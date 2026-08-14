#!/usr/bin/env python3
"""
build-sp-capabilities.py — Informix SP→Capability Mapping v1.0

Construye la tabla de mapping SP ↔ ETB L3 usando la cadena:
  sps.domain → domain_capabilities.domain_id → etb_l3

Outputs:
  1. brain.db / sp_capabilities (junction table)
  2. brain.db / etb_l3  enriquecida: sp_n, esb_n, soul_n, bcop_cross_sps (JSON key SPs)
  3. portal/data/capability-sp-mapping.json  para el HTML
"""
import sqlite3, json, sys
from collections import defaultdict

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

BCOP = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - SPE/HVM/AM/BanCoppel/Informix")
DB      = f"{BCOP}/digital-brain/brain.db"
OUT_JSON = f"{BCOP}/portal/data/capability-sp-mapping.json"

# Prioridad para SPs representativos por capacidad
ROLE_PRIORITY = {
    'esb_exposed':  0,
    'entry_point':  1,
    'super_orchestrator': 2,
    'orchestrator': 3,
    'cross_domain_primitive': 4,
    'shared_service': 4,
    'implementation': 5,
    'batch_orchestrator': 6,
    'leaf': 7,
    'batch': 8,
}


def role_sort_key(sp):
    role_p = ROLE_PRIORITY.get(sp['role'] or '', 9)
    soul_p = 0 if sp['is_soul'] else 1
    return (soul_p, role_p, -(sp['fan_in'] or 0))


def main():
    conn = sqlite3.connect(DB)
    conn.row_factory = sqlite3.Row
    cur  = conn.cursor()

    # ── 1. Crear tabla sp_capabilities ──────────────────────────────────────
    cur.execute("DROP TABLE IF EXISTS sp_capabilities")
    cur.execute("""
        CREATE TABLE sp_capabilities (
            sp_id        TEXT NOT NULL,
            l3_id        TEXT NOT NULL,
            mapping_type TEXT NOT NULL DEFAULT 'inherited',
            PRIMARY KEY (sp_id, l3_id)
        )
    """)

    # ── 2. Poblar desde la cadena sps → domain_capabilities ─────────────────
    cur.execute("""
        INSERT OR IGNORE INTO sp_capabilities (sp_id, l3_id, mapping_type)
        SELECT s.id, dc.l3_id, dc.mapping_type
        FROM   sps s
        JOIN   domain_capabilities dc ON s.domain = dc.domain_id
        WHERE  s.domain IS NOT NULL AND s.domain != ''
    """)
    n_rows = cur.execute("SELECT COUNT(*) FROM sp_capabilities").fetchone()[0]
    print(f"sp_capabilities: {n_rows:,} filas creadas")

    # ── 3. Agregar columnas a etb_l3 si no existen ──────────────────────────
    existing = {r[1] for r in cur.execute("PRAGMA table_info(etb_l3)").fetchall()}
    for col, typ in [('sp_n','INTEGER'), ('esb_n','INTEGER'), ('soul_n','INTEGER')]:
        if col not in existing:
            cur.execute(f"ALTER TABLE etb_l3 ADD COLUMN {col} {typ} DEFAULT 0")
            print(f"  + columna etb_l3.{col} añadida")

    # ── 4. Calcular stats y SPs representativos por capacidad L3 ────────────
    caps = cur.execute("SELECT id FROM etb_l3").fetchall()
    cap_data = {}

    for (l3_id,) in caps:
        sps = cur.execute("""
            SELECT s.id, s.name, s.biz, s.sp_role, s.is_soul, s.fan_in, s.fan_out,
                   s.prod_calls_day, s.db, sc.mapping_type
            FROM   sp_capabilities sc
            JOIN   sps s ON sc.sp_id = s.id
            WHERE  sc.l3_id = ?
        """, (l3_id,)).fetchall()

        if not sps:
            cap_data[l3_id] = {'sp_n': 0, 'esb_n': 0, 'soul_n': 0, 'key_sps': []}
            continue

        sp_n   = len(sps)
        esb_n  = sum(1 for s in sps if s['sp_role'] == 'esb_exposed')
        soul_n = sum(1 for s in sps if s['is_soul'])

        # SPs representativos — ordenados por prioridad de rol + alma
        sorted_sps = sorted([{
            'id':       s['id'],
            'name':     s['name'],
            'biz':      s['biz'] or '',
            'role':     s['sp_role'] or '',
            'is_soul':  bool(s['is_soul']),
            'fan_in':   s['fan_in'] or 0,
            'fan_out':  s['fan_out'] or 0,
            'prod_calls': s['prod_calls_day'],
            'db':        s['db'] or '',
            'mapping':   s['mapping_type'],
        } for s in sps], key=role_sort_key)

        # Top 10: primero expuestos, luego almas, luego por fan_in
        key_sps = sorted_sps[:10]

        cap_data[l3_id] = {
            'sp_n':    sp_n,
            'esb_n':   esb_n,
            'soul_n':  soul_n,
            'key_sps': key_sps,
        }

        # Actualizar etb_l3
        cur.execute("""
            UPDATE etb_l3 SET sp_n=?, esb_n=?, soul_n=?, bcop_cross_sps=?
            WHERE id=?
        """, (sp_n, esb_n, soul_n,
              json.dumps([s['id'] for s in key_sps], ensure_ascii=False),
              l3_id))

    conn.commit()
    print("etb_l3 actualizada con sp_n / esb_n / soul_n / bcop_cross_sps")

    # ── 5. Generar JSON para el HTML ─────────────────────────────────────────
    # Incluir metadata de cada L3 para el panel de detalle
    l3_meta = {r['id']: dict(r) for r in
               cur.execute("SELECT * FROM etb_l3").fetchall()}

    output = {}
    for l3_id, data in cap_data.items():
        meta = l3_meta.get(l3_id, {})
        output[l3_id] = {
            'name':       meta.get('name', ''),
            'definition': meta.get('definition', ''),
            'bcop_status': meta.get('bcop_status', 'NOT_COVERED'),
            'sp_n':    data['sp_n'],
            'esb_n':   data['esb_n'],
            'soul_n':  data['soul_n'],
            'key_sps': data['key_sps'],
        }

    # ── 5b. domain_l3_map: domain → sorted list of L3 capabilities ──────────
    domain_l3_map = {}
    for row in cur.execute("""
        SELECT dc.domain_id, dc.l3_id, dc.mapping_type, c.name, c.sp_n, c.esb_n, c.soul_n
        FROM   domain_capabilities dc
        JOIN   etb_l3 c ON dc.l3_id = c.id
        ORDER  BY dc.domain_id, dc.l3_id
    """).fetchall():
        d = row[0]
        if d not in domain_l3_map:
            domain_l3_map[d] = []
        domain_l3_map[d].append({
            'l3_id':   row[1],
            'mapping': row[2],
            'name':    row[3],
            'sp_n':    row[4] or 0,
            'esb_n':   row[5] or 0,
            'soul_n':  row[6] or 0,
            'key_sps': output.get(row[1], {}).get('key_sps', []),
        })

    final_output = {'capabilities': output, 'domain_l3_map': domain_l3_map}

    import pathlib
    pathlib.Path(OUT_JSON).parent.mkdir(parents=True, exist_ok=True)
    with open(OUT_JSON, 'w', encoding='utf-8') as f:
        json.dump(final_output, f, ensure_ascii=False, indent=2)
    print(f"JSON exportado → {OUT_JSON}")

    # ── 6. Resumen ───────────────────────────────────────────────────────────
    covered = sum(1 for d in output.values() if d['sp_n'] > 0)
    total_l3 = len(output)
    print(f"\n=== Resumen ===")
    print(f"  L3 capabilities totales   : {total_l3}")
    print(f"  Con SPs mapeados          : {covered}  ({covered/total_l3*100:.0f}%)")
    print(f"  Sin SPs (NOT_COVERED)     : {total_l3 - covered}")
    print(f"\n  Top 15 capacidades por SP count:")
    top = sorted(output.items(), key=lambda x: -x[1]['sp_n'])[:15]
    for lid, d in top:
        print(f"    {lid:<10} {d['name']:<45} {d['sp_n']:>5} SPs  esb={d['esb_n']}  souls={d['soul_n']}")

    conn.close()


if __name__ == '__main__':
    main()
