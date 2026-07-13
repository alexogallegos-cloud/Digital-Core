#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-sp-specs.py — Grounding Pass del Gemelo Cognitivo
========================================================
Regresa al código fuente línea por línea con el conocimiento acumulado y:
  1. Verifica claims del análisis previo (journeys, vocab, reglas) contra el código real
  2. Genera KB detallada en MD para cada SP analizado (con citas de línea)
  3. Clasifica cada elemento por nivel de evidencia:
       CÓDIGO     — aparece explícitamente en el código fuente (evidencia dura)
       CONVENCIÓN — vocab confirmado (término estándar, aunque no en este SP)
       INFERIDO   — deducido del nombre del SP (sin confirmación en el cuerpo)
       SINTÉTICO  — sin grounding en ninguna fuente (marcado como riesgo)

Output:
  knowledge-base/{DOMAIN}/sp-specs-{db}.md   — spec de todos los SPs del dominio
  sp-validation-{db}.json                     — datos crudos (para futuro reporte HTML)

Uso:
  PYTHONIOENCODING=utf-8 python build-sp-specs.py d09
  PYTHONIOENCODING=utf-8 python build-sp-specs.py d09 d03 d06   # múltiples dominios

Etapa DISCOVER · Gemelo Cognitivo · Grounding Pass v1.0
"""

import json, re, sys, os
from pathlib import Path
from collections import defaultdict

# ── paths ──────────────────────────────────────────────────────────────────
BASE = Path("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
            "03 - Software & Platform Engineering/High Velocity Modernization/"
            "Application Modernization/BanCoppel/BCOPCore/")
SRC  = BASE / "source/BCOPCore/informix"
KB   = BASE / "knowledge-base"

sys.path.insert(0, str(BASE))
from sp_vocab import CAT, segment, compose

# ── dominios canónicos ──────────────────────────────────────────────────────
DOMS = {
    "d01": dict(db="bdicnweb",      name="Canal Digital Web",   folder="D01-bdicnweb"),
    "d02": dict(db="bdinteg",       name="Integración y Auth",  folder="D02-bdinteg"),
    "d03": dict(db="bdicred",       name="Créditos",            folder="D03-bdicred"),
    "d04": dict(db="bdicheq",       name="Cheques / Cuentas",   folder="D04-bdicheq"),
    "d05": dict(db="bdisac",        name="Saldos y Cuentas",    folder="D05-bdisac"),
    "d06": dict(db="bdisolic",      name="Solicitudes",         folder="D06-bdisolic"),
    "d07": dict(db="bdiaclaracion", name="Aclaraciones",        folder="D07-bdiaclaracion"),
    "d08": dict(db="bdispei",       name="SPEI",                folder="D08-bdispei"),
    "d09": dict(db="bdimnsj",       name="Mensajería",          folder="D09-bdimnsj"),
    "d10": dict(db="bdisuc",        name="Sucursales",          folder="D10-bdisuc"),
    "d11": dict(db="bdicobranza",   name="Cobranza",            folder="D11-bdicobranza"),
    "d12": dict(db="bdicont",       name="Contabilidad",        folder="D12-bdicont"),
}

# ── palabras reservadas SQL — no son tablas ──────────────────────────────────
SQL_KW = {
    'SELECT','WHERE','AND','OR','NOT','SET','GROUP','ORDER','BY','HAVING',
    'JOIN','LEFT','RIGHT','INNER','OUTER','ON','AS','DISTINCT','LIMIT',
    'CASE','WHEN','THEN','ELSE','END','NULL','IS','IN','EXISTS','BETWEEN',
    'LIKE','ALL','ANY','SOME','UNION','EXCEPT','INTERSECT','VALUES',
    'TABLE','VIEW','INDEX','PROCEDURE','FUNCTION','TRIGGER','CURSOR',
    'DEFINE','RETURN','RETURNING','FOREACH','WHILE','FOR','IF','ELIF',
    'BEGIN','END','WITH','CURRENT','TODAY','YEAR','MONTH','DAY',
    'DATE','TIME','DATETIME','INTERVAL','FIRST','LAST','SKIP',
    'INTO','FROM','OF','TO','AT','LET','CALL',
}

# ── carga datos del callgraph ────────────────────────────────────────────────
cg       = json.load(open(BASE / "callgraph-data.json", encoding="utf-8"))
CG_NODES = {n["id"]: n for n in cg["graph"]["nodes"]}
CG_OUT   = defaultdict(list)
CG_IN    = defaultdict(list)
for e in cg["graph"]["edges"]:
    CG_OUT[e["from"]].append(e["to"])
    CG_IN[e["to"]].append(e["from"])

# ── carga journeys data ──────────────────────────────────────────────────────
JD = json.load(open(BASE / "journeys-data.json", encoding="utf-8"))


# ══════════════════════════════════════════════════════════════════════════════
# PARSERS DE CÓDIGO SPL
# ══════════════════════════════════════════════════════════════════════════════

def read_first_procedure(filepath):
    """
    Lee un archivo SQL y extrae SOLO el primer CREATE PROCEDURE.
    Convención documentada: el SP objetivo es SIEMPRE el primero;
    los siguientes son dependencias concatenadas.
    Devuelve dict o None si no hay CREATE PROCEDURE.
    """
    with open(filepath, encoding="utf-8", errors="replace") as f:
        content = f.read()

    cp_re = re.compile(
        r'CREATE\s+PROCEDURE\s+(?:"informix"\.)?\s*(\w+)\s*\(',
        re.IGNORECASE | re.MULTILINE
    )
    matches = list(cp_re.finditer(content))
    if not matches:
        return None

    first  = matches[0]
    sp_name = first.group(1)
    start_char = first.start()
    start_line = content[:start_char].count('\n') + 1   # 1-indexed

    end_char = matches[1].start() if len(matches) > 1 else len(content)
    sp_text  = content[start_char:end_char]
    sp_lines = sp_text.split('\n')

    return {
        "name":       sp_name,
        "text":       sp_text,
        "lines":      sp_lines,
        "start_line": start_line,
        "total_lines": len(sp_lines),
        "has_deps":   len(matches) > 1,
        "dep_count":  max(0, len(matches) - 1),
    }


def _split_params_text(params_text):
    """
    Divide el texto de parámetros en tokens individuales respetando
    paréntesis anidados (e.g., MONEY(16,2) no se parte en la coma).
    """
    parts, depth, current = [], 0, []
    for ch in params_text:
        if ch == '(':
            depth += 1
            current.append(ch)
        elif ch == ')':
            depth -= 1
            current.append(ch)
        elif ch == ',' and depth == 0:
            parts.append(''.join(current).strip())
            current = []
        else:
            current.append(ch)
    if current:
        parts.append(''.join(current).strip())
    return parts


def parse_params(sp_text):
    """
    Extrae parámetros de la firma CREATE PROCEDURE.
    Maneja tipos complejos: MONEY(16,2), DATETIME YEAR TO FRACTION(3), etc.
    Devuelve lista de {name, type, raw}.
    """
    cp_match = re.search(r'CREATE\s+PROCEDURE[^(]+\(', sp_text, re.IGNORECASE)
    if not cp_match:
        return []

    # Encuentra el paréntesis de cierre de la firma (ignora anidados)
    start = cp_match.end()
    depth, pos = 1, start
    while pos < len(sp_text) and depth > 0:
        c = sp_text[pos]
        if c == '(':
            depth += 1
        elif c == ')':
            depth -= 1
        pos += 1

    params_text = sp_text[start:pos - 1]
    params = []

    for part in _split_params_text(params_text):
        # Eliminar comentarios inline
        if '--' in part:
            part = part[:part.index('--')]
        part = part.strip()
        if not part:
            continue
        # Patrón: nombre_param TIPO_INFORMIX [opciones]
        m = re.match(r'(\w+)\s+(.+)', part, re.DOTALL)
        if m:
            raw_type = m.group(2).strip()
            params.append({
                "name": m.group(1),
                "type": raw_type,
                "raw":  part,
            })
    return params


def parse_returning(sp_text):
    """Extrae la cláusula RETURNING."""
    m = re.search(r'RETURNING\s+(.+?)(?:;|\n)', sp_text, re.IGNORECASE)
    return m.group(1).strip() if m else None


def parse_defines(sp_text, base_line=0):
    """
    Extrae declaraciones DEFINE.
    Devuelve lista de {name, type, line}.
    """
    defines = []
    for i, line in enumerate(sp_text.split('\n')):
        m = re.match(r'\s*DEFINE\s+(\w+)\s+(.+?)\s*;?\s*(?:--.*)?$', line, re.IGNORECASE)
        if m:
            defines.append({
                "name": m.group(1),
                "type": m.group(2).strip(),
                "line": base_line + i,
            })
    return defines


def parse_tables(sp_text, local_db, base_line=0):
    """
    Extrae tablas/vistas accedidas con su operación y si son cross-DB.
    Maneja referencias cross-DB en formato Informix:
      db:tabla
      db:"informix".tabla
      "informix".tabla
    Devuelve lista de {table, db, cross_db, operation, line}.
    """
    tables = []
    lines  = sp_text.split('\n')

    # Fragmento de regex para referencia de tabla Informix:
    #   (?:(\w+):)?           — db prefix  (group 1)
    #   (?:"informix"\.)?     — schema Informix (ignorado)
    #   (\w+)                 — tabla (group 2)
    _REF = r'(?:(\w+):)?(?:"informix"\.)?(\w+)'

    # patrones: (regex, operacion)
    patterns = [
        (rf'\bFROM\s+{_REF}(?:\s|,|$|\n|;)',   'SELECT'),
        (rf'\bINSERT\s+INTO\s+{_REF}',          'INSERT'),
        (rf'\bUPDATE\s+{_REF}\s',               'UPDATE'),
        (rf'\bDELETE\s+FROM\s+{_REF}',          'DELETE'),
        (rf'\bINTO\s+{_REF}\s+VALUES',          'INSERT'),
    ]

    seen = set()
    for i, raw_line in enumerate(lines):
        line_strip = raw_line.strip()
        if line_strip.startswith('--'):
            continue
        for pat, op in patterns:
            for m in re.finditer(pat, raw_line, re.IGNORECASE):
                db    = (m.group(1) or local_db).lower()
                table = m.group(2).upper()
                if table in SQL_KW or len(table) <= 1:
                    continue
                # Ignora aliases cortos (a, b, c …)
                if re.match(r'^[A-Z]$', table):
                    continue
                key = (table.lower(), db, op)
                if key not in seen:
                    seen.add(key)
                    tables.append({
                        "table":    table.lower(),
                        "db":       db,
                        "cross_db": db != local_db,
                        "operation": op,
                        "line":     base_line + i,
                    })
    return tables


def parse_calls(sp_text, local_db, base_line=0):
    """
    Extrae llamadas EXECUTE PROCEDURE / CALL.
    Devuelve lista de {sp, db, cross_db, line}.
    """
    calls = []
    lines = sp_text.split('\n')
    seen  = set()

    patterns = [
        r'EXECUTE\s+PROCEDURE\s+(?:(\w+):)?(?:"informix"\.)?(\w+)',
        r'\bCALL\s+(?:(\w+):)?(?:"informix"\.)?(\w+)',
    ]

    for i, raw_line in enumerate(lines):
        if raw_line.strip().startswith('--'):
            continue
        for pat in patterns:
            for m in re.finditer(pat, raw_line, re.IGNORECASE):
                db = (m.group(1) or local_db).lower()
                sp = m.group(2).lower()
                if sp.upper() in SQL_KW or len(sp) <= 1:
                    continue
                key = (sp, db)
                if key not in seen:
                    seen.add(key)
                    calls.append({
                        "sp":       sp,
                        "db":       db,
                        "cross_db": db != local_db,
                        "line":     base_line + i,
                    })
    return calls


def parse_authors(sp_text):
    """
    Extrae metadatos del bloque de comentarios de cabecera.
    Limpia artefactos de encoding (ÃÂ…).
    Devuelve lista de {kind, value, line}.
    """
    authors = []
    patterns_map = [
        (r'--\s*Realiz[oa][^:]*:\s*(.+)',    'AUTOR'),
        (r'--\s*Por\s*:\s*(.+)',              'AUTOR'),
        (r'--\s*Fecha\s*[^:]*:\s*(.+)',       'FECHA'),
        (r'--\s*Modific[^:]*:\s*(.+)',        'MODIFICACION'),
        (r'--\s*Proyecto\s*:\s*(.+)',         'PROYECTO'),
        (r'--\s*Actividad\s*:\s*(.+)',        'ACTIVIDAD'),
        (r'--\s*Descripci[^:]*:\s*(.+)',      'DESCRIPCION'),
    ]

    # Solo buscar en los primeros 60 renglones (cabecera)
    for i, line in enumerate(sp_text.split('\n')[:60]):
        for pat, kind in patterns_map:
            m = re.search(pat, line, re.IGNORECASE)
            if m:
                raw = m.group(1).strip()
                # Limpia artefactos de codificación doble (UTF-8 mal leído)
                clean = re.sub(r'[ÃÂ][^\s]{0,3}', '', raw).strip()
                clean = re.sub(r'\s{2,}', ' ', clean)
                if clean:
                    authors.append({"kind": kind, "value": clean, "line": i + 1})
    return authors


def parse_rules(sp_text, base_line=0):
    """
    Extrae reglas de negocio:
      - Fórmulas: LET con operadores aritméticos
      - Validaciones: IF con RETURN de código de error / RAISE EXCEPTION
      - Códigos de retorno: LET cCodRet = 'NNNNN'
    Devuelve lista de {type, code, line, risk_equivalence}.
    """
    rules  = []
    lines  = sp_text.split('\n')

    for i, raw in enumerate(lines):
        stripped = raw.strip()
        if stripped.startswith('--'):
            continue

        # Fórmulas aritméticas
        if re.match(r'\s*LET\s+\w+\s*=\s*.+[\+\-\*/]', raw, re.IGNORECASE):
            # Excluir concatenaciones de strings y asignaciones triviales
            if not re.search(r"LET\s+\w+\s*=\s*'", raw):
                risk = bool(re.search(
                    r'(MONEY|DECIMAL|IMPORTE|MONTO|INTERES|TASA|TRUNC|ROUND|MOD)',
                    raw, re.IGNORECASE))
                rules.append({
                    "type": "FÓRMULA",
                    "code": stripped[:120],
                    "line": base_line + i,
                    "risk": risk,
                })

        # RAISE EXCEPTION
        elif re.match(r'\s*RAISE\s+EXCEPTION', raw, re.IGNORECASE):
            rules.append({
                "type": "EXCEPCIÓN",
                "code": stripped[:120],
                "line": base_line + i,
                "risk": False,
            })

        # Código de retorno de error (LET cCodRet = '00NNN')
        elif re.match(r"\s*LET\s+\w*[Cc]od[Rr]et\s*=\s*'[0-9]{5}'", raw, re.IGNORECASE):
            rules.append({
                "type": "CÓDIGO_RETORNO",
                "code": stripped[:120],
                "line": base_line + i,
                "risk": False,
            })

        # IF que retorna directamente (validaciones de entrada)
        elif re.match(r'\s*IF\s+.*\bIS\s+NULL\b|\bIS\s+NULL\b', raw, re.IGNORECASE):
            rules.append({
                "type": "VALIDACIÓN_NULL",
                "code": stripped[:120],
                "line": base_line + i,
                "risk": False,
            })

    return rules


# ══════════════════════════════════════════════════════════════════════════════
# VERIFICACIÓN DE CLAIMS
# ══════════════════════════════════════════════════════════════════════════════

def classify_vocab(sp_text, sp_name, params, defines, tables, calls):
    """
    Para cada token del vocabulario que aparece en el nombre del SP,
    verifica si tiene evidencia ADICIONAL en el cuerpo del código.

    Evidencia:
      CÓDIGO     — aparece como param, variable, tabla, llamada o literal en el cuerpo
      CONVENCIÓN — el token es 'conf' en el vocab pero no aparece en el cuerpo
      INFERIDO   — el token es 'inf' en el vocab y no aparece en el cuerpo
      SINTÉTICO  — token con estado 'gap' sin evidencia alguna
    """
    tokens   = segment(sp_name)
    sp_lower = sp_text.lower()
    results  = []

    # Construir set de identificadores del cuerpo
    id_set = set()
    for p in params:
        id_set.add(p['name'].lower())
        # Descomponer el nombre del param en tokens
        for t in re.split(r'[_\s]', p['name'].lower()):
            id_set.add(t)
    for d in defines:
        id_set.add(d['name'].lower())
        for t in re.split(r'[_\s]', d['name'].lower()):
            id_set.add(t)
    for tbl in tables:
        id_set.add(tbl['table'].lower())
        for t in re.split(r'[_\s]', tbl['table'].lower()):
            id_set.add(t)
    for c in calls:
        id_set.add(c['sp'].lower())

    for token in tokens:
        if token == '?_' or not token:
            continue
        cat_info = CAT.get(token)
        if not cat_info:
            results.append({
                "token":   token,
                "meaning": "(desconocido — no en vocab)",
                "cat":     "DESCONOCIDO",
                "estado":  "gap",
                "evidence": "SINTÉTICO",
                "found_in": [],
            })
            continue

        cat, meaning, estado = cat_info

        # Buscar evidencia en el cuerpo
        found_in = ["nombre_sp"]  # siempre aparece en el nombre
        # En identificadores
        if token in id_set:
            found_in.append("identificador_en_cuerpo")
        # En texto libre del cuerpo (params, tablas, columnas dentro de SQLs)
        if token != 'sp' and re.search(r'\b' + re.escape(token) + r'\b', sp_lower):
            found_in.append("texto_cuerpo")

        non_name = [f for f in found_in if f != "nombre_sp"]

        if non_name:
            evidence = "CÓDIGO"
        elif estado == "conf":
            evidence = "CONVENCIÓN"
        elif estado == "inf":
            evidence = "INFERIDO"
        else:
            evidence = "SINTÉTICO"

        results.append({
            "token":    token,
            "meaning":  meaning,
            "cat":      cat,
            "estado":   estado,
            "evidence": evidence,
            "found_in": found_in,
        })

    return results


def verify_biz(biz_phrase, biz_estado, sp_text, params, tables, calls, rules):
    """
    Intenta verificar el propósito inferido contra el código real.
    Devuelve (veredicto, justificación).

    Veredictos:
      VERIFICADO     — el código confirma el propósito inferido
      PARCIAL        — hay evidencia parcial pero no completa
      INCORRECTO     — el código contradice el propósito
      NO_VERIFICABLE — no hay suficiente evidencia para validar
    """
    if not biz_phrase:
        return "NO_VERIFICABLE", "No se pudo inferir un objetivo de negocio"

    sp_upper = sp_text.upper()
    evidence = []

    # Mapa: palabras clave del propósito → operaciones DML esperadas
    action_map = {
        "registra":    ["INSERT"],
        "inserta":     ["INSERT"],
        "guarda":      ["INSERT", "UPDATE"],
        "consulta":    ["SELECT", "FROM"],
        "recupera":    ["SELECT", "FROM"],
        "obtiene":     ["SELECT", "FROM"],
        "actualiza":   ["UPDATE"],
        "modifica":    ["UPDATE"],
        "elimina":     ["DELETE"],
        "depura":      ["DELETE"],
        "valida":      ["IF", "RETURN"],
        "confirma":    ["SELECT", "UPDATE"],
        "genera":      ["INSERT", "SELECT"],
        "notifica":    ["INSERT", "EXECUTE"],
        "suscriptores":["SELECT", "UPDATE", "INSERT"],
        "monitoreo":   ["SELECT"],
        "envía":       ["INSERT", "EXECUTE"],
        "envio":       ["INSERT", "EXECUTE"],
        "mover":       ["INSERT", "DELETE", "UPDATE"],
    }

    biz_lower = biz_phrase.lower()

    for keyword, dml_ops in action_map.items():
        if keyword in biz_lower:
            for op in dml_ops:
                if op in sp_upper:
                    evidence.append(f"`{keyword}` → `{op}` encontrado en el cuerpo")

    # Si hay calls, puede ser que el SP delega
    if calls and not evidence:
        evidence.append(f"SP delega a {len(calls)} llamada(s): " +
                        ", ".join(f"`{c['sp']}`" for c in calls[:3]))

    # Si hay tablas accedidas, es evidencia genérica
    if tables and not evidence:
        ops_found = set(t['operation'] for t in tables)
        evidence.append(f"Accede a {len(tables)} tabla(s) con operaciones: {', '.join(ops_found)}")

    if not evidence:
        if biz_estado == "conf":
            return "PARCIAL", "Tokens confirmados en el vocab pero DML no correlaciona con el propósito"
        else:
            return "NO_VERIFICABLE", "Propósito inferido; sin evidencia DML para verificar"

    # Si solo hay tablas genéricas sin correlación directa con el verbo
    if all("tabla" in e or "delega" in e for e in evidence):
        return "PARCIAL", " · ".join(evidence)

    return "VERIFICADO", " · ".join(evidence)


def get_cg_info(sp_name, db):
    """Info del callgraph para este SP."""
    nid = f"{db}:{sp_name}"
    if nid in CG_NODES:
        n = CG_NODES[nid]
        callers = [c.split(':')[-1] for c in CG_IN.get(nid, [])][:5]
        callees = [c.split(':')[-1] for c in CG_OUT.get(nid, [])][:5]
        return {
            "in_graph": True,
            "fan_in":   n.get("fan_in", 0),
            "fan_out":  n.get("fan_out", 0),
            "loc":      n.get("loc", 0),
            "callers":  callers,
            "callees":  callees,
        }
    return {"in_graph": False, "fan_in": 0, "fan_out": 0, "loc": 0,
            "callers": [], "callees": []}


# ══════════════════════════════════════════════════════════════════════════════
# GENERADOR DE MARKDOWN
# ══════════════════════════════════════════════════════════════════════════════

VERDICT_ICON = {
    "VERIFICADO":     "✅",
    "PARCIAL":        "⚠️",
    "INCORRECTO":     "❌",
    "NO_VERIFICABLE": "❓",
}
EVIDENCE_ICON = {
    "CÓDIGO":     "✅",
    "CONVENCIÓN": "🔵",
    "INFERIDO":   "🟡",
    "SINTÉTICO":  "🔴",
}


def sp_to_markdown(sp_data, domain_key, dom_meta, cg_info, biz_info, biz_verdict,
                   params, returning, defines, tables, calls, authors, rules, vocab):
    """Genera el bloque MD completo para un SP."""

    name    = sp_data["name"]
    db      = dom_meta["db"]
    dom_name = dom_meta["name"]
    filename = f"{db}_{name}.sql"

    biz       = biz_info.get("biz") or "*(no inferido)*"
    biz_est   = biz_info.get("estado", "gap")
    verdict   = biz_verdict[0]
    just      = biz_verdict[1]
    v_icon    = VERDICT_ICON.get(verdict, "❓")

    code_n  = sum(1 for v in vocab if v["evidence"] == "CÓDIGO")
    conv_n  = sum(1 for v in vocab if v["evidence"] == "CONVENCIÓN")
    inf_n   = sum(1 for v in vocab if v["evidence"] == "INFERIDO")
    sint_n  = sum(1 for v in vocab if v["evidence"] == "SINTÉTICO")
    total_v = len(vocab)

    md = []

    # ── Encabezado ──────────────────────────────────────────────────────────
    md += [
        f"## `{name}`",
        "",
        f"| Campo | Valor |",
        f"|-------|-------|",
        f"| **Dominio** | {domain_key.upper()} · `{db}` · {dom_name} |",
        f"| **Archivo fuente** | `{filename}` |",
        f"| **LOC (1er CREATE)** | {sp_data['total_lines']} |",
    ]

    if cg_info["in_graph"]:
        md.append(
            f"| **Callgraph** | ✅ fan_in={cg_info['fan_in']} / fan_out={cg_info['fan_out']} |"
        )
        if cg_info["callers"]:
            md.append(
                f"| **Principales callers** | {', '.join(f'`{c}`' for c in cg_info['callers'])} |"
            )
    else:
        md.append("| **Callgraph** | ❌ SP aislado (no conectado en el grafo principal) |")

    if sp_data.get("has_deps"):
        md.append(
            f"| **Deps concatenadas** | {sp_data['dep_count']} SPs adicionales en el archivo (NO analizados aquí) |"
        )

    biz_quoted = f'"{biz}"'
    md += [
        f"| **Propósito inferido** | {biz_quoted} `[{biz_est}]` |",
        f"| **Propósito verificado** | {v_icon} {verdict} — {just} |",
        f"| **Evidencia vocab** | CÓDIGO={code_n} · CONVENCIÓN={conv_n} · INFERIDO={inf_n} · SINTÉTICO={sint_n} / {total_v} términos |",
        "",
    ]

    # ── Historia ─────────────────────────────────────────────────────────────
    if authors:
        md += ["### Historia del SP", ""]
        md += ["| Tipo | Valor |", "|------|-------|"]
        for a in authors:
            val = a["value"].replace("|", "\\|")
            md.append(f"| {a['kind']} | {val} |")
        md.append("")

    # ── Firma ────────────────────────────────────────────────────────────────
    md += ["### Firma", "", "```sql", f"CREATE PROCEDURE {name}("]
    for p in params:
        md.append(f"  {p['name']:<28} {p['type']}")
    ret_str = f") RETURNING {returning}" if returning else ")"
    md += [ret_str, "```", ""]

    # ── Parámetros ───────────────────────────────────────────────────────────
    if params:
        md += ["### Parámetros", "",
               "| Nombre | Tipo | Vocab encontrado | Evidencia |",
               "|--------|------|-----------------|-----------|"]
        for p in params:
            p_low = p["name"].lower()
            pvocab = [v for v in vocab
                      if any(p_low in f or v["token"] in p_low for f in v["found_in"]
                             if "param" in f or "identif" in f)
                      or v["token"] in p_low]
            pvocab = pvocab[:2]  # máx 2 por fila
            vocab_str = " · ".join(f"`{v['token']}`={v['meaning']}" for v in pvocab) or "—"
            ev_str    = " / ".join(set(
                EVIDENCE_ICON.get(v["evidence"], "") + " " + v["evidence"]
                for v in pvocab)) or "—"
            md.append(f"| `{p['name']}` | `{p['type']}` | {vocab_str} | {ev_str} |")
        md.append("")

    # ── Variables ────────────────────────────────────────────────────────────
    if defines:
        md += ["### Variables (DEFINE)", "",
               "| Variable | Tipo | Línea |",
               "|----------|------|-------|"]
        for d in defines[:25]:
            md.append(f"| `{d['name']}` | `{d['type']}` | L{d['line']} |")
        if len(defines) > 25:
            md.append(f"| *…{len(defines) - 25} más…* | | |")
        md.append("")

    # ── Tablas ───────────────────────────────────────────────────────────────
    if tables:
        md += ["### Tablas accedidas", "",
               "| Tabla | Base de datos | Cross-DB | Operación | Línea |",
               "|-------|--------------|----------|-----------|-------|"]
        for t in tables:
            cross = "⚠️ sí" if t["cross_db"] else "no"
            md.append(
                f"| `{t['table']}` | `{t['db']}` | {cross} | {t['operation']} | L{t['line']} |"
            )
        md.append("")

    # ── Llamadas ─────────────────────────────────────────────────────────────
    if calls:
        md += ["### Llamadas (EXECUTE PROCEDURE / CALL)", "",
               "| SP llamado | Base | Cross-DB | Línea |",
               "|------------|------|----------|-------|"]
        for c in calls:
            cross = "⚠️ sí" if c["cross_db"] else "no"
            md.append(f"| `{c['sp']}` | `{c['db']}` | {cross} | L{c['line']} |")
        md.append("")

    # ── Reglas de negocio ────────────────────────────────────────────────────
    if rules:
        md += ["### Reglas extraídas del código", "",
               "| Línea | Tipo | Código | Riesgo equivalencia |",
               "|-------|------|--------|---------------------|"]
        for r in rules[:30]:
            risk_s = "🔴 MONEY/aritmética financiera" if r.get("risk") else ""
            code_s = r["code"].replace("|", "\\|")[:100]
            md.append(f"| L{r['line']} | {r['type']} | `{code_s}` | {risk_s} |")
        if len(rules) > 30:
            md.append(f"| | *…{len(rules) - 30} más…* | | |")
        md.append("")

    # ── Vocabulario verificado ────────────────────────────────────────────────
    if vocab:
        md += ["### Vocabulario verificado contra el código", "",
               "| Token | Categoría | Significado | Evidencia | Encontrado en |",
               "|-------|-----------|-------------|-----------|---------------|"]
        for v in vocab:
            icon    = EVIDENCE_ICON.get(v["evidence"], "")
            found_s = ", ".join(v["found_in"][:3])
            mean_s  = v["meaning"].replace("|", "\\|")[:60]
            md.append(
                f"| `{v['token']}` | {v['cat']} | {mean_s} | {icon} {v['evidence']} | {found_s} |"
            )
        md.append("")

        # Alertas de elementos sintéticos
        sinteticos = [v for v in vocab if v["evidence"] == "SINTÉTICO"]
        if sinteticos:
            md += [
                "> ⚠️ **Elementos sin grounding (SINTÉTICO):**",
                f"> Los tokens `{'`, `'.join(v['token'] for v in sinteticos)}` "
                "aparecen en el nombre del SP pero no tienen evidencia en el vocab ni en el cuerpo del código. "
                "Requieren validación SME antes de usarlos como base para decisions de diseño.",
                "",
            ]

    md += ["---", ""]
    return "\n".join(md)


# ══════════════════════════════════════════════════════════════════════════════
# HEADER MD DEL DOMINIO
# ══════════════════════════════════════════════════════════════════════════════

def domain_header(domain_key, dom_meta, stats):
    """Genera el encabezado del documento MD del dominio."""
    db  = dom_meta["db"]
    name = dom_meta["name"]
    tot  = stats["total"]
    in_g = stats["in_graph"]
    isol = stats["isolated"]
    verif = stats["verified"]
    parc  = stats["partial"]
    nover = stats["not_verifiable"]
    sint  = stats["synthetic_flags"]

    return f"""# SP Specs — {domain_key.upper()} · `{db}` · {name}

> Generado por `build-sp-specs.py` · Grounding Pass v1.0
> Objetivo: verificar el conocimiento del Gemelo Cognitivo contra el código fuente real
> **Convención:** solo se analiza el PRIMER `CREATE PROCEDURE` de cada archivo
> (los siguientes son dependencias concatenadas — ver memoria del proyecto)

## Resumen de validación del dominio

| Métrica | Valor |
|---------|-------|
| SPs analizados | **{tot}** |
| Presentes en callgraph | {in_g} |
| SPs aislados (⚠️ no estaban en el análisis previo) | {isol} |
| Propósito **VERIFICADO** | {verif} |
| Propósito **PARCIAL** | {parc} |
| Propósito **NO_VERIFICABLE** | {nover} |
| SPs con tokens **SINTÉTICOS** detectados | {sint} |

> Los **{isol} SPs aislados** no aparecen en el callgraph y por tanto
> **no fueron incluidos en el análisis de journeys, reglas ni vocabulario previo**.
> Este grounding pass los analiza por primera vez directamente desde el código.

---

"""


# ══════════════════════════════════════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════════════════════════════════════

def process_domain(domain_key):
    if domain_key not in DOMS:
        print(f"[ERROR] Dominio '{domain_key}' no existe. Opciones: {', '.join(DOMS.keys())}")
        return

    dom  = DOMS[domain_key]
    db   = dom["db"]
    folder = dom["folder"]

    print(f"\n{'='*65}")
    print(f"  GROUNDING PASS — {domain_key.upper()} · {db} · {dom['name']}")
    print(f"{'='*65}")

    sql_files = sorted(SRC.glob(f"{db}_*.sql"))
    print(f"  Archivos fuente encontrados: {len(sql_files)}")

    all_md   = []
    val_data = []

    for sql_file in sql_files:
        fname = sql_file.name
        sp_data = read_first_procedure(sql_file)
        if not sp_data:
            print(f"  [SKIP] {fname} — sin CREATE PROCEDURE")
            continue

        name = sp_data["name"]
        print(f"  Parsing {name:<50s} ({sp_data['total_lines']:4d} líneas)", end="")

        sp_text    = sp_data["text"]
        base_line  = sp_data["start_line"]

        params    = parse_params(sp_text)
        returning = parse_returning(sp_text)
        defines   = parse_defines(sp_text, base_line)
        tables    = parse_tables(sp_text, db, base_line)
        calls     = parse_calls(sp_text, db, base_line)
        authors   = parse_authors(sp_text)
        rules     = parse_rules(sp_text, base_line)

        cg_info   = get_cg_info(name, db)
        biz_phrase, biz_flag, biz_estado = compose(name)
        biz_info  = {"biz": biz_phrase, "flag": biz_flag, "estado": biz_estado}
        vocab     = classify_vocab(sp_text, name, params, defines, tables, calls)
        biz_verd  = verify_biz(biz_phrase, biz_estado, sp_text, params, tables, calls, rules)

        sint_flags = [v for v in vocab if v["evidence"] == "SINTÉTICO"]
        verdict    = biz_verd[0]

        verdict_short = {"VERIFICADO":"✅","PARCIAL":"⚠️","NO_VERIFICABLE":"❓","INCORRECTO":"❌"}.get(verdict,"?")
        graph_s = f"fan_in={cg_info['fan_in']}" if cg_info["in_graph"] else "AISLADO"
        print(f"  {verdict_short} {verdict:<15s}  {graph_s}")

        block = sp_to_markdown(
            sp_data, domain_key, dom, cg_info, biz_info, biz_verd,
            params, returning, defines, tables, calls, authors, rules, vocab
        )
        all_md.append(block)

        val_data.append({
            "sp":           name,
            "file":         fname,
            "domain":       domain_key,
            "db":           db,
            "in_graph":     cg_info["in_graph"],
            "fan_in":       cg_info["fan_in"],
            "fan_out":      cg_info["fan_out"],
            "loc_parsed":   sp_data["total_lines"],
            "has_deps":     sp_data["has_deps"],
            "dep_count":    sp_data["dep_count"],
            "biz":          biz_phrase,
            "biz_estado":   biz_estado,
            "verdict":      verdict,
            "justification": biz_verd[1],
            "params_n":     len(params),
            "defines_n":    len(defines),
            "tables_n":     len(tables),
            "calls_n":      len(calls),
            "rules_n":      len(rules),
            "authors_n":    len(authors),
            "vocab_codigo":    sum(1 for v in vocab if v["evidence"] == "CÓDIGO"),
            "vocab_convencion": sum(1 for v in vocab if v["evidence"] == "CONVENCIÓN"),
            "vocab_inferido":  sum(1 for v in vocab if v["evidence"] == "INFERIDO"),
            "vocab_sintetico": len(sint_flags),
            "sinteticos":   [v["token"] for v in sint_flags],
        })

    # ── Estadísticas ─────────────────────────────────────────────────────────
    stats = {
        "total":          len(val_data),
        "in_graph":       sum(1 for v in val_data if v["in_graph"]),
        "isolated":       sum(1 for v in val_data if not v["in_graph"]),
        "verified":       sum(1 for v in val_data if v["verdict"] == "VERIFICADO"),
        "partial":        sum(1 for v in val_data if v["verdict"] == "PARCIAL"),
        "not_verifiable": sum(1 for v in val_data if v["verdict"] == "NO_VERIFICABLE"),
        "incorrect":      sum(1 for v in val_data if v["verdict"] == "INCORRECTO"),
        "synthetic_flags": sum(1 for v in val_data if v["vocab_sintetico"] > 0),
    }

    # ── Escritura del MD ─────────────────────────────────────────────────────
    kb_dir = KB / folder
    kb_dir.mkdir(exist_ok=True)

    out_md = kb_dir / f"sp-specs-{db}.md"
    with open(out_md, "w", encoding="utf-8") as f:
        f.write(domain_header(domain_key, dom, stats))
        f.write("\n".join(all_md))

    # ── Escritura del JSON de validación ─────────────────────────────────────
    out_json = BASE / f"sp-validation-{db}.json"
    with open(out_json, "w", encoding="utf-8") as f:
        json.dump(val_data, f, ensure_ascii=False, indent=2)

    # ── Resumen en consola ───────────────────────────────────────────────────
    print(f"\n  {'─'*55}")
    print(f"  RESULTADO  {domain_key.upper()} · {db}")
    print(f"  {'─'*55}")
    print(f"  SPs analizados:       {stats['total']}")
    print(f"  En callgraph:         {stats['in_graph']}")
    print(f"  Aislados (NUEVOS):    {stats['isolated']}")
    print(f"  ✅ VERIFICADO:         {stats['verified']}")
    print(f"  ⚠️  PARCIAL:            {stats['partial']}")
    print(f"  ❓ NO_VERIFICABLE:     {stats['not_verifiable']}")
    print(f"  🔴 Con SINTÉTICOS:     {stats['synthetic_flags']}")
    print(f"  {'─'*55}")
    print(f"  📄 MD output:          {out_md}")
    print(f"  🗃️  JSON output:        {out_json}")

    return stats


def main():
    domains = sys.argv[1:] if len(sys.argv) > 1 else ["d09"]
    domains = [d.lower() for d in domains]

    for domain_key in domains:
        process_domain(domain_key)

    print(f"\n  Grounding pass completado para: {', '.join(domains)}\n")


if __name__ == "__main__":
    main()