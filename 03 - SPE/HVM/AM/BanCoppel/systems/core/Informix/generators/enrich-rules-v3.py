#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
enrich-rules-v3.py — Layer A+ enrichment para reglas de negocio Informix.

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
        "03 - SPE/HVM/AM/BanCoppel/systems/core/Informix/")
SRC  = BASE + "source/informix/"

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

            # FORMULA — excluir asignaciones de string literal (paths, comandos shell)
            # ADR-SPE-AM-010: el término financiero debe estar en la expresión RHS,
            # no en un string literal de ruta como '/resplogifx/abono/...'
            m = RE_FORMULA.match(ls)
            _rhs = m.group(2).strip() if m else ""
            if (m and FIN_PAT_RE.search(_rhs) and not RE_BOILERPLATE.search(lo)
                    and not _rhs.startswith(("'", '"'))):
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

# ── 5. business_name — ADR-SPE-AM-010 ────────────────────────────────────────
# El extractor NUNCA genera business_name. La síntesis LLM es la única fuente.
# Ver: AM/adr/ADR-SPE-AM-010-llm-synthesis-as-generation.md
for r in rules:
    r.setdefault('business_name', '')

# ── 5b. Apply Layer B+ overrides (name-overrides-ai.json) ────────────────────
# ADR-SPE-AM-010: guardia defensiva — nunca aplicar un override con firma de
# código crudo. Si un nombre parece código (÷, "Calcular vsql", "LET ...",
# snake_case puro), se descarta y la regla queda vacía para síntesis LLM.
import re as _re_ov

_BAD_OV_PREFIX = (
    "Calcular v", "Calcular cadena", "Calcular ruta", "Calcular shell",
    "Calcular descripci", "Calcular sql", "Calcular stmt", "Calcular idpais",
    "Calcular monto", "Calcular plazo", "Calcular div", "Calcular fecha",
    "Calcular valor", "Calcular bill", "Calcular vbill",
    "Cálculo con umbral", "Calculo con umbral",
    "Fórmula:", "Formula:", "And num_", "LET ", "let ", "RAISE ", "RETURN ",
)

def _override_is_bad(v: str) -> bool:
    v = (v or "").strip()
    if not v or "÷" in v:
        return True
    if v.startswith(_BAD_OV_PREFIX):
        return True
    if _re_ov.fullmatch(r"[a-z0-9_]+", v) and "_" in v:      # identificador de código puro
        return True
    if _re_ov.search(r"\((multiplicaci[óo]n|divisi[óo]n|suma|resta)\)\s*$", v, _re_ov.I):
        return True
    return False

_overrides_path = BASE + 'knowledge-base/rules/name-overrides-ai.json'
try:
    ov_raw = json.load(open(_overrides_path, encoding='utf-8'))
    ov_names = ov_raw.get('names', ov_raw) if isinstance(ov_raw, dict) else {}
    ov_applied = 0
    ov_skipped = 0
    rules_idx = {r['id']: r for r in rules}
    for rule_id, better_name in ov_names.items():
        r = rules_idx.get(rule_id)
        if not r or not better_name or not better_name.strip():
            continue
        if _override_is_bad(better_name):
            ov_skipped += 1
            continue
        r['business_name'] = better_name.strip()
        ov_applied += 1
    print(f"Layer B+ overlay: {ov_applied} aplicados, {ov_skipped} descartados (firma código) / {len(ov_names)} total")
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

md = f"""# Informix · Catálogo de Reglas de Negocio — v3.0 (Layer A+)

> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Enrichment Layer A+
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
