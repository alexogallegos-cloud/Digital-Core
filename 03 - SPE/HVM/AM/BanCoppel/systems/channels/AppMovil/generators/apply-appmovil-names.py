#!/usr/bin/env python3
"""
apply-appmovil-names.py — Fusiona nombres heurísticos + scatter-gather y los aplica a rules-data.json
BanCoppel AppMovil · SPE-AM-001

Fuentes de business_name (prioridad descendente):
  1. scatter-gather VALIDACIÓN results  (knowledge-base/rules/batches/validacion/results/batch_NN_result.json)
  2. heurísticos ANOTACIÓN/CONF/UMBRAL  (knowledge-base/rules/name-overrides-appmovil-heuristic.json)

Salida:
  - rules-data.json actualizado in-place (backup -> rules-data.json.bak)
  - Imprime estadísticas de cobertura

Uso:
  python generators/apply-appmovil-names.py [--dry-run]
"""

import json
import sys
import shutil
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE = Path(__file__).parent.parent
RULES_PATH = BASE / "portal" / "data" / "rules-data.json"
HEURISTIC_PATH = BASE / "knowledge-base" / "rules" / "name-overrides-appmovil-heuristic.json"
RESULTS_DIR = BASE / "knowledge-base" / "rules" / "batches" / "validacion" / "results"

DRY_RUN = "--dry-run" in sys.argv


def load_heuristic():
    if not HEURISTIC_PATH.exists():
        print(f"[WARN] No encontrado: {HEURISTIC_PATH}")
        return {}
    data = json.loads(HEURISTIC_PATH.read_text(encoding="utf-8"))
    print(f"Heurísticos cargados: {len(data)}")
    return data


def load_scatter_gather():
    if not RESULTS_DIR.exists():
        print(f"[WARN] Directorio de resultados no existe: {RESULTS_DIR}")
        return {}
    overrides = {}
    loaded_batches = []
    for f in sorted(RESULTS_DIR.glob("batch_*_result.json")):
        try:
            data = json.loads(f.read_text(encoding="utf-8"))
            results = data.get("results", {})
            overrides.update(results)
            loaded_batches.append(f.name)
        except Exception as e:
            print(f"[ERROR] {f.name}: {e}")
    print(f"Scatter-gather batches: {len(loaded_batches)} — {len(overrides)} nombres")
    return overrides


def main():
    heuristic = load_heuristic()
    scatter = load_scatter_gather()

    # Fusionar: scatter > heuristic
    all_overrides = {}
    all_overrides.update(heuristic)
    all_overrides.update(scatter)
    print(f"Nombres disponibles total: {len(all_overrides)}")

    rules = json.loads(RULES_PATH.read_text(encoding="utf-8"))
    total = len(rules)
    applied = 0
    already_had = 0
    not_found = []

    for r in rules:
        rid = r.get("id", "")
        if r.get("business_name"):
            already_had += 1
            continue
        if rid in all_overrides:
            r["business_name"] = all_overrides[rid]
            applied += 1
        else:
            not_found.append(rid)

    coverage = (total - len(not_found)) / total * 100 if total else 0

    print()
    print(f"Total reglas       : {total}")
    print(f"Ya tenían nombre   : {already_had}")
    print(f"Aplicados ahora    : {applied}")
    print(f"Sin nombre aún     : {len(not_found)}")
    print(f"Cobertura          : {coverage:.1f}%")

    if not_found:
        print()
        print("Reglas sin business_name (primeras 20):")
        for rid in not_found[:20]:
            print(f"  {rid}")
        if len(not_found) > 20:
            print(f"  ... y {len(not_found) - 20} más")

    if DRY_RUN:
        print()
        print("[DRY RUN] No se escribió nada.")
        return

    # Backup + write
    bak = RULES_PATH.with_suffix(".json.bak")
    shutil.copy2(RULES_PATH, bak)
    RULES_PATH.write_text(
        json.dumps(rules, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print()
    print(f"Backup guardado en  : {bak.name}")
    print(f"rules-data.json actualizado ({total} reglas · {coverage:.1f}% con nombre)")


if __name__ == "__main__":
    main()