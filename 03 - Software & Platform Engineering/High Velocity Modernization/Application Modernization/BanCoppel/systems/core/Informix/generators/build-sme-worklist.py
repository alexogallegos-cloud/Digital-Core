#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-sme-worklist.py — Lista priorizada de validación para la sesión con el
Domain Expert (SME) de BanCoppel. Extrae del inventario los términos que NO
tienen evidencia dura (convención / inferido / ambiguo / candidato) y los ordena
por IMPACTO (frecuencia = # de SPs afectados si el significado está mal).

Cada término confirmado por el SME → editar sp_vocab.py → sube la certeza dura.
Consume: vocabulary-inventory.json · Genera: sme-validation-worklist-bcop.md
Etapa 3 — Business Logic Extraction · Specialist Informix SPL · SPE-AM-001
"""
import json, re
from collections import Counter

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/Informix/")
INV = json.load(open(BASE + "knowledge-base/vocabulary-inventory.json", encoding="utf-8"))

BIZ = re.compile(r"bancoppel|afore|banxico|condusef|western|moneygram|coppel|codi|spei|"
                 r"clabe|comprobante|banca por internet|art\.61|reco|domiciliaci|remesa|"
                 r"quincena|oxxo|hipotec|préstamo|prestamo|inversión|msi|cep|rastreo|udi", re.I)
def fuente(r):
    m = (r.get("mean") or "").lower()
    if "confirmado sme" in m:            return "SME"
    if BIZ.search(m):                     return "NEGOCIO"
    if r.get("fp", 0) >= 5:               return "CODIGO"
    if r.get("est") == "conf":            return "CONVENCION"
    if r.get("est") == "inf":             return "INFERIDO"
    return "AMBIGUO"

CATL = {"PREFIJO":"prefijo","ACCION":"acción","ENTIDAD":"entidad","MODIF":"modif",
        "REG":"regulatorio","AMBIGUO":"ambiguo","?":"—"}

atoms = [{**r, "tipo":"atómico"} for r in INV["atomos"]]
comps = [{**r, "tipo":"compuesto"} for r in INV["compuestos"]]
cands = [{"term":c["frag"], "cat":"?", "mean":"(sin significado asignado)", "est":"-",
          "deco":"", "fn":c["frec"], "fp":0, "tipo":"candidato"} for c in INV["candidatos"]]

for r in atoms + comps:
    r["fuente"] = fuente(r)
    r["imp"] = r.get("fn", 0) + r.get("fp", 0)
for r in cands:
    r["fuente"] = "CANDIDATO"; r["imp"] = r["fn"]

# TIER 1 — convención de alto impacto: OBJETOS DE NEGOCIO (entidad/modif/reg),
# no verbos ni prefijos genéricos (esos son inequívocos y no requieren SME)
tier1 = sorted([r for r in atoms + comps
                if r["fuente"] == "CONVENCION" and r["cat"] in ("ENTIDAD", "MODIF", "REG")],
               key=lambda r: -r["imp"])[:40]
# TIER 2 — ambiguos e inferidos con hipótesis a decidir
tier2 = sorted([r for r in atoms + comps if r["fuente"] in ("AMBIGUO", "INFERIDO")],
               key=lambda r: -r["imp"])[:40]
# TIER 3 — candidatos sin significado (fragmentos frecuentes) — filtra ruido de sufijos
NOISE = {"cion","ion","ciones","ero","eda","tura","ual","ito","tante","cial","inte",
         "esar","erro","tal","ent","ceso","gistro","racion","itor","uesta","pvchr",
         "pchr","pdt","pint","pde","_funcionc","_rq","dinya","trama"}
tier3 = sorted([r for r in cands if r["term"] not in NOISE and len(r["term"]) > 2],
               key=lambda r: -r["imp"])[:35]

def tabla(rows, cols_extra=""):
    L = [f"| # | Término | Hipótesis actual | Cat | Impacto | ¿Correcto? | Significado correcto (si ✗) |",
         "|--:|---|---|---|--:|:--:|---|"]
    for i, r in enumerate(rows, 1):
        deco = f" _(={r['deco']})_" if r.get("deco") else ""
        hip = (r["mean"] or "").replace("|", "/")
        L.append(f"| {i} | `{r['term']}` | {hip}{deco} | {CATL.get(r['cat'],r['cat'])} | {r['imp']} | ☐ | |")
    return "\n".join(L)

imp1 = sum(r["imp"] for r in tier1)
imp2 = sum(r["imp"] for r in tier2)
imp3 = sum(r["imp"] for r in tier3)

md = f"""# Informix · Lista de Validación SME — Vocabulario

> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Para:** sesión HITL con Domain Expert / DBA de BanCoppel · **Generado:** 2026-07-03

Términos del vocabulario **sin evidencia dura** (no confirmados por código, SME ni fuente de negocio), ordenados por **impacto** = frecuencia con que aparecen (cuántos SPs se interpretan mal si la hipótesis es incorrecta).

**Cómo usar:** por cada fila, marca la casilla `¿Correcto?` (☑ si la hipótesis es correcta, ✗ si no) y escribe el significado correcto en la última columna. Al terminar, cada confirmación se agrega a `sp_vocab.py` y el análisis se regenera — subiendo la **certeza dura** del vocabulario (hoy 25%).

Prioridad: **Tier 1** = mayor riesgo (los di por buenos sin verificar, y son muy usados) · **Tier 2** = ambiguos que requieren decisión · **Tier 3** = fragmentos frecuentes aún sin significado.

---

## 🔴 Tier 1 · Convención de alto impacto — *verificar que mi interpretación es correcta*

{len(tier1)} términos · impacto acumulado {imp1:,} apariciones. Objetos de negocio (entidades/modificadores) que asigné por convención; **suenan bien pero nadie los ha confirmado**. Un error aquí se propaga a muchos SPs. *(Los verbos y prefijos genéricos — `sp`, `cons`, `valida`, `genera` — se consideran inequívocos y no se listan.)*

{tabla(tier1)}

---

## 🟠 Tier 2 · Ambiguos / inferidos — *decidir entre lecturas posibles*

{len(tier2)} términos · impacto {imp2:,}. Tienen ≥2 significados plausibles o son abreviaturas sin expandir.

{tabla(tier2)}

---

## ⚪ Tier 3 · Candidatos sin significado — *nombrar el término*

{len(tier3)} fragmentos frecuentes (filtrado el ruido de segmentación) · impacto {imp3:,}. Aparecen mucho pero aún no tienen entrada en el vocabulario.

{tabla(tier3)}

---

## Cómo se cierra el ciclo

```
1. SME marca ✗ y escribe el significado correcto en este documento
2. Editar sp_vocab.py:  "termino": ("CATEGORIA", "significado confirmado — SME", "conf"),
3. python extract-journeys.py && python mine-source.py && python build-catalog.py
   && python build-vocab-inventory.py && python build-vocab-report.py
4. La certeza dura sube y estos términos pasan a evidencia 🧑 SME
```

**Impacto potencial:** validar estos {len(tier1)+len(tier2)+len(tier3)} términos cubre {imp1+imp2+imp3:,} apariciones — el grueso del vocabulario de alto uso. Prioriza Tier 1 (máximo riesgo/beneficio).

*Generado por Specialist — Informix SPL Analysis · Etapa 3 · fuente: vocabulary-inventory.json + build-sme-worklist.py*
"""

open(BASE + "knowledge-base/sme-validation-worklist-bcop.md", "w", encoding="utf-8").write(md)
print(f"knowledge-base/sme-validation-worklist-bcop.md escrito.")
print(f"  Tier 1 (convención alto impacto): {len(tier1)} · impacto {imp1:,}")
print(f"  Tier 2 (ambiguos/inferidos):      {len(tier2)} · impacto {imp2:,}")
print(f"  Tier 3 (candidatos):              {len(tier3)} · impacto {imp3:,}")
print(f"  Total a validar: {len(tier1)+len(tier2)+len(tier3)} términos · {imp1+imp2+imp3:,} apariciones")