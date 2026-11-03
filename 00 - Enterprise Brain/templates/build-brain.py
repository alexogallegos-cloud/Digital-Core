"""
build-brain.py — Pipeline canónico del Enterprise Brain · Template
Versión: 2.0.0 · Enterprise Brain · Digital Core · Accenture México

INSTRUCCIONES DE USO:
    1. Copia este archivo y `schema.sql` a {sistema}/digital-brain/
    2. Ajusta el bloque IDENTIDAD y ONTOLOGÍA
    3. Implementa los load_*() que apliquen a tu brain_type
    4. Corre: python build-brain.py && python build-brain.py --validate

PATRONES CANÓNICOS QUE IMPLEMENTA:
    · Idempotencia dura por DROP explícito (de AppMóvil) — rebuild determinista
    · --dry-run (de Exodus) — inspeccionar sin escribir
    · signals emitidas al cierre (de AppMóvil) — bus entre brains
    · seeds push a los brains vecinos (de Informix, Regla B11)
    · ontología declarada antes que cargada (Regla B20)
    · ningún hueco se inventa: va a knowledge_gaps (Regla B17)

FLUJO DE CARPETAS (Regla P1):
    source/  →  knowledge-base/  →  digital-brain/brain.db
    El builder NUNCA lee source/ directo: lee el corpus curado.
"""

import argparse
import json
import sqlite3
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).parent
DB_PATH = HERE / "brain.db"
SCHEMA_PATH = HERE / "schema.sql"
KB_PATH = HERE.parent / "knowledge-base"
SEEDS_PATH = HERE / "seeds"

BRAIN_VERSION = "1.0.0"

# ── IDENTIDAD — Reglas B13, B14, B18, B19 ────────────────────────────────────

SYSTEM_INFO = {
    "slug": "REEMPLAZAR",
    "display_name": "REEMPLAZAR",
    "brain_type": "system",          # enterprise | project | system
    "hemisphere": "run",             # change (projects/) | run (systems/)
    "togaf_type": "core",            # core|processors|channels|data|integration|compliance
    "togaf_state": "baseline",
    # Industria ANCLA — fija el nombre del brain de cliente ({industria}-brain)
    "industry": "REEMPLAZAR",        # banca | seguros | retail | ...
    "industry_sme": "SME/Industry/REEMPLAZAR",
    "capability_model": "REEMPLAZAR",
    "process_ontology": "REEMPLAZAR",
    "process_ontology_version": "1.0",
    # Ontología de operaciones IT — la define el SME de ITOM/AMS (Regla B23).
    # El brain la ancla; el modelo completo (CIs, service map, SLOs) vive en el SME.
    "itom_model": None,               # ej. "ITIL v4 SMP", "ServiceNow ITOM Discovery v2.0"
    "itom_sme": "SME/Framework/IT Operating Model",
    # Eje de ramo/LOB. NULL si la industria no lo tiene (banca no, seguros sí).
    "lob_dimension": None,
    "version": BRAIN_VERSION,
    "status": "building",            # → 'active' solo tras Brain Auditor PASS
    "source_of_truth": "knowledge-base/",
    "build_agent": "REEMPLAZAR",        # DT del enjambre que construye este brain (Regla B29)
}

# ── ONTOLOGÍA — Regla B20 ────────────────────────────────────────────────────
# Toda empresa compone su ontología de los ETB que le corresponden más sus
# extensiones propias. Exactamente una lleva role='primary'.
# Ejemplo real (Liverpool): retail primary + financial_services secondary.

ONTOLOGY_BINDINGS = [
    {
        "ontology": "REEMPLAZAR",
        "role": "primary",
        # etb | bian | regulatory | it-capability | value-chain | client-logical
        "model_type": "etb",
        "catalog": "REEMPLAZAR",
        "catalog_version": "1.0",
        "industry_sme": "SME/Industry/REEMPLAZAR",
        "regulators": ["REEMPLAZAR"],
        "l3_base": 0,
        "l3_extension": 0,
        "rationale": "REEMPLAZAR — por qué este modelo aplica a esta empresa",
    },
]


class BrainBuilder:
    def __init__(self, db_path: Path = DB_PATH, dry_run: bool = False):
        self.db_path = db_path
        self.dry_run = dry_run
        self.counts: dict[str, int] = {}
        self.db: sqlite3.Connection | None = None

    # ── Ciclo de vida ────────────────────────────────────────────────────────

    def open(self):
        if self.dry_run:
            self.db = sqlite3.connect(":memory:")
            print("DRY-RUN — construyendo en memoria, no se escribe brain.db")
        else:
            self.db = sqlite3.connect(self.db_path)
        self.db.row_factory = sqlite3.Row

    #: Tablas cuyo contenido NO se deriva de `source/` y por lo tanto un rebuild
    #: no puede recrear. El registro de consultas de B45 ocurre al consultar y
    #: no existe en ningún archivo fuente: si el DROP lo borra, B43 pierde la
    #: serie con que mide el uso y B44 pierde lo que debía sobrevivir al
    #: archivado. Se preserva entre builds, y es la única excepción a la
    #: idempotencia dura.
    RUNTIME_TABLES = ("queries",)

    def init_schema(self):
        """
        Idempotencia dura: DROP explícito antes de CREATE. Un rebuild produce
        siempre el mismo resultado, sin drift acumulado de corridas anteriores.

        Las tablas de `RUNTIME_TABLES` se preservan y se reinsertan después,
        porque su contenido no se puede reconstruir desde el código fuente.
        """
        schema = SCHEMA_PATH.read_text(encoding="utf-8")
        existing = [
            r["name"] for r in self.db.execute(
                "SELECT name FROM sqlite_master WHERE type IN ('table','view')"
            )
        ]

        preservado: dict[str, list] = {}
        for t in self.RUNTIME_TABLES:
            if t in existing:
                filas = self.db.execute(f'SELECT * FROM "{t}"').fetchall()
                if filas:
                    preservado[t] = ([k[0] for k in self.db.execute(
                        f'SELECT * FROM "{t}" LIMIT 0').description],
                        [tuple(f) for f in filas])

        for t in existing:
            if t.startswith("sqlite_"):
                continue
            kind = "VIEW" if t.endswith("_view") else "TABLE"
            try:
                self.db.execute(f'DROP {kind} IF EXISTS "{t}"')
            except sqlite3.Error:
                self.db.execute(f'DROP TABLE IF EXISTS "{t}"')
        self.db.executescript(schema)

        for t, (cols, filas) in preservado.items():
            # Si el esquema cambió las columnas, se reinserta solo lo que sigue
            # existiendo: perder una columna es preferible a perder el registro.
            vigentes = {c[1] for c in self.db.execute(f'PRAGMA table_info("{t}")')}
            idx = [i for i, c in enumerate(cols) if c in vigentes]
            lista = ", ".join(f'"{cols[i]}"' for i in idx)
            marcas = ", ".join("?" for _ in idx)
            self.db.executemany(
                f'INSERT OR REPLACE INTO "{t}" ({lista}) VALUES ({marcas})',
                [tuple(f[i] for i in idx) for f in filas])
            print(f"  {t}: {len(filas)} filas preservadas del build anterior")

        self.db.commit()

    def close(self):
        if self.db:
            self.db.commit()
            self.db.close()

    def _insert(self, table: str, rows: list[dict], *, source_type: str | None = None,
                source_ref=None, tier: str = "bronze", id_field: str = "id",
                valid_from: str | None = None) -> int:
        if not rows:
            self.counts[table] = 0
            return 0
        cols = list(rows[0].keys())
        ph = ",".join("?" * len(cols))
        sql = f'INSERT OR REPLACE INTO "{table}" ({",".join(cols)}) VALUES ({ph})'
        self.db.executemany(
            sql,
            [
                tuple(
                    json.dumps(r[c], ensure_ascii=False)
                    if isinstance(r[c], (list, dict)) else r[c]
                    for c in cols
                )
                for r in rows
            ],
        )
        self.counts[table] = len(rows)

        # Regla B37/B40 — toda afirmación declara su nivel, su fuente y su
        # vigencia. Si el cargador no pasa el contrato de linaje, la fila queda
        # en bronze por omisión y `assert_lineage()` lo reporta al cerrar.
        if source_type:
            for r in rows:
                self.record_lineage(
                    table,
                    str(r.get(id_field) or r.get("id") or r.get("slug") or ""),
                    tier, source_type,
                    (source_ref(r) if callable(source_ref) else source_ref) or "",
                    valid_from=(r.get("valid_from") or valid_from),
                )
        return len(rows)

    # ── Linaje del conocimiento (Reglas B37 y B40) ───────────────────────────

    GOLD_BY_ORIGIN = {"code", "log", "monitoring", "job_run", "regulation", "signed_artifact"}

    def record_lineage(self, entity_table: str, entity_id: str, tier: str,
                       source_type: str, source_ref: str, *, tier_basis: str | None = None,
                       source_version: str | None = None, asserted_by: str | None = None,
                       method: str | None = None, validated_by: str | None = None,
                       field: str | None = None, notes: str | None = None,
                       valid_from: str | None = None, valid_to: str | None = None):
        """
        Registra de dónde viene una afirmación y con qué nivel entra al brain.
        Un hecho irrefutable (GOLD_BY_ORIGIN) entra directo a gold. Cualquier otra
        fuente solo llega a gold con validated_by: es el HITL quien la promueve.
        """
        if tier_basis is None:
            tier_basis = ("origin" if tier == "gold" and source_type in self.GOLD_BY_ORIGIN
                          else "validated" if tier == "gold"
                          else "sourced" if tier == "silver" else "ingested")
        if tier == "gold" and tier_basis == "origin" and source_type not in self.GOLD_BY_ORIGIN:
            raise ValueError(
                f"{entity_table}:{entity_id} — '{source_type}' no es hecho irrefutable; "
                f"no puede entrar directo a gold (Regla B37)")
        if tier == "gold" and tier_basis == "validated" and not validated_by:
            raise ValueError(f"{entity_table}:{entity_id} — gold por validación exige validated_by")
        now = datetime.now(timezone.utc).isoformat(timespec="seconds")
        self.db.execute(
            "INSERT INTO knowledge_lineage (entity_table, entity_id, field, tier, tier_basis, "
            "source_type, source_ref, source_version, asserted_by, method, validated_by, "
            "validated_at, notes, valid_from, valid_to, recorded_at) "
            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (entity_table, entity_id, field, tier, tier_basis, source_type, source_ref,
             source_version, asserted_by or SYSTEM_INFO.get("build_agent"), method,
             validated_by, now if validated_by else None, notes,
             valid_from, valid_to, now),
        )
        self.counts["knowledge_lineage"] = self.counts.get("knowledge_lineage", 0) + 1

    # ── CORE — obligatorio en todo brain ─────────────────────────────────────

    def load_system_info(self):
        info = dict(SYSTEM_INFO)
        info["built_at"] = datetime.now(timezone.utc).isoformat(timespec="seconds")
        # La identidad del brain es hecho firmado: entra gold por origen (B37).
        self._insert(
            "system_info", [info],
            source_type="signed_artifact",
            source_ref=lambda r: f"CLAUDE.md#{r.get('slug')}",
            tier="gold", id_field="slug",
        )

    def load_ontology_bindings(self):
        primary = [b for b in ONTOLOGY_BINDINGS if b.get("role") == "primary"]
        if len(primary) != 1:
            raise ValueError(
                f"ONTOLOGY_BINDINGS debe tener exactamente una ontología "
                f"role='primary' (hay {len(primary)}) — Regla B18/B20"
            )
        self._insert("ontology_bindings", ONTOLOGY_BINDINGS)

    def load_cross_dependencies(self):
        """
        Regla B5 — se declaran desde la perspectiva de ESTE brain
        (other_system + direction), con evidencia y origin_artifact.
        """
        self._insert("cross_dependencies", [])

    def load_knowledge_gaps(self):
        """
        Regla B17 — ningún hueco se deja muerto. Cada dato faltante se declara
        con resolution_action redactada como consulta concreta a un SME.
        """
        self._insert("knowledge_gaps", [])

    def load_itom_layer(self):
        """
        Regla B23 — ontología de IT Operating Model, anclada al SME.
        El brain declara qué dominios ITOM cubre y en qué nivel de madurez.
        El modelo completo (procesos, roles, BSC) vive en el SME.

        Valores canónicos de `layer` (ITOM v9.0):
          customer-engagement | it-strategy | delivery |
          technology-operations | information-analytics | it-management
        """
        self._insert("itom_layer", [])

    def load_capabilities(self):
        """
        Regla B21 — ontología de negocio, OBLIGATORIA en todo brain.
        Cada capability declara su `ontology` de origen (FK a
        ontology_bindings) y si es extensión propia de la empresa
        (`is_extension=1`). La regulación viaja con la capability.

        Para un brain de proyecto es el modelo contra el cual se mide el
        cambio: qué capabilities toca la migración, qué obligaciones cubre.
        """
        self._insert("capabilities", [])

    # ── CORE — cadena de valor (Regla B27) ───────────────────────────────────

    def load_products(self):
        """
        Catálogo de productos del cliente (Regla B27 — orientación a producto).
        Punto de partida de la cadena: Producto → KPI → Proceso → Componente.
        Lo puebla ETB vía el Industry SME; TOGAF lo ubica en el dominio B (B28, B36).
        """
        self._insert("products", [])

    def load_kpis(self):
        """
        KPIs vinculados a producto y proceso (Regla B27).
        Change fija `target`; Run mide `current` — análogo a slos del puente.
        """
        self._insert("kpis", [])

    # ── CORE — estructura TOGAF (ADR-EB-009) ─────────────────────────────────

    def load_stakeholders(self):
        """Dominio B. Los portales compartibles usan role y stakeholder_type, nunca nombres."""
        self._insert("stakeholders", [])

    def load_suppliers(self):
        """
        Regla B41 / ADR-EB-011 — proveedores y socios estratégicos. Poseída por
        Supplier Relationship Manager; cierra los procesos ITOM 4 y 5.

        Un proveedor se evalúa contra su SLO medido (`slo_id`), nunca contra su
        propuesta. `criticality='critical'` sin `exit_plan` es hallazgo.
        """
        self._insert("suppliers", [])

    def load_source_catalog(self):
        """
        ADR-EB-014 y ADR-EB-015 — catálogo de fuentes. Poseída por
        `dt-source-steward`. Es el PRIMER paso de todo build: antes de poblar
        nada, el brain declara con qué fuentes cuenta y cuáles le faltan.

        El `natural_tier` se deriva de `source_type` según la tabla F2 del DT,
        nunca de captura libre: ninguna afirmación puede superar el tier de la
        fuente que la sostiene (B37). Toda fila con `status='ausente'` genera
        su fila en `knowledge_gaps` con `gap_type='source'`.
        """
        self._insert("source_catalog", [])

    def load_company_profile(self):
        """
        ADR-EB-015, Etapa 0 — la ficha de identidad. Poseída por
        `dt-client-intelligence`. Una sola fila, con el mismo slug que
        `system_info`.

        Las CIFRAS no van aquí: ingresos, empleados y participación de mercado
        son filas de `measurements` ancladas a esta tabla.
        """
        self._insert("company_profile", [])

    def load_business_milestones(self):
        """
        ADR-EB-015, Etapa 0 — la trayectoria que explica por qué la empresa es
        como es hoy. Su tier es silver o bronze por origen: una nota de prensa
        no es un hecho firmado.
        """
        self._insert("business_milestones", [])

    def load_strategic_drivers(self):
        """
        ADR-EB-015, Etapa 0 — pilares, objetivos, retos y amenazas, tipados en
        una sola tabla porque comparten estructura y se consultan juntos.

        Un pilar declarado en un reporte anual es INTENCIÓN, no hecho: su tier
        es silver por origen (B37). Marcarlo gold contamina todo lo que cuelgue
        del driver.
        """
        self._insert("strategic_drivers", [])

    def load_driver_links(self):
        """
        ADR-EB-015, Etapa 0 — la traza de vuelta que convierte el estudio del
        cliente en eje rector y no en prólogo.

        Criterio de salida de la Etapa 0: cada driver tiene al menos un link, o
        está declarado como hueco. Un driver sin ningún link es un hallazgo, no
        un silencio: o el brain no cubre esa parte del estate, o la empresa
        declara una prioridad que su tecnología no sostiene.
        """
        self._insert("driver_links", [])

    def load_technology_components(self):
        """Dominio T: qué opera TI. Cómo lo opera va en itom_layer (B36)."""
        self._insert("technology_components", [])

    def load_data_entities(self):
        """Dominio D. En brains de sistema se deriva de las referencias componente-tabla."""
        self._insert("data_entities", [])

    # ── Extensión SYSTEM ─────────────────────────────────────────────────────

    def load_component_data(self):
        """Matriz CRUD aplicación-dato. Patrón de Informix sp_table_refs."""
        self._insert("component_data", [])

    def load_components(self):
        self._insert("components", [])

    def load_rules(self):
        """business_name por síntesis LLM source-read (ADR-EB-004), nunca transcripción."""
        self._insert("rules", [])

    def load_vocabulary(self):
        self._insert("vocabulary", [])

    def load_processes(self):
        """
        Ontología de procesos de la industria — distinta de capabilities y
        distinta de journeys. La suministra el Industry SME (Regla B19).
        """
        self._insert("processes", [])

    def load_journeys(self):
        """Trazas reales por el call graph. La brecha vs. processes es hallazgo."""
        self._insert("journeys", [])

    # ── Extensión PROJECT ─────────────────────────────────────────────────────

    def load_applications(self):
        """Aplicaciones del proyecto — unidades de despliegue/migración."""
        self._insert("applications", [])

    def load_waves(self):
        """Olas de migración o implantación — agrupa aplicaciones por ventana de entrega."""
        self._insert("waves", [])

    def load_risks(self):
        """Riesgos del proyecto. origin_finding_id vincula a hallazgos de Run (Regla B24)."""
        self._insert("risks", [])

    def load_decisions(self):
        """Decisiones arquitectónicas del proyecto — ADRs en DB."""
        self._insert("decisions", [])

    def load_user_stories(self):
        """User Stories del proyecto. origin_finding_id vincula a hallazgos de Run."""
        self._insert("user_stories", [])

    # ── Puente Change–Run (Regla B24) ────────────────────────────────────────

    def load_plateaus(self):
        """Estados de arquitectura del proyecto: as_is → transition(s) → to_be."""
        self._insert("plateaus", [])

    def load_transitions(self):
        """
        Lado Change del puente. `fate` en vocabulario canónico (7R + encapsulate);
        el valor original va en `fate_source`. Un destino desconocido NO es
        transición: va a knowledge_gaps (Regla B17).
        """
        self._insert("transitions", [])

    def load_readiness_gates(self):
        """Una fila por gate (runbook, oncall, slo, rollback, drp, test, knowledge, prr)."""
        self._insert("readiness_gates", [])

    def load_slos(self):
        """Change carga `target`; Run carga `current`. Mismo id en ambos brains."""
        self._insert("slos", [])

    def load_findings(self):
        """
        Lado Run del puente. Severidad canónica (blocker|critical|high|medium|low);
        el valor original va en `severity_source`. Si el hallazgo toca algo en
        transición, se rutea al brain de proyecto (routed_to_brain).
        """
        self._insert("findings", [])

    # ── Cierre ───────────────────────────────────────────────────────────────

    def rebuild_fts(self):
        pairs = [
            ("rules_fts", "rules", "id, business_name, description, fragmento"),
            ("vocabulary_fts", "vocabulary", "id, term, definition"),
            ("components_fts", "components", "id, name, display_name, description"),
        ]
        for fts, src, cols in pairs:
            try:
                self.db.execute(f"DELETE FROM {fts}")
                self.db.execute(f"INSERT INTO {fts} SELECT {cols} FROM {src}")
            except sqlite3.Error:
                pass

    def emit_signals(self):
        """Bus entre brains — se emite al cierre del pipeline."""
        ts = datetime.now(timezone.utc).isoformat(timespec="seconds")
        rows = [
            {"signal": "brain_built", "value": BRAIN_VERSION,
             "source": "build-brain.py", "ts": ts},
            {"signal": "component_count", "value": str(self.counts.get("components", 0)),
             "source": "build-brain.py", "ts": ts},
            {"signal": "rule_count", "value": str(self.counts.get("rules", 0)),
             "source": "build-brain.py", "ts": ts},
            # Puente — el enterprise brain los usa para saber qué cruzar
            {"signal": "transition_count", "value": str(self.counts.get("transitions", 0)),
             "source": "build-brain.py", "ts": ts},
            {"signal": "finding_count", "value": str(self.counts.get("findings", 0)),
             "source": "build-brain.py", "ts": ts},
        ]
        self._insert("signals", rows)

    def emit_seeds(self):
        """
        Regla B11 — los seeds son push, no pull. Por cada sistema con relación
        conocida se emite evidencia estructurada para que arranque su brain.
        """
        deps = self.db.execute(
            "SELECT * FROM cross_dependencies"
        ).fetchall()
        if not deps or self.dry_run:
            return
        SEEDS_PATH.mkdir(exist_ok=True)
        manifest = []
        for d in deps:
            d = dict(d)
            seed = {
                "emitted_by": SYSTEM_INFO["slug"],
                "emitted_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
                "receptor": d["other_system"],
                "evidence": {
                    "origin_artifact": f"digital-brain/brain.db::cross_dependencies",
                    "dependency_type": d.get("dependency_type"),
                    "direction": d.get("direction"),
                    "volume": d.get("volume"),
                    "criticality": d.get("criticality"),
                },
            }
            name = f"{d['other_system']}-seed.json"
            (SEEDS_PATH / name).write_text(
                json.dumps(seed, ensure_ascii=False, indent=2), encoding="utf-8"
            )
            manifest.append(name)
        (SEEDS_PATH / "manifest.json").write_text(
            json.dumps({"seeds": manifest}, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )

    def summary(self):
        print(f"\nbrain.db · {SYSTEM_INFO['slug']} · v{BRAIN_VERSION}")
        print(f"  tipo: {SYSTEM_INFO['brain_type']}/{SYSTEM_INFO['hemisphere']}"
              f" · industria: {SYSTEM_INFO['industry']}")
        for t, n in sorted(self.counts.items()):
            if n:
                print(f"  {t:<24}{n:>8}")

    # ── Orquestación ─────────────────────────────────────────────────────────

    def build(self):
        self.open()
        self.init_schema()

        # CORE — ningún brain está exento
        self.load_system_info()
        self.load_ontology_bindings()
        self.load_capabilities()        # Regla B21 — ontología de negocio anclada
        self.load_processes()           # Regla B22 — ontología de procesos CORE
        self.load_products()            # Regla B27 — productos del cliente (ancla de KPI)
        self.load_kpis()                # Regla B27 — KPIs vinculados a producto y proceso
        self.load_stakeholders()        # ADR-EB-009 — TOGAF dominio B
        self.load_technology_components()  # ADR-EB-009 — TOGAF dominio T
        self.load_suppliers()           # Regla B41 — ADR-EB-011
        self.load_data_entities()       # ADR-EB-009 — TOGAF dominio D
        self.load_itom_layer()          # Regla B23 — IT Operating Model (SME ancla)
        self.load_cross_dependencies()
        self.load_knowledge_gaps()

        bt = SYSTEM_INFO["brain_type"]
        if bt == "system":
            self.load_components()
            self.load_component_data()
            self.load_rules()
            self.load_vocabulary()
            self.load_journeys()
            # Puente — lado Run
            self.load_findings()
            self.load_slos()
        elif bt == "project":
            # Extensión PROJECT
            self.load_applications()
            self.load_waves()
            self.load_risks()
            self.load_decisions()
            self.load_user_stories()
            # Puente — lado Change
            self.load_plateaus()
            self.load_transitions()
            self.load_readiness_gates()
            self.load_slos()

        self.rebuild_fts()
        self.emit_signals()
        self.emit_seeds()
        self.assert_lineage()
        self.summary()
        self.close()


    def assert_lineage(self):
        """
        Reglas B37 y B40 — guarda de construcción.

        Verifica el invariante real: **toda tabla de conocimiento con filas debe
        tener linaje**. La versión anterior solo comprobaba que la tabla de
        linaje no estuviera vacía, y como `load_system_info` siempre escribe una
        fila, nunca podía fallar. Una guarda que no puede dar negativo no es una
        guarda: es decoración.

        Si agregas un cargador, pásale el contrato de linaje a `_insert`
        (source_type, source_ref, tier) o esta guarda te lo va a reclamar.
        """
        con_linaje = {
            r[0] for r in self.db.execute(
                "SELECT DISTINCT entity_table FROM knowledge_lineage")
        }
        sin_linaje = []
        for tabla, n in sorted(self.counts.items()):
            if n and tabla != "knowledge_lineage" and tabla not in con_linaje:
                sin_linaje.append(f"{tabla} ({n} filas)")

        total = self.db.execute("SELECT COUNT(*) FROM knowledge_lineage").fetchone()[0]
        if sin_linaje:
            raise RuntimeError(
                "Hay conocimiento cargado sin declarar su procedencia (Regla B37). "
                "Tablas con filas y sin una sola entrada en knowledge_lineage: "
                + ", ".join(sin_linaje)
                + ". Pasa source_type, source_ref y tier a _insert()."
            )

        sin_vigencia = self.db.execute(
            "SELECT COUNT(*) FROM knowledge_lineage WHERE valid_from IS NULL"
        ).fetchone()[0]
        if sin_vigencia:
            print(
                f"  [aviso B40] {sin_vigencia} de {total} afirmaciones sin valid_from. "
                f"Se interpretan como verdad desde el origen del sistema.",
                file=sys.stderr,
            )
        print(f"  linaje: {total} afirmaciones sobre {len(con_linaje)} tabla(s)")


def run_validator() -> int:
    validador = (
        HERE.parents[3] / "00 - Enterprise Brain" / "dt" / "dt-brain-auditor" / "validate.py"
    )
    if not validador.exists():
        print(f"Brain Auditor no encontrado en {validador}", file=sys.stderr)
        return 2
    return subprocess.run(
        [sys.executable, str(validador), "--db", str(DB_PATH)]
    ).returncode


def main():
    p = argparse.ArgumentParser(description="Pipeline canónico del Enterprise Brain")
    p.add_argument("--dry-run", action="store_true",
                   help="construye en memoria sin escribir brain.db")
    p.add_argument("--validate", action="store_true",
                   help="corre el Brain Auditor sobre el brain.db existente")
    args = p.parse_args()

    if args.validate:
        return run_validator()

    BrainBuilder(dry_run=args.dry_run).build()
    return 0


if __name__ == "__main__":
    sys.exit(main())
