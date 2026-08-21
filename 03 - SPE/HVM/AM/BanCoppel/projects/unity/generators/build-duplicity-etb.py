"""
build-duplicity-etb.py  --  Matriz de cobertura ETB: Legados vs. Unity R4
Produce portal/data/duplicidad-etb.json

Columnas izquierda (LEGADOS):
  - Informix/PISA       → sp_capabilities del Informix brain (61 L3, conteo SPs)
  - App Movil (actual)  → 49 SPs del AppMovil brain cruzados con Informix sp_capabilities (37 L3)
  - SIWEB (actual)      → marcadores manuales (sin brain propio)
  - InterAct/Syndein    → marcadores manuales (sin brain propio)
  - Intercard CMS       → marcadores manuales (sin brain propio)

Columnas derecha (UNITY R4):
  - Transact, SmartVista, Apolo, App Movil R4, Atlas, SIWEB R4, Cobranza, Apificacion
  → desde functional_duplicity del Unity brain (etb_capability JSON arrays)

Uso:
    python generators/build-duplicity-etb.py    # desde projects/unity/
"""

import json
import sqlite3
from datetime import datetime
from pathlib import Path

BASE        = Path(__file__).parent.parent
UNITY_DB    = BASE / "digital-brain" / "brain.db"
INFORMIX_DB = BASE.parent.parent / "systems" / "core"  / "Informix"  / "digital-brain" / "brain.db"
APPMOVIL_DB = BASE.parent.parent / "systems" / "channels" / "AppMovil" / "digital-brain" / "brain.db"
OUT         = BASE / "portal" / "data" / "duplicidad-etb.json"

# ── Sistemas legado ────────────────────────────────────────────────────────────
LEGACY_SYSTEMS = [
    {"id": "informix",        "label": "Informix / PISA",   "type": "core",        "color": "#1a3060"},
    {"id": "app-movil-legacy","label": "App Movil (actual)","type": "channel",     "color": "#1a4060"},
    {"id": "siweb-legacy",    "label": "SIWEB (actual)",    "type": "channel",     "color": "#1a4848"},
    {"id": "interact",        "label": "InterAct / Syndein","type": "middleware",  "color": "#302060"},
    {"id": "intercard",       "label": "Intercard CMS",     "type": "processor",  "color": "#3a2040"},
]

# Marcadores manuales para sistemas sin brain propio (ETB L3 que cubren conocidos)
MANUAL_LEGACY_MARKERS = {
    "siweb-legacy": ["1.2.1", "1.1.1", "7.1.2", "7.1.4"],
    "interact":     ["3.4.1","3.4.2","3.4.3","3.4.4","3.4.5","3.4.6","3.4.7","3.4.8"],
    "intercard":    ["3.5.1","3.5.2","3.5.7"],
}

# ── Sistemas Unity R4 ──────────────────────────────────────────────────────────
NEW_SYSTEMS = [
    {"id": "transact",   "label": "Temenos Transact",  "type": "core",        "color": "#122FB1"},
    {"id": "smartvista", "label": "SmartVista (BPC)",  "type": "processor",   "color": "#1a3a8a"},
    {"id": "apolo",      "label": "Apolo",             "type": "channel",     "color": "#2d5abf"},
    {"id": "app-movil",  "label": "App Movil R4",      "type": "channel",     "color": "#3d7abf"},
    {"id": "siweb",      "label": "SIWEB R4",          "type": "channel",     "color": "#2a7a7a"},
    {"id": "atlas",      "label": "Atlas (GCP MDM)",   "type": "data",        "color": "#1a6e6e"},
    {"id": "cobranza",   "label": "Cobranza Direc.",   "type": "channel",     "color": "#5d6ab0"},
    {"id": "eglobal",    "label": "Apificación",       "type": "integration", "color": "#8060c0"},
]


def load_etb(ifx: sqlite3.Connection) -> dict:
    l1s = [{"id": r[0], "name": r[1]} for r in ifx.execute(
        "SELECT id, name FROM etb_l1 ORDER BY id")]
    l2s = [{"id": r[0], "l1_id": r[1], "name": r[2]} for r in ifx.execute(
        "SELECT id, l1_id, name FROM etb_l2 ORDER BY id")]
    l3s = [{"id": r[0], "l2_id": r[1], "l1_id": r[2], "name": r[3]}
           for r in ifx.execute("SELECT id, l2_id, l1_id, name FROM etb_l3 ORDER BY id")]
    return {"l1s": l1s, "l2s": l2s, "l3s": l3s}


def load_informix_coverage(ifx: sqlite3.Connection) -> dict:
    """l3_id → {n_sps, n_dbs, domains, covered}"""
    cov = {}
    for row in ifx.execute("""
        SELECT l3.id, COUNT(DISTINCT sc.sp_id) as n_sps,
               COUNT(DISTINCT s.db) as n_dbs,
               GROUP_CONCAT(DISTINCT s.domain) as domains
        FROM sp_capabilities sc
        JOIN etb_l3 l3 ON sc.l3_id = l3.id
        JOIN sps s ON sc.sp_id = s.id
        GROUP BY l3.id
    """):
        cov[row[0]] = {
            "n_sps": row[1], "n_dbs": row[2],
            "domains": sorted(set(d for d in (row[3] or "").split(",") if d)),
        }
    return cov


def load_appmovil_coverage(app: sqlite3.Connection, ifx: sqlite3.Connection) -> dict:
    """l3_id → {n_sps} via los 49 SPs que AppMovil llama en Informix."""
    # Todos los SPs únicos (calls + properties)
    sp_ids = set()
    for row in app.execute(
        "SELECT DISTINCT db_name || ':' || sp_name FROM sp_calls "
        "UNION "
        "SELECT DISTINCT db_name || ':' || sp_name FROM sp_properties"
    ):
        sp_ids.add(row[0])

    if not sp_ids:
        return {}

    # ATTACH la db de Informix para hacer el join
    try:
        ifx.execute(f"ATTACH '{str(INFORMIX_DB).replace(chr(92), '/')}' AS ifx2")
    except Exception:
        pass  # ya attached

    placeholders = ",".join("?" * len(sp_ids))
    cov = {}
    for row in ifx.execute(f"""
        SELECT sc.l3_id, COUNT(DISTINCT sc.sp_id) as n_sps
        FROM sp_capabilities sc
        WHERE sc.sp_id IN ({placeholders})
        GROUP BY sc.l3_id
    """, list(sp_ids)):
        cov[row[0]] = {"n_sps": row[1]}
    return cov


def load_dups(unity: sqlite3.Connection) -> dict:
    dups = {}
    for row in unity.execute("""
        SELECT id, dt_agent, capability_domain, etb_capability,
               legacy_system, new_system, overlap_type,
               recommended_scenario, scenario_confidence,
               migration_blocker, blocker_description, decision_dependency,
               evidence, status, notes
        FROM functional_duplicity ORDER BY id
    """):
        eid = row[3]
        etb_ids = []
        if eid:
            try:
                etb_ids = json.loads(eid)
            except Exception:
                etb_ids = [eid.strip()] if isinstance(eid, str) and eid.strip() else []
        dups[row[0]] = {
            "id": row[0], "dt_agent": row[1], "capability_domain": row[2],
            "etb_ids": etb_ids,
            "legacy_system": row[4], "new_system": row[5],
            "overlap_type": row[6], "recommended_scenario": row[7],
            "scenario_confidence": row[8], "migration_blocker": bool(row[9]),
            "blocker_description": row[10], "decision_dependency": row[11],
            "evidence": row[12], "status": row[13], "notes": row[14],
        }
    return dups


def build_matrix(etb: dict, ifx_cov: dict, app_cov: dict, dups: dict) -> dict:
    """
    Para cada ETB L3:
      legacy  = {informix:{n_sps,...}, app-movil-legacy:{n_sps}, siweb-legacy:{marker}, ...}
      new     = {sys_id: {dup_id, scenario, blocker, ...}}
    """
    matrix = {}
    for l3 in etb["l3s"]:
        lid = l3["id"]
        legacy = {}

        # Informix
        if lid in ifx_cov:
            legacy["informix"] = ifx_cov[lid]

        # AppMovil legacy
        if lid in app_cov:
            legacy["app-movil-legacy"] = app_cov[lid]

        # Manual markers
        for sys_id, markers in MANUAL_LEGACY_MARKERS.items():
            if lid in markers:
                legacy[sys_id] = {"marker": True}

        # New systems (from DUPs)
        new = {}
        for dup_id, dup in dups.items():
            if lid not in dup["etb_ids"]:
                continue
            sys_id = dup["new_system"]
            if sys_id not in new:
                new[sys_id] = []
            new[sys_id].append({
                "dup_id": dup_id,
                "scenario": dup["recommended_scenario"],
                "blocker": dup["migration_blocker"],
                "capability_domain": dup["capability_domain"],
            })

        if legacy or new:
            matrix[lid] = {"legacy": legacy, "new": new}

    return matrix


def build_summary(etb: dict, matrix: dict, dups: dict) -> dict:
    covered_ifx   = sum(1 for l in etb["l3s"] if l["id"] in matrix and "informix" in matrix[l["id"]].get("legacy", {}))
    covered_app   = sum(1 for l in etb["l3s"] if l["id"] in matrix and "app-movil-legacy" in matrix[l["id"]].get("legacy", {}))
    dup_cells     = sum(1 for cell in matrix.values() if cell.get("new"))
    ifx_only      = sum(1 for cell in matrix.values() if cell.get("legacy") and not cell.get("new"))
    blockers      = sum(1 for d in dups.values() if d["migration_blocker"])
    by_scenario   = {}
    for d in dups.values():
        sc = d["recommended_scenario"] or "analizar"
        by_scenario[sc] = by_scenario.get(sc, 0) + 1
    return {
        "total_etb_l3": len(etb["l3s"]),
        "informix_l3": covered_ifx,
        "appmovil_l3": covered_app,
        "dup_mapped_l3": dup_cells,
        "informix_only_l3": ifx_only,
        "total_dups": len(dups),
        "blockers": blockers,
        "by_scenario": by_scenario,
    }


def main() -> None:
    for path, name in [(UNITY_DB, "Unity"), (INFORMIX_DB, "Informix"), (APPMOVIL_DB, "AppMovil")]:
        if not path.exists():
            raise FileNotFoundError(f"{name} brain no encontrado: {path}")

    unity   = sqlite3.connect(str(UNITY_DB))
    ifx     = sqlite3.connect(str(INFORMIX_DB))
    app     = sqlite3.connect(str(APPMOVIL_DB))

    print("Leyendo ETB de Informix brain...")
    etb = load_etb(ifx)
    print(f"  {len(etb['l1s'])} L1 | {len(etb['l2s'])} L2 | {len(etb['l3s'])} L3")

    print("Cargando cobertura Informix...")
    ifx_cov = load_informix_coverage(ifx)
    print(f"  {len(ifx_cov)} L3 cubiertos por Informix")

    print("Cargando cobertura AppMovil (49 SPs × ETB)...")
    app_cov = load_appmovil_coverage(app, ifx)
    print(f"  {len(app_cov)} L3 cubiertos por AppMovil")

    print("Cargando functional_duplicity de Unity brain...")
    dups = load_dups(unity)
    print(f"  {len(dups)} DUPs | {sum(1 for d in dups.values() if d['etb_ids'])} con ETB mapeado")

    print("Construyendo matriz legacy × new...")
    matrix = build_matrix(etb, ifx_cov, app_cov, dups)
    summary = build_summary(etb, matrix, dups)
    print(f"  informix_only={summary['informix_only_l3']} | dup_mapped={summary['dup_mapped_l3']} | blockers={summary['blockers']}")

    output = {
        "meta": {"generated_at": datetime.now().isoformat(), "version": "2.0.0"},
        "summary": summary,
        "l1s": etb["l1s"], "l2s": etb["l2s"], "l3s": etb["l3s"],
        "legacy_systems": LEGACY_SYSTEMS,
        "new_systems": NEW_SYSTEMS,
        "dups": dups,
        "matrix": matrix,
    }

    OUT.parent.mkdir(parents=True, exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)
    print(f"\n  duplicidad-etb.json: {OUT} ({OUT.stat().st_size // 1024} KB)")


if __name__ == "__main__":
    main()