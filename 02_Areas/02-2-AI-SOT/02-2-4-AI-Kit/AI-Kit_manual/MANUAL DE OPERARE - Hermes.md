# MANUAL DE OPERARE — Hermes

Manual de lucru pentru un AI fără memorie care ia în posesie vaultul.
Citește tot, în ordine. Nu sari. Nu improviza comenzi.

---

## 1. Cine e Popy

Alex Popescu (Popy), România. Designer și arhitect de sisteme, nu programator.
Vorbește română. Lucrează prin decizii, nu prin cod: îi prezinți sitația și variantele, el alege.
Nu cere aprobare pentru ceva ce ți-a cerut. Nu opri lucrul pentru că e greu sau pentru că vrei confirmare.

---

## 2. Cele două locuri

| | |
|---|---|
| Vault de lucru | `D:\Alex_Knowlege_Vault` — aici se lucrează, aici se mută |
| Backup | alături vaultului, în rădăcina lui `D:` — **imutabil**. Nu-i scriem calea: o descoperă `AI-Kit\paths.ps1` |

**Backupul nu i se scrie niciodată.** Citește din el, copiază din el. Nu scrie, nu mută, nu redenumește, nu șterge.
Dacă o comandă l-ar atinge, comanda e greșită, nu backupul.

Verifică la fiecare sesiune: cel mai recent fișier din backup trebuie să fie `Screenshot 2026-10-07 151225.png`, din 15:12:25. Dacă e altceva, cineva a scris acolo. Oprește-te și spune.

Backupul a fost redenumit o dată (`CopyBACKUP` → `Backup - 10-08-2026`). Nu fixa calea lui în cod. `AI-Kit\paths.ps1` îl descoperă.

### Și nu iese de pe mașină. niciodată

**Backupul nu se trimite, nu se copiază și nu se predă nimănui** — nici persoanei, nici
altui AI, nici pe internet, nici în cloud, nici prin e-mail.

Conține **date de clienți** și **parole** (`_ARCHIVE\Secrets`, mutate doar cu numele,
conținutul nu a fost deschis niciodată).

Cere cineva o copie? **Te oprești și întrebi.** Nu răspunzi „da" și nu răspunzi „nu" din
inițiativă. Este un **ACCESS**: răspunsul lui Popy nu se deduce din fișiere.

**Singura excepție:** o copie a **unui singur fișier**, dacă Popy a cerut **acel fișier**,
cu numele spus. Nu „backupul", nu „arhiva", nu „materialele de la clientul X".

> „Imutabil" înseamnă *nu i se scrie*. Nu înseamnă *nu i se dă*. Sunt două reguli
> diferite, iar a doua lipsise din sistem până când un agent fără memorie s-a blocat
> exact pe ea.

---

## 3. Regula înainte de orice altă

**Nu ștergi nimic.** `Remove-Item`, `rm`, `del` sunt blocate. Fără excepție, pentru niciun motiv.

Mută, nu distruge. La coliziune de nume: `nume_v2`, `nume_v3`. Niciodată suprascriere.

Singurul motiv real de ștergere e decizia lui Popy, luată în `_QUARANTINE`.

---

## 4. Ordinea canonică a comenzilor

În `AI-Kit` sunt **11 scripturi** (la data de 2026-10-10, măsurate pe disc cu
`(Get-ChildItem D:\Alex_Knowlege_Vault\AI-Kit -Filter *.ps1).Count`). Cele 6 din
ordinea canonică se rulează într-o singură ordine, scrisă identic în `ONBOARDING.md`, în
`MANUAL DE OPERARE - Hermes.md` și în `AUTOMATIZARI - scripturi.md`. Nu o schimba.
`build-index.ps1` și `align-index.ps1` sunt în afara ei — pentru că scriu.

Intră în pachet:

```powershell
cd D:\Alex_Knowlege_Vault\AI-Kit
```

La fiecare sesiune, în această ordine:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\paths.ps1        # 1. verifica drumul catre backup   (nu scrie)
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1        # 2. verifica mediul                (nu scrie)
powershell -NoProfile -ExecutionPolicy Bypass -File .\lint.ps1         # 3. POARTA: regulile               (nu scrie)
powershell -NoProfile -ExecutionPolicy Bypass -File .\health-check.ps1 # 4. masoara vaultul                 (nu scrie)
powershell -NoProfile -ExecutionPolicy Bypass -File .\reconcile.ps1    # 5. cifre despre pierderi          (implicit: nu scrie)
```

Ce înseamnă fiecare, într-o propoziție:

| # | Script | Rolul lui, într-o propoziție |
|---|---|---|
| 1 | `paths.ps1` | nu găsește calea, **o verifică** — de aceea nu o scriem tare nicăieri |
| 2 | `setup.ps1` | verifică mediul, **nu modifică nimic** |
| 3 | `lint.ps1` | **poarta** — dacă nu dă 0, nu începi |
| 4 | `health-check.ps1` | **măsoară** — volumul și numărătoarele pe rafturi |
| 5 | `reconcile.ps1` | **singurul care produce cifre despre pierderi** |

**Trecere obligatorie.** Poarta e **0 erori**. Dacă `lint.ps1` dă 0, treci **chiar dacă
raportează atenționări** — citește-le, dar ele nu blochează. Doar **eroarea** oprește.
Corectia e decizia lui Popy, nu a ta.

### `build-index.ps1` nu e în ordine

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\build-index.ps1
```

Rulează-l **doar dacă ai mutat ceva în masă sau ți s-a cerut index nou.**
Scrie `00_INDEX.md` în sute de foldere. **Nu e parte din preluare**, și nu se rulează
„ca să fie sigur". Ca agent verificator, nu îl rulezi deloc.

### `align-index.ps1` nu e în ordine nici el

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\align-index.ps1
```

**Scrie.** De aceea e în afara lanțului, la fel ca `build-index`. Diferența: nu creează
indexuri din conținut, ci **aliniază** indexurile care există deja cu măsurătoarea reală
a folderului, scriind **doar ce a diferit**.

**Ca agent verificator, nu îl rulezi deloc** — nici cu `-CeVad` doar pentru că „nu
scrie". Îl citesc, îl explici, îl propui lui Popy.

Cele cinci stări, pentru orice citire ulterioară: `LIPSA` · `CORUPT` · `INCOMPLET` ·
`NEALINIAT` · `CONFORM`. Nu există a șasea. Rândul `CONFORM` e cel mai important —
**nu atinge nimic**, și nu se loghează. Rândul `**De ce e aici:**` scris de om nu se
suprascrie niciodată.

Trei comutatoare, toate de citire: `-CeVad` (face tot, nu scrie nimic), `-VerificaExcluderi`
(probează lista de excluziuni pe căi reale), `-DoarCargol` (un singur subarbore).

**O regulă care nu se declanșează e o regulă scrisă în decor** — și asta s-a plătit: o
excluziune scrisă ca `\01` a fost citită de .NET ca secvență **octală** (bara + `0` + `1`
= `U+0001`), așa că nu oprea nicio cale reală, iar **330 de indexuri s-au scris în arbori
declarați „nu se atinge"**. De aceea fiecare tipar e `[\\/]`, iar proba e
`-VerificaExcluderi` pe căi reale: un tipar cu 0 căi e `DEFECT`, nu „merge și el".

Detaliul complet, cu logul și cu automatele: `AUTOMATIZARI - scripturi.md`.

### `watch.ps1` — verificarea care vine singură

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\watch.ps1
```

Singurul punct de intrare al verificării automate. Rulează în ordine fixă doar
treptele 3, 4 și 5 de mai sus: `lint`, `health-check`, `reconcile` în modul informativ.

- **Scrie un singur raport** în vault: `_SYSTEM\rapoarte\raport-ultima-rulare.txt`.
  Nimic altceva. Backupul nu e atins.
- **Nu rulează `build-index`.** Nu rulează **nicio** restaurare.
- **Ieșire:** `0` = nicio **eroare**, `1` = există **eroare**. **Atențiile se raportează,
  dar nu ridică singure verdictul și nu schimbă codul de ieșire** — altfel automatismul
  ar urla în fiecare zi pe fapte pe care `lint` însuși le etichetează „nu e dovezi".
  Verdictul e o singură linie: `OK` sau `ATENȚIE: <ce anume>`. Raportul are un rând
  separat, **„ERORI vs ATENȚII"**, care spune câte sunt din fiecare și care cer ochiul tău.
- **Programat** zilnic la **03:30**; rulează și pe baterie, și dacă PC-ul era închis.
  Durata măsurată: **1 m 26 s**.
- **De șters:** `Unregister-ScheduledTask -TaskName 'PKMS-Watch' -Confirm:$false`

### `PKMS-Aliniere` — EXISTĂ ți rulează

Verificare la **2026-10-09**: `Get-ScheduledTask -TaskName 'PKMS-Aliniere'` → starea **Ready**, ultima
rulare **20:00:01**, rezultat **0**. Deci automatul exista chiar si atunci cand
textul de mai jos spunea altceva; cifra de aici e cea masurata acum, nu cea veche.

Când va fi creat, e al doilea automat al vaultului, și are un **risc diferit** de
`PKMS-Watch`:

| Automat | Când | Ce face | Risc |
|---|---|---|---|
| `PKMS-Watch` | zilnic, **03:30** | doar citire: `lint`, `health-check`, `reconcile` | nu scrie nimic |
| `PKMS-Aliniere` | la autentificare + de 3 ori pe zi | `align-index.ps1` — scrie doar ce diferă | **scrie în vault** |

„La computer pornit" se implementează ca **la autentificare**, cu 3 minute întârziere,
și rulează **ca Alex, nu ca SYSTEM** — altfel ar avea alte drepturi și altă vedere asupra
vaultului. Cele trei ore sunt **06:00, 13:00 și 20:00**.

Un singur automat poate scrie în vault odată: dacă o aliniere e deja pornită și se
declanșează alta, aceasta **iese tăcut, în cod 0, fără log**. Mecanismul e un
**mutex**, nu un fișier-pid — pentru că un fișier se poate minte, iar un mutex nu.

Iesirea: `raport-aliniere.log`, **la rădăcina vaultului** (nu în `_SYSTEM`). **Se scrie
doar la eveniment** — o rulare curentă nu atinge deloc fișierul, deci data lui de
modificare înseamnă „ultima dată când s-a întâmplat ceva". Rezolvatele se mută în
`arhiva- raport aliniere.log` și rămân ca istoric. Nimic nu se șterge.

- **De oprit:** `Unregister-ScheduledTask -TaskName 'PKMS-Aliniere' -Confirm:$false`

### `reconcile.ps1` nu scrie **în mod implicit**

Doar apelarea goală nu scrie nimic. Există **trei comutatoare care scriu în vault**:

| Comutator | Ce scrie |
|---|---|
| `-Restore` | umple o gaură de fișiere dispărute — copiază înapoi din backup, pe același drum |
| `-RestoreModified` | suprascrie conținutul; versiunea curentă e pusă la loc **înainte**, în `_QUARANTINE\restaurari\<data și oră>\` |
| `-WriteManifest` | scrie `REVERT3.csv` — mutările care nu aveau dovadă |

**Ca agent verificator, nu rula niciunul dintre ele.** Un comutator fără nume nu e
o comandă, e o decizie.

### Dacă întrebarea e „ce am pierdut din backup?"

Citește cei indicatorii în ordine, și oprește-te la primul care spune „0":

1. **`backup folosit:`** — fără el, comparația nu s-a făcut. Spune asta.
2. **O cifră `0` într-o categorie nu e vestea bună.** Backup gol înseamnă „nu am citit
   nimic", iar „nu s-a pierdut nimic" e atunci minciună. Oprește-te.
3. **Socoteala trebuie să se adune exact cu totalul backupului** (`socoteala inchisa: X din Y`).
   Dacă nu se adună, spune: *nu pot afirma că nu s-a pierdut nimic — nu am comparat tot* — și oprește-te.
4. **Manifest negăsit** → cifrele **nu sunt concludente**. Absența dovezilor nu e dovadă de repaus.
5. **„mutat, fără manifest"** e o datorie de plat, nu o victorie: fișierul există, dar mutarea
   nu e dovedită. Remediere: `-WriteManifest`, apoi rulează din nou, până ajunge la `0`.
6. **„modificat" nu e pierdere** — conținutul s-a schimbat intenționat sau s-a stricat.

**Singura cifră care înseamnă pierdere e `REAL LIPSA (niciunde in vault)`.** Orice
potrivire cu nume **mai mic** decât în backup e o **diferență de dimensiune**, nu o lipsă.

### Cifrele vii

Nu copia cifrele dintr-un document — măsură. Rulează `health-check.ps1` și citește
`TOTAL:`. Măsurate pe 8 octombrie 2026: **50.970** de fișiere de lucru în vault (fără
`.obsidian` și `.git`), **59,01 GB**; pe disc, cu tot cu folderele programelor, **52.239**.
`reconcile.ps1` numără la fel ca `health-check.ps1`, deci comparația cu backupul se
face pe prima cifră. Nu amesteca cele două.

Înainte să spui „gata", rulează din nou `lint.ps1` și `reconcile.ps1`, și pune-ți întrebarea: **ar vedea un utilizator că funcționează asta?** Dacă răspunsul e nu, nu ai terminat.

Planul stă scris unde se citește înapoi — widgetul de progres, bifat pas cu pas, sau `AI-Kit\PLAN.md`. Un plan din conversație se pierde la turele următoare.

---

## 5. Cum lucrezi cu subagenți

**Scrie lista de verificare pe disc înainte de a trimite primul agent.** Fără listă, agenții nu pot fi manageriați și munca se pierde.

**Un singur domeniu per agent.** Nu se suprapun peste altcineva.

| Agent | Domeniu | Are voie | Are PROIBIT |
|---|---|---|---|
| V1 — Structură | arbore de foldere, numerotare, reguli de denumire | citire, numărări | orice scriere, orice mutare |
| V2 — Scripturi | cele 11 scripturi din `AI-Kit` | citire, rulare read-only | `build-index.ps1`, `align-index.ps1`, `reconcile.ps1 -Restore` / `-RestoreModified` / `-WriteManifest` |
| V3 — Documentație | legături între documente, indexuri, carantină | citire, căutare de fișiere | orice scriere |

Niciun agent nu atinge `E:\`, nu atinge backupul, nu atinge `.git`.

**Scrierea e interzisă pentru un verificator.** Verificatorul măsoară și raportează. Repară cel care deține singur domeniul.

**Spune unde aștept și unde acționezi**, înainte de trimitere: unde aștept rapoartele, ce nu rescriu până se întorc, și singurul lucru pe care îl deții în exclusivitate. Dacă nu poți spune asta, lista nu e gata.

**Un agent care raportează „totul e corect" fără cifre nu a verificat.** Cere comanda rulată și numărul întors exact. Un agent care nu găsește nimic nu înseamnă că e bine — înseamnă că n-a putut căuta.

---

## 6. Accidente deja întâmplate, ca să nu se repete

### Dacă scrii un fișier de comandă cu codare greșită, scriptul moare

Un fișier de script salvat fără marcajul de recunoaștere e citit ca text vechi, nu ca text modern.
Orice literă cu diacritică din el devine coruptă, iar scriptul se oprește cu o eroare fără înțeles.
A costat trei rulări pierdute. **Salvează orice fișier de comandă cu marcajul de recunoaștere. Obligatoriu.**

### Dacă exclui fișiere după extensie fără baremă, înghiți și foldere

`*.docx` a înghițit 105 de fișiere dintr-un folder care se numea `BRIEF Evenimente sediu.docx`.
**Pune `!*.ext/` după fiecare `*.ext`.** Extensia cu slash o exclude; extensia goală le ia și pe ele.

### Dacă numără fișiere într-un mod care numără întotdeauna unu

Forma cu paranteze în jurul conductei dă mereu 1, chiar când folderul are mii de fișiere.
Scrie `( ... | Measure-Object).Count`, fără paranteze în plus.

### Dacă forțezi o ștergere, garda mediului te oprește

Ștergerea directă e blocată din exterior. Folosește ștergerea reversibilă sau lasă fișierul temporar acolo.
Nu ocoli garda. Dacă chiar trebuie eliminat ceva, ajunge în carantină.

### Dacă lași o numărare mare să expire, pierzi rezultatul

Numărarea pe 59 GB e lentă. Pornește comanda și așteaptă rezultatul.
**Un rezultat lipsă luat drept „0" e o eroare, nu o măsurătoare.**

### Dacă carantenezi un folder fiindcă pare duplicat, pierzi jumătate din el

`Video Screen Shots` părea integral duplicat. Verificarea fișier cu fișier a arătat că **6 din 12** capturi nu existau în niciun alt loc.
O scanare de duplicate afișează doar perechile care se potrivesc. **Verifică individual, înainte de orice carantinare.**

### Dacă numești fișiere după dimensiune, anulezi perechile de aceeași mărime

O auditare a declarat +23 de fișiere noi. Diferența reală era +30.
**Numără exact pe nume. Dimensiunea e o aproximație, nu o cheie.**

### Dacă lansezi un generator înainte de a-i declara excepțiile, scrie peste tot

`build-index.ps1` a scris mii de `00_INDEX.md` în bibliotecile de programe din `_SYSTEM\Skills`
(la momentul incidentului: **3.671**. Măsurat pe 8 octombrie 2026, în
`_QUARANTINE\indexuri generate in gresit\` sunt **3.988**).
**Excepțiile se declară înaintea primei rulări, nu după.** Dacă s-a întâmplat, mută ce a scris greșit în `_QUARANTINE\indexuri generate in gresit\`, adaugă excepțiile, relansează curat.

### Dacă un linter semnalează ceva, presupune că lumea e greșită

Au existat două semnalări false: o comparație de dată la limita de egalitate, și un test de prefix potrivit vaultul împotriva backup-ului.
**Nu corecta fișierele. Verifică ambele părți și corectează dovedind.**

### Dacă regula se lovește singură prin documentarea ei, regula e greșită

Linterul a semnalat cuvântul interzis în cele două documente care definesc regula.
Verificarea trebuia să se uite la **nume**, nu la conținut.

### Dacă cineva propune o restructurare, propune — nu execută

O propunere de schimbare totală în 7 domenii a fost tratată ca un ghid. Nu a fost aplicată: ar fi distrus baza de lucru a lui Popy.
**Un harness extern propune; Popy decide.** Diferența dintre „a asculta" și „a executa fără aprobare" e diferența dintre consult și vandalism.

### Dacă o limită închisă la mijloc se întoarce în coadă, ai pierdut timp

**Înainte să descrii ce a rămas neterminat, recitește ultima măsurătoare, nu primul tău rezumat.**

### Dacă renumezi ceva din backup, cazi toate scripturile

O singură redenumire a backupului a rupt orice script cu numele scris tare.
**Descoperă drumul, nu-l fixa.**

### Dacă potrivești fișiere după dimensiune, pierderile se ascund

Reconcilierea potrivea după dimensiune. Un fișier șters dispărea într-un altul de aceeași
mărime, iar scriptul raporta **„nu s-a pierdut nimic"**. Corectată după drum, a raportat
**34.380 de pierderi false** — pentru că vaultul fusese reorganizat.

**Corect e în trei straturi:** același drum → mutat, cu manifest → mutat, căutat după
nume + dimensiune. Iar mapările de **director** se aplică ca **prefix**, nu ca cheie exactă.
Întrebă-te mereu: *„ce tip de obiect conține acest manifest?"*

### Dacă un raport nu se adună, nu îl crede

Am afișat `2.141 + 9.712 + 0 = 0 pierderi`. Imposibil — suma nu atingea totalul.
Diferența dispăruse în tăcere, dintr-o înlocuire de text care stricase și bucla nouă.

**Fiecare categorie trebuie să se adune cu totalul.** Dacă nu se adună, oprește-te și
spune „nu am comparat tot". Un zero obținut printr-o buclă care nu s-a executat e decor.

### Dacă un folder redenumit pare pierdut, caută mai întâi după fragmente

`POPY - GORDON - Docker Ai` lipsea din vault. Nu lipsea — devenise `_SYSTEM\GORDON - Docker AI`.
O căutare după nume exact dă „nu îl găsesc" și ton de pierdere.
**„Nu îl găsesc" înseamnă „nu îl găsesc după criteriul meu".**

### Dacă sistemul trece verificările dar nu e complet

Trei verificatori au confirmat că sistemul respectă regulile. Și aveau dreptate.
Apoi un agent pus în locul unui LLM fără memorie, căruia i s-au dat 8 întrebări de lucru
*fără să citească nimic în plus*, a răspuns bine la 6 și **s-a blocat complet** la a șaptea.

Verificarea de conformitate întreabă *„ai făcut ce ai spus?"*. Testul acid întreabă
*„poate altcineva să facă ce trebuie?"*. **Prima nu vede gaura pe care nicio regulă nu o acoperă.**

### Dacă un script există, dar niciun document nu îl numește, e o gaură

Un agent fără memorie a primit un folder cu **7** scripturi, iar documentele îi promiteau
**6**. `watch.ps1` n-avea mențiune: nici nume, nici rol, nici dacă scrie. Agentul a spus
corect: *într-un folder operațional, un script nedocumentat e o gaură, nu un detaliu*.

**Numărul de scripturi se numără pe disc, nu se promite din document.** Dacă `AI-Kit`
conține un script pe care documentele nu îl numesc, **descrie-l înainte să-l folosești**,
în toate documentele de predare.

### Dacă spui „nu scrie" despre un script care are un comutator de scriere, minți pe jumătate

`reconcile.ps1` nu scrie — **în mod implicit**. Există trei comutatoare care scriu:
`-Restore`, `-RestoreModified`, `-WriteManifest`. Un agent căruia i se spune „reconcile
nu scrie" poate trece `-WriteManifest` crezând că e inofensiv.

**Corect e: „nu scrie în mod implicit", urmat de enumerarea fiecărui comutator.**
O afirmație despre ce nu face un script e completă doar când spune și ce face cu opțiunile lui.

### Dacă două documente dau ordini de rulare diferite, niciuna nu e de încredere

`ONBOARDING.md` punea `build-index` la pasul 2, iar acest manual îl condiționa la „după
mutări în masă". Un agent care citea doar onboarding-ul rula un script care scrie sute de
fișiere într-o sesiune de preluare, fără să știe că celălalt document îl oprește.

**O ordine de rulare trăiește într-un singur loc.** Dacă apare în două locuri, cele două
trebuie să fie identice cuvânt cu cuvânt — altfel urmează divergențe, nu ordine.

### Dacă o cifră vie e scrisă tare, e o minciună cu termen

Documentele spuneau „992 de indexuri utile". Măsurat pe **8 octombrie 2026, după
ștergerile făcute azi dimineață**, pe disc sunt **4.649** de `00_INDEX.md`, din care
**3.988** stau în `_QUARANTINE\indexuri generate in gresit\` — deci **661 utile**.
(Imediat înaintea ștergerilor de azi erau 4.681 pe disc și 693 utile.) Nu era o eroare
de metodă: **992** erau indexurile utile la o măsurătoare mai veche, **4.649** sunt tot
ce-i pe disc acum. Ambele adevărate, înseamnă lucruri diferite, și niciun document nu
spunea care.

**Scrie cifra la care se referă** — „de indexuri utile", „de fișiere pe disc, inclusiv
cele din carantină" — **și spune cum se re-verifică.** Nu alege un singur număr și nu-l
lăsa să îmbătrânească: într-un folder viu, orice cifră statică are termen.
```powershell
(Get-ChildItem 'D:\Alex_Knowlege_Vault' -Filter '00_INDEX.md' -File -Recurse -Force).Count
(Get-ChildItem 'D:\Alex_Knowlege_Vault\_QUARANTINE\indexuri generate in gresit' -Filter '00_INDEX.md' -File -Recurse -Force).Count
```

---

## 7. Ce e interzis

**Interzis absolut:**
- `E:\` — nu e discul lui Popy. Nu se citește, nu se scrie, nu se copiază.
- Backupul — scris, mutare, redenumire, ștergere, **predare**. Doar citire.
- Folderele cu punct: `.obsidian`, `.trash`, `.vault-intelligence`, `.claudian`, `.neural_memory`, `.sentinel_temp`, `.wwebjs_cache`. Plus `Canvas Bases` și `.git` din proiecte.
- Cuvântul interzis `LUCURARE` în orice nume de folder, fișier sau drum de script. În conținut e permis. Stratul de lucru se numește `01_Projects\01-6-Work_Folder (to sort)`.
- Ștergerea oricărui lucru. Vezi secțiunea 3.

**Interzis prin regulă:**
- Să cauți prin baza `00`–`06` ca să lucrezi. singurul nivel de lucru e `01_Projects\01-6-Work_Folder (to sort)`.
- Să muți ceva între baze. Baza se completează și se citește.
- Să redenumești fișere fără să repari întâi legăturile. Obsidian se leagă de ele prin nume.
- Să dezarhivezi bibliotecile de programe. Copiile repetate sunt artefacte de build, nu mizerie.
- Să ieși din `01_Projects\01-6-Work_Folder (to sort)` cu peste 30 de rafturi. Semnalul e numărul de rafturi, nu volumul.
- Să atingi `_ARCHIVE\Secrets\`. Se mută doar după nume. Conținutul nu s-a deschis niciodată, nu se deschide.
- Să normalizezi fișiere de pe `D:`. E un subdomeniu, nu o regulă a vaultului.

---

## 8. Dacă ceva nu se înțelege

Nu șterge. Nu redenumește. Nu muta în baza `00`–`06`.

**Mută în `_QUARANTINE\`, cu motiv scris.**

1. Creează folderul cu numele motivului, nu numele obiectului.
2. Scrie `00_INDEX.md` în el, spunând de ce e acolo.
3. Notează ce ai mutat și de unde.

Carantina nu e coș de gunoi. Aici decide Popy, nu tu.