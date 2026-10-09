# DELEGARE — planul de verificare

Scris **înainte** de a trimite vreun agent. Fără listă, agenții nu pot fi manageriați și munca se pierde.
Fiecare agent primește un singur domeniu, nu se suprapun peste altcineva și nu scrie nimic pe disc.

Data: 2026-10-08

---

## Cine verifică ce

| Agent | Domeniu | Ce are voie | Ce are PROIBIT |
|---|---|---|---|
| **V1 — Structură** | arbore de foldere, numerotare, reguli de denumire | citire, `Get-ChildItem`, numărări | orice scriere, orice mutare |
| **V2 — Scripturi** | cele 10 scripturi din `AI-Kit` | citire, rulare read-only a **5** scripturi (`paths`, `setup`, `lint`, `health-check`, `reconcile` — `reconcile` în modul implicit) | `build-index.ps1` (scrie), `align-index.ps1` (scrie), `reconcile.ps1 -Restore` (scrie), `inchide-log.ps1 -Arhiveaza` (mută în arhivă) |
| **V3 — Documentație** | legături între documente, indexuri, carantină | citire, căutare de fișiere | orice scriere |

Niciun agent nu atinge `E:\`, nu atinge backup-ul, nu atinge `.git`.

---

## V1 — Structură (agent `verifier`)

Întreabă la care trebuie răspuns **da / nu**, cu dovezi:

1. Bazele `00`–`06` sunt 7 la rădăcină și **nu au fost renumerotate**. `10_Work` e raft,
   nu bază. Verifică **explicit** că fiecare număr 00…06 apare o singură dată ca prim
   segment la rădăcină.
2. `10_Work` există la rădăcină și are exact cele 8 rafturi: `Joburi`, `In Progress`, `Clienti`,
   `Sisteme AI`, `Site`, `Personaj Sentinel`, `Documentatie AI`, `Casa`.
3. Cele 3 rafturi ale mașinii — `_SYSTEM`, `_ARCHIVE`, `_QUARANTINE` — **nu** încep cu cifră.
   La fel `AI-Kit` și `Canvas Bases`.
4. **Cuvântul interzis nu apare în niciun nume** de folder sau fișier, pe întregul vault.
   Verificare pe **nume**, nu pe conținut. Atenție: cele două documente care *definesc* regula
   conțin cuvântul în text — nu se penalizează.
5. Folders-ele cu punct la început (`.obsidian`, `.claudian`, `.neural_memory`, `.sentinel_temp`,
   `.trash`, `.vault-intelligence`, `.wwebjs_cache`) sunt încă la rădăcină și **neatinse**.
6. `Canvas Bases` este încă la rădăcină.
7. Backup-ul există la `D:\Alex_Knowlege_Vault - Backup - 10-08-2026`, este **în afara** vault-ului
   și cel mai recent fișier din el are data `2026-10-07 15:12:25` (dovadă că nu a fost atins).
8. Niciun folder nou numerotat nu a apărut la rădăcină după `10_Work` (deci nu s-a numerotat
   rațional în baza veche).

---

## V2 — Scripturi (agent `verifier`)

Rulările permise, în această ordine, din `D:\Alex_Knowlege_Vault\AI-Kit`:

```
powershell -NoProfile -ExecutionPolicy Bypass -File .\paths.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\lint.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\health-check.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\reconcile.ps1
```

**NU** rula `build-index.ps1` — scrie `00_INDEX.md` peste tot (la data de 2026-10-08,
după ștergerile de azi: **661** de indexuri utile în afara carantinei; erau 693 înainte).
**NU** rula `reconcile.ps1 -Restore` — rescrie în vault.
**NU** rula `align-index.ps1` — scrie `00_INDEX.md`, arhiva lui și logul. Nici cu
`-CeVad`: e interzis prin rol, nu doar prin efect.

Despre `align-index.ps1` raportează **doar citind fișierul**, și anume:
1. Cele cinci stări apar în ordinea din §18.3: `LIPSA`, `CORUPT`, `INCOMPLET`,
   `NEALINIAT`, `CONFORM` — și `CONFORM` nu atinge nimic.
2. Logul e `raport-aliniere.log` **la rădăcina voltului**, nu în `_SYSTEM`.
3. Blocajul se face cu **mutex**, nu cu fișier-pid.
4. Fiecare tipar de excluziune e scris `[\\/]`, nu `\01` — pentru că `\01` e citit de
   .NET ca secvență **octală** (`U+0001`) și nu se declanșează pe nicio cale reală.
5. ~~Automatul `PKMS-Aliniere` **nu există** la 2026-10-08.~~ **CORECTAT:** la 2026-10-09
   automatul exista si ruleaza (Ready, ultima 20:00:01, rezultat 0). Se verifica la
   fel cu `Get-ScheduledTask -TaskName 'PKMS-Aliniere'` — dar acum ca confirmare,
   nu ca presupunere ca ar lipsi.

Verifică:

1. Fiecare scriptul **se termină cu un cod de ieșire** și îl raportează.
2. `lint.ps1` încheie cu **0 erori** și cod de ieșire 0. **Atenționările se raportează,
   dar nu blochează** — poarta trece și cu ele. Raportează separat `0 erori` și câte
   atenționări, și nu cerea „0 atenționări" drept condiție de trecere.
3. Toate cele 6 fișiere au **BOM UTF-8** (PowerShell 5.1 nu citește altfel).
4. **Niciun script nu are calea de backup scrisă fix** — `paths.ps1` o descoperă.
   Caută literal șirul `Backup` în fiecare script și raportează fiecare apariție.
5. Dacă `paths.ps1` este o librarie (definește funcții), spune clar cum se încarcă.

---

## V3 — Documentație (agent `verifier`)

1. Fiecare document de la rădăcină pe care îl promite `ONBOARDING.md` **există efectiv**.
2. Fiecare legătură markdown de tip `](nume-fișier.md)` din documentele de la rădăcină
   indică un fișier **care există** în același folder sau în subfolderele indicate.
   Raportează **fiecare** legătură ruptă, cu documentul și linia.
3. Fiecare folder din `_QUARANTINE` conține un `00_INDEX.md` care **spune de ce** e acolo.
   Raportează folderele fără explicație.
4. `INDEX CENTRAL.md` este generat, nu scris de mână: verifică că prima linie conține un marcaj
   de tip „generat automat” și o dată, și raportează dimensiunea reală în linii.
5. Numărul de indexuri: confirmă separat cele din afara carantinei și cele din carantină,
   ca să poată fi verificată afirmația „de indexuri utile". **Cifra e vie**: la 2026-10-08,
   după ștergerile făcute în aceeași zi, sunt **4.649** pe disc și **661** utile
   (înainte: 4.681 și 693). Raportează cifra **și** comanda cu care ai măsurat.
6. Fiecare referință la un fișier citat în documentație indică un fișier care **există**
   efectiv. Raportează fiecare referință ruptă, cu documentul și linia.

---

## Unde aștept, unde acționez

- **Aștept** în cele trei rapoarte. Nu rescriu nimic din `AI-Kit` și nu ating documentele
  cât timp ele nu s-au întors.
- **Acționez** pe singurul lucru pe care îl dețin eu în exclusivitate: fișierul SKILL.md din
  `C:\Users\apviz\.minimax\skills\popy_minimax_personal_knowledge-vault\`.
  Nu se suprapune cu niciun dintre cei trei agenți.
- **După rapoarte**: orice abatere reală se repară, apoi se rulează din nou `lint.ps1`.

## Regula de aur

Un agent care nu găsește nimic nu înseamnă că e bine. Înseamnă că n-a putut căuta.
Dacă un agent raportează „totul e corect", cere dovezi: comanda rulată și numărul exact
returnat. „0 erori" fără cifra returnată este o presupunere, nu o verificare.