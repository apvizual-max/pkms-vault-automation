# PROCESE — de la captură la utilizare

Arborele de proces. **Fiecare lanț de mai jos e un proces complet, cu pașii lui și cu regula lui de verificare.**

---

## PROCESUL 1 — Captură

Când vezi sau primești ceva care merită păstrat.

```
ziplic pe WhatsApp ─┐
notă în telefon ────┤
articol de pe web ──┼──►  00_Inbox\00.X  ──►  TU DECIZI
clip de pe Gmail ───┤                                    │
dintr-un NotebookLM ┘                                    │
                                                          ↓
                                    mută în raftul potrivit din 01_Projects\01-6-Work_Folder (to sort)
                                       Clienti · Joburi · Site · Casa
                                                          ↓
                                          lucrezi ──► termină ──► COBÓRÂ îNAPOI în bază
```

**Regulă:** nimic nu sare peste `00_Inbox`. Cele 5 rafturi sunt goale acum — **e corect, nu e golătură.**

**Verificare:** `00_Inbox` gol = ai procesat tot ce a venit.

---

## PROCESUL 2 — Job

Singurul proces cu automatizare în vault.

```
firmă țintă
    ↓
CV AUTOMATION PROCESS
    ↓
BACH_1_LinkedIn_RAW-JD_s     ← descrierile de job luate de pe LinkedIn (94)
    ↓
BACH_1_LinkedIn_Delivrables\  ← câte un folder pe firmă: CV + scrisoare + PDF
    ↓
APPLIED\                      ← cele trimise efectiv
```

**Aici s-a curățat:**
- 92 de descrieri de job identice cu cele din mașină → `_QUARANTINE`
- 12 fișiere `TEMP_STYLING_` lăsate de automatizare → `_QUARANTINE`
- 4 fișiere dintr-o primă rundă pe jobul INFUSE → `_QUARANTINE`

**Regulă:** un `TEMP_STYLING_X` se mută în carantină **numai după ce ai verificat că `X` există lângă el.**
Nu se presupune. Se verifică fișier cu fișier.

---

## PROCESUL 3 — Client

```
brief sau comandă
    ↓
02_Areas\...\AP-ID - Clients\   (baza)
    ↓  urcă în Work când devine activ
01_Projects\01-6-Work_Folder (to sort)\01-6-2-Clienti\
    ├── Knights Tempar\  → Ordinul Sfantului Bernard (284 fiș)
    │                   → Ordinul Dragonilor – Juramant Cavaler (104 fiș)
    └── raft retras\    → clienți, brief-uri, artwork (client închis)
```

**Regulă:** proiectul **urcă** în `01_Projects\01-6-Work_Folder (to sort)` când începe, **coboară** în bază când se închide.
`Clienti` nu e arhivă. Dacă plănești să nu-l vezi 2 ani, coboară-l.

---

## PROCESUL 4 — Website

```
fișier de editat (salient-child)  ──►  01_Projects\01-6-Work_Folder (to sort)\01-6-8-Site\01_Theme_Salient\
media încărcate în WordPress     ──►  01_Projects\01-6-Work_Folder (to sort)\01-6-8-Site\02_Media_Uploads\ (27.689)
```

Era împărțit în trei locuri înainte. Acum e într-un singur raft.

**Regulă:** **niciun nume nu se atinge.** 27.689 de imagini din 2010, cu structura de foldere
`YYYY\MM` pe care a creat-o WordPress. Folderele goale de lună **se păstrează** — WordPress creează
luna la upload, deci un gol e o lună în care nu ai uploadat, nu gunoi.

---

## PROCESUL 5 — Cunoaștere personală

```
16Personalities (descărcat)  ──►  03_Resources\03_3-ALEX_Research\16 Personalities - imagi descarcate
ce ai citit                   ──►  03_Resources\03_3-ALEX_Research\
ce te-a impresionat           ──►  03_Resources\03_5-ALEX_Inspirations\
dintr-un NotebookLM           ──►  00_Inbox\00.5_NotebookLM\
```

**Regulă:** descărcat ≠ ținta ta. Materia descărcată stă în `03_Resources`,
**nu se amestecă cu ce ți-ai construit tu.** Aici s-au separat: 632 de imagini descărcate
de la 16personalities au fost mutate în `03_Resources`, iar folderul MBTI a rămas cu 19 fișiere — ale tale.

---

## PROCESUL 6 — Curățenie și carantină

```
ceva neclar, duplicat sau reziduu
    ↓
_VERIFICARE (obligatorie)     ← pasul care se sărea mereu
    ↓
_QUARANTINE\  +  un 00_INDEX.md care spune DE CE
    ↓
ALEX decide: înapoi / rămâne / se poate șterge
```

**Regula #1 a procesului:** înainte să pui ceva în carantină, verifici fiecare fișier.

Aproape am aruncat `05_1-Images\Screenshots\Video Screen Shots` ca fiind duplicat.
Verificarea a arătat că **6 din cele 12 capturi existau doar acolo.** Le-am păstrat.

**Regula #2:** o copie identică nu e automat gunoi. 5.164 de fișiere identice sunt biblioteci
de programe salvate la trei date. 1.110 sunt imagini încărcate de două ori pe site.
**Copie de rezervă ≠ mizerie.**

---

## PROCESUL 7 — Reorganizare

```
1. MĂSOARĂ totul (nu eșantiona)
2. Scrie lista în widget          ← fără asta, nu știi ce faci
3. Bifează, mută, bifează
4. Măsoară din nou
5. Compară cu backup-ul: 0 lipsă
6. Notează tot ce a fost mutat într-un CSV cu adresa veche
```

**Regula:** măsurătoarea e o condiție, nu un rezultat. Dacă după măsurare vaultul arată la fel,
măsurătoarea a fost un tur pierdut.

---

## PROCESUL 8 — Predare la alt AI

```
un AI nou, fără memorie
    ↓
citește  COTOR.md
    ↓
citește  AI-Kit_manual\ONBOARDING.md
    ↓
rulează  AI-Kit_manual\setup.ps1
    ↓
audea  libere? ── nu ──► cere numai informații de fapt
       │ da
       ↓
primește PLAN scris în widget
    ↓
execută, bifează, execută
```

**Regulă:** un AI fără memorie nu poate primi un plan în conversație.
Planul trebuie **scris undeva unde se citește înapoi** — widget, sau `AI-Kit_manual\PLAN.md`.

Aceasta e cauza pentru care cinci runde anterioare s-au pierdut: planul exista doar în conversație.