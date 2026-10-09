# COTOR

**Scheletul voltului.** Tot ce urmează pleacă de aici.

Ultima actualizare: **8 octombrie 2026**. 50.970 de fișiere de lucru · 59,01 GB.
Backupul e alături voltului, pe `D:` — neatins, se citește doar.
**Calea lui nu se scrie tare nicăieri:** o descoperă `AI-Kit\paths.ps1`.

---

## Vocabular — folosit corect peste tot

| Cuvânt | Ce înseamnă aici | Nu e |
|---|---|---|
| **volt** | `D:\Alex_Knowlege_Vault` — singurul loc unde se lucrează | — |
| **backup** | copia de pe `D:\`, **imutabilă**. Citește, copiază din ea. Nu scrie niciodată | nu e raft |
| **bază** | nivelul `00`–`06` (7 baze). Rămâne neatins, ca un fond de bibliotecă | nu e locul de lucru |
| **Work** | `10_Work` — singurul nivel în care intri ca să lucrezi | nu e o bază |
| **raft** | un folder din `10_Work`, pe un subiect de muncă | — |
| **cotor** | documentația asta: tot sistemul pe un fir | — |
| **index** | `00_INDEX.md` într-un folder: ce conține, în cuvinte | — |
| **carantină** | `_QUARANTINE` — nimic nu se șterge, totul ajunge aici | nu e coș de gunoi |

---

## Cele două niveluri

```
D:\Alex_Knowlege_Vault\
│
├── 00 … 07          BAZA — fondul. Nu se modifică. Aici stă ce nu e treabă curentă.
│
├── 10_Work          LUCRU — aici intri. 8 rafturi, pe ce lucrezi.
│
├── Clippings        TAIE — e locul în care programele trimit ce taie, iar Obsidian
│                   e programat să-l caute la rădăcină. De aceea **NU se mută**
│                   în bază: la rădăcină e locul lui, oriunde ar ajunge Obsidian
│                   să scrie.
│
├── COTOR + documentația din rădăcină    (fișierele *.md de aici)
│
├── AI-Kit           pachetul de predare pentru orice AI, fără memorie
│
├── _SYSTEM          unelte, biblioteci de programe, rest de programe
├── _ARCHIVE         parole și lucruri scoase din calea deschisă
├── _QUARANTINE      tot ce e neclar. Nimic nu se șterge.
│
└── .obsidian, .trash, .vault-intelligence, .claudian, ...   NU SE ATINGE
```

**Regula de aur:** întrezi în `10_Work`. Nu cauți niciodată prin baza `00`–`06`.

---

## Rafturile de lucru

Măsurate pe **8 octombrie 2026**, cu `AI-Kit\health-check.ps1`:

| Raft | Ce e | Fișiere |
|---|---|---|
| `10_Work\Clienti` | Knights Tempar (44,57 GB) + ZURLI | 1.214 |
| `10_Work\Site` | tema Salient cumpărată + 27.689 imagini din 2010 | 29.748 |
| `10_Work\Joburi` | mașina de aplicare, 94 de firme | 602 |
| `10_Work\Casa` | Oglinda Casă | 484 |
| `10_Work\Documentatie AI` | articole tăiate din web | 359 |
| `10_Work\Sisteme AI` | AP-ID Systems, Optimus, Hermes, Google AI | 379 |
| `10_Work\Personaj Sentinel` | ființa Sentinel | 147 |
| `10_Work\In Progress` | ce e în mișcare acum | 65 |

Total `10_Work`: **32.998 de fișiere.**

> **O cifră vie e o obligație, o cifră statică e o minciună cu termen.**
> Tabelul de mai sus e o fotografie, nu o sursă. Se schimbă la fiecare mutare și la
> fiecare index generat. **Pentru cifra de azi rulează `AI-Kit\health-check.ps1`**,
> care numără pe loc și tipărește `TOTAL:`. Nu edita cifrele aici după ureche —
> rulează uneltă.

> **De ce două cifre diferite despre același lucru sunt amândouă adevărate.**
> **La data de 2026-10-08, după ștergerile făcute azi dimineață:** `00_INDEX.md` —
> **4.649** pe disc, din care **3.988** în `_QUARANTINE\indexuri generate in gresit\` →
> **661 utile**.
> (Înaintea ștergerilor de azi erau 4.681 pe disc și 693 utile — diferența e exact ce
> s-a șters. **Cifra vie: se schimbă la fiecare ștergere și la fiecare rulare de
> `align-index`.** Nu o copia într-un plan ca număr fix — **măsoară:**
> ```powershell
> (Get-ChildItem 'D:\Alex_Knowlege_Vault' -Filter '00_INDEX.md' -File -Recurse -Force).Count
> (Get-ChildItem 'D:\Alex_Knowlege_Vault\_QUARANTINE\indexuri generate in gresit' -Filter '00_INDEX.md' -File -Recurse -Force).Count
> ```
> Primul minus al doilea = indexurile utile.)
> Nu alege un singur număr: spune **cifra la care te referi** și spune cum se re-verifică.

---

## Baza — ce a rămas jos

Măsurate pe **8 octombrie 2026**:

| Bază | Ce mai e acolo |
|---|---|
| `00_Inbox` | 23 fișiere + rafturi de primire |
| `01_Projects` | 2 fișiere (proiectele active au urcat în `10_Work`) |
| `02_Areas` | 779 fișiere · 6,4 GB — clienți rămași, CV, cercetare despre tine |
| `03_Resources` | 914 fișiere · 921 MB — personalitate, inspirații, memorie |
| `04_Archive` | 1.109 fișiere — copii de site-uri, nimic valoros |
| `05_Attachments` | 1.196 imagini capturate de tine |
| `06_Metadata` | 43 fișiere — ținte, șabloane, agenți |

---

## Cele trei rafturi ale mașinii

| | Ce e | De ce există |
|---|---|---|
| `_SYSTEM` | 9.746 fișiere — biblioteci de programe, prompturi, rest de programe | nu-s ale tale, dar stau în volt ca să nu te împiedici |
| `_ARCHIVE\Secrets` | 7 fișiere | parole, mutate **doar după nume**, conținutul nu s-a deschis niciodată |
| `_QUARANTINE` | 4.165 fișiere | tot ce a fost neclar. **Aici decizi tu, nu eu** |

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
Dacă numele folderului spune el însuși scopul, acesta se **citează**, nu se interpretează.
`Cuvinte cheie` se iau numai din numele folderului, primele trei cuvinte cu valoare din
numele celui mai mare fișier, și cele mai frecvente două extensii.

**Interdicții:** niciun adjectiv care nu a fost măsurat — niciodată „important", „urgent",
„cheie", „esențial", „special", „de bază". Nu se deduce o dependență dintr-un nume tehnic:
un folder care conține `node_modules` nu e, prin asta, dependent de Node. Nu se descrie
conținutul fișierelor — doar nume, tipuri și numere.

**Niciodată nu se suprascrie** rândul `**De ce e aici:**` scris de mână. Există **23** în
`_QUARANTINE` (la data de 2026-10-08), fiecare cu un motiv real, scris de un om sau de
un agent care a privit fișierul înainte să-l mute. Cifra e vie — se re-verifică cu
`Select-String -Pattern '\*\*De ce e aici:\*\*'` pe `00_INDEX.md` din `_QUARANTINE`,
fără arborele `indexuri generate in gresit\`.

Astea sunt **singurele două blocuri generate** care se suprascriu. Blocul adaugă cel mult
**8 rânduri** unui index. Un index rămâne un index.

---

## Cum se verifică singur — §17

„Să fie respectat în permanență" nu înseamnă „când îmi amintesc".
Înseamnă un punct de intrare care poate fi chemat de om **sau de ceas**.

### Un singur punct de intrare: `AI-Kit\watch.ps1`

Rulează, în ordine fixă, doar lucruri care **nu scriu în volt**:

1. `lint` — regulile de denumire, cuvântul interzis, legăturile, copiile de onboarding.
2. `health-check` — numerele vii ale voltului.
3. `reconcile` — socoteala cu backupul, în modul informativ, fără restaurări.

**Scrie un singur raport:** `_SYSTEM\rapoarte\raport-ultima-rulare.txt`.
Nimic altceva în volt. Backupul primește citiri și atât.

**Ce nu intră în automatism:**
- **`build-index`** nu se rulează la verificare — scrie sute de indexuri.
  Se rulează cu mâna, doar după mutări în masă sau la cerere.
- **Nicio restaurare.** `reconcile -Restore` și `-RestoreModified` rămân comenzi cu nume.
  Un automatism care repară nu distinge; un om distinge.
- **Nicio scriere în backup.**

### Cum rulează

- Zilnic la **03:30**, taskul **`PKMS-Watch`**.
- Rulează și pe baterie, și dacă PC-ul era închis.
- Ultima măsurare: **1 m 26 s**.
- Cod de ieșire: **`0` = totul bine**, **`1` = există o abatere**.
- De șters: `Unregister-ScheduledTask -TaskName 'PKMS-Watch' -Confirm:$false`

### Raportul

Un singur fișier, cu data, cu codul de ieșire al fiecărui script și cu un verdict
pe o singură linie: `OK` sau `ATENȚIE: <ce anume>`.

Un raport care spune „merge bine" fără un număr lângă el nu e raport, e dispoziție.

---

## Alinierea automată a indexurilor — §19

`AI-Kit\align-index.ps1` repară indexurile care **există deja**. Nu le creează din
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
| `-DoarCargol` | aliniază un singur subarbore, nu tot voltul |

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

- **În rădăcina voltului**, lângă `COTOR.md` — nu în `_SYSTEM`. E locul unde Alex
  uită să se uite; un log ascuns e un log care nu se citește.
- **Se scrie doar la eveniment.** O rulare fără nimic de reparat **nu atinge deloc
  fișierul**. Data de modificare a logului înseamnă „ultima dată când s-a întâmplat
  ceva" — de aceea e o cifră vie, nu un jurnal de ștamare.
- Fiecare intrare poartă **numele scriptului și data**.
- **Nu se șterge nimic.** Când Alex rezolvă ceva, blocul rezolvat se mută în
  `arhiva- raport aliniere.log`, lângă el, și rămâne ca istoric.
- **O dată pe săptămână** Alex citește logul și rezolvă. Automatul nu rezolvă nimic
  în numele lui — doar notează ce n-a putut.

> **La data de 2026-10-08: logul nu există încă pe disc** — nu a curs nicio aliniere.
> Se creează la primul eveniment. Verifică:
> `Test-Path D:\Alex_Knowlege_Vault\raport-aliniere.log`

### Cele două automate, cu riscuri diferite

| Automat | Când | Ce face | Risc | Stare |
|---|---|---|---|---|
| `PKMS-Watch` | zilnic, **03:30** | doar citire: `lint`, `health-check`, `reconcile` | nu scrie nimic | ✅ există, `Ready` |
| `PKMS-Aliniere` | la autentificare + de 3 ori pe zi | aliniază indexurile, scrie doar ce diferă | **scrie în volt** | 🔴 **de creat** |

**Neamestecate, pentru că riscurile nu sunt aceleași.** Automatul care doar citește
poate fi lăsat să ruleze oricând; automatul care scrie trebuie creat conștient, cu
ora lui, ca alegere — nu ca efect secundar.

> **`PKMS-Aliniere` nu există la data de 2026-10-08.** Măsurat:
> `Get-ScheduledTask -TaskName 'PKMS-Aliniere'` → nu găsește nimic. Când va fi creat,
> „la computer pornit" se implementează ca **la autentificare**, cu 3 minute întârziere,
> și rulează ca Alex, nu ca SYSTEM. Cele trei ore sunt **06:00, 13:00 și 20:00**.
> Cum se oprește:
> `Unregister-ScheduledTask -TaskName 'PKMS-Aliniere' -Confirm:$false`

### Regula de blocaj: mutex, nu fișier-pid

Un singur automat poate scrie în volt odată. Dacă o aliniere e deja pornită și se
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

## Cele 10 scripturi din `AI-Kit`

Măsurate pe disc, nu promise: `(Get-ChildItem D:\Alex_Knowlege_Vault\AI-Kit -Filter *.ps1).Count`

| Script | Rolul |
|---|---|
| `paths.ps1` | nu găsește calea, **o verifică** |
| `setup.ps1` | verifică mediul, nu modifică nimic |
| `lint.ps1` | **poarta** — dacă nu dă 0, nu începi |
| `health-check.ps1` | **măsoară** |
| `reconcile.ps1` | **singurul care produce cifre despre pierderi** |
| `build-index.ps1` | scrie indexurile — **doar după mutări în masă** |
| `watch.ps1` | verificarea automată: `lint` → `health-check` → `reconcile` |
| `align-index.ps1` | **aliniază** indexurile existente — nu le creează din zero |
| `verifica-schema.ps1` | **verifică** dacă indexurile sunt pe schema §18.1 — nu dacă există (asta e treaba lui `lint`) |
| `inchide-log.ps1` | spune ce e **DESCHIS acum** în log; cu `-Arhiveaza` mută rezolvatele în arhivă |

**Ordinea canonică rămâne cea de 5 trepte** de mai sus (`paths` → `setup` → `lint` →
`health-check` → `reconcile`) și **nu se schimbă**.

**`build-index` și `align-index` nu intră în lanț.** Nu pentru că sunt mai puțin
importante — pentru că amândoi **scriu**. `build-index` creează indexuri din conținut;
`align-index` repară indexuri care există deja. Un lanț de preluare care ar scrie în
sute de foldere fără să fie cerut ar face voltul să arate altfel fără motiv. Rulă-le
**la cerere** sau prin automatul dedicat (`PKMS-Aliniere`), niciodată „ca să fie sigur".

Ordinea canonică și ce înseamnă fiecare pas: `AI-Kit\AUTOMATIZARI - scripturi.md` și
`AI-Kit\ONBOARDING.md`. **Un script care nu apare acolo e o gaură, nu un detaliu.**

---

## Dosarele cu punct — NU SE ATINGE

`.obsidian` · `.trash` · `.vault-intelligence` · `.claudian` · `.neural_memory` ·
`.sentinel_temp` · `.wwebjs_cache`

Plus `Canvas Bases` — funcția **Bases** din Obsidian, se folosește de pe loc.

---

## Restul documentației

| Fișier | Ce e |
|---|---|
| `LOGICA - cum se foloseste fiecare baza.md` | fiecare bază, scopul, mecanismul, data-flow-ul |
| `PROCESE - flux de la captură la utilizare.md` | arborele de proces, pas cu pas |
| `WORKFLOW - ce faci concret.md` | ce faci într-o zi de lucru |
| `AUTOMATIZARI - scripturi.md` | cele 10 scripturi, ordinea canonică, ce scrie fiecare |
| `SPECIFICATII - contractul voltului.md` | regulile care nu se încalcă, inclusiv §16 și §17 |
| `ONBOARDING AI - cum preia un AI voltul.md` | cum ia în posesie voltul un AI fără memorie |
| `AI-Kit\ONBOARDING.md` | **copia octet cu octet identică** a onboarding-ului — `lint.ps1` o verifică la fiecare rulare |
| `AI-Kit\MANUAL DE OPERARE - Hermes.md` | manualul de lucru al agentului, cu ordinea canonică și rețeta „ce am pierdut din backup" |
| `INDEX CENTRAL.md` | tot voltul, pe un singur ecran, generat de script |
| `AUDIT_RECONCILIERE_FINAL.md` | dovada că nu s-a pierdut nimic |

---

## Trei lucruri care NU se fac

1. **Nu se șterge nimic.** `rm` și `Remove-Item` sunt blocate. Neclarul ajunge în carantină.
2. **Nu se atinge backup-ul.** Se citește. Dacă lipsește ceva, se copiază **din** el.
3. **Nu se schimbă baza `00`–`06`.** Se completează și se citește, nu se rearanjează.