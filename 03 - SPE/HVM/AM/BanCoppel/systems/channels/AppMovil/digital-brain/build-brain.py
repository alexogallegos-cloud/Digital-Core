#!/usr/bin/env python3
"""
build-brain.py — AppMovil Digital Brain
BanCoppel Application Modernization · SPE-AM-001

Pipeline de construcción del brain.db del canal móvil:
  1. load_services()     — escanea pom.xml de los ~200 microservicios
  2. load_sp_calls()     — extrae llamadas JDBC a SPs Informix desde Constants.java y properties
  3. load_endpoints()    — extrae rutas REST desde application-dev.properties
  4. load_terms()        — minería de vocabulario desde Constants.java
  5. load_dependencies() — dependencias entre microservicios (Feign) y sistemas externos
  6. build_fts()         — construye índices FTS5 para búsqueda semántica
  7. emit_signals()      — emite señales de resumen al brain.db

Uso:
  python build-brain.py [--source <ruta>] [--db <ruta>] [--verbose]

Patrón de naming: msa{domain}-{layer}-{function}[-b]
  domain: ch|cm|cr|dp|im|lo|mg|py|sr|xd
  layer:  b=business, d=domain, p=platform, o=orchestration, s=service, m=middleware, u=utility
"""

import sqlite3
import os
import re
import json
import sys
import argparse
import xml.etree.ElementTree as ET
from pathlib import Path
from datetime import datetime, timezone

sys.stdout.reconfigure(encoding='utf-8', errors='replace')

# ─────────────────────────────────────────────────────────────────
# Configuración
# ─────────────────────────────────────────────────────────────────

SCRIPT_DIR  = Path(__file__).parent
SOURCE_DIR  = SCRIPT_DIR.parent / "source" / "code"
DB_PATH     = SCRIPT_DIR / "brain.db"
SYSTEM_ID   = "app-movil"
VERSION     = "0.1.0"
TS_NOW      = datetime.now(timezone.utc).isoformat()

# Mapa de prefijos de dominio → nombre funcional
DOMAIN_MAP = {
    "ch": "Canal / Channel Infrastructure",
    "cm": "Customer Management",
    "cr": "Credit",
    "dp": "Deposit & Transfer",
    "im": "Infrastructure Messaging",
    "lo": "Lending / Loans",
    "mg": "Messaging",
    "py": "Payments",
    "sr": "Services / ATM",
    "xd": "Cross-domain",
}

# Mapa de capas → descripción
LAYER_MAP = {
    "b": "Business — orquestación de negocio",
    "d": "Domain — lógica de dominio + acceso a datos",
    "p": "Platform — servicios transversales de plataforma",
    "o": "Orchestration — flujos complejos multi-sistema",
    "s": "Service — servicios reutilizables",
    "m": "Middleware — adaptadores e integraciones",
    "u": "Utility — librerías y commons",
    "i": "Integration — capa de integración",
}

# Almas identificadas en dt-almas (pre-validadas)
KNOWN_ALMAS = {
    "msach-p-security-application-validations",
    "msacm-p-security-session-management",
    "msacm-d-security-customer-access-managment",
    "msadp-d-domain-deposit-accounts",
    "msach-b-business-application-data",
    "msapy-d-domain-codi-payment",
    "msacm-d-domain-customer-data",
    "msamg-p-platform-push-notifications-service-management",
    "msacr-d-security-card-data-validation",
    "msasr-d-domain-services-banking-validations",
    "msach-b-business-application-configuration",
    "msacm-d-platform-customer-enrollment-verification",
}

# Constantes que son boilerplate (no aportan vocabulario)
BOILERPLATE_CONSTANTS = {
    "UUID_MDC_LABEL", "MSG_TO_LOG_HEADER", "T0_REQ_ATTRIBUTE", "TIME_ELAPSED_MESSAGE",
    "MSG_CURLY_BRACKETS", "MSG_ERROR_RESPONSE_HAS_NO_BODY", "MSG_ERROR_FORMAT",
    "MSG_STATUS", "MSG_REQUEST", "MSG_RESPONSE", "ERROR_FEIGN_DETAILS",
    "DEFAULT_STATUS_HTTP", "DOWN_STREAM_EXCEPTION_NAME", "ERROR_RESPONSE_DETAILS_FIELD_NAME",
    "ERROR_RESPONSE_UUID_FIELD_NAME", "ERROR_RESPONSE_TIMESTAMP_FIELD_NAME",
    "START_REQUEST", "HEADER_WORD_CONSTANT", "CONTENT_TYPE", "ACCEPT",
    "UUID", "AUTHORIZATION", "OK", "BAD_REQUEST", "INTERNAL_ERROR",
    "OK_CODE", "BAD_REQUEST_CODE", "INTERNAL_ERROR_CODE", "BUSINESS_VALIDATION",
    "EMPTY_STRING", "SPACE_STRING", "COLON", "COMMA_SEPARATOR", "SLASH",
    "JSON_STRING", "SCAN_PACKAGE_ONE", "SCAN_PACKAGE_TWO", "SCAN_PACKAGE_ALL",
    "FORMATO_FECHA_ZDT", "TRANSACCIONAL_LOG", "OPERACIONAL_LOG",
    "BASE_PATH", "SPECIFIC_PATH", "API_OPERATION", "ERROR_RESPONSE_TYPE",
    "ERROR_RESPONSE_CODE", "ERROR_RESPONSE_DETAILS", "ERROR_RESPONSE_LOCATION",
    "ERROR_RESPONSE_MORE_INFORMATION", "NOT_BE_NULL", "NOT_BE_EMPTY",
    "ZERO", "MINUS_ONE", "REQUEST", "RESPONSE", "SP_CALL",
    "USER_MDC_LABEL", "ACCOUNT_TYPE_STRING", "BEAN_EXECUTOR", "PREFIX_EXECUTOR",
    "ACTIVE_STATUS_CONSTANT", "ACCOUNT_STATUS_ACTIVE",
}

# ─────────────────────────────────────────────────────────────────
# Parsers de naming convention
# ─────────────────────────────────────────────────────────────────

def parse_service_name(artifact_id: str) -> dict:
    """
    Parsea el artifactId: msa{domain}-{layer}-{function}[-b]
    Retorna dict con: prefix, domain, domain_name, layer, function, has_variant
    """
    result = {
        "prefix": artifact_id,
        "domain": "??",
        "domain_name": "Unknown",
        "layer": "?",
        "function": artifact_id,
        "has_variant": False,
    }

    if not artifact_id.startswith("msa"):
        return result

    # Extrae dominio (2 chars después de 'msa')
    # e.g. msach → ch, msapy → py, msacm → cm
    rest = artifact_id[3:]  # 'ch-b-business-application-data' o 'acm-...'
    # Dominio es todo hasta el primer '-'
    parts = rest.split("-")
    if len(parts) < 3:
        return result

    domain = parts[0]  # 'ch', 'cm', 'cr', etc.
    layer = parts[1]   # 'b', 'd', 'p', etc.

    # ¿Tiene variante -b al final?
    has_variant = parts[-1] == "b" and len(parts) > 3
    if has_variant:
        function_parts = parts[2:-1]
    else:
        function_parts = parts[2:]

    result.update({
        "domain": domain,
        "domain_name": DOMAIN_MAP.get(domain, f"Unknown ({domain})"),
        "layer": layer,
        "function": "-".join(function_parts),
        "has_variant": has_variant,
    })
    return result


# ─────────────────────────────────────────────────────────────────
# Parsers de archivos
# ─────────────────────────────────────────────────────────────────

NS = {"mvn": "http://maven.apache.org/POM/4.0.0"}

def parse_pom(pom_path: Path) -> dict:
    """Extrae metadata del pom.xml: artifactId, version, java_version, framework, tecnologías."""
    info = {
        "artifact_id": None,
        "version": None,
        "java_version": None,
        "framework": "spring-boot",
        "java_package": None,
        "has_informix": False,
        "has_mongodb": False,
        "has_redis": False,
        "has_feign": False,
        "has_quarkus": False,
    }
    try:
        tree = ET.parse(pom_path)
        root = tree.getroot()

        def find_text(path):
            el = root.find(path, NS)
            return el.text.strip() if el is not None and el.text else None

        info["artifact_id"] = find_text("mvn:artifactId")
        info["version"] = find_text("mvn:version")

        # Java version — en properties o compiler plugin
        props = root.find("mvn:properties", NS)
        if props is not None:
            for child in props:
                tag = child.tag.replace("{http://maven.apache.org/POM/4.0.0}", "")
                if tag in ("java.version", "maven.compiler.release", "maven.compiler.source"):
                    if child.text:
                        info["java_version"] = child.text.strip()
                        break

        # Framework y dependencias
        deps_text = ET.tostring(root, encoding="unicode")
        if "quarkus-bom" in deps_text or "quarkus.platform" in deps_text:
            info["framework"] = "quarkus"
            info["has_quarkus"] = True
        if "informix" in deps_text.lower():
            info["has_informix"] = True
        if "data-mongodb" in deps_text or "mongodb" in deps_text:
            info["has_mongodb"] = True
        if "data-redis" in deps_text or "jedis" in deps_text:
            info["has_redis"] = True
        if "openfeign" in deps_text:
            info["has_feign"] = True

        # java_package — del groupId
        gid = find_text("mvn:groupId")
        if gid:
            info["java_package"] = gid

    except Exception as e:
        pass
    return info


def parse_properties(props_path: Path) -> dict:
    """
    Extrae rutas de API, SPs y configuración de archivos .properties / configMap.yml.
    Patrones de SP cubiertos:
      P_CALL:    = {call db:sp(...)} o = {CALL db:informix.sp(...)}
      P_NOCURL:  = CALL db:sp(...) (sin llaves)
      P_PLAIN:   = db:informix.sp_name o = db:sp_name (sin parámetros)
      P_DBINFER: = sp_xxx (sin prefijo db) — DB inferida del JDBC URL si única en el archivo
    """
    result = {
        "base_path": None,
        "specific_paths": [],
        "sp_names": {},      # {prop_key: "db_name:sp_name"} — normalizado
        "valid_channels": None,
        "operation_ids": {},
    }
    if not props_path.exists():
        return result

    # P_CALL: {[Cc]all db[:informix.]sp(...)}  o  CALL db[:informix.]sp(...)
    CALL_RE = re.compile(
        r'(?:\{)?[Cc][Aa][Ll][Ll]\s+([\w]+):(informix\.)?([\w]+)\s*[\(\{]',
        re.IGNORECASE
    )
    # P_PLAIN: db:informix.sp_name o db:sp_name sin call (valor empieza con bdi* o similar)
    PLAIN_RE = re.compile(
        r'^(bdi[\w]+|intercard\w*|bdmis):(informix\.)?([\w]+)',
        re.IGNORECASE
    )
    # P_DBINFER: extrae DB del JDBC URL (spring.datasource.url)
    JDBC_URL_RE = re.compile(r'jdbc:informix-sqli://[^/]+/(\w+)', re.IGNORECASE)
    # P_DBINFER: valores que son nombre de SP sin prefijo de DB (empieza con sp/sps/spc)
    SP_NOPREFIX_RE = re.compile(r'^(sp[\w]+)\s*$', re.IGNORECASE)
    # P_DBINFER: solo aplica cuando la clave de la propiedad indica que es un SP
    _SP_KEY_HINT = re.compile(
        r'(?:storedprocedure|storeprocedure|procedure|nametransaction)',
        re.IGNORECASE
    )

    jdbc_dbs: list = []       # DBs encontradas en JDBC URLs del archivo
    no_prefix_sps: dict = {}  # {prop_key: sp_name} — SPs sin DB prefix, a resolver

    try:
        lines = props_path.read_text(encoding="utf-8", errors="replace").splitlines()
        for line in lines:
            line = line.strip()
            if "=" not in line or line.startswith("#"):
                continue
            key, _, val = line.partition("=")
            key = key.strip()
            val = val.strip()

            if key == "constants.api.uri.basePath":
                result["base_path"] = val
            elif "constants.api.uri.specificPath" in key:
                result["specific_paths"].append(val)
            elif key == "valid.channels":
                result["valid_channels"] = val
            elif key.startswith("constants.log.operationId."):
                op_name = key.split(".")[-1]
                result["operation_ids"][op_name] = val

            # P_JDBC: detectar URL JDBC para inferencia de DB
            m_jdbc = JDBC_URL_RE.search(val)
            if m_jdbc:
                jdbc_dbs.append(m_jdbc.group(1).lower())
                continue

            # Detectar referencia a SP en el valor
            m_call = CALL_RE.search(val)
            if m_call:
                db_name = m_call.group(1).lower()
                sp_name = _normalize_sp_name(m_call.group(3))
                result["sp_names"][key] = f"{db_name}:{sp_name}"
                continue

            m_plain = PLAIN_RE.match(val)
            if m_plain:
                db_name = m_plain.group(1).lower()
                sp_name = _normalize_sp_name(m_plain.group(3))
                # Skip table-name prefixes comunes en Informix (no son SPs)
                if re.match(r'^(tbl|si_|tb_)', sp_name, re.IGNORECASE):
                    continue
                result["sp_names"][key] = f"{db_name}:{sp_name}"
                continue

            # P_DBINFER: SP sin prefijo de DB — solo en propiedades SP-keyed
            if _SP_KEY_HINT.search(key):
                m_noprefix = SP_NOPREFIX_RE.match(val)
                if m_noprefix:
                    no_prefix_sps[key] = _normalize_sp_name(val)

    except Exception:
        pass

    # Aplicar DB inferida si TODAS las URLs del archivo apuntan a la misma DB
    unique_dbs = set(jdbc_dbs)
    if len(unique_dbs) == 1 and no_prefix_sps:
        inferred_db = unique_dbs.pop()
        for k, sp in no_prefix_sps.items():
            result["sp_names"][k] = f"{inferred_db}:{sp}"

    return result


def _normalize_sp_name(sp_raw: str) -> str:
    """Strip 'informix.' prefix and params from a raw SP name fragment."""
    sp = sp_raw.strip()
    if sp.lower().startswith("informix."):
        sp = sp[len("informix."):]
    return sp.split("(")[0].split(",")[0].strip().lower()


# Prefijos de base de datos Informix reconocidos en BanCoppel
_INFORMIX_DBS = re.compile(
    r'^(bdi\w+|intercard\w*|bdmis|msa\w+)',
    re.IGNORECASE
)


def extract_sp_calls_from_java(java_dir: Path) -> list:
    """
    Extrae llamadas a SPs Informix de TODOS los archivos *Constants.java.
    Patrones cubiertos:
      P1:  {call db:sp(...)} o {call db:informix.sp(...)} — JDBC clásico
      P2:  EXECUTE PROCEDURE db:sp(...) o db\\:sp(...) — JPA nativeQuery (1 backslash)
      P6c: "db:sp_name" literal plain sin CALL/EXECUTE wrapper
      P6d: "db\\\\:sp_name" colon doblemente escapado (JPA con 2 backslashes en fuente)
    Retorna lista de dicts: {constant_name, sp_full, db_name, sp_name, param_count, source_file}
    """
    calls = []
    seen = set()

    # P1: {[Cc][Aa][Ll][Ll] db[:informix.]sp(...)}
    CALL_RE = re.compile(
        r'\{[Cc][Aa][Ll][Ll]\s+([\w]+):(informix\.)?([\w]+)\s*\(([^)]*)\)\}',
        re.DOTALL
    )
    # P2: EXECUTE PROCEDURE db[\:]sp(...)  (backslash optional — JPA escaping, 1 backslash)
    EXEC_RE = re.compile(
        r'EXECUTE\s+PROCEDURE\s+([\w]+)\\?:(informix\.)?([\w]+)',
        re.IGNORECASE
    )
    # P3: nombre de constante con valor standalone "sp_xxx" (para cruzar con P2)
    CONST_NAME_RE = re.compile(
        r'public\s+static\s+final\s+String\s+(\w+)\s*=\s*"(sp_[\w]+)"'
    )
    # P6c: "db:sp_name" o "db:informix.sp_name" plain string literal sin wrapper CALL/EXECUTE
    # No requiere prefijo sp_ — SPs pueden llamarse abono_ref, cargo_ref, reversion, etc.
    # La closing " garantiza que no capturamos URLs ni strings con punto+slash después
    PLAIN_JAVA_RE = re.compile(
        r'"(bdi[\w]+|intercard[\w]*):(informix\.)?([a-z][a-z0-9_]+)"',
        re.IGNORECASE
    )
    # Nombres a descartar en P6c — prefijos de tabla Y la palabra "informix" sola
    _TBL_PREFIX_RE = re.compile(r'^(tbl|si_|tb_|informix$)', re.IGNORECASE)

    # P6d: "db\\:sp_name" — colon escapado con 2 backslashes en el fuente .java
    # Discriminante: si el qualifier "informix." está presente → es referencia a TABLA, no SP
    ESCAPED_COLON_RE = re.compile(
        r'"(bdi[\w]+|intercard[\w]*)\\\\:(informix\.)?([\w]+)',
        re.IGNORECASE
    )

    for java_file in java_dir.rglob("*Constants.java"):
        try:
            text = java_file.read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue

        rel_path = str(java_file.relative_to(java_dir))

        # P1 — {call db:sp(...)}
        for m in CALL_RE.finditer(text):
            db_raw  = m.group(1)
            sp_raw  = m.group(3)
            params  = m.group(4).count("?")
            db_name = db_raw.lower()
            sp_name = _normalize_sp_name(sp_raw)
            key = (db_name, sp_name)
            if key in seen:
                continue
            seen.add(key)
            calls.append({
                "constant_name": f"CALL_P1_{sp_name.upper()[:30]}",
                "sp_full": m.group(0)[:120],
                "db_name": db_name,
                "sp_name": sp_name,
                "param_count": params,
                "source_file": rel_path,
            })

        # P2 — EXECUTE PROCEDURE db:sp(...)
        for m in EXEC_RE.finditer(text):
            db_raw  = m.group(1)
            sp_raw  = m.group(3)
            db_name = db_raw.lower()
            sp_name = _normalize_sp_name(sp_raw)
            # Skip if looks like a logger format (contains {} for placeholders)
            nearby = text[max(0, m.start()-20):m.end()+40]
            if "'{}'".lower() in nearby.lower() or '{}' in nearby:
                continue
            key = (db_name, sp_name)
            if key in seen:
                continue
            seen.add(key)
            calls.append({
                "constant_name": f"EXEC_P2_{sp_name.upper()[:30]}",
                "sp_full": m.group(0)[:120],
                "db_name": db_name,
                "sp_name": sp_name,
                "param_count": 0,
                "source_file": rel_path,
            })

        # P6c — "db:sp_name" o "db:informix.sp_name" plain string literal
        for m in PLAIN_JAVA_RE.finditer(text):
            db_name = m.group(1).lower()
            # group(2) = "informix." qualifier (opcional), group(3) = nombre
            sp_name = _normalize_sp_name(m.group(3))
            if not sp_name or _TBL_PREFIX_RE.match(sp_name):
                continue
            key = (db_name, sp_name)
            if key in seen:
                continue
            seen.add(key)
            calls.append({
                "constant_name": f"PLAIN_P6C_{sp_name.upper()[:30]}",
                "sp_full": m.group(0)[:120],
                "db_name": db_name,
                "sp_name": sp_name,
                "param_count": 0,
                "source_file": rel_path,
            })

        # P6d — "db\\:sp_name" escaped-colon (2 backslashes en el fuente)
        # Discriminante: informix. qualifier → referencia a TABLA → descartar
        for m in ESCAPED_COLON_RE.finditer(text):
            if m.group(2) is not None:   # "informix." qualifier presente = tabla, no SP
                continue
            db_name = m.group(1).lower()
            sp_name = _normalize_sp_name(m.group(3))
            if not sp_name or _TBL_PREFIX_RE.match(sp_name):
                continue
            key = (db_name, sp_name)
            if key in seen:
                continue
            seen.add(key)
            calls.append({
                "constant_name": f"ESC_P6D_{sp_name.upper()[:30]}",
                "sp_full": m.group(0)[:120],
                "db_name": db_name,
                "sp_name": sp_name,
                "param_count": 0,
                "source_file": rel_path,
            })

    return calls


def extract_vocabulary_from_java(java_dir: Path, service_id: str) -> list:
    """
    Minería de vocabulario desde Constants.java.
    Extrae constantes String con valor semánticamente relevante.
    Retorna lista de dicts: {term, cat, meaning, source}
    """
    terms = []
    const_re = re.compile(
        r'public\s+static\s+final\s+String\s+(\w+)\s*=\s*"([^"]{3,80})"'
    )

    # Patrones para filtrar valores que NO son vocabulario
    exclude_patterns = [
        r'\{\}',               # format strings
        r'^%[a-zA-Z]',        # log patterns
        r'^\d+$',              # pure numbers as strings
        r'^https?://',         # URLs
        r'^\^',                # regex
        r'\\[dDwWsS]',        # regex escape
        r'\[%X\{',             # log format
        r'classpath:',
        r'swagger-ui',
        r'webjars',
        r'@project\.',
        r'^\s*$',
    ]
    exclude_compiled = [re.compile(p) for p in exclude_patterns]

    # Vocabulario valioso: nombres de SPs, mensajes en español, operaciones bancarias
    valuable_patterns = [
        re.compile(r'\{call\s+\w+:\w+', re.IGNORECASE),  # SP call
        re.compile(r'[a-záéíóúüñ]{4,}', re.IGNORECASE),  # Spanish words
        re.compile(r'^(sp_|spc|bdi)', re.IGNORECASE),    # SP names
        re.compile(r'Exception$'),                         # Exception names
        re.compile(r'^\d{6}$'),                           # 6-digit error codes
        re.compile(r'^[A-Z][a-z]'),                       # CamelCase (class-like)
    ]

    # Categorías inferidas por prefijo del nombre de constante
    def infer_cat(name: str, value: str) -> str:
        n = name.upper()
        if "ERROR" in n or "EXCEPTION" in n or "CODE" in n:
            return "ERROR"
        if "SP_" in n or "CALL" in n or value.startswith("{call"):
            return "ENTIDAD"  # SP
        if "PATH" in n or "URI" in n or "URL" in n:
            return "CONFIGURACION"
        if "MSG" in n or "LOG" in n or "DEBUG" in n or "MESSAGE" in n:
            return "CONFIGURACION"
        if "BEAN" in n or "PACKAGE" in n or "FORMAT" in n:
            return "INFRAESTRUCTURA"
        return "ENTIDAD"

    constants_files = list(java_dir.rglob("constant/Constants.java"))
    for cf in constants_files:
        try:
            text = cf.read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue

        rel = str(cf.relative_to(java_dir))

        for match in const_re.finditer(text):
            const_name = match.group(1)
            value      = match.group(2)

            # Skip boilerplate
            if const_name in BOILERPLATE_CONSTANTS:
                continue

            # Skip excluded patterns
            excluded = any(p.search(value) for p in exclude_compiled)
            if excluded:
                continue

            # Check if valuable
            is_valuable = any(p.search(value) for p in valuable_patterns)
            if not is_valuable and len(value) < 8:
                continue

            cat = infer_cat(const_name, value)
            terms.append({
                "term": value,
                "cat": cat,
                "meaning": f"{const_name} en {service_id}",
                "source": f"{service_id}/{rel}",
                "confidence": "MEDIA",
            })

    return terms


def find_feign_clients(java_dir: Path) -> list:
    """Busca @FeignClient en archivos .java. Retorna lista de target service names."""
    targets = []
    feign_re = re.compile(r'@FeignClient\s*\([^)]*name\s*=\s*["\']([^"\']+)["\']')
    for jf in java_dir.rglob("*.java"):
        try:
            text = jf.read_text(encoding="utf-8", errors="replace")
            for m in feign_re.finditer(text):
                targets.append(m.group(1))
        except Exception:
            pass
    return list(set(targets))


# ─────────────────────────────────────────────────────────────────
# Inicialización del DB
# ─────────────────────────────────────────────────────────────────

SCHEMA = """
CREATE TABLE IF NOT EXISTS system_info (
    key   TEXT PRIMARY KEY,
    value TEXT
);

CREATE TABLE IF NOT EXISTS signals (
    id     INTEGER PRIMARY KEY AUTOINCREMENT,
    signal TEXT NOT NULL,
    value  TEXT,
    source TEXT,
    ts     TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS services (
    id             TEXT PRIMARY KEY,
    domain         TEXT,
    domain_name    TEXT,
    layer          TEXT,
    layer_name     TEXT,
    function_name  TEXT,
    has_variant    INTEGER DEFAULT 0,
    version        TEXT,
    java_version   TEXT,
    framework      TEXT DEFAULT 'spring-boot',
    java_package   TEXT,
    has_informix   INTEGER DEFAULT 0,
    has_mongodb    INTEGER DEFAULT 0,
    has_redis      INTEGER DEFAULT 0,
    has_feign      INTEGER DEFAULT 0,
    has_sp_calls   INTEGER DEFAULT 0,
    is_alma        INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS sp_calls (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    service_id    TEXT,
    constant_name TEXT,
    sp_full       TEXT,
    db_name       TEXT,
    sp_name       TEXT,
    param_count   INTEGER DEFAULT 0,
    source_file   TEXT,
    FOREIGN KEY (service_id) REFERENCES services(id)
);

CREATE TABLE IF NOT EXISTS endpoints (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    service_id    TEXT,
    base_path     TEXT,
    specific_path TEXT,
    full_path     TEXT,
    FOREIGN KEY (service_id) REFERENCES services(id)
);

CREATE TABLE IF NOT EXISTS sp_properties (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    service_id  TEXT,
    prop_key    TEXT,
    sp_value    TEXT,
    db_name     TEXT,
    sp_name     TEXT,
    FOREIGN KEY (service_id) REFERENCES services(id)
);

CREATE TABLE IF NOT EXISTS terms (
    term       TEXT PRIMARY KEY,
    cat        TEXT,
    meaning    TEXT,
    source     TEXT,
    confidence TEXT DEFAULT 'MEDIA'
);

CREATE TABLE IF NOT EXISTS feign_calls (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    source_service TEXT,
    target_service TEXT,
    FOREIGN KEY (source_service) REFERENCES services(id)
);

CREATE TABLE IF NOT EXISTS cross_dependencies (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    source_system TEXT NOT NULL,
    target_system TEXT NOT NULL,
    direction     TEXT,
    volume        INTEGER,
    evidence      TEXT
);
"""

FTS_SCHEMA = """
CREATE VIRTUAL TABLE IF NOT EXISTS services_fts
    USING fts5(id, domain_name, function_name, content='services', content_rowid='rowid');

CREATE VIRTUAL TABLE IF NOT EXISTS terms_fts
    USING fts5(term, meaning, content='terms', content_rowid='rowid');
"""


def init_db(conn: sqlite3.Connection):
    # Drop todas las tablas existentes para garantizar schema limpio
    conn.executescript("""
        DROP TABLE IF EXISTS services_fts;
        DROP TABLE IF EXISTS terms_fts;
        DROP TABLE IF EXISTS feign_calls;
        DROP TABLE IF EXISTS cross_dependencies;
        DROP TABLE IF EXISTS sp_properties;
        DROP TABLE IF EXISTS sp_calls;
        DROP TABLE IF EXISTS endpoints;
        DROP TABLE IF EXISTS terms;
        DROP TABLE IF EXISTS services;
        DROP TABLE IF EXISTS signals;
        DROP TABLE IF EXISTS system_info;
    """)
    conn.executescript(SCHEMA)
    conn.commit()
    # Seed system_info
    meta = [
        ("system_id", SYSTEM_ID),
        ("togaf_type", "channels"),
        ("togaf_state", "discovering"),
        ("version", VERSION),
        ("built_at", TS_NOW),
        ("source_dir", str(SOURCE_DIR)),
    ]
    conn.executemany("INSERT INTO system_info VALUES (?, ?)", meta)
    conn.commit()


# ─────────────────────────────────────────────────────────────────
# Loaders
# ─────────────────────────────────────────────────────────────────

def load_services(conn: sqlite3.Connection, verbose: bool = False):
    """Escanea pom.xml de cada microservicio y popula la tabla services."""
    rows = []
    for pom in sorted(SOURCE_DIR.glob("*/pom.xml")):
        svc_dir = pom.parent
        pom_info = parse_pom(pom)

        artifact_id = pom_info.get("artifact_id") or svc_dir.name
        parsed = parse_service_name(artifact_id)

        row = (
            artifact_id,
            parsed["domain"],
            parsed["domain_name"],
            parsed["layer"],
            LAYER_MAP.get(parsed["layer"], parsed["layer"]),
            parsed["function"],
            1 if parsed["has_variant"] else 0,
            pom_info.get("version"),
            pom_info.get("java_version"),
            pom_info.get("framework", "spring-boot"),
            pom_info.get("java_package"),
            1 if pom_info.get("has_informix") else 0,
            1 if pom_info.get("has_mongodb") else 0,
            1 if pom_info.get("has_redis") else 0,
            1 if pom_info.get("has_feign") else 0,
            0,  # has_sp_calls — se actualiza en load_sp_calls
            1 if artifact_id in KNOWN_ALMAS else 0,
        )
        rows.append(row)
        if verbose:
            print(f"  ✓ {artifact_id} [{parsed['domain']}/{parsed['layer']}] {pom_info.get('framework','?')}")

    conn.executemany("""
        INSERT OR REPLACE INTO services
        (id, domain, domain_name, layer, layer_name, function_name, has_variant,
         version, java_version, framework, java_package,
         has_informix, has_mongodb, has_redis, has_feign, has_sp_calls, is_alma)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, rows)
    conn.commit()
    print(f"[services] {len(rows)} microservicios cargados")


def load_sp_calls(conn: sqlite3.Connection, verbose: bool = False):
    """
    Extrae llamadas a SPs Informix desde todas las fuentes:
    1. ALL *Constants.java — patrones {call db:sp} y EXECUTE PROCEDURE
    2. ALL application*.properties — patrones CALL, {CALL}, plain db:sp_name
    """
    sp_rows = []
    prop_rows = []
    services_with_calls = set()

    for svc_dir in sorted(SOURCE_DIR.iterdir()):
        if not svc_dir.is_dir():
            continue
        artifact_id = svc_dir.name

        # 1. Todos los *Constants.java bajo src/main/java
        java_dir = svc_dir / "src" / "main" / "java"
        if java_dir.exists():
            calls = extract_sp_calls_from_java(java_dir)
            for c in calls:
                sp_rows.append((
                    artifact_id,
                    c["constant_name"],
                    c["sp_full"],
                    c["db_name"],
                    c["sp_name"],
                    c["param_count"],
                    c["source_file"],
                ))
                services_with_calls.add(artifact_id)
                if verbose:
                    print(f"  SP-java {artifact_id}: {c['db_name']}:{c['sp_name']} ({c['param_count']}p) [{c['constant_name']}]")

        # 2. Todos los archivos .properties y configMap.yml
        prop_candidates = [
            svc_dir / "config" / "application-dev.properties",
            svc_dir / "config" / "application.properties",
            svc_dir / "src" / "main" / "resources" / "application-dev.properties",
            svc_dir / "src" / "main" / "resources" / "application.properties",
            svc_dir / "src" / "main" / "jkube" / "configMap.yml",    # P8
        ]
        for prop_file in prop_candidates:
            if not prop_file.exists():
                continue
            props = parse_properties(prop_file)
            for key, sp_value in props["sp_names"].items():
                if ":" in sp_value:
                    db_name, sp_name = sp_value.split(":", 1)
                    prop_rows.append((artifact_id, key, sp_value, db_name, sp_name))
                    services_with_calls.add(artifact_id)
                    if verbose:
                        print(f"  SP-prop {artifact_id}: {sp_value} [{key}]")

    conn.executemany("""
        INSERT OR IGNORE INTO sp_calls (service_id, constant_name, sp_full, db_name, sp_name, param_count, source_file)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    """, sp_rows)

    conn.executemany("""
        INSERT OR IGNORE INTO sp_properties (service_id, prop_key, sp_value, db_name, sp_name)
        VALUES (?, ?, ?, ?, ?)
    """, prop_rows)

    # Actualiza has_sp_calls
    for svc_id in services_with_calls:
        conn.execute("UPDATE services SET has_sp_calls = 1 WHERE id = ?", (svc_id,))

    conn.commit()
    print(f"[sp_calls] {len(sp_rows)} SP calls desde *Constants.java (P1+P2+P6c+P6d)")
    print(f"[sp_properties] {len(prop_rows)} SP refs desde *.properties / configMap.yml (P3+P4+P5+P_DBINFER+P8)")


def load_endpoints(conn: sqlite3.Connection, verbose: bool = False):
    """Extrae rutas REST desde application-dev.properties."""
    rows = []
    for svc_dir in sorted(SOURCE_DIR.iterdir()):
        if not svc_dir.is_dir():
            continue
        artifact_id = svc_dir.name

        for prop_file in [
            svc_dir / "config" / "application-dev.properties",
            svc_dir / "src" / "main" / "resources" / "application-dev.properties",
        ]:
            if prop_file.exists():
                props = parse_properties(prop_file)
                base = props.get("base_path") or ""
                for specific in props.get("specific_paths", []):
                    full = base + specific if specific.startswith("/") else specific
                    rows.append((artifact_id, base, specific, full))
                    if verbose:
                        print(f"  EP {artifact_id}: {full}")
                break

    conn.executemany("""
        INSERT OR IGNORE INTO endpoints (service_id, base_path, specific_path, full_path)
        VALUES (?, ?, ?, ?)
    """, rows)
    conn.commit()
    print(f"[endpoints] {len(rows)} endpoints cargados")


def load_terms(conn: sqlite3.Connection, verbose: bool = False):
    """Minería de vocabulario desde Constants.java de todos los microservicios."""
    all_terms = {}  # term → dict (deduplica por valor)

    for svc_dir in sorted(SOURCE_DIR.iterdir()):
        if not svc_dir.is_dir():
            continue
        artifact_id = svc_dir.name
        java_dir = svc_dir / "src" / "main" / "java"
        if not java_dir.exists():
            continue

        terms = extract_vocabulary_from_java(java_dir, artifact_id)
        for t in terms:
            term_key = t["term"]
            if term_key not in all_terms:
                all_terms[term_key] = t
            # Si el término ya existe, acumula la fuente
            else:
                existing = all_terms[term_key]
                if artifact_id not in existing["source"]:
                    existing["source"] += f"; {artifact_id}"

    # Añade términos del vocabulario seed (vocabulario-appmovil.md ya tiene 109 términos)
    # Los términos de código son adicionales y complementarios
    rows = [(t["term"], t["cat"], t["meaning"], t["source"], t["confidence"])
            for t in all_terms.values()]

    conn.executemany("""
        INSERT OR IGNORE INTO terms (term, cat, meaning, source, confidence)
        VALUES (?, ?, ?, ?, ?)
    """, rows)
    conn.commit()
    print(f"[terms] {len(rows)} términos de vocabulario minados del código")


def load_dependencies(conn: sqlite3.Connection, verbose: bool = False):
    """
    Carga dependencias entre microservicios (Feign) y dependencias de sistemas externos.
    """
    feign_rows = []
    for svc_dir in sorted(SOURCE_DIR.iterdir()):
        if not svc_dir.is_dir():
            continue
        artifact_id = svc_dir.name
        java_dir = svc_dir / "src" / "main" / "java"
        if not java_dir.exists():
            continue

        targets = find_feign_clients(java_dir)
        for t in targets:
            feign_rows.append((artifact_id, t))
            if verbose:
                print(f"  Feign {artifact_id} → {t}")

    conn.executemany("""
        INSERT OR IGNORE INTO feign_calls (source_service, target_service)
        VALUES (?, ?)
    """, feign_rows)

    # Cross-dependencies con sistemas externos
    # Basado en tecnologías detectadas en los servicios
    informix_count = conn.execute("SELECT COUNT(*) FROM services WHERE has_informix=1").fetchone()[0]
    mongodb_count  = conn.execute("SELECT COUNT(*) FROM services WHERE has_mongodb=1").fetchone()[0]
    redis_count    = conn.execute("SELECT COUNT(*) FROM services WHERE has_redis=1").fetchone()[0]
    sp_count       = conn.execute("SELECT COUNT(*) FROM sp_calls").fetchone()[0] + \
                     conn.execute("SELECT COUNT(*) FROM sp_properties").fetchone()[0]

    cross = [
        ("app-movil", "informix", "outbound", sp_count,
         f"{informix_count} microservicios con JDBC Informix; {sp_count} referencias a SPs"),
        ("app-movil", "mongodb-bdibex", "outbound", mongodb_count,
         f"{mongodb_count} microservicios con MongoDB; base bdibex en Atlas"),
        ("app-movil", "redis-sessions", "outbound", redis_count,
         f"{redis_count} microservicios con Redis; gestión de sesiones TTL=1200s"),
        ("informix", "app-movil", "inbound", 363,
         "Seed Informix: 363 endpoints del canal invocan SPs del core"),
    ]
    conn.executemany("""
        INSERT OR IGNORE INTO cross_dependencies
        (source_system, target_system, direction, volume, evidence)
        VALUES (?, ?, ?, ?, ?)
    """, cross)
    conn.commit()
    print(f"[feign_calls] {len(feign_rows)} dependencias Feign inter-microservicio")
    print(f"[cross_deps] Informix({informix_count} MSAs), MongoDB({mongodb_count}), Redis({redis_count})")


def build_fts(conn: sqlite3.Connection):
    """Construye índices FTS5 para búsqueda semántica."""
    # Drop y recrear FTS
    conn.executescript("""
        DROP TABLE IF EXISTS services_fts;
        DROP TABLE IF EXISTS terms_fts;
    """)
    conn.executescript(FTS_SCHEMA)

    # Populate FTS
    conn.execute("""
        INSERT INTO services_fts(rowid, id, domain_name, function_name)
        SELECT rowid, id, domain_name, function_name FROM services
    """)
    conn.execute("""
        INSERT INTO terms_fts(rowid, term, meaning)
        SELECT rowid, term, meaning FROM terms
    """)
    conn.commit()
    print("[fts] Índices FTS5 construidos para services y terms")


def emit_signals(conn: sqlite3.Connection):
    """Emite señales de resumen al brain.db."""
    total_services = conn.execute("SELECT COUNT(*) FROM services").fetchone()[0]
    total_almas    = conn.execute("SELECT COUNT(*) FROM services WHERE is_alma=1").fetchone()[0]
    total_sp_calls = conn.execute("SELECT COUNT(*) FROM sp_calls").fetchone()[0]
    total_sp_props = conn.execute("SELECT COUNT(*) FROM sp_properties").fetchone()[0]
    total_endpoints= conn.execute("SELECT COUNT(*) FROM endpoints").fetchone()[0]
    total_terms    = conn.execute("SELECT COUNT(*) FROM terms").fetchone()[0]
    total_feign    = conn.execute("SELECT COUNT(*) FROM feign_calls").fetchone()[0]

    informix_svcs  = conn.execute("SELECT COUNT(*) FROM services WHERE has_informix=1").fetchone()[0]
    mongodb_svcs   = conn.execute("SELECT COUNT(*) FROM services WHERE has_mongodb=1").fetchone()[0]
    redis_svcs     = conn.execute("SELECT COUNT(*) FROM services WHERE has_redis=1").fetchone()[0]
    quarkus_svcs   = conn.execute("SELECT COUNT(*) FROM services WHERE framework='quarkus'").fetchone()[0]

    # Dominios únicos
    domains = conn.execute(
        "SELECT domain, COUNT(*) as cnt FROM services GROUP BY domain ORDER BY cnt DESC"
    ).fetchall()
    domains_summary = "; ".join(f"{d[0]}={d[1]}" for d in domains)

    # SPs únicos por base de datos (union sp_calls + sp_properties)
    sp_by_db = conn.execute("""
        SELECT db_name, COUNT(DISTINCT sp_name) as n
        FROM (
            SELECT db_name, sp_name FROM sp_calls
            UNION
            SELECT db_name, sp_name FROM sp_properties
        )
        GROUP BY db_name ORDER BY n DESC
    """).fetchall()
    sp_db_summary = "; ".join(f"{r[0]}:{r[1]}SPs" for r in sp_by_db)

    total_unique_sps = conn.execute("""
        SELECT COUNT(DISTINCT sp_name) FROM (
            SELECT sp_name FROM sp_calls UNION SELECT sp_name FROM sp_properties
        )
    """).fetchone()[0]

    signals = [
        ("total_services",    str(total_services),     "build-brain.py"),
        ("total_almas",       str(total_almas),         "build-brain.py"),
        ("total_sp_calls",    str(total_sp_calls + total_sp_props), "build-brain.py"),
        ("total_endpoints",   str(total_endpoints),     "build-brain.py"),
        ("total_terms",       str(total_terms),         "build-brain.py"),
        ("total_feign_deps",  str(total_feign),         "build-brain.py"),
        ("informix_services", str(informix_svcs),       "build-brain.py"),
        ("mongodb_services",  str(mongodb_svcs),        "build-brain.py"),
        ("redis_services",    str(redis_svcs),          "build-brain.py"),
        ("quarkus_services",  str(quarkus_svcs),        "build-brain.py"),
        ("domain_distribution", domains_summary,        "build-brain.py"),
        ("sp_by_informix_db", sp_db_summary,            "build-brain.py"),
        ("total_unique_sps",  str(total_unique_sps),    "build-brain.py"),
        ("built_at",          TS_NOW,                   "build-brain.py"),
    ]
    conn.executemany(
        "INSERT INTO signals (signal, value, source) VALUES (?, ?, ?)",
        signals
    )
    conn.commit()

    print("\n" + "═" * 60)
    print(f"  AppMovil Brain — build completo {TS_NOW[:10]}")
    print("═" * 60)
    print(f"  Microservicios : {total_services}")
    print(f"  Almas          : {total_almas}")
    print(f"  SP calls       : {total_sp_calls + total_sp_props}  (código+properties)")
    print(f"  Endpoints      : {total_endpoints}")
    print(f"  Términos vocab : {total_terms}")
    print(f"  Feign deps     : {total_feign}")
    print(f"  Con Informix   : {informix_svcs} MSAs")
    print(f"  Con MongoDB    : {mongodb_svcs} MSAs")
    print(f"  Con Redis      : {redis_svcs} MSAs")
    print(f"  Con Quarkus    : {quarkus_svcs} MSAs")
    print(f"  Dominios       : {domains_summary}")
    print(f"  SPs únicos     : {total_unique_sps}  (en {len(sp_by_db)} BDs Informix)")
    if sp_db_summary:
        print(f"  SPs por BD     : {sp_db_summary}")
    print("═" * 60)


# ─────────────────────────────────────────────────────────────────
# CLI
# ─────────────────────────────────────────────────────────────────

def main():
    global SOURCE_DIR, DB_PATH

    parser = argparse.ArgumentParser(description="Build AppMovil brain.db")
    parser.add_argument("--source", type=Path, default=SOURCE_DIR,
                        help="Ruta al directorio source/code/ de AppMovil")
    parser.add_argument("--db",     type=Path, default=DB_PATH,
                        help="Ruta de salida para brain.db")
    parser.add_argument("--verbose", "-v", action="store_true",
                        help="Mostrar detalle de cada elemento procesado")
    args = parser.parse_args()

    SOURCE_DIR = args.source
    DB_PATH    = args.db

    if not SOURCE_DIR.exists():
        print(f"ERROR: source dir no encontrado: {SOURCE_DIR}")
        return 1

    print(f"[build-brain] AppMovil — {TS_NOW[:10]}")
    print(f"  source : {SOURCE_DIR}")
    print(f"  db     : {DB_PATH}")
    print()

    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA journal_mode=WAL")
    conn.execute("PRAGMA foreign_keys=OFF")

    try:
        init_db(conn)
        load_services(conn, args.verbose)
        load_sp_calls(conn, args.verbose)
        load_endpoints(conn, args.verbose)
        load_terms(conn, args.verbose)
        load_dependencies(conn, args.verbose)
        build_fts(conn)
        emit_signals(conn)
    finally:
        conn.close()

    print(f"\n✓ brain.db listo en: {DB_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())