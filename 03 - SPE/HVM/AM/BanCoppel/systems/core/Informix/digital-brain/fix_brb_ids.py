"""
fix_brb_ids.py — Reasigna los IDs BRB-unk-* con formato legible.

Esquema nuevo: BRB-{db}-{sp_short}-{line}
  db       = columna db real (bdmis, bdisac, bdcre, etc.)
  sp_short = nombre del SP sin prefijo sp_, máx 14 chars
  line     = número de línea

Si hay colisión (mismo db+sp_short+line en SPs distintos), agrega sufijo -2, -3, etc.
"""
import sqlite3, re
from pathlib import Path
from datetime import datetime
import sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

DB  = Path(r"C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core\03 - SPE\HVM\AM\BanCoppel\systems\core\Informix\digital-brain\brain.db")
con = sqlite3.connect(str(DB))
cur = con.cursor()
NOW = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

# Cargar IDs existentes de reglas NO-BRB para no chocar
cur.execute("SELECT id FROM rules WHERE id IS NOT NULL AND id NOT LIKE 'BRB-%'")
existing_ids = {r[0] for r in cur.fetchall()}

# Cargar los BRB-unk (todos son BRB por ahora)
cur.execute("""
    SELECT rowid, id, sp, db, line
    FROM rules
    WHERE id LIKE 'BRB-%'
    ORDER BY db, sp, line
""")
brb_rows = cur.fetchall()
print(f"Reglas BRB a reasignar: {len(brb_rows)}")

def make_readable_id(db_col, sp_col, line):
    db = (db_col or 'unk').strip()
    sp_clean = re.sub(r'^sp_', '', (sp_col or '').strip())  # quitar prefijo sp_
    sp_short = sp_clean[:14].rstrip('_')                    # máx 14 chars, sin _ al final
    return f"BRB-{db}-{sp_short}-{line}"

updates   = []
log_entries = []
seen_ids  = set(existing_ids)

for rowid, old_id, sp, db, line in brb_rows:
    base = make_readable_id(db, sp, line)
    new_id = base
    suffix = 1
    while new_id in seen_ids:
        suffix += 1
        new_id = f"{base}-{suffix}"
    seen_ids.add(new_id)
    updates.append((new_id, old_id))
    log_entries.append((new_id, 'fix_brb_ids', 'id', old_id, new_id, NOW, 1.0, 'readable_id', ''))

# Preview
print("\nPREVIEW — primeros 10:")
for new_id, old_id in updates[:10]:
    print(f"  {old_id:35s} → {new_id}")

# Aplicar
# Primero nullear los viejos para evitar UNIQUE constraint durante el swap
cur.executemany("UPDATE rules SET id=NULL WHERE id=?", [(old,) for _, old in updates])
cur.executemany("UPDATE rules SET id=? WHERE rowid=(SELECT rowid FROM rules WHERE id IS NULL AND sp=? LIMIT 1)",
                [])  # no usar este approach

# Mejor: usar rowid directamente
rowid_map = {old_id: rowid for rowid, old_id, sp, db, line in brb_rows}

# Null todos primero
cur.execute("UPDATE rules SET id=NULL WHERE id LIKE 'BRB-%'")
# Luego asignar los nuevos por rowid
rowid_updates = [(new_id, rowid) for (new_id, old_id), (rowid, _, _, _, _) in zip(updates, brb_rows)]
cur.executemany("UPDATE rules SET id=? WHERE rowid=?", rowid_updates)

# Log
cur.executemany("""
    INSERT INTO rule_enrichment_log (rule_id, swarm, field, old_value, new_value, timestamp, confidence, method, notes)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
""", log_entries)

cur.execute("INSERT INTO rules_fts(rules_fts) VALUES('rebuild')")
con.commit()

# Verificar
cur.execute("SELECT COUNT(*) FROM rules WHERE id LIKE 'BRB-unk-%'")
remaining_unk = cur.fetchone()[0]
cur.execute("SELECT COUNT(*) FROM rules WHERE id LIKE 'BRB-%'")
total_brb = cur.fetchone()[0]

print(f"\n✓ IDs actualizados: {len(updates)}")
print(f"  BRB-unk restantes: {remaining_unk}")
print(f"  BRB total: {total_brb}")

# Muestra final
cur.execute("SELECT id, sp, db, line FROM rules WHERE id LIKE 'BRB-%' LIMIT 8")
print("\nMuestra post-fix:")
for r in cur.fetchall():
    print(f"  {r[0]}")

con.close()
print("\nAhora corre: python digital-brain/rebuild_from_brain.py")
