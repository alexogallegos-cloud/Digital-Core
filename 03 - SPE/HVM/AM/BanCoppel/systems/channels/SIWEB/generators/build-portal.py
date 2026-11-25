#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-portal.py — Landing del portal SIWEB.

Es el otro arquetipo del canon de Informix: barra `nav`, aurora animada,
secciones y tarjetas de vista. A diferencia de las páginas de contenido, la
landing lleva maqueta propia, que vive en `generators/_landing.html`, y aquí
solo se rellenan las cifras en vivo.

Las cifras salen de `brain.db`: ninguna se escribe a mano en el HTML, que es la
regla del portal.

Uso:
  python generators/build-portal.py
"""
import importlib.util
import sqlite3
import sys
from datetime import date
from pathlib import Path

_spec = importlib.util.spec_from_file_location(
    "_canon", Path(__file__).resolve().parent / "_canon.py")
canon = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(canon)

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

PLANTILLA = Path(__file__).resolve().parent / "_landing.html"
SALIDA = canon.PORTAL / "index.html"


def cifras():
    con = sqlite3.connect(canon.DB)
    q = lambda s: con.execute(s).fetchone()[0]

    datos = {
        "__SERVICIOS__": q("SELECT COUNT(*) FROM ws_services"),
        "__USADOS__": q("SELECT COUNT(*) FROM ws_services WHERE usages > 0"),
        "__SIN_INVOCAR__": q("SELECT COUNT(*) FROM ws_services WHERE usages = 0"),
        "__COMPARTIDOS__": q("SELECT COUNT(*) FROM (SELECT ws_id FROM ws_services "
                             "GROUP BY ws_id HAVING COUNT(*) > 1)"),
        "__PUENTES__": q("SELECT COUNT(*) FROM core_bridges"),
        "__URLS__": q("SELECT COUNT(*) FROM endpoints"),
        "__SIN_PUBLICAR__": q("SELECT COUNT(*) FROM endpoints WHERE controller IS NULL"),
        "__PANTALLAS__": q("SELECT COUNT(*) FROM views"),
        "__AREAS__": q("SELECT COUNT(DISTINCT area) FROM views"),
        "__MODULOS__": q("SELECT COUNT(*) FROM modules"),
        "__JAVA__": q("SELECT MAX(java_files) FROM modules"),
        "__SP__": q("SELECT COUNT(*) FROM sp_calls"),
    }
    con.close()
    datos["__FECHA__"] = date.today().isoformat()
    return datos


def main():
    if not PLANTILLA.exists():
        print(f"ERROR: falta la maqueta {PLANTILLA}")
        return 1

    html = PLANTILLA.read_text(encoding="utf-8")
    datos = cifras()

    # Las cifras van con separador de miles en la prosa y crudas en data-target,
    # que es lo que anima el contador.
    for token, valor in datos.items():
        if token == "__FECHA__":
            html = html.replace(token, str(valor))
            continue
        html = html.replace(f'data-target="{token}"', f'data-target="{valor}"')
        html = html.replace(token, f"{valor:,}" if isinstance(valor, int) else str(valor))

    sobrantes = [t for t in datos if t in html]
    if sobrantes:
        print(f"AVISO: tokens sin sustituir: {sobrantes}")

    SALIDA.write_text(html, encoding="utf-8", newline="\n")
    print("landing generada desde brain.db")
    for k, v in datos.items():
        print(f"   {k:18} {v}")
    print(f"HTML : {SALIDA}  ({len(html):,} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
