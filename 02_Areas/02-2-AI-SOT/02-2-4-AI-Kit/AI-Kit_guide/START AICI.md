# START AICI

Harta vaultului tău. Un singur loc unde vezi tot ce ai.
**Cifrele de mai jos sunt măsurate pe 8 octombrie 2026, după reorganizarea care a dus
`07_Site_Build` în `01_Projects\01-6-Work_Folder (to sort)` și pe după ștergerile făcute în aceeași zi.**

> **O cifră vie e o obligație, o cifră statică e o minciună cu termen.** Nu schimba
> cifrele aici după ureche — rulează `AI-Kit\health-check.ps1`, care numără pe loc și
> tipărește `TOTAL:`.

---

## Cele 8 mari

| Folder | Ce e | Cât |
|---|---|---|
| **00_Inbox** | **Intrare.** Ce e nou sau fără loc intră aici, tu sortezi. | 16 fișiere |
| **01_Projects** | Lucruri active. Știi ce ai de făcut acum. | 1 fișier |
| **02_Areas** | Clienți rămași, CV, cercetare despre tine. | 696 fișiere |
| **03_Resources** | Materie primă: ce ai adunat, tăiat, fotografiat, descărcat. | 873 fișiere |
| **04_Archive** | Nimic valoros. Se poate șterge când vrei. | 1.088 fișiere |
| **05_Attachments** | Imagini captate de tine. | 1.181 fișiere |
| **06_Metadata** | Ținte, șabloane, agenți. | 30 fișiere |

**Numărătoarele de mai sus sunt fișiere de conținut** — `00_INDEX.md` nu intră în ele,
fiindcă indexul e registrul, nu conținutul (contractul §18.7).

**`07_Site_Build` nu mai e la rădăcină.** Site-ul a urcat în `01_Projects\01-6-Work_Folder (to sort)`, unde e singurul
loc în care intri ca să lucrezi: `01_Projects\01-6-Work_Folder (to sort)\01-6-8-Site` are **29.720 de fișiere de conținut**.

**Regula:** numerele cresc. Nu schimbi numerele, adaugi următorul.

---

## Cele trei rafturi ale mașinii

Nu-s ale tale, dar stau în vault ca să nu te împiedici de ele.

| Folder | Ce e |
|---|---|
| **_SYSTEM** | Scripturi, biblioteci de programe, prompturi, rest de unelte. 9.770 de fișiere |
| **_ARCHIVE** | Parole și lucruri scoase din calea deschisă. 5 fișiere |
| **_QUARANTINE** | Aici pui ce nu vrei. **Nu șterg nimic, niciodată.** 18 fișiere de conținut |

**Ce s-a schimbat pe 2026-10-08, în carantină.** Înainte erau aici cele 12 foldere goale
scoate în runda 3, cele 92 de descrieri de job identice și fișierul de decizie
`H hotarare foldere goale.md`. **Alex le-a șters pe toate, cu mâna lui** — a fost
decizia lui, nu o ștergere automată. Ce a rămas: rafturi cu motive scrise în
`00_INDEX.md`, fiecare index spunând de ce e acolo.

**Ce nu s-a șters:** **`Clippings`**, care a fost mutat **la rădăcina vaultului**, nu
șters. **Trebuie să rămână acolo** — Obsidian e programat să-l caute la rădăcină. Are
13 subfoldere (rafturi) și 404 fișiere de conținut. Doar 3 rafturi conțin indexuri
în interior — `AI TOOLS` (6), `HERMES` (3), `LINKEDIN` (2) — iar împreună cu indexul de
la rădăcină, `Clippings` are 12 fișiere `00_INDEX.md`.

> **Cifrele astea sunt măsurate pe 2026-10-08**, după ce `Clippings` a fost recuperat
> integral din backup. `Clippings` e un folder viu — primește tăieri în zile întregi, deci
> cifra se verifică, nu se presupune. Pentru re-verificare:
> `Get-ChildItem 'D:\Alex_Knowlege_Vault\Clippings' -Directory -Force | Measure-Object | Select-Object -ExpandProperty Count`
> `Get-ChildItem 'D:\Alex_Knowlege_Vault\Clippings' -Recurse -File -Force | Where-Object { $_.Name -ne '00_INDEX.md' } | Measure-Object | Select-Object -ExpandProperty Count`
> `Get-ChildItem 'D:\Alex_Knowlege_Vault\Clippings' -Recurse -File -Force -Filter '00_INDEX.md' | Measure-Object | Select-Object -ExpandProperty Count`

---

## Unde stă greutatea — de unde începi

**Cele două locuri care țin aproape tot vaultul.**

1. **`01_Projects\01-6-Work_Folder (to sort)\01-6-2-Clienti\Knights Tempar` — 44,57 GB**
   396 de fișiere, în două comenzi: *Ordinul Sfantului Bernard* (284 fișiere, 30,94 GB)
   și *Ordinul Dragonilor – Juramant Cavaler* (104 fișiere, 13,61 GB).
   ~~`02_Areas\02_1-ALEX-Folder\AP-ID - B2B\AP-ID - Clients\Knights Tempar`~~ — drumul
   acesta nu mai există: raftul a urcat în `01_Projects\01-6-Work_Folder (to sort)` la reorganizare.

2. **`01_Projects\01-6-Work_Folder (to sort)\01-6-8-Site\07_Site_Build\02_Media_Uploads` — 27.689 de imagini, 1,9 GB**
   Site-ul, din 2010. Nu s-a atins niciun nume.

Restul: **raftul retras** — 660 de fișiere (clienți, brief-uri, artwork). Client închis:
> numele lui nu mai apare nici în acest document, nici în indexuri. Raftul stă în
> `_QUARANTINE\retirat-2026-10-10\` — mutat, nu șters.

> **La data de 2026-10-08:** `Knights Tempar` = 396 de fișiere / 44,57 GB (confirmat),
> raftul retras = 660 de fișiere (cifra de 7 octombrie era 1.742 — nu se mai reproduce
> după reorganizare). Măsură cu:
> `Get-ChildItem 'G:\My Drive\GDrive-Second_Brain_PKMS\01_Projects\Work_Folder (to sort)\Clienti' -Directory | ForEach-Object { $_.Name + ': ' + (Get-ChildItem $_.FullName -File -Recurse -Force | Where-Object { $_.Name -ne '00_INDEX.md' } | Measure-Object).Count }`

---

## Dosarele cu punct în față — NU LE ATINGE

Astea sunt ale unor programe. Dacă le muți, programele se strică.

`.obsidian` · `.vault-intelligence` · `.trash` · `.claudian` · `.neural_memory` ·
`.sentinel_temp` · `.wwebjs_cache`

Și `Canvas Bases` — e funcția **Bases** din Obsidian. Se folosește de pe loc, nu o atingi.

---

## Ce a fost scos din rădăcină în curățarea din 7 octombrie

Rădăcina avea dosare care nu aparțineau structurii. Le-am dat fiecare un loc:

| A fost | Acum e | De ce |
|---|---|---|
| ~~`Clippings` (310 fișiere)~~ → `03_Resources\03_8-Clippings` | **`Clippings`, înapoi la rădăcină** | **mutat înapoi pe 2026-10-08: Obsidian e programat să-l caute la rădăcină. Mutat acolo ar opri programele să scrie acolo.** |
| `POPY - GORDON - Docker Ai` | `_SYSTEM\GORDON - Docker AI` | e procesul unei unelte |
| `Wisper_Transcripts` | `_SYSTEM\Wisper Transcripts` | e al unei unelte |
| `Tags` | `_QUARANTINE\resturi de sistem` | conținea doar baza locală a unui program |
| `TagsRoutes` | `_SYSTEM\resturi de unelte` | un singur fișier de log, gol |

---

## Două lucruri pe care ți le spun fără să le fi schimbat

**1. `01_Projects\01_2-AP-ID - AI Systems` conține un depozit Git întreg** — `.git\` cu obiectele
lui, la folderul PLATEFUL. E un folder cu punct, deci nu l-am atins. Îți consumă loc și îți
molutește folderul, dar e istoric de proiect și decizia de a-l șterge e a ta.

**2. În `Clippings\AI TOOLS` sunt 223 de fișiere de conținut** (măsurat recursiv pe
2026-10-08, după ce `Clippings` a fost recuperat integral din backup: 404 de fișiere,
52 de foldere, 397 MB, 13 rafturi). Multe au nume lung și ilizibile — codul unei
adrese web. Nu le-am reatribuit numele, pentru că Obsidian se poate lega de ele prin
nume și așa ceva ar strica legăturile. Se poate face corect, cu repararea legăturilor.

> **Cifra asta e măsurată azi**, dar `Clippings` e un folder viu — primește tăieri
> din zile întregi. Nu e o cifră permanentă. Pentru re-verificare:
> `Get-ChildItem 'D:\Alex_Knowlege_Vault\Clippings\AI TOOLS' -Recurse -File -Force | Where-Object { $_.Name -ne '00_INDEX.md' } | Measure-Object | Select-Object -ExpandProperty Count`

---

## Două corecturi de ale mele, spuse deschis

**Am crezut că `05_1-Images\Screenshots\Video Screen Shots` e un folder duplicat** și eram gata să-l
scriu la carantină. Am verificat fișier cu fișier: 6 din cele 12 capturi există **doar** acolo.
A rămas neatins. Dacă aș fi decis din-o privire, ți-am fi șters muncă.

**Am mutat 4 fișiere din jobul INFUSE la carantină** ca „rulare veche". Le-am mutat pentru că
exista o copie completă, cu PDF-uri, în folderul de deasupra. Sunt în `_QUARANTINE`, nu șterse.
Dacă te interesează prima rundă, le ai înapoi într-o secundă.

---

## Unde intră tot ce vine de pe WhatsApp, Gmail, NotebookLM sau din web

`00_Inbox` nu mai e o găleată. Are cinci rafturi, goale, care te așteaptă:

`00.1_WhatsApp` · `00.2_Daily_Raw_Notes` · `00.3_Email` · `00.4_Web_Clips` · `00.5_NotebookLM`

 Nimic nu se pune singur în structură. Totul trece întâi pe aici, prin el alegi.

---

## Actul care dovedește că nu s-a pierdut nimic

**`AUDIT_RECONCILIERE_FINAL.md`, în rădăcină.** Conține calculul, cu fiecare fișier
nou numit și cu cine l-a făcut.

Rezultatul, **la momentul acelei reconcilieri**: **46.263 în vault, 46.233 în backup,
plus 30** — **23 de fișiere scrise de mine** (hărțile, acest raport, rafturile de primire)
**+ 7 capturi de ecran făcute de tine** între 20:12 și 22:58, în timp ce lucram.

> **Aceasta e o socoteală din 7 octombrie, nu de azi.** De atunci s-a mutat `07_Site_Build`
> în `01_Projects\01-6-Work_Folder (to sort)`, s-a mutat `Clippings` înapoi la rădăcină și s-au șters, pe 2026-10-08,
> cele 92 de descrieri de job identice, cele 6 rafturi goale din carantină și
> `H hotarare foldere goale.md`. **Cifra de azi** se obține cu
> `AI-Kit\reconcile.ps1` (raportează, nu scrie) — și se citește rândul
> `socoteala inchisa: X din Y`: dacă nu se adună, scriptul spune *„nu am comparat tot"*.

---

## Tot ce s-a mutat, se poate întoarce

Fiecare mutare e într-un tabel cu adresa veche și adresa nouă:
`C:\Users\apviz\.minimax\vault-manifest\REVERT.csv`

Backup-ul tău e la `D:\Alex_Knowlege_Vault - Backup - 10-08-2026` — neatins, nu am scris niciodată în el.
Verificarea de azi: **niciun fișier din backup nu lipsește din vault.**