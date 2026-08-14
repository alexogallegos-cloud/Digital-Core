"""
build-brain.py — Control-M Brain · Pipeline de construcción
Lee el inventario de jobs de BMC Control-M (Excel .xls) y construye brain.db.

Fuente: source/Cierre ControlM 12082026 (1) (1).xls
Uso:  python digital-brain/build-brain.py
"""

import json, sqlite3, re, sys
from pathlib import Path

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

SCRIPT_DIR = Path(__file__).resolve().parent
BASE       = SCRIPT_DIR.parent                   # ControlM/
DB_PATH    = SCRIPT_DIR / 'brain.db'
XLS_GLOB   = list(BASE.glob('source/*.xls')) + list(BASE.glob('source/*.xlsx'))

# ── Mapping: folder CTM → dominio Informix ──────────────────────────────────
# Basado en análisis del inventario de jobs. "multi" = varios dominios.
FOLDER_DOMAIN = {
    'PRO_JOBS_001':                          'multi',
    'PRO_JOBS_001_MTY':                      'multi',
    'PRO_AFT_001':                           'multi',      # File transfers
    'PRO_AFT_001_MTY':                       'multi',
    'PRO_EJECUTOR_001':                      'multi',      # Orquestador genérico
    'PRO_EJECUTOR_001_MTY':                  'multi',
    'PRO_ACTIV_PRE_001':                     'D03',        # Créditos — pre-activación
    'PRO_ACTIV_PRE_001_MTY':                 'D03',
    'PRO_PER-INTEGRAL_001':                  'D06',        # Solicitudes / persona integral
    'PRO_PER-INTEGRAL_001_MTY':              'D06',
    'PRO_POSTERIORES_001':                   'multi',      # Post-processing cierre de día
    'PRO_POSTERIORES_001_MTY':               'multi',
    'PRO_SISTEMA_COBRANZA_ICS_001':          'D11',        # Cobranza
    'PRO_SISTEMA_COBRANZA_ICS_001_MTY':      'D11',
    'PRO_CREDITO_COMERCIAL_001':             'D03',        # Crédito comercial
    'PRO_CREDITO_COMERCIAL_001_MTY':         'D03',
    'PRO_CREDITO_001':                       'D03',        # Crédito general
    'PRO_CREDITO_001_MTY':                   'D03',
    'PRO_CRED_HIPOTECARIO_INFONAVIT_001':    'D03',        # Crédito hipotecario
    'PRO_CRED_HIPOTECARIO_INFONAVIT_001_MTY':'D03',
    'PRO_ATM_IST_001':                       'D10',        # ATM / Sucursales
    'PRO_ATM_IST_001_MTY':                   'D10',
    'PRO_RIESGOS_001':                       'D48',        # Riesgos de crédito
    'PRO_RIESGOS_001_MTY':                   'D48',
    'PRO_PLD_MINDS_001':                     'D15',        # AML / PLD
    'PRO_PLD_MINDS_001_MTY':                 'D15',
    'PRO_GENEDOCTAS_001':                    'D12',        # Generación estados de cuenta / contabilidad
    'PRO_GENEDOCTAS_001_MTY':               'D12',
    'PRO_CALCULOS_001':                      'D03',        # Cálculos crédito
    'PRO_CALCULOS_001_MTY':                  'D03',
    'PRO_SUCURSALES_WEB_001':                'D10',        # Sucursales web
    'PRO_SUCURSALES_WEB_001_MTY':            'D10',
    'PRO_CORRESPONSALES_001':                'D10',        # Corresponsal bancario
    'PRO_CORRESPONSALES_001_MTY':            'D10',
    'PRO_COPPEL_MAX_001':                    'D03',        # Producto CoppelMax
    'PRO_COPPEL_MAX_001_MTY':               'D03',
    'PRO_GRANDATA_001':                      'D03',        # Scoring / Gran Data (buró)
    'PRO_GRANDATA_001_MTY':                  'D03',
    'PRO_DATA_WAREHOUSE_001':                'D40',        # Banca Internet / BI
    'PRO_DATA_WAREHOUSE_001_MTY':            'D40',
    'PRO_INICO_ANO_001':                     'multi',      # Inicialización de año
    'PRO_INICO_ANO_001_MTY':                 'multi',
    'PRO_CTM_A_PROD_001':                    'multi',      # Infraestructura CTM
    'PRO_CTM_A_PROD_001_MTY':               'multi',
    # Unity — ya en producción parcial
    'USV-UNITY_SMARTVISTA_001':              'D16',        # SmartVista (Unity R2/R3)
    'USV-UNITY_SMARTVISTA_001_MTY':          'D16',
    # Pruebas / Control
    'CTM-VALIDA_AGENTES':                    None,
    'CTM-PRUEBAS_DS':                        None,
    'CTM-PRUEBA_FUNCIONAL':                  None,
    'TEST_AGNT_CTM_V9':                      None,
    'CTM-VALIDA_AGENTES_MTY':               None,
}

FOLDER_NAMES = {
    'PRO_JOBS_001':                          'Batch Principal (multi-dominio)',
    'PRO_AFT_001':                           'Transferencias de Archivos',
    'PRO_EJECUTOR_001':                      'Orquestador Genérico',
    'PRO_ACTIV_PRE_001':                     'Pre-Activación Créditos',
    'PRO_PER-INTEGRAL_001':                  'Persona Integral / Solicitudes',
    'PRO_POSTERIORES_001':                   'Post-Procesamiento Cierre de Día',
    'PRO_SISTEMA_COBRANZA_ICS_001':          'Sistema Cobranza ICS',
    'PRO_CREDITO_COMERCIAL_001':             'Crédito Comercial',
    'PRO_CREDITO_001':                       'Crédito General',
    'PRO_CRED_HIPOTECARIO_INFONAVIT_001':    'Crédito Hipotecario Infonavit',
    'PRO_ATM_IST_001':                       'ATM / IST Sucursales',
    'PRO_RIESGOS_001':                       'Riesgos de Crédito',
    'PRO_PLD_MINDS_001':                     'AML / PLD Minds',
    'PRO_GENEDOCTAS_001':                    'Generación de Estados de Cuenta',
    'PRO_CALCULOS_001':                      'Cálculos de Crédito',
    'PRO_SUCURSALES_WEB_001':               'Sucursales Web',
    'PRO_CORRESPONSALES_001':               'Corresponsal Bancario',
    'PRO_COPPEL_MAX_001':                   'Producto CoppelMax',
    'PRO_GRANDATA_001':                     'Scoring / Gran Data',
    'PRO_DATA_WAREHOUSE_001':               'Data Warehouse / BI',
    'PRO_INICO_ANO_001':                    'Inicialización de Año',
    'PRO_CTM_A_PROD_001':                   'Infraestructura Control-M',
    'USV-UNITY_SMARTVISTA_001':             'Unity — SmartVista (malla nueva)',
    'CTM-VALIDA_AGENTES':                   'Validación de Agentes CTM',
    'TEST_AGNT_CTM_V9':                     'Test / Staging CTM v9',
}

# ── Schema ───────────────────────────────────────────────────────────────────
SCHEMA = '''
PRAGMA journal_mode=WAL;
PRAGMA synchronous=NORMAL;

DROP TABLE IF EXISTS cross_dependencies;
DROP TABLE IF EXISTS sp_hints;
DROP TABLE IF EXISTS flows;
DROP TABLE IF EXISTS jobs;

CREATE TABLE jobs (
    id             TEXT PRIMARY KEY,   -- job_name (único en el export)
    job_name       TEXT NOT NULL,
    job_type       TEXT,               -- OS | AFT | Dummy | WS | Databases | ...
    folder         TEXT,               -- Parent Folder en CTM
    ctm_server     TEXT,               -- Control-M Server
    host           TEXT,               -- Host/Host Group (servidor de ejecución)
    site           TEXT,               -- CLN | MTY (derivado del host)
    created_by     TEXT,
    description    TEXT,
    run_as         TEXT,               -- usuario de SO que ejecuta el job
    doc_lib        TEXT,
    doc_mem        TEXT,               -- nombre del .txt de documentación
    mem_name       TEXT,               -- script ejecutado (Mem Name)
    cyclic         TEXT,
    critical       TEXT,
    confirm        TEXT,
    domain_id      TEXT,               -- dominio Informix (derivado del folder)
    is_informix    INTEGER DEFAULT 0,  -- 1 si corre en servidor Informix
    is_unity       INTEGER DEFAULT 0,  -- 1 si es job Unity (nueva malla)
    has_sp_hint    INTEGER DEFAULT 0   -- 1 si el script/job referencia un SP por nombre
);

CREATE TABLE flows (
    folder         TEXT PRIMARY KEY,
    folder_name    TEXT,
    domain_id      TEXT,
    job_count      INTEGER DEFAULT 0,
    os_count       INTEGER DEFAULT 0,
    aft_count      INTEGER DEFAULT 0,
    informix_count INTEGER DEFAULT 0,
    unity          INTEGER DEFAULT 0   -- 1 si es un flow de Unity (nueva malla)
);

CREATE TABLE sp_hints (
    job_id         TEXT NOT NULL,
    sp_name_hint   TEXT NOT NULL,      -- nombre del SP extraído del script/job
    source         TEXT,               -- 'job_name' | 'mem_name'
    PRIMARY KEY (job_id, sp_name_hint)
);

-- Dependencias cross-sistema (Regla B5 AM) — perspectiva de Control-M
CREATE TABLE cross_dependencies (
    id               TEXT PRIMARY KEY,
    other_system     TEXT NOT NULL,
    dependency_type  TEXT NOT NULL,    -- orchestrates | calls | reads | writes | feeds | notifies
    direction        TEXT NOT NULL,    -- outbound | inbound
    description      TEXT,
    evidence         TEXT,
    criticality      TEXT
);

CREATE INDEX idx_jobs_folder   ON jobs(folder);
CREATE INDEX idx_jobs_host     ON jobs(host);
CREATE INDEX idx_jobs_type     ON jobs(job_type);
CREATE INDEX idx_jobs_domain   ON jobs(domain_id);
CREATE INDEX idx_jobs_informix ON jobs(is_informix);
CREATE INDEX idx_jobs_unity    ON jobs(is_unity);
CREATE INDEX idx_sp_hints_job  ON sp_hints(job_id);
CREATE INDEX idx_sp_hints_sp   ON sp_hints(sp_name_hint);
'''

# ── Helpers ──────────────────────────────────────────────────────────────────
INFORMIX_HOSTS = {'dccsif01', 'dcmsif01'}
UNITY_FOLDERS  = {'USV-UNITY_SMARTVISTA_001', 'USV-UNITY_SMARTVISTA_001_MTY'}

def site_from_host(host: str) -> str:
    h = host.lower()
    if 'mty' in h or h.endswith('020') or h == 'dcmsif01' or h == 'dcmdat01' \
            or h == 'dcmpld01' or h == 'dcmpyt01' or h == 'dcmatm02' or h == 'dcmpld02':
        return 'MTY'
    if 'cln' in h or h == 'dccsif01' or h == 'dccdat01' \
            or h == 'dccpld01' or h == 'dccimg01' or h == 'dccpyt01' or h == 'dccatm02':
        return 'CLN'
    return 'SHARED'

def normalize_folder(folder: str) -> str:
    """Normaliza el folder quitando el sufijo _MTY para el lookup de dominio."""
    for suffix in ('_MTY', '_MTY_001', '_001_MTY'):
        if folder.endswith(suffix):
            return folder[:-len(suffix)] + '_001'
    return folder

def extract_sp_hints(job_name: str, mem_name: str) -> list[tuple[str, str]]:
    """Extrae posibles nombres de SPs del nombre del job o del script."""
    hints = []
    sp_re = re.compile(r'sp_[a-zA-Z0-9_]+', re.IGNORECASE)
    for m in sp_re.finditer(job_name):
        hints.append((m.group().lower(), 'job_name'))
    for m in sp_re.finditer(mem_name):
        hints.append((m.group().lower(), 'mem_name'))
    return hints


# ── Carga desde Excel ─────────────────────────────────────────────────────────
def load_jobs(conn):
    if not XLS_GLOB:
        print('  jobs         [SKIPPED — no .xls/.xlsx en source/]')
        return

    xls_path = XLS_GLOB[0]
    print(f'  Leyendo: {xls_path.name}')

    try:
        import xlrd
        wb = xlrd.open_workbook(str(xls_path))
        sh = wb.sheets()[0]
        headers = [sh.cell_value(0, j) for j in range(sh.ncols)]
        raw_rows = [
            {headers[j]: sh.cell_value(i, j) for j in range(sh.ncols)}
            for i in range(1, sh.nrows)
        ]
    except ImportError:
        print('  [ERROR] xlrd no instalado. Ejecuta: pip install xlrd')
        return

    job_rows, sp_hint_rows = [], []
    seen_ids = {}

    for r in raw_rows:
        job_name = r.get('Job Name', '').strip()
        if not job_name:
            continue

        # Dedup: si el job_name ya existe (MTY mirror), usa sufijo
        if job_name in seen_ids:
            seen_ids[job_name] += 1
            uid = f"{job_name}__#{seen_ids[job_name]}"
        else:
            seen_ids[job_name] = 0
            uid = job_name

        folder   = r.get('Parent Folder', '').strip()
        host     = r.get('Host/Host Group', '').strip()
        mem_name = r.get('Mem Name', '').strip()

        norm_folder = normalize_folder(folder)
        domain_id   = FOLDER_DOMAIN.get(folder) or FOLDER_DOMAIN.get(norm_folder)
        is_informix = 1 if host in INFORMIX_HOSTS else 0
        is_unity    = 1 if folder in UNITY_FOLDERS else 0

        hints = extract_sp_hints(job_name, mem_name)
        has_sp_hint = 1 if hints else 0

        job_rows.append((
            uid,
            job_name,
            r.get('Type', '').strip(),
            folder,
            r.get('Control-M Server', '').strip(),
            host,
            site_from_host(host),
            r.get('Created By', '').strip(),
            r.get('Description', '').strip(),
            r.get('Run as', '').strip(),
            r.get('Doc Lib', '').strip(),
            r.get('Doc Mem', '').strip(),
            mem_name,
            r.get('Cyclic', '').strip(),
            r.get('Critical', '').strip(),
            r.get('Confirm', '').strip(),
            domain_id,
            is_informix,
            is_unity,
            has_sp_hint,
        ))

        for sp_hint, source in hints:
            sp_hint_rows.append((uid, sp_hint, source))

    conn.executemany(
        '''INSERT OR REPLACE INTO jobs
           (id, job_name, job_type, folder, ctm_server, host, site,
            created_by, description, run_as, doc_lib, doc_mem, mem_name,
            cyclic, critical, confirm, domain_id, is_informix, is_unity, has_sp_hint)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)''',
        job_rows
    )
    conn.executemany(
        'INSERT OR IGNORE INTO sp_hints (job_id, sp_name_hint, source) VALUES (?,?,?)',
        sp_hint_rows
    )
    conn.commit()
    n = conn.execute('SELECT COUNT(*) FROM jobs').fetchone()[0]
    n_ifx = conn.execute('SELECT COUNT(*) FROM jobs WHERE is_informix=1').fetchone()[0]
    n_unity = conn.execute('SELECT COUNT(*) FROM jobs WHERE is_unity=1').fetchone()[0]
    n_sp = conn.execute('SELECT COUNT(*) FROM sp_hints').fetchone()[0]
    print(f'  jobs         {n:>6,} total   {n_ifx:>5,} en Informix   {n_unity:>4} Unity   {n_sp:>5,} SP hints')


def build_flows(conn):
    """Agrega estadísticas por folder (= proceso/flujo batch)."""
    rows = conn.execute(
        '''SELECT folder,
                  COUNT(*) AS job_count,
                  SUM(CASE WHEN job_type='OS'  THEN 1 ELSE 0 END) AS os_count,
                  SUM(CASE WHEN job_type='AFT' THEN 1 ELSE 0 END) AS aft_count,
                  SUM(is_informix) AS informix_count,
                  MAX(is_unity)    AS unity
           FROM jobs
           GROUP BY folder'''
    ).fetchall()

    flow_rows = []
    for r in rows:
        folder = r[0]
        norm = normalize_folder(folder)
        folder_name = FOLDER_NAMES.get(folder) or FOLDER_NAMES.get(norm) or folder
        domain_id   = FOLDER_DOMAIN.get(folder) or FOLDER_DOMAIN.get(norm)
        flow_rows.append((folder, folder_name, domain_id, r[1], r[2], r[3], r[4], r[5]))

    conn.executemany(
        '''INSERT OR REPLACE INTO flows
           (folder, folder_name, domain_id, job_count, os_count, aft_count, informix_count, unity)
           VALUES (?,?,?,?,?,?,?,?)''',
        flow_rows
    )
    conn.commit()
    n = conn.execute('SELECT COUNT(*) FROM flows').fetchone()[0]
    print(f'  flows        {n:>6,} carpetas/procesos batch')


def seed_cross_dependencies(conn):
    """Dependencias cross-sistema desde la perspectiva de Control-M (Regla B5 AM)."""
    n_ifx = conn.execute('SELECT COUNT(*) FROM jobs WHERE is_informix=1').fetchone()[0]
    n_os  = conn.execute("SELECT COUNT(*) FROM jobs WHERE is_informix=1 AND job_type='OS'").fetchone()[0]
    n_sp  = conn.execute('SELECT COUNT(*) FROM sp_hints').fetchone()[0]

    deps = [
        # OUTBOUND: CTM orquesta los SPs batch de Informix
        ('ctm-pisa-orchestrates',
         'pisa', 'orchestrates', 'outbound',
         'Control-M invoca los jobs batch que corren sobre Informix (dccsif01/dcmsif01). '
         'Gestiona la secuencia de ejecución, ventanas horarias, retry y alertas de SLA batch.',
         f'{n_ifx:,} jobs en servidores Informix — {n_os:,} de tipo OS — {n_sp:,} referencias a SPs',
         'critical'),
        # OUTBOUND: CTM ya tiene jobs de SmartVista (Unity)
        ('ctm-smartvista-unity',
         'smartvista', 'orchestrates', 'outbound',
         'Control-M ya incluye carpeta USV-UNITY_SMARTVISTA_001 con jobs de SmartVista (Unity R2/R3). '
         'La malla batch está siendo extendida para los sistemas target del programa Unity.',
         'Carpeta USV-UNITY_SMARTVISTA_001 detectada en inventario — malla en transición',
         'high'),
        # OUTBOUND: CTM genera archivos que van a sistemas externos (Banxico, CECOBAN)
        ('ctm-banxico-feeds',
         'banxico', 'feeds', 'outbound',
         'Jobs batch de CTM generan archivos de liquidación SPEI/CECOBAN que se envían '
         'a Banxico en el proceso de cierre de día.',
         'Folder PRO_JOBS_001 incluye jobs de cierre SPEI (eje_029Redilide.sh, etc.)',
         'critical'),
        # INBOUND: Atlas usa ventanas batch de CTM para extracción
        ('ctm-atlas-window',
         'atlas', 'notifies', 'inbound',
         'Atlas depende de las ventanas batch de Control-M para programar sus extracciones '
         'nocturnas de datos históricos de Informix sin impacto en producción.',
         'Extracción programada en ventana post-cierre de día CTM',
         'medium'),
    ]
    conn.executemany(
        '''INSERT OR REPLACE INTO cross_dependencies
           (id, other_system, dependency_type, direction, description, evidence, criticality)
           VALUES (?,?,?,?,?,?,?)''',
        deps
    )
    conn.commit()
    print(f'  cross_deps   {len(deps):>3} dependencias declaradas')


def print_summary(conn):
    print('\n── Control-M brain.db ─────────────────────────────────')
    for t in ['jobs', 'flows', 'sp_hints', 'cross_dependencies']:
        n = conn.execute(f'SELECT COUNT(*) FROM {t}').fetchone()[0]
        print(f'  {t:<22} {n:>6,}')

    print('\n── Por tipo de job ────────────────────────────────────')
    for row in conn.execute('SELECT job_type, COUNT(*) n FROM jobs GROUP BY job_type ORDER BY n DESC'):
        print(f'  {row[0] or "(vacío)":<30} {row[1]:>6,}')

    print('\n── Informix: jobs por dominio ──────────────────────────')
    for row in conn.execute(
        '''SELECT domain_id, COUNT(*) n FROM jobs WHERE is_informix=1
           GROUP BY domain_id ORDER BY n DESC LIMIT 15'''
    ):
        print(f'  {row[0] or "multi/unknown":<10} {row[1]:>6,}')

    print('\n── SP Hints — top 20 ───────────────────────────────────')
    for row in conn.execute(
        'SELECT sp_name_hint, COUNT(*) n FROM sp_hints GROUP BY sp_name_hint ORDER BY n DESC LIMIT 20'
    ):
        print(f'  {row[0]:<45} {row[1]:>4}')

    print('\n── Flows Unity (nueva malla) ───────────────────────────')
    for row in conn.execute('SELECT folder, folder_name, job_count FROM flows WHERE unity=1'):
        print(f'  {row[0]:<35} {row[1]:<35} {row[2]:>4} jobs')


# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    print('Control-M Brain — build pipeline')
    print(f'Base:   {BASE}')
    print(f'Output: {DB_PATH}\n')

    if DB_PATH.exists():
        DB_PATH.unlink()
        print('brain.db anterior eliminado')

    conn = sqlite3.connect(DB_PATH)
    conn.executescript(SCHEMA)
    print('Schema OK\n')

    print('Cargando fuentes:')
    load_jobs(conn)
    build_flows(conn)
    seed_cross_dependencies(conn)
    print_summary(conn)
    conn.close()
    print('\n✓ brain.db construido')


if __name__ == '__main__':
    main()
