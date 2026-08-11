#!/usr/bin/env python3
"""
rebuild-capability-model.py — Pipeline completo del modelo de capacidades BCOPCore

Pasos (en orden obligatorio):
  1. build-sp-capabilities.py   → tabla sp_capabilities + capability-sp-mapping.json base
  2. build-sp-fine-mapping.py   → añade key_sps_fine + prod_calls al JSON
  2.5 build-sp-capability-map.py → tabla sp_capability_map (propagación grafo)
      Baseline replicable: propaga fine-grained L3 assignments via call graph
      bidireccional (leaf→seed + seed→shared). Cobertura: ~47% vs 34.7% seed.
  3. build-capability-model.py  → genera capability-model-bcop.html + capability-model-bcop-v2.html

El orden importa: el paso 3 lee el JSON que escribe el paso 2, que a su vez completa el JSON
del paso 1. El paso 2.5 es independiente del JSON pero debe correr después del paso 2 para
tener sp_capabilities actualizado como fuente del seed. Correr en cualquier otro orden
produce key_sps_fine vacíos o HTML desactualizado.
"""
import subprocess, sys, time
from pathlib import Path

BASE = Path(__file__).parent

STEPS = [
    ("SP Capabilities (junction + JSON base)",        "build-sp-capabilities.py"),
    ("SP Fine Mapping (key_sps_fine + prod_calls)",   "build-sp-fine-mapping.py"),
    ("SP Capability Map (graph propagation baseline)", "build-sp-capability-map.py"),
    ("Capability Model HTML (bcop + bcop-v2)",        "build-capability-model.py"),
]

def run(script: str) -> bool:
    result = subprocess.run(
        [sys.executable, str(BASE / script)],
        capture_output=False,
    )
    return result.returncode == 0


def main():
    print("=" * 60)
    print("  BCOPCore — Rebuild Capability Model")
    print("=" * 60)
    total_start = time.time()

    for i, (label, script) in enumerate(STEPS, 1):
        print(f"\n[{i}/{len(STEPS)}] {label}")
        print(f"      > {script}")
        t0 = time.time()
        ok = run(script)
        elapsed = time.time() - t0
        status = "OK" if ok else "FAILED"
        print(f"      {status} ({elapsed:.1f}s)")
        if not ok:
            print(f"\nPipeline abortado en paso {i}: {script}")
            sys.exit(1)

    total = time.time() - total_start
    print(f"\n{'=' * 60}")
    print(f"  Pipeline completado en {total:.1f}s")
    print(f"  Outputs:")
    print(f"    portal/data/capability-sp-mapping.json")
    print(f"    digital-brain/brain.db :: sp_capability_map (graph propagation)")
    print(f"    portal/capability-model-bcop.html")
    print(f"    portal/capability-model-bcop-v2.html")
    print("=" * 60)


if __name__ == "__main__":
    main()
