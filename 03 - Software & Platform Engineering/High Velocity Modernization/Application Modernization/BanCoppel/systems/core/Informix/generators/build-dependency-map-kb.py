#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-dependency-map-kb.py — Mapa de dependencias entre componentes Informix.

Genera: knowledge-base/cross-reference/component-dependency-map.md

Secciones:
  1. Matriz de dependencias entre dominios (N×N, edges cross_db)
  2. Top dependencias cross-dominio (pares db→db más frecuentes)
  3. Fan-in champions — SPs más llamados (nodos críticos, bloqueantes de migración)
  4. Fan-out champions — SPs con más salidas (orquestadores, mayor complejidad)
  5. Hub SPs — alto fan_in Y fan_out (puentes estructurales del sistema)
  6. Índice de aislamiento por dominio (% llamadas internas vs externas)
  7. Cadenas críticas — paths de 2-3 saltos sobre hubs
  8. SPs sin conectividad (aislados — potencial dead code)

SPE-AM-001 · Etapa 3 · Dependency Analysis
"""
import json, os
from collections import defaultdict, Counter

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/Informix/")

cg    = json.load(open(BASE + "portal/data/callgraph-data.json", encoding="utf-8"))
NODES = cg["graph"]["nodes"]
EDGES = cg["graph"]["edges"]

# Domain mapping (D01-D16 canonical + unmapped raw)
DOMN = {
    "bdicnweb":"D01","bdinteg":"D02","bdicred":"D03","bdicheq":"D04",
    "bdisac":"D05","bdisolic":"D06","bdiaclaracion":"D07","bdispei":"D08",
    "bdimnsj":"D09","bdisuc":"D10","bdicobranza":"D11","bdicont":"D12",
    "bditef":"D13","bdibei":"D14","bdilide":"D15","intercard":"D16",
}
DOMN_LABELS = {
    "D01":"Canal Web","D02":"Integración","D03":"Créditos","D04":"Cheques",
    "D05":"Saldos/SAC","D06":"Solicitudes","D07":"Aclaraciones","D08":"SPEI",
    "D09":"Mensajería","D10":"Sucursales","D11":"Cobranza","D12":"Contabilidad",
    "D13":"TEF","D14":"BEI","D15":"PLD/LIDE","D16":"Tarjetas",
    "bdiburo":"Buró Crédito","bdisitesp":"Sitio Especial","bditarjeta":"Tarjeta (tja)",
    "bdidomi":"Domiciliación","bdiprog":"Programas","bditransfer":"Transfer",
    "bdiauditor":"Auditoría","bditarjcop":"Tarjeta Coppel","bdivr":"Voice Response",
    "bdinvers":"Inversiones","bdicorresp":"Corresponsalía","bdibpi":"BPI",
    "bdiedoelec":"Edo. Electrónico","bdimonitorcob":"Monitor Cob.","bditrans":"Transacciones",
    "bditrapres":"Trámites Pres.","intercardbpi":"Intercard BPI","bdicplbot":"Compliance Bot",
    "bdicntchq":"Cnt. Cheques","bdicat":"Catálogos",
}

def dom(db): return DOMN.get(db, db)
def lbl(d):  return DOMN_LABELS.get(d, d)

# ── Index nodes ──────────────────────────────────────────────────────────────
node_by_id  = {n["id"]: n for n in NODES}
node_by_lbl = {n["label"]: n for n in NODES}

# Full set of SP labels (from source/ scan — all 12,832)
all_sp_files = set()
src = BASE + "source/informix/"
if os.path.isdir(src):
    for f in os.listdir(src):
        if f.endswith(".sql"):
            # filename: db_spname.sql → extract sp label
            parts = f[:-4].split("_", 1)
            if len(parts) == 2:
                all_sp_files.add(parts[1])  # sp name (without db prefix)

# ── Edge aggregation ─────────────────────────────────────────────────────────
callers  = defaultdict(Counter)  # sp_label → {caller_label: count}
callees  = defaultdict(Counter)  # sp_label → {callee_label: count}
dom_matrix = Counter()           # (from_dom, to_dom) → edge_count (cross only)
dom_pair   = Counter()           # (from_db, to_db) → edge_count (cross only)
dom_internal = Counter()         # db → internal edge count
dom_external = Counter()         # db → external edge count

for e in EDGES:
    frm_id, to_id = e["from"], e["to"]
    frm_n = node_by_id.get(frm_id, {})
    to_n  = node_by_id.get(to_id,  {})
    frm_sp = frm_n.get("label", frm_id.split(":",1)[1] if ":" in frm_id else frm_id)
    to_sp  = to_n.get("label",  to_id.split(":",1)[1]  if ":" in to_id  else to_id)
    frm_db = frm_n.get("db", frm_id.split(":")[0] if ":" in frm_id else "")
    to_db  = to_n.get("db",  to_id.split(":")[0]  if ":" in to_id  else "")

    callers[to_sp][frm_sp]  += 1
    callees[frm_sp][to_sp]  += 1

    if e.get("cross_db") or frm_db != to_db:
        frm_dom = dom(frm_db)
        to_dom  = dom(to_db)
        dom_matrix[(frm_dom, to_dom)] += 1
        dom_pair[(frm_db, to_db)]     += 1
        dom_external[frm_db]          += 1
    else:
        dom_internal[frm_db] += 1

# ── Node metrics ─────────────────────────────────────────────────────────────
node_fi = {n["label"]: n["fan_in"]  for n in NODES}
node_fo = {n["label"]: n["fan_out"] for n in NODES}
node_db = {n["label"]: n["db"]      for n in NODES}
node_lc = {n["label"]: n["loc"]     for n in NODES}

# Domains present
all_doms = sorted(set(dom(n["db"]) for n in NODES),
                  key=lambda d: (0 if d.startswith("D") else 1, d))

# ── Build MD ─────────────────────────────────────────────────────────────────
os.makedirs(BASE + "knowledge-base/cross-reference", exist_ok=True)
OUT = BASE + "knowledge-base/cross-reference/component-dependency-map.md"

L = [
    "# Informix · Mapa de Dependencias entre Componentes",
    "",
    "> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Dependency Analysis  ",
    "> **Generado:** 2026-08-02 · `build-dependency-map-kb.py`  ",
    f"> **Callgraph:** {len(NODES):,} nodos · {len(EDGES):,} edges · {len(all_doms)} dominios/bases  ",
    "> **Propósito:** fuente de verdad para el plan de migración — qué depende de qué, cuáles SPs son bloqueantes, y qué dominios deben migrarse antes que otros.  ",
    "",
    "---",
    "",
    "## 1. Matriz de dependencias entre dominios (cross-DB)",
    "",
    "> Solo edges `cross_db=true` (llamadas que cruzan bases de datos). Las internas se muestran en §6.",
    "> Leer como: fila = dominio **origen** (caller), columna = dominio **destino** (callee).",
    "",
]

# Build matrix for top domains (by total cross-db involvement)
dom_involvement = Counter()
for (fd, td), cnt in dom_matrix.items():
    dom_involvement[fd] += cnt
    dom_involvement[td] += cnt

top_doms = [d for d, _ in dom_involvement.most_common(20)]

# Header row
header_labels = [lbl(d)[:8] for d in top_doms]
L.append("| Origen \\ Destino | " + " | ".join(header_labels) + " |")
L.append("|" + "---|" * (len(top_doms) + 1))
for fd in top_doms:
    row = [f"**{lbl(fd)[:12]}** (`{fd}`)"]
    for td in top_doms:
        cnt = dom_matrix.get((fd, td), 0)
        row.append(str(cnt) if cnt > 0 else "—")
    L.append("| " + " | ".join(row) + " |")

L += [
    "",
    "---",
    "",
    "## 2. Top 40 dependencias cross-dominio (pares más frecuentes)",
    "",
    "| # | DB Origen | DB Destino | Dom. Origen | Dom. Destino | Edges |",
    "|---|---|---|---|---|---:|",
]
for i, ((fd, td), cnt) in enumerate(dom_pair.most_common(40), 1):
    L.append(f"| {i} | `{fd}` | `{td}` | {lbl(dom(fd))} | {lbl(dom(td))} | {cnt:,} |")

L += [
    "",
    "> **Interpretación para el plan de migración:** si D01 llama a D02 3,490 veces,",
    "> D02 debe estar estable en el target antes de migrar cualquier SP de D01.",
    "",
    "---",
    "",
    "## 3. Fan-in champions — SPs más llamados (nodos críticos)",
    "",
    "> Un SP con fan_in alto es un **bloqueante de migración**: si falla, todos sus callers fallan.",
    "> Estos SPs deben tener golden master y parallel-run verificado **antes** de cualquier cutover.",
    "",
    "| # | SP | DB | Dom. | fan_in | fan_out | LOC | Callers (muestra) |",
    "|---|---|---|---|---:|---:|---:|---|",
]
top_fi = sorted(NODES, key=lambda n: -n["fan_in"])[:60]
for i, n in enumerate(top_fi, 1):
    sp  = n["label"]
    top_c = [s for s, _ in callers.get(sp, Counter()).most_common(3)]
    c_str = ", ".join(f"`{s}`" for s in top_c) if top_c else "—"
    L.append(f"| {i} | `{sp}` | `{n['db']}` | {dom(n['db'])} | {n['fan_in']:,} | {n['fan_out']:,} | {n['loc']:,} | {c_str} |")

L += [
    "",
    "---",
    "",
    "## 4. Fan-out champions — SPs con más salidas (orquestadores)",
    "",
    "> Un SP con fan_out alto es un **orquestador complejo**: llama a muchos otros SPs.",
    "> Son los más costosos de migrar porque requieren validar la equivalencia de todas sus dependencias.",
    "",
    "| # | SP | DB | Dom. | fan_out | fan_in | LOC | Callees (muestra) |",
    "|---|---|---|---|---:|---:|---:|---|",
]
top_fo = sorted(NODES, key=lambda n: -n["fan_out"])[:60]
for i, n in enumerate(top_fo, 1):
    sp  = n["label"]
    top_e = [s for s, _ in callees.get(sp, Counter()).most_common(3)]
    e_str = ", ".join(f"`{s}`" for s in top_e) if top_e else "—"
    L.append(f"| {i} | `{sp}` | `{n['db']}` | {dom(n['db'])} | {n['fan_out']:,} | {n['fan_in']:,} | {n['loc']:,} | {e_str} |")

L += [
    "",
    "---",
    "",
    "## 5. Hub SPs — alto fan_in Y fan_out (puentes estructurales)",
    "",
    "> Los hubs son el **sistema nervioso del sistema**: los falla tanto callers como callees.",
    "> Criterio: fan_in ≥ 50 AND fan_out ≥ 20. Estos SPs deben migrarse con doble parallel-run.",
    "",
    "| SP | DB | Dom. | fan_in | fan_out | LOC | Rol estimado |",
    "|---|---|---|---:|---:|---:|---|",
]
hubs = sorted([n for n in NODES if n["fan_in"] >= 50 and n["fan_out"] >= 20],
              key=lambda n: -(n["fan_in"] * n["fan_out"]))
for n in hubs:
    fi, fo = n["fan_in"], n["fan_out"]
    role = ("orquestador-crítico" if fo > 100 else
            "distribuidor" if fi > fo * 2 else
            "puente")
    L.append(f"| `{n['label']}` | `{n['db']}` | {dom(n['db'])} | {fi:,} | {fo:,} | {n['loc']:,} | {role} |")

L += [
    "",
    "---",
    "",
    "## 6. Índice de aislamiento por dominio",
    "",
    "> **Aislamiento alto** = mayoría de llamadas son internas → puede migrarse con menor coordinación cross-domain.",
    "> **Aislamiento bajo** = muchas llamadas cross-DB → la migración requiere coordinar con otros dominios.",
    "",
    "| DB | Dom. | Edges internos | Edges externos | Total | % Interno | Riesgo coordinación |",
    "|---|---|---:|---:|---:|---:|---|",
]
all_dbs = sorted(set(n["db"] for n in NODES))
for db in sorted(all_dbs,
                 key=lambda d: -(dom_internal.get(d,0) + dom_external.get(d,0))):
    internal = dom_internal.get(db, 0)
    external = dom_external.get(db, 0)
    total    = internal + external
    if total == 0:
        continue
    pct = int(internal * 100 / total)
    risk = ("BAJO" if pct >= 80 else "MEDIO" if pct >= 50 else "ALTO")
    L.append(f"| `{db}` | {dom(db)} | {internal:,} | {external:,} | {total:,} | {pct}% | {risk} |")

L += [
    "",
    "---",
    "",
    "## 7. Cadenas críticas — paths 2-3 saltos sobre hubs",
    "",
    "> Secuencias de llamada que pasan por al menos un hub. Son los caminos de mayor riesgo en el cutover.",
    "> Formato: SP_A → SP_B (hub) → SP_C",
    "",
    "| Origen | Hub | Destino | Dominios cruzados |",
    "|---|---|---|---|",
]

# Build top hub labels for chain discovery
hub_labels = {n["label"] for n in hubs[:30]}

chains_seen = set()
for hub_n in hubs[:30]:
    hub_sp = hub_n["label"]
    hub_db = hub_n["db"]
    # callers of this hub
    top_callers = [s for s, _ in callers.get(hub_sp, Counter()).most_common(5)]
    # callees of this hub
    top_callees = [s for s, _ in callees.get(hub_sp, Counter()).most_common(5)]
    for caller in top_callers[:3]:
        for callee in top_callees[:3]:
            if caller != callee:
                k = f"{caller}→{hub_sp}→{callee}"
                if k not in chains_seen:
                    chains_seen.add(k)
                    caller_db = node_db.get(caller, "")
                    callee_db = node_db.get(callee, "")
                    doms_crossed = len({dom(caller_db), dom(hub_db), dom(callee_db)})
                    L.append(f"| `{caller}` | `{hub_sp}` | `{callee}` | {doms_crossed} dominio(s) |")
                    if len(chains_seen) >= 50:
                        break
        if len(chains_seen) >= 50:
            break

L += [
    "",
    "---",
    "",
    "## 8. SPs sin conectividad en callgraph",
    "",
    "> SPs del filesystem que NO aparecen en el callgraph — posible dead code o endpoints de entrada directa.",
    "> **Criterio de riesgo**: si tienen > 200 LOC y no están en callgraph, revisar si son entry-points omitidos.",
    "",
]

# SPs in callgraph
cg_labels = set(n["label"] for n in NODES)

# SPs known from filesystem (only available if source/ exists)
if all_sp_files:
    orphans_db = sorted(all_sp_files - cg_labels)
    L += [
        f"**Total SPs en filesystem:** {len(all_sp_files):,}  ",
        f"**En callgraph:** {len(cg_labels):,}  ",
        f"**Sin conectividad (aislados):** {len(orphans_db):,}  ",
        "",
        f"> Muestra de los primeros 100 aislados (ordenados alfabéticamente):",
        "",
        "| SP | Observación |",
        "|---|---|",
    ]
    for sp in sorted(orphans_db)[:100]:
        note = "posible entry-point" if any(sp.startswith(p) for p in ("sp_api_","sp_web_","sp_ext_")) else "revisar uso"
        L.append(f"| `{sp}` | {note} |")
    if len(orphans_db) > 100:
        L.append(f"| *(+{len(orphans_db)-100} más — ver filesystem)* | |")
else:
    L += [
        f"**SPs en callgraph:** {len(cg_labels):,}  ",
        "> Nota: para el listado completo de aislados se requiere acceso al filesystem source/.  ",
        f"> Total aproximado: 12,832 (filesystem) − {len(cg_labels):,} (callgraph) = ~{12832-len(cg_labels):,} sin conectividad registrada.",
    ]

L += [
    "",
    "---",
    "",
    "## 9. Recomendaciones para el plan de migración",
    "",
    "| Prioridad | Hallazgo | Acción |",
    "|---|---|---|",
]

# Dynamic recommendations based on data
# Find domains with most cross-db external dependencies (highest coordination risk)
high_ext = sorted(all_dbs, key=lambda d: -dom_external.get(d, 0))[:5]
high_int = sorted([d for d in all_dbs if dom_internal.get(d,0) > 0],
                  key=lambda d: -dom_internal.get(d,0) / max(dom_internal.get(d,0)+dom_external.get(d,0),1))[:5]

recs = []
recs.append(("P1", f"`{top_fi[0]['label']}` (fan_in={top_fi[0]['fan_in']:,}): SP más llamado del sistema",
             "Estabilizar y golden-master antes de cualquier cutover"))
recs.append(("P1", f"`{top_fo[0]['label']}` (fan_out={top_fo[0]['fan_out']:,}): SP más complejo",
             "Mapear todas sus dependencias antes de migrar"))
recs.append(("P1", f"Dominio `{dom(high_ext[0])}` ({high_ext[0]}): {dom_external.get(high_ext[0],0):,} edges cross-DB",
             "Alta coordinación — migrar SPs dependientes ANTES"))
if hubs:
    hub_count = len(hubs)
    recs.append(("P2", f"{hub_count} Hub SPs identificados (fan_in≥50 Y fan_out≥20)",
                 "Cada hub requiere double parallel-run (callers + callees)"))
recs.append(("P2", f"Dominio `{dom(high_int[0])}` ({high_int[0]}): mayor % interno → menor coordinación",
             "Candidato para Wave temprana — pocas dependencias externas"))
recs.append(("P3", "SPs con fan_in=0 y fan_out=0 en callgraph",
             "Revisar como posible dead code candidato a retire (7R)"))

for pri, hallazgo, accion in recs:
    L.append(f"| **{pri}** | {hallazgo} | {accion} |")

L += [
    "",
    "---",
    "",
    "*Generado automáticamente · `build-dependency-map-kb.py` · Informix SPE-AM-001*  ",
    "*Fuente: `callgraph-data.json` · Para actualizar: `python build-dependency-map-kb.py`*",
]

open(OUT, "w", encoding="utf-8").write("\n".join(L))
print(f"component-dependency-map.md escrito · {len(L)} líneas")
print(f"  Hubs: {len(hubs)} SPs (fan_in≥50 AND fan_out≥20)")
print(f"  Dominios en matriz: {len(top_doms)}")
print(f"  Cadenas críticas: {len(chains_seen)}")
print(f"  Cross-domain pares únicos: {len(dom_pair)}")
