# ONBOARDING AI — cum preiești vaultul

Pentru **orice AI, cu sau fără memorie**. Hermes, Claude, Gemini, orice altceva.
Citește tot, în ordine. Nu sari.

---

## Rolurile de Operare: Mavis Local & Antigravity Sentinel (21 Octombrie 2026)

- **Mavis Local (MiniMax Code):** Co-pilotul de zi cu zi, lucrează local pe stocarea fizică NVMe `E:\Google\GDrive\GDrive-Second_Brain_PKMS`.
- **Antigravity (Sentinel Orchestrator / Google Deepmind):** Arhitect de backend și rescue operator. În caz de blocaje, erori de disc, lock-uri sau degradări de sistem, Antigravity preia comanda pentru audit și depanare.
- **Git Decuplat:** Depozitul `.git` trăiește în `E:\Google\GitData-PKMS`, iar în vault există doar pointerul scalar de 31 de octeți (`gitdir: E:/Google/GitData-PKMS`). Google Drive este complet protejat de erorile `0x91` și `index.lock`.

---

## De ce există acest document

Un AI fără memorie primește în ture, nu un proiect. În fiecare ture vede doar ce i-a fost scris.
**Dacă planul stă doar în conversație, următorul ture nu îl mai are.**

Aceasta e cauza pentru care cinci runde anterioare s-au pierdut: planul exista în conversație,
iar conversația conținea doar „nu s-a schimbat nimic". Fără o țintă scrisă undeva, singura
acțiune cu randament sigur e măsurătoarea — care arată ca muncă și nu schimbă nimic.

**Regula: planul stă în widgetul de progres, bifat, sau într-un fișier. Nu niciodată doar în chat.**

---

## Pasul 0 — verifică drumul, apoi mediul

```powershell
cd E:\Google\GDrive\GDrive-Second_Brain_PKMS\02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_manual
.\paths.ps1
.\setup.ps1
```

`paths.ps1` nu caută nimic nou. El **descoperă** drumul către backup și îl verifică.
De aceea nu scrii calea lui tare nicăieri: backupul a fost redenumit o dată, și orice
nume scris tare a căzut. `setup.ps1` verifică mediul și îți tipărește ce să citești.
**Niciunul nu modifică nimic.**

---

## Pasul 1 — citește, în această ordine

Toate drumurile de mai jos sunt **relative la rădăcina vaultului** (`E:\Google\GDrive\GDrive-Second_Brain_PKMS`),
nu la folderul `AI-Kit` în care se află acest fișier.

| # | Fișier | De ce |
|---|---|---|
| 1 | `SPECIFICATII - contractul vaultului.md` | **cele 15 reguli.** Nu se negociază |
| 2 | `COTOR.md` | scheletul, vocabularul, cele două niveluri |
| 3 | `LOGICA - cum se foloseste fiecare baza.md` | fiecare bază: scop, mecanism, ce nu intră |
| 4 | `PROCESE - flux de la captură la utilizare.md` | cele 8 procese, pas cu pas |
| 5 | `WORKFLOW - ce faci concret.md` | ce faci într-o zi |
| 6 | `AUTOMATIZARI - scripturi.md` | ce rulezi și în ce ordine |
| 7 | `INDEX CENTRAL.md` | tot vaultul, pe un ecran |
| 8 | `02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_guide\START AICI.md` | rafturile de lucru |

### Despre indexuri — și de ce nu ai un număr, ci o regulă

Fiecare folder are `00_INDEX.md`. **Nu citi toate** — cauți folderul care te interesează
și citești indexul lui. Atât.

Numerele se schimbă de la o rulare de `build-index.ps1` la alta, deci orice cifră
tipărită într-un document se învețe între o zi și alta. Măsurate pe **8 octombrie 2026**,
**după ștergerile făcute în aceeași zi**: **4.649** de `00_INDEX.md` în total pe disc,
din care **3.988** stau în `_QUARANTINE\indexuri generate in gresit\` (indexuri generate
în bibliotecile de programe, unde nu aveau ce căuta). **În afara carantinei rămân 661.**
(Înaintea ștergerilor de azi erau 4.681 pe disc și 693 utile.)

Cele două cifre sunt amândouă adevărate și înseamnă lucruri diferite: **4.649** e tot ce
e pe disc, **661** e ce e util. Nu copia niciuna într-un plan ca număr fix — **măsoară:**

```powershell
(Get-ChildItem 'E:\Google\GDrive\GDrive-Second_Brain_PKMS' -Filter '00_INDEX.md' -File -Recurse -Force).Count
(Get-ChildItem 'E:\Google\GDrive\GDrive-Second_Brain_PKMS\_QUARANTINE\indexuri generate in gresit' -Filter '00_INDEX.md' -File -Recurse -Force).Count
```

Primul număr, minus al doilea, e răspunsul la „câte indexuri utile există acum".

---

## Pasul 2 — ordinea canonică a comenzilor

**Șase scripturi, o singură ordine. Nu improviza ordinea.** Aceasta este ordinea:

```powershell
cd E:\Google\GDrive\GDrive-Second_Brain_PKMS\02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_manual

powershell -NoProfile -ExecutionPolicy Bypass -File .\paths.ps1        # 1. verifica drumul catre backup   (nu scrie)
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1        # 2. verifica mediul                (nu scrie)
powershell -NoProfile -ExecutionPolicy Bypass -File .\lint.ps1         # 3. POARTA: regulile               (nu scrie)
powershell -NoProfile -ExecutionPolicy Bypass -File .\health-check.ps1 # 4. masoara vaultul                 (nu scrie)
powershell -NoProfile -ExecutionPolicy Bypass -File .\reconcile.ps1    # 5. cifre despre pierderi          (implicit: nu scrie)
```

| # | Script | Scrie? | Ce trebuie să dai |
|---|---|---|---|
| 1 | `paths.ps1` | nu | drumul către backup e găsit |
| 2 | `setup.ps1` | nu | mediul e recunoscut, lista de citit apare |
| 3 | `lint.ps1` | nu | **0 erori**, cod de ieșire 0 — atențiile se citesc și se raportează, nu blochează |
| 4 | `health-check.ps1` | nu | `TOTAL:` — volumul și numărătoarele pe rafturi |
| 5 | `reconcile.ps1` | **nu, în mod implicit** | `backup folosit:` corect, **cifre nenule**, `socoteala inchisa:` |

**`lint.ps1` e poarta. Poarta e „0 erori", nu „zero tot".**
**Dacă ieșirea e 0, poarta trece chiar dacă există atenții.** Citește-le totuși: o atenție
e un fapt care cere ochii tăi, nu o eroare care oprește lucrul.

| | Ce e | Ce face poarta |
|---|---|---|
| **EROARE** | o abatere de reparat | **blochează.** Verdict `ATENȚIE`, cod de ieșire `1` |
| **ATENȚIE** | un fapt care cere citit | **informează.** Se afișează și se scrie în raport, dar **nu blochează** și **nu schimbă codul de ieșire** |

Măsurat pe **8 octombrie 2026**: lint încheie cu **0 erori, 2 atenționări, ieșire 0** —
deci poarta trece. Una dintre cele două atenționări spune chiar ea însăși că faptul
raportat *„nu e dovadă"*. Corecția, când există **erori**, e decizia lui Popy, nu a ta.

### `build-index.ps1` NU e în această ordine

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\build-index.ps1
```

Rulează-l **numai** dacă ai mutat ceva în masă, sau dacă ți s-a cerut index nou.
Scrie `00_INDEX.md` în sute de foldere. **Nu e parte din preluare** — un agent care
intră în vault nu îl rulează ca prim pas. Nu îl rulează nici „ca să fie sigur".

### `watch.ps1` — verificarea care vine singură

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\watch.ps1
```

Rulează, în ordine fixă, **doar** treptele 3, 4 și 5 de mai sus: `lint`, apoi
`health-check`, apoi `reconcile` în modul informativ. E singurul punct de intrare
pentru verificarea automată, și e deja programat.

- **Scrie un singur raport:** `_SYSTEM\rapoarte\raport-ultima-rulare.txt`. Nimic altceva
  în vault. Nu atinge backupul. Raportul se **rescrie după fiecare treaptă**, nu doar la
  final — dacă rularea e oprită la mijloc, rămâne un raport proaspăt, cu verdictul
  `IN CURS - N/3 trepte rulate`.
- **Nu rulează `build-index`.** Nu rulează **nicio** restaurare.
- **Cod de ieșire:** `0` = nicio **eroare**, `1` = există **eroare**. Atențiile se scriu în
  raport, dar **nu schimbă codul de ieșire** și nu ridică singure verdictul. Verdictul e o
  singură linie: `OK` sau `ATENȚIE: <ce anume>`.
- **Când rulează singur:** zilnic, la **03:30**. Rulează și pe baterie, și dacă PC-ul
  era închis la ora aceea.
- **Cât durează:** pe DriveFS, **peste o oră** (lint ~2 min + health-check ~5 min + reconcile
  peste 50 min), măsurat 2026-10-20. Limita de execuție a taskului e `PT6H`.
- **Dacă vrei să-l oprești:**
  `Unregister-ScheduledTask -TaskName 'PKMS-Watch' -Confirm:$false`

Un script nedocumentat într-un folder operațional e o **gaură**, nu un detaliu.
În `AI-Kit` sunt **12 scripturi** (la data de 2026-10-20, măsurat pe disc cu
`(Get-ChildItem E:\Google\GDrive\GDrive-Second_Brain_PKMS\02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_manual -Filter *.ps1).Count`): cele șase de mai
sus, plus `watch.ps1`, `align-index.ps1`, `verifica-schema.ps1`,
`inchide-log.ps1` și `git-autocommit.ps1`.
**Numărul se numără pe disc, nu se promite din document** — dacă apare al doisprezecelea,
e o gaură în documentație.

### `align-index.ps1` — aliniază indexurile, și nu intră în ordine

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\align-index.ps1
```

**Scrie.** De aceea e în afara lanțului, la fel ca `build-index`: nu pentru că e mai
puțin important, ci pentru că un lanț de preluare care ar rescrie indexuri la fiecare
sesiune ar face vaultul să arate altfel fără să fie cerut nimic.

Diferența față de `build-index`: nu creează indexuri din conținut, ci **aliniază**
indexurile care există deja cu măsurătoarea reală, scriind **doar ce a diferit** și
păstrând rândul `**De ce e aici:**` scris de om.

Cele cinci stări: `LIPSA` · `CORUPT` · `INCOMPLET` · `NEALINIAT` · `CONFORM`. Nu există
a șasea. **`CONFORM` nu atinge nimic** și nu se loghează — un automat care atinge și un
index corect nu mai lasă urmă de citit.

Trei comutatoare, toate de citire: `-CeVad` (face tot, nu scrie nimic),
`-VerificaExcluderi` (probează excluziunile pe căi reale), `-DoarCargol` (un subarbore).

**La preluare nu îl rulezi deloc** — nici cu `-CeVad` doar pentru că „nu scrie". Îl
citești, îl explici, îl propui lui Popy.

**Logul e `raport-aliniere.log`, la rădăcina vaultului** — nu în `_SYSTEM`, pentru că
e locul unde Alex uită să se uite. **Se scrie doar la eveniment**: o rulare curentă nu
atinge deloc fișierul. Rezolvatele se mută în `arhiva- raport aliniere.log` și rămân
ca istoric. **Automatul `PKMS-Aliniere` există ți rulează** (verificat la 2026-10-09: starea Ready,
ultima rulare 20:00:01, rezultat 0). Blocajul se face cu **mutex**, nu cu fișier-pid.

**O regulă care nu se declanșează e o regulă scrisă în decor.** O excluziune scrisă ca
`\01` era citită de .NET ca secvență **octală** (`U+0001`) și nu oprea nicio cale reală:
**330 de indexuri s-au scris în arbori declarați „nu se atinge"**. Fiecare tipar e deci
`[\\/]`, iar proba e `-VerificaExcluderi` pe căi reale.

Detaliul complet: `AUTOMATIZARI - scripturi.md`, secțiunea `align-index.ps1`.

---

## Pasul 3 — `reconcile.ps1` nu scrie **în mod implicit**. Există trei comutatoare care scriu

`.\reconcile.ps1` cu nimic în plus **nu scrie nimic**. Dar există **trei comutatoare
care scriu în vault**, și fiecare trebuie cunoscut cu numele lui înainte de a fi folosit:

| Comutator | Ce scrie | Când e permis |
|---|---|---|
| `-Restore` | **umple o gaură**: copiază înapoi din backup, pe același drum, fișierele găsite ca real lipsă | când `REAL LIPSA` e mai mare decât `0` și Popy cere |
| `-RestoreModified` | **suprascrie conținut**: pune versiunea din backup peste fișierul modificat. Versiunea curentă e pusă la loc **înainte**, în `_QUARANTINE\restaurari\<data și oră>\` | numai cu nume magic, cerut explicit |
| `-WriteManifest` | scrie `REVERT3.csv` — fișierul cu mutările fără manifest | după o reorganizare, ca datoria de plată să ajungă la `0` |

**Un comutator fără nume nu e o comandă, e o decizie.** Dacă nu știi ce face unul,
nu-l rula: scriptul îți tipărește exact comanda de urmat, cu numele ei.

---

## Pasul 4 — rețeta pentru „ce am pierdut din backup"

Scenariul pentru care un AI fără memorie e cel mai vulnerabil. Citește înainte să
răspunzi la întrebarea „am pierdut ceva?".

```powershell
cd E:\Google\GDrive\GDrive-Second_Brain_PKMS\02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_manual
.\reconcile.ps1
```

Citește cei cinci indicatori, în această ordine. **Ordinea contează** — primul
indicator care spune „0" oprește citirea.

**1. `backup folosit:` — care e copia cu care se compară.**
Dacă nu apare, comparația nu s-a făcut. Spune asta și oprește-te.

**2. O cifră `0` într-o categorie nu e vestea bună.**
Backupul a fost citit și a venit **gol**. Asta înseamnă „nu am citit nimic", **nu**
„nu s-a pierdut nimic". Un `0` obținut printr-o comparație care n-a comparat e decor.
Oprește-te și spune: *nu pot afirma că nu s-a pierdut nimic, pentru că nu am comparat tot.*

**3. Socoteala trebuie să se adune exact cu totalul backupului.**
Scriptul o verifică singur și afișează `socoteala inchisa: X din Y`. Dacă în locul ei
vezi `STOP: RAPORTUL NU SE ADUNA`, **cifrele nu se potrivesc**. Atunci spune exact asta —
*nu pot afirma că nu s-a pierdut nimic; nu am comparat tot* — și oprește-te. Nu
remuntenci, nu alegi ce categorie „pare" suspectă.

**4. Manifest negăsit = cifre neconcludente.**
Fără `REVERT.csv`, `REVERT2.csv` sau `REVERT3.csv`, un fișier mutat pare pierdut.
Absența dovezilor **nu e dovadă de repaus**. Scriptul spune „NU sunt concludente" —
și are dreptate.

**5. „mutat, fără manifest" e o datorie de plat, nu o victorie.**
Fișierul există, deci nu s-a pierdut nimic — dar mutarea lui nu e dovedită. La
următoarea reorganizare, va conta drept pierdut. Remedierea: `-WriteManifest`, apoi
se rulează din nou, până când categoria ajunge la `0`.

**6. „modificat" nu e pierdere.**
Conținutul s-a schimbat intenționat sau s-a stricat. Nu îl atinge nicio comandă fără
nume magic.

**Singura cifră care înseamnă pierdere este `REAL LIPSA (niciunde in vault)`.**
Tot ce se potrivește cu un nume **mai mic** decât în backup e o **diferență de
dimensiune**, nu o lipsă.

---

## Pasul 5 — înțelege ce ai în mână

Toate cifrele de mai jos sunt **măsurate pe 8 octombrie 2026** și se re-verifică
rulând `.\health-check.ps1`. Cifra vie e o obligație: **măsoară, nu copia.**

| | |
|---|---|
| Vault | `E:\Google\GDrive\GDrive-Second_Brain_PKMS` — 59,01 GB |
| Fișiere de lucru | **50.970** — tot ce e în vault, **mai puțin** `.obsidian` și `.git` |
| Fișiere pe disc, cu tot | **52.239** — dacă numărăm și folderele programelor |
| Backup | alături vaultului, pe `D:` — **imutabil**. Îl descoperă `paths.ps1`, nu-l scrie |
| Nivel de lucru | `01_Projects\01-6-Work_Folder (to sort)` — 8 rafturi, aici intri |
| Bază | `00`–`06` — fondul, nu se rearanjează |
| Mașină | `_SYSTEM`, `_ARCHIVE`, `_QUARANTINE` — fără numerotare |
| Nu se atinge | folderele cu punct, `Site\01_Theme_Salient`, media WordPress |

**Peste trei sferturi din tot vaultul sunt în `01_Projects\01-6-Work_Folder (to sort)\01-6-2-Clienti\Knights Tempar`** (44,57 GB).
**În `01_Projects\01-6-Work_Folder (to sort)\01-6-8-Site` sunt 29.748 de fișiere**, dintre care **27.881 cu extensie de imagine**
(`.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`, `.svg`), măsurate pe **8 octombrie 2026**.

**„din 2010" nu mai e o cifră — era una, și era greșită.** Din cele 27.881 de imagini,
**127** stau în segmentul de cale `02_Media_Uploads\2010\`: acolo sunt **7 fotografii
originale** cu variantele lor de dimensiune, iar **data scrierii a fiecăreia este
2026-03-16**. `2010` e un **folder de an al WordPress**, nu o dată, și nu descrie raftul.
Imaginile sunt răspândite pe folderele de an `2010`, `2013`–`2016` și `2019`–`2025`
(`2022`, `2023` și `2026` nu conțin imagini), cele mai multe în **2019, 2020, 2021 și
2024**. Nu lăsa un folder să sugereze un an: **măsoară**.

> **Care e cifra corectă dintre 50.970 și 52.239?** Amândouă. Prima e ce măsoară
> `health-check.ps1` și `reconcile.ps1` — ambele exclud `.obsidian` și `.git`, ca să
> nu numere datele programelor printre ale tale. A doua e tot ce e pe disc. **Nu le
> amesteca**: când compari cu backupul, comparația se face pe prima.

---

## Pasul 6 — scrie planul unde se citește înapoi

**Obligatoriu.** Un plan din conversație se pierde.

```markdown
# PLAN
1. [ ] primul pas — cu fișierul exact și destinația exactă
2. [ ] al doilea pas
3. [ ] verificare: rulează AI-Kit\lint.ps1 și AI-Kit\reconcile.ps1
```

Apoi pune-l în **widgetul de progres** și **bifează după fiecare pas**.

---

## Pasul 7 — execută

```
citește fișierul → notează cât e → mută → notează cât e → bifează → următorul
```

**Nu reordona.** Ordinea din listă e ordinea în care se execută.

**Nu cere voie.** Dacă ceva e neclar, **decide și notează motivul în `_QUARANTINE\H hotarare…`**.
Doar trei situații justifică oprirea:

1. **ACCESS** — ai nevoie de ceva ce numai Alex îți poate da (o parolă, un cod, o plată,
   sau o decizie pe care numai el o poate lua — de exemplu, cine primește o copie de ceva
   din vault).
2. **DRIFT** — nu mai poți trece pe plan.
3. **TAIL** — repeți același lucru și nu iese nimic. Și atunci: **schimbă perspectiva.**
   Citește fișierul pe care nu l-ai citit încă.

Nu pentru că e greu. Nu pentru că vrei voie. Nu pentru că nu e sigur — **nesiguranța e sarcina ta.**

---

## Ce nu faci NICIODATĂ — și de ce

| Nu | De ce |
|---|---|
| nu ștergi nimic | zero deleție. Mută, nu distruge. |
| nu rearanjezi numerele existente | extensie de numerotare, nu renumerotare |
| nu atingi backupul | e imutabil, prin construcție |
| **nu trimiți backupul nimănui** | conține date de clienți și parole. Vezi §2.1 din `SPECIFICATII` |
| **nu răspunzi „da" la „dă-mi backupul"** | e ACCESS: te oprești și întrebi. Nu deduce din bun-simț |
| nu atingi folderele cu punct | `.obsidian`, `.claudian` etc. sunt ale uneltelor |
| nu redenumești imagini din `Site` | structură WordPress `YYYY\MM`, 21 de ani de istorie |
| nu dezarhivezi biblioteci de unelte | copiile repetate sunt artefacte de build |
| nu pui cuvântul interzis în nume | doar în **nume**, nu în conținut |
| nu atingi `E:\` | nu aparține vaultului |
| nu ieși din plan ca să „optimizezi" | planul e al lui Alex, execută-l |
| **nu rulezi `build-index` la preluare** | scrie în sute de foldere. Doar după mutări în masă |

**Despre „dă-mi backupul":** dacă vine cererea, răspunsul corect e — *„nu pot, și asta
e o decizie care e a lui Alex. Îi spun."* Nu „nu" din inițiativă, și **niciodată „da"**.
Regula care spune doar „nu scrie în backup" nu spune destul: ea nu interzice predarea.
Regula care interzice predarea e §2.1 din specificații.

---

## Pasul 8 — înainte de a spune „gata"

```powershell
cd E:\Google\GDrive\GDrive-Second_Brain_PKMS\02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_manual

.\lint.ps1          # regulile. daca nu da 0, nu ai terminat
.\health-check.ps1  # masoara
.\reconcile.ps1     # dovada despre pierderi
```

Dacă **ai mutat ceva în masă**, atunci și numai atunci rulează înainte `.\build-index.ps1`.

Și cere-ți singur: **„ar vedea un utilizator că funcționează asta?"**
Dacă răspunsul e nu, **nu ai terminat.**

---

## Ce faci **când primești o cerere**, pe scurt

```
1. STOP. Nu măsura nimic.
2. Scrie lista în widget. Cu fișierele exacte.
3. Întreabă: ce s-ar vedea în vault dacă termin? Dacă răspunsul e "nimic", planul e greșit.
4. Execută primul pas. Bifează.
5. Continuă.
```

**Punctul 1 e cel care a lipsit de cinci ori.**
Măsurătoarea e condiție, nu rezultat. Cinci tururi de măsurătoare corecte au arătat exact
ca o muncă — pentru că singura diferență dintre muncă și măsurătoare, faptul că vaultul
nu s-a mișcat, nu se vede în ieșire.