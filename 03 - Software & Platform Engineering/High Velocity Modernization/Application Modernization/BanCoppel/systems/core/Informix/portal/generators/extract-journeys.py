#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Extrae journeys de negocio (call chains desde entry points) por dominio
del call graph Informix. Genera journeys-data.json embebible en el HTML.
Etapa 3 — Business Logic Extraction · Specialist Informix SPL.
"""
import json, re
from collections import defaultdict

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/Informix/")
CG = json.load(open(BASE + "portal/data/callgraph-data.json", encoding="utf-8"))

nodes = {n["id"]: n for n in CG["graph"]["nodes"]}
out = defaultdict(list)
inn = defaultdict(list)
for e in CG["graph"]["edges"]:
    out[e["from"]].append(e["to"])
    inn[e["to"]].append(e["from"])

NM   = lambda i: nodes.get(i, {}).get("label", i.split(":")[-1])
DBOF = lambda i: i.split(":")[0]
LOC  = lambda i: nodes.get(i, {}).get("loc", 0)

# ── metadata de dominios (alineada al component-map) ───────────────
DOMS = {
 "d01": dict(db="bdicnweb",     name="Canal Digital Web", color="#1E6868", wave=6, reg=[]),
 "d02": dict(db="bdinteg",      name="Integración y Auth",color="#2A507A", wave=5, reg=["CNBV"]),
 "d03": dict(db="bdicred",      name="Créditos",          color="#7A4018", wave=4, reg=["CNBV","SAT","CONDUSEF"]),
 "d04": dict(db="bdicheq",      name="Cheques / Cuentas",  color="#8B3535", wave=4, reg=["CNBV","TESOFE","IPAB","CONDUSEF"]),
 "d05": dict(db="bdisac",       name="Saldos y Cuentas",   color="#6B6B18", wave=3, reg=["CNBV","IPAB","SAT"]),
 "d06": dict(db="bdisolic",     name="Solicitudes",        color="#2E6B48", wave=3, reg=["CNBV","CONDUSEF"]),
 "d07": dict(db="bdiaclaracion",name="Aclaraciones",       color="#803060", wave=2, reg=["CONDUSEF","CNBV"]),
 "d08": dict(db="bdispei",      name="SPEI",               color="#7A2020", wave=2, reg=["Banxico"]),
 "d09": dict(db="bdimnsj",      name="Mensajería",         color="#1A7A4A", wave=1, reg=["CNBV","CONDUSEF"]),
 "d10": dict(db="bdisuc",       name="Sucursales",         color="#485055", wave=3, reg=["CNBV"]),
 "d11": dict(db="bdicobranza",  name="Cobranza",           color="#503280", wave=2, reg=["CNBV","CONDUSEF"]),
 "d12": dict(db="bdicont",      name="Contabilidad",       color="#3D5A24", wave=4, reg=["SAT","IPAB","CNBV"]),
}
DB2DOM = {v["db"]: k for k, v in DOMS.items()}

# DBs regulatorias que, al ser invocadas cross-domain, marcan el paso como regulatorio
REG_DB = {"bdispei": "Banxico", "bdicont": "SAT/Contable"}
REG_NAME = re.compile(r"(regulatorio|cnbv|condusef|spei|ipab|tesofe|_reg\b)", re.I)

# objetivo de negocio compuesto por tokenización (catálogo compartido sp_vocab.py)
from sp_vocab import compose

def infer_name(sp):
    """Devuelve el objetivo compuesto (frase). None si no aporta nada útil."""
    phrase, _flag, _estado = compose(sp)
    return phrase if phrase and phrase != sp else None

MAX_DEPTH = 3
MAX_CHILD = 7

def build_chain(root, db, depth, path):
    """DFS de la cadena de llamadas. path = ids en la rama actual (anti-ciclo)."""
    kids = []
    for callee in out.get(root, []):
        if callee in path:            # evita ciclo en la rama
            continue
        cdb = DBOF(callee)
        cross = cdb != db
        cname = NM(callee)
        cbiz, _f, cbest = compose(cname)
        node = {
            "id": callee, "name": cname, "biz": cbiz, "biz_estado": cbest,
            "db": cdb, "cross": cross, "loc": LOC(callee),
            "reg": bool(REG_NAME.search(cname)) or (cdb in REG_DB),
            "reg_by": REG_DB.get(cdb) if cross else None,
            "children": [],
        }
        # expandir solo pasos internos al dominio (los cross se muestran como hoja etiquetada)
        if depth > 1 and not cross:
            node["children"] = build_chain(callee, db, depth - 1, path | {callee})
        kids.append(node)
        if len(kids) >= MAX_CHILD:
            break
    return kids

def triggered_by(nid, db):
    """Quién dispara el journey: dominios origen (cross-DB) o invocación directa app/batch."""
    caller_doms = defaultdict(int)
    ext_total = 0
    for c in inn[nid]:
        if DBOF(c) != db:
            caller_doms[DB2DOM.get(DBOF(c), DBOF(c))] += 1
            ext_total += 1
    if ext_total == 0:
        return [{"dom": "app", "n": 0}]     # canal / batch / JDBC directo
    return [{"dom": d, "n": n} for d, n in sorted(caller_doms.items(), key=lambda x: -x[1])[:5]]

result = {}
summary = []
for dom, meta in DOMS.items():
    db = meta["db"]
    dom_ids = [nid for nid, n in nodes.items() if n["db"] == db]

    # ── JOURNEYS ORQUESTADORES: fan_out>=2 (orquesta cadena) ──────
    # score prioriza callers cross-domain (journey inter-dominio) y fan_out (riqueza de cadena)
    orch = []
    for nid in dom_ids:
        fo = nodes[nid]["fan_out"]
        if fo >= 2:
            ext = len([c for c in inn[nid] if DBOF(c) != db])
            orch.append((nid, ext, fo, fo * 2 + ext * 3))
    orch.sort(key=lambda x: -x[3])
    orch = orch[:10]

    journeys = []
    for nid, ext_n, fo, _ in orch:
        phrase, _flag, estado = compose(NM(nid))
        journeys.append({
            "id": nid, "sp": NM(nid), "biz": phrase, "biz_estado": estado,
            "ext_callers": ext_n, "fan_out": fo, "loc": LOC(nid),
            "reg": bool(REG_NAME.search(NM(nid))),
            "triggered_by": triggered_by(nid, db),
            "steps": build_chain(nid, db, MAX_DEPTH, {nid}),
        })

    # ── SERVICIOS EXPUESTOS: sinks (fan_out=0) con alto fan_in externo ──
    exposed = []
    for nid in dom_ids:
        if nodes[nid]["fan_out"] == 0:
            ext = len([c for c in inn[nid] if DBOF(c) != db])
            if ext >= 20:
                exposed.append((nid, ext))
    exposed.sort(key=lambda x: -x[1])
    exposed_services = []
    for nid, ext_n in exposed[:6]:
        phrase, _flag, estado = compose(NM(nid))
        exposed_services.append({
            "id": nid, "sp": NM(nid), "biz": phrase, "biz_estado": estado,
            "ext_callers": ext_n, "loc": LOC(nid),
            "reg": bool(REG_NAME.search(NM(nid))),
            "triggered_by": triggered_by(nid, db),
        })

    result[dom] = {**meta, "sp_count": len(dom_ids),
                   "journeys": journeys, "exposed": exposed_services}
    summary.append((dom, meta["name"], len(dom_ids), len(journeys), len(exposed_services)))

with open(BASE + "portal/data/journeys-data.json", "w", encoding="utf-8") as f:
    json.dump(result, f, ensure_ascii=False, separators=(",", ":"))

print("journeys-data.json escrito.\n")
print(f"{'Dom':4} {'Nombre':22} {'SPs':>5} {'Journeys':>9} {'Expuestos':>10}")
for dom, name, spc, jc, ec in summary:
    print(f"{dom:4} {name:22} {spc:5} {jc:9} {ec:10}")
tot = sum(len(v['journeys']) for v in result.values())
tote = sum(len(v['exposed']) for v in result.values())
print(f"\nTotal journeys orquestadores: {tot} · servicios expuestos: {tote}")
import os
print("Tamaño JSON:", os.path.getsize(BASE + 'portal/data/journeys-data.json'), "bytes")
