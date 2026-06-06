#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generador procedural - seed-sap-banking-ecc-scale-graph
Reference Data Lab (AI-ready Data / Digital Core)

Produce el grafo de dependencias REALISTA de un core bancario sobre SAP ECC a
ESCALA (~1,500 tablas): distribucion scale-free (pocas tablas hub de fan-in
altisimo: company code, moneda, business partner, GL account), comunidades por
modulo (BP / FS-AM Deposits / FS-CML Loans / Payments / FI-GL / CO / Cards /
Channels / Collateral / DMEE) con fuga cross-modulo, ciclos (SCCs), un modulo
muerto (legacy decomisionado) y la capa de ACOPLAMIENTO OCULTO = tablas de
customizing/master compartidas referenciadas por muchos modulos (el analogo del
copybook coupling de Mainframe; el hairball que el plan por-modulo no ve).

A esta escala NO se emiten filas: se emite el grafo como dato (graph/*.json) y el
answer key se COMPUTA del grafo (hubs, Tarjan SCC, WCC, modularidad). Determinista.
Dual del seed-corebank-unisys de Mainframe, en mundo de datos.

Ejecutar: python generate.py
"""
import json
import os
import random
from collections import defaultdict

# ---- Parametros (espejo de generation-spec.yaml) ----
SEED = 5100
# conteos por arquetipo de tabla SAP (suman ~1500 + dead + crm)
N_MASTER = 120     # master data (BUT000, account master, GL account, bank...)
N_TXN = 720        # transaccional / documentos (postings, turnovers, line items)
N_TEXT = 150       # text tables (dependientes de idioma, SPRAS)
N_CUST = 360       # customizing / check tables (T*)
N_TOTALS = 80      # agregados / totales / index
N_DEAD = 70        # modulo legacy decomisionado (isla)
N_CRM = 30         # sistema satelite CRM (no SAP)

PREF_EXP = 1.6                 # exponente de preferential attachment (scale-free)
CROSS_MODULE_LEAKAGE = 0.16    # fraccion de FK que cruzan modulo
N_CYCLES = 5
CYCLE_SIZE = (3, 6)

MODULES = ["bp", "am_deposits", "cml_loans", "payments", "fi_gl",
           "co", "cards", "channels", "collateral", "dmee"]
ABBR = {"bp": "BUT", "am_deposits": "BKK", "cml_loans": "VD", "payments": "FPAY",
        "fi_gl": "BSEG", "co": "COEP", "cards": "CC", "channels": "FEB",
        "collateral": "BCA", "dmee": "DMEE"}
MOD_LABEL = {"bp": "Business Partner", "am_deposits": "Deposits Mgmt (FS-AM)",
             "cml_loans": "Loans Mgmt (FS-CML)", "payments": "Payments",
             "fi_gl": "Financial Accounting / GL", "co": "Controlling",
             "cards": "Cards", "channels": "Bank Statement / Channels",
             "collateral": "Collateral (BCA)", "dmee": "Payment Medium (DMEE)"}
# Prefijo de familia SAP REAL por modulo (para la cola larga de tablas generadas)
PREFIX = {"bp": "BUT", "am_deposits": "BKK", "cml_loans": "VD", "payments": "REGU",
          "fi_gl": "BS", "co": "CO", "cards": "CCARD", "channels": "FEB",
          "collateral": "CMS", "dmee": "DMEE"}
# Tablas SAP REALES prominentes por modulo (se usan primero; el resto = PREFIX+num)
CURATED = {
    "bp": ["BUT020", "BUT021_FS", "BUT050", "BUT051", "BUT052", "BUT100", "BUT0ID",
           "BP001", "BP030", "BPVB", "TB001", "TB003", "TB008S", "TBZ0"],
    "am_deposits": ["BKK40", "BKK41", "BKK42", "BKK43", "BKKIT", "BKKI1", "BKKA", "BKKC",
                    "BKK1", "BKKEXT", "BKKBW", "BCAACCTBAL", "TBKK01", "TBKKA", "BKKLIM"],
    "cml_loans": ["VDARL", "VDBEPP", "VDBEPK", "VTBBEWE", "VTBFHAPO", "BAV", "VDARLZA",
                  "VTVBUFFER", "TVARL", "VDIN", "VDPSO", "VDBUKEXT"],
    "payments": ["REGUH", "REGUP", "REGUHM", "PAYR", "PAYRQ", "FPAYH", "FPAYHX", "FPAYP",
                 "T042", "T042Z", "T042E"],
    "fi_gl": ["BKPF", "BSEG", "BSIS", "BSAS", "BSID", "BSAD", "BSIK", "BSAK", "FAGLFLEXA",
              "FAGLFLEXT", "GLT0", "SKAT", "T003", "T004", "T030"],
    "co": ["COEP", "COBK", "COSP", "COSS", "COKA", "COKS", "CSKA", "CSKB", "CSKS", "CSKT",
           "TKA01", "TKA02", "COSL"],
    "cards": ["CCARDEC", "FCC_DOC", "FCC_HEAD", "TCCARDTYP", "BKK_CARD", "TB033"],
    "channels": ["FEBKO", "FEBEP", "FEBRE", "FEBCL", "FEBPI", "FEBVW", "T028B", "T028D", "T028G"],
    "collateral": ["CMS_REL_COLL_OBJ", "CMS_OBJ", "CMS_REL", "CMS_CAG", "TCMS_OBJTYPE", "BCA_COLL"],
    "dmee": ["DMEE_TREE_HEAD", "DMEE_TREE_NODE", "DMEE_PARK", "DMEE_PAR", "T_DMEE", "DMEEABA"],
}
_name_q = {m: list(CURATED.get(m, [])) for m in MODULES}
_tail = defaultdict(int)


def next_name(mod):
    q = _name_q.get(mod, [])
    while q:
        cand = q.pop(0)
        if cand not in nodes:
            return cand
    _tail[mod] += 1
    nid = "%s%03d" % (PREFIX[mod], 100 + _tail[mod])
    while nid in nodes:
        _tail[mod] += 1
        nid = "%s%03d" % (PREFIX[mod], 100 + _tail[mod])
    return nid


# Tablas HUB nombradas (reales de SAP) con su rol de acoplamiento cross-modulo
HUB_TABLES = {
    "T001":   ("CUST", "fi_gl", "Company codes — referenced by every posting"),
    "TCURC":  ("CUST", "fi_gl", "Currency codes"),
    "TCURX":  ("CUST", "fi_gl", "Decimal places per currency (amount conversion)"),
    "TCURR":  ("CUST", "fi_gl", "Exchange rates"),
    "T005":   ("CUST", "bp", "Country keys"),
    "SKA1":   ("MASTER", "fi_gl", "G/L account master (chart of accounts)"),
    "SKB1":   ("MASTER", "fi_gl", "G/L account master (company-code level)"),
    "BUT000": ("MASTER", "bp", "Business Partner — the customer, shared by all modules"),
    "BNKA":   ("MASTER", "bp", "Bank master"),
    "T012":   ("CUST", "payments", "House banks"),
    "T880":   ("MASTER", "fi_gl", "Global company (group)"),
    "TBSL":   ("CUST", "fi_gl", "Posting keys"),
}

rnd = random.Random(SEED)
nodes = {}                       # id -> dict(layer, domain, loc, access)
by_layer = defaultdict(list)
by_mod_layer = defaultdict(list)
by_module = defaultdict(list)


def add_node(nid, layer, module, loc):
    if nid in nodes:
        return
    nodes[nid] = {"id": nid, "layer": layer, "domain": module, "loc": loc}
    by_layer[layer].append(nid)
    by_mod_layer[(module, layer)].append(nid)
    by_module[module].append(nid)


# ---- 1. Hubs nombrados primero ----
for nid, (layer, module, _desc) in HUB_TABLES.items():
    add_node(nid, layer, module, rnd.randint(50, 5000))


# ---- 2. Tablas generadas por arquetipo, repartidas en modulos ----
def make(layer, count, loc_range):
    for _ in range(count):
        mod = rnd.choice(MODULES)
        nid = next_name(mod)   # nombre SAP real (curado) o PREFIX de familia real + num
        add_node(nid, layer, mod, rnd.randint(*loc_range))


make("MASTER", N_MASTER, (200, 50000))
make("TXN", N_TXN, (5000, 50000000))     # transaccional: alto volumen
make("TEXT", N_TEXT, (200, 80000))
make("CUST", N_CUST, (5, 4000))
make("TOTALS", N_TOTALS, (1000, 200000))

# modulo muerto (legacy decomisionado): isla
dead_ids = []
for i in range(N_DEAD):
    nid = "ZZOLD_%04d" % i
    add_node(nid, "TXN", "obsolete", rnd.randint(1000, 200000))
    dead_ids.append(nid)

# CRM satelite (sistema NO-SAP)
crm_ids = []
add_node("CRM_ACCOUNT", "MASTER", "crm", 5000)
crm_ids.append("CRM_ACCOUNT")
for i in range(N_CRM - 1):
    nid = "CRM_%04d" % i
    add_node(nid, rnd.choice(["TXN", "MASTER"]), "crm", rnd.randint(500, 200000))
    crm_ids.append(nid)

# ---- access por arquetipo (read-mostly vs transaccional) ----
for nd in nodes.values():
    L = nd["layer"]
    nd["access"] = "read" if L in ("CUST", "TEXT", "TOTALS") else "update"

edges = []
indeg = defaultdict(int)
seen_edge = set()


def add_edge(s, d, t):
    if s == d or (s, d) in seen_edge:
        return
    seen_edge.add((s, d))
    edges.append((s, d, t))
    indeg[d] += 1


master_ids = [n for n in by_layer["MASTER"] if nodes[n]["domain"] not in ("obsolete", "crm")]
cust_ids = [n for n in by_layer["CUST"] if nodes[n]["domain"] != "obsolete"]
txn_ids = [n for n in by_layer["TXN"] if nodes[n]["domain"] not in ("obsolete", "crm")]
text_ids = [n for n in by_layer["TEXT"]]
totals_ids = [n for n in by_layer["TOTALS"]]


def pref_pick(pool):
    """preferential attachment: favorece nodos con fan-in alto -> scale-free."""
    weights = [(indeg[n] + 1) ** PREF_EXP for n in pool]
    return rnd.choices(pool, weights=weights, k=1)[0]


def pick_in_module(pool, mod):
    cands = [n for n in pool if nodes[n]["domain"] == mod]
    return cands or pool


def ref_target(pool, mod):
    """FK target: dentro del modulo salvo fuga cross-modulo."""
    if rnd.random() < CROSS_MODULE_LEAKAGE:
        return pref_pick(pool)
    return pref_pick(pick_in_module(pool, mod))


# ---- 3. FK: TXN -> MASTER (1-3) + CUST hubs (1-2) ----
for t in txn_ids:
    mod = nodes[t]["domain"]
    for _ in range(rnd.randint(1, 3)):
        add_edge(t, ref_target(master_ids, mod), "fk")
    for _ in range(rnd.randint(1, 2)):
        add_edge(t, ref_target(cust_ids, mod), "fk")
    # casi todo posting toca company code y moneda (hubs reales)
    add_edge(t, "T001", "fk")
    if rnd.random() < 0.6:
        add_edge(t, rnd.choice(["TCURC", "TCURX"]), "fk")
    # los modulos financieros tocan GL account (fuga estructural a FI)
    if mod in ("am_deposits", "cml_loans", "payments", "co", "cards") and rnd.random() < 0.5:
        add_edge(t, rnd.choice(["SKA1", "SKB1"]), "fk")

# ---- 4. MASTER -> CUST + BUT000/BNKA ----
for m in master_ids:
    mod = nodes[m]["domain"]
    for _ in range(rnd.randint(1, 2)):
        add_edge(m, ref_target(cust_ids, mod), "fk")
    if rnd.random() < 0.45 and m != "BUT000":
        add_edge(m, "BUT000", "fk")     # casi toda master cuelga del cliente
    add_edge(m, "T001", "fk")

# ---- 5. TEXT -> MASTER (su maestro) ----
for tx in text_ids:
    mod = nodes[tx]["domain"]
    add_edge(tx, ref_target(master_ids, mod), "fk")

# ---- 6. TOTALS -> MASTER + CUST ----
for to in totals_ids:
    mod = nodes[to]["domain"]
    add_edge(to, ref_target(master_ids, mod), "fk")
    add_edge(to, ref_target(cust_ids, mod), "fk")
    add_edge(to, "T001", "fk")

# ---- 7. Ciclos (SCCs) entre MASTER de actualizacion (jerarquias/estatus circular) ----
planted_cycles = []
used = set()
cyc_pool = [m for m in master_ids if m not in HUB_TABLES]
for _ in range(N_CYCLES):
    size = rnd.randint(*CYCLE_SIZE)
    avail = [m for m in cyc_pool if m not in used]
    if len(avail) < size:
        break
    ring = rnd.sample(avail, size)
    used.update(ring)
    for i in range(size):
        add_edge(ring[i], ring[(i + 1) % size], "fk")
    planted_cycles.append(ring)

# ---- 8. Modulo muerto: FK internas, sin inbound del grafo vivo ----
for s in dead_ids:
    for _ in range(rnd.randint(1, 3)):
        add_edge(s, rnd.choice(dead_ids), "fk")

# ---- 9. CRM satelite + entity-link (acoplamiento OCULTO cross-system) ----
for c in crm_ids:
    if c == "CRM_ACCOUNT":
        continue
    add_edge(c, "CRM_ACCOUNT", "fk")
add_edge("CRM_ACCOUNT", "BUT000", "entity-link")   # mismo cliente, ningun FK lo declara

# ---- 10. Acoplamiento OCULTO: tablas compartidas referenciadas cross-modulo ----
# (analogo del copybook coupling: el hairball que el call/FK graph por-modulo no ve)
shared_usage = defaultdict(set)        # tabla compartida -> modulos que la referencian
for s, d, t in edges:
    if t == "fk" and nodes[d]["domain"] != nodes[s]["domain"]:
        shared_usage[d].add(nodes[s]["domain"])
# quedarse con las realmente transversales (>=3 modulos)
shared_coupling = {k: sorted(v) for k, v in shared_usage.items() if len(v) >= 3}

shared_glossary = {k: HUB_TABLES[k][2] for k in HUB_TABLES}

# ============================================================
#  ANALISIS — answer key COMPUTADO del grafo
# ============================================================
adj = defaultdict(list)
radj = defaultdict(list)
for s, d, t in edges:
    adj[s].append(d)
    radj[d].append(s)

N = len(nodes)
E = len(edges)

# --- hubs por in-degree ---
hubs = sorted(nodes.keys(), key=lambda n: indeg[n], reverse=True)[:25]

# --- Tarjan SCC (iterativo, seguro a escala) ---
index = {}
low = {}
on_stack = set()
stack = []
sccs = []
counter = [0]
for root in list(nodes.keys()):
    if root in index:
        continue
    work = [(root, 0)]
    while work:
        v, pi = work[-1]
        if pi == 0:
            index[v] = low[v] = counter[0]
            counter[0] += 1
            stack.append(v)
            on_stack.add(v)
        recursed = False
        children = adj[v]
        if pi < len(children):
            work[-1] = (v, pi + 1)
            w = children[pi]
            if w not in index:
                work.append((w, 0))
                recursed = True
            elif w in on_stack:
                low[v] = min(low[v], index[w])
        if not recursed and pi >= len(children):
            if low[v] == index[v]:
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
                low[work[-1][0]] = min(low[work[-1][0]], low[v])

nontrivial_sccs = [c for c in sccs if len(c) > 1]

# --- WCC (componentes debilmente conexas) -> islas muertas ---
parent = {n: n for n in nodes}


def find(x):
    while parent[x] != x:
        parent[x] = parent[parent[x]]
        x = parent[x]
    return x


def union(a, b):
    ra, rb = find(a), find(b)
    if ra != rb:
        parent[ra] = rb


for s, d, t in edges:
    union(s, d)
wcc = defaultdict(list)
for n in nodes:
    wcc[find(n)].append(n)
wccs = sorted(wcc.values(), key=len, reverse=True)
isolated = [n for n in nodes if indeg[n] == 0 and len(adj[n]) == 0]
dead_wcc = [c for c in wccs if all(nodes[x]["domain"] == "obsolete" for x in c)]
dead_total = sum(len(c) for c in dead_wcc)

# --- modularidad por modulo (proyeccion no dirigida) ---
deg = defaultdict(int)
for s, d, t in edges:
    deg[s] += 1
    deg[d] += 1
m2 = 2.0 * E
comm = {n: nodes[n]["domain"] for n in nodes}
Lc = defaultdict(float)
Dc = defaultdict(float)
for n in nodes:
    Dc[comm[n]] += deg[n]
for s, d, t in edges:
    if comm[s] == comm[d]:
        Lc[comm[s]] += 1
Q = sum((Lc[c] / E) - (Dc[c] / m2) ** 2 for c in set(comm.values())) if E else 0.0

# fuga cross-modulo observada
cross = sum(1 for s, d, t in edges if t == "fk" and comm[s] != comm[d] and "obsolete" not in (comm[s], comm[d]))
fk_total = sum(1 for s, d, t in edges if t == "fk")
max_fanin = max(indeg.values()) if indeg else 0

# ============================================================
#  EMIT
# ============================================================
HERE = os.path.dirname(os.path.abspath(__file__))
SEED_DIR = os.path.dirname(HERE)
G = os.path.join(SEED_DIR, "graph")
AK = os.path.join(SEED_DIR, "answer-key")
os.makedirs(G, exist_ok=True)
os.makedirs(AK, exist_ok=True)

graph = {
    "system": "SAP-BANKING-ECC-SCALE",
    "seed": SEED,
    "nodes": [{"id": n, "layer": nodes[n]["layer"], "domain": nodes[n]["domain"],
               "loc": nodes[n]["loc"], "access": nodes[n]["access"]} for n in nodes],
    "edges": [{"from": s, "to": d, "type": t} for s, d, t in edges],
}
with open(os.path.join(G, "dependency-graph.json"), "w", encoding="utf-8") as f:
    json.dump(graph, f, indent=1, ensure_ascii=False)
with open(os.path.join(G, "shared-table-usage.json"), "w", encoding="utf-8") as f:
    json.dump({k: v for k, v in shared_coupling.items()}, f, indent=1, ensure_ascii=False)
with open(os.path.join(G, "shared-table-glossary.json"), "w", encoding="utf-8") as f:
    json.dump(shared_glossary, f, indent=1, ensure_ascii=False)

# Sidecars que CONSUME el render_graph.py de RE (nombres fijos) para dibujar la capa
# de acoplamiento: tabla compartida -> tablas (node ids) que la referencian por FK.
coupling_members = defaultdict(list)
for s, d, t in edges:
    if t == "fk" and d in shared_coupling:
        coupling_members[d].append(s)
cpy_usage = {k: sorted(set(coupling_members[k])) for k in shared_coupling}
cpy_gloss = {k: (HUB_TABLES[k][2] if k in HUB_TABLES
                 else "Tabla compartida por %d modulos (acoplamiento oculto)" % len(shared_coupling[k]))
             for k in shared_coupling}
with open(os.path.join(G, "copybook-usage.json"), "w", encoding="utf-8") as f:
    json.dump(cpy_usage, f, indent=1, ensure_ascii=False)
with open(os.path.join(G, "copybook-glossary.json"), "w", encoding="utf-8") as f:
    json.dump(cpy_gloss, f, indent=1, ensure_ascii=False)

# ---- ESQUEMAS de referencia por tabla (DDL) -> source/{id}.sql ----
# El render_graph.py de RE escanea {seed}/source/ y, si halla {node_id}.sql, muestra
# un visor por nodo. Aqui el esquema es coherente con la TOPOLOGIA: las columnas FK
# corresponden 1:1 a las aristas salientes del grafo (ese es el punto didactico).
SRCDIR = os.path.join(SEED_DIR, "source")
os.makedirs(SRCDIR, exist_ok=True)
# limpiar .sql previos (evita huerfanos de nombres de runs anteriores)
for _old in os.listdir(SRCDIR):
    if _old.endswith(".sql"):
        try:
            os.remove(os.path.join(SRCDIR, _old))
        except OSError:
            pass
out_edges = defaultdict(list)
for s, d, t in edges:
    out_edges[s].append((d, t))
# nombre de columna FK por tabla target (real SAP donde aplica)
FKCOL = {"T001": "BUKRS", "TCURC": "WAERS", "TCURX": "WAERS", "TCURR": "KURST",
         "T005": "LAND1", "SKA1": "SAKNR", "SKB1": "SAKNR", "BUT000": "PARTNER",
         "BNKA": "BANKL", "T012": "HBKID", "T880": "RCOMP", "TBSL": "BSCHL"}
DOMCOL = {"bp": "PARTNER", "am_deposits": "KONTO", "cml_loans": "DARLEHEN",
          "payments": "PYORD", "fi_gl": "SAKNR", "co": "KOKRS", "cards": "CARDID",
          "channels": "STMID", "collateral": "COLID", "dmee": "DMEEID", "crm": "CRM_ID"}
COLTYPE = {"WAERS": "CUKY", "BUKRS": "CHAR(4)", "LAND1": "CHAR(3)", "SPRAS": "LANG",
           "KURST": "CHAR(4)", "RCOMP": "CHAR(6)", "BSCHL": "CHAR(2)"}
ARCH_FIELDS = {
    "MASTER": [("NAME1", "CHAR(40)", "nombre / descripcion"), ("ERDAT", "DATS", "fecha creacion"),
               ("LOEVM", "CHAR(1)", "flag de borrado")],
    "TXN": [("BUDAT", "DATS", "fecha contable"), ("BLDAT", "DATS", "fecha documento"),
            ("DMBTR", "CURR(15)", "importe (minor units, ver TCURX)"), ("SHKZG", "CHAR(1)", "debe/haber")],
    "TEXT": [("SPRAS", "LANG", "clave de idioma"), ("TXTLG", "CHAR(50)", "texto descriptivo")],
    "CUST": [("WERT", "CHAR(20)", "valor de configuracion"), ("DESCR", "CHAR(40)", "descripcion")],
    "TOTALS": [("GJAHR", "NUMC(4)", "ejercicio"), ("MONAT", "NUMC(2)", "periodo"),
               ("SALDO", "CURR(17)", "saldo acumulado")],
}
for nid, nd in nodes.items():
    L, mod = nd["layer"], nd["domain"]
    is_crm = (mod == "crm")
    cols = []
    used = set()

    def addcol(c, ty, cm):
        base, i = c, 2
        while c in used:
            c = "%s%d" % (base, i)
            i += 1
        used.add(c)
        cols.append((c, ty, cm))
    if not is_crm:
        addcol("MANDT", "CLNT", "mandante (client)")
    addcol((nid.split("_")[0] + "ID")[:10], "CHAR(18)", "clave primaria (ALPHA, ceros a la izq.)")
    for d, t in out_edges.get(nid, []):
        if t == "entity-link":
            addcol("SAP_PARTNER_REF", "CHAR(10)", "-> %s (entity-link; NO hay FK declarada)" % d)
        else:
            col = FKCOL.get(d) or DOMCOL.get(nodes[d]["domain"], "REF")
            addcol(col, COLTYPE.get(col, "CHAR(10)"), "FK -> %s" % d)
    for c, ty, cm in ARCH_FIELDS.get(L, []):
        addcol(c, ty, cm)
    _n = len(cols)
    body = "\n".join("  %-16s %-10s%s  -- %s" % (c, ty, ("," if i < _n - 1 else " "), cm)
                     for i, (c, ty, cm) in enumerate(cols))
    desc = HUB_TABLES.get(nid, (None, None, ""))[2] or "(generada)"
    head = ("-- %s  ·  %s  ·  arquetipo %s  ·  fan-in=%d\n-- %s\n-- ESQUEMA DE REFERENCIA (graph-as-data): las columnas FK = aristas salientes del grafo.\n"
            % (nid, MOD_LABEL.get(mod, mod), L, indeg[nid] if nid in indeg else 0, desc))
    with open(os.path.join(SRCDIR, "%s.sql" % nid), "w", encoding="utf-8") as f:
        f.write(head + "CREATE TABLE %s (\n%s\n);\n" % (nid, body))


def w(name, text):
    with open(os.path.join(AK, name), "w", encoding="utf-8") as f:
        f.write(text)


def table(headers, rows):
    out = "| " + " | ".join(headers) + " |\n|" + "|".join("---" for _ in headers) + "|\n"
    for r in rows:
        out += "| " + " | ".join(str(x) for x in r) + " |\n"
    return out


# inventario por modulo y arquetipo
mod_rows = []
for mod in MODULES + ["crm", "obsolete"]:
    cnt = len(by_module[mod])
    if not cnt:
        continue
    by_arch = defaultdict(int)
    for n in by_module[mod]:
        by_arch[nodes[n]["layer"]] += 1
    arch = " ".join("%s:%d" % (k, by_arch[k]) for k in sorted(by_arch))
    mod_rows.append((MOD_LABEL.get(mod, mod), mod, cnt, arch))
w("ground-truth-source-inventory.md",
  "# Ground Truth - Source Inventory (SAP Banking ECC a escala)\n\n"
  "> Grafo generado proceduralmente. seed=%d. %d tablas, %d FK/edges.\n\n" % (SEED, N, E)
  + table(["Modulo", "clave", "# tablas", "arquetipos"], mod_rows))

w("ground-truth-graph-metrics.md",
  "# Ground Truth - Graph Metrics\n\n> Computado del grafo. seed=%d.\n\n" % SEED
  + table(["Metrica", "Valor"], [
      ("Nodos (tablas)", N), ("Edges (FK + entity-link)", E),
      ("Densidad", round(E / (N * (N - 1)), 6)),
      ("Fan-in maximo", max_fanin),
      ("SCCs no triviales (ciclos)", len(nontrivial_sccs)),
      ("Componentes debilmente conexas (WCC)", len(wccs)),
      ("WCC mas grande (nodos)", len(wccs[0]) if wccs else 0),
      ("Tablas en isla muerta (obsolete)", dead_total),
      ("Tablas aisladas (sin FK)", len(isolated)),
      ("Modularidad Q (por modulo)", round(Q, 4)),
      ("FK cross-modulo (fuga)", "%d / %d (%.1f%%)" % (cross, fk_total, 100.0 * cross / max(fk_total, 1))),
  ]))

w("ground-truth-hubs.md",
  "# Ground Truth - Hubs (blast radius por fan-in)\n\n"
  "> Las tablas mas referenciadas: maximo impacto si cambian. Migrar/masterear primero.\n\n"
  + table(["#", "Tabla", "Fan-in", "Arquetipo", "Modulo", "Rol"],
          [(i + 1, h, indeg[h], nodes[h]["layer"], nodes[h]["domain"],
            HUB_TABLES.get(h, ("", "", "(generada)"))[2]) for i, h in enumerate(hubs)]))

w("ground-truth-cycles.md",
  "# Ground Truth - Cycles (SCCs no triviales)\n\n"
  "> Ciclos de FK: no hay orden topologico -> no hay orden de migracion obvio dentro del ciclo.\n\n"
  + (table(["#", "Tamano", "Tablas"], [(i + 1, len(c), ", ".join(c)) for i, c in enumerate(nontrivial_sccs)])
     if nontrivial_sccs else "_Sin SCCs no triviales._\n"))

comm_rows = []
for mod in MODULES + ["crm", "obsolete"]:
    if not by_module[mod]:
        continue
    comm_rows.append((MOD_LABEL.get(mod, mod), len(by_module[mod]), round(Lc[mod]), round(Dc[mod])))
w("ground-truth-communities.md",
  "# Ground Truth - Communities (modulos) + modularidad\n\n"
  "> Modularidad Q=%.4f. Fuga cross-modulo=%.1f%%. Q<1 => los modulos NO son limpios:\n"
  "> encontrar los seams para waves es el problema real.\n\n" % (Q, 100.0 * cross / max(fk_total, 1))
  + table(["Modulo", "# tablas", "edges internos", "grado total"], comm_rows))

w("ground-truth-dead-clusters.md",
  "# Ground Truth - Dead Clusters (islas no referenciadas)\n\n"
  "> Modulo legacy decomisionado: %d tablas en isla(s) sin inbound del grafo vivo + %d aisladas.\n"
  "> Candidatas a RETIRE (no migrar).\n\n" % (dead_total, len(isolated))
  + table(["WCC", "# tablas", "modulos"], [
      (i + 1, len(c), ", ".join(sorted(set(nodes[x]["domain"] for x in c))))
      for i, c in enumerate(dead_wcc)]))

# acoplamiento oculto: top tablas compartidas cross-modulo
sc_rows = sorted(shared_coupling.items(), key=lambda kv: -len(kv[1]))[:25]
w("ground-truth-shared-table-coupling.md",
  "# Ground Truth - Shared-Table Coupling (el acoplamiento OCULTO)\n\n"
  "> Analogo del copybook coupling de Mainframe. Tablas referenciadas por FK desde >=3\n"
  "> modulos: acoplan modulos que 'deberian' estar separados. Un plan de waves basado solo\n"
  "> en el call/FK graph por-modulo NO ve este acoplamiento -> causa #1 de fallo del Strangler.\n\n"
  + table(["Tabla compartida", "# modulos", "modulos", "rol"],
          [(k, len(v), ", ".join(v), shared_glossary.get(k, "(generada)")) for k, v in sc_rows]))

acc = defaultdict(int)
for n in nodes:
    acc[nodes[n]["access"]] += 1
w("ground-truth-access-classification.md",
  "# Ground Truth - Access Classification\n\n"
  "> read-mostly (customizing/text/totals) vs transaccional (master/txn). Base para\n"
  "> wave planning: las read-mostly (referencia) migran temprano y de bajo riesgo.\n\n"
  + table(["Clase", "# tablas"], [("read (referencia)", acc["read"]),
                                   ("update (transaccional/master)", acc["update"])]))

print("OK - seed-sap-banking-ecc-scale-graph (seed=%d)" % SEED)
print("  nodos=%d  edges=%d  fan-in max=%d (%s)" % (N, E, max_fanin, hubs[0]))
print("  SCCs no triviales=%d  WCC=%d  isla muerta=%d  aisladas=%d" % (
    len(nontrivial_sccs), len(wccs), dead_total, len(isolated)))
print("  modularidad Q=%.4f  fuga cross-modulo=%.1f%%" % (Q, 100.0 * cross / max(fk_total, 1)))
print("  acoplamiento oculto: %d tablas compartidas (>=3 modulos)" % len(shared_coupling))
print("  top hubs:", ", ".join("%s(%d)" % (h, indeg[h]) for h in hubs[:6]))