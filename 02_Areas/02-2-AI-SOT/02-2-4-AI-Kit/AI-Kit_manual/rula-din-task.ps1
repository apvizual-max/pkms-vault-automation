<#
.SYNOPSIS
    Wrapper pentru automatizarile zilnice: astepta ca volumul sa fie montat, apoi rula scriptul.

.DESCRIPTION
    Măsurat 2026-10-19/20: la 23:04:40 taskul PKMS-Aliniere a pornit pe triggerul
    de LOGON si a esuat cu 2147942667 (ERROR_DIRECTORY). Calea din task era corecta
    (aceeasi ca la rularea manuala de verificare, care a iesit EXIT=0). Cauza: la
    logon, G: (DriveFS) poate fi inca nemontat — taskul porneste, calea de lucru
    nu exista, si procesul moare inainte sa ruleze ceva.

    Acest wrapper rezolva exact asta: astepta ca calea sa devina accesibila, apoi
    ruleaza scriptul si propaga codul lui de iesire.

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
$Vault    = 'G:\My Drive\GDrive-Second_Brain_PKMS'
$Manual   = Join-Path $Vault '02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_manual'
$Jurnal   = Join-Path $Manual 'raport-wrapper-task.log'
$script:Start = Get-Date

function Write-Jurnal([string]$Msg) {
    $lin = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Msg
    try { Add-Content -LiteralPath $Jurnal -Value $lin -Encoding UTF8 } catch { }
    Write-Output $lin
}

# ── 1. asteptam calea (viteza reala: 2 s) ──
$inceput = Get-Date
$asteptat = 0
while ($true) {
    if (Test-Path -LiteralPath $Manual -PathType Container) { break }
    $asteptat = [int]((Get-Date) - $inceput).TotalSeconds
    if ($asteptat -ge $AsteptareMaxima) {
        Write-Jurnal ("ABANDON: calea nu a devenit accesibila in {0}s -> {1}" -f $AsteptareMaxima, $Manual)
        exit 3
    }
    Start-Sleep -Seconds 2
}
if ($asteptat -gt 0) {
    Write-Jurnal ("calea a devenit accesibila dupa {0}s" -f $asteptat)
}

# ── 2. scriptul exista? ──
$calea = Join-Path $Manual $Script
if (-not (Test-Path -LiteralPath $calea -PathType Leaf)) {
    Write-Jurnal ("EROARE: scriptul nu exista -> {0}" -f $calea)
    exit 4
}

# ── 3. rulam, cu mediul corect ──
$env:PKMS_VAULT   = $Vault
$env:PKMS_BACKUP  = 'H:\Alex_Knowlege_Vault_BKUP_10-19-2026'
Write-Jurnal ("rulez {0}" -f $Script)

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
