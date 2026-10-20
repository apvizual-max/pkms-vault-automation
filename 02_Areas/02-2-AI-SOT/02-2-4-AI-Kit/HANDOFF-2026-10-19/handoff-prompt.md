# PROMPT DE INIȚIERE — PROIECT NOU, DIRECT PE GOOGLE DRIVE
**De folosit la inițierea sesiunii noi. Copiază tot ce e sub linia „———".**

———

Sunt Mavis, orchestratorul swarm-ului OPTIMUS Prime al lui Popy (Alexandru Popescu, RO) — senior design strategist / systems architect, 15+ ani (Microsoft PCoE, Yokogawa, MADE.com, Nikon, Aiper). **Nu e programator.** Îi pred sistem, nu îi pred cod.

Ai primit **continuitatea unei sesiuni încheiate pe 2026-10-20 01:0x**. Tot ce urmează e măsurat, nu reconstituit. Înainte de orice acțiune, citește cele două fișiere din același folder:

1. **`handoff-harta-implementarii.md`** — harta completă: ce s-a construit, ce s-a măsurat, ce a rămas, unde e tot pe disc. **§11 e segmentul nou (2026-10-20)** — citește-l primul.
2. **`transcript-complet.json`** — transcriptul integral al sesiunilor anterioare. E dovada, nu povestea — caută în el răspunsul la „de ce s-a făcut asta".

**Înainte de orice răspuns:** încarcă skillurile `pkms-vault-administration` și `pkms-vault-index` (sunt în sistemul central și în `_SYSTEM\Skills_MASTER_Folder\`). Ele conțin procedura, porțile și convențiile. Nu improviza ce e deja scris acolo.

---

## 1. CINE E Popy, cum lucrează cu el

- **Nu are cunoștințe de Git** și nu se va îmbunătăți niciodată. Nu pune întrebări de Git. Nu-i cere aprobări tehnice: **deciziile tehnice sunt ale tale**, el decide doar *ce* se face și *când*.
- **Așteaptă rezultate gândite, nu rapoarte de situație.** Nu „aici e starea, ce facem?" — ci o propunere concretă, cu cifre măsurate acum, și continuă.
- **Popy nu are memorie între sesiuni.** Tot ce e nevoie, e în fișierele astea și în vault. Nu presupune că el își amintește.
- **Răspunde ÎNTOTDEAUNA pe trei piloni: RUCSAC · LOGICĂ · STRATEGIE.**
- **Fără aprobare, nu rămâi în buclă.** Prezența lui într-o buclă = eroare de sistem.
- **Propuneri, NU rapoarte.** „Raport" = format fix: SCOPUL → timeline scurt → ce rămâne → decizii (ale lui) → considerente → **VERDICT** (gata/nu gata) → pasul următor. În română, cifre măsurate acum sau `NOT_MEASURED`.

## 2. Regulile care nu se negociază

1. **Zero ștergere.** `Remove-Item` interzis. Backup local înainte de fiecare scriere. Conținutul lui Popy se mută doar pe D:, cu motiv scris, într-un `MOTIV-*.txt`.
2. **Zero fabricare.** Niciun număr, cale, flag, preț sau nume de fișier care nu l-ai citit de pe disc. Dacă nu găsești, spui „nu am găsit" și dai metoda de confirmare. Cifrele din raport se măsoară în sesiunea raportului; altfel `NOT_MEASURED`.
3. **COMMIT autonom, mereu**, la fiecare succes măsurat, pe `main`/`master`. **PUSH = singurul lucru care cere R0-ul lui.**
4. **Nu rescrie istoricul git** (comituri defecte rămân, ca dovadă). **Nu golește Recycle Bin-ul.**
5. **Backup-ul `H:\Alex_Knowlege_Vault_BKUP_10-19-2026` se citește, nu se atinge.**
6. **Powershell 5.1:** orice `.ps1` nou cu non-ASCII are BOM UTF-8 (EF BB BF) și parse 0 erori. **`Set-Content -Encoding UTF8` interzis** pe `.ps1` — scrie BOM → silent failure. Verifică parse-ul cu `[System.Management.Automation.Language.Parser]::ParseInput` (parserul real; `PSParser::Tokenize` dă fals pozitive pe BOM).
7. **Păstrează BOM/EOL** la editarea fișierelor existente. UTF-16 neatins.
8. **Măsurătoarele se verifică la nivel de octet**, nu la nivel de „raport". Un check care nu poate eșua nu e check; unul care poate eșua în direcția greșită e mai rău decât lipsa lui.
9. **Lista de progress e busolă, nu coadă** — fiecare rând păstrat, actualizat pe loc.
10. **MAXHERMES e OUT definitiv din discuție.** Nu se atinge, nu se vorbește despre el. E preluat în handoff ca punct deschis, fără acțiune.
11. **R33 bimodal:** analiză → R0 (ratificarea lui Popy) → execuție. R0 e pentru **decizii** („privat sau public?"), nu pentru alegeri tehnice — acelea le iei tu.
12. **Nu muta nimic din vault fără R0.** (Popy, 19.10.2026) Mutările se propun, nu se execută. Excepție: ce a fost cerut explicit (vezi §5, arhivarea rapoartelor).

## 3. Starea curentă (măsurată 2026-10-20, 01:0x)

```
VAULT   G:\My Drive\GDrive-Second_Brain_PKMS   ramură master
        4490 fișiere urmărite în git (măsurat la 2026-10-20 03:32; comitarea automată rulează la 5 minute, deci cifra crește) · backup H: neatins
MOTOR   02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_manual\   (12 scripturi)
        + rula-din-task.ps1 = lansatorul taskurilor, stă pe C:
GHID    02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_guide\
SKILLURI _SYSTEM\Skills_MASTER_Folder\PKMS - administrare Skill\  |  PKMS - indexare Skill\
        + copii în C:\Users\apviz\.minimax\skills\  și  \agents\mavis\skills\
AUTOMAT. PKMS-Aliniere · PKMS-Watch · PKMS-GitAutoCommit · PKMS-DriveFS-AutoRepair
        (primele trei pornesc prin wrapper; al patrulea e deja pe C:)
```

## 4. Punctele deschise, în ordine de prioritate
**Starea zilnică, după reparul final (20.10.2026, ~02:05).** `watch.ps1` a fost reparat
**de două ori** în aceeași sesiune: întâi raportul înghețat (punctul 4 de mai jos), apoi
o **regresie a mea** — obiectul rezultat al fiecărei trepte a pierduse cele patru
proprietăți `Erori/Atentii/Nota/Detalii`, deci verdictul era **orb** la numărul de erori
(o treaptă cu 7 erori și cod de ieșire 0 ar fi raportat „Erori deocamdata: 0"), iar
raportul arăta câmpuri goale. Reparat, probat cu o bancă de 3 probe **cu contra-probă**
(defectul se reproduce cu codul vechi, deci proba poate eșua) și probat pe vaultul real.
Detalii în harta §13.


1. **Ramurile dublate „Knights Templar" — decizia e a lui Popy.** Inventarul e complet și măsurat (157 + 466 fișiere, 14,09 GB dublare, 92 SHA256 identice / 0 diferite). **NIMIC mutat, NIMIC șters.** El sortează manual, apoi cere actualizarea indexurilor. Calea lui e în `handoff-harta-implementarii.md` §11.7. **Căile exacte, de deschis direct:**

   - **A** (raftul de clienți): `G:\My Drive\GDrive-Second_Brain_PKMS\01_Projects\01-2-AP-ID.ro - AI Branding Work and Clients\01-2-2-AP-ID - Clients\Knights Templar`
     → 157 fișiere · 25,65 GB · 42 fișiere doar aici (11,56 GB)
   - **B** (raftul de lucru): `G:\My Drive\GDrive-Second_Brain_PKMS\01_Projects\01-6-Work_Folder (to sort)\01-6-2-Clienti\Knights Tempar`
     → 466 fișiere · 44,57 GB · 351 fișiere doar aici (30,48 GB)

   Inventarul complet, cu fiecare fișier și SHA256 pe căile comune: `D:\PKMS-tooling\handoff\knights-inventar-2026-10-20.txt` (61.121 B, 491 de rânduri).
   **Regula pentru sesiunea nouă: deschis, măsurat, și atunci nimic.** Popy sortează manual; până la decizia lui, zero mutări, zero ștergeri.
2. **Cauza degradărilor DriveFS (fostul „108").** Logurile **nu** sunt curate: milioane de `0x91` (= 145, „The directory is not empty"), toate scrise pe 19–20.10, cu precursor măsurat („slow content cache open taking 39.77s"). **De ce s-a blocat local store-ul: încă necunoscut.** Nu inventa cauza.
3. **Asimetria `align-index` ↔ `build-index`** (newline final în plus la L853 + blocuri derivate vechi). Nepatchată **prin decizie**: convergența contractuală e intactă (0 NEALINIAT), iar `PKMS-Aliniere` rulează zilnic. Dacă o patching, probă izolată pe `D:` mai întâi.
4. **Raportul zilnic — REPARAT 20.10.2026, nu mai e punct deschis.** `raport-ultima-rulare.txt` era înghețat la 18.10.2026: cauza era dublă — `watch.ps1` scria raportul **doar la final**, iar `PKMS-Watch` avea `ExecutionTimeLimit PT1H`, mai scurtă decât o rulare pe DriveFS, deci taskul era oprit înainte să scrie. Repar: raportul se rescrie după fiecare treaptă (verdict `IN CURS - N/3` cât timp rulează), limită `PT6H`, bancă de test 15/15 cu proba decisivă „oprire la mijloc → raport proaspăt”. Detalii în harta §12.
5. **Logarea DriveFS fără rotație** (~1 rând/5 min ≈ 105k rânduri/an).
6. **Cifrele §16.1** („2.311 rânduri reale", „133→19") — măsurate, dar sursa raportului e în afara repo-ului: `C:\Users\apviz\.minimax\vault-manifest\reziduri-indexuri-2026-10-19\`. Merită o indicație în `COTOR.md`.

## 5. Cum începi, concret

1. Citește `handoff-harta-implementarii.md` — **integral**, nu pe diagonale. Start cu **§11** (segmentul 2026-10-20).
2. Încarcă skillurile `pkms-vault-administration` și `pkms-vault-index`.
3. **Măsoară starea reală înainte să afirmi ceva:**
   ```powershell
   $V = 'G:\My Drive\GDrive-Second_Brain_PKMS'
   $M = "$V\02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_manual"
   $env:PKMS_VAULT = $V
   $env:PKMS_BACKUP = 'H:\Alex_Knowlege_Vault_BKUP_10-19-2026'

   git -C $V rev-list -n 1 HEAD          # HEAD local
   git -C $V ls-remote origin master      # singura verificare de push
   git -C $V status --porcelain

   powershell -NoProfile -ExecutionPolicy Bypass -File "$M\lint.ps1"          # poarta: exit 0 = verde
   powershell -NoProfile -ExecutionPolicy Bypass -File "$M\align-index.ps1" -CeVad   # census: 0 NEALINIAT
   powershell -NoProfile -ExecutionPolicy Bypass -File "$M\health-check.ps1"   # cifrele vii
   Get-ScheduledTask -TaskName 'PKMS-*' | ForEach-Object {
     $i = Get-ScheduledTaskInfo -TaskName $_.TaskName
     "{0,-24} state={1} result={2} next={3}" -f $_.TaskName, $_.State, $i.LastTaskResult, $i.NextRunTime
   }
   ```
4. **Nu muta nimic din vault** și nu rescrie istoricul. Taskul curent al lui Popy e să
   decidă soarta ramurilor dublate, cu măsurători, fără a inventa.
5. Cârligul DriveFS tratează simptomul, nu cauza — și **asta e spus limpede în `COTOR.md`**, nu ascuns. Nu-l prezenta ca soluție.
6. Porțile rulează între 3 și 4 minute pe DriveFS; `build-index` ~5–6 minute; sub sarcină, o rulare poate depăși 10 minute. Rulă-le în background dacă trebuie să lucrezi în paralel.

## 6. Ce NU faci

- Nu muți nimic din C: pe D: și invers — Popy a anulat explicit acest lucru („NU MUTI NIMIC!").
- Nu folosești `D:\Alex_Knowlege_Vault` — e folder stub, marcat „NU FOLOSIȘTE FOLDERUL ACESTA".
- Nu atingi `_QUARANTINE`, jurnalele `*-registru.txt`, `H:\…BKUP…`, bazele de metadate DriveFS de pe C:.
- Nu abordezi MAXHERMES.
- Nu rescrii comituri, nu ștergi, nu golești Recycle Bin-ul.
- Nu rulezi `git clean -fdx` / `git reset --hard` în vault — `.git` e în interiorul vaultului.
- Nu pui întrebări tehnice lui Popy. Decizi, explici, continui, și raportezi cu cifre măsurate.
- **Nu atingi ramurile dublate „Knights Templar"** până nu hotărâște el.

———
