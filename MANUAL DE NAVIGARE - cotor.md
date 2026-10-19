# MANUAL DE NAVIGARE PRIN COTOR

**Cum găsești ceva în vault fără să scanezi tot volumul.**
Măsurat 2026-10-19 pe `G:\My Drive\GDrive-Second_Brain_PKMS`.

> Acest document nu repetă `COTOR.md` (acolo e *ce* e sistemul).
> Aici e *cum se navighează*. Diferența e tot ce contează: un agent care știe
> ce e sistemul dar nu cum se caută în el ajunge tot la `Get-ChildItem -Recurse`
> peste zeci de mii de fișiere — și atunci cotorul nu mai ajută la nimic.

Motorul care întreține cotorul stă aici:
`02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_manual\`

---

## 0. Interdicția care dă cel mai mult timp înapoi

**Nu scanezi niciodată întregul vault ca să găsești un fișier.**

Măsurat: cotorul atinge **2.515 de foldere indexate** și **16.113 de fișiere**
descrise, prin `git grep`, în **sub o secundă**. Un `Get-ChildItem -Recurse -Force`
atinge tot arborele și durează minute.

Diferența nu e un factor de viteză. E un factor de **răspuns**: scanarea brută
întoarce tot, și tu alegi; cotorul întoarne câteva rânduri, și tu decizi.

---

## 1. Scara de căutare — trei trepte, de la cea mai ieftină

### Treapta 1 — calea o știi

Nu căuta. Deschide.

> **Atenție, corectat 2026-10-19.** O versiune mai veche a acest document spunea
> „nu verifica prin `Test-Path` dacă n-ai dubii". **Acea îndrumare era greșită și a
> costat.** `Test-Path` întreabă dacă *există*, nu dacă *se poate citi*.
>
> Măsurat pe această mașină: `G:` este montat prin DriveFS, care uneori intră într-o
> stare în care **listează directorele, dar citirea fișierelor aruncă** „Incorrect
> function" (Win32 `ERROR_INVALID_FUNCTION`). În acea stare `Test-Path` întoarce
> **True**, iar `COTOR.md` tot se trăbește ca existent. Un zero obținut așa **nu e
> zero** — e o măsurătoare care nu a măsurat.
>
> Regula de acum: dacă *numărul* contează, verifică și **citirea**, nu doar existența:
> ```powershell
> [System.IO.File]::ReadAllBytes('C:\cale\absolută\obligatorie.md').Length
> ```
> Motorul are asta gata: `Test-PkmsVaultCitibil` din `paths.ps1`, legat în toate
> porțile. Nu îl rescrie — îl folosește.

### Treapta 2 — calea nu o știi, dar știi subiectul

Caută **în cotor**, nu în conținut:

```powershell
$V = 'G:\My Drive\GDrive-Second_Brain_PKMS'
git -C $V grep -l -i 'termen' -- '*/00_INDEX.md'
```

Fiecare rezultat e un **folder**, cu un `00_INDEX.md` care spune ce conține.
Citești 20 de linii, nu 20.000.

> **Atenție, măsurat 2026-10-19:** `git grep` pe acest vault s-a dovedit
> **instabil** — de mai multe ori a returnat `fatal: not a git repository` în
> mijlocul altor comenzi din același bloc. Nu e greșeala căutării; e DriveFS-ul.
> Dacă se întâmplă, **repornește DriveFS și reia** — nu căuta altă cale și nu
> conclude că termenul nu există.

Apoi, în folderul găsit, cauți pe loc:

```powershell
Get-ChildItem '<folder>' -File -Recurse | Where-Object { $_.Name -like '*termen*' }
```

> `Select-String -Path <listă de fișiere>` **nu se folosește**: numele cu `[` și `]`
> sunt citite ca tipare și aruncă excepție. Cu `-LiteralPath` merge.

### Treapta 3 — nu știi nici subiectul

`INDEX CENTRAL.md`, din rădăcină. Un ecran, tot vaultul, generat de
`build-index.ps1`. **Nu se versionează** — e derivat, și îl regenerezi.

---

## 2. Contractul unui `00_INDEX.md` — ce poți presupune fără să-l citești

| Bloc | Ce e | Poți presupune? |
|---|---|---|
| titlu + cale | `# 00_INDEX — <cale>` | da |
| `**N fișiere · X · Y subfoldere**` | numere vii, măsurate la generare | da |
| nota de generare | „Nu edita manual" | da — nu se editează, se regenerează |
| `**De ce e aici:**` | scris **de om**, nu de generator | **întotdeauna prezent unde există** |
| `## Ce e aici` | 1–2 propoziții, generate | da |
| `## Cuvinte cheie` | 5–12 cuvinte, generate | da |
| `## Fișiere` | tabel cu fișier, dimensiune, dată | da |
| `## Subfoldere` | linkuri către indexurile copil | da |

**Consecința operațională:** dacă un folder nu are `00_INDEX.md`, **nu e
defect** — poate fi nou, sau poate fi într-o zonă de excludere. Nu crea
manual: rulează `align-index.ps1 -CeVad` și vezi ce spune.

**Consecința a doua:** dacă `**De ce e aici:**` lipsește dintr-un folder care
avea motiv, s-a pierdut un motiv scris de om. Asta e o pierdere reală și se
notează. Nu se regenerează.

**Ultima măsurătoare** (19 octombrie, după numerotare): **0 LIPSA · 0 CORUPT ·
0 INCOMPLET · 0 NEALINIAT · 2.515 CONFORM.** Cotorul e la zi.

---

## 3. Cum se numează un folder

Codul e **poziția**, nu eticheta:

```
02-1-ALEX-SOT       = baza 02, copilul cu nr. 1, numele «ALEX-SOT»
02-2-4-AI-Kit       = baza 02, copilul 2, subcopilul 4, numele «AI-Kit»
```

- Numerotarea **se oprește la al treilea folder în adâncime**. Mai jos, numele rămân
  cum le-ai numit.
- Rădăcinile care încep cu `_` — `_SYSTEM`, `_ARCHIVE`, `_QUARANTINE` — **nu primesc
  cod**: linia de subliniere spune deja „sunt sistem, nu conținut".
- **Nu scrie o cale cu un folder numerotat în mână.** Caută după **nume**. O cale
  scrisă tare se stinge singură la prima renumerare și lasă poarta rosie pe o
  structură sănătoasă — caz produs și reparat pe 19 octombrie.

---

## 4. Când se regenerează cotorul, și când **nu**

| Situație | Ce faci | De ce |
|---|---|---|
| cauți un fișier | **nimic** | cotorul există deja |
| ai mutat 1–2 fișiere | `align-index.ps1 -DoarCargol '<subarbore>'` | nu rescrie tot |
| ai mutat în masă | `build-index.ps1` cu mâna | sute de indexuri |
| un index e corupt | `align-index.ps1` — starea `CORUPT` | îl reface și spune ce a pierdut |
| `lint.ps1` dă ≠ 0 | te oprești, **nu cauți nimic** | poarta e poartă |
| n-ai mai făcut asta de luni | verifică `health-check.ps1`, **nu** rescrie | cifrele sunt vii |

> `build-index.ps1` și `align-index.ps1` **scriu în vault**. Nu intră în lanțul
> `watch.ps1` tocmai pentru că un automatism care scrie în sute de foldere fără
> să fie cerut face vaultul să arate altfel fără motiv.

---

## 5. Zona interzisă pentru orice scan

`Get-PkmsExclusions` din `AI-Kit_manual\paths.ps1` e lista canonică. Măsurat
2026-10-19:

| zonă | ce e |
|---|---|
| `.obsidian` + `plugins_backup` | stare de aplicație |
| `_SYSTEM\Skills_MASTER_Folder\OPTIMUS_Skills_ARCHIVE` | skill-uri vendor, ~126 MB |
| `_QUARANTINE` | tot ce a fost neclar |
| `.vault-intelligence` | derivate |
| `.trash`, `.sentinel_temp`, `.wwebjs_cache`, `.claudian` | gunoaie tehnică |

Niciunul nu se scanează pentru căutare. Niciunul nu se atinge.
`07_Canvas Bases` se folosește **de pe loc** — nu e zonă de arhivă.

---

## 6. Costul real al unei căutări — pentru comparație

| metodă | ce atinge | timp |
|---|---|---|
| `git grep` în `00_INDEX.md` | cotorul | < 1 s |
| `INDEX CENTRAL.md` | 1 fișier | instant |
| `Get-ChildItem -Recurse` | tot arborele | minute |
| `Select-String` pe tot arborele | tot arborele | minute, și fără context |

**Scara asta e un instrument, nu o preferință.** Nu se rescrie la fiecare
mutare: cotorul se regenerează la cerere, și între timp el rămâne suficient
de bun pentru căutare.

---

## 7. Ce **nu** poate face cotorul

| nu poate | de ce |
|---|---|
| găsi după **conținut** în interiorul unui fișier | indexul are nume, nu conținut |
| găsi un fișier **nou**, neindexat | nu a fost generat |
| spune dacă un fișier e **corect** | spune că există și cât e |
| înlocui cunoașterea despre **cine** lucrează ce | ăsta e rolul omului |

Dacă o căutare prin cotor nu dă nimic, **verifică** dacă zona e indexată,
**apoi** caută local, în folder. Nu rescrie cotorul ca să-l faci să
apară ceva ce n-a fost niciodată indexat.

---

## 8. Când DriveFS se rupe — și asta s-a întâmplat

Pe 19 octombrie, `G:` a intrat de **șapte ori** în starea în care directorele se
listă, dar citirea fișierelor aruncă „Incorrect function". Nu s-a pierdut nimic:
obiectele git rămân pe disc, iar push-ul se reia după repornire.

| simptom | ce e de fapt | ce faci |
|---|---|---|
| `git` → `fatal: not a git repository` | `.git` există, dar nu e lizibil | **nu** căuta altă cale: verifică citirea |
| `ReadAllBytes` → „Incorrect function" | montul e mort, nu calea | repornește DriveFS, reia |
| o poartă raportează `0` | poate fi o măsurătoare care n-a măsurat | verifică **și citirea**, nu doar `Test-Path` |
| comit pică cu 128 | eroarea vine *după* comit | **măsoară** `ls-remote`, nu presupune |

Repornirea: oprește cele două procese `GoogleDriveFS`, rulează
`C:\Program Files\Google\Drive File Stream\launch.bat`, așteaptă ~20 s.
Nu se pierde nimic, iar montarea revine completă.

---

## 9. Comanda de pornire, pentru un agent fără memorie

1. citește `START AICI.md` (din `AI-Kit_guide`)
2. citește `COTOR.md` — sistemul
3. citește **documentul de față** — cum cauți în el
4. `02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_manual\paths.ps1` — nu scrie calea tare nicăieri
5. `…\lint.ps1` — dacă nu dă 0, **nu începi**

**Trei clicuri, patru citiri, zero scanări.**

---

*Măsurătorile din acest document sunt din 2026-10-19. Cifrele sunt vii:
rulează `AI-Kit_manual\health-check.ps1` pentru cele de azi. Nu copia cifrele vechi
într-un raport — spune data și spune cum se re-verifică.*