#!/usr/bin/env python3
"""
Liverpool — Bronze Layer Rule Extractor  (Medallion Architecture)
----------------------------------------------------------------
Reads 12 ABAP programs from  source/Source Code SAP/
Detects rule types:  FÓRMULA · VALIDACIÓN · UMBRAL · ESTADO
Maps to retail domains:  R01-R10
Cross-references 155-term Liverpool vocabulary catalog
Output: portal/data/rules-bronze-liv.json

ADR-SPE-AM-010: business_name = ""  (LLM synthesis is the ONLY source)
"""
import re, json, os
from pathlib import Path
from datetime import date
from collections import Counter

# ── Paths ─────────────────────────────────────────────────────────────────────
HERE  = Path(__file__).parent
BRAIN = HERE.parent
SRC   = BRAIN / "source" / "Source Code SAP"
OUT   = BRAIN / "portal" / "data" / "rules-bronze-liv.json"
OUT.parent.mkdir(parents=True, exist_ok=True)

# ── Vocabulary cross-reference ────────────────────────────────────────────────
# Subset of 155-term catalog (build-vocab-catalog.py) used for vocab_refs tagging.
# Purpose: mark which vocabulary terms appear in each extracted rule.
VOCAB_TERMS = [
    # SISTEMA
    "SAP", "S/4HANA", "ECC", "Mainframe", "VPL", "Vision Plus", "SOMS",
    "Base24", "Sterling OMS", "IBM IIB", "IIB", "Apigee", "Tumbleweed",
    "Siebel", "PIM", "STEP", "ATG", "Endeca", "Bridgecore", "Control-D",
    "CDP", "SAP BW", "Cyberfinancial", "Card Wizard", "FICO TRIAD",
    "Oracle PL/SQL", "Gestor4PL", "commercetools",
    # PROCESO
    "importaciones", "pedimento", "reserva de pedido", "contabilización",
    "embarque", "incoterms", "agente aduanal", "despacho aduanal",
    "pago de proveedor", "solicitud de pago", "pedido de compra",
    "devolución", "Click & Collect", "fulfillment", "originación",
    "autorización", "cobranza", "facturación", "lealtad",
    "emisión de tarjeta", "disputa", "aclaración", "surtido", "allocation",
    # ABAP
    "ZIMFIC002", "ZIMPOB010B", "ZIMPOC001", "ZIMPOC002", "ZIMPOC003",
    "ZIMPOC005", "ZIMPOC007", "ZIMPOC023", "ZIMPOC024", "ZRTPOC079",
    "ZRTPOC079N", "ZRT_PO_REP_EPI_BD", "ZIM_RVPO", "ZIM_CNST", "ZIM_LICH",
    "ZZSTATUS_MI", "ZIM_EMLG", "ZTASA",
    # SEÑAL
    "96.69%", "pendientes", "MACH", "brownfield", "greenfield",
    "multi-sociedad", "N5 automation", "pedimento 16 dígitos",
    # DOMINIO
    "R01", "R02", "R03", "R04", "R05", "R06", "R07", "R08", "R09", "R10",
    "gestión comercial", "servicios financieros", "cadena de suministro",
    "canales digitales", "operaciones de tienda", "finanzas y contabilidad",
    # VENDOR
    "FIS Global", "ACI Worldwide", "Oracle", "IBM", "Google", "Broadcom",
    "FICO", "Stibo Systems",
    # 7R
    "Repurchase", "Replatform", "Refactor", "Rehost", "Retain", "Retire",
    "Encapsulate", "API-fy",
    # MODULO
    "FI/CO", "MM/PUR", "MM/MAT", "LE/SHP", "SD", "SRM", "F&R", "HCM",
    "EWM", "PDM", "PDTA",
    # ENTIDAD
    "LiverpoolCard", "Suburbia", "Liverpool", "Sfera", "SBB", "LIV",
    # ARQUITECTURA
    "API-first", "cloud-native", "headless", "composable", "GCP",
    # REG
    "SAT", "Banxico", "CONDUSEF", "Buró de Crédito", "PCI-DSS", "BMV",
    "Ley Aduanera", "LIVA", "LISR", "IMSS",
]

# Build sorted list by length descending for regex priority
VOCAB_SORTED = sorted(VOCAB_TERMS, key=len, reverse=True)

def detect_vocab_refs(code_lower: str) -> list[str]:
    refs = []
    seen = set()
    for t in VOCAB_SORTED:
        tl = t.lower()
        if len(tl) < 3:
            continue
        if tl not in seen and re.search(r"\b" + re.escape(tl) + r"\b", code_lower):
            refs.append(t)
            seen.add(tl)
        if len(refs) >= 10:
            break
    return refs


# ── Domain mapping ────────────────────────────────────────────────────────────
# 12 ABAP programs → retail domain (confirmed from dt-proceso-importaciones-sap)
PROG_DOMAIN: dict[str, tuple[str, str]] = {
    "ZIMFIC002":        ("R07", "Finanzas y Contabilidad"),
    "ZIMPOB010B":       ("R04", "Cadena de Suministro y Logística"),
    "ZIMPOC001":        ("R04", "Cadena de Suministro y Logística"),
    "ZIMPOC002":        ("R01", "Gestión Comercial"),
    "ZIMPOC003":        ("R01", "Gestión Comercial"),
    "ZIMPOC005":        ("R04", "Cadena de Suministro y Logística"),
    "ZIMPOC007":        ("R04", "Cadena de Suministro y Logística"),
    "ZIMPOC023":        ("R04", "Cadena de Suministro y Logística"),
    "ZIMPOC024":        ("R04", "Cadena de Suministro y Logística"),
    "ZRTPOC079":        ("R04", "Cadena de Suministro y Logística"),
    "ZRTPOC079N":       ("R04", "Cadena de Suministro y Logística"),
    "ZRT_PO_REP_EPI_BD": ("R07", "Finanzas y Contabilidad"),
}


# ── Regulatory signals for Liverpool ─────────────────────────────────────────
REG_RULES: list[tuple[str, str, str]] = [
    # SAT / Aduana
    (r"\bpedimento\b|zzpedi|pedi_no|pedimen\w*",
     "SAT",
     "Ley Aduanera Art.36 — pedimento de importación; campo 14→16 dígitos (oct-2025)"),
    (r"\barancel\b|ztasa\b|tasa.*arancel|arancel.*tasa|arancel.*import|derecho.*aduan",
     "SAT",
     "Ley Aduanera / UMC — aranceles ad valorem; tabla ZTASA* fuente de tasas"),
    (r"\biva\b|impuesto.*valor.agr|liva\b",
     "SAT",
     "LIVA — IVA aplicable a importaciones (tasa 16%); validación en pedimento"),
    (r"\bisr\b|impuesto.*renta|lisr\b",
     "SAT",
     "LISR Art.90+ — ISR sobre pagos a proveedores extranjeros en importaciones"),
    (r"\bcfdi\b|factura.*electronica|folio.*fiscal|xml.*sat",
     "SAT",
     "SAT — CFDI obligatorio en pagos a proveedores de importación"),
    (r"\bagente.*aduanal\b|aduanal\b|zim_agad",
     "SAT",
     "Ley Aduanera Art.40 — intervención de agente aduanal obligatoria"),
    (r"\bincoterms?\b|konv.*inco|zim_lich",
     "SAT",
     "Reglas Incoterms ICC — base de valoración en aduana (CIF/FOB)"),
    (r"\bduty.free\b|libre.*impuesto|exento",
     "SAT",
     "Ley Aduanera — régimen de importación temporal / duty free"),
    # Banxico
    (r"\btipo.*cambio\b|tipocambio\b|kursf\b|ukurs\b|wmobj\b|tcurr\b",
     "Banxico",
     "Banxico — tipo de cambio FIX; liquidación de obligaciones en moneda extranjera"),
    # BMV (empresa pública)
    (r"\bbkpf\b|\bbseg\b|contabilizac|asiento.*contable|doc.*contable|bukrs\b",
     "BMV",
     "LMV — empresa pública LIVEPOLC; trazabilidad contable obligatoria"),
    # CONDUSEF / crédito consumo
    (r"\bliverpoolcard\b|tarjeta.*liverpool|credito.*consumo|tasa.*interes|comision\b",
     "CONDUSEF",
     "LTOSF — comisiones y tasas de crédito al consumo (LiverpoolCard)"),
    # IMSS
    (r"\bnomina\b|\bimss\b|\bsua\b|\bpatron\w+\b",
     "IMSS",
     "IMSS — obligaciones patronales en nómina de operaciones logísticas"),
]


def clasifica(code_lower: str) -> list[list[str]]:
    """Return list of [reg_body, norma] for regulatory matches."""
    hits, seen = [], set()
    for pat, reg, norma in REG_RULES:
        if re.search(pat, code_lower) and reg not in seen:
            hits.append([reg, norma])
            seen.add(reg)
    return hits


# ── Equivalence risk signals (ABAP-specific) ─────────────────────────────────
def riesgo_abap(expr: str) -> list[str]:
    r = []
    e = expr.lower()
    if re.search(r"/\s*100\b", expr):
        r.append("DIV 100 — verificar modo de redondeo en conversión de porcentaje")
    if re.search(r"/\s*365\b", expr):
        r.append("base 365 — verificar vs base 360 en cálculos de interés")
    if re.search(r"/\s*360\b", expr):
        r.append("base 360 — verificar vs base 365")
    if re.search(r"\bkursf\b|\bukurs\b|\btcurr\b", e):
        r.append("tipo de cambio en variable — verificar fuente FIX Banxico vs SAP TCURR")
    if re.search(r"\bconv_exit\b|conversion_exit", e):
        r.append("CONV_EXIT — salida de conversión SAP; comportamiento puede cambiar en S/4HANA")
    if re.search(r"\bcall\s+function\b", e):
        r.append("CALL FUNCTION — FM SAP; disponibilidad y firma pueden cambiar en S/4HANA")
    if re.search(r"\bnetwr\b|\bbrtwr\b|\bbetrw\b|\bwrbtr\b|\bdmbtr\b", e):
        r.append("valor monetario SAP (NET/GROSS) — verificar alineación con valor en aduana")
    if re.search(r"\btrunc\b|\bfloor\b|\bceil\b", e):
        r.append("truncado — verificar pérdida de centavos en operaciones monetarias")
    return r


# ── Categoria assignment ──────────────────────────────────────────────────────
_DOM_CAT: dict[str, str] = {
    "R01": "GESTION_COMERCIAL",
    "R02": "CLIENTES_LEALTAD",
    "R03": "SERVICIOS_FINANCIEROS",
    "R04": "CADENA_SUMINISTRO",
    "R05": "CANALES_DIGITALES",
    "R06": "OPERACIONES_TIENDA",
    "R07": "FINANZAS_CONTABILIDAD",
    "R08": "RRHH",
    "R09": "ANALITICA",
    "R10": "INFRAESTRUCTURA",
}


def asigna_categoria(dom_code: str, tipo: str, regs: list) -> str:
    if regs:
        return "REGULATORIO"
    if tipo == "FÓRMULA":
        return "CALCULO_NEGOCIO"
    return _DOM_CAT.get(dom_code, "OPERACIONAL")


# ── ABAP extraction patterns ──────────────────────────────────────────────────
# Financial field names common in Liverpool ABAP (SAP standard + Z-custom)
_FIN_TERMS = [
    # SAP standard monetary/quantity fields
    "betrw", "dmbtr", "wrbtr", "menge", "netwr", "brtwr", "kzskl",
    "zollt", "zollg", "navna", "erfmg", "lsmng", "lsmeh",
    # Z-custom Liverpool fields (ZIM_RVPO, ZIM_LIPG, etc.)
    "zzimimp", "zzimiva", "zzimfle", "zzimgas", "zzimant", "zzimtot",
    "zzmoneda", "zzimporte", "zzvalor", "zzimusd", "zzimcosto",
    "zzsolpg", "zzstspg", "zzfstcd", "zzfscdf", "zzfstem",
    # SAP currency/exchange fields
    "kursf", "ukurs", "waers", "budat", "bldat",
    # Spanish financial terms
    "iva", "isr", "impuesto", "tasa", "arancel", "pedimento",
    "monto", "importe", "valor", "costo", "precio", "flete",
    "seguro", "anticipo", "pago", "factura", "descuento", "cargo",
    "interes", "mora", "comision", "retencion", "deduccion", "provision",
    "tipo_cambio", "tipo cambio", "cantidad", "dias", "plazo",
    # Thresholds commonly found in importaciones ABAP
    "dias_libre", "dias_embarq", "dias_arribo", "dias_plaza",
]
_FIN_PAT = "(" + "|".join(re.escape(t) for t in sorted(_FIN_TERMS, key=len, reverse=True)) + ")"

# UMBRAL — more lenient: any IF with numeric comparison ≥ 10, even without strict FIN_PAT
# (many ABAP thresholds use SAP field names not in FIN list)
RE_UMBRAL_STRICT = re.compile(
    r"^\s*if\b.{0,120}" + _FIN_PAT +
    r".{0,60}(?:>|<|>=|<=|\bgt\b|\blt\b|\bge\b|\ble\b)\s*(\d{2,}(?:[.,]\d+)?)\b",
    re.I,
)
RE_UMBRAL_LOOSE = re.compile(
    r"^\s*if\b.{0,100}"
    r"(?:[a-z_][a-z0-9_\-]*(?:\-[a-z_][a-z0-9_]*)?)"
    r"\s*(?:>|<|>=|<=|\bgt\b|\blt\b|\bge\b|\ble\b)\s*(\d{2,}(?:[.,]\d+)?)\b",
    re.I,
)

# FÓRMULA — assignment with arithmetic and financial term
RE_FORMULA = re.compile(
    r"^\s*([a-z_][a-z0-9_\-<>]*)\s*=\s*(.+[*/+\-].+)",
    re.I,
)
RE_COMPUTE = re.compile(
    r"^\s*compute\s+([a-z_][a-z0-9_\-<>]*)\s*=\s*(.+)",
    re.I,
)
RE_ADD_SUB = re.compile(
    r"^\s*(add|subtract|multiply|divide)\s+(.+?)\s+(to|from|by|into)\s+(.+)",
    re.I,
)

# VALIDACIÓN — errors, checks, SY-SUBRC
RE_RAISE = re.compile(
    r"raise\s+exception\s+type\s+\w+"
    r"|message\s+[ew]\d{3,}"
    r"|message\s+id\s+\S+\s+type\s+'[ew]'"
    r"|sy-subrc\s*(ne|<>)\s*0"
    r"|\bif\s+sy-subrc\s*(ne|<>|eq|=)\s*0",
    re.I,
)
RE_CHECK = re.compile(
    r"^\s*check\s+.{4,}(?:initial|bound|space|negative|positive|not\b)",
    re.I,
)

# ESTADO — state machine / status field checks
RE_ESTADO = re.compile(
    r"^\s*(?:if|elseif|when)\b.{0,100}"
    r"\b(zzstatus_mi|zzstspg|zzsolpg|ekgrp|matkl|mtart|bstyp|bukrs|waers|"
    r"lifnr|flag|indicator|zall|zautoa|estatus|status|werks|land1|inco1)\b"
    r".{0,60}(?:=\s*'[A-Z0-9_]{1,6}'|\s+eq\s+'[A-Z0-9_]{1,6}'"
    r"|\s+in\s+\(|\s+between\b)",
    re.I,
)

# Boilerplate skips (avoid trivial lines)
RE_BOILER = re.compile(
    r"^\s*(?:sy-subrc\s*=\s*0\s*\.\s*$"
    r"|clear\s|refresh\s|free\s|move\s|write\s|format\s|skip\s"
    r"|uline|new-line|top-of-page|end-of-page"
    r"|perform\s|call\s+screen\s|set\s+pf-status|set\s+titlebar"
    r"|include\s|report\s|tables\b|data:\s*begin\s"
    r"|create\s+object\s|type-pools\s)",
    re.I,
)

# Pre-filter keywords (binary scan)
PRE_FILTER = [
    b"if ", b"check ", b"raise exception", b"message e", b"message w",
    b"compute ", b"add ", b"subtract ", b"multiply ", b"divide ",
    b"pedimento", b"arancel", b"iva", b"isr", b"tasa", b"monto", b"importe",
    b"ztasa", b"zim_", b"netwr", b"betrw", b"wrbtr", b"dmbtr",
    b"sy-subrc", b"is initial", b"zzstatus_mi",
]


def is_comment(line: str) -> bool:
    s = line.strip()
    return not s or s.startswith("*") or s.startswith('"')


def norm(e: str) -> str:
    return re.sub(r"\s+", " ", e).strip().rstrip(".").rstrip()[:220]


# ── Locate source files ───────────────────────────────────────────────────────
source_files = sorted(
    [f for f in SRC.iterdir()
     if f.is_file() and f.suffix == "" and f.name.upper() in PROG_DOMAIN],
    key=lambda f: f.name,
)
print(f"  Programas ABAP encontrados: {len(source_files)}")
for f in source_files:
    print(f"    {f.name}")

# ── Extraction main loop ──────────────────────────────────────────────────────
rules: list[dict] = []
seq = 0
seen_f: set = set()
seen_v: set = set()
seen_u: set = set()
seen_e: set = set()
n_scanned = n_pre = 0

for fp in source_files:
    prog = fp.name.upper()
    dom_code, dom_label = PROG_DOMAIN[prog]

    # Binary pre-filter
    try:
        raw = fp.read_bytes()[:32768].lower()
        if not any(kw in raw for kw in PRE_FILTER):
            n_pre += 1
            continue
    except Exception:
        continue

    n_scanned += 1
    try:
        txt = fp.read_text(encoding="latin-1", errors="replace")
    except Exception:
        continue

    v_val = 0   # cap validations per program

    for lineno, rawln in enumerate(txt.split("\n"), 1):
        if is_comment(rawln):
            continue
        s  = rawln.rstrip()
        if not s.strip():
            continue
        sl = s.lower()

        if RE_BOILER.match(s):
            continue

        # ── FÓRMULA ──────────────────────────────────────────────────────────
        for pat in (RE_FORMULA, RE_COMPUTE):
            m = pat.match(s)
            if not m:
                continue
            lhs = m.group(1)
            rhs = m.group(2).strip()
            # require arithmetic + financial term + not a string literal
            if (re.search(r"[*/+\-]", rhs)
                    and re.search(_FIN_PAT, s, re.I)
                    and not rhs.startswith(("'", '"', "space", "initial"))
                    and len(rhs) > 4):
                expr = norm(f"{lhs} = {rhs}")
                key  = (prog, re.sub(r"\d+", "#", expr[:90]))
                if key not in seen_f:
                    seen_f.add(key)
                    regs = clasifica(sl)
                    vr   = detect_vocab_refs(sl)
                    seq += 1
                    rules.append({
                        "id":            f"BR-LIV-{seq:06d}",
                        "tipo":          "FÓRMULA",
                        "prog":          prog,
                        "line":          lineno,
                        "code":          expr,
                        "reg":           regs,
                        "riesgo":        riesgo_abap(s),
                        "vocab_refs":    vr,
                        "dominio":       dom_label,
                        "dom_code":      dom_code,
                        "categoria":     asigna_categoria(dom_code, "FÓRMULA", regs),
                        "business_name": "",
                        "clase":         "",
                    })
            break  # tried both patterns

        # ADD/SUBTRACT/MULTIPLY/DIVIDE with financial term
        ma = RE_ADD_SUB.match(s)
        if ma and re.search(_FIN_PAT, s, re.I):
            expr = norm(s)
            key  = (prog, re.sub(r"\d+", "#", expr[:90]))
            if key not in seen_f:
                seen_f.add(key)
                regs = clasifica(sl)
                vr   = detect_vocab_refs(sl)
                seq += 1
                rules.append({
                    "id":            f"BR-LIV-{seq:06d}",
                    "tipo":          "FÓRMULA",
                    "prog":          prog,
                    "line":          lineno,
                    "code":          expr,
                    "reg":           regs,
                    "riesgo":        riesgo_abap(s),
                    "vocab_refs":    vr,
                    "dominio":       dom_label,
                    "dom_code":      dom_code,
                    "categoria":     asigna_categoria(dom_code, "FÓRMULA", regs),
                    "business_name": "",
                    "clase":         "",
                })

        # ── VALIDACIÓN ───────────────────────────────────────────────────────
        if (RE_RAISE.search(s) or RE_CHECK.match(s)) and v_val < 10:
            key = (prog, re.sub(r"\d+", "#", s.strip()[:80]))
            if key not in seen_v:
                seen_v.add(key)
                code = norm(s)
                regs = clasifica(sl)
                vr   = detect_vocab_refs(sl)
                seq += 1; v_val += 1
                rules.append({
                    "id":            f"BR-LIV-{seq:06d}",
                    "tipo":          "VALIDACIÓN",
                    "prog":          prog,
                    "line":          lineno,
                    "code":          code,
                    "reg":           regs,
                    "riesgo":        riesgo_abap(s),
                    "vocab_refs":    vr,
                    "dominio":       dom_label,
                    "dom_code":      dom_code,
                    "categoria":     asigna_categoria(dom_code, "VALIDACIÓN", regs),
                    "business_name": "",
                    "clase":         "",
                })

        # ── UMBRAL ───────────────────────────────────────────────────────────
        mu = RE_UMBRAL_STRICT.match(s) or RE_UMBRAL_LOOSE.match(s)
        if mu:
            expr = norm(s)
            key  = (prog, re.sub(r"\d+", "#", expr[:90]))
            if key not in seen_u:
                seen_u.add(key)
                regs = clasifica(sl)
                vr   = detect_vocab_refs(sl)
                seq += 1
                rules.append({
                    "id":            f"BR-LIV-{seq:06d}",
                    "tipo":          "UMBRAL",
                    "prog":          prog,
                    "line":          lineno,
                    "code":          expr,
                    "reg":           regs,
                    "riesgo":        riesgo_abap(s),
                    "vocab_refs":    vr,
                    "dominio":       dom_label,
                    "dom_code":      dom_code,
                    "categoria":     asigna_categoria(dom_code, "UMBRAL", regs),
                    "business_name": "",
                    "clase":         "",
                })

        # ── ESTADO ───────────────────────────────────────────────────────────
        me = RE_ESTADO.match(s)
        if me:
            expr = norm(s)
            key  = (prog, expr[:90])
            if key not in seen_e:
                seen_e.add(key)
                regs = clasifica(sl)
                vr   = detect_vocab_refs(sl)
                seq += 1
                rules.append({
                    "id":            f"BR-LIV-{seq:06d}",
                    "tipo":          "ESTADO",
                    "prog":          prog,
                    "line":          lineno,
                    "code":          expr,
                    "reg":           regs,
                    "riesgo":        [],
                    "vocab_refs":    vr,
                    "dominio":       dom_label,
                    "dom_code":      dom_code,
                    "categoria":     asigna_categoria(dom_code, "ESTADO", regs),
                    "business_name": "",
                    "clase":         "",
                })

# ── Statistics ────────────────────────────────────────────────────────────────
by_tipo  = Counter(r["tipo"]     for r in rules)
by_dom   = Counter(r["dom_code"] for r in rules)
by_prog  = Counter(r["prog"]     for r in rules)
by_cat   = Counter(r["categoria"] for r in rules)
n_reg    = sum(1 for r in rules if r["reg"])
n_riesgo = sum(1 for r in rules if r["riesgo"])
n_vocab  = sum(1 for r in rules if r["vocab_refs"])

print(f"\n  Escaneados  : {n_scanned}  |  Pre-filtro descartó: {n_pre}")
print(f"  Reglas Bronze extraídas: {len(rules)}")
for t in ("FÓRMULA", "VALIDACIÓN", "UMBRAL", "ESTADO"):
    print(f"    {t:<12}: {by_tipo.get(t, 0)}")
print(f"  Con reg     : {n_reg}")
print(f"  Con riesgo  : {n_riesgo}")
print(f"  Con vocab   : {n_vocab}")
print(f"\n  Por programa:")
for prog, cnt in sorted(by_prog.items()):
    print(f"    {prog:<26}: {cnt}")
print(f"\n  Por dominio:")
for dom, cnt in sorted(by_dom.items()):
    lbl = next((v for k, v in PROG_DOMAIN.values() if k == dom), dom)
    print(f"    {dom}: {cnt}")

# ── Output JSON ───────────────────────────────────────────────────────────────
payload = {
    "meta": {
        "version":       "bronze-liv-1.0",
        "layer":         "bronze",
        "generated":     str(date.today()),
        "tool":          "generators/extract-rules.py",
        "source":        "source/Source Code SAP  (12 ABAP programs — Módulo Importaciones)",
        "prog_scanned":  n_scanned,
        "prog_skipped":  n_pre,
        "total":         len(rules),
        "by_tipo": {t: by_tipo.get(t, 0)
                    for t in ("FÓRMULA", "VALIDACIÓN", "UMBRAL", "ESTADO")},
        "by_dom":  dict(by_dom.most_common()),
        "reg_pct": round(n_reg * 100 / len(rules), 1) if rules else 0,
    },
    "rules": rules,
    "stats": {
        "tipo":      dict(by_tipo),
        "dominio":   dict(by_dom),
        "programa":  dict(by_prog),
        "categoria": dict(by_cat),
    },
}

OUT.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
print(f"\n  Output -> {OUT}")
print("  Done.")
