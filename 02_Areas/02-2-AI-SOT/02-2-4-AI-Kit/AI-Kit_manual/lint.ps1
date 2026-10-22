<#
  PKMS lint.ps1 - verifica regulile vaultului si raporteaza abaterile.
  NU corecteaza nimic. doar raporteaza. corectia ramane decizia lui Alex.
#>
param([string]$Vault = '')
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\paths.ps1"

if (-not $Vault) { $Vault = Get-PkmsVault }
# -Vault vine de la om si nu trece prin Get-PkmsVault. Fara asta, o bara
# obisnuita la finalul caii face ca tot vaultul sa para nealiniat.
$Vault = Normalize-PkmsPath $Vault
# Poarta de cale reala — o poarta care verifica vaultul gresit nu verifica nimic.
Assert-PkmsVaultReal -Vault $Vault -Cine 'lint'
$skip = Get-PkmsExclusions

$errors = New-Object System.Collections.Generic.List[string]
$warn   = New-Object System.Collections.Generic.List[string]
$ok     = New-Object System.Collections.Generic.List[string]

# --- 1. REPERUL: oglinda Google Drive Cloud (Decizia 1) ---
# Backupul local nu mai e reperul. E FALLBACK: e folosit doar cand oglinda nu
# poate fi masurata. Deci lipsa backupului NU mai ridica verdictul daca oglinda
# e sanatoasa.
#
# MASURAT 2026-10-21: backupul de pe H: nu mai exista, iar lint raporta EROARE
# in fiecare zi pentru un reper pe care nimeni nu l-a mai cerut. O poarta care
# urluieste zilnic pe o realitate care a fost inlocuita nu mai e o poarta: e
# zgomot, si omul invata sa nu o mai citeasca.
#
# Mesajul de mai jos spune ACUM ce cauta si ce a gasit, pentru ca oglinda si
# backupul se cauta in locuri CONCRETE — nu se mai trimite omul la intuneric.
$ref = Get-PkmsReference
$B = $null
if ($ref.Tip -eq 'cloud') {
  $ok.Add("reper: oglinda Google Drive Cloud (mount: $($ref.Mount))")
  $ok.Add("baza de metadate DriveFS: $($ref.Baza)")
  $ok.Add("starea per-fisier local<->cloud o masoara verifica-oglinda.ps1 (poarta dedicata)")
} elseif ($ref.Cale) {
  $B = $ref.Cale
  $warn.Add("oglinda DriveFS nu e masurabila ($($ref.Motiv)); reperul e backupul local: $B")
} else {
  $mountGasit = if ($ref.Mount) { $ref.Mount } else { 'nu a fost gasit (nici shortcutul DriveFS, nici amprenta desktop.ini in stramosii)' }
  $dbGasit = if ($ref.Baza) { $ref.Baza } else { 'nu a fost gasita (mirror_sqlite.db lipseste sub %LOCALAPPDATA%\Google\DriveFS)' }
  $errors.Add("NU S-A GASIT REPER. S-au cautat, in ordine: (1) oglinda Google Drive Cloud - mountul DriveFS: $mountGasit; baza de metadate: $dbGasit; (2) backup local - \$env:PKMS_BACKUP, apoi numele vechi de pe D:, apoi toate volumele. REPERUL OBLIGATORIU e oglinda cloud: e ea ce se actualizeaza singura si singura care poate fi masurata per fisier. Fara oglinda si fara backup nu se compara nimic, iar 'nu s-a pierdut nimic' ar fi o minciuna.")
}
if ($B) {
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
  # backupul nu trebuie sa fie in interiorul vaultului
  # (comparație pe cale completa, cu separator - altfel 'Vault - Backup' da match pe prefix)
  $vPrefix = $Vault.TrimEnd('\') + '\'
  if ($B.TrimEnd('\').StartsWith($vPrefix)) { $errors.Add("copia de backup e INSIDE vaultului. trebuie sa stea PE ALT VOLUM, in afara vaultului. Calea gasita: $B") }
}

# --- 2. rafturile masinii fara numerotare ---
foreach ($m in @('_SYSTEM','_ARCHIVE','_QUARANTINE')) {
  if ((Test-Path (Join-Path $Vault $m)) -and ($m -match '^\d')) { $errors.Add("raftul masinii $m are numerotare. nu trebuie.") }
}
$ok.Add("rafturile masinii sunt fara numerotare")

# --- 3. cuvantul interzis: se verifica in NUME, nu in continut ---
# regula e despre nume (foldere, fisiere, scripturi), nu despre text.
# documentatia care DEFINESTE regula trebuie sa poata numi cuvantul, altfel nu exista.
$bad = New-Object System.Collections.Generic.List[string]
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
  Get-ChildItem -LiteralPath $p -Recurse -Force -EA SilentlyContinue |
           Where-Object { $_.Name -match 'LUCURARE' } | ForEach-Object { $bad.Add($_.FullName.Substring($Vault.Length+1)) }
}
Get-ChildItem -LiteralPath $Vault -Force -EA SilentlyContinue |
        Where-Object { $_.Name -match 'LUCURARE' } | ForEach-Object { $bad.Add($_.Name) }
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
# lista urmarea 10_Work, care nu mai exista — deci cel mai mare arbore din vault
# putea lipsi de index fara ca poarta sa geaba. O poarta mutata pe baza noua trebuie
# sa-si mute si aria, nu doar numele.
$noIdx = New-Object System.Collections.Generic.List[string]
foreach ($top in @('01_Projects','02_Areas','03_Resources','00_Inbox','06_Metadata')) {
  $p = Join-Path $Vault $top
  if (Test-Path $p) {
    foreach ($d in Get-ChildItem -LiteralPath $p -Directory -Recurse -Force -Depth 2 -EA SilentlyContinue) {
      $hit = $false
      foreach ($s in $skip) { if ($d.FullName -match $s) { $hit = $true } }
      if ($hit) { continue }
      if (-not (Test-Path (Join-Path $d.FullName '00_INDEX.md'))) { $noIdx.Add($d.FullName.Substring($Vault.Length+1)) }
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
$Guide = if ($Guide.Count -ge 1) { $Guide[0].FullName } else { Join-Path $Vault '02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_guide' }
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
  $errors.Add("LIPSA documentatia: SPECIFICATII - contractul <vaultului|vaultului>.md")
}

foreach ($doc in @('COTOR.md','START AICI.md','INDEX CENTRAL.md',
                   'LOGICA - cum se foloseste fiecare baza.md',
                   'PROCESE - flux de la captură la utilizare.md',
                   'WORKFLOW - ce faci concret.md',
                   'AUTOMATIZARI - scripturi.md',
                   'ONBOARDING AI - cum preia un AI vaultul.md')) {
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
# 2026-10-19. DriveFS se degradeaza IN TIMPUL rularii, nu doar la inceput: in aceeasi
# zi a intrat de 6 ori in starea in care citirea arunca "Incorrect function". O poarta
# verificata la pornire poate sa treaca, iar vaultul sa moara sub ea la jumatate.
# Un stack trace la linia 204 nu e un verdict — e o masuratoare care nu s-a terminat.
# Deci fiecare citire e gardata, iar o citire picata se numara si se raporteaza.
$citiriEsuate = 0
$citiriPicate = New-Object System.Collections.Generic.List[string]
function Read-LinesGardat([string]$Path, [string]$De) {
  try { return ,([System.IO.File]::ReadAllLines($Path)) }
  catch {
    $script:citiriEsuate++
    $script:citiriPicate.Add($De)
    return ,@()
  }
}
foreach ($f in @(Get-ChildItem -LiteralPath $PSScriptRoot -Filter *.ps1 -File -EA SilentlyContinue)) {
  if ($f.Name -eq 'paths.ps1') { continue }   # aici descoperirea e prin design
  $i = 0
  foreach ($ln in (Read-LinesGardat $f.FullName ("script " + $f.Name))) {
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
  foreach ($ln in (Read-LinesGardat $f.FullName ("document " + $f.Name))) {
    $i++
    if ($ln -match 'Alex_Knowlege_Vault\s+-\s+CopyBACKUP') {
      $hard.Add("document $($f.Name) linia $i : $($ln.Trim())")
    }
  }
}
if ($hard.Count -gt 0) {
  foreach ($h in $hard) { $errors.Add("cale de backup scrisa tare, trebuie descoperita: $h") }
} else { $ok.Add("niciun script si niciun document nu are calea de backup scrisa tare") }

# O citire picata NU e un verdict de "curat". E o masuratoare care nu s-a terminat,
# si trebuie sa se vada ca atare, altfel poarta zice "OK" pentru ceva ce n-a citit.
if ($citiriEsuate -gt 0) {
  $errors.Add("VAULTUL NU A PUTUT FI CITIT COMPLET: $($citiriEsuate) citire(s) au picat in timpul rularii — " +
              "filesystem-ul s-a degradat sub poarta. Verdictul de mai sus NU e de incredere. " +
              "Repornește DriveFS și rulează din nou. Picat pe: " + ($citiriPicate -join ', '))
}

# --- 8. cele doua copii ale onboarding-ului trebuie sa fie identice ---
# au fost scrise in paralel si au inceput sa difere: radacina era ramasa in urma.
# o copie care se dezincronizeaza e mai rea decat una singura, pentru ca nimeni
# nu stie care e cea corecta.
$onb1 = Join-Path $Guide 'ONBOARDING AI - cum preia un AI vaultul.md'
if (-not (Test-Path $onb1)) { $onb1 = Join-Path $Vault 'ONBOARDING AI - cum preia un AI vaultul.md' }
$onb2 = Join-Path $PSScriptRoot 'ONBOARDING.md'
if ((Test-Path $onb1) -and (Test-Path $onb2)) {
  $h1 = (Get-FileHash -LiteralPath $onb1 -Algorithm SHA256).Hash
  $h2 = (Get-FileHash -LiteralPath $onb2 -Algorithm SHA256).Hash
  if ($h1 -ne $h2) {
    $errors.Add("cele doua copii ale onboarding-ului difera. copia mai noua: AI-Kit_manual\ONBOARDING.md")
  } else { $ok.Add("cele doua copii ale onboarding-ului sunt identice") }
} else { $warn.Add("lipseste una dintre cele doua copii ale onboarding-ului (cautate in AI-Kit_guide si AI-Kit_manual)") }

# --- 9. encoding: BOM pe orice script care contine caractere ne-ASCII ---
# MASURAT 2026-10-19. watch.ps1 era singurul script al motorului fara BOM. Parse-ul
# raporta 0 erori — si totusi scriptul era stricat: parserul citeste UTF-8, dar
# interpreterul executa ANSI (Windows-1252). Codepoint-ul 021A (Ț) ajungea la
# rulare ca 00C8 0161, iar verdictul 'ATENȚIE' se afisa corupt.
#
# Deci verificarea care prinde defectul NU e parse-ul. E o comparatie de octeti:
# ce scrie Get-Content (cum citeste PS 5.1) contra unei decodari UTF-8 stricte.
# Un script doar-ASCII NU are nevoie de BOM — citit ca ANSI sau ca UTF-8 da
# acelasi text. Poarta urla doar cand non-ASCII exista SI BOM lipseste, pentru ca
# acolo chiar se pierde un caracter. O poarta care urluieste pe scripturi sanatoase
# e mai rea decat o poarta care tace: invata sa nu fie ascultata.
$encDefecte = New-Object System.Collections.Generic.List[string]
$encBune = 0
$encCitiri = 0
$encStrict = New-Object System.Text.UTF8Encoding($false, $true)
foreach ($f in @(Get-ChildItem -LiteralPath $PSScriptRoot -Filter *.ps1 -File -EA SilentlyContinue)) {
  $bytes = $null
  try { $bytes = [System.IO.File]::ReadAllBytes($f.FullName) }
  catch {
    $script:citiriEsuate++
    $script:citiriPicate.Add("encoding " + $f.Name)
    continue
  }
  $encCitiri++
  if ($bytes.Length -eq 0) {
    $encDefecte.Add("script $($f.Name) are 0 octeti — nu are ce verifica")
    continue
  }
  $areBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
  $peste = @($bytes | Where-Object { $_ -gt 0x7F }).Count
  if ($peste -gt 0 -and -not $areBom) {
    $primele = ($bytes | Where-Object { $_ -gt 0x7F } | Select-Object -First 6) -join ' '
    $encDefecte.Add("script $($f.Name) are $peste octeti peste 0x7F si NU are BOM UTF-8. " +
                    "PowerShell 5.1 il citeste ca ANSI si il corupe la rulare. Octeti non-ascii gasiti: $primele. " +
                    "Reparare: adauga EF BB BF in fata fisierului, fara a atinge continutul.")
  } else {
    # cu BOM, verifica si ca ce e DUPA BOM e UTF-8 valid — altfel BOM-ul minte
    if ($areBom) {
      try { $null = $encStrict.GetString($bytes, 3, $bytes.Length - 3) }
      catch { $encDefecte.Add("script $($f.Name) are BOM, dar continutul de dupa el nu e UTF-8 valid") }
    }
    $encBune++
  }
}
if ($encDefecte.Count -gt 0) {
  foreach ($d in $encDefecte) { $errors.Add("encoding: $d") }
} else {
  $ok.Add("encoding: $encBune/$encCitiri scripturi — fiecare cu caractere ne-ASCII are BOM UTF-8")
}

# --- raport ---
Write-Output "=== PKMS LINT ==="
foreach ($o in $ok)     { Write-Output "  OK      $o" }
foreach ($w in $warn)   { Write-Output "  ATENTIE $w" }
foreach ($e in $errors) { Write-Output "  EROARE  $e" }
Write-Output ""
Write-Output "REZULTAT: $($errors.Count) erori, $($warn.Count) atentioni"
if ($errors.Count -gt 0) { exit 1 } else { exit 0 }