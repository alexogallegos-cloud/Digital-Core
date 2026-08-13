"""
classify-batch.py
Clasifica todos los SPs candidatos a batch con un sub-arquetipo basado en señales
del código fuente. Escribe resultados a brain.db (tabla batch_analysis).

Sub-arquetipos:
  FILE_LOADER        — carga archivos externos al filesystem AIX
  ORCHESTRATOR       — llama a >=2 SPs distintos
  MASS_OPERATION     — FOREACH masivo sobre registros (abono, bloqueo masivo)
  ACCOUNTING_JOB     — escribe al bus contable (sx_contproc / sd_contproc)
  CIERRE_CORTE       — cierre de período sin bus contable
  REPORT_AGGREGATOR  — genera reportes / agrega bitácora sin calls externos
  PURGE_JOB          — depura / mueve a _hist
  DATA_MAINT         — actualiza/inserta tablas sin calls (con o sin loop)
  SINGLE_CALL        — delega a exactamente 1 SP
  CONCILIACION       — conciliación / reconciliación
  CURSOR_SP          — loop de lectura sin escritura (retorna conjuntos de filas vía RETURNING+FOREACH)
  QUERY_SP           — consulta puntual sin loop ni escritura (RETURNING, sin DML)
  NO_SOURCE          — no se encontró el archivo SQL
  UNKNOWN            — señales insuficientes (residual mínimo esperado)

Ejecutar desde BCOPCore/:
    python digital-brain/classify-batch.py
"""

import re, sys, os, sqlite3, time
from collections import Counter, defaultdict

sys.stdout.reconfigure(encoding='utf-8')

BASE       = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE_DIR = os.path.join(BASE, 'source', 'BCOPCore', 'informix')
DB_PATH    = os.path.join(BASE, 'digital-brain', 'brain.db')

# Alias explícitos para SPs registrados bajo nombre canónico pero cuyo archivo
# existe con variante (sufijo, namespace, DB distinta).
# Formato: (db, sp_name) → (file_db, file_sp_name) tal como aparece en file_index.
FILE_ALIASES = {
    ('bdicheq',  'cons_sdos2'):                    ('bdicheq',  'cons_sdos2_pba'),
    ('bdicnweb', 'sp_guardadireccionesctemoral'):   ('bdicnweb', 'sp_guardadireccionesctemoral2'),
    ('bdicred',  'sp_consultatgarantia'):           ('bdicnweb', 'sp_cred_consultatgarantia'),
    ('bdicred',  'sp_grabatipofacturacion'):        ('bdicnweb', 'sp_cred_grabatipofacturacion'),
    ('bdicred',  'sp_status_sol_aud'):              ('bdicred',  'sp_status_sol_aud2'),
    ('bdispei',  'sp_validafecha'):                 ('bdiresp',  'sp_validafecha'),
}


# ── 1. Abrir brain.db para conocer los nombres de DB antes de indexar ─────
conn = sqlite3.connect(DB_PATH)
conn.row_factory = sqlite3.Row

# DBs ordenadas de mayor a menor longitud para evitar ambigüedad en prefix-match
known_dbs = sorted(
    {r[0] for r in conn.execute('SELECT DISTINCT db FROM sps WHERE db IS NOT NULL').fetchall()},
    key=len, reverse=True
)

# ── 2. Índice de archivos SQL — dos convenciones de nombre ─────────────────
# Convención 1 (nueva): {db}_sp_{resto}.sql   → sp_name = "sp_{resto}"
# Convención 2 (legacy): {db}_{nombre}.sql    → sp_name = "{nombre}" (sin sp_)
print('Indexando archivos SQL...', flush=True)
file_index = {}  # (db, sp_name) → filepath
n_conv1 = 0; n_conv2 = 0
for entry in os.scandir(SOURCE_DIR):
    if not entry.name.endswith('.sql'):
        continue
    fname = entry.name[:-4]

    # Convención 1: contiene "_sp_"
    idx = fname.find('_sp_')
    if idx >= 0:
        db_part = fname[:idx]
        sp_part = fname[idx+1:]          # incluye "sp_"
        file_index[(db_part, sp_part)] = entry.path
        n_conv1 += 1
        continue

    # Convención 2: {db}_{nombre} donde nombre no empieza con sp_
    fname_l = fname.lower()
    for db in known_dbs:
        if fname_l.startswith(db + '_'):
            sp_part = fname[len(db) + 1:]
            file_index[(db, sp_part)] = entry.path
            n_conv2 += 1
            break

print(f'  {n_conv1:,} archivos conv-1 (sp_prefix)  +  {n_conv2:,} conv-2 (legacy)  =  {len(file_index):,} total', flush=True)


# ── 3. Cargar candidatos desde brain.db ───────────────────────────────────
candidates = conn.execute('''
    SELECT domain, db, name, loc, fan_out
    FROM sps
    ORDER BY domain, name
''').fetchall()
print(f'Universo completo (patrón estructural): {len(candidates):,} SPs', flush=True)


# ── 4. Señales y clasificador ──────────────────────────────────────────────
def extract_signals(sp_name, db_name):
    key = (db_name, sp_name)
    fpath = file_index.get(key)
    if not fpath:
        alias = FILE_ALIASES.get(key)
        if alias:
            fpath = file_index.get(alias)
    if not fpath:
        return None

    try:
        with open(fpath, encoding='utf-8', errors='replace') as f:
            code = f.read()
    except OSError:
        return None

    code_u = code.upper()

    sig_match = re.search(r'CREATE\s+PROCEDURE\s+\S+\s*\(([^)]*)\)', code, re.I | re.S)
    params_u  = sig_match.group(1).upper() if sig_match else ''

    calls     = re.findall(r'(?:CALL|EXECUTE\s+PROCEDURE)\s+([\w:]+)\s*\(', code, re.I)
    calls_set = {c.lower() for c in calls}
    n_calls   = len(calls_set)
    n_cross   = sum(1 for c in calls_set if ':' in c)

    # RETURN...WITH RESUME: este SP es un cursor streaming (producer).
    # Patrón Informix-específico sin equivalente en SQL estándar — todo caller
    # debe usar el protocolo FOREACH/RESUME y migrar cuando el producer migre.
    has_return_resume = bool(re.search(r'\bRETURN\b[^;]+\bWITH\s+RESUME\b', code_u, re.S))

    inserts = len(re.findall(r'\bINSERT\b', code_u))
    updates = len(re.findall(r'\bUPDATE\b', code_u))
    deletes = len(re.findall(r'\bDELETE\b', code_u))

    write_targets = ' '.join(
        re.findall(r'(?:INSERT\s+(?:INTO\s+)?|UPDATE\s+)([\w:]+)', code, re.I)
    ).lower()

    n_foreach = len(re.findall(r'\bFOREACH\b', code_u))
    n_commit  = len(re.findall(r'\bCOMMIT\b',  code_u))

    # RETURNING: SP retorna valores/filas al caller (función-like); ausencia de RETURNING
    # implica SP de efecto lateral puro (escritura/proceso sin valor de retorno explícito).
    has_returning = bool(re.search(r'\bRETURNING\b', code_u))

    name_l = sp_name.lower()
    return dict(
        n_calls=n_calls,   n_cross=n_cross,
        calls_set=calls_set,  # retenido para detección de consumers en segunda pasada
        inserts=inserts,   updates=updates,   deletes=deletes,
        n_writes=inserts + updates + deletes,
        n_foreach=n_foreach, n_commit=n_commit,
        has_return_resume = has_return_resume,
        has_returning  = has_returning,
        has_contproc   = 'sx_contproc'   in write_targets or 'sd_contproc' in write_targets,
        has_hist       = bool(re.search(r'_hist\b', write_targets)),
        is_empresa     = 'EMPRESA' in params_u or 'PEMP' in params_u,
        has_file       = bool(re.search(r'cargarchivo|_load|archivo|carga_arch|load_file', name_l)),
        has_load_stmt  = bool(re.search(r'\bLOAD\b|\bUNLOAD\b', code_u)),
        has_purge      = bool(re.search(r'depura|purga|limpia|elimina|borra', name_l)),
        has_masivo     = bool(re.search(r'masivo|massiv|_lote|_bulk', name_l)),
        has_masivo_code= n_foreach >= 10 and n_cross >= 1,
        has_cierre     = bool(re.search(r'cierre|corte|cierr', name_l)),
        has_concilia   = bool(re.search(r'concilia|reconcil', name_l)),
        has_reporte    = bool(re.search(r'reporte|genrep|bitacora|_aud', name_l)),
    )


def classify(sp_name, sig):
    if sig is None:
        return 'NO_SOURCE'

    if sig['has_purge'] or (sig['has_hist'] and sig['deletes'] > 0 and sig['n_calls'] == 0):
        return 'PURGE_JOB'

    if sig['has_file'] or sig['has_load_stmt']:
        return 'FILE_LOADER'

    if sig['has_contproc'] and sig['is_empresa']:
        return 'ACCOUNTING_JOB'

    if sig['has_masivo'] or sig['has_masivo_code']:
        return 'MASS_OPERATION'

    if sig['n_calls'] >= 2:
        return 'ORCHESTRATOR'

    if sig['has_cierre'] and sig['n_writes'] > 0:
        return 'CIERRE_CORTE'

    if sig['has_concilia']:
        return 'CONCILIACION'

    if sig['has_reporte'] or (sig['n_foreach'] >= 5 and sig['n_calls'] == 0 and sig['n_writes'] > 0):
        return 'REPORT_AGGREGATOR'

    # DATA_MAINT: escribe a tablas sin calls externos (con o sin loop).
    # Antes requería n_foreach>=1; esa restricción excluía 575 SPs con writes
    # condicionales (IF-branches) sin FOREACH explícito.
    if sig['n_writes'] > 0 and sig['n_calls'] == 0:
        return 'DATA_MAINT'

    if sig['n_calls'] == 1:
        return 'SINGLE_CALL'

    # CURSOR_SP: loop de lectura puro — FOREACH sin escritura ni calls.
    # Típico de SPs que retornan conjuntos de filas al caller vía RETURNING+FOREACH.
    if sig['n_foreach'] > 0 and sig['n_writes'] == 0 and sig['n_calls'] == 0:
        return 'CURSOR_SP'

    # QUERY_SP: consulta puntual sin loop ni DML — SPs con RETURNING que
    # calculan y devuelven valores (CHAR/MONEY/DATE) sin iterar ni escribir.
    if sig['n_writes'] == 0 and sig['n_calls'] == 0 and sig['n_foreach'] == 0:
        return 'QUERY_SP'

    return 'UNKNOWN'


# ── 4. Procesar candidatos — Primera pasada ────────────────────────────────
print('Clasificando SPs (pasada 1/2)...', flush=True)
t0 = time.time()
rows = []
counts = Counter()
all_calls_map = {}  # (db, sp_name) → calls_set; para detección de consumers

for i, row in enumerate(candidates):
    sig      = extract_signals(row['name'], row['db'])
    archetype = classify(row['name'], sig)
    counts[archetype] += 1

    all_calls_map[(row['db'], row['name'])] = sig['calls_set'] if sig else set()

    rows.append((
        row['domain'],
        row['db'],
        row['name'],
        row['loc'],
        archetype,
        sig['n_calls']         if sig else None,
        sig['n_cross']         if sig else None,
        sig['n_foreach']       if sig else None,
        sig['n_writes']        if sig else None,
        sig['n_commit']        if sig else None,
        1 if (sig and sig['has_contproc'])      else 0,
        1 if (sig and sig['has_hist'])          else 0,
        1 if (sig and sig['has_return_resume']) else 0,
    ))

    if (i + 1) % 500 == 0:
        elapsed = time.time() - t0
        print(f'  {i+1:,} / {len(candidates):,}  ({elapsed:.1f}s)', flush=True)

elapsed = time.time() - t0
print(f'Pasada 1 completa: {len(rows):,} SPs en {elapsed:.1f}s', flush=True)

# ── 4b. Segunda pasada — detectar consumers de producers ──────────────────
# Producer: índice 12 == has_return_resume
producer_names = {r[2] for r in rows if r[12] == 1}
print(f'Producers (RETURN...WITH RESUME): {len(producer_names):,}', flush=True)

final_rows = []
n_consumers = 0
for r in rows:
    db, sp_name = r[1], r[2]
    calls = all_calls_map.get((db, sp_name), set())
    # Un SP es consumer si llama a algún producer (compara solo la parte después de ':')
    has_consumer = int(any(c.split(':')[-1] in producer_names for c in calls))
    n_consumers += has_consumer
    final_rows.append(r + (has_consumer,))

print(f'Consumers (FOREACH → producer): {n_consumers:,}', flush=True)


# ── 5. Guardar en brain.db ─────────────────────────────────────────────────
print('Escribiendo a brain.db...', flush=True)
conn.execute('DROP TABLE IF EXISTS batch_analysis')
conn.execute('''
    CREATE TABLE batch_analysis (
        domain              TEXT,
        db                  TEXT,
        sp_name             TEXT,
        loc                 INTEGER,
        archetype           TEXT,
        n_calls             INTEGER,
        n_cross_db          INTEGER,
        n_foreach           INTEGER,
        n_writes            INTEGER,
        n_commit            INTEGER,
        has_contproc        INTEGER,
        has_hist            INTEGER,
        has_return_resume   INTEGER,  -- 1 = producer: RETURN...WITH RESUME (streaming cursor Informix-específico)
        has_resume_consumer INTEGER,  -- 1 = consumer: llama a un producer vía FOREACH
        PRIMARY KEY (db, sp_name)
    )
''')
conn.executemany('''
    INSERT OR REPLACE INTO batch_analysis VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)
''', final_rows)
conn.commit()
print(f'  {len(final_rows):,} filas insertadas', flush=True)

# ── 6. Resumen final ───────────────────────────────────────────────────────
print()
print('=== DISTRIBUCIÓN DE SUB-ARQUETIPOS ===')
for arch, n in sorted(counts.items(), key=lambda x: -x[1]):
    bar = '█' * (n // 50)
    print(f'  {arch:<22} {n:>5}  {bar}')

print()
print('=== MUESTRA POR SUB-ARQUETIPO (primeros 5) ===')
by_arch = defaultdict(list)
for r in final_rows:
    by_arch[r[4]].append(r)

for arch in sorted(by_arch.keys()):
    sample = by_arch[arch][:5]
    print(f'\n[{arch}]  total={len(by_arch[arch])}')
    for dom, db, name, loc, _, n_calls, n_cross, n_foreach, n_writes, *_ in sample:
        print(f'  {dom:<6} {name:<50} loc={loc:>6} loops={n_foreach} calls={n_calls} writes={n_writes}')

# ── 7. Propagar a sps.batch_archetype + sp_archetype ────────────────────────
print('Propagando arquetipos a sps...', flush=True)

try:
    conn.execute('ALTER TABLE sps ADD COLUMN sp_archetype TEXT')
except Exception:
    pass

conn.execute('''
    UPDATE sps SET
        batch_archetype = CASE
            WHEN batch_archetype = 'CTM_HINT' THEN 'CTM_HINT'
            ELSE (SELECT b.archetype FROM batch_analysis b
                  WHERE b.db = sps.db AND b.sp_name = sps.name)
        END,
        sp_archetype    = (SELECT b.archetype FROM batch_analysis b
                           WHERE b.db = sps.db AND b.sp_name = sps.name)
    WHERE EXISTS (
        SELECT 1 FROM batch_analysis b WHERE b.db = sps.db AND b.sp_name = sps.name
    )
''')
conn.commit()
n_prop = conn.execute(
    'SELECT COUNT(*) FROM sps WHERE sp_archetype IS NOT NULL'
).fetchone()[0]
total  = conn.execute('SELECT COUNT(*) FROM sps').fetchone()[0]
print(f'  {n_prop:,} / {total:,} SPs con sp_archetype ({n_prop/total*100:.1f}%)')

conn.close()
print()
print('Listo. Tabla batch_analysis disponible en brain.db.')
