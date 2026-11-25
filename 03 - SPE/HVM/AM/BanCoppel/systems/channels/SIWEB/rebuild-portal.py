#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
rebuild-portal.py — Reconstruye el brain y el portal de SIWEB de punta a punta.

El orden no es decorativo: las vistas leen el brain, así que el brain va primero.

  1. build-brain.py             — servicios de core, puentes, endpoints y pantallas
  2. build-*-portal.py          — las tres vistas de contenido
  3. build-portal.py            — la landing, que resume las cifras de todas

Uso:
  python rebuild-portal.py            reconstruye todo
  python rebuild-portal.py --portal   solo las vistas, sin tocar el brain
"""
import subprocess
import sys
import time
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
BASE = Path(__file__).resolve().parent
PUERTO = 3200

BRAIN = [
    ("digital-brain/build-brain.py", "Brain: servicios de core, puentes, endpoints y pantallas"),
]
PORTAL = [
    ("generators/build-core-portal.py", "Vista: puente al core"),
    ("generators/build-endpoints-portal.py", "Vista: endpoints del canal"),
    ("generators/build-views-portal.py", "Vista: pantallas de ventanilla"),
    ("generators/build-portal.py", "Landing del portal"),
]


def correr(rel, desc, args=()):
    script = BASE / rel
    if not script.exists():
        print(f"  [FALTA] {rel}")
        return False
    t0 = time.time()
    r = subprocess.run([sys.executable, str(script), *args], cwd=BASE,
                       capture_output=True, text=True,
                       encoding="utf-8", errors="replace")
    seg = time.time() - t0
    if r.returncode != 0:
        print(f"  [FALLO] {desc}  ({seg:.1f}s)")
        print((r.stderr or r.stdout).strip()[-900:])
        return False
    lineas = [l for l in (r.stdout or "").splitlines() if l.strip()]
    print(f"  [ok] {desc}  ({seg:.1f}s)")
    for l in lineas[-3:]:
        print(f"       {l.strip()}")
    return True


def main():
    solo_portal = "--portal" in sys.argv

    print("=" * 70)
    print(f"  SIWEB · {'portal' if solo_portal else 'brain y portal'}")
    print("=" * 70)

    fallos = 0
    if not solo_portal:
        for rel, desc in BRAIN:
            if not correr(rel, desc, ("--reset",)):
                fallos += 1
    for rel, desc in PORTAL:
        if not correr(rel, desc):
            fallos += 1

    pasos = len(PORTAL) + (0 if solo_portal else len(BRAIN))
    print("=" * 70)
    if fallos:
        print(f"  Terminado con {fallos} fallo(s) de {pasos} pasos")
    else:
        print(f"  Los {pasos} pasos terminaron bien")
    print(f"  Servir con:  python -m http.server {PUERTO} --bind 127.0.0.1")
    print(f"  Portal en :  http://localhost:{PUERTO}/portal/index.html")
    print("=" * 70)
    return 1 if fallos else 0


if __name__ == "__main__":
    raise SystemExit(main())
