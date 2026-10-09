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