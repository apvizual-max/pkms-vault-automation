# SPECIFICATII — contractul vaultului

Regulile care **nu se încalcă**. Fără excepții, fără „de data asta".

> **Actualizat 2026-10-19, după mutarea voltului pe Google Drive.** Contractul a fost
> mutat odată cu `AI-Kit` în `02_Areas\02_2-AI-SOT\AI-Kit\AI-Kit_guide\`, iar numele lui
> a trecut de la *voltului* la *vaultului*. Titlul de mai sus a rămas cu grafsia veche:
> un document care nu-și spune propriul nume în propria titulatură nu e corect.
>
> **`01_Projects\01-6-Work_Folder (to sort)` nu mai există.** Măsurat: pe 8 octombrie avea 32.998 de fișiere; azi
> `01_Projects` are **33.069 de fișiere · 79,44 GB**. E aceeași masă, redenumită.
> §3, §4, §5 și §6 au fost actualizate în consecință.

---

## 1. Nimic nu se șterge

`Remove-Item`, `rm`, `del` — blocate. Fără excepție, pentru niciun motiv.

Orice e neclar, duplicat, reziduu sau suspect → **`_QUARANTINE\`**, cu un `00_INDEX.md` care spune **de ce**.

**Singurul motiv real de ștergere:** decizia lui Alex, luată în `_QUARANTINE`.

Coliziuni de nume: `nume_v2`, `nume_v3`. **Niciodată suprascriere.**

---

## 2. Backupul e imutabil

```
D:\Alex_Knowlege_Vault - Backup - 10-08-2026
```

**Citește. Copiază din el. Nu scrie, nu mută, nu redenumește, nu șterge.**

Dacă o comandă ar atinge backupul, **comanda e greșită**, nu backupul.

Backupul a fost redenumit o dată (`CopyBACKUP` → `Backup - 10-08-2026`).
De aceea scripturile **nu mai scriu numele lui niciunde** — îl descoperă singure, cu `AI-Kit\paths.ps1`.

**Dovada că e neatins:** cel mai recent fișier din backup trebuie să fie
`Screenshot 2026-10-07 151225.png`, din 15:12:25. Dacă e altceva, cineva a scris acolo. STOP.

### 2.1 Backupul nu părăsește niciodată mașina, pe cont propriu

Aceasta e o regulă separată, pentru că se întreba des. Nu o deduce din „imutabil".

- **Backupul nu se trimite, nu se copiază și nu se predă nimănui** — nici unei persoane,
  nici unui AI, nici pe internet, nici într-un cloud, nici prin e-mail.
- Cine cere o copie, **primește un refuz și o întrebare**, nu o arhivă.
- Conține **date de clienți** și **parole** (`_ARCHIVE\Secrets`, mutate doar cu numele, conținutul
  nu a fost deschis niciodată). Nu se trage niciun fel de concluzie despre cine primește ce.
- **Singurul care poate hotărâ să dea ceva este Alex**, caz cu caz, și numai fiind
  convins în momentul acela. Nu există o regulă generală care să permită predarea.
- Un AI care e întrebat despre asta **se oprește și întreabă**. Nu răspunde „da" și nu
  răspunde „nu" din inițiativă. Asta e un **ACCESS**: numai Alex poate furniza ceea ce
  cerutul presupune, iar răspunsul lui nu se poate deduce din fișiere.
- Ce **poate** fi făcut fără întrebare: o copie de **un singur fișier**, dacă Alex a cerut
  **acel fișier** cu numele spus. Numai atunci. Nu „backupul", nu „arhiva", nu „materialele
  de la clientul X".

---

## 3. Baza `00`–`06` nu se rearanjează

```
00_Inbox  01_Projects  02_Areas  03_Resources  04_Archive  05_Attachments  06_Metadata
```

Se **completează** și se **citește**. Nu se mută nimic între bază și bază.

Un proiect **urcă** în `01_Projects` când devine activ și **coboară** înapoi când se termină.

---

## 4. `01_Projects` e singurul nivel de lucru

Nu cauți niciodată prin baza ca să lucrezi. `01_Projects` e singurul nivel în care intri.

Măsurat pe **19 octombrie 2026**:

| Raft | Fișiere | pentru |
|---|---|---|
| `Work_Folder (to sort)` | 32.249 | **nesortat, în așteptare** — 97,5% din volumul de lucru |
| `AP-ID.ro - AI Branding Work and Clients` | 734 | branding și clienți |
| `Alex - AI Work - Colaborations` | 78 | colaborări |
| `FORGE - AI JOB Automation` | 7 | automatizare de joburi |
| `Arhiva Elements - To Monetize` | 0 | de monetizat, neînceput |
| `Arhiva Foto - To Monetize` | 0 | de monetizat, neînceput |

**Dacă `01_Projects` are 30 de rafturi, nu mai e strat de lucru, e altă mizerie.**

> **Un raft se numește cum e, nu cum ar trebui să fie.** `Work_Folder (to sort)` nu e o
> greșeală de denumire, e o **măsurătoare**: spune că raftul acesta nu a fost încă
> despărțit. Redenumit frumos înainte de a fi sortat, ar fi ascuns datoria, nu ar fi
> reparat-o.

---

## 5. Numerotare: doar bază și rafturi de lucru

Au numere: bazele `00`–`06`, rafturile din `01_Projects`, sub-rafturile lor.
**Nu au numere:** `_SYSTEM`, `_ARCHIVE`, `_QUARANTINE`, `AI-Kit`, `Canvas Bases`, `COTOR`.

Un folder fără cifră în față spune imediat „asta nu e conținutul tău".

---

## 6. Cuvântul interzis

`LUCURARE` nu apare nicăieri în numele de foldere, de fișiere și de scripturi.
**Folosirea e `01_Projects`.** În română: *de lucru*.

Verificat automat de `AI-Kit\lint.ps1`.

**Ce scanează verificatorul, mai exact:**

- **DOAR numele** — numele de folder, numele de fișiere și drumurile din scripturi.
- **NU scanează conținutul** textual al documentelor.
- De ce: acest document, `COTOR.md` și `ONBOARDING.md` trebuie să poată **numa** cuvântul
  interzis ca să definească regula. Un verificator care ar citi și textul ar self-sancționa
  prin definiție, și ar trebui o excepție care ar slăbi regula.
- Consecință: un document **despre** lucrul tău poate conține cuvântul. Un folder **numit**
  așa nu.

**Excepție reală, măsurată:** 9 nume de fișiere din
`01_Projects\01-6-Work_Folder (to sort)\01-6-1-Casa\02_7-OGLINDA-CASA\HERMES - browser-agent\test_run\Email_Archives\`
(subiecte de e-mail salvate, printre care `locuri de munca`) și un `Incetare contract de munca`
în `02_Areas\`. Sunt **titluri de documente primite de la terți**, nu vocabular de structură
ales de sistem. Nu au fost redenumite: redenumirea ar schimba titlul unui act real.
Dacă Alex cere vreodată redenumirea, se face **cu repararea legăturilor**, nu orbește.

> **Măsurătoare dinaintea mutării pe Drive (2026-10-19).** Calea de mai sus conține
> `01_Projects\01-6-Work_Folder (to sort)`, care nu mai există — măsurarea e istorică, **regula nu e**. Cuvântul rămâne
> interzis în nume oriunde s-ar afla acum. Nu se rescrie istoria unei măsurători ca să
> pară actuală: se marchează data ei.

---

## 7. Folderele cu punct nu se ating

```
.obsidian  .trash  .vault-intelligence  .claudian
.neural_memory  .sentinel_temp  .wwebjs_cache
```

Plus `Canvas Bases` (funcția Bases din Obsidian) și `.git\` din proiecte.

**Excepția care dovedește regula:** `Tags` și `TagsRoutes` *aveau* punct și **nu erau** ale unui program —
conțineau doar baza locală a unui program (`context.mdb`) și un log gol.

**Nume tehnic ≠ dependență reală.** Demonstrează dependența înainte să protejezi sau să muți.

---

## 8. Nimic nu se reatribuie fără repararea legăturilor

161 de fișiere din `Documentatie AI\AI TOOLS` au numele transformat în adresă web.
**Nu au fost reatribuite**, pentru că Obsidian se poate lega de ele prin nume.

Dacă se reatribuie vreodată: **întâi** se repară legăturile, **apoi** se schimbă numele. Nu invers.

---

## 9. Cuvântul interzis al ștergerii: „copie" nu înseamnă „mizerie"

| Ce | Nu e mizerie |
|---|---|
| 5.164 fișiere identice în biblioteci de programe | copii de rezervă la trei date |
| 1.110 imagini identice în media site-ului | aceeași imagine uploadată de două ori |
| 161 copii de site-uri | materie brută, păstrată în `04_Archive` |

---

## 10. Înainte de carantină: verificare fișier cu fișier

O funcție poate **înșela prin jumătate**: scanarea de duplicate listează doar perechile care se potrivesc.
Un folder poate părea duplicat integral, conținând jumătate din conținut unic.

Verificarea care a lipsit o dată: `Video Screen Shots` — **6 din 12 capturi existau doar acolo.**

---

## 11. Măsurătoarea e condiție, nu rezultat

Măsoară **înainte** și **după**. Dacă după măsurare voltul arată la fel, măsurătoarea a fost un tur pierdut.

Măsurătoarea care nu a produs schimbare, de cinci ori la rând, se numește **trompă**.

---

## 12. Planul trebuie scris unde se citește înapoi

Un AI fără memorie **nu poate primi un plan într-o conversație**.

- planul stă în **widgetul de progres**, bifat pas cu pas, sau
- în `AI-Kit\PLAN.md`

Fără asta: cinci runde pierdute, pentru că planul exista doar în conversație, iar conversația
conținea doar constatări de eșec.

---

## 13. Corectitudinea înainte de eficiență

Un număr mare și un cuvânt „gata" **înseamnă că nu s-a întâmplat nimic vizibil**.
Cinci runde de măsurători corecte au arătat exact ca o muncă, pentru că singura diferență
dintre muncă și măsurătoare — **voltul nu s-a mișcat** — nu se vede în ieșire.

---

## 14. Secretele se mută după nume

`_ARCHIVE\Secrets\` conține parole. Sunt mutate **doar după nume**.
**Conținutul nu s-a deschis niciodată, nu se deschide.**

Un fișier gol, al cărui nume arată că e o parolă (`WP Account - …`), se mută oricum.

---

## 15. `E:\` nu se atinge

Nu e discul lui Alex. Nu se citește, nu se scrie, nu se copiază.
Arhiva de 2 TB de poze nu e atașată.

---

## 16. Fiecare index spune ce e în el și prin ce cuvinte se găsește

Un folder n-are index doar dacă nu are fișiere. Un index fără descriere e un număr,
iar un număr nu se caută.

### Cele două blocuri, obligatorii, în această ordine

Imediat după nota de generare și **înainte** de `## Subfoldere`:

1. `## Ce e aici` — una sau două propoziții.
2. `## Cuvinte cheie` — **câte au rezultat din măsurători: minimum 2, maximum 12.**
   Fiecare cuvânt între apostrofuri inverse, separate prin `·`, pe un singur rând.

> **De ce „minimum 2" și nu „5".** Măsurat: din cele 694 de indexuri, **290 (42%)** nu pot
> ajunge la cinci cuvinte din cele trei izvoare de mai jos. Un folder ca `00.1_WhatsApp`
> are exact **3**: numele lui, `README`, `.md` — nu există a doua extensie, iar `README`
> nu are o a doua cuvântă cu valoare. Ca să ajungem la 5, ar trebui inventate două.
> **Regula izvoarelor e mai tare decât regula numărului.** Un rând scurt și adevărat
> servește la căutare; unul lung și inventat servește la umplere și o trage în tăcere.
> Dacă sunt mai puțin de 2, ceva e greșit în măsurătoare — se raportează, nu se completează.

### De unde provin, obligatoriu măsurate

`Ce e aici` se scrie **numai** din:
- cele două tipuri de fișiere care domină folderul după număr,
- numărul rafturilor copil și numele lor,
- cel mai mare element din folder.

Dacă **numele folderului** spune el însuși scopul, acesta se **citează**, nu se interpretează.
Numele e o măsurtoare; el nu dovedește conținut.

`Cuvinte cheie` se iau **numai** din:
- numele folderului,
- primele trei cuvinte cu valoare din numele celui mai mare fișier,
- cele mai frecvente două extensii.

### Interdicții

- **Niciun adjectiv care nu a fost măsurat.** Niciodată „important", „urgent",
  „cheie", „esențial", „special", „de bază". Un cuvânt care nu poate fi numărat
  nu are voie să apară.
- **Nu se deduce o dependență dintr-un nume tehnic.** Un folder care conține `node_modules`
  nu e, prin asta, dependent de Node. Se spune ce e, nu ce presupune.
- **Nu se descrie conținutul fișierelor.** Doar nume, tipuri și numere.
  Conținutul se citește în fișier, nu se inventează în index.
- Blocul adaugă cel mult **8 rânduri** unui index. Un index rămâne un index.

### Cine le scrie

Generatorul — `AI-Kit\build-index.ps1` — la fiecare rulare, înlocuind blocul vechi.
Astea sunt singurele două blocuri generate care se suprascriu.

**Nu se suprascrie niciodată:** rândul `**De ce e aici:**` scris de mână.

_(la 2026-10-08: 24 în `_QUARANTINE` — măsurat cu rânduri care **încep cu**
`**De ce e aici:**`. Căutând doar `De ce e aici` se găsesc 365, fiindcă majoritatea
apar în șabloane și în explicații. Pentru re-verificare: numără rândurile care
încep exact cu `**Dece e aici:**` / `**De ce e aici:**`.)_

Fiecare dintre ele are un motiv real, scris de un om sau de un agent care a privit
fișierul înainte să-l mute.

---

## 17. Sistemul se verifică singur

„Să fie respectat în permanență" nu înseamnă „când îmi amintesc".
Înseamnă un punct de intrare care poate fi chemat de om **sau de ceas**.

### Un singur punct de intrare

`AI-Kit\watch.ps1` rulează, în ordine fixă, doar lucruri care **nu scriu în vault**:

1. `lint` — regulile de denumire, cuvântul interzis, legăturile, copiile de onboarding.
2. `health-check` — numerele vii ale voltului.
3. `reconcile` — socoteala cu backupul, în modul informativ, fără restaurări.

### Ce nu intră în automatism

- **`build-index` nu se rulează la verificare.** Scrie 694 de indexuri. Se rulează
  la cerere sau numai dacă `watch` raportează că un index lipsește.
- **Nicio restaurare.** `reconcile -RestoreModified` rămâne o comandă cu nume,
  nu o treaptă automată. Un automatism care repară nu distinge; un om distinge.
- **Nicio scriere în backup.** Backupul primește citiri și atât.

### Raportul

Un singur fișier, cu data, cu codul de ieșire al fiecărui script și cu un verdict
pe o singură linie: `OK` sau `ATENȚIE: <ce anume>`.

Un raport care spune „merge bine" fără un număr lângă el nu e raport, e dispoziție.
---

## 18. Schema indexului

Un index nu e un rezumat. E un **contract de navigare**: promite că ce scrie
acolo se potrivește cu ce e în folder, și se ține singur la cuvânt.

### 18.1 Anatomia fixă

Orice `00_INDEX.md` — scris de om sau de automat — are exact aceste părți, în
această ordine:

```
# 00_INDEX — <calea relativă, cu / în loc de \>

**De ce e aici:** <o propoziție. Scrisă de om. Nu se atinge niciodată.>

**N fișiere · X · M subfoldere**

> Generat automat de <scriptul care l-a scris>. Nu edita manual — rulează
> scriptul din nou. Randul **De ce e aici** de mai sus, daca exista, se
> pastreaza la fiecare regenerare.

## Ce e aici

<1–2 rânduri, doar din măsurături>

## Cuvinte cheie

`a` · `b` · `c`

## Subfoldere

_Fiecare raft e legat la indexul lui. Un index care nu e legat nu e în arbore._

- [`Nume`](<Nume/00_INDEX.md>) — N fișiere · M subfoldere

## Fișiere

| Fișier | Dimensiune | Modificat |
|---|---|---|
| `exemplu.docx` | 1,2 MB | 2026-10-07 |
```

Un titlu, un motiv, un rând de stare, apoi patru blocuri generate.
Blocul `**De ce e aici:**` e singurul care nu aparține automatului.

### 18.2 Cine deține ce

| Piesa | Cine o scrie | Se poate suprascrie? |
|---|---|---|
| titlul `# 00_INDEX — ...` | automat | da |
| `**De ce e aici:**` | **om** | **nu, niciodată** |
| `**N fișiere · X · M subfoldere**` | automat | da |
| `## Ce e aici` | automat | da |
| `## Cuvinte cheie` | automat | da |
| `## Subfoldere` | automat | da |
| `## Fișiere` | automat | da |
| orice alt text dintre blocuri | om | nu |

**Regula:** automatul rescrie doar ceea ce a scris el. Dacă nu poate spune
sigur că un rând e al lui, nu îl atinge — îl raportează.

### 18.3 Cele cinci stări ale unui index

Automatul pune fiecare folder eligibil în exact una din aceste stări.
Nu există o șasea.

| Stare | Cum se recunoaște | Ce face automatul | Se loghează? |
|---|---|---|---|
| **LIPSA** | folderul există, `00_INDEX.md` nu | creează indexul complet, pe schemă | **nu** — s-a rezolvat |
| **CORUPT** | există, dar e gol, trunchiat sau nu are titlu | îl reface **de la zero** și spune ce a pierdut | **da** — s-a pierdut ceva |
| **INCOMPLET** | are titlu și motiv, dar îi lipsește un bloc din cele patru | îl completează, păstrând ce are | **da** — a fost nesuportat |
| **NEALINIAT** | are toate blocurile, dar măsurătoarea nu mai corespunde | rescrie **doar** blocurile derivate | **da** — realitatea s-a schimbat |
| **CONFORM** | totul corespunde | **nu atinge nimic** | **nu** |

Ultimul rând e cel mai important. Un automat care atinge și un index corect
nu mai lasă urmă de citit, și nu se mai poate vedea când strică ceva.

### 18.4 Reparația se face din datele lui

Când automatul repară un index, **nu îl șterge și nu îl recrează**.

- **Rămân:** titlul, rândul `**De ce e aici:**`, orice text scris de om între blocuri.
- **Se calculează din nou:** cele patru blocuri generate.
- **Înainte de orice scriere**, vechea versiune se copiază în
  `_SYSTEM\arhiva-indexe\<data>\<cale cu / înlocuit cu __>.md`.

  De ce aplatizat, și nu oglindit în subfoldere: un arbore oglindit în arhivă ar
  fi măsurat la următoarea rulare ca foldere noi, iar automatul s-ar hrăni cu
  propria arhivă.

  Folderul poartă **data și ora rulării** (`2026-10-09_20-14-33`), nu doar data.
  Altfel patru rulări pe zi s-ar suprascrie în același loc, iar „înapoi un pas”
  ar însemna înapoi acum două ore, nu înapoi la ce a scris **ultima** dată.

Ultimul punct e cel care face sistemul demontabil. Dacă alinierea începe
intr-o zi să scrie prost, versiunea bună e la un pas înapoi — nu la o căutare
prin backup.

### 18.5 Indexul unui folder gol

Un folder gol primește tot un index, cu aceleași blocuri. Un singur loc
diferă: **unde automatul nu știe, scrie data la care a completat el.**

```
**De ce e aici:** Index completat automat pe 2026-10-08. Folderul era gol în
ziua aceasta. Scrie aici, cu o propoziție, de ce va conține ceva — până atunci
rămâne o întrebare, și e corect să fie o întrebare.
```

```
## Ce e aici

Folder gol pe 2026-10-08: niciun fișier, niciun subfolder.

## Cuvinte cheie

`gol` · `necompletat`
```

Cele două cuvinte sunt singura excepție de la §16: un folder gol nu are nume
de fișiere, extensii sau elemente — nu are de unde măsura. `gol` și
`necompletat` nu sunt inventate; ele **descriu starea măsurată**, care e tocmai
golul. Data scrisă e data la care automatul a completat, nu data folderului.

**Data se scrie o singură dată, și nu se mai reîmprospătează.** E data la care
automatul a completat folderul **prima dată** — nu data zilei de azi. Trecerea
unei zile nu schimbă nimic în index, iar un folder gol rămâne `CONFORM` la
nesfarsit. Dacă indexul nu are deja o dată, se scrie azi; dacă are, se păstrează.

Măsurat pe 2026-10-09. `align-index.ps1` și `build-index.ps1` scriau amândouă
data zilei curente. La 06:00, singur automatul a raportat **40 de foldere goale**
`NEALINIAT` într-o singură zi — le-a rescris și a notat 40 de evenimente de log
care nu însemnau nimic, în fiecare zi, la nesfarsit. Contractul cerea deja lucrul
acesta; implementarea nu-l respecta. Corectat în ambele generatoare.

### 18.6 Ce nu intră niciodată sub automat

Folderele excluse nu sunt indexate, nu sunt reparate, nu sunt atinse:
`.obsidian`, `.trash`, `.git`, `.vault-intelligence`, `.claudian`,
`.neural_memory`, `.sentinel_temp`, `.wwebjs_cache`, `node_modules`,
`01_Theme_Salient`, `02_Media_Uploads\20\d\d`, `Skills_Archive`,
`HERMES-Skills`, `_Skills_BackUp`, `indexuri generate in gresit`.

**Rădăcina unei zone interzise nu e în interiorul ei.** E un raft obișnuit al
voltului și se indexează ca orice raft — doar interiorul e neatins. Altfel
`build-index` și `align-index` ar da răspunsuri diferite exact în zonele
protejate, și unul dintre ele ar rescrie indexuri în interiorul caruia n-are voie.

**O regulă care nu se declanșează e o regulă scrisă în decor.** Fiecare din
cele de mai sus a fost pusă pe o cale care chiar există în volt și s-a
verificat că o oprește. Când se adaugă o excluziune nouă, obligatoriu se
arată o cale reală pe care o oprește — altfel nu e o excluziune, e o
speranță.

### 18.7 O singură definiție a cifrelor

`00_INDEX.md` este **registrul**, nu conținutul. De aceea nu intră niciodată în
numărătoare.

Prin urmare, în orice index:

- `**N fișiere · X · M subfoldere**` numără **doar fișierele de conținut**;
- `X` (octeți) măsoară **doar fișierele de conținut**;
- tabelul din `## Fișiere` listează **doar fișierele de conținut**;
- „Cele mai mari 20" se calculează **doar din fișierele de conținut**.

Motivul e simplu și nu e negociabil: dacă indexul s-ar număra pe sine, cifrele
ar depinde de mărimea textului scris chiar în el, `CONFORM` n-ar mai fi atins
niciodată, iar două rulări consecutive ar da rezultate diferite pe același
folder. Un registru care se numără singur nu mai e un registru.

Aceeași regulă e valabilă pentru **ambele** generatoare. Două scripturi care
măsoară diferit nu se pot verifica între ele — și când rulează pe rând, își
rescriu reciproc indexurile la nesfârșit.

**Aceeași măsurătoare se aplică și COPILILOR.** Când un index își descrie
rafturile copil în `## Subfoldere`, folosește exact cifrele pe care le-ar scrie
acel copil în rândul lui de stare: fișiere de conținut, fără `00_INDEX.md`, cu
subfolderele indexabile, fără zonele interzise. Altfel părintele spune „1
fișier" despre un copil care nu are niciunul.

### 18.8 Un folder gol are o singură descriere

`LIPSA` și `INCOMPLET` se hotărâsc după **structură** — îi lipsește un bloc. Nu
după **cuprins**. Un folder gol care are indexul complet și corect rămâne
**CONFORM** și nu e atins: nu i se adaugă un motiv, nu i se schimbă textul.

Consecința: dacă ambii generatoare ar descrie folderul gol în moduri diferite,
nu s-ar știe care e corect — și s-ar putea respinge un index perfect valid.
Deci **un singur loc decide** ce înseamnă „gol", iar orice schimbare acolo se
face **la contract**, nu într-un script.

### 18.9 Două generatoare, un arbore

`build-index` și `align-index` scriu în același arbore. De aceea:

- **măsoară identic** (§18.7, §18.8);
- **exclud identic** (§18.6) — o zonă interzisă într-unul și nu în celălalt
  înseamnă că unul dintre ele intră în arborele pe care celălalt îl apără;
- **se exclud reciproc** (§19.1, pasul 1) — nu pot rula amândouă în același timp.

Singura diferență permisă între ele e **atribuirea**: fiecare scrie în rândul
său propriu ce script a scris indexul, ca să se știe cine a venit după cine.
Aceea e informație, nu măsurătoare — și se schimbă de la o rulare la alta, fără
să însemne că arborele s-a modificat.

---

## 19. Alinierea automată

### 19.1 Scriptul

`AI-Kit\align-index.ps1`. Fără AI, fără cost, fără internet, fără scriere în
backup. Ordinea, fixă:

1. **Închide ușa în urma lui.** Dacă mai rulează o aliniere, iese tăcut.
2. **Măsoară.** Fiecare folder eligibil: câte fișiere, câte subfoldere, cine.
3. **Clasifică** — cele cinci stări din §18.3.
4. **Repară** — §18.4, bloc cu bloc, păstrând motivul.
5. **Scrie** — doar ce a diferit, după ce a pus vechea versiune la
   `_SYSTEM\arhiva-indexe\<data>_<ora>\`.
6. **Raportează** — în log, **numai dacă a fost un eveniment**.

### 19.2 Logul: `raport-aliniere.log`

- **În rădăcina voltului**, lângă `COTOR.md` și `SPECIFICATII…`, nu în
  `_SYSTEM`. Motivul: e locul unde Alex uită să se uite. Un log ascuns e un
  log care nu se citește.
- **Se scrie doar la eveniment.** O rulare fără nimic de reparat **nu atinge
  deloc fișierul** — nu îl deschide, nu îl reînnoiește. Data de modificare a
  logului înseamnă, prin urmare, „ultima dată când s-a întâmplat ceva".
- Fiecare intrare poartă **numele scriptului și data**:

```
=== align-index.ps1 · 2026-10-08 08:12:33 ===
[NEALINIAT] 01_Projects\01-6-Work_Folder (to sort)/Site/07_Site_Build/02_Media_Uploads
    masura: 27791 fișiere, 13 subfoldere
    indexul spunea: 27500 fișiere, 12 subfoldere
    reparat: blocurile derivate rescrise, motivul pastrat
```

- **Nu se șterge nimic.** Când Alex rezolvă ceva, blocul rezolvat se mută în
  `arhiva- raport aliniere.log`, lângă el, și rămâne acolo ca istoric.
- **O dată pe săptămână**, Alex citește logul și rezolvă. Automatul nu
  rezolvă nimic în numele lui — doar notează ce n-a putut.

### 19.3 Când rulează

Două automate, cu riscuri diferite, neamestecate:

| Automat | Când | Ce face | Risc |
|---|---|---|---|
| `PKMS-Watch` | zilnic, 03:30 | doar citire: lint, health-check, reconcile | nu scrie nimic |
| `PKMS-Aliniere` | **la autentificare** + **de 3 ori pe zi** | aliniază indexurile, scrie doar ce diferă | scrie în volt |

„La computerul pornit" se implementează ca **la autentificare**, cu trei
minute întârziere. Automatul rulează ca Alex, nu ca SYSTEM — un automat de
SYSTEM ar avea alte drepturi și altă vedere asupra voltului. Cele trei ore
sunt 06:00, 13:00 și 20:00.

### 19.4 Ce poate și ce nu poate repara singur

Automatul repară tot ce e **derivat**: numere, liste, linkuri, blocuri lipsă,
indexuri absente, foldere goale marcate.

În log ajung doar situațiile unde **nu poate decide care dintre două lucruri
era adevărat**:

- un link dintr-un index duce într-un folder care nu mai există — nu știe
  dacă folderul a fost mutat sau șters;
- un index e corupt și nu mai are motivul lui;
- același folder apare indexat de două ori pe căi diferite;
- un index e scris de om cu altă structură, iar automatul nu e sigur că-l
  poate aduce la schemă fără să piardă text.

Ultimele trei sunt rare prin construcție — sunt exact cazurile în care
intervenția automată ar distruge informație.

### 19.5 Regula de blocaj

Un singur automat poate scrie în volt odată. Dacă o aliniere e deja pornită
și se declanșează alta, aceasta din urmă iese tăcut, în cod 0, fără log.
Sistemul nu se apără cu un fișier care declară cine are dreptul — se apără
cu un mecanism pe care nu-l poate minți.

### 19.6 Cum se oprește

```powershell
Unregister-ScheduledTask -TaskName 'PKMS-Aliniere' -Confirm:$false
```

Asta e tot. Indexurile deja scrise rămân; se văd în
`_SYSTEM\arhiva-indexe\`, iar logul rămâne la rădăcină ca istoric.