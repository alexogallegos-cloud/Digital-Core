#!/usr/bin/env python3
"""
fix-low-conf-from-source.py — Lee el SQL fuente completo para las 69 reglas
de baja confianza y extrae el SP referenciado sin truncamiento.

El campo `code` en los batches swarm2 estaba truncado a ~120 chars, cortando
el nombre del SP en los RAISE EXCEPTION. Este script va directo al fuente.

Estrategia por categoría:
  error_msg / ref_sp → busca la línea RAISE en el fuente, extrae SP name completo
  formula_raw        → lee bloque de asignación cCmd para ver qué SELECT construye
  code_frag          → lee la línea completa con su comentario inline --
  sp_in_name         → lee contexto del SP para entender qué hace
  param_list         → lee bloque de parámetros con su comentario
"""
import json, re, sqlite3, sys, os, collections

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/BCOPCore/")
SRC       = BASE + "source/BCOPCore/informix/"
DB        = BASE + "digital-brain/brain.db"
AUDIT_IN  = BASE + "knowledge-base/rules/bad-names-audit3.json"
NANO_PATH = BASE + "knowledge-base/rules/name-overrides-ai.json"

# ── 1. brain.db ──────────────────────────────────────────────────────────────
conn = sqlite3.connect(DB)
biz_rows = conn.execute(
    "SELECT id, biz FROM sps WHERE biz IS NOT NULL AND biz != ''"
).fetchall()
# rules table: id → (db, sp_full_id, line)
rule_rows = conn.execute("SELECT id, db, sp, line FROM rules").fetchall()
RULE_META = {r[0]: (r[1], r[2], r[3]) for r in rule_rows}

def _clean(biz):
    if " — " in biz: biz = biz.split(" — ")[0].strip()
    return biz[:90].strip()

BIZ = {r[0]: _clean(r[1]) for r in biz_rows}
BIZ_BY_NAME = {}
for sid, biz in BIZ.items():
    name = sid.split(":")[-1]
    if name not in BIZ_BY_NAME:
        BIZ_BY_NAME[name] = biz
conn.close()

# ── 2. Helpers ────────────────────────────────────────────────────────────────
_SP_ID_RE   = re.compile(r"([a-z][a-z0-9]{2,15}:[a-z][a-z0-9_]{3,60})")
_INFORMIX_RE = re.compile(r'"informix"\s*\.\s*(sp_[a-z0-9_]+)', re.IGNORECASE)
_INLINE_CMT = re.compile(r"--\s*(.+?)$")

def _load_source(db: str, sp_name: str) -> list[str]:
    path = os.path.join(SRC, f"{db}_{sp_name}.sql")
    try:
        with open(path, encoding="utf-8", errors="replace") as f:
            return f.readlines()
    except FileNotFoundError:
        return []

def _find_lines_with(lines: list[str], fragment: str, max_dist: int = 5) -> list[tuple[int, str]]:
    """Devuelve [(lineno, full_line)] donde fragment aparece (ignora case)."""
    frag_lo = fragment.lower().replace(" ", "")
    results = []
    for i, line in enumerate(lines):
        if frag_lo[:30] in line.lower().replace(" ", ""):
            results.append((i, line))
    return results

def _lookup_sp(sp_ref: str):
    """Devuelve biz o None."""
    if ":" in sp_ref:
        biz = BIZ.get(sp_ref)
        if biz: return biz
        name = sp_ref.split(":")[-1]
    else:
        name = sp_ref
    return BIZ_BY_NAME.get(name)

def _humanize(sp_name: str) -> str:
    return sp_name.replace("sp_", "").replace("_", " ").strip()

# ── 3. Estrategias ────────────────────────────────────────────────────────────

_EXEC_PROC_RE = re.compile(
    r"(?:EXECUTE\s+PROCEDURE|CALL)\s+([a-z][a-z0-9]{2,15}:[a-z][a-z0-9_]{3,60}|[a-z][a-z0-9_]{3,60})\s*[\(;]",
    re.IGNORECASE
)

def _find_preceding_call(lines: list[str], raise_lineno: int) -> str | None:
    """Busca el EXECUTE PROCEDURE / CALL más reciente antes de raise_lineno."""
    window = lines[max(0, raise_lineno - 12):raise_lineno]
    for line in reversed(window):
        m = _EXEC_PROC_RE.search(line)
        if m:
            return m.group(1).rstrip("_'\".,;")
    return None


def strategy_raise_from_source(rule: dict, lines: list[str]) -> tuple[str, str]:
    """Lee la línea RAISE completa desde el fuente; si el SP está vacío,
    busca el EXECUTE PROCEDURE / CALL que lo precede."""
    search_token = "ERROR EN"
    rule_line = RULE_META.get(rule["id"], (None, None, None))[2]

    # Zona preferida: alrededor del número de línea conocido
    if rule_line:
        zone = lines[max(0, rule_line-3):rule_line+5]
        matching = [(rule_line - 3 + i, l) for i, l in enumerate(zone) if search_token in l.upper()]
    else:
        matching = [(i, l) for i, l in enumerate(lines) if search_token in l.upper()]

    for lineno, line in matching:
        # Intento 1: SP name explícito en la línea RAISE
        m_id  = _SP_ID_RE.findall(line)
        m_inf = _INFORMIX_RE.findall(line)
        # también buscar sp_name sin prefijo db: dentro del string
        m_sp  = re.findall(r"SP\s+([a-z][a-z0-9_]{4,60})['\";]", line, re.IGNORECASE)

        sp_ref = None
        for c in reversed(m_id):
            c = c.rstrip("_'\".,;")
            if len(c) > 6:
                sp_ref = c
                break
        if not sp_ref and m_inf:
            sp_ref = m_inf[-1]
        if not sp_ref and m_sp:
            sp_ref = m_sp[-1].rstrip("_")

        if sp_ref:
            biz = _lookup_sp(sp_ref)
            if biz:
                return f"propaga error al ejecutar {biz}", "high"
            name = sp_ref.split(":")[-1] if ":" in sp_ref else sp_ref
            return f"propaga error al ejecutar procedimiento {_humanize(name)}", "medium"

        # Intento 2: SP name vacío → buscar EXECUTE PROCEDURE anterior
        if "ERROR EN" in line.upper():
            prior = _find_preceding_call(lines, lineno)
            if prior:
                biz = _lookup_sp(prior)
                if biz:
                    return f"propaga error al ejecutar {biz}", "high"
                name = prior.split(":")[-1] if ":" in prior else prior
                return f"propaga error al ejecutar procedimiento {_humanize(name)}", "medium"

    # Último recurso: biz del SP contenedor
    sp_full = rule.get("sp","")
    outer_biz = BIZ.get(sp_full)
    if not outer_biz:
        sp_name = sp_full.split(":")[-1]
        outer_biz = BIZ_BY_NAME.get(sp_name)
    if outer_biz:
        short = outer_biz[:55].rsplit(" ",1)[0] if len(outer_biz) > 50 else outer_biz
        return f"propaga error en {short}", "medium"

    return None, None


def strategy_formula_from_source(rule: dict, lines: list[str]) -> tuple[str, str]:
    """Lee el bloque de asignación cCmd para entender qué reporte construye."""
    # La sp's biz es el contexto más útil
    sp_full = rule.get("sp", "")
    biz = BIZ.get(sp_full) or BIZ_BY_NAME.get(sp_full.split(":")[-1], "")

    code_frag = (rule.get("code","") or "")[:40]
    var_match  = re.match(r"(\w+)\s*=", code_frag)
    var_name   = var_match.group(1) if var_match else "cCmd"

    # Buscar el bloque completo de la asignación en fuente
    in_block = False
    block_lines = []
    for line in lines:
        if re.search(rf"\b{re.escape(var_name)}\b", line) and ("SELECT" in line.upper() or "UNION" in line.upper() or "FROM" in line.upper()):
            in_block = True
        if in_block:
            block_lines.append(line.strip())
            if len(block_lines) > 10:
                break

    block_text = " ".join(block_lines).upper()
    is_union   = "UNION ALL" in block_text or "UNION SELECT" in block_text
    is_select  = "SELECT" in block_text

    # Extraer columnas del current_name
    cur = rule.get("current_name","") or ""
    cols = ""
    m_col = re.match(r"^[Ff][oó]rmula:\s*(.+)$", cur)
    if m_col:
        parts = [p.strip() for p in re.split(r"[·,]", m_col.group(1)) if len(p.strip()) > 2]
        useful = [p for p in parts if p.lower() not in ("fórmula","formula","valor","resultado")]
        cols = "/".join(useful[:2])

    if biz:
        short = biz[:55].rsplit(" ",1)[0] if len(biz) > 50 else biz
        if cols:
            action = "agrega segmento" if is_union else "agrega columnas"
            return f"{action} {cols} a la consulta de {short}", "medium"
        action = "agrega bloque UNION" if is_union else "construye consulta dinámica"
        return f"{action} para {short}", "medium"

    if cols:
        return f"agrega columnas {cols} al reporte dinámico", "medium"
    return None, None


def strategy_code_frag_from_source(rule: dict, lines: list[str]) -> tuple[str, str]:
    """Lee la línea completa con el comentario inline."""
    code_frag = (rule.get("code","") or "")[:50]
    rule_line = RULE_META.get(rule["id"], (None, None, None))[2]

    # Buscar en zona de la regla
    search_lines = []
    if rule_line:
        search_lines = lines[max(0, rule_line-2):rule_line+3]
    else:
        search_lines = [l for l in lines if code_frag[:20].lower() in l.lower()]

    for line in search_lines:
        m = _INLINE_CMT.search(line)
        if m:
            cmt = m.group(1).strip()
            if len(cmt) > 4:
                return cmt[0].upper() + cmt[1:], "high"

    # Si no hay comentario, usar contexto del SP
    sp_full = rule.get("sp","")
    biz = BIZ.get(sp_full) or BIZ_BY_NAME.get(sp_full.split(":")[-1], "")
    if biz:
        short = biz[:55].rsplit(" ",1)[0] if len(biz) > 50 else biz
        return f"fragmento de {short}", "medium"
    return None, None


def enrich_from_source(rule: dict) -> tuple[str, str]:
    """Estrategia principal: carga fuente y aplica la sub-estrategia."""
    rid = rule["id"]
    meta = RULE_META.get(rid)
    if not meta:
        return None, None
    db, sp_full, rule_line = meta
    sp_name = sp_full.split(":")[-1]
    lines = _load_source(db, sp_name)
    if not lines:
        return None, None

    cat = rule.get("category","")
    if cat in ("error_msg", "ref_sp"):
        return strategy_raise_from_source(rule, lines)
    if cat == "formula_raw":
        return strategy_formula_from_source(rule, lines)
    if cat == "code_frag":
        return strategy_code_frag_from_source(rule, lines)
    # sp_in_name, param_list: usar biz del SP padre
    sp_full = rule.get("sp","")
    biz = BIZ.get(sp_full) or BIZ_BY_NAME.get(sp_full.split(":")[-1], "")
    if biz:
        short = biz[:55].rsplit(" ",1)[0] if len(biz) > 50 else biz
        return f"parámetro de {short}", "medium"
    return None, None


# ── 4. Procesar 69 reglas ────────────────────────────────────────────────────
audit_raw = json.load(open(AUDIT_IN, encoding="utf-8"))
rules = audit_raw["rules"]
print(f"Reglas de baja confianza a procesar: {len(rules)}")

improved  = {}   # rid → new name
still_low = []
conf_counts = collections.Counter()

for rule in rules:
    rid = rule["id"]
    name, conf = enrich_from_source(rule)
    if name:
        name = name[:110].strip()
        improved[rid] = name
        conf_counts[conf] += 1
        if conf == "low":
            still_low.append({**rule, "generated_v3": name})
    else:
        conf_counts["low"] += 1
        still_low.append({**rule, "generated_v3": rule.get("generated_v2","")})

print(f"\nResultado desde fuente:")
print(f"  Alta    : {conf_counts.get('high',0)}")
print(f"  Media   : {conf_counts.get('medium',0)}")
print(f"  Baja    : {conf_counts.get('low',0)}")

# Muestra
print("\nMuestra de mejoras (10):")
for rule in rules[:10]:
    rid = rule["id"]
    old = (rule.get("generated_v2") or rule.get("generated",""))[:50]
    new = improved.get(rid, old)[:55]
    mark = "↑" if rid in improved and new != old else "="
    print(f"  {mark} [{rule['category']}] {old!r} → {new!r}")

# ── 5. Actualizar name-overrides-ai.json ─────────────────────────────────────
nano = json.load(open(NANO_PATH, encoding="utf-8"))
names = nano["names"]
updated = 0
for rid, new_name in improved.items():
    if names.get(rid) != new_name:
        names[rid] = new_name
        updated += 1
nano["names"] = names
with open(NANO_PATH, "w", encoding="utf-8") as f:
    json.dump(nano, f, ensure_ascii=False, indent=2)
print(f"\nname-overrides-ai.json: {updated} actualizados")

# ── 6. Actualizar bad-names-audit3.json ──────────────────────────────────────
audit_out = {"total_low": len(still_low), "rules": still_low}
with open(AUDIT_IN, "w", encoding="utf-8") as f:
    json.dump(audit_out, f, ensure_ascii=False, indent=2)
print(f"bad-names-audit3.json: {len(still_low)} siguen baja confianza")
