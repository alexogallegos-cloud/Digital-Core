#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
parse-pod-logs.py — Destila los logs de pod de OpenShift a conocimiento de negocio.

Los microservicios de AppMovil escriben una bitacora con mas estructura de la que
aparenta. Cada linea trae, en este orden:

    NIVEL, fecha hora,ms, clase:metodo:linea, idCorrelacion, mensaje, latencia

y el mensaje de negocio viene entre corchetes, en espanol, escrito por el propio
desarrollador: "Recupera la informacion general de una cuenta.", "Consulta el MTU
del cliente". Eso vale mas que cualquier nombre inferido — es la Regla V1 servida
por el codigo, no por un heuristico.

Una transaccion se delimita sola: abre con `Inicia Llamado [endpoint]` y cierra con
`Time elapsed for request/response roundtrip`. En medio va el arbol de llamadas con
su latencia por paso. Los errores abren un bloque de cinco lineas con el codigo
interno y, lo mas util, el texto que termina viendo el cliente.

Lo que NO se persiste: el log no trae payloads ni datos de cliente (verificado), y
aun asi este extractor solo guarda catalogos, conteos y estadisticas de latencia.
Si una version futura del servicio empieza a loguear cuerpos, `enmascara()` es el
punto donde hay que atajarlo.

Uso:
  python generators/parse-pod-logs.py
  python generators/parse-pod-logs.py --lote pod-deposit-account-validation-20261030
"""
import argparse
import json
import re
import statistics
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
LOGS = BASE / "source" / "logs"
SALIDA = BASE / "knowledge-base" / "runtime-pods.json"

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

# NIVEL, 2026-10-30 17:00:23,353, clase:metodo:linea, idCorrelacion, resto
RE_LINEA = re.compile(
    r"^(?P<nivel>TRACE|DEBUG|INFO|WARN|ERROR|FATAL),\s+"
    r"(?P<ts>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}),(?P<ms>\d{3}),\s+"
    r"(?P<origen>[^,]*?),\s*"
    r"(?P<corr>[0-9a-fA-F-]{0,36}),\s*"
    r"(?P<resto>.*)$"
)

# "Tx SERVICE CALL - [descripcion], 302"  y tambien "... [descripcion] 0".
# El separador de la latencia es coma en casi todas las clases y espacio en
# JwtDecoderBusiness. Aceptar ambos o se pierden 34 mil lineas.
RE_TX = re.compile(
    r"^Tx (?P<err>Err )?(?P<tipo>[A-Z]+(?: [A-Z]+)?) - \[(?P<desc>[^\]]*)\]"
    r"(?:,?\s*(?P<lat>\d+))?"
)
RE_INICIA = re.compile(r"^Inicia Llamado \[(?P<endpoint>[^\]]*)\]")
RE_FIN = re.compile(r"^Time elapsed for request/response roundtrip \[(?P<endpoint>[^\]]*)\]"
                    r"[^0-9]*(?P<lat>\d+)?")
RE_ERRCAMPO = re.compile(r"^(?P<campo>type|code|details|location|moreInfo):\s*(?P<valor>.*)$")

# clase:metodo:linea — la clase viene abreviada por el patron de logback (c.b.d.a.v)
RE_ORIGEN = re.compile(r"^(?P<clase>[^:]+):(?P<metodo>[^:]+):(?P<linea>\d+)$")

# Metadatos que el arranque de Spring regala gratis
RE_ARRANQUE = re.compile(r"Starting (?P<app>\w+) (?P<version>v[\w.-]+) using Java (?P<java>[\w.]+)")
RE_REPO = re.compile(r"repository candidate interface ([\w.]+\.(\w+Repository))")

# Cualquier tira de digitos larga que se cuele en una descripcion. Hoy no hay
# ninguna; esta aqui porque un cambio de logueo no deberia convertirse en fuga.
RE_DIGITOS = re.compile(r"\b\d{8,}\b")


def enmascara(texto: str) -> str:
    """Ninguna tira larga de digitos sobrevive a un artefacto versionable."""
    if not texto:
        return texto
    return RE_DIGITOS.sub(lambda m: f"(numero de {len(m.group(0))} digitos)", texto)


def estadisticas(valores: list) -> dict:
    """p50, p95 y maximo. Sin la lista cruda: interesa la forma, no cada medicion."""
    if not valores:
        return {}
    v = sorted(valores)
    return {
        "p50_ms": int(statistics.median(v)),
        "p95_ms": int(v[min(len(v) - 1, int(len(v) * 0.95))]),
        "max_ms": int(v[-1]),
    }


def identifica_lote(ruta: Path) -> dict:
    """El nombre del archivo trae el microservicio, su variante y el pod.

    El sufijo de una sola letra (`-b`, `-c`) es la variante del servicio, no parte
    de su identidad: el catalogo estatico del brain registra
    `msach-o-business-deposit-account-validation` y el pod se llama `...-b`. Hay que
    separarlos o el cruce contra `services` no encuentra nada.
    """
    nombre = ruta.stem
    # msach-o-business-deposit-account-validation-b-28-2mlhp-msach-o-business-...
    m = re.match(r"^(?P<svc>.+?)-(?P<rs>\d+)-(?P<pod>[a-z0-9]{5})-", nombre)
    svc = m.group("svc") if m else nombre
    v = re.match(r"^(?P<base>.+)-(?P<variante>[a-z])$", svc)
    return {
        "service": svc,
        "service_base": v.group("base") if v else svc,
        "variante": v.group("variante") if v else None,
        "replicaset": m.group("rs") if m else None,
        "pod": m.group("pod") if m else None,
    }


def procesa(ruta: Path, lote: str) -> dict:
    meta = identifica_lote(ruta)
    ops = defaultdict(lambda: {"calls": 0, "errors": 0, "lat": [], "origenes": set()})
    txs = {}
    errores = defaultdict(lambda: {"hits": 0, "type": None, "details": None,
                                   "location": None, "operacion": None})
    endpoints = defaultdict(lambda: {"calls": 0, "lat": [], "errors": 0})
    repos, arranque = set(), {}
    lineas = sin_patron = 0
    primera = ultima = None
    err_actual = {}

    with ruta.open(encoding="utf-8", errors="replace") as fh:
        for cruda in fh:
            lineas += 1
            cruda = cruda.rstrip("\n")

            if not arranque:
                a = RE_ARRANQUE.search(cruda)
                if a:
                    arranque = {"app": a.group("app"), "version": a.group("version"),
                                "java": a.group("java")}
            r = RE_REPO.search(cruda)
            if r:
                repos.add(r.group(2))

            m = RE_LINEA.match(cruda)
            if not m:
                sin_patron += 1
                continue

            ts, corr, resto = m.group("ts"), m.group("corr"), m.group("resto")
            primera = primera or ts
            ultima = ts

            o = RE_ORIGEN.match(m.group("origen") or "")
            origen = f"{o.group('clase')}:{o.group('metodo')}:{o.group('linea')}" if o else None

            # -- apertura de transaccion
            ini = RE_INICIA.match(resto)
            if ini and corr:
                txs[corr] = {"endpoint": ini.group("endpoint"), "inicio": ts,
                             "pasos": 0, "ms": None, "error": None}
                continue

            # -- cierre de transaccion
            fin = RE_FIN.match(resto)
            if fin and corr:
                tx = txs.setdefault(corr, {"endpoint": fin.group("endpoint"), "inicio": ts,
                                           "pasos": 0, "ms": None, "error": None})
                tx["ms"] = int(fin.group("lat")) if fin.group("lat") else None
                ep = endpoints[fin.group("endpoint")]
                ep["calls"] += 1
                if tx["ms"] is not None:
                    ep["lat"].append(tx["ms"])
                if tx["error"]:
                    ep["errors"] += 1
                continue

            # -- paso de negocio
            tx = RE_TX.match(resto)
            if tx:
                desc = enmascara(tx.group("desc").strip())
                tipo = tx.group("tipo").strip()
                clave = f"{tipo}|{desc}"
                d = ops[clave]
                d["calls"] += 1
                if origen:
                    d["origenes"].add(origen)
                if tx.group("lat"):
                    d["lat"].append(int(tx.group("lat")))
                if tx.group("err"):
                    d["errors"] += 1
                    err_actual = {"operacion": desc}
                if corr in txs:
                    txs[corr]["pasos"] += 1
                continue

            # -- bloque de error: type / code / details / location / moreInfo
            ec = RE_ERRCAMPO.match(resto)
            if ec and m.group("nivel") == "ERROR":
                err_actual[ec.group("campo")] = enmascara(ec.group("valor").strip())
                if ec.group("campo") == "moreInfo":        # cierra el bloque
                    cod = err_actual.get("code") or "sin-codigo"
                    e = errores[cod]
                    e["hits"] += 1
                    for k in ("type", "details", "location", "operacion"):
                        e[k] = e[k] or err_actual.get(k)
                    if corr in txs:
                        txs[corr]["error"] = cod
                    err_actual = {}
                continue

    catalogo = []
    for clave, d in sorted(ops.items(), key=lambda kv: -kv[1]["calls"]):
        tipo, desc = clave.split("|", 1)
        catalogo.append({
            "operacion": desc, "tipo": tipo, "calls": d["calls"], "errors": d["errors"],
            "origenes": sorted(d["origenes"])[:5], **estadisticas(d["lat"]),
        })

    eps = [{"endpoint": k, "calls": v["calls"], "errors": v["errors"], **estadisticas(v["lat"])}
           for k, v in sorted(endpoints.items(), key=lambda kv: -kv[1]["calls"])]

    duraciones = [t["ms"] for t in txs.values() if t["ms"] is not None]
    con_error = sum(1 for t in txs.values() if t["error"])

    return {
        "lote": lote,
        "archivo": ruta.name,
        "service": meta["service"],
        "service_base": meta["service_base"],
        "variante": meta["variante"],
        "replicaset": meta["replicaset"],
        "pod": meta["pod"],
        "app": arranque.get("app"),
        "version": arranque.get("version"),
        "java": arranque.get("java"),
        "window_start": primera,
        "window_end": ultima,
        "lineas": lineas,
        "lineas_sin_patron": sin_patron,
        "transacciones": len(txs),
        "transacciones_con_error": con_error,
        "duracion_tx": estadisticas(duraciones),
        "repositorios": sorted(repos),
        "operaciones": catalogo,
        "endpoints": eps,
        "errores": [{"code": k, **v} for k, v in sorted(errores.items(), key=lambda kv: -kv[1]["hits"])],
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--lote", help="una sola carpeta de source/logs/")
    args = ap.parse_args()

    if not LOGS.exists():
        sys.exit(f"No existe {LOGS}")

    lotes = [LOGS / args.lote] if args.lote else sorted(d for d in LOGS.iterdir() if d.is_dir())
    salida = []
    for carpeta in lotes:
        if not carpeta.is_dir():
            print(f"  omitido (no es carpeta): {carpeta.name}")
            continue
        archivos = sorted(carpeta.glob("*.log"))
        if not archivos:
            print(f"  sin .log: {carpeta.name}")
            continue
        for ruta in archivos:
            d = procesa(ruta, carpeta.name)
            salida.append(d)
            print(f"  {d['service']} pod {d['pod']}: {d['lineas']:,} lineas, "
                  f"{d['transacciones']:,} transacciones, {len(d['operaciones'])} operaciones, "
                  f"{len(d['errores'])} codigos de error")

    SALIDA.parent.mkdir(parents=True, exist_ok=True)
    SALIDA.write_text(json.dumps({
        "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
        "pods": salida,
    }, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"\n-> {SALIDA}")


if __name__ == "__main__":
    main()
