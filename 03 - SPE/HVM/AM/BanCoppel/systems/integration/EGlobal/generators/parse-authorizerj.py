#!/usr/bin/env python3
"""
parse-authorizerj.py — Extractor de conocimiento de negocio del autorizador e-global
BanCoppel Application Modernization · SPE-AM-001

Lee los logs de produccion del autorizador (`authorizerj-N.log`) y destila el
conocimiento de negocio que contienen, sin persistir datos de tarjetahabiente.

Que extrae (capa de conocimiento, no telemetria):
  1. Catalogo de validaciones de negocio ejecutadas en runtime (IDs + orden + contexto)
  2. Catalogo de funciones del autorizador con su grafo de llamadas real
  3. Mezcla transaccional: tipo de transaccion x codigo x resultado
  4. Mapeo empirico CodRet del core Informix -> codigo de respuesta ISO 8583
  5. Catalogo de modos de entrada (POS entry mode), giros de negocio (MCC) y tokens propietarios
  6. Stored procedures de Informix invocados por el autorizador (cross-dependency con evidencia)

PCI-DSS: el log crudo trae PAN, track2 y nombre del tarjetahabiente en claro.
Este extractor NUNCA escribe esos datos. Del PAN conserva solo BIN (6) y
ultimos 4 digitos, que es lo permitido para analisis. Nombres y saldos se
descartan en la lectura.

Uso:
  python parse-authorizerj.py                      # procesa todos los lotes de source/logs/
  python parse-authorizerj.py --batch authorizerj.eglobal.20261104
  python parse-authorizerj.py --jobs 8             # paralelismo (un proceso por archivo)
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

# Cuantas transacciones de muestra guardar por codigo de respuesta ISO
EVIDENCE_PER_CODE = 3

# ─────────────────────────────────────────────────────────────────
# Patrones de linea
# ─────────────────────────────────────────────────────────────────

RE_ENTRA = re.compile(r"(?:Entrando a|Entrando de)\s+([A-Za-z_][A-Za-z0-9_]*)")
RE_SALE = re.compile(r"(?:Saliendo de|Saliendo a)\s+([A-Za-z_][A-Za-z0-9_]*)")
RE_VALIDACIONES = re.compile(r"Validaciones Efectuadas:\s*(.+?)\s*$")
RE_PEM = re.compile(r"POS ENTRY MODE:\s*(\S+)\s*=\s*(.+?)\s*$")
RE_SP = re.compile(r"EXECUTE PROCEDURE\s+([a-z0-9_]+(?::[a-z0-9_]+)?)\s*\(", re.I)
RE_CODRET = re.compile(r"CodRet:\s*\[(.*?)\]")
RE_RC_ISO = re.compile(r"RETURN CODE:\s*(\w+)")
RE_MCC = re.compile(r"CodGiroNeg:\s*(\d+)")
RE_TIPOTRAN = re.compile(r"BuiltDescription, TipoTran:\s*(\d+)")
RE_TOKEN_OK = re.compile(r"Se encontro Token ([A-Z0-9]{2})\b")
RE_TOKEN_NO = re.compile(r"No se encontro Token ([A-Z0-9]{2})\b")
RE_TOKEN_PASEO = re.compile(r"Se paseo Token ([A-Z0-9]{2})\b")
RE_SEQ = re.compile(r"Secuencia:\s*(\d+)")
RE_BIN = re.compile(r"dbGetTipoTarjeta, BIN:\s*(\d+)")
RE_PAN = re.compile(r"\b(\d{13,19})\b")
RE_GETTYPE = re.compile(
    r"GetTypeOfTransaction, Prod:\s*(\S+)\s*MessType:\s*(\d+)TipoTran:\s*(\d+)"
    r"Monto:\s*([\d.]+)MontoCashBack([\d.]+)"
)
RE_CODIGO_CENTRAL = re.compile(r"Codigo Central:\s*(\w+)")
# Resultados que el HSM devuelve ya calculados por la capa InterAct.
# FF significa que esa validacion no aplica para la transaccion.
RE_HSM = re.compile(r"TRACE (PINRc|CVCRc|CVC2Rc|ARQCRc|CAVVRc|EMVScriptRc)\[(\w*)\]")
HSM_CAMPOS = ("PINRc", "CVCRc", "CVC2Rc", "ARQCRc", "CAVVRc", "EMVScriptRc")
RE_TIPO_ERROR = re.compile(r"Tipo Error:\s*\[(\w*)\]")
RE_LABEL = re.compile(r"TRACE ([A-Z][A-Z_]{3,})\s*$")

# Etiquetas de tipo de transaccion conocidas (lista blanca: evita capturar ruido en mayusculas)
TX_LABELS = {
    "COMPRA_POS", "RETIRO_ATM", "CONSULTA_ATM", "REVERSA_ATM", "REVERSA_POS",
    "CASH_BACK_POS", "VALIDACION_CUENTA", "CONSULTA_POS", "DEPOSITO_ATM",
    "TRANSFERENCIA_ATM", "PAGO_SERVICIOS", "COMPRA_ECOMMERCE",
}

# Marcadores de contexto de negocio dentro del bloque
CONTEXT_FLAGS = {
    "TRANSACCION INTERNACIONAL": "internacional",
    "TRANSACCION CON BIN: BANCOPPEL.": "bin_propio",
    "ES UNA TRANSACCION DIGITADA": "digitada",
    "ES UNA TRANSACCION DE CARGOS AUTOMATICOS": "cargo_automatico",
    "SOPORTA CVV2 DINAMICO": "cvv2_dinamico",
    "TRANSACCION INICIADA POR EL COMERCIO (MIT) !!!": "mit",
    "No entro a validacion OTP": "sin_otp",
    "No entro a validacion HASH": "sin_hash",
    "Es Retiro: SI": "es_retiro",
    "Sin tarjeta: SI": "sin_tarjeta",
}

# Clasificacion de funciones por prefijo/semantica
def classify_function(name):
    if name.startswith("db"):
        return "acceso-datos"
    if name.startswith("Validate") or name.startswith("bTarjeta"):
        return "validacion"
    if name.startswith("Build") or name.startswith("Built"):
        return "construccion-mensaje"
    if name.startswith("Execute"):
        return "invocacion-core"
    if name in ("Autoriza", "RxAutorizaTransaccion", "GetTypeOfTransaction"):
        return "orquestacion"
    return "otro"


def mask_pan(pan):
    """PCI-DSS: del PAN solo sobreviven BIN (6) y ultimos 4."""
    if not pan or len(pan) < 10:
        return None
    return f"{pan[:6]}XXXXXX{pan[-4:]}"


def banda_monto(monto):
    """Agrupa el importe en bandas; no se persisten importes individuales."""
    if monto is None:
        return "desconocido"
    for techo, etiqueta in (
        (100, "0-100"), (500, "100-500"), (1000, "500-1k"),
        (3000, "1k-3k"), (5000, "3k-5k"), (10000, "5k-10k"),
    ):
        if monto < techo:
            return etiqueta
    return "10k+"


class Acumulador:
    """Agregados de un archivo. Se fusionan entre procesos al final."""

    def __init__(self):
        self.validaciones = collections.Counter()
        self.validacion_orden = collections.Counter()      # suma de posiciones
        self.validacion_por_tipo = collections.defaultdict(collections.Counter)
        self.validacion_en_rechazo = collections.Counter()
        self.funciones = collections.Counter()
        self.funcion_ms = collections.Counter()
        self.funcion_max_ms = {}
        self.funcion_por_tipo = collections.defaultdict(collections.Counter)
        self.sps = collections.Counter()
        self.sp_por_tipo = collections.defaultdict(collections.Counter)
        self.tx = collections.Counter()                    # (label, tipotran, messtype, prod)
        self.tx_resultado = collections.Counter()           # (label, outcome, iso_rc)
        self.tx_banda = collections.defaultdict(collections.Counter)
        self.pem = collections.Counter()
        self.pem_desc = {}
        self.mcc = collections.Counter()
        self.mcc_por_tipo = collections.defaultdict(collections.Counter)
        self.tokens = collections.Counter()                 # (token, estado)
        self.codret_host = collections.Counter()
        self.iso_rc = collections.Counter()
        self.mapeo_codigos = collections.Counter()          # (codret_host, iso_rc)
        self.flags = collections.Counter()
        self.flags_por_tipo = collections.defaultdict(collections.Counter)
        self.bins = collections.Counter()
        self.hsm = collections.Counter()            # (campo, valor)
        self.hsm_por_tipo = collections.defaultdict(collections.Counter)
        self.evidencia = collections.defaultdict(list)
        self.n_tx = 0
        self.ts_min = None
        self.ts_max = None

    def to_dict(self):
        return {
            "validaciones": dict(self.validaciones),
            "validacion_orden": dict(self.validacion_orden),
            "validacion_por_tipo": {k: dict(v) for k, v in self.validacion_por_tipo.items()},
            "validacion_en_rechazo": dict(self.validacion_en_rechazo),
            "funciones": dict(self.funciones),
            "funcion_ms": dict(self.funcion_ms),
            "funcion_max_ms": dict(self.funcion_max_ms),
            "funcion_por_tipo": {k: dict(v) for k, v in self.funcion_por_tipo.items()},
            "sps": dict(self.sps),
            "sp_por_tipo": {k: dict(v) for k, v in self.sp_por_tipo.items()},
            "tx": {"|".join(map(str, k)): v for k, v in self.tx.items()},
            "tx_resultado": {"|".join(map(str, k)): v for k, v in self.tx_resultado.items()},
            "tx_banda": {k: dict(v) for k, v in self.tx_banda.items()},
            "pem": dict(self.pem),
            "pem_desc": self.pem_desc,
            "mcc": dict(self.mcc),
            "mcc_por_tipo": {k: dict(v) for k, v in self.mcc_por_tipo.items()},
            "tokens": {"|".join(k): v for k, v in self.tokens.items()},
            "codret_host": dict(self.codret_host),
            "iso_rc": dict(self.iso_rc),
            "mapeo_codigos": {"|".join(k): v for k, v in self.mapeo_codigos.items()},
            "flags": dict(self.flags),
            "flags_por_tipo": {k: dict(v) for k, v in self.flags_por_tipo.items()},
            "bins": dict(self.bins),
            "hsm": {"|".join(k): v for k, v in self.hsm.items()},
            "hsm_por_tipo": {k: dict(v) for k, v in self.hsm_por_tipo.items()},
            "evidencia": {k: v for k, v in self.evidencia.items()},
            "n_tx": self.n_tx,
            "ts_min": self.ts_min,
            "ts_max": self.ts_max,
        }


def ts_ms(linea):
    """'2026-11-04 00:02:43.283' -> milisegundos absolutos del dia."""
    try:
        h = int(linea[11:13]); m = int(linea[14:16])
        s = int(linea[17:19]); ms = int(linea[20:23])
        return ((h * 60 + m) * 60 + s) * 1000 + ms
    except (ValueError, IndexError):
        return None


class Bloque:
    """Una transaccion: desde 'Mensaje ISO Entrada' hasta el siguiente."""

    __slots__ = ("seq", "label", "tipotran", "messtype", "prod", "monto", "cashback",
                 "pem", "mcc", "bin6", "last4", "validaciones", "funciones", "sps",
                 "codret_host", "iso_rc", "outcome", "flags", "tokens", "t0", "t1",
                 "codigo_central", "abiertas", "hsm")

    def __init__(self):
        self.seq = None; self.label = None; self.tipotran = None
        self.messtype = None; self.prod = None; self.monto = None; self.cashback = None
        self.pem = None; self.mcc = None; self.bin6 = None; self.last4 = None
        self.validaciones = []; self.funciones = []; self.sps = []
        self.codret_host = None; self.iso_rc = None; self.outcome = None
        self.flags = set(); self.tokens = []
        self.t0 = None; self.t1 = None; self.codigo_central = None
        self.abiertas = {}; self.hsm = {}


def cerrar_bloque(b, acc):
    if b is None or b.seq is None and not b.funciones:
        return
    acc.n_tx += 1
    label = b.label or "SIN_ETIQUETA"
    rechazada = b.outcome in ("rechazada", "autorizacion_rechazada")

    acc.tx[(label, b.tipotran or "?", b.messtype or "?", b.prod or "?")] += 1
    acc.tx_resultado[(label, b.outcome or "desconocido", b.iso_rc or "?")] += 1
    acc.tx_banda[label][banda_monto(b.monto)] += 1

    for i, v in enumerate(b.validaciones):
        acc.validaciones[v] += 1
        acc.validacion_orden[v] += i
        acc.validacion_por_tipo[v][label] += 1
        if rechazada:
            acc.validacion_en_rechazo[v] += 1

    for nombre, ms in b.funciones:
        acc.funciones[nombre] += 1
        acc.funcion_por_tipo[nombre][label] += 1
        if ms is not None:
            acc.funcion_ms[nombre] += ms
            if ms > acc.funcion_max_ms.get(nombre, -1):
                acc.funcion_max_ms[nombre] = ms

    for sp in b.sps:
        acc.sps[sp] += 1
        acc.sp_por_tipo[sp][label] += 1

    if b.pem:
        acc.pem[b.pem] += 1
    if b.mcc:
        acc.mcc[b.mcc] += 1
        acc.mcc_por_tipo[b.mcc][label] += 1
    if b.bin6:
        acc.bins[b.bin6] += 1
    if b.codret_host:
        acc.codret_host[b.codret_host] += 1
    if b.iso_rc:
        acc.iso_rc[b.iso_rc] += 1
    if b.codret_host and b.iso_rc:
        acc.mapeo_codigos[(b.codret_host, b.iso_rc)] += 1
    for t, estado in b.tokens:
        acc.tokens[(t, estado)] += 1
    for f in b.flags:
        acc.flags[f] += 1
        acc.flags_por_tipo[f][label] += 1

    for campo, valor in b.hsm.items():
        acc.hsm[(campo, valor)] += 1
        if valor != "FF":                      # FF = la validacion no aplica
            acc.hsm_por_tipo[campo][label] += 1

    # Evidencia enmascarada por codigo de respuesta
    if b.iso_rc and len(acc.evidencia[b.iso_rc]) < EVIDENCE_PER_CODE:
        elapsed = (b.t1 - b.t0) if (b.t0 is not None and b.t1 is not None) else None
        acc.evidencia[b.iso_rc].append({
            "tipo_transaccion": label,
            "tipotran": b.tipotran,
            "pan_enmascarado": mask_pan((b.bin6 or "") + "0" * 6 + (b.last4 or "")) if b.bin6 and b.last4 else None,
            "bin": b.bin6,
            "pem": b.pem,
            "mcc": b.mcc,
            "banda_monto": banda_monto(b.monto),
            "codret_host": b.codret_host,
            "codigo_central": b.codigo_central,
            "iso_rc": b.iso_rc,
            "outcome": b.outcome,
            "validaciones": b.validaciones,
            "flags": sorted(b.flags),
            "sps": b.sps,
            "elapsed_ms": elapsed,
        })


def abrir_log(path):
    """
    Abre el log en modo texto. Los lotes de dia completo llegan comprimidos
    (`.log.gz`, ~12 veces su tamaño en disco); se leen en streaming para no
    descomprimir decenas de gigabytes.
    """
    if path.endswith(".gz"):
        return gzip.open(path, "rt", errors="replace")
    return open(path, "r", errors="replace")


def parse_file(path):
    """Procesa un archivo de log completo. Devuelve (metadatos, agregados)."""
    acc = Acumulador()
    b = None
    n_lineas = 0
    h = hashlib.sha256()

    with abrir_log(path) as fh:
        for linea in fh:
            n_lineas += 1
            h.update(linea[:120].encode("utf-8", "replace"))
            if len(linea) < 30:
                continue

            t = ts_ms(linea)
            if t is not None:
                if acc.ts_min is None or t < acc.ts_min:
                    acc.ts_min = t
                if acc.ts_max is None or t > acc.ts_max:
                    acc.ts_max = t

            # ── Inicio de transaccion ──
            if "Mensaje ISO Entrada" in linea:
                cerrar_bloque(b, acc)
                b = Bloque()
                b.t0 = t
                continue

            if b is None:
                continue
            b.t1 = t

            # ── Fin de transaccion: resultado ──
            if "Mensaje Completo ISO Salida" in linea:
                if "Autorizada" in linea:
                    b.outcome = "autorizada"
                elif "Autorizacion Rechazada" in linea:
                    b.outcome = "autorizacion_rechazada"
                elif "Rechazada" in linea:
                    b.outcome = "rechazada"
                continue

            if "RETURN CODE:" in linea:
                m = RE_RC_ISO.search(linea)
                if m:
                    b.iso_rc = m.group(1)
                continue

            # ── Resultados del HSM, calculados aguas arriba por InterAct ──
            if "Rc[" in linea:
                m = RE_HSM.search(linea)
                if m and m.group(1) not in b.hsm:
                    b.hsm[m.group(1)] = m.group(2) or "(vacio)"
                    continue

            # ── Funciones: entrada/salida y latencia ──
            if "Entrando" in linea:
                m = RE_ENTRA.search(linea)
                if m:
                    nombre = m.group(1)
                    b.abiertas[nombre] = t
                    if nombre == "GetTypeOfTransaction":
                        g = RE_GETTYPE.search(linea)
                        if g:
                            b.prod, b.messtype, b.tipotran = g.group(1), g.group(2), g.group(3)
                            try:
                                b.monto = float(g.group(4))
                                b.cashback = float(g.group(5))
                            except ValueError:
                                pass
                    elif nombre == "dbGetTipoTarjeta":
                        mb = RE_BIN.search(linea)
                        if mb:
                            b.bin6 = mb.group(1)
                    elif nombre == "dbValidateGiroDeNegocio":
                        mm = RE_MCC.search(linea)
                        if mm:
                            b.mcc = mm.group(1)
                    elif nombre == "dbGetandValidateHostResponse":
                        mc = RE_CODIGO_CENTRAL.search(linea)
                        if mc:
                            b.codigo_central = mc.group(1)
                    if b.seq is None:
                        ms_ = RE_SEQ.search(linea)
                        if ms_:
                            b.seq = ms_.group(1)
                    # PAN -> solo ultimos 4
                    if b.last4 is None and ("Tarjeta" in linea or "tarjeta" in linea):
                        mp = RE_PAN.search(linea)
                        if mp:
                            b.last4 = mp.group(1)[-4:]
                            if b.bin6 is None:
                                b.bin6 = mp.group(1)[:6]
                continue

            if "Saliendo" in linea:
                m = RE_SALE.search(linea)
                if m:
                    nombre = m.group(1)
                    t_ini = b.abiertas.pop(nombre, None)
                    ms = (t - t_ini) if (t is not None and t_ini is not None and t >= t_ini) else None
                    b.funciones.append((nombre, ms))
                continue

            # ── Conocimiento de negocio ──
            if "Validaciones Efectuadas" in linea:
                m = RE_VALIDACIONES.search(linea)
                if m:
                    vistos = set()
                    for v in m.group(1).split(","):
                        v = v.strip()
                        if v.isdigit() and v not in vistos:
                            vistos.add(v)
                            b.validaciones.append(v)
                continue

            if "POS ENTRY MODE" in linea:
                m = RE_PEM.search(linea)
                if m:
                    b.pem = m.group(1)
                    acc.pem_desc[m.group(1)] = m.group(2).strip()
                continue

            if "EXECUTE PROCEDURE" in linea:
                m = RE_SP.search(linea)
                if m:
                    sp = m.group(1).lower()
                    if sp not in b.sps:
                        b.sps.append(sp)
                continue

            if "CodRet:" in linea:
                m = RE_CODRET.search(linea)
                if m and b.codret_host is None:
                    b.codret_host = m.group(1).strip()
                continue

            if "Token" in linea:
                m = RE_TOKEN_OK.search(linea)
                if m:
                    b.tokens.append((m.group(1), "presente"))
                    continue
                m = RE_TOKEN_NO.search(linea)
                if m:
                    b.tokens.append((m.group(1), "ausente"))
                    continue
                m = RE_TOKEN_PASEO.search(linea)
                if m:
                    b.tokens.append((m.group(1), "paseado"))
                continue

            # Etiqueta de tipo de transaccion / banderas de contexto
            cuerpo = linea[30:].strip()
            if cuerpo in TX_LABELS:
                b.label = cuerpo
                continue
            flag = CONTEXT_FLAGS.get(cuerpo)
            if flag:
                b.flags.add(flag)

    cerrar_bloque(b, acc)

    meta = {
        "archivo": os.path.basename(path),
        "bytes": os.path.getsize(path),
        "lineas": n_lineas,
        "transacciones": acc.n_tx,
        "sha256_prefijo": h.hexdigest()[:16],
        "ts_min_ms": acc.ts_min,
        "ts_max_ms": acc.ts_max,
    }
    return meta, acc.to_dict()


# ─────────────────────────────────────────────────────────────────
# Fusion de agregados
# ─────────────────────────────────────────────────────────────────

def fusionar(total, parcial):
    for clave, valor in parcial.items():
        if clave in ("n_tx",):
            total[clave] = total.get(clave, 0) + valor
        elif clave in ("ts_min",):
            if valor is not None:
                total[clave] = valor if total.get(clave) is None else min(total[clave], valor)
        elif clave in ("ts_max",):
            if valor is not None:
                total[clave] = valor if total.get(clave) is None else max(total[clave], valor)
        elif clave == "funcion_max_ms":
            d = total.setdefault(clave, {})
            for k, v in valor.items():
                if v > d.get(k, -1):
                    d[k] = v
        elif clave == "pem_desc":
            total.setdefault(clave, {}).update(valor)
        elif clave == "evidencia":
            d = total.setdefault(clave, {})
            for k, v in valor.items():
                lista = d.setdefault(k, [])
                lista.extend(v[: max(0, EVIDENCE_PER_CODE - len(lista))])
        elif isinstance(valor, dict) and valor and isinstance(next(iter(valor.values())), dict):
            d = total.setdefault(clave, {})
            for k, sub in valor.items():
                dd = d.setdefault(k, {})
                for kk, vv in sub.items():
                    dd[kk] = dd.get(kk, 0) + vv
        elif isinstance(valor, dict):
            d = total.setdefault(clave, {})
            for k, v in valor.items():
                d[k] = d.get(k, 0) + v
    return total


def main():
    ap = argparse.ArgumentParser(description="Extrae conocimiento de negocio de los logs del autorizador e-global")
    ap.add_argument("--batch", help="nombre del lote dentro de source/logs/ (por omision: todos)")
    ap.add_argument("--jobs", type=int, default=max(1, (os.cpu_count() or 4) - 1))
    ap.add_argument("--out", help="ruta del JSON de salida")
    args = ap.parse_args()

    lotes = [LOGS_DIR / args.batch] if args.batch else sorted(p for p in LOGS_DIR.iterdir() if p.is_dir())
    if not lotes:
        print(f"[!] sin lotes en {LOGS_DIR}")
        return 1

    OUT_DIR.mkdir(parents=True, exist_ok=True)

    for lote in lotes:
        archivos = sorted(glob.glob(str(lote / "authorizerj-*.log"))
                          + glob.glob(str(lote / "authorizerj-*.log.gz")))
        if not archivos:
            print(f"[!] {lote.name}: sin archivos authorizerj-*.log ni .log.gz")
            continue

        print(f"\n[{lote.name}] {len(archivos)} archivos · {args.jobs} procesos")
        total = {}
        fuentes = []
        with Pool(args.jobs) as pool:
            for meta, parcial in pool.imap_unordered(parse_file, archivos):
                fuentes.append(meta)
                fusionar(total, parcial)
                print(f"  · {meta['archivo']:24s} {meta['lineas']:>9,} lineas  {meta['transacciones']:>6,} txn")

        fuentes.sort(key=lambda m: m["archivo"])
        salida = {
            "lote": lote.name,
            "extractor": "parse-authorizerj.py",
            "extractor_version": EXTRACTOR_VERSION,
            "generado": datetime.now(timezone.utc).isoformat(),
            "fuentes": fuentes,
            "agregados": total,
        }
        destino = Path(args.out) if args.out else OUT_DIR / f"{lote.name}.json"
        destino.write_text(json.dumps(salida, ensure_ascii=False, indent=1), encoding="utf-8")

        n = total.get("n_tx", 0)
        print(f"\n  transacciones: {n:,}")
        print(f"  validaciones distintas: {len(total.get('validaciones', {}))}")
        print(f"  funciones distintas:    {len(total.get('funciones', {}))}")
        print(f"  SPs Informix:           {len(total.get('sps', {}))}")
        print(f"  codigos ISO:            {len(total.get('iso_rc', {}))}")
        print(f"  mapeos CodRet->ISO:     {len(total.get('mapeo_codigos', {}))}")
        print(f"  -> {destino}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
