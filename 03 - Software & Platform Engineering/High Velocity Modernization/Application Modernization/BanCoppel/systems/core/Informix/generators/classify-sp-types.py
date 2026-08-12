#!/usr/bin/env python3
"""
classify-sp-types.py — BCOPCore SP Classifier v1.0
Reclasifica todos los SPs en brain.db con la taxonomía de 7 arquetipos.

Reglas (en orden de prioridad):
  1. Roles explícitos preservados: esb_exposed · entry_point · cross_domain_primitive · shared_service
  2. fan_out > 50                          → super_orchestrator
  3. fan_out 6-50 AND fan_in > 0          → orchestrator
  4. fan_out 1-5  AND fan_in > 0          → implementation
  5. fan_out = 0  AND fan_in > 0          → leaf
  6. fan_out > 5  AND fan_in = 0          → batch_orchestrator
  7. demás (fan_in = 0, fan_out <= 5)     → batch
"""
import sqlite3, sys
from collections import Counter

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

BCOP = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/BCOPCore")
DB = f"{BCOP}/digital-brain/brain.db"

PRESERVED = frozenset({'esb_exposed', 'entry_point', 'cross_domain_primitive', 'shared_service'})

ORDER = [
    'esb_exposed', 'entry_point', 'super_orchestrator', 'batch_orchestrator',
    'orchestrator', 'implementation', 'leaf',
    'cross_domain_primitive', 'shared_service', 'batch',
]

DESCRIPTIONS = {
    'esb_exposed':           'Frontera: expuesto al ESB (API pública del core)',
    'entry_point':           'Frontera: punto de entrada de transacciones',
    'super_orchestrator':    'Orquestador complejo — fan_out > 50 SPs',
    'batch_orchestrator':    'Batch con orquestación — fan_in=0, fan_out > 5',
    'orchestrator':          'Orquestador interno — fan_out 6-50, fan_in > 0',
    'implementation':        'Implementación — fan_out 1-5, fan_in > 0',
    'leaf':                  'Hoja atómica — fan_out=0, fan_in > 0',
    'cross_domain_primitive':'Primitiva cross-domain — ops fundamentales compartidas',
    'shared_service':        'Servicio compartido — infraestructura transversal',
    'batch':                 'Batch standalone — fan_in=0, sin callers SP-to-SP',
}


def classify(fi: int, fo: int, role: str) -> str:
    if role in PRESERVED:
        return role
    fi, fo = fi or 0, fo or 0
    if fo > 50:                  return 'super_orchestrator'
    if fo > 5  and fi > 0:       return 'orchestrator'
    if 1 <= fo <= 5 and fi > 0:  return 'implementation'
    if fo == 0 and fi > 0:       return 'leaf'
    if fo > 5  and fi == 0:      return 'batch_orchestrator'
    return 'batch'


def print_table(counter: Counter, total: int, title: str):
    print(f"\n{title}")
    for role in ORDER:
        n = counter.get(role, 0)
        if n == 0:
            continue
        bar = '█' * int(n / total * 40)
        print(f"  {role:<30} {n:>6}  ({n/total*100:5.1f}%)  {bar}")
    other = sum(v for k, v in counter.items() if k not in ORDER)
    if other:
        print(f"  {'(otros)':<30} {other:>6}  ({other/total*100:5.1f}%)")


def main():
    conn = sqlite3.connect(DB)
    cur  = conn.cursor()

    rows = cur.execute("SELECT id, fan_in, fan_out, sp_role FROM sps").fetchall()
    total = len(rows)
    print(f"=== BCOPCore SP Classifier v1.0 ===")
    print(f"Total SPs: {total:,}")

    before  = Counter(r[3] or 'NULL' for r in rows)
    updates = []
    after   = Counter()

    for sp_id, fi, fo, old_role in rows:
        new = classify(fi, fo, old_role or '')
        after[new] += 1
        if new != (old_role or ''):
            updates.append((new, sp_id))

    print_table(before, total, "ANTES (sp_role original):")
    print_table(after,  total, "DESPUÉS (taxonomía 7 arquetipos):")

    print(f"\nSPs a actualizar: {len(updates):,}")
    if updates:
        cur.executemany("UPDATE sps SET sp_role = ? WHERE id = ?", updates)
        conn.commit()
        print(f"✓ brain.db actualizado — {len(updates):,} SPs reclasificados")
    else:
        print("Sin cambios.")

    print("\nDescripciones por arquetipo:")
    for role in ORDER:
        n = after.get(role, 0)
        if n:
            print(f"  {role:<30} {DESCRIPTIONS[role]}")

    conn.close()


if __name__ == '__main__':
    main()
