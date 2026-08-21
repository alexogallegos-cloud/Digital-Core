"""
build-duplicity-etb.py  --  Generador de matriz de cobertura ETB vs Duplicidad Funcional
Produce portal/data/duplicidad-etb.json para duplicidad-etb-bcop.html

Fuentes:
  - Unity brain.db::functional_duplicity (23 DUP-NNN)
  - Informix brain.db::sp_capabilities + etb_l3/l2/l1 (61 L3 cubiertos)

Salida: portal/data/duplicidad-etb.json
  {
    "l1s": [...],
    "l2s": [...],
    "l3s": [{id, name, l2_id, l1_id, informix_sps, informix_dbs, informix_domains, dups:[...]}],
    "dups": {DUP-NNN: {etb_ids:[], scenario, blocker, new_system, legacy_system, domain}},
    "systems": [...],  -- sistemas Unity con sus L3 mapped
    "meta": {generated_at, ...}
  }

Uso:
    python generators/build-duplicity-etb.py       # desde projects/unity/
"""

import json
import sqlite3
from datetime import datetime
from pathlib import Path

BASE    = Path(__file__).parent.parent          # projects/unity/
UNITY_DB   = BASE / "digital-brain" / "brain.db"
INFORMIX_DB = BASE.parent.parent / "systems" / "core" / "Informix" / "digital-brain" / "brain.db"
OUT     = BASE / "portal" / "data" / "duplicidad-etb.json"


def load_etb_from_informix(ifx: sqlite3.Connection) -> dict:
    """Lee la taxonomia ETB completa y la cobertura de SPs en Informix."""
    l1s = [{"id": r[0], "name": r[1]} for r in ifx.execute(
        "SELECT id, name FROM etb_l1 ORDER BY id"
    )]
    l2s = [{"id": r[0], "l1_id": r[1], "name": r[2]} for r in ifx.execute(
        "SELECT id, l1_id, name FROM etb_l2 ORDER BY id"
    )]

    # L3 con cobertura real en Informix
    covered = {}
    for row in ifx.execute("""
        SELECT l3.id, COUNT(DISTINCT sc.sp_id) as n_sps,
               COUNT(DISTINCT s.db) as n_dbs,
               GROUP_CONCAT(DISTINCT s.domain) as domains
        FROM sp_capabilities sc
        JOIN etb_l3 l3 ON sc.l3_id = l3.id
        JOIN sps s ON sc.sp_id = s.id
        GROUP BY l3.id
    """):
        covered[row[0]] = {
            "n_sps": row[1], "n_dbs": row[2],
            "domains": sorted(set(d for d in (row[3] or "").split(",") if d)) if row[3] else [],
        }

    l3s = []
    for row in ifx.execute("SELECT id, l2_id, l1_id, name FROM etb_l3 ORDER BY id"):
        l3_id = row[0]
        cov = covered.get(l3_id, {})
        l3s.append({
            "id": l3_id, "l2_id": row[1], "l1_id": row[2], "name": row[3],
            "informix_sps": cov.get("n_sps", 0),
            "informix_dbs": cov.get("n_dbs", 0),
            "informix_domains": cov.get("domains", []),
            "covered": l3_id in covered,
        })

    return {"l1s": l1s, "l2s": l2s, "l3s": l3s}


def load_dups_from_unity(unity: sqlite3.Connection) -> dict:
    """Lee functional_duplicity del brain Unity y parsea etb_capability como JSON array."""
    dups = {}
    for row in unity.execute("""
        SELECT id, dt_agent, capability_domain, etb_capability,
               legacy_system, new_system, overlap_type,
               recommended_scenario, scenario_confidence,
               migration_blocker, blocker_description, decision_dependency,
               status, notes
        FROM functional_duplicity ORDER BY id
    """):
        eid = row[3]
        etb_ids = []
        if eid:
            try:
                etb_ids = json.loads(eid)
            except (json.JSONDecodeError, TypeError):
                if isinstance(eid, str) and eid.strip():
                    etb_ids = [eid.strip()]

        dups[row[0]] = {
            "id": row[0], "dt_agent": row[1],
            "capability_domain": row[2],
            "etb_ids": etb_ids,
            "legacy_system": row[4], "new_system": row[5],
            "overlap_type": row[6],
            "recommended_scenario": row[7],
            "scenario_confidence": row[8],
            "migration_blocker": bool(row[9]),
            "blocker_description": row[10],
            "decision_dependency": row[11],
            "status": row[12],
            "notes": row[13],
        }
    return dups


# Unity system → display info
SYSTEMS = [
    {"id": "informix",   "label": "Informix/PISA",    "type": "legacy",  "color": "#1a2d5a"},
    {"id": "transact",   "label": "Temenos Transact",  "type": "core",    "color": "#122FB1"},
    {"id": "smartvista", "label": "SmartVista (BPC)",  "type": "processor","color": "#1a3a8a"},
    {"id": "apolo",      "label": "Apolo",             "type": "channel", "color": "#2d5abf"},
    {"id": "app-movil",  "label": "App Movil",         "type": "channel", "color": "#3d7abf"},
    {"id": "siweb",      "label": "SIWEB",             "type": "channel", "color": "#4d8acf"},
    {"id": "atlas",      "label": "Atlas (GCP MDM)",   "type": "data",    "color": "#1a6e6e"},
    {"id": "cobranza",   "label": "Cobranza Direc.",   "type": "channel", "color": "#5d6ab0"},
    {"id": "eglobal",    "label": "Apificacion",       "type": "integration","color": "#8060c0"},
]


def build_matrix(etb: dict, dups: dict) -> dict:
    """
    Para cada ETB L3: lista qué DUP-NNN lo referencia y qué sistemas lo cubren.
    Devuelve: {l3_id: {dups: [DUP-NNN,...], systems: {sys_id: {status, dup_ids}}}}
    """
    l3_map = {l3["id"]: l3 for l3 in etb["l3s"]}
    matrix = {l3["id"]: {"dups": [], "unity_systems": {}} for l3 in etb["l3s"]}

    # Expand DUPs into the matrix
    for dup_id, dup in dups.items():
        for l3_id in dup["etb_ids"]:
            if l3_id not in matrix:
                continue
            matrix[l3_id]["dups"].append(dup_id)
            sys_id = dup["new_system"]
            if sys_id not in matrix[l3_id]["unity_systems"]:
                matrix[l3_id]["unity_systems"][sys_id] = {"dup_ids": [], "scenario": None}
            matrix[l3_id]["unity_systems"][sys_id]["dup_ids"].append(dup_id)
            matrix[l3_id]["unity_systems"][sys_id]["scenario"] = dup["recommended_scenario"]

    return matrix


def build_summary(etb: dict, dups: dict, matrix: dict) -> dict:
    """KPIs para el hero del portal."""
    covered_l3 = sum(1 for l3 in etb["l3s"] if l3["covered"])
    dup_l3 = sum(1 for l3_id, cell in matrix.items() if cell["dups"])
    blockers = sum(1 for d in dups.values() if d["migration_blocker"])
    by_scenario = {}
    for d in dups.values():
        sc = d["recommended_scenario"] or "tbd"
        by_scenario[sc] = by_scenario.get(sc, 0) + 1
    l3_with_informix_only = sum(
        1 for l3_id, cell in matrix.items()
        if next((l for l in etb["l3s"] if l["id"] == l3_id), {}).get("covered")
        and not cell["dups"]
    )
    return {
        "total_etb_l3": len(etb["l3s"]),
        "informix_covered_l3": covered_l3,
        "dup_mapped_l3": dup_l3,
        "informix_only_l3": l3_with_informix_only,
        "total_dups": len(dups),
        "blockers": blockers,
        "by_scenario": by_scenario,
    }


def main() -> None:
    if not UNITY_DB.exists():
        raise FileNotFoundError(f"Unity brain no encontrado: {UNITY_DB}")
    if not INFORMIX_DB.exists():
        raise FileNotFoundError(f"Informix brain no encontrado: {INFORMIX_DB}")

    unity   = sqlite3.connect(str(UNITY_DB))
    informix = sqlite3.connect(str(INFORMIX_DB))

    print("Leyendo ETB de Informix brain...")
    etb = load_etb_from_informix(informix)
    covered = sum(1 for l3 in etb["l3s"] if l3["covered"])
    print(f"  ETB: {len(etb['l1s'])} L1 | {len(etb['l2s'])} L2 | {len(etb['l3s'])} L3 | {covered} cubiertos por Informix")

    print("Leyendo functional_duplicity de Unity brain...")
    dups = load_dups_from_unity(unity)
    etb_mapped = sum(1 for d in dups.values() if d["etb_ids"])
    print(f"  DUPs: {len(dups)} total | {etb_mapped} con ETB L3 mapeado")

    print("Construyendo matriz ETB L3 × Sistema...")
    matrix = build_matrix(etb, dups)
    active_cells = sum(1 for cell in matrix.values() if cell["dups"])
    print(f"  Celdas activas: {active_cells} L3 con DUP asignado")

    summary = build_summary(etb, dups, matrix)
    print(f"  KPIs: informix_only={summary['informix_only_l3']} | dup_mapped={summary['dup_mapped_l3']} | blockers={summary['blockers']}")

    output = {
        "meta": {"generated_at": datetime.now().isoformat(), "version": "1.0.0"},
        "summary": summary,
        "l1s": etb["l1s"],
        "l2s": etb["l2s"],
        "l3s": etb["l3s"],
        "dups": dups,
        "matrix": matrix,
        "systems": SYSTEMS,
    }

    OUT.parent.mkdir(parents=True, exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)

    size_kb = OUT.stat().st_size // 1024
    print(f"\n  duplicidad-etb.json: {OUT} ({size_kb} KB)")


if __name__ == "__main__":
    main()
