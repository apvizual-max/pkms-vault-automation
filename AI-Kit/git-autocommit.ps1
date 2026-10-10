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
      - nu comită fișiere care par secrete
      - nu comită un fișier scris acum puțin timp (timpul de „așezare"),
        ca să nu prindă o scriere la jumătate

    Coduri de ieșire:
      0  curat, sau așteaptă așezarea, sau a făcut salvarea
      1  refuzat: secrete în lista de comitat, sau comitul a eșuat
      2  eroare de mediu: repo invalid, git indisponibil
#>

[CmdletBinding()]
param(
    [string]$Repo,
    [int]$SettleSeconds = 60,
    [switch]$CeVerificare
)

$ErrorActionPreference = 'Stop'

# --- unde stă registrul și logul ---------------------------------------------
$registru = Join-Path $PSScriptRoot 'git-autocommit-registru.txt'
$log     = Join-Path $PSScriptRoot 'raport-autocomit.log'

function Scrie-Log([string]$msg) {
    if (Test-Path -LiteralPath $log) {
        $t = Get-Content -LiteralPath $log -Raw -Encoding UTF8
        if ($null -ne $t -and $t.Length -gt 0 -and -not $t.EndsWith("`n")) {
            $t = $t + "`r`n"
        }
    } else { $t = '' }
    $linie = '[' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + '] ' + $msg
    Add-Content -LiteralPath $log -Value $linie -Encoding UTF8
}

# --- repo-urile de supraveghat -----------------------------------------------
if ([string]::IsNullOrWhiteSpace($Repo)) {
    $Repo = $null
    if (Test-Path -LiteralPath $registru) {
        $Repo = ((Get-Content -LiteralPath $registru -Encoding UTF8) |
                 Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.Trim().StartsWith('#') } |
                 Select-Object -First 1).Trim()
    }
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

    # --- poarta 1: secrete -----------------------------------------------------
    $secrete = '(\.env($|\.)|(^|[\\/])id_rsa|(^|[\\/])id_ed25519|\.pem$|\.pfx$|\.p12$|(^|[\\/])credentials?($|\.|\[)|secret|token|password)'
    $cai = New-Object System.Collections.Generic.List[string]
    foreach ($linie in $raw) {
        $p = $linie.Substring(3).Trim()
        if ($p -match ' -> ') { $p = ($p -split ' -> ')[-1] }   # renumări
        $p = $p.Trim('"')
        $cai.Add($p)
    }
    $periculoase = $cai | Where-Object { $_ -match $secrete }
    if ($periculoase) {
        Scrie-Log ('REFUZAT ' + $periculoase.Count + ' cale(s) cu posibile secrete: ' + (($periculoase | Select-Object -First 5) -join ' | '))
        Write-Output ('AUTOCOMIT: REFUZAT — posibile secrete: ' + (($periculoase | Select-Object -First 5) -join ' | '))
        exit 1
    }

    # --- poarta 2: timpul de așezare ------------------------------------------
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

    if ($CeVerificare) {
        Write-Output ('AUTOCOMIT: [verificare] ar comita ' + $cai.Count + ' cale(i)')
        Write-Output ('AUTOCOMIT: [verificare] mesaj: ' + $mesaj)
        exit 0
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