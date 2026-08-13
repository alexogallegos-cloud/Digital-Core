"""
triaje-d17-d49.py — BCOPCore Triaje Regulatorio D17-D49 v1.0
==============================================================
Añade anotaciones reg + riesgo a las ~491 reglas de D17-D49
que carecen de ellas en portal/data/business-rules-v3.json y brain.db.

Estrategia:
  1. Default regulatorio por dominio (cubre todo lo sin reg)
  2. Pattern-overrides por keywords en SP name y code fragment
  3. Detección universal de riesgo en reglas FÓRMULA

Dominios cubiertos (25 dominios D17-D49, excluye D34 Respaldos DBA):
  D17 BPI               — CNBV operaciones básicas
  D18 Intercard BPI     — CNBV TDC + VISA/MC
  D19 Tarjetas          — CNBV CUB Cap.XI + VISA/MC
  D20 Programas (AFORE) — CONSAR + SAT IVA + CNBV pagos programados
  D21 Domiciliación     — Banxico CLC (pocos sin reg, skip)
  D22 Transferencias    — Banxico SPEI + CNBV
  D23 MIS               — CNBV gestión sucursales
  D24 Buró de Crédito   — CNBV + LRSIC
  D25 Sitio Especial    — CNBV PLD + GAFI (lista bloqueados)
  D26 Prospectos        — CNBV KYC + PLD/GAFI
  D27 Auditoría         — CNBV Art.78 LIC + CUB auditoría
  D28 Inversiones       — CNBV inversiones + Banxico
  D29 Estados Cuenta    — CNBV/CONDUSEF (pocos sin reg, skip)
  D30 Tarjetas Coppel   — CNBV TDC + VISA/MC
  D31 Control Cheques   — CNBV + CECOBAN
  D32 Reports           — MC + VISA + CNBV TDC
  D33 Monitor Cobranza  — CNBV calidad cartera
  D35 Digital           — CNBV expediente digital
  D36 Repaut            — CNBV CUB Serie R (reportes supervisión) + Banxico FX
  D41 Corresponsalía    — Banxico UDI + CNBV Corresponsales
  D42 IVR               — CNBV canales alternativos
  D43 Transf.Presencial — Banxico SPEI presencial
  D44 RECH              — CNBV conciliación
  D46 OFI               — CONDUSEF + CNBV
  D48 Riesgos           — CNBV riesgo crédito (Basilea III)

v1.0 (2026-08-12): anotación inicial D17-D49 (491 reglas objetivo).
"""

import ast
import json
import re
import sqlite3
import sys
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE = Path(__file__).resolve().parent.parent
V3   = BASE / "portal" / "data" / "business-rules-v3.json"
DB   = BASE / "digital-brain" / "brain.db"

# ── Refs regulatorias canónicas ────────────────────────────────────────────────

# CNBV — general y por tipo de operación
_CNBV_GEN     = ["CNBV",    "Disposiciones Únicas de Bancos — operaciones y servicios bancarios generales (CUB)"]
_CNBV_TDC     = ["CNBV",    "Disposiciones Únicas de Bancos — tarjetas de crédito y débito (Capítulo XI CUB)"]
_CNBV_ART78   = ["CNBV",    "Art.78 LIC — conservación de información 5 años (bitácoras y movimientos)"]
_CNBV_AUD     = ["CNBV",    "CUB Título Sexto — función de auditoría interna; control y supervisión"]
_CNBV_LRSIC   = ["CNBV",    "LRSIC — Ley para Regular las Sociedades de Información Crediticia; reportes a buró de crédito"]
_CNBV_SITESP  = ["CNBV",    "Circular 4/2019 PLD — Sitio Especial: personas sin acceso a servicios financieros por riesgo PLD/FT"]
_CNBV_KYC     = ["CNBV",    "CUB Título Tercero — apertura y operación de cuentas; identificación de clientes (KYC)"]
_CNBV_PLD     = ["CNBV",    "CNBV PLD/FT — Disposiciones en materia de Prevención de Lavado de Dinero (Circular 4/2019)"]
_CNBV_INV     = ["CNBV",    "Disposiciones Únicas de Bancos Título V — inversiones en valores y tesorería bancaria"]
_CNBV_CHQ     = ["CNBV",    "Disposiciones Únicas de Bancos — operaciones con cheques (CUB Cap.IX); compensación CECOBAN"]
_CNBV_CARTERA = ["CNBV",    "CUB Anexo 33 — calificación de cartera crediticia; metodologías de reservas preventivas"]
_CNBV_DIGIT   = ["CNBV",    "Circular 14/2020 CNBV — expediente digital de clientes; documentación en formato electrónico"]
_CNBV_SERIES  = ["CNBV",    "CUB Serie R — reportes regulatorios de supervisión; Anexo 1-A catálogo de cuentas contables"]
_CNBV_CORRESP = ["CNBV",    "Circular 14/2015 CNBV — operaciones con corresponsales bancarios; límites y controles"]
_CNBV_EDOCTA  = ["CNBV",    "CUB Art.48 Bis 2 — estado de cuenta digital; Circular 14/2020 banca digital"]
_CNBV_IVR     = ["CNBV",    "Disposiciones Únicas de Bancos — canales alternativos de atención; IVR y banca telefónica"]
_CNBV_CONCIL  = ["CNBV",    "Disposiciones Únicas de Bancos — conciliación operativa y control de rechazos interbancarios"]
_CNBV_RIESGO  = ["CNBV",    "CUB Anexo 33 — riesgo de crédito; requerimientos de capital Basilea III"]

# Banxico
_BANXICO_SPEI = ["Banxico", "Reglas SPEI/CECOBAN — transferencias electrónicas de fondos (Art.42 LSNSP)"]
_BANXICO_CLC  = ["Banxico", "Circular 14/2017 Banxico — Cargos por Lote y Compensación (CLC); domiciliación automática"]
_BANXICO_INV  = ["Banxico", "Circular 3/2012 Banxico — reporte de posiciones en valores e instrumentos financieros derivados"]
_BANXICO_UDI  = ["Banxico", "Decreto UDI — valor de Unidades de Inversión publicado diario por Banxico; Circular 6/2015"]
_BANXICO_FX   = ["Banxico", "Circular 2019/2017 Banxico — tipo de cambio FIX; reporte de posiciones en divisas"]

# CONSAR / SAR
_CONSAR_SAR   = ["CONSAR",  "Ley del SAR y Reglas de Operación AFORE — cuenta individual, subcuentas SAR, rendimientos mínimos garantizados"]
_IMSS_SAR     = ["IMSS",    "Ley del Seguro Social Art.168 — aportaciones SAR 2% obrero-patronal"]

# SAT
_SAT_IVA      = ["SAT",     "LIVA Art.1 — tasa IVA 16% aplicable a comisiones y servicios financieros"]
_SAT_LISR     = ["SAT",     "LISR Art.151 — deducibilidad de aportaciones voluntarias al SAR"]

# GAFI
_GAFI_REC10   = ["GAFI",    "FATF Rec.10/11 — debida diligencia del cliente y monitoreo de transacciones"]

# VISA / MC
_VISA_RULES   = ["VISA",    "Visa Core Rules — requisitos de emisor, operación de tarjetas y reportería regulatoria"]
_MC_RULES     = ["MC",      "MasterCard Network Rules — requisitos de emisor, intercambio y reportería trimestral"]

# CONDUSEF
_CONDUSEF_COB = ["CONDUSEF", "LFPIORPI + disposiciones CONDUSEF — transparencia en cobro de créditos; comisiones y cobros"]


# ── Mapa dominio → regulación default ─────────────────────────────────────────
# Clave = valor del campo 'dominio' en v3.json (ej. "D17 BPI")
# Si un dominio tiene muy pocos sin_reg (<5) se puede omitir — igual se aplican patterns

DOMAIN_DEFAULT: dict[str, list] = {
    "D17 BPI":                          [_CNBV_GEN],
    "D18 Intercard BPI":                [_CNBV_TDC, _VISA_RULES],
    "D19 Tarjetas":                     [_CNBV_TDC],
    "D20 Programas":                    [_CNBV_GEN],          # + CONSAR via pattern afore
    "D21 Domiciliación":                [_BANXICO_CLC],
    "D22 Transferencias":               [_BANXICO_SPEI],
    "D23 MIS":                          [_CNBV_GEN],
    "D24 Buró de Crédito":              [_CNBV_LRSIC],
    "D25 Sitio Especial":               [_CNBV_SITESP, _GAFI_REC10],
    "D26 Prospectos":                   [_CNBV_KYC, _CNBV_PLD],
    "D27 Auditoría":                    [_CNBV_ART78, _CNBV_AUD],
    "D28 Inversiones":                  [_CNBV_INV, _BANXICO_INV],
    "D29 Estados de Cuenta Electrónicos": [_CNBV_EDOCTA],
    "D30 Tarjetas Coppel":              [_CNBV_TDC],
    "D31 Control de Cheques":           [_CNBV_CHQ],
    "D32 Reports":                      [_MC_RULES, _VISA_RULES, _CNBV_TDC],
    "D33 Monitor de Cobranza":          [_CNBV_CARTERA],
    "D35 Digital":                      [_CNBV_DIGIT],
    "D36 Repaut":                       [_CNBV_SERIES],
    "D41 Corresponsalía":               [_CNBV_CORRESP],
    "D42 IVR":                          [_CNBV_IVR],
    "D43 Transferencias Presenciales":  [_BANXICO_SPEI],
    "D44 RECH":                         [_CNBV_CONCIL],
    "D46 OFI":                          [_CONDUSEF_COB, _CNBV_GEN],
    "D48 Riesgos":                      [_CNBV_RIESGO],
}


# ── Riesgos canónicos ──────────────────────────────────────────────────────────

_RIESGO_MONEY   = "MONEY — banker's rounding Informix; NUMERIC PostgreSQL diverge"
_RIESGO_ROUND   = "ROUND — validar modo (banker's vs half-up)"
_RIESGO_DIV     = "DIV — división monetaria puede perder centavos; usar DECIMAL(18,4)"
_RIESGO_IVA     = "IVA — cálculo 16% sobre base; verificar base imponible y redondeo"
_RIESGO_UDI     = "UDI — valor publicado diario Banxico; dependencia externa en target; cache necesario"
_RIESGO_DBACCESS = "DBACCESS — ejecución SQL externa vía shell; paths AIX (/ifxsif01/bin/, /resplogifx/) muertos en target AWS/PostgreSQL"
_RIESGO_AFORE   = "AFORE — rendimientos mínimos CONSAR calculados sobre saldo promedio SIEFORE; verificar tasa garantizada en target"
_RIESGO_FX      = "FX — conversión tipo de cambio FIX Banxico; dependencia externa en target; cache con fecha de vigencia"


# ── Helpers ────────────────────────────────────────────────────────────────────

def _has(text: str, *tokens: str) -> bool:
    t = text.lower()
    return any(tok.lower() in t for tok in tokens)


def _is_empty(val) -> bool:
    if val is None:
        return True
    if isinstance(val, list):
        return len(val) == 0
    return str(val).strip() in ("", "[]", "null", "None")


def _unique_refs(refs: list) -> list:
    seen = set()
    out = []
    for ref in refs:
        key = tuple(ref) if isinstance(ref, list) else ref
        if key not in seen:
            seen.add(key)
            out.append(ref)
    return out


# ── Pattern overrides por SP + code ───────────────────────────────────────────

def extra_reg(rule: dict) -> list:
    """
    Retorna referencias regulatorias adicionales basadas en patrones del SP y code.
    Se suman (no reemplazan) al default del dominio.
    """
    code = (rule.get("code") or "").lower()
    sp   = (rule.get("sp") or "").lower()
    dom  = (rule.get("dominio") or "")
    extra = []

    # AFORE / SAR patterns (D20 Programas principalmente)
    if _has(sp, "afore", "_sar", "sarnet"):
        extra.append(_CONSAR_SAR)
        if _has(code, "rendim", "monto_afore", "subcuenta"):
            extra.append(_CONSAR_SAR)  # reiterar contexto
        if _has(code, "imss", "patron", "obrero"):
            extra.append(_IMSS_SAR)

    # IVA patterns — cualquier dominio
    if re.search(r'\b(viva|miva|iva_cob|mivacob|iva)\b', code) or _has(sp, "iva"):
        extra.append(_SAT_IVA)

    # LISR / SAR deducibilidad
    if _has(code, "lisr", "deduccion_sar", "aportacion_voluntaria"):
        extra.append(_SAT_LISR)

    # UDI patterns (D41 Corresponsalía)
    if re.search(r'\b(udi|precio_udi|vmtopagosudi|valor_udi)\b', code):
        extra.append(_BANXICO_UDI)

    # FX / tipo de cambio (D36 Repaut, D28 Inversiones)
    if _has(code, "precio_dolar", "tipocambio", "tipo_cambio", "v_precio_dolar", "fix"):
        extra.append(_BANXICO_FX)

    # VISA specific
    if _has(sp, "visa") or _has(code, "rep20123", "reportevisa"):
        extra.append(_VISA_RULES)

    # MC specific
    if _has(sp, "mc_", "mastercard") or _has(code, "mastercard", "mc_cal", "mc_cie"):
        extra.append(_MC_RULES)

    # PLD / GAFI patterns (cualquier dominio)
    if _has(sp, "pld", "sitiosp", "lide", "lavado") or _has(code, "folio_pld", "alerta_pld"):
        extra.append(_CNBV_PLD)
        extra.append(_GAFI_REC10)

    # Auditoría / bitácoras (cualquier dominio)
    if _has(sp, "bitacora", "log_", "auditor") or _has(code, "bdiauditor", "/bitacora"):
        extra.append(_CNBV_ART78)

    # SPEI extra: transfers con clabe
    if _has(code, "clabe", "spei", "transferencia_inter") and "Transferencias" in dom:
        extra.append(_BANXICO_SPEI)

    return extra


# ── Inferencia de riesgo ───────────────────────────────────────────────────────

def infer_riesgo(rule: dict) -> list:
    tipo = rule.get("tipo") or ""
    if tipo not in ("FÓRMULA", "F\xd3RMULA", "FORMULA"):
        return []
    code     = (rule.get("code") or "")
    code_low = code.lower()
    sp       = (rule.get("sp") or "").lower()
    dom      = (rule.get("dominio") or "")
    tags = []

    # MONEY type
    if "::money" in code_low or re.search(r'\bmoney\b', code_low):
        tags.append(_RIESGO_MONEY)

    # ROUND / TRUNC
    if re.search(r'\b(round|trunc)\s*\(', code_low):
        tags.append(_RIESGO_ROUND)

    # División de variables monetarias
    if re.search(r'/\s*\(?\s*(vprecio|vmonto|vimporte|vsaldo|precio_udi|divisioncifra|precio_contable|precio_dolar)', code_low):
        tags.append(_RIESGO_DIV)

    # IVA multiplicación
    if re.search(r'\*\s*(viva|miva|v_iva|mivac)', code_low):
        tags.append(_RIESGO_IVA)

    # UDI
    if re.search(r'(precio_udi|valor_udi)', code_low):
        tags.append(_RIESGO_UDI)

    # FX / tipo de cambio
    if re.search(r'(precio_dolar|v_precio_dolar|tipocambio)', code_low):
        tags.append(_RIESGO_FX)

    # AFORE
    if _has(sp, "afore") and _has(code_low, "rendim", "tasa"):
        tags.append(_RIESGO_AFORE)

    # DBACCESS paths AIX
    if ("dbaccess" in code_low
            or "/ifxsif01/" in code
            or "/resplogifx/" in code
            or re.search(r"vsql\s*=|csql\s*=", code_low)):
        tags.append(_RIESGO_DBACCESS)

    # Dedup: MONEY implica ROUND risk; eliminar ROUND si ya hay MONEY
    if _RIESGO_MONEY in tags and _RIESGO_ROUND in tags:
        tags.remove(_RIESGO_ROUND)

    return list(dict.fromkeys(tags))  # dedup conservando orden


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    print("=" * 65)
    print("triaje-d17-d49.py — Anotación regulatoria D17-D49 v1.0")
    print("=" * 65)

    # Cargar v3.json
    v3_data  = json.loads(V3.read_text(encoding="utf-8"))
    v3_rules = v3_data["rules"]

    # Normalizar string-repr → lista real (artefactos de repr() antiguo)
    n_norm = 0
    for r in v3_rules:
        for field in ("reg", "riesgo"):
            val = r.get(field)
            if isinstance(val, str) and val.strip().startswith("["):
                try:
                    r[field] = ast.literal_eval(val)
                    n_norm += 1
                except (ValueError, SyntaxError):
                    pass
    if n_norm:
        print(f"  [normalize] {n_norm} campos string-repr convertidos a lista")

    # Filtrar D17-D49
    d17_plus = [r for r in v3_rules if str(r.get("dominio", "")) >= "D17"]
    print(f"\nReglas D17-D49 en v3.json: {len(d17_plus)}")

    # Identificar todos los dominios únicos para logging
    doms = sorted({r.get("dominio", "?") for r in d17_plus})
    print(f"Dominios: {len(doms)}")

    # Acumuladores
    stats: dict[str, dict] = {}
    reg_added = riesgo_added = 0

    for r in d17_plus:
        dom = r.get("dominio", "")
        if dom not in stats:
            stats[dom] = {"total": 0, "reg_added": 0, "riesgo_added": 0}
        stats[dom]["total"] += 1

        # ── reg ──────────────────────────────────────────────────────────
        if _is_empty(r.get("reg")):
            default = DOMAIN_DEFAULT.get(dom, [])
            extra   = extra_reg(r)
            new_refs = _unique_refs(default + extra)
            if new_refs:
                r["reg"] = new_refs
                stats[dom]["reg_added"] += 1
                reg_added += 1
        else:
            # Aunque ya tenga reg, añadir extra si aplica
            existing = r["reg"] if isinstance(r["reg"], list) else []
            extra = extra_reg(r)
            if extra:
                merged = _unique_refs(existing + extra)
                if len(merged) > len(existing):
                    r["reg"] = merged
                    stats[dom]["reg_added"] += 1
                    reg_added += 1

        # ── riesgo ───────────────────────────────────────────────────────
        if _is_empty(r.get("riesgo")):
            new_risk = infer_riesgo(r)
            if new_risk:
                r["riesgo"] = new_risk
                stats[dom]["riesgo_added"] += 1
                riesgo_added += 1

    # Guardar v3.json
    V3.write_text(json.dumps(v3_data, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"\n✓ v3.json actualizado")
    print(f"  reg_added    : {reg_added}")
    print(f"  riesgo_added : {riesgo_added}")

    # ── Sync brain.db ─────────────────────────────────────────────────────────
    print("\n── Sync brain.db ──────────────────────────────────────────────")
    conn = sqlite3.connect(DB)
    cur  = conn.cursor()

    db_reg_upd = db_riesgo_upd = 0
    for r in d17_plus:
        rid        = str(r.get("id", ""))
        new_reg    = r.get("reg", [])
        new_riesgo = r.get("riesgo", [])

        # Serializar como repr() para brain.db (consistente con pipeline)
        if isinstance(new_reg, list):
            new_reg_str = repr(new_reg)
        else:
            new_reg_str = str(new_reg) or "[]"

        if isinstance(new_riesgo, list):
            new_riesgo_str = repr(new_riesgo)
        else:
            new_riesgo_str = str(new_riesgo) or "[]"

        cur.execute(
            "UPDATE rules SET reg=?, riesgo=? WHERE id=?",
            (new_reg_str, new_riesgo_str, rid)
        )
        if cur.rowcount:
            if new_reg_str not in ("[]", ""):
                db_reg_upd += 1
            if new_riesgo_str not in ("[]", ""):
                db_riesgo_upd += 1

    conn.commit()

    # ── Cobertura post-triaje ─────────────────────────────────────────────────
    print("\n── Cobertura post-triaje (brain.db) ───────────────────────────")
    print(f"  {'Dominio':<38} {'Total':>5} {'Reg':>5} {'Reg%':>5} {'Riesgo':>6} {'Riesgo%':>7}")
    print(f"  {'─'*38} {'─'*5} {'─'*5} {'─'*5} {'─'*6} {'─'*7}")

    total_all = reg_all = riesgo_all = 0
    for dom in sorted(stats.keys()):
        n = cur.execute(
            "SELECT COUNT(*) FROM rules WHERE domain=?",
            (dom.split()[0],)   # "D20 Programas" → "D20"
        ).fetchone()[0]
        nr = cur.execute(
            "SELECT COUNT(*) FROM rules WHERE domain=? AND reg NOT IN ('[]','','None','null')",
            (dom.split()[0],)
        ).fetchone()[0]
        nri = cur.execute(
            "SELECT COUNT(*) FROM rules WHERE domain=? AND riesgo NOT IN ('[]','','None','null')",
            (dom.split()[0],)
        ).fetchone()[0]
        reg_pct    = f"{nr*100//n if n else 0}%"
        riesgo_pct = f"{nri*100//n if n else 0}%"
        print(f"  {dom:<38} {n:>5} {nr:>5} {reg_pct:>5} {nri:>6} {riesgo_pct:>7}")
        total_all  += n
        reg_all    += nr
        riesgo_all += nri

    print(f"  {'─'*38} {'─'*5} {'─'*5} {'─'*5} {'─'*6} {'─'*7}")
    total_reg_pct    = f"{reg_all*100//total_all if total_all else 0}%"
    total_riesgo_pct = f"{riesgo_all*100//total_all if total_all else 0}%"
    print(f"  {'TOTAL D17-D49':<38} {total_all:>5} {reg_all:>5} {total_reg_pct:>5} {riesgo_all:>6} {total_riesgo_pct:>7}")

    conn.close()
    print(f"\n  brain.db: {db_reg_upd} rows con reg | {db_riesgo_upd} rows con riesgo")
    print("\n✔  Triaje D17-D49 completado.")
    print(f"   Actualiza: {V3}")
    print(f"   Actualiza: {DB}")
    print()
    print("Siguiente paso: python generators/gen-rules-portal.py")
    print("                python digital-brain/build-brain.py  (si se quiere rebuild completo)")


if __name__ == "__main__":
    main()