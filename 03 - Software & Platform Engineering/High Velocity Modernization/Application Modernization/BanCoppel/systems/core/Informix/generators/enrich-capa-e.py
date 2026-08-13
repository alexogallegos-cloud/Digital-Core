"""
enrich-capa-e.py — Ola E: mejora semántica de reglas NEGOCIO con nombre genérico.

Objetivo: mejorar los business_name que son:
  • "Cálculo con umbral/factor N"  — 514 reglas (constante numérica sin contexto)
  • "Fórmula: sp_name_tokens"       — 372 reglas (SP name como fallback)
  • "Validación: sp_name_tokens"    — 70 reglas  (SP name como fallback)

Estrategia (sin API Claude):
  A. Detectar la constante de negocio del fragmento de código (IVA, edad, FX…)
  B. Extraer la variable del lado izquierdo (LHS) de la asignación
  C. Limpiar el nombre de la variable (prefijos SPL → tokens legibles)
  D. Cruzar tokens con la tabla terms del brain.db (vocabulario de dominio)
  E. Construir un nombre de negocio: "{sujeto} — {operación}"

Salida:
  knowledge-base/rules/batches/ola-e/overrides.json  — id → nuevo nombre
  knowledge-base/rules/bad-names-audit4.json          — no mejorables (baja confianza)

Merge en name-overrides-ai.json: correr merge-apply-overrides.py después.
"""

import json, re, sqlite3, unicodedata
from pathlib import Path
from collections import defaultdict

BASE     = Path(__file__).resolve().parent.parent
BRAIN    = BASE / "digital-brain" / "brain.db"
OUTDIR   = BASE / "knowledge-base" / "rules" / "batches" / "ola-e"
OUTDIR.mkdir(parents=True, exist_ok=True)
OUT_OVR  = OUTDIR / "overrides.json"
OUT_AUD  = BASE / "knowledge-base" / "rules" / "bad-names-audit4.json"

# ── 0. Cargar vocabulario del dominio (terms) ─────────────────────────────────
conn = sqlite3.connect(BRAIN)
cur  = conn.cursor()
terms_raw = cur.execute(
    "SELECT term, meaning FROM terms WHERE meaning IS NOT NULL AND meaning != ''"
).fetchall()
conn.close()

def _short_meaning(m: str) -> str:
    """Primera oración del meaning, máx 50 chars."""
    m = m.split(";")[0].split(".")[0].strip()
    return m[:50].strip() if m else ""

VOCAB = {}   # term → short meaning
for t, m in terms_raw:
    short = _short_meaning(m)
    if short:
        VOCAB[t.lower()] = short

print(f"Vocabulario cargado: {len(VOCAB)} términos")

# ── 1. Helpers de limpieza y extracción ──────────────────────────────────────

_STRIP_ACCENT = str.maketrans(
    "áéíóúüñÁÉÍÓÚÜÑ",
    "aeiouunAEIOUUN"
)

def strip_a(s: str) -> str:
    return s.translate(_STRIP_ACCENT)

# Prefijos de variables SPL a quitar (orden: más largos primero)
_VAR_PREFIXES = [
    "vsd", "bdi", "ch", "bi", "v_", "m_", "s_", "c_", "n_", "d_",
    "l_", "g_", "e_", "k_", "p_", "i_", "j_", "b_",
]

# Letras de prefijo de tipo SPL (se anteponen antes de una consonante)
_TYPE_PREFIX_LETTERS = set("vmcndslgepb")
# Consonantes (para detectar patrón vfecha, mcodigo, ctipo...)
_CONSONANTS = set("bcdfghjklmnpqrstvwxyz")

def clean_varname(varname: str) -> list[str]:
    """Elimina prefijo SPL, divide camelCase y underscore en tokens."""
    v = varname.strip()
    # Quitar prefijos más largos primero
    for pre in _VAR_PREFIXES:
        lv = v.lower()
        if lv.startswith(pre):
            v = v[len(pre):]
            break
    # Quitar prefijo de una letra si va seguido de mayúscula o _
    if len(v) > 2 and v[0].islower() and (v[1].isupper() or v[1] == "_"):
        v = v[1:]
    # Quitar prefijo de una letra si va seguido de consonante (vfecha→fecha, mtipo→tipo)
    # Solo cuando primera y segunda son letras distintas y el resultado tiene ≥4 chars
    elif (len(v) >= 5
          and v[0].lower() in _TYPE_PREFIX_LETTERS
          and v[1].lower() in _CONSONANTS
          and v[0].lower() != v[1].lower()):   # evitar "cc", "vv"
        v = v[1:]
    v = v.lstrip("_")
    # Dividir camelCase
    v = re.sub(r"([a-z])([A-Z])", r"\1_\2", v)
    parts = [p.lower() for p in re.split(r"[_\s]+", v) if len(p) >= 2]
    return parts


def humanize_tokens(parts: list[str]) -> str:
    """Convierte tokens en texto de negocio usando el vocabulario."""
    result = []
    skip_next = False
    for i, p in enumerate(parts):
        if skip_next:
            skip_next = False
            continue
        # Intentar bigrama primero
        if i + 1 < len(parts):
            bigram = f"{p}{parts[i+1]}"  # e.g. "tipocambio"
            if bigram in VOCAB:
                result.append(VOCAB[bigram])
                skip_next = True
                continue
        if p in VOCAB:
            result.append(VOCAB[p])
        else:
            result.append(p)
    return " ".join(result)


def extract_lhs(code: str) -> str:
    """Extrae la variable del lado izquierdo de la asignación."""
    code = code.strip()
    # "LET var =" o simplemente "var ="
    m = re.match(r"(?:LET\s+)?([a-zA-Z_][a-zA-Z0-9_]*)\s*(?:\[.*?\])?\s*=", code)
    if m:
        return m.group(1)
    # También para "RETURN 'code'" — no hay LHS
    return ""


# ── 2. Detectar la semántica de la constante / operación ─────────────────────

# Mapa de constantes financieras conocidas
_CONST_MAP = [
    # IVA y tasas
    (re.compile(r"[*/]\s*0\.16\b"),    "IVA 16%"),
    (re.compile(r"/\s*1\.16\b"),       "base sin IVA (÷1.16)"),
    (re.compile(r"[*/]\s*0\.15\b"),    "tasa 15%"),
    (re.compile(r"/\s*1\.15\b"),       "base sin tasa (÷1.15)"),
    (re.compile(r"[*/]\s*0\.10\b"),    "tasa 10%"),
    (re.compile(r"/\s*1\.10\b"),       "base sin tasa (÷1.10)"),
    (re.compile(r"[*/]\s*0\.08\b"),    "tasa 8%"),
    (re.compile(r"[*/]\s*0\.09\b"),    "ISR 9%"),
    # Cálculo de edad / tiempo
    (re.compile(r"[*/]\s*365\.25\b"),  "días/año (365.25) → edad exacta"),
    (re.compile(r"/\s*365\b"),         "tasa diaria (base año natural)"),
    (re.compile(r"/\s*360\b"),         "tasa diaria (base año comercial)"),
    (re.compile(r"\*\s*365\b"),        "proyección anual (×365)"),
    (re.compile(r"\*\s*360\b"),        "proyección anual comercial (×360)"),
    # Mensual
    (re.compile(r"/\s*12\b"),          "tasa mensual (÷12)"),
    (re.compile(r"\*\s*12\b"),         "factor anual (×12)"),
    (re.compile(r"[*/]\s*30\b"),       "días por mes (30)"),
    # Porcentaje
    (re.compile(r"\*\s*100\b"),        "conversión a porcentaje (×100)"),
    (re.compile(r"/\s*100\b"),         "conversión desde porcentaje (÷100)"),
    # Inversión de signo
    (re.compile(r"\*\s*\(?-1\)?"),     "inversión de signo (debe/haber)"),
    (re.compile(r"=\s*-\s*[a-zA-Z]"), "negación de valor"),
    # FX / tipo de cambio
    (re.compile(r"[*/]\s*\w*(?:cambio|tipo_cambio|valor_cambio|dolar|dollar|usd)\b", re.IGNORECASE),
                                       "conversión tipo de cambio (FX)"),
    # Fechas nulas / default
    (re.compile(r"'01/01/1900'"),      "fecha por defecto (1900)"),
    (re.compile(r"'[0-9]{2}/[0-9]{2}/[0-9]{4}'"), "asignación de fecha fija"),
    # Formato de fecha / TO_CHAR
    (re.compile(r"TO_CHAR\s*\(", re.IGNORECASE), "formato de fecha"),
    (re.compile(r"MDY\s*\(",  re.IGNORECASE),     "construcción de fecha MDY"),
    (re.compile(r"EXTEND\s*\(", re.IGNORECASE),   "extensión de rango de fecha"),
    # Redondeo
    (re.compile(r"ROUND\s*\(",  re.IGNORECASE),   "redondeo financiero"),
    (re.compile(r"FLOOR\s*\(",  re.IGNORECASE),   "parte entera (FLOOR)"),
    (re.compile(r"CEIL\s*\(",   re.IGNORECASE),   "redondeo hacia arriba (CEIL)"),
]

def detect_operation(code: str) -> str:
    """Detecta la operación de negocio en el fragmento de código."""
    for pattern, label in _CONST_MAP:
        if pattern.search(code):
            return label
    return ""


# ── 3. Construir nombre mejorado ──────────────────────────────────────────────

_GENERIC_FACTOR_RE = re.compile(
    r"C[aá]lculo con umbral/factor\s+([\d\.]+)", re.IGNORECASE
)
_FORMULA_SP_RE = re.compile(
    r"^[Ff][oó]rmula:\s+(.+)$"
)
_VALID_SP_RE = re.compile(
    r"^[Vv]alid[ae]ci[oó]n:\s+(.+)$"
)

# Indicadores regulatorios — skip (nombre intencionalmente regulatorio)
_REGULATORY_RE = re.compile(
    r"\b(LTOSF|CNBV|CONSAR|GAFI|FATCA|LFPDPPP|CECOBAN|SPEI|CoDi|VISA"
    r"|MC\b|LIC\b|LISR|RCSF|LTAIPF|IFRS|SAT|AFORE|CUB|BANXICO|CONDUSEF"
    r"|Art\.\s*\d|Circular|Título|Cap\.\s*[IVXLCD]+|Anexo\s*\d)\b",
    re.IGNORECASE,
)

def build_improved_name(rule_id: str, tipo: str, biz: str, code: str) -> tuple[str, str]:
    """
    Intenta construir un nombre mejorado.
    Retorna (nuevo_nombre, confianza: 'alta'|'media'|'baja')
    """
    # 1. Skip: nombres regulatorios — son correctos por diseño
    if _REGULATORY_RE.search(biz):
        return biz, "skip_regulatory"

    # 2. Detectar operación desde el código
    operation = detect_operation(code or "")

    # 3. Extraer LHS variable
    lhs = extract_lhs(code or "")
    lhs_tokens = clean_varname(lhs) if lhs else []
    lhs_human  = humanize_tokens(lhs_tokens) if lhs_tokens else ""

    # ── Patrón A: "Cálculo con umbral/factor N" ───────────────────────────────
    m = _GENERIC_FACTOR_RE.match(biz)
    if m:
        const_val = m.group(1)
        if operation:
            if lhs_human and lhs_human not in ("", const_val):
                name = f"{lhs_human.capitalize()} — {operation}"
            else:
                name = f"Factor {const_val}: {operation}"
            return name, "alta"
        elif lhs_human:
            name = f"Cálculo de {lhs_human} (factor {const_val})"
            return name, "media"
        else:
            return biz, "baja"

    # ── Patrón B: "Fórmula: sp_name_tokens" ──────────────────────────────────
    m = _FORMULA_SP_RE.match(biz)
    if m:
        if operation:
            if lhs_human:
                name = f"{lhs_human.capitalize()} — {operation}"
            else:
                name = operation.capitalize()
            return name, "alta" if lhs_human else "media"
        elif lhs_human and len(lhs_human) > 4:
            name = f"Cálculo de {lhs_human}"
            return name, "media"
        else:
            return biz, "baja"

    # ── Patrón C: "Validación: sp_name_tokens" ────────────────────────────────
    m = _VALID_SP_RE.match(biz)
    if m:
        # Check for RETURN code pattern
        ret_match = re.search(r"RETURN\s*['\"]([0-9A-Z]+)['\"]", code or "")
        if ret_match:
            code_val = ret_match.group(1)
            name = f"Retorno de código {code_val}"
            return name, "media"
        elif operation:
            name = f"Validación: {operation}"
            return name, "media"
        elif lhs_human:
            name = f"Validación de {lhs_human}"
            return name, "media"
        else:
            return biz, "baja"

    # ── Otros: no son del patrón target ──────────────────────────────────────
    return biz, "no_target"


# ── 4. Procesar reglas desde brain.db ────────────────────────────────────────

conn = sqlite3.connect(BRAIN)
cur  = conn.cursor()

TARGET_PATTERNS = [
    "C%lculo con umbral%",  # Cálculo con umbral/factor
    "F%rmula:%",            # Fórmula: sp_name
    "Validaci%n:%",         # Validación: sp_name
]

rows = []
for pat in TARGET_PATTERNS:
    batch = cur.execute("""
        SELECT id, tipo, sp, db, business_name, code
        FROM rules
        WHERE clase = 'NEGOCIO' AND business_name LIKE ?
    """, (pat,)).fetchall()
    rows.extend(batch)

conn.close()
print(f"Reglas candidatas: {len(rows)}")

overrides: dict[str, str] = {}
audit_low:   list[dict]   = []
stats = defaultdict(int)

for rule_id, tipo, sp, db, biz, code in rows:
    new_name, confidence = build_improved_name(rule_id, tipo, biz, code or "")
    stats[confidence] += 1

    if confidence in ("alta", "media") and new_name != biz:
        overrides[rule_id] = new_name[:120].strip()
    elif confidence == "baja":
        audit_low.append({
            "id": rule_id, "tipo": tipo, "sp": sp,
            "business_name": biz, "code": (code or "")[:100],
        })

print(f"\nResultados Ola E:")
for k, v in sorted(stats.items()):
    print(f"  {k}: {v}")
print(f"\nOverrides generados: {len(overrides)}")
print(f"Reglas de baja confianza: {len(audit_low)}")

# ── 5. Guardar overrides ──────────────────────────────────────────────────────

with open(OUT_OVR, "w", encoding="utf-8") as f:
    json.dump({"generated": "2026-08-13", "total": len(overrides), "names": overrides}, f,
              ensure_ascii=False, indent=2)
print(f"\nOverrides: {OUT_OVR}")

with open(OUT_AUD, "w", encoding="utf-8") as f:
    json.dump(audit_low, f, ensure_ascii=False, indent=2)
print(f"Audit low: {OUT_AUD}")

# ── 6. Preview de los top 15 overrides ────────────────────────────────────────
print("\nPreview overrides (primeros 15):")
for i, (rid, name) in enumerate(list(overrides.items())[:15]):
    orig = next(r[4] for r in rows if r[0] == rid)
    print(f"  {rid}: {orig!r}")
    print(f"         → {name!r}")