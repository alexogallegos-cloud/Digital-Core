"""
sync-brain-to-v3.py — Propaga los business_name sintetizados en brain.db de vuelta
a portal/data/business-rules-v3.json (que es lo que lee gen-rules-portal.py).

brain.db es la fuente autoritativa del business_name (síntesis LLM leída de código
fuente, method='llm_synthesis_source_read'). Como enrich-rules-v3.py regenera v3.json
con business_name vacío, este script re-sincroniza los nombres del cerebro al JSON.

Uso: python digital-brain/sync-brain-to-v3.py
     (gen-rules-portal.py ya hace overlay de brain.db en memoria, así que este
      sync es opcional; úsalo si necesitas v3.json con los nombres materializados)

ADR-SPE-AM-010 · metodología source-read-synthesis
"""
import sqlite3, json, sys
from pathlib import Path

BASE  = Path(__file__).resolve().parent.parent          # Informix/
DB    = BASE / "digital-brain" / "brain.db"
V3    = BASE / "portal" / "data" / "business-rules-v3.json"

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")


def main():
    con = sqlite3.connect(DB)
    names = {rid: bn for rid, bn in con.execute(
        "SELECT id, business_name FROM rules "
        "WHERE business_name IS NOT NULL AND business_name != ''")}
    con.close()
    print(f"Nombres en brain.db: {len(names)}")

    data = json.loads(V3.read_text(encoding="utf-8"))
    updated = 0
    for r in data["rules"]:
        n = names.get(r.get("id"))
        if n and r.get("business_name", "") != n:
            r["business_name"] = n
            updated += 1

    V3.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    empty = sum(1 for r in data["rules"] if not r.get("business_name"))
    print(f"v3.json: {len(data['rules'])} reglas · {updated} actualizadas · {empty} vacías")


if __name__ == "__main__":
    main()
