#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ola-b-upgrade.py — Ola B: sube confianza inf/gap → conf en UPGRADE_CANDIDATES
Ejecuta: python generators/ola-b-upgrade.py

Criterio de upgrade: ≥10 SPs de evidencia en el knowledge base, o ≥3 reglas/journeys.
'generar' se omite — ya eliminado en Ola A.
"""

import re, shutil, sqlite3, sys
from pathlib import Path
from datetime import datetime

sys.stdout.reconfigure(encoding="utf-8")

BASE      = Path(__file__).parent.parent
VOCAB_PY  = BASE / "generators" / "sp_vocab.py"
BRAIN_DB  = BASE / "digital-brain" / "brain.db"

# ── Lista UPGRADE_CANDIDATES (inf/gap → conf) ─────────────────────────────
UPGRADE = {
    "ope", "sw", "ro", "ofi", "gen", "cg", "cjunk", "cac", "rem", "sd",
    "obt", "con", "cp", "sol", "aut", "fc", "cc", "cre", "os", "iccat",
    "ss", "bym", "crd", "sps", "ref", "ins", "aud", "corrige", "prod",
    "dinya", "domi", "suc", "upgrade", "his", "exp", "reg", "arch", "auto",
    "mib", "sdos", "sif", "cal", "chq", "cnt", "arr", "cpl", "ftc", "int",
    "synmotor", "det", "mueve", "proac", "respalda", "rev", "adm", "dicta",
    "borra", "calif", "cam", "credisoluciones", "ics", "movs", "tels", "upd",
    "ccl", "chi", "nom", "bex", "dv", "edo", "indicador", "tar", "clon",
    "cnr", "dep", "bccc", "evc", "mon", "inv",
    # generar fue eliminado en Ola A — se omite
}

# ── Backup sp_vocab.py ───────────────────────────────────────────────────────
ts = datetime.now().strftime("%Y%m%d_%H%M%S")
backup = VOCAB_PY.with_suffix(f".bak_{ts}.py")
shutil.copy2(VOCAB_PY, backup)
print(f"Backup: {backup.name}")

# ── Editar sp_vocab.py: inf/gap → conf ──────────────────────────────────────
text = VOCAB_PY.read_text(encoding="utf-8")

upgraded_vocab = []
skipped_vocab  = []

for token in sorted(UPGRADE):
    # Match the entry and capture its current state
    pat = r'("' + re.escape(token) + r'"\s*:\s*\("[^"]*",\s*"[^"]*",\s*)"(inf|gap)"(\s*\))'
    def make_repl(t):
        def _repl(m):
            upgraded_vocab.append(t)
            return m.group(1) + '"conf"' + m.group(3)
        return _repl
    new_text, n = re.subn(pat, make_repl(token), text)
    if n > 0:
        text = new_text
    else:
        skipped_vocab.append(token)

VOCAB_PY.write_text(text, encoding="utf-8")
print(f"\nsp_vocab.py: {len(upgraded_vocab)} términos → conf")
if skipped_vocab:
    print(f"  No encontrados / ya conf ({len(skipped_vocab)}): {', '.join(skipped_vocab)}")

# ── Verificar sintaxis ────────────────────────────────────────────────────────
import ast
try:
    ast.parse(VOCAB_PY.read_text(encoding="utf-8"))
    print("  Sintaxis Python OK")
except SyntaxError as e:
    print(f"[ERROR] Sintaxis rota: {e}")
    shutil.copy2(backup, VOCAB_PY)
    print("Backup restaurado.")
    sys.exit(1)

# ── Actualizar brain.db: est → conf ──────────────────────────────────────────
conn = sqlite3.connect(BRAIN_DB)
cur  = conn.cursor()

updated_db = []
for token in sorted(UPGRADE):
    row = cur.execute("SELECT term, est FROM terms WHERE term=?", (token,)).fetchone()
    if row:
        if row[1] in ("inf", "gap"):
            cur.execute("UPDATE terms SET est='conf' WHERE term=?", (token,))
            updated_db.append(token)

conn.commit()
conn.close()
print(f"\nbrain.db: {len(updated_db)} términos actualizados → conf")

# ── Resumen ────────────────────────────────────────────────────────────────────
print(f"""
─────────────────────────────────────────
Ola B completada
  sp_vocab.py upgrades : {len(upgraded_vocab)}
  brain.db upgrades    : {len(updated_db)}
  Backup               : {backup.name}

Próximos pasos:
  1. python generators/build-vocab-inventory.py   # reconstruye inventory
  2. python generators/build-vocab-report-v2.py   # regenera HTML
─────────────────────────────────────────""")
