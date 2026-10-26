# -*- coding: utf-8 -*-
"""
load-hosting-zones.py
Dimensión de hosting del landscape AXA México.

Responde la pregunta central de Exit Run Off Zone: ¿dónde vive cada sistema y
qué hay que sacar de RoZ antes del Q4 2028?

Un sistema puede ocupar varias zonas según el ambiente. El caso testigo es
Datapower: producción en la Run Off Zone y los ambientes de desarrollo y QA en
MPI. Por eso el hosting es una tabla de relación y no una columna de systems.

Disciplina de evidencia — campo `confidence`:
  evidenced  La fuente dice explícitamente dónde vive el sistema
  inferred   No lo dice, pero la naturaleza del producto no deja alternativa
             razonable (por ejemplo un SaaS de mercado). Se marca para poder
             filtrarlo y validarlo con el cliente
  Lo que no cae en ninguna de las dos no se registra: queda como brecha y
  aparece en el reporte de cobertura.

Uso:
    python generators/load-hosting-zones.py
    python generators/load-hosting-zones.py --dry-run
    python generators/load-hosting-zones.py --roz     # solo el inventario de RoZ
"""

import os
import sqlite3
import sys
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, "axa-brain.db")

DDL = """
CREATE TABLE IF NOT EXISTS hosting_zones (
    zone          TEXT PRIMARY KEY,
    display_name  TEXT,
    kind          TEXT,
    status        TEXT,
    note          TEXT
);

CREATE TABLE IF NOT EXISTS system_hosting (
    system_slug   TEXT,
    zone          TEXT,
    environment   TEXT,
    confidence    TEXT,
    evidence      TEXT,
    source        TEXT,
    PRIMARY KEY (system_slug, zone, environment)
);
"""

# ──────────────────────────────────────────────────────────────────────
# ZONAS
# kind: datacenter | cloud | saas | external | endpoint
# status: exit-target | active | deprecated
# ──────────────────────────────────────────────────────────────────────
ZONES = [
    ("roz", "Run Off Zone", "datacenter", "exit-target",
     "Zona de salida con infraestructura fuera de soporte. Debe vaciarse antes del Q4 2028. "
     "Es el objeto de la iniciativa INI-002, la de mayor winability del portafolio 2027"),
    ("pod", "POD", "datacenter", "active",
     "Centro de datos que aloja balanceadores virtualizados junto con la Run Off Zone"),
    ("mpi", "MPI", "datacenter", "active",
     "Centro de datos que aloja ambientes de desarrollo y QA. No confundir con el producto "
     "MPI Application Gateway, que comparte prefijo"),
    ("core-it", "Core IT", "datacenter", "active",
     "Servidores de Core IT. Liferay mantiene referencias a esta zona que no se han retirado, "
     "según la iniciativa INI-008 de Estabilidad"),
    ("azure", "Azure", "cloud", "active",
     "Backbone de infraestructura, datos e IA del Grupo AXA"),
    ("nube-privada", "Nube privada", "cloud", "active",
     "Plataforma de contenedores propia"),
    ("saas", "SaaS de proveedor", "saas", "active",
     "Servicio gestionado por el proveedor. Fuera del alcance de migración de infraestructura, "
     "pero dentro del alcance de gobierno de integraciones"),
    ("externo", "Servicio externo", "external", "active",
     "Fuera del perímetro de AXA. El TOGAF marca la falta de observabilidad unificada como gap"),
    ("endpoint", "Equipo de usuario final", "endpoint", "active",
     "Archivos y herramientas que viven en el escritorio del usuario o en carpetas compartidas"),
]

# ──────────────────────────────────────────────────────────────────────
# ASIGNACIONES
# (system_slug, zone, environment, confidence, evidence, source)
# environment: prod | dev-qa | all
# ──────────────────────────────────────────────────────────────────────
HOSTING = [
    # ── Run Off Zone: el inventario que importa para INI-002 ──────────
    ("api-gateway", "roz", "prod", "evidenced",
     "Por complejidad en la red, el Datapower de producción se llevó a la Run Off Zone. "
     "Cerca del 95% de las aplicaciones de AXA Seguros pasan por él",
     "PORTFOLIO-2027 INI-004"),
    ("api-gateway", "mpi", "dev-qa", "evidenced",
     "Los ambientes de desarrollo y QA de Datapower están en MPI",
     "PORTFOLIO-2027 INI-004"),
    ("ecm-ridd", "roz", "prod", "evidenced",
     "La fuente prevé que el enfoque actual de CMX no garantiza dejar de usar los servidores "
     "de la Run Off Zone antes de 2028",
     "PORTFOLIO-2027 INI-013"),
    ("perimeter", "roz", "prod", "evidenced",
     "Los balanceadores virtualizados viven en POD y en la Run Off Zone",
     "PORTFOLIO-2027 INI-009"),
    ("perimeter", "pod", "prod", "evidenced",
     "Los balanceadores virtualizados viven en POD y en la Run Off Zone",
     "PORTFOLIO-2027 INI-009"),

    # ── Cloud ─────────────────────────────────────────────────────────
    ("cloud-backbone", "azure", "all", "evidenced",
     "Azure es el backbone de infraestructura, datos e IA: Entra ID, APIM, Service Bus, "
     "Key Vault, Monitor y Sentinel",
     "TOGAF-p11"),
    ("azure-ai", "azure", "all", "evidenced",
     "Azure AI Foundry y OpenAI dentro del backbone Azure",
     "TOGAF-p4,p11"),
    ("data-platform-target", "azure", "all", "evidenced",
     "Azure Data Factory, Data Lake y Databricks como plataforma de datos destino",
     "TOGAF-p4,p7,p11"),
    ("containers", "nube-privada", "all", "evidenced",
     "OpenShift como plataforma de contenedores en nube privada",
     "TOGAF-p3"),

    # ── SaaS declarado en la fuente ───────────────────────────────────
    ("claims-autos", "saas", "all", "evidenced",
     "Guidewire como core SaaS de siniestros de Autos",
     "TOGAF-p6,p7,p11"),
    ("policy-admin-salud", "saas", "all", "evidenced",
     "Visual Time como SaaS de Salud",
     "TOGAF-p5,p11"),
    ("payments", "saas", "all", "evidenced",
     "FIS Payments como pagos SaaS en patrón híbrido",
     "TOGAF-p11"),
    ("procurement", "saas", "all", "evidenced",
     "Coupa como procurement SaaS",
     "TOGAF-p11"),
    ("fraud-detection", "saas", "all", "evidenced",
     "Shift Technology listado entre los cores SaaS y plataformas",
     "TOGAF-p6"),
    ("esb", "saas", "all", "evidenced",
     "Mulesoft Anypoint como iPaaS",
     "TOGAF-p11"),

    # ── SaaS inferido: producto de mercado sin alternativa razonable ──
    ("itsm", "saas", "all", "inferred",
     "ServiceNow es un producto SaaS de mercado. La fuente lo nombra como ITSM y CMDB "
     "corporativos pero no declara su modelo de despliegue",
     "TOGAF-p3,p11"),
    ("jira-service-mgmt", "saas", "all", "inferred",
     "Jira Service Management es un producto SaaS de mercado. La fuente no declara despliegue",
     "TOGAF-p3"),
    ("salesforce", "saas", "all", "inferred",
     "Salesforce es un producto SaaS de mercado. La fuente no declara alcance ni despliegue",
     "TOGAF-p3"),
    ("peritacion", "saas", "all", "inferred",
     "Audatex opera como servicio del proveedor con integración directa a Guidewire. "
     "La fuente no lo declara SaaS de forma explícita",
     "TOGAF-p10,p11"),
    ("securegpt", "saas", "all", "inferred",
     "SecureGPT es una pasarela corporativa de modelos del Grupo AXA. La fuente no declara "
     "dónde se despliega",
     "TOGAF-p4"),
    ("world-check", "saas", "all", "inferred",
     "World-Check es un servicio de screening de mercado. El Discovery lo menciona en uso "
     "sin declarar despliegue",
     "DISCOVERY"),
    ("actuarial-catnet", "saas", "all", "inferred",
     "Catnet es un servicio de mapeo de peligros naturales del proveedor. El Discovery no "
     "declara despliegue",
     "DISCOVERY"),

    # ── Externo ───────────────────────────────────────────────────────
    ("payments-online", "externo", "all", "evidenced",
     "Mitec y BBVA son pasarela externa de pagos online, sin observabilidad unificada "
     "en Azure Sentinel",
     "TOGAF-p8,p12"),
    ("infobip", "externo", "all", "evidenced",
     "Infobip como salida multicanal de la capa agéntica hacia WhatsApp, llamada y correo",
     "TOGAF-p9"),

    # ── Escritorio del usuario: el shadow IT ──────────────────────────
    ("hsd-excel", "endpoint", "all", "evidenced",
     "La Hoja de Suscripción de Daños se trabaja en Excel sobre archivos y carpetas locales",
     "DISCOVERY"),
    ("pyl-rentabilidad", "endpoint", "all", "evidenced",
     "El análisis de rentabilidad se prepara en P&L y en archivos de trabajo locales",
     "DISCOVERY"),
    ("tarifa-rc", "endpoint", "all", "evidenced",
     "La tarificación de Responsabilidad Civil se mantiene en Excel",
     "DISCOVERY"),
    ("security-list", "endpoint", "all", "evidenced",
     "El listado de reaseguradores admitidos se mantiene en Excel",
     "DISCOVERY"),
]


def validate(conn):
    errors = []
    zones = {z[0] for z in ZONES}
    known = {r[0] for r in conn.execute("SELECT slug FROM systems")}
    if not known:
        errors.append("La tabla systems está vacía. Ejecuta build-landscape-v2.py primero")
    seen = set()
    for slug, zone, env, conf, _ev, _src in HOSTING:
        if slug not in known:
            errors.append(f"Asignación apunta a sistema fuera del landscape: {slug}")
        if zone not in zones:
            errors.append(f"Zona desconocida: {zone}")
        if conf not in ("evidenced", "inferred"):
            errors.append(f"Confidence inválido en {slug}: {conf}")
        key = (slug, zone, env)
        if key in seen:
            errors.append(f"Asignación duplicada: {key}")
        seen.add(key)
    if errors:
        for e in errors:
            print(f"  [ERROR] {e}")
        raise SystemExit("[ABORT] La dimensión de hosting no es coherente. No se escribió nada.")
    print(f"  [OK] {len(ZONES)} zonas, {len(HOSTING)} asignaciones")


def load(conn):
    cur = conn.cursor()
    cur.execute("DELETE FROM hosting_zones")
    cur.executemany(
        "INSERT INTO hosting_zones (zone, display_name, kind, status, note) VALUES (?,?,?,?,?)",
        ZONES)
    cur.execute("DELETE FROM system_hosting")
    cur.executemany(
        "INSERT INTO system_hosting (system_slug, zone, environment, confidence, evidence, source) "
        "VALUES (?,?,?,?,?,?)", HOSTING)
    cur.executemany("INSERT OR REPLACE INTO brain_meta (key, value) VALUES (?,?)", [
        ("hosting_loaded_at", datetime.now().strftime("%Y-%m-%d %H:%M")),
        ("hosting_zones_count", str(len(ZONES))),
        ("hosting_assignments_count", str(len(HOSTING))),
    ])
    conn.commit()
    print(f"  [OK] hosting_zones: {len(ZONES)}")
    print(f"  [OK] system_hosting: {len(HOSTING)}")


def report_roz(conn):
    print("\n[INVENTARIO RUN OFF ZONE — alcance de INI-002]")
    q = """
        SELECT h.system_slug, s.real_name, h.environment, h.evidence
        FROM system_hosting h JOIN systems s ON s.slug = h.system_slug
        WHERE h.zone = 'roz' ORDER BY h.system_slug
    """
    rows = list(conn.execute(q))
    if not rows:
        print("  (vacío)")
    for slug, real, env, ev in rows:
        print(f"  {slug:<16} {real:<28} [{env}]")
        print(f"      {ev}")
    print(f"\n  Total confirmado en RoZ: {len(rows)} sistemas de 88.")
    print("  La fuente no da el inventario completo de RoZ: es el objeto del discovery "
          "de octubre a diciembre.")


def report(conn):
    print("\n[COBERTURA DE LA DIMENSION]")
    total = conn.execute("SELECT COUNT(*) FROM systems").fetchone()[0]
    con_dato = conn.execute("SELECT COUNT(DISTINCT system_slug) FROM system_hosting").fetchone()[0]
    ev = conn.execute(
        "SELECT COUNT(DISTINCT system_slug) FROM system_hosting WHERE confidence='evidenced'"
    ).fetchone()[0]
    inf = conn.execute(
        "SELECT COUNT(DISTINCT system_slug) FROM system_hosting WHERE confidence='inferred'"
    ).fetchone()[0]
    print(f"  Sistemas en el landscape        {total:>3}")
    print(f"  Con zona asignada               {con_dato:>3}  ({con_dato*100//total}%)")
    print(f"    de ellos con evidencia        {ev:>3}")
    print(f"    de ellos inferidos            {inf:>3}")
    print(f"  Sin zona, pendientes de dato    {total-con_dato:>3}  ({(total-con_dato)*100//total}%)")

    print("\n[SISTEMAS POR ZONA]")
    for zone, disp, status, n in conn.execute("""
        SELECT z.zone, z.display_name, z.status, COUNT(DISTINCT h.system_slug)
        FROM hosting_zones z LEFT JOIN system_hosting h ON h.zone = z.zone
        GROUP BY z.zone ORDER BY COUNT(DISTINCT h.system_slug) DESC
    """):
        flag = "  <- objetivo de salida" if status == "exit-target" else ""
        print(f"  {disp:<26} {n:>3}{flag}")

    report_roz(conn)

    print("\n[PENDIENTE DE DATO — sistemas sin zona, por categoria]")
    for cat, n in conn.execute("""
        SELECT s.category, COUNT(*) FROM systems s
        WHERE NOT EXISTS (SELECT 1 FROM system_hosting h WHERE h.system_slug = s.slug)
        GROUP BY s.category ORDER BY COUNT(*) DESC
    """):
        print(f"  {cat:<14} {n:>3}")
    print("\n  Este es el worklist para el discovery de Exit RoZ: hasta no saber en qué zona")
    print("  vive cada sistema, no se puede secuenciar la salida ni estimar el esfuerzo.")


def main():
    if not os.path.exists(DB_PATH):
        raise SystemExit(f"[ABORT] No existe {DB_PATH}")
    conn = sqlite3.connect(DB_PATH)
    conn.executescript(DDL)

    if "--roz" in sys.argv:
        report_roz(conn)
        return

    print("[HOSTING] Dimensión de zonas del landscape AXA")
    print("[VALIDATE]")
    validate(conn)
    if "--dry-run" in sys.argv:
        print("[DRY-RUN] Nada escrito.")
        return
    print("[LOAD]")
    load(conn)
    report(conn)
    conn.close()


if __name__ == "__main__":
    main()
