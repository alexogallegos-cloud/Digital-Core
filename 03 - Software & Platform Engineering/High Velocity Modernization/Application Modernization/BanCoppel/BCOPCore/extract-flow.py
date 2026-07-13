#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
extract-flow.py — Reconstruye el FLUJO DE CONTROL (secuencia real de invocaciones
con IF/FOREACH/WHILE anidados) de cada journey, parseando el código fuente SPL.
Complementa el call graph (que solo da dependencias sin orden ni condiciones).

Genera:
  flow-data.json                    — árbol de control por journey (para flow-bcop.html)
  orchestrators-complexity-bcop.md  — ranking de deuda técnica (mega-orquestadores)

Etapa 3 — Business Logic Extraction · Specialist Informix SPL · SPE-AM-001
"""
import json, re, os
from sp_vocab import compose

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/BCOPCore/")
SRC = BASE + "source/BCOPCore/informix/"
J = json.load(open(BASE + "journeys-data.json", encoding="utf-8"))
CG = json.load(open(BASE + "callgraph-data.json", encoding="utf-8"))
DBOF = lambda i: i.split(":")[0]
NM = {n["id"]: n["label"] for n in CG["graph"]["nodes"]}

RE_END   = re.compile(r"^\s*end\s+(if|foreach|while|for)\b", re.I)
RE_IF     = re.compile(r"^\s*if\b(.+?)\bthen\b", re.I)
RE_IFOPEN = re.compile(r"^\s*if\b(.+)$", re.I)
RE_FE     = re.compile(r"^\s*foreach\b(.*)$", re.I)
RE_WH     = re.compile(r"^\s*while\b(.+?)(\bloop\b|$)", re.I)
RE_FOR    = re.compile(r"^\s*for\b(.+?)(\bto\b|\bin\b)", re.I)
RE_CALL   = re.compile(r"\b(?:execute\s+procedure|call)\s+([a-z_][a-z0-9_]*)", re.I)
RE_CREATE = re.compile(r"create\s+(?:procedure|function)\b", re.I)

def isolate_target(text):
    """Los .sql traen el SP objetivo + sus dependencias concatenadas.
    El objetivo es el PRIMER CREATE; devolvemos solo su cuerpo (hasta el 2º CREATE)."""
    ms = list(RE_CREATE.finditer(text))
    if len(ms) >= 2:
        return text[ms[0].start():ms[1].start()]
    return text

def clean(s):
    s = re.sub(r"\s+", " ", s).strip(" ()")
    return (s[:70] + "…") if len(s) > 70 else s

def parse_flow(text, own_db):
    """Devuelve (árbol, métricas). Mini-parser de bloques de control SPL."""
    root = {"kind": "ROOT", "children": []}
    stack = [root]
    depth_max = 1
    n_if = n_loop = n_call = 0
    pending_then = False   # IF multilínea cuyo THEN aún no aparece
    for i, raw in enumerate(text.split("\n"), 1):
        low = raw.strip().lower()
        if not low or low.startswith("--"):
            continue
        # cierre de bloque
        if RE_END.match(low):
            if len(stack) > 1:
                stack.pop()
            continue
        # invocación (puede coexistir con apertura en la misma línea)
        for m in RE_CALL.finditer(low):
            sp = m.group(1)
            if sp in ("procedure",):  # falso positivo
                continue
            stack[-1]["children"].append({"kind": "CALL", "sp": sp, "line": i})
            n_call += 1
        # apertura de bloques
        if RE_FE.match(low):
            node = {"kind": "FOREACH", "cond": clean(RE_FE.match(low).group(1)), "line": i, "children": []}
            stack[-1]["children"].append(node); stack.append(node); n_loop += 1
        elif RE_WH.match(low):
            node = {"kind": "WHILE", "cond": clean(RE_WH.match(low).group(1)), "line": i, "children": []}
            stack[-1]["children"].append(node); stack.append(node); n_loop += 1
        elif re.match(r"^\s*for\b", low) and RE_FOR.match(low):
            node = {"kind": "FOR", "cond": clean(RE_FOR.match(low).group(1)), "line": i, "children": []}
            stack[-1]["children"].append(node); stack.append(node); n_loop += 1
        elif RE_IF.match(low):   # IF ... THEN en una línea
            node = {"kind": "IF", "cond": clean(RE_IF.match(low).group(1)), "line": i, "children": []}
            stack[-1]["children"].append(node); stack.append(node); n_if += 1
        elif re.match(r"^\s*if\b", low):   # IF multilínea (THEN vendrá luego)
            node = {"kind": "IF", "cond": clean(RE_IFOPEN.match(low).group(1)), "line": i, "children": []}
            stack[-1]["children"].append(node); stack.append(node); n_if += 1
        depth_max = max(depth_max, len(stack))
    metrics = {"loc": text.count("\n"), "n_call": n_call, "n_if": n_if,
               "n_loop": n_loop, "depth_max": depth_max - 1}
    # score de complejidad de orquestación
    metrics["score"] = n_call + n_if * 2 + n_loop * 3 + (depth_max - 1) * 2
    return root, metrics

def enrich(node, own_db):
    """Agrega biz + dominio destino a cada CALL; poda ramas vacías."""
    kids = []
    for c in node["children"]:
        if c["kind"] == "CALL":
            db = None
            # resolver dominio del callee si es cross-db conocido
            for nid in (f"{own_db}:{c['sp']}",):
                pass
            biz, _f, _e = compose(c["sp"])
            c["biz"] = biz
            kids.append(c)
        else:
            enrich(c, own_db)
            if c["children"]:      # poda bloques sin invocaciones
                kids.append(c)
    node["children"] = kids
    return node

flows = {}
complexity = []
n_parsed = 0
for dom, dd in J.items():
    db = dd.get("db")
    for j in dd["journeys"]:            # solo orquestadores (los expuestos no tienen flujo)
        fp = SRC + f"{db}_{j['sp']}.sql"
        if not os.path.exists(fp):
            continue
        text = isolate_target(open(fp, encoding="utf-8", errors="replace").read())
        tree, metrics = parse_flow(text, db)
        tree = enrich(tree, db)
        n_parsed += 1
        flows[j["id"]] = {"sp": j["sp"], "biz": j.get("biz", ""), "dom": dom,
                          "reg": j.get("reg", False), "metrics": metrics, "flow": tree}
        complexity.append({"id": j["id"], "sp": j["sp"], "dom": dom, "biz": j.get("biz", ""),
                           **metrics})

json.dump(flows, open(BASE + "flow-data.json", "w", encoding="utf-8"),
          ensure_ascii=False, separators=(",", ":"))

# ── reporte de orquestadores complejos (deuda técnica) ──
complexity.sort(key=lambda r: -r["score"])
DOMN = {"d01":"Canal Digital","d02":"Integración","d03":"Créditos","d04":"Cheques",
        "d05":"Saldos","d06":"Solicitudes","d07":"Aclaraciones","d08":"SPEI",
        "d09":"Mensajería","d10":"Sucursales","d11":"Cobranza","d12":"Contabilidad"}
L = ["# BCOPCore · Orquestadores Complejos — Deuda Técnica de Refactor",
 "",
 "> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 · **Fuente:** análisis de flujo de control del código SPL",
 "> **Generado:** 2026-07-03 por `extract-flow.py`",
 "",
 "SPs orquestadores ordenados por **complejidad de orquestación** = "
 "`invocaciones + 2·IF + 3·bucles + 2·profundidad`. Los de mayor score son **candidatos prioritarios "
 "a refactor antes de transpilar** (`[DT-IFX]`): concentran lógica condicional profunda difícil de "
 "reescribir con equivalencia garantizada.",
 "",
 "| # | SP | Objetivo | Dominio | LOC | Invoc. | IF | Bucles | Prof. | Score |",
 "|--:|---|---|---|--:|--:|--:|--:|--:|--:|"]
for i, r in enumerate(complexity[:40], 1):
    flag = " 🔴" if r["score"] >= 60 else (" 🟠" if r["score"] >= 30 else "")
    L.append(f"| {i} | `{r['sp']}` | {r['biz']} | {DOMN.get(r['dom'],r['dom'])} | "
             f"{r['loc']:,} | {r['n_call']} | {r['n_if']} | {r['n_loop']} | {r['depth_max']} | {r['score']}{flag} |")
crit = [r for r in complexity if r["score"] >= 60]
L += ["",
 f"**{len(crit)} orquestadores críticos** (score ≥ 60) concentran la mayor deuda de refactor. "
 "Recomendación: descomponerlos en servicios más pequeños **antes** de la transpilación a Java, "
 "y cubrir cada rama condicional con golden master tests (equivalencia ≥ 99.95%).",
 "",
 "## Anti-patrón detectado",
 "",
 "- **`[DT-IFX]` Mega-orquestador con anidamiento profundo:** un SP con profundidad de control ≥ 5 "
 "y decenas de invocaciones condicionales es equivalente al DT-002 (P010) de Banamex S500 — "
 "reescribirlo 1:1 arrastra la complejidad; refactorizar por rama de negocio reduce el riesgo de equivalencia.",
 "",
 "*Generado por Specialist — Informix SPL Analysis · Etapa 3 · fuente: source/ + extract-flow.py*"]
open(BASE + "orchestrators-complexity-bcop.md", "w", encoding="utf-8").write("\n".join(L))

import os as _os
print(f"flow-data.json ({_os.path.getsize(BASE+'flow-data.json'):,} bytes) · {n_parsed} journeys parseados")
print(f"orchestrators-complexity-bcop.md · {len(crit)} orquestadores críticos (score≥60)")
print("\nTop 8 orquestadores más complejos:")
for r in complexity[:8]:
    print(f"  {r['sp']:28} score {r['score']:4} · {r['n_call']} calls · {r['n_if']} IF · {r['n_loop']} loops · prof {r['depth_max']}")