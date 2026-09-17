#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
extract-rules.py — Bronze Layer: Extracción unificada D01-D49.

Medallion Architecture:
  Bronze (extract-rules.py → rules-bronze.json)
    → Silver (enrich-rules.py → business-rules-v3.json)
      → Gold  (build-brain.py --reset → brain.db)

Consolida extract-rules-v2.py (D01-D16) y extract-rules-d17-d49.py (D17-D49)
en un solo pipeline con cobertura completa de los 49 dominios Informix BanCoppel
(~12,812 SPs, ~11,391 con contenido relevante).

Output: portal/data/rules-bronze.json
  {"meta": {...}, "rules": [{id, tipo, sp, db, line, code, reg, riesgo,
                               bc, bc_name, vocab_refs, dominio, dom_code,
                               categoria, business_name, clase}], "stats": {...}}

Nota ADR-SPE-AM-010: business_name="" siempre — la síntesis LLM es la única
fuente del campo (se aplica post-extracción sobre brain.db).

SPE-AM-001 · Specialist Informix SPL · 2026-08-25
"""
import json, re, os, sys
from pathlib import Path
from collections import Counter
from datetime import date

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE     = Path(__file__).resolve().parent.parent
SRC      = BASE / "source" / "Informix"
OUT      = BASE / "portal" / "data" / "rules-bronze.json"
VOCAB_F  = BASE / "knowledge-base" / "vocabulary-inventory.json"

# ── Vocabulario certificado ────────────────────────────────────────────────────
print("Cargando vocabulario...")
inv = json.loads(VOCAB_F.read_text(encoding="utf-8"))
VOCAB = {}
for section in ("atomos", "compuestos"):
    for item in inv.get(section, []):
        VOCAB[item["term"]] = item

FIN_FROM_VOCAB = sorted(
    {t for t, v in VOCAB.items()
     if v.get("cat") in ("ENTIDAD", "METRICA")
     and v.get("nivel") in ("ALTA", "MEDIA")
     and len(t) >= 4},
    key=len, reverse=True)

BC_TERMS = {}
for t, v in VOCAB.items():
    bc = v.get("bc", "") or ""
    if bc and bc not in ("—", "-"):
        BC_TERMS[t] = (bc, v.get("bc_name", ""))

VOCAB_SET = set(VOCAB.keys())
print(f"  Vocabulario: {len(VOCAB_SET)} términos · BC_TERMS: {len(BC_TERMS)}")


def detect_vocab_refs(code_lower):
    found = []
    for t in VOCAB_SET:
        if len(t) >= 4 and re.search(r"\b" + re.escape(t) + r"\b", code_lower):
            found.append(t)
    return found[:8]


def tag_bc(vocab_refs):
    for t in vocab_refs:
        if t in BC_TERMS:
            return BC_TERMS[t]
    return ("", "")


# ── Mapa dominios D01-D49 (49 bases de datos) ─────────────────────────────────
DOMN = {
    # D01-D16
    "bdicnweb":      "D01 Canal Digital Web",
    "bdinteg":       "D02 Integración y Auth",
    "bdicred":       "D03 Créditos",
    "bdicheq":       "D04 Cheques / Cuentas",
    "bdisac":        "D05 Saldos y Cuentas",
    "bdisolic":      "D06 Solicitudes",
    "bdiaclaracion": "D07 Aclaraciones",
    "bdispei":       "D08 SPEI",
    "bdimnsj":       "D09 Mensajería",
    "bdisuc":        "D10 Sucursales",
    "bdicobranza":   "D11 Cobranza",
    "bdicont":       "D12 Contabilidad",
    "bditef":        "D13 TEF",
    "bdibei":        "D14 BEI",
    "bdilide":       "D15 LIDE / PLD",
    "intercard":     "D16 Tarjetas",
    # D17-D49
    "bdibpi":        "D17 BPI",
    "intercardbpi":  "D18 Intercard BPI",
    "bditarjeta":    "D19 Tarjetas",
    "bdiprog":       "D20 Programas",
    "bdidomi":       "D21 Domiciliación",
    "bditransfer":   "D22 Transferencias",
    "bdmis":         "D23 MIS Sucursales",
    "bdiburo":       "D24 Buró de Crédito",
    "bdisitesp":     "D25 Sitio Especial",
    "bdiprospectos": "D26 Prospectos",
    "bdiauditor":    "D27 Auditoría",
    "bdinvers":      "D28 Inversiones",
    "bdiedoelec":    "D29 Estados de Cuenta Electrónicos",
    "bditarjcop":    "D30 Tarjetas Coppel",
    "bdicntchq":     "D31 Control de Cheques",
    "bdireports":    "D32 Reportes Visa/MC",
    "bdimonitorcob": "D33 Monitor de Cobranza",
    "bdiresp":       "D34 RESP",
    "bdidigital":    "D35 Digitalización",
    "bdirepaut":     "D36 Reportería CNBV",
    "bdiadminnomina":"D37 Administración Nómina",
    "bdicplbot":     "D38 CPL Bot",
    "bdiservicios":  "D39 Servicios",
    "bdibi":         "D40 BI",
    "bdicorresp":    "D41 Corresponsalía",
    "bdivr":         "D42 IVR",
    "bditrapres":    "D43 Transferencias Presenciales",
    "bdirech":       "D44 Conciliación Operativa",
    "bdiprem":       "D45 PREM",
    "bdiofi":        "D46 Oficinas de Cobro",
    "bdigaran":      "D47 Garantías",
    "bdiriesgos":    "D48 Riesgos de Crédito",
    "bdirst":        "D49 RST",
}

DOMN_CODE = {db: lbl.split()[0] for db, lbl in DOMN.items()}
D01_D16   = {db for db in DOMN if int(DOMN[db].split()[0][1:]) <= 16}

# ── Categorías D17-D49 por código de dominio ──────────────────────────────────
CAT_DOM = {
    "D17": "OPERACIONAL",          "D18": "TARJETAS",
    "D19": "TARJETAS",             "D20": "OPERACIONAL",
    "D21": "PAGOS_TRANSFERENCIAS", "D22": "PAGOS_TRANSFERENCIAS",
    "D23": "REPORTERIA",           "D24": "RIESGO_CREDITO",
    "D25": "OPERACIONAL",          "D26": "RIESGO_CREDITO",
    "D27": "OPERACIONAL",          "D28": "CALCULO_FINANCIERO",
    "D29": "ATENCION_CLIENTE",     "D30": "TARJETAS",
    "D31": "PAGOS_TRANSFERENCIAS", "D32": "REPORTERIA",
    "D33": "COBRANZA",             "D34": "OPERACIONAL",
    "D35": "OPERACIONAL",          "D36": "REGULATORIO",
    "D37": "OPERACIONAL",          "D38": "OPERACIONAL",
    "D39": "OPERACIONAL",          "D40": "REPORTERIA",
    "D41": "OPERACIONAL",          "D42": "ATENCION_CLIENTE",
    "D43": "PAGOS_TRANSFERENCIAS", "D44": "OPERACIONAL",
    "D45": "OPERACIONAL",          "D46": "OPERACIONAL",
    "D47": "RIESGO_CREDITO",       "D48": "REGULATORIO",
    "D49": "OPERACIONAL",
}

# ── Clasificación regulatoria (unión D01-D16 + D17-D49) ───────────────────────
REG_RULES = [
    # SAT
    (r"\bisr\b|imp_isr|tasa_isr|calc_isr",
     "SAT", "LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual)"),
    (r"\biva\b|imp_iva|ivas\b|miva",
     "SAT", "LIVA — IVA sobre comisiones (16% / 8% frontera)"),
    (r"\bgdf\b|sp_bitacoragdf|cfdi|retenciones|folio_fiscal|nomina.*cfdi",
     "SAT", "CFDI/Retenciones bancarias — folio fiscal por transacción de pago de servicios (SAT)"),
    # CONDUSEF
    (r"comis|comicob|cobracom|comi_",
     "CONDUSEF", "LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF"),
    (r"\bcat\b|costo_anual",
     "CONDUSEF", "LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente)"),
    (r"\bgat\b|ganancia_anual",
     "CONDUSEF", "LTOSF — Ganancia Anual Total (nominal/real)"),
    (r"sp_sac_|aclaracion|disputa|remisac|queja|reclam|sp_genreporbenefrem",
     "CONDUSEF", "RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario"),
    # CNBV
    (r"interes|calc_int|tasa|rendim|pagare|inversion|invers",
     "CNBV", "Criterios contables CNBV + GAT — cálculo de intereses/rendimientos"),
    (r"sp_cont_|gl_saldos|gl_movimientos|gl_asientos|cat_cuentas|co_sdodias",
     "CNBV", "CUB Anexo 33-34 — Plan de cuentas mínimo; cuadre DEBE = HABER a centavo"),
    (r"cierre_diario|serie_r|sp_genera_serie_r|sp_cont_conssaldosdiariosb4",
     "CNBV", "CUB Anexo 36 — Serie R; reportes mensuales R01-A/B R04-A/B R12 R22 R24"),
    (r"bitacora|_movhis|sd_movhis|log_|_his\b|auditor|logifx",
     "CNBV", "Art.78 LIC — conservación de información 5 años (bitácoras y movimientos)"),
    (r"reserva|castigo|cartera_vencida|estimacion_preventiva|pi_\w|sxp\b",
     "CNBV", "CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Severidad × Exposición"),
    (r"sp_bts_|_bts\b|grabapagocoppel|sac_controlconvenios",
     "CNBV", "CUB Art.310-315 — Corresponsalía BTS; validación convenio activo + folio único"),
    (r"art_?61|inactiv|beneficencia",
     "CNBV", "Art.61 LIC — cuentas inactivas → prescripción a beneficencia pública"),
    (r"buro|califica|consultaburo|burofisic|scoring",
     "CNBV", "LRSIC — Buró de Crédito; evaluación crediticia"),
    (r"mora|vencid",
     "CNBV", "CUB CNBV — calificación cartera vencida y constitución de reservas"),
    (r"tarjeta|_tc_|_td_|personaliza|emboza|plastico",
     "CNBV", "Disposiciones Únicas de Bancos — tarjetas de crédito y débito (Capítulo XI CUB)"),
    (r"garan|colateral|prenda",
     "CNBV", "Disposiciones Únicas de Bancos — garantías en operaciones de crédito (Circular B-6)"),
    (r"riesgo|var\b|exposicion|perdida_esperada",
     "CNBV", "CUB Circular B-5 — gestión integral de riesgos (crédito, mercado, operativo)"),
    (r"\bclabe\b|cuenta_clabe",
     "Banxico", "Circular Banxico — formato CLABE 18 dígitos (validación algoritmo módulo-10)"),
    # Banxico
    (r"spei_|clave_rastreo|cve_rastreo|transfer|domi_|domicil",
     "Banxico", "SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA < 20 s"),
    (r"spei_recextemporanea|spei_apgbanope|sp_actbancont",
     "Banxico", "SPEI — confirmación bancos operadores; extemporáneo > 17:30"),
    (r"\bcodi\b|spei_devcodi|spei_recerrorescodi",
     "Banxico", "Reglas CoDi — Cobro Digital Banxico; devolución y errores CoDi"),
    (r"appriza|sp_app_confirmpayment|sp_actualiza_cte_remesa",
     "Banxico", "Circular 14/2017 — Notificación fallos remesas; max_retries 3; plazo ≤ 2 días hábiles"),
    # IPAB
    (r"cuota.*ipab|ipab|4.?al.?millar|saldo_asegurado|lraf\b|captacion_tradicional",
     "IPAB", "LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiqueta LRAF"),
    # TESOFE
    (r"tesofe|pago_gobierno|concentracion\b",
     "TESOFE", "LTF — concentración/dispersión fondos gobierno; conciliación diaria folio GDF"),
    (r"dispersion|pension|beca",
     "TESOFE", "LTF — dispersión de recursos federales (pensiones, becas, apoyos)"),
    # IMSS (D17+)
    (r"nomina|imss|sua\b|patronal",
     "IMSS", "IMSS/SAT — obligaciones de nómina, CFDI nómina y SUA"),
]


def clasifica(text):
    hits, seen = [], set()
    low = text.lower()
    for pat, reg, norma in REG_RULES:
        if re.search(pat, low) and reg not in seen:
            hits.append([reg, norma])
            seen.add(reg)
    return hits


# ── Riesgos de equivalencia (superset D01-D49) ────────────────────────────────
def riesgo_equiv(expr, full_line=""):
    r = []
    e = expr.lower()
    fl = full_line.lower()
    if re.search(r"/\s*360\b", expr):
        r.append("base 360 (año comercial) — verificar vs 365")
    if re.search(r"/\s*365\b", expr):
        r.append("base 365 — verificar vs 360")
    if re.search(r"/\s*30\b", expr):
        r.append("base 30 días/mes — verificar cálculo calendario")
    if re.search(r"/\s*v?_?(anio|anno|year|base_?anio|aniobase|dias_?anio|ndias_?anio)", e):
        r.append("base de año en variable — verificar 360 vs 365 (divergencia de intereses)")
    if "trunc" in e:
        r.append("TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos)")
    if re.search(r"\bround\b", e):
        r.append("ROUND — validar modo (banker's vs half-up)")
    if "money" in e:
        r.append("MONEY — banker's rounding Informix; NUMERIC PostgreSQL diverge")
    if re.search(r"/\s*[a-z_]*(monto|importe|saldo|total|capital)", e) and not r:
        r.append("DIV monetaria — posible pérdida de centavos; usar DECIMAL(18,4) + ROUND explícito")
    if ("dbaccess" in e or "/resplogifx/" in fl or "unload to" in e
            or re.search(r"vsql\s*=|vstmt\s*=", e)):
        r.append("DBACCESS — ejecución SQL externa vía shell; paths AIX muertos en target AWS/PostgreSQL")
    return r


# ── Patrones de extracción ────────────────────────────────────────────────────
RE_CREATE  = re.compile(r"create\s+(?:procedure|function)\b", re.I)
RE_FORMULA = re.compile(r"\b(?:let|set)\s+([a-z_][a-z0-9_]*)\s*=\s*(.+)", re.I)
RE_BOILERP = re.compile(r"codret\s*=\s*['\"]0+['\"]", re.I)
RE_RAISE   = re.compile(
    r"raise\s+exception"
    r"|return\s+['\"]?\d{4,}"
    r"|codret\s*=\s*['\"][1-9A-Z][A-Z0-9]{2,}['\"]"
    r"|retornar\s+['\"]?\d{3,}"
    r"|v_?codret\s*[<>]+\s*['\"]"
    r"|vcodret\s*=\s*['\"][1-9]",
    re.I)

_BASE_FIN = [
    "int","isr","tasa","monto","saldo","comis","iva","cuota","dias","importe",
    "capital","rendim","gat","cat","sdo","abono","cargo","mora","interes",
    "reserva","provision","tir","van","pago","plazo","pagare","aforo","descuento",
]
_VOCAB_FIN = [t for t in FIN_FROM_VOCAB if len(t) >= 4][:40]
_ALL_FIN   = sorted(set(_BASE_FIN + _VOCAB_FIN), key=len, reverse=True)
FIN_PAT    = "(" + "|".join(re.escape(t) for t in _ALL_FIN) + ")"

RE_UMBRAL = re.compile(
    r"^\s*if\b.{0,80}" + FIN_PAT + r".{0,40}([<>]=?)\s*(\d{2,}(?:[.,]\d+)?)\b",
    re.I)
RE_ESTADO = re.compile(
    r"^\s*if\b.{0,60}\b(estatus|estado|tipo|clave|codest|codret|estado_cuenta|tipo_cuenta|"
    r"tipo_credito|tipo_mov|condicion|flag|stat|clase)\b.{0,30}"
    r"(?:=\s*['\"][A-Z0-9]{1,4}['\"]|\bin\s*\(['\"])",
    re.I)


def norm_expr(e):
    e = re.sub(r"\s+", " ", e).strip().rstrip(";")
    return e[:180]


def isolate(txt):
    ms = list(RE_CREATE.finditer(txt))
    return txt[ms[0].start():ms[1].start()] if len(ms) >= 2 else txt


# ── Categorías D01-D16 (por patrón nombre SP y DB) ────────────────────────────
_CAT_PAGOS    = re.compile(
    r"sp_tef_|sp_domi_|sp_rem_|sp_transfer_|spei_|sp_atms_|sp_pago|"
    r"sp_aplic|sp_cobro|sp_cargo_|sp_app_confirm|sp_app_record|sp_grabapago", re.I)
_CAT_ATENCION = re.compile(
    r"sp_sac_|sp_acl_|sp_cac_|aclaracion|disputa|sp_reclam|sp_queja|"
    r"sp_benefrem|sp_atencion|sp_ejecuta_sac", re.I)
_CAT_RIESGO   = re.compile(
    r"buro|scoring|califica|cartera|carterav|mora|reserva|provision|"
    r"lincred|principalcrd|principal_|sp_adn_|geninsumos|sp_pld|sp_burofisicas", re.I)
_CAT_FLUJO    = re.compile(
    r"procesa|proceso|ejecuta|sp_principal\b|sp_cierre|reproceso|"
    r"sp_flujo|sp_main|sp_cierr|sp_aplica_lote|sp_genera_", re.I)
_CAT_CONT     = re.compile(
    r"sp_cont_|gl_saldos|gl_movimientos|gl_asientos|sp_repor|"
    r"sp_cierrecontable|sp_genera_serie|sp_cnsif|sp_repipab|sp_fc_|sp_genera_cintas", re.I)
_CAT_PARAM    = re.compile(
    r"^sp_consulta|^sp_cons|^sp_obtiene|^sp_get_|^sp_cat_|"
    r"sp_actcatalogo|sp_lee_|sp_carga_cat", re.I)

_DB_D01_D16_OVERRIDES = {
    "bdispei": "PAGOS_TRANSFERENCIAS", "bditef": "PAGOS_TRANSFERENCIAS",
    "bditransfer": "PAGOS_TRANSFERENCIAS", "bdiaclaracion": "ATENCION_CLIENTE",
    "bdicont": "CONTABILIDAD_REPORTES", "bdicred": "RIESGO_CREDITO",
}


def asigna_categoria(sp, code, tipo, regs, db):
    dc = DOMN_CODE.get(db, "")
    if regs:
        return "REGULATORIO"
    if tipo == "FÓRMULA":
        return "CALCULO_FINANCIERO"
    # D17-D49: usar CAT_DOM
    if dc and dc in CAT_DOM and int(dc[1:]) >= 17:
        return CAT_DOM[dc]
    # D01-D16: patrones por SP name
    s = sp.lower()
    if _CAT_CONT.search(s):     return "CONTABILIDAD_REPORTES"
    if _CAT_PAGOS.search(s):    return "PAGOS_TRANSFERENCIAS"
    if _CAT_ATENCION.search(s): return "ATENCION_CLIENTE"
    if _CAT_RIESGO.search(s):   return "RIESGO_CREDITO"
    if _CAT_FLUJO.search(s):    return "FLUJO_OPERATIVO"
    if _CAT_PARAM.search(s):    return "PARAMETRIA"
    return _DB_D01_D16_OVERRIDES.get(db, "OPERACIONAL")


# ── Pre-filtro rápido ─────────────────────────────────────────────────────────
PRE_FILTER = (
    b"let ", b"set ", b"raise exception", b"return ", b"if ", b"while ",
    b"interes", b"tasa", b"saldo", b"monto", b"importe", b"comis",
    b"isr", b"iva", b"gat", b"spei", b"clabe", b"reserva",
    b"bitacora", b"cartera", b"mora", b"cobro", b"pago", b"cuota",
    b"money", b"decimal", b"trunc", b"round", b"dbaccess",
    b"pagare", b"inversion", b"nomina",
)

# ── Candidatos: todos los .sql de los 49 dominios ─────────────────────────────
cand = []
for fn in sorted(os.listdir(SRC)):
    if not fn.endswith(".sql"):
        continue
    db, _, sp = fn[:-4].partition("_")
    if sp:
        cand.append((db, sp, str(SRC / fn)))
print(f"  Archivos .sql encontrados: {len(cand)}")

# ── Extracción principal ───────────────────────────────────────────────────────
rules = []
seq = 0
seen_f = set(); seen_v = set(); seen_u = set(); seen_e = set()
n_scanned = n_pre = 0

for db, sp, fp in cand:
    try:
        raw = open(fp, "rb").read(8192).lower()
        if not any(pf in raw for pf in PRE_FILTER):
            n_pre += 1
            continue
    except Exception:
        continue

    n_scanned += 1
    try:
        txt = isolate(open(fp, encoding="utf-8", errors="replace").read())
    except Exception:
        continue

    dom_label = DOMN.get(db, db)
    dom_code  = DOMN_CODE.get(db, "")
    v_val = 0

    for i, rawln in enumerate(txt.split("\n"), 1):
        s  = rawln.strip()
        if not s or s.startswith("--"):
            continue
        sl = s.lower()

        # ── FÓRMULA ──────────────────────────────────────────────────────────
        m    = RE_FORMULA.match(s)
        _rhs = m.group(2).strip() if m else ""
        if (m and re.search(r"[*/]", _rhs) and re.search(FIN_PAT, s, re.I)
                and not _rhs.startswith(("'", '"'))):
            expr = norm_expr(m.group(1) + " = " + m.group(2))
            key  = (db, sp, re.sub(r"\d", "#", expr))
            if key not in seen_f:
                seen_f.add(key)
                regs = clasifica(sp + " " + expr)
                vr   = detect_vocab_refs(sl)
                bc, bcn = tag_bc(vr)
                seq += 1
                rules.append({
                    "id": f"BR-BRZ-{seq:06d}", "tipo": "FÓRMULA",
                    "sp": sp, "db": db, "line": i, "code": expr,
                    "reg": regs, "riesgo": riesgo_equiv(m.group(2), s),
                    "bc": bc, "bc_name": bcn, "vocab_refs": vr,
                    "dominio": dom_label, "dom_code": dom_code,
                    "categoria": asigna_categoria(sp, expr, "FÓRMULA", regs, db),
                    "business_name": "", "clase": "",
                })

        # ── VALIDACIÓN ───────────────────────────────────────────────────────
        if RE_RAISE.search(s) and not RE_BOILERP.search(s) and v_val < 5:
            key = (db, sp, re.sub(r"\d", "#", s[:80]))
            if key not in seen_v:
                seen_v.add(key)
                code = norm_expr(s)
                regs = clasifica(sp + " " + s)
                vr   = detect_vocab_refs(sl)
                bc, bcn = tag_bc(vr)
                seq += 1; v_val += 1
                rules.append({
                    "id": f"BR-BRZ-{seq:06d}", "tipo": "VALIDACIÓN",
                    "sp": sp, "db": db, "line": i, "code": code,
                    "reg": regs, "riesgo": riesgo_equiv(s, s),
                    "bc": bc, "bc_name": bcn, "vocab_refs": vr,
                    "dominio": dom_label, "dom_code": dom_code,
                    "categoria": asigna_categoria(sp, s, "VALIDACIÓN", regs, db),
                    "business_name": "", "clase": "",
                })

        # ── UMBRAL ───────────────────────────────────────────────────────────
        mu = RE_UMBRAL.match(s)
        if mu:
            expr = norm_expr(s)
            key  = (db, sp, re.sub(r"\d", "#", expr))
            if key not in seen_u:
                seen_u.add(key)
                regs = clasifica(sp + " " + expr)
                vr   = detect_vocab_refs(sl)
                bc, bcn = tag_bc(vr)
                seq += 1
                rules.append({
                    "id": f"BR-BRZ-{seq:06d}", "tipo": "UMBRAL",
                    "sp": sp, "db": db, "line": i, "code": expr,
                    "reg": regs, "riesgo": riesgo_equiv(s, s),
                    "bc": bc, "bc_name": bcn, "vocab_refs": vr,
                    "dominio": dom_label, "dom_code": dom_code,
                    "categoria": asigna_categoria(sp, expr, "UMBRAL", regs, db),
                    "business_name": "", "clase": "",
                })

        # ── ESTADO ───────────────────────────────────────────────────────────
        if RE_ESTADO.match(s):
            expr = norm_expr(s)
            key  = (db, sp, expr[:80])
            if key not in seen_e:
                seen_e.add(key)
                regs = clasifica(sp + " " + expr)
                vr   = detect_vocab_refs(sl)
                bc, bcn = tag_bc(vr)
                seq += 1
                rules.append({
                    "id": f"BR-BRZ-{seq:06d}", "tipo": "ESTADO",
                    "sp": sp, "db": db, "line": i, "code": expr,
                    "reg": regs, "riesgo": [],
                    "bc": bc, "bc_name": bcn, "vocab_refs": vr,
                    "dominio": dom_label, "dom_code": dom_code,
                    "categoria": asigna_categoria(sp, expr, "ESTADO", regs, db),
                    "business_name": "", "clase": "",
                })

print(f"  Escaneados: {n_scanned}  |  Pre-filtro descartó: {n_pre}")

# ── Estadísticas ──────────────────────────────────────────────────────────────
by_tipo = Counter(r["tipo"]    for r in rules)
by_reg  = Counter(x            for r in rules for x, _ in r["reg"])
by_dom  = Counter(r["dominio"] for r in rules)
n_reg   = sum(1 for r in rules if r["reg"])
n_ries  = sum(1 for r in rules if r["riesgo"])

print(f"\nReglas Bronze extraídas: {len(rules)}")
for t in ("FÓRMULA", "VALIDACIÓN", "UMBRAL", "ESTADO"):
    print(f"  {t:<12}: {by_tipo.get(t, 0)}")
print(f"  Con reg    : {n_reg} ({n_reg * 100 // len(rules) if rules else 0}%)")
print(f"  Con riesgo : {n_ries}")
print(f"  Dominios   : {len(by_dom)}")
print(f"\nTop dominios:")
for dom, cnt in by_dom.most_common(10):
    print(f"  {dom}: {cnt}")

# ── Output JSON ───────────────────────────────────────────────────────────────
out = {
    "meta": {
        "version": "bronze-1.0",
        "layer": "bronze",
        "generated": str(date.today()),
        "tool": "extract-rules.py",
        "sp_scanned": n_scanned,
        "sp_prefiltered": n_pre,
        "total": len(rules),
        "domains": len(by_dom),
    },
    "rules": rules,
    "stats": {
        "by_tipo": dict(by_tipo),
        "by_reg":  dict(by_reg.most_common()),
        "by_dom":  dict(by_dom.most_common()),
        "n_reg":   n_reg,
        "n_riesgo": n_ries,
    },
}

OUT.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
print(f"\nrules-bronze.json escrito: {len(rules)} reglas · {len(by_dom)} dominios")
print("Siguiente: python generators/enrich-rules.py")
