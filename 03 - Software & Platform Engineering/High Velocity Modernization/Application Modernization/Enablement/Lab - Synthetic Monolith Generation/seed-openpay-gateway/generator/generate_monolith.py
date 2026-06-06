#!/usr/bin/env python3
"""
Generador procedural del seed openpay-gateway.

Produce un grafo de dependencias REALISTA de un monolito Java de pagos
(Java 8 / Spring MVC / Tomcat / MySQL): distribucion scale-free (pocos hubs de
fan-in alto), capas con fugas, ciclos (SCCs entre @Service), acoplamiento por
DTO compartido como capa separada y un cluster muerto.

A esta escala NO se emiten ~660 clases a mano: se emite el grafo como dato
(graph/*.json) y el answer key se COMPUTA del grafo generado -> coherencia
garantizada (el grafo es la fuente de verdad). El source representativo
(hubs + bounded contexts 'security/tokenization' + 'infra/config') se escribe
aparte, a mano; ademas se emite un esqueleto .java navegable por nodo.

Los 9 enablers in-scope se plantan como hubs NOMBRADOS con fan-in objetivo igual
al regression_scope del fanout-graph.json del Reference Case -> cose la narrativa
Fase 0 (descubre el tangle e identifica los 9 hubs) -> Fase 1 (los extrae).

Determinista por semilla (output.seed en generation-spec.yaml).
"""
import json
import random
import os
import sys
from collections import defaultdict, Counter

# ============================================================
#  PARAMETROS (espejo de generation-spec.yaml)
# ============================================================
SEED = 920
N_WEB = 120          # controllers Spring MVC
N_JOB = 119          # scheduled/batch jobs (los 119 del Manager)
N_SERVICE = 300      # @Service procedurales (los 9 enablers se suman aparte)
N_REPO = 90          # @Repository / DAO
N_UTIL = 12          # helpers estaticos (hubs) — incluye 2 sinks de datos
N_DEAD = 22          # cluster muerto legacy.oldreports.*
PREF_EXP = 1.4
CROSS_DOMAIN_LEAKAGE = 0.18
N_CYCLES = 6
CYCLE_SIZE = (3, 7)

DOMAINS = ["payments", "merchants", "finance", "risk-fraud", "terminals",
           "compliance", "security", "infra", "channels"]
ABBR = {"payments": "Pay", "merchants": "Mer", "finance": "Fin",
        "risk-fraud": "Rsk", "terminals": "Trm", "compliance": "Cmp",
        "security": "Sec", "infra": "Inf", "channels": "Chn"}

# dominio -> WAR/component primario del monolito
COMP_BY_DOMAIN = {"payments": "API", "merchants": "Dashboard", "finance": "Manager",
                  "risk-fraud": "API", "terminals": "Dashboard", "compliance": "Manager",
                  "security": "API", "infra": "Manager", "channels": "Dashboard"}

# Utilerias estaticas (los hubs). Los 2 ultimos son los SINKS de datos
# (el "sistema de registro"): escritura y lectura. Se excluyen del pool generico
# para que una llamada generica a utileria no cree por accidente un camino de escritura.
UTIL_NAMES = ["MoneyUtils", "JsonUtils", "DateUtils", "ValidationUtils",
              "AuditLogger", "RetCodeMapper", "HttpClientWrapper", "CryptoUtils",
              "StringUtils", "ConfigCache", "JdbcWriteGateway", "JdbcReadGateway"]
DB_WRITE = "JdbcWriteGateway"
DB_READ = "JdbcReadGateway"

# Los 9 enablers in-scope: (id, dominio, component, blast_radius objetivo, wave, pci, intent)
ENABLERS = [
    ("RbacService",         "security", "Dashboard", 74, 4, False, "read"),
    ("ConfigService",       "infra",    "Manager",   68, 4, False, "read"),
    ("NotificationService", "infra",    "API",       67, 3, False, "update"),
    ("UserService",         "security", "Dashboard", 48, 3, False, "update"),
    ("VaultService",        "security", "Vault",     38, 3, True,  "read"),
    ("TokenizationService", "security", "API",       31, 3, True,  "update"),
    ("DocumentService",     "infra",    "Dashboard", 28, 2, False, "update"),
    ("BinManagerService",   "infra",    "API",       24, 1, False, "read"),
    ("ApiKeyService",       "security", "API",       22, 1, False, "read"),
]
ENABLER_IDS = {e[0] for e in ENABLERS}

# DTOs compartidos (capa de acoplamiento separada del call graph = hairball oculto).
# nombre -> (dominios, fraccion de uso, descripcion)
SHARED_DTO = {
    "ResponseEnvelope": (DOMAINS, 0.90,
        "Standard API response wrapper (status, payload, errors) — used by every controller and service"),
    "TransactionDTO": (["payments", "finance", "risk-fraud", "merchants", "terminals"], 0.78,
        "GOD DTO carrying full transaction state; mutated across layers — the central coupling object"),
    "MoneyAmount": (["payments", "finance", "merchants", "compliance"], 0.80,
        "Monetary value object (amount, currency, scale) — shared everywhere money flows"),
    "MerchantDTO": (["merchants", "payments", "finance", "risk-fraud"], 0.68,
        "Merchant master snapshot passed between domains"),
    "AccountingEntry": (["finance", "payments", "compliance"], 0.55,
        "Double-entry accounting posting structure — couples finance to payments/compliance"),
    "AuditContext": (DOMAINS, 0.60,
        "Cross-cutting audit/correlation context threaded through call chains"),
}
# DTOs por dominio (3 roles c/u), nombre y significado explicitos
DOM_DTO_ROLES = [
    ("Request",  "Inbound request payload of the"),
    ("Response", "Outbound response payload of the"),
    ("Entity",   "JPA persistence entity of the"),
]
DOMAIN_LABEL = {d: f"{d} domain" for d in DOMAINS}
dto_desc = {}  # nombre -> descripcion (glosario explicito)

rnd = random.Random(SEED)

# ============================================================
#  1. NODOS
# ============================================================
nodes = {}   # id -> dict(layer, domain, component, loc, intent)
by_layer = defaultdict(list)
by_domain_layer = defaultdict(list)


def add_node(nid, layer, domain, component, loc):
    nodes[nid] = {"id": nid, "layer": layer, "domain": domain,
                  "component": component, "loc": loc}
    by_layer[layer].append(nid)
    by_domain_layer[(domain, layer)].append(nid)


# utilerias (dominio 'shared')
for name in UTIL_NAMES[:N_UTIL]:
    add_node(name, "UTIL", "shared", "shared", rnd.randint(40, 260))

# enablers nombrados (SERVICE) — se plantan antes que el resto
for eid, dom, comp, _br, _w, _pci, _intent in ENABLERS:
    add_node(eid, "SERVICE", dom, comp, rnd.randint(300, 900))


def make(prefix, layer, count, loc_range, comp_override=None, dom_pool=None):
    seq = 0
    for _ in range(count):
        dom = rnd.choice(dom_pool or DOMAINS)
        seq += 1
        nid = f"{ABBR[dom]}{prefix}{seq:03d}"
        comp = comp_override or COMP_BY_DOMAIN[dom]
        add_node(nid, layer, dom, comp, rnd.randint(*loc_range))


# jobs: pesados hacia finance/compliance/infra/payments; SIEMPRE en el Manager (los 119)
JOB_DOMS = ["finance", "compliance", "infra", "payments", "payments",
            "finance", "merchants", "risk-fraud"]
make("Controller", "WEB", N_WEB, (60, 280))
make("Job", "JOB", N_JOB, (80, 360), comp_override="Manager", dom_pool=JOB_DOMS)
make("Service", "SERVICE", N_SERVICE, (120, 800))
make("Repository", "REPO", N_REPO, (50, 240))

# cluster muerto: isla huerfana (no alcanzable) en el Manager
dead_ids = []
for i in range(N_DEAD):
    nid = f"LegacyReport{i:03d}"
    add_node(nid, "SERVICE", "obsolete", "Manager", rnd.randint(120, 500))
    dead_ids.append(nid)

# ---- intent de acceso a datos por nodo (dirige el ruteo a los sinks) ----
# read-only = solo consulta; update = escribe en el sistema de registro.
INTENT_P = {"REPO": 0.45, "SERVICE": 0.40, "WEB": 0.55, "JOB": 0.30}  # prob. read-only
enabler_intent = {e[0]: e[6] for e in ENABLERS}
for _id, _nd in nodes.items():
    if _nd["layer"] == "UTIL" or _nd["domain"] == "obsolete":
        _nd["intent"] = "none"
    elif _id in enabler_intent:
        _nd["intent"] = enabler_intent[_id]
    else:
        _nd["intent"] = "read" if rnd.random() < INTENT_P.get(_nd["layer"], 0.4) else "update"
nodes[DB_WRITE]["intent"] = "update"
nodes[DB_READ]["intent"] = "read"

# ============================================================
#  2. ARISTAS
# ============================================================
edges = []
indeg = defaultdict(int)


def add_edge(s, d, t):
    if s == d:
        return
    edges.append((s, d, t))
    indeg[d] += 1


# utilerias entre si (cadena minima)
add_edge("AuditLogger", "JsonUtils", "calls")
add_edge("HttpClientWrapper", "JsonUtils", "calls")
add_edge("ValidationUtils", "StringUtils", "calls")
add_edge("CryptoUtils", "StringUtils", "calls")

util_ids = by_layer["UTIL"]
gen_util = [u for u in util_ids if u not in (DB_WRITE, DB_READ)]


def pick_util():
    weights = [(indeg[u] + 1) ** PREF_EXP for u in gen_util]
    return rnd.choices(gen_util, weights=weights, k=1)[0]


service_ids = [s for s in by_layer["SERVICE"] if s not in ENABLER_IDS and nodes[s]["domain"] != "obsolete"]
repo_ids = by_layer["REPO"]
web_ids = by_layer["WEB"]
job_ids = by_layer["JOB"]


def pool(layer, intent, dom=None):
    """Nodos de una capa con cierto intent (opcionalmente de un dominio)."""
    base = [n for n in by_layer[layer]
            if n not in ENABLER_IDS and nodes[n]["domain"] != "obsolete"]
    if dom is not None:
        r = [n for n in base if nodes[n]["domain"] == dom and nodes[n]["intent"] == intent]
        if r:
            return r
    r = [n for n in base if nodes[n]["intent"] == intent]
    return r or base


# ---- 3. JOB -> SERVICE (mismo intent que el job) ----
# El inbound a los 9 enablers se reserva al top-up (paso 8), que lo lleva al
# blast_radius objetivo exacto. Aqui solo se cablea el grafo organico no-enabler.
for w in job_ids:
    dom, it = nodes[w]["domain"], nodes[w]["intent"]
    cands = pool("SERVICE", it, dom)
    for t in rnd.sample(cands, min(len(cands), rnd.randint(2, 6))):
        add_edge(w, t, "invokes")

# ---- 4. WEB(controller) -> SERVICE (la fuga cruza dominio, no intent) ----
for o in web_ids:
    dom, it = nodes[o]["domain"], nodes[o]["intent"]
    for _ in range(rnd.randint(1, 3)):
        if rnd.random() < CROSS_DOMAIN_LEAKAGE:
            add_edge(o, rnd.choice(pool("SERVICE", it)), "calls")
        else:
            add_edge(o, rnd.choice(pool("SERVICE", it, dom)), "calls")


# ---- 5. SERVICE -> SERVICE / REPO / sink / UTIL / ENABLER (segun intent) ----
def pick_service_pref(dom, it):
    p = pool("SERVICE", it, dom)
    weights = [(indeg[b] + 1) ** PREF_EXP for b in p]
    return rnd.choices(p, weights=weights, k=1)[0]


for b in service_ids:
    dom, it = nodes[b]["domain"], nodes[b]["intent"]
    # SERVICE -> SERVICE: 'read' solo llama a 'read'; 'update' puede llamar a cualquiera
    for _ in range(rnd.randint(0, 3)):
        tgt_it = rnd.choice(["read", "update"]) if (it == "update" and rnd.random() < 0.5) else it
        if rnd.random() < CROSS_DOMAIN_LEAKAGE:
            add_edge(b, rnd.choice(pool("SERVICE", tgt_it)), "calls")
        else:
            add_edge(b, pick_service_pref(dom, tgt_it), "calls")
    for _ in range(rnd.randint(1, 2)):                       # SERVICE -> REPO (intent-matched)
        add_edge(b, rnd.choice(pool("REPO", it, dom)), "calls")
    # SERVICE -> sink de datos directo: fija el acceso y da fan-in a los sinks
    add_edge(b, DB_WRITE if it == "update" else DB_READ, "calls")
    for _ in range(rnd.randint(1, 4)):                       # SERVICE -> UTIL generica (hubs)
        add_edge(b, pick_util(), "calls")

# ---- 6. REPO -> sink (segun intent) + utilerias ----
for d in repo_ids:
    add_edge(d, DB_WRITE if nodes[d]["intent"] == "update" else DB_READ, "calls")
    for _ in range(rnd.randint(0, 2)):
        add_edge(d, pick_util(), "calls")

# ---- 7. Enablers: fan-out propio (llaman repos/utils/sinks) ----
for eid, dom, comp, _br, _w, _pci, it in ENABLERS:
    add_edge(eid, DB_WRITE if it == "update" else DB_READ, "calls")
    for _ in range(rnd.randint(1, 3)):
        add_edge(eid, rnd.choice(pool("REPO", it, dom) or repo_ids), "calls")
    add_edge(eid, pick_util(), "calls")
# dependencias entre enablers (coherentes con el fanout: rbac->user, tokenization->vault)
add_edge("UserService", "RbacService", "calls")
add_edge("TokenizationService", "VaultService", "calls")
add_edge("ApiKeyService", "ConfigService", "calls")

# ---- 8. Top-up: llevar cada enabler a su blast_radius objetivo (fan-in plantado) ----
all_callers = service_ids + web_ids + job_ids
for eid, dom, comp, target_br, _w, _pci, it in ENABLERS:
    # callers compatibles: si el enabler es 'read', cualquiera puede consultarlo;
    # si es 'update', preferimos callers 'update' (un read no debe alcanzar un writer)
    if it == "read":
        cand = [c for c in all_callers if c != eid]
    else:
        cand = [c for c in all_callers if c != eid and nodes[c]["intent"] == "update"]
    rnd.shuffle(cand)
    existing = {s for (s, d, _t) in edges if d == eid}
    for c in cand:
        if indeg[eid] >= target_br:
            break
        if c in existing:
            continue
        add_edge(c, eid, "calls")
        existing.add(c)

# ---- 9. Ciclos: solo entre SERVICE de actualizacion (no contamina las de consulta) ----
planted_cycles = []
used = set()
upd_serv = [b for b in service_ids if nodes[b]["intent"] == "update"]
for _ in range(N_CYCLES):
    size = rnd.randint(*CYCLE_SIZE)
    avail = [b for b in upd_serv if b not in used]
    if len(avail) < size:
        break
    ring = rnd.sample(avail, size)
    used.update(ring)
    for i in range(size):
        add_edge(ring[i], ring[(i + 1) % size], "calls")
    planted_cycles.append(ring)

# ---- 10. Cluster muerto: aristas internas, sin inbound del grafo vivo ----
for s in dead_ids:
    for _ in range(rnd.randint(1, 3)):
        add_edge(s, rnd.choice(dead_ids), "calls")

# ============================================================
#  11. DTOs (capa de acoplamiento separada del call graph)
# ============================================================
dto_usage = defaultdict(list)
for dto, (doms, frac, desc) in SHARED_DTO.items():
    dto_desc[dto] = desc
    for nid, nd in nodes.items():
        if nd["layer"] == "UTIL" or nd["domain"] == "obsolete":
            continue
        if nd["domain"] in doms and rnd.random() < frac:
            dto_usage[dto].append(nid)

# DTOs por dominio (3 roles c/u), nombre y significado explicitos
for dom in DOMAINS:
    progs = [n for n, nd in nodes.items() if nd["domain"] == dom]
    for role, role_desc in DOM_DTO_ROLES:
        dto = f"{ABBR[dom]}{role}"
        dto_desc[dto] = f"{role_desc} {DOMAIN_LABEL[dom]}"
        for nid in progs:
            if rnd.random() < 0.5:
                dto_usage[dto].append(nid)

# ============================================================
#  12. ANALISIS — el answer key se COMPUTA del grafo generado
# ============================================================
adj = defaultdict(list)
radj = defaultdict(list)
for s, d, t in edges:
    adj[s].append(d)
    radj[d].append(s)

N = len(nodes)
E = len(edges)

# --- Clasificacion de acceso: consulta vs actualizacion (cierre de llamadas) ---
def reach_to(target):
    seen2 = {target}
    st2 = [target]
    while st2:
        v = st2.pop()
        for u in radj[v]:
            if u not in seen2:
                seen2.add(u)
                st2.append(u)
    return seen2


writers = reach_to(DB_WRITE)
readers = reach_to(DB_READ)
for nid in nodes:
    if nid in writers:
        nodes[nid]["access"] = "update"
    elif nid in readers:
        nodes[nid]["access"] = "read"
    else:
        nodes[nid]["access"] = "none"

# --- Hubs por in-degree ---
hubs = sorted(nodes.keys(), key=lambda n: indeg[n], reverse=True)[:20]

# --- Tarjan SCC (iterativo para evitar limites de recursion) ---
index_counter = [0]
index = {}
lowlink = {}
on_stack = set()
stack = []
sccs = []


def tarjan(start):
    work = [(start, 0)]
    while work:
        v, pi = work[-1]
        if pi == 0:
            index[v] = index_counter[0]
            lowlink[v] = index_counter[0]
            index_counter[0] += 1
            stack.append(v)
            on_stack.add(v)
        recurse = False
        succs = adj[v]
        i = pi
        while i < len(succs):
            w = succs[i]
            if w not in index:
                work[-1] = (v, i + 1)
                work.append((w, 0))
                recurse = True
                break
            elif w in on_stack:
                lowlink[v] = min(lowlink[v], index[w])
            i += 1
        if recurse:
            continue
        if lowlink[v] == index[v]:
            comp = []
            while True:
                w = stack.pop()
                on_stack.discard(w)
                comp.append(w)
                if w == v:
                    break
            sccs.append(comp)
        work.pop()
        if work:
            pv = work[-1][0]
            lowlink[pv] = min(lowlink[pv], lowlink[v])


for v in list(nodes.keys()):
    if v not in index:
        tarjan(v)

nontrivial_sccs = [c for c in sccs if len(c) > 1]

# --- Reachability desde entry points (WEB + JOB) ---
roots = web_ids + job_ids
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
    uadj[s].add(d)
    uadj[d].add(s)
wcc_seen, wccs = set(), []
for start in nodes:
    if start in wcc_seen:
        continue
    comp, st = [], [start]
    while st:
        v = st.pop()
        if v in wcc_seen:
            continue
        wcc_seen.add(v)
        comp.append(v)
        st.extend(uadj[v] - wcc_seen)
    wccs.append(comp)

# --- Modularidad de la particion por dominio ---
m = E
deg = defaultdict(int)
for s, d, _ in edges:
    deg[s] += 1
    deg[d] += 1
intra = sum(1 for s, d, _ in edges if nodes[s]["domain"] == nodes[d]["domain"])
dom_deg = defaultdict(int)
for n in nodes:
    dom_deg[nodes[n]["domain"]] += deg[n]
sum_a2 = sum((dd / (2 * m)) ** 2 for dd in dom_deg.values())
Q = intra / m - sum_a2

density = E / (N * (N - 1))
avg_out = E / N
max_indeg = indeg[hubs[0]]

# ============================================================
#  13. ESCRITURA DE ARTEFACTOS
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
        "system": "openpay-gateway",
        "seed": SEED,
        "nodes": list(nodes.values()),
        "edges": [{"from": s, "to": d, "type": t} for s, d, t in edges],
    }, f, indent=1)

# --- graph/dto-coupling.json ---
with open(os.path.join(GRAPH, "dto-coupling.json"), "w", encoding="utf-8") as f:
    json.dump({dto: sorted(set(progs)) for dto, progs in dto_usage.items()}, f, indent=1)

# --- graph/dto-glossary.json ---
with open(os.path.join(GRAPH, "dto-glossary.json"), "w", encoding="utf-8") as f:
    json.dump(dto_desc, f, indent=1, ensure_ascii=False)

# --- source/skeleton/{ID}.java : esqueleto navegable por nodo + source-map.json ---
SKEL = os.path.join(ROOT, "source", "skeleton")
os.makedirs(SKEL, exist_ok=True)
node_dtos = defaultdict(list)
for _dto, _progs in dto_usage.items():
    for _p in set(_progs):
        node_dtos[_p].append(_dto)
ACC_LBL = {"read": "inquiry (read-only)", "update": "update (writes)", "none": "no data access"}
ANNOT = {"WEB": "@RestController", "JOB": "@Scheduled", "SERVICE": "@Service",
         "REPO": "@Repository", "UTIL": "(static helper)"}


def emit_java(cid, nd, outs):
    dtos = sorted(set(node_dtos.get(cid, [])) | {"ResponseEnvelope"})
    imports = "\n".join(f"import com.openpay.dto.{d};" for d in dtos)
    fields = "\n".join(
        f"    private final {o} {o[0].lower() + o[1:]};" for o in outs[:12]) or "    // (no collaborators)"
    if nd["access"] == "update":
        dataccess = "        jdbcWriteGateway.persist(ctx);   // writes to the system of record"
    elif nd["access"] == "read":
        dataccess = "        return jdbcReadGateway.query(ctx);   // inquiry only"
    else:
        dataccess = "        // (does not touch the database)"
    annot = ANNOT.get(nd["layer"], "")
    return f"""package com.openpay.{nd['component'].lower()}.{nd['domain'].replace('-', '')};

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : {nd['component']} (WAR)      DOMAIN : {nd['domain']}
//  LAYER     : {nd['layer']:<8}             ACCESS : {ACC_LBL.get(nd['access'], nd['access'])}
//  FAN-IN    : {indeg[cid]}    FAN-OUT : {len(outs)}    LOC approx: {nd['loc']}
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
{imports}

{annot}
public class {cid} {{

    // Collaborators (match the graph call edges):
{fields}

    public ResponseEnvelope handle(AuditContext ctx) {{
{dataccess}
    }}
}}
"""


source_map = {}
for cid, nd in nodes.items():
    outs = sorted(set(adj[cid]))
    open(os.path.join(SKEL, f"{cid}.java"), "w", encoding="utf-8").write(emit_java(cid, nd, outs))
    source_map[cid] = f"source/skeleton/{cid}.java"
with open(os.path.join(GRAPH, "source-map.json"), "w", encoding="utf-8") as f:
    json.dump(source_map, f, indent=1)


def w_md(name, text):
    with open(os.path.join(AK, name), "w", encoding="utf-8") as f:
        f.write(text)


# --- ground-truth-graph-metrics.md ---
w_md("ground-truth-graph-metrics.md", f"""# Ground Truth — Metricas de Grafo · openpay-gateway

> Computado del grafo generado (seed {SEED}). El grafo es la fuente de verdad.

| Metrica | Valor |
|---------|-------|
| Nodos (clases) | {N} |
| Aristas (dependencias de llamada) | {E} |
| Densidad | {density:.5f} |
| Grado de salida promedio | {avg_out:.2f} |
| Fan-in maximo (top hub: {hubs[0]}) | {max_indeg} |
| SCCs no triviales (ciclos) | {len(nontrivial_sccs)} |
| Componentes debilmente conexas (WCC) | {len(wccs)} |
| Nodos no alcanzables desde entry points | {len(unreachable)} |
| Modularidad Q (particion por dominio) | {Q:.3f} |

**Lectura:** densidad baja pero fan-in altisimo concentrado en pocos hubs = firma
scale-free. Q ~ 0.3-0.5 indica comunidades reales pero con fuga (no es 1.0 porque
los dominios se acoplan via hubs y leakage). {len(wccs)} WCC => hay al menos una
isla desconectada (cluster muerto legacy.oldreports).
""")

# --- ground-truth-hubs.md ---
rows = "\n".join(
    f"| {i + 1} | {h} | {nodes[h]['layer']} | {nodes[h]['domain']} | {nodes[h]['component']} | {indeg[h]} |"
    for i, h in enumerate(hubs))
w_md("ground-truth-hubs.md", f"""# Ground Truth — Hubs (fan-in alto) · openpay-gateway

> Los hubs son el corazon del hairball: utilerias estaticas y los 9 enablers,
> llamados por decenas/cientos de clases. El discovery debe identificarlos como
> nodos de maximo riesgo de migracion (tocarlos impacta a todo el sistema).

| # | Clase | Capa | Dominio | Component | Fan-in |
|---|-------|------|---------|-----------|--------|
{rows}

`[BENCHMARK]` Los hubs UTIL (MoneyUtils, JsonUtils, AuditLogger, los sinks JDBC) y
los 9 SERVICE enabler deben aparecer en el top. Quien no los detecte subestimara
el blast radius de cualquier cambio.
""")

# --- ground-truth-enabler-seams.md (exclusivo: cose Fase 0 -> Fase 1) ---
en_rows = "\n".join(
    f"| {eid} | {dom} | {comp} | {indeg[eid]} | {target_br} | {w} | {'PCI' if pci else '—'} | {nodes[eid]['access']} |"
    for eid, dom, comp, target_br, w, pci, _it in ENABLERS)
w_md("ground-truth-enabler-seams.md", f"""# Ground Truth — Seams de los 9 Enablers in-scope · openpay-gateway

> Estos 9 `@Service` son los **seams** que la Fase 1 (Enabler Extraction) extrae
> en waves. Se plantaron como hubs nombrados con fan-in objetivo igual al
> `regression_scope` del `fanout-graph.json` del Reference Case. Asi la narrativa
> se cose de punta a punta:
>
>   **Fase 0 (este monolito)** descubre el tangle e identifica estos hubs →
>   **Fase 1 (fanout-graph)** los extrae como enablers en waves 1-4.

| Enabler (clase) | Dominio | Component | Fan-in real | Blast radius objetivo | Wave | PCI | Acceso |
|-----------------|---------|-----------|------------:|----------------------:|:----:|:---:|:------:|
{en_rows}

`[COHERENCIA]` El fan-in real es aproximado al objetivo (el top-up procedural lo
ajusta sin romper el cierre de acceso). Las dependencias entre enablers
(UserService->RbacService, TokenizationService->VaultService, ApiKeyService->ConfigService)
reflejan las del fanout. RBAC (read, fan-in mas alto) es el SPOF de seguridad;
ConfigService (read) es el de parametrizacion. Ambos = wave 4 (mayor blast radius).

`[BENCHMARK]` Recuperar estos 9 seams del grafo crudo (sin este answer key) y
ordenarlos por blast radius = el ejercicio central del discovery de Fase 0.
""")

# --- ground-truth-access-classification.md ---
acc_overall = Counter(nd["access"] for nd in nodes.values())
acc_by_layer = defaultdict(Counter)
acc_by_dom = defaultdict(Counter)
for nd in nodes.values():
    acc_by_layer[nd["layer"]][nd["access"]] += 1
    acc_by_dom[nd["domain"]][nd["access"]] += 1


def acc_row(label, c):
    tot = c["read"] + c["update"] + c["none"]
    return f"| {label} | {c['read']} | {c['update']} | {c['none']} | {tot} |"


layer_rows = "\n".join(acc_row(L, acc_by_layer[L]) for L in ["JOB", "WEB", "SERVICE", "REPO", "UTIL"])
dom_rows = "\n".join(acc_row(d, acc_by_dom[d]) for d in sorted(acc_by_dom) if d not in ("shared", "obsolete"))
web = acc_by_layer["WEB"]
web_tot = web["read"] + web["update"] + web["none"]
w_md("ground-truth-access-classification.md", f"""# Ground Truth — Consulta vs Actualizacion (CQRS) · openpay-gateway

> Como se sabe que endpoints son de **solo consulta** y cuales de **actualizacion**?
> Por analisis estatico del cierre de llamadas: una clase es de **actualizacion** si
> su cierre alcanza una escritura al sistema de registro (`{DB_WRITE}` /
> `repository.save()`); de **consulta** si alcanza lectura (`{DB_READ}`) pero **nunca**
> una escritura; `none` si no toca datos.

## Resumen del sistema
| Tipo | Clases |
|------|--------|
| Consulta (read-only) | {acc_overall['read']} |
| Actualizacion (transaccional) | {acc_overall['update']} |
| Sin acceso a datos (compute/util) | {acc_overall['none']} |

## Por capa
| Capa | Consulta | Actualizacion | Sin acceso | Total |
|------|---------:|--------------:|-----------:|------:|
{layer_rows}

## Por dominio
| Dominio | Consulta | Actualizacion | Sin acceso | Total |
|---------|---------:|--------------:|-----------:|------:|
{dom_rows}

## Endpoints WEB (la capa de cara al usuario)
De **{web_tot}** controllers: **{web['read']}** son de consulta y **{web['update']}**
de actualizacion. Esa separacion es la base del analisis CQRS.

## Implicacion de migracion
| Tipo | Riesgo | Estrategia destino | Cuando migrar |
|------|--------|--------------------|---------------|
| **Consulta** | Bajo | CQRS read-model · replica de lectura · cache · API facade read-only | Temprano (waves iniciales) — bajo riesgo, valor rapido |
| **Actualizacion** | Alto | Nucleo transaccional ACID · saga/outbox · doble escritura controlada | Tardio — requiere shadow period y validacion regulatoria |

`[BENCHMARK]` Recuperar esta clasificacion = recall sobre las {acc_overall['update']}
clases de actualizacion (no perder ninguna: un escritor mal clasificado como
consulta corrompe datos). El falso-positivo barato es marcar consulta como
actualizacion; el caro y peligroso es lo contrario.
""")

# --- ground-truth-cycles.md ---
def fmt_scc(c):
    return " -> ".join(c + [c[0]])


planted_str = "\n".join(f"- Ciclo plantado {i + 1} ({len(c)}): {fmt_scc(c)}"
                        for i, c in enumerate(planted_cycles)) or "- (ninguno)"
detected_str = "\n".join(
    f"- SCC {i + 1} (tamano {len(c)}): {', '.join(sorted(c))}"
    for i, c in enumerate(sorted(nontrivial_sccs, key=len, reverse=True))) or "- (ninguno)"
w_md("ground-truth-cycles.md", f"""# Ground Truth — Ciclos / SCCs · openpay-gateway

> Las dependencias circulares entre `@Service` rompen el orden topologico: no hay
> "orden de migracion" obvio. En Spring suelen aparecer como circular bean
> dependencies parcheadas con `@Lazy` o setter injection. Detectarlas es critico
> para el wave planning.

## Ciclos plantados ({len(planted_cycles)})
{planted_str}

## SCCs no triviales detectados en el grafo final ({len(nontrivial_sccs)})
{detected_str}

`[BENCHMARK]` El nro de SCCs detectados puede exceder los plantados: el preferential
attachment + leakage pueden crear ciclos emergentes. Ambos cuentan como verdad.
""")

# --- ground-truth-communities.md ---
dom_counts = defaultdict(int)
for n in nodes:
    dom_counts[nodes[n]["domain"]] += 1
crows = "\n".join(f"| {d} | {dom_counts[d]} |" for d in sorted(dom_counts, key=lambda x: -dom_counts[x]))
w_md("ground-truth-communities.md", f"""# Ground Truth — Comunidades / Bounded Contexts · openpay-gateway

> Particion real plantada por dominio. Modularidad Q = {Q:.3f}.
> Q < 1 porque los dominios estan acoplados por hubs y por {int(CROSS_DOMAIN_LEAKAGE * 100)}%
> de fuga SERVICE->SERVICE entre dominios — exactamente por que encontrar los *seams*
> del Strangler Fig es dificil en un monolito real.

| Dominio (community) | # clases |
|---------------------|----------|
{crows}

`[BENCHMARK]` Una herramienta de deteccion de comunidades deberia recuperar estos
dominios con alta pureza PERO sufrira en los nodos de fuga (cross-domain) y en los
que cuelgan de los hubs compartidos. La pureza por dominio es la metrica de scoring.
""")

# --- ground-truth-dead-clusters.md ---
dead_in_unreach = [n for n in unreachable if nodes[n]["domain"] == "obsolete"]
other_unreach = [n for n in unreachable if nodes[n]["domain"] != "obsolete"]
w_md("ground-truth-dead-clusters.md", f"""# Ground Truth — Clusters Muertos / Codigo Inalcanzable · openpay-gateway

> Subsistemas que ya nadie invoca pero siguen empaquetados en el WAR. En un sistema
> real son clusters enteros (paquetes completos), no una clase suelta.

- Total no alcanzable desde entry points (WEB + JOB): **{len(unreachable)}**
- Cluster muerto plantado (`legacy.oldreports.*`, dominio 'obsolete'): **{len(dead_in_unreach)}** clases
  (isla LegacyReport*, con aristas internas pero sin inbound del grafo vivo)
- Otros nodos huerfanos emergentes (sin caller, no plantados): **{len(other_unreach)}**
  -> realismo: services que ningun controller/job/service alcanza

`[BENCHMARK]` Distinguir el cluster muerto plantado (LegacyReport*) de los huerfanos
emergentes es el reto. Ambos son candidatos a Retire, pero los emergentes requieren
validar en logs de produccion antes de descartar (shadow execution / APM).
""")

# --- ground-truth-dto-coupling.md ---
dto_rows = []
for dto in sorted(dto_usage, key=lambda c: -len(set(dto_usage[c]))):
    progs = sorted(set(dto_usage[dto]))
    doms = sorted({nodes[p]["domain"] for p in progs})
    desc = dto_desc.get(dto, "")
    dto_rows.append(f"| `{dto}` | {desc} | {len(progs)} | {len(doms)} | {', '.join(doms)} |")
dto_table = "\n".join(dto_rows)
top_shared = max(dto_usage, key=lambda c: len(set(dto_usage[c])))
w_md("ground-truth-dto-coupling.md", f"""# Ground Truth — Acoplamiento por DTO compartido · openpay-gateway

> EL HAIRBALL OCULTO. Este acoplamiento NO esta en el call graph: dos clases que
> nunca se llaman pero comparten un DTO mutable (`TransactionDTO`, `MoneyAmount`)
> estan acopladas por datos. Cambiar la estructura compartida las impacta a todas a
> la vez. En Java es el equivalente exacto del copybook compartido del mainframe.

| DTO | Significado | # clases | # dominios | Dominios |
|-----|-------------|---------:|-----------:|----------|
{dto_table}

**DTO de mayor acoplamiento:** `{top_shared}` — {dto_desc.get(top_shared, "")}
({len(set(dto_usage[top_shared]))} clases).

`[BENCHMARK]` El revelador mas duro del seed. Una herramienta que solo analiza el
call graph reportara comunidades limpias y NO vera este acoplamiento transversal.
La verdad: `TransactionDTO` y `AccountingEntry` crean cliques de acoplamiento que
atraviesan dominios -> finanzas queda acoplado a pagos/compliance aunque no haya
llamada directa entre ellos. Este es el motivo nro 1 por el que el Strangler Fig
falla si solo se mira el call graph (y por que database-per-service es tan caro).
""")

# --- planted-defects.md ---
w_md("planted-defects.md", f"""# Planted Defects · openpay-gateway (escala / topologia)

> A esta escala los "defectos" son propiedades de topologia, no lineas de codigo.
> Todos computados del grafo (seed {SEED}).

| # | Tipo | Cantidad | Donde verlo |
|---|------|----------|-------------|
| T1 | Hubs scale-free (god utils + enablers) | top 20 | ground-truth-hubs.md |
| T2 | Ciclos / SCCs no triviales (Spring circular deps) | {len(nontrivial_sccs)} | ground-truth-cycles.md |
| T3 | Cluster muerto plantado (legacy.oldreports) | {len(dead_in_unreach)} clases | ground-truth-dead-clusters.md |
| T4 | Huerfanos emergentes (sin caller) | {len(other_unreach)} | ground-truth-dead-clusters.md |
| T5 | Fuga entre dominios (SERVICE->SERVICE cross) | ~{int(CROSS_DOMAIN_LEAKAGE * 100)}% de SERVICE->SERVICE | ground-truth-communities.md |
| T6 | Acoplamiento por DTO compartido (oculto) | {len(dto_usage)} DTOs | ground-truth-dto-coupling.md |
| T7 | Componentes desconectadas (WCC) | {len(wccs)} | ground-truth-graph-metrics.md |
| T8 | 9 enablers seam (hubs nombrados) | 9 | ground-truth-enabler-seams.md |

## Como puntuar
Entregar `graph/dependency-graph.json` (sin `dto-coupling.json` ni answer-key) a la
herramienta de discovery o al RE specialist y medir:
- **Hubs:** recall del top-20 por fan-in (incluye los 9 enablers).
- **Ciclos:** SCCs recuperados / {len(nontrivial_sccs)}.
- **Comunidades:** pureza vs. particion por dominio (Q ground-truth = {Q:.3f}).
- **Dead code:** recall del cluster LegacyReport* + huerfanos.
- **Acoplamiento por DTO:** la herramienta lo ve sin el call graph? (revelador).
- **Enablers:** recupera los 9 seams y los ordena por blast radius? (cose con Fase 1).
""")

print(f"OK · nodos={N} aristas={E} hubs_top={hubs[0]}({max_indeg}) "
      f"SCCs={len(nontrivial_sccs)} WCC={len(wccs)} "
      f"unreach={len(unreachable)} Q={Q:.3f} DTOs={len(dto_usage)}")
print("Enabler fan-in real vs objetivo:")
for eid, dom, comp, target_br, w, pci, it in ENABLERS:
    print(f"   {eid:<22} {indeg[eid]:>3} / {target_br:<3} (wave {w}, {it})")