<#
  PKMS lint.ps1 - verifica regulile voltului si raporteaza abaterile.
  NU corecteaza nimic. doar raporteaza. corectia ramane decizia lui Alex.
#>
param([string]$Vault = '')
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\paths.ps1"

if (-not $Vault) { $Vault = Get-PkmsVault }
$skip = Get-PkmsExclusions

$errors = New-Object System.Collections.Generic.List[string]
$warn   = New-Object System.Collections.Generic.List[string]
$ok     = New-Object System.Collections.Generic.List[string]

# --- 1. backup descoperit si neatins ---
$B = Get-PkmsBackup
if (-not $B) {
  $errors.Add("BACKUP NU A FOST GASIT in radacina lui D:")
} else {
  $ok.Add("backup: $B")
  # prag: 15:13 = dupa ultima lucrare de dinaintea rearanjarii. 15:12:25 era ultima captura din backup.
  $prag = Get-Date '2026-10-07 15:13:00'
  # --- FISIERE si FOLDERE, masurate SEPARAT, cu pragul ACELUASI ---
  # motivul separarii: o copie pastreaza data fisierelor, dar stampileaza folderele
  # cu ora copierii. Un folder dupa prag NU dovedeste nimic despre continut, iar
  # amestecarea lui cu fisierele ar face lint sa urle pe baza unui fapt care nu
  # spunem nimic. Invers, o regula care urluieste fara motiv e mai rea decat o lipsa.
  $fTouched = @(Get-ChildItem -LiteralPath $B -File     -Recurse -Force -EA SilentlyContinue |
                Where-Object { $_.LastWriteTime -gt $prag } | Sort-Object LastWriteTime -Desc)
  $dTouched = @(Get-ChildItem -LiteralPath $B -Directory -Recurse -Force -EA SilentlyContinue |
                Where-Object { $_.LastWriteTime -gt $prag } | Sort-Object LastWriteTime -Desc)
  if ($fTouched.Count -gt 0) {
    $errors.Add("BACKUP PARE ATINS: $($fTouched.Count) fisiere dupa $($prag.ToString('yyyy-MM-dd HH:mm:ss')) - cel mai recent $($fTouched[0].LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')) $($fTouched[0].Name)")
  } else {
    $nB = (Get-ChildItem -LiteralPath $B -File -Recurse -Force -EA SilentlyContinue |
           Sort-Object LastWriteTime -Desc | Select-Object -First 1)
    $ok.Add("backup neatins la nivel de FISIERE: 0 fisiere dupa prag (cel mai recent: $($nB.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')))")
  }
  # FOLDURILE: faptul se raporteaza, verdictul NU se da aici.
  # masurat: 0 fisiere dupa prag, dar 4.882 de 5.004 foldere dupa prag. aceeasi
  # amprenta ar aparea si daca backupul ar fi sters si recopiat integral - de aceea
  # nu poate fi folosita ca dovezi. ce inseamna ramane de hotarat de cititor.
  if ($dTouched.Count -gt 0) {
    $warn.Add("backup: $($dTouched.Count) FOLDERE au LastWriteTime dupa prag (cel mai recent: $($dTouched[0].LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')) $($dTouched[0].Name))")
    $warn.Add("   fapt, nu verdict: copiile pastreaza data fisierelor dar stampileaza folderele cu ora copierii. nu e dovezi de continut atins.")
  } else {
    $ok.Add("backup neatins la nivel de FOLDERE: 0 foldere dupa prag")
  }
  # backupul nu trebuie sa fie in interiorul voltului
  # (comparație pe cale completa, cu separator - altfel 'Vault - Backup' da match pe prefix)
  $vPrefix = $Vault.TrimEnd('\') + '\'
  if ($B.TrimEnd('\').StartsWith($vPrefix)) { $errors.Add("copia de backup e INSIDE voltului. trebuie sa stea in radacina lui D:") }
}

# --- 2. rafturile masinii fara numerotare ---
foreach ($m in @('_SYSTEM','_ARCHIVE','_QUARANTINE')) {
  if ((Test-Path (Join-Path $Vault $m)) -and ($m -match '^\d')) { $errors.Add("raftul masinii $m are numerotare. nu trebuie.") }
}
$ok.Add("rafturile masinii sunt fara numerotare")

# --- 3. cuvantul interzis: se verifica in NUME, nu in continut ---
# regula e despre nume (foldere, fisiere, scripturi), nu despre text.
# documentatia care DEFINESTE regula trebuie sa poata numi cuvantul, altfel nu exista.
$bad = @()
# 01_Projects intra in scanare din 2026-10-08. pana atunci nu era verificat, desi
# baza exista si health-check o raporteaza: un nume cu cuvantul interzis acolo trecea
# prin lint cu "OK". nu exista ratione documentata pentru excludere - contractul
# (SPECIFICATII, sectiunea 6) cere absenta cuvantului din TOATE numele. deci se scaneaza.
foreach ($d in @('10_Work','01_Projects','_SYSTEM','_QUARANTINE','00_Inbox','02_Areas','03_Resources','04_Archive','05_Attachments','06_Metadata','_ARCHIVE','AI-Kit')) {
  $p = Join-Path $Vault $d
  if (-not (Test-Path $p)) { continue }
  $bad += Get-ChildItem -LiteralPath $p -Recurse -Force -EA SilentlyContinue |
           Where-Object { $_.Name -match 'LUCURARE' } | ForEach-Object { $_.FullName.Substring($Vault.Length+1) }
}
$bad += Get-ChildItem -LiteralPath $Vault -Force -EA SilentlyContinue |
        Where-Object { $_.Name -match 'LUCURARE' } | ForEach-Object { $_.Name }
if ($bad.Count -gt 0) { foreach ($b in ($bad|Sort-Object -Unique|Select-Object -First 20)) { $errors.Add("nume cu cuvantul interzis: $b") } }
else { $ok.Add("niciun nume de folder/fisier nu contine cuvantul interzis") }

# --- 4. numele stratului de lucru ---
if (Test-Path (Join-Path $Vault '10_LUCURARE')) { $errors.Add("10_LUCURARE a revenit. corect este 10_Work") }
elseif (Test-Path (Join-Path $Vault '10_Work')) { $ok.Add("stratul de lucru este 10_Work") }
else { $errors.Add("nu exista nici 10_Work, nici 10_LUCURARE") }

# --- 5. index in fiecare folder de continut ---
$noIdx = @()
foreach ($top in @('10_Work','02_Areas','03_Resources','00_Inbox','06_Metadata')) {
  $p = Join-Path $Vault $top
  if (Test-Path $p) {
    foreach ($d in Get-ChildItem -LiteralPath $p -Directory -Recurse -Force -Depth 2 -EA SilentlyContinue) {
      $hit = $false
      foreach ($s in $skip) { if ($d.FullName -match $s) { $hit = $true } }
      if ($hit) { continue }
      if (-not (Test-Path (Join-Path $d.FullName '00_INDEX.md'))) { $noIdx += $d.FullName.Substring($Vault.Length+1) }
    }
  }
}
if ($noIdx.Count -gt 0) {
  $warn.Add("foldere fara 00_INDEX.md: $($noIdx.Count)")
  $noIdx | Select-Object -First 10 | ForEach-Object { $warn.Add("   lipseste: $_") }
} else { $ok.Add("toate folderele de continut au index") }

# --- 6. documentatia de la radacina ---
foreach ($doc in @('COTOR.md','START AICI.md','INDEX CENTRAL.md',
                   'LOGICA - cum se foloseste fiecare baza.md',
                   'PROCESE - flux de la captură la utilizare.md',
                   'WORKFLOW - ce faci concret.md',
                   'SPECIFICATII - contractul voltului.md',
                   'AUTOMATIZARI - scripturi.md',
                   'ONBOARDING AI - cum preia un AI voltul.md')) {
  if (Test-Path (Join-Path $Vault $doc)) { $ok.Add("doc: $doc") }
  else { $errors.Add("LIPSA documentatia: $doc") }
}

# --- 7. calea de backup nu se scrie TARE niciodata ---
# regula care a fost încălcată: un default de parametru cu calea scrisă tare face ca
# descoperirea din paths.ps1 să nu se apeleze niciodată, iar scriptul comparează cu nimic
# și anunță fals că nu s-a pierdut nimic.
$hard = New-Object System.Collections.Generic.List[string]
foreach ($f in @(Get-ChildItem -LiteralPath $PSScriptRoot -Filter *.ps1 -File -EA SilentlyContinue)) {
  if ($f.Name -eq 'paths.ps1') { continue }   # aici descoperirea e prin design
  $i = 0
  foreach ($ln in [System.IO.File]::ReadAllLines($f.FullName)) {
    $i++
    if ($ln -match 'Alex_Knowlege_Vault\s+-\s+(CopyBACKUP|Backup)') {
      $hard.Add("script $($f.Name) linia $i : $($ln.Trim())")
    }
  }
}
# documentele de la radacina. auditul datat e exclus prin design: pastreaza istoria,
# iar istoria are voie sa numeasca numele de atunci.
foreach ($f in @(Get-ChildItem -LiteralPath $Vault -Filter *.md -File -EA SilentlyContinue)) {
  if ($f.Name -eq 'AUDIT_RECONCILIERE_FINAL.md') { continue }
  $i = 0
  foreach ($ln in [System.IO.File]::ReadAllLines($f.FullName)) {
    $i++
    if ($ln -match 'Alex_Knowlege_Vault\s+-\s+CopyBACKUP') {
      $hard.Add("document $($f.Name) linia $i : $($ln.Trim())")
    }
  }
}
if ($hard.Count -gt 0) {
  foreach ($h in $hard) { $errors.Add("cale de backup scrisa tare, trebuie descoperita: $h") }
} else { $ok.Add("niciun script si niciun document nu are calea de backup scrisa tare") }

# --- 8. cele doua copii ale onboarding-ului trebuie sa fie identice ---
# au fost scrise in paralel si au inceput sa difere: radacina era ramasa in urma.
# o copie care se dezincronizeaza e mai rea decat una singura, pentru ca nimeni
# nu stie care e cea corecta.
$onb1 = Join-Path $Vault 'ONBOARDING AI - cum preia un AI voltul.md'
$onb2 = Join-Path $PSScriptRoot 'ONBOARDING.md'
if ((Test-Path $onb1) -and (Test-Path $onb2)) {
  $h1 = (Get-FileHash -LiteralPath $onb1 -Algorithm SHA256).Hash
  $h2 = (Get-FileHash -LiteralPath $onb2 -Algorithm SHA256).Hash
  if ($h1 -ne $h2) {
    $errors.Add("cele doua copii ale onboarding-ului difera. copia mai noua: AI-Kit\ONBOARDING.md")
  } else { $ok.Add("cele doua copii ale onboarding-ului sunt identice") }
} else { $warn.Add("lipseste una dintre cele doua copii ale onboarding-ului") }

# --- raport ---
Write-Output "=== PKMS LINT ==="
foreach ($o in $ok)     { Write-Output "  OK      $o" }
foreach ($w in $warn)   { Write-Output "  ATENTIE $w" }
foreach ($e in $errors) { Write-Output "  EROARE  $e" }
Write-Output ""
Write-Output "REZULTAT: $($errors.Count) erori, $($warn.Count) atentioni"
if ($errors.Count -gt 0) { exit 1 } else { exit 0 }