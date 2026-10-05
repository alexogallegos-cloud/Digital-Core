#!/usr/bin/env python3
"""
build-liverpool-brain.py — Liverpool Federated Brain Builder
SPE-AM-003 · High Velocity Modernization · Application Modernization

Construye liverpool-brain.db (SQLite) agregando:
  - rtb_l3        : 232 caps Retail (RTL.{L1}.{seq}) + 50 caps FS (FSV.{L1}.{seq})
  - retail_domains: 10 dominios retail R01-R10
  - components    : inventario de componentes (poblado por brains de sistemas)
  - cross_deps    : dependencias cruzadas entre los 4 sistemas

Ejecutar: python build-liverpool-brain.py
Requiere: rtl-capabilities.json + fsv-capabilities.json (mismo directorio)

Después ejecutar: python generators/extract-from-dashboard.py  (carga 117 servicios)

Federación (B4): usa SQLite ATTACH para agregar los brains de sistemas:
  ../systems/core/SAP/digital-brain/brain.db
  ../systems/core/Mainframe/digital-brain/brain.db
  ../systems/processors/Oracle-PL-SQL/digital-brain/brain.db
  ../systems/channels/Digital-Platform/digital-brain/brain.db
"""

import sqlite3
import json
import os
import sys
from pathlib import Path
from datetime import date

BASE_DIR = Path(__file__).parent
DB_PATH  = BASE_DIR / "liverpool-brain.db"
RTL_PATH = BASE_DIR / "rtl-capabilities.json"   # Retail ETB  — RTL.{L1}.{seq}
FSV_PATH = BASE_DIR / "fsv-capabilities.json"   # FS ETB (R03) — FSV.{L1}.{seq}

SYSTEM_BRAINS = {
    "SAP": BASE_DIR / "../systems/core/SAP/digital-brain/brain.db",
    "Mainframe": BASE_DIR / "../systems/core/Mainframe/digital-brain/brain.db",
    "Oracle": BASE_DIR / "../systems/processors/Oracle-PL-SQL/digital-brain/brain.db",
    "Digital-Platform": BASE_DIR / "../systems/channels/Digital-Platform/digital-brain/brain.db",
}

RETAIL_DOMAINS = [
    ("R01", "Gestión Comercial",
     "Gestión de productos, catálogo, precios y merchandising",
     "SAP,Mainframe"),
    ("R02", "Gestión de Clientes y Lealtad",
     "CRM, programa Liverpool Premia, LiverpoolCard cliente",
     "Oracle,Digital-Platform"),
    ("R03", "Servicios Financieros",
     "LiverpoolCard — crédito al consumo, cobranza, cargos, reportería regulatoria",
     "Oracle,Mainframe"),
    ("R04", "Cadena de Suministro y Logística",
     "Compras, WMS, distribución, last-mile, centro Arco Norte",
     "SAP,Digital-Platform"),
    ("R05", "Canales Digitales",
     "E-commerce liverpool.com.mx, app móvil, APIs omnicanal, Click and Collect",
     "Digital-Platform"),
    ("R06", "Operaciones de Tienda",
     "POS, cierres, inventario en tienda, pagos en tienda",
     "SAP,Mainframe"),
    ("R07", "Finanzas y Contabilidad",
     "Contabilidad general, costos, tesorería, reportería financiera",
     "SAP,Oracle"),
    ("R08", "Recursos Humanos",
     "Nómina, gestión de empleados, capacitación, plantilla 130+ tiendas",
     "SAP"),
    ("R09", "Analítica e Inteligencia",
     "BI, analytics de ventas, customer analytics, forecasting",
     "Digital-Platform,SAP"),
    ("R10", "Infraestructura y Plataforma",
     "Integración entre sistemas, middleware, APIs internas, cloud",
     "Digital-Platform"),
]


def create_schema(conn):
    conn.executescript("""
    CREATE TABLE IF NOT EXISTS brain_meta (
        key TEXT PRIMARY KEY,
        value TEXT
    );

    CREATE TABLE IF NOT EXISTS retail_domains (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        primary_systems TEXT,
        component_count INTEGER DEFAULT 0,
        rtb_coverage INTEGER DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS rtb_l3 (
        id TEXT PRIMARY KEY,          -- RTL.{L1}.{seq} o FSV.{L1}.{seq}
        l1_num INTEGER,               -- número de L1 (1-9 Retail, 1-6 FS)
        l1_name TEXT NOT NULL,
        l2_name TEXT NOT NULL,
        l3_name TEXT NOT NULL,
        description TEXT,
        source TEXT,
        source_etb TEXT DEFAULT 'retail',  -- 'retail' | 'financial_services'
        primary_system TEXT,
        regulation TEXT,              -- JSON array de normas aplicables
        liverpool_status TEXT DEFAULT 'UNKNOWN',
        domain_id TEXT,
        etb_version TEXT DEFAULT '1.0'
    );

    CREATE TABLE IF NOT EXISTS components (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        source_system TEXT,
        source_language TEXT,
        component_type TEXT,
        domain_id TEXT,
        business_name TEXT,
        description TEXT,
        togaf_type TEXT,
        migration_fate TEXT,
        lines_of_code INTEGER,
        complexity TEXT,
        status TEXT DEFAULT 'active',
        rtb_capabilities TEXT,
        seeded_by TEXT
    );

    CREATE TABLE IF NOT EXISTS cross_dependencies (
        id TEXT PRIMARY KEY,
        from_system TEXT NOT NULL,
        to_system TEXT NOT NULL,
        dependency_type TEXT,
        description TEXT,
        criticality TEXT DEFAULT 'medium',
        domain_ids TEXT,
        evidence TEXT,
        status TEXT DEFAULT 'hypothesis'
    );

    CREATE TABLE IF NOT EXISTS value_chain (
        id TEXT PRIMARY KEY,            -- VC-01 .. VC-09
        seq INTEGER NOT NULL,           -- orden visual
        name TEXT NOT NULL,             -- nombre del proceso
        subtitle TEXT,                  -- descripción breve
        zone TEXT DEFAULT 'primary',    -- primary | support
        classification TEXT DEFAULT 'S', -- S=Sustantivo E=Secundario P=Soporte
        rtl_groups TEXT,                -- JSON ["RTL.4","RTL.5"] o ["FSV"]
        domain_ids TEXT,                -- JSON ["R01","R04"]
        cap_count INTEGER DEFAULT 0,    -- calculado post carga de rtb_l3
        color TEXT DEFAULT 'sky'        -- sky | cerise | rose | muted
    );

    CREATE VIRTUAL TABLE IF NOT EXISTS components_fts USING fts5(
        id, name, business_name, description,
        content='components', content_rowid='rowid'
    );

    CREATE VIRTUAL TABLE IF NOT EXISTS rtb_fts USING fts5(
        id, l1_name, l2_name, l3_name, description,
        content='rtb_l3', content_rowid='rowid'
    );
    """)
    conn.commit()


def _load_caps_file(path: Path, source_etb: str, default_version: str) -> list:
    with open(path, "r", encoding="utf-8-sig") as f:
        data = json.loads(f.read(), strict=False)
    rows = []
    for cap in data["capabilities"]:
        reg = cap.get("regulation")
        rows.append((
            cap["id"],
            cap.get("l1_num"),
            cap.get("l1_name", ""),
            cap.get("l2_name", ""),
            cap.get("l3_name", ""),
            cap.get("description", ""),
            cap.get("source", source_etb),
            cap.get("source_etb", source_etb),
            cap.get("primary_system"),
            json.dumps(reg, ensure_ascii=False) if isinstance(reg, list) else reg,
            "UNKNOWN",
            None,
            default_version,
        ))
    return rows


def load_rtb(conn):
    rows = []

    if RTL_PATH.exists():
        rtl_rows = _load_caps_file(RTL_PATH, "retail", "5.0")
        rows.extend(rtl_rows)
        print(f"  RTL: {len(rtl_rows)} capacidades Retail (RTL.x.xx)")
    else:
        print(f"  WARN: {RTL_PATH.name} no encontrado — ejecutar generators/generate-rtl-capabilities.py")

    if FSV_PATH.exists():
        fsv_rows = _load_caps_file(FSV_PATH, "financial_services", "1.0")
        rows.extend(fsv_rows)
        print(f"  FSV: {len(fsv_rows)} capacidades Financial Services (FSV.x.xx)")
    else:
        print(f"  WARN: {FSV_PATH.name} no encontrado")

    conn.executemany("""
        INSERT OR REPLACE INTO rtb_l3
        (id, l1_num, l1_name, l2_name, l3_name, description, source,
         source_etb, primary_system, regulation,
         liverpool_status, domain_id, etb_version)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)
    """, rows)
    conn.commit()
    print(f"  Total caps: {len(rows)} (RTL + FSV)")


def load_domains(conn):
    rows = [(d[0], d[1], d[2], d[3], 0, 0) for d in RETAIL_DOMAINS]
    conn.executemany("""
        INSERT OR REPLACE INTO retail_domains
        (id, name, description, primary_systems, component_count, rtb_coverage)
        VALUES (?,?,?,?,?,?)
    """, rows)
    conn.commit()
    print(f"  Dominios: {len(rows)} dominios retail R01-R10 cargados")


VALUE_CHAIN_SEED = [
    # zone=primary — actividades generadoras de valor directo (izq → der)
    ("VC-01", 1, "Desarrollo de Oferta",    "Market & Product Development + Merchandising",
     "primary", "S", '["RTL.4","RTL.5"]', '["R01"]',           "sky"),
    ("VC-02", 2, "Cadena de Suministro",    "Supply Chain, Logística y Distribución",
     "primary", "S", '["RTL.6"]',          '["R04"]',           "sky"),
    ("VC-03", 3, "Comercio Unificado",      "Venta omnicanal — Online, Tienda, Click & Collect",
     "primary", "S", '["RTL.3"]',          '["R01","R05","R06"]',"sky"),
    ("VC-04", 4, "Canales de Interacción",  "Digital, Tienda Física, Contact Center, App",
     "primary", "S", '["RTL.1"]',          '["R05"]',           "sky"),
    ("VC-05", 5, "Engagement y Marketing",  "CRM, Programa Premia, Campañas, Lealtad",
     "primary", "E", '["RTL.2"]',          '["R02"]',           "rose"),
    ("VC-06", 6, "Servicios Financieros",   "LiverpoolCard — Crédito, Cobranza, Fraude, Cumplimiento",
     "primary", "S", '["FSV"]',            '["R03"]',           "cerise"),
    # zone=support — actividades habilitadoras
    ("VC-07", 7, "Fundación Empresarial",   "Finanzas, RRHH, Legal, Gobernanza Corporativa",
     "support", "P", '["RTL.7"]',          '["R07","R08"]',     "muted"),
    ("VC-08", 8, "Fundación de Información","TI, Datos Maestros, Plataforma, Middleware",
     "support", "P", '["RTL.8"]',          '["R10"]',           "muted"),
    ("VC-09", 9, "Analítica e Inteligencia","BI, Forecasting, Customer Analytics, Insights",
     "support", "E", '["RTL.9"]',          '["R09"]',           "rose"),
]


def load_value_chain(conn):
    conn.executemany("""
        INSERT OR REPLACE INTO value_chain
        (id, seq, name, subtitle, zone, classification, rtl_groups, domain_ids, cap_count, color)
        VALUES (?,?,?,?,?,?,?,?,0,?)
    """, VALUE_CHAIN_SEED)
    conn.commit()

    # Calcular cap_count desde rtb_l3
    for vc_id, rtl_groups_json in conn.execute("SELECT id, rtl_groups FROM value_chain"):
        groups = json.loads(rtl_groups_json)
        if "FSV" in groups:
            cnt = conn.execute(
                "SELECT COUNT(*) FROM rtb_l3 WHERE source_etb='financial_services'"
            ).fetchone()[0]
        else:
            l1_nums = [int(g.split(".")[1]) for g in groups if g.startswith("RTL")]
            ph = ",".join("?" * len(l1_nums))
            cnt = conn.execute(
                f"SELECT COUNT(*) FROM rtb_l3 WHERE source_etb='retail' AND l1_num IN ({ph})",
                l1_nums,
            ).fetchone()[0]
        conn.execute("UPDATE value_chain SET cap_count=? WHERE id=?", (cnt, vc_id))
    conn.commit()
    vc_count = conn.execute("SELECT COUNT(*) FROM value_chain").fetchone()[0]
    print(f"  Value chain: {vc_count} bloques de proceso cargados")


def load_cross_dependencies(conn):
    # Known cross-system dependencies (hypothesis level, to be confirmed in Etapa 0)
    deps = [
        ("XDEP-001", "SAP", "Oracle", "data_exchange",
         "SAP FI integra con Oracle para conciliacion LiverpoolCard — transferencia datos financieros",
         "high", "R03,R07", "hypothesis"),
        ("XDEP-002", "SAP", "Mainframe", "data_exchange",
         "SAP intercambia con Mainframe para cierres de tienda y batch nocturno",
         "high", "R01,R06", "hypothesis"),
        ("XDEP-003", "SAP", "Digital-Platform", "api_call",
         "Digital Platform consulta SAP para catalogo, inventario y precios en tiempo real",
         "critical", "R01,R04,R05", "hypothesis"),
        ("XDEP-004", "Oracle", "Digital-Platform", "api_call",
         "Digital Platform consulta Oracle para autorizacion de credito LiverpoolCard en checkout",
         "critical", "R02,R03,R05", "hypothesis"),
        ("XDEP-005", "Mainframe", "Oracle", "data_exchange",
         "Mainframe alimenta Oracle con transacciones batch de LiverpoolCard",
         "high", "R03", "hypothesis"),
        ("XDEP-006", "Digital-Platform", "SAP", "api_call",
         "Click and Collect requiere consulta de inventario en tienda desde SAP",
         "critical", "R04,R05,R06", "hypothesis"),
    ]

    rows = [(d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7]) for d in deps]
    conn.executemany("""
        INSERT OR REPLACE INTO cross_dependencies
        (id, from_system, to_system, dependency_type, description, criticality, domain_ids, status)
        VALUES (?,?,?,?,?,?,?,?)
    """, rows)
    conn.commit()
    print(f"  Cross-deps: {len(rows)} dependencias hipótesis cargadas")


def populate_meta(conn):
    today = str(date.today())
    rtl_count = conn.execute("SELECT COUNT(*) FROM rtb_l3 WHERE source_etb='retail'").fetchone()[0]
    fsv_count = conn.execute("SELECT COUNT(*) FROM rtb_l3 WHERE source_etb='financial_services'").fetchone()[0]
    meta = [
        ("project_id",            "SPE-AM-003"),
        ("client",                "El Puerto de Liverpool S.A.B. de C.V."),
        ("brain_type",            "federated"),
        ("brain_version",         "0.2.0"),
        ("rtl_version",           "5.0"),
        ("fsv_version",           "1.0"),
        ("rtl_total_l3",          str(rtl_count)),
        ("fsv_total_l3",          str(fsv_count)),
        ("capability_model",      "Retail ETB (RTL) + FS overlay (FSV) — Option A"),
        ("domains",               "R01-R10"),
        ("systems",               "SAP,Mainframe,Oracle,Digital-Platform"),
        ("built_at",              today),
        ("status",                "ACTIVE"),
        ("togaf_state_SAP",       "baseline"),
        ("togaf_state_Mainframe", "baseline"),
        ("togaf_state_Oracle",    "baseline"),
        ("togaf_state_Digital_Platform", "transitional"),
    ]
    conn.executemany(
        "INSERT OR REPLACE INTO brain_meta (key, value) VALUES (?,?)", meta
    )
    conn.commit()


def attach_system_brains(conn):
    attached = []
    for system_name, brain_path in SYSTEM_BRAINS.items():
        resolved = brain_path.resolve()
        if resolved.exists():
            alias = system_name.lower().replace("-", "_")
            conn.execute(f"ATTACH DATABASE ? AS {alias}", (str(resolved),))
            attached.append(system_name)
            print(f"  ATTACH: {system_name} ({resolved.name})")
        else:
            print(f"  SKIP (not built yet): {system_name}")
    return attached


def aggregate_components(conn, attached_systems):
    for system in attached_systems:
        alias = system.lower().replace("-", "_")
        try:
            cur = conn.execute(f"SELECT * FROM {alias}.components LIMIT 1")
            cols = [d[0] for d in cur.description]
            cur = conn.execute(f"SELECT * FROM {alias}.components")
            rows = cur.fetchall()
            for row in rows:
                row_dict = dict(zip(cols, row))
                conn.execute("""
                    INSERT OR IGNORE INTO components
                    (id, name, source_system, source_language, component_type,
                     domain_id, business_name, description, togaf_type,
                     migration_fate, lines_of_code, complexity, status)
                    VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)
                """, (
                    row_dict.get("id"),
                    row_dict.get("name"),
                    system,
                    row_dict.get("source_language"),
                    row_dict.get("component_type"),
                    row_dict.get("domain_id"),
                    row_dict.get("business_name"),
                    row_dict.get("description"),
                    row_dict.get("togaf_type"),
                    row_dict.get("migration_fate"),
                    row_dict.get("lines_of_code"),
                    row_dict.get("complexity"),
                    row_dict.get("status", "active"),
                ))
            print(f"  Aggregated {len(rows)} components from {system}")
        except Exception as e:
            print(f"  Could not aggregate from {system}: {e}")
    conn.commit()


def main():
    print("Liverpool Brain Builder — SPE-AM-003")
    print("=" * 45)

    if DB_PATH.exists():
        DB_PATH.unlink()
        print(f"  Rebuilt: {DB_PATH.name}")

    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA journal_mode=WAL")

    print("Schema...")
    create_schema(conn)

    print("Capabilities (RTL + FSV)...")
    load_rtb(conn)

    print("Retail domains...")
    load_domains(conn)

    print("Value chain...")
    load_value_chain(conn)

    print("Cross-system dependencies (hypothesis)...")
    load_cross_dependencies(conn)

    print("Metadata...")
    populate_meta(conn)

    print("Attaching system brains (federation B4)...")
    attached = attach_system_brains(conn)

    if attached:
        print("Aggregating components from attached brains...")
        aggregate_components(conn, attached)

    # Rebuild FTS
    conn.execute("INSERT INTO rtb_fts(rtb_fts) VALUES('rebuild')")
    conn.commit()

    # Summary
    rtl_count  = conn.execute("SELECT COUNT(*) FROM rtb_l3 WHERE source_etb='retail'").fetchone()[0]
    fsv_count  = conn.execute("SELECT COUNT(*) FROM rtb_l3 WHERE source_etb='financial_services'").fetchone()[0]
    comp_count = conn.execute("SELECT COUNT(*) FROM components").fetchone()[0]
    dom_count  = conn.execute("SELECT COUNT(*) FROM retail_domains").fetchone()[0]
    dep_count  = conn.execute("SELECT COUNT(*) FROM cross_dependencies").fetchone()[0]
    vc_count   = conn.execute("SELECT COUNT(*) FROM value_chain").fetchone()[0]

    conn.close()

    print()
    print("Liverpool Brain built:")
    print(f"  RTL capabilities (Retail)  : {rtl_count}  (RTL.x.xx — 9 L1 groups)")
    print(f"  FSV capabilities (FS R03)  : {fsv_count}   (FSV.x.xx — 6 L1 groups)")
    print(f"  Total capabilities         : {rtl_count + fsv_count}")
    print(f"  Retail domains             : {dom_count} (R01-R10)")
    print(f"  Components                 : {comp_count}")
    print(f"  Cross-dependencies         : {dep_count}")
    print(f"  Value chain blocks         : {vc_count}")
    print(f"  DB path                    : {DB_PATH}")
    print()
    print("Next steps:")
    print("  python generators/extract-from-dashboard.py  # carga 117 servicios")
    print("  python liverpool-brain.py                    # test Agent API")


if __name__ == "__main__":
    main()