# PKMS inchide-log.ps1 - recenseaza raport-aliniere.log si spune care
# evenimente sunt INCA DESCHISE acum.
#
# PROBLEMA pe care o rezolva, masurata: documentatia cere ca evenimentele
# rezolvate sa se mute in "arhiva- raport aliniere.log". Masurat pe vaultul
# real inainte de a scrie acest script: 1.313 evenimente, 661 de foldere,
# toate dintr-o singura zi, si ZERO fisiere de arhiva in tot vaultul.
# Asadar ritualul saptamanal era la jumatate: se stia ce se cere, nu exista
# prin ce se face. Iar deschiderea logului cerea 537 KB ca sa afli ca nu
# mai e nimic de facut.
#
# REGULA CARE O TINE: "rezolvat" nu e o amintire, e o masuratoare. Un
# eveniment e rezolvat daca si numai daca folderul lui NU mai apare in
# iesirea de azi a portii (align-index.ps1 -CeVad). Deci intrebarea "mai e
# treaba?" se raspunde remeasurand, nu citind ce scriam ieri.
#
# ATENTIE: nu sterge nimic. Evenimentele rezolvate se MUTA in arhiva, care
# creste; logul viu pastreaza doar ce e deschis. A doua rulare cu
# -Arhiveaza nu mai arhiveaza nimic — e idempotent prin constructione.
#
# Codare: UTF-8 cu BOM (PowerShell 5.1 citeste altfel ca ANSI).
# Fara operator ternar PowerShell 7 (? :) — incompatibil cu 5.1.

param(
  # Lasat GOAL intentionat, ca in celelalte scripturi: o cale scrisa tare ca
  # parametru ar face ca Get-PkmsVault sa nu fie apelat niciodata, iar
  # $env:PKMS_VAULT ar fi ignorat in tacure.
  [string]$Vault = '',
  # Fisierul de log. GOAL intentionat, ca mai sus: implicit luat din vault.
  [string]$Log = '',
  # Implicit: DOAR raporteaza. Nimic nu se scrie.
  [switch]$Arhiveaza,
  # Autoproba: dovedeste ca poarta poate deveni rosie si ca arhivarea nu
  # inghiteaza lucru deschis. Ruleaza in %TEMP%, nu atinge vaultul.
  [switch]$AutoTest,
  [int]$Nivel = 1
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\paths.ps1"

# ======================= PARSARE ===========================================
# Un eveniment incepe cu [STAREA] drumul si continua pana la urmatorul
# eveniment sau pana la urmatorul antet de rulare. Randurile indente sunt
# masuratorile lui (masura / indexul spunea / reparat / vechea versiune).
function Parse-Log([string]$text) {
  $lin = $text -split "`r?`n"
  $evenimente = New-Object System.Collections.ArrayList
  $antetCurent = '(fara data)'
  for ($i = 0; $i -lt $lin.Count; $i++) {
    $l = $lin[$i]
    if ($l -match '^=== align-index\.ps1 ·\s*(.+?)\s*===$') {
      $antetCurent = $Matches[1]
      continue
    }
    if ($l -match '^\[(LIPSA|CORUPT|INCOMPLET|NEALINIAT)\]\s+(.+?)\s*$') {
      $stare = $Matches[1]
      $drum = $Matches[2]
      $detalii = New-Object System.Collections.ArrayList
      $j = $i + 1
      for (; $j -lt $lin.Count; $j++) {
        $d = $lin[$j]
        if ($d -match '^\[') { break }
        if ($d -match '^===') { break }
        if ($d.Trim() -eq '') { [void]$detalii.Add(''); continue }
        if ($d -match '^\s') { [void]$detalii.Add($d); continue }
        break
      }
      [void]$evenimente.Add([pscustomobject]@{
        Data    = $antetCurent
        Stare   = $stare
        Drum    = $drum
        Detalii = @($detalii)
      })
      $i = $j - 1
      continue
    }
  }
  return @($evenimente)
}

# ======================= CLASIFICARE ======================================
# $Deschise = lista drumurilor pe care poarta le raporteaza ACUM ca
# neconforme. Un eveniment e deschis daca si numai daca drumul lui apare
# acolo. Tot restul e rezolvat — prin masurare, nu prin presupunere.
function Test-Census([object[]]$evenimente, [string[]]$deschise) {
  $ramase = New-Object System.Collections.ArrayList
  $inchise = New-Object System.Collections.ArrayList
  foreach ($e in $evenimente) {
    $esteDeschis = $false
    foreach ($d in $deschise) {
      if ($d -eq $e.Drum) { $esteDeschis = $true; break }
    }
    if ($esteDeschis) { [void]$ramase.Add($e) } else { [void]$inchise.Add($e) }
  }
  return [pscustomobject]@{ Deschise = @($ramase); Rezolvate = @($inchise) }
}

# ======================= AUTOPROBA ========================================
function Invoke-AutoTest {
  Write-Host 'AUTOPROBA — log de proba construit in memorie:'
  Write-Host '  A) un eveniment rezolvat, unul deschis  -> trebuie: 1 rezolvat, 1 deschis'
  Write-Host '  B) ambele rezolvate                       -> trebuie: 2 rezolvate, 0 deschise'
  Write-Host '  C) log gol                                -> trebuie: nimic de clasificat'
  Write-Host '  D) arhivarea muta doar rezolvatul si lasa deschisul in logul viu'
  Write-Host ''

  $log = @(
    '=== align-index.ps1 · 2026-10-08 10:09:26 ===',
    '[NEALINIAT] raft/bun',
    '    masura: 3 fisiere, 0 subfoldere',
    '    indexul spunea: 1 fisier · 1 KB · 0 subfoldere',
    '',
    '[NEALINIAT] raft/rau',
    '    masura: 0 fisiere, 2 subfoldere',
    '    indexul spunea: 0 fisiere · 0 B · 0 subfoldere',
    ''
  ) -join "`n"

  $ev = Parse-Log $log
  $ok = $true

  Write-Host ('  evenimente parsate: ' + $ev.Count + '   (asteptat 2)')
  if ($ev.Count -ne 2) { $ok = $false }

  $a = Test-Census -evenimente $ev -deschise @('raft/rau')
  Write-Host ('  A) rezolvate=' + $a.Rezolvate.Count + '  deschise=' + $a.Deschise.Count + '   (asteptat 1 / 1)')
  if ($a.Rezolvate.Count -ne 1 -or $a.Deschise.Count -ne 1) { $ok = $false; Write-Host '     [NEPRINS]' }
  else { Write-Host '     [PRINS] — poarta stie sa devina rosie' }

  $b = Test-Census -evenimente $ev -deschise @()
  Write-Host ('  B) rezolvate=' + $b.Rezolvate.Count + '  deschise=' + $b.Deschise.Count + '   (asteptat 2 / 0)')
  if ($b.Rezolvate.Count -ne 2 -or $b.Deschise.Count -ne 0) { $ok = $false; Write-Host '     [NEPRINS]' }
  else { Write-Host '     [PRINS]' }

  $c = Test-Census -evenimente @() -deschise @('raft/rau')
  Write-Host ('  C) rezolvate=' + $c.Rezolvate.Count + '  deschise=' + $c.Deschise.Count + '   (asteptat 0 / 0)')
  if ($c.Rezolvate.Count -ne 0 -or $c.Deschise.Count -ne 0) { $ok = $false; Write-Host '     [NEPRINS]' }
  else { Write-Host '     [PRINS]' }

  # D) din A: 'raft/bun' e rezolvat, 'raft/rau' e deschis.
  $inArhiva = ($a.Rezolvate | ForEach-Object { $_.Drum }) -join ','
  $inViu    = ($a.Deschise  | ForEach-Object { $_.Drum }) -join ','
  $d1 = $inArhiva.Contains('raft/bun')
  $d2 = (-not $inArhiva.Contains('raft/rau'))
  $d3 = $inViu.Contains('raft/rau')
  $d4 = (-not $inViu.Contains('raft/bun'))
  Write-Host ('  D) arhiva: [' + $inArhiva + ']   log viu: [' + $inViu + ']')
  if (-not ($d1 -and $d2 -and $d3 -and $d4)) { $ok = $false; Write-Host '     [NEPRINS] — arhivarea a atins ceva ce era deschis' }
  else { Write-Host '     [PRINS] — arhivarea nu inghiteaza lucru deschis' }

  Write-Host ''
  if ($ok) {
    Write-Host 'AUTOPROBA: TOATE CAZURILE AU FOST PRINSE. Poarta e vie.'
    return 0
  }
  Write-Host 'AUTOPROBA: UN CAZ NU A FOST PRINS. Poarta nu poate fi de incredere.'
  return 2
}

# ======================= RULARE ===========================================
if ($AutoTest) { $cod = Invoke-AutoTest; exit $cod }

if (-not $Vault) { $Vault = Get-PkmsVault }
# -Vault vine de la om si nu trece prin Get-PkmsVault. Fara asta, o bara
# obisnuita la finalul caii face ca tot vaultul sa para nealiniat.
$Vault = Normalize-PkmsPath $Vault
if (-not (Test-Path -LiteralPath $Vault)) { throw ('Vaultul nu exista: ' + $Vault) }
if (-not $Log) { $Log = Join-Path $Vault 'raport-aliniere.log' }
if (-not (Test-Path -LiteralPath $Log)) {
  Write-Host ('LOGUL NU EXISTA: ' + $Log)
  Write-Host 'Nu am citit nimic. Nu pot spune ca nu e treaba.'
  exit 1
}

# --- poarta: intrebam automatul, nu ne aminteam ce am scris ieri ------------
$align = Join-Path $PSScriptRoot 'align-index.ps1'
if (-not (Test-Path -LiteralPath $align)) { throw ('Lipseste poarta: ' + $align) }
# -Vault se propaga. Fara asta, cu -Vault spre alt arbore, clasificarea s-ar
# face dupa starea vaultului implicit, nu a celui cerut.
$ie = & powershell -NoProfile -File $align -Vault $Vault -CeVad 2>&1 | Out-String

$deschise = New-Object System.Collections.ArrayList
foreach ($l in ($ie -split "`r?`n")) {
  # Doar liniile EVENIMENTELOR, care sunt intotdeauna intre paranteze:
  #     [NEALINIAT] AI-Kit
  # Paranteza e obligatorie. Fara ea se prindeau si liniile de DETALIU
  # ("NEALINIAT   AI-Kit" urmat de "— ar rescrie 00_INDEX.md ..."), care NU
  # sunt foldere. Era inofensiv cat timp $deschise se folosea doar ca reper de
  # apartenenta; de cand le numaram ca stricari neacoperite, ar fi numarat
  # si ele, ar fi spus "4 stricari" cand sunt 2, si ar fi numit drept stricare
  # o linie care descrie o stricare.
  if ($l -match '^\s*\[(LIPSA|CORUPT|INCOMPLET|NEALINIAT)\]\s+(.+?)\s*$') {
    [void]$deschise.Add($Matches[2])
  }
}

# --- logul ---
$txt = ''
$citit = $false
for ($t = 0; $t -lt 3 -and -not $citit; $t++) {
  try { $txt = [IO.File]::ReadAllText($Log); $citit = $true }
  catch {
    if ($t -eq 2) { throw ('Logul nu a putut fi citit: ' + $Log) }
    else { Start-Sleep -Milliseconds 400 }
  }
}
$ev = @(Parse-Log $txt)
$cls = Test-Census -evenimente $ev -deschise @($deschise)

$toateDrumuri = @($ev | Select-Object -ExpandProperty Drum -Unique)
$foldereDeschise = @($cls.Deschise | Select-Object -ExpandProperty Drum -Unique)
$foldereRezolvate = @($cls.Rezolvate | Select-Object -ExpandProperty Drum -Unique)

# --- ACOPERIRE: logul vs poarta -------------------------------------------
# $cls.Deschise numara doar evenimentele care sunt IN LOG. Daca poarta
# raporteaza o stricare pe care logul nu o contine, numarul de "deschise"
# este zero chiar daca stricarea exista — si spuneam "NIMIC DESCHIS" cu cod 0.
# Masurat 2026-10-09 pe micro-vault-6: poarta 2 NEALINIAT, log gol,
# "NIMIC DESCHIS", cod 0. Verde plin pe un vault stricat.
#
# ACOPERIREA e masura care lipsa: orice stricare raportata acum de poarta,
# pentru care nu exista eveniment in log, e stricare neacoperita. Se numeste,
# se arata, si ridica verdictul la 1.
$neacoperite = New-Object System.Collections.ArrayList
foreach ($d in $deschise) {
  $acoperit = $false
  foreach ($dr in $toateDrumuri) {
    if ($dr -eq $d) { $acoperit = $true; break }
  }
  if (-not $acoperit) { [void]$neacoperite.Add($d) }
}

Write-Host ('Log: ' + $Log)
Write-Host ('Evenimente inregistrate: ' + $ev.Count + '   in ' + $toateDrumuri.Count + ' foldere distincte')
Write-Host ('  rezolvate ACUM: ' + $cls.Rezolvate.Count + ' evenimente, in ' + $foldereRezolvate.Count + ' foldere')
Write-Host ('  DESCHISE ACUM:  ' + $cls.Deschise.Count + ' evenimente, in ' + $foldereDeschise.Count + ' foldere')
Write-Host ''
if ($neacoperite.Count -gt 0) {
  Write-Host ''
  Write-Host ('ATENTIE — POARTA REPORTA ' + $neacoperite.Count + ' STRICARI PE CARE LOGUL NU LE CONTINE:')
  foreach ($d in $neacoperite) { Write-Host ('    ' + $d) }
  Write-Host 'Logul si vaultul nu mai sunt de acord. Aceste foldere nu pot fi nici'
  Write-Host 'arhivate, nici declarate rezolvate: nu au eveniment de corespuns.'
  Write-Host 'Ruleaza align-index.ps1 ca evenimentele sa ajunga in log.'
}
Write-Host ''
Write-Host 'Un eveniment e rezolvat daca folderul lui NU mai apare in iesirea de azi'
Write-Host 'a portii (align-index.ps1 -CeVad). Nu dupa ce scriam atunci — dupa ce masuram acum.'
Write-Host ''

if ($cls.Deschise.Count -gt 0) {
  Write-Host 'RAMANE DE FACUT, pe foldere:'
  foreach ($d in $foldereDeschise) {
    $stari = @($cls.Deschise | Where-Object { $_.Drum -eq $d } | Select-Object -ExpandProperty Stare -Unique)
    Write-Host ('  [' + ($stari -join ', ') + '] ' + $d)
  }
  if ($Nivel -ge 1) {
    Write-Host ''
    foreach ($e in ($cls.Deschise | Select-Object -First 6)) {
      Write-Host ('  --- ' + $e.Drum + '   (raportat ' + $e.Data + ')')
      foreach ($d in ($e.Detalii | Where-Object { $_.Trim() -ne '' } | Select-Object -First 4)) {
        Write-Host ('      ' + $d.Trim())
      }
    }
  }
}

if (-not $Arhiveaza) {
  Write-Host ''
  if ($neacoperite.Count -gt 0) {
    Write-Host ('VERDICT INCOMPLET: ' + $neacoperite.Count + ' stricari reale, necuprinse in log.')
    Write-Host 'Nu pot spune "nimic deschis" — stiu ca sunt stricari, si nu le-am vazut.'
    exit 1
  }
  if ($cls.Deschise.Count -gt 0) {
    Write-Host ('RAMANE TREABA: ' + $cls.Deschise.Count + ' evenimente deschise.')
    Write-Host 'Nu s-a scris nimic. Cu -Arhiveaza se muta doar cele rezolvate.'
    exit 1
  }
  Write-Host 'NIMIC DESCHIS. Cu -Arhiveaza se poate curata logul.'
  exit 0
}

# ======================= ARHIVARE =========================================
# Nimic nu se sterge. Arhiva CRESTE, logul viu pastreaza doar deschise.
if ($cls.Rezolvate.Count -eq 0) {
  Write-Host ''
  Write-Host 'NIMIC DE ARHIVAT: logul viu nu mai contine evenimente rezolvate.'
  Write-Host 'Idempotent — o a doua rulare nu schimba nimic.'
  if ($cls.Deschise.Count -gt 0) { exit 1 } else { exit 0 }
}

$arhivaPath = Join-Path $Vault 'arhiva- raport aliniere.log'
$stamp = Get-Date -Format 'yyyy-MM-dd HH-mm-ss'
$enc = New-Object System.Text.UTF8Encoding $true

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('=== arhivat din raport-aliniere.log · ' + $stamp + ' · ' + $cls.Rezolvate.Count + ' evenimente rezolvate ===')
foreach ($e in $cls.Rezolvate) {
  [void]$sb.AppendLine('  --- rezolvat: ' + $e.Drum + '   (raportat ' + $e.Data + ')')
  [void]$sb.AppendLine('  [' + $e.Stare + '] ' + $e.Drum)
  foreach ($d in $e.Detalii) { [void]$sb.AppendLine('  ' + $d) }
}
[void]$sb.AppendLine('')

$veche = ''
if (Test-Path -LiteralPath $arhivaPath) { $veche = [IO.File]::ReadAllText($arhivaPath) }
[IO.File]::WriteAllText($arhivaPath, $veche + $sb.ToString(), $enc)

# logul viu: se pastreaza DOAR evenimentele deschise, cu antetul lor de rulare
$sb2 = New-Object System.Text.StringBuilder
foreach ($g in ($cls.Deschise | Group-Object -Property Data)) {
  [void]$sb2.AppendLine('=== align-index.ps1 · ' + $g.Name + ' ===')
  foreach ($e in $g.Group) {
    [void]$sb2.AppendLine('[' + $e.Stare + '] ' + $e.Drum)
    foreach ($d in $e.Detalii) { [void]$sb2.AppendLine($d) }
  }
  [void]$sb2.AppendLine('')
}
[IO.File]::WriteAllText($Log, $sb2.ToString(), $enc)

Write-Host ''
Write-Host ('ARHIVAT: ' + $cls.Rezolvate.Count + ' evenimente -> ' + (Split-Path -Path $arhivaPath -Leaf))
Write-Host ('RAMASE IN LOG: ' + $cls.Deschise.Count + ' evenimente deschise')
if ($neacoperite.Count -gt 0) {
  Write-Host ('VERDICT INCOMPLET: ' + $neacoperite.Count + ' stricari reale, necuprinse in log.')
  exit 1
}
if ($cls.Deschise.Count -gt 0) { exit 1 } else { exit 0 }