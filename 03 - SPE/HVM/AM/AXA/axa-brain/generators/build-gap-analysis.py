"""
build-gap-analysis.py
Lee axa-brain.db y genera 3 archivos MD en dt/dt-gap-analysis/:
  - gap-matrix.md     cruce pain_points × ETB capabilities
  - opportunities.md  oportunidades priorizadas por impacto × esfuerzo
  - quick-wins.md     5-7 intervenciones de alto impacto / bajo esfuerzo

Ejecutar desde: AXA/axa-brain/
    python generators/build-gap-analysis.py
"""

import sqlite3
import os
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH  = os.path.join(BASE_DIR, "axa-brain.db")
OUT_DIR  = os.path.join(BASE_DIR, "dt", "dt-gap-analysis")
TODAY    = datetime.now().strftime("%Y-%m-%d")

# ─── Mapeo: categoría pain point → dominio ETB afectado ─────────────────────
CAT_ETB = {
    "Información dispersa y herramientas no conectadas": "D6 Underwriting / D1 Distribution",
    "Proceso manual e intensivo en datos":               "D6 Underwriting / D9 Operations",
    "Dependencia de herramientas no integradas":         "D6 Underwriting / D8 Technology",
    "Falta de visibilidad y trazabilidad":               "D6 Underwriting / D5 Analytics",
    "Limitaciones de los sistemas actuales":             "D8 Technology Infrastructure",
    "Carga operativa y retrabajo":                       "D9 Operations Management",
    "Capacitación y adopción tecnológica":               "D10 Human Capital",
}

# ─── ETB capabilities clave para suscripción ────────────────────────────────
ETB_KEY = [
    ("6.3.1", "Risk Information Management",    "Gestión de la información del riesgo"),
    ("6.3.2", "Risk Assessment & Rating",        "Evaluación y tarificación del riesgo"),
    ("6.3.3", "Catastrophe Modelling",           "Modelación catastrófica"),
    ("6.3.4", "Quote Management",                "Gestión de la cotización"),
    ("6.3.5", "Negotiation & Placement",         "Negociación y colocación"),
    ("6.4",   "Policy Administration",           "Administración de pólizas"),
    ("6.5",   "Reinsurance Management",          "Gestión de reaseguro"),
    ("4.1",   "Distribution Management",         "Gestión de distribución / agentes"),
    ("7.1",   "Claims Management",               "Gestión de siniestros"),
    ("9.1",   "Regulatory Reporting",            "Reportes regulatorios"),
    ("5.1",   "Analytics & BI",                 "Analítica e inteligencia de negocio"),
    ("8.1",   "Integration Platform",            "Plataforma de integración"),
]

# ─── Sistema AXA → estado de cobertura ETB ──────────────────────────────────
SYSTEM_COVERAGE = {
    "6.3.1": ("underwriting-engine", "Vector (workflow) + HSD (cálculo — GAP CRÍTICO)", "PARTIAL"),
    "6.3.2": ("underwriting-engine", "HSD Excel — sin sistema real",                    "GAP"),
    "6.3.3": ("actuarial",           "ERN (confirmado) — manual al HSD",                "PARTIAL"),
    "6.3.4": ("underwriting-engine", "HSD Excel + negociación por correo",              "GAP"),
    "6.3.5": ("underwriting-engine", "Sin sistema — correo/Teams/WhatsApp",             "GAP"),
    "6.4":   ("policy-admin",        "General Daños — recaptura manual desde slip",     "PARTIAL"),
    "6.5":   ("reinsurance",         "SAFAC — solo estructura lineal",                  "PARTIAL"),
    "4.1":   ("portal-agentes",      "Sin sistema confirmado",                           "SCAFFOLD"),
    "7.1":   ("claims",              "Sin sistema confirmado",                           "SCAFFOLD"),
    "9.1":   ("reporting-cnsf",      "Monitor (tentativo)",                             "PARTIAL"),
    "5.1":   ("analytics",           "Power BI — acceso fragmentado",                   "PARTIAL"),
    "8.1":   ("api-gateway",         "Sin sistema confirmado",                           "SCAFFOLD"),
}

# ─── Score de impacto por estado ─────────────────────────────────────────────
IMPACT = {"GAP": 3, "PARTIAL": 2, "SCAFFOLD": 2, "CONFIRMED": 0}


def load_pain_points(conn):
    rows = conn.execute("""
        SELECT id, cat_c1, cat_c2, descripcion, manualidad,
               lob_property, lob_ramos_tecnicos, lob_rc, lob_maritimo,
               lob_aviacion, lob_obras_arte, lob_lineas_fin, lob_suscripcion,
               causa_tecnologia, mejora_tecnologia, patron_tecnologia
        FROM pain_points
        ORDER BY cat_c1, id
    """).fetchall()
    return rows


def count_lobs(row):
    return sum([row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12]])


def build_gap_matrix(conn) -> str:
    pp_rows = load_pain_points(conn)

    # Agrupar por categoría
    cats: dict[str, list] = {}
    for r in pp_rows:
        cat = r[1] or "Sin categoría"
        cats.setdefault(cat, []).append(r)

    lines = [
        f"# Gap Matrix — AXA México P&C Commercial Lines",
        f"> Generado: {TODAY} · Fuente: axa-brain.db",
        f"> {len(pp_rows)} pain points × capacidades ETB Insurance P&C v3.0",
        "",
        "---",
        "",
        "## Resumen de Brechas por Categoría",
        "",
        "| Categoría | Pain Points | LoBs promedio | Manualidad | Dominio ETB afectado |",
        "|-----------|------------|---------------|------------|----------------------|",
    ]

    for cat, rows in sorted(cats.items(), key=lambda x: -len(x[1])):
        n = len(rows)
        avg_lobs = sum(count_lobs(r) for r in rows) / n if n else 0
        manual = sum(1 for r in rows if r[4] == 1)
        etb = CAT_ETB.get(cat, "Por mapear")
        lines.append(f"| {cat} | {n} | {avg_lobs:.1f} | {manual}/{n} | {etb} |")

    lines += [
        "",
        "---",
        "",
        "## Brecha por Capacidad ETB",
        "",
        "| ETB ID | Capacidad | Sistema AXA Actual | Estado | Impacto |",
        "|--------|-----------|-------------------|--------|---------|",
    ]

    for cap_id, cap_en, cap_es in ETB_KEY:
        slug, sistema, estado = SYSTEM_COVERAGE.get(cap_id, ("—", "Por confirmar", "SCAFFOLD"))
        impacto = "🔴 Alto" if IMPACT.get(estado, 0) == 3 else ("🟡 Medio" if IMPACT.get(estado, 0) == 2 else "🟢 Cubierto")
        lines.append(f"| {cap_id} | {cap_es} | {sistema} | {estado} | {impacto} |")

    lines += [
        "",
        "---",
        "",
        "## Pain Points Detalle",
        "",
    ]

    for cat, rows in sorted(cats.items(), key=lambda x: -len(x[1])):
        lines.append(f"### {cat}")
        lines.append("")
        lines.append("| ID | Descripción | LoBs | Manual | Causa tecnológica | Mejora propuesta |")
        lines.append("|----|-------------|------|--------|-------------------|------------------|")
        for r in rows:
            desc = (r[3] or "")[:80]
            lobs = count_lobs(r)
            manual = "Sí" if r[4] == 1 else "No"
            causa = (r[13] or "—")[:60]
            mejora = (r[14] or "—")[:60]
            lines.append(f"| {r[0]} | {desc} | {lobs} | {manual} | {causa} | {mejora} |")
        lines.append("")

    lines += [
        "---",
        "",
        f"*Generado por build-gap-analysis.py el {TODAY}*",
    ]
    return "\n".join(lines)


def build_opportunities(conn) -> str:
    pp_rows = load_pain_points(conn)

    # Definir oportunidades basadas en gaps ETB + pain points
    opportunities = [
        {
            "id": "OPP-001",
            "nombre": "Digitalizar la HSD — eliminar Excel de cálculo técnico",
            "descripcion": "Sustituir la Hoja de Suscripción de Daños (Excel) por una herramienta web integrada con Vector. Es el gap más crítico: el cálculo técnico de suscripción vive fuera de cualquier sistema.",
            "etb": "6.3.2 Risk Assessment & Rating",
            "pain_points": [r[0] for r in pp_rows if r[4] == 1 and r[12] == 1][:5],
            "sistemas": ["underwriting-engine"],
            "impacto": "Alto",
            "esfuerzo": "Medio",
            "lobs": "Todos (Property, RT, RC, Marítimo, Aviación, OA, LF)",
            "tipo": "Quick Win → Estratégico",
        },
        {
            "id": "OPP-002",
            "nombre": "API ERN → sistema de cotización",
            "descripcion": "Exponer los resultados de ERN (modelación catastrófica) como API para eliminar la copia manual de PML y cúmulos al HSD.",
            "etb": "6.3.3 Catastrophe Modelling",
            "pain_points": [],
            "sistemas": ["actuarial", "underwriting-engine"],
            "impacto": "Alto",
            "esfuerzo": "Bajo",
            "lobs": "Property, Ramos Técnicos",
            "tipo": "Quick Win",
        },
        {
            "id": "OPP-003",
            "nombre": "Integración Vector → General Daños",
            "descripcion": "Eliminar la recaptura manual de condiciones aprobadas desde el slip al sistema de emisión. Crear una API de traspaso de condiciones entre el expediente de suscripción y la póliza.",
            "etb": "6.4 Policy Administration",
            "pain_points": [],
            "sistemas": ["underwriting-engine", "policy-admin"],
            "impacto": "Alto",
            "esfuerzo": "Medio",
            "lobs": "Todos",
            "tipo": "Estratégico",
        },
        {
            "id": "OPP-004",
            "nombre": "Portal de agentes básico",
            "descripcion": "Visibilidad del estado de folios en Vector para agentes y corredores. Sin este canal, la coordinación se hace por correo/WhatsApp, sin trazabilidad.",
            "etb": "4.1 Distribution Management",
            "pain_points": [],
            "sistemas": ["portal-agentes", "underwriting-engine"],
            "impacto": "Alto",
            "esfuerzo": "Medio",
            "lobs": "Todos",
            "tipo": "Estratégico",
        },
        {
            "id": "OPP-005",
            "nombre": "Consolidación de información cross-sistema",
            "descripcion": "Resolver la fragmentación de información entre Vector, SINCO, HSD, ERN y Power BI. Los suscriptores buscan datos en múltiples sistemas sin fuente única de verdad.",
            "etb": "5.1 Analytics & BI / 8.1 Integration Platform",
            "pain_points": [r[0] for r in pp_rows if r[1] and "dispersa" in r[1].lower()][:5],
            "sistemas": ["datawarehouse", "analytics", "api-gateway"],
            "impacto": "Alto",
            "esfuerzo": "Alto",
            "lobs": "Todos",
            "tipo": "Estratégico",
        },
        {
            "id": "OPP-006",
            "nombre": "SAFAC extendido — carga masiva de capas",
            "descripcion": "Ampliar SAFAC para soportar estructuras de reaseguro complejas (múltiples capas, múltiples reaseguradores por capa) sin requerir manipulación manual.",
            "etb": "6.5 Reinsurance Management",
            "pain_points": [],
            "sistemas": ["reinsurance"],
            "impacto": "Medio",
            "esfuerzo": "Bajo",
            "lobs": "Property, Ramos Técnicos, RC",
            "tipo": "Quick Win",
        },
        {
            "id": "OPP-007",
            "nombre": "Mapa regulatorio completo (Monitor + reservas)",
            "descripcion": "Confirmar el rol de Monitor y los sistemas de reservas técnicas para construir la cadena regulatoria CNSF completa. Prerequisito para IFRS 17 y Solvencia C.",
            "etb": "9.1 Regulatory Reporting",
            "pain_points": [],
            "sistemas": ["reporting-cnsf", "cnsf", "solvency"],
            "impacto": "Alto",
            "esfuerzo": "Bajo",
            "lobs": "Regulatorio",
            "tipo": "Quick Win (discovery)",
        },
    ]

    lines = [
        f"# Oportunidades de Transformación — AXA México P&C",
        f"> Generado: {TODAY} · Priorizado por impacto × esfuerzo",
        "",
        "---",
        "",
        "## Mapa de Oportunidades",
        "",
        "```",
        "           ALTO IMPACTO",
        "                │",
        "  OPP-002 ──────┼────── OPP-001  OPP-003  OPP-004",
        "  OPP-006       │       OPP-007",
        "  BAJO ─────────┼───────────────────────── ALTO",
        "  ESFUERZO      │              OPP-005",
        "                │",
        "           BAJO IMPACTO",
        "```",
        "",
        "---",
        "",
        "## Detalle por Oportunidad",
        "",
    ]

    for opp in opportunities:
        pp_str = ", ".join(opp["pain_points"]) if opp["pain_points"] else "Ver gap matrix"
        lines += [
            f"### {opp['id']} — {opp['nombre']}",
            "",
            f"**Tipo**: {opp['tipo']}  ",
            f"**Impacto**: {opp['impacto']} | **Esfuerzo**: {opp['esfuerzo']}  ",
            f"**ETB**: {opp['etb']}  ",
            f"**LoBs afectadas**: {opp['lobs']}  ",
            f"**Sistemas involucrados**: {', '.join(opp['sistemas'])}  ",
            f"**Pain points relacionados**: {pp_str}",
            "",
            opp["descripcion"],
            "",
        ]

    lines += [
        "---",
        "",
        f"*Generado por build-gap-analysis.py el {TODAY}*",
    ]
    return "\n".join(lines)


def build_quick_wins() -> str:
    lines = [
        f"# Quick Wins — AXA México P&C · Ola 1",
        f"> Generado: {TODAY}",
        f"> Intervenciones de alto impacto / bajo esfuerzo · 0-12 meses",
        "",
        "---",
        "",
        "Las 5 intervenciones con mejor ratio impacto/esfuerzo identificadas desde el brain:",
        "",
        "## QW-1 · API ERN → cotización (1-2 meses)",
        "",
        "**Problema**: Los resultados de modelación catastrófica de ERN se copian manualmente al HSD.",
        "**Acción**: Crear una API (o exportación estructurada) de ERN que alimente directamente",
        "la herramienta de cotización técnica.",
        "**Impacto**: Elimina transcripción manual de PML, velocidad y exactitud en Property/RT.",
        "**Prerequisito**: Acceso técnico a ERN para evaluar capacidad de integración.",
        "",
        "## QW-2 · SAFAC — carga masiva de capas (1-3 meses)",
        "",
        "**Problema**: SAFAC solo soporta estructura lineal de reaseguro.",
        "**Acción**: Evaluar si SAFAC tiene funcionalidad de carga masiva no utilizada;",
        "si no, implementar importación desde Excel de capas/reaseguradores.",
        "**Impacto**: Reduce tiempo de registro de colocaciones complejas.",
        "**Prerequisito**: Sesión con el equipo de reaseguro + proveedor de SAFAC.",
        "",
        "## QW-3 · Confirmar Monitor (2-4 semanas)",
        "",
        "**Problema**: Monitor aparece en el proceso de suscripción pero su rol exacto no está confirmado.",
        "**Acción**: Entrevista con el equipo de reporting para confirmar si Monitor es:",
        "(a) herramienta de reporting CNSF, (b) monitoreo de cartera, o (c) ambas.",
        "**Impacto**: Desbloquea dt-regulatory-solvency y dt-financial-reporting.",
        "**Prerequisito**: Acceso al equipo de control de gestión / finanzas.",
        "",
        "## QW-4 · Visibilidad de folios para agentes (3-6 meses)",
        "",
        "**Problema**: Los agentes y corredores no tienen visibilidad del estado de sus casos en Vector.",
        "**Acción**: Exponer una vista de solo lectura de folios Vector por conducto,",
        "sin requerir un portal nuevo completo (puede ser un reporte/email automático).",
        "**Impacto**: Reduce llamadas/correos de seguimiento; mejora relación con intermediarios.",
        "**Prerequisito**: Confirmar si Vector tiene API o capacidad de exportación/notificación.",
        "",
        "## QW-5 · Diagnóstico HSD — roadmap de digitalización (4-8 semanas)",
        "",
        "**Problema**: La HSD (Hoja de Suscripción de Daños) es el gap más crítico del proceso",
        "de suscripción. Antes de decidir cómo reemplazarla, se necesita un diagnóstico completo.",
        "**Acción**: Taller con los suscriptores para mapear todas las variantes del HSD por LoB,",
        "identificar campos críticos vs redundantes, y proponer alternativas (configurador web,",
        "Python/Streamlit, integración con Vector, módulo en plataforma de suscripción).",
        "**Impacto**: Define la decisión de inversión más importante del programa.",
        "**Prerequisito**: Disponibilidad de suscriptores por LoB (Property, RT, RC mínimo).",
        "",
        "---",
        "",
        "## Matriz Resumen",
        "",
        "| # | Quick Win | Esfuerzo | Tiempo | Impacto | Prerequisito |",
        "|---|-----------|----------|--------|---------|--------------|",
        "| QW-1 | API ERN → cotización | Bajo | 1-2 meses | Alto | Acceso técnico ERN |",
        "| QW-2 | SAFAC carga masiva | Bajo | 1-3 meses | Medio | Sesión reaseguro |",
        "| QW-3 | Confirmar Monitor | Muy bajo | 2-4 semanas | Alto (desbloqueador) | Entrevista reporting |",
        "| QW-4 | Visibilidad folios agentes | Medio | 3-6 meses | Alto | API/export Vector |",
        "| QW-5 | Diagnóstico HSD | Bajo | 4-8 semanas | Muy alto (decisión clave) | Suscriptores disponibles |",
        "",
        "---",
        "",
        f"*Generado por build-gap-analysis.py el {TODAY}*",
    ]
    return "\n".join(lines)


def main() -> None:
    if not os.path.exists(DB_PATH):
        print(f"[ERROR] axa-brain.db no encontrado en {DB_PATH}")
        return

    os.makedirs(OUT_DIR, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)

    n_pp = conn.execute("SELECT COUNT(*) FROM pain_points").fetchone()[0]
    n_etb = conn.execute("SELECT COUNT(*) FROM etb_capabilities").fetchone()[0]
    n_ps = conn.execute("SELECT COUNT(*) FROM process_steps").fetchone()[0]
    print(f"[INFO] Leyendo brain: {n_pp} pain points · {n_etb} ETB caps · {n_ps} process steps")

    gap_matrix = build_gap_matrix(conn)
    opportunities = build_opportunities(conn)
    quick_wins = build_quick_wins()
    conn.close()

    files = [
        ("gap-matrix.md",    gap_matrix),
        ("opportunities.md", opportunities),
        ("quick-wins.md",    quick_wins),
    ]

    for fname, content in files:
        fpath = os.path.join(OUT_DIR, fname)
        with open(fpath, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"[OK] {fname}")

    print(f"\n[DONE] dt-gap-analysis/ poblado con 3 archivos → {OUT_DIR}")
    print(f"       Próximo paso: python generators/build-transformation-roadmap.py")


if __name__ == "__main__":
    main()