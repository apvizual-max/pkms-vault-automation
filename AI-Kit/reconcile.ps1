<#
  PKMS reconcile.ps1 - compara voltul cu backupul si raporteaza pierderile.
  REGULA: nu scrie niciodata in backup. doar citeste.
  Daca gaseste lipsuri, le COPIAZA din backup in volt - nu le muta.
#>
param(
  # ATENTIE: lasat GOAL, la fel ca $Backup de mai jos. Daca am pune aici un drum,
  # Get-PkmsVault nu s-ar apela niciodata, iar $env:PKMS_VAULT ar fi ignorat in
  # tacure. era exact regula scrisa in comentariul de sub $Backup, aplicata pe
  # backup si uitata pe volt.
  [string]$Vault = '',
  # ATENTIE: lasat GOAL. Daca am pune aici un drum, Get-PkmsBackup nu s-ar apela
  # niciodata, iar scriptul ar compara cu nimic si ar anunta fals "nu s-a pierdut nimic".
  [string]$Backup = '',
  [switch]$Restore,
  # scrie mutarile fara manifest intr-un REVERT3.csv, ca urmatoarea runda sa le stie.
  # fara asta, la urmatoarea reorganizare ele chiar vor parea pierdute.
  [switch]$WriteManifest,
  # reface fisierele SUPASCRISE (la acelasi drum, continut diferit).
  # e separat de -Restore intentionat: aici suprascriem continut nou peste ceva
  # existent, nu umplem o gaura. versiunea curenta e pusa la loc inainte, in
  # _QUARANTINE\restaurari\, deci nimic nu se pierde nici aici.
  [switch]$RestoreModified
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\paths.ps1"
if (-not $Backup) { $Backup = Get-PkmsBackup }
if (-not $Vault)  { $Vault  = Get-PkmsVault }
if (-not $Backup) { Write-Output 'BACKUP NU A FOST GASIT'; exit 1 }
if (-not (Test-Path -LiteralPath $Backup)) {
  Write-Output "BACKUP INEXISTENT: $Backup"
  Write-Output 'Nu s-a comparat nimic. Nu pot spune ca nu s-a pierdut nimic.'
  exit 1
}
# aceeasi regula pentru voltul: daca nu exista, comparatia nu are obiect.
# fara asta, Get-ChildItem ar intoarce 0 fisiere si scriptul ar raporta
# "lipsa reala" pentru tot backupul, fara sa stie ca n-a citit nimic.
if (-not (Test-Path -LiteralPath $Vault)) {
  Write-Output "VOLT INEXISTENT: $Vault"
  Write-Output 'Nu s-a comparat nimic. Nu pot spune ca nu s-a pierdut nimic.'
  exit 1
}
$ex = '\\\.obsidian\\|\\\.git\\'

$now = @(Get-ChildItem -LiteralPath $Vault  -File -Recurse -Force -EA SilentlyContinue | Where-Object { $_.FullName -notmatch $ex })
$bak = @(Get-ChildItem -LiteralPath $Backup -File -Recurse -Force -EA SilentlyContinue | Where-Object { $_.FullName -notmatch $ex })

$nv = [int64](($now | Measure-Object Length -Sum).Sum)
$bk = [int64](($bak | Measure-Object Length -Sum).Sum)

# potrivire pe NUME RELATIV, nu pe dimensiune.
# motivul: dimensiunea egala nu inseamna acelasi fisier. Un fisier sters din volt se
# putea ascunde in faptul ca in volt exista ALT fisier de aceeasi dimensiune, iar
# scriptul ar raporta "nu s-a pierdut nimic". Asta e un repaus fals.
#
# dar numele relativ singur nu ajunge: voltul a fost REORGANIZAT, deci 39.469 de
# fisiere au drum nou. Fiecare dintre ele ar pare "lipsa" daca nu corelam cu manifestul
# de mutari. De aceea corelatia, nu dimensiunea, decide cine e mutat si cine e pierdut.
$nowRel = New-Object 'System.Collections.Generic.Dictionary[string,long]' ([StringComparer]::OrdinalIgnoreCase)
# scris la ce moment in volt. fara asta, "modificat" nu poate fi despartit in
# ACTIV (scris recent, viu) si SUSPECT (diferit, dar vechi) - vezi mai jos.
$nowTime = New-Object 'System.Collections.Generic.Dictionary[string,datetime]' ([StringComparer]::OrdinalIgnoreCase)
foreach ($f in $now) {
  $k = $f.FullName.Substring($Vault.Length+1)
  $nowRel[$k] = $f.Length
  $nowTime[$k] = $f.LastWriteTime
}

# pragul de ACTIVITATE: cea mai recenta scriere din backup. orice fisier scris in
# volt DUPA asta a fost atins dupa ultima captura, deci nu poate fi judecat prin
# comparatie cu backupul - continutul lui mai nou e chiar el.
$ultimaScriereBackup = [datetime]::MinValue
if ($bak.Count -gt 0) {
  $mx = ($bak | Measure-Object LastWriteTime -Maximum).Maximum
  if ($mx) { $ultimaScriereBackup = $mx }
}

function Test-Activ([string]$relCur) {
  # mai multe probe, nu unul singur. un fisier modificat saptamana trecuta NU e activ.
  # 1) exista in volt la acel drum
  if (-not $nowTime.ContainsKey($relCur)) { return $false }
  $t = $nowTime[$relCur]
  # 2) scris DUPAA ultima scriere cunoscuta din backup (altfel backupul e mai nou)
  if ($ultimaScriereBackup -ne [datetime]::MinValue -and $t -le $ultimaScriereBackup) { return $false }
  # 3) scris in ultimele 48h. fara asta, "dupa ultima scriere" ar cuprinde orice
  # lucru facut intre o luna - adica un fisier vechi, nu unul viu.
  if ($t -lt (Get-Date).AddHours(-48)) { return $false }
  return $true
}

# --- manifestul de mutari ---
# ATENTIE: REVERT.csv mapeaza FISIER cu fisier. REVERT2.csv mapeaza DIRECTOARE, deci
# se aplica ca PREFIX, iar rezultatul lui trebuie sa treaca inca o data prin el.
# fara aceasta, 34.380 de fisiere mutate erau raportate ca pierdute.
$maniDir = Join-Path $env:USERPROFILE '.minimax\vault-manifest'
$maniOK = $false
function Rel([string]$p) {
  if (-not $p) { return $null }
  if ($p.StartsWith($Backup)) { return $p.Substring($Backup.Length+1) }
  if ($p.StartsWith($Vault))  { return $p.Substring($Vault.Length+1) }
  return $null
}

# reguli de director, cel mai lung prefix primul (altfel un prefix scurt poate
# "castiga" unul mai lung si trimite fisierul in alt loc)
$dirRules = New-Object System.Collections.Generic.List[object]
$fileMap  = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([StringComparer]::OrdinalIgnoreCase)

if (Test-Path (Join-Path $maniDir 'REVERT2.csv')) {
  foreach ($r in (Import-Csv (Join-Path $maniDir 'REVERT2.csv'))) {
    $o = Rel $r.original; $n = Rel $r.current
    if ($o -and $n) { $dirRules.Add([pscustomobject]@{ Old=$o; New=$n }); $maniOK = $true }
  }
}
if (Test-Path (Join-Path $maniDir 'REVERT.csv')) {
  foreach ($r in (Import-Csv (Join-Path $maniDir 'REVERT.csv'))) {
    $o = Rel $r.original_abs; $n = Rel $r.current_abs
    if ($o -and $n) { $fileMap[$o] = $n; $maniOK = $true }
  }
}
# REVERT3 = mutari din rundele tarzii, scrise de -WriteManifest. le trateaza la fel
# ca REVERT.csv, adica fisier cu fisier.
if (Test-Path (Join-Path $maniDir 'REVERT3.csv')) {
  foreach ($r in (Import-Csv (Join-Path $maniDir 'REVERT3.csv'))) {
    $o = Rel $r.original; $n = Rel $r.current
    if ($o -and $n) { $fileMap[$o] = $n; $maniOK = $true }
  }
}
$dirRules = @($dirRules | Sort-Object { $_.Old.Length } -Descending)

function Map-Dir([string]$rel) {
  foreach ($d in $dirRules) {
    if ($rel.StartsWith($d.Old + '\', [StringComparison]::OrdinalIgnoreCase)) {
      return ($d.New + $rel.Substring($d.Old.Length))
    }
  }
  return $null
}

$laLoc     = 0
$mutat     = 0
$lipsa     = New-Object System.Collections.Generic.List[object]
$modificat = New-Object System.Collections.Generic.List[object]
foreach ($f in $bak) {
  $rel = $f.FullName.Substring($Backup.Length+1)
  if ($nowRel.ContainsKey($rel)) {
    $laLoc++
    $gLen = [long]$nowRel[$rel]
    if ($gLen -ne $f.Length) { $modificat.Add([pscustomobject]@{ Rel=$rel; Cur=$rel; Src=$f.FullName; Was=$f.Length; Now=$gLen; Activ=(Test-Activ $rel) }) }
  } elseif ($maniOK) {
    # candidata 1: fisierul era deja mutat fisier cu fisier, apoi mutat cu tot directorul
    $cand = $null
    if ($fileMap.ContainsKey($rel)) { $cand = $fileMap[$rel] }
    # candidata 2: direct sub un director mutat (fara sa fi trecut prin REVERT.csv)
    if (-not $cand) { $cand = Map-Dir $rel }
    # candidata 3: dupa maparea de fisier, directorul s-a mutat intre timp
    if ($cand) { $c2 = Map-Dir $cand; if ($c2) { $cand = $c2 } }

    $g = -1
    if ($cand -and $nowRel.ContainsKey($cand)) { $g = [long]$nowRel[$cand] }
    if ($g -ge 0) {
      $mutat++
      if ($g -ne $f.Length) { $modificat.Add([pscustomobject]@{ Rel=$rel; Cur=$cand; Src=$f.FullName; Was=$f.Length; Now=$g; Activ=(Test-Activ $cand) }) }
    } else {
      $lipsa.Add([pscustomobject]@{ Rel=$rel; Src=$f.FullName; Len=$f.Length })
    }
  } else {
    $lipsa.Add([pscustomobject]@{ Rel=$rel; Src=$f.FullName; Len=$f.Length })
  }
}
# --- ultima runda: mutari fara manifest ---
# rundele tarzii (note la radacina -> 00_Inbox, secrete -> _ARCHIVE, reziduuri ->
# _QUARANTINE) nu au fost scrise in niciun manifest. Ca sa nu raportam ca pierdute
# fisiere care exista, cautam fiecare "lipsa" dupa NUME si DIMENSIUNE in tot voltul.
$byNS = New-Object 'System.Collections.Generic.Dictionary[string,System.Collections.Generic.List[string]]'
foreach ($k in $nowRel.Keys) {
  $key = ([IO.Path]::GetFileName($k)) + '|' + $nowRel[$k]
  if (-not $byNS.ContainsKey($key)) { $byNS[$key] = New-Object System.Collections.Generic.List[string] }
  $byNS[$key].Add($k)
}
$relocat = New-Object System.Collections.Generic.List[string]
$relocPairs = New-Object System.Collections.Generic.List[object]
$realLipsa = New-Object System.Collections.Generic.List[object]
foreach ($l in $lipsa) {
  $key = ([IO.Path]::GetFileName($l.Rel)) + '|' + $l.Len
  if ($byNS.ContainsKey($key)) {
    $dest = $byNS[$key][0]
    $relocat.Add("$($l.Rel)  ==>  $dest")
    $relocPairs.Add([pscustomobject]@{ current = (Join-Path $Vault $dest); original = $l.Src })
    continue
  }
  # nivelul 2: mutat SI RENUMIT. rafturile masinii pastreaza martorii cu prefix,
  # ca sa nu se ciocneasca ("Gemini Scribe - debug.log", nu "debug.log").
  # le recunosc dupa sufixul numelui + aceeasi dimensiune.
  $nume = [IO.Path]::GetFileName($l.Rel)
  $hit = $null
  foreach ($k in $byNS.Keys) {
    if ($k.EndsWith('|' + $l.Len) -and $k.StartsWith('|') -eq $false) {
      $destN = [IO.Path]::GetFileName($k.Substring(0, $k.LastIndexOf('|')))
      if ($destN.Length -gt $nume.Length -and
          $destN.EndsWith($nume, [StringComparison]::OrdinalIgnoreCase)) {
        $hit = $byNS[$k][0]; break
      }
    }
  }
  if ($hit) {
    $relocat.Add("$($l.Rel)  ==>  $hit   [redenumit]")
    $relocPairs.Add([pscustomobject]@{ current = (Join-Path $Vault $hit); original = $l.Src })
  }
  else { $realLipsa.Add($l) }
}
$missing = $realLipsa.Count

Write-Output "=== RECONCILIERE ==="
Write-Output "backup folosit: $Backup"
Write-Output "volt:    $($now.Count) fisiere  $([math]::Round($nv/1GB,2)) GB"
Write-Output "backup:  $($bak.Count) fisiere  $([math]::Round($bk/1GB,2)) GB"
Write-Output "diferenta de dimensiune: $([math]::Round($nv-$bk,0)) octeti"
Write-Output ""
Write-Output "SURSA FIECAREI CIFRE DE MAI SUS:"
Write-Output "  numarator: Get-ChildItem -LiteralPath <cale> -File -Recurse -Force |"
Write-Output "             Where-Object { `$_.FullName -notmatch $ex }"
Write-Output "  \$ex = '$ex'   (2 tipare)"
Write-Output "  asta NU e Get-PkmsExclusions (15 tipare, din paths.ps1). cele doua dau"
Write-Output "  numere diferite prin constructie. aici se raporteaza numarul masurat cu"
Write-Output "  filtrul scris mai sus, ca sa poata fi verificat sau contrazis."
Write-Output "  masurat: Get-ChildItem nu pierde nimic la cale >259 caractere - 128 cai"
Write-Output "  (max 329) exista si toate sunt numarate. calea lunga nu e motivul"
Write-Output "  pentru care doua rulari pot da cifre diferite."

# gard: un backup gol inseamna ca nu am citit nimic, nu ca nu s-a pierdut nimic
if ($bak.Count -eq 0) {
  Write-Output "ATENTIE: backupul a fost citit si a venit CU 0 FISIERE."
  Write-Output 'Comparatia nu este valida. Nu pot afirma ca nu s-a pierdut nimic.'
  exit 1
}

Write-Output "din backup, la ACELASI drum in volt:            $laLoc"
Write-Output "din backup, MUTAT, inregistrat in manifest:      $mutat"
Write-Output "din backup, MUTAT, fara manifest (gasit in volt): $($relocat.Count)"
Write-Output "din backup, REAL LIPSA (niciunde in volt):        $missing"
if ($relocat.Count -gt 0) {
  Write-Output "  primele 5 relocari, ca sa le poti verifica cu ochiul:"
  $relocat | Select-Object -First 5 | ForEach-Object { Write-Output "     $_" }
  Write-Output "  ATENTIE: aceste mutari NU sunt in niciun REVERT. La urmatoarea reorganizare"
  Write-Output "  vor conta drept pierdute. Asta e o datorie de plat, nu o victorie."
  if ($WriteManifest) {
    $r3 = Join-Path $maniDir 'REVERT3.csv'
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('"current","original"')
    foreach ($p in $relocPairs) { $lines.Add(('"{0}","{1}"' -f $p.current, $p.original)) }
    [IO.File]::WriteAllLines($r3, $lines, (New-Object Text.UTF8Encoding $true))
    Write-Output "  MUTARI INREGISTRATE: $($relocPairs.Count) randuri -> $r3"
    Write-Output "  (acum sunt acoperite de manifest._ruleaza din nou ca sa le vezi mutate)"
  }
}
$activ    = @($modificat | Where-Object { $_.Activ })
$suspect  = @($modificat | Where-Object { -not $_.Activ })
Write-Output "la acelasi drum, dar dimensiune diferita (continut modificat): $($modificat.Count)"
Write-Output "   dintre care ACTIVI (scrisi in volt dupa ultima scriere din backup): $($activ.Count)"
Write-Output "   dintre care SUSPECTI (diferiti, dar nu activi):                     $($suspect.Count)"
if ($activ.Count -gt 0) {
  Write-Output ""
  Write-Output "ACTIVI - nu sunt suspecti, nu se restaura:"
  Write-Output "  un fisier activ a fost scris in volt DUPA ultima scriere din backup, deci"
  Write-Output "  continutul lui mai nou e chiar el, nu o degradare. masurat pe:"
  # CIFRA SE CALCULEAZA AICI, NU SE SCRITE.
  # era scrisa tare (964 octeti) intr-un script care, doua randuri mai jos, afisa chiar
  # cifra reala masurata in acel moment: 2.334. Fisierul creste cat ruleaza sistemul,
  # deci un numar scris aici ingheata o stare care nu mai exista peste un minut.
  $dbgRel = '06_Metadata\Gemini Scribe\debug.log'
  $dbgCur = Join-Path $Vault $dbgRel
  $dbgBak = Join-Path $Backup $dbgRel
  if (Test-Path -LiteralPath $dbgCur) {
    Write-Output "    $dbgRel - $((Get-Item -LiteralPath $dbgCur).Length) octeti in volt acum"
  } else {
    Write-Output "    $dbgRel - nu a fost gasit in volt acum"
  }
  if (Test-Path -LiteralPath $dbgBak) {
    Write-Output "    in backup: $((Get-Item -LiteralPath $dbgBak).Length) octeti, la ultima captura."
  } else {
    Write-Output "    in backup: nu a fost gasit la acelasi drum."
  }
  Write-Output "    (dimensiune la momentul citirii - nu o cifra inghetata in script)"
  Write-Output "  Pentru ei nu se propune -RestoreModified: ar suprascrie un log viu cu unul vechi."
  $activ | Select-Object -First 10 | ForEach-Object {
    $t = if ($nowTime.ContainsKey($_.Cur)) { $nowTime[$_.Cur].ToString('yyyy-MM-dd HH:mm:ss') } else { '?' }
    Write-Output "   ACTIV:   $($_.Cur)  ($($_.Was) -> $($_.Now) octeti, scris in volt la $t)" }
  if ($activ.Count -gt 10) { Write-Output "   ... si $($activ.Count - 10) altii activi" }
}
if ($suspect.Count -gt 0) {
  $suspect | Select-Object -First 10 | ForEach-Object { Write-Output "   SUSPECT: $($_.Cur)  ($($_.Was) -> $($_.Now) octeti)" }
  if ($suspect.Count -gt 10) { Write-Output "   ... si $($suspect.Count - 10) altele" }
}
if ($modificat.Count -gt 0) {
  if (-not $RestoreModified) {
    Write-Output ""
    if ($suspect.Count -gt 0) {
      Write-Output "ATENTIE: SUSPECTII nu sunt pierderi. Continutul lor a fost schimbat intentionat,"
      Write-Output "sau s-a stricat. Nicio comanda nu atinge un fisier care a fost modificat,"
      Write-Output "pentru ca o suprascriere strica poate distruge ceva nou si bun."
      Write-Output "Daca vrei totusi versiunea din backup, pentru CEI $($suspect.Count) SUSPECTI, spune-o explicit:"
      Write-Output "   .\reconcile.ps1 -RestoreModified"
      Write-Output "Versiunea ta de acum e pusa la loc in _QUARANTINE\restaurari\ inainte de orice scriere."
    }
    if ($activ.Count -gt 0) {
      Write-Output ""
      Write-Output "ACTIVII NU SUNT ATINGI de -RestoreModified, nici daca comanda se da cu totul."
      Write-Output "Sunt scrisi dupa ultima captura, deci comparatia cu backupul nu are ce spune despre ei."
    }
  } else {
    Write-Output ""
    Write-Output "REFACERE FISIERE MODIFICATE (doar SUSPECTII - activii raman neatinsi)"
    $stamp  = Get-Date -Format 'yyyy-MM-dd HH-mm-ss'
    $past   = Join-Path $Vault "_QUARANTINE\restaurari\$stamp"
    $done = 0
    foreach ($m in $suspect) {
      $cur = Join-Path $Vault $m.Cur
      $salve = Join-Path $past $m.Cur
      $par = Split-Path -Parent $salve
      if (-not (Test-Path $par)) { New-Item -ItemType Directory -Path $par -Force | Out-Null }
      Copy-Item -LiteralPath $cur -Destination $salve -Force
      Copy-Item -LiteralPath $m.Src -Destination $cur -Force
      Write-Output "   REFACUT: $($m.Cur)   (versiunea ta e la $salve)"
      $done++
    }
    Write-Output "refacute: $done.  salvate inapoi: $past"
  }
}
if (-not $maniOK) {
  Write-Output ""
  Write-Output "ATENTIE: manifestul de mutari nu a fost gasit la $maniDir"
  Write-Output "Fara el, un fisier mutat ar parea pierdut. Cifrele de mai sus NU sunt concludente."
}

$newest = (Get-ChildItem -LiteralPath $Backup -File -Recurse -Force -EA SilentlyContinue |
           Sort-Object LastWriteTime -Desc | Select-Object -First 1)
if ($newest) {
  Write-Output "backup neatins, cel mai recent: $($newest.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))  $($newest.Name)"

# cerinta de socoteala: categoriile trebuie sa acopere EXACT backupul.
# un raport care nu se aduna nu e raport, e decor. am facut exact asta o data:
# 2141 + 41907 = 44048, backupul are 46233, si diferenta s-a pierdut linistit.
$acoperit = $laLoc + $mutat + $relocat.Count + $missing
if ($acoperit -ne $bak.Count) {
  Write-Output ""
  Write-Output "STOP: RAPORTUL NU SE ADUNA."
  Write-Output "  categorii: $laLoc + $mutat + $($relocat.Count) + $missing = $acoperit"
  Write-Output "  backup are: $($bak.Count)"
  Write-Output "  diferenta:  $($bak.Count - $acoperit)"
  Write-Output "Nu pot afirma ca nu s-a pierdut nimic. Nu s-a comparat tot."
  exit 1
}
Write-Output "socoteala inchisa: $acoperit din $($bak.Count). Nicio categorie nu e ascunsa."
}
# RAMURA ELIMINATA, masurata, nu ghicita. "else"-ul care spunea "NU AM PUTUT CITI
# NICIO FISIER DIN BACKUP" era inaccesibil: el cerea $newest -lti, adica niciun
# fisier citibil in backup - iar pentru exact asta scriptul iese deja cu cod 1,
# la $bak.Count -eq 0, cu zece liniuri mai sus. $newest este ACEEASI enumerare ca
# $bak, doar fara filtrul $ex, deci nu poate fi ne EMPTY cand $bak nu e. Mesajul
# era deci repetarea exacta a unui verdict deja dat, cu iesire mai tare. A fost
# eliminat, nu mutat: conditia ramane acoperita acolo unde chiar poate aparea.

if ($missing -gt 0) {
  Write-Output ""
  Write-Output "LIPSA $missing fisiere, dupa numele lor. Iata care sunt cele REAL lipsa:"
  foreach ($l in ($realLipsa | Select-Object -First 20)) { Write-Output "   LIPSA: $($l.Rel)" }
  if ($missing -gt 20) { Write-Output "   ... si $($missing - 20) altele" }
  Write-Output ""
  Write-Output "Restaurarea copiaza FISAIERUL PE ACELASI NUME, inapoi la acelasi drum."
  Write-Output "Nu se atinge backupul. Daca vrei:"
  Write-Output "   .\reconcile.ps1 -Restore"
  if ($Restore) {
    Write-Output "RESTAURARE: se copiaza inapoi din backup, pe numele proprii"
    $copied = 0
    foreach ($l in $realLipsa) {
      $dst = Join-Path $Vault $l.Rel
      $par = Split-Path -Parent $dst
      if (-not (Test-Path $par)) { New-Item -ItemType Directory -Path $par -Force | Out-Null }
      Copy-Item -LiteralPath $l.Src -Destination $dst -Force
      Write-Output "   RESTAT: $($l.Rel)"
      $copied++
    }
    Write-Output "restaurate: $copied"
  }
}

if ($missing -gt 0) { exit 1 } else { exit 0 }