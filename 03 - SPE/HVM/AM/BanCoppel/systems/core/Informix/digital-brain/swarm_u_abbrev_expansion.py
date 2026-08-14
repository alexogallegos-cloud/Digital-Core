"""
swarm_u_abbrev_expansion.py — Swarm U: Expansión de abreviaturas en business names.

Regla P6-ext (extensión de P6): Usar vocabulario humano completo, sin abreviaturas
internas del sistema ni del código SPL.

Mapa de expansiones en orden de aplicación (compuestos primero, simples después):
Las expansiones se aplican word-boundary (\\b), case-insensitive donde aplique.
"""

import sqlite3, re, sys
from pathlib import Path
from datetime import datetime

sys.stdout.reconfigure(encoding='utf-8', errors='replace')

DB  = Path(r"C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core\03 - SPE\HVM\AM\BanCoppel\systems\core\Informix\digital-brain\brain.db")
con = sqlite3.connect(str(DB))
cur = con.cursor()
NOW = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

# ─────────────────────────────────────────────────────────────────────────────
# Mapa de expansiones — compuestos primero (más específicos → menos riesgo de colisión)
# Formato: (pattern, replacement, descripción)
# ─────────────────────────────────────────────────────────────────────────────
EXPANSIONS = [
    # 1. Formas compuestas BanCoppel (máxima confianza)
    (re.compile(r'\bctemovil\b', re.I),  'cliente (canal móvil)',    'ctemovil→cliente canal móvil'),
    (re.compile(r'\bctamovil\b', re.I),  'cuenta móvil',            'ctamovil→cuenta móvil'),
    (re.compile(r'\bctemoral\b', re.I),  'cuenta persona moral',    'ctemoral→cuenta persona moral'),
    (re.compile(r'\bctamoral\b', re.I),  'cuenta persona moral',    'ctamoral→cuenta persona moral'),
    (re.compile(r'\bctamec\b',   re.I),  'Cuenta Mecánica',         'ctamec→Cuenta Mecánica'),

    # 2. Normalizar "mc — mesa de control" → "Mesa de Control" (colapsar redundancia Swarm T)
    (re.compile(r'\bmc\s*—\s*mesa de control\b', re.I), 'Mesa de Control',
     'mc—mesa de control→Mesa de Control'),

    # 3. Abreviaturas simples (word boundary, case-insensitive)
    (re.compile(r'\bcta\b', re.I),   'cuenta',           'cta→cuenta'),
    (re.compile(r'\bcte\b', re.I),   'cliente',          'cte→cliente'),
    (re.compile(r'\bmc\b',  re.I),   'Mesa de Control',  'mc→Mesa de Control'),
    (re.compile(r'\bsdo\b', re.I),   'saldo',            'sdo→saldo'),
    (re.compile(r'\bvenc\b',re.I),   'vencido',          'venc→vencido'),
    (re.compile(r'\bnum\b', re.I),   'número',           'num→número'),
    (re.compile(r'\bsol\b', re.I),   'solicitud',        'sol→solicitud'),
    (re.compile(r'\bmov\b', re.I),   'movimiento',       'mov→movimiento'),
    (re.compile(r'\barch\b',re.I),   'archivo',          'arch→archivo'),
    (re.compile(r'\bref\b', re.I),   'referencia',       'ref→referencia'),
    (re.compile(r'\bemp\b', re.I),   'empresa',          'emp→empresa'),
    (re.compile(r'\bsuc\b', re.I),   'sucursal',         'suc→sucursal'),
    (re.compile(r'\bcred\b',re.I),   'crédito',          'cred→crédito'),
    (re.compile(r'\bpag\b', re.I),   'pago',             'pag→pago'),
    (re.compile(r'\bnvo\b', re.I),   'nuevo',            'nvo→nuevo'),
    (re.compile(r'\bmens\b',re.I),   'mensual',          'mens→mensual'),
    (re.compile(r'\bsup\b', re.I),   'superior',         'sup→superior'),
    (re.compile(r'\binf\b', re.I),   'inferior',         'inf→inferior'),
    (re.compile(r'\bnro\b', re.I),   'número',           'nro→número'),
]

def apply_expansions(bn):
    """Aplica todas las expansiones al business name. Retorna (new_bn, changed_flag)."""
    result = bn
    for pat, repl, _ in EXPANSIONS:
        result = pat.sub(repl, result)
    # Normalizar espacios
    result = re.sub(r'\s+', ' ', result).strip()
    # Capitalizar primera letra si quedó en minúscula
    if result and result[0].islower():
        result = result[0].upper() + result[1:]
    return result, (result != bn)

# ─────────────────────────────────────────────────────────────────────────────
# Cargar y procesar
# ─────────────────────────────────────────────────────────────────────────────
cur.execute("SELECT id, business_name FROM rules WHERE business_name IS NOT NULL AND business_name != ''")
all_rules = cur.fetchall()

updates  = []
log_rows = []
PATCHED  = set()
counts   = {}

for rule_id, bn in all_rules:
    new_bn, changed = apply_expansions(bn)
    if not changed or rule_id in PATCHED: continue

    # Detectar qué expansiones se aplicaron para el log
    applied = [desc for pat, repl, desc in EXPANSIONS if pat.search(bn)]

    PATCHED.add(rule_id)
    updates.append((new_bn, rule_id))
    log_rows.append((rule_id, 'swarm_u', 'business_name',
                     bn, new_bn, NOW, 0.85, 'abbrev_expansion',
                     '; '.join(applied[:3])))

    for desc in applied:
        abbrev = desc.split('→')[0]
        counts[abbrev] = counts.get(abbrev, 0) + 1

# ─────────────────────────────────────────────────────────────────────────────
# Resultado
# ─────────────────────────────────────────────────────────────────────────────
total = len(updates)
print(f"Swarm U — Expansión de abreviaturas")
print(f"{'='*55}")
print(f"Total reglas a actualizar: {total}")
print("\nPor abreviatura:")
for k in sorted(counts.keys()):
    print(f"  {k}: {counts[k]}")

# Muestra
print("\nMuestra de cambios:")
for rule_id, new_bn in [(u[1], u[0]) for u in updates[:20]]:
    orig = next(bn for rid, bn in all_rules if rid == rule_id)
    print(f"  {rule_id}")
    print(f"    ANTES: {orig[:80]}")
    print(f"    AHORA: {new_bn[:80]}")
    print()

if updates:
    cur.executemany("UPDATE rules SET business_name=? WHERE id=?", updates)
    cur.executemany("""
        INSERT INTO rule_enrichment_log
          (rule_id, swarm, field, old_value, new_value, timestamp, confidence, method, notes)
        VALUES (?,?,?,?,?,?,?,?,?)
    """, log_rows)
    try:
        cur.execute("INSERT INTO rules_fts(rules_fts) VALUES('rebuild')")
    except Exception:
        pass
    con.commit()
    print(f"\n✓ {total} reglas actualizadas en brain.db")

con.close()
print("\nPipeline: rebuild_from_brain.py && build-rules-coherence.py")
