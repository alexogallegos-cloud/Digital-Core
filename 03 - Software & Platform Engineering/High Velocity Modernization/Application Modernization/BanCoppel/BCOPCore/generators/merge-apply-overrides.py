#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
merge-apply-overrides.py — Merge de todos los overrides de agentes + apply a v3.json.

Uso:
  python generators/merge-apply-overrides.py --dry-run   # muestra stats sin escribir
  python generators/merge-apply-overrides.py             # merge + apply + regenera portal
"""
import json, sys, io, argparse
from pathlib import Path

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

BASE       = Path("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
                  "03 - Software & Platform Engineering/High Velocity Modernization/"
                  "Application Modernization/BanCoppel/BCOPCore/")
OVERRIDES_DIR = BASE / "knowledge-base/rules/batches/overrides"
RULES_FILE    = BASE / "portal/data/business-rules-v3.json"

parser = argparse.ArgumentParser()
parser.add_argument("--dry-run", action="store_true")
args = parser.parse_args()

# ── 1. Leer todos los archivos de override ────────────────────────────────────
override_files = sorted(OVERRIDES_DIR.glob("*.json"))
print(f"Override files encontrados: {len(override_files)}")

all_overrides: dict[str, str] = {}
total_per_domain: dict[str, int] = {}

for fpath in override_files:
    try:
        with open(fpath, encoding="utf-8") as f:
            data = json.load(f)
    except Exception as e:
        print(f"  ERROR leyendo {fpath.name}: {e}")
        continue

    overrides = data.get("overrides", [])
    domain    = data.get("domain", fpath.stem)
    valid     = 0
    for item in overrides:
        rid  = item.get("id", "")
        name = (item.get("business_name") or item.get("name") or "").strip()
        if rid and name and len(name) >= 5:
            all_overrides[rid] = name
            valid += 1
    total_per_domain[f"{fpath.stem} ({domain})"] = valid
    print(f"  {fpath.name:<30} → {valid} overrides")

print(f"\nTotal overrides válidos: {len(all_overrides)}")

# ── 2. Aplicar a v3.json ──────────────────────────────────────────────────────
with open(RULES_FILE, encoding="utf-8") as f:
    data = json.load(f)
rules = data["rules"]

patched = 0
skipped_empty = 0
for r in rules:
    rid = r["id"]
    if rid in all_overrides:
        new_name = all_overrides[rid]
        old_name = r.get("business_name", "")
        if new_name != old_name:
            if not args.dry_run:
                r["business_name"] = new_name
            patched += 1
    elif not r.get("business_name"):
        skipped_empty += 1

print(f"Reglas a parchear: {patched}")
print(f"Reglas sin override y sin nombre: {skipped_empty}")

if args.dry_run:
    print("\n[DRY RUN] No se escribió nada.")
    # Muestra sample de overrides
    print("\nSample de overrides (primeros 10):")
    for rid, name in list(all_overrides.items())[:10]:
        orig = next((r.get("business_name","") for r in rules if r["id"]==rid), "")
        print(f"  {rid}: {orig!r} → {name!r}")
    sys.exit(0)

# ── 3. Guardar v3.json actualizado ────────────────────────────────────────────
with open(RULES_FILE, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, separators=(",", ":"))
print(f"\nGuardado: {RULES_FILE}")

# ── 4. Regenerar portal ───────────────────────────────────────────────────────
import subprocess, os
result = subprocess.run(
    [sys.executable, str(BASE / "generators/gen-rules-portal.py")],
    capture_output=True, text=True, encoding="utf-8",
    cwd=str(BASE)
)
if result.returncode == 0:
    for line in result.stdout.strip().splitlines()[-4:]:
        print(line)
else:
    print("ERROR regenerando portal:", result.stderr[:300])

print("\nDone. Abre: http://localhost:8080/rules-catalog-bcop.html")