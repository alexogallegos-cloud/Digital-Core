"""
validate.py — Brain Auditor · Health Check del Enterprise Brain
Versión: 1.3.0 · Enterprise Brain · Digital Core · Accenture México

Ejecuta las 9 dimensiones de validación sobre un brain.db y emite un reporte.
D8 valida el lado del puente Change–Run de este brain; el cruce entre brains
lo razona templates/callosum.py.
REPORTA, NO CORRIGE — nunca escribe en el brain.db (PRAGMA query_only).

USO:
    python validate.py --db digital-brain/brain.db --system informix
    python validate.py --db digital-brain/brain.db --summary
    python validate.py --db digital-brain/brain.db --dim business_name
    python validate.py --db digital-brain/brain.db --json    # para agregación cross-brain

EXIT CODES:
    0 = PASS  · 1 = FAIL (hallazgos bloqueantes) · 2 = error de ejecución
"""

import argparse
import json
import sqlite3
import subprocess
import sys
from pathlib import Path

# ── Contrato canónico ────────────────────────────────────────────────────────

# Canon v2.0 (ADR-EB-006) — destilado del estate, no aspiracional.
# CORE es obligatorio en todo brain; la extensión depende de brain_type.
# Regla B21 — la ontología de negocio (ontology_bindings + capabilities) es
# CORE: ningún brain está exento, tampoco los de proyecto.
CORE_TABLES = [
    # Identidad, ontología, cadena de valor (B27), habilitador IT, federación, honestidad
    "system_info", "ontology_bindings", "capabilities", "processes",
    "products", "kpis",                  # Regla B27 — orientación a producto y KPI
    # ADR-EB-009 — estructura TOGAF: stakeholders (B), datos (D) y tecnología (T)
    "stakeholders", "data_entities", "technology_components",
    "suppliers",                         # Regla B41 — de dt-supplier-relationship-manager (ADR-EB-011)
    "measurements", "costs",             # Regla B43 — serie y costo (ADR-EB-012)
    "itom_layer", "cross_dependencies", "signals", "knowledge_gaps",
    "knowledge_lineage",                 # Regla B37 — calidad y linaje (ADR-EB-010)
    "queries",                           # Regla B45 — objeto consulta (ADR-EB-013)
    "source_catalog",                    # de dt-source-steward (ADR-EB-014)
    # Etapa 0 Identidad — de dt-client-intelligence (ADR-EB-015)
    "company_profile", "business_milestones", "strategic_drivers", "driver_links",
]

EXTENSION_TABLES = {
    "system": [
        "components", "component_calls", "component_data", "rules", "rule_enrichment_log",
        "vocabulary", "journeys", "component_capabilities", "component_processes",
        "regulatory_obligations", "external_systems",
    ],
    "project": ["applications", "waves", "risks", "decisions", "user_stories"],
    "enterprise": ["federated_brains", "documents"],
}

# Regla B24 — cada hemisferio implementa SU lado del puente Change–Run.
# El cruce entre brains lo razona templates/callosum.py, no este validador.
BRIDGE_TABLES = {
    "system": ["findings", "slos"],
    "project": ["plateaus", "transitions", "readiness_gates", "slos"],
    "enterprise": [],
}

VALID_FATES = {
    "retain", "retire", "rehost", "replatform", "refactor",
    "rearchitect", "replace", "encapsulate",
}
VALID_TRANSITION_STATUS = {
    "planned", "in_progress", "coexisting", "cutover", "done", "cancelled",
}
VALID_GATE_STATUS = {"pending", "done", "waived", "blocked"}
VALID_SEVERITIES = {"blocker", "critical", "high", "medium", "low"}
VALID_ROUTE_STATUS = {"open", "routed", "accepted", "rejected", "resolved"}

# Tablas que deben vincular a un proceso de negocio (Regla B22)
PROCESS_LINKED_TABLES = [
    "rules", "vocabulary", "capabilities", "applications",
    "products", "kpis",              # Regla B27 — vinculados a proceso de negocio
    "risks", "user_stories", "regulatory_obligations",
    "knowledge_gaps", "journeys", "transitions", "findings", "slos",
    "suppliers",                     # Regla B22 — declara el proceso que habilita
    "measurements", "costs",         # ADR-EB-012
]

#: Roster exigible de la Regla B41, reformulado por ADR-EB-016. Son 24 ROLES y
#: no 24 nombres de carpeta: un brain cumple cuando ninguna de estas
#: responsabilidades queda sin dueño, con el nombre que ese brain use.
#:
#: La auditoría de noviembre de 2026 midió el cumplimiento de la formulación
#: vieja y dio cero de ocho brains, con intersección vacía entre los 44 nombres
#: del estate y estos 24. Una regla que nadie cumple y que nadie citó nunca no
#: está siendo incumplida: está mal escrita. Por eso aquí se mide cobertura de
#: responsabilidad y no coincidencia de nombres.
ROSTER_CANONICO = (
    # Categoría A — rol de TI (10). Cada uno encarna un rol del catálogo ITOM
    # de 46 que prescribe el SME de IT Operating Model.
    "dt-domain-architect", "dt-information-architect", "dt-knowledge-manager",
    "dt-asset-configuration-manager", "dt-change-manager",
    "dt-service-operations-lead", "dt-it-risk-manager", "dt-demand-manager",
    "dt-programme-manager", "dt-supplier-relationship-manager",
    # Categoría B — ingeniería del brain (5). No razonan sobre el cliente:
    # construyen y cuidan el brain.
    "dt-build-operator", "dt-human-reviewer", "dt-brain-engineer",
    "dt-brain-auditor", "dt-source-steward",
    # Categoría C — negocio (9). Destilados de los catálogos de industria,
    # no inventados.
    "dt-channel-owner", "dt-distribution-owner", "dt-product-owner",
    "dt-customer-owner", "dt-operations-owner", "dt-enterprise-functions-owner",
    "dt-business-support-owner", "dt-sustainability-owner",
    "dt-client-intelligence",
)

#: Dónde una instancia declara su mapeo de rol a DT propio. El primero que
#: exista manda. Sin ninguno, la cobertura es DESCONOCIDA y no cero, y esa
#: distinción es justo lo que ADR-EB-016 vino a fijar.
ROSTER_DECLARACIONES = ("dt/roster-dt.md", "roster-dt.md",
                        "knowledge-base/roster-dt.md")

#: Cómo una instancia declara que un rol no tiene dueño todavía. Un hueco
#: declarado es conocimiento; uno callado es el defecto.
ROSTER_HUECOS = {"", "—", "-", "–", "n/a", "na", "hueco", "[hueco]",
                 "sin dueño", "sin dueno", "pendiente", "ninguno"}

# Modelos lógicos de negocio admitidos como ancla de la ontología (B21)
VALID_MODEL_TYPES = {
    "etb", "bian", "regulatory", "it-capability", "value-chain", "client-logical", "itom",
}

CANONICAL_FTS = ["rules_fts", "vocabulary_fts"]

# Regla B37 — calidad y linaje del conocimiento
VALID_TIERS = {"gold", "silver", "bronze", "rejected"}
VALID_TIER_BASIS = {"origin", "validated", "sourced", "ingested", "demoted", "rejected"}
# Hechos irrefutables: entran directo a gold sin HITL
GOLD_BY_ORIGIN = {"code", "log", "monitoring", "job_run", "regulation", "signed_artifact"}
# Fuentes versionables: sin versión no se puede degradar cuando cambian
VERSIONED_ORIGINS = {"code", "log", "monitoring", "job_run"}
TIERED_TABLES = [
    "capabilities", "processes", "products", "kpis", "stakeholders", "data_entities",
    "technology_components", "itom_layer", "cross_dependencies", "components",
    "component_calls", "component_data", "component_capabilities", "component_processes",
    "rules", "vocabulary", "journeys", "regulatory_obligations", "external_systems",
    "applications", "waves", "risks", "decisions", "user_stories", "plateaus",
    "transitions", "readiness_gates", "slos", "findings", "suppliers",
    "measurements", "costs", "queries",
]
# Decisiones de gate que solo se sostienen sobre gold
GOLD_GATES = {
    "transitions": "LOWER(status) IN ('cutover','done')",
    "readiness_gates": "LOWER(status)='done'",
}
SILVER_STALE_DAYS = 90

# Columnas mínimas por tabla — ausencia = hallazgo bloqueante
REQUIRED_COLUMNS = {
    "system_info": ["slug", "display_name", "brain_type", "hemisphere",
                    "industry", "status"],
    "cross_dependencies": ["id", "other_system", "direction"],
    "components": ["id", "name", "domain", "primary_capability"],
    "rules": ["id", "component_id", "clase", "business_name", "reg"],
}

# Columnas recomendadas — ausencia = hallazgo no bloqueante (advertencia)
RECOMMENDED_COLUMNS = {
    "system_info": ["source_of_truth", "build_agent"],  # B31, B29
}

# Dimensiones que solo aplican a brains de sistema: los brains de proyecto
# modelan applications/waves/risks, no rules.
SYSTEM_ONLY_DIMS = {"business_name", "regulacion", "clase"}

VALID_CLASES = {"NEGOCIO", "INFRAESTRUCTURA", "ENSAMBLAJE", "PRESENTACION"}

# Placeholders del template sin reemplazar. Un brain que los conserva declara
# semántica falsa — es peor que no declararla (Regla B17).
PLACEHOLDERS = {"reemplazar", "todo", "pendiente", "tbd", "xxx", "n/a", "placeholder"}
VALID_HEMISPHERES = {"change", "run"}
VALID_BRAIN_TYPES = {"enterprise", "project", "system"}

ETB_COVERAGE_TARGET = 60.0  # SLO-EB-03

GENERIC_NAMES = [
    "proceso", "validación", "validacion", "cálculo", "calculo",
    "proceso de datos", "validación de registro", "actualización de tabla",
    "calcular valor", "procesar datos", "ejecutar procedimiento",
]
# GLOB es case-sensitive. Los patrones de palabra clave van anclados al inicio:
# sin anclar, "*IF *" marca texto español legítimo como "CNSIF cuando".
CODE_TOKEN_GLOBS = [
    "*vl_*", "*sp_*", "*vsql*", "*cCmd*", "*bdiburo*",
    "IF *", "DEFINE *", "SELECT *", "UPDATE *", "EXEC *", "LET *",
]

DIMENSIONS = [
    "schema", "coverage", "business_name", "regulacion", "clase",
    "cross_refs", "process_linkage", "callosum", "knowledge_quality",
    "roster",
]


class Finding:
    def __init__(self, dim, blocking, message, sample=None):
        self.dim = dim
        self.blocking = blocking
        self.message = message
        self.sample = sample or []

    def as_dict(self):
        return {
            "dim": self.dim,
            "blocking": self.blocking,
            "message": self.message,
            "sample": self.sample[:10],
        }


class Validator:
    def __init__(self, db_path: Path, system: str | None = None,
                 brain_type: str | None = None):
        self.db_path = Path(db_path)
        self.system = system
        self.findings: list[Finding] = []
        self.metrics: dict = {}
        self.dim_status: dict = {}
        self._tables: set[str] = set()
        self._forced_type = brain_type
        self.brain_type = brain_type or "system"

        if not self.db_path.exists():
            raise FileNotFoundError(f"brain.db no encontrado: {self.db_path}")

        self.db = sqlite3.connect(f"file:{self.db_path}?mode=ro", uri=True)
        self.db.row_factory = sqlite3.Row

    def close(self):
        self.db.close()

    # ── Helpers ──────────────────────────────────────────────────────────────

    def _scalar(self, sql, params=(), default=None):
        try:
            row = self.db.execute(sql, params).fetchone()
            return row[0] if row else default
        except sqlite3.Error:
            return default

    def _rows(self, sql, params=()):
        try:
            return [dict(r) for r in self.db.execute(sql, params).fetchall()]
        except sqlite3.Error:
            return []

    def _has(self, table: str) -> bool:
        return table in self._tables

    def _columns(self, table: str) -> set[str]:
        return {r["name"] for r in self._rows(f"PRAGMA table_info({table})")}

    def _add(self, dim, blocking, message, sample=None):
        self.findings.append(Finding(dim, blocking, message, sample))

    def _seal(self, dim):
        blocking = [f for f in self.findings if f.dim == dim and f.blocking]
        self.dim_status[dim] = "PASS" if not blocking else "FAIL"

    def _na(self, dim, reason):
        """Dimensión no evaluable — distinta de PASS, para no reportar salud falsa."""
        self._add(dim, False, reason)
        self.dim_status[dim] = "N/A "

    # ── D1 · Schema Integridad ───────────────────────────────────────────────

    def d1_schema(self):
        self._tables = {
            r["name"] for r in self._rows(
                "SELECT name FROM sqlite_master WHERE type IN ('table','view')"
            )
        }
        self.brain_type = self._detect_brain_type()
        self.metrics["brain_type_detected"] = self.brain_type
        if "system_info" in self._tables:
            info = (self._rows("SELECT * FROM system_info LIMIT 1") or [{}])[0]
            for k in ("slug", "brain_type", "hemisphere", "built_at", "status"):
                self.metrics.setdefault(k, info.get(k))

        bridge = BRIDGE_TABLES.get(self.brain_type, [])
        expected = (
            CORE_TABLES + EXTENSION_TABLES.get(self.brain_type, [])
            + [t for t in bridge if t not in EXTENSION_TABLES.get(self.brain_type, [])]
        )

        missing_core = [t for t in CORE_TABLES if t not in self._tables]
        if missing_core:
            self._add(
                "schema", True,
                f"{len(missing_core)} tablas del CORE ausentes "
                f"(obligatorias en todo brain)", missing_core,
            )

        missing_ext = [
            t for t in EXTENSION_TABLES.get(self.brain_type, [])
            if t not in self._tables
        ]
        if missing_ext:
            plural = "tablas" if len(missing_ext) > 1 else "tabla"
            self._add(
                "schema", True,
                f"{len(missing_ext)} {plural} de la extensión "
                f"'{self.brain_type}' ausente(s)", missing_ext,
            )

        missing_bridge = [t for t in bridge if t not in self._tables]
        if missing_bridge:
            self._add(
                "schema", True,
                f"Lado del puente Change–Run ausente para '{self.brain_type}' "
                f"(Regla B24)", missing_bridge,
            )

        missing_fts = [t for t in CANONICAL_FTS if t not in self._tables]
        if missing_fts:
            self._add("schema", False, "Tablas FTS5 ausentes (búsqueda degradada a LIKE)", missing_fts)

        for table, required in REQUIRED_COLUMNS.items():
            if not self._has(table):
                continue
            cols = self._columns(table)
            absent = [c for c in required if c not in cols]
            if absent:
                blocking = table == "rules" or any(
                    c in ("slug", "id", "component_id") for c in absent
                )
                self._add(
                    "schema", blocking,
                    f"Columnas requeridas ausentes en {table}", absent,
                )

        # Columnas recomendadas — hallazgo no bloqueante (B29 build_agent, B31 source_of_truth)
        for table, recommended in RECOMMENDED_COLUMNS.items():
            if not self._has(table):
                continue
            cols = self._columns(table)
            absent_rec = [c for c in recommended if c not in cols]
            if absent_rec:
                self._add(
                    "schema", False,
                    f"Columnas recomendadas ausentes en {table} "
                    f"(build_agent=B29 trazabilidad DT; source_of_truth=B31 fuente de verdad)",
                    absent_rec,
                )
            else:
                # Columna presente — verificar que tenga valor (no NULL ni vacío)
                for col in recommended:
                    if col in cols:
                        val = self._scalar(
                            f"SELECT {col} FROM {table} LIMIT 1", default=""
                        )
                        if not (val or "").strip():
                            self._add(
                                "schema", False,
                                f"{table}.{col} está presente pero vacío — "
                                f"{'declarar qué DT construyó el brain (Regla B29)' if col == 'build_agent' else 'declarar ruta del corpus fuente (Regla B31)'}",
                            )

        self.metrics["tables_present"] = len([t for t in expected if t in self._tables])
        self.metrics["tables_expected"] = len(expected)
        self._seal("schema")

    def _detect_brain_type(self) -> str:
        """
        brain_type declarado en system_info; si no existe, se infiere por las
        tablas presentes. Un brain sin system_info ya falla D1 por CORE ausente.
        """
        if self._forced_type:
            return self._forced_type

        if "system_info" in self._tables:
            rows = self._rows("SELECT brain_type FROM system_info LIMIT 1")
            declared = (rows[0].get("brain_type") or "").lower() if rows else ""
            if declared in VALID_BRAIN_TYPES:
                return declared

        # Varios brains pre-homologación declaran el tipo en brain_meta k/v
        # (Liverpool usa brain_type='federated' para lo que el canon llama
        # 'enterprise').
        if "brain_meta" in self._tables:
            rows = self._rows(
                "SELECT value FROM brain_meta WHERE key='brain_type' LIMIT 1"
            )
            declared = (rows[0].get("value") or "").lower() if rows else ""
            if declared in VALID_BRAIN_TYPES:
                return declared
            if declared in ("federated", "client", "bank"):
                return "enterprise"

        # Inferencia estructural por tablas presentes
        if self._tables & {"federated_brains", "systems", "sud_systems"}:
            return "enterprise"
        if self._tables & {
            "applications", "waves", "project_info", "program_info",
            "user_stories", "roadmap_phases",
        }:
            return "project"
        return "system"

    # ── D2 · Coverage ────────────────────────────────────────────────────────

    def d2_coverage(self):
        if not self._has("components"):
            self._na("coverage", "Tabla components ausente — coverage no medible")
            return

        total = self._scalar("SELECT COUNT(*) FROM components", default=0) or 0
        self.metrics["components"] = total

        if total == 0:
            self._add("coverage", False, "Brain sin componentes — scaffold vacío")
            self.metrics["etb_pct"] = 0.0
            self._seal("coverage")
            return

        cols = self._columns("components")
        cap_col = "primary_capability" if "primary_capability" in cols else (
            "etb_primary_l3" if "etb_primary_l3" in cols else None
        )
        if cap_col:
            con_etb = self._scalar(
                f"SELECT COUNT(*) FROM components "
                f"WHERE {cap_col} IS NOT NULL AND {cap_col} != ''",
                default=0,
            ) or 0
            etb_pct = round(100.0 * con_etb / total, 1)
            self.metrics["etb_pct"] = etb_pct
            if etb_pct < ETB_COVERAGE_TARGET:
                self._add(
                    "coverage", False,
                    f"Cobertura ETB {etb_pct}% por debajo del objetivo "
                    f"{ETB_COVERAGE_TARGET}% (SLO-EB-03) — deuda de conocimiento",
                )

        if "description" in cols:
            con_desc = self._scalar(
                "SELECT COUNT(*) FROM components "
                "WHERE description IS NOT NULL AND description != ''",
                default=0,
            ) or 0
            self.metrics["desc_pct"] = round(100.0 * con_desc / total, 1)

        self._seal("coverage")

    # ── D3 · business_name Quality ───────────────────────────────────────────

    def d3_business_name(self):
        if not self._has("rules"):
            self._na("business_name", "Tabla rules ausente")
            return

        total = self._scalar("SELECT COUNT(*) FROM rules", default=0) or 0
        self.metrics["rules"] = total
        if total == 0:
            self._seal("business_name")
            return

        if "business_name" not in self._columns("rules"):
            self._add("business_name", True, "Columna business_name ausente en rules")
            self._seal("business_name")
            return

        vacios = self._scalar(
            "SELECT COUNT(*) FROM rules WHERE business_name IS NULL OR business_name=''",
            default=0,
        ) or 0
        self.metrics["bn_vacios"] = vacios
        if vacios:
            sample = [
                r["id"] for r in self._rows(
                    "SELECT id FROM rules WHERE business_name IS NULL "
                    "OR business_name='' LIMIT 10"
                )
            ]
            self._add(
                "business_name", True,
                f"{vacios} reglas sin business_name (DoD-EB-02 exige 0)", sample,
            )

        placeholders = ",".join("?" * len(GENERIC_NAMES))
        genericos = self._rows(
            f"SELECT id, business_name FROM rules "
            f"WHERE LOWER(TRIM(business_name)) IN ({placeholders}) "
            f"OR (business_name IS NOT NULL AND business_name != '' "
            f"    AND LENGTH(business_name) < 10) LIMIT 50",
            tuple(GENERIC_NAMES),
        )
        self.metrics["bn_genericos"] = len(genericos)
        if genericos:
            self._add(
                "business_name", True,
                f"{len(genericos)} business_name genéricos o demasiado cortos",
                [f"{r['id']}: {r['business_name']}" for r in genericos],
            )

        glob_clause = " OR ".join("business_name GLOB ?" for _ in CODE_TOKEN_GLOBS)
        tokens = self._rows(
            f"SELECT id, business_name FROM rules WHERE {glob_clause} LIMIT 50",
            tuple(CODE_TOKEN_GLOBS),
        )
        self.metrics["bn_tokens"] = len(tokens)
        if tokens:
            self._add(
                "business_name", True,
                f"{len(tokens)} business_name contienen tokens de código fuente "
                f"(ADR-EB-004 exige síntesis, no transcripción)",
                [f"{r['id']}: {r['business_name']}" for r in tokens],
            )

        self._seal("business_name")

    # ── D4 · Regulación Coverage ─────────────────────────────────────────────

    def d4_regulacion(self):
        if not self._has("rules") or "reg" not in self._columns("rules"):
            self._add("regulacion", True, "Columna reg ausente en rules")
            self._seal("regulacion")
            return

        nulls = self._scalar(
            "SELECT COUNT(*) FROM rules WHERE reg IS NULL", default=0
        ) or 0
        self.metrics["reg_nulls"] = nulls
        if nulls:
            sample = [
                r["id"] for r in self._rows(
                    "SELECT id FROM rules WHERE reg IS NULL LIMIT 10"
                )
            ]
            self._add(
                "regulacion", True,
                f"{nulls} reglas con reg=NULL (no revisado). "
                f"reg='' es válido cuando no aplica regulación",
                sample,
            )
        self._seal("regulacion")

    # ── D5 · Clase Coverage ──────────────────────────────────────────────────

    def d5_clase(self):
        if not self._has("rules") or "clase" not in self._columns("rules"):
            self._add("clase", True, "Columna clase ausente en rules")
            self._seal("clase")
            return

        nulls = self._scalar(
            "SELECT COUNT(*) FROM rules WHERE clase IS NULL OR clase=''", default=0
        ) or 0
        self.metrics["clase_nulls"] = nulls
        if nulls:
            self._add("clase", True, f"{nulls} reglas sin clase asignada")

        dist = self._rows(
            "SELECT clase, COUNT(*) as n FROM rules "
            "WHERE clase IS NOT NULL GROUP BY clase ORDER BY n DESC"
        )
        self.metrics["clase_dist"] = {r["clase"]: r["n"] for r in dist}
        invalidas = [r["clase"] for r in dist if r["clase"] not in VALID_CLASES]
        if invalidas:
            self._add(
                "clase", True,
                f"{len(invalidas)} valores de clase fuera del canon "
                f"({'|'.join(sorted(VALID_CLASES))})",
                invalidas,
            )
        self._seal("clase")

    # ── D6 · Cross-References ────────────────────────────────────────────────

    def d6_cross_refs(self):
        # P5 · ADR-EB-002 — se evalúa siempre, no depende de system_info
        ignored = self._git_ignored(self.db_path)
        self.metrics["gitignored"] = ignored
        if ignored is False:
            self._add(
                "cross_refs", True,
                "brain.db NO está en .gitignore (ADR-EB-002 / Regla P5)",
            )

        if not self._has("system_info"):
            self._add("cross_refs", True, "Tabla system_info ausente")
            self._seal("cross_refs")
            return

        info = self._rows("SELECT * FROM system_info LIMIT 1")
        if not info:
            self._add("cross_refs", True, "system_info vacía — brain sin identidad declarada")
            self._seal("cross_refs")
            return

        info = info[0]
        self.metrics["slug"] = info.get("slug")
        self.metrics["status"] = info.get("status")
        self.metrics["built_at"] = info.get("built_at")
        self.metrics["hemisphere"] = info.get("hemisphere")
        self.metrics["brain_type"] = info.get("brain_type")

        status = (info.get("status") or "").lower()
        if status in ("discovered", "seeded"):
            self._add(
                "cross_refs", False,
                f"status='{status}' — brain semilla, no elegible para RELEASE",
            )
        elif status not in ("active", "building", "stale", "archived"):
            self._add("cross_refs", True, f"status='{status}' fuera del canon")

        # B13 · B14 — hemisferio y tipo de brain
        hemi = (info.get("hemisphere") or "").lower()
        if not hemi:
            self._add("cross_refs", True, "system_info.hemisphere no declarado (Regla B13)")
        elif hemi not in VALID_HEMISPHERES:
            self._add(
                "cross_refs", True,
                f"hemisphere='{hemi}' inválido — debe ser change|run (Regla B13)",
            )

        btype = (info.get("brain_type") or "").lower()
        if not btype:
            self._add("cross_refs", True, "system_info.brain_type no declarado (Regla B14)")
        elif btype not in VALID_BRAIN_TYPES:
            self._add(
                "cross_refs", True,
                f"brain_type='{btype}' inválido — debe ser "
                f"enterprise|project|system (Regla B14)",
            )

        # B19 — la semántica la suministra el Industry SME, no el brain
        self.metrics["industry"] = info.get("industry")
        self.metrics["capability_model"] = info.get("capability_model")
        self.metrics["process_ontology"] = info.get("process_ontology")

        if not (info.get("industry") or "").strip():
            self._add(
                "cross_refs", True,
                "system_info.industry no declarado — sin él no se resuelve "
                "vocabulario, capabilities, procesos ni regulador (Regla B19)",
            )
        if not (info.get("capability_model") or "").strip():
            self._add(
                "cross_refs", False,
                "capability_model no declarado — la ontología de capabilities "
                "queda implícita (Regla B2)",
            )

        # Regla B17 — placeholders del template sin reemplazar
        sucios = [
            f"{k}='{v}'" for k, v in info.items()
            if isinstance(v, str) and v.strip().lower() in PLACEHOLDERS
        ]
        if sucios:
            self._add(
                "cross_refs", True,
                f"{len(sucios)} campos de system_info conservan placeholders "
                f"del template — semántica falsa (Regla B17)", sucios,
            )

        self._check_ontology_composition()
        if not (info.get("process_ontology") or "").strip():
            self._add(
                "cross_refs", False,
                "process_ontology no declarada — la ontología de procesos es "
                "distinta por industria y no se deriva de capabilities (B19)",
            )

        # Seeds — B11
        brain_dir = self.db_path.parent
        deps = self._scalar(
            "SELECT COUNT(*) FROM cross_dependencies", default=0
        ) if self._has("cross_dependencies") else 0
        seeds_dir = brain_dir / "seeds"
        self.metrics["cross_deps"] = deps
        self.metrics["seeds"] = len(list(seeds_dir.glob("*.json"))) if seeds_dir.exists() else 0
        if deps and self.metrics["seeds"] == 0:
            self._add(
                "cross_refs", False,
                f"{deps} cross_dependencies declaradas pero seeds/ vacío (Regla B11)",
            )

        self._seal("cross_refs")

    def _check_ontology_composition(self):
        """
        Regla B20 — la ontología declarada y la cargada deben coincidir.
        Una ontología cargada sin declarar es semántica no gobernada; una
        declarada sin cargar es promesa incumplida.
        """
        if not self._has("ontology_bindings"):
            return

        bindings = self._rows("SELECT * FROM ontology_bindings")
        declared = {
            r["ontology"] for r in bindings if r.get("ontology")
        }
        self.metrics["ontologies_declared"] = sorted(declared)

        if not bindings:
            self._add(
                "cross_refs", True,
                "ontology_bindings vacía — todo brain ancla su ontología de "
                "negocio a un ETB u otro modelo lógico (Regla B21)",
            )
            return

        # B21 — el tipo de modelo debe estar declarado y ser válido
        self.metrics["model_types"] = sorted(
            {r.get("model_type") for r in bindings if r.get("model_type")}
        )
        malos = [
            f"{r.get('ontology')}: model_type='{r.get('model_type') or ''}'"
            for r in bindings
            if (r.get("model_type") or "").strip().lower() not in VALID_MODEL_TYPES
        ]
        if malos:
            self._add(
                "cross_refs", True,
                f"model_type ausente o fuera del canon "
                f"({'|'.join(sorted(VALID_MODEL_TYPES))}) — Regla B21",
                malos,
            )

        sin_catalogo = [
            r.get("ontology") for r in bindings
            if not (r.get("catalog") or "").strip()
        ]
        if sin_catalogo:
            self._add(
                "cross_refs", False,
                "Ontologías sin `catalog` declarado — no se puede trazar de "
                "qué modelo salieron las capabilities (Regla B21)",
                sin_catalogo,
            )

        roles = [
            r["role"] for r in self._rows(
                "SELECT role FROM ontology_bindings WHERE role='primary'"
            )
        ]
        if declared and len(roles) != 1:
            self._add(
                "cross_refs", True,
                f"ontology_bindings debe tener exactamente una ontología "
                f"role='primary' (encontradas {len(roles)}) — es la que fija "
                f"el nombre del brain (Regla B18)",
            )

        if not self._has("capabilities"):
            return

        loaded = {
            r["ontology"] for r in self._rows(
                "SELECT DISTINCT ontology FROM capabilities "
                "WHERE ontology IS NOT NULL"
            )
        }
        self.metrics["ontologies_loaded"] = sorted(loaded)

        sin_declarar = sorted(loaded - declared)
        if sin_declarar:
            self._add(
                "cross_refs", True,
                "Ontologías cargadas en capabilities pero no declaradas en "
                "ontology_bindings (Regla B20)", sin_declarar,
            )

        sin_cargar = sorted(declared - loaded)
        if sin_cargar:
            self._add(
                "cross_refs", False,
                "Ontologías declaradas sin capabilities cargadas (Regla B20)",
                sin_cargar,
            )

    # ── D7 · Process Linkage ─────────────────────────────────────────────────

    def d7_process_linkage(self):
        """
        Regla B22 — todo conocimiento ata a un proceso de negocio.
        Cuenta filas huérfanas (process_id IS NULL) en cada tabla de conocimiento.
        Un brain con conocimiento huérfano no puede activarse.
        """
        if not self._has("processes"):
            self._add(
                "process_linkage", True,
                "Tabla processes ausente — sin ontología de procesos, ningún "
                "conocimiento puede atarse (Regla B22)",
            )
            self._seal("process_linkage")
            return

        proc_count = self._scalar("SELECT COUNT(*) FROM processes", default=0) or 0
        self.metrics["processes"] = proc_count

        missing_col: list[str] = []
        with_orphans: dict[str, int] = {}
        for table in PROCESS_LINKED_TABLES:
            if not self._has(table):
                continue
            if "process_id" not in self._columns(table):
                missing_col.append(table)
                continue
            n = self._scalar(
                f"SELECT COUNT(*) FROM {table} WHERE process_id IS NULL",
                default=0,
            ) or 0
            if n:
                with_orphans[table] = n

        self.metrics["orphan_knowledge"] = with_orphans

        if missing_col:
            self._add(
                "process_linkage", True,
                f"Columna process_id ausente en {len(missing_col)} tabla(s) "
                f"— no puede validarse el vínculo a proceso (Regla B22)",
                missing_col,
            )

        if with_orphans:
            total = sum(with_orphans.values())
            sample = [f"{t}: {n}" for t, n in sorted(with_orphans.items())]
            self._add(
                "process_linkage", True,
                f"{total} filas de conocimiento sin process_id en "
                f"{len(with_orphans)} tabla(s) — conocimiento huérfano "
                f"no se puede priorizar ni agregar (Regla B22)",
                sample,
            )

        if proc_count == 0 and not missing_col and not with_orphans:
            self._add(
                "process_linkage", False,
                "processes vacía — scaffold sin ontología de procesos cargada",
            )

        self._seal("process_linkage")

    # ── D8 · Puente Change–Run (cuerpo calloso) ──────────────────────────────

    def d8_callosum(self):
        """
        Regla B24 — valida el lado del puente que le toca a ESTE brain.
        Si el puente cruza bien entre brains lo razona callosum.py vía ATTACH.
        """
        if self.brain_type == "project":
            self._callosum_change_side()
        elif self.brain_type == "system":
            self._callosum_run_side()
        else:
            self._na(
                "callosum",
                "El enterprise brain no tiene lado propio: razona el cruce "
                "con templates/callosum.py",
            )
            return
        self._slo_kpi_trace()
        self._seal("callosum")

    def _slo_kpi_trace(self):
        """Regla B36 — un SLO de TI sin KPI de negocio es un motor sin dirección."""
        if not self._has("slos") or "kpi_id" not in self._columns("slos"):
            return
        sin_kpi = self._scalar(
            "SELECT COUNT(*) FROM slos WHERE kpi_id IS NULL OR kpi_id=''", default=0
        ) or 0
        self.metrics["slos_sin_kpi"] = sin_kpi
        if sin_kpi:
            self._add(
                "callosum", False,
                f"{sin_kpi} SLOs sin kpi_id — el círculo TI-negocio no cierra (Regla B36)",
            )

    def _callosum_change_side(self):
        if not self._has("transitions"):
            self._add("callosum", True, "Tabla transitions ausente — Change no declara qué entrega a Run")
            return

        rows = self._rows("SELECT * FROM transitions")
        self.metrics["transitions"] = len(rows)

        malas = [
            f"{r['id']}: fate='{r.get('fate')}'" for r in rows
            if (r.get("fate") or "").lower() not in VALID_FATES
        ]
        if malas:
            self._add(
                "callosum", True,
                f"{len(malas)} transiciones con fate fuera del canon "
                f"({'|'.join(sorted(VALID_FATES))}). Un destino desconocido no "
                f"es transición: va a knowledge_gaps (Regla B17)", malas,
            )

        estados = [
            f"{r['id']}: status='{r.get('status')}'" for r in rows
            if (r.get("status") or "").lower() not in VALID_TRANSITION_STATUS
        ]
        if estados:
            self._add("callosum", True, f"{len(estados)} transiciones con status fuera del canon", estados)

        sin_destino = [
            r["id"] for r in rows
            if not (r.get("from_system") or "").strip() or not (r.get("to_system") or "").strip()
        ]
        if sin_destino:
            self._add(
                "callosum", True,
                f"{len(sin_destino)} transiciones sin from_system/to_system — "
                f"el enterprise brain no puede encontrar al brain de Run que hereda",
                sin_destino,
            )

        if self._has("plateaus"):
            huerfanas = [
                r["id"] for r in self._rows(
                    "SELECT t.id FROM transitions t "
                    "LEFT JOIN plateaus p ON p.id = t.plateau_id WHERE p.id IS NULL"
                )
            ]
            if huerfanas:
                self._add(
                    "callosum", True,
                    f"{len(huerfanas)} transiciones apuntan a un plateau inexistente",
                    huerfanas,
                )

        # Lo que ya cruzó (o está cruzando) a Run debe estar listo para operarse
        cerradas = [r for r in rows if (r.get("status") or "").lower() in ("cutover", "done")]
        sin_owner = [r["id"] for r in cerradas if not (r.get("run_owner") or "").strip()]
        if sin_owner:
            self._add(
                "callosum", True,
                f"{len(sin_owner)} transiciones en cutover/done sin run_owner — "
                f"Run no sabe que hereda algo", sin_owner,
            )

        if self._has("readiness_gates") and cerradas:
            no_listas = []
            for r in cerradas:
                gates = self._rows(
                    "SELECT gate, status FROM readiness_gates WHERE transition_id=?",
                    (r["id"],),
                )
                pend = [g["gate"] for g in gates if g["status"] not in ("done", "waived")]
                if not gates:
                    no_listas.append(f"{r['id']}: sin gates")
                elif pend:
                    no_listas.append(f"{r['id']}: pendientes {','.join(pend)}")
            if no_listas:
                self._add(
                    "callosum", True,
                    f"{len(no_listas)} transiciones cruzaron a Run sin readiness completa",
                    no_listas,
                )

        if self._has("slos"):
            sin_target = self._scalar(
                "SELECT COUNT(*) FROM slos WHERE target IS NULL OR target=''", default=0
            ) or 0
            if sin_target:
                self._add(
                    "callosum", False,
                    f"{sin_target} SLOs sin target — Change no fijó el contrato que Run medirá",
                )

    def _callosum_run_side(self):
        if not self._has("findings"):
            self._add("callosum", True, "Tabla findings ausente — Run no tiene cómo devolver lo que aprende")
            return

        rows = self._rows("SELECT * FROM findings")
        self.metrics["findings"] = len(rows)

        malas = [
            f"{r['id']}: severity='{r.get('severity')}'" for r in rows
            if (r.get("severity") or "").lower() not in VALID_SEVERITIES
        ]
        if malas:
            self._add(
                "callosum", True,
                f"{len(malas)} hallazgos con severidad fuera del canon "
                f"({'|'.join(sorted(VALID_SEVERITIES))}); el valor original va "
                f"en severity_source", malas,
            )

        rutas = [
            f"{r['id']}: route_status='{r.get('route_status')}'" for r in rows
            if (r.get("route_status") or "").lower() not in VALID_ROUTE_STATUS
        ]
        if rutas:
            self._add("callosum", True, f"{len(rutas)} hallazgos con route_status fuera del canon", rutas)

        graves_sin_ruta = [
            r["id"] for r in rows
            if (r.get("severity") or "").lower() in ("blocker", "critical")
            and (r.get("route_status") or "").lower() == "open"
        ]
        self.metrics["findings_graves_sin_ruta"] = len(graves_sin_ruta)
        if graves_sin_ruta:
            self._add(
                "callosum", False,
                f"{len(graves_sin_ruta)} hallazgos blocker/critical sin rutear — "
                f"correr callosum.py para saber si tocan algo en transición",
                graves_sin_ruta,
            )

        ruteados_sin_destino = [
            r["id"] for r in rows
            if (r.get("route_status") or "").lower() in ("routed", "accepted")
            and not (r.get("routed_to_brain") or "").strip()
            and not (r.get("routed_to_tool") or "").strip()   # Regla B38 — o a una herramienta
        ]
        if ruteados_sin_destino:
            self._add(
                "callosum", True,
                f"{len(ruteados_sin_destino)} hallazgos marcados como ruteados sin destino "
                f"(routed_to_brain o routed_to_tool)",
                ruteados_sin_destino,
            )

    @staticmethod
    def _git_ignored(path: Path) -> bool | None:
        # La ruta debe resolverse a absoluta: git la interpreta relativa a cwd,
        # y cwd es el directorio del brain, no aquel desde donde se invocó.
        try:
            target = path.resolve()
            r = subprocess.run(
                ["git", "check-ignore", "-q", str(target)],
                cwd=target.parent, capture_output=True, timeout=15,
            )
            # 0 = ignorado · 1 = no ignorado · 128 = fuera de repo git
            if r.returncode == 128:
                return None
            return r.returncode == 0
        except (OSError, subprocess.SubprocessError):
            return None

    # ── D9 · Calidad y linaje del conocimiento ───────────────────────────────

    def d9_knowledge_quality(self):
        """
        Regla B37 — cada afirmación declara su nivel (gold, silver, bronze) y su
        fuente. Los hechos irrefutables entran directo a gold; el resto sube por
        validación HITL. Las decisiones de gate solo se sostienen sobre gold.
        """
        dim = "knowledge_quality"
        present = [t for t in TIERED_TABLES if self._has(t)]
        sin_tier = [t for t in present if "tier" not in self._columns(t)]
        if sin_tier:
            self._add(
                dim, True,
                f"{len(sin_tier)} tablas de conocimiento sin columna tier — el brain "
                f"no distingue hecho de hipótesis (Regla B37)", sin_tier,
            )
        tiered = [t for t in present if t not in sin_tier]

        totals = {k: 0 for k in VALID_TIERS}
        invalid = []
        for t in tiered:
            for r in self._rows(f"SELECT LOWER(tier) AS tier, COUNT(*) AS n FROM {t} GROUP BY 1"):
                if r["tier"] in totals:
                    totals[r["tier"]] += r["n"]
                else:
                    invalid.append(f"{t}: '{r['tier']}' ({r['n']})")
        if invalid:
            self._add(dim, True, "Valores de tier fuera del canon", invalid)
        n = sum(totals.values())
        self.metrics["tier_totals"] = totals
        self.metrics["tier_pct"] = {
            k: round(100.0 * v / n, 1) if n else 0 for k, v in totals.items()
        }

        # Decisiones de gate sobre conocimiento que no es gold
        for t, cond in GOLD_GATES.items():
            if t not in tiered:
                continue
            rows = self._rows(f"SELECT * FROM {t} WHERE {cond} AND LOWER(tier)!='gold'")
            bad = [str(r.get("id") or r.get("transition_id")) for r in rows]
            if bad:
                self._add(
                    dim, True,
                    f"{len(bad)} filas de {t} en estado de decisión sin ser gold — "
                    f"un cutover o un gate cerrado no se sostiene sobre silver", bad,
                )

        if not self._has("knowledge_lineage"):
            self._seal(dim)
            return

        self.metrics["lineage_rows"] = self._scalar(
            "SELECT COUNT(*) FROM knowledge_lineage", default=0
        )
        vigentes = self._rows("SELECT * FROM knowledge_lineage WHERE superseded_by IS NULL")

        malos = [
            f"{r['entity_table']}:{r['entity_id']} tier={r['tier']} basis={r['tier_basis']}"
            for r in vigentes
            if (r["tier"] or "").lower() not in VALID_TIERS
            or (r["tier_basis"] or "").lower() not in VALID_TIER_BASIS
        ]
        if malos:
            self._add(dim, True, f"{len(malos)} registros de linaje con tier o tier_basis fuera del canon", malos)

        golds = [r for r in vigentes if (r["tier"] or "").lower() == "gold"]
        salto = [
            f"{r['entity_table']}:{r['entity_id']} ({r['source_type']})" for r in golds
            if r["tier_basis"] == "origin" and (r["source_type"] or "") not in GOLD_BY_ORIGIN
        ]
        if salto:
            self._add(
                dim, True,
                f"{len(salto)} afirmaciones saltaron a gold por origen sin ser hecho irrefutable "
                f"({'|'.join(sorted(GOLD_BY_ORIGIN))}); deben subir por validación HITL", salto,
            )
        sin_val = [
            f"{r['entity_table']}:{r['entity_id']}" for r in golds
            if r["tier_basis"] == "validated" and not (r["validated_by"] or "").strip()
        ]
        if sin_val:
            self._add(dim, True, f"{len(sin_val)} gold por validación sin validated_by", sin_val)
        sin_ref = [f"{r['entity_table']}:{r['entity_id']}" for r in golds if not (r["source_ref"] or "").strip()]
        if sin_ref:
            self._add(
                dim, True,
                f"{len(sin_ref)} gold sin source_ref — un hecho irrefutable tiene que poder comprobarse",
                sin_ref,
            )
        sin_ver = [
            f"{r['entity_table']}:{r['entity_id']}" for r in golds
            if (r["source_type"] or "") in VERSIONED_ORIGINS and not (r["source_version"] or "").strip()
        ]
        if sin_ver:
            self._add(
                dim, False,
                f"{len(sin_ver)} gold de código, log o monitoreo sin source_version — "
                f"si la fuente cambia, el brain no sabrá degradarlo", sin_ver,
            )

        # Filas marcadas gold sin linaje gold vigente que las respalde
        respaldo = {(r["entity_table"], str(r["entity_id"])) for r in golds}
        huerfanos = []
        for t in tiered:
            if "id" not in self._columns(t):
                continue
            for r in self._rows(f"SELECT id FROM {t} WHERE LOWER(tier)='gold'"):
                if (t, str(r["id"])) not in respaldo:
                    huerfanos.append(f"{t}:{r['id']}")
        if huerfanos:
            self._add(
                dim, True,
                f"{len(huerfanos)} filas gold sin registro de linaje que diga de dónde vienen",
                huerfanos,
            )

        stale = self._scalar(
            "SELECT COUNT(*) FROM knowledge_lineage WHERE superseded_by IS NULL "
            "AND LOWER(tier)='silver' AND validated_at IS NULL "
            f"AND julianday('now') - julianday(recorded_at) > {SILVER_STALE_DAYS}",
            default=0,
        ) or 0
        self.metrics["silver_stale"] = stale
        if stale:
            self._add(
                dim, False,
                f"{stale} afirmaciones silver sin revisión en más de {SILVER_STALE_DAYS} días — "
                f"van a la cola HITL",
            )
        self._seal(dim)

    # ── Orquestación ─────────────────────────────────────────────────────────

    # ── D10 · Cobertura del roster exigible ──────────────────────────────────

    def d10_roster(self):
        """
        Regla B41, tal como la reformuló ADR-EB-016: lo exigible no es que
        existan 24 carpetas con nombre canónico, sino que ninguna de las 24
        responsabilidades quede sin dueño declarado.

        Un brain que no declara su mapeo no reprueba: queda en DESCONOCIDO.
        Reprobarlo sería afirmar que su cobertura es cero, y eso es un juicio
        que la evidencia no sostiene. Lo que sí reprueba es declarar el mapeo y
        dejar responsabilidades fuera sin siquiera nombrarlas como hueco.
        """
        ruta = self._roster_path()
        self.metrics["roster_total"] = len(ROSTER_CANONICO)
        if ruta is None:
            self._na(
                "roster",
                "Este brain no declara su mapeo de rol a DT propio. Su cobertura "
                "de B41 es DESCONOCIDA, que no es lo mismo que cero. Declara el "
                "mapeo en " + ROSTER_DECLARACIONES[0] + " (plantilla en "
                "templates/roster-dt.md del asset)",
            )
            return

        self.metrics["roster_file"] = ruta.name
        cubiertos, huecos, ajenos = {}, [], []
        for linea in ruta.read_text(encoding="utf-8").splitlines():
            if not linea.strip().startswith("|"):
                continue
            celdas = [c.strip().strip("`*") for c in linea.strip().strip("|").split("|")]
            if len(celdas) < 2:
                continue
            rol = celdas[0].lower()
            if rol in ("rol", "rol canónico", "rol canonico") or set(rol) <= set("- :"):
                continue
            dueno = celdas[1]
            if rol not in ROSTER_CANONICO:
                ajenos.append(celdas[0])
                continue
            if dueno.lower() in ROSTER_HUECOS:
                huecos.append(rol)
            else:
                cubiertos[rol] = dueno

        sin_mencion = [r for r in ROSTER_CANONICO
                       if r not in cubiertos and r not in huecos]
        self.metrics["roster_cubiertos"] = len(cubiertos)
        self.metrics["roster_huecos"] = len(huecos)
        self.metrics["roster_sin_mencion"] = len(sin_mencion)

        if sin_mencion:
            self._add(
                "roster", True,
                f"{len(sin_mencion)} responsabilidad(es) del roster exigible no "
                f"aparecen en {ruta.name}: ni con dueño ni declaradas como hueco. "
                f"Un rol sin mención no es un rol cubierto",
                sample=sin_mencion[:8],
            )
        if huecos:
            self._add(
                "roster", False,
                f"{len(huecos)} responsabilidad(es) declaradas sin dueño. Es "
                f"admisible y es mejor que el silencio, pero cada una es una "
                f"pregunta abierta sobre quién responde por ese dominio",
                sample=huecos[:8],
            )
        if ajenos:
            self._add(
                "roster", False,
                f"{len(ajenos)} fila(s) nombran un rol que no es del roster "
                f"exigible. Si son DTs de dimensión no van en esta tabla: son "
                f"población libre y no se enumeran (ADR-EB-016)",
                sample=ajenos[:8],
            )
        self._seal("roster")

    def _roster_path(self):
        """Busca la declaración desde el brain hacia arriba, dos niveles."""
        base = Path(self.db_path).resolve().parent
        for raiz in (base, base.parent):
            for rel in ROSTER_DECLARACIONES:
                cand = raiz / rel
                if cand.is_file():
                    return cand
        return None

    def run(self, only: str | None = None):
        steps = {
            "schema": self.d1_schema,
            "coverage": self.d2_coverage,
            "business_name": self.d3_business_name,
            "regulacion": self.d4_regulacion,
            "clase": self.d5_clase,
            "cross_refs": self.d6_cross_refs,
            "process_linkage": self.d7_process_linkage,
            "callosum": self.d8_callosum,
            "knowledge_quality": self.d9_knowledge_quality,
            "roster": self.d10_roster,
        }
        # D1 siempre corre: fija el inventario de tablas y el brain_type
        self.d1_schema()
        for name, fn in steps.items():
            if name == "schema":
                continue
            if only and name != only:
                continue
            if name in SYSTEM_ONLY_DIMS and self.brain_type != "system":
                self._na(
                    name,
                    f"No aplica a brains de tipo '{self.brain_type}' "
                    f"(su ontología no incluye rules)",
                )
                continue
            fn()
        return self

    @property
    def passed(self) -> bool:
        return not any(f.blocking for f in self.findings)

    def as_dict(self):
        return {
            "db": str(self.db_path),
            "system": self.system or self.metrics.get("slug"),
            "result": "PASS" if self.passed else "FAIL",
            "dimensions": self.dim_status,
            "metrics": self.metrics,
            "findings": [f.as_dict() for f in self.findings],
        }


# ── Reporte ──────────────────────────────────────────────────────────────────

LABELS = {
    "schema": "D1 Schema Integridad",
    "coverage": "D2 Coverage         ",
    "business_name": "D3 business_name    ",
    "regulacion": "D4 Regulación       ",
    "clase": "D5 Clase            ",
    "cross_refs": "D6 Cross-references ",
    "process_linkage": "D7 Process Linkage  ",
    "callosum": "D8 Puente Change-Run",
    "knowledge_quality": "D9 Calidad conocim. ",
    "roster": "D10 Roster exigible",
}


def render(v: Validator, summary: bool = False) -> str:
    m = v.metrics
    out = []
    out.append("BRAIN AUDITOR REPORT")
    declared = m.get("brain_type") or f"~{m.get('brain_type_detected')} (inferido)"
    out.append(
        f"Sistema: {v.system or m.get('slug') or '—'} · "
        f"Build: {m.get('built_at') or '—'} · "
        f"Tipo: {declared}/{m.get('hemisphere') or '—'}"
    )
    out.append("=" * 62)

    detail = {
        "schema": (
            f"{m.get('tables_present', 0)}/{m.get('tables_expected', 0)} "
            f"tablas del canon (core+{m.get('brain_type_detected')})"
        ),
        "coverage": f"etb: {m.get('etb_pct', 0)}% · components: {m.get('components', 0)}",
        "business_name": (
            f"{m.get('bn_vacios', 0)} vacíos · "
            f"{m.get('bn_genericos', 0)} genéricos · "
            f"{m.get('bn_tokens', 0)} tokens"
        ),
        "regulacion": f"{m.get('reg_nulls', 0)} NULLs (debe ser 0)",
        "clase": f"{m.get('clase_nulls', 0)} NULLs · {len(m.get('clase_dist', {}))} valores",
        "cross_refs": (
            f"status: {m.get('status') or '—'} · "
            f"industria: {m.get('industry') or '—'} · "
            f"seeds: {m.get('seeds', 0)} · "
            f"gitignore: {'OK' if m.get('gitignored') else 'MISSING'}"
        ),
        "process_linkage": (
            f"processes: {m.get('processes', 0)} · "
            f"huérfanos: {sum(m.get('orphan_knowledge', {}).values())} "
            f"en {len(m.get('orphan_knowledge', {}))} tabla(s)"
        ),
        "callosum": (
            f"transiciones: {m.get('transitions', 0)} · "
            f"hallazgos: {m.get('findings', 0)} · "
            f"graves sin rutear: {m.get('findings_graves_sin_ruta', 0)}"
        ),
        "knowledge_quality": (
            f"gold {m.get('tier_pct', {}).get('gold', 0)}% · "
            f"silver {m.get('tier_pct', {}).get('silver', 0)}% · "
            f"bronze {m.get('tier_pct', {}).get('bronze', 0)}% · "
            f"linaje: {m.get('lineage_rows', 0)}"
        ),
        "roster": (
            f"cubiertos: {m.get('roster_cubiertos', 0)}/{m.get('roster_total', 0)} · "
            f"huecos declarados: {m.get('roster_huecos', 0)} · "
            f"sin mención: {m.get('roster_sin_mencion', 0)}"
            if m.get("roster_file") else "no declarado — cobertura DESCONOCIDA"
        ),
    }

    for dim in DIMENSIONS:
        status = v.dim_status.get(dim)
        if status is None:
            continue
        out.append(f"[{status}] {LABELS[dim]} — {detail[dim]}")

    out.append("")
    blocking = [f for f in v.findings if f.blocking]
    warnings = [f for f in v.findings if not f.blocking]
    out.append(
        f"RESULTADO FINAL: {'PASS' if v.passed else f'FAIL — {len(blocking)} hallazgos bloqueantes'}"
    )

    if summary:
        return "\n".join(out)

    if blocking:
        out.append("")
        out.append("Hallazgos bloqueantes:")
        for f in blocking:
            out.append(f"  · {f.message}")
            for s in f.sample[:5]:
                out.append(f"      {s}")
    if warnings:
        out.append("")
        out.append("Hallazgos no bloqueantes:")
        for f in warnings:
            out.append(f"  · {f.message}")

    return "\n".join(out)


def main():
    p = argparse.ArgumentParser(description="Brain Auditor — health check del Enterprise Brain")
    p.add_argument("--db", required=True, help="ruta a brain.db")
    p.add_argument("--system", help="slug del sistema (default: system_info.slug)")
    p.add_argument("--brain-type", choices=sorted(VALID_BRAIN_TYPES),
                   help="forzar tipo de brain (default: system_info.brain_type)")
    p.add_argument("--dim", choices=DIMENSIONS, help="ejecutar solo una dimensión")
    p.add_argument("--summary", action="store_true", help="reporte compacto sin detalle")
    p.add_argument("--json", action="store_true", help="salida JSON para agregación")
    args = p.parse_args()

    try:
        v = Validator(Path(args.db), args.system, args.brain_type).run(only=args.dim)
    except FileNotFoundError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 2
    except sqlite3.Error as e:
        print(f"ERROR: brain.db ilegible — {e}", file=sys.stderr)
        return 2

    print(json.dumps(v.as_dict(), ensure_ascii=False, indent=2)
          if args.json else render(v, args.summary))
    v.close()
    return 0 if v.passed else 1


if __name__ == "__main__":
    sys.exit(main())
