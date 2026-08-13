#!/usr/bin/env python3
"""
classify-sp-types.py — Informix SP Classifier v1.1
Puebla sp_archetype en brain.db con la taxonomía estructural de 7 arquetipos.

sp_archetype (columna) = patrón estructural derivado de fan_in/fan_out (todos los SPs).
sp_role     (columna) = rol ESB (entry_point, esb_exposed, etc.) — NO se toca.

Reglas (derivadas de call graph — fan_in y fan_out):
  1. fan_out > 50                              → super_orchestrator
  2. fan_out 6-50 AND fan_in > 0              → orchestrator
  3. fan_out 1-5  AND fan_in > 0              → implementation
  4. fan_out = 0  AND fan_in > 0              → leaf
  5. fan_out > 5  AND fan_in = 0              → batch_orchestrator
  6. demás (fan_in = 0, fan_out <= 5)         → batch
"""
import sqlite3, sys
from pathlib import Path
from collections import Counter

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

BASE = Path(__file__).parent.parent   # systems/core/Informix/
DB   = BASE / "digital-brain" / "brain.db"

ORDER = [
    'super_orchestrator', 'batch_orchestrator',
    'orchestrator', 'implementation', 'leaf', 'batch',
]

DESCRIPTIONS = {
    'super_orchestrator':    'Orquestador complejo — fan_out > 50 SPs',
    'batch_orchestrator':    'Batch con orquestación — fan_in=0, fan_out > 5',
    'orchestrator':          'Orquestador interno — fan_out 6-50, fan_in > 0',
    'implementation':        'Implementación — fan_out 1-5, fan_in > 0',
    'leaf':                  'Hoja atómica — fan_out=0, fan_in > 0',
    'batch':                 'Batch standalone — fan_in=0, fan_out ≤ 5',
}


def classify(fi: int, fo: int) -> str:
    fi, fo = fi or 0, fo or 0
    if fo > 50:                  return 'super_orchestrator'
    if fo > 5  and fi > 0:       return 'orchestrator'
    if 1 <= fo <= 5 and fi > 0:  return 'implementation'
    if fo == 0 and fi > 0:       return 'leaf'
    if fo > 5  and fi == 0:      return 'batch_orchestrator'
    return 'batch'


def print_table(counter: Counter, total: int, title: str):
    print(f"\n{title}")
    for arch in ORDER:
        n = counter.get(arch, 0)
        if n == 0:
            continue
        bar = '█' * int(n / total * 40)
        print(f"  {arch:<25} {n:>6,}  ({n/total*100:5.1f}%)  {bar}")


def main():
    db_path = str(DB)
    conn = sqlite3.connect(db_path)
    cur  = conn.cursor()

    rows = cur.execute("SELECT id, fan_in, fan_out FROM sps").fetchall()
    total = len(rows)
    print(f"=== Informix SP Classifier v1.1 ===")
    print(f"DB:        {db_path}")
    print(f"Total SPs: {total:,}")

    updates = []
    after   = Counter()

    for sp_id, fi, fo in rows:
        arch = classify(fi, fo)
        after[arch] += 1
        updates.append((arch, sp_id))

    print_table(after, total, "Distribución sp_archetype:")

    cur.executemany("UPDATE sps SET sp_archetype = ? WHERE id = ?", updates)
    conn.commit()
    print(f"\n✓ brain.db actualizado — sp_archetype poblado en {len(updates):,} SPs")

    print("\nDescripciones:")
    for arch in ORDER:
        n = after.get(arch, 0)
        if n:
            print(f"  {arch:<25} {DESCRIPTIONS[arch]}")

    conn.close()


if __name__ == '__main__':
    main()
