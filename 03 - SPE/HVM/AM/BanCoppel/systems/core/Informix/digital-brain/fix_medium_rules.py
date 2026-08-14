"""
fix_medium_rules.py — Corrige 17 reglas MEDIUM con descriptores en español
Swarm enriquecimiento semántico BanCoppel Informix SPL
2026-08-13
"""
import sqlite3
import json
from pathlib import Path

BASE = Path(r'C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core\03 - SPE\HVM\AM\BanCoppel\systems\core\Informix')
DB_PATH = BASE / 'digital-brain' / 'brain.db'
JSON_PATH = BASE / 'portal' / 'data' / 'rules-coherence.json'

# ── Corrections map: rule_id → new business_name ────────────────────────────
# Source-validated: each new name uses only tokens present in the SPL code.
CORRECTIONS = {
    # CÓDIGO_RETORNO / RETORNO_CÓDIGO ─────────────────────────────────────────
    # 1. bdicheq:sp_edoctaencabezado L397 — ELSE of IF iExisteCuenta > 0
    'BR-V2-1445': '[100]: ELSE iExisteCuenta <= 0 — vcodret = "100"',

    # 2. bdibei:sp_constotmovschq_bei L280 — ELSE of IF pFechaInicial = vFechaHoy AND pFechaFinal = vFechaHoy
    'BR-V2-0249': '[100]: ELSE pFechaInicial <> vFechaHoy OR pFechaFinal <> vFechaHoy',

    # 3. bdibei:sp_consultmovschq_bei L612 — same outer IF
    'BR-V2-0252': '[100]: ELSE pFechaInicial <> vFechaHoy OR pFechaFinal <> vFechaHoy',

    # 4. bdicheq:sp_edoctamovtos_central L273 — LET cCodRet post END FOREACH
    'BR-V2-1454': "[100]: cCodRet END FOREACH — cProducto <> '1600'",

    # 5. bdicont:cancela_resultados L103 — LET codret = "99999" initial default
    'BR-V2-3365': 'codret 99999 — v_begin = "N" LET BEGIN',

    # 6. bdicont:reoaux L86 — LET codret = "100" initial default
    'BR-V2-3381': 'codret 100 — BEGIN on exception sql_err isam_err',

    # 7. bdicont:reosec L85 — same
    'BR-V2-3383': 'codret 100 — BEGIN on exception sql_err isam_err',

    # 8. bdicont:reosuc L86 — same
    'BR-V2-3385': 'codret 100 — BEGIN on exception sql_err isam_err',

    # 9. bdicorresp:cons_pago_minimo_no_interes_pba L145 — ON EXCEPTION sql_err <> 0
    'BR-V2-3417': 'vcodret 999 — ON EXCEPTION sql_err <> 0',

    # 10. bditrans:certi_chq L150 — IF v_com_fija_mn IS NULL
    'BR-V2-7269': 'codret 102 — IF v_com_fija_mn IS NULL',

    # 11. bditrans:ordpago L286 — IF v_preve IS NULL
    'BR-V2-7335': 'o_codret 105 — IF v_preve IS NULL',

    # 12. bdiauditor:sp_pld_chq_crg_xml L340 — ELSE tblpld_chqc_crg count = 0
    'BR-V2-0231': 'RETURN 0000002 — tblpld_chqc_crg periodo pperiodo count = 0 vpaso 5',

    # 13. bditarjeta:sp_con_buscararchivo L38 — IF p_Ruta = "" OR p_Ruta IS NULL
    'BR-V2-7149': 'RETURN 00450 NULL — IF p_Ruta = "" OR p_Ruta IS NULL',

    # 14. bdicheq:consasigtarjeta L58 — ELSE NVL(vCantReg,0) <= 0
    'BR-V2-0800': '[262]: ELSE NVL(vCantReg,0) <= 0 — vCodRet = "262"',

    # 15. bdicheq:sp_dispersionnominavalidacionestatus L76 — cEstatusCuenta IN check
    'BR-V2-1403': "[815]: cEstatusCuenta IN('2','6','7','8') — vcodret = \"815\"",

    # CONTROL_FLUJO / CÁLCULO_ARITMÉTICO ─────────────────────────────────────
    # 16. bdicheq:entre_chq L171 — IF estatus IN ("si" is Spanish)
    'BR-V2-0880': 'estatus IN("2","6","7","8") — cod_ret = "200"',

    # 17. bdibei:sp_soe_consulta_solicitud_numsol L101 — iCostoIVA = iConsto * 1.16
    'BR-V2-0283': 'iCostoIVA = iConsto * 1.16',
}

conn = sqlite3.connect(str(DB_PATH))
cur = conn.cursor()

# Check FTS triggers exist (to decide manual FTS sync)
cur.execute("SELECT name FROM sqlite_master WHERE type='trigger' AND tbl_name='rules'")
triggers = [r[0] for r in cur.fetchall()]
print(f"rules triggers: {triggers}")

updated = 0
failed = []
log = []

for rule_id, new_name in CORRECTIONS.items():
    # Fetch old name
    cur.execute("SELECT business_name FROM rules WHERE id = ?", (rule_id,))
    row = cur.fetchone()
    if not row:
        print(f"  WARNING: rule {rule_id} NOT FOUND in DB")
        failed.append(rule_id)
        continue

    old_name = row[0]

    # UPDATE rules table
    cur.execute("UPDATE rules SET business_name = ? WHERE id = ?", (new_name, rule_id))

    # UPDATE rules_fts (the FTS virtual table may need explicit update)
    try:
        cur.execute("UPDATE rules_fts SET business_name = ? WHERE id = ?", (new_name, rule_id))
    except Exception as e:
        print(f"  FTS update skipped for {rule_id}: {e}")

    updated += 1
    log.append({
        'id': rule_id,
        'old': old_name,
        'new': new_name,
    })
    print(f"  OK {rule_id}: {old_name[:60]} → {new_name[:60]}")

conn.commit()
conn.close()

print(f"\n=== DONE: {updated} updated, {len(failed)} not found ===")

# ── Update rules-coherence.json ──────────────────────────────────────────────
print("\nUpdating rules-coherence.json...")
with open(str(JSON_PATH), encoding='utf-8') as f:
    coherence = json.load(f)

# Build lookup by (sp, db, line, sub_tipo) → rule in JSON
id_to_meta = {}
for r in CORRECTIONS:
    id_to_meta[r] = CORRECTIONS[r]

# We need to match JSON rules to IDs
# Load all the matched rules
with sqlite3.connect(str(DB_PATH)) as conn2:
    cur2 = conn2.cursor()
    cur2.execute("SELECT id, sp, db, line, sub_tipo FROM rules WHERE id IN (%s)" %
                 ','.join('?' * len(CORRECTIONS)), list(CORRECTIONS.keys()))
    db_rows = {r[0]: (r[1], r[2], r[3], r[4]) for r in cur2.fetchall()}

# For each medium_rule in JSON, if (sp, db, line, sub_tipo) matches a correction, update
json_updated = 0
for rule in coherence.get('medium_rules', []):
    sp = rule.get('sp', '')
    db = rule.get('db', '')
    line = rule.get('line', 0)
    sub = rule.get('sub_tipo', '')
    for rid, (dsp, ddb, dline, dsub) in db_rows.items():
        if sp == dsp and db == ddb and line == dline and sub == dsub:
            if rule['business_name'] != CORRECTIONS[rid]:
                rule['business_name'] = CORRECTIONS[rid]
                json_updated += 1
            break

for rule in coherence.get('low_rules', []):
    sp = rule.get('sp', '')
    db = rule.get('db', '')
    line = rule.get('line', 0)
    sub = rule.get('sub_tipo', '')
    for rid, (dsp, ddb, dline, dsub) in db_rows.items():
        if sp == dsp and db == ddb and line == dline and sub == dsub:
            if rule['business_name'] != CORRECTIONS[rid]:
                rule['business_name'] = CORRECTIONS[rid]
                json_updated += 1
            break

with open(str(JSON_PATH), 'w', encoding='utf-8') as f:
    json.dump(coherence, f, ensure_ascii=False, indent=2)

print(f"JSON updated: {json_updated} entries")
print("\n=== Log summary ===")
for entry in log:
    print(f"{entry['id']}")
    print(f"  OLD: {entry['old']}")
    print(f"  NEW: {entry['new']}")
    print()
