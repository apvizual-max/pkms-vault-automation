<#
.SYNOPSIS
    Alinierea PKMS, conditionata: VERIFICA intai, SCRIE doar daca exista nealiniere.

.DESCRIPTION
    MIERE 2026-10-22. Taskul PKMS-Aliniere ruleaza la 09:00, 15:00 si 22:00.
    Regula lui Popy: "nu rula alinierea daca nu e necesara" - unele zile nu se
    schimba nimic, si atunci nu trebuie lucrat in van.

    Cum se rezolva, masurat:
      PAS 1 (CENSUS): align-index.ps1 -CeVad. Modul de citire: NU scrie nimic -
        nici logul de aliniere, nici arhiva de indexe, nici un index. Iesirea
        are o linie machine-readable:
          "rezumat: N LIPSA - N CORUPT - N INCOMPLET - N NEALINIAT - N CONFORM - N nemodificate"
      PAS 2 (ACTIUNE): doar daca censusul a gasit ceva. align-index.ps1 in modul
        scriere rescrie DOAR folderele nealiniate, pe subarborii afectati. Nu
        reconstruiește tot arborele - asta face build-index.ps1, la cerere, dupa
        mutari in masa.
      PAS 3 (CONFIRMARE): census din nou. Daca mai exista nealiniere, iesirea e 1.

    De ce nu ruleaza build-index.ps1: build-index rescrie TOT arborele (2.616 de
    indexuri, ~74 s, fiecare rulare). E interventie, nu rutina. Interventia ramane
    la cerere.

    Iesire:
      0 - totul aliniat (fie era deja aliniat, fie a fost reparat acum)
      1 - au ramas nealinieri dupa reparație
      2 - censusul nu a putut fi citit: masuratoarea NU s-a facut (nu e "bine")
      4 - align-index.ps1 lipseste din motor

    Nu ruleaza build-index.ps1. Nu sterge, nu muta, nu rearanjeaza nimic.
#>
param([string]$Vault = '')

$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\paths.ps1"

if (-not $Vault) { $Vault = Get-PkmsVault }
$Vault = Normalize-PkmsPath $Vault
Assert-PkmsVaultReal -Vault $Vault -Cine 'aliniere-conditionala'

$align = Join-Path $PSScriptRoot 'align-index.ps1'
if (-not (Test-Path -LiteralPath $align -PathType Leaf)) {
    Write-Output "EROARE: align-index.ps1 lipseste din motor. Alinierea nu s-a putut face."
    exit 4
}

# Copilul ruleaza in proces separat, pentru un motiv masurat: align-index.ps1
# apeleaza 'exit', iar 'exit' intr-un script apelat cu '&' omoara si procesul
# parintelui. Daca l-am apela direct, pasul 2 (actiune) nu ar mai rula niciodata.
$psExe = Join-Path $PSHOME 'powershell.exe'

function Invoke-Census {
    param([switch]$Scrie)
    $argumente = @('-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-File', $align, '-Vault', $Vault)
    if (-not $Scrie) { $argumente += '-CeVad' }
    $raw = & $psExe @argumente 2>&1
    $cod = [int]$LASTEXITCODE
    $text = ($raw | Out-String)
    $linie = $null
    foreach ($l in ($text -split "`r?`n")) {
        if ($l -match '^\s*rezumat:') { $linie = $l; break }
    }
    $rez = [ordered]@{ Cod = $cod; Text = $text; Gasit = ($null -ne $linie); Lipsa = 0; Corupt = 0; Incomplet = 0; Nealiniat = 0; Conform = 0 }
    if ($linie) {
        foreach ($pereche in @(@('LIPSA', 'Lipsa'), @('CORUPT', 'Corupt'), @('INCOMPLET', 'Incomplet'), @('NEALINIAT', 'Nealiniat'), @('CONFORM', 'Conform'))) {
            $m = [regex]::Match($linie, '(?<!\d)(\d+)\s+' + [regex]::Escape($pereche[0]) + '\b')
            if ($m.Success) { $rez[$pereche[1]] = [int]$m.Groups[1].Value } else { $rez.Gasit = $false }
        }
    }
    return $rez
}

# ── PAS 1: CENSUS (nu scrie nimic) ──
$inceput = Get-Date
$census = Invoke-Census
if (-not $census.Gasit) {
    Write-Output "ALINIERE: censusul nu a putut fi citit. Masuratoarea nu s-a facut - asta NU e 'bine'."
    Write-Output ("DETALIU: cod={0}" -f $census.Cod)
    exit 2
}

$nealiniere = $census.Lipsa + $census.Corupt + $census.Incomplet + $census.Nealiniat
$durataCensus = [int]((Get-Date) - $inceput).TotalSeconds

if ($nealiniere -eq 0) {
    # NIMIC DE FACUT. Nicio scriere: nici log, nici arhiva, nici index.
    Write-Output ("ALINIERE: nimic de facut - {0} foldere CONFORM, 0 nealiniere. Nu s-a scris nimic. ({1}s)" -f $census.Conform, $durataCensus)
    exit 0
}

Write-Output ("ALINIERE: {0} nealiniere gasite (LIPSA {1} / CORUPT {2} / INCOMPLET {3} / NEALINIAT {4}) - reparam doar arborii afectati. ({5}s)" -f $nealiniere, $census.Lipsa, $census.Corupt, $census.Incomplet, $census.Nealiniat, $durataCensus)

# ── PAS 2: ACTIUNE (scrie doar ce e nealiniat) ──
$actiune = Invoke-Census -Scrie
$durataActiune = [int]((Get-Date) - $inceput).TotalSeconds

# ── PAS 3: CONFIRMARE ──
$confirmare = Invoke-Census
if (-not $confirmare.Gasit) {
    Write-Output "ALINIERE: confirmarea nu a putut fi citit. Masuratoarea nu s-a facut."
    exit 2
}
$ramase = $confirmare.Lipsa + $confirmare.Corupt + $confirmare.Incomplet + $confirmare.Nealiniat
$total = [int]((Get-Date) - $inceput).TotalSeconds

if ($ramase -eq 0) {
    Write-Output ("ALINIERE: reparat - {0} nealiniere au fost reparate, confirmare {1} CONFORM, 0 ramase. ({2}s)" -f $nealiniere, $confirmare.Conform, $total)
    exit 0
}

Write-Output ("ALINIERE: au ramas {0} nealiniere dupa reparație (LIPSA {1} / CORUPT {2} / INCOMPLET {3} / NEALINIAT {4}). ({5}s)" -f $ramase, $confirmare.Lipsa, $confirmare.Corupt, $confirmare.Incomplet, $confirmare.Nealiniat, $total)
exit 1
