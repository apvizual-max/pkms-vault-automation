<#
  PKMS setup.ps1 - ruleaza asta PRIMUL, cand preiei vaultul.
  verifica mediul si iti spune exact ce stiu si ce nu stiu.
  nu modifica nimic.
#>
param([string]$Vault = '')
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\paths.ps1"

if (-not $Vault) { $Vault = Get-PkmsVault }
# -Vault vine de la om si nu trece prin Get-PkmsVault. Fara asta, o bara
# obisnuita la finalul caii face ca tot vaultul sa para nealiniat.
$Vault = Normalize-PkmsPath $Vault

Write-Output "=============================================="
Write-Output "   MINIMAX PKMS - verificare de preluare"
Write-Output "=============================================="
Write-Output ""

if (-not (Test-Path $Vault)) { Write-Output "NU EXISTA: $Vault"; exit 1 }
Write-Output "[OK] vaultul exista: $Vault"

# REPERUL (Decizia 1, Popy, 21-10-2026): reperul nu mai e o copie locala de backup,
# ci oglinda Google Drive Cloud, verificata per fisier local<->cloud. Backupul local
# de pe D: a fost eliminat de pe structura, deci "nu am gasit backup" NU mai e o
# conditie de oprire: poarta cere reper MASURABIL, nu backup.
$ref = Get-PkmsReference
if ($ref.Tip -eq 'cloud') {
  Write-Output "[OK] reperul e oglinda Google Drive Cloud (masurabila per fisier local <-> cloud)"
  Write-Output "     mount: $($ref.Mount)"
  Write-Output "     baza:  $($ref.Baza)"
} elseif ($ref.Tip -eq 'backup-local') {
  Write-Output "[OK] oglinda DriveFS nu e masurabila; reperul e backupul local: $($ref.Cale)"
  Write-Output "     motiv: $($ref.Motiv)"
} else {
  Write-Output "[EROARE] nici oglinda DriveFS, nici backup local: nu ai cu ce compara. NU continua."
  Write-Output "     motiv: $($ref.Motiv)"
  exit 1
}

# Un singur scan al vaultului: lista de citit si cifrele de volum se calculeaza din
# ACEEASI parcurgere. Doua scanuri ar dubla timpul fara sa adauge nimic.
$skip = Get-PkmsExclusions
$all = @(Get-ChildItem -LiteralPath $Vault -File -Recurse -Force -EA SilentlyContinue)
$real = @($all | Where-Object { $n=$_.FullName; $keep=$true; foreach($s in $skip){ if($n -match $s){$keep=$false} }; $keep })

Write-Output ""
Write-Output "CITESTE IN ACEASTA ORDINE (nu sari):"
# CAUTA PE NUME, NU PE CALE SCRISA TARE (AGENTS.md, regula 8). Documentatia s-a
# mutat de mai multe ori (radacina vaultului -> AI-Kit_guide), iar o cale scrisa tare
# intr-o poarta e o alarma amintita cu ce s-a sters: se stinge singura la prima
# renumerare si lasa poarta rosie pe o structura sanatoasa.
$docs = @(
  'SPECIFICATII - contractul vaultului.md',
  'COTOR.md',
  'LOGICA - cum se foloseste fiecare baza.md',
  'PROCESE - flux de la captură la utilizare.md',
  'WORKFLOW - ce faci concret.md',
  'AUTOMATIZARI - scripturi.md',
  'ONBOARDING.md',
  'PROMPT-INSCRIERE.md',
  'INDEX CENTRAL.md'
)
$i = 0
foreach ($d in $docs) {
  $i++
  # ADANCIMEA PRIMEAZA: COTOR.md exista si in PKMS-tooling\...\backup\; cel canonic
  # e la radacina vaultului. Sortarea doar dupa nume ar lua copia de arhiva.
  $hit = @($all | Where-Object { $_.Name -eq $d } | Sort-Object @{e={($_.FullName.Substring($Vault.Length+1) -split '\\').Count}}, @{e={$_.FullName}})
  if ($hit.Count -ge 1) {
    $rel = $hit[0].FullName.Substring($Vault.Length+1)
    Write-Output ("  {0}. {1}  ({2})" -f $i, $d, $rel)
  } else {
    Write-Output ("  {0}. LIPSA: {1}" -f $i, $d)
  }
}

Write-Output ""
Write-Output "VOLUM BRUT: $($all.Count) fisiere, $([math]::Round((($all|Measure-Object Length -Sum).Sum)/1GB,2)) GB"
Write-Output "VOLUM PROPRIU: $($real.Count) fisiere, $([math]::Round((($real|Measure-Object Length -Sum).Sum)/1GB,2)) GB"
Write-Output "  (fara media site-ului si bibliotecile de programe - ale programelor, nu ale tale;`r`n   cifra exacta o masoara build-index.ps1, nu e scrisa aici ca sa nu se ingheteze)"

Write-Output ""
Write-Output "TREI REGULI INAINTE SA FACI ORICE:"
Write-Output "  1. Nu stergi nimic. Neclarul ajunge in _QUARANTINE, cu un motiv scris."
Write-Output "  2. Nu scrii in reper. Daca lipseste ceva, COPIEZI DIN el (oglinda cloud) sau din arhiva externa H:\CLAUDE_Archive."
Write-Output "  3. Nu atingi folderele cu punct. Sunt ale programelor."
Write-Output ""
Write-Output "COMENZI (enumerate dupa fisierele REALE din acest folder, nu din memorie):"
# lista se construieste din ce e efectiv pe disc. un script nou adaugat aici apare
# automat, iar unul fara descriere e spus cu numele lui, in loc sa fie omis tacit.
$rol = @{
  'align-index.ps1'    = 'aliniaza indexurile; scrie doar indexul, arhiva lui si logul'
  'paths.ps1'        = 'verifica reperul (oglinda cloud); nu scrie'
  'setup.ps1'        = 'verificare de preluare; nu scrie'
  'lint.ps1'         = 'POARTA: regulile; nu scrie'
  'verifica-schema.ps1' = 'POARTA: forma indexurilor 00_INDEX; nu scrie'
  'health-check.ps1' = 'masoara vaultul; nu scrie'
  'inchide-log.ps1'    = 'recenseaza evenimentele deschise; scrie doar cu -Arhiveaza'
  'reconcile.ps1'    = 'compara cu reperul; implicit nu scrie'
  'watch.ps1'        = 'verificarea care vine singura; scrie UN raport'
  'build-index.ps1'  = 'regenereaza indexurile; ruleaza DOAR dupa mutari in masa'
  'git-autocommit.ps1' = 'commit autonom la 5 min; nu scrie in afara de commit'
  'rula-din-task.ps1' = 'wrapper-ul taskului; rezolva reperul dinamic; nu scrie'
  'verifica-oglinda.ps1' = 'POARTA: oglinda local <-> cloud, per fisier; nu scrie'
}
$k = 0
foreach ($f in @(Get-ChildItem -LiteralPath $PSScriptRoot -Filter *.ps1 -File -EA SilentlyContinue | Sort-Object Name)) {
  $k++
  $d = 'FARA DESCRIERE - completeaz tabelul $rol din setup.ps1'
  if ($rol.ContainsKey($f.Name)) { $d = $rol[$f.Name] }
  Write-Output ("  {0}. {1,-17} {2}" -f $k, $f.Name, $d)
}
foreach ($n in @($rol.Keys | Sort-Object)) {
  if (-not (Test-Path (Join-Path $PSScriptRoot $n))) { Write-Output "  ATENTIE: $n e descris aici, dar nu exista in acest folder." }
}
Write-Output "  (exista $($k) scripturi)"
Write-Output ""
Write-Output "=============================================="