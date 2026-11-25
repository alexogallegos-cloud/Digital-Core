#!/usr/bin/env python3
"""
build-brain.py — SIWEB Digital Brain
BanCoppel Application Modernization · SPE-AM-001

SIWEB es la operacion de cajero y ventanilla de sucursal (alias OFI_WEB, ID 60
del inventario As-Is). El fuente es CPlaSu, "BanCoppel Sucursales", del
proveedor Solser (groupId mx.com.solser.cplasu): un cliente JavaFX desplegado
por Java Web Start contra un backend Spring MVC empaquetado como EAR.

El hallazgo que gobierna este brain es que SIWEB no habla con Informix por JDBC.
Cada operacion de core se pide al BUS por un identificador numerico de web
service (enum IdentificadorWebService) desde un DAO por base de datos
(databases/ws/*Ws.java). Ese identificador, no el nombre del stored procedure,
es la unidad de dependencia del canal contra el core.

Etapas del pipeline:
  1. load_system_info()   — identidad TOGAF del sistema
  2. load_modules()       — modulos Maven del reactor CPlaSu
  3. load_ws_services()   — catalogo de identificadores de web service del core
  4. load_core_bridges()  — un DAO por base Informix, con los identificadores que usa
  5. load_sp_calls()      — enums EXECUTE PROCEDURE heredados, con su estado de uso
  6. load_endpoints()     — catalogo de URLs de UrlConstantes y sus controladores
  7. load_views()         — vistas FXML, que son la superficie de operacion en caja
  8. load_integrations()  — clientes SOAP y accesos fuera de Informix
  9. load_cross_deps()    — dependencias conocidas por documentacion (Regla B12)
 10. build_fts()          — indices FTS5 para busqueda semantica
 11. emit_signals()       — senales de resumen del estado del brain

Uso:
  python build-brain.py [--reset] [--source <ruta>] [--db <ruta>] [--verbose]
"""

import argparse
import json
import re
import sqlite3
import sys
import xml.etree.ElementTree as ET
from bisect import bisect_right
from datetime import datetime, timezone
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

SCRIPT_DIR = Path(__file__).parent
SOURCE_DIR = SCRIPT_DIR.parent / "source" / "code"
DB_PATH    = SCRIPT_DIR / "brain.db"
SEEDS_DIR  = SCRIPT_DIR / "seeds"
SYSTEM_ID  = "siweb"
VERSION    = "1.0.0"
TS_NOW     = datetime.now(timezone.utc).isoformat()

# Receptores de los seeds que emite este brain (Regla B11). El slug es el que
# usa el resto de la flota, no el nombre de la carpeta.
SEED_TARGETS = {
    "informix":      ("core", "calls"),
    "smartvista":    ("processors", "calls"),
    "e-global":      ("integration", "calls"),
    "western-union": ("processors", "calls"),
    # El BUS es la via por la que SIWEB llega al core: no emitirle seed dejaba
    # fuera al vecino mas citado de este canal. Un sistema que solo siembra a
    # quien ya tiene carpeta nunca dispara la Regla B9 sobre los que faltan.
    "bus":           ("integration", "calls"),
}

ASIS_DOC = ("projects/unity/source/docs/DocumentosTrabajo/ArquitecturaAplicativaAsIs/"
            "BanCoppel_ASIS_Base_Conocimiento_y_Regeneracion_2.md")
UNITY_DT = "projects/unity/dt/dt-siweb.md"

MAVEN_NS = "{http://maven.apache.org/POM/4.0.0}"

# ── Patrones de extraccion ──────────────────────────────────────────────
# W1: constante del catalogo de web services:  CONSULTA_FECHA_SISTEMA(1),
RE_WS_ENTRY = re.compile(r'^[ \t]*([A-Z][A-Z0-9_]*)\s*\(\s*(\d+)\s*\)', re.MULTILINE)
RE_WS_USE   = re.compile(r'\bIdentificadorWebService\.([A-Z][A-Z0-9_]*)\b')
RE_COMMENT  = re.compile(r'^[ \t]*(?://+|/\*+)\s*(.+?)\s*(?:\*/)?$')
# M1: declaracion de metodo Java, para atribuir cada uso a su operacion
RE_METHOD = re.compile(
    r'^[ \t]*(?:public|protected|private)\s+(?:static\s+|final\s+|synchronized\s+)*'
    r'[\w.<>,\[\]\? ]+?\s+(\w+)\s*\(', re.MULTILINE)
# E1: entrada de enum de stored procedure heredado
RE_SP_ENTRY = re.compile(r'^[ \t]*([A-Z][A-Z0-9_]*)[ \t]*\([ \t]*"([^"]*)"', re.MULTILINE)
RE_SP_DB    = re.compile(r'private\s+static\s+final\s+String\s+DB\s*=\s*"([^"]+)"')
RE_SP_NAME  = re.compile(r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s*\(')
RE_SP_PARAM = re.compile(r'\{\d+\}')
RE_SP_USE   = re.compile(r'\b(SP[A-Za-z0-9]+)\.([A-Z][A-Z0-9_]*)\b')
# E3: constante de URL en UrlConstantes
RE_URL_CONST = re.compile(r'public\s+static\s+final\s+String\s+([A-Z0-9_]+)\s*=\s*"([^"]*)"')
RE_MAPPING = re.compile(
    r'@(RequestMapping|PostMapping|GetMapping|PutMapping|DeleteMapping)\s*\('
    r'[^)]*?UrlConstantes\.([A-Z0-9_]+)', re.DOTALL)
RE_URL_USE = re.compile(r'UrlConstantes\.([A-Z0-9_]+)')
RE_HTTP_METHOD = re.compile(r'RequestMethod\.([A-Z]+)')
RE_CLASS_PKG = re.compile(r'^\s*package\s+([\w.]+)\s*;', re.MULTILINE)
RE_REPOSITORY = re.compile(r'@Repository\(\s*"([^"]*)"\s*\)')

SCHEMA = """
-- Mismas columnas que el resto de la flota (el brain de e-global es el
-- precedente de un brain maduro nacido de un seed): se conservan las del seed
-- y se agregan las propias del sistema.
CREATE TABLE IF NOT EXISTS system_info (
    slug             TEXT PRIMARY KEY,
    display_name     TEXT,
    togaf_type       TEXT,
    togaf_state      TEXT,
    togaf_abb        TEXT,
    seeded_by        TEXT,
    seeded_at        TEXT,
    seed_version     TEXT,
    brain_version    TEXT,
    built_at         TEXT,
    aliases          TEXT DEFAULT '[]',
    vendor           TEXT,
    stack_declarado  TEXT,
    stack_confirmado TEXT,
    source_snapshot  TEXT
);

CREATE TABLE IF NOT EXISTS modules (
    id          TEXT PRIMARY KEY,
    group_id    TEXT,
    artifact_id TEXT,
    name        TEXT,
    packaging   TEXT,
    path        TEXT,
    java_files  INTEGER DEFAULT 0,
    role        TEXT
);

-- Catalogo de operaciones de core que el canal puede pedirle al BUS.
CREATE TABLE IF NOT EXISTS ws_services (
    constant         TEXT PRIMARY KEY,
    ws_id            INTEGER NOT NULL,
    functional_group TEXT,
    file             TEXT,
    usages           INTEGER DEFAULT 0
);

-- Donde se invoca cada operacion: DAO, base de datos destino y metodo.
CREATE TABLE IF NOT EXISTS ws_usages (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    constant    TEXT REFERENCES ws_services(constant),
    ws_id       INTEGER,
    db_domain   TEXT,
    dao_class   TEXT,
    method      TEXT,
    module      TEXT,
    file        TEXT
);

-- Un puente por base Informix alcanzada a traves del BUS.
CREATE TABLE IF NOT EXISTS core_bridges (
    db_domain    TEXT PRIMARY KEY,
    dao_class    TEXT,
    bean_name    TEXT,
    file         TEXT,
    ws_ids_used  INTEGER DEFAULT 0,
    methods      INTEGER DEFAULT 0
);

-- Enums EXECUTE PROCEDURE heredados del acceso directo a Informix.
CREATE TABLE IF NOT EXISTS sp_calls (
    id          TEXT PRIMARY KEY,
    db_name     TEXT NOT NULL,
    enum_class  TEXT NOT NULL,
    constant    TEXT NOT NULL,
    sp_name     TEXT NOT NULL,
    params      INTEGER DEFAULT 0,
    raw_query   TEXT,
    file        TEXT,
    pattern     TEXT,
    status      TEXT DEFAULT 'sin-uso'
);

CREATE TABLE IF NOT EXISTS sp_usages (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    sp_call_id TEXT REFERENCES sp_calls(id),
    module     TEXT,
    file       TEXT,
    java_class TEXT
);

CREATE TABLE IF NOT EXISTS endpoints (
    id          TEXT PRIMARY KEY,
    constant    TEXT NOT NULL,
    url         TEXT,
    http_method TEXT,
    module      TEXT,
    controller  TEXT,
    file        TEXT,
    consumed_by TEXT DEFAULT '[]'
);

-- La identidad de una pantalla es su ruta, no su nombre de archivo: hay
-- nombres repetidos en areas distintas y la clave por nombre perdia 14 de 492.
CREATE TABLE IF NOT EXISTS views (
    id     TEXT PRIMARY KEY,
    name   TEXT,
    area   TEXT,
    path   TEXT,
    module TEXT
);

CREATE TABLE IF NOT EXISTS integrations (
    id         TEXT PRIMARY KEY,
    kind       TEXT,
    java_class TEXT,
    file       TEXT,
    detail     TEXT
);

CREATE TABLE IF NOT EXISTS cross_dependencies (
    id              TEXT PRIMARY KEY,
    other_system    TEXT NOT NULL,
    relationship    TEXT NOT NULL,
    direction       TEXT NOT NULL,
    volume          INTEGER DEFAULT 0,
    domains         TEXT DEFAULT '[]',
    regulation      TEXT DEFAULT '[]',
    description     TEXT,
    criticality     TEXT DEFAULT 'unknown',
    evidence_kind   TEXT DEFAULT 'documental',
    origin_artifact TEXT,
    seeded_at       TEXT,
    -- Quien escribio la fila. Lo propio se recalcula en cada build; lo que
    -- sembro otro brain se preserva (Regla B12).
    emitter         TEXT DEFAULT 'siweb'
);

CREATE TABLE IF NOT EXISTS signals (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    signal_type   TEXT NOT NULL,
    source_system TEXT NOT NULL,
    value         INTEGER DEFAULT 0,
    metadata      TEXT DEFAULT '{}',
    seeded_at     TEXT
);
"""

FTS_SCHEMA = """
CREATE VIRTUAL TABLE ws_services_fts
    USING fts5(constant, functional_group, content='ws_services', content_rowid='rowid');
CREATE VIRTUAL TABLE sp_calls_fts
    USING fts5(id, db_name, constant, sp_name, content='sp_calls', content_rowid='rowid');
CREATE VIRTUAL TABLE endpoints_fts
    USING fts5(id, constant, url, controller, content='endpoints', content_rowid='rowid');
CREATE VIRTUAL TABLE cross_dependencies_fts
    USING fts5(id, other_system, relationship, description,
               content='cross_dependencies', content_rowid='rowid');
"""

MODULE_ROLES = {
    "CPlaSuCommons":     "Beans de request y response, utilerias y catalogo de URLs",
    "CPlaSuPersistence": "Acceso a datos: DAOs contra el BUS, enums heredados y clientes SOAP",
    "CPlaSuService":     "Backend Spring MVC con los controladores REST del canal",
    "CPlaSuFX":          "Cliente JavaFX de ventanilla: vistas FXML, controladores y servicios de UI",
    "CPlaSuApp":         "Aplicacion web que publica el cliente por Java Web Start (JNLP)",
    "EARCPlaSuApp":      "Empaquetado EAR de la aplicacion web",
    "EARCPlaSuService":  "Empaquetado EAR del backend de servicios",
    "ControlesSolser":   "Controles de UI propios del proveedor, fuera del reactor activo",
    "report-compiler":   "Compilador de reportes JasperReports",
}

CROSS_DEPS = [
    ("SIWEB-DEP-001", "informix", "calls", "outbound", 0, ["D01", "D02"],
     ["CNBV Banca Electronica"],
     "En consultas desde SIWEB el BUS consulta Informix para datos del cliente y "
     "validaciones de existencia y lista negra",
     "critical", ASIS_DOC),
    ("SIWEB-DEP-002", "bus-iib", "calls", "outbound", 0, [], [],
     "Via valida al core. Informix no recibe REST, SOAP, ISO 8583 ni SFTP directo: "
     "terminan en middleware",
     "critical", ASIS_DOC),
    ("SIWEB-DEP-003", "gestor-central-huellas", "calls", "outbound", 0, [], [],
     "Web Service de autenticacion por huella para OFI y SIWEB, resuelto contra bdinteg",
     "high", ASIS_DOC),
    ("SIWEB-DEP-004", "bts-monterrey", "calls", "outbound", 0, [], [],
     "Remesas por F5 e IHS 15.27.31.14:7801 hacia JBoss Remesas WEB BTS y nube "
     "GlobalPlatform. Persistencia Informix y PostgreSQL",
     "high", ASIS_DOC),
    ("SIWEB-DEP-005", "western-union", "calls", "outbound", 0, [], [],
     "Remesas por F5 e IHS 10.27.30.28:7808 hacia JBoss Remesas WEB WU y gateway "
     "eugateway2.westernunion.net",
     "high", ASIS_DOC),
    ("SIWEB-DEP-006", "banca-empresarial", "peer", "unknown", 0, [], [],
     "Las ordenes de pago entre sucursales se generan desde SIWEB o desde Banca Empresarial",
     "medium", ASIS_DOC),
    ("SIWEB-DEP-007", "smartvista", "calls", "outbound", 0, [], [],
     "Transaccion 623 de compras diferidas MCI, resuelta via modulo DPP",
     "high", UNITY_DT),
    ("SIWEB-DEP-008", "e-global", "calls", "outbound", 0, [], [],
     "Compras diferidas MSI operadas desde caja",
     "high", UNITY_DT),
    ("SIWEB-DEP-009", "ofi-tradicional", "peer", "unknown", 0, [], [],
     "Enlace canal a canal que el As-Is marca como probable falso positivo. "
     "Validar contra SUD antes de darlo por bueno",
     "low", ASIS_DOC),
]


# ── Utilidades ──────────────────────────────────────────────────────────

def read_text(path: Path) -> str:
    """Los fuentes mezclan UTF-8 e ISO-8859-1. Se intenta en ese orden."""
    for encoding in ("utf-8", "latin-1"):
        try:
            return path.read_text(encoding=encoding)
        except (UnicodeDecodeError, OSError):
            continue
    return ""


def find_reactor(source_dir: Path) -> Path | None:
    """Localiza la raiz del reactor Maven (la carpeta con el pom padre)."""
    for pom in sorted(source_dir.rglob("pom.xml")):
        root = ET.parse(pom).getroot()
        if (root.findtext(f"{MAVEN_NS}packaging") == "pom"
                and root.find(f"{MAVEN_NS}modules") is not None):
            return pom.parent
    return None


def rel(path: Path, base: Path) -> str:
    try:
        return str(path.relative_to(base)).replace("\\", "/")
    except ValueError:
        return str(path).replace("\\", "/")


def java_classname(text: str, path: Path) -> str:
    package = RE_CLASS_PKG.search(text)
    return f"{package.group(1)}.{path.stem}" if package else path.stem


def method_index(text: str):
    """Posiciones y nombres de los metodos del archivo, para atribuir usos."""
    starts, names = [], []
    for match in RE_METHOD.finditer(text):
        if match.group(1) in ("if", "for", "while", "switch", "catch", "return"):
            continue
        starts.append(match.start())
        names.append(match.group(1))
    return starts, names


def method_at(starts, names, position: int) -> str | None:
    index = bisect_right(starts, position) - 1
    return names[index] if index >= 0 else None


def db_domain_of(dao_stem: str) -> str:
    """BDIsucWs y BDIdomiWS son la misma convencion: nombre de base mas sufijo Ws."""
    return re.sub(r'[Ww][Ss]$', '', dao_stem).upper()


# ── Regla B12: ningun brain arranca de cero ─────────────────────────────

def preserve_seed(db_path: Path) -> dict:
    """Rescata lo que otros brains sembraron aqui antes de reconstruir.

    Solo se preserva lo ajeno: las dependencias y senales que este pipeline
    produjo se recalculan en cada build. Sin ese filtro, cada rebuild acumularia
    copias de su propia salida. Es el mismo criterio que usa e-global.
    """
    rescate = {"cross_dependencies": [], "signals": [], "system_info": None}
    if not db_path.exists():
        return rescate
    con = sqlite3.connect(db_path)
    con.row_factory = sqlite3.Row
    consultas = {
        "cross_dependencies": f"SELECT * FROM cross_dependencies WHERE emitter != '{SYSTEM_ID}'",
        "signals": f"SELECT * FROM signals WHERE source_system != '{SYSTEM_ID}'",
    }
    for tabla, sql in consultas.items():
        try:
            rescate[tabla] = [dict(r) for r in con.execute(sql)]
        except sqlite3.OperationalError:
            # Brain anterior a la columna emitter: no se puede distinguir lo
            # ajeno de lo propio, asi que no se rescata nada y se reconstruye.
            pass
    try:
        fila = con.execute("SELECT * FROM system_info").fetchone()
        rescate["system_info"] = dict(fila) if fila else None
    except sqlite3.OperationalError:
        pass
    con.close()
    return rescate


def restaurar_ajeno(conn: sqlite3.Connection, rescate) -> int:
    """Devuelve al brain las filas sembradas por otros sistemas."""
    filas = (rescate or {}).get("cross_dependencies") or []
    if not filas:
        return 0
    columnas = [r[1] for r in conn.execute("PRAGMA table_info(cross_dependencies)")]
    for fila in filas:
        valores = [fila.get(c) for c in columnas]
        conn.execute(
            f"INSERT OR REPLACE INTO cross_dependencies ({','.join(columnas)}) "
            f"VALUES ({','.join('?' * len(columnas))})", valores)
    return len(filas)


def restaurar_senales(conn: sqlite3.Connection, rescate) -> int:
    filas = (rescate or {}).get("signals") or []
    for fila in filas:
        conn.execute(
            "INSERT INTO signals (signal_type, source_system, value, metadata, seeded_at) "
            "VALUES (?,?,?,?,?)",
            (fila.get("signal_type"), fila.get("source_system"), fila.get("value"),
             fila.get("metadata"), fila.get("seeded_at")))
    return len(filas)


# ── Regla B11, lado receptor: aplicar los seeds dirigidos a este brain ───

def load_received_seeds(conn: sqlite3.Connection) -> int:
    """Lee todo `*/digital-brain/seeds/siweb-seed.json` del arbol de sistemas.

    Es la capa de enriquecimiento: lo que otros brains saben de SIWEB entra como
    cross_dependency con `emitter` igual al emisor, para no confundirlo con lo
    que este pipeline deduce del codigo.
    """
    raiz = SCRIPT_DIR.parents[2]          # systems/
    if raiz.name != "systems":
        return 0
    n = 0
    for archivo in sorted(raiz.rglob(f"digital-brain/seeds/{SYSTEM_ID}-seed.json")):
        try:
            seed = json.loads(archivo.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            continue
        emisor = seed.get("source_system")
        if not emisor or emisor == SYSTEM_ID:
            continue
        ev = seed.get("evidence", {})
        # El seed describe la relacion desde el emisor: al recibirla se invierte.
        direccion = {"inbound": "outbound", "outbound": "inbound"}.get(
            ev.get("direction"), "unknown")
        conn.execute(
            "INSERT OR REPLACE INTO cross_dependencies VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (f"seed-{emisor}-{SYSTEM_ID}", emisor, seed.get("relationship", "unknown"),
             direccion, ev.get("volume") or 0,
             json.dumps(ev.get("domains", [])), json.dumps(ev.get("regulation", [])),
             ev.get("description") or ev.get("cross_dep_description"),
             ev.get("criticality", "unknown"), "seed",
             f"{rel(archivo, raiz)} ({seed.get('source_version','')})".strip(),
             seed.get("generated_at") or TS_NOW, emisor))
        n += 1
    return n


def sync_seed_provenance(conn: sqlite3.Connection) -> None:
    """`seeded_by` deja de ser una frase y pasa a ser la lista real de brains que
    sembraron aqui, igual que en e-global. Si nadie sembro, queda el artefacto
    de descubrimiento que abrio la estructura."""
    filas = conn.execute(
        "SELECT emitter, origin_artifact, seeded_at FROM cross_dependencies "
        "WHERE evidence_kind = 'seed' ORDER BY emitter").fetchall()
    if not filas:
        return
    emisores = sorted({f[0] for f in filas})
    version = ""
    for _, origen, _ in filas:
        if origen and "(" in origen:
            version = origen[origen.rfind("(") + 1:origen.rfind(")")]
            break
    conn.execute(
        "UPDATE system_info SET seeded_by = ?, seeded_at = ?, seed_version = ? WHERE slug = ?",
        (json.dumps(emisores), min(f[2] for f in filas)[:10],
         version or "sin version declarada", SYSTEM_ID))


# ── Regla B11: al terminar el build, siembra a los vecinos ───────────────

def emit_seeds(conn: sqlite3.Connection) -> dict:
    """Emite un seed por vecino con la evidencia que este brain tiene de él.

    Para Informix el seed es el catalogo de servicios que el canal le pide al
    BUS, agrupado por base de datos: es lo mas cerca que SIWEB puede estar de
    decir que SPs toca, porque no los invoca directamente.
    """
    SEEDS_DIR.mkdir(parents=True, exist_ok=True)
    emitidos = {}

    bases = [{"id": dom, "name": dom, "dao": dao.split(".")[-1],
              "services": ws, "methods": met}
             for dom, dao, ws, met in conn.execute(
                 "SELECT db_domain, dao_class, ws_ids_used, methods FROM core_bridges "
                 "WHERE db_domain NOT IN ('AIDABAN','COPPEL','INTERAPI') "
                 "ORDER BY ws_ids_used DESC")]
    servicios = conn.execute("SELECT COUNT(*) FROM ws_services WHERE usages > 0").fetchone()[0]

    evidencias = {
        "informix": {
            "component_count": len(bases),
            "components": bases,
            "volume": servicios,
            "domains": ["D01", "D02"],
            "regulation": ["CNBV Banca Electronica"],
            "origin_artifact": "digital-brain/brain.db::core_bridges",
            "nota": ("SIWEB no invoca stored procedures: pide operaciones al BUS por "
                     "identificador de web service. Las bases son el destino final "
                     "declarado por el DAO, no una conexion JDBC del canal."),
        },
    }
    # El BUS es el unico vecino al que SIWEB llama de verdad: lo que el canal
    # le pide son los servicios por identificador, y el resto del camino al
    # core lo hace el BUS. Por eso su seed lleva el volumen de servicios y las
    # bases destino, no un cero como los vecinos que solo estan documentados.
    evidencias["bus"] = {
        "component_count": len(bases),
        "components": bases,
        "volume": servicios,
        "domains": ["D01", "D02"],
        "regulation": ["CNBV Banca Electronica"],
        "origin_artifact": "digital-brain/brain.db::core_bridges",
        "nota": ("SIWEB pide operaciones al BUS por identificador de web service; "
                 "el BUS resuelve el acceso al core. Informix no recibe REST, SOAP, "
                 "ISO 8583 ni SFTP directo: todo termina en middleware."),
    }

    # Los que quedan se describen con lo que diga cross_dependencies. Derivar
    # la lista de SEED_TARGETS y no de una tupla fija evita que agregar un
    # vecino nuevo rompa la emision con un KeyError.
    for slug in (t for t in SEED_TARGETS if t not in evidencias):
        fila = conn.execute(
            "SELECT description, criticality, origin_artifact FROM cross_dependencies "
            "WHERE other_system = ?", (slug,)).fetchone()
        evidencias[slug] = {
            "component_count": 0,
            "components": [],
            "volume": 0,
            "domains": [],
            "regulation": [],
            "origin_artifact": fila[2] if fila else "digital-brain/brain.db::cross_dependencies",
            "nota": (fila[0] if fila else
                     "Relacion declarada por documentacion, sin evidencia de codigo todavia."),
        }

    manifest = []
    for slug, (togaf, relacion) in SEED_TARGETS.items():
        seed = {
            "source_system": SYSTEM_ID,
            "source_togaf_type": "channels",
            "target_system": slug,
            "target_togaf_type": togaf,
            "generated_at": TS_NOW[:10],
            "source_version": f"siweb v{VERSION}",
            "relationship": relacion,
            "evidence": evidencias[slug],
        }
        archivo = f"{slug}-seed.json"
        (SEEDS_DIR / archivo).write_text(
            json.dumps(seed, ensure_ascii=False, indent=1), encoding="utf-8")
        manifest.append({"target": slug, "file": archivo,
                         "evidence_count": seed["evidence"]["component_count"]})
        emitidos[slug] = seed["evidence"]["component_count"]

    (SEEDS_DIR / "manifest.json").write_text(
        json.dumps({"emitter": SYSTEM_ID, "generated_at": TS_NOW,
                    "source_version": f"siweb v{VERSION}", "seeds": manifest},
                   ensure_ascii=False, indent=1), encoding="utf-8")
    return emitidos


# ── Etapas ──────────────────────────────────────────────────────────────

def load_system_info(conn: sqlite3.Connection, snapshot, stack, rescate=None) -> None:
    """Identidad del sistema. Lo que haya sembrado otro brain en `seeded_by`,
    `seeded_at` y `seed_version` se respeta: es la memoria de quien nos descubrio."""
    previo = (rescate or {}).get("system_info") or {}
    conn.execute(
        "INSERT OR REPLACE INTO system_info VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
        (SYSTEM_ID, "SIWEB — Canal de Sucursal, Ventanilla y Caja", "channels",
         "active" if snapshot else "discovered", "branch-teller-web",
         previo.get("seeded_by") or json.dumps(["asis-inventory-id-60", "unity-track-siweb"]),
         previo.get("seeded_at") or TS_NOW[:10],
         previo.get("seed_version") or "sin seed de origen",
         VERSION, TS_NOW,
         json.dumps(["OFI_WEB", "OFI Web", "CPlaSu"]),
         "Solser (mx.com.solser.cplasu)",
         "Angular sobre WebSphere, segun el inventario As-Is",
         stack, snapshot))


def load_modules(conn: sqlite3.Connection, reactor: Path, base: Path) -> int:
    rows = []
    for pom in sorted(reactor.rglob("pom.xml")):
        root = ET.parse(pom).getroot()
        parent = root.find(f"{MAVEN_NS}parent")
        group = (root.findtext(f"{MAVEN_NS}groupId")
                 or (parent.findtext(f"{MAVEN_NS}groupId") if parent is not None else None))
        rows.append((pom.parent.name, group,
                     root.findtext(f"{MAVEN_NS}artifactId") or pom.parent.name,
                     root.findtext(f"{MAVEN_NS}name"),
                     root.findtext(f"{MAVEN_NS}packaging") or "jar",
                     rel(pom.parent, base),
                     sum(1 for _ in pom.parent.rglob("*.java")),
                     MODULE_ROLES.get(pom.parent.name)))
    conn.executemany("INSERT OR REPLACE INTO modules VALUES (?,?,?,?,?,?,?,?)", rows)
    return len(rows)


def load_ws_services(conn: sqlite3.Connection, reactor: Path, base: Path) -> dict:
    """Patron W1. El enum esta seccionado por comentarios y ese comentario es la
    unica pista de agrupacion funcional que dejo el proveedor: se conserva."""
    catalog = {}
    for enum_file in reactor.rglob("ws/enums/IdentificadorWebService.java"):
        text = read_text(enum_file)
        group = None
        for line in text.splitlines():
            comment = RE_COMMENT.match(line)
            if comment:
                # Una entrada comentada no es un titulo de seccion: el proveedor
                # desactiva servicios dejandolos en su lugar con //.
                if not RE_WS_ENTRY.match(comment.group(1)):
                    group = comment.group(1)
                continue
            entry = RE_WS_ENTRY.match(line)
            if entry:
                catalog[entry.group(1)] = (int(entry.group(2)), group,
                                           rel(enum_file, base))
    conn.executemany(
        "INSERT OR REPLACE INTO ws_services (constant, ws_id, functional_group, file) "
        "VALUES (?,?,?,?)",
        [(name, data[0], data[1], data[2]) for name, data in catalog.items()])
    return catalog


def load_core_bridges(conn: sqlite3.Connection, reactor: Path, base: Path,
                      catalog: dict) -> tuple[int, int]:
    """Cada DAO Ws es el puente del canal hacia una base Informix via el BUS.
    Se registra que operacion pide, desde que metodo y contra que base."""
    conn.execute("DELETE FROM ws_usages")
    conn.execute("DELETE FROM core_bridges")
    usages, bridges = [], {}
    for java in sorted(reactor.rglob("*.java")):
        text = read_text(java)
        if "IdentificadorWebService." not in text:
            continue
        if java.name == "IdentificadorWebService.java":
            continue
        dao_class = java_classname(text, java)
        module = rel(java, reactor).split("/")[0]
        domain = db_domain_of(java.stem)
        starts, names = method_index(text)
        bean = RE_REPOSITORY.search(text)
        for match in RE_WS_USE.finditer(text):
            constant = match.group(1)
            usages.append((constant, catalog.get(constant, (None,))[0], domain,
                           dao_class, method_at(starts, names, match.start()),
                           module, rel(java, base)))
        bridges[domain] = (dao_class, bean.group(1) if bean else None, rel(java, base))

    conn.executemany(
        "INSERT INTO ws_usages (constant, ws_id, db_domain, dao_class, method, module, file) "
        "VALUES (?,?,?,?,?,?,?)", usages)
    conn.executemany(
        "INSERT OR REPLACE INTO core_bridges (db_domain, dao_class, bean_name, file) "
        "VALUES (?,?,?,?)",
        [(domain, *data) for domain, data in bridges.items()])
    # Los conteos se derivan de la tabla, no del recorrido: si dos clases tocan
    # la misma base el resultado sigue siendo correcto.
    conn.execute("""
        UPDATE core_bridges SET
            ws_ids_used = (SELECT COUNT(DISTINCT constant) FROM ws_usages
                           WHERE ws_usages.db_domain = core_bridges.db_domain),
            methods     = (SELECT COUNT(DISTINCT method) FROM ws_usages
                           WHERE ws_usages.db_domain = core_bridges.db_domain
                             AND method IS NOT NULL)
    """)
    conn.execute(
        "UPDATE ws_services SET usages = ("
        "  SELECT COUNT(*) FROM ws_usages WHERE ws_usages.constant = ws_services.constant)")
    return len(usages), len(bridges)


def load_sp_calls(conn: sqlite3.Connection, reactor: Path, base: Path) -> tuple[int, int]:
    """Patron E1. Los enums declaran EXECUTE PROCEDURE contra Informix, que es
    el acceso directo anterior al BUS. Se cargan con su estado de uso real."""
    conn.execute("DELETE FROM sp_usages")
    index, rows = {}, []
    for java in sorted(reactor.rglob("persistence/enums/SP*.java")):
        text = read_text(java)
        db_match = RE_SP_DB.search(text)
        if not db_match:
            continue  # SPDBCore es la interfaz, no declara base
        db_name, enum_class = db_match.group(1), java.stem
        for constant, raw_query in RE_SP_ENTRY.findall(text[:db_match.start()]):
            name_match = RE_SP_NAME.match(raw_query)
            if not name_match:
                continue
            sp_id = f"{db_name.lower()}:{name_match.group(1)}:{constant}"
            rows.append((sp_id, db_name, enum_class, constant, name_match.group(1),
                         len(RE_SP_PARAM.findall(raw_query)), raw_query,
                         rel(java, base), "E1-enum", "sin-uso"))
            index[(enum_class, constant)] = sp_id
    conn.executemany("INSERT OR REPLACE INTO sp_calls VALUES (?,?,?,?,?,?,?,?,?,?)", rows)

    found = []
    for java in reactor.rglob("*.java"):
        if java.parent.name == "enums" and java.stem.startswith("SP"):
            continue
        text = read_text(java)
        if "SP" not in text:
            continue
        module = rel(java, reactor).split("/")[0]
        java_class = java_classname(text, java)
        for key in {(e, c) for e, c in RE_SP_USE.findall(text)} & index.keys():
            found.append((index[key], module, rel(java, base), java_class))
    conn.executemany(
        "INSERT INTO sp_usages (sp_call_id, module, file, java_class) VALUES (?,?,?,?)",
        found)
    conn.execute(
        "UPDATE sp_calls SET status = 'en-uso' WHERE id IN (SELECT sp_call_id FROM sp_usages)")
    return len(rows), len(found)


def load_endpoints(conn: sqlite3.Connection, reactor: Path, base: Path) -> int:
    """Patron E3 y E4: UrlConstantes es el catalogo de URLs del canal; los
    controladores Spring dicen cual de ellas esta realmente publicada."""
    constants = {}
    for url_file in reactor.rglob("UrlConstantes.java"):
        for name, value in RE_URL_CONST.findall(read_text(url_file)):
            constants.setdefault(name, value)
    if not constants:
        return 0

    published, consumers = {}, {}
    for java in reactor.rglob("*.java"):
        if java.name == "UrlConstantes.java":
            continue
        text = read_text(java)
        if "UrlConstantes." not in text:
            continue
        module = rel(java, reactor).split("/")[0]
        java_class = java_classname(text, java)
        is_controller = "@RestController" in text or "@Controller" in text
        if is_controller:
            for annotation, constant in RE_MAPPING.findall(text):
                method = {"PostMapping": "POST", "GetMapping": "GET",
                          "PutMapping": "PUT", "DeleteMapping": "DELETE"}.get(annotation)
                if method is None:
                    window = text[text.find(f"UrlConstantes.{constant}"):][:200]
                    verb = RE_HTTP_METHOD.search(window)
                    method = verb.group(1) if verb else "ANY"
                published[constant] = (method, module, java_class, rel(java, base))
        else:
            for constant in set(RE_URL_USE.findall(text)):
                consumers.setdefault(constant, set()).add(java_class)

    rows = []
    for constant, url in sorted(constants.items()):
        method, module, controller, file = published.get(constant, (None, None, None, None))
        rows.append((f"{SYSTEM_ID}:{constant}", constant, url, method, module,
                     controller, file,
                     json.dumps(sorted(consumers.get(constant, []))[:20])))
    conn.executemany("INSERT OR REPLACE INTO endpoints VALUES (?,?,?,?,?,?,?,?)", rows)
    return len(rows)


def load_views(conn: sqlite3.Connection, reactor: Path, base: Path) -> int:
    """Cada FXML es una pantalla de ventanilla. La ruta codifica el area funcional:
    view/<area> o, cuando cuelga de view/core, view/core/<area>."""
    conn.execute("DELETE FROM views")
    rows = []
    for fxml in sorted(reactor.rglob("*.fxml")):
        path = rel(fxml, reactor)
        parts = path.split("/")
        area = parts[-2] if len(parts) > 1 else "raiz"
        if "view" in parts:
            tail = parts[parts.index("view") + 1:-1]
            if tail and tail[0] == "core":
                tail = tail[1:]
            if tail:
                area = tail[0]
        ruta = rel(fxml, base)
        rows.append((ruta, fxml.stem, area, ruta, parts[0]))
    conn.executemany("INSERT OR REPLACE INTO views VALUES (?,?,?,?,?)", rows)
    return conn.execute("SELECT COUNT(*) FROM views").fetchone()[0]


def load_integrations(conn: sqlite3.Connection, reactor: Path, base: Path) -> int:
    """Lo que sale del canal sin pasar por el catalogo de web services. El cliente
    del BUS no es JAX-WS: es XML armado a mano, enviado con Apache HttpClient y
    leido con Jsoup. Se clasifica por lo que el codigo hace, no por su nombre."""
    conn.execute("DELETE FROM integrations")
    rows = []
    for java in sorted(reactor.rglob("*.java")):
        text = read_text(java)
        kinds = set()
        if "javax.xml.soap" in text or "SOAPMessage" in text or "SOAPConnection" in text:
            kinds.add("soap-jaxws")
        if "org.apache.http" in text and ("HttpPost" in text or "HttpGet" in text):
            kinds.add("xml-sobre-http")
        if "org.jsoup" in text:
            kinds.add("parseo-jsoup")
        if "jdbc:" in text.lower() or "DriverManager" in text:
            kinds.add("jdbc-directo")
        urls = sorted({u for u in re.findall(r'"(https?://[^"\s]+)"', text)})
        if urls:
            kinds.add("url-embebida")
        if not kinds:
            continue
        java_class = java_classname(text, java)
        for kind in kinds:
            rows.append((f"{kind}:{java_class}", kind, java_class, rel(java, base),
                         json.dumps(urls[:5]) if kind == "url-embebida" else None))
    conn.executemany("INSERT OR REPLACE INTO integrations VALUES (?,?,?,?,?)", rows)
    return len(rows)


def load_cross_deps(conn: sqlite3.Connection, rescate=None) -> int:
    rows = [(d[0], d[1], d[2], d[3], d[4], json.dumps(d[5]), json.dumps(d[6]),
             d[7], d[8], "documental", d[9], TS_NOW, SYSTEM_ID) for d in CROSS_DEPS]
    conn.executemany(
        "INSERT OR REPLACE INTO cross_dependencies VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)", rows)
    restaurar_ajeno(conn, rescate)
    return conn.execute("SELECT COUNT(*) FROM cross_dependencies").fetchone()[0]


def build_fts(conn: sqlite3.Connection) -> None:
    for table in ("ws_services_fts", "sp_calls_fts", "endpoints_fts",
                  "cross_dependencies_fts"):
        conn.execute(f"DROP TABLE IF EXISTS {table}")
    conn.executescript(FTS_SCHEMA)
    conn.execute("INSERT INTO ws_services_fts(rowid, constant, functional_group) "
                 "SELECT rowid, constant, functional_group FROM ws_services")
    conn.execute("INSERT INTO sp_calls_fts(rowid, id, db_name, constant, sp_name) "
                 "SELECT rowid, id, db_name, constant, sp_name FROM sp_calls")
    conn.execute("INSERT INTO endpoints_fts(rowid, id, constant, url, controller) "
                 "SELECT rowid, id, constant, url, controller FROM endpoints")
    conn.execute("INSERT INTO cross_dependencies_fts(rowid, id, other_system, "
                 "relationship, description) SELECT rowid, id, other_system, "
                 "relationship, description FROM cross_dependencies")


def emit_signals(conn: sqlite3.Connection, counts: dict) -> None:
    conn.execute("DELETE FROM signals")
    for signal_type, value in counts.items():
        conn.execute(
            "INSERT INTO signals (signal_type, source_system, value, metadata, seeded_at) "
            "VALUES (?,?,?,?,?)",
            (signal_type, SYSTEM_ID, value, json.dumps({"brain_version": VERSION}), TS_NOW))


def main() -> int:
    ap = argparse.ArgumentParser(description="Construye el brain.db de SIWEB")
    ap.add_argument("--reset", action="store_true", help="Borra el brain antes de construirlo")
    ap.add_argument("--source", type=Path, default=SOURCE_DIR, help="Ruta del fuente")
    ap.add_argument("--db", type=Path, default=DB_PATH, help="Ruta del brain.db")
    ap.add_argument("--verbose", action="store_true")
    args = ap.parse_args()

    # Regla B12: lo que otro brain sembro aqui sobrevive al --reset.
    rescate = preserve_seed(args.db)
    if args.reset and args.db.exists():
        args.db.unlink()
    conn = sqlite3.connect(args.db)
    conn.executescript(SCHEMA)

    reactor = find_reactor(args.source) if args.source.exists() else None
    if reactor is None:
        print(f"No hay reactor Maven bajo {args.source}. El fuente no esta cargado.")
        load_system_info(conn, None, None, rescate)
        load_received_seeds(conn)
        deps = load_cross_deps(conn, rescate)
        build_fts(conn)
        emit_signals(conn, {"cross_dependencies": deps})
        restaurar_senales(conn, rescate)
        conn.commit()
        conn.close()
        print(f"  cross_dependencies: {deps} (origen documental)")
        return 0

    snapshot = rel(reactor.parent, args.source)
    if args.verbose:
        print(f"[reactor] {reactor}")

    stack = ("Cliente JavaFX por Java Web Start, backend Spring MVC empaquetado como EAR, "
             "acceso al core por web services del BUS, reportes JasperReports")
    load_system_info(conn, snapshot, stack, rescate)
    modules = load_modules(conn, reactor, args.source)
    catalog = load_ws_services(conn, reactor, args.source)
    ws_usages, bridges = load_core_bridges(conn, reactor, args.source, catalog)
    sp_calls, sp_usages = load_sp_calls(conn, reactor, args.source)
    endpoints = load_endpoints(conn, reactor, args.source)
    views = load_views(conn, reactor, args.source)
    integrations = load_integrations(conn, reactor, args.source)
    recibidos = load_received_seeds(conn)
    deps = load_cross_deps(conn, rescate)
    sync_seed_provenance(conn)
    build_fts(conn)
    seeds = emit_seeds(conn)

    q = lambda sql: conn.execute(sql).fetchone()[0]
    counts = {
        "modules": modules,
        "ws_services": len(catalog),
        "ws_services_en_uso": q("SELECT COUNT(*) FROM ws_services WHERE usages > 0"),
        "ws_usages": ws_usages,
        "ws_ids_compartidos": q("SELECT COUNT(*) FROM (SELECT ws_id FROM ws_services "
                                "GROUP BY ws_id HAVING COUNT(*) > 1)"),
        "core_bridges": bridges,
        "sp_calls_heredados": sp_calls,
        "sp_calls_en_uso": q("SELECT COUNT(*) FROM sp_calls WHERE status = 'en-uso'"),
        "sp_usages": sp_usages,
        "endpoints": endpoints,
        "endpoints_publicados": q("SELECT COUNT(*) FROM endpoints WHERE controller IS NOT NULL"),
        "views": views,
        "integrations": integrations,
        "cross_dependencies": deps,
        "seeds_recibidos": recibidos,
        "seeds_emitidos": len(seeds),
    }
    emit_signals(conn, counts)
    restaurar_senales(conn, rescate)
    conn.commit()
    conn.close()

    print(f"brain.db de SIWEB construido en {args.db}")
    print(f"  snapshot del fuente: {snapshot}")
    for key, value in counts.items():
        print(f"  {key}: {value}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
