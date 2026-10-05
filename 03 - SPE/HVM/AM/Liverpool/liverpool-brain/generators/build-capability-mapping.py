#!/usr/bin/env python3
"""
Liverpool — Consolida el mapeo capacidad ETB <-> aplicación y lo carga al brain.

Dos pasos:
  1. Gather   — junta los mapping_VC-*.json producidos por el swarm de análisis
                y los consolida en portal/data/capability-mapping-liv.json
  2. Load     — vuelca ese catálogo al brain:
                · rtb_l3.primary_system, .liverpool_status, .coverage_confidence, .coverage_note
                · components.rtb_capabilities (lista de capacidades que cubre cada app)
                · capability_coverage — tabla puente capacidad x aplicación (primary/supporting)

El paso 1 se omite si no existe el directorio del swarm: el catálogo consolidado
es la fuente persistente, de modo que el script sigue siendo re-ejecutable sin él.

Uso:
    python generators/build-capability-mapping.py [--swarm RUTA]
"""
import argparse
import json
import sqlite3
from collections import defaultdict
from pathlib import Path

HERE    = Path(__file__).parent
BRAIN   = HERE.parent
DB      = BRAIN / "liverpool-brain.db"
CATALOG = BRAIN / "portal" / "data" / "capability-mapping-liv.json"

VALID_STATUS = {"COVERED", "PARTIAL", "NOT_COVERED", "CROSS_CUTTING"}


def gather(swarm_dir: Path) -> dict | None:
    files = sorted(swarm_dir.glob("mapping_VC-*.json"))
    if not files:
        return None
    mappings, seen = [], set()
    for f in files:
        blob = json.loads(f.read_text(encoding="utf-8"))
        for m in blob.get("mappings", []):
            cap = m.get("cap_id")
            if not cap or cap in seen:
                continue
            seen.add(cap)
            status = (m.get("status") or "").upper()
            mappings.append({
                "cap_id": cap,
                "vc_id": blob.get("vc_id"),
                "primary_system": m.get("primary_system") or None,
                "supporting": m.get("supporting") or [],
                "status": status if status in VALID_STATUS else "NOT_COVERED",
                "confidence": (m.get("confidence") or "low").lower(),
                "rationale": (m.get("rationale") or "").strip(),
            })
    return {"source": "swarm de análisis de cobertura ETB",
            "files": [f.name for f in files], "mappings": mappings}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--swarm", type=Path, default=None,
                    help="directorio con los mapping_VC-*.json del swarm")
    args = ap.parse_args()

    if args.swarm and args.swarm.is_dir():
        blob = gather(args.swarm)
        if blob:
            CATALOG.parent.mkdir(parents=True, exist_ok=True)
            CATALOG.write_text(json.dumps(blob, ensure_ascii=False, indent=1), encoding="utf-8")
            print(f"gather: {len(blob['mappings'])} capacidades desde {len(blob['files'])} archivos")

    if not CATALOG.exists():
        raise SystemExit(f"no existe {CATALOG}; correr primero con --swarm RUTA")

    data = json.loads(CATALOG.read_text(encoding="utf-8"))
    mappings = data["mappings"]

    conn = sqlite3.connect(DB)
    c = conn.cursor()

    for col, decl in (("coverage_confidence", "TEXT"), ("coverage_note", "TEXT")):
        cols = [r[1] for r in c.execute("PRAGMA table_info(rtb_l3)")]
        if col not in cols:
            c.execute(f"ALTER TABLE rtb_l3 ADD COLUMN {col} {decl}")

    c.execute("DROP TABLE IF EXISTS capability_coverage")
    c.execute("""CREATE TABLE capability_coverage (
        cap_id TEXT, app_key TEXT, role TEXT, status TEXT, confidence TEXT,
        PRIMARY KEY (cap_id, app_key, role))""")

    # app_key -> component.id real, para poder poblar components.rtb_capabilities
    known = {r[0] for r in c.execute("SELECT id FROM components").fetchall()}
    by_system = defaultdict(list)
    for cid, sysname in c.execute(
            "SELECT id, source_system FROM components WHERE source_system IS NOT NULL").fetchall():
        by_system[sysname].append(cid)

    caps_of_component = defaultdict(set)
    n_cap = n_edge = unknown = 0

    for m in mappings:
        cap, status = m["cap_id"], m["status"]
        c.execute("""UPDATE rtb_l3 SET primary_system=?, liverpool_status=?,
                     coverage_confidence=?, coverage_note=? WHERE id=?""",
                  (m["primary_system"], status, m["confidence"], m["rationale"], cap))
        n_cap += 1

        for role, keys in (("primary", [m["primary_system"]] if m["primary_system"] else []),
                           ("supporting", m["supporting"])):
            for k in keys:
                if not k:
                    continue
                c.execute("""INSERT OR IGNORE INTO capability_coverage
                             VALUES (?,?,?,?,?)""", (cap, k, role, status, m["confidence"]))
                n_edge += 1
                if k in known:
                    caps_of_component[k].add(cap)
                elif k in by_system:
                    for cid in by_system[k]:
                        caps_of_component[cid].add(cap)
                else:
                    unknown += 1

    c.execute("UPDATE components SET rtb_capabilities=NULL")
    for cid, caps in caps_of_component.items():
        c.execute("UPDATE components SET rtb_capabilities=? WHERE id=?",
                  (json.dumps(sorted(caps)), cid))

    conn.commit()

    print(f"rtb_l3              : {n_cap} capacidades con cobertura declarada")
    print(f"capability_coverage : {n_edge} aristas capacidad-aplicación"
          + (f" ({unknown} con app_key desconocido)" if unknown else ""))
    print(f"components          : {len(caps_of_component)} con rtb_capabilities poblado")
    print()
    print("Cobertura por estado:")
    for st, n in c.execute("""SELECT liverpool_status, COUNT(*) FROM rtb_l3
                              GROUP BY liverpool_status ORDER BY COUNT(*) DESC"""):
        print(f"  {str(st).ljust(14)} {n}")
    print()
    print("Cobertura por eslabón de cadena de valor:")
    for r in c.execute("""SELECT v.id, v.name,
               SUM(CASE WHEN r.liverpool_status='COVERED' THEN 1 ELSE 0 END),
               SUM(CASE WHEN r.liverpool_status='PARTIAL' THEN 1 ELSE 0 END),
               SUM(CASE WHEN r.liverpool_status='NOT_COVERED' THEN 1 ELSE 0 END),
               COUNT(*)
        FROM value_chain v JOIN rtb_l3 r ON r.vc_id=v.id
        GROUP BY v.id ORDER BY v.seq"""):
        pct = round(100 * (r[2] + 0.5 * r[3]) / r[5]) if r[5] else 0
        print(f"  {r[0]}  {str(pct).rjust(3)}%  cubiertas {str(r[2]).rjust(2)} "
              f"parciales {str(r[3]).rjust(2)} sin cobertura {str(r[4]).rjust(2)}   {r[1]}")
    conn.close()


if __name__ == "__main__":
    main()
