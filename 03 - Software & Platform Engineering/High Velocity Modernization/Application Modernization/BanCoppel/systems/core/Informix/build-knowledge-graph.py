#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-knowledge-graph.py
Genera knowledge-graph-bcop.html — ontología y semántica del conocimiento BCOPCore.

Secciones:
  1. Arquitectura del Gemelo Cognitivo (capas + DTs)
  2. Grafo de Dependencias de Dominios Informix (D3 force, pre-calculado)
  3. Mapa Semántico BC × Dominio (heatmap + bubble chart)
  4. Taxonomía de Negocio — árbol colapsable (L1→L2→L3)
  5. Cobertura ETB — progress bars por BC

Consume:
  knowledge-base/domain-dependency-graph.json
  vocabulary-inventory.json
  knowledge-base/vocabulary/vocabulary-enrichment.json
  dt/dt-modelo-dominio/taxonomia-negocio-bancoppel.md
  knowledge-base/ontology/etb-capabilities.json

Genera: knowledge-graph-bcop.html
"""
import json
import re
from pathlib import Path
from collections import defaultdict, Counter

BASE = Path("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
            "03 - Software & Platform Engineering/High Velocity Modernization/"
            "Application Modernization/BanCoppel/BCOPCore/")
KB = BASE / "knowledge-base"

# ──────────────────────────────────────────────────────────────────────────────
# 1. CARGAR DATOS
# ──────────────────────────────────────────────────────────────────────────────
dom_graph = json.loads((KB / "domain-dependency-graph.json").read_text(encoding="utf-8"))

inv = {}
vocab_terms = []
try:
    inv = json.loads((BASE / "vocabulary-inventory.json").read_text(encoding="utf-8"))
    vocab_terms = inv.get("atomos", []) + inv.get("compuestos", [])
except FileNotFoundError:
    print("  AVISO: vocabulary-inventory.json no encontrado")

try:
    enrich = json.loads((KB / "vocabulary/vocabulary-enrichment.json").read_text(encoding="utf-8"))
except FileNotFoundError:
    enrich = {}
    print("  AVISO: vocabulary-enrichment.json no encontrado")

try:
    etb_raw = json.loads((KB / "ontology/etb-capabilities.json").read_text(encoding="utf-8"))
    etb_caps = etb_raw.get("capabilities", []) if isinstance(etb_raw, dict) else etb_raw
except (FileNotFoundError, json.JSONDecodeError):
    etb_caps = []
    print("  AVISO: etb-capabilities.json no encontrado o inválido")

try:
    tax_text = (BASE / "dt/dt-modelo-dominio/taxonomia-negocio-bancoppel.md").read_text(encoding="utf-8")
except FileNotFoundError:
    tax_text = ""
    print("  AVISO: taxonomia-negocio-bancoppel.md no encontrado")

# ──────────────────────────────────────────────────────────────────────────────
# 2. PROCESAR DOMINIOS
# ──────────────────────────────────────────────────────────────────────────────
DOM_META = {
    "bdicnweb":    {"id":"D01","name":"Canal Digital Web",   "wave":"ÚLTIMO",  "risk":"ALTO",    "bc":"BC-1.x"},
    "bdinteg":     {"id":"D02","name":"Integración y Auth",  "wave":"Wave 5",  "risk":"CRÍTICO", "bc":"BC-7.1"},
    "bdicred":     {"id":"D03","name":"Créditos",            "wave":"Wave 4",  "risk":"CRÍTICO", "bc":"BC-3.3"},
    "bdicheq":     {"id":"D04","name":"Cheques / Cuentas",   "wave":"Wave 4",  "risk":"CRÍTICO", "bc":"BC-3.2"},
    "bdisac":      {"id":"D05","name":"Saldos y Cuentas",    "wave":"Wave 3",  "risk":"ALTO",    "bc":"BC-3.2"},
    "bdisolic":    {"id":"D06","name":"Solicitudes",         "wave":"Wave 3",  "risk":"ALTO",    "bc":"BC-7.1"},
    "bdiaclaracion":{"id":"D07","name":"Aclaraciones",       "wave":"Wave 2",  "risk":"ALTO",    "bc":"BC-3.18"},
    "bdispei":     {"id":"D08","name":"SPEI",                "wave":"Wave 2",  "risk":"CRÍTICO", "bc":"BC-3.4"},
    "bdimnsj":     {"id":"D09","name":"Mensajería",          "wave":"Wave 1",  "risk":"BAJO",    "bc":"BC-4.x"},
    "bdisuc":      {"id":"D10","name":"Sucursales",          "wave":"Wave 3",  "risk":"ALTO",    "bc":"BC-1.x"},
    "bdicobranza": {"id":"D11","name":"Cobranza",            "wave":"Wave 2",  "risk":"MEDIO",   "bc":"BC-3.3"},
    "bdicont":     {"id":"D12","name":"Contabilidad",        "wave":"Wave 4",  "risk":"ALTO",    "bc":"BC-5.4"},
}
WAVE_COLOR = {
    "Wave 1": "#F57F17", "Wave 2": "#B71C1C", "Wave 3": "#2E7D32",
    "Wave 4": "#0277BD", "Wave 5": "#6A00B3", "ÚLTIMO": "#A100FF",
}
RISK_COLOR = {"BAJO":"#22c55e","MEDIO":"#f59e0b","ALTO":"#ef4444","CRÍTICO":"#dc2626"}

# Enrich domain nodes with SP counts from graph data
dom_sp = {}
for n in dom_graph["nodes"]:
    db = n["id"]
    dom_sp[db] = {"total_in": n["total_in"], "total_out": n["total_out"], "size": n["size"]}

# ──────────────────────────────────────────────────────────────────────────────
# 3. COMPUTAR BC × DOMAIN HEATMAP
# ──────────────────────────────────────────────────────────────────────────────
BC_ORDER = ["BC-7.1","BC-3.2","BC-3.3","BC-3.4","BC-3.5","BC-3.18",
            "BC-1.x","BC-5.4","BC-5.8","BC-4.x"]
BC_NAMES = {
    "BC-7.1":"Customer","BC-3.2":"Accounts","BC-3.3":"Lending",
    "BC-3.4":"Payments","BC-3.5":"Cards","BC-3.18":"Disputes",
    "BC-1.x":"Channels","BC-5.4":"Finance","BC-5.8":"AML/Risk","BC-4.x":"Ref.Data"
}
BC_COLOR = {
    "BC-7.1":"#122FB1","BC-3.2":"#0277BD","BC-3.3":"#B71C1C",
    "BC-3.4":"#2E7D32","BC-3.5":"#6A00B3","BC-3.18":"#F57F17",
    "BC-1.x":"#37474F","BC-5.4":"#827717","BC-5.8":"#C62828","BC-4.x":"#00695C"
}
DOM_ORDER = list(DOM_META.keys())

bc_dom_matrix = defaultdict(lambda: defaultdict(int))
bc_count = Counter()
dom_count_by_bc = defaultdict(Counter)

for term, e in enrich.items():
    bc = e.get("bc")
    dom = e.get("dominio_as_is")
    if bc and bc != "—":
        bc_count[bc] += 1
        if dom and dom in [m["id"] for m in DOM_META.values()]:
            # find db key for dom id
            for db, meta in DOM_META.items():
                if meta["id"] == dom:
                    bc_dom_matrix[bc][db] += 1
                    break

# max value for colour scaling
max_cell = max((v for row in bc_dom_matrix.values() for v in row.values()), default=1)

def cell_color(val, mx):
    if val == 0: return "transparent"
    ratio = min(val / mx, 1.0)
    alpha = 0.12 + ratio * 0.78
    return f"rgba(18,47,177,{alpha:.2f})"

def text_color(val, mx):
    if val == 0: return "#ccc"
    ratio = min(val / mx, 1.0)
    return "#ffffff" if ratio > 0.5 else "#0a1330"

# ──────────────────────────────────────────────────────────────────────────────
# 4. PARSEAR TAXONOMÍA
# ──────────────────────────────────────────────────────────────────────────────
def parse_taxonomy(text):
    """Extract L1/L2/L3 nodes from the taxonomy markdown."""
    tree = []
    current_l1 = None
    current_l2 = None
    for line in text.splitlines():
        # L1: "# 1. Title"
        m1 = re.match(r"^# (\d+)\. (.+)$", line)
        if m1:
            current_l1 = {"num": m1.group(1), "name": m1.group(2).strip(), "subs": []}
            tree.append(current_l1)
            current_l2 = None
            continue
        # L2: "## 1.1 Title"
        m2 = re.match(r"^## (\d+\.\d+) (.+)$", line)
        if m2 and current_l1:
            db_ref = re.search(r"\[DB: (D\d+[^\]]*)\]", line)
            etb_ref = re.search(r"\[ETB: ([^\]]+)\]", line)
            current_l2 = {
                "num": m2.group(1),
                "name": re.sub(r"`\[.*?\]`", "", m2.group(2)).strip(),
                "db": db_ref.group(1) if db_ref else "",
                "etb": etb_ref.group(1) if etb_ref else "",
                "caps": []
            }
            if current_l1:
                current_l1["subs"].append(current_l2)
            continue
        # L3: "### 1.1.1 Title"
        m3 = re.match(r"^### (\d+\.\d+\.\d+) (.+)$", line)
        if m3 and current_l2:
            cnbv = re.search(r"\[CNBV: ([^\]]+)\]", line)
            current_l2["caps"].append({
                "num": m3.group(1),
                "name": re.sub(r"`\[.*?\]`", "", m3.group(2)).strip(),
                "cnbv": cnbv.group(1) if cnbv else ""
            })
    return tree

taxonomy = parse_taxonomy(tax_text)

def render_tree_html(tree):
    if not tree:
        return "<p style='color:#888'>Taxonomía no disponible</p>"
    parts = []
    for d in tree:
        parts.append(f'<div class="tx-l1">'
                     f'<div class="tx-l1-hd"><span class="tx-num">{d["num"]}</span>{d["name"]}'
                     f'<span class="tx-badge">{len(d["subs"])} subdominios · '
                     f'{sum(len(s["caps"]) for s in d["subs"])} caps</span></div>')
        for s in d["subs"]:
            db_pill = f'<span class="tx-db">{s["db"]}</span>' if s["db"] else ""
            parts.append(f'<div class="tx-l2">'
                         f'<div class="tx-l2-hd"><span class="tx-num">{s["num"]}</span>'
                         f'{s["name"]}{db_pill}</div>')
            if s["caps"]:
                parts.append('<div class="tx-caps">')
                for c in s["caps"]:
                    cnbv = f'<span class="tx-cnbv">CNBV</span>' if c["cnbv"] else ""
                    parts.append(f'<div class="tx-l3">'
                                 f'<span class="tx-num">{c["num"]}</span>'
                                 f'{c["name"]}{cnbv}</div>')
                parts.append('</div>')
            parts.append('</div>')
        parts.append('</div>')
    return "\n".join(parts)

TREE_HTML = render_tree_html(taxonomy)

# ──────────────────────────────────────────────────────────────────────────────
# 5. HEATMAP TABLE HTML
# ──────────────────────────────────────────────────────────────────────────────
def render_heatmap():
    rows = ["<table class='hm-table'><thead><tr><th>BC</th>"]
    for db in DOM_ORDER:
        m = DOM_META[db]
        rows.append(f"<th title='{db}'>{m['id']}</th>")
    rows.append("</tr></thead><tbody>")
    for bc in BC_ORDER:
        total = bc_count.get(bc, 0)
        name = BC_NAMES.get(bc, bc)
        color = BC_COLOR.get(bc, "#333")
        rows.append(f"<tr><td class='hm-bc' style='border-left:3px solid {color}'>"
                    f"<span class='hm-bcid' style='color:{color}'>{bc}</span>"
                    f"<span class='hm-bcname'>{name}</span>"
                    f"<span class='hm-total'>{total}</span></td>")
        for db in DOM_ORDER:
            val = bc_dom_matrix[bc].get(db, 0)
            bg = cell_color(val, max_cell)
            tc = text_color(val, max_cell)
            title = f"{bc} × {DOM_META[db]['id']}: {val} términos"
            display = str(val) if val > 0 else ""
            rows.append(f"<td class='hm-cell' style='background:{bg};color:{tc}' title='{title}'>{display}</td>")
        rows.append("</tr>")
    rows.append("</tbody></table>")
    return "\n".join(rows)

HEATMAP_HTML = render_heatmap()

# ──────────────────────────────────────────────────────────────────────────────
# 6. DATOS D3 — GRAFO DE DOMINIOS
# ──────────────────────────────────────────────────────────────────────────────
d3_nodes = []
for n in dom_graph["nodes"]:
    db = n["id"]
    meta = DOM_META.get(db, {})
    d3_nodes.append({
        "id": db,
        "label": meta.get("id", db),
        "name": meta.get("name", db),
        "wave": meta.get("wave", ""),
        "risk": meta.get("risk", ""),
        "bc": meta.get("bc", "—"),
        "color": WAVE_COLOR.get(meta.get("wave",""), "#555"),
        "r": max(18, min(56, 14 + (n["total_in"] + n["total_out"]) ** 0.38)),
        "total_in": n["total_in"],
        "total_out": n["total_out"],
    })

d3_edges = []
for e in dom_graph["edges"]:
    d3_edges.append({
        "source": e["from"],
        "target": e["to"],
        "value": e["value"],
        "tooltip": e["title"].replace("\n", " · "),
    })

D3_NODES = json.dumps(d3_nodes, ensure_ascii=False)
D3_EDGES = json.dumps(d3_edges, ensure_ascii=False)

# ──────────────────────────────────────────────────────────────────────────────
# 7. AGGREGATE ROOTS DATA
# ──────────────────────────────────────────────────────────────────────────────
ROOTS = [
    {"term":"cliente",      "bc":"BC-7.1", "name":"Cliente",             "db":"D02,D06"},
    {"term":"cuenta",       "bc":"BC-3.2", "name":"Cuenta",              "db":"D04,D05"},
    {"term":"credito",      "bc":"BC-3.3", "name":"Crédito",             "db":"D03,D06"},
    {"term":"pago",         "bc":"BC-3.4", "name":"Pago / Transacción",  "db":"D05,D08"},
    {"term":"tarjeta",      "bc":"BC-3.5", "name":"Tarjeta",             "db":"D16"},
    {"term":"asiento",      "bc":"BC-5.4", "name":"Asiento Contable",    "db":"D12"},
    {"term":"aclaracion",   "bc":"BC-3.18","name":"Aclaración",          "db":"D07"},
    {"term":"alerta",       "bc":"BC-5.8", "name":"Alerta AML",          "db":"D15"},
]
ROOTS_JSON = json.dumps(ROOTS, ensure_ascii=False)

# ──────────────────────────────────────────────────────────────────────────────
# 8. DT SWARM DATA
# ──────────────────────────────────────────────────────────────────────────────
DTS = [
    {"id":"dt-vocabulario","capa":"1","name":"DT-Vocabulario","count":"787 términos",
     "desc":"Léxico del sistema: átomos, compuestos, candidatos","color":"#F0D224",
     "smes":"SPL Analysis · Industry Banking"},
    {"id":"dt-almas","capa":"2","name":"DT-Almas","count":"16 módulos",
     "desc":"Identidades funcionales del core bancario","color":"#122FB1",
     "smes":"SPL Analysis · Core Banking Transformation"},
    {"id":"dt-journeys","capa":"3","name":"DT-Journeys","count":"131 journeys",
     "desc":"Procesos bancarios end-to-end desde el código","color":"#6882AA",
     "smes":"SPL Analysis · Industry Banking"},
    {"id":"dt-reglas","capa":"4","name":"DT-Reglas","count":"7,795 reglas",
     "desc":"Condiciones de negocio SBVR: umbrales y restricciones","color":"#8b3a8b",
     "smes":"SPL Analysis · Industry Banking · Banking Accounting"},
    {"id":"dt-modelo-dominio","capa":"H","name":"DT-Modelo-Dominio","count":"7 dom · 67 caps",
     "desc":"Hilo conductor: taxonomía 5 niveles AS-IS","color":"#2e6b48",
     "smes":"Core Banking Transformation · Industry Banking · DBA Informix"},
    {"id":"dt-capacidades","capa":"C","name":"DT-Capacidades","count":"261 caps ETB",
     "desc":"Cobertura BIAN L3: 23.8% covered","color":"#1e5a8a",
     "smes":"Core Banking Transformation · Industry Banking"},
    {"id":"dt-riesgos","capa":"R","name":"DT-Riesgos","count":"44 riesgos",
     "desc":"Registro de riesgos de migración N1→N5","color":"#8b2020",
     "smes":"SPL Analysis · Cybersecurity · SRE & AIOps"},
    {"id":"dt-spl-analysis","capa":"★","name":"DT-SPL-Analysis","count":"10,144 SPs",
     "desc":"Orquestador scatter-gather: 34,279 edges","color":"#333",
     "smes":"Specialist propio (auto-suficiente)"},
]

# ──────────────────────────────────────────────────────────────────────────────
# 9b. KB DOCUMENT MAP DATA
# ──────────────────────────────────────────────────────────────────────────────
KB_DOC_TYPES = [
    ("00","business-process-catalog","Catálogo de Procesos"),
    ("01","journey","Journey Map"),
    ("02","data-catalog","Catálogo de Datos"),
    ("03","data-dictionary","Diccionario de Datos"),
    ("04","business-rules","Reglas de Negocio"),
    ("05","risks","Riesgos"),
    ("06","exceptions","Excepciones"),
    ("07","dependencies","Mapa de Dependencias"),
    ("08","sp-table-matrix","SP × Tabla Matrix"),
    ("09","dead-code","Dead Code"),
    ("10","test-strategy","Test Strategy"),
    ("11","batch-processes","Batch Processes"),
    ("12","er-model","ER Model"),
    ("13","external-dependencies","Deps. Externas"),
    ("14","target-architecture","Arquitectura Target"),
    ("15","type-mapping","Type Mapping"),
    ("16","api-contract","API Contract"),
    ("17","data-migration-plan","Plan Migración Datos"),
    ("18","pii-security-assessment","PII / Security"),
    ("19","performance-baseline","Perf. Baseline"),
    ("20","cutover-plan","Cutover Plan"),
    ("21","observability-runbook","Observability Runbook"),
]
D16_PARTIAL = {0,1,4,6,11,13,19,21}  # archivos presentes en D16 (parcialmente analizado)

KB_DOM_ANALYZED = [
    # (id, db_name, wave, sps, rules, full_22_files)
    ("D01","bdicnweb","ÚLTIMO",1058,1339,True),
    ("D02","bdinteg","Wave 5",396,723,True),
    ("D03","bdicred","Wave 4",522,1743,True),
    ("D04","bdicheq","Wave 4",658,1344,True),
    ("D05","bdisac","Wave 3",99,208,True),
    ("D06","bdisolic","Wave 3",96,251,True),
    ("D07","bdiaclaracion","Wave 2",41,217,True),
    ("D08","bdispei","Wave 2",53,117,True),
    ("D09","bdimnsj","Wave 1",19,22,True),
    ("D10","bdisuc","Wave 3",31,62,True),
    ("D11","bdicobranza","Wave 2",75,209,True),
    ("D12","bdicont","Wave 4",51,87,True),
    ("D13","bditef","—",38,75,True),
    ("D14","bdibei","—",34,90,True),
    ("D15","bdilide","—",21,44,True),
    ("D16","intercard","—",113,324,False),  # parcial: solo 8 de 22 tipos
]

# Nodos para el grafo de documentos KB
KB_SYNTHESIS = [
    {"id":"sd-rules","label":"business-rules-bcop","type":"synthesis","size_kb":28,"desc":"7,795 reglas de negocio","color":"#8b3a8b","covers":"all"},
    {"id":"sd-journeys","label":"journeys-catalog","type":"synthesis","size_kb":38,"desc":"131 journeys de negocio","color":"#2e6b48","covers":"all"},
    {"id":"sd-almas","label":"CAPA-2-mapa-almas","type":"synthesis","size_kb":21,"desc":"15 almas / módulos","color":"#122FB1","covers":["D01","D02","D03","D04","D05","D06","D07","D08","D09","D10","D11","D12"]},
    {"id":"sd-risks","label":"migration-risk-register","type":"synthesis","size_kb":19,"desc":"44 riesgos de migración","color":"#dc2626","covers":["D01","D02","D03","D04","D05"]},
    {"id":"sd-dep-matrix","label":"domain-dependency-matrix","type":"synthesis","size_kb":9,"desc":"Matriz call graph cross-DB","color":"#B71C1C","covers":["D01","D02","D03","D04","D05","D06","D07","D08","D09","D10","D11","D12"]},
    {"id":"sd-reg-val","label":"regulatory-validation","type":"synthesis","size_kb":32,"desc":"Paquetes HITL regulatorio","color":"#d4a800","covers":["D02","D03","D04","D08","D12","D15"]},
    {"id":"sd-latency","label":"latency-baseline","type":"synthesis","size_kb":7,"desc":"Baseline latencia producción","color":"#555","covers":["D01","D02","D03","D04"]},
    {"id":"sd-audit","label":"vocab-audit","type":"synthesis","size_kb":10,"desc":"Auditoría falsos positivos","color":"#556080","covers":["D01","D02","D03","D04","D05","D06"]},
    {"id":"sd-banking","label":"banking-operating-model","type":"synthesis","size_kb":10,"desc":"Modelo operativo BIAN","color":"#37474F","covers":"all"},
    {"id":"sd-orch","label":"orchestrators-complexity","type":"synthesis","size_kb":6,"desc":"Orquestadores — deuda técnica","color":"#827717","covers":["D01","D02","D03"]},
]
KB_CROSSREF = [
    {"id":"xr-sp-rules","label":"sp-rules-vocab-map","type":"crossref","size_kb":77,"desc":"Top 100 SPs × reglas × vocab","color":"#0277BD","covers":["D01","D02","D03","D04","D05","D06"]},
    {"id":"xr-vocab-sp","label":"vocab-sp-coverage","type":"crossref","size_kb":65,"desc":"Vocabulario → cobertura SPs","color":"#0277BD","covers":"all"},
    {"id":"xr-reg","label":"regulatory-sp-index","type":"crossref","size_kb":165,"desc":"Índice regulatorio CNBV/SAT/Banxico","color":"#0277BD","covers":["D02","D03","D04","D08","D12","D15"]},
    {"id":"xr-dep-map","label":"component-dep-map","type":"crossref","size_kb":40,"desc":"Mapa dependencias de componentes","color":"#0277BD","covers":"all"},
]
KB_VOCAB = [
    {"id":"vc-inv","label":"vocabulary-inventory","type":"vocabulary","size_kb":63,"desc":"Inventario 787 términos","color":"#d4a800","covers":"all"},
    {"id":"vc-kb","label":"vocabulary-knowledge-base","type":"vocabulary","size_kb":28,"desc":"Base conocimiento léxico","color":"#d4a800","covers":["D01","D02","D03","D04","D05","D06"]},
]
KB_RULES = [
    {"id":"rl-cat","label":"rules/business-rules","type":"rules","size_kb":30,"desc":"Catálogo formal v2.2","color":"#dc2626","covers":"all"},
]

ALL_KB_DOCS = KB_SYNTHESIS + KB_CROSSREF + KB_VOCAB + KB_RULES

# Build D3 nodes and edges for the KB doc graph
ANALYZED_IDS = [d[0] for d in KB_DOM_ANALYZED]  # D01..D16
STUB_ID = "D17-49"

kb_gnodes = []
for doc in ALL_KB_DOCS:
    r = max(20, min(48, 14 + doc["size_kb"] ** 0.5 * 2.2))
    kb_gnodes.append({
        "id": doc["id"], "label": doc["label"], "type": doc["type"],
        "desc": doc["desc"], "color": doc["color"], "r": r,
        "size_kb": doc["size_kb"],
        "universal": doc["covers"] == "all",
    })

for did, db_name, wave, sps, rules, full in KB_DOM_ANALYZED:
    kb_gnodes.append({
        "id": did, "label": did, "type": "domain",
        "desc": f"{db_name} · {sps} SPs · {rules} reglas",
        "color": WAVE_COLOR.get(wave, "#aaa"), "r": 16,
        "wave": wave, "sps": sps, "rules": rules,
        "universal": False,
    })
kb_gnodes.append({
    "id": STUB_ID, "label": "D17–D49", "type": "stub",
    "desc": "33 dominios pendientes de análisis (solo 00-index.md)", "color": "#aab", "r": 24,
    "universal": False,
})

# Edges:
# - Universal docs: arista punteada a TODOS los 16 dominios (fina) + arista al stub
# - Docs con covers específico: arista sólida solo a sus dominios
kb_gedges = []
for doc in ALL_KB_DOCS:
    if doc["covers"] == "all":
        # conectar a todos los dominios analizados (punteada, fina — evita huérfanos)
        kb_gedges.append({"source": doc["id"], "target": STUB_ID, "kind": "universal", "dashed": True})
        for did, *_ in KB_DOM_ANALYZED:
            kb_gedges.append({"source": doc["id"], "target": did, "kind": "universal", "dashed": True})
    else:
        for dom in doc["covers"]:
            kb_gedges.append({"source": doc["id"], "target": dom, "kind": "covers", "dashed": False})

KB_GNODES_JSON = json.dumps(kb_gnodes, ensure_ascii=False)
KB_GEDGES_JSON = json.dumps(kb_gedges, ensure_ascii=False)

# ── Coverage matrix HTML ──
def render_kb_coverage():
    rows = ["<div class='kb-cov-wrap'><table class='kb-cov-table'><thead><tr>"]
    rows.append("<th class='kb-ct'>Tipo de artefacto</th>")
    for (did, db_name, wave, sps, rules, full) in KB_DOM_ANALYZED:
        wc = WAVE_COLOR.get(wave, "#aaa")
        short = db_name.replace("bdi","").replace("bd","")[:5]
        rows.append(f"<th class='kb-dh' style='border-top:3px solid {wc}' title='{did} {db_name} · {sps} SPs'>{did}</th>")
    rows.append("<th class='kb-dh stub-h' title='D17-D49: 33 dominios con solo 00-index.md'>D17–D49</th>")
    rows.append("</tr></thead><tbody>")
    for (num, slug, label) in KB_DOC_TYPES:
        idx = int(num)
        type_color = {"04":"#8b3a8b","01":"#2e6b48","07":"#B71C1C","05":"#dc2626",
                      "18":"#C62828","10":"#0277BD","21":"#37474F"}.get(num,"")
        tc_style = f"border-left:3px solid {type_color}" if type_color else ""
        rows.append(f"<tr><td class='kb-ct' style='{tc_style}'><span class='kb-num'>{num}</span>{label}</td>")
        for (did, db_name, wave, sps, rules, full) in KB_DOM_ANALYZED:
            if full:
                cls, title = "cov-full", f"{did} {db_name}: {label} ✓ analizado"
            elif not full and idx in D16_PARTIAL:
                cls, title = "cov-full", f"{did}: {label} ✓ presente"
            else:
                cls, title = "cov-miss", f"{did}: {label} — no generado (D16 parcial)"
            rows.append(f"<td class='cov-cell {cls}' title='{title}'></td>")
        stub_cls = "cov-stub" if idx == 0 else "cov-miss"
        rows.append(f"<td class='cov-cell {stub_cls}' title='D17-D49: {'solo índice' if idx==0 else 'pendiente'}' ></td>")
        rows.append("</tr>")
    rows.append("</tbody></table></div>")
    return "\n".join(rows)

KB_COVERAGE_HTML = render_kb_coverage()

# Stats for header tiles
n_vocab = len(vocab_terms) + len(inv.get("candidatos",[]))
n_bc_covered = sum(1 for b,c in bc_count.items() if c > 0)

# ──────────────────────────────────────────────────────────────────────────────
# 9. HTML TEMPLATE
# ──────────────────────────────────────────────────────────────────────────────
HTML = """<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>BCOPCore · Ontología del Conocimiento</title>
<script src="https://cdn.jsdelivr.net/npm/d3@7/dist/d3.min.js"></script>
<style>
:root{--bg:#f5f7ff;--bg2:#eaedfa;--panel:#ffffff;--line:rgba(18,47,177,.12);
  --blue:#122FB1;--yellow:#F0D224;--txt:#0a1330;--muted:#556080}
*{box-sizing:border-box;margin:0;padding:0}
body{background:var(--bg);color:var(--txt);font-family:'Inter',system-ui,sans-serif;min-height:100vh}
/* ── HEADER ── */
header{background:linear-gradient(135deg,#0d2185 0%,#122FB1 55%,#1a3abf 100%);
  border-bottom:3px solid #F0D224;padding:18px 28px;
  display:flex;align-items:center;gap:20px;box-shadow:0 4px 24px rgba(0,0,0,.45)}
header img{height:40px;filter:drop-shadow(0 2px 6px rgba(0,0,0,.5));object-fit:contain}
header .div{width:1px;height:38px;background:rgba(255,255,255,.2)}
header .meta{flex:1}
header .bc{font-size:10px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;
  color:rgba(255,255,255,.45);margin-bottom:4px}
header .bc span{color:#F0D224}
header h1{font-size:18px;font-weight:800;color:#fff;letter-spacing:-.01em}
header .sub{font-size:11px;color:#a0b4e8;margin-top:3px}
header .bw{display:flex;gap:8px;margin-left:auto}
.hbadge{font-size:10px;font-weight:700;padding:4px 12px;border-radius:20px;white-space:nowrap}
.hbadge.y{background:rgba(240,210,36,.15);border:1px solid rgba(240,210,36,.4);color:#F0D224}
.hbadge.b{background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.14);color:#c9d3f5}
/* ── STAT TILES ── */
#tiles{display:flex;gap:8px;padding:14px 20px;flex-wrap:wrap;background:var(--bg2);
  border-bottom:1px solid var(--line)}
.tile{background:#fff;border-radius:8px;padding:8px 14px;min-width:100px;
  border-left:3px solid var(--line);box-shadow:0 1px 4px rgba(18,47,177,.07)}
.tile .n{font-size:22px;font-weight:800;letter-spacing:-.02em}
.tile .l{font-size:9px;color:var(--muted);text-transform:uppercase;letter-spacing:.06em}
/* ── SECTIONS ── */
.section{padding:28px 28px 0}
.shead{font-size:17px;font-weight:800;letter-spacing:-.01em;margin-bottom:6px;display:flex;
  align-items:center;gap:10px}
.shead .icon{width:28px;height:28px;border-radius:8px;display:flex;align-items:center;
  justify-content:center;font-size:14px;flex-shrink:0}
.ssub{font-size:12px;color:var(--muted);margin-bottom:18px;max-width:90ch}
/* ── GEMELO COGNITIVO LAYERS ── */
.gc-wrap{display:flex;gap:10px;align-items:stretch;overflow-x:auto;padding-bottom:8px}
.gc-layer{background:#fff;border:1px solid var(--line);border-radius:12px;
  padding:14px 16px;min-width:170px;flex:1;position:relative;
  box-shadow:0 2px 8px rgba(18,47,177,.06)}
.gc-layer.transv{background:#f8f5ff;border-style:dashed}
.gc-num{width:28px;height:28px;border-radius:7px;display:flex;align-items:center;
  justify-content:center;font-size:12px;font-weight:900;color:#fff;margin-bottom:10px}
.gc-title{font-size:13px;font-weight:700;margin-bottom:3px}
.gc-count{font-size:11px;font-weight:700;color:var(--blue);margin-bottom:4px}
.gc-desc{font-size:10px;color:var(--muted);line-height:1.4;margin-bottom:8px}
.gc-dt{font-size:9.5px;color:#122FB1;font-weight:600;margin-bottom:2px}
.gc-sme{font-size:9px;color:var(--muted)}
.gc-arrow{position:absolute;right:-18px;top:50%;transform:translateY(-50%);
  font-size:18px;color:rgba(18,47,177,.3);z-index:2;pointer-events:none}
/* ── D3 FORCE GRAPH ── */
#domain-graph{background:#fff;border:1px solid var(--line);border-radius:14px;
  box-shadow:0 2px 10px rgba(18,47,177,.07);overflow:hidden}
#domain-graph svg{display:block}
.node-label{font-size:9.5px;font-weight:700;fill:#fff;text-anchor:middle;pointer-events:none;dominant-baseline:central}
.node-sub{font-size:8px;fill:rgba(255,255,255,.75);text-anchor:middle;pointer-events:none}
.edge-path{fill:none;stroke-opacity:.5}
.edge-path:hover{stroke-opacity:1}
#graph-tooltip{position:fixed;background:rgba(10,19,48,.93);color:#eaedfa;padding:8px 12px;
  border-radius:8px;font-size:11px;pointer-events:none;display:none;z-index:100;
  border:1px solid rgba(240,210,36,.3);max-width:280px;line-height:1.5}
/* ── LEGEND ── */
.legend{display:flex;flex-wrap:wrap;gap:8px;margin-top:10px}
.leg-item{display:flex;align-items:center;gap:5px;font-size:10px;color:var(--muted)}
.leg-dot{width:10px;height:10px;border-radius:50%}
/* ── HEATMAP ── */
.hm-wrap{overflow-x:auto;border-radius:12px;border:1px solid var(--line);
  box-shadow:0 2px 8px rgba(18,47,177,.05)}
table.hm-table{border-collapse:collapse;width:100%;background:#fff}
.hm-table th{background:var(--bg2);font-size:9.5px;text-transform:uppercase;
  letter-spacing:.06em;color:var(--muted);padding:6px 8px;font-weight:700;
  white-space:nowrap;border-bottom:1px solid var(--line);text-align:center}
.hm-table th:first-child{text-align:left;min-width:180px}
.hm-bc{font-size:11px;padding:7px 10px;white-space:nowrap}
.hm-bcid{font-size:9px;font-weight:800;letter-spacing:.06em;margin-right:4px}
.hm-bcname{color:var(--muted);font-size:10px;margin-right:8px}
.hm-total{font-size:9px;font-weight:700;color:var(--blue);
  background:rgba(18,47,177,.08);border-radius:10px;padding:0 5px}
.hm-cell{text-align:center;font-size:10px;font-weight:700;padding:6px 4px;
  width:56px;cursor:default;transition:opacity .12s;font-variant-numeric:tabular-nums}
.hm-cell:hover{opacity:.7;outline:1px solid var(--blue)}
.hm-table tbody tr:hover .hm-bc{background:rgba(18,47,177,.04)}
/* ── TAXONOMY ── */
.tax-wrap{background:#fff;border:1px solid var(--line);border-radius:12px;
  padding:18px 20px;box-shadow:0 2px 8px rgba(18,47,177,.05)}
.tx-l1{margin-bottom:16px}
.tx-l1-hd{font-size:14px;font-weight:800;color:var(--blue);padding:8px 0 6px;
  border-bottom:2px solid rgba(18,47,177,.12);display:flex;align-items:center;gap:8px;
  cursor:pointer;user-select:none}
.tx-l1-hd:hover{color:#0a1330}
.tx-badge{font-size:9px;font-weight:600;color:var(--muted);background:rgba(18,47,177,.08);
  border-radius:10px;padding:2px 8px;margin-left:auto}
.tx-l2{border-left:2px solid rgba(18,47,177,.15);margin-left:12px;padding-left:12px;
  margin-top:8px}
.tx-l2-hd{font-size:12px;font-weight:700;color:#2a3a6a;padding:4px 0;
  display:flex;align-items:center;gap:6px;cursor:pointer;user-select:none}
.tx-l2-hd:hover{color:var(--blue)}
.tx-caps{display:flex;flex-wrap:wrap;gap:5px;margin-top:6px;margin-bottom:6px}
.tx-l3{font-size:10px;color:var(--muted);background:#f5f7ff;border:1px solid rgba(18,47,177,.1);
  border-radius:6px;padding:3px 9px;display:flex;align-items:center;gap:5px}
.tx-l3:hover{border-color:var(--blue);color:var(--blue)}
.tx-num{font-size:9px;font-weight:800;color:rgba(18,47,177,.5);margin-right:4px;
  font-family:'Cascadia Code',monospace}
.tx-db{font-size:9px;font-weight:700;color:#122FB1;background:rgba(18,47,177,.08);
  border:1px solid rgba(18,47,177,.15);border-radius:4px;padding:1px 5px;margin-left:6px}
.tx-cnbv{font-size:8.5px;font-weight:700;color:#dc2626;background:rgba(220,38,38,.07);
  border:1px solid rgba(220,38,38,.2);border-radius:4px;padding:0 4px}
/* ── DT SWARM ── */
.dt-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:10px}
.dt-card{background:#fff;border:1px solid var(--line);border-radius:12px;padding:14px;
  box-shadow:0 2px 8px rgba(18,47,177,.05);position:relative;overflow:hidden}
.dt-card::before{content:'';position:absolute;top:0;left:0;right:0;height:3px}
.dt-num{width:26px;height:26px;border-radius:6px;display:flex;align-items:center;
  justify-content:center;font-size:11px;font-weight:900;color:#fff;margin-bottom:8px}
.dt-name{font-size:12px;font-weight:800;margin-bottom:2px}
.dt-count{font-size:11px;font-weight:700;color:var(--blue);margin-bottom:4px}
.dt-desc{font-size:10px;color:var(--muted);line-height:1.4;margin-bottom:6px}
.dt-sme{font-size:9px;color:#556080;border-top:1px solid var(--line);padding-top:5px}
/* ── KB COVERAGE MATRIX ── */
.kb-cov-wrap{overflow-x:auto;border-radius:10px;border:1px solid var(--line);
  box-shadow:0 2px 8px rgba(18,47,177,.05)}
table.kb-cov-table{border-collapse:collapse;width:100%;background:#fff;font-size:11px}
.kb-cov-table thead tr{background:var(--bg2)}
.kb-dh{padding:5px 3px;font-size:8.5px;font-weight:800;text-align:center;white-space:nowrap;
  color:var(--muted);min-width:32px;border-bottom:1px solid var(--line)}
.stub-h{color:#aab;font-style:italic}
.kb-ct{padding:5px 10px;font-size:10px;color:var(--muted);white-space:nowrap;
  min-width:190px;font-weight:500}
.kb-num{font-size:9px;font-weight:800;font-family:'Cascadia Code',monospace;
  color:rgba(18,47,177,.4);margin-right:7px}
.cov-cell{width:32px;height:22px;text-align:center}
.cov-full{background:#dcfce7}
.cov-miss{background:#f5f7ff}
.cov-stub{background:#fef3c7}
.kb-cov-table tbody tr:hover td{opacity:.8}
/* ── KB DOC GRAPH ── */
#kb-doc-graph{background:#fff;border:1px solid var(--line);border-radius:14px;
  box-shadow:0 2px 10px rgba(18,47,177,.07);overflow:hidden;margin-top:18px}
.kb-doc-label{font-size:8px;fill:var(--txt);text-anchor:middle;pointer-events:none;
  dominant-baseline:central;font-weight:600}
.kb-doc-sub{font-size:7px;fill:var(--muted);text-anchor:middle;pointer-events:none}
/* ── KB LEGEND STRIP ── */
.kb-legend{display:flex;flex-wrap:wrap;gap:10px;margin:10px 0;align-items:center}
.kb-leg{display:flex;align-items:center;gap:5px;font-size:10px;color:var(--muted)}
.kb-leg .dot{width:11px;height:11px;border-radius:3px}
.kb-leg .line-s{width:22px;height:2px}
/* ── FOOTER ── */
footer{font-size:9px;color:var(--muted);padding:10px 28px;margin-top:40px;
  border-top:1px solid var(--line);background:var(--bg2);
  display:flex;justify-content:space-between;flex-wrap:wrap;gap:4px}
</style>
</head>
<body>
<header>
  <img src="bancoppel-logo.png" alt="BanCoppel">
  <div class="div"></div>
  <div class="meta">
    <div class="bc">BCOPCore · <span>SPE-AM-001</span> · Gemelo Cognitivo del Sistema</div>
    <h1>Ontología y Semántica del Conocimiento</h1>
    <div class="sub">IBM Informix IDS 14.10 · POWER-AIX · Fase DISCOVER — Etapa 3</div>
  </div>
  <div class="bw">
    <span class="hbadge y">Knowledge Graph</span>
    <span class="hbadge b">Informix SPL</span>
  </div>
</header>

<div id="tiles">
  <div class="tile" style="border-left-color:#F0D224"><div class="n">__VOCAB__</div><div class="l">Términos de vocabulario</div></div>
  <div class="tile" style="border-left-color:#122FB1"><div class="n">10,144</div><div class="l">Stored Procedures</div></div>
  <div class="tile" style="border-left-color:#6882AA"><div class="n">34,279</div><div class="l">Edges call graph</div></div>
  <div class="tile" style="border-left-color:#8b3a8b"><div class="n">7,795</div><div class="l">Reglas de negocio</div></div>
  <div class="tile" style="border-left-color:#2e6b48"><div class="n">131</div><div class="l">Customer journeys</div></div>
  <div class="tile" style="border-left-color:#B71C1C"><div class="n">12</div><div class="l">Dominios Informix</div></div>
  <div class="tile" style="border-left-color:#0277BD"><div class="n">__BCCOUNT__</div><div class="l">Bounded Contexts cubiertos</div></div>
  <div class="tile" style="border-left-color:#37474F"><div class="n">8</div><div class="l">Digital Twins</div></div>
</div>

<!-- ═══════════════════════════════════════════════════════════
     SECCIÓN 1: ARQUITECTURA DEL GEMELO COGNITIVO
═══════════════════════════════════════════════════════════ -->
<div class="section">
  <div class="shead"><div class="icon" style="background:#122FB1">🧠</div>Arquitectura del Gemelo Cognitivo</div>
  <div class="ssub">4 capas de comprensión del sistema + 2 capas transversales. Cada capa materializa un artefacto del conocimiento gobernado por un Digital Twin peer.</div>
  <div class="gc-wrap">
    <div class="gc-layer">
      <div class="gc-num" style="background:#F0D224;color:#0a1330">1</div>
      <div class="gc-title">Lenguaje</div>
      <div class="gc-count">787 términos · 438 clasificados</div>
      <div class="gc-desc">Vocabulario del dominio extraído del corpus SPL: morfemas del lenguaje de negocio del banco codificado en Informix.</div>
      <div class="gc-dt">DT-Vocabulario</div>
      <div class="gc-sme">SPL Analysis · Industry Banking</div>
      <div class="gc-arrow">→</div>
    </div>
    <div class="gc-layer">
      <div class="gc-num" style="background:#122FB1">2</div>
      <div class="gc-title">Almas</div>
      <div class="gc-count">16 módulos funcionales</div>
      <div class="gc-desc">Identidades propias del sistema: los actores internos del core — cada uno con responsabilidades, dependencias y biometría de código.</div>
      <div class="gc-dt">DT-Almas</div>
      <div class="gc-sme">SPL Analysis · Core Banking Transformation</div>
      <div class="gc-arrow">→</div>
    </div>
    <div class="gc-layer">
      <div class="gc-num" style="background:#6882AA">3</div>
      <div class="gc-title">Biografía</div>
      <div class="gc-count">131 journeys extractados</div>
      <div class="gc-desc">Historia del sistema: cómo evolucionó el código, qué procesos de negocio ejecuta hoy, la narrativa de su ciclo de vida.</div>
      <div class="gc-dt">DT-Journeys</div>
      <div class="gc-sme">SPL Analysis · Industry Banking</div>
      <div class="gc-arrow">→</div>
    </div>
    <div class="gc-layer">
      <div class="gc-num" style="background:#8b3a8b">4</div>
      <div class="gc-title">Intención</div>
      <div class="gc-count">7,795 reglas · 1,308 SBVR</div>
      <div class="gc-desc">Propósito del sistema: las reglas de negocio que gobiernan el comportamiento — condiciones, umbrales, restricciones regulatorias.</div>
      <div class="gc-dt">DT-Reglas</div>
      <div class="gc-sme">SPL Analysis · Industry Banking · Banking Accounting</div>
    </div>
    <div class="gc-layer transv" style="margin-left:10px">
      <div class="gc-num" style="background:#2e6b48">H</div>
      <div class="gc-title">Hilo Conductor</div>
      <div class="gc-count">7 dom · 67 capacidades</div>
      <div class="gc-desc">Taxonomía AS-IS 5 niveles: la referencia canónica que ancla todo artefacto del Gemelo a un nodo del negocio.</div>
      <div class="gc-dt">DT-Modelo-Dominio</div>
      <div class="gc-sme">Core Banking · Industry Banking · DBA Informix</div>
    </div>
    <div class="gc-layer transv">
      <div class="gc-num" style="background:#8b2020">⚠</div>
      <div class="gc-title">Calidad</div>
      <div class="gc-count">ISO 5055 · CWE · 7R</div>
      <div class="gc-desc">Salud estructural del AS-IS: métricas de deuda técnica, complejidad ciclomática, vulnerabilidades CWE — input de la decisión 7R.</div>
      <div class="gc-dt">Specialist Code Quality</div>
      <div class="gc-sme">Code Quality Assessment (HVM-wide)</div>
    </div>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════
     SECCIÓN 2: GRAFO DE DEPENDENCIAS
═══════════════════════════════════════════════════════════ -->
<div class="section" style="margin-top:28px">
  <div class="shead"><div class="icon" style="background:#B71C1C">🔗</div>Grafo de Dependencias de Dominios Informix</div>
  <div class="ssub">Las 12 bases de datos Informix como nodos. Las aristas representan llamadas cross-DB reales del call graph (34,279 total). El grosor es proporcional al volumen de llamadas. Color = wave de migración.</div>
  <div id="domain-graph"></div>
  <div class="legend" style="margin-top:12px">
    <span style="font-size:10px;font-weight:700;color:var(--muted);margin-right:4px">Wave:</span>
    <div class="leg-item"><div class="leg-dot" style="background:#F57F17"></div>Wave 1</div>
    <div class="leg-item"><div class="leg-dot" style="background:#B71C1C"></div>Wave 2</div>
    <div class="leg-item"><div class="leg-dot" style="background:#2E7D32"></div>Wave 3</div>
    <div class="leg-item"><div class="leg-dot" style="background:#0277BD"></div>Wave 4</div>
    <div class="leg-item"><div class="leg-dot" style="background:#6A00B3"></div>Wave 5</div>
    <div class="leg-item"><div class="leg-dot" style="background:#A100FF"></div>ÚLTIMO (migra al final)</div>
    <span style="margin-left:16px;font-size:10px;font-weight:700;color:var(--muted)">Riesgo:</span>
    <div class="leg-item"><div class="leg-dot" style="background:#22c55e"></div>Bajo</div>
    <div class="leg-item"><div class="leg-dot" style="background:#f59e0b"></div>Medio</div>
    <div class="leg-item"><div class="leg-dot" style="background:#ef4444"></div>Alto</div>
    <div class="leg-item"><div class="leg-dot" style="background:#dc2626;border:2px solid #ff4444"></div>Crítico</div>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════
     SECCIÓN 3: MAPA SEMÁNTICO BC × DOMINIO
═══════════════════════════════════════════════════════════ -->
<div class="section" style="margin-top:28px">
  <div class="shead"><div class="icon" style="background:#0277BD">📊</div>Mapa Semántico — Vocabulario por Bounded Context × Dominio</div>
  <div class="ssub">Cada celda = número de términos del vocabulario con esa combinación BC–Dominio Informix. Intensidad del azul = densidad semántica. Las celdas vacías indican que ese dominio no aporta vocabulario a ese BC.</div>
  <div class="hm-wrap">__HEATMAP__</div>
</div>

<!-- ═══════════════════════════════════════════════════════════
     SECCIÓN 4: TAXONOMÍA DE NEGOCIO
═══════════════════════════════════════════════════════════ -->
<div class="section" style="margin-top:28px">
  <div class="shead"><div class="icon" style="background:#2e6b48">🌲</div>Taxonomía de Negocio BanCoppel</div>
  <div class="ssub">Modelo lógico AS-IS de 5 niveles: L1 Dominio → L2 Subdominio → L3 Capacidad → L4 Proceso → L5 Tarea. Hilo conductor del Gemelo Cognitivo: todo artefacto se referencia a un nodo de esta jerarquía. Clic en un nodo para expandir/colapsar.</div>
  <div class="tax-wrap" id="tax-tree">__TREE__</div>
</div>

<!-- ═══════════════════════════════════════════════════════════
     SECCIÓN 5: DIGITAL TWINS SWARM
═══════════════════════════════════════════════════════════ -->
<div class="section" style="margin-top:28px;padding-bottom:40px">
  <div class="shead"><div class="icon" style="background:#8b3a8b">🤖</div>Swarm de Digital Twins</div>
  <div class="ssub">8 Digital Twins peers, cada uno propietario de un artefacto del Gemelo Cognitivo. Heredan talento de los SMEs declarados en su CLAUDE.md y operan en el contexto exclusivo de BCOPCore.</div>
  <div class="dt-grid">__DTCARDS__</div>
</div>

<!-- ═══════════════════════════════════════════════════════════
     SECCIÓN 6: ARQUITECTURA DEL KNOWLEDGE BASE
═══════════════════════════════════════════════════════════ -->
<div class="section" style="margin-top:28px">
  <div class="shead"><div class="icon" style="background:#0277BD">📁</div>Arquitectura del Knowledge Base — Relaciones entre Documentos</div>
  <div class="ssub">361 archivos .md organizados en 4 capas de conocimiento. Las capas síntesis y cross-reference agregan información de los 16 dominios analizados. Los dominios D17–D49 tienen solo el índice inicial (00-index.md).</div>

  <div class="kb-legend">
    <div class="kb-leg"><div class="dot" style="background:#dcfce7;border:1px solid #86efac"></div>Artefacto analizado (22 tipos)</div>
    <div class="kb-leg"><div class="dot" style="background:#fef3c7;border:1px solid #fcd34d"></div>Solo 00-index.md (stub)</div>
    <div class="kb-leg"><div class="dot" style="background:#f5f7ff;border:1px solid #c7d2fe"></div>Tipo no generado (D16 parcial)</div>
    <div style="flex:1"></div>
    <div class="kb-leg" style="font-size:9px;background:rgba(18,47,177,.05);padding:4px 10px;border-radius:6px">
      D01–D15: 22 tipos de artefacto completos · D16: 8/22 · D17–D49: 1/22</div>
  </div>

  <div>__KB_COVERAGE__</div>

  <div style="margin-top:22px">
    <div style="font-size:13px;font-weight:700;margin-bottom:6px;color:var(--blue)">Red de Documentos — Síntesis · Cross-Reference · Vocabulario · Dominios</div>
    <div style="font-size:11px;color:var(--muted);margin-bottom:10px">Cada nodo es un documento o carpeta de dominio. Las aristas sólidas = cobertura específica. Las aristas punteadas = cobertura universal (el documento cubre todos los dominios D01–D16). El tamaño del nodo es proporcional al tamaño del archivo.</div>
    <div class="kb-legend">
      <div class="kb-leg"><div class="dot" style="background:#8b3a8b"></div>Síntesis (root KB)</div>
      <div class="kb-leg"><div class="dot" style="background:#0277BD"></div>Cross-Reference</div>
      <div class="kb-leg"><div class="dot" style="background:#d4a800"></div>Vocabulario</div>
      <div class="kb-leg"><div class="dot" style="background:#dc2626"></div>Reglas formales</div>
      <div class="kb-leg"><div class="dot" style="background:#A100FF"></div>Dominio Informix analizado</div>
      <div class="kb-leg"><div class="dot" style="background:#aab;border:1px solid #888"></div>Stubs D17–D49</div>
      <div style="flex:1"></div>
      <div class="kb-leg"><div class="line-s" style="background:#888;border-top:2px dashed #aaa"></div>Cubre todos</div>
      <div class="kb-leg"><div class="line-s" style="background:#888;border-top:2px solid #555"></div>Cubre dominio específico</div>
    </div>
    <div id="kb-doc-graph"></div>
  </div>
</div>

<footer>
  <span>BCOPCore · SPE-AM-001 · Gemelo Cognitivo del Sistema · knowledge-graph-bcop.html</span>
  <span>IBM Informix IDS 14.10 / POWER-AIX · generado con build-knowledge-graph.py · 2026-08-03</span>
</footer>

<div id="graph-tooltip"></div>

<script>
// ── DATA ──
const NODES = __NODES__;
const EDGES = __EDGES__;
const ROOTS = __ROOTS__;

// ── TAXONOMY toggle ──
document.querySelectorAll('.tx-l1-hd').forEach(hd=>{
  const l1 = hd.parentElement;
  hd.onclick=()=>l1.classList.toggle('collapsed');
});
document.querySelectorAll('.tx-l2-hd').forEach(hd=>{
  const l2 = hd.parentElement;
  hd.onclick=()=>{l2.classList.toggle('collapsed');};
});

// ── D3 FORCE GRAPH ──
(function(){
  const W=900, H=520, PR=window.devicePixelRatio||1;
  const svg = d3.select('#domain-graph')
    .append('svg')
    .attr('width','100%')
    .attr('height',H)
    .attr('viewBox',`0 0 ${W} ${H}`)
    .attr('preserveAspectRatio','xMidYMid meet');

  const defs = svg.append('defs');
  // arrow marker per color
  const markers=[{id:'arr-heavy',color:'#ef4444'},{id:'arr-med',color:'#94a3b8'}];
  markers.forEach(m=>{
    defs.append('marker').attr('id',m.id).attr('viewBox','0 -5 10 10')
      .attr('refX',10).attr('refY',0).attr('markerWidth',5).attr('markerHeight',5)
      .attr('orient','auto')
      .append('path').attr('d','M0,-5L10,0L0,5').attr('fill',m.color).attr('opacity',.7);
  });

  // Pre-build node lookup
  const nodeById = {};
  NODES.forEach(n=>{nodeById[n.id]=n;});

  // Make links reference node objects
  const links = EDGES.map(e=>({
    ...e, source:nodeById[e.source]||e.source, target:nodeById[e.target]||e.target
  }));

  // ── PRE-CALCULATE LAYOUT (no tick listener, per CLAUDE.md rules) ──
  const sim = d3.forceSimulation(NODES)
    .force('link', d3.forceLink(links).id(d=>d.id).distance(d=>{
      const v=d.value||1; return v>5000?80:v>1000?100:v>100?120:140;
    }).strength(0.4))
    .force('charge', d3.forceManyBody().strength(-700))
    .force('center', d3.forceCenter(W/2, H/2))
    .force('collision', d3.forceCollide().radius(d=>d.r+12))
    .stop();

  for(let i=0;i<500;++i) sim.tick();

  // Clamp to viewport
  NODES.forEach(n=>{
    n.x = Math.max(n.r+8, Math.min(W-n.r-8, n.x));
    n.y = Math.max(n.r+8, Math.min(H-n.r-8, n.y));
  });

  // ── RENDER EDGES ──
  const edgeG = svg.append('g').attr('class','edges');
  const edgeSel = edgeG.selectAll('path').data(links).enter().append('path')
    .attr('class','edge-path')
    .attr('d', d=>{
      const sx=d.source.x, sy=d.source.y, tx=d.target.x, ty=d.target.y;
      const mx=(sx+tx)/2, my=(sy+ty)/2;
      const dx=tx-sx, dy=ty-sy;
      const perp = Math.sqrt(dx*dx+dy*dy);
      const cx=mx - dy*0.15, cy=my + dx*0.15;
      return `M${sx},${sy} Q${cx},${cy} ${tx},${ty}`;
    })
    .attr('stroke', d=>{
      const v=d.value||1;
      return v>5000?'#dc2626':v>1000?'#ef4444':v>200?'#f97316':'#94a3b8';
    })
    .attr('stroke-width', d=>Math.max(1, Math.min(8, 0.7+Math.log10(d.value||1)*1.5)))
    .attr('marker-end', d=>d.value>200?'url(#arr-heavy)':'url(#arr-med)');

  // ── RENDER NODES ──
  const nodeG = svg.append('g').attr('class','nodes');
  const nodeSel = nodeG.selectAll('g').data(NODES).enter().append('g')
    .attr('class',d=>`node node-${d.id}`)
    .attr('transform',d=>`translate(${d.x},${d.y})`)
    .attr('cursor','grab');

  nodeSel.append('circle')
    .attr('r',d=>d.r)
    .attr('fill',d=>d.color)
    .attr('stroke','rgba(255,255,255,.3)')
    .attr('stroke-width',2);

  // risk ring
  nodeSel.append('circle')
    .attr('r',d=>d.r+3)
    .attr('fill','none')
    .attr('stroke',d=>{
      const rc={BAJO:'#22c55e',MEDIO:'#f59e0b',ALTO:'#ef4444',CRÍTICO:'#dc2626'};
      return rc[d.risk]||'transparent';
    })
    .attr('stroke-width',d=>d.risk==='CRÍTICO'?2.5:1.5)
    .attr('stroke-dasharray',d=>d.risk==='CRÍTICO'?'none':'4,3')
    .attr('opacity',.7);

  nodeSel.append('text').attr('class','node-label').attr('y',-3).text(d=>d.label);
  nodeSel.append('text').attr('class','node-sub').attr('y',9)
    .text(d=>{const tot=d.total_in+d.total_out;return tot>1000?(tot/1000).toFixed(1)+'k':tot;});

  // ── TOOLTIP ──
  const tip = document.getElementById('graph-tooltip');
  nodeSel.on('mouseenter',(ev,d)=>{
    tip.style.display='block';
    tip.innerHTML=`<b>${d.label} — ${d.name}</b><br>Wave: ${d.wave} · Riesgo: ${d.risk}<br>BC target: ${d.bc}<br>Llamadas entrantes: ${d.total_in.toLocaleString()}<br>Llamadas salientes: ${d.total_out.toLocaleString()}`;
  }).on('mousemove',ev=>{
    tip.style.left=(ev.clientX+14)+'px'; tip.style.top=(ev.clientY-10)+'px';
  }).on('mouseleave',()=>{ tip.style.display='none'; });

  edgeSel.on('mouseenter',(ev,d)=>{
    tip.style.display='block';
    tip.innerHTML=d.tooltip;
  }).on('mousemove',ev=>{
    tip.style.left=(ev.clientX+14)+'px'; tip.style.top=(ev.clientY-10)+'px';
  }).on('mouseleave',()=>{ tip.style.display='none'; });

  // ── DRAG (sin reiniciar simulación) ──
  nodeSel.call(d3.drag()
    .on('start',function(ev,d){ d3.select(this).raise().attr('cursor','grabbing'); })
    .on('drag',function(ev,d){
      d.x += ev.dx; d.y += ev.dy;
      d3.select(this).attr('transform',`translate(${d.x},${d.y})`);
      edgeSel.filter(l=>l.source.id===d.id||l.target.id===d.id)
        .attr('d', l=>{
          const sx=l.source.x, sy=l.source.y, tx=l.target.x, ty=l.target.y;
          const mx=(sx+tx)/2, my=(sy+ty)/2;
          const dx2=tx-sx, dy2=ty-sy;
          const cx=mx - dy2*0.15, cy=my + dx2*0.15;
          return `M${sx},${sy} Q${cx},${cy} ${tx},${ty}`;
        });
    })
    .on('end',function(){ d3.select(this).attr('cursor','grab'); })
  );
})();

// ── KB DOCUMENT GRAPH ──
(function(){
  const KBNODES = __KB_GNODES__;
  const KBEDGES = __KB_GEDGES__;

  const W=960, H=580;
  const svg = d3.select('#kb-doc-graph')
    .append('svg')
    .attr('width','100%')
    .attr('height',H)
    .attr('viewBox',`0 0 ${W} ${H}`)
    .attr('preserveAspectRatio','xMidYMid meet');

  const defs2 = svg.append('defs');
  defs2.append('marker').attr('id','kb-arr').attr('viewBox','0 -4 8 8')
    .attr('refX',8).attr('refY',0).attr('markerWidth',5).attr('markerHeight',5)
    .attr('orient','auto')
    .append('path').attr('d','M0,-4L8,0L0,4').attr('fill','#aaa').attr('opacity',.6);

  const kbNodeById = {};
  KBNODES.forEach(n=>{ kbNodeById[n.id]=n; });

  const kbLinks = KBEDGES.map(e=>({
    ...e,
    source: kbNodeById[e.source]||e.source,
    target: kbNodeById[e.target]||e.target
  }));

  // ── PRE-CALCULATE LAYOUT (no tick listener) ──
  const DOC_TYPES = ['synthesis','crossref','vocabulary','rules'];
  const sim2 = d3.forceSimulation(KBNODES)
    .force('link', d3.forceLink(kbLinks).id(d=>d.id).distance(d=>d.dashed?110:70).strength(0.25))
    .force('charge', d3.forceManyBody().strength(d=>DOC_TYPES.includes(d.type)?-350:-200))
    .force('center', d3.forceCenter(W/2, H/2))
    .force('collision', d3.forceCollide().radius(d=>d.r+8))
    .force('x', d3.forceX().x(d=>{
      if(DOC_TYPES.includes(d.type)) return W*0.25;
      if(d.type==='stub') return W*0.82;
      return W*0.68;
    }).strength(0.12))
    .stop();

  for(let i=0;i<500;++i) sim2.tick();

  KBNODES.forEach(n=>{
    n.x = Math.max(n.r+4, Math.min(W-n.r-4, n.x));
    n.y = Math.max(n.r+4, Math.min(H-n.r-4, n.y));
  });

  // ── EDGES ──
  const kbEdgeSel = svg.append('g').selectAll('line').data(kbLinks).enter()
    .append('line')
    .attr('x1',d=>d.source.x).attr('y1',d=>d.source.y)
    .attr('x2',d=>d.target.x).attr('y2',d=>d.target.y)
    .attr('stroke',d=>d.dashed?'#c0c8e8':'#94a3b8')
    .attr('stroke-width',d=>d.dashed?1:1.2)
    .attr('stroke-dasharray',d=>d.dashed?'5,3':'none')
    .attr('stroke-opacity',d=>d.dashed?.5:.7)
    .attr('marker-end','url(#kb-arr)');

  // ── NODES ──
  const kbNodeSel = svg.append('g').selectAll('g').data(KBNODES).enter()
    .append('g')
    .attr('transform',d=>`translate(${d.x},${d.y})`)
    .attr('cursor','grab');

  kbNodeSel.append('circle')
    .attr('r',d=>d.r)
    .attr('fill',d=>d.color)
    .attr('stroke','rgba(255,255,255,.35)').attr('stroke-width',1.5)
    .attr('opacity',d=>d.type==='stub'?.55:1);

  // icon by type
  const typeIcon = {synthesis:'◆',crossref:'⬡',vocabulary:'◉',rules:'▲',domain:'●',stub:'○'};
  kbNodeSel.append('text').attr('class','kb-doc-label').attr('y',d=>d.r>20?-4:-2)
    .text(d=>{
      if(d.type==='domain'||d.type==='stub') return d.label;
      const w=d.label.replace('vocabulary-','vocab-').replace('business-','biz-')
               .replace('migration-risk','mig-risk').replace('-bcop','');
      return w.length>14?w.slice(0,13)+'…':w;
    });
  kbNodeSel.filter(d=>d.r>20).append('text').attr('class','kb-doc-sub').attr('y',8)
    .text(d=>{
      if(d.type==='domain') return `${d.sps}SPs`;
      return `${d.size_kb}KB`;
    });

  // ── TOOLTIP ──
  const tip2 = document.getElementById('graph-tooltip');
  kbNodeSel.on('mouseenter',(ev,d)=>{
    tip2.style.display='block';
    const typeLabel = {synthesis:'Síntesis KB',crossref:'Cross-Reference',vocabulary:'Vocabulario',
                       rules:'Reglas Formales',domain:'Dominio Informix',stub:'Stubs pendientes'}[d.type]||d.type;
    tip2.innerHTML=`<b>${d.label}</b><br>Tipo: ${typeLabel}<br>${d.desc}${d.size_kb?'<br>Tamaño: '+d.size_kb+'KB':''}`;
  }).on('mousemove',ev=>{
    tip2.style.left=(ev.clientX+14)+'px'; tip2.style.top=(ev.clientY-10)+'px';
  }).on('mouseleave',()=>{ tip2.style.display='none'; });

  // ── DRAG ──
  kbNodeSel.call(d3.drag()
    .on('start',function(ev,d){ d3.select(this).raise().attr('cursor','grabbing'); })
    .on('drag',function(ev,d){
      d.x += ev.dx; d.y += ev.dy;
      d3.select(this).attr('transform',`translate(${d.x},${d.y})`);
      kbEdgeSel.filter(l=>l.source.id===d.id||l.target.id===d.id)
        .attr('x1',l=>l.source.x).attr('y1',l=>l.source.y)
        .attr('x2',l=>l.target.x).attr('y2',l=>l.target.y);
    })
    .on('end',function(){ d3.select(this).attr('cursor','grab'); })
  );
})();
</script>
</body>
</html>
"""

# ──────────────────────────────────────────────────────────────────────────────
# 10. RENDER DT CARDS
# ──────────────────────────────────────────────────────────────────────────────
def dt_cards():
    parts = []
    for d in DTS:
        c = d["color"]
        tc = "#0a1330" if c == "#F0D224" else "#fff"
        parts.append(
            f'<div class="dt-card" style="border-top:3px solid {c}">'
            f'<div class="dt-num" style="background:{c};color:{tc}">{d["capa"]}</div>'
            f'<div class="dt-name">{d["name"]}</div>'
            f'<div class="dt-count">{d["count"]}</div>'
            f'<div class="dt-desc">{d["desc"]}</div>'
            f'<div class="dt-sme">SMEs: {d["smes"]}</div>'
            f'</div>'
        )
    return "\n".join(parts)

# ──────────────────────────────────────────────────────────────────────────────
# 11. INJECT ALL DATA
# ──────────────────────────────────────────────────────────────────────────────
HTML = HTML.replace("__VOCAB__", str(n_vocab))
HTML = HTML.replace("__BCCOUNT__", str(n_bc_covered))
HTML = HTML.replace("__HEATMAP__", HEATMAP_HTML)
HTML = HTML.replace("__TREE__", TREE_HTML)
HTML = HTML.replace("__DTCARDS__", dt_cards())
HTML = HTML.replace("__NODES__", D3_NODES)
HTML = HTML.replace("__EDGES__", D3_EDGES)
HTML = HTML.replace("__ROOTS__", ROOTS_JSON)
HTML = HTML.replace("__KB_COVERAGE__", KB_COVERAGE_HTML)
HTML = HTML.replace("__KB_GNODES__", KB_GNODES_JSON)
HTML = HTML.replace("__KB_GEDGES__", KB_GEDGES_JSON)

out = BASE / "knowledge-graph-bcop.html"
out.write_text(HTML, encoding="utf-8")
print(f"knowledge-graph-bcop.html escrito · {len(HTML)//1024}KB")
print(f"  {len(d3_nodes)} nodos · {len(d3_edges)} aristas · {len(taxonomy)} dominios taxonomía")
print(f"  {len(bc_count)} BCs con vocabulario · {sum(bc_count.values())} términos con BC asignado")