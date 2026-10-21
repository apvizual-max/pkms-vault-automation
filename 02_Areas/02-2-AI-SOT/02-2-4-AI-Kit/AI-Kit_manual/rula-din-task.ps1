<#
.SYNOPSIS
    Wrapper pentru automatizarile zilnice: astepta ca volumul sa fie montat, apoi rula scriptul.

.DESCRIPTION
    Masurat 2026-10-19/20: la 23:04:40 taskul PKMS-Aliniere a pornit pe triggerul
    de LOGON si a esuat cu 2147942667 (ERROR_DIRECTORY). Calea din task era corecta
    (aceeasi ca la rularea manuala de verificare, care a iesit EXIT=0). Cauza: la
    logon, G: (DriveFS) poate fi inca nemontat — taskul porneste, calea de lucru
    nu exista, si procesul moare inainte sa ruleze ceva.

    Acest wrapper rezolva exact asta: astepta ca calea sa devina accesibila, apoi
    ruleaza scriptul si propaga codul lui de iesire.

    MUTARE 2026-10-21 (Decizia 1): reperul nu mai e o copie locala pe D:/H:, ci
    oglinda Google Drive Cloud. De aici:
      - reperul se rezolva DINAMIC, din shortcutul pe care DriveFS il creeaza
        ('G:\My Drive.lnk' -> 'E:\Google\GDrive', masurat). Calea 'G:\My Drive\...'
        NU exista pe aceasta masina: 'G:\My Drive' nici nu e director, doar
        shortcutul. Scris tare, ramanea o cale moarta — care era chiar cauza
        repornirilor inutile ale DriveFS.
      - PKMS_BACKUP se seteaza DOAR daca backupul exista efectiv. Pe o cale
        moarta, env-ul ar trimite lantul catre un reper care nu exista.

    NU SCHIMBA nimic in afara vaultului. Nu sterge, nu muta, nu rearanjeaza.

.PARAMETER Script
    Numele scriptului din AI-Kit_manual (ex: align-index.ps1). Implicit: argumentul 1.

.PARAMETER AsteptareMaxima
    Cate secunde astepta calea. Implicit: 300 (5 minute).

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File rula-din-task.ps1 align-index.ps1
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Script = 'align-index.ps1',
    [int]$AsteptareMaxima = 300
)

$ErrorActionPreference = 'Stop'

# ── reperul: rezolvat DINAMIC ──
# Ordinea: (1) shortcutul pe care DriveFS il creeaza — urmeaza automat orice
# remontare; (2) calea cunoscuta pe E:. 'G:\My Drive\...' e ultima, ca
# alternativa, NU ca implicit: masurat ca nu exista.
$VaultCandidates = New-Object System.Collections.Generic.List[string]
try {
    $sh = New-Object -ComObject WScript.Shell
    foreach ($lnk in @('G:\My Drive.lnk', (Join-Path $env:USERPROFILE 'Desktop\My Drive.lnk'))) {
        try {
            if ([System.IO.File]::Exists($lnk)) {
                $t = $sh.CreateShortcut($lnk).TargetPath
                if ($t) { $VaultCandidates.Add((Join-Path $t 'GDrive-Second_Brain_PKMS')) }
            }
        } catch { }
    }
} catch { }
$VaultCandidates.Add('E:\Google\GDrive\GDrive-Second_Brain_PKMS')
$VaultCandidates.Add('G:\My Drive\GDrive-Second_Brain_PKMS')

$ManualRel = '02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_manual'

function Get-VaultAccesibil {
    foreach ($c in $VaultCandidates) {
        $m = Join-Path $c $ManualRel
        if (Test-Path -LiteralPath $m -PathType Container) { return $c }
    }
    return $null
}

$script:Start = Get-Date
$Vault = $null
$Manual = ''
$Jurnal = ''

function Write-Jurnal([string]$Msg) {
    $lin = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Msg
    try { if ($Jurnal) { Add-Content -LiteralPath $Jurnal -Value $lin -Encoding UTF8 } } catch { }
    Write-Output $lin
}

# ── 1. asteptam calea (viteza reala: 2 s) ──
$inceput = Get-Date
$asteptat = 0
while ($true) {
    $Vault = Get-VaultAccesibil
    if ($Vault) { break }
    $asteptat = [int]((Get-Date) - $inceput).TotalSeconds
    if ($asteptat -ge $AsteptareMaxima) {
        Write-Jurnal ("ABANDON: calea nu a devenit accesibila in {0}s. Cautat in: {1}" -f $AsteptareMaxima, ($VaultCandidates -join ' | '))
        exit 3
    }
    Start-Sleep -Seconds 2
}
$Manual = Join-Path $Vault $ManualRel
$Jurnal = Join-Path $Manual 'raport-wrapper-task.log'
if ($asteptat -gt 0) {
    Write-Jurnal ("calea a devenit accesibila dupa {0}s -> {1}" -f $asteptat, $Vault)
}

# ── 2. scriptul exista? ──
$calea = Join-Path $Manual $Script
if (-not (Test-Path -LiteralPath $calea -PathType Leaf)) {
    Write-Jurnal ("EROARE: scriptul nu exista -> {0}" -f $calea)
    exit 4
}

# ── 3. rulam, cu mediul corect ──
$env:PKMS_VAULT   = $Vault
# Backupul local e FALLBACK (Decizia 1), nu reperul. Se anunta doar daca
# EXISTA: o cale moarta in env e mai rea decat o variabila goala, pentru ca
# lantul ar raporta ca are reper cand nu are.
$backupCandidat = 'H:\Alex_Knowlege_Vault_BKUP_10-19-2026'
if (Test-Path -LiteralPath $backupCandidat) {
    $env:PKMS_BACKUP = $backupCandidat
    Write-Jurnal ("rulez {0} (reper: oglinda cloud; backup local disponibil ca fallback)" -f $Script)
} else {
    $env:PKMS_BACKUP = ''
    Write-Jurnal ("rulez {0} (reper: oglinda cloud; backup local absent, fallback indisponibil)" -f $Script)
}

try {
    & powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $calea
    $cod = $LASTEXITCODE
} catch {
    Write-Jurnal ("EXCEPTIE: {0}" -f $_.Exception.Message)
    exit 5
}

$durata = [int]((Get-Date) - $script:Start).TotalSeconds
Write-Jurnal ("{0} terminat, cod={1}, durata={2}s" -f $Script, $cod, $durata)
exit $cod
