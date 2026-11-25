#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
load-incidents.py — Carga los incidentes de Control de Cambios al brain.

Lee `knowledge-base/incidentes-cc.json` (que produce extract-incidents.py desde
los reportes corporativos) y lo materializa en `brain.db::incidents`.

Va en su propio cargador y no dentro de build-brain.py porque la fuente es
documental, no el código: build-brain.py se reconstruye del fuente Java y
elimina sus tablas en cada corrida, mientras que esta vive del corpus de
`source/docs/`.

Uso:
  python generators/load-incidents.py
"""
import json
import sqlite3
import sys
from collections import Counter
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
DB = BASE / "digital-brain" / "brain.db"
ORIGEN = BASE / "knowledge-base" / "incidentes-cc.json"

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

DDL = """
CREATE TABLE IF NOT EXISTS incidents (
    id                TEXT PRIMARY KEY,
    fecha             TEXT NOT NULL,
    incidentes        TEXT,      -- folios IMS, separados por coma
    ccs               TEXT,      -- folios de Control de Cambios
    aplicacion        TEXT,      -- cadena original del reporte
    servicios         TEXT,      -- servicios tocados, separados por coma
    afectacion        TEXT,
    afectacion_canal  TEXT,      -- redacción del reporte específico de App, si existe
    nivel_evidencia   TEXT,
    patron            TEXT,      -- mecanismo de falla, según la sección 4 de los reportes
    afecta_appmovil   INTEGER DEFAULT 0,
    en_reporte_canal  INTEGER DEFAULT 0,
    cronologia        TEXT,      -- narrativa de la sección 3, cuando el caso la trae
    fuentes           TEXT
);
CREATE INDEX IF NOT EXISTS ix_incidents_fecha ON incidents(fecha);
CREATE INDEX IF NOT EXISTS ix_incidents_patron ON incidents(patron);
"""


def identidad(r, n):
    """Identificador estable y legible: INC-CC-{fecha}-{folio o consecutivo}."""
    sufijo = (r["incidentes"] or r["ccs"] or [f"{n:02d}"])[0]
    return f"INC-CC-{r['fecha'].replace('-', '')}-{sufijo}"


def main():
    if not ORIGEN.exists():
        print(f"ERROR: falta {ORIGEN}. Corre antes extract-incidents.py")
        return 1
    if not DB.exists():
        print(f"ERROR: no hay brain.db en {DB}")
        return 1

    datos = json.loads(ORIGEN.read_text(encoding="utf-8"))
    filas = datos["incidentes"]

    con = sqlite3.connect(DB)
    con.executescript(DDL)
    # La tabla refleja el corpus documental completo: se reescribe entera para
    # que un incidente retirado del reporte no quede colgado en el brain.
    con.execute("DELETE FROM incidents")

    vistos = set()
    registros = []
    for n, r in enumerate(filas, 1):
        ident = identidad(r, n)
        while ident in vistos:          # dos incidentes el mismo día sin folio
            ident += "b"
        vistos.add(ident)
        registros.append((
            ident, r["fecha"],
            ",".join(r["incidentes"]), ",".join(r["ccs"]),
            r["aplicacion"], ",".join(r["servicios"]),
            r["afectacion"], r.get("afectacion_canal", ""),
            r["nivel_evidencia"], r["patron"],
            1 if r["afecta_appmovil"] else 0,
            1 if r["en_reporte_canal"] else 0,
            r["cronologia"], ",".join(r["fuentes"]),
        ))

    con.executemany("""
        INSERT INTO incidents
        (id, fecha, incidentes, ccs, aplicacion, servicios, afectacion,
         afectacion_canal, nivel_evidencia, patron, afecta_appmovil,
         en_reporte_canal, cronologia, fuentes)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    """, registros)
    con.commit()

    total = con.execute("SELECT COUNT(*) FROM incidents").fetchone()[0]
    app = con.execute("SELECT COUNT(*) FROM incidents WHERE afecta_appmovil=1").fetchone()[0]
    por_patron = dict(con.execute(
        "SELECT patron, COUNT(*) FROM incidents GROUP BY patron ORDER BY 2 DESC"))
    con.close()

    print(f"brain.db::incidents -> {total} incidentes cargados")
    print(f"  tocan AppMovil    : {app}")
    print(f"  por patrón        : {por_patron}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
