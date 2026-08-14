#!/usr/bin/env python3
"""
Consolida los 4 outputs del swarm de enriquecimiento de journeys,
actualiza brain.db y regenera el portal HTML.
"""
import json, sqlite3, os, subprocess

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - SPE/HVM/AM/BanCoppel/Informix/")
KB   = BASE + "knowledge-base/"
DB   = BASE + "digital-brain/brain.db"

# 1. Consolidar los 4 JSONs
overrides: dict = {}
for i in range(1, 5):
    path = KB + f"journey-enrichment-output-batch{i}.json"
    if not os.path.exists(path):
        print(f"FALTANTE: {path}")
        continue
    batch = json.load(open(path, encoding="utf-8"))
    print(f"Batch {i}: {len(batch)} journeys")
    overrides.update(batch)

print(f"\nTotal overrides consolidados: {len(overrides)}")

# Guardar overrides consolidados
out_path = KB + "journey-biz-overrides.json"
json.dump(overrides, open(out_path, "w", encoding="utf-8"),
          ensure_ascii=False, indent=2)
print(f"Guardado: {out_path}")

# 2. Aplicar overrides a brain.db
conn = sqlite3.connect(DB)
cur  = conn.cursor()

# Verificar estado previo
total_journeys = cur.execute("SELECT COUNT(*) FROM journeys").fetchone()[0]
print(f"\nbrain.db journeys total: {total_journeys}")

updated = 0
not_found = []
for jid, new_biz in overrides.items():
    # Verificar que el journey existe
    row = cur.execute("SELECT id, biz FROM journeys WHERE id=?", (jid,)).fetchone()
    if row is None:
        not_found.append(jid)
        continue
    cur.execute("UPDATE journeys SET biz=? WHERE id=?", (new_biz, jid))
    updated += 1

conn.commit()
conn.close()

print(f"Journeys actualizados: {updated}")
if not_found:
    print(f"No encontrados ({len(not_found)}): {not_found[:5]}{'...' if len(not_found)>5 else ''}")

# 3. Regenerar el HTML
print("\nRegenerando portal/capability-model-bcop-v2.html...")
gen_script = BASE + "generators/build-capability-model.py"
result = subprocess.run(
    ["python", gen_script],
    cwd=BASE,
    capture_output=True, text=True, encoding="utf-8"
)
if result.returncode == 0:
    print("HTML regenerado OK")
    if result.stdout:
        print(result.stdout[:500])
else:
    print("ERROR regenerando HTML:")
    print(result.stderr[:1000])

print("\nDone.")
