"""
build-vocab-catalog.py — Genera dos variantes del catálogo de vocabulario SPL:

  · vocabulary-catalog-bcop.html       — portal (lectura, sin UI de aprobación)
  · vocabulary-catalog-bcop-hitl.html  — revisión HITL (Candidatos pill · Aprobar · Exportar)

Ambas se generan desde el mismo template vocab-catalog.tmpl.html, que usa los
placeholders %%DATA%% y %%HITL%% (true/false). La diferencia es exclusivamente el
flag HITL_MODE que activa/desactiva la columna Aprobar y el botón Exportar.

Uso: python generators/build-vocab-catalog.py
"""
import json, sys
from pathlib import Path

BASE     = Path(__file__).resolve().parent.parent           # Informix/
TMPL     = Path(__file__).resolve().parent / "vocab-catalog.tmpl.html"
DATA     = BASE / "knowledge-base" / "vocabulary" / "vocabulary-catalog-data.json"
INV      = BASE / "knowledge-base" / "vocabulary-inventory.json"
CAND     = BASE / "knowledge-base" / "vocab-candidates.json"
OUT      = BASE / "portal" / "vocabulary-catalog-bcop.html"
OUT_HITL = BASE / "portal" / "vocabulary-catalog-bcop-hitl.html"

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

# Data de columnas (Término/BC/Dom/Familia/Máscara/Unidades/Frec…) — layout original.
cat = json.loads(DATA.read_text(encoding="utf-8"))
terms = cat["terms"]

# Calidad desde el inventario (fuente autoritativa sp_vocab.py CAT): significado +
# confianza (est) + nivel. Se sobrepone al catalog-data para que las mejoras de contenido
# Y de confianza (p.ej. gdf: gap/inf → conf) persistan en cada regeneración.
import hashlib, base64
# ID VOC-XXXXXX de ancho fijo — MISMA función que build-vocab-inventory.py (debe coincidir
# para que el catálogo y brain.db compartan el mismo ID por término).
def _vid(t):
    h = hashlib.sha1(str(t).strip().lower().encode("utf-8")).digest()
    return "VOC-" + base64.b32encode(h).decode("ascii").rstrip("=")[:6]

_NIVEL = {"conf": "ALTA", "inf": "MEDIA", "gap": "AMBIGUA"}
inv = json.loads(INV.read_text(encoding="utf-8"))
# calidad (mean/est/nivel) desde el inventario, por término.
qinv = {}
for _sec in ("atomos", "compuestos", "candidatos"):
    for a in inv.get(_sec, []):
        key = a.get("term") or a.get("frag")
        if not key:
            continue
        m = (a.get("mean") or "").strip()
        if m and m.lower() != str(key).strip().lower():       # ignora tautológicos
            qinv[key] = (m, a.get("est"), a.get("nivel"))

overlaid = 0
for t in terms:
    key = t.get("term") or t.get("frag")
    t["id"] = _vid(key)                  # ID de ancho fijo para TODA palabra (749/749)
    q = qinv.get(key)
    if not q:
        continue
    mean, est, nivel = q
    changed = False
    if mean != t.get("mean"):
        t["mean"] = mean; changed = True
    if est and est != t.get("est"):
        t["est"] = est
        t["nivel"] = nivel or _NIVEL.get(est, t.get("nivel"))
        changed = True
    if changed:
        overlaid += 1

# Inyectar candidatos de vocab-candidates.json como nivel CANDIDATO
n_cand = 0
if CAND.exists():
    cand_data = json.loads(CAND.read_text(encoding="utf-8"))
    existing_terms = {t.get("term", "").lower() for t in terms}
    # Mapeo de categoría inferida a cat canónico
    cat_map = {"ENTIDAD": "ENTIDAD", "ACCION": "ACCION", "MODIF": "MODIF",
               "PREFIJO": "PREFIJO", "REG": "REG"}
    # Todos los candidatos, ordenados por frecuencia descendente para revisión prioritaria
    for c in sorted(cand_data.get("new", []), key=lambda x: x.get("freq", 0), reverse=True):
        tok = c.get("token", "")
        if not tok or tok.lower() in existing_terms:
            continue
        cat_inferred = cat_map.get(c.get("inferred_cat", ""), "?")
        sample = c.get("sample_sps", [])
        terms.append({
            "term":          tok,
            "cat":           cat_inferred,
            "mean":          c.get("mean_inferred", ""),
            "est":           "gap",
            "nivel":         "CANDIDATO",
            "fn":            c.get("freq", 0),
            "fp":            0,
            "deco":          "",
            "bc":            "—",
            "bc_name":       "Sin clasificar",
            "dominio_as_is": "—",
            "es_variante_de": None,
            "tipo_relacion": None,
            "capa_gemelo":   "—",
            "estado":        "CANDIDATO",
            "target_term":   None,
            "regulatorio":   None,
            "nodo_taxonomia": None,
            "validado_por":  None,
            "notas_sme":     sample[0] if sample else None,
            "tipo":          "candidato",
            "scope":         "—",
            "fuente":        "AUTO",
            "nalias":        0,
            "bian":          "—",
            "is_root":       0,
            "root_bc":       "",
            "trasciende":    False,
            "mascara":       "—",
            "unidades":      "—",
            "id":            _vid(tok),
        })
        existing_terms.add(tok.lower())
        n_cand += 1

tmpl_raw  = TMPL.read_text(encoding="utf-8")
data_json = json.dumps(terms, ensure_ascii=False)
taut = sum(1 for t in terms if (t.get("mean") or "").strip().lower() == t["term"].strip().lower())

def _render(hitl: bool) -> str:
    return tmpl_raw.replace("%%DATA%%", data_json).replace("%%HITL%%", "true" if hitl else "false")

OUT.write_text(_render(hitl=False), encoding="utf-8")
OUT_HITL.write_text(_render(hitl=True), encoding="utf-8")

print(f"vocabulary-catalog-bcop.html      escrito · {len(terms)} términos · portal (sin HITL)")
print(f"vocabulary-catalog-bcop-hitl.html escrito · {len(terms)} términos · revisión Specialist")
print(f"  {overlaid} means de calidad sobrepuestos · {taut} tautológicos · {n_cand} candidatos")
