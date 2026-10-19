<#
    git-autocommit.ps1 — plasa de siguranță pentru panoul Changes

    Ce face: dacă un repo înregistrat are fișiere modificate și necomitate,
    le comită singur. Astfel panoul `Changes` al interfeței nu are niciodată
    ce arăta, iar omul nu e nevoit să dea comit.

    Ce NU face, deliberat:
      - nu atinge interfața aplicației
      - nu atinge hook-urile git — sunt globale pe mașină și aparțin altui
        mecanism (LiveReview); aici ar produce conflict
      - nu șterge nimic, nu face reset, nu face force push
      - nu comită fișiere care PAR secrete (nume) sau CARE CONȚIN secrete
      - nu comită fișierele declarate în git-autocommit-ignorat.txt
      - nu comită un fișier scris acum puțin timp (timpul de „așezare"),
        ca să nu prindă o scriere la jumătate

    Coduri de ieșire:
      0  curat, sau așteaptă așezarea, sau a făcut salvarea, sau autoproba a trecut
      1  refuzat: secrete, căi interzise, sau comitul a eșuat
      2  eroare de mediu: repo invalid, git indisponibil
      3  autoproba a eșuat (o poartă care nu poate deveni roșie e decor)

    Fișiere pereche:
      git-autocommit-registru.txt  — câte o cale de repo pe rând
      git-autocommit-ignorat.txt  — căi care NU se comită niciodată (wildcard)
#>

[CmdletBinding()]
param(
    [string]$Repo,
    [int]$SettleSeconds = 60,
    [switch]$CeVerificare,
    [switch]$AutoProbe,
    [switch]$DoiSingurul
)

$ErrorActionPreference = 'Stop'

$registru = Join-Path $PSScriptRoot 'git-autocommit-registru.txt'
$ignorat  = Join-Path $PSScriptRoot 'git-autocommit-ignorat.txt'
$log      = Join-Path $PSScriptRoot 'raport-autocomit.log'

# ---------------------------------------------------------------------------
# PORTA DE SECRETE
# ---------------------------------------------------------------------------

# (a) pe NUME — cale, extensie sau fragment
$secreteNume = '(?i)(\.env($|\.)|(^|[\\/])id_rsa|(^|[\\/])id_ed25519|\.pem$|\.pfx$|\.p12$|\.keystore$|(^|[\\/])credentials?($|\.|\[)|(^|[\\/])\.?netrc|(^|[\\/])secrets?($|[\\/.\[])|secret|token|password|passwd)'

# (b) pe CONTINUT — forme care chiar arată material secret
$secreteContinut = @(
    '-----BEGIN [A-Z ]*PRIVATE KEY-----',
    '-----BEGIN OPENSSH PRIVATE KEY-----',
    'AKIA[0-9A-Z]{16}',
    'ASIA[0-9A-Z]{16}',
    'gh[pousr]_[A-Za-z0-9]{20,}',
    'github_pat_[A-Za-z0-9_]{20,}',
    'glpat-[A-Za-z0-9_\-]{20,}',
    'sk-[A-Za-z0-9]{20,}',
    'AIza[0-9A-Za-z_\-]{30,}',
    'xox[baprs]-[A-Za-z0-9\-]{10,}',
    '(?i)\b(password|passwd|secret|token|api[_-]?key|access[_-]?key|client[_-]?secret)\b\s*[:=]\s*["'']?[^\s"''<>$\{]{8,}'
)

# extensii peste care nu citim conținutul (binare / prea mari)
$binare = '\.(png|jpe?g|gif|webp|bmp|ico|svg|pdf|zip|7z|rar|gz|bz2|xz|tar|exe|dll|so|dylib|mp3|mp4|wav|avi|mov|mkv|docx?|xlsx?|pptx?|ttf|otf|woff2?|db|sqlite|psd|ai|sketch)$'

# ZONE ORBE DECLARATE.
# Un detector conține, prin definiție, tiparele pe care le caută — altfel
# n-ar putea să le caute. Deci poarta nu se poate scanda pe ea însăși.
# Excepția e NOUMITĂ, nu ascunsă, și numărul ei ajunge în mesajul de comit,
# ca oricine citește istoricul să vadă ce a fost necăutat.
#
# POTRIVIRE PRIN NUME DE FIȘIER, NU PRIN CALE ABSOLUTĂ — măsurat 2026-10-19.
# Excepțiile erau scrise ca 'AI-Kit/git-autocommit.ps1', adică pentru structura
# de pe D:. După mutarea pe Drive, fișierul stă la
# 02_Areas/02_2-AI-SOT/AI-Kit/AI-Kit_manual/git-autocommit.ps1, deci potrivirea
# pe cale nu se mai făcea. Rezultatul: poarta respingea propriul detector cu
# „secrete în continut" și ieșea 1 la fiecare 5 minute, pentru totdeauna.
# Numele fișierului nu se schimbă la mutare, deci potrivirea pe nume e cea care
# rezistă la orice reorganizare viitoare.
$exceptiiDefinire = @(
    'git-autocommit.ps1',
    'git-autocommit-ignorat.txt'
)

$citireMaxOcteti = 512000

function Test-ContinutSecret {
    <#
      Întoarce lista de motive pentru care un fișier e suspect.
      Fișier lipsă, binar sau prea mare -> lista goala (nu e verdict de
      curățenie, e verdict de «nu am putut citi»; asta se spune în log).
    #>
    param([string]$Full)

    $motive = New-Object System.Collections.Generic.List[string]

    if (-not (Test-Path -LiteralPath $Full)) { return $motive }
    $it = Get-Item -LiteralPath $Full
    if ($it.PSIsContainer) { return $motive }
    if ($it.Name -match $binare) { return $motive }
    if ($it.Length -eq 0) { return $motive }
    if ($it.Length -gt $citireMaxOcteti) { return $motive }

    $raw = $null
    try { $raw = [System.IO.File]::ReadAllText($Full) } catch { return $motive }
    if ([string]::IsNullOrEmpty($raw)) { return $motive }

    # nul = binar deghizat
    if ($raw.IndexOf([char]0) -ge 0) { return $motive }

    foreach ($t in $secreteContinut) {
        if ($raw -match $t) {
            $nume = ([regex]::Match($t, '\(\?i\)|-----BEGIN \[[^\]]+\]|AKIA|gh[pousr]_|glpat-|sk-|AIza|xox\[[^\]]+\]')).Value
            $motive.Add(('continut: ' + ($(if ($nume) { $nume } else { 'tipar' }))))
            break
        }
    }
    return $motive
}

function Scrie-Log([string]$msg) {
    # Add-Content NU garantează rând nou înaintea primei scrieri pe fișier
    # nou; de aceea verificăm explicit sfârșitul, nu doar existentă.
    $prefix = ''
    if (Test-Path -LiteralPath $log) {
        $t = [System.IO.File]::ReadAllText($log)
        if ($t.Length -gt 0 -and -not ($t.EndsWith("`n"))) { $prefix = "`r`n" }
    }
    $linie = $prefix + '[' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + '] ' + $msg
    Add-Content -LiteralPath $log -Value $linie -Encoding UTF8
}

# ---------------------------------------------------------------------------
# AUTOPROBA — o poartă care nu poate deveni ROȘIE e decor, nu poartă.
# Fiecare caz pozitiv trebuie să ardă; un caz negativ nu trebuie să ardă.
# ---------------------------------------------------------------------------
if ($AutoProbe) {
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('acprobe-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tmp -Force | Out-Null
    $cazuri = @(
        @{ n = 'PEM privat';        c = "-----BEGIN RSA PRIVATE KEY-----`nMIIEow=="; a = $true },
        @{ n = 'cheie AWS';        c = 'AKIAIOSFODNN7EXAMPLE';                            a = $true },
        @{ n = 'token GitHub';     c = 'ghp_0123456789abcdefghijABCDEFGHIJ';               a = $true },
        @{ n = 'parola atribuita'; c = 'password = "Str0ng-SecreT!"';                     a = $true },
        @{ n = 'api_key atribuita';c = 'api_key: abcd1234efgh5678';                        a = $true },
        @{ n = 'text oarecare';    c = "nu comita asta`n";                                a = $false },
        @{ n = 'README curat';     c = "# Documentatie`nFoloseste tokenul din vault.";    a = $false },
        @{ n = 'cod fara secret';  c = 'function Get() { return password.Length; }';      a = $false }
    )
    $ars = 0; $pica = 0
    foreach ($c in $cazuri) {
        $f = Join-Path $tmp (($c.n -replace '\s', '_') + '.txt')
        [System.IO.File]::WriteAllText($f, $c.c, (New-Object System.Text.UTF8Encoding($false)))
        $m = Test-ContinutSecret -Full $f
        $ars = if ($m.Count -gt 0) { $true } else { $false }
        if ($ars -eq [bool]$c.a) {
            $pica++
            Write-Output ('AUTOPROBA: TRECUT  ' + $c.n + '  (așteptat ardere=' + $c.a + ')')
        } else {
            Write-Output ('AUTOPROBA: PICAT   ' + $c.n + '  (așteptat ardere=' + $c.a + ', real=' + $ars + ') motive=' + (($m | Select-Object -First 2) -join ','))
        }
    }
    # control de sensibilitate: cazul pozitiv TREBUIE să ardă, altfel
    # poarta e goală și trece tot ce-i dăm
    Write-Output ('AUTOPROBA: ' + $pica + '/' + $cazuri.Count + ' cazuri')
    if ($pica -eq $cazuri.Count) { Write-Output 'AUTOPROBA: POARTA DE SECRETE POATE DEVENI ROȘIE'; exit 0 }
    exit 3
}

# ---------------------------------------------------------------------------
# repo-ul de supraveghat
# ---------------------------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($Repo)) {
    $Repo = $null
    $toate = @()
    if (Test-Path -LiteralPath $registru) {
        $toate = @(Get-Content -LiteralPath $registru -Encoding UTF8 |
                   Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.Trim().StartsWith('#') } |
                   ForEach-Object { $_.Trim() } |
                   Where-Object { $_ })
    }

    # Mai multe repo-uri inregistrate: le rulate pe toate, fiecare prin propria
    # trecere, ca sa nu se modifice nimic din corpii portilor de mai jos.
    # Reintrarea e blocata de -DoiSingurul, altfel s-ar apela la infinit.
    if ($toate.Count -gt 1 -and -not $DoiSingurul) {
        $celRau = 0
        foreach ($unu in $toate) {
            Write-Output ('AUTOCOMIT: === ' + $unu + ' ===')
            $arg = @{}
            foreach ($k in $PSBoundParameters.Keys) {
                if ($k -ne 'DoiSingurul') { $arg[$k] = $PSBoundParameters[$k] }
            }
            $arg['Repo'] = $unu
            $arg['DoiSingurul'] = $true
            $global:LASTEXITCODE = 0
            & $PSCommandPath @arg
            $cod = $LASTEXITCODE
            if ($cod -gt $celRau) { $celRau = $cod }
        }
        Write-Output ('AUTOCOMIT: ' + $toate.Count + ' repo-uri verificate, cel mai rau cod ' + $celRau)
        exit $celRau
    }

    if ($toate.Count -ge 1) { $Repo = $toate[0] }
    if (-not $Repo) { $Repo = (Split-Path -Parent $PSScriptRoot) }   # rădăcina vaultului
}

if (-not (Test-Path -LiteralPath $Repo)) {
    Write-Output "AUTOCOMIT: repo inexistent: $Repo"
    exit 2
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Output 'AUTOCOMIT: git nu este pe PATH'
    exit 2
}

Push-Location -LiteralPath $Repo
try {
    $interior = (& git rev-parse --is-inside-work-tree 2>$null)
    if ($LASTEXITCODE -ne 0 -or $interior -ne 'true') {
        Write-Output "AUTOCOMIT: nu e repo git: $Repo"
        exit 2
    }

    $raw = @(& git status --porcelain 2>$null)
    if ($LASTEXITCODE -ne 0) { Write-Output 'AUTOCOMIT: git status a esuat'; exit 2 }

    # curat: nu atingem nici logul, nici commitul
    if ($raw.Count -eq 0) {
        Write-Output 'AUTOCOMIT: curat, nimic de facut'
        exit 0
    }

    # --- lista căilor candidate ----------------------------------------------
    $cai = New-Object System.Collections.Generic.List[string]
    foreach ($linie in $raw) {
        $p = $linie.Substring(3).Trim()
        if ($p -match ' -> ') { $p = ($p -split ' -> ')[-1] }   # renumări
        $p = $p.Trim('"')
        $cai.Add($p)
    }

    # Căile care EXISTĂ acum pe disc. O ștergere nu e o cale cu secrete:
    # portile au rost doar pe ce urmează să intre în istoric.
    $caiNoi = New-Object System.Collections.Generic.List[string]
    foreach ($c in $cai) {
        if (Test-Path -LiteralPath (Join-Path $Repo $c)) { $caiNoi.Add($c) }
    }

    # --- poarta 1: secrete pe NUME -------------------------------------------
    $periculoase = @($caiNoi | Where-Object { $_ -match $secreteNume })
    if ($periculoase.Count -gt 0) {
        Scrie-Log ('REFUZAT ' + $periculoase.Count + ' cale(s) cu secrete în NUME: ' + (($periculoase | Select-Object -First 5) -join ' | '))
        Write-Output ('AUTOCOMIT: REFUZAT — secrete în nume: ' + (($periculoase | Select-Object -First 5) -join ' | '))
        exit 1
    }

    # --- poarta 2: secrete pe CONTINUT ---------------------------------------
    $gasite = New-Object System.Collections.Generic.List[string]
    $citite = 0; $sarite = 0; $exceptate = 0
    foreach ($c in $caiNoi) {
        $full = Join-Path $Repo $c
        if (-not (Test-Path -LiteralPath $full)) { continue }
        $it = Get-Item -LiteralPath $full
        if ($it.PSIsContainer) { continue }
        # potrivire pe NUME, nu pe cale — vezi $exceptiiDefinire
        $numeFisier = [System.IO.Path]::GetFileName($c)
        if ($exceptiiDefinire -contains $numeFisier) { $exceptate++; continue }
        if ($it.Name -match $binare -or $it.Length -gt $citireMaxOcteti) { $sarite++; continue }
        $citite++
        $m = Test-ContinutSecret -Full $full
        if ($m.Count -gt 0) { $gasite.Add($c + ' [' + (($m | Select-Object -First 1)) + ']') }
    }
    if ($gasite.Count -gt 0) {
        Scrie-Log ('REFUZAT ' + $gasite.Count + ' cale(s) cu secrete în CONTINUT: ' + (($gasite | Select-Object -First 5) -join ' | '))
        Write-Output ('AUTOCOMIT: REFUZAT — secrete în conținut: ' + (($gasite | Select-Object -First 5) -join ' | '))
        exit 1
    }

    # --- poarta 3: căi declarate INTERZISE -----------------------------------
    if (Test-Path -LiteralPath $ignorat) {
        $reguli = @(Get-Content -LiteralPath $ignorat -Encoding UTF8 |
                    Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.Trim().StartsWith('#') } |
                    ForEach-Object { $_.Trim() })
        $interzise = New-Object System.Collections.Generic.List[string]
        foreach ($c in $caiNoi) {
            foreach ($r in $reguli) {
                if ($c -like $r) { $interzise.Add($c); break }
            }
        }
        if ($interzise.Count -gt 0) {
            Scrie-Log ('REFUZAT ' + $interzise.Count + ' cale(s) declarate interzise: ' + (($interzise | Select-Object -First 5) -join ' | '))
            Write-Output ('AUTOCOMIT: REFUZAT — căi interzise: ' + (($interzise | Select-Object -First 5) -join ' | '))
            exit 1
        }
    }

    # --- poarta 4: timpul de așezare ------------------------------------------
    $prag = (Get-Date).AddSeconds(-1 * $SettleSeconds)
    $nestabilite = New-Object System.Collections.Generic.List[string]
    foreach ($c in $cai) {
        $full = Join-Path $Repo $c
        if (-not (Test-Path -LiteralPath $full)) { continue }
        $lw = (Get-Item -LiteralPath $full).LastWriteTime
        if ($lw -gt $prag) { $nestabilite.Add($c) }
    }
    if ($nestabilite.Count -gt 0) {
        Write-Output ('AUTOCOMIT: așteaptă așezarea (' + $nestabilite.Count + ' fișier(e) modificate în ultimele ' + $SettleSeconds + 's)')
        exit 0
    }

    # --- mesajul: spune CE s-a schimbat, nu „chore: update <fișier>" ----------
    $arata = ($cai | Select-Object -First 3) -join ', '
    if ($cai.Count -gt 3) { $arata = $arata + ', ...' }
    $mesaj = 'Salvare automata: ' + $cai.Count + ' cale(i) modificate — ' + $arata
    $mesaj = $mesaj + ' [porti: nume 0, continut ' + $citite + ', sarite-binar ' + $sarite + ', exceptie-definire ' + $exceptate + ']'

    if ($CeVerificare) {
        # MĂSURĂTOARE DE INDEXABILITATE, nu de intenție.
        #
        # Defect găsit 2026-10-19: modul de verificare spunea 0 pentru un repo
        # al cărui `git add -A` real picotează. Verificarea trecea peste poarta
        # care singura poate da roșu, deci nu putea deveni roșie — decor.
        #
        # Probe uscată: `git add -An` face exact aceeași parcurgere ca `git add -A`
        # și NU scrie, dar raportează exact aceleași erori de deschidere.
        $probe = @(& git add -An 2>&1)
        if ($LASTEXITCODE -ne 0) {
            $erori = @($probe | Where-Object { $_ -match '^(error|fatal)' })
            $most = ($erori | Select-Object -First 2) -join ' | '
            Scrie-Log ('VERIFICARE: indexare imposibila (' + $erori.Count + ' erori) ' + $most)
            Write-Output ('AUTOCOMIT: [verificare] NU SE POATE COMITA — ' + $erori.Count + ' eroare de indexare')
            Write-Output ('AUTOCOMIT: [verificare] ' + $most)
            exit 1
        }
        Write-Output ('AUTOCOMIT: [verificare] indexare posibila, ar comita ' + $cai.Count + ' cale(i)')
        Write-Output ('AUTOCOMIT: [verificare] mesaj: ' + $mesaj)
        exit 0
    }

    # --- LiveReview NU blocheaza comitul ---------------------------------------
    # core.hooksPath e global, deci orice repo nou se armeaza automat si prima
    # comitare esuiaza cu "review attestation missing". Măsurat: intr-un repo
    # de probă curat, comitul a fost oprit de poartă.
    #
    # Se dezactiveaza DOAR in acest repo, ca in PROMPT git install.md sectiunea 5.
    # Reversibil cu `lrc hooks enable`, vizibil cu `lrc hooks status`.
    # core.hooksPath global NU se atinge. Nimic nu se sterge: se scrie un marcaj.
    $marcajLrc = Join-Path $Repo '.git\lrc\disabled'
    if (-not (Test-Path -LiteralPath $marcajLrc)) {
        if (Get-Command lrc -ErrorAction SilentlyContinue) {
            & lrc hooks disable 2>&1 | Out-Null
        }
    }

    & git add -A 2>$null
    if ($LASTEXITCODE -ne 0) { Scrie-Log 'REFUZAT: git add a esuat'; Write-Output 'AUTOCOMIT: git add a esuat'; exit 1 }

    $out = @(& git commit -m $mesaj 2>&1)
    if ($LASTEXITCODE -ne 0) {
        Scrie-Log ('ESUAT la comit: ' + (($out | Select-Object -First 2) -join ' | '))
        Write-Output ('AUTOCOMIT: comitul a esuat: ' + (($out | Select-Object -First 1)))
        exit 1
    }

    # --- verificare reală, nu cod de ieșire -----------------------------------
    $ramase = @(& git status --porcelain 2>$null)
    if ($ramase.Count -ne 0) {
        Scrie-Log ('PARTIAL: ' + $ramase.Count + ' cale(i) au ramas necomitate')
        Write-Output 'AUTOCOMIT: parțial — au rămas căi necomitate'
        exit 1
    }

    $sha = (& git rev-parse --short HEAD 2>$null)
    Scrie-Log ('OK ' + $sha + ' — ' + $mesaj)
    Write-Output ('AUTOCOMIT: salvat ' + $sha + ' — ' + $cai.Count + ' cale(i)')
    exit 0
}
finally {
    Pop-Location
}