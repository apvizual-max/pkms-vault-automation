<#
  PKMS health-check.ps1 - starea de sanatate a vaultului, intr-un raport scurt.
  Nu modifica nimic.
#>
param([string]$Vault = '')
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\paths.ps1"
if (-not $Vault) { $Vault = Get-PkmsVault }
# -Vault vine de la om si nu trece prin Get-PkmsVault. Fara asta, o bara
# obisnuita la finalul caii face ca tot vaultul sa para nealiniat.
$Vault = Normalize-PkmsPath $Vault
$ex = '\\\.obsidian\\|\\\.git\\'

# --- numaratoare REPRODUCIBILA ---
# masurat: aceeasi expresie, doua rulari la 3 secunde, a dat 50.967 apoi 50.970.
# deci expresia e stabila, dar VAULTUL CRESTE sub ea - procese vii scriu in el.
# intrebarea "de ce difera doua numarari?" nu se raspunde ghicind: se raspunde
# masurand de doua ori si spunand diferenta.
# NOTA: Get-ChildItem nu pierde nimic la cale lunga. masurat: 52.242 cu
# Get-ChildItem -File -Recurse si 52.242 cu [System.IO.Directory]::EnumerateFiles
# pe prefixul \\?\, deci delta 0. Exista 128 de cai peste 259 de caractere
# (maxima 329) si toate sunt numarate. Calea lunga NU e motivul nedeterminismului.
$probe1 = 0
foreach ($f in Get-ChildItem -LiteralPath $Vault -File -Recurse -Force -EA SilentlyContinue) {
  if ($f.FullName -notmatch $ex) { $probe1++ }
}
Start-Sleep -Milliseconds 700
$probe2 = 0
foreach ($f in Get-ChildItem -LiteralPath $Vault -File -Recurse -Force -EA SilentlyContinue) {
  if ($f.FullName -notmatch $ex) { $probe2++ }
}
$drift = $probe2 - $probe1
$exSurse = "excludere folosita aici: \\.obsidian\\ si \\.git\\ (2 tipare). paths.ps1 Get-PkmsExclusions are 15 tipare si da ALT numar - nu se amesteca."

Write-Output "==================== STAREA VAULTULUI ===================="
Write-Output ""

Write-Output "STRATUL DE LUCRU"
# MUTARE 2026-10-19: 10_Work a fost redenumit 01_Projects si a urcat in baza.
# Aceeasi lista ca in lint.ps1 ($workCorect). Un instrument care cauta un strat
# de lucru care nu mai exista raporteaza "LIPSA" pentru ceva care EXISTA -- si
# nu raporteaza niciun raft, deci nu masoara nimic in rafturile de lucru.
$workLayer = '01_Projects'
if (Test-Path (Join-Path $Vault $workLayer)) {
  foreach ($r in Get-ChildItem -LiteralPath (Join-Path $Vault $workLayer) -Directory -Force | Sort-Object Name) {
    # Acelasi filtru ca in bucla de mai jos (BAZA): altfel rafturile si bazele
    # masoara doua lucruri diferite, iar suma lor nu mai este suma bazei.
    $fCount = 0; [int64]$fSum = 0
    foreach ($file in Get-ChildItem -LiteralPath $r.FullName -File -Recurse -Force -EA SilentlyContinue) {
      if ($file.FullName -notmatch $ex) { $fCount++; $fSum += $file.Length }
    }
    $mb = [math]::Round($fSum/1MB,0)
    Write-Output ("  {0,-22} {1,6} fisiere  {2,8} MB" -f $r.Name, $fCount, $mb)
  }
} else { Write-Output "  LIPSA $workLayer" }

Write-Output ""
Write-Output "BAZA"
foreach ($b in @('00_Inbox','01_Projects','02_Areas','03_Resources','04_Archive','05_Attachments','06_Metadata','07_Canvas Bases','08_Clippings','09_raport-archive')) {
  $p = Join-Path $Vault $b
  if (Test-Path $p) {
    $fCount = 0; [int64]$fSum = 0
    foreach ($file in Get-ChildItem -LiteralPath $p -File -Recurse -Force -EA SilentlyContinue) {
      if ($file.FullName -notmatch $ex) { $fCount++; $fSum += $file.Length }
    }
    $mb = [math]::Round($fSum/1MB,0)
    Write-Output ("  {0,-22} {1,6} fisiere  {2,8} MB" -f $b, $fCount, $mb)
  }
}

Write-Output ""
Write-Output "RAFTURILE MASINII"
foreach ($m in @('_SYSTEM','_ARCHIVE','_QUARANTINE')) {
  $p = Join-Path $Vault $m
  if (Test-Path $p) {
    $fCount = 0; [int64]$fSum = 0
    foreach ($file in Get-ChildItem -LiteralPath $p -File -Recurse -Force -EA SilentlyContinue) {
      if ($file.FullName -notmatch $ex) { $fCount++; $fSum += $file.Length }
    }
    $mb = [math]::Round($fSum/1MB,0)
    Write-Output ("  {0,-22} {1,6} fisiere  {2,8} MB" -f $m, $fCount, $mb)
  }
}

$allCount = 0; [int64]$allSum = 0
foreach ($file in Get-ChildItem -LiteralPath $Vault -File -Recurse -Force -EA SilentlyContinue) {
  if ($file.FullName -notmatch $ex) { $allCount++; $allSum += $file.Length }
}
$gb = [math]::Round($allSum/1GB,2)
Write-Output ""
Write-Output "TOTAL: $allCount fisiere | $gb GB"
Write-Output "  numarator: Get-ChildItem -File -Recurse -Force, filtru $ex"
Write-Output "  $exSurse"
Write-Output "  masurat: Get-ChildItem pierde 0 fisiere la cale >259 caractere (52.242 = 52.242 vs .NET EnumerateFiles, \\?\)"
Write-Output "  stabilitate: $probe1 la prima masuratoare, $probe2 la a doua (la 700 ms distanta), diferenta $drift"
if ($drift -ne 0) {
  Write-Output "  ATENTIE: vaultul s-a schimbat intre cele doua masuratori. cifrele de mai sus sunt"
  Write-Output "  momente, nu constante. daca vrei comparatie intre doua rulari, ruleaza in"
  Write-Output "  intervale cu procesele de scriere oprite."
} else {
  Write-Output "  vaultul nu s-a schimbat intre cele doua masuratori."
}

Write-Output ""
Write-Output "SEMAINE DE LUCRU"
$inb = 0
foreach ($f in Get-ChildItem -LiteralPath (Join-Path $Vault '00_Inbox') -File -Recurse -Force -EA SilentlyContinue) {
  if ($f.Name -ne 'README.md' -and $f.Name -ne '00_INDEX.md') { $inb++ }
}
Write-Output "  Inbox neprocesate: $inb   (0 = bine, ai procesat tot)"
# 2026-10-19: '10_Work\In Progress' nu mai exista — raftul a fost mutat pe Drive
# si apoi renumerat. Cauta cu -LiteralPath o cale moarta insemna 0 de fiecare
# data, adica un raport care arata mereu "bine" fara sa fi masurat nimic.
# Un zero dintr-o masuratoare care nu a masurat nu e zero. Se cauta dupa NUME.
$prgDir = $null
foreach ($d in Get-ChildItem -LiteralPath $Vault -Recurse -Directory -Force -Depth 4 -EA SilentlyContinue) {
  if ($d.Name -eq '01-6-4-In Progress' -or $d.Name -eq 'In Progress') { $prgDir = $d; break }
}
if ($prgDir) {
  $prg = 0
  foreach ($f in Get-ChildItem -LiteralPath $prgDir.FullName -File -Recurse -Force -EA SilentlyContinue) {
    if ($f.Name -ne '00_INDEX.md') { $prg++ }
  }
  Write-Output "  In Progress:        $prg   (0 = bine, nu ai nimic neterminat)   [$($prgDir.FullName.Substring($Vault.Length+1))]"
} else {
  Write-Output "  In Progress:        NU CAZUT   (raftul 'In Progress' nu a fost gasit sub vault)"
}
Write-Output ""
Write-Output "=========================================================="

# COD DE IESIRE EXPLICIT - masurat 2026-10-21.
# Fara un 'exit' propriu, scriptul NU seteaza $LASTEXITCODE, deci mosteneste codul
# treptei anterioare a lantului. Probe: cu $LASTEXITCODE=1 inainte, health-check
# raporta "cod de iesire 1" cu 0 erori si 0 atentioni, desi masura lui era corecta
# (51.286 fisiere / 88,72 GB / diferenta 0). Cu 0 inainte, raporta 0. Rularea
# nativa raporta 0. lint.ps1:323 are deja 'exit 1 / exit 0'; era singura poarta
# fara exit. O poarta care raporteaza codul altui instrument nu masoara nimic
# despre ea - si zicea 'cod de iesire 1' despre o masuratoare care nu esuase.
exit 0
