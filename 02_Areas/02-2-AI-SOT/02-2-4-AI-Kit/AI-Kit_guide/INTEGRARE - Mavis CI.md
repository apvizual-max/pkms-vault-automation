# INTEGRARE — Mavis Optimus CI

**De ce acest fișier e aici.** Repo-ul acesta (`pkms-vault-automation`) versionează
**motorul**. Conținutul brut al vaultului **nu** e aici și nu va fi. Motorul, în
schimb, are nevoie de o singură poartă către sistemul care îl conduce: proiectul
`MAVIS-OPTIMUS-CI`.

**Nu copiem nimic în două locuri.** Puntea, skill-urile și planul stau la
adresa de mai jos și sunt citite de acolo. Singurul lucru pe care îl ținem aici
e **suprafața de integrare**: cine răspunde de ce și în ce ordine.

---

## 1. Cine răspunde de ce

| | unde stă | răspunde de |
|---|---|---|
| conținut | `D:\Alex_Knowlege_Vault` | backup local, **nu** GitHub |
| motor | acest repo | GitHub |
| punte, skill-uri, plan | `C:\Users\apviz\.minimax-agent\projects\Mavis-Optimus-Continuous-Integration\` | proces |
| sursa Cloud | `cloud-ingest\MAVIS-CLOUD\` (clonă read-only) | citit, **nu** modificat |

---

## 2. Legea asimetrică a împingerii

| instanță | împinge pe GitHub | de ce |
|---|---|---|
| Mavis Cloud | **direct, fără R0** | container volatil, online 24/7 |
| Mavis Local | **doar cu R0 explicit** | e mașina lui Popy, cu datele lui |

**Punctul unic unde se cere acordul: împingerea.** Citirea și commitul sunt
 automate. Orice automatism care ar împinge fără acord ocolește poarta.

Puntea: `Mavis-Optimus-Continuous-Integration\scripts\mavis-sync.ps1`
`pull --ff-only` din Cloud, commit local automat, **zero** instrucțiuni de
împingere. Scriptul își verifică propriul cod la pornire și se oprește dacă
găsește un verb interzis.

---

## 3. Regulile de cotor, unde stau

| | |
|---|---|
| ce **e** sistemul | `COTOR.md` (rădăcină) |
| cum **se caută** în el | `MANUAL DE NAVIGARE - cotor.md` (rădăcină) |
| contractul unui index | `COTOR.md` §16, verificat de `AI-Kit\verifica-schema.ps1` |
| măsurătorile | `AI-Kit\health-check.ps1` |

**Regulă:** cifrele din documente sunt **vii**. Nu se copiază într-un raport ca
număr fix — se spune data și se spune cum se re-verifică.

---

## 4. Ce nu intră niciodată în istoricul acestui repo

| | măsurat |
|---|---|
| date, documente, imagini, dosare de clienți, CV-uri | 52.949 fișiere / 59,82 GB |
| cotorul generat (`00_INDEX.md`) | 4.682 fișiere — derivat, se regenerează |
| bibliotecile vendor din `Skills_Archive` | 9.740 fișiere |
| secrete | `_ARCHIVE\Secrets`, `credentials.json`, chei |

Ce rămâne sub urmărire: **41–42 de fișiere**, toate motorul.

**ATENȚIE:** `git clean -fdx` și `git reset --hard` sunt interzise aici. `.git`
e **în interiorul** vaultului — un clean șterge conținutul vaultului, nu doar
fișierele neversionate. Incident produs și măsurat pe 2026-10-12.

---

## 5. Ordinea canonică — nu se schimbă

```
paths → setup → lint → health-check → reconcile
```

`build-index` și `align-index` **nu intră în lanț**: amândoi scriu în vault.
Se rulează cu mâna, sau prin automatul dedicat, la cerere.

`lint.ps1` e poarta: dacă nu dă `0`, nu începi.