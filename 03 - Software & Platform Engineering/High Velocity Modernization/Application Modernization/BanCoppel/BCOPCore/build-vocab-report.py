#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-vocab-report.py — Genera vocabulary-report-bcop.html: reporte visual
autocontenido de TODO el vocabulario (átomos + compuestos + candidatos) con
métricas, filtros y tabla ordenable. Embebe los datos → funciona en file://.

Consume: vocabulary-inventory.json (de build-vocab-inventory.py)
Etapa 3 — Business Logic Extraction · Specialist Informix SPL · SPE-AM-001
"""
import json
import sys
from collections import Counter

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/BCOPCore/")
INV = json.load(open(BASE + "vocabulary-inventory.json", encoding="utf-8"))

# fila unificada para la tabla
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

# guarda: el 'scope' lo enriquece extract-dataflow.py DESPUÉS de build-vocab-inventory.py.
# si el inventory se regeneró sin re-correr ese paso, el scope se pierde (queda todo "—").
_sin_scope = sum(1 for r in rows if r.get("scope", "—") == "—")
if _sin_scope > len(rows) * 0.8:
    print(f"\n⚠️  ADVERTENCIA: {_sin_scope}/{len(rows)} términos SIN scope (columna 'Scope' saldrá vacía).\n"
          f"   El scope lo añade extract-dataflow.py. Córrelo ANTES de este reporte:\n"
          f"       python3 extract-dataflow.py && python3 build-vocab-report.py\n",
          file=sys.stderr)

# ── fuente de validación (cómo sabemos el significado = la certeza) ──
import re as _re
BIZ = _re.compile(r"bancoppel|afore|banxico|condusef|western|moneygram|coppel|codi|spei|"
                  r"clabe|comprobante|banca por internet|art\.61|reco|domiciliaci|remesa|"
                  r"quincena|oxxo|hipotec|préstamo|prestamo|inversión|msi|cep|rastreo|udi|cat |gat", _re.I)
def fuente(r):
    m = (r.get("mean") or "").lower()
    if "confirmado sme" in m or "sme" in m:            return "SME"
    if BIZ.search(m):                                   return "NEGOCIO"
    if r.get("fp", 0) >= 5:                             return "CODIGO"
    if r.get("est") == "conf":                          return "CONVENCION"
    if r.get("est") == "inf":                           return "INFERIDO"
    return "AMBIGUO"
for r in rows:
    r["fuente"] = fuente(r)

# métricas
byniv = Counter(r["nivel"] for r in rows)
bycat = Counter(r["cat"] for r in rows if r["cat"] != "?")
bytipo = Counter(r["tipo"] for r in rows)
byfte = Counter(r["fuente"] for r in rows)
meta = INV["meta"]

# ── sinónimos / alias: mismo concepto escrito de varias formas (deuda de nombrado) ──
elig = [r for r in rows if r["cat"] not in ("AMBIGUO", "?") and r.get("est") not in ("gap", "-")]
by_term = {r["term"]: r for r in elig}
parent = {t: t for t in by_term}
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
# anglicismos con equivalente en español dentro del core → preferimos el español
ANGLICISMOS = {"status", "mail", "email", "update", "insert", "delete", "select",
               "flag", "check", "log", "user", "account", "client", "payment",
               "transfer", "balance", "amount", "name", "date", "report"}
def _cscore(x, gs):
    t = x["term"]
    limpio = 0 if (t[-1:].isdigit() or _isplural(t, gs)) else 1  # ni versionado (bym2) ni plural (cheques)
    espanol = 0 if t in ANGLICISMOS else 1                       # si lo tenemos en español, es mejor
    return (limpio, espanol, len(t), (x.get("fp") or 0) + (x.get("fn") or 0))  # limpio -> español -> palabra completa -> frecuencia
canon = {}; canon_key = {}
for root, terms in _clusters.items():
    gs = {x["term"] for x in terms}
    c = max(terms, key=lambda x: _cscore(x, gs))
    canon_key[root] = c["term"]
    for t in terms:
        if t["term"] != c["term"]: canon[t["term"]] = c["term"]
n_concepts = len(_clusters); n_alias = sum(len(v) for v in _clusters.values())
n_collapsed = sum(len(v) - 1 for v in _clusters.values())
n_canonical = len(rows) - n_collapsed
# ── conteos deduplicados: solo canónicos + singletons (alias colapsados a su canónico) ──
_surv = [r for r in rows if r["term"] not in canon]
byniv_u = Counter(r["nivel"] for r in _surv)
bycat_u = Counter(r["cat"] for r in _surv if r["cat"] != "?")
bytipo_u = Counter(r["tipo"] for r in _surv)
byfte_u = Counter(r["fuente"] for r in _surv)
_alias = {}; _tg = {}
for root, terms in _clusters.items():
    g = sorted(t["term"] for t in terms)
    for t in terms:
        _alias[t["term"]] = {"g": g, "c": canon_key[root]}; _tg[t["term"]] = len(g)
for r in rows:
    r["nalias"] = _tg.get(r["term"], 0)
ALIASES = json.dumps(_alias, ensure_ascii=False)

# ── alineación a modelo de dominio bancario (BIAN Service Landscape) ──
BIAN = [
 ("Cliente / Party", r"cliente|\bcte\b|apoderad|beneficiari|persona|contacto|domicili|tel[eé]fon|celular|correo|\bfirma"),
 ("Cuentas y Depósitos", r"cuenta|saldo|dep[oó]sito|captaci|chequera|cheque|disponible|cuentahab|apertura|\bbym\b|piezas"),
 ("Cobranza y Recuperación", r"cobranz|recuperaci|reestructur|refinanci|moratori|quebranto|\bmora\b|castigo|\bciloc|frecpago|adeud|promesa"),
 ("Pagos y Transferencias", r"spei|\bpago|transferen|\borden\b|abono|cargo|clabe|rastreo|codi|dispersi|remesa|domiciliaci|traspaso"),
 ("Tarjetas", r"tarjeta|\btdc\b|pl[aá]stico|\bcvv\b|intercard|\bn[ií]p\b|token"),
 ("Crédito y Préstamos", r"cr[eé]dito|\bcred\b|pr[eé]stamo|pagar[eé]|amortiza|\bcuota|\bl[ií]nea|scoring|califica|bur[oó]|\bmsi\b|plazo|inter[eé]s|\bgat\b|\bcat\b|rendim"),
 ("Canales y Digital", r"canal|\bweb\b|m[oó]vil|\bbpi\b|cajero|\batm\b|sucursal|\bapp\b|clic|banca por internet|kiosko"),
 ("Contabilidad y Finanzas", r"contab|p[oó]liza|\bmayor\b|asiento|\bpase\b|c[eé]dula|balance|cnsif|conciliaci|devengo"),
 ("Riesgo y Cumplimiento", r"regulat|\bpld\b|lavado|\bisr\b|\biva\b|cnbv|art\.?\s*61|fiscal|ipab|tesofe|condusef|banxico|beneficencia|inactiv"),
 ("Servicing y Operaciones", r"aclaraci|solicitud|mensaj|notificaci|alerta|\bfolio\b|tr[aá]mite|reverso|cancelaci"),
 ("Datos de Referencia", r"cat[aá]logo|\btabla|c[oó]digo|codificaci|\btipo\b|denominaci|\bclave\b|par[aá]metro|producto"),
]
def bian_of(r):
    s = (r["term"] + " " + (r.get("mean") or "")).lower()
    for name, pat in BIAN:
        if _re.search(pat, s): return name
    return "Transversal / Técnico"
for r in rows: r["bian"] = bian_of(r)
bybian = Counter(r["bian"] for r in rows)

# ── hallazgos principales ──
pct_alta = round(100 * byniv.get("ALTA", 0) / len(rows)) if rows else 0
pct_hard = round(100 * byfte.get("CODIGO", 0) / len(rows)) if rows else 0
_biz = [(n, v) for n, v in bybian.most_common() if n != "Transversal / Técnico"]
_tec = bybian.get("Transversal / Técnico", 0)
pct_biz = round(100 * sum(v for _, v in _biz) / len(rows)) if rows else 0
H_cards = [
 ("El léxico del negocio",
  f"El core habla un vocabulario de <b>{len(rows)} términos</b> — {bytipo['atómico']} atómicos y {bytipo['compuesto']} compuestos — destilado de {meta['sps']:,} SPs. Es el idioma del negocio fosilizado en el código."),
 ("Dónde vive el negocio",
  f"El <b>{pct_biz}%</b> del vocabulario mapea a dominios del modelo <b>BIAN</b> — sobre todo <b>{_biz[0][0]}</b> ({_biz[0][1]}), {_biz[1][0]} ({_biz[1][1]}) y {_biz[2][0]} ({_biz[2][1]}). El {100-pct_biz}% restante es léxico transversal (verbos, prefijos y términos técnicos usados en todos los dominios)."),
 ("Deuda semántica por resolver",
  f"<b>{byfte.get('AMBIGUO', 0)} términos ambiguos</b> + {bytipo['candidato']} candidatos sin clasificar — la cola a resolver antes de sembrar el modelo de dominio del target."),
 ("Sinónimos, alias y plurales · deuda de nombrado",
  f"El mismo concepto se escribe de varias formas — sinónimos (cliente/cte), abreviaturas (mov/movimiento) y <b>plurales</b> (cheque/cheques, producto/productos): <b>{n_concepts} conceptos</b> en <b>{n_alias} términos</b>. Al normalizar, los {len(rows)} términos colapsan a ~<b>{n_canonical} conceptos únicos</b> — el canónico es la forma completa singular (movimiento, no mov) y se conservan todos los alias para no perder trazabilidad."),
]
HALLAZGOS_H = "".join(f'<div class="hcard"><div class="hn">{n}</div>{t}</div>' for n, t in H_cards)
_bmax = max((v for _, v in _biz), default=1) or 1
BIANBARS_H = "".join(
 f'<div class="bianrow"><div class="bl">{n}</div><div class="bbar"><i class="{"top" if i==0 else ""}" '
 f'style="width:{round(100*v/_bmax)}%"></i></div><div class="bv">{v}</div></div>'
 for i, (n, v) in enumerate(_biz))
BIANBARS_H += (f'<div class="bianrow tec"><div class="bl">Transversal / Técnico</div>'
 f'<div class="btec">léxico genérico — verbos, prefijos y términos técnicos que no mapean a un dominio de negocio</div>'
 f'<div class="bv">{_tec}</div></div>')

# ── modelo entidad-relación de dominios (Mermaid ER · relaciones del call graph real) ──
try:
    _CG = json.load(open(BASE + "callgraph-data.json", encoding="utf-8"))
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
       "Riesgo y Cumplimiento": "RIESGO", "Servicing y Operaciones": "SERVICING", "Datos de Referencia": "DATOS_REF"}
_datt = {}
for r in sorted(rows, key=lambda x: -((x.get("fp") or 0) + (x.get("fn") or 0))):
    d = r.get("bian")
    if d in EID and r["cat"] in ("ENTIDAD", "ACCION", "REG"):
        lst = _datt.setdefault(d, [])
        raw = canon.get(r["term"], r["term"])       # colapsa alias → término canónico
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

DATA = json.dumps(rows, ensure_ascii=False, separators=(",", ":"))
M = json.dumps({"byniv": byniv, "bycat": bycat, "bytipo": bytipo, "byfte": byfte,
                "byniv_u": byniv_u, "bycat_u": bycat_u, "bytipo_u": bytipo_u, "byfte_u": byfte_u,
                "meta": meta, "total": len(rows), "total_u": len(_surv)}, ensure_ascii=False)

HTML = """<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>BCOPCore · Reporte de Vocabulario SPL</title>
<style>
:root{--bg:#0a1330;--bg2:#0d1a3d;--panel:#132152;--line:#26317c;--magenta:#F0D224;--blue:#3D5FCD;--txt:#EAEDF7;--muted:#9aa4c4}
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
/* hallazgos + BIAN (antes del detalle) */
.lead{padding:22px 24px 6px}
.lhead{font-size:17px;font-weight:800;letter-spacing:-.01em;margin-bottom:12px}
.lsub{font-size:12px;color:var(--muted);margin:-4px 0 14px;max-width:84ch}
.hgrid{display:grid;grid-template-columns:repeat(2,1fr);gap:13px}
@media(max-width:760px){.hgrid{grid-template-columns:1fr}}
.hcard{background:rgba(255,255,255,.05);backdrop-filter:blur(14px) saturate(140%);-webkit-backdrop-filter:blur(14px) saturate(140%);border:1px solid rgba(255,255,255,.1);border-left:3px solid var(--magenta);box-shadow:0 8px 26px rgba(0,0,0,.3),inset 0 1px 0 rgba(255,255,255,.08);border-radius:14px;padding:15px 18px;font-size:13px;color:var(--muted);line-height:1.55}
.hcard b{color:#fff;font-weight:700}.hcard i{color:#e4eaff}.hcard .hn{font-size:11px;font-weight:800;color:var(--magenta);letter-spacing:.05em;text-transform:uppercase;margin-bottom:7px}
.bianwrap{background:rgba(255,255,255,.04);backdrop-filter:blur(14px) saturate(140%);-webkit-backdrop-filter:blur(14px) saturate(140%);border:1px solid rgba(255,255,255,.09);border-radius:14px;padding:16px 20px;box-shadow:inset 0 1px 0 rgba(255,255,255,.07)}
.bianrow{display:grid;grid-template-columns:210px 1fr 46px;gap:12px;align-items:center;padding:4px 0;font-size:12.5px}
@media(max-width:640px){.bianrow{grid-template-columns:130px 1fr 40px}}
.bl{color:#dfe6ff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.bbar{background:#0c1747;border-radius:6px;height:16px;overflow:hidden}
.bbar i{display:block;height:100%;background:linear-gradient(90deg,var(--blue),#6f8ce6);border-radius:6px}
.bbar i.top{background:linear-gradient(90deg,var(--magenta),#f6e27a)}
.bv{color:var(--muted);text-align:right;font-variant-numeric:tabular-nums;font-weight:700}
.bianrow.tec{opacity:.72;border-top:1px solid var(--line);margin-top:8px;padding-top:10px}
.btec{font-size:11px;color:var(--muted);font-style:italic;align-self:center}
.ermwrap{overflow-x:auto}.ermwrap .mermaid{text-align:center;min-height:300px}
.synrow{display:grid;grid-template-columns:190px 1fr;gap:14px;align-items:baseline;padding:6px 0;border-bottom:1px solid rgba(38,49,124,.5);font-size:12.5px}
.syc{color:#dfe6ff;font-weight:700}
.sya{display:flex;flex-wrap:wrap;gap:6px}
.sychip{background:#0c1747;border:1px solid var(--line);border-radius:12px;padding:2px 9px;font-size:11px;color:var(--muted);font-family:'Cascadia Code',monospace}
.sychip.can{background:rgba(240,210,36,.12);border-color:rgba(240,210,36,.45);color:var(--magenta);font-weight:700}
.syntag{font-size:9px;font-weight:700;color:var(--magenta);background:rgba(240,210,36,.1);border:1px solid rgba(240,210,36,.3);border-radius:8px;padding:0 5px;margin-left:5px;font-family:'Inter',sans-serif}
/* tiles */
#tiles{display:flex;gap:8px;padding:10px 20px;flex-wrap:wrap;flex-shrink:0}
.tile{background:var(--panel);border-radius:8px;padding:8px 14px;min-width:92px;border-left:3px solid var(--line)}
.tile .n{font-size:20px;font-weight:800}
.tile .l{font-size:9px;color:var(--muted);text-transform:uppercase;letter-spacing:.06em}
.tile .sub{font-size:8.5px;color:#5b6580;margin-top:2px;font-variant-numeric:tabular-nums}
.tile.alta{border-left-color:#22c55e}.tile.media{border-left-color:#f59e0b}
.tile.amb{border-left-color:#ef4444}.tile.cand{border-left-color:#6b7280}
.tile.tot{border-left-color:var(--magenta)}
/* barras categoría */
#cats,#ftes{display:flex;gap:6px;padding:0 20px 8px;flex-wrap:wrap;flex-shrink:0}
#ftes .lead{font-size:9px;color:var(--muted);align-self:center;letter-spacing:.06em}
.catbar{background:var(--panel);border-radius:6px;padding:5px 10px;font-size:10px;display:flex;gap:6px;align-items:center}
.catbar b{color:var(--txt)}.catbar .dot{width:8px;height:8px;border-radius:2px}
/* controls */
#ctrl{display:flex;gap:10px;padding:8px 20px;align-items:center;flex-wrap:wrap;flex-shrink:0;
  border-top:1px solid var(--line);border-bottom:1px solid var(--line);background:var(--bg2)}
#q{background:var(--panel);border:1px solid var(--line);border-radius:6px;color:var(--txt);
  padding:6px 10px;font-size:12px;width:240px;outline:none}
#q:focus{border-color:var(--magenta)}
.fgroup{display:flex;gap:4px;align-items:center}
.fgroup .lbl{font-size:9px;color:var(--muted);text-transform:uppercase;letter-spacing:.06em;margin-right:2px}
.chip{background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:3px 10px;
  font-size:10px;color:var(--muted);cursor:pointer;user-select:none;transition:all .15s}
.chip:hover{border-color:var(--muted)}
.chip.on{background:#12235a;border-color:var(--magenta);color:var(--txt)}
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
footer{font-size:9px;color:var(--muted);padding:6px 20px;flex-shrink:0;border-top:1px solid var(--line)}
</style>
</head>
<body>
<header>
  <div class="logo-wrap">
    <img src="bancoppel-logo.png" alt="BanCoppel">
    <div class="divider"></div>
  </div>
  <div class="meta">
    <div class="breadcrumb">BCOPCore · <span>SPE-AM-001</span> · Gemelo Cognitivo del Sistema</div>
    <h1>Reporte de Vocabulario SPL</h1>
    <div class="sub">IBM Informix IDS 14.10 · __SPS__ stored procedures analizados · Etapa 3 — Business Logic Extraction</div>
  </div>
  <div class="badge-wrap">
    <span class="hbadge etapa">Etapa 3</span>
    <span class="hbadge tech">Informix SPL</span>
  </div>
</header>

<div class="lead">
  <div class="lhead">Hallazgos principales</div>
  <div class="hgrid">__HALLAZGOS__</div>
  <div class="lhead" style="margin-top:28px">Vocabulario alineado a un modelo de dominio bancario · BIAN</div>
  <div class="lsub">Cada término del vocabulario mapeado a un dominio del <b>BIAN Service Landscape</b> — dónde vive el lenguaje del negocio dentro del core.</div>
  <div class="bianwrap">__BIANBARS__</div>
  <div class="lhead" style="margin-top:28px">Modelo entidad-relación de dominios</div>
  <div class="lsub">Los dominios de negocio como <b>entidades</b> (con su <b>top-10 de términos</b> como atributos, ordenados por frecuencia de uso) y sus <b>relaciones</b> derivadas del grafo de llamadas real — el número en cada relación = nº de llamadas entre SPs de esos dominios.</div>
  <div class="bianwrap ermwrap"><pre class="mermaid">__ERDIAG__</pre></div>
  <div class="lhead" style="margin-top:30px">Detalle del vocabulario</div>
  <div class="lsub">Explora todos los términos: filtra por tipo, confiabilidad, categoría, evidencia y scope; ordena por cualquier columna.</div>
</div>

<div id="tiles"></div>
<div id="cats"></div>
<div id="ftes"></div>

<div id="ctrl">
  <input id="q" type="text" placeholder="Buscar término o significado…" autocomplete="off">
  <div class="fgroup"><span class="lbl">Tipo</span><div id="ftipo"></div></div>
  <div class="fgroup"><span class="lbl">Confiab.</span><div id="fniv"></div></div>
  <div class="fgroup"><span class="lbl">Categoría</span><div id="fcat"></div></div>
  <div class="fgroup"><span class="lbl">Evidencia</span><div id="ffte"></div></div>
  <div class="fgroup"><span class="lbl">Scope</span><div id="fscope"></div></div>
  <span id="count"></span>
</div>

<div id="wrap">
  <table>
    <thead><tr>
      <th data-k="term">Término <span class="ar">↕</span></th>
      <th data-k="tipo">Tipo <span class="ar">↕</span></th>
      <th data-k="cat">Categoría <span class="ar">↕</span></th>
      <th data-k="mean">Significado <span class="ar">↕</span></th>
      
      <th data-k="deco">Descomposición <span class="ar">↕</span></th>
      <th data-k="nalias">Alias / sinónimos <span class="ar">↕</span></th>
      <th data-k="nivel">Confiab. <span class="ar">↕</span></th>
      <th data-k="fuente">Evidencia <span class="ar">↕</span></th>
      <th data-k="scope">Scope <span class="ar">↕</span></th>
      <th data-k="fn" class="num">frec-nom <span class="ar">↕</span></th>
      <th data-k="fp" class="num">frec-par <span class="ar">↕</span></th>
    </tr></thead>
    <tbody id="tb"></tbody>
  </table>
</div>
<footer>🟢 Alta (confirmada por código/param) · 🟡 Media (inferida) · 🔴 Ambigua (requiere SME) · ⚪ Candidato (sin clasificar). frec-par = evidencia de código. Fuente: sp_vocab.py + vocabulary-inventory.json</footer>

<script>
const DATA = __DATA__;
const M = __META__;
const ALIASES = __ALIASES__;
function aliasCell(t){const a=ALIASES[t]; if(!a) return '<span style="color:#4a5578">-</span>'; return a.g.map(x=>'<span class="sychip'+(x===a.c?' can':'')+'">'+x+'</span>').join(' ');}

const NIV = {ALTA:['🟢 Alta','b-alta'],MEDIA:['🟡 Media','b-media'],AMBIGUA:['🔴 Ambigua','b-amb'],CANDIDATO:['⚪ Candidato','b-cand']};
const CATCOL = {PREFIJO:'#3d4666',ACCION:'#1e5a8a',ENTIDAD:'#2e6b48',MODIF:'#7a6018',REG:'#8b2020',AMBIGUO:'#6b3080','?':'#333'};
const CATLBL = {PREFIJO:'prefijo',ACCION:'acción',ENTIDAD:'entidad',MODIF:'modif',REG:'regulatorio',AMBIGUO:'ambiguo','?':'—'};
const FTE = {CODIGO:['🔬 Código','#1e5a8a'],SME:['🧑 SME','#2e6b48'],NEGOCIO:['🌐 Negocio','#6b3080'],
  CONVENCION:['📖 Convención','#7a6018'],INFERIDO:['💭 Inferido','#4a4a5a'],AMBIGUO:['❓ Ambiguo','#8b2020']};
const SCOPE = {'TRASCIENDE':['🟢 Trasciende','#2e6b48'],'EFÍMERA-CÁLCULO':['🔴 Efím-cálculo','#8b2020'],
  'EFÍMERA':['⚪ Efímera','#4a4a5a'],'MIXTO':['🔵 Mixto','#1e5a8a'],'—':['—','#333']};

// TILES — conteos deduplicados (canónicos, sin alias/plurales); bruto entre paréntesis
const tiles = [
  ['tot', M.total_u, 'Términos únicos', M.total],
  ['tot', M.bytipo_u['atómico']||0, 'Atómicos', M.bytipo['atómico']||0],
  ['tot', M.bytipo_u['compuesto']||0, 'Compuestos', M.bytipo['compuesto']||0],
  ['alta', M.byniv_u.ALTA||0, '🟢 Alta'],
  ['media', M.byniv_u.MEDIA||0, '🟡 Media'],
  ['amb', M.byniv_u.AMBIGUA||0, '🔴 Ambigua'],
  ['cand', M.byniv_u.CANDIDATO||0, '⚪ Candidatos'],
];
document.getElementById('tiles').innerHTML = tiles.map(([c,n,l,raw])=>
  `<div class="tile ${c}"><div class="n">${n}</div><div class="l">${l}</div>`+
  ((raw!=null&&raw!==n)?`<div class="sub">${raw} con alias</div>`:``)+`</div>`).join('');

// CATEGORY BARS — deduplicado
document.getElementById('cats').innerHTML = Object.entries(M.bycat_u)
  .sort((a,b)=>b[1]-a[1])
  .map(([c,n])=>`<div class="catbar"><span class="dot" style="background:${CATCOL[c]}"></span>${CATLBL[c]||c} <b>${n}</b></div>`).join('');

// BARRA DE EVIDENCIA (cómo se validó cada término = la certeza) — deduplicado
document.getElementById('ftes').innerHTML = '<span class="lead">EVIDENCIA / CERTEZA:</span>' +
  ['CODIGO','SME','NEGOCIO','CONVENCION','INFERIDO','AMBIGUO'].filter(f=>M.byfte_u[f])
  .map(f=>`<div class="catbar"><span class="dot" style="background:${FTE[f][1]}"></span>${FTE[f][0]} <b>${M.byfte_u[f]}</b></div>`).join('');

// FILTERS state
let fTipo=new Set(), fNiv=new Set(), fCat=new Set(), fFte=new Set(), fScope=new Set(), q='';
function mkChips(elId, vals, set, labelFn){
  document.getElementById(elId).innerHTML = vals.map(v=>`<span class="chip" data-v="${v}">${labelFn(v)}</span>`).join('');
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
mkChips('fscope',['TRASCIENDE','EFÍMERA-CÁLCULO','EFÍMERA','MIXTO'],fScope,v=>SCOPE[v][0]);
document.getElementById('q').oninput=e=>{q=e.target.value.toLowerCase();render();};

// SORT
let sortK='fp', sortDir=-1;
document.querySelectorAll('thead th').forEach(th=>th.onclick=()=>{
  const k=th.dataset.k;
  if(sortK===k) sortDir*=-1; else {sortK=k; sortDir=(k==='fn'||k==='fp')?-1:1;}
  render();
});

const tb=document.getElementById('tb');
function render(){
  let rows=DATA.filter(r=>{
    if(fTipo.size && !fTipo.has(r.tipo)) return false;
    if(fNiv.size && !fNiv.has(r.nivel)) return false;
    if(fCat.size && !fCat.has(r.cat)) return false;
    if(fFte.size && !fFte.has(r.fuente)) return false;
    if(fScope.size && !fScope.has(r.scope)) return false;
    if(q && !(r.term.toLowerCase().includes(q) || (r.mean||'').toLowerCase().includes(q))) return false;
    return true;
  });
  rows.sort((a,b)=>{
    let x=a[sortK], y=b[sortK];
    if(typeof x==='number'){return (x-y)*sortDir;}
    return String(x||'').localeCompare(String(y||''))*sortDir;
  });
  tb.innerHTML=rows.map(r=>{
    const [nl,nc]=NIV[r.nivel]||['—','b-cand'];
    const catbg=CATCOL[r.cat]||'#333';
    return `<tr>
      <td><span class="term">${r.term}</span></td>
      <td><span class="tipo">${r.tipo}</span></td>
      <td><span class="cat" style="background:${catbg}">${CATLBL[r.cat]||r.cat}</span></td>
      <td class="mean">${(r.mean||'').replace(/</g,'&lt;')}</td>
      <td class="deco">${r.deco||''}</td>
      <td>${aliasCell(r.term)}</td>
      <td><span class="badge ${nc}">${nl}</span></td>
      <td><span class="cat" style="background:${FTE[r.fuente][1]}">${FTE[r.fuente][0]}</span></td>
      <td><span class="cat" style="background:${(SCOPE[r.scope]||SCOPE['—'])[1]}">${(SCOPE[r.scope]||SCOPE['—'])[0]}</span></td>
      <td class="num ${r.fn>=100?'hot':''}">${r.fn||''}</td>
      <td class="num ${r.fp>=50?'hot':''}">${r.fp||''}</td>
    </tr>`;
  }).join('');
  document.getElementById('count').textContent=`${rows.length} de ${DATA.length} términos`;
}
render();
</script>
<script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
<script>
try{ mermaid.initialize({startOnLoad:true, securityLevel:'loose', theme:'dark',
  themeVariables:{fontFamily:'Inter, sans-serif', primaryColor:'#122152', primaryBorderColor:'#3D5FCD',
    primaryTextColor:'#EAEDF7', lineColor:'#6f8ce6', tertiaryColor:'#0d1a3d',
    attributeBackgroundColorOdd:'#0d1a3d', attributeBackgroundColorEven:'#132152'}}); }catch(e){}
</script>
</body>
</html>"""

HTML = (HTML.replace("__DATA__", DATA).replace("__META__", M)
            .replace("__HALLAZGOS__", HALLAZGOS_H).replace("__BIANBARS__", BIANBARS_H)
            .replace("__ERDIAG__", ERDIAG)
            .replace("__ALIASES__", ALIASES)
            .replace("__SPS__", f"{meta['sps']:,}"))
open(BASE + "vocabulary-report-bcop.html", "w", encoding="utf-8").write(HTML)
print(f"vocabulary-report-bcop.html escrito · {len(rows)} términos "
      f"({bytipo['atómico']} atómicos · {bytipo['compuesto']} compuestos · {bytipo['candidato']} candidatos)")