<#
.SYNOPSIS
    Raport saptamanal de stare a PKMS: oglinda, indexurile, cotorul, regulile.

.DESCRIPTION
    MIERE 2026-10-22. Taskul PKMS-RaportSaptamanal ruleaza o data pe saptamana.
    Rolul lui: NU repara. Verifica si raporteaza starea de ansamblu, ca sa fie
    vizibil daca sistemul se degradeaza intre doua alinieri.

    Ce verifica:
      1. OGLINDA  - local <-> Google Drive Cloud (verifica-oglinda.ps1)
      2. INDEXURI - structura completa de indexuri, aliniata (align-index -CeVad)
      3. SCHEMA   - indexurile pe schema §18.1 (verifica-schema.ps1)
      4. REGULI   - denumire + encoding scripturi (lint.ps1)
      5. VAULT    - masura (fisiere, octeti) (health-check.ps1)
      6. COTOR    - cele 4 documente din radacina + fiecare folder de nivel 1
                    trebuie sa fie mentionate in COTOR.md

    Iesire:
      0 - totul in ordine
      1 - s-a gasit ceva in afara de ordine
      2 - o masuratoare nu s-a putut face (nu e "bine", e necunoscut)

    Scrie raportul in _SYSTEM\rapoarte\ (gitignorat). Urmarea: indexul folderului
    _SYSTEM\rapoarte devine nealiniat pana la urmatoarea trecere a taskului
    PKMS-Aliniere - care il repara, pe acel arbore doar. E comportamentul dorit.
#>
param([string]$Vault = '')

$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\paths.ps1"

if (-not $Vault) { $Vault = Get-PkmsVault }
$Vault = Normalize-PkmsPath $Vault
Assert-PkmsVaultReal -Vault $Vault -Cine 'raport-saptamanal'

$errors = New-Object System.Collections.Generic.List[string]
$warn   = New-Object System.Collections.Generic.List[string]
$ok     = New-Object System.Collections.Generic.List[string]
$linii  = New-Object System.Collections.Generic.List[string]

$psExe = Join-Path $PSHOME 'powershell.exe'
$inceput = Get-Date

function Invoke-Porta {
    param([string]$Nume, [string[]]$Argumente)
    $script = Join-Path $PSScriptRoot $Nume
    if (-not (Test-Path -LiteralPath $script -PathType Leaf)) {
        return [pscustomobject]@{ Cod = 99; Text = ("LIPSA: " + $script); Exista = $false }
    }
    $raw = & $psExe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $script @Argumente 2>&1
    return [pscustomobject]@{ Cod = [int]$LASTEXITCODE; Text = ($raw | Out-String); Exista = $true }
}

function Get-NumDinText {
    param([string]$Text, [string]$Model)
    $m = [regex]::Match($Text, $Model)
    if ($m.Success) { return [int]$m.Groups[1].Value }
    return -1
}

$linii.Add("=== RAPORT SAPTAMINAL PKMS ===")
$linii.Add(("data: {0}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$linii.Add(("vault: {0}" -f $Vault))
$linii.Add("")

# ── 1. OGLINDA ──
$linii.Add("--- 1. OGLINDA LOCAL <-> GOOGLE DRIVE CLOUD ---")
$ogl = Invoke-Porta 'verifica-oglinda.ps1' @('-Vault', $Vault)
if (-not $ogl.Exista) {
    $errors.Add("verifica-oglinda.ps1 lipseste din motor. Oglinda nu a fost masurata.")
} else {
    $div = Get-NumDinText $ogl.Text '(?m)^DIVERGENTA LOCAL<->CLOUD:\s*(\d+)'
    $lat = Get-NumDinText $ogl.Text '(?m)^LATENTA LOCAL<->CLOUD:\s*(\d+)'
    $mas = [regex]::Match($ogl.Text, '(?m)^MASURAT OGLINDA:\s*(\S+)')
    $masurat = if ($mas.Success) { $mas.Groups[1].Value } else { 'NU' }
    if ($div -lt 0 -or $lat -lt 0) {
        $errors.Add("Oglinda: randul de rezultat nu a putut fi citit. Masuratoarea nu s-a facut.")
    } else {
        if ($div -gt 0) { $errors.Add("Oglinda: $div fisiere DIVERGENTE intre local si cloud.") }
        else { $ok.Add("oglinda local<->cloud: 0 divergente") }
        if ($lat -gt 0) { $warn.Add("Oglinda: $lat fisiere in latenta (in coada de incarcare). Acceptabil pentru o oglinda vie.") }
        else { $ok.Add("oglinda local<->cloud: 0 in latenta") }
        if ($masurat -ne 'da') { $errors.Add("Oglinda: masuratoarea nu s-a facut (MASURAT OGLINDA: $masurat).") }
    }
    $linii.Add(("  divergenta: {0} | latenta: {1} | masurat: {2} | cod: {3}" -f $div, $lat, $masurat, $ogl.Cod))
}
$linii.Add("")

# ── 2. INDEXURI (census, nu scrie) ──
$linii.Add("--- 2. STRUCTURA DE INDEXURI (census, nu scrie nimic) ---")
$al = Invoke-Porta 'align-index.ps1' @('-Vault', $Vault, '-CeVad')
$rezumat = $null
if (-not $al.Exista) {
    $errors.Add("align-index.ps1 lipseste din motor. Indexurile nu au fost masurate.")
} else {
    foreach ($l in ($al.Text -split "`r?`n")) { if ($l -match '^\s*rezumat:') { $rezumat = $l; break } }
    if (-not $rezumat) {
        $errors.Add("Indexuri: randul 'rezumat' nu a putut fi citit. Masuratoarea nu s-a facut.")
    } else {
        $lipsa = Get-NumDinText $rezumat '(?<!\d)(\d+)\s+LIPSA\b'
        $corupt = Get-NumDinText $rezumat '(?<!\d)(\d+)\s+CORUPT\b'
        $incomplet = Get-NumDinText $rezumat '(?<!\d)(\d+)\s+INCOMPLET\b'
        $nealiniat = Get-NumDinText $rezumat '(?<!\d)(\d+)\s+NEALINIAT\b'
        $conform = Get-NumDinText $rezumat '(?<!\d)(\d+)\s+CONFORM\b'
        $total = $lipsa + $corupt + $incomplet + $nealiniat
        if ($total -gt 0) {
            $errors.Add("Indexuri: $total nealiniere (LIPSA $lipsa / CORUPT $corupt / INCOMPLET $incomplet / NEALINIAT $nealiniat).")
        } else {
            $ok.Add("indexuri: $conform CONFORM, 0 nealiniere")
        }
        $linii.Add(("  LIPSA {0} | CORUPT {1} | INCOMPLET {2} | NEALINIAT {3} | CONFORM {4}" -f $lipsa, $corupt, $incomplet, $nealiniat, $conform))
    }
}
$linii.Add("")

# ── 3. SCHEMA ──
$linii.Add("--- 3. SCHEMA §18.1 A INDEXURILOR ---")
$sc = Invoke-Porta 'verifica-schema.ps1' @('-Vault', $Vault)
if (-not $sc.Exista) {
    $errors.Add("verifica-schema.ps1 lipseste din motor. Schema nu a fost masurata.")
} elseif ($sc.Cod -ne 0) {
    $m = [regex]::Match($sc.Text, '(?m)^REZULTAT:\s*(.+)$')
    $detaliu = if ($m.Success) { $m.Groups[1].Value.Trim() } else { ("cod " + $sc.Cod) }
    $errors.Add("Schema: $detaliu")
} else {
    $m = [regex]::Match($sc.Text, '(?m)^REZULTAT:\s*(.+)$')
    $detaliu = if ($m.Success) { $m.Groups[1].Value.Trim() } else { 'cod 0' }
    $ok.Add("schema: $detaliu")
    $linii.Add(("  $detaliu"))
}
$linii.Add("")

# ── 4. REGULI (lint) ──
$linii.Add("--- 4. REGULI DE DENUMIRE SI ENCODING (lint) ---")
$li = Invoke-Porta 'lint.ps1' @('-Vault', $Vault)
if (-not $li.Exista) {
    $errors.Add("lint.ps1 lipseste din motor. Regulile nu au fost masurate.")
} else {
    $m = [regex]::Match($li.Text, '(?m)^REZULTAT:\s*(\d+)\s+erori,\s*(\d+)\s+aten')
    $ne = if ($m.Success) { [int]$m.Groups[1].Value } else { -1 }
    $na = if ($m.Success) { [int]$m.Groups[2].Value } else { -1 }
    if ($ne -lt 0) {
        $errors.Add("Lint: randul de rezultat nu a putut fi citit. Masuratoarea nu s-a facut.")
    } else {
        if ($ne -gt 0) { $errors.Add("Lint: $ne erori de regula.") } else { $ok.Add("lint: 0 erori, $na atentioni") }
        if ($na -gt 0) { $warn.Add("Lint: $na atentioni (fapte, nu abateri).") }
        $linii.Add(("  erori: {0} | atentioni: {1} | cod: {2}" -f $ne, $na, $li.Cod))
    }
}
$linii.Add("")

# ── 5. VAULT (masura) ──
$linii.Add("--- 5. MASURA VAULTULUI ---")
$hc = Invoke-Porta 'health-check.ps1' @('-Vault', $Vault)
if (-not $hc.Exista) {
    $errors.Add("health-check.ps1 lipseste din motor. Masura nu s-a facut.")
} else {
    $m = [regex]::Match($hc.Text, '(?m)^\s*masura:\s*(.+)$')
    $masura = if ($m.Success) { $m.Groups[1].Value.Trim() } else { 'NU CITITA' }
    $dm = [regex]::Match($hc.Text, '(?m)diferenta\s*(\d+)')
    $diferenta = if ($dm.Success) { [int]$dm.Groups[1].Value } else { -1 }
    if ($masura -eq 'NU CITITA') {
        $errors.Add("Vault: masura nu a putut fi citita. Masuratoarea nu s-a facut.")
    } else {
        $ok.Add("vault: $masura")
        $linii.Add(("  $masura"))
    }
}
$linii.Add("")

# ── 6. COTOR ──
$linii.Add("--- 6. COTOR (documentatia de la radacina) ---")
$cotoruri = @('COTOR.md', 'INDEX CENTRAL.md', 'MANUAL DE NAVIGARE - cotor.md', 'AGENTS.md')
$lipsaCotor = @()
foreach ($c in $cotoruri) {
    $p = Join-Path $Vault $c
    if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { $lipsaCotor += $c }
    elseif ((Get-Item -LiteralPath $p -Force).Length -eq 0) { $lipsaCotor += ($c + ' (gol)') }
}
if ($lipsaCotor.Count -gt 0) {
    $errors.Add(("Cotor: documentatie lipsa sau goala la radacina - " + ($lipsaCotor -join ', ')))
} else {
    $ok.Add("cotor: cele 4 documente de la radacina exista si nu sunt goale")
}
$cotorPath = Join-Path $Vault 'COTOR.md'
if (Test-Path -LiteralPath $cotorPath -PathType Leaf) {
    $textCotor = [System.IO.File]::ReadAllText($cotorPath)
    $neMentionate = @()
    foreach ($d in (Get-ChildItem -LiteralPath $Vault -Directory -Force -ErrorAction SilentlyContinue)) {
        if ($d.Name.StartsWith('.')) { continue }
        if (-not $textCotor.Contains($d.Name)) { $neMentionate += $d.Name }
    }
    if ($neMentionate.Count -gt 0) {
        $errors.Add(("Cotor: foldere de nivel 1 nementionate in COTOR.md - " + ($neMentionate -join ', ')))
    } else {
        $ok.Add("cotor: toate folderele de nivel 1 sunt mentionate in COTOR.md")
    }
}
$linii.Add("")

# ── raport ──
$linii.Add("--- REZUMAT ---")
foreach ($o in $ok)     { $linii.Add("  OK      $o") }
foreach ($w in $warn)   { $linii.Add("  ATENTIE $w") }
foreach ($e in $errors) { $linii.Add("  EROARE  $e") }
$linii.Add("")
$durata = [int]((Get-Date) - $inceput).TotalSeconds
$linii.Add(("durata: {0}s" -f $durata))
$linii.Add(("REZULTAT: {0} erori, {1} atentioni" -f $errors.Count, $warn.Count))
$verdict = if ($errors.Count -gt 0) { 'NEIN ORDINE' } else { 'IN ORDINE' }
$linii.Add(("VERDICT: {0}" -f $verdict))

$textRaport = ($linii -join "`r`n") + "`r`n"
Write-Output $textRaport

$rapoarte = Join-Path $Vault '_SYSTEM\rapoarte'
try {
    if (-not (Test-Path -LiteralPath $rapoarte -PathType Container)) { New-Item -ItemType Directory -Path $rapoarte -Force | Out-Null }
    $stamp = Get-Date -Format 'yyyy-MM-dd_HH-mm'
    $arhiva = Join-Path $rapoarte ('raport-saptamanal-' + $stamp + '.txt')
    $ultima = Join-Path $rapoarte 'raport-saptamanal-ultima.txt'
    $enc = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($arhiva, $textRaport, $enc)
    [System.IO.File]::WriteAllText($ultima, $textRaport, $enc)
    Write-Output ("raport scris: {0}" -f $arhiva)
    Write-Output ("raport scris: {0}" -f $ultima)
} catch {
    Write-Output ("ATENTIE: raportul NU a putut fi scris: " + $_.Exception.Message)
}

if ($errors.Count -gt 0) { exit 1 } else { exit 0 }
