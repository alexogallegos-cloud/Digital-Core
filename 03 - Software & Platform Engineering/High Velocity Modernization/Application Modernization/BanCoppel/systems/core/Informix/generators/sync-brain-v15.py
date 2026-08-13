#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
sync-brain-v15.py — Sincronización brain.db con pipeline v1.5.0

Operaciones:
  1. ADD COLUMN rules.business_name  — nombre semántico inferido por infer-rule-names v1.5.0
     Match: (v3.db + ':' + v3.sp, v3.line)  ==  (brain.sp, brain.line)
  2. ADD COLUMN rules.human_expr     — expresión SPL humanizada
  3. ADD COLUMN rules.expl_negocio   — explicación de negocio (cascada comentario→reg→sintetizado)
  4. ADD COLUMN sps.flow_p50_s / flow_p95_s / flow_p99_s / flow_n
     — latencia de flujos multi-SP desde output/log-analysis/latency-by-sp.json
     (distinta de prod_p50_s que mide SP individual; no sobreescribe)

Fuentes:
  portal/data/business-rules-v3.json   — 7,785 reglas con business_name v1.5.0
  output/log-analysis/latency-by-sp.json — 78 SPs con P50/P95/P99 de flujo ESB

SPE-AM-001 · BCOPBrain sync v1.5.0 · 2026-08-07
"""
import json, sqlite3, sys
from pathlib import Path

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

BASE     = Path(__file__).resolve().parent.parent
BRAIN_DB = BASE / "digital-brain" / "brain.db"
V3_JSON  = BASE / "portal" / "data" / "business-rules-v3.json"
LAT_JSON = BASE / "output" / "log-analysis" / "latency-by-sp.json"

# ── 1. Conectar ────────────────────────────────────────────────────────────────
conn = sqlite3.connect(BRAIN_DB)
cur  = conn.cursor()

# ── 2. Agregar columnas si no existen ─────────────────────────────────────────
def _add_col(table, col, dtype="TEXT"):
    try:
        cur.execute(f"ALTER TABLE {table} ADD COLUMN {col} {dtype}")
        conn.commit()
        print(f"  ✔ {table}.{col} agregada")
    except sqlite3.OperationalError:
        print(f"  · {table}.{col} ya existe")

print("\n── Paso 1/4: columnas nuevas ─────────────────────────────────────────")
_add_col("rules", "business_name", "TEXT")
_add_col("rules", "human_expr",    "TEXT")
_add_col("rules", "expl_negocio",  "TEXT")
_add_col("sps",   "flow_p50_s",    "REAL")
_add_col("sps",   "flow_p95_s",    "REAL")
_add_col("sps",   "flow_p99_s",    "REAL")
_add_col("sps",   "flow_n",        "INTEGER")

# ── 3. Cargar v3 rules y construir índice (sp_full, line) → names ─────────────
print("\n── Paso 2/4: indexar business-rules-v3.json ──────────────────────────")
v3_data = json.loads(V3_JSON.read_text(encoding="utf-8"))
v3_rules = v3_data["rules"]

# Índice: (db:sp, line) → {business_name, human_expr, expl_negocio}
v3_idx: dict[tuple, dict] = {}
for r in v3_rules:
    db  = r.get("db", "") or ""
    sp  = r.get("sp", "") or ""
    line = r.get("line") or 0
    key = (f"{db}:{sp}", line)
    v3_idx[key] = {
        "business_name": r.get("business_name", ""),
        "human_expr":    r.get("human_expr",    ""),
        "expl_negocio":  r.get("expl_negocio",  ""),
    }
print(f"  {len(v3_idx):,} reglas indexadas desde v3.json")

# ── 4. Actualizar rules en brain.db ───────────────────────────────────────────
print("\n── Paso 3/4: sync business_name → rules ─────────────────────────────")
brain_rules = cur.execute("SELECT id, sp, line FROM rules").fetchall()
updated = skipped = 0
for (rid, sp_full, line) in brain_rules:
    key = (sp_full, line)
    v3  = v3_idx.get(key)
    if v3 and v3["business_name"]:
        cur.execute("""
            UPDATE rules
            SET business_name=?, human_expr=?, expl_negocio=?
            WHERE id=?
        """, (v3["business_name"], v3["human_expr"], v3["expl_negocio"], rid))
        updated += 1
    else:
        skipped += 1
conn.commit()

total = len(brain_rules)
print(f"  {updated:,}/{total:,} reglas actualizadas  ({updated/total*100:.1f}%)")
print(f"  {skipped:,} sin match (key no encontrada en v3.json)")

# Muestra 5 ejemplos actualziados
print("\n  Ejemplos de names inferidos:")
for row in cur.execute("""
    SELECT id, tipo, business_name FROM rules
    WHERE business_name IS NOT NULL
    ORDER BY RANDOM() LIMIT 5
""").fetchall():
    print(f"    {row[0]}  [{row[1]}]  {row[2]}")

# ── 5. Sync latencia de flujo → sps ───────────────────────────────────────────
print("\n── Paso 4/4: sync flow_latency → sps ────────────────────────────────")
lat_data = json.loads(LAT_JSON.read_text(encoding="utf-8"))

lat_updated = lat_skipped = 0
for sp_name, metrics in lat_data.items():
    rows = cur.execute(
        "SELECT id FROM sps WHERE name=? LIMIT 1", (sp_name,)
    ).fetchall()
    if not rows:
        lat_skipped += 1
        continue
    cur.execute("""
        UPDATE sps
        SET flow_p50_s=?, flow_p95_s=?, flow_p99_s=?, flow_n=?
        WHERE name=?
    """, (
        metrics.get("p50_s"),
        metrics.get("p95_s"),
        metrics.get("p99_s"),
        metrics.get("count"),
        sp_name
    ))
    lat_updated += 1
conn.commit()

print(f"  {lat_updated}/{len(lat_data)} SPs actualizados con flow latency")
print(f"  {lat_skipped}/{len(lat_data)} SPs no encontrados en brain.db")

# Top 5 SPs lentos con flow latency
print("\n  Top 5 SPs por flow_p95_s:")
for row in cur.execute("""
    SELECT name, flow_p50_s, flow_p95_s, flow_n
    FROM sps WHERE flow_p95_s IS NOT NULL
    ORDER BY flow_p95_s DESC LIMIT 5
""").fetchall():
    print(f"    {row[0]:45s} P50={row[1]}s P95={row[2]}s N={row[3]}")

# ── 6. Inferencia directa para reglas sin match (brain-only SPs) ─────────────
print("\n── Paso 5: inferencia directa para reglas sin match ─────────────────")
unmatched = cur.execute(
    "SELECT id FROM rules WHERE business_name IS NULL"
).fetchall()

if not unmatched:
    print(f"  0 reglas sin match — skip inferencia")
    inf_updated = 0
else:
    import sys as _sys
    _sys.path.insert(0, str(BASE / "generators"))
    import importlib.util as _ilu
    _spec = _ilu.spec_from_file_location("infer_mod", BASE / "generators" / "infer-rule-names.py")
    _mod  = _ilu.module_from_spec(_spec)
    _spec.loader.exec_module(_mod)
    _infer = _mod.infer_name

    unmatched_full = cur.execute(
        "SELECT id, tipo, sp, line, code, reg FROM rules WHERE business_name IS NULL"
    ).fetchall()
    inf_updated = 0
    for (rid, tipo, sp_full, line, code, reg_raw) in unmatched_full:
        try:
            reg = json.loads(reg_raw) if reg_raw else []
        except Exception:
            reg = []
        rule_dict = {
            "tipo": tipo or "", "code": code or "", "vocab_refs": [],
            "explicacion": "", "sp": sp_full.split(":")[-1] if ":" in sp_full else sp_full,
            "bc_name": "", "reg": reg, "db": sp_full.split(":")[0] if ":" in sp_full else "",
        }
        name, _ = _infer(rule_dict)
        if name:
            human = _mod.humanize_expr(code or "")
            expl  = _mod.business_explanation(rule_dict, human)
            cur.execute("UPDATE rules SET business_name=?, human_expr=?, expl_negocio=? WHERE id=?",
                        (name, human, expl, rid))
            inf_updated += 1
    conn.commit()
    print(f"  {inf_updated}/{len(unmatched_full)} reglas inferidas directamente")

# ── 7. Resumen final ──────────────────────────────────────────────────────────
print("\n── Resumen final ─────────────────────────────────────────────────────")
rc = cur.execute("SELECT COUNT(*) FROM rules WHERE business_name IS NOT NULL").fetchone()[0]
rt = cur.execute("SELECT COUNT(*) FROM rules").fetchone()[0]
sc = cur.execute("SELECT COUNT(*) FROM sps WHERE flow_p95_s IS NOT NULL").fetchone()[0]
print(f"  rules con business_name: {rc:,}/{rt:,}  ({rc/rt*100:.1f}%)")
print(f"  sps  con flow latency  : {sc:,}")
print(f"\nSaved: {BRAIN_DB}")
conn.close()
print("sync-brain-v15.py completado.")
