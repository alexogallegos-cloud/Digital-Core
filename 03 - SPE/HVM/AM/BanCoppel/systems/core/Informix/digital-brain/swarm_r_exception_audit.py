"""
swarm_r_exception_audit.py — Swarm R: Auditoría de excepciones y corrección de P7 falsos positivos.

Tres problemas a corregir:

  R1 — P7 falsos positivos (108 reglas con placeholder "[descripción pendiente]"):
       El regex de P7 usaba re.I haciendo que "Aplicado / forzado" o "importe x tasa IVA / 100"
       se detectaran como fórmulas camelCase. Se restaura el old_value desde rule_enrichment_log
       y se clasifica:
       - Si old_value contenía variables camelCase reales (iVar, mMonto): es fórmula real → usar subject
       - Si NO tenía camelCase: falso positivo → restaurar old_value

  R2 — Excepciones con mensaje específico en RAISE EXCEPTION (742 reglas con P3 genérico):
       "error de sistema o excepción no controlada" es correcto para ON EXCEPTION handlers.
       Pero si el code tiene RAISE EXCEPTION ..., ..., 'mensaje', ese mensaje ES la condición
       de negocio y debe usarse en el business_name.
       Regla: siempre ir al código y establecer la condición real que arroja la excepción.

  R3 — Corrección manual BR-V2-7160:
       "Aplicado / forzado" → "Clasificación de estado DevPos: aplicado si el monto
       coincide con Intercard, forzado si difiere" (code: DECODE+APLICADO/FORZADO validado)
"""

import sqlite3, re, sys
from pathlib import Path
from datetime import datetime

sys.stdout.reconfigure(encoding='utf-8', errors='replace')

DB  = Path(r"C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core\03 - SPE\HVM\AM\BanCoppel\systems\core\Informix\digital-brain\brain.db")
con = sqlite3.connect(str(DB))
cur = con.cursor()
NOW = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

updates  = []
log_rows = []
PATCHED  = set()
counts   = {'R1_restored': 0, 'R1_subject_only': 0, 'R2_raise_msg': 0, 'R3_manual': 0}

def register(rule_id, old_bn, new_bn, conf, method, note=''):
    if rule_id in PATCHED: return False
    new_bn = re.sub(r'\s+', ' ', new_bn).strip()
    if new_bn == old_bn or not new_bn: return False
    PATCHED.add(rule_id)
    updates.append((new_bn, rule_id))
    log_rows.append((rule_id, 'swarm_r', 'business_name',
                     old_bn, new_bn, NOW, 0.90, method, note))
    return True

# Detector de variables camelCase reales (minúscula + mayúscula: iMonto, mTasa, pParam)
REAL_CAMEL = re.compile(r'\b[a-z][A-Z][a-zA-Z0-9_]{2,}')

# Extractor de mensaje de RAISE EXCEPTION
RAISE_PAT = re.compile(
    r"RAISE\s+EXCEPTION\s+\w+\s*,\s*\d+\s*,\s*'([^']{5,})'",
    re.I
)

# ─────────────────────────────────────────────────────────────────────────────
# R3 — Corrección manual BR-V2-7160 (validado desde código fuente)
# ─────────────────────────────────────────────────────────────────────────────
cur.execute("SELECT business_name FROM rules WHERE id='BR-V2-7160'")
row = cur.fetchone()
if row:
    new_bn_7160 = 'Clasificación de estado DevPos: aplicado si el monto coincide con Intercard, forzado si difiere'
    if register('BR-V2-7160', row[0], new_bn_7160, 0.95, 'manual_source_verification',
                'DECODE(psMonto325/100, pmMontoIntercard, A=APLICADO, F=FORZADO) validado línea 111'):
        counts['R3_manual'] += 1
        print(f"R3 BR-V2-7160: {(row[0] or '')[:60]} → {new_bn_7160[:60]}")

# ─────────────────────────────────────────────────────────────────────────────
# R1 — Restaurar/mejorar los 108 placeholders de P7
# ─────────────────────────────────────────────────────────────────────────────
cur.execute("""
    SELECT DISTINCT l.rule_id, l.old_value, r.business_name, r.sp, r.db
    FROM rule_enrichment_log l
    JOIN rules r ON r.id = l.rule_id
    WHERE l.method = 'formula_removal'
      AND r.business_name LIKE '%pendiente%columna code%'
    ORDER BY l.rule_id
""")
placeholder_rows = cur.fetchall()
print(f"\n[R1] Placeholders a corregir: {len(placeholder_rows)}")

for rule_id, old_value, current_bn, sp, db in placeholder_rows:
    if not old_value or rule_id in PATCHED:
        continue

    # ¿El old_value tenía camelCase real?
    has_camel = bool(REAL_CAMEL.search(old_value or ''))

    colon = old_value.find(':')
    subject   = old_value[:colon].strip() if colon >= 0 else old_value.strip()
    condition = old_value[colon+1:].strip() if colon >= 0 else ''

    if has_camel:
        # Era fórmula real: usar solo el sujeto como nombre descriptivo
        # El sujeto ya describe el concepto (ej: "IVA sobre comisión de convenio")
        new_bn = subject
        if new_bn and new_bn[0].islower():
            new_bn = new_bn[0].upper() + new_bn[1:]
        if register(rule_id, current_bn, new_bn, 0.75, 'p7_placeholder_subject_only',
                    f'camelCase detectado en old_value; se usa subject="{subject}"'):
            counts['R1_subject_only'] += 1
    else:
        # Falso positivo: restaurar old_value (el "/" no era operador camelCase)
        # Capitalizar condición si está en minúscula
        if colon >= 0 and condition and condition[0].islower():
            condition = condition[0].upper() + condition[1:]
            new_bn = f"{subject}: {condition}" if condition else subject
        else:
            new_bn = old_value.strip()
        if new_bn and new_bn[0].islower():
            new_bn = new_bn[0].upper() + new_bn[1:]
        if register(rule_id, current_bn, new_bn, 0.92, 'p7_false_positive_restore',
                    f'sin camelCase en old_value; restaurado como falso positivo de P7'):
            counts['R1_restored'] += 1
            print(f"R1 RESTORE {rule_id}: {(old_value or '')[:60]} → {new_bn[:60]}")

print(f"R1: {counts['R1_restored']} restaurados, {counts['R1_subject_only']} a subject-only")

# ─────────────────────────────────────────────────────────────────────────────
# R2 — RAISE EXCEPTION con mensaje específico → usar mensaje como condición de negocio
# ─────────────────────────────────────────────────────────────────────────────
cur.execute("""
    SELECT id, business_name, code, sp, db
    FROM rules
    WHERE business_name LIKE '%error de sistema o excepci%'
      AND code LIKE '%RAISE EXCEPTION%'
    ORDER BY id
""")
raise_rows = cur.fetchall()
print(f"\n[R2] Reglas candidatas RAISE EXCEPTION: {len(raise_rows)}")

for rule_id, bn, code, sp, db in raise_rows:
    if not code or rule_id in PATCHED:
        continue

    m = RAISE_PAT.search(code)
    if not m:
        continue

    msg = m.group(1).strip()
    # Limpiar: quitar prefijos técnicos "ERROR EN LA EJECUCION DEL SP " → más legible
    msg_clean = re.sub(r'^ERROR\s+EN\s+LA\s+EJECUCION\s+DEL\s+SP\s+', 'error al ejecutar ', msg, flags=re.I)
    msg_clean = re.sub(r'^ERROR:\s*', '', msg_clean, flags=re.I).strip()
    msg_clean = re.sub(r'^ERR:\s*', '', msg_clean, flags=re.I).strip()
    msg_clean = re.sub(r'\s+', ' ', msg_clean).strip()
    if not msg_clean or len(msg_clean) < 5:
        continue

    # Capitalizar
    msg_clean = msg_clean[0].upper() + msg_clean[1:]

    # Construir nuevo business_name
    colon = bn.find(': error de sistema')
    subject = bn[:colon].strip() if colon >= 0 else bn.replace(' — error de sistema o excepción no controlada', '').strip()
    new_bn = f"{subject}: {msg_clean}" if subject else msg_clean

    if register(rule_id, bn, new_bn, 0.88, 'raise_exception_msg_extraction',
                f'RAISE EXCEPTION message extraído: "{msg[:60]}"'):
        counts['R2_raise_msg'] += 1
        if counts['R2_raise_msg'] <= 20:  # Solo imprimir los primeros 20
            print(f"R2 {rule_id}: {bn[:60]}")
            print(f"   → {new_bn[:60]}")

if counts['R2_raise_msg'] > 20:
    print(f"   ... y {counts['R2_raise_msg'] - 20} más")

# ─────────────────────────────────────────────────────────────────────────────
# Aplicar
# ─────────────────────────────────────────────────────────────────────────────
total = sum(counts.values())
print(f"\n{'='*60}")
print(f"Total actualizaciones: {total}")
for k, v in counts.items():
    if v: print(f"  {k}: {v}")

if updates:
    cur.executemany("UPDATE rules SET business_name=? WHERE id=?", updates)
    cur.executemany("""
        INSERT INTO rule_enrichment_log
          (rule_id, swarm, field, old_value, new_value, timestamp, confidence, method, notes)
        VALUES (?,?,?,?,?,?,?,?,?)
    """, log_rows)
    try:
        cur.execute("INSERT INTO rules_fts(rules_fts) VALUES('rebuild')")
    except Exception:
        pass
    con.commit()
    print("\n✓ brain.db actualizado")
else:
    print("\nNada que actualizar.")

con.close()
print("\nPipeline canónico:")
print("  1. python digital-brain/rebuild_from_brain.py")
print("  2. python generators/build-rules-coherence.py")
