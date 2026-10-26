#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-equivalencia.py — Lleva al brain la capa de Equivalencia Funcional, que
hasta ahora vivia solo como markdown fuera del portal.

Dos fuentes, ambas en GemCog/:
  migration-risk-register.md   181 riesgos MR-{CAP}-{NN} con severidad, patron y
                               accion requerida, bajo taxonomia N1..N5.
  equivalencia-strategy.md     estrategia golden-master y reparto de los campos
                               COMP-3 por bounded context, que es lo que define
                               el alcance real de la prueba de equivalencia.

El registro trae 32 tablas de catalogo y 4 vistas cruzadas que re-listan IDs ya
catalogados; solo las primeras producen filas, o el total saldria inflado.

Ademas reconcilia contra la tabla hallazgos que ya vive en el brain, que es un
registro distinto y mas sucio, y reporta la divergencia en vez de elegir una
callando la otra.

USO:
    PYTHONUTF8=1 python generators/build-equivalencia.py [--dry-run]
"""

from __future__ import annotations

import json
import re
import sqlite3
import sys
from collections import Counter, defaultdict
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

BASE = Path(__file__).resolve().parent.parent
DB = BASE / "digital-brain" / "brain.db"
KB = BASE / "knowledge-base" / "equivalencia"
GEMCOG = BASE.parent.parent.parent / "GemCog"
REGISTRO = GEMCOG / "migration-risk-register.md"
ESTRATEGIA = GEMCOG / "equivalencia-strategy.md"

SEVERIDADES = ["DEFECTO-PROD", "BLOQUEADOR", "CRÍTICO", "ALTO", "MEDIO", "BAJO", "RESUELTO"]
ORDEN_SEV = {s: i for i, s in enumerate(SEVERIDADES)}

# Encabezados de columna equivalentes entre las variantes de tabla del registro.
ALIAS = {
    "id": "riesgo_id",
    "severidad": "severidad", "sev": "severidad",
    "patrón": "patrones", "patron": "patrones",
    "n5: tarea(s)": "ancla", "fuente": "ancla", "n5: tarea": "ancla",
    "descripción del riesgo": "descripcion", "riesgo": "descripcion", "descripción": "descripcion",
    "acción requerida": "accion", "mitigación": "accion", "reemplazo target": "accion",
}

RE_N12 = re.compile(r"^###\s+N1:\s*(.+?)\s+—\s+N2:\s*(.+?)\s*$")
RE_N34 = re.compile(r"^####\s+N3:\s*(.+?)\s+—\s+N4:\s*(.+?)\s*$")
RE_SEP = re.compile(r"^\|[\s:|-]+\|$")
RE_ID = re.compile(r"^(MR|H)-([A-Z]{2,4})-(\d+)$")


def limpia(c: str) -> str:
    """Quita formato markdown y emoji de severidad de una celda."""
    c = c.strip()
    c = re.sub(r"[🔴🟠🟡🟢⚠️]", "", c)
    c = re.sub(r"\*\*(.+?)\*\*", r"\1", c)
    c = re.sub(r"`(.+?)`", r"\1", c)
    return " ".join(c.split())


def normaliza_sev(s: str) -> str:
    s = limpia(s).upper().replace("CRITICO", "CRÍTICO")
    for sev in SEVERIDADES:
        if sev in s:
            return sev
    return s or "SIN CLASIFICAR"


def filas_de_tabla(lineas: list[str], i: int):
    """Lee una tabla markdown desde su encabezado. Devuelve (dicts, i_final)."""
    cab = [limpia(c).lower() for c in lineas[i].strip().strip("|").split("|")]
    if i + 1 >= len(lineas) or not RE_SEP.match(lineas[i + 1].strip()):
        return [], i
    campos = [ALIAS.get(c, c) for c in cab]
    out, j = [], i + 2
    n = len(campos)
    while j < len(lineas) and lineas[j].lstrip().startswith("|"):
        celdas = [c for c in lineas[j].strip().strip("|").split("|")]
        # Un `||` de SQL dentro de backticks parte la fila de mas: el excedente
        # pertenece a la ultima columna y se vuelve a unir.
        if len(celdas) > n:
            celdas = celdas[:n - 1] + ["|".join(celdas[n - 1:])]
        if len(celdas) == n:
            out.append({campos[k]: limpia(celdas[k]) for k in range(n)})
        j += 1
    return out, j


def parsea_registro():
    lineas = REGISTRO.read_text(encoding="utf-8").splitlines()
    n1 = n2 = n3 = n4 = ""
    riesgos, vistas = [], 0
    i = 0
    while i < len(lineas):
        l = lineas[i]
        if (m := RE_N12.match(l)):
            n1, n2 = m.group(1), m.group(2)
            n3 = n4 = ""
        elif (m := RE_N34.match(l)):
            n3, n4 = m.group(1), m.group(2)
        elif l.lstrip().startswith("|"):
            filas, fin = filas_de_tabla(lineas, i)
            if filas:
                if "severidad" in filas[0]:
                    for f in filas:
                        rid = limpia(f.get("riesgo_id", ""))
                        if not RE_ID.match(rid):
                            continue
                        pat = f.get("patrones", "")
                        riesgos.append({
                            "riesgo_id": rid,
                            "cap_slug": RE_ID.match(rid).group(2).lower(),
                            "severidad": normaliza_sev(f.get("severidad", "")),
                            "patrones": pat,
                            "patron_principal": re.split(r"\s*[·+]\s*", pat)[0] if pat else "",
                            "n1": n1, "n2": n2, "n3": n3, "n4": n4,
                            "ancla": f.get("ancla", ""),
                            "descripcion": f.get("descripcion", ""),
                            "accion": f.get("accion", ""),
                        })
                elif any(RE_ID.match(limpia(f.get("riesgo_id", ""))) for f in filas):
                    vistas += 1          # vista cruzada: re-lista IDs ya catalogados
                i = fin
                continue
        i += 1

    # Un ID puede aparecer en el catalogo y luego en el triaje de la Ola 4;
    # gana la ultima aparicion, que es la revisada por el SME.
    por_id = {r["riesgo_id"]: r for r in riesgos}
    return sorted(por_id.values(),
                  key=lambda r: (ORDEN_SEV.get(r["severidad"], 9), r["riesgo_id"])), vistas


RE_BC = re.compile(r"^\|\s*(BC-\d+)\s*\|")


def parsea_estrategia():
    """Tabla de reparto de campos COMP-3 por bounded context (seccion 3)."""
    filas = []
    for l in ESTRATEGIA.read_text(encoding="utf-8").splitlines():
        if not RE_BC.match(l.strip()):
            continue
        c = [limpia(x) for x in l.strip().strip("|").split("|")]
        if len(c) < 7:
            continue
        def num(s):
            d = re.sub(r"[^\d]", "", s)
            return int(d) if d else 0
        filas.append({"bc_id": c[0], "nombre": c[1], "sistema": c[2], "wave": num(c[3]),
                      "campos_comp3": num(c[4]), "pct": c[5], "tier1": num(c[6])})
    return filas


DDL = """
CREATE TABLE IF NOT EXISTS riesgos_migracion (
  riesgo_id TEXT PRIMARY KEY, cap_slug TEXT, severidad TEXT, patrones TEXT,
  patron_principal TEXT, n1 TEXT, n2 TEXT, n3 TEXT, n4 TEXT, ancla TEXT,
  descripcion TEXT, accion TEXT);
CREATE TABLE IF NOT EXISTS equivalencia_bc (
  bc_id TEXT PRIMARY KEY, nombre TEXT, sistema TEXT, wave INTEGER,
  campos_comp3 INTEGER, pct TEXT, tier1 INTEGER);
CREATE INDEX IF NOT EXISTS ix_riesgos_sev ON riesgos_migracion(severidad);
CREATE INDEX IF NOT EXISTS ix_riesgos_cap ON riesgos_migracion(cap_slug);
"""


def carga(riesgos, bcs):
    con = sqlite3.connect(DB)
    con.executescript(DDL)
    con.execute("DELETE FROM riesgos_migracion")
    con.execute("DELETE FROM equivalencia_bc")
    con.executemany(
        "INSERT INTO riesgos_migracion (riesgo_id,cap_slug,severidad,patrones,patron_principal,"
        "n1,n2,n3,n4,ancla,descripcion,accion) VALUES (:riesgo_id,:cap_slug,:severidad,:patrones,"
        ":patron_principal,:n1,:n2,:n3,:n4,:ancla,:descripcion,:accion)", riesgos)
    con.executemany(
        "INSERT INTO equivalencia_bc (bc_id,nombre,sistema,wave,campos_comp3,pct,tier1)"
        " VALUES (:bc_id,:nombre,:sistema,:wave,:campos_comp3,:pct,:tier1)", bcs)
    con.commit()
    con.close()


def reconcilia(riesgos):
    """hallazgos y riesgos_migracion son registros distintos. Se mide el solape
    por texto para saber si uno absorbe al otro o si cuentan cosas diferentes."""
    con = sqlite3.connect(DB)
    con.row_factory = sqlite3.Row
    try:
        hall = con.execute("SELECT hallazgo_id, cap_slug, severidad, riesgo FROM hallazgos").fetchall()
    except sqlite3.OperationalError:
        return None
    finally:
        con.close()

    def huella(t):
        return frozenset(w for w in re.findall(r"[a-záéíóúñ]{5,}", (t or "").lower()))

    hs = [(h["hallazgo_id"], huella(h["riesgo"])) for h in hall]
    solape = 0
    for r in riesgos:
        hr = huella(r["descripcion"])
        if not hr:
            continue
        if any(len(hr & hh) / max(len(hr | hh), 1) > 0.5 for _, hh in hs if hh):
            solape += 1
    vacias = sum(1 for h in hall if not (h["severidad"] or "").strip())
    return {"hallazgos": len(hall), "sin_severidad": vacias, "solape": solape}


def main():
    seco = "--dry-run" in sys.argv
    for f in (REGISTRO, ESTRATEGIA):
        if not f.is_file():
            sys.exit(f"ERROR: falta {f}")

    riesgos, vistas = parsea_registro()
    bcs = parsea_estrategia()

    print("EQUIVALENCIA FUNCIONAL — capa 7")
    print("=" * 66)
    print(f"  riesgos catalogados : {len(riesgos)}   (vistas cruzadas ignoradas: {vistas})")
    sev = Counter(r["severidad"] for r in riesgos)
    for s in SEVERIDADES:
        if sev.get(s):
            print(f"       {sev[s]:4d}  {s}")
    otras = {k: v for k, v in sev.items() if k not in ORDEN_SEV}
    for k, v in otras.items():
        print(f"       {v:4d}  {k}  <-- revisar")

    pat = Counter(r["patron_principal"] for r in riesgos if r["patron_principal"])
    print("\n  PATRONES DE RIESGO")
    for p, n in pat.most_common(9):
        print(f"       {n:4d}  {p}")

    print(f"\n  campos COMP-3 por bounded context: {len(bcs)} BC"
          f" · {sum(b['campos_comp3'] for b in bcs)} campos"
          f" · {sum(b['tier1'] for b in bcs)} tier-1")

    rec = reconcilia(riesgos)
    if rec:
        print("\n  RECONCILIACION CON hallazgos (registro preexistente del brain)")
        print(f"       hallazgos en el brain        : {rec['hallazgos']}")
        print(f"       hallazgos sin severidad      : {rec['sin_severidad']}")
        print(f"       riesgos con equivalente textual: {rec['solape']} de {len(riesgos)}")

    if seco:
        print("\n--dry-run: no se escribio nada")
        return 0

    KB.mkdir(parents=True, exist_ok=True)
    (KB / "riesgos-migracion.json").write_text(json.dumps(riesgos, ensure_ascii=False, indent=1), encoding="utf-8")
    (KB / "equivalencia-bc.json").write_text(json.dumps(bcs, ensure_ascii=False, indent=1), encoding="utf-8")
    carga(riesgos, bcs)
    print(f"\n  JSON en {KB}")
    print(f"  cargado en {DB.name}: riesgos_migracion, equivalencia_bc")
    return 0


if __name__ == "__main__":
    sys.exit(main())
