#!/usr/bin/env python3
"""
Liverpool — Carga el catálogo SUD al digital brain (idempotente).
Lee portal/data/sud-catalog-liv.json y puebla liverpool-brain.db:
  · components         — 1 fila por sistema SUD (seeded_by='SUD')
  · cross_dependencies — evidencia real desde interfaces (status='sud')
  · sud_systems        — detalle completo (servers/dbs/interfaces/risks/glossary) por sistema

Re-ejecutable: borra lo previo con marca SUD antes de reinsertar.
Correr DESPUÉS de build-liverpool-brain.py (que reconstruye la base).
"""
import json, sqlite3, re
from pathlib import Path

HERE  = Path(__file__).parent
BRAIN = HERE.parent
DB    = BRAIN / "liverpool-brain.db"
CAT   = BRAIN / "portal" / "data" / "sud-catalog-liv.json"

data = json.loads(CAT.read_text(encoding="utf-8"))
systems = data["systems"]

conn = sqlite3.connect(DB)
c = conn.cursor()

# ── tabla de detalle SUD ──────────────────────────────────────────────────────
c.execute("""CREATE TABLE IF NOT EXISTS sud_systems (
    slug TEXT PRIMARY KEY, system TEXT, domain_id TEXT, togaf_type TEXT,
    vendor TEXT, fill_quality TEXT, purpose TEXT,
    n_servers INT, n_databases INT, n_interfaces INT, n_risks INT, n_glossary INT,
    detail_json TEXT, seeded_by TEXT DEFAULT 'SUD')""")

# ── limpieza idempotente ──────────────────────────────────────────────────────
c.execute("DELETE FROM components WHERE seeded_by='SUD'")
c.execute("DELETE FROM cross_dependencies WHERE status='sud'")
c.execute("DELETE FROM sud_systems")

def short(txt, n=90):
    t = (txt or "").strip().replace("\n", " ")
    return t[:n] + ("…" if len(t) > n else "")

CX_MAP = {"rich": "high", "partial": "medium", "template": "low"}
dep_n = 0
for s in systems:
    slug = s["slug"]; sysname = s.get("system") or slug
    dom = s.get("domain") or "R10"
    tt  = s.get("togaf_type") or "channels"
    # component
    c.execute("""INSERT INTO components
        (id,name,source_system,source_language,component_type,domain_id,
         business_name,description,togaf_type,migration_fate,lines_of_code,
         complexity,status,rtb_capabilities,seeded_by)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
        (f"SUD-{slug}", sysname, sysname, None, "application", dom,
         short(s.get("purpose"), 120), s.get("purpose") or "", tt, None, None,
         None,   # complexity: la calidad del SUD no es complejidad del sistema
         "discovered", None, "SUD"))
    # detalle
    c.execute("""INSERT INTO sud_systems
        (slug,system,domain_id,togaf_type,vendor,fill_quality,purpose,
         n_servers,n_databases,n_interfaces,n_risks,n_glossary,detail_json,seeded_by)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
        (slug, sysname, dom, tt, s.get("vendor"), s.get("fill_quality"),
         s.get("purpose"), len(s.get("servers") or []), len(s.get("databases") or []),
         len(s.get("interfaces") or []), len(s.get("risks") or []),
         len(s.get("glossary") or []), json.dumps(s, ensure_ascii=False), "SUD"))
    # cross_dependencies desde interfaces + cross_dependencies declaradas
    deps = list(s.get("cross_dependencies") or [])
    for it in (s.get("interfaces") or []):
        cp = it.get("counterpart")
        if cp:
            deps.append({"other_system": cp,
                         "relationship": it.get("type", "interface"),
                         "direction": it.get("direction", ""),
                         "evidence": it.get("name") or it.get("protocol") or "interface"})
    for d in deps:
        other = (d.get("other_system") or "").strip()
        if not other:
            continue
        direction = (d.get("direction") or "").lower()
        if direction == "in":
            frm, to = other, sysname
        else:
            frm, to = sysname, other
        dep_n += 1
        c.execute("""INSERT INTO cross_dependencies
            (id,from_system,to_system,dependency_type,description,criticality,domain_ids,evidence,status)
            VALUES (?,?,?,?,?,?,?,?,?)""",
            (f"SUDDEP-{dep_n:04d}", frm, to, d.get("relationship", "interface"),
             short(d.get("evidence"), 160), "medium", dom,
             f"SUD: {s.get('sud_file','')}", "sud"))

conn.commit()

n_comp = c.execute("SELECT COUNT(*) FROM components WHERE seeded_by='SUD'").fetchone()[0]
n_dep  = c.execute("SELECT COUNT(*) FROM cross_dependencies WHERE status='sud'").fetchone()[0]
n_tot_comp = c.execute("SELECT COUNT(*) FROM components").fetchone()[0]
conn.close()
print(f"loaded: {n_comp} sistemas SUD -> components  |  {n_dep} cross_dependencies (status=sud)")
print(f"        sud_systems detalle table poblada")
print(f"        total components en brain ahora: {n_tot_comp}")
