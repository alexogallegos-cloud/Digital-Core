#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-vocab-inventory.py — Inventario de términos del vocabulario BCOPCore.
Clasifica cada término como ATÓMICO (num) o COMPUESTO (numcte), con:
  frecuencia real en el corpus (3,761 SPs: nombres + parámetros),
  evidencia de parámetros, descomposición y NIVEL DE CONFIABILIDAD.
También lista CANDIDATOS (fragmentos frecuentes aún no clasificados).

Genera: vocabulary-inventory-bcop.md + vocabulary-inventory.json
Etapa 3 — Business Logic Extraction · Specialist Informix SPL · SPE-AM-001
"""
import json, re, os
from collections import Counter
from sp_vocab import CAT, KEYS

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/BCOPCore/")
SRC = BASE + "source/BCOPCore/informix/"
CG = json.load(open(BASE + "callgraph-data.json", encoding="utf-8"))
nodes = CG["graph"]["nodes"]
RE_SIG = re.compile(r"CREATE\s+(?:PROCEDURE|FUNCTION)\s+[^\(]*\(([^;]*?)\)\s*RETURNING", re.I | re.S)

# ── corpus: nombres + morfemas de parámetros ──
names = [n["label"].lower() for n in nodes]
def dehung(p):
    core = re.sub(r"^(p|c|v|w|i|m|d|n|b|f|dt|arr|o|s|l)([A-Z_])", r"\2", p)
    return core.lstrip("_").lower()
param_names = Counter()
for n in nodes:
    db, sp = n["id"].split(":", 1)
    fp = SRC + f"{db}_{sp}.sql"
    if os.path.exists(fp):
        head = open(fp, encoding="utf-8", errors="replace").read()[:3000]
        m = RE_SIG.search(head)
        if m:
            for chunk in m.group(1).split(","):
                pm = re.match(r"\s*([a-zA-Z][a-zA-Z0-9_]*)\s+\w", chunk)
                if pm:
                    c = dehung(pm.group(1))
                    if len(c) >= 3:
                        param_names[c] += 1

def segment_ex(tok, exclude=None):
    keys = KEYS if exclude is None else [k for k in KEYS if k != exclude]
    out, i, t = [], 0, tok.lower()
    while i < len(t):
        m = next((k for k in keys if t.startswith(k, i)), None)
        if m: out.append(m); i += len(m)
        else:
            j = i + 1
            while j < len(t) and not any(t.startswith(k, j) for k in keys): j += 1
            out.append("?" + t[i:j]); i = j
    return out

def is_compound(term):
    seg = segment_ex(term, exclude=term)
    atoms = [s for s in seg if not s.startswith("?")]
    ok = all(not s.startswith("?") for s in seg)
    return (len(atoms) > 1 and ok), seg

# frecuencia por SEGMENTACIÓN real (no substring): evita inflar átomos cortos
seg_atom_freq = Counter()   # átomos al segmentar los tokens de nombres
raw_token_freq = Counter()  # tokens crudos entre "_"
for nm in names:
    for seg in nm.split("_"):
        if not seg:
            continue
        raw_token_freq[seg] += 1
        for a in segment_ex(seg):
            if not a.startswith("?"):
                seg_atom_freq[a] += 1

def freq_of(term, compound):
    fp = param_names.get(term, 0)
    fn = raw_token_freq.get(term, 0) if compound else seg_atom_freq.get(term, 0)
    return fn, fp

# nivel de confiabilidad
def nivel(term):
    cat, mean, est = CAT[term]
    fp = param_names.get(term, 0)
    if cat == "AMBIGUO" or est == "gap":
        return "AMBIGUA"
    if fp >= 5 or est == "conf":
        return "ALTA"
    if est == "inf":
        return "MEDIA"
    return "MEDIA"

# ── clasificar todo el vocab ──
atomos, compuestos = [], []
for term in sorted(CAT.keys()):
    if len(term) < 2:
        continue
    cat, mean, est = CAT[term]
    comp, seg = is_compound(term)
    fn, fp = freq_of(term, comp)
    row = dict(term=term, cat=cat, mean=mean, est=est,
               nivel=nivel(term), fn=fn, fp=fp,
               deco=" + ".join(seg) if comp else "")
    (compuestos if comp else atomos).append(row)

# ── candidatos: fragmentos desconocidos frecuentes en el corpus ──
# Se separa el RUIDO (sufijos gramaticales + notación húngara) de los candidatos reales.
SUFIJOS = {"cion","ciones","ion","iones","ero","era","eda","tura","ncia","dad","ado","ido",
           "ual","ito","ita","tante","cial","inte","esar","tal","ent","ceso","gistro","racion",
           "itor","uesta","anza","miento","encia","aria","ario","oria","orio","able","ible",
           "tar","der","fer","ecutivo","del","trama","dinya","etv"}
HUNG = re.compile(r"^_?p?(v?chr|vchar|int8?|dt|num|imp|dec|smallint|serial|money|char|mny|mn|pr)$"
                  r"|vchr|pchr|pvchr|pmny|pmn", re.I)
def is_noise(t):
    if t in SUFIJOS: return True          # sufijo gramatical (-ción, -tar, -ero…)
    if t.startswith("_") or t.endswith("_"): return True   # resto con separador
    if HUNG.search(t): return True        # notación húngara de tipo (pvchr, pmny…)
    if t.isdigit(): return True           # números sueltos
    if len(t) <= 2: return True
    return False

unknown = Counter()
for nm in names:
    for seg in nm.split("_"):
        for a in segment_ex(seg):
            if a.startswith("?") and len(a) > 3:
                unknown[a[1:]] += 1
for p, c in param_names.items():
    for a in segment_ex(p):
        if a.startswith("?") and len(a) > 3:
            unknown[a[1:]] += c
# candidatos reales (posibles términos) vs ruido (excluido del trabajo de clasificación)
candidatos = [(t, c) for t, c in unknown.most_common(300) if not is_noise(t)][:60]
n_ruido = sum(1 for t in unknown if is_noise(t))

# ── ordenar por frecuencia ──
atomos.sort(key=lambda r: -(r["fn"] + r["fp"]))
compuestos.sort(key=lambda r: -(r["fn"] + r["fp"]))

# ── JSON ──
out = {"atomos": atomos, "compuestos": compuestos,
       "candidatos": [{"frag": t, "frec": c} for t, c in candidatos],
       "meta": {"sps": len(nodes), "vocab": len(CAT),
                "n_atomos": len(atomos), "n_compuestos": len(compuestos),
                "n_ruido": n_ruido}}
json.dump(out, open(BASE + "vocabulary-inventory.json", "w", encoding="utf-8"),
          ensure_ascii=False, separators=(",", ":"))

# ── Markdown ──
NIV = {"ALTA": "🟢 Alta", "MEDIA": "🟡 Media", "AMBIGUA": "🔴 Ambigua", "CANDIDATO": "⚪ Candidato"}
CATL = {"PREFIJO": "prefijo", "ACCION": "acción", "ENTIDAD": "entidad",
        "MODIF": "modificador", "REG": "regulatorio", "AMBIGUO": "ambiguo"}
L = ["# BCOPCore · Inventario de Términos del Vocabulario",
 "",
 "> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction  ",
 "> **Corpus:** 3,761 SPs conectados (nombres + parámetros del código fuente) · **Vocabulario:** `sp_vocab.py`  ",
 "> **Generado:** 2026-07-03 por `build-vocab-inventory.py`  ",
 "",
 "**Confiabilidad:** 🟢 Alta (confirmada por código/param o significado inequívoco) · "
 "🟡 Media (inferida por convención) · 🔴 Ambigua (requiere SME/DBA) · ⚪ Candidato (sin clasificar).  ",
 "**Columnas:** `frec-nom` = veces que aparece en nombres de SP · `frec-par` = veces como parámetro (evidencia de código).",
 "",
 f"Totales: **{len(atomos)} términos atómicos** · **{len(compuestos)} términos compuestos** · "
 f"**{len(candidatos)} candidatos sin clasificar**.",
 "",
 "---",
 "",
 "## A · Términos atómicos (individuales)",
 "",
 "Morfemas irreducibles — los building blocks del vocabulario.",
 "",
 "| Término | Categoría | Significado | Confiab. | frec-nom | frec-par |",
 "|---|---|---|---|--:|--:|"]
for r in atomos:
    L.append(f"| `{r['term']}` | {CATL[r['cat']]} | {r['mean']} | {NIV[r['nivel']]} | {r['fn']} | {r['fp']} |")

L += ["", "---", "", "## B · Términos compuestos",
 "",
 "Términos lexicalizados que se descomponen en átomos conocidos.",
 "",
 "| Compuesto | Descomposición | Significado | Confiab. | frec-nom | frec-par |",
 "|---|---|---|---|--:|--:|"]
for r in compuestos:
    L.append(f"| `{r['term']}` | {r['deco']} | {r['mean']} | {NIV[r['nivel']]} | {r['fn']} | {r['fp']} |")

L += ["", "---", "", "## C · Candidatos sin clasificar (fragmentos frecuentes)",
 "",
 "Fragmentos que el segmentador no reconoce y aparecen ≥ 4 veces. "
 "Son los **próximos términos a clasificar con el SME** — cada uno agregado a `sp_vocab.py` "
 "sube la cobertura de todos los SPs que lo contienen.",
 "",
 "| Fragmento | Frecuencia | Hipótesis (por confirmar) |",
 "|---|--:|---|"]
HINT = {"cion":"sufijo -ción (resto de partir un verbo)","ciones":"sufijo -ciones",
 "ion":"sufijo -ión","itor":"resto de 'monitor'","uesta":"resto de 'respuesta/propuesta'",
 "racion":"resto de -ración","ciliacion":"resto de 'conciliación'","centracion":"resto de 'concentración'",
 "dinya":"?","tdc":"tarjeta de crédito (ya en vocab)","cjunk":"variable junk (ruido)",
 "adn":"?","mesas":"¿mesa de control?","soe":"prefijo SOE (bdibei)","ope":"operación (ya en vocab)"}
for t, c in candidatos:
    L.append(f"| `{t}` | {c} | {HINT.get(t,'—')} |")

# resumen confiabilidad
allrows = atomos + compuestos
byn = Counter(r["nivel"] for r in allrows)
L += ["", "---", "", "## D · Resumen de confiabilidad",
 "",
 "| Nivel | Términos | % |",
 "|---|--:|--:|"]
tot = len(allrows)
for k in ["ALTA", "MEDIA", "AMBIGUA"]:
    L.append(f"| {NIV[k]} | {byn.get(k,0)} | {100*byn.get(k,0)//tot if tot else 0}% |")
L += [f"| **Total clasificado** | **{tot}** | |",
 f"| ⚪ Candidatos pendientes | {len(candidatos)} | |",
 "",
 "*Generado por Specialist — Informix SPL Analysis · Etapa 3 · fuente: callgraph-data.json + source/ + sp_vocab.py*"]

open(BASE + "vocabulary-inventory-bcop.md", "w", encoding="utf-8").write("\n".join(L))
print(f"vocabulary-inventory-bcop.md + .json escritos.")
print(f"  {len(atomos)} atómicos · {len(compuestos)} compuestos · {len(candidatos)} candidatos")
print(f"  confiabilidad: {dict(byn)}")
print("\n⚠️  Este inventory NO incluye el campo 'scope' (efímero/trasciende).")
print("   El scope lo añade extract-dataflow.py — córrelo AHORA o el reporte saldrá con 'Scope' vacío:")
print("       python3 extract-dataflow.py")