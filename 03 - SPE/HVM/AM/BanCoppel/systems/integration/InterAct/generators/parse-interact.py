#!/usr/bin/env python3
"""
parse-interact.py — Extractor de conocimiento de negocio de InterAct
BanCoppel Application Modernization · SPE-AM-001

InterAct es el front-end ISO 8583 de la plataforma de tarjetas: recibe el
trafico de la red, lo valida criptograficamente, lo entrega al autorizador
e-global y arma el mensaje de respuesta.

Que extrae:
  1. Politicas de validacion de seguridad, que el modulo intersec escribe en prosa
  2. Inventario de procesos de la suite y su papel en el flujo
  3. Flujo de mensajes: tipos ISO de entrada y salida, sistemas origen
  4. Catalogo de tokens propietarios del campo DE63
  5. Indicadores de CVV, 3D Secure y EMV observados
  6. Errores de proceso recurrentes

PCI-DSS: el log crudo contiene mensajes ISO completos con PAN y datos de banda,
ademas de volcados hexadecimales. Este extractor NO persiste ningun mensaje
crudo ni valor de token: guarda estructura, catalogos y conteos.

Uso:
  python parse-interact.py [--batch interact.20261104] [--jobs N]
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

# Papel de cada proceso de la suite dentro del flujo
ROLES = {
    "interapp": ("Aplicacion de transaccion",
                 "Recibe la respuesta del autorizador y arma el mensaje ISO de salida"),
    "intertcps": ("Listener TCP servidor",
                  "Recibe el trafico entrante de la red en crudo"),
    "intertcpn": ("Listener TCP de red",
                  "Atiende el enlace con la red de marca"),
    "intersec": ("Seguridad y HSM",
                 "Aplica la politica de validacion criptografica de PIN, CVV y CVV2"),
    "interserv": ("Enlace de servicio",
                  "Puente entre el enlace nativo y el resto de la suite"),
}

# ── Patrones ─────────────────────────────────────────────────────
RE_PROCESO = re.compile(r"^(inter[a-z]+?)(\d*)(?:-\d+)?\.", re.I)
RE_TS = re.compile(r"^\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3})\]")
RE_MTI_OUT = re.compile(r"Output ISO-8583 Message: \[ISO\d{9}(\d{4})")
RE_MSG_TYPE = re.compile(r"Message Type: \[(\d{4})\]")
RE_SYSTEM_ID = re.compile(r"System Id: \[(\d+)\]")
RE_RETURN_CODE = re.compile(r"Return Code\.*: \[(-?\d+)\]")
RE_FUNCTION_CODE = re.compile(r"Function Code: \[(\d+)\]")
RE_LEN_IN = re.compile(r"ISO-8583 Input Message Length: \[(\d+)\]")
RE_LEN_OUT = re.compile(r"ISO-8583 Output Message Length: \[(\d+)\]")
RE_TOKEN_DECL = re.compile(r"! ([A-Z0-9]{2})(\d{5}) ")
RE_TOKEN_ERR = re.compile(r"Error looking for Token ([A-Z0-9]{2}): \[(-?\d+)\]")
RE_TOKEN_SET = re.compile(r"^\[setToken([A-Z0-9]{2})\]")
RE_PEM = re.compile(r"POS Entry Mode: \[(\d+)\]")
RE_PRODUCT = re.compile(r"Product Indicator: \[(\w+)\]")
RE_PROCCODE = re.compile(r"Processing Code: \[(\w+)\]")
RE_MARCA = re.compile(r"Marca: \[(\w+)\]")
RE_CVV_IND = re.compile(r"Card Verification Value Indicator = (.*?)\s*$")
RE_3DS = re.compile(r"3D Secure - eCommerce Value Indicator: \[(\w*)\]")
RE_CVN = re.compile(r"CVN (\d+)\.")
RE_GET_ICARD = re.compile(r"get_from_icard")

# Frases de politica: lineas en prosa que declaran que se valida y cuando
RE_POLITICA = re.compile(
    r"(?:Financial Transaction|Reversal|Advice|Fallback|without make).*", re.I)
PISTAS_POLITICA = ("Validation", "validations", "invalid transaction")


def clasificar_proceso(nombre):
    m = RE_PROCESO.match(nombre)
    if not m:
        return "desconocido", ""
    return m.group(1).lower(), m.group(2)


class Acc:
    def __init__(self):
        self.politicas = collections.Counter()
        self.mti_out = collections.Counter()
        self.msg_type = collections.Counter()
        self.system_id = collections.Counter()
        self.return_code = collections.Counter()
        self.function_code = collections.Counter()
        self.tokens = collections.Counter()
        self.token_err = collections.Counter()
        self.token_set = collections.Counter()
        self.pem = collections.Counter()
        self.product = collections.Counter()
        self.proccode = collections.Counter()
        self.marca = collections.Counter()
        self.cvv_ind = collections.Counter()
        self.tds = collections.Counter()
        self.cvn = collections.Counter()
        self.mensajes = 0
        self.len_in = [0, 0]      # suma, n
        self.len_out = [0, 0]
        self.ts_min = None
        self.ts_max = None

    def dict(self):
        return {
            "politicas": dict(self.politicas),
            "mti_out": dict(self.mti_out),
            "msg_type": dict(self.msg_type),
            "system_id": dict(self.system_id),
            "return_code": dict(self.return_code),
            "function_code": dict(self.function_code),
            "tokens": dict(self.tokens),
            "token_err": {f"{k[0]}|{k[1]}": v for k, v in self.token_err.items()},
            "token_set": dict(self.token_set),
            "pem": dict(self.pem),
            "product": dict(self.product),
            "proccode": dict(self.proccode),
            "marca": dict(self.marca),
            "cvv_ind": dict(self.cvv_ind),
            "tds": dict(self.tds),
            "cvn": dict(self.cvn),
            "mensajes": self.mensajes,
            "len_in": self.len_in,
            "len_out": self.len_out,
            "ts_min": self.ts_min,
            "ts_max": self.ts_max,
        }


def abrir(path):
    if path.endswith(".gz"):
        return gzip.open(path, "rt", errors="replace")
    return open(path, "r", errors="replace")


def parse_file(path):
    acc = Acc()
    nombre = os.path.basename(path)
    familia, instancia = clasificar_proceso(nombre)
    n_lineas = 0
    h = hashlib.sha256()

    with abrir(path) as fh:
        for linea in fh:
            n_lineas += 1
            h.update(linea[:120].encode("utf-8", "replace"))

            m = RE_TS.match(linea)
            if m:
                t = m.group(1)[11:]
                if acc.ts_min is None or t < acc.ts_min:
                    acc.ts_min = t
                if acc.ts_max is None or t > acc.ts_max:
                    acc.ts_max = t

            if "get_from_icard" in linea or "get_from_srv" in linea:
                acc.mensajes += 1
                continue

            # ── Politicas de validacion en prosa ──
            if any(p in linea for p in PISTAS_POLITICA):
                m = RE_POLITICA.search(linea)
                if m:
                    texto = m.group(0).strip().rstrip("!").strip()
                    if 20 < len(texto) < 220:
                        acc.politicas[texto] += 1

            # ── Estructura del mensaje ──
            if "ISO-8583" in linea:
                m = RE_MTI_OUT.search(linea)
                if m:
                    acc.mti_out[m.group(1)] += 1
                m = RE_LEN_IN.search(linea)
                if m:
                    acc.len_in[0] += int(m.group(1)); acc.len_in[1] += 1
                m = RE_LEN_OUT.search(linea)
                if m:
                    acc.len_out[0] += int(m.group(1)); acc.len_out[1] += 1
                continue

            if "Message Type" in linea:
                m = RE_MSG_TYPE.search(linea)
                if m:
                    acc.msg_type[m.group(1)] += 1
                continue
            if "System Id" in linea:
                m = RE_SYSTEM_ID.search(linea)
                if m:
                    acc.system_id[m.group(1)] += 1
                continue
            if "Return Code" in linea:
                m = RE_RETURN_CODE.search(linea)
                if m:
                    acc.return_code[m.group(1)] += 1
                continue
            if "Function Code" in linea:
                m = RE_FUNCTION_CODE.search(linea)
                if m:
                    acc.function_code[m.group(1)] += 1
                continue

            # ── Tokens propietarios del DE63 ──
            if "Token" in linea:
                m = RE_TOKEN_ERR.search(linea)
                if m:
                    acc.token_err[(m.group(1), m.group(2))] += 1
                m = RE_TOKEN_SET.match(linea)
                if m:
                    acc.token_set[m.group(1)] += 1
                # declaracion de tokens dentro del campo 63: "! Q100002 9 !"
                for tok, largo in RE_TOKEN_DECL.findall(linea):
                    acc.tokens[tok] += 1

            # ── Indicadores de riesgo y medio de entrada ──
            if "POS Entry Mode" in linea:
                m = RE_PEM.search(linea)
                if m:
                    acc.pem[m.group(1)] += 1
                continue
            if "Product Indicator" in linea:
                m = RE_PRODUCT.search(linea)
                if m:
                    acc.product[m.group(1)] += 1
                continue
            if "Processing Code" in linea:
                m = RE_PROCCODE.search(linea)
                if m:
                    acc.proccode[m.group(1)] += 1
                continue
            if "Marca:" in linea:
                m = RE_MARCA.search(linea)
                if m:
                    acc.marca[m.group(1)] += 1
                continue
            if "Card Verification Value Indicator =" in linea:
                m = RE_CVV_IND.search(linea)
                if m:
                    acc.cvv_ind[m.group(1).strip() or "(vacio)"] += 1
                continue
            if "3D Secure" in linea:
                m = RE_3DS.search(linea)
                if m:
                    acc.tds[m.group(1).strip() or "(vacio)"] += 1
                continue
            if "CVN " in linea:
                m = RE_CVN.search(linea)
                if m:
                    acc.cvn[m.group(1)] += 1
            if "A FULL EMV Transaction" in linea:
                acc.cvn["full_emv"] += 1

    meta = {
        "archivo": nombre,
        "proceso": familia,
        "instancia": instancia,
        "bytes": os.path.getsize(path),
        "lineas": n_lineas,
        "mensajes": acc.mensajes,
        "sha256_prefijo": h.hexdigest()[:16],
        "ts_min": acc.ts_min,
        "ts_max": acc.ts_max,
    }
    return meta, acc.dict()


def fusionar(total, parcial):
    for clave, valor in parcial.items():
        if clave == "mensajes":
            total[clave] = total.get(clave, 0) + valor
        elif clave in ("len_in", "len_out"):
            a = total.setdefault(clave, [0, 0])
            a[0] += valor[0]; a[1] += valor[1]
        elif clave == "ts_min":
            if valor and (total.get(clave) is None or valor < total[clave]):
                total[clave] = valor
        elif clave == "ts_max":
            if valor and (total.get(clave) is None or valor > total[clave]):
                total[clave] = valor
        elif isinstance(valor, dict):
            d = total.setdefault(clave, {})
            for k, v in valor.items():
                d[k] = d.get(k, 0) + v
    return total


def main():
    ap = argparse.ArgumentParser(description="Extrae conocimiento de los logs de InterAct")
    ap.add_argument("--batch")
    ap.add_argument("--jobs", type=int, default=max(1, (os.cpu_count() or 4) - 1))
    args = ap.parse_args()

    lotes = [LOGS_DIR / args.batch] if args.batch else sorted(
        p for p in LOGS_DIR.iterdir() if p.is_dir())
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    for lote in lotes:
        archivos = sorted(glob.glob(str(lote / "inter*.err"))
                          + glob.glob(str(lote / "inter*.err.gz")))
        if not archivos:
            print(f"[!] {lote.name}: sin archivos inter*.err")
            continue

        print(f"\n[{lote.name}] {len(archivos)} archivos · {args.jobs} procesos")
        total, fuentes = {}, []
        por_proceso = collections.Counter()
        with Pool(args.jobs) as pool:
            for meta, parcial in pool.imap_unordered(parse_file, archivos):
                fuentes.append(meta)
                por_proceso[meta["proceso"]] += meta["mensajes"]
                fusionar(total, parcial)

        fuentes.sort(key=lambda m: (m["proceso"], m["archivo"]))
        procesos = {}
        for m in fuentes:
            p = procesos.setdefault(m["proceso"], {
                "rol": ROLES.get(m["proceso"], ("Sin clasificar", ""))[0],
                "descripcion": ROLES.get(m["proceso"], ("", ""))[1],
                "archivos": 0, "instancias": set(), "lineas": 0, "mensajes": 0, "bytes": 0})
            p["archivos"] += 1
            if m["instancia"]:
                p["instancias"].add(m["instancia"])
            p["lineas"] += m["lineas"]
            p["mensajes"] += m["mensajes"]
            p["bytes"] += m["bytes"]
        for p in procesos.values():
            p["instancias"] = sorted(p["instancias"], key=lambda x: int(x) if x else 0)

        salida = {
            "lote": lote.name,
            "extractor": "parse-interact.py",
            "extractor_version": EXTRACTOR_VERSION,
            "generado": datetime.now(timezone.utc).isoformat(),
            "fuentes": fuentes,
            "procesos": procesos,
            "agregados": total,
        }
        destino = OUT_DIR / f"{lote.name}.json"
        destino.write_text(json.dumps(salida, ensure_ascii=False, indent=1), encoding="utf-8")

        print(f"  mensajes procesados: {total.get('mensajes', 0):,}")
        print(f"  politicas de validacion: {len(total.get('politicas', {}))}")
        print(f"  tipos de mensaje ISO de salida: {len(total.get('mti_out', {}))}")
        print(f"  tokens DE63 distintos: {len(total.get('tokens', {}))}")
        print(f"  procesos de la suite: {len(procesos)}")
        for nombre, p in sorted(procesos.items(), key=lambda x: -x[1]['mensajes']):
            print(f"    {nombre:12s} {p['archivos']:>3} archivos  {p['mensajes']:>8,} mensajes  {p['rol']}")
        print(f"  -> {destino}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
