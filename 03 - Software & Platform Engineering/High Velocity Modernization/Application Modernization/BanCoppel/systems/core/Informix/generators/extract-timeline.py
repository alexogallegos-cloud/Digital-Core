#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
extract-timeline.py — Extrae fechas de creación/modificación y autoría de los
COMENTARIOS del código SPL (única fuente: Informix no guarda metadata de fecha).
Estima antigüedad y actividad por SP y por dominio.

Genera: timeline-code-bcop.md · enriquece flow-data.json (campo "years") opcional
Etapa 3 — Business Logic Extraction · Specialist Informix SPL · SPE-AM-001
"""
import json, re, os
from collections import Counter, defaultdict

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/Informix/")
SRC = BASE + "source/informix/"
CG = json.load(open(BASE + "portal/data/callgraph-data.json", encoding="utf-8"))

RE_CREATE = re.compile(r"create\s+(?:procedure|function)\b", re.I)
def isolate(t):
    ms = list(RE_CREATE.finditer(t))
    return t[ms[0].start():ms[1].start()] if len(ms) >= 2 else t

# año válido 1998-2026; fechas dd/mm/yyyy, yyyy/mm/dd, dd-mm-yyyy
RE_YEAR = re.compile(r"\b(199[89]|20[0-2]\d)\b")
RE_AUTOR = re.compile(r"(?:autor|realiz[oó]|modific[oó](?:\s+por)?|elabor[oó])\s*[:\-]\s*([A-Za-zÁÉÍÓÚñÑ][\w .]{2,35})", re.I)
RE_MODLINE = re.compile(r"(modific|ultima|cambio|actualiz|ajuste)", re.I)
RE_CRELINE = re.compile(r"(creaci|alta|realiz|autor|elabor)", re.I)

DOM = {"bdicnweb":"D01","bdinteg":"D02","bdicred":"D03","bdicheq":"D04","bdisac":"D05",
       "bdisolic":"D06","bdiaclaracion":"D07","bdispei":"D08","bdimnsj":"D09","bdisuc":"D10",
       "bdicobranza":"D11","bdicont":"D12"}

recs = []       # por SP: {sp, db, dom, y_min, y_max, n_years, autores}
year_hist = Counter()      # histograma de TODOS los años (actividad)
year_create = Counter()    # años de creación (min por SP)
year_mod = Counter()       # años de última mod (max por SP)
autores = Counter()
by_dom_years = defaultdict(list)
n_sp = n_with_date = 0

for node in CG["graph"]["nodes"]:
    db, sp = node["id"].split(":", 1)
    fp = SRC + f"{db}_{sp}.sql"
    if not os.path.exists(fp):
        continue
    n_sp += 1
    txt = isolate(open(fp, encoding="utf-8", errors="replace").read())
    years = set()
    aut = set()
    for ln in txt.split("\n"):
        s = ln.strip()
        if not (s.startswith("--") or s.startswith("{")):
            continue
        for y in RE_YEAR.findall(s):
            yi = int(y)
            years.add(yi); year_hist[yi] += 1
        ma = RE_AUTOR.search(s)
        if ma:
            nm = re.sub(r"\s+", " ", ma.group(1)).strip(" .-")
            if len(nm) >= 3 and not nm.isdigit():
                aut.add(nm)
    if years:
        n_with_date += 1
        ymin, ymax = min(years), max(years)
        year_create[ymin] += 1
        year_mod[ymax] += 1
        by_dom_years[DOM.get(db, db)].append(ymax)
        for a in aut:
            autores[a] += 1
        recs.append({"sp": sp, "db": db, "dom": DOM.get(db, db),
                     "y_min": ymin, "y_max": ymax, "n_years": len(years),
                     "autores": sorted(aut)[:3]})

# ── reporte ──
def bar(n, mx, w=30):
    return "█" * int(round(w * n / mx)) if mx else ""

L = ["# Informix · Línea Temporal del Código (creación / modificación)",
 "",
 "> **Componente:** Informix · SPE-AM-001 · Etapa 3 · **Generado:** 2026-07-05 por `extract-timeline.py`  ",
 f"> **{n_with_date:,} de {n_sp:,} SPs** ({100*n_with_date//n_sp if n_sp else 0}%) tienen fecha documentada en comentarios.",
 "",
 "> ⚠ **Fuente = comentarios del código, no metadata de sistema.** Informix no guarda fecha de "
 "creación/modificación de SPs; el `mtime` del `.sql` es la fecha del dump. Las fechas son las que "
 "**el desarrollador escribió** en el header/bitácora — pueden faltar o estar desactualizadas.",
 "",
 "---", "",
 "## Actividad por año (todas las fechas mencionadas)", "",
 "```"]
mx = max(year_hist.values()) if year_hist else 1
for y in range(min(year_hist or [2000]), max(year_hist or [2026]) + 1):
    n = year_hist.get(y, 0)
    L.append(f"{y}  {bar(n, mx)} {n}")
L.append("```")
L += ["", "## Antigüedad de la última modificación", "",
 "| Rango | SPs con fecha | Interpretación |",
 "|-------|--------------:|----------------|"]
buckets = [("2023–2026","reciente — lógica activa/en evolución",lambda y:y>=2023),
           ("2018–2022","media",lambda y:2018<=y<=2022),
           ("2013–2017","antigua",lambda y:2013<=y<=2017),
           ("≤ 2012","legacy profundo — estable o dead code candidato",lambda y:y<=2012)]
for lbl, interp, f in buckets:
    c = sum(1 for r in recs if f(r["y_max"]))
    L.append(f"| **{lbl}** | {c} | {interp} |")
L += ["", "## Antigüedad por dominio (año de última modificación)", "",
 "| Dominio | SPs c/fecha | Más antiguo | Más reciente | Mediana |",
 "|---------|------------:|:-----------:|:------------:|:-------:|"]
for dom in sorted(by_dom_years):
    ys = sorted(by_dom_years[dom])
    med = ys[len(ys)//2]
    L.append(f"| {dom} | {len(ys)} | {ys[0]} | {ys[-1]} | {med} |")
L += ["", "## Autores más frecuentes (bitácora)", ""]
for a, c in autores.most_common(12):
    L.append(f"- {a} — {c} SPs")
L += ["", "## SPs modificados recientemente (2024+) — lógica activa", "",
 "| SP | Dominio | Creación aprox | Última mod |",
 "|----|---------|:--------------:|:----------:|"]
for r in sorted([r for r in recs if r["y_max"] >= 2024], key=lambda r: -r["y_max"])[:20]:
    L.append(f"| `{r['sp']}` | {r['dom']} | {r['y_min']} | {r['y_max']} |")
L += ["", "---", "",
 "## Uso para modernización", "",
 "- **Reciente (2023+)** = lógica **activa/en evolución** → mayor riesgo de cambio durante la migración; "
 "coordinar congelamiento de código con el cliente.",
 "- **Legacy profundo (≤2012) sin modificaciones** = estable (bajo riesgo) **o dead code** → cruzar con "
 "`fan_in` del call graph: antiguo + fan_in 0 = candidato a retiro.",
 "- **Antigüedad + complejidad** (ver `orchestrators-complexity-bcop.md`): un mega-orquestador antiguo "
 "y aún modificado es la peor deuda técnica.",
 "- **Autoría**: identifica a los desarrolladores clave para las sesiones de validación de conocimiento tribal.",
 "",
 "> **Limitación:** cobertura parcial (solo SPs con fecha en comentarios); formatos de fecha heterogéneos "
 "(dd/mm/yyyy, yyyy/mm/dd, 'Mes-año'); una fecha en comentario no garantiza que sea la última modificación real.",
 "",
 "*Generado por Specialist — Informix SPL Analysis · Etapa 3 · fuente: comentarios en source/*"]

open(BASE + "knowledge-base/timeline-code-bcop.md", "w", encoding="utf-8").write("\n".join(L))
print(f"knowledge-base/timeline-code-bcop.md escrito · {n_with_date:,}/{n_sp:,} SPs con fecha ({100*n_with_date//n_sp if n_sp else 0}%)")
print(f"  rango de años: {min(year_hist) if year_hist else '—'}–{max(year_hist) if year_hist else '—'}")
print(f"  última mod 2023+: {sum(1 for r in recs if r['y_max']>=2023)} · ≤2012: {sum(1 for r in recs if r['y_max']<=2012)}")
print(f"  top años de última mod: " + " · ".join(f"{y}:{c}" for y,c in year_mod.most_common(6)))