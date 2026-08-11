#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
enrich-rules-v3.py — Layer A+ enrichment para reglas de negocio BCOPCore.

Qué hace:
  1. Carga domain map completo D01-D53 desde brain.db
  2. Lee business-rules-v2.json (7,784 reglas, D01-D16 + D17-D44 raw)
  3. Extrae reglas de los 7 DBs faltantes (D37,D43,D45,D46,D47,D48,D49)
  4. Corrige etiqueta `dominio` para D17+ (raw DB name → "D17 Banca por Internet")
  5. Añade `business_name` a cada regla (nombre natural en español, max 65 chars)
  6. Escribe portal/data/business-rules-v3.json + knowledge-base/rules/business-rules-bcop.md

Layer A+ — DT-Reglas v1.3.0 · SPE-AM-001
"""
import json, re, os, sqlite3, io, sys, datetime
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/BCOPCore/")
SRC  = BASE + "source/BCOPCore/informix/"

# ── 1. Domain map from brain.db ───────────────────────────────────────────────
conn = sqlite3.connect(BASE + 'digital-brain/brain.db')
conn.row_factory = sqlite3.Row
DB_TO_DOMAIN = {}   # db_name → {id, label}  e.g. 'bdibpi' → {id:'D17', label:'D17 Banca por Internet (BPI)'}
EXCLUDED_DBS = {'borra', 'sentinel'}

def fix_domain_name(s):
    """Fix double-encoded names: some were stored as UTF-8 bytes interpreted as Latin-1."""
    if not s: return ''
    try:
        return s.encode('latin-1').decode('utf-8')
    except (UnicodeDecodeError, UnicodeEncodeError):
        return s   # already correctly encoded

for row in conn.execute("SELECT id, db, name FROM domains ORDER BY id"):
    did  = row['id']
    db   = row['db']
    name = fix_domain_name(row['name'] or '')
    label = f"{did} {name}"
    DB_TO_DOMAIN[db] = {'id': did, 'label': label, 'name': name}

# Extender con BDs secundarias desde sps (e.g. bdiburo→D03, bdinvers→D04).
# La tabla domains solo tiene la BD canónica; sps tiene todas.
# Esto permite que el paso 4 (fix dominio labels) resuelva las 957 reglas con nombre crudo.
domain_by_id = {v['id']: v for v in DB_TO_DOMAIN.values()}
secondary_count = 0
for row in conn.execute(
        "SELECT DISTINCT db, domain FROM sps WHERE domain IS NOT NULL AND domain <> ''"):
    sec_db, did = row['db'], row['domain']
    if sec_db not in DB_TO_DOMAIN and did in domain_by_id:
        DB_TO_DOMAIN[sec_db] = domain_by_id[did]
        secondary_count += 1

conn.close()
print(f"Domain map loaded: {len(DB_TO_DOMAIN)} entries ({len(DB_TO_DOMAIN)-secondary_count} canonical + {secondary_count} secondary)")

# ── 2. Load current rules ─────────────────────────────────────────────────────
src_data = json.load(open(BASE + 'portal/data/business-rules-v2.json', encoding='utf-8'))
rules = src_data['rules']
print(f"Loaded rules: {len(rules)}")

# Shared mutable counter for new rule IDs — persists across all extract_from_db calls
existing_ids = {r['id'] for r in rules}
max_num = max((int(re.search(r'\d+', rid).group()) for rid in existing_ids
               if re.search(r'\d+', rid)), default=7784)
_counter = [max_num]   # list so inner functions can mutate it without nonlocal

# ── 3. Extract rules from missing DBs ────────────────────────────────────────
inv = json.load(open(BASE + "knowledge-base/vocabulary-inventory.json", encoding="utf-8"))
VOCAB = {}
for section in ("atomos", "compuestos"):
    for item in inv.get(section, []):
        VOCAB[item["term"]] = item
VOCAB_SET = set(VOCAB.keys())
BC_TERMS = {t: (v.get("bc",""), v.get("bc_name",""))
            for t, v in VOCAB.items()
            if v.get("bc","") not in ("—","-","",None)}
print(f"Vocabulary loaded: {len(VOCAB_SET)} terms, {len(BC_TERMS)} BC-tagged")

def detect_vocab_refs(code_lower):
    return [t for t in VOCAB_SET if len(t) >= 4 and re.search(r'\b'+re.escape(t)+r'\b', code_lower)][:8]

def tag_bc(vocab_refs):
    for t in vocab_refs:
        if t in BC_TERMS: return BC_TERMS[t]
    return ("", "")

RE_CREATE = re.compile(r"create\s+(?:procedure|function)\b", re.I)
RE_FORMULA = re.compile(r"\b(?:let|set)\s+([a-z_][a-z0-9_]*)\s*=\s*(.+)", re.I)
RE_BOILERPLATE = re.compile(r"codret\s*=\s*['\"]0+['\"]", re.I)
RE_RAISE = re.compile(
    r"raise\s+exception"
    r"|retornar\s+['\"]?\d{3,}"
    r"|v_codret\s*[<>]+\s*['\"]"
    r"|return\s+['\"]?\d{3,}"                              # 3+ digits (was 4+)
    r"|codret\s*=\s*['\"][1-9A-Z][A-Z0-9]{1,}['\"]"       # original (shorter min)
    # Extended: broader codret variable naming — v_codret=, cCodRet=, cod_ret=, vCodRet=
    r"|\blet\s+\w*cod[_]?ret\w*\s*=\s*"
        r"(?:sql_err|isam_err|sqlErr|iSqlErr|iSamErr"      # assigned from sql error variable
        r"|['\"](?!0+['\"])[^'\"]+['\"])",                 # or non-all-zero string literal
    re.I
)
# Single-line IF condition tracker (for context in validation rules)
RE_IF_COND = re.compile(r'^\s*IF\s+(?P<cond>.+?)\s+THEN\s*$', re.I)
# Date/temporal comparisons that represent business expiry/threshold rules
RE_IF_DATECMP = re.compile(r'\b\w+\s*(?:<=|>=)\s*(?:current|today|now)\b', re.I)
# SQL error variable names — used to filter boilerplate exception handlers
RE_SQL_ERR_VAR = re.compile(r'\b(?:sql_err|isam_err|sqlerr|isamerr|sqlErr|iSqlErr)\b', re.I)
FIN_PAT_RE = re.compile(
    r"\b(int|isr|tasa|monto|saldo|comis|iva|cuota|dias|importe|capital|rendim|gat|cat|"
    r"sdo|abono|cargo|mora|interes|reserva|provision|tir|van|pago)\b", re.I)

def riesgo_equiv(expr):
    r = []
    if re.search(r"/\s*360\b", expr): r.append("base 360 (año comercial) — verificar vs 365")
    if re.search(r"/\s*365\b", expr): r.append("base 365 — verificar vs 360")
    if "trunc" in expr.lower():       r.append("TRUNC — Informix trunca; PostgreSQL puede redondear")
    if re.search(r"\bround\b", expr.lower()): r.append("ROUND — validar modo (banker's vs half-up)")
    if "money" in expr.lower():       r.append("MONEY — banker's rounding Informix; NUMERIC PostgreSQL diverge")
    return r

def extract_from_db(db):
    """Extract financial formulas, validations and conditions.
    Uses shared _counter for unique IDs.
    Extended (Layer A+ v2) to handle broader codret naming conventions and
    IF-condition context tracking for operational/administrative databases.
    """
    new = []
    domain_label = DB_TO_DOMAIN.get(db, {}).get('label', db)
    files = sorted(f for f in os.listdir(SRC) if f.startswith(db+'_') and f.endswith('.sql'))
    for fname in files:
        sp = fname.replace('.sql','').replace(db+'_','',1)
        try:
            text = open(SRC+fname, encoding='utf-8', errors='replace').read()
        except Exception:
            continue
        ms = list(RE_CREATE.finditer(text))
        body = text[ms[0].start():ms[1].start()] if len(ms)>=2 else text
        prev_if = None  # (lineno, condition_text) of the most recent non-boilerplate IF
        for lineno, line in enumerate(body.split('\n'), 1):
            ls = line.strip()
            if not ls or ls.startswith('--'): continue
            lo = ls.lower()

            # Track IF conditions for better rule descriptions
            m_if = RE_IF_COND.match(ls)
            if m_if:
                cond = m_if.group('cond')
                if RE_SQL_ERR_VAR.search(cond):
                    # Exception-handling boilerplate — don't track as business rule context
                    prev_if = None
                else:
                    prev_if = (lineno, ls)
                    # Date/temporal comparison = standalone business rule (e.g. expiry check)
                    if RE_IF_DATECMP.search(cond):
                        vrefs = detect_vocab_refs(lo)
                        bc, bc_name = tag_bc(vrefs)
                        _counter[0] += 1
                        new.append({'id': f'BR-V3-{_counter[0]:04d}', 'tipo': 'CONDICIÓN',
                            'sp': f'{db}:{sp}', 'db': db, 'line': lineno, 'code': ls[:200],
                            'reg': '', 'riesgo': [], 'bc': bc, 'bc_name': bc_name,
                            'vocab_refs': vrefs, 'dominio': domain_label,
                            'categoria': 'OPERACIONAL', 'explicacion': '', 'expl_conf': '?',
                            'sp_rel': [], 'vocab_detail': {}})
                continue
            if re.match(r'^\s*(END\s+IF|ELSE\b)', ls, re.I):
                prev_if = None
                continue

            # FORMULA
            m = RE_FORMULA.match(ls)
            if m and FIN_PAT_RE.search(lo) and not RE_BOILERPLATE.search(lo):
                vrefs = detect_vocab_refs(lo)
                bc, bc_name = tag_bc(vrefs)
                _counter[0] += 1
                new.append({'id': f'BR-V3-{_counter[0]:04d}', 'tipo': 'FÓRMULA',
                    'sp': f'{db}:{sp}', 'db': db, 'line': lineno, 'code': ls[:200],
                    'reg': '', 'riesgo': riesgo_equiv(ls), 'bc': bc, 'bc_name': bc_name,
                    'vocab_refs': vrefs, 'dominio': domain_label,
                    'categoria': 'CALCULO_FINANCIERO', 'explicacion': '', 'expl_conf': '?',
                    'sp_rel': [], 'vocab_detail': {}})
            # VALIDATION — use IF condition as code when inside an IF block
            elif RE_RAISE.search(ls) and not RE_BOILERPLATE.search(lo):
                rule_code = prev_if[1] if prev_if else ls
                rule_line = prev_if[0] if prev_if else lineno
                vrefs = detect_vocab_refs(rule_code.lower())
                bc, bc_name = tag_bc(vrefs)
                _counter[0] += 1
                new.append({'id': f'BR-V3-{_counter[0]:04d}', 'tipo': 'VALIDACIÓN',
                    'sp': f'{db}:{sp}', 'db': db, 'line': rule_line, 'code': rule_code[:200],
                    'reg': '', 'riesgo': [], 'bc': bc, 'bc_name': bc_name,
                    'vocab_refs': vrefs, 'dominio': domain_label,
                    'categoria': 'OPERACIONAL', 'explicacion': '', 'expl_conf': '?',
                    'sp_rel': [], 'vocab_detail': {}})
    return new

current_dbs = {r['db'] for r in rules}
MISSING_DBS = [db for db in DB_TO_DOMAIN
               if db not in EXCLUDED_DBS and db not in current_dbs
               and any(f.startswith(db+'_') and f.endswith('.sql') for f in os.listdir(SRC))]
print(f"Missing DBs to extract: {MISSING_DBS}")

new_rules = []
for db in MISSING_DBS:
    extracted = extract_from_db(db)
    new_rules.extend(extracted)
    print(f"  {db}: +{len(extracted)} rules")

rules.extend(new_rules)
print(f"Rules after adding missing DBs: {len(rules)}")

# ── 4. Fix dominio labels for all rules ──────────────────────────────────────
fixed = 0
for r in rules:
    db = r.get('db','')
    dom = r.get('dominio','') or ''
    if db in DB_TO_DOMAIN:
        canonical = DB_TO_DOMAIN[db]['label']
        if dom != canonical:
            r['dominio'] = canonical
            fixed += 1
print(f"Dominio labels fixed: {fixed}")

# ── 5. Add business_name ─────────────────────────────────────────────────────
ACTION_MAP = {
    'calc': 'Cálculo de', 'calcula': 'Cálculo de', 'calcular': 'Cálculo de',
    'valida': 'Validación', 'validar': 'Validación', 'validacion': 'Validación',
    'genera': 'Generación', 'generar': 'Generación',
    'obtiene': 'Consulta', 'obtener': 'Consulta', 'obt': 'Consulta',
    'actualiza': 'Actualización', 'actualizar': 'Actualización', 'upd': 'Actualización',
    'inserta': 'Registro', 'ins': 'Registro',
    'elimina': 'Eliminación', 'borra_': 'Eliminación',
    'procesa': 'Proceso', 'aplica': 'Aplicación',
    'cobra': 'Cobro', 'cobrar': 'Cobro',
    'crea': 'Creación', 'crear': 'Creación',
    'consulta': 'Consulta', 'graba': 'Registro', 'guarda': 'Registro',
    'carga': 'Carga', 'envía': 'Envío', 'envia': 'Envío',
    'notifica': 'Notificación', 'registra': 'Registro',
    'rep': 'Reporte de', 'reporte': 'Reporte de',
    'batch': 'Proceso batch', 'conciliar': 'Conciliación de', 'concilia': 'Conciliación de',
    'conciladm': 'Conciliación ADM', 'concilatm': 'Conciliación ATM',
}
TIPO_PREFIX = {'FÓRMULA':'Fórmula', 'VALIDACIÓN':'Validación',
               'UMBRAL':'Umbral de', 'ESTADO':'Transición de estado'}
_GARBAGE_RE   = re.compile(r'\|---|">|</|https?://|\*{5,}', re.I)
_CODE_FUNC_RE = re.compile(r'\b(round|trunc|pow|nvl|isnull|substr|length|mod|abs)\s*\(', re.I)
# Detectores de texto que ES código, no descripción de negocio
_SQL_STMT_RE  = re.compile(
    r'^(INSERT\s+INTO|SELECT\s|UPDATE\s+\w|DELETE\s+FROM'
    r'|LET\s+\w+\s*=|EXECUTE\s+PROCEDURE|EXECUTE\s+FUNCTION|CALL\s+'
    r'|FOREACH\s|OPEN\s+\w|CLOSE\s+\w|FETCH\s+\w'
    r'|LOAD\s+FROM|UNLOAD\s+TO|LOAD\s+\w+\s+FROM'
    r'|WHERE\s+\w|AND\s+\(|OR\s+\('
    r'|FROM\s+\w+:\w+'
    r'|IF\s*\('
    r'|ORDER\s+BY\s+'
    r'|NR\s*==\s*FNR)', re.I)
_UNIX_CMD_RE  = re.compile(
    r'^(chmod|chown|rm\s|mv\s|cp\s|mkdir|touch|ln\s|cat\s|grep\s|'
    r'sed\s|awk\s|echo\s|sh\s|bash\s|perl\s|python\s|export\s|'
    r'dbaccess\s|dbload\s|oncheck\s|dbschema\s)', re.I)
_FILEPATH_RE  = re.compile(r'[/\\][a-z0-9_\-]+[/\\]', re.I)   # /word/word/ path segment
_FILENAME_RE  = re.compile(r'^\S+\.(sql|txt|unl|sh|csv|dat|log|html|xml|json|py)$', re.I)
_DATE_LIT_RE  = re.compile(r'^\d{1,2}/\d{1,2}/\d{4}')          # 01/08/2022
_DATE_ES_RE   = re.compile(r'^\d{1,2}/(ene|feb|mar|abr|may|jun|jul|ago|sep|oct|nov|dic)/\d{2,4}', re.I)
_DATE_NUM_RE  = re.compile(r'^\d{8}$')                           # 20191024
_DATE_FMT_RE  = re.compile(r'\b(dd/mm|aaaa|yyyy|hh:mm)\b', re.I) # formato dd/mm/aaaa
_NUM_ONLY_RE  = re.compile(r'^\d[\d\s,%\.]+$')                   # 42.67 % ó 1,234.56
_SHELL_OP_RE  = re.compile(r'^[>\|<&!+]')                        # > < | & ! +
_DECOR_RE     = re.compile(r'^[#=\-\*\s]{5,}$')                  # ##### === ------
# Regex para comentario inline SPL: `expr; -- descripcion`
_INLINE_CMT   = re.compile(r';\s*--\s+(.{6,})')

def first_clause(text):
    """Extrae la primera cláusula significativa de una explicación."""
    if not text:
        return ''
    t = text.strip()
    # Rechaza decoradores: ###... ===... ---...
    if _DECOR_RE.match(t):
        return ''
    # Rechaza sentencias SQL/SPL directas
    if _SQL_STMT_RE.match(t):
        return ''
    # Rechaza fechas literales dd/mm/yyyy y numéricas YYYYMMDD
    if _DATE_LIT_RE.match(t) or _DATE_NUM_RE.match(t):
        return ''
    # Rechaza listas de columnas pipe-separated (2+ pipes = encabezados de reporte)
    if t.count('|') >= 2:
        return ''
    if _GARBAGE_RE.search(t):
        return ''
    # Rechaza operadores shell al inicio: > < | & !
    if _SHELL_OP_RE.match(t):
        return ''
    # Rechaza comandos Unix: chmod, rm, mv, cp, mkdir...
    if _UNIX_CMD_RE.match(t):
        return ''
    # Rechaza rutas de archivo Unix/Windows: /resplogifx/word/ o C:\path\
    if _FILEPATH_RE.search(t):
        return ''
    # Rechaza nombres de archivo solos: encabezado.txt, query.sql
    if _FILENAME_RE.match(t):
        return ''
    # Rechaza fragmentos de shell UNLOAD: "nombre.unl >" o "nombre.unl >>" (redirect operador)
    if re.search(r'\.(unl|sql|dat)\s*>{1,2}', t, re.I):
        return ''
    # Rechaza fechas en español: 14/dic/95
    if _DATE_ES_RE.match(t):
        return ''
    # Rechaza cadenas de formato de fecha: dd/mm/aaaa
    if _DATE_FMT_RE.search(t):
        return ''
    # Rechaza números/porcentajes solos: 42.67 %
    if _NUM_ONLY_RE.match(t):
        return ''
    # Rechaza literales SQL: 'valor', '1900-01-01', etc.
    if t.startswith("'"):
        return ''
    # Rechaza fragmentos SQL embebidos: "... update db:table set" o "... where x ="
    if re.search(r'\b(UPDATE\s+\w+:\w+|WHERE\s+\w+\s*=)', t, re.I):
        return ''
    # Rechaza expresiones de variables SPL: (var_name + var_name), (var * 0.15)
    if t.startswith('(') and '_' in t:
        return ''
    # Texto entre paréntesis sin código → quita los paréntesis externos
    if t.startswith('(') and t.endswith(')') and '_' not in t:
        t = t[1:-1].strip()
    # Rechaza llamadas a funciones matemáticas SPL (round, trunc, pow…)
    if _CODE_FUNC_RE.search(t):
        return ''
    # Limpia prefijos hash inline: "# texto útil" → "texto útil"
    t = re.sub(r'^#+\s*', '', t).strip()
    if not t:
        return ''
    # Limpia prefijos de variable SPL: "v_nombre = descripcion" o "v_nombre descripcion" → "descripcion"
    m_var = re.match(r'^[vVcCnNlLdD]_\w+\s*=?\s+(.{4,})', t)
    if m_var:
        t = m_var.group(1).strip()
    if not t:
        return ''
    # Quita guiones/iguales al inicio (1+): "-texto", "------texto", "- // texto" → "texto"
    t = re.sub(r'^[-=]+\s*', '', t).strip()
    # Quita marcadores de comentario y decoradores líderes: //, -*, --, *, * (1-4 asteriscos)
    t = re.sub(r'^(//\s*|-\*\s*|\*{1,4}\s*)', '', t).strip()
    # Quita asteriscos decorativos finales: "texto *" o "texto ****"
    t = re.sub(r'\s*\*+\s*$', '', t).strip()
    if not t:
        return ''
    # Quita prefijos regulatorios tipo "LISR Art.54/135 — " o "CNBV CUB B-5 — "
    t = re.sub(r'^[A-ZÁÉÍÓÚ][A-ZÁÉÍÓÚa-záéíóú0-9/\.\s]+\s[—–]\s', '', t).strip()
    # Corta antes de punto, punto y coma, o guión largo
    for sep in (' — ', ' – ', '; ', '. '):
        if sep in t:
            t = t.split(sep)[0].strip()
    # Corta en 65 chars sin cortar palabras
    if len(t) > 65:
        cut = t[:65].rsplit(' ', 1)[0]
        t = cut + '…'
    return t.strip() if t else ''

def sp_to_name(sp_full, tipo):
    sp = sp_full.split(':')[-1] if ':' in sp_full else sp_full
    sp = re.sub(r'^(sp_|arr_|bdi_)', '', sp)
    words = sp.replace('_', ' ').split()
    if not words:
        return TIPO_PREFIX.get(tipo, tipo)
    first = words[0].lower()
    rest  = ' '.join(words[1:]) if len(words) > 1 else ''
    if first in ACTION_MAP:
        label = f"{ACTION_MAP[first]} {rest}".strip()
    else:
        prefix = TIPO_PREFIX.get(tipo, '')
        label = f"{prefix}: {sp.replace('_',' ')}".strip() if prefix else sp.replace('_',' ')
    return label[:65]

def code_to_hint(code, sp_full, tipo):
    """Extrae pista de negocio del código SPL cuando explicacion es código o está vacía."""
    if not code:
        return sp_to_name(sp_full, tipo)
    code_s = code.strip()
    # 1. Comentario inline al final de la sentencia: expr; -- descripcion
    m = _INLINE_CMT.search(code_s)
    if m:
        hint = m.group(1).strip()
        # Validar que el comentario no sea otro decorador
        if not _DECOR_RE.match(hint) and not _SQL_STMT_RE.match(hint):
            cleaned = first_clause(hint)
            if cleaned:
                return cleaned
    # 2. RETURN "CODE"; -- descripcion
    m = re.match(r'RETURN\s+"(\w+)"\s*;', code_s, re.I)
    if m:
        ret_code = m.group(1)
        sp_label = sp_to_name(sp_full, tipo)
        return f"{sp_label} — retorno {ret_code}"[:65]
    # 3. Fallback: SP name en lenguaje de negocio
    return sp_to_name(sp_full, tipo)

named = 0
for r in rules:
    expl = (r.get('explicacion') or '').strip()
    # Intentar primero con explicacion; si es vacía o código, usar código + SP
    name = first_clause(expl) if expl else ''
    if not name:
        name = code_to_hint(r.get('code', ''), r.get('sp', ''), r.get('tipo', ''))
    # Capitalize first letter
    r['business_name'] = name[0].upper() + name[1:] if name else ''
    if r['business_name']:
        named += 1

print(f"business_name added: {named} / {len(rules)}")

# ── 5b. Apply Layer B+ overrides (name-overrides-ai.json) ────────────────────
_overrides_path = BASE + 'knowledge-base/rules/name-overrides-ai.json'
try:
    ov_raw = json.load(open(_overrides_path, encoding='utf-8'))
    ov_names = ov_raw.get('names', ov_raw) if isinstance(ov_raw, dict) else {}
    ov_applied = 0
    rules_idx = {r['id']: r for r in rules}
    for rule_id, better_name in ov_names.items():
        r = rules_idx.get(rule_id)
        if r and better_name and better_name.strip():
            r['business_name'] = better_name.strip()
            ov_applied += 1
    print(f"Layer B+ overlay: {ov_applied} / {len(ov_names)} overrides applied")
except FileNotFoundError:
    print(f"Layer B+ overrides not found at {_overrides_path}, skipping")

# ── 6. Stats ──────────────────────────────────────────────────────────────────
by_tipo = {}
by_cat  = {}
by_dom  = {}
by_reg  = {}
for r in rules:
    for k, d in [('tipo',by_tipo),('categoria',by_cat),('dominio',by_dom),('reg',by_reg)]:
        v = r.get(k,'?') or '?'
        if isinstance(v, list): v = ','.join(str(x) for x in v) if v else '—'
        d[v] = d.get(v,0) + 1

# ── 6b. Overlay SBVR v1 enrichment (reg manual + riesgo) ────────────────────
v1_path = BASE + 'portal/data/business-rules.json'
try:
    with open(v1_path, encoding='utf-8') as fv1:
        v1_rules = json.load(fv1).get('rules', [])
    v1_idx = {(r['sp'], r['db'], r['line']): r for r in v1_rules}
    reg_applied = riesgo_applied = 0
    for r in rules:
        key = (r['sp'], r['db'], r['line'])
        v1 = v1_idx.get(key)
        if not v1:
            continue
        if v1.get('reg'):                     # reg manual prevalece sobre auto-extraído
            r['reg'] = v1['reg']
            reg_applied += 1
        if v1.get('riesgo') and not r.get('riesgo'):
            r['riesgo'] = v1['riesgo']
            riesgo_applied += 1
    print(f"SBVR v1 overlay: {reg_applied} reg + {riesgo_applied} riesgo applied "
          f"({len(v1_rules)} v1 rules, {len(v1_idx)} indexed)")
except FileNotFoundError:
    print(f"SBVR v1 not found at {v1_path}, skipping overlay")

# ── 6c. Deduplicar reglas (mismo sp+db+line → conservar primero) ─────────────
seen_keys = set()
deduped = []
dup_count = 0
for r in rules:
    key = (r['sp'], r['db'], r['line'])
    if key in seen_keys:
        dup_count += 1
    else:
        seen_keys.add(key)
        deduped.append(r)
if dup_count:
    print(f"Deduplication: removed {dup_count} duplicate(s) → {len(deduped)} rules")
rules = deduped
named = sum(1 for r in rules if r.get('business_name'))

# ── 7. Save v3 JSON ───────────────────────────────────────────────────────────
out = {
    'meta': {
        'version': '3.0',
        'generated': datetime.date.today().isoformat(),
        'tool': 'enrich-rules-v3.py',
        'sp_scanned': src_data['meta'].get('sp_scanned', 12832),
        'total': len(rules),
        'enriched': datetime.date.today().isoformat(),
        'layer': 'A+',
        'business_name_coverage': named,
    },
    'rules': rules,
    'stats': {
        'by_tipo': dict(sorted(by_tipo.items(), key=lambda x:-x[1])),
        'by_cat':  dict(sorted(by_cat.items(),  key=lambda x:-x[1])),
        'by_reg':  dict(sorted(by_reg.items(),  key=lambda x:-x[1])),
        'by_dom':  dict(sorted(by_dom.items(),  key=lambda x:x[0])),
    },
}
out_json = BASE + 'portal/data/business-rules-v3.json'
json.dump(out, open(out_json, 'w', encoding='utf-8'), ensure_ascii=False, separators=(',',':'))
print(f"Saved: {out_json}  ({os.path.getsize(out_json):,} bytes)")

# ── 8. Update MD report ───────────────────────────────────────────────────────
has_name = sum(1 for r in rules if r.get('business_name'))
has_expl = sum(1 for r in rules if r.get('explicacion') and len(r['explicacion']) > 10)
has_riesgo = sum(1 for r in rules if r.get('riesgo') and r['riesgo'])

md = f"""# BCOPCore · Catálogo de Reglas de Negocio — v3.0 (Layer A+)

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Enrichment Layer A+
> **Generado:** 2026-08-06 · `enrich-rules-v3.py` · {len(rules):,} reglas · {has_name:,} con nombre natural · {has_expl:,} con explicación
> **Cobertura:** D01-D53 (todos los dominios) · {len(DB_TO_DOMAIN)-2} bases de datos activas
> **Fuente primaria:** `business-rules-v3.json` (v3.0, Layer A+)

## Resumen ejecutivo

| Tipo | Reglas |
|----|---:|
"""
for tipo, cnt in sorted(by_tipo.items(), key=lambda x:-x[1]):
    md += f"| {tipo} | {cnt:,} |\n"
md += f"| **TOTAL** | **{len(rules):,}** |\n\n"

md += "| Dimensión | Valor |\n|---|---|\n"
md += f"| Reglas con nombre natural (business_name) | {has_name:,} |\n"
md += f"| Reglas con explicación | {has_expl:,} |\n"
md += f"| Reglas con riesgo de equivalencia | {has_riesgo:,} |\n"
md += f"| Dominios cubiertos | {len(set(r.get('dominio','') for r in rules if r.get('dominio')))} |\n\n"

md += "## Por categoría\n\n| Categoría | Reglas |\n|---|---:|\n"
for cat, cnt in sorted(by_cat.items(), key=lambda x:-x[1]):
    md += f"| {cat} | {cnt:,} |\n"

md += "\n## Por regulador\n\n| Regulador | Reglas |\n|---|---:|\n"
for reg, cnt in sorted(by_reg.items(), key=lambda x:-x[1]):
    if reg and reg != '?':
        md += f"| {reg} | {cnt:,} |\n"

md += "\n## Por dominio\n\n| Dominio | Reglas |\n|---|---:|\n"
for dom, cnt in sorted(by_dom.items(), key=lambda x:x[0]):
    if dom and dom != '?':
        md += f"| {dom} | {cnt:,} |\n"

md += "\n## Reglas críticas — riesgo de equivalencia financiera\n\n"
md += "| ID | business_name | SP | Riesgo |\n|----|---|---|---|\n"
shown = 0
for r in rules:
    riesgo = r.get('riesgo') or []
    if riesgo and shown < 30:
        name = r.get('business_name','') or r.get('explicacion','')[:50]
        risks = ' · '.join(riesgo[:2]) if isinstance(riesgo, list) else str(riesgo)
        sp_short = r['sp'].split(':')[-1] if ':' in r.get('sp','') else r.get('sp','')
        md += f"| {r['id']} | {name[:55]} | `{sp_short}` | {risks[:80]} |\n"
        shown += 1

out_md = BASE + 'knowledge-base/rules/business-rules-bcop.md'
open(out_md, 'w', encoding='utf-8').write(md)
print(f"Updated MD: {out_md}")
print(f"\nDone. Total: {len(rules):,} rules · {named:,} with business_name · {has_riesgo:,} with equiv risk")
