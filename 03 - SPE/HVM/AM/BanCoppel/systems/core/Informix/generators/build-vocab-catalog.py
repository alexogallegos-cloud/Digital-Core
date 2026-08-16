"""
build-vocab-catalog.py — Genera portal/vocabulary-catalog-bcop.html
Layout "El lenguaje del core bancario" (VOCABULARIO SPL · hero con tiles · explorador
con columnas Término/Significado/CAT/Bounded Context/Dom/Familia/Máscara/Unidades/Frec).

Llena la plantilla generators/vocab-catalog.tmpl.html (placeholder %%DATA%%) con los
términos de knowledge-base/vocabulary/vocabulary-catalog-data.json, SOBREPONIENDO los
'mean' de calidad desde vocabulary-inventory.json (cuya fuente autoritativa es el CAT de
sp_vocab.py). Así el catálogo conserva su layout original y siempre usa las descripciones
de negocio de calidad en cada regeneración.

Uso: python generators/build-vocab-catalog.py
"""
import json, sys
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent           # Informix/
TMPL = Path(__file__).resolve().parent / "vocab-catalog.tmpl.html"
DATA = BASE / "knowledge-base" / "vocabulary" / "vocabulary-catalog-data.json"
INV  = BASE / "knowledge-base" / "vocabulary-inventory.json"
OUT  = BASE / "portal" / "vocabulary-catalog-bcop.html"

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

html = TMPL.read_text(encoding="utf-8").replace("%%DATA%%", json.dumps(terms, ensure_ascii=False))
OUT.write_text(html, encoding="utf-8")

taut = sum(1 for t in terms if (t.get("mean") or "").strip().lower() == t["term"].strip().lower())
print(f"vocabulary-catalog-bcop.html escrito · {len(terms)} términos · "
      f"{overlaid} means de calidad sobrepuestos · {taut} tautológicos restantes")
