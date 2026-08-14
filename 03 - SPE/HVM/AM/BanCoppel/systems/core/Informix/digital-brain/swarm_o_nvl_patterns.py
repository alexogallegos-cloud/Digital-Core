"""
swarm_o_nvl_patterns.py — Swarm O: Traduce patrones NVL() en business names a lenguaje natural.

Objetivo: 300 reglas donde el business_name expone sintaxis NVL() de Informix SPL.
NVL es idiomático en SPL para null-safety; se traduce al concepto de negocio que expresa.

Patrones principales:
  nvl(var,'') = ''       -> "var no fue proporcionado"
  nvl(var,'') <> ''      -> "var tiene valor"
  nvl(var,0) >= N        -> "var es al menos N"
  trim(nvl(var,'')) = '' -> igual con normalización de espacios
  nvl(v1,'') = nvl(v2,'') -> "v1 coincide con v2"
"""

import sqlite3, re, sys
from pathlib import Path
from datetime import datetime

sys.stdout.reconfigure(encoding='utf-8', errors='replace')

DB  = Path(r"C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core\03 - SPE\HVM\AM\BanCoppel\systems\core\Informix\digital-brain\brain.db")
con = sqlite3.connect(str(DB))
cur = con.cursor()
NOW = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

# ---------------------------------------------------------------------------
# Vocabulario
# ---------------------------------------------------------------------------
cur.execute("SELECT term, meaning FROM terms WHERE meaning IS NOT NULL AND meaning != '' LIMIT 2000")
VOCAB = {r[0].lower(): r[1] for r in cur.fetchall()}

TERM_MAP = {
    'numcta': 'numero de cuenta', 'numcte': 'numero de cliente',
    'cta': 'cuenta', 'cte': 'cliente', 'numcliente': 'numero de cliente',
    'empresa': 'empresa', 'sucursal': 'sucursal', 'ejecutivo': 'ejecutivo',
    'folio': 'folio', 'clave': 'clave', 'idparam': 'identificador de parametro',
    'sidparam': 'identificador de parametro', 'secuencia': 'secuencia',
    'telefonocasa': 'telefono casa', 'telefonocel': 'telefono celular',
    'telefonoofi': 'telefono oficina', 'telefonoref1': 'telefono referencia 1',
    'telefonoref2': 'telefono referencia 2', 'telefonoref3': 'telefono referencia 3',
    'numctetitular': 'numero de cuenta titular', 'numctecompara': 'numero de cuenta a comparar',
    'rfc': 'RFC', 'ctebanco': 'cuenta banco', 'tipoconsulta': 'tipo de consulta',
    'tipocambio': 'tipo de cambio', 'dolar': 'dolar',
    'ruta': 'ruta', 'nombrearch': 'nombre de archivo',
    'causa': 'causa', 'sgenerico': 'parametro generico',
    'situacion': 'situacion de cuenta', 'accion': 'accion',
    'funcion': 'funcion', 'numsolicitud': 'numero de solicitud',
    'numsol': 'numero de solicitud',
}

def var_to_term(var_raw):
    v = var_raw.strip().lower()
    v_stripped = re.sub(r'^(p_?|c_?|v_?|i_?|l_?|s_?)(?=[a-z])', '', v)
    for candidate in [v, v_stripped]:
        if candidate in VOCAB:
            dfn = VOCAB[candidate]
            return dfn.split('.')[0].split(':')[0][:60].strip()
    for candidate in [v_stripped, v]:
        if candidate in TERM_MAP:
            return TERM_MAP[candidate]
    for pat in [r'^[pcvils]{1,2}', r'^[pcvils]{1,2}_']:
        cand = re.sub(pat, '', v_stripped)
        if cand in TERM_MAP:
            return TERM_MAP[cand]
    words = re.sub(r'_', ' ', v_stripped).strip()
    words = re.sub(r'([a-z])([A-Z])', r'\1 \2', words).lower()
    return words[:50] if words else var_raw[:30]


# ---------------------------------------------------------------------------
# Traductor de una cláusula NVL simple
# ---------------------------------------------------------------------------

def translate_nvl_condition(cond_raw):
    cond = cond_raw.strip()

    # nvl(v,'') = '' or trim(nvl(v,'')) = ''
    m = re.fullmatch(
        r"(?:trim\()?nvl\(([^,)]+),\s*['\"]['\"]?\s*\)(?:\))?\s*(=|<>|!=)\s*['\"]['\"]?",
        cond, re.I)
    if m:
        var_part, op = m.group(1).strip(), m.group(2)
        term = var_to_term(var_part)
        return (term + " no fue proporcionado") if op == '=' else (term + " tiene valor")

    # nvl(v,0) op N
    m = re.fullmatch(
        r"(?:trim\()?nvl\(([^,)]+),\s*0\s*\)(?:\))?\s*(=|>=|<=|>|<|<>)\s*([0-9]+)",
        cond, re.I)
    if m:
        var_part, op, val = m.group(1).strip(), m.group(2), m.group(3)
        term = var_to_term(var_part)
        op_map = {'=': 'es', '>=': 'es al menos', '<=': 'es como maximo',
                  '>': 'es mayor que', '<': 'es menor que', '<>': 'no es'}
        return f"{term} {op_map.get(op, op)} {val}"

    # nvl(v1,'') = nvl(v2,'')
    m = re.fullmatch(
        r"(?:trim\()?nvl\(([^,)]+),\s*['\"]['\"]?\s*\)(?:\))?\s*(=|<>)\s*(?:trim\()?nvl\(([^,)]+),\s*['\"]['\"]?\s*\)(?:\))?",
        cond, re.I)
    if m:
        v1, op, v2 = m.group(1).strip(), m.group(2), m.group(3).strip()
        t1, t2 = var_to_term(v1), var_to_term(v2)
        return (f"{t1} coincide con {t2}") if op == '=' else (f"{t1} difiere de {t2}")

    return None


def translate_full_condition(cond_block):
    cond = re.sub(r'^\s*if\s+', '', cond_block.strip(), flags=re.I)
    negated = False
    m = re.match(r'^not\s*\((.+)\)$', cond, re.I)
    if m:
        cond = m.group(1).strip()
        negated = True

    parts = re.split(r'\s+(and|or)\s+', cond, flags=re.I)
    ops = re.findall(r'\s+(and|or)\s+', cond, flags=re.I)

    translated_parts = []
    ops_to_use = []
    for i, part in enumerate(parts):
        t = translate_nvl_condition(part.strip())
        if t:
            translated_parts.append(t)
            if i < len(ops):
                ops_to_use.append(ops[i])
        else:
            return None

    if not translated_parts:
        return None

    result = translated_parts[0]
    for op, part in zip(ops_to_use, translated_parts[1:]):
        connector = ' y ' if op.lower() == 'and' else ' o '
        result += connector + part

    if negated:
        result = 'no se cumple que ' + result

    return result[0].upper() + result[1:]


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
cur.execute("""
    SELECT id, business_name, code, tipo, sub_tipo
    FROM rules
    WHERE business_name LIKE '%nvl(%' OR business_name LIKE '%NVL(%'
    ORDER BY id
""")
rows = cur.fetchall()
print(f"Reglas con NVL(): {len(rows)}")

updates = []
log_rows = []
fixed = 0
skipped_formula = 0
skipped_no_pattern = 0

def inline_nvl_replace(text):
    """
    Sustituye patrones NVL() completos (incluye el operador y valor que les sigue)
    por lenguaje natural. Opera sobre el string completo de la condición.
    """
    t = re.sub(r'\s+', ' ', text.strip())
    original = t

    OP_MAP_STR = {'=': 'es', '<>': 'no es', '!=': 'no es',
                  '>=': 'es al menos', '<=': 'es maximo',
                  '>': 'mayor que', '<': 'menor que'}
    NVL_VAR = r'(?:trim\()?nvl\(\s*([a-zA-Z_][a-zA-Z0-9_.]*)\s*,\s*'
    STR_DEF = r"(?:\'[^\']*\'|\"[^\"]*\"|\'\'|\"\")"  # empty or literal string default
    NUM_DEF = r'(-?\d+)'
    CMP_STR_VAL = r'\s*(=|<>|!=)\s*(?:trim\()?(?:\'[^\']*\'|\"[^\"]*\"|\'\'|\"\")\)?'
    CMP_NUM_VAL = r'\s*(=|<>|!=|>=|<=|>|<)\s*(-?\d+)'
    END_NVL = r'\)(?:\))?'

    # Pattern 1: nvl(var,'') op ''  =>  "var tiene valor / no fue proporcionado"
    def repl_str_empty(m):
        var, op = m.group(1).strip(), m.group(2)
        term = var_to_term(var)
        return f"{term} no fue proporcionado" if op == '=' else f"{term} tiene valor"

    t = re.sub(NVL_VAR + STR_DEF + END_NVL + CMP_STR_VAL, repl_str_empty, t, flags=re.I)

    # Pattern 2: nvl(var, 0) op N  =>  "var es al menos N"
    def repl_num(m):
        var, op, val = m.group(1).strip(), m.group(2), m.group(3)
        term = var_to_term(var)
        if op in ('=', '<>') and val in ('0', '-1'):
            return f"{term} no fue proporcionado" if op == '=' else f"{term} tiene valor"
        return f"{term} {OP_MAP_STR.get(op, op)} {val}"

    t = re.sub(NVL_VAR + NUM_DEF + END_NVL + CMP_NUM_VAL, repl_num, t, flags=re.I)

    # Pattern 3: nvl(v1,'') op nvl(v2,'')  =>  "v1 coincide con v2"
    def repl_cross(m):
        v1, op, v2 = m.group(1).strip(), m.group(2), m.group(3).strip()
        t1, t2 = var_to_term(v1), var_to_term(v2)
        return f"{t1} coincide con {t2}" if op == '=' else f"{t1} difiere de {t2}"

    t = re.sub(
        NVL_VAR + STR_DEF + END_NVL + r'\s*(=|<>)\s*' + NVL_VAR + STR_DEF + END_NVL,
        repl_cross, t, flags=re.I)

    # Pattern 4: nvl(var, 'specific_literal') op 'literal'
    def repl_str_val(m):
        var, dflt, op, val = m.group(1).strip(), m.group(2), m.group(3), m.group(4).strip("'\"")
        term = var_to_term(var)
        if op in ('=', '<>'):
            return f"{term} es '{val}'" if op == '=' else f"{term} no es '{val}'"
        return f"{term} {OP_MAP_STR.get(op, op)} '{val}'"

    t = re.sub(
        NVL_VAR + r"(\'[^\']*\'|\"[^\"]*\")" + END_NVL + r"\s*(=|<>|!=)\s*(\'[^\']*\'|\"[^\"]*\")",
        repl_str_val, t, flags=re.I)

    # Strip residual SPL keywords
    t = re.sub(r'\bif\b\s*', '', t, flags=re.I)
    t = re.sub(r'\bnot\s*\(', 'no aplica cuando (', t, flags=re.I)
    t = re.sub(r'\bor\b', 'o', t, flags=re.I)
    t = re.sub(r'\band\b', 'y', t, flags=re.I)
    t = re.sub(r'\s+', ' ', t).strip()
    t = re.sub(r'^[oy]\s+', '', t).strip()
    t = re.sub(r'\s+[oy]$', '', t).strip()

    return t if t != original and 'nvl(' not in t.lower() else None


for id, bn, code, tipo, sub_tipo in rows:
    # Skip FÓRMULA — NVL forma parte del cálculo, no de una condición
    if 'RMULA' in (tipo or '') or 'LCULO' in (sub_tipo or ''):
        skipped_formula += 1
        continue

    if ':' not in (bn or ''):
        skipped_no_pattern += 1
        continue

    colon_idx = bn.index(':')
    subject = bn[:colon_idx].strip()
    cond_raw = bn[colon_idx+1:].strip()

    # Intento 1: traducción holística (AND/OR simple)
    translated = translate_full_condition(cond_raw)
    if not translated:
        # Intento 2: sustitución inline token-level
        translated = inline_nvl_replace(cond_raw)

    if not translated or translated == cond_raw:
        skipped_no_pattern += 1
        continue

    # Capitalizar primera letra
    translated = translated[0].upper() + translated[1:]
    new_bn = f"{subject}: {translated}"
    if new_bn == bn:
        continue

    updates.append((new_bn, id))
    log_rows.append((id, 'swarm_o_nvl_patterns', 'business_name', bn, new_bn,
                     NOW, 0.80, 'nvl_pattern_translation', ''))
    fixed += 1

print(f"Fixed: {fixed}")
print(f"Skipped FORMULA: {skipped_formula}")
print(f"Skipped (no clean pattern): {skipped_no_pattern}")

print("\nPREVIEW (15 primeras):")
for new_bn, id in updates[:15]:
    old = next(r[1] for r in rows if r[0] == id)
    print(f"\n  {id}")
    print(f"  OLD: {old[:120]}")
    print(f"  NEW: {new_bn[:120]}")

if fixed > 0:
    cur.executemany("UPDATE rules SET business_name=? WHERE id=?", updates)
    cur.executemany("""
        INSERT INTO rule_enrichment_log
          (rule_id,swarm,field,old_value,new_value,timestamp,confidence,method,notes)
        VALUES (?,?,?,?,?,?,?,?,?)
    """, log_rows)
    try:
        cur.execute("INSERT INTO rules_fts(rules_fts) VALUES('rebuild')")
    except Exception:
        pass
    con.commit()
    print(f"\n✓ {fixed} reglas actualizadas en brain.db")
else:
    print("\nNada que actualizar.")

con.close()
