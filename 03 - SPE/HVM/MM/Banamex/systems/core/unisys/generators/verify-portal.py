"""
verify-portal.py — Compara portal/ generado contra la entrega de referencia.

SOLO LECTURA sobre source/GemCogAlt/. Reporta, por archivo, el número de líneas
de diff unificado (0 = byte-por-byte idéntico) y un resumen global.

Uso:
    python generators/verify-portal.py                 # todos los .html de portal/
    python generators/verify-portal.py pilots          # sólo los 3 pilotos
    python generators/verify-portal.py <substring> ... # filtra por substring de ruta
"""
from __future__ import annotations
import difflib
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
REF = BASE / "source" / "GemCogAlt" / "gemcog-portal-2026-08-26-cliente-entregable"
OUT = BASE / "portal"

PILOTS = ["pseudocodigo/S500_P046.html", "modelo capacidades/cap-pos.html", "index.html"]


def diff_count(rel: str) -> tuple[int, str]:
    """→ (n_lineas_diff, nota).  -1 = falta en referencia; -2 = falta generado."""
    a = REF / rel
    b = OUT / rel
    if not b.exists():
        return -2, "no generado"
    if not a.exists():
        return -1, "no existe en referencia"
    ba, bb = a.read_bytes(), b.read_bytes()
    if ba == bb:
        return 0, "identico"
    la = ba.decode("utf-8", "replace").splitlines()
    lb = bb.decode("utf-8", "replace").splitlines()
    d = list(difflib.unified_diff(la, lb, lineterm=""))
    n = sum(1 for l in d if l[:1] in "+-" and not l.startswith(("+++", "---")))
    note = "bytes ref=%d gen=%d" % (len(ba), len(bb))
    return (n if n else 1), note


def targets(argv):
    if argv and argv[0] == "pilots":
        return PILOTS
    rels = sorted(str(p.relative_to(OUT)).replace("\\", "/")
                  for p in OUT.rglob("*.html"))
    if argv:
        rels = [r for r in rels if any(a in r for a in argv)]
    return rels


def main():
    rels = targets(sys.argv[1:])
    bad = []
    ok = 0
    for rel in rels:
        n, note = diff_count(rel)
        if n == 0:
            ok += 1
        else:
            bad.append((n, rel, note))
    bad.sort(key=lambda t: -t[0])
    print("=" * 70)
    print("diff 0 : %d / %d" % (ok, len(rels)))
    print("con diff: %d" % len(bad))
    print("=" * 70)
    for n, rel, note in bad:
        print("%8d  %-48s %s" % (n, rel, note))
    return 0 if not bad else 1


if __name__ == "__main__":
    sys.exit(main())
