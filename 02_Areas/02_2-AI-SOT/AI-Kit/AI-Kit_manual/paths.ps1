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
  if ($env:PKMS_VAULT -and (Test-Path $env:PKMS_VAULT)) { return (Normalize-PkmsPath $env:PKMS_VAULT) }
  return 'D:\Alex_Knowlege_Vault'
}

function Get-PkmsBackup {
  if ($env:PKMS_BACKUP -and (Test-Path $env:PKMS_BACKUP)) { return $env:PKMS_BACKUP }

  # numele vechi, daca exista
  $legacy = 'D:\Alex_Knowlege_Vault - CopyBACKUP'
  if ($legacy -and (Test-Path $legacy)) { return (Normalize-PkmsPath $legacy) }

  # cauta in radacina lui D: orice copie a voltului
  $candidates = @(
    Get-ChildItem -LiteralPath 'D:\' -Directory -Force -EA SilentlyContinue |
      Where-Object { $_.Name -match '^(Alex_Knowlege_Vault)\s*[-_].*' -and $_.FullName -ne (Get-PkmsVault) } |
      Sort-Object LastWriteTime -Desc
  )
  if ($candidates.Count -gt 0) { return (Normalize-PkmsPath $candidates[0].FullName) }
  return $null
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

# ---------------------------------------------------------------------------
# Treapta 1 a lantului. Rulat DIRECT (nu prin dot-sourcing), trebuie sa spuna
# ce a gasit si sa poata da rosu — altfel e o treapta goala intr-un lant care se
# pretinde ca are cinci. Dotat din celelalte scripturi, ramane tacut: acolo nu
# e o treapta, e doar o dependinta.
#
# ATENTIE: $env:PKMS_VAULT are prioritate. Daca nu e setat, Get-PkmsVault
# intoarce drumul REAL. Cine ruleaza pe o copie trebuie sa si-o declare, altfel
# lucreaza pe volt, crezand ca lucreaza pe copie.
# ---------------------------------------------------------------------------
if ($MyInvocation.InvocationName -ne '.') {
  $v = Get-PkmsVault
  $b = Get-PkmsBackup
  Write-Output "volt:   $v"
  Write-Output "backup: $b"
  if ($b) {
    Write-Output 'ambele la loc. nu s-a scris nimic.'
  } else {
    Write-Output 'BACKUP NU A FOST GASIT. comparatia cu backupul nu e posibila.'
    exit 1
  }
}