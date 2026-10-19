---
name: pkms-vault-index
description: >
  Indexarea și alinierea automată a vaultului PKMS — contractul `00_INDEX.md`, cele cinci
  stări (LIPSA / CORUPT / INCOMPLET / NEALINIAT / CONFORM), cine deține fiecare piesă,
  regula „jurnalele vii nu sunt conținut", contractul de convergență dintre cele două
  generatoare (build-index ↔ align-index), blocurile „De ce e aici" și „Cuvinte cheie",
 zonele interzise, logul `raport-aliniere.log`, cele două automate și comutatoarele
  lor. Se declanșează la orice întrebare despre `00_INDEX.md`, `build-index.ps1`,
  `align-index.ps1`, `watch.ps1`, `verifica-schema.ps1`, despre cifrele din indexuri sau
  despre faptul că un folder rămâne „nealiniat".
license: Proprietar — Popy / OPTIMUS PRIME
---

# PKMS — Indexarea și alinierea

> **Indexul nu e conținut.** E harta. Se rescrie, se măsoară, se verifică. Nu se citeste
> ca autoritate — autoritatea e conținutul de pe disc.

## 1. Contractul de navigare

Fiecare folder de conținut are **exact un** `00_INDEX.md`, generat. Structura:

```
# 00_INDEX — <calea relativă>
**N fișiere · X KB · Y subfoldere**
> Generat automat de AI-Kit\build-index.ps1. Nu edita manual — rulează scriptul din nou.
> Randul **De ce e aici** de mai sus, daca exista, se pastreaza la fiecare regenerare.
## Ce e aici          ← BLOC DERIVAT (propozitie + extensii)
## Cuvinte cheie      ← BLOC DERIVAT (identitatea folderului)
## Fișiere            ← BLOC DERIVAT (tabel)
```

**Rândul `**De ce e aici:**`** e singurul rând scris de om. Generatorul îl păstrează
la fiecare regenerare. E acolo ca un AI fără memorie să știe *de ce* există folderul, nu
doar *ce* e în el. **Nu se rescrie niciodată automat.**

**Blocurile derivate** sunt singurele pe care automatul le poate suprascrie. Tot ce e
în afara lor, într-un `00_INDEX.md`, e reziduu — și reziduul e defect.

## 2. Cele cinci stări

| Stare | Ce înseamnă | Cine repară |
|---|---|---|
| **LIPSA** | folderul nu are `00_INDEX.md` | `align-index` îl creează |
| **CORUPT** | indexul există dar nu e parsabil (blocuri lipsă, tabel rupt) | `align-index` îl reface de la zero |
| **INCOMPLET** | indexul există dar îi lipsește un bloc obligatoriu | `align-index` completează blocul, **păstrând motivul** |
| **NEALINIAT** | indexul există, e complet, dar cifrele nu mai corespund conținutului | `align-index` rescrie **doar blocurile derivate** |
| **CONFORM** | indexul corespunde conținutului | nimeni — nu se atinge |

**CONFORM nu înseamnă „corect" în sens absolut.** Înseamnă „concordant cu măsurătoarea
de azi". Dacă măsurătoarea e greșită, indexul e greșit în mod consistent — și de aceea
e atât de important ca măsurătoarea să fie măsurată la nivel de octet, nu estimată.

## 3. Cine deține ce

| Piesă | Proprietar | Ce poate rescrie |
|---|---|---|
| `00_INDEX.md` (blocuri derivate) | `build-index.ps1` / `align-index.ps1` | automatul, integral |
| rândul `**De ce e aici:**` | omul | **numai omul** — automatul îl păstrează |
| `INDEX CENTRAL.md` | `build-index.ps1` | generatorul, integral; nu se patch-ează |
| logul `raport-aliniere.log` | `align-index.ps1` | append-only |
| `.gitignore` | omul, cu motive scrise | omul |

**`align-index` nu creează niciodată conținut și nu atinge backupul.** Citește
conținutul, calculează cifrele, scrie blocurile derivate. Restul rămâne.

## 4. Regula „jurnalele vii nu sunt conținut" — §18.7

Cele trei jurnale ale motorului **cresc în timp ce rulează**:

| Jurnal | Unde | De ce crește |
|---|---|---|
| `raport-autocomit.log` | `AI-Kit_manual\` | `git-autocommit.ps1:133` adaugă la fiecare commit |
| `raport-aliniere.log` | `AI-Kit_guide\` | fiecare rulare de aliniere adaugă un eveniment |
| `arhiva- raport aliniere.log` | `AI-Kit_guide\` | arhiva fiecărei rulări |

**Regula (contractul §18.7):** aceste trei nume nu intră în numărătoarea de fișiere a
folderului care le conține. Lista e **într-un singur loc** — `paths.ps1` →
`Test-PkmsLiveLog` — și e aplicată identic în `build-index.ps1` (3 locuri),
`align-index.ps1` (2 locuri + `$bytes` aliniat cu `$realBytes`) și `verifica-schema.ps1`
(1 loc).

**De ce centralizat:** dacă fiecare generator ar exclude singur, unul din ele ar scrie
indexuri pe care celălalt le-ar rescrie la nesfârșit. O listă într-un singur loc e
singura formă în care contractul și codul nu se pot despărți.

**Ce NU se exclude:** `raport-ultima-rulare.txt` și arhivele `raport-*.txt` din
`_SYSTEM\rapoarte`. Excluderea lor ar face folderul „gol" la §18.5 — o minciună în
cifre. Și taskul lor era mort, deci n-ar fi observat.

## 5. Contractul de convergență (§18.9)

Cele două generatoare trebuie să producă **același text** pentru același folder. Altfel
ciclul se reînnoiește la nesfârșit.

| | `build-index.ps1` | `align-index.ps1` |
|---|---|---|
| **Scope** | tot arborele, obligatoriu | poate fi scoped (`-DoarCargol`) |
| **Ce scrie** | tot ce găsește | **doar blocurile derivate** ale celor NEALINIAT |
| **Când** | rearanjare, schimbare de cifre | mentenanță de zi cu zi |
| **INDEX CENTRAL.md** | îl rescrie | nu |
| **Logul** | nu atinge `raport-aliniere.log` | îl scrie |

**Proba de echivalență (măsurată 19.10.2026):** 2.511 foldere ale căror indexuri
fuseseră scrise de `build-index` la 11:29 au fost găsite **CONFORM** de `align-index` la
22:37 — deci textul produs de cele două e identic. Plus: `align-index` **păstrează
capul cu atribuirea** („Generat automat de `AI-Kit\build-index.ps1`"), deci rularea
`build-index` nu produce ping-pong.

**Asimetria măsurată, încă nepatchată:** `align-index` scrie cu **un newline final în
plus** (`Set-Content` adaugă peste EOL deja prezent, la L853) și **nu recunoaște
blocurile derivate vechi** — a lăsat un rând stale cu „18 fișiere" în `AI-Kit_manual`,
unde corect era 17. `build-index` normalizează ambele. Convergența **contractuală** e
intactă (censusul dă 0 NEALINIAT), dar rămâne zgomot de git la rescrierile viitoare.
**Nu s-a patchat**, pentru că `PKMS-Aliniere` rulează zilnic la 06:00: orice schimbare
a căii de scriere cere probă izolată și ciclu de verificare propriu.

## 6. Reparația se face din datele lui

Nu inventa. La o stare NEALINIAT:

1. citește conținutul real al folderului (număr, octeți, extensii, cele mai mari
   elemente) — **de pe disc, nu din index**;
2. recalculează cifrele cu **aceeași** măsurătoare pe care o folosește `build-index`
   (de aceea `$bytes` din `align-index` a fost aliniat cu `$realBytes`);
3. scrie **doar blocurile derivate**;
4. **păstrează** rândul `**De ce e aici:**` — dacă nu e clar al cui rând e, nu scrie
   nimic (`$refuz`).

## 7. Indexul unui folder gol

Un folder gol primește index oricum, cu marcatul „gol" (§18.5) — **altfel ar fi
invizibil** și un AI fără memorie nu ar ști că există. Nu se inventează conținut pentru
a-l umple. Măsurătoarea rămâne corectă: 0 fișiere, 0 octeți.

## 8. Ce nu intră niciodată sub automat

- `00_INDEX.md` în **backup** — backupul nu e al automatului.
- Fișierele din `_QUARANTINE` — nu se ating; `retirat-2026-10-10` e raft retras, cu
  motiv scris.
- Secretele: `*.pem`, `*.key`, `id_rsa*`, `**/credentials.json`, `**/client_secret*.json`.
  Un secret intrat în istoric nu se mai scoate curat.
- Zonele interzise: `.obsidian`, `.git`, `.trash`, `.vault-intelligence`, `.claudian`,
  `.neural_memory`, `.sentinel_temp`, `.wwebjs_cache`, `node_modules`.
- **Rădăcina unei zone interzise se indexează, interiorul nu.** Altfel un AI ar crede
  că `.obsidian` e conținut de proiect.

**Tipare, nu scriere cu `\`:** pentru o cale, `([\\/]|$)` — bara finală obligatorie.
Doar `\\.git\\` se potrivește în interiorul unei căi, nu la capătul ei; de aceea `.git`
de la rădăcină rămânea neprotejat. Iar `[\\/]` înseamnă „o bară înclinată, în orice
sens" — nu scrie `\` ca `\\` într-un regex PowerShell.

## 9. Logul: `raport-aliniere.log`

Append-only. Fiecare rulare adaugă un eveniment: câte foldere au fost verificate, câte
rescrise, ce s-a refuzat și de ce. **Nu se rescrie niciodată.**

Logul e în `AI-Kit_guide\`, iar **folderul care îl conține nu poate fi indexat cu
fișierele lui** — de aceea e în lista din §4. Logul e stare, nu conținut.

`inchide-log.ps1` îl arhivează (mută, nu șterge) în `_SYSTEM\arhiva-indexe\`.

## 10. Comutatoarele văzute în cod

| Script | Comutator | Ce face |
|---|---|---|
| `align-index.ps1` | `-CeVad` | **nu scrie nimic**; doar raportează. Singurul mod sigur de diagnostic |
| `align-index.ps1` | `-DoarCargol '<subarbore>'` | scope la un subarbore; singurul mod sigur de rearanjare |
| `build-index.ps1` | `-Quiet` | nu afișează summary-ul; **nu** schimbă ce scrie |
| `build-index.ps1` | — | nu poate fi scoped. Rulează pe tot arborele |

## 11. Cum se opreste

**Censusul nu se oprește la primul NEALINIAT.** Citește tot arborele, raportează tot.
Un raport trunchiat e un raport fără verdict.

Verdictul se citește în ultima linie:

```
rezumat: 0 LIPSA · 0 CORUPT · 0 INCOMPLET · 0 NEALINIAT · 2516 CONFORM · 2516 nemodificate
evenimente de log: 0 (CeVad: logul NU s-a atins)
duble cai prin puncte de legatura: 0
foldere cu mai putin de 2 cuvinte cheie, raportate §16: 0
```

**Cifrele se măsoară în sesiunea raportului.** O cifră din ieri, într-un raport de azi,
e `NOT_MEASURED`.

## 12. Cifrele de referință (19.10.2026, măsurate)

| | |
|---|---|
| foldere indexate | **2.516**, toate CONFORM |
| `INDEX CENTRAL.md` | 962.335 B · „Actualizat: 2026-10-19 22:32" · 16.125 fișiere · 83,70 GB indexate |
| vault total (health-check) | 50.728 fișiere · 85,75 GB · stabilitate 50.728/50.728, diferența 0 |
| scripturi | 11, toate parse 0 erori, encoding 11/11 |
| `build-index` | EXIT=0 în 331 s · 58 indexuri rescrise |
| `align-index` (scriere) | 5 NEALINIAT reparate · 2.511 CONFORM · 177 s |

**Cele două cifre mari nu se contrazic:** `INDEX CENTRAL.md` măsoară **substratul
indexat** (fără zonele excluse), `health-check` măsoară **tot vaultul**. Scope diferit,
nu eroare.
