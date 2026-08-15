#!/usr/bin/env python3
"""
mark-ctm-entry-points.py — Marca batch entry points confirmados desde scripts .sh de CTM v1.0

Fuente: CTM brain.db (sh_sp_refs, confidence='high') — SPs identificados vía
        execute procedure "informix".sp_name() en el contenido real de los scripts .sh.

El pipeline clásico (load-ctm-to-brain.py) solo linkea ~89/1,358 jobs via nombre de job.
Este script cierra el gap: toma los 107 SPs confirmados por execute_procedure en los .sh
y los marca CTM_ENTRY en PISA brain si aún tienen batch_archetype=NO_SOURCE o NULL.

Reglas de preservacion (mismas que load-ctm-to-brain.py):
  - NO sobreescribe CTM_ENTRY ni CTM_HINT existentes
  - NO toca sp_archetype ni ningun otro campo

Uso:
  python generators/mark-ctm-entry-points.py
  python generators/mark-ctm-entry-points.py --dry-run
"""

import sqlite3, sys, argparse
from pathlib import Path
from collections import defaultdict

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE     = Path(__file__).parent.parent
PISA_DB  = BASE / "digital-brain" / "brain.db"
CTM_DB   = BASE.parent.parent / "integration" / "ControlM" / "digital-brain" / "brain.db"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true", help="No escribe a DB")
    args = ap.parse_args()

    print("=== mark-ctm-entry-points.py v1.0 ===")
    print(f"PISA brain : {PISA_DB}")
    print(f"CTM  brain : {CTM_DB}")

    if not PISA_DB.exists():
        sys.exit(f"PISA brain no encontrado: {PISA_DB}")
    if not CTM_DB.exists():
        sys.exit(f"CTM brain no encontrado: {CTM_DB}")

    ctm  = sqlite3.connect(CTM_DB)
    pisa = sqlite3.connect(PISA_DB)

    # ── 1. Obtener SP refs de alta confianza del CTM brain ────────────────────
    #    confidence='high' = extraidos via execute procedure "informix".sp_name()
    sh_refs = ctm.execute("""
        SELECT sp_name, db_name, COUNT(*) n_scripts
        FROM sh_sp_refs
        WHERE confidence = 'high'
        GROUP BY sp_name, db_name
        ORDER BY n_scripts DESC
    """).fetchall()

    print(f"\nSP refs alta confianza en CTM brain : {len(sh_refs)} unicos (execute_procedure)")

    # ── 2. Build lookup PISA: name.lower() → {id, db, batch_archetype} ────────
    sp_rows = pisa.execute(
        "SELECT id, name, db, batch_archetype FROM sps"
    ).fetchall()

    by_name: dict[str, list[dict]] = defaultdict(list)
    for sid, sname, db, arch in sp_rows:
        by_name[(sname or "").lower()].append({
            "id": sid, "db": db, "batch_archetype": arch
        })

    # ── 3. Cruzar y clasificar ────────────────────────────────────────────────
    to_update:       list[dict] = []   # candidatos a CTM_ENTRY
    already_entry:   list[str]  = []   # ya CTM_ENTRY o CTM_HINT
    not_in_pisa:     list[str]  = []   # built-ins o nombre distinto

    for sp_name, ctm_db, n_scripts in sh_refs:
        hits = by_name.get(sp_name.lower(), [])
        if not hits:
            not_in_pisa.append(sp_name)
            continue

        for h in hits:
            current_arch = h["batch_archetype"] or ""
            if current_arch in ("CTM_ENTRY", "CTM_HINT"):
                already_entry.append(sp_name)
            else:
                to_update.append({
                    "sp_id":    h["id"],
                    "sp_name":  sp_name,
                    "pisa_db":  h["db"],
                    "ctm_db":   ctm_db,
                    "n_scripts": n_scripts,
                    "prev_arch": current_arch or "NULL",
                })

    # ── 4. Dedup (mismo sp_id puede aparecer si nombre coincide en varias DBs) ─
    seen_ids: set[str] = set()
    unique_updates: list[dict] = []
    for u in to_update:
        if u["sp_id"] not in seen_ids:
            seen_ids.add(u["sp_id"])
            unique_updates.append(u)

    print(f"\n=== RESUMEN PRE-UPDATE ===")
    print(f"  A marcar CTM_ENTRY (batch_archetype=NO_SOURCE/NULL) : {len(unique_updates)}")
    print(f"  Ya tenian CTM_ENTRY o CTM_HINT (sin cambio)         : {len(already_entry)}")
    print(f"  No encontrados en PISA (built-ins)                  : {len(not_in_pisa)}")

    if unique_updates:
        print(f"\n=== SPs A ACTUALIZAR ===")
        print(f"  {'SP':<45} {'pisa_db':<12} {'ctm_db':<12} {'prev_arch':<15} {'x_scripts':>9}")
        print("  " + "-" * 100)
        for u in sorted(unique_updates, key=lambda x: (x["pisa_db"], x["sp_name"])):
            print(f"  {u['sp_name']:<45} {u['pisa_db']:<12} {u['ctm_db'] or '?':<12} "
                  f"{u['prev_arch']:<15} {u['n_scripts']:>9}")

    if not_in_pisa:
        print(f"\n=== NO EN PISA (built-ins o variante de nombre) ===")
        for sp in not_in_pisa:
            print(f"  {sp}")

    if args.dry_run:
        print("\n[DRY-RUN] Sin cambios en PISA brain.db.")
        ctm.close()
        pisa.close()
        return

    if not unique_updates:
        print("\nNada que actualizar.")
        ctm.close()
        pisa.close()
        return

    # ── 5. Aplicar UPDATE ─────────────────────────────────────────────────────
    updated = 0
    for u in unique_updates:
        r = pisa.execute(
            "UPDATE sps SET batch_archetype='CTM_ENTRY' "
            "WHERE id=? AND (batch_archetype IS NULL OR batch_archetype NOT IN ('CTM_ENTRY', 'CTM_HINT'))",
            (u["sp_id"],)
        )
        updated += r.rowcount

    pisa.commit()

    # ── 6. Verificacion post-update ───────────────────────────────────────────
    total_ctm_entry = pisa.execute(
        "SELECT COUNT(*) FROM sps WHERE batch_archetype='CTM_ENTRY'"
    ).fetchone()[0]

    ctm.close()
    pisa.close()

    print(f"\n=== RESULTADO ===")
    print(f"  batch_archetype='CTM_ENTRY' aplicado : {updated} SPs nuevos")
    print(f"  Total CTM_ENTRY en PISA brain.db     : {total_ctm_entry} SPs")
    print(f"\nSiguiente: python generators/build-decoupling-cost.py  (si quieres actualizar metricas)")
    print(f"           python generators/build-sp-fine-mapping.py   (si ETB mapping es relevante)")


if __name__ == "__main__":
    main()