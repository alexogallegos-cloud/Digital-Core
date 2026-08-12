#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
extract-rules-v2.py — Extracción extensiva de reglas de negocio anclada en vocabulario.

Mejoras sobre v1:
  · Cobertura ampliada: 3,761 SPs del callgraph (vs ~427 en v1)
  · Regex FIN ampliado con términos ENTIDAD/METRICA del vocabulario certificado
  · Nuevos tipos: UMBRAL (umbrales numéricos), ESTADO (transiciones de estado)
  · BC tagging: cada regla hereda el Bounded Context del término vocab dominante en su código
  · vocab_refs: lista de términos vocab referenciados en cada regla
  · Genera: business-rules-v2.json + knowledge-base/rules/business-rules-bcop.md

Etapa 3 — Business Logic Extraction · Specialist Informix SPL · SPE-AM-001
"""
import json, re, os
from collections import defaultdict, Counter

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/BCOPCore/")
SRC = BASE + "source/BCOPCore/informix/"

# ── Cargar vocabulario certificado ────────────────────────────────────────────
inv = json.load(open(BASE + "knowledge-base/vocabulary-inventory.json", encoding="utf-8"))
VOCAB = {}
for section in ("atomos", "compuestos"):
    for item in inv.get(section, []):
        VOCAB[item["term"]] = item

# términos ENTIDAD/METRICA de alta/media confianza para ampliar FIN regex
FIN_FROM_VOCAB = sorted(
    {t for t, v in VOCAB.items()
     if v["cat"] in ("ENTIDAD", "METRICA") and v["nivel"] in ("ALTA", "MEDIA") and len(t) >= 4},
    key=len, reverse=True
)
# BC lookup: term → (bc_code, bc_name)  — solo términos con BC específico
BC_TERMS = {}
for t, v in VOCAB.items():
    bc = v.get("bc", "") or ""
    if bc and bc not in ("—", "-"):
        BC_TERMS[t] = (bc, v.get("bc_name", ""))

VOCAB_SET = set(VOCAB.keys())  # fast membership test

def detect_vocab_refs(code_lower):
    """Retorna lista de términos vocab encontrados en la línea de código."""
    found = []
    for t in VOCAB_SET:
        if len(t) >= 4 and re.search(r'\b' + re.escape(t) + r'\b', code_lower):
            found.append(t)
    return found[:8]  # máx 8 refs por regla

def tag_bc(vocab_refs):
    """Devuelve (bc_code, bc_name) del término BC-específico más frecuente en vocab_refs."""
    for t in vocab_refs:
        if t in BC_TERMS:
            return BC_TERMS[t]
    return ("", "")

# ── SMEs reguladores ──────────────────────────────────────────────────────────
SME = {
    "SAT":      ("SME Regulatorio — SAT",      "SME/Regulatory/SAT/"),
    "CNBV":     ("SME Regulatorio — CNBV",     "SME/Regulatory/CNBV/"),
    "CONDUSEF": ("SME Regulatorio — CONDUSEF", "SME/Regulatory/CONDUSEF/"),
    "Banxico":  ("SME Regulatorio — Banxico",  "SME/Regulatory/Banxico/"),
    "IPAB":     ("SME Regulatorio — IPAB",     "SME/Regulatory/IPAB/"),
    "TESOFE":   ("SME Regulatorio — TESOFE",   "SME/Regulatory/TESOFE/"),
}
REG_RULES = [
    # ── SAT ──────────────────────────────────────────────────────────────────
    (r"\bisr\b|imp_isr|tasa_isr",
     "SAT", "LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual)"),
    (r"\biva\b|imp_iva|ivas\b",
     "SAT", "LIVA — IVA sobre comisiones (16% / 8% frontera)"),
    (r"\bgdf\b|sp_bitacoragdf|sp_consdatosticketpgdf|sp_validadvgdf|cfdi|retenciones",
     "SAT", "CFDI/Retenciones bancarias — folio fiscal por transacción de pago de servicios (SAT)"),
    # ── CONDUSEF ─────────────────────────────────────────────────────────────
    (r"comis|comicob|cobracom",
     "CONDUSEF", "LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF"),
    (r"\bcat\b|costo_anual",
     "CONDUSEF", "LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente)"),
    (r"\bgat\b|ganancia_anual",
     "CONDUSEF", "LTOSF — Ganancia Anual Total (nominal/real)"),
    (r"sp_sac_|aclaracion|disputa|remisac|sp_genreporbenefrem|sp_validarembtsensac",
     "CONDUSEF", "RECA/SAC — Reclamaciones; resolución ≤ 45 días calendario"),
    # ── CNBV ─────────────────────────────────────────────────────────────────
    (r"interes|calc_int|tasa|rendim",
     "CNBV", "Criterios contables CNBV + GAT — cálculo de intereses/rendimientos"),
    (r"sp_cont_|gl_saldos|gl_movimientos|gl_asientos|cat_cuentas|co_sdodias",
     "CNBV", "CUB Anexo 33-34 — Plan de cuentas mínimo; cuadre DEBE = HABER a centavo"),
    (r"cierre_diario|serie_r|sp_genera_serie_r|sp_cont_conssaldosdiariosb4|sp_cont_productotransaccionb5",
     "CNBV", "CUB Anexo 36 — Serie R; reportes mensuales R01-A/B R04-A/B R12 R22 R24"),
    (r"bitacora|sp_bitacoragdf|_movhis|sd_movhis|log_|_his\b",
     "CNBV", "Art.78 LIC — conservación de información 5 años (bitácoras y movimientos)"),
    (r"estimacion_preventiva|cartera_vencida|reserva|castigo|pi_\w|sxp\b",
     "CNBV", "CUB B-5 — Reservas crediticias; Reserva = Saldo × PI × Severidad × Exposición"),
    (r"sp_bts_|_bts\b|grabapagocoppel|sp_sac_eliminamovsbts|sac_controlconvenios",
     "CNBV", "CUB Art.310-315 — Corresponsalía BTS; validación convenio activo + folio único"),
    (r"art_?61|inactiv|beneficencia",
     "CNBV", "Art.61 LIC — cuentas inactivas → prescripción a beneficencia pública"),
    (r"buro|scoring|califica",
     "CNBV", "LRSIC — Buró de Crédito; evaluación crediticia"),
    (r"mora|vencid|cartera_vencida",
     "CNBV", "CUB CNBV — calificación cartera vencida y constitución de reservas"),
    (r"\bclabe\b|cuenta_clabe",
     "Banxico", "Circular Banxico — formato CLABE 18 dígitos (validación algoritmo módulo-10)"),
    # ── Banxico ───────────────────────────────────────────────────────────────
    (r"spei_|spei_aplicaordenpago|spei_recordenpago|spei_recdevolucion|spei_reccancelacion|clave_rastreo|cve_rastreo",
     "Banxico", "SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA < 20 s"),
    (r"spei_recextemporanea|spei_apgbanope|sp_actbancont|spei_upd_status_firma",
     "Banxico", "SPEI — confirmación bancos operadores; extemporáneo > 17:30"),
    (r"\bcodi\b|spei_devcodi|spei_recerrorescodi",
     "Banxico", "Reglas CoDi — Cobro Digital Banxico; devolución y errores CoDi"),
    (r"appriza|sp_app_confirmpayment|sp_app_recordorder|sp_app_submitpayreversal|sp_actualiza_cte_remesa",
     "Banxico", "Circular 14/2017 — Notificación fallos remesas; max_retries 3; plazo ≤ 2 días hábiles"),
    # ── IPAB ──────────────────────────────────────────────────────────────────
    (r"cuota.*ipab|ipab|4.?al.?millar|saldo_asegurado|lraf\b|nivel_cuenta|captacion_tradicional",
     "IPAB", "LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular; etiqueta LRAF"),
    # ── TESOFE ────────────────────────────────────────────────────────────────
    (r"tesofe|sp_sacreportemensualgdf|sp_sacreportesemanalgdf|pago_gobierno|aportacion|concentracion\b",
     "TESOFE", "LTF — concentración/dispersión fondos gobierno; conciliación diaria folio GDF"),
    (r"dispersion|pension|beca",
     "TESOFE", "LTF — dispersión de recursos federales (pensiones, becas, apoyos)"),
]

def clasifica(text):
    hits, seen = [], set()
    low = text.lower()
    for pat, reg, norma in REG_RULES:
        if re.search(pat, low) and reg not in seen:
            hits.append((reg, norma))
            seen.add(reg)
    return hits

# ── Riesgos de equivalencia ───────────────────────────────────────────────────
def riesgo_equiv(expr):
    r = []
    if re.search(r"/\s*360\b", expr):   r.append("base 360 (año comercial) — verificar vs 365")
    if re.search(r"/\s*365\b", expr):   r.append("base 365 — verificar vs 360")
    if re.search(r"/\s*30\b", expr):    r.append("base 30 días/mes — verificar cálculo calendario")
    if "trunc" in expr.lower():         r.append("TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos)")
    if re.search(r"\bround\b", expr.lower()): r.append("ROUND — validar modo (banker's vs half-up)")
    if "money" in expr.lower():         r.append("MONEY — banker's rounding Informix; NUMERIC PostgreSQL diverge")
    return r

# ── Patrones de extracción ────────────────────────────────────────────────────
RE_CREATE = re.compile(r"create\s+(?:procedure|function)\b", re.I)

def isolate(t):
    ms = list(RE_CREATE.finditer(t))
    return t[ms[0].start():ms[1].start()] if len(ms) >= 2 else t

# FIN: variables financieras (legacy + vocab-ampliado)
_BASE_FIN = ["int","isr","tasa","monto","saldo","comis","iva","cuota","dias","importe",
             "capital","rendim","gat","cat","sdo","abono","cargo","mora","interes",
             "reserva","provision","cuota","cargo","tir","van","pago"]
_VOCAB_FIN = [t for t in FIN_FROM_VOCAB if len(t) >= 4][:40]
_ALL_FIN = sorted(set(_BASE_FIN + _VOCAB_FIN), key=len, reverse=True)
FIN_PAT = "(" + "|".join(re.escape(t) for t in _ALL_FIN) + ")"

RE_FORMULA = re.compile(r"\b(?:let|set)\s+([a-z_][a-z0-9_]*)\s*=\s*(.+)", re.I)

# Boilerplate excluido: inicializaciones de happy-path (cero = sin error, no es regla)
RE_BOILERPLATE = re.compile(r"codret\s*=\s*['\"]0+['\"]", re.I)

RE_RAISE = re.compile(
    r"raise\s+exception"
    r"|return\s+['\"]?\d{4,}"
    r"|codret\s*=\s*['\"][1-9A-Z][A-Z0-9]{2,}['\"]"   # código != 0000
    r"|retornar\s+['\"]?\d{3,}"
    r"|v_codret\s*[<>]+\s*['\"]",
    re.I
)

# ── Categorías de segmentación ────────────────────────────────────────────────
_CAT_PAGOS     = re.compile(r"sp_tef_|sp_domi_|sp_rem_|sp_transfer_|spei_|sp_atms_|sp_pago|"
                             r"sp_aplic|sp_cobro|sp_cargo_|bditef|bdidomi|bditransfer|"
                             r"sp_app_confirm|sp_app_record|sp_grabapago", re.I)
_CAT_ATENCION  = re.compile(r"sp_sac_|sp_acl_|sp_cac_|aclaracion|disputa|sp_reclam|sp_queja|"
                             r"sp_benefrem|sp_atencion|sp_ejecuta_sac", re.I)
_CAT_RIESGO    = re.compile(r"buro|scoring|califica|cartera|carterav|mora|reserva|provision|"
                             r"lincred|principalcrd|principal_|sp_adn_|geninsumos|calif_|"
                             r"sp_sw_ro|sp_pld|sp_burofisicas", re.I)
_CAT_FLUJO     = re.compile(r"procesa|proceso|ejecuta|sp_principal\b|sp_cierre|reproceso|"
                             r"orquesta|sp_flujo|sp_main|sp_cierr|lote|batch|sp_aplica_lote|"
                             r"sp_genera_", re.I)
_CAT_CONT      = re.compile(r"sp_cont_|gl_saldos|gl_movimientos|gl_asientos|sp_repor|"
                             r"sp_cierrecontable|sp_genera_serie|sp_cnsif|sp_sorteo|"
                             r"sp_repipab|sp_fc_|sp_genera_cintas", re.I)
_CAT_PARAM     = re.compile(r"^sp_consulta|^sp_cons|^sp_obtiene|^sp_get_|^sp_cat_|"
                             r"catalogos|sp_actcatalogo|sp_lee_|sp_carga_cat", re.I)

def asigna_categoria(sp, code, tipo, regs, db):
    s = sp.lower()
    c = code.lower()
    # Regulatorio: tiene impacto regulatorio explícito (primer check, mayor prioridad)
    if regs:
        return "REGULATORIO"
    # Cálculo financiero: toda fórmula o código con aritmética
    if tipo == "FÓRMULA":
        return "CALCULO_FINANCIERO"
    # Por patrón de SP name
    if _CAT_CONT.search(s):     return "CONTABILIDAD_REPORTES"
    if _CAT_PAGOS.search(s):    return "PAGOS_TRANSFERENCIAS"
    if _CAT_ATENCION.search(s): return "ATENCION_CLIENTE"
    if _CAT_RIESGO.search(s):   return "RIESGO_CREDITO"
    if _CAT_FLUJO.search(s):    return "FLUJO_OPERATIVO"
    if _CAT_PARAM.search(s):    return "PARAMETRIA"
    # Por dominio DB
    if db in ("bdispei", "bditef", "bditransfer"): return "PAGOS_TRANSFERENCIAS"
    if db in ("bdiaclaracion",):                    return "ATENCION_CLIENTE"
    if db in ("bdicont",):                          return "CONTABILIDAD_REPORTES"
    if db in ("bdicred",):                          return "RIESGO_CREDITO"
    return "OPERACIONAL"

# UMBRAL: IF v_xxx [<>]=? constante_numérica en contexto financiero
RE_UMBRAL = re.compile(
    r"^\s*if\b.{0,80}" + FIN_PAT + r".{0,40}([<>]=?)\s*(\d{2,}(?:[.,]\d+)?)\b",
    re.I
)

# ESTADO: IF v_estado|v_estatus|v_tipo|v_clave = 'X' / IN (...)
RE_ESTADO = re.compile(
    r"^\s*if\b.{0,60}\b(estatus|estado|tipo|clave|codest|codret|estado_cuenta|tipo_cuenta|"
    r"tipo_credito|tipo_mov|condicion|flag|stat|clase)\b.{0,30}(?:=\s*['\"][A-Z0-9]{1,4}['\"]|"
    r"\bin\s*\(['\"])",
    re.I
)

def norm_expr(e):
    e = re.sub(r"\s+", " ", e).strip().rstrip(";")
    return e[:180]

# ── Candidatos SP para escanear — TODOS los 12,881 archivos ──────────────────
DOMN = {"bdicheq":"D04 Cheques","bdicred":"D03 Créditos","bdisac":"D05 Saldos","bdispei":"D08 SPEI",
        "bdicont":"D12 Contab.","bdisolic":"D06 Solic.","bdiaclaracion":"D07 Aclar.","bdimnsj":"D09 Msj",
        "bdicnweb":"D01 Canal","bdinteg":"D02 Integr.","bdicobranza":"D11 Cobr.","bdisuc":"D10 Suc.",
        "bdibts":"D13 BTS","bdiconsorcio":"D14 Consorcio","bdiarras":"D15 Arras"}

# Pre-filtro rápido: strings que garantizan contenido financiero/regulatorio
# (evita aplicar regex pesado a SPs puramente de catálogo/UI sin lógica)
PRE_FILTER = (
    "let ", "set ", "raise exception", "return ", "if ", "while ",  # lógica
    "interes", "tasa", "saldo", "monto", "importe", "comis",        # finanzas
    "isr", "iva", "gat", "cat", "spei", "clabe", "reserva",        # regulatorio
    "bitacora", "cartera", "mora", "cobro", "pago", "cuota",       # negocio
    "money", "decimal", "trunc", "round",                           # tipos financieros
)

cand = []
print(f"  Escaneando filesystem {SRC}...")
for fn in sorted(os.listdir(SRC)):
    if not fn.endswith(".sql"):
        continue
    db, _, sp = fn[:-4].partition("_")
    if sp:
        cand.append((db, sp, SRC + fn))
print(f"  Total archivos .sql: {len(cand)}")

# ── Extracción ────────────────────────────────────────────────────────────────
rules = []
rid = 0
seen_formula = set()
seen_validacion = set()
seen_umbral = set()
seen_estado = set()

n_files_scanned = 0
n_pre_filtered = 0

for db, sp, fp in cand:
    # Pre-filtro rápido (lectura binaria para máxima velocidad)
    try:
        raw_bytes = open(fp, "rb").read(8192)  # primeros 8KB bastan para detectar patrón
        raw_low = raw_bytes.lower()
        if not any(pf.encode() in raw_low for pf in PRE_FILTER):
            n_pre_filtered += 1
            continue
    except Exception:
        continue

    n_files_scanned += 1
    try:
        txt = isolate(open(fp, encoding="utf-8", errors="replace").read())
    except Exception:
        continue
    lines = txt.split("\n")

    v_val = 0  # máx validaciones por SP

    for i, raw in enumerate(lines, 1):
        s = raw.strip()
        if not s or s.startswith("--"):
            continue
        sl = s.lower()

        # FÓRMULA — asignación aritmética sobre variable financiera
        m = RE_FORMULA.match(s)
        if m and re.search(r"[*/]", m.group(2)) and re.search(FIN_PAT, s, re.I):
            expr = norm_expr(m.group(1) + " = " + m.group(2))
            key = (sp, re.sub(r"\d", "#", expr))
            if key not in seen_formula:
                seen_formula.add(key)
                regs = clasifica(sp + " " + expr)
                vr = detect_vocab_refs(sl)
                bc, bc_name = tag_bc(vr)
                cat = asigna_categoria(sp, expr, "FÓRMULA", regs, db)
                rid += 1
                rules.append({
                    "id": f"BR-V2-{rid:04d}", "tipo": "FÓRMULA", "sp": sp, "db": db,
                    "line": i, "code": expr, "reg": regs, "riesgo": riesgo_equiv(m.group(2)),
                    "bc": bc, "bc_name": bc_name, "vocab_refs": vr,
                    "dominio": DOMN.get(db, db), "categoria": cat
                })

        # VALIDACIÓN — RAISE EXCEPTION / código de retorno (máx 5 por SP)
        # Se excluyen inicializaciones boilerplate: codret = '0000' sin lógica
        if RE_RAISE.search(s) and not RE_BOILERPLATE.search(s) and v_val < 5:
            key = (sp, re.sub(r"\d", "#", s[:80]))
            if key not in seen_validacion:
                seen_validacion.add(key)
                regs = clasifica(sp + " " + s)
                vr = detect_vocab_refs(sl)
                bc, bc_name = tag_bc(vr)
                cat = asigna_categoria(sp, s, "VALIDACIÓN", regs, db)
                rid += 1
                v_val += 1
                rules.append({
                    "id": f"BR-V2-{rid:04d}", "tipo": "VALIDACIÓN", "sp": sp, "db": db,
                    "line": i, "code": norm_expr(s), "reg": regs, "riesgo": [],
                    "bc": bc, "bc_name": bc_name, "vocab_refs": vr,
                    "dominio": DOMN.get(db, db), "categoria": cat
                })

        # UMBRAL — IF v_xxx [<>]= constante en contexto financiero
        mu = RE_UMBRAL.match(s)
        if mu:
            expr = norm_expr(s)
            key = (sp, re.sub(r"\d", "#", expr))
            if key not in seen_umbral:
                seen_umbral.add(key)
                regs = clasifica(sp + " " + expr)
                vr = detect_vocab_refs(sl)
                bc, bc_name = tag_bc(vr)
                cat = asigna_categoria(sp, expr, "UMBRAL", regs, db)
                rid += 1
                rules.append({
                    "id": f"BR-V2-{rid:04d}", "tipo": "UMBRAL", "sp": sp, "db": db,
                    "line": i, "code": expr, "reg": regs, "riesgo": riesgo_equiv(s),
                    "bc": bc, "bc_name": bc_name, "vocab_refs": vr,
                    "dominio": DOMN.get(db, db), "categoria": cat
                })

        # ESTADO — checks de estado/tipo/clave con valor literal
        if RE_ESTADO.match(s):
            expr = norm_expr(s)
            key = (sp, expr[:80])
            if key not in seen_estado:
                seen_estado.add(key)
                regs = clasifica(sp + " " + expr)
                vr = detect_vocab_refs(sl)
                bc, bc_name = tag_bc(vr)
                cat = asigna_categoria(sp, expr, "ESTADO", regs, db)
                rid += 1
                rules.append({
                    "id": f"BR-V2-{rid:04d}", "tipo": "ESTADO", "sp": sp, "db": db,
                    "line": i, "code": expr, "reg": regs, "riesgo": [],
                    "bc": bc, "bc_name": bc_name, "vocab_refs": vr,
                    "dominio": DOMN.get(db, db), "categoria": cat
                })

print(f"\n  Archivos escaneados: {n_files_scanned} (pre-filtro descartó {n_pre_filtered})")

# ── Estadísticas ──────────────────────────────────────────────────────────────
by_tipo   = Counter(r["tipo"] for r in rules)
by_reg    = Counter(x for r in rules for x, _ in r["reg"])
by_bc     = Counter((r["bc"], r.get("bc_name","")) for r in rules if r["bc"])
by_cat    = Counter(r.get("categoria","OPERACIONAL") for r in rules)
n_riesgo  = sum(1 for r in rules if r["riesgo"])
n_reg     = sum(1 for r in rules if r["reg"])
by_dom    = Counter(r["dominio"] for r in rules)

print(f"\nReglas extraídas v2: {len(rules)}")
print(f"  FÓRMULA:    {by_tipo.get('FÓRMULA',0)}")
print(f"  VALIDACIÓN: {by_tipo.get('VALIDACIÓN',0)}")
print(f"  UMBRAL:     {by_tipo.get('UMBRAL',0)}")
print(f"  ESTADO:     {by_tipo.get('ESTADO',0)}")
print(f"  Regulatorias: {n_reg} · Con riesgo equiv: {n_riesgo}")
print(f"  Reguladores: " + " · ".join(f"{k}:{v}" for k,v in sorted(by_reg.items(), key=lambda x:-x[1])))
print(f"\n  Categorías:")
for cat, cnt in by_cat.most_common():
    print(f"    {cat}: {cnt}")

# ── Output JSON ───────────────────────────────────────────────────────────────
out = {
    "meta": {
        "version": "2.1",
        "generated": "2026-08-02",
        "tool": "extract-rules-v2.py",
        "sp_scanned": n_files_scanned,
        "total": len(rules),
    },
    "rules": rules,
    "stats": {
        "by_tipo": dict(by_tipo),
        "by_reg": dict(by_reg),
        "by_bc": {f"{bc}|||{bn}": cnt for (bc, bn), cnt in by_bc.most_common()},
        "by_cat": dict(by_cat.most_common()),
        "by_dom": dict(by_dom.most_common()),
        "n_riesgo": n_riesgo,
        "n_reg": n_reg,
    }
}
json.dump(out, open(BASE + "portal/data/business-rules-v2.json", "w", encoding="utf-8"),
          ensure_ascii=False, separators=(",", ":"))
print(f"\nbusiness-rules-v2.json escrito · {len(rules)} reglas")

# ── Knowledge-base Markdown ───────────────────────────────────────────────────
os.makedirs(BASE + "knowledge-base/rules", exist_ok=True)
KB_PATH = BASE + "knowledge-base/rules/business-rules-bcop.md"

L = [
    "# BCOPCore · Catálogo de Reglas de Negocio — v2",
    "",
    "> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction  ",
    f"> **Generado:** 2026-08-02 · `extract-rules-v2.py` · {n_files_scanned} SPs escaneados  ",
    "> **Anclaje:** vocabulario certificado 787 términos · `vocabulary-inventory.json`  ",
    "> **Fuente canónica:** `business-rules-v2.json` — este MD es resumen navegable  ",
    "",
    "## Resumen ejecutivo",
    "",
    f"| Tipo | Reglas |",
    "|----|---:|",
]
for tipo in ("FÓRMULA", "VALIDACIÓN", "UMBRAL", "ESTADO"):
    L.append(f"| {tipo} | {by_tipo.get(tipo, 0)} |")
L += [
    f"| **TOTAL** | **{len(rules)}** |",
    "",
    "| Dimensión | Valor |",
    "|---|---|",
    f"| SPs escaneados | {n_files_scanned} |",
    f"| Reglas con impacto regulatorio | {n_reg} |",
    f"| Reglas con riesgo de equivalencia | {n_riesgo} |",
    "",
    "## Reguladores",
    "",
    "| Regulador | SME | Reglas |",
    "|---|---|---:|",
]
for reg in ("CNBV", "Banxico", "CONDUSEF", "SAT", "TESOFE", "IPAB"):
    nm, path = SME[reg]
    cnt = by_reg.get(reg, 0)
    if cnt:
        L.append(f"| **{reg}** | `{path}` | {cnt} |")

L += ["", "## Bounded Contexts", "", "| BC | Nombre | Reglas |", "|---|---|---:|"]
for (bc, bn), cnt in by_bc.most_common():
    if bc:
        L.append(f"| `{bc}` | {bn} | {cnt} |")

L += [
    "",
    "---",
    "",
    "## Fórmulas financieras críticas (con riesgo de equivalencia)",
    "",
    "> Estas fórmulas **deben validarse con golden master** antes de transpilar al target.",
    "> Un centavo de divergencia es auditable ante SAT/CNBV.",
    "",
]
destacadas = [r for r in rules if r["tipo"] == "FÓRMULA" and r["riesgo"]][:25]
for r in destacadas:
    regs = " · ".join(f"**{reg}**" for reg, _ in r["reg"]) or "operacional"
    bc_tag = f" · `{r['bc']}`" if r.get("bc") else ""
    L.append(f"- `{r['id']}` **{r['sp']}** ({r['dominio']} · L{r['line']}{bc_tag}) — {regs}  ")
    L.append(f"  ```sql")
    L.append(f"  {r['code']}")
    L.append(f"  ```")
    for rk in r["riesgo"]:
        L.append(f"  > ⚠ `[RIESGO-EQUIV]` {rk}")
    L.append("")

L += [
    "---",
    "",
    "## Umbrales de negocio críticos (UMBRAL)",
    "",
    "Valores hardcodeados en el código SPL — cada uno es un parámetro de negocio que **debe documentarse**",
    "como configuración externalizable en el target (no constante embebida).",
    "",
    "| ID | SP | Dominio | BC | Código |",
    "|----|----|----|---|---|",
]
umbrales = [r for r in rules if r["tipo"] == "UMBRAL"][:40]
for r in umbrales:
    code_short = r["code"][:70].replace("|", "/")
    bc_col = f"`{r['bc']}`" if r.get("bc") else "—"
    L.append(f"| {r['id']} | `{r['sp']}` | {r['dominio']} | {bc_col} | `{code_short}` |")

L += [
    "",
    "---",
    "",
    "## Transiciones de estado (ESTADO)",
    "",
    "Reglas que verifican o asignan códigos de estado/tipo. Cada valor literal es un",
    "**catálogo implícito** que debe migrar a tabla de referencia en el target.",
    "",
    "| ID | SP | Dominio | BC | Código |",
    "|----|----|----|---|---|",
]
estados = [r for r in rules if r["tipo"] == "ESTADO"][:40]
for r in estados:
    code_short = r["code"][:70].replace("|", "/")
    bc_col = f"`{r['bc']}`" if r.get("bc") else "—"
    L.append(f"| {r['id']} | `{r['sp']}` | {r['dominio']} | {bc_col} | `{code_short}` |")

L += [
    "",
    "---",
    "",
    "## Riesgos de equivalencia — guía de validación",
    "",
    "| Riesgo | Origen Informix | Validación requerida |",
    "|---|---|---|",
    "| **Base 360** | `/ 360` año comercial | Confirmar vs base 365 con SME CNBV |",
    "| **Base 365** | `/ 365` año natural | Confirmar vs base 360 con SME CNBV |",
    "| **TRUNC** | Trunca decimales sin redondear | Replicar `TRUNC` exacto en PostgreSQL/Java |",
    "| **ROUND** | Modo Informix (half-up) | Validar banker's rounding vs half-up |",
    "| **MONEY** | Banker's rounding automático | Usar `NUMERIC(18,4)` + ROUND explícito en target |",
    "",
    "---",
    "",
    "*Generado automáticamente · Specialist — Informix SPL Analysis · BCOPCore Etapa 3*  ",
    "*Fuente primaria: `source/BCOPCore/informix/` · Vocabulario: `vocabulary-inventory.json`*",
]

open(KB_PATH, "w", encoding="utf-8").write("\n".join(L))
print(f"knowledge-base/rules/business-rules-bcop.md escrito ({len(L)} líneas)")
