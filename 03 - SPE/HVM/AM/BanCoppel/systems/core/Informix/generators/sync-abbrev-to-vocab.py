#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""sync-abbrev-to-vocab.py — Sincroniza las entradas de ABBREV (generador de nombres)
   hacia el inventario de vocabulario, como 'compuestos' con tipo_relacion ABBREV-OF.
   Así el catálogo/glosario de vocabulario refleja el léxico que usa el namer.

   Aditivo y seguro: solo agrega términos que NO existen ya en el inventario; no toca
   los existentes. Marca origen (est='gen', validado_por) para trazabilidad.

Input/Output: knowledge-base/vocabulary-inventory.json  (respaldo previo)
SPE-AM-001 · DT-Vocabulario + DT-Reglas
"""
import re, io, sys, json, shutil, datetime
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - SPE/HVM/AM/BanCoppel/Informix/")

# Cargar ABBREV del generador (solo las defs, sin ejecutar el main)
src = open(BASE + "generators/infer-rule-names.py", encoding="utf-8").read().split("# ── 7. Main")[0]
src = re.sub(r'^sys\.stdout\s*=.*$', '', src, flags=re.M)
mod = {}
exec(compile(src, "gen-defs", "exec"), mod)
ABBREV = mod['ABBREV']

INV = BASE + "knowledge-base/vocabulary-inventory.json"
inv = json.load(open(INV, encoding="utf-8"))
existing = {i['term'].lower() for i in inv.get('atomos', [])} | {i['term'].lower() for i in inv.get('compuestos', [])}

# palabras SQL/keyword sin valor de negocio (ABBREV las mapea a '')
SKIP_EMPTY = True
added = 0
for term, mean in ABBREV.items():
    t = term.lower()
    if t in existing:
        continue
    if SKIP_EMPTY and (not mean or mean == term):
        continue
    if len(t) < 3:
        continue
    # deco: separación heurística si el término es claramente compuesto (no la calculamos fina)
    inv['compuestos'].append({
        'term': t, 'cat': 'ABREVIATURA', 'mean': mean, 'est': 'gen', 'nivel': 'MEDIA',
        'fn': 0, 'fp': 0, 'deco': '', 'bc': '—', 'bc_name': 'Transversal',
        'dominio_as_is': None, 'es_variante_de': None, 'tipo_relacion': 'ABBREV-OF',
        'capa_gemelo': 'Capa 1', 'estado': 'ACTIVO', 'target_term': None,
        'regulatorio': None, 'nodo_taxonomia': None,
        'validado_por': 'DT-Reglas/DT-Vocabulario · sync 2026-08-07', 'notas_sme': None,
    })
    existing.add(t)
    added += 1

# meta
inv.setdefault('meta', {})
inv['meta']['abbrev_sync'] = {'fecha': '2026-08-07', 'agregados': added,
                              'total_compuestos': len(inv['compuestos'])}

shutil.copy(INV, INV.replace('.json', f'.bak_{datetime.datetime.now():%Y%m%d_%H%M%S}.json'))
json.dump(inv, open(INV, "w", encoding="utf-8"), ensure_ascii=False, indent=1)

print(f"ABBREV entries totales   : {len(ABBREV):,}")
print(f"Agregados al inventario  : {added:,}  (nuevos compuestos ABBREV-OF)")
print(f"Compuestos ahora         : {len(inv['compuestos']):,}")
print(f"Atomos                   : {len(inv.get('atomos',[])):,}")
print(f"Saved: {INV}")
