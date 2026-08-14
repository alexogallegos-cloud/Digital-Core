"""
build-vocab-v1.py — Vocabulario BanCoppel v1.0

Sincroniza el vocabulario de Informix (634 términos) como semilla del
vocabulario canónico del banco. Es la v1: todos los términos heredan
source_systems=["informix"] y maturity="live" (vienen de código verificado).

Salida:
  bank-brain/knowledge-base/vocab/vocab-bancoppel-v1.json  ← legible / versionable
  bank-brain/digital-brain/bank-brain.db :: tabla terms    ← consultable

Cuándo volver a correr:
  - Al agregar un sistema nuevo con su propio vocabulario
  - Al curar términos manualmente (editar vocab-bancoppel-v1.json y recargar)
  - Al resolver conflictos entre sistemas (mismo term, meanings distintos)

Scope rules (heurístico v1):
  PREFIJO con 1-2 chars y meaning de sigla técnica  → system
  ENTIDAD / ACCION / DOMINIO con palabra española   → enterprise
  Todo lo demás                                     → review  (a curar manualmente)
"""

import json
import re
import sqlite3
from datetime import date
from pathlib import Path

# ── Rutas ──────────────────────────────────────────────────────────────────────
BASE        = Path(__file__).parent.parent.parent  # BanCoppel/
INFORMIX_DB = BASE / "systems/core/Informix/digital-brain/brain.db"
BANK_DB     = Path(__file__).parent.parent / "digital-brain/bank-brain.db"
OUT_JSON    = Path(__file__).parent.parent / "knowledge-base/vocab/vocab-bancoppel-v1.json"

VERSION   = "1.0"
GENERATED = date.today().isoformat()

# ── Categorías consideradas enterprise por defecto ────────────────────────────
_ENTERPRISE_CATS = {"ENTIDAD", "ACCION", "DOMINIO", "CONCEPTO", "ESTADO", "ROL"}
_SYSTEM_CATS     = {"PREFIJO", "CODIGO", "ABREVIATURA"}

# Términos técnicos de Informix que no aplican enterprise aunque cat=ENTIDAD
_SYSTEM_TERMS = {
    "sp", "bd", "bdi", "aux", "tmp", "idx", "cnt", "err", "ret",
    "vsd", "bdisp", "dbaccess", "unload", "shell",
}


def classify_scope(term: str, cat: str, meaning: str) -> str:
    t = term.lower().strip()
    if t in _SYSTEM_TERMS:
        return "system"
    if cat in _ENTERPRISE_CATS:
        # Término con palabra española de ≥4 chars → enterprise
        if re.search(r"[a-záéíóúüñ]{4,}", t):
            return "enterprise"
        return "review"
    if cat in _SYSTEM_CATS:
        # Prefijo corto o sigla → system; prefijo largo con significado bancario → review
        if len(t) <= 3:
            return "system"
        return "review"
    return "review"


# ── 1. Leer términos de Informix ───────────────────────────────────────────────
print(f"Leyendo vocabulario de Informix: {INFORMIX_DB}")
inf_conn = sqlite3.connect(INFORMIX_DB)
inf_conn.row_factory = sqlite3.Row
rows = inf_conn.execute(
    "SELECT term, cat, meaning, est, nivel, scope FROM terms ORDER BY term"
).fetchall()
inf_conn.close()
print(f"  {len(rows)} términos encontrados")

# ── 2. Construir términos enriquecidos ─────────────────────────────────────────
terms = []
scope_counts = {"enterprise": 0, "system": 0, "review": 0}

for r in rows:
    term    = r["term"] or ""
    cat     = (r["cat"] or "").upper()
    meaning = r["meaning"] or ""
    est     = r["est"] or "conf"
    nivel   = r["nivel"] or "MEDIA"

    scope = classify_scope(term, cat, meaning)
    scope_counts[scope] += 1

    terms.append({
        "term":           term,
        "cat":            cat,
        "meaning":        meaning,
        "est":            est,
        "nivel":          nivel,
        "scope":          scope,
        "source_systems": ["informix"],
        "maturity":       "live",
    })

print(f"  enterprise: {scope_counts['enterprise']}  "
      f"system: {scope_counts['system']}  "
      f"review: {scope_counts['review']}")

# ── 3. Escribir JSON ───────────────────────────────────────────────────────────
payload = {
    "generated":     GENERATED,
    "version":       VERSION,
    "total":         len(terms),
    "scope_summary": scope_counts,
    "terms":         terms,
}
OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
with open(OUT_JSON, "w", encoding="utf-8") as f:
    json.dump(payload, f, ensure_ascii=False, indent=2)
print(f"\nJSON escrito: {OUT_JSON}  ({OUT_JSON.stat().st_size:,} bytes)")

# ── 4. Cargar en bank-brain.db ────────────────────────────────────────────────
print(f"\nCargando en bank-brain.db: {BANK_DB}")
bb_conn = sqlite3.connect(BANK_DB)
bb_conn.executescript("""
    CREATE TABLE IF NOT EXISTS terms (
        term          TEXT PRIMARY KEY,
        cat           TEXT,
        meaning       TEXT,
        est           TEXT,
        nivel         TEXT,
        scope         TEXT,
        source_systems TEXT DEFAULT '["informix"]',
        maturity       TEXT DEFAULT 'live',
        vocab_version  TEXT
    );
    CREATE VIRTUAL TABLE IF NOT EXISTS terms_fts
        USING fts5(term, cat, meaning, content='terms');
""")

bb_conn.execute("DELETE FROM terms")
bb_conn.executemany("""
    INSERT INTO terms (term, cat, meaning, est, nivel, scope, source_systems, maturity, vocab_version)
    VALUES (:term, :cat, :meaning, :est, :nivel, :scope, :source_systems, :maturity, :vocab_version)
""", [
    {**t,
     "source_systems": json.dumps(t["source_systems"]),
     "vocab_version":  VERSION}
    for t in terms
])
bb_conn.execute("INSERT INTO terms_fts(terms_fts) VALUES('rebuild')")
bb_conn.commit()
bb_conn.close()

loaded = sqlite3.connect(BANK_DB).execute("SELECT COUNT(*) FROM terms").fetchone()[0]
print(f"  {loaded} términos cargados en bank-brain.db")

# ── 5. Preview enterprise ──────────────────────────────────────────────────────
print("\nPreview — primeros 10 enterprise:")
for t in [x for x in terms if x["scope"] == "enterprise"][:10]:
    print(f"  [{t['cat']:10s}] {t['term']:20s} → {t['meaning'][:60]}")