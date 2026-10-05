"""
build-underwriting-intelligence.py
Lee axa-brain.db y genera el contenido del DT de suscripción:

  dt/dt-underwriting-intelligence/
    as-is.md        → proceso actual: fases, LoBs, sistemas, roles, reglas
    gaps.md         → brechas: pain points + capacidades ETB faltantes
    process-map.md  → mapa completo L1→L4 con sistemas y flags de manualidad

Ejecutar desde: AXA/axa-brain/
    python generators/build-underwriting-intelligence.py
"""

import sqlite3
import os
from datetime import datetime
from collections import defaultdict

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH  = os.path.join(BASE_DIR, "axa-brain.db")
OUT_DIR  = os.path.join(BASE_DIR, "dt", "dt-underwriting-intelligence")
TODAY    = datetime.now().strftime("%Y-%m-%d")

# Orden canónico de fases L2
FASE_ORDER = [
    "preparación de la información",
    "evaluación del riesgo",
    "carga de información en la hsd",
    "modelación catastrófica",
    "cálculo y revisión de resultados técnicos",
    "definición de la cotización",
    "elaboración y validación de la cotización",
    "negociación de la cotización",
    "envío y negociación",
    "validación de reglas de suscripción",
]

LOB_ORDER = [
    "Property",
    "Ramos Técnicos",
    "RC",
    "Marítimo",
    "Aviación",
    "Obras de Arte",
    "Líneas Financieras",
]

SISTEMA_LABEL = {
    "underwriting-engine": "Vector / HSD",
    "crm":                 "SINCO",
    "actuarial":           "ERN",
    "reinsurance":         "SAFAC",
    "policy-admin":        "General Daños",
    "analytics":           "Power BI",
    "reporting-cnsf":      "Monitor",
}


def slugs_to_labels(slugs_str: str) -> str:
    if not slugs_str:
        return "— (manual / sin sistema)"
    parts = [s.strip() for s in slugs_str.split(";") if s.strip()]
    labels = [SISTEMA_LABEL.get(p, p) for p in parts]
    return " · ".join(labels)


def load_steps(conn) -> list:
    return conn.execute("""
        SELECT id, id_padre, rama, lob, proceso_l1, fase_l2, etapa_l3, paso_l4,
               sistemas_raw, sistemas_slugs, roles, documentos, regla_negocio,
               tiempos, etb_capability
        FROM process_steps
        ORDER BY id
    """).fetchall()


def load_pain_points_suscripcion(conn) -> list:
    return conn.execute("""
        SELECT id, cat_c1, cat_c2, descripcion, manualidad,
               causa_proceso, mejora_proceso,
               causa_tecnologia, mejora_tecnologia, patron_tecnologia,
               lob_property, lob_ramos_tecnicos, lob_rc, lob_maritimo,
               lob_aviacion, lob_obras_arte, lob_lineas_fin, lob_suscripcion
        FROM pain_points
        WHERE lob_suscripcion=1
        ORDER BY cat_c1, id
    """).fetchall()


# ═══════════════════════════════════════════════════════════
# as-is.md
# ═══════════════════════════════════════════════════════════
def build_as_is(conn) -> str:
    steps = load_steps(conn)

    # Totales por LoB
    lob_counts: dict[str, int] = defaultdict(int)
    for s in steps:
        lob_counts[s[3]] += 1

    # Pasos sin sistema (manuales)
    manual = [s for s in steps if not s[9] or s[9].strip() == ""]
    pct_manual = 100 * len(manual) / len(steps) if steps else 0

    # Sistemas únicos por fase
    fase_sistemas: dict[str, set] = defaultdict(set)
    fase_counts: dict[str, int] = defaultdict(int)
    lob_fase_counts: dict[tuple, int] = defaultdict(int)
    for s in steps:
        fase = (s[5] or "").strip().lower()
        fase_counts[fase] += 1
        if s[9]:
            for slug in s[9].split(";"):
                slug = slug.strip()
                if slug:
                    fase_sistemas[fase].add(slug)
        if s[3]:
            lob_fase_counts[(s[3], fase)] += 1

    # Roles únicos globales
    all_roles: set[str] = set()
    for s in steps:
        if s[10]:
            for r in s[10].split(","):
                r = r.strip()
                if r and r != "None":
                    all_roles.add(r)

    lines = [
        "# AS-IS — Proceso de Suscripción AXA Daños",
        f"> Generado: {TODAY} · Fuente: axa-brain.db ({len(steps)} pasos de proceso)",
        "",
        "---",
        "",
        "## Vista General",
        "",
        f"El proceso de suscripción de daños comerciales en AXA México comprende **{len(steps)} pasos**",
        f"distribuidos en **{len(lob_counts)} líneas de negocio** y **5 fases principales**.",
        "",
        f"- **Pasos sin sistema registrado (manuales)**: {len(manual)} de {len(steps)} ({pct_manual:.0f}%)",
        f"- **Herramienta crítica sin integración**: HSD (Hoja de Suscripción de Daños — Excel)",
        f"- **Sistemas confirmados en el proceso**: Vector · SINCO · ERN · SAFAC · General Daños · Power BI",
        "",
        "---",
        "",
        "## Pasos por Línea de Negocio",
        "",
        "| Línea de Negocio | Pasos | % del total |",
        "|-----------------|-------|-------------|",
    ]

    for lob in LOB_ORDER:
        n = lob_counts.get(lob, 0)
        pct = 100 * n / len(steps) if steps else 0
        lines.append(f"| {lob} | {n} | {pct:.0f}% |")

    # Cualquier LoB no en el orden canónico
    for lob, n in sorted(lob_counts.items()):
        if lob not in LOB_ORDER:
            pct = 100 * n / len(steps) if steps else 0
            lines.append(f"| {lob} | {n} | {pct:.0f}% |")

    lines += [
        "",
        "---",
        "",
        "## Fases del Proceso (L2)",
        "",
        "| Fase | Pasos totales | Sistemas involucrados |",
        "|------|--------------|----------------------|",
    ]

    fases_seen = []
    for fase_key in FASE_ORDER:
        for fase_raw, cnt in sorted(fase_counts.items(), key=lambda x: -x[1]):
            if fase_key in fase_raw and fase_raw not in fases_seen:
                fases_seen.append(fase_raw)
                sistemas_str = " · ".join(
                    SISTEMA_LABEL.get(s, s) for s in sorted(fase_sistemas[fase_raw])
                ) or "— (manual)"
                lines.append(f"| {fase_raw.title()} | {cnt} | {sistemas_str} |")

    # Fases no mapeadas al orden canónico
    for fase_raw, cnt in sorted(fase_counts.items(), key=lambda x: -x[1]):
        if fase_raw and fase_raw not in fases_seen:
            sistemas_str = " · ".join(
                SISTEMA_LABEL.get(s, s) for s in sorted(fase_sistemas[fase_raw])
            ) or "— (manual)"
            lines.append(f"| {fase_raw.title()} | {cnt} | {sistemas_str} |")

    lines += [
        "",
        "---",
        "",
        "## Roles del Proceso",
        "",
        "| Rol |",
        "|-----|",
    ]
    for r in sorted(all_roles):
        lines.append(f"| {r} |")

    lines += [
        "",
        "---",
        "",
        "## Sistemas — Participación en el Proceso",
        "",
        "| Sistema | Rol | Fases principales | Estado |",
        "|---------|-----|------------------|--------|",
        "| Vector | Workflow de folios — registro, seguimiento, control de expedientes | Preparación, Evaluación, Negociación | CONFIRMED |",
        "| HSD (Excel) | Cálculo técnico — tarificación, cúmulos, condiciones especiales | Carga HSD, Cálculo resultados, Elaboración cotización | **GAP CRÍTICO** |",
        "| SINCO | Búsqueda de cuentas, antecedentes y conductos | Preparación | CONFIRMED |",
        "| ERN | Modelación catastrófica (PML, sísmica, hidro) | Modelación catastrófica | CONFIRMED |",
        "| SAFAC | Registro de colocaciones de reaseguro facultativo | Definición cotización, Negociación | CONFIRMED |",
        "| General Daños | Emisión de la póliza una vez aprobada la suscripción | Post-suscripción | CONFIRMED |",
        "| Power BI | Consulta de siniestralidad histórica | Preparación, Evaluación | CONFIRMED |",
        "| Monitor | Consulta / reporte (rol exacto por confirmar) | Por determinar | PARTIAL |",
        "| Correo / Teams / WhatsApp | Coordinación y comunicación fuera de sistemas | Todas | **GAP** |",
        "",
        "---",
        "",
        "## Reglas de Negocio Clave (muestra)",
        "",
    ]

    # Muestra de reglas de negocio no vacías
    reglas_sample = [s for s in steps if s[12] and s[12] not in ("None", "—", "")][:15]
    lines += [
        "| ID Paso | LoB | Fase | Regla de negocio |",
        "|---------|-----|------|-----------------|",
    ]
    for s in reglas_sample:
        regla = (s[12] or "")[:100]
        fase = (s[5] or "")[:40]
        lines.append(f"| {s[0]} | {s[3]} | {fase} | {regla} |")

    lines += [
        "",
        "---",
        "",
        f"*Generado por build-underwriting-intelligence.py el {TODAY}*",
    ]
    return "\n".join(lines)


# ═══════════════════════════════════════════════════════════
# gaps.md
# ═══════════════════════════════════════════════════════════
def build_gaps(conn) -> str:
    pp = load_pain_points_suscripcion(conn)
    steps = load_steps(conn)

    manual = [s for s in steps if not s[9] or s[9].strip() == ""]
    pct_manual = 100 * len(manual) / len(steps) if steps else 0

    # Pain points con causa tecnológica
    pp_tech = [r for r in pp if r[7] and r[7] not in ("", "—", "None")]
    # Pain points con manualidad
    pp_manual = [r for r in pp if r[4] == 1]

    lines = [
        "# GAP — Brechas del Proceso de Suscripción",
        f"> Generado: {TODAY} · {len(pp)} pain points aplicables a suscripción",
        "",
        "---",
        "",
        "## El Gap Central: HSD como Sistema Crítico",
        "",
        "La **Hoja de Suscripción de Daños (HSD)** es un archivo Excel que actúa como el sistema",
        "de cálculo técnico de la suscripción — tarificación, cúmulos, condiciones especiales,",
        "carga de ubicaciones. No es un sistema tecnológico: es una herramienta manual sin integración.",
        "",
        "**Consecuencias directas:**",
        "- Sin trazabilidad automática de cambios en el cálculo técnico",
        "- Sin integración con Vector (el expediente no captura el cálculo técnico)",
        "- Sin integración con ERN (resultados catastróficos se copian a mano)",
        "- Sin integración con SAFAC (condiciones de cesión se trasladan manualmente)",
        "- Sin versionamiento: ¿qué HSD corresponde a qué folio en qué versión?",
        "- Riesgo de error humano en cada transcripción",
        "",
        "**Capacidad ETB faltante**: 6.3.2 Risk Assessment & Rating — el motor de tarificación",
        "y cálculo técnico no existe como sistema. Es el gap más crítico del landscape.",
        "",
        "---",
        "",
        "## Mapa de Brechas por Fase",
        "",
        "| Fase | Gap identificado | Causa raíz | ETB afectado |",
        "|------|-----------------|------------|--------------|",
        "| Preparación de la información | SINCO solo permite búsqueda por razón social + dirección; sin identificador confiable de cliente | Limitación de sistema | 6.3.1 |",
        "| Evaluación del riesgo | ERN → HSD manual; sin API de resultados catastróficos | Falta de integración | 6.3.2 / 6.3.3 |",
        "| Carga en HSD | HSD es Excel — sin integración, sin control de versiones | Ausencia de sistema | 6.3.2 |",
        "| Definición de cotización | Condiciones técnicas se negocian por correo/WhatsApp | Sin sistema de negociación | 6.3.4 / 6.3.5 |",
        "| Negociación | Sin pipeline de cotizaciones; cada caso es ad-hoc | Sin gestión de pipeline | 6.3.5 |",
        "| Emisión (post-suscripción) | Recaptura manual de condiciones aprobadas en General Daños | Falta de integración | 6.4 |",
        "",
        "---",
        "",
        f"## Pain Points de Suscripción ({len(pp)} identificados)",
        "",
        "### Con causa tecnológica confirmada",
        "",
        "| ID | Categoría | Descripción | Causa tecnológica | Mejora propuesta |",
        "|----|-----------|-------------|-------------------|-----------------|",
    ]

    for r in pp_tech:
        desc = (r[3] or "")[:70]
        cat = (r[1] or "")[:50]
        causa = (r[7] or "")[:80]
        mejora = (r[8] or "")[:80]
        lines.append(f"| {r[0]} | {cat} | {desc} | {causa} | {mejora} |")

    lines += [
        "",
        "### Con alta manualidad",
        "",
        "| ID | Categoría | Descripción | Proceso manual identificado |",
        "|----|-----------|-------------|----------------------------|",
    ]

    for r in pp_manual:
        desc = (r[3] or "")[:70]
        cat = (r[1] or "")[:50]
        causa_proc = (r[5] or "—")[:80]
        lines.append(f"| {r[0]} | {cat} | {desc} | {causa_proc} |")

    lines += [
        "",
        "---",
        "",
        "## Pasos Sin Sistema (manualidad estructural)",
        "",
        f"De los {len(steps)} pasos del proceso, **{len(manual)} ({pct_manual:.0f}%) no tienen",
        "ningún sistema registrado**. Estos pasos se ejecutan con herramientas fuera del stack",
        "de sistemas (correo, Excel, Teams, WhatsApp, llamadas telefónicas).",
        "",
        "Muestra de pasos sin sistema (primeros 20):",
        "",
        "| ID | LoB | Fase | Paso |",
        "|----|-----|------|------|",
    ]

    for s in manual[:20]:
        paso = (s[7] or "")[:80]
        fase = (s[5] or "")[:40]
        lines.append(f"| {s[0]} | {s[3]} | {fase} | {paso} |")

    if len(manual) > 20:
        lines.append(f"| … | … | … | *+{len(manual)-20} pasos adicionales* |")

    lines += [
        "",
        "---",
        "",
        "## Brechas ETB — Capacidades Faltantes",
        "",
        "| ETB ID | Capacidad | Estado en AXA | Brecha |",
        "|--------|-----------|--------------|--------|",
        "| 6.3.1 | Risk Information Management | PARTIAL — SINCO limitado | Sin identificador único de riesgo cross-sistema |",
        "| 6.3.2 | Risk Assessment & Rating | **GAP** — HSD Excel | Motor de tarificación no existe como sistema |",
        "| 6.3.3 | Catastrophe Modelling | PARTIAL — ERN confirmado | Resultados no se integran automáticamente |",
        "| 6.3.4 | Quote Management | **GAP** — HSD + correo | Sin sistema de gestión de cotizaciones |",
        "| 6.3.5 | Negotiation & Placement | **GAP** — correo/WhatsApp | Sin pipeline de negociación |",
        "| 6.4   | Policy Administration | PARTIAL — General Daños | Recaptura manual desde slip |",
        "| 6.5   | Reinsurance Management | PARTIAL — SAFAC | Solo estructura lineal |",
        "| 4.1   | Distribution Management | **SCAFFOLD** — sin confirmar | Sin portal de agentes |",
        "| 8.1   | Integration Platform | **SCAFFOLD** — sin confirmar | Sin API gateway entre sistemas |",
        "",
        "---",
        "",
        f"*Generado por build-underwriting-intelligence.py el {TODAY}*",
    ]
    return "\n".join(lines)


# ═══════════════════════════════════════════════════════════
# process-map.md
# ═══════════════════════════════════════════════════════════
def build_process_map(conn) -> str:
    steps = load_steps(conn)

    # Organizar por LoB → L2 → L3 → L4
    tree: dict = defaultdict(lambda: defaultdict(lambda: defaultdict(list)))
    for s in steps:
        lob = s[3] or "Sin LoB"
        fase = (s[5] or "Sin fase").strip()
        etapa = (s[6] or "Sin etapa").strip()
        tree[lob][fase][etapa].append(s)

    lines = [
        "# Mapa de Proceso — Suscripción AXA Daños · L1 → L4",
        f"> Generado: {TODAY} · {len(steps)} pasos · 7 LoBs",
        "> 🔴 = sin sistema (manual) · 🟡 = parcial · 🟢 = con sistema",
        "",
        "---",
        "",
    ]

    for lob in LOB_ORDER:
        if lob not in tree:
            continue
        lob_steps = sum(len(v) for f in tree[lob].values() for v in f.values())
        lines += [
            f"## {lob} ({lob_steps} pasos)",
            "",
        ]

        fases_lob = tree[lob]
        # Ordenar fases por orden canónico
        fases_sorted = []
        for fk in FASE_ORDER:
            for fase_raw in fases_lob:
                if fk in fase_raw.lower() and fase_raw not in fases_sorted:
                    fases_sorted.append(fase_raw)
        for fase_raw in fases_lob:
            if fase_raw not in fases_sorted:
                fases_sorted.append(fase_raw)

        for fase in fases_sorted:
            n_fase = sum(len(v) for v in fases_lob[fase].values())
            lines += [
                f"### {fase.title()} ({n_fase} pasos)",
                "",
                "| ID | Etapa (L3) | Paso (L4) | Sistema | Rol | Regla |",
                "|----|-----------|-----------|---------|-----|-------|",
            ]
            etapas = fases_lob[fase]
            for etapa, step_list in sorted(etapas.items()):
                for s in step_list:
                    sistema_lbl = slugs_to_labels(s[9])
                    icon = "🟢" if s[9] and s[9].strip() else "🔴"
                    rol = (s[10] or "—")[:40]
                    regla = (s[12] or "—")[:60]
                    paso = (s[7] or "—")[:80]
                    et = (etapa or "—")[:50]
                    lines.append(f"| {s[0]} | {icon} {et} | {paso} | {sistema_lbl} | {rol} | {regla} |")
            lines.append("")

    lines += [
        "---",
        "",
        "## Leyenda",
        "",
        "| Icono | Significado |",
        "|-------|-------------|",
        "| 🟢 | Paso con sistema registrado (Vector, SINCO, ERN, SAFAC, etc.) |",
        "| 🔴 | Paso sin sistema — ejecución manual (correo, Excel, Teams, WhatsApp) |",
        "| 🟡 | Paso con sistema parcial (HSD — herramienta sin integración) |",
        "",
        "---",
        "",
        f"*Generado por build-underwriting-intelligence.py el {TODAY}*",
    ]
    return "\n".join(lines)


def main() -> None:
    if not os.path.exists(DB_PATH):
        print(f"[ERROR] axa-brain.db no encontrado.")
        return

    os.makedirs(OUT_DIR, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)

    n_ps = conn.execute("SELECT COUNT(*) FROM process_steps").fetchone()[0]
    n_pp = conn.execute("SELECT COUNT(*) FROM pain_points WHERE lob_suscripcion=1").fetchone()[0]
    print(f"[INFO] {n_ps} pasos de proceso · {n_pp} pain points de suscripción")

    files = [
        ("as-is.md",       build_as_is(conn)),
        ("gaps.md",        build_gaps(conn)),
        ("process-map.md", build_process_map(conn)),
    ]
    conn.close()

    for fname, content in files:
        fpath = os.path.join(OUT_DIR, fname)
        with open(fpath, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"[OK] {fname}")

    print(f"\n[DONE] dt-underwriting-intelligence/ poblado → {OUT_DIR}")


if __name__ == "__main__":
    main()