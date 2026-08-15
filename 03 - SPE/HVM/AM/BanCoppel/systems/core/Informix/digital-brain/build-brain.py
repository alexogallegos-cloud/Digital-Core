"""
build-brain.py — Informix Digital Brain · Pipeline de construcción
Lee todos los artefactos existentes (JSON, py) y construye brain.db (SQLite).
No modifica ningún archivo fuente.

Uso: python digital-brain/build-brain.py
     (ejecutar desde Informix/ o desde digital-brain/)
"""

import json, sqlite3, re, sys
from pathlib import Path

# Ensure UTF-8 output on Windows (avoids cp1252 crash on box-drawing chars)
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

# ── Rutas ────────────────────────────────────────────────────────────────────

SCRIPT_DIR = Path(__file__).resolve().parent
BASE = SCRIPT_DIR.parent           # Informix/
DB_PATH = SCRIPT_DIR / 'brain.db'

# ── Mapeos canónicos ─────────────────────────────────────────────────────────

DB_TO_DOMAIN = {
    # ── Dominios originales D01-D12 ───────────────────────────────────────────
    'bdicnweb':     'D01', 'bdinteg':      'D02', 'bdicred':      'D03',
    'bdicheq':      'D04', 'bdisac':       'D05', 'bdisolic':     'D06',
    'bdiaclaracion':'D07', 'bdispei':      'D08', 'bdimnsj':      'D09',
    'bdisuc':       'D10', 'bdicobranza':  'D11', 'bdicont':      'D12',
    # ── Mapeo profundo 2026-07-26 — dominios existentes ───────────────────────
    'bdiburo':      'D03',  # Créditos — consulta Buró de Crédito
    'bditrapres':   'D03',  # Créditos — transacciones de préstamos
    'bdicntchq':    'D04',  # Cheques y Cuentas — consultas de cuentas
    'bditrans':     'D04',  # Cheques y Cuentas — certificación de cheques/pagos
    'bdinvers':     'D04',  # Cheques y Cuentas — inversiones/pagarés (depósitos a plazo)
    'bdidomi':      'D08',  # Pagos — domiciliación (cobro automático)
    'bditransfer':  'D08',  # Pagos — transferencias internas + SPEI
    'bdibpi':       'D08',  # Pagos — operaciones de pago portal institucional
    'bdiprog':      'D08',  # Pagos — AFORE batch + transacciones programadas
    'bdiedoelec':   'D09',  # Mensajería — estados de cuenta electrónicos (sp_ins_user_pass* → D02 vía override)
    'bdicplbot':    'D08',  # Pagos — transacciones reales via WhatsApp (cargo/reverso)
    'bdicorresp':   'D10',  # Sucursales/ATM — corresponsal bancario
    'bdivr':        'D10',  # Sucursales/ATM — IVR canal telefónico
    'bdimonitorcob':'D11',  # Cobranza — monitoreo de pagos
    # ── Nuevos dominios D13-D16 ───────────────────────────────────────────────
    'bditef':       'D13',  # TEF — Transferencias Electrónicas de Fondos (CECOBAN batch)
    'bdibei':       'D14',  # BEI — Banca Electrónica Institucional / tokens SOE
    'bdilide':      'D15',  # AML — LIDE (Ley de Identificación Depósitos en Efectivo)
    'bdiauditor':   'D15',  # AML — listas negras / auditoría XML
    'bdisitesp':    'D15',  # AML — SITE-SP (personas sancionadas/PEP), fan_in ~260
    'intercard':    'D16',  # Tarjetas — gestión tarjetas INTERCARD
    'intercardbpi': 'D16',  # Tarjetas — INTERCARD portal institucional
    'bditarjeta':   'D15',  # AML/Regulatorio — SAT reporting (conciliación → D12 vía override)
    'bditarjcop':   'D08',  # Pagos — sp_conslotepend (lotes pendientes, fan_in=137)
    # ── Nuevos dominios D23-D49 — swarm mapping 2026-08-10 ───────────────────
    # Fuente: swarm 3-agentes (A=nombre, B=código fuente, D=vocab); B tiene mayor peso
    'bdmis':          'D23',   # Fuerza de Ventas / MIS Sucursales
    'bdiprospectos':  'D26',   # Prospectos / Captación Nuevos Clientes
    'bdireports':     'D32',   # Reportes Redes de Pago Visa/MC
    'bdiresp':        'D34',   # Respaldos / Administración DBA
    'bdidigital':     'D35',   # Digitalización / Expediente Documental
    'bdirepaut':      'D36',   # Reportería Regulatoria Automatizada CNBV
    'bdiadminnomina': 'D37',   # Nómina / Dispersión de Cuentas Nómina
    'bdibi':          'D40',   # Banca por Internet / Portal BPI Consumer
    'bdiprem':        'D45',   # Premios / Promociones Comerciales
    'bdiofi':         'D46',   # Oficinas de Cobro / Cajeros Distribuidores
    'bdigaran':       'D47',   # Garantías / Colaterales y Avales
    'bdiriesgos':     'D48',   # Riesgos de Crédito / Reportería Regulatoria
    'bdirst':         'D49',   # Claves de Retiro sin Tarjeta
    'bdirech':        'D44',   # Faltantes de Caja / Conciliación Operativa
    # ── Colapsos a dominios existentes (sin identidad propia) ─────────────────
    'bdiservicios':   'D05',   # → bdisac: capa MSW que delega vía EXECUTE PROCEDURE
    'bdicat':         'D11',   # → bdicobranza: fachada XML-RPC del catálogo de mensajes
}

# Nombres canónicos de dominio — ÚNICA fuente de verdad para etiquetas humanas.
# DB_TO_DOMAIN define qué BD pertenece a qué dominio; DOMAIN_NAMES define cómo se llama.
# Al agregar un dominio nuevo: (1) agregar su BD(s) a DB_TO_DOMAIN, (2) agregar su nombre aquí.
# INSERT OR IGNORE en ensure_all_domains() protege los registros D01-D16 ya cargados por load_journeys().
DOMAIN_NAMES: dict[str, str] = {
    # ── D01-D16 (referencia — load_journeys() los inserta primero desde journeys-data.json) ──
    'D01': 'Canal Digital Web',
    'D02': 'Integración y Auth',
    'D03': 'Créditos',
    'D04': 'Cheques y Cuentas',
    'D05': 'Saldos y Ahorro',
    'D06': 'Solicitudes',
    'D07': 'Aclaraciones',
    'D08': 'Pagos y SPEI',
    'D09': 'Mensajería',
    'D10': 'Sucursales y ATM',
    'D11': 'Cobranza',
    'D12': 'Contabilidad',
    'D13': 'TEF',
    'D14': 'Banca Electrónica Institucional',
    'D15': 'AML y Regulatorio',
    'D16': 'Tarjetas',
    # ── D23-D49 (fuente primaria — solo existen aquí) ──────────────────────────
    'D23': 'MIS Sucursales',
    'D26': 'Prospectos',
    'D32': 'Reportes Visa/MC',
    'D34': 'Respaldos DBA',
    'D35': 'Digitalización',
    'D36': 'Reportería CNBV',
    'D37': 'Nómina BPI',
    'D40': 'Banca Internet',
    'D44': 'Conciliación Operativa',
    'D45': 'Premios',
    'D46': 'Oficinas de Cobro',
    'D47': 'Garantías',
    'D48': 'Riesgos de Crédito',
    'D49': 'Retiro sin Tarjeta',
}

# 12 Almas — Capa 2 del Gemelo Cognitivo (keyed by short sp_name)
SOULS_BY_NAME = {
    'sp_cnsif_confirmaejecutivo':    (1,  'GATE DE AUTORIZACIÓN'),
    'sp_registra_evento':            (2,  'EVENT BUS'),
    'cargo_ref':                     (3,  'PRIMITIVA DÉBITO'),
    'abono_ref':                     (4,  'PRIMITIVA CRÉDITO'),
    'sp_split_cadena':               (5,  'INFRAESTRUCTURA SERIALIZACIÓN'),
    'califica_scoring2_cjunk':       (6,  'MOTOR DE DECISIÓN CREDITICIA'),
    'sp_consulta_saldos_general':    (7,  'ORÁCULO POSICIÓN FINANCIERA'),
    'sp_inserta_bitacora_cob':       (8,  'AUDIT LOG COBRANZA'),
    'sp_ctedigital_validaclientes':  (9,  'ORQUESTADOR ONBOARDING DIGITAL'),
    'sp_notif_cambios_portacec':     (10, 'PROCESO BATCH REGULATORIO'),
    'sp_consultadatospiezas_bym3':   (11, 'ORÁCULO DE BIENES'),
    'regex_match':                   (12, 'INFRAESTRUCTURA REGEX'),
}

# SP-level domain overrides — auditoría swarm 2026-07-26
# Prevalece sobre DB_TO_DOMAIN cuando el SP individual pertenece a un dominio diferente al de su DB.
# Formato: 'db:sp_name' → 'DXX'
SP_DOMAIN_OVERRIDE = {
    # D13 (bditef) → D04: imágenes de cheques devueltos — lógica de cheques, no TEF
    'bditef:sp_validaimagencheque':                          'D04',
    'bditef:sp_validaimagencheque_dev':                      'D04',
    'bditef:sp_grabaimageneschqdevueltos':                   'D04',
    'bditef:sp_consultarimageneschqdevueltos':               'D04',
    'bditef:sp_consultageneralcheques':                      'D04',
    'bditef:cons_img_nula1_mx2':                             'D04',
    # D14 (bdibei) → D08: lógica de pago embebida en canal BEI
    'bdibei:sp_pp_consultarcveprog_bei':                     'D08',
    'bdibei:sp_scvalidatransfctaspropias_bei':               'D08',
    # D15/bditarjeta → D12: conciliación contable de tarjetas
    'bditarjeta:sp_tras_archivoshis_con':                    'D12',
    'bditarjeta:sp_tras_movhis_con':                         'D12',
    'bditarjeta:sp_conarchivoresumen_con':                   'D12',
    'bditarjeta:sp_conarchivos_con_pba':                     'D12',
    'bditarjeta:sp_concreing_buscarmovimientointercard_pba': 'D12',
    'bditarjeta:sp_concreing_consdevolucion':                'D12',
    'bditarjeta:sp_concreing_consdevolucion_pba':            'D12',
    'bditarjeta:sp_concreing_consif_pba':                    'D12',
    'bditarjeta:sp_concreing_consultamovpendientes_pba':     'D12',
    'bditarjeta:sp_concreing_consultaparam':                 'D12',
    'bditarjeta:sp_concreing_identificatipoconciliacion_pba':'D12',
    # D09 (bdiedoelec) → D02: gestión de credenciales del portal de estados de cuenta
    'bdiedoelec:sp_ins_user_pass':                           'D02',
    'bdiedoelec:sp_ins_user_pass_web':                       'D02',
    'bdiedoelec:sp_ins_user_paws_bpi':                       'D02',
}

# ── Schema ───────────────────────────────────────────────────────────────────

SCHEMA = '''
PRAGMA journal_mode=WAL;
PRAGMA synchronous=NORMAL;

DROP TABLE IF EXISTS cross_dependencies;
DROP TABLE IF EXISTS etb_l3_fts;
DROP TABLE IF EXISTS sp_capabilities;
DROP TABLE IF EXISTS domain_capabilities;
DROP TABLE IF EXISTS etb_l3;
DROP TABLE IF EXISTS etb_l2;
DROP TABLE IF EXISTS etb_l1;
DROP TABLE IF EXISTS sps_fts;
DROP TABLE IF EXISTS rules_fts;
DROP TABLE IF EXISTS terms_fts;
DROP TABLE IF EXISTS journeys_fts;
DROP TABLE IF EXISTS sp_terms;
DROP TABLE IF EXISTS sp_calls;
DROP TABLE IF EXISTS journeys;
DROP TABLE IF EXISTS external_systems;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS terms;
DROP TABLE IF EXISTS rules;
DROP TABLE IF EXISTS domains;
DROP TABLE IF EXISTS sps;

CREATE TABLE sps (
    id          TEXT PRIMARY KEY,   -- db:sp_name (canónico)
    name        TEXT,               -- sp_name corto (sin db prefix)
    label       TEXT,
    db          TEXT,
    domain      TEXT,
    fan_in      INTEGER DEFAULT 0,
    fan_out     INTEGER DEFAULT 0,
    loc         INTEGER DEFAULT 0,
    biz         TEXT,
    biz_estado  TEXT,
    verdict     TEXT,
    justification TEXT,
    params_n    INTEGER DEFAULT 0,
    tables_n    INTEGER DEFAULT 0,
    calls_n     INTEGER DEFAULT 0,
    rules_n     INTEGER DEFAULT 0,
    authors_n   INTEGER DEFAULT 0,
    is_soul     INTEGER DEFAULT 0,
    soul_rank   INTEGER,
    soul_pattern TEXT,
    weaknesses  INTEGER DEFAULT 0,
    complexity  INTEGER DEFAULT 0,
    -- Clasificación de rol (derivada del call graph + ESB logs)
    sp_role          TEXT,
    -- Métricas de producción (fuente: ESB logs 2026-04-24)
    prod_calls_day   INTEGER,
    prod_calls_hour  REAL,
    prod_calls_sec   REAL,
    prod_errors_day  INTEGER,
    prod_error_rate  REAL,
    prod_channels_n  INTEGER,
    prod_p50_s       REAL,
    prod_p95_s       REAL,
    prod_p99_s       REAL,
    prod_evidence_date TEXT,
    prod_calling_systems TEXT,
    -- Clasificación de patrón estructural (poblada por classify-batch.py)
    sp_archetype    TEXT,   -- patrón estructural universal (todos los SPs)
    batch_archetype TEXT,   -- ídem, alias para compatibilidad y filtros batch
    batch_l2        TEXT
);

CREATE TABLE domains (
    id          TEXT PRIMARY KEY,
    db          TEXT,
    name        TEXT,
    wave        INTEGER,
    color       TEXT,
    sp_count    INTEGER DEFAULT 0,
    reg         TEXT,
    weaknesses  INTEGER DEFAULT 0,
    densidad    REAL DEFAULT 0
);

CREATE TABLE rules (
    id            TEXT PRIMARY KEY,
    tipo          TEXT,
    sub_tipo      TEXT,
    clase         TEXT,
    sp            TEXT,
    db            TEXT,
    domain        TEXT,
    line          INTEGER,
    code          TEXT,
    reg           TEXT,
    riesgo        TEXT,
    business_name TEXT
);

CREATE TABLE terms (
    term    TEXT PRIMARY KEY,
    cat     TEXT,
    meaning TEXT,
    est     TEXT,
    nivel   TEXT,
    scope   TEXT
);

CREATE TABLE external_systems (
    id              TEXT PRIMARY KEY,
    category        TEXT,
    total_endpoints INTEGER DEFAULT 0,
    error_codes     TEXT,      -- JSON array de códigos de error conocidos (nullable)
    failure_rate    REAL,      -- ratio de fallos 0.0-1.0 (nullable — requiere enriquecimiento)
    timeout_ms      INTEGER    -- timeout P95 observado en ms (nullable)
);

CREATE TABLE journeys (
    id           TEXT PRIMARY KEY,
    sp           TEXT,
    domain       TEXT,
    db           TEXT,
    biz          TEXT,
    biz_estado   TEXT,
    journey_type TEXT,
    reg          TEXT,
    fan_out      INTEGER DEFAULT 0,
    loc          INTEGER DEFAULT 0,
    steps        TEXT
);

CREATE TABLE sp_calls (
    from_sp  TEXT NOT NULL,
    to_sp    TEXT NOT NULL,
    cross_db INTEGER DEFAULT 0,
    PRIMARY KEY (from_sp, to_sp)
);

CREATE TABLE sp_terms (
    sp      TEXT NOT NULL,
    term    TEXT NOT NULL,
    source  TEXT,
    PRIMARY KEY (sp, term)
);

CREATE TABLE authors (
    id      TEXT PRIMARY KEY,
    n_sps   INTEGER DEFAULT 0,
    domains TEXT,
    share   REAL DEFAULT 0
);

CREATE TABLE etb_l1 (
    id    TEXT PRIMARY KEY,
    name  TEXT
);

CREATE TABLE etb_l2 (
    id    TEXT PRIMARY KEY,
    l1_id TEXT,
    name  TEXT
);

CREATE TABLE etb_l3 (
    id             TEXT PRIMARY KEY,
    l2_id          TEXT,
    l1_id          TEXT,
    name           TEXT,
    definition     TEXT,
    bcop_status    TEXT,
    bcop_cross_sps TEXT,
    etb_version    TEXT    -- versión del catálogo ETB (ej. "5.0") — detecta desalineación al federar
);

CREATE TABLE domain_capabilities (
    domain_id    TEXT NOT NULL,
    l3_id        TEXT NOT NULL,
    mapping_type TEXT,
    PRIMARY KEY (domain_id, l3_id)
);

CREATE TABLE sp_capabilities (
    sp_id        TEXT NOT NULL,
    l3_id        TEXT NOT NULL,
    mapping_type TEXT,          -- 'primary' | 'secondary' (inherited from domain_capabilities)
    source       TEXT,          -- 'domain' (inherited) | 'override' (manual SP-level)
    PRIMARY KEY (sp_id, l3_id)
);

CREATE INDEX idx_sps_domain   ON sps(domain);
CREATE INDEX idx_sps_name     ON sps(name);
CREATE INDEX idx_sps_fanin    ON sps(fan_in DESC);
CREATE INDEX idx_sps_soul     ON sps(is_soul);
CREATE INDEX idx_sps_role     ON sps(sp_role);
CREATE INDEX idx_calls_from   ON sp_calls(from_sp);
CREATE INDEX idx_calls_to     ON sp_calls(to_sp);
CREATE INDEX idx_rules_sp     ON rules(sp);
CREATE INDEX idx_rules_domain ON rules(domain);
CREATE INDEX idx_rules_reg    ON rules(reg);
CREATE INDEX idx_journeys_dom ON journeys(domain);
CREATE INDEX idx_sp_terms_t   ON sp_terms(term);
CREATE INDEX idx_etb_l3_status ON etb_l3(bcop_status);
CREATE INDEX idx_etb_l3_l2    ON etb_l3(l2_id);
CREATE INDEX idx_dc_domain     ON domain_capabilities(domain_id);
CREATE INDEX idx_dc_l3         ON domain_capabilities(l3_id);
CREATE INDEX idx_sp_cap_sp     ON sp_capabilities(sp_id);
CREATE INDEX idx_sp_cap_l3     ON sp_capabilities(l3_id);

-- Dependencias cross-sistema declaradas desde la perspectiva de ESTE brain.
-- Regla AM: cada cerebro es autónomo — declara sus dependencias en ambas direcciones.
-- direction: outbound = este sistema necesita al otro (lo llama / lee / alimenta)
--            inbound  = el otro sistema depende de este (lo orquesta / lo lee)
CREATE TABLE cross_dependencies (
    id               TEXT PRIMARY KEY,
    other_system     TEXT NOT NULL,     -- el sistema externo (puede no tener brain propio)
    dependency_type  TEXT NOT NULL,     -- orchestrates | calls | reads | writes | feeds | notifies
    direction        TEXT NOT NULL,     -- outbound | inbound (perspectiva de ESTE brain)
    description      TEXT,
    evidence         TEXT,              -- cuantificación concreta
    criticality      TEXT              -- critical | high | medium | low
);

CREATE VIRTUAL TABLE sps_fts USING fts5(
    id, label, biz, justification, soul_pattern,
    content=sps, content_rowid=rowid,
    tokenize='unicode61 remove_diacritics 1'
);

CREATE VIRTUAL TABLE rules_fts USING fts5(
    id, sp, code, reg, riesgo, business_name,
    content=rules, content_rowid=rowid,
    tokenize='unicode61 remove_diacritics 1'
);

CREATE VIRTUAL TABLE terms_fts USING fts5(
    term, meaning, cat,
    content=terms, content_rowid=rowid,
    tokenize='unicode61 remove_diacritics 1'
);

CREATE VIRTUAL TABLE journeys_fts USING fts5(
    id, sp, biz,
    content=journeys, content_rowid=rowid,
    tokenize='unicode61 remove_diacritics 1'
);

CREATE VIRTUAL TABLE etb_l3_fts USING fts5(
    id, name, definition, bcop_status,
    content=etb_l3, content_rowid=rowid,
    tokenize='unicode61 remove_diacritics 1'
);
'''

# ── Loaders ───────────────────────────────────────────────────────────────────

def load_callgraph(conn):
    p = BASE / 'portal' / 'data' / 'callgraph-data.json'
    with open(p) as f:
        cg = json.load(f)

    nodes = cg['graph']['nodes']
    edges = cg['graph']['edges']

    sp_rows = []
    for n in nodes:
        full_id = n['id']                        # db:sp_name
        db = n.get('db', '')
        # short name: strip db prefix if present
        sp_name = full_id[len(db)+1:] if full_id.startswith(db + ':') else full_id
        soul = SOULS_BY_NAME.get(sp_name)
        sp_rows.append((
            full_id, sp_name, n.get('label', sp_name), db,
            SP_DOMAIN_OVERRIDE.get(full_id) or DB_TO_DOMAIN.get(db, ''),
            n.get('fan_in', 0), n.get('fan_out', 0), n.get('loc', 0),
            None, None, None, None,
            0, 0, 0, 0, 0,
            1 if soul else 0,
            soul[0] if soul else None,
            soul[1] if soul else None,
            0, 0
        ))

    conn.executemany('''
        INSERT OR IGNORE INTO sps
        (id,name,label,db,domain,fan_in,fan_out,loc,biz,biz_estado,verdict,justification,
         params_n,tables_n,calls_n,rules_n,authors_n,is_soul,soul_rank,soul_pattern,
         weaknesses,complexity)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    ''', sp_rows)

    edge_rows = [(e['from'], e['to'], 1 if e.get('cross_db') else 0) for e in edges]
    conn.executemany(
        'INSERT OR IGNORE INTO sp_calls (from_sp,to_sp,cross_db) VALUES (?,?,?)',
        edge_rows
    )
    conn.commit()
    print(f'  callgraph    {len(sp_rows):>6,} SPs   {len(edge_rows):>7,} edges')


def load_sp_validations(conn):
    val_files = sorted((BASE / 'knowledge-base').glob('sp-validation-*.json'))
    total, term_rows, new_sps = 0, [], []

    for vf in val_files:
        with open(vf, encoding='utf-8') as f:
            records = json.load(f)
        for r in records:
            sp = r.get('sp', '')
            if not sp:
                continue

            db = r.get('db', '')
            full_id = f'{db}:{sp}' if db else sp
            domain = (SP_DOMAIN_OVERRIDE.get(full_id) or r.get('domain') or DB_TO_DOMAIN.get(db, '')).upper()
            soul = SOULS_BY_NAME.get(sp)

            # Upsert: UPDATE if already in callgraph (same full_id), INSERT otherwise
            conn.execute('''
                INSERT INTO sps (id,name,label,db,domain,fan_in,fan_out,loc,
                    biz,biz_estado,verdict,justification,
                    params_n,tables_n,calls_n,rules_n,authors_n,
                    is_soul,soul_rank,soul_pattern,weaknesses,complexity)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,0,0)
                ON CONFLICT(id) DO UPDATE SET
                    biz         = COALESCE(excluded.biz, biz),
                    biz_estado  = COALESCE(excluded.biz_estado, biz_estado),
                    verdict     = COALESCE(excluded.verdict, verdict),
                    justification = COALESCE(excluded.justification, justification),
                    domain      = COALESCE(NULLIF(domain,''), excluded.domain),
                    params_n    = CASE WHEN excluded.params_n > 0 THEN excluded.params_n ELSE params_n END,
                    tables_n    = CASE WHEN excluded.tables_n > 0 THEN excluded.tables_n ELSE tables_n END,
                    calls_n     = CASE WHEN excluded.calls_n  > 0 THEN excluded.calls_n  ELSE calls_n  END,
                    rules_n     = CASE WHEN excluded.rules_n  > 0 THEN excluded.rules_n  ELSE rules_n  END,
                    authors_n   = CASE WHEN excluded.authors_n > 0 THEN excluded.authors_n ELSE authors_n END
            ''', (
                full_id, sp, sp, db, domain,
                r.get('fan_in', 0), r.get('fan_out', 0), r.get('loc_parsed', 0),
                r.get('biz'), r.get('biz_estado'),
                r.get('verdict'), r.get('justification'),
                r.get('params_n', 0), r.get('tables_n', 0),
                r.get('calls_n', 0), r.get('rules_n', 0), r.get('authors_n', 0),
                1 if soul else 0,
                soul[0] if soul else None,
                soul[1] if soul else None,
            ))

            total += 1

    conn.commit()
    print(f'  validations  {total:>6,} SPs')


def load_journeys(conn):
    with open(BASE / 'portal' / 'data' / 'journeys-data.json') as f:
        jd = json.load(f)

    dom_rows, j_rows = [], []

    for dk, dv in jd.items():
        did = dk.upper()
        dom_rows.append((
            did, dv.get('db', ''), dv.get('name', ''),
            dv.get('wave'), dv.get('color', ''),
            dv.get('sp_count', 0), json.dumps(dv.get('reg', [])),
            0, 0.0
        ))

        for j in dv.get('journeys', []):
            j_rows.append((
                j.get('id', f'{dk}_{j.get("sp","")}'),
                j.get('sp', ''), did, dv.get('db', ''),
                j.get('biz', ''), j.get('biz_estado', ''),
                'orchestrator',
                json.dumps(j.get('reg', [])),
                j.get('fan_out', 0), j.get('loc', 0),
                json.dumps(j.get('steps', []))
            ))

        for j in dv.get('exposed', []):
            j_rows.append((
                j.get('id', f'{dk}_exp_{j.get("sp","")}'),
                j.get('sp', ''), did, dv.get('db', ''),
                j.get('biz', ''), j.get('biz_estado', ''),
                'exposed',
                json.dumps(j.get('reg', [])),
                j.get('fan_out', 0), j.get('loc', 0),
                json.dumps([])
            ))

    conn.executemany('''
        INSERT OR REPLACE INTO domains
        (id,db,name,wave,color,sp_count,reg,weaknesses,densidad)
        VALUES (?,?,?,?,?,?,?,?,?)
    ''', dom_rows)

    conn.executemany('''
        INSERT OR IGNORE INTO journeys
        (id,sp,domain,db,biz,biz_estado,journey_type,reg,fan_out,loc,steps)
        VALUES (?,?,?,?,?,?,?,?,?,?,?)
    ''', j_rows)

    conn.commit()
    print(f'  journeys     {len(dom_rows):>6,} domains {len(j_rows):>6,} journeys')


def ensure_all_domains(conn):
    """Garantiza que cada dominio en DOMAIN_NAMES tiene fila en `domains`.

    Fuente única de verdad:
      - DB_TO_DOMAIN  → qué BD canónica representa al dominio
      - DOMAIN_NAMES  → nombre humano del dominio

    D01-D16 ya los inserta load_journeys() desde journeys-data.json; el INSERT OR IGNORE
    los protege (no sobreescribe). Los dominios D23-D49 los crea esta función.
    Para agregar un dominio nuevo: añadir a DB_TO_DOMAIN + a DOMAIN_NAMES — nada más.
    """
    # canonical_db: domain_id → primera BD en DB_TO_DOMAIN que apunta a ese dominio
    canonical_db: dict[str, str] = {}
    for db, did in DB_TO_DOMAIN.items():
        if did not in canonical_db:
            canonical_db[did] = db

    rows = []
    for did, name in sorted(DOMAIN_NAMES.items()):
        db = canonical_db.get(did, '')
        sp_count = conn.execute(
            'SELECT COUNT(*) FROM sps WHERE domain=?', (did,)
        ).fetchone()[0]
        rows.append((did, db, name, 3, '', sp_count, '[]', 0, 0.0))

    conn.executemany('''
        INSERT OR IGNORE INTO domains
        (id, db, name, wave, color, sp_count, reg, weaknesses, densidad)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', rows)
    conn.commit()
    inserted = conn.execute('SELECT COUNT(*) FROM domains').fetchone()[0]
    new_domains = len(DOMAIN_NAMES) - 16  # D01-D16 vienen de journeys-data.json
    print(f'  domains      {inserted:>6,} total ({new_domains} D17+ garantizados desde DOMAIN_NAMES)')


def load_souls(conn):
    with open(BASE / 'portal' / 'data' / 'souls-data.json') as f:
        sd = json.load(f)

    rows = []
    seen = set()
    for s in sd.get('top_souls', []):
        name = s.get('name', '')
        if name and name not in seen:
            rows.append((name, s.get('n', 0), json.dumps(s.get('doms', [])), 0.0))
            seen.add(name)

    for bf in sd.get('busfactor', []):
        for who in bf.get('who', []):
            if who and who not in seen:
                rows.append((who, 0, json.dumps([bf.get('dom', '')]), bf.get('share', 0)))
                seen.add(who)

    conn.executemany(
        'INSERT OR IGNORE INTO authors (id,n_sps,domains,share) VALUES (?,?,?,?)',
        rows
    )
    conn.commit()
    print(f'  souls        {len(rows):>6,} authors')


def load_integrations(conn):
    with open(BASE / 'portal' / 'data' / 'integrations-data.json') as f:
        ig = json.load(f)

    rows = [
        (
            s['key'], s.get('cat', ''), s.get('total', 0),
            json.dumps(s['error_codes'], ensure_ascii=False) if isinstance(s.get('error_codes'), list) else s.get('error_codes'),
            s.get('failure_rate'),
            s.get('timeout_ms'),
        )
        for s in ig.get('systems', [])
    ]
    conn.executemany(
        'INSERT OR REPLACE INTO external_systems (id,category,total_endpoints,error_codes,failure_rate,timeout_ms) VALUES (?,?,?,?,?,?)',
        rows
    )
    conn.commit()
    print(f'  integrations {len(rows):>6,} external systems')


def load_quality(conn):
    with open(BASE / 'portal' / 'data' / 'quality-data.json') as f:
        qd = json.load(f)

    # Enrich domains
    for d in qd.get('por_dominio', []):
        dom_id = DB_TO_DOMAIN.get(d.get('dom', ''))
        if dom_id:
            conn.execute(
                'UPDATE domains SET weaknesses=?, densidad=? WHERE id=?',
                (d.get('weak', 0), d.get('densidad', 0.0), dom_id)
            )

    # Enrich SPs from hallazgos (list of lists: [sp, db, dom, loc, fanin, fanout, cc, sev, reglas])
    hallazgos = qd.get('hallazgos', [])
    for h in hallazgos:
        if not isinstance(h, (list, tuple)) or len(h) < 8:
            continue
        sp_id, db, dom, loc, fanin, fanout, cc, sev = h[0], h[1], h[2], h[3], h[4], h[5], h[6], h[7]
        conn.execute(
            'UPDATE sps SET weaknesses=weaknesses+1, complexity=? WHERE id=?',
            (cc or 0, sp_id)
        )

    conn.commit()
    print(f'  quality      {len(qd.get("por_dominio",[]))} domains   {len(hallazgos):>6,} hallazgos')


def load_rules(conn):
    with open(BASE / 'portal' / 'data' / 'business-rules-v3.json', encoding='utf-8') as f:
        br = json.load(f)

    rows = []
    for r in br.get('rules', []):
        db = r.get('db', '')
        sp_name = r.get('sp', '')
        full_sp_id = f'{db}:{sp_name}' if db else sp_name
        # reg y riesgo pueden ser listas anidadas — serializar a string
        reg = r.get('reg', '')
        riesgo = r.get('riesgo', '')
        if isinstance(reg, (list, dict)):
            if reg and isinstance(reg[0], (list, tuple)):
                reg = '; '.join(str(x[0]) for x in reg if x)
            else:
                reg = json.dumps(reg, ensure_ascii=False)
        if isinstance(riesgo, (list, dict)):
            if riesgo and isinstance(riesgo[0], (list, tuple)):
                riesgo = '; '.join(str(x[0]) for x in riesgo if x)
            else:
                riesgo = json.dumps(riesgo, ensure_ascii=False)
        rows.append((
            r.get('id', ''), r.get('tipo', ''),
            r.get('categoria', ''),   # sub_tipo: categoría funcional de la regla
            r.get('clase', ''),       # clase: NEGOCIO / INFRAESTRUCTURA / ENSAMBLAJE_REPORTE / PRESENTACION
            full_sp_id, db, DB_TO_DOMAIN.get(db, ''),
            r.get('line', 0), r.get('code', ''),
            reg or '', riesgo or '',
            r.get('business_name', '')
        ))

    # ADR-SPE-AM-010: INSERT siempre toma el valor del JSON (extractor o Layer B+).
    # Los nombres heurísticos antiguos NO se preservan — solo sobreviven los de rule_enrichment_log.
    # Después del INSERT se re-aplica el log para restaurar nombres LLM sin contaminar con heurísticas.
    conn.executemany('''
        INSERT INTO rules (id,tipo,sub_tipo,clase,sp,db,domain,line,code,reg,riesgo,business_name)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
        ON CONFLICT(id) DO UPDATE SET
            tipo          = excluded.tipo,
            sub_tipo      = excluded.sub_tipo,
            clase         = excluded.clase,
            sp            = excluded.sp,
            db            = excluded.db,
            domain        = excluded.domain,
            line          = excluded.line,
            code          = excluded.code,
            reg           = excluded.reg,
            riesgo        = excluded.riesgo,
            business_name = excluded.business_name
    ''', rows)

    # Re-aplicar síntesis LLM desde rule_enrichment_log (persiste entre rebuilds).
    # ADR-SPE-AM-010: SOLO confía en síntesis LLM genuina (method='llm_synthesis').
    #   - Nunca restaura nombres heurísticos (esos ya no viven en el log tras la purga).
    #   - Excluye defensivamente cualquier valor con firma de código crudo (÷).
    #   - SOLO llena reglas vacías — no sobreescribe nombres del JSON (Layer B+).
    try:
        log_count = conn.execute("""
            UPDATE rules
            SET business_name = (
                SELECT new_value
                FROM rule_enrichment_log
                WHERE rule_id = rules.id
                  AND field = 'business_name'
                  AND method IN ('llm_synthesis','llm_synthesis_source_read')
                  AND new_value IS NOT NULL AND new_value != ''
                  AND new_value NOT LIKE '%÷%'
                ORDER BY
                  CASE method WHEN 'llm_synthesis_source_read' THEN 0 ELSE 1 END,
                  timestamp DESC
                LIMIT 1
            )
            WHERE (rules.business_name IS NULL OR rules.business_name = '')
              AND EXISTS (
                SELECT 1 FROM rule_enrichment_log
                WHERE rule_id = rules.id
                  AND field = 'business_name'
                  AND method IN ('llm_synthesis','llm_synthesis_source_read')
                  AND new_value IS NOT NULL AND new_value != ''
                  AND new_value NOT LIKE '%÷%'
            )
        """).rowcount
        if log_count:
            print(f'  enrichment   {log_count:>6,} names LLM restaurados desde rule_enrichment_log')

        # Prioridad de fuente: la síntesis que LEYÓ CÓDIGO FUENTE (source_read) es autoritativa
        # y SOBREESCRIBE incluso nombres del overlay (name-overrides-ai.json) — el overlay puede
        # contener nombres pobres con prefijo de variable que la lectura de fuente ya corrigió.
        override_count = conn.execute("""
            UPDATE rules
            SET business_name = (
                SELECT new_value
                FROM rule_enrichment_log
                WHERE rule_id = rules.id
                  AND field = 'business_name'
                  AND method = 'llm_synthesis_source_read'
                  AND new_value IS NOT NULL AND new_value != ''
                  AND new_value NOT LIKE '%÷%'
                ORDER BY timestamp DESC
                LIMIT 1
            )
            WHERE EXISTS (
                SELECT 1 FROM rule_enrichment_log
                WHERE rule_id = rules.id
                  AND field = 'business_name'
                  AND method = 'llm_synthesis_source_read'
                  AND new_value IS NOT NULL AND new_value != ''
                  AND new_value NOT LIKE '%÷%'
            )
        """).rowcount
        if override_count:
            print(f'  enrichment   {override_count:>6,} names source_read (autoritativos sobre overlay)')
    except Exception:
        pass  # rule_enrichment_log aún no existe — primer build limpio

    # Normalización: el sufijo "(regulatorio: ...)" es redundante con la columna reg
    # (el portal ya muestra los reguladores por separado). Se elimina del nombre.
    conn.execute(r"""
        UPDATE rules
        SET business_name = TRIM(
            substr(business_name, 1, instr(business_name, '(regulatorio:') - 1)
        )
        WHERE business_name LIKE '%(regulatorio:%'
    """)

    # Normalización: eliminar fugas de nombre técnico (BD/SP) del business_name.
    # El nombre de negocio no debe contener 'bdixxx' ni 'sp_xxx' — son artefactos del código.
    import re as _re_norm
    _tech_rows = conn.execute(
        "SELECT id, business_name FROM rules "
        "WHERE business_name GLOB '*bdi[a-z]*' OR business_name GLOB '*sp_*'"
    ).fetchall()
    _tech_fixed = []
    for _rid, _bn in _tech_rows:
        _new = _bn
        _new = _re_norm.sub(r"\s*\((?:bdi[a-z0-9_]+|sp_[a-z0-9_]+)\)", "", _new)   # (bdinvers) / (sp_x)
        _new = _re_norm.sub(r"\s+en\s+bdi[a-z0-9_]+", "", _new)                     # en bdisolic
        _new = _re_norm.sub(r"\s+del\s+SP\s+sp_[a-z0-9_]+", "", _new, flags=_re_norm.I)  # del SP sp_x
        _new = _re_norm.sub(r"\s+de\s+bdi[a-z0-9_]+", "", _new)                     # de bdicobranza
        _new = _re_norm.sub(r"\s{2,}", " ", _new).strip(" .,—-")
        if _new and _new != _bn:
            _tech_fixed.append((_new, _rid))
    if _tech_fixed:
        conn.executemany("UPDATE rules SET business_name=? WHERE id=?", _tech_fixed)
        print(f'  normalize    {len(_tech_fixed):>6,} nombres — fuga técnica (bdi/sp_) removida')

    # Capitalización: toda descripción visible inicia con mayúscula (feedback global).
    _cap_rows = conn.execute(
        "SELECT id, business_name FROM rules WHERE business_name != '' "
        "AND substr(business_name,1,1) BETWEEN 'a' AND 'z'"
    ).fetchall()
    _cap_fixed = [(bn[0].upper() + bn[1:], rid) for rid, bn in _cap_rows]
    if _cap_fixed:
        conn.executemany("UPDATE rules SET business_name=? WHERE id=?", _cap_fixed)
        print(f'  normalize    {len(_cap_fixed):>6,} nombres — capitalizada inicial')

    conn.commit()
    print(f'  rules        {len(rows):>6,} business rules')


def load_vocabulary(conn):
    with open(BASE / 'knowledge-base' / 'vocabulary-inventory.json', encoding='utf-8') as f:
        vi = json.load(f)

    rows = []
    for a in vi.get('atomos', []):
        rows.append((
            a.get('term', ''), a.get('cat', ''), a.get('mean', ''),
            a.get('est', ''), a.get('nivel', ''), a.get('scope', '')
        ))

    conn.executemany('''
        INSERT OR REPLACE INTO terms (term,cat,meaning,est,nivel,scope)
        VALUES (?,?,?,?,?,?)
    ''', rows)
    conn.commit()
    print(f'  vocabulary   {len(rows):>6,} terms')


def load_etb_capabilities(conn):
    p = BASE / 'knowledge-base' / 'ontology' / 'etb-capabilities.json'
    if not p.exists():
        print('  etb          [skipped — etb-capabilities.json not found]')
        return

    with open(p, encoding='utf-8') as f:
        etb = json.load(f)

    caps = etb.get('capabilities', [])
    etb_version = etb.get('meta', {}).get('version', 'unknown')
    l1_seen, l2_seen = {}, {}
    l3_rows, dc_rows = [], []

    for c in caps:
        l1_id = c['l1_id']
        if l1_id not in l1_seen:
            l1_seen[l1_id] = c['l1']
        l2_id = c['l2_id']
        if l2_id not in l2_seen:
            l2_seen[l2_id] = (c['l1_id'], c['l2'])
        l3_rows.append((
            c['l3_id'], c['l2_id'], c['l1_id'],
            c['l3'], c.get('definition', ''),
            c['bcop_status'],
            json.dumps(c.get('bcop_cross_sps', []), ensure_ascii=False),
            etb_version,
        ))
        for dom_id, mtype in c.get('bcop_domain_mapping', {}).items():
            dc_rows.append((dom_id, c['l3_id'], mtype))

    l1_rows = list(l1_seen.items())
    l2_rows = [(l2_id, l1_id, name) for l2_id, (l1_id, name) in l2_seen.items()]

    conn.executemany('INSERT OR REPLACE INTO etb_l1 (id,name) VALUES (?,?)', l1_rows)
    conn.executemany('INSERT OR REPLACE INTO etb_l2 (id,l1_id,name) VALUES (?,?,?)', l2_rows)
    conn.executemany('''
        INSERT OR REPLACE INTO etb_l3
        (id,l2_id,l1_id,name,definition,bcop_status,bcop_cross_sps,etb_version)
        VALUES (?,?,?,?,?,?,?,?)
    ''', l3_rows)
    conn.executemany(
        'INSERT OR IGNORE INTO domain_capabilities (domain_id,l3_id,mapping_type) VALUES (?,?,?)',
        dc_rows
    )
    conn.commit()

    covered = sum(1 for c in caps if c['bcop_status'] == 'COVERED')
    cross   = sum(1 for c in caps if c['bcop_status'] == 'CROSS_CUTTING')
    pct     = round(100 * (covered + cross) / len(caps), 1)
    print(f'  etb          {len(l1_rows):>3} L1  {len(l2_rows):>3} L2  {len(l3_rows):>4} L3'
          f'   covered {covered}+{cross}cc/{len(l3_rows)} ({pct}%)')


def build_sp_capabilities(conn):
    """
    Deriva sp_capabilities heredando de domain_capabilities.
    Cada SP recibe los L3 caps de su dominio con source='domain'.
    Soporte futuro para source='override' (asignación manual por SP).
    """
    conn.execute('''
        INSERT OR IGNORE INTO sp_capabilities (sp_id, l3_id, mapping_type, source)
        SELECT s.id, dc.l3_id, dc.mapping_type, 'domain'
        FROM sps s
        JOIN domain_capabilities dc ON s.domain = dc.domain_id
        WHERE s.domain IS NOT NULL AND s.domain != ''
    ''')
    conn.commit()
    n         = conn.execute('SELECT COUNT(*) FROM sp_capabilities').fetchone()[0]
    sps_cov   = conn.execute('SELECT COUNT(DISTINCT sp_id) FROM sp_capabilities').fetchone()[0]
    l3_cov    = conn.execute('SELECT COUNT(DISTINCT l3_id) FROM sp_capabilities').fetchone()[0]
    print(f'  sp_capabilities {n:>7,} links   {sps_cov:>6,} SPs cubiertos   {l3_cov} L3 distintas')


def merge_fine_capabilities(conn):
    """
    Fusiona sp_capability_map → sp_capabilities con source='override'.
    Solo inserta asignaciones genuinamente nuevas (no cubiertas ya por domain-inheritance).
    Filtra entradas con l3_id='shared' (categoría sintética del fine-mapping, no ETB real).
    Umbral mínimo de confianza: 0.35.
    Requiere que sp_capability_map exista (creada por build-sp-fine-mapping.py).
    """
    has_map = conn.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='sp_capability_map'"
    ).fetchone()
    if not has_map:
        print('  merge_fine_capabilities: sp_capability_map no existe — omitido')
        return

    n_before = conn.execute('SELECT COUNT(*) FROM sp_capabilities').fetchone()[0]
    conn.execute('''
        INSERT OR IGNORE INTO sp_capabilities (sp_id, l3_id, mapping_type, source)
        SELECT scm.sp_id, scm.l3_id, 'override', 'override'
        FROM sp_capability_map scm
        WHERE scm.confidence >= 0.35
          AND scm.l3_id != 'shared'
          AND NOT EXISTS (
              SELECT 1 FROM sp_capabilities sc
              WHERE sc.sp_id = scm.sp_id AND sc.l3_id = scm.l3_id
          )
    ''')
    conn.commit()
    n_after    = conn.execute('SELECT COUNT(*) FROM sp_capabilities').fetchone()[0]
    overrides  = conn.execute("SELECT COUNT(*) FROM sp_capabilities WHERE source='override'").fetchone()[0]
    l3_after   = conn.execute('SELECT COUNT(DISTINCT l3_id) FROM sp_capabilities').fetchone()[0]
    print(f'  merge fine-map +{n_after - n_before:,} overrides   total {n_after:,} links   {l3_after} L3 distintas   ({overrides} overrides)')


def mark_ctm_hints(conn):
    """
    Marca batch_archetype='CTM_HINT' para SPs que aparecen en SP hints del CTM brain
    y cumplen criterio de alta confianza: fan_in=0 + sp_archetype batch/batch_orchestrator.
    Solo corre si el CTM brain.db existe (no bloquea el build si no está).
    Ortogonal a CTM_ENTRY (vía nombre exacto SP_ en job).
    """
    ctm_path = BASE.parent.parent / "systems" / "integration" / "ControlM" / "digital-brain" / "brain.db"
    if not ctm_path.exists():
        print(f'  ctm_hints    [SKIP — CTM brain.db no encontrado en {ctm_path}]')
        return

    conn.execute(f"ATTACH DATABASE '{ctm_path}' AS ctm")

    n = conn.execute("""
        UPDATE sps
        SET batch_archetype = 'CTM_HINT'
        WHERE id IN (
            SELECT DISTINCT s.id
            FROM ctm.sp_hints h
            JOIN sps s ON (
                s.name = h.sp_name_hint
                OR s.name = REPLACE(h.sp_name_hint, '_pro', '')
            )
            WHERE h.sp_name_hint LIKE 'sp_%'
              AND s.fan_in = 0
              AND s.sp_archetype IN ('batch', 'batch_orchestrator')
              AND (s.batch_archetype IS NULL OR s.batch_archetype NOT IN ('CTM_ENTRY', 'CTM_HINT'))
        )
    """).rowcount
    conn.commit()
    conn.execute("DETACH DATABASE ctm")
    print(f'  ctm_hints    {n:>6,} SPs marcados CTM_HINT (alta confianza — fan_in=0 + match en CTM sp_hints)')


def classify_sp_archetypes(conn):
    """
    Puebla sp_archetype (patrón estructural) derivado de fan_in/fan_out.
    Ortogonal a sp_role (topología ESB) — no lo modifica.
    """
    rows = conn.execute('SELECT id, fan_in, fan_out FROM sps').fetchall()

    def _arch(fi, fo):
        fi, fo = fi or 0, fo or 0
        if fo > 50:                  return 'super_orchestrator'
        if fo > 5  and fi > 0:       return 'orchestrator'
        if 1 <= fo <= 5 and fi > 0:  return 'implementation'
        if fo == 0 and fi > 0:       return 'leaf'
        if fo > 5  and fi == 0:      return 'batch_orchestrator'
        return 'batch'

    updates = [(_arch(fi, fo), sp_id) for sp_id, fi, fo in rows]
    conn.executemany('UPDATE sps SET sp_archetype=? WHERE id=?', updates)
    conn.commit()

    from collections import Counter
    dist = Counter(u[0] for u in updates)
    total = len(updates)
    print(f'  sp_archetype {total:>6,} SPs clasificados:')
    for arch in ['super_orchestrator','batch_orchestrator','orchestrator','implementation','leaf','batch']:
        n = dist.get(arch, 0)
        if n:
            print(f'               {arch:<25} {n:>6,}  ({n/total*100:.1f}%)')


def classify_sps(conn):
    """
    Asigna sp_role a cada SP derivado del call graph + journeys-data.json + ESB logs.

    Roles:
      entry_point          — llamado sólo desde canales externos (app/ESB), sin callers SPL.
                             Evidencia: triggered_by=[{dom:'app',n:0}] o ausencia en sp_calls como callee.
      cross_domain_primitive — primitiva de negocio llamada desde múltiples dominios internos.
                             Evidencia: triggered_by con dominios internos con n>0.
      shared_service       — utility cross-domain (event bus, validators, audit logs).
                             Evidencia: journey_type='exposed' en journeys-data.json.
      esb_exposed          — SP medido en logs ESB de producción pero no catalogado en journeys.
                             Evidencia: aparece en sp-frequency.json, 0 filas como callee en sp_calls.
      internal             — lógica SPL interna; nunca llamado desde canales externos.

    is_soul (flag existente) es ortogonal al rol — un soul puede ser entry_point, cross_domain_primitive
    o shared_service simultáneamente.
    """
    with open(BASE / 'portal' / 'data' / 'journeys-data.json', encoding='utf-8') as f:
        jd = json.load(f)

    freq_path = BASE / 'output' / 'log-analysis' / 'sp-frequency.json'
    with open(freq_path, encoding='utf-8') as f:
        freq_data = json.load(f)
    esb_sps = {row['sp'] for row in freq_data}

    role_map = {}

    for dv in jd.values():
        for j in dv.get('journeys', []):
            sp = j.get('sp', '')
            if not sp:
                continue
            tb = j.get('triggered_by', [])
            has_internal = any(
                t.get('dom', 'app') not in ('app', '') and t.get('n', 0) > 0
                for t in tb
            )
            role_map[sp] = 'cross_domain_primitive' if has_internal else 'entry_point'

        for j in dv.get('exposed', []):
            sp = j.get('sp', '')
            if sp:
                role_map[sp] = 'shared_service'

    # SPs en ESB que no están en journeys → esb_exposed
    for sp in esb_sps:
        if sp not in role_map:
            role_map[sp] = 'esb_exposed'

    updates = [(role_map.get(name, 'internal'), sp_id)
               for sp_id, name in conn.execute('SELECT id, name FROM sps')]
    conn.executemany('UPDATE sps SET sp_role=? WHERE id=?', updates)
    conn.commit()

    counts = {}
    for role, n in conn.execute('SELECT sp_role, COUNT(*) FROM sps GROUP BY sp_role ORDER BY 2 DESC'):
        counts[role] = n
    total = sum(counts.values())
    print(f'  classify     {total:>6,} SPs clasificados:')
    for role, n in sorted(counts.items(), key=lambda x: -x[1]):
        print(f'               {role:<25} {n:>6,}')


def load_prod_metrics(conn):
    """
    Enriquece sps con métricas de producción extraídas de los logs ESB (2026-04-24):
    - prod_calls_day / hour / sec — volumen transaccional
    - prod_errors_day, prod_error_rate — calidad de servicio
    - prod_channels_n — diversidad de canales ESB
    - prod_p50_s, prod_p95_s, prod_p99_s — latencia individual (v2) o flujo (v1)
    - prod_calling_systems — sistemas ESB que invocan el SP (JSON array)
    Fuentes: sp-frequency.json + latency-individual-by-sp.json (v2) + latency-by-sp.json (v1)
    """
    freq_path  = BASE / 'output' / 'log-analysis' / 'sp-frequency.json'
    lat_v2_path = BASE / 'output' / 'log-analysis' / 'latency-individual-by-sp.json'
    lat_v1_path = BASE / 'output' / 'log-analysis' / 'latency-by-sp.json'

    with open(freq_path, encoding='utf-8') as f:
        freq_data = json.load(f)
    with open(lat_v2_path, encoding='utf-8') as f:
        lat_v2 = json.load(f)
    lat_v1 = {}
    if lat_v1_path.exists():
        with open(lat_v1_path, encoding='utf-8') as f:
            lat_v1 = json.load(f)

    evidence_date = '2026-04-24'
    SECS_DAY = 86400.0

    updates = 0
    for row in freq_data:
        sp = row['sp']
        calls = row.get('calls', 0) or 0
        errors = row.get('errors', 0) or 0
        err_rate = row.get('error_rate', 0.0) or 0.0
        sistemas = [s for s in row.get('sistemas', []) if s and s != '-']
        channels_n = len(sistemas)

        lat = lat_v2.get(sp) or lat_v1.get(sp)
        p50 = lat.get('p50') if lat else None
        p95 = lat.get('p95') if lat else None
        p99 = lat.get('p99') if lat else None

        conn.execute('''
            UPDATE sps SET
                prod_calls_day        = ?,
                prod_calls_hour       = ?,
                prod_calls_sec        = ?,
                prod_errors_day       = ?,
                prod_error_rate       = ?,
                prod_channels_n       = ?,
                prod_p50_s            = ?,
                prod_p95_s            = ?,
                prod_p99_s            = ?,
                prod_evidence_date    = ?,
                prod_calling_systems  = ?
            WHERE name = ?
        ''', (
            calls,
            round(calls / 24.0, 2) if calls else None,
            round(calls / SECS_DAY, 4) if calls else None,
            errors,
            err_rate,
            channels_n if channels_n else None,
            p50, p95, p99,
            evidence_date,
            json.dumps(sistemas, ensure_ascii=False) if sistemas else None,
            sp
        ))
        updates += 1

    conn.commit()
    measured_lat = conn.execute('SELECT COUNT(*) FROM sps WHERE prod_p95_s IS NOT NULL').fetchone()[0]
    measured_vol = conn.execute('SELECT COUNT(*) FROM sps WHERE prod_calls_day > 0').fetchone()[0]
    print(f'  prod_metrics {updates:>6,} SPs con volumen  |  {measured_lat:>4} con latencia  [{evidence_date}]')


def build_sp_terms(conn):
    """
    Construye sp_terms enlazando SPs con el vocabulario controlado.
    Para cada SP, tokeniza su nombre y busca coincidencias exactas con terms.
    """
    # Carga todos los términos conocidos
    known = {
        row[0]
        for row in conn.execute('SELECT term FROM terms').fetchall()
    }

    # Para cada SP, tokeniza su nombre corto (name) y cruza con vocabulario
    sp_rows = conn.execute('SELECT id, name FROM sps').fetchall()
    term_rows = []
    for (sp_id, sp_name) in sp_rows:
        if not sp_name:
            continue
        tokens = re.split(r'[_\s]+', sp_name.lower())
        for tok in tokens:
            tok = tok.strip()
            if tok and tok in known:
                term_rows.append((sp_id, tok, 'nombre'))

    conn.executemany(
        'INSERT OR IGNORE INTO sp_terms (sp,term,source) VALUES (?,?,?)',
        term_rows
    )
    conn.commit()
    linked = conn.execute('SELECT COUNT(DISTINCT sp) FROM sp_terms').fetchone()[0]
    print(f'  sp_terms     {len(term_rows):>6,} links   {linked:>6,} SPs con vocab')


def build_fts(conn):
    conn.execute("INSERT INTO sps_fts(sps_fts) VALUES('rebuild')")
    conn.execute("INSERT INTO rules_fts(rules_fts) VALUES('rebuild')")
    conn.execute("INSERT INTO terms_fts(terms_fts) VALUES('rebuild')")
    conn.execute("INSERT INTO journeys_fts(journeys_fts) VALUES('rebuild')")
    conn.execute("INSERT INTO etb_l3_fts(etb_l3_fts) VALUES('rebuild')")
    conn.commit()
    print('  FTS5 indexes rebuilt')


def print_summary(conn):
    tables = ['sps', 'domains', 'rules', 'terms', 'external_systems',
              'journeys', 'sp_calls', 'sp_terms', 'authors', 'sp_capabilities']
    print('\n── Entidades en brain.db ──────────────────────────')
    for t in tables:
        n = conn.execute(f'SELECT COUNT(*) FROM {t}').fetchone()[0]
        print(f'  {t:<20} {n:>8,}')
    souls  = conn.execute('SELECT COUNT(*) FROM sps WHERE is_soul=1').fetchone()[0]
    linked = conn.execute('SELECT COUNT(DISTINCT sp) FROM sp_terms').fetchone()[0]
    print(f'\n  {"almas (souls)":<20} {souls:>8,}')
    print(f'  {"SPs con vocab":<20} {linked:>8,}')

    print(f'\n── SP Roles ────────────────────────────────────────')
    for role, n in conn.execute(
        'SELECT sp_role, COUNT(*) FROM sps GROUP BY sp_role ORDER BY 2 DESC'
    ):
        print(f'  {str(role):<25} {n:>8,}')

    print(f'\n── Producción (ESB 2026-04-24) ────────────────────')
    vol  = conn.execute('SELECT COUNT(*) FROM sps WHERE prod_calls_day > 0').fetchone()[0]
    lat  = conn.execute('SELECT COUNT(*) FROM sps WHERE prod_p95_s IS NOT NULL').fetchone()[0]
    top  = conn.execute('SELECT name, prod_calls_day FROM sps WHERE prod_calls_day > 0 ORDER BY prod_calls_day DESC LIMIT 3').fetchall()
    p95h = conn.execute('SELECT name, prod_p95_s FROM sps WHERE prod_p95_s > 0 ORDER BY prod_p95_s DESC LIMIT 3').fetchall()
    print(f'  {"SPs con volumen":<25} {vol:>8,}')
    print(f'  {"SPs con latencia":<25} {lat:>8,}')
    print(f'  Top 3 por volumen: {[f"{r[0]}({r[1]:,})" for r in top]}')
    print(f'  Top 3 por P95:     {[f"{r[0]}({r[1]}s)" for r in p95h]}')

    l3_n  = conn.execute('SELECT COUNT(*) FROM etb_l3').fetchone()[0]
    if l3_n:
        cov = conn.execute("SELECT COUNT(*) FROM etb_l3 WHERE bcop_status='COVERED'").fetchone()[0]
        cc  = conn.execute("SELECT COUNT(*) FROM etb_l3 WHERE bcop_status='CROSS_CUTTING'").fetchone()[0]
        dc  = conn.execute('SELECT COUNT(*) FROM domain_capabilities').fetchone()[0]
        print(f'\n── ETB v5.0 Ontology ──────────────────────────────')
        print(f'  {"etb_l1":<20} {conn.execute("SELECT COUNT(*) FROM etb_l1").fetchone()[0]:>8,}')
        print(f'  {"etb_l2":<20} {conn.execute("SELECT COUNT(*) FROM etb_l2").fetchone()[0]:>8,}')
        print(f'  {"etb_l3":<20} {l3_n:>8,}')
        print(f'  {"domain_capabilities":<20} {dc:>8,}')
        print(f'  {"COVERED":<20} {cov:>8,}  ({round(100*cov/l3_n,1)}%)')
        print(f'  {"CROSS_CUTTING":<20} {cc:>8,}  ({round(100*cc/l3_n,1)}%)')


def seed_cross_dependencies(conn):
    """Declara las dependencias cross-sistema desde la perspectiva de ESTE brain (Informix/PISA).
    Regla AM: cada cerebro es autónomo — documenta su lado de la relación.
    bank-brain agrega la vista global; si desconectas este brain, sigue sabiendo que CTM lo orquesta.
    """
    deps = [
        # INBOUND: Control-M nos orquesta (CTM invoca nuestros SPs en ventanas batch).
        ("pisa-controlm-batch",
         "controlm", "orchestrates", "inbound",
         "Control-M invoca los SPs batch de Informix en ventanas programadas (cierre de día, "
         "liquidación nocturna, conciliación SPEI, reportería regulatoria). "
         "La lógica de negocio vive aquí; el cuándo y el orden viven en Control-M.",
         "87 SPs confirmados batch_archetype=CTM_ENTRY (load-ctm-to-brain.py 2026-08-12). "
         "1,358 jobs en ctm_jobs; ~1,271 via shell scripts pendientes de mapear.",
         "critical"),
        # INBOUND: MuleSoft/ESB nos llama vía los endpoints expuestos (journeys).
        ("pisa-mulesoft-esb",
         "mulesoft", "calls", "inbound",
         "MuleSoft/ESB invoca los SPs de Informix expuestos como endpoints (bdicnweb, bdinteg). "
         "Los 166 journeys online son el catálogo de endpoints accesibles vía ESB.",
         "166 journeys on-line; 552 SPs con métricas de producción (ESB logs 2026-04-24). "
         "D01 bdicnweb: punto de entrada principal del ESB.",
         "critical"),
        # INBOUND: e-global (autorizador externo) nos llama para autorización de pagos.
        ("pisa-eglobal-auth",
         "e-global", "calls", "inbound",
         "e-global (capa de autorización externa) invoca SPs de autorización de pagos "
         "en Informix (dominio D08 SPEI + D16 Tarjetas). Códigos ESB sin contexto son "
         "probablemente errores de autorización e-global.",
         "Evidenciado en logs ESB 2026-04-24; análisis en portal/incidents/frontier-latency.html.",
         "critical"),
        # OUTBOUND: PISA envía archivos a Banxico (SPEI liquidación nocturna).
        ("pisa-banxico-spei",
         "banxico", "feeds", "outbound",
         "Informix genera archivos de liquidación SPEI (D08) que se entregan a la red Banxico "
         "en el proceso de cierre de día. RTO 15 min Banxico.",
         "Dominio D08 — SPs de cierre SPEI generan archivos CECOBAN. "
         "627 reglas D13-D16 con triaje regulatorio completo.",
         "critical"),
        # OUTBOUND: PISA alimenta a SmartVista con reportería de tarjetas.
        ("pisa-smartvista-reporteria",
         "smartvista", "feeds", "outbound",
         "Informix genera reportería batch de tarjetas (D32 — Visa/Mastercard) "
         "que SmartVista consume para reconciliación nocturna.",
         "Dominio D32 — bdireports ~reportes nocturnos Visa/MC. "
         "migration_fate=replicate (12 SPs, 133 reglas).",
         "high"),
        # INBOUND: Atlas nos lee para extracción de migración.
        ("pisa-atlas-extraccion",
         "atlas", "reads", "inbound",
         "Atlas extrae datos históricos de Informix vía JDBC y archivos flat para la migración "
         "a los sistemas target (Transact, Apolo, SmartVista). Compite con ventana batch.",
         "11,391 SPs en scope; migration_fate cubriendo todos los dominios D01-D49.",
         "high"),
        # OUTBOUND: PISA alimenta reportería regulatoria CNBV.
        ("pisa-cnbv-reporteria",
         "cnbv", "feeds", "outbound",
         "Informix genera reportería regulatoria automatizada para CNBV (D36 bdirepaut). "
         "Incluye Serie R, CUB Anexo 33-36, reportes PLD/LIDE.",
         "Dominio D36 bdirepaut — regulatoria CNBV. D15 LIDE 100% reg cobertura post-triaje.",
         "high"),
        # OUTBOUND: PISA genera señales AML que PLD/Minds consume (D15).
        ("pisa-pld-aml-signals",
         "pld", "feeds", "outbound",
         "Informix (D15 bdilide/bdiauditor/bdisitesp) genera señales batch de prevención de "
         "lavado de dinero (AML) que el sistema PLD/Minds consume para análisis y reporte "
         "regulatorio LFPIORPI/UIF. Los SPs generan los datos; PLD aplica los modelos de riesgo.",
         "Dominio D15 — bdilide (LIDE), bdiauditor (listas negras), bdisitesp (PLD core). "
         "208 jobs CTM en servidores PLD confirmados en inventario 2026-08-12.",
         "high"),
        # INBOUND: DataStage lee de PISA para integración Unity Transact (UTR-UNITY_TRANSACT).
        ("pisa-datastage-transact",
         "datastage", "reads", "inbound",
         "DataStage tiene una carpeta UTR-UNITY_TRANSACT en producción (inventario CTM 2026-08-12) "
         "lo que indica que ya extrae datos de Informix para la integración con Unity/Transact. "
         "DataStage opera como capa ETL entre el core Informix y el sistema Transact destino, "
         "complementando o reemplazando la función de Atlas en este flujo.",
         "Hallazgo CTM 2026-08-12: carpeta UTR-UNITY_TRANSACT en host datastage "
         "(dccinfsph2/dccinfsphe2/dccinfsph1). Relación confirmada por evidencia operativa.",
         "high"),
    ]
    conn.executemany(
        """INSERT OR REPLACE INTO cross_dependencies
           (id, other_system, dependency_type, direction, description, evidence, criticality)
           VALUES (?,?,?,?,?,?,?)""",
        deps
    )
    conn.commit()
    n = conn.execute('SELECT COUNT(*) FROM cross_dependencies').fetchone()[0]
    print(f'  cross_dependencies {n:>5} dependencias declaradas')


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    print(f'Informix Digital Brain — build pipeline')
    print(f'Base:  {BASE}')
    print(f'Output:{DB_PATH}\n')

    conn = sqlite3.connect(DB_PATH)

    print('Aplicando schema...')
    conn.executescript(SCHEMA)
    print('Schema OK\n')

    print('Cargando fuentes:')
    load_callgraph(conn)
    load_sp_validations(conn)
    load_journeys(conn)
    ensure_all_domains(conn)
    load_souls(conn)
    load_integrations(conn)
    load_quality(conn)
    load_rules(conn)
    load_vocabulary(conn)
    load_etb_capabilities(conn)
    build_sp_capabilities(conn)
    merge_fine_capabilities(conn)
    classify_sps(conn)
    classify_sp_archetypes(conn)
    mark_ctm_hints(conn)
    load_prod_metrics(conn)
    build_sp_terms(conn)
    seed_cross_dependencies(conn)

    print('\nConstruyendo índices FTS5:')
    build_fts(conn)

    print_summary(conn)
    conn.close()
    print(f'\n✅  Digital Brain listo → digital-brain/brain.db')


if __name__ == '__main__':
    main()
