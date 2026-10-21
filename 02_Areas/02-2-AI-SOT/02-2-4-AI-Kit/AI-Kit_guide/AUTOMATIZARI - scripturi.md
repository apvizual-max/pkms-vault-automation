# AUTOMATIZĂRI — scripturile

Sunt în `AI-Kit\`. **Douăsprezece scripturi.** Rulează-le din PowerShell:

```powershell
cd "E:\Google\GDrive\GDrive-Second_Brain_PKMS\02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_manual"
```

---

| Script | Ce face | Modifică? |
|---|---|---|
| `paths.ps1` | descoperă backupul și excepțiile, apoi le verifică | nu |
| `setup.ps1` | verifică mediul, îți spune ce să citești | nu |
| `lint.ps1` | verifică regulile, raportează abaterile | nu |
| `health-check.ps1` | starea vaultului într-un raport scurt | nu |
| `reconcile.ps1` | compară cu backupul, raportează pierderile | **nu în mod implicit** — doar cu `-Restore`, `-RestoreModified` sau `-WriteManifest` |
| `build-index.ps1` | regenerează indexurile din conținutul real | da, doar `00_INDEX.md` |
| `watch.ps1` | rulează singur `lint` → `health-check` → `reconcile` și scrie un raport | da — **un singur raport**, nimic altceva |
| `align-index.ps1` | **aliniază** indexurile care există deja cu măsurătoarea reală | da — doar `00_INDEX.md`, arhiva lui și logul |
| `verifica-schema.ps1` | **verifică forma**, nu existența: titlu, motiv, cele patru blocuri, 2—12 cuvinte cheie | **nu** — doar citește |
| `inchide-log.ps1` | recitește logul, re-măsoară fiecare folder și spune ce e **DESCHIS acum**; cu `-Arhiveaza` mută rezolvatele în arhivă | implicit **nu** — doar cu `-Arhiveaza` |
| `git-autocommit.ps1` | comită singur, în repo git, ce a rămas necomitat — ca panoul `Changes` să nu aibă ce arăta | **da, în git** — patru porți înainte: secrete pe nume, secrete pe conținut, căi interzise, timp de așezare |
| `rula-din-task.ps1` | **lansatorul** taskurilor: stă pe `C:`, așteaptă ca `G:` să fie montat, apoi rulează alt script și îi propagă codul | **da** — rulează scriptul însuși, cu `PKMS_VAULT` și `PKMS_BACKUP` setate |

**Dacă în `AI-Kit` apare un script pe care tabelul nu îl numește, e o gaură în documentație,
nu un detaliu.** Numărul de scripturi se numără pe disc, nu se promite din document:

```powershell
(Get-ChildItem .\AI-Kit_manual -Filter *.ps1).Count
```

**La data de 2026-10-20: 12**, măsurat pe calea nouă
`02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_manual\`. *Cifra veche din acest
document spunea `D:\Alex_Knowlege_Vault\AI-Kit` — o cale care nu mai există de
când vaultul a fost mutat pe Drive. Numărul de scripturi se numără pe disc, la
calea de acum; un număr corect, spus la o cale moartă, nu ajută pe nimeni.*

---

## Ordinea canonică — o singură, scrisă identic în toate documentele de predare

```powershell
cd "E:\Google\GDrive\GDrive-Second_Brain_PKMS\02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_manual"

powershell -NoProfile -ExecutionPolicy Bypass -File .\paths.ps1        # 1. verifica drumul catre backup   (nu scrie)
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1        # 2. verifica mediul                (nu scrie)
powershell -NoProfile -ExecutionPolicy Bypass -File .\lint.ps1         # 3. POARTA: regulile               (nu scrie)
powershell -NoProfile -ExecutionPolicy Bypass -File .\health-check.ps1 # 4. masoara vaultul                 (nu scrie)
powershell -NoProfile -ExecutionPolicy Bypass -File .\reconcile.ps1    # 5. cifre despre pierderi          (implicit: nu scrie)
```

| # | Script | Rolul lui, într-o propoziție |
|---|---|---|
| 1 | `paths.ps1` | nu găsește calea, **o verifică** |
| 2 | `setup.ps1` | verifică mediul, **nu modifică nimic** |
| 3 | `lint.ps1` | **poarta** — dacă nu dă 0, nu începi |
| 4 | `health-check.ps1` | **măsoară** |
| 5 | `reconcile.ps1` | **singurul care produce cifre despre pierderi** |

**`build-index.ps1` nu e în această ordine.** Se rulează **doar după mutări în masă sau
la cerere de index nou**. Nu e parte din preluare.

**Nici `align-index.ps1` nu intră în această ordine** — și asta e important, pentru că
altfel pare doar „încă un pas de verificare". Nu e: `align-index` **scrie**. Un lanț de
preluare care ar rescrie indexuri la fiecare sesiune ar face vaultul să arate altfel fără
să fi fost cerut nimic, iar un automat care atinge și un index corect nu mai lasă urmă
de citit.

| Script | De ce nu e în lanț |
|---|---|
| `build-index.ps1` | **creează** indexuri din conținut — scrie în sute de foldere |
| `align-index.ps1` | **repară** indexuri existente — scrie, deși doar ce a diferit |
| `verifica-schema.ps1` | nu scrie nimic, dar arată cât de schemă e datorie — de aceea nu e în lanț |
| `inchide-log.ps1` | implicit nu scrie, dar cu `-Arhiveaza` **mută evenimente** din log în arhivă — iar hotărârea de a muta e a lui Alex |
| `git-autocommit.ps1` | nu atinge vaultul deloc, dar **scrie în istoricul git** — și poate **refuza**, caz în care panoul `Changes` rămâne plin tocmai când plasa era chemată să-l golească. De aceea rulează la 5 minute, nu la fiecare scriere |
| `rula-din-task.ps1` | nu e o treaptă de verificare, e **lansatorul**: stă pe `C:`, ca să poată porni și când `G:` nu e montat; așteaptă calea, apoi rulează alt script |

Rulă-le **la cerere** sau prin automatul dedicat (`PKMS-Aliniere`), niciodată
„ca să fie sigur". `watch.ps1` rămâne singurul punct de intrare al verificării.

---

## `setup.ps1` — întâi, la preluare

```powershell
.\setup.ps1
```

Verifică că vaultul și backupul există, și îți tipărește documentația în ordinea de citit.
**Nu modifică nimic.**

---

## `lint.ps1` — verifică regulile

```powershell
.\lint.ps1
```

Verifică, în ordine:
- **backupul există și e neatins** — pragul e ancorat la *data copierii backupului însuși*, nu la o
  cifră scrisă tare. Măsurat 2026-10-19: backupul e pe **`H:`**, nu pe `D:`, și e descoperit din
  `$env:PKMS_BACKUP`, apoi pe toate volumele. **Mesajele poarții nu numesc un volum** — un mesaj
  care trimite la volumul greșit e mai rău decât unul care nu trimite deloc.
- backupul e **în afara vaultului** (altfel ar fi o copie care se șterge odată cu originalul)
- `_SYSTEM` / `_ARCHIVE` / `_QUARANTINE` n-au numerotare
- cuvântul interzis `LUCURARE` nu apare în **nume** (nu și în conținut)
- stratul de lucru se numește **`01_Projects`** (nu `10_Work` — reapariția lui e o regresie)
- fiecare folder de conținut are `00_INDEX.md`
- documentația există, căutată **după nume** în rădăcină sau în `AI-Kit_guide`
- **niciun script și niciun document nu scrie calea de backup tare**
- **cele două copii ale onboarding-ului sunt octet cu octet identice**
- **encoding: orice script al motorului cu caractere ne-ASCII are BOM UTF-8** (secțiunea 9)

Ultima a fost adăugată 2026-10-19, după ce `watch.ps1` s-a dovedit singurul script fără BOM:
PowerShell 5.1 îl citea ca ANSI și afișa `ATENȚIE` corupt (`021A` → `00C8 0161`), **în timp ce
parse-ul raporta 0 erori**. Deci poarea compară **octeți**, nu parseză. Un script doar-ASCII fără
BOM e sănătos și nu e acuzat — o poartă care urluiește pe fișiere sănătoase învață omul s-o
ignoreze.

Poarta are și o **gardă de citibilitate**: dacă DriveFS se degradează *în timpul* rulării, citirile
picate se numără și se raportează ca „vaultul nu a putut fi citit complet". Altfel poarta ar da
`0` pentru ceva ce n-a citit.

Iese cu `1` dacă sunt erori, `0` dacă totul e curat.
**Nu corectează nimic** — corectia e decizia lui Alex.

---

## `health-check.ps1` — starea de sănătate

```powershell
.\health-check.ps1
```

Raport scurt: cât e în fiecare raft, cât în bază, cât în rafturile mașinii, totalul,
și cele două semne de sănătate:

```
Inbox neprocesate: N   (0 = bine, ai procesat tot)
In Progress:        N   (0 = bine, nu ai nimic neterminat)
```

---

## `reconcile.ps1` — dovada că nu s-a pierdut nimic

```powershell
.\reconcile.ps1
```

Compara vaultul cu backupul, **fără să scrie nimic în backup**.
Iese cu `1` dacă găsește pierderi **sau** dacă socoteala nu se închide.

### Cele cinci categorii, și de ce sunt cinci

Un backup e o fotografie de **înainte** de reorganizare, deci vaultul *nu arată la fel* cu
backupul. „Nu se potrivește" nu înseamnă „s-a pierdut". De aceea le desparte:

| Categorie | Ce înseamnă |
|---|---|
| **la același drum** | nu s-a mișcat. Compară dimensiunea — diferența înseamnă **conținut modificat** |
| **mutat, înregistrat în manifest** | `REVERT.csv` (fișier cu fișier) sau `REVERT2.csv` (directoare, aplicate ca prefix) |
| **mutat, fără manifest** | găsit în vault după nume + dimensiune. Scriptul arată **unde a ajuns** |
| **mutat și redenumit** | recunoscut după sufixul numelui — martorii din `_SYSTEM` primesc prefix |
| **real pierdut** | nu e niciunde în vault. **Doar astea se numără pierderi** |

**Potrivirea se face pe drum, nu pe dimensiune.** Pe dimensiune, un fișier șters dispărea
într-un alt fișier de aceeași mărime, iar scriptul raporta „nu s-a pierdut nimic".

**Cerința de socoteală.** Categoriile trebuie să se adune cu totalul din backup. Dacă nu se
adună, scriptul se oprește și spune *„nu am comparat tot"*. Un zero obținut printr-o buclă
care nu s-a executat nu e repaus, e decor.

### Cele patru ieșiri

```powershell
.\reconcile.ps1                 # raportează, nu scrie nimic
.\reconcile.ps1 -Restore        # copiază înapoi cele REAL lipsă, pe numele proprii
.\reconcile.ps1 -WriteManifest  # scrie mutările fără manifest în REVERT3.csv
.\reconcile.ps1 -RestoreModified # reface fișierele SUPRASCRISE
```

`-Restore` **copiază** înapoi, pe același drum, din backup. Nu mută, nu șterge, nu atinge
backupul.

### De ce `-RestoreModified` e separat, și nu e înfipt în `-Restore`

Fișierele **modificate** nu sunt pierderi. Conținutul lor s-a schimbat intenționat, sau
s-a stricat — și în al doilea caz, versiunea nouă poate fi cea mai bună. De aceea
nicio comandă nu atinge un fișier modificat fără să fie cerut **nume magic**.

Când îl ceri, se întâmplă în ordinea asta:
1. versiunea ta de acum e copiată în `_QUARANTINE\restaurari\<data și oră>\`
2. abia apoi vine peste ea versiunea din backup

**Deci nici aici nu se pierde nimic.** Poți oricând să te întorci la ce era înainte.

**De ce `-WriteManifest` există:** rundele târzii (note la rădăcină → `00_Inbox`, secrete →
`_ARCHIVE`, reziduuri → `_QUARANTINE`) nu au fost scrise în manifest. Fără el, la următoarea
reorganizare acele fișiere chiar vor conta drept pierdute. Rulează-l o dată după o
reorganizare, apoi rulează din nou — datoria trebuie să ajungă la **0**.

**`REVERT3.csv` este citit înapoi**, la fel ca `REVERT.csv`: fișier cu fișier, ca mapare
drum vechi → drum nou. De aceea, după ce îl scrii, categoria „mutat, fără manifest" scade
la zero și mutările trec la „mutat, înregistrat".

### Ce citeste scriptul ca să poată distinge mutat de pierdut

| Manifest | Ce conține | Cum se aplică |
|---|---|---|
| `REVERT.csv` | fișier cu fișier | mapare exactă de drum |
| `REVERT2.csv` | **directoare** | **ca prefix**, nu ca cheie exactă |
| `REVERT3.csv` | fișier cu fișier, scris de `-WriteManifest` | mapare exactă de drum |

Dacă manifestul lipsește, scriptul **spune că nu e concludent** și nu afirmă că nu s-a pierdut
nimic. Absența dovezilor nu e dovadă de repaus.

### Rețeta: „ce am pierdut din backup?"

Citește cei indicatorii în ordine. **Oprește-te la primul care spune „0".**

1. **`backup folosit:`** — fără el, comparația nu s-a făcut. Spune asta și oprește-te.
2. **O cifră `0` într-o categorie nu e vestea bună.** Backupul a fost citit și a venit gol.
   Înseamnă „nu am citit nimic", **nu** „nu s-a pierdut nimic". Afirmația ar fi o minciună.
3. **Socoteala trebuie să se adune exact cu totalul backupului** — `socoteala inchisa: X din Y`.
   Dacă apare `STOP: RAPORTUL NU SE ADUNA`, spune exact: *nu pot afirma că nu s-a pierdut
   nimic — nu am comparat tot* — și oprește-te. Nu remuntenci, nu alegi categoria „suspectă".
4. **Manifest negăsit** → cifrele **nu sunt concludente**. Fără el, un fișier mutat pare pierdut.
5. **„mutat, fără manifest"** e **o datorie de plat, nu o victorie**. Fișierul există, dar
   mutarea nu e dovedită: la următoarea reorganizare va conta drept pierdut. Remediere:
   `-WriteManifest`, apoi rulează din nou, până când categoria ajunge la `0`.
6. **„modificat" nu e pierdere.** Conținutul s-a schimbat intenționat sau s-a stricat.

**Singura cifră care înseamnă pierdere este `REAL LIPSA (niciunde in vault)`.** Orice potrivire
cu un nume **mai mic** decât în backup e o **diferență de dimensiune**, nu o lipsă.

### Cele trei comutatoare care scriu — repetat, pentru că e cel mai uitat lucru

Doar apelarea goală nu scrie nimic:

| Comutator | Ce scrie |
|---|---|
| `-Restore` | umple o gaură de fișiere dispărute — copiază înapoi din backup, pe același drum |
| `-RestoreModified` | suprascrie conținutul; versiunea curentă e pusă la loc **înainte**, în `_QUARANTINE\restaurari\<data și oră>\` |
| `-WriteManifest` | scrie `REVERT3.csv` — mutările care nu aveau dovadă |

„`reconcile.ps1` nu scrie" e adevărat **doar în mod implicit**. Un agent căruia i se spune așa
poate trece `-WriteManifest` crezând că e inofensiv. **Corect e: „nu scrie în mod implicit",
plus enumerarea fiecărui comutator cu ce face.**

---

## `build-index.ps1` — indexurile

```powershell
.\build-index.ps1
```

Scrie `00_INDEX.md` în fiecare folder, **din conținutul real**, nu din memorie:
subfoldere, tipuri de fișiere cu dimensiuni, și cele mai mari fișiere.

- folder cu **≤60 de fișiere** → tabel complet
- folder cu **peste 60** → grupat pe tip, plus cele mai mari 20. **Complet, dar compact.**

Apoi scrie `INDEX CENTRAL.md` la rădăcină, însumând de jos în sus.

**Nu atinge:** folderele cu punct, plugin-urile, `.git`, tema cumpărată,
structura WordPress `YYYY\MM`, bibliotecile de programe din `_SYSTEM\Skills`,
folderul `indexuri generate in gresit\` din carantină.

**Nu îl rulează nimeni la preluare.** Scrie în sute de foldere, iar singurul efect al
unei rulări la preluare e un vault care arată altfel fără să fi fost cerut nimic.
Rulează-l **doar** după mutări în masă sau la cerere de index nou.

---

## `paths.ps1` — de ce există

Backupul a fost redenumit o dată: `CopyBACKUP` → `Backup - 10-08-2026`.
Toate scripturile au căzut, fiindcă aveau numele scris tare.

`paths.ps1` **descoperă** backupul: mai întâi verifică numele vechi, apoi caută în rădăcina lui `D:`
orice folder care începe cu `Alex_Knowlege_Vault` și nu e vaultul însuși.

**Rolul lui în ordine:** nu găsește calea, ci **o verifică**. De aceea nu o scriem tare
nici în scripturi, nici în documentele de predare — `lint.ps1` urmărește exact asta.

Se poate forța:

```powershell
$env:PKMS_VAULT  = 'D:\Alex_Knowlege_Vault'
$env:PKMS_BACKUP = '<drumul descoperit de paths.ps1>'
```

---

## `watch.ps1` — singurul punct de intrare al verificării

```powershell
.\watch.ps1
```

Nu e „un script care face mai multe". E **un singur punct de intrare**, chemat de om
sau de ceas. Rulează în ordine fixă trei trepte care **nu scriu în vault**:

1. `lint` — regulile de denumire, cuvântul interzis, legăturile, copiile de onboarding.
2. `health-check` — numerele vii ale vaultului.
3. `reconcile` — socoteala cu backupul, în modul informativ, fără restaurări.

### Ce scrie

**Un singur fișier:** `_SYSTEM\rapoarte\raport-ultima-rulare.txt` (și folderul lui, dacă lipsea).
**Nimic altceva în vault.** Backupul primește citiri și atât.

**Raportul se rescrie după fiecare treaptă, nu doar la final.** Măsurat 2026-10-20: pe
vaultul de pe DriveFS, `reconcile` (treapta 3) durează peste 50 de minute, iar taskul era
oprit de limita lui de 1 oră **înainte** să ajungă la scriere — raportul zilnic rămăsese
înghețat la 18.10, cu căile vechi de pe `D:`. Cu scrierea după fiecare treaptă, raportul
e proaspăt chiar dacă rularea e oprită la mijloc; verdictul are atunci prefixul
`IN CURS - N/3 trepte rulate`, ca un raport pe jumătate să nu pară „OK”.

### Ce NU intră în automatism — și de ce

- **`build-index.ps1` nu rulează aici.** Scrie sute de indexuri. Se rulează cu mâna,
  doar după mutări în masă sau la cerere.
- **Nicio restaurare.** `reconcile -Restore` și `-RestoreModified` rămân comenzi cu nume.
  Un automatism care repară nu distinge; un om distinge.
- **Nicio scriere în backup.**

### Codul de ieșire

`0` = totul bine. `1` = există o abatere. Verdictul e **o singură linie**:
`OK` sau `ATENȚIE: <ce anume>`.


**Măsurat 2026-10-20: verdictul trebuie să vadă NUMERUL de erori, nu doar codul de ieșire.**
O regresie a mea (obiectul rezultat al treptelor pierduse `Erori/Atentii/Nota/Detalii`)
a făcut ca o treaptă cu 7 erori și cod de ieșire 0 să raporteze „Erori deocamdata: 0".
Reparat, și probat cu o bancă de 3 probe cu contra-probă: câmpurile goale ale raportului
sunt un semn de alarmă, nu o simplă lipsă de rând.


### Când rulează singur

- **Zilnic, la `03:30`.** Taskul se numește `PKMS-Watch`.
- Rulează și **pe baterie**, și **dacă PC-ul era închis** la ora aceea.
- Durata pe vaultul de pe DriveFS, măsurată 2026-10-20: **lint ~2 min · health-check ~5 min ·
  reconcile peste 50 min** — deci **o oră și jumătate**, nu 1 m 26 s. Cifra veche era de pe
  vaultul de pe `D:`.
- **Limita de execuție a taskului: `PT6H`** (era `PT1H` — mai scurtă decât o rulare pe
  DriveFS, deci taskul se oprea singur înainte să scrie raportul).

Dacă vrei să-l oprești:

```powershell
Unregister-ScheduledTask -TaskName 'PKMS-Watch' -Confirm:$false
```

---

## `align-index.ps1` — alinierea automată a indexurilor

```powershell
.\align-index.ps1
```

Aliniază indexurile care **există deja** cu măsurătoarea reală a folderului. Nu le
creează din conținut ca `build-index` — le repară, **scriind doar ce a diferit**, și
păstrând rândul `**De ce e aici:**` scris de om.

Fără AI, fără rețea, fără cost, fără scriere în backup.

### Cele cinci stări

Fiecare folder eligibil ajunge în **exact una**. Nu există a șasea.

| Stare | Cum se recunoaște | Ce face automatul | Se loghează? |
|---|---|---|---|
| **LIPSA** | folderul există, `00_INDEX.md` nu | creează indexul complet, pe schemă | **nu** — s-a rezolvat |
| **CORUPT** | gol, trunchiat sau fără titlu | îl reface **de la zero** și spune ce a pierdut | **da** — s-a pierdut ceva |
| **INCOMPLET** | are titlu și motiv, îi lipsește un bloc | îl completează, păstrând ce are | **da** |
| **NEALINIAT** | are toate blocurile, măsurătoarea nu mai corespunde | rescrie **doar** blocurile derivate | **da** — realitatea s-a schimbat |
| **CONFORM** | totul corespunde | **nu atinge nimic** | **nu** |

Rândul `CONFORM` e cel mai important. Un automat care atinge și un index corect nu mai
lasă urmă de citit, și nu se mai poate vedea când strică ceva.

### Ordinea fixă din script

1. **Închide ușa în urma lui** — mutex, `WaitOne(0)`. Dacă mai rulează o aliniere, iese tăcut.
2. **Măsoară** — fiecare folder eligibil: câte fișiere, câte subfoldere, cine.
3. **Clasifică** — în cele cinci stări de mai sus.
4. **Repară** — bloc cu bloc, păstrând motivul.
5. **Scrie** — doar ce a diferit, **după** ce a pus vechea versiune în
   `_SYSTEM\arhiva-indexe\<data>_<ora>\` — folderul poartă ora rulării, ca
   „înapoi un pas” să însemne înapoi **ultima scriere**, nu înapoi azi.
6. **Raportează** — în log, **numai dacă a fost un eveniment**.

### Trei comutatoare, toate de citire

| Comutator | Ce face |
|---|---|
| `-CeVad` | face tot, **nu scrie nimic**, tipărește ce ar face |
| `-VerificaExcluderi` | aplică lista de excluziuni pe **căi reale** și raportează fiecare tipar |
| `-DoarCargol` | aliniază un singur subarbore, nu tot vaultul |

```powershell
.\align-index.ps1 -CeVad               # vedere, nu scrie
.\align-index.ps1 -VerificaExcluderi   # proba pe cai reale
.\align-index.ps1 -DoarCargol 'Clippings'
```

### O regulă care nu se declanșează e o regulă scrisă în decor

Astfel s-a plătit deja, și e cel mai util lucru din tot acest script.

O excluziune pentru arborii de tip `01` a fost scrisă ca `\01` întrebare regex. .NET a
citit șirul ca **secvență octală**: bara înclinată plus `0` plus `1` au devenit
caracterul `U+0001`, care nu se potrivește cu nicio cale reală. Excluderea exista în
documentație, era corectă citită, și **nu oprea nimic** — rezultatul a fost
**330 de indexuri scrise în arbori declarați „nu se atinge"**.

De aceea fiecare tipar din script e scris ca `[\\/]` (ambele bare acceptate), iar proba
nu e lectura codului, ci rularea pe căi reale:

```powershell
.\align-index.ps1 -VerificaExcluderi
```

Un tipar cu **0 căi** e marcat `DEFECT` — nu acceptat ca „merge și el". Când se adaugă
o excluziune nouă, obligatoriu se arată o cale reală pe care o oprește; altfel nu e o
excluziune, e o speranță.

### Rădăcina zonei interzise se indexează, interiorul nu

O zonă interzisă e scoasă **cu tot cu interiorul**, dar **rădăcina ei e un raft
obișnuit** al vaultului și se indexează ca orice raft. Altfel `build-index` și
`align-index` ar da răspunsuri diferite exact în zonele protejate, iar unul dintre ele
ar rescrie indexuri în interiorul caruia n-are voie să scrie.

### Logul: `raport-aliniere.log`

- **În rădăcina vaultului**, lângă `COTOR.md` — nu în `_SYSTEM`. Motivul: e locul unde
  Alex uită să se uite. **Un log ascuns e un log care nu se citește.**
- **Se scrie doar la eveniment.** O rulare curentă, fără nimic de reparat, **nu atinge
  deloc fișierul** — nu îl deschide, nu îl reînnoiește. De aceea data de modificare a
  logului înseamnă „ultima dată când s-a întâmplat ceva".
- Fiecare intrare poartă **numele scriptului și data**.
- **Nu se șterge nimic.** Când Alex rezolvă ceva, blocul rezolvat se mută în
  `arhiva- raport aliniere.log`, lângă el, și rămâne acolo ca istoric.
- **O dată pe săptămână** Alex citește logul și rezolvă. Automatul nu rezolvă nimic în
  numele lui — doar notează ce n-a putut.

> **La data de 2026-10-08 logul există și e gol de tot: 3 octeți** — doar BOM-ul.
> 1.315 evenimente au fost mutate în `arhiva- raport aliniere.log` (733.417 caractere),
> toate rezolvate. **Logul gol e rezultatul dorit**: înseamnă că nu e treabă deschisă.
> Verifică: `Get-Item D:\Alex_Knowlege_Vault\raport-aliniere.log | Select-Object Length`

### Cele trei automate, cu riscuri diferite

| Automat | Când | Ce face | Risc | Stare la 2026-10-08 |
|---|---|---|---|---|
| `PKMS-Watch` | zilnic, **03:30** | doar citire: `lint`, `health-check`, `reconcile` | nu scrie nimic | ✅ există |
| `PKMS-Aliniere` | **la autentificare** + **de 3 ori pe zi** | aliniază indexurile, scrie doar ce diferă | **scrie în vault** | ✅ **există, măsurat** |
| `PKMS-GitAutoCommit` | **la 5 minute** | comită singur ce a rămas necomitat în repo git | **scrie în istoric**, și poate **refuza** | ✅ **există, măsurat** |

Neamestecate pentru că riscurile nu sunt aceleași: automatul care doar citește poate
rula oricând, iar automatul care scrie trebuie creat conștient, cu ora lui.

`PKMS-Aliniere` **există** — măsurat: **4 declanșatori** (autentificare + 06:00,
13:00, 20:00), rulat ca `apviz`, `Limited`, `Interactive`, directorul de lucru
`AI-Kit`, limita de 1 oră, `IgnoreNew`, fereastră ascunsă. Declanșat o singură dată
cu mâna: **22,4 secunde, rezultat 0** — și a prins un drift real, deci nu e decor.
„La computer pornit" s-a implementat ca **la autentificare**, cu 3 minute întârziere,
ca Alex și nu ca SYSTEM (altfel ar avea alte drepturi și altă vedere asupra vaultului).

Cum se oprește:

```powershell
Unregister-ScheduledTask -TaskName 'PKMS-Aliniere' -Confirm:$false
```

Indexurile deja scrise rămân; se văd în `_SYSTEM\arhiva-indexe\`, iar logul rămâne la
rădăcină ca istoric.

### `PKMS-GitAutoCommit` — plasa de siguranță pentru panoul `Changes`

Alex nu e programator și nu va folosi niciodată panoul `Changes`; pentru el e blocaj,
nu ajutor. Iar `Changes` plin apare exact când o sesiune se oprește la jumătate.
Plasa răspunde la asta **fără să atingă interfața**: comită singur.

```powershell
.\git-autocommit.ps1              # comită ce a rămas necomitat
.\git-autocommit.ps1 -CeVerificare # arată ce ar comita, fără să comite
.\git-autocommit.ps1 -AutoProbe   # proba porților — trebuie să poată deveni ROȘIE
```

| Fișier | Ce e |
|---|---|
| `AI-Kit\git-autocommit-registru.txt` | repo-ul de supravegheat, o cale pe rând |
| `AI-Kit\git-autocommit-ignorat.txt` | căi care nu se comită niciodată (wildcard) |
| `AI-Kit\raport-autocomit.log` | urma fiecărui eveniment — scris **doar la eveniment**. **NU intră în git** (măsurat 2026-10-11) |

**Cele patru porți, în ordine:** secrete pe **nume** → secrete pe **conținut** → căi
**interzise** → **timp de așezare** (implicit 60 s, ca să nu prindă o scriere la jumătate).

Coduri de ieșire: `0` curat / așteaptă / salvat · `1` refuzat · `2` mediu · `3` autoproba a picat.

### De ce poarta de secrete a fost reconstruită, nu doar întărită

Măsurat pe 2026-10-10: prima versiune căuta secrete **doar în nume**. Am probat cu un
fișier `_config-uit.txt` al cărui conținut nu conținea niciun cuvânt-cheie — **a trecut
pe lângă poartă și a fost comitat**. Repară: o a doua poartă care citește **conținutul**
(chei PEM, `AKIA…`, `ghp_…`, `sk-…`, `password = "…"`), cu trei reguli de prudență —
binarele nu se citesc, nimic peste 512 KB nu se citește, iar **ce s-a sărit se numără
și apare în mesajul de comit**, ca să nu pară că totul a fost verificat.

### Trei limite declarate, nu ascunse

1. **Poarta nu se scanează pe ea însăși.** Un detector conține tiparele pe care le caută.
   Excepția e **numită** (`exceptie-definire` în mesajul de comit), nu trecută sub tăcere.
2. **O poartă recunoaște o CHEIE, nu o INTENȚIE.** Un fișier cu nume și conținut inocue
   care spune „nu comita asta" e opac pentru orice automat. Forma corectă e declarația
   explicită din `git-autocommit-ignorat.txt`.
3. **Refuzul lasă `Changes` plin.** E un refuz **tăcut pentru om și tare pentru log**.
   Preferat e un panoul plin și un motiv scris, peste un comit nedorit.

Probă reală, măsurată: prima declanșare a taskului **7,8 secunde, rezultat 0**, comit
`c7796c4`, cu `exceptie-definire 2` în mesaj. Iar porțile 2 și 3 au fost probate **separat**,
cu `-CeVerificare`, ca nimic să nu ajungă în istoric: `notite-personale.txt` (nume inocent,
conținut `ghp_…`) → **REFUZAT**, cod 1; `_proba-poarta3.txt` (tot inocent) → **REFUZAT**,
cod 1. `HEAD` neatins după ambele.

Ce nu atinge: interfața, hook-urile git globale (LiveReview), backupul. **Nu face push** —
pushul rămâne decizia lui Alex. Cum se oprește:

```powershell
Unregister-ScheduledTask -TaskName 'PKMS-GitAutoCommit' -Confirm:$false
```


### Întreținerea automată a obiectelor git e OPRITĂ pe acest repo — și de ce

Măsurat 2026-10-19. **Nu activa `gc.auto` înapoi fără să citești asta.**

```powershell
git -C '<volumul>' config gc.auto 0
git -C '<volumul>' config maintenance.auto 0
```

Măsurătoarea care a dus la decizie: **fiecare** comit care a picat în acea zi s-a oprit
la aceeași linie, `task 'geometric-repack' failed`, urmată de
`couldn't read .git/packed-refs: Invalid argument` și
`unable to resolve HEAD after creating commit`. Nu era o coincidență și nici o
problemă de logică — git declanșa repack-ul automat la comit, pe un volum
DriveFS, și repack-ul cădea la mijloc.

Costul măsurat al opririi: obiectele se acumulează. La oprire, `.git` avea
**11.462 fișiere, 21,1 MB** — neglijabil pentru ritmul acestui repo. Când
DriveFS e stabil și vrei să compactezi, rulează `git gc` **cu mâna**, nu
lăsa gitul să o facă singur.

Ce **nu** e demonstrat: că repack-ul e cauza degradărilor DriveFS. Ce e
demonstrat: că el e punctul în care se rupe comitul, de 3 ori în aceeași zi,
pe rând. Cauza degradărilor rămâne necunoscută — nu se inventează una.


### De ce logul plasei NU intră în git

Măsurat pe 2026-10-11, pe istoricul real al repo-ului: **55 de comituri consecutive**,
fiecare conținând doar `AI-Kit\raport-autocomit.log`, între 13:11 și 17:46. Cauza nu era
o greșeală de logică, ci o consecință: plasa scrie o intrare în log → intrarea schimbă
fișierul → fișierul schimbat apare ca „modificat" la următoarea rundă → plasa îl comită.

Logul **rămâne pe disc**, unde omul îl citește. Nu se pierde nimic; se doar mută lucrul
care se rescrie singur în afara istoricului, care e locul lucrurilor care nu se schimbă.

Două greșeli de-aici au fost și ele ale mele, închise laolaltă:

1. **Regula `.gitignore` deschidea o cale care nu există** (`/raport-autocomit.log`),
   pentru că logul mutase în `AI-Kit\`. Era o regulă **moartă**. Logul intra oricum în
   git prin deschiderea `!/AI-Kit/**`.
2. **Fixul de urgență a fost greșit, deși oprea bucla.** Logul a fost adăugat în
   `git-autocommit-ignorat.txt` — adică în lista de căi *interzise*. Orice rundă s-ar
   fi oprit cu „REFUZAT", deci **plasa nu ar mai comita nimic, niciodată**. Un refuz care
   blochează tot sistemul nu e o reparare, e o oprire.

Corectul e la nivelul corect: logul este **ignorat de git**, nu interzis de plasa. O
cale interzisă oprește tot; o cale ignorată de git pur și simplu nu mai ajunge în `status`.

Proba, în ambele sensuri: prima rundă a salvat cele 3 fișiere reale, iar **a doua rundă
a răspuns „curat, nimic de facut"** — deși logul tocmai fusese scris. Acolo se închide bucla.

### Regula de blocaj: mutex, nu fișier-pid

Un singur automat poate scrie în vault odată. Dacă o aliniere e deja pornită și se
declanșează alta, aceasta din urmă **iese tăcut, în cod 0, fără log**.

**Mutex, nu fișier-pid** — pentru că un fișier se poate minte (pid reutilizat, scriere
pe jumătate), iar un mutex nu. Sistemul nu se apără cu un fișier care declară cine are
dreptul; se apără cu un mecanism pe care **nu-l poate minți**.

### `00_INDEX.md` nu intră în nicio cifră — §18.7

Indexul e **registrul**, nu conținutul. De aceea nu intră niciodată în numărătoare:
nici în `**N fișiere · X · M subfoldere**`, nici în octeți, nici în „Cele mai mari 20".

Motivul nu e decor: dacă indexul s-ar număra pe sine, cifrele ar depinde de mărimea
textului scris chiar în el, `CONFORM` n-ar mai fi atins niciodată, iar două rulări
consecutive pe același folder ar da rezultate diferite. **Un registru care se numără
singur nu mai e un registru.**

Aceeași regulă e valabilă pentru **ambele** generatoare: două scripturi care măsoară
diferit nu se pot verifica între ele — iar rulate pe rând își rescriu reciproc indexurile
la nesfârșit.

### Ce poate și ce nu poate repara singur

Automatul repară tot ce e **derivat**: numere, liste, linkuri, blocuri lipsă, indexuri
absente, foldere goale marcate.

În log ajung **doar** situațiile unde nu poate decide care dintre două lucruri era
adevărat:

- un link dintr-un index duce într-un folder care nu mai există — nu știe dacă a fost
  mutat sau șters;
- un index e corupt și nu mai are motivul lui;
- același folder apare indexat de două ori pe căi diferite;
- un index e scris de om cu altă structură, iar automatul nu e sigur că-l poate aduce
  la schemă fără să piardă text.

Ultimele trei sunt rare prin construcție — sunt exact cazurile în care intervenția
automată ar distruge informație.

---

## O dată se scrie o singură dată

Defect găsit **de automat**, la 06:00 pe 2026-10-09, și măsurat până la capăt.

La 06:00, `PKMS-Aliniere` a raportat **44 evenimente**. Patru erau adevărate: un
screenshot nou apărut noaptea (916 → 917 fișiere) și raportul automatului însuși, care
își face propriul index neconform. **Patruzeci erau false**, toate cu aceeași formă:

```
[NEALINIAT] <un folder gol>
    masura: 0 fișiere, 0 subfoldere
    indexul spunea: 0 fișiere · 0 B · 0 subfoldere
```

Cifrele de ambele părți sunt **identice**. Singura diferență, comparată rând cu rând
între versiunea veche și cea nouă, a fost:

```
Folder gol pe 2026-10-08: niciun fișier, niciun subfolder.   ← ce scrisese indexul
Folder gol pe 2026-10-09: niciun fișier, niciun subfolder.   ← ce aștepta automatul
```

**Cauza:** ambele generatoare scriau data **zilei curente** în rândul de folder gol.
La miezul nopții, toate cele 40 de foldere goale deveneau „greșite" prin construcție.
Automatul le rescria și nota 40 de evenimente — în fiecare zi, la nesfarsit. Iar
ritualul săptămânal ar fi arătat 40 de probleme false, pentru totdeauna.

### Ce NU era cauza — măsurat, nu presupus

| Ipoteza | Măsurarea | Verdict |
|---|---|---|
| oscilație între generatoare | `build-index` → `align -CeVad` = **0 evenimente**, de două ori | căzută |
| N4 — CRLF la final | ambele fișiere se terminau identic, `0D 0A 0D 0A` | căzută |
| conținut mutat noaptea | cifrele erau identice de ambele părți | căzută |
| **calendarul** | singura diferență era `2026-10-08` vs `2026-10-09` | **asta e** |

Măsurătoarea mea anterioară — „4 rulări = 0 evenimente" — fusese **corectă, dar într-o
zi**. Defectul poate apărea doar la trecerea dintre două zile, deci starea în care
l-am măsurat era tocmai starea în care **nu putea apărea**.

### Reparația

Data e **proveniență**, nu o valoare recalculată. Se scrie o singură dată, când
folderul e marcat primul, și se păstrează. Corectat în **ambele** generatoare: dacă unul
păstrează și celălalt scrie azi, zarul se mută de la unul la altul în loc să se piardă.

### Proba, în ambele sensuri

Pe o copie, în 87 de foldere goale cărora li s-a scris o dată veche:

| Pas | Codul vechi | Codul reparat |
|---|---|---|
| `align -CeVad` | **87 NEALINIAT** | **0 NEALINIAT** |
| `build-index` rescrie tot | datele treceau pe azi | **datele rămân cele vechi** |
| `align -CeVad` din nou | — | **0 NEALINIAT** |

Proba **pică pe codul vechi**. O probă care nu poate cădea nu e o probă.

---

## `inchide-log.ps1` — ritualul săptămânal

```powershell
.\inchide-log.ps1             # cati sunt DESCHISI acum (implicit: nu scrie)
.\inchide-log.ps1 -Arhiveaza  # muta rezultatele rezolvate in arhiva
.\inchide-log.ps1 -AutoTest   # proba proprie, se poate inrosi
```

### De ce „rezolvat" e o măsurătoare, nu o amintire

Un eveniment din log **nu se declară rezolvat pentru că a fost notat într-o zi**.
E rezolvat dacă **folderul lui nu mai apare în ieșirea de azi a porții**:

```powershell
.\align-index.ps1 -CeVad
```

De aceea logul nu ține minte ce ai reparat, ci **re-verifică azi**. Rezistă la orice
pauză: o săptămână, o lună, sau un calculator oprit zile întregi.

### Ce înseamnă codul de ieșire

| Cod | Ce înseamnă |
|---|---|
| `0` | nimic deschis — poți arhiva |
| `1` | există evenimente deschise, **tipărite cu numele folderului** |
| `2` | logul lipsește sau nu poate fi citit |

Apelarea fără comutator **nu scrie nimic**: e un census, nu o curățenie.

### Ce scrie, cu `-Arhiveaza`

- **mută** evenimentele rezolvate din `raport-aliniere.log` în
  `arhiva- raport aliniere.log`, care se **adaugă** la sfârșit — nu se rescrie;
- **rescrie** logul viu, păstrând **doar** evenimentele încă deschise;
- **nu șterge nimic**, niciodată. Arhiva primește tot, logul reține ce e deschis.

Fiecare eveniment arhivat își păstrează rândul
`--- rezolvat: <folder> (raportat <data și oră>)`, deci istoricul rămâne lizibil
după luni.

### Măsurat la 2026-10-08, pe vaultul real

| | |
|---|---|
| log înainte de prima arhivare | **1.313 evenimente** în 661 foldere |
| după prima arhivare | 1.306 rezolvate mutate, **7 rămase deschise** |
| după alinierea celor 7 | **9 evenimente**, toate rezolvate |
| a doua rulare de arhivare | **0 arhivate** — „Idempotent", fișierele neschimbate |
| arhiva acum | **733.417 caractere**, 1.315 evenimente |
| logul acum | **3 octeți** — doar BOM-ul |

**Un log de 3 octeți e starea de repaus, nu o pierdere.** Se verifică într-o secundă:

```powershell
Get-Item D:\Alex_Knowlege_Vault\raport-aliniere.log | Select-Object Length, LastWriteTime
```

### Ritualul, o dată pe săptămână

1. `.\align-index.ps1` — lasă automatul să repare ce poate. El e singurul autor.
2. `.\inchide-log.ps1` — vezi **ce a rămas deschis**, cu numele folderului.
3. Rezolvi tu ce e deschis, prin orice mijloc.
4. `.\align-index.ps1` din nou.
5. `.\inchide-log.ps1 -Arhiveaza` — rezultatul pleacă în arhivă.
6. Pasul 5 se poate repeta oricând: nu strică nimic.

**Pasul 1 e obligatoriu înainte de 2 și 5.** Fără el, logul îți raportează ca „deschis"
ce `align` ar fi reparat singur, și ritualul arată muncă de om care nu exista.

### Proba care se poate înroșii

```powershell
.\inchide-log.ps1 -AutoTest
```

Patru cazuri: un rezolvat + unul deschis, ambele rezolvate, log gol, și arhivarea
unui rezolvat **lăsând deschisul în logul viu**. Cazul A se poate înroșii — o probă
care nu poate pica nu e o probă.

---

## Ce scrie `build-index.ps1` în fiecare index — §16 din contract

Indexul nu e doar un număr: **un număr nu se caută.** Iată ce pune generatorul în
fiecare `00_INDEX.md`, imediat după nota de generare și **înainte** de `## Subfoldere`:

1. `## Ce e aici` — una sau două propoziții.
2. `## Cuvinte cheie` — între 5 și 12 cuvinte, fiecare între apostrofuri inverse,
   separate prin `·`, pe un singur rând.

**De unde provin, obligatoriu măsurate:** cele două tipuri de fișiere care domină folderul
după număr, numărul rafturilor copil și numele lor, cel mai mare element din folder.
`Cuvinte cheie` se iau numai din numele folderului, primele trei cuvinte cu valoare din
numele celui mai mare fișier, și cele mai frecvente două extensii.

**Interdicții:** niciun adjectiv care nu a fost măsurat — niciodată „important", „urgent",
„cheie", „esențial", „special", „de bază". Nu se deduce o dependență dintr-un nume tehnic:
un folder care conține `node_modules` nu e, prin asta, dependent de Node. Nu se descrie
conținutul fișierelor — doar nume, tipuri și numere.

**Niciodată nu se suprascrie** rândul `**De ce e aici:**` scris de mână. **La data de
2026-10-08: 23** în `_QUARANTINE` (24 dacă se numără și arborele
`indexuri generate in gresit\`), fiecare cu un motiv real. Doar cele două blocuri
generate se înlocuiesc.

Cifra e vie — se schimbă la fiecare ștergere și la fiecare raft nou. Verifică:
```powershell
Get-ChildItem 'D:\Alex_Knowlege_Vault\_QUARANTINE' -Filter '00_INDEX.md' -File -Recurse -Force |
  Where-Object { $_.FullName -notlike '*indexuri generate in gresit*' } |
  Select-String -Pattern '\*\*De ce e aici:\*\*' -Encoding UTF8 | Measure-Object | Select-Object -Expand Count
```
(Documentele spuneau **67**; azi măsurat, nu se mai reproduce sub nicio formă.)

Blocul adaugă cel mult **8 rânduri** unui index. Un index rămâne un index.

## De ce nu rulează `build-index` la verificare — §17 din contract

„Să fie respectat în permanență" nu înseamnă „când îmi amintesc". `watch.ps1` e punctul de
intrare chemat de ceas; `build-index` e **în afara lui**, pentru că scrie.

Așadar: verificarea zilnică măsoară, **nu repară și nu construiește**.

---