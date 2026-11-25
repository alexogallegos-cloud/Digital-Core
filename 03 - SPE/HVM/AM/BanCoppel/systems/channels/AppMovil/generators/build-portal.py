#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-portal.py — Landing del portal AppMovil.

Es el otro arquetipo del canon de Informix: barra `nav`, aurora animada,
secciones y tarjetas de vista. A diferencia de las páginas de contenido, la
landing lleva ilustración propia, así que su maqueta vive en
`generators/_landing.html` y aquí solo se rellenan las cifras en vivo.

Las cifras salen de `brain.db` y del vocabulario curado: ninguna se escribe a
mano en el HTML, que es la regla del portal.

Uso:
  python generators/build-portal.py
"""
import importlib.util
import json
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
CURADO = canon.KB / "vocabulario-curado.json"

# Los cuatro SPs verificados a mano, que el análisis estático no puede ubicar.
# La lista vive también en build-sp-portal.py; al tocar una hay que tocar la otra.
HUECOS = {
    ("bdicred", "sp_proyecta_prest_credisol"),
    ("intercard", "sp_registro_cte_cvv2din"),
    ("intercard", "sp_activatarjeta_iccat"),
    ("bdinteg", "sp_valida_celular_cancelado"),
}


def cifras():
    con = sqlite3.connect(canon.DB)
    q = lambda s: con.execute(s).fetchone()[0]

    pares = {(d.lower(), s.lower()) for d, s in con.execute(
        "SELECT db_name, sp_name FROM sp_calls "
        "UNION SELECT db_name, sp_name FROM sp_properties") if s}
    todos = pares | HUECOS

    datos = {
        "__MSAS__": q("SELECT COUNT(*) FROM services"),
        "__SPS__": len({s for _, s in todos}),
        "__BASES__": len({d for d, _ in todos}),
        "__TERMINOS__": q("SELECT COUNT(*) FROM terms"),
        "__REGLAS__": q("SELECT COUNT(*) FROM rules"),
    }
    try:
        datos["__INCIDENTES__"] = q("SELECT COUNT(*) FROM incidents")
        datos["__INC_APP__"] = q("SELECT COUNT(*) FROM incidents WHERE afecta_appmovil=1")
    except sqlite3.OperationalError:      # todavía no se cargó el corpus documental
        datos["__INCIDENTES__"] = 0
        datos["__INC_APP__"] = 0
    con.close()

    curado = json.loads(CURADO.read_text(encoding="utf-8"))
    datos["__CURADOS__"] = len(curado["terminos"])
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
        print(f"   {k:14} {v}")
    print(f"HTML : {SALIDA}  ({len(html):,} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
