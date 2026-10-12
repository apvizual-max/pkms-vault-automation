# MANUAL DE NAVIGARE PRIN COTOR

**Cum găsești ceva în volt fără să scanezi tot volumul.**
Măsurat 2026-10-12 pe `D:\Alex_Knowlege_Vault`.

> Acest document nu repetă `COTOR.md` (acolo e *ce* e sistemul).
> Aici e *cum se navighează*. Diferența e tot ce contează: un agent care știe
> ce e sistemul dar nu cum se caută în el ajunge tot la `Get-ChildItem -Recurse`
> peste 52.949 de fișiere — și atunci cotorul nu mai ajută la nimic.

---

## 0. Interdicția care dă cel mai mult timp înapoi

**Nu scanezi niciodată întregul volt ca să găsești un fișier.**

Măsurat: un `Get-ChildItem -Recurse -Force` peste volt citește **52.949 de fișiere**
și durează **câteva minute**. În schimb, căutarea în cotor atinge **4.682 de
`00_INDEX.md`** — de **11 ori mai puțin**, prin `git grep`, în **sub o secundă**.

Diferența nu e un factor de viteză. E un factor de **răspuns**: scanarea brută
întoarce tot, și tu alegi; cotorul întoarce trei rânduri, și tu decizi.

---

## 1. Scara de căutare — trei trepte, de la cea mai ieftină

### Treapta 1 — calea o știi

Nu căuta. Deschide. Cost: zero.
Nu verifica prin `Test-Path` dacă n-ai dubii — e o întrebare la care răspunsul
e mereu da, și costă un stat de sistem.

### Treapta 2 — calea nu o știi, dar știi subiectul

Caută **în cotor**, nu în conținut:

```powershell
git -C 'D:\Alex_Knowlege_Vault' grep -l -i 'termen' -- '*/00_INDEX.md'
```

Fiecare rezultat e un **folder**, cu un `00_INDEX.md` care spune ce conține.
Citești 20 de linii, nu 20.000.

Apoi, în folderul găsit, cauți pe loc:

```powershell
Get-ChildItem '<folder>' -File -Recurse | Where-Object { $_.Name -like '*termen*' }
```

### Treapta 3 — nu știi nici subiectul

`INDEX CENTRAL.md`, din rădăcină. Un ecran, tot voltul, generat de
`build-index.ps1`. **Nu se versionează** — e derivat, și îl regenerezi.

---

## 2. Contractul unui `00_INDEX.md` — ce poți presupune fără să-l citești

Măsurat pe 4.682 de indexuri, generate de `AI-Kit\build-index.ps1`:

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
manual: rulează `align-index.ps1`.

**Consecința a doua:** dacă `**De ce e aici:**` lipsește dintr-un folder care
avea motiv, s-a pierdut un motiv scris de om. Asta e o pierdere reală și se
notează. Nu se regenerează.

---

## 3. Adâncimea cotorului — măsurată

| adâncime | câte `00_INDEX.md` |
|---|---|
| 1 | 16 |
| 2 | 60 |
| 3 | 80 |
| 4 | 95 |
| 5 | 635 |
| 6 | 1.350 |
| 7 | 1.599 |
| 8 | 314 |
| 9 | 224 |
| 10+ | 327 |

Nucleul e la **adâncimea 5–7**: acolo e masa rafturilor de lucru. Peste 8,
cotorul devine rar și mai puțin util.

**De ce contează:** dacă cauți într-un subarbore și nu găsești niciun index
peste adâncimea 8, e o informație, nu o eroare — înseamnă că zonele aia nu
sunt indexate, nu că nu există.

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

> `build-index.ps1` și `align-index.ps1` **scriu în volt**. Nu intră în lanțul
> `watch.ps1` tocmai pentru că un automatism care scrie în sute de foldere fără
> să fie cerut face voltul să arate altfel fără motiv.

---

## 5. Zona interzisă pentru orice scan

`Get-PkmsExclusions` din `AI-Kit\paths.ps1` e lista canonică. Măsurat 2026-10-12:

| zonă | fișiere | ce e |
|---|---|---|
| `.obsidian` + `plugins_backup` | 1.174 | stare de aplicație |
| `_SYSTEM\Skills\Skills_Archive` | 9.740 | biblioteci vendor, arhivă |
| `_QUARANTINE` | 4.789 | tot ce a fost neclar |
| `.vault-intelligence` | 14 | derivate |
| `.trash`, `.sentinel_temp`, `.wwebjs_cache`, `.claudian`, `.neural_memory` | 5 | gunoaie tehnică |

Niciunul nu se scanează pentru căutare. Niciunul nu se atinge.
`Canvas Bases` se folosește **de pe loc** — nu e zonă de arhivă.

---

## 6. Costul real al unei căutări — pentru comparație

| metodă | fișiere atinse | timp |
|---|---|---|
| `git grep` în `00_INDEX.md` | 4.682 | < 1 s |
| `INDEX CENTRAL.md` | 1 | instant |
| `Get-ChildItem -Recurse` | 52.949 | minute |
| `Select-String` pe tot arborele | 52.949 + reparse | minute, și fără context |

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

Dacă o căutare prin cotor nu dă nimic, **verifică** dacă zona e indexată
(§3), **apoi** caută local, în folder. Nu rescrie cotorul ca să-l faci să
apară ceva ce n-a fost niciodată indexat.

---

## 8. Comanda de pornire, pentru un agent fără memorie

1. citește `START AICI.md`
2. citește `COTOR.md` — sistemul
3. citește **documentul de față** — cum cauți în el
4. `AI-Kit\paths.ps1` — nu scrie calea tare nicăieri
5. `AI-Kit\lint.ps1` — dacă nu dă 0, nu începi

**Trei clicuri, patru citiri, zero scanări.**

---

*Măsurătorile din acest document sunt din 2026-10-12. Cifrele sunt vii:
rulează `AI-Kit\health-check.ps1` pentru cele de azi. Nu copia cifrele vechi
într-un raport — spune data și spune cum se re-verifică.*