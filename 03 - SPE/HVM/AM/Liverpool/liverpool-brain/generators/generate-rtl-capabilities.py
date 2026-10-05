#!/usr/bin/env python3
"""
generate-rtl-capabilities.py
Convierte rtb-capabilities.json (IDs: RTB-001…232)
a rtl-capabilities.json  (IDs: RTL.{L1}.{seq:02d})

Lógica de ID:
  - Extrae número de L1 del campo l1_name  ("1. Interaction Channels" → 1)
  - Asigna seq secuencial dentro de cada L1 empezando en 01
  - Resultado: RTL.1.01, RTL.1.02 … RTL.9.34

Ejecutar desde liverpool-brain/:
    python generators/generate-rtl-capabilities.py
"""

import json, re
from pathlib import Path
from collections import defaultdict

BRAIN_DIR = Path(__file__).parent.parent
SRC  = BRAIN_DIR / "rtb-capabilities.json"
DEST = BRAIN_DIR / "rtl-capabilities.json"


def l1_num(name: str) -> int:
    m = re.match(r"^(\d+)", name.strip())
    return int(m.group(1)) if m else 0


def main():
    with open(SRC, encoding="utf-8-sig") as f:
        data = json.loads(f.read(), strict=False)

    counters: dict[int, int] = defaultdict(int)
    new_caps = []

    for cap in data["capabilities"]:
        n = l1_num(cap.get("l1_name", ""))
        counters[n] += 1
        new_id = f"RTL.{n}.{counters[n]:02d}"

        new_caps.append({
            "id":          new_id,
            "old_rtb_id":  cap["id"],          # referencia al ID original RTB-XXX
            "l1_num":      n,
            "l1_name":     cap.get("l1_name", ""),
            "l2_name":     cap.get("l2_name", ""),
            "l3_name":     cap.get("l3_name", ""),
            "description": cap.get("description", ""),
            "source_etb":  "retail",
            "source":      cap.get("source", "Retail_ETB_V5"),
        })

    output = {
        "metadata": {
            **data["metadata"],
            "id_format":    "RTL.{L1}.{seq:02d}",
            "source_etb":   "retail",
            "migrated_from": "rtb-capabilities.json",
            "migrated_at":  "2026-09-02",
            "l1_groups": {
                str(k): v for k, v in sorted(counters.items())
            },
        },
        "capabilities": new_caps,
    }

    with open(DEST, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)

    print(f"rtl-capabilities.json generado: {len(new_caps)} caps")
    print("Distribución por L1:")
    for k, v in sorted(counters.items()):
        print(f"  RTL.{k}.xx  {v:3d} caps")


if __name__ == "__main__":
    main()