#!/usr/bin/env python3
"""
Generador procedural del seed SISTEMA-CORE-UNISYS.

Produce un grafo de dependencias REALISTA de un core bancario Unisys ClearPath:
distribucion scale-free (pocos hubs de fan-in alto), capas con fugas, ciclos
(SCCs), acoplamiento por copybook como capa separada y un cluster muerto.

A esta escala NO se emiten ~800 fuentes a mano: se emite el grafo como dato
(graph/*.json) y el answer key se COMPUTA del grafo generado -> coherencia
garantizada (el grafo es la fuente de verdad). El source representativo
(hubs + bounded context 'deposits') se escribe aparte, a mano.

Determinista por semilla (output.seed en generation-spec.yaml).
"""
import json
import random
import os
from collections import defaultdict

# ---- Parametros (espejo de generation-spec.yaml) ----
SEED = 2200
N_BL = 460
N_ONLINE = 140
N_DA = 110
N_WFL = 76
N_UTIL = 14
N_DEAD = 30
PREF_EXP = 1.4
CROSS_DOMAIN_LEAKAGE = 0.18
N_CYCLES = 6
CYCLE_SIZE = (3, 7)
DOMAINS = ["deposits", "payments", "loans", "cards", "gl",
           "customer", "reporting", "channels"]
DOM_ABBR = {"deposits": "DEP", "payments": "PAY", "loans": "LON",
            "cards": "CRD", "gl": "GL", "customer": "CUS",
            "reporting": "RPT", "channels": "CHN"}

UTIL_NAMES = ["UDATECONV", "UERRHND", "ULOGWRT", "UDMSIIRD", "UDMSIIWR",
              "UNUMFMT", "UMSGFMT", "USECCHK", "UCURRCNV", "UTBLLKUP",
              "UAUDITWR", "UTRACE", "UPARSEDT", "USIGNCHK"]

# Copybooks COMPARTIDOS con nombre realista (prefijo de libreria CB- = Core Banking)
# y significado EXPLICITO. Formato: nombre -> (dominios, fraccion, descripcion)
SHARED_CPY = {
    "CB-RETCODE":    (DOMAINS, 0.92, "Standard return code shared across programs"),
    "CB-ENCABEZADO": (DOMAINS, 0.85, "Standard record header (common layout)"),
    "CB-IMPORTE":    (["deposits", "payments", "loans", "cards", "gl"], 0.80,
                      "Standard monetary amount (amount, currency, sign)"),
    "CB-CLIENTE":    (["customer", "deposits", "loans", "cards", "payments"], 0.70,
                      "Customer master data"),
    "CB-CUENTA":     (["deposits", "gl", "loans"], 0.75, "Bank account master"),
    "CB-ASIENTO":    (["gl", "deposits", "loans", "payments"], 0.55,
                      "Accounting entry — posting to the General Ledger"),
}
# Copybooks por dominio: 3 roles estandar por dominio, con significado explicito
DOM_CPY_ROLES = [
    ("PARAMETRO", "Configuration parameters of the"),
    ("CATALOGO",  "Reference catalog/table of the"),
    ("AUXILIAR",  "Auxiliary working structure of the"),
]
DOMAIN_LABEL_ES = {
    "deposits": "deposits domain", "payments": "payments domain", "loans": "loans domain",
    "cards": "cards domain", "gl": "GL (accounting) domain", "customer": "customer domain",
    "reporting": "reporting domain", "channels": "channels domain",
}
copybook_desc = {}  # nombre -> descripcion (glosario explicito)

rnd = random.Random(SEED)

# ---- 1. Crear nodos ----
nodes = {}   # id -> dict(layer, domain, loc)
by_layer = defaultdict(list)
by_domain_layer = defaultdict(list)

def add_node(nid, layer, domain, loc):
    nodes[nid] = {"id": nid, "layer": layer, "domain": domain, "loc": loc}
    by_layer[layer].append(nid)
    by_domain_layer[(domain, layer)].append(nid)

# utilerias (dominio 'shared')
for i, name in enumerate(UTIL_NAMES[:N_UTIL]):
    add_node(name, "UTIL", "shared", rnd.randint(40, 220))

def make(prefix, layer, count, loc_range):
    seq = 0
    for _ in range(count):
        dom = rnd.choice(DOMAINS)
        seq += 1
        nid = f"{DOM_ABBR[dom]}{prefix}{seq:04d}"
        add_node(nid, layer, dom, rnd.randint(*loc_range))

make("B", "BL", N_BL, (120, 900))
make("O", "ONLINE", N_ONLINE, (80, 400))
make("D", "DA", N_DA, (60, 300))
make("W", "WFL", N_WFL, (40, 200))

# cluster muerto: isla huerfana (no alcanzable)
dead_ids = []
for i in range(N_DEAD):
    nid = f"ZZDEAD{i:03d}"
    add_node(nid, "BL", "obsolete", rnd.randint(100, 500))
    dead_ids.append(nid)

# ---- intent de acceso a datos por programa (dirige el ruteo a DMSII) ----
# read-only = solo consulta; update = escribe en el sistema de registro.
# El cableado posterior garantiza que un programa 'read' nunca alcance al writer.
INTENT_P = {"DA": 0.45, "BL": 0.40, "ONLINE": 0.55, "WFL": 0.30}  # prob. de read-only
for _id, _nd in nodes.items():
    if _nd["layer"] == "UTIL" or _nd["domain"] == "obsolete":
        _nd["intent"] = "none"
    else:
        _nd["intent"] = "read" if rnd.random() < INTENT_P.get(_nd["layer"], 0.4) else "update"
nodes["UDMSIIRD"]["intent"] = "read"
nodes["UDMSIIWR"]["intent"] = "update"

edges = []  # (src, dst, type)
indeg = defaultdict(int)

def add_edge(s, d, t):
    if s == d:
        return
    edges.append((s, d, t))
    indeg[d] += 1

# ---- 2. Utilerias: el pool generico EXCLUYE los wrappers DMSII ----
# (asi una llamada generica a utileria no crea por accidente un camino de escritura)
util_ids = by_layer["UTIL"]
gen_util = [u for u in util_ids if u not in ("UDMSIIRD", "UDMSIIWR")]
def pick_util():
    weights = [(indeg[u] + 1) ** PREF_EXP for u in gen_util]
    return rnd.choices(gen_util, weights=weights, k=1)[0]

# utilerias entre si (cadena minima)
add_edge("UERRHND", "ULOGWRT", "CALL")
add_edge("UAUDITWR", "ULOGWRT", "CALL")
add_edge("UPARSEDT", "UDATECONV", "CALL")

bl_ids = by_layer["BL"]
da_ids = by_layer["DA"]
online_ids = by_layer["ONLINE"]
wfl_ids = by_layer["WFL"]

def pool(layer, intent, dom=None):
    """Programas de una capa con cierto intent (opcionalmente de un dominio)."""
    if dom is not None:
        r = [n for n in by_domain_layer[(dom, layer)] if nodes[n]["intent"] == intent]
        if r:
            return r
    return [n for n in by_layer[layer] if nodes[n]["intent"] == intent] or by_layer[layer]

# ---- 3. WFL -> BL/ONLINE (mismo intent que el job) ----
for w in wfl_ids:
    dom, it = nodes[w]["domain"], nodes[w]["intent"]
    cands = pool("BL", it, dom) + pool("ONLINE", it, dom)
    if not cands:
        cands = pool("BL", it)
    for t in rnd.sample(cands, min(len(cands), rnd.randint(2, 6))):
        add_edge(w, t, "RUN")

# ---- 4. ONLINE -> BL (mismo intent; la fuga cruza dominio, no intent) ----
for o in online_ids:
    dom, it = nodes[o]["domain"], nodes[o]["intent"]
    for _ in range(rnd.randint(1, 4)):
        if rnd.random() < CROSS_DOMAIN_LEAKAGE:
            add_edge(o, rnd.choice(pool("BL", it)), "CALL")
        else:
            add_edge(o, rnd.choice(pool("BL", it, dom)), "CALL")

# ---- 5. BL -> BL / DA / DMSII / UTIL (segun intent) ----
def pick_bl_pref(dom, it):
    p = pool("BL", it, dom)
    weights = [(indeg[b] + 1) ** PREF_EXP for b in p]
    return rnd.choices(p, weights=weights, k=1)[0]

for b in bl_ids:
    dom, it = nodes[b]["domain"], nodes[b]["intent"]
    # BL -> BL: 'read' solo llama a 'read' (preserva el cierre de consulta);
    #           'update' puede llamar a cualquiera.
    for _ in range(rnd.randint(0, 3)):
        tgt_it = rnd.choice(["read", "update"]) if (it == "update" and rnd.random() < 0.5) else it
        if rnd.random() < CROSS_DOMAIN_LEAKAGE:
            add_edge(b, rnd.choice(pool("BL", tgt_it)), "CALL")
        else:
            add_edge(b, pick_bl_pref(dom, tgt_it), "CALL")
    for _ in range(rnd.randint(1, 2)):                       # BL -> DA (intent-matched)
        add_edge(b, rnd.choice(pool("DA", it, dom)), "CALL")
    # BL -> wrapper DMSII directo: da fan-in alto a los wrappers y fija el acceso
    add_edge(b, "UDMSIIWR" if it == "update" else "UDMSIIRD", "CALL")
    for _ in range(rnd.randint(1, 4)):                       # BL -> UTIL generica (hubs)
        add_edge(b, pick_util(), "CALL")

# ---- 6. DA -> DMSII (segun intent) + utilerias ----
for d in da_ids:
    add_edge(d, "UDMSIIWR" if nodes[d]["intent"] == "update" else "UDMSIIRD", "CALL")
    for _ in range(rnd.randint(0, 2)):
        add_edge(d, pick_util(), "CALL")

# ---- 7. Ciclos: solo entre BL de actualizacion (no contamina las de consulta) ----
planted_cycles = []
used = set()
upd_bl = [b for b in bl_ids if nodes[b]["intent"] == "update"]
for _ in range(N_CYCLES):
    size = rnd.randint(*CYCLE_SIZE)
    avail = [b for b in upd_bl if b not in used]
    if len(avail) < size:
        break
    ring = rnd.sample(avail, size)
    used.update(ring)
    for i in range(size):
        add_edge(ring[i], ring[(i + 1) % size], "CALL")
    planted_cycles.append(ring)

# ---- 8. Cluster muerto: aristas internas, sin inbound del grafo vivo ----
for s in dead_ids:
    for _ in range(rnd.randint(1, 3)):
        add_edge(s, rnd.choice(dead_ids), "CALL")

# ---- 9. Copybooks (capa de acoplamiento separada del call graph) ----
copybook_usage = defaultdict(list)
all_prog = list(nodes.keys())

for cpy, (doms, frac, desc) in SHARED_CPY.items():
    copybook_desc[cpy] = desc
    for nid, nd in nodes.items():
        if nd["domain"] in doms and rnd.random() < frac:
            copybook_usage[cpy].append(nid)

# copybooks por dominio (3 roles c/u), nombre y significado explicitos
for dom in DOMAINS:
    progs = [n for n, nd in nodes.items() if nd["domain"] == dom]
    for role, role_desc in DOM_CPY_ROLES:
        cpy = f"{DOM_ABBR[dom]}-{role}"
        copybook_desc[cpy] = f"{role_desc} {DOMAIN_LABEL_ES.get(dom, dom)}"
        for nid in progs:
            if rnd.random() < 0.5:
                copybook_usage[cpy].append(nid)

# ============================================================
#  ANALISIS — el answer key se COMPUTA del grafo generado
# ============================================================
adj = defaultdict(list)
radj = defaultdict(list)
for s, d, t in edges:
    adj[s].append(d)
    radj[d].append(s)

N = len(nodes)
E = len(edges)

# --- Clasificacion de acceso a datos: consulta vs actualizacion ---
# Un programa es de ACTUALIZACION si su cierre de llamadas alcanza el wrapper
# de escritura DMSII (UDMSIIWR). Es de CONSULTA (read-only) si alcanza el de
# lectura (UDMSIIRD) pero nunca una escritura. Si no toca DMSII -> 'none'.
# Esto espeja el analisis estatico real de verbos READ/FIND vs STORE/MODIFY/ERASE.
def reach_to(target):
    seen2 = {target}; st2 = [target]
    while st2:
        v = st2.pop()
        for u in radj[v]:
            if u not in seen2:
                seen2.add(u); st2.append(u)
    return seen2
writers = reach_to("UDMSIIWR")
readers = reach_to("UDMSIIRD")
for nid in nodes:
    if nid in writers:
        nodes[nid]["access"] = "update"
    elif nid in readers:
        nodes[nid]["access"] = "read"
    else:
        nodes[nid]["access"] = "none"

# --- Hubs por in-degree ---
hubs = sorted(nodes.keys(), key=lambda n: indeg[n], reverse=True)[:20]

# --- Tarjan SCC ---
index_counter = [0]
stack, on_stack, lowlink, index = [], set(), {}, {}
sccs = []
import sys
sys.setrecursionlimit(10000)

def strongconnect(v):
    index[v] = index_counter[0]
    lowlink[v] = index_counter[0]
    index_counter[0] += 1
    stack.append(v); on_stack.add(v)
    for w in adj[v]:
        if w not in index:
            strongconnect(w)
            lowlink[v] = min(lowlink[v], lowlink[w])
        elif w in on_stack:
            lowlink[v] = min(lowlink[v], index[w])
    if lowlink[v] == index[v]:
        comp = []
        while True:
            w = stack.pop(); on_stack.discard(w); comp.append(w)
            if w == v:
                break
        sccs.append(comp)

for v in list(nodes.keys()):
    if v not in index:
        strongconnect(v)

nontrivial_sccs = [c for c in sccs if len(c) > 1]

# --- Reachability desde entry points (WFL + ONLINE) ---
roots = wfl_ids + online_ids
seen = set()
stack2 = list(roots)
while stack2:
    v = stack2.pop()
    if v in seen:
        continue
    seen.add(v)
    for w in adj[v]:
        if w not in seen:
            stack2.append(w)
unreachable = [n for n in nodes if n not in seen]

# --- Weakly connected components ---
uadj = defaultdict(set)
for s, d, _ in edges:
    uadj[s].add(d); uadj[d].add(s)
wcc_seen, wccs = set(), []
for start in nodes:
    if start in wcc_seen:
        continue
    comp, st = [], [start]
    while st:
        v = st.pop()
        if v in wcc_seen:
            continue
        wcc_seen.add(v); comp.append(v)
        st.extend(uadj[v] - wcc_seen)
    wccs.append(comp)

# --- Modularidad de la particion por dominio (proyeccion no dirigida) ---
m = E
deg = defaultdict(int)
for s, d, _ in edges:
    deg[s] += 1; deg[d] += 1
intra = 0
for s, d, _ in edges:
    if nodes[s]["domain"] == nodes[d]["domain"]:
        intra += 1
sum_a2 = 0.0
dom_deg = defaultdict(int)
for n in nodes:
    dom_deg[nodes[n]["domain"]] += deg[n]
for dom, dd in dom_deg.items():
    sum_a2 += (dd / (2 * m)) ** 2
Q = intra / m - sum_a2

density = E / (N * (N - 1))
avg_out = E / N
max_indeg = indeg[hubs[0]]

# ============================================================
#  ESCRITURA DE ARTEFACTOS
# ============================================================
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
GRAPH = os.path.join(ROOT, "graph")
AK = os.path.join(ROOT, "answer-key")
os.makedirs(GRAPH, exist_ok=True)
os.makedirs(AK, exist_ok=True)

# --- graph/dependency-graph.json ---
with open(os.path.join(GRAPH, "dependency-graph.json"), "w", encoding="utf-8") as f:
    json.dump({
        "system": "SISTEMA-CORE-UNISYS",
        "seed": SEED,
        "nodes": list(nodes.values()),
        "edges": [{"from": s, "to": d, "type": t} for s, d, t in edges],
    }, f, indent=1)

# --- graph/copybook-usage.json ---
with open(os.path.join(GRAPH, "copybook-usage.json"), "w", encoding="utf-8") as f:
    json.dump({cpy: sorted(set(progs)) for cpy, progs in copybook_usage.items()},
              f, indent=1)

# --- graph/copybook-glossary.json (nombre -> significado explicito) ---
with open(os.path.join(GRAPH, "copybook-glossary.json"), "w", encoding="utf-8") as f:
    json.dump(copybook_desc, f, indent=1, ensure_ascii=False)

# --- source/programs/{ID}.{cob|wfl} : esqueleto por nodo + source-map.json ---
# A escala el sistema es graph-as-data; aun así emitimos un esqueleto navegable
# por nodo, COHERENTE con el grafo (sus COPY = copybook-usage, sus CALL = aristas),
# para que la visualización pueda enlazar "ver código fuente" de cualquier programa.
PROGDIR = os.path.join(ROOT, "source", "programs")
os.makedirs(PROGDIR, exist_ok=True)
prog_cpys = defaultdict(list)
for _cpy, _progs in copybook_usage.items():
    for _p in set(_progs):
        prog_cpys[_p].append(_cpy)
ACC_LBL = {"read": "inquiry (read-only)", "update": "update (writes)",
           "none": "no data access"}
def emit_cobol(pid, nd, outs):
    cpys = sorted(set(prog_cpys.get(pid, [])) | {"CB-RETCODE"})  # CB-RETCODE da RC-AREA
    copy_lines = "\n".join(f"           COPY {c}." for c in cpys) or "      *    (no copybooks)"
    call_lines = "\n".join(f"           CALL '{o}'." for o in outs) or "      *    (does not call other programs)"
    if nd["access"] == "update":
        dataccess = "           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record"
    elif nd["access"] == "read":
        dataccess = "           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only"
    else:
        dataccess = "      *    (does not touch the database)"
    return f"""       IDENTIFICATION DIVISION.
       PROGRAM-ID. {pid}.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : {nd['layer']:<8} DOMAIN  : {nd['domain']}
      * ACCESS  : {ACC_LBL.get(nd['access'], nd['access'])}
      * FAN-IN  : {indeg[pid]}   FAN-OUT : {len(outs)}   LOC approx: {nd['loc']}
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
{copy_lines}
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
{call_lines}
{dataccess}
           GOBACK.
"""
def emit_wfl(pid, nd, outs):
    runs = "\n".join(f"  RUN OBJECT/{nd['domain'].upper()}/{o};" for o in outs) or "  % (no steps)"
    return f"""?BEGIN JOB {pid};
% =================================================================
% SISTEMA-CORE-UNISYS · WFL layer · domain {nd['domain']} (synthetic)
% Orchestrates the programs of its domain. RUN = graph edges.
% =================================================================
  CLASS = 5;
{runs}
  DISPLAY "{pid}: done";
?END JOB.
"""
source_map = {}
for pid, nd in nodes.items():
    outs = sorted(set(adj[pid]))
    if nd["layer"] == "WFL":
        ext, body = "wfl", emit_wfl(pid, nd, outs)
    else:
        ext, body = "cob", emit_cobol(pid, nd, outs)
    open(os.path.join(PROGDIR, f"{pid}.{ext}"), "w", encoding="utf-8").write(body)
    source_map[pid] = f"source/programs/{pid}.{ext}"   # relativo a la raíz del seed (donde vive graph-view.html)
with open(os.path.join(GRAPH, "source-map.json"), "w", encoding="utf-8") as f:
    json.dump(source_map, f, indent=1)

def w_md(name, text):
    with open(os.path.join(AK, name), "w", encoding="utf-8") as f:
        f.write(text)

# --- ground-truth-graph-metrics.md ---
w_md("ground-truth-graph-metrics.md", f"""# Ground Truth — Métricas de Grafo · SISTEMA-CORE-UNISYS

> Computado del grafo generado (seed {SEED}). El grafo es la fuente de verdad.

| Métrica | Valor |
|---------|-------|
| Nodos (programas/objetos) | {N} |
| Aristas (dependencias de llamada) | {E} |
| Densidad | {density:.5f} |
| Grado de salida promedio | {avg_out:.2f} |
| Fan-in máximo (top hub: {hubs[0]}) | {max_indeg} |
| SCCs no triviales (ciclos) | {len(nontrivial_sccs)} |
| Componentes débilmente conexas (WCC) | {len(wccs)} |
| Nodos no alcanzables desde entry points | {len(unreachable)} |
| Modularidad Q (partición por dominio) | {Q:.3f} |

**Lectura:** densidad baja pero fan-in altísimo concentrado en pocos hubs = firma
scale-free. Q ~ 0.3-0.5 indica comunidades reales pero con fuga (no es 1.0 porque
los dominios se acoplan vía hubs y leakage). {len(wccs)} WCC => hay al menos una
isla desconectada (cluster muerto).
""")

# --- ground-truth-hubs.md ---
rows = "\n".join(
    f"| {i+1} | {h} | {nodes[h]['layer']} | {nodes[h]['domain']} | {indeg[h]} |"
    for i, h in enumerate(hubs))
w_md("ground-truth-hubs.md", f"""# Ground Truth — Hubs (fan-in alto) · SISTEMA-CORE-UNISYS

> Los hubs son el corazón del hairball: utilerías llamadas por cientos de programas.
> Una herramienta de RE debe identificarlos como nodos de máximo riesgo de migración
> (tocarlos impacta a todo el sistema).

| # | Programa | Capa | Dominio | Fan-in |
|---|----------|------|---------|--------|
{rows}

`[BENCHMARK]` Los hubs UTIL (DATECONV, ERRHND, DMSIIRD…) deben aparecer en el top.
Quien no los detecte subestimará el blast radius de cualquier cambio.
""")

# --- ground-truth-access-classification.md ---
from collections import Counter
acc_overall = Counter(nd["access"] for nd in nodes.values())
acc_by_layer = defaultdict(Counter)
acc_by_dom = defaultdict(Counter)
for nd in nodes.values():
    acc_by_layer[nd["layer"]][nd["access"]] += 1
    acc_by_dom[nd["domain"]][nd["access"]] += 1
def acc_row(label, c):
    tot = c["read"] + c["update"] + c["none"]
    return f"| {label} | {c['read']} | {c['update']} | {c['none']} | {tot} |"
layer_rows = "\n".join(acc_row(L, acc_by_layer[L]) for L in ["WFL", "ONLINE", "BL", "DA", "UTIL"])
dom_rows = "\n".join(acc_row(d, acc_by_dom[d]) for d in sorted(acc_by_dom) if d not in ("shared", "obsolete"))
onl = acc_by_layer["ONLINE"]
onl_tot = onl["read"] + onl["update"] + onl["none"]
w_md("ground-truth-access-classification.md", f"""# Ground Truth — Consulta vs Actualización · SISTEMA-CORE-UNISYS

> ¿Cómo se sabe qué transacciones son de **solo consulta** y cuáles de **actualización**?
> Por análisis estático de los verbos de acceso a datos. Un programa es de
> **actualización** si su cierre de llamadas alcanza una escritura al sistema de
> registro (aquí, el wrapper `UDMSIIWR`); de **consulta** si alcanza lectura
> (`UDMSIIRD`) pero **nunca** una escritura; `none` si no toca la base.

## Resumen del sistema
| Tipo | Programas |
|------|-----------|
| Consulta (read-only) | {acc_overall['read']} |
| Actualización (transaccional) | {acc_overall['update']} |
| Sin acceso a datos (compute/util) | {acc_overall['none']} |

## Por capa
| Capa | Consulta | Actualización | Sin acceso | Total |
|------|---------:|--------------:|-----------:|------:|
{layer_rows}

## Por dominio
| Dominio | Consulta | Actualización | Sin acceso | Total |
|---------|---------:|--------------:|-----------:|------:|
{dom_rows}

## Transacciones ONLINE (la capa de cara al usuario)
De **{onl_tot}** transacciones ONLINE: **{onl['read']}** son de consulta y
**{onl['update']}** de actualización. Esa separación es la base del análisis CQRS.

## Implicación de migración
| Tipo | Riesgo | Estrategia destino | Cuándo migrar |
|------|--------|--------------------|---------------|
| **Consulta** | Bajo | CQRS read-model · réplica de lectura · caché · API facade de solo lectura | Temprano (waves iniciales) — bajo riesgo, valor rápido |
| **Actualización** | Alto | Núcleo transaccional ACID · saga/outbox · doble escritura controlada | Tardío — requiere shadow period y validación regulatoria |

`[BENCHMARK]` Recuperar esta clasificación = recall sobre los {acc_overall['update']}
programas de actualización (no perder ninguno: un escritor mal clasificado como
consulta corrompe datos). El falso-positivo barato es marcar consulta como
actualización; el caro y peligroso es lo contrario.

`[OBSERVACIÓN]` En un sistema real el escritor no es un solo wrapper: hay WRITE a
archivos secuenciales, puts a MQ, llamadas a otros sistemas de registro. El
análisis debe rastrear **todos** los sumideros de escritura, no uno.
""")

# --- ground-truth-cycles.md ---
def fmt_scc(c):
    return " → ".join(c + [c[0]])
planted_str = "\n".join(f"- Ciclo plantado {i+1} ({len(c)}): {fmt_scc(c)}"
                        for i, c in enumerate(planted_cycles))
detected_str = "\n".join(
    f"- SCC {i+1} (tamaño {len(c)}): {', '.join(sorted(c))}"
    for i, c in enumerate(sorted(nontrivial_sccs, key=len, reverse=True)))
w_md("ground-truth-cycles.md", f"""# Ground Truth — Ciclos / SCCs · SISTEMA-CORE-UNISYS

> Las dependencias circulares rompen el orden topológico: no hay "orden de migración"
> obvio. Detectarlas es crítico para el wave planning.

## Ciclos plantados ({len(planted_cycles)})
{planted_str}

## SCCs no triviales detectados en el grafo final ({len(nontrivial_sccs)})
{detected_str}

`[BENCHMARK]` El nº de SCCs detectados puede exceder los plantados: el preferential
attachment + leakage pueden crear ciclos emergentes. Ambos cuentan como verdad.
""")

# --- ground-truth-communities.md ---
dom_counts = defaultdict(int)
for n in nodes:
    dom_counts[nodes[n]["domain"]] += 1
crows = "\n".join(f"| {d} | {dom_counts[d]} |" for d in
                  sorted(dom_counts, key=lambda x: -dom_counts[x]))
w_md("ground-truth-communities.md", f"""# Ground Truth — Comunidades / Bounded Contexts · SISTEMA-CORE-UNISYS

> Partición real plantada por dominio. Modularidad Q = {Q:.3f}.
> Q < 1 porque los dominios están acoplados por hubs y por {int(CROSS_DOMAIN_LEAKAGE*100)}%
> de fuga BL→BL entre dominios — exactamente por qué encontrar los *seams* del
> Strangler Fig es difícil en un sistema real.

| Dominio (community) | # nodos |
|---------------------|---------|
{crows}

`[BENCHMARK]` Una herramienta de detección de comunidades debería recuperar estos
dominios con alta pureza PERO sufrirá en los nodos de fuga (cross-domain) y en los
que cuelgan de los hubs compartidos. La pureza por dominio es la métrica de scoring.
""")

# --- ground-truth-dead-clusters.md ---
dead_in_unreach = [n for n in unreachable if nodes[n]["domain"] == "obsolete"]
other_unreach = [n for n in unreachable if nodes[n]["domain"] != "obsolete"]
w_md("ground-truth-dead-clusters.md", f"""# Ground Truth — Clusters Muertos / Código Inalcanzable · SISTEMA-CORE-UNISYS

> Subsistemas que ya nadie invoca pero siguen en la librería. En un sistema real
> son clusters enteros, no un programa suelto.

- Total no alcanzable desde entry points (WFL + ONLINE): **{len(unreachable)}**
- Cluster muerto plantado (dominio 'obsolete'): **{len(dead_in_unreach)}** nodos
  (isla ZZDEAD*, con aristas internas pero sin inbound del grafo vivo)
- Otros nodos huérfanos emergentes (sin caller, no plantados): **{len(other_unreach)}**
  → realismo: programas BL que ningún WFL/ONLINE/BL alcanza

`[BENCHMARK]` Distinguir el cluster muerto plantado (ZZDEAD*) de los huérfanos
emergentes es el reto. Ambos son candidatos a Retire, pero los emergentes requieren
validar en logs de producción antes de descartar (shadow execution).
""")

# --- ground-truth-copybook-coupling.md ---
cpy_rows = []
for cpy in sorted(copybook_usage, key=lambda c: -len(set(copybook_usage[c]))):
    progs = sorted(set(copybook_usage[cpy]))
    doms = sorted({nodes[p]["domain"] for p in progs})
    desc = copybook_desc.get(cpy, "")
    cpy_rows.append(f"| `{cpy}` | {desc} | {len(progs)} | {len(doms)} | {', '.join(doms)} |")
cpy_table = "\n".join(cpy_rows)
top_shared = max(copybook_usage, key=lambda c: len(set(copybook_usage[c])))
w_md("ground-truth-copybook-coupling.md", f"""# Ground Truth — Acoplamiento por Copybook · SISTEMA-CORE-UNISYS

> EL HAIRBALL OCULTO. Este acoplamiento NO está en el call graph: dos programas que
> nunca se llaman pero comparten un copybook están acoplados por datos. Cambiar la
> estructura compartida los impacta a todos a la vez.
> Nombres con convención de librería realista (`CB-*` = compartidos de Core Banking;
> `{{DOMINIO}}-*` = propios del dominio) y significado explícito.

| Copybook | Significado | # programas | # dominios | Dominios |
|----------|-------------|------------:|-----------:|----------|
{cpy_table}

**Copybook de mayor acoplamiento:** `{top_shared}` — {copybook_desc.get(top_shared, "")}
({len(set(copybook_usage[top_shared]))} programas).

`[BENCHMARK]` El revelador más duro del seed. Una herramienta que sólo analiza el
call graph reportará comunidades limpias y NO verá este acoplamiento transversal.
La verdad: `{top_shared}` y los compartidos (`CB-CUENTA`/`CB-ASIENTO`) crean cliques de
acoplamiento que atraviesan dominios → el GL queda acoplado a depósitos/créditos/pagos
aunque no haya CALL entre ellos. Este es el motivo nº1 por el que el Strangler Fig
falla si sólo se mira el call graph.
""")

# --- planted-defects.md (resumen) ---
w_md("planted-defects.md", f"""# Planted Defects · SISTEMA-CORE-UNISYS (escala / topología)

> A esta escala los "defectos" son propiedades de topología, no líneas de código.
> Todos computados del grafo (seed {SEED}).

| # | Tipo | Cantidad | Dónde verlo |
|---|------|----------|-------------|
| T1 | Hubs scale-free (fan-in alto) | top 20 | ground-truth-hubs.md |
| T2 | Ciclos / SCCs no triviales | {len(nontrivial_sccs)} | ground-truth-cycles.md |
| T3 | Cluster muerto plantado (isla) | {len(dead_in_unreach)} nodos | ground-truth-dead-clusters.md |
| T4 | Huérfanos emergentes (sin caller) | {len(other_unreach)} | ground-truth-dead-clusters.md |
| T5 | Fuga entre dominios (BL→BL cross) | ~{int(CROSS_DOMAIN_LEAKAGE*100)}% de BL→BL | ground-truth-communities.md |
| T6 | Acoplamiento por copybook (oculto) | {len(copybook_usage)} copybooks | ground-truth-copybook-coupling.md |
| T7 | Componentes desconectadas (WCC) | {len(wccs)} | ground-truth-graph-metrics.md |

## Cómo puntuar
Entregar `graph/dependency-graph.json` (sin `copybook-usage.json` ni answer-key) a la
herramienta o al RE specialist y medir:
- **Hubs:** recall del top-20 por fan-in.
- **Ciclos:** SCCs recuperados / {len(nontrivial_sccs)}.
- **Comunidades:** pureza vs. partición por dominio (Q ground-truth = {Q:.3f}).
- **Dead code:** recall del cluster ZZDEAD* + huérfanos.
- **Acoplamiento por copybook:** ¿la herramienta lo ve sin el call graph? (revelador).
""")

print(f"OK · nodos={N} aristas={E} hubs_top={hubs[0]}({max_indeg}) "
      f"SCCs={len(nontrivial_sccs)} WCC={len(wccs)} "
      f"unreach={len(unreachable)} Q={Q:.3f} copybooks={len(copybook_usage)}")