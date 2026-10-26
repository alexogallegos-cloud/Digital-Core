#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-test-data.py — Set de datos sintéticos para cada caso de prueba del catálogo.

Lee portal/data/test-cases.json (salida de build-test-catalog.py) y, para cada caso,
genera los valores de entrada que ese caso necesita: parsea las variables del fragmento
de código SPL, las tipa por nombre y por prefijo húngaro, y produce un valor sintético
coherente con la intención del caso (satisface, incumple, cae en el límite).

Principios:
  · Cero datos de producción. Todo se construye, nada se copia ni se enmascara.
  · Determinista: la semilla sale del identificador del caso, así que el set se
    regenera idéntico y es citable en un defecto.
  · Estructuralmente válido: CLABE, tarjeta, RFC y CURP llevan dígito verificador o
    formato correcto para que las validaciones del componente nuevo no rechacen el dato
    por forma antes de ejercitar la regla.
  · Imposible de confundir con un dato real: banco 999 (no asignado por Banxico),
    BIN 400000 de pruebas, nombres de un pool ficticio.

Salidas por marca:
  portal/data/test-data.json        · set por caso + universo de entidades
  portal/data/test-data.csv         · formato largo (caso, campo, tipo, valor) para fixtures
  portal/test-data-bcop.html        · la vista que explica la estrategia
  (equivalentes en sanitized/ con el cliente anonimizado)

Uso:
  python generators/build-test-data.py

SPE-AM-001 · Specialist Informix SPL · QE shift-left
"""

import sys, re, csv, json, html, random, hashlib, argparse
from pathlib import Path
from collections import Counter
from datetime import date, timedelta

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE = Path(__file__).resolve().parent.parent
CASOS = BASE / "portal" / "data" / "test-cases.json"

BRANDS = {
    "bcop": {
        "html":  BASE / "portal" / "test-data-bcop.html",
        "data":  BASE / "portal" / "data" / "test-data.json",
        "csv":   BASE / "portal" / "data" / "test-data.csv",
        "back":  "index-bcop-v2.html", "vista": "test-acceleration-bcop.html",
        "catalogo": "test-catalog-bcop.html",
        "logo":  "bancoppel-logo.png", "alt": "BanCoppel",
        "crumb": "BCOPCORE", "sys": "Informix",
        "accent": "#F0D224", "accent2": "#f6e27a", "blue": "#3D5FCD", "blued": "#122FB1",
        "bg": "#060a1a", "glow": "240,210,36", "scrub": False,
    },
    "legacy": {
        "html":  BASE / "sanitized" / "test-data-legacy.html",
        "data":  BASE / "sanitized" / "data" / "test-data.json",
        "csv":   BASE / "sanitized" / "data" / "test-data.csv",
        "back":  "index-legacy.html", "vista": "test-acceleration-legacy.html",
        "catalogo": "test-catalog-legacy.html",
        "logo":  "accenture-logo.png", "alt": "Accenture",
        "crumb": "LEGACYCORE", "sys": "LegacyCore",
        "accent": "#A100FF", "accent2": "#c77dff", "blue": "#7C4DCF", "blued": "#6B21A8",
        "bg": "#14142b", "glow": "161,0,255", "scrub": True,
    },
}

SCRUB = [
    (re.compile(r"BanCoppel", re.I), "LegacyCore"),
    (re.compile(r"\bAPPCOPPEL\b", re.I), "APP_GRUPO"),
    (re.compile(r"\bCoppel\b", re.I), "el grupo"),
    (re.compile(r"COPPEL", re.I), "GRUPO"),
    (re.compile(r"bcpl", re.I), "lgc"),
    (re.compile(r"_CPL\b", re.I), "_GRP"),
    (re.compile(r"bcop", re.I), "lgc"),
    (re.compile(r"Informix", re.I), "LegacyCore"),
]


def scrub(txt, on):
    if not on or not txt:
        return txt
    for rx, rep in SCRUB:
        txt = rx.sub(rep, str(txt))
    return txt


# ═════════════════════════════════════════════════════════════════════════════
# Universo de entidades sintéticas
# ═════════════════════════════════════════════════════════════════════════════
NOMBRES = ["Ana", "Luis", "María", "Jorge", "Carmen", "Raúl", "Elena", "Mario", "Sofía",
           "Héctor", "Lucía", "Iván", "Paola", "Néstor", "Rosa", "Ulises", "Diana", "Omar"]
APELLIDOS = ["Vargas", "Mendoza", "Olvera", "Quintero", "Zamora", "Iturbe", "Narváez",
             "Peralta", "Escobar", "Trujillo", "Barrera", "Fuentes", "Galindo", "Robles"]
PLAZAS = ["180", "320", "440", "610", "750"]       # claves de plaza ficticias
BANCO_SINTETICO = "999"                             # código no asignado por Banxico
BIN_PRUEBA = "400000"                               # BIN de pruebas, no emisor real


def luhn_dv(num):
    s, alt = 0, True
    for d in reversed(num):
        d = int(d)
        if alt:
            d *= 2
            if d > 9:
                d -= 9
        s += d
        alt = not alt
    return str((10 - s % 10) % 10)


def clabe_dv(d18):
    pesos = [3, 7, 1] * 6
    s = sum((int(a) * p) % 10 for a, p in zip(d18, pesos))
    return str((10 - s % 10) % 10)


def rfc_de(nom, ape, fnac):
    base = (ape[:2] + nom[0] + "X").upper()
    base = re.sub(r"[^A-Z]", "X", base)[:4]
    return f"{base}{fnac:%y%m%d}" + "XX0"


def curp_de(nom, ape, fnac, sexo):
    base = re.sub(r"[^A-Z]", "X", (ape[:2] + nom[0] + "X").upper())[:4]
    return f"{base}{fnac:%y%m%d}{sexo}DFXXX0{fnac.day % 10}"


def universo(n_personas=120):
    """Pool fijo de clientes, cuentas y tarjetas sintéticas, reutilizable entre casos."""
    rnd = random.Random("universo-sintetico-spe-am-001")
    personas = []
    for i in range(n_personas):
        nom, ape = rnd.choice(NOMBRES), rnd.choice(APELLIDOS)
        ape2 = rnd.choice(APELLIDOS)
        fnac = date(1960, 1, 1) + timedelta(days=rnd.randint(0, 365 * 45))
        sexo = rnd.choice("HM")
        plaza = rnd.choice(PLAZAS)
        cuenta11 = f"{rnd.randint(0, 10**11 - 1):011d}"
        d17 = BANCO_SINTETICO + plaza + cuenta11       # 3 banco + 3 plaza + 11 cuenta
        pan15 = BIN_PRUEBA + f"{rnd.randint(0, 10**9 - 1):09d}"
        personas.append({
            "id": f"CTE-{i + 1:04d}",
            "nombre": f"{nom} {ape} {ape2}",
            "rfc": rfc_de(nom, ape, fnac),
            "curp": curp_de(nom, ape, fnac, sexo),
            "nacimiento": fnac.isoformat(),
            "sucursal": plaza,
            "cuenta": cuenta11,
            "clabe": d17 + clabe_dv(d17),
            "tarjeta": pan15 + luhn_dv(pan15),
            "saldo": round(rnd.uniform(150, 85000), 2),
        })
    return personas


# ═════════════════════════════════════════════════════════════════════════════
# Tipado de variables del código SPL
# ═════════════════════════════════════════════════════════════════════════════
RESERVADAS = {
    "if", "then", "else", "elif", "end", "let", "return", "returning", "select", "from",
    "where", "and", "or", "not", "null", "nvl", "cast", "as", "date", "datetime", "current",
    "today", "to_char", "to_date", "round", "trunc", "floor", "ceil", "count", "sum", "max",
    "min", "avg", "integer", "int", "smallint", "money", "char", "varchar", "decimal", "dec",
    "float", "year", "month", "day", "extend", "mdy", "units", "begin", "foreach", "for",
    "while", "exit", "continue", "define", "execute", "procedure", "function", "values",
    "into", "set", "update", "insert", "delete", "group", "order", "by", "having", "exists",
    "between", "like", "in", "is", "distinct", "case", "when", "trim", "upper", "lower",
    "substr", "length", "replace", "raise", "exception", "on", "off", "yes", "no", "true",
    "false", "temp", "table", "tbl", "sp", "informix",
}

SEMANTICA = [
    (r"clabe", "clabe"),
    (r"(tarjeta|tarj|plastico|plástico|\bpan\b|numtar)", "tarjeta"),
    (r"\brfc\b", "rfc"),
    (r"\bcurp\b", "curp"),
    (r"(cuenta|\bcta\b|ctacheq|numcta)", "cuenta"),
    (r"(sucursal|\bsuc\b|plaza|cecos)", "sucursal"),
    (r"(fecha|\bfch\b|fec_|_fec|nacimiento|vencim|corte|vigencia)", "fecha"),
    (r"(tasa|porcent|pct|ciento|factor)", "tasa"),
    # Antes que «monto»: num_pagos cuenta pagos y no es un importe. Y un nombre que
    # arranca con numero/cantidad es un conteo, sin importar lo que lo siga.
    (r"^(numero|número|num|cant|cantidad|conteo|contador|total_reg)[ _]", "entero"),
    (r"(num|numero|número|cant|cantidad|cont|contador|total)_?"
     r"(pagos|cuotas|abonos|cargos|operaciones|movimientos|registros|meses|dias|días|"
     r"intentos|veces|clientes|cuentas|aclaraciones)", "entero"),
    (r"(monto|importe|saldo|abono|cargo|pago|comision|comisión|interes|interés|capital|"
     r"total|deposito|depósito|retiro|efectivo|limite|límite|linea|línea|disponible|"
     r"adeudo|deuda|exigible|principal|prima|penaliza)", "monto"),
    # Después de «monto»: total_iva es el impuesto calculado; valIva suelto es la tasa.
    (r"\biva\b", "tasa"),
    (r"(dias|días|plazo|meses|periodo|periodicidad|edad|antiguedad|antigüedad)", "dias"),
    (r"(intentos|contador|\bcont\b|numero|número|\bnum\b|cantidad|cuantos|total_reg)", "entero"),
    (r"(cliente|\bcte\b|persona|titular|socio)", "cliente"),
    (r"(codret|codigo|código|\bcod\b|estatus|status|estado|clave|motivo|resultado)", "codigo"),
    (r"(producto|prod|subproducto)", "producto"),
    (r"(nombre|apellido|razon|razón)", "nombre"),
    (r"(folio|referencia|\bref\b|autorizacion|autorización|rastreo)", "folio"),
]

HUNGARO = {"m": "monto", "d": "fecha", "i": "entero", "c": "codigo", "e": "monto",
           "n": "entero", "f": "fecha", "s": "codigo"}


def palabras(var):
    """vValIva → 'v val iva'; mMontoChequeUsd → 'm monto cheque usd'.

    Los nombres del dialecto concatenan palabras sin separador, así que buscar con
    límite de palabra sobre el identificador crudo nunca encuentra 'iva'. Y buscarlo
    como subcadena daría falsos positivos obvios ('derivado'). Separar primero resuelve
    las dos cosas.
    """
    s = re.sub(r"([a-z0-9])([A-Z])", r"\1 \2", var)
    s = re.sub(r"[_.\-]+", " ", s)
    return re.sub(r"\s+", " ", s).strip().lower()


def tipar(var):
    v = palabras(var)
    crudo = var.lower().lstrip("_")
    for rx, t in SEMANTICA:
        if re.search(rx, v) or re.search(rx, crudo):
            return t
    m = re.match(r"^(v|p)?([a-z]{1,2})[A-Z_]", var)
    if m and m.group(2) and m.group(2)[0] in HUNGARO:
        return HUNGARO[m.group(2)[0]]
    pre = re.match(r"^([a-z]{1,2})[A-Z]", var)
    if pre and pre.group(1)[0] in HUNGARO:
        return HUNGARO[pre.group(1)[0]]
    return "entero"


def variables(code):
    """Variables de entrada del fragmento: identificadores que no son palabras del lenguaje.

    En una asignación, el lado izquierdo es el resultado y no es entrada.
    """
    if not code:
        return [], None
    salida = None
    m = re.match(r"\s*(?:LET\s+)?([A-Za-z_][\w.]*)\s*=(?!=)", code)
    if m:
        salida = m.group(1)
        cuerpo = code[m.end():]
    else:
        cuerpo = code
    vistos, out = set(), []
    for ident in re.findall(r"[A-Za-z_][\w]{2,}", cuerpo):
        low = ident.lower()
        if low in RESERVADAS or low.startswith("tbl") or ident == salida:
            continue
        if re.fullmatch(r"[A-Z_]{2,}", ident) and low in RESERVADAS:
            continue
        if low not in vistos:
            vistos.add(low)
            out.append(ident)
        if len(out) == 5:
            break
    return out, salida


# ═════════════════════════════════════════════════════════════════════════════
# Generación de valores
# ═════════════════════════════════════════════════════════════════════════════
CMP = re.compile(r"(>=|<=|<>|!=|>|<|=)\s*'?(-?[\d]+(?:[.,]\d+)?)'?")


def valor(tipo, rnd, persona, sesgo=None):
    """sesgo: 'alto' | 'bajo' | 'cero' | 'limite' | None"""
    if tipo == "monto":
        if sesgo == "cero":
            return "0.00"
        if sesgo == "bajo":
            return f"{rnd.uniform(0.01, 50):.2f}"
        if sesgo == "alto":
            return f"{rnd.uniform(50000, 250000):.2f}"
        # medio centavo exacto: el valor que separa banker's rounding de half-up
        if sesgo == "redondeo":
            return f"{rnd.randint(10, 9999)}.{rnd.choice(['005', '015', '025'])}"
        return f"{rnd.uniform(100, 25000):.2f}"
    if tipo == "tasa":
        return rnd.choice(["0.16", "0.1600", "0.085", "0.2250", "0.36"])
    if tipo == "fecha":
        base = date(2026, 4, 24)
        d = base - timedelta(days=rnd.randint(0, 540))
        return d.isoformat()
    if tipo == "dias":
        return str(rnd.choice([0, 1, 7, 15, 30, 45, 90, 180, 360]))
    if tipo == "entero":
        return str(rnd.randint(1, 999))
    if tipo == "cuenta":
        return persona["cuenta"]
    if tipo == "clabe":
        return persona["clabe"]
    if tipo == "tarjeta":
        return persona["tarjeta"]
    if tipo == "rfc":
        return persona["rfc"]
    if tipo == "curp":
        return persona["curp"]
    if tipo == "cliente":
        return persona["id"]
    if tipo == "sucursal":
        return persona["sucursal"]
    if tipo == "nombre":
        return persona["nombre"]
    if tipo == "producto":
        return rnd.choice(["01", "04", "07", "12"])
    if tipo == "folio":
        return f"{rnd.randint(10**9, 10**10 - 1)}"
    if tipo == "codigo":
        return rnd.choice(["000000", "0000", "01", "100"])
    return str(rnd.randint(1, 999))


def fmt_num(v, tipo="monto"):
    """Un monto conserva los centavos aunque el valor sea redondo: 10,000.00, no 10,000."""
    if tipo in ("monto", "tasa"):
        return f"{v:,.2f}"
    return f"{int(v):,}" if float(v).is_integer() else f"{v:,.2f}"


def set_de(caso, persona, rnd):
    """Devuelve (campos, nota) para un caso del catálogo."""
    code = caso.get("cd") or ""
    tec, cid = caso["tc"], caso["i"]
    seq = cid.rsplit("-", 1)[-1]
    vars_, salida = variables(code)
    campos, nota = [], ""

    if tec == "BVA":
        m = CMP.search(code)
        var = vars_[0] if vars_ else "valor_evaluado"
        tipo = tipar(var)
        try:
            lim = float(m.group(2).replace(",", ""))
            op = m.group(1)
        except (AttributeError, ValueError):
            lim, op = 0.0, ">="
        delta = 0.01 if tipo in ("monto", "tasa") else 1
        v = {"01": lim - delta, "02": lim, "03": lim + delta}.get(seq, lim)
        campos.append({"n": var, "t": tipo, "v": fmt_num(v, tipo),
                       "d": f"Límite declarado en el código: {op} {fmt_num(lim, tipo)}"})
        nota = {"01": "Valor inmediatamente por debajo del límite",
                "02": "Valor exactamente en el límite: aquí se decide si el operador es inclusivo",
                "03": "Valor inmediatamente por encima del límite"}.get(seq, "")
        for v2 in vars_[1:3]:
            campos.append({"n": v2, "t": tipar(v2), "v": valor(tipar(v2), rnd, persona),
                           "d": "Variable acompañante del predicado, en valor neutro"})

    elif tec == "GM":
        redondea = bool(re.search(r"ROUND|TRUNC|/", code, re.I))
        sesgado = False
        for v2 in vars_ or ["insumo"]:
            t = tipar(v2)
            borde = redondea and t == "monto"
            sesgado = sesgado or borde
            campos.append({"n": v2, "t": t,
                           "v": valor(t, rnd, persona, "redondeo" if borde else None),
                           "d": "Operando de la fórmula"})
        if salida:
            campos.append({"n": salida, "t": "resultado", "v": "calculado por el legacy",
                           "d": "Valor esperado: lo produce el motor actual durante el parallel-run"})
        nota = ("Los montos caen a medio centavo a propósito: es el insumo que separa el "
                "redondeo bancario del aritmético y donde aparece la divergencia."
                if sesgado else "Insumos neutros para comparar el cálculo contra el legacy.")

    elif tec == "EQ":
        positivo = seq == "01"
        for v2 in vars_ or ["condicion"]:
            t = tipar(v2)
            s = None
            if t == "monto":
                s = "alto" if positivo else "cero"
            campos.append({"n": v2, "t": t, "v": valor(t, rnd, persona, s),
                           "d": "Dato que participa en la condición de la regla"})
        nota = ("Datos que satisfacen la condición: la operación debe continuar."
                if positivo else
                "Datos que incumplen la condición: debe devolver el mismo rechazo que el legacy.")

    elif tec == "ST":
        campos.append({"n": "estado_origen", "t": "codigo",
                       "v": "ACTIVO" if seq == "01" else "CANCELADO",
                       "d": "Estado del registro antes de la transición"})
        campos.append({"n": "estado_destino", "t": "codigo", "v": "BLOQUEADO",
                       "d": "Estado al que se intenta mover el registro"})
        nota = ("Transición permitida: debe completarse y quedar bitácora."
                if seq == "01" else
                "Transición no permitida desde ese estado: debe rechazarse sin cambiar nada.")

    elif tec == "NEG":
        campos.append({"n": "codigo_esperado", "t": "codigo",
                       "v": caso["rl"].split(":")[-1],
                       "d": "Código de retorno que debe devolver el componente nuevo"})
        nota = "El escenario se provoca; lo que se verifica es el código y el mensaje."

    elif tec == "E2E":
        campos += [
            {"n": "cliente", "t": "cliente", "v": persona["id"], "d": "Cliente sintético del pool"},
            {"n": "cuenta", "t": "cuenta", "v": persona["cuenta"], "d": "Cuenta asociada al cliente"},
            {"n": "clabe", "t": "clabe", "v": persona["clabe"],
             "d": "CLABE con dígito verificador válido, banco 999 no asignado"},
            {"n": "monto", "t": "monto", "v": valor("monto", rnd, persona), "d": "Monto de la operación"},
            {"n": "fecha_operacion", "t": "fecha", "v": valor("fecha", rnd, persona),
             "d": "Fecha de proceso dentro del rango de la evidencia"},
        ]
        nota = "El recorrido completo usa el mismo cliente en todos sus pasos, para que el flujo sea coherente."

    if tec not in ("NEG",) and not any(c["t"] == "cliente" for c in campos):
        campos.append({"n": "cliente_contexto", "t": "cliente", "v": persona["id"],
                       "d": "Cliente sintético bajo el que se ejecuta el caso"})
    return campos, nota


# ═════════════════════════════════════════════════════════════════════════════
def construir():
    if not CASOS.exists():
        sys.exit(f"Falta {CASOS}. Corre antes: python generators/build-test-catalog.py")
    cat = json.loads(CASOS.read_text(encoding="utf-8"))
    pool = universo()
    sets = {}
    for c in cat["casos"]:
        h = int(hashlib.md5(c["i"].encode()).hexdigest()[:8], 16)
        rnd = random.Random(h)
        # El cliente se ancla a la REGLA, no al caso: los tres valores límite de un
        # mismo umbral deben ejercitarse sobre el mismo titular para ser comparables.
        hp = int(hashlib.md5(c["rl"].encode()).hexdigest()[:8], 16)
        persona = pool[hp % len(pool)]
        campos, nota = set_de(c, persona, rnd)
        sets[c["i"]] = {"p": persona["id"], "n": nota, "c": campos}
    return cat, pool, sets


def escribir(cat, pool, sets, b):
    on = b["scrub"]
    s_pool = [{k: scrub(v, on) if isinstance(v, str) else v for k, v in p.items()} for p in pool]
    s_sets = {
        scrub(k, on): {
            "p": v["p"], "n": scrub(v["n"], on),
            "c": [{"n": scrub(x["n"], on), "t": x["t"], "v": scrub(x["v"], on),
                   "d": scrub(x["d"], on)} for x in v["c"]],
        } for k, v in sets.items()
    }
    tipos = Counter(x["t"] for v in sets.values() for x in v["c"])
    meta = {
        "sets": len(s_sets),
        "campos": sum(len(v["c"]) for v in s_sets.values()),
        "personas": len(s_pool),
        "por_tipo": dict(tipos.most_common()),
        "banco": BANCO_SINTETICO, "bin": BIN_PRUEBA,
    }
    b["data"].parent.mkdir(parents=True, exist_ok=True)
    b["data"].write_text(json.dumps({"meta": meta, "pool": s_pool, "sets": s_sets},
                                    ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    with open(b["csv"], "w", encoding="utf-8-sig", newline="") as fh:
        w = csv.writer(fh, delimiter=";")
        w.writerow(["caso", "cliente_sintetico", "campo", "tipo", "valor", "descripcion"])
        for cid, v in s_sets.items():
            for x in v["c"]:
                w.writerow([cid, v["p"], x["n"], x["t"], x["v"], x["d"]])
    return meta


def ejemplos(cat, sets, n=3):
    """Un ejemplo por técnica, elegidos entre los casos con más señal."""
    por_tec, out = {}, []
    for c in cat["casos"]:
        if c["tc"] in ("BVA", "GM", "E2E") and c["tc"] not in por_tec:
            if c["tc"] == "GM" and not c.get("k"):
                continue
            if c["tc"] == "BVA" and not c.get("cd"):
                continue
            por_tec[c["tc"]] = c
        if len(por_tec) == n:
            break
    for tec in ("BVA", "GM", "E2E"):
        if tec in por_tec:
            c = por_tec[tec]
            out.append((c, sets[c["i"]]))
    return out


def tabla_ejemplo(c, s, b):
    on = b["scrub"]
    filas = "".join(
        f'<tr><td class="mono">{html.escape(scrub(x["n"], on))}</td>'
        f'<td class="dim">{html.escape(x["t"])}</td>'
        f'<td class="mono hot">{html.escape(scrub(x["v"], on))}</td>'
        f'<td class="dim">{html.escape(scrub(x["d"], on))}</td></tr>' for x in s["c"])
    cd = html.escape(scrub(c.get("cd") or "sin fragmento asociado", on))
    return (f'<div class="ej glass"><div class="ejh"><span class="ejid">'
            f'{html.escape(scrub(c["i"], on))}</span>'
            f'<span class="ejt">{html.escape(scrub(c["t"], on))}</span></div>'
            f'<div class="ejc">{cd}</div>'
            f'<div class="tblwrap"><table><thead><tr><th>Campo</th><th>Tipo</th>'
            f'<th>Valor sintético</th><th>Por qué ese valor</th></tr></thead>'
            f'<tbody>{filas}</tbody></table></div>'
            f'<div class="ejn">{html.escape(scrub(s["n"], on))}</div></div>')


def render(meta, cat, sets, b):
    ej = "".join(tabla_ejemplo(c, s, b) for c, s in ejemplos(cat, sets))
    tipos = "".join(f'<div class="legend-item"><b>{html.escape(k)}</b><span>{v:,}</span></div>'
                    for k, v in list(meta["por_tipo"].items())[:10])
    p = cat["casos"][0]
    T = {
        "__TITLE__": f"{b['sys']} · Datos de Prueba Sintéticos",
        "__LOGO__": b["logo"], "__ALT__": b["alt"], "__CRUMB__": b["crumb"],
        "__BACK__": b["back"], "__VISTA__": b["vista"], "__CATALOGO__": b["catalogo"],
        "__CSV__": b["csv"].name, "__JSON__": b["data"].name,
        "__ACCENT__": b["accent"], "__ACCENT2__": b["accent2"], "__BLUE__": b["blue"],
        "__BLUED__": b["blued"], "__BG__": b["bg"], "__GLOW__": b["glow"],
        "__SETS__": f"{meta['sets']:,}", "__CAMPOS__": f"{meta['campos']:,}",
        "__PERSONAS__": f"{meta['personas']:,}", "__BANCO__": meta["banco"],
        "__BIN__": meta["bin"], "__TIPOS__": tipos, "__EJEMPLOS__": ej,
    }
    out = PAGE
    for k, v in T.items():
        out = out.replace(k, str(v))
    return out


PAGE = r"""<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>__TITLE__</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
:root{--blue:__BLUE__;--blued:__BLUED__;--yellow:__ACCENT__;--yellow2:__ACCENT2__;
 --ink:#F4F6FF;--muted:#aab3d4;--muted2:#818ab0;--glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.10)}
html{scroll-behavior:smooth}
body{background:__BG__;color:var(--ink);font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',sans-serif;-webkit-font-smoothing:antialiased;overflow-x:hidden}
.aurora{position:fixed;inset:0;z-index:-2;overflow:hidden;pointer-events:none}
.aurora::before{content:"";position:absolute;width:62vw;height:62vw;left:-12vw;top:-16vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(27,63,208,.5),transparent 70%);animation:f1 24s ease-in-out infinite}
.aurora::after{content:"";position:absolute;width:48vw;height:48vw;right:-12vw;bottom:-10vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(__GLOW__,.18),transparent 70%);animation:f2 28s ease-in-out infinite}
@keyframes f1{50%{transform:translate(6vw,8vh) scale(1.15)}}
@keyframes f2{50%{transform:translate(-7vw,-8vh) scale(1.12)}}
.grain{position:fixed;inset:0;z-index:-1;opacity:.045;pointer-events:none;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}
.hero-bar{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;align-items:center;gap:18px;padding:14px 32px;
 backdrop-filter:blur(20px) saturate(150%);-webkit-backdrop-filter:blur(20px) saturate(150%);
 background:rgba(6,10,26,.6);border-bottom:1px solid rgba(255,255,255,.06)}
.hero-bar img{height:34px;object-fit:contain;filter:drop-shadow(0 2px 6px rgba(0,0,0,.6))}
.hero-bar .hb-sep{width:1px;height:28px;background:rgba(255,255,255,.15)}
.hero-bar .crumb{font-size:10px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.35)}
.hero-bar .crumb em{color:var(--yellow);font-style:normal}
.hero-bar .hb-sp{flex:1}
.hero-bar a.back{font-size:12px;color:var(--muted);padding:6px 13px;border-radius:20px;border:1px solid rgba(255,255,255,.09);text-decoration:none;transition:.22s;white-space:nowrap}
.hero-bar a.back:hover{color:var(--ink);background:rgba(255,255,255,.07)}
.hero-bar a.cta-bar{color:#10101e;background:var(--yellow);border-color:var(--yellow);font-weight:700}
.glass{background:var(--glass);backdrop-filter:blur(22px) saturate(155%);-webkit-backdrop-filter:blur(22px) saturate(155%);
 border:1px solid var(--glassb);border-radius:22px;box-shadow:0 12px 44px rgba(0,0,0,.36),inset 0 1px 0 rgba(255,255,255,.10)}
.wrap{max-width:1200px;margin:0 auto;padding:0 30px}
section{padding:64px 0;scroll-margin-top:70px}
.hero{padding:92px 0 28px}
.hero-body{display:flex;align-items:flex-end;gap:44px;flex-wrap:wrap;margin-top:28px}
.hero-title{flex:1;min-width:300px}
.hero-label{font-size:10px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:var(--yellow);margin-bottom:12px}
.hero-h1{font-size:clamp(29px,4.8vw,52px);font-weight:900;letter-spacing:-.035em;line-height:1.03;
 background:linear-gradient(176deg,#fff 34%,#9fb4ff);-webkit-background-clip:text;background-clip:text;color:transparent}
.hero-sub{margin-top:16px;font-size:14px;color:var(--muted);line-height:1.68;max-width:62ch}
.hero-sub b{color:#e4eaff;font-weight:600}
.hero-stats{display:flex;gap:10px;flex-wrap:wrap;align-items:flex-end;padding-bottom:4px}
.stat-block{background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08);border-radius:14px;padding:16px 22px;min-width:104px}
.stat-block .sn{font-size:27px;font-weight:900;letter-spacing:-.03em;font-variant-numeric:tabular-nums;line-height:1;
 background:linear-gradient(135deg,var(--yellow),var(--yellow2));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
.stat-block.blue .sn{background:linear-gradient(135deg,#93c5fd,#6f8ce6);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
.stat-block .sl{font-size:9px;font-weight:600;letter-spacing:.08em;text-transform:uppercase;color:var(--muted2);margin-top:5px}
.shead{margin-bottom:30px}
.kick{font-size:12px;font-weight:700;letter-spacing:.2em;text-transform:uppercase;color:var(--yellow);margin-bottom:12px}
.shead h2{font-size:clamp(23px,3.2vw,38px);font-weight:800;letter-spacing:-.025em;line-height:1.08}
.shead p{color:var(--muted);font-size:14px;margin-top:14px;max-width:80ch;line-height:1.7}
.shead p b{color:#e4eaff;font-weight:600}
.cols3{display:grid;grid-template-columns:repeat(3,1fr);gap:16px}
@media(max-width:900px){.cols3{grid-template-columns:1fr}}
.cols2{display:grid;grid-template-columns:1fr 1fr;gap:16px}
@media(max-width:900px){.cols2{grid-template-columns:1fr}}
.card{padding:24px 26px}
.card h4{font-size:12px;color:var(--yellow);text-transform:uppercase;letter-spacing:.09em;margin-bottom:10px;font-weight:700}
.card p{font-size:13.5px;color:var(--muted);line-height:1.68}
.card p b{color:#fff;font-weight:600}
.card code{font-family:'SF Mono',ui-monospace,Menlo,monospace;font-size:12px;color:var(--yellow);
 background:rgba(__GLOW__,.09);border:1px solid rgba(__GLOW__,.22);border-radius:5px;padding:1px 6px}
table{width:100%;border-collapse:collapse;font-size:12.5px}
.tblwrap{overflow-x:auto}
th{text-align:left;font-size:9.5px;font-weight:800;letter-spacing:.1em;text-transform:uppercase;color:var(--muted2);
 padding:11px 12px;border-bottom:1px solid rgba(255,255,255,.12);white-space:nowrap}
td{padding:10px 12px;border-bottom:1px solid rgba(255,255,255,.055);color:var(--muted);vertical-align:top}
tr:last-child td{border-bottom:none}
td.mono,.mono{font-family:'SF Mono',ui-monospace,Menlo,monospace;font-size:11.5px;color:#c9d3f5}
td.hot{color:var(--yellow);font-weight:700}
td.dim,.dim{color:var(--muted2)}
.ej{padding:22px 24px;margin-bottom:16px}
.ejh{display:flex;align-items:baseline;gap:14px;flex-wrap:wrap;margin-bottom:12px}
.ejid{font-family:'SF Mono',ui-monospace,Menlo,monospace;font-size:11px;color:var(--yellow);font-weight:700}
.ejt{font-size:14px;font-weight:700;color:#e8edff;flex:1;line-height:1.45}
.ejc{font-family:'SF Mono',ui-monospace,Menlo,monospace;font-size:11.5px;color:#c9d3f5;line-height:1.6;
 padding:11px 14px;border-radius:10px;background:rgba(0,0,0,.32);border:1px solid rgba(255,255,255,.07);margin-bottom:14px;word-break:break-word}
.ejn{font-size:12.5px;color:var(--muted);line-height:1.65;margin-top:13px;padding-top:13px;border-top:1px solid rgba(255,255,255,.07)}
.legend{display:flex;gap:8px;flex-wrap:wrap;margin-top:18px}
.legend-item{font-size:11px;color:var(--muted2);background:rgba(255,255,255,.035);border:1px solid rgba(255,255,255,.07);
 border-radius:10px;padding:6px 11px;display:flex;gap:8px;align-items:baseline}
.legend-item b{color:#c9d3f5;font-weight:600}
.legend-item span{font-variant-numeric:tabular-nums;color:var(--yellow);font-weight:700}
.note{margin-top:20px;padding:18px 22px;border-radius:16px;font-size:13px;color:var(--muted);line-height:1.68;
 background:rgba(255,255,255,.04);border:1px solid rgba(__GLOW__,.18)}
.note b{color:#e4eaff}
.cta{display:flex;align-items:center;gap:26px;margin-top:22px;padding:26px 30px;border-radius:20px;text-decoration:none;
 background:linear-gradient(120deg,rgba(__GLOW__,.13),rgba(255,255,255,.04));border:1px solid rgba(__GLOW__,.32);
 transition:transform .3s cubic-bezier(.16,1,.3,1),border-color .3s,box-shadow .3s}
.cta:hover{transform:translateY(-3px);border-color:rgba(__GLOW__,.6);box-shadow:0 20px 50px rgba(0,0,0,.42)}
.cta-k{font-size:10px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:var(--yellow);margin-bottom:9px}
.cta-t{font-size:21px;font-weight:800;letter-spacing:-.02em;color:#fff}
.cta-d{font-size:13px;color:var(--muted);line-height:1.65;margin-top:9px;max-width:74ch}
.cta-arr{font-size:30px;color:var(--yellow);flex-shrink:0;transition:transform .3s}
.cta:hover .cta-arr{transform:translateX(7px)}
.flow{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-top:10px}
@media(max-width:940px){.flow{grid-template-columns:1fr 1fr}}
.step{padding:20px;border-radius:16px;background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08)}
.step .n{font-size:10px;font-weight:800;color:var(--yellow);letter-spacing:.12em;margin-bottom:9px}
.step h5{font-size:13.5px;font-weight:800;margin-bottom:7px;letter-spacing:-.01em}
.step p{font-size:12px;color:var(--muted2);line-height:1.6}
footer{text-align:center;padding:42px 30px 60px;font-size:11.5px;color:var(--muted2);border-top:1px solid rgba(255,255,255,.06);line-height:1.8}
footer code{font-family:'SF Mono',ui-monospace,monospace;color:var(--muted)}
</style></head><body>
<div class="aurora"></div><div class="grain"></div>

<div class="hero-bar">
  <img src="__LOGO__" alt="__ALT__">
  <div class="hb-sep"></div>
  <span class="crumb">__CRUMB__ &nbsp;·&nbsp; SPE-AM-001 &nbsp;·&nbsp; <em>DATOS DE PRUEBA SINTÉTICOS</em></span>
  <span class="hb-sp"></span>
  <a href="data/__CSV__" class="back cta-bar" download>Descargar el set</a>
  <a href="__CATALOGO__" class="back">Catálogo de casos</a>
  <a href="__BACK__" class="back">Portal</a>
</div>

<section class="hero wrap">
  <div class="hero-body">
    <div class="hero-title">
      <div class="hero-label">Quality Engineering · Datos de prueba</div>
      <h1 class="hero-h1">Datos sintéticos,<br>no producción enmascarada</h1>
      <p class="hero-sub">Un caso de prueba sin datos es una intención. El gemelo ya sabe qué variable evalúa cada
        regla, con qué tipo y contra qué límite, así que el dato se puede <b>construir</b> en lugar de extraerlo de
        producción y taparlo. Cada uno de los <b>__SETS__ casos</b> tiene su propio set, generado de forma
        determinista: la misma regla produce siempre los mismos valores, y por eso se pueden citar en un defecto.</p>
    </div>
    <div class="hero-stats">
      <div class="stat-block"><div class="sn">__SETS__</div><div class="sl">Sets generados</div></div>
      <div class="stat-block blue"><div class="sn">__CAMPOS__</div><div class="sl">Campos con valor</div></div>
      <div class="stat-block blue"><div class="sn">__PERSONAS__</div><div class="sl">Clientes sintéticos</div></div>
    </div>
  </div>
</section>

<!-- ═══ POR QUÉ SINTÉTICO ═══ -->
<section class="wrap">
  <div class="shead">
    <div class="kick">La decisión de fondo</div>
    <h2>Enmascarar producción<br>resuelve el dato y rompe la prueba</h2>
    <p>La ruta habitual es copiar un extracto de producción y enmascararlo. Funciona para volumen, pero arrastra tres
      problemas en una modernización: el extracto sigue siendo dato personal mientras viaja al ambiente de pruebas, el
      enmascaramiento rompe las relaciones que el propio sistema valida, y el extracto contiene lo que pasó, no lo que
      hace falta probar. Los valores límite casi nunca están en producción, y son exactamente donde el target diverge.</p>
  </div>
  <div class="cols3">
    <div class="card glass">
      <h4>Cobertura dirigida</h4>
      <p>El dato se construye para el caso. Si la regla corta en un umbral, el set trae el valor justo por debajo,
        el exacto y el justo por encima. Ese trío rara vez existe en un extracto y es el que destapa si el operador
        del target quedó inclusivo o estricto.</p>
    </div>
    <div class="card glass">
      <h4>Sin dato personal</h4>
      <p>No hay nada que enmascarar porque nunca se copió nada. El ambiente de pruebas deja de ser un lugar donde vive
        información de clientes reales, y el parallel-run deja de depender de una autorización de privacidad para
        arrancar.</p>
    </div>
    <div class="card glass">
      <h4>Reproducible</h4>
      <p>La semilla sale del identificador del caso. Regenerar el set produce byte por byte los mismos valores, así
        que un defecto se reporta con el identificador del caso y cualquiera reconstruye la entrada exacta sin
        adjuntar archivos.</p>
    </div>
  </div>
</section>

<!-- ═══ CÓMO SE CONSTRUYE ═══ -->
<section class="wrap">
  <div class="shead">
    <div class="kick">Cómo se construye el valor</div>
    <h2>Del fragmento de código<br>al dato con tipo y con intención</h2>
    <p>El gemelo guarda el fragmento SPL de cada regla. De ahí salen las variables que participan en la condición;
      cada una se tipa por su nombre y por el prefijo del dialecto del sistema, y recibe un valor acorde a lo que el
      caso quiere ejercitar. Cuando la fórmula redondea o divide, los montos se generan a medio centavo a propósito.</p>
  </div>
  <div class="flow">
    <div class="step"><div class="n">01</div><h5>Parseo</h5><p>Del fragmento se extraen las variables de entrada y se descarta el lado izquierdo, que es el resultado.</p></div>
    <div class="step"><div class="n">02</div><h5>Tipado</h5><p>Nombre y prefijo deciden el tipo: monto, fecha, tasa, cuenta, CLABE, tarjeta, RFC, CURP, días, código.</p></div>
    <div class="step"><div class="n">03</div><h5>Intención</h5><p>El valor se sesga según el caso: satisface, incumple, cae en el límite o fuerza el borde de redondeo.</p></div>
    <div class="step"><div class="n">04</div><h5>Coherencia</h5><p>Cada caso se ancla a un cliente del pool sintético, de modo que cuenta, CLABE y tarjeta pertenecen a la misma persona.</p></div>
  </div>
  <div class="legend">__TIPOS__</div>
</section>

<!-- ═══ EJEMPLOS ═══ -->
<section class="wrap">
  <div class="shead">
    <div class="kick">Sets reales</div>
    <h2>Tres casos con su dato</h2>
    <p>Estos sets salieron del generador tal cual. Arriba de cada tabla está el fragmento del legacy del que se
      dedujeron las variables.</p>
  </div>
  __EJEMPLOS__
</section>

<!-- ═══ VALIDEZ ESTRUCTURAL ═══ -->
<section class="wrap">
  <div class="shead">
    <div class="kick">Validez estructural</div>
    <h2>Falso, pero bien formado</h2>
    <p>Un dato sintético mal formado falla por la razón equivocada: el componente lo rechaza por formato y la regla
      nunca se ejercita. Por eso los identificadores del dominio se construyen con su dígito verificador y con rangos
      que no pueden pertenecer a nadie.</p>
  </div>
  <div class="cols2">
    <div class="card glass">
      <h4>Imposible de confundir con un dato real</h4>
      <p>La CLABE usa el código de banco <code>__BANCO__</code>, que Banxico no tiene asignado a ninguna institución, y
        aun así calcula correctamente su dígito verificador con la ponderación 3, 7, 1. Las tarjetas se emiten sobre el
        BIN de pruebas <code>__BIN__</code> y cierran con dígito de Luhn válido. Si uno de estos valores se filtra a un
        log o a un ticket, no hay nada que notificar.</p>
    </div>
    <div class="card glass">
      <h4>Coherencia entre campos</h4>
      <p>RFC y CURP se derivan del mismo nombre y fecha de nacimiento ficticios del cliente, con la estructura que
        esperan las validaciones. Cuenta, CLABE y tarjeta pertenecen al mismo titular. Un caso de extremo a extremo
        recorre todos sus pasos con la misma persona, que es lo que permite que el comparador del parallel-run
        encuentre el registro en cada etapa.</p>
    </div>
  </div>
  <div class="note"><b>Lo que el generador no decide:</b> el volumen. Para las pruebas de carga el set define la forma
    del registro, no cuántos hacen falta; ese número sale de la telemetría de producción que ya está en la vista del
    método. Y para una regla cuyo comportamiento esperado está en disputa, el dato se genera igual, pero el resultado
    correcto sigue siendo una decisión del SME de dominio.</div>

  <a class="cta" href="data/__CSV__" download>
    <div>
      <div class="cta-k">Entregable</div>
      <div class="cta-t">Descargar los __SETS__ sets en CSV</div>
      <div class="cta-d">Formato largo con caso, cliente sintético, campo, tipo, valor y la razón del valor. Punto y
        coma como separador y UTF-8 con BOM, listo para cargarse como fixture o importarse al ALM. El mismo contenido
        está en <code>data/__JSON__</code> para consumo programático.</div>
    </div>
    <span class="cta-arr">→</span>
  </a>
</section>

<footer>
  __CRUMB__ · SPE-AM-001 · Sets generados por <code>build-test-data.py</code> a partir del catálogo de casos.<br>
  __SETS__ sets · __CAMPOS__ campos · __PERSONAS__ clientes sintéticos · sin un solo dato de producción.
</footer>
</body></html>"""


def main():
    ap = argparse.ArgumentParser(description="Datos de prueba sintéticos por caso")
    ap.add_argument("--brand", choices=list(BRANDS) + ["all"], default="all")
    args = ap.parse_args()

    cat, pool, sets = construir()
    print(f"Casos en el catálogo : {len(cat['casos']):,}")
    print(f"Sets generados       : {len(sets):,}")
    print(f"Campos con valor     : {sum(len(v['c']) for v in sets.values()):,}")
    print(f"Clientes sintéticos  : {len(pool):,}")

    for key in (list(BRANDS) if args.brand == "all" else [args.brand]):
        b = BRANDS[key]
        meta = escribir(cat, pool, sets, b)
        b["html"].parent.mkdir(parents=True, exist_ok=True)
        pagina = render(meta, cat, sets, b)
        b["html"].write_text(pagina, encoding="utf-8")
        print(f"\n[{key}] {b['html'].relative_to(BASE)} · {len(pagina):,} bytes")
        print(f"       {b['data'].relative_to(BASE)} · {b['data'].stat().st_size:,} bytes")
        print(f"       {b['csv'].relative_to(BASE)} · {b['csv'].stat().st_size:,} bytes")


if __name__ == "__main__":
    main()
