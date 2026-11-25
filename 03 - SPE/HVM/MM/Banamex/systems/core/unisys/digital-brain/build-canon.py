#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-canon.py — Capa canónica del Enterprise Brain sobre el brain de Banamex.

Corre DESPUÉS de build-brain.py. No toca el pipeline histórico ni reescribe
una sola fila: añade la interfaz que exige el canon del Enterprise Brain
(`00 - Enterprise Brain/canon/brain-rules.md`) siguiendo la Regla B16,
"homologar por vista, no por migración".

Identidad del brain: brain_type='system', hemisphere='run', togaf_type='core'.
Implementa el CORE (25 tablas) + la extensión SYSTEM (11) + su lado del
PUENTE (findings, slos) — Reglas B15 y B24.

TRES MECANISMOS DE HOMOLOGACIÓN
───────────────────────────────
1. VISTA — la tabla histórica existe con otro nombre. Se expone con el nombre
   canónico sin tocar los datos. Es el patrón que el canon cita de este mismo
   brain (`risks` <- `hallazgos`).

      components             <- inventario LEFT JOIN programs
      capabilities           <- capacidades + conteo de programs
      data_entities          <- datasets + db_fisicas
      vocabulary             <- vocab_full
      journeys               <- flujos
      component_capabilities <- programs
      regulatory_obligations <- regulatory_reports
      findings               <- hallazgos
      business_milestones    <- cronologia_eventos

2. COLUMNA GENERADA — la tabla ya se llama como el canon pero sus columnas no.
   No se puede crear una vista con un nombre ocupado por una tabla, así que
   el nombre canónico se añade como columna VIRTUAL sobre la histórica:
   siempre en sincronía, cero almacenamiento, reversible con DROP COLUMN.

      rules              (rule_id -> id, nombre -> business_name, ...)
      cross_dependencies (dep_type -> dependency_type)

3. TABLA NUEVA — el concepto no existía. El DDL se LEE de
   `00 - Enterprise Brain/templates/schema.sql`, nunca se transcribe aquí
   (Regla B15: ese archivo es la única fuente de verdad del esquema).

NINGÚN HUECO SE DEJA MUERTO (Regla B17)
───────────────────────────────────────
Toda tabla canónica que queda vacía se registra en `knowledge_gaps` con una
`resolution_action` redactada como consulta concreta a un SME identificado.
No se inventa un dato ni se escribe 'PENDIENTE' en ningún campo.

Uso:  PYTHONUTF8=1 python build-canon.py [--db brain.db] [--report]
"""

from __future__ import annotations

import argparse
import datetime as _dt
import json
import re
import sqlite3
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
NOW = _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds")
TODAY = NOW[:10]

BRAIN_SLUG = "unisys-core"
BRAIN_VERSION = "4.0.0"
SOURCE_OF_TRUTH = (
    "systems/core/unisys/source/GemCogAlt/gemcog-chatbot-kb-2026-08-26/ (KB v1.13)"
)


# ─────────────────────────────────────────────────────────────────────────────
# Localización del canon
# ─────────────────────────────────────────────────────────────────────────────
def find_canon_schema() -> Path:
    """Sube hasta la raíz del ecosistema y devuelve templates/schema.sql."""
    for parent in HERE.parents:
        if parent.name == "Digital Core":
            candidate = parent / "00 - Enterprise Brain" / "templates" / "schema.sql"
            if candidate.exists():
                return candidate
    raise SystemExit(
        "No encuentro 00 - Enterprise Brain/templates/schema.sql. "
        "El canon es la única fuente del DDL (Regla B15); sin él no se construye nada."
    )


def extract_ddl(schema_sql: Path) -> dict[str, str]:
    """Devuelve {tabla: sentencia CREATE TABLE} del schema canónico."""
    text = schema_sql.read_text(encoding="utf-8")
    body = "\n".join(
        ln for ln in text.split("\n") if not ln.lstrip().startswith("--")
    )
    ddl: dict[str, str] = {}
    for m in re.finditer(
        r"(CREATE TABLE IF NOT EXISTS (\w+)\s*\(.*?\n\);)", body, re.S
    ):
        ddl[m.group(2)] = m.group(1)
    return ddl


# ─────────────────────────────────────────────────────────────────────────────
# Qué implementa este brain
# ─────────────────────────────────────────────────────────────────────────────
CORE = [
    "system_info", "cross_dependencies", "signals", "ontology_bindings",
    "capabilities", "processes", "knowledge_gaps", "itom_layer", "products",
    "kpis", "stakeholders", "data_entities", "technology_components",
    "suppliers", "measurements", "costs", "queries", "knowledge_lineage",
    "source_catalog", "company_profile", "business_milestones",
    "strategic_drivers", "driver_links", "action_catalog", "actions",
]
SYSTEM_EXT = [
    "components", "component_calls", "rules", "rule_enrichment_log",
    "vocabulary", "journeys", "component_capabilities", "component_processes",
    "component_data", "regulatory_obligations", "external_systems",
]
# Regla B24 — el hemisferio 'run' implementa su lado del puente
BRIDGE_RUN = ["findings", "slos"]

IMPLEMENTS = CORE + SYSTEM_EXT + BRIDGE_RUN

# Tablas que se resuelven por VISTA: no se crea la tabla canónica.
VIEW_BACKED = {
    "components", "capabilities", "data_entities", "vocabulary", "journeys",
    "component_capabilities", "regulatory_obligations", "findings",
}

# Tablas históricas que ya ocupan el nombre canónico: se homologan in situ.
IN_PLACE = {"rules", "cross_dependencies"}


# ─────────────────────────────────────────────────────────────────────────────
# 1. Vistas de homologación (Regla B16)
# ─────────────────────────────────────────────────────────────────────────────
#  `tier` se DERIVA, nunca se inventa (ADR-EB-010):
#    gold   — el hecho está en la KB validada directamente con el cliente
#    silver — destilado por el pipeline desde el corpus, sin validar con cliente
#    bronze — inferido por heurístico
VIEWS: dict[str, str] = {}

VIEWS["components"] = """
CREATE VIEW components AS
SELECT
    i.sistema || '-' || i.programa                       AS id,
    CASE WHEN p.prog_id IS NOT NULL THEN 'gold'
         ELSE 'silver' END                               AS tier,
    i.programa                                           AS name,
    COALESCE(NULLIF(TRIM(p.nombre), ''), i.programa)      AS display_name,
    NULLIF(TRIM(p.rol_funcional), '')                     AS description,
    COALESCE(NULLIF(TRIM(i.dominio), ''),
             NULLIF(TRIM(p.dominio_s), ''))               AS domain,
    i.tipo                                                AS tipo,
    NULL                                                  AS fan_in,
    i.aristas_salientes                                   AS fan_out,
    i.loc                                                 AS loc,
    NULL                                                  AS is_soul,
    NULL                                                  AS soul_rank,
    NULL                                                  AS archetype,
    NULLIF(TRIM(p.bc_id), '')                             AS primary_capability,
    'Unisys ClearPath MCP'                                AS current_platform,
    NULL                                                  AS target_platform,
    NULL                                                  AS migration_status,
    NULL                                                  AS origin_transition_id,
    'dt-mainframe-analyst'                                AS seeded_by,
    NULLIF(TRIM(p.confianza), '')                         AS fill_quality,
    'GemCogAlt KB v1.13 · inventario + program-registry'  AS source_doc,
    'active'                                              AS status
FROM inventario i
LEFT JOIN programs p
       ON p.prog_id = i.programa AND p.sistema = i.sistema;
"""

VIEWS["capabilities"] = """
CREATE VIEW capabilities AS
SELECT
    c.bc_id                                   AS id,
    'gold'                                    AS tier,
    'bian'                                    AS ontology,
    'v14'                                     AS ontology_version,
    'GemCogAlt KB v1.13'                      AS catalog_source,
    0                                         AS is_extension,
    NULLIF(TRIM(c.dominio), '')               AS l1_name,
    NULLIF(TRIM(c.subdominio), '')            AS l2_name,
    c.nombre                                  AS l3_name,
    NULLIF(TRIM(c.bian_ref), '')              AS definition,
    NULL                                      AS regulation,
    CASE WHEN t.n_reglas > 0 THEN 'covered'
         ELSE 'declared' END                  AS coverage_status,
    NULL                                      AS process_id,
    NULL                                      AS coverage_confidence,
    t.n_reglas                                AS coverage_evidence,
    c.sistema                                 AS primary_system,
    (SELECT COUNT(*) FROM programs p
      WHERE TRIM(p.bc_id) = c.bc_id)          AS component_count
FROM capacidades c
LEFT JOIN traceability t ON t.bc_id = c.bc_id;
"""

VIEWS["data_entities"] = """
CREATE VIEW data_entities AS
SELECT
    d.sistema || '-' || d.dataset                  AS id,
    'gold'                                         AS tier,
    d.dataset                                      AS name,
    NULLIF(TRIM(d.descripcion), '')                AS business_name,
    NULLIF(TRIM(d.descripcion), '')                AS description,
    'dataset'                                      AS entity_level,
    COALESCE(NULLIF(TRIM(f.nombre_fisico), ''),
             d.db_id)                              AS store,
    d.sistema || '-' || d.db_id                    AS technology_id,
    NULL                                           AS classification,
    NULL                                           AS regulation,
    NULL                                           AS owner_id,
    NULLIF(NULLIF(TRIM(d.poblacion), ''), '—')     AS row_count,
    'GemCogAlt KB v1.13 · modelo de datos DMSII'   AS source_doc
FROM datasets d
LEFT JOIN db_fisicas f
       ON f.db_id = d.db_id AND f.sistema = d.sistema;
"""

VIEWS["vocabulary"] = """
CREATE VIEW vocabulary AS
SELECT
    v.sistema || '-' || v.term                     AS id,
    CASE WHEN x.rule_id IS NOT NULL THEN 'gold'
         ELSE 'silver' END                         AS tier,
    v.term                                         AS term,
    NULLIF(NULLIF(TRIM(v.significado), ''), '—')   AS definition,
    NULLIF(TRIM(v.categoria), '')                  AS categoria,
    NULLIF(NULLIF(TRIM(v.alcance), ''), '—')       AS scope,
    NULL                                           AS process_id,
    NULL                                           AS domain,
    NULLIF(TRIM(v.confianza), '')                  AS maturity,
    v.sistema                                      AS source_system,
    NULLIF(NULLIF(TRIM(v.aliases), ''), '—')       AS aliases,
    v.frecuencia                                   AS est
FROM vocab_full v
LEFT JOIN (SELECT DISTINCT term, sistema, 1 AS rule_id FROM vocab_rule_xref) x
       ON x.term = v.term AND x.sistema = v.sistema;
"""

VIEWS["journeys"] = """
CREATE VIEW journeys AS
SELECT
    f.flujo_id                                     AS id,
    'gold'                                         AS tier,
    f.titulo                                       AS display_name,
    NULL                                           AS description,
    NULL                                           AS entry_component,
    NULL                                           AS call_depth,
    (LENGTH(f.programas) - LENGTH(REPLACE(f.programas, ',', '')) + 1)
                                                   AS component_count,
    NULL                                           AS domain,
    NULLIF(TRIM(f.xcap), '')                       AS cross_domains,
    NULL                                           AS process_id,
    NULLIF(TRIM(f.bc_id), '')                      AS capability_id,
    NULL                                           AS systems,
    'mermaid'                                      AS source_type
FROM flujos f;
"""

VIEWS["component_capabilities"] = """
CREATE VIEW component_capabilities AS
SELECT
    p.sistema || '-' || p.prog_id       AS component_id,
    'gold'                              AS tier,
    TRIM(p.bc_id)                       AS capability_id,
    'primary'                           AS mapping_type,
    'GemCogAlt program-registry'        AS source,
    NULLIF(TRIM(p.confianza), '')       AS confidence
FROM programs p
WHERE TRIM(COALESCE(p.bc_id, '')) <> '';
"""

VIEWS["regulatory_obligations"] = """
CREATE VIEW regulatory_obligations AS
SELECT
    r.reporte                                      AS id,
    'gold'                                         AS tier,
    r.regulador                                    AS regulator,
    r.reporte                                      AS instrument,
    NULL                                           AS article,
    NULLIF(TRIM(r.impacto), '')                    AS description,
    'reporte'                                      AS obligation_type,
    NULL                                           AS process_id,
    NULL                                           AS rol_aplicable,
    NULLIF(TRIM(r.periodicidad), '')               AS frequency,
    NULLIF(TRIM(r.deadline), '')                   AS penalty_risk,
    NULL                                           AS effective_date
FROM regulatory_reports r;
"""

# Lado Run del puente (Regla B24). La vista histórica `risks` se conserva
# porque brain.py la consume; ambas leen de `hallazgos`.
VIEWS["findings"] = """
CREATE VIEW findings AS
SELECT
    h.hallazgo_id                                  AS id,
    'gold'                                         AS tier,
    'hallazgo-migracion'                           AS finding_type,
    SUBSTR(h.riesgo, 1, 120)                       AS title,
    h.riesgo                                       AS description,
    NULLIF(TRIM(h.impacto), '')                    AS impact_if_ignored,
    NULLIF(TRIM(h.severidad), '')                  AS severity,
    CASE WHEN TRIM(COALESCE(h.severidad, '')) = ''
         THEN 'inline-en-texto' ELSE 'kb' END      AS severity_source,
    'task'                                         AS entity_type,
    NULLIF(TRIM(h.tareas), '')                     AS entity_ids,
    NULL                                           AS domain,
    NULLIF(TRIM(h.bc_id), '')                      AS capability_id,
    NULL                                           AS process_id,
    1                                              AS occurrences,
    NULL                                           AS first_seen,
    NULL                                           AS last_seen,
    NULLIF(TRIM(h.accion), '')                     AS recommended_action,
    'cap-' || h.cap_slug || '.md'                  AS discovered_from,
    NULL                                           AS discovered_at,
    'KB validada con el cliente'                   AS validated_by,
    'alta'                                         AS confidence,
    NULL                                           AS routed_to_brain,
    NULL                                           AS routed_to_tool,
    NULL                                           AS routed_ref,
    'open'                                         AS route_status
FROM hallazgos h;
"""

# `business_milestones` NO se homologa contra `cronologia_eventos`.
# Se intentó y es un error de categoría: el enum de `milestone_type` del canon
# (fundacion, fusion, adquisicion, ipo, crisis, entrada_mercado, salida_mercado,
# reestructura, sancion) describe hitos del NEGOCIO, y cronologia_eventos
# contiene cambios de código fechados ("Cambio Sin Nota", "Incluir transferencia
# automática del MOVSCIG"). Meter los segundos en la primera llenaría la tabla
# con filas que ningún consumidor del canon puede interpretar.
# La tabla queda vacía y declarada en knowledge_gaps; la historia técnica sigue
# viviendo en `cronologia_eventos` y `cronologia`, que no son canon pero son
# correctas en su propio nombre.


# ─────────────────────────────────────────────────────────────────────────────
# 2. Homologación in situ por columna generada
# ─────────────────────────────────────────────────────────────────────────────
# {tabla: {columna_canonica: (expresion | None)}}  None = columna real vacía
RENAMES: dict[str, dict[str, str]] = {
    "rules": {
        "id": "rule_id",
        "component_id": "sistema || '-' || programa",
        "tipo": "tipo_regla",
        "business_name": "nombre",
        "description": "descripcion",
        "reg": "regulador",
        "riesgo": "riesgos",
        "confidence": "confianza",
        "enrichment_method": "veredicto",
        # tier derivado del veredicto (ADR-EB-010). Solo es gold lo que validó
        # un SME real con nombre: "VALIDADO (analista)" a secas NO es gold,
        # porque el analista es parte del equipo que extrajo la regla, no una
        # autoridad independiente. Esa distinción es la que hace que el tier
        # signifique algo.
        "tier": (
            "CASE "
            "WHEN veredicto IS NULL OR TRIM(veredicto) = '' THEN 'bronze' "
            "WHEN veredicto LIKE '%SME%' OR veredicto LIKE '%Regulatorio%' "
            "     THEN 'gold' "
            "WHEN veredicto LIKE '%VALIDADO%' THEN 'silver' "
            "ELSE 'bronze' END"
        ),
    },
    "cross_dependencies": {
        "dependency_type": "dep_type",
        "tier": "'gold'",
    },
}

# Columnas del canon que la tabla histórica no puede expresar. Se añaden
# vacías y su ausencia se declara en knowledge_gaps (Regla B17).
ADDITIONS: dict[str, list[str]] = {
    "rules": ["linea", "condicion", "fragmento", "process_id", "domain"],
    "cross_dependencies": ["volume", "domains", "regulation", "origin_artifact"],
}


# ─────────────────────────────────────────────────────────────────────────────
# 3. Semillas con contenido real y trazable
# ─────────────────────────────────────────────────────────────────────────────
SYSTEM_INFO = {
    "slug": BRAIN_SLUG,
    "display_name": "Core Unisys — S500 Cargos y Abonos + S151 Movimientos Contables",
    "brain_type": "system",
    "hemisphere": "run",
    "togaf_type": "core",
    "togaf_state": "baseline",
    "togaf_abb": "core-banking-deposits-gl",
    # Mismo vocabulario que ontology_bindings.ontology y company_profile.
    # industries: si aquí dijera 'banca' y allá 'financial_services', ningún
    # loader de federación podría cruzar las tres tablas.
    "industry": "financial_services",
    "industry_sme": "SME/Industry/Industry Banking",
    "capability_model": "BIAN Service Landscape v14 (26 capacidades BC-XX)",
    "process_ontology": "Banca por producto financiero (captación, pagos, contabilidad)",
    "process_ontology_version": None,
    "itom_model": None,
    "itom_sme": "SME/Framework/IT Operating Model",
    "lob_dimension": None,
    "version": BRAIN_VERSION,
    "status": "active",
    "built_at": NOW,
    "source_of_truth": SOURCE_OF_TRUTH,
    "build_agent": "dt-mainframe-analyst",
}

# `ontology` es PRIMARY KEY y su dominio es la INDUSTRIA, no el catálogo
# (retail | financial_services | insurance). El catálogo elegido va en
# `catalog` + `model_type`. Por eso hay una sola fila, no una por catálogo.
ONTOLOGY_BINDINGS = [
    {
        "ontology": "financial_services", "role": "primary", "model_type": "bian",
        "catalog": "BIAN v14", "catalog_version": "v14",
        "industry_sme": "SME/Industry/Industry Banking",
        "regulators": json.dumps(["CNBV", "Banxico", "SAT", "IPAB", "CONDUSEF"],
                                 ensure_ascii=False),
        "l3_base": 26, "l3_extension": 0,
        "rationale": "Las 26 capacidades BC-XX de la KB vienen mapeadas a BIAN "
                     "en capability_bian_map (104 filas): es la ontología que el "
                     "corpus trae de origen. El ETB de banca no está cargado; "
                     "esa brecha vive en knowledge_gaps, no como un binding "
                     "declarado que nadie puede consultar.",
    },
]

STRATEGIC_DRIVERS = [
    {
        "id": "DRV-001", "driver_type": "reto",
        "title": "Separación Citi y Banamex",
        "description": "El desacoplamiento de los sistemas compartidos con Citi "
                       "obliga a identificar y romper todo punto donde el código "
                       "asume una sola institución.",
        "horizon": None, "priority": "alta", "status": "en_ejecucion",
        "declared_by": "README del programa de modernización",
        "source_ref": "03 - SPE/HVM/MM/Banamex/README.md",
    },
    {
        "id": "DRV-002", "driver_type": "objetivo",
        "title": "Reducción de MIPS y licenciamiento Unisys",
        "description": "El costo de la plataforma ClearPath MCP y su licenciamiento "
                       "es uno de los motores económicos de la modernización.",
        "horizon": None, "priority": "alta", "status": "en_ejecucion",
        "declared_by": "README del programa de modernización",
        "source_ref": "03 - SPE/HVM/MM/Banamex/README.md",
    },
    {
        "id": "DRV-003", "driver_type": "objetivo",
        "title": "Canales digitales y reportería cloud-native",
        "description": "Habilitar canales digitales y reportería regulatoria sobre "
                       "una plataforma moderna, hoy limitada por el batch nocturno.",
        "horizon": None, "priority": "media", "status": "en_ejecucion",
        "declared_by": "README del programa de modernización",
        "source_ref": "03 - SPE/HVM/MM/Banamex/README.md",
    },
]

COMPANY_PROFILE = {
    "slug": "banamex",
    "tier": "gold",
    "legal_name": "Banco Nacional de México, S.A.",
    "display_name": "Banamex",
    "founded_year": None,
    # `ownership` se deja nula a propósito: la estructura de control está en
    # plena transición por la separación de Citi y poner un valor sería
    # inventar un hecho. Va como hueco declarado.
    "ownership": None,
    "parent_group": None,
    "ticker": None,
    "hq_country": "MX",
    "geographies": json.dumps(["MX"], ensure_ascii=False),
    "industries": json.dumps(["financial_services"], ensure_ascii=False),
    "business_model": None,
    "source_ref": "CLAUDE.md del ecosistema Digital Core",
}

SOURCE_CATALOG = [
    {
        "id": "SRC-001", "ontology": "financial_services",
        "name": "GemCogAlt — base de conocimiento del gemelo cognitivo (KB v1.13)",
        "source_type": "doc", "generator_type": "parser",
        "cadence": "bajo demanda", "status": "activa", "natural_tier": "gold",
        "coverage_pct": 100.0,
        "enables": json.dumps(
            ["capabilities", "rules", "tasks", "findings", "journeys",
             "pseudocodigo"], ensure_ascii=False),
        "location": SOURCE_OF_TRUTH,
        "owner": "dt-knowledge-curator",
    },
    {
        "id": "SRC-002", "ontology": "financial_services",
        "name": "Corpus fuente S151 (104 archivos .txt)",
        "source_type": "codigo", "generator_type": "parser",
        "cadence": "bajo demanda", "status": "activa", "natural_tier": "gold",
        "coverage_pct": 99.0,
        "enables": json.dumps(["components", "vocabulary", "rules"],
                              ensure_ascii=False),
        "location": "systems/core/unisys/source/S151/",
        "owner": "dt-mainframe-analyst",
    },
    {
        "id": "SRC-003", "ontology": "financial_services",
        "name": "Corpus fuente S500 (114 archivos .txt)",
        "source_type": "codigo", "generator_type": "parser",
        "cadence": "bajo demanda", "status": "activa", "natural_tier": "gold",
        "coverage_pct": 96.0,
        "enables": json.dumps(["components", "vocabulary", "rules"],
                              ensure_ascii=False),
        "location": "systems/core/unisys/source/S500/extracted_source/",
        "owner": "dt-mainframe-analyst",
    },
    {
        "id": "SRC-004", "ontology": "financial_services",
        "name": "Corpus pendiente por solicitar (5 programas sin .txt)",
        "source_type": "codigo", "generator_type": "parser",
        "cadence": "bajo demanda", "status": "ausente", "natural_tier": "gold",
        "coverage_pct": 0.0,
        "enables": json.dumps(["equivalence-testing"], ensure_ascii=False),
        "location": "systems/core/unisys/source/CORPUS-PENDIENTE.md",
        "owner": "dt-knowledge-curator",
    },
]


def seed_technology_components(cur: sqlite3.Cursor) -> int:
    """La plataforma y sus bases DMSII son hechos del corpus, no inferencias."""
    # `support_status` queda en 'unknown' a propósito: que Unisys siga dando
    # soporte a esta versión de ClearPath es justo uno de los datos del caso de
    # negocio, y no lo tenemos confirmado. Se declara como hueco.
    rows = [
        (
            "TC-PLAT-01", "gold", "Unisys ClearPath MCP", "platform",
            None, "Unisys", None, "on_prem", "MX", "active",
            "unknown", None, "sunset", None,
            "Mainframe que ejecuta S500 y S151. Dialecto COBOL propio, ALGOL y "
            "WFL como lenguaje de orquestación batch.",
            SOURCE_OF_TRUTH,
        ),
        (
            "TC-DMSII-01", "gold", "DMSII", "dbms", None, "Unisys", None,
            "on_prem", "MX", "active", "unknown", None, "sunset", None,
            "Gestor de bases de datos jerárquico de ClearPath. Las estructuras "
            "se declaran en DASDL (13 archivos en el inventario).",
            SOURCE_OF_TRUTH,
        ),
    ]
    for db_id, sistema, nombre, pack, n_ds, poblacion in cur.execute(
        "SELECT db_id, sistema, nombre_fisico, pack, n_datasets, poblacion "
        "FROM db_fisicas"
    ).fetchall():
        desc = f"Base DMSII con {n_ds} dataset(s)"
        if poblacion and poblacion.strip() not in ("", "—"):
            desc += f". Población declarada: {poblacion.strip()}"
        if pack and pack.strip() not in ("", "—"):
            desc += f". Pack: {pack.strip()}"
        rows.append((
            f"{sistema}-{db_id}", "gold", nombre, "dbms", None,
            "Unisys", None, "on_prem", "MX", "active", "unknown", None,
            "sunset", None, desc + ".", SOURCE_OF_TRUTH,
        ))
    cur.executemany(
        "INSERT OR REPLACE INTO technology_components "
        "(id, tier, name, category, record_scope, vendor, version, hosting, "
        " location, status, support_status, end_of_support, standard_status, "
        " itom_layer_id, description, source_doc) "
        "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
        rows,
    )
    return len(rows)


def seed_suppliers(cur: sqlite3.Cursor) -> int:
    """
    Las organizaciones externas que escribieron código son proveedores reales,
    pero la evidencia es la división AUTHOR de los programas, no un contrato:
    entran como bronze y con `status` nulo, porque no sabemos si la relación
    sigue viva. Las áreas internas del propio banco NO entran — un área interna
    no es un proveedor, y meterla aquí ensucia el conteo.
    """
    internas = {
        "BANAMEX", "GRUPO DE CAPTACION", "INGENIERIA DE SISTEMAS BANAMEX",
        "FABRICA DE SOFTWARE BANAMEX (ING.SOFT.-JFC)",
    }
    rows = []
    for autor_id, display, n_prog, sistemas in cur.execute(
        "SELECT autor_id, display, n_programas, sistemas FROM autores "
        "WHERE tipo = 'organizacion'"
    ).fetchall():
        if display.strip().upper() in internas:
            continue
        rows.append((
            "SUP-" + re.sub(r"[^A-Z0-9]+", "-", display.upper())[:28].strip("-"),
            "bronze", display, None, "service_provider", None, 0, None, None,
            None, None, None, None, None, None,
            f"Organización acreditada en la división AUTHOR de {n_prog} "
            f"programa(s) de {sistemas}. Evidencia de autoría histórica, no de "
            f"una relación contractual vigente.",
            "brain.autores (minado del corpus)",
        ))
    cur.executemany(
        "INSERT OR REPLACE INTO suppliers "
        "(id, tier, name, business_name, kind, criticality, regulatory_flag, "
        " contract_ref, contract_end, slo_id, exit_plan, process_id, "
        " itom_layer_id, status, owner_role, description, source_doc) "
        "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
        rows,
    )
    return len(rows)


def seed_driver_links(cur: sqlite3.Cursor) -> int:
    """
    Ata cada driver a la evidencia concreta que ya vive en el brain.

    `entity_table` solo admite los anclajes que el canon enumera
    (capabilities, products, processes, rules, findings, risks, user_stories,
    applications) y `relation` solo sirve/bloquea/mide. Por eso DRV-002 se ata
    a las CAPACIDADES que contienen piezas ALGOL y no a los componentes: el
    componente no es un anclaje válido de driver en el canon.
    """
    links = []

    def add(driver, table, entity, relation, rationale):
        # `driver_links.id` es INTEGER AUTOINCREMENT: no se suministra.
        links.append((
            "gold", driver, table, entity, relation, rationale, "build-canon.py",
        ))

    # DRV-001 Separación Citi — los hallazgos que la bloquean
    for (hid,) in cur.execute(
        "SELECT hallazgo_id FROM hallazgos "
        "WHERE riesgo LIKE '%BNMEX%' OR riesgo LIKE '%SETID%' "
        "   OR riesgo LIKE '%Citi%' OR accion LIKE '%SETID%'"
    ).fetchall():
        add("DRV-001", "findings", hid, "bloquea",
            "Hallazgo que materializa el acoplamiento institucional que el "
            "driver de separación debe romper.")

    # DRV-002 MIPS — el ALGOL no transpilable fija el piso del calendario.
    # Se ata a las REGLAS de esas piezas, no a capacidades: las piezas ALGOL
    # están clasificadas como arquitectura y no tienen BC de negocio, así que
    # el anclaje por capacidad daría cero filas y el driver quedaría mudo.
    for (rid,) in cur.execute(
        "SELECT r.rule_id FROM rules r "
        "WHERE EXISTS (SELECT 1 FROM inventario i "
        "              WHERE i.tipo = 'ALGOL' AND i.sistema = r.sistema "
        "                AND r.programa LIKE '%' || i.programa || '%')"
    ).fetchall():
        add("DRV-002", "rules", rid, "bloquea",
            "Regla alojada en una pieza ALGOL: no transpilable, exige "
            "reescritura, y por eso condiciona el calendario de salida.")

    # DRV-003 Reportería — las reglas con carga regulatoria EXTERNA.
    # El filtro va por nombre de regulador y no por exclusión: la columna
    # `regulador` expresa la ausencia de cinco formas distintas ('—', 'N/A',
    # 'N/A — control interno', 'Interno', vacío), así que excluir solo algunas
    # dejaba pasar 1,148 reglas y el driver perdía todo significado.
    for (rid,) in cur.execute(
        "SELECT rule_id FROM rules "
        "WHERE regulador LIKE '%CNBV%' OR regulador LIKE '%Banxico%' "
        "   OR regulador LIKE '%SAT%' OR regulador LIKE '%IPAB%' "
        "   OR regulador LIKE '%CONDUSEF%' OR regulador LIKE '%UIF%'"
    ).fetchall():
        add("DRV-003", "rules", rid, "sirve",
            "Regla con carga regulatoria externa servida hoy por el batch "
            "nocturno; es lo que la reportería moderna tiene que seguir "
            "cumpliendo.")

    cur.execute("DELETE FROM driver_links WHERE source_ref = 'build-canon.py'")
    cur.executemany(
        "INSERT INTO driver_links "
        "(tier, driver_id, entity_table, entity_id, relation, rationale, "
        " source_ref) VALUES (?,?,?,?,?,?,?)",
        links,
    )
    return len(links)


def seed_knowledge_lineage(cur: sqlite3.Cursor) -> int:
    """
    Linaje por tabla: de dónde salió y quién lo validó (Regla B29, ADR-EB-010).

    `tier_basis` y `source_type` son enums del canon, no prosa libre: la razón
    en palabras va en `notes`. `id` es INTEGER AUTOINCREMENT, así que no se
    suministra; la idempotencia se resuelve borrando el linaje de tabla antes
    de reinsertarlo.
    """
    base = [
        ("capabilities", "gold", "validated", "document", SOURCE_OF_TRUTH,
         "Las 26 capacidades vienen de la KB validada directamente con el cliente."),
        ("rules", "gold", "validated", "document", SOURCE_OF_TRUTH,
         "Fichas de regla de la KB validada con el cliente. El tier por regla "
         "se afina con rules.tier, derivado del veredicto."),
        ("findings", "gold", "validated", "document", SOURCE_OF_TRUTH,
         "Sección 'Hallazgos de migración' de cada cap-*.md de la KB validada."),
        ("components", "silver", "sourced", "code", "systems/core/unisys/source/",
         "Inventario reconciliado contra el corpus: 217 de 217 dentro de ±5% "
         "del LOC real medido sobre el fuente."),
        ("vocabulary", "silver", "sourced", "code", "systems/core/unisys/source/",
         "Destilado del corpus por el pipeline. No hay validación del cliente "
         "término por término, y son casi 70 mil términos."),
        ("suppliers", "bronze", "ingested", "code", "systems/core/unisys/source/",
         "Minado de la división AUTHOR de los programas. Es evidencia de "
         "autoría histórica, no de una relación contractual vigente."),
        ("technology_components", "gold", "origin", "code",
         "systems/core/unisys/source/",
         "La plataforma y las bases DMSII se leen del propio corpus: los "
         "archivos DASDL declaran las estructuras."),
    ]
    cur.execute("DELETE FROM knowledge_lineage WHERE entity_id = '*'")
    rows = []
    for tbl, tier, basis, stype, sref, note in base:
        # entity_id es NOT NULL en el canon; '*' significa "toda la tabla".
        rows.append((
            tbl, "*", None, tier, basis, stype, sref, "v1.13",
            "dt-mainframe-analyst",
            "llm_synthesis" if stype == "document" else "extraccion",
            "KB validada con el cliente" if tier == "gold" else None,
            TODAY if tier == "gold" else None,
            None,
            note + " Linaje a nivel de tabla; el de cada afirmación se registra "
            "cuando un DT toca la fila.",
            json.dumps(["federacion"], ensure_ascii=False), TODAY, None, NOW,
        ))
    cur.executemany(
        "INSERT INTO knowledge_lineage "
        "(entity_table, entity_id, field, tier, tier_basis, source_type, "
        " source_ref, source_version, asserted_by, method, validated_by, "
        " validated_at, superseded_by, notes, exposed_for, valid_from, "
        " valid_to, recorded_at) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
        rows,
    )
    return len(rows)


# ─────────────────────────────────────────────────────────────────────────────
# 4. Huecos — ninguno se deja muerto (Regla B17)
# ─────────────────────────────────────────────────────────────────────────────
# `gap_type` y `dimension` son enums del canon:
#   gap_type  : dato | decisión | acceso | validación
#   dimension : negocio | tecnología | regulatoria | cultural
# La naturaleza fina del hueco va en la descripción, no en la columna.
#
# {tabla_vacia: (gap_type, dimension, impacto, requerido_para, consulta, owner)}
GAPS: dict[str, tuple[str, str, str, str, str, str]] = {
    "processes": (
        "dato", "negocio",
        "Sin ontología de procesos, la Regla B22 queda incumplida: ninguna regla, "
        "hallazgo ni capacidad se puede priorizar por impacto al negocio.",
        "B22 · priorización de olas de migración",
        "Solicitar al Industry Banking SME el árbol L1-L4 de procesos de banca "
        "mexicana para captación, pagos y contabilidad, y el criterio de "
        "asignación de una regla a un proceso.",
        "SME/Industry/Industry Banking",
    ),
    "itom_layer": (
        "dato", "tecnología",
        "El brain no declara cómo se opera hoy la plataforma que sostiene S500 y "
        "S151, así que no se puede dimensionar el modelo operativo destino.",
        "B23 · diseño del modelo operativo TO-BE",
        "Pedir al SME de IT Operating Model el anclaje de los 6 dominios ITOM "
        "v9.0 para una operación de mainframe Unisys, y a Banamex quién opera "
        "hoy cada dominio.",
        "SME/Framework/IT Operating Model",
    ),
    "products": (
        "dato", "negocio",
        "Sin catálogo de productos, la cadena de valor de la Regla B27 arranca "
        "rota: no hay a qué atar capacidades ni KPIs.",
        "B27 · cadena producto-KPI-proceso-aplicación",
        "Solicitar a Banamex el catálogo de productos de captación servidos por "
        "S500 (cheques, ahorro, nómina, inversión) con su identificador interno.",
        "SME/Industry/Industry Banking",
    ),
    "kpis": (
        "dato", "negocio",
        "No hay forma de medir si la modernización mejora o degrada el negocio.",
        "B27 · B41 · línea base medible",
        "Pedir al dueño de producto de Banamex los KPIs vigentes de cada producto "
        "de captación y su valor actual, para fijar la línea base pre-migración.",
        "Banamex — dueño de producto",
    ),
    "stakeholders": (
        "dato", "cultural",
        "El brain no sabe a quién consultar ni quién aprueba qué; cada gap "
        "regulatorio queda sin destinatario.",
        "B37 · ruteo de consultas y validaciones",
        "Levantar con el Account Lead el mapa RACI de la modernización: dueño de "
        "cada capacidad BC-XX, dueño contable y dueño regulatorio.",
        "Accenture — Account Lead",
    ),
    "measurements": (
        "acceso", "tecnología",
        "Sin mediciones no hay evidencia cuantitativa del comportamiento actual, "
        "que es la línea base contra la que se valida la equivalencia.",
        "B40 · B43 · equivalence testing",
        "Solicitar a Banamex las métricas de ejecución del batch nocturno: "
        "ventana, volumen por programa, consumo de MIPS y tasa de aborto.",
        "Banamex — operación de mainframe",
    ),
    "costs": (
        "acceso", "negocio",
        "El driver SD-02 de reducción de MIPS no se puede cuantificar ni "
        "defender sin la estructura de costo actual.",
        "B27 · caso de negocio de la modernización",
        "Pedir a Banamex el costo anual de la plataforma ClearPath: "
        "licenciamiento, hardware, soporte y personal dedicado.",
        "Banamex — finanzas de TI",
    ),
    "component_calls": (
        "dato", "tecnología",
        "El grafo de llamadas entre programas no está extraído, así que el radio "
        "de impacto de un cambio se estima a mano.",
        "B37 · análisis de blast radius",
        "Extraer las aristas CALL y ZIP del corpus con dt-mainframe-analyst; "
        "`inventario.aristas_salientes` tiene el conteo pero no el destino.",
        "dt-mainframe-analyst",
    ),
    "component_processes": (
        "dato", "negocio",
        "Depende de `processes`; mientras esa tabla esté vacía no hay relación "
        "que registrar.",
        "B22 · trazabilidad componente-proceso",
        "Bloqueado por el gap de `processes`. Al cargar la ontología de procesos, "
        "derivar esta relación desde component_capabilities.",
        "SME/Industry/Industry Banking",
    ),
    "component_data": (
        "dato", "tecnología",
        "La relación componente-entidad existe en `program_io` pero en prosa "
        "libre, no en forma consultable; el linaje de datos no es navegable.",
        "B42 · linaje de datos",
        "Normalizar `program_io.lee` y `program_io.escribe` a referencias de "
        "dataset. Hoy son texto redactado y no se pueden unir sin inventar.",
        "dt-mainframe-analyst",
    ),
    "rule_enrichment_log": (
        "validación", "tecnología",
        "El historial de enriquecimiento SBVR vive en markdown y en el historial "
        "de git, no en el brain, así que no se puede auditar desde la consulta.",
        "ADR-EB-004 · auditoría del enriquecimiento",
        "Cargar el historial de enrich-rules.py e integrate-triage.py desde los "
        "commits del rules-catalog hacia esta tabla.",
        "dt-knowledge-curator",
    ),
    "external_systems": (
        "acceso", "tecnología",
        "Los sistemas externos están descritos en `cross_dependencies` a nivel "
        "de dependencia, pero sin endpoints, códigos de error ni umbrales.",
        "B37 · diseño de las interfaces TO-BE",
        "Solicitar a Banamex el contrato de interfaz de SPEI, CECOBAN y "
        "PeopleSoft S254: endpoints, códigos de retorno y timeouts.",
        "Banamex — integración",
    ),
    "slos": (
        "acceso", "tecnología",
        "El lado Run del puente no declara compromisos de servicio, así que el "
        "gate de readiness de cada transición no tiene contra qué medirse.",
        "B24 · B36 · puente Change-Run",
        "Pedir a Banamex los acuerdos de nivel de servicio vigentes del batch "
        "nocturno y de la ventana en línea de S500.",
        "Banamex — operación de mainframe",
    ),
    "queries": (
        "dato", "tecnología",
        "Se puebla en tiempo de uso; vacía solo significa que el brain aún no ha "
        "respondido consultas registradas.",
        "B42 · B43 · B45",
        "No requiere acción: `queries` la escribe la API al responder. Se "
        "registra para que la ausencia no se lea como omisión.",
        "dt-knowledge-manager",
    ),
    "actions": (
        "dato", "tecnología",
        "Se puebla en tiempo de uso cuando un DT ejecuta una acción del catálogo.",
        "B39 · gobierno de acciones",
        "No requiere acción: `actions` la escribe el DT que actúa. Se registra "
        "para que la ausencia no se lea como omisión.",
        "dt-change-manager",
    ),
    "business_milestones": (
        "dato", "negocio",
        "El brain no conoce la historia de negocio del cliente, así que un "
        "hallazgo técnico no se puede explicar por lo que al banco le pasó.",
        "ADR-EB-015 · Etapa 0 Identidad",
        "Levantar con el Account Lead los hitos de negocio del banco (fusiones, "
        "adquisiciones, crisis, reestructuras) con año y fuente. Ojo: "
        "`cronologia_eventos` NO sirve para esto, son cambios de código, no "
        "hitos de negocio.",
        "Accenture — Account Lead",
    ),
}

# Huecos a nivel de columna: el canon pide un campo que la tabla histórica no
# puede expresar (Regla B16, párrafo final).
COLUMN_GAPS = [
    ("rules.linea", "dato", "tecnología",
     "Las reglas se trazan a programa, no a línea de código. El mejor estándar "
     "del estate (Gentera) traza a línea; aquí no se puede verificar una regla "
     "contra su fragmento exacto sin abrir el fuente.",
     "ADR-EB-004 · verificabilidad de la regla",
     "Re-extraer con dt-mainframe-analyst capturando número de línea y "
     "fragmento al momento de leer el fuente.",
     "dt-mainframe-analyst"),
    ("rules.condicion", "dato", "tecnología",
     "Sin la condición formalizada, la regla no es ejecutable como criterio de "
     "aceptación automático en equivalence testing.",
     "equivalence testing automatizado",
     "Derivar la condición desde el pseudocódigo ya cargado, regla por regla, "
     "con validación del SME de dominio.",
     "dt-mainframe-analyst"),
    ("components.fan_in", "dato", "tecnología",
     "`inventario` guarda aristas salientes pero no entrantes, así que no se "
     "puede ordenar los componentes por cuántos dependen de ellos.",
     "B37 · priorización por acoplamiento",
     "Derivar fan_in invirtiendo el grafo de llamadas una vez que "
     "`component_calls` esté poblada.",
     "dt-mainframe-analyst"),
    ("components.is_soul", "decisión", "tecnología",
     "Ningún componente está marcado como alma, pese a que la Capa 2 'Mapa de "
     "las Almas' identificó candidatos. El criterio no se bajó al brain.",
     "B37 · identificación de componentes críticos",
     "Definir el umbral de alma para este brain (LOC, fan_in, criticidad "
     "regulatoria) y marcarlo en el pipeline.",
     "dt-mainframe-analyst"),
    ("company_profile.ownership", "dato", "negocio",
     "La estructura de control del banco se deja nula a propósito: está en "
     "transición por la separación de Citi y ponerle un valor sería inventarlo.",
     "ADR-EB-015 · Etapa 0 Identidad",
     "Confirmar con el Account Lead la estructura de control vigente y la "
     "fecha efectiva del cambio, para fecharla con valid_from.",
     "Accenture — Account Lead"),
    ("technology_components.support_status", "dato", "tecnología",
     "No sabemos si Unisys sigue dando soporte a esta versión de ClearPath, "
     "así que las tres filas de plataforma quedan en 'unknown'.",
     "caso de negocio de salida de la plataforma",
     "Pedir a Banamex el contrato de soporte vigente de ClearPath MCP con su "
     "fecha de fin, que es un insumo directo del driver DRV-002.",
     "Banamex — mainframe"),
    ("capabilities.ontology (ETB)", "decisión", "negocio",
     "El brain ancla a BIAN porque es lo que el corpus trae, pero el resto del "
     "estate bancario compara por ETB de banca, así que hoy no es comparable "
     "con BanCoppel ni con Liverpool en el eje de capacidades.",
     "B21 · federación y comparación entre brains",
     "Decidir con el Industry Banking SME si se carga el ETB de banca como "
     "segundo eje o si la comparación se hace vía el mapeo BIAN a ETB.",
     "SME/Industry/Industry Banking"),
]


def seed_knowledge_gaps(cur: sqlite3.Cursor, empty: set[str]) -> int:
    rows, seq = [], 0

    def add(gap_id, gap_type, dim, desc, impact, required, action, owner):
        rows.append((
            gap_id, gap_type, dim, None, None, desc, impact, required, action,
            owner, "open", TODAY, None,
        ))

    for table in sorted(empty):
        if table not in GAPS:
            continue
        seq += 1
        gtype, dim, impact, required, action, owner = GAPS[table]
        add(f"KG-T-{seq:03d}", gtype, dim,
            f"La tabla canónica `{table}` está vacía en este brain.",
            impact, required, action, owner)

    for i, (ref, gtype, dim, impact, required, action, owner) in enumerate(
        COLUMN_GAPS, start=1
    ):
        # El motivo NO se templetea: en unos casos la tabla histórica no puede
        # expresar el campo y en otros simplemente no conocemos el dato. La
        # razón concreta de cada uno va en `impact`.
        add(f"KG-C-{i:03d}", gtype, dim,
            f"El canon pide `{ref}` y el brain no lo tiene.",
            impact, required, action, owner)

    # Huecos del corpus: lo que la KB documenta pero el corpus no tiene
    for j, (prog, sistema) in enumerate(
        [("P138", "S151"), ("P093", "S500"), ("P629", "S500"),
         ("P630", "S500"), ("P655", "S500")], start=1
    ):
        add(f"KG-S-{j:03d}", "acceso", "tecnología",
            f"{prog} ({sistema}) está documentado en la KB pero su archivo "
            f"fuente no está en el corpus.",
            "Sin el fuente crudo no hay golden master, así que la equivalencia "
            "funcional de este programa no se puede validar.",
            "equivalence testing de BUILD y TEST",
            f"Solicitar a Banamex el fuente de {prog}, o confirmar si existe "
            f"bajo otro nombre de archivo.",
            "Banamex — mainframe")

    # Huecos de ontología L1/L2 en capacidades
    add("KG-O-001", "dato", "negocio",
        "`capacidades.dominio` y `capacidades.subdominio` están vacías en la "
        "KB, así que capabilities.l1_name y l2_name salen nulas.",
        "Las 26 capacidades no se pueden agregar por nivel, que es justo lo que "
        "hace comparable este brain con los demás del estate.",
        "B21 · federación y comparación entre brains",
        "Derivar L1 y L2 del identificador BIAN que sí está en `bian_ref`, "
        "contra el BIAN Service Landscape v14 que suministra el Industry SME.",
        "SME/Industry/Industry Banking")

    cur.executemany(
        "INSERT OR REPLACE INTO knowledge_gaps "
        "(id, gap_type, dimension, domain, process_id, description, impact, "
        " required_for, resolution_action, owner, status, opened_at, "
        " resolved_at) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",
        rows,
    )
    return len(rows)


# ─────────────────────────────────────────────────────────────────────────────
# Motor
# ─────────────────────────────────────────────────────────────────────────────
def objects(cur: sqlite3.Cursor) -> dict[str, str]:
    return {
        n: t
        for n, t in cur.execute(
            "SELECT name, type FROM sqlite_master WHERE type IN ('table','view')"
        )
    }


def columns(cur: sqlite3.Cursor, table: str) -> set[str]:
    """
    table_xinfo, no table_info: `PRAGMA table_info` OMITE las columnas
    generadas, así que con table_info el guardia de idempotencia no las ve y
    el segundo build revienta con "duplicate column name".
    """
    return {r[1] for r in cur.execute(f'PRAGMA table_xinfo("{table}")')}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--db", default=str(HERE / "brain.db"))
    ap.add_argument("--report", action="store_true",
                    help="escribe canon-alignment.md junto al brain")
    args = ap.parse_args()

    db = Path(args.db)
    if not db.exists():
        raise SystemExit(f"No existe {db}. Corre primero build-brain.py.")

    ddl = extract_ddl(find_canon_schema())
    missing_ddl = [t for t in IMPLEMENTS if t not in ddl]
    if missing_ddl:
        raise SystemExit(
            "El canon no define estas tablas que este brain dice implementar: "
            + ", ".join(missing_ddl)
        )

    con = sqlite3.connect(str(db))
    con.execute("PRAGMA foreign_keys = OFF")
    cur = con.cursor()
    log: list[str] = []

    # ── Fase 1 · tablas canónicas nuevas ────────────────────────────────────
    existing = objects(cur)
    created = []
    for table in IMPLEMENTS:
        if table in VIEW_BACKED or table in IN_PLACE:
            continue
        if table in existing:
            continue
        cur.execute(ddl[table])
        created.append(table)
    log.append(f"Tablas canónicas creadas: {len(created)}")

    # ── Fase 2 · vistas de homologación ─────────────────────────────────────
    existing = objects(cur)
    views_made = []
    for name, sql in VIEWS.items():
        if existing.get(name) == "table":
            log.append(
                f"OMITIDA vista {name}: ya existe una TABLA con ese nombre. "
                f"Revisar a mano."
            )
            continue
        cur.execute(f'DROP VIEW IF EXISTS "{name}"')
        cur.execute(sql)
        views_made.append(name)
    log.append(f"Vistas de homologación: {len(views_made)}")

    # ── Fase 3 · homologación in situ ───────────────────────────────────────
    renamed, added = 0, 0
    for table, mapping in RENAMES.items():
        if objects(cur).get(table) != "table":
            log.append(f"OMITIDO rename en {table}: no es una tabla.")
            continue
        have = columns(cur, table)
        for canon_col, expr in mapping.items():
            if canon_col in have:
                continue
            cur.execute(
                f'ALTER TABLE "{table}" ADD COLUMN "{canon_col}" '
                f"GENERATED ALWAYS AS ({expr}) VIRTUAL"
            )
            renamed += 1
    for table, cols in ADDITIONS.items():
        if objects(cur).get(table) != "table":
            continue
        have = columns(cur, table)
        for col in cols:
            if col in have:
                continue
            cur.execute(f'ALTER TABLE "{table}" ADD COLUMN "{col}" TEXT')
            added += 1
    log.append(
        f"Columnas canónicas sobre tablas históricas: {renamed} generadas, "
        f"{added} vacías"
    )

    # ── Fase 4 · semillas ───────────────────────────────────────────────────
    cols = ", ".join(SYSTEM_INFO)
    ph = ", ".join("?" * len(SYSTEM_INFO))
    cur.execute(
        f"INSERT OR REPLACE INTO system_info ({cols}) VALUES ({ph})",
        tuple(SYSTEM_INFO.values()),
    )

    for row in ONTOLOGY_BINDINGS:
        cur.execute(
            f"INSERT OR REPLACE INTO ontology_bindings ({', '.join(row)}) "
            f"VALUES ({', '.join('?' * len(row))})",
            tuple(row.values()),
        )
    for row in STRATEGIC_DRIVERS:
        cur.execute(
            f"INSERT OR REPLACE INTO strategic_drivers "
            f"({', '.join(row)}, tier) VALUES ({', '.join('?' * len(row))}, 'gold')",
            tuple(row.values()),
        )
    for row in SOURCE_CATALOG:
        cur.execute(
            f"INSERT OR REPLACE INTO source_catalog ({', '.join(row)}) "
            f"VALUES ({', '.join('?' * len(row))})",
            tuple(row.values()),
        )
    cur.execute(
        f"INSERT OR REPLACE INTO company_profile ({', '.join(COMPANY_PROFILE)}) "
        f"VALUES ({', '.join('?' * len(COMPANY_PROFILE))})",
        tuple(COMPANY_PROFILE.values()),
    )

    n_tech = seed_technology_components(cur)
    n_sup = seed_suppliers(cur)
    n_lin = seed_knowledge_lineage(cur)
    n_dl = seed_driver_links(cur)
    log.append(
        f"Semillas: system_info 1, ontology_bindings {len(ONTOLOGY_BINDINGS)}, "
        f"strategic_drivers {len(STRATEGIC_DRIVERS)}, driver_links {n_dl}, "
        f"source_catalog {len(SOURCE_CATALOG)}, company_profile 1, "
        f"technology_components {n_tech}, suppliers {n_sup}, "
        f"knowledge_lineage {n_lin}"
    )

    # Catálogo de acciones: el canon lo trae sembrado
    seed_sql = find_canon_schema().parent / "action-catalog-seed.sql"
    if seed_sql.exists() and not cur.execute(
        "SELECT COUNT(*) FROM action_catalog"
    ).fetchone()[0]:
        cur.executescript(seed_sql.read_text(encoding="utf-8"))
        log.append(
            "action_catalog sembrado desde el canon: "
            f"{cur.execute('SELECT COUNT(*) FROM action_catalog').fetchone()[0]}"
        )

    # ── Fase 5 · huecos ─────────────────────────────────────────────────────
    con.commit()
    empty = set()
    for table in IMPLEMENTS:
        try:
            if cur.execute(f'SELECT COUNT(*) FROM "{table}"').fetchone()[0] == 0:
                empty.add(table)
        except sqlite3.Error as exc:
            log.append(f"No se pudo contar {table}: {exc}")
    cur.execute("DELETE FROM knowledge_gaps WHERE status = 'open'")
    n_gaps = seed_knowledge_gaps(cur, empty)
    log.append(f"knowledge_gaps abiertos: {n_gaps}")

    # ── Fase 6 · señal de build (Regla B12) ─────────────────────────────────
    # `empty` se midió ANTES de sembrar huecos y señales, que es lo correcto
    # para decidir qué hueco declarar, pero no para reportar: si se reporta ese
    # conjunto, un build limpio acusa dos tablas vacías de más (knowledge_gaps
    # y signals, que este mismo script acaba de llenar). Por eso se vuelve a
    # medir aquí.
    cur.execute("DELETE FROM signals WHERE signal LIKE 'canon.%'")
    for sig, val in [
        ("canon.aligned_at", NOW),
        ("canon.version", BRAIN_VERSION),
        ("canon.tables_implemented", str(len(IMPLEMENTS))),
        ("canon.open_gaps", str(n_gaps)),
    ]:
        cur.execute(
            "INSERT INTO signals (signal, value, source, ts) VALUES (?,?,?,?)",
            (sig, val, "build-canon.py", NOW),
        )
    con.commit()

    empty = set()
    for table in IMPLEMENTS:
        try:
            if cur.execute(f'SELECT COUNT(*) FROM "{table}"').fetchone()[0] == 0:
                empty.add(table)
        except sqlite3.Error:
            pass
    cur.execute(
        "INSERT INTO signals (signal, value, source, ts) VALUES (?,?,?,?)",
        ("canon.tables_empty", str(len(empty)), "build-canon.py", NOW),
    )
    con.commit()

    # ── Verificación ────────────────────────────────────────────────────────
    present = objects(cur)
    faltan = [t for t in IMPLEMENTS if t not in present]
    poblado = sum(1 for t in IMPLEMENTS if t not in empty)

    print("\n".join(log))
    print()
    print(f"Canon implementado   : {len(IMPLEMENTS) - len(faltan)}/{len(IMPLEMENTS)}")
    print(f"Con datos            : {poblado}")
    print(f"Vacías y declaradas  : {len(empty & set(IMPLEMENTS))}")
    if faltan:
        print("FALTAN: " + ", ".join(faltan))

    if args.report:
        write_report(cur, present, empty, faltan)
        print(f"Reporte: {HERE / 'canon-alignment.md'}")

    con.close()
    return 1 if faltan else 0


def write_report(cur, present, empty, faltan) -> None:
    def count(t):
        try:
            return cur.execute(f'SELECT COUNT(*) FROM "{t}"').fetchone()[0]
        except sqlite3.Error:
            return "—"

    lines = [
        "# Alineación del brain de Banamex al canon del Enterprise Brain",
        "",
        f"> Generado por `build-canon.py` el {TODAY}. **No editar a mano.**",
        "",
        f"Identidad declarada: `brain_type='system'`, `hemisphere='run'`, "
        f"`togaf_type='core'`, slug `{BRAIN_SLUG}`, versión {BRAIN_VERSION}.",
        "",
        "Implementa el CORE, la extensión SYSTEM y el lado Run del puente "
        "(Reglas B15 y B24). La homologación sigue la Regla B16: ninguna fila "
        "del pipeline histórico se reescribió.",
        "",
        "## Cobertura",
        "",
        "| Tabla canónica | Capa | Objeto | Origen histórico | Filas |",
        "|---|---|---|---|---|",
    ]
    capa = {**{t: "CORE" for t in CORE},
            **{t: "SYSTEM" for t in SYSTEM_EXT},
            **{t: "PUENTE" for t in BRIDGE_RUN}}
    origen = {
        "components": "inventario, programs", "capabilities": "capacidades",
        "data_entities": "datasets, db_fisicas", "vocabulary": "vocab_full",
        "journeys": "flujos", "component_capabilities": "programs",
        "regulatory_obligations": "regulatory_reports", "findings": "hallazgos",
        "rules": "rules (homologada in situ)",
        "cross_dependencies": "cross_dependencies (homologada in situ)",
    }
    for t in IMPLEMENTS:
        tipo = present.get(t, "AUSENTE")
        lines.append(
            f"| `{t}` | {capa[t]} | {tipo} | {origen.get(t, 'nueva')} | {count(t)} |"
        )

    lines += ["", "## Huecos declarados", "",
              "Cada hueco es una consulta concreta a un responsable "
              "identificado, nunca un `PENDIENTE` (Regla B17).", "",
              "| Id | Tipo | Qué falta | A quién se le pregunta |", "|---|---|---|---|"]
    for gid, gtype, desc, owner in cur.execute(
        "SELECT id, gap_type, description, owner FROM knowledge_gaps "
        "WHERE status = 'open' ORDER BY id"
    ):
        lines.append(f"| {gid} | {gtype} | {desc} | {owner} |")

    (HERE / "canon-alignment.md").write_text(
        "\n".join(lines) + "\n", encoding="utf-8"
    )


if __name__ == "__main__":
    sys.exit(main())
