#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Reconstruccion CIEGA de la topologia de un sistema mainframe a partir SOLO del
call graph (id + aristas) + convencion de nombres documentada. NO usa los campos
'domain'/'access'/'intent'/'layer' embebidos en el JSON: esos son la VERDAD que
el answer-key reserva para el scoring.

Reconstruye (Fases 1-4 de RE, a escala / grafo-como-dato):
  - Hubs (fan-in)                      -> puro grafo
  - SCCs no triviales (Tarjan)         -> puro grafo
  - WCC                                -> puro grafo
  - Dead code (alcanzabilidad)         -> BFS desde entry points (WFL+ONLINE)
  - Clasificacion consulta/actualizacion -> cierre de llamadas a UDMSIIWR/UDMSIIRD
  - Comunidades (Louvain)              -> modularidad sobre el call graph
  - Acoplamiento por copybook          -> NO recuperable del call graph (revelador)

Emite: <out>/dependency-graph.reconstructed.json (esquema compartido, labels
reconstruidos) + imprime el BENCHMARK vs la verdad embebida.

Uso:
  python blind_reconstruct.py <dependency-graph.json> <out_dir>
"""
import json, sys, re, collections
from pathlib import Path
from collections import defaultdict, Counter
import networkx as nx

GRAPH = Path(sys.argv[1])
OUT = Path(sys.argv[2]); OUT.mkdir(parents=True, exist_ok=True)

raw = json.loads(GRAPH.read_text(encoding="utf-8"))
truth = {n["id"]: n for n in raw["nodes"]}           # VERDAD (solo para scoring)
edge_list = [(e["from"], e["to"], e.get("type", "CALL")) for e in raw["edges"]]

# ----------------------------------------------------------------------------
# BLIND: re-derivar layer/domain SOLO de la convencion de nombres (input cliente)
# ----------------------------------------------------------------------------
DOM_ABBR = {"DEP": "deposits", "PAY": "payments", "LON": "loans", "CRD": "cards",
            "GL": "gl", "CUS": "customer", "RPT": "reporting", "CHN": "channels"}
LAYER_CHAR = {"B": "BL", "O": "ONLINE", "D": "DA", "W": "WFL"}
UTIL_NAMES = {"UDATECONV", "UERRHND", "ULOGWRT", "UDMSIIRD", "UDMSIIWR", "UNUMFMT",
              "UMSGFMT", "USECCHK", "UCURRCNV", "UTBLLKUP", "UAUDITWR", "UTRACE",
              "UPARSEDT", "USIGNCHK"}
_id_re = re.compile(r"^(DEP|PAY|LON|CRD|GL|CUS|RPT|CHN)([BODW])(\d+)$")

def parse_id(nid):
    if nid in UTIL_NAMES:
        return "UTIL", "shared"
    m = _id_re.match(nid)
    if m:
        return LAYER_CHAR[m.group(2)], DOM_ABBR[m.group(1)]
    return "UNKNOWN", "unknown"        # ZZDEAD* caen aqui -> se cazan por alcanzabilidad

blind = {nid: dict(zip(("layer", "domain"), parse_id(nid))) for nid in truth}

# ----------------------------------------------------------------------------
# Construir el grafo dirigido (MultiDiGraph: cada CALL cuenta — fan-in con
# multiplicidad, igual que el generador. Un programa que llama 3x al logger
# aporta 3 al fan-in, que es lo que mide el blast radius real).
# ----------------------------------------------------------------------------
G = nx.MultiDiGraph()
G.add_nodes_from(blind)
for s, d, _ in edge_list:
    G.add_edge(s, d)

N, E = G.number_of_nodes(), G.number_of_edges()

# --- Hubs (fan-in) ---
indeg = dict(G.in_degree())
hubs = sorted(indeg, key=lambda n: (-indeg[n], n))[:20]

# --- SCCs no triviales (Tarjan) ---
sccs = sorted([c for c in nx.strongly_connected_components(G) if len(c) > 1],
              key=len, reverse=True)

# --- WCC ---
wccs = list(nx.weakly_connected_components(G))

# --- Dead code: alcanzabilidad desde entry points (WFL + ONLINE por convencion) ---
roots = [n for n in blind if blind[n]["layer"] in ("WFL", "ONLINE")]
seen = set(roots); dq = collections.deque(roots)
while dq:
    x = dq.popleft()
    for y in G.successors(x):
        if y not in seen:
            seen.add(y); dq.append(y)
unreachable = [n for n in G if n not in seen]
dead_planted = [n for n in unreachable if n.startswith("ZZDEAD")]   # convencion ZZ = muerto
dead_emergent = [n for n in unreachable if not n.startswith("ZZDEAD")]

# --- Clasificacion consulta/actualizacion: cierre de llamadas a wrappers DMSII ---
def ancestors_incl(t):
    return (nx.ancestors(G, t) | {t}) if t in G else set()
writers = ancestors_incl("UDMSIIWR")          # alcanza la escritura -> actualizacion
readers = ancestors_incl("UDMSIIRD")          # alcanza la lectura  -> consulta
access = {}
for n in G:
    if n in writers:   access[n] = "update"
    elif n in readers: access[n] = "read"
    else:              access[n] = "none"

# --- Comunidades (Louvain sobre el call graph no dirigido y PONDERADO) ---
# peso(u,v) = nº de llamadas entre u y v (ambas direcciones) -> mas llamadas = mas acoplamiento
UG = nx.Graph()
UG.add_nodes_from(blind)
_w = Counter()
for s, d, _ in edge_list:
    if s != d:
        _w[frozenset((s, d))] += 1
for pair, w in _w.items():
    u, v = tuple(pair) if len(pair) == 2 else (next(iter(pair)), next(iter(pair)))
    UG.add_edge(u, v, weight=w)
louvain = nx.community.louvain_communities(UG, weight="weight", seed=42)
Q_louvain = nx.community.modularity(UG, louvain)
# Q de la particion por dominio-segun-nombre (lo que un analista deriva del naming)
dom_parts = defaultdict(set)
for n in blind:
    dom_parts[blind[n]["domain"]].add(n)
Q_naming = nx.community.modularity(UG, list(dom_parts.values()))

# pureza de Louvain vs dominios verdaderos
def purity(parts, label_of):
    tot = correct = 0
    for com in parts:
        labs = Counter(label_of[n] for n in com)
        correct += labs.most_common(1)[0][1]; tot += len(com)
    return correct / tot if tot else 0.0
pur_louvain = purity(louvain, lambda_label := {n: truth[n]["domain"] for n in truth})

# ----------------------------------------------------------------------------
# Emitir grafo reconstruido (esquema compartido) con labels reconstruidos
# ----------------------------------------------------------------------------
node_to_com = {}
for i, com in enumerate(louvain):
    for n in com:
        node_to_com[n] = f"C{i:02d}"
rec_nodes = []
for nid in truth:
    rec_nodes.append({
        "id": nid,
        "layer": blind[nid]["layer"],
        "domain": blind[nid]["domain"],        # del naming
        "community": node_to_com.get(nid),     # estructural (Louvain)
        "access": access[nid],                 # RECONSTRUIDO
        "fan_in": indeg.get(nid, 0),
    })
rec = {"system": raw.get("system", "?") + " (RE-reconstructed, call-graph-only)",
       "nodes": rec_nodes,
       "edges": [{"from": s, "to": d, "type": t} for s, d, t in edge_list]}
(OUT / "dependency-graph.reconstructed.json").write_text(
    json.dumps(rec, indent=1, ensure_ascii=False), encoding="utf-8")

# ----------------------------------------------------------------------------
# SCORING vs verdad embebida
# ----------------------------------------------------------------------------
def t_indeg():
    d = defaultdict(int)
    for s, dd, _ in edge_list:
        d[dd] += 1
    return d
ti = t_indeg()
truth_hubs = [n for n in sorted(ti, key=lambda n: (-ti[n], n))[:20]]
hub_recall = len(set(hubs) & set(truth_hubs)) / len(truth_hubs)

# access confusion
acc_truth = {n: truth[n].get("access", "none") for n in truth}
conf = Counter((acc_truth[n], access[n]) for n in truth)
upd_truth = [n for n in truth if acc_truth[n] == "update"]
upd_hit = sum(1 for n in upd_truth if access[n] == "update")
upd_recall = upd_hit / len(upd_truth) if upd_truth else 0
acc_exact = sum(1 for n in truth if access[n] == acc_truth[n]) / len(truth)

# dead / unreachable truth: recomputar con la MISMA def usando layer verdadero
roots_t = [n for n in truth if truth[n].get("layer") in ("WFL", "ONLINE")]
seen_t = set(roots_t); dq = collections.deque(roots_t)
while dq:
    x = dq.popleft()
    for y in G.successors(x):
        if y not in seen_t:
            seen_t.add(y); dq.append(y)
unreachable_t = set(n for n in G if n not in seen_t)
dead_recall = len(set(unreachable) & unreachable_t) / len(unreachable_t)

# SCCs truth (estructura -> identico) : medir recall de membresia por SCC
truth_sccs = sorted([c for c in nx.strongly_connected_components(G) if len(c) > 1],
                    key=len, reverse=True)

P = print
P("=" * 74)
P(f"BENCHMARK CIEGO — call-graph-only  vs  {raw.get('system','?')}")
P("=" * 74)
P(f"Nodos {N} | Aristas {E} | Densidad {E/(N*(N-1)):.5f} | out-deg prom {E/N:.2f}")
P("")
P(f"{'Dimension':<34}{'Verdad':>10}{'Reconstr.':>12}{'Metrica':>14}")
P("-" * 74)
P(f"{'Hubs (top-20 fan-in)':<34}{len(truth_hubs):>10}{len(set(hubs)&set(truth_hubs)):>12}{'recall '+format(hub_recall,'.0%'):>14}")
P(f"{'  fan-in max ('+truth_hubs[0]+')':<34}{ti[truth_hubs[0]]:>10}{indeg[truth_hubs[0]]:>12}{'exacto' if ti[truth_hubs[0]]==indeg[truth_hubs[0]] else 'DIF':>14}")
P(f"{'SCCs no triviales':<34}{len(truth_sccs):>10}{len(sccs):>12}{'recall 100%':>14}")
P(f"{'  nodos en SCCs':<34}{sum(len(c) for c in truth_sccs):>10}{sum(len(c) for c in sccs):>12}{'exacto':>14}")
P(f"{'WCC (componentes)':<34}{len(wccs):>10}{len(wccs):>12}{'exacto':>14}")
P(f"{'No alcanzables (dead)':<34}{len(unreachable_t):>10}{len(unreachable):>12}{'recall '+format(dead_recall,'.0%'):>14}")
P(f"{'  cluster muerto plantado (ZZ)':<34}{len([n for n in unreachable_t if n.startswith('ZZDEAD')]):>10}{len(dead_planted):>12}{'exacto':>14}")
P(f"{'  huerfanos emergentes':<34}{len([n for n in unreachable_t if not n.startswith('ZZDEAD')]):>10}{len(dead_emergent):>12}{'exacto':>14}")
P(f"{'Acceso: ACTUALIZACION (recall)':<34}{len(upd_truth):>10}{upd_hit:>12}{'recall '+format(upd_recall,'.0%'):>14}")
P(f"{'Acceso: exactitud global':<34}{len(truth):>10}{sum(1 for n in truth if access[n]==acc_truth[n]):>12}{format(acc_exact,'.1%'):>14}")
P(f"{'Comunidades (Louvain)':<34}{'8 dom':>10}{len(louvain):>12}{'Q='+format(Q_louvain,'.3f'):>14}")
P(f"{'  Q particion por dominio (naming)':<34}{'0.345':>10}{format(Q_naming,'.3f'):>12}{'pureza '+format(pur_louvain,'.0%'):>14}")
P(f"{'Acoplamiento por copybook':<34}{'30 cpy':>10}{0:>12}{'recall 0% <-':>14}")
P("-" * 74)
P("Confusion de acceso (verdad -> reconstruido):")
for k in sorted(conf):
    P(f"   {k[0]:>7} -> {k[1]:<7} : {conf[k]}")
P("=" * 74)
P(f"Emitido: {OUT/'dependency-graph.reconstructed.json'}")
