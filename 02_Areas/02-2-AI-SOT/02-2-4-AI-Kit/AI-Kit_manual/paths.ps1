<#
  PKMS paths.ps1 - descopera singure backupul si locatiile canonice.
  se include din toate scripturile, ca numele sa nu mai fie scris tare in 4 locuri.

  de ce: backupul a fost redenumit o data (CopyBACKUP -> Backup - 10-08-2026)
  si scripturile cu numele scris tare au cazut. Acum il cauta.
#>

# Taie separatorul de la final. MASURAT 2026-10-10: Resolve-Path pastreaza bara
# de la final (23 de caractere in loc de 22), iar calea relativa se taie cu
# Substring($Vault.Length) — deci iese fara separatorul de la inceput si nu se
# mai potriveste cu nimic. Rezultat: o bara obisnuita la sfarsitul caii face
# ca toate cele 689 de indexuri sa para nealiniate. In modul de scriere, le-ar
# rescrie pe toate.
function Normalize-PkmsPath([string]$p) {
  if (-not $p) { return $p }
  $t = $p.TrimEnd([char]92, [char]47)
  # o radacina de tip D:\ nu poate ramane goala dupa taiere
  if ($t.Length -eq 0) { return $p.Substring(0,1) }
  return $t
}

function Get-PkmsVault {
  # ORDINEA DE INCREDERE:
  #  1. PKMS_VAULT din mediu — dar doar daca e un vault REAL (vezi Test-PkmsVaultReal)
  #  2. descoperire pe disc: orice folder care are amprenta vaultului
  #  3. NIMIC — intoarce $null. Niciun drum implicit catre o cale moarta.
  #
  # DE CE S-A SCHIMBAT (masurat 2026-10-19):
  #  Versunea veche cadea pe 'return D:\Alex_Knowlege_Vault' ori de cate ori
  #  PKMS_VAULT nu era setat. D: mai are un folder — un STUB cu un singur
  #  fisier, _NU-FOLOSIT-FOLDER-REFACUT.txt. Test-Path trecea, deci scriptul credea
  #  ca e vaultul. In consecinta, orice rulare fara PKMS_VAULT (adica orice
  #  rulare pornita de un task programat, care mosteneste un mediu curat) scria
  #  pe sau citia din folderul mort, in timp ce vaultul real de pe G: nu era
  #  atins. Datoria de index nu se rezolva pentru ca automatul nu privea niciodata
  #  unde trebuia.
  #  O cale care exista NU e neaparat calea corecta. Trebuie sa fie si REALA.

  # 1. mediu, validat
  if ($env:PKMS_VAULT -and (Test-Path -LiteralPath $env:PKMS_VAULT)) {
    $p = (Normalize-PkmsPath $env:PKMS_VAULT)
    if (Test-PkmsVaultReal -Path $p) { return $p }
    # exista, dar nu e vault -> nu ne contam. Cadem mai jos, la descoperire.
  }

  # 2. descoperire pe disc
  foreach ($c in (Get-PkmsVaultCandidates)) {
    if (Test-PkmsVaultReal -Path $c) { return $c }
  }

  # 3. nimic confirmat
  return $null
}

# Amprenta unui vault real: .git + COTOR.md + cel putin un folder numerotat la
# radacina (00_..06_). Un folder obisnuit, oricat de gol, nu trece.
function Test-PkmsVaultReal([string]$Path) {
  if (-not $Path) { return $false }
  if (-not (Test-Path -LiteralPath $Path)) { return $false }
  $p = (Normalize-PkmsPath $Path)
  if (-not (Test-Path -LiteralPath (Join-Path $p '.git')))      { return $false }
  if (-not (Test-Path -LiteralPath (Join-Path $p 'COTOR.md')))  { return $false }
  $numerotat = @(Get-ChildItem -LiteralPath $p -Directory -Force -EA SilentlyContinue |
                 Where-Object { $_.Name -match '^\d\d_' })
  if ($numerotat.Count -lt 3) { return $false }
  if (-not (Test-PkmsVaultCitibil -Path $p)) { return $false }
  return $true
}

# 2026-10-19. Amprenta de mai sus se baza doar pe Test-Path si Get-ChildItem.
# Ambele TREC pe un filesystem care nu mai poate citi continutul: DriveFS a
# intrat de 5 ori in aceasta zi in starea in care lista directoarele, dar
# citirea fisierelor arunca "Incorrect function" (Win32 ERROR_INVALID_FUNCTION).
# Test-Path era deci VERDE pe un mont mort — si orice poarta construită pe el
# raporta zero-uri care nu insemnau nimic. Zero de la o masuratoare care nu a
# masurat nu e zero.
#
# Testul de mai jos citeste OCTETI, nu statistici de metadate. Daca citirea
# arunca, vaultul e declarat ilizibil si poarta se opreste cu rosu, in loc sa
# numere in gol.
function Test-PkmsVaultCitibil([string]$Path) {
  if (-not $Path) { return $false }
  $santinela = Join-Path $Path 'COTOR.md'
  try {
    if (-not (Test-Path -LiteralPath $santinela)) { return $false }
    $b = [System.IO.File]::ReadAllBytes($santinela)
    if ($b.Length -eq 0) { return $false }
    return $true
  } catch {
    return $false
  }
}

function Get-PkmsVaultCandidates {
  # Cautam in radacina fiecarui volum fix o copie cu amprenta vaultului.
  # Fara hardcodare pe o singura litera de disc: daca vaultul se muta din nou,
  # descoperirea merge singura.
  #
  # REGULA DE EXCLUDERE A COPIILOR (masurat 2026-10-19):
  #  Backupul de pe H: are EXACT aceeasi amprenta ca vaultul — .git, COTOR.md si
  #  8 foldere numerotate. Daca descoperirea l-ar lua de bun, atunci build-index
  #  (care RESCRIE tot) ar rescrie BACKUPUL. Backupul e reper, nu tinta.
  #  Deci orice folder al carui NUME aduce a copie e exclus din lista de vaulturi.
  #  Env-ul primeste prioritate (determinist); descoperirea e doar plansa de
  #  siguranta, si plansa nu are voie sa indice spre o copie.
  $rez = New-Object System.Collections.Generic.List[string]
  # indiciu rapid, daca exista
  $hintE = 'E:\Google\GDrive\GDrive-Second_Brain_PKMS'
  if (Test-Path -LiteralPath $hintE) { $rez.Add((Normalize-PkmsPath $hintE)) }
  $hint = 'G:\My Drive\GDrive-Second_Brain_PKMS'
  if (Test-Path -LiteralPath $hint) { $rez.Add((Normalize-PkmsPath $hint)) }
  foreach ($vol in @(Get-PSDrive -PSProvider FileSystem -EA SilentlyContinue)) {
    $rad = $vol.Root
    if (-not (Test-Path -LiteralPath $rad)) { continue }
    foreach ($d in @(Get-ChildItem -LiteralPath $rad -Directory -Force -EA SilentlyContinue)) {
      $full = $d.FullName
      if ($full -like '*My Drive*') {
        foreach ($sub in @(Get-ChildItem -LiteralPath $full -Directory -Force -EA SilentlyContinue)) {
          if ((Test-PkmsVaultReal -Path $sub.FullName) -and -not (Test-PkmsNumeleDeCopie $sub.Name)) {
            $rez.Add((Normalize-PkmsPath $sub.FullName))
          }
        }
      } elseif ((Test-PkmsVaultReal -Path $full) -and -not (Test-PkmsNumeleDeCopie $d.Name)) {
        $rez.Add((Normalize-PkmsPath $full))
      }
    }
  }
  return $rez
}

function Test-PkmsNumeleDeCopie([string]$Nume) {
  if (-not $Nume) { return $false }
  return [bool]($Nume -match '(?i)(bkup|backup|copy|copia|salvat|rezerva|vechi|old)')
}

function Get-PkmsBackup {
  # 1. mediu
  if ($env:PKMS_BACKUP -and (Test-Path $env:PKMS_BACKUP)) { return $env:PKMS_BACKUP }

  # 2. numele vechi, daca exista
  $legacy = 'D:\Alex_Knowlege_Vault - CopyBACKUP'
  if ($legacy -and (Test-Path $legacy)) { return (Normalize-PkmsPath $legacy) }

  # 3. descoperire pe toate volumele (masurat 2026-10-19: backupul s-a mutat pe
  #    H: si nu mai era la D:, deci fara asta Get-PkmsBackup intoarcea null si
  #    lantul se oprea la treapta 1 chiar cu backupul montat corect.)
  #    Cautam un folder care ARE amprenta de vault (copie completa) si NU e
  #    vaultul activ. Preferam numele care spun "copie" (BKUP/BACKUP/...).
  $vault = Get-PkmsVault
  $copii = New-Object System.Collections.Generic.List[string]
  foreach ($vol in @(Get-PSDrive -PSProvider FileSystem -EA SilentlyContinue)) {
    $rad = $vol.Root
    if (-not (Test-Path -LiteralPath $rad)) { continue }
    foreach ($d in @(Get-ChildItem -LiteralPath $rad -Directory -Force -EA SilentlyContinue)) {
      foreach ($p in (Get-PkmsCopiiDeVault -Path $d.FullName)) {
        if ($p -ne $vault) { $copii.Add($p) }
      }
    }
  }
  # preferinta: numele de copie inaintea oricarui alt criteriu
  $numit = @($copii | Where-Object { (Split-Path -Leaf $_) -match '(?i)(bkup|backup|copy|copia)' })
  if ($numit.Count -gt 0) { return (Normalize-PkmsPath $numit[0]) }
  if ($copii.Count -gt 0)  { return (Normalize-PkmsPath $copii[0]) }
  return $null
}

# Copyile complete ale vaultului aflate la radacina unui volum (sau sub My Drive),
# recunoscute prin amprenta, nu prin nume — numele poate fi orice.
function Get-PkmsCopiiDeVault([string]$Path) {
  $rez = New-Object System.Collections.Generic.List[string]
  if (-not (Test-Path -LiteralPath $Path)) { return $rez }
  $p = (Normalize-PkmsPath $Path)
  if (Test-PkmsVaultReal -Path $p) { $rez.Add($p); return $rez }
  if ($p -like '*My Drive*') {
    foreach ($sub in @(Get-ChildItem -LiteralPath $p -Directory -Force -EA SilentlyContinue)) {
      if (Test-PkmsVaultReal -Path $sub.FullName) { $rez.Add((Normalize-PkmsPath $sub.FullName)) }
    }
  }
  return $rez
}

# Refuzul la scriere pe cale nerecunoscuta. Un singur loc, ca mesajul sa fie
# identic in toate scripturile. $Vault vine si din -Vault (omul), deci chiar si
# o cale trecuta manual trebuie validata: D: are un stub cu un fisier care ar
# trece orice Test-Path.
function Assert-PkmsVaultReal([string]$Vault, [string]$Cine) {
  if (-not $Vault) {
    Write-Output ("REFUZAT (" + $Cine + "): nu s-a reusit descoperirea vaultului real. nu s-a scris nimic.")
    exit 1
  }
  if (-not (Test-PkmsVaultReal -Path $Vault)) {
    Write-Output ("REFUZAT (" + $Cine + "): casta nu e un vault real: " + $Vault)
    Write-Output ('  (asteptat: .git + COTOR.md + cel putin 3 foldere NN_ la radacina)')
    exit 1
  }
}

function Get-PkmsExclusions {
  # zone in care nu ne atingem: dot-folders, plugin-uri, git, media WordPress
  return @(
    '\\\.obsidian', '\\\.trash', '\\\.vault-intelligence', '\\\.claudian',
    '\\\.neural_memory', '\\\.sentinel_temp', '\\\.wwebjs_cache',
    '\\\.git\\', '\\node_modules\\', '\\01_Theme_Salient\\',
    '\\02_Media_Uploads\\20\d\d\\',
    'Skills_Archive\\', 'HERMES-Skills\\', '_Skills_BackUp',
    'indexuri generate in gresit\\'
  )
}

# Jurnalele vii ale motorului NU sunt continut — masurat 2026-10-19.
# raport-autocomit.log creste la fiecare comit (Add-Content in
# git-autocommit.ps1:133), iar indexul folderului AI-Kit_manual il numara:
# marimea lui intra in randul de stare, in suma de octeti si in tabelul
# "## Fisier(e)". Rezultatul masurat: indexul era NEALINIAT la fiecare 5
# minute, pentru totdeauna, si nicio rulare nu-l putea duce la CONFORM —
# pentru ca masuratoarea se schimba intre doua comparatii. Mai rau: alinierea
# scria indexul, autocomitul comita, jurnalul crestea, indexul era din nou
# nealiniat. Bucla nu se oprea niciodata.
#
# Regula e aceeasi ca pentru 00_INDEX.md (contractul §18.7): un fisier scris de
# automat, in timpul automatului, nu se numara. Lista e centralizata AICI, ca
# cele doua generatoare sa masoare identic (§18.9) — altfel ele se contrazic,
# si unul rescrie indexurile celuilalt la nesfarsit.
function Test-PkmsLiveLog([string]$Nume) {
  if (-not $Nume) { return $false }
  # Numele sunt scrise EXACT cum sunt pe disc. De aici vine fiecare corectie:
  # raport-autocommit.log (doua 'm'), nu raport-autocomit.log. Un typo intr-o
  # lista de excluziune face poarta sa creada la locul gresit.
  return [bool]($Nume -in @(
    'raport-autocomit.log',        # AI-Kit_manual: creste la fiecare comit
    'raport-aliniere.log',         # AI-Kit_guide: creste la fiecare aliniere
    'arhiva- raport aliniere.log', # AI-Kit_guide: se adauga, nu se suprascrie
    'raport-wrapper-task.log'      # AI-Kit_manual: creste la fiecare rulare de task
  ))
}

# ---------------------------------------------------------------------------
# Treapta 1 a lantului. Rulat DIRECT (nu prin dot-sourcing), trebuie sa spuna
# ce a gasit si sa poata da rosu — altfel e o treapta goala intr-un lant care se
# pretinde ca are cinci. Dotat din celelalte scripturi, ramane tacut: acolo nu
# e o treapta, e doar o dependinta.
#
# ATENTIE: $env:PKMS_VAULT are prioritate. Daca nu e setat, Get-PkmsVault
# intoarce drumul REAL. Cine ruleaza pe o copie trebuie sa si-o declare, altfel
# lucreaza pe vault, crezand ca lucreaza pe copie.
# ---------------------------------------------------------------------------
if ($MyInvocation.InvocationName -ne '.') {
  $v = Get-PkmsVault
  $b = Get-PkmsBackup
  Write-Output "vault:   $v"
  Write-Output "backup: $b"

  # VAULTUL INEXISTENT. O cale care exista nu e neaparat vaultul — vezi Get-PkmsVault.
  # Scrierea e interzisa pe orice cale nerecunoscuta: pe D: sta un stub de un
  # fisier, iar acolo o rulare ar "reu"i fara sa atinga nimic real.
  if (-not $v) { Write-Output 'VAULTUL REAL NU A FOST GASIT. nu s-a scris nimic.'; exit 1 }
  if (-not (Test-PkmsVaultReal -Path $v)) { Write-Output "CALEA NU E UN VAULT REAL: $v"; exit 1 }

  if ($b) {
    Write-Output 'ambele la loc. nu s-a scris nimic.'
  } else {
    Write-Output 'BACKUP NU A FOST GASIT. comparatia cu backupul nu e posibila.'
    exit 1
  }
}