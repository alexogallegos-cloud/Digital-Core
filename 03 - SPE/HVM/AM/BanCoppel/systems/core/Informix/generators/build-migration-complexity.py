#!/usr/bin/env python3
"""
build-migration-complexity.py — Informix Migration Complexity Generator v1.0
Genera portal/data/migration-complexity.json desde bank-brain.db + brain.db.

Fuentes:
  bank-brain.db  migrations → sp, db, domain_id, domain_name, target_sys, migration_fate, rule_count
  brain.db       sps        → sp_archetype, biz, fan_in, fan_out

Cubre los 11,391 SPs que tienen entrada en bank-brain (D01-D16 + D17-D49 analizables).
Los 1,006 SPs "oscuros" (D17-D22/D24-D33/D38/D41-D43 sin SQL fuente) se omiten.

Salida: portal/data/migration-complexity.json
"""

import json, sqlite3, sys
from pathlib import Path
from collections import defaultdict

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

BASE      = Path(__file__).parent.parent   # systems/core/Informix/
BRAIN_DB  = BASE / "digital-brain" / "brain.db"
BANK_DB   = BASE.parent.parent.parent / "bank-brain" / "bank-brain.db"
OUT_JSON  = BASE / "portal" / "data" / "migration-complexity.json"

assert BRAIN_DB.exists(), f"brain.db no encontrado: {BRAIN_DB}"
assert BANK_DB.exists(),  f"bank-brain.db no encontrado: {BANK_DB}"

ARCHS  = ['super_orchestrator', 'batch_orchestrator', 'orchestrator',
          'implementation', 'leaf', 'batch']
FATES  = ['replicate', 'complement', 'absorbed', 'retire', 'unknown']
TARGETS = ['apolo', 'transact', 'smartvista', 'cross', 'multi', 'decommission', 'unknown']


def empty_fate_cell():
    return {f: {'n': 0, 'rules': 0} for f in FATES}


def empty_arch_row():
    return {a: empty_fate_cell() for a in ARCHS}


def main():
    print("=== build-migration-complexity.py v1.0 ===")

    # ── 1. Leer brain.db → sp_archetype por SP ────────────────────────────
    brain = sqlite3.connect(str(BRAIN_DB))
    arch_map = {}   # (sp_name, db) → sp_archetype
    biz_map  = {}   # (sp_name, db) → biz
    for row in brain.execute("SELECT name, db, sp_archetype, biz FROM sps"):
        sp, db, arch, biz = row
        arch_map[(sp, db)] = arch or 'batch'
        biz_map[(sp, db)]  = biz or ''
    brain.close()
    print(f"brain.db: {len(arch_map):,} SPs cargados")

    # ── 2. Leer bank-brain.db → migrations con migration_fate ─────────────
    bank = sqlite3.connect(str(BANK_DB))

    # Ensure migration_fate column exists (classify-migration-fate.py la agrega)
    cols = [r[1] for r in bank.execute("PRAGMA table_info(migrations)")]
    if 'migration_fate' not in cols:
        print("ERROR: migration_fate no existe en bank-brain.db")
        print("  Ejecuta: python bank-brain/classify-migration-fate.py")
        sys.exit(1)

    rows = bank.execute("""
        SELECT sp, db, domain_id, domain_name, target_sys,
               COALESCE(migration_fate, 'unknown') as fate,
               COALESCE(rule_count, 0) as rules
        FROM migrations
    """).fetchall()
    bank.close()
    print(f"bank-brain.db: {len(rows):,} SPs cargados con migration_fate")

    # ── 3. Construir matriz target × sp_archetype → fate → {n, rules} ─────
    matrix      = {t: empty_arch_row() for t in TARGETS}
    top_rep     = {t: [] for t in TARGETS}
    domain_agg  = {t: defaultdict(lambda: {'id': '', 'name': '', 'n': 0, 'rules': 0})
                   for t in TARGETS}

    totals = {'sps': 0, 'replicate': 0, 'absorbed': 0, 'complement': 0,
              'retire': 0, 'unknown': 0}

    for sp, db, dom_id, dom_name, target, fate, rule_count in rows:
        arch = arch_map.get((sp, db), 'batch')

        # normalise unknown target
        tgt = target if target in TARGETS else 'unknown'

        matrix[tgt][arch][fate]['n']     += 1
        matrix[tgt][arch][fate]['rules'] += rule_count
        totals['sps'] += 1
        if fate in totals:
            totals[fate] += 1

        # domain_summary
        dom_key = dom_id or 'NONE'
        entry = domain_agg[tgt][dom_key]
        entry['id']    = dom_id or ''
        entry['name']  = dom_name or ''
        entry['n']     += 1
        entry['rules'] += rule_count

        # top_replicate
        if fate == 'replicate':
            top_rep[tgt].append({
                'sp':     sp,
                'db':     db,
                'domain': dom_id or '',
                'arch':   arch,
                'rules':  rule_count,
                'conf':   'high' if rule_count > 15 else ('medium' if rule_count > 5 else 'low'),
            })

    # Sort top_replicate by rules desc, cap 50
    for tgt in TARGETS:
        top_rep[tgt].sort(key=lambda x: x['rules'], reverse=True)
        top_rep[tgt] = top_rep[tgt][:50]

    # domain_summary: sort by n desc
    domain_summary = {}
    for tgt in TARGETS:
        domain_summary[tgt] = sorted(
            [v for v in domain_agg[tgt].values() if v['n'] > 0],
            key=lambda x: x['n'], reverse=True
        )

    # ── 4. Escribir JSON ───────────────────────────────────────────────────
    out = {
        'matrix':         matrix,
        'top_replicate':  top_rep,
        'domain_summary': domain_summary,
        'archs':          ARCHS,
        'targets':        TARGETS,
        'fates':          FATES,
        'totals':         totals,
    }

    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    with open(OUT_JSON, 'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False)

    print(f"\n✓ {OUT_JSON.name} generado")
    print(f"  SPs totales : {totals['sps']:,}")
    print(f"  replicate   : {totals['replicate']:,}")
    print(f"  absorbed    : {totals['absorbed']:,}")
    print(f"  complement  : {totals['complement']:,}")
    print(f"  retire      : {totals['retire']:,}")
    print(f"  unknown     : {totals['unknown']:,}")

    # ── 5. Verificar top targets ───────────────────────────────────────────
    print("\nTop replicate por target:")
    for tgt in TARGETS:
        n = sum(matrix[tgt][a]['replicate']['n'] for a in ARCHS)
        r = sum(matrix[tgt][a]['replicate']['rules'] for a in ARCHS)
        if n > 0:
            print(f"  {tgt:<15}: {n:>5,} SPs · {r:>5,} reglas")


if __name__ == '__main__':
    main()
