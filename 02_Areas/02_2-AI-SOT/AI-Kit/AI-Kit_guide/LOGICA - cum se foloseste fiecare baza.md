# LOGICA — cum se folosește fiecare bază

Aceasta este întrebarea la care trebuie să răspundă orice AI care primește voltul:
**„ce pun aici, și de ce?”**

Fiecare bază are: **scop · mecanism · ce intră · ce NU intră · unde se duce · cum se folosește.**

---

## 00_Inbox — poarta

**Scop:** singurul punct unde intră orice lucru nou, din orice sursă.

**Mecanism:** nimic nu se pune direct în structură. Totul trece pe aici, apoi **Alex alege**.

**Cele 5 rafturi de primire:**

| Raft | Ce intră | Surse |
|---|---|---|
| `00.1_WhatsApp` | linkuri, capturi, idei primite pe WhatsApp | puntea MiniMax, `127.0.0.1:3071` |
| `00.2_Daily_Raw_Notes` | note zilnice brute, înainte de a fi puse undeva anume | tine, zilnic |
| `00.3_Email` | material descărcat din Gmail pentru prelucrare | `google-workspace-mcp` |
| `00.4_Web_Clips` | articole tăiate cu Obsidian Web Clipper | extensia Clipper |
| `00.5_NotebookLM` | ce scoți din NotebookLM și vrei să-l păstrezi | `minimax-notebooklm` |

**Regula:** WhatsApp se **citește**, nu se răspunde. Răspunsul cere confirmarea destinatarului și a textului exact.
Gmail nu trimite, nu șterge, nu marchează. NotebookLM se citește.

**Ce NU intră:** nimic din baza veche. `00_Inbox` e gol acum — de fapt gol, nu plin cu gunoi.

**Cum se folosește:** capturezi → aruncă în raftul corect → când ai timp, decizi. Golitul lui înseamnă că ai procesat tot.

---

## 10_Work — masa de lucru

**Scop:** singurul nivel în care intri ca să lucrezi.

**Mecanism:** proiectele active **urcă** din bază în `10_Work`, pe raftul lor. Când se termină, coboară înapoi.

**Cele 8 rafturi** — vezi `COTOR.md` pentru cifre.

| Raft | Scop | Nu se folosește pentru |
|---|---|---|
| `Clienti` | tot ce livrezi unui client | documente care nu sunt ale unui client |
| `Site` | singurul website, întreg | nimic altceva |
| `Joburi` | tot fluxul de aplicare | nu e bibliotecă de CV-uri vechi |
| `Casa` | tot ce ține de casă | nu e loc pentru orice notă personală |
| `Sisteme AI` | OPTIMUS, Sentinel, Hermes, AP-ID Systems | nu e bibliotecă de știri AI |
| `Personaj Sentinel` | ființa, nu manualul ei | nu e documentație |
| `Documentatie AI` | ce ai tăiat din web | nu e sursa originală, e copia ta |
| `In Progress` | ce e în mișcare acum | nu e arhivă — se golește |

**De ce contează:** înainte, `02_Areas\...\Knights Tempar` era la cinci niveluri adâncime. Acum e la **două clicuri**.

---

## 02_Areas — fondul de lucru al lui Alex

**Scop:** tot ce e al tăruși despre tine și clienții tăi, care **nu e treabă curentă**.

**Ce a rămas acolo:** CV-ul, cercetarea despre personalitatea ta (16Personalities, 796 MB), inspirațiile, amintirile.

**Mecanism:** nu se mai adaugă nimic. Se citește și se consultă.

**Cum se folosește:** când ai nevoie de ceva despre tine însuți — personalitate, tipuri, memorie — te uiți aici.

---

## 03_Resources — materie primă

**Scop:** ce ai **adunat**, nu ce ai făcut.

| Folder | Ce e |
|---|---|
| `03_3-ALEX_Research` | 678 fișiere · 796 MB — personalitate, cercetare UX, baze de date cu expozanți |
| `03_5-ALEX_Inspirations` | 160 imagini — tabla de inspirație |
| `03_4-ALEX_Memories` | 16 fotografii. Nu s-au atins |
| `03_0-iDEEAS` | 13 note de idee, neaplicate încă |
| `03_6-AP-ID_Prompts_and_JSON` | 2 fișiere de prompt |

**Cum se folosește:** te interesează vizual → `03_5`. Te interesează de tine → `03_3`. Ai o idee → `03_0`.

---

## 04_Archive — nimic valoros, în așteptare

**Scop:** păstrat, dar scos din drum.

`ZURLI - copii de site-uri` — 1.082 de copii ale unor site-uri, 113 MB. Nu le-ați citit niciodată.
Când vrei, se poate șterge. **Până atunci stau.**

---

## 05_Attachments — ce ai capturat

**Scop:** imaginile tale. Capturi de ecran, fotografii, lipituri.

**NU e o cale de captură.** Nu se pune nimic direct aici la venire.
`05_Attachments` e **depozitul** a ceea ce ai hotărât deja să păstrezi.
Singura poartă de intrare în volt rămâne **`00_Inbox`** — fotografie de pe telefon,
captură de ecran, PDF trimis pe WhatsApp sau e-mail: toate ajung întâi în Inbox,
prin calea de transfer pe care o folosești, și **de acolo** sunt triate.

- ai nevoie de un mecanism automat telefon → volt? **nu există unul instalat**;
  până se instalează, transferul se face manual în `00_Inbox`, și atât.
- **care raft de primire?** `00.1_WhatsApp` dacă vine prin conversație,
  `00.3_Email` dacă vine prin e-mail, `00.2_Daily_Raw_Notes` dacă îl notezi tu în ziua
  respectivă. **Telefonul nu are raft propriu**: până se creează unul, o fotografie
  trimisă de mână se pune direct la rădăcina `00_Inbox`, lângă celelalte note libere,
  și se triază de acolo odată cu restul. Nu se inventează un raft nou doar pentru că
  azi a venit o fotografie.
- de acolo: dacă e o fotografie de document care nu aparține niciunui proiect,
  se mută în `05_Attachments`; dacă aparține unui proiect, merge în raftul lui de lucru.
- **nimic nu ocolește Inbox.** Inbox nu e o formalitate, e singurul loc unde
  alegi ce păstrezi.

`05_1-Images` — 1.179 fișiere · 403 MB.

**Cum se folosește:** când ai nevoie de o captură veche, cauți aici. Nimic nu se șterge, pentru că nu știi
când o vei mai folosi.

---

## 06_Metadata — ținte și șabloane

**Scop:** cum funcționează mașina, nu ce conține ea.

`Gemini Scribe` (hook-uri, prompturi, stări) · `Agent-Archive` (backup-uri de AGENTS.md) · `Templates`.

**Notă:** 1,7 MB de jurnale de eroare au fost mutate în `_SYSTEM\resturi de unelte`. Nu sunt conținut.

---

## _SYSTEM, _ARCHIVE, _QUARANTINE — rafturile mașinii

Nu au numerotare. **Deliberat** — un folder fără cifre în față spune imediat „asta nu e conținutul tău".

| | Ce e | Cine decide |
|---|---|---|
| `_SYSTEM` | biblioteci de programe, prompturi, rest de programe | AI-ul poate muta aici, cu motiv scris |
| `_ARCHIVE\Secrets` | parole | mutate **doar după nume**. Conținutul nu s-a deschis niciodată |
| `_QUARANTINE` | orice neclar | **numai Alex** |

**Regula carantinei:** dacă nu ești sigur dacă ceva se șterge, ajunge aici. **Nu se șterge nimic.**
Fiecare folder din carantină are un `00_INDEX.md` care spune de ce e acolo.

---

## Dosarele cu punct — limită de teren

`.obsidian` `.trash` `.vault-intelligence` `.claudian` `.neural_memory` `.sentinel_temp` `.wwebjs_cache`
și `Canvas Bases`.

Un folder cu punct aparține unui program. Dacă îl muți, programul se strică.
**Excepție dovedită:** `Tags` și `TagsRoutes` *aveau* punct și totuși nu erau ale unui program —
conțineau doar baza locală a unui program și un log gol. **Numele tehnic nu dovedește dependență.**

---

## Arborele de logică, pe un singur ecran

```
                    ÎN CE FACI LUCRU ACUM
                              ↓
                        ┌─────────────┐
                        │  10_Work    │  ← singurul nivel de lucru
                        └─────────────┘
                              ↓
        ┌───────┬─────────┬─────┴────┬──────────┬─────────┐
     Clienti   Site    Joburi      Sisteme    Document.   Casa
        │        │        │         AI         AI        │
        ↓        ↓        ↓         ↓            ↓        ↓
   ce livrezi  singurul  flux de   OPTIMUS    ce ai tăiat  casă,
              website   aplicare   Sentinel    din web     automatezări
```

Nu ai nevoie de niciun desen. Ai nevoie să apeși `10_Work` și alegi raftul.