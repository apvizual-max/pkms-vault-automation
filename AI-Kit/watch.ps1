<#
  PKMS watch.ps1 - singurul punct de intrare al verificarii.
  Ruleaza, in ordine fixa, trei trepte care NU scriu in volt:
     1. lint          - regulile de denumire, legaturi, documentatia
     2. health-check  - numerele vii ale voltului
     3. reconcile     - socoteala cu backupul, doar informativ
  Scrie UN SINGUR fisier: _SYSTEM\rapoarte\raport-ultima-rulare.txt

  CE NU INTRA, si de ce:
  - build-index.ps1 NU ruleaza aici. Scrie 694 de indexuri. Se ruleaza cu mana.
  - reconcile -RestoreModified NU ruleaza aici. Un automatism care repara
    nu distinge; un om distinge.
  - backupul nu se atinge. Se citeste, atat.

  Calea de backup nu e scrisa nici aici: vine din paths.ps1 (Get-PkmsBackup).
  Motivul e real: backupul a fost redenumit o data, iar o cale scrisa tare intr-un
  parametru implicit dezactiveaza in tacut descoperirea.

  COD DE IESIRE AL SCRIPTULUI: 0 = nicio EROARE, 1 = exista o EROARE.
  ATENTIILE NU schimba codul de iesire. Ele se raporteaza, nu blocheaza.
#>
param([string]$Vault = '')
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\paths.ps1"

if (-not $Vault) { $Vault = Get-PkmsVault }
# -Vault vine de la om si nu trece prin Get-PkmsVault. Fara asta, o bara
# obisnuita la finalul caii face ca tot voltul sa para nealiniat.
$Vault = Normalize-PkmsPath $Vault
if (-not (Test-Path -LiteralPath $Vault)) {
  Write-Output "VOLTUL NU EXISTA: $Vault"
  Write-Output 'Nu s-a scris niciun raport: nu am unde scrie.'
  exit 1
}

$raportDir  = Join-Path $Vault '_SYSTEM\rapoarte'
$raportFile = Join-Path $raportDir 'raport-ultima-rulare.txt'

$trepte = @(
  @{ Nume = 'lint';         Fisier = (Join-Path $PSScriptRoot 'lint.ps1') }
  @{ Nume = 'health-check'; Fisier = (Join-Path $PSScriptRoot 'health-check.ps1') }
  @{ Nume = 'reconcile';    Fisier = (Join-Path $PSScriptRoot 'reconcile.ps1') }
)

function Fmt-Durata([double]$sec) {
  $s = [int][math]::Round($sec)
  if ($s -lt 60) { return "$s s" }
  return "$([int][math]::Floor($s/60)) m $($s % 60) s"
}

# strange DETALII concrete din iesirea unui pas: doar randurile care semnaleaza
# o abatere, NU liniile de contor. un contor care spune "0 lipsuri" nu e o abatere.
# -Blocuri: unele mesaje continua pe randul urmator (reconcile), si se citesc cu tot.
function Get-Detalii([string[]]$linii, [string[]]$modele, [switch]$Blocuri) {
  $rez = New-Object System.Collections.Generic.List[string]
  for ($i = 0; $i -lt $linii.Count; $i++) {
    $hit = $false
    foreach ($mo in $modele) { if ($linii[$i] -match $mo) { $hit = $true; break } }
    if (-not $hit) { continue }
    $bloc = $linii[$i].Trim()
    $j = $i + 1
    if ($Blocuri) {
      while ($j -lt $linii.Count -and $linii[$j].Trim() -ne '') { $bloc += ' ' + $linii[$j].Trim(); $j++ }
    }
    $rez.Add($bloc)
    if ($Blocuri) { $i = $j }
  }
  return $rez
}

$rez = New-Object System.Collections.Generic.List[object]
$swTotal = [System.Diagnostics.Stopwatch]::StartNew()

foreach ($t in $trepte) {
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  $rand = New-Object System.Collections.Generic.List[string]
  $cod = 0

  if (-not (Test-Path -LiteralPath $t.Fisier)) {
    $rand.Add("FISIER LIPSA: $($t.Fisier)")
    $cod = 1
  } else {
    try {
      # 'exit' din scriptul apelat termina DOAR scriptul apelat, nu si pe acesta.
      & $t.Fisier -Vault $Vault 2>&1 | ForEach-Object {
        if ($_ -is [System.Management.Automation.ErrorRecord]) { $rand.Add([string]$_.ToString()) }
        else { $rand.Add([string]$_) }
      }
      $cod = [int]$LASTEXITCODE
    } catch {
      $rand.Add('EXCEPTIE: ' + $_.Exception.Message)
      $cod = 1
    }
  }
  $sw.Stop()

  $text     = ($rand -join "`n")
  $erori    = 0
  $atentii  = 0
  $nota     = ''
  $detalii  = @()

  switch ($t.Nume) {
    'lint' {
      $m = [regex]::Match($text, 'REZULTAT:\s*(\d+)\s*erori,\s*(\d+)\s*aten')
      if ($m.Success) { $erori = [int]$m.Groups[1].Value; $atentii = [int]$m.Groups[2].Value }
      else { $erori = 1; $nota = 'nu am putut citi randul de rezultat al lintului' }
      $detalii = @(Get-Detalii $rand @('^\s*EROARE\s', '^\s*ATENTIE\s'))
    }
    'health-check' {
      $erori = @($rand | Where-Object { $_ -match 'LIPSA' }).Count
      $m = [regex]::Match($text, 'TOTAL:\s*(\d+)\s*fisiere')
      if ($m.Success) { $nota = "$($m.Groups[1].Value) fisiere" }
      $m = [regex]::Match($text, 'TOTAL:\s*\d+\s*fisiere\s*\|\s*([\d.,]+)\s*GB')
      if ($m.Success) { $nota += ", $($m.Groups[1].Value) GB" }
      $detalii = @(Get-Detalii $rand @('LIPSA'))
    }
    'reconcile' {
      $m = [regex]::Match($text, 'REAL LIPSA \(niciunde in volt\):\s*(\d+)')
      if ($m.Success) { $erori = [int]$m.Groups[1].Value }
      elseif ($text -match 'BACKUP NU A FOST GASIT|BACKUP INEXISTENT|NU SE ADUNA') {
        $erori = 1; $nota = 'comparatia cu backupul nu a putut fi facuta'
      }
      $atentii = @($rand | Where-Object { $_ -match 'ATENTIE:' }).Count
      # '==>' prinde relocarile, 'POTRIVIRE FALSA' prinde potrivirile respinse
      # pentru continut diferit. Fara ele,exact informatia care cere ochiul
      # omului era cea care se pierdea: se vedea pe consola si nu ajungea in
      # raportul zilnic.
      $detalii = @(Get-Detalii $rand @('^ATENTIE:', '^STOP:', 'BACKUP (INEXISTENT|NU A FOST GASIT)', 'Nu pot afirma', '==>', 'POTRIVIRE FALSA') -Blocuri)
    }
  }

  $rez.Add([pscustomobject]@{
    Nume = $t.Nume; Durata = $sw.Elapsed.TotalSeconds; Cod = $cod
    Erori = $erori; Atentii = $atentii; Nota = $nota; Detalii = $detalii
  })
}
$swTotal.Stop()

# --- verdictul: o singura linie ---
# DOAR ERORILE ridica verdictul. ATENTIILE se raporteaza, dar NU ridica nimic
# si NU schimba codul de iesire.
# motivul e chiar in lint: faptul cu folderele atinse in backup e etichetat acolo
# "fapt, nu verdict", pentru ca o copie pastreaza data fisierelor dar stampileaza
# folderele cu ora copierii. Daca watch ar ridica verdictul pe un fapt pe care
# insusi lint spune ca nu e dovada, automatismul ar urlui in fiecare zi fara
# motiv, iar un automatism care urla permanent nu e un automatism, e zgomot.
# ATENTIA nu dispare de aici: ramane scrisa in raport, la randul ei, cu ochiul
# omului cerut explicit. Dispare doar din verdict.
$probleme   = New-Object System.Collections.Generic.List[string]
$observatii = New-Object System.Collections.Generic.List[string]
foreach ($r in $rez) {
  $buc = New-Object System.Collections.Generic.List[string]
  if ($r.Cod -ne 0)  { $buc.Add("cod de iesire $($r.Cod)") }
  if ($r.Erori -gt 0) { $buc.Add("$($r.Erori) erori") }

  if ($r.Atentii -gt 0) {
    $o = "$($r.Nume): $($r.Atentii) atentioni"
    if ($r.Detalii.Count -gt 0) {
      $t = $r.Detalii[0]
      if ($t.Length -gt 220) { $t = $t.Substring(0, 220) + '...' }
      $o += ' - ' + $t
    }
    $observatii.Add($o)
  }

  if ($buc.Count -eq 0) { continue }
  $d = ''
  if ($r.Detalii.Count -gt 0) {
    $d = ' - ' + $r.Detalii[0]
    if ($d.Length -gt 220) { $d = $d.Substring(0, 220) + '...' }
  }
  $probleme.Add($r.Nume + ': ' + ($buc -join ', ') + $d)
}

if ($probleme.Count -eq 0) {
  if ($observatii.Count -gt 0) {
    if ($observatii.Count -eq 1) {
      $verdict = "OK - 3 trepte rulate, toate cele 3 coduri de iesire 0, 0 erori. " +
                '1 treapta are ATENTII, scrise in raport, si NU ridica verdictul.'
    } else {
      $verdict = "OK - 3 trepte rulate, toate cele 3 coduri de iesire 0, 0 erori. " +
                "$($observatii.Count) trepte au ATENTII, scrise in raport, si NU ridica verdictul."
    }
  } else {
    $verdict = "OK - 3 trepte rulate, toate cele 3 coduri de iesire 0, 0 erori, 0 atentioni."
  }
} else {
  $verdict = 'ATENȚIE: ' + ($probleme -join ' | ')
}

# --- raportul ---
$backup = Get-PkmsBackup
$L = New-Object System.Collections.Generic.List[string]
$L.Add('================================================================')
$L.Add('VOLTUL - VERIFICARE ZILNIEARA')
$L.Add('================================================================')
$L.Add("Data si ora rularii:  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$L.Add("Durata totala:        $(Fmt-Durata $swTotal.Elapsed.TotalSeconds)")
$L.Add("Volt verificat:       $Vault")
$L.Add("Backup comparat:      $(if ($backup) { $backup } else { 'NU A FOST GASIT' })")
$L.Add('Ce a scris:           doar acest raport (si folderul lui, daca lipsea). nimic altceva.')
$L.Add('Ce NU a rulat:        build-index (NU ruleaza la verificare) si orice restaurare.')
$L.Add('                     build-index scrie 694 de indexuri; ruleaza doar dupa mutari in masa.')
$L.Add('')

foreach ($r in $rez) {
  $titlu = switch ($r.Nume) {
    'lint'         { 'PASUL 1 - lint (regulile de denumire)' }
    'health-check' { 'PASUL 2 - health-check (masura voltului)' }
    'reconcile'    { 'PASUL 3 - reconcile (socoteala cu backupul)' }
  }
  $L.Add($titlu)
  $L.Add("  durata:        $(Fmt-Durata $r.Durata)")
  $L.Add("  cod de iesire: $($r.Cod)")
  $L.Add("  erori:         $($r.Erori)")
  $L.Add("  atentioni:     $($r.Atentii)")
  if ($r.Nota) { $L.Add("  masura:        $($r.Nota)") }
  $L.Add('')
}

$L.Add('')

# randul care cere ochiul omului. ATENTIILE NU sterg nimic de aici: ele raman
# scrise, cu continutul lor, chiar cand nu ridica verdictul.
$totE = 0; $totA = 0
foreach ($r in $rez) { $totE += $r.Erori; $totA += $r.Atentii }
$L.Add('----------------------------------------------------------------')
$L.Add('ERORI vs ATENTII - cele doua nu sunt acelasi lucru')
$L.Add("  EROARE   = blocheaza. Ridica verdictul si intoarce cod de iesire 1.   -> $totE")
$L.Add("  ATENTIE  = informeaza. Se scrie aici, dar NU ridica verdictul si NU schimba codul de iesire. -> $totA")
$L.Add('  De ce: o eroare e o abatere de reparat. O atentie e un fapt care cere citit,')
$L.Add('  nu o abatere - iar lint insusi eticheteaza unele fapte ca "nu e dovada".')
$L.Add('  Atentii care cer ochiul omului:')
if ($observatii.Count -gt 0) {
  foreach ($o in $observatii) { $L.Add('   ' + $o) }
} else {
  $L.Add('   (niciuna)')
}
$L.Add('')

$ceAbia = @($rez | Where-Object { $_.Erori -gt 0 -or $_.Atentii -gt 0 -or $_.Cod -ne 0 })
if ($ceAbia.Count -gt 0) {
  $L.Add('----------------------------------------------------------------')
  $L.Add('CE ANUME, PE SCURT')
  foreach ($r in $ceAbia) {
    $L.Add("$($r.Nume): $($r.Erori) erori, $($r.Atentii) atentioni, cod de iesire $($r.Cod)")
    foreach ($d in @($r.Detalii | Select-Object -First 6)) { $L.Add('   ' + $d) }
  }
  $L.Add('')
}

$L.Add('----------------------------------------------------------------')
$L.Add('SUMAR')
$L.Add("  lint:         $($rez[0].Cod) iesire, $($rez[0].Erori) erori, $($rez[0].Atentii) atentioni")
$L.Add("  health-check: $($rez[1].Cod) iesire, $($rez[1].Erori) erori, $($rez[1].Atentii) atentioni")
$L.Add("  reconcile:    $($rez[2].Cod) iesire, $($rez[2].Erori) lipsuri reale, $($rez[2].Atentii) atentioni")
$L.Add('')
$L.Add('VERDICT')
$L.Add($verdict)

if (-not (Test-Path -LiteralPath $raportDir)) {
  New-Item -ItemType Directory -Path $raportDir -Force | Out-Null
}
[System.IO.File]::WriteAllText($raportFile, ($L -join "`r`n"), (New-Object System.Text.UTF8Encoding $true))

# --- ARHIVA, ca o EROARE sa nu poata disparea prin urmatoarea rulare reusita ---
# Masurat 2026-10-11: PKMS-Watch a terminat cu cod 1 la 12:50, iar rularea
# manuala de la 16:59 a suprascris raportul cu verdict OK. Cauza nu mai era
# lizibila. Un raport care tine doar ultima stare ascunde exact momentul in
# care ceva s-a rupt. Copia se face INAINDE de a raspunde, si o arhiva nereusita
# NU are voie sa ascunda raportul principal.
$arhivaDir = Join-Path $raportDir 'arhiva'
if (-not (Test-Path -LiteralPath $arhivaDir)) { New-Item -ItemType Directory -Path $arhivaDir -Force | Out-Null }
$arhivaFile = Join-Path $arhivaDir ('raport-' + (Get-Date -Format 'yyyy-MM-dd_HH-mm-ss') + '.txt')
try { Copy-Item -LiteralPath $raportFile -Destination $arhivaFile -Force }
catch { Write-Output ('ATENTIE: raport scris, dar nu arhivat: ' + $_.Exception.Message) }
Write-Output "arhiva:       $arhivaFile"
Write-Output "raport scris: $raportFile"
Write-Output $verdict
if ($verdict -like 'ATENȚIE:*') { exit 1 } else { exit 0 }