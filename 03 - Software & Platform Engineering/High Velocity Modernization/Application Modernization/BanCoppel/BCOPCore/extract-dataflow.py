#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
extract-dataflow.py — Análisis de SCOPE / data-flow de los identificadores del código:
distingue lo que TRASCIENDE (parámetros = contrato API · columnas/tablas = persistencia BD)
de lo EFÍMERO (variables DEFINE locales). Las efímeras de CÁLCULO/DECISIÓN revelan reglas.

Cruza el resultado con el vocabulario: marca cada término como TRASCIENDE-API / TRASCIENDE-BD
/ EFÍMERA / MIXTO, y agrega el campo "scope" a vocabulary-inventory.json.

Genera: dataflow-scope-bcop.md · enriquece vocabulary-inventory.json
Etapa 3 — Business Logic Extraction · Specialist Informix SPL · SPE-AM-001
"""
import json, re, os
from collections import defaultdict, Counter
import sp_vocab

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/BCOPCore/")
SRC = BASE + "source/BCOPCore/informix/"
CG = json.load(open(BASE + "callgraph-data.json", encoding="utf-8"))

RE_CREATE = re.compile(r"create\s+(?:procedure|function)\b", re.I)
RE_SIG    = re.compile(r"create\s+(?:procedure|function)\s+[^(]*\(([^;]*?)\)\s*returning\s+([^;]+)", re.I | re.S)
RE_DEFINE = re.compile(r"\bdefine\s+(\w+)\s+", re.I)
RE_TABLE  = re.compile(r"\b(?:from|into|update|join)\s+(?:(bdi[a-z]+|intercard\w*)\s*:)?\s*(?:\"?informix\"?\.)?(\w+)", re.I)
RE_LETCALC= re.compile(r"\b(?:let|set)\s+(\w+)\s*=\s*[^;]*[*/][^;]*", re.I)
RE_IFVAR  = re.compile(r"\bif\b[^;]*?\b(v\w+|c\w+|i\w+)\b", re.I)
TIPOS = {"char","varchar","nchar","nvarchar","lvarchar","integer","int","smallint","int8","bigint",
         "money","decimal","numeric","float","smallfloat","real","date","datetime","interval",
         "boolean","serial","serial8","text","byte","year","to","second","fraction","hour"}

def isolate(t):
    ms = list(RE_CREATE.finditer(t))
    return t[ms[0].start():ms[1].start()] if len(ms) >= 2 else t

def parse_params(sigtxt):
    out = []
    for chunk in sigtxt.split(","):
        m = re.match(r"\s*([a-zA-Z_]\w+)\s+\w", chunk)
        if m and m.group(1).lower() not in TIPOS:
            out.append(m.group(1))
    return out

def dehung(p):
    core = re.sub(r"^(p|c|v|w|i|m|d|n|b|f|dt|arr|o|s|l)([A-Z_])", r"\2", p)
    return core.lstrip("_").lower()

# scope por término del vocabulario: cuenta apariciones en cada scope
term_scope = defaultdict(lambda: Counter())   # term -> {API, BD, LOCAL, LOCAL_CALC}
id_scope = Counter()                          # conteo global de identificadores por scope
n_sp = 0

def toks(idn):
    return [t for t in sp_vocab.tokenize(dehung(idn)) if not t.startswith("?") and len(t) > 2]

for node in CG["graph"]["nodes"]:
    db, sp = node["id"].split(":", 1)
    fp = SRC + f"{db}_{sp}.sql"
    if not os.path.exists(fp):
        continue
    txt = isolate(open(fp, encoding="utf-8", errors="replace").read())
    n_sp += 1
    low = txt.lower()

    sig = RE_SIG.search(txt)
    params = parse_params(sig.group(1)) if sig else []
    defines = set(m.lower() for m in RE_DEFINE.findall(txt))
    lets_calc = set(m.lower() for m in RE_LETCALC.findall(txt))
    tablas = set()
    for pref, name in RE_TABLE.findall(txt):
        nm = name.lower()
        if nm in defines or nm in TIPOS or nm in ("dual", "table", "select", "where"):
            continue
        tablas.add(nm)

    # clasificar y cruzar con vocabulario
    for p in params:
        id_scope["API"] += 1
        for t in toks(p):
            term_scope[t]["API"] += 1
    for tb in tablas:
        id_scope["BD"] += 1
        for t in toks(tb):
            term_scope[t]["BD"] += 1
    for v in defines:
        calc = v in lets_calc
        id_scope["LOCAL_CALC" if calc else "LOCAL"] += 1
        for t in toks(v):
            term_scope[t]["LOCAL_CALC" if calc else "LOCAL"] += 1

# ── determinar naturaleza de scope por término ──
def naturaleza(c):
    api, bd, loc, lc = c["API"], c["BD"], c["LOCAL"], c["LOCAL_CALC"]
    trans = api + bd
    local = loc + lc
    tot = trans + local
    if tot == 0:
        return "—", 0
    if trans >= 2 * local:
        return "TRASCIENDE", tot
    if local >= 2 * trans:
        return ("EFÍMERA-CÁLCULO" if lc >= 3 else "EFÍMERA"), tot
    # mixto, pero si participa en varias fórmulas lo marcamos como señal de regla
    if lc >= 5:
        return "EFÍMERA-CÁLCULO", tot
    return "MIXTO", tot

# enriquecer inventario
INVP = BASE + "vocabulary-inventory.json"
INV = json.load(open(INVP, encoding="utf-8"))
def annotate(rows):
    for r in rows:
        c = term_scope.get(r["term"], Counter())
        nat, tot = naturaleza(c)
        r["scope"] = nat
        r["scope_counts"] = {"API": c["API"], "BD": c["BD"], "LOCAL": c["LOCAL"], "LOCAL_CALC": c["LOCAL_CALC"]}
annotate(INV["atomos"]); annotate(INV["compuestos"])
json.dump(INV, open(INVP, "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))

# ── reporte ──
allterms = INV["atomos"] + INV["compuestos"]
bynat = Counter(r["scope"] for r in allterms)
def top(nat, n=25):
    return sorted([r for r in allterms if r["scope"] == nat],
                  key=lambda r: -(sum(r["scope_counts"].values())))[:n]

L = ["# BCOPCore · Análisis de Scope del Vocabulario (efímero vs. trasciende)",
 "",
 "> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 · **Generado:** 2026-07-04 por `extract-dataflow.py`  ",
 f"> Analizados **{n_sp:,} SPs** · {id_scope['API']:,} parámetros (API) · {id_scope['BD']:,} accesos a tabla (BD) · "
 f"{id_scope['LOCAL']+id_scope['LOCAL_CALC']:,} variables locales ({id_scope['LOCAL_CALC']:,} de cálculo)",
 "",
 "Cada término del vocabulario se clasifica por **dónde vive el dato**:",
 "",
 "| Scope | Significado | Uso en modernización |",
 "|-------|-------------|----------------------|",
 "| **TRASCIENDE** | Aparece sobre todo como parámetro (API) o columna (BD) | **Contrato del microservicio target** (entra/sale) |",
 "| **EFÍMERA-CÁLCULO** | Variable local que participa en fórmulas (LET aritmético) | **Regla de negocio** — lógica interna a preservar |",
 "| **EFÍMERA** | Variable local auxiliar (contadores, control) | Lógica interna, no contrato |",
 "| **MIXTO** | Trasciende y también se usa localmente | Revisar caso por caso |",
 "",
 f"**Distribución:** " + " · ".join(f"{k}: {bynat.get(k,0)}" for k in ["TRASCIENDE","EFÍMERA-CÁLCULO","EFÍMERA","MIXTO"]),
 "",
 "---",
 "",
 "## 🟢 Términos que TRASCIENDEN — candidatos al contrato de la API/BD target", "",
 "Datos que entran/salen del SP: definen la **interfaz** del microservicio modernizado.", "",
 "| Término | Significado | API | BD | Local |",
 "|---------|-------------|----:|---:|------:|"]
for r in top("TRASCIENDE"):
    sc = r["scope_counts"]
    L.append(f"| `{r['term']}` | {r['mean']} | {sc['API']} | {sc['BD']} | {sc['LOCAL']+sc['LOCAL_CALC']} |")

L += ["", "---", "",
 "## 🔴 Términos EFÍMEROS-CÁLCULO — señal de reglas de negocio", "",
 "Variables locales que participan en fórmulas: **aquí vive la lógica de negocio** (cálculos de "
 "interés, ISR, comisión, saldo). No son contrato, pero **su fórmula debe preservarse** (golden master).", "",
 "| Término | Significado | En fórmula (LET) | Local total |",
 "|---------|-------------|-----------------:|------------:|"]
for r in top("EFÍMERA-CÁLCULO", 30):
    sc = r["scope_counts"]
    L.append(f"| `{r['term']}` | {r['mean']} | {sc['LOCAL_CALC']} | {sc['LOCAL']+sc['LOCAL_CALC']} |")

L += ["", "---", "",
 "## ⚪ Términos EFÍMEROS auxiliares (control interno)", "",
 "Variables de control/temporales sin cálculo — lógica interna que **no** forma parte del contrato "
 "ni suele ser regla de negocio (códigos de retorno, contadores, banderas técnicas).", "",
 "| Término | Significado | Local |",
 "|---------|-------------|------:|"]
for r in top("EFÍMERA", 20):
    sc = r["scope_counts"]
    L.append(f"| `{r['term']}` | {r['mean']} | {sc['LOCAL']} |")

L += ["", "---", "",
 "## Cómo se usa este análisis", "",
 "1. **TRASCIENDE → contrato target.** Los términos que entran/salen por parámetro o BD definen la "
 "interfaz del microservicio (OpenAPI / esquema de datos). Ej. `cuenta`, `monto`, `numcte` trascienden.",
 "2. **EFÍMERA-CÁLCULO → reglas de negocio.** Variables como `vimp_isr`, `vcalc_int`, `vtasa_isr_tr` son "
 "locales pero llevan la fórmula — se documentan en `business-rules-bcop.md` y requieren golden master exacto.",
 "3. **EFÍMERA → descartable en el contrato.** Códigos de retorno, contadores y banderas técnicas son "
 "detalle de implementación; el target los reescribe libremente.",
 "",
 "> ⚠ **Heurística, no análisis formal de data-flow:** el scope se infiere por dónde aparece el "
 "identificador (firma / tabla / DEFINE). Casos límite (variables reusadas, SQL dinámico) requieren "
 "revisión. La distinción efímero/trasciende es direccional, útil para priorizar el contrato y las reglas.",
 "",
 "*Generado por Specialist — Informix SPL Analysis · Etapa 3 · fuente: source/ + sp_vocab.py*"]

open(BASE + "dataflow-scope-bcop.md", "w", encoding="utf-8").write("\n".join(L))
print(f"dataflow-scope-bcop.md escrito · {n_sp:,} SPs analizados")
print(f"  identificadores: {id_scope['API']:,} API · {id_scope['BD']:,} BD · "
      f"{id_scope['LOCAL']:,} local · {id_scope['LOCAL_CALC']:,} local-cálculo")
print(f"  términos por scope: " + " · ".join(f"{k}:{bynat.get(k,0)}" for k in ['TRASCIENDE','EFÍMERA-CÁLCULO','EFÍMERA','MIXTO']))