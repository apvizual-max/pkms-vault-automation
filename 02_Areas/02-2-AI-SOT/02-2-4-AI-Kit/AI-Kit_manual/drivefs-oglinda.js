// PKMS drivefs-oglinda.js
// Cititor READ-ONLY al oglinzii Google Drive + motor de identitate local<->cloud.
//
// Decizia 1 (Popy, 2026-10-21): reperul de backup nu mai e o copie locala pe
// D:/H:. Reperul e oglinda Google Drive Cloud. Oglinda se verifica prin
// starea per-fisier local<->cloud, luata din baza de metadate a DriveFS.
//
// REGULA CARE CONVERGE:
//   o masuratoare care nu a masurat NU e o masuratoare de zero.
//   Daca baza nu s-a deschis, sau daca arborele nu contine vaultul, rezultatul
//   e "nemapaturat" si cod de iesire 2. NICIODATA "0 divergente" pentru un
//   arbore gol sau pentru o baza care nu s-a citit.
//
// REGULA CARE SEPARA LATENTA DE DIVERGENTA (masurata, nu ghicita):
//   "md5 diferit" NU e divergenta. Experiment controlat 2026-10-21 (fisier
//   creat si modificat in afara vaultului, urmarit in DB la fiecare 2.5s):
//     - fisier MODIFICAT local, inainte de incarcare: md5 diferit, dimensiune
//       diferita, local_size = -1, local_mtime > cloud_mtime, si fisierul in
//       queued_uploads. Se rezolva singur in ~5s.
//     - fisier NOU creat: cloud_md5 gol, cloud_version = -1, queued_uploads = 1.
//   Deci divergenta REALA e doar: md5 diferit, NU in coada, mtime-uri egale,
//   si veche de peste 48h (pragul de escaladare al sistemului).
//   Popy a acceptat explicit latenta ca fiind normala a sistemului bidirectional.
//
// Iesire: JSON pe stdout cu --json, altfel text lizibil pentru om.
// Cod de iesire: 0 = oglinda identica (sau doar latenta), 1 = divergenta reala,
//                 2 = nu s-a putut masura.

'use strict';

const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');

const args = process.argv.slice(2);
const getArg = (name) => {
  const i = args.indexOf(name);
  return (i >= 0 && i + 1 < args.length) ? args[i + 1] : null;
};
const hasFlag = (name) => args.includes(name);

const JSON_OUT = hasFlag('--json');
const VAULT_ABS = getArg('--vault');
const MOUNT_ABS = getArg('--mount');
const VAULT_REL_OVERRIDE = getArg('--vault-rel');
const DB_OVERRIDE = getArg('--db');
const PRAG_ESCALADARE_H = 48;   // acelasi prag pe care il foloseste si Test-Activ din reconcile

function emit(obj, text) {
  if (JSON_OUT) {
    process.stdout.write(JSON.stringify(obj, null, 2) + '\n');
  } else {
    process.stdout.write(text + '\n');
  }
}

function fail(reason, extra) {
  const obj = Object.assign({
    ok: false,
    verdict: 'nemapaturat',
    motiv: reason,
    masuratLa: new Date().toISOString(),
  }, extra || {});
  emit(obj,
    'VERDICT: NEMAPATURAT\n' +
    'Motiv: ' + reason + '\n' +
    'Masurat la: ' + obj.masuratLa + '\n');
  process.exit(2);
}

// --- 1. descoperirea profilului DriveFS ---
function gasesteProfiluri() {
  const base = path.join(process.env.LOCALAPPDATA || path.join(os.homedir(), 'AppData', 'Local'), 'Google', 'DriveFS');
  if (!fs.existsSync(base)) return [];
  let names = [];
  try { names = fs.readdirSync(base); } catch { return []; }
  const out = [];
  for (const n of names) {
    const db = path.join(base, n, 'mirror_sqlite.db');
    if (fs.existsSync(db)) {
      let mtime = 0;
      try { mtime = fs.statSync(db).mtimeMs; } catch { /* stat poate pica */ }
      out.push({ id: n, db, mtime });
    }
  }
  out.sort((a, b) => b.mtime - a.mtime);
  return out;
}

let DatabaseSync;
try {
  ({ DatabaseSync } = require('node:sqlite'));
} catch (e) {
  fail('node:sqlite nu este disponibil in runtime-ul Node curent (' + process.version + '). ' +
       'Masuratoarea nu s-a facut. Nu pot afirma ca oglinda e identica.');
}

const profiluri = gasesteProfiluri();
if (profiluri.length === 0) {
  fail('niciun mirror_sqlite.db sub %LOCALAPPDATA%\\Google\\DriveFS\\. DriveFS nu e instalat sau profilul nu exista.');
}
let profil = profiluri[0];
if (DB_OVERRIDE) {
  const p = profiluri.find((x) => x.db === DB_OVERRIDE);
  if (!p) fail('--db nu corespunde niciunui profil DriveFS gasit: ' + DB_OVERRIDE);
  profil = p;
}

// --- 2. deschiderea READ-ONLY ---
let db;
try {
  const uri = 'file:' + profil.db.replace(/\\/g, '/') + '?mode=ro';
  db = new DatabaseSync(uri, { readOnly: true });
} catch (e) {
  fail('baza de metadate DriveFS nu s-a putut deschide in regim READ-ONLY: ' + e.message +
       ' (db: ' + profil.db + '). Nu am citit nimic, deci nu pot afirma nimic.');
}

// --- 3. arborele ---
let rootCfg;
try {
  rootCfg = db.prepare('SELECT local_stable_id, root_id, root_state FROM root_config').get();
} catch (e) {
  fail('interogarea root_config a picat: ' + e.message);
}
if (!rootCfg) fail('root_config e gol: arborele DriveFS nu are radacina. Nu am masurat nimic.');

let rootRow;
try {
  rootRow = db.prepare('SELECT local_stable_id, local_filename FROM mirror_item WHERE local_stable_id = ?')
                  .get(rootCfg.local_stable_id);
} catch (e) {
  fail('interogarea radacinii a picat: ' + e.message);
}
const rootName = (rootRow && rootRow.local_filename) ? rootRow.local_filename : '';

// --- 4. calea relativa a vaultului in arbore ---
function caleRelativa(vaultAbs, mountAbs, rootLabel) {
  if (VAULT_REL_OVERRIDE) return VAULT_REL_OVERRIDE;
  if (!vaultAbs) return null;
  let rel = null;
  if (mountAbs) {
    const m = mountAbs.replace(/[\\/]+$/, '');
    const v = vaultAbs.replace(/[\\/]+$/, '');
    if (v.toLowerCase().startsWith(m.toLowerCase() + '\\')) {
      rel = v.slice(m.length + 1);
    } else if (v.toLowerCase() === m.toLowerCase()) {
      rel = '';
    }
  }
  if (rel === null) return null;
  return rootLabel ? (rootLabel + '\\' + rel) : rel;
}

const vaultRel = caleRelativa(VAULT_ABS, MOUNT_ABS, rootName);

// --- 5. citirea arborelui ---
let rows;
try {
  rows = db.prepare(`
    WITH RECURSIVE tree(lsid, p, depth) AS (
      SELECT local_stable_id, local_filename, 0 FROM mirror_item WHERE local_stable_id = ?
      UNION ALL
      SELECT m.local_stable_id, t.p || '\\' || m.local_filename, t.depth + 1
      FROM mirror_item m JOIN tree t ON m.parent_local_stable_id = t.lsid
    )
    SELECT t.lsid, t.p AS rel, t.depth, m.local_size, m.cloud_size,
           m.local_md5_checksum, m.cloud_md5_checksum,
           m.local_mtime_ms, m.cloud_mtime_ms, m.local_type, m.cloud_type
    FROM tree t JOIN mirror_item m ON m.local_stable_id = t.lsid`).all(rootCfg.local_stable_id);
} catch (e) {
  fail('interogarea arborelui a picat: ' + e.message);
}

if (!rows || rows.length === 0) {
  fail('arborele DriveFS a venit CU 0 RANDURI. Nu am masurat nimic.');
}

let inVault;
if (vaultRel) {
  inVault = rows.filter((r) => r.rel === vaultRel || r.rel.startsWith(vaultRel + '\\'));
} else {
  inVault = [];
}

if (inVault.length === 0) {
  fail('vaultul nu apare in arborele DriveFS (caut rel="' + (vaultRel || 'n/a') + '"). ' +
       'Masuratoarea a citit ' + rows.length + ' itemi, dar niciunul al vaultului. ' +
       'Nu pot afirma ca oglinda e identica.');
}

const files = inVault.filter((r) => r.local_type === 1 || r.cloud_type === 1);
const folders = inVault.filter((r) => r.local_type === 0 && r.cloud_type === 0);

// --- 6. cozile: se citesc INAINTE de clasificare, pentru ca sunt discriminatorul ---
const cozi = {};
const inPending = new Set();
for (const t of ['pending_uploads', 'queued_uploads', 'pending_deletes']) {
  try {
    cozi[t] = db.prepare('SELECT COUNT(*) AS n FROM ' + t).get().n;
  } catch (e) {
    cozi[t] = null;
  }
}
for (const t of ['pending_uploads', 'queued_uploads']) {
  try {
    for (const r of db.prepare('SELECT local_stable_id FROM ' + t).all()) {
      if (r.local_stable_id !== null && r.local_stable_id !== undefined) inPending.add(String(r.local_stable_id));
    }
  } catch (e) { /* coada nu s-a citit: se trateaza ca vida, dar verdictul ramane masurat */ }
}

// --- 7. clasificarea: latenta SAU divergenta ---
const identice = [];
const pendingUpload = [];
const pendingDownload = [];
const neobservate = [];
const divergente = [];
const md5Lipsa = [];
const dimDiferita = [];
const acumMs = Date.now();

for (const f of files) {
  const l = f.local_md5_checksum, c = f.cloud_md5_checksum;
  const inCoada = inPending.has(String(f.lsid));
  const sizeLocalNecunoscut = (f.local_size === -1);
  const areTimpuri = (f.local_mtime_ms !== null && f.local_mtime_ms !== undefined &&
                      f.cloud_mtime_ms !== null && f.cloud_mtime_ms !== undefined);
  const localMaiNou = areTimpuri && f.local_mtime_ms > f.cloud_mtime_ms;
  const cloudMaiNou = areTimpuri && f.cloud_mtime_ms > f.local_mtime_ms;

  if (l && c && l === c) {
    identice.push(f);
  } else if (l && !c) {
    pendingUpload.push(f);          // nou local, inca neincarcat in cloud
  } else if (!l && c) {
    pendingDownload.push(f);       // in cloud, inca neadus local
  } else if (!l && !c) {
    md5Lipsa.push(f);
  } else {
    // md5 diferit: intrebarea NU e 'diferit?', ci 'e o divergenta sau o latenta?'
    const pending = inCoada || sizeLocalNecunoscut || localMaiNou || cloudMaiNou;
    if (pending) {
      if (cloudMaiNou && !localMaiNou) pendingDownload.push(f);
      else pendingUpload.push(f);
    } else {
      // nu e pending, dar n-a trecut pragul: DriveFS n-a prins inca modificarea
      const varstaH = (acumMs - Math.max(f.local_mtime_ms || 0, f.cloud_mtime_ms || 0)) / 3600000;
      if (varstaH > PRAG_ESCALADARE_H) divergente.push(f);
      else neobservate.push(f);
    }
  }
  if (f.local_size !== null && f.cloud_size !== null && f.local_size !== f.cloud_size) {
    dimDiferita.push(f);
  }
}

const latentaTotala = pendingUpload.length + pendingDownload.length + neobservate.length;

// --- 8. verdict ---
let verdict;
if (divergente.length > 0) verdict = 'divergent';
else if (latentaTotala > 0) verdict = 'pending';
else verdict = 'identic';

const sub = (f) => ({
  cale: String(f.rel).slice(vaultRel.length + 1),
  local: { octeti: f.local_size, md5: f.local_md5_checksum, mtime: f.local_mtime_ms },
  cloud: { octeti: f.cloud_size, md5: f.cloud_md5_checksum, mtime: f.cloud_mtime_ms },
});

const rezultat = {
  ok: true,
  verdict,
  masuratLa: new Date().toISOString(),
  motor: 'drivefs-oglinda.js',
  db: profil.db,
  profilDriveFs: profil.id,
  mount: MOUNT_ABS,
  vault: VAULT_ABS,
  vaultRel: vaultRel,
  radacinaArbore: rootName,
  pragEscaladareOre: PRAG_ESCALADARE_H,
  itemi: {
    total: inVault.length,
    fisiere: files.length,
    foldere: folders.length,
    inArbore: rows.length,
  },
  identitate: {
    md5Identice: identice.length,
    divergentaReala: divergente.length,
    pendingUpload: pendingUpload.length,
    pendingDownload: pendingDownload.length,
    neobservate: neobservate.length,
    md5Lipsa: md5Lipsa.length,
    dimensiuneDiferita: dimDiferita.length,
    latentaTotala: latentaTotala,
  },
  cozi,
  exemple: {
    divergente: divergente.slice(0, 20).map(sub),
    pendingUpload: pendingUpload.slice(0, 20).map(sub),
    pendingDownload: pendingDownload.slice(0, 20).map(sub),
    neobservate: neobservate.slice(0, 20).map(sub),
  },
  motiv: null,
};

try { db.close(); } catch { /* inchiderea nu trebuie sa arunce */ }

const linii = [];
linii.push('=== OGLINDA GOOGLE DRIVE - LOCAL <-> CLOUD ===');
linii.push('masurat la:  ' + rezultat.masuratLa);
linii.push('mount:       ' + (MOUNT_ABS || '(necunoscut)'));
linii.push('vault:       ' + (VAULT_ABS || '(necunoscut)'));
linii.push('baza:        ' + profil.db);
linii.push('');
linii.push('itemi in vault: ' + inVault.length + '  (fisiere ' + files.length + ', foldere ' + folders.length + ')');
linii.push('  md5 identice (oglinda identica) : ' + identice.length);
linii.push('  DIVERGENTA REALA (eroare)       : ' + divergente.length);
linii.push('  pending upload (latenza)        : ' + pendingUpload.length);
linii.push('  pending download (latenza)      : ' + pendingDownload.length);
linii.push('  neobservate de DriveFS (latenza): ' + neobservate.length);
linii.push('  md5 lipsa (ambele)              : ' + md5Lipsa.length);
linii.push('  dimensiune diferita (fapt)      : ' + dimDiferita.length);
linii.push('');
linii.push('cozi: pending_uploads=' + cozi.pending_uploads +
           ' queued_uploads=' + cozi.queued_uploads +
           ' pending_deletes=' + cozi.pending_deletes);
linii.push('');
linii.push('VERDICT: ' + verdict.toUpperCase());
if (verdict === 'identic') {
  linii.push('  oglinda locala si cea din cloud sunt identice, per fisier.');
} else if (verdict === 'pending') {
  linii.push('  latenta de sincronizare (' + latentaTotala + '). Nu e divergenta; se raporteaza, nu blocheaza.');
} else {
  linii.push('  DIVERGENTA REALA (' + divergente.length + '). Continut diferit intre local si cloud, peste pragul de ' + PRAG_ESCALADARE_H + 'h.');
}

emit(rezultat, linii.join('\n'));
process.exit(verdict === 'divergent' ? 1 : 0);
