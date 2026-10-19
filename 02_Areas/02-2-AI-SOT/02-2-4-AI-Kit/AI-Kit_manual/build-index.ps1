<#
  PKMS build-index.ps1
  Generează 00_INDEX.md în fiecare folder al vaultului, din conținutul REAL.
  Apoi scrie indexul central, prin însumare de la jos în sus.

  Reguli pe care le respectă singur:
   - nu atinge folderele cu punct
   - nu atinge folderele de plugin-uri
   - nu atinge tema cumpărată
   - nu atinge structura WordPress YYYY\MM din media
   - nu scrie niciodată în backup
#>
# ATENTIE: $Vault ramane GOAL, intentionat (ca in align-index.ps1 si
# reconcile.ps1). Un drum implicit aici face ca `if (-not $Vault)` de mai jos
# sa nu se declanseze NICIODATA: $Vault ar fi mereu nevid, Get-PkmsVault n-ar
# fi apelat niciodata, iar $env:PKMS_VAULT ar fi ignorat in tacere. Cine ar
# rula pe o copie crezand ca ruleaza pe copie ar rescrie vaultul REAL.
# Masurat 2026-10-09: exact asta s-a intamplat intr-o proba adversara — 689 de
# fisiere scrise in vault, pe cand operatorul credea ca lucreaza in alta parte.
param(
  [string]$Vault = '',
  [switch]$Quiet
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\paths.ps1"
# Scrierea unui index poate fi blocata o secunda de antivirus sau de indexerul de
# cautare. O blocare TRENZITORIE nu trebuie sa omoare o rulare de 700 de indexuri.
# Fara re incercare, o singura clipa de blocare lasa arborele la jumatate scris.
# SCRIERE REZILIENTA, CU REFACERE.
# Doua lucruri masurate aici, nu citite:
#  1) Set-Content deschide fisierul in modul Create — il TRUNCHIAZA — si doar
#     apoi scrie. Cand scrierea e blocata, exceptia vine DUPA trunchiere, si
#     indexul ramane gol sau jumatate scris. Vazut pe Old\mici\00_INDEX.md: o
#     rulare nu l-a putut scrie, iar urmatoarea l-a rescris diferit tocmai pentru
#     ca intre timp fusese lasat trunchiat.
#  2) [System.IO.File]::Replace, incercat in locul lui, s-a dovedit SCUMP aici:
#     127s fara sa termine ceea ce Set-Content face in 36s. Nu se blocheaza,
#     dar pastreaza ACL si atribute pe un arbore de 59 GB.
# De aceea: scriem cu Set-Content, si daca toate incercarile esueaza, PUNEM
# INAPOI continutul vechi — care oricum era citit in memorie. Un esec poate
# sa stie, dar nu poate lasa un index fara cap.
function Write-IndexRezilient([string]$cale, [string]$continut, [string[]]$vechi) {
  $pauze = @(300, 1200, 3000, 8000)   # ~12.5s de ferealta in total
  for ($tent = 0; $tent -le $pauze.Count; $tent++) {
    try {
      Set-Content -LiteralPath $cale -Value $continut -Encoding UTF8
      return $true
    } catch {
      if ($tent -eq $pauze.Count) { break }
      Start-Sleep -Milliseconds $pauze[$tent]
    }
  }
  # refacere: fisierul poate fi acum trunchiat de ultima tentativa esuata
  try {
    if ($vechi -and $vechi.Count -gt 0) {
      [System.IO.File]::WriteAllLines($cale, $vechi, (New-Object System.Text.UTF8Encoding($true)))
    }
  } catch { }
  return $false
}

if (-not $Vault) { $Vault = Get-PkmsVault }
# -Vault vine de la om si nu trece prin Get-PkmsVault. Fara asta, o bara
# obisnuita la finalul caii face ca tot vaultul sa para nealiniat.
$Vault = Normalize-PkmsPath $Vault

# Poarta de cale reala. build-index RESCRIE tot ce gaseste, deci o cale gresita
# aici nu e o greseala de raport, e o stergere in masa (vezi paths.ps1).
Assert-PkmsVaultReal -Vault $Vault -Cine 'build-index'


# --- usa (§19.5, ca in align-index.ps1) ---
# build-index.ps1 rescrie TOT ce gaseste. Fara usa, o rulare suprapusa peste
# alta fisier peste fisier, iar rezultatul depinde de cine a terminat intai — nu
# de cine a citit corect. Ca in align: daca usa e inchisa, se iese tacut, cod 0,
# fara scriere si fara log.
$mutexBuild = $null
$mutexAlMeu = $false
foreach ($mn in @('Global\PKMS_BuildIndex_v1', 'Local\PKMS_BuildIndex_v1')) {
  try { $mutexBuild = New-Object System.Threading.Mutex($false, $mn) } catch { $mutexBuild = $null }
  if ($mutexBuild) { break }
}
if ($mutexBuild) {
  try { $mutexAlMeu = $mutexBuild.WaitOne(0) }
  catch [System.Threading.AbandonedMutexException] { $mutexAlMeu = $true }
  if (-not $mutexAlMeu) {
    try { $mutexBuild.Dispose() } catch { }
    Write-Output 'BLOCAJ: o alta rulare de build-index este deja in curs. Ies tacut.'
    exit 0
  }
}
# --- zone interzise (nu primesc index, nu sunt ale tale) ---
$skipDirs = @(
  '\.obsidian', '\.trash', '\.vault-intelligence', '\.claudian',
  '\.neural_memory', '\.sentinel_temp', '\.wwebjs_cache',
  # Folder-singure: trebuie '([\\/]|$)'. Cu bara finala obligatoriu ('\\.git\\'),
  # tiparul NU se potriveste la capatul unei cai — deci .git de la radacina ramanea
  # neprotejat, iar pe masura reala se vedeau 4 subfoldere unde altfel erau 3.
  '[\\/]\.git([\\/]|$)', '[\\/]node_modules([\\/]|$)',
  # ATENTIE: [\\/] inseamna "o bara inclinata", in orice sens. Nu scrie '\' ca
  # la celelalte: un backslash la inceput de regex e ESCAPE octal, deci '\01'
  # devine caracterul cu codul 1 si nu poate potrivi nicio cale reala.
  # Iar pentru un folder-singular trebuie '([\\/]|$)': bara finala obligatorie
  # nu s-ar potrivi niciodata la capatul unei cai, iar folderele goale cu punct
  # de la radacina ar ramane neprotejate.
  # Verificat pe cai reale, nu doar pe hartie:
  #   ...\02_Media_Uploads\2010\01    -> se exclude   (True)
  #   ...\01_Theme_Salient\Licensing  -> se exclude   (True)
  #   ...\vault\.git                   -> se exclude   (True)   [capat de cale]
  #   ...\02_Media_Uploads            -> NU se exclude (radacina ramane indexata)
  #   ...\01_Theme_Salient            -> NU se exclude (radacina ramane indexata)
  #   ...\07_Site_Build, ...\Clienti  -> NU se exclude (neafectate)
  '[\\/]01_Theme_Salient[\\/]', '[\\/]02_Media_Uploads[\\/]20\d\d[\\/]',
  '[\\/]Skills_Archive[\\/]', '[\\/]HERMES-Skills[\\/]', '_Skills_BackUp',
  '[\\/]indexuri generate in gresit[\\/]',
  '[\\/]arhiva-indexe[\\/]?'
)
function Is-Skipped([string]$path) {
  foreach ($s in $skipDirs) { if ($path -match $s) { return $true } }
  return $false
}
if (Test-Path "$Vault\.obsidian") { $skipDirs += '\.obsidian' }

$created = 0; $updated = 0; $skipped = 0
# Initializat AICI, inainte de orice parcurgere. Un contor neinitializat porneste
# de la $null, iar $null + 1 = 1 — asadar ar raporta cu unu prea mult. (§18.7,
# aceeasi clasa ca un contor afisat ca 0 fara a fi calculat vreodata.)
$script:goluri = 0
$rows = New-Object System.Collections.Generic.List[object]

function Human($b) {
  if ($b -ge 1GB) { return "{0:N2} GB" -f ($b/1GB) }
  if ($b -ge 1MB) { return "{0:N0} MB" -f ($b/1MB) }
  if ($b -ge 1KB) { return "{0:N0} KB" -f ($b/1KB) }
  return "$b B"
}

# --- §16: primele cuvinte cu valoare dintr-un nume ---
# regula e fixa, ca doua rulari sa dea exact acelasi text:
# lungime >= 3, macar o litera, nu doar cifre.
function Get-ValueWords([string]$name, [int]$max, [bool]$stripExt) {
  if (-not $name) { return @() }
  $base = if ($stripExt) { [System.IO.Path]::GetFileNameWithoutExtension($name) } else { $name }
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

# --- §16: cele doua blocuri generate ---
# singurele doua blocuri pe care le poate suprascrie. randul "De ce e aici" nu se atinge.
# tot ce se scrie aici vine din masuratoare: extensii, numarul rafturilor, numele lor,
# cel mai mare element. niciun cuvant care nu poate fi numarat.

# ---------------------------------------------------------------------------
# TEXTUL SCRIS DE OM — nu se pierde la regenerare (§18.4; contract linia 383:
# "Rămân: titlul, rândul **De ce e aici:**, orice text scris de om între blocuri").
#
# DEFECTUL PE CARE ASTA ÎL REPARĂ, măsurat pe D: înainte, o rulare de
# build-index.ps1 a șters 16 rânduri scrise cu mâna din două indexuri
# (_QUARANTINE și _QUARANTINE\foldere goale) — note de tip "Ce se verifică din
# nou", rânduri tăiate cu ~~...~~, paragrafe "CORECTAT la 2026-10-08". Scriptul
# asambla fișierul de la zero și singurul lucru pe care îl prelua era motivul.
# align-index.ps1 știa să facă asta; build-index.ps1 nu. De aceea două generatoare
# de aceeași schemă se puteau întoarce una contra celeilalte pe textul omului.
#
# CUM SE DECIDE CE E AL OMULUI: prin potrivire exacta, nu prin forma randului.
# Un rand nou generat care coincide cu un rand vechi e al automatului. Randul
# care NU coincide e al omului — si asta prinde si randurile umane care arata
# ca cele generate (note "> ..." lipite de nota de generat, randuri de tabel
# taiate cu ~~...~~). Forma ar fi taiat bine, dar o stergere prin forma ar fi
# pierdere deghizata in curatenie.
#
# BAZA NEGRA: forma se foloseste DOAR ca a doua plasa, si numai pe randuri care
# sunt identitatea generatorului (titlu, cele patru blocuri, randul de stare,
# notele de generat). Daca un rand generat vechi nu mai coincide cu cel nou
# pentru ca s-a schimbat o cifra, el nu trebuie readus ca fiind al omului —
# de aceea plasa de forma exista deloc.
# ---------------------------------------------------------------------------
# Tiparul randului de stare scris cu `fi[sş]iere` NU se declansea niciodata:
# clasa continea U+015F (s cu cedila, 351), iar in vault scris cu U+0219
# (s cu virgula dedesubt, 537). Masurat: 707 de randuri se potriveau cu
# "incepe cu ** cifra", si toate se scurgeau ca "text de om". Rezultatul era
# vizibil: AI-Kit\00_INDEX.md avea SASE randuri de stare suprapuse (176/182/
# 184/185/186 KB), ramase definitiv in fisier. De aceea tiparul nu mai scrie
# cuvantul cu diacritic: recunoaste randul de stare prin forma lui, care oricum
# este unica — incepe cu "**" urmat de cifra, si nimic scris de om nu incepe asa.
function Test-LiniaGenerata([string]$l) {
  if ($l -match '^#\s*00_INDEX')        { return $true }
  if ($l -match '^#{2,3}\s')            { return $true }
  if ($l -match '^\*\*De ce e aici:')   { return $true }
  if ($l -match '^\*\*\d+ ')           { return $true }   # randul de stare, fara diacritic
  if ($l -match '^> Generat automat de ') { return $true }
  if ($l -match '^> Randul \*\*De ce e aici\*\*') { return $true }
  if ($l -match '^_Fiecare raft e legat')  { return $true }
  # Randurile de date pe care le genereaza automatul: tabelul de fisiere si
  # cele doua liste (subfoldere cu link, grupare pe extensie, cele mai mari 20).
  # Fara ele, orice fisierwhose dimensiune se schimba lasa randul vechi in
  # fisier pentru totdeauna — masurat: 4 randuri de tabel ramase la dimensiuni
  # de 31/30/28/22 KB, in timp ce scriptul avea 32 KB.
  # EXCEPTIE: un rand de tabel taiat cu ~~...~~ este scris de om (il marcheaza
  # ca fiind ceva ce nu mai exista), si se pastreaza oricum. Masurat: azi sunt
  # 0 astfel de randuri in cele 702 de indexuri, deci regula nu costa nimic —
  # dar e ieftina sa existe inainte sa fie nevoie de ea.
  if ($l -match '^\|' -and $l -notmatch '~~') { return $true }
  if ($l -match '^- \[')          { return $true }   # link de subfolder
  if ($l -match '^- \*\*\.')      { return $true }   # grupare pe extensie
  if ($l -match '^- `.*` — \d')     { return $true }   # cele mai mari 20
  if ($l -match '^_\( \d+ fi')     { return $true }   # nota de volum mare
  # Propozitia de descriere si linia de cuvinte cheie sunt identitatea
  # generatorului, la fel ca blocurile. Fara ele, un rand generat vechi
  # supravietuieste in fisier pentru totdeauna: masurat, renumerarea a lasat
  # in coada 51 de propozitii de descriere si 130 de linii de cuvinte cheie, in
  # 114 de indexuri, pentru ca se schimbase un nume de raft sau o cifra, iar
  # forma lor nu era recunoscuta. Plasa de forma exista tocmai pentru asta.
  # Diacriticele sunt scrise ca escape-uri, ca sa nu depinda de codificarea
  # in care e citit fisierul: \u0103 = a-breve, \u0219 = s-comma-below (U+0219,
  # forma in care scrie generatorul), \u021B = t-comma-below, \u00B7 = middle dot.
  if ($l -match '^Folder gol pe \d{4}-\d{2}-\d{2}: niciun fi[\u0219\u015F]ier, niciun subfolder\.$') { return $true }
  if ($l -match '^Nu are fi[\u0219\u015F]iere de con[\u021B\u0163]inut\.') { return $true }
  if ($l -match '^Singura extensie prezent[\u0103\u0102] e `') { return $true }
  if ($l -match '^Cele mai frecvente dou[\u0103\u0102] extensii sunt `') { return $true }
  if ($l -match '^`[^`]+`( \u00B7 `[^`]+`)+$') { return $true }
  return $false
}

$recs = New-Object System.Collections.Generic.List[object]

Get-ChildItem -LiteralPath $Vault -Directory -Recurse -Force -EA SilentlyContinue | Sort-Object FullName | ForEach-Object {
  $dir = $_
  if (Is-Skipped $dir.FullName) { $script:skipped++; return }

  $files = @(Get-ChildItem -LiteralPath $dir.FullName -File -Force -EA SilentlyContinue)
  $subs   = @(Get-ChildItem -LiteralPath $dir.FullName -Directory -Force -EA SilentlyContinue | Where-Object { -not (Is-Skipped $_.FullName) })
  # 00_INDEX.md este REGISTRUL, nu continutul. Daca intra in numaratoare, randul de
  # stare ar depinde de marimea indexului scris chiar in el si nu s-ar mai putea ajunge
  # niciodata la CONFORM. Unica definitie a cifrelor e $real — o foloseste TOT scriptul.
  $real   = @($files | Where-Object { $_.Name -ne '00_INDEX.md' })
  $bytes  = [int64](($real | Measure-Object Length -Sum).Sum)
  $rel    = $dir.FullName.Substring($Vault.Length+1)

  $rows.Add([pscustomobject]@{
    folder = $rel; files = $real.Count; subs = $subs.Count; bytes = $bytes
  })

  $idxPath = Join-Path $dir.FullName '00_INDEX.md'
  $existed = Test-Path -LiteralPath $idxPath

  # --- motivul scris de om: NU se sterge la regenerare ---
  # Un index generat nu are voie sa distruga motivul pe care cineva l-a scris cu mana.
  # Citim randul "**De ce e aici:**" din indexul existent (daca exista) si il pastram.
  $motiv = $null
  $vechi = $null   # randurile vechi, ca textul omului sa poata fi dus peste
  if (Test-Path -LiteralPath $idxPath) {
    $vechi = [System.IO.File]::ReadAllLines($idxPath)
    $prima = $vechi | Where-Object { $_ -match '^\*\*De ce e aici:' } | Select-Object -First 1
    if ($prima) {
      $prima = $prima -replace '^\*\*De ce e aici:\*\*\s*', '**De ce e aici:** '
      $motiv = $prima
    }
  }

  # --- §18.5 / §18.8: folderul gol are UN SINGUR text ---
  # Se hotaraste AICI, inainte de orice asamblare, pentru ca motivul, descrierea
  # si cuvintele cheie sa fie stabilite o singura data si in aceeasi ordine.
  # Un folder gol nu are extensii, nume sau ceva de citit: nu are de unde masura.
  # Cele doua cuvinte NU sunt inventate — ele descriu starea masurata, care e
  # tocmai golul. Data e data la care automatul a completat, nu data folderului.
  $gol = ($real.Count -eq 0 -and $subs.Count -eq 0)
  $dataGol = (Get-Date).ToString('yyyy-MM-dd')
  if ($gol) {
    if (-not $motiv) {
      $motiv = "**De ce e aici:** Index completat automat pe $dataGol. Folderul era gol în ziua aceasta. Scrie aici, cu o propoziție, de ce va conține ceva — până atunci rămâne o întrebare, și e corect să fie o întrebare."
    }
    $script:goluri++
  }

  # --- masuratori pentru blocurile §16 ---
  # 00_INDEX.md e indexul pe care il scriem chiar acum. Daca intra in masuratoare,
  # fiecare index s-ar descrie pe sine, iar 'cel mai mare fisier' ar fi mereu el.
  $real = @($files | Where-Object { $_.Name -ne '00_INDEX.md' })
  $realBytes = [int64](($real | Measure-Object Length -Sum).Sum)

  # cele doua extensii care domina dupa numar. ordinea e stabilata explicit
  # (numar desc, apoi nume) ca doua rulari consecutive sa dea acelasi text.
  $exts = @()
  foreach ($g in ($real | Group-Object Extension | Sort-Object @{e={$_.Count};d=$true}, @{e={$_.Name};d=$false})) {
    if ($g.Name) { $exts += ,@([string]$g.Name, [int]$g.Count) }
  }
  $e1n = ''; $e1c = 0; $e2n = ''; $e2c = 0
  if ($exts.Count -gt 0) { $e1n = $exts[0][0]; $e1c = $exts[0][1] }
  if ($exts.Count -gt 1) { $e2n = $exts[1][0]; $e2c = $exts[1][1] }

  # cel mai mare fisier real; la dimensiune egala, primul alfabetic.
  $bigF = $real | Sort-Object @{e={$_.Length};d=$true}, @{e={$_.Name};d=$false} | Select-Object -First 1
  $bigName = ''; $bigLen = [int64]0
  if ($bigF) { $bigName = [string]$bigF.Name; $bigLen = [int64]$bigF.Length }

  # rafturile copil: le numaram O SINGURA DATA aici, ca sa nu parcurgem arborele
  # inca o data. sectiunea "## Subfoldere" va citi tot din lista asta.
  $subInfos = New-Object System.Collections.Generic.List[object]
  foreach ($s in ($subs | Sort-Object Name)) {
    # Aceeasi masuratoare ca in randul de stare (§18.7), aplicata COPILOR:
    # indexul copilului nu se numara, iar subfolderele interzise ale copilului nu se
    # numara. Fara asta, parintele spune "1 fisier" despre un copil gol, si cele doua
    # generatoare se contrazic pe fiecare folder cu copii.
    $sf    = @(Get-ChildItem -LiteralPath $s.FullName -File -Force -EA SilentlyContinue |
                 Where-Object { $_.Name -ne '00_INDEX.md' })
    $sDirs = @(Get-ChildItem -LiteralPath $s.FullName -Directory -Force -EA SilentlyContinue |
                 Where-Object { -not (Is-Skipped $_.FullName) })
    $subInfos.Add([pscustomobject]@{
      name   = $s.Name
      files  = $sf.Count
      dirs   = $sDirs.Count
      bytes  = [int64](($sf | Measure-Object Length -Sum).Sum)
      # Orice copil eligibil are index dupa aceasta rulare: fie il are deja, fie
      # i-l scriem chiar acum. Test-Path ar da 0 pentru un copil creat acum, parintele
      # l-ar lista "fara index", si a doua rulare l-ar raporta din nou — la nesfarsit.
      hasIdx = $true
      total  = [int64]0
    })
  }

  $a = New-Object System.Text.StringBuilder
  # Calea se scrie cu '/', nu cu '\' (§18.1). Un titlu cu backslash arata
  # identic pe disc, dar e alt text — si daca un generator scrie '\' si celalalt
  # '/', ei se vad diferiti la fiecare comparatie si nu ating nici punct fix.
  [void]$a.AppendLine("# 00_INDEX — $($rel -replace '\\','/')")
  [void]$a.AppendLine()
  if ($motiv) {
    [void]$a.AppendLine($motiv)
    [void]$a.AppendLine()
  }
  [void]$a.AppendLine("**$($real.Count) fișiere · $(Human $bytes) · $($subs.Count) subfoldere**")
  [void]$a.AppendLine()
  [void]$a.AppendLine("> Generat automat de `AI-Kit\build-index.ps1`. Nu edita manual — rulează scriptul din nou.")
  [void]$a.AppendLine("> Randul **De ce e aici** de mai sus, daca exista, se pastreaza la fiecare regenerare.")
  [void]$a.AppendLine()

  $bs = New-Object System.Text.StringBuilder
  if ($subs.Count -gt 0) {
    [void]$bs.AppendLine("## Subfoldere")
    [void]$bs.AppendLine()
    [void]$bs.AppendLine("_Fiecare raft e legat la indexul lui. Un index care nu e legat nu e în arbore._")
    [void]$bs.AppendLine()
    foreach ($s in $subInfos) {
      # rezumat: cate fisiere are, cate subfoldere are, si daca are index
      $sum = "$($s.files) fișiere · $($s.dirs) subfoldere"
      if ($s.hasIdx) {
        # link relativ, incapsulat in <...> ca sa mearga si cu spatii in nume.
        # %23 pentru '#': in markdown '#' e separator de ancora, asa ca un nume de
        # folder ca "Tags__#108" ar fi taiat la "Tags__" si linkul s-ar strica.
        # % se codifica PRIMUL, apoi %. altfel %23 noua iese %2523 si nici asta nu merge.
        $enc = $s.name.Replace('%','%25').Replace('#','%23')
        [void]$bs.AppendLine("- [``$($s.name)``](<$enc/00_INDEX.md>) — $sum")
      } else {
        [void]$bs.AppendLine("- ``$($s.name)`` — $sum · _fără index_")
      }
    }
    [void]$bs.AppendLine()
  }

  $bf = New-Object System.Text.StringBuilder
  if ($real.Count -gt 0) {
    [void]$bf.AppendLine("## Fișiere")
    [void]$bf.AppendLine()
    if ($real.Count -le 60) {
      # volum mic -> tabel complet
      [void]$bf.AppendLine("| Fișier | Dimensiune | Modificat |")
      [void]$bf.AppendLine("|---|---|---|")
      foreach ($f in ($real | Sort-Object Name)) {
        [void]$bf.AppendLine("| ``$($f.Name)`` | $(Human $f.Length) | $($f.LastWriteTime.ToString('yyyy-MM-dd')) |")
      }
    } else {
      # volum mare -> grupat pe extensie, complet dar compact
      [void]$bf.AppendLine("_( $($real.Count) fișiere — grupat după tip, pentru nu umfla documentul)_")
      [void]$bf.AppendLine()
      foreach ($g in ($real | Group-Object Extension | Sort-Object Count -Descending)) {
        $ext = if ($g.Name) { $g.Name } else { '(fără extensie)' }
        $sz  = [int64](($g.Group | Measure-Object Length -Sum).Sum)
        [void]$bf.AppendLine("- **$ext** — $($g.Count) fișiere · $(Human $sz)")
      }
      [void]$bf.AppendLine()
      [void]$bf.AppendLine("### Cele mai mari 20")
      [void]$bf.AppendLine()
      foreach ($f in ($real | Sort-Object Length -Descending | Select-Object -First 20)) {
        [void]$bf.AppendLine("- ``$($f.Name)`` — $(Human $f.Length)")
      }
    }
  }

  # textul e pastrat in memorie pana cand se cunosc dimensiunile recursive.
  # nimic nu se scrie pe disc aici: scrierea se face in pasul 2, dupa ce
  # 'cel mai mare element' poate fi calculat pe intregul arbore.
  $recs.Add([pscustomobject]@{
    path = $dir.FullName; rel = $rel; leaf = $dir.Name; depth = ($rel -split '\\').Count
    real = $real.Count; realBytes = $realBytes; extCount = $exts.Count
    e1n = $e1n; e1c = $e1c; e2n = $e2n; e2c = $e2c
    bigName = $bigName; bigLen = $bigLen
    subs = $subInfos
    idxPath = $idxPath; existed = $existed
    vechi = $vechi
    a = $a.ToString(); bs = $bs.ToString(); bf = $bf.ToString()
  })
}

# --- pasul 2: dimensiunea pe disc a fiecarui folder, calculata IN MEMORIE ---
# nu parcurgem arborele a doua oara. fiecare record isi stie deja fisierele directe,
# iar totalul se aduna de jos in sus, dupa adancime. zero acces la disc in plus.
# se aduna doar fisierele de continut: 00_INDEX.md e fisierul GENERAT, iar daca ar
# intra in masuratoare, propozitia din 'Ce e aici' ar depinde de marimea indexului
# chiar scris in ea -> s-ar schimba de la o rulare la alta fara sa se modifice nimic.
$acc = @{}
foreach ($r in $recs) { $acc[$r.path] = [int64]$r.realBytes }
foreach ($r in ($recs | Sort-Object depth -Descending)) {
  $par = [System.IO.Directory]::GetParent($r.path)
  if ($par -and $acc.ContainsKey($par.FullName)) {
    $acc[$par.FullName] = [int64]$acc[$par.FullName] + [int64]$acc[$r.path]
  }
}

$script:smallKw = 0
$script:omTotal = 0
# Foldere a caror index NU a putut fi scris. Se raporteaza la final si dau
# cod de iesire 1, dar NU opresc restul: masurat, o blocare de scanner pe un
# singur fisier a abandonat odata 701 de indexuri deja scrise corect.
$script:esuate = New-Object System.Collections.Generic.List[string]
# Unde s-a pastrat text scris de om. Fara asta, singura masura e un numar
# total, si nu se poate verifica DE CE a sarit de la 21 la 27.
$script:omUnde = New-Object System.Collections.Generic.List[string]   # contor cu NUME PROPRIU: $omPastrat de mai jos este aceeasi
                     # variabila (foreach nu creeaza scope), iar daca ar fi acelasi
                     # nume, "x = x + x" s-ar anula la fiecare folder si ar
                     # raporta doar ultimul.
# (contorul $script:goluri este initializat langa $created/$updated, inainte de
#  parcurgere — daca l-am initializa aici, ar sterge ce a acumulat prima bucla.)
foreach ($r in $recs) {
  # N1 (poarta de convergenta, 2026-10-08): $gol se calcula in PASUL 1 si se
  # recitia in pasul 2. ForEach-Object nu creeaza scope nou, deci in pasul 2
  # $gol era valoarea ULTIMULUI folder, nu a celui scris — de aceea doar
  # ultimul folder gol primea textul §18.5, iar ceilalti scriau propozitii
  # gresite. Se recalculeaza din $r, care apartine folderului curent.
  $gol = ($r.real -eq 0 -and $r.subs.Count -eq 0)
  # DATA DE COMPLETARE, NU DATA DE ASTAZI (defect masurat 2026-10-09 pe automat,
  # la 06:00: 40 de evenimente din 44, toate cu masura si indexul identice, singura
  # diferenta fiind "azi" vs "ieri"). $dataGol de mai sus se calculeaza la PASUL 1,
  # iar linia se scrie aici, la PASUL 2 — intre bucle nu se creeaza scope nou, deci
  # valoarea de acolo s-ar scurge peste toate folderele. De aceea se calculeaza
  # separat, aici, din indexul aflat acum pe disc. Doar pentru folderele goale, ca
  # sa nu adaug o citire de fisier la fiecare folder din arbore.
  $dataGolFolosita = $dataGol
  if ($gol) {
    $idxGol = Join-Path $r.path '00_INDEX.md'
    if (Test-Path -LiteralPath $idxGol) {
      foreach ($lin in [System.IO.File]::ReadAllLines($idxGol)) {
        if ($lin -match '^Folder gol pe (\d{4}-\d{2}-\d{2}):') { $dataGolFolosita = $Matches[1]; break }
      }
    }
  }
  foreach ($s in $r.subs) {
    $sp = Join-Path $r.path $s.name
    if ($acc.ContainsKey($sp)) { $s.total = [int64]$acc[$sp] } else { $s.total = [int64]$s.bytes }
  }

  # cel mai mare element: cel mai mare fisier real sau cel mai mare raft copil
  $bigName = $r.bigName; $bigLen = [int64]$r.bigLen; $bigIsDir = $false
  $bigSub = $r.subs | Sort-Object @{e={$_.total};d=$true}, @{e={$_.Name};d=$false} | Select-Object -First 1
  if ($bigSub) {
    if ((-not $bigName) -or ([int64]$bigSub.total -gt $bigLen)) {
      $bigName = $bigSub.name; $bigLen = [int64]$bigSub.total; $bigIsDir = $true
    }
  }

  # --- propozitia 1: cele doua extensii care domina ---
  if ($gol) {
    $s1 = "Folder gol pe ${dataGolFolosita}: niciun fișier, niciun subfolder."
  } elseif ($r.real -eq 0) {
    # N2 (poarta de convergenta, 2026-10-08): fara fisiere, dar cu rafturi
    # copil. Nu e folder gol la §18.5 (are subfoldere), deci ramane aceasta
    # propozitie — aceeasi pe care o scrie align-index.ps1:343-344.
    $s1 = 'Nu are fișiere de conținut.'
  } elseif ($r.extCount -eq 1) {
    $s1 = "Singura extensie prezentă e ``$($r.e1n)`` ($($r.e1c) din $($r.real) fișiere)."
  } else {
    $s1 = "Cele mai frecvente două extensii sunt ``$($r.e1n)`` ($($r.e1c) din $($r.real) fișiere) și ``$($r.e2n)`` ($($r.e2c) din $($r.real) fișiere)."
  }

  # --- propozitia 2: rafturile copil si cel mai mare element ---
  $p2 = New-Object System.Collections.Generic.List[string]
  if ($r.subs.Count -eq 1) {
    $p2.Add("Un raft copil: ``$($r.subs[0].name)``")
  } elseif ($r.subs.Count -gt 1) {
    $nn = @(($r.subs | Sort-Object Name | Select-Object -First 3) | ForEach-Object { "``$($_.name)``" })
    if ($r.subs.Count -le 3) {
      $p2.Add("$($r.subs.Count) rafturi copil: $($nn -join ', ')")
    } else {
      $p2.Add("$($r.subs.Count) rafturi copil (primele trei după nume: $($nn -join ', '))")
    }
  }
  if ($bigName -ne '') {
    $p2.Add("cel mai mare element din folder e ``$bigName`` ($(Human $bigLen))")
  }
  $s2 = ''
  if ($p2.Count -gt 0) {
    $s2 = ($p2 -join '; ')
    $s2 = $s2.Substring(0,1).ToUpper() + $s2.Substring(1)
  }
  $desc = if ($s2 -ne '') { "$s1 $s2" } else { $s1 }

  # --- cuvintele cheie: numele folderului, primele 3 cuvinte cu valoare din numele
  # celei mai mari chestii, si cele doua extensii cele mai frecvente ---
  $cand = New-Object System.Collections.Generic.List[string]
  $cand.Add([string]$r.leaf)
  foreach ($w in @(Get-ValueWords $bigName 3 (-not $bigIsDir))) { $cand.Add($w) }
  if ($r.e1n -ne '') { $cand.Add($r.e1n) }
  if ($r.e2n -ne '') { $cand.Add($r.e2n) }

  $kw   = New-Object System.Collections.Generic.List[string]
  $seen = @{}
  foreach ($c in $cand) {
    if ($kw.Count -ge 12) { break }
    $t = ([string]$c).Replace('`','').Replace('·','').Trim()
    if ($t.Length -lt 2) { continue }
    if ($seen.ContainsKey($t)) { continue }
    $seen[$t] = $true
    $kw.Add($t)
  }
  # daca nu s-au strans 5, se completeaza cu numele rafturilor copil, cel mai mare intai
  if ($kw.Count -lt 5) {
    foreach ($s in ($r.subs | Sort-Object @{e={$_.total};d=$true}, @{e={$_.Name};d=$false})) {
      $t = ([string]$s.name).Replace('`','').Replace('·','').Trim()
      if ($t.Length -lt 2) { continue }
      if ($seen.ContainsKey($t)) { continue }
      $seen[$t] = $true
      $kw.Add($t)
      if ($kw.Count -ge 5) { break }
    }
  }
  if ($kw.Count -lt 5) { $script:smallKw++ }
  $kwLine = '`' + ($kw -join '` · `') + '`'
  # §18.5: pentru un folder gol, cuvintele cheie sunt cele doua care descriu starea
  # masurata. Aceleasi doua pe care le scrie align-index — altfel, dupa ce un folder
  # se umple, fiecare generator ar rescrie celalalt cuvintele, la nesfarsit.
  if ($gol) { $kwLine = '`gol` · `necompletat`' }

  $out = New-Object System.Text.StringBuilder
  [void]$out.Append($r.a)
  [void]$out.AppendLine("## Ce e aici")
  [void]$out.AppendLine()
  [void]$out.AppendLine($desc)
  [void]$out.AppendLine()
  [void]$out.AppendLine("## Cuvinte cheie")
  [void]$out.AppendLine()
  [void]$out.AppendLine($kwLine)
  # Un rand gol intre blocuri (§18.1). Fara el, cele doua generatoate scriu
  # aceeasi informatie cu un rand desfasurat intre ele, si diffrul nu se
  # reduce niciodata la randul de atribuire.
  [void]$out.AppendLine()
  [void]$out.Append($r.bs)
  [void]$out.Append($r.bf)
# --- textul omului, dus peste la noua asamblare (vezi Test-LiniaGenerata) ---
  $capOm   = New-Object System.Collections.Generic.List[string]
  $coadaOm = New-Object System.Collections.Generic.List[string]
  $omPastrat = 0
  if ($r.vechi) {
    $vechiLinii = @($r.vechi)
    # primul heading de bloc marcheaza granita dintre "cap" si rest.
    # Ce a fost scris de om deasupra lui ramane in cap; ce a fost scris intre
    # blocuri sau sub ultimul bloc ramane acolo, la coada.
    $primulBloc = -1
    for ($i=0; $i -lt $vechiLinii.Count; $i++) {
      if (([string]$vechiLinii[$i]).Trim() -match '^#{2,3}\s') { $primulBloc = $i; break }
    }
    # ce contine asamblarea noua: orice rand vechi care se regaseste acolo e al automatului
    $cnt = @{}
    foreach ($x in ($out.ToString() -split "`r?`n")) {
      $t = ([string]$x).TrimEnd()
      if ($t -eq '') { continue }
      if ($cnt.ContainsKey($t)) { $cnt[$t] = $cnt[$t] + 1 } else { $cnt[$t] = 1 }
    }
    for ($i=0; $i -lt $vechiLinii.Count; $i++) {
      $t = ([string]$vechiLinii[$i]).TrimEnd()
      if ($t -eq '') { continue }
      if ($cnt.ContainsKey($t) -and $cnt[$t] -gt 0) { $cnt[$t] = $cnt[$t] - 1; continue }
      if (Test-LiniaGenerata $t) { continue }
      $omPastrat++
      if ($primulBloc -ge 0 -and $i -lt $primulBloc) { $capOm.Add($t) } else { $coadaOm.Add($t) }
    }
  }
  if ($omPastrat -gt 0) {
    # Asamblam din nou PE LINII, ca sa putem interpune fara sa atingem ordinea
    # blocurilor. Randurile goale din interior se pastreaza — fara ele, sectiunile
    # se lipesc si §18.1 se incalca chiar in timp ce salvam textul omului.
    $L = New-Object System.Collections.Generic.List[string]
    foreach ($x in ($out.ToString() -split "`r?`n")) { $L.Add([string]$x) }
    while ($L.Count -gt 0 -and $L[$L.Count-1] -eq '') { $L.RemoveAt($L.Count-1) }

    # UNDE intra textul de om din cap: DUPA motiv, daca motivul exista. Daca nu
    # exista (index nou sau corupt), dupa titlu. Se hotaraste O SINGURA DATA,
    # inainte de bucla: altfel conditia "i -eq 0" se declanseaza la titlu la
    # ORICE index, si textul ar ajunge inaintea motivului in loc sa dupa el.
    $areMotiv = (@($L | Where-Object { $_ -match '^\*\*De ce e aici:' })).Count -gt 0
    $rez = New-Object System.Collections.Generic.List[string]
    $introdusCap = $false
    for ($i=0; $i -lt $L.Count; $i++) {
      $rez.Add($L[$i])
      if ((-not $introdusCap) -and ($capOm.Count -gt 0)) {
        $acum = $false
        if ($areMotiv) { if ($L[$i] -match '^\*\*De ce e aici:') { $acum = $true } }
        else { if ($i -eq 0) { $acum = $true } }
        if ($acum) {
          $introdusCap = $true
          if ($rez[$rez.Count-1] -ne '') { $rez.Add('') }
          foreach ($x in $capOm) { $rez.Add([string]$x) }
          $capOm = New-Object System.Collections.Generic.List[string]
        }
      }
    }
    if ((-not $introdusCap) -and ($capOm.Count -gt 0)) {
      $rez.Add('')
      foreach ($x in $capOm) { $rez.Add([string]$x) }
    }
    # Coada: rand gol INAINTE de fiecare rand, nu unul singur in fata blocului.
    # Masurat: align-index.ps1 foloseste Add-Separator, care pune un rand gol
    # inaintea fiecarei bucati de text dintre blocuri. build-index le scria
    # lipite. Rezultatul: align rescria _QUARANTINE\00_INDEX.md la fiecare
    # rulare, si urmatoarea rulare de build lua randurile goale la loc — doua
    # generatoare de aceeasi schema care se bat intre ele. Se aplica aici
    # aceeasi regula ca in align, ca sa nu se mai poata deosebi.
    if ($coadaOm.Count -gt 0) {
      foreach ($x in $coadaOm) {
        if ($rez[$rez.Count-1] -ne '') { $rez.Add('') }
        $rez.Add([string]$x)
      }
    }
    $out2 = New-Object System.Text.StringBuilder
    foreach ($x in $rez) { [void]$out2.AppendLine($x) }
    $out = $out2
  }
  if (-not (Write-IndexRezilient $r.idxPath $out.ToString() $r.vechi)) { $script:esuate.Add($r.rel) }
  else { if ($r.existed) { $script:updated++ } else { $script:created++ } }
  if ($omPastrat -gt 0) {
    $script:omTotal = $script:omTotal + $omPastrat
    $script:omUnde.Add(("{0} ({1} randuri)" -f $r.rel, $omPastrat))
  }
}

# --- index central, însumat de jos în sus ---
$top = @(Get-ChildItem -LiteralPath $Vault -Directory -Force -EA SilentlyContinue | Where-Object { -not (Is-Skipped $_.Name) } | Sort-Object Name)
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("# INDEX CENTRAL — generat automat, nu se scrie manual")
[void]$sb.AppendLine()
[void]$sb.AppendLine("**Tot vaultul, pe un singur ecran.** Generat de ``AI-Kit\build-index.ps1``. Dacă editezi acest fișier, următoarea rulare îl suprascrie.")
[void]$sb.AppendLine()
[void]$sb.AppendLine("Actualizat: $(Get-Date -Format 'yyyy-MM-dd HH:mm')")
[void]$sb.AppendLine()

$allFiles = @(Get-ChildItem -LiteralPath $Vault -File -Recurse -Force -EA SilentlyContinue | Where-Object { -not (Is-Skipped $_.FullName) })
$allBytes = [int64](($allFiles | Measure-Object Length -Sum).Sum)
[void]$sb.AppendLine("**Total indexat: $($allFiles.Count) fișiere · $(Human $allBytes) · $($rows.Count) foldere indexate**")
[void]$sb.AppendLine()
[void]$sb.AppendLine("> Cifra de mai sus **nu** e totalul de pe disc. Sunt scoase folderele cu punct (ale uneltelor), dosarul ``.git``, ``node_modules``, arborele temei cumpărate ``01_Theme_Salient`` și structura WordPress YYYY\MM din ``02_Media_Uploads``. Rădăcinile temei și ale mediilor rămân indexate, fiindcă nu se exclud. Scriptul nu numără niciodată totalul de pe disc, deci nu compară cifra asta cu nimic.")
[void]$sb.AppendLine()

$bk = Get-PkmsBackup
if ($bk) {
  [void]$sb.AppendLine("Backup: ``$bk`` — imutabil, nu i se scrie niciodată.")
} else {
  [void]$sb.AppendLine("Backup: **NEGĂSIT** — `paths.ps1` nu l-a descoperit. Verifică înainte de orice reconciliere.")
}
[void]$sb.AppendLine()
[void]$sb.AppendLine("---")
[void]$sb.AppendLine()
[void]$sb.AppendLine("## Niveluri")
[void]$sb.AppendLine()
[void]$sb.AppendLine("| Folder | Fișiere | Subfoldere | Dimensiune |")
[void]$sb.AppendLine("|---|---|---|---|")

foreach ($t in $top) {
  $r = $rows | Where-Object { $_.folder -eq $t.Name }
  if ($r) {
    [void]$sb.AppendLine("| ``$($t.Name)`` | $($r.files) | $($r.subs) | $(Human $r.bytes) |")
  } else {
    $f = @(Get-ChildItem -LiteralPath $t.FullName -File -Force -EA SilentlyContinue)
    [void]$sb.AppendLine("| ``$($t.Name)`` | $($f.Count) | — | $(Human ([int64](($f|Measure-Object Length -Sum).Sum))) |")
  }
}
[void]$sb.AppendLine()
[void]$sb.AppendLine("---")
[void]$sb.AppendLine()
[void]$sb.AppendLine("## Toate folderele indexate")
[void]$sb.AppendLine()
foreach ($g in ($rows | Group-Object { ($_.folder -split '\\')[0] } | Sort-Object Name)) {
  [void]$sb.AppendLine("### ``$($g.Name)``")
  [void]$sb.AppendLine()
  [void]$sb.AppendLine("| Folder | Fișiere | Dimensiune | Index |")
  [void]$sb.AppendLine("|---|---|---|---|")
  foreach ($r in ($g.Group | Sort-Object folder)) {
    # %23 pentru '#' — in markdown e separator de ancora, deci un folder numit
    # "Tags - #108" ar fi taiat la "Tags - " si linkul ar muri.
    # %25 pentru '%' — trebuie codificat primul, altfel s-ar strica ordinea.
    $enc = ($r.folder -replace '\\','/').Replace('%','%25').Replace('#','%23')
    $link = "[``$($r.folder)``]($enc/00_INDEX.md)"
    [void]$sb.AppendLine("| ``$($r.folder)`` | $($r.files) | $(Human $r.bytes) | $link |")
  }
  [void]$sb.AppendLine()
}

Set-Content -LiteralPath (Join-Path $Vault 'INDEX CENTRAL.md') -Value $sb.ToString() -Encoding UTF8

if (-not $Quiet) {
  Write-Output "indexuri: $created noi, $updated actualizate, $skipped zone protejate"
Write-Output "foldere goale marcate (§18.5): $goluri"
  Write-Output "index central: INDEX CENTRAL.md  ($($rows.Count) foldere)"
  Write-Output ("pastrat text scris de om: {0} randuri, in {1} foldere" -f $script:omTotal, $script:omUnde.Count)
  foreach ($u in $script:omUnde) { Write-Output ("   pastrat: " + $u) }
  if ($script:esuate.Count -gt 0) {
    Write-Output ("INDEXURI NESCRISE (blocaj de fisier, dupa 5 incercari): {0}" -f $script:esuate.Count)
    foreach ($e in ($script:esuate | Select-Object -First 20)) { Write-Output ("   nescris: " + $e) }
  }
}

# Cod de iesire 1 daca ceva nu s-a scris. Un cod 0 care ascunde o scriere esuata
# ar insemna ca automatul se declara reusit in timp ce arborele e la jumatate.
if ($script:esuate.Count -gt 0) { exit 1 }
exit 0