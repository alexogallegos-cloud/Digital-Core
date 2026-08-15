#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-vocab-report-v2.py — Genera vocabulary-catalog-bcop.CANDIDATE.html
v2: añade dimensión Bounded Context, panel de Aggregate Roots, capas del
Gemelo Cognitivo y filtro BC en el explorador.
Output: portal/vocabulary-catalog-bcop.CANDIDATE.html
        Revisar y renombrar a vocabulary-catalog-bcop.html para promover.

Consume: vocabulary-inventory.json (de build-vocab-inventory.py)
Etapa 3 — Business Logic Extraction · Specialist Informix SPL · SPE-AM-001
"""
import json
import sys
import re as _re
import csv as _csv
from collections import Counter
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
INV  = json.load(open(BASE / "knowledge-base" / "vocabulary-inventory.json", encoding="utf-8"))

# ── scope autoritativo desde brain.db ──
import sqlite3 as _sq
_bdb = _sq.connect(str(BASE / "digital-brain" / "brain.db"))
_SCOPE_DB = {r[0]: r[1] for r in _bdb.execute("SELECT term, scope FROM terms")}
_bdb.close()

# ── tipo y mascara desde ola-c-tipos-result.csv (Ola C) ──
_TIPO_DB = {}
_csv_path = BASE / "generators" / "ola-c-tipos-result.csv"
if _csv_path.exists():
    with open(_csv_path, encoding="utf-8") as _f:
        for _row in _csv.DictReader(_f):
            _TIPO_DB[_row["term"]] = (_row["tipo"] or "?", _row["mascara"] or "?")

# ── fila unificada para la tabla ──
rows = []
for r in INV["atomos"]:
    rows.append({**r, "tipo": "atómico"})
for r in INV["compuestos"]:
    rows.append({**r, "tipo": "compuesto"})
for c in INV["candidatos"]:
    rows.append({"term": c["frag"], "cat": "?", "mean": "(sin clasificar)", "est": "-",
                 "nivel": "CANDIDATO", "fn": c["frec"], "fp": 0, "deco": "", "tipo": "candidato",
                 "scope": "—"})
for r in rows:
    r.setdefault("scope", "—")
    if r["term"] in _SCOPE_DB and _SCOPE_DB[r["term"]] not in ("—", "", None):
        r["scope"] = _SCOPE_DB[r["term"]]
    # tipo/mascara desde brain.db (Ola C)
    _td = _TIPO_DB.get(r["term"], ("?", "?"))
    r["tipo_dato"]  = _td[0]
    r["mascara"]    = _td[1]
    r.setdefault("dominio_as_is", None)
    r.setdefault("target_term", None)
    r.setdefault("regulatorio", None)
    r.setdefault("nodo_taxonomia", None)
    r.setdefault("es_variante_de", None)
    r.setdefault("tipo_relacion", None)
    r.setdefault("capa_gemelo", "Capa 1")
    r.setdefault("estado", "ACTIVO")
    r.setdefault("validado_por", None)
    r.setdefault("notas_sme", None)

_sin_scope = sum(1 for r in rows if r.get("scope", "—") == "—")
if _sin_scope > len(rows) * 0.8:
    print(f"\n⚠️  ADVERTENCIA: {_sin_scope}/{len(rows)} términos SIN scope.\n"
          f"   Córrelo primero: python3 extract-dataflow.py\n", file=sys.stderr)

# ── fuente de validación ──
BIZ = _re.compile(r"bancoppel|afore|banxico|condusef|western|moneygram|coppel|codi|spei|"
                  r"clabe|comprobante|banca por internet|art\.61|reco|domiciliaci|remesa|"
                  r"quincena|oxxo|hipotec|préstamo|prestamo|inversión|msi|cep|rastreo|udi|cat |gat", _re.I)
def fuente(r):
    m = (r.get("mean") or "").lower()
    if "confirmado sme" in m or "sme" in m:   return "SME"
    if BIZ.search(m):                          return "NEGOCIO"
    if r.get("fp", 0) >= 5:                   return "CODIGO"
    if r.get("est") == "conf":                return "CONVENCION"
    if r.get("est") == "inf":                 return "INFERIDO"
    return "AMBIGUO"
for r in rows:
    r["fuente"] = fuente(r)

# ── Split: términos que trascienden vs. efímeros ──
# Regla: scope EFIMERA/EFIMERA-CALCULO siempre van a efímero.
# scope '—' (sin clasificar) va a efímero SOLO si es átomo — los compuestos
# con scope '—' son términos confiables sin clasificar, van al Vocabulario principal.
_EFIM_SCOPE = {'EFIMERA', 'EFIMERA-CALCULO'}
def _is_efim(r):
    return r.get('scope', '—') in _EFIM_SCOPE
_EFIM = {'EFIMERA', 'EFIMERA-CALCULO', '—'}  # kept for N_EFIM_DASH calc
rows_main = [r for r in rows if not _is_efim(r)]
rows_efim = [r for r in rows if _is_efim(r)]
# Todas las métricas del tab "Vocabulario" operan sobre rows_main
rows = rows_main  # reasignar para que el resto del código use rows_main

# ── métricas base ──
byniv  = Counter(r["nivel"] for r in rows)
bycat  = Counter(r["cat"]   for r in rows if r["cat"] != "?")
bytipo = Counter(r["tipo"]  for r in rows)
byfte  = Counter(r["fuente"] for r in rows)
meta   = INV["meta"]

# ── sinónimos / alias (mismo algoritmo que v1) ──
elig = [r for r in rows if r["cat"] not in ("AMBIGUO", "?") and r.get("est") not in ("gap", "-")]
by_term = {r["term"]: r for r in elig}
parent  = {t: t for t in by_term}
def _find(x):
    while parent[x] != x: parent[x] = parent[parent[x]]; x = parent[x]
    return x
def _union(a, b):
    ra, rb = _find(a), _find(b)
    if ra != rb: parent[ra] = rb
_mg = {}
for r in elig:
    key = _re.sub(r"[^a-z0-9 ]", "", (r.get("mean") or "").lower().split("(")[0].split(" / ")[0]).strip()
    if key and key != "sin clasificar": _mg.setdefault(key, []).append(r["term"])
for _ts in _mg.values():
    for _t in _ts[1:]: _union(_ts[0], _t)
for _t, _r in by_term.items():
    for _pl in (_t + "s", _t + "es"):
        if _pl in by_term and by_term[_pl]["cat"] == _r["cat"]: _union(_t, _pl)
_comp = {}
for _t in parent: _comp.setdefault(_find(_t), []).append(_t)
_clusters = {root: [by_term[t] for t in ts] for root, ts in _comp.items() if len(ts) > 1}
def _isplural(t, gs):
    return (t.endswith("s") and t[:-1] in gs) or (t.endswith("es") and t[:-2] in gs)
ANGLICISMOS = {"status", "mail", "email", "update", "insert", "delete", "select",
               "flag", "check", "log", "user", "account", "client", "payment",
               "transfer", "balance", "amount", "name", "date", "report"}
def _cscore(x, gs):
    t = x["term"]
    limpio = 0 if (t[-1:].isdigit() or _isplural(t, gs)) else 1
    espanol = 0 if t in ANGLICISMOS else 1
    return (limpio, espanol, len(t), (x.get("fp") or 0) + (x.get("fn") or 0))
canon = {}; canon_key = {}
for root, terms in _clusters.items():
    gs = {x["term"] for x in terms}
    c  = max(terms, key=lambda x: _cscore(x, gs))
    canon_key[root] = c["term"]
    for t in terms:
        if t["term"] != c["term"]: canon[t["term"]] = c["term"]
n_concepts  = len(_clusters)
n_alias     = sum(len(v) for v in _clusters.values())
n_collapsed = sum(len(v) - 1 for v in _clusters.values())
n_canonical = len(rows) - n_collapsed
_surv = [r for r in rows if r["term"] not in canon]
byniv_u  = Counter(r["nivel"] for r in _surv)
bycat_u  = Counter(r["cat"]   for r in _surv if r["cat"] != "?")
bytipo_u = Counter(r["tipo"]  for r in _surv)
byfte_u  = Counter(r["fuente"] for r in _surv)
_alias = {}; _tg = {}
for root, terms in _clusters.items():
    g = sorted(t["term"] for t in terms)
    for t in terms:
        _alias[t["term"]] = {"g": g, "c": canon_key[root]}; _tg[t["term"]] = len(g)
for r in rows:
    r["nalias"] = _tg.get(r["term"], 0)
ALIASES = json.dumps(_alias, ensure_ascii=False)

# ── BIAN (mismo que v1) ──
BIAN = [
 ("Cliente / Party",         r"cliente|\bcte\b|apoderad|beneficiari|persona|contacto|domicili|tel[eé]fon|celular|correo|\bfirma"),
 ("Cuentas y Depósitos",     r"cuenta|saldo|dep[oó]sito|captaci|chequera|cheque|disponible|cuentahab|apertura|\bbym\b|piezas"),
 ("Cobranza y Recuperación", r"cobranz|recuperaci|reestructur|refinanci|moratori|quebranto|\bmora\b|castigo|\bciloc|frecpago|adeud|promesa"),
 ("Pagos y Transferencias",  r"spei|\bpago|transferen|\borden\b|abono|cargo|clabe|rastreo|codi|dispersi|remesa|domiciliaci|traspaso"),
 ("Tarjetas",                r"tarjeta|\btdc\b|pl[aá]stico|\bcvv\b|intercard|\bn[ií]p\b|token"),
 ("Crédito y Préstamos",     r"cr[eé]dito|\bcred\b|pr[eé]stamo|pagar[eé]|amortiza|\bcuota|\bl[ií]nea|scoring|califica|bur[oó]|\bmsi\b|plazo|inter[eé]s|\bgat\b|\bcat\b|rendim"),
 ("Canales y Digital",       r"canal|\bweb\b|m[oó]vil|\bbpi\b|cajero|\batm\b|sucursal|\bapp\b|clic|banca por internet|kiosko"),
 ("Contabilidad y Finanzas", r"contab|p[oó]liza|\bmayor\b|asiento|\bpase\b|c[eé]dula|balance|cnsif|conciliaci|devengo"),
 ("Riesgo y Cumplimiento",   r"regulat|\bpld\b|lavado|\bisr\b|\biva\b|cnbv|art\.?\s*61|fiscal|ipab|tesofe|condusef|banxico|beneficencia|inactiv"),
 ("Servicing y Operaciones", r"aclaraci|solicitud|mensaj|notificaci|alerta|\bfolio\b|tr[aá]mite|reverso|cancelaci"),
 ("Datos de Referencia",     r"cat[aá]logo|\btabla|c[oó]digo|codificaci|\btipo\b|denominaci|\bclave\b|par[aá]metro|producto"),
]
def bian_of(r):
    s = (r["term"] + " " + (r.get("mean") or "")).lower()
    for name, pat in BIAN:
        if _re.search(pat, s): return name
    return "Transversal / Técnico"
for r in rows: r["bian"] = bian_of(r)
bybian = Counter(r["bian"] for r in rows)

# ── NEW v2+: Unit detection ──
NA_CATS = {"PREFIJO", "ACCION", "MODIF", "REG"}
UNIT_PATS = [
    ("MXN",   r"monto|importe|saldo\b|capital\b|adeudo|cargo\b|abono\b|pago\b|cuota|inter[eé]s|comisi[oó]n|quebranto|castigo|costo\b|precio\b|\bvalor\b|saldoantes|saldodespues|disponible\b|adeudo|deuda\b|rendimiento\b"),
    ("USD",   r"\bdol\b|\busd\b|d[oó]lar"),
    ("PCT",   r"\btasa\b|porcentaje|rendimiento\b.*%|tasa.*inter|interes.*%"),
    ("RATIO", r"\bfactor\b(?!ia)|coeficiente|multiplicador"),
    ("COUNT", r"\bcantidad\b|conteo|secuencia|consecutivo|\btotal.*sp|\bnum[_ ]"),
    ("DIAS",  r"\bd[ií]as?\b|plazo.*d[ií]a|vencimiento\b"),
    ("MESES", r"\bmes(?:es)?\b(?!aje)"),
    ("ID",    r"clabe|clave bancaria|clave estandar|n[uú]mero de cuenta|n[uú]mero de (cr[eé]dito|tarjeta|cliente)|folio\b|c[oó]digo\b|referencia\b|identificador"),
    ("BOOL",  r"bandera|flag|activo\b|inactivo\b|vigente\b|bloqueado\b|\baplica\b"),
    ("TEXT",  r"\bnombre\b|descripci[oó]n|mensaje\b|leyenda\b|texto\b"),
]
def unit_of(row):
    if row.get("cat") in NA_CATS:
        return "N/A"
    s = ((row.get("term") or "") + " " + (row.get("mean") or "")).lower()
    for unit, pat in UNIT_PATS:
        if _re.search(pat, s):
            return unit
    return "MIXTO" if row.get("cat") in ("ENTIDAD","AMBIGUO") else "N/A"

for r in rows:
    r["unit"] = unit_of(r)

byunit = Counter(r["unit"] for r in rows if r["unit"] != "N/A")

# ── NEW v2: Bounded Context dimension ──
BIAN_TO_BC = {
    "Cliente / Party":         ("BC-7.1",  "Customer"),
    "Cuentas y Depósitos":     ("BC-3.2",  "Accounts"),
    "Cobranza y Recuperación": ("BC-3.3",  "Lending"),
    "Pagos y Transferencias":  ("BC-3.4",  "Payments"),
    "Tarjetas":                ("BC-3.5",  "Cards"),
    "Crédito y Préstamos":     ("BC-3.3",  "Lending"),
    "Canales y Digital":       ("BC-1.x",  "Channels"),
    "Contabilidad y Finanzas": ("BC-5.4",  "Finance"),
    "Riesgo y Cumplimiento":   ("BC-5.8",  "AML/Risk"),
    "Servicing y Operaciones": ("BC-3.18", "Disputes"),
    "Datos de Referencia":     ("BC-4.x",  "Ref.Data"),
    "Transversal / Técnico":   ("—",       "Transversal"),
}
BC_LABELS = {
    "BC-7.1":  "Customer Management",
    "BC-3.2":  "Accounts & Deposits",
    "BC-3.3":  "Lending & Cobranza",
    "BC-3.4":  "Payments (SPEI+TEF)",
    "BC-3.5":  "Cards",
    "BC-1.x":  "Channels",
    "BC-5.4":  "Finance",
    "BC-5.8":  "AML / Risk",
    "BC-3.18": "Disputes",
    "BC-4.x":  "Reference Data",
}

# ── NEW v2: Aggregate Roots ──
AGGREGATE_ROOTS = {
    "cliente": "BC-7.1", "cte": "BC-7.1", "ctes": "BC-7.1",
    "numcliente": "BC-7.1", "numcte": "BC-7.1",
    "cuenta": "BC-3.2", "cta": "BC-3.2", "ctas": "BC-3.2", "numcuenta": "BC-3.2",
    "credito": "BC-3.3", "cred": "BC-3.3", "numcredito": "BC-3.3",
    "folio": "BC-3.4", "pago": "BC-3.4",
    "tarjeta": "BC-3.5", "tdc": "BC-3.5", "tdd": "BC-3.5", "numtarjeta": "BC-3.5",
    "poliza": "BC-5.4", "asiento": "BC-5.4",
    "aclaracion": "BC-3.18",
    "alerta": "BC-5.8", "pld": "BC-5.8",
}

for r in rows:
    bc_pair = BIAN_TO_BC.get(r.get("bian", ""), ("—", "Transversal"))
    r["bc"]      = bc_pair[0]
    r["bc_name"] = bc_pair[1]
    r["is_root"] = 1 if r["term"] in AGGREGATE_ROOTS else 0
    r["root_bc"] = AGGREGATE_ROOTS.get(r["term"], "")

bybc = Counter(r["bc"] for r in rows if r["bc"] != "—")

# ── ER diagram (mismo que v1) ──
try:
    _CG = json.load(open(BASE + "portal/data/callgraph-data.json", encoding="utf-8"))
    _cgn = _CG["graph"]["nodes"]; _cge = _CG["graph"].get("edges", _CG["graph"].get("links", []))
except Exception:
    _cgn, _cge = [], []
def _bian_name(nm):
    s = nm.lower()
    for name, pat in BIAN:
        if _re.search(pat, s): return name
    return "Transversal / Técnico"
_ndom = {}
for nd in _cgn:
    nid = nd.get("id", ""); nm = nid.split(":", 1)[1] if ":" in nid else nid
    _ndom[nid] = _bian_name(nm)
_ew = Counter()
for e in _cge:
    a = _ndom.get(e.get("from")); b = _ndom.get(e.get("to"))
    if a and b and a != b and "Transversal / Técnico" not in (a, b):
        _ew[tuple(sorted([a, b]))] += 1
EID = {"Cliente / Party": "CLIENTE", "Cuentas y Depósitos": "CUENTAS", "Pagos y Transferencias": "PAGOS",
       "Tarjetas": "TARJETAS", "Crédito y Préstamos": "CREDITO", "Cobranza y Recuperación": "COBRANZA",
       "Canales y Digital": "CANALES", "Contabilidad y Finanzas": "CONTABILIDAD",
       "Riesgo y Cumplimiento": "RIESGO", "Servicing y Operaciones": "SERVICING",
       "Datos de Referencia": "DATOS_REF"}
_datt = {}
for r in sorted(rows, key=lambda x: -((x.get("fp") or 0) + (x.get("fn") or 0))):
    d = r.get("bian")
    if d in EID and r["cat"] in ("ENTIDAD", "ACCION", "REG"):
        lst = _datt.setdefault(d, [])
        raw = canon.get(r["term"], r["term"])
        t = _re.sub(r"[^a-z0-9_]", "", raw.lower())
        if len(lst) < 10 and t and t not in [a[1] for a in lst]:
            cn = {"ENTIDAD": "entidad", "ACCION": "accion", "REG": "regulatorio"}.get(r["cat"], "term")
            lst.append((cn, t))
_er = ["erDiagram"]
for dom, eid in EID.items():
    _er.append("  " + eid + " {")
    for c, t in (_datt.get(dom) or [("dominio", eid.lower())]):
        _er.append("    " + c + " " + t)
    _er.append("  }")
for (a, b), c in _ew.most_common(14):
    _er.append('  ' + EID[a] + ' }o--o{ ' + EID[b] + ' : "' + str(c) + '"')
ERDIAG = "\n".join(_er)

# ── hallazgos ──
pct_alta = round(100 * byniv.get("ALTA", 0) / len(rows)) if rows else 0
_biz = [(n, v) for n, v in bybian.most_common() if n != "Transversal / Técnico"]
_tec = bybian.get("Transversal / Técnico", 0)
pct_biz = round(100 * sum(v for _, v in _biz) / len(rows)) if rows else 0
n_roots = sum(1 for r in rows if r["is_root"])
H_cards = [
 ("El léxico del negocio",
  f"El core habla <b>{len(rows)} términos</b> — {bytipo['atómico']} atómicos y {bytipo['compuesto']} compuestos — destilados de {meta['sps']:,} SPs en 16 dominios D01-D16. Es el idioma del negocio fosilizado en el código Informix."),
 ("Bounded Contexts del target",
  f"<b>{len(BC_LABELS)} Bounded Contexts</b> identificados en el modelo lógico. Los 8 <b>Aggregate Roots</b> ({n_roots} variantes AS-IS) deben converger en identificadores canónicos únicos — la principal deuda semántica de la arquitectura."),
 ("Deuda semántica por resolver",
  f"<b>{byfte.get('AMBIGUO', 0)} términos ambiguos</b> + {bytipo['candidato']} candidatos sin clasificar. Los {n_alias} términos con alias colapsan a ~<b>{n_canonical} conceptos únicos</b> con forma canónica (completa singular)."),
 ("Contribuciones de los 6 DTs peer",
  f"El vocabulario de Capa 1 (sp_vocab) se enriquece con capas superiores del Gemelo Cognitivo: <b>16 almas</b> (módulos), <b>131 journeys</b> (procesos), <b>1,308 reglas</b> (condiciones SBVR) y <b>23 BCs</b> (modelo lógico). Juntos completan el cuadro semántico."),
]
HALLAZGOS_H = "".join(f'<div class="hcard"><div class="hn">{n}</div>{t}</div>' for n, t in H_cards)

# ── hero de enriquecimiento ──
_n_total_vocab = len(rows)
_n_alta  = byniv.get("ALTA",  0)
_n_media = byniv.get("MEDIA", 0)
_n_amb   = byniv.get("AMBIGUA", 0)
_pct_a   = round(100 * _n_alta  / _n_total_vocab) if _n_total_vocab else 0
_pct_m   = round(100 * _n_media / _n_total_vocab) if _n_total_vocab else 0
_pct_b   = 100 - _pct_a - _pct_m
_bar_a   = f'<div class="qbar-seg" style="width:{_pct_a}%;background:#22c55e" title="ALTA {_pct_a}%"></div>'
_bar_m   = f'<div class="qbar-seg" style="width:{_pct_m}%;background:#f59e0b" title="MEDIA {_pct_m}%"></div>'
_bar_b   = f'<div class="qbar-seg" style="width:{_pct_b}%;background:#ef4444" title="AMBIGUA {_pct_b}%"></div>' if _pct_b else ''
ENRICH_HERO_H = f"""
<div class="enrich-hero">
  <div class="eh-body">
    <div class="eh-left">
      <div class="eh-label">Calidad del vocabulario</div>
      <div class="eh-pct">{_pct_a}<span class="eh-sym">%</span></div>
      <div class="eh-sub"><b>{_n_alta}</b> de {_n_total_vocab} términos con confianza ALTA</div>
      <div class="qbar">{_bar_a}{_bar_m}{_bar_b}</div>
      <div class="qbar-legend">
        <span><span class="ql-dot" style="background:#22c55e"></span>ALTA {_n_alta}</span>
        <span><span class="ql-dot" style="background:#f59e0b"></span>MEDIA {_n_media}</span>
        <span><span class="ql-dot" style="background:#ef4444"></span>AMBIGUA {_n_amb}</span>
      </div>
    </div>
    <div class="eh-sep"></div>
    <div class="eh-right">
      <div class="eh-ola-label">Olas de enriquecimiento</div>
      <div class="ola-row done"><span class="ola-badge">A</span><span class="ola-desc">Limpieza — <b>−38 términos</b> (ruido, infinitivos, sinónimos)</span><span class="ola-check">✓</span></div>
      <div class="ola-row done"><span class="ola-badge">B</span><span class="ola-desc">Confianza — <b>+77 upgrades</b> inf/gap → conf · ALTA: 552 → {_n_alta}</span><span class="ola-check">✓</span></div>
      <div class="ola-row done"><span class="ola-badge">C</span><span class="ola-desc">Tipos — <b>631 términos</b> con tipo (NUM/ALFA/FECHA) desde 12K archivos SQL</span><span class="ola-check">✓</span></div>
      <div class="ola-row done"><span class="ola-badge">D</span><span class="ola-desc">Definiciones — <b>10 términos</b> enriquecidos desde código AS-IS (SPs más llamados)</span><span class="ola-check">✓</span></div>
    </div>
  </div>
</div>"""

# ── log de enriquecimiento ──
ENRICH_LOG = [
  {"fecha": "2026-08-04", "ola": "C", "titulo": "Tipos de dato desde código AS-IS",
   "items": ["Escaneo de 12,881 archivos SQL — 70,766 nombres de variable indexados",
             "631 términos clasificados: 268 ALFA · 196 NUM · 30 FECHA · 1 BOOL · 143 N/A (ACCION/REG)",
             "Mascara = tipo Informix exacto del código (e.g. DECIMAL(18,2), CHAR(20), DATE)",
             "Script: generators/ola-c-tipos.py · evidencia: ola-c-tipos-result.csv"]},
  {"fecha": "2026-08-04", "ola": "D", "titulo": "Enriquecimiento desde código AS-IS",
   "items": ["10 definiciones reescritas desde el cuerpo de los SPs más llamados por término",
             "Fuente: código SPL real (fan_in como proxy de relevancia de negocio)",
             "Términos: consulta · valida · actualiza · genera · cred · spei · inserta · depura · dicta · estatus",
             "Evidencia representativa: sp_consulta_saldos_general (fi=435) — 47 campos snapshot crédito"]},
  {"fecha": "2026-08-04", "ola": "B", "titulo": "Upgrade de confianza",
   "items": [f"82 términos inf/gap → conf en sp_vocab.py",
             f"79 actualizaciones en brain.db",
             f"Confianza ALTA: 552 → {_n_alta} (+{_n_alta-552})",
             "Criterio: ≥10 SPs de evidencia o ≥3 reglas/journeys"]},
  {"fecha": "2026-08-04", "ola": "A", "titulo": "Limpieza del vocabulario",
   "items": ["−38 tokens: 23 sin evidencia + 1 typo + 8 infinitivos + 6 sinónimos/duplicados",
             "sp_vocab.py: 663 → 626 términos",
             "brain.db: 32 entradas eliminadas de terms table",
             "Sinónimos canónicos: status→estatus · valid→valida · tc→tdc · mvl→movil · numcliente/numerocliente→numcte"]},
]
def _log_item(e):
    ola_cls = "log-done" if e["ola"] in ("A","B") else "log-pend"
    items_h = "".join(f'<li>{i}</li>' for i in e["items"])
    return (f'<div class="log-entry {ola_cls}">'
            f'<div class="log-meta"><span class="log-ola">{e["ola"]}</span>'
            f'<span class="log-fecha">{e["fecha"]}</span></div>'
            f'<div class="log-titulo">{e["titulo"]}</div>'
            f'<ul class="log-items">{items_h}</ul></div>')
ENRICH_LOG_H = '<div class="enrich-log">' + "".join(_log_item(e) for e in ENRICH_LOG) + '</div>'

# ── BIAN bars ──
_bmax = max((v for _, v in _biz), default=1) or 1
BIANBARS_H = "".join(
 f'<div class="bianrow"><div class="bl">{n}</div><div class="bbar"><i class="{"top" if i==0 else ""}" '
 f'style="width:{round(100*v/_bmax)}%"></i></div><div class="bv">{v}</div></div>'
 for i, (n, v) in enumerate(_biz))
BIANBARS_H += (f'<div class="bianrow tec"><div class="bl">Transversal / Técnico</div>'
 f'<div class="btec">léxico genérico — verbos, prefijos y términos técnicos usados en todos los dominios</div>'
 f'<div class="bv">{_tec}</div></div>')

# ── NEW v2: BC bars ──
_bcmax = max(bybc.values(), default=1) or 1
BCBARS_H = "".join(
    f'<div class="bianrow">'
    f'<div class="bl"><b>{bc}</b> — {BC_LABELS.get(bc, bc)}</div>'
    f'<div class="bbar"><i class="{"top" if i == 0 else ""}" style="width:{round(100*v/_bcmax)}%"></i></div>'
    f'<div class="bv">{v}</div>'
    f'</div>'
    for i, (bc, v) in enumerate(sorted(bybc.items(), key=lambda x: -x[1]))
)

# ── NEW v2: Aggregate Roots panel ──
ROOT_INFO = [
    ("BC-7.1",  "cliente",    "Cliente",              ["cte", "ctes", "numcliente", "numcte"],      "num_cliente"),
    ("BC-3.2",  "cuenta",     "Cuenta",               ["cta", "ctas", "numcuenta"],                 "num_cuenta"),
    ("BC-3.3",  "credito",    "Crédito",              ["cred", "cre", "numcredito"],                "num_credito"),
    ("BC-3.4",  "folio",      "Transacción de Pago",  ["pago", "orden", "tef"],                    "folio"),
    ("BC-3.5",  "tarjeta",    "Tarjeta",              ["tdc", "tdd", "numtarjeta"],                 "PAN (tokenizado)"),
    ("BC-5.4",  "poliza",     "Asiento Contable",     ["asiento"],                                  "folio_contable"),
    ("BC-3.18", "aclaracion", "Aclaración",           ["acl"],                                      "num_aclaracion"),
    ("BC-5.8",  "alerta",     "Alerta AML",           ["alertas", "pld"],                           "id_alerta"),
]
def root_card(bc, term, name, variants, canonical):
    freq = next(((r.get("fn", 0) or 0) + (r.get("fp", 0) or 0) for r in rows if r["term"] == term), 0)
    chips = "".join(f'<span class="sychip">{v}</span>' for v in variants)
    return (f'<div class="root-card">'
            f'<div class="root-bc">{bc}</div>'
            f'<div class="root-term">⭐ {term}</div>'
            f'<div class="root-name">{name}</div>'
            f'<div class="root-id">→ <code>{canonical}</code></div>'
            f'<div class="root-vars">{chips}</div>'
            f'<div class="root-freq">{freq} usos en SPs</div>'
            f'</div>')
ROOTS_H = "".join(root_card(*info) for info in ROOT_INFO)

# ── NEW v2: DT layers panel ──
DT_LAYERS = [
    ("1", "DT-Vocabulario",   f"{len(rows)} términos",    "SPs: átomos · compuestos · candidatos",    "#F0D224"),
    ("2", "DT-Almas",         "16 módulos",      "Nombres de módulos funcionales del sistema","#3068C4"),
    ("3", "DT-Journeys",      "131 journeys",    "Procesos bancarios (verbos + entidades)",   "#6882AA"),
    ("4", "DT-Reglas",        "1,308 reglas",    "Condiciones SBVR: umbrales y regulación",   "#8b3a8b"),
    ("M", "DT-Modelo-Dom.",   "23 BCs · 8 roots","Bounded contexts y aggregate roots target", "#2e6b48"),
    ("C", "DT-Capacidades",   "261 caps ETB",    "Capacidades BIAN L3 con cobertura BCOP",    "#1e5a8a"),
]
DTLAYERS_H = "".join(
    f'<div class="dtlayer">'
    f'<div class="dtnum" style="background:{color}">{num}</div>'
    f'<div class="dtbody">'
    f'<div class="dtname">{name}</div>'
    f'<div class="dtcount">{count}</div>'
    f'<div class="dtdesc">{desc}</div>'
    f'</div></div>'
    for num, name, count, desc, color in DT_LAYERS
)

DATA_EFIM = json.dumps(rows_efim, ensure_ascii=False, separators=(",", ":"))
N_EFIM      = len(rows_efim)
N_EFIM_REAL = sum(1 for r in rows_efim if r.get("scope") in ("EFIMERA", "EFIMERA-CALCULO"))
N_EFIM_DASH = sum(1 for r in rows_efim if r.get("scope") == "—")
DATA = json.dumps(rows, ensure_ascii=False, separators=(",", ":"))
M = json.dumps({"byniv": byniv, "bycat": bycat, "bytipo": bytipo, "byfte": byfte,
                "byniv_u": byniv_u, "bycat_u": bycat_u, "bytipo_u": bytipo_u, "byfte_u": byfte_u,
                "meta": meta, "total": len(rows), "total_u": len(_surv),
                "byunit": dict(byunit)}, ensure_ascii=False)

# ── HTML template ──
HTML = """<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Informix · Vocabulario SPL v2</title>
<style>
:root{--bg:#0a1330;--bg2:#0d1a3d;--panel:#132152;--line:#26317c;--magenta:#F0D224;--yellow:#F0D224;--blue:#3D5FCD;--txt:#EAEDF7;--muted:#9aa4c4}
*{box-sizing:border-box;margin:0;padding:0}
body{background:var(--bg);color:var(--txt);font-family:'Inter',system-ui,sans-serif;min-height:100vh}
header{background:linear-gradient(135deg,#0d2185 0%,#122FB1 55%,#1a3abf 100%);
  border-bottom:3px solid var(--magenta);padding:18px 28px;
  display:flex;align-items:center;gap:20px;
  box-shadow:0 4px 24px rgba(0,0,0,.45)}
header .logo-wrap{display:flex;align-items:center;gap:16px;flex-shrink:0}
header img{height:44px;filter:drop-shadow(0 2px 6px rgba(0,0,0,.55));object-fit:contain}
header .divider{width:1px;height:40px;background:rgba(255,255,255,.2);flex-shrink:0}
header .meta{flex:1}
header .breadcrumb{font-size:10px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;
  color:rgba(255,255,255,.45);margin-bottom:5px}
header .breadcrumb span{color:var(--magenta)}
header h1{font-size:18px;font-weight:800;letter-spacing:-.01em;line-height:1.2}
header .sub{font-size:11px;color:#a0b4e8;margin-top:4px;line-height:1.4}
header .badge-wrap{display:flex;gap:8px;align-items:center;margin-left:auto;flex-shrink:0}
header .hbadge{font-size:10px;font-weight:700;padding:4px 12px;border-radius:20px;
  letter-spacing:.04em;white-space:nowrap}
header .hbadge.etapa{background:rgba(240,210,36,.15);border:1px solid rgba(240,210,36,.4);color:var(--magenta)}
header .hbadge.tech{background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.14);color:#c9d3f5}
header .hbadge.v2{background:rgba(61,95,205,.3);border:1px solid rgba(61,95,205,.6);color:#93c5fd}
/* lead sections */
.lead{padding:22px 24px 6px}
.lhead{font-size:17px;font-weight:800;letter-spacing:-.01em;margin-bottom:12px}
.lsub{font-size:12px;color:var(--muted);margin:-4px 0 14px;max-width:84ch}
/* hallazgos */
.hgrid{display:grid;grid-template-columns:repeat(2,1fr);gap:13px}
@media(max-width:760px){.hgrid{grid-template-columns:1fr}}
.hcard{background:rgba(255,255,255,.05);backdrop-filter:blur(14px) saturate(140%);-webkit-backdrop-filter:blur(14px) saturate(140%);border:1px solid rgba(255,255,255,.1);border-left:3px solid var(--magenta);box-shadow:0 8px 26px rgba(0,0,0,.3),inset 0 1px 0 rgba(255,255,255,.08);border-radius:14px;padding:15px 18px;font-size:13px;color:var(--muted);line-height:1.55}
.hcard b{color:#fff;font-weight:700}.hcard i{color:#e4eaff}
.hcard .hn{font-size:11px;font-weight:800;color:var(--magenta);letter-spacing:.05em;text-transform:uppercase;margin-bottom:7px}
/* ── enrich hero — full-width ── */
.enrich-hero{
  position:relative;overflow:hidden;
  background:linear-gradient(135deg,#0a1a70 0%,#122FB1 45%,#1a3abf 70%,#0d2060 100%);
  border-bottom:3px solid #F0D224;
  padding:32px 36px 28px;
}
.enrich-hero::before{             /* decorative radial glow */
  content:'';position:absolute;top:-60px;right:-60px;
  width:340px;height:340px;border-radius:50%;
  background:radial-gradient(circle,rgba(240,210,36,.18) 0%,transparent 70%);
  pointer-events:none}
.enrich-hero::after{              /* bottom shimmer line */
  content:'';position:absolute;bottom:0;left:0;right:0;height:1px;
  background:linear-gradient(90deg,transparent,rgba(240,210,36,.5),transparent)}
.eh-brand{display:flex;align-items:center;gap:12px;margin-bottom:22px}
.eh-brand img{height:36px;filter:drop-shadow(0 2px 8px rgba(0,0,0,.5));object-fit:contain}
.eh-brand-sep{width:1px;height:28px;background:rgba(255,255,255,.2)}
.eh-brand-label{font-size:10px;font-weight:700;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.45)}
.eh-brand-label span{color:#F0D224}
.eh-body{display:grid;grid-template-columns:auto 1px 1fr;gap:0;align-items:start}
@media(max-width:760px){.eh-body{grid-template-columns:1fr}}
.eh-left{padding-right:36px}
.eh-sep{background:rgba(255,255,255,.15);margin:0 36px;align-self:stretch}
@media(max-width:760px){.eh-sep{display:none}}
.eh-label{font-size:10px;font-weight:800;letter-spacing:.1em;text-transform:uppercase;color:#F0D224;margin-bottom:8px}
.eh-pct{font-size:80px;font-weight:900;color:#fff;line-height:.9;letter-spacing:-.03em;text-shadow:0 4px 24px rgba(0,0,0,.4)}
.eh-sym{font-size:44px;font-weight:900;color:#F0D224;vertical-align:top;margin-top:10px;display:inline-block}
.eh-sub{font-size:12px;color:rgba(255,255,255,.55);margin:8px 0 14px;line-height:1.4}
.eh-sub b{color:rgba(255,255,255,.85)}
.qbar{display:flex;height:10px;border-radius:5px;overflow:hidden;width:200px;gap:1px}
.qbar-seg{height:100%}
.qbar-legend{display:flex;gap:12px;margin-top:8px;flex-wrap:wrap}
.qbar-legend span{font-size:10px;color:rgba(255,255,255,.5);display:flex;align-items:center;gap:4px}
.ql-dot{width:8px;height:8px;border-radius:2px;flex-shrink:0}
.eh-right{padding-left:4px}
.eh-ola-label{font-size:10px;font-weight:800;letter-spacing:.1em;text-transform:uppercase;color:#F0D224;margin-bottom:12px}
.ola-row{display:flex;align-items:center;gap:12px;padding:9px 0;border-bottom:1px solid rgba(255,255,255,.07);font-size:12.5px}
.ola-row:last-child{border-bottom:none}
.ola-badge{width:26px;height:26px;border-radius:7px;background:rgba(240,210,36,.15);border:1px solid #F0D224;color:#F0D224;font-weight:900;font-size:12px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.ola-badge.pend{background:rgba(255,255,255,.06);border-color:rgba(255,255,255,.15);color:rgba(255,255,255,.3)}
.ola-desc{flex:1;color:rgba(255,255,255,.6)}.ola-desc b{color:#fff}
.ola-check{color:#22c55e;font-size:16px;flex-shrink:0;filter:drop-shadow(0 0 4px #22c55e88)}
.ola-pend{color:rgba(255,255,255,.25);font-size:13px;flex-shrink:0}
.ola-row.done .ola-desc{color:rgba(255,255,255,.85)}
/* ── enrich log ── */
.enrich-log{display:flex;flex-direction:column;gap:10px;margin:14px 0 4px}
.log-entry{background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.07);border-left:3px solid #122FB1;border-radius:10px;padding:12px 16px}
.log-entry.log-done{border-left-color:#22c55e}
.log-meta{display:flex;align-items:center;gap:8px;margin-bottom:5px}
.log-ola{background:#122FB1;color:#F0D224;font-weight:900;font-size:10px;padding:2px 7px;border-radius:4px}
.log-fecha{font-size:10px;color:var(--muted);font-variant-numeric:tabular-nums}
.log-titulo{font-size:12px;font-weight:700;color:#e4eaff;margin-bottom:5px}
.log-items{margin:0;padding-left:16px;font-size:11px;color:var(--muted);line-height:1.7}
.log-items li{list-style:disc}
/* aggregate roots grid */
.roots-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-top:4px}
@media(max-width:900px){.roots-grid{grid-template-columns:repeat(2,1fr)}}
@media(max-width:540px){.roots-grid{grid-template-columns:1fr}}
.root-card{background:rgba(255,255,255,.05);backdrop-filter:blur(10px);-webkit-backdrop-filter:blur(10px);border:1px solid rgba(255,255,255,.1);
  border-top:3px solid var(--magenta);border-radius:12px;padding:14px 16px;
  box-shadow:0 2px 8px rgba(0,0,0,.3)}
.root-bc{font-size:9px;font-weight:800;color:#93c5fd;letter-spacing:.08em;text-transform:uppercase;margin-bottom:4px}
.root-term{font-size:18px;font-weight:900;font-family:'Cascadia Code','Consolas',monospace;
  color:var(--magenta);letter-spacing:-.01em;margin-bottom:2px}
.root-name{font-size:10px;color:var(--muted);margin-bottom:6px}
.root-id{font-size:10px;color:var(--muted);margin-bottom:8px}
.root-id code{color:#93c5fd;font-family:'Cascadia Code',monospace;font-size:9.5px}
.root-vars{display:flex;flex-wrap:wrap;gap:4px;margin-bottom:6px}
.root-freq{font-size:9px;color:#5b6a8a}
.root-star{color:var(--magenta);font-size:10px;margin-left:3px;vertical-align:top}
/* DT layers */
.dt-wrap{display:flex;gap:8px;flex-wrap:wrap;margin-top:4px}
.dtlayer{display:flex;gap:10px;align-items:flex-start;background:rgba(255,255,255,.05);
  backdrop-filter:blur(10px);-webkit-backdrop-filter:blur(10px);
  border:1px solid rgba(255,255,255,.1);border-radius:10px;padding:12px 14px;
  min-width:150px;flex:1;box-shadow:0 1px 4px rgba(0,0,0,.2)}
.dtnum{width:28px;height:28px;border-radius:6px;display:flex;align-items:center;
  justify-content:center;font-size:11px;font-weight:900;color:#ffffff;flex-shrink:0}
.dtbody{min-width:0}
.dtname{font-size:11px;font-weight:700;color:var(--txt);margin-bottom:2px}
.dtcount{font-size:10px;font-weight:700;color:var(--magenta);margin-bottom:2px}
.dtdesc{font-size:9.5px;color:var(--muted);line-height:1.4}
/* BIAN / BC bars */
.bianwrap{background:rgba(255,255,255,.04);backdrop-filter:blur(14px) saturate(140%);-webkit-backdrop-filter:blur(14px) saturate(140%);border:1px solid rgba(255,255,255,.09);border-radius:14px;padding:16px 20px;box-shadow:inset 0 1px 0 rgba(255,255,255,.07)}
.bianrow{display:grid;grid-template-columns:220px 1fr 46px;gap:12px;align-items:center;padding:4px 0;font-size:12.5px}
@media(max-width:640px){.bianrow{grid-template-columns:130px 1fr 40px}}
.bl{color:#dfe6ff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.bbar{background:#0c1747;border-radius:6px;height:16px;overflow:hidden}
.bbar i{display:block;height:100%;background:linear-gradient(90deg,var(--blue),#6f8ce6);border-radius:6px}
.bbar i.top{background:linear-gradient(90deg,var(--magenta),#f6e27a)}
.bv{color:var(--muted);text-align:right;font-variant-numeric:tabular-nums;font-weight:700}
.bianrow.tec{opacity:.72;border-top:1px solid var(--line);margin-top:8px;padding-top:10px}
.btec{font-size:11px;color:var(--muted);font-style:italic;align-self:center}
/* ER diagram */
.ermwrap{overflow-x:auto}.ermwrap .mermaid{text-align:center;min-height:300px}
/* sinónimos */
.synrow{display:grid;grid-template-columns:190px 1fr;gap:14px;align-items:baseline;
  padding:6px 0;border-bottom:1px solid rgba(38,49,124,.5);font-size:12.5px}
.syc{color:#dfe6ff;font-weight:700}
.sya{display:flex;flex-wrap:wrap;gap:6px}
.sychip{background:#0c1747;border:1px solid var(--line);border-radius:12px;
  padding:2px 9px;font-size:11px;color:var(--muted);font-family:'Cascadia Code',monospace}
.sychip.can{background:rgba(240,210,36,.12);border-color:rgba(240,210,36,.45);
  color:var(--magenta);font-weight:700}
.syntag{font-size:9px;font-weight:700;color:var(--magenta);background:rgba(240,210,36,.1);
  border:1px solid rgba(240,210,36,.3);border-radius:8px;padding:0 5px;
  margin-left:5px;font-family:'Inter',sans-serif}
/* tiles */
#tiles{display:flex;gap:8px;padding:10px 20px;flex-wrap:wrap;flex-shrink:0}
.tile{background:var(--panel);border-radius:8px;padding:8px 14px;min-width:92px;
  border-left:3px solid var(--line);box-shadow:0 1px 4px rgba(0,0,0,.2)}
.tile .n{font-size:20px;font-weight:800}
.tile .l{font-size:9px;color:var(--muted);text-transform:uppercase;letter-spacing:.06em}
.tile .sub{font-size:8.5px;color:#5b6580;margin-top:2px;font-variant-numeric:tabular-nums}
.tile.alta{border-left-color:#22c55e}.tile.media{border-left-color:#f59e0b}
.tile.amb{border-left-color:#ef4444}.tile.cand{border-left-color:#6b7280}
.tile.tot{border-left-color:var(--magenta)}.tile.root{border-left-color:var(--blue)}
/* catbars */
#cats,#ftes{display:flex;gap:6px;padding:0 20px 8px;flex-wrap:wrap;flex-shrink:0}
#ftes .lead{font-size:9px;color:var(--muted);align-self:center;letter-spacing:.06em}
.catbar{background:var(--panel);border-radius:6px;padding:5px 10px;
  font-size:10px;display:flex;gap:6px;align-items:center}
.catbar b{color:var(--txt)}.catbar .dot{width:8px;height:8px;border-radius:2px}
/* controls */
#ctrl{display:flex;gap:8px;padding:8px 20px;align-items:center;flex-wrap:wrap;flex-shrink:0;
  border-top:1px solid var(--line);border-bottom:1px solid var(--line);
  background:var(--bg2)}
#q{background:var(--panel);border:1px solid var(--line);border-radius:6px;color:var(--txt);
  padding:6px 10px;font-size:12px;width:230px;outline:none}
#q:focus{border-color:var(--magenta);box-shadow:0 0 0 2px rgba(240,210,36,.12)}
.fgroup{display:flex;gap:4px;align-items:center}
.fgroup .lbl{font-size:9px;color:var(--magenta);text-transform:uppercase;letter-spacing:.08em;font-weight:700;margin-right:2px}
.chip{background:var(--panel);border:1px solid var(--line);border-radius:20px;padding:3px 10px;
  font-size:10px;color:var(--muted);cursor:pointer;user-select:none;transition:all .15s;white-space:nowrap}
.chip:hover{border-color:var(--muted);color:var(--txt)}
.chip.on{background:#12235a;border-color:var(--magenta);color:var(--txt);font-weight:700}
#count{font-size:10px;color:var(--muted);margin-left:auto}
/* table */
#wrap{overflow:visible;padding:0 24px 40px}
table{width:100%;border-collapse:collapse;font-size:12px}
thead th{position:sticky;top:0;background:var(--bg2);text-align:left;padding:8px 10px;
  font-size:9px;text-transform:uppercase;letter-spacing:.06em;color:var(--muted);
  border-bottom:1px solid var(--line);cursor:pointer;white-space:nowrap;z-index:5}
thead th:hover{color:var(--txt)}
thead th .ar{opacity:.4;font-size:8px}
tbody td{padding:6px 10px;border-bottom:1px solid rgba(44,44,80,.5)}
tbody tr:hover{background:rgba(240,210,36,.07)}
tbody tr.is-root{background:rgba(240,210,36,.05)}
.term{font-family:'Cascadia Code','Consolas',monospace;font-weight:700;color:#d8d8f0}
.deco{font-family:'Cascadia Code','Consolas',monospace;font-size:10px;color:#6f8ce6}
.mean{color:var(--txt)}
.num{text-align:right;font-variant-numeric:tabular-nums;color:var(--muted)}
.num.hot{color:#93c5fd;font-weight:600}
.badge{display:inline-block;font-size:9px;font-weight:700;padding:1px 7px;border-radius:10px;white-space:nowrap}
.b-alta{background:#052e16;color:#86efac}.b-media{background:#3a2a08;color:#fdba74}
.b-amb{background:#450a0a;color:#fca5a5}.b-cand{background:#1f2430;color:#9aa4b8}
.cat{font-size:9px;padding:1px 7px;border-radius:3px;font-weight:600}
.tipo{font-size:9px;color:var(--muted)}
.tdato{font-size:9px;font-weight:700;padding:1px 6px;border-radius:3px;white-space:nowrap}
.tdato-NUM{background:#052e16;color:#86efac}.tdato-ALFA{background:#1e3a5f;color:#93c5fd}
.tdato-FECHA{background:#3a2a08;color:#fcd34d}.tdato-BOOL{background:#3b1278;color:#d8b4fe}
.bc-tag{font-size:9px;font-weight:700;background:rgba(61,95,205,.15);border:1px solid rgba(61,95,205,.35);
  border-radius:4px;padding:1px 6px;color:#93c5fd;white-space:nowrap}
.bc-tag.is-root-bc{border-color:rgba(240,210,36,.5);background:rgba(240,210,36,.12);color:var(--magenta)}
footer{font-size:9px;color:var(--muted);padding:6px 20px;flex-shrink:0;border-top:1px solid var(--line);background:var(--bg2)}
/* column visibility */
table.hide-deco   th.col-deco,   table.hide-deco   td.col-deco   {display:none!important}
table.hide-dom    th.col-dom,    table.hide-dom    td.col-dom    {display:none!important}
table.hide-target th.col-target, table.hide-target td.col-target {display:none!important}
table.hide-reg    th.col-reg,    table.hide-reg    td.col-reg    {display:none!important}
table.hide-taxon  th.col-taxon,  table.hide-taxon  td.col-taxon  {display:none!important}
table.hide-fn     th.col-fn,     table.hide-fn     td.col-fn     {display:none!important}
#fvis{display:flex;gap:4px;flex-wrap:wrap}
#fvis .chip{min-width:56px;text-align:center}
#fvis .chip.on{background:rgba(61,95,205,.2);border-color:var(--blue);color:#93c5fd;font-weight:600}
td.col-dom,td.col-target,td.col-reg,td.col-taxon{max-width:130px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.dom-tag{display:inline-block;font-size:9px;font-weight:800;background:rgba(61,95,205,.15);border:1px solid rgba(61,95,205,.3);border-radius:3px;padding:1px 5px;color:#93c5fd;font-family:'Cascadia Code',monospace}
.reg-tag{display:inline-block;font-size:9px;font-weight:700;background:rgba(220,38,38,.1);border:1px solid rgba(220,38,38,.3);border-radius:3px;padding:1px 5px;color:#fca5a5;white-space:nowrap}
/* tabs */
.tab-nav{display:flex;gap:6px;padding:12px 24px 0;flex-shrink:0;border-bottom:2px solid var(--line);background:var(--bg2)}
.tab-btn{background:transparent;border:none;border-bottom:2px solid transparent;margin-bottom:-2px;
  padding:7px 16px;font-size:11px;font-weight:700;letter-spacing:.06em;text-transform:uppercase;
  color:var(--muted);cursor:pointer;transition:all .15s}
.tab-btn:hover{color:var(--txt)}
.tab-btn.active{border-bottom-color:var(--magenta);color:var(--magenta)}
/* unit badges */
.unit{font-size:9px;font-weight:700;padding:2px 7px;border-radius:10px;white-space:nowrap;font-family:'Cascadia Code',monospace}
.u-MXN{background:#052e16;color:#86efac}.u-USD{background:#05261a;color:#6ee7b7}
.u-PCT{background:#3a2a08;color:#fde68a}.u-RATIO{background:#1a2a50;color:#93c5fd}
.u-COUNT{background:#1a1a40;color:#a5b4fc}.u-DIAS{background:#2a1a40;color:#d8b4fe}
.u-MESES{background:#1f1240;color:#c4b5fd}.u-ID{background:#2a1a10;color:#fdba74}
.u-BOOL{background:#3a1010;color:#fca5a5}.u-TEXT{background:#1a1a1a;color:#9aa4c4}
.u-MIXTO{background:#1e1e2e;color:#6f8ce6}.u-NA{background:#111;color:#444;display:none}
/* efimero tab extras */
#tab-efimero .lhead-efim{font-size:13px;font-weight:700;color:var(--magenta);padding:12px 24px 4px;letter-spacing:.04em}
#tab-efimero .efim-desc{font-size:11px;color:var(--muted);padding:0 24px 10px;max-width:80ch}
#unit-dist{display:flex;gap:6px;flex-wrap:wrap;padding:10px 20px}
.udist-chip{background:var(--panel);border:1px solid var(--line);border-radius:8px;
  padding:5px 12px;font-size:10px;display:flex;gap:6px;align-items:center}
.udist-chip .dot{width:8px;height:8px;border-radius:2px}
</style>
</head>
<body>
<header>
  <div class="logo-wrap">
    <img src="../bancoppel-logo.png" alt="BanCoppel">
    <div class="divider"></div>
  </div>
  <div class="meta">
    <div class="breadcrumb">Informix · <span>SPE-AM-001</span> · Gemelo Cognitivo del Sistema · Capa 1</div>
    <h1>Reporte de Vocabulario SPL · v2</h1>
    <div class="sub">IBM Informix IDS 14.10 · __SPS__ stored procedures · 16 dominios D01-D16 · Bounded Contexts + Aggregate Roots + capas del Gemelo</div>
  </div>
  <div class="badge-wrap">
    <span class="hbadge v2">v2</span>
    <span class="hbadge etapa">Etapa 3</span>
    <span class="hbadge tech">Informix SPL</span>
  </div>
</header>

__ENRICH_HERO__

<div class="lead">
  <div class="lhead">Hallazgos principales</div>
  <div class="hgrid">__HALLAZGOS__</div>
  <div class="lhead" style="margin-top:22px;font-size:12px;opacity:.8">Log de enriquecimiento</div>
  __ENRICH_LOG__

  <div class="lhead" style="margin-top:28px">Aggregate Roots — identificadores canónicos del target</div>
  <div class="lsub">Los 8 aggregate roots del modelo lógico. En el AS-IS Informix cada uno tiene 3-5 variantes de nombre (sin contrato de API); en el target deben converger en el identificador canónico. Los términos marcados con ⭐ en la tabla son variantes de estos roots.</div>
  <div class="roots-grid">__ROOTS__</div>

  <div class="lhead" style="margin-top:28px">Vocabulario por capa del Gemelo Cognitivo</div>
  <div class="lsub">Cada DT peer aporta vocabulario desde una perspectiva distinta del sistema. La Capa 1 (sp_vocab) extrae del código; las capas superiores aportan semántica de negocio que el código no nombra explícitamente.</div>
  <div class="dt-wrap">__DTLAYERS__</div>

  <div class="lhead" style="margin-top:28px">Vocabulario alineado a BIAN</div>
  <div class="lsub">Cada término mapeado a un dominio del <b>BIAN Service Landscape</b> — dónde vive el lenguaje del negocio dentro del core.</div>
  <div class="bianwrap">__BIANBARS__</div>

  <div class="lhead" style="margin-top:28px">Distribución por Bounded Context</div>
  <div class="lsub">Los mismos términos agrupados por <b>Bounded Context del modelo target</b>. BC-7.1 (Customer) y BC-3.3 (Lending) dominan porque el producto central de BanCoppel es crédito Coppel con cliente de la red retail.</div>
  <div class="bianwrap">__BCBARS__</div>

  <div class="lhead" style="margin-top:28px">Modelo entidad-relación de dominios</div>
  <div class="lsub">Dominios como entidades con top-10 términos como atributos. Relaciones derivadas del grafo de llamadas real — el número = nº de llamadas cruzadas entre dominios.</div>
  <div class="bianwrap ermwrap"><pre class="mermaid">__ERDIAG__</pre></div>

  <div class="lhead" style="margin-top:30px">Explorador de vocabulario</div>
  <div class="lsub">Filtra por tipo, confiabilidad, categoría, evidencia, scope y <b>Bounded Context</b>. Los términos ⭐ son aggregate roots o sus variantes AS-IS.</div>
</div>

<div id="tiles"></div>
<div id="cats"></div>
<div id="ftes"></div>

<div class="tab-nav">
  <button class="tab-btn active" id="btn-all" onclick="switchTab('all')">📊 Vocabulario — términos que trascienden</button>
  <button class="tab-btn" id="btn-efimero" onclick="switchTab('efimero')">🔢 Efímero — solo cálculo interno</button>
</div>

<div id="tab-all">

<div id="ctrl">
  <input id="q" type="text" placeholder="Buscar término o significado…" autocomplete="off">
  <div class="fgroup"><span class="lbl">Tipo</span><div id="ftipo"></div></div>
  <div class="fgroup"><span class="lbl">Confiab.</span><div id="fniv"></div></div>
  <div class="fgroup"><span class="lbl">Categoría</span><div id="fcat"></div></div>
  <div class="fgroup"><span class="lbl">Evidencia</span><div id="ffte"></div></div>
  <div class="fgroup"><span class="lbl">Scope</span><div id="fscope"></div></div>
  <div class="fgroup"><span class="lbl">BC</span><div id="fbc"></div></div>
  <div class="fgroup">
    <span class="lbl">Root</span>
    <div id="froot"></div>
  </div>
  <span id="count"></span>
  <div class="fgroup" style="width:100%;border-top:1px solid var(--line);padding-top:6px;margin-top:4px">
    <span class="lbl" style="flex-shrink:0">Columnas</span><div id="fvis"></div>
  </div>
</div>

<div id="wrap">
  <table>
    <thead><tr>
      <th data-k="term">Término <span class="ar">↕</span></th>
      <th data-k="tipo">Tipo <span class="ar">↕</span></th>
      <th data-k="tipo_dato">T.dato <span class="ar">↕</span></th>
      <th data-k="cat">Categoría <span class="ar">↕</span></th>
      <th data-k="mean">Significado <span class="ar">↕</span></th>
      <th data-k="bc">BC <span class="ar">↕</span></th>
      <th data-k="dominio_as_is" class="col-dom">Dom AS-IS <span class="ar">↕</span></th>
      <th data-k="deco" class="col-deco">Descomposición <span class="ar">↕</span></th>
      <th data-k="nalias">Alias / Sinónimos <span class="ar">↕</span></th>
      <th data-k="nivel">Confiab. <span class="ar">↕</span></th>
      <th data-k="fuente">Evidencia <span class="ar">↕</span></th>
      <th data-k="scope">Scope <span class="ar">↕</span></th>
      <th data-k="unit">Unidad <span class="ar">↕</span></th>
      <th data-k="target_term" class="col-target">Target Term <span class="ar">↕</span></th>
      <th data-k="regulatorio" class="col-reg">Reg. <span class="ar">↕</span></th>
      <th data-k="nodo_taxonomia" class="col-taxon">Taxonomía <span class="ar">↕</span></th>
      <th data-k="fn" class="num col-fn">frec-nom <span class="ar">↕</span></th>
      <th data-k="fp" class="num">frec-par <span class="ar">↕</span></th>
    </tr></thead>
    <tbody id="tb"></tbody>
  </table>
  </div>
</div><!-- /tab-all -->

<div id="tab-efimero" style="display:none">
  <div class="lhead-efim">Vocabulario efímero — __N_EFIM__ términos sin API boundary</div>
  <div class="efim-desc"><b>__N_EFIM_REAL__ efímeros reales</b> (EFIMERA · EFIMERA-CALCULO) + <b>__N_EFIM_DASH__ sin clasificar</b> (scope no asignado). Ninguno forma parte del contrato de datos del sistema — son variables internas de cálculo, candidatos pendientes de análisis o términos Ola-A para eliminar.</div>
  <div id="unit-dist"></div>
  <div id="wrap-efimero">
    <table id="tbl-efimero">
      <thead><tr>
        <th data-k2="term">Término</th>
        <th data-k2="cat">Categoría</th>
        <th data-k2="mean">Significado</th>
        <th data-k2="unit">Unidad</th>
        <th data-k2="scope">Scope</th>
        <th data-k2="fp" class="num">frec-par</th>
        <th data-k2="fn" class="num">frec-nom</th>
      </tr></thead>
      <tbody id="tb-efimero"></tbody>
    </table>
  </div>
</div>

<footer>⭐ Aggregate Root (variante AS-IS de un identificador canónico del target) · 🟢 Alta (confirmada) · 🟡 Media (inferida) · 🔴 Ambigua (requiere SME) · ⚪ Candidato. frec-par = evidencia en código. v2 · 2026-08-02</footer>

<script>
const DATA = __DATA__;
const M = __META__;
const ALIASES = __ALIASES__;
const DATA_EFIM = __DATA_EFIM__;

// ── unit ──
const UNIT_STYLE = {
  'MXN':'u-MXN','USD':'u-USD','PCT':'u-PCT','RATIO':'u-RATIO',
  'COUNT':'u-COUNT','DIAS':'u-DIAS','MESES':'u-MESES','ID':'u-ID',
  'BOOL':'u-BOOL','TEXT':'u-TEXT','MIXTO':'u-MIXTO','N/A':'u-NA',
};
const UNIT_LBL = {
  'MXN':'$ MXN','USD':'$ USD','PCT':'%','RATIO':'ratio',
  'COUNT':'cantidad','DIAS':'días','MESES':'meses','ID':'ID',
  'BOOL':'bool','TEXT':'texto','MIXTO':'mixto','N/A':'',
};
function unitCell(u){
  const cls=UNIT_STYLE[u]||'u-NA';
  const lbl=UNIT_LBL[u]||u;
  if(u==='N/A') return '';
  return '<span class="unit ' + cls + '">' + lbl + '</span>';
}

// ── tabs ──
function switchTab(t){
  document.getElementById('tab-all').style.display = t==='all'?'':'none';
  document.getElementById('tab-efimero').style.display = t==='efimero'?'':'none';
  document.getElementById('btn-all').classList.toggle('active', t==='all');
  document.getElementById('btn-efimero').classList.toggle('active', t==='efimero');
  if(t==='efimero') renderEfimero();
}

// ── column visibility ──
const COL_DEFS = [
  {id:'dom',    label:'Dom AS-IS', hidden:false},
  {id:'deco',   label:'Descomp.', hidden:true},
  {id:'target', label:'Target',   hidden:true},
  {id:'reg',    label:'Reg.',     hidden:false},
  {id:'taxon',  label:'Taxon.',   hidden:true},
  {id:'fn',     label:'frec-nom', hidden:true},
];
const hiddenCols = new Set(COL_DEFS.filter(c=>c.hidden).map(c=>c.id));
const tblEl = document.querySelector('table');
function applyColVis(){
  COL_DEFS.forEach(c=>tblEl.classList.toggle('hide-'+c.id, hiddenCols.has(c.id)));
}
applyColVis();
document.getElementById('fvis').innerHTML=COL_DEFS.map(c=>
  `<span class="chip${hiddenCols.has(c.id)?'':' on'}" data-col="${c.id}">${c.label}</span>`
).join('');
document.querySelectorAll('#fvis .chip').forEach(ch=>ch.onclick=()=>{
  const id=ch.dataset.col;
  if(hiddenCols.has(id)){hiddenCols.delete(id);ch.classList.add('on');}
  else{hiddenCols.add(id);ch.classList.remove('on');}
  applyColVis();
});

function aliasCell(t){
  const a=ALIASES[t];
  if(!a) return '<span style="color:#4a5578">-</span>';
  return a.g.map(x=>'<span class="sychip'+(x===a.c?' can':'')+'">'+x+'</span>').join(' ');
}

const NIV={ALTA:['🟢 Alta','b-alta'],MEDIA:['🟡 Media','b-media'],AMBIGUA:['🔴 Ambigua','b-amb'],CANDIDATO:['⚪ Candidato','b-cand']};
const CATCOL={PREFIJO:'#3d4666',ACCION:'#1e5a8a',ENTIDAD:'#2e6b48',MODIF:'#7a6018',REG:'#8b2020',AMBIGUO:'#6b3080','?':'#333'};
const CATLBL={PREFIJO:'prefijo',ACCION:'acción',ENTIDAD:'entidad',MODIF:'modif',REG:'regulatorio',AMBIGUO:'ambiguo','?':'—'};
const FTE={CODIGO:['🔬 Código','#1e5a8a'],SME:['🧑 SME','#2e6b48'],NEGOCIO:['🌐 Negocio','#6b3080'],
  CONVENCION:['📖 Convención','#7a6018'],INFERIDO:['💭 Inferido','#4a4a5a'],AMBIGUO:['❓ Ambiguo','#8b2020']};
const SCOPE={
  'PERSISTE-BD':    ['💾 Persiste-BD',   '#1a5c38'],
  'LECTURA-BD':     ['📖 Lectura-BD',    '#2e6b48'],
  'INTERFAZ-IN':    ['⬇️ Interfaz-IN',   '#1e5a8a'],
  'INTERFAZ-OUT':   ['⬆️ Interfaz-OUT',  '#2b4a8a'],
  'BATCH':          ['⚙️ Batch',         '#5a4200'],
  'CURSOR':         ['🔄 Cursor',        '#3a3a6a'],
  'EFIMERA-CALCULO':['🔢 Efím-cálculo',  '#8b2020'],
  'EFIMERA':        ['⚪ Efímera',        '#4a4a5a'],
  'EXCEPCION':      ['⚠️ Excepción',     '#7a3a00'],
  'MIXTO':          ['🔵 Mixto',         '#1e4a6a'],
  // legacy labels from v1 (backward compat)
  'TRASCIENDE':     ['🟢 Trasciende',    '#2e6b48'],
  'EFÍMERA-CÁLCULO':['🔴 Efím-cálculo',  '#8b2020'],
  'EFÍMERA':        ['⚪ Efímera',        '#4a4a5a'],
  '—':              ['—',               '#333'],
};
// extend with domain-specific scopes
['D01','D02','D03','D04','D05','D06','D07','D08','D09','D10',
 'D11','D12','D13','D14','D15','D16','D17','D18','D19','D20',
 'D21','D22','D23','D24','D25','D26','D27','D28','D29','D30',
 'D31','D32','D33','D34','D35','D36','D37','D38','D39','D40',
 'D41','D42','D43','D44','D45','D46','D47','D48','D49'].forEach(d=>{
  SCOPE['DOMINIO-'+d]=['🏦 '+d,'#1a3a5a'];
});
// ensure TRANSVERSAL and INFRAESTRUCTURA are always present
SCOPE['TRANSVERSAL']=['🌐 Trans.','#1a4a2a'];
SCOPE['INFRAESTRUCTURA']=['⚙️ Infra','#2a2a1a'];

// TILES
const tiles=[
  ['tot', M.total_u, 'Términos únicos', M.total],
  ['tot', M.bytipo_u['atómico']||0, 'Atómicos', M.bytipo['atómico']||0],
  ['tot', M.bytipo_u['compuesto']||0, 'Compuestos', M.bytipo['compuesto']||0],
  ['root', DATA.filter(r=>r.is_root).length, '⭐ Aggregate Roots'],
  ['alta', M.byniv_u.ALTA||0, '🟢 Alta'],
  ['media', M.byniv_u.MEDIA||0, '🟡 Media'],
  ['amb', M.byniv_u.AMBIGUA||0, '🔴 Ambigua'],
  ['cand', M.byniv_u.CANDIDATO||0, '⚪ Candidatos'],
];
document.getElementById('tiles').innerHTML=tiles.map(([c,n,l,raw])=>
  `<div class="tile ${c}"><div class="n">${n}</div><div class="l">${l}</div>`+
  ((raw!=null&&raw!==n)?`<div class="sub">${raw} con alias</div>`:``)+`</div>`).join('');

document.getElementById('cats').innerHTML=Object.entries(M.bycat_u)
  .sort((a,b)=>b[1]-a[1])
  .map(([c,n])=>`<div class="catbar"><span class="dot" style="background:${CATCOL[c]}"></span>${CATLBL[c]||c} <b>${n}</b></div>`).join('');

document.getElementById('ftes').innerHTML='<span class="lead">EVIDENCIA:</span>'+
  ['CODIGO','SME','NEGOCIO','CONVENCION','INFERIDO','AMBIGUO'].filter(f=>M.byfte_u[f])
  .map(f=>`<div class="catbar"><span class="dot" style="background:${FTE[f][1]}"></span>${FTE[f][0]} <b>${M.byfte_u[f]}</b></div>`).join('');

// FILTERS
let fTipo=new Set(),fNiv=new Set(),fCat=new Set(),fFte=new Set(),fScope=new Set(),fBC=new Set(),fRoot=false,q='';
function mkChips(elId,vals,set,labelFn){
  document.getElementById(elId).innerHTML=vals.map(v=>`<span class="chip" data-v="${v}">${labelFn(v)}</span>`).join('');
  document.querySelectorAll(`#${elId} .chip`).forEach(ch=>ch.onclick=()=>{
    const v=ch.dataset.v;
    if(set.has(v)){set.delete(v);ch.classList.remove('on');}else{set.add(v);ch.classList.add('on');}
    render();
  });
}
mkChips('ftipo',['atómico','compuesto','candidato'],fTipo,v=>v);
mkChips('fniv',['ALTA','MEDIA','AMBIGUA','CANDIDATO'],fNiv,v=>NIV[v][0]);
mkChips('fcat',['PREFIJO','ACCION','ENTIDAD','MODIF','REG','AMBIGUO'],fCat,v=>CATLBL[v]);
mkChips('ffte',['CODIGO','SME','NEGOCIO','CONVENCION','INFERIDO','AMBIGUO'],fFte,v=>FTE[v][0]);
const scopeVals=[...new Set(DATA.map(r=>r.scope).filter(s=>s&&s!=='—'))].sort();
mkChips('fscope',scopeVals,fScope,v=>(SCOPE[v]||[v])[0]);
const bcVals=[...new Set(DATA.map(r=>r.bc).filter(b=>b&&b!=='—'))].sort();
mkChips('fbc',bcVals,fBC,v=>v);
// root toggle
document.getElementById('froot').innerHTML='<span class="chip" id="croot">⭐ Solo roots</span>';
document.getElementById('croot').onclick=function(){
  fRoot=!fRoot;this.classList.toggle('on',fRoot);render();
};
document.getElementById('q').oninput=e=>{q=e.target.value.toLowerCase();render();};

let sortK2='fp', sortDir2=-1;
document.querySelectorAll('[data-k2]').forEach(th=>th.onclick=()=>{
  const k=th.dataset.k2;
  if(sortK2===k) sortDir2*=-1; else{sortK2=k;sortDir2=(k==='fn'||k==='fp')?-1:1;}
  renderEfimero();
});

function renderEfimero(){
  const efim = DATA_EFIM;
  efim.sort((a,b)=>{
    let x=a[sortK2],y=b[sortK2];
    if(typeof x==='number') return(x-y)*sortDir2;
    return String(x||'').localeCompare(String(y||''))*sortDir2;
  });
  // unit dist bar
  const uc={};
  efim.forEach(r=>{if(r.unit&&r.unit!=='N/A')uc[r.unit]=(uc[r.unit]||0)+1;});
  document.getElementById('unit-dist').innerHTML=
    Object.entries(uc).sort((a,b)=>b[1]-a[1]).map(([u,n])=>
      '<div class="udist-chip"><span class="dot" style="background:' + unitDotColor(u) + '"></span><span class="unit ' + (UNIT_STYLE[u]||'') + '">' + (UNIT_LBL[u]||u) + '</span><b>' + n + '</b></div>'
    ).join('');
  document.getElementById('tb-efimero').innerHTML=efim.map(r=>{
    const catbg=CATCOL[r.cat]||'#333';
    return '<tr>' +
      '<td><span class="term">' + r.term + '</span></td>' +
      '<td><span class="cat" style="background:' + catbg + '">' + (CATLBL[r.cat]||r.cat) + '</span></td>' +
      '<td class="mean">' + (r.mean||'').replace(/</g,'&lt;') + '</td>' +
      '<td>' + unitCell(r.unit) + '</td>' +
      '<td><span class="cat" style="background:' + (SCOPE[r.scope]||SCOPE['—'])[1] + '">' + (SCOPE[r.scope]||SCOPE['—'])[0] + '</span></td>' +
      '<td class="num ' + (r.fp>=10?'hot':'') + '">' + (r.fp||'') + '</td>' +
      '<td class="num">' + (r.fn||'') + '</td>' +
      '</tr>';
  }).join('');
}

function unitDotColor(u){
  const map={'MXN':'#86efac','USD':'#6ee7b7','PCT':'#fde68a','RATIO':'#93c5fd',
    'COUNT':'#a5b4fc','DIAS':'#d8b4fe','MESES':'#c4b5fd','ID':'#fdba74',
    'BOOL':'#fca5a5','TEXT':'#9aa4c4','MIXTO':'#6f8ce6'};
  return map[u]||'#444';
}

// SORT
let sortK='fp',sortDir=-1;
document.querySelectorAll('thead th').forEach(th=>th.onclick=()=>{
  const k=th.dataset.k;
  if(sortK===k) sortDir*=-1; else{sortK=k;sortDir=(k==='fn'||k==='fp')?-1:1;}
  render();
});

const tb=document.getElementById('tb');
function render(){
  let rs=DATA.filter(r=>{
    if(fTipo.size&&!fTipo.has(r.tipo)) return false;
    if(fNiv.size&&!fNiv.has(r.nivel)) return false;
    if(fCat.size&&!fCat.has(r.cat)) return false;
    if(fFte.size&&!fFte.has(r.fuente)) return false;
    if(fScope.size&&!fScope.has(r.scope)) return false;
    if(fBC.size&&!fBC.has(r.bc)) return false;
    if(fRoot&&!r.is_root) return false;
    if(q&&!(r.term.toLowerCase().includes(q)||(r.mean||'').toLowerCase().includes(q)||
           (r.dominio_as_is||'').toLowerCase().includes(q)||(r.target_term||'').toLowerCase().includes(q)||
           (r.regulatorio||'').toLowerCase().includes(q)||(r.nodo_taxonomia||'').toLowerCase().includes(q))) return false;
    return true;
  });
  rs.sort((a,b)=>{
    let x=a[sortK],y=b[sortK];
    if(typeof x==='number') return(x-y)*sortDir;
    return String(x||'').localeCompare(String(y||''))*sortDir;
  });
  tb.innerHTML=rs.map(r=>{
    const[nl,nc]=NIV[r.nivel]||['—','b-cand'];
    const catbg=CATCOL[r.cat]||'#333';
    const rootStar=r.is_root?'<span class="root-star" title="Aggregate Root">⭐</span>':'';
    const bcCls=r.is_root?'bc-tag is-root-bc':'bc-tag';
    const domCell=r.dominio_as_is?`<span class="dom-tag">${r.dominio_as_is}</span>`:'';
    const targetCell=r.target_term?`<code style="color:#93c5fd;font-size:10px">${r.target_term}</code>`:'';
    const regCell=r.regulatorio?`<span class="reg-tag">${r.regulatorio}</span>`:'';
    const taxCell=r.nodo_taxonomia?`<span style="font-size:9px;color:#6f8ce6">${r.nodo_taxonomia}</span>`:'';
    return `<tr class="${r.is_root?'is-root':''}">
      <td><span class="term">${r.term}</span>${rootStar}</td>
      <td><span class="tipo">${r.tipo}</span></td>
      <td>${r.tipo_dato&&r.tipo_dato!=='—'&&r.tipo_dato!=='?'?`<span class="tdato tdato-${r.tipo_dato}" title="${r.mascara||''}">${r.tipo_dato}</span>`:''}</td>
      <td><span class="cat" style="background:${catbg}">${CATLBL[r.cat]||r.cat}</span></td>
      <td class="mean">${(r.mean||'').replace(/</g,'&lt;')}</td>
      <td><span class="${bcCls}">${r.bc||'—'}</span></td>
      <td class="col-dom">${domCell}</td>
      <td class="deco col-deco">${r.deco||''}</td>
      <td>${aliasCell(r.term)}</td>
      <td><span class="badge ${nc}">${nl}</span></td>
      <td><span class="cat" style="background:${FTE[r.fuente][1]}">${FTE[r.fuente][0]}</span></td>
      <td><span class="cat" style="background:${(SCOPE[r.scope]||SCOPE['—'])[1]}">${(SCOPE[r.scope]||SCOPE['—'])[0]}</span></td>
      <td>${unitCell(r.unit)}</td>
      <td class="col-target" title="${(r.notas_sme||'').replace(/"/g,'&quot;')}">${targetCell}</td>
      <td class="col-reg">${regCell}</td>
      <td class="col-taxon">${taxCell}</td>
      <td class="num col-fn ${r.fn>=100?'hot':''}">${r.fn||''}</td>
      <td class="num ${r.fp>=50?'hot':''}">${r.fp||''}</td>
    </tr>`;
  }).join('');
  document.getElementById('count').textContent=`${rs.length} de ${DATA.length} términos`;
}
render();
</script>
<script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
<script>
try{mermaid.initialize({startOnLoad:true,securityLevel:'loose',theme:'dark',
  themeVariables:{fontFamily:'Inter, sans-serif',primaryColor:'#122152',primaryBorderColor:'#3D5FCD',
    primaryTextColor:'#EAEDF7',lineColor:'#6f8ce6',tertiaryColor:'#0d1a3d',
    attributeBackgroundColorOdd:'#0d1a3d',attributeBackgroundColorEven:'#132152'}});}catch(e){}
</script>
</body>
</html>"""

HTML = (HTML
    .replace("__DATA__",      DATA)
    .replace("__META__",      M)
    .replace("__ALIASES__",   ALIASES)
    .replace("__DATA_EFIM__", DATA_EFIM)
    .replace("__N_EFIM__",      str(N_EFIM))
    .replace("__N_EFIM_REAL__", str(N_EFIM_REAL))
    .replace("__N_EFIM_DASH__", str(N_EFIM_DASH))
    .replace("__HALLAZGOS__",    HALLAZGOS_H)
    .replace("__ENRICH_HERO__", ENRICH_HERO_H)
    .replace("__ENRICH_LOG__",  ENRICH_LOG_H)
    .replace("__BIANBARS__",  BIANBARS_H)
    .replace("__BCBARS__",    BCBARS_H)
    .replace("__ROOTS__",     ROOTS_H)
    .replace("__DTLAYERS__",  DTLAYERS_H)
    .replace("__ERDIAG__",    ERDIAG)
    .replace("__SPS__",       f"{meta['sps']:,}"))

out = BASE / "portal" / "vocabulary-catalog-bcop.CANDIDATE.html"
open(out, "w", encoding="utf-8").write(HTML)
print(f"vocabulary-catalog-bcop.CANDIDATE.html escrito · {len(rows)} términos "
      f"({bytipo['atómico']} atómicos · {bytipo['compuesto']} compuestos · {bytipo['candidato']} candidatos) · "
      f"{sum(1 for r in rows if r['is_root'])} aggregate roots marcados")