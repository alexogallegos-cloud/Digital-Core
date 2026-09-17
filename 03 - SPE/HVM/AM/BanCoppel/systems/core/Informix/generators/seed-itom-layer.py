"""
seed-itom-layer.py
Siembra itom_layer desde evidencia ya disponible en brain.db (Fase 1).
No requiere entrevistas — usa sp_archetype de orquestadores y external_systems.
Ejecutar después de build-brain.py.

Uso: python generators/seed-itom-layer.py [--dry-run]
"""
import sqlite3
import pathlib
import sys
from datetime import date

BRAIN = pathlib.Path(__file__).parent.parent / "digital-brain" / "brain.db"
DRY_RUN = "--dry-run" in sys.argv

# external_systems.category → dominio ITOM
LAYER_MAP_CATEGORY = {
    "Canales propios":    "customer-engagement",
    "Crédito/Tarjetas":   "customer-engagement",
    "Grupo Coppel":       "customer-engagement",
    "Red física":         "customer-engagement",
    "Remesas":            "customer-engagement",
    "Pagos Banxico":      "it-management",
    "Reguladores":        "it-management",
}

ROWS: list[dict] = []


def collect_orchestrators(db: sqlite3.Connection) -> None:
    """SPs orquestadores batch → Technology Operations.

    super_orchestrator / batch_orchestrator / orchestrator son los
    puntos de entrada de los procesos batch — equivalentes a CTM_ENTRY
    en la nomenclatura ITOM v9.0.
    """
    archetypes = ("super_orchestrator", "batch_orchestrator", "orchestrator")
    placeholders = ",".join("?" * len(archetypes))
    cur = db.execute(
        f"SELECT id, name, domain, sp_archetype FROM sps "
        f"WHERE sp_archetype IN ({placeholders})",
        archetypes,
    )
    for r in cur:
        ROWS.append({
            "component_id": r["id"],
            "layer": "technology-operations",
            "technology": "IBM-Informix-SPL",
            "operation_model": f"batch-{r['sp_archetype']}",
            "slo_ref": None,
            "owner_domain": "Batch Operations",
            "notes": f"sp_archetype={r['sp_archetype']} · {r['name']} [domain:{r['domain'] or 'n/a'}]",
        })


def collect_external_systems(db: sqlite3.Connection) -> None:
    """Sistemas externos → dominio ITOM según category."""
    cur = db.execute(
        "SELECT id, category, total_endpoints FROM external_systems "
        "WHERE total_endpoints > 0 ORDER BY total_endpoints DESC"
    )
    for r in cur:
        cat = r["category"] or ""
        layer = LAYER_MAP_CATEGORY.get(cat, "technology-operations")
        ROWS.append({
            "component_id": r["id"],
            "layer": layer,
            "technology": "integration-endpoint",
            "operation_model": "integration",
            "slo_ref": None,
            "owner_domain": cat or "Unknown",
            "notes": f"Evidencia: external_systems · {r['total_endpoints']} endpoints · categoría={cat}",
        })


def seed(db: sqlite3.Connection) -> None:
    if DRY_RUN:
        print(f"\n[DRY-RUN] {len(ROWS)} rows a insertar en itom_layer:")
        for r in ROWS[:8]:
            print(f"  {r['component_id'][:42]:<42}  {r['layer']:<28}  {r['operation_model']}")
        if len(ROWS) > 8:
            print(f"  ... y {len(ROWS) - 8} más")
        # Resumen por layer
        from collections import Counter
        counts = Counter(r["layer"] for r in ROWS)
        print("\n  Por dominio ITOM:")
        for layer, n in sorted(counts.items()):
            print(f"    {layer:<30} {n:>4}")
        return

    db.execute(
        "DELETE FROM itom_layer WHERE "
        "notes LIKE 'sp_archetype=%' "
        "OR notes LIKE 'Evidencia: external_systems%'"
    )
    db.executemany(
        "INSERT INTO itom_layer "
        "(component_id, layer, technology, operation_model, slo_ref, owner_domain, notes) "
        "VALUES (:component_id, :layer, :technology, :operation_model, "
        ":slo_ref, :owner_domain, :notes)",
        ROWS,
    )
    db.commit()
    print(f"\nitom_layer: {len(ROWS)} rows insertados ({date.today()})")


def main() -> None:
    if not BRAIN.exists():
        print(f"ERROR: brain.db no encontrado en {BRAIN}")
        print("Ejecuta build-brain.py primero.")
        sys.exit(1)

    with sqlite3.connect(BRAIN) as db:
        db.row_factory = sqlite3.Row

        tables = {r[0] for r in db.execute("SELECT name FROM sqlite_master WHERE type='table'")}
        if "itom_layer" not in tables:
            print("ERROR: tabla itom_layer no existe. Ejecuta build-brain.py primero.")
            sys.exit(1)

        print("Recolectando evidencia desde brain.db...")

        collect_orchestrators(db)
        print(f"  Orquestadores batch: {len(ROWS)} SPs")

        prev = len(ROWS)
        collect_external_systems(db)
        print(f"  Sistemas externos:   {len(ROWS) - prev} entradas")

        if not ROWS:
            print("Sin datos — verifica que brain.db tenga sps con sp_archetype y external_systems con endpoints.")
            sys.exit(0)

        seed(db)

        if not DRY_RUN:
            cur = db.execute(
                "SELECT layer, COUNT(*) AS n FROM itom_layer GROUP BY layer ORDER BY n DESC"
            )
            print("\nDistribución por dominio ITOM:")
            for r in cur:
                print(f"  {r['layer']:<32} {r['n']:>5} componentes")


if __name__ == "__main__":
    main()