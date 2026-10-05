#!/usr/bin/env python3
"""
Liverpool — Métricas de Programa + Dependencias (Módulo Importaciones)
----------------------------------------------------------------------
Calcula, por programa ABAP: tamaño, estructura, acoplamiento de datos,
integración, superficie de validación; deriva un score de complejidad,
una hipótesis 7R y un score de prioridad de migración. Además detecta
dependencias programa→programa vía tablas Z compartidas (write→read).

Reads  source/Source Code SAP/*  +  portal/data/{interfaces,table-lineage,rules-bronze}-liv.json
Writes portal/data/program-metrics-liv.json
"""
import re, json, glob, os
from pathlib import Path
from datetime import date

HERE  = Path(__file__).parent
BRAIN = HERE.parent
SRC   = BRAIN / "source" / "Source Code SAP"
DATA  = BRAIN / "portal" / "data"
OUTJ  = DATA / "program-metrics-liv.json"

DOM = {
    "ZIMFIC002": ("R07","Finanzas y Contabilidad"), "ZIMPOB010B": ("R04","Cadena de Suministro"),
    "ZIMPOC001": ("R04","Cadena de Suministro"), "ZIMPOC002": ("R01","Gestión Comercial"),
    "ZIMPOC003": ("R01","Gestión Comercial"), "ZIMPOC005": ("R04","Cadena de Suministro"),
    "ZIMPOC007": ("R04","Cadena de Suministro"), "ZIMPOC023": ("R04","Cadena de Suministro"),
    "ZIMPOC024": ("R04","Cadena de Suministro"), "ZRTPOC079": ("R04","Cadena de Suministro"),
    "ZRTPOC079N": ("R04","Cadena de Suministro"), "ZRT_PO_REP_EPI_BD": ("R07","Finanzas y Contabilidad"),
}

iface = json.loads((DATA / "interfaces-liv.json").read_text(encoding="utf-8"))
lin   = json.loads((DATA / "table-lineage-liv.json").read_text(encoding="utf-8"))
rules = json.loads((DATA / "rules-bronze-liv.json").read_text(encoding="utf-8"))

# ── métricas por programa desde JSONs previos ─────────────────────────────────
rfc_by, s4_by, tab_by, tabw_by, ztab_read, ztab_write = {}, {}, {}, {}, {}, {}
for e in iface["edges"]:
    if e["cat"] in ("BAPI", "Z-CUSTOM", "RFC"):
        rfc_by[e["prog"]] = rfc_by.get(e["prog"], 0) + 1
s4_tabs = {t["tab"] for t in lin["tables"] if t["s4"]}
for e in lin["edges"]:
    p, tab, op = e["prog"], e["tab"], e["op"]
    tab_by.setdefault(p, set()).add(tab)
    if op == "W":
        tabw_by.setdefault(p, set()).add(tab)
        if tab.startswith(("z", "y")): ztab_write.setdefault(tab, set()).add(p)
    if tab in s4_tabs: s4_by.setdefault(p, set()).add(tab)
    if op == "R" and tab.startswith(("z", "y")): ztab_read.setdefault(tab, set()).add(p)
rules_by, reg_by = {}, {}
for r in rules["rules"]:
    rules_by[r["prog"]] = rules_by.get(r["prog"], 0) + 1
    if r["reg"]: reg_by[r["prog"]] = reg_by.get(r["prog"], 0) + 1

# ── métricas crudas del código ────────────────────────────────────────────────
progs = sorted(f for f in glob.glob(str(SRC / "*")) if os.path.isfile(f) and not f.endswith(".xlsx"))
raw = {}
for p in progs:
    n = os.path.basename(p); t = open(p, encoding="latin-1").read(); L = t.splitlines()
    raw[n] = {
        "loc":     sum(1 for x in L if x.strip() and not x.strip().startswith("*")),
        "forms":   len(re.findall(r"^\s*form\s+\w", t, re.I | re.M)),
        "performs":len(re.findall(r"\bperform\b", t, re.I)),
        "screens": len(re.findall(r"call\s+screen", t, re.I)),
        "messages":len(re.findall(r"\bmessage\b", t, re.I)),
        "is_report": bool(re.search(r"\b(REP|EPI)\b", n)) or "REPORT" in t[:400].upper() and "screen" not in t.lower()[:2000],
    }

# ── normalización + score de complejidad ──────────────────────────────────────
def col(k):  return {n: raw[n][k] for n in raw}
def mx(d):   return max(d.values()) or 1

W = {"loc":0.24, "forms":0.14, "performs":0.14, "screens":0.10, "messages":0.10, "tables":0.16, "rfc":0.12}
mxv = {
    "loc": mx(col("loc")), "forms": mx(col("forms")), "performs": mx(col("performs")),
    "screens": mx(col("screens")), "messages": mx(col("messages")),
    "tables": max((len(tab_by.get(n, set())) for n in raw), default=1) or 1,
    "rfc": max(rfc_by.values() or [1]),
}

def r7(prog, cx, s4n, scr, rfc):
    if raw[prog]["loc"] < 20:
        return ("Retire", "Shell vacío — solo INCLUDEs; sin lógica propia que migrar")
    if raw[prog]["is_report"] and cx < 45:
        return ("Replatform", "Reporte — reconstruir como CDS View / Fiori analytical en S/4HANA")
    if cx >= 62 or scr >= 5:
        return ("Refactor", "Alta complejidad / UI dynpro pesada — descomponer y rediseñar (Fiori/RAP)")
    if rfc >= 8 or s4n >= 3:
        return ("Refactor", "Integración densa / múltiples Simplification Items — remediar modelo de datos")
    if cx <= 32:
        return ("Retain+Remediate", "Bajo acoplamiento — conservar y remediar incompatibilidades S/4")
    return ("Replatform", "Complejidad media — ajustar a S/4 (BP, ACDOCA, longitudes de campo)")

items = []
for n in raw:
    tabs_n = len(tab_by.get(n, set())); rfc_n = rfc_by.get(n, 0)
    s4_n = len(s4_by.get(n, set()))
    comp = {
        "loc":     raw[n]["loc"]      / mxv["loc"],
        "forms":   raw[n]["forms"]    / mxv["forms"],
        "performs":raw[n]["performs"] / mxv["performs"],
        "screens": raw[n]["screens"]  / mxv["screens"],
        "messages":raw[n]["messages"] / mxv["messages"],
        "tables":  tabs_n             / mxv["tables"],
        "rfc":     rfc_n              / mxv["rfc"],
    }
    cx = round(sum(comp[k] * W[k] for k in W) * 100, 1)
    hyp, why = r7(n, cx, s4_n, raw[n]["screens"], rfc_n)
    items.append({
        "prog": n, "dom": DOM[n][0], "dom_label": DOM[n][1],
        "loc": raw[n]["loc"], "forms": raw[n]["forms"], "performs": raw[n]["performs"],
        "screens": raw[n]["screens"], "messages": raw[n]["messages"],
        "tables": tabs_n, "tables_w": len(tabw_by.get(n, set())),
        "rfc": rfc_n, "s4_tables": s4_n, "rules": rules_by.get(n, 0),
        "reg": reg_by.get(n, 0),
        "complexity": cx,
        "breakdown": {k: round(comp[k] * W[k] * 100, 1) for k in W},
        "r7": hyp, "r7_why": why,
    })

# ── dependencias programa→programa vía tablas Z (write → read) ─────────────────
edges = {}
for tab, writers in ztab_write.items():
    readers = ztab_read.get(tab, set())
    for w in writers:
        for r in readers:
            if w != r:
                k = (w, r)
                edges.setdefault(k, {"tables": [], "n": 0})
                edges[k]["tables"].append(tab); edges[k]["n"] += 1
dep_edges = [{"from": w, "to": r, "n": v["n"], "tables": sorted(v["tables"])}
             for (w, r), v in sorted(edges.items(), key=lambda x: -x[1]["n"])]

# fan-in / fan-out
fin, fout = {}, {}
for e in dep_edges:
    fout[e["from"]] = fout.get(e["from"], 0) + 1
    fin[e["to"]]    = fin.get(e["to"], 0) + 1
for it in items:
    it["fan_in"]  = fin.get(it["prog"], 0)
    it["fan_out"] = fout.get(it["prog"], 0)

# ── score de prioridad de migración ───────────────────────────────────────────
mx_cx  = max(i["complexity"] for i in items) or 1
mx_fin = max((i["fan_in"] for i in items), default=1) or 1
mx_s4  = max((i["s4_tables"] for i in items), default=1) or 1
for it in items:
    crit = (0.50 * it["complexity"] / mx_cx +
            0.20 * (1 if it["reg"] else 0) +
            0.20 * it["fan_in"] / mx_fin +
            0.10 * it["s4_tables"] / mx_s4)
    it["priority"] = round(crit * 100, 1)
items.sort(key=lambda x: -x["priority"])
for i, it in enumerate(items, 1):
    it["rank"] = i

payload = {
    "meta": {"generated": str(date.today()), "programs": len(items),
             "weights": W, "dep_edges": len(dep_edges)},
    "programs": items,
    "dependencies": dep_edges,
}
OUTJ.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
print(f"metrics -> {OUTJ.name}: {len(items)} programs / {len(dep_edges)} dep-edges")
print("  top priority:", ", ".join(f"{i['prog']}({i['priority']})" for i in items[:5]))
print("  7R:", {h: sum(1 for i in items if i['r7'] == h) for h in {i['r7'] for i in items}})
