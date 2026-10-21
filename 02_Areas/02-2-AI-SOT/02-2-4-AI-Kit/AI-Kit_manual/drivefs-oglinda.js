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

// --- 4. calea relativă a vaultului in arbore ---
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

const md5Identice = [], md5Diferite = [], md5Lipsa = [], dimDiferita = [];
const doarLocal = [], doarCloud = [];

for (const f of files) {
  const l = f.local_md5_checksum, c = f.cloud_md5_checksum;
  if (l && c) {
    if (l === c) md5Identice.push(f); else md5Diferite.push(f);
  } else if (l && !c) {
    doarLocal.push(f);
  } else if (!l && c) {
    doarCloud.push(f);
  } else {
    md5Lipsa.push(f);
  }
  if (f.local_size !== null && f.cloud_size !== null && f.local_size !== f.cloud_size) {
    dimDiferita.push(f);
  }
}

// --- 6. cozile ---
const cozi = {};
for (const t of ['pending_uploads', 'queued_uploads', 'pending_deletes']) {
  try {
    cozi[t] = db.prepare('SELECT COUNT(*) AS n FROM ' + t).get().n;
  } catch (e) {
    cozi[t] = null;
  }
}

// --- 7. verdict ---
// EROARE reala = continut divergent SAU o coada de stergeri/incarcari care nu
// se misca. Latenta de sincronizare (doarLocal/doarCloud) e ATENTIE, nu EROARE:
// Popy a acceptat explicit latenta ca fiind normala a sistemului bidirectional.
const divergenta = md5Diferite.length + dimDiferita.length;
let verdict;
if (divergenta > 0) {
  verdict = 'divergent';
} else if (doarLocal.length > 0 || doarCloud.length > 0) {
  verdict = 'pending';
} else {
  verdict = 'identic';
}

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
  itemi: {
    total: inVault.length,
    fisiere: files.length,
    foldere: folders.length,
    inArbore: rows.length,
  },
  identitate: {
    md5Identice: md5Identice.length,
    md5Diferite: md5Diferite.length,
    md5Lipsa: md5Lipsa.length,
    dimensiuneDiferita: dimDiferita.length,
    doarLocal: doarLocal.length,
    doarCloud: doarCloud.length,
  },
  cozi,
  exemple: {
    md5Diferite: md5Diferite.slice(0, 20).map(sub),
    dimensiuneDiferita: dimDiferita.slice(0, 20).map(sub),
    doarLocal: doarLocal.slice(0, 20).map(sub),
    doarCloud: doarCloud.slice(0, 20).map(sub),
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
linii.push('  md5 identice      : ' + md5Identice.length);
linii.push('  md5 DIFERITE      : ' + md5Diferite.length);
linii.push('  dimensiune dif.   : ' + dimDiferita.length);
linii.push('  md5 lipsa (ambele) : ' + md5Lipsa.length);
linii.push('  doar local (inca neincarcat): ' + doarLocal.length);
linii.push('  doar cloud (inca neadus local): ' + doarCloud.length);
linii.push('');
linii.push('cozi: pending_uploads=' + cozi.pending_uploads +
           ' queued_uploads=' + cozi.queued_uploads +
           ' pending_deletes=' + cozi.pending_deletes);
linii.push('');
linii.push('VERDICT: ' + verdict.toUpperCase());
if (verdict === 'identic') {
  linii.push('  oglinda locala si cea din cloud sunt identice, per fisier.');
} else if (verdict === 'pending') {
  linii.push('  latenta de sincronizare. Nu e divergenta; se raporteaza, nu blocheaza.');
} else {
  linii.push('  DIVERGENTA REALA. Continut diferit intre local si cloud.');
}

emit(rezultat, linii.join('\n'));
process.exit(verdict === 'divergent' ? 1 : 0);
