#!/usr/bin/env python3
"""
Banamex Gemelo Cognitivo — Extractor COBOL/ALGOL/DASDL/WFL (Unisys ClearPath MCP)

Columna COBOL / Unisys MCP del método HVM-wide:
    .../High Velocity Modernization/metodologia-gemelo-cognitivo.md  §4

Implementa las capas 1-4 del Gemelo (extracción AS-IS):
  Capa 1 · Lenguaje   → vocabulario de párrafos, data-items, records DASDL
  Capa 2 · Almas      → autoría declarada (headers, tickets MTP/FSW/INI-FIN)
  Capa 3 · Biografía  → fechas en logs de modificación
  Capa 4 · Intención  → call graph (PERFORM/CALL/RUN/LIBRARY), acceso a datos (BDB/$SET/DATABASE)

Produce:
  data/{SISTEMA}/gemelo-{sistema}.json       — JSON normalizado §6 del método
  data/{SISTEMA}/dependency-graph-{sistema}.json — grafo para render_graph.py

Uso:
  python extract.py S500
  python extract.py S151
  python extract.py S500 S151   ← ambos sistemas
"""

import os
import re
import json
import sys
import argparse
from pathlib import Path
from collections import defaultdict

# ─── Rutas ────────────────────────────────────────────────────────────────────

BASE = Path(__file__).parent.parent  # Banamex/

SYSTEM_CONFIG = {
    "S500": {
        "source_dir": BASE / "S500/source/S500/extracted_source",
        "detect_type": lambda f: _s500_type(f),
        "extract_name": lambda f: _s500_name(f),
    },
    "S151": {
        "source_dir": BASE / "S151/source/S151",
        "detect_type": lambda f: _s151_type(f),
        "extract_name": lambda f: _s151_name(f),
    },
}

# ─── Detección de tipo / nombre por sistema ────────────────────────────────────

def _s500_type(fname: str) -> str:
    s = fname.upper()
    if "_WFL_" in s:       return "wfl"
    if "_INC_" in s:       return "inc"
    if "_DASDL_" in s:     return "dasdl"
    # ALGOL: archivos SOURCE cuyo nombre comienza con L (librería)
    m = re.match(r"S500_SOURCE_(L\w+)", fname, re.I)
    if m:                  return "algol"
    if "_SOURCE_" in s:    return "cobol"
    return "unknown"

def _s500_name(fname: str) -> str:
    stem = Path(fname).stem
    for p in ("S500_SOURCE_", "S500_INC_", "S500_WFL_", "S500_DASDL_"):
        if stem.upper().startswith(p.upper()):
            return stem[len(p):]
    return stem

def _s151_type(fname: str) -> str:
    s = fname.upper()
    if s.startswith("COBOL_"):  return "cobol"
    if s.startswith("ALGOL_"):  return "algol"
    if s.startswith("DASDL_"):  return "dasdl"
    if s.startswith("WFL_"):    return "wfl"
    return "unknown"

def _s151_name(fname: str) -> str:
    stem = Path(fname).stem
    for p in ("COBOL_", "ALGOL_", "DASDL_", "WFL_"):
        if stem.upper().startswith(p.upper()):
            return stem[len(p):]
    return stem

# ─── Capa 1 · Lenguaje — vocabulario de identifiers ──────────────────────────

STOPWORDS_ES = {
    "de", "la", "el", "los", "las", "en", "un", "una", "es", "son",
    "se", "del", "por", "con", "que", "si", "no", "al", "lo", "le",
    "su", "sus", "o", "y", "a", "e", "u",
}

def tokenize_identifier(name: str) -> list[str]:
    """Split a COBOL/ALGOL identifier into semantic tokens."""
    # UPPER-CASE-HYPHEN-SEPARATED or camelCase or UNDERSCORE
    name = name.upper()
    parts = re.split(r"[-_]", name)
    tokens = []
    for p in parts:
        if len(p) >= 2 and p not in STOPWORDS_ES:
            tokens.append(p)
    return tokens

def extract_vocab_cobol(lines: list[str]) -> list[str]:
    """Extract identifiers from COBOL source: paragraph names, data-item names."""
    vocab = []
    in_data_div = False
    for line in lines:
        # Skip line number prefix (first 6 chars)
        content = line[6:].rstrip() if len(line) > 6 else line.rstrip()
        # Data Division identifiers (01-88 level data items)
        m = re.match(r"\s{1,8}(\d{2})\s+([A-Z0-9][A-Z0-9-]+)", content, re.I)
        if m and m.group(1).strip().isdigit():
            name = m.group(2).strip()
            if name not in ("REDEFINES", "FILLER", "PIC", "PICTURE"):
                vocab.extend(tokenize_identifier(name))
        # Paragraph / section names (column 8-11, ending with period or no indent)
        m2 = re.match(r"^([A-Z][A-Z0-9-]{2,})\s*\.", content, re.I)
        if m2:
            name = m2.group(1)
            if not re.match(r"^(IDENTIFICATION|ENVIRONMENT|DATA|PROCEDURE|"
                             r"WORKING-STORAGE|FILE|LINKAGE|INPUT-OUTPUT|"
                             r"DATA-BASE)$", name, re.I):
                vocab.extend(tokenize_identifier(name))
    return vocab

def extract_vocab_dasdl(lines: list[str]) -> list[str]:
    """Extract record and field names from DASDL schemas."""
    vocab = []
    for line in lines:
        content = line.strip()
        # RECORD <name>
        m = re.match(r"RECORD\s+([A-Z][A-Z0-9-]+)", content, re.I)
        if m:
            vocab.extend(tokenize_identifier(m.group(1)))
        # SET <name>
        m2 = re.match(r"SET\s+([A-Z][A-Z0-9-]+)", content, re.I)
        if m2:
            vocab.extend(tokenize_identifier(m2.group(1)))
        # Field definitions: <name> ALPHA/NUMBER/BOOLEAN
        m3 = re.match(r"\s+([A-Z][A-Z0-9-]+)\s+(ALPHA|NUMBER|BOOLEAN|INTEGER|REAL)", content, re.I)
        if m3:
            vocab.extend(tokenize_identifier(m3.group(1)))
    return vocab

def extract_vocab_algol(lines: list[str]) -> list[str]:
    """Extract procedure, variable and database names from ALGOL."""
    vocab = []
    for line in lines:
        content = line[6:].strip() if len(line) > 6 else line.strip()
        m = re.match(r"PROCEDURE\s+([A-Z][A-Z0-9]+)\s*[;(]", content, re.I)
        if m:
            vocab.extend(tokenize_identifier(m.group(1)))
        m2 = re.match(r"DATABASE\s+([A-Z][A-Z0-9]+)", content, re.I)
        if m2:
            vocab.extend(tokenize_identifier(m2.group(1)))
    return vocab

# ─── Capa 2 · Almas — autoría declarada ──────────────────────────────────────

# S500: *INI TICKET  DESCRIPTION  AUTHOR  or  *AUTOR ABARBOSA etc.
S500_INI_RE = re.compile(
    r"\*INI\s+(\S+)\s+(.+?)\s{2,}(\S+)\s*$", re.I
)
# S500: general author tag
S500_AUTOR_RE = re.compile(r"\*\s*AUTOR[:\s]+(\S+)", re.I)
# S151: modification number patterns  01MTP008 : desc
S151_TICKET_RE = re.compile(r"\*\s*(\d{2}[A-Z]{3}\d{3})\s*:", re.I)
# Generic author names in comment lines (all-caps 3-12 chars, not COBOL keywords)
AUTHOR_RE = re.compile(r"\b([A-Z]{3,12})\b")

COBOL_KWORDS = {
    "MOVE", "COMPUTE", "PERFORM", "CALL", "IF", "ELSE", "END", "STOP",
    "SECTION", "PARAGRAPH", "DIVISION", "DATA", "PROCEDURE", "WORKING",
    "STORAGE", "COPY", "PICTURE", "ACCEPT", "DISPLAY", "INITIALIZE",
    "EVALUATE", "WHEN", "SEARCH", "READ", "WRITE", "REWRITE", "DELETE",
    "OPEN", "CLOSE", "SORT", "MERGE", "STOP", "GOBACK", "EXIT", "NOTE",
    "ADD", "SUBTRACT", "MULTIPLY", "DIVIDE", "SET", "GO", "ALTER",
    "INSPECT", "STRING", "UNSTRING", "CORRESPONDING", "REPLACING",
    "LEADING", "TRAILING", "AFTER", "BEFORE", "UNTIL", "VARYING",
    "TIMES", "THROUGH", "THRU", "TRUE", "FALSE", "ZERO", "ZEROS",
    "SPACE", "SPACES", "HIGH-VALUE", "LOW-VALUE", "QUOTE", "NULL",
    "NULLS", "LENGTH", "ADDRESS", "REFERENCE", "CONTENT", "VALUE",
    "COMP", "COMP-3", "COMP-1", "COMP-2", "BINARY", "PACKED",
    "DECIMAL", "REDEFINES", "OCCURS", "DEPENDING", "ASCENDING",
    "DESCENDING", "INDEXED", "SYNC", "SYNCHRONIZED", "JUSTIFIED",
    "BLANK", "SCREEN", "COLUMN", "LINE", "FOREGROUND", "BACKGROUND",
    "NATIVE", "STANDARD", "OPTIONAL", "RELATIVE", "SEQUENTIAL",
    "RANDOM", "DYNAMIC", "DISK", "PRINTER", "TAPE", "MEMORY",
    "AUTOMATIC", "MANUAL", "MANDATORY", "OPTIONAL", "EQUAL", "NOT",
    "GREATER", "LESS", "THAN", "OR", "AND", "LITERAL", "NUMERIC",
    "ALPHABETIC", "ALPHANUMERIC", "SELECT", "ASSIGN", "ORGANIZATION",
    "ACCESS", "MODE", "FILE", "STATUS", "RECORD", "CONTAINS", "BLOCK",
    "LABEL", "RECORDS", "STANDARD", "OMITTED", "FD", "SD", "RD",
    "LINKAGE", "COMMUNICATION", "REPORT", "SCREEN", "ENVIRONMENT",
    "IDENTIFICATION", "AUTHOR", "DATE", "REMARKS", "OBJECT", "SOURCE",
    "COMPUTER", "CURRENCY", "DECIMAL", "SIGN", "PROGRAM", "CLASS",
    "ALPHABET", "SPECIAL", "NAMES", "CONFIGURATION", "PROCESSING",
    "DATABASE", "USING", "GIVING", "FROM", "INTO", "TO", "BY",
    "EXCEPTION", "ERROR", "OVERFLOW", "SIZE", "ROUNDED", "ON",
    "LOCK", "KEY", "KEYS", "ALTERNATE", "NOMINAL", "AREA",
    "AREASIZE", "AREAS", "FRAMESIZE", "MAXRECSIZE", "SECURITYUSE",
    "SAVEFACTOR", "TITLE", "PROTECTION", "PROTECTED", "UNPROTECTED",
    "DISK", "PACK", "TAPE", "PRINTER", "READER", "PUNCH",
    "MTP", "FSW", "INI", "FIN", "CRONOS", "TADS",
}

def extract_authors_cobol(program_id: str, lines: list[str], sistema: str) -> list[dict]:
    """Extract authorship records from COBOL comment blocks."""
    found = []
    for line in lines:
        raw = line[6:] if len(line) > 6 else line
        # S500 *INI pattern: *INI FSW P08-378  Tarjeta Prepagada  ABARBOSA
        m = S500_INI_RE.match(raw.strip())
        if m:
            found.append({
                "objeto": program_id,
                "autor": m.group(3).strip(),
                "fecha": "",
                "proyecto": m.group(2).strip(),
                "ticket": m.group(1).strip(),
            })
            continue
        # S500 *AUTOR: ABARBOSA
        m2 = S500_AUTOR_RE.match(raw.strip())
        if m2:
            found.append({
                "objeto": program_id,
                "autor": m2.group(1).strip(),
                "fecha": "", "proyecto": "", "ticket": "AUTOR",
            })
            continue
        # S151 01MTP008 : desc
        m3 = S151_TICKET_RE.match(raw.strip())
        if m3:
            found.append({
                "objeto": program_id,
                "autor": "",
                "fecha": "",
                "proyecto": raw.strip()[len(m3.group(0)):].strip()[:60],
                "ticket": m3.group(1).strip(),
            })
    return found

def extract_authors_wfl(program_id: str, lines: list[str]) -> list[dict]:
    """Extract author from WFL comment blocks (e.g. %% L.MARIN, NOVIEMBRE DE 1991)."""
    found = []
    for line in lines:
        raw = line.strip()
        # %% L.MARIN, NOVIEMBRE DE 1991 %%
        m = re.search(r"%%\s+([A-Z][A-Z.]+),\s+(\w+)\s+DE\s+(\d{4})", raw, re.I)
        if m:
            found.append({
                "objeto": program_id,
                "autor": m.group(1).strip(),
                "fecha": m.group(3).strip(),
                "proyecto": "WFL", "ticket": "",
            })
    return found

# ─── Capa 3 · Biografía — fechas y hitos ─────────────────────────────────────

YEAR_RE = re.compile(r"\b(19[7-9]\d|20[012]\d)\b")

def extract_hitos(lines: list[str], sistema: str) -> list[dict]:
    """Extract dates and modification milestones from all comment blocks."""
    hitos = []
    seen = set()
    for line in lines:
        raw = line[6:] if len(line) > 6 else line
        years = YEAR_RE.findall(raw)
        for y in years:
            if y in seen:
                continue
            seen.add(y)
            # Build brief context: strip comment markers
            ctx = re.sub(r"[%*]", "", raw).strip()[:80]
            hitos.append({
                "anio": int(y),
                "titulo": ctx or f"{sistema} modificación {y}",
                "tipo": "tecnologico",
            })
    return hitos

# ─── Capa 4 · Intención — call graph y acceso a datos ────────────────────────

# COBOL CALL patterns
COBOL_CALL_STATIC  = re.compile(r"\bCALL\s+['\"]([A-Z][A-Z0-9/_-]+)['\"]", re.I)
COBOL_CALL_DYNAMIC = re.compile(r"\bCALL\s+([A-Z][A-Z0-9-]+)\b(?!\s*['\"])", re.I)
COBOL_PERFORM      = re.compile(r"\bPERFORM\s+([A-Z][A-Z0-9-]+)", re.I)
COBOL_COPY         = re.compile(r"\bCOPY\s+['\"]([^'\"]+)['\"]", re.I)
COBOL_COPY2        = re.compile(r"\bCOPY\s+([A-Z0-9][A-Z0-9/_-]+)", re.I)
COBOL_ENTER        = re.compile(r"\bENTER\s+([A-Z][A-Z0-9/_-]+)", re.I)

# Unisys ClearPath COBOL DATA-BASE SECTION
COBOL_DB_SECTION   = re.compile(r"DB\s+(?:ORIGINAL\s*=\s*)?([A-Z][A-Z0-9]+)", re.I)
# S500 $SET BDB record declarations
SET_BDB_RE         = re.compile(r"\$SET\s+((?:BDB\S+\s*)+)", re.I)

# WFL RUN / COMPILE
WFL_RUN_RE = re.compile(r"(?:RUN|COMPILE)\s+['\"]?([A-Z0-9][A-Z0-9/_-]+)['\"]?", re.I)
WFL_OBJECT_RE = re.compile(r"S(?:500|151)/OBJECT/([A-Z0-9]+)", re.I)

# ALGOL LIBRARY / DATABASE / CALL patterns
ALGOL_LIBRARY_RE   = re.compile(r"LIBRARY\s+([A-Z][A-Z0-9]+)\s*[,(;]", re.I)
ALGOL_DATABASE_RE  = re.compile(r"DATABASE\s+([A-Z][A-Z0-9]+)\s*[,(;]", re.I)
ALGOL_CALL_RE      = re.compile(r"\bCALL\s+([A-Z][A-Z0-9/_-]+)\b", re.I)

# BDB domain mapping (S500 specific)
BDB_DOMAIN = {
    "BDB00": "CAPTACION",
    "BDB01": "CAPTACION",   # Cuentas
    "BDB02": "CAPTACION",   # MOVIMIENTO (S500B04MOVIMIENTO)
    "BDB03": "CAPTACION",   # MSGAAPLI
    "BDB04": "CAPTACION",   # MOVIMIENTO record
    "BDB05": "CAPTACION",
    "BDB06": "CAPTACION",
    "BDB07": "CAPTACION",
    "BDB08": "CAPTACION",
    "BDB09": "CAPTACION",
    "BDB12": "CAPTACION",
    "BDB13": "CAPTACION",
    "BDB15": "CAPTACION",
    "BDB16": "CAPTACION",
    "BDB17": "CAPTACION",
    "BDB18": "CAPTACION",
    "BDB21": "CAPTACION",
    "BDB22": "CAPTACION",
    "BDB23": "CAPTACION",
    "BDB24": "CAPTACION",
    "BDB25": "CAPTACION",
    "BDB26": "CAPTACION",
    "BDB01M": "TARJETAS",   # BD01M = TARJETAS
    "BDB28": "COMISIONES",
    "BDB29": "COMISIONES",
    "BDB30": "COMISIONES",
    "BDB31": "COMISIONES",
    "BDB32": "COMISIONES",
    "BDB33": "COMISIONES",
    "BDB34": "COMISIONES",
    "BDB35": "CPE",
    "BDB36": "CPE",
    "BDB37": "CPE",
    "BDB38": "CPE",
    "BDB39": "CPE",
    "BDB40": "TARJETAS",
    "BDB41": "TARJETAS",
    "BDB42": "TARJETAS",
    "BDB43": "TARJETAS",
    "BDB44": "TARJETAS",
    "BDB45": "TARJETAS",
    "BDB46": "CAPTACION",
    "BDB47": "TARJETAS",
    "BDB47A": "TARJETAS",
    "BDB49": "TARJETAS",
    "BDB50": "TESORERIA",
    "BDB51": "TESORERIA",
    "BDB52": "TESORERIA",
    "BDB53": "TESORERIA",
    "BDB54": "TESORERIA",
    "BDB55": "TESORERIA",
    "BDB56": "TESORERIA",
    "BDB91": "CONTROL",
    "BDB99": "CONTROL",
}

# COBOL layer heuristics
ONLINE_PROGRAMS_S500 = {
    "P010", "P014", "P015", "P038", "P050", "P060", "P080",
    "P091", "P093",
}
WFL_NAMES_S500 = {
    "WFL_LINEA", "WFL_LOTE", "WFL_REORG_GARBAGE_S500BD01CAPTACION",
    "WFL_REORG_GARBAGE_S500BD04TARJETAS",
}

def infer_layer(name: str, tipo: str, sistema: str) -> str:
    if tipo == "wfl":     return "WFL"
    if tipo == "dasdl":   return "DA"
    if tipo == "inc":     return "INC"
    if tipo == "algol":
        return "ONLINE" if sistema == "S500" and name in ONLINE_PROGRAMS_S500 else "BL"
    # COBOL
    if sistema == "S500" and name in ONLINE_PROGRAMS_S500:
        return "ONLINE"
    if name.startswith("P") and re.match(r"P\d{3}", name):
        return "BL"
    if name.startswith("L"):
        return "UTIL"
    return "BL"

def infer_domain_s500(bdb_records: set[str]) -> str:
    """Derive primary domain from BDB record access set."""
    counts = defaultdict(int)
    for rec in bdb_records:
        prefix = re.match(r"(BDB\d+[A-Z]?)", rec.upper())
        if prefix:
            dom = BDB_DOMAIN.get(prefix.group(1), "CAPTACION")
            counts[dom] += 1
    if not counts:
        return "CONTROL"
    return max(counts, key=counts.get)

def infer_domain_s151(name: str) -> str:
    """S151 domain from program name range."""
    m = re.match(r"[PL](\d+)", name)
    if not m:
        return "CONTROL"
    n = int(m.group(1))
    if n == 0:         return "CONTROL"
    if 1 <= n <= 25:   return "MOVIMIENTOS"
    if 26 <= n <= 100: return "MOVIMIENTOS"
    if 101 <= n <= 200: return "CONTABILIDAD"
    if 201 <= n <= 399: return "AJUSTES"
    if 400 <= n <= 599: return "INTERFACES"
    if 600 <= n <= 699: return "REPORTES"
    if 700 <= n <= 899: return "CONTROL"
    return "CONTROL"

# ─── Extracción de acceso a datos ─────────────────────────────────────────────

DMSII_ACCESS_VERBS = {
    "FIND": "R", "GET": "R", "FETCH": "R", "READ": "R",
    "STORE": "W", "MODIFY": "W", "ERASE": "W", "WRITE": "W",
    "REWRITE": "W",
}

def extract_data_access_cobol(program_id: str, lines: list[str], db_names: set[str]) -> list[dict]:
    """Infer data access mode per database from COBOL verbs and $SET records."""
    # $SET BDB records → likely RW unless all are read-only (hard to tell statically)
    # We classify as RW if any MODIFY/STORE/ERASE appears in file; R otherwise
    has_write = False
    for line in lines:
        raw = line[6:] if len(line) > 6 else line
        for verb in ("STORE", "MODIFY", "ERASE", "REWRITE"):
            if re.search(rf"\b{verb}\b", raw, re.I):
                has_write = True
                break
    mode = "RW" if has_write else "R"
    result = []
    for db in sorted(db_names):
        result.append({"objeto": program_id, "entidad": db, "modo": mode})
    return result

# ─── Risk types (COMP-3 / packed decimal) ─────────────────────────────────────

COMP3_RE = re.compile(r"\b(\w[\w-]+)\s+PIC\s+9.*?COMP-3", re.I)
DATE_8_RE = re.compile(r"\b(\w[\w-]+)\s+PIC\s+9\(8\)", re.I)

def extract_risk_types(program_id: str, lines: list[str]) -> list[dict]:
    """Flag COMP-3 (packed decimal) and 8-digit date fields as conversion risks."""
    risks = []
    for line in lines:
        raw = line[6:] if len(line) > 6 else line
        m = COMP3_RE.search(raw)
        if m:
            risks.append({
                "entidad": program_id, "campo": m.group(1),
                "tipo_origen": "COMP-3", "riesgo": "alto",
            })
        m2 = DATE_8_RE.search(raw)
        if m2:
            risks.append({
                "entidad": program_id, "campo": m2.group(1),
                "tipo_origen": "9(8)-DATE", "riesgo": "medio",
            })
    return risks

# ─── Procesador de archivo individual ─────────────────────────────────────────

def process_file(fpath: Path, tipo: str, name: str, sistema: str) -> dict:
    """
    Parse a single source file and return a dict with all extracted fields
    for integration into the normalized JSON.
    """
    try:
        raw = fpath.read_text(encoding="utf-8", errors="replace")
    except Exception as e:
        return {"error": str(e)}

    lines = raw.splitlines()
    loc_total = len(lines)

    result = {
        "id": name,
        "nombre": name,
        "tipo": tipo,
        "loc": loc_total,
        "dominio": "",
        "params": 0,
        "layer": infer_layer(name, tipo, sistema),
        # extendidos (no en §6 pero útiles para renderers)
        "db_access": [],         # set of DB entities accessed
        "bdb_records": set(),    # S500 BDB records from $SET
        "calls_out": [],         # outgoing call edges
        "vocab": [],             # Capa 1 tokens
        "headers": [],           # Capa 2 authors
        "hitos": [],             # Capa 3 dates
        "risks": [],             # riesgos_tipo
    }

    # ── COBOL ─────────────────────────────────────────────────────────────────
    if tipo in ("cobol",):
        # Vocabulario (Capa 1)
        result["vocab"] = extract_vocab_cobol(lines)
        # Almas (Capa 2)
        result["headers"] = extract_authors_cobol(name, lines, sistema)
        # Hitos (Capa 3)
        result["hitos"] = extract_hitos(lines, sistema)
        # Risk types
        result["risks"] = extract_risk_types(name, lines)

        # Call graph
        db_names = set()
        for line in lines:
            raw_line = line[6:] if len(line) > 6 else line
            # Static CALL
            for m in COBOL_CALL_STATIC.finditer(raw_line):
                target = _normalize_program_ref(m.group(1))
                result["calls_out"].append({"to": target, "tipo": "call"})
            # COPY
            for m in COBOL_COPY.finditer(raw_line):
                inc = Path(m.group(1)).stem
                result["calls_out"].append({"to": inc, "tipo": "copy"})
            for m in COBOL_COPY2.finditer(raw_line):
                inc = Path(m.group(1)).stem
                result["calls_out"].append({"to": inc, "tipo": "copy"})
            # ENTER (Unisys MCP specific)
            for m in COBOL_ENTER.finditer(raw_line):
                target = _normalize_program_ref(m.group(1))
                result["calls_out"].append({"to": target, "tipo": "enter"})
            # DATA-BASE SECTION: DB statement
            m_db = COBOL_DB_SECTION.match(raw_line.strip())
            if m_db:
                db_names.add(m_db.group(1))
            # $SET BDB records (S500)
            m_set = SET_BDB_RE.match(raw_line.strip())
            if m_set:
                records = m_set.group(1).split()
                for rec in records:
                    result["bdb_records"].add(rec.upper())
                    # Derive DB name from BDB prefix
                    prefix_m = re.match(r"(BDB\d+[A-Z]?)", rec.upper())
                    if prefix_m:
                        dom = BDB_DOMAIN.get(prefix_m.group(1), "CAPTACION")

        # Derive domain
        if sistema == "S500":
            result["dominio"] = infer_domain_s500(result["bdb_records"])
        else:
            result["dominio"] = infer_domain_s151(name)

        # DB access entries
        if sistema == "S500":
            # Map BDB records back to DMSII schema names
            for rec in result["bdb_records"]:
                prefix_m = re.match(r"(BDB\d+[A-Z]?)", rec.upper())
                if prefix_m:
                    db_names.add(prefix_m.group(1))
        result["db_access"] = extract_data_access_cobol(name, lines, db_names)

    # ── INC (copybooks) ───────────────────────────────────────────────────────
    elif tipo == "inc":
        result["vocab"] = extract_vocab_cobol(lines)
        result["risks"] = extract_risk_types(name, lines)
        result["dominio"] = infer_domain_s151(name) if sistema == "S151" else "CAPTACION"

    # ── ALGOL ─────────────────────────────────────────────────────────────────
    elif tipo == "algol":
        result["vocab"] = extract_vocab_algol(lines)
        result["headers"] = extract_authors_cobol(name, lines, sistema)
        result["hitos"] = extract_hitos(lines, sistema)
        for line in lines:
            raw_line = line[6:].strip() if len(line) > 6 else line.strip()
            m = ALGOL_LIBRARY_RE.match(raw_line)
            if m:
                result["calls_out"].append({"to": m.group(1), "tipo": "library"})
            m2 = ALGOL_DATABASE_RE.match(raw_line)
            if m2:
                result["db_access"].append({
                    "objeto": name, "entidad": m2.group(1), "modo": "RW"
                })
            m3 = ALGOL_CALL_RE.search(raw_line)
            if m3:
                target = _normalize_program_ref(m3.group(1))
                result["calls_out"].append({"to": target, "tipo": "call"})
        if sistema == "S500":
            result["dominio"] = "CAPTACION"  # ALGOL libs are cross-domain in S500
        else:
            result["dominio"] = "CONTROL"

    # ── WFL ───────────────────────────────────────────────────────────────────
    elif tipo == "wfl":
        result["headers"] = extract_authors_wfl(name, lines)
        result["hitos"] = extract_hitos(lines, sistema)
        result["dominio"] = "CONTROL"
        for line in lines:
            raw_line = line.strip()
            # Object references in comments
            for m in WFL_OBJECT_RE.finditer(raw_line):
                result["calls_out"].append({"to": m.group(1), "tipo": "run"})
            # Actual RUN/COMPILE statements
            for m in WFL_RUN_RE.finditer(raw_line):
                target = _normalize_program_ref(m.group(1))
                result["calls_out"].append({"to": target, "tipo": "run"})

    # ── DASDL ─────────────────────────────────────────────────────────────────
    elif tipo == "dasdl":
        result["vocab"] = extract_vocab_dasdl(lines)
        result["hitos"] = extract_hitos(lines, sistema)
        result["dominio"] = _dasdl_domain(name, sistema)

    # Deduplicate calls
    seen_calls = set()
    unique_calls = []
    for c in result["calls_out"]:
        key = (c["to"], c["tipo"])
        if key not in seen_calls:
            seen_calls.add(key)
            unique_calls.append(c)
    result["calls_out"] = unique_calls

    return result

def _normalize_program_ref(ref: str) -> str:
    """Normalize program references: S500/OBJECT/P010 → P010, etc."""
    ref = ref.strip().strip("'\"")
    # S500/OBJECT/P010 or S151/OBJECT/P001
    m = re.search(r"/OBJECT/([A-Z0-9]+)$", ref, re.I)
    if m:
        return m.group(1)
    # S500/INC/WOR/25MTP004 → INC_WOR
    m2 = re.search(r"/INC/([A-Z0-9_]+)", ref, re.I)
    if m2:
        return "INC_" + m2.group(1).upper()
    # S500/SOURCE/P010 → P010
    m3 = re.search(r"/SOURCE/([A-Z0-9]+)", ref, re.I)
    if m3:
        return m3.group(1)
    # Just a name
    name = Path(ref).stem.upper()
    return name

def _dasdl_domain(name: str, sistema: str) -> str:
    """Infer domain from DASDL schema name."""
    n = name.upper()
    if "MOVDIA" in n:  return "MOVIMIENTOS"
    if "SALDO" in n:   return "MOVIMIENTOS"
    if "CONTROL" in n: return "CONTROL"
    if "BIFIN" in n:   return "CONTABILIDAD"
    if "MC001" in n:   return "MOVIMIENTOS"
    if "CAPTACION" in n: return "CAPTACION"
    if "TARJETA" in n:   return "TARJETAS"
    if "AUXILIAR" in n:  return "CAPTACION"
    return "CONTROL"

# ─── Generación del JSON normalizado §6 ──────────────────────────────────────

def build_normalized_json(sistema: str, objects: list[dict]) -> dict:
    """Build the canonical §6 JSON from the list of processed objects."""
    # Objects
    obj_list = []
    for o in objects:
        obj_list.append({
            "id": o["id"],
            "nombre": o["nombre"],
            "tipo": o["tipo"],
            "loc": o["loc"],
            "dominio": o["dominio"],
            "params": o.get("params", 0),
        })

    # Callgraph
    callgraph = []
    obj_ids = {o["id"] for o in objects}
    for o in objects:
        for c in o.get("calls_out", []):
            callgraph.append({
                "from": o["id"],
                "to": c["to"],
                "tipo": c["tipo"],
            })

    # Acceso
    acceso = []
    for o in objects:
        acceso.extend(o.get("db_access", []))

    # Headers
    headers = []
    for o in objects:
        headers.extend(o.get("headers", []))

    # Hitos (deduplicated by year+titulo)
    hitos_map = {}
    for o in objects:
        for h in o.get("hitos", []):
            key = (h["anio"], h["titulo"][:20])
            if key not in hitos_map:
                hitos_map[key] = h
    hitos = sorted(hitos_map.values(), key=lambda x: x["anio"])

    # Riesgos de tipo
    riesgos = []
    for o in objects:
        riesgos.extend(o.get("risks", []))

    conectados = len({c["from"] for c in callgraph} | {c["to"] for c in callgraph} & obj_ids)

    return {
        "meta": {
            "sistema": sistema,
            "tecnologia": "cobol-algol-dasdl-wfl-unisys-mcp",
            "objetos": len(obj_list),
            "conectados": conectados,
            "fuente_evidencia": "fuentes",
            "loc_total": sum(o["loc"] for o in obj_list),
        },
        "objetos": obj_list,
        "callgraph": callgraph,
        "acceso": acceso,
        "headers": headers,
        "hitos": hitos,
        "riesgos_tipo": riesgos,
    }

# ─── Generación del dependency-graph.json para render_graph.py ───────────────

def build_dependency_graph(sistema: str, objects: list[dict]) -> dict:
    """Build dependency-graph.json compatible with Fase 1 - Discover render_graph.py."""
    # Access mode per object: if any db_access has W → update; else read
    access_map = {}
    for o in objects:
        for da in o.get("db_access", []):
            if "W" in da.get("modo", ""):
                access_map[o["id"]] = "update"
                break
        if o["id"] not in access_map and o.get("db_access"):
            access_map[o["id"]] = "read"
        if o["id"] not in access_map:
            access_map[o["id"]] = "none"

    nodes = []
    for o in objects:
        nodes.append({
            "id": o["id"],
            "layer": o.get("layer", "BL"),
            "domain": o.get("dominio", ""),
            "loc": o["loc"],
            "access": access_map.get(o["id"], "none"),
        })

    edges = []
    seen_edges = set()
    for o in objects:
        for c in o.get("calls_out", []):
            key = (o["id"], c["to"], c["tipo"])
            if key not in seen_edges:
                seen_edges.add(key)
                edges.append({
                    "from": o["id"],
                    "to": c["to"],
                    "type": c["tipo"],
                })

    # Copybook coupling sidecar
    copybook_usage = defaultdict(list)
    for o in objects:
        if o["tipo"] in ("cobol", "algol"):
            for c in o.get("calls_out", []):
                if c["tipo"] == "copy":
                    copybook_usage[c["to"]].append(o["id"])

    return {
        "system": sistema,
        "nodes": nodes,
        "edges": edges,
        "_copybook_usage": dict(copybook_usage),
    }

# ─── Main ─────────────────────────────────────────────────────────────────────

def extract_system(sistema: str) -> None:
    cfg = SYSTEM_CONFIG.get(sistema)
    if not cfg:
        print(f"[ERROR] Sistema desconocido: {sistema}")
        return

    src_dir: Path = cfg["source_dir"]
    if not src_dir.exists():
        print(f"[ERROR] Directorio fuente no encontrado: {src_dir}")
        return

    out_dir = Path(__file__).parent / "data" / sistema
    out_dir.mkdir(parents=True, exist_ok=True)

    print(f"\n{'='*60}")
    print(f"  Gemelo Cognitivo — Extractor")
    print(f"  Sistema: {sistema}  |  Fuente: {src_dir.name}")
    print(f"{'='*60}")

    files = sorted(f for f in src_dir.iterdir()
                   if f.is_file() and f.suffix.lower() == ".txt")

    print(f"\n[Etapa 0] Inventario: {len(files)} archivos encontrados")

    objects = []
    for fpath in files:
        tipo = cfg["detect_type"](fpath.name)
        name = cfg["extract_name"](fpath.name)
        if tipo == "unknown":
            print(f"  [SKIP] {fpath.name} (tipo desconocido)")
            continue
        obj = process_file(fpath, tipo, name, sistema)
        if "error" in obj:
            print(f"  [ERROR] {fpath.name}: {obj['error']}")
            continue
        objects.append(obj)
        print(f"  [{tipo.upper():6}] {name:<30} {obj['loc']:>6} LOC  dom={obj['dominio']}")

    # Normalize bdb_records (set → list) for JSON serialization
    for o in objects:
        if "bdb_records" in o:
            o["bdb_records"] = sorted(o["bdb_records"])

    print(f"\n[Etapa 1] Call graph")
    total_edges = sum(len(o.get("calls_out", [])) for o in objects)
    print(f"  Aristas extraídas: {total_edges}")

    print(f"\n[Etapa 2] Acceso a datos")
    total_access = sum(len(o.get("db_access", [])) for o in objects)
    print(f"  Registros de acceso: {total_access}")

    print(f"\n[Etapa 2] Almas (autoría declarada)")
    total_headers = sum(len(o.get("headers", [])) for o in objects)
    print(f"  Registros de autoría: {total_headers}")

    print(f"\n[Capa 3] Hitos (fechas en comentarios)")
    all_hitos = []
    for o in objects:
        all_hitos.extend(o.get("hitos", []))
    years = sorted({h["anio"] for h in all_hitos})
    print(f"  Años detectados: {min(years) if years else '?'} – {max(years) if years else '?'}")

    print(f"\n[Transversal Calidad] Riesgos de tipo")
    total_risks = sum(len(o.get("risks", [])) for o in objects)
    print(f"  Campos COMP-3 / fechas 9(8): {total_risks}")

    # ─── Build normalized JSON ─────────────────────────────────────────────
    gemelo_json = build_normalized_json(sistema, objects)

    # Summary by domain
    print(f"\n[Capa 5] Dominios identificados:")
    dom_counts = defaultdict(lambda: {"count": 0, "loc": 0})
    for o in objects:
        d = o.get("dominio") or "?"
        dom_counts[d]["count"] += 1
        dom_counts[d]["loc"] += o["loc"]
    for d, stats in sorted(dom_counts.items(), key=lambda x: -x[1]["loc"]):
        print(f"  {d:<20} {stats['count']:>3} programas  {stats['loc']:>8} LOC")

    # ─── Write outputs ─────────────────────────────────────────────────────
    gemelo_path = out_dir / f"gemelo-{sistema.lower()}.json"
    with open(gemelo_path, "w", encoding="utf-8") as f:
        json.dump(gemelo_json, f, ensure_ascii=False, indent=2)
    print(f"\n[OUTPUT] {gemelo_path.name}")

    dep_graph = build_dependency_graph(sistema, objects)
    dep_path = out_dir / f"dependency-graph-{sistema.lower()}.json"
    with open(dep_path, "w", encoding="utf-8") as f:
        json.dump(dep_graph, f, ensure_ascii=False, indent=2)
    print(f"[OUTPUT] {dep_path.name}")

    # ─── Summary markdown ──────────────────────────────────────────────────
    _write_inventory_md(sistema, objects, gemelo_json, out_dir)

    print(f"\n[DONE] {sistema}: {len(objects)} objetos · "
          f"{gemelo_json['meta']['loc_total']:,} LOC total")


def _write_inventory_md(sistema: str, objects: list[dict],
                         gemelo: dict, out_dir: Path) -> None:
    """Write a human-readable inventory summary."""
    loc_total = gemelo["meta"]["loc_total"]
    by_type = defaultdict(lambda: {"count": 0, "loc": 0})
    for o in objects:
        by_type[o["tipo"]]["count"] += 1
        by_type[o["tipo"]]["loc"] += o["loc"]

    lines = [
        f"# Inventario Maestro — {sistema}",
        f"> Gemelo Cognitivo del Sistema · Etapa 0 · {gemelo['meta']['tecnologia']}",
        "",
        "## Resumen por tipo",
        "",
        "| Tipo | Piezas | LOC Total | % |",
        "|------|--------|-----------|---|",
    ]
    for t, stats in sorted(by_type.items(), key=lambda x: -x[1]["loc"]):
        pct = stats["loc"] / loc_total * 100 if loc_total else 0
        lines.append(f"| {t.upper()} | {stats['count']} | {stats['loc']:,} | {pct:.1f}% |")
    lines.extend([
        f"| **TOTAL** | **{len(objects)}** | **{loc_total:,}** | **100%** |",
        "",
        "## Inventario detallado",
        "",
        "| Programa | Tipo | LOC | Dominio | Aristas salientes |",
        "|----------|------|-----|---------|-------------------|",
    ])
    for o in sorted(objects, key=lambda x: -x["loc"]):
        n_calls = len(o.get("calls_out", []))
        lines.append(
            f"| {o['id']} | {o['tipo'].upper()} | {o['loc']:,} "
            f"| {o.get('dominio','?')} | {n_calls} |"
        )
    lines.extend([
        "",
        "## Dominios (señal Capa 5)",
        "",
        "| Dominio | Programas | LOC |",
        "|---------|-----------|-----|",
    ])
    dom_counts = defaultdict(lambda: {"count": 0, "loc": 0})
    for o in objects:
        d = o.get("dominio") or "?"
        dom_counts[d]["count"] += 1
        dom_counts[d]["loc"] += o["loc"]
    for d, s in sorted(dom_counts.items(), key=lambda x: -x[1]["loc"]):
        lines.append(f"| {d} | {s['count']} | {s['loc']:,} |")

    inv_path = out_dir / f"inventario-{sistema.lower()}.md"
    inv_path.write_text("\n".join(lines), encoding="utf-8")
    print(f"[OUTPUT] {inv_path.name}")


def main():
    parser = argparse.ArgumentParser(
        description="Banamex Gemelo Cognitivo — Extractor COBOL/ALGOL/DASDL/WFL"
    )
    parser.add_argument("sistemas", nargs="+", choices=["S500", "S151"],
                        help="Sistema(s) a procesar")
    args = parser.parse_args()

    for s in args.sistemas:
        extract_system(s)

    print("\n[COMPLETO] Proximos pasos:")
    print("  python build-vocab.py S500 S151   # Capa 1: vocabulario")
    print("  python build-souls.py S500 S151   # Capa 2: mapa de almas")
    print("  python render-portal.py           # Portal HTML Banamex")


if __name__ == "__main__":
    main()