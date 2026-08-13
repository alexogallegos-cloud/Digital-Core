#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
extract-rules.py — Extrae REGLAS DE NEGOCIO del código SPL con evidencia directa:
  · Fórmulas (LET/SET con aritmética sobre variables financieras)
  · Validaciones (IF … RAISE EXCEPTION / código de error)
  · Umbrales y catálogos hardcodeados
Cada regla se marca con su REGULADOR dueño (SME) + norma + riesgo de equivalencia.

Genera: business-rules-bcop.md + business-rules.json
Etapa 3 — Business Logic Extraction · Specialist Informix SPL · SPE-AM-001
"""
import json, re, os
from collections import defaultdict

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/Informix/")
SRC = BASE + "source/informix/"
CG = json.load(open(BASE + "portal/data/callgraph-data.json", encoding="utf-8"))

# ── SMEs reguladores (agentes en SME/Regulatory/) ──
SME = {
 "SAT":      ("SME Regulatorio — SAT",      "SME/Regulatory/SAT/"),
 "CNBV":     ("SME Regulatorio — CNBV",     "SME/Regulatory/CNBV/"),
 "CONDUSEF": ("SME Regulatorio — CONDUSEF", "SME/Regulatory/CONDUSEF/"),
 "Banxico":  ("SME Regulatorio — Banxico",  "SME/Regulatory/Banxico/"),
 "IPAB":     ("SME Regulatorio — IPAB",     "SME/Regulatory/IPAB/"),
 "TESOFE":   ("SME Regulatorio — TESOFE",   "SME/Regulatory/TESOFE/"),
}
# keyword en el código → (regulador, norma aplicable)
REG_RULES = [
 (r"\bisr\b|imp_isr|tasa_isr",        "SAT",      "LISR Art.54/135 — retención de ISR sobre intereses (tasa 2026 = 0.90% anual)"),
 (r"\biva\b|imp_iva|ivas\b",          "SAT",      "LIVA — IVA sobre comisiones (16% / 8% frontera)"),
 (r"comis|comicob|cobracom",          "CONDUSEF", "LTOSF Art.17 (CAT) + RECO — comisión debe estar registrada"),
 (r"\bcat\b|costo_anual",             "CONDUSEF", "LTOSF Art.17 — Costo Anual Total (fórmula IRR)"),
 (r"\bgat\b|ganancia_anual",          "CONDUSEF", "LTOSF — Ganancia Anual Total (nominal/real)"),
 (r"interes|calc_int|tasa|rendim",    "CNBV",     "Criterios contables CNBV + GAT — cálculo de intereses/rendimientos"),
 (r"spei|clave_rastreo|cve_rastreo",  "Banxico",  "Circular 3/2012 SPEI — irrevocabilidad, clave de rastreo"),
 (r"codi",                            "Banxico",  "Reglas CoDi — Cobro Digital"),
 (r"cuota.*ipab|ipab|4.?al.?millar",  "IPAB",     "LPAB Art.22 — cuota ordinaria 4 al millar sobre pasivos asegurados"),
 (r"tesofe|dispersion|pension|beca",  "TESOFE",   "LTF — dispersión de recursos federales"),
 (r"art_?61|inactiv|beneficencia",    "CNBV",     "Art. 61 LIC — cuentas inactivas cuyos saldos, tras años sin movimiento, prescriben a favor de la beneficencia pública"),
 (r"buro|scoring|califica",           "CNBV",     "Buró de Crédito — evaluación crediticia (LRSIC)"),
]
def clasifica(text):
    hits = []
    low = text.lower()
    for pat, reg, norma in REG_RULES:
        if re.search(pat, low):
            hits.append((reg, norma))
    return hits

# ── riesgos de equivalencia en fórmulas (semántica Informix que puede divergir) ──
def riesgo_equiv(expr):
    r = []
    if re.search(r"/\s*360\b", expr):  r.append("base 360 (año comercial) — verificar vs 365")
    if re.search(r"/\s*365\b", expr):  r.append("base 365 — verificar vs 360")
    if "trunc" in expr.lower():        r.append("TRUNC — Informix trunca; PostgreSQL/Java puede redondear (divergencia de centavos)")
    if re.search(r"round\b", expr.lower()): r.append("ROUND — validar modo de redondeo (banker's vs half-up)")
    return r

RE_CREATE = re.compile(r"create\s+(?:procedure|function)\b", re.I)
def isolate(t):
    ms = list(RE_CREATE.finditer(t))
    return t[ms[0].start():ms[1].start()] if len(ms) >= 2 else t

# fórmula: asignación aritmética sobre variable financiera
FIN = r"(int|isr|tasa|monto|saldo|comis|iva|cuota|dias|importe|capital|rendim|gat|cat|sdo|abono|cargo)"
RE_FORMULA = re.compile(r"\b(?:let|set)\s+([a-z_][a-z0-9_]*)\s*=\s*(.+)", re.I)
# validación: RAISE EXCEPTION o retorno de error dentro de condición
RE_RAISE = re.compile(r"raise\s+exception|return\s+['\"]?\d{4,}|codret\s*=\s*['\"]", re.I)

def norm_expr(e):
    e = re.sub(r"\s+", " ", e).strip().rstrip(";")
    return e[:150]

# SPs a escanear: TODOS los archivos de cálculo/fórmula del filesystem (no solo los
# conectados en el call graph — muchos SPs de ISR/IVA/interés son hojas no conectadas)
CALC = re.compile(r"calc|calcula|comis|isr|interes|_iva|ivas|cuota|tasa|scoring|rendim|dispers|gat|reserva|moratori", re.I)
cand = set()
for fn in os.listdir(SRC):
    if not fn.endswith(".sql"):
        continue
    db, _, sp = fn[:-4].partition("_")   # {db}_{sp}.sql · el db no tiene "_"
    if sp and CALC.search(sp):
        cand.add((db, sp))
# + orquestadores del flujo (para sus validaciones)
try:
    fd = json.load(open(BASE + "portal/data/flow-data.json", encoding="utf-8"))
    for jid in fd:
        db, sp = jid.split(":", 1); cand.add((db, sp))
except FileNotFoundError:
    pass

rules = []
rid = 0
seen_formula = set()
for db, sp in sorted(cand):
    fp = SRC + f"{db}_{sp}.sql"
    if not os.path.exists(fp):
        continue
    txt = isolate(open(fp, encoding="utf-8", errors="replace").read())
    lines = txt.split("\n")
    for i, raw in enumerate(lines, 1):
        s = raw.strip()
        if not s or s.startswith("--"):
            continue
        # FÓRMULAS
        m = RE_FORMULA.match(s)
        if m and re.search(r"[*/]", m.group(2)) and re.search(FIN, s, re.I):
            expr = norm_expr(m.group(1) + " = " + m.group(2))
            key = (sp, re.sub(r"\d", "#", expr))
            if key in seen_formula:
                continue
            seen_formula.add(key)
            regs = clasifica(sp + " " + expr)
            rid += 1
            rules.append({"id": f"BR-IFX-{rid:03d}", "tipo": "FÓRMULA", "sp": sp, "db": db,
                          "line": i, "code": expr, "reg": regs,
                          "riesgo": riesgo_equiv(m.group(2))})
    # muestreo de validaciones críticas (RAISE) por SP — máx 3 por SP para no saturar
    val = 0
    for i, raw in enumerate(lines, 1):
        s = raw.strip()
        if RE_RAISE.search(s) and val < 3:
            regs = clasifica(sp)
            rid += 1
            rules.append({"id": f"BR-IFX-{rid:03d}", "tipo": "VALIDACIÓN", "sp": sp, "db": db,
                          "line": i, "code": norm_expr(s), "reg": regs, "riesgo": []})
            val += 1

# ── agrupar por regulador ──
by_reg = defaultdict(list)
sin_reg = []
for r in rules:
    if r["reg"]:
        for reg, norma in r["reg"]:
            by_reg[reg].append((r, norma))
    else:
        sin_reg.append(r)

DOMN = {"bdicheq":"D04 Cheques","bdicred":"D03 Créditos","bdisac":"D05 Saldos","bdispei":"D08 SPEI",
        "bdicont":"D12 Contab.","bdisolic":"D06 Solic.","bdiaclaracion":"D07 Aclar.","bdimnsj":"D09 Msj",
        "bdicnweb":"D01 Canal","bdinteg":"D02 Integr.","bdicobranza":"D11 Cobr.","bdisuc":"D10 Suc."}

n_form = sum(1 for r in rules if r["tipo"] == "FÓRMULA")
n_val = sum(1 for r in rules if r["tipo"] == "VALIDACIÓN")
n_reg = sum(1 for r in rules if r["reg"])

json.dump({"rules": rules, "by_reg_counts": {k: len(v) for k, v in by_reg.items()}},
          open(BASE + "portal/data/business-rules.json", "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))

# ── Markdown ──
L = ["# Informix · Catálogo de Reglas de Negocio y Fórmulas",
 "",
 "> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Extraction  ",
 "> **Evidencia:** extraído del código SPL (SP + línea) · **Generado:** 2026-07-04 por `extract-rules.py`  ",
 "",
 f"**{n_form} fórmulas** + **{n_val} validaciones** extraídas · **{n_reg} con impacto regulatorio**. "
 "Cada regla tiene evidencia directa (SP + línea de código). Las fórmulas financieras llevan "
 "`[RIESGO-EQUIVALENCIA]` cuando su semántica Informix (TRUNC, base 360/365, MONEY) puede divergir en el target.",
 "",
 "## SMEs reguladores presentes",
 "",
 "Cada regla regulatoria tiene un **SME dueño** que valida el cumplimiento contra su corpus normativo:",
 "",
 "| Regulador | SME (agente) | Reglas |",
 "|-----------|--------------|-------:|"]
for reg in ["CNBV", "Banxico", "CONDUSEF", "SAT", "TESOFE", "IPAB"]:
    nm, path = SME[reg]
    L.append(f"| **{reg}** | `{path}` | {len(by_reg.get(reg, []))} |")
L += ["", "---", ""]

# fórmulas destacadas (las de cálculo financiero con riesgo)
L += ["## Fórmulas de negocio críticas (con riesgo de equivalencia)", ""]
destacadas = [r for r in rules if r["tipo"] == "FÓRMULA" and r["riesgo"]][:20]
for r in destacadas:
    regs = " · ".join(f"**{reg}**" for reg, _ in r["reg"]) or "operacional"
    L.append(f"- `{r['id']}` **{r['sp']}** ({DOMN.get(r['db'],r['db'])} · L{r['line']}) — {regs}  ")
    L.append(f"  ```")
    L.append(f"  {r['code']}")
    L.append(f"  ```")
    for rk in r["riesgo"]:
        L.append(f"  ⚠ `[RIESGO-EQUIVALENCIA]` {rk}")
    L.append("")

# por regulador
L += ["---", "", "## Reglas por regulador", ""]
for reg in ["CNBV", "Banxico", "CONDUSEF", "SAT", "TESOFE", "IPAB"]:
    items = by_reg.get(reg, [])
    if not items:
        continue
    nm, path = SME[reg]
    L.append(f"### {reg} — {nm}")
    L.append(f"> Corpus: `{path}` · {len(items)} reglas")
    L.append("")
    L.append("| ID | Tipo | SP · línea | Norma | Evidencia (código) |")
    L.append("|----|------|-----------|-------|--------------------|")
    seen = set()
    for r, norma in items[:25]:
        if r["id"] in seen: continue
        seen.add(r["id"])
        code = r["code"].replace("|", "/")[:70]
        L.append(f"| {r['id']} | {r['tipo']} | `{r['sp']}` L{r['line']} | {norma[:48]} | `{code}` |")
    L.append("")

L += ["---", "",
 "## Riesgos de equivalencia consolidados `[RIESGO-EQUIVALENCIA]`", "",
 "Semántica Informix en fórmulas financieras que **debe validarse con golden master** antes de transpilar:",
 "",
 "- **Base de cálculo de interés `/360` vs `/365`:** año comercial vs año natural — una diferencia sistemática "
 "en todos los intereses. Debe confirmarse con el SME cuál aplica por producto.",
 "- **`TRUNC` vs `ROUND`:** Informix trunca (no redondea) en las fórmulas de ISR e interés; el target debe "
 "replicar TRUNC exacto o divergirá por centavos en cada cálculo — **auditable ante SAT/CNBV**.",
 "- **Tipo `MONEY`:** Informix aplica banker's rounding por defecto; PostgreSQL `NUMERIC` no. Toda "
 "aritmética sobre MONEY es `[RIESGO-EQUIVALENCIA]` crítico.",
 "- **Tasa `/100`:** conversión de porcentaje a decimal — verificar precisión (DECIMAL vs FLOAT).",
 "",
 "## Método de validación (HITL con SMEs reguladores)",
 "",
 "```",
 "1. Cada fórmula/regla → se envía al SME regulador dueño (tabla arriba)",
 "2. El SME valida contra su corpus normativo (ej. SAT confirma tasa ISR y base de cálculo)",
 "3. Se define el golden master test que preserva la fórmula exacta (incl. TRUNC/base)",
 "4. Equivalencia ≥ 99.95% obligatoria en cálculos financieros (auditable)",
 "```",
 "",
 "*Generado por Specialist — Informix SPL Analysis · Etapa 3 · fuente: source/ + extract-rules.py · "
 "coordina con SMEs en SME/Regulatory/*"]

open(BASE + "knowledge-base/business-rules-bcop.md", "w", encoding="utf-8").write("\n".join(L))
print(f"knowledge-base/business-rules-bcop.md + .json escritos.")
print(f"  {n_form} fórmulas · {n_val} validaciones · {n_reg} con impacto regulatorio")
print(f"  por regulador: " + " · ".join(f"{k}:{len(v)}" for k, v in sorted(by_reg.items(), key=lambda x:-len(x[1]))))