# AGENTS — cum iei vaultul în posesie, cu 0 memorie

Acesta e un **LLM Wiki**: surse brute, un strat de indexuri generat automat, și
un contract. Patternul (raw / wiki / schema) e cel descris în skillul `llm-wiki`;
aici e cum se traduce **în acest vault**, pe `G:\My Drive\GDrive-Second_Brain_PKMS`.

## Cele trei straturi, aici

| Strat (LLM Wiki) | În acest vault | Cine îl scrie |
|---|---|---|
| **Schema** — `AGENTS.md` | `COTOR.md` — contractul sistemului | omul, prin reguli; automatul doar verifică |
| **Wiki** — `index.md` | `00_INDEX.md` în fiecare folder (2.515) + `INDEX CENTRAL.md` (totul, pe un ecran) | `build-index.ps1` / `align-index.ps1` |
| **Log** — `log.md` | istoricul git + `raport-aliniere.log` + jurnalele `*-registru.txt` | append-only; nu se rescrie niciodată |
| **Raw sources** | `00_Inbox` … `08_Clippings` | omul |

**De ce nu există `index.md` și `log.md` cu numele astea:** fiecare ar fi fost o
**a doua adevăr** despre același lucru. `index.md` ar fi duplicat `INDEX CENTRAL.md`
(derivat, deci nu se versionează); `log.md` ar fi duplicat istoricul git, care ține
și *diferențele*, nu doar evenimentele. `AGENTS.md` **există** — acesta e — și
ține contractul lung în `COTOR.md`, ca să nu fie repetat în două locuri.

## Ordinea de citit: patru citiri, zero scanări

1. `COTOR.md` — sistemul: ce e, ce nu se atinge, cine scrie ce
2. `MANUAL DE NAVIGARE - cotor.md` — cum cauți: scara de trei trepte, contractul unui index
3. `START AICI.md` — harta rafturilor, cifrele de azi
4. `00_INDEX.md` din folderul în care lucrezi

Motorul stă în `02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_manual\` (11 scripturi).

## Scara de căutare

| Situație | Faci | De ce |
|---|---|---|
| știi calea | deschizi folderul | nu cauți nimic |
| știi subiectul | `git -C <vault> grep -l -i 'termen' -- '*/00_INDEX.md'` | sub o secundă, în loc de minute |
| nu știi nici subiectul | `INDEX CENTRAL.md` | tot vaultul, pe un ecran |
| ai nevoie de cifre vii | `AI-Kit_manual\health-check.ps1` | cifrele scrise în răspunsuri sunt de ieri |

**Interdicție:** nu scanezi niciodată tot arborele cu `Get-ChildItem -Recurse`
ca să găsești un fișier. Cotrul răspunde în sub o secundă.

## Cele trei operații LLM Wiki, traduse aici

| Operație | Cum arată în acest vault |
|---|---|
| **Ingest** (material nou) | intră în `00_Inbox` → alegi raftul → `align-index.ps1 -DoarCargol '<subarbore>'` reface cotorul acelui raft |
| **Query** | treptele de mai sus: citești **indexuri**, nu conținut |
| **Lint** | `AI-Kit_manual\lint.ps1` (poarta: dă 0 sau nu intri) + `align-index.ps1 -CeVad` (cotorul: câte indexuri nu sunt aliniate) |

## Reguli care nu se încalcă

1. **Nu se șterge nimic.** `rm` și `Remove-Item` sunt blocate. Neclarul ajunge în
   `_QUARANTINE`, cu motiv scris în indexul lui.
2. **Nu se atinge backupul** (`H:\Alex_Knowlege_Vault_BKUP_10-19-2026`). Se citește.
   Dacă lipsește ceva, se copiază **din** el.
3. **Nu se scrie o cale cu un folder numerotat în mână.** Numerotarea e **poziție**,
   nu etichetă, și se oprește la al treilea nivel în adâncime: o cale scrisă tare
   se stinge singură la prima renumerare, și lasă poarta roșie pe o structură sănătoasă.
4. **`00_INDEX.md` nu se editează manual** — se regenerează. Singura excepție:
   rândul `**De ce e aici:**`, scris **de om**, care se păstrează la fiecare regenerare.
5. **Rădăcinile care încep cu `_`** (`_SYSTEM`, `_ARCHIVE`, `_QUARANTINE`) nu primesc
   cod: sublinierea spune deja „sunt sistem, nu conținut".
6. **Zero ștergeri și zero mutări fără R0.** Mutarea conținutului e decizia lui Popy.

## Măsurătorile din acest document

Cifrele de mai jos sunt măsurate pe **19 octombrie 2026**, pe `G:`. Nu copia cifrele
vechi într-un raport: rulează `health-check.ps1` și spune data.

- **2.515** foldere indexate · **16.113** fișiere descrise · **83,67 GB** indexate
- cotorul: **0 LIPSA · 0 CORUPT · 0 INCOMPLET · 0 NEALINIAT · 2.515 CONFORM**
- rădăcini numerotate: **10** (`00_Inbox` … `09_raport-archive`) + **3** de sistem
  (`_ARCHIVE`, `_QUARANTINE`, `_SYSTEM`)

*Fișier scris de om. Nu se regenerează — singurul document de la rădăcină care e
așa, și tocmai de aceea nu poate fi șters de `build-index.ps1`.*
