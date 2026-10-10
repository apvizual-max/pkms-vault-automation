# SKILL: git-install

**Cum se pune pe picioare Git + GitHub, de la zero, o singură dată.**

| | |
|---|---|
| **Perechea** | skill: `git-install` · prompt: `PROMPT git install.md` |
| **Se încarcă** | la proiect nou, sau proiect fără `.git`, sau fără remote pe GitHub |
| **Rulează** | o singură dată, la ridicare — **nu** la fiecare ședință |
| **Nu e** | funcționarea de zi cu zi — aceea e skillul `git-autonom` |
| **Copie vie** | `C:\Users\apviz\.minimax\agents\mavis\skills\mavis-git-install-skill\SKILL.md` |

---

## Cum aleg între cele două skilluri

| Situația | Skill |
|---|---|
| proiectul n-are încă `.git` | **`git-install`** — îl ridici |
| proiectul are deja istoric | **`git-autonom`** — îl folosești |

Nu se rulează amândouă. `git-install` e o dată, `git-autonom` e restul vieții
proiectului.

## Ordinea nu se negociază

1. **Măsoară înainte să schimbi ceva.** `git --version`, `gh --version`,
   `gh auth status`, `git config --global user.name` / `user.email`,
   `rev-parse --is-inside-work-tree`, `remote -v`. Raportează ce ai găsit.
   Nu instala nimic din inițiativa proprie — deosebește „lipsește" de
   „nu am voie".

2. **Identitatea NU se schimbă.** Dacă există global, se lasă cum e. E a
   mașinii, nu a proiectului. Nu ceri altă identitate: o citești, o folosești,
   o raportezi.

3. **Inițializează și configurează pe nivel de REPO**, nu global:

```
git init
git config core.autocrlf false
git config core.eol native
git config core.filemode false
```

`autocrlf false` e per-repo pentru că e decizie a proiectului. Global ar
forța toate proiectele de pe mașină, inclusiv ale altcuia.

4. **`.gitignore` prin NEGARE, nu enumerare.** Interzici totul cu `/*`, apoi
   deschizi explicit căile pe care proiectul le are nevoie. La un proiect
   mare, pericolul nu e să uiți un fișier — e să verși conținut în afară.

5. **Repo privat pe GitHub:**

```
gh auth login                       (doar dacă nu ești deja autentificat)
gh repo create <nume> --private --source=. --remote=origin
git add -A
git commit -m "prima stare a proiectului"
git push -u origin master
```

6. **Verifică cu `git ls-remote origin master`.** Nu cu codul de ieșire:
   `git` scrie progresul pe stderr și poate arunca o eroare roșie chiar când a
   mers bine.

7. **Predă către `git-autonom`.** Ridicarea e gata; de acum înainte regulile
   de fiecare zi sunt cele din skillul `git-autonom`.

## Regula `.gitignore` care costă cel mai mult — măsurată, nu auzită

Pe 2026-10-10, în acest vault, prima excepție scrisă corect **nu a funcționat**.
Două comituri consecutive au raportat doar logul, fără niciun avertisment.
Cauza, găsită prin măsură cu `git check-ignore -v`:

- Git nu coboară într-un director interzis. Ca să redeschizi un fișier,
  redeschide și **părintele** lui.
- `**` se potrivește și cu **zero componente**: `/_x/**` închide și directorul
  `_x` însuși, nu doar conținutul lui.
- Ultima regulă care se potrivește câștigă. Redeschiderile puse **înaintea**
  regulii de excludere sunt anulate de aceasta.

Ordinea corectă, pe fiecare nivel:

```
/_x/**
!/_x/
!/_x/sub/
!/_x/sub/**
```

Verifică după ce ai scris, cu `git check-ignore -v`: pe un fișier care trebuie
urmărit, răspunsul corect e că **NU** e ignorat. Pe unul care nu trebuie,
trebuie să rămână ignorat. Fără controlul pe partea a doua, poarta nu poate
deveni roșie.

## Prohibit, fără excepție

`git clean -fdx` · `git reset --hard` · `force push` fără cerere · secrete în
fișiere urmărite · ștergerea conținutului utilizatorului (muți, cu motiv
scris, în carantină).

## Regula de comportament, de la prima zi

**Commit autonom la fiecare succes măsurat. Push doar cu acordul lui.
Interfața aplicației nu se atinge** — rezolvarea e comportament, nu buton.
Acestea nu se negociază nici la instalare: se pun în vigoare din comitul 1.

## Măsurat pe această mașină (2026-10-10)

git `2.56.0.windows.2` · `gh 2.97.0`, instalat și autentificat ·
`credential.https://github.com.helper=store` · identitate și `core.hooksPath`
la nivel global. **`gh` e deja prezent și logat** — o instanță nouă nu e
blocată pe autentificare.

## Promptul pereche

`PROMPT git install.md`, în același folder — se trimite ca atare într-o
sesiune nouă. Rulează **o singură dată**; retrimiterea lui face un al doilea
repo pe același proiect.