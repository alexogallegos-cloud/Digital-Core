#!/usr/bin/env python3
"""
Liverpool — Carga el análisis de tickets AMS (GenWizard) al digital brain (idempotente).

Fuentes:
  · source/AMS Info/Analisis_Tickets_Liv.xlsx  — 6 hojas de métricas agregadas
  · source/AMS Info/Analisis_Palabras.html     — corpus de 40K tickets (Mes/group/description)

Puebla:
  · ams_groups           — 1 fila por grupo AMS con volumetría y tiempos de atención
  · ams_group_component  — puente grupo AMS -> componente/sistema del brain
  · ticket_recurrence    — patrones recurrentes con ocurrencias y ventana temporal
  · ticket_corpus        — ticket individual (mes, grupo, descripción) + FTS
  · ticket_monthly       — serie mensual por prioridad

Re-ejecutable: borra las tablas de tickets antes de reinsertar.
Correr DESPUÉS de build-liverpool-brain.py y load-sud-to-brain.py.
"""
import json, re, sqlite3, sys
from pathlib import Path

import openpyxl

HERE  = Path(__file__).parent
BRAIN = HERE.parent
DB    = BRAIN / "liverpool-brain.db"
XLSX  = BRAIN / "source" / "AMS Info" / "Analisis_Tickets_Liv.xlsx"
WORDS = BRAIN / "source" / "AMS Info" / "Analisis_Palabras.html"

# ── Grupos que no son aplicaciones: ruido del export ─────────────────────────
NOISE_GROUPS = {"Sin grupo", "FALLA / ERROR", "052", "043",
                "08/10/2026, 03:38:51 PM", None, ""}

# ── Mapeo grupo AMS -> (component_id, source_system) ─────────────────────────
# component_id  : cuando el grupo corresponde a una aplicación catalogada (SUD)
# source_system : cuando el grupo corresponde a un sistema base del dashboard
# Ausente       : gap de inventario — el grupo opera sobre algo no catalogado
GROUP_MAP = {
    # ── aplicaciones con SUD ──────────────────────────────────────────────
    "AMS XD APPSURTIDO":            ("SUD-xd-app-surtido", None),
    "AMS SAP BW LIV/ SAP BW PDM":   ("SUD-sap-bw-liv", None),
    "AMS SAP ECC RETAIL":           ("SUD-sap-ecc-retail", None),
    "AMS SAP EWM (LIV Y SBB)":      ("SUD-sap-ewm", None),
    "AMS STERLING OMS (LIV/SBB)":   ("SUD-oms-liv", None),
    "AMS SAP BW4 SBB/BO HIBRIDO":   ("SUD-sap-bw-hibrido", None),
    "AMS PAO":                      ("SUD-pao", None),
    "AMS GESTOR":                   ("SUD-gestor-4pl", None),
    "AMS OPTICA":                   ("SUD-optica", None),
    "AMS CDP":                      ("SUD-cdp", None),
    "AMS TMS":                      ("SUD-tms-plan-n5", None),
    "AMS MECALUX":                  ("SUD-mecalux", None),
    "AMS VCM":                      ("SUD-vcm", None),
    "AMS SASTRERIA":                ("SUD-sastreria", None),
    "AMS SIBO":                     ("SUD-sibo", None),
    "AMS PORTAL DE CITAS SL":       ("SUD-portal-citas-softline-plan-n5", None),
    "AMS PORTAL DE CITAS BT":       ("SUD-portal-de-citas-bt", None),
    "AMS ENTRADA UNICA":            ("SUD-pip-portal-proveedores", None),
    "AMS EU SAP":                   ("SUD-pip-portal-proveedores", None),
    "AMS HUB DE PAGOS":             ("SUD-hub-de-pagos", None),
    "AMS PANTALLA UNICA":           ("SUD-pantalla-unica", None),
    "AMS PRESTAMOS PERSONALES":     ("SUD-prestamos-personales", None),
    "AMS PRESTAMOS/DISP EFECTIVO":  ("SUD-prestamos-personales", None),
    "AMS DISPOSICION DE EFECTIVO":  ("SUD-disposicion-medios-digitales", None),
    "AMS MI PUERTO":                ("SUD-mipuerto", None),
    "AMS MIPUERTO/AUTOSERVICIO":    ("SUD-mipuerto", None),
    "AMS ICM":                      ("SUD-icm", None),
    "AMS PLM":                      ("SUD-plm", None),
    "AMS SAP PLM":                  ("SUD-plm", None),
    "AMS POWER BI":                 ("SUD-power-bi", None),
    "AMS SAS":                      ("SUD-sas", None),
    "AMS CHERWELL":                 ("SUD-cherwell", None),
    "AMS TASK MANAGER":             ("SUD-task-manager", None),
    "AMS WORK FRONT Y WFS SBB":     ("SUD-work-front", None),
    "AMS PA&A":                     ("SUD-paa", None),
    "AMS RUTEADOR":                 ("SUD-simpli-route", None),
    "AMS PORTAL REPARACIONES N5":   ("SUD-reparaciones", None),
    "AMS VAS REPARACION DE RELOJES Y JOYERIA FINA": ("SUD-vas-reparaciones", None),
    "AMS VAS MADE TO ORDER":        ("SUD-vas-made-to-order", None),
    "AMS SAP ECC INMOBILIARIA":     ("SUD-sap-inmobiliaria", None),
    "AMS RH NOMINA":                ("SUD-sap-nomina", None),
    "AMS PDM":                      ("SUD-sap-pdm-liv", None),
    "AMS SIEBEL CRM":               ("SUD-crm-siebel", None),
    "AMS SIEBEL SIS":               ("SUD-crm-siebel", None),
    "AMS SIEBEL MDM":               ("SUD-crm-siebel", None),
    "AMS XSTREAM":                  ("SUD-opentext-exstream", None),
    "AMS CYBER":                    ("SUD-cyberfinancial", None),
    # ── sistemas base del dashboard ───────────────────────────────────────
    "AMS APIGEE":                   (None, "Apigee"),
    "AMS BASE24":                   (None, "Base24"),
    "AMS CREDITO VPL":              (None, "VPL-Vision-Plus"),
    "AMS CREDITO VPL SATELITES":    (None, "VPL-Vision-Plus"),
    "AMS FICO TRIAD":               (None, "FICO-TRIAD"),
    "AMS CONTROL DIGITAL (FICO APM)": (None, "FICO-TRIAD"),
    "AMS FICO CONTROL DIGITAL":     (None, "FICO-TRIAD"),
    "AMS FICO DMPS":                (None, "FICO-TRIAD"),
    "AMS FICO PEGA":                (None, "FICO-TRIAD"),
    "AMS POS":                      (None, "Bridgecore"),
    "AMS SOMS (CIBERCOM)":          (None, "Mainframe"),
    "AMS CLIENTES":                 (None, "Mainframe"),
    "AMS BROKER":                   (None, "IBM-IIB"),
    "AMS SAP ECC FI":               (None, "SAP"),
    "AMS SAP MM":                   (None, "SAP"),
    "AMS SAP FIORI":                (None, "SAP"),
    "AMS SAP S4H SBB":              (None, "SAP"),
    "AMS SAP PMR":                  (None, "SAP"),
    "AMS SAP BPC":                  (None, "SAP"),
    "AMS SAP ECC PM MTTO":          (None, "SAP"),
    "AMS SAP F&R":                  (None, "SAP"),
    "AMS BTP":                      (None, "SAP"),
    "AMS FACTURACION":              (None, "SAP"),
    "AMS FACTURACION EXTENDIDO":    (None, "SAP"),
    "AMS PDTA":                     (None, "SAP"),
    "AMS SSFF LIV Y SBB":           (None, "SAP"),
    "AMS SAP BW PMR SAP BO":        (None, "SAP-BW"),
}


def clean(v):
    return v.strip() if isinstance(v, str) else v


def sheet_rows(wb, name):
    """Filas de una hoja como dicts, usando la fila 0 como encabezado."""
    ws = wb[name]
    it = ws.iter_rows(values_only=True)
    header = [clean(h) for h in next(it)]
    for row in it:
        yield dict(zip(header, row))


def load_corpus(path: Path):
    """Extrae el array DATA (tickets individuales) del HTML de análisis de palabras."""
    html = path.read_text(encoding="utf-8", errors="replace")
    m = re.search(r"(?:const|var|let)\s+DATA\s*=\s*", html)
    if not m:
        return []
    start = m.end()
    depth = 0; i = start; instr = False; esc = False
    while i < len(html):
        ch = html[i]
        if instr:
            if esc:        esc = False
            elif ch == "\\": esc = True
            elif ch == '"': instr = False
        else:
            if ch == '"':  instr = True
            elif ch == "[": depth += 1
            elif ch == "]":
                depth -= 1
                if depth == 0:
                    return json.loads(html[start:i + 1])
        i += 1
    return []


def main():
    for p in (XLSX, WORDS):
        if not p.exists():
            sys.exit(f"falta la fuente: {p}")

    conn = sqlite3.connect(DB)
    c = conn.cursor()

    for t in ("ams_groups", "ams_group_component", "ticket_recurrence",
              "ticket_corpus", "ticket_monthly", "ticket_corpus_fts"):
        c.execute(f"DROP TABLE IF EXISTS {t}")

    c.execute("""CREATE TABLE ams_groups (
        group_name TEXT PRIMARY KEY, tickets INT, median_hours REAL, p90_hours REAL,
        recurrent INT, prio_critica INT, prio_alta INT, is_noise INT DEFAULT 0)""")
    c.execute("""CREATE TABLE ams_group_component (
        group_name TEXT PRIMARY KEY, component_id TEXT, source_system TEXT,
        tickets INT, mapping TEXT)""")
    c.execute("""CREATE TABLE ticket_recurrence (
        id INTEGER PRIMARY KEY AUTOINCREMENT, recurrence_key TEXT, group_name TEXT,
        occurrences INT, first_date TEXT, last_date TEXT, priorities TEXT)""")
    c.execute("""CREATE TABLE ticket_corpus (
        id INTEGER PRIMARY KEY AUTOINCREMENT, month TEXT, group_name TEXT, description TEXT)""")
    c.execute("""CREATE TABLE ticket_monthly (
        month TEXT, priority TEXT, tickets INT, median_hours REAL)""")

    wb = openpyxl.load_workbook(XLSX, read_only=True, data_only=True)

    # ── grupos AMS + mapeo a componentes ──────────────────────────────────
    n_map = n_gap = 0
    for r in sheet_rows(wb, "Group_Analysis"):
        g = clean(r.get("Assigned_Group"))
        noise = 1 if g in NOISE_GROUPS else 0
        c.execute("INSERT OR REPLACE INTO ams_groups VALUES (?,?,?,?,?,?,?,?)",
                  (g, r.get("Tickets"), r.get("Mediana_Atencion_H"), r.get("P90_Atencion_H"),
                   r.get("Recurrentes"), r.get("Prioridad_Critica"), r.get("Prioridad_Alta"), noise))
        if noise:
            continue
        comp, syst = GROUP_MAP.get(g, (None, None))
        if comp or syst:
            mapping = "component" if comp else "system"
            n_map += 1
        else:
            mapping = "gap"
            n_gap += 1
        c.execute("INSERT OR REPLACE INTO ams_group_component VALUES (?,?,?,?,?)",
                  (g, comp, syst, r.get("Tickets"), mapping))

    # ── recurrencias ──────────────────────────────────────────────────────
    for r in sheet_rows(wb, "Recurrence_Analysis"):
        c.execute("""INSERT INTO ticket_recurrence
            (recurrence_key,group_name,occurrences,first_date,last_date,priorities)
            VALUES (?,?,?,?,?,?)""",
            (clean(r.get("Recurrence_Key")), clean(r.get("Assigned_Group")),
             r.get("Ocurrencias"), str(r.get("Primera_Fecha") or ""),
             str(r.get("Ultima_Fecha") or ""), clean(r.get("Prioridades"))))

    # ── serie mensual por prioridad ───────────────────────────────────────
    for r in sheet_rows(wb, "Monthly_Priority"):
        c.execute("INSERT INTO ticket_monthly VALUES (?,?,?,?)",
                  (clean(r.get("Year_Month_Sort")), clean(r.get("Priority_Clean")),
                   r.get("Tickets"), r.get("Mediana_Atencion_H")))
    wb.close()

    # ── corpus de tickets individuales ────────────────────────────────────
    corpus = load_corpus(WORDS)
    c.executemany("INSERT INTO ticket_corpus (month,group_name,description) VALUES (?,?,?)",
                  [(t.get("Mes"), t.get("group"), t.get("description")) for t in corpus])

    c.execute("""CREATE VIRTUAL TABLE ticket_corpus_fts USING fts5(
        description, group_name UNINDEXED, month UNINDEXED,
        content='ticket_corpus', content_rowid='id')""")
    c.execute("""INSERT INTO ticket_corpus_fts(rowid, description, group_name, month)
                 SELECT id, description, group_name, month FROM ticket_corpus""")

    conn.commit()

    n_groups = c.execute("SELECT COUNT(*) FROM ams_groups WHERE is_noise=0").fetchone()[0]
    n_rec    = c.execute("SELECT COUNT(*) FROM ticket_recurrence").fetchone()[0]
    n_corp   = c.execute("SELECT COUNT(*) FROM ticket_corpus").fetchone()[0]
    gap_vol  = c.execute("SELECT COALESCE(SUM(tickets),0) FROM ams_group_component WHERE mapping='gap'").fetchone()[0]
    conn.close()

    print(f"ams_groups          : {n_groups} grupos AMS (+ruido excluido)")
    print(f"ams_group_component : {n_map} mapeados · {n_gap} sin aplicación catalogada ({gap_vol} tickets)")
    print(f"ticket_recurrence   : {n_rec} patrones recurrentes")
    print(f"ticket_corpus       : {n_corp} tickets + FTS")


if __name__ == "__main__":
    main()
