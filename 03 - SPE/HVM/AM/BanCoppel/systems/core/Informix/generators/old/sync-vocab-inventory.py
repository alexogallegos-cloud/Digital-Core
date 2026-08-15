#!/usr/bin/env python3
"""
sync-vocab-inventory.py — Sincroniza vocabulary-inventory.json con sp_vocab.py.

Añade términos que están en sp_vocab.py pero NO en vocabulary-inventory.json.
NO modifica los términos existentes. Idempotente.

Uso:
  python generators/sync-vocab-inventory.py           # aplica cambios
  python generators/sync-vocab-inventory.py --dry-run # solo reporta
"""
import json, sys, argparse
from pathlib import Path

sys.stdout.reconfigure(encoding='utf-8', errors='replace')

BASE   = Path(__file__).resolve().parent.parent
INV    = BASE / 'knowledge-base' / 'vocabulary-inventory.json'
VOCAB  = BASE / 'generators' / 'sp_vocab.py'

# ── Cargar sp_vocab.py ────────────────────────────────────────────────────────
spec = {}
exec(VOCAB.read_text(encoding='utf-8'), spec)
CAT: dict = spec['CAT']

# ── Cargar vocabulary-inventory.json ─────────────────────────────────────────
inv = json.loads(INV.read_text(encoding='utf-8'))
atomos: list = inv['atomos']
existing = {a['term'] for a in atomos}

# ── Calcular nivel de confiabilidad (mismo criterio que build-vocab-inventory) ─
def nivel(cat: str, est: str) -> str:
    if cat in ('PREFIJO', 'REG'):
        return 'MUY ALTA'
    if est == 'conf':
        return 'ALTA'
    if est == 'inf':
        return 'MEDIA'
    return 'BAJA'

def bc_name_from_cat(cat: str) -> str:
    return 'Transversal'

# ── Detectar términos nuevos ───────────────────────────────────────────────────
nuevos = []
for term, (cat, meaning, est) in CAT.items():
    if term in existing:
        continue
    nuevos.append({
        'term': term,
        'cat': cat,
        'mean': meaning,
        'est': est,
        'nivel': nivel(cat, est),
        'fn': 0,
        'fp': 0,
        'deco': '',
        'bc': '—',
        'bc_name': bc_name_from_cat(cat),
        'dominio_as_is': None,
        'es_variante_de': None,
        'tipo_relacion': None,
        'capa_gemelo': 'Capa 1',
        'estado': 'ACTIVO',
        'target_term': None,
        'regulatorio': None,
        'nodo_taxonomia': None,
        'validado_por': None,
        'notas_sme': None,
    })

print(f'sp_vocab.py          : {len(CAT):>4} términos')
print(f'vocabulary-inventory : {len(existing):>4} términos actuales')
print(f'Nuevos a agregar     : {len(nuevos):>4}')
print()

if not nuevos:
    print('Nada que sincronizar.')
    sys.exit(0)

# ── Reporte de nuevos ─────────────────────────────────────────────────────────
from collections import Counter
cats = Counter(t['cat'] for t in nuevos)
print('Por categoría:', dict(cats))
print()
for t in sorted(nuevos, key=lambda x: x['cat']):
    print(f"  [{t['cat']:<8}] {t['term']:<30} {t['est']:<4}  {t['mean'][:60]}")

ap = argparse.ArgumentParser()
ap.add_argument('--dry-run', action='store_true')
args = ap.parse_args()

if args.dry_run:
    print('\n[dry-run] No se escriben cambios.')
    sys.exit(0)

# ── Aplicar ───────────────────────────────────────────────────────────────────
# Insertar en orden alfabético dentro de cada cat (misma convención del existente)
atomos.extend(nuevos)
atomos.sort(key=lambda a: (a['cat'], a['term']))

inv['atomos'] = atomos
inv['meta']['n_atomos'] = len(atomos)
inv['meta']['vocab'] = len(CAT)

INV.write_text(json.dumps(inv, ensure_ascii=False, indent=2), encoding='utf-8')
print(f'\nvocabulary-inventory.json actualizado: {len(atomos)} átomos (+{len(nuevos)})')
print('Siguiente paso: python digital-brain/build-brain.py')