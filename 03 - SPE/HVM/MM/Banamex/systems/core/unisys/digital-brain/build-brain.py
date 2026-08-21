"""
build-brain.py — GemCog Brain v2 · Banamex S500 + S151
Construye brain.db desde los MDs canónicos del Gemelo Cognitivo.

Tablas:
  capacidades       — 22 BC-XX (taxonomía)
  programs          — 75 S151 + 77 S500 (program-registry)
  tasks             — T-XX-NNN por capacidad (cap-*.md)
  rules             — 1,550+ reglas (rules-catalog/*.md)
                      clase: NEGOCIO · CONTABLE · CONTROL_FLUJO · VALIDACION
                      sub_tipo: agrupación desde tipo_tecnico
  risks             — 181 riesgos (migration-risk-register.md)
  rule_vocab        — referencias vocab por regla
  vocab_terms       — términos únicos referenciados en reglas
  cross_dependencies — sistemas externos: reguladores + integración
  stats             — métricas de cobertura

FTS5: rules_fts · risks_fts · vocab_fts · cross_deps_fts

Uso:
  cd digital-brain/
  python build-brain.py
"""

import sqlite3, re, glob, os, sys
from pathlib import Path
from collections import defaultdict

BASE   = Path(__file__).parent
GEMCOG = BASE.parent.parent.parent.parent / "GemCog"
DB     = BASE / "brain.db"

# ── BC-ID ↔ slug (fuente: capability-model-taxonomy.md) ──────────────────────
BC_TO_SLUG = {
    "BC-01": "tel", "BC-02": "tar", "BC-03": "hld", "BC-04": "acl",
    "BC-05": "dep", "BC-06": "pay", "BC-07": "sta", "BC-08": "int",
    "BC-09": "adj", "BC-10": "cmp", "BC-11": "rec", "BC-12": "orc",
    "BC-13": "gl",  "BC-14": "sch", "BC-15": "ods", "BC-16": "sec",
    "BC-17": "mq",  "BC-18": "rpt", "BC-19": "cfr", "BC-20": "wfl",
    "BC-21": "cpe", "BC-23": "spei",
}
SLUG_TO_BC = {v: k for k, v in BC_TO_SLUG.items()}

SEV_RANK = {
    "DEFECTO-PROD": 5, "CRÍTICO": 4, "ALTO": 3, "MEDIO": 2, "BAJO": 1,
}

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
    prog_id      TEXT,
    sistema      TEXT,
    bc_id        TEXT,
    bc_slug      TEXT,
    nombre       TEXT,
    bian_ref     TEXT,
    confianza    TEXT,
    rol_funcional TEXT,
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

CREATE TABLE risks (
    risk_id    TEXT PRIMARY KEY,
    cap_slug   TEXT,
    bc_id      TEXT,
    severidad  TEXT,
    sev_rank   INTEGER,
    patron     TEXT,
    tareas     TEXT,
    descripcion TEXT,
    accion     TEXT
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

CREATE VIRTUAL TABLE rules_fts USING fts5(
    rule_id, nombre, descripcion, riesgos
);
CREATE VIRTUAL TABLE risks_fts USING fts5(
    risk_id, descripcion, accion
);
CREATE VIRTUAL TABLE vocab_fts USING fts5(
    term, significado
);
CREATE VIRTUAL TABLE cross_deps_fts USING fts5(
    id, other_system, description
);
"""

# ── Utilidades ────────────────────────────────────────────────────────────────
def clean(s: str) -> str:
    return (s or "").strip().strip("*").strip()

def parse_table_rows(lines: list[str]) -> list[list[str]]:
    """Extrae filas de una tabla Markdown (excluye separador |---|)."""
    rows = []
    for ln in lines:
        if not ln.strip().startswith("|"):
            continue
        if re.match(r'\|\s*[-:]+', ln):
            continue
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        if cells:
            rows.append(cells)
    return rows

def detect_sistema(path: str) -> str:
    name = Path(path).stem.lower()
    if "s500" in name:
        return "S500"
    if "s151" in name:
        return "S151"
    return "AMBOS"

# ── Loader: capacidades ───────────────────────────────────────────────────────
def load_taxonomy(conn: sqlite3.Connection):
    tax_file = GEMCOG / "capability-model-taxonomy.md"
    rows = []
    in_table = False
    for ln in tax_file.read_text(encoding="utf-8").splitlines():
        # tabla del catálogo canónico: | BC-ID | Slug | Nombre ... | BIAN ref | Sistema | Archivo |
        m = re.match(r'\|\s*(BC-\d+)\s*\|\s*(\S*)\s*\|\s*([^|]+?)\s*\|\s*([^|]*?)\s*\|\s*([^|]+?)\s*\|', ln)
        if m:
            bc_id   = m.group(1)
            slug    = m.group(2).strip() or BC_TO_SLUG.get(bc_id, "")
            nombre  = m.group(3).strip()
            bian    = m.group(4).strip()
            sistema = m.group(5).strip()
            rows.append((bc_id, slug.lower(), nombre, bian, sistema))

    # Complementar con datos del mapa de cobertura (dominio + subdominio)
    domain_map: dict[str, tuple] = {}
    for ln in tax_file.read_text(encoding="utf-8").splitlines():
        # Tabla de cobertura: | ID | Dominio | Sub-categoría | Capacidad | S500 | S151 | AMBOS |
        m = re.match(r'\|\s*([0-9T]\.\d(?:\.\d)?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|', ln)
        if m:
            bid, dom, sub, cap = m.group(1), m.group(2).strip(), m.group(3).strip(), m.group(4).strip()
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
def _parse_program_row_s151(ln: str) -> tuple | None:
    """| # | Programa | BC-ID | Capacidad (ES) | bian_ref | Rol funcional | Confianza |"""
    m = re.match(
        r'\|\s*\d+\s*\|\s*([A-Z]\w+)\s*\|\s*(BC-\d+)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(\w+)\s*\|',
        ln
    )
    if m:
        return m.group(1), m.group(2), m.group(3).strip(), m.group(4).strip(), m.group(5).strip(), m.group(6).strip()
    return None

def _parse_program_row_s500(ln: str) -> tuple | None:
    """| # | Programa | LOC | Dominio S500 | BC-ID | Capacidad (ES) | bian_ref | Rol funcional | Confianza | Validado por |"""
    m = re.match(
        r'\|\s*\d+\s*\|\s*([A-Z]\w+)\s*\|\s*[^|]*?\s*\|\s*[^|]*?\s*\|\s*(BC-\d+)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(\w+)\s*\|',
        ln
    )
    if m:
        return m.group(1), m.group(2), m.group(3).strip(), m.group(4).strip(), m.group(5).strip(), m.group(6).strip()
    return None

def load_programs(conn: sqlite3.Connection):
    inserted = 0
    for reg_file in [GEMCOG / "program-registry-s151.md", GEMCOG / "program-registry-s500.md"]:
        sistema = "S151" if "s151" in reg_file.name else "S500"
        parse_row = _parse_program_row_s151 if sistema == "S151" else _parse_program_row_s500
        in_main = False
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
                prog, bc_id, nombre, bian, rol, conf = result
                slug = BC_TO_SLUG.get(bc_id, "")
                conn.execute(
                    "INSERT OR REPLACE INTO programs VALUES (?,?,?,?,?,?,?,?)",
                    (prog, sistema, bc_id, slug, nombre, bian, conf.upper(), rol)
                )
                inserted += 1
    conn.commit()
    print(f"  programs: {inserted} registros")

# ── Loader: tasks (desde cap-*.md) ───────────────────────────────────────────
def load_tasks(conn: sqlite3.Connection):
    inserted = 0
    for cap_file in sorted((GEMCOG / "capacidades").glob("cap-*.md")):
        slug = cap_file.stem.replace("cap-", "")
        bc_id = SLUG_TO_BC.get(slug, "")
        text = cap_file.read_text(encoding="utf-8")
        # Detectar sección "## Inventario de Tareas"
        in_tasks = False
        for ln in text.splitlines():
            if re.match(r'##\s+Inventario de Tareas', ln):
                in_tasks = True
                continue
            if in_tasks and ln.startswith("##"):
                break
            if not in_tasks:
                continue
            # | ID | Tarea | Programa | Componente fuente | Tipo |
            m = re.match(
                r'\|\s*(T-[A-Z]+-\d+)\s*\|\s*([^|]+?)\s*\|\s*([^|]*?)\s*\|\s*([^|]*?)\s*\|\s*([^|]*?)\s*\|',
                ln
            )
            if m:
                task_id, desc, prog = m.group(1), m.group(2).strip(), m.group(3).strip()
                tipo = m.group(5).strip()
                conn.execute(
                    "INSERT OR REPLACE INTO tasks VALUES (?,?,?,?,?,?)",
                    (task_id, bc_id, slug, prog, desc, tipo)
                )
                inserted += 1
    conn.commit()
    print(f"  tasks: {inserted} tareas")

# ── Loader: rules (desde rules-catalog/*.md) ──────────────────────────────────
SKIP_FILES = {"rules-index.md", "schema-canonico-reglas.md", "homologation-inventory.md"}

FIELD_MAP = {
    "identificador": "rule_id",
    "nombre": "nombre",
    "estado ciclo": "estado",
    "bc-id": "bc_id",
    "bian_ref": "bian_ref",
    "tipo regla": "tipo_regla",
    "tipo técnico": "tipo_tecnico",
    "confianza": "confianza",
    "veredicto": "veredicto",
    "regulador": "regulador",
    "programa ejecutor": "programa",
}

# ── Derivación clase / sub_tipo ───────────────────────────────────────────────
def _derive_clase(rule: dict) -> str:
    tipo    = (rule.get("tipo_regla")   or "").lower()
    tecnico = (rule.get("tipo_tecnico") or "").upper()
    bc_id   = rule.get("bc_id", "")
    reg     = rule.get("regulador", "")
    # Contable: capacidad GL o referencia a regulador de reportes financieros
    if bc_id == "BC-13" or any(s in reg for s in ("CNBV", "TESOFE", "IFRS", "NIF")):
        return "CONTABLE"
    # Control de flujo: habilitación o condición pura sin lógica de negocio
    if "habilitac" in tipo:
        return "CONTROL_FLUJO"
    # Validación: restricción con tipo técnico de validación
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

# ── Patrones de dependencias externas ─────────────────────────────────────────
# (regex, system_name, dep_type, direction, criticality)
XDEP_PATTERNS = [
    (r"\bCNBV\b",     "CNBV",     "REGULATORIO", "outbound",      "ALTA"),
    (r"\bBanxico\b",  "Banxico",  "REGULATORIO", "outbound",      "ALTA"),
    (r"\bCONDUSEF\b", "CONDUSEF", "REGULATORIO", "outbound",      "MEDIA"),
    (r"\bIPAB\b",     "IPAB",     "REGULATORIO", "outbound",      "MEDIA"),
    (r"\bSAT\b",      "SAT",      "REGULATORIO", "outbound",      "ALTA"),
    (r"\bTESOFE\b",   "TESOFE",   "REGULATORIO", "outbound",      "ALTA"),
    (r"\bUIF\b",      "UIF",      "REGULATORIO", "outbound",      "ALTA"),
    (r"\bSPEI\b",     "SPEI",     "INTEGRACION", "bidireccional", "ALTA"),
    (r"\bSPID\b",     "SPID",     "INTEGRACION", "bidireccional", "ALTA"),
    (r"\bCECOBAN\b",  "CECOBAN",  "INTEGRACION", "outbound",      "MEDIA"),
    (r"\bDORA\b",     "DORA",     "REGULATORIO", "outbound",      "MEDIA"),
    (r"\bAMIB\b",     "AMIB",     "REGULATORIO", "outbound",      "BAJA"),
]

def _extract_xdep(text: str) -> list[str]:
    """Devuelve lista de system_name encontrados en text."""
    return [sys for pat, sys, *_ in XDEP_PATTERNS if re.search(pat, text, re.IGNORECASE)]

def _extract_vocab_inline(line: str, rule_id: str) -> list[dict]:
    """
    Parsea vocab inline en sus variantes:
      '**Vocabulario en la fórmula:** term1 · term2'   (colon dentro del bold)
      '**Vocabulario en la fórmula:** term1 · term2'   (colon fuera del bold)
    Devuelve vacío si no hay términos en la misma línea (significa que hay tabla separada).
    """
    # Buscar cualquier variante del encabezado y tomar lo que sigue
    m = re.search(r'f[oó]rmula[*:]+\**\s*(.*)', line)
    if not m:
        return []
    raw = m.group(1).strip()
    if not raw:          # línea solo tiene el encabezado, sin términos → tabla aparte
        return []
    terms = [t.strip().strip("`").strip("*").strip(":") for t in re.split(r'[·•,]', raw) if t.strip()]
    return [{"rule_id": rule_id, "term": t, "categoria": "", "alcance": "", "significado": ""}
            for t in terms if t and len(t) > 1 and not t.startswith("-")]


def parse_rules_file(path: Path) -> tuple[list[dict], list[dict]]:
    """
    Devuelve (rules_list, vocab_refs_list).
    Maneja dos formatos:
      - H3 (###) con vocab en tabla  — archivos originales + homologados
      - H2 (##)  con vocab inline    — archivos swarm (contabilidad-a/b, deposits-a/b, etc.)
    """
    sistema = detect_sistema(str(path))
    source  = path.name
    text    = path.read_text(encoding="utf-8")
    lines   = text.splitlines()

    rules      = []
    vocab_refs = []

    # Regex para cabecera de regla: ## o ### RN-S500/S151-NNN
    RULE_HDR = re.compile(r'^#{2,3}\s+(RN-(?:S500|S151)-\d+)')

    i = 0
    while i < len(lines):
        ln = lines[i]
        m = RULE_HDR.match(ln)
        if not m:
            i += 1
            continue

        rule_id_h = m.group(1)
        hdr_level = "##" if ln.startswith("## ") else "###"

        # Recolectar todas las líneas hasta la próxima regla o fin de archivo
        j = i + 1
        while j < len(lines) and not RULE_HDR.match(lines[j]):
            j += 1
        block = lines[i:j]
        i = j

        # Parsear tabla de propiedades (mismo formato en ambos schemas)
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

        # Extraer Descripción
        desc_lines = []
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

        # Extraer Riesgos / Excepciones (bullets)
        risk_lines = []
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

        # Extraer Vocabulario — detectar formato (tabla vs inline)
        in_vocab = False
        vocab_inline_done = False
        for bln in block:
            if re.match(r'\*\*Vocabulario en la f[oó]rmula', bln):
                # Intentar primero formato inline (misma línea)
                inline = _extract_vocab_inline(bln, rule_id)
                if inline:
                    vocab_refs.extend(inline)
                    vocab_inline_done = True
                else:
                    in_vocab = True  # iniciar modo tabla
                continue
            if vocab_inline_done:
                continue
            if in_vocab:
                if re.match(r'\*\*(Estado|---)', bln):
                    break
                # Formato tabla: | Campo COBOL | Término vocab | Categoría | Alcance | Significado |
                cells = [c.strip().strip("`") for c in bln.strip().strip("|").split("|")]
                if len(cells) >= 5 and cells[0] and not cells[0].startswith("-"):
                    term_vocab = cells[1] if cells[1] not in ("—", "") else cells[0]
                    cat        = cells[2] if cells[2] not in ("—", "") else ""
                    alcance    = cells[3] if cells[3] not in ("—", "") else ""
                    sig        = cells[4] if cells[4] not in ("—", "") else ""
                    if term_vocab and term_vocab.lower() not in ("término vocab", "—", "term"):
                        vocab_refs.append({
                            "rule_id": rule_id, "term": term_vocab,
                            "categoria": cat, "alcance": alcance, "significado": sig,
                        })

        bc_id   = props.get("bc_id", "")
        bc_slug = BC_TO_SLUG.get(bc_id, "")

        rule = {
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
    rules_cat = GEMCOG / "rules-catalog"
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

    # Vocab: dedup por (rule_id, term)
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

    # vocab_terms: términos únicos
    term_data: dict[str, dict] = {}
    for v in all_vocab:
        t = v["term"]
        if t not in term_data:
            term_data[t] = {"categoria": v["categoria"], "alcance": v["alcance"],
                            "significado": v["significado"], "count": 0}
        term_data[t]["count"] += 1
    for term, td in term_data.items():
        conn.execute(
            "INSERT OR REPLACE INTO vocab_terms VALUES (?,?,?,?,?)",
            (term, td["categoria"], td["alcance"], td["significado"], td["count"])
        )

    conn.commit()
    print(f"  rules: {len(all_rules)} reglas · vocab_refs: {len(seen)} · vocab_terms: {len(term_data)}")

# ── Loader: risks (desde migration-risk-register.md) ─────────────────────────
def load_risks(conn: sqlite3.Connection):
    rr_file = GEMCOG / "migration-risk-register.md"
    text    = rr_file.read_text(encoding="utf-8")
    inserted = 0

    for ln in text.splitlines():
        # Tabla de riesgos: | MR-CAP-NN | 🔴 DEFECTO-PROD | PATRÓN | T-... | Descripción | Acción |
        m = re.match(
            r'\|\s*(MR-[A-Z]+-\d+)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|',
            ln
        )
        if not m:
            continue
        risk_id = m.group(1)
        sev_raw = m.group(2).strip()
        patron  = m.group(3).strip()
        tareas  = m.group(4).strip()
        desc    = m.group(5).strip()
        accion  = m.group(6).strip()

        # Ignorar fila de encabezado
        if risk_id.upper() in ("ID", "RISK_ID"):
            continue

        # Extraer slug del risk_id: MR-GL-01 → gl
        slug_raw = re.match(r'MR-([A-Z]+)-', risk_id)
        cap_slug = slug_raw.group(1).lower() if slug_raw else ""
        bc_id    = SLUG_TO_BC.get(cap_slug, "")

        # Severidad: extraer texto ignorando emoji
        sev_text = re.sub(r'[🔴🟠🟡🟢]', '', sev_raw).strip()
        sev_rank = SEV_RANK.get(sev_text.upper(), 0)

        conn.execute(
            "INSERT OR REPLACE INTO risks VALUES (?,?,?,?,?,?,?,?,?)",
            (risk_id, cap_slug, bc_id, sev_text, sev_rank, patron, tareas, desc, accion)
        )
        inserted += 1

    conn.commit()
    print(f"  risks: {inserted} riesgos")

# ── Loader: cross_dependencies ───────────────────────────────────────────────
def load_cross_dependencies(conn: sqlite3.Connection):
    """Agrega una fila por sistema externo encontrado en regulador/descripcion de reglas."""
    rows = conn.execute(
        "SELECT rule_id, regulador, descripcion FROM rules"
    ).fetchall()

    # Acumular: system_name → {rule_ids, description}
    systems: dict[str, dict] = {}
    for rule_id, reg, desc in rows:
        text = f"{reg or ''} {desc or ''}"
        for pat, sys_name, dep_type, direction, criticality in XDEP_PATTERNS:
            if re.search(pat, text, re.IGNORECASE):
                if sys_name not in systems:
                    systems[sys_name] = {
                        "dep_type": dep_type, "direction": direction,
                        "criticality": criticality, "rule_ids": [], "desc_sample": "",
                    }
                systems[sys_name]["rule_ids"].append(rule_id)
                if not systems[sys_name]["desc_sample"] and reg and "N/A" not in reg:
                    systems[sys_name]["desc_sample"] = reg.split("—")[0].strip()

    inserted = 0
    for i, (sys_name, data) in enumerate(
        sorted(systems.items(), key=lambda x: -len(x[1]["rule_ids"])), start=1
    ):
        xdep_id  = f"XDEP-{sys_name.upper()}-{i:02d}"
        evidence = ",".join(data["rule_ids"][:10])  # muestra los primeros 10
        conn.execute(
            "INSERT OR REPLACE INTO cross_dependencies VALUES (?,?,?,?,?,?,?,?)",
            (xdep_id, sys_name, data["dep_type"], data["direction"],
             data["criticality"], len(data["rule_ids"]), evidence, data["desc_sample"])
        )
        inserted += 1

    conn.commit()
    print(f"  cross_dependencies: {inserted} sistemas externos")

# ── FTS5 ──────────────────────────────────────────────────────────────────────
def build_fts(conn: sqlite3.Connection):
    conn.execute("""
        INSERT INTO rules_fts(rule_id, nombre, descripcion, riesgos)
        SELECT rule_id, COALESCE(nombre,''), COALESCE(descripcion,''), COALESCE(riesgos,'')
        FROM rules
    """)
    conn.execute("""
        INSERT INTO risks_fts(risk_id, descripcion, accion)
        SELECT risk_id, COALESCE(descripcion,''), COALESCE(accion,'')
        FROM risks
    """)
    conn.execute("""
        INSERT INTO vocab_fts(term, significado)
        SELECT term, COALESCE(significado,'')
        FROM vocab_terms
    """)
    conn.execute("""
        INSERT INTO cross_deps_fts(id, other_system, description)
        SELECT id, other_system, COALESCE(description,'')
        FROM cross_dependencies
    """)
    conn.commit()
    print("  FTS5: rules_fts · risks_fts · vocab_fts · cross_deps_fts poblados")

# ── Stats ─────────────────────────────────────────────────────────────────────
def write_stats(conn: sqlite3.Connection):
    cur = conn.cursor()
    stats = {}
    for table in ("capacidades", "programs", "tasks", "rules", "risks", "rule_vocab", "vocab_terms"):
        n = cur.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        stats[table] = n

    # cross_dependencies
    n = cur.execute("SELECT COUNT(*) FROM cross_dependencies").fetchone()[0]
    stats["cross_dependencies"] = n

    # Distribución de clase
    for clase in ("NEGOCIO", "CONTABLE", "CONTROL_FLUJO", "VALIDACION"):
        n = cur.execute("SELECT COUNT(*) FROM rules WHERE clase=?", (clase,)).fetchone()[0]
        stats[f"rules_clase_{clase.lower()}"] = n

    # Cobertura SBVR
    sbvr_sin = cur.execute(
        "SELECT COUNT(*) FROM rules WHERE tipo_regla IS NULL OR tipo_regla=''"
    ).fetchone()[0]
    stats["rules_sin_sbvr"] = sbvr_sin

    # Reglas con regulador real
    reg_real = cur.execute(
        "SELECT COUNT(*) FROM rules WHERE regulador NOT IN ('N/A','N/A — control de integridad','') "
        "AND regulador IS NOT NULL"
    ).fetchone()[0]
    stats["rules_con_regulador"] = reg_real

    # Riesgos criticos
    for sev, key in [("DEFECTO-PROD", "risks_defecto_prod"), ("CRITICO", "risks_critico"),
                     ("CRITICO", "risks_critico2")]:
        n = cur.execute("SELECT COUNT(*) FROM risks WHERE UPPER(severidad) LIKE ?",
                        (f"%{sev}%",)).fetchone()[0]
        stats[key] = n

    for k, v in stats.items():
        conn.execute("INSERT OR REPLACE INTO stats VALUES (?,?)", (k, str(v)))
    conn.commit()

    sep = "-" * 51
    print(f"\n{sep}")
    print(" GemCog Brain v2")
    print(sep)
    print(f"  capacidades : {stats['capacidades']:>5}")
    print(f"  programs    : {stats['programs']:>5}")
    print(f"  tasks       : {stats['tasks']:>5}")
    print(f"  rules       : {stats['rules']:>5}   ({sbvr_sin} sin tipo_regla)")
    neg = stats.get("rules_clase_negocio", 0)
    con = stats.get("rules_clase_contable", 0)
    flw = stats.get("rules_clase_control_flujo", 0)
    val = stats.get("rules_clase_validacion", 0)
    print(f"    NEGOCIO={neg}  CONTABLE={con}  CONTROL_FLUJO={flw}  VALIDACION={val}")
    print(f"  risks       : {stats['risks']:>5}   ({stats.get('risks_defecto_prod',0)} DEFECTO-PROD)")
    print(f"  rule_vocab  : {stats['rule_vocab']:>5}")
    print(f"  vocab_terms : {stats['vocab_terms']:>5}")
    print(f"  regulatorio : {reg_real} reglas con norma explicita")
    print(f"  cross_deps  : {stats.get('cross_dependencies',0)} sistemas externos")
    print(sep)

# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    if DB.exists():
        DB.unlink()
        print(f"  (eliminado brain.db anterior)")

    conn = sqlite3.connect(DB)
    conn.executescript(SCHEMA)
    conn.execute("PRAGMA journal_mode=WAL")

    print("Cargando GemCog Brain v2...")
    load_taxonomy(conn)
    load_programs(conn)
    load_tasks(conn)
    load_rules(conn)
    load_risks(conn)
    load_cross_dependencies(conn)
    build_fts(conn)
    write_stats(conn)

    conn.close()
    print(f"\nbrain.db -> {DB}")

if __name__ == "__main__":
    main()