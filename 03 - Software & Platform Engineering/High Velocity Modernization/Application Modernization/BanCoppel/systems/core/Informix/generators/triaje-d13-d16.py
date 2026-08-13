"""
triaje-d13-d16.py — BCOPCore Triaje Regulatorio D13-D16 v1.0
==============================================================
Añade anotaciones reg + riesgo a las 627 reglas de D13 (TEF),
D14 (BEI), D15 (LIDE/PLD) y D16 (Tarjetas) que carecen de ellas.

Fuentes canónicas actualizadas:
  portal/data/business-rules-v3.json
  digital-brain/brain.db (columnas rules.reg, rules.riesgo)

Heurísticas por dominio:
  D13 — BANXICO SPEI/CECOBAN + SAT LIVA (IVA)
  D14 — CNBV Banca Electrónica + CNBV tokens/auth + SAT LIVA (IVA)
  D15 — CNBV PLD/FT Circular 4/2019 + Art.78 LIC + GAFI Rec.10/11
  D16 — CNBV Tarjetas CUB + VISA/MC + Art.78 LIC

v1.0 (2026-08-11): cobertura inicial D13-D16 (627 reglas).
"""

import ast
import json
import re
import sqlite3
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

BASE  = Path(__file__).resolve().parent.parent
V3    = BASE / "portal" / "data" / "business-rules-v3.json"
DB    = BASE / "digital-brain" / "brain.db"

# ── Utilidades ─────────────────────────────────────────────────────────────────

def mk_reg(*pairs) -> list:
    """Retorna lista de [fuente, descripción] compatible con v3.json."""
    return [list(p) for p in pairs]


def mk_riesgo(*tags) -> list:
    return list(tags)


def has_any(text: str, *tokens) -> bool:
    t = text.lower()
    return any(tok.lower() in t for tok in tokens)


# ── Catálogo de refs regulatorias ──────────────────────────────────────────────

_BANXICO_SPEI  = ("BANXICO",  "Reglas SPEI/CECOBAN — transferencias electrónicas de fondos (Art. 42 LSNSP)")
_SAT_IVA       = ("SAT",      "LIVA Art. 1 — tasa IVA 16% aplicable a comisiones y servicios financieros")
_CNBV_CUB_COM  = ("CNBV",     "Disposiciones Únicas de Bancos — comisiones y cuotas de servicios bancarios")
_CNBV_BEI      = ("CNBV",     "Disposiciones Únicas de Bancos — banca electrónica institucional y autenticación fuerte")
_CNBV_TOKEN    = ("CNBV",     "Circular 22/2010 CNBV — autenticación fuerte y gestión de tokens en banca electrónica")
_CNBV_PLD      = ("CNBV",     "CNBV PLD/FT — Disposiciones en materia de Prevención de Lavado de Dinero (Circular 4/2019)")
_CNBV_ART78    = ("CNBV",     "Art. 78 LIC — conservación de información 5 años (bitácoras y movimientos)")
_CNBV_PLD_RPT  = ("CNBV",     "CNBV PLD — reportes de operaciones inusuales, relevantes e internas preocupantes")
_GAFI_REC10    = ("GAFI",     "FATF Rec. 10/11 — debida diligencia del cliente y monitoreo de transacciones")
_CNBV_TDC      = ("CNBV",     "Disposiciones Únicas de Bancos — tarjetas de crédito y débito (Capítulo XI CUB)")
_VISA_MC_INV   = ("VISA/MC",  "Visa/MC Issuer Rules — card inventory management, card personalization and issuance controls")
_VISA_MC_CANC  = ("VISA/MC",  "Visa/MC Issuer Rules — card cancellation, lost/stolen and fraud replacement procedures")

_RIESGO_ROUND    = "ROUND — validar modo (banker's vs half-up)"
_RIESGO_MONEY    = "MONEY — banker's rounding Informix; NUMERIC PostgreSQL diverge"
_RIESGO_DIV      = "DIV — división monetaria puede perder centavos; usar DECIMAL(18,4)"
_RIESGO_IVA      = "IVA — cálculo 16% sobre base; verificar base imponible y redondeo"
_RIESGO_DBACCESS = "DBACCESS — ejecución SQL externa vía shell; paths AIX (/resplogifx/, /tmp/) muertos en target AWS/PostgreSQL"


# ── Inferencia de reg ──────────────────────────────────────────────────────────

def infer_reg_d13(rule: dict) -> list[tuple]:
    code = rule.get("code", "") or ""
    sp   = (rule.get("sp", "") or "").lower()
    refs: list[tuple] = []

    refs.append(_BANXICO_SPEI)

    if has_any(code, "viva", "mIva", "iva_cob", "mIvaCom", "iva"):
        refs.append(_SAT_IVA)
    if has_any(code, sp, "mcomision", "comision", "mMontoCom", "vimportecom"):
        refs.append(_CNBV_CUB_COM)

    return refs


def infer_reg_d14(rule: dict) -> list[tuple]:
    code = rule.get("code", "") or ""
    sp   = (rule.get("sp", "") or "").lower()
    refs: list[tuple] = [_CNBV_BEI]

    if has_any(code, sp, "token", "admtoken", "solicitudstatus", "estatustokenasociado"):
        refs.append(_CNBV_TOKEN)
    if has_any(code, "mIva", "viva", "iva"):
        refs.append(_SAT_IVA)

    return refs


def infer_reg_d15(rule: dict) -> list[tuple]:
    code = rule.get("code", "") or ""
    sp   = (rule.get("sp", "") or "").lower()
    refs: list[tuple] = [_CNBV_PLD]

    if has_any(code, sp, "bdiauditor", "bitacora", "log_", "logifx"):
        refs.append(_CNBV_ART78)
    if has_any(code, sp, "sp_pld", "pld_chq", "addfolio", "folio", "UNLOAD", "reporte"):
        refs.append(_CNBV_PLD_RPT)
    if has_any(sp, "pld", "lide", "auditor"):
        refs.append(_GAFI_REC10)

    return refs


def infer_reg_d16(rule: dict) -> list[tuple]:
    code = rule.get("code", "") or ""
    sp   = (rule.get("sp", "") or "").lower()
    refs: list[tuple] = [_CNBV_TDC]

    if has_any(code, sp, "dbaccess intercard", "inventario", "log_existencia",
               "log_solicitadas", "personalizacion"):
        refs.append(_VISA_MC_INV)
    if has_any(sp, "cancelatarjetas", "rob_frau", "ext"):
        refs.append(_VISA_MC_CANC)
    if has_any(code, sp, "bdiauditor", "auditortarjeta", "bitacora"):
        refs.append(_CNBV_ART78)

    return refs


INFER_REG = {
    "D13": infer_reg_d13,
    "D14": infer_reg_d14,
    "D15": infer_reg_d15,
    "D16": infer_reg_d16,
}


# ── Inferencia de riesgo ───────────────────────────────────────────────────────

def infer_riesgo(rule: dict) -> list[str]:
    if rule.get("tipo", "") != "FÓRMULA":
        return []
    code     = (rule.get("code", "") or "")
    code_low = code.lower()
    domain   = str(rule.get("dominio", rule.get("domain", "")))
    tags: list[str] = []

    if "::money" in code_low or re.search(r'\bmoney\b', code_low):
        tags.append(_RIESGO_MONEY)
    if re.search(r'\b(round|trunc)\s*\(', code_low):
        tags.append(_RIESGO_ROUND)
    if re.search(r'/\s*\(?\s*(1\s*\+|vmontotot|viva|miva|valorc)', code_low):
        tags.append(_RIESGO_DIV)
    if re.search(r'\*\s*(viva|miva|mivac|iva)', code_low):
        tags.append(_RIESGO_IVA)

    # D16 — ejecución SQL externa vía shell (dbaccess + paths AIX)
    if domain.startswith("D16") and (
        "dbaccess" in code_low
        or "/resplogifx/" in code
        or "unload to" in code_low
        or re.search(r"vsql\s*=", code_low)
    ):
        tags.append(_RIESGO_DBACCESS)

    # Evitar duplicar ROUND si ya está MONEY (MONEY implica rounding risk)
    if _RIESGO_MONEY in tags and _RIESGO_ROUND in tags:
        tags.remove(_RIESGO_ROUND)

    return tags


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    print("=" * 60)
    print("triaje-d13-d16.py — Anotación regulatoria D13-D16 v1.0")
    print("=" * 60)

    v3_data  = json.loads(V3.read_text(encoding="utf-8"))
    v3_rules = v3_data["rules"]
    by_id    = {r["id"]: r for r in v3_rules}

    # Normalizar string-repr → lista real (artefactos de mk_reg/mk_riesgo antiguo con repr())
    n_normalized = 0
    for r in v3_rules:
        for field in ("reg", "riesgo"):
            val = r.get(field)
            if isinstance(val, str) and val.strip().startswith("["):
                try:
                    r[field] = ast.literal_eval(val)
                    n_normalized += 1
                except (ValueError, SyntaxError):
                    pass
    if n_normalized:
        print(f"  [normalize] {n_normalized} campos string-repr convertidos a lista")

    targets = {d: [] for d in ("D13", "D14", "D15", "D16")}
    for r in v3_rules:
        dom = str(r.get("dominio", ""))
        for d in targets:
            if dom.startswith(d):
                targets[d].append(r)
                break

    stats = {d: {"reg_added": 0, "riesgo_added": 0, "total": 0} for d in targets}

    def is_empty(val) -> bool:
        if val is None:
            return True
        if isinstance(val, list):
            return len(val) == 0
        return str(val).strip() in ("", "[]", "null", "None")

    for dom, rules in targets.items():
        fn_reg = INFER_REG[dom]
        stats[dom]["total"] = len(rules)

        for r in rules:
            # ── reg ──────────────────────────────────────────────────────
            if is_empty(r.get("reg")):
                new_refs = fn_reg(r)
                if new_refs:
                    r["reg"] = mk_reg(*new_refs)
                    stats[dom]["reg_added"] += 1

            # ── riesgo ───────────────────────────────────────────────────
            if is_empty(r.get("riesgo")):
                new_risk = infer_riesgo(r)
                if new_risk:
                    r["riesgo"] = mk_riesgo(*new_risk)
                    stats[dom]["riesgo_added"] += 1

    # ── Guardar v3.json ───────────────────────────────────────────────────────
    V3.write_text(json.dumps(v3_data, ensure_ascii=False, indent=2), encoding="utf-8")

    print("\n── Resultados por dominio ────────────────────────────────────")
    total_reg = total_riesgo = total_n = 0
    for dom, s in stats.items():
        print(f"  {dom}: {s['total']} reglas | reg_added={s['reg_added']} | riesgo_added={s['riesgo_added']}")
        total_reg    += s["reg_added"]
        total_riesgo += s["riesgo_added"]
        total_n      += s["total"]
    print(f"  TOTAL: {total_n} reglas | +{total_reg} reg | +{total_riesgo} riesgo")

    # ── Sync brain.db ─────────────────────────────────────────────────────────
    print("\n── Sync brain.db ──────────────────────────────────────────────")
    conn = sqlite3.connect(DB)
    cur  = conn.cursor()

    db_reg_upd = db_riesgo_upd = 0
    for dom, rules in targets.items():
        for r in rules:
            rid = str(r.get("id", ""))
            # Normalize to string — existing riesgo may be a Python list from old extraction
            new_reg    = r.get("reg", "[]")
            new_riesgo = r.get("riesgo", "[]")
            if isinstance(new_reg, list):
                new_reg = repr(new_reg)
            if isinstance(new_riesgo, list):
                new_riesgo = repr(new_riesgo)
            new_reg    = str(new_reg) or "[]"
            new_riesgo = str(new_riesgo) or "[]"
            cur.execute(
                "UPDATE rules SET reg=?, riesgo=? WHERE id=?",
                (new_reg, new_riesgo, rid)
            )
            if cur.rowcount:
                if new_reg    not in ("[]", ""):
                    db_reg_upd    += 1
                if new_riesgo not in ("[]", ""):
                    db_riesgo_upd += 1

    conn.commit()
    conn.close()
    print(f"  brain.db actualizado: {db_reg_upd} con reg | {db_riesgo_upd} con riesgo")

    # ── Resumen cobertura post-triaje ─────────────────────────────────────────
    print("\n── Cobertura post-triaje (brain.db) ───────────────────────────")
    conn2 = sqlite3.connect(DB)
    cur2  = conn2.cursor()
    for dom in ("D13", "D14", "D15", "D16"):
        n   = cur2.execute(f"SELECT COUNT(*) FROM rules WHERE domain LIKE '{dom}%'").fetchone()[0]
        nr  = cur2.execute(f"SELECT COUNT(*) FROM rules WHERE domain LIKE '{dom}%' AND reg NOT IN ('[]','','None','null')").fetchone()[0]
        nri = cur2.execute(f"SELECT COUNT(*) FROM rules WHERE domain LIKE '{dom}%' AND riesgo NOT IN ('[]','','None','null')").fetchone()[0]
        print(f"  {dom}: {n} reglas | reg={nr}/{n} ({nr*100//n if n else 0}%) | riesgo={nri}/{n} ({nri*100//n if n else 0}%)")
    conn2.close()

    print("\n✔  Triaje D13-D16 completado.")
    print(f"   Actualiza: {V3}")
    print(f"   Actualiza: {DB}")


if __name__ == "__main__":
    main()