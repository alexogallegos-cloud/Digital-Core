#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
extract-rules-d17-d49.py — Extracción vocab-anchored REAL para D17-D49 v1.0
============================================================================
Eleva D17-D49 al mismo nivel analítico que D01-D16: aplica la MISMA maquinaria
de extract-rules-v2.py (anclada en vocabulario certificado) sobre las 33 bases
de datos D17-D49, detectando:
  · FÓRMULA    — aritmética (*,/) sobre variable financiera → riesgo equivalencia
  · VALIDACIÓN — RAISE EXCEPTION / código de retorno de error
  · UMBRAL     — IF v_xxx [<>]= constante numérica en contexto financiero
  · ESTADO     — IF estatus/tipo/clave = 'X' → catálogo implícito
  · reg        — clasificación regulatoria (SAT/CNBV/CONDUSEF/Banxico/IPAB/TESOFE)
  · riesgo     — base 360/365, TRUNC, ROUND, MONEY, base-año-variable, DBACCESS

Reemplaza las reglas crudas BR-V3 (IF/THEN regex) de triaje-d17-d49.py por
extracción rica. Sincroniza brain.db + v3.json.

Diferencia vs extract-rules-v2.py:
  · BASE path relativo (post-refactor systems/core/Informix/)
  · DOMN cubre las 33 BDs D17-D49
  · riesgo_equiv detecta base-de-año en VARIABLE (/vaniobase) + DBACCESS shell
  · Solo escanea D17-D49 (D01-D16 conserva su extracción v2 + Layer A/B/C)

SPE-AM-001 · Specialist Informix SPL · 2026-08-12
"""
import json, re, os, sqlite3, sys
from collections import Counter
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE = Path(__file__).resolve().parent.parent
SRC  = BASE / "source" / "Informix" / "informix"
V3   = BASE / "portal" / "data" / "business-rules-v3.json"
DB   = BASE / "digital-brain" / "brain.db"
VOCAB_INV = BASE / "knowledge-base" / "vocabulary-inventory.json"

# ── Mapa DB → dominio D17-D49 (33 bases) ──────────────────────────────────────
DOMN = {
    'bdibpi':'D17 BPI', 'intercardbpi':'D18 Intercard BPI', 'bditarjeta':'D19 Tarjetas',
    'bdiprog':'D20 Programas', 'bdidomi':'D21 Domiciliación', 'bditransfer':'D22 Transferencias',
    'bdmis':'D23 MIS', 'bdiburo':'D24 Buró de Crédito', 'bdisitesp':'D25 Sitio Especial',
    'bdiprospectos':'D26 Prospectos', 'bdiauditor':'D27 Auditoría', 'bdinvers':'D28 Inversiones',
    'bdiedoelec':'D29 Estados de Cuenta Electrónicos', 'bditarjcop':'D30 Tarjetas Coppel',
    'bdicntchq':'D31 Control de Cheques', 'bdireports':'D32 Reports',
    'bdimonitorcob':'D33 Monitor de Cobranza', 'bdiresp':'D34 RESP', 'bdidigital':'D35 Digital',
    'bdirepaut':'D36 Repaut', 'bdiadminnomina':'D37 Administración Nómina', 'bdicplbot':'D38 CPL Bot',
    'bdiservicios':'D39 Servicios', 'bdibi':'D40 BI', 'bdicorresp':'D41 Corresponsalía',
    'bdivr':'D42 IVR', 'bditrapres':'D43 Transferencias Presenciales', 'bdirech':'D44 RECH',
    'bdiprem':'D45 PREM', 'bdiofi':'D46 OFI', 'bdigaran':'D47 Garantías',
    'bdiriesgos':'D48 Riesgos', 'bdirst':'D49 RST',
}
# DB → código de dominio (para brain.db)
DOMN_CODE = {db: label.split()[0] for db, label in DOMN.items()}
D17_DBS = set(DOMN.keys())

# ── Categoría por dominio D17-D49 ─────────────────────────────────────────────
CAT_DOM = {
    'D17':'BANCA_DIGITAL','D18':'TARJETAS','D19':'TARJETAS','D20':'OPERACIONAL',
    'D21':'PAGOS_TRANSFERENCIAS','D22':'PAGOS_TRANSFERENCIAS','D23':'REPORTERIA',
    'D24':'RIESGO_CREDITO','D25':'OPERACIONAL','D26':'RIESGO_CREDITO','D27':'REGULATORIO',
    'D28':'CALCULO_FINANCIERO','D29':'ATENCION_CLIENTE','D30':'TARJETAS','D31':'PAGOS_TRANSFERENCIAS',
    'D32':'REPORTERIA','D33':'COBRANZA','D34':'OPERACIONAL','D35':'BANCA_DIGITAL','D36':'OPERACIONAL',
    'D37':'NOMINA','D38':'BANCA_DIGITAL','D39':'OPERACIONAL','D40':'REPORTERIA','D41':'OPERACIONAL',
    'D42':'ATENCION_CLIENTE','D43':'PAGOS_TRANSFERENCIAS','D44':'COBRANZA','D45':'OPERACIONAL',
    'D46':'OPERACIONAL','D47':'RIESGO_CREDITO','D48':'REGULATORIO','D49':'OPERACIONAL',
}

# ── Cargar vocabulario certificado ────────────────────────────────────────────
inv = json.loads(VOCAB_INV.read_text(encoding="utf-8"))
VOCAB = {}
for section in ("atomos", "compuestos"):
    for item in inv.get(section, []):
        VOCAB[item["term"]] = item

FIN_FROM_VOCAB = sorted(
    {t for t, v in VOCAB.items()
     if v.get("cat") in ("ENTIDAD", "METRICA") and v.get("nivel") in ("ALTA", "MEDIA") and len(t) >= 4},
    key=len, reverse=True)

BC_TERMS = {}
for t, v in VOCAB.items():
    bc = v.get("bc", "") or ""
    if bc and bc not in ("—", "-"):
        BC_TERMS[t] = (bc, v.get("bc_name", ""))
VOCAB_SET = set(VOCAB.keys())

def detect_vocab_refs(code_lower):
    found = []
    for t in VOCAB_SET:
        if len(t) >= 4 and re.search(r'\b' + re.escape(t) + r'\b', code_lower):
            found.append(t)
    return found[:8]

def tag_bc(vocab_refs):
    for t in vocab_refs:
        if t in BC_TERMS:
            return BC_TERMS[t]
    return ("", "")

# ── Clasificación regulatoria (idéntica a v2 + refs D17-D49) ──────────────────
REG_RULES = [
    (r"\bisr\b|imp_isr|tasa_isr|calc_isr",
     "SAT", "LISR Art.54/135 — retención ISR sobre intereses (tasa 2026 = 0.90% anual)"),
    (r"\biva\b|imp_iva|ivas\b|miva",
     "SAT", "LIVA — IVA sobre comisiones (16% / 8% frontera)"),
    (r"cfdi|retenciones|folio_fiscal|nomina.*cfdi",
     "SAT", "CFDI/Retenciones — folio fiscal por operación (SAT)"),
    (r"comis|comicob|cobracom|comi_",
     "CONDUSEF", "LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada en CONDUSEF"),
    (r"\bcat\b|costo_anual",
     "CONDUSEF", "LTOSF Art.17 — Costo Anual Total (fórmula IRR equivalente)"),
    (r"\bgat\b|ganancia_anual",
     "CONDUSEF", "LTOSF — Ganancia Anual Total (nominal/real)"),
    (r"aclaracion|disputa|queja|reclam|adeudo|monitorcob|cobranza|recupera",
     "CONDUSEF", "RECA/SAC — Reclamaciones y cobranza; protección al usuario"),
    (r"interes|calc_int|tasa|rendim|pagare|inversion|invers",
     "CNBV", "Criterios contables CNBV + GAT — cálculo de intereses/rendimientos"),
    (r"bitacora|_movhis|log_|_his\b|auditor|logifx",
     "CNBV", "Art.78 LIC — conservación de información 5 años (bitácoras y movimientos)"),
    (r"reserva|castigo|cartera_vencida|calif|scoring|principalcrd",
     "CNBV", "CUB B-5 — Reservas crediticias; calificación de cartera"),
    (r"buro|burofisic|consultaburo",
     "CNBV", "LRSIC — Buró de Crédito; evaluación crediticia (consentimiento LFPDPPP)"),
    (r"\bclabe\b|cuenta_clabe",
     "Banxico", "Circular Banxico — formato CLABE 18 dígitos (validación módulo-10)"),
    (r"spei_|clave_rastreo|cve_rastreo|transfer|domi_|domicil",
     "Banxico", "SPEI/Domiciliación Reglas técnicas — irrevocabilidad, clave rastreo, ventanas"),
    (r"tarjeta|_tc_|_td_|intercard|personaliza|emboza|plastico",
     "CNBV", "Disposiciones Únicas de Bancos — tarjetas de crédito y débito (Capítulo XI CUB)"),
    (r"garan|colateral|prenda",
     "CNBV", "Disposiciones Únicas de Bancos — garantías en operaciones de crédito (Circular B-6)"),
    (r"riesgo|var\b|exposicion|perdida_esperada",
     "CNBV", "CUB Circular B-5 — gestión integral de riesgos (crédito, mercado, operativo)"),
    (r"cuota.*ipab|ipab|4.?al.?millar|saldo_asegurado",
     "IPAB", "LPAB Art.22 — cuota 4 al millar; cobertura máx 400,000 UDIs por titular"),
    (r"tesofe|pago_gobierno|dispersion|pension|beca",
     "TESOFE", "LTF — concentración/dispersión de fondos gobierno; conciliación diaria"),
    (r"nomina|imss|sua|patronal",
     "IMSS", "IMSS/SAT — obligaciones de nómina, CFDI nómina y SUA"),
]
def clasifica(text):
    hits, seen = [], set()
    low = text.lower()
    for pat, reg, norma in REG_RULES:
        if re.search(pat, low) and reg not in seen:
            hits.append([reg, norma]); seen.add(reg)
    return hits

# ── Riesgos de equivalencia (v2 + base-año-variable + DBACCESS) ───────────────
def riesgo_equiv(expr, full_line=""):
    r = []
    e = expr.lower()
    if re.search(r"/\s*360\b", expr):   r.append("base 360 (año comercial) — verificar vs 365")
    if re.search(r"/\s*365\b", expr):   r.append("base 365 — verificar vs 360")
    if re.search(r"/\s*30\b", expr):    r.append("base 30 días/mes — verificar cálculo calendario")
    # base de año en VARIABLE (patrón D17-D49: /vaniobase, /v_anio, /diasanio)
    if re.search(r"/\s*v?_?(anio|anno|year|base_?anio|aniobase|dias_?anio|ndias_?anio)", e):
        r.append("base de año en variable — verificar 360 vs 365 (divergencia de intereses)")
    if "trunc" in e:                    r.append("TRUNC — Informix trunca; PostgreSQL puede redondear (divergencia centavos)")
    if re.search(r"\bround\b", e):      r.append("ROUND — validar modo (banker's vs half-up)")
    if "money" in e:                    r.append("MONEY — banker's rounding Informix; NUMERIC PostgreSQL diverge")
    # división monetaria genérica (pérdida de centavos)
    if re.search(r"/\s*[a-z_]*(monto|importe|saldo|total|capital)", e) and not r:
        r.append("DIV monetaria — posible pérdida de centavos; usar DECIMAL(18,4) + ROUND explícito")
    # DBACCESS shell exec con paths AIX
    if ("dbaccess" in e or "/resplogifx/" in full_line or "unload to" in e
            or re.search(r"vsql\s*=|vstmt\s*=", e)):
        r.append("DBACCESS — ejecución SQL externa vía shell; paths AIX (/resplogifx/, /ifxsif01/) muertos en target AWS/PostgreSQL")
    return r

# ── Patrones de extracción (idénticos a extract-rules-v2.py) ──────────────────
RE_CREATE = re.compile(r"create\s+(?:procedure|function)\b", re.I)
def isolate(t):
    ms = list(RE_CREATE.finditer(t))
    return t[ms[0].start():ms[1].start()] if len(ms) >= 2 else t

_BASE_FIN = ["int","isr","tasa","monto","saldo","comis","iva","cuota","dias","importe",
             "capital","rendim","gat","cat","sdo","abono","cargo","mora","interes",
             "reserva","provision","tir","van","pago","plazo","pagare","aforo","descuento"]
_VOCAB_FIN = [t for t in FIN_FROM_VOCAB if len(t) >= 4][:40]
_ALL_FIN = sorted(set(_BASE_FIN + _VOCAB_FIN), key=len, reverse=True)
FIN_PAT = "(" + "|".join(re.escape(t) for t in _ALL_FIN) + ")"

RE_FORMULA = re.compile(r"\b(?:let|set)\s+([a-z_][a-z0-9_]*)\s*=\s*(.+)", re.I)
RE_BOILERPLATE = re.compile(r"codret\s*=\s*['\"]0+['\"]", re.I)
RE_RAISE = re.compile(
    r"raise\s+exception|return\s+['\"]?\d{4,}|codret\s*=\s*['\"][1-9A-Z][A-Z0-9]{2,}['\"]"
    r"|retornar\s+['\"]?\d{3,}|v_?codret\s*[<>]+\s*['\"]|vcodret\s*=\s*['\"][1-9]", re.I)
RE_UMBRAL = re.compile(r"^\s*if\b.{0,80}" + FIN_PAT + r".{0,40}([<>]=?)\s*(\d{2,}(?:[.,]\d+)?)\b", re.I)
RE_ESTADO = re.compile(
    r"^\s*if\b.{0,60}\b(estatus|estado|tipo|clave|codest|codret|estado_cuenta|tipo_cuenta|"
    r"tipo_credito|tipo_mov|condicion|flag|stat|clase)\b.{0,30}(?:=\s*['\"][A-Z0-9]{1,4}['\"]|"
    r"\bin\s*\(['\"])", re.I)

def norm_expr(e):
    e = re.sub(r"\s+", " ", e).strip().rstrip(";")
    return e[:180]

def asigna_categoria(sp, code, tipo, regs, dom_code):
    if regs:                    return "REGULATORIO"
    if tipo == "FÓRMULA":       return "CALCULO_FINANCIERO"
    return CAT_DOM.get(dom_code, "OPERACIONAL")

def build_bn(tipo, sp, code):
    # ADR-SPE-AM-010: el extractor nunca genera business_name.
    # La síntesis LLM es la única fuente del campo — se aplica post-extracción sobre todas las clases.
    return ""

# ── Candidatos: SOLO D17-D49 ──────────────────────────────────────────────────
PRE_FILTER = ("let ","set ","raise exception","return ","if ","while ",
    "interes","tasa","saldo","monto","importe","comis","isr","iva","gat","spei",
    "clabe","reserva","bitacora","cartera","mora","cobro","pago","cuota",
    "money","decimal","trunc","round","dbaccess","pagare","inversion")

cand = []
for fn in sorted(os.listdir(SRC)):
    if not fn.endswith(".sql"):
        continue
    db, _, sp = fn[:-4].partition("_")
    if sp and db in D17_DBS:
        cand.append((db, sp, str(SRC / fn)))
print(f"  Archivos D17-D49 a escanear: {len(cand)}")

# ── Extracción ────────────────────────────────────────────────────────────────
rules = []
rid = 0
seen_f = set(); seen_v = set(); seen_u = set(); seen_e = set()
n_scanned = n_pre = 0

for db, sp, fp in cand:
    try:
        raw = open(fp, "rb").read(8192).lower()
        if not any(pf.encode() in raw for pf in PRE_FILTER):
            n_pre += 1; continue
    except Exception:
        continue
    n_scanned += 1
    try:
        txt = isolate(open(fp, encoding="utf-8", errors="replace").read())
    except Exception:
        continue

    dom_label = DOMN.get(db, db)
    dom_code  = DOMN_CODE.get(db, db)
    v_val = 0

    for i, rawln in enumerate(txt.split("\n"), 1):
        s = rawln.strip()
        if not s or s.startswith("--"):
            continue
        sl = s.lower()

        # FÓRMULA
        # ADR-SPE-AM-010: excluir RHS string literal — '/' en paths dispara [*/] falsamente.
        m = RE_FORMULA.match(s)
        _rhs_d = m.group(2).strip() if m else ""
        if (m and re.search(r"[*/]", _rhs_d) and re.search(FIN_PAT, s, re.I)
                and not _rhs_d.startswith(("'", '"'))):
            expr = norm_expr(m.group(1) + " = " + m.group(2))
            key = (db, sp, re.sub(r"\d", "#", expr))
            if key not in seen_f:
                seen_f.add(key)
                regs = clasifica(sp + " " + expr)
                vr = detect_vocab_refs(sl); bc, bcn = tag_bc(vr)
                rid += 1
                rules.append({"tipo":"FÓRMULA","sp":sp,"db":db,"line":i,"code":expr,
                    "reg":regs,"riesgo":riesgo_equiv(m.group(2), s),"bc":bc,"bc_name":bcn,
                    "vocab_refs":vr,"dominio":dom_label,"dom_code":dom_code,
                    "categoria":asigna_categoria(sp,expr,"FÓRMULA",regs,dom_code),
                    "business_name":build_bn("FÓRMULA",sp,expr)})

        # VALIDACIÓN
        if RE_RAISE.search(s) and not RE_BOILERPLATE.search(s) and v_val < 5:
            key = (db, sp, re.sub(r"\d", "#", s[:80]))
            if key not in seen_v:
                seen_v.add(key)
                regs = clasifica(sp + " " + s)
                vr = detect_vocab_refs(sl); bc, bcn = tag_bc(vr)
                rid += 1; v_val += 1
                code = norm_expr(s)
                rules.append({"tipo":"VALIDACIÓN","sp":sp,"db":db,"line":i,"code":code,
                    "reg":regs,"riesgo":riesgo_equiv(s, s),"bc":bc,"bc_name":bcn,
                    "vocab_refs":vr,"dominio":dom_label,"dom_code":dom_code,
                    "categoria":asigna_categoria(sp,s,"VALIDACIÓN",regs,dom_code),
                    "business_name":build_bn("VALIDACIÓN",sp,code)})

        # UMBRAL
        mu = RE_UMBRAL.match(s)
        if mu:
            expr = norm_expr(s)
            key = (db, sp, re.sub(r"\d", "#", expr))
            if key not in seen_u:
                seen_u.add(key)
                regs = clasifica(sp + " " + expr)
                vr = detect_vocab_refs(sl); bc, bcn = tag_bc(vr)
                rid += 1
                rules.append({"tipo":"UMBRAL","sp":sp,"db":db,"line":i,"code":expr,
                    "reg":regs,"riesgo":riesgo_equiv(s, s),"bc":bc,"bc_name":bcn,
                    "vocab_refs":vr,"dominio":dom_label,"dom_code":dom_code,
                    "categoria":asigna_categoria(sp,expr,"UMBRAL",regs,dom_code),
                    "business_name":build_bn("UMBRAL",sp,expr)})

        # ESTADO
        if RE_ESTADO.match(s):
            expr = norm_expr(s)
            key = (db, sp, expr[:80])
            if key not in seen_e:
                seen_e.add(key)
                regs = clasifica(sp + " " + expr)
                vr = detect_vocab_refs(sl); bc, bcn = tag_bc(vr)
                rid += 1
                rules.append({"tipo":"ESTADO","sp":sp,"db":db,"line":i,"code":expr,
                    "reg":regs,"riesgo":[],"bc":bc,"bc_name":bcn,
                    "vocab_refs":vr,"dominio":dom_label,"dom_code":dom_code,
                    "categoria":asigna_categoria(sp,expr,"ESTADO",regs,dom_code),
                    "business_name":build_bn("ESTADO",sp,expr)})

print(f"  Escaneados: {n_scanned} (pre-filtro descartó {n_pre})")

# ── Estadísticas ──────────────────────────────────────────────────────────────
by_tipo = Counter(r["tipo"] for r in rules)
by_reg  = Counter(x for r in rules for x, _ in r["reg"])
n_reg   = sum(1 for r in rules if r["reg"])
n_ries  = sum(1 for r in rules if r["riesgo"])
by_dom  = Counter(r["dom_code"] for r in rules)

print(f"\n  Reglas ricas extraídas: {len(rules)}")
for t in ("FÓRMULA","VALIDACIÓN","UMBRAL","ESTADO"):
    print(f"    {t:<12}: {by_tipo.get(t,0)}")
print(f"    Con reg      : {n_reg} ({n_reg*100//len(rules) if rules else 0}%)")
print(f"    Con riesgo   : {n_ries} ({n_ries*100//len(rules) if rules else 0}%)")
print(f"    Reguladores  : " + " · ".join(f"{k}:{v}" for k,v in by_reg.most_common()))

# ── Reemplazar D17-D49 en v3.json ─────────────────────────────────────────────
print("\n-- Reemplazando D17-D49 en v3.json --")
v3 = json.loads(V3.read_text(encoding="utf-8"))
old_rules = v3["rules"]
# Conservar solo D01-D16 (dominio NO empieza en D17-D49)
DOM_D17_RE = re.compile(r"^D(1[7-9]|[2-4]\d)\b")
kept = [r for r in old_rules if not DOM_D17_RE.match(str(r.get("dominio","")))]
n_removed = len(old_rules) - len(kept)
print(f"  Removidas reglas crudas D17-D49: {n_removed}")

# Asignar IDs BR-V3 a las nuevas reglas ricas
max_seq = 0
for r in kept:
    mm = re.search(r'V\d+-(\d+)$', r.get("id",""))
    if mm: max_seq = max(max_seq, int(mm.group(1)))
seq = max_seq
new_entries = []
brain_rows = []   # (id, tipo, sp, db, domain, line, code, reg_json, riesgo_json, bn)
for r in rules:
    seq += 1
    rid_str = f"BR-V3-{seq:05d}"
    reg_json    = json.dumps(r["reg"], ensure_ascii=False)
    riesgo_json = json.dumps(r["riesgo"], ensure_ascii=False)
    new_entries.append({
        "id":rid_str,"tipo":r["tipo"],"sp":r["sp"],"db":r["db"],"line":r["line"],
        "code":r["code"],"reg":r["reg"],"riesgo":r["riesgo"],"bc":r["bc"],"bc_name":r["bc_name"],
        "business_name":r["business_name"],"categoria":r["categoria"],
        "explicacion":r["business_name"],"expl_conf":"extract-v2-d17d49",
        "dominio":r["dominio"],"sp_rel":{"callees":[],"callers":[]},
        "vocab_detail":[],"vocab_refs":r["vocab_refs"],
    })
    brain_rows.append((rid_str, r["tipo"], f"{r['db']}:{r['sp']}", r["db"], r["dom_code"],
                       r["line"], r["code"], reg_json, riesgo_json, r["business_name"]))

v3["rules"] = kept + new_entries
v3.setdefault("meta", {})["total_rules"] = len(v3["rules"])
V3.write_text(json.dumps(v3, ensure_ascii=False, indent=2), encoding="utf-8")
print(f"  v3.json: {len(v3['rules'])} reglas ({len(kept)} D01-D16 + {len(new_entries)} D17-D49 ricas)")

# ── Reemplazar D17-D49 en brain.db ────────────────────────────────────────────
print("\n-- Reemplazando D17-D49 en brain.db --")
con = sqlite3.connect(DB)
cur = con.cursor()
n_del = cur.execute("DELETE FROM rules WHERE domain BETWEEN 'D17' AND 'D49'").rowcount
con.commit()
print(f"  Reglas crudas borradas de brain.db: {n_del}")
cur.executemany(
    "INSERT INTO rules (id, tipo, sp, db, domain, line, code, reg, riesgo, business_name) "
    "VALUES (?,?,?,?,?,?,?,?,?,?)", brain_rows)
con.commit()
print(f"  Reglas ricas insertadas: {len(brain_rows)}")

# Actualizar rules_n por SP (rules.sp usa formato db:name, igual que D01-D16)
cur.execute("""
    UPDATE sps SET rules_n = (
        SELECT COUNT(*) FROM rules
        WHERE rules.sp = sps.db || ':' || sps.name AND rules.db = sps.db
    ) WHERE domain BETWEEN 'D17' AND 'D49'
""")
con.commit()
con.close()

print(f"\n  Siguiente: python generators/gen-rules-portal.py")
print("Done.")
