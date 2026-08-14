"""
classify-migration-fate.py â€” Clasifica el destino fÃ­sico de cada SP legacy en Unity.

Agrega migration_fate + fate_confidence a la tabla migrations de bank-brain.db.
No toca brain.db (legacy inmutable).

Fates:
  absorbed    â€” el sistema COTS destino (Temenos/SmartVista) o la capa MuleSoft
                cubre la funciÃ³n nativamente. El SP desaparece.
  replicate   â€” el SP tiene lÃ³gica de negocio propia de BanCoppel que el COTS
                no trae. Debe re-implementarse (TAFJ/OFS para Transact,
                Java para Apolo, customizaciÃ³n BPC para SmartVista).
  complement  â€” la funcionalidad se mueve a un microservicio/API que opera
                junto al sistema destino (ej. reporterÃ­a regulatoria CNBV,
                GL contable transversal, capa de integraciÃ³n MuleSoft con lÃ³gica).
  retire      â€” dead code, infraestructura interna o funcionalidad que
                desaparece sin reemplazo (backups DBA, wrappers sin lÃ³gica
                en sistemas que se dan de baja).
  unknown     â€” dominio sin clasificar aÃºn.

Confidence:
  high   â€” criterio determinÃ­stico (decommission, rule_count muy alto)
  medium â€” criterio heurÃ­stico robusto
  low    â€” heurÃ­stico dÃ©bil, requiere revisiÃ³n de cÃ³digo
"""

import sqlite3, sys
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

DB = Path(__file__).parent.parent / "digital-brain" / "bank-brain.db"
assert DB.exists(), "Ejecuta build-bank-brain.py primero"

db = sqlite3.connect(str(DB))
db.execute("PRAGMA foreign_keys=ON")

# â”€â”€ 1. DDL â€” agregar columnas si no existen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
for col, dflt in [("migration_fate", "unknown"), ("fate_confidence", "low")]:
    try:
        db.execute(f"ALTER TABLE migrations ADD COLUMN {col} TEXT DEFAULT '{dflt}'")
        print(f"Columna {col} agregada")
    except Exception:
        print(f"Columna {col} ya existe")
db.commit()

# â”€â”€ 2. LÃ³gica de clasificaciÃ³n â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

def classify(target_sys: str, domain_id: str, rule_count: int) -> tuple[str, str]:
    """Retorna (migration_fate, fate_confidence)."""
    rc = rule_count or 0

    # Decommission: siempre retire, sin importar reglas
    if target_sys == "decommission" or domain_id == "D34":
        return "retire", "high"

    # Unknown domain: no clasificable aÃºn
    if target_sys == "unknown":
        return "unknown", "low"

    # â”€â”€ COTS: Transact (Temenos) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # Temenos cubre cuentas, pagos, crÃ©dito empresarial, sucursales nativamente.
    # LÃ³gica personalizada de BanCoppel necesita re-implementaciÃ³n (TAFJ/OFS routines).
    if target_sys == "transact":
        if rc == 0:
            return "absorbed", "low"        # asume COTS cubre; verificar cÃ³digo
        if rc <= 5:
            return "absorbed", "low"        # mÃ­nima lÃ³gica, probablemente configuraciÃ³n COTS
        if rc <= 15:
            return "replicate", "medium"    # lÃ³gica BanCoppel propia â†’ customizaciÃ³n Temenos
        return "replicate", "high"          # lÃ³gica compleja BanCoppel â†’ sÃ­ o sÃ­ custom

    # â”€â”€ COTS: SmartVista / BPC â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # BPC cubre emisiÃ³n, autorizaciÃ³n, liquidaciÃ³n, recompensas nativamente.
    # Rechazos especÃ­ficos BanCoppel, reglas de negocio â†’ replicate en BPC.
    if target_sys == "smartvista":
        if rc == 0:
            return "absorbed", "low"
        if rc <= 5:
            return "absorbed", "low"
        if rc <= 15:
            return "replicate", "medium"
        return "replicate", "high"

    # â”€â”€ Custom: Apolo (Java microservicios) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # Apolo se construye desde cero. Todo el cÃ³digo SPL es la spec del microservicio.
    # rule_count=0: SP sin lÃ³gica extraÃ­da â†’ re-implementaciÃ³n mÃ­nima (thin layer).
    # rule_count>0: lÃ³gica real â†’ re-implementaciÃ³n con complejidad proporcional.
    if target_sys == "apolo":
        if rc == 0:
            return "replicate", "low"       # re-implementar como thin layer Java
        if rc <= 5:
            return "replicate", "medium"
        if rc <= 15:
            return "replicate", "medium"
        return "replicate", "high"          # SPs complejos (ej. generaestadosdecuenta)

    # â”€â”€ Middleware: MuleSoft / API Gateway â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # MuleSoft maneja routing y orquestaciÃ³n nativamente.
    # LÃ³gica de negocio en SPs de D01/D02 â†’ complement como policy/transformation MuleSoft.
    if target_sys == "multi":
        if rc == 0:
            return "absorbed", "low"        # routing puro, MuleSoft lo maneja
        if rc <= 5:
            return "complement", "low"      # lÃ³gica mÃ­nima â†’ policy MuleSoft
        return "complement", "medium"       # lÃ³gica significativa â†’ DataWeave / custom policy

    # â”€â”€ Shared services: cross (GL, PLD, CNBV, conciliaciÃ³n) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    # No tiene un sistema COTS destino claro â†’ se convierte en microservicio compartido.
    # GL contable, PLD/LIDE compliance, reporterÃ­a CNBV â†’ APIs transversales.
    if target_sys == "cross":
        if rc == 0:
            return "complement", "low"
        return "complement", "medium"

    # Fallback
    return "unknown", "low"


# â”€â”€ 3. Aplicar clasificaciÃ³n â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

# â”€â”€ 4. Resumen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
print("\n=== Resumen de migration_fate ===\n")

# Global
print("â”€â”€ Global â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€")
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
    print(f"\nâ”€â”€ {target.upper()} ({total_t:,} SPs) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€")
    for fate, cnt, rules in rows_t:
        pct = cnt / total_t * 100
        bar = "â–ˆ" * int(pct / 5)
        print(f"  {fate:<12}: {cnt:>5,} SPs  {rules or 0:>6,} reglas  {pct:>5.1f}%  {bar}")

# SPs de alta complejidad por replicate
print("\nâ”€â”€ Top 15 SPs crÃ­ticos (replicate, mayor rule_count) â”€â”€â”€â”€â”€â”€")
for sp, dbname, target, dom, rc, conf in db.execute("""
    SELECT sp, db, target_sys, domain_id, rule_count, fate_confidence
    FROM migrations
    WHERE migration_fate = 'replicate'
    ORDER BY rule_count DESC
    LIMIT 15
"""):
    print(f"  {sp:<40} [{target:<10}] dom={dom}  rules={rc:>4}  conf={conf}")

print("\nclassify-migration-fate.py completado.")
