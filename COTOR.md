# COTOR

**Scheletul vaultului.** Tot ce urmează pleacă de aici.

Ultima actualizare: **21 octombrie 2026**. 51.157 de fișiere de conținut · 88,72 GiB conținut util · 95,86 GB brut zecimal (100% bit-parity).
Vaultul trăiește fizic ca oglindă locală NVMe pe **`E:\Google\GDrive\GDrive-Second_Brain_PKMS`** — oglinda locală a Google Drive Cloud, sincronizată permanent cu cloud-ul.
Baza de date Git este **decuplată fizic** la **`E:\Google\GitData-PKMS`**, lăsând în rădăcina vaultului doar un pointer scalar de 31 octeți (`.git`).
**Reperul de siguranță este oglinda Google Drive Cloud** (Decizia 1, 21-10-2026): fiecare fișier există în două locuri, iar starea lor se verifică **per fișier**, local↔cloud. Arhiva externă de pe **`H:`** — `H:\CLAUDE_Archive` (**711.821 fișiere · 180,77 GB**, măsurat 21-10-2026) — rămâne **arhivă neatinsă** — nu mai e reperul, e ultimul rând de rezervă, și se citește doar când e nevoie.
**Calea vaultului, a mountului și a reperului nu se scriu tare nicăieri:** le descoperă dinamic `02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_manual\paths.ps1`.

> **MUTAREA DIN 10-11.** Pe `D:` nu mai există nici vaultul, nici backupul. Ce a rămas pe
> `D:` e un folder stub, fără rol. Doi termeni și-au schimbat înțelesul:
> **lucrezi** a fost `01_Projects\01-6-Work_Folder (to sort)` și acum e **`01_Projects`** — același volum, redenumit;
> **backupul** a fost lângă vault pe `D:` și acum e pe **`H:`**.

---

## Vocabular — folosit corect peste tot

| Cuvânt | Ce înseamnă aici | Nu e |
|---|---|---|
| **vault** | `E:\Google\GDrive\GDrive-Second_Brain_PKMS` — singurul loc unde se lucrează | — |
| **backup** | arhiva de pe `H:`, **imutabilă** și **nu e reperul**. Citește, copiază din ea. Nu scrie niciodată | nu e raft, nu e reper |
| **oglindă** | perechea local↔cloud a aceluiași fișier. **Se verifică per fișier** — asta e reperul | nu e copie locală |
| **bază** | nivelul `00`–`09` (10 baze). Rămâne neatins, ca un fond de bibliotecă | nu e locul de lucru |
| **proiect** | `01_Projects` — singurul nivel în care intri ca să lucrezi | nu e o bază |
| **raft** | un folder din `01_Projects`, pe un subiect de muncă | — |
| **cotor** | documentația asta: tot sistemul pe un fir | — |
| **index** | `00_INDEX.md` într-un folder: ce conține, în cuvinte | — |
| **carantină** | `_QUARANTINE` — nimic nu se șterge, totul ajunge aici | nu e coș de gunoi |

---

## Cele două niveluri

```
E:\Google\GDrive\GDrive-Second_Brain_PKMS\
│
├── 00 … 09          BAZA — fondul. Nu se rearanjează. Aici stă ce nu e treabă curentă.
│
├── 01_Projects      LUCRU — aici intri. A fost `01_Projects\01-6-Work_Folder (to sort)` pe D:. 6 rafturi.
│
├── 08_Clippings     TAIE — locul în care programele trimit ce taie. A stat la
│                   rădăcină până la numerotarea din 19 oct; acum stă în seria
│                   bazelor. ⚠ **De verificat:** Obsidian era programat să caute
│                   `Clippings` la rădăcină — mutat, poate scrie în gol. Observația
│                   e în `AGENTS.md` și `START AICI.md`; decizia e a lui Popy.
│
├── COTOR + INDEX CENTRAL + AGENTS + MANUAL DE NAVIGARE
│
├── _SYSTEM          unelte, biblioteci de programe, skill-uri vii, rest de programe
├── _ARCHIVE         lucruri scoase din calea deschisă
├── _QUARANTINE      tot ce e neclar. Nimic nu se șterge.
│
└── .obsidian, .trash, .vault-intelligence, .claudian, ...   NU SE ATINGE
```

**Regula de aur:** întrezi în `01_Projects`. Nu cauți niciodată prin baza `00`–`09`.

### Unde stă motorul

| Ce | Unde | De ce acolo |
|---|---|---|
| `02-2-4-AI-Kit\AI-Kit_manual` | `02_Areas\02-2-AI-SOT\` | scripturile — **motorul** |
| `02-2-4-AI-Kit\AI-Kit_guide` | `02_Areas\02-2-AI-SOT\` | documentația: contractul, procesele, workflow, onboarding |
| skill-urile vii `git-autonom` / `git-install` | `_SYSTEM\Skills_MASTER_Folder\SENTINEL - git-*- Skill\` | copii vii, verificate prin SHA-256 |
| skill-urile PKMS (`administrare` / `indexare`) | `_SYSTEM\Skills_MASTER_Folder\PKMS - *- Skill\` | sursa de adevăr a sistemului; copii și în sistemul central |
| `arhiva vendor` de skill-uri | `_SYSTEM\Skills_MASTER_Folder\_Skills_BackUp_Archive_2026-07-15\` | **închisă**, nu e motor |

> **Rădăcina nu mai conține documentația, ci patru fișiere `.md`:** `COTOR.md`,
> `INDEX CENTRAL.md`, `MANUAL DE NAVIGARE - cotor.md` și `AGENTS.md` (puntea către
> LLM Wiki). Rapoartele de stare sunt documente datate: cele vechi stau în
> `09_raport-archive`, cel nou în `02-2-4-AI-Kit`. Restul e în `AI-Kit_guide`. Uneltele
> trebuie să caute acolo, nu la rădăcină — altfel urlă pe fișiere care există.

---

## Rafturile de lucru

Măsurate pe **19 octombrie 2026**:

| Raft | Fișiere | GB |
|---|---|---|
| `01_Projects\01-6-Work_Folder (to sort)` | 32.181 | 47,78 |
| `01_Projects\01-2-AP-ID.ro - AI Branding Work and Clients` | 764 | 31,58 |
| `01_Projects\01-1-Alex - AI Work - Colaborations` | 97 | 0,07 |
| `01_Projects\01-5-FORGE - AI JOB Automation` | 9 | 0,00 |
| `01_Projects\01-3-Arhiva Elements - To Monetize` | 1 | 0,00 |
| `01_Projects\01-4-Arhiva Foto - To Monetize` | 1 | 0,00 |

Total `01_Projects`: **33.053 de fișiere în cele 6 rafturi · 79,43 GB.** (cu `00_INDEX.md`-ul bazei: 33.054.)

> **O cifră vie e o obligație, o cifră statică e o minciună cu termen.**
> Tabelul de mai sus e o fotografie, nu o sursă. **Pentru cifra de azi rulează
> `02-2-4-AI-Kit\AI-Kit_manual\health-check.ps1`**, care numără pe loc și tipărește `TOTAL:`. Nu edita cifrele
> aici după ureche — rulează o unealtă.

> **`Work_Folder (to sort)` e datoria, și e numele ei.** 32.181 de fișiere într-un singur
> raft nesortat, adică **97,36% din tot volumul de lucru**. Nu e o rață, e o măsurătoare
> care spune că raftul acesta nu a fost încă despărțit. Se numește așa deoarece știe că
> e în așteptare, nu pentru că ar fi o cofăjenie.

---

## Baza — ce a rămas jos

Măsurate pe **19 octombrie 2026**, după numerotarea pe trei niveluri:

| Bază | Fișiere | GB | Ce mai e acolo |
|---|---|---|---|
| `00_Inbox` | 30 | 0,00 | rafturi de primire, numerotate `00-1` … `00-9` |
| `01_Projects` | 33.054 | 79,43 | **proiectele active — aici se lucrează** |
| `02_Areas` | 3.166 | 1,04 | `02-1-ALEX-SOT` 2.459 · `02-2-AI-SOT` 703 · `02-5-SCIENCE-SOT` 3 (AI-Kit, punți, transcripturi) |
| `03_Resources` | 912 | 0,90 | personalitate, inspirații, memorie |
| `04_Archive` | 11 | 0,00 | copiile de site-uri au urcat în `01_Projects` |
| `05_Attachments` | 1.266 | 0,41 | imagini capturate de tine |
| `06_Metadata` | 43 | 0,00 | ținte, șabloane, agenți |
| `07_Canvas Bases` | 9 | 0,00 | canvas-urile din Obsidian |
| `08_Clippings` | 457 | 0,37 | articole tăiate din web |
| `09_raport-archive` | 4 | 0,00 | rapoartele de stare vechi |

> **`01_Projects`, pe rnduri:** `01-6-Work_Folder (to sort)` 32.181 fișiere / 47,78 GB · `01-2-AP-ID.ro` 764 fișiere / 31,58 GB · `01-1-Alex` 97 fișiere / 0,07 GB · `01-5-FORGE` 9 · `01-3-Arhiva Elements` 1 · `01-4-Arhiva Foto` 1.

### Cum se citește un cod

`02-1-ALEX-SOT` înseamnă: **baza** `02` → **copilul cu nr. 1** → `ALEX-SOT`.
La nivelul 3 se adaugă o cifră: `02-2-4-AI-Kit` = baza 02, copil 2, copil 4.
Numerotarea **se oprește la al treilea folder în adâncime** — mai jos, numele rămân
cum le-ai numit. Codurile **pe care le aveai deja nu și-au schimbat poziția**, ca un
folder nou pus primul la alfabet să nu împingă toate referințele existente.

Rădăcinile care încep cu `_` — `_SYSTEM`, `_ARCHIVE`, `_QUARANTINE` — **nu primesc cod**
deliberat: linia de subliniere e deja semnalul „sunt sistem, nu conținut".

---

## Cele trei rafturi ale mașinii

Măsurate pe **19 octombrie 2026**:

| | Ce e | De ce există |
|---|---|---|
| `_SYSTEM` | 6.950 fișiere · 0,11 GB — scripturi, skill-uri, biblioteci de programe | nu-s ale tale, dar stau în vault ca să nu te împiedici |
| `_ARCHIVE` | 13 fișiere · 0,13 GB | parole și lucruri scoase din calea deschisă |
| `_QUARANTINE` | 4.777 fișiere · 3,16 GB — tot ce a fost neclar | tot ce a fost neclar. **Aici decizi tu, nu eu** |

---

## Indexurile — cifrele de azi

Măsurate pe **19 octombrie 2026**:

| Ce | Câte |
|---|---|
| `00_INDEX.md` pe disc, în tot vaultul | **6.491** |
| din care în `_QUARANTINE` | **4.089** |
| **utili, în afara carantinei** | **2.402** |
| pe GitHub, în repo-ul de automatizare | **4.439** |

> Cele trei cifre mari sunt adevărate despre lucruri diferite și **niciuna nu o
> anulează pe cealaltă**. Pe disc sunt 6.491 pentru că `build-index` a scris index și
> în arborele renumerotat. Pe GitHub sunt 4.439 pentru că acolo nu urcă materialul și
> nici raftul retras. Diferența dintre 6.491 și 4.439 nu e o pierdere: e **ce a rămas
> pe Drive anume ca să nu urce** —raftul retras inclusiv, cu numele clientului închis.

> **Nu alege un singur număr: spune cifra la care te referi și spune cum se re-verifică.**
> 6.491, 4.089 și 2.402 sunt toate trei adevărate despre trei lucruri diferite.
> ```powershell
> $v = 'E:\Google\GDrive\GDrive-Second_Brain_PKMS'
> (Get-ChildItem $v -Filter '00_INDEX.md' -File -Recurse -Force).Count
> (Get-ChildItem "$v\_QUARANTINE" -Filter '00_INDEX.md' -File -Recurse -Force).Count
> ```
> Primul minus al doilea = indexurile utile.

---

## Ce scrie `build-index.ps1` în fiecare index — §16

Un index fără descriere e un **număr**, iar un număr nu se caută.
Fiecare `00_INDEX.md` poartă două blocuri, imediat după nota de generare și **înainte**
de `## Subfoldere`:

1. **`## Ce e aici`** — una sau două propoziții.
2. **`## Cuvinte cheie`** — între 5 și 12 cuvinte, fiecare între apostrofuri inverse,
   separate prin `·`, pe un singur rând.

**De unde provin, obligatoriu măsurate:** cele două tipuri de fișiere care domină folderul
după număr, numărul rafturilor copil și numele lor, cel mai mare element din folder.
Dacă numele folderului spune el însăși scopul, acesta se **citează**, nu se interpretează.
`Cuvinte cheie` se iau numai din numele folderului, primele trei cuvinte cu valoare din
numele celui mai mare fișier, și cele mai frecvente două extensii.

**Interdicții:** niciun adjectiv care nu a fost măsurat — niciodată „important", „urgent",
„cheie", „esențial", „special", „de bază". Nu se deduce o dependență dintr-un nume tehnic:
un folder care conține `node_modules` nu e, prin asta, dependent de Node. Nu se descrie
conținutul fișierelor — doar nume, tipuri și numere.

**Niciodată nu se suprascrie** rândul `**De ce e aici:**` scris de mână. Fiecare are un
motiv real, scris de un om sau de un agent care a privit fișierul înainte să-l mute. Cifra
e vie — se re-verifică cu `Select-String -Pattern '\*\*De ce e aici:\*\*'` pe `00_INDEX.md`
din `_QUARANTINE`, fără arborele `indexuri generate in gresit\`.

Astea sunt **singurele două blocuri generate** care se suprascriu. Blocul adaugă cel mult
**8 rânduri** unui index. Un index rămâne un index.

---

## Regula cozii: blocul generat deține adevărul — §16.1

Fiecare index poartă **două** blocuri generate: `## Ce e aici` și `## Cuvinte cheie`.
Tot ce mai e în index — descrieri scrise cu mâna, liste de cuvinte cheie vechi, copii
ale altor blocuri — e **rest**, nu informație.

**Regula, măsurată pe 114 de indexuri (2026-10-19):**

- Cele două blocuri generate dețin adevărul despre folder.
- Orice altă copie a aceleiași informații, **diferită** de blocul generat, e
  **reziduu** — se taie.
- Copiile **identice** rămân: nu contrazic nimic.
- `_QUARANTINE` nu se atinge. E material retras, nu coș de gunoi.

**Măsurare:** 133 de contradicții înainte (114 în arborele viu + 19 în carantină) →
**după: 19, toate în carantină, vii = 0**.

**De ce a trebuut reparat și generatorul.** Reziduul nu se curăță singur: dacă
`build-index.ps1` nu recunoaște formele pe care le scrie, orice regenerare le
readuce în index. `Test-LiniaGenerata` a fost reparat să recunoască toate cele **5**
forme generate (4 descrieri + rândul de cuvinte cheie). Poarta verifică
**bidirecțional**: funcția nouă nu aruncă pe niciuna din 2.311 de rânduri reale, și
recunoaște **181/181** reziduuri reale.

---
## Cum se verifică singur — §17

„Să fie respectat în permanență" nu înseamnă „când îmi amintesc".
Înseamnă un punct de intrare care poate fi chemat de om **sau de ceas**.

### Un singur punct de intrare: `02-2-4-AI-Kit\AI-Kit_manual\watch.ps1`

Rulează, în ordine fixă, doar lucruri care **nu scriu în vault**:

1. `lint` — regulile de denumire, cuvântul interzis, legăturile, copiile de onboarding.
2. `health-check` — numerele vii ale vaultului.
3. `reconcile` — socoteala cu backupul, în modul informativ, fără restaurări.

**Scrie un singur raport:** `_SYSTEM\rapoarte\raport-ultima-rulare.txt`.
Nimic altceva în vault. Backupul primește citiri și atât.

**Ce nu intră în automatism:**
- **`build-index`** nu se rulează la verificare — scrie sute de indexuri.
  Se rulează cu mâna, doar după mutări în masă sau la cerere.
- **Nicio restaurare.** `reconcile -Restore` și `-RestoreModified` rămân comenzi cu nume.
  Un automatism care repară nu distinge; un om distinge.
- **Nicio scriere în backup.**

### Cum rulează

- Zilnic la **03:30**, taskul **`PKMS-Watch`**.
- Rulează și pe baterie, și dacă PC-ul era închis.
- Cod de ieșire: **`0` = totul bine**, **`1` = există o abatere**.
- De șters: `Unregister-ScheduledTask -TaskName 'PKMS-Watch' -Confirm:$false`

### Calea, pe mașina de azi

`paths.ps1` ia calea din `$env:PKMS_VAULT` dacă e setată, **descoperă** mountul DriveFS
(din shortcutul `G:\My Drive.lnk` → `E:\Google\GDrive`) și baza de metadate
(`mirror_sqlite.db`), și abia apoi se uită la backupul local — **ca fallback**.

```powershell
$env:PKMS_VAULT  = 'E:\Google\GDrive\GDrive-Second_Brain_PKMS'
$env:PKMS_BACKUP = 'H:\CLAUDE_Archive'   # doar dacă există
```

**Fără niciun drum scris tare în scripturi.** `Get-PkmsReference` întoarce reperul
curent: `cloud` (oglinda), `backup-local` (fallback) sau `niciunul` — și ultima
variantă e o **eroare**, nu un „OK" mascate.

### Raportul

Un singur fișier, cu data, cu codul de ieșire al fiecărui script și cu un verdict
pe o singură linie: `OK` sau `ATENȚIE: <ce anume>`.

Un raport care spune „merge bine" fără un număr lângă el nu e raport, e dispoziție.

---

## Alinierea automată a indexurilor — §19

`02-2-4-AI-Kit\AI-Kit_manual\align-index.ps1` repară indexurile care **există deja**. Nu le creează din
conținut ca `build-index`; le aduce la contract, măsurând folderul și rescriind
**doar blocurile derivate**.

**Cele cinci stări** — fiecare folder eligibil ajunge în exact una, nu există a șasea:

| Stare | Cum se recunoaște | Ce face | Se loghează? |
|---|---|---|---|
| `LIPSA` | folderul există, indexul nu | creează indexul pe schemă | **nu** — s-a rezolvat |
| `CORUPT` | gol, trunchiat sau fără titlu | îl reface de la zero și spune ce a pierdut | **da** |
| `INCOMPLET` | are titlu și motiv, îi lipsește un bloc | îl completează, păstrând ce are | **da** |
| `NEALINIAT` | are toate blocurile, măsurătoarea nu mai corespunde | rescrie **doar** blocurile derivate | **da** |
| `CONFORM` | totul corespunde | **nu atinge nimic** | **nu** |

Rândul `CONFORM` e cel mai important: un automat care atinge și un index corect nu mai
lasă urmă de citit și nu se mai poate vedea când strică ceva. Rândul
`**De ce e aici:**` scris de om nu se suprascrie niciodată.

**Trei comutatoare, toate citire:**

| Comutator | Ce face |
|---|---|
| `-CeVad` | face tot, **nu scrie nimic**, tipărește ce ar face |
| `-VerificaExcluderi` | aplică lista de excluziuni pe **căi reale** și raportează fiecare tipar |
| `-DoarCargol` | aliniază un singur subarbore, nu tot vaultul |

**O regulă care nu se declanșează e o regulă scrisă în decor.** Asta s-a plătit deja:
o excluziune scrisă ca `\01` era citită de .NET ca secvență **octală** — bara împreună
cu `0` și `1` deveneau caracterul `U+0001`, care nu se potrivește cu nicio cale reală.
Rezultatul: **330 de indexuri s-au scris în arbori declarați „nu se atinge"**. De aceea
fiecare tipar e scris ca `[\\/]` cu ambele bare acceptate, iar proba e
`.\align-index.ps1 -VerificaExcluderi` pe căi reale. La adaugarea unei excluziuni
noi, obligatoriu se arată o cale pe care o oprește — altfel nu e o excluziune, e o
speranță.

**Rădăcina unei zone interzise se indexează; interiorul nu.** Altfel `build-index` și
`align-index` ar da rămpunsuri diferite exact în zonele protejate, și unul dintre ele
ar rescrie indexuri acolo unde n-are voie.

### Logul: `raport-aliniere.log`

- **În rădăcina vaultului**, lângă `COTOR.md` — nu în `_SYSTEM`. E locul unde Alex
  uită să se uite; un log ascuns e un log care nu se citește.
- **Se scrie doar la eveniment.** O rulare fără nimic de reparat **nu atinge deloc
  fișierul**. Data de modificare a logului înseamnă „ultima dată când s-a întâmplat
  ceva" — de aceea e o cifră vie, nu un jurnal de ștamare.
- Fiecare intrare poartă **numele scriptului și data**.
- **Nu se șterge nimic.** Când Alex rezolvă ceva, blocul rezolvat se mută în
  `arhiva- raport aliniere.log`, lângă el, și rămâne ca istoric.
- **O dată pe săptămână** Alex citește logul și rezolvă. Automatul nu rezolvă nimic
  în numele lui — doar notează ce n-a putut.

### Cele două automate, cu riscuri diferite

| Automat | Când | Ce face | Risc |
|---|---|---|---|
| `PKMS-Watch` | zilnic, **03:30** | doar citire: `lint`, `health-check`, `reconcile` | nu scrie nimic |
| `PKMS-Aliniere` | la autentificare + de 3 ori pe zi | aliniază indexurile, scrie doar ce diferă | **scrie în vault** |

**Neamestecate, pentru că riscurile nu sunt aceleași.** Automatul care doar citește
poate fi lăsat să ruleze oricând; automatul care scrie trebuie creat conștient, cu
ora lui, ca alegere — nu ca efect secundar.

**Cursa de montare, măsurată și reparată (20.10.2026).** `PKMS-Aliniere` a pornit la
**23:04:40** pe triggerul de **logon** și a murit cu `2147942667` (ERROR_DIRECTORY): `G:`
(DriveFS) nu era încă montat, iar taskul pornea cu `WorkingDirectory` pe `G:` — deci
calea de lucru nu exista înainte de a rula orice. **Configurația taskului era corectă:**
rularea manuală a *exact* acelei comenzi a ieșit `EXIT=0` în 629 s, cu 0 NEALINIAT.
Reparare: `PKMS-Aliniere`, `PKMS-Watch` și `PKMS-GitAutoCommit` pornesc acum prin
`rula-din-task.ps1`, aflat pe `C:` (`C:\Users\apviz\.minimax\pkms\`), care **așteaptă
calea** (max 300 s), apoi rulează scriptul și îi propagă codul de ieșire. Jurnalul lui
(`raport-wrapper-task.log`) e **jurnal viu**, deci **nu intră** în nicio numărătoare (§18.7).

### Cârligul de auto-repair pentru DriveFS — `PKMS-DriveFS-AutoRepair`

Al treilea automat, dar **în afara vaultului**: rulează din
`C:\Users\apviz\.minimax\drivefs\auto-repair-drivefs.ps1`, la fiecare **5 minute**.

| | `PKMS-Watch` | `PKMS-Aliniere` | `PKMS-DriveFS-AutoRepair` |
|---|---|---|---|
| Unde rulează | în vault | în vault | **în afara vaultului** |
| Scrie în vault | nu | da | nu |
| Ce face | citește | aliniază indexurile | verifică santinelele DriveFS, repornește procesul doar dacă e rupt |

**De ce stă în afara vaultului:** trebuie să funcționeze chiar și atunci când
vaultul e ilizibil. Un cârlig aflat în vault ar lipsi exact atunci când ar trebui
să tragă.

**Sentinele:** 4 citiri de control. Dacă toate sunt curate, verdictul e `SANATOS`
și nu se face nimic. Repornirea are loc doar la verdict de rupt, iar numărul de
reporniri se scrie în `state.json` — nu se deduce din nimic.

**Măsurat (2026-10-19):** `LastTaskResult = 0`, rulări reale dovedite, verdict
`sanatos`, `totalReporniri: 0`. Task: `apviz`, `Interactive`, `Limited`, interval
`PT5M`, `StartWhenAvailable`.

**Rezolvarea Cauzei Rădăcină (21.10.2026, Antigravity Sentinel):**
Cauza celor 9.422 apariții de `0x91 ERROR_DIR_NOT_EMPTY` și a degradărilor DriveFS a fost identificată și eliminată definitiv:
Git crea și ștergea structuri temporare în `.git\objects\??\` direct în interiorul folderului sincronizat de Google Drive.
DriveFS aplica lock-uri de citire pe fișiere pentru sync cloud, iar la curățarea Git Windows arunca `Win32Exception(145)` (`0x91 ERROR_DIR_NOT_EMPTY`), cauzând blocaje în lanț pe `index.lock` și `LocalStore`.
Prin **decuplarea bazei de date Git** în afara spațiului Google Drive la `E:\Google\GitData-PKMS` (folosind pointer scalar `gitdir: E:/Google/GitData-PKMS` în rădăcină), motorul Google Drive nu mai scanează baza Git, coliziunile de lock au devenit fizic imposibile, iar aparițiile de `0x91` și `index.lock` au coborât la **0**.

**Limita istorică, explicată:** cârligul trata inițial simptomul. Acum cauza de fond a fost decuplată complet din rădăcină.

### Regula de blocaj: mutex, nu fișier-pid

Un singur automat poate scrie în vault odată. Dacă o aliniere e deja pornită și se
declanșează alta, aceasta din urmă **iese tăcut, în cod 0, fără log**. Sistemul nu se
apără cu un fișier care declară cine are dreptul — se apără cu un mecanism pe care
**nu-l poate minți**. Un fișier-pid se poate minte (pid reutilizat, scriere pe jumătate);
un mutex nu.

### `00_INDEX.md` nu intră în nicio cifră — §18.7

`00_INDEX.md` e **registrul**, nu conținutul. Dacă indexul s-ar număra pe sine, cifrele
ar depinde de mărimea textului scris chiar în el, `CONFORM` n-ar mai fi atins niciodată,
iar două rulări consecutive pe același folder ar da rezultate diferite. **Un registru
care se numără singur nu mai e un registru.** Aceeași regulă e valabilă pentru ambele
generatoare: două scripturi care măsoară diferit nu se pot verifica între ele, iar
rulate pe rând își rescriu reciproc indexurile la nesfârșit.

---

## Cele 12 scripturi din `AI-Kit`

Măsurate pe disc, nu promise: `(Get-ChildItem '02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_manual' -Filter *.ps1).Count`
→ **12**.

| Script | Rolul |
|---|---|
| `paths.ps1` | nu găsește calea, **o verifică** |
| `setup.ps1` | verifică mediul, nu modifică nimic |
| `lint.ps1` | **poarta** — dacă nu dă 0, nu începi |
| `health-check.ps1` | **măsoară** |
| `reconcile.ps1` | **singurul care produce cifre despre pierderi** — cu `-Referinta auto` compară cu **oglinda cloud** (per fisier), iar cu `-Referinta backup` păstrează comparația cu backupul local |
| `verifica-oglinda.ps1` | **poarta reperului**: starea oglinzii local↔cloud + sănătatea DriveFS (proces, cozi). EROARE doar pe divergență reală (peste 48h); latența e ATENȚIE |
| `drivefs-oglinda.js` | cititorul READ-ONLY al bazei de metadate DriveFS (`mirror_sqlite.db`). Nu scrie nimic; raportează verdict ca JSON |
| `build-index.ps1` | scrie indexurile — **doar după mutări în masă** |
| `watch.ps1` | verificarea automată: `lint` → `health-check` → `reconcile` |
| `align-index.ps1` | **aliniază** indexurile existente — nu le creează din zero |
| `verifica-schema.ps1` | **verifică** dacă indexurile sunt pe schema §18.1 — nu dacă există (asta e treaba lui `lint`) |
| `inchide-log.ps1` | spune ce e **DESCHIS acum** în log; cu `-Arhiveaza` mută rezolvatele în arhivă |
| `git-autocommit.ps1` | **NU atinge vaultul.** Comită singur, în repo git, ce a rămas necomitat — ca panoul `Changes` să nu aibă ce arăta. Patru porți: secrete pe nume, secrete pe conținut, căi interzise, timp de așezare. Nu face push. Task: `PKMS-GitAutoCommit`, la 5 minute |
| `rula-din-task.ps1` | **lansatorul taskurilor**, nu o treaptă: stă pe `C:` (`C:\Users\apviz\.minimax\pkms\`), **așteaptă** ca vaultul să fie accesibil (max 300 s), apoi rulează un script din `AI-Kit_manual` și îi propagă codul de ieșire. Rezolvă reperul **dinamic**, din shortcutul DriveFS — nu din `G:`, care nu există ca director | **da** — rulează scriptul însuși, cu `PKMS_VAULT` setat și `PKMS_BACKUP` setat **numai dacă backupul există** |

**Ordinea canonică rămâne cea de 5 trepte** (`paths` → `setup` → `lint` →
`health-check` → `reconcile`) și **nu se schimbă**.

**`build-index` și `align-index` nu intră în lanț.** Nu pentru că sunt mai puțin
importante — pentru că amândoi **scriu**. `build-index` creează indexuri din conținut;
`align-index` repară indexuri care există deja. Un lanț de preluare care ar scrie în
sute de foldere fără să fie cerut ar face vaultul să arate altfel fără motiv. Rulă-le
**la cerere** sau prin automatul dedicat (`PKMS-Aliniere`), niciodată „ca să fie sigur".

Ordinea canonică și ce înseamnă fiecare pas: `AI-Kit_guide\AUTOMATIZARI - scripturi.md`
și `AI-Kit_guide\ONBOARDING.md`. **Un script care nu apare acolo e o gaură, nu un detaliu.**

---

## Dosarele cu punct — NU SE ATINGE

`.obsidian` · `.trash` · `.vault-intelligence` · `.claudian` · `.neural_memory` ·
`.sentinel_temp` · `.wwebjs_cache`

Plus `Canvas Bases` — funcția **Bases** din Obsidian, se folosește de pe loc.

---

## Restul documentației

Toate stau acum în **`02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_guide\`**, nu la rădăcină:

| Fișier | Ce e |
|---|---|
| `SPECIFICATII - contractul vaultului.md` | regulile care nu se încalcă, inclusiv §16 și §17 |
| `LOGICA - cum se foloseste fiecare baza.md` | fiecare bază, scopul, mecanismul, data-flow-ul |
| `PROCESE - flux de la captură la utilizare.md` | arborele de proces, pas cu pas |
| `WORKFLOW - ce faci concret.md` | ce faci într-o zi de lucru |
| `AUTOMATIZARI - scripturi.md` | cele 12 scripturi, ordinea canonică, ce scrie fiecare |
| `ONBOARDING AI - cum preia un AI vaultul.md` | cum ia în posesie vaultul un AI fără memorie |
| `START AICI.md` | rafturile de lucru |
| `AUDIT_RECONCILIERE_FINAL.md` | dovada că nu s-a pierdut nimic |

La rădăcină au rămas **patru** fișiere `.md`: `COTOR.md` (acest fișier),
`INDEX CENTRAL.md` (generat de `build-index.ps1`), `MANUAL DE NAVIGARE - cotor.md`
și `AGENTS.md` (puntea către LLM Wiki). Rapoartele de stare sunt documente datate:
cele vechi stau în `09_raport-archive`, cel nou în `02-2-4-AI-Kit`. Mutarea lor a fost
hotărârea lui Popy, cu R0 — nu se mută nimic fără R0.

## LLM Wiki — legătura cu stratul de indexuri

Vaultul e un **LLM Wiki**: surse brute, un strat de indexuri generat automat și un
contract. Puntea dintre ele e `AGENTS.md`, de la rădăcină.

| Strat (LLM Wiki) | În acest vault | Cine îl scrie |
|---|---|---|
| **Schema** | `COTOR.md` — contractul sistemului | omul, prin reguli; automatul doar verifică |
| **Wiki** | `00_INDEX.md` în fiecare folder + `INDEX CENTRAL.md` (totul, pe un ecran) | `build-index.ps1` / `align-index.ps1` |
| **Log** | istoricul git + `raport-aliniere.log` + jurnalele `*-registru.txt` | append-only; nu se rescrie niciodată |
| **Raw** | `00_Inbox` … `08_Clippings` | omul |

**`index.md` și `log.md` nu se creează, cu numele alea.** Fiecare ar fi fost **o a
doua adevăr** despre același lucru: `index.md` ar duplica `INDEX CENTRAL.md` (derivat,
deci neversionat), iar `log.md` ar duplica istoricul git — care ține și *diferențele*,
nu doar evenimentele. `AGENTS.md` există: e rampa, iar contractul lung stă în
`COTOR.md`, ca să nu fie repetat în două locuri.

**Cele trei operații, traduse aici:**

| Operație | Cum arată în acest vault |
|---|---|
| **Ingest** (material nou) | intră în `00_Inbox` → alegi raftul → `align-index.ps1 -DoarCargol '<subarbore>'` reface cotorul acelui raft |
| **Query** | patru citiri, nu scanări: `COTOR.md` → `MANUAL DE NAVIGARE - cotor.md` → `START AICI.md` → `00_INDEX.md` din folderul în care lucrezi |
| **Lint** | `lint.ps1` (poarta: dă 0 sau nu intri) + `align-index.ps1 -CeVad` (cotorul: câte indexuri nu sunt aliniate) |

**Interdicția care rămâne:** nu scanezi niciodată tot arborele cu
`Get-ChildItem -Recurse` ca să găsești un fișier. Cotrul răspunde în sub o secundă.

---

## Trei lucruri care NU se fac

1. **Nu se șterge nimic.** `rm` și `Remove-Item` sunt blocate. Neclarul ajunge în carantină.
2. **Nu se atinge backup-ul.** Se citește. Dacă lipsește ceva, se copiază **din** el.
3. **Nu se schimbă baza `00`–`09`.** Se completează și se citește, nu se rearanjează.
