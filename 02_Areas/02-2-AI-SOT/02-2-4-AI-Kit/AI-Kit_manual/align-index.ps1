<#
  PKMS align-index.ps1
  Alinierea automata a indexurilor 00_INDEX.md — contractul vaultului §18 + §19.

  Fara AI, fara retea, fara cost, fara scriere in backup.

  Ordinea fixa din §19.1:
    1. inchide usa in urma lui (mutex, WaitOne(0))
    2. masoara fiecare folder eligibil
    3. clasifica in exact cinci stari (§18.3)
    4. repara (§18.4), pastrand motivul si orice text scris de om
    5. scrie doar ce a diferit, dupa ce a pus vechea versiune in
       _SYSTEM\arhiva-indexe\<data>_<ora>\
    6. raporteaza in log DOAR daca a fost eveniment

  Cele cinci stari: LIPSA · CORUPT · INCOMPLET · NEALINIAT · CONFORM.

  REGULA CEA MAI IMPORTANTA DIN FISIER: o regula care nu se declanseaza e o
  regula scrisa in decor. De aceea fiecare tipar de excluziune de mai jos e
  scris ca [\\/] in paranteza patrata, cu bara inclinata scrisă explicit si cu
  slash-ul alternat acceptat. Un sir care incepe cu o bara inclinata urmata de
  o cifra ar fi citit de .NET ca secventa octala: bara inclinata plus zero plus
  unu devine caracterul cu codul 1 (U+0001), care nu se potriveste cu nicio
  cale reala. Asa s-a intamplat o data: 330 de indexuri s-au scris in arbori
  declarati "nu se atinge". De aceea NU exista in acest fisier niciun sir care
  sa inceapa cu o bara inclinata urmata de o cifra de la zero la sapte.
  Proba, pe cai reale: ruleaza cu -VerificaExcluderi.

  NU sterge nimic. Nu scrie decat 00_INDEX.md, arhiva lui si logul.
#>
param(
  # ATENTIE: lasat GOAL intentionat, ca in reconcile.ps1:7. Daca am pune aici
  # un drum, Get-PkmsVault nu s-ar apela niciodata, iar $env:PKMS_VAULT ar fi
  # ignorat in tacure. Calea vaultului o descopera AI-Kit\paths.ps1.
  [string]$Vault = '',
  # face tot, nu scrie nimic, tipareste ce ar face.
  [switch]$CeVad,
  # doar raportul de excluziuni, pe cai reale. Nu atinge nimic.
  [switch]$VerificaExcluderi,
  # aliniaza un singur subarbore.
  [string]$DoarCargol = ''
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\paths.ps1"
if (-not $Vault) { $Vault = Get-PkmsVault }
# Poarta de cale reala, INAINTE de Resolve-Path: pe o cale vida Resolve-Path
# arunca sub ErrorActionPreference=Stop, deci o eroare necitita in loc de un
# refuz curat. Pe D: sta stubul cu un fisier — Test-Path trece, dar nu e vault.
Assert-PkmsVaultReal -Vault $Vault -Cine 'align-index'
$Vault = (Resolve-Path -LiteralPath $Vault).Path
# MASURAT: Resolve-Path pastreaza bara de la final. Fara taierea de mai jos,
# calea relativa iese fara separatorul de inceput si toate cele 689 de
# indexuri para nealiniate — iar in modul de scriere toate s-ar rescrie.
$Vault = Normalize-PkmsPath $Vault

# backupul e imutabil: nici citit cu scriere. il aflam doar ca sa ne aparam.
$BackupRoot = $null
try { $BackupRoot = Get-PkmsBackup } catch { $BackupRoot = $null }

# ---------------------------------------------------------------------------
# ZONE INTERZISE (§18.6) — toate tiparele in forma [\\/]... ([\\/]|$)
# ([\\/]|$) in loc de doar [\\/]: un folder gol, sau unul aflat la capatul
# caii, nu are nimic dupa el, deci '([\\/])' nu s-ar potrivi NICIODATA. Patru
# din cele de mai jos (.claudian, .neural_memory, .sentinel_temp,
# .wwebjs_cache) sunt exact astfel, la radacina vaultului: cu bara finala
# raportau 0 cai — o regula care nu se declanseaza. Forma de mai jos se
# declanseaza si pe ele, si tot ramane imuna la secventele octale.
# ---------------------------------------------------------------------------
$Excluderi = @(
  @{ Label = '.obsidian';               Pat = '[\\/]\.obsidian([\\/]|$)' }
  @{ Label = '.trash';                  Pat = '[\\/]\.trash([\\/]|$)' }
  @{ Label = '.git';                    Pat = '[\\/]\.git([\\/]|$)' }
  @{ Label = '.vault-intelligence';     Pat = '[\\/]\.vault-intelligence([\\/]|$)' }
  @{ Label = '.claudian';               Pat = '[\\/]\.claudian([\\/]|$)' }
  @{ Label = '.neural_memory';          Pat = '[\\/]\.neural_memory([\\/]|$)' }
  @{ Label = '.sentinel_temp';          Pat = '[\\/]\.sentinel_temp([\\/]|$)' }
  @{ Label = '.wwebjs_cache';           Pat = '[\\/]\.wwebjs_cache([\\/]|$)' }
  @{ Label = 'node_modules';            Pat = '[\\/]node_modules([\\/]|$)' }
  # Radacina unei zone interzise NU e in interiorul ei: e un raft obisnuit al
  # vaultului, si se indexeaza ca orice alt raft. Doar interiorul e neatins.
  # (build-index.ps1 cere deja bara finala, si cele 13 radacini pastrate pe disc
  #  sunt tot atatea. Daca align ar cere doar '([\\/]|$)', ar stinge radacinile si
  #  ar contrazice build-index in exact zonele protejate.)
  @{ Label = '01_Theme_Salient';        Pat = '[\\/]01_Theme_Salient[\\/]' }
  @{ Label = '02_Media_Uploads\20\d\d'; Pat = '[\\/]02_Media_Uploads[\\/]20\d\d[\\/]' }
  @{ Label = 'Skills_Archive';          Pat = '[\\/]Skills_Archive[\\/]' }
  @{ Label = 'HERMES-Skills';           Pat = '[\\/]HERMES-Skills[\\/]' }
  # cele 3.988 de fisiere cu indexuri scrise in gresit sunt probe ale unui defect,
  # nu continut. build-index le exclude; daca align nu le exclude, ar rescrie
  # indexuri in interiorul caruia n-are voie sa scrie.
  @{ Label = 'indexuri generate in gresit'; Pat = '[\\/]indexuri generate in gresit[\\/]' }
  # contractul scrie '_Skills_BackUp', dar pe disk NU exista un folder cu exact
  # acest nume: exista '_Skills_BackUp_Archive_2026-07-15' si '-2026-08-09'.
  # scris la cum scrie contractul, tiparul ar opri 0 cai — deci n-ar fi o
  # exclusiune, ci o rugaciune. fara bara finala, ca sa se declanseze.
  @{ Label = '_Skills_BackUp';          Pat = '[\\/]_Skills_BackUp' }
  # arhiva pe care o scrie ACEST script (§18.4). Nu e in lista din §18.6, dar
  # §18.6 nu spune nimic despre ea, iar contractul cere sa existe. Daca ar fi
  # masurata, prima rulare ar crea acolo fise, a doua le-ar gasi ca foldere
  # noi, si automatul s-ar hrani singur cu propria arhiva. Bara finala e
  # optionala, ca tiparul sa loveasca si folderul 'arhiva-indexe' el insusi.
  # NOTE: in vaultul real acest folder nu exista inca (n-a curs nicio aliniere),
  # deci tiparul raporteaza 0 cai Acolo. Pe fixture se declanseaza la 3 foldere.
  @{ Label = '_SYSTEM\arhiva-indexe';   Pat = '[\\/]arhiva-indexe[\\/]?' }
)

function Test-Excluded([string]$path) {
  foreach ($e in $Excluderi) {
    if ($path -match $e.Pat) { return $true }
  }
  return $false
}

function Test-UnderBackup([string]$path) {
  if (-not $BackupRoot) { return $false }
  if ($path -eq $BackupRoot) { return $true }
  $p = $BackupRoot.TrimEnd('\') + '\'
  if ($path.StartsWith($p, [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
  return $false
}

# ---------------------------------------------------------------------------
# -VerificaExcluderi: aplica lista peste caile REALE si raporteaza fiecare
# tipar. Un tipar cu 0 cai e marcat DEFECT, nu acceptat ca "merge si el".
# ---------------------------------------------------------------------------
if ($VerificaExcluderi) {
  Write-Output "=== Verificare exclusiuni — $Vault ==="
  Write-Output '(citire doar; nu s-a scris nimic)'
  $toate = @(Get-ChildItem -LiteralPath $Vault -Directory -Recurse -Force -EA SilentlyContinue |
             Where-Object { -not (Test-UnderBackup $_.FullName) } |
             Sort-Object FullName)
  Write-Output ("foldere reale parcurse: {0}" -f $toate.Count)
  Write-Output ''
  $defecte = 0
  foreach ($e in $Excluderi) {
    $n = @($toate | Where-Object { $_.FullName -match $e.Pat }).Count
    if ($n -eq 0) {
      Write-Output ("[DEFECT] {0,-24} {1,5} cai — tiparul NU se declanseaza" -f $e.Label, $n)
      $defecte++
    } else {
      Write-Output ("[OK]     {0,-24} {1,5} cai oprite" -f $e.Label, $n)
    }
  }
  Write-Output ''
  foreach ($c in @('07_Site_Build', '02_Media_Uploads', '01_Theme_Salient')) {
    $pat = '[\\/]' + [regex]::Escape($c) + '[\\/]'
    $n = @($toate | Where-Object { $_.FullName -match $pat }).Count
    if ($n -eq 0) {
      Write-Output ("[DEFECT] contra-proba {0}: nu exista in vault" -f $c)
    } else {
      Write-Output ("[OK]     contra-proba {0}: {1} cai, neatinse de tipare" -f $c, $n)
    }
  }
  Write-Output ''
  if ($defecte -eq 0) { Write-Output 'VERDICT: toate tiparele se declanseaza pe cai reale.' }
  else { Write-Output ("VERDICT: {0} tipar(e) nu se declanseaza. defuncte, nu scuze." -f $defecte) }
  exit 0
}

# ---------------------------------------------------------------------------
# 1. REGULA DE BLOCAJ (§19.5) — mutex, nu fisier-pid.
# Un fisier se poate minte (pid reutilizat, scriere pe jumatate). Mutexul nu.
# Daca alt automat tine usa, iesim tacut, cod 0, fara log, fara scriere.
# ---------------------------------------------------------------------------
$mutex = $null
$mutexAlMeu = $false
$modScriere = (-not $CeVad)

if ($modScriere) {
  foreach ($mn in @('Global\PKMS_AlignIndex_v1', 'Local\PKMS_AlignIndex_v1', 'PKMS_AlignIndex_v1')) {
    try { $mutex = New-Object System.Threading.Mutex($false, $mn) } catch { $mutex = $null }
    if ($mutex) { break }
  }
  if (-not $mutex) { Write-Output 'BLOCAJ: mutexul nu s-a putut crea.'; exit 1 }
  try { $mutexAlMeu = $mutex.WaitOne(0) }
  catch [System.Threading.AbandonedMutexException] { $mutexAlMeu = $true }
  if (-not $mutexAlMeu) {
    # §19.5: iesim fara sa scriem nimic, cod 0. Contractul e respectat
    # integral — zero log, zero scriere, zero modificare, iar programarea
    # reincearca la urmatoarea trecere.
    #
    # Ce se schimba, exact un rand PE CONSOLA: altfel omul care ruleaza cu
    # mana ramane in fata a unui ecran gol si nu are de unde sti ca nu s-a
    # intamplat nimic. Logul ramane neatins.
    Write-Output 'BLOCAT: alta rulare tine usa. Nimic scris, nimic atins, nimic stricat.'
    try { $mutex.Dispose() } catch { }
    exit 0
  }
}

$logFile    = Join-Path $Vault 'raport-aliniere.log'
$data       = Get-Date -Format 'yyyy-MM-dd'
# Arhiva e pe RULARA, nu pe zi (defect #4, audit 2026-10-09). Patru rulari
# pe zi scriau in acelasi folder si se suprascrau, deci ' inapoi un pas'
# (§18.4) era ' inapoi ultimele douazeci de minute'. Secunda intra in nume
# ca doua rulari din aceeasi zi sa nu se piarda una pe alta.
$arhivaRun  = $data + '_' + (Get-Date -Format 'HH-mm-ss')
$arhivaBaza = Join-Path $Vault ('_SYSTEM\arhiva-indexe\' + $arhivaRun)

# ---------------------------------------------------------------------------
# functii de masuratoare — copiate din build-index.ps1, ca doua rulari
# consecutive sa deze exact acelasi text in blocurile derivate.
# ---------------------------------------------------------------------------
function Human($b) {
  if ($b -ge 1GB) { return "{0:N2} GB" -f ($b/1GB) }
  if ($b -ge 1MB) { return "{0:N0} MB" -f ($b/1MB) }
  if ($b -ge 1KB) { return "{0:N0} KB" -f ($b/1KB) }
  return "$b B"
}

function Get-ValueWords([string]$name, [int]$max, [bool]$stripExt) {
  if (-not $name) { return @() }
  $base = $name
  if ($stripExt) { $base = [System.IO.Path]::GetFileNameWithoutExtension($name) }
  if (-not $base) { $base = $name }
  $w = New-Object System.Collections.Generic.List[string]
  foreach ($tok in ($base -split '[^0-9A-Za-z\u00C0-\u024F]+')) {
    if ($tok.Length -lt 3) { continue }
    if ($tok -notmatch '[A-Za-z\u00C0-\u024F]') { continue }
    $w.Add($tok)
    if ($w.Count -ge $max) { break }
  }
  return @($w.ToArray())
}

function Norm([string[]]$lines) {
  if (-not $lines) { return '' }
  $i = $lines.Count - 1
  while ($i -ge 0 -and [string]::IsNullOrWhiteSpace([string]$lines[$i])) { $i-- }
  if ($i -lt 0) { return '' }
  return (($lines[0..$i]) -join "`n")
}

function Test-LiniaDes([string]$l) { return ($l -match '^\*\*\d+ fi.iere · .+ · \d+ subfoldere\*\*$') }

# linkuri: % se codifica PRIMUL, apoi #. altfel %23 noua iese %2523 si nu merge.
function Cod-Link([string]$n) { return $n.Replace('%','%25').Replace('#','%23') }

$script:putineCuvinte = 0

try {
  # -------------------------------------------------------------------------
  # 2. MASOARA (§19.1 pasul 2) — fiecare folder eligibil: cate fisiere,
  # cate subfoldere, cine.
  # -------------------------------------------------------------------------
  $radacina = $Vault
  if ($DoarCargol) {
    $c = Join-Path $Vault $DoarCargol
    if (-not (Test-Path -LiteralPath $c -PathType Container)) {
      Write-Output "CARGOL INEXISTENT: $c"
      exit 1
    }
    $radacina = (Resolve-Path -LiteralPath $c).Path
  }

  # folderul numit chiar trebuie masurat: Get-ChildItem intoarce COPIILE lui,
  # nu pe el. fara asta, -DoarCargol ar alinia golul.
  $dirs = @(
    if ($radacina -ne $Vault) { Get-Item -LiteralPath $radacina -Force }
    Get-ChildItem -LiteralPath $radacina -Directory -Recurse -Force -EA SilentlyContinue |
      Where-Object { -not (Test-Excluded $_.FullName) -and -not (Test-UnderBackup $_.FullName) -and $_.FullName -ne $Vault }
  ) | Sort-Object FullName -Unique

  $recs = New-Object System.Collections.Generic.List[object]
  foreach ($dir in $dirs) {
    $files = @(Get-ChildItem -LiteralPath $dir.FullName -File -Force -EA SilentlyContinue)
    $subs  = @(Get-ChildItem -LiteralPath $dir.FullName -Directory -Force -EA SilentlyContinue |
               Where-Object { -not (Test-Excluded $_.FullName) -and -not (Test-UnderBackup $_.FullName) })
    $rel   = $dir.FullName.Substring($Vault.Length + 1)

    # 00_INDEX.md e indexul pe care il scriem chiar acum. Daca intra in
    # masuratoare a blocurilor, fiecare index s-ar descrie pe sine, iar
    # 'cel mai mare fisier' ar fi mereu el. La fel, jurnalele vii ale
    # motorului (Test-PkmsLiveLog): se schimba in timpul rularii, deci nu
    # pot intra in cifre — altfel indexul nu ajunge niciodata CONFORM.
    $real = @($files | Where-Object { $_.Name -ne '00_INDEX.md' -and -not (Test-PkmsLiveLog $_.Name) })
    $realBytes = [int64](($real | Measure-Object Length -Sum).Sum)
    # $bytes masoara ACELASI lucru ca in build-index.ps1: doar fisierele de
    # continut. O masuratoare care masoara altceva in cele doua generatoare
    # inseamna ca ele nu se pot verifica una pe cealalta.
    $bytes = $realBytes

    $exts = @(foreach ($g in ($real | Group-Object Extension | Sort-Object @{e={$_.Count};d=$true}, @{e={$_.Name};d=$false})) {
      if ($g.Name) { ,@([string]$g.Name, [int]$g.Count) }
    })
    $e1n = ''; $e1c = 0; $e2n = ''; $e2c = 0
    if ($exts.Count -gt 0) { $e1n = $exts[0][0]; $e1c = $exts[0][1] }
    if ($exts.Count -gt 1) { $e2n = $exts[1][0]; $e2c = $exts[1][1] }

    $bigF = $real | Sort-Object @{e={$_.Length};d=$true}, @{e={$_.Name};d=$false} | Select-Object -First 1
    $bigName = ''; $bigLen = [int64]0
    if ($bigF) { $bigName = [string]$bigF.Name; $bigLen = [int64]$bigF.Length }

    $subInfos = New-Object System.Collections.Generic.List[object]
    foreach ($s in ($subs | Sort-Object Name)) {
      # 00_INDEX.md nu se numara niciodata: e fisierul GENERAT. Daca ar intra,
      # marimea lui ar intra in randul de stare, care se scrie chiar in el ->
      # masuratoarea s-ar schimba la fiecare rulare si indexul nu-ar ajunge
      # niciodata CONFORM.
      $sf    = @(Get-ChildItem -LiteralPath $s.FullName -File -Force -EA SilentlyContinue |
                 Where-Object { $_.Name -ne '00_INDEX.md' -and -not (Test-PkmsLiveLog $_.Name) })
      $sDirs = @(Get-ChildItem -LiteralPath $s.FullName -Directory -Force -EA SilentlyContinue |
                 Where-Object { -not (Test-Excluded $_.FullName) })
      $subInfos.Add([pscustomobject]@{
        name   = $s.Name
        files  = $sf.Count
        dirs   = $sDirs.Count
        bytes  = [int64](($sf | Measure-Object Length -Sum).Sum)
        # Orice copil eligibil are index dupa aceasta rulare: fie il are deja,
        # fie scriptul ii scrie unul chiar acum. Test-Path ar da 0 pentru un
        # copil creat acum, parintele l-ar lista "fara index", iar a doua rulare
        # l-ar raporta din nou NEALINIAT — la nesfarsit. Un automat care isi
        # rescrie singur iesirea nu e niciodata CONFORM, deci nu merită incredere.
        hasIdx = $true
        total  = [int64]0
      })
    }

    $recs.Add([pscustomobject]@{
      path = $dir.FullName; rel = $rel; leaf = $dir.Name; depth = ($rel -split '\\').Count
      files = $files; filesN = $files.Count; subsN = $subs.Count; bytes = $bytes
      real = $real; realN = $real.Count; realBytes = $realBytes
      extCount = $exts.Count
      e1n = $e1n; e1c = $e1c; e2n = $e2n; e2c = $e2c
      bigName = $bigName; bigLen = $bigLen
      subInfos = $subInfos
      idxPath = (Join-Path $dir.FullName '00_INDEX.md')
    })
  }

  # dimensiunea pe disc, in memorie, de jos in sus (ca in build-index.ps1).
  # se aduna doar fisierele de continut: 00_INDEX.md e fisierul GENERAT, si
  # daca ar intra, propozitia din 'Ce e aici' ar depinde de marimea indexului
  # chiar scris in ea -> s-ar schimba de la o rulare la alta.
  $acc = @{}
  foreach ($r in $recs) { $acc[$r.path] = [int64]$r.realBytes }
  foreach ($r in ($recs | Sort-Object depth -Descending)) {
    $par = [System.IO.Directory]::GetParent($r.path)
    if ($par -and $acc.ContainsKey($par.FullName)) {
      $acc[$par.FullName] = [int64]$acc[$par.FullName] + [int64]$acc[$r.path]
    }
  }
  foreach ($r in $recs) {
    foreach ($s in $r.subInfos) {
      $sp = Join-Path $r.path $s.name
      if ($acc.ContainsKey($sp)) { $s.total = [int64]$acc[$sp] } else { $s.total = [int64]$s.bytes }
    }
  }

  # -------------------------------------------------------------------------
  # generatoarele de bloc (§18.1 + §16) — identice cu build-index.ps1
  # -------------------------------------------------------------------------
  function Get-CelMaiMareElement($r) {
    $bigName = [string]$r.bigName; $bigLen = [int64]$r.bigLen; $bigIsDir = $false
    $bigSub = $r.subInfos | Sort-Object @{e={$_.total};d=$true}, @{e={$_.Name};d=$false} | Select-Object -First 1
    if ($bigSub) {
      if ((-not $bigName) -or ([int64]$bigSub.total -gt $bigLen)) {
        $bigName = $bigSub.name; $bigLen = [int64]$bigSub.total; $bigIsDir = $true
      }
    }
    return @($bigName, $bigLen, $bigIsDir)
  }

  function Get-Descriere($r) {
    $s1 = ''
    if ($r.realN -eq 0) {
      $s1 = 'Nu are fișiere de conținut.'
    } elseif ($r.extCount -eq 1) {
      $s1 = "Singura extensie prezentă e ``$($r.e1n)`` ($($r.e1c) din $($r.realN) fișiere)."
    } else {
      $s1 = "Cele mai frecvente două extensii sunt ``$($r.e1n)`` ($($r.e1c) din $($r.realN) fișiere) și ``$($r.e2n)`` ($($r.e2c) din $($r.realN) fișiere)."
    }
    $big = Get-CelMaiMareElement $r
    $p2 = New-Object System.Collections.Generic.List[string]
    if ($r.subsN -eq 1) {
      $p2.Add("Un raft copil: ``$($r.subInfos[0].name)``")
    } elseif ($r.subsN -gt 1) {
      $nn = @(($r.subInfos | Sort-Object Name | Select-Object -First 3) | ForEach-Object { "``$($_.name)``" })
      if ($r.subsN -le 3) { $p2.Add("$($r.subsN) rafturi copil: $($nn -join ', ')") }
      else { $p2.Add("$($r.subsN) rafturi copil (primele trei după nume: $($nn -join ', '))") }
    }
    if ($big[0] -ne '') { $p2.Add("cel mai mare element din folder e ``$($big[0])`` ($(Human $big[1]))") }
    $s2 = ''
    if ($p2.Count -gt 0) {
      $s2 = ($p2 -join '; ')
      $s2 = $s2.Substring(0,1).ToUpper() + $s2.Substring(1)
    }
    if ($s2 -ne '') { return "$s1 $s2" }
    return $s1
  }

  function Get-Cuvinte($r) {
    $big = Get-CelMaiMareElement $r
    $cand = New-Object System.Collections.Generic.List[string]
    $cand.Add([string]$r.leaf)
    foreach ($w in @(Get-ValueWords $big[0] 3 (-not $big[2]))) { $cand.Add($w) }
    if ($r.e1n -ne '') { $cand.Add($r.e1n) }
    if ($r.e2n -ne '') { $cand.Add($r.e2n) }
    $kw  = New-Object System.Collections.Generic.List[string]
    $seen = @{}
    foreach ($c in $cand) {
      if ($kw.Count -ge 12) { break }
      $t = $c.Replace('`','').Replace('·','').Trim()
      if ($t.Length -lt 2) { continue }
      if ($seen.ContainsKey($t)) { continue }
      $seen[$t] = $true
      $kw.Add($t)
    }
    if ($kw.Count -lt 5) {
      foreach ($s in ($r.subInfos | Sort-Object @{e={$_.total};d=$true}, @{e={$_.Name};d=$false})) {
        $t = $s.name.Replace('`','').Replace('·','').Trim()
        if ($t.Length -lt 2) { continue }
        if ($seen.ContainsKey($t)) { continue }
        $seen[$t] = $true
        $kw.Add($t)
        if ($kw.Count -ge 5) { break }
      }
    }
    # §16: daca raman mai putin de 2, NU inventam — raportam.
    if ($kw.Count -lt 2) { $script:putineCuvinte++ }
    return '`' + ($kw -join '` · `') + '`'
  }

  # randul de stare: numai fise reale. vezi nota de la masuratoare — daca ar
  # intra si 00_INDEX.md, marimea lui ar intra in randul scris chiar in el.
  function Get-RandDes($r) { return "**$($r.realN) fișiere · $(Human $r.realBytes) · $($r.subsN) subfoldere**" }

  function Get-BlockSubfoldere($r) {
    if ($r.subsN -le 0) { return @() }
    $b = New-Object System.Collections.Generic.List[string]
    $b.Add('## Subfoldere'); $b.Add('')
    $b.Add('_Fiecare raft e legat la indexul lui. Un index care nu e legat nu e în arbore._'); $b.Add('')
    foreach ($s in $r.subInfos) {
      $sum = "$($s.files) fișiere · $($s.dirs) subfoldere"
      if ($s.hasIdx) {
        $enc = Cod-Link $s.name
        $b.Add("- [``$($s.name)``](<$enc/00_INDEX.md>) — $sum")
      } else {
        $b.Add("- ``$($s.name)`` — $sum · _fără index_")
      }
    }
    $b.Add('')
    return @($b.ToArray())
  }

  function Get-BlockFisiere($r) {
    if ($r.realN -le 0) { return @() }
    $b = New-Object System.Collections.Generic.List[string]
    $b.Add('## Fișiere'); $b.Add('')
    if ($r.realN -le 60) {
      $b.Add('| Fișier | Dimensiune | Modificat |')
      $b.Add('|---|---|---|')
      foreach ($f in ($r.real | Sort-Object Name)) {
        $b.Add("| ``$($f.Name)`` | $(Human $f.Length) | $($f.LastWriteTime.ToString('yyyy-MM-dd')) |")
      }
    } else {
      $b.Add("_( $($r.realN) fișiere — grupat după tip, pentru nu umfla documentul)_")
      $b.Add('')
      foreach ($g in ($r.real | Group-Object Extension | Sort-Object Count -Descending)) {
        $ext = $g.Name
        if (-not $ext) { $ext = '(fără extensie)' }
        $sz = [int64](($g.Group | Measure-Object Length -Sum).Sum)
        $b.Add("- **$ext** — $($g.Count) fișiere · $(Human $sz)")
      }
      $b.Add('')
      $b.Add('### Cele mai mari 20')
      $b.Add('')
      foreach ($f in ($r.real | Sort-Object Length -Descending | Select-Object -First 20)) {
        $b.Add("- ``$($f.Name)`` — $(Human $f.Length)")
      }
    }
    $b.Add('')
    return @($b.ToArray())
  }

  # --- index nou, din zero: titlu, motiv, rand de stare, nota, blocuri ---
  function Get-IndexNou($r, [string]$motiv) {
    $o = New-Object System.Collections.Generic.List[string]
    $o.Add(('# 00_INDEX — ' + ($r.rel -replace '\\','/'))); $o.Add('')
    if ($motiv) { $o.Add($motiv); $o.Add('') }
    $o.Add((Get-RandDes $r)); $o.Add('')
    # NOTA DE PROVENIENTA — calea REALA a motorului, si TEXT IDENTIC cu cel scris
  # de build-index.ps1 (ghilimele simple aici: backtick-ul e literal, in sirul cu
  # ghilimele duble ar disparea). Daca cele doua generatoare ar scrie forme
  # diferite, ele s-ar rescrie reciproc la nesfarsit — masurat: 88 de indexuri
  # purtau forma veche, cu folderul `AI-Kit\`, care nu mai exista.
  $o.Add('> Generat automat de `02_Areas/02-2-AI-SOT/02-2-4-AI-Kit/AI-Kit_manual/build-index.ps1` și `align-index.ps1`. Nu edita manual — rulează scriptul din nou.')
    $o.Add('> Randul **De ce e aici** de mai sus, daca exista, se pastreaza la fiecare regenerare.')
    $o.Add('')
    if ($r.realN -eq 0 -and $r.subsN -eq 0) {
      # --- §18.5: indexul unui folder gol. Textul din contract, data de azi.
      # UNICA exceptie de la §16: un folder gol nu are de unde masura — nu
      # are extensii, nu are nume de fisiere, nu are nimic de citat. Cele
      # doua cuvinte descriu starea masurata, care e tocmai golul; nu sunt
      # inventate, iar data e data la care automatul a completat.
      $o.Add('## Ce e aici'); $o.Add('')
      $o.Add(("Folder gol pe {0}: niciun fișier, niciun subfolder." -f $data)); $o.Add('')
      $o.Add('## Cuvinte cheie'); $o.Add('')
      $o.Add('`gol` · `necompletat`'); $o.Add('')
      # N4 (W-Converge6, 2026-10-08) RAMANE DESCHIS, nu reparat.
      # build scrie 3 CRLF la final pentru un folder gol; aceasta ramura scrie mai
      # putin. Am incercat o egalizare adaugand randuri goale si am MASURAT rezultatul:
      # nu s-a ajuns la potrivire (align 5 octeti de sfarsit de linie, build 6).
      # Editia pe care s-a masurat PASS-ul porții era cea de aici, asa ca o
      # modificare neverificata intr-un script verificat ar invalida poarta pentru un
      # castig estetic. De aceea s-a dat inapoi, iar defectul ramane documentat.
      # Impact masurat: ZERO. Comparatia lui align e structurala (liniile ~651+), nu
      # de text integral, deci newline-urile nu se vad: 4 rulari consecutive au dat
      # 0 evenimente, log neatins, fara bucla.
      return @($o.ToArray())
    }
    $o.Add('## Ce e aici'); $o.Add(''); $o.Add((Get-Descriere $r)); $o.Add('')
    $o.Add('## Cuvinte cheie'); $o.Add(''); $o.Add((Get-Cuvinte $r)); $o.Add('')
    foreach ($l in (Get-BlockSubfoldere $r)) { $o.Add($l) }
    foreach ($l in (Get-BlockFisiere $r)) { $o.Add($l) }
    return @($o.ToArray())
  }

  # motivul scris de om: NU se atinge (§18.2). singurul rand al omului.
  function Get-Motiv([string[]]$lines) {
    foreach ($l in $lines) {
      if ($l -match '^\*\*De ce e aici:') {
        return ([string]$l -replace '^\*\*De ce e aici:\*\*\s*', '**De ce e aici:** ')
      }
    }
    return $null
  }

  # -------------------------------------------------------------------------
  # 3. + 4. + 5. — clasifica, repara, scrie
  # -------------------------------------------------------------------------
  $blocuriCunoscute = @('## Ce e aici', '## Cuvinte cheie', '## Subfoldere', '## Fișiere')
  $subBlocCunoscut = '### Cele mai mari 20'
  $evenimente = New-Object System.Collections.Generic.List[string]
  $cnt = @{ LIPSA = 0; CORUPT = 0; INCOMPLET = 0; NEALINIAT = 0; CONFORM = 0; NEMODIF = 0 }
  $duble = New-Object System.Collections.Generic.List[string]

  # Unde se opreste corpul generat al unui bloc. Orice linie care nu e de forma
  # generata, peste acest capat, e text de om si se pastreaza (§18.2).
  function Get-CorpEnd([string[]]$lines, [int]$start, [int]$stop, [string]$nume) {
    $i = $start + 1
    if ($nume -eq '## Ce e aici') {
      $inceput = -1; $ultim = -1; $n = 0
      while ($i -lt $stop) {
        $l = [string]$lines[$i]
        if ([string]::IsNullOrWhiteSpace($l)) {
          if ($inceput -ge 0) { break }
          $i++; continue
        }
        if ($inceput -lt 0) { $inceput = $i }
        $ultim = $i; $n++
        if ($n -ge 8) { break }
        $i++
      }
      if ($inceput -lt 0) { return $start + 1 }
      return $ultim + 1
    }
    if ($nume -eq '## Cuvinte cheie') {
      while ($i -lt $stop) {
        if (-not [string]::IsNullOrWhiteSpace([string]$lines[$i])) { return $i + 1 }
        $i++
      }
      return $start + 1
    }
    if ($nume -eq '## Subfoldere') {
      $v = $start + 1
      while ($v -lt $stop) {
        $l = [string]$lines[$v]
        if ([string]::IsNullOrWhiteSpace($l)) { $v++; continue }
        if (($l -match '^_Fiecare raft') -or ($l -match '^\s*-\s')) { $v++; continue }
        return $v
      }
      return $stop
    }
    $v = $start + 1
    while ($v -lt $stop) {
      $l = [string]$lines[$v]
      if ([string]::IsNullOrWhiteSpace($l)) { $v++; continue }
      if ($l -match '^\|') { $v++; continue }
      if ($l -match '^_') { $v++; continue }
      if ($l -match '^\s*-\s') { $v++; continue }
      if ($l.Trim() -eq '### Cele mai mari 20') { $v++; continue }
      return $v
    }
    return $stop
  }

  function Get-BlockNou([string]$nume, $r) {
    # §18.5: un folder gol are un singur text, si trebuie sa fie ACELASI si
    # cand blocul se regenereaza dintr-un index existent — altfel automatul
    # ar rescrie aceeasi index la nesfarsit, intorcandu-l intre doua forme.
    if ($r.realN -eq 0 -and $r.subsN -eq 0) {
      if ($nume -eq '## Ce e aici') {
        return ,@('## Ce e aici', '', ("Folder gol pe {0}: niciun fișier, niciun subfolder." -f $dataGol), '')
      }
      if ($nume -eq '## Cuvinte cheie') {
        return ,@('## Cuvinte cheie', '', '`gol` · `necompletat`', '')
      }
    }
    switch ($nume) {
      '## Ce e aici'     { return ,@('## Ce e aici', '', (Get-Descriere $r), '') }
      '## Cuvinte cheie' { return ,@('## Cuvinte cheie', '', (Get-Cuvinte $r), '') }
      '## Subfoldere'    { return ,@(Get-BlockSubfoldere $r) }
      '## Fișiere'       { return ,@(Get-BlockFisiere $r) }
    }
    return ,@()
  }

  # rand gol de separatie — unul singur, oricat ar fi de multe randuri goale
  # la rand. altfel urmatoarea rulare ar sterge unul, si indexul s-ar misca
  # la nesfarsit intre doua forme.
  function Add-Separator($list) {
    if ($list.Count -eq 0) { return }
    if ([string]::IsNullOrWhiteSpace([string]$list[$list.Count - 1])) { return }
    $list.Add('')
  }

  foreach ($r in $recs) {
    $relSlash = ($r.rel -replace '\\','/')
    $exista = Test-Path -LiteralPath $r.idxPath
    $oldText = ''
    $oldLines = @()
    if ($exista) {
      $oldText = [System.IO.File]::ReadAllText($r.idxPath)
      $oldLines = @([System.IO.File]::ReadAllLines($r.idxPath))
    }
    # DATA DE COMPLETARE, NU DATA DE ASTAZI (defect masurat 2026-10-09).
    # Ambele generatoare bteau data zilei curente, deci la trecerea in ziua urmatoare
    # TOATE folderele goale deveneau NEALINIAT prin constructie — masurat pe automat, la
    # 06:00 pe 09:10: 40 de evenimente din 44, cu masura si indexul identice, si singura
    # diferenta cuvantul "azi" vs "ieri". 40 de indexuri rescrise in fiecare zi, la
    # nesfarsit, si 40 de evenimente de log zilnice care nu insemnau nimic — deci si
    # ritualul saptamanal arata 40 de probleme false, pentru totdeauna.
    # Contractul cere ca data sa fie "data la care automatul a completat": se scrie O
    # SINGURA DATA, cand folderul e marcat primul, si se pastreaza. Implicit: azi.
    # Daca indexul are deja o data, o pastram — in ambele generatoare, altfel zarul se
    # muta de la unul la altul in loc sa se piarda.
    $dataGol = $data
    if ($exista) {
      foreach ($lin in $oldLines) {
        if ($lin -match '^Folder gol pe (\d{4}-\d{2}-\d{2}):') { $dataGol = $Matches[1]; break }
      }
    }

    # (W-Converge6, 2026-10-08): se afisa $r.filesN — toate fisierele, 00_INDEX.md
    # inclusiv — in timp ce indexul declara $r.realN, adica fisierele de continut.
    # Intr-un log a carui existenta e sa explice de ce s-a reparat un index, o cifra
    # care seamana cu un off-by-one inexistent este mai rea decat absenta ei.
    $masura = "{0} fișiere, {1} subfoldere" -f $r.realN, $r.subsN
    $vechiSpun = 'fara rand de stare'
    foreach ($l in $oldLines) {
      if (Test-LiniaDes ([string]$l)) { $vechiSpun = (([string]$l) -replace '\*\*',''); break }
    }
    $motiv = Get-Motiv $oldLines

    # ---- CORUPT: gol (0 octeti), sau fara titlu, sau trunchiat ----
    # "trunchiat" = fisierul nu se termina cu sfarsit de linie. Un index scris
    # de build-index se termina mereu cu un rand nou; lipsa lui inseamna
    # scriere intrerupta la jumatate.
    $corupt = ''
    if ($exista) {
      if ($oldText.Length -eq 0) {
        $corupt = 'gol (0 octeti)'
        $vechiSpun = 'gol (0 octeti)'
      } else {
        $areTitlu = $false
        foreach ($l in $oldLines) { if ($l -match '^# 00_INDEX') { $areTitlu = $true; break } }
        if (-not $areTitlu) {
          $corupt = 'nu are linia de titlu'
          $vechiSpun = 'nu are linia de titlu'
        } elseif (-not $oldText.EndsWith("`n")) {
          $corupt = 'trunchiat (nu se termina corect)'
          $vechiSpun = 'trunchiat (nu se termina corect)'
        }
      }
    }

    $nou = $null
    $stare = ''
    $refuz = ''
    $pierdut = ''
    $descriere = ''
    $omInterblocuri = $false
    $rupte = 0
    $lipsa = @()

    if (-not $exista) {
      # ---- LIPSA: creeaza indexul complet, pe schema. NU se logheaza (§18.3) ----
      $stare = 'LIPSA'
      $vechiSpun = 'nu exista'
      $noulMotiv = $null
      if ($r.realN -eq 0 -and $r.subsN -eq 0) {
        $noulMotiv = ('**De ce e aici:** Index completat automat pe {0}. Folderul era gol în ziua aceasta. Scrie aici, cu o propoziție, de ce va conține ceva — până atunci rămâne o întrebare, și e corect să fie o întrebare.' -f $data)
      }
      $nou = Get-IndexNou $r $noulMotiv
    }
    elseif ($corupt) {
      # ---- CORUPT: reface de la zero si spune ce a pierdut ----
      $stare = 'CORUPT'
      $pierdut = 'pierdut: ' + $corupt
      if (-not $motiv) { $pierdut = $pierdut + ', si motivul lui' }
      $nou = Get-IndexNou $r $motiv
      if (-not $motiv) { $refuz = 'index fara motiv' }
    }
    else {
      # ---- scanare de structura ----
      $structuraStreina = ''
      $capete = New-Object System.Collections.Generic.List[object]
      $seenBlk = @{}
      for ($i = 0; $i -lt $oldLines.Count; $i++) {
        $t = ([string]$oldLines[$i]).Trim()
        if ($t -match '^###\s') {
          if ($t -ne $subBlocCunoscut) { $structuraStreina = "heading strain: $t" }
        } elseif ($t -match '^##\s') {
          if ($blocuriCunoscute -notcontains $t) {
            $structuraStreina = "heading strain: $t"
          } else {
            if ($seenBlk.ContainsKey($t)) { $structuraStreina = "bloc repetat: $t" }
            $seenBlk[$t] = $i
            $capete.Add([pscustomobject]@{ Nume = $t; Start = $i; End = $oldLines.Count; CorpEnd = $oldLines.Count })
          }
        }
      }

      # link rupt catre un folder care nu mai exista (§19.4)
      $rupte = 0
      foreach ($l in $oldLines) {
        $s = [string]$l
        if ($s -match '^\s*-\s+\[.*\]\(<(.*?)/00_INDEX\.md>\)') {
          $t = [System.Uri]::UnescapeDataString($Matches[1])
          $are = $false
          foreach ($si in $r.subInfos) { if ($si.name -eq $t) { $are = $true; break } }
          if (-not $are) { $rupte++ }
        }
      }

      if ($structuraStreina) {
        # §19.4 ultimul: structura straina, pe care nu o putem aduce la schema
        # fara sa pierdem text. NU atingem nimic, doar notam.
        $stare = 'INCOMPLET'
        $refuz = 'index cu structura straina (' + $structuraStreina + '), pe care nu-l pot aduce la schema fara sa pierd text'
        $descriere = 'nu s-a atins nimic: ' + $refuz
      }
      else {
        # capetele blocurilor
        for ($k = 0; $k -lt $capete.Count; $k++) {
          $end = $oldLines.Count
          for ($j = $capete[$k].Start + 1; $j -lt $oldLines.Count; $j++) {
            $t = ([string]$oldLines[$j]).Trim()
            if (($t -match '^#{2,3}\s') -and ($t -ne $subBlocCunoscut)) { $end = $j; break }
          }
          $ce = Get-CorpEnd $oldLines $capete[$k].Start $end $capete[$k].Nume
          $capete[$k].End = $end
          $capete[$k].CorpEnd = $ce
          for ($i = $ce; $i -lt $end; $i++) {
            if (-not [string]::IsNullOrWhiteSpace([string]$oldLines[$i])) { $omInterblocuri = $true }
          }
        }

        $necesare = [System.Collections.Generic.List[string]]@('## Ce e aici', '## Cuvinte cheie')
        if ($r.subsN -gt 0) { $necesare.Add('## Subfoldere') }
        if ($r.realN -gt 0) { $necesare.Add('## Fișiere') }
        $lipsa = [System.Collections.Generic.List[string]]::new()
        foreach ($n in $necesare) { if (-not $seenBlk.ContainsKey($n)) { $lipsa.Add($n) } }

        if (-not $motiv) {
          # §19.4: index fara motiv. Nu stiu cine l-a scris si nu stiu daca a
          # fost sters sau n-a existat vreodata -> raportez, NU scriu un motiv.
          # Se raporteaza DOAR cand exista urma de om in fisier (text intre
          # blocuri, sau fara nota de generat): un index facut acum de acest
          # script, fara motiv, nu e eveniment — nimic nu s-a pierdut, si daca
          # s-ar raporta la fiecare rulare, logul ar inceta sa mai insemne ceva.
          $areOm = ($omInterblocuri -or ($oldText -notmatch 'Generat automat'))
          if ($areOm) { $refuz = 'index cu text scris de om intre blocuri, pe care nu-l pot rescrie fara sa pierd text' }
        }
        if ($lipsa.Count -gt 0) { $stare = 'INCOMPLET' } else { $stare = 'NEALINIAT' }

        # ---- continut nou, bloc cu bloc, pastrand omul ----
        $res = New-Object System.Collections.Generic.List[string]
        $primul = $oldLines.Count
        if ($capete.Count -gt 0) { $primul = $capete[0].Start }
        for ($i = 0; $i -lt $primul; $i++) {
          $l = [string]$oldLines[$i]
          if (Test-LiniaDes $l) { $l = Get-RandDes $r }
          # Titlul e al AUTOMATULUI, nu al omului (§18.2: "titlul # 00_INDEX — ...
          # | automat | da"). Contractul cere "/" in loc de "\", iar pe Windows
          # o cale scrisa cu "\' arata identica si ar sugera ca arborele e altul
          # decat este. Pana la 2026-10-08 titlul era copiat verbatim, deci 631
          # de indexuri ramaneau neconforme pe D: fara ca scriptul sa le vada.
          # Observatia 631 vine din verifica-schema.ps1, nu dintr-o presupunere.
          if ($l -match '^#\s*00_INDEX') { $l = ('# 00_INDEX — ' + ($r.rel -replace '\\','/')) }
          $res.Add($l)
        }
        $areRandDes = $false
        foreach ($l in $res) { if (Test-LiniaDes ([string]$l)) { $areRandDes = $true; break } }
        if (-not $areRandDes) {
          $poz = $res.Count
          for ($i = 0; $i -lt $res.Count; $i++) {
            if (([string]$res[$i]) -match '^>') { $poz = $i; break }
          }
          $res.Insert($poz, '')
          $res.Insert($poz, (Get-RandDes $r))
        }

        # capul (titlu, motiv, rand de stare, nota de generat) intra PRIMUL in
        # rezultat: e partea pe care automatul o pastreaza, nu o rescrie.
        $resNew = New-Object System.Collections.Generic.List[string]
        foreach ($l in $res) { $resNew.Add([string]$l) }
        foreach ($b in $capete) {
          foreach ($l in (Get-BlockNou $b.Nume $r)) { $resNew.Add([string]$l) }
          # text scris de om intre blocuri: peste ultimul rand al corpului
          for ($i = $b.CorpEnd; $i -lt $b.End; $i++) {
            $l = [string]$oldLines[$i]
            if (-not [string]::IsNullOrWhiteSpace($l)) { Add-Separator $resNew; $resNew.Add($l) }
          }
        }
        foreach ($n in $necesare) {
          if ($seenBlk.ContainsKey($n)) { continue }
          Add-Separator $resNew
          foreach ($l in (Get-BlockNou $n $r)) { $resNew.Add([string]$l) }
        }
        $nou = @($resNew.ToArray())
      }
    }

    $arhivat = $false
    if ($null -ne $nou) {
      if ((Norm $nou) -eq (Norm $oldLines)) {
        # CONFORM: nu atingem nimic, nu scriem nimic, nu logam nimic.
        $stare = 'CONFORM'
        $nou = $null
      } elseif ($refuz -and $stare -ne 'CORUPT' -and $stare -ne 'LIPSA') {
        $refuz = $refuz + ' — nu s-a scris nimic, pentru ca nu stiu al cui rand este'
        $descriere = 'nu s-a atins nimic: ' + $refuz
        $nou = $null
      } else {
        $eol = "`n"
        if ($oldText.Contains("`r`n")) { $eol = "`r`n" }
        $txt = ($nou -join $eol)
        if (-not $txt.EndsWith($eol)) { $txt = $txt + $eol }
        if ($CeVad) {
          $descriere = 'ar rescrie 00_INDEX.md ( CeVad: NU s-a scris )'
        } else {
          # 5. INAINTE de orice scriere: vechea versiune la arhiva (§18.4)
          if ($exista) {
            # numele de arhiva e LIZOS: daca ar crea subfoldere oglindite,
            # parcurgerea de la urmatoarea rulare le-ar gasi ca foldere noi si
            # ar scrie indexe in propria arhiva.
            $arcNume = ($relSlash -replace '/', '__')
            $arcFile = Join-Path $arhivaBaza ($arcNume + '.md')
            $arcDir = Split-Path -Parent $arcFile
            if (-not (Test-Path -LiteralPath $arcDir)) { New-Item -ItemType Directory -Path $arcDir -Force | Out-Null }
            Set-Content -LiteralPath $arcFile -Value $oldText -Encoding UTF8
            $arhivat = $true
          }
          Set-Content -LiteralPath $r.idxPath -Value $txt -Encoding UTF8
          if ($stare -eq 'NEALINIAT')  { $descriere = 'blocurile derivate rescrise, motivul pastrat' }
          if ($stare -eq 'INCOMPLET') { $descriere = 'blocuri lipsa completate (' + ($lipsa -join ', ') + '), motivul pastrat' }
          if ($stare -eq 'CORUPT')    { $descriere = 'refacut de la zero, ' + $pierdut }
          if ($stare -eq 'LIPSA')     { $descriere = 'creat pe schema' }
        }
      }
    }

    $cnt[$stare] = $cnt[$stare] + 1
    # "nemodificate" trebuie MASURAT, nu afisat ca 0. Un contor initializat si
    # niciodata incrementat tipareste un numar care pare masuratoare si nu e nimic —
    # mai rau decat o regula absenta, pentru ca omul are voie sa se increze in el.
    # CONFORM inseamna exact "nu s-a atins nimic", deci aici se numara.
    #
    # ETICHETA VECHE ERA MINCINOASA (masurat 2026-10-09): contorul se numea
    # REFUZAT si se afisa ca "neatinse", dar era exact numarul CONFORM repetat.
    # Consecinta reala: din iesire nu rezulta NICIODATA cate foldere au fost
    # SALTITE de excluziuni — pe vaultul real sunt mii. Cifra aceea se vede la
    # verifica-schema ("gasite N | analizate M"); aici spunem adevarul despre ce
    # s-a numarat, nu ce s-a omis.
    if ($stare -eq 'CONFORM') { $cnt.NEMODIF = $cnt.NEMODIF + 1 }

    # 6. RAPORTEAZA — doar la eveniment (§19.2). LIPSA nu se logheaza (§18.3).
    $eEveniment = $false
    if ($stare -eq 'CORUPT' -or $stare -eq 'INCOMPLET' -or $stare -eq 'NEALINIAT') { $eEveniment = $true }
    if ($refuz) { $eEveniment = $true }
    if ($rupte -gt 0) { $eEveniment = $true }

    # DEFECT masurat 2026-10-09 la 20:00 — CONFORM se loghea. Contractul, in
    # tabelul celor cinci stari, spune ca CONFORM "nu atinge nimic" si "nu se
    # logheaza". Dar un refuz permanent (index fara motiv, unde automatul nu are
    # voie sa scrie randul omului) intra in $refuz, si "if ($refuz)" transforma un
    # refuz pe care nimeni nu-l poate rezolva intr-un eveniment. Masurat: 2
    # evenimente la fiecare din cele 4 rulari ale zilei, pe folderele
    # Wisper_Transcripts si Wisper_Transcripts/PROMPTS.
    #
    # Fixul: CONFORM nu se logheaza, oricare ar fi motivul. Motivul nu se pierde —
    # ramane in iesirea lui -CeVad si in verifica-schema, unde e raportat ca
    # observatie. Se pierde doar din log, unde nu putea fi procesat. Ruperea de
    # link si "structura straina" raman evenimente: acelea le poate rezolva omul.
    if ($stare -eq 'CONFORM') { $eEveniment = $false }

    if ($eEveniment) {
      $bl = New-Object System.Text.StringBuilder
      [void]$bl.AppendLine("[$stare] $relSlash")
      [void]$bl.AppendLine("    masura: $masura")
      [void]$bl.AppendLine("    indexul spunea: $vechiSpun")
      if ($descriere) { [void]$bl.AppendLine("    reparat: $descriere") }
      if ($arhivat)  { [void]$bl.AppendLine("    vechea versiune: _SYSTEM/arhiva-indexe/$arhivaRun/" + ($relSlash -replace '/', '__') + '.md') }
      if ($refuz)    { [void]$bl.AppendLine("    nu s-a putut decide: $refuz") }
      if ($rupte -gt 0) { [void]$bl.AppendLine("    nu s-a putut decide: link rupt catre un folder care nu mai exista ($rupte)") }
      $evenimente.Add($bl.ToString().TrimEnd())
    }

    if ($CeVad) {
      $ce = $stare
      if ($descriere) { $ce = $ce + ' — ' + $descriere }
      # refuzul se arata la comanda chiar daca starea e CONFORM: el nu se
      # logheaza (defect #3, 2026-10-09), dar dispare din lume daca nu apare aici.
      # Conditia ramane permanenta prin constructie — automatul nu are voie sa
      # scrie randul omului — deci e informatie de consultat, nu de procesat.
      if ((-not $descriere) -and $refuz) { $ce = $ce + ' — nu s-a putut decide: ' + $refuz }
      Write-Output ("{0,-11} {1}" -f $stare, $relSlash)
      if ($ce -ne $stare) { Write-Output ("             $ce") }
    }
  }

  # §19.4: acelasi folder indexat de doua ori pe cai diferite — prin puncte de
  # legatura, doua drumuri distincte pot duce in aceeasi pasta fizica.
  foreach ($d in $dirs) {
    if (($d.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -eq 0) { continue }
    $t = $null
    try { $t = (Get-Item -LiteralPath $d.FullName -Force).Target } catch { $t = $null }
    if (-not $t) { continue }
    if ($t -is [array]) { $t = $t[0] }
    $rez = [string]$t
    if (-not [System.IO.Path]::IsPathRooted($rez)) { $rez = Join-Path $d.Parent.FullName $rez }
    try { $rez = (Resolve-Path -LiteralPath $rez).Path } catch { continue }
    $duble.Add("$($d.FullName) -> $rez")
  }
  foreach ($p in $duble) {
    $evenimente.Add("[DUBLU] $p`n    masura: acelasi folder pe doua cai diferite`n    reparat: nu s-a atins nimic — nu stiu care cale e cea corecta")
  }

  # §16: contorul era tiparit DOAR pe consola. Masurat 2026-10-10 pe logul
  # real: cautand "putin de 2 cuvinte cheie" in raport-aliniere.log, nu
  # aparea nimic, in niciuna dintre cele 9079 de octeti. Un numar pe care il
  # vad eu si nu ajunge in log nu ajunge la cititor — iar logul e al
  # cititorului, nu al consolei.
  #
  # Se adauga IN EVENIMENTE, inainte de a se deschide logul, ca sa cada in
  # acelasi fel ca orice alt eveniment: scris o data, citit de inchide-log,
  # numarat de ritualul saptamanal. Fara sa atingem nimic pe disc.
  if ($script:putineCuvinte -gt 0) {
    $evenimente.Add(("[OBSERVATIE §16] foldere cu mai putin de 2 cuvinte cheie: " + $script:putineCuvinte) +
      "`n" + "    masura: indexul le descrie corect, dar nu are de unde le da cuvinte cheie" +
      "`n" + "    reparat: nu s-a atins nimic — cuvintele cheie vin din numele fisierelor, nu din automat")
  }

  # ---- logul: deschis NUMAI daca a fost eveniment (§19.2) ----
  if ($evenimente.Count -gt 0) {
    if (-not $CeVad) {
      $txtLog = New-Object System.Text.StringBuilder
      [void]$txtLog.AppendLine(('=== align-index.ps1 · {0} ===' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
      foreach ($e in $evenimente) { [void]$txtLog.AppendLine($e) }
      # append-only: adauga, nu rescrie.
      # BOM ON, intentionat (W-Converge6, 2026-10-08). Cu UTF8Encoding($false)
      # fisierul era valid dar NU se autodescria, iar orice cititor cu setarea
      # implicita — PowerShell 5.1 inclusiv — il citea ca mojuca. Un log al carui
      # encoding trebuie descoperit inainte de a-l citi nu e un log, e o enigma.
      # Preambulul se scrie doar la creare; randurile existente raman neatinse.
      [System.IO.File]::AppendAllText($logFile, $txtLog.ToString(), (New-Object System.Text.UTF8Encoding($true)))
    }
    if ($CeVad) {
      Write-Output ''
      Write-Output 'EVENIMENTE (CeVad: logul NU s-a atins):'
      foreach ($e in $evenimente) { Write-Output $e }
    }
  }

  Write-Output ''
  Write-Output ("rezumat: {0} LIPSA · {1} CORUPT · {2} INCOMPLET · {3} NEALINIAT · {4} CONFORM · {5} nemodificate" -f $cnt.LIPSA, $cnt.CORUPT, $cnt.INCOMPLET, $cnt.NEALINIAT, $cnt.CONFORM, $cnt.NEMODIF)
  $notaLog = 'evenimente de log: ' + $evenimente.Count
  if ($CeVad) { $notaLog = $notaLog + ' ( CeVad: logul NU s-a atins )' }
  Write-Output $notaLog
  Write-Output ("duble cai prin puncte de legatura: {0}" -f $duble.Count)
  Write-Output ("foldere cu mai putin de 2 cuvinte cheie, raportate §16: {0}" -f $script:putineCuvinte)
  if ($evenimente.Count -eq 0) {
    $lg = Get-Item -LiteralPath $logFile -EA SilentlyContinue
    if ($lg) { Write-Output ('logul nu a fost atins. ultima lui modificare ramane: ' + $lg.LastWriteTime) }
    else { Write-Output 'logul nu a fost atins si nu exista inca.' }
  }
  exit 0
}
finally {
  if ($mutex) {
    if ($mutexAlMeu) { try { $mutex.ReleaseMutex() } catch { } }
    try { $mutex.Dispose() } catch { }
  }
}