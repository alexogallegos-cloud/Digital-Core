#!/usr/bin/env python3
"""
Liverpool — Bronze Rule Name Inference (heuristic)
--------------------------------------------------
Reads  portal/data/rules-bronze-liv.json
Writes business_name + name_source into each rule (in place).

ADR-SPE-AM-010: el extractor deja business_name = "". La síntesis LLM es la
fuente PRIMARIA. Este script produce nombres HEURÍSTICOS de capa Bronze —
descripción mecánica del código ABAP — para que el catálogo sea navegable
mientras llega la síntesis semántica (Silver). Cada nombre queda marcado con
name_source = "heuristic-bronze" para que Silver lo pueda sobrescribir.
"""
import json, re
from pathlib import Path

HERE = Path(__file__).parent
JSON = HERE.parent / "portal" / "data" / "rules-bronze-liv.json"

# ── Diccionario de campos ABAP → término de negocio ───────────────────────────
# SAP estándar (Módulo MM/FI) + campos Z custom de Liverpool (Importaciones)
FIELD_TERMS = {
    # --- SAP estándar ---
    "menge": "cantidad", "lfimg": "cantidad de entrega", "cantpprov": "cantidad del proveedor",
    "canthprov": "cantidad del proveedor",
    "waers": "moneda", "hwaer": "moneda local",
    "ukurs": "tipo de cambio", "kursf": "tipo de cambio", "wkurs": "tipo de cambio",
    "dmbtr": "importe en moneda local", "wrbtr": "importe del documento",
    "netwr": "valor neto", "kbetr": "importe de condición", "netpr": "precio neto",
    "belnr": "documento contable", "ebeln": "pedido de compra", "ebelp": "posición del pedido",
    "lifnr": "proveedor", "ekgrp": "grupo de compras", "matnr": "material",
    "bukrs": "sociedad", "werks": "centro", "mblnr": "documento de material",
    "rbstat": "estatus de factura", "datum": "fecha", "etxdat": "fecha de entrega",
    "subrc": "resultado de operación", "tabix": "índice de tabla",
    "ponum": "número de pedido", "ponum": "número de pedido", "ind": "contador",
    "objkey": "clave de objeto", "fieldname": "campo", "tabname": "tabla",
    "monto": "monto", "neto": "neto", "mreal": "monto real", "mfact": "monto de factura",
    "message": "mensaje", "anticipo": "anticipo", "pediva": "IVA del pedimento",
    "iva": "IVA", "ivagasto": "IVA de gastos", "wa_totales": "totales",
    # --- Z custom Liverpool — Módulo Importaciones ---
    "zzstatus_mi": "estatus de importación",
    "zzsolpg": "solicitud de pedido", "zzstspg": "estatus de pedido",
    "zzimimp": "importe de importación", "zzimnet": "importe neto de importación",
    "zzimbrt": "importe bruto de importación",
    "zzfstem": "fecha estimada", "zzfstcd": "fecha de cierre", "zzfscdf": "fecha",
    "zzfentr": "fecha de entrada", "zzmnrft": "monto de flete",
    "pedmon": "monto del pedimento", "pedimento": "pedimento", "zzpedi": "pedimento",
}

# Valores de moneda conocidos → glosa
CURRENCY_GLOSS = {"MXP": "peso mexicano", "MXN": "peso mexicano", "USD": "dólar"}

OP_SYMBOL = {"gt": ">", "ge": ">=", "lt": "<", "le": "<=", "eq": "=", "ne": "≠",
             ">": ">", ">=": ">=", "<": "<", "<=": "<=", "=": "=", "<>": "≠"}

# prefijos ABAP a descartar al descomponer un identificador
_PREFIX = re.compile(r"^(it_|wa_|ls_|lt_|lv_|gv_|gs_|gt_|is_|es_|im_|ex_|ch_|"
                     r"i_|w_|l_|g_|p_|vl_|v_|s_|o_|obj_|<[a-z_]*>-?)", re.I)


def clean_token(tok: str) -> str:
    """Última componente de un campo estructurado, sin prefijo húngaro."""
    t = tok.strip().strip("<>").lower()
    if "-" in t:
        t = t.split("-")[-1]
    t = _PREFIX.sub("", t)
    return t


def term_for(tok: str) -> str:
    """Término de negocio para un identificador ABAP."""
    key = clean_token(tok)
    if key in FIELD_TERMS:
        return FIELD_TERMS[key]
    # campo Z desconocido → quitar zz y presentar limpio
    if key.startswith("zz"):
        key = key[2:]
    return key.replace("_", " ") or tok.lower()


def first_business_field(code: str, exclude=("sy-subrc", "sy-tabix", "sy-")):
    """Primer identificador con contenido de negocio dentro de una condición."""
    for m in re.finditer(r"([a-z_][a-z0-9_]*(?:-[a-z0-9_]+)?|<[a-z_]+>-[a-z0-9_]+)", code, re.I):
        tok = m.group(1)
        low = tok.lower()
        if any(low.startswith(x) or low == x.rstrip("-") for x in exclude):
            continue
        if low in ("if", "elseif", "when", "and", "or", "not", "is", "initial",
                   "eq", "ne", "gt", "lt", "ge", "le", "bound", "check", "in"):
            continue
        return tok
    return None


def name_formula(code: str) -> str:
    # ABAP aritmética acumulativa: ADD/SUBTRACT/MULTIPLY/DIVIDE
    ma = re.match(r"\s*(add|subtract)\s+.+?\s+(?:to|from)\s+([a-z_][a-z0-9_<>-]*)", code, re.I)
    if ma:
        verb = "Acumulación de" if ma.group(1).lower() == "add" else "Deducción de"
        return f"{verb} {term_for(ma.group(2))}"
    mm = re.match(r"\s*(multiply|divide)\s+([a-z_][a-z0-9_<>-]*)", code, re.I)
    if mm:
        return f"Cálculo de {term_for(mm.group(2))}"
    # asignación / cálculo estándar: lhs = rhs
    m = re.match(r"\s*([a-z_][a-z0-9_<>-]*)\s*=\s*(.+)", code, re.I)
    if not m:
        return "Asignación de valor"
    lhs, rhs = m.group(1), m.group(2)
    if "|" in rhs or "&&" in rhs:                    # string template / concat
        return f"Construcción de {term_for(lhs)}"
    verb = "Cálculo de" if re.search(r"[*/+]|(?<=\w)\s-\s(?=\w)", rhs) else "Asignación de"
    return f"{verb} {term_for(lhs)}"


def name_validacion(code: str) -> str:
    low = code.lower()
    mx = re.search(r"raise\s+exception\s+type\s+(\w+)", low)
    if mx:
        return f"Validación con excepción {mx.group(1).upper()}"
    if re.search(r"\bmessage\b", low):
        return "Validación con mensaje de error"
    mi = re.search(r"([a-z_][a-z0-9_\[\]<>-]*)\s+is\s+(not\s+)?initial", low)
    if mi:
        neg = mi.group(2)
        term = term_for(mi.group(1).replace("[]", ""))
        return f"Validación de {term} {'con datos' if neg else 'sin datos'}"
    if "sy-subrc" in low:
        if re.search(r"sy-subrc\s*(=|eq)\s*0\b", low):
            return "Validación de operación exitosa"
        if re.search(r"sy-subrc\s*(<>|ne|>|gt)\s*0\b", low):
            return "Validación de operación fallida"
        return "Validación de resultado de operación"
    fld = first_business_field(code)
    return f"Validación de {term_for(fld)}" if fld else "Validación de condición"


def name_umbral(code: str) -> str:
    m = re.search(r"([a-z_][a-z0-9_<>-]*)\s*(gt|ge|lt|le|>=|<=|>|<)\s*(\d+)", code, re.I)
    if not m:
        return "Umbral numérico"
    fld, op, num = m.group(1), m.group(2).lower(), m.group(3)
    return f"Umbral de {term_for(fld)} {OP_SYMBOL.get(op, op)} {num}"


def name_estado(code: str) -> str:
    m = re.search(r"([a-z_][a-z0-9_<>-]*)\s*(eq|=|ne|<>)\s*'([^']+)'", code, re.I)
    if not m:
        fld = first_business_field(code)
        return f"Estado de {term_for(fld)}" if fld else "Verificación de estado"
    fld, _, val = m.group(1), m.group(2), m.group(3)
    term = term_for(fld)
    gloss = CURRENCY_GLOSS.get(val.upper())
    tail = f"'{val}' ({gloss})" if gloss else f"'{val}'"
    return f"Verificación de {term} = {tail}"


NAMERS = {
    "FÓRMULA": name_formula,
    "VALIDACIÓN": name_validacion,
    "UMBRAL": name_umbral,
    "ESTADO": name_estado,
}


def cap(s: str) -> str:
    return s[:1].upper() + s[1:] if s else s


def main():
    data = json.loads(JSON.read_text(encoding="utf-8"))
    counts = {}
    for r in data["rules"]:
        namer = NAMERS.get(r["tipo"])
        name = cap(namer(r["code"]).strip()) if namer else ""
        r["business_name"] = name
        r["name_source"] = "heuristic-bronze"
        counts[r["tipo"]] = counts.get(r["tipo"], 0) + (1 if name else 0)
    JSON.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    named = sum(counts.values())
    print(f"Named {named}/{len(data['rules'])} rules (heuristic-bronze)")
    for t, c in counts.items():
        print(f"  {t}: {c}")


if __name__ == "__main__":
    main()
