#!/usr/bin/env python3
"""
enrich-capa-d.py — Enriquecimiento Capa D para las 878 reglas con bc_name vacío o genérico.

Estrategias en orden de prioridad:
  1. RAISE EXCEPTION  → extrae SP referenciado, busca biz en brain.db
  2. dbaccess shell   → usa current_name (ya descriptivo)
  3. echo/UNLOAD      → parsea columnas del reporte
  4. sed command      → describe la transformación del archivo
  5. math formula     → analiza variable + operadores
  6. string message   → parsea el literal de la cadena
  7. code_frag        → extrae el comentario inline
  8. fallback         → limpia current_name

Salida: knowledge-base/rules/batches/swarm2/overrides.json
        knowledge-base/rules/bad-names-audit3.json (reglas con baja confianza)
"""
import json, re, sqlite3, glob, os, sys

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - SPE/HVM/AM/BanCoppel/Informix/")
SW2  = BASE + "knowledge-base/rules/batches/swarm2/"
DB   = BASE + "digital-brain/brain.db"
OUT_OVERRIDES = SW2 + "overrides.json"
OUT_AUDIT     = BASE + "knowledge-base/rules/bad-names-audit3.json"

# ── 1. Cargar brain.db: sps biz (canónico db:sp_name) ──────────────────────
conn = sqlite3.connect(DB)
cur  = conn.cursor()
rows = cur.execute("SELECT id, biz FROM sps WHERE biz IS NOT NULL AND biz != ''").fetchall()

def _clean_biz(biz: str) -> str:
    """Elimina anotaciones de vocabulario (después de ' — ') y recorta."""
    if " — " in biz:
        biz = biz.split(" — ")[0].strip()
    # Quitar sufijos de aclaración entre paréntesis si quedan muy largos
    if len(biz) > 90:
        m = re.search(r"^(.{40,90})\s*[\(;]", biz)
        if m:
            biz = m.group(1).strip()
    return biz[:100].strip()

BIZ  = {r[0]: _clean_biz(r[1]) for r in rows}
BIZ_BY_NAME = {}
for sid, biz in BIZ.items():
    sp_name = sid.split(":")[-1]
    if sp_name not in BIZ_BY_NAME:
        BIZ_BY_NAME[sp_name] = biz
conn.close()
print(f"brain.db SPs con biz: {len(BIZ):,}")

# ── 2. Helpers de normalización ─────────────────────────────────────────────

_ENC_FIX = [
    (r"EJECUCIï¿½\?N", "EJECUCIÓN"),
    (r"EJECUCIï¿½N",   "EJECUCIÓN"),
    (r"EJECUCIÃN",      "EJECUCIÓN"),
    (r"EJECUCIÃ\x91N", "EJECUCIÓN"),
    (r"ejecuciãn",      "ejecución"),
]
def fix_enc(s):
    for pat, rep in _ENC_FIX:
        s = re.sub(pat, rep, s)
    return s

def cap1(s):
    """Primera letra mayúscula."""
    if not s:
        return s
    return s[0].upper() + s[1:]

# ── 3. Estrategia RAISE EXCEPTION ───────────────────────────────────────────
_RAISE_RE = re.compile(
    r"ERROR EN (?:LA )?EJECUCI[ÃA]?\??[Ó]?[Nn] (?:DE[L]? )?SP\s+['\"]?([a-zA-Z0-9_:]+)",
    re.IGNORECASE
)
# Regex adicional para current_name: "Error en la ejecución del sp [ref]"
_CURNAME_SP_RE = re.compile(
    r"del sp\s+([a-zA-Z0-9_:]+)\s*$",
    re.IGNORECASE
)
def enrich_raise(rule) -> tuple[str, str]:
    """Devuelve (bc_name, confidence='high'|'medium'|'low')."""
    code     = fix_enc(rule.get("code", ""))
    cur_name = fix_enc(rule.get("current_name", ""))
    sp_ref   = None

    m = _RAISE_RE.search(code)
    if m:
        candidate = m.group(1).strip("'\" ,;").rstrip("_")
        # Descartar si quedó incompleto (solo prefijo db: o solo "sp_")
        if len(candidate) > 5 and candidate not in ("sp_", "bdinteg:", "bdicnweb:"):
            sp_ref = candidate

    if not sp_ref:
        # Intentar desde current_name
        m2 = _CURNAME_SP_RE.search(cur_name)
        if m2:
            candidate = m2.group(1).strip("'\" ,;").rstrip("_")
            if len(candidate) > 5:
                sp_ref = candidate

    if not sp_ref:
        # Fallback: usar SP contenedor
        outer_sp = rule.get("sp", "")
        outer_db = rule.get("db", "")
        outer_id = f"{outer_db}:{outer_sp}"
        outer_biz = BIZ.get(outer_id) or BIZ_BY_NAME.get(outer_sp, "")
        if outer_biz:
            # Cap a 50 chars para evitar descripciones compuestas largas
            short = outer_biz[:52].rsplit(" ", 1)[0] if len(outer_biz) > 50 else outer_biz
            return f"valida resultado de ejecución en proceso de {short}", "low"
        return f"propaga error de ejecución del procedimiento {outer_sp}", "low"

    # Limpiar la referencia al SP
    sp_ref = fix_enc(sp_ref)
    # Quitar sufijo colgante con comillas/punto y coma
    sp_ref = re.sub(r"['\";,\s]+$", "", sp_ref)

    # Resolver biz
    if ":" in sp_ref:
        biz = BIZ.get(sp_ref)
        sp_name_only = sp_ref.split(":")[-1]
    else:
        biz = BIZ_BY_NAME.get(sp_ref)
        sp_name_only = sp_ref

    if biz:
        return f"propaga error al ejecutar {biz}", "high"
    # Fallback humanize del nombre del SP
    readable = sp_name_only.replace("sp_", "").replace("_", " ").strip()
    return f"propaga error al ejecutar procedimiento {readable}", "medium"

# ── 4. Estrategia dbaccess / shell ──────────────────────────────────────────
_DBACCESS_RE = re.compile(r"dbaccess\s+(\w+)", re.IGNORECASE)
_SQL_FILE_RE = re.compile(r"'([\w_]+\.sql)'", re.IGNORECASE)
def enrich_dbaccess(rule) -> tuple[str, str]:
    code = rule.get("code", "")
    cur_name = rule.get("current_name", "").strip()
    # Si current_name ya es descriptivo (no es "Fórmula:"), usarlo
    if cur_name and not cur_name.lower().startswith("fórmula"):
        return cap1(cur_name), "high"
    m_db  = _DBACCESS_RE.search(code)
    m_sql = _SQL_FILE_RE.search(code)
    db_name  = m_db.group(1)  if m_db  else ""
    sql_file = m_sql.group(1) if m_sql else ""
    sql_desc = sql_file.replace(".sql", "").replace("_", " ") if sql_file else "script SQL"
    if db_name:
        return f"ejecuta {sql_desc} en base de datos {db_name}", "medium"
    return f"ejecuta {sql_desc}", "medium"

# ── 5. Estrategia echo/UNLOAD (reportes con columnas) ───────────────────────
_ECHO_COLS_RE = re.compile(r"""echo\s+['"]([\w\s|áéíóúÁÉÍÓÚñÑ_/().,-]+)['"]\s*[|>]""",
                            re.IGNORECASE)
def _extract_columns(code: str) -> list[str]:
    m = _ECHO_COLS_RE.search(code)
    if not m:
        # Fallback: buscar literal entre comillas con pipes
        m2 = re.search(r"""['"]([\w\s|áéíóúÁÉÍÓÚñÑ_/().,-]{10,})['"]\s*[|>]""", code)
        if m2:
            raw = m2.group(1)
        else:
            return []
    else:
        raw = m.group(1)
    cols = [c.strip() for c in raw.split("|") if c.strip()]
    return cols[:5]  # primeras 5

def enrich_echo(rule) -> tuple[str, str]:
    code = rule.get("code", "")
    cur_name = rule.get("current_name", "")
    cols = _extract_columns(code)
    # Detectar dominio del SP
    db = rule.get("db", "")
    sp = rule.get("sp", "")
    context = ""
    if "aclaracion" in db or "acl" in sp:
        context = "de aclaraciones bancarias"
    elif "cobranza" in db:
        context = "de cobranza"
    elif "spei" in db or "spei" in sp:
        context = "SPEI"
    elif "tarjeta" in db or "intercard" in db or "card" in sp:
        context = "de tarjetas"
    elif "solic" in db:
        context = "de solicitudes de crédito"
    elif "tef" in db or "tef" in sp:
        context = "de Transferencia Electrónica"

    # Detectar si es UNLOAD (descarga) o echo (genera encabezado)
    is_unload = "UNLOAD" in code.upper()

    if cols:
        first_cols = ", ".join(cols[:3])
        if is_unload:
            return f"descarga datos {context} con campos: {first_cols}", "medium"
        return f"genera encabezado de archivo {context} con campos: {first_cols}", "medium"

    # Fallback: usar current_name si no es "Fórmula:"
    if cur_name and not cur_name.lower().startswith("fórmula"):
        return cap1(cur_name), "medium"
    return None, "low"

# ── 6. Estrategia sed (transformación de archivo) ───────────────────────────
_SED_PATH_RE = re.compile(r"(/[\w/._-]+)")
def enrich_sed(rule) -> tuple[str, str]:
    code = rule.get("code", "")
    paths = _SED_PATH_RE.findall(code)
    # Buscar path relevante (no el binario sed)
    data_path = next((p for p in paths if "sed" not in p and "bin" not in p), "")
    if data_path:
        fname = os.path.basename(data_path)
        return f"transforma separadores en archivo de {fname.replace('_', ' ').replace('.', ' ')}", "medium"
    return "limpia formato de archivo de exportación", "low"

# ── 7. Estrategia math formula ───────────────────────────────────────────────
def enrich_math(rule) -> tuple[str, str]:
    code = rule.get("code", "").strip()
    cur_name = rule.get("current_name", "")

    # GAT / interés
    if "POW" in code and "tasa" in code.lower():
        return "calcula tasa GAT nominal anualizada por período", "high"
    # IVA
    if re.search(r"iva", code, re.IGNORECASE) and ("*" in code or "/" in code):
        return "calcula IVA sobre importe de comisión o convenio", "medium"
    # Denominaciones de efectivo
    if re.search(r"pcant\d+", code):
        return "calcula monto total de efectivo sumando piezas por denominación", "high"
    # Acumulado SQL (importe/operaciones)
    if "SUM" in code.upper() and "COUNT" in code.upper():
        return "acumula importe y número de operaciones redondeando montos", "medium"
    # Valor monetario total
    if re.search(r"valor.*total|total.*valor", code, re.IGNORECASE):
        return "calcula valor monetario total de la operación", "medium"
    # Monto de convenio
    if "convenio" in code.lower() and ("*" in code or "/" in code):
        return "calcula importe de cargo o comisión de convenio", "medium"

    # Fallback con current_name
    if cur_name and not cur_name.lower().startswith("fórmula"):
        return cap1(cur_name), "medium"
    return None, "low"

# ── 8. Estrategia string message ────────────────────────────────────────────
def enrich_string_msg(rule) -> tuple[str, str]:
    code = rule.get("code", "")
    # Extraer primer literal de cadena significativo
    m = re.search(r'"([^"]{15,})"', code)
    if not m:
        m = re.search(r"'([^']{15,})'", code)
    if m:
        snippet = m.group(1)[:80]
        if "SALDO" in snippet.upper():
            return "construye mensaje de notificación con saldo de cuenta", "medium"
        if "Lamentamos" in snippet or "No Procede" in snippet:
            return "construye mensaje de rechazo de aclaración bancaria por solicitud no procedente", "high"
        if "vencimiento" in snippet.lower() or "vencido" in snippet.lower():
            return "construye mensaje de notificación de vencimiento de crédito", "medium"
        if "BIENVENIDO" in snippet.upper() or "bienvenid" in snippet.lower():
            return "construye mensaje de bienvenida para el cliente", "medium"
        # Mensaje genérico
        return f"construye mensaje: «{snippet[:50]}...»", "low"
    return None, "low"

# ── 9. Estrategia code_frag (variable assignment con comentario) ─────────────
def enrich_code_frag(rule) -> tuple[str, str]:
    code = rule.get("code", "")
    # Extraer comentario después de --
    m = re.search(r"--+\s*(.+)", code)
    if m:
        comment = m.group(1).strip()
        # Limpiar artefactos de código
        comment = re.sub(r"//.*$", "", comment).strip()
        comment = re.sub(r"LET\s+\w+\s*=.*$", "", comment).strip()
        if len(comment) > 8:
            return cap1(comment.lower()), "medium"
    # Buscar la variable que se asigna
    m2 = re.search(r"^(\w+)\s*=\s*['\"]([^'\"]{5,})['\"]", code.strip())
    if m2:
        val = m2.group(2)[:60]
        return f"asigna valor «{val}» como parámetro de control", "low"
    return None, "low"

# ── 10. Fallback: limpiar current_name ──────────────────────────────────────
_FORMULA_PREFIX_RE = re.compile(r"^fórmula\s*:\s*", re.IGNORECASE)
def enrich_fallback(rule) -> tuple[str, str]:
    cur_name = fix_enc(rule.get("current_name", "")).strip()
    if not cur_name or cur_name in ("…", "..."):
        sp = rule.get("sp", "").replace("sp_", "").replace("_", " ")
        return f"ejecuta procedimiento {sp}", "low"
    # Quitar prefijo "Fórmula:"
    cleaned = _FORMULA_PREFIX_RE.sub("", cur_name).strip()
    # Quitar puntos suspensivos, artefactos
    cleaned = re.sub(r"[\.…]+$", "", cleaned).strip()
    # Si quedó algo útil
    if len(cleaned) > 6 and not cleaned.lower().startswith("ipcb"):
        return cap1(cleaned), "low"
    sp = rule.get("sp", "").replace("sp_", "").replace("_", " ")
    return f"ejecuta procedimiento {sp}", "low"

# ── 11. Router principal ─────────────────────────────────────────────────────
def enrich_rule(rule) -> tuple[str, str]:
    code    = rule.get("code", "")
    cat     = rule.get("category", "")
    tipo    = rule.get("tipo", "")

    # RAISE EXCEPTION (mayoría de D01 y varios otros)
    if re.search(r"RAISE\s+EXCEPTION", code, re.IGNORECASE):
        return enrich_raise(rule)

    # dbaccess shell
    if "dbaccess" in code.lower():
        return enrich_dbaccess(rule)

    # echo / UNLOAD → reportes con columnas
    if re.search(r"\becho\b|\bUNLOAD\b", code, re.IGNORECASE):
        result, conf = enrich_echo(rule)
        if result:
            return result, conf

    # sed
    if re.search(r"\bsed\b", code, re.IGNORECASE):
        return enrich_sed(rule)

    # math formula
    if tipo == "FÓRMULA" and cat in ("formula_raw", "param_list"):
        result, conf = enrich_math(rule)
        if result:
            return result, conf

    # string message
    if tipo == "FÓRMULA":
        result, conf = enrich_string_msg(rule)
        if result:
            return result, conf

    # code_frag
    if cat == "code_frag":
        result, conf = enrich_code_frag(rule)
        if result:
            return result, conf

    # sp_in_name — el SP en el nombre da la pista
    if cat == "sp_in_name":
        cur_name = rule.get("current_name", "")
        if cur_name and not cur_name.lower().startswith("fórmula"):
            return cap1(fix_enc(cur_name)), "medium"

    return enrich_fallback(rule)

def enrich(rule) -> tuple[str, str]:
    """Router con cap final de longitud."""
    bc, conf = enrich_rule(rule)
    if not bc:
        bc, conf = enrich_fallback(rule)
    if len(bc) > 110:
        bc = bc[:108].rsplit(" ", 1)[0] + "…"
    return bc, conf

# ── 12. Procesar todos los batches ───────────────────────────────────────────
overrides  = {}
low_conf   = []
stats = {"high": 0, "medium": 0, "low": 0}
total = 0

for batch_file in sorted(glob.glob(SW2 + "batch-*.json")):
    data = json.load(open(batch_file, encoding="utf-8"))
    for rule in data.get("rules", []):
        rid   = rule["id"]
        bc, conf = enrich(rule)
        overrides[rid] = bc
        stats[conf] += 1
        total += 1
        if conf == "low":
            low_conf.append({
                "id": rid, "sp": rule["db"]+":"+rule["sp"],
                "category": rule["category"], "tipo": rule["tipo"],
                "code": rule["code"][:120],
                "current_name": rule.get("current_name","")[:80],
                "generated": bc
            })

print(f"\nTotal reglas procesadas: {total}")
print(f"  Alta confianza  : {stats['high']:>4} ({100*stats['high']//total}%)")
print(f"  Media confianza : {stats['medium']:>4} ({100*stats['medium']//total}%)")
print(f"  Baja confianza  : {stats['low']:>4} ({100*stats['low']//total}%)")

# ── 13. Guardar salidas ──────────────────────────────────────────────────────
with open(OUT_OVERRIDES, "w", encoding="utf-8") as f:
    json.dump(overrides, f, ensure_ascii=False, indent=2)
print(f"\nOverrides guardados: {OUT_OVERRIDES}")

with open(OUT_AUDIT, "w", encoding="utf-8") as f:
    json.dump({"total_low": len(low_conf), "rules": low_conf}, f, ensure_ascii=False, indent=2)
print(f"Audit baja confianza: {OUT_AUDIT} ({len(low_conf)} reglas)")