"""
rebuild_from_brain.py — Script canónico de sincronización.
Genera portal/data/rules-portal-data.json COMPLETO desde brain.db.
brain.db es la ÚNICA fuente de verdad.

Incluye:
  - Todas las reglas con id IS NOT NULL (originales BR-V2-* + Grupo B BRB-*)
  - Campos: i, n, t, st, s, db, ln, d, r, c, e, cl, gi, gc
  - Grupos por business_name (gi/gc)
  - Meta actualizado

Corre este script cada vez que se modifique brain.db para mantener el portal al día.
"""
import sqlite3, json
from pathlib import Path
from collections import Counter
import sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE  = Path(__file__).parent.parent   # .../Informix/
DB    = BASE / "digital-brain" / "brain.db"
PDATA = BASE / "portal" / "data" / "rules-portal-data.json"

con = sqlite3.connect(str(DB))
cur = con.cursor()

# Mapa tipo brain → t portal (categoría de 4 valores)
TIPO_TO_T = {
    'FÓRMULA':    'FÓRMULA',
    'VALIDACIÓN': 'VALIDACIÓN',
    'UMBRAL':     'UMBRAL',
    'ESTADO':     'ESTADO',
    'VALIDACION': 'VALIDACIÓN',  # Grupo B
    'LOGICA':     'VALIDACIÓN',  # Grupo B
    'EXCEPCION':  'VALIDACIÓN',  # Grupo B
}

print("Leyendo brain.db...")
cur.execute("""
    SELECT
        r.id, r.sp, r.db, r.line, r.tipo, r.sub_tipo,
        r.business_name, r.code, r.reg, r.domain,
        r.clase, r.compound_group_id
    FROM rules r
    WHERE r.id IS NOT NULL
    ORDER BY r.sp, r.line
""")
rows = cur.fetchall()
con.close()
print(f"  Reglas con ID: {len(rows):,}")

# Construir lista de reglas para el JSON
portal_rules = []
for row in rows:
    rid, sp, db, line, tipo, sub_tipo, bn, code, reg, domain, clase, cgid = row

    # Tipo portal (4 categorías)
    t = TIPO_TO_T.get(tipo, 'FÓRMULA')

    # Reguladores — puede ser lista JSON o string
    try:
        reg_list = json.loads(reg) if reg and reg.startswith('[') else ([reg] if reg else [])
    except:
        reg_list = [reg] if reg else []

    portal_rules.append({
        'i':  rid,
        'n':  bn or '',
        't':  t,
        'st': sub_tipo or '',
        's':  sp or '',
        'db': db or '',
        'ln': str(line or ''),
        'd':  domain or '',
        'r':  reg_list,
        'c':  code or '',
        'e':  '',       # explanation (campo manual)
        'cl': clase or '',
        'k':  [],       # risk keys (campo manual, se preserva si existe)
        'gi': 0,        # se recalcula abajo
        'gc': 1,        # se recalcula abajo
    })

# Calcular grupos por business_name
name_count = Counter(r['n'] for r in portal_rules)
name_to_gi = {}
gi_ctr = 0
for r in portal_rules:
    nm = r['n']
    if nm not in name_to_gi:
        name_to_gi[nm] = gi_ctr
        gi_ctr += 1
    r['gi'] = name_to_gi[nm]
    r['gc'] = name_count[nm]

# Meta
by_tipo  = Counter(r['t']  for r in portal_rules)
by_clase = Counter(r['cl'] for r in portal_rules)
n_negocio = by_clase.get('NEGOCIO', 0)
domains_list = sorted({r['d'] for r in portal_rules if r['d']})

# Preservar campos manuales del JSON existente (e, he, vr, bc, k, ex, rn)
MANUAL_FIELDS = ('e', 'he', 'vr', 'bc', 'k', 'ex', 'rn')
if PDATA.exists():
    try:
        old = json.loads(PDATA.read_text(encoding='utf-8'))
        old_by_id = {r['i']: r for r in old.get('rules', []) if r.get('i')}
        for r in portal_rules:
            old_r = old_by_id.get(r['i'])
            if old_r:
                for f in MANUAL_FIELDS:
                    if old_r.get(f):
                        r[f] = old_r[f]
        print(f"  Campos manuales preservados desde JSON existente")
    except Exception as ex:
        print(f"  Advertencia: no se pudo leer JSON existente: {ex}")

# Escribir
meta = {
    'total': len(portal_rules),
    'n_negocio': n_negocio,
    'n_groups': len(name_to_gi),
    'by_tipo': dict(by_tipo),
    'by_clase': dict(by_clase),
    'domains': domains_list,
}
out = {'meta': meta, 'rules': portal_rules}
PDATA.write_text(json.dumps(out, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')

print(f"\n✓ portal JSON regenerado desde brain.db:")
print(f"  Total reglas: {len(portal_rules):,}")
print(f"  Grupos únicos: {len(name_to_gi):,}")
print(f"  NEGOCIO: {n_negocio:,}")
print(f"  Por tipo: {dict(by_tipo)}")
print(f"  Por clase: {dict(by_clase)}")
print(f"\n  Archivo: {PDATA}")
