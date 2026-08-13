#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
analyze-vocab-enrichment.py — Análisis exhaustivo del vocabulario Informix.

Genera output/vocab-enrichment-analysis.md con 5 secciones:
  1. UPGRADE_CANDIDATES — términos inf/gap con alta evidencia en el knowledge base
  2. Pares sinónimos/duplicados detectados
  3. Términos con scope propuesto (actualmente '—')
  4. Top 30 tokens frecuentes faltantes en vocabulario
  5. Top 20 definiciones con oportunidad de enriquecimiento

SPE-AM-001 · BanCoppel Informix · Etapa 3 · 2026-08-04
"""

import os, sys, re, sqlite3
from collections import defaultdict, Counter
from pathlib import Path

# ── Rutas ────────────────────────────────────────────────────────────────────
BASE = Path(__file__).resolve().parent.parent
DB   = BASE / "digital-brain" / "brain.db"
OUT  = BASE / "output" / "vocab-enrichment-analysis.md"

# ── Importar vocabulario vigente ──────────────────────────────────────────────
sys.path.insert(0, str(BASE / "generators"))
from sp_vocab import CAT, COMPOUND

# ── Conectar DB ───────────────────────────────────────────────────────────────
conn = sqlite3.connect(str(DB))
conn.text_factory = str          # evita errores de decode en contenido legacy
cur  = conn.cursor()

import io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
print("Informix Vocab Enrichment Analysis - SPE-AM-001")
print("=" * 55)

# ═══════════════════════════════════════════════════════════════════════════════
# UTILIDADES
# ═══════════════════════════════════════════════════════════════════════════════

KNOWN_SCOPE  = {"MIXTO","INTERFAZ-IN","INTERFAZ-OUT","EFIMERA","EFIMERA-CALCULO",
                "PERSISTE-BD","LECTURA-BD","EXCEPCION","REGULATORIO","TRANSVERSAL"}
DASH         = "—"          # em-dash: el valor '—' almacenado en brain.db

def needs_scope(scope_val: str) -> bool:
    """True si el scope no está asignado (es '—' o caracter EM-DASH o no reconocido)."""
    # El scope '—' puede estar almacenado como U+2014 (EM DASH) o como mojibake
    if scope_val in KNOWN_SCOPE:
        return False
    # Detectar EM-DASH (U+2014) o mojibake equivalente (\xe2\x80\x94 como chars latin-1)
    if scope_val == "—":   # EM dash directo
        return True
    if scope_val == "\xe2\x80\x94":  # mojibake de EM dash (3 chars)
        return True
    if len(scope_val) == 1 and ord(scope_val) == 0x2014:
        return True
    return True  # cualquier scope no reconocido

def fix_mojibake(s: str) -> str:
    """Repara el mojibake: UTF-8 bytes almacenados como chars latin-1.
    Ej: 'Ã³' (U+00C3 + U+00B3) → 'ó' (U+00F3)."""
    if not s:
        return s
    try:
        return s.encode('latin-1').decode('utf-8')
    except (UnicodeEncodeError, UnicodeDecodeError):
        return s  # ya correcto o mixto

def clean_meaning(m: str) -> str:
    fixed = fix_mojibake(m)
    return fixed.replace("�", "?").replace("\xad", "")

# ── Cargar datos base ─────────────────────────────────────────────────────────

# 1) Todos los términos del vocabulario (fuente: sp_vocab.CAT)
all_terms   = {tok: (cat, meaning, est) for tok, (cat, meaning, est) in CAT.items()
               if tok not in COMPOUND}
inf_gap     = {tok: (cat, m, e) for tok, (cat, m, e) in all_terms.items()
               if e in ("inf", "gap")}

# 2) Terms table del brain.db (scope, nivel)
cur.execute("SELECT term, cat, meaning, est, nivel, scope FROM terms")
db_terms = {r[0]: {"cat": r[1], "meaning": r[2], "est": r[3],
                    "nivel": r[4], "scope": r[5]}
            for r in cur.fetchall()}

# 3) sp_terms table — mapeo token → SPs
cur.execute("SELECT term, sp FROM sp_terms WHERE source = 'nombre'")
token_to_sps = defaultdict(set)
for term, sp in cur.fetchall():
    token_to_sps[term].add(sp)

# 4) SPs completos (id, domain, is_soul, soul_rank, fan_in)
cur.execute("SELECT id, name, db, domain, fan_in, is_soul, soul_rank FROM sps")
sps_data = {r[0]: {"name": r[1], "db": r[2], "domain": r[3],
                    "fan_in": r[4] or 0, "is_soul": r[5], "soul_rank": r[6]}
            for r in cur.fetchall()}

# 5) Souls set
soul_sps = {sp_id for sp_id, d in sps_data.items() if d["is_soul"] == 1}

# 6) Rules (sp, code, reg)
cur.execute("SELECT id, sp, code, reg, domain FROM rules")
rules_rows = [(r[0], r[1], fix_mojibake(r[2] or ""), r[3], r[4]) for r in cur.fetchall()]

# 7) Journeys (sp, biz, domain)
cur.execute("SELECT id, sp, biz, domain FROM journeys")
journeys_rows = [(r[0], r[1], fix_mojibake(r[2] or ""), r[3]) for r in cur.fetchall()]

# ── Pre-computa sets por token para reglas y journeys ────────────────────────

# Para reglas: el token puede aparecer en el nombre del SP o en el código
def build_token_rule_map():
    out = defaultdict(set)
    for rule_id, sp, code, reg, domain in rules_rows:
        sp_name  = sp.split(":")[-1] if sp else ""
        text_all = (sp_name + " " + (code or "")).lower()
        for tok in all_terms:
            # match de token como sub-cadena en texto (para shortness, exigir boundary)
            if len(tok) >= 4:
                if tok in text_all:
                    out[tok].add(rule_id)
            else:
                # tokens cortos: solo matchear si aparece como secuencia de underscores
                # o al inicio/fin de palabra en la cadena
                pattern = r'(?<![a-z])' + re.escape(tok) + r'(?![a-z])'
                if re.search(pattern, text_all):
                    out[tok].add(rule_id)
    return out

def build_token_journey_map():
    out = defaultdict(set)
    for j_id, sp, biz, domain in journeys_rows:
        text = ((sp or "") + " " + (biz or "")).lower()
        for tok in all_terms:
            if len(tok) >= 4:
                if tok in text:
                    out[tok].add(j_id)
            else:
                pattern = r'(?<![a-z])' + re.escape(tok) + r'(?![a-z])'
                if re.search(pattern, text):
                    out[tok].add(j_id)
    return out

print("  Construyendo indices token->rules y token->journeys...", end=" ", flush=True)
token_rule_map    = build_token_rule_map()
token_journey_map = build_token_journey_map()
print("listo.")

# ═══════════════════════════════════════════════════════════════════════════════
# SECCIÓN 1 — EVIDENCIA PARA TÉRMINOS inf/gap
# ═══════════════════════════════════════════════════════════════════════════════

print("  Sección 1: evidencia inf/gap…", end=" ", flush=True)

# Clasificación:
# UPGRADE_CANDIDATE : sp_hits >= 10  OR  (sp_hits >= 5 AND rules_hits + journey_hits >= 3)
# STAYS_INF         : sp_hits 3-9    OR  (sp_hits 1-4  AND rules/journey hits > 0)
# NEEDS_SME         : sp_hits 1-2    AND ambiguity markers en meaning
# REMOVE_CANDIDATE  : sp_hits == 0

section1 = []

for tok, (cat, meaning, est) in sorted(inf_gap.items()):
    sp_set      = token_to_sps.get(tok, set())
    rule_set    = token_rule_map.get(tok, set())
    journey_set = token_journey_map.get(tok, set())
    soul_hit    = any(sp in soul_sps for sp in sp_set)

    sp_n   = len(sp_set)
    rule_n = len(rule_set)
    jour_n = len(journey_set)

    # Dominios únicos donde aparece este token
    domains = {sps_data[sp]["domain"] for sp in sp_set if sp in sps_data}

    # Clasificar
    if sp_n >= 10 or (sp_n >= 5 and rule_n + jour_n >= 3) or (sp_n >= 3 and soul_hit):
        classification = "UPGRADE_CANDIDATE"
    elif sp_n == 0 and rule_n == 0 and jour_n == 0:
        classification = "REMOVE_CANDIDATE"
    elif sp_n <= 2 and ("¿" in meaning or "ambiguo" in meaning.lower() or "gap" in est):
        classification = "NEEDS_SME"
    else:
        classification = "STAYS_INF"

    section1.append({
        "token":      tok,
        "cat":        cat,
        "meaning":    meaning,
        "est":        est,
        "sp_n":       sp_n,
        "rule_n":     rule_n,
        "jour_n":     jour_n,
        "soul_hit":   soul_hit,
        "domains":    sorted(domains),
        "class":      classification,
    })

section1.sort(key=lambda x: (-x["sp_n"], x["token"]))
print("listo.")

# ═══════════════════════════════════════════════════════════════════════════════
# SECCIÓN 2 — SINÓNIMOS / DUPLICADOS
# ═══════════════════════════════════════════════════════════════════════════════

print("  Sección 2: pares sinónimos…", end=" ", flush=True)

pairs = []
seen_pairs = set()
tokens_list = sorted(all_terms.keys())

for i, t1 in enumerate(tokens_list):
    cat1, m1, _ = all_terms[t1]
    m1_clean = m1.lower().split("/")[0].split("(")[0].split("[")[0].strip()

    for t2 in tokens_list[i+1:]:
        pair_key = tuple(sorted([t1, t2]))
        if pair_key in seen_pairs:
            continue

        cat2, m2, _ = all_terms[t2]
        m2_clean = m2.lower().split("/")[0].split("(")[0].split("[")[0].strip()

        rel = None

        # 1) Abreviación: t1 es prefijo de t2 con misma raíz semántica
        if t2.startswith(t1) and len(t1) <= len(t2) - 1:
            # Verificar que los significados son relacionados
            m1_words = set(m1_clean.split())
            m2_words = set(m2_clean.split())
            if m1_words & m2_words:
                rel = "ABBREVIATION_PAIR"
        elif t1.startswith(t2) and len(t2) <= len(t1) - 1:
            m1_words = set(m1_clean.split())
            m2_words = set(m2_clean.split())
            if m1_words & m2_words:
                rel = "ABBREVIATION_PAIR"

        # 2) El significado de uno contiene el texto del otro token
        if rel is None:
            if t2 in m1_clean and len(t2) >= 4:
                rel = "OVERLAP"
            elif t1 in m2_clean and len(t1) >= 4:
                rel = "OVERLAP"

        # 3) Significados casi idénticos (al menos 80% de palabras en común)
        if rel is None and m1_clean and m2_clean:
            words1 = set(re.findall(r'\w+', m1_clean))
            words2 = set(re.findall(r'\w+', m2_clean))
            if words1 and words2:
                overlap = len(words1 & words2)
                union   = len(words1 | words2)
                jaccard = overlap / union if union else 0
                if jaccard >= 0.75 and len(words1) >= 2:
                    rel = "SYNONYM_PAIR"

        if rel:
            seen_pairs.add(pair_key)
            pairs.append({
                "t1": t1, "cat1": cat1, "m1": m1,
                "t2": t2, "cat2": cat2, "m2": m2,
                "relation": rel,
            })

print(f"listo. {len(pairs)} pares.")

# ═══════════════════════════════════════════════════════════════════════════════
# SECCIÓN 3 — SCOPE ENRICHMENT
# ═══════════════════════════════════════════════════════════════════════════════

print("  Sección 3: scope enrichment…", end=" ", flush=True)

# Dominio → nombre legible
cur.execute("SELECT id, name FROM domains")
domain_names = {r[0]: fix_mojibake(r[1]) for r in cur.fetchall()}

# Mapeo db → dominio
cur.execute("SELECT id, db FROM domains")
db_to_domain = {r[1]: r[0] for r in cur.fetchall()}

section3 = []

for tok in sorted(all_terms.keys()):
    # Buscar en db_terms si el scope necesita completarse
    db_entry = db_terms.get(tok, {})
    scope_val = db_entry.get("scope", DASH)
    if not needs_scope(scope_val):
        continue  # ya tiene scope

    # Calcular scope basado en SPs que usan este token
    sp_set = token_to_sps.get(tok, set())
    if not sp_set:
        section3.append({
            "token":          tok,
            "current_scope":  scope_val,
            "proposed_scope": "—SIN-EVIDENCIA—",
            "sp_count":       0,
            "domains":        [],
            "note":           "Sin SPs en sp_terms — verificar segmentación",
        })
        continue

    # Obtener dominios
    domains_hit = []
    for sp_id in sp_set:
        d = sps_data.get(sp_id, {})
        dom = d.get("domain", "")
        if dom:
            domains_hit.append(dom)

    domain_counter = Counter(domains_hit)
    unique_domains  = len(domain_counter)

    # Proponer scope
    if unique_domains >= 5:
        proposed = "TRANSVERSAL"
    elif unique_domains == 1:
        dom_id   = list(domain_counter.keys())[0]
        proposed = f"DOMAIN-SPECIFIC ({dom_id} — {domain_names.get(dom_id,dom_id)})"
    elif unique_domains <= 3:
        dom_list = ", ".join(f"{d}:{domain_names.get(d,d)}" for d in sorted(domain_counter)[:3])
        proposed = f"DOMAIN-CLUSTER ({dom_list})"
    else:
        proposed = "TRANSVERSAL"

    section3.append({
        "token":          tok,
        "current_scope":  scope_val,
        "proposed_scope": proposed,
        "sp_count":       len(sp_set),
        "domains":        sorted(domain_counter.keys()),
        "top_domains":    domain_counter.most_common(3),
        "note":           "",
    })

section3.sort(key=lambda x: -x["sp_count"])
print("listo.")

# ═══════════════════════════════════════════════════════════════════════════════
# SECCIÓN 4 — TOKENS FRECUENTES FALTANTES
# ═══════════════════════════════════════════════════════════════════════════════

print("  Sección 4: tokens faltantes…", end=" ", flush=True)

# Tokenizar todos los nombres de SPs
cur.execute("SELECT name FROM sps")
all_sp_names = [r[0] for r in cur.fetchall()]

token_freq = Counter()
for sp_name in all_sp_names:
    parts = sp_name.lower().split("_")
    for p in parts:
        if len(p) >= 3 and not p.isdigit() and not re.fullmatch(r'[0-9]+', p):
            token_freq[p] += 1

# Filtrar: quitar tokens que YA están en CAT (con o sin plural/variantes)
known = set(all_terms.keys())
missing_candidates = []
for tok, freq in token_freq.most_common():
    if freq <= 20:
        break
    if tok in known:
        continue
    # Ignorar fragmentos puramente numéricos o 1-2 letras
    if len(tok) < 3 or re.fullmatch(r'\d+', tok):
        continue
    # Ignorar si es variante plural/femenino ya cubierta
    base_forms = [tok.rstrip("s"), tok.rstrip("es"), tok.rstrip("as")]
    if any(b in known for b in base_forms if len(b) >= 3):
        continue
    missing_candidates.append((tok, freq))

section4 = missing_candidates[:30]

# Candidatos secundarios freq 10-20
missing_candidates_low = []
for tok, freq in token_freq.most_common():
    if freq > 20:
        continue
    if freq < 10:
        break
    if tok in known:
        continue
    if len(tok) < 3 or re.fullmatch(r'\d+', tok):
        continue
    base_forms = [tok.rstrip("s"), tok.rstrip("es"), tok.rstrip("as")]
    if any(b in known for b in base_forms if len(b) >= 3):
        continue
    missing_candidates_low.append((tok, freq))

section4_low = missing_candidates_low[:20]

print(f"listo. {len(token_freq)} tokens únicos, {len(missing_candidates)} candidatos freq>20, {len(missing_candidates_low)} candidatos freq 10-20.")

# ═══════════════════════════════════════════════════════════════════════════════
# SECCIÓN 5 — DEFINICIONES A ENRIQUECER
# ═══════════════════════════════════════════════════════════════════════════════

print("  Sección 5: definiciones enriquecibles…", end=" ", flush=True)

# Top 50 por frecuencia en SP names
top50 = [(tok, token_freq.get(tok, 0)) for tok in all_terms.keys()]
top50.sort(key=lambda x: -x[1])
top50 = top50[:50]

# Journeys que usan cada token
token_journey_biz = defaultdict(list)
for j_id, sp, biz, domain in journeys_rows:
    sp_name = sp.split(":")[-1].lower() if sp else ""
    biz_l   = (biz or "").lower()
    for tok in all_terms:
        if len(tok) >= 4 and tok in sp_name:
            token_journey_biz[tok].append(biz or "")

# Reglas regulatorias por token (via rules.reg)
token_reg = defaultdict(set)
for rule_id, sp_id, code, reg, domain in rules_rows:
    sp_name = (sp_id or "").split(":")[-1].lower()
    for tok in all_terms:
        if len(tok) >= 4 and tok in sp_name:
            if reg and reg.strip().lower() not in ("false", "null", "", "[]"):
                token_reg[tok].add(reg)

section5 = []
for tok, freq in top50:
    if freq == 0:
        continue
    cat, meaning, est = all_terms[tok]
    m_lower = meaning.lower()

    # Verificar si la definición ya menciona journeys o contexto enriquecido
    has_journey_context = any(w in m_lower for w in
                              ["journey", "proceso", "flujo", "ciclo", "operaci"])
    has_reg_context     = any(w in m_lower for w in
                              ["cnbv", "banxico", "sat", "condusef", "ipab"])

    journeys_for_tok = token_journey_biz.get(tok, [])[:3]
    regs_for_tok     = sorted(token_reg.get(tok, set()))

    opportunity = []
    if not has_journey_context and journeys_for_tok:
        opportunity.append("contexto-journey")
    if not has_reg_context and regs_for_tok:
        opportunity.append("contexto-regulatorio")
    if est == "inf":
        opportunity.append("confirmar-estado")

    if opportunity:
        section5.append({
            "token":    tok,
            "cat":      cat,
            "meaning":  meaning,
            "est":      est,
            "freq":     freq,
            "journeys": journeys_for_tok,
            "regs":     regs_for_tok,
            "opps":     opportunity,
        })

section5.sort(key=lambda x: -x["freq"])
section5 = section5[:20]
print("listo.")

# ═══════════════════════════════════════════════════════════════════════════════
# RESUMEN EJECUTIVO — CONSOLA
# ═══════════════════════════════════════════════════════════════════════════════

upgrades  = [x for x in section1 if x["class"] == "UPGRADE_CANDIDATE"]
stays     = [x for x in section1 if x["class"] == "STAYS_INF"]
needs_sme = [x for x in section1 if x["class"] == "NEEDS_SME"]
removes   = [x for x in section1 if x["class"] == "REMOVE_CANDIDATE"]

abbrev_pairs  = [p for p in pairs if p["relation"] == "ABBREVIATION_PAIR"]
synonym_pairs = [p for p in pairs if p["relation"] == "SYNONYM_PAIR"]
overlap_pairs = [p for p in pairs if p["relation"] == "OVERLAP"]

scope_proposed = [x for x in section3 if x["proposed_scope"] not in ("—SIN-EVIDENCIA—",)]
scope_transv   = [x for x in section3 if "TRANSVERSAL" in x["proposed_scope"]]

print()
print("╔══════════════════════════════════════════════════════╗")
print("║         RESUMEN EJECUTIVO — VOCAB ENRICHMENT         ║")
print("╠══════════════════════════════════════════════════════╣")
print(f"║  Vocabulario vigente (sp_vocab.CAT):   {len(all_terms):>5} tokens    ║")
print(f"║  Términos conf:                         {sum(1 for _,(_,_,e) in all_terms.items() if e=='conf'):>5}          ║")
print(f"║  Términos inf:                          {sum(1 for _,(_,_,e) in all_terms.items() if e=='inf'):>5}          ║")
print(f"║  Términos gap:                          {sum(1 for _,(_,_,e) in all_terms.items() if e=='gap'):>5}          ║")
print("╠══════════════════════════════════════════════════════╣")
print(f"║  §1 UPGRADE_CANDIDATE (inf/gap→conf):   {len(upgrades):>5}          ║")
print(f"║     STAYS_INF (evidencia moderada):      {len(stays):>5}          ║")
print(f"║     NEEDS_SME (requiere validación):     {len(needs_sme):>5}          ║")
print(f"║     REMOVE_CANDIDATE (0 evidencia):      {len(removes):>5}          ║")
print("╠══════════════════════════════════════════════════════╣")
print(f"║  §2 Pares ABBREVIATION_PAIR:            {len(abbrev_pairs):>5}          ║")
print(f"║     Pares SYNONYM_PAIR:                  {len(synonym_pairs):>5}          ║")
print(f"║     Pares OVERLAP:                       {len(overlap_pairs):>5}          ║")
print("╠══════════════════════════════════════════════════════╣")
print(f"║  §3 Términos sin scope (scope='—'):     {len(section3):>5}          ║")
print(f"║     Con scope propuesto:                 {len(scope_proposed):>5}          ║")
print(f"║     Propuestos TRANSVERSAL:              {len(scope_transv):>5}          ║")
print("╠══════════════════════════════════════════════════════╣")
print(f"║  §4 Tokens faltantes freq>20:           {len(section4):>5}          ║")
print(f"║     Tokens faltantes freq 10-20:        {len(section4_low):>5}          ║")
print("╠══════════════════════════════════════════════════════╣")
print(f"║  §5 Definiciones con oportunidad:       {len(section5):>5}          ║")
print("╚══════════════════════════════════════════════════════╝")
print()

# ═══════════════════════════════════════════════════════════════════════════════
# GENERAR MARKDOWN
# ═══════════════════════════════════════════════════════════════════════════════

OUT.parent.mkdir(parents=True, exist_ok=True)

lines = []
def w(*args):
    lines.append(" ".join(str(a) for a in args))

w("# Análisis de Enriquecimiento del Vocabulario Informix")
w()
w("> **Proyecto**: SPE-AM-001 — BanCoppel Application Modernization  ")
w("> **Fecha**: 2026-08-04  ")
w(f"> **Vocabulario analizado**: {len(all_terms)} tokens ({sum(1 for _,(_,_,e) in all_terms.items() if e=='conf')} conf · {sum(1 for _,(_,_,e) in all_terms.items() if e=='inf')} inf · {sum(1 for _,(_,_,e) in all_terms.items() if e=='gap')} gap)")
w()
w("---")
w()
w("## Resumen ejecutivo")
w()
w("| Dimensión | Total |")
w("|-----------|------:|")
w(f"| Términos con potencial upgrade inf→conf | **{len(upgrades)}** |")
w(f"| Términos inf que permanecen con evidencia moderada | {len(stays)} |")
w(f"| Términos ambiguos que requieren validación SME | {len(needs_sme)} |")
w(f"| Términos candidatos a eliminar (0 evidencia) | {len(removes)} |")
w(f"| Pares abreviación-forma larga detectados | {len(abbrev_pairs)} |")
w(f"| Pares sinónimos detectados | {len(synonym_pairs)} |")
w(f"| Pares con overlap semántico | {len(overlap_pairs)} |")
w(f"| Términos sin scope asignado | {len(section3)} |")
w(f"| Tokens frecuentes faltantes (freq > 20) | {len(section4)} |")
w(f"| Tokens faltantes secundarios (freq 10-20) | {len(section4_low)} |")
w(f"| Definiciones con oportunidad de enriquecimiento | {len(section5)} |")
w()
w("---")
w()

# ── Sección 1 ─────────────────────────────────────────────────────────────────
w("## Sección 1 — Candidatos a upgrade (inf/gap → conf)")
w()
w(f"Los siguientes **{len(upgrades)}** términos tienen alta evidencia en el knowledge base (SPs, reglas,")
w("journeys o almas) y pueden elevarse de `inf`/`gap` a `conf` en la próxima revisión del SME.")
w()
w("### UPGRADE_CANDIDATE")
w()
w("| Token | Cat | Est | SPs | Reglas | Journeys | Alma | Dominios | Significado actual |")
w("|-------|-----|-----|----:|-------:|---------:|------|----------|--------------------|")
for x in upgrades:
    soul_mark = "★" if x["soul_hit"] else ""
    domains_str = ", ".join(x["domains"][:4]) + ("…" if len(x["domains"]) > 4 else "")
    m = clean_meaning(x["meaning"])[:70]
    w(f"| `{x['token']}` | {x['cat']} | {x['est']} | {x['sp_n']} | {x['rule_n']} | {x['jour_n']} | {soul_mark} | {domains_str} | {m} |")
w()

w("### STAYS_INF — Evidencia moderada (sin cambio recomendado aún)")
w()
w("| Token | Cat | SPs | Reglas | Journeys | Significado actual |")
w("|-------|-----|----:|-------:|---------:|--------------------|")
for x in stays:
    m = clean_meaning(x["meaning"])[:70]
    w(f"| `{x['token']}` | {x['cat']} | {x['sp_n']} | {x['rule_n']} | {x['jour_n']} | {m} |")
w()

w("### NEEDS_SME — Ambiguos, requieren validación")
w()
w("| Token | Cat | Est | SPs | Significado actual |")
w("|-------|-----|-----|----:|--------------------|")
for x in needs_sme:
    m = clean_meaning(x["meaning"])[:80]
    w(f"| `{x['token']}` | {x['cat']} | {x['est']} | {x['sp_n']} | {m} |")
w()

w("### REMOVE_CANDIDATE — Sin evidencia en el knowledge base")
w()
w("| Token | Cat | Est | Significado actual |")
w("|-------|-----|-----|--------------------|")
for x in removes:
    m = clean_meaning(x["meaning"])[:80]
    w(f"| `{x['token']}` | {x['cat']} | {x['est']} | {m} |")
w()
w("---")
w()

# ── Sección 2 ─────────────────────────────────────────────────────────────────
w("## Sección 2 — Pares sinónimos y duplicados detectados")
w()
w(f"Se detectaron **{len(pairs)}** pares con relación semántica significativa.")
w()

if abbrev_pairs:
    w("### Pares abreviación-forma larga (ABBREVIATION_PAIR)")
    w()
    w("| Abreviación | Forma larga | Cat | Nota |")
    w("|-------------|-------------|-----|------|")
    for p in sorted(abbrev_pairs, key=lambda x: x["t1"]):
        shorter = p["t1"] if len(p["t1"]) <= len(p["t2"]) else p["t2"]
        longer  = p["t2"] if len(p["t1"]) <= len(p["t2"]) else p["t1"]
        m_short = clean_meaning(all_terms[shorter][1])[:40]
        m_long  = clean_meaning(all_terms[longer][1])[:40]
        note = "Consolidar si mismo scope" if p["cat1"] == p["cat2"] else "Categorías diferentes — revisar"
        w(f"| `{shorter}` ({m_short}) | `{longer}` ({m_long}) | {p['cat1']} | {note} |")
    w()

if synonym_pairs:
    w("### Pares sinónimos (SYNONYM_PAIR)")
    w()
    w("| Token A | Token B | Cat | Jaccard | Significado A | Significado B |")
    w("|---------|---------|-----|---------|---------------|---------------|")
    for p in sorted(synonym_pairs, key=lambda x: x["t1"]):
        mA = clean_meaning(p["m1"])[:45]
        mB = clean_meaning(p["m2"])[:45]
        w(f"| `{p['t1']}` | `{p['t2']}` | {p['cat1']}/{p['cat2']} | ≥0.75 | {mA} | {mB} |")
    w()

if overlap_pairs:
    w("### Pares con overlap semántico (OVERLAP)")
    w()
    w("| Token A | Token B | Relación | Significado A | Significado B |")
    w("|---------|---------|----------|---------------|---------------|")
    for p in sorted(overlap_pairs[:40], key=lambda x: x["t1"]):
        mA = clean_meaning(p["m1"])[:45]
        mB = clean_meaning(p["m2"])[:45]
        rel_note = f"'{p['t1']}' aparece en def de '{p['t2']}'" if p["t2"] in p["m1"].lower() else f"'{p['t2']}' aparece en def de '{p['t1']}'"
        w(f"| `{p['t1']}` | `{p['t2']}` | {rel_note} | {mA} | {mB} |")
    if len(overlap_pairs) > 40:
        w(f"\n_... y {len(overlap_pairs) - 40} pares adicionales no mostrados._")
    w()

w("---")
w()

# ── Sección 3 ─────────────────────────────────────────────────────────────────
w("## Sección 3 — Scope enrichment propuesto")
w()
w(f"Hay **{len(section3)}** términos con `scope='—'` (no asignado) en brain.db.")
w("El scope propuesto se deriva de los dominios (D01-D16) donde aparecen los SPs que usan ese token.")
w()
w("| Token | Cat | SPs | Scope propuesto | Dominios principales |")
w("|-------|-----|----:|-----------------|----------------------|")
for x in section3[:60]:
    top = ", ".join(f"{d}({n})" for d, n in x["top_domains"][:3]) if x.get("top_domains") else "—"
    sp_str = str(x["sp_count"])
    w(f"| `{x['token']}` | {db_terms.get(x['token'],{}).get('cat','?')} | {sp_str} | {x['proposed_scope']} | {top} |")
if len(section3) > 60:
    w(f"\n_... y {len(section3) - 60} términos adicionales no mostrados._")
w()
w("---")
w()

# ── Sección 4 ─────────────────────────────────────────────────────────────────
w("## Sección 4 — Tokens frecuentes faltantes en vocabulario")
w()
w(f"Análisis de {len(token_freq):,} tokens únicos extraídos de {len(all_sp_names):,} nombres de SPs.")
w(f"Solo **{len(missing_candidates)}** tokens con frecuencia > 20 no están en el vocabulario, lo que confirma")
w("la alta cobertura del vocabulario actual tras los grounding passes D01-D16.")
w()

def cat_suggest(tok):
    if tok.endswith(("cion", "aje", "ura", "idad", "dad")):
        return "ENTIDAD"
    elif tok.endswith(("ar", "er", "ir", "izar")):
        return "ACCION"
    elif tok in ("nuevo", "viejo", "anterior", "actual", "siguiente", "previo",
                 "inicial", "final", "global", "interno", "externo",
                 "tabla", "temporal", "siguiente"):
        return "MODIF"
    elif tok in ("sat", "cnbv", "banxico", "condusef", "ipab", "ine", "cfdi"):
        return "REG"
    elif re.fullmatch(r'[a-z]{1,4}\d+', tok):
        return "MODIF (versión)"
    else:
        return "ENTIDAD?"

w("### Candidatos primarios (freq > 20)")
w()
if section4:
    w("| Rank | Token | Frecuencia | Categoría sugerida | Nota |")
    w("|-----:|-------|----------:|---------------------|------|")
    for rank, (tok, freq) in enumerate(section4, 1):
        cat_sug = cat_suggest(tok)
        # Nota contextual
        if re.fullmatch(r'[a-z]+\d+', tok):
            note = f"Variante versionada de `{tok.rstrip('0123456789')}`"
        elif len(tok) <= 4:
            note = "Token corto — verificar si es abreviación conocida"
        else:
            note = ""
        w(f"| {rank} | `{tok}` | {freq} | {cat_sug} | {note} |")
else:
    w("_No se encontraron tokens con frecuencia > 20 fuera del vocabulario._")
w()
w(f"### Candidatos secundarios (freq 10-20) — top {len(section4_low)} de {len(missing_candidates_low)}")
w()
w("Tokens de frecuencia moderada que pueden ser candidatos para futuras expansiones del vocabulario.")
w()
if section4_low:
    w("| Rank | Token | Frecuencia | Categoría sugerida | Nota |")
    w("|-----:|-------|----------:|---------------------|------|")
    for rank, (tok, freq) in enumerate(section4_low, 1):
        cat_sug = cat_suggest(tok)
        if re.fullmatch(r'[a-z]+\d+', tok):
            note = f"Variante versionada de `{tok.rstrip('0123456789')}`"
        elif len(tok) <= 4:
            note = "Token corto — verificar si es abreviación"
        elif tok.endswith(("ar", "er", "ir")):
            note = "Infinitivo sin registrar"
        else:
            note = ""
        w(f"| {rank} | `{tok}` | {freq} | {cat_sug} | {note} |")
w()
w("---")
w()

# ── Sección 5 ─────────────────────────────────────────────────────────────────
w("## Sección 5 — Definiciones con oportunidad de enriquecimiento")
w()
w("Top 20 términos de alta frecuencia cuya definición puede enriquecerse con contexto de journeys")
w("y/o regulatorio extraído del knowledge base.")
w()
for i, x in enumerate(section5, 1):
    w(f"### {i}. `{x['token']}` — {clean_meaning(x['meaning'])[:60]}")
    w()
    w(f"- **Categoría**: {x['cat']} | **Estado**: {x['est']} | **Frecuencia en SPs**: {x['freq']}")
    w(f"- **Oportunidades**: {', '.join(x['opps'])}")
    if x["regs"]:
        w(f"- **Reguladores relevantes detectados**: {', '.join(x['regs'])}")
    if x["journeys"]:
        w(f"- **Contexto de journeys**:")
        for j in x["journeys"]:
            w(f"  - _{j[:100]}_")
    w()

w("---")
w()
w("_Generado por `generators/analyze-vocab-enrichment.py` · SPE-AM-001 · 2026-08-04_")

# Escribir archivo
report_text = "\n".join(lines)
with open(OUT, "w", encoding="utf-8") as f:
    f.write(report_text)

print(f"\nReporte generado: {OUT}")
print(f"  Tamaño: {len(report_text):,} caracteres")
