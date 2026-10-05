#!/usr/bin/env python3
"""
Liverpool — Cobertura ETB: ancla cada capacidad L3 a su eslabón de cadena de valor
y consolida la cobertura aplicación · capacidad · proceso.

Determinístico (este script):
  · rtb_l3.vc_id      — eslabón de cadena de valor (VC-01..VC-09) por grupo L1
  · rtb_l3.domain_id  — dominio retail R01-R10 heredado del eslabón
  · retail_domains.rtb_coverage y value_chain.cap_count recalculados
  · cap_coverage      — vista materializada: capacidad × sistema × tickets

Semántico (no lo hace este script): rtb_l3.primary_system y components.rtb_capabilities
se pueblan con el swarm de mapeo — ver load-capability-mapping.py.

Re-ejecutable. Correr después de load-sud-to-brain.py y load-tickets-to-brain.py.
"""
import json, sqlite3
from pathlib import Path

HERE  = Path(__file__).parent
BRAIN = HERE.parent
DB    = BRAIN / "liverpool-brain.db"


def ensure_column(c, table, col, decl):
    cols = [r[1] for r in c.execute(f"PRAGMA table_info({table})")]
    if col not in cols:
        c.execute(f"ALTER TABLE {table} ADD COLUMN {col} {decl}")


def main():
    conn = sqlite3.connect(DB)
    c = conn.cursor()

    ensure_column(c, "rtb_l3", "vc_id", "TEXT")

    # ── eslabón de cadena de valor por prefijo de grupo L1 ────────────────
    # value_chain.rtl_groups declara qué grupos ETB alimentan cada eslabón.
    prefix_to_vc, vc_domains = {}, {}
    for vc_id, groups_json, domains_json in c.execute(
            "SELECT id, rtl_groups, domain_ids FROM value_chain"):
        vc_domains[vc_id] = json.loads(domains_json)
        for g in json.loads(groups_json):
            prefix_to_vc[g] = vc_id

    n_vc = n_dom = 0
    for cap_id, in c.execute("SELECT id FROM rtb_l3").fetchall():
        prefix = "FSV" if cap_id.startswith("FSV") else cap_id.rsplit(".", 1)[0]
        vc = prefix_to_vc.get(prefix)
        if not vc:
            continue
        doms = vc_domains.get(vc) or []
        # Un eslabón con varios dominios no desambigua por sí solo: se ancla al
        # primero y la precisión fina la aporta el mapeo semántico por capacidad.
        dom = doms[0] if doms else None
        c.execute("UPDATE rtb_l3 SET vc_id=?, domain_id=? WHERE id=?", (vc, dom, cap_id))
        n_vc += 1
        if dom:
            n_dom += 1

    # ── recuento real de capacidades por eslabón ──────────────────────────
    for vc_id, n in c.execute(
            "SELECT vc_id, COUNT(*) FROM rtb_l3 WHERE vc_id IS NOT NULL GROUP BY vc_id").fetchall():
        c.execute("UPDATE value_chain SET cap_count=? WHERE id=?", (n, vc_id))

    # ── cobertura por dominio ─────────────────────────────────────────────
    for dom, n in c.execute(
            "SELECT domain_id, COUNT(*) FROM rtb_l3 WHERE domain_id IS NOT NULL GROUP BY domain_id").fetchall():
        c.execute("UPDATE retail_domains SET rtb_coverage=? WHERE id=?", (n, dom))
    for dom, n in c.execute(
            "SELECT domain_id, COUNT(*) FROM components WHERE domain_id IS NOT NULL GROUP BY domain_id").fetchall():
        c.execute("UPDATE retail_domains SET component_count=? WHERE id=?", (n, dom))

    # ── vista consolidada: aplicación × carga operativa × eslabón ─────────
    c.execute("DROP TABLE IF EXISTS app_operational_load")
    c.execute("""CREATE TABLE app_operational_load AS
        SELECT
            COALESCE(gc.component_id, gc.source_system) AS app_key,
            COALESCE(cp.name, gc.source_system)         AS app_name,
            cp.domain_id                                AS domain_id,
            cp.togaf_type                               AS togaf_type,
            COUNT(DISTINCT gc.group_name)               AS ams_groups,
            SUM(gc.tickets)                             AS tickets,
            SUM(g.recurrent)                            AS recurrent,
            SUM(g.prio_critica)                         AS prio_critica,
            SUM(g.prio_alta)                            AS prio_alta,
            MAX(g.p90_hours)                            AS worst_p90_hours
        FROM ams_group_component gc
        LEFT JOIN components cp ON cp.id = gc.component_id
        LEFT JOIN ams_groups  g  ON g.group_name = gc.group_name
        WHERE gc.mapping != 'gap'
        GROUP BY app_key""")

    conn.commit()

    print(f"rtb_l3              : {n_vc} capacidades ancladas a eslabón · {n_dom} con dominio")
    print()
    print("Cadena de valor — capacidades por eslabón:")
    for vc_id, name, n in c.execute(
            "SELECT id, name, cap_count FROM value_chain ORDER BY seq"):
        print(f"  {vc_id}  {str(n).rjust(3)}  {name}")
    print()
    print("Carga operativa por aplicación (top 10):")
    for r in c.execute("""SELECT app_name, tickets, recurrent, prio_critica+prio_alta
                          FROM app_operational_load ORDER BY tickets DESC LIMIT 10"""):
        print(f"  {str(r[1]).rjust(5)} tickets · {str(r[2] or 0).rjust(5)} recurrentes · "
              f"{str(r[3] or 0).rjust(3)} crit+alta  {r[0]}")
    conn.close()


if __name__ == "__main__":
    main()
