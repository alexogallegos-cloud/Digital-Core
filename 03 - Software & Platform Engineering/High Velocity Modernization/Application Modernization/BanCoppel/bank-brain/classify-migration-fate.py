"""
classify-migration-fate.py — Clasifica el destino físico de cada SP legacy en Unity.

Agrega migration_fate + fate_confidence a la tabla migrations de bank-brain.db.
No toca brain.db (legacy inmutable).

Fates:
  absorbed    — el sistema COTS destino (Temenos/SmartVista) o la capa MuleSoft
                cubre la función nativamente. El SP desaparece.
  replicate   — el SP tiene lógica de negocio propia de BanCoppel que el COTS
                no trae. Debe re-implementarse (TAFJ/OFS para Transact,
                Java para Apolo, customización BPC para SmartVista).
  complement  — la funcionalidad se mueve a un microservicio/API que opera
                junto al sistema destino (ej. reportería regulatoria CNBV,
                GL contable transversal, capa de integración MuleSoft con lógica).
  retire      — dead code, infraestructura interna o funcionalidad que
                desaparece sin reemplazo (backups DBA, wrappers sin lógica
                en sistemas que se dan de baja).
  unknown     — dominio sin clasificar aún.

Confidence:
  high   — criterio determinístico (decommission, rule_count muy alto)
  medium — criterio heurístico robusto
  low    — heurístico débil, requiere revisión de código
"""

import sqlite3, sys
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

DB = Path(__file__).parent / "bank-brain.db"
assert DB.exists(), "Ejecuta build-bank-brain.py primero"

db = sqlite3.connect(str(DB))
db.execute("PRAGMA foreign_keys=ON")

# ── 1. DDL — agregar columnas si no existen ────────────────────────────────
for col, dflt in [("migration_fate", "unknown"), ("fate_confidence", "low")]:
    try:
        db.execute(f"ALTER TABLE migrations ADD COLUMN {col} TEXT DEFAULT '{dflt}'")
        print(f"Columna {col} agregada")
    except Exception:
        print(f"Columna {col} ya existe")
db.commit()

# ── 2. Lógica de clasificación ─────────────────────────────────────────────

def classify(target_sys: str, domain_id: str, rule_count: int) -> tuple[str, str]:
    """Retorna (migration_fate, fate_confidence)."""
    rc = rule_count or 0

    # Decommission: siempre retire, sin importar reglas
    if target_sys == "decommission" or domain_id == "D34":
        return "retire", "high"

    # Unknown domain: no clasificable aún
    if target_sys == "unknown":
        return "unknown", "low"

    # ── COTS: Transact (Temenos) ──────────────────────────────────────────
    # Temenos cubre cuentas, pagos, crédito empresarial, sucursales nativamente.
    # Lógica personalizada de BanCoppel necesita re-implementación (TAFJ/OFS routines).
    if target_sys == "transact":
        if rc == 0:
            return "absorbed", "low"        # asume COTS cubre; verificar código
        if rc <= 5:
            return "absorbed", "low"        # mínima lógica, probablemente configuración COTS
        if rc <= 15:
            return "replicate", "medium"    # lógica BanCoppel propia → customización Temenos
        return "replicate", "high"          # lógica compleja BanCoppel → sí o sí custom

    # ── COTS: SmartVista / BPC ────────────────────────────────────────────
    # BPC cubre emisión, autorización, liquidación, recompensas nativamente.
    # Rechazos específicos BanCoppel, reglas de negocio → replicate en BPC.
    if target_sys == "smartvista":
        if rc == 0:
            return "absorbed", "low"
        if rc <= 5:
            return "absorbed", "low"
        if rc <= 15:
            return "replicate", "medium"
        return "replicate", "high"

    # ── Custom: Apolo (Java microservicios) ───────────────────────────────
    # Apolo se construye desde cero. Todo el código SPL es la spec del microservicio.
    # rule_count=0: SP sin lógica extraída → re-implementación mínima (thin layer).
    # rule_count>0: lógica real → re-implementación con complejidad proporcional.
    if target_sys == "apolo":
        if rc == 0:
            return "replicate", "low"       # re-implementar como thin layer Java
        if rc <= 5:
            return "replicate", "medium"
        if rc <= 15:
            return "replicate", "medium"
        return "replicate", "high"          # SPs complejos (ej. generaestadosdecuenta)

    # ── Middleware: MuleSoft / API Gateway ────────────────────────────────
    # MuleSoft maneja routing y orquestación nativamente.
    # Lógica de negocio en SPs de D01/D02 → complement como policy/transformation MuleSoft.
    if target_sys == "multi":
        if rc == 0:
            return "absorbed", "low"        # routing puro, MuleSoft lo maneja
        if rc <= 5:
            return "complement", "low"      # lógica mínima → policy MuleSoft
        return "complement", "medium"       # lógica significativa → DataWeave / custom policy

    # ── Shared services: cross (GL, PLD, CNBV, conciliación) ─────────────
    # No tiene un sistema COTS destino claro → se convierte en microservicio compartido.
    # GL contable, PLD/LIDE compliance, reportería CNBV → APIs transversales.
    if target_sys == "cross":
        if rc == 0:
            return "complement", "low"
        return "complement", "medium"

    # Fallback
    return "unknown", "low"


# ── 3. Aplicar clasificación ───────────────────────────────────────────────
rows = db.execute(
    "SELECT sp, db, target_sys, domain_id, rule_count FROM migrations"
).fetchall()

updates = []
for sp, dbname, target_sys, domain_id, rule_count in rows:
    fate, confidence = classify(target_sys, domain_id, rule_count)
    updates.append((fate, confidence, sp, dbname))

db.executemany(
    "UPDATE migrations SET migration_fate=?, fate_confidence=? WHERE sp=? AND db=?",
    updates
)
db.commit()
print(f"\nClasificados: {len(updates):,} SPs")

# ── 4. Resumen ─────────────────────────────────────────────────────────────
print("\n=== Resumen de migration_fate ===\n")

# Global
print("── Global ──────────────────────────────────────────────")
for fate, cnt, rules in db.execute("""
    SELECT migration_fate, COUNT(*) n, SUM(rule_count) r
    FROM migrations
    GROUP BY migration_fate
    ORDER BY n DESC
"""):
    pct = cnt / len(updates) * 100
    print(f"  {fate:<12}: {cnt:>6,} SPs  {rules or 0:>6,} reglas  ({pct:.1f}%)")

# Por target_sys
TARGETS = ['transact', 'smartvista', 'apolo', 'cross', 'multi', 'decommission']
for target in TARGETS:
    rows_t = db.execute("""
        SELECT migration_fate, COUNT(*) n, SUM(rule_count) r
        FROM migrations
        WHERE target_sys = ?
        GROUP BY migration_fate
        ORDER BY n DESC
    """, (target,)).fetchall()
    if not rows_t:
        continue
    total_t = sum(r[1] for r in rows_t)
    print(f"\n── {target.upper()} ({total_t:,} SPs) ──────────────────────────")
    for fate, cnt, rules in rows_t:
        pct = cnt / total_t * 100
        bar = "█" * int(pct / 5)
        print(f"  {fate:<12}: {cnt:>5,} SPs  {rules or 0:>6,} reglas  {pct:>5.1f}%  {bar}")

# SPs de alta complejidad por replicate
print("\n── Top 15 SPs críticos (replicate, mayor rule_count) ──────")
for sp, dbname, target, dom, rc, conf in db.execute("""
    SELECT sp, db, target_sys, domain_id, rule_count, fate_confidence
    FROM migrations
    WHERE migration_fate = 'replicate'
    ORDER BY rule_count DESC
    LIMIT 15
"""):
    print(f"  {sp:<40} [{target:<10}] dom={dom}  rules={rc:>4}  conf={conf}")

print("\nclassify-migration-fate.py completado.")
