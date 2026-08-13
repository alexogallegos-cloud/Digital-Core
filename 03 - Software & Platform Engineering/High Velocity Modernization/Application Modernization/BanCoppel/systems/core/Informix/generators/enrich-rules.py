#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
enrich-rules.py — Enriquece business-rules-v2.json con:

  · explicacion  Explicación de negocio en lenguaje natural (solo donde hay confianza)
  · expl_conf    Nivel de confianza: "literal" | "formula" | "norma" | "infer" | ""
  · sp_rel       SPs relacionados del callgraph (callers + callees top-3)
  · vocab_detail [{term, mean, bc}] para cada vocab_ref

Fuentes consultadas:
  vocabulary-inventory.json  → significados y BC de cada término
  callgraph-data.json        → relaciones entre SPs
  source/informix/  → código fuente (para comentarios inline)

También actualiza knowledge-base/rules/business-rules-bcop.md con la tabla de explicaciones.

SPE-AM-001 · Etapa 3 — Business Logic Enrichment
"""
import json, re, os
from collections import defaultdict

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/Informix/")
SRC = BASE + "source/informix/"

# ── 1. Cargar vocabulario ──────────────────────────────────────────────────────
inv = json.load(open(BASE + "knowledge-base/vocabulary-inventory.json", encoding="utf-8"))
VOCAB = {}
for section in ("atomos", "compuestos"):
    for item in inv.get(section, []):
        VOCAB[item["term"]] = {
            "mean":    item.get("mean", ""),
            "bc":      item.get("bc", "") or "",
            "bc_name": item.get("bc_name", "") or "",
            "cat":     item.get("cat", ""),
        }

def _clean_prefix(name):
    """Quita prefijos de variable húngara: v_, m_, c_, p_, etc."""
    return re.sub(r"^[vmcp][_A-Z]", "", name, flags=re.I).lower().lstrip("_")

# ── 2. Cargar callgraph → mapa bidireccional ───────────────────────────────────
cg = json.load(open(BASE + "portal/data/callgraph-data.json", encoding="utf-8"))

node_meta = {}   # sp_label → {fan_in, fan_out, loc, db}
for n in cg["graph"]["nodes"]:
    node_meta[n["label"]] = {
        "fan_in":  n["fan_in"],
        "fan_out": n["fan_out"],
        "loc":     n["loc"],
        "db":      n["db"],
    }

callers  = defaultdict(list)  # sp → [SPs que lo llaman]
callees  = defaultdict(list)  # sp → [SPs que llama]
for e in cg["graph"]["edges"]:
    frm = e["from"].split(":", 1)[1]
    to  = e["to"].split(":", 1)[1]
    callees[frm].append(to)
    callers[to].append(frm)

def top_related(sp, n=3):
    """Callers y callees únicos, ordenados por fan_in del nodo (más llamados primero)."""
    c_in  = sorted(set(callers.get(sp, [])),
                   key=lambda x: node_meta.get(x, {}).get("fan_in", 0), reverse=True)[:n]
    c_out = sorted(set(callees.get(sp, [])),
                   key=lambda x: node_meta.get(x, {}).get("fan_in", 0), reverse=True)[:n]
    return {"callers": c_in, "callees": c_out}

# ── 3. Generador de explicación ────────────────────────────────────────────────
RE_STR_LITERAL = re.compile(
    r"['\"]([A-ZÁÉÍÓÚÜÑA-Záéíóúüña-z][^'\"]{8,90})['\"]"
)
RE_COMMENT     = re.compile(r"--\s*(.{5,90})$")
RE_ASSIGN      = re.compile(r"^(\w+)\s*=\s*(.+)")
RE_RAISE_MSG   = re.compile(
    r"raise\s+exception\s+[-\d]+\s*,\s*\d+\s*,\s*['\"]([^'\"]+)['\"]", re.I
)
RE_CODRET      = re.compile(
    r"codret\s*=\s*['\"]([1-9A-Z][A-Z0-9]{2,})['\"]", re.I
)
RE_NUMBER      = re.compile(r"(\d{2,}(?:[,.]\d+)?)")

# Diccionario de operaciones financieras comunes en SPL
FIN_OPS = {
    r"/\s*360":  "base 360 (año comercial)",
    r"/\s*365":  "base 365 (año natural)",
    r"/\s*30\b": "base 30 días/mes",
    r"/\s*100":  "conversión porcentual (÷100)",
    r"/\s*12\b": "periodicidad mensual",
    r"\btrunc\b":"truncamiento (sin redondeo)",
    r"\bround\b":"redondeo",
}

_SRC_CACHE = {}

def _get_src_lines(db, sp, radius=5, target_line=1):
    """Lee ±radius líneas alrededor de target_line del archivo fuente."""
    key = f"{db}_{sp}"
    if key not in _SRC_CACHE:
        fp = SRC + f"{db}_{sp}.sql"
        try:
            _SRC_CACHE[key] = open(fp, encoding="utf-8", errors="replace").read().splitlines()
        except FileNotFoundError:
            _SRC_CACHE[key] = []
    lines = _SRC_CACHE[key]
    lo = max(0, target_line - radius - 1)
    hi = min(len(lines), target_line + radius)
    return lines[lo:hi]

def gen_explicacion(rule):
    """
    Retorna (texto, confianza).
    confianza: "literal" | "formula" | "norma" | "infer" | ""
    """
    tipo  = rule["tipo"]
    code  = rule["code"]
    sp    = rule["sp"]
    db    = rule["db"]
    line  = rule.get("line", 1)
    vr    = rule.get("vocab_refs", [])
    reg   = rule.get("reg", [])

    # ── Nivel 1: RAISE EXCEPTION con mensaje literal ──────────────────────────
    m = RE_RAISE_MSG.search(code)
    if m:
        msg = m.group(1).strip()
        if len(msg) > 5:
            return msg.title()[:120], "literal"

    # ── Nivel 2: Código de retorno con comentario en el código fuente ─────────
    m = RE_CODRET.search(code)
    if m:
        ctx_lines = _get_src_lines(db, sp, radius=2, target_line=line)
        for ln in ctx_lines:
            cm = RE_COMMENT.search(ln)
            if cm:
                txt = cm.group(1).strip()
                if len(txt) > 5 and not txt.lower().startswith("fin "):
                    return txt.capitalize()[:120], "literal"
        # Sin comentario — devuelve el código de retorno con descripción
        codval = m.group(1)
        return f"Retorna código de error {codval}", "infer"

    # ── Nivel 3: String literal descriptivo (RAISE con texto) ────────────────
    m = RE_STR_LITERAL.search(code)
    if m:
        txt = m.group(1).strip()
        if len(txt) > 8:
            return txt.capitalize()[:120], "literal"

    # ── Nivel 4: Comentario inline -- ─────────────────────────────────────────
    m = RE_COMMENT.search(code)
    if m:
        txt = m.group(1).strip()
        if len(txt) > 5 and not txt.lower().startswith(("fin", "todo", "ok")):
            return txt.capitalize()[:120], "literal"

    # ── Nivel 5: FÓRMULA — construir explicación desde vocab ──────────────────
    if tipo == "FÓRMULA":
        m = RE_ASSIGN.match(code)
        if m:
            target = m.group(1)
            expr   = m.group(2)
            tc     = _clean_prefix(target)
            t_info = VOCAB.get(tc, {})
            t_mean = t_info.get("mean", "")

            # Operaciones especiales
            ops_found = []
            for pat, label in FIN_OPS.items():
                if re.search(pat, expr, re.I):
                    ops_found.append(label)

            # Partes de vocab en la expresión
            parts = [VOCAB.get(t, {}).get("mean", "") for t in vr if VOCAB.get(t, {}).get("mean")]

            if t_mean:
                prefix = "Calcula" if re.search(r"[*/]", expr) else "Asigna"
                base   = f"{prefix} {t_mean}"
                if ops_found:
                    return f"{base} ({', '.join(ops_found[:2])})", "formula"
                if parts:
                    return f"{base} sobre {', '.join(parts[:2])}", "formula"
                return base, "formula"

            if parts:
                ops_str = f" ({ops_found[0]})" if ops_found else ""
                return f"Fórmula: {' · '.join(parts[:3])}{ops_str}", "formula"

            # Último recurso: número clave en la fórmula
            nums = RE_NUMBER.findall(expr)
            key_nums = [n for n in nums if int(n.replace(",","").replace(".","")) not in (100,1000)]
            if key_nums:
                return f"Cálculo con umbral/factor {key_nums[0]}", "formula"

    # ── Nivel 6: Contexto regulatorio ────────────────────────────────────────
    if reg:
        norma = reg[0][1]
        short = norma.split(" — ")[0].strip()[:100]
        return short, "norma"

    # ── Nivel 7: UMBRAL — extraer valor + vocab ───────────────────────────────
    if tipo == "UMBRAL":
        mn = RE_NUMBER.search(code)
        if mn and vr:
            val = mn.group(1)
            mean = VOCAB.get(vr[0], {}).get("mean", vr[0])
            op_m = re.search(r"([<>]=?)", code)
            op   = op_m.group(1) if op_m else "="
            return f"Umbral: {mean} {op} {val}", "infer"

    return "", ""


# ── 4. Enriquecer reglas ───────────────────────────────────────────────────────
data  = json.load(open(BASE + "portal/data/business-rules-v2.json", encoding="utf-8"))
rules = data["rules"]

n_expl  = {"literal": 0, "formula": 0, "norma": 0, "infer": 0, "": 0}
n_sprel = 0

for r in rules:
    # Explicación
    expl, conf = gen_explicacion(r)
    r["explicacion"] = expl
    r["expl_conf"]   = conf
    n_expl[conf]     += 1

    # SP relacionado
    rel = top_related(r["sp"], n=3)
    r["sp_rel"] = rel
    if rel["callers"] or rel["callees"]:
        n_sprel += 1

    # Vocab con detalle de significado
    r["vocab_detail"] = [
        {"term": t, "mean": VOCAB.get(t, {}).get("mean", ""), "bc": VOCAB.get(t, {}).get("bc", "")}
        for t in r.get("vocab_refs", [])
        if VOCAB.get(t, {}).get("mean")
    ]

print(f"Enriquecidas: {len(rules)} reglas")
print(f"  Con explicación: {len(rules)-n_expl['']} ({(len(rules)-n_expl[''])*100//len(rules)}%)")
print(f"    literal: {n_expl['literal']}  formula: {n_expl['formula']}  norma: {n_expl['norma']}  infer: {n_expl['infer']}")
print(f"  Con SP relacionado: {n_sprel}")

# Guardar JSON enriquecido
data["meta"]["enriched"] = "2026-08-02"
data["meta"]["version"]  = "2.2"
json.dump(data, open(BASE + "portal/data/business-rules-v2.json", "w", encoding="utf-8"),
          ensure_ascii=False, separators=(",", ":"))
print(f"\nbusiness-rules-v2.json actualizado (v2.2)")

# ── 5. Actualizar knowledge-base MD ───────────────────────────────────────────
os.makedirs(BASE + "knowledge-base/rules", exist_ok=True)
KB = BASE + "knowledge-base/rules/business-rules-bcop.md"

from collections import Counter
by_cat  = Counter(r.get("categoria","OPERACIONAL") for r in rules)
by_reg  = Counter(x for r in rules for x, _ in r.get("reg",[]))
by_tipo = Counter(r["tipo"] for r in rules)
n_riesgo = sum(1 for r in rules if r.get("riesgo"))
n_expl_tot = len(rules) - n_expl[""]

L = [
    "# Informix · Catálogo de Reglas de Negocio — v2.2",
    "",
    "> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Enrichment  ",
    f"> **Generado:** 2026-08-02 · `enrich-rules.py` · {len(rules):,} reglas · {n_expl_tot:,} con explicación  ",
    "> **Anclaje:** vocabulario 787 términos · callgraph 34,279 edges · 12,832 SPs escaneados  ",
    "> **Fuente primaria:** `business-rules-v2.json` (v2.2) — este MD es resumen navegable y auditable  ",
    "",
    "## Resumen ejecutivo",
    "",
    "| Tipo | Reglas | Con explicación |",
    "|----|---:|---:|",
]
for tipo in ("FÓRMULA", "VALIDACIÓN", "UMBRAL", "ESTADO"):
    cnt = by_tipo.get(tipo, 0)
    exp = sum(1 for r in rules if r["tipo"]==tipo and r.get("explicacion"))
    L.append(f"| {tipo} | {cnt:,} | {exp:,} |")
L += [
    f"| **TOTAL** | **{len(rules):,}** | **{n_expl_tot:,}** |",
    "",
    "| Dimensión | Valor |",
    "|---|---|",
    f"| SPs escaneados | 12,832 |",
    f"| Reglas con impacto regulatorio | {sum(1 for r in rules if r.get('reg')):,} |",
    f"| Reglas con riesgo de equivalencia | {n_riesgo:,} |",
    f"| Reglas con SP relacionado en callgraph | {n_sprel:,} |",
    "",
    "## Reguladores",
    "",
    "| Regulador | Reglas |",
    "|---|---:|",
]
for reg in ("CNBV","Banxico","CONDUSEF","SAT","TESOFE","IPAB"):
    if by_reg.get(reg):
        L.append(f"| **{reg}** | {by_reg[reg]:,} |")

L += ["", "## Categorías de segmentación", "", "| Categoría | Reglas |", "|---|---:|"]
for cat, cnt in by_cat.most_common():
    L.append(f"| {cat} | {cnt:,} |")

L += [
    "",
    "---",
    "",
    "## Explicaciones de negocio — Fórmulas críticas con riesgo de equivalencia",
    "",
    "> Solo se muestran reglas donde la explicación tiene confianza **literal** o **formula**.",
    "> Estas son las más importantes para el golden master de migración.",
    "",
    "| ID | SP | Dominio | BC | Explicación | Riesgo equiv. | SPs relacionados |",
    "|----|----|----|---|---|---|---|",
]
crit = [r for r in rules
        if r.get("riesgo") and r.get("expl_conf") in ("literal","formula","norma")]
for r in crit[:60]:
    expl    = r.get("explicacion","")[:70].replace("|","/")
    riesc   = "; ".join(r["riesgo"])[:60].replace("|","/") if r.get("riesgo") else ""
    bc_col  = f"`{r['bc']}`" if r.get("bc") else "—"
    callers = ", ".join(f"`{s}`" for s in r["sp_rel"].get("callers",[])[:2])
    L.append(f"| {r['id']} | `{r['sp']}` | {r['dominio']} | {bc_col} | {expl} | {riesc} | {callers} |")

L += [
    "",
    "---",
    "",
    "## Explicaciones por categoría — muestra representativa",
    "",
]

CATS_ORDER = ["REGULATORIO","CALCULO_FINANCIERO","CONTABILIDAD_REPORTES",
              "PAGOS_TRANSFERENCIAS","ATENCION_CLIENTE","RIESGO_CREDITO",
              "FLUJO_OPERATIVO","PARAMETRIA","OPERACIONAL"]

for cat in CATS_ORDER:
    sample = [r for r in rules
              if r.get("categoria")==cat and r.get("explicacion")
              and r.get("expl_conf") in ("literal","formula","norma")][:12]
    if not sample:
        continue
    L += [f"### {cat} — muestra ({len(sample)} de {by_cat.get(cat,0):,})", ""]
    L += ["| ID | Tipo | SP | Explicación | Vocab relacionado |",
          "|----|------|----|-------------|-------------------|"]
    for r in sample:
        expl  = r.get("explicacion","")[:65].replace("|","/")
        vd    = "; ".join(f"{v['term']} ({v['mean'][:30]})" for v in r.get("vocab_detail",[])[:3])
        if not vd:
            vd = "—"
        L.append(f"| {r['id']} | {r['tipo']} | `{r['sp']}` | {expl} | {vd[:60]} |")
    L.append("")

L += [
    "---",
    "",
    "## Umbrales hardcodeados — parámetros a externalizar",
    "",
    "Cada umbral es un valor de negocio embebido en código que **debe migrar a tabla de configuración**.",
    "",
    "| ID | SP | Dominio | Explicación | Vocab |",
    "|----|----|----|---|---|",
]
for r in [x for x in rules if x["tipo"]=="UMBRAL" and x.get("explicacion")][:30]:
    expl = r.get("explicacion","")[:60].replace("|","/")
    vd   = r.get("vocab_detail",[{}])[0].get("term","") if r.get("vocab_detail") else ""
    L.append(f"| {r['id']} | `{r['sp']}` | {r['dominio']} | {expl} | {vd} |")

L += [
    "",
    "---",
    "",
    "## Riesgos de equivalencia — guía de validación",
    "",
    "| Riesgo | Origen Informix | Acción requerida |",
    "|---|---|---|",
    "| Base 360 | `/360` año comercial | Confirmar con SME CNBV cuál base aplica por producto |",
    "| Base 365 | `/365` año natural | Confirmar con SME CNBV cuál base aplica por producto |",
    "| TRUNC | Trunca sin redondear | Replicar `TRUNC` exacto en PostgreSQL (no ROUND) |",
    "| ROUND | Half-up | Validar modo banker's vs half-up en target |",
    "| MONEY | Banker's rounding | Usar `NUMERIC(18,4)` + ROUND explícito |",
    "",
    "---",
    "",
    "*Generado automáticamente · Specialist — Informix SPL Analysis · Informix Etapa 3*  ",
    "*Fuentes: `business-rules-v2.json` v2.2 · `vocabulary-inventory.json` · `callgraph-data.json`*  ",
    "*Para actualizar: `python enrich-rules.py`*",
]

open(KB, "w", encoding="utf-8").write("\n".join(L))
print(f"knowledge-base/rules/business-rules-bcop.md actualizado ({len(L)} líneas)")
