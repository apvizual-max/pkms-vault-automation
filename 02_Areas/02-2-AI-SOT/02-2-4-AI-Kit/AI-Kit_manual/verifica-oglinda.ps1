<#
  PKMS verifica-oglinda.ps1 - poarta reperului nou.

  DECIZIA 1 (Popy, 2026-10-21): reperul de backup nu mai e o copie locala pe
  D:/H:. Reperul e OGLINDA GOOGLE DRIVE CLOUD. Localul si cloud-ul trebuie sa
  fie identice per fisier, iar DriveFS trebuie sa functioneze fara erori, ca
  simetrizarea sa ramana permanenta.

  Ce face:
    1. rezolva mountul DriveFS si baza de metadate (paths.ps1)
    2. cere cititorului READ-ONLY drivefs-oglinda.js starea per-fisier
       local<->cloud: md5 identice / diferite, dimensiune diferita, doar
       local, doar cloud
    3. citeste cozurile DriveFS (pending_uploads, queued_uploads,
       pending_deletes) si starea procesului
    4. clasifica: EROARE / ATENTIE / OK, si intoarce cod de iesire

  MODELUL DE SEVERITATE (masurat, nu inventat):
    EROARE   = continut divergent intre local si cloud (md5 diferit sau
               dimensiune diferita) SAU masuratoarea nu s-a putut face.
    ATENTIE  = latenta de sincronizare (doar local / doar cloud) sau cozi
               active. Popy a acceptat explicit latenta ca fiind normala a
               sistemului bidirectional. Se raporteaza, NU blocheaza.
    OK       = oglinda identica per fisier, cozi goale.

  REGULA CARE CONVERGE:
    o masuratoare care nu a masurat NU e o masuratoare de zero.
    Daca baza nu s-a deschis, sau arborele nu contine vaultul, rezultatul e
    EROARE, nu "OK, 0 divergente". Un raport verde care n-a masurat nimic e
    cel mai periculos raport posibil.

  NU scrie nimic in vault. Nu atinge cloud-ul. Nu repara: raporteaza.
#>
param([string]$Vault = '')
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\paths.ps1"

if (-not $Vault) { $Vault = Get-PkmsVault }
$Vault = Normalize-PkmsPath $Vault
# Poarta de cale reala — o poarta care verifica vaultul gresit nu verifica nimic.
Assert-PkmsVaultReal -Vault $Vault -Cine 'verifica-oglinda'

$errors = New-Object System.Collections.Generic.List[string]
$warn   = New-Object System.Collections.Generic.List[string]
$ok     = New-Object System.Collections.Generic.List[string]

# --- 1. instrumentele ---
$js = Join-Path $PSScriptRoot 'drivefs-oglinda.js'
$node = Get-PkmsNode
$mount = Get-PkmsDriveFsMount
$db = Get-PkmsDriveFsDb

if (-not (Test-Path -LiteralPath $js)) {
  $errors.Add("CITITORUL DE OGLINDA LIPSA: $js. Masuratoarea nu s-a putut face.")
} elseif (-not $node) {
  $errors.Add("NODE NU E PE PATH. Cititorul de oglinda ruleaza pe Node (node:sqlite). Masuratoarea nu s-a putut face.")
}
if (-not $mount) {
  $errors.Add("MOUNTUL DRIVEFS NU A FOST GASIT. Sursa dinamica (shortcutul 'G:\My Drive.lnk') nu a fost accesibila, si niciun stramos al vaultului nu poarta amprenta DriveFS (desktop.ini cu GoogleDriveFS.exe). Masuratoarea nu s-a putut face.")
}
if (-not $db) {
  $errors.Add("Baza DE METADATA DRIVEFS NU A FOST GASITA (mirror_sqlite.db sub %LOCALAPPDATA%\Google\DriveFS\). Masuratoarea nu s-a putut face.")
}

# --- 2. procesul DriveFS ---
$proc = @(Get-Process GoogleDriveFS -EA SilentlyContinue)
if ($proc.Count -eq 0) {
  $errors.Add("PROCESUL DRIVEFS NU RULEAZA. Oglinda nu se mai sincronizeaza. Verifica shortcutul sau porneste DriveFS.")
} else {
  $ok.Add("DriveFS ruleaza (proces: $($proc.Count))")
}

# --- 3. masurarea oglinzii ---
$rez = $null
$cod = -1
if ($errors.Count -eq 0) {
  $argsJs = @($js, '--json', '--vault', $Vault, '--mount', $mount, '--db', $db)
  $raw = $null
  try {
    $raw = & $node @argsJs 2>&1
    $cod = [int]$LASTEXITCODE
  } catch {
    $errors.Add("CITITORUL DE OGLINDA A PICAT: $($_.Exception.Message). Masuratoarea nu s-a putut face.")
    $raw = $null
  }
  if ($raw) {
    $txt = ($raw | Out-String)
    try { $rez = $txt | ConvertFrom-Json }
    catch {
      $errors.Add("IESIREA CITITORULUI NU E JSON. Masuratoarea nu s-a putut face. Primele 200 de caractere: " + $txt.Substring(0, [Math]::Min(200, $txt.Length)))
      $rez = $null
    }
  } else {
    $errors.Add("CITITORUL DE OGLINDA NU A PRODUS IESEIRE. Masuratoarea nu s-a putut face.")
    $rez = $null
  }
}

if ($rez) {
  if (-not $rez.ok) {
    # exit 2 = masuratoarea NU s-a facut. Asta e o eroare, nu un zero.
    $errors.Add("MASURAT OGLINDA NU A REUSIT: $($rez.motiv)")
  } else {
    $id = $rez.identitate
    $it = $rez.itemi
    $ok.Add("oglinda masurata la $($rez.masuratLa) — $($it.fisiere) fisiere, $($it.foldere) foldere in vault")
    $ok.Add("md5 identice local<->cloud: $($id.md5Identice)")

    if ($id.md5Diferite -gt 0) {
      $errors.Add("DIVERGENTA REALA: $($id.md5Diferite) fisiere au md5 diferit intre local si cloud. Exemple: " +
                  (($rez.exemple.md5Diferite | Select-Object -First 5 | ForEach-Object { $_.cale }) -join '; '))
    }
    if ($id.dimensiuneDiferita -gt 0) {
      $errors.Add("DIVERGENTA REALA: $($id.dimensiuneDiferita) fisiere au dimensiune diferita intre local si cloud.")
    }
    if ($id.md5Lipsa -gt 0) {
      $warn.Add("$($id.md5Lipsa) fisiere nu au md5 nici local, nici in cloud. Fapt, nu verdict: pot fi in flux de upload.")
    }
    if ($id.doarLocal -gt 0) {
      $warn.Add("$($id.doarLocal) fisiere sunt doar local (inca neincarcate in cloud). Latenta e acceptata; se raporteaza.")
    }
    if ($id.doarCloud -gt 0) {
      $warn.Add("$($id.doarCloud) fisiere sunt doar in cloud (inca neaduse local). Recuperabile din cloud.")
    }

    $cozi = $rez.cozi
    $coziText = "pending_uploads=$($cozi.pending_uploads), queued_uploads=$($cozi.queued_uploads), pending_deletes=$($cozi.pending_deletes)"
    if ($cozi.pending_deletes -gt 0) {
      $errors.Add("COADA DE STERGERI: $($cozi.pending_deletes) stergeri in asteptare. Rerile se sterg din oglinda locala.")
    }
    if ($cozi.pending_uploads -gt 0 -or $cozi.queued_uploads -gt 0) {
      $warn.Add("cozi active: $coziText")
    } else {
      $ok.Add("cozi DriveFS goale: $coziText")
    }

    if ($rez.verdict -eq 'identic') { $ok.Add("VERDICT OGLINDA: IDENTICA per fisier") }
    elseif ($rez.verdict -eq 'pending') { $warn.Add("VERDICT OGLINDA: latenta de sincronizare, fara divergenta") }
  }
}

# --- raport ---
Write-Output "=== PKMS OGLINDA ==="
foreach ($o in $ok)     { Write-Output "  OK      $o" }
foreach ($w in $warn)   { Write-Output "  ATENTIE $w" }
foreach ($e in $errors) { Write-Output "  EROARE  $e" }
Write-Output ""
# LINII MACHINE-READABLE. Contractul cu watch.ps1: daca o treapta nu are o
# forma recunoscuta, parserul nu poate spune "0 erori" — trebuie sa ramana
# "nu am putut citi randul de rezultat". Aici forma e aceeasi cu cea a
# reconcilierii pe backup, ca sa poata fi citita de acelasi parser.
$divLocalCloud = 0
$latLocalCloud = 0
if ($rez -and $rez.ok) {
  $divLocalCloud = [int]$rez.identitate.md5Diferite + [int]$rez.identitate.dimensiuneDiferita
  $latLocalCloud = [int]$rez.identitate.doarLocal + [int]$rez.identitate.doarCloud
}
Write-Output "DIVERGENTA LOCAL<->CLOUD: $divLocalCloud"
Write-Output "LATENTA LOCAL<->CLOUD: $latLocalCloud"
Write-Output "MASURAT OGLINDA: $(if ($rez -and $rez.ok) { 'da' } else { 'NU' })"
Write-Output ""
Write-Output "REZULTAT: $($errors.Count) erori, $($warn.Count) atentioni"
if ($errors.Count -gt 0) { exit 1 } else { exit 0 }
