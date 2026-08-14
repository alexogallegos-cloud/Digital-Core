#!/usr/bin/env python3
"""
fix-low-conf-rules.py — Mejora las 261 reglas de baja confianza de Capa D.

Estrategias específicas (sin API Claude):
  1. error_msg / ref_sp → regex agresivo db:sp_name en code (no depende de fix_enc)
  2. formula_raw        → usa biz del SP padre desde brain.db + columnas del current_name
  3. Informix owner     → "informix".sp_name → lookup por nombre solo en brain.db
  4. Fallback mejorado  → biz del SP padre en vez de "valida resultado de..."

Salida: actualiza name-overrides-ai.json con los overrides mejorados.
        Reemplaza bad-names-audit3.json con las que siguen siendo baja confianza.
"""
import json, re, sqlite3, sys, os

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - SPE/HVM/AM/BanCoppel/Informix/")
DB        = BASE + "digital-brain/brain.db"
AUDIT_IN  = BASE + "knowledge-base/rules/bad-names-audit3.json"
NANO_PATH = BASE + "knowledge-base/rules/name-overrides-ai.json"

# ── 1. brain.db ─────────────────────────────────────────────────────────────
conn = sqlite3.connect(DB)
rows = conn.execute("SELECT id, biz FROM sps WHERE biz IS NOT NULL AND biz != ''").fetchall()

def _clean(biz: str) -> str:
    if " — " in biz:
        biz = biz.split(" — ")[0].strip()
    return biz[:90].strip()

BIZ        = {r[0]: _clean(r[1]) for r in rows}   # db:sp_name → biz
BIZ_BY_NAME = {}
for sid, biz in BIZ.items():
    name = sid.split(":")[-1]
    if name not in BIZ_BY_NAME:
        BIZ_BY_NAME[name] = biz
conn.close()
print(f"brain.db SPs con biz: {len(BIZ):,}")

# ── 2. Regexes ───────────────────────────────────────────────────────────────

# Agresivo: encuentra cualquier db:sp_name en el código
_SP_AGRESSIVE = re.compile(r"([a-z][a-z0-9]{2,15}:[a-z][a-z0-9_]{3,60})")
# "informix".sp_name
_INFORMIX_SP  = re.compile(r'"informix"\s*\.\s*(sp_[a-z0-9_]+)', re.IGNORECASE)
# Columnas de formula en current_name: "Fórmula: col1 · col2 · col3"
_COL_RE       = re.compile(r"^[Ff][oó]rmula:\s*(.+)$")

def _resolve_sp(code: str) -> tuple[str | None, str | None]:
    """Devuelve (sp_ref, biz) o (None, None)."""
    # Intento 1: db:sp_name agresivo
    candidates = _SP_AGRESSIVE.findall(code)
    for c in reversed(candidates):               # el último suele ser el referenciado
        c = c.rstrip("_'\".,;")
        if len(c) > 6:
            biz = BIZ.get(c)
            if biz:
                return c, biz
            # Sin biz exacto: guardar como candidato de nombre
    for c in reversed(candidates):
        c = c.rstrip("_'\".,;")
        if len(c) > 6:
            sp_name = c.split(":")[-1]
            biz2 = BIZ_BY_NAME.get(sp_name)
            if biz2:
                return c, biz2
            readable = sp_name.replace("sp_", "").replace("_", " ").strip()
            return c, f"procedimiento {readable}"

    # Intento 2: "informix".sp_name
    m = _INFORMIX_SP.search(code)
    if m:
        sp_name = m.group(1)
        biz = BIZ_BY_NAME.get(sp_name)
        if biz:
            return sp_name, biz
        readable = sp_name.replace("sp_", "").replace("_", " ").strip()
        return sp_name, f"procedimiento {readable}"

    return None, None


def enrich_error_msg(rule: dict) -> tuple[str, str]:
    code  = rule.get("code", "") or ""
    sp_r, biz = _resolve_sp(code)
    if biz:
        return f"propaga error al ejecutar {biz}", "high"
    # Fallback: biz del SP contenedor
    outer_id  = f"{rule.get('db','')}:{rule.get('sp','')}"
    outer_biz = BIZ.get(outer_id) or BIZ_BY_NAME.get(rule.get("sp",""), "")
    if outer_biz:
        short = outer_biz[:55].rsplit(" ", 1)[0] if len(outer_biz) > 50 else outer_biz
        return f"propaga error en {short}", "medium"
    return rule.get("generated", ""), "low"


def enrich_formula_raw(rule: dict) -> tuple[str, str]:
    """formula_raw: constructores SQL dinámicos — usa biz del SP padre."""
    outer_id  = f"{rule.get('db','')}:{rule.get('sp','')}"
    outer_biz = BIZ.get(outer_id) or BIZ_BY_NAME.get(rule.get("sp",""), "")

    # Columnas del current_name: "Fórmula: referencia · hora · saldo"
    cur = rule.get("current_name", "") or ""
    m = _COL_RE.match(cur)
    cols = ""
    if m:
        # Tomar primeras 2 columnas
        parts = [p.strip() for p in re.split(r"[·,]", m.group(1)) if p.strip()]
        # Filtrar tokens genéricos
        useful = [p for p in parts if len(p) > 2 and p.lower() not in
                  ("fórmula", "formula", "valor", "resultado")]
        if useful:
            cols = "/".join(useful[:2])

    code = rule.get("code", "") or ""
    is_union = "UNION" in code.upper()
    is_select = "SELECT" in code.upper()

    if outer_biz:
        short_biz = outer_biz[:55].rsplit(" ", 1)[0] if len(outer_biz) > 50 else outer_biz
        if cols:
            if is_union:
                return f"agrega segmento {cols} a la consulta dinámica de {short_biz}", "medium"
            return f"agrega columnas {cols} a la consulta de {short_biz}", "medium"
        if is_union:
            return f"agrega bloque UNION a la consulta dinámica de {short_biz}", "medium"
        if is_select:
            return f"construye consulta dinámica para {short_biz}", "medium"
        return f"construye fragmento de consulta de {short_biz}", "medium"

    # Sin biz del SP padre
    if cols:
        return f"agrega columnas {cols} a la consulta dinámica", "medium"
    return rule.get("generated", ""), "low"


def enrich_ref_sp(rule: dict) -> tuple[str, str]:
    """ref_sp: RAISE con SP referenciado — misma lógica que error_msg."""
    return enrich_error_msg(rule)


def enrich_generic(rule: dict) -> tuple[str, str]:
    """Fallback para code_frag, sp_in_name, param_list."""
    # Usar biz del SP padre
    outer_id  = f"{rule.get('db','')}:{rule.get('sp','')}"
    outer_biz = BIZ.get(outer_id) or BIZ_BY_NAME.get(rule.get("sp",""), "")
    cur = (rule.get("current_name","") or "").strip()
    if outer_biz and cur and not cur.lower().startswith("fórmula"):
        return cur[0].upper() + cur[1:], "medium"
    if outer_biz:
        short = outer_biz[:55].rsplit(" ", 1)[0] if len(outer_biz) > 50 else outer_biz
        return f"parámetro/fragmento de {short}", "medium"
    return rule.get("generated", ""), "low"


def enrich(rule: dict) -> tuple[str, str]:
    cat = rule.get("category", "")
    if cat in ("error_msg",):
        return enrich_error_msg(rule)
    if cat in ("ref_sp",):
        return enrich_ref_sp(rule)
    if cat in ("formula_raw",):
        return enrich_formula_raw(rule)
    return enrich_generic(rule)


# ── 3. Procesar 261 reglas ───────────────────────────────────────────────────
audit_raw = json.load(open(AUDIT_IN, encoding="utf-8"))
rules = audit_raw["rules"]
print(f"Reglas a mejorar: {len(rules)}")

improved   = {}   # rid → new bc_name
still_low  = []

conf_counts = {"high": 0, "medium": 0, "low": 0}
for rule in rules:
    rid = rule["id"]
    name, conf = enrich(rule)
    name = name[:110].strip() if name else ""
    if name:
        improved[rid] = name
    conf_counts[conf] += 1
    if conf == "low":
        still_low.append({**rule, "generated_v2": name, "conf": conf})

print(f"\nResultado:")
print(f"  Alta confianza : {conf_counts['high']}")
print(f"  Media confianza: {conf_counts['medium']}")
print(f"  Baja confianza : {conf_counts['low']}")

# Muestra de mejoras
print("\nMuestra (primeras 12 mejoras):")
for rule in rules[:12]:
    rid = rule["id"]
    old = rule.get("generated","")[:50]
    new = improved.get(rid, old)[:55]
    mark = "↑" if new != old else "="
    print(f"  {mark} [{rule['category']}] {old} → {new}")

# ── 4. Actualizar name-overrides-ai.json ────────────────────────────────────
nano = json.load(open(NANO_PATH, encoding="utf-8"))
names = nano.get("names", {})
before = len(names)
updated = 0
for rid, new_name in improved.items():
    if names.get(rid) != new_name:
        names[rid] = new_name
        updated += 1
nano["names"] = names
with open(NANO_PATH, "w", encoding="utf-8") as f:
    json.dump(nano, f, ensure_ascii=False, indent=2)
print(f"\nname-overrides-ai.json: {before} → {len(names)} ({updated} actualizados)")

# ── 5. Actualizar bad-names-audit3.json con los que siguen siendo bajos ──────
audit_out = {"total_low": len(still_low), "rules": still_low}
with open(AUDIT_IN, "w", encoding="utf-8") as f:
    json.dump(audit_out, f, ensure_ascii=False, indent=2)
print(f"bad-names-audit3.json: {len(still_low)} siguen siendo baja confianza")
