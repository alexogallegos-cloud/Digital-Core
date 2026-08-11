#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-brain.py — GENCore Digital Brain · Pipeline de construcción
Lee los artefactos generados (objects-inventory.json, vocab-gentera.json,
rules-gentera.json) y construye brain.db (SQLite).

No modifica ningún archivo fuente.

Uso: python digital-brain/build-brain.py
     (ejecutar desde GENCore/ o desde digital-brain/)

GENCore · SPE-AM-002 · Gemelo Cognitivo SAP ABAP
"""

import json
import sqlite3
import re
import sys
from pathlib import Path
from collections import Counter

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

# ── Rutas ────────────────────────────────────────────────────────────────────

SCRIPT_DIR = Path(__file__).resolve().parent
BASE       = SCRIPT_DIR.parent           # GENCore/
DB_PATH    = SCRIPT_DIR / 'brain.db'

INV_FILE   = BASE / 'objects-inventory.json'
VOCAB_FILE = BASE / 'vocab-gentera.json'
RULES_FILE = BASE / 'rules-gentera.json'

# ── Mapeo de dominios BIAN para Gentera ───────────────────────────────────────

# Mapeado desde tokens en nombre/tipo del objeto
DOMAIN_PATTERNS = [
    ('MICROCREDITO',   re.compile(r'credit|credito|prestamo|cartera|ciclo|cobranza|mora|cuota', re.I)),
    ('CLIENTE',        re.compile(r'cliente|cte|persona|party|socio|promotor|grupo', re.I)),
    ('PAGOS',          re.compile(r'pago|transferen|abono|cargo|spei|codi|dispersi|remesa', re.I)),
    ('CONTABILIDAD',   re.compile(r'contab|poliza|asiento|balance|cierre|devengo|fiscal', re.I)),
    ('CUENTAS',        re.compile(r'cuenta|saldo|deposito|captacion|ahorro', re.I)),
    ('RIESGO',         re.compile(r'ifrs|pld|aml|riesgo|audit|regulat|cnbv', re.I)),
    ('CANALES',        re.compile(r'canal|web|movil|cajero|atm|sucursal|app|banca', re.I)),
    ('PARAMETROS',     re.compile(r'tvarvc|tvarv|param|config|variable|event|flag|selecci', re.I)),
    ('SERVICIOS',      re.compile(r'service|helper|exception|message|log|msg|util|base', re.I)),
]


def detect_domain(obj_name: str, obj_tipo: str, metodos: list[str]) -> str:
    text = ' '.join([obj_name] + metodos).lower()
    for domain_id, pat in DOMAIN_PATTERNS:
        if pat.search(text):
            return domain_id
    return 'TRANSVERSAL'


# ── Módulo SAP ────────────────────────────────────────────────────────────────

MODULE_PATTERNS = [
    ('SAP FI',             re.compile(r'bkpf|bseg|fi\b|contab|asiento|poliza|devengo', re.I)),
    ('SAP CO',             re.compile(r'coas|cosp|co\b|costo|centro|rentabilidad', re.I)),
    ('SAP SD',             re.compile(r'vbak|vbap|sd\b|venta|orden|ciclo', re.I)),
    ('SAP MM',             re.compile(r'marc|mara|ekko|ekpo|mm\b|material|compra', re.I)),
    ('SAP HCM',            re.compile(r'pa0001|pa0002|hr\b|hcm\b|nomina|empleado|promotor', re.I)),
    ('SAP Basis/Custom',   re.compile(r'tvarvc|tvarv|t001|basis|customizing|selecci|variable', re.I)),
    ('SAP IFRS/Regulatorio', re.compile(r'ifrs|niif|regulat|cnbv|fiscal|sat\b', re.I)),
    ('SAP Integration',    re.compile(r'bapi|rfc\b|idoc|interfaz|connector|soap|rest', re.I)),
]


def detect_module(obj_name: str, metodos: list[str], sql_access: list[dict]) -> str:
    tables = ' '.join(s.get('entidad', '') for s in sql_access)
    text   = ' '.join([obj_name] + metodos + [tables]).lower()
    for mod, pat in MODULE_PATTERNS:
        if pat.search(text):
            return mod
    return 'SAP Genérico'


# ── DDL ──────────────────────────────────────────────────────────────────────

DDL = '''
PRAGMA journal_mode=WAL;
PRAGMA synchronous=NORMAL;

DROP TABLE IF EXISTS rules_fts;
DROP TABLE IF EXISTS objects_fts;
DROP TABLE IF EXISTS terms_fts;
DROP TABLE IF EXISTS object_domains;
DROP TABLE IF EXISTS object_authors;
DROP TABLE IF EXISTS object_calls;
DROP TABLE IF EXISTS rules;
DROP TABLE IF EXISTS terms;
DROP TABLE IF EXISTS domains;
DROP TABLE IF EXISTS sql_access;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS objects;

CREATE TABLE objects (
    id              TEXT PRIMARY KEY,
    nombre          TEXT,
    tipo            TEXT,       -- class, prog, fugr, intf
    loc             INTEGER,
    dominio         TEXT,       -- BIAN domain code
    sap_module      TEXT,       -- SAP FI / CO / HCM / etc.
    namespace       TEXT,       -- /CBB/, /ZCB/, Z, Y
    n_metodos       INTEGER DEFAULT 0,
    n_tipos         INTEGER DEFAULT 0,
    n_atributos     INTEGER DEFAULT 0,
    n_deps          INTEGER DEFAULT 0,
    fan_in          INTEGER DEFAULT 0,
    fan_out         INTEGER DEFAULT 0,
    autor           TEXT,
    usuario_sap     TEXT,
    fecha_creacion  TEXT,
    ticket          TEXT,
    is_singleton    INTEGER DEFAULT 0,
    biz             TEXT,       -- descripción de negocio (a completar)
    primary_bian    TEXT        -- dominio BIAN principal
);

CREATE TABLE object_calls (
    from_obj    TEXT NOT NULL,
    to_obj      TEXT NOT NULL,
    call_type   TEXT,           -- call_function, call_function_rfc, instantiate, type_ref, catch
    PRIMARY KEY (from_obj, to_obj, call_type),
    FOREIGN KEY (from_obj) REFERENCES objects(id)
);

CREATE TABLE sql_access (
    obj_id      TEXT NOT NULL,
    entidad     TEXT NOT NULL,  -- nombre de la tabla SAP accedida
    modo        TEXT,           -- R (read), W (write)
    es_std      INTEGER,        -- 1=tabla estándar SAP, 0=tabla Z
    PRIMARY KEY (obj_id, entidad, modo),
    FOREIGN KEY (obj_id) REFERENCES objects(id)
);

CREATE TABLE rules (
    id              TEXT PRIMARY KEY,   -- GENREG-NNNN
    obj_id          TEXT NOT NULL,
    metodo          TEXT,
    linea           INTEGER,
    tipo            TEXT,       -- VALIDACION, FLUJO, MANEJO_ERROR, CALCULO, REGULATORIO, AUTORIZACION
    condicion       TEXT,
    business_name   TEXT,
    reg             TEXT,       -- CNBV, IFRS, SAT, etc.
    riesgo          TEXT,       -- ALTO, MEDIO, BAJO
    fuente          TEXT,       -- CODE, INFERRED
    FOREIGN KEY (obj_id) REFERENCES objects(id)
);

CREATE TABLE terms (
    term        TEXT PRIMARY KEY,
    cat         TEXT,           -- ENTIDAD, ACCION, REG, PREFIJO, MODIF, AMBIGUO
    nivel       TEXT,           -- ALTA, MEDIA, AMBIGUA, CANDIDATO
    fn          INTEGER,        -- frecuencia en código
    mean        TEXT,
    bian_domain TEXT,
    fuente      TEXT            -- CODE, SME, NEGOCIO, CONVENCION, INFERIDO, AMBIGUO
);

CREATE TABLE domains (
    id          TEXT PRIMARY KEY,
    nombre      TEXT,
    bian_ref    TEXT,
    descripcion TEXT
);

CREATE TABLE authors (
    uid         TEXT PRIMARY KEY,
    nombre      TEXT,
    n_objetos   INTEGER DEFAULT 0,
    fecha_primera TEXT,
    fecha_ultima  TEXT,
    tickets     TEXT            -- JSON array
);

CREATE TABLE object_authors (
    obj_id      TEXT NOT NULL,
    uid         TEXT NOT NULL,
    fecha       TEXT,
    ticket      TEXT,
    proyecto    TEXT,
    PRIMARY KEY (obj_id, uid),
    FOREIGN KEY (obj_id) REFERENCES objects(id),
    FOREIGN KEY (uid)    REFERENCES authors(uid)
);

-- Índices
CREATE INDEX idx_obj_dominio   ON objects(dominio);
CREATE INDEX idx_obj_tipo      ON objects(tipo);
CREATE INDEX idx_obj_fanin     ON objects(fan_in DESC);
CREATE INDEX idx_calls_from    ON object_calls(from_obj);
CREATE INDEX idx_calls_to      ON object_calls(to_obj);
CREATE INDEX idx_rules_obj     ON rules(obj_id);
CREATE INDEX idx_rules_tipo    ON rules(tipo);
CREATE INDEX idx_rules_riesgo  ON rules(riesgo);
CREATE INDEX idx_rules_reg     ON rules(reg);
CREATE INDEX idx_sql_obj       ON sql_access(obj_id);
CREATE INDEX idx_terms_cat     ON terms(cat);
CREATE INDEX idx_terms_nivel   ON terms(nivel);
CREATE INDEX idx_terms_bian    ON terms(bian_domain);

-- FTS5
CREATE VIRTUAL TABLE objects_fts USING fts5(
    id, nombre, biz, sap_module, dominio,
    content='objects', content_rowid='rowid'
);

CREATE VIRTUAL TABLE rules_fts USING fts5(
    id, obj_id, metodo, condicion, business_name, reg, tipo,
    content='rules', content_rowid='rowid'
);

CREATE VIRTUAL TABLE terms_fts USING fts5(
    term, mean, bian_domain,
    content='terms', content_rowid='rowid'
);
'''

# ── Dominios BIAN canónicos de Gentera ───────────────────────────────────────

DOMAINS = [
    ('MICROCREDITO', 'Microfinanzas y Crédito',
     'Lending',
     'Crédito grupal e individual, ciclos de crédito, amortización, cartera, cobranza'),
    ('CLIENTE',      'Cliente / Party',
     'Party Data Management',
     'Gestión de clientes, promotores, grupos solidarios, datos personales LFPDPPP'),
    ('PAGOS',        'Pagos y Transferencias',
     'Payments',
     'SPEI, CoDi, dispersión de nómina, domiciliación, transferencias'),
    ('CONTABILIDAD', 'Contabilidad y Finanzas',
     'Financial Accounting',
     'Contabilidad SAP FI, cierres, pólizas, IFRS, estados financieros CNBV'),
    ('CUENTAS',      'Cuentas y Depósitos',
     'Current Account',
     'Cuentas de ahorro, captación, saldos, apertura'),
    ('RIESGO',       'Riesgo y Cumplimiento',
     'Regulatory Compliance',
     'PLD, AML, IFRS 9, riesgo de crédito, cumplimiento CNBV/CONDUSEF'),
    ('CANALES',      'Canales y Digital',
     'Channel Management',
     'Banca por internet, cajeros ATM, app móvil, sucursales'),
    ('PARAMETROS',   'Parámetros y Configuración',
     'Reference Data Management',
     'TVARVC, variables de selección, flags de eventos, configuración operativa'),
    ('SERVICIOS',    'Servicios Técnicos Transversales',
     'Infrastructure',
     'Helpers, excepciones, mensajes, logging, patrones de diseño técnico'),
    ('TRANSVERSAL',  'Transversal / Sin clasificar',
     'Other',
     'Objetos que no mapean a un dominio de negocio específico'),
]


# ── Loaders ──────────────────────────────────────────────────────────────────

def load_domains(conn: sqlite3.Connection) -> None:
    conn.executemany(
        'INSERT OR IGNORE INTO domains (id, nombre, bian_ref, descripcion) VALUES (?,?,?,?)',
        DOMAINS,
    )
    conn.commit()
    print(f'  dominios {len(DOMAINS):>4}')


def load_objects(conn: sqlite3.Connection) -> dict[str, dict]:
    """Carga objetos desde objects-inventory.json. Retorna index obj_id → row dict."""
    if not INV_FILE.exists():
        print('  WARN: objects-inventory.json no encontrado. Corre parse-abap.py primero.')
        return {}

    inv     = json.loads(INV_FILE.read_text(encoding='utf-8'))
    objetos = inv.get('objetos', [])
    callgraph = inv.get('callgraph', [])
    headers_raw = inv.get('headers', [])
    accesos = inv.get('acceso', [])

    # fan_in / fan_out desde callgraph
    fan_in:  Counter = Counter()
    fan_out: Counter = Counter()
    for edge in callgraph:
        fan_out[edge['from']] += 1
        fan_in[edge.get('to', '')] += 1

    # Headers por objeto
    headers = {}
    for h in headers_raw:
        oid = h.get('objeto', '')
        if oid not in headers:
            headers[oid] = h

    obj_index: dict[str, dict] = {}

    for o in objetos:
        oid      = o['id']
        nombre   = o.get('nombre', oid)
        tipo     = o.get('tipo', 'unknown')
        metodos  = o.get('metodos', [])
        tipos    = o.get('tipos', [])
        atribs   = o.get('atributos', [])
        deps     = o.get('dependencias', [])

        # Extraer accesos SQL de este objeto (desde inv.acceso)
        sql_objs = [a for a in accesos if a.get('objeto') == oid]

        # Dominio y módulo
        dominio    = detect_domain(nombre, tipo, metodos)
        sap_module = detect_module(nombre, metodos, sql_objs)

        # Namespace
        ns_m = re.match(r'^(/[A-Z0-9]+/)', oid)
        namespace = ns_m.group(1) if ns_m else ('Z' if oid.startswith('Z') else 'SAP')

        # Singleton
        is_singleton = 1 if any('singleton' in m.lower() or 'instance' in m.lower()
                                  for m in metodos) else 0

        # Header de autoría
        h    = headers.get(oid, {})
        autor    = h.get('autor', '')
        uid      = h.get('usuario_sap', '')
        fecha    = h.get('fecha', '')
        ticket   = h.get('ticket', '')
        proyecto = h.get('proyecto', '')

        row = {
            'id'           : oid,
            'nombre'       : nombre,
            'tipo'         : tipo,
            'loc'          : o.get('loc', 0),
            'dominio'      : dominio,
            'sap_module'   : sap_module,
            'namespace'    : namespace,
            'n_metodos'    : len(metodos),
            'n_tipos'      : len(tipos),
            'n_atributos'  : len(atribs),
            'n_deps'       : len(deps),
            'fan_in'       : fan_in.get(oid, 0),
            'fan_out'      : fan_out.get(oid, 0),
            'autor'        : autor,
            'usuario_sap'  : uid,
            'fecha_creacion': fecha,
            'ticket'       : ticket,
            'is_singleton' : is_singleton,
            'biz'          : None,
            'primary_bian' : dominio,
        }
        obj_index[oid] = row

        conn.execute('''
            INSERT OR REPLACE INTO objects
            (id, nombre, tipo, loc, dominio, sap_module, namespace,
             n_metodos, n_tipos, n_atributos, n_deps, fan_in, fan_out,
             autor, usuario_sap, fecha_creacion, ticket, is_singleton,
             biz, primary_bian)
            VALUES
            (:id,:nombre,:tipo,:loc,:dominio,:sap_module,:namespace,
             :n_metodos,:n_tipos,:n_atributos,:n_deps,:fan_in,:fan_out,
             :autor,:usuario_sap,:fecha_creacion,:ticket,:is_singleton,
             :biz,:primary_bian)
        ''', row)

        # SQL access
        for sql in sql_objs:
            conn.execute('''
                INSERT OR IGNORE INTO sql_access (obj_id, entidad, modo, es_std)
                VALUES (?, ?, ?, ?)
            ''', (oid, sql.get('entidad', ''), sql.get('modo', 'R'),
                  1 if sql.get('es_std') else 0))

        # Author
        if uid:
            conn.execute('''
                INSERT INTO authors (uid, nombre, n_objetos, fecha_primera, fecha_ultima, tickets)
                VALUES (?, ?, 1, ?, ?, ?)
                ON CONFLICT(uid) DO UPDATE SET
                    n_objetos = n_objetos + 1,
                    fecha_primera = CASE WHEN fecha_primera > ? OR fecha_primera IS NULL
                                    THEN ? ELSE fecha_primera END,
                    fecha_ultima  = CASE WHEN fecha_ultima < ? OR fecha_ultima IS NULL
                                    THEN ? ELSE fecha_ultima END
            ''', (uid, autor, fecha, fecha, tickets_json(ticket), fecha, fecha, fecha, fecha))

            conn.execute('''
                INSERT OR IGNORE INTO object_authors (obj_id, uid, fecha, ticket, proyecto)
                VALUES (?, ?, ?, ?, ?)
            ''', (oid, uid, fecha, ticket, proyecto))

    conn.commit()

    # Call graph
    for edge in callgraph:
        conn.execute('''
            INSERT OR IGNORE INTO object_calls (from_obj, to_obj, call_type)
            VALUES (?, ?, ?)
        ''', (edge.get('from', ''), edge.get('to', ''), edge.get('tipo', 'call')))
    conn.commit()

    print(f'  objects   {len(objetos):>5}  |  call_edges {len(callgraph):>5}  |  sql_access {len(accesos):>5}')
    return obj_index


def tickets_json(ticket: str) -> str:
    return json.dumps([ticket] if ticket else [])


def load_rules(conn: sqlite3.Connection) -> None:
    if not RULES_FILE.exists():
        print('  INFO: rules-gentera.json no encontrado — omitiendo carga de reglas.')
        print('        Corre: python extract-rules.py  para generarlo.')
        return

    data  = json.loads(RULES_FILE.read_text(encoding='utf-8'))
    reglas = data.get('reglas', [])

    for r in reglas:
        conn.execute('''
            INSERT OR IGNORE INTO rules
            (id, obj_id, metodo, linea, tipo, condicion, business_name, reg, riesgo, fuente)
            VALUES (?,?,?,?,?,?,?,?,?,?)
        ''', (r['id'], r.get('obj_id', ''), r.get('metodo', ''),
              r.get('linea', 0), r.get('tipo', ''), r.get('condicion', ''),
              r.get('business_name', ''), r.get('reg'), r.get('riesgo', 'BAJO'),
              r.get('fuente', 'CODE')))
    conn.commit()
    print(f'  rules     {len(reglas):>5}')


def load_vocabulary(conn: sqlite3.Connection) -> None:
    if not VOCAB_FILE.exists():
        print('  INFO: vocab-gentera.json no encontrado — omitiendo vocabulario.')
        return

    data  = json.loads(VOCAB_FILE.read_text(encoding='utf-8'))
    atoms = data.get('atomos', [])
    comps = data.get('compuestos', [])
    cands = data.get('candidatos', [])

    rows = []
    for r in atoms + comps:
        rows.append((
            r.get('term', ''),
            r.get('cat', '?'),
            r.get('nivel', 'CANDIDATO'),
            r.get('fn', 0),
            r.get('mean', ''),
            r.get('bian', ''),
            r.get('fuente', 'CODE'),
        ))
    for c in cands:
        rows.append((
            c.get('frag', ''),
            '?',
            'CANDIDATO',
            c.get('frec', 0),
            '(sin clasificar)',
            '',
            'CODE',
        ))

    conn.executemany('''
        INSERT OR IGNORE INTO terms (term, cat, nivel, fn, mean, bian_domain, fuente)
        VALUES (?,?,?,?,?,?,?)
    ''', rows)
    conn.commit()
    print(f'  terms     {len(rows):>5}  (atomicos {len(atoms)} + compuestos {len(comps)} + candidatos {len(cands)})')


def build_fts(conn: sqlite3.Connection) -> None:
    conn.execute("INSERT INTO objects_fts(objects_fts) VALUES('rebuild')")
    conn.execute("INSERT INTO rules_fts(rules_fts) VALUES('rebuild')")
    conn.execute("INSERT INTO terms_fts(terms_fts) VALUES('rebuild')")
    conn.commit()
    print('  FTS5 indices reconstruidos')


def print_summary(conn: sqlite3.Connection) -> None:
    tables = ['objects', 'object_calls', 'sql_access', 'rules', 'terms',
              'domains', 'authors', 'object_authors']
    print('\n── Entidades en brain.db ──────────────────────────')
    for t in tables:
        n = conn.execute(f'SELECT COUNT(*) FROM {t}').fetchone()[0]
        print(f'  {t:<20} {n:>6,}')

    print('\n── Reglas por tipo ────────────────────────────────')
    for row in conn.execute(
        "SELECT tipo, COUNT(*) n FROM rules GROUP BY tipo ORDER BY n DESC"
    ).fetchall():
        print(f'  {row[0]:<20} {row[1]:>5}')

    print('\n── Reglas por riesgo ──────────────────────────────')
    for row in conn.execute(
        "SELECT riesgo, COUNT(*) n FROM rules GROUP BY riesgo ORDER BY n DESC"
    ).fetchall():
        print(f'  {row[0]:<20} {row[1]:>5}')

    reg_rows = conn.execute(
        "SELECT reg, COUNT(*) n FROM rules WHERE reg IS NOT NULL GROUP BY reg ORDER BY n DESC"
    ).fetchall()
    if reg_rows:
        print('\n── Reglas regulatorias ────────────────────────────')
        for row in reg_rows:
            print(f'  {row[0]:<20} {row[1]:>5}')

    print('\n── Objetos por dominio BIAN ───────────────────────')
    for row in conn.execute(
        "SELECT dominio, COUNT(*) n FROM objects GROUP BY dominio ORDER BY n DESC"
    ).fetchall():
        print(f'  {row[0]:<25} {row[1]:>5}')


def main():
    print('GENCore Digital Brain — build-brain.py')
    print(f'DB: {DB_PATH}\n')

    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row

    print('── Inicializando schema ──────────────────────────')
    conn.executescript(DDL)
    conn.commit()

    print('── Cargando datos ────────────────────────────────')
    load_domains(conn)
    load_objects(conn)
    load_rules(conn)
    load_vocabulary(conn)

    print('── Construyendo índices FTS5 ─────────────────────')
    build_fts(conn)

    print_summary(conn)

    conn.close()
    size_kb = DB_PATH.stat().st_size // 1024
    print(f'\nOK  brain.db ({size_kb} KB) listo.')
    print('Siguiente paso: from digital_brain.brain import GENCOREBrain')


if __name__ == '__main__':
    main()