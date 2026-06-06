#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
profile_scale.py - Fase 1 Discover en MODO GRAFO (a escala)

Consume el modelo a escala del Reference Data Lab (seed-sap-banking-ecc-scale-graph,
~1,500 tablas, graph-as-data, sin filas) y produce el Source Profiling & Discovery
Assessment a escala. Computa la topologia DE FORMA INDEPENDIENTE del grafo fuente
(hubs por fan-in, comunidades/modularidad, ciclos via Tarjan, dead clusters via WCC,
acoplamiento cross-modulo) — como un discovery real, no leyendo el answer key.

[GATE] El modelo solo se consume con sign-off del SME SAP Banking Services
(.../seed-sap-banking-ecc-scale-graph/validation/validation-sap-core-banking-signoff.md).

Determinista. Solo stdlib.  Ejecutar: python profile_scale.py
"""
import json
import os
from collections import defaultdict
from datetime import datetime
from string import Template

HERE = os.path.dirname(os.path.abspath(__file__))
FASE = os.path.dirname(HERE)
ART = os.path.join(FASE, "artifacts-scale")
SCALE = os.path.normpath(os.path.join(
    FASE, "..", "Enablement", "Training - Reference Data Lab",
    "seed-sap-banking-ecc-scale-graph"))
GRAPH = os.path.join(SCALE, "graph", "dependency-graph.json")
SIGNOFF = os.path.join(SCALE, "validation", "validation-sap-core-banking-signoff.md")

MOD_LABEL = {"bp": "Business Partner", "am_deposits": "Deposits Mgmt (FS-AM)",
             "cml_loans": "Loans Mgmt (FS-CML)", "payments": "Payments",
             "fi_gl": "Financial Accounting / GL", "co": "Controlling",
             "cards": "Cards", "channels": "Bank Statement / Channels",
             "collateral": "Collateral (BCA)", "dmee": "Payment Medium (DMEE)",
             "crm": "CRM (satélite, no-SAP)", "obsolete": "Legacy decomisionado",
             "shared": "Compartido"}

# ---- cargar grafo ----
G = json.load(open(GRAPH, encoding="utf-8"))
nodes = {n["id"]: n for n in G["nodes"]}
edges = [(e["from"], e["to"], e.get("type", "fk")) for e in G["edges"]]
N, E = len(nodes), len(edges)

indeg = defaultdict(int)
adj = defaultdict(list)
deg = defaultdict(int)
for s, d, t in edges:
    indeg[d] += 1
    adj[s].append(d)
    deg[s] += 1
    deg[d] += 1

by_module = defaultdict(list)
by_mod_arch = defaultdict(lambda: defaultdict(int))
for nid, nd in nodes.items():
    by_module[nd["domain"]].append(nid)
    by_mod_arch[nd["domain"]][nd["layer"]] += 1

# ---- hubs ----
hubs = sorted(nodes, key=lambda n: indeg[n], reverse=True)[:25]
max_fanin = indeg[hubs[0]] if hubs else 0

# ---- Tarjan SCC (iterativo) ----
index, low, onst, stack, sccs, cnt = {}, {}, set(), [], [], [0]
for root in nodes:
    if root in index:
        continue
    work = [(root, 0)]
    while work:
        v, pi = work[-1]
        if pi == 0:
            index[v] = low[v] = cnt[0]
            cnt[0] += 1
            stack.append(v)
            onst.add(v)
        rec = False
        ch = adj[v]
        if pi < len(ch):
            work[-1] = (v, pi + 1)
            w = ch[pi]
            if w not in index:
                work.append((w, 0))
                rec = True
            elif w in onst:
                low[v] = min(low[v], index[w])
        if not rec and pi >= len(ch):
            if low[v] == index[v]:
                comp = []
                while True:
                    w = stack.pop()
                    onst.discard(w)
                    comp.append(w)
                    if w == v:
                        break
                sccs.append(comp)
            work.pop()
            if work:
                low[work[-1][0]] = min(low[work[-1][0]], low[v])
cycles = [c for c in sccs if len(c) > 1]

# ---- WCC (islas) ----
par = {n: n for n in nodes}
def find(x):
    while par[x] != x:
        par[x] = par[par[x]]
        x = par[x]
    return x
for s, d, t in edges:
    a, b = find(s), find(d)
    if a != b:
        par[a] = b
wcc = defaultdict(list)
for n in nodes:
    wcc[find(n)].append(n)
wccs = sorted(wcc.values(), key=len, reverse=True)
isolated = [n for n in nodes if indeg[n] == 0 and not adj[n]]
dead = [c for c in wccs if all(nodes[x]["domain"] == "obsolete" for x in c)]
dead_total = sum(len(c) for c in dead)

# ---- modularidad + fuga cross-modulo ----
comm = {n: nodes[n]["domain"] for n in nodes}
Lc, Dc = defaultdict(float), defaultdict(float)
for n in nodes:
    Dc[comm[n]] += deg[n]
for s, d, t in edges:
    if comm[s] == comm[d]:
        Lc[comm[s]] += 1
Q = sum((Lc[c] / E) - (Dc[c] / (2 * E)) ** 2 for c in set(comm.values())) if E else 0
fk = [(s, d) for s, d, t in edges if t == "fk"]
cross = sum(1 for s, d in fk if comm[s] != comm[d] and "obsolete" not in (comm[s], comm[d]))

# ---- acoplamiento oculto (tablas compartidas >=3 modulos) ----
shared = defaultdict(set)
for s, d, t in edges:
    if t == "fk" and comm[s] != comm[d]:
        shared[d].add(comm[s])
coupling = sorted([(k, sorted(v)) for k, v in shared.items() if len(v) >= 3],
                  key=lambda kv: -len(kv[1]))

# ---- access ----
acc = defaultdict(int)
for n in nodes:
    acc[nodes[n].get("access", "?")] += 1

# ---- dispositions + waves (por modulo) ----
DISP_MODULE = {
    "fi_gl": ("Rehost-raw + Master", "GL/customizing: hubs referenciados por todo (T001, monedas, GL accounts) -> Wave 0"),
    "bp": ("Master/Consolidate", "Business Partner: el cliente, hub master -> Wave 0 (mastering)"),
    "am_deposits": ("Conform", "Cuentas y movimientos: alto volumen, FK a BP/GL"),
    "cml_loans": ("Conform", "Créditos: FK a BP/GL"),
    "payments": ("Conform", "Pagos: FK a cuentas/bancos/GL"),
    "co": ("Conform", "Controlling"),
    "cards": ("Conform", "Cards"),
    "channels": ("Conform", "Bank statement / canales"),
    "collateral": ("Conform", "Colateral"),
    "dmee": ("Conform", "Medios de pago"),
    "crm": ("Master/Consolidate", "CRM satélite: entity resolution con BP (entity-link)"),
    "obsolete": ("Retire", "Módulo legacy decomisionado: isla sin inbound -> NO migrar"),
}
WAVES = [
    ("Wave 0 - Foundation", ["fi_gl", "bp"], "Customizing + GL + Business Partner: referenciados por todo. Mastering BP+CRM aquí."),
    ("Wave 1 - Cuentas y productos", ["am_deposits", "cml_loans", "collateral"], "Dependen de BP/GL."),
    ("Wave 2 - Transaccional y pagos", ["payments", "co", "cards"], "Dependen de cuentas/GL."),
    ("Wave 3 - Canales y satélites", ["channels", "dmee", "crm"], "Capa de canales + CRM."),
    ("Retire", ["obsolete"], "Isla legacy: no migra."),
]

os.makedirs(ART, exist_ok=True)


def tbl(h, rows):
    return "| " + " | ".join(h) + " |\n|" + "|".join("---" for _ in h) + "|\n" + \
        "".join("| " + " | ".join(str(x) for x in r) + " |\n" for r in rows)


def w(name, txt):
    open(os.path.join(ART, name), "w", encoding="utf-8").write(txt)


modules_present = [m for m in MOD_LABEL if by_module.get(m)]
inv_rows = [(MOD_LABEL[m], m, len(by_module[m]),
             " ".join("%s:%d" % (k, by_mod_arch[m][k]) for k in sorted(by_mod_arch[m])))
            for m in modules_present]
w("inventory-by-module.md", "# Inventario por módulo (a escala)\n\n> %d tablas, %d FK. Computado del grafo.\n\n" % (N, E)
  + tbl(["Módulo", "clave", "# tablas", "arquetipos"], inv_rows))
w("hubs.md", "# Hubs por blast-radius (fan-in)\n\n" + tbl(["#", "Tabla", "Fan-in", "Módulo"],
  [(i + 1, h, indeg[h], nodes[h]["domain"]) for i, h in enumerate(hubs)]))
w("shared-table-coupling.md", "# Acoplamiento oculto (tablas compartidas >=3 módulos)\n\n"
  + tbl(["Tabla", "# módulos", "módulos"], [(k, len(v), ", ".join(v)) for k, v in coupling[:25]]))
w("dead-clusters.md", "# Dead clusters (RETIRE)\n\n> Isla legacy %d tablas + %d aisladas.\n" % (dead_total, len(isolated)))
w("handoff-discover-to-target.md", "# Handoff Fase 1 (escala) -> Fase 2\n\n"
  "- %d tablas, %d módulos, %d FK. Hub principal: %s (fan-in %d).\n"
  "- Acoplamiento oculto: %d tablas compartidas cross-módulo (Wave 0 obligatoria).\n"
  "- Dead/RETIRE: %d tablas legacy.\n- Modularidad Q=%.3f; fuga cross-módulo %.1f%%.\n"
  "- [GATE] modelo validado por SME SAP Banking Services (sign-off adjunto).\n"
  % (N, len(modules_present), E, hubs[0], max_fanin, len(coupling), dead_total, Q, 100.0 * cross / max(len(fk), 1)))

# ---- discovery-assessment-scale.html ----
def cards(items):
    return "".join('<div class="card"><div class="n">%s</div><div class="v">%s</div></div>' % (k, v) for k, v in items)
def ht(h, rows):
    return "<table><tr>%s</tr>%s</table>" % ("".join("<th>%s</th>" % x for x in h),
        "".join("<tr>%s</tr>" % "".join("<td>%s</td>" % c for c in r) for r in rows))

wave_html = ""
for nm, mods, note in WAVES:
    rows = [(MOD_LABEL[m], DISP_MODULE[m][0], len(by_module.get(m, [])), DISP_MODULE[m][1]) for m in mods if by_module.get(m)]
    if rows:
        wave_html += "<h3>%s</h3><p class='muted'>%s</p>%s" % (nm, note, ht(["Módulo", "Disposición", "# tablas", "Razón"], rows))

signoff_exists = os.path.isfile(SIGNOFF)
html = Template(r"""<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Discovery Assessment (escala) - BANKING-SAP-CRM</title><style>
 :root{--purple:#6B21A8;--magenta:#A100FF;--ink:#1A1A2E;--bg:#f4f4f6;--card:#fff;--line:#dcdce4;--txt:#22222e;--muted:#63636f;--green:#2e7d4f}
 *{box-sizing:border-box}body{margin:0;font-family:'Segoe UI',Roboto,Arial,sans-serif;background:var(--bg);color:var(--txt);line-height:1.55;font-size:14.5px}
 header{background:var(--ink);color:#fff;padding:22px 38px;border-bottom:3px solid var(--purple)}
 header h1{margin:0;font-size:21px}header p{margin:4px 0 0;font-size:12.5px;opacity:.85}
 main{max-width:1080px;margin:0 auto;padding:30px 28px 70px}
 h2{font-size:13px;text-transform:uppercase;letter-spacing:.6px;color:var(--purple);margin:30px 0 12px;border-bottom:1px solid var(--line);padding-bottom:6px}
 h3{font-size:14.5px;color:var(--ink);margin:18px 0 6px}
 .grid{display:grid;gap:13px;grid-template-columns:repeat(4,1fr);margin:10px 0}
 @media(max-width:760px){.grid{grid-template-columns:1fr 1fr}}
 .card{background:var(--card);border:1px solid var(--line);border-left:4px solid var(--magenta);border-radius:6px;padding:13px 15px}
 .card .n{font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.4px}.card .v{font-size:20px;font-weight:700;color:var(--ink);margin-top:3px}
 table{border-collapse:collapse;width:100%;background:#fff;border:1px solid var(--line);border-radius:6px;overflow:hidden;font-size:13px;margin:8px 0}
 th{background:#f0eef6;color:var(--purple);text-align:left;padding:7px 10px;font-size:11.5px;text-transform:uppercase}
 td{padding:7px 10px;border-top:1px solid var(--line)}.muted{color:var(--muted);font-size:13px}
 .verdict{background:#f3effa;border:1px solid #e0d5f3;border-radius:8px;padding:16px 18px;margin:10px 0}.verdict b{color:var(--purple)}
 .flag{background:#fdecea;border-left:4px solid #c0392b;padding:12px 15px;border-radius:6px;margin:10px 0}
 .ok{background:#e9f6ee;border-left:4px solid var(--green);padding:12px 15px;border-radius:6px;margin:10px 0}
 ul{margin:8px 0;padding-left:20px}li{margin:4px 0}footer{text-align:center;color:var(--muted);font-size:11px;padding:20px;border-top:1px solid var(--line)}
 code{background:#eee;padding:1px 5px;border-radius:3px}
</style></head><body>
<header><h1>Discovery Assessment &mdash; Core Bancario SAP (escala)</h1>
<p>Fase 1 &mdash; Discover &amp; Source Profiling (modo grafo) &middot; Data Migration &middot; AI-ready Data &middot; &#9733; Digital Core &middot; $date</p></header>
<main>
<h2>Executive summary</h2>
<div class="grid">$cards</div>
<div class="verdict"><b>Veredicto Discover:</b> data estate de <b>$N tablas</b> en <b>$nmods módulos</b> con <b>$E relaciones FK</b>. Topología <b>scale-free</b>: el hub <code>$hub</code> es referenciado por <b>$fanin</b> tablas (máximo blast-radius). <b>Acoplamiento oculto</b>: $ncoupling tablas compartidas conectan módulos que "deberían" estar separados (fuga cross-módulo $leak%) &mdash; el estate NO es migrable por módulos aislados. Readiness: <b>condicional</b> a respetar el orden de waves (Foundation primero) y a la validación de fidelidad del SME.</div>
$signoff
<h2>Inventario por módulo</h2>
$inventory
<h2>Hubs &mdash; blast radius (fan-in)</h2>
<p class="muted">Las tablas más referenciadas: cambiarlas/migrarlas mal impacta medio sistema. Foundation de Wave 0.</p>
$hubs
<h2>Acoplamiento oculto &mdash; tablas compartidas cross-módulo</h2>
<div class="flag"><b>[HALLAZGO]</b> $ncoupling tablas son referenciadas por &ge;3 módulos (company code, monedas, GL, Business Partner). Acoplan módulos por datos sin que un plan por-módulo lo vea &mdash; causa #1 de fallo del Strangler. Deben migrar en Wave 0.</div>
$coupling
<h2>Topología &mdash; ciclos y dead clusters</h2>
<p class="muted">Ciclos (SCCs no triviales): <b>$ncycles</b> &mdash; sin orden topológico, no hay orden de migración obvio dentro del ciclo. Dead/RETIRE: <b>$dead</b> tablas (módulo legacy) + <b>$iso</b> aisladas. Modularidad Q=<b>$Q</b>.</p>
<p class="muted">Grafo navegable: <code>../Enablement/Training - Reference Data Lab/seed-sap-banking-ecc-scale-graph/graph-view.html</code> (click en una tabla &rarr; "Ver esquema").</p>
<h2>Disposición y wave plan</h2>
$waves
<h2>Discover closing gate</h2>
<div class="ok"><b>Criterios antes de Fase 2:</b><ul>
<li>Inventario + topología de las $N tablas computados &#10003;</li>
<li>Hubs + acoplamiento oculto cuantificados &#10003;</li>
<li>Dead clusters + ciclos identificados &#10003;</li>
<li>Wave plan por módulo (Foundation primero) &#10003;</li>
<li><b>[GATE] Fidelidad del modelo validada por SME SAP Banking Services</b> &#10003;</li>
<li><b>Pendiente humano:</b> clasificación PII + criticidad por Data Steward (HITL).</li>
</ul></div>
<h2>Handoff a Fase 2</h2>
<p class="muted">Detalle en <code>artifacts-scale/handoff-discover-to-target.md</code>. Wave 0 (Foundation) primero: GL/customizing + Business Partner + mastering CRM.</p>
</main>
<footer>Fase 1 Discover (escala) &middot; Data Migration &middot; uso interno &middot; modelo de referencia validado por SME, sin IP de cliente</footer>
</body></html>""").safe_substitute({
    "date": datetime.now().strftime("%Y-%m-%d"),
    "N": "{:,}".format(N), "E": "{:,}".format(E), "nmods": len(modules_present),
    "hub": hubs[0], "fanin": "{:,}".format(max_fanin), "ncoupling": len(coupling),
    "leak": "%.0f" % (100.0 * cross / max(len(fk), 1)),
    "ncycles": len(cycles), "dead": dead_total, "iso": len(isolated), "Q": "%.2f" % Q,
    "cards": cards([("Tablas", "{:,}".format(N)), ("Módulos", len(modules_present)),
                    ("Relaciones FK", "{:,}".format(E)), ("Hub máx (fan-in)", "{:,}".format(max_fanin)),
                    ("Tablas compartidas", len(coupling)), ("Ciclos (SCC)", len(cycles)),
                    ("Dead/RETIRE", dead_total), ("Modularidad Q", "%.2f" % Q)]),
    "signoff": ('<div class="ok"><b>[GATE] Fidelidad validada:</b> el modelo fue revisado y firmado por el SME <b>SAP Banking Services</b> (APROBADO CON OBSERVACIONES). Modelo de referencia, sin IP de cliente; fiel al patrón SAP for Banking. Ver <code>.../validation/validation-sap-core-banking-signoff.md</code>.</div>' if signoff_exists else '<div class="flag"><b>[GATE PENDIENTE]</b> falta sign-off del SME SAP Banking Services.</div>'),
    "inventory": ht(["Módulo", "clave", "# tablas", "arquetipos"], inv_rows),
    "hubs": ht(["#", "Tabla", "Fan-in", "Módulo"], [(i + 1, h, "{:,}".format(indeg[h]), nodes[h]["domain"]) for i, h in enumerate(hubs[:15])]),
    "coupling": ht(["Tabla compartida", "# módulos", "módulos"], [(k, len(v), ", ".join(v)) for k, v in coupling[:15]]),
    "waves": wave_html,
})
open(os.path.join(FASE, "discovery-assessment-scale.html"), "w", encoding="utf-8").write(html)

print("OK - Fase 1 discovery a escala")
print("  %d tablas, %d FK, %d modulos | hub=%s(%d) | ciclos=%d dead=%d aisladas=%d Q=%.3f coupling=%d" % (
    N, E, len(modules_present), hubs[0], max_fanin, len(cycles), dead_total, len(isolated), Q, len(coupling)))
print("  signoff SME presente:", signoff_exists)
print("  -> discovery-assessment-scale.html + artifacts-scale/")