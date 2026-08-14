#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
extract-dataflow.py — Scope / data-flow del vocabulario Informix.
v2: 10 tipos de scope.

  PERSISTE-BD     Aparece en INSERT/UPDATE/DELETE — el BC que escribe es el owner
  LECTURA-BD      Solo en SELECT/FROM — consume datos pero no los posee
  INTERFAZ-IN     Parametro de entrada en la firma del SP (contrato de entrada)
  INTERFAZ-OUT    Variable en clausula RETURN (contrato de salida)
  BATCH           Solo en SPs de proceso batch/nocturno (patron de nombre)
  CURSOR          Variable buffer de FOREACH...INTO
  EFIMERA-CALCULO Variable DEFINE local en expresion aritmetica (LET con */+-)
  EFIMERA         Variable DEFINE local auxiliar (control, contadores)
  EXCEPCION       Variable en RAISE EXCEPTION (modelo de error)
  MIXTO           Aparece en multiples contextos a traves del corpus

Senales detectadas por SP (contadores de vocabulario):
  AIN  parametros de entrada (firma CREATE PROCEDURE)
  AOUT variables en RETURN (salida al caller)
  BDR  referencias FROM/JOIN (lectura de tabla)
  BDW  referencias INSERT INTO / UPDATE / DELETE FROM (escritura)
  LOC  variables DEFINE locales sin calculo
  LC   variables DEFINE locales en expresion aritmetica (LET con operador)
  CUR  variables en FOREACH...INTO (buffer de cursor)
  EXC  variables en RAISE EXCEPTION
  BAT  ocurrencias en SPs de tipo batch (todos sus identificadores)

Genera: dataflow-scope-bcop.md  +  enriquece vocabulary-inventory.json
Etapa 3 - Business Logic Extraction - Specialist Informix SPL - SPE-AM-001
"""
import json, re, os
from collections import defaultdict, Counter
import sp_vocab

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - SPE/HVM/AM/BanCoppel/Informix/")
SRC = BASE + "source/informix/"
CG  = json.load(open(BASE + "portal/data/callgraph-data.json", encoding="utf-8"))

# ── patrones de extraccion ──
RE_CREATE   = re.compile(r"create\s+(?:procedure|function)\b", re.I)
# firma con RETURNING
RE_SIG_RET  = re.compile(r"create\s+(?:procedure|function)\s+[^(]*\(([^;]*?)\)\s*returning", re.I | re.S)
# firma sin RETURNING (termina en DEFINE, WITH, comentario o fin)
RE_SIG_NRET = re.compile(r"create\s+(?:procedure|function)\s+[^(]*\(([^;]*?)\)\s*(?:define|with\s|--|\Z)", re.I | re.S)
RE_DEFINE   = re.compile(r"\bdefine\s+(\w+)\s+", re.I)
RE_LETCALC  = re.compile(r"\b(?:let|set)\s+(\w+)\s*=\s*[^;]*[+\-*/][^;]*", re.I)
# BD lectura (FROM / JOIN) — grupo 1 = nombre de tabla
RE_BD_READ  = re.compile(
    r"\b(?:from|join)\s+(?:(?:bdi\w+|intercard\w*)\s*:)?\s*(?:\"?informix\"?\.)?(\w+)\b", re.I)
# BD escritura (INSERT INTO / UPDATE tablename / DELETE FROM)
RE_BD_WRITE = re.compile(
    r"\b(?:(?:insert\s+into|update)\s+(?:(?:bdi\w+|intercard\w*)\s*:)?\s*(?:\"?informix\"?\.)?(\w+)"
    r"|delete\s+from\s+(?:(?:bdi\w+|intercard\w*)\s*:)?\s*(?:\"?informix\"?\.)?(\w+))\b", re.I)
# RETURN statement — extrae variables simples
RE_RETURN   = re.compile(r"\breturn\s+([a-z_]\w*(?:\s*,\s*[a-z_]\w*)*)\s*;", re.I)
# FOREACH cursor INTO v1, v2
RE_FOREACH  = re.compile(r"\bforeach\s+\w+(?:\s+\w+)?\s+into\s+((?:[a-z_]\w*(?:\s*,\s*)?)+)", re.I)
# RAISE EXCEPTION -nnn, -nnn, variable
RE_RAISE    = re.compile(r"\braise\s+exception\s+(?:-?\d+\s*,\s*-?\d+\s*,\s*)?([a-z_]\w*)", re.I)
# patron de SP batch/nocturno
BATCH_PAT   = re.compile(r"_(?:noc|lote|msv|masivo|cierr|cierre|batch)(?:_|\d*$)", re.I)

TIPOS = {"char","varchar","nchar","nvarchar","lvarchar","integer","int","smallint","int8","bigint",
         "money","decimal","numeric","float","smallfloat","real","date","datetime","interval",
         "boolean","serial","serial8","text","byte","year","to","second","fraction","hour"}
SKIP = {"dual","table","select","where","informix","set","temp","update","delete","insert","from","join"} | TIPOS

# ── helpers ──
def isolate(txt):
    ms = list(RE_CREATE.finditer(txt))
    return txt[ms[0].start():ms[1].start()] if len(ms) >= 2 else txt

def parse_params(txt):
    m = RE_SIG_RET.search(txt) or RE_SIG_NRET.search(txt)
    if not m: return []
    out = []
    for chunk in m.group(1).split(","):
        pm = re.match(r"\s*([a-zA-Z_]\w+)\s+\w", chunk)
        if pm and pm.group(1).lower() not in TIPOS:
            out.append(pm.group(1))
    return out

def parse_list(txt, pattern):
    out = []
    for m in pattern.finditer(txt):
        for chunk in m.group(1).split(","):
            nm = chunk.strip()
            if re.match(r'^[a-z_]\w*$', nm, re.I) and nm.lower() not in SKIP:
                out.append(nm)
    return out

def parse_tables_read(txt):
    out = set()
    for m in RE_BD_READ.finditer(txt):
        nm = m.group(1).lower()
        if nm and nm not in SKIP and not nm[0].isdigit() and len(nm) > 2:
            out.add(nm)
    return out

def parse_tables_write(txt):
    out = set()
    for m in RE_BD_WRITE.finditer(txt):
        nm = (m.group(1) or m.group(2) or "").lower()
        if nm and nm not in SKIP and not nm[0].isdigit() and len(nm) > 2:
            out.add(nm)
    return out

def dehung(p):
    core = re.sub(r"^(p|c|v|w|i|m|d|n|b|f|dt|arr|o|s|l)([A-Z_])", r"\2", p)
    return core.lstrip("_").lower()

def toks(idn):
    return [t for t in sp_vocab.tokenize(dehung(idn)) if not t.startswith("?") and len(t) > 2]

# ── scan del corpus ──
term_scope = defaultdict(Counter)   # term -> {AIN, AOUT, BDR, BDW, LOC, LC, CUR, EXC, BAT}
id_scope   = Counter()
n_sp = 0

for node in CG["graph"]["nodes"]:
    db, sp = node["id"].split(":", 1)
    fp = SRC + f"{db}_{sp}.sql"
    if not os.path.exists(fp):
        continue
    txt = isolate(open(fp, encoding="utf-8", errors="replace").read())
    n_sp += 1

    is_batch = bool(BATCH_PAT.search(sp))

    params      = parse_params(txt)
    defines_raw = {m.lower() for m in RE_DEFINE.findall(txt)}
    lets_calc   = {m.lower() for m in RE_LETCALC.findall(txt)}
    ret_vars    = parse_list(txt, RE_RETURN)
    cursor_vars = parse_list(txt, RE_FOREACH)
    exc_vars    = [m.group(1).lower() for m in RE_RAISE.finditer(txt)
                   if m.group(1).lower() not in SKIP]
    bd_read     = parse_tables_read(txt)  - defines_raw
    bd_write    = parse_tables_write(txt) - defines_raw

    # conteo global de identificadores
    id_scope["AIN"]  += len(params)
    id_scope["AOUT"] += len(ret_vars)
    id_scope["BDR"]  += len(bd_read)
    id_scope["BDW"]  += len(bd_write)
    id_scope["CUR"]  += len(cursor_vars)
    id_scope["EXC"]  += len(exc_vars)
    id_scope["LC"]   += sum(1 for v in defines_raw if v in lets_calc)
    id_scope["LOC"]  += sum(1 for v in defines_raw if v not in lets_calc)

    def add(items, key):
        for idn in items:
            for t in toks(idn):
                term_scope[t][key] += 1
                if is_batch:
                    term_scope[t]["BAT"] += 1

    add(params,      "AIN")
    add(ret_vars,    "AOUT")
    add(bd_read,     "BDR")
    add(bd_write,    "BDW")
    add(cursor_vars, "CUR")
    add(exc_vars,    "EXC")
    for v in defines_raw:
        key = "LC" if v in lets_calc else "LOC"
        for t in toks(v):
            term_scope[t][key] += 1
            if is_batch:
                term_scope[t]["BAT"] += 1

# ── clasificacion 10 tipos ──
def scope_10(c):
    ain  = c.get("AIN",  0)
    aout = c.get("AOUT", 0)
    bdr  = c.get("BDR",  0)
    bdw  = c.get("BDW",  0)
    loc  = c.get("LOC",  0)
    lc   = c.get("LC",   0)
    cur  = c.get("CUR",  0)
    exc  = c.get("EXC",  0)
    bat  = c.get("BAT",  0)

    trans    = ain + aout + bdr + bdw
    local    = loc + lc
    special  = cur + exc
    total    = trans + local + special
    # BAT no se suma al total — es un modificador transversal

    if total == 0:
        return "—", 0

    def pct(x): return x / total

    # --- dominancia unica (>= 60% del total) ---
    if pct(bdw)  >= 0.60:                    return "PERSISTE-BD",     total
    if pct(bdr)  >= 0.60 and bdw == 0:       return "LECTURA-BD",      total
    if pct(aout) >= 0.60:                    return "INTERFAZ-OUT",     total
    if pct(ain)  >= 0.60:                    return "INTERFAZ-IN",      total
    if pct(cur)  >= 0.60:                    return "CURSOR",           total
    if pct(exc)  >= 0.60:                    return "EXCEPCION",        total
    if pct(lc)   >= 0.60:                    return "EFIMERA-CALCULO",  total
    if pct(loc)  >= 0.60:                    return "EFIMERA",          total
    # BATCH: dominante si > 70% de apariciones son en contexto batch
    # (BAT puede duplicar conteos, usamos ratio conservador)
    if bat > 0 and bat >= 1.5 * total:       return "BATCH",           total

    # --- puro local (sin ninguna senal transciende) ---
    if trans == 0 and special == 0:
        return ("EFIMERA-CALCULO" if lc >= loc else "EFIMERA"), total

    # --- puro transciende (sin local ni especial) ---
    if local == 0 and special == 0:
        best = max([("PERSISTE-BD", bdw), ("LECTURA-BD", bdr if bdw == 0 else 0),
                    ("INTERFAZ-IN", ain), ("INTERFAZ-OUT", aout)], key=lambda x: x[1])
        if best[1] > 0: return best[0], total

    # --- grupo dominante (ratio >= 2.5x) ---
    if local >= 2.5 * (trans + special):
        return ("EFIMERA-CALCULO" if lc >= loc else "EFIMERA"), total
    if trans >= 2.5 * (local + special):
        best = max([("PERSISTE-BD", bdw), ("LECTURA-BD", bdr if bdw == 0 else 0),
                    ("INTERFAZ-IN", ain), ("INTERFAZ-OUT", aout)], key=lambda x: x[1])
        if best[1] > 0: return best[0], total

    return "MIXTO", total

# ── enriquecer inventario ──
INVP = BASE + "knowledge-base/vocabulary-inventory.json"
INV  = json.load(open(INVP, encoding="utf-8"))

SIGNAL_KEYS = ("AIN", "AOUT", "BDR", "BDW", "LOC", "LC", "CUR", "EXC", "BAT")

def annotate(rows):
    for r in rows:
        c = term_scope.get(r["term"], Counter())
        nat, tot = scope_10(c)
        r["scope"] = nat
        r["scope_counts"] = {k: c.get(k, 0) for k in SIGNAL_KEYS}

annotate(INV["atomos"])
annotate(INV["compuestos"])
json.dump(INV, open(INVP, "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))

# ── reporte MD ──
allterms = INV["atomos"] + INV["compuestos"]
bynat    = Counter(r["scope"] for r in allterms)

SCOPE_META = [
    ("PERSISTE-BD",     "BD — escritura", "El BC que escribe es el OWNER. Contrato de datos del microservicio."),
    ("LECTURA-BD",      "BD — lectura",   "Consume datos ajenos. Patron de query en el target."),
    ("INTERFAZ-IN",     "API entrada",    "Parametro de entrada. Define el request contract."),
    ("INTERFAZ-OUT",    "API salida",     "Variable de RETURN. Define el response contract."),
    ("BATCH",           "Batch",          "Solo en jobs nocturnos/masivos. Lifecycle diferente al OLTP."),
    ("CURSOR",          "Cursor",         "Buffer de fila en FOREACH. No es contrato, es detalle de impl."),
    ("EFIMERA-CALCULO", "Efimera calculo","Variable local aritmetica. Aqui vive la regla de negocio."),
    ("EFIMERA",         "Efimera",        "Variable local auxiliar. Detalle de implementacion."),
    ("EXCEPCION",       "Excepcion",      "Variable de error. Define el error model del microservicio."),
    ("MIXTO",           "Mixto",          "Multiples roles. Requiere analisis de desambiguacion."),
]

def top_terms(scope_type, n=20):
    return sorted([r for r in allterms if r["scope"] == scope_type],
                  key=lambda r: -sum(r.get("scope_counts", {}).values()))[:n]

L = [
    "# Informix - Scope del Vocabulario (10 tipos)",
    "",
    f"> **Corpus:** {n_sp:,} SPs analizados  ",
    f"> **Identificadores:** "
    f"AIN={id_scope['AIN']:,}  AOUT={id_scope['AOUT']:,}  "
    f"BDR={id_scope['BDR']:,}  BDW={id_scope['BDW']:,}  "
    f"LOC={id_scope['LOC']:,}  LC={id_scope['LC']:,}  "
    f"CUR={id_scope['CUR']:,}  EXC={id_scope['EXC']:,}",
    "",
    "## Distribucion por tipo de scope",
    "",
    "| Tipo | N | Descripcion |",
    "|------|--:|-------------|",
]
for sc, label, desc in SCOPE_META:
    n = bynat.get(sc, 0)
    if n > 0:
        L.append(f"| **{sc}** | {n} | {desc} |")
L.append(f"| — (sin senal) | {bynat.get('—',0)} | No aparece en ningun SP del corpus |")

for sc, label, desc in SCOPE_META:
    n = bynat.get(sc, 0)
    if n == 0: continue
    terms = top_terms(sc)
    if not terms: continue
    L += ["", "---", "", f"## {label} — {sc} ({n} terminos)", "", desc, ""]

    if sc in ("PERSISTE-BD", "LECTURA-BD"):
        L += ["| Termino | Significado | BDR | BDW | API |", "|---------|-------------|----:|----:|----:|"]
        for r in terms:
            sc2 = r.get("scope_counts", {})
            L.append(f"| `{r['term']}` | {r.get('mean','')} | {sc2.get('BDR',0)} | {sc2.get('BDW',0)} | {sc2.get('AIN',0)+sc2.get('AOUT',0)} |")
    elif sc in ("INTERFAZ-IN", "INTERFAZ-OUT"):
        L += ["| Termino | Significado | AIN | AOUT | BD |", "|---------|-------------|----:|-----:|---:|"]
        for r in terms:
            sc2 = r.get("scope_counts", {})
            L.append(f"| `{r['term']}` | {r.get('mean','')} | {sc2.get('AIN',0)} | {sc2.get('AOUT',0)} | {sc2.get('BDR',0)+sc2.get('BDW',0)} |")
    elif sc in ("EFIMERA-CALCULO",):
        L += ["| Termino | Significado | LC (calculo) | LOC | Trans |", "|---------|-------------|-------------:|----:|------:|"]
        for r in terms:
            sc2 = r.get("scope_counts", {})
            L.append(f"| `{r['term']}` | {r.get('mean','')} | {sc2.get('LC',0)} | {sc2.get('LOC',0)} | {sc2.get('AIN',0)+sc2.get('AOUT',0)+sc2.get('BDR',0)+sc2.get('BDW',0)} |")
    else:
        L += ["| Termino | Significado | Total |", "|---------|-------------|------:|"]
        for r in terms:
            tot = sum(r.get("scope_counts", {}).values())
            L.append(f"| `{r['term']}` | {r.get('mean','')} | {tot} |")

L += [
    "", "---", "",
    "## Uso en la arquitectura target",
    "",
    "| Scope | Implicacion en el microservicio target |",
    "|-------|----------------------------------------|",
    "| PERSISTE-BD    | El bounded context que escribe este dato es el OWNER. Va en el esquema del microservicio. |",
    "| LECTURA-BD     | El microservicio lee datos de otro BC. Candidato a query via API del BC owner, no schema propio. |",
    "| INTERFAZ-IN    | Entra en el request DTO. Debe tener un nombre canonico en el target (target_term). |",
    "| INTERFAZ-OUT   | Sale en el response DTO. Idem — nombre canonico requerido. |",
    "| BATCH          | Proceso offline — candidato a job separado (Lambda / Cloud Run Job) con su propio schema. |",
    "| CURSOR         | Implementacion — no necesita superficie en el API contract. |",
    "| EFIMERA-CALCULO| Regla de negocio interna. Preservar la formula (golden master). No en el contrato. |",
    "| EFIMERA        | Detalle de implementacion — puede reescribirse libremente en el target. |",
    "| EXCEPCION      | Error model del microservicio. Debe mapearse a HTTP status + ProblemDetail RFC 9457. |",
    "| MIXTO          | Analizar por contexto de SP. Posible necesidad de desambiguacion en el modelo de dominio. |",
    "",
    "*Generado por extract-dataflow.py v2 - 10 tipos de scope*",
]

open(BASE + "knowledge-base/dataflow-scope-bcop.md", "w", encoding="utf-8").write("\n".join(L))
print(f"knowledge-base/dataflow-scope-bcop.md escrito - {n_sp:,} SPs analizados")
print(f"  AIN={id_scope['AIN']:,}  AOUT={id_scope['AOUT']:,}  "
      f"BDR={id_scope['BDR']:,}  BDW={id_scope['BDW']:,}  "
      f"LOC={id_scope['LOC']:,}  LC={id_scope['LC']:,}  "
      f"CUR={id_scope['CUR']:,}  EXC={id_scope['EXC']:,}")
print("  terminos por scope:")
for sc, _, _ in SCOPE_META:
    n = bynat.get(sc, 0)
    if n: print(f"    {sc:<20} {n}")
print(f"    {'sin senal':<20} {bynat.get('—',0)}")
print(f"\nProximo paso: python build-vocab-report-v2.py")