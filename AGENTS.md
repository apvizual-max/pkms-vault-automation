# AGENTS — cum iei vaultul în posesie, cu 0 memorie

Acesta este un **LLM Wiki**: surse brute, un strat de indexuri generat automat, și
un contract de sistem. Patternul (raw / wiki / schema) este cel descris în arhitectura
generală de AI Knowledge Management; aici este cum se traduce **în acest vault**,
pe stocarea locală NVMe **`E:\Google\GDrive\GDrive-Second_Brain_PKMS`** (oglindită permanent
în Google Drive Cloud și accesibilă secundar prin montura virtuală `E:\Google\GDrive\GDrive-Second_Brain_PKMS`).

---

## Rolurile Agenților: Mavis Local & Antigravity Sentinel

Sistemul este operat într-o arhitectură duală:
- **Operator Frontend / Co-Pilot Local (Mavis Local - MiniMax Code):**
  - Gestionează sarcinile zilnice, navigarea prin indexuri, sortarea inbox-ului, crearea notițelor și interacțiunea directă cu Popy.
- **Operator Backend / Sentinel Suveran (Antigravity - Google Deepmind Gemini Brain):**
  - Arhitectul de sistem și backend engineer-ul suveran.
  - Administrează depozitul decuplat Git (`E:\Google\GitData-PKMS`), sincronizarea cu GitHub (`pkms-vault-automation`), pipeline-ul din Windows Task Scheduler (`PKMS-*`) și depanarea avansată în caz de avarii, erori de disc, lock-uri sau blocaje DriveFS.
  - Intervine ca **rescue operator** oricând Mavis Local întâmpină o limitare sau o defecțiune critică de sistem.

---

## Arhitectura Stocării și Decuplarea Git

1. **Oglinda Fizică Locală (Local Mirroring):**
   - Rădăcina de lucru fizică este [`E:\Google\GDrive\GDrive-Second_Brain_PKMS`](file:///E:/Google/GDrive/GDrive-Second_Brain_PKMS).
   - Google Drive for Desktop menține această imagine sincronizată bit-cu-bit cu Google Drive Cloud.
2. **Decuplarea Atomică Git (`E:\Google\GitData-PKMS`):**
   - În rădăcina vault-ului, `.git` este acum un **fișier text scalar de 31 de octeți**:
     `gitdir: E:/Google/GitData-PKMS`
   - Baza de date Git (obiecte, packfile-uri, index, refs, logs) se află pe NVMe la [`E:\Google\GitData-PKMS`](file:///E:/Google/GitData-PKMS), complet izolată de scannerul Google Drive for Desktop.
   - **Beneficiu:** A fost eliminată definitiv eroarea `0x91 ERROR_DIR_NOT_EMPTY` și blocajele de tip `index.lock`.
3. **Repo GitHub de Automatizare:**
   - Remote: `https://github.com/apvizual-max/pkms-vault-automation.git` (ramura `master`).
   - Urmărește doar motorul (`AI-Kit`), documentația, indexurile `00_INDEX.md` și fișierele de handoff `.md`. Conținutul personal și logurile mari sunt excluse prin `.gitignore`.

---

## Cele trei straturi, aici

| Strat (LLM Wiki) | În acest vault | Cine îl scrie |
|---|---|---|
| **Schema** — `AGENTS.md` | `COTOR.md` — contractul sistemului | omul, prin reguli; automatul doar verifică |
| **Wiki** — `index.md` | `00_INDEX.md` în fiecare folder + `INDEX CENTRAL.md` (totul, pe un ecran) | `build-index.ps1` / `align-index.ps1` |
| **Log** — `log.md` | istoricul git + `raport-aliniere.log` + jurnalele `*-registru.txt` | append-only; nu se rescrie niciodată |
| **Raw sources** | `00_Inbox` … `08_Clippings` | omul |

---

## Ordinea de citit: patru citiri, zero scanări

1. `COTOR.md` — sistemul: ce e, ce nu se atinge, cine scrie ce.
2. `MANUAL DE NAVIGARE - cotor.md` — cum cauți: scara de trei trepte, contractul unui index.
3. `02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_guide\START AICI.md` — harta rafturilor, cifrele de azi.
4. `00_INDEX.md` din folderul în care lucrezi.

Motorul stă în `02_Areas\02-2-AI-SOT\02-2-4-AI-Kit\AI-Kit_manual\` (12 scripturi).

---

## Scara de căutare

| Situație | Faci | De ce |
|---|---|---|
| Știi calea | deschizi folderul | nu cauți nimic |
| Știi subiectul | `git -C <vault> grep -l -i 'termen' -- '*/00_INDEX.md'` | sub o secundă, în loc de minute |
| Nu știi nici subiectul | `INDEX CENTRAL.md` | tot vaultul, pe un ecran |
| Ai nevoie de cifre vii | `AI-Kit_manual\health-check.ps1` | cifrele scrise în rapoarte vechi sunt istorice |

**Interdicție:** nu scanezi niciodată tot arborele cu `Get-ChildItem -Recurse` ca să găsești un fișier. Cotorul răspunde în sub o secundă.

---

## Reguli care nu se încalcă

1. **Nu se șterge nimic.** `rm` și `Remove-Item` sunt blocate. Neclarul ajunge în `_QUARANTINE`, cu motiv scris în indexul lui.
2. **Nu se atinge backupul extern** (`H:\CLAUDE_Archive` și `H:\Alex_Knowlege_Vault_BKUP_10-19-2026`). Se citesc doar la nevoie.
3. **Nu se scrie o cale cu un folder numerotat în mână.** Numerotarea este poziție, nu etichetă, și se oprește la al treilea nivel în adâncime.
4. **`00_INDEX.md` nu se editează manual** — se regenerează. Singura excepție: rândul `**De ce e aici:**`, scris de om.
5. **Rădăcinile care încep cu `_`** (`_SYSTEM`, `_ARCHIVE`, `_QUARANTINE`) nu primesc cod numeric: sublinierea spune deja „sunt sistem, nu conținut”.
6. **Zero ștergeri și zero mutări fără R0.** Mutarea conținutului este decizia suverană a lui Popy.
7. **Ramura Knights Templar** (cele două directoare identice de 14,09 GB din `01_Projects`) rămâne neatinsă până la organizarea manuală de către Popy.

---

## Măsurătorile de Sistem (21 Octombrie 2026)

Cifre măsurate pe stocarea locală NVMe `E:\Google\GDrive\GDrive-Second_Brain_PKMS`:
- **51.157** fișiere de conținut activ • **88,72 GiB** volum net util (verificat de `health-check.ps1`).
- **95.862.563.649 octeți** volum total brut (**95,86 GB zecimali** în Google Drive Cloud Web = **89,28 GiB binari** în Windows Explorer). Paritate de biți: **100%**.
- Baza de date Git: **decuplată** în `E:\Google\GitData-PKMS`.
- Taskuri automate: **4 active** (`PKMS-Aliniere`, `PKMS-Watch`, `PKMS-GitAutoCommit`, `PKMS-DriveFS-AutoRepair`).
- Stabilitate vault: **100%** • Fișiere pierdute: **0**.
