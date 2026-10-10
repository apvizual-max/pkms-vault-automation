# PROMPT DE INSTALARE — punerea pe picioare a infrastructurii Git + GitHub

Trimite-l **ca atare** unei instanțe noi, într-un proiect nou, unde nu s-a
atins niciodată Git și unde ea **nu știe nimic** despre GitHub.

**Diferența față de `PROMPT-UNIVERSAL.md`:** acela spune *ce faci cu* Git.
Ăsta spune *cum îl instalez*. Rulează **o dată**, la început. După aceea,
vreau ca `PROMPT-UNIVERSAL.md` să fie cel care merge.

---

```
SETUP GIT + GITHUB, de la zero. Nu știi nimic despre Git. Proiectul are nevoie
de versionare și de o copie pe GitHub. Instalează tot ce trebuie, pas cu pas,
și verifică tot ce ai făcut. Nu presupune nimic — măsoară înainte.

=== REGULA DE BAZĂ, valabilă peste tot ===

COMMIT = treaba ta, automată, la fiecare pas.
PUSH = decizia mea, niciodată din inițiativa ta.

1. MĂSOARĂ ÎNTÂI, NU PRESUPUNE.
   Rulează și raportează-mă, înainte să schimbi ceva:
   - git --version                (dacă lipsește: spune-mi, NU instala tu)
   - gh --version                 (GitHub CLI)
   - gh auth status               (ești autentificat?)
   - git -C <proiect> rev-parse --is-inside-work-tree
   - git -C <proiect> remote -v
   Spune-mi ce ai găsit, înainte de pasul 2.

2. IDENTITATEA — o singură dată, la nivel global.
   Dacă user.name / user.email nu sunt setate, pune-le. Întreabă-mă pentru
   nume și adresă, sau folosește ce am dat. Nu inventa identitatea mea.

3. PROIECTUL — configurează-l de la zero:
   git init
   git config core.autocrlf false      ← IMPORTANT, vezi secțiunea 6
   git config core.eol native
   git config core.filemode false

4. .gitignore — MODUL GREȘIT E CEL MAI FRECVENT.
   NU folosi .gitignore obișnuit, cu liste de ce nu se urmărește. La un
   proiect mare, pericolul nu e să uiți un fișier, ci să verși conținut
   în afară: parole, fișiere personale, zeci de GB.
   Folosește inversul: interzici TOTUL, apoi deschizi doar căile enumerate.

   /*                        ← tot ce e la rădăcină: interzis
   !/README.md               ← apoi deschizi explicit, pe rând
   !/src/
   !/src/**

   Reguli care contează:
   - Ordinea contează: ultima regulă care se potrivește câștigă.
   - Git NU coboară într-un director interzis. Ca să redeschizi un
     fișier, redeschide și PĂRINTELE lui, chiar dacă pe acesta cazi
     înapoi imediat.
   - `**` se potrivește și cu ZERO componente: `/_x/**` închide și
     directorul `_x` însuși.
   Verifică după ce ai scris: `git check-ignore -v <fișier>`.
   Pentru un fișier care TREBUIE urmărit, răspunsul corect e că NU e ignorat.
   Pentru unul care nu trebuie, trebuie să rămână ignorat.

5. PRIMUL COMIT ȘI PRIMUL PUSH.
   gh auth login                    (doar dacă nu ești deja autentificat)
   gh repo create <nume> --private --source=. --remote=origin
   git add -A ; git commit -m "prima stare a proiectului"
   git push -u origin master

6. LINII CRUCIALE — NU LE SARI.
   - `core.autocrlf false` pe Windows: altfel fiecare fișier apare modificat
     la fiecare clone, fără ca cineva să fi atins ceva. E cauza #1 de
     „proiectul e stricat" pe Windows.
   - NICIODATĂ `git clean -fdx`. Într-un proiect mare, șterge fișiere
     ignorate care pot fi conținut real.
   - NICIODATĂ `git reset --hard`. Distruge munca necomitată.
   - Fără `force push` fără cerere explicită.
   - Nu pune parole, tokenuri sau chei în fișiere urmărite. Dacă apare unul
     într-un fișier urmărit, spune-mi IMEDIAT, nu îl comite.

7. VERIFICĂ, NU ANUNȚA.
   După push: `git ls-remote origin master`. ASTA e adevărul.
   Nu încălzi cu codul de ieșire al shell-ului: `git` scrie progresul pe
   stderr și poate arunca o eroare roșie chiar când totul a mers bine.

8. DE CE INSTANTEZI TU, NU EU.
   Nu e o treabă de citit documentație. E o treabă de măsurat și de construit.
   Dacă nu ai drept de scriere unde trebuie, spune-mi clar de ce.

La final spune-mi, pe scurt:
- ce a existat și ce ai creat
- comitul și repo-ul, cu adresa
- ce verificări ai făcut și ce au răspuns
- ce n-ai putut face și de ce
```

---

## Varianta scurtă, pentru un AI cu context mare

```
Măsoară: git --version, gh --version, gh auth status, remote -v. Configurează
proiectul: init, core.autocrlf false, core.eol native. Scrie .gitignore prin
NEGARE (interzici totul cu /*, deschizi explicit căile pe care le vrei).
gh repo create --private, primul comit, push. Verifică push-ul cu git ls-remote,
nu cu ieșirea shell-ului. Nu rula niciodată git clean -fdx sau git reset --hard.
Nu comite parole sau tokenuri. Commit autonom la fiecare pas, push doar când
eu spun. Interfața nu o schimbi.
```

## Ce am măsurat pe această mașină, ca să fie verificabil

Nu e teorie — e starea reală de la care pornește orice proiect nou:

| Ce | Valoare măsurată |
|---|---|
| Git | `2.56.0.windows.2` |
| GitHub CLI | `gh 2.97.0 (2026-07-31)` — **instalat** |
| Autentificare | `hosts.yml` există → logat |
| `core.autocrlf` | `false` — **pe nivel de repo, nu global** |
| `core.eol` | `native` |
| `core.filemode` | `false` |
| `core.hooksPath` | `C:\Users\apviz\.git-hooks` (global) |
| Identitate | `Sentinel Prime <sentinel.prime@optimus.local>` (global) |
| Credential | `credential.https://github.com.helper = store` |
| Remote | HTTPS, `apvizual-max/pkms-vault-automation.git` |

**De ce `autocrlf=false` e pe nivel de repo:** e o decizie a proiectului, nu a
mașinii. Două proiecte pe același calculator pot avea reguli diferite pe rânduri
de text. Setată global, ar forța toate proiectele în același mod — inclusiv
proiectele altcuiva.

## Ce știu deja și nu trebuie repetat

- Regula `**` cu zero componente — **măsurată aici**, a costat două comituri
  care raportau doar logul, fără niciun avertisment.
- Interfața aplicației nu se atinge. Rezolvarea e comportament, nu buton.
- `git ls-remote` e singurul verdict de push.
- `chore: update <fișier>` vine din mesajul lăsat gol — nu e un intrus.

## După instalare

Instalația se termină aici. De acum înainte, ce rulează la fiecare ședință e
`PROMPT-UNIVERSAL.md` — commit autonom, push doar cu acordul meu, interfața
neatină. Nu retrimite promptul acesta: rulat de două ori, înființează un al
doilea repo pe același proiect.