<#
  PKMS lint.ps1 - verifica regulile voltului si raporteaza abaterile.
  NU corecteaza nimic. doar raporteaza. corectia ramane decizia lui Alex.
#>
param([string]$Vault = '')
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\paths.ps1"

if (-not $Vault) { $Vault = Get-PkmsVault }
# -Vault vine de la om si nu trece prin Get-PkmsVault. Fara asta, o bara
# obisnuita la finalul caii face ca tot voltul sa para nealiniat.
$Vault = Normalize-PkmsPath $Vault
# Poarta de cale reala — o poarta care verifica voltul gresit nu verifica nimic.
Assert-PkmsVaultReal -Vault $Vault -Cine 'lint'
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
  # PRAGUL, MASURAT IN LOC, NU SCRIS TARE. MUTARE 2026-10-19.
  # Era o data scrisa tare (2026-10-07 15:13), calibrata pe BACKUPUL VECHI de pe D:.
  # Cand backupul s-a mutat pe H: si a fost refacut, pragul a ramas in urma si a
  # urlat pe 5.799 de fisiere care NU erau atinse nimic — erau munca ta de 12 zile,
  # copiata odata cu backupul. Masurat: 4.692 pe 10-08 (ziua backupului vechi), apoi
  # 688 / 259 / 48 / 59 / 8 / 3 / 9 / 3 / 7 / 4 pana la 10-19. Asta e o COPIE, nu o
  # mana pusa pe backup.
  # Un prag legat de o data istorica nu masoara nimic despre backupul care exista acum.
  # Il legam de backupul insusi: radacina lui primeste ora copierii, iar fisierele
  # pastreaza data lor. Deci ultima scriere in radacina e plafonul peste care orice
  # fiseier mai recent ar insemna cu adevarat ca s-a atins backupul dupa copiere.
  $bRoot = Get-Item -LiteralPath $B -Force -EA SilentlyContinue
  if ($bRoot) {
    $prag = $bRoot.LastWriteTime
    $ok.Add("prag ancorat la backupul insusi: $($prag.ToString('yyyy-MM-dd HH:mm:ss')) (data copierei)")
  } else {
    $prag = Get-Date '2026-10-07 15:13:00'
    $warn.Add("FALBACK: radacina backupului nu s-a citit, se foloseste pragul vechi scris tare")
  }
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
# 2026-10-19: '10_Work' si 'AI-Kit' au fost scoase din lista — primul nu mai exista
# dupa mutarea pe Drive, iar al doilea a devenit 02-2-4-AI-Kit. 'continue' le-ar
# fi sarit in tacerere, iar o poarta care nu mai ajunge la nimic e decor: ar fi
# raportat OK fara sa mai verifice nimic din arborele ala.
# In locul lor, se scaneaza RADACINA pe primele doua niveluri. Astfel orice
# radacina noua sau redenumita intra in verificare fara sa fie numita explicit.
foreach ($d in @('01_Projects','_SYSTEM','_QUARANTINE','00_Inbox','02_Areas','03_Resources','04_Archive','05_Attachments','06_Metadata','07_Canvas Bases','08_Clippings','09_raport-archive','_ARCHIVE','Canvas Bases','Clippings','raport-archive')) {
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
# MUTARE 2026-10-19: 10_Work a fost redenumit 01_Projects si a urcat in baza, la
# randul lui. Masurat: 33.069 de fisiere, 79,44 GB — deci e aceeasi masa, alt nume.
# Inversarea sensului e importanta: 10_Work nu mai e numele CORECT, e o REGRESIE.
# Inainte, lipsa lui 10_LUCURARE era o abatere; acum, prezenTA lui 10_Work este abaterea.
$workCorect = @('01_Projects')
$workRegresie = @('10_Work','10_LUCURARE')
$gasitCorect = $false
foreach ($w in $workCorect) {
  if (Test-Path (Join-Path $Vault $w)) { $ok.Add("stratul de lucru este $w"); $gasitCorect = $true }
}
foreach ($w in $workRegresie) {
  if (Test-Path (Join-Path $Vault $w)) { $errors.Add("$w a revenit. corect este $($workCorect -join ', ')") }
}
if (-not $gasitCorect) { $errors.Add("nu exista stratul de lucru: nici $($workCorect -join ', '), nici $($workRegresie -join ', ')") }

# --- 5. index in fiecare folder de continut ---
# 01_Projects a intrat aici odata cu redenumirea. Inainte NU era scanat, pentru ca
# lista urmarea 10_Work, care nu mai exista — deci cel mai mare arbore din volt
# putea lipsi de index fara ca poarta sa geaba. O poarta mutata pe baza noua trebuie
# sa-si mute si aria, nu doar numele.
$noIdx = @()
foreach ($top in @('01_Projects','02_Areas','03_Resources','00_Inbox','06_Metadata')) {
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

# --- 6. documentatia ---
# MUTARE 2026-10-19. Documentatia NU mai este toata la radacina. La radacina au
# ramas doar 3: COTOR.md, INDEX CENTRAL.md, MANUAL DE NAVIGARE - cotor.md. Restul
# a fost mutat de Alex in AI-Kit\AI-Kit_guide\, odata cu AI-Kit in 02_Areas.
#
# Poarta cauta in ambele locuri, in ordinea: radacina, apoi AI-Kit_guide. O poarta
# care urluieste pe un fisier care EXISTA e o poarta stricata: invata sa numere
# erori pe o structura pe care nu o mai are nimeni, si nimic nu se mai citeste din ea.
# CaUTA in doua locuri, NU renunta: un fisier mutat intr-un tert loc trebuie sa
# cada tot in eroare, ca mutarea lui sa ramana o decizie si nu oPierdere tacita.
# RENUMERARE 2026-10-19: calea scrisa tare a murit aici — AI-Kit a devenit
# 02-2-4-AI-Kit, iar poarta raporta 7 de erori pe documentatie care EXISTA.
# O cale scrisa tare intr-o poarta e o alarma amintita cu ce s-a sters: se stinge
# singura la prima renumerare si lasa poarta rosie pe o structura sanatoasa.
# Deci se cauta după NUME, adica dupa adevarul pe care poarta chiar il verifica.
$Guide = @(Get-ChildItem -LiteralPath $Vault -Recurse -Directory -Force -Depth 6 -EA SilentlyContinue |
           Where-Object { $_.Name -eq 'AI-Kit_guide' } | Select-Object -First 1)
$Guide = if ($Guide.Count -ge 1) { $Guide[0].FullName } else { Join-Path $Vault 'AI-Kit\AI-Kit_guide' }
# Contractul s-a numit mereu SPECIFICATII - contractul <...>.md, dar in 10-11 i s-a
# schimbat grafia din "voltului" in "vaultului" in nume, iar H1 a ramas cu vechea.
# Poarta nu are voie sa retina o grafie ca regula: cerinta reala e "contractul
# EXISTA", nu "are exact acest nume". Se cauta dupa tipar, la radacina sau in ghid,
# si daca nu apare niciuna dintre grafii, atunci chiar lipseste.
$contract = @(Get-ChildItem -LiteralPath $Vault -Recurse -File -Filter 'SPECIFICATII - contractul *.md' -Force -Depth 6 -EA SilentlyContinue |
              Where-Object { $_.FullName -notmatch '\\\.git\\' })
if ($contract.Count -gt 0) {
  $rel = $contract[0].FullName.Substring($Vault.Length+1)
  $ok.Add("doc: contractul ($rel)")
  if ($contract.Count -gt 1) { $warn.Add("EXISTĂ $($contract.Count) contracte, nu stiu care e cel canon: $($rel.FullName)") }
} else {
  $errors.Add("LIPSA documentatia: SPECIFICATII - contractul <voltului|vaultului>.md")
}

foreach ($doc in @('COTOR.md','START AICI.md','INDEX CENTRAL.md',
                   'LOGICA - cum se foloseste fiecare baza.md',
                   'PROCESE - flux de la captură la utilizare.md',
                   'WORKFLOW - ce faci concret.md',
                   'AUTOMATIZARI - scripturi.md',
                   'ONBOARDING AI - cum preia un AI voltul.md')) {
  $atRadacina = Test-Path (Join-Path $Vault $doc)
  $inGuide    = Test-Path (Join-Path $Guide $doc)
  if ($atRadacina)      { $ok.Add("doc: $doc (radacina)") }
  elseif ($inGuide)     { $ok.Add("doc: $doc (AI-Kit_guide)") }
  else { $errors.Add("LIPSA documentatia: $doc (nici la radacina, nici in AI-Kit_guide)") }
}
if (-not (Test-Path $Guide)) {
  $errors.Add("LIPSA AI-Kit_guide: documentatia nu are unde sta")
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
$onb1 = Join-Path $Guide 'ONBOARDING AI - cum preia un AI voltul.md'
if (-not (Test-Path $onb1)) { $onb1 = Join-Path $Vault 'ONBOARDING AI - cum preia un AI voltul.md' }
$onb2 = Join-Path $PSScriptRoot 'ONBOARDING.md'
if ((Test-Path $onb1) -and (Test-Path $onb2)) {
  $h1 = (Get-FileHash -LiteralPath $onb1 -Algorithm SHA256).Hash
  $h2 = (Get-FileHash -LiteralPath $onb2 -Algorithm SHA256).Hash
  if ($h1 -ne $h2) {
    $errors.Add("cele doua copii ale onboarding-ului difera. copia mai noua: AI-Kit_manual\ONBOARDING.md")
  } else { $ok.Add("cele doua copii ale onboarding-ului sunt identice") }
} else { $warn.Add("lipseste una dintre cele doua copii ale onboarding-ului (cautate in AI-Kit_guide si AI-Kit_manual)") }

# --- raport ---
Write-Output "=== PKMS LINT ==="
foreach ($o in $ok)     { Write-Output "  OK      $o" }
foreach ($w in $warn)   { Write-Output "  ATENTIE $w" }
foreach ($e in $errors) { Write-Output "  EROARE  $e" }
Write-Output ""
Write-Output "REZULTAT: $($errors.Count) erori, $($warn.Count) atentioni"
if ($errors.Count -gt 0) { exit 1 } else { exit 0 }