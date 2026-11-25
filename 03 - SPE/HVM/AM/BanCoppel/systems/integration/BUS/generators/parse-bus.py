#!/usr/bin/env python3
"""
parse-bus.py — Extractor de conocimiento de negocio del BUS
BanCoppel Application Modernization · SPE-AM-001

El BUS (IBM Integration Bus) registra cada traza en XML propio, con el namespace
`http://www.bancoppel.com/Logger`. Cada linea es una traza con esta forma:

  <trace>
    <idTrxGlobal>..</idTrxGlobal>
    <sistemaOrigen>OFI_WEB</sistemaOrigen>
    <referencia>ValFechasWeb_20261030_100000</referencia>
    <servicio>Cliente2</servicio>
    <trama>ifx_bdinteg call informix.val_fechas_web('001', '2026-10-30'); || </trama>
    <estatus>success</estatus>
  </trace>

Que extrae:
  1. Catalogo de servicios con su tasa de error real (del campo estatus)
  2. Sistemas origen, clasificados: el campo NO esta disciplinado y hay que separar
     nombres de sistema de operaciones, vacios y numeros
  3. Mapa servicio -> datasource -> stored procedure de Informix, que es la
     dependencia cuantificada con el core
  4. Operaciones invocadas por servicio
  5. Volumetria por hora
  6. Firmas de error normalizadas

PCI y PII: el campo `trama` lleva los parametros reales de la llamada, que incluyen
numeros de cuenta, tarjetas y datos de cliente. Este extractor NO persiste ninguna
trama ni ningun valor de parametro: del trama solo deriva estructura (datasource,
nombre del procedure, numero de parametros). `idTrxGlobal` tampoco se guarda.

Uso:
  python parse-bus.py [--batch revision-bus-20261030] [--jobs N]
"""

import argparse
import collections
import glob
import gzip
import hashlib
import json
import os
import re
import sys
from datetime import datetime, timezone
from multiprocessing import Pool
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

SCRIPT_DIR = Path(__file__).resolve().parent
SYSTEM_DIR = SCRIPT_DIR.parent
LOGS_DIR = SYSTEM_DIR / "source" / "logs"
OUT_DIR = SYSTEM_DIR / "digital-brain" / "data"
EXTRACTOR_VERSION = "1.0.0"

MUESTRAS_POR_FIRMA = 2

# ── Campos de la traza ───────────────────────────────────────────
#
# Los campos de texto se acotan con [^<]* a proposito. El escritor del log corta
# lineas a la mitad y concatena el siguiente registro, asi que una captura no
# acotada cruza la frontera del registro y se traga el XML entero, incluido el
# idTrxGlobal. Eso ensucia los catalogos y arrastra identificadores de cliente.
RE_ORIGEN = re.compile(r"<sistemaOrigen>([^<]*)</sistemaOrigen>")
RE_SERVICIO = re.compile(r"<servicio>([^<]*)</servicio>")
RE_REFERENCIA = re.compile(r"<referencia>([^<]*)</referencia>")
RE_ESTATUS = re.compile(r"<estatus>([^<]*)</estatus>")
# El trama si puede traer XML y JSON anidados, pero nunca se persiste su valor:
# solo se deriva estructura y, en errores, una firma normalizada.
RE_TRAMA = re.compile(r"<trama>(.*?)</trama>", re.S)

# ── Estructura del trama ─────────────────────────────────────────
RE_SP = re.compile(r"(?:(ifx_[a-z0-9_]+)\s+)?call\s+informix\.([a-z0-9_]+)\s*\(", re.I)
RE_REF = re.compile(r"^(.*?)_(\d{8})_(\d{6})$")

# Clasificacion del campo sistemaOrigen, que no esta disciplinado
RE_NOMBRE_SISTEMA = re.compile(r"^[A-Z][A-Z0-9_]{2,}(?: [A-Z0-9_]+)*$")


def clasificar_origen(valor):
    """
    El campo sistemaOrigen trae cuatro cosas distintas. Clasificarlas es
    obligatorio: contar los valores distintos como si fueran sistemas da
    un inventario falso.
    """
    v = (valor or "").strip()
    if not v or v == "-":
        return "vacio"
    if v.isdigit():
        return "numerico"
    if RE_NOMBRE_SISTEMA.match(v):
        return "sistema"
    return "operacion"


def familia_origen(valor):
    """Agrupa las grafias del mismo sistema: OFI_WEB, OFIWEB, OFI_WEBC."""
    v = (valor or "").strip().upper().replace(" ", "_")
    return re.sub(r"_+", "_", v).strip("_")


def firma_error(trama):
    """
    Normaliza el trama de un error a una firma comparable. Nunca devuelve datos
    del cliente: se eliminan los valores entre comillas, los numeros, las tiras
    hexadecimales largas (identificadores SOAP, bloques EMV y de PIN) y los
    caracteres de control que algunos procedures devuelven en crudo.
    """
    t = trama or ""
    t = "".join(ch if ch.isprintable() or ch in " \t" else " " for ch in t)
    t = re.sub(r"'[^']*'", "'?'", t)
    t = re.sub(r'"[^"]*"', '"?"', t)
    t = re.sub(r"\b[0-9A-Fa-f]{8,}\b", "<hex>", t)
    t = re.sub(r"\b\d+\b", "N", t)
    t = re.sub(r"\s+", " ", t).strip()
    return t[:180]


class Acc:
    def __init__(self):
        self.servicios = collections.Counter()
        self.servicios_error = collections.Counter()
        self.origenes = collections.Counter()
        self.origenes_error = collections.Counter()
        self.origen_clase = {}
        self.origen_familia = {}
        self.sp_calls = collections.Counter()          # (datasource, sp)
        self.sp_error = collections.Counter()
        self.servicio_sp = collections.Counter()       # (servicio, datasource, sp)
        self.servicio_origen = collections.Counter()   # (servicio, origen)
        self.operaciones = collections.Counter()
        self.trama_clase = collections.Counter()
        self.por_hora = collections.Counter()
        self.por_hora_error = collections.Counter()
        self.firmas = collections.Counter()
        self.muestras = collections.defaultdict(list)
        self.trazas = 0

    def dict(self):
        j = lambda c: {"|".join(k): v for k, v in c.items()}
        return {
            "servicios": dict(self.servicios),
            "servicios_error": dict(self.servicios_error),
            "origenes": dict(self.origenes),
            "origenes_error": dict(self.origenes_error),
            "origen_clase": self.origen_clase,
            "origen_familia": self.origen_familia,
            "sp_calls": j(self.sp_calls),
            "sp_error": j(self.sp_error),
            "servicio_sp": j(self.servicio_sp),
            "servicio_origen": j(self.servicio_origen),
            "operaciones": dict(self.operaciones),
            "trama_clase": dict(self.trama_clase),
            "por_hora": dict(self.por_hora),
            "por_hora_error": dict(self.por_hora_error),
            "firmas": dict(self.firmas),
            "muestras": {k: v for k, v in self.muestras.items()},
            "trazas": self.trazas,
        }


def abrir(path):
    if path.endswith(".gz"):
        return gzip.open(path, "rt", errors="replace")
    return open(path, "r", errors="replace")


def parse_file(path):
    acc = Acc()
    nombre = os.path.basename(path)
    es_error_log = nombre.startswith("errores_bus")
    n_lineas = 0
    h = hashlib.sha256()

    # la hora viene en el nombre: transacciones_bus_20261030_10.txt
    # el sufijo (1) lo agrega el navegador al descargar dos veces el mismo archivo
    m = re.search(r"_(\d{8})_(\d{2})(?:\(\d+\))?\.txt", nombre)
    hora_archivo = f"{m.group(1)}-{m.group(2)}" if m else "desconocida"

    with abrir(path) as fh:
        for linea in fh:
            n_lineas += 1
            h.update(linea[:120].encode("utf-8", "replace"))
            if "<trace>" not in linea and "<servicio>" not in linea:
                continue

            acc.trazas += 1
            ms = RE_SERVICIO.search(linea)
            servicio = ms.group(1).strip() if ms else "(sin servicio)"
            me = RE_ESTATUS.search(linea)
            estatus = me.group(1).strip().lower() if me else ("error" if es_error_log else "desconocido")
            es_error = estatus == "error" or es_error_log

            acc.servicios[servicio] += 1
            if es_error:
                acc.servicios_error[servicio] += 1

            mo = RE_ORIGEN.search(linea)
            origen = mo.group(1).strip() if mo else ""
            # Algun llamador pone numeros largos en el campo. Como nombre de sistema
            # no aportan nada y pueden ser identificadores de cliente, asi que se
            # enmascaran: del valor solo sobrevive su longitud.
            if origen.isdigit() and len(origen) >= 8:
                origen = f"(numero de {len(origen)} digitos)"
            clave_origen = origen or "(vacio)"
            acc.origenes[clave_origen] += 1
            if es_error:
                acc.origenes_error[clave_origen] += 1
            if clave_origen not in acc.origen_clase:
                acc.origen_clase[clave_origen] = clasificar_origen(origen)
                acc.origen_familia[clave_origen] = familia_origen(origen)
            acc.servicio_origen[(servicio, clave_origen)] += 1

            mr = RE_REFERENCIA.search(linea)
            if mr:
                mref = RE_REF.match(mr.group(1).strip())
                if mref:
                    acc.operaciones[mref.group(1)] += 1

            acc.por_hora[hora_archivo] += 1
            if es_error:
                acc.por_hora_error[hora_archivo] += 1

            mt = RE_TRAMA.search(linea)
            if mt:
                trama = mt.group(1)
                # si el registro venia truncado, corta donde empieza el siguiente
                for marca in ("<Out>", "<NS1:Log"):
                    pos = trama.find(marca)
                    if pos > 0:
                        trama = trama[:pos]
                msp = RE_SP.search(trama)
                if msp:
                    ds = (msp.group(1) or "").lower()
                    sp = msp.group(2).lower()
                    acc.trama_clase["stored-procedure"] += 1
                    acc.sp_calls[(ds, sp)] += 1
                    acc.servicio_sp[(servicio, ds, sp)] += 1
                    if es_error:
                        acc.sp_error[(ds, sp)] += 1
                elif "REQUEST_BUS" in trama:
                    acc.trama_clase["peticion-json"] += 1
                else:
                    acc.trama_clase["otro"] += 1

                if es_error:
                    firma = firma_error(trama)
                    acc.firmas[firma] += 1
                    if len(acc.muestras[firma]) < MUESTRAS_POR_FIRMA:
                        acc.muestras[firma].append(
                            {"servicio": servicio, "origen": clave_origen,
                             "hora": hora_archivo})

    return ({
        "archivo": nombre,
        # el nodo vive en el nombre de la carpeta: BUS1-puresys10. Forma parte de
        # la identidad del archivo: el mismo nombre se repite en los cuatro nodos.
        "nodo": os.path.basename(os.path.dirname(path)),
        "tipo": "errores" if es_error_log else "transacciones",
        "bytes": os.path.getsize(path),
        "lineas": n_lineas,
        "trazas": acc.trazas,
        "hora": hora_archivo,
        "sha256_prefijo": h.hexdigest()[:16],
    }, acc.dict())


def firma_archivo(path):
    """
    Firma barata para detectar archivos repetidos: tamaño mas hash del primer y
    ultimo megabyte. Las descargas de Drive duplican archivos con sufijo (1), y
    contarlos dos veces infla la volumetria.
    """
    tam = os.path.getsize(path)
    h = hashlib.sha256(str(tam).encode())
    with open(path, "rb") as fh:
        h.update(fh.read(1 << 20))
        if tam > (2 << 20):
            fh.seek(-(1 << 20), os.SEEK_END)
            h.update(fh.read(1 << 20))
    return h.hexdigest()


def descartar_duplicados(archivos):
    """Devuelve (archivos unicos, descartados) conservando el primero de cada firma."""
    vistos, unicos, descartados = {}, [], []
    for a in archivos:
        try:
            f = firma_archivo(a)
        except OSError:
            unicos.append(a)
            continue
        if f in vistos:
            descartados.append((os.path.basename(a), os.path.basename(vistos[f])))
        else:
            vistos[f] = a
            unicos.append(a)
    return unicos, descartados


def fusionar(total, parcial):
    for clave, valor in parcial.items():
        if clave == "trazas":
            total[clave] = total.get(clave, 0) + valor
        elif clave in ("origen_clase", "origen_familia"):
            total.setdefault(clave, {}).update(valor)
        elif clave == "muestras":
            d = total.setdefault(clave, {})
            for k, v in valor.items():
                lista = d.setdefault(k, [])
                lista.extend(v[: max(0, MUESTRAS_POR_FIRMA - len(lista))])
        elif isinstance(valor, dict):
            d = total.setdefault(clave, {})
            for k, v in valor.items():
                d[k] = d.get(k, 0) + v
    return total


def main():
    ap = argparse.ArgumentParser(description="Extrae conocimiento de los logs del BUS")
    ap.add_argument("--batch")
    ap.add_argument("--jobs", type=int, default=max(1, (os.cpu_count() or 4) - 1))
    args = ap.parse_args()

    lotes = [LOGS_DIR / args.batch] if args.batch else sorted(
        p for p in LOGS_DIR.iterdir() if p.is_dir())
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    for lote in lotes:
        archivos = sorted(glob.glob(str(lote / "*" / "*_bus_*.txt"))
                          + glob.glob(str(lote / "*" / "*_bus_*.txt.gz")))
        if not archivos:
            print(f"[!] {lote.name}: sin archivos *_bus_*.txt")
            continue

        archivos, duplicados = descartar_duplicados(archivos)
        print(f"\n[{lote.name}] {len(archivos)} archivos · {args.jobs} procesos")
        for dup, original in duplicados:
            print(f"  [duplicado descartado] {dup} es copia de {original}")
        total, fuentes = {}, []
        with Pool(args.jobs) as pool:
            for meta, parcial in pool.imap_unordered(parse_file, archivos):
                fuentes.append(meta)
                fusionar(total, parcial)

        fuentes.sort(key=lambda m: (m["tipo"], m["nodo"], m["archivo"]))
        salida = {
            "lote": lote.name,
            "extractor": "parse-bus.py",
            "extractor_version": EXTRACTOR_VERSION,
            "generado": datetime.now(timezone.utc).isoformat(),
            "fuentes": fuentes,
            "agregados": total,
        }
        destino = OUT_DIR / f"{lote.name}.json"
        destino.write_text(json.dumps(salida, ensure_ascii=False, indent=1), encoding="utf-8")

        trazas = total.get("trazas", 0)
        errores = sum(total.get("servicios_error", {}).values())
        clases = collections.Counter(total.get("origen_clase", {}).values())
        print(f"  trazas: {trazas:,} · errores: {errores:,} "
              f"({100*errores/trazas if trazas else 0:.2f}%)")
        print(f"  servicios: {len(total.get('servicios', {}))}")
        print(f"  stored procedures de Informix: {len(total.get('sp_calls', {}))}")
        print(f"  pares servicio-procedure: {len(total.get('servicio_sp', {}))}")
        print(f"  operaciones: {len(total.get('operaciones', {}))}")
        print(f"  valores de sistemaOrigen: {len(total.get('origenes', {}))} "
              f"-> {dict(clases)}")
        print(f"  -> {destino}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
