#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-vocab-report.py — Genera vocab-report-gentera.html: reporte visual
autocontenido del vocabulario SAP ABAP de Gentera con métricas, filtros y
tabla ordenable. Embebe los datos → funciona en file://.

Consume: vocab-gentera.json (de extract-vocabulary.py)
         objects-inventory.json (de parse-abap.py) — para callgraph
Produce: vocab-report-gentera.html

Etapa 1-3 · GENCore · SPE-AM-002 · Gemelo Cognitivo SAP ABAP
"""
import json
import re
import sys
from collections import Counter
from pathlib import Path

BASE     = Path(__file__).parent
VOCAB_F  = BASE / "vocab-gentera.json"
INV_F    = BASE / "objects-inventory.json"
OUT_FILE = BASE / "vocab-report-gentera.html"

if not VOCAB_F.exists():
    print("⚠  vocab-gentera.json no encontrado. Corre primero: python3 extract-vocabulary.py")
    sys.exit(1)

INV  = json.loads(VOCAB_F.read_text(encoding='utf-8'))
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

# ── fuente de validación ──────────────────────────────────────────────────────
BIZ_RE = re.compile(
    r"microfinanz|crédito|credito|cobranza|cartera|ciclo|promotor|grupo solidario|"
    r"ifrs|cnbv|condusef|banxico|ipab|tesofe|sat\b|"
    r"pago|transferen|abono|cargo|spei|codi|dispersi|"
    r"contab|asiento|póliza|poliza|cierre|estado financiero|"
    r"cliente|cuentahabiente|beneficiari|"
    r"inter[eé]s|amortiza|plazo|tasa|comisi|"
    r"riesgo|regulat|cumplim|audit",
    re.I
)
def fuente(r):
    m = (r.get("mean") or "").lower()
    if "confirmado sme" in m or "sme" in m:  return "SME"
    if BIZ_RE.search(m):                      return "NEGOCIO"
    if r.get("fp", 0) >= 3:                   return "CODIGO"
    if r.get("est") == "conf":                return "CONVENCION"
    if r.get("est") == "inf":                 return "INFERIDO"
    return "AMBIGUO"
for r in rows:
    r["fuente"] = fuente(r)

meta   = INV["meta"]
byniv  = Counter(r["nivel"]            for r in rows)
bycat  = Counter(r["cat"]              for r in rows if r["cat"] != "?")
bytipo = Counter(r["tipo"]             for r in rows)
byfte  = Counter(r["fuente"]           for r in rows)

# ── sinónimos / alias (union-find) ────────────────────────────────────────────
elig    = [r for r in rows if r["cat"] not in ("AMBIGUO", "?") and r.get("est") not in ("gap", "-")]
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
    key = re.sub(r"[^a-z0-9 ]", "", (r.get("mean") or "").lower().split("(")[0].split(" / ")[0]).strip()
    if key and key not in ("sin clasificar", "inferido", "confirmar con sme"):
        _mg.setdefault(key, []).append(r["term"])
for _ts in _mg.values():
    for _t in _ts[1:]: _union(_ts[0], _t)
for _t, _r in by_term.items():
    for _pl in (_t + "s", _t + "es"):
        if _pl in by_term and by_term[_pl]["cat"] == _r["cat"]: _union(_t, _pl)
_comp = {}
for _t in parent: _comp.setdefault(_find(_t), []).append(_t)
_clusters   = {root: [by_term[t] for t in ts] for root, ts in _comp.items() if len(ts) > 1}
ANGLICISMOS = {"status","event","range","instance","result","name","flag","active",
               "get","set","load","check","type","code","mode","level","key"}
def _isplural(t, gs): return (t.endswith("s") and t[:-1] in gs) or (t.endswith("es") and t[:-2] in gs)
def _cscore(x, gs):
    t = x["term"]
    limpio  = 0 if (t[-1:].isdigit() or _isplural(t, gs)) else 1
    espanol = 0 if t.lower() in ANGLICISMOS else 1
    return (limpio, espanol, len(t), (x.get("fp") or 0) + (x.get("fn") or 0))
canon = {}; canon_key = {}
for root, terms in _clusters.items():
    gs = {x["term"] for x in terms}
    c  = max(terms, key=lambda x: _cscore(x, gs))
    canon_key[root] = c["term"]
    for t in terms:
        if t["term"] != c["term"]: canon[t["term"]] = c["term"]
n_concepts = len(_clusters)
n_alias    = sum(len(v) for v in _clusters.values())
n_collapsed= sum(len(v) - 1 for v in _clusters.values())
n_canonical= len(rows) - n_collapsed
_surv      = [r for r in rows if r["term"] not in canon]
byniv_u    = Counter(r["nivel"]            for r in _surv)
bycat_u    = Counter(r["cat"]              for r in _surv if r["cat"] != "?")
bytipo_u   = Counter(r["tipo"]             for r in _surv)
byfte_u    = Counter(r["fuente"]           for r in _surv)
_alias = {}; _tg = {}
for root, terms in _clusters.items():
    g = sorted(t["term"] for t in terms)
    for t in terms:
        _alias[t["term"]] = {"g": g, "c": canon_key[root]}; _tg[t["term"]] = len(g)
for r in rows:
    r["nalias"] = _tg.get(r["term"], 0)
ALIASES = json.dumps(_alias, ensure_ascii=False)

# ── alineación BIAN + módulo SAP ──────────────────────────────────────────────
# Patrones BIAN adaptados para microfinanzas (Gentera / Compartamos Banco)
BIAN = [
    ("Microfinanzas y Crédito",
     r"crédito|credito|préstamo|prestamo|cartera|microfinanz|grupo solidario|ciclo|"
     r"cobranza|promotor|amortiza|plazo|tasa|inter[eé]s|comisi|pagar[eé]|"
     r"event|active|tvarvc|flag"),
    ("Cliente / Party",
     r"cliente|\bcte\b|apoderad|beneficiari|persona|contacto|domicili|tel[eé]fon|celular|correo|firma"),
    ("Cuentas y Depósitos",
     r"cuenta|saldo|dep[oó]sito|captaci|chequera|cheque|disponible|apertura"),
    ("Pagos y Transferencias",
     r"spei|\bpago|transferen|abono|cargo|clabe|codi|dispersi|remesa|domiciliaci|traspaso"),
    ("Contabilidad y Finanzas",
     r"contab|p[oó]liza|asiento|balance|conciliaci|devengo|cierre|diario|mayor"),
    ("Riesgo y Cumplimiento",
     r"ifrs|regulat|\bpld\b|lavado|\bisr\b|\biva\b|cnbv|fiscal|ipab|tesofe|condusef|"
     r"banxico|inactiv|audit|riesgo|cumplim"),
    ("Canales y Digital",
     r"canal|\bweb\b|m[oó]vil|cajero|\batm\b|sucursal|\bapp\b|banca por internet"),
    ("Servicing y Operaciones",
     r"aclaraci|solicitud|mensaj|notificaci|alerta|\bfolio\b|tr[aá]mite|reverso|cancelaci"),
    ("Datos de Referencia",
     r"cat[aá]logo|\btabla|c[oó]digo|codificaci|\btipo\b|denominaci|\bclave\b|par[aá]metro|producto"),
]

# Mapeo de módulo SAP (basado en tokens)
SAP_MODULES = {
    r"fi|contab|asiento|p[oó]liza|bkpf|bseg|devengo":      "SAP FI",
    r"co|costo|centro|rentabilidad|coas|cosp":              "SAP CO",
    r"sd|venta|orden|vbak|vbap|ciclo|crédito|credito":      "SAP SD",
    r"mm|material|compra|ekko|ekpo|mara|marc":              "SAP MM",
    r"hr|hcm|nomina|nómina|empleado|promotor|pa0001|pa0002":"SAP HCM",
    r"tvarvc|tvarv|selecci|criterio|par[aá]metro":          "SAP Basis/Customizing",
    r"ifrs|regulat|cnbv|fiscal":                            "SAP Regulatorio",
    r"bapi|rfc|idoc|interfaz":                              "SAP Integration",
}

def bian_of(r):
    s = (r["term"] + " " + (r.get("mean") or "")).lower()
    for name, pat in BIAN:
        if re.search(pat, s): return name
    return "Transversal / Técnico"
for r in rows: r["bian"] = bian_of(r)
bybian = Counter(r["bian"] for r in rows)

# ── hallazgos principales ─────────────────────────────────────────────────────
pct_alta = round(100 * byniv.get("ALTA", 0) / len(rows)) if rows else 0
_biz  = [(n, v) for n, v in bybian.most_common() if n != "Transversal / Técnico"]
_tec  = bybian.get("Transversal / Técnico", 0)
pct_biz = round(100 * sum(v for _, v in _biz) / len(rows)) if rows else 0
_biz_top3 = _biz[:3] if len(_biz) >= 3 else _biz + [("—", 0)] * (3 - len(_biz))
n_obj = meta.get("objetos", 1)
reg_terms = [r for r in rows if r.get("cat") == "REG"]

H_cards = [
    ("Vocabulario extraído hasta ahora",
     f"Con <b>{n_obj} objeto(s) ABAP analizado(s)</b>, el Gemelo Cognitivo Capa 1 cuenta con "
     f"<b>{len(rows)} términos</b> — {bytipo['atómico']} atómicos y {bytipo['compuesto']} compuestos. "
     f"Este es el idioma del negocio fosilizado en el código SAP de Gentera. "
     f"El corpus crecerá conforme se carguen más archivos en source/."),
    ("Señales de negocio detectadas",
     f"El <b>{pct_biz}%</b> del vocabulario mapea a dominios BIAN. "
     f"Dominio principal: <b>{_biz_top3[0][0]}</b> ({_biz_top3[0][1]} términos). "
     + (f"<br><b>⚠ Regulatorio:</b> {len(reg_terms)} término(s) regulatorio(s) detectado(s): "
        f"<code>{'</code>, <code>'.join(r['term'] for r in reg_terms)}</code>. "
        f"Confirmar contexto exacto con SME IFRS antes de continuar." if reg_terms else "")),
    ("Estado de clasificación",
     f"<b>{byfte.get('AMBIGUO', 0)} términos ambiguos</b> + {bytipo['candidato']} candidatos sin clasificar. "
     f"Recomendación: validar <code>TVARVC</code> y los métodos de feature flag con SME de negocio — "
     f"son el mecanismo de control de procesos del sistema."),
    ("Próximos pasos para ampliar el corpus",
     f"Para obtener un Gemelo Cognitivo más completo, solicitar al cliente: "
     f"(1) export TADIR/TRDIR del namespace <code>/CBB/</code>, "
     f"(2) bulk export de fuentes ABAP (ABAPGit o RFC_READ_REPORT), "
     f"(3) export CSV de tablas Z (DD02L filtrando <code>TABNAME LIKE '/CBB/%'</code>)."),
]
HALLAZGOS_H = "".join(f'<div class="hcard"><div class="hn">{n}</div>{t}</div>' for n, t in H_cards)

_bmax = max((v for _, v in _biz), default=1) or 1
BIANBARS_H = "".join(
    f'<div class="bianrow"><div class="bl">{n}</div>'
    f'<div class="bbar"><i class="{"top" if i == 0 else ""}" '
    f'style="width:{round(100 * v / _bmax)}%"></i></div>'
    f'<div class="bv">{v}</div></div>'
    for i, (n, v) in enumerate(_biz)
)
BIANBARS_H += (
    f'<div class="bianrow tec"><div class="bl">Transversal / Técnico</div>'
    f'<div class="btec">léxico genérico — verbos, prefijos y términos técnicos SAP</div>'
    f'<div class="bv">{_tec}</div></div>'
)

# ── ER diagram (Mermaid) ──────────────────────────────────────────────────────
try:
    _CG  = json.loads(INV_F.read_text(encoding="utf-8"))
    _cgn = [{'id': o['id']} for o in _CG.get('objetos', [])]
    _cge = [{'from': e['from'], 'to': e['to']} for e in _CG.get('callgraph', [])]
except Exception:
    _cgn, _cge = [], []

def _bian_name(nm):
    s = nm.lower()
    for name, pat in BIAN:
        if re.search(pat, s): return name
    return "Transversal / Técnico"

_ndom = {}
for nd in _cgn:
    nid = nd.get("id", "")
    nm  = nid.split("/")[-1] if "/" in nid else nid
    _ndom[nid] = _bian_name(nm)

_ew = Counter()
for e in _cge:
    a = _ndom.get(e.get("from")); b = _bian_name(e.get("to", ""))
    if a and b and a != b and "Transversal / Técnico" not in (a, b):
        _ew[tuple(sorted([a, b]))] += 1

EID = {
    "Microfinanzas y Crédito"  : "MICROCREDITO",
    "Cliente / Party"          : "CLIENTE",
    "Cuentas y Depósitos"      : "CUENTAS",
    "Pagos y Transferencias"   : "PAGOS",
    "Contabilidad y Finanzas"  : "CONTABILIDAD",
    "Riesgo y Cumplimiento"    : "RIESGO",
    "Canales y Digital"        : "CANALES",
    "Servicing y Operaciones"  : "SERVICING",
    "Datos de Referencia"      : "DATOS_REF",
}
_datt = {}
for r in sorted(rows, key=lambda x: -((x.get("fp") or 0) + (x.get("fn") or 0))):
    d = r.get("bian")
    if d in EID and r["cat"] in ("ENTIDAD", "ACCION", "REG"):
        lst  = _datt.setdefault(d, [])
        raw  = canon.get(r["term"], r["term"])
        t    = re.sub(r"[^a-z0-9_]", "", raw.lower())
        if len(lst) < 8 and t and t not in [a[1] for a in lst]:
            cn = {"ENTIDAD": "entidad", "ACCION": "accion", "REG": "regulatorio"}.get(r["cat"], "term")
            lst.append((cn, t))

_er = ["erDiagram"]
for dom, eid in EID.items():
    if dom in bybian:
        _er.append("  " + eid + " {")
        for c, t in (_datt.get(dom) or [("dominio", eid.lower())]):
            _er.append("    " + c + " " + t)
        _er.append("  }")
for (a, b), c in _ew.most_common(10):
    if a in EID and b in EID:
        _er.append('  ' + EID[a] + ' }o--o{ ' + EID[b] + ' : "' + str(c) + '"')
ERDIAG = "\n".join(_er)

# ── serializar datos para el HTML ─────────────────────────────────────────────
DATA = json.dumps(rows, ensure_ascii=False, separators=(",", ":"))
M    = json.dumps({
    "byniv": byniv, "bycat": bycat, "bytipo": bytipo, "byfte": byfte,
    "byniv_u": byniv_u, "bycat_u": bycat_u, "bytipo_u": bytipo_u, "byfte_u": byfte_u,
    "meta": meta, "total": len(rows), "total_u": len(_surv)
}, ensure_ascii=False)

# ── HTML ──────────────────────────────────────────────────────────────────────
# Colores Gentera/Compartamos: naranja primario + azul corporativo
# [DATO-REQUERIDO] confirmar colores exactos con brand guidelines Gentera
HTML = """<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>GENCore · Reporte de Vocabulario SAP ABAP</title>
<style>
:root{--bg:#06111f;--bg2:#091929;--panel:#0d2235;--line:#1a3a5c;--naranja:#E8521A;--blue:#2B5CA8;--txt:#EBF0F7;--muted:#8aa4c4}
*{box-sizing:border-box;margin:0;padding:0}
body{background:var(--bg);color:var(--txt);font-family:'Inter',system-ui,sans-serif;min-height:100vh}
header{background:linear-gradient(135deg,#0a1e38 0%,#1B3A8C 55%,#2045a8 100%);
  border-bottom:3px solid var(--naranja);padding:18px 28px;
  display:flex;align-items:center;gap:20px;
  box-shadow:0 4px 24px rgba(0,0,0,.5)}
header .logo-wrap{display:flex;align-items:center;gap:16px;flex-shrink:0}
header .divider{width:1px;height:40px;background:rgba(255,255,255,.2);flex-shrink:0}
header .meta{flex:1}
header .breadcrumb{font-size:10px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;
  color:rgba(255,255,255,.45);margin-bottom:5px}
header .breadcrumb span{color:var(--naranja)}
header h1{font-size:18px;font-weight:800;letter-spacing:-.01em;line-height:1.2}
header .sub{font-size:11px;color:#a0c4e8;margin-top:4px;line-height:1.4}
header .badge-wrap{display:flex;gap:8px;align-items:center;margin-left:auto;flex-shrink:0}
header .hbadge{font-size:10px;font-weight:700;padding:4px 12px;border-radius:20px;
  letter-spacing:.04em;white-space:nowrap}
header .hbadge.etapa{background:rgba(232,82,26,.15);border:1px solid rgba(232,82,26,.4);color:var(--naranja)}
header .hbadge.tech{background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.14);color:#c9d3f5}
.lead{padding:22px 24px 6px}
.lhead{font-size:17px;font-weight:800;letter-spacing:-.01em;margin-bottom:12px}
.lsub{font-size:12px;color:var(--muted);margin:-4px 0 14px;max-width:84ch}
.hgrid{display:grid;grid-template-columns:repeat(2,1fr);gap:13px}
@media(max-width:760px){.hgrid{grid-template-columns:1fr}}
.hcard{background:rgba(255,255,255,.05);backdrop-filter:blur(14px) saturate(140%);
  border:1px solid rgba(255,255,255,.1);border-left:3px solid var(--naranja);
  box-shadow:0 8px 26px rgba(0,0,0,.3),inset 0 1px 0 rgba(255,255,255,.08);
  border-radius:14px;padding:15px 18px;font-size:13px;color:var(--muted);line-height:1.55}
.hcard b{color:#fff;font-weight:700}.hcard code{background:#0d2235;border-radius:3px;padding:1px 5px;font-size:11px;color:#c8d8f4}
.hcard .hn{font-size:11px;font-weight:800;color:var(--naranja);letter-spacing:.05em;text-transform:uppercase;margin-bottom:7px}
.bianwrap{background:rgba(255,255,255,.04);backdrop-filter:blur(14px) saturate(140%);
  border:1px solid rgba(255,255,255,.09);border-radius:14px;padding:16px 20px;
  box-shadow:inset 0 1px 0 rgba(255,255,255,.07)}
.bianrow{display:grid;grid-template-columns:220px 1fr 46px;gap:12px;align-items:center;padding:4px 0;font-size:12.5px}
@media(max-width:640px){.bianrow{grid-template-columns:130px 1fr 40px}}
.bl{color:#dfe6ff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.bbar{background:#071424;border-radius:6px;height:16px;overflow:hidden}
.bbar i{display:block;height:100%;background:linear-gradient(90deg,var(--blue),#5e8de6);border-radius:6px}
.bbar i.top{background:linear-gradient(90deg,var(--naranja),#f09060)}
.bv{color:var(--muted);text-align:right;font-variant-numeric:tabular-nums;font-weight:700}
.bianrow.tec{opacity:.72;border-top:1px solid var(--line);margin-top:8px;padding-top:10px}
.btec{font-size:11px;color:var(--muted);font-style:italic;align-self:center}
.ermwrap{overflow-x:auto}.ermwrap .mermaid{text-align:center;min-height:200px}
#tiles{display:flex;gap:8px;padding:10px 20px;flex-wrap:wrap;flex-shrink:0}
.tile{background:var(--panel);border-radius:8px;padding:8px 14px;min-width:92px;border-left:3px solid var(--line)}
.tile .n{font-size:20px;font-weight:800}
.tile .l{font-size:9px;color:var(--muted);text-transform:uppercase;letter-spacing:.06em}
.tile .sub{font-size:8.5px;color:#4a6a80;margin-top:2px;font-variant-numeric:tabular-nums}
.tile.alta{border-left-color:#22c55e}.tile.media{border-left-color:#f59e0b}
.tile.amb{border-left-color:#ef4444}.tile.cand{border-left-color:#6b7280}
.tile.tot{border-left-color:var(--naranja)}
#cats,#ftes{display:flex;gap:6px;padding:0 20px 8px;flex-wrap:wrap;flex-shrink:0}
#ftes .lead{font-size:9px;color:var(--muted);align-self:center;letter-spacing:.06em}
.catbar{background:var(--panel);border-radius:6px;padding:5px 10px;font-size:10px;display:flex;gap:6px;align-items:center}
.catbar b{color:var(--txt)}.catbar .dot{width:8px;height:8px;border-radius:2px}
#ctrl{display:flex;gap:10px;padding:8px 20px;align-items:center;flex-wrap:wrap;flex-shrink:0;
  border-top:1px solid var(--line);border-bottom:1px solid var(--line);background:var(--bg2)}
#q{background:var(--panel);border:1px solid var(--line);border-radius:6px;color:var(--txt);
  padding:6px 10px;font-size:12px;width:240px;outline:none}
#q:focus{border-color:var(--naranja)}
.fgroup{display:flex;gap:4px;align-items:center}
.fgroup .lbl{font-size:9px;color:var(--muted);text-transform:uppercase;letter-spacing:.06em;margin-right:2px}
.chip{background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:3px 10px;
  font-size:10px;color:var(--muted);cursor:pointer;user-select:none;transition:all .15s}
.chip:hover{border-color:var(--muted)}
.chip.on{background:#12233a;border-color:var(--naranja);color:var(--txt)}
#count{font-size:10px;color:var(--muted);margin-left:auto}
#wrap{overflow:visible;padding:0 24px 40px}
table{width:100%;border-collapse:collapse;font-size:12px}
thead th{position:sticky;top:0;background:var(--bg2);text-align:left;padding:8px 10px;
  font-size:9px;text-transform:uppercase;letter-spacing:.06em;color:var(--muted);
  border-bottom:1px solid var(--line);cursor:pointer;white-space:nowrap;z-index:5}
thead th:hover{color:var(--txt)}
thead th .ar{opacity:.4;font-size:8px}
tbody td{padding:6px 10px;border-bottom:1px solid rgba(26,58,92,.5)}
tbody tr:hover{background:rgba(232,82,26,.07)}
.term{font-family:'Cascadia Code','Consolas',monospace;font-weight:700;color:#d0d8f0}
.deco{font-family:'Cascadia Code','Consolas',monospace;font-size:10px;color:#6f9ce6}
.mean{color:var(--txt)}
.num{text-align:right;font-variant-numeric:tabular-nums;color:var(--muted)}
.num.hot{color:#93c5fd;font-weight:600}
.badge{display:inline-block;font-size:9px;font-weight:700;padding:1px 7px;border-radius:10px;white-space:nowrap}
.b-alta{background:#052e16;color:#86efac}.b-media{background:#3a2a08;color:#fdba74}
.b-amb{background:#450a0a;color:#fca5a5}.b-cand{background:#1f2430;color:#9aa4b8}
.cat{font-size:9px;padding:1px 7px;border-radius:3px;font-weight:600}
.tipo{font-size:9px;color:var(--muted)}
.sychip{background:#071424;border:1px solid var(--line);border-radius:12px;padding:2px 9px;font-size:11px;color:var(--muted);font-family:'Cascadia Code',monospace}
.sychip.can{background:rgba(232,82,26,.12);border-color:rgba(232,82,26,.45);color:var(--naranja);font-weight:700}
footer{font-size:9px;color:var(--muted);padding:6px 20px;flex-shrink:0;border-top:1px solid var(--line)}
</style>
</head>
<body>
<header>
  <div class="logo-wrap">
    <div style="width:44px;height:44px;border-radius:8px;background:linear-gradient(135deg,var(--naranja),#c44010);
      display:flex;align-items:center;justify-content:center;font-weight:900;font-size:16px;color:#fff;letter-spacing:-.02em">
      GEN
    </div>
    <div class="divider"></div>
  </div>
  <div class="meta">
    <div class="breadcrumb">GENCore · <span>SPE-AM-002</span> · Gemelo Cognitivo del Sistema · Capa 1 — Lenguaje</div>
    <h1>Reporte de Vocabulario SAP ABAP</h1>
    <div class="sub">Namespace /CBB/ · __OBJS__ objeto(s) ABAP analizados · Etapa 1-3 — Business Logic Extraction</div>
  </div>
  <div class="badge-wrap">
    <span class="hbadge etapa">Etapa 1-3</span>
    <span class="hbadge tech">SAP ABAP · /CBB/</span>
  </div>
</header>

<div class="lead">
  <div class="lhead">Hallazgos principales</div>
  <div class="hgrid">__HALLAZGOS__</div>
  <div class="lhead" style="margin-top:28px">Vocabulario alineado a modelo de dominio bancario · BIAN</div>
  <div class="lsub">Cada término mapeado al <b>BIAN Service Landscape</b> adaptado para microfinanzas — dónde vive el lenguaje del negocio dentro del core SAP de Gentera.</div>
  <div class="bianwrap">__BIANBARS__</div>
  <div class="lhead" style="margin-top:28px">Modelo entidad-relación de dominios</div>
  <div class="lsub">Dominios como <b>entidades</b> (top-8 términos como atributos, por frecuencia) y <b>relaciones</b> derivadas del grafo de llamadas SAP real.</div>
  <div class="bianwrap ermwrap"><pre class="mermaid">__ERDIAG__</pre></div>
  <div class="lhead" style="margin-top:30px">Detalle del vocabulario</div>
  <div class="lsub">Explora todos los términos: filtra por tipo, confiabilidad, categoría, evidencia; ordena por cualquier columna.</div>
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
  <span id="count"></span>
</div>

<div id="wrap">
  <table>
    <thead><tr>
      <th data-k="term">Término <span class="ar">↕</span></th>
      <th data-k="tipo">Tipo <span class="ar">↕</span></th>
      <th data-k="cat">Categoría <span class="ar">↕</span></th>
      <th data-k="mean">Significado <span class="ar">↕</span></th>
      <th data-k="deco">Descomposición <span class="ar">↕</span></th>
      <th data-k="nalias">Alias <span class="ar">↕</span></th>
      <th data-k="nivel">Confiab. <span class="ar">↕</span></th>
      <th data-k="fuente">Evidencia <span class="ar">↕</span></th>
      <th data-k="fn" class="num">frec <span class="ar">↕</span></th>
    </tr></thead>
    <tbody id="tb"></tbody>
  </table>
</div>
<footer>🟢 Alta (confirmada) · 🟡 Media (inferida) · 🔴 Ambigua (requiere SME) · ⚪ Candidato (sin clasificar) · frec = evidencia en código · Fuente: parse-abap.py + extract-vocabulary.py</footer>

<script>
const DATA = __DATA__;
const M = __META__;
const ALIASES = __ALIASES__;
function aliasCell(t){
  const a=ALIASES[t];
  if(!a) return '<span style="color:#2a4a6a">-</span>';
  return a.g.map(x=>'<span class="sychip'+(x===a.c?' can':'')+'">'+x+'</span>').join(' ');
}
const NIV={ALTA:['🟢 Alta','b-alta'],MEDIA:['🟡 Media','b-media'],AMBIGUA:['🔴 Ambigua','b-amb'],CANDIDATO:['⚪ Candidato','b-cand']};
const CATCOL={PREFIJO:'#1e3a5c',ACCION:'#1e4a6a',ENTIDAD:'#1a5a3a',MODIF:'#4a4010',REG:'#7a1a10',AMBIGUO:'#4a1a6a','?':'#1a2a3a'};
const CATLBL={PREFIJO:'prefijo',ACCION:'acción',ENTIDAD:'entidad',MODIF:'modif',REG:'regulatorio',AMBIGUO:'ambiguo','?':'—'};
const FTE={CODIGO:['🔬 Código','#1e4a6a'],SME:['🧑 SME','#1a5a3a'],NEGOCIO:['🌐 Negocio','#4a1a6a'],
  CONVENCION:['📖 Convención','#4a4010'],INFERIDO:['💭 Inferido','#2a3a4a'],AMBIGUO:['❓ Ambiguo','#7a1a10']};

const tiles=[
  ['tot',M.total_u,'Términos únicos',M.total],
  ['tot',M.bytipo_u['atómico']||0,'Atómicos',M.bytipo['atómico']||0],
  ['tot',M.bytipo_u['compuesto']||0,'Compuestos',M.bytipo['compuesto']||0],
  ['alta',M.byniv_u.ALTA||0,'🟢 Alta'],
  ['media',M.byniv_u.MEDIA||0,'🟡 Media'],
  ['amb',M.byniv_u.AMBIGUA||0,'🔴 Ambigua'],
  ['cand',M.byniv_u.CANDIDATO||0,'⚪ Candidatos'],
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

let fTipo=new Set(),fNiv=new Set(),fCat=new Set(),fFte=new Set(),q='';
function mkChips(elId,vals,set,labelFn){
  document.getElementById(elId).innerHTML=vals.map(v=>`<span class="chip" data-v="${v}">${labelFn(v)}</span>`).join('');
  document.querySelectorAll('#'+elId+' .chip').forEach(ch=>ch.onclick=()=>{
    const v=ch.dataset.v;
    if(set.has(v)){set.delete(v);ch.classList.remove('on');}else{set.add(v);ch.classList.add('on');}
    render();
  });
}
mkChips('ftipo',['atómico','compuesto','candidato'],fTipo,v=>v);
mkChips('fniv',['ALTA','MEDIA','AMBIGUA','CANDIDATO'],fNiv,v=>NIV[v][0]);
mkChips('fcat',['PREFIJO','ACCION','ENTIDAD','MODIF','REG','AMBIGUO'],fCat,v=>CATLBL[v]);
mkChips('ffte',['CODIGO','SME','NEGOCIO','CONVENCION','INFERIDO','AMBIGUO'],fFte,v=>FTE[v][0]);
document.getElementById('q').oninput=e=>{q=e.target.value.toLowerCase();render();};

let sortK='fn',sortDir=-1;
document.querySelectorAll('thead th').forEach(th=>th.onclick=()=>{
  const k=th.dataset.k;
  if(sortK===k) sortDir*=-1; else{sortK=k;sortDir=(k==='fn'||k==='fp')?-1:1;}
  render();
});

const tb=document.getElementById('tb');
function render(){
  let rows=DATA.filter(r=>{
    if(fTipo.size&&!fTipo.has(r.tipo)) return false;
    if(fNiv.size&&!fNiv.has(r.nivel)) return false;
    if(fCat.size&&!fCat.has(r.cat))   return false;
    if(fFte.size&&!fFte.has(r.fuente))return false;
    if(q&&!(r.term.toLowerCase().includes(q)||(r.mean||'').toLowerCase().includes(q)))return false;
    return true;
  });
  rows.sort((a,b)=>{
    let x=a[sortK],y=b[sortK];
    if(typeof x==='number') return(x-y)*sortDir;
    return String(x||'').localeCompare(String(y||''))*sortDir;
  });
  tb.innerHTML=rows.map(r=>{
    const [nl,nc]=NIV[r.nivel]||['—','b-cand'];
    const catbg=CATCOL[r.cat]||'#1a2a3a';
    return `<tr>
      <td><span class="term">${r.term}</span></td>
      <td><span class="tipo">${r.tipo}</span></td>
      <td><span class="cat" style="background:${catbg}">${CATLBL[r.cat]||r.cat}</span></td>
      <td class="mean">${(r.mean||'').replace(/</g,'&lt;')}</td>
      <td class="deco">${r.deco||''}</td>
      <td>${aliasCell(r.term)}</td>
      <td><span class="badge ${nc}">${nl}</span></td>
      <td><span class="cat" style="background:${FTE[r.fuente][1]}">${FTE[r.fuente][0]}</span></td>
      <td class="num ${r.fn>=5?'hot':''}">${r.fn||''}</td>
    </tr>`;
  }).join('');
  document.getElementById('count').textContent=`${rows.length} de ${DATA.length} términos`;
}
render();
</script>
<script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
<script>
try{mermaid.initialize({startOnLoad:true,securityLevel:'loose',theme:'dark',
  themeVariables:{fontFamily:'Inter, sans-serif',primaryColor:'#0d2235',primaryBorderColor:'#2B5CA8',
    primaryTextColor:'#EBF0F7',lineColor:'#5e8de6',tertiaryColor:'#091929',
    attributeBackgroundColorOdd:'#091929',attributeBackgroundColorEven:'#0d2235'}});}catch(e){}
</script>
</body>
</html>"""

HTML = (HTML
    .replace("__DATA__",      DATA)
    .replace("__META__",      M)
    .replace("__HALLAZGOS__", HALLAZGOS_H)
    .replace("__BIANBARS__",  BIANBARS_H)
    .replace("__ERDIAG__",    ERDIAG)
    .replace("__ALIASES__",   ALIASES)
    .replace("__OBJS__",      str(meta.get("objetos", "?")))
)
OUT_FILE.write_text(HTML, encoding='utf-8')
n_at  = bytipo.get('atómico', 0)
n_co  = bytipo.get('compuesto', 0)
n_can = bytipo.get('candidato', 0)
print(f"OK  vocab-report-gentera.html  =>  {len(rows)} terminos ({n_at} atomicos | {n_co} compuestos | {n_can} candidatos)")