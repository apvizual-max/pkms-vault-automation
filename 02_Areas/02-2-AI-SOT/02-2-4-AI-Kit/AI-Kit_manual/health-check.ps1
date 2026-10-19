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
$probe1 = @(Get-ChildItem -LiteralPath $Vault -File -Recurse -Force -EA SilentlyContinue |
            Where-Object { $_.FullName -notmatch $ex }).Count
Start-Sleep -Milliseconds 700
$probe2 = @(Get-ChildItem -LiteralPath $Vault -File -Recurse -Force -EA SilentlyContinue |
            Where-Object { $_.FullName -notmatch $ex }).Count
$drift = $probe2 - $probe1
$exSurse = "excludere folosita aici: \\.obsidian\\ si \\.git\\ (2 tipare). paths.ps1 Get-PkmsExclusions are 15 tipare si da ALT numar - nu se amesteca."

Write-Output "==================== STAREA VAULTULUI ===================="
Write-Output ""

Write-Output "STRATUL DE LUCRU"
if (Test-Path (Join-Path $Vault '10_Work')) {
  foreach ($r in Get-ChildItem -LiteralPath (Join-Path $Vault '10_Work') -Directory -Force | Sort-Object Name) {
    $f = @(Get-ChildItem -LiteralPath $r.FullName -File -Recurse -Force -EA SilentlyContinue)
    $mb = [math]::Round((($f | Measure-Object Length -Sum).Sum)/1MB,0)
    Write-Output ("  {0,-22} {1,6} fisiere  {2,8} MB" -f $r.Name, $f.Count, $mb)
  }
} else { Write-Output "  LIPSA 10_Work" }

Write-Output ""
Write-Output "BAZA"
foreach ($b in @('00_Inbox','01_Projects','02_Areas','03_Resources','04_Archive','05_Attachments','06_Metadata')) {
  $p = Join-Path $Vault $b
  if (Test-Path $p) {
    $f = @(Get-ChildItem -LiteralPath $p -File -Recurse -Force -EA SilentlyContinue | Where-Object { $_.FullName -notmatch $ex })
    $mb = [math]::Round((($f | Measure-Object Length -Sum).Sum)/1MB,0)
    Write-Output ("  {0,-22} {1,6} fisiere  {2,8} MB" -f $b, $f.Count, $mb)
  }
}

Write-Output ""
Write-Output "RAFTURILE MASINII"
foreach ($m in @('_SYSTEM','_ARCHIVE','_QUARANTINE')) {
  $p = Join-Path $Vault $m
  if (Test-Path $p) {
    $f = @(Get-ChildItem -LiteralPath $p -File -Recurse -Force -EA SilentlyContinue | Where-Object { $_.FullName -notmatch $ex })
    $mb = [math]::Round((($f | Measure-Object Length -Sum).Sum)/1MB,0)
    Write-Output ("  {0,-22} {1,6} fisiere  {2,8} MB" -f $m, $f.Count, $mb)
  }
}

$all = @(Get-ChildItem -LiteralPath $Vault -File -Recurse -Force -EA SilentlyContinue | Where-Object { $_.FullName -notmatch $ex })
$gb = [math]::Round((($all | Measure-Object Length -Sum).Sum)/1GB,2)
Write-Output ""
Write-Output "TOTAL: $($all.Count) fisiere | $gb GB"
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
$inb = @(Get-ChildItem -LiteralPath (Join-Path $Vault '00_Inbox') -File -Recurse -Force -EA SilentlyContinue | Where-Object { $_.Name -ne 'README.md' -and $_.Name -ne '00_INDEX.md' }).Count
Write-Output "  Inbox neprocesate: $inb   (0 = bine, ai procesat tot)"
# 2026-10-19: '10_Work\In Progress' nu mai exista — raftul a fost mutat pe Drive
# si apoi renumerat. Cauta cu -LiteralPath o cale moarta insemna 0 de fiecare
# data, adica un raport care arata mereu "bine" fara sa fi masurat nimic.
# Un zero dintr-o masuratoare care nu a masurat nu e zero. Se cauta dupa NUME.
$prgDir = @(Get-ChildItem -LiteralPath $Vault -Recurse -Directory -Force -Depth 4 -EA SilentlyContinue |
            Where-Object { $_.Name -eq '01-6-4-In Progress' -or $_.Name -eq 'In Progress' } | Select-Object -First 1)
if ($prgDir.Count -ge 1) {
  $prg = @(Get-ChildItem -LiteralPath $prgDir[0].FullName -File -Recurse -Force -EA SilentlyContinue | Where-Object { $_.Name -ne '00_INDEX.md' }).Count
  Write-Output "  In Progress:        $prg   (0 = bine, nu ai nimic neterminat)   [$($prgDir[0].FullName.Substring($Vault.Length+1))]"
} else {
  Write-Output "  In Progress:        NU CAZUT   (raftul 'In Progress' nu a fost gasit sub vault)"
}
Write-Output ""
Write-Output "=========================================================="