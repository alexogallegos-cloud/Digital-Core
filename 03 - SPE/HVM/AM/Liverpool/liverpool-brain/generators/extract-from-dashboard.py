#!/usr/bin/env python3
"""
extract-from-dashboard.py
Extrae los 117 servicios de Arquitectura_Liverpool_Dashboard_1.html
y los carga como `components` en liverpool-brain.db.

Fuente: liverpool-brain/source/Arquitectura_Liverpool_Dashboard_1.html
        Business Units vs. Aplicaciones Liverpool v2.1 · Consolidado 2026-06-16

Ejecutar desde el directorio liverpool-brain/:
    python generators/extract-from-dashboard.py
"""

import re
import json
import sqlite3
from pathlib import Path

# ─── Paths ────────────────────────────────────────────────────────────────────
BRAIN_DIR = Path(__file__).parent.parent
HTML_PATH = BRAIN_DIR / "source" / "Arquitectura_Liverpool_Dashboard_1.html"
DB_PATH   = BRAIN_DIR / "liverpool-brain.db"

# ─── Mapeos de dominio del dashboard → R-dominio Liverpool ────────────────────
# Refinamiento adicional por plataforma (p) en get_domain()
BASE_DOMAIN_MAP = {
    "Retail":  "R01",
    "Digital": "R05",
    "SF":      "R03",
    "BF":      "R07",
    "BO":      "R08",
    "BI":      "R07",   # Inmobiliaria → Finanzas (más cercano)
}

# Casos donde la plataforma anula el dominio base
PLATFORM_DOMAIN_OVERRIDE = {
    "OMS":      "R04",
    "Logística":"R04",
    "SAP EWM":  "R04",
    "POS":      "R06",
    "Servicio tienda": "R06",
    "Crédito":  "R03",
    "Fraude":   "R03",
    "HCM":      "R08",
    "SAP BW":   "R09",
}

# ─── Plataforma del dashboard (p) → source_system ────────────────────────────
PLATFORM_TO_SYSTEM = {
    "SAP ECC":      "SAP",
    "SAP S/4HANA":  "SAP",
    "SAP PMR":      "SAP",
    "SAP EWM":      "SAP",
    "SAP PDM/PDTA": "SAP",
    "SAP SRM":      "SAP",
    "SAP F&R":      "SAP",
    "HCM":          "SAP",
    "Facturación":  "SAP",
    "Servicio tienda": "SAP",
    "SAP BW":       "SAP-BW",
    "Mainframe":    "Mainframe",
    "Fraude":       "Mainframe",    # Preautorizador, Key Monitor corren en Mainframe
    "OMS":          "Sterling-OMS",
    "eCommerce":    "ATG-Endeca",
    "Digital":      "Digital-Platform",
    "Seguros":      "Digital-Platform",
    "POS":          "Bridgecore",
    "Crédito":      "FICO-TRIAD",   # FICO TRIAD + Card Wizard + VPL → clasificar como SF stack
    "PIM":          "PIM-STEP",
    "Planning":     "Oracle-PL-SQL",
    "Logística":    "SAP",          # EWM es el core logístico; algunas sub son Sterling/TMS
    "Otros":        "Digital-Platform",
}

# ─── source_system → TOGAF type ───────────────────────────────────────────────
SYSTEM_TOGAF = {
    "SAP":            "core",
    "Mainframe":      "core",
    "VPL-Vision-Plus":"processors",
    "FICO-TRIAD":     "processors",
    "Base24":         "processors",
    "Cyberfinancial": "processors",
    "Card-Wizard":    "processors",
    "Oracle-PL-SQL":  "processors",
    "Siebel-CRM":     "processors",
    "PIM-STEP":       "processors",
    "ATG-Endeca":     "channels",
    "Sterling-OMS":   "channels",
    "Bridgecore":     "channels",
    "Digital-Platform":"channels",
    "IBM-IIB":        "integration",
    "Tumbleweed":     "integration",
    "Control-D":      "integration",
    "Apigee":         "integration",
    "CDP-GCP":        "data",
    "SAP-BW":         "data",
}

SYSTEM_LANGUAGE = {
    "SAP":            "ABAP",
    "SAP-BW":         "ABAP/BW",
    "Mainframe":      "COBOL",
    "VPL-Vision-Plus":"COBOL/VPL proprietary",
    "FICO-TRIAD":     "FICO proprietary",
    "Base24":         "ACI proprietary",
    "Cyberfinancial": "Harman Navigator",
    "Oracle-PL-SQL":  "PL/SQL",
    "Siebel-CRM":     "Siebel/JavaScript",
    "PIM-STEP":       "STEP",
    "ATG-Endeca":     "Java/ATG",
    "Sterling-OMS":   "Java/Sterling",
    "Bridgecore":     "Bridgecore proprietary",
    "Digital-Platform":"Java/GCP",
    "IBM-IIB":        "ESQL/Java",
    "Tumbleweed":     "MFT proprietary",
    "Control-D":      "JCL",
    "Apigee":         "JavaScript/Apigee",
    "CDP-GCP":        "Java/Python/GCP",
    "Card-Wizard":    "proprietary",
}

MIGRATION_FATE = {
    "SAP":            "replatform",   # ECC → S/4HANA (LIV pendiente, SBB listo)
    "SAP-BW":         "replatform",   # BW → BW4 HANA
    "Mainframe":      "encapsulate",  # API-fy VPL Vision Plus + SOMS
    "VPL-Vision-Plus":"encapsulate",
    "FICO-TRIAD":     "retain",
    "Base24":         "retain",
    "Cyberfinancial": "replatform",   # v8.4→v9C en curso
    "Card-Wizard":    "retain",
    "Oracle-PL-SQL":  "refactor",
    "Siebel-CRM":     "repurchase",
    "PIM-STEP":       "retain",
    "ATG-Endeca":     "repurchase",   # → commercetools
    "Sterling-OMS":   "refactor",
    "Bridgecore":     "retain",
    "Digital-Platform":"evolve",
    "IBM-IIB":        "replatform",
    "Tumbleweed":     "replatform",
    "Control-D":      "encapsulate",
    "Apigee":         "evolve",
    "CDP-GCP":        "evolve",
}

SOC_LABEL = {"LIV": "Liverpool", "SBB": "Suburbia", "Ambas": "Ambas"}

DOMAIN_FULL = {
    "Retail": "Retail", "Digital": "Digital",
    "SF": "Servicios Financieros", "BF": "Backoffice Finanzas",
    "BO": "Desarrollo Organizacional", "BI": "Inmobiliaria",
}


# ─── Extracción del HTML ──────────────────────────────────────────────────────

def extract_data_and_stacks(html: str):
    """Extrae el array DATA y el dict STACKS del HTML."""
    lines = html.splitlines()

    # DATA: recorrer líneas entre 'const DATA=[' y '];'
    data_lines = []
    in_data = False
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("const DATA=["):
            in_data = True
            rest = stripped[len("const DATA=["):]
            if rest:
                data_lines.append(rest)
            continue
        if in_data:
            if stripped.startswith("];"):
                break
            if stripped:
                data_lines.append(stripped)

    data_js = "[" + "".join(data_lines).rstrip(",") + "]"
    # Convertir claves JS sin quotes a JSON
    data_json = re.sub(r'([{,])\s*([a-zA-Z_]\w*)\s*:', r'\1"\2":', data_js)
    data = json.loads(data_json)

    # STACKS: línea única 'const STACKS={...};'
    stacks = {}
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("const STACKS="):
            stacks_js = stripped[len("const STACKS="):]
            if stacks_js.endswith(";"):
                stacks_js = stacks_js[:-1]
            stacks = json.loads(stacks_js)
            break

    return data, stacks


# ─── Helpers de mapeo ─────────────────────────────────────────────────────────

def get_source_system(p: str) -> str:
    return PLATFORM_TO_SYSTEM.get(p, "Digital-Platform")


def get_domain_id(d: str, p: str) -> str:
    if p in PLATFORM_DOMAIN_OVERRIDE:
        return PLATFORM_DOMAIN_OVERRIDE[p]
    return BASE_DOMAIN_MAP.get(d, "R01")


def get_complexity(n_apps: int, critical: bool) -> str:
    if critical and n_apps >= 8:
        return "very-high"
    if critical or n_apps >= 8:
        return "high"
    if n_apps >= 4:
        return "medium"
    return "low"


def build_description(entry: dict, apps: list) -> str:
    soc  = SOC_LABEL.get(entry.get("s", ""), entry.get("s", ""))
    dom  = DOMAIN_FULL.get(entry.get("d", ""), entry.get("d", ""))
    main = entry.get("a", "")
    sla  = entry.get("v", "")
    hrs  = entry.get("h", "")
    grp  = entry.get("g", "")
    crit = "CRÍTICO" if entry.get("c") else ""
    ams  = "EN ALCANCE AMS" if entry.get("e") else ""
    stack_str = " · ".join(apps[:10]) if apps else main

    parts = [
        f"{soc} · {dom}",
        f"App: {main}",
        f"Stack: {stack_str}",
        f"SLA: {sla}" if sla else "",
        f"Horario: {hrs}" if hrs else "",
        f"AMS: {grp}" if grp else "",
        crit, ams,
    ]
    return " | ".join(p for p in parts if p)


# ─── Carga en DB ──────────────────────────────────────────────────────────────

def load_components(conn, data: list, stacks: dict) -> int:
    rows = []
    for idx, entry in enumerate(data):
        svc_no = idx + 1
        svc_id = f"LIV-SVC-{svc_no:03d}"

        p_val   = entry.get("p", "")
        d_val   = entry.get("d", "")
        apps    = stacks.get(str(svc_no), [])
        src_sys = get_source_system(p_val)
        dom_id  = get_domain_id(d_val, p_val)
        crit    = bool(entry.get("c", 0))
        in_scope = bool(entry.get("e", 0))

        rows.append((
            svc_id,
            entry.get("n", f"Servicio {svc_no}"),          # name
            src_sys,                                         # source_system
            SYSTEM_LANGUAGE.get(src_sys, ""),               # source_language
            "service",                                       # component_type
            dom_id,                                          # domain_id
            entry.get("n", ""),                              # business_name
            build_description(entry, apps),                  # description
            SYSTEM_TOGAF.get(src_sys, "channels"),           # togaf_type
            MIGRATION_FATE.get(src_sys),                     # migration_fate
            None,                                            # lines_of_code
            get_complexity(len(apps), crit),                 # complexity
            "active" if in_scope else "baseline",            # status
            None,                                            # rtb_capabilities
            "Arquitectura_Liverpool_Dashboard_1.html",       # seeded_by
        ))

    conn.executemany("""
        INSERT OR REPLACE INTO components
        (id, name, source_system, source_language, component_type,
         domain_id, business_name, description, togaf_type,
         migration_fate, lines_of_code, complexity, status,
         rtb_capabilities, seeded_by)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    """, rows)

    # Rebuild FTS
    try:
        conn.execute("INSERT INTO components_fts(components_fts) VALUES('rebuild')")
    except Exception:
        pass

    conn.commit()
    return len(rows)


def update_domain_counts(conn):
    for r_id in [f"R{i:02d}" for i in range(1, 11)]:
        count = conn.execute(
            "SELECT COUNT(*) FROM components WHERE domain_id = ?", (r_id,)
        ).fetchone()[0]
        conn.execute(
            "UPDATE retail_domains SET component_count = ? WHERE id = ?", (count, r_id)
        )
    conn.commit()


# ─── Main ─────────────────────────────────────────────────────────────────────

def main():
    print("Liverpool Brain — Extract from Dashboard")
    print("=" * 45)

    for path, label in [(HTML_PATH, "HTML"), (DB_PATH, "Brain DB")]:
        if not path.exists():
            print(f"ERROR: No encontrado — {path}")
            if label == "Brain DB":
                print("  Ejecutar primero: python build-liverpool-brain.py")
            return

    print(f"Leyendo {HTML_PATH.name} ...")
    with open(HTML_PATH, encoding="utf-8") as f:
        html = f.read()

    print("Extrayendo DATA + STACKS ...")
    data, stacks = extract_data_and_stacks(html)
    print(f"  Servicios : {len(data)}")
    print(f"  Stacks    : {len(stacks)}")

    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA journal_mode=WAL")

    # Borrar carga anterior de esta fuente
    conn.execute(
        "DELETE FROM components WHERE seeded_by = 'Arquitectura_Liverpool_Dashboard_1.html'"
    )

    print("Cargando components ...")
    n = load_components(conn, data, stacks)

    print("Actualizando conteos de dominios ...")
    update_domain_counts(conn)

    # ── Resumen ──────────────────────────────────────────────────────────────
    total   = conn.execute("SELECT COUNT(*) FROM components").fetchone()[0]
    active  = conn.execute("SELECT COUNT(*) FROM components WHERE status='active'").fetchone()[0]
    crit    = conn.execute(
        "SELECT COUNT(*) FROM components WHERE complexity IN ('high','very-high')"
    ).fetchone()[0]
    by_sys  = conn.execute(
        "SELECT source_system, COUNT(*) n FROM components "
        "GROUP BY source_system ORDER BY n DESC"
    ).fetchall()
    by_dom  = conn.execute(
        "SELECT d.id, d.name, COUNT(c.id) n FROM retail_domains d "
        "LEFT JOIN components c ON c.domain_id = d.id "
        "GROUP BY d.id ORDER BY d.id"
    ).fetchall()

    conn.close()

    print()
    print(f"Components cargados       : {n}")
    print(f"Total en brain            : {total}")
    print(f"En alcance AMS (active)   : {active}")
    print(f"Alta / muy alta complejidad: {crit}")
    print()
    print("Por source_system:")
    for sys, cnt in by_sys:
        print(f"  {(sys or 'unknown'):25s}  {cnt:3d}")
    print()
    print("Por dominio retail:")
    for dom_id, dom_name, cnt in by_dom:
        print(f"  {dom_id}  {dom_name:35s}  {cnt:3d}")
    print()
    print("Next: python liverpool-brain.py  # verificar brain con components")


if __name__ == "__main__":
    main()