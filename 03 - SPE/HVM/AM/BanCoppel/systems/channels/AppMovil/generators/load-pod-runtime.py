#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
load-pod-runtime.py — Lleva la evidencia de ejecucion de los pods al brain.

Lee `knowledge-base/runtime-pods.json` (que produce parse-pod-logs.py desde
`source/logs/`) y lo materializa en `brain.db::runtime_*`.

Va en su propio cargador y no dentro de build-brain.py por la misma razon que
load-incidents.py: build-brain.py se reconstruye del fuente Java y borra sus
propias tablas en cada corrida. Esta evidencia viene de produccion, no del
codigo, y tiene que sobrevivir a esos rebuilds.

El lote va en la llave primaria de todas las tablas. Es la leccion de e-global:
dos capturas del mismo servicio en ventanas distintas son dos hechos, no uno que
pisa al otro. La agregacion, si hace falta, ocurre en la consulta.

Uso:
  python generators/load-pod-runtime.py
"""
import json
import sqlite3
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
DB = BASE / "digital-brain" / "brain.db"
ORIGEN = BASE / "knowledge-base" / "runtime-pods.json"

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

DDL = """
CREATE TABLE IF NOT EXISTS runtime_pods (
    lote           TEXT NOT NULL,
    archivo        TEXT NOT NULL,
    service        TEXT,          -- nombre del pod, con su sufijo de variante
    service_base   TEXT,          -- sin la variante: enlaza con services.id
    variante       TEXT,          -- b, c... la letra que distingue el despliegue
    pod            TEXT,
    replicaset     TEXT,
    app            TEXT,
    version        TEXT,          -- la que reporta el arranque de Spring
    java           TEXT,
    window_start   TEXT,
    window_end     TEXT,
    lineas         INTEGER,
    transacciones  INTEGER,
    tx_con_error   INTEGER,
    tx_p50_ms      INTEGER,
    tx_p95_ms      INTEGER,
    tx_max_ms      INTEGER,
    repositorios   TEXT,          -- JSON array, las entidades que declara Spring Data
    PRIMARY KEY (lote, archivo)
);

CREATE TABLE IF NOT EXISTS runtime_operations (
    lote       TEXT NOT NULL,
    service    TEXT,
    tipo       TEXT NOT NULL,     -- SERVICE CALL | REPOSITORY CALL | BUSINESS SERVICE | ...
    operacion  TEXT NOT NULL,     -- el nombre de negocio, en espanol, del propio codigo
    calls      INTEGER,
    errors     INTEGER,
    p50_ms     INTEGER,
    p95_ms     INTEGER,
    max_ms     INTEGER,
    origenes   TEXT,              -- JSON array clase:metodo:linea, amarra con source/code
    PRIMARY KEY (lote, tipo, operacion)
);

CREATE TABLE IF NOT EXISTS runtime_endpoints (
    lote      TEXT NOT NULL,
    service   TEXT,
    endpoint  TEXT NOT NULL,
    calls     INTEGER,
    errors    INTEGER,
    p50_ms    INTEGER,
    p95_ms    INTEGER,
    max_ms    INTEGER,
    PRIMARY KEY (lote, endpoint)
);

CREATE TABLE IF NOT EXISTS runtime_errors (
    lote       TEXT NOT NULL,
    service    TEXT,
    code       TEXT NOT NULL,     -- codigo interno del servicio
    tipo       TEXT,
    details    TEXT,              -- el texto que ve el cliente en la app
    location   TEXT,
    operacion  TEXT,              -- la validacion de negocio que lo levanto
    hits       INTEGER,
    PRIMARY KEY (lote, code)
);
"""


def main():
    if not ORIGEN.exists():
        sys.exit(f"No existe {ORIGEN}. Corre antes generators/parse-pod-logs.py")
    if not DB.exists():
        sys.exit(f"No existe {DB}. Corre antes digital-brain/build-brain.py")

    datos = json.loads(ORIGEN.read_text(encoding="utf-8"))
    con = sqlite3.connect(DB)
    con.executescript(DDL)

    for pod in datos["pods"]:
        lote, svc = pod["lote"], pod["service"]
        # Recargar un lote lo reemplaza entero; nunca mezcla con otro.
        for t in ("runtime_pods", "runtime_operations", "runtime_endpoints", "runtime_errors"):
            con.execute(f"DELETE FROM {t} WHERE lote = ?", (lote,))

        d = pod.get("duracion_tx") or {}
        con.execute(
            "INSERT INTO runtime_pods VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (lote, pod["archivo"], svc, pod["service_base"], pod["variante"],
             pod["pod"], pod["replicaset"], pod["app"],
             pod["version"], pod["java"], pod["window_start"], pod["window_end"],
             pod["lineas"], pod["transacciones"], pod["transacciones_con_error"],
             d.get("p50_ms"), d.get("p95_ms"), d.get("max_ms"),
             json.dumps(pod["repositorios"], ensure_ascii=False)))

        con.executemany(
            "INSERT INTO runtime_operations VALUES (?,?,?,?,?,?,?,?,?,?)",
            [(lote, svc, o["tipo"], o["operacion"], o["calls"], o["errors"],
              o.get("p50_ms"), o.get("p95_ms"), o.get("max_ms"),
              json.dumps(o["origenes"], ensure_ascii=False)) for o in pod["operaciones"]])

        con.executemany(
            "INSERT INTO runtime_endpoints VALUES (?,?,?,?,?,?,?,?)",
            [(lote, svc, e["endpoint"], e["calls"], e["errors"],
              e.get("p50_ms"), e.get("p95_ms"), e.get("max_ms")) for e in pod["endpoints"]])

        con.executemany(
            "INSERT INTO runtime_errors VALUES (?,?,?,?,?,?,?,?)",
            [(lote, svc, e["code"], e["type"], e["details"], e["location"],
              e["operacion"], e["hits"]) for e in pod["errores"]])

        print(f"  {svc} [{lote}]: {len(pod['operaciones'])} operaciones, "
              f"{len(pod['endpoints'])} endpoints, {len(pod['errores'])} codigos de error")

    con.commit()

    # Lo que corre en produccion contra lo que declara el repositorio. Esta es la
    # razon de ser de la evidencia de ejecucion: el pom dice una cosa y el pod otra.
    print()
    for base, vprod, jprod, vrepo, jrepo in con.execute("""
        SELECT p.service_base, p.version, p.java, s.version, s.java_version
          FROM runtime_pods p LEFT JOIN services s ON s.id = p.service_base
         ORDER BY p.service_base
    """):
        if vrepo is None:
            print(f"  {base}: sin fila en el catalogo estatico")
            continue
        difiere = (vprod or "").lstrip("v") != (vrepo or "") or (jprod or "").split(".")[0] != (jrepo or "")
        print(f"  {base}")
        print(f"     produccion: {vprod} sobre Java {jprod}")
        print(f"     catalogo  : {vrepo} sobre Java {jrepo}"
              f"{'   <-- difiere' if difiere else ''}")
    con.close()


if __name__ == "__main__":
    main()
