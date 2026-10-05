#!/usr/bin/env python3
"""
Liverpool — Pipeline completo de reconstrucción del brain y el portal.

build-liverpool-brain.py recrea el esquema desde cero, de modo que toda carga
posterior (SUD, tickets, cobertura) se pierde si no se vuelve a aplicar. Este
script encadena los pasos en el orden correcto para que el brain quede íntegro
con una sola ejecución.

    python rebuild-all.py             # pipeline completo
    python rebuild-all.py --portal    # solo regenerar vistas del portal
"""
import argparse
import subprocess
import sys
from pathlib import Path

BRAIN = Path(__file__).parent

# (script, obligatorio) — los opcionales se saltan si su fuente no está disponible
BRAIN_STEPS = [
    ("build-liverpool-brain.py",             True),
    ("generators/extract-from-dashboard.py", True),
    ("generators/extract-sap-source.py",     True),
    ("generators/load-sud-to-brain.py",      True),
    ("generators/load-tickets-to-brain.py",  False),
    ("generators/build-etb-coverage.py",     True),
    ("generators/build-capability-mapping.py", False),
    ("generators/load-cadena-valor-tickets.py", False),
    ("generators/load-procesos-criticos.py",   False),
    ("generators/load-ams-applications.py",   False),
]

PORTAL_STEPS = [
    ("generators/build-portal.py",              True),
    ("generators/build-cadena-valor.py",        True),
    ("generators/build-mapa-capacidades.py",    True),
    ("generators/build-systems-catalog.py",     True),
    ("generators/build-capability-coverage.py", False),
    ("generators/build-ams-tickets.py",         False),
    ("generators/build-cadena-valor-tickets.py", False),
    ("generators/build-procesos-criticos.py",   False),
    ("generators/build-ams-applications.py",    False),
    ("generators/build-rules-catalog.py",       True),
    ("generators/build-vocab-catalog.py",       True),
    ("generators/build-interfaces-map.py",      True),
    ("generators/build-table-lineage.py",       True),
    ("generators/build-migration-complexity.py", True),
    ("generators/build-priority-ranking.py",    True),
    ("generators/build-dependency-graph.py",    True),
    ("generators/build-sap-architecture.py",    True),
    ("generators/build-sap-modular.py",         True),
    ("generators/build-evolution.py",           True),
]


def run(script: str, required: bool) -> bool:
    path = BRAIN / script
    if not path.exists():
        print(f"  omitido (no existe): {script}")
        return not required
    r = subprocess.run([sys.executable, str(path)], cwd=BRAIN,
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    if r.returncode != 0:
        tail = (r.stderr or r.stdout or "").strip().splitlines()
        print(f"  FALLÓ: {script}")
        for line in tail[-6:]:
            print(f"       {line}")
        return not required
    head = [l for l in (r.stdout or "").strip().splitlines() if l.strip()][:2]
    print(f"  ok: {script}")
    for line in head:
        print(f"       {line}")
    return True


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--portal", action="store_true", help="solo regenerar el portal")
    args = ap.parse_args()

    steps = PORTAL_STEPS if args.portal else BRAIN_STEPS + PORTAL_STEPS
    if not args.portal:
        print("== Brain ==")
    failed = []
    for i, (script, required) in enumerate(steps):
        if not args.portal and i == len(BRAIN_STEPS):
            print("\n== Portal ==")
        if args.portal and i == 0:
            print("== Portal ==")
        if not run(script, required):
            failed.append(script)

    print()
    if failed:
        print(f"pipeline terminado con {len(failed)} paso(s) fallido(s):")
        for f in failed:
            print(f"  {f}")
        sys.exit(1)
    print("pipeline completo sin errores")
    print("portal: python -m http.server 8002 --directory portal")


if __name__ == "__main__":
    main()
