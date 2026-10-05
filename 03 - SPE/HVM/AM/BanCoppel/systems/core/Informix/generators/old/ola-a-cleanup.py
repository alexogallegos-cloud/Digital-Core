#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ola-a-cleanup.py — Ola A: limpieza del vocabulario sp_vocab.py + brain.db
Ejecuta: python generators/ola-a-cleanup.py

Operaciones:
  1. Elimina 23 REMOVE_CANDIDATES (sin evidencia en KB)
  2. Elimina typo 'consuta'
  3. Elimina 8 infinitivos (mantiene la forma conjugada)
  4. Elimina duplicados/sinónimos (mantiene el término canónico)
  5. Actualiza brain.db (DELETE FROM terms)
  6. Genera backup de sp_vocab.py antes de editar
"""

import re, shutil, sqlite3, sys
from pathlib import Path
from datetime import datetime

sys.stdout.reconfigure(encoding="utf-8")

BASE = Path(__file__).parent.parent
VOCAB_PY = BASE / "generators" / "sp_vocab.py"
BRAIN_DB  = BASE / "digital-brain" / "brain.db"

# ── 1. Lista completa de tokens a eliminar ─────────────────────────────────

REMOVE_CANDIDATES = {
    # Sin evidencia en KB (23 REMOVE_CANDIDATES del análisis)
    "apell", "aum", "b4", "b5", "balp", "cns", "conciliadora", "consolidada",
    "ctb", "ctemoral", "debcred", "digver", "edocuenta", "enavipro", "exec",
    "firme", "lin", "msjafore", "obtenerctas", "paq", "proyeccion", "quebr", "speich",
    # Typo
    "consuta",
    # Infinitivos — se mantiene la forma conjugada (aplica, calcula, etc.)
    "aplicar", "calcular", "consultar", "cobrar", "ejecutar",
    "generar", "inicializar", "decodificar",
    # Sinónimos — se mantiene el término canónico
    "status",        # → estatus
    "valid",         # → valida
    "mvl",           # → movil
    "numcliente",    # → numcte
    "numerocliente", # → numcte
    "tc",            # → tdc  (tarjeta de crédito; tdc es el término dominante)
}

CANONICAL_MAP = {
    "aplicar":        "aplica",
    "calcular":       "calcula",
    "consultar":      "consulta",
    "cobrar":         "cobra",
    "ejecutar":       "ejecuta",
    "generar":        "genera",
    "inicializar":    "inicializa",
    "decodificar":    "decodifica",
    "status":         "estatus",
    "valid":          "valida",
    "mvl":            "movil",
    "numcliente":     "numcte",
    "numerocliente":  "numcte",
    "tc":             "tdc",
}

# ── 2. Backup sp_vocab.py ───────────────────────────────────────────────────

ts = datetime.now().strftime("%Y%m%d_%H%M%S")
backup = VOCAB_PY.with_suffix(f".bak_{ts}.py")
shutil.copy2(VOCAB_PY, backup)
print(f"Backup: {backup.name}")

# ── 3. Leer y editar sp_vocab.py ────────────────────────────────────────────

text = VOCAB_PY.read_text(encoding="utf-8")
original_lines = text.count("\n")

removed = []
not_found = []

for token in sorted(REMOVE_CANDIDATES):
    # Pattern: "token" optionally with spaces, colon, 3-tuple, trailing comma+optional space
    # Handles both standalone-line and inline-with-others entries
    pat = r'"' + re.escape(token) + r'"\s*:\s*\("[^"]*",\s*"[^"]*",\s*"[^"]*"\s*\),?\s*'
    new_text, n = re.subn(pat, "", text)
    if n > 0:
        removed.append(token)
        text = new_text
    else:
        not_found.append(token)

# Clean up: remove lines that became empty or only whitespace after removal
lines = text.splitlines(keepends=True)
clean_lines = []
for ln in lines:
    stripped = ln.strip()
    # Skip lines that are now empty (not comment lines, not code)
    if stripped == "" and clean_lines and clean_lines[-1].strip() == "":
        continue  # collapse consecutive blank lines to one
    clean_lines.append(ln)

text = "".join(clean_lines)
VOCAB_PY.write_text(text, encoding="utf-8")

new_lines = text.count("\n")
print(f"\nsp_vocab.py: {original_lines} → {new_lines} líneas (−{original_lines - new_lines})")
print(f"  Eliminados ({len(removed)}): {', '.join(sorted(removed))}")
if not_found:
    print(f"  No encontrados ({len(not_found)}): {', '.join(not_found)}")

# ── 4. Actualizar brain.db ───────────────────────────────────────────────────

conn = sqlite3.connect(BRAIN_DB)
cur  = conn.cursor()

# Verificar cuáles existen en brain.db
placeholders = ",".join("?" * len(REMOVE_CANDIDATES))
existing = cur.execute(
    f"SELECT term FROM terms WHERE term IN ({placeholders})",
    list(REMOVE_CANDIDATES)
).fetchall()
existing_set = {r[0] for r in existing}

if existing_set:
    cur.execute(
        f"DELETE FROM terms WHERE term IN ({placeholders})",
        list(REMOVE_CANDIDATES)
    )
    conn.commit()
    print(f"\nbrain.db: {len(existing_set)} términos eliminados de terms table")
    print(f"  {', '.join(sorted(existing_set))}")
else:
    print("\nbrain.db: ningún término encontrado en terms (ya limpios o nombre diferente)")

conn.close()

# ── 5. Verificar sintaxis del sp_vocab.py editado ───────────────────────────

import ast
try:
    ast.parse(VOCAB_PY.read_text(encoding="utf-8"))
    print("\nsp_vocab.py: sintaxis Python OK")
except SyntaxError as e:
    print(f"\n[ERROR] Sintaxis rota en sp_vocab.py: {e}")
    print(f"Restaurando backup...")
    shutil.copy2(backup, VOCAB_PY)
    print("Backup restaurado. Revisa manualmente.")
    sys.exit(1)

# ── 6. Resumen ────────────────────────────────────────────────────────────────

print(f"""
─────────────────────────────────────────
Ola A completada
  Tokens eliminados de sp_vocab.py : {len(removed)}
  Tokens en brain.db eliminados    : {len(existing_set)}
  Backup                           : {backup.name}

Próximos pasos:
  1. python generators/build-vocab-inventory.py   # reconstruye vocabulary-inventory.json
  2. python generators/build-vocab-report-v2.py   # regenera el HTML
─────────────────────────────────────────""")
