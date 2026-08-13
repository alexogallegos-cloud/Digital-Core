#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ola-c-tipos.py — Ola C: asigna tipo y mascara a términos desde código AS-IS

Estrategia:
  1. Escaneo único de ~12K archivos SQL (solo los primeros 200 lines = firmas + DEFINE)
  2. Extrae pares (nombre_variable → tipo_informix) con 3 patrones regex
  3. Para cada término del vocabulario, busca variables que LO CONTIENEN (como subcadena)
  4. Voto mayoritario de tipos → tipo canónico (NUM/ALFA/FECHA/BOOL)
  5. Mascara = tipo Informix más frecuente (e.g. "DECIMAL(18,2)", "CHAR(20)")
  6. Agrega columnas tipo/mascara a brain.db + actualiza

Ejecuta: python generators/ola-c-tipos.py
"""

import re, sqlite3, sys, shutil
from pathlib import Path
from datetime import datetime
from collections import Counter, defaultdict

sys.stdout.reconfigure(encoding="utf-8")

BASE     = Path(__file__).parent.parent
SRC_DIR  = BASE / "source" / "Informix" / "informix"
BRAIN_DB = BASE / "digital-brain" / "brain.db"

# ── Patrones regex de extracción de tipos Informix ──────────────────────────
_TYPE = (
    r"(CHAR\s*\(\s*\d+\s*\)"
    r"|DECIMAL\s*\(\s*\d+\s*,\s*\d+\s*\)"
    r"|MONEY\s*\(\s*\d+\s*,\s*\d+\s*\)"
    r"|DATE(?!\s*TIME)\b"
    r"|DATETIME\s+\w+\s+TO\s+\w+"
    r"|INTEGER\b"
    r"|SMALLINT\b"
    r"|BOOLEAN\b"
    r"|INT\b)"
)

# Patrón 1: param/DEFINE → "nombre TYPE"
RE_NAMETYP = re.compile(r"\b(\w{3,})\s+" + _TYPE, re.IGNORECASE)
# Patrón 2: RETURNING → "TYPE AS nombre"
RE_TYPNAME = re.compile(_TYPE + r"\s+AS\s+(\w{3,})", re.IGNORECASE)

def _normalize_type(raw: str) -> str:
    """Normaliza el tipo Informix a forma canónica compacta."""
    r = re.sub(r"\s+", "", raw.upper())
    r = re.sub(r"DATETIME\w+TO\w+", "DATETIME", r)
    return r

def _tipo_from_informix(itype: str) -> str:
    t = itype.upper().replace(" ", "")
    if t.startswith("CHAR") or t.startswith("VARCHAR"):
        return "ALFA"
    if t.startswith("DECIMAL") or t.startswith("MONEY") or t.startswith("FLOAT"):
        return "NUM"
    if t in ("INTEGER", "SMALLINT", "INT"):
        return "NUM"
    if t.startswith("DATE"):
        return "FECHA"
    if t == "BOOLEAN":
        return "BOOL"
    return "?"

# ── Paso 1: escaneo único de fuentes ─────────────────────────────────────────
print("Escaneando fuentes SQL...")
sql_files = list(SRC_DIR.glob("*.sql"))
print(f"  {len(sql_files)} archivos encontrados")

# name_types: {norm_name: Counter({tipo_informix: count})}
name_types: dict[str, Counter] = defaultdict(Counter)

LINES_TO_READ = 250  # primeros N lines — firmas + DEFINE block

for i, fpath in enumerate(sql_files):
    if i % 2000 == 0:
        print(f"  {i}/{len(sql_files)}...", end="\r")
    try:
        lines = []
        with open(fpath, encoding="utf-8", errors="replace") as fh:
            for j, ln in enumerate(fh):
                if j >= LINES_TO_READ:
                    break
                lines.append(ln)
    except Exception:
        continue

    text = " ".join(lines)

    # Patrón 1: nombre TYPE
    for m in RE_NAMETYP.finditer(text):
        name = m.group(1).lower().lstrip("p")  # strip leading 'p' (param prefix)
        itype = _normalize_type(m.group(2))
        name_types[name][itype] += 1

    # Patrón 2: TYPE AS nombre
    for m in RE_TYPNAME.finditer(text):
        itype = _normalize_type(m.group(1))
        name = m.group(2).lower()
        name_types[name][itype] += 1

print(f"\n  {len(name_types)} nombres únicos indexados")

# ── Paso 2: cargar vocabulario ────────────────────────────────────────────────
sys.path.insert(0, str(BASE / "generators"))
import sp_vocab  # type: ignore

vocab_terms = list(sp_vocab.CAT.keys())
print(f"  {len(vocab_terms)} términos en sp_vocab")

# ── Paso 3: asignar tipo/mascara a cada término ──────────────────────────────
print("\nAsignando tipo/mascara...")

results: dict[str, tuple[str, str, str]] = {}  # term → (tipo, mascara, evidence)

for term in vocab_terms:
    cat, _, _ = sp_vocab.CAT[term]

    # Acciones y prefijos de sistema no tienen tipo de dato
    if cat == "ACCION":
        results[term] = ("—", "—", "accion")
        continue
    if cat == "REG":
        results[term] = ("—", "—", "regulacion")
        continue

    # Buscar todas las variables que contienen este término como subcadena
    agg: Counter = Counter()
    hits = 0
    for var_name, type_counter in name_types.items():
        if term in var_name:  # subcadena exacta (ya en minúsculas)
            for itype, cnt in type_counter.items():
                agg[itype] += cnt
                hits += cnt

    if hits == 0:
        # Intento con partial match (term como prefijo de variable)
        for var_name, type_counter in name_types.items():
            if var_name.startswith(term) or var_name.endswith(term):
                for itype, cnt in type_counter.items():
                    agg[itype] += cnt
                    hits += cnt

    if hits == 0:
        results[term] = ("?", "?", "no_evidence")
        continue

    # Tipo dominante
    dominant_itype, dominant_count = agg.most_common(1)[0]
    tipo = _tipo_from_informix(dominant_itype)
    mascara = dominant_itype  # mantener tipo Informix exacto como mascara
    evidence = f"{hits} ocurrencias"

    results[term] = (tipo, mascara, evidence)

# ── Resumen de distribución ───────────────────────────────────────────────────
tipo_dist: Counter = Counter(v[0] for v in results.values())
no_ev = sum(1 for v in results.values() if v[2] == "no_evidence")
print(f"\nDistribución tipo:")
for t, cnt in tipo_dist.most_common():
    print(f"  {t:<10} {cnt:>4}")
print(f"  Sin evidencia : {no_ev}")

# ── Paso 4: agregar columnas a brain.db ────────────────────────────────────────
print("\nActualizando brain.db...")
conn = sqlite3.connect(BRAIN_DB)
cur  = conn.cursor()

# Agregar columnas si no existen
for col in ("tipo", "mascara"):
    try:
        cur.execute(f"ALTER TABLE terms ADD COLUMN {col} TEXT DEFAULT '?'")
        print(f"  Columna '{col}' añadida a terms")
    except sqlite3.OperationalError:
        print(f"  Columna '{col}' ya existe")

conn.commit()

# Actualizar
updated = 0
for term, (tipo, mascara, _) in results.items():
    r = cur.execute("SELECT term FROM terms WHERE term=?", (term,)).fetchone()
    if r:
        cur.execute(
            "UPDATE terms SET tipo=?, mascara=? WHERE term=?",
            (tipo, mascara, term)
        )
        updated += 1

conn.commit()
conn.close()
print(f"  {updated} términos actualizados en brain.db")

# ── Paso 5: reporte de top-20 ENTIDAD/PREFIJO con tipo asignado ──────────────
print("\nTop 20 términos ENTIDAD/PREFIJO con tipo:")
print(f"{'TERM':<20} {'CAT':<8} {'TIPO':<8} {'MASCARA':<25} EVIDENCIA")
print("-" * 75)
shown = 0
for term in vocab_terms:
    if shown >= 20: break
    cat, _, _ = sp_vocab.CAT[term]
    if cat not in ("ENTIDAD", "PREFIJO", "MODIF"): continue
    tipo, mascara, ev = results[term]
    print(f"{term:<20} {cat:<8} {tipo:<8} {mascara:<25} {ev}")
    shown += 1

# ── Guardar CSV de evidencia ──────────────────────────────────────────────────
out_csv = BASE / "generators" / "ola-c-tipos-result.csv"
with open(out_csv, "w", encoding="utf-8") as f:
    f.write("term,cat,tipo,mascara,evidencia\n")
    for term in sorted(results.keys()):
        cat, _, _ = sp_vocab.CAT[term]
        tipo, mascara, ev = results[term]
        f.write(f'"{term}","{cat}","{tipo}","{mascara}","{ev}"\n')
print(f"\nCSV de evidencia: {out_csv.name}")

print(f"""
─────────────────────────────────────────
Ola C completada
  Archivos SQL escaneados     : {len(sql_files)}
  Nombres variables indexados : {len(name_types)}
  Términos clasificados       : {updated}
  CSV de evidencia            : ola-c-tipos-result.csv

Próximos pasos:
  1. python generators/build-vocab-report-v2.py   # regenera HTML con columna tipo
─────────────────────────────────────────""")
