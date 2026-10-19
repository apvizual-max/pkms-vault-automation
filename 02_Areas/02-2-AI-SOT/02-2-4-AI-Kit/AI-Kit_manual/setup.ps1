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

$B = Get-PkmsBackup
if ($B) { Write-Output "[OK] backupul exista: $B" }
else { Write-Output "[EROARE] backupul nu a fost gasit in radacina lui D:. NU continua fara el."; exit 1 }

Write-Output ""
Write-Output "CITESTE IN ACEASTA ORDINE (nu sari):"
$docs = @(
  'SPECIFICATII - contractul vaultului.md',
  'COTOR.md',
  'LOGICA - cum se foloseste fiecare baza.md',
  'PROCESE - flux de la captură la utilizare.md',
  'WORKFLOW - ce faci concret.md',
  'AUTOMATIZARI - scripturi.md',
  'AI-Kit\ONBOARDING.md',
  'AI-Kit\PROMPT-INSCRIERE.md'
)
$i = 1
foreach ($d in $docs) {
  $p = Join-Path $Vault $d
  if (Test-Path $p) { Write-Output ("  {0}. {1}" -f $i, $d) }
  else { Write-Output ("  {0}. LIPSA: {1}" -f $i, $d) }
  $i++
}
Write-Output "  $i. INDEX CENTRAL.md  (tot vaultul, pe un ecran)"

Write-Output ""
$skip = Get-PkmsExclusions
$all = @(Get-ChildItem -LiteralPath $Vault -File -Recurse -Force -EA SilentlyContinue)
$real = @($all | Where-Object { $n=$_.FullName; $keep=$true; foreach($s in $skip){ if($n -match $s){$keep=$false} }; $keep })
Write-Output "VOLUM BRUT: $($all.Count) fisiere, $([math]::Round((($all|Measure-Object Length -Sum).Sum)/1GB,2)) GB"
Write-Output "VOLUM PROPRIU: $($real.Count) fisiere, $([math]::Round((($real|Measure-Object Length -Sum).Sum)/1GB,2)) GB"
Write-Output "  (fara media site-ului si bibliotecile de programe - ale programelor, nu ale tale;`r`n   cifra exacta o masoara build-index.ps1, nu e scrisa aici ca sa nu se ingheteze)"

Write-Output ""
Write-Output "TREI REGULI INAINTE SA FACI ORICE:"
Write-Output "  1. Nu stergi nimic. Neclarul ajunge in _QUARANTINE, cu un motiv scris."
Write-Output "  2. Nu scrii in backup. Il citesti. Daca lipseste ceva, COPIEZI DIN el."
Write-Output "  3. Nu atingi folderele cu punct. Sunt ale programelor."
Write-Output ""
Write-Output "COMENZI (enumerate dupa fisierele REALE din acest folder, nu din memorie):"
# lista se construieste din ce e efectiv pe disc. un script nou adaugat aici apare
# automat, iar unul fara descriere e spus cu numele lui, in loc sa fie omis tacit.
$rol = @{
  'align-index.ps1'    = 'aliniaza indexurile; scrie doar indexul, arhiva lui si logul'
  'paths.ps1'        = 'verifica drumul catre backup; nu scrie'
  'setup.ps1'        = 'verificare de preluare; nu scrie'
  'lint.ps1'         = 'POARTA: regulile; nu scrie'
  'verifica-schema.ps1' = 'POARTA: forma indexurilor 00_INDEX; nu scrie'
  'health-check.ps1' = 'masoara vaultul; nu scrie'
  'inchide-log.ps1'    = 'recenseaza evenimentele deschise; scrie doar cu -Arhiveaza'
  'reconcile.ps1'    = 'compara cu backupul; implicit nu scrie'
  'watch.ps1'        = 'verificarea care vine singura; scrie UN raport'
  'build-index.ps1'  = 'regenereaza indexurile; ruleaza DOAR dupa mutari in masa'
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