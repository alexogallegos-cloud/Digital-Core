"""
swarm-aggregator.py — Carga los JSONs del DT Swarm en brain.db lifecycle_* tables.
Uso: python swarm-aggregator.py [--dry-run]
"""
import sqlite3, json, os, sys
from datetime import datetime

DRY_RUN = "--dry-run" in sys.argv
DB   = os.path.join(os.path.dirname(__file__), "brain.db")
OUT  = os.path.join(os.path.dirname(__file__), "swarm-output")
NOW  = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")

PHASES_META = {
    "originacion":  {"num": "01", "icon": "📋", "color": "#1565C0", "track": "apolo"},
    "emision":      {"num": "02", "icon": "🏭", "color": "#6A1B9A", "track": "smartvista"},
    "activacion":   {"num": "03", "icon": "⚡", "color": "#E65100", "track": "app, smartvista"},
    "autorizacion": {"num": "04", "icon": "🔐", "color": "#2E7D32", "track": "smartvista"},
    "transacciones":{"num": "05", "icon": "📊", "color": "#0277BD", "track": "smartvista, app, cat, siweb"},
    "pagos":        {"num": "06", "icon": "💰", "color": "#00695C", "track": "smartvista, app"},
    "contabilidad": {"num": "07", "icon": "📒", "color": "#4E342E", "track": "smartvista, apificacion"},
    "cobranza":     {"num": "08", "icon": "📞", "color": "#BF360C", "track": "informix, smartvista"},
}

def load_json(phase_id):
    path = os.path.join(OUT, f"{phase_id}-analysis.json")
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def _scalar(v):
    if isinstance(v, (dict, list)):
        return json.dumps(v, ensure_ascii=False)
    return v

def upsert(cur, table, row):
    cols = list(row.keys())
    placeholders = ", ".join(["?" for _ in cols])
    col_names    = ", ".join(cols)
    sql = f"INSERT OR REPLACE INTO {table} ({col_names}) VALUES ({placeholders})"
    cur.execute(sql, [_scalar(v) for v in row.values()])

def _node_name(node):
    return (node.get("node_name") or node.get("label") or node.get("name")
            or node.get("system") or node.get("sistema",""))

def _arrow_label(arrow, i):
    label = arrow.get("label","")
    frm   = arrow.get("from_node") or arrow.get("from","")
    to    = arrow.get("to_node")   or arrow.get("to","")
    if frm and to:
        label = f"{frm} → {to}: {label}"
    return label[:200]

def _normalize_flow(fv):
    """Return (nodes_list, arrows_list, summary_str) from any flow_validated shape."""
    if isinstance(fv, list):
        return fv, [], ""
    if isinstance(fv, dict):
        nodes  = (fv.get("nodes") or fv.get("main_flow") or [])
        raw_arrows = (fv.get("arrows") or fv.get("flow_sequence") or [])
        arrows = [a for a in raw_arrows if isinstance(a, dict)]
        vs     = (fv.get("validation_summary") or fv.get("summary")
                  or fv.get("notes") or fv.get("aging_model_note") or "")
        if isinstance(vs, (dict, list)):
            vs = json.dumps(vs, ensure_ascii=False)
        # alternate_channels: append as extra nodes if present
        alt = fv.get("alternate_channels") or []
        if isinstance(alt, list):
            nodes = list(nodes) + list(alt)
        return nodes, arrows, str(vs)
    return [], [], ""

def load_phase(cur, phase_id, data):
    meta = PHASES_META[phase_id]

    nodes, arrows, vs_str = _normalize_flow(data["flow_validated"])

    # ── lifecycle_phases — preservar columnas que el aggregator no gestiona ──
    existing = cur.execute(
        "SELECT etb_l3, track, notes, narrative_industry, narrative_kpis, narrative_brechas "
        "FROM lifecycle_phases WHERE phase_id=?", (phase_id,)
    ).fetchone()
    preserved = {}
    if existing:
        cols = ["etb_l3","track","notes","narrative_industry","narrative_kpis","narrative_brechas"]
        preserved = {c: existing[i] for i, c in enumerate(cols) if existing[i] is not None}

    upsert(cur, "lifecycle_phases", {
        "phase_id":    phase_id,
        "name":        data["phase_name"],
        "num":         meta["num"],
        "icon":        meta["icon"],
        "color":       meta["color"],
        "description": vs_str,
        "coverage":    "parcial" if any(
            s.get("gap_flag") for s in data.get("steps_enriched",[])
        ) else "completa",
        "us_count":    len(data.get("us_mapping",[])),
        "validated":   1,
        "updated_at":  NOW,
        **preserved,
    })

    # ── borrar datos existentes de esta fase antes de recargar ────────
    # Solo reemplazar si el swarm trae datos; si no, conservar los estáticos de build-brain.py
    if nodes:
        cur.execute("DELETE FROM lifecycle_flow_nodes   WHERE phase_id=?", (phase_id,))
    if arrows:
        cur.execute("DELETE FROM lifecycle_flow_arrows  WHERE phase_id=?", (phase_id,))
    cur.execute("DELETE FROM lifecycle_steps            WHERE phase_id=?", (phase_id,))
    cur.execute("DELETE FROM lifecycle_data_elements    WHERE phase_id=?", (phase_id,))
    cur.execute("DELETE FROM lifecycle_integrations     WHERE phase_id=?", (phase_id,))
    cur.execute("DELETE FROM lifecycle_test_cases       WHERE phase_id=?", (phase_id,))
    for i, node in enumerate(nodes):
        if not isinstance(node, dict):
            continue
        nid  = f"LFN-{phase_id.upper()[:4]}-{i+1:03d}"
        name = _node_name(node)
        upsert(cur, "lifecycle_flow_nodes", {
            "id":           nid,
            "phase_id":     phase_id,
            "step_order":   i + 1,
            "node_name":    name,
            "system_id":    name.lower().replace(" ","_")[:40],
            "node_type":    node.get("node_type") or node.get("type",""),
            "pending":      1 if node.get("pending") else 0,
            "evidence_type":node.get("evidence_type",""),
            "evidence_ref": node.get("evidence_ref",""),
        })

    # ── lifecycle_flow_arrows ─────────────────────────────────────────
    for i, arrow in enumerate(arrows):
        aid = f"LFA-{phase_id.upper()[:4]}-{i+1:03d}"
        upsert(cur, "lifecycle_flow_arrows", {
            "id":           aid,
            "phase_id":     phase_id,
            "step_order":   arrow.get("step_order") or arrow.get("step_ref") or i+1,
            "label":        _arrow_label(arrow, i),
            "pending":      1 if arrow.get("pending") else 0,
            "evidence_ref": arrow.get("evidence_ref",""),
        })

    # ── lifecycle_steps ───────────────────────────────────────────────
    for idx, step in enumerate(data.get("steps_enriched",[])):
        step_n = (step.get("step_n") or step.get("step_num") or step.get("step") or idx+1)
        try:
            step_n = int(step_n)
        except (TypeError, ValueError):
            step_n = idx + 1
        sid = f"LS-{phase_id.upper()[:4]}-{step_n:03d}"
        desc   = (step.get("description") or step.get("name") or step.get("titulo",""))
        sistema = (step.get("sistema") or step.get("system") or step.get("systems",""))
        if isinstance(sistema, list):
            sistema = ", ".join(sistema)
        us_id  = (step.get("us_id") or step.get("user_story_ref") or step.get("user_story_id") or None)
        us_ttl = step.get("us_title") or None
        proto  = (step.get("protocol") or step.get("protocolo") or None)
        exists = step.get("exists_today", False)
        gflag  = step.get("gap_flag", False)
        gnote  = (step.get("gap_notes") or step.get("gap_description") or step.get("evidence") or None)
        upsert(cur, "lifecycle_steps", {
            "id":          sid,
            "phase_id":    phase_id,
            "step_n":      step_n,
            "description": desc,
            "sistema":     sistema,
            "us_id":       us_id,
            "us_title":    us_ttl,
            "protocol":    proto,
            "exists_today":1 if exists else 0,
            "gap_flag":    1 if gflag else 0,
            "gap_notes":   gnote,
        })

    # ── lifecycle_data_elements ───────────────────────────────────────
    for i, de in enumerate(data.get("data_elements",[])):
        did = f"LDE-{phase_id.upper()[:4]}-{i+1:03d}"
        # Normalize: support both English and Spanish field names
        fname = de.get("field_name") or de.get("nombre") or de.get("name","")
        ename = de.get("entity_name") or de.get("entidad","")
        dtype = de.get("data_type") or de.get("tipo","")
        desc  = de.get("description") or de.get("descripcion","")
        src   = de.get("source_system") or de.get("fuente","")
        reg   = de.get("regulation_ref") or de.get("regulacion") or None
        is_pii = de.get("is_pii") or ("pii" in str(de.get("sensibilidad","")).lower())
        is_fin = de.get("is_financial") or de.get("is_fin") or False
        upsert(cur, "lifecycle_data_elements", {
            "id":             did,
            "phase_id":       phase_id,
            "entity_name":    ename,
            "field_name":     fname,
            "data_type":      dtype,
            "description":    desc,
            "source_system":  src,
            "regulation_ref": reg,
            "is_pii":         1 if is_pii else 0,
            "is_financial":   1 if is_fin else 0,
        })

    # ── lifecycle_integrations ────────────────────────────────────────
    for i, intg in enumerate(data.get("integrations",[])):
        iid = f"LI-{phase_id.upper()[:4]}-{i+1:03d}"
        # Normalize: support both English and Spanish field names
        iref  = intg.get("integration_ref") or intg.get("id","")
        frm   = intg.get("from_system") or intg.get("sistema_origen","")
        to    = intg.get("to_system")   or intg.get("sistema_destino","")
        api   = intg.get("api_name")    or intg.get("nombre","")
        proto = intg.get("protocol")    or intg.get("tipo","")
        direc = intg.get("direction","")
        evus  = intg.get("evidence_us") or intg.get("us_ref") or None
        scope = intg.get("scope_r4",True)
        gflag = intg.get("gap_flag") or (intg.get("existe_hoy") is False) or False
        gnote = intg.get("gap_notes") or intg.get("descripcion") or None
        upsert(cur, "lifecycle_integrations", {
            "id":              iid,
            "phase_id":        phase_id,
            "integration_ref": iref,
            "from_system":     frm,
            "to_system":       to,
            "api_name":        api,
            "protocol":        proto,
            "direction":       direc,
            "evidence_us":     evus,
            "scope_r4":        1 if scope else 0,
            "gap_flag":        1 if gflag else 0,
            "gap_notes":       gnote,
        })

    # ── lifecycle_test_cases ──────────────────────────────────────────
    for i, tc in enumerate(data.get("test_cases",[])):
        tcid = f"LTC-{phase_id.upper()[:4]}-{i+1:03d}"
        # Normalize: support both English and Spanish field names
        title  = tc.get("tc_title") or tc.get("nombre") or tc.get("title","")
        pre    = tc.get("precondition") or tc.get("precondiciones","")
        steps  = tc.get("steps_summary") or tc.get("descripcion","")
        exp    = tc.get("expected_result") or tc.get("resultado_esperado","")
        prio   = tc.get("priority") or tc.get("prioridad","")
        ttype  = tc.get("test_type") or tc.get("tipo","")
        reg    = tc.get("regulation_ref") or tc.get("kpi_ref") or None
        lus    = tc.get("linked_us_id") or None
        upsert(cur, "lifecycle_test_cases", {
            "id":               tcid,
            "phase_id":         phase_id,
            "tc_id":            tc.get("tc_id",""),
            "tc_title":         title,
            "precondition":     pre,
            "steps_summary":    steps,
            "expected_result":  exp,
            "priority":         prio,
            "test_type":        ttype,
            "regulation_ref":   reg,
            "linked_us_id":     lus,
        })

    print(f"  ✓ {phase_id}: "
          f"{len(nodes)} nodes, "
          f"{len(arrows)} arrows, "
          f"{len(data.get('steps_enriched',[]))} steps, "
          f"{len(data.get('data_elements',[]))} data_elements, "
          f"{len(data.get('integrations',[]))} integrations, "
          f"{len(data.get('test_cases',[]))} test_cases")

def main():
    if DRY_RUN:
        print("[DRY-RUN] No changes will be written to brain.db")

    con = sqlite3.connect(DB)
    cur = con.cursor()

    phases = ["originacion","emision","activacion","autorizacion",
              "transacciones","pagos","contabilidad","cobranza"]
    for phase_id in phases:
        json_path = os.path.join(OUT, f"{phase_id}-analysis.json")
        if not os.path.exists(json_path):
            print(f"  SKIP {phase_id}: {json_path} not found")
            continue
        data = load_json(phase_id)
        print(f"Loading {phase_id}...")
        if not DRY_RUN:
            load_phase(cur, phase_id, data)
        else:
            load_phase(cur, phase_id, data)

    if not DRY_RUN:
        con.commit()
        print("\nCommitted to brain.db")
    else:
        print("\n[DRY-RUN] Rolled back — no changes written")
        con.rollback()

    # Verification
    print("\n--- lifecycle_* table counts ---")
    for tbl in ["lifecycle_phases","lifecycle_flow_nodes","lifecycle_flow_arrows",
                "lifecycle_steps","lifecycle_data_elements","lifecycle_integrations","lifecycle_test_cases"]:
        n = cur.execute(f"SELECT COUNT(*) FROM {tbl}").fetchone()[0]
        print(f"  {tbl}: {n}")

    con.close()

if __name__ == "__main__":
    main()
