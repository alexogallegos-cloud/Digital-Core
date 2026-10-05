#!/usr/bin/env python3
"""
load-ams-applications.py — Carga el catálogo oficial AMS de Liverpool al brain.

Fuente: source/AMS Info/AMS_Applications 1.xlsx
  - 78 aplicaciones con dominio de negocio y flag Apigee/BTP
  - Columna "Nombre Anterior" documenta renombramientos oficiales

Acciones:
  1. Crea tabla `ams_applications` con las 78 apps
  2. Mapea 7 dominios AMS → R01-R10 (retail domains) → VC-01..09
  3. Cruza contra `components` existentes (fuzzy por source_system / name)
  4. Registra apps sin match como nuevos components (Regla B8 — evidencia AMS)

Ejecutar desde liverpool-brain/:
    python generators/load-ams-applications.py
"""

import re
import sqlite3
import shutil
from pathlib import Path
from datetime import date

BASE_DIR  = Path(__file__).parent.parent
DB_PATH   = BASE_DIR / "liverpool-brain.db"
XL_PATH   = BASE_DIR / "source" / "AMS Info" / "AMS_Applications 1.xlsx"

# ── Mapeo dominios AMS → (domain_id retail, vc_id ETB) ─────────────────────
DOMAIN_MAP = {
    "Retail, merchandising y comercial":    ("R01", "VC-01"),
    "Cadena de suministro y logística":     ("R04", "VC-02"),
    "Tienda y servicios postventa":         ("R06", "VC-03"),
    "Canal digital y cliente":              ("R05", "VC-04"),
    "Servicios financieros":                ("R03", "VC-06"),
    "Backoffice y corporativo":             ("R07", "VC-07"),
    "Datos, analítica e integración":       ("R09", "VC-08"),
}

# ── 78 aplicaciones oficiales AMS ───────────────────────────────────────────
# (app_name, dominio_ams, in_scope_apigee_btp, nombre_anterior)
APPS = [
    ("ACC",                                    "Cadena de suministro y logística",  None,         "CXEC"),
    ("APIGEE",                                 "Datos, analítica e integración",    None,         None),
    ("APARTA+",                                "Tienda y servicios postventa",       "MIDDLEWARE", None),
    ("APPLE & SAMSUNG CARE",                   "Tienda y servicios postventa",       "MIDDLEWARE", None),
    ("BOVEDA DIGITAL",                         "Servicios financieros",              "MIDDLEWARE", None),
    ("GESTOR DE ACLARACIONES",                 "Servicios financieros",              "MIDDLEWARE", None),
    ("BROKER",                                 "Datos, analítica e integración",     None,         None),
    ("BSM COUPA",                              "Backoffice y corporativo",           None,         None),
    ("BTP",                                    "Cadena de suministro y logística",   None,         None),
    ("CDP",                                    "Canal digital y cliente",            None,         None),
    ("CHERWELL",                               "Cadena de suministro y logística",   None,         None),
    ("CYBER",                                  "Servicios financieros",              None,         None),
    ("DWH/DATA",                               "Cadena de suministro y logística",   None,         None),
    ("APACHE NIFI",                            "Cadena de suministro y logística",   None,         None),
    ("CIFRAS DE CONTROL",                      "Cadena de suministro y logística",   None,         None),
    ("PIF POR NOMINA",                         "Cadena de suministro y logística",   None,         None),
    ("ENTRADA UNICA",                          "Backoffice y corporativo",           None,         None),
    ("EU SAP",                                 "Backoffice y corporativo",           None,         None),
    ("FACTURACION",                            "Servicios financieros",              None,         None),
    ("PEGA",                                   "Servicios financieros",              None,         "FICO APM"),
    ("FICO DMPS",                              "Servicios financieros",              None,         None),
    ("FICO TRIAD",                             "Servicios financieros",              None,         None),
    ("GESTOR 4PL",                             "Cadena de suministro y logística",   None,         None),
    ("HUB DE PAGOS",                           "Servicios financieros",              None,         None),
    ("ICM",                                    "Backoffice y corporativo",           None,         None),
    ("ITR",                                    "Cadena de suministro y logística",   None,         None),
    ("MI PUERTO",                              "Canal digital y cliente",            "MIDDLEWARE", None),
    ("MIPUERTO/AUTOSERVICIO",                  "Canal digital y cliente",            "MIDDLEWARE", None),
    ("OPTICA",                                 "Retail, merchandising y comercial",  None,         None),
    ("PA&A",                                   "Retail, merchandising y comercial",  None,         None),
    ("PANTALLA UNICA",                         "Backoffice y corporativo",           None,         None),
    ("PAO",                                    "Cadena de suministro y logística",   None,         None),
    ("PDM",                                    "Backoffice y corporativo",           None,         None),
    ("PDTA",                                   "Backoffice y corporativo",           None,         None),
    ("PIM",                                    "Backoffice y corporativo",           None,         None),
    ("PORTAL DE CITAS BT",                     "Cadena de suministro y logística",   None,         None),
    ("PORTAL DE CITAS SL",                     "Cadena de suministro y logística",   None,         None),
    ("PORTAL REPARACIONES N5",                 "Cadena de suministro y logística",   None,         None),
    ("POWER BI",                               "Backoffice y corporativo",           None,         None),
    ("PRESTAMOS/DISP EFECTIVO",                "Servicios financieros",              None,         None),
    ("RH NOMINA",                              "Backoffice y corporativo",           None,         None),
    ("RH PORTALES",                            "Backoffice y corporativo",           None,         None),
    ("SIMPLI ROUTE",                           "Cadena de suministro y logística",   None,         None),
    ("SAP BPC",                                "Backoffice y corporativo",           None,         None),
    ("SAP BW LIV/ SAP BW PDM",                "Retail, merchandising y comercial",  None,         None),
    ("SAP BW PMR SAP BO",                      "Retail, merchandising y comercial",  None,         None),
    ("SAP BW4 SBB/BO HIBRIDO",                "Retail, merchandising y comercial",  None,         None),
    ("SAP ECC FI",                             "Backoffice y corporativo",           None,         None),
    ("SAP ECC INMOBILIARIA",                   "Backoffice y corporativo",           None,         None),
    ("SAP ECC PM MTTO",                        "Backoffice y corporativo",           None,         None),
    ("SAP ECC RETAIL",                         "Retail, merchandising y comercial",  None,         None),
    ("SAP EWM (LIV Y SBB)",                   "Cadena de suministro y logística",   None,         None),
    ("SAP FIORI",                              "Backoffice y corporativo",           None,         None),
    ("SAP MM",                                 "Backoffice y corporativo",           None,         None),
    ("SAP PLM",                                "Retail, merchandising y comercial",  None,         None),
    ("SAP PMR",                                "Retail, merchandising y comercial",  None,         None),
    ("SAP PUBLICIDAD",                         "Backoffice y corporativo",           None,         None),
    ("SAP S4H SBB",                            "Backoffice y corporativo",           None,         None),
    ("SAS",                                    "Servicios financieros",              None,         None),
    ("SASTRERIA",                              "Retail, merchandising y comercial",  None,         None),
    ("SIBO",                                   "Retail, merchandising y comercial",  None,         None),
    ("SIEBEL CRM",                             "Servicios financieros",              None,         None),
    ("SIEBEL MDM",                             "Servicios financieros",              None,         None),
    ("SIEBEL SIS",                             "Servicios financieros",              None,         None),
    ("SISTEMA DE UNIFORMES",                   "Cadena de suministro y logística",   None,         None),
    ("SRM",                                    "Backoffice y corporativo",           None,         None),
    ("SSFF LIV Y SBB",                        "Backoffice y corporativo",           None,         None),
    ("STERLING OMS (LIV/SBB)",                "Cadena de suministro y logística",   None,         None),
    ("TASK MANAGER",                           "Backoffice y corporativo",           None,         None),
    ("TMS",                                    "Cadena de suministro y logística",   None,         None),
    ("UKG",                                    "Backoffice y corporativo",           "MIDDLEWARE", None),
    ("VAS MADE TO ORDER",                      "Retail, merchandising y comercial",  None,         None),
    ("VAS REPARACION DE RELOJES Y JOYERIA FINA","Retail, merchandising y comercial",None,         None),
    ("VCM",                                    "Retail, merchandising y comercial",  None,         None),
    ("VOCOLLECT",                              "Cadena de suministro y logística",   None,         None),
    ("WORK FRONT Y WFS SBB",                  "Backoffice y corporativo",           None,         None),
    ("XD APPSURTIDO",                          "Cadena de suministro y logística",   None,         None),
    ("EXSTREAM",                               "Servicios financieros",              None,         None),
]

# ── Mapeo explícito AMS app → keywords para cruzar contra source_system ─────
# (solo los casos que no se resuelven por substring automático)
EXPLICIT_MATCH = {
    "ACC":                        ["CXEC", "ACC"],
    "APARTA+":                    ["Aparta", "Apartados"],
    "APPLE & SAMSUNG CARE":       ["Apple", "Samsung", "LivCare"],
    "BOVEDA DIGITAL":             ["Boveda", "Bóveda"],
    "CYBER":                      ["Cyberfinancial", "Cyber"],
    "DWH/DATA":                   ["DWH/DATA", "AMS DWH"],   # evitar match con CDP "Customer Data Platform"
    "ENTRADA UNICA":              ["Entrada Unica", "PIP"],
    "EXSTREAM":                   ["Exstream", "OpenText"],
    "FACTURACION":                ["Facturación", "Facturacion"],
    "FICO TRIAD":                 ["FICO-TRIAD", "FICO TRIAD", "Triad"],
    "GESTOR 4PL":                 ["Gestor4PL", "Gestor 4PL"],
    "GESTOR DE ACLARACIONES":     ["Aclaraciones"],
    "ICM":                        ["ICM", "Incentive"],
    "MI PUERTO":                  ["Mi puerto", "Mipuerto", "MiPuerto"],
    "MIPUERTO/AUTOSERVICIO":      ["Mi puerto", "Mipuerto", "MiPuerto"],
    "OPTICA":                     ["Óptica", "Optica"],
    "PA&A":                       ["PA&A", "o9 MFP", "Assortment"],
    "PAO":                        ["PAO", "Administración de Órdenes"],
    "PDM":                        ["PDM", "Product Data"],
    "PDTA":                       ["PDTA"],
    "PIM":                        ["PIM-STEP", "PIM", "Stibo"],
    "PORTAL DE CITAS BT":         ["Portal de Citas BT"],
    "PORTAL DE CITAS SL":         ["Portal de Citas Softline", "Citas SL"],
    "PORTAL REPARACIONES N5":     ["Portal de Reparaciones"],
    "POWER BI":                   ["Power BI", "PBI"],
    "PRESTAMOS/DISP EFECTIVO":    ["Préstamos", "Prestamos", "Disposición de Efectivo"],
    "RH NOMINA":                  ["Nomina", "HCM"],
    "SAP BW LIV/ SAP BW PDM":    ["SAP BW LIV", "SAP BW PDM"],
    "SAP BW PMR SAP BO":          ["SAP BW PMR", "SAP BO", "BusinessObjects"],
    "SAP BW4 SBB/BO HIBRIDO":    ["SAP BW4", "BW Híbrido", "BW Hibrido"],
    "SAP ECC INMOBILIARIA":       ["Inmobiliaria", "SAP RE"],
    "SAP ECC PM MTTO":            ["PM MTTO", "Mantenimiento"],
    "SAP ECC RETAIL":             ["SAP ECC Retail"],
    "SAP EWM (LIV Y SBB)":       ["SAP EWM", "EWM"],
    "SAP PLM":                    ["PLM", "Centric"],
    "SAP PMR":                    ["PMR"],
    "SAP PUBLICIDAD":             ["SAP Publicidad", "Publicidad"],
    "SAP S4H SBB":                ["SAP S4H", "S/4HANA SBB"],   # evitar match con OMS SBB
    "SAS":                        ["SAS ("],   # SAS analytics — evitar match con "Sastreria"
    "SASTRERIA":                  ["Sastreria", "Sastrería"],
    "SIBO":                       ["SIBO"],
    "SIEBEL CRM":                 ["Siebel CRM"],
    "SIEBEL MDM":                 ["Siebel MDM"],
    "SIMPLI ROUTE":               ["Simpli Route", "Simpliroute", "Ruteador"],
    "STERLING OMS (LIV/SBB)":    ["Sterling", "OMS", "Order Management"],
    "TASK MANAGER":               ["Task Manager"],
    "TMS":                        ["TMS", "Transportation"],
    "UKG":                        ["UKG"],
    "VAS MADE TO ORDER":          ["VAS Made To Order", "MTO"],
    "VAS REPARACION DE RELOJES Y JOYERIA FINA": ["VAS Reparaci", "Reparaciones de Relojes"],
    "VCM":                        ["VCM", "Verificacion"],
    "VOCOLLECT":                  ["Vocollect"],
    "WORK FRONT Y WFS SBB":      ["Work Front", "WorkFront"],
    "XD APPSURTIDO":              ["XD", "AppSurtido", "App Surtido"],
}


def normalize(s):
    """Lowercase + sin acentos + sin especiales para matching."""
    s = (s or "").lower()
    for a, b in [("á","a"),("é","e"),("í","i"),("ó","o"),("ú","u"),("ñ","n")]:
        s = s.replace(a, b)
    return re.sub(r"[^a-z0-9 ]", " ", s)


def find_match(app_name, sources):
    """Busca la app en la lista de source_systems existentes. Devuelve lista de matches."""
    keywords = EXPLICIT_MATCH.get(app_name, [app_name])
    hits = []
    for src in sources:
        src_norm = normalize(src)
        for kw in keywords:
            if normalize(kw) in src_norm:
                if src not in hits:
                    hits.append(src)
                break
    return hits


def main():
    if not DB_PATH.exists():
        print("ERROR: liverpool-brain.db no encontrado.")
        return

    conn = sqlite3.connect(DB_PATH)
    c    = conn.cursor()
    today = str(date.today())

    # ── 1. Crear / recrear tabla ams_applications ────────────────────────────
    c.execute("DROP TABLE IF EXISTS ams_applications")
    c.execute("""
        CREATE TABLE ams_applications (
            app_id          TEXT PRIMARY KEY,
            app_name        TEXT NOT NULL,
            ams_domain      TEXT,
            domain_id       TEXT,
            vc_id           TEXT,
            in_scope_apigee INTEGER DEFAULT 0,
            nombre_anterior TEXT,
            matched_sources TEXT,
            is_new          INTEGER DEFAULT 0,
            component_id    TEXT,
            loaded_at       TEXT DEFAULT (date('now'))
        )
    """)

    # ── 2. Cargar source_systems existentes en components ────────────────────
    existing_sources = [
        r[0] for r in c.execute("SELECT DISTINCT source_system FROM components WHERE source_system IS NOT NULL").fetchall()
    ]
    existing_names = [
        (r[0], r[1]) for r in c.execute("SELECT id, name FROM components").fetchall()
    ]

    # ── 3. Procesar cada app ─────────────────────────────────────────────────
    matched     = []
    new_apps    = []
    seq         = 0

    for app_name, ams_domain, in_scope, nombre_ant in APPS:
        seq += 1
        app_id   = f"LIV-AMS-{seq:03d}"
        domain_id, vc_id = DOMAIN_MAP.get(ams_domain, ("R07", "VC-07"))
        is_scope = 1 if in_scope else 0

        # Buscar match en source_systems
        hits = find_match(app_name, existing_sources)

        # Si no hay match en source_system, buscar en nombres de components
        if not hits:
            kws = EXPLICIT_MATCH.get(app_name, [app_name])
            name_hits = []
            for cid, cname in existing_names:
                for kw in kws:
                    if normalize(kw) in normalize(cname):
                        if cname not in name_hits:
                            name_hits.append(cname)
                        break
            if name_hits:
                hits = name_hits

        matched_str = "; ".join(hits) if hits else None
        is_new      = 0 if hits else 1

        c.execute("""
            INSERT INTO ams_applications
              (app_id, app_name, ams_domain, domain_id, vc_id,
               in_scope_apigee, nombre_anterior, matched_sources, is_new, loaded_at)
            VALUES (?,?,?,?,?,?,?,?,?,?)
        """, (app_id, app_name, ams_domain, domain_id, vc_id,
              is_scope, nombre_ant, matched_str, is_new, today))

        if hits:
            matched.append((app_name, hits))
        else:
            new_apps.append((app_id, app_name, ams_domain, domain_id, vc_id))

    # ── 4. Registrar apps nuevas en components (Regla B8) ────────────────────
    # Obtener el max ID existente LIV-APP-*
    existing_app_ids = [
        r[0] for r in c.execute("SELECT id FROM components WHERE id LIKE 'LIV-APP-%'").fetchall()
    ]
    next_seq = max(
        (int(i.split("-")[-1]) for i in existing_app_ids if i.split("-")[-1].isdigit()),
        default=0
    ) + 1

    for app_id_ams, app_name, ams_domain, domain_id, vc_id in new_apps:
        comp_id = f"LIV-APP-{next_seq:03d}"
        next_seq += 1
        # Determinar togaf_type aproximado
        if ams_domain == "Datos, analítica e integración":
            togaf = "data"
        elif ams_domain == "Cadena de suministro y logística" and app_name in ("BTP","APACHE NIFI","BROKER"):
            togaf = "integration"
        elif ams_domain == "Backoffice y corporativo":
            togaf = "core"
        else:
            togaf = "channels"

        c.execute("""
            INSERT OR IGNORE INTO components
              (id, name, source_system, component_type, domain_id,
               business_name, togaf_type, status, seeded_by)
            VALUES (?,?,?,?,?,?,?,?,?)
        """, (comp_id, app_name, app_name, "application", domain_id,
              app_name.title(), togaf, "discovered",
              "AMS_Applications_1.xlsx"))

        # Actualizar component_id en ams_applications
        c.execute("UPDATE ams_applications SET component_id=? WHERE app_id=?",
                  (comp_id, app_id_ams))

    conn.commit()

    # ── 5. Reporte ────────────────────────────────────────────────────────────
    total   = len(APPS)
    n_match = len(matched)
    n_new   = len(new_apps)

    print(f"\n{'='*60}")
    print(f"  AMS_Applications 1.xlsx — Cargado al brain")
    print(f"{'='*60}")
    print(f"  Total apps AMS         : {total}")
    print(f"  Matches en brain       : {n_match}  ({n_match*100//total}%)")
    print(f"  Apps nuevas (Regla B8) : {n_new}   ({n_new*100//total}%)")
    print()

    print("── MATCHES ────────────────────────────────────────────")
    for app, hits in sorted(matched):
        print(f"  ✓ {app:<40} → {hits[0][:50]}")

    print()
    print("── NUEVAS (Regla B8 — evidencia AMS) ─────────────────")
    for app_id, app, dom, rid, vc in new_apps:
        print(f"  + {app:<40} [{rid} · {vc}]")

    print()
    print("── DOMINIOS AMS → ETB ─────────────────────────────────")
    for dom, (rid, vc) in DOMAIN_MAP.items():
        cnt = sum(1 for a in APPS if a[1] == dom)
        print(f"  {dom:<42} → {rid} · {vc}  ({cnt} apps)")

    print()
    print("── IN SCOPE APIGEE/BTP ────────────────────────────────")
    scope_apps = [(a[0], a[1]) for a in APPS if a[2]]
    for app, dom in scope_apps:
        print(f"  ◈ {app}")

    total_comps = conn.execute("SELECT COUNT(*) FROM components").fetchone()[0]
    print()
    print(f"  Total components (post-carga): {total_comps}")
    print(f"  Tabla ams_applications creada: {total} filas")
    print()

    conn.close()


if __name__ == "__main__":
    main()
