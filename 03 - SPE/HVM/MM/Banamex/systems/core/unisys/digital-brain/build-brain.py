"""
build-brain.py — GemCog Brain v3 · Banamex S500 + S151
Construye brain.db exclusivamente desde GemCogAlt (KB canónica v1.13 / 2026-08-26).

Fuente autoritativa (READ-ONLY — nunca se escribe ahí):
  source/GemCogAlt/gemcog-chatbot-kb-2026-08-26/

Tablas:
  capacidades       — 22 BC-XX (taxonomía BIAN v12)
  programs          — 75 S151 + 77 S500 (program-registry con LOC y dominio)
  tasks             — T-XX-NNN por capacidad (cap-*.md)
  rules             — 1,583 reglas (rules-catalog/*.md)
  cross_dependencies — 19 sistemas externos (integration-map.md)
  inventario        — 218 artifacts S500 + S151 con LOC, tipo y aristas
  vocab_full        — ~70K términos S500 + S151 con metadata completa
  vocab_rule_xref   — términos × reglas citantes (vocab-rules-xref.md)
  pseudocodigo      — 199 pseudocódigos completos (*.pseudo.md)
  wfl_catalog       — 7 WFLs S500 + S151 (wfl-catalog.md)
  rule_vocab        — referencias vocab por regla (desde rules-catalog)
  vocab_terms       — términos únicos citados en reglas
  stats             — métricas de cobertura

FTS5: rules_fts · vocab_fts · cross_deps_fts · pseudo_fts

Uso:
  cd digital-brain/
  python build-brain.py
"""

import sqlite3, re, sys
from pathlib import Path

BASE   = Path(__file__).parent
KB_ALT = BASE.parent / "source" / "GemCogAlt" / "gemcog-chatbot-kb-2026-08-26"
DB     = BASE / "brain.db"

# ── Validación temprana ───────────────────────────────────────────────────────
if not KB_ALT.exists():
    sys.exit(f"ERROR: No se encontró GemCogAlt en:\n  {KB_ALT}")

# ── BC-ID ↔ slug (fuente: capability-model-taxonomy.md) ──────────────────────
BC_TO_SLUG = {
    "BC-01": "tel",  "BC-02": "tar",  "BC-03": "hld",  "BC-04": "acl",
    "BC-05": "dep",  "BC-06": "pay",  "BC-07": "sta",  "BC-08": "int",
    "BC-09": "adj",  "BC-10": "cmp",  "BC-11": "rec",  "BC-12": "orc",
    "BC-13": "gl",   "BC-14": "sch",  "BC-15": "ods",  "BC-16": "sec",
    "BC-17": "mq",   "BC-18": "rpt",  "BC-19": "cfr",  "BC-20": "wfl",
    "BC-21": "cpe",  "BC-23": "spei", "BC-24": "feed", "BC-25": "pos",
}
SLUG_TO_BC = {v: k for k, v in BC_TO_SLUG.items()}

# ── Schema ────────────────────────────────────────────────────────────────────
SCHEMA = """
PRAGMA foreign_keys = ON;

CREATE TABLE capacidades (
    bc_id       TEXT PRIMARY KEY,
    slug        TEXT,
    nombre      TEXT,
    bian_ref    TEXT,
    dominio     TEXT,
    subdominio  TEXT,
    sistema     TEXT
);

CREATE TABLE programs (
    prog_id       TEXT,
    sistema       TEXT,
    bc_id         TEXT,
    bc_slug       TEXT,
    nombre        TEXT,
    bian_ref      TEXT,
    confianza     TEXT,
    rol_funcional TEXT,
    loc           INTEGER,
    dominio_s     TEXT,
    PRIMARY KEY (prog_id, sistema)
);

CREATE TABLE tasks (
    task_id     TEXT PRIMARY KEY,
    bc_id       TEXT,
    bc_slug     TEXT,
    programa    TEXT,
    descripcion TEXT,
    tipo        TEXT
);

CREATE TABLE rules (
    rule_id      TEXT PRIMARY KEY,
    sistema      TEXT,
    nombre       TEXT,
    bc_id        TEXT,
    bc_slug      TEXT,
    bian_ref     TEXT,
    tipo_regla   TEXT,
    tipo_tecnico TEXT,
    clase        TEXT,
    sub_tipo     TEXT,
    confianza    TEXT,
    veredicto    TEXT,
    regulador    TEXT,
    programa     TEXT,
    descripcion  TEXT,
    riesgos      TEXT,
    estado       TEXT,
    source_file  TEXT
);

CREATE TABLE cross_dependencies (
    id              TEXT PRIMARY KEY,
    other_system    TEXT,
    dep_type        TEXT,
    direction       TEXT,
    criticality     TEXT,
    rule_count      INTEGER DEFAULT 0,
    evidence        TEXT,
    description     TEXT
);

CREATE TABLE inventario (
    programa          TEXT,
    sistema           TEXT,
    tipo              TEXT,
    loc               INTEGER,
    dominio           TEXT,
    aristas_salientes INTEGER,
    PRIMARY KEY (programa, sistema)
);

CREATE TABLE vocab_full (
    term          TEXT,
    sistema       TEXT,
    frecuencia    INTEGER,
    categoria     TEXT,
    confianza     TEXT,
    evidencia     TEXT,
    significado   TEXT,
    alcance       TEXT,
    programas_str TEXT,
    aliases       TEXT,
    sensibilidad  TEXT,
    PRIMARY KEY (term, sistema)
);

CREATE TABLE vocab_rule_xref (
    term    TEXT,
    rule_id TEXT,
    sistema TEXT,
    PRIMARY KEY (term, rule_id)
);

CREATE TABLE pseudocodigo (
    programa  TEXT,
    sistema   TEXT,
    tipo      TEXT,
    bc_id     TEXT,
    filename  TEXT,
    contenido TEXT,
    PRIMARY KEY (programa, sistema, tipo)
);

CREATE TABLE wfl_catalog (
    wfl_id       TEXT,
    sistema      TEXT,
    bian         TEXT,
    riesgo       TEXT,
    estrategia   TEXT,
    funcion      TEXT,
    dependencias TEXT,
    PRIMARY KEY (wfl_id, sistema)
);

CREATE TABLE rule_vocab (
    rule_id     TEXT,
    term        TEXT,
    categoria   TEXT,
    alcance     TEXT,
    significado TEXT,
    PRIMARY KEY (rule_id, term)
);

CREATE TABLE vocab_terms (
    term        TEXT PRIMARY KEY,
    categoria   TEXT,
    alcance     TEXT,
    significado TEXT,
    rule_count  INTEGER DEFAULT 0
);

CREATE TABLE stats (
    key   TEXT PRIMARY KEY,
    value TEXT
);

-- ═══ Relaciones adicionales (QA 2026-09-29 · sin perder ninguna relación) ═══

-- flujos-ensamblado.md — 45 sub-flujos Mermaid por capacidad
CREATE TABLE flujos (
    flujo_id  TEXT PRIMARY KEY,   -- {cap_slug}#{subid}
    cap_slug  TEXT,
    bc_id     TEXT,
    subid     TEXT,               -- 5.a, 5.b, ...
    titulo    TEXT,
    programas TEXT,               -- CSV de programas citados (propios)
    xcap      TEXT,               -- CSV de programas cross-cap (:::xcap)
    mermaid   TEXT
);

-- cross-cap-index.md — enlace cap→cap vía programa puente
CREATE TABLE cross_cap (
    id            INTEGER PRIMARY KEY,
    cap_origen    TEXT,
    programa_enlace TEXT,
    cap_destino   TEXT,
    etiqueta      TEXT
);

-- traceability-matrix.md — BC-XX → conteo de reglas por sistema
CREATE TABLE traceability (
    bc_id     TEXT PRIMARY KEY,
    capacidad TEXT,
    bian      TEXT,
    n_reglas  INTEGER,
    n_s500    INTEGER,
    n_s151    INTEGER
);

-- traceability-matrix.md §2 — programa sin capacidad → rangos RN
CREATE TABLE traceability_unresolved (
    componente TEXT PRIMARY KEY,
    n_reglas   INTEGER,
    rn_range   TEXT
);

-- dasdl-*.md + dataset-summary-s500.md — bases de datos físicas DMSII
CREATE TABLE db_fisicas (
    db_id         TEXT,
    sistema       TEXT,
    nombre_fisico TEXT,
    pack          TEXT,
    n_datasets    INTEGER,
    poblacion     TEXT,
    PRIMARY KEY (db_id, sistema)
);

-- dasdl-*.md + dataset-summary-s500.md — catálogo de datasets
CREATE TABLE datasets (
    dataset     TEXT,
    sistema     TEXT,
    db_id       TEXT,
    tipo        TEXT,
    prefijo     TEXT,
    poblacion   TEXT,
    descripcion TEXT,
    PRIMARY KEY (dataset, sistema)
);

-- modelo-datos-campos-s151.md — campos por dataset (modelo de datos)
CREATE TABLE campos (
    dataset     TEXT,
    sistema     TEXT,
    campo       TEXT,
    descripcion TEXT,
    tipo        TEXT,
    longitud    TEXT,
    PRIMARY KEY (dataset, campo, sistema)
);

-- cnbv-regulatory-impact-assessment.md — reportes regulatorios
CREATE TABLE regulatory_reports (
    reporte      TEXT PRIMARY KEY,
    regulador    TEXT,
    programas    TEXT,
    periodicidad TEXT,
    deadline     TEXT,
    impacto      TEXT,
    wave         TEXT
);

-- kb-capa5-fronteras.md — bounded contexts del target + externos
CREATE TABLE bounded_contexts (
    bc_ext_id  TEXT PRIMARY KEY,
    sistema    TEXT,
    nombre     TEXT,
    dominio    TEXT,
    programas  TEXT,
    loc        TEXT,
    mecanismo  TEXT,
    prereq_wave TEXT
);

-- kb-capa5-fronteras.md — decisiones 7R por programa (wave map)
CREATE TABLE sevenr_decisions (
    programa  TEXT PRIMARY KEY,
    bc        TEXT,
    decision  TEXT,
    accion    TEXT,
    sme       TEXT,
    wave      TEXT
);

-- capability-map.md — mapa de 104 capacidades BIAN → cap-file
CREATE TABLE capability_bian_map (
    bian_id   TEXT PRIMARY KEY,
    capacidad TEXT,
    dominio   TEXT,
    sistema   TEXT,
    cap_file  TEXT,
    estado    TEXT
);

-- cap-*.md · M1 Blast radius — programa → I/O de datasets
CREATE TABLE program_io (
    cap_slug   TEXT,
    programa   TEXT,
    lee        TEXT,
    escribe    TEXT,
    criticidad TEXT,
    PRIMARY KEY (cap_slug, programa)
);

-- cap-*.md · Reglas vinculadas — tarea → regla
CREATE TABLE task_rules (
    cap_slug    TEXT,
    task_id     TEXT,
    rule_id     TEXT,
    componente  TEXT,
    descripcion TEXT,
    PRIMARY KEY (cap_slug, task_id, rule_id)
);

-- cap-*.md · Dependencias — cap → cap (con evidencia)
CREATE TABLE cap_dependencies (
    id           INTEGER PRIMARY KEY,
    cap_slug     TEXT,
    capacidad_rel TEXT,
    relacion     TEXT,
    cap_file     TEXT
);

-- cap-*.md · Hallazgos de migración — riesgos reales por capacidad
CREATE TABLE hallazgos (
    hallazgo_id TEXT PRIMARY KEY,
    cap_slug    TEXT,
    bc_id       TEXT,
    riesgo      TEXT,
    tareas      TEXT,
    severidad   TEXT,
    impacto     TEXT,
    accion      TEXT
);

-- Red de seguridad: texto crudo COMPLETO de cada .md de la KB (cero pérdida)
CREATE TABLE kb_documents (
    path      TEXT PRIMARY KEY,
    filename  TEXT,
    categoria TEXT,
    n_lineas  INTEGER,
    contenido TEXT
);

CREATE VIRTUAL TABLE rules_fts USING fts5(
    rule_id, nombre, descripcion, riesgos
);
CREATE VIRTUAL TABLE vocab_fts USING fts5(
    term, significado
);
CREATE VIRTUAL TABLE cross_deps_fts USING fts5(
    id, other_system, description
);
CREATE VIRTUAL TABLE pseudo_fts USING fts5(
    programa, sistema, contenido
);
CREATE VIRTUAL TABLE kb_fts USING fts5(
    path, filename, contenido
);
CREATE VIRTUAL TABLE flujos_fts USING fts5(
    flujo_id, titulo, mermaid
);
CREATE VIRTUAL TABLE risks_fts USING fts5(
    risk_id, descripcion, accion
);

-- ═══ Vista de compatibilidad `risks` ← hallazgos (QA 2026-09-29) ═══
-- Los riesgos viven en `hallazgos` (extraídos de "Hallazgos de migración" de cada
-- cap-*.md). Esta vista los expone con el esquema histórico `risks` que consume la
-- API GemCogBrain, y deriva `sev_rank` canónico (0-5) desde el texto de severidad
-- (que en la fuente varía: CRÍTICO, Alta/ALTO, BLOQUEADOR, DEFECTO-PROD, blanco…).
CREATE VIEW risks AS
    SELECT
        hallazgo_id AS risk_id,
        cap_slug,
        bc_id,
        severidad,
        CASE
            WHEN UPPER(severidad) LIKE '%DEFECTO%'                                   THEN 5
            WHEN UPPER(severidad) LIKE '%CRÍTIC%' OR UPPER(severidad) LIKE '%CRITIC%'
              OR UPPER(severidad) LIKE '%BLOQUEAD%'                                  THEN 4
            WHEN UPPER(severidad) LIKE '%ALT%'                                       THEN 3
            WHEN UPPER(severidad) LIKE '%MEDI%'                                      THEN 2
            WHEN UPPER(severidad) LIKE '%BAJ%'                                       THEN 1
            ELSE 0
        END AS sev_rank,
        '' AS patron,
        tareas,
        riesgo AS descripcion,
        accion
    FROM hallazgos;

-- ═══ Vista canónica regla → capacidad de negocio (QA 2026-09-29) ═══
-- Resuelve la capacidad de CADA regla por el mejor camino:
--   fuente='ficha'    → bc_id declarado en la ficha (reglas de negocio)
--   fuente='cap-file' → reglas técnicas (sin BC en ficha) asignadas a una
--                       capacidad vía la sección "Reglas vinculadas" de cap-*.md
--                       (resuelve BC-15/ODS, BC-20/WFL y demás many-to-many)
-- Toda regla queda consultable por capacidad sin importar el camino.
CREATE VIEW rule_capability AS
    SELECT r.rule_id, r.bc_id, c.slug AS bc_slug, c.nombre AS capacidad, 'ficha' AS fuente
    FROM   rules r
    JOIN   capacidades c ON r.bc_id = c.bc_id
    WHERE  r.bc_id LIKE 'BC-%'
    UNION
    SELECT DISTINCT tr.rule_id, c.bc_id, c.slug, c.nombre, 'cap-file' AS fuente
    FROM   task_rules tr
    JOIN   capacidades c ON tr.cap_slug = c.slug
    JOIN   rules r       ON tr.rule_id  = r.rule_id
    WHERE  r.bc_id NOT LIKE 'BC-%';
"""

# ── Utilidades ────────────────────────────────────────────────────────────────
def clean(s: str) -> str:
    return (s or "").strip().strip("*").strip()

def detect_sistema(path: str) -> str:
    name = Path(path).stem.lower()
    if "s500" in name:
        return "S500"
    if "s151" in name:
        return "S151"
    return "AMBOS"

def _parse_int(s: str) -> int | None:
    try:
        return int(s.replace(",", "").replace(".", "").strip())
    except Exception:
        return None

def _norm_dataset(name: str) -> str:
    """Normaliza nombre de dataset: quita prefijo Sxxx para que campos↔datasets hagan join."""
    return re.sub(r'^S(?:151|500)', '', (name or "").strip()).strip("`").strip()

# ── Loader: capacidades ───────────────────────────────────────────────────────
def load_taxonomy(conn: sqlite3.Connection):
    tax_file = KB_ALT / "capability-model-taxonomy.md"
    rows: list[tuple] = []
    text = tax_file.read_text(encoding="utf-8")

    for ln in text.splitlines():
        m = re.match(
            r'\|\s*(BC-\d+)\s*\|\s*(\S*)\s*\|\s*([^|]+?)\s*\|\s*([^|]*?)\s*\|\s*([^|]+?)\s*\|',
            ln
        )
        if m:
            bc_id   = m.group(1)
            slug    = m.group(2).strip() or BC_TO_SLUG.get(bc_id, "")
            nombre  = m.group(3).strip()
            bian    = m.group(4).strip()
            sistema = m.group(5).strip()
            rows.append((bc_id, slug.lower(), nombre, bian, sistema))

    domain_map: dict[str, tuple] = {}
    for ln in text.splitlines():
        m = re.match(
            r'\|\s*([0-9T]\.\d(?:\.\d)?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|',
            ln
        )
        if m:
            bid  = m.group(1)
            dom  = m.group(2).strip()
            sub  = m.group(3).strip()
            cap  = m.group(4).strip()
            if dom.lower() != "dominio" and "P##" not in cap:
                domain_map[bid] = (dom, sub)

    inserted = 0
    for bc_id, slug, nombre, bian, sistema in rows:
        if "reservado" in nombre.lower() or not bc_id:
            continue
        dom, sub = domain_map.get(bian, ("", ""))
        conn.execute(
            "INSERT OR REPLACE INTO capacidades VALUES (?,?,?,?,?,?,?)",
            (bc_id, slug, nombre, bian, dom, sub, sistema)
        )
        inserted += 1
    conn.commit()
    print(f"  capacidades: {inserted} BC-XX")

# ── Loader: programs ──────────────────────────────────────────────────────────
# Parseo por celdas (no regex mega): acepta BC-ID = BC-XX o clasificación no-BC
# (— · TRANSV · texto) para no perder programas técnicos/transversales del registry.
_CONF = {"ALTA", "MEDIA", "BAJA"}

def _parse_program_s151(ln: str) -> tuple | None:
    """| # | Programa | BC-ID | Capacidad (ES) | bian_ref | Rol funcional | Confianza |"""
    s = ln.strip()
    if not s.startswith("|") or re.match(r'\|\s*[-:]+', s):
        return None
    cells = [x.strip() for x in s.strip("|").split("|")]
    if len(cells) < 7 or not re.match(r'^\d+$', cells[0]) or not re.match(r'^[A-Z]\w+$', cells[1]):
        return None
    prog, bc, nombre, bian, rol, conf = cells[1], cells[2], cells[3], cells[4], cells[5], cells[6]
    return prog, bc, nombre, bian, rol, conf, None, ""

def _parse_program_s500(ln: str) -> tuple | None:
    """| # | Programa | LOC | Dominio S500 | BC-ID | Capacidad (ES) | bian_ref | Rol funcional | Confianza | Validado por |"""
    s = ln.strip()
    if not s.startswith("|") or re.match(r'\|\s*[-:]+', s):
        return None
    cells = [x.strip() for x in s.strip("|").split("|")]
    if len(cells) < 9 or not re.match(r'^\d+$', cells[0]) or not re.match(r'^[A-Z]\w+$', cells[1]):
        return None
    prog    = cells[1]
    loc     = _parse_int(cells[2])
    dominio = cells[3]
    bc      = cells[4]
    nombre, bian, rol, conf = cells[5], cells[6], cells[7], cells[8]
    return prog, bc, nombre, bian, rol, conf, loc, dominio

def load_programs(conn: sqlite3.Connection):
    inserted = 0
    for reg_file in [KB_ALT / "program-registry-s151.md", KB_ALT / "program-registry-s500.md"]:
        if not reg_file.exists():
            continue
        sistema    = "S151" if "s151" in reg_file.name else "S500"
        parse_row  = _parse_program_s151 if sistema == "S151" else _parse_program_s500
        in_main    = False
        for ln in reg_file.read_text(encoding="utf-8").splitlines():
            if re.search(r'##\s+(Tabla principal|Registro detallado)', ln):
                in_main = True
                continue
            if in_main and ln.startswith("##") and "Tabla" not in ln and "Registro" not in ln:
                in_main = False
            if not in_main:
                continue
            result = parse_row(ln)
            if result:
                prog, bc_raw, nombre, bian, rol, conf, loc, dominio = result
                # BC-ID real vs clasificación no-BC (— · TRANSV · texto → bc_id vacío)
                bc_id = bc_raw if re.match(r'^BC-\d+$', bc_raw) else ""
                slug  = BC_TO_SLUG.get(bc_id, "")
                conf_u = conf.upper() if conf.upper() in _CONF else conf
                conn.execute(
                    "INSERT OR REPLACE INTO programs VALUES (?,?,?,?,?,?,?,?,?,?)",
                    (prog, sistema, bc_id, slug, nombre, bian, conf_u, rol, loc, dominio)
                )
                inserted += 1
    conn.commit()
    print(f"  programs: {inserted} registros")

# ── Loader: tasks ─────────────────────────────────────────────────────────────
def load_tasks(conn: sqlite3.Connection):
    """
    Captura TODAS las secciones 'Inventario de Tareas' (H2 base + H3 Ampliación).
    Base:      | ID | Tarea | Programa/Componente | Tipo |            (4 col)
    Ampliación:| ID | Nombre | Programa | Tipo | Complejidad | Riesgo | (6 col)
    """
    cap_dir  = KB_ALT / "capacidades"
    inserted = 0
    TASK_ROW = re.compile(r'^\|\s*(T-[A-Z]+(?:-P\d+)?-\d+)\s*\|')
    for cap_file in sorted(cap_dir.glob("cap-*.md")):
        slug  = cap_file.stem.replace("cap-", "")
        bc_id = SLUG_TO_BC.get(slug, "")
        in_tasks = False
        for ln in cap_file.read_text(encoding="utf-8").splitlines():
            # cualquier header (H2/H3) que sea "Inventario de Tareas" abre sección
            if re.match(r'^#{2,3}\s+Inventario de Tareas', ln):
                in_tasks = True
                continue
            # otro header cierra la sección
            if in_tasks and re.match(r'^#{2,3}\s+', ln):
                in_tasks = False
            if not in_tasks:
                continue
            if not TASK_ROW.match(ln):
                continue
            cells = [c.strip() for c in ln.strip().strip("|").split("|")]
            if len(cells) < 4:
                continue
            task_id = cells[0]
            desc    = cells[1]
            prog    = cells[2]
            tipo    = cells[3]
            conn.execute(
                "INSERT OR REPLACE INTO tasks VALUES (?,?,?,?,?,?)",
                (task_id, bc_id, slug, prog, desc, tipo)
            )
            inserted += 1
    conn.commit()
    print(f"  tasks: {inserted} tareas")

# ── Loader: rules ─────────────────────────────────────────────────────────────
SKIP_FILES = {
    "rules-index.md", "schema-canonico-reglas.md", "homologation-inventory.md",
}

FIELD_MAP = {
    "identificador":   "rule_id",
    "nombre":          "nombre",
    "estado ciclo":    "estado",
    "bc-id":           "bc_id",
    "bian_ref":        "bian_ref",
    "tipo regla":      "tipo_regla",
    "tipo técnico":    "tipo_tecnico",
    "confianza":       "confianza",
    "veredicto":       "veredicto",
    "regulador":       "regulador",
    "programa ejecutor": "programa",
}

def _derive_clase(rule: dict) -> str:
    tipo    = (rule.get("tipo_regla")   or "").lower()
    tecnico = (rule.get("tipo_tecnico") or "").upper()
    bc_id   = rule.get("bc_id", "")
    reg     = rule.get("regulador", "")
    if bc_id == "BC-13" or any(s in reg for s in ("CNBV", "TESOFE", "IFRS", "NIF")):
        return "CONTABLE"
    if "habilitac" in tipo:
        return "CONTROL_FLUJO"
    if "restricc" in tipo and any(t in tecnico for t in ("VALIDACION", "GUARD", "RANGO")):
        return "VALIDACION"
    return "NEGOCIO"

def _derive_sub_tipo(rule: dict) -> str:
    tecnico = (rule.get("tipo_tecnico") or "").upper()
    if "FORMULA"    in tecnico: return "FORMULA"
    if "CONDICION"  in tecnico: return "CONDICIONAL"
    if "MAPEO"      in tecnico: return "MAPEO"
    if "VALIDACION" in tecnico: return "VALIDACION"
    if any(t in tecnico for t in ("CALCULO", "CÁLCULO")): return "CALCULO"
    return rule.get("tipo_regla", "")

def _extract_vocab_inline(line: str, rule_id: str) -> list[dict]:
    m = re.search(r'f[oó]rmula[*:]+\**\s*(.*)', line)
    if not m:
        return []
    raw = m.group(1).strip()
    if not raw:
        return []
    terms = [t.strip().strip("`").strip("*").strip(":")
             for t in re.split(r'[·•,]', raw) if t.strip()]
    return [{"rule_id": rule_id, "term": t, "categoria": "", "alcance": "", "significado": ""}
            for t in terms if t and len(t) > 1 and not t.startswith("-")]

def parse_rules_file(path: Path) -> tuple[list[dict], list[dict]]:
    sistema = detect_sistema(str(path))
    source  = path.name
    lines   = path.read_text(encoding="utf-8").splitlines()
    rules: list[dict]      = []
    vocab_refs: list[dict] = []

    RULE_HDR = re.compile(r'^#{2,3}\s+(RN-(?:S500|S151)-\d+)')
    i = 0
    while i < len(lines):
        ln = lines[i]
        m  = RULE_HDR.match(ln)
        if not m:
            i += 1
            continue
        rule_id_h = m.group(1)
        j = i + 1
        while j < len(lines) and not RULE_HDR.match(lines[j]):
            j += 1
        block = lines[i:j]
        i = j

        props: dict[str, str] = {}
        for bln in block:
            m2 = re.match(r'\|\s*\*\*([^*]+)\*\*\s*\|\s*(.+?)\s*\|?$', bln)
            if m2:
                key = clean(m2.group(1)).lower()
                val = clean(m2.group(2))
                for fk, fv in FIELD_MAP.items():
                    if key == fk:
                        props[fv] = val
                        break

        rule_id = props.get("rule_id") or rule_id_h
        if not rule_id:
            continue

        desc_lines: list[str] = []
        in_desc = False
        for bln in block:
            if re.match(r'\*\*Descripci[oó]n[:\*]', bln):
                in_desc = True
                rest = re.sub(r'\*\*Descripci[oó]n[:\*]\*?\*?:?\s*', '', bln).strip()
                if rest:
                    desc_lines.append(rest)
                continue
            if in_desc:
                if re.match(r'\*\*(Trigger|Campos|Traza|Riesgos|F[oó]rmula|Vocabulario|Estado|Excepciones)', bln):
                    break
                if bln.strip() and not bln.strip().startswith("|"):
                    desc_lines.append(bln.strip())
        descripcion = " ".join(desc_lines).strip()

        risk_lines: list[str] = []
        in_risk = False
        for bln in block:
            if re.match(r'\*\*(Riesgos de migraci|Excepciones)', bln):
                in_risk = True
                continue
            if in_risk:
                if re.match(r'\*\*(Vocabulario|Estado|---)', bln):
                    break
                s = bln.strip()
                if s.startswith("-"):
                    risk_lines.append(s.lstrip("-").strip())
        riesgos = " | ".join(risk_lines)

        in_vocab          = False
        vocab_inline_done = False
        for bln in block:
            if re.match(r'\*\*Vocabulario en la f[oó]rmula', bln):
                inline = _extract_vocab_inline(bln, rule_id)
                if inline:
                    vocab_refs.extend(inline)
                    vocab_inline_done = True
                else:
                    in_vocab = True
                continue
            if vocab_inline_done:
                continue
            if in_vocab:
                if re.match(r'\*\*(Estado|---)', bln):
                    break
                cells = [c.strip().strip("`") for c in bln.strip().strip("|").split("|")]
                if len(cells) >= 5 and cells[0] and not cells[0].startswith("-"):
                    term_vocab = cells[1] if cells[1] not in ("—", "") else cells[0]
                    cat        = cells[2] if cells[2] not in ("—", "") else ""
                    alcance    = cells[3] if cells[3] not in ("—", "") else ""
                    sig        = cells[4] if cells[4] not in ("—", "") else ""
                    if term_vocab and term_vocab.lower() not in ("término vocab", "—", "term"):
                        vocab_refs.append({
                            "rule_id":   rule_id,
                            "term":      term_vocab,
                            "categoria": cat,
                            "alcance":   alcance,
                            "significado": sig,
                        })

        bc_id   = props.get("bc_id", "")
        bc_slug = BC_TO_SLUG.get(bc_id, "")
        rule    = {
            "rule_id":      rule_id,
            "sistema":      sistema,
            "nombre":       props.get("nombre", ""),
            "bc_id":        bc_id,
            "bc_slug":      bc_slug,
            "bian_ref":     props.get("bian_ref", ""),
            "tipo_regla":   props.get("tipo_regla", ""),
            "tipo_tecnico": props.get("tipo_tecnico", ""),
            "confianza":    props.get("confianza", ""),
            "veredicto":    props.get("veredicto", ""),
            "regulador":    props.get("regulador", ""),
            "programa":     props.get("programa", ""),
            "descripcion":  descripcion,
            "riesgos":      riesgos,
            "estado":       props.get("estado", ""),
            "source_file":  source,
        }
        rule["clase"]    = _derive_clase(rule)
        rule["sub_tipo"] = _derive_sub_tipo(rule)
        rules.append(rule)

    return rules, vocab_refs

def load_rules(conn: sqlite3.Connection):
    rules_cat = KB_ALT / "rules-catalog"
    all_rules: list[dict] = []
    all_vocab: list[dict] = []

    for md in sorted(rules_cat.glob("rules-*.md")):
        if md.name in SKIP_FILES:
            continue
        r, v = parse_rules_file(md)
        all_rules.extend(r)
        all_vocab.extend(v)

    for r in all_rules:
        conn.execute(
            "INSERT OR REPLACE INTO rules VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (r["rule_id"], r["sistema"], r["nombre"], r["bc_id"], r["bc_slug"],
             r["bian_ref"], r["tipo_regla"], r["tipo_tecnico"], r["clase"], r["sub_tipo"],
             r["confianza"], r["veredicto"], r["regulador"], r["programa"],
             r["descripcion"], r["riesgos"], r["estado"], r["source_file"])
        )

    seen: set[tuple] = set()
    for v in all_vocab:
        key = (v["rule_id"], v["term"])
        if key in seen:
            continue
        seen.add(key)
        conn.execute(
            "INSERT OR REPLACE INTO rule_vocab VALUES (?,?,?,?,?)",
            (v["rule_id"], v["term"], v["categoria"], v["alcance"], v["significado"])
        )

    term_data: dict[str, dict] = {}
    for v in all_vocab:
        t = v["term"]
        if t not in term_data:
            term_data[t] = {
                "categoria": v["categoria"], "alcance": v["alcance"],
                "significado": v["significado"], "count": 0,
            }
        term_data[t]["count"] += 1
    for term, td in term_data.items():
        conn.execute(
            "INSERT OR REPLACE INTO vocab_terms VALUES (?,?,?,?,?)",
            (term, td["categoria"], td["alcance"], td["significado"], td["count"])
        )

    conn.commit()
    print(f"  rules: {len(all_rules)} reglas · vocab_refs: {len(seen)} · vocab_terms: {len(term_data)}")

# ── Loader: inventario ────────────────────────────────────────────────────────
def load_inventario(conn: sqlite3.Connection):
    """
    inventario-s500.md / inventario-s151.md:
    | Programa | Tipo | LOC | Dominio | Aristas salientes |
    Sección: ## Inventario detallado
    """
    inserted = 0
    for inv_file in [
        KB_ALT / "data" / "S500" / "inventario-s500.md",
        KB_ALT / "data" / "S151" / "inventario-s151.md",
    ]:
        if not inv_file.exists():
            print(f"  (inventario no encontrado: {inv_file.name})")
            continue
        sistema  = "S500" if "s500" in inv_file.name else "S151"
        in_table = False
        for ln in inv_file.read_text(encoding="utf-8").splitlines():
            if re.match(r'##\s+Inventario detallado', ln):
                in_table = True
                continue
            if not in_table:
                continue
            if re.match(r'\|\s*[-:]+', ln):
                continue
            if not ln.strip().startswith("|"):
                continue
            cells = [c.strip() for c in ln.strip().strip("|").split("|")]
            if len(cells) < 5:
                continue
            prog, tipo, loc_s, dominio, aristas_s = (
                cells[0], cells[1], cells[2], cells[3], cells[4]
            )
            if not prog or prog.lower() in ("programa", "---"):
                continue
            loc     = _parse_int(loc_s)
            aristas = _parse_int(aristas_s)
            conn.execute(
                "INSERT OR REPLACE INTO inventario VALUES (?,?,?,?,?,?)",
                (prog, sistema, tipo, loc, dominio, aristas)
            )
            inserted += 1
    conn.commit()
    print(f"  inventario: {inserted} artefactos")

# ── Loader: vocab_full ────────────────────────────────────────────────────────
def load_vocab_full(conn: sqlite3.Connection):
    """
    vocab-s500.md / vocab-s151.md — 11 columnas:
    | # | Termino | Frecuencia | Categoria | Confianza | Evidencia |
    | Significado | Alcance | Programas | Aliases | Sensibilidad |
    """
    inserted = 0
    for vocab_file in [
        KB_ALT / "data" / "S500" / "vocab-s500.md",
        KB_ALT / "data" / "S151" / "vocab-s151.md",
    ]:
        if not vocab_file.exists():
            print(f"  (vocab no encontrado: {vocab_file.name})")
            continue
        sistema  = "S500" if "s500" in vocab_file.name else "S151"
        in_table = False
        for ln in vocab_file.read_text(encoding="utf-8").splitlines():
            if re.match(r'\|\s*#\s*\|\s*[Tt]ermino', ln):
                in_table = True
                continue
            if not in_table:
                continue
            if re.match(r'\|\s*[-:]+', ln):
                continue
            if not ln.strip().startswith("|"):
                continue
            cells = [c.strip().strip("`") for c in ln.strip().strip("|").split("|")]
            if len(cells) < 3:
                continue
            # cells: [#, Termino, Frecuencia, Categoria, Confianza, Evidencia,
            #          Significado, Alcance, Programas, Aliases, Sensibilidad]
            term = cells[1] if len(cells) > 1 else ""
            if not term or term.lower() in ("termino", "término", "---", ""):
                continue
            freq = _parse_int(cells[2]) if len(cells) > 2 else 0
            conn.execute(
                "INSERT OR REPLACE INTO vocab_full VALUES (?,?,?,?,?,?,?,?,?,?,?)",
                (
                    term, sistema, freq or 0,
                    cells[3] if len(cells) > 3 else "",
                    cells[4] if len(cells) > 4 else "",
                    cells[5] if len(cells) > 5 else "",
                    cells[6] if len(cells) > 6 else "",
                    cells[7] if len(cells) > 7 else "",
                    cells[8] if len(cells) > 8 else "",
                    cells[9] if len(cells) > 9 else "",
                    cells[10] if len(cells) > 10 else "",
                )
            )
            inserted += 1
    conn.commit()
    print(f"  vocab_full: {inserted} términos")

# ── Loader: vocab_rule_xref ───────────────────────────────────────────────────
def load_vocab_rule_xref(conn: sqlite3.Connection):
    """
    vocab-rules-xref.md:
    ## S500 — N términos
    | Término | # Reglas | Reglas |
    | `DMTERMINATE` | 13 | RN-S500-195 · RN-S500-201 … (+1) |
    """
    xref_file = KB_ALT / "vocab-rules-xref.md"
    if not xref_file.exists():
        print("  vocab_rule_xref: (archivo no encontrado, omitido)")
        return

    current_sistema = "AMBOS"
    inserted = 0
    for ln in xref_file.read_text(encoding="utf-8").splitlines():
        if re.match(r'##\s+S500', ln):
            current_sistema = "S500"
            continue
        if re.match(r'##\s+S151', ln):
            current_sistema = "S151"
            continue
        if re.match(r'\|\s*[-:]+', ln) or not ln.strip().startswith("|"):
            continue

        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        if len(cells) < 3:
            continue
        term = cells[0].strip().strip("`")
        if not term or term.lower() in ("término", "termino", "---", ""):
            continue

        rules_raw = cells[2]
        rules_raw = re.sub(r'\s*[…\.]{2,}\s*\(\+\d+\)', '', rules_raw)
        rule_ids  = [r.strip() for r in re.split(r'[\s·•]+', rules_raw)
                     if re.match(r'RN-S\d+-\d+', r.strip())]

        for rule_id in rule_ids:
            sis = "S500" if "S500" in rule_id else "S151" if "S151" in rule_id else current_sistema
            try:
                conn.execute(
                    "INSERT OR IGNORE INTO vocab_rule_xref VALUES (?,?,?)",
                    (term, rule_id, sis)
                )
                inserted += 1
            except sqlite3.IntegrityError:
                pass

    conn.commit()
    print(f"  vocab_rule_xref: {inserted} pares (term, rule_id)")

# ── Loader: pseudocodigo ──────────────────────────────────────────────────────
def load_pseudocodigo(conn: sqlite3.Connection):
    """
    RECURSIVO — captura todos los *.pseudo.md incluyendo subcarpetas:
      pseudocodigo-{sis}/            → tipo=program
      pseudocodigo-{sis}/libraries/  → tipo=library
      pseudocodigo-{sis}/modules/    → tipo=module
      pseudocodigo-{sis}/wfl/        → tipo=wfl
    Nombre: P109.pseudo.md → programa = P109
    """
    prog_bc: dict[tuple, str] = {
        (r[0], r[1]): r[2]
        for r in conn.execute("SELECT prog_id, sistema, bc_id FROM programs").fetchall()
    }

    pseudo_dirs: list[tuple[Path | None, str]] = []
    for sistema, candidates in [
        ("S500", [KB_ALT / "data" / "S500" / "pseudocodigo-s500"]),
        ("S151", [
            KB_ALT / "data" / "S151" / "pseudocodigo-S151",
            KB_ALT / "data" / "S151" / "pseudocodigo-s151",
        ]),
    ]:
        pseudo_dirs.append((next((d for d in candidates if d.exists()), None), sistema))

    def _tipo(rel_parts: tuple) -> str:
        for token in ("libraries", "modules", "wfl"):
            if token in rel_parts:
                return {"libraries": "library", "modules": "module", "wfl": "wfl"}[token]
        return "program"

    inserted = 0
    counts: dict[str, int] = {}
    for pseudo_dir, sistema in pseudo_dirs:
        if pseudo_dir is None:
            print(f"  (directorio pseudocodigo {sistema} no encontrado)")
            continue
        for pseudo_file in sorted(pseudo_dir.rglob("*.pseudo.md")):
            prog = pseudo_file.name.replace(".pseudo.md", "").replace(".pseudo", "")
            if not prog:
                continue
            rel_parts = pseudo_file.relative_to(pseudo_dir).parts
            tipo      = _tipo(rel_parts)
            bc_id     = prog_bc.get((prog, sistema), "")
            contenido = pseudo_file.read_text(encoding="utf-8")
            conn.execute(
                "INSERT OR REPLACE INTO pseudocodigo VALUES (?,?,?,?,?,?)",
                (prog, sistema, tipo, bc_id, pseudo_file.name, contenido)
            )
            inserted += 1
            counts[tipo] = counts.get(tipo, 0) + 1

    conn.commit()
    detalle = " · ".join(f"{k}={v}" for k, v in sorted(counts.items()))
    print(f"  pseudocodigo: {inserted} archivos ({detalle})")

# ── Loader: wfl_catalog ───────────────────────────────────────────────────────
def load_wfl_catalog(conn: sqlite3.Connection):
    """
    wfl-catalog.md: secciones ### WFL_NAME
    Property table: | Campo | Valor |
    **Función:** prose en la misma o siguiente línea
    **Dependencias directas:** tabla | Programa | Capacidad | Función |
    """
    wfl_file = KB_ALT / "wfl-catalog.md"
    if not wfl_file.exists():
        print("  wfl_catalog: (wfl-catalog.md no encontrado)")
        return

    WFL_HDR = re.compile(r'^###\s+(WFL\S+)')
    lines   = wfl_file.read_text(encoding="utf-8").splitlines()

    def flush(cur_wfl: dict) -> bool:
        if not cur_wfl.get("wfl_id"):
            return False
        conn.execute(
            "INSERT OR REPLACE INTO wfl_catalog VALUES (?,?,?,?,?,?,?)",
            (
                cur_wfl["wfl_id"],
                cur_wfl.get("sistema", ""),
                cur_wfl.get("bian", ""),
                cur_wfl.get("riesgo", ""),
                cur_wfl.get("estrategia", ""),
                cur_wfl.get("funcion", ""),
                cur_wfl.get("dependencias", ""),
            )
        )
        return True

    cur_wfl: dict = {}
    inserted = 0

    for ln in lines:
        m = WFL_HDR.match(ln)
        if m:
            if flush(cur_wfl):
                inserted += 1
            cur_wfl = {"wfl_id": m.group(1)}
            continue

        if not cur_wfl.get("wfl_id"):
            continue

        # Property table | Campo | Valor |
        m2 = re.match(r'\|\s*\*?\*?([^|*]+)\*?\*?\s*\|\s*([^|]+?)\s*\|', ln)
        if m2:
            campo = m2.group(1).strip().lower().rstrip("*").rstrip(":")
            val   = clean(m2.group(2))
            if campo == "sistema":
                cur_wfl["sistema"] = val
            elif campo == "bian":
                cur_wfl["bian"] = val
            elif campo in ("riesgo máximo", "riesgo"):
                cur_wfl["riesgo"] = val
            elif campo == "estrategia":
                cur_wfl["estrategia"] = val
            # Dependencias table: | Programa | Capacidad | Función |
            prog_m = re.match(r'\|\s*([A-Z]\w+)\s*\|', ln)
            if prog_m and campo not in ("campo", "sistema", "bian", "riesgo máximo", "estrategia"):
                prog_name = prog_m.group(1)
                if prog_name.lower() not in ("programa", "campo"):
                    cap_part = m2.group(2).strip() if m2 else ""
                    dep_entry = f"{prog_name}:{cap_part}"
                    deps = cur_wfl.get("dependencias", "")
                    cur_wfl["dependencias"] = (deps + " | " + dep_entry).strip(" | ")

        # Función prose
        m3 = re.match(r'\*\*Funci[oó]n:\*\*\s*(.*)', ln)
        if m3 and m3.group(1).strip():
            cur_wfl["funcion"] = m3.group(1).strip()

    if flush(cur_wfl):
        inserted += 1
    conn.commit()
    print(f"  wfl_catalog: {inserted} WFLs")

# ── Loader: cross_dependencies (desde integration-map.md) ────────────────────
# Mapeo de categoría H2 → (dep_type, criticality)
CAT_TYPE: dict[str, tuple] = {
    "redes de pago":                      ("INTEGRACION",  "ALTA"),
    "autoridades regulatorias":           ("REGULATORIO",  "ALTA"),
    "sistemas corporativos citi":         ("CORPORATIVO",  "ALTA"),
    "analytics":                          ("ANALYTICS",    "MEDIA"),
    "observabilidad":                     ("ANALYTICS",    "MEDIA"),
    "mensajería":                         ("INTEGRACION",  "MEDIA"),
    "pagos internacionales":              ("INTEGRACION",  "ALTA"),
    "antifraude":                         ("INTEGRACION",  "ALTA"),
    "dependencias cross-sistema":         ("INTERNO",      "ALTA"),
    "internos":                           ("INTERNO",      "ALTA"),
}

def _cat_to_type(cat: str) -> tuple[str, str]:
    cat_low = cat.lower()
    for key, val in CAT_TYPE.items():
        if key in cat_low:
            return val
    return ("INTEGRACION", "MEDIA")

def load_cross_dependencies(conn: sqlite3.Connection):
    imap_file = KB_ALT / "integration-map.md"
    if not imap_file.exists():
        print("  cross_dependencies: (integration-map.md no encontrado, omitido)")
        return

    lines       = imap_file.read_text(encoding="utf-8").splitlines()
    current_cat = ""
    cur_sys: dict = {}
    systems: list[dict] = []

    def flush_sys(cur_sys: dict, cat: str) -> dict | None:
        name = cur_sys.get("nombre", "").strip()
        if not name:
            return None
        dep_type, criticality = _cat_to_type(cat)
        return {
            "nombre":      name,
            "direction":   cur_sys.get("direction", "BIDIRECCIONAL"),
            "descripcion": cur_sys.get("descripcion", ""),
            "dep_type":    dep_type,
            "criticality": criticality,
        }

    for ln in lines:
        # H2 → categoría
        m_cat = re.match(r'^##\s+\d+\.\s+(.*)', ln)
        if m_cat:
            if cur_sys:
                s = flush_sys(cur_sys, current_cat)
                if s:
                    systems.append(s)
            current_cat = m_cat.group(1).strip()
            cur_sys = {}
            continue

        # H3 → sistema
        m_sys = re.match(r'^###\s+[\d.]+\s+(.*)', ln)
        if m_sys:
            if cur_sys:
                s = flush_sys(cur_sys, current_cat)
                if s:
                    systems.append(s)
            cur_sys = {"nombre": m_sys.group(1).strip()}
            continue

        if not cur_sys.get("nombre"):
            continue

        # Property table | **Campo** | Valor |
        m_prop = re.match(r'\|\s*\*\*([^*]+)\*\*\s*\|\s*([^|]+?)\s*\|', ln)
        if m_prop:
            campo = m_prop.group(1).strip().lower()
            val   = m_prop.group(2).strip()
            if "direcci" in campo:
                cur_sys["direction"] = val.upper()
            elif campo == "sistema":
                cur_sys["descripcion"] = val

    if cur_sys:
        s = flush_sys(cur_sys, current_cat)
        if s:
            systems.append(s)

    inserted = 0
    for i, data in enumerate(systems, start=1):
        # ID: XDEP-{NOMBRE_LIMPIO}-NN
        nombre_clean = re.sub(r'[^A-Za-z0-9]', '', data["nombre"].split("/")[0].strip().upper())[:10]
        xdep_id      = f"XDEP-{nombre_clean or 'SYS'}-{i:02d}"
        conn.execute(
            "INSERT OR REPLACE INTO cross_dependencies VALUES (?,?,?,?,?,?,?,?)",
            (
                xdep_id, data["nombre"], data["dep_type"], data["direction"],
                data["criticality"], 0, "", data["descripcion"]
            )
        )
        inserted += 1

    conn.commit()
    print(f"  cross_dependencies: {inserted} sistemas ({len([s for s in systems if s['dep_type'] == 'REGULATORIO'])} regulatorios)")

# ══════════════════════════════════════════════════════════════════════════════
# LOADERS ADICIONALES · QA 2026-09-29 — captura de relaciones faltantes
# ══════════════════════════════════════════════════════════════════════════════

def _table_rows(lines: list[str]):
    """Itera celdas de filas de tabla Markdown (salta separadores |---|)."""
    for ln in lines:
        s = ln.strip()
        if not s.startswith("|"):
            continue
        if re.match(r'\|\s*[-:]+', s):
            continue
        yield [c.strip() for c in s.strip("|").split("|")]

def _split_h2(text: str) -> dict[str, list[str]]:
    """Divide un MD en secciones por header H2 (## ...). Devuelve {titulo: [lineas]}."""
    sections: dict[str, list[str]] = {}
    current = "__preamble__"
    buf: list[str] = []
    for ln in text.splitlines():
        m = re.match(r'^##\s+(.*)', ln)
        if m and not ln.startswith("###"):
            sections.setdefault(current, []).extend(buf)
            current = m.group(1).strip()
            buf = []
        else:
            buf.append(ln)
    sections.setdefault(current, []).extend(buf)
    return sections

# ── Loader: flujos (flujos-ensamblado.md) ─────────────────────────────────────
def load_flujos(conn: sqlite3.Connection):
    f = KB_ALT / "flujos-ensamblado.md"
    if not f.exists():
        print("  flujos: (flujos-ensamblado.md no encontrado)")
        return

    lines = f.read_text(encoding="utf-8").splitlines()
    prog_re = re.compile(r'\b([PL]\d{2,4}[A-Z_]*)\b')

    cap_slug = ""
    bc_id    = ""
    subid    = ""
    titulo   = ""
    in_mer   = False
    mer_buf: list[str] = []
    inserted = 0
    seq      = 0

    def flush(cap_slug, bc_id, subid, titulo, mer_buf):
        nonlocal inserted, seq
        if not mer_buf or not cap_slug:
            return
        seq += 1
        mermaid = "\n".join(mer_buf)
        progs, xcaps = set(), set()
        for ml in mer_buf:
            is_x = (":::xcap" in ml) or ("(cap-" in ml)
            for p in prog_re.findall(ml):
                (xcaps if is_x else progs).add(p)
        flujo_id = f"{cap_slug}#{subid or seq}"
        conn.execute(
            "INSERT OR REPLACE INTO flujos VALUES (?,?,?,?,?,?,?,?)",
            (flujo_id, cap_slug, bc_id, subid, titulo,
             ",".join(sorted(progs)), ",".join(sorted(xcaps)), mermaid)
        )
        inserted += 1

    i = 0
    while i < len(lines):
        ln = lines[i]
        m_h2 = re.match(r'^##\s+(cap-\S+)\s*·\s*(.*)', ln)
        if m_h2 and not ln.startswith("###"):
            # slug bare (sin prefijo 'cap-') para que joinee con capacidades.slug
            cap_slug = m_h2.group(1).strip().replace("cap-", "", 1)
            titulo   = m_h2.group(2).strip()
            subid    = ""
            # buscar bc_id en la línea de blockquote siguiente
            bc_id = ""
            if i + 1 < len(lines):
                mb = re.search(r'(BC-\d+)', lines[i + 1])
                if mb:
                    bc_id = mb.group(1)
            i += 1
            continue
        m_h3 = re.match(r'^###\s+(.*)', ln)
        if m_h3:
            m_sub = re.match(r'([\d.]+[a-z]?)\s*·\s*(.*)', m_h3.group(1))
            if m_sub:
                subid  = m_sub.group(1).strip()
                titulo = m_sub.group(2).strip()
            else:
                subid  = ""
                titulo = m_h3.group(1).strip()
            i += 1
            continue
        if ln.strip().startswith("```mermaid"):
            in_mer  = True
            mer_buf = []
            i += 1
            continue
        if in_mer and ln.strip().startswith("```"):
            in_mer = False
            flush(cap_slug, bc_id, subid, titulo, mer_buf)
            mer_buf = []
            i += 1
            continue
        if in_mer:
            mer_buf.append(ln)
        i += 1

    conn.commit()
    print(f"  flujos: {inserted} sub-flujos Mermaid")

# ── Loader: cross_cap (cross-cap-index.md) ────────────────────────────────────
def load_cross_cap(conn: sqlite3.Connection):
    f = KB_ALT / "cross-cap-index.md"
    if not f.exists():
        print("  cross_cap: (cross-cap-index.md no encontrado)")
        return
    # normaliza a slug bare: 'cap-dep (P050)' -> 'dep', 'cap-gl' -> 'gl'
    def _slug(s: str) -> str:
        s = re.sub(r'\s*\(.*?\)', '', s).strip()   # quita decoración '(P050)'
        return s.replace("cap-", "", 1).strip() if s.startswith("cap-") else s.strip()

    inserted = 0
    for cells in _table_rows(f.read_text(encoding="utf-8").splitlines()):
        if len(cells) < 4:
            continue
        origen = cells[0].strip()
        # saltar header y la tabla resumen (2 cols)
        if origen.lower() in ("cap origen", "origen → destino", ""):
            continue
        if "→" in origen:  # tabla resumen
            continue
        prog = clean(cells[1])
        dest = cells[2].strip()
        etiq = cells[3].strip()
        inserted += 1
        conn.execute(
            "INSERT OR REPLACE INTO cross_cap VALUES (?,?,?,?,?)",
            (inserted, _slug(origen), prog, _slug(dest), etiq)
        )
    conn.commit()
    print(f"  cross_cap: {inserted} enlaces cap→cap")

# ── Loader: traceability (traceability-matrix.md) ─────────────────────────────
def load_traceability(conn: sqlite3.Connection):
    f = KB_ALT / "traceability-matrix.md"
    if not f.exists():
        print("  traceability: (traceability-matrix.md no encontrado)")
        return
    text = f.read_text(encoding="utf-8")
    n_tr = 0
    for cells in _table_rows(text.splitlines()):
        if len(cells) < 6:
            continue
        bc = cells[0].strip()
        if not re.match(r'BC-\d+', bc):
            continue
        conn.execute(
            "INSERT OR REPLACE INTO traceability VALUES (?,?,?,?,?,?)",
            (bc, cells[1].strip(), cells[2].strip(),
             _parse_int(cells[3]) or 0, _parse_int(cells[4]) or 0, _parse_int(cells[5]) or 0)
        )
        n_tr += 1
    # §2 bullets: - **P053** (10): RN-S151-950..959
    n_un = 0
    bullet = re.compile(r'^\s*-\s+\*\*([^*]+)\*\*\s*\((\d+)\)\s*:\s*(.*)')
    for ln in text.splitlines():
        m = bullet.match(ln)
        if m:
            conn.execute(
                "INSERT OR REPLACE INTO traceability_unresolved VALUES (?,?,?)",
                (m.group(1).strip(), int(m.group(2)), m.group(3).strip())
            )
            n_un += 1
    conn.commit()
    print(f"  traceability: {n_tr} BC + {n_un} programas sin-cap")

# ── Loader: db_fisicas + datasets (dasdl + dataset-summary) ───────────────────
def load_datasets(conn: sqlite3.Connection):
    n_db = n_ds = 0

    # db_fisicas: tabla resumen de cada dasdl-*.md
    for dasdl, sistema in [("dasdl-s500.md", "S500"), ("dasdl-s151.md", "S151")]:
        fp = KB_ALT / "data" / sistema / dasdl
        if not fp.exists():
            continue
        for cells in _table_rows(fp.read_text(encoding="utf-8").splitlines()):
            if len(cells) < 5:
                continue
            bd = cells[0].strip()
            if not re.match(r'BD\d+', bd):
                continue
            conn.execute(
                "INSERT OR REPLACE INTO db_fisicas VALUES (?,?,?,?,?,?)",
                (bd, sistema, cells[1].strip(), cells[2].strip(),
                 _parse_int(cells[3]) or 0, cells[4].strip())
            )
            n_db += 1

    # datasets S500: dataset-summary-s500.md (H2 por BD → tabla 5-col)
    fp = KB_ALT / "data" / "S500" / "dataset-summary-s500.md"
    if fp.exists():
        cur_db = ""
        for ln in fp.read_text(encoding="utf-8").splitlines():
            m = re.match(r'^##\s+(BD\d+)', ln)
            if m:
                cur_db = m.group(1)
                continue
            cells = None
            s = ln.strip()
            if s.startswith("|") and not re.match(r'\|\s*[-:]+', s):
                cells = [c.strip() for c in s.strip("|").split("|")]
            if not cells or len(cells) < 5:
                continue
            ds = _norm_dataset(cells[0])
            if ds.lower() in ("dataset", ""):
                continue
            conn.execute(
                "INSERT OR REPLACE INTO datasets VALUES (?,?,?,?,?,?,?)",
                (ds, "S500", cur_db, cells[2].strip(), cells[1].strip(),
                 cells[3].strip().replace(" ", ""), cells[4].strip())
            )
            n_ds += 1

    # datasets S151: dasdl-s151.md per-DB (H2 `## BDxx · nombre`, tabla 2-col Dataset|Descripcion)
    fp = KB_ALT / "data" / "S151" / "dasdl-s151.md"
    if fp.exists():
        cur_db = ""
        for ln in fp.read_text(encoding="utf-8").splitlines():
            m = re.match(r'^##\s+(BD\d+)', ln)
            if m:
                cur_db = m.group(1)
                continue
            s = ln.strip()
            if not s.startswith("|") or re.match(r'\|\s*[-:]+', s):
                continue
            cells = [c.strip() for c in s.strip("|").split("|")]
            if len(cells) < 2:
                continue
            ds_raw = cells[0].strip()
            if ds_raw.lower() in ("dataset", "bd", "") or not re.match(r'[A-Z]', ds_raw):
                continue
            # evitar la tabla resumen (cuyo primer campo es BDxx)
            if re.match(r'BD\d+', ds_raw):
                continue
            ds = _norm_dataset(ds_raw)
            try:
                conn.execute(
                    "INSERT OR IGNORE INTO datasets VALUES (?,?,?,?,?,?,?)",
                    (ds, "S151", cur_db, "", "", "", cells[1].strip())
                )
                n_ds += 1
            except sqlite3.IntegrityError:
                pass

    conn.commit()
    print(f"  datasets: {n_db} BD físicas · {n_ds} datasets")

# ── Loader: campos (modelo-datos-campos-s151.md) ──────────────────────────────
def load_campos(conn: sqlite3.Connection):
    fp = KB_ALT / "data" / "S151" / "modelo-datos-campos-s151.md"
    if not fp.exists():
        print("  campos: (modelo-datos-campos-s151.md no encontrado)")
        return
    cur_ds = ""
    inserted = 0
    for ln in fp.read_text(encoding="utf-8").splitlines():
        m = re.match(r'^###\s+([A-Z0-9]+)\s*·(.*)', ln)
        if m:
            cur_ds = _norm_dataset(m.group(1))
            # registrar el dataset (modelo-datos documenta más datasets que dasdl-s151)
            m_pop = re.search(r'pop\s+([\d,\. ]+)', m.group(2))
            pop = m_pop.group(1).strip().replace(" ", "") if m_pop else ""
            conn.execute(
                "INSERT OR IGNORE INTO datasets VALUES (?,?,?,?,?,?,?)",
                (cur_ds, "S151", "", "DATA SET", "", pop, "")
            )
            continue
        s = ln.strip()
        if not cur_ds or not s.startswith("|") or re.match(r'\|\s*[-:]+', s):
            continue
        cells = [c.strip() for c in s.strip("|").split("|")]
        if len(cells) < 3:
            continue
        campo = cells[0].strip()
        if campo.lower() in ("campo", "") or not re.match(r'[A-Z0-9]', campo):
            continue
        tipo = cells[2].strip() if len(cells) > 2 else ""
        longitud = cells[3].strip() if len(cells) > 3 else ""
        try:
            conn.execute(
                "INSERT OR IGNORE INTO campos VALUES (?,?,?,?,?,?)",
                (cur_ds, "S151", campo, cells[1].strip(), tipo, longitud)
            )
            inserted += 1
        except sqlite3.IntegrityError:
            pass
    conn.commit()
    print(f"  campos: {inserted} campos (modelo de datos S151)")

# ── Loader: regulatory_reports (cnbv-regulatory-impact-assessment.md) ─────────
def load_regulatory(conn: sqlite3.Connection):
    fp = KB_ALT / "cnbv-regulatory-impact-assessment.md"
    if not fp.exists():
        print("  regulatory: (cnbv-regulatory-impact-assessment.md no encontrado)")
        return
    inserted = 0
    for cells in _table_rows(fp.read_text(encoding="utf-8").splitlines()):
        if len(cells) < 7:
            continue
        reporte = cells[0].strip()
        if reporte.lower() in ("reporte", "") or "regulador" in cells[1].strip().lower() and reporte.lower() == "reporte":
            continue
        if cells[1].strip().lower() == "regulador":
            continue
        try:
            conn.execute(
                "INSERT OR IGNORE INTO regulatory_reports VALUES (?,?,?,?,?,?,?)",
                (reporte, cells[1].strip(), cells[2].strip(), cells[3].strip(),
                 cells[4].strip(), cells[5].strip(), cells[6].strip())
            )
            inserted += 1
        except sqlite3.IntegrityError:
            pass
    conn.commit()
    print(f"  regulatory_reports: {inserted} reportes regulatorios")

# ── Loader: bounded_contexts + sevenr (kb-capa5-fronteras.md) ─────────────────
def load_capa5(conn: sqlite3.Connection):
    fp = KB_ALT / "kb-capa5-fronteras.md"
    if not fp.exists():
        print("  capa5: (kb-capa5-fronteras.md no encontrado)")
        return
    lines = fp.read_text(encoding="utf-8").splitlines()
    n_bc = n_7r = 0
    for cells in _table_rows(lines):
        if not cells:
            continue
        c0 = cells[0].strip()
        # Bounded contexts: BC-NN o EXT-NN
        if re.match(r'(BC|EXT)-\d+', c0) and len(cells) >= 5:
            is_ext = c0.startswith("EXT")
            try:
                if is_ext:
                    # | ID | Sistema Externo | Mecanismo | Programas dep | Prereq Wave |
                    conn.execute(
                        "INSERT OR IGNORE INTO bounded_contexts VALUES (?,?,?,?,?,?,?,?)",
                        (c0, "EXT", clean(cells[1]), "", clean(cells[3]), "",
                         clean(cells[2]), clean(cells[4]))
                    )
                else:
                    # | ID | Bounded Context | Dominio | Programas/Rango | LOC |
                    conn.execute(
                        "INSERT OR IGNORE INTO bounded_contexts VALUES (?,?,?,?,?,?,?,?)",
                        (c0, "", clean(cells[1]), clean(cells[2]), clean(cells[3]),
                         clean(cells[4]), "", "")
                    )
                n_bc += 1
            except sqlite3.IntegrityError:
                pass
            continue
        # Wave decision: | Programa | BC | Decisión | Acción | SME |
        # Señal confiable: col2 (Decisión) contiene un keyword 7R (el Programa
        # puede venir como "S151/L002R2 S151REGISTRA", no siempre empieza con P/L).
        if len(cells) >= 5 and c0.lower() not in ("programa", "tipo", "bc candidato", "id", ""):
            dec = cells[2].strip().lower()
            if any(k in dec for k in ("refactor", "rehost", "replatform", "replace",
                                       "retain", "retire", "encapsul", "relocate")):
                try:
                    conn.execute(
                        "INSERT OR IGNORE INTO sevenr_decisions VALUES (?,?,?,?,?,?)",
                        (c0, clean(cells[1]), clean(cells[2]), clean(cells[3]),
                         clean(cells[4]), "")
                    )
                    n_7r += 1
                except sqlite3.IntegrityError:
                    pass
    conn.commit()
    print(f"  capa5: {n_bc} bounded contexts · {n_7r} decisiones 7R")

# ── Loader: capability_bian_map (capability-map.md) ───────────────────────────
def load_capability_map(conn: sqlite3.Connection):
    fp = KB_ALT / "capability-map.md"
    if not fp.exists():
        print("  capability_map: (capability-map.md no encontrado)")
        return
    inserted = 0
    for cells in _table_rows(fp.read_text(encoding="utf-8").splitlines()):
        if len(cells) < 6:
            continue
        bian = clean(cells[0])
        # ID BIAN dotted: 2.1.1 / T.2.3
        if not re.match(r'[0-9T]\.\d', bian):
            continue
        cap_file = cells[4].strip()
        m_link = re.search(r'\(([^)]+\.md)\)', cap_file)
        cap_file_clean = m_link.group(1) if m_link else cap_file
        try:
            conn.execute(
                "INSERT OR IGNORE INTO capability_bian_map VALUES (?,?,?,?,?,?)",
                (bian, clean(cells[1]), clean(cells[2]), clean(cells[3]),
                 cap_file_clean, cells[5].strip())
            )
            inserted += 1
        except sqlite3.IntegrityError:
            pass
    conn.commit()
    print(f"  capability_bian_map: {inserted} capacidades BIAN")

# ── Loader: relaciones dentro de cap-*.md ─────────────────────────────────────
def load_cap_relations(conn: sqlite3.Connection):
    cap_dir = KB_ALT / "capacidades"
    n_dep = n_tr = n_hal = n_io = 0
    dep_seq = 0
    for cap_file in sorted(cap_dir.glob("cap-*.md")):
        slug  = cap_file.stem.replace("cap-", "")
        bc_id = SLUG_TO_BC.get(slug, "")
        secs  = _split_h2(cap_file.read_text(encoding="utf-8"))

        # Dependencias: | Capacidad | Relación | Cap file |
        for name, body in secs.items():
            if name.strip().lower() == "dependencias":
                for cells in _table_rows(body):
                    if len(cells) < 3 or cells[0].strip().lower() in ("capacidad", ""):
                        continue
                    dep_seq += 1
                    conn.execute(
                        "INSERT OR REPLACE INTO cap_dependencies VALUES (?,?,?,?,?)",
                        (dep_seq, slug, cells[0].strip(), clean(cells[1]), cells[2].strip())
                    )
                    n_dep += 1

            # Reglas vinculadas: | Tarea | Regla | Componente fuente | Descripción | Tags |
            elif name.strip().lower() == "reglas vinculadas":
                for cells in _table_rows(body):
                    if len(cells) < 2:
                        continue
                    task = cells[0].strip()
                    rule = cells[1].strip()
                    if not task.startswith("T-") or not rule.startswith("RN-"):
                        continue
                    comp = cells[2].strip() if len(cells) > 2 else ""
                    desc = cells[3].strip() if len(cells) > 3 else ""
                    try:
                        conn.execute(
                            "INSERT OR IGNORE INTO task_rules VALUES (?,?,?,?,?)",
                            (slug, task, rule, comp, desc)
                        )
                        n_tr += 1
                    except sqlite3.IntegrityError:
                        pass

            # Hallazgos de migración: | # | Riesgo | Tarea(s) | Severidad | Impacto | Acción |
            # NOTA: solo 4 caps usan IDs H-*; los otros 18 dejan el ID vacío → ID sintético.
            elif name.strip().lower().startswith("hallazgos"):
                seq = 0
                for cells in _table_rows(body):
                    if len(cells) < 6:
                        continue
                    c0     = cells[0].strip()
                    riesgo = clean(cells[1])
                    # saltar encabezado y filas sin riesgo
                    if c0 == "#" or riesgo.lower() == "riesgo" or not riesgo:
                        continue
                    seq += 1
                    hid    = c0 if re.match(r'H-', c0) else f"H-{slug.upper()}-{seq:02d}"
                    tareas = cells[2].strip()
                    sev    = re.sub(r'[🔴🟠🟡🟢⚪]', '', cells[3]).strip()
                    imp    = cells[4].strip()
                    acc    = cells[5].strip()
                    conn.execute(
                        "INSERT OR REPLACE INTO hallazgos VALUES (?,?,?,?,?,?,?,?)",
                        (hid, slug, bc_id, riesgo, tareas, sev, imp, acc)
                    )
                    n_hal += 1

            # M1 Blast radius: | Programa | Lee | Escribe / Genera | Criticidad |
            elif name.strip().startswith("M1"):
                for cells in _table_rows(body):
                    if len(cells) < 4:
                        continue
                    prog = cells[0].strip()
                    if not re.match(r'[PL]\d{2,4}', prog):
                        continue
                    try:
                        conn.execute(
                            "INSERT OR IGNORE INTO program_io VALUES (?,?,?,?,?)",
                            (slug, prog, cells[1].strip(), cells[2].strip(), cells[3].strip())
                        )
                        n_io += 1
                    except sqlite3.IntegrityError:
                        pass

    conn.commit()
    print(f"  cap_relations: {n_dep} deps · {n_tr} task→regla · {n_hal} hallazgos · {n_io} program-I/O")

# ── Loader: kb_documents (red de seguridad — texto crudo completo) ─────────────
def load_kb_documents(conn: sqlite3.Connection):
    """Guarda el texto COMPLETO de cada .md de la KB. Garantía de cero pérdida."""
    EXCLUDE = {"MANIFEST.md"}  # índice puro; el resto se conserva íntegro
    inserted = 0
    for md in sorted(KB_ALT.rglob("*.md")):
        if md.name in EXCLUDE:
            continue
        rel  = md.relative_to(KB_ALT)
        cat  = str(rel.parent).replace("\\", "/") if str(rel.parent) != "." else "root"
        text = md.read_text(encoding="utf-8")
        conn.execute(
            "INSERT OR REPLACE INTO kb_documents VALUES (?,?,?,?,?)",
            (str(rel).replace("\\", "/"), md.name, cat, len(text.splitlines()), text)
        )
        inserted += 1
    conn.commit()
    print(f"  kb_documents: {inserted} archivos .md (texto crudo completo)")

# ── FTS5 ──────────────────────────────────────────────────────────────────────
def build_fts(conn: sqlite3.Connection):
    conn.execute("""
        INSERT INTO rules_fts(rule_id, nombre, descripcion, riesgos)
        SELECT rule_id, COALESCE(nombre,''), COALESCE(descripcion,''), COALESCE(riesgos,'')
        FROM rules
    """)
    conn.execute("""
        INSERT INTO vocab_fts(term, significado)
        SELECT term, COALESCE(significado,'') FROM vocab_terms
    """)
    conn.execute("""
        INSERT INTO cross_deps_fts(id, other_system, description)
        SELECT id, other_system, COALESCE(description,'') FROM cross_dependencies
    """)
    conn.execute("""
        INSERT INTO pseudo_fts(programa, sistema, contenido)
        SELECT programa, sistema, COALESCE(SUBSTR(contenido, 1, 50000), '')
        FROM pseudocodigo
    """)
    conn.execute("""
        INSERT INTO kb_fts(path, filename, contenido)
        SELECT path, filename, contenido FROM kb_documents
    """)
    conn.execute("""
        INSERT INTO flujos_fts(flujo_id, titulo, mermaid)
        SELECT flujo_id, COALESCE(titulo,''), COALESCE(mermaid,'') FROM flujos
    """)
    conn.execute("""
        INSERT INTO risks_fts(risk_id, descripcion, accion)
        SELECT hallazgo_id, COALESCE(riesgo,''), COALESCE(accion,'') FROM hallazgos
    """)
    conn.commit()
    print("  FTS5: rules · vocab · cross_deps · pseudo · kb · flujos · risks")

# ── Stats ─────────────────────────────────────────────────────────────────────
def write_stats(conn: sqlite3.Connection):
    cur = conn.cursor()
    stats: dict = {}

    for table in (
        "capacidades", "programs", "tasks", "rules", "cross_dependencies",
        "inventario", "vocab_full", "vocab_rule_xref", "pseudocodigo",
        "wfl_catalog", "rule_vocab", "vocab_terms",
        "flujos", "cross_cap", "traceability", "traceability_unresolved",
        "db_fisicas", "datasets", "campos", "regulatory_reports",
        "bounded_contexts", "sevenr_decisions", "capability_bian_map",
        "program_io", "task_rules", "cap_dependencies", "hallazgos",
        "kb_documents",
    ):
        n = cur.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        stats[table] = n

    for clase in ("NEGOCIO", "CONTABLE", "CONTROL_FLUJO", "VALIDACION"):
        n = cur.execute("SELECT COUNT(*) FROM rules WHERE clase=?", (clase,)).fetchone()[0]
        stats[f"rules_clase_{clase.lower()}"] = n

    sbvr_sin = cur.execute(
        "SELECT COUNT(*) FROM rules WHERE tipo_regla IS NULL OR tipo_regla=''"
    ).fetchone()[0]
    stats["rules_sin_sbvr"] = sbvr_sin

    reg_real = cur.execute(
        "SELECT COUNT(*) FROM rules "
        "WHERE regulador NOT IN ('N/A','N/A — control de integridad','') AND regulador IS NOT NULL"
    ).fetchone()[0]
    stats["rules_con_regulador"] = reg_real

    # Metadatos de la fuente
    stats["kb_source"]  = KB_ALT.name
    stats["kb_version"] = "v1.13 / 2026-08-26"

    for k, v in stats.items():
        conn.execute("INSERT OR REPLACE INTO stats VALUES (?,?)", (k, str(v)))
    conn.commit()

    sep = "─" * 57
    print(f"\n{sep}")
    print(f" GemCog Brain v3  ·  KB {stats['kb_version']}")
    print(sep)
    print(f"  capacidades       : {stats['capacidades']:>6}")
    print(f"  programs          : {stats['programs']:>6}")
    print(f"  tasks             : {stats['tasks']:>6}")
    print(f"  rules             : {stats['rules']:>6}   ({sbvr_sin} sin tipo_regla)")
    neg = stats.get("rules_clase_negocio",       0)
    con = stats.get("rules_clase_contable",      0)
    flw = stats.get("rules_clase_control_flujo", 0)
    val = stats.get("rules_clase_validacion",    0)
    print(f"    NEGOCIO={neg}  CONTABLE={con}  CONTROL_FLUJO={flw}  VALIDACION={val}")
    print(f"  cross_dependencies: {stats.get('cross_dependencies', 0):>6}")
    print(f"  inventario        : {stats['inventario']:>6}")
    print(f"  vocab_full        : {stats['vocab_full']:>6}")
    print(f"  vocab_rule_xref   : {stats['vocab_rule_xref']:>6}")
    print(f"  pseudocodigo      : {stats['pseudocodigo']:>6}")
    print(f"  wfl_catalog       : {stats['wfl_catalog']:>6}")
    print(f"  rule_vocab        : {stats['rule_vocab']:>6}")
    print(f"  vocab_terms       : {stats['vocab_terms']:>6}")
    print(f"  con_regulador     : {reg_real:>6} reglas con norma explícita")
    print(sep)
    print(" Relaciones adicionales (QA 2026-09-29)")
    print(sep)
    print(f"  flujos            : {stats.get('flujos',0):>6}")
    print(f"  cross_cap         : {stats.get('cross_cap',0):>6}")
    print(f"  traceability      : {stats.get('traceability',0):>6}  (+{stats.get('traceability_unresolved',0)} sin-cap)")
    print(f"  db_fisicas        : {stats.get('db_fisicas',0):>6}")
    print(f"  datasets          : {stats.get('datasets',0):>6}")
    print(f"  campos            : {stats.get('campos',0):>6}")
    print(f"  regulatory_reports: {stats.get('regulatory_reports',0):>6}")
    print(f"  bounded_contexts  : {stats.get('bounded_contexts',0):>6}")
    print(f"  sevenr_decisions  : {stats.get('sevenr_decisions',0):>6}")
    print(f"  capability_bian   : {stats.get('capability_bian_map',0):>6}")
    print(f"  program_io        : {stats.get('program_io',0):>6}")
    print(f"  task_rules        : {stats.get('task_rules',0):>6}")
    print(f"  cap_dependencies  : {stats.get('cap_dependencies',0):>6}")
    print(f"  hallazgos (riesgos): {stats.get('hallazgos',0):>5}")
    print(f"  kb_documents      : {stats.get('kb_documents',0):>6}  (texto crudo completo)")
    print(sep)

# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    if DB.exists():
        DB.unlink()
        print("  (eliminado brain.db anterior)")

    conn = sqlite3.connect(DB)
    conn.executescript(SCHEMA)
    conn.execute("PRAGMA journal_mode=WAL")
    conn.execute("PRAGMA synchronous=NORMAL")

    print(f"Cargando GemCog Brain v3 desde:\n  {KB_ALT}\n")
    load_taxonomy(conn)
    load_programs(conn)
    load_tasks(conn)
    load_rules(conn)
    load_inventario(conn)
    load_vocab_full(conn)
    load_vocab_rule_xref(conn)
    load_pseudocodigo(conn)
    load_wfl_catalog(conn)
    load_cross_dependencies(conn)
    # ── Relaciones adicionales (QA 2026-09-29) ──
    load_flujos(conn)
    load_cross_cap(conn)
    load_traceability(conn)
    load_datasets(conn)
    load_campos(conn)
    load_regulatory(conn)
    load_capa5(conn)
    load_capability_map(conn)
    load_cap_relations(conn)
    load_kb_documents(conn)
    build_fts(conn)
    write_stats(conn)

    conn.close()
    print(f"\nbrain.db → {DB}")

if __name__ == "__main__":
    main()
