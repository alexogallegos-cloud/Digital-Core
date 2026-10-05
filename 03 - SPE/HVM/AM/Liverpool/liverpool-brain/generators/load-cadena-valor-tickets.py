"""
load-cadena-valor-tickets.py
Carga el análisis anual de tickets por grupo AMS con métricas de SLA
y enriquece la ontología del brain con la relación a la cadena de valor ETB.

Fuente: source/Cadena de Valor y Tickets 30092026/Analisis x Grupo y Año 2.xlsx
Columnas: Assigned_Group, Año, Tickets, Mediana_Atencion_H, P90_Atencion_H, P1, P2, P1&P2

Qué hace este loader:
  1. Crea tabla ams_yearly (group × year con métricas completas de SLA)
  2. Agrega columna vc_id a ams_groups y ams_group_component
  3. Incorpora 13 grupos nuevos a ams_group_component con su mapeo
  4. Actualiza vc_id en todos los grupos (87) para cruzar contra la ontología ETB
  5. Actualiza brain_meta con las nuevas cifras
"""

import sqlite3
import openpyxl
from pathlib import Path

DB = Path("liverpool-brain.db")
XLSX = Path("source/Cadena de Valor y Tickets 30092026/Analisis x Grupo y Año 2.xlsx")

# ---------------------------------------------------------------------------
# Mapeo grupo AMS → componente / sistema existente
# Ampliación del GROUP_MAP original con los 13 grupos nuevos
# ---------------------------------------------------------------------------
# mapping types:
#   'component' → component_id en la tabla components (seeded_by=SUD normalmente)
#   'system'    → source_system genérico (sin component_id específico)
#   'gap'       → sistema sin catalogar (evidencia B8)

NEW_GROUPS = {
    # grupo                              component_id         source_system  mapping
    "AMS BSM COUPA":             (None,                  None,     "gap"),     # Coupa spend mgmt — sistema descubierto
    "AMS CONTROL CXEC":          (None,                  None,     "gap"),     # Control CXEC — 749 tickets previos, sin catálogo
    "AMS DWH/DATA":              (None,                  None,     "gap"),     # DWH — 7,065 tickets previos, sin catálogo
    "AMS ITR":                   (None,                  None,     "gap"),     # IT Request management
    "AMS JIRA":                  (None,                  None,     "gap"),     # Jira ITSM — Accenture tooling
    "AMS MONEDEROS":             (None,                  None,     "gap"),     # Monedero Liverpool — producto FS
    "AMS MYWIZARD":              (None,                  None,     "gap"),     # Accenture MyWizard — AMS automation
    "AMS PARADOX":               (None,                  None,     "gap"),     # HR recruiting AI (Paradox)
    "AMS PRM":                   (None,                  "SAP",    "system"),  # SAP Trade Promotion / PRM
    "AMS RH PORTALES":           (None,                  "SAP",    "system"),  # SAP SuccessFactors portals RH
    "AMS UKG":                   (None,                  None,     "gap"),     # UKG Kronos — workforce mgmt
    "AMS UPF":                   (None,                  None,     "gap"),     # UPF — back-office/payments framework
    "AMS VOICE LINK/VOICE PICKING": (None,               None,     "gap"),     # Voice picking warehouse (Vocollect)
}

# ---------------------------------------------------------------------------
# Mapeo grupo AMS → vc_id (cadena de valor ETB Liverpool)
# Cubre los 87 grupos del Excel nuevo + los ya conocidos
# ---------------------------------------------------------------------------
GROUP_VC = {
    # VC-01 Desarrollo de Oferta — PLM, planificación, surtido, forecasting
    "AMS PA&A":                          "VC-01",
    "AMS PDM":                           "VC-01",
    "AMS PLM":                           "VC-01",
    "AMS SAP PLM":                       "VC-01",
    "AMS SAP PMR":                       "VC-01",
    "AMS SAP F&R":                       "VC-01",
    "AMS PRM":                           "VC-01",   # Trade Promotion Management
    "AMS PARADOX":                       "VC-07",   # HR recruiting — va a fundación

    # VC-02 Cadena de Suministro — WMS, OMS, TMS, compras, recepción
    "AMS SAP EWM (LIV Y SBB)":          "VC-02",
    "AMS SAP MM":                        "VC-02",
    "AMS STERLING OMS (LIV/SBB)":       "VC-02",
    "AMS SOMS (CIBERCOM)":              "VC-02",
    "AMS TMS":                           "VC-02",
    "AMS GESTOR":                        "VC-02",
    "AMS MECALUX":                       "VC-02",
    "AMS RUTEADOR":                      "VC-02",
    "AMS PDTA":                          "VC-02",
    "AMS SIBO":                          "VC-02",
    "AMS VOICE LINK/VOICE PICKING":      "VC-02",   # Voice-directed picking
    "AMS ITR":                           "VC-02",   # Inbound Transfer/Receiving (warehouse)

    # VC-03 Comercio Unificado — POS, facturación, hub pagos, surtido, omnicanal
    "AMS POS":                           "VC-03",
    "AMS FACTURACION":                   "VC-03",
    "AMS FACTURACION EXTENDIDO":         "VC-03",
    "AMS SAP ECC RETAIL":                "VC-03",
    "AMS HUB DE PAGOS":                  "VC-03",
    "AMS VCM":                           "VC-03",
    "AMS ENTRADA UNICA":                 "VC-03",
    "AMS XD APPSURTIDO":                 "VC-03",
    "AMS XSTREAM":                       "VC-03",
    "AMS ICM":                           "VC-03",   # Incentive/Commerce Management
    "AMS PAO":                           "VC-03",   # POS/Apertura Operativa
    "AMS EU SAP":                        "VC-03",   # Entrada Única SAP (POS)

    # VC-04 Canales de Interacción — portales cliente, CRM, atención, servicios
    "AMS MI PUERTO":                     "VC-04",
    "AMS MIPUERTO/AUTOSERVICIO":         "VC-04",
    "AMS CLIENTES":                      "VC-04",
    "AMS SIEBEL CRM":                    "VC-04",
    "AMS SIEBEL MDM":                    "VC-04",
    "AMS SIEBEL SIS":                    "VC-04",
    "AMS PANTALLA UNICA":                "VC-04",
    "AMS PORTAL DE CITAS BT":            "VC-04",
    "AMS PORTAL DE CITAS SL":            "VC-04",
    "AMS PORTAL REPARACIONES N5":        "VC-04",
    "AMS OPTICA":                        "VC-04",
    "AMS SASTRERIA":                     "VC-04",
    "AMS VAS MADE TO ORDER":             "VC-04",
    "AMS VAS REPARACION DE RELOJES Y JOYERIA FINA": "VC-04",
    "AMS TASK MANAGER":                  "VC-04",   # gestión de tareas en tienda
    "AMS BROKER":                        "VC-04",

    # VC-05 Engagement y Marketing — CDP, loyalty, campañas, marketing
    "AMS CDP":                           "VC-05",
    "AMS WORK FRONT Y WFS SBB":          "VC-05",   # WorkFront = gestión campañas mktg
    "AMS MONEDEROS":                     "VC-05",   # Monedero Liverpool — loyalty wallet

    # VC-06 Servicios Financieros — crédito, tarjetas, cobranza, pagos
    "AMS BASE24":                        "VC-06",
    "AMS CREDITO VPL":                   "VC-06",
    "AMS CREDITO VPL SATELITES":         "VC-06",
    "AMS CYBER":                         "VC-06",   # Cyberfinancial — cobranza
    "AMS CONTROL DIGITAL (FICO APM)":    "VC-06",
    "AMS FICO CONTROL DIGITAL":          "VC-06",
    "AMS FICO DMPS":                     "VC-06",   # Debt Mgmt & Payment Solutions
    "AMS FICO PEGA":                     "VC-06",
    "AMS FICO TRIAD":                    "VC-06",
    "AMS DISPOSICION DE EFECTIVO":       "VC-06",
    "AMS PRESTAMOS PERSONALES":          "VC-06",
    "AMS PRESTAMOS/DISP EFECTIVO":       "VC-06",

    # VC-07 Fundación Empresarial — ERP, RH, IT ops, facilities, procurement
    "AMS SAP ECC FI":                    "VC-07",
    "AMS SAP ECC INMOBILIARIA":          "VC-07",
    "AMS SAP ECC PM MTTO":              "VC-07",
    "AMS SAP S4H SBB":                  "VC-07",
    "AMS SAP FIORI":                     "VC-07",
    "AMS SSFF LIV Y SBB":               "VC-07",   # SuccessFactors
    "AMS RH NOMINA":                     "VC-07",
    "AMS RH PORTALES":                   "VC-07",
    "AMS APIGEE":                        "VC-07",   # API mgmt — fundación plataforma
    "AMS BTP":                           "VC-07",   # SAP BTP — plataforma tecnológica
    "AMS CHERWELL":                      "VC-07",   # ITSM
    "AMS BSM COUPA":                     "VC-07",   # Coupa — gestión de gasto
    "AMS JIRA":                          "VC-07",   # Jira — gestión de proyectos IT
    "AMS MYWIZARD":                      "VC-07",   # Accenture AMS automation
    "AMS UKG":                           "VC-07",   # Kronos — workforce management
    "AMS UPF":                           "VC-07",   # Unified payables framework

    # VC-08 Fundación de Información — DWH, BI, reporting, consolidación
    "AMS SAP BW LIV/ SAP BW PDM":       "VC-08",
    "AMS SAP BW PMR SAP BO":            "VC-08",
    "AMS SAP BW4 SBB/BO HIBRIDO":       "VC-08",
    "AMS SAP BPC":                       "VC-08",   # Business Planning & Consolidation
    "AMS POWER BI":                      "VC-08",
    "AMS DWH/DATA":                      "VC-08",   # Data warehouse — sistema descubierto
    "AMS CONTROL CXEC":                  "VC-08",   # Control reporting CXEC

    # VC-09 Analítica e Inteligencia — data science, advanced analytics, ML
    "AMS SAS":                           "VC-09",
}

# ---------------------------------------------------------------------------
# Component_id mapping para grupos que tienen SUD o sistema identificado
# Basado en los slugs de sud_systems + source conocida
# ---------------------------------------------------------------------------
GROUP_COMPONENT = {
    # Ya existentes (75 de 87) — los nuevos van como gap/system
    "AMS APIGEE":            ("SUD-apigee" if False else None, "Apigee",  "system"),
    "AMS BASE24":            (None,                    "Base24",           "system"),
    "AMS BROKER":            (None,                    None,               "gap"),
    "AMS BTP":               (None,                    "SAP",              "system"),
    "AMS CDP":               ("SUD-cdp",               None,               "component"),
    "AMS CHERWELL":          ("SUD-cherwell",           None,               "component"),
    "AMS CLIENTES":          (None,                    None,               "gap"),
    "AMS CONTROL DIGITAL (FICO APM)": (None,           "FICO-TRIAD",       "system"),
    "AMS CREDITO VPL":       (None,                    "VPL-Vision-Plus",  "system"),
    "AMS CREDITO VPL SATELITES": (None,                "VPL-Vision-Plus",  "system"),
    "AMS CYBER":             (None,                    "Cyberfinancial",   "system"),
    "AMS DISPOSICION DE EFECTIVO": ("SUD-disposicion-medios-digitales", None, "component"),
    "AMS ENTRADA UNICA":     (None,                    None,               "gap"),
    "AMS EU SAP":            (None,                    "SAP",              "system"),
    "AMS FACTURACION":       (None,                    "SAP",              "system"),
    "AMS FACTURACION EXTENDIDO": ("SUD-opentext-exstream", None,           "component"),
    "AMS FICO CONTROL DIGITAL": (None,                 "FICO-TRIAD",       "system"),
    "AMS FICO DMPS":         (None,                    "FICO-TRIAD",       "system"),
    "AMS FICO PEGA":         (None,                    "FICO-TRIAD",       "system"),
    "AMS FICO TRIAD":        (None,                    "FICO-TRIAD",       "system"),
    "AMS GESTOR":            ("SUD-gestor-4pl",         None,               "component"),
    "AMS HUB DE PAGOS":      ("SUD-hub-de-pagos",       None,               "component"),
    "AMS ICM":               ("SUD-icm",                None,               "component"),
    "AMS MECALUX":           ("SUD-mecalux",             None,               "component"),
    "AMS MI PUERTO":         ("SUD-mipuerto",            None,               "component"),
    "AMS MIPUERTO/AUTOSERVICIO": ("SUD-mipuerto",        None,               "component"),
    "AMS OPTICA":            ("SUD-optica",              None,               "component"),
    "AMS PA&A":              ("SUD-paa",                 None,               "component"),
    "AMS PANTALLA UNICA":    ("SUD-pantalla-unica",      None,               "component"),
    "AMS PAO":               ("SUD-pao",                 None,               "component"),
    "AMS PDM":               ("SUD-sap-pdm-liv",         None,               "component"),
    "AMS PDTA":              (None,                     None,               "gap"),
    "AMS PLM":               ("SUD-plm",                 None,               "component"),
    "AMS PORTAL DE CITAS BT": ("SUD-portal-de-citas-bt", None,              "component"),
    "AMS PORTAL DE CITAS SL": ("SUD-portal-citas-softline-plan-n5", None,   "component"),
    "AMS PORTAL REPARACIONES N5": ("SUD-reparaciones",   None,               "component"),
    "AMS POS":               (None,                     "Bridgecore",       "system"),
    "AMS POWER BI":          ("SUD-power-bi",             None,               "component"),
    "AMS PRESTAMOS PERSONALES": ("SUD-prestamos-personales", None,           "component"),
    "AMS PRESTAMOS/DISP EFECTIVO": ("SUD-prestamos-personales", None,        "component"),
    "AMS RH NOMINA":         ("SUD-sap-nomina",           None,               "component"),
    "AMS RUTEADOR":          (None,                     None,               "gap"),
    "AMS SAP BPC":           (None,                     "SAP",              "system"),
    "AMS SAP BW LIV/ SAP BW PDM": ("SUD-sap-bw-liv",   None,               "component"),
    "AMS SAP BW PMR SAP BO": ("SUD-sap-bw-pdm",         None,               "component"),
    "AMS SAP BW4 SBB/BO HIBRIDO": ("SUD-sap-bw-hibrido", None,             "component"),
    "AMS SAP ECC FI":        (None,                     "SAP",              "system"),
    "AMS SAP ECC INMOBILIARIA": ("SUD-sap-inmobiliaria", None,              "component"),
    "AMS SAP ECC PM MTTO":   (None,                     "SAP",              "system"),
    "AMS SAP ECC RETAIL":    ("SUD-sap-ecc-retail",      None,               "component"),
    "AMS SAP EWM (LIV Y SBB)": ("SUD-sap-ewm",           None,               "component"),
    "AMS SAP F&R":           (None,                     "SAP",              "system"),
    "AMS SAP FIORI":         (None,                     "SAP",              "system"),
    "AMS SAP MM":            (None,                     "SAP",              "system"),
    "AMS SAP PLM":           ("SUD-plm",                 None,               "component"),
    "AMS SAP PMR":           (None,                     "SAP",              "system"),
    "AMS SAP S4H SBB":       (None,                     "SAP",              "system"),
    "AMS SAS":               ("SUD-sas",                 None,               "component"),
    "AMS SASTRERIA":         ("SUD-sastreria",            None,               "component"),
    "AMS SIBO":              ("SUD-sibo",                 None,               "component"),
    "AMS SIEBEL CRM":        ("SUD-crm-siebel",           None,               "component"),
    "AMS SIEBEL MDM":        ("SUD-crm-siebel",           None,               "component"),
    "AMS SIEBEL SIS":        ("SUD-crm-siebel",           None,               "component"),
    "AMS SOMS (CIBERCOM)":   (None,                     "Sterling-OMS",     "system"),
    "AMS SSFF LIV Y SBB":   (None,                     "SAP",              "system"),
    "AMS STERLING OMS (LIV/SBB)": (None,               "Sterling-OMS",     "system"),
    "AMS TASK MANAGER":      ("SUD-task-manager",         None,               "component"),
    "AMS TMS":               ("SUD-tms-plan-n5",          None,               "component"),
    "AMS VAS MADE TO ORDER": ("SUD-vas-made-to-order",    None,               "component"),
    "AMS VAS REPARACION DE RELOJES Y JOYERIA FINA": ("SUD-vas-reparaciones", None, "component"),
    "AMS VCM":               ("SUD-vcm",                  None,               "component"),
    "AMS WORK FRONT Y WFS SBB": ("SUD-work-front",        None,               "component"),
    "AMS XD APPSURTIDO":     ("SUD-xd-app-surtido",       None,               "component"),
    "AMS XSTREAM":           (None,                     None,               "gap"),
    # 13 nuevos
    "AMS BSM COUPA":          (None,                    None,               "gap"),
    "AMS CONTROL CXEC":       (None,                    None,               "gap"),
    "AMS DWH/DATA":           (None,                    None,               "gap"),
    "AMS ITR":                (None,                    None,               "gap"),
    "AMS JIRA":               (None,                    None,               "gap"),
    "AMS MONEDEROS":          (None,                    None,               "gap"),
    "AMS MYWIZARD":           (None,                    None,               "gap"),
    "AMS PARADOX":            (None,                    None,               "gap"),
    "AMS PRM":                (None,                    "SAP",              "system"),
    "AMS RH PORTALES":        (None,                    "SAP",              "system"),
    "AMS UKG":                (None,                    None,               "gap"),
    "AMS UPF":                (None,                    None,               "gap"),
    "AMS VOICE LINK/VOICE PICKING": (None,              None,               "gap"),
}


def load(conn):
    c = conn.cursor()

    # ------------------------------------------------------------------
    # 1. Crear tabla ams_yearly — desglose anual por grupo AMS
    # ------------------------------------------------------------------
    c.execute("DROP TABLE IF EXISTS ams_yearly")
    c.execute("""
        CREATE TABLE ams_yearly (
            group_name   TEXT NOT NULL,
            year         INTEGER NOT NULL,
            tickets      INTEGER DEFAULT 0,
            mediana_h    REAL,            -- mediana de tiempo de atención en horas
            p90_h        REAL,            -- percentil 90 de tiempo de atención
            p1_count     INTEGER DEFAULT 0,  -- tickets prioridad P1 (Crítica)
            p2_count     INTEGER DEFAULT 0,  -- tickets prioridad P2 (Alta)
            criticality_pct REAL,         -- proporción P1+P2 sobre total (P1&P2 del Excel)
            PRIMARY KEY (group_name, year)
        )
    """)
    print("✓ Tabla ams_yearly creada")

    # ------------------------------------------------------------------
    # 2. Agregar columna vc_id a ams_groups (idempotente)
    # ------------------------------------------------------------------
    existing_cols = [r[1] for r in c.execute("PRAGMA table_info(ams_groups)").fetchall()]
    if "vc_id" not in existing_cols:
        c.execute("ALTER TABLE ams_groups ADD COLUMN vc_id TEXT")
        print("✓ Columna vc_id agregada a ams_groups")
    else:
        print("✓ Columna vc_id ya existe en ams_groups")

    # ------------------------------------------------------------------
    # 3. Agregar columna vc_id a ams_group_component (idempotente)
    # ------------------------------------------------------------------
    existing_cols2 = [r[1] for r in c.execute("PRAGMA table_info(ams_group_component)").fetchall()]
    if "vc_id" not in existing_cols2:
        c.execute("ALTER TABLE ams_group_component ADD COLUMN vc_id TEXT")
        print("✓ Columna vc_id agregada a ams_group_component")
    else:
        print("✓ Columna vc_id ya existe en ams_group_component")

    # ------------------------------------------------------------------
    # 4. Cargar datos del Excel a ams_yearly
    # ------------------------------------------------------------------
    wb = openpyxl.load_workbook(str(XLSX), data_only=True)
    ws = wb["Sheet1"]
    rows = list(ws.iter_rows(min_row=2, values_only=True))

    inserted = 0
    for row in rows:
        group, year, tickets, mediana, p90, p1, p2, crit = row
        if not group or not year:
            continue
        c.execute("""
            INSERT OR REPLACE INTO ams_yearly
            (group_name, year, tickets, mediana_h, p90_h, p1_count, p2_count, criticality_pct)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            str(group).strip(),
            int(year),
            int(tickets) if tickets is not None else 0,
            float(mediana) if mediana is not None else None,
            float(p90) if p90 is not None else None,
            int(p1) if p1 is not None else 0,
            int(p2) if p2 is not None else 0,
            float(crit) if crit is not None else 0.0,
        ))
        inserted += 1

    print(f"✓ {inserted} filas cargadas en ams_yearly")

    # ------------------------------------------------------------------
    # 5. Actualizar vc_id en ams_groups para todos los grupos
    # ------------------------------------------------------------------
    vc_updated = 0
    for group_name, vc_id in GROUP_VC.items():
        c.execute(
            "UPDATE ams_groups SET vc_id = ? WHERE group_name = ?",
            (vc_id, group_name)
        )
        if c.rowcount > 0:
            vc_updated += 1

    print(f"✓ vc_id actualizado en ams_groups: {vc_updated} grupos")

    # ------------------------------------------------------------------
    # 6. Insertar / actualizar ams_group_component con los 13 nuevos
    #    y actualizar vc_id en todos
    # ------------------------------------------------------------------
    new_inserted = 0
    vc_comp_updated = 0

    # Primero los 13 nuevos que no estaban en ams_group_component
    # Obtener totales del Excel para calcular tickets anuales agregados
    totals_from_excel = {}
    for row in rows:
        group, year, tickets = row[0], row[1], row[2]
        if group:
            totals_from_excel[str(group).strip()] = (
                totals_from_excel.get(str(group).strip(), 0) + (int(tickets) if tickets else 0)
            )

    for group_name, (comp_id, src_sys, mapping) in GROUP_COMPONENT.items():
        # Verificar si ya existe en ams_group_component
        existing = c.execute(
            "SELECT group_name FROM ams_group_component WHERE group_name = ?",
            (group_name,)
        ).fetchone()

        if not existing:
            total_tickets = totals_from_excel.get(group_name, 0)
            c.execute("""
                INSERT INTO ams_group_component
                (group_name, component_id, source_system, tickets, mapping, vc_id)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (
                group_name, comp_id, src_sys, total_tickets, mapping,
                GROUP_VC.get(group_name)
            ))
            new_inserted += 1

        # Actualizar vc_id en todos (nuevos y existentes)
        vc = GROUP_VC.get(group_name)
        if vc:
            c.execute(
                "UPDATE ams_group_component SET vc_id = ? WHERE group_name = ?",
                (vc, group_name)
            )
            if c.rowcount > 0:
                vc_comp_updated += 1

    print(f"✓ {new_inserted} grupos nuevos insertados en ams_group_component")
    print(f"✓ vc_id actualizado en ams_group_component: {vc_comp_updated} grupos")

    # ------------------------------------------------------------------
    # 7. Actualizar ams_groups con nuevos grupos que no existían antes
    #    (para que ams_groups y ams_group_component estén sincronizados)
    # ------------------------------------------------------------------
    new_ag = 0
    for group_name in GROUP_COMPONENT:
        existing = c.execute(
            "SELECT group_name FROM ams_groups WHERE group_name = ?",
            (group_name,)
        ).fetchone()
        if not existing:
            total = totals_from_excel.get(group_name, 0)
            vc = GROUP_VC.get(group_name)
            c.execute("""
                INSERT INTO ams_groups (group_name, tickets, is_noise, vc_id)
                VALUES (?, ?, 0, ?)
            """, (group_name, total, vc))
            new_ag += 1

    if new_ag:
        print(f"✓ {new_ag} grupos nuevos insertados en ams_groups")

    # ------------------------------------------------------------------
    # 8. Resumen de cobertura por eslabón
    # ------------------------------------------------------------------
    print()
    print("─── Tickets por eslabón ETB (acumulado 2024-2026) ───")
    vc_stats = c.execute("""
        SELECT agc.vc_id, vc.name,
               COUNT(DISTINCT agc.group_name) AS grupos,
               SUM(ay.tickets) AS total_tickets
        FROM ams_group_component agc
        JOIN ams_yearly ay ON ay.group_name = agc.group_name
        JOIN value_chain vc ON vc.id = agc.vc_id
        WHERE agc.vc_id IS NOT NULL
        GROUP BY agc.vc_id
        ORDER BY total_tickets DESC
    """).fetchall()

    for vc_id, vc_name, grupos, tickets in vc_stats:
        print(f"  {vc_id}  {vc_name[:35]:<37}  {grupos:>3} grupos  {tickets:>7,} tickets")

    # ------------------------------------------------------------------
    # 9. Grupos sin vc_id asignado (gaps de ontología)
    # ------------------------------------------------------------------
    unmapped = c.execute("""
        SELECT DISTINCT agc.group_name FROM ams_group_component agc
        LEFT JOIN ams_groups ag ON ag.group_name = agc.group_name
        WHERE agc.vc_id IS NULL AND COALESCE(ag.is_noise, 0) = 0
        ORDER BY agc.group_name
    """).fetchall()
    if unmapped:
        print()
        print(f"⚠ Grupos sin vc_id ({len(unmapped)}):")
        for row in unmapped:
            print(f"  {row[0]}")

    # ------------------------------------------------------------------
    # 10. Actualizar brain_meta
    # ------------------------------------------------------------------
    yearly_rows = c.execute("SELECT COUNT(*) FROM ams_yearly").fetchone()[0]
    distinct_groups = c.execute("SELECT COUNT(DISTINCT group_name) FROM ams_yearly").fetchone()[0]
    mapped_vc = c.execute(
        "SELECT COUNT(DISTINCT group_name) FROM ams_group_component WHERE vc_id IS NOT NULL"
    ).fetchone()[0]

    c.execute("""
        INSERT OR REPLACE INTO brain_meta (key, value)
        VALUES ('ams_yearly_rows', ?)
    """, (str(yearly_rows),))
    c.execute("""
        INSERT OR REPLACE INTO brain_meta (key, value)
        VALUES ('ams_groups_with_vc', ?)
    """, (str(mapped_vc),))
    c.execute("""
        INSERT OR REPLACE INTO brain_meta (key, value)
        VALUES ('ams_yearly_groups', ?)
    """, (str(distinct_groups),))
    c.execute("""
        INSERT OR REPLACE INTO brain_meta (key, value)
        VALUES ('ams_yearly_source', 'Cadena de Valor y Tickets 30092026/Analisis x Grupo y Año 2.xlsx')
    """)

    conn.commit()
    print()
    print(f"✓ brain_meta actualizado ({yearly_rows} filas anuales, {distinct_groups} grupos, {mapped_vc} con vc_id)")


def main():
    if not XLSX.exists():
        print(f"ERROR: No se encuentra {XLSX}")
        return
    conn = sqlite3.connect(str(DB))
    try:
        load(conn)
        print()
        print("✓ load-cadena-valor-tickets completado")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
