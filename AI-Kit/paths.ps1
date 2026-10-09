<#
  PKMS paths.ps1 - descopera singure backupul si locatiile canonice.
  se include din toate scripturile, ca numele sa nu mai fie scris tare in 4 locuri.

  de ce: backupul a fost redenumit o data (CopyBACKUP -> Backup - 10-08-2026)
  si scripturile cu numele scris tare au cazut. Acum il cauta.
#>

function Get-PkmsVault {
  if ($env:PKMS_VAULT -and (Test-Path $env:PKMS_VAULT)) { return $env:PKMS_VAULT }
  return 'D:\Alex_Knowlege_Vault'
}

function Get-PkmsBackup {
  if ($env:PKMS_BACKUP -and (Test-Path $env:PKMS_BACKUP)) { return $env:PKMS_BACKUP }

  # numele vechi, daca exista
  $legacy = 'D:\Alex_Knowlege_Vault - CopyBACKUP'
  if (Test-Path $legacy) { return $legacy }

  # cauta in radacina lui D: orice copie a voltului
  $candidates = @(
    Get-ChildItem -LiteralPath 'D:\' -Directory -Force -EA SilentlyContinue |
      Where-Object { $_.Name -match '^(Alex_Knowlege_Vault)\s*[-_].*' -and $_.FullName -ne (Get-PkmsVault) } |
      Sort-Object LastWriteTime -Desc
  )
  if ($candidates.Count -gt 0) { return $candidates[0].FullName }
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