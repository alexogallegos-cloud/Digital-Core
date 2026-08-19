#!/usr/bin/env python3
"""
export-validacion-batches.py — Exporta reglas VALIDACIÓN en lotes para scatter-gather
BanCoppel AppMovil · SPE-AM-001

Agrupa las 774 reglas VALIDACIÓN por source_file (para minimizar lecturas de archivo por agente)
y las parte en lotes de ~70 reglas. Cada lote incluye:
  - Las reglas a nombrar (id, sp, source_file, code, domain, line)
  - Lista de source_files únicos que el agente debe leer (con path absoluto)

Salida: knowledge-base/rules/batches/validacion/batch_NN.json (11 lotes aprox.)

Uso:
  python generators/export-validacion-batches.py
"""

import json
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE = Path(__file__).parent.parent
# La base para resolver source_file es el directorio 'channels' (padre de AppMovil)
BASE_CHANNELS = BASE.parent
RULES_PATH = BASE / "portal" / "data" / "rules-data.json"
BATCHES_DIR = BASE / "knowledge-base" / "rules" / "batches" / "validacion"
BATCH_SIZE = 70

TIPO_VALID = "VALIDACI\xd3N"


def main():
    rules = json.loads(RULES_PATH.read_text(encoding="utf-8"))
    val_rules = [r for r in rules if r.get("tipo") == TIPO_VALID]
    print(f"Total VALIDACIÓN: {len(val_rules)}")

    # Agrupar por source_file (mantener reglas del mismo archivo juntas)
    from collections import defaultdict
    by_file = defaultdict(list)
    for r in val_rules:
        sf = r.get("source_file", "")
        by_file[sf].append(r)

    # Ordenar archivos por número de reglas descendente (archivos grandes primero → batches más uniformes)
    sorted_files = sorted(by_file.keys(), key=lambda sf: -len(by_file[sf]))

    # Crear batches greedy: agregar archivos al batch actual hasta llegar a BATCH_SIZE
    batches = []
    current_batch = []
    for sf in sorted_files:
        file_rules = by_file[sf]
        # Si el archivo solo no cabe en el batch actual Y ya hay algo, cerrar el batch
        if current_batch and len(current_batch) + len(file_rules) > BATCH_SIZE:
            batches.append(current_batch)
            current_batch = []
        current_batch.extend(file_rules)
    if current_batch:
        batches.append(current_batch)

    print(f"Lotes generados: {len(batches)}")

    BATCHES_DIR.mkdir(parents=True, exist_ok=True)

    for i, batch_rules in enumerate(batches):
        # Recolectar source_files únicos + sus paths absolutos
        source_files_set = {}
        for r in batch_rules:
            sf = r.get("source_file", "")
            if sf and sf not in source_files_set:
                abs_path = BASE_CHANNELS / sf
                source_files_set[sf] = str(abs_path)

        # Construir payload del batch
        batch = {
            "batch_id": i + 1,
            "total_batches": len(batches),
            "total_rules_in_batch": len(batch_rules),
            "source_files": source_files_set,
            "rules": [
                {
                    "id": r.get("id", ""),
                    "tipo": r.get("tipo", ""),
                    "sp": r.get("sp", ""),
                    "source_file": r.get("source_file", ""),
                    "line": r.get("line", 0),
                    "code": r.get("code", ""),
                    "domain": r.get("domain", ""),
                    "reg": r.get("reg", ""),
                    "riesgo": r.get("riesgo", ""),
                }
                for r in batch_rules
            ],
        }

        out_path = BATCHES_DIR / f"batch_{i+1:02d}.json"
        out_path.write_text(
            json.dumps(batch, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )
        sfs = len(source_files_set)
        print(f"  batch_{i+1:02d}.json — {len(batch_rules):3} reglas · {sfs:3} archivos")

    print()
    print(f"Batches guardados en: {BATCHES_DIR}")
    print()
    print("Siguiente paso:")
    print("  Lanzar agentes scatter-gather sobre cada batch.")
    print("  Cada agente lee los source_files y genera:")
    print('  {"batch_id": N, "results": {"BR-AM-xxx": "business_name", ...}}')
    print(f"  Guardar en: {BATCHES_DIR}/results/batch_NN_result.json")
    print()
    print("  Luego: python generators/apply-appmovil-names.py")


if __name__ == "__main__":
    main()