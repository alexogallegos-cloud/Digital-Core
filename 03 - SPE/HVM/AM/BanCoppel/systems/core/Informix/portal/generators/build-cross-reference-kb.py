#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-cross-reference-kb.py
Informix — Cross-Reference Knowledge Base Generator
Etapa 3 — Conecta vocabulary, business rules y callgraph en KB transversal

Fuentes:
  business-rules-v2.json   — 7795 reglas enriquecidas
  vocabulary-inventory.json — 727 términos (atomos + compuestos)
  callgraph-data.json       — 3761 nodos, 34279 edges

Output: knowledge-base/cross-reference/ (4 archivos MD)
"""

import json
import os
import sys
import time
from collections import defaultdict, Counter

sys.stdout.reconfigure(encoding="utf-8")
t0 = time.time()

BASE = (
    "c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
    "03 - SPE/HVM/AM/BanCoppel/Informix/"
)
OUTPUT_DIR = BASE + "knowledge-base/cross-reference/"
HEADER = (
    "> **Componente:** Informix · SPE-AM-001 · "
    "Etapa 3 — Cross-Reference KB · Generado: 2026-08-02\n\n"
)

# ─── Load data ─────────────────────────────────────────────────────────────────
print("  Loading business-rules-v2.json...")
with open(BASE + "portal/data/business-rules-v2.json", "r", encoding="utf-8") as f:
    rules_data = json.load(f)
rules = rules_data["rules"]

print("  Loading vocabulary-inventory.json...")
with open(BASE + "knowledge-base/vocabulary-inventory.json", "r", encoding="utf-8") as f:
    vocab_data = json.load(f)
vocab_atomos   = vocab_data.get("atomos", [])
vocab_compuestos = vocab_data.get("compuestos", [])
all_vocab_terms = vocab_atomos + vocab_compuestos

print("  Loading callgraph-data.json...")
with open(BASE + "portal/data/callgraph-data.json", "r", encoding="utf-8") as f:
    cg_data = json.load(f)
cg_nodes = cg_data["graph"]["nodes"]
cg_edges = cg_data["graph"]["edges"]

os.makedirs(OUTPUT_DIR, exist_ok=True)
print(f"  Data loaded in {time.time()-t0:.1f}s")

# ─── Callgraph indexes ─────────────────────────────────────────────────────────
node_by_label = {}   # sp_name → node dict
node_by_id    = {}   # db:sp   → node dict
for node in cg_nodes:
    node_by_label[node["label"]] = node
    node_by_id[node["id"]]       = node

# Callers/callees per sp label (deduplicated sets)
callers_by_sp  = defaultdict(set)   # sp → {caller_sp, ...}
callees_by_sp  = defaultdict(set)   # sp → {callee_sp, ...}
for edge in cg_edges:
    fr = edge["from"]
    to = edge["to"]
    fr_lbl = fr.split(":", 1)[1] if ":" in fr else fr
    to_lbl = to.split(":", 1)[1] if ":" in to else to
    callers_by_sp[to_lbl].add(fr_lbl)
    callees_by_sp[fr_lbl].add(to_lbl)

# ─── Vocabulary lookup ─────────────────────────────────────────────────────────
vocab_meta = {}   # term → {mean, bc, bc_name, cat}
for v in all_vocab_terms:
    t = v.get("term", "").strip()
    if t:
        vocab_meta[t] = {
            "mean":    v.get("mean", ""),
            "bc":      v.get("bc", ""),
            "bc_name": v.get("bc_name", ""),
            "cat":     v.get("cat", ""),
        }

# ─── SP-level aggregation from rules ──────────────────────────────────────────
sp_rules_map = defaultdict(list)          # (sp, db) → [rules]
for r in rules:
    sp_rules_map[(r["sp"], r["db"])].append(r)

CONF_RANK = {"norma": 0, "formula": 1, "literal": 2, "infer": 3}

def best_explicacion(rule_list):
    """Return (explicacion, expl_conf) for the highest-confidence rule."""
    best = None
    best_rank = 99
    for r in rule_list:
        expl = r.get("explicacion", "")
        if not expl:
            continue
        rank = CONF_RANK.get(r.get("expl_conf", "infer"), 3)
        if rank < best_rank:
            best_rank = rank
            best = (expl, r.get("expl_conf", "infer"))
    return best or ("", "infer")

def domain_code(dominio):
    """Extract Dxx code from dominio string like 'D07 Aclar.'"""
    if dominio and len(dominio) >= 3 and dominio[0] == "D" and dominio[1:3].isdigit():
        return dominio[:3]
    return dominio[:8] if dominio else "—"

sp_agg = {}   # (sp, db) → agg dict
for (sp, db), sp_rule_list in sp_rules_map.items():
    tipo_counts   = Counter(r["tipo"] for r in sp_rule_list)
    cat_counts    = Counter(r["categoria"] for r in sp_rule_list)
    dominant_cat  = cat_counts.most_common(1)[0][0] if cat_counts else ""

    # Vocab terms (deduplicated term→mean)
    vocab_terms = {}
    for r in sp_rule_list:
        for vd in r.get("vocab_detail", []):
            term = vd.get("term", "").strip()
            if term and term not in vocab_terms:
                vocab_terms[term] = vd.get("mean", vocab_meta.get(term, {}).get("mean", ""))
    # Also from vocab_refs
    for r in sp_rule_list:
        for vref in r.get("vocab_refs", []):
            if isinstance(vref, str) and vref.strip() and vref not in vocab_terms:
                vocab_terms[vref] = vocab_meta.get(vref, {}).get("mean", "")

    # Regulatory data: reg_data[regulator] = [norma_text, ...]
    reg_data = defaultdict(list)
    for r in sp_rule_list:
        for reg_item in r.get("reg", []):
            if isinstance(reg_item, list) and len(reg_item) >= 2:
                norm_text = reg_item[1]
                if norm_text and norm_text not in reg_data[reg_item[0]]:
                    reg_data[reg_item[0]].append(norm_text)
            elif isinstance(reg_item, str) and reg_item:
                reg_data[reg_item]  # ensure key exists

    # Count rules with regulatory annotations
    reg_rule_count = sum(1 for r in sp_rule_list if r.get("reg"))

    has_riesgo = any(r.get("riesgo") for r in sp_rule_list)
    dominio    = sp_rule_list[0].get("dominio", "")
    node       = node_by_label.get(sp, {})
    fan_in     = node.get("fan_in", 0)
    fan_out    = node.get("fan_out", 0)
    density    = len(sp_rule_list) * 2 + len(vocab_terms) * 3 + fan_in / 100

    expl, expl_conf = best_explicacion(sp_rule_list)

    sp_agg[(sp, db)] = {
        "sp":             sp,
        "db":             db,
        "rule_count":     len(sp_rule_list),
        "tipo_counts":    dict(tipo_counts),
        "cat_counts":     dict(cat_counts),
        "dominant_cat":   dominant_cat,
        "vocab_terms":    vocab_terms,
        "reg_data":       dict(reg_data),
        "reg_rule_count": reg_rule_count,
        "has_riesgo":     has_riesgo,
        "dominio":        dominio,
        "fan_in":         fan_in,
        "fan_out":        fan_out,
        "density":        density,
        "explicacion":    expl,
        "expl_conf":      expl_conf,
    }

# ─── Vocab → SPs coverage ─────────────────────────────────────────────────────
term_to_sps = defaultdict(set)   # term → {sp, ...}
for r in rules:
    sp = r["sp"]
    for vd in r.get("vocab_detail", []):
        t = vd.get("term", "").strip()
        if t:
            term_to_sps[t].add(sp)
    for vref in r.get("vocab_refs", []):
        if isinstance(vref, str) and vref.strip():
            term_to_sps[vref.strip()].add(sp)

# ─── Helper: top-N callers/callees sorted by caller's fan_in ──────────────────
def top_callers(sp, n=3):
    callers = callers_by_sp.get(sp, set())
    return sorted(callers, key=lambda c: node_by_label.get(c, {}).get("fan_in", 0), reverse=True)[:n]

def top_callees(sp, n=3):
    callees = callees_by_sp.get(sp, set())
    return sorted(callees, key=lambda c: node_by_label.get(c, {}).get("fan_in", 0), reverse=True)[:n]

# ─── Sorted SP lists ──────────────────────────────────────────────────────────
all_sp_sorted_density = sorted(
    sp_agg.values(), key=lambda x: x["density"], reverse=True
)
all_sp_sorted_rules = sorted(
    sp_agg.values(), key=lambda x: x["rule_count"], reverse=True
)

# ─── Stats ────────────────────────────────────────────────────────────────────
stats_sps_with_rules = len(sp_agg)
stats_total_rules    = len(rules)
stats_vocab_terms    = len(all_vocab_terms)
stats_total_edges    = len(cg_edges)
stats_total_nodes    = len(cg_nodes)

print(f"  Built indexes: {stats_sps_with_rules} SPs · "
      f"{stats_total_rules} reglas · {stats_vocab_terms} vocab · "
      f"{stats_total_edges} edges")

# ═══════════════════════════════════════════════════════════════════════════════
# FILE 1: index.md
# ═══════════════════════════════════════════════════════════════════════════════
print("\n  Generating index.md...")

lines_index = []
lines_index.append(HEADER)
lines_index.append("# Cross-Reference KB — Informix\n\n")
lines_index.append(
    "Este directorio conecta el vocabulario, las reglas de negocio y el grafo de llamadas "
    "del sistema Informix en un único mapa de conocimiento navegable. Cada artefacto "
    "toma un ángulo de análisis diferente; juntos permiten responder preguntas que "
    "ninguna fuente aislada puede responder: ¿qué procedimiento concentra mayor riesgo "
    "regulatorio?, ¿qué término de negocio es transversal a más lógica?, ¿cuáles SPs "
    "son candidatos obligatorios para el golden master de migración?\n\n"
)

lines_index.append("---\n\n")
lines_index.append("## Tabla de Contenidos\n\n")
lines_index.append("| Artefacto | Descripción |\n")
lines_index.append("|-----------|-------------|\n")
lines_index.append("| [sp-rules-vocab-map.md](sp-rules-vocab-map.md) | Top 100 SPs por densidad de conocimiento · Índice por Categoría · Índice Regulatorio |\n")
lines_index.append("| [vocab-sp-coverage.md](vocab-sp-coverage.md) | Mapa vocabulario → SPs · Términos sin cobertura de reglas |\n")
lines_index.append("| [regulatory-sp-index.md](regulatory-sp-index.md) | Índice regulatorio completo por organismo: CNBV, CONDUSEF, SAT, Banxico, IPAB, TESOFE |\n\n")

lines_index.append("---\n\n")
lines_index.append("## Resumen Numérico\n\n")
lines_index.append("| Dimensión | Valor |\n")
lines_index.append("|-----------|-------|\n")
lines_index.append(f"| SPs con reglas de negocio | {stats_sps_with_rules:,} |\n")
lines_index.append(f"| Total reglas de negocio | {stats_total_rules:,} |\n")
lines_index.append(f"| Términos de vocabulario (átomos + compuestos) | {stats_vocab_terms:,} |\n")
lines_index.append(f"| Nodos en callgraph | {stats_total_nodes:,} |\n")
lines_index.append(f"| Edges en callgraph | {stats_total_edges:,} |\n")
# Regulatory counts
reg_summary = defaultdict(lambda: {"sps": set(), "rules": 0})
for (sp, db), agg in sp_agg.items():
    for reg_name, normas in agg["reg_data"].items():
        reg_summary[reg_name]["sps"].add(sp)
        reg_summary[reg_name]["rules"] += agg["reg_rule_count"]
for r in rules:
    for reg_item in r.get("reg", []):
        reg_name = reg_item[0] if isinstance(reg_item, list) else reg_item
        reg_summary[reg_name]["rules"]  # just ensure key
# Proper count
reg_rule_counts = defaultdict(int)
reg_sp_counts   = defaultdict(set)
for r in rules:
    for reg_item in r.get("reg", []):
        reg_name = reg_item[0] if isinstance(reg_item, list) else (reg_item if isinstance(reg_item, str) else "")
        if reg_name:
            reg_rule_counts[reg_name] += 1
            reg_sp_counts[reg_name].add(r["sp"])

lines_index.append(f"| SPs con anotación regulatoria | {len(set(r['sp'] for r in rules if r.get('reg'))):,} |\n")
lines_index.append(f"| Reglas con referencia regulatoria | {sum(1 for r in rules if r.get('reg')):,} |\n\n")

lines_index.append("### Distribución por Regulador\n\n")
lines_index.append("| Regulador | # Reglas | # SPs |\n")
lines_index.append("|-----------|----------|-------|\n")
for reg_name in sorted(reg_rule_counts.keys()):
    lines_index.append(f"| {reg_name} | {reg_rule_counts[reg_name]:,} | {len(reg_sp_counts[reg_name]):,} |\n")
lines_index.append("\n")

lines_index.append("### Distribución por Categoría\n\n")
lines_index.append("| Categoría | # Reglas | # SPs |\n")
lines_index.append("|-----------|----------|-------|\n")
cat_rule_counts = Counter(r["categoria"] for r in rules)
cat_sp_counts   = defaultdict(set)
for r in rules:
    cat_sp_counts[r["categoria"]].add(r["sp"])
for cat, cnt in cat_rule_counts.most_common():
    lines_index.append(f"| {cat} | {cnt:,} | {len(cat_sp_counts[cat]):,} |\n")
lines_index.append("\n")

lines_index.append("### Distribución por Dominio (Top 15)\n\n")
lines_index.append("| Dominio | # Reglas | # SPs |\n")
lines_index.append("|---------|----------|-------|\n")
dom_rule_counts = Counter(r["dominio"] for r in rules)
dom_sp_counts   = defaultdict(set)
for r in rules:
    dom_sp_counts[r["dominio"]].add(r["sp"])
for dom, cnt in dom_rule_counts.most_common(15):
    lines_index.append(f"| {dom} | {cnt:,} | {len(dom_sp_counts[dom]):,} |\n")
lines_index.append("\n")

lines_index.append("---\n\n")
lines_index.append("## Propósito de la Cross-Reference\n\n")
lines_index.append(
    "El objetivo es conectar el vocabulario, las reglas de negocio y el grafo de llamadas "
    "en un único mapa de conocimiento navegable que permita:\n\n"
    "- Identificar los procedimientos de mayor criticidad para el golden master de migración\n"
    "- Rastrear cualquier término de negocio hacia todos los SPs que lo implementan\n"
    "- Priorizar la cobertura de pruebas por densidad regulatoria y de riesgo\n"
    "- Detectar gaps de extracción donde el vocabulario no tiene cobertura en reglas\n"
    "- Establecer el blast radius de cualquier cambio en el callgraph\n\n"
)
lines_index.append(
    "Estos artefactos son input directo a las fases BUILD y TEST del SDLC del componente "
    "SPE-AM-001 y alimentan el Digital Brain SQLite semántico (BCOPBrain).\n"
)

index_path = OUTPUT_DIR + "index.md"
with open(index_path, "w", encoding="utf-8") as f:
    f.writelines(lines_index)
print(f"    index.md → {len(lines_index)} líneas")

# ═══════════════════════════════════════════════════════════════════════════════
# FILE 2: sp-rules-vocab-map.md
# ═══════════════════════════════════════════════════════════════════════════════
print("  Generating sp-rules-vocab-map.md...")

lines_map = []
lines_map.append(HEADER)
lines_map.append("# SP — Reglas — Vocabulario: Mapa Central\n\n")
lines_map.append(
    "Mapa cruzado de los procedimientos almacenados con mayor concentración de conocimiento de negocio, "
    "indexado por categoría funcional y por regulador. La densidad de conocimiento se calcula como: "
    "`rule_count × 2 + vocab_terms_únicos × 3 + fan_in / 100`.\n\n"
)
lines_map.append("---\n\n")

# ─── SECCIÓN A: Top 100 SPs por densidad ──────────────────────────────────────
lines_map.append("## Sección A — Top 100 SPs por Densidad de Conocimiento\n\n")
lines_map.append(
    "Ordenados por densidad descendente. Para cada SP se muestra el perfil completo "
    "de reglas, vocabulario referenciado y posición en el callgraph.\n\n"
)

top100 = all_sp_sorted_density[:100]

for rank, agg in enumerate(top100, 1):
    sp        = agg["sp"]
    db        = agg["db"]
    dcode     = domain_code(agg["dominio"])
    rc        = agg["rule_count"]
    tipos     = agg["tipo_counts"]
    dom_cat   = agg["dominant_cat"]
    regs      = agg["reg_data"]
    has_r     = agg["has_riesgo"]
    vterms    = agg["vocab_terms"]
    expl      = agg["explicacion"]
    expl_c    = agg["expl_conf"]
    fi        = agg["fan_in"]

    lines_map.append(f"#### `{sp}` · {db} · {dcode}\n\n")

    # Tipo summary
    tipo_parts = []
    for tipo_name, cnt in sorted(tipos.items(), key=lambda x: -x[1]):
        tipo_parts.append(f"{tipo_name} {cnt}")
    tipo_str = ", ".join(tipo_parts) if tipo_parts else "—"
    lines_map.append(f"- **Reglas**: {rc} (tipos: {tipo_str})\n")
    lines_map.append(f"- **Categoría dominante**: {dom_cat}\n")

    # Reguladores
    if regs:
        lines_map.append(f"- **Reguladores**: {', '.join(sorted(regs.keys()))}\n")
    else:
        lines_map.append("- **Reguladores**: —\n")

    lines_map.append(f"- **Riesgo equiv.**: {'sí' if has_r else 'no'}\n")

    # Vocabulario (top 10 terms to keep manageable)
    if vterms:
        shown = list(vterms.items())[:10]
        vocab_str = ", ".join(
            f"{t} ({m})" if m and m != t else t
            for t, m in shown
        )
        suffix = f" (+{len(vterms)-10} más)" if len(vterms) > 10 else ""
        lines_map.append(f"- **Vocabulario** ({len(vterms)} términos únicos): {vocab_str}{suffix}\n")
    else:
        lines_map.append("- **Vocabulario**: —\n")

    # Explicación representativa
    if expl:
        expl_short = expl[:180] + ("..." if len(expl) > 180 else "")
        lines_map.append(f"- **Explicación representativa**: {expl_short} (conf: {expl_c})\n")
    else:
        lines_map.append("- **Explicación representativa**: —\n")

    # Callgraph
    callers_top = top_callers(sp, 3)
    callees_top = top_callees(sp, 3)
    callers_str = ", ".join(f"`{c}`" for c in callers_top) if callers_top else "—"
    callees_str = ", ".join(f"`{c}`" for c in callees_top) if callees_top else "—"
    total_callers = len(callers_by_sp.get(sp, set()))
    total_callees = len(callees_by_sp.get(sp, set()))
    lines_map.append(f"- **Llamado por** (fan_in={fi}, top 3 de {total_callers}): {callers_str}\n")
    lines_map.append(f"- **Llama a** (top 3 de {total_callees}): {callees_str}\n")
    lines_map.append("\n")

lines_map.append("---\n\n")

# ─── SECCIÓN B: Índice por Categoría ─────────────────────────────────────────
lines_map.append("## Sección B — Índice por Categoría\n\n")
lines_map.append(
    "Para cada categoría funcional, los 20 SPs con mayor número de reglas "
    "de esa categoría.\n\n"
)

# Build: category → {(sp,db) → rule_count_in_cat}
cat_sp_rule_counts = defaultdict(lambda: defaultdict(int))
for r in rules:
    cat_sp_rule_counts[r["categoria"]][(r["sp"], r["db"])] += 1

all_cats = sorted(cat_rule_counts.keys(), key=lambda c: -cat_rule_counts[c])

for cat in all_cats:
    lines_map.append(f"### {cat}\n\n")
    sp_counts_in_cat = cat_sp_rule_counts[cat]
    top20 = sorted(sp_counts_in_cat.items(), key=lambda x: -x[1])[:20]
    lines_map.append("| SP | DB | # Reglas | Explicación representativa |\n")
    lines_map.append("|----|----|----------|----------------------------|\n")
    for (sp, db), cnt in top20:
        agg    = sp_agg.get((sp, db), {})
        expl   = agg.get("explicacion", "")
        expl_s = (expl[:80] + "...") if len(expl) > 80 else expl
        lines_map.append(f"| `{sp}` | {db} | {cnt} | {expl_s} |\n")
    lines_map.append("\n")

lines_map.append("---\n\n")

# ─── SECCIÓN C: Índice Regulatorio → SPs ─────────────────────────────────────
lines_map.append("## Sección C — Índice Regulatorio\n\n")
lines_map.append(
    "Para cada organismo regulador, los 15 SPs con mayor número de reglas "
    "con anotación de ese regulador.\n\n"
)

# Build: regulator → {(sp,db) → {rule_count, top_norma}}
reg_sp_detail = defaultdict(lambda: defaultdict(lambda: {"count": 0, "normas": set()}))
for r in rules:
    for reg_item in r.get("reg", []):
        if isinstance(reg_item, list) and len(reg_item) >= 2:
            reg_name  = reg_item[0]
            norma_txt = reg_item[1]
        elif isinstance(reg_item, str):
            reg_name  = reg_item
            norma_txt = ""
        else:
            continue
        key = (r["sp"], r["db"])
        reg_sp_detail[reg_name][key]["count"] += 1
        if norma_txt:
            reg_sp_detail[reg_name][key]["normas"].add(norma_txt)

for reg_name in sorted(reg_sp_detail.keys()):
    sp_counts = reg_sp_detail[reg_name]
    top15     = sorted(sp_counts.items(), key=lambda x: -x[1]["count"])[:15]
    lines_map.append(f"### {reg_name}\n\n")
    lines_map.append("| SP | DB | # Reglas reg. | Top norma |\n")
    lines_map.append("|----|----|--------------|-----------|\n")
    for (sp, db), detail in top15:
        cnt   = detail["count"]
        normas = sorted(detail["normas"])
        top_n = normas[0][:80] + ("..." if len(normas[0]) > 80 else "") if normas else "—"
        lines_map.append(f"| `{sp}` | {db} | {cnt} | {top_n} |\n")
    lines_map.append("\n")

map_path = OUTPUT_DIR + "sp-rules-vocab-map.md"
with open(map_path, "w", encoding="utf-8") as f:
    f.writelines(lines_map)
print(f"    sp-rules-vocab-map.md → {len(lines_map)} líneas")

# ═══════════════════════════════════════════════════════════════════════════════
# FILE 3: vocab-sp-coverage.md
# ═══════════════════════════════════════════════════════════════════════════════
print("  Generating vocab-sp-coverage.md...")

lines_vocab = []
lines_vocab.append(HEADER)
lines_vocab.append("# Vocabulario → Cobertura de SPs\n\n")
lines_vocab.append(
    "Mapa de cada término del vocabulario hacia los procedimientos almacenados que "
    "lo referencian en reglas de negocio. Un término con alta cobertura de SPs indica "
    "un concepto transversal crítico; términos sin cobertura son candidatos a gap de extracción.\n\n"
)
lines_vocab.append("---\n\n")

# Build full term list with SP counts
term_coverage = []
all_known_terms = set(v.get("term", "") for v in all_vocab_terms if v.get("term"))
for term in all_known_terms:
    sps    = term_to_sps.get(term, set())
    vmeta  = vocab_meta.get(term, {})
    term_coverage.append({
        "term":    term,
        "mean":    vmeta.get("mean", ""),
        "bc":      vmeta.get("bc", ""),
        "bc_name": vmeta.get("bc_name", ""),
        "cat":     vmeta.get("cat", ""),
        "sp_count": len(sps),
        "sps":     sorted(sps),
    })

# Terms referenced in rules but not in vocabulary inventory
extra_terms_in_rules = set(term_to_sps.keys()) - all_known_terms
for term in extra_terms_in_rules:
    sps = term_to_sps.get(term, set())
    term_coverage.append({
        "term":    term,
        "mean":    "",
        "bc":      "",
        "bc_name": "—",
        "cat":     "—",
        "sp_count": len(sps),
        "sps":     sorted(sps),
    })

# Sort by SP count descending
term_coverage.sort(key=lambda x: -x["sp_count"])

# Top 150 with ≥2 SPs
top_terms = [t for t in term_coverage if t["sp_count"] >= 2][:150]
zero_terms = [t for t in term_coverage if t["sp_count"] == 0 and t["term"] in all_known_terms]

lines_vocab.append(f"## Top {len(top_terms)} Términos por Cobertura de SPs (≥ 2 SPs)\n\n")
lines_vocab.append(f"_Total términos con cobertura ≥ 1 SP: {sum(1 for t in term_coverage if t['sp_count'] >= 1)}_\n\n")
lines_vocab.append("| # | Término | Significado | BC | # SPs | SPs (top 5) |\n")
lines_vocab.append("|---|---------|-------------|----|----|----------|\n")

for i, tc in enumerate(top_terms, 1):
    term   = tc["term"]
    mean   = tc["mean"] or "—"
    bc     = tc["bc"] or "—"
    spc    = tc["sp_count"]
    top5   = ", ".join(f"`{s}`" for s in tc["sps"][:5])
    suffix = f" (+{spc-5} más)" if spc > 5 else ""
    lines_vocab.append(f"| {i} | **{term}** | {mean[:60]} | {bc} | {spc} | {top5}{suffix} |\n")

lines_vocab.append("\n---\n\n")

# Single-SP terms summary
single_terms = [t for t in term_coverage if t["sp_count"] == 1]
lines_vocab.append(f"## Términos con Cobertura de 1 SP ({len(single_terms)} términos)\n\n")
lines_vocab.append(
    f"Estos {len(single_terms)} términos aparecen en exactamente un SP. "
    "Son relevantes pero no transversales.\n\n"
)
lines_vocab.append("| Término | Significado | BC | SP |\n")
lines_vocab.append("|---------|-------------|----|----|---|\n")
for tc in single_terms[:100]:
    sp_name = tc["sps"][0] if tc["sps"] else "—"
    mean    = tc["mean"] or "—"
    bc      = tc["bc"] or "—"
    lines_vocab.append(f"| **{tc['term']}** | {mean[:60]} | {bc} | `{sp_name}` |\n")
if len(single_terms) > 100:
    lines_vocab.append(f"| _(+{len(single_terms)-100} más — omitidos por brevedad)_ | | | |\n")
lines_vocab.append("\n---\n\n")

# Zero-coverage terms = gaps
lines_vocab.append(f"## Términos sin Cobertura de Reglas — Posibles Gaps ({len(zero_terms)} términos)\n\n")
lines_vocab.append(
    "Estos términos están en el vocabulario pero no aparecen en ninguna regla de negocio extraída. "
    "Pueden indicar: (1) gaps de extracción donde el SP existe pero las reglas no fueron capturadas, "
    "(2) términos de infraestructura o prefijos que no mapean a lógica de negocio, "
    "o (3) términos del dominio que aún no tienen SP dedicado.\n\n"
)
lines_vocab.append("| # | Término | Significado | BC | Categoría |\n")
lines_vocab.append("|---|---------|-------------|----|-----------|\n")
for i, tc in enumerate(sorted(zero_terms, key=lambda x: x["term"]), 1):
    mean = tc["mean"] or "—"
    bc   = tc["bc"] or "—"
    cat  = tc["cat"] or "—"
    lines_vocab.append(f"| {i} | **{tc['term']}** | {mean[:60]} | {bc} | {cat} |\n")

vocab_path = OUTPUT_DIR + "vocab-sp-coverage.md"
with open(vocab_path, "w", encoding="utf-8") as f:
    f.writelines(lines_vocab)
print(f"    vocab-sp-coverage.md → {len(lines_vocab)} líneas")

# ═══════════════════════════════════════════════════════════════════════════════
# FILE 4: regulatory-sp-index.md
# ═══════════════════════════════════════════════════════════════════════════════
print("  Generating regulatory-sp-index.md...")

lines_reg = []
lines_reg.append(HEADER)
lines_reg.append("# Índice Regulatorio — SPs por Organismo\n\n")
lines_reg.append(
    "Índice completo de todos los procedimientos almacenados con anotación regulatoria, "
    "agrupados por organismo regulador. Estos SPs son candidatos obligatorios para el "
    "golden master de migración y requieren cobertura de pruebas de regresión regulatoria.\n\n"
)
lines_reg.append("---\n\n")

# Summary table
lines_reg.append("## Resumen por Regulador\n\n")
lines_reg.append("| Regulador | # SPs | # Reglas reg. | Normas representativas |\n")
lines_reg.append("|-----------|-------|---------------|------------------------|\n")

reg_names_sorted = sorted(
    reg_sp_detail.keys(),
    key=lambda r: -sum(d["count"] for d in reg_sp_detail[r].values())
)
for reg_name in reg_names_sorted:
    sp_dict   = reg_sp_detail[reg_name]
    total_sps = len(sp_dict)
    total_rc  = sum(d["count"] for d in sp_dict.values())
    all_normas = []
    for d in sp_dict.values():
        all_normas.extend(d["normas"])
    norma_sample = all_normas[0][:70] + "..." if all_normas and len(all_normas[0]) > 70 else (all_normas[0] if all_normas else "—")
    lines_reg.append(f"| [{reg_name}](#{reg_name.lower()}) | {total_sps} | {total_rc} | {norma_sample} |\n")
lines_reg.append("\n---\n\n")

# Per-regulator full table
for reg_name in reg_names_sorted:
    sp_dict   = reg_sp_detail[reg_name]
    total_sps = len(sp_dict)
    total_rc  = sum(d["count"] for d in sp_dict.values())

    lines_reg.append(f"## {reg_name}\n\n")
    lines_reg.append(
        f"**{total_sps} SPs** con un total de **{total_rc} reglas** con anotación {reg_name}.\n\n"
    )

    # Sort by reg rule count desc
    sorted_sps = sorted(sp_dict.items(), key=lambda x: -x[1]["count"])

    lines_reg.append("| SP | DB | Dominio | # Reglas reg. | Normas relevantes | Explicación |\n")
    lines_reg.append("|----|----|---------|--------------|--------------------|-------------|\n")

    for (sp, db), detail in sorted_sps:
        cnt    = detail["count"]
        normas = sorted(detail["normas"])
        agg    = sp_agg.get((sp, db), {})
        dom    = agg.get("dominio", "—")
        expl   = agg.get("explicacion", "")
        expl_s = (expl[:70] + "...") if len(expl) > 70 else expl

        # Normas: join first 2
        if normas:
            norma_disp = " | ".join(n[:60] + ("..." if len(n) > 60 else "") for n in normas[:2])
            if len(normas) > 2:
                norma_disp += f" (+{len(normas)-2} más)"
        else:
            norma_disp = "—"

        lines_reg.append(f"| `{sp}` | {db} | {dom} | {cnt} | {norma_disp} | {expl_s} |\n")

    lines_reg.append(
        f"\n> **Nota:** Los {total_sps} SPs listados son candidatos obligatorios para el "
        f"golden master de migración en el segmento {reg_name}. "
        "Requieren test cases con datos de golden set regulatorio y validación cruzada con el SME regulatorio.\n\n"
    )
    lines_reg.append("---\n\n")

# Closing note on SPs with multiple regulators
multi_reg_sps = [
    (sp, db, agg)
    for (sp, db), agg in sp_agg.items()
    if len(agg["reg_data"]) >= 2
]
multi_reg_sps.sort(key=lambda x: (-len(x[2]["reg_data"]), -x[2]["reg_rule_count"]))

lines_reg.append("## SPs con Múltiples Reguladores\n\n")
lines_reg.append(
    f"Los siguientes {len(multi_reg_sps)} SPs tienen anotaciones de más de un organismo regulador — "
    "son de máxima prioridad para el golden master.\n\n"
)
lines_reg.append("| SP | DB | # Reguladores | Reguladores | # Reglas reg. |\n")
lines_reg.append("|----|----|-----------|--------------|---------|\n")
for sp, db, agg in multi_reg_sps[:50]:
    regs_str = ", ".join(sorted(agg["reg_data"].keys()))
    lines_reg.append(f"| `{sp}` | {db} | {len(agg['reg_data'])} | {regs_str} | {agg['reg_rule_count']} |\n")
if len(multi_reg_sps) > 50:
    lines_reg.append(f"| _(+{len(multi_reg_sps)-50} más)_ | | | | |\n")
lines_reg.append("\n")

reg_path = OUTPUT_DIR + "regulatory-sp-index.md"
with open(reg_path, "w", encoding="utf-8") as f:
    f.writelines(lines_reg)
print(f"    regulatory-sp-index.md → {len(lines_reg)} líneas")

# ─── Final summary ─────────────────────────────────────────────────────────────
elapsed = time.time() - t0
print()
print("=" * 60)
print("  Cross-Reference KB generada en {:.1f}s".format(elapsed))
print("=" * 60)
print(f"  index.md              → {len(lines_index):>6,} líneas")
print(f"  sp-rules-vocab-map.md → {len(lines_map):>6,} líneas")
print(f"  vocab-sp-coverage.md  → {len(lines_vocab):>6,} líneas")
print(f"  regulatory-sp-index.md→ {len(lines_reg):>6,} líneas")
print(f"  Total líneas escritas → {len(lines_index)+len(lines_map)+len(lines_vocab)+len(lines_reg):>6,}")
print()
print(f"  Cobertura: {stats_sps_with_rules} SPs · {stats_total_rules} reglas · "
      f"{stats_vocab_terms} vocab · {stats_total_edges} edges")
print(f"  Output: {OUTPUT_DIR}")
