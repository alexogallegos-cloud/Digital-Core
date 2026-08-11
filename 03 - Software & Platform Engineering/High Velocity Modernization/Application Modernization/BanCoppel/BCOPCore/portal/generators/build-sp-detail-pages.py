#!/usr/bin/env python3
"""build-sp-detail-pages.py
Generates HTML detail pages and KB markdown files for each SP in journeys-data.json.
Run from BCOPCore/ directory (BASE is set to the script's own directory).
"""

import json
import os
import re
import sqlite3
import sys
from datetime import date

TODAY = date.today().isoformat()
BASE = os.path.normpath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..')) + os.sep

DOMAIN_INFO = {
    'd01': {'db': 'bdicnweb',      'name': 'Canal Digital Web',       'slug': 'D01-bdicnweb',      'num': 'D01'},
    'd02': {'db': 'bdinteg',       'name': 'Integracion Core',        'slug': 'D02-bdinteg',       'num': 'D02'},
    'd03': {'db': 'bdicred',       'name': 'Credito',                 'slug': 'D03-bdicred',       'num': 'D03'},
    'd04': {'db': 'bdicheq',       'name': 'Chequera / Debito',       'slug': 'D04-bdicheq',       'num': 'D04'},
    'd05': {'db': 'bdisac',        'name': 'SAC / Transferencias',    'slug': 'D05-bdisac',        'num': 'D05'},
    'd06': {'db': 'bdisolic',      'name': 'Solicitudes de Credito',  'slug': 'D06-bdisolic',      'num': 'D06'},
    'd07': {'db': 'bdiaclaracion', 'name': 'Aclaraciones',            'slug': 'D07-bdiaclaracion', 'num': 'D07'},
    'd08': {'db': 'bdispei',       'name': 'SPEI / CoDi',             'slug': 'D08-bdispei',       'num': 'D08'},
    'd09': {'db': 'bdimnsj',       'name': 'Mensajeria',              'slug': 'D09-bdimnsj',       'num': 'D09'},
    'd10': {'db': 'bdisuc',        'name': 'Sucursales',              'slug': 'D10-bdisuc',        'num': 'D10'},
    'd11': {'db': 'bdicobranza',   'name': 'Cobranza',                'slug': 'D11-bdicobranza',   'num': 'D11'},
    'd12': {'db': 'bdicont',       'name': 'Contabilidad',            'slug': 'D12-bdicont',       'num': 'D12'},
    'd13': {'db': 'bditef',        'name': 'TEF / Nomina',            'slug': 'D13-bditef',        'num': 'D13'},
    'd14': {'db': 'bdibei',        'name': 'BEI / Banca Empresarial', 'slug': 'D14-bdibei',        'num': 'D14'},
    'd15': {'db': 'bdilide',       'name': 'LIDE / Dispersion',       'slug': 'D15-bdilide',       'num': 'D15'},
    'd16': {'db': 'intercard',     'name': 'Intercard',               'slug': 'D16-intercard',     'num': 'D16'},
}

# Module-level callee info lookup — populated in main() after data load.
# Phase B: 166 journeys+exposed SPs → has_page=True (click links active).
# Phase C: up to 10,664 brain.db SPs → has_page=False (biz annotation only).
# Maps sp_name → {'biz': str, 'rules_n': int, 'has_page': bool}.
CALLEE_INFO = {}

# portal/generators/ is two levels below BCOPCore/
BRAIN_DB_PATH = os.path.normpath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '..', 'digital-brain', 'brain.db'))


# ---------------------------------------------------------------------------
# Phase C: load biz annotations from brain.db
# ---------------------------------------------------------------------------

def load_callee_info_from_brain(brain_db_path: str) -> dict:
    """
    Phase C — query brain.db for all SPs with a biz annotation.
    Returns sp_name → {'biz': str, 'rules_n': int, 'has_page': False}.
    The caller is responsible for overlaying Phase-B journeys entries
    (which set has_page=True and carry curated biz from journeys-data.json).
    """
    result = {}
    if not os.path.exists(brain_db_path):
        print(f"  [Phase C] brain.db not found at {brain_db_path} — skipping")
        return result
    try:
        conn = sqlite3.connect(brain_db_path)
        rows = conn.execute(
            "SELECT name, biz, rules_n FROM sps WHERE biz IS NOT NULL AND biz != ''"
        ).fetchall()
        conn.close()
        for name, biz, rules_n in rows:
            result[name] = {'biz': biz or '', 'rules_n': rules_n or 0, 'has_page': False}
        print(f"  [Phase C] {len(result):,} SP entries loaded from brain.db")
    except Exception as exc:
        print(f"  [Phase C] Warning — could not read brain.db: {exc}")
    return result


# ---------------------------------------------------------------------------
# Data loading
# ---------------------------------------------------------------------------

def load_json(path):
    with open(path, encoding='utf-8') as f:
        return json.load(f)


def load_all_data():
    print("Loading journeys-data.json...")
    journeys = load_json(os.path.join(BASE, 'portal/data/journeys-data.json'))

    print("Loading flow-data.json...")
    flow_raw = load_json(os.path.join(BASE, 'portal/data/flow-data.json'))

    print("Loading business-rules-v2.json...")
    rules_raw = load_json(os.path.join(BASE, 'portal/data/business-rules-v2.json'))

    print("Loading vocabulary-inventory.json...")
    vocab_raw = load_json(os.path.join(BASE, 'knowledge-base/vocabulary-inventory.json'))

    # Load all sp-validation files
    validation = {}  # db -> {sp_name -> entry}
    for fname in os.listdir(os.path.join(BASE, 'knowledge-base')):
        if fname.startswith('sp-validation-') and fname.endswith('.json'):
            db = fname[len('sp-validation-'):-len('.json')]
            entries = load_json(os.path.join(BASE, 'knowledge-base', fname))
            validation[db] = {e['sp']: e for e in entries}
            print(f"  Loaded sp-validation-{db}.json ({len(entries)} entries)")

    # Build flow lookup: "db:sp" -> entry
    flow_lookup = flow_raw  # already keyed correctly

    # Build rules lookup: sp_name -> list of rules
    rules_lookup = {}
    for rule in rules_raw.get('rules', []):
        sp = rule.get('sp', '')
        if sp:
            rules_lookup.setdefault(sp, []).append(rule)

    # Build vocab dict: term -> entry
    vocab_dict = {}
    for atom in vocab_raw.get('atomos', []):
        vocab_dict[atom['term']] = atom
    for comp in vocab_raw.get('compuestos', []):
        vocab_dict[comp['term']] = comp

    return journeys, flow_lookup, rules_lookup, validation, vocab_dict


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def clean_mermaid(text):
    """Sanitise text for use inside Mermaid node labels (inside quotes)."""
    if not text:
        return ''
    # Remove or replace problematic characters
    text = str(text)
    text = text.replace('"', "'")
    text = text.replace('#', 'num')
    text = text.replace('<', '')
    text = text.replace('>', '')
    text = text.replace('\n', ' ')
    text = text.replace('\r', '')
    text = text.replace('`', "'")
    text = text.replace('[', '(')
    text = text.replace(']', ')')
    text = text.replace('{', '(')
    text = text.replace('}', ')')
    # Trim
    text = text.strip()
    return text


def truncate(text, n=35):
    if not text:
        return ''
    text = str(text)
    if len(text) > n:
        return text[:n - 1] + '.'
    return text


def html_escape(text):
    """Escape HTML special characters."""
    if not text:
        return ''
    text = str(text)
    text = text.replace('&', '&amp;')
    text = text.replace('<', '&lt;')
    text = text.replace('>', '&gt;')
    text = text.replace('"', '&quot;')
    return text


def get_sp_tokens(sp_name):
    """Split SP name into tokens for vocab lookup."""
    # Remove sp_ prefix if present
    name = sp_name
    if name.startswith('sp_'):
        name = name[3:]
    # Split by underscore
    tokens = [t for t in name.split('_') if len(t) > 2]
    return tokens


def get_callee_sps(flow_data):
    """Extract CALL nodes from a flow tree, returning list of sp names."""
    if not flow_data:
        return []
    callees = []

    def walk(node):
        if node.get('kind') == 'CALL':
            sp = node.get('sp', '')
            if sp and sp not in callees:
                callees.append(sp)
        for child in node.get('children', []):
            walk(child)

    flow = flow_data.get('flow', {})
    for child in flow.get('children', []):
        walk(child)
    return callees


def pick_top_rules(rules, max_n=4):
    """Pick the most important rules: riesgo first, then REGULATORIO, then rest."""
    risky = [r for r in rules if r.get('riesgo')]
    reg = [r for r in rules if not r.get('riesgo') and
           r.get('categoria', '').upper() in ('REGULATORIO', 'CALCULO_FINANCIERO')]
    rest = [r for r in rules if r not in risky and r not in reg]
    combined = (risky + reg + rest)[:max_n]
    return combined


def get_validation_entry(sp_name, db, validation):
    """Find validation entry for a SP."""
    db_val = validation.get(db, {})
    # Try exact match first
    entry = db_val.get(sp_name)
    if entry:
        return entry
    # Try stripping sp_ prefix
    if sp_name.startswith('sp_'):
        entry = db_val.get(sp_name[3:])
        if entry:
            return entry
    # Try adding sp_ prefix
    entry = db_val.get('sp_' + sp_name)
    if entry:
        return entry
    return None


SOURCE_DIR = os.path.join(BASE, 'source', 'BCOPCore', 'informix')


def parse_sp_source(sp_name, db):
    """Read the .sql source file and extract structured information about the SP.
    Falls back to any file containing the SP name if the exact db-prefixed file is missing."""
    sql_path = os.path.join(SOURCE_DIR, f'{db}_{sp_name}.sql')
    if not os.path.exists(sql_path):
        # Search for any file whose name contains the SP name (case-insensitive)
        sp_lower = sp_name.lower()
        try:
            candidates = [
                os.path.join(SOURCE_DIR, f)
                for f in os.listdir(SOURCE_DIR)
                if sp_lower in f.lower() and f.endswith('.sql')
            ]
        except OSError:
            candidates = []
        if not candidates:
            return None
        sql_path = candidates[0]   # take first match

    with open(sql_path, encoding='utf-8', errors='ignore') as f:
        src = f.read()

    # Find the CREATE PROCEDURE block for this specific SP (there may be multiple in the file)
    params = []
    proc_pos = re.search(rf'CREATE PROCEDURE[^(]*?{re.escape(sp_name)}\s*\(', src, re.IGNORECASE)
    if proc_pos:
        start = proc_pos.end()
        depth = 1
        i = start
        while i < len(src) and depth > 0:
            if src[i] == '(':
                depth += 1
            elif src[i] == ')':
                depth -= 1
            i += 1
        raw_params = src[start:i - 1]
        current = ''
        d = 0
        for ch in raw_params:
            if ch == '(':
                d += 1
                current += ch
            elif ch == ')':
                d -= 1
                current += ch
            elif ch == ',' and d == 0:
                p = current.strip()
                if p:
                    params.append(p)
                current = ''
            else:
                current += ch
        if current.strip():
            params.append(current.strip())

    # Extract validation comments: lines like --ALGO that appear just before RETURN with error code
    validations = []
    for m in re.finditer(r'--\s*([A-ZÁÉÍÓÚÑ][^\n]{5,70})\s*\n[^\n]*?LET\s+\w+\s*=\s*["\'](\d{4,5})["\']', src):
        cmt = m.group(1).strip().rstrip(',;')
        code = m.group(2)
        if cmt and code and cmt not in validations and len(validations) < 5:
            validations.append(f"{cmt} → retorna <code>{code}</code>")

    # Extract FOREACH loops: what table each iterates
    foreach_tables = []
    for m in re.finditer(r'FOREACH\s+SELECT\b.+?\bFROM\s+([\w@:.]+)', src, re.IGNORECASE | re.DOTALL):
        tbl = m.group(1).strip().rstrip(',')
        short = tbl.split(':')[-1]  # strip db prefix
        if short not in foreach_tables and len(foreach_tables) < 5:
            foreach_tables.append(short)

    # Extract called SPs — covers both CALL and EXECUTE PROCEDURE patterns
    # Informix uses:  CALL db@inst:sp(...)  or  EXECUTE PROCEDURE db:"informix".sp(...)
    ext_calls = []
    _sp_name_re = re.compile(
        r'(?:CALL|EXECUTE\s+PROCEDURE)\s+'              # keyword
        r'(?:[\w@]+:(?:"informix"\.)?)?'                # optional db:["informix".]
        r'(\w+)',                                        # SP name
        re.IGNORECASE)
    for m in _sp_name_re.finditer(src):
        candidate = m.group(1)
        # Skip DB-only hits (no underscore, very short, looks like a DB name)
        if candidate.lower() in ('informix', 'procedure') or len(candidate) < 3:
            continue
        if candidate not in ext_calls and len(ext_calls) < 6:
            ext_calls.append(candidate)

    # Extract DOCUMENT modification notes (last 3)
    doc_notes = []
    doc_m = re.search(r'\bDOCUMENT\b(.+?)(?:;|\Z)', src, re.IGNORECASE | re.DOTALL)
    if doc_m:
        for mod in re.finditer(r'MODIFICACION:\s*([^\n\']+)', doc_m.group(1)):
            note = mod.group(1).strip()
            if note and len(note) > 10:
                doc_notes.append(note)
        doc_notes = doc_notes[-3:]

    return {
        'params': params[:5],
        'validations': validations,
        'foreach_tables': foreach_tables,
        'ext_calls': ext_calls,
        'doc_notes': doc_notes,
        'src_lines': src.splitlines(),   # raw lines for per-step annotation
    }


def generate_story(sp_name, biz, val_entry, flow_data, dom_name, db):
    """Generate functional story — uses source code when available, falls back to metrics."""
    loc = val_entry.get('loc_parsed', 0) if val_entry else 0
    tables = val_entry.get('tables_n', 0) if val_entry else 0
    fan_in = val_entry.get('fan_in', 0) if val_entry else 0
    authors = val_entry.get('authors_n', 0) if val_entry else 0
    if flow_data and not loc:
        loc = flow_data.get('metrics', {}).get('loc', 0)

    parsed = parse_sp_source(sp_name, db)

    if parsed:
        # ── Rich story from source ──────────────────────────────────────────
        html = []

        # P1 — what it does + parameters
        biz_clean = (biz or sp_name).strip().rstrip('.')
        biz_clean = biz_clean[0].upper() + biz_clean[1:] if biz_clean else sp_name
        p1 = f"El procedimiento <b>{sp_name}</b> implementa la lógica de <em>{biz_clean.lower()}</em> en el dominio {dom_name} (<code>{db}</code>)."
        if parsed['params']:
            param_str = ', '.join(f"<code>{p.strip()}</code>" for p in parsed['params'])
            p1 += f" Recibe los parámetros: {param_str}."
        html.append(f"<p>{p1}</p>")

        # P2 — validation gates
        if parsed['validations']:
            gates = '; '.join(parsed['validations'])
            html.append(f"<p>Antes de ejecutar su lógica principal, verifica las siguientes condiciones de bloqueo: {gates}.</p>")

        # P3 — iteration + calls
        parts3 = []
        if parsed['foreach_tables']:
            tbls = ', '.join(f"<code>{t}</code>" for t in parsed['foreach_tables'])
            parts3.append(f"itera sobre {tbls}")
        if parsed['ext_calls']:
            call_parts = []
            for _c in parsed['ext_calls']:
                _ci = CALLEE_INFO.get(_c, {})
                if _ci.get('biz'):
                    _biz_short = html_escape(truncate(_ci['biz'], 40))
                    call_parts.append(f"<code>{html_escape(_c)}</code> ({_biz_short})")
                else:
                    call_parts.append(f"<code>{html_escape(_c)}</code>")
            parts3.append(f"delega a {', '.join(call_parts)}")
        if parts3:
            html.append(f"<p>En su cuerpo principal, {' y '.join(parts3)}.</p>")

        # P4 — scale + history
        scale_parts = []
        if loc:
            scale_parts.append(f"{loc:,} líneas")
        if tables:
            scale_parts.append(f"{tables} tablas")
        if authors > 1:
            scale_parts.append(f"{authors} autores históricos")
        if fan_in:
            scale_parts.append(f"{fan_in:,} callers en producción")
        if scale_parts:
            html.append(f"<p>Dimensión: {', '.join(scale_parts)}.</p>")

        # P5 — last doc note
        if parsed['doc_notes']:
            last = parsed['doc_notes'][-1].strip()
            if last:
                html.append(f"<p class=\"mnote\">Última modificación documentada: {last}</p>")

        return '\n'.join(html)

    # ── Fallback: metrics-only story ───────────────────────────────────────
    biz_text = (biz or sp_name)
    biz_text = biz_text[0].upper() + biz_text[1:] if biz_text else sp_name
    s1 = f"El procedimiento <b>{sp_name}</b> implementa la lógica de {biz_text.lower()} en el dominio {dom_name} (base de datos <code>{db}</code>)."

    parts = []
    if loc:
        parts.append(f"{loc:,} líneas de código")
    if tables:
        parts.append(f"{tables} tablas consultadas")
    if authors > 1:
        parts.append(f"{authors} autores históricos")
    s2 = ("Su alcance abarca " + ", ".join(parts) + "." if parts
          else "La lógica encapsulada forma parte del núcleo operativo del dominio.")

    if fan_in:
        s3 = f"Es invocado por {fan_in} callers, lo que lo convierte en un punto de alta dependencia funcional."
    elif flow_data:
        callees = get_callee_sps(flow_data)
        s3 = (f"Delega lógica a {', '.join(f'<code>{c}</code>' for c in callees[:3])}." if callees
              else "Opera de forma autónoma en su flujo principal.")
    else:
        s3 = "Su presencia en el mapa de journeys indica relevancia operativa dentro del dominio."

    return f"<p>{s1}</p><p>{s2}</p><p>{s3}</p>"


# ---------------------------------------------------------------------------
# Mermaid flowchart generation
# ---------------------------------------------------------------------------

def annotate_step(kind, item, src_lines):
    """Return a brief second-line annotation from source code for a flow node."""
    line_no = item.get('line', 0)
    if not src_lines or line_no <= 0:
        return ''

    # Window of lines around/after the node's line (0-indexed)
    idx = line_no - 1
    window_after = '\n'.join(src_lines[idx: idx + 8])
    window_true  = ' '.join(src_lines[idx + 1: idx + 5])  # lines inside the true branch

    if kind == 'FOREACH':
        m = re.search(r'\bFROM\s+([\w@:.]+)', window_after, re.IGNORECASE)
        if m:
            tbl = m.group(1).split(':')[-1].rstrip(',;')
            # Try to get WHERE key to show filter
            w = re.search(r'\bWHERE\s+(\w+)\s*=\s*(\w+)', window_after, re.IGNORECASE)
            if w:
                return f"Cursor: {tbl}  WHERE {w.group(1)}={w.group(2)}"
            return f"Cursor: {tbl}"
        return ''

    elif kind == 'IF':
        up = window_true.upper()
        # Check INSERT before DELETE/RETURN to avoid false positives
        if 'INSERT INTO' in up:
            m = re.search(r'INSERT INTO\s+([\w@:.]+)', window_true, re.IGNORECASE)
            tbl = m.group(1).split(':')[-1] if m else 'tabla'
            return f"Sí → inserta en {tbl}"
        if 'DELETE FROM' in up:
            m = re.search(r'DELETE FROM\s+([\w@:.]+)', window_true, re.IGNORECASE)
            tbl = m.group(1).split(':')[-1] if m else 'tabla'
            return f"Sí → elimina de {tbl}"
        # Use word-boundary to avoid matching RETURNING inside CALL ... RETURNING
        if re.search(r'\bRETURN\b', window_true, re.IGNORECASE):
            codes = re.findall(r'["\'](\d{4,5})["\']', window_true)
            return f"Sí → retorna {codes[0]}" if codes else "Sí → retorna error"
        if 'CALL' in up:
            m = re.search(r'CALL\s+([\w@:.]+)', window_true, re.IGNORECASE)
            sp = m.group(1).split(':')[-1] if m else ''
            return f"Sí → llama {sp}" if sp else "Sí → llama subproceso"
        if 'UPDATE' in up:
            m = re.search(r'UPDATE\s+([\w@:.]+)', window_true, re.IGNORECASE)
            tbl = m.group(1).split(':')[-1] if m else 'tabla'
            return f"Sí → actualiza {tbl}"
        if 'LET' in up:
            m = re.search(r'LET\s+(\w+)\s*=', window_true, re.IGNORECASE)
            var = m.group(1) if m else 'variable'
            return f"Sí → calcula {var}"
        return ''

    elif kind == 'CALL':
        return ''   # label already shows the SP name

    elif kind == 'WHILE':
        m = re.search(r'\bFROM\s+([\w@:.]+)', window_after, re.IGNORECASE)
        if m:
            return f"Repite sobre {m.group(1).split(':')[-1]}"
        return ''

    return ''


def generate_flowchart(sp_name, flow_data, rules, source_calls=None, src_lines=None):
    """Generate a sequential Mermaid flowchart with specific rule IDs and real SP names."""
    lines = ['flowchart TD']
    sp_label = clean_mermaid(truncate(sp_name, 34))
    lines.append(f'    A["{sp_label}\\nRecibe parámetros de entrada"]')

    children = []
    if flow_data:
        children = flow_data.get('flow', {}).get('children', [])

    # source_calls: list of actual SP names extracted from source (fallback for generic biz)
    src_calls_queue = list(source_calls or [])

    # Flatten tree into a deduplicated sequence of meaningful steps
    steps = []   # list of (label, shape)  shape: rect | diamond | pill
    seen_keys = set()

    def add_step(label, shape='rect', click_callee=None):
        key = label.lower()[:32]
        if key in seen_keys:
            return
        seen_keys.add(key)
        if len(steps) < 5:          # cap at 5 structural steps, leave room for rules
            steps.append((label, shape, click_callee))

    def resolve_call_label(item):
        """Return the best human-readable name for a CALL node.
        Source-parsed SP names are preferred over flow_data biz (which is often generic)."""
        biz = (item.get('biz') or '').strip()
        sp  = (item.get('sp')  or '').strip()
        # Always prefer source_calls when available — they contain real SP names
        if src_calls_queue:
            name = src_calls_queue.pop(0)
            return clean_mermaid(truncate(name, 36))
        # Fall back: use biz if it looks like a real description (not generic tokens)
        if biz and biz not in ('identificador', 'sp', 'procedure', ''):
            return clean_mermaid(truncate(biz, 36))
        return clean_mermaid(truncate(sp or sp_name, 28))

    def build_label(base, annotation):
        """Combine base label and annotation into a Mermaid multi-line string."""
        if annotation:
            ann = clean_mermaid(truncate(annotation, 44))
            return f'{base}\\n{ann}'
        return base

    def extract(node_list, depth=0):
        if depth > 2 or len(steps) >= 5:
            return
        for item in node_list:
            kind = item.get('kind', '')
            ann  = annotate_step(kind, item, src_lines)
            if kind == 'FOREACH':
                add_step(build_label('Itera sobre registros del cursor', ann), 'pill')
                extract(item.get('children', []), depth + 1)
            elif kind == 'IF':
                cond = clean_mermaid(truncate(item.get('cond', ''), 38)) or 'Evalúa condición'
                add_step(build_label(cond, ann), 'diamond')
                extract(item.get('children', []), depth + 1)
            elif kind == 'CALL':
                # Peek at raw callee SP name BEFORE resolve_call_label pops src_calls_queue
                if src_calls_queue:
                    callee_raw = src_calls_queue[0]
                else:
                    callee_raw = (item.get('sp') or '').strip()
                callee_display = resolve_call_label(item)
                # Enriched annotation: look up callee purpose in CALLEE_INFO
                ci = CALLEE_INFO.get(callee_raw, {})
                if ci.get('biz'):
                    ann_parts = [clean_mermaid(truncate(ci['biz'], 44))]
                    if ci.get('rules_n', 0) > 0:
                        ann_parts.append(f"{ci['rules_n']} reglas")
                    ann = ' · '.join(ann_parts)
                else:
                    ann = ''  # annotate_step returns '' for CALL anyway
                label = f'Llama a {callee_display}'
                # Click link only for SPs that have their own detail page (Phase B set).
                click_callee = callee_raw if (callee_raw and ci.get('has_page')) else None
                add_step(build_label(label, ann), 'rect', click_callee)
            elif kind == 'WHILE':
                cond = clean_mermaid(truncate(item.get('cond', ''), 32)) or 'Evalúa condición'
                add_step(build_label(f'Mientras: {cond}', ann), 'pill')
                extract(item.get('children', []), depth + 1)
            elif kind not in ('ROOT', ''):
                add_step('Proceso interno', 'rect')

    extract(children)

    if not steps:
        steps.append(('Ejecuta lógica principal', 'rect', None))

    # Emit structural chain A → N1 → N2 → ...
    counter = [0]
    click_directives = []

    def emit(label, shape, prev_id):
        counter[0] += 1
        nid = f'N{counter[0]}'
        if shape == 'diamond':
            lines.append(f'    {nid}{{"{label}"}}')
        elif shape == 'pill':
            lines.append(f'    {nid}(["{label}"])')
        else:
            lines.append(f'    {nid}["{label}"]')
        lines.append(f'    {prev_id} --> {nid}')
        return nid

    prev = 'A'
    for step_label, step_shape, step_click in steps:
        nid = emit(step_label, step_shape, prev)
        prev = nid
        if step_click:
            click_directives.append(
                f'    click {nid} "sp-detail-{step_click}.html" "Ver detalle funcional"'
            )

    # Rules: expand into specific nodes (≤3 shown individually, more → summary)
    if rules:
        top = pick_top_rules(rules, max_n=3)
        if len(rules) <= 3:
            for rule in top:
                rid   = rule.get('id', 'BR')
                expl  = clean_mermaid(truncate(rule.get('explicacion') or rule.get('code', ''), 40))
                label = f'{rid}: {expl}' if expl else rid
                prev  = emit(label, 'rect', prev)
        else:
            ids   = ' · '.join(r.get('id', '') for r in top[:2])
            extra = len(rules) - 2
            label = f'{ids} +{extra} reglas'
            prev  = emit(label, 'rect', prev)

    lines.append('    Z["Retorna resultado"]')
    lines.append(f'    {prev} --> Z')

    # Click directives MUST come after all node/edge definitions (Mermaid v11)
    if click_directives:
        lines.extend(click_directives)

    return '\n'.join(lines)


# ---------------------------------------------------------------------------
# Mermaid sequence diagram generation
# ---------------------------------------------------------------------------

def generate_sequence(sp_name, dom_name, dom_num, flow_data, rules, vocab_matches):
    """Generate a Mermaid sequence diagram string."""
    lines = []
    lines.append('sequenceDiagram')
    lines.append('    autonumber')

    # Participants
    caller_label = clean_mermaid(truncate(f'{dom_num} {dom_name}', 25))
    sp_label = clean_mermaid(truncate(sp_name, 28))
    lines.append(f'    participant CL as {caller_label}')
    lines.append(f'    participant SP as {sp_label}')

    # Add callee participants
    callees = []
    if flow_data:
        raw_callees = get_callee_sps(flow_data)
        for i, c in enumerate(raw_callees[:3]):
            pid = f'C{i+1}'
            clabel = clean_mermaid(truncate(c, 25))
            lines.append(f'    participant {pid} as {clabel}')
            callees.append((pid, c))

    # Call sequence
    lines.append(f'    CL->>SP: invoca {sp_label}')

    # Show callee calls
    for pid, callee in callees[:2]:
        clabel = clean_mermaid(truncate(callee, 25))
        lines.append(f'    SP->>{pid}: delega a {clabel}')
        lines.append(f'    {pid}-->>SP: resultado')

    # Notes for top rules
    top_rules = pick_top_rules(rules, max_n=4) if rules else []
    for rule in top_rules:
        rid = rule.get('id', '')
        cat = rule.get('categoria', '')
        expl = clean_mermaid(truncate(rule.get('explicacion', rule.get('code', '')), 50))
        if rid and expl:
            lines.append(f'    Note over SP: {rid} {cat}: {expl}')

    # Vocab note
    if vocab_matches:
        terms = ', '.join(v['term'] for v in vocab_matches[:4])
        lines.append(f'    Note over SP,CL: vocab: {clean_mermaid(terms)}')

    lines.append(f'    SP-->>CL: retorna resultado')

    return '\n'.join(lines)


# ---------------------------------------------------------------------------
# Vocab matching
# ---------------------------------------------------------------------------

def find_vocab_matches(sp_name, db, vocab_dict):
    """Find vocab terms relevant to this SP."""
    tokens = get_sp_tokens(sp_name)
    matches = []
    seen = set()

    # Direct token matches (exact match on split token)
    for token in tokens:
        if token in vocab_dict and token not in seen:
            matches.append(vocab_dict[token])
            seen.add(token)

    # Find vocab terms that appear as substrings within the SP name
    sp_lower = sp_name.lower()
    for term, entry in vocab_dict.items():
        if term in seen:
            continue
        if len(term) > 3 and term in sp_lower:
            matches.append(entry)
            seen.add(term)
            if len(matches) >= 8:
                break

    return matches[:8]


# ---------------------------------------------------------------------------
# HTML generation
# ---------------------------------------------------------------------------

CSS = r"""
*{box-sizing:border-box;margin:0;padding:0}
:root{--blue:#122FB1;--blueb:#3D5FCD;--yellow:#F0D224;--ink:#F4F6FF;--muted:#aab3d4;--muted2:#818ab0;
  --glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.10);--bg:#060d1f}
html{scroll-behavior:smooth}
body{background:var(--bg);color:var(--ink);font-family:'SF Pro Display',-apple-system,'Inter','Segoe UI',sans-serif;
  -webkit-font-smoothing:antialiased;overflow-x:hidden;line-height:1.6}
.aurora{position:fixed;inset:0;z-index:-2;overflow:hidden;pointer-events:none}
.aurora::before{content:"";position:absolute;width:55vw;height:55vw;left:-10vw;top:-10vw;border-radius:50%;
  background:radial-gradient(circle,rgba(18,47,177,.45),transparent 70%);filter:blur(80px);animation:f1 20s ease-in-out infinite}
.aurora::after{content:"";position:absolute;width:40vw;height:40vw;right:-8vw;bottom:-8vw;border-radius:50%;
  background:radial-gradient(circle,rgba(240,210,36,.12),transparent 70%);filter:blur(80px);animation:f2 26s ease-in-out infinite}
@keyframes f1{50%{transform:translate(5vw,8vh) scale(1.1)}}
@keyframes f2{50%{transform:translate(-5vw,-6vh) scale(1.15)}}
.grain{position:fixed;inset:0;z-index:-1;opacity:.04;pointer-events:none;
  background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}
nav{position:sticky;top:0;z-index:50;display:flex;align-items:center;gap:12px;padding:13px 28px;
  backdrop-filter:blur(18px) saturate(150%);background:rgba(6,13,31,.7);border-bottom:1px solid rgba(255,255,255,.07)}
nav img{height:20px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.5))}
nav .sep{color:rgba(255,255,255,.2);font-size:14px}
nav .bc{font-size:12px;color:var(--muted);font-weight:500}
nav .sp{flex:1}
nav a.back{font-size:12px;color:var(--muted);padding:5px 12px;border-radius:18px;border:1px solid rgba(255,255,255,.09);transition:.2s;text-decoration:none}
nav a.back:hover{color:var(--ink);background:rgba(255,255,255,.07)}
.glass{background:var(--glass);backdrop-filter:blur(20px) saturate(150%);border:1px solid var(--glassb);
  border-radius:20px;box-shadow:0 10px 40px rgba(0,0,0,.35),inset 0 1px 0 rgba(255,255,255,.09)}
.wrap{max-width:1040px;margin:0 auto;padding:0 28px}
section{padding:52px 0}
.sp-hero{padding:52px 0 32px}
.sp-domain-tag{display:inline-flex;align-items:center;gap:8px;padding:5px 14px;border-radius:20px;
  font-size:11px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:#dfe6ff;margin-bottom:20px;
  background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.10)}
.sp-domain-tag .dot{width:6px;height:6px;border-radius:50%;background:var(--yellow);box-shadow:0 0 8px var(--yellow);animation:pulse 2s infinite}
@keyframes pulse{50%{opacity:.3}}
.sp-name{font-size:clamp(24px,4vw,40px);font-weight:800;letter-spacing:-.03em;line-height:1.1;
  font-family:'SF Mono',ui-monospace,monospace;color:#e0ecff;margin-bottom:14px}
.sp-name .prefix{color:rgba(255,255,255,.3)}
.sp-desc{font-size:16px;color:var(--muted);max-width:68ch;line-height:1.6}
.metrics{display:flex;gap:12px;flex-wrap:wrap;margin-top:28px}
.metric{padding:14px 22px;text-align:center;min-width:110px}
.metric-n{font-size:28px;font-weight:800;letter-spacing:-.02em;font-variant-numeric:tabular-nums;
  background:linear-gradient(180deg,#fff,#c4d0ff);-webkit-background-clip:text;background-clip:text;color:transparent}
.metric-l{font-size:10px;color:var(--muted2);margin-top:5px;text-transform:uppercase;letter-spacing:.07em;font-weight:600}
.metric.warn .metric-n{background:linear-gradient(180deg,var(--yellow),#c8a800);-webkit-background-clip:text;background-clip:text;color:transparent}
.sec-num{font-size:10px;font-weight:800;letter-spacing:.2em;color:var(--yellow);text-transform:uppercase;margin-bottom:10px}
.sec-title{font-size:clamp(22px,3vw,32px);font-weight:800;letter-spacing:-.025em;margin-bottom:8px}
.sec-sub{font-size:14px;color:var(--muted);max-width:72ch;line-height:1.6;margin-bottom:28px}
.divider{height:1px;background:linear-gradient(90deg,rgba(240,210,36,.3),transparent);margin:52px 0 0}
.story-body{font-size:15.5px;color:#d0daf4;line-height:1.75;max-width:78ch}
.story-body p{margin-bottom:18px}
.story-body b{color:#e8f0ff;font-weight:700}
.story-body code{background:rgba(240,210,36,.1);border:1px solid rgba(240,210,36,.22);border-radius:5px;
  padding:1px 6px;font-size:11.5px;color:var(--yellow);font-family:'SF Mono',ui-monospace,monospace}
.call-pills{display:flex;flex-wrap:wrap;gap:8px;margin-top:16px}
.pill{padding:5px 12px;border-radius:20px;font-size:12px;font-weight:600;font-family:monospace}
.pill.callee{background:rgba(240,210,36,.1);border:1px solid rgba(240,210,36,.3);color:var(--yellow)}
.pill.caller{background:rgba(61,95,205,.15);border:1px solid rgba(61,95,205,.4);color:#9ab0ff}
.diagram-wrap{padding:28px 24px;overflow-x:auto}
.diagram-wrap .mermaid{display:flex;justify-content:center}
.rules-grid{display:flex;flex-direction:column;gap:10px}
.rule-row{display:grid;grid-template-columns:90px 1fr auto;gap:16px;align-items:start;padding:14px 18px;border-radius:14px;
  background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.07)}
.rule-row:hover{background:rgba(255,255,255,.055);border-color:rgba(240,210,36,.2)}
.rule-id{font-size:10px;color:var(--muted2);font-family:monospace;font-weight:600;padding-top:2px}
.rule-code{font-family:'SF Mono',ui-monospace,monospace;font-size:12px;color:#a0d0ff;background:rgba(0,0,0,.3);
  border-radius:6px;padding:5px 10px;margin-bottom:6px;word-break:break-all}
.rule-expl{font-size:13px;color:var(--muted);line-height:1.5}
.rule-badges{display:flex;flex-direction:column;align-items:flex-end;gap:5px}
.badge{font-size:10px;font-weight:700;padding:2px 8px;border-radius:8px;white-space:nowrap;letter-spacing:.04em}
.badge.calc{background:rgba(46,123,88,.25);border:1px solid rgba(46,123,88,.5);color:#5de8a0}
.badge.reg{background:rgba(122,58,154,.25);border:1px solid rgba(122,58,154,.5);color:#cc88ff}
.badge.risk{background:rgba(240,100,36,.2);border:1px solid rgba(240,100,36,.4);color:#ff9966;font-size:9px}
.badge.cnbv{background:rgba(240,210,36,.1);border:1px solid rgba(240,210,36,.3);color:var(--yellow)}
.no-data{font-size:14px;color:var(--muted2);font-style:italic;padding:24px 0}
.vocab-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:12px}
.vocab-card{padding:14px 16px;border-radius:14px}
.vocab-term{font-size:14px;font-weight:700;font-family:monospace;color:#e0ecff;margin-bottom:4px}
.vocab-mean{font-size:12.5px;color:var(--muted);line-height:1.5}
.vocab-conf{font-size:9.5px;font-weight:700;letter-spacing:.07em;text-transform:uppercase;margin-top:6px;color:var(--yellow)}
.reveal{opacity:0;transform:translateY(24px);transition:opacity .8s cubic-bezier(.16,1,.3,1),transform .8s cubic-bezier(.16,1,.3,1)}
.reveal.in{opacity:1;transform:none}
footer{padding:36px 28px 56px;text-align:center;color:var(--muted2);font-size:11.5px;
  border-top:1px solid rgba(255,255,255,.06);margin-top:40px;line-height:1.8}
code{background:rgba(240,210,36,.1);border:1px solid rgba(240,210,36,.22);border-radius:5px;
  padding:1px 6px;font-size:11.5px;color:var(--yellow);font-family:'SF Mono',ui-monospace,monospace}
.chips{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:20px}
.chip{padding:4px 12px;border-radius:14px;font-size:11px;font-weight:700;letter-spacing:.05em}
.chip.blue{background:rgba(18,47,177,.3);border:1px solid rgba(61,95,205,.5);color:#9ab0ff}
.chip.muted{background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);color:var(--muted)}
.chip.yellow{background:rgba(240,210,36,.12);border:1px solid rgba(240,210,36,.3);color:var(--yellow)}
"""

MERMAID_INIT = """<script type="module">
import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
mermaid.initialize({
  startOnLoad: true,
  theme: 'dark',
  themeVariables: {
    primaryColor:       '#1a3080',
    primaryTextColor:   '#F4F6FF',
    primaryBorderColor: '#3D5FCD',
    secondaryColor:     '#0d1a40',
    tertiaryColor:      '#1a2a5a',
    lineColor:          '#5a8fff',
    edgeLabelBackground:'#0a1230',
    actorBkg:           '#122FB1',
    actorBorder:        '#3D5FCD',
    actorTextColor:     '#F4F6FF',
    actorLineColor:     '#3a6adf',
    signalColor:        '#aab3d4',
    signalTextColor:    '#e0ecff',
    labelBoxBkgColor:   '#0d1a40',
    labelBoxBorderColor:'#3D5FCD',
    labelTextColor:     '#c8d8f0',
    loopTextColor:      '#c8d8f0',
    noteBorderColor:    '#F0D224',
    noteBkgColor:       '#1c1a00',
    noteTextColor:      '#F0D224',
    activationBorderColor:'#F0D224',
    activationBkgColor: '#2a2800',
    fontFamily: "'SF Pro Display', -apple-system, 'Inter', sans-serif",
    fontSize:   '13px',
  }
});
</script>"""

REVEAL_SCRIPT = """<script>
const io = new IntersectionObserver(es => es.forEach(e => {
  if(e.isIntersecting){ e.target.classList.add('in'); io.unobserve(e.target); }
}), {threshold:.1, rootMargin:'0px 0px -5% 0px'});
document.querySelectorAll('.reveal').forEach(el => {
  const sibs = [...el.parentElement.children].filter(c => c.classList.contains('reveal'));
  el.style.transitionDelay = (Math.min(sibs.indexOf(el), 6) * 80) + 'ms';
  io.observe(el);
});
</script>"""


def render_rule_badge(rule):
    cat = rule.get('categoria', '').upper()
    riesgo = rule.get('riesgo', [])
    badges = []
    if cat == 'REGULATORIO':
        badges.append('<span class="badge reg">Regulatorio</span>')
        # Check for CNBV reference
        reg_refs = rule.get('reg', [])
        if reg_refs:
            badges.append('<span class="badge cnbv">CNBV</span>')
    elif cat == 'CALCULO_FINANCIERO':
        badges.append('<span class="badge calc">Calculo Financiero</span>')
    elif cat:
        badges.append(f'<span class="badge muted">{html_escape(cat[:20])}</span>')
    if riesgo:
        badges.append('<span class="badge risk">riesgo</span>')
    return '\n'.join(badges)


def build_html(sp_name, entry, dom_info, flow_data, rules, val_entry, vocab_matches):
    dom_name = dom_info['name']
    dom_num = dom_info['num']
    db = dom_info['db']
    dom_slug = dom_info['slug']
    entry_type = entry.get('_type', 'proc')

    # Metrics
    fan_in = 0
    fan_out = entry.get('fan_out', entry.get('ext_callers', 0)) or 0
    loc = entry.get('loc', 0) or 0
    tables = 0
    authors = 0

    if val_entry:
        fan_in = val_entry.get('fan_in', 0) or 0
        if not loc:
            loc = val_entry.get('loc_parsed', 0) or 0
        tables = val_entry.get('tables_n', 0) or 0
        authors = val_entry.get('authors_n', 0) or 0

    if flow_data:
        fm = flow_data.get('metrics', {})
        if not loc:
            loc = fm.get('loc', 0) or 0

    rule_count = len(rules)

    # SP name display: if starts with sp_, show prefix in muted color
    if sp_name.startswith('sp_'):
        sp_display = '<span class="prefix">sp_</span>' + html_escape(sp_name[3:])
    else:
        sp_display = html_escape(sp_name)

    # Badge chips
    type_chip = 'proc' if entry_type == 'journeys' else 'exposed'
    type_chip_class = 'yellow' if entry_type == 'journeys' else 'muted'

    # Callees
    callees = get_callee_sps(flow_data) if flow_data else []
    callee_pills = ''.join(f'<span class="pill callee">{html_escape(c)}</span>' for c in callees)
    callee_section = ''
    if callee_pills:
        callee_section = f'''
      <div style="font-size:11px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:var(--muted2);margin-top:16px;margin-bottom:10px">Llama a</div>
      <div class="call-pills">{callee_pills}</div>'''

    # Source parse (shared between story and flowchart)
    parsed_src = parse_sp_source(sp_name, db)
    src_calls  = parsed_src.get('ext_calls', []) if parsed_src else []
    src_lines  = parsed_src.get('src_lines', []) if parsed_src else []

    # Story
    story = generate_story(sp_name, entry.get('biz', ''), val_entry, flow_data, dom_name, db)

    # Flowchart
    flowchart = generate_flowchart(sp_name, flow_data, rules, source_calls=src_calls, src_lines=src_lines)

    # Sequence
    sequence = generate_sequence(sp_name, dom_name, dom_num, flow_data, rules, vocab_matches)

    # Rules rows
    rules_html = ''
    if rules:
        rows = []
        for rule in rules[:20]:
            rid = html_escape(rule.get('id', ''))
            line = rule.get('line', '')
            code = html_escape(rule.get('code', ''))
            expl = html_escape(rule.get('explicacion', ''))
            badges = render_rule_badge(rule)
            rows.append(f'''      <div class="rule-row reveal">
        <div class="rule-id">{rid}<br/>linea {line}</div>
        <div class="rule-main">
          <div class="rule-code">{code}</div>
          <div class="rule-expl">{expl}</div>
        </div>
        <div class="rule-badges">{badges}</div>
      </div>''')
        rules_html = '<div class="rules-grid">\n' + '\n'.join(rows) + '\n      </div>'
    else:
        rules_html = '<p class="no-data">No se detectaron reglas de negocio para este proceso.</p>'

    # Vocab cards
    vocab_html = ''
    if vocab_matches:
        cards = []
        for v in vocab_matches:
            term = html_escape(v.get('term', ''))
            mean = html_escape(v.get('mean', ''))
            cat = html_escape(v.get('cat', ''))
            nivel = html_escape(v.get('nivel', ''))
            conf_label = f'{nivel} · {cat}' if nivel and cat else cat or nivel
            cards.append(f'''      <div class="vocab-card glass reveal">
        <div class="vocab-term">{term}</div>
        <div class="vocab-mean">{mean}</div>
        <div class="vocab-conf">{conf_label}</div>
      </div>''')
        vocab_html = '<div class="vocab-grid">\n' + '\n'.join(cards) + '\n      </div>'
    else:
        vocab_html = '<p class="no-data">Terminos pendientes de clasificacion.</p>'

    # Metrics warning threshold
    fan_in_cls = ' warn' if fan_in > 50 else ''
    rule_cls = ' warn' if rule_count > 5 else ''

    loc_str = f'{loc:,}' if loc else '—'
    fan_in_str = str(fan_in) if fan_in else '0'
    fan_out_str = str(fan_out) if fan_out else '0'
    rule_str = str(rule_count)
    tables_str = str(tables) if tables else '—'
    authors_str = str(authors) if authors else '—'

    biz_text = html_escape(entry.get('biz', '') or sp_name)

    reg_flag = entry.get('reg', False)
    reg_badge = f'<span class="chip yellow">REGULATORIO</span>' if reg_flag else ''

    html = f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>{html_escape(sp_name)} · BCOPCore</title>
{MERMAID_INIT}
<style>
{CSS}
</style></head><body>
<div class="aurora"></div><div class="grain"></div>

<nav>
  <img src="bancoppel-logo.png" alt="BanCoppel">
  <span class="sep">/</span>
  <span class="bc">BCOPCore · {dom_num} · {html_escape(dom_name)}</span>
  <span class="sp"></span>
  <a class="back" href="capability-model-bcop-v2.html">← Modelo de Capacidades</a>
  <a class="back" href="component-map-bcop-v2.html">← Mapa de Componentes</a>
</nav>

<div class="wrap">

  <!-- Hero -->
  <header class="sp-hero">
    <div class="sp-domain-tag"><span class="dot"></span> {dom_num} · {html_escape(dom_name)} · {html_escape(db)} · FLUJO OPERATIVO</div>
    <div class="sp-name">{sp_display}</div>
    <p class="sp-desc">{biz_text}</p>
    <div class="chips">
      <span class="chip blue">{html_escape(dom_name)}</span>
      <span class="chip muted">{html_escape(db)}</span>
      <span class="chip {type_chip_class}">{type_chip}</span>
      {reg_badge}
    </div>
    <div class="metrics">
      <div class="metric glass{fan_in_cls}"><div class="metric-n">{fan_in_str}</div><div class="metric-l">Fan-in</div></div>
      <div class="metric glass"><div class="metric-n">{fan_out_str}</div><div class="metric-l">Fan-out</div></div>
      <div class="metric glass"><div class="metric-n">{loc_str}</div><div class="metric-l">Lineas de codigo</div></div>
      <div class="metric glass{rule_cls}"><div class="metric-n">{rule_str}</div><div class="metric-l">Reglas</div></div>
      <div class="metric glass"><div class="metric-n">{tables_str}</div><div class="metric-l">Tablas</div></div>
      <div class="metric glass"><div class="metric-n">{authors_str}</div><div class="metric-l">Autores</div></div>
    </div>
  </header>

  <div class="divider"></div>

  <!-- 01 Historia Funcional -->
  <section>
    <div class="sec-num reveal">01 · Historia Funcional</div>
    <h2 class="sec-title reveal">{html_escape(sp_name)}</h2>
    <p class="sec-sub reveal">Narrativa reconstruida a partir del call graph, el codigo y el vocabulario del dominio.</p>
    <div class="story-body reveal">{story}</div>
    {callee_section}
  </section>

  <div class="divider"></div>

  <!-- 02 Flujo de Decision -->
  <section>
    <div class="sec-num reveal">02 · Flujo de Decision</div>
    <h2 class="sec-title reveal">Flujo de Decision</h2>
    <p class="sec-sub reveal">Reconstruido desde el call graph y las reglas de negocio detectadas en el codigo.</p>
    <div class="glass diagram-wrap reveal">
      <div class="mermaid">
{flowchart}
      </div>
    </div>
  </section>

  <div class="divider"></div>

  <!-- 03 Secuencia -->
  <section>
    <div class="sec-num reveal">03 · Diagrama de Secuencia</div>
    <h2 class="sec-title reveal">Secuencia con Reglas y Vocabulario</h2>
    <p class="sec-sub reveal">Muestra la secuencia de llamadas y las restricciones de negocio en contexto.</p>
    <div class="glass diagram-wrap reveal">
      <div class="mermaid">
{sequence}
      </div>
    </div>
  </section>

  <div class="divider"></div>

  <!-- 04 Reglas -->
  <section>
    <div class="sec-num reveal">04 · Reglas de Negocio</div>
    <h2 class="sec-title reveal">Reglas de Negocio</h2>
    <p class="sec-sub reveal">{rule_count} reglas extraidas del codigo fuente.</p>
    {rules_html}
  </section>

  <div class="divider"></div>

  <!-- 05 Vocabulario -->
  <section>
    <div class="sec-num reveal">05 · Vocabulario</div>
    <h2 class="sec-title reveal">Vocabulario</h2>
    <p class="sec-sub reveal">Terminos del vocabulario controlado de BCOPCore presentes en este procedimiento.</p>
    {vocab_html}
  </section>

</div>

<footer>
  BCOPCore · {dom_num} {html_escape(dom_name)} · <code>{html_escape(sp_name)}</code> · SPE-AM-001 · Fase DISCOVER<br>
  Datos extraidos desde <code>business-rules-v2.json</code> · <code>flow-data.json</code> · <code>vocabulary-inventory.json</code>
</footer>

{REVEAL_SCRIPT}
</body></html>"""

    return html


# ---------------------------------------------------------------------------
# KB Markdown generation
# ---------------------------------------------------------------------------

def build_md(sp_name, entry, dom_info, flow_data, rules, val_entry, vocab_matches):
    dom_name = dom_info['name']
    dom_num = dom_info['num']
    dom_slug = dom_info['slug']
    db = dom_info['db']
    entry_type = entry.get('_type', 'journeys')

    # Metrics
    fan_in = 0
    fan_out = entry.get('fan_out', entry.get('ext_callers', 0)) or 0
    loc = entry.get('loc', 0) or 0
    tables = 0
    authors = 0
    rules_n = 0
    sinteticos = []

    if val_entry:
        fan_in = val_entry.get('fan_in', 0) or 0
        if not loc:
            loc = val_entry.get('loc_parsed', 0) or 0
        tables = val_entry.get('tables_n', 0) or 0
        authors = val_entry.get('authors_n', 0) or 0
        rules_n = val_entry.get('rules_n', 0) or 0
        sinteticos = val_entry.get('sinteticos', []) or []

    if flow_data:
        fm = flow_data.get('metrics', {})
        if not loc:
            loc = fm.get('loc', 0) or 0

    rule_count = len(rules)
    biz = entry.get('biz', sp_name)
    reg_flag = entry.get('reg', False)

    # Callees
    callees = get_callee_sps(flow_data) if flow_data else []

    # Story (plain text for MD)
    story_plain = f"El SP `{sp_name}` implementa la logica de {biz} en el dominio {dom_name} (base de datos `{db}`). "
    parts = []
    if loc > 0:
        parts.append(f"{loc:,} lineas de codigo")
    if tables > 0:
        parts.append(f"{tables} tablas consultadas")
    if authors > 1:
        parts.append(f"{authors} autores historicos")
    if parts:
        story_plain += "Comprende " + ", ".join(parts) + ". "
    if fan_in > 0:
        story_plain += f"Es invocado por {fan_in} callers en el sistema, lo que lo convierte en un componente de alta dependencia. "
    if callees:
        story_plain += f"Delega logica a: " + ", ".join([f"`{c}`" for c in callees[:3]]) + "."

    # Relations table
    relations = [
        ('Cross-reference de reglas y vocabulario', '../cross-reference/sp-rules-vocab-map.md'),
        (f'Dependencias del dominio {dom_num}', f'../{ dom_slug}/07-dependencies.md'),
        ('Reglas globales del sistema', '../rules/business-rules-bcop.md'),
        ('Vocabulario del sistema', '../vocabulary/vocabulary-knowledge-base-bcop.md'),
        ('Vista HTML interactiva', f'../../portal/sp-detail/sp-detail-{sp_name}.html'),
    ]
    if reg_flag:
        relations.insert(1, ('Indice regulatorio', '../cross-reference/regulatory-sp-index.md'))

    rel_rows = '\n'.join(f'| {desc} | [{doc}]({doc}) |' for desc, doc in relations)

    # Flowchart (for MD use simple mermaid block)
    parsed_src_md = parse_sp_source(sp_name, db)
    src_calls_md  = parsed_src_md.get('ext_calls', []) if parsed_src_md else []
    src_lines_md  = parsed_src_md.get('src_lines', []) if parsed_src_md else []
    flowchart = generate_flowchart(sp_name, flow_data, rules, source_calls=src_calls_md, src_lines=src_lines_md)
    sequence = generate_sequence(sp_name, dom_name, dom_num, flow_data, rules, vocab_matches)

    # Rules table
    rules_table = ''
    if rules:
        rows = ['| ID | Tipo | Categoria | Linea | Codigo | Referencia |',
                '|----|------|-----------|-------|--------|------------|']
        for r in rules[:20]:
            rid = r.get('id', '')
            tipo = r.get('tipo', '')
            cat = r.get('categoria', '')
            line = str(r.get('line', ''))
            code = r.get('code', '')[:60].replace('|', '\\|')
            reg_refs = r.get('reg', [])
            ref = reg_refs[0][1] if reg_refs and len(reg_refs[0]) > 1 else ('CNBV' if reg_refs else '—')
            rows.append(f'| {rid} | {tipo} | {cat} | {line} | `{code}` | {ref} |')
        rules_table = '\n'.join(rows)
    else:
        rules_table = '_No se detectaron reglas de negocio para este proceso._'

    # Vocab table
    vocab_table = ''
    if vocab_matches:
        rows = ['| Termino | Categoria | Nivel | Significado |',
                '|---------|-----------|-------|-------------|']
        for v in vocab_matches:
            term = v.get('term', '')
            cat = v.get('cat', '')
            nivel = v.get('nivel', '')
            mean = v.get('mean', '')
            rows.append(f'| `{term}` | {cat} | {nivel} | {mean} |')
        vocab_table = '\n'.join(rows)
    else:
        vocab_table = '_Terminos pendientes de clasificacion._'

    # Migration note
    mig_note = ''
    reg_rules = [r for r in rules if r.get('categoria', '').upper() == 'REGULATORIO']
    if reg_rules:
        mig_note += f"\nLas {len(reg_rules)} reglas con categoria REGULATORIO son las mas sensibles en la migracion y deben ser validadas por el SME de Industry Banking Accounting contra el CUB vigente."
    if sinteticos:
        tokens = ', '.join([f'`{t}`' for t in sinteticos[:5]])
        mig_note += f"\nEl nombre contiene tokens sinteticos ({tokens}), lo que indica que el alcance original fue parcialmente documentado por el equipo historico."
    if not mig_note:
        mig_note = "\nSin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado."

    callee_list = '\n'.join(f'| `{c}` | delegado | — |' for c in callees[:4]) or '| — | — | — |'

    md = f"""# SP Profile: `{sp_name}`

> **Base de datos**: `{db}` · Dominio {dom_num} — {dom_name}
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: {TODAY}
> **Estado**: ACTIVO · {fan_in} callers en produccion

---

## Historia Funcional

{story_plain}

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
{rel_rows}

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **{fan_in}** |
| Fan-out (callees) | **{fan_out}** |
| Callees principales | {', '.join([f'`{c}`' for c in callees[:3]]) or '—'} |
| LOC | **{loc:,}** |
| Tablas consultadas | {tables} |
| Reglas de negocio activas | **{rule_count}** |
| Autores historicos | {authors} |

---

## Flujo de Decision

```mermaid
{flowchart}
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
{sequence}
```

---

## Reglas de Negocio Activas

{rules_table}

---

## Vocabulario Clave

{vocab_table}

---

## Nota de Migracion
{mig_note}

Ver registro completo de riesgos: [migration-risk-register.md](../../knowledge-base/migration-risk-register.md).
"""
    return md


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    journeys, flow_lookup, rules_lookup, validation, vocab_dict = load_all_data()

    # Phase C: pre-load biz for all brain.db SPs (has_page=False).
    global CALLEE_INFO
    print("\nBuilding CALLEE_INFO (Phase C + Phase B)...")
    CALLEE_INFO = load_callee_info_from_brain(BRAIN_DB_PATH)

    # Phase B: overlay curated journeys entries — these SPs have HTML detail
    # pages so their entries get has_page=True and their biz takes priority.
    for _dom, _ddata in journeys.items():
        for _etype in ('journeys', 'exposed'):
            for _jj in _ddata.get(_etype, []):
                _sp = _jj.get('sp', '')
                if _sp:
                    CALLEE_INFO[_sp] = {
                        'biz': _jj.get('biz') or CALLEE_INFO.get(_sp, {}).get('biz', ''),
                        'rules_n': 0,
                        'has_page': True,
                    }
    # Enrich journeys entries with actual rule counts
    for _sp, _rlist in rules_lookup.items():
        if _sp in CALLEE_INFO and CALLEE_INFO[_sp].get('has_page'):
            CALLEE_INFO[_sp]['rules_n'] = len(_rlist)
    _with_biz  = sum(1 for v in CALLEE_INFO.values() if v.get('biz'))
    _with_page = sum(1 for v in CALLEE_INFO.values() if v.get('has_page'))
    print(f"CALLEE_INFO: {len(CALLEE_INFO):,} entries  |  "
          f"{_with_biz:,} with biz  |  {_with_page} with detail page")
    # dummy var to preserve indentation of next line
    _callee_with_biz = _with_biz  # kept for any downstream reference

    html_count = 0
    md_count = 0
    skipped = 0
    errors = []

    # Collect all SPs
    all_sps = []
    for dom, dinfo in journeys.items():
        db = dinfo.get('db', '')
        for entry_type in ['journeys', 'exposed']:
            for sp_entry in dinfo.get(entry_type, []):
                entry = dict(sp_entry)
                entry['_dom'] = dom
                entry['_db'] = db
                entry['_type'] = entry_type
                all_sps.append(entry)

    print(f"\nProcessing {len(all_sps)} SPs...\n")

    for sp_entry in all_sps:
        sp_name = sp_entry.get('sp', '')
        if not sp_name:
            continue

        dom = sp_entry['_dom']
        db = sp_entry['_db']

        if dom not in DOMAIN_INFO:
            print(f"  SKIP {sp_name} — unknown domain {dom}")
            skipped += 1
            continue

        dom_info = DOMAIN_INFO[dom]

        try:
            # Find flow data
            flow_key = f'{db}:{sp_name}'
            flow_data = flow_lookup.get(flow_key)

            # Find validation entry
            val_entry = get_validation_entry(sp_name, db, validation)

            # Find rules
            rules = rules_lookup.get(sp_name, [])

            # Find vocab
            vocab_matches = find_vocab_matches(sp_name, db, vocab_dict)

            # --- Generate HTML ---
            html_path = os.path.join(BASE, 'portal', 'sp-detail', f'sp-detail-{sp_name}.html')
            html_content = build_html(sp_name, sp_entry, dom_info, flow_data, rules, val_entry, vocab_matches)
            with open(html_path, 'w', encoding='utf-8') as f:
                f.write(html_content)
            html_count += 1

            # --- Generate MD ---
            kb_dir = os.path.join(BASE, 'knowledge-base', dom_info['slug'])
            if os.path.isdir(kb_dir):
                md_path = os.path.join(kb_dir, f'sp-profile-{sp_name}.md')
                if os.path.exists(md_path):
                    print(f"  [skip-md] {sp_name} (MD already exists)")
                else:
                    md_content = build_md(sp_name, sp_entry, dom_info, flow_data, rules, val_entry, vocab_matches)
                    with open(md_path, 'w', encoding='utf-8') as f:
                        f.write(md_content)
                    md_count += 1
                    print(f"  [ok] {sp_name} -> HTML + MD ({dom_info['num']})")
            else:
                print(f"  [ok-html] {sp_name} → HTML only (no KB dir for {dom_info['slug']})")

        except Exception as e:
            errors.append((sp_name, str(e)))
            print(f"  [ERROR] {sp_name}: {e}")

    print(f"\n{'='*60}")
    print(f"HTML files generated: {html_count}")
    print(f"KB markdown files generated: {md_count}")
    print(f"Skipped: {skipped}")
    if errors:
        print(f"Errors ({len(errors)}):")
        for sp, err in errors:
            print(f"  {sp}: {err}")
    else:
        print("Errors: 0")
    print(f"{'='*60}")


if __name__ == '__main__':
    main()
