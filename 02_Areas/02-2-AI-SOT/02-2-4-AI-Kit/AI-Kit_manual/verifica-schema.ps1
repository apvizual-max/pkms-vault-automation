<#
  PKMS verifica-schema.ps1
  Verifica daca fiecare 00_INDEX.md respecta SCHEMA din contractul vaultului
  §18.1 — nu daca exista (astea e treaba lui lint.ps1, punctul 5), ci daca e
  BINE FACUT.

  De ce e un script separat, nu un punct nou in lint: lint intreaba "exista?".
  Acesta intreaba "are forma pe care a promis-o contractul?". Amestecate, un
  lint care suie ar ingropa o eroare de schema printre sute de "OK".

  REGULA CE O RETINE: o poarta care nu poate niciodata sa fie rosie nu e o
  poarta, e decor. De aceea exista -AutoTest, care construiește in %TEMP% patru
  indexuri — unul corect, unul cu titlul scris cu \, unul fara blocul de
  fisiere, unul cu o singura cuvant cheie — si cinsprezece cai REALE pe care
  tiparele de excludere trebuie sa le opreasca. Daca una dintre ele nu e
  prinsa, iesirea e 2 si poarta nu poate fi crezuta.

  REGULA PE CARE O RETINE SI BLOCATUL: un index pe care nu-l poti citi nu se
  numara "bine". Daca lista celor NESCRISE nu se poate umple, poarta nu stie
  ce nu a vazut si anunta "totul e pe schema" despre un arbore necitit. De
  aceea -AutoTest blocheaza acum un 00_INDEX.md cu FileShare.None si cere ca
  pe ecran sa apara "NESCRISE", cu iesire cu cod nenul.

  REGULA A DOUA: un bloc nu se cere pentru nimic. Masurat pe un index generat
  real, un folder gol are DOAR "## Ce e aici" si "## Cuvinte cheie" —
  "## Subfoldere" si "## Fișiere" nu se scriu cand nu e nimic de masurat.
  Cererea lor neconditionata a produs 435 de erori false intr-un arbore
  sanatos. Un bloc e obligatoriu doar daca exista ce masurat in el.

  REGULA A TREIA: lista de excluderi se COPIEZA din generatoare, nu se
  rescrie din memorie. Prima mea versiune scria '\Skills_Archive', '\01_Theme_
  Salient' si alte sase: in .NET o bara urmata de o cifra de la 0 la 7 e
  ESCAPE OCTAL (\01 devine U+0001, deci nu poate potrivi nicio cale reala), iar
  \S \H \_ \i nici nu sunt recunoscute — arunca la potrivire.apte tipare moarte,
  iar prima autoproba nu le-a prins pentru ca Test-Excluded ruleaza doar in
  scanarea vaultului, nu in -AutoTest. De aceea autoproba le verifica acum.

  Fara AI. Fara retea. Fara cost. NU scrie nimic pe D:. Citeste doar.
  Nu sterge nimic.

  Codare: UTF-8 cu BOM (PowerShell 5.1 citeste altfel ca ANSI).
  Fara operator ternar PowerShell 7 (`? :`) — incompatibil cu 5.1.
#>
param(
  # Lasat GOAL intentionat, ca in align-index.ps1: o cale scrisa tare ca
  # parametru ar face ca Get-PkmsVault sa nu fie apelat niciodata.
  [string]$Vault = '',
  [switch]$CeVad,
  # Auto-proba: dovedeste ca poarta poate deveni rosie. Ruleaza in %TEMP%.
  [switch]$AutoTest,
  # 0 = doar erorile, 1 = erori + observatii, 2 = tot
  [int]$Nivel = 1
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\paths.ps1"
# calea catre ACEST fisier. -AutoTest porneste un copil cu -File, iar copilul
# trebuie sa stie exact ce script ruleaza, nu ce se gaseste in directorul curent.
$self = $PSCommandPath

# --- zonele interzise — OGLINDITE VERBATIM din build-index.ps1:22-45 --------
$skipDirs = @(
  '\.obsidian', '\.trash', '\.vault-intelligence', '\.claudian',
  '\.neural_memory', '\.sentinel_temp', '\.wwebjs_cache',
  '[\\/]\.git([\\/]|$)', '[\\/]node_modules([\\/]|$)',
  '[\\/]01_Theme_Salient[\\/]', '[\\/]02_Media_Uploads[\\/]20\d\d[\\/]',
  '[\\/]Skills_Archive[\\/]', '[\\/]HERMES-Skills[\\/]', '_Skills_BackUp',
  '[\\/]indexuri generate in gresit[\\/]',
  '[\\/]arhiva-indexe[\\/]?'
)

function Test-Excluded {
  param([string]$Rel)
  foreach ($p in $skipDirs) { if ($Rel -match $p) { return $true } }
  return $false
}

# Cale relativă la rădăcină. Fără ea, măsurătoarea de subfoldere ar căuta
# tiparele de excluziune în calea absolută (C:\...), iar rădăcina arborelui
# de probă ar conta ca fiind un folder interzis. Split-Path -Parent e ambiguu
# în PowerShell 5.1, de aceea substringul manual.
function Relativ([string]$full, [string]$root) {
  if (-not $root) { return $full }
  if ($full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
    return $full.Substring($root.Length).TrimStart('\')
  }
  return $full
}

# --- schema §18.1, ca date ---------------------------------------------------
$blocuri = @('## Ce e aici', '## Cuvinte cheie', '## Subfoldere', '## Fișiere')
$minCuv = 2
$maxCuv = 12


function Test-IndexStructure {
  param([string[]]$linii, $Gasit)

  function Adauga([string]$nivel, [string]$motiv, [string]$detaliu) {
    [void]$Gasit.Add([pscustomobject]@{ Nivel = $nivel; Motiv = $motiv; Detaliu = $detaliu })
  }

  # --- titlul ---
  $titlu = ''
  foreach ($l in $linii) { if ($l.Trim().Length -gt 0) { $titlu = $l.Trim(); break } }
  if ($titlu -notmatch '^#\s*00_INDEX\s+—\s+\S') {
    Adauga 'eroare' 'TITLU' ("prima linie nu e titlul de forma '# 00_INDEX — <cale>'. Gasit: '" + $titlu + "'")
  } elseif ($titlu -match '\\') {
    # §18.1 cere explicit "/" in loc de "\". Pe Windows o cale scrisa cu \
    # arata identica si ar sugera ca arborele e altul decat este.
    Adauga 'eroare' 'TITLU_BARLA' ("titlul contine '\'; contractul §18.1 cere '/'. Titlu: " + $titlu)
  } else {
    $cale = ($titlu -replace '^#\s*00_INDEX\s+—\s*', '').Trim()
    if ($cale -eq '') { Adauga 'eroare' 'TITLU_CALE' 'titlul nu numeste calea.' }
  }

  # --- randul de stare ---
  $areStare = $false
  foreach ($l in $linii) { if ($l -match '^\*\*\d+\s+fi[sș]iere.*subfoldere') { $areStare = $true; break } }
  if (-not $areStare) { Adauga 'eroare' 'STARE' 'lipseste randul "**N fisiere · X · M subfoldere**".' }

  # --- randul omului ---
  #    NU e eroare daca lipseste: e al omului, iar automatul nu are voie sa-l
  #    invente. Lipsa lui e o observatie, nu un defect.
  $areMotiv = $false; $idxMotiv = -1
  for ($i = 0; $i -lt $linii.Count; $i++) {
    if ($linii[$i] -match '^\*\*De ce e aici:\*\*') { $areMotiv = $true; $idxMotiv = $i; break }
  }
  if (-not $areMotiv) {
    Adauga 'observatie' 'MOTIV' 'nu are randul "**De ce e aici:**". E al omului — automatul nu are voie sa-l scrie.'
  } elseif ($idxMotiv -gt 2) {
    Adauga 'observatie' 'MOTIV_POZITIE' ('motivul e pe linia ' + ($idxMotiv + 1) + '; schema §18.1 il pune pe linia 3.')
  }

  # --- nota de generare ---
  $areNota = $false
  foreach ($l in $linii) { if ($l -match '^>\s*Generat automat de') { $areNota = $true; break } }
  if (-not $areNota) { Adauga 'observatie' 'NOTA' 'lipseste nota "> Generat automat de <scriptul>".' }
}

function Test-IndexSemantics {
  param([string[]]$linii, [string]$Dir, [string]$Radacina, $Gasit)

  function Adauga([string]$nivel, [string]$motiv, [string]$detaliu) {
    [void]$Gasit.Add([pscustomobject]@{ Nivel = $nivel; Motiv = $motiv; Detaliu = $detaliu })
  }

  # --- ce s-a măsurat efectiv ---
  # OGLINDIT din build-index.ps1:210-211, care e sursa de adevăr:
  #   - FIȘIERELE se numără toate, fără filtru: interiorul unei zone
  #     interzise nu se atinge, dar un fișier aflat chiar în rădăcina
  #     zonei e conținut (măsurat: 01_Theme_Salient are 2 fișiere reale,
  #     indexate și listate corect de amândouă generatoarele).
  #   - SUBFOLDERELE se numără DOAR dacă nu sunt interzise.
  # Prima mea versiune număra subfolderele fără filtru și cerea "## Subfoldere"
  # în 16 rădăcini de zonă (13 ani din 02_Media_Uploads + 01_Theme_Salient +
  # Skills_Archive + indexuri generate in gresit) ale căror copii sunt TOȚI
  # excluși. 16 erori false, măsurate: în toate cele 16, neexcluse = 0.
  $nrSub = 0; $nrFis = 0
  if ($Dir -and (Test-Path -LiteralPath $Dir)) {
    $nrSub = @(Get-ChildItem -LiteralPath $Dir -Directory -Force -EA SilentlyContinue |
               Where-Object { -not (Test-Excluded -Rel (Relativ $_.FullName $Radacina)) }).Count
    $nrFis = @(Get-ChildItem -LiteralPath $Dir -File -Force -EA SilentlyContinue |
               Where-Object { $_.Name -ne '00_INDEX.md' -and -not (Test-PkmsLiveLog $_.Name) }).Count
  }

  # --- cele patru blocuri ---
  $poz = @{}
  for ($i = 0; $i -lt $linii.Count; $i++) {
    foreach ($b in $blocuri) {
      if (-not $poz.ContainsKey($b) -and $linii[$i].Trim() -eq $b) { $poz[$b] = $i }
    }
  }
  foreach ($b in $blocuri) {
    $trebuie = $true
    if ($b -eq '## Subfoldere' -and $nrSub -eq 0) { $trebuie = $false }
    if ($b -eq '## Fișiere'   -and $nrFis -eq 0) { $trebuie = $false }
    if ($trebuie -and -not $poz.ContainsKey($b)) {
      Adauga 'eroare' 'BLOC_LIPSA' ("lipseste blocul '" + $b + "'.")
    }
  }
  $laRind = @($blocuri | Where-Object { $poz.ContainsKey($_) } | ForEach-Object { $poz[$_] })
  for ($k = 1; $k -lt $laRind.Count; $k++) {
    if ($laRind[$k] -le $laRind[$k - 1]) {
      Adauga 'eroare' 'BLOC_ORDINE' ("blocurile nu sunt in ordinea §18.1: '" + $blocuri[$k] + "' apare inainte de '" + $blocuri[$k - 1] + "'.")
    }
  }

  # --- cuvintele cheie ---
  if ($poz.ContainsKey('## Cuvinte cheie')) {
    $start = $poz['## Cuvinte cheie'] + 1
    $cuv = @()
    for ($i = $start; $i -lt $linii.Count; $i++) {
      $t = $linii[$i].Trim()
      if ($t -eq '' -or $t.StartsWith('#')) { if ($cuv.Count -gt 0) { break } else { continue } }
      $cuv += @($t -split '·' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
    }
    switch ($cuv.Count) {
      { $_ -lt $minCuv } {
        Adauga 'eroare' 'CUVINTE_PUTINE' ($cuv.Count.ToString() + ' cuvinte cheie; §18 cere minimum ' + $minCuv + '.')
        break
      }
      { $_ -gt $maxCuv } {
        Adauga 'eroare' 'CUVINTE_MULTE' ($cuv.Count.ToString() + ' cuvinte cheie; §18 cere maximum ' + $maxCuv + '.')
        break
      }
    }
  }
}

function Test-Index {
  param([string]$Rel, [string]$Text, [string]$Dir, [string]$Radacina = '')

  $Gasit = New-Object System.Collections.ArrayList
  $linii = $Text -split "`r?`n"

  Test-IndexStructure -linii $linii -Gasit $Gasit
  Test-IndexSemantics -linii $linii -Dir $Dir -Radacina $Radacina -Gasit $Gasit

  return $Gasit.ToArray()
}



# ======================= AUTOPROBA =========================================
function Invoke-AutoTest {
  Write-Host "AUTOPROBA — arbore de test in %TEMP%, cu 6 indexuri:"
  Write-Host "  A) corect, pe schema        -> trebuie: ZERO probleme"
  Write-Host "  B) titlu scris cu '\'       -> trebuie: prins ca TITLU_BARLA"
  Write-Host "  C) fara '## Fisier'      -> trebuie: prins ca BLOC_LIPSA (exista un fisier de masurat)"
  Write-Host "  E) fara '## Subfoldere'   -> trebuie: prins ca BLOC_LIPSA (exista un subfolder de masurat)"
  Write-Host "  F) fara '## Subfoldere'   -> NU trebuie prins: singurul subfolder e interzis"
  Write-Host "  D) o singura cuvant cheie   -> trebuie: prins ca CUVINTE_PUTINE"
  Write-Host ""

  $t = Join-Path $env:TEMP ('pkms-schema-autotest-' + [guid]::NewGuid().ToString('N').Substring(0,8))
  $null = New-Item -ItemType Directory -Path $t -Force

  $rand = '-'
  $corect = @(
    '# 00_INDEX — autotest/bun', '',
    '**De ce e aici:** un folder de proba corect scris.', '',
    '**3 fișiere · 1,2 KB · 1 subfoldere**', '',
    '> Generat automat de autotest. Nu edita manual.', '',
    '## Ce e aici', '',
    'Trei fisiere de text si un subfolder.', '',
    '## Cuvinte cheie', '',
    ('`autotest` · `proba`'), '',
    '## Subfoldere', '',
    ('- [`sub`](sub/00_INDEX.md) ' + $rand + ' 1 fișiere · 0 subfoldere'), '',
    '## Fișiere', '',
    '| Fișier | Dimensiune | Modificat |',
    '|---|---|---|',
    '| `a.txt` | 10 B | 2026-10-08 |'
  ) -join "`n"

  $bara = $corect.Replace('autotest/bun', 'autotest\bun')
  $lin = $corect -split "`n"
  $fara = @(); for ($i = 0; $i -lt $lin.Count; $i++) { if ($lin[$i] -ne '## Fișiere') { $fara += $lin[$i] } } ; $fara = ($fara -join "`n")
  # Varianta fara "## Subfoldere", cu randul ei de link scos deasupra, ca sa
  # nu se amestece in cuvintele cheie. Pe asta se construiesc cazurile E si F.
$sarit = $false
$faraSub = $(foreach ($l in $lin) {
  if ($l -eq '## Subfoldere') { $sarit = $true; continue }
  if ($sarit) { if ($l -eq '') { $sarit = $false }; continue }
  $l
}) -join "`n"
  $unu = $corect.Replace('`autotest` · `proba`', '`singur`')

  $cazuri = @(
    @{ N = 'A'; Nume = 'A corect';          Text = $corect; Astept = @();                De = 'corect, pe schema' },
    @{ N = 'B'; Nume = 'B bara inversata';  Text = $bara;  Astept = @('TITLU_BARLA');   De = 'titlu scris cu o bara inclinata' },
    @{ N = 'C'; Nume = 'C bloc lipsa';      Text = $fara;  Astept = @('BLOC_LIPSA');    De = 'fara ## Fisier, desi exista un fisier de masurat' },
    @{ N = 'D'; Nume = 'D putine cuvinte';  Text = $unu;   Astept = @('CUVINTE_PUTINE'); De = 'o singura cuvant cheie' },
    @{ N = 'E'; Nume = 'E subf lipsa';      Text = $faraSub; Astept = @('BLOC_LIPSA');  De = 'fara ## Subfoldere, desi exista un subfolder de masurat' },
    @{ N = 'F'; Nume = 'F subf interzis';   Text = $faraSub; Astept = @();                De = 'singurul subfolder e interzis -> NU cere ## Subfoldere'; SubExcl = $true; DirRel = '02_Media_Uploads\2020' }
  )

  $ok = $true
  foreach ($c in $cazuri) {
    $d = New-Item -ItemType Directory -Path (Join-Path $t ('c' + $c.N)) -Force
    # Cutia trebuie sa aiba CE MASURAT: un fisier de continut si un subfolder.
    # Inainte avea doar 00_INDEX.md, deci niciun bloc nu era cerut, iar cazul C
    # trecea pentru alt motiv. Fiecare caz primeste fixture-ul de care are nevoie.
    $dd = $d.FullName
    if ($c.DirRel) { $dd = Join-Path $d.FullName $c.DirRel }
    $null = New-Item -ItemType Directory -Path $dd -Force
    Set-Content -LiteralPath (Join-Path $dd 'a.txt') -Value 'proba' -Encoding UTF8
    if ($c.SubExcl) {
      # OGLINDIREA EXACTA a celor 16 radacini de zona: cutia JOI joaca rolul
      # radacinii zonei (anul 2020), iar copilul ei (luna 01) este interiorul
      # interzis. Deci "## Subfoldere" nu are ce masura si NU trebuie cerut.
      $null = New-Item -ItemType Directory -Path (Join-Path $dd '01') -Force
    } else {
      $null = New-Item -ItemType Directory -Path (Join-Path $dd 'sub') -Force
    }
    Set-Content -LiteralPath (Join-Path $dd '00_INDEX.md') -Value $c.Text -Encoding UTF8
    $p = Test-Index -Rel 'autotest' -Text $c.Text -Dir $dd -Radacina $t
    $cuEroare = @($p | Where-Object { $_.Nivel -eq 'eroare' })
    $motive = @($cuEroare | ForEach-Object { $_.Motiv })
    if ($c.Astept.Count -eq 0) { $trecut = ($motive.Count -eq 0) }
    else { $trecut = $false; foreach ($a in $c.Astept) { if ($motive -contains $a) { $trecut = $true } } }
    if (-not $trecut) { $ok = $false }
    if ($trecut) { Write-Host ('  [PRINS]    ' + $c.Nume + ' (' + $c.De + ')') }
    else { Write-Host ('  [NEPRINS]  ' + $c.Nume + ' (' + $c.De + ')  — POARTA NU POATE DEVENI ROSIE') }
    if ($cuEroare.Count -eq 0) { Write-Host '             motivele: (niciuna)' }
    else { foreach ($m in $cuEroare) { Write-Host ('             motiv: ' + $m.Motiv + ' — ' + $m.Detaliu) } }
  }

  # --- proba de excluziuni ---
  Write-Host ""
  Write-Host "  EXCLUZIUNI — fiecare tipar, pe o cale care AR TREBUI sa se excluda:"
  $probe = @(
    @{ C = '10_Work\Site\07_Site_Build\02_Media_Uploads\2010\01';  A = $true;  De = 'interior WordPress' },
    @{ C = '10_Work\Site\07_Site_Build\02_Media_Uploads\2024\07';  A = $true;  De = 'interior WordPress' },
    @{ C = 'Clippings\Skills_Archive\mlops';                        A = $true;  De = 'raft Skills_Archive' },
    @{ C = 'Clippings\HERMES-Skills\x';                             A = $true;  De = 'raft HERMES-Skills' },
    @{ C = 'Clippings\_Skills_BackUp_Archive_2026-07-15\a';         A = $true;  De = 'raft _Skills_BackUp' },
    @{ C = '10_Work\Clienti\Knights Tempar\.git';                   A = $true;  De = '.git la CAPAT de cale' },
    @{ C = '10_Work\Site\node_modules\x';                           A = $true;  De = 'node_modules' },
    @{ C = 'vault\indexuri generate in gresit\a\b';                 A = $true;  De = 'arhiva de indexuri gresite' },
    @{ C = '_SYSTEM\arhiva-indexe\2026-10-08\x';                   A = $true;  De = 'arhiva pe care align o scrie' },
    @{ C = 'Clippings\01_Theme_Salient\Licensing';                  A = $true;  De = 'interior temei cumparate' },
    @{ C = '.obsidian\workspace.json';                             A = $true;  De = 'folder cu punct' },
    @{ C = '10_Work\Site\07_Site_Build\02_Media_Uploads';          A = $false; De = 'RADACINA mediilor — ramane indexata' },
    @{ C = 'Clippings\01_Theme_Salient';                            A = $false; De = 'RADACINA temei — ramane indexata' },
    @{ C = '10_Work\Clienti\Knights Tempar';                        A = $false; De = 'raft normal' },
    @{ C = 'Clippings';                                             A = $false; De = 'raft normal la radacina' }
  )
  $probeOk = $true
  foreach ($pr in $probe) {
    $got = Test-Excluded -Rel $pr.C
    if ($got -eq $pr.A) { Write-Host ('  [OK]       asteptat=' + $pr.A + ' primit=' + $got + '  ' + $pr.De) }
    else { $probeOk = $false; Write-Host ('  [GRESIT]   asteptat=' + $pr.A + ' primit=' + $got + '  ' + $pr.De) }
  }
  if (-not $probeOk) { $ok = $false }

  # --- proba NESCRISE: singura poarta pe care o poate omori o stare gresita ---
  Write-Host ""
  Write-Host "  NESCRISE — un index BLOCAT (deschis cu FileShare.None, ca un folder"
  Write-Host "  la care nu ai drept). Trebuie: 'NESCRISE: 1' + 'verdict incomplet' +"
  Write-Host "  iesire cu cod nenul. Altfel verdictul 'totul e pe schema' se prefacea"
  Write-Host "  despre un arbore pe care nu l-a citit."
  $gRoot = Join-Path $t 'g'
  $gOk   = Join-Path $gRoot 'g_bun'
  $gBl   = Join-Path $gRoot 'g_blocaj'
  $null = New-Item -ItemType Directory -Path (Join-Path $gOk 'sub') -Force
  $null = New-Item -ItemType Directory -Path $gBl -Force
  Set-Content -LiteralPath (Join-Path $gOk 'a.txt') -Value 'proba' -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $gOk '00_INDEX.md') -Value ($corect.Replace('autotest/bun','autotest/g_bun')) -Encoding UTF8
  $gIdx = Join-Path $gBl '00_INDEX.md'
  Set-Content -LiteralPath $gIdx -Value $corect -Encoding UTF8

  $fs = $null; $gOut = ''; $gCod = 0
  try {
    # Blocaj REAL, tinut deschis in timp ce copilul citeste. Un proces strain
    # primeste IOException la ReadAllText - exact ce primeste o poarta pe un
    # index la care nu are acces.
    $fs = [System.IO.File]::Open($gIdx, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::None)
    $eaVechi = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $gOut = & 'pwsh' -NoProfile -ExecutionPolicy Bypass -File $self -Vault $gRoot -Nivel 0 2>&1 | Out-String
    $gCod = $LASTEXITCODE
    $ErrorActionPreference = $eaVechi
  } finally {
    if ($fs) { $fs.Close(); $fs.Dispose() }
  }
  foreach ($ln in @($gOut -split "`r?`n")) {
    if ($ln -match 'NESCRISE|REZULTAT|analizate|erori:') { Write-Host ('             ' + $ln.Trim()) }
  }
  $gPrins = (($gOut -match 'NESCRISE:\s+1') -and ($gOut -match 'verdict incomplet') -and ($gCod -ne 0))
  if ($gPrins) { Write-Host ('  [PRINS]    G index blocat -> cod ' + $gCod + ', "NESCRISE: 1" + "verdict incomplet"') }
  else { $ok = $false; Write-Host ('  [NEPRINS]  G index blocat (cod=' + $gCod + ') — POARTA NU POATE DEVENI ROSIE') }

  Write-Host ""
  if ($ok) {
    Write-Host "AUTOPROBA: TOATE CAZURILE AU FOST PRINSE, SI TIPARELE DE EXCLUDERE LOVESC CAILE REALE. Poarta e vie."
    return 0
  }
  Write-Host "AUTOPROBA: UN CAZ NU A FOST PRINS. Poarta nu poate fi de incredere."
  return 2
}

# ======================= RULARE ============================================
# Scanarea e functie, nu cod la nivel de script, pentru un singur motiv: ca
# -AutoTest sa o poata rula asupra unui arbore de proba si sa verifice IESIREA
# cu cod nenul. O poarta pe care nimeni nu poate apuca sa o tragi nu e o poarta.
function Invoke-Scan {
param([string]$Vault, [int]$Nivel = 1)

if (-not $Vault) { $Vault = Get-PkmsVault }
# -Vault vine de la om si nu trece prin Get-PkmsVault. Fara asta, o bara
# obisnuita la finalul caii face ca tot vaultul sa para nealiniat.
$Vault = Normalize-PkmsPath $Vault
if (-not (Test-Path -LiteralPath $Vault)) { throw ('Vaultul nu exista: ' + $Vault) }

$idx = @(Get-ChildItem -LiteralPath $Vault -Recurse -File -Filter '00_INDEX.md' -Force -ErrorAction SilentlyContinue)
$eroare = 0; $observatie = 0; $analizat = 0
# Foldere al caror index NU a putut fi citit. Sunt raportate cu numele,
# pentru ca o poarta care nu spune ce nu a vazut nu este o poarta.
$probleme = New-Object System.Collections.ArrayList
# MASURAT: $nescrise era folosit la 6 locuri si nu era initializat NICIODATA.
# .Add() pe $null arunca RuntimeException, iar cu $ErrorActionPreference='Stop'
# scriptul murea exact la indexul pe care nu-l putea citi - adica exact acolo
# unde trebuia sa raporteze. O poarta ucisa de propria ei lista nu e o poarta.
$nescrise = New-Object System.Collections.Generic.List[string]

foreach ($f in $idx) {
  $rel = $f.FullName.Substring($Vault.Length).TrimStart('\')
  # Regula se aplica pe CAEA FOLDERULUI, nu pe calea cu numele de fisier.
  # Motivul e masurat, nu theoretic: cu "\00_INDEX.md" la capat, radacina
  # zonei (ex. "...\01_Theme_Salient\00_INDEX.md") se potrivea la tiparul
  # de interior, si 16 foldere erau sarite din verificare. Radacina e raft
  # obisnuit si se indexeaza — la fel cum o trateaza build-index si align.
  $relDir = $f.DirectoryName.Substring($Vault.Length).TrimStart('\')
  if (Test-Excluded -Rel $relDir) { continue }
  $txt = ''
  $citit = $false
  for ($tent = 0; $tent -lt 3 -and -not $citit; $tent++) {
    try { $txt = [IO.File]::ReadAllText($f.FullName); $citit = $true }
    catch {
      if ($tent -eq 2) {
        # Refacerea listei daca initializarea de sus a fost stersa: ramura asta
        # trebuie sa ramana intai de ori nu poate ajunge la null.
        if ($nescrise -eq $null) { $nescrise = New-Object System.Collections.Generic.List[string] }
        # si inapoi: un .Add() care arunca aici ar omori chiar mesajul pe care
        # il are ca datorie. Poarta nu se poate ucide pe ea insasi.
        try { [void]$nescrise.Add($rel) } catch { Write-Host ('  ATENTIE: nu am putut nota indexul neles: ' + $rel) }
      }
      else { Start-Sleep -Milliseconds 400 }
    }
  }
  if (-not $citit) { continue }   # raportat mai jos, nu trecut sub tac
  $analizat++
  $r = Test-Index -Rel $rel -Text $txt -Dir $f.DirectoryName -Radacina $Vault
  foreach ($x in $r) {
    if ($x.Nivel -eq 'eroare') { $eroare++ } else { $observatie++ }
    [void]$probleme.Add([pscustomobject]@{ F = $rel; N = $x.Nivel; M = $x.Motiv; D = $x.Detaliu })
  }
}

Write-Host ('Schema §18.1 — indexuri gasite: ' + $idx.Count + ' | analizate: ' + $analizat)
Write-Host ('  erori:      ' + $eroare)
if ($nescrise.Count -gt 0) {
  Write-Host ('  NESCRISE:    ' + $nescrise.Count + '   (NU au fost verificate)')
  foreach ($x in ($nescrise | Select-Object -First 20)) { Write-Host ('     ' + $x) }
}
Write-Host ('  observatii: ' + $observatie + '   (informeaza, nu blocheaza)')
Write-Host ''

$groups = @($probleme | Group-Object -Property M | Sort-Object -Property Count -Descending)
if ($groups.Count -gt 0) {
  Write-Host 'Pe motive:'
  foreach ($g in $groups) {
    $suf = ''
    if ($g.Group[0].N -eq 'observatie') { $suf = '   [informeaza]' }
    Write-Host ('  ' + $g.Name + ': ' + $g.Count + $suf)
  }
  if ($Nivel -ge 1) {
    Write-Host ''
    Write-Host 'Primele 25, cu fisierul:'
    foreach ($p in @($probleme | Select-Object -First 25)) {
      Write-Host ('  [' + $p.N + '] ' + $p.F + ' — ' + $p.M + ': ' + $p.D)
    }
  }
}

Write-Host ''
if ($eroare -gt 0) {
  Write-Host ('REZULTAT: NEALINIAT cu §18.1 — ' + $eroare + ' erori.')
  return 1
}
if ($nescrise.Count -gt 0) {
  Write-Host ('REZULTAT: cele ' + $analizat + ' indexuri CITITE sunt pe schema §18.1; ' + $nescrise.Count + ' NU au putut fi citite — verdict incomplet.')
  return 1
}
Write-Host 'REZULTAT: toate indexurile analizate sunt pe schema §18.1.'
return 0
}

if ($AutoTest) { $cod = Invoke-AutoTest; exit $cod }
exit (Invoke-Scan -Vault $Vault -Nivel $Nivel)