#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
rebuild-portal.py — Reconstruye el brain y el portal de AppMovil de punta a punta.

El orden no es decorativo:
  1. build-brain.py          — servicios, SPs, endpoints, vocabulario, dependencias
  2. extract-rules-java.py   — catálogo de reglas; se ancla en el vocabulario del
                               brain, así que tiene que correr DESPUÉS del paso 1
  3. build-java-analysis.py  — métricas de calidad para dt-java-analysis
  4. extract/load-incidents  — corpus documental de source/docs al brain
  5. build-*-portal.py       — las vistas, que leen el brain ya reconstruido

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

BRAIN = [
    ("digital-brain/build-brain.py", "Brain: servicios, SPs, endpoints y vocabulario"),
    ("generators/extract-rules-java.py", "Reglas de negocio (se ancla en el vocabulario)"),
    ("generators/build-java-analysis.py", "Métricas de calidad Java"),
    ("generators/extract-incidents.py", "Incidentes de CC desde source/docs"),
    ("generators/load-incidents.py", "Incidentes al brain"),
]
PORTAL = [
    ("generators/build-rules-portal.py", "Vista: catálogo de reglas"),
    ("generators/build-sp-portal.py", "Vista: dependencias SP"),
    ("generators/build-vocab-portal.py", "Vista: vocabulario"),
    ("generators/build-incidents-portal.py", "Vista: incidentes por Control de Cambios"),
    ("generators/build-portal.py", "Landing del portal"),
]


def correr(rel, desc):
    script = BASE / rel
    if not script.exists():
        print(f"  [FALTA] {rel}")
        return False
    t0 = time.time()
    r = subprocess.run([sys.executable, str(script)], cwd=BASE,
                       capture_output=True, text=True,
                       encoding="utf-8", errors="replace")
    seg = time.time() - t0
    if r.returncode != 0:
        print(f"  [FALLO] {desc}  ({seg:.1f}s)")
        print((r.stderr or r.stdout).strip()[-900:])
        return False
    ultima = [l for l in (r.stdout or "").splitlines() if l.strip()]
    print(f"  [ok] {desc}  ({seg:.1f}s)")
    for l in ultima[-3:]:
        print(f"       {l.strip()}")
    return True


def main():
    solo_portal = "--portal" in sys.argv
    pasos = PORTAL if solo_portal else BRAIN + PORTAL

    print("=" * 66)
    print(f"  AppMovil · {'portal' if solo_portal else 'brain y portal'}")
    print("=" * 66)

    fallos = 0
    for rel, desc in pasos:
        if not correr(rel, desc):
            fallos += 1

    print("=" * 66)
    if fallos:
        print(f"  Terminado con {fallos} fallo(s) de {len(pasos)} pasos")
    else:
        print(f"  Los {len(pasos)} pasos terminaron bien")
    print("  Servir con:  python -m http.server 3100 --bind 127.0.0.1")
    print("  Portal en :  http://localhost:3100/portal/index.html")
    print("=" * 66)
    return 1 if fallos else 0


if __name__ == "__main__":
    raise SystemExit(main())
