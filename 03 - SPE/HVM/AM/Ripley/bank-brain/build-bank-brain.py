"""
build-bank-brain.py — Pipeline del cerebro empresarial de Banco Ripley Chile
Instanciado del template canonico 00 - Enterprise Brain/templates/build-brain.py v2.0.0

RONDA R0 — ENCUADRE. Este build no produce hallazgos ni modelo de negocio: declara
la identidad del brain, su ontologia compuesta, su catalogo de fuentes y su backlog
de huecos. R1 y R2 lo pueblan despues.

El template canonico cubre las extensiones `system` y `project` pero no `enterprise`.
Esta instancia agrega esa rama (federated_brains + documents) y el cargador de
source_catalog, que ADR-EB-014 declara pero ningun template implementa todavia.

FLUJO (Regla P1):
    source/  ->  knowledge-base/  ->  bank-brain.db  ->  portal/
    El builder NUNCA lee source/ directo: lee el corpus curado.

USO:
    python build-bank-brain.py
    python build-bank-brain.py --dry-run
    python build-bank-brain.py --validate
"""

import argparse
import json
import sqlite3
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).parent
DB_PATH = HERE / "bank-brain.db"
LOCAL_SCHEMA = HERE / "schema.sql"
KB_PATH = HERE / "knowledge-base"
SEEDS_PATH = HERE / "seeds"

BRAIN_VERSION = "0.1.0"


def asset_root() -> Path | None:
    """
    Localiza el asset Enterprise Brain subiendo por el arbol. ADR-EB-006 fija que
    templates/schema.sql es la unica fuente de verdad del DDL; cuando el asset es
    alcanzable se usa ese, y la copia local queda solo como respaldo de autonomia
    (Regla B1 — el brain funciona aunque el asset no este montado).
    """
    for p in [HERE, *HERE.parents]:
        cand = p / "00 - Enterprise Brain"
        if cand.is_dir():
            return cand
    return None


def schema_path() -> Path:
    root = asset_root()
    if root and (root / "templates" / "schema.sql").exists():
        return root / "templates" / "schema.sql"
    if LOCAL_SCHEMA.exists():
        print("  [aviso] asset no alcanzable; usando la copia local de schema.sql",
              file=sys.stderr)
        return LOCAL_SCHEMA
    raise FileNotFoundError("No se encontro schema.sql ni en el asset ni local")


# ── IDENTIDAD — Reglas B13, B14, B18, B19 ────────────────────────────────────

SYSTEM_INFO = {
    "slug": "ripley-bank-brain",
    "display_name": "Banco Ripley Chile",
    "brain_type": "enterprise",
    "hemisphere": "change",            # el brain cubre ambos; la columna admite uno
    "togaf_type": None,                # un brain enterprise no es un sistema
    "togaf_state": None,
    "togaf_abb": None,
    "industry": "banca",
    "industry_sme": "SME/Industry/Industry Banking",
    "capability_model": "Accenture Logical Operating Model for Banking, Digital Bank 4.0 (28 L1 en 3 L0)",
    "process_ontology": "Procesos por producto financiero, anclados al catalogo Digital Bank 4.0",
    "process_ontology_version": "1.0",
    "itom_model": "IT Operating Model v9.0 (38 procesos en 6 dominios)",
    "itom_sme": "SME/Framework/IT Operating Model",
    "lob_dimension": None,             # banca no tiene eje de ramo (ADR-EB-007)
    "version": BRAIN_VERSION,
    "status": "discovered",            # R0 no activa el brain
    "source_of_truth": "knowledge-base/ (corpus curado de registros publicos: CMF, Bolsa de Santiago, memorias de Ripley Corp)",
    "build_agent": "Enjambre de 23 Digital Twins canonicos (Regla B41)",
}

# ── ONTOLOGIA — Reglas B20 y B21 ─────────────────────────────────────────────

ONTOLOGY_BINDINGS = [
    {
        "ontology": "banca",
        "role": "primary",
        "model_type": "etb",
        "catalog": "Accenture Logical Operating Model for Banking - Digital Bank 4.0",
        "catalog_version": "L2 View / BIAN Heatmap",
        "industry_sme": "SME/Industry/Industry Banking",
        "regulators": ["CMF", "Banco Central de Chile", "SERNAC"],
        "l3_base": 0,
        "l3_extension": 0,
        "rationale": "Banco de consumo con licencia bancaria chilena. Es la ontologia ancla y fija el nombre del brain (B18).",
    },
    {
        "ontology": "retail",
        "role": "secondary",
        "model_type": "value-chain",
        "catalog": "Cadena de valor de retail (PLAN-BUY-MOVE-SELL-SERVE)",
        "catalog_version": "1.0",
        "industry_sme": "SME/Industry/Industry Retail",
        "regulators": ["SERNAC"],
        "l3_base": 0,
        "l3_extension": 0,
        "rationale": "La red de tiendas Ripley es canal de originacion del banco desde 1976, antes que el banco existiera. Entra como canal, no como lifecycle propio.",
    },
    {
        "ontology": "it_capability",
        "role": "secondary",
        "model_type": "it-capability",
        "catalog": "IT Operating Model v9.0",
        "catalog_version": "9.0",
        "industry_sme": "SME/Framework/IT Operating Model",
        "regulators": [],
        "l3_base": 38,
        "l3_extension": 0,
        "rationale": "La cara de TI del brain. Los 38 procesos son la rejilla contra la que R2 declara que demuestra la evidencia.",
    },
    {
        "ontology": "bian",
        "role": "secondary",
        "model_type": "bian",
        "catalog": "BIAN Service Landscape",
        "catalog_version": "v14",
        "industry_sme": "SME/Industry/Industry Banking",
        "regulators": [],
        "l3_base": 0,
        "l3_extension": 0,
        "rationale": "Mapeo de los L2 con contraparte BIAN. Aplicable cuando existan brains de sistema; hoy declarado y vacio.",
    },
    {
        "ontology": "regulatorio_chile",
        "role": "secondary",
        "model_type": "regulatory",
        "catalog": "Recopilacion Actualizada de Normas de la CMF y Compendio de Normas Financieras del Banco Central",
        "catalog_version": "[POR CONFIRMAR]",
        "industry_sme": "SME/Industry/Industry Banking",
        "regulators": ["CMF", "Banco Central de Chile", "SERNAC"],
        "l3_base": 0,
        "l3_extension": 0,
        "rationale": "HUECO ABIERTO. El Industry SME solo tiene capa Mexico. R1 no cierra en dominios regulados sin esta capa. Ver GAP-RIP-001.",
    },
]

# ── CATALOGO DE FUENTES — ADR-EB-014, dueno dt-source-steward ────────────────
# El tier natural lo fija el tipo de fuente. Dos excepciones declaradas: los
# estados financieros auditados y los hechos esenciales son artefactos firmados
# ante una autoridad, y por eso sostienen gold aunque su source_type sea `doc`.

SOURCE_CATALOG = [
    {
        "id": "SRC-RIP-001", "ontology": "regulatorio_chile",
        "name": "Recopilacion Actualizada de Normas de la CMF para bancos",
        "source_type": "regulacion", "generator_type": "parser", "cadence": "bajo demanda",
        "status": "planeada", "natural_tier": "gold", "coverage_pct": None,
        "enables": ["obligaciones regulatorias", "riesgo operacional", "continuidad", "ciberseguridad"],
        "location": "https://www.cmfchile.cl", "last_refresh": None,
        "owner": "dt-it-risk-manager",
    },
    {
        "id": "SRC-RIP-002", "ontology": "regulatorio_chile",
        "name": "Compendio de Normas Financieras del Banco Central de Chile",
        "source_type": "regulacion", "generator_type": "parser", "cadence": "bajo demanda",
        "status": "planeada", "natural_tier": "gold", "coverage_pct": None,
        "enables": ["regimen de pagos", "encaje", "operaciones con el Banco Central"],
        "location": "https://www.bcentral.cl", "last_refresh": None,
        "owner": "dt-it-risk-manager",
    },
    {
        "id": "SRC-RIP-003", "ontology": "regulatorio_chile",
        "name": "Compendio de Normas Contables de la CMF para bancos",
        "source_type": "regulacion", "generator_type": "parser", "cadence": "bajo demanda",
        "status": "planeada", "natural_tier": "gold", "coverage_pct": None,
        "enables": ["plan de cuentas", "reporte regulatorio"],
        "location": "https://www.cmfchile.cl", "last_refresh": None,
        "owner": "dt-enterprise-functions-owner",
    },
    {
        "id": "SRC-RIP-004", "ontology": "banca",
        "name": "Estados financieros auditados de Banco Ripley publicados en la CMF",
        "source_type": "doc", "generator_type": "parser", "cadence": "batch",
        "status": "planeada", "natural_tier": "gold", "coverage_pct": None,
        "enables": ["tamano del balance", "composicion de cartera", "provisiones", "indicadores de capital"],
        "location": "https://www.cmfchile.cl", "last_refresh": None,
        "owner": "dt-enterprise-functions-owner",
    },
    {
        "id": "SRC-RIP-005", "ontology": "banca",
        "name": "Analisis razonado trimestral de Ripley Corp, segmento bancario",
        "source_type": "doc", "generator_type": "parser", "cadence": "batch",
        "status": "planeada", "natural_tier": "gold", "coverage_pct": None,
        "enables": ["evolucion de colocaciones", "ingresos del segmento bancario", "resultado"],
        "location": "Relacion con inversionistas de Ripley Corp", "last_refresh": None,
        "owner": "dt-demand-manager",
    },
    {
        "id": "SRC-RIP-006", "ontology": "banca",
        "name": "Memoria anual de Banco Ripley",
        "source_type": "doc", "generator_type": "parser", "cadence": "batch",
        "status": "parcial", "natural_tier": "silver", "coverage_pct": None,
        "enables": ["estructura societaria", "filiales", "gobierno", "fechas de constitucion"],
        "location": "Relacion con inversionistas de Ripley Corp, Memoria Banco Ripley 2024",
        "last_refresh": "2026-10-27",
        "owner": "dt-domain-architect",
    },
    {
        "id": "SRC-RIP-007", "ontology": "banca",
        "name": "Hechos esenciales de Banco Ripley ante la CMF",
        "source_type": "doc", "generator_type": "connector", "cadence": "continuo",
        "status": "planeada", "natural_tier": "gold", "coverage_pct": None,
        "enables": ["eventos materiales", "incidentes operativos relevantes", "colocaciones de bonos"],
        "location": "https://www.cmfchile.cl", "last_refresh": None,
        "owner": "dt-service-operations-lead",
    },
    {
        "id": "SRC-RIP-008", "ontology": "banca",
        "name": "Comunicados del SERNAC sobre Banco Ripley",
        "source_type": "doc", "generator_type": "connector", "cadence": "continuo",
        "status": "parcial", "natural_tier": "gold", "coverage_pct": None,
        "enables": ["incidentes con impacto en clientes", "Procedimiento Voluntario Colectivo de agosto 2026",
                    "falla operativa del 4 de mayo de 2026"],
        "location": "https://www.sernac.cl", "last_refresh": "2026-10-27",
        "owner": "dt-service-operations-lead",
    },
    {
        "id": "SRC-RIP-009", "ontology": "banca",
        "name": "Informe de desempeno del sistema bancario de la CMF",
        "source_type": "doc", "generator_type": "parser", "cadence": "batch",
        "status": "planeada", "natural_tier": "gold", "coverage_pct": None,
        "enables": ["linea base del sistema para comparar al banco contra el mercado"],
        "location": "https://www.cmfchile.cl", "last_refresh": None,
        "owner": "dt-demand-manager",
    },
    {
        "id": "SRC-RIP-010", "ontology": "banca",
        "name": "Modelo Digital Bank 4.0 del asset Enterprise Brain",
        "source_type": "doc", "generator_type": "parser", "cadence": "bajo demanda",
        "status": "activa", "natural_tier": "silver", "coverage_pct": None,
        "enables": ["que deberia poder hacer el banco", "capabilities esperadas de R1"],
        "location": "00 - Enterprise Brain/knowledge-base/ontology/banca.md",
        "last_refresh": "2026-10-27", "owner": "dt-domain-architect",
    },
    {
        "id": "SRC-RIP-011", "ontology": "it_capability",
        "name": "IT Operating Model v9.0, 38 procesos",
        "source_type": "doc", "generator_type": "parser", "cadence": "bajo demanda",
        "status": "activa", "natural_tier": "silver", "coverage_pct": None,
        "enables": ["rejilla de los 38 procesos contra la que R2 se pronuncia"],
        "location": "SME/Framework/IT Operating Model", "last_refresh": "2026-10-27",
        "owner": "dt-knowledge-manager",
    },
    {
        "id": "SRC-RIP-012", "ontology": "banca",
        "name": "Inventario de aplicaciones y mapa de arquitectura del banco",
        "source_type": "cmdb", "generator_type": "connector", "cadence": "continuo",
        "status": "ausente", "natural_tier": "gold", "coverage_pct": 0.0,
        "enables": ["landscape tecnologico", "core bancario", "procesador de tarjetas", "integraciones"],
        "location": None, "last_refresh": None,
        "owner": "dt-asset-configuration-manager",
    },
    {
        "id": "SRC-RIP-013", "ontology": "banca",
        "name": "Codigo fuente de los sistemas del banco",
        "source_type": "codigo", "generator_type": "parser", "cadence": "batch",
        "status": "ausente", "natural_tier": "gold", "coverage_pct": 0.0,
        "enables": ["las cuatro etapas del gemelo cognitivo, por sistema"],
        "location": None, "last_refresh": None,
        "owner": "dt-build-operator",
    },
]

# ── HUECOS — Reglas B17 y B35 ────────────────────────────────────────────────
# Una pregunta concreta, un destinatario con nombre de rol, y que se hace con la
# respuesta. Sin las tres cosas el hueco no sirve.

KNOWLEDGE_GAPS = [
    {
        "id": "GAP-RIP-001", "gap_type": "dato", "dimension": "regulatoria", "domain": "transversal",
        "process_id": None,
        "description": "No existe la capa regulatoria chilena en el Industry Banking SME. Lo unico publicado es la capa Mexico (CNBV, Banxico, CONDUSEF, extension de 89 productos de banca multiple).",
        "impact": "BLOQUEANTE. R1 no puede cerrar en ningun dominio regulado. Declarar un dominio regulado completo sin esta capa produce un falso positivo.",
        "required_for": "Gate de salida de R1",
        "resolution_action": "Consulta a SME/Industry/Industry Banking: producir kb-banking-regulacion-cl.md contra la Recopilacion Actualizada de Normas de la CMF y el Compendio de Normas Financieras del Banco Central. Aterriza en ontology_bindings y regulatory_obligations.",
        "owner": "dt-it-risk-manager", "status": "open", "opened_at": "2026-10-27",
    },
    {
        "id": "GAP-RIP-002", "gap_type": "dato", "dimension": "negocio", "domain": "producto",
        "process_id": None,
        "description": "No existe el catalogo de productos de la banca chilena equivalente a la extension mexicana. Evidencia publica parcial: tarjetas Mastercard emitidas por CAR S.A., cuenta corriente con planes, deposito a plazo en pesos y en UF, credito de consumo. La Cuenta Vista Ripley aparece como descontinuada en una fuente secundaria sin confirmar.",
        "impact": "dt-product-owner no puede declarar el modelo de producto de R1 ni mapearlo a la taxonomia Digital Bank 4.0.",
        "required_for": "R1, dominio L1 de Producto y servicio",
        "resolution_action": "Consulta a SME/Industry/Industry Banking: producir el catalogo de productos de banca chilena y su mapeo a Digital Bank 4.0. Verificar el estado de la Cuenta Vista contra el sitio oficial del banco. Aterriza en products.",
        "owner": "dt-product-owner", "status": "open", "opened_at": "2026-10-27",
    },
    {
        "id": "GAP-RIP-003", "gap_type": "validación", "dimension": "regulatoria", "domain": "finanzas abiertas",
        "process_id": None,
        "description": "La fecha efectiva de entrada en vigor del Sistema de Finanzas Abiertas de la Ley Fintec 21.521 esta en movimiento. Estaba prevista para julio de 2026; la CMF puso en consulta una extension de doce meses y en abril de 2026 su presidenta declaro que veia complejo que estuviera operativo en julio. Hay referencias a una norma tecnica de junio de 2026 sin verificar contra el texto oficial.",
        "impact": "Una fecha equivocada en un entregable de cliente sobre un programa regulatorio es un error caro.",
        "required_for": "R2, dt-it-risk-manager",
        "resolution_action": "Verificacion directa en cmfchile.cl y en el Diario Oficial antes de que entre al brain como gold. Hasta entonces se mantiene como [POR CONFIRMAR].",
        "owner": "dt-it-risk-manager", "status": "open", "opened_at": "2026-10-27",
    },
    {
        "id": "GAP-RIP-004", "gap_type": "validación", "dimension": "regulatoria", "domain": "datos personales",
        "process_id": None,
        "description": "Falta confirmar la fecha de entrada en vigencia plena de la Ley 21.719 de proteccion de datos personales y el estado de su autoridad de control.",
        "impact": "Determina si la obligacion ya pesa sobre el banco o todavia no.",
        "required_for": "R2, dt-information-architect",
        "resolution_action": "Verificacion directa en el Diario Oficial. Aterriza en regulatory_obligations con su valid_from real (Regla B40).",
        "owner": "dt-information-architect", "status": "open", "opened_at": "2026-10-27",
    },
    {
        "id": "GAP-RIP-005", "gap_type": "dato", "dimension": "regulatoria", "domain": "contabilidad",
        "process_id": None,
        "description": "Falta la capa contable chilena: el equivalente del trabajo que el SME de Contabilidad Bancaria tiene hecho para la Circular Unica de Bancos mexicana.",
        "impact": "dt-enterprise-functions-owner no puede declarar el modelo de reporte regulatorio.",
        "required_for": "R1, dominio L1 de Funciones de empresa",
        "resolution_action": "Consulta a SME/Industry/Industry Banking Accounting: producir el mapa del Compendio de Normas Contables de la CMF.",
        "owner": "dt-enterprise-functions-owner", "status": "open", "opened_at": "2026-10-27",
    },
    {
        "id": "GAP-RIP-006", "gap_type": "dato", "dimension": "negocio", "domain": "pagos",
        "process_id": None,
        "description": "Falta la capa de pagos Chile: ecosistema de adquirencia de cuatro partes, camara de compensacion, transferencias electronicas y el regimen de la Ley 20.009 sobre fraude en medios de pago.",
        "impact": "Sin esto no hay forma de modelar el producto principal del banco, que es la tarjeta. No existe equivalente de SPEI ni de CoDi; reusar el vocabulario mexicano seria un error de fondo.",
        "required_for": "R1, dominios de Operaciones del core y de Canales",
        "resolution_action": "Consulta a SME/Industry/Industry Payments: producir la capa de pagos Chile.",
        "owner": "dt-operations-owner", "status": "open", "opened_at": "2026-10-27",
    },
    {
        "id": "GAP-RIP-007", "gap_type": "acceso", "dimension": "tecnología", "domain": "core",
        "process_id": None,
        "description": "Se desconoce cual es el core bancario de Banco Ripley y en que version corre.",
        "impact": "Es el hueco central del analisis. dt-asset-configuration-manager y dt-domain-architect quedan sin evidencia alguna en R2.",
        "required_for": "R2 y cualquier apertura de systems/core/",
        "resolution_action": "Requiere acceso al cliente. Consulta a Arquitectura o CIO del banco. Al recibir respuesta se abre el sistema bajo systems/core/ con su estructura canonica (Reglas B8 y B9).",
        "owner": "dt-asset-configuration-manager", "status": "open", "opened_at": "2026-10-27",
    },
    {
        "id": "GAP-RIP-008", "gap_type": "acceso", "dimension": "tecnología", "domain": "tarjetas",
        "process_id": None,
        "description": "Se desconoce que plataforma usa CAR S.A. para emitir y procesar la Tarjeta de Credito Banco Ripley, y si el procesamiento es propio o tercerizado.",
        "impact": "El producto principal del banco lo emite una persona juridica distinta. El sistema de registro puede estar fuera del perimetro del banco.",
        "required_for": "R2 y cualquier apertura de systems/processors/",
        "resolution_action": "Requiere acceso al cliente. Consulta a Arquitectura o CIO del banco sobre la plataforma de CAR S.A.",
        "owner": "dt-operations-owner", "status": "open", "opened_at": "2026-10-27",
    },
    {
        "id": "GAP-RIP-009", "gap_type": "dato", "dimension": "cultural", "domain": "historia",
        "process_id": None,
        "description": "El estudio historico no tiene ninguna decision tecnologica documentada: ni cuando se implanto el core actual, ni si hubo reemplazos, ni que quedo de la plataforma del retail dentro del banco.",
        "impact": "Es la ausencia mas cara del estudio, porque es justamente la que explica el porque del codigo (Regla B26).",
        "required_for": "Cierre del estudio historico de R0",
        "resolution_action": "Consulta a Arquitectura del banco y revision de memorias anuales historicas en la CMF. Aterriza en knowledge-base/historia/.",
        "owner": "dt-domain-architect", "status": "open", "opened_at": "2026-10-27",
    },
    {
        "id": "GAP-RIP-010", "gap_type": "decisión", "dimension": "tecnología", "domain": "transversal",
        "process_id": None,
        "description": "La taxonomia de riesgo de equivalencia del asset usa UDI, la unidad de inversion mexicana. Chile indexa en Unidad de Fomento, que difiere en calculo y en periodicidad de publicacion.",
        "impact": "No se arregla documentandolo: el detector de patrones que asigna el campo riesgo tiene UDI en su taxonomia y necesita UF. Muerde en cuanto se extraiga la primera regla de un sistema de este banco.",
        "required_for": "Primera extraccion de reglas de cualquier sistema",
        "resolution_action": "Abrir ADR en el asset Enterprise Brain para extender la taxonomia de riesgo con UF, y ajustar el enriquecedor.",
        "owner": "dt-brain-engineer", "status": "open", "opened_at": "2026-10-27",
    },
]

# ── DEPENDENCIAS CRUZADAS — Regla B5 ─────────────────────────────────────────
# Se declaran desde la perspectiva de ESTE brain, con evidencia y artefacto origen.

CROSS_DEPENDENCIES = [
    {
        "id": "DEP-RIP-CAR", "tier": "silver",
        "other_system": "car-sa",
        "dependency_type": "feeds", "direction": "outbound",
        "volume": 0,
        "domains": ["tarjetas"], "regulation": ["CMF"],
        "description": "CAR S.A. es la sociedad de apoyo al giro que emite la Tarjeta de Credito Banco Ripley. Es persona juridica distinta, constituida en 1972 como Inversiones Centro Limitada y transformada en sociedad anonima cerrada en 2001, treinta anos antes que el banco. El sistema de registro del producto principal puede vivir fuera del perimetro del banco.",
        "criticality": "critical",
        "evidence": "Memoria Banco Ripley 2024 y seccion de filiales del sitio del banco",
        "origin_artifact": "knowledge-base/historia/linea-de-tiempo.md",
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
            print("DRY-RUN — construyendo en memoria, no se escribe bank-brain.db")
        else:
            self.db = sqlite3.connect(self.db_path)
        self.db.row_factory = sqlite3.Row

    #: Unica excepcion a la idempotencia dura: el registro de consultas de B45
    #: ocurre al consultar y no existe en ningun archivo fuente.
    RUNTIME_TABLES = ("queries",)

    def init_schema(self):
        schema = schema_path().read_text(encoding="utf-8")
        existing = [
            r["name"] for r in self.db.execute(
                "SELECT name FROM sqlite_master WHERE type IN ('table','view')"
            )
        ]

        preservado: dict[str, tuple] = {}
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
        if tier_basis is None:
            tier_basis = ("origin" if tier == "gold" and source_type in self.GOLD_BY_ORIGIN
                          else "validated" if tier == "gold"
                          else "sourced" if tier == "silver" else "ingested")
        if tier == "gold" and tier_basis == "origin" and source_type not in self.GOLD_BY_ORIGIN:
            raise ValueError(
                f"{entity_table}:{entity_id} — '{source_type}' no es hecho irrefutable; "
                f"no puede entrar directo a gold (Regla B37)")
        if tier == "gold" and tier_basis == "validated" and not validated_by:
            raise ValueError(f"{entity_table}:{entity_id} — gold por validacion exige validated_by")
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

    # ── CORE ─────────────────────────────────────────────────────────────────

    def load_system_info(self):
        info = dict(SYSTEM_INFO)
        info["built_at"] = datetime.now(timezone.utc).isoformat(timespec="seconds")
        self._insert(
            "system_info", [info],
            source_type="signed_artifact",
            source_ref=lambda r: f"bank-brain/CLAUDE.md#{r.get('slug')}",
            tier="gold", id_field="slug", valid_from="2026-10-27",
        )

    def load_ontology_bindings(self):
        primary = [b for b in ONTOLOGY_BINDINGS if b.get("role") == "primary"]
        if len(primary) != 1:
            raise ValueError(
                f"ONTOLOGY_BINDINGS debe tener exactamente una ontologia role='primary' "
                f"(hay {len(primary)}) — Reglas B18 y B20")
        self._insert(
            "ontology_bindings", ONTOLOGY_BINDINGS,
            source_type="document",
            source_ref="knowledge-base/methodology/metodologia-analisis-situacion.md#R0",
            tier="silver", id_field="ontology", valid_from="2026-10-27",
        )

    def load_source_catalog(self):
        """
        ADR-EB-014. Dueno dt-source-steward. Toda fila con status='ausente'
        tiene su hueco correspondiente en knowledge_gaps.
        """
        self._insert(
            "source_catalog", SOURCE_CATALOG,
            source_type="document",
            source_ref="knowledge-base/source-catalog.md",
            tier="silver", valid_from="2026-10-27",
        )

    def load_knowledge_gaps(self):
        self._insert(
            "knowledge_gaps", KNOWLEDGE_GAPS,
            source_type="document",
            source_ref="knowledge-base/source-catalog.md",
            tier="silver", valid_from="2026-10-27",
        )

    def load_cross_dependencies(self):
        self._insert(
            "cross_dependencies", CROSS_DEPENDENCIES,
            source_type="document",
            source_ref=lambda r: r.get("origin_artifact") or "",
            tier="silver", valid_from="1972-07-25",
        )

    # Tablas del CORE que R0 declara vacias a proposito. R1 y R2 las pueblan.
    def load_capabilities(self):
        self._insert("capabilities", [])          # R1

    def load_processes(self):
        self._insert("processes", [])             # R1

    def load_products(self):
        self._insert("products", [])              # R1, bloqueado por GAP-RIP-002

    def load_kpis(self):
        self._insert("kpis", [])                  # R1

    def load_stakeholders(self):
        self._insert("stakeholders", [])          # R1

    def load_technology_components(self):
        self._insert("technology_components", []) # R2, bloqueado por GAP-RIP-007

    def load_suppliers(self):
        self._insert("suppliers", [])             # R2

    def load_data_entities(self):
        self._insert("data_entities", [])         # R2

    def load_itom_layer(self):
        self._insert("itom_layer", [])            # R2

    # ── Extension ENTERPRISE ─────────────────────────────────────────────────

    def load_federated_brains(self):
        """
        Regla B4 — federacion via ATTACH. Vacia por diseno: no existe todavia
        ningun brain de sistema ni de proyecto de Banco Ripley que federar.
        """
        self._insert("federated_brains", [])

    def load_documents(self):
        """
        Corpus documental curado. Red de seguridad de cero perdida: el texto
        completo queda indexado para que nada se pierda en la destilacion.
        Lee knowledge-base/, nunca source/ directo (Regla P1).
        """
        rows = []
        if KB_PATH.is_dir():
            for f in sorted(KB_PATH.rglob("*.md")):
                texto = f.read_text(encoding="utf-8")
                rows.append({
                    "path": str(f.relative_to(HERE)).replace("\\", "/"),
                    "filename": f.name,
                    "categoria": f.parent.name if f.parent != KB_PATH else "raiz",
                    "n_lineas": texto.count("\n") + 1,
                    "contenido": texto,
                })
        self._insert(
            "documents", rows,
            source_type="document",
            source_ref=lambda r: r["path"],
            tier="silver", id_field="path", valid_from="2026-10-27",
        )

    # ── Cierre ───────────────────────────────────────────────────────────────

    def rebuild_fts(self):
        pairs = [
            ("rules_fts", "rules", "id, business_name, description, fragmento"),
            ("vocabulary_fts", "vocabulary", "id, term, definition"),
            ("components_fts", "components", "id, name, display_name, description"),
            # El template canonico omite documents_fts aunque el schema lo declara.
            # En un brain enterprise es el unico indice que importa.
            ("documents_fts", "documents", "path, filename, contenido"),
        ]
        for fts, src, cols in pairs:
            try:
                self.db.execute(f"DELETE FROM {fts}")
                self.db.execute(f"INSERT INTO {fts} SELECT {cols} FROM {src}")
            except sqlite3.Error:
                pass

    def emit_signals(self):
        ts = datetime.now(timezone.utc).isoformat(timespec="seconds")
        rows = [
            {"signal": "brain_built", "value": BRAIN_VERSION, "source": "build-bank-brain.py", "ts": ts},
            {"signal": "ronda", "value": "R0", "source": "build-bank-brain.py", "ts": ts},
            {"signal": "source_catalog_count", "value": str(self.counts.get("source_catalog", 0)),
             "source": "build-bank-brain.py", "ts": ts},
            {"signal": "open_gap_count", "value": str(self.counts.get("knowledge_gaps", 0)),
             "source": "build-bank-brain.py", "ts": ts},
            {"signal": "federated_brain_count", "value": str(self.counts.get("federated_brains", 0)),
             "source": "build-bank-brain.py", "ts": ts},
        ]
        self._insert("signals", rows)

    def emit_seeds(self):
        """Regla B11 — push, no pull."""
        deps = self.db.execute("SELECT * FROM cross_dependencies").fetchall()
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
                    "origin_artifact": d.get("origin_artifact"),
                    "dependency_type": d.get("dependency_type"),
                    "direction": d.get("direction"),
                    "volume": d.get("volume"),
                    "criticality": d.get("criticality"),
                    "description": d.get("description"),
                },
            }
            name = f"{d['other_system']}-seed.json"
            (SEEDS_PATH / name).write_text(
                json.dumps(seed, ensure_ascii=False, indent=2), encoding="utf-8")
            manifest.append(name)
        (SEEDS_PATH / "manifest.json").write_text(
            json.dumps({"seeds": manifest}, ensure_ascii=False, indent=2), encoding="utf-8")

    #: Tablas que no contienen afirmaciones sobre el cliente sino telemetria del
    #: propio build, y que por lo tanto no tienen procedencia que declarar. El
    #: template canonico del asset omite esta exencion y por eso su assert_lineage
    #: aborta en cualquier build: emit_signals siempre inserta filas en `signals`
    #: y nunca les registra linaje. Defecto reportado, corregido aqui.
    TELEMETRY_TABLES = ("signals", "queries")

    def assert_lineage(self):
        con_linaje = {
            r[0] for r in self.db.execute(
                "SELECT DISTINCT entity_table FROM knowledge_lineage")
        }
        sin_linaje = [
            f"{t} ({n} filas)" for t, n in sorted(self.counts.items())
            if n and t != "knowledge_lineage" and t not in con_linaje
            and t not in self.TELEMETRY_TABLES
        ]
        total = self.db.execute("SELECT COUNT(*) FROM knowledge_lineage").fetchone()[0]
        if sin_linaje:
            raise RuntimeError(
                "Hay conocimiento cargado sin declarar su procedencia (Regla B37). "
                "Tablas con filas y sin una sola entrada en knowledge_lineage: "
                + ", ".join(sin_linaje)
                + ". Pasa source_type, source_ref y tier a _insert().")
        sin_vigencia = self.db.execute(
            "SELECT COUNT(*) FROM knowledge_lineage WHERE valid_from IS NULL"
        ).fetchone()[0]
        if sin_vigencia:
            print(f"  [aviso B40] {sin_vigencia} de {total} afirmaciones sin valid_from.",
                  file=sys.stderr)
        print(f"  linaje: {total} afirmaciones sobre {len(con_linaje)} tabla(s)")

    def summary(self):
        print(f"\nbank-brain.db · {SYSTEM_INFO['slug']} · v{BRAIN_VERSION} · ronda R0")
        print(f"  tipo: {SYSTEM_INFO['brain_type']} · industria: {SYSTEM_INFO['industry']}"
              f" · status: {SYSTEM_INFO['status']}")
        for t, n in sorted(self.counts.items()):
            if n:
                print(f"  {t:<24}{n:>8}")
        # Tablero de niveles (B37) — hay DOS vistas y no son la misma cifra.
        # El Brain Auditor mide en D9 la columna `tier` de las tablas de
        # conocimiento; `source_catalog` y `knowledge_gaps` no la tienen, asi que
        # el grueso del contenido de un brain en R0 le es invisible. La vista por
        # linaje si cubre toda afirmacion cargada. Se reportan las dos, separadas,
        # porque presentarlas como una sola cifra seria enganoso.
        por_linaje = self.db.execute(
            "SELECT tier, COUNT(*) FROM knowledge_lineage GROUP BY tier ORDER BY 2 DESC"
        ).fetchall()
        print("  niveles por linaje (toda afirmacion):",
              ", ".join(f"{r[0]} {r[1]}" for r in por_linaje) or "vacio")
        por_columna = self.db.execute(
            "SELECT tier, COUNT(*) FROM cross_dependencies GROUP BY tier"
        ).fetchall()
        print("  niveles por columna tier (lo que mide D9):",
              ", ".join(f"{r[0]} {r[1]}" for r in por_columna) or "vacio")
        abiertos = self.db.execute(
            "SELECT COUNT(*) FROM knowledge_gaps WHERE status='open'").fetchone()[0]
        bloqueantes = self.db.execute(
            "SELECT id FROM knowledge_gaps WHERE impact LIKE 'BLOQUEANTE%'").fetchall()
        print(f"  huecos abiertos: {abiertos}"
              f" · bloqueantes: {', '.join(r[0] for r in bloqueantes) or 'ninguno'}")
        ausentes = self.db.execute(
            "SELECT COUNT(*) FROM source_catalog WHERE status='ausente'").fetchone()[0]
        print(f"  fuentes ausentes: {ausentes} de {self.counts.get('source_catalog', 0)}")

    # ── Orquestacion ─────────────────────────────────────────────────────────

    def build(self):
        self.open()
        self.init_schema()

        # CORE — ningun brain esta exento
        self.load_system_info()
        self.load_ontology_bindings()
        self.load_source_catalog()
        self.load_capabilities()
        self.load_processes()
        self.load_products()
        self.load_kpis()
        self.load_stakeholders()
        self.load_technology_components()
        self.load_suppliers()
        self.load_data_entities()
        self.load_itom_layer()
        self.load_cross_dependencies()
        self.load_knowledge_gaps()

        bt = SYSTEM_INFO["brain_type"]
        if bt == "enterprise":
            self.load_federated_brains()
            self.load_documents()
        else:
            raise ValueError(f"brain_type '{bt}' no esperado en este brain")

        self.rebuild_fts()
        self.emit_signals()
        self.emit_seeds()
        self.assert_lineage()
        self.summary()
        self.close()


def run_validator() -> int:
    root = asset_root()
    if not root:
        print("Asset Enterprise Brain no alcanzable desde el arbol", file=sys.stderr)
        return 2
    validador = root / "dt" / "dt-brain-auditor" / "validate.py"
    if not validador.exists():
        print(f"Brain Auditor no encontrado en {validador}", file=sys.stderr)
        return 2
    return subprocess.run([sys.executable, str(validador), "--db", str(DB_PATH)]).returncode


def main():
    p = argparse.ArgumentParser(description="Pipeline R0 del bank-brain de Banco Ripley")
    p.add_argument("--dry-run", action="store_true",
                   help="construye en memoria sin escribir bank-brain.db")
    p.add_argument("--validate", action="store_true",
                   help="corre el Brain Auditor sobre el bank-brain.db existente")
    args = p.parse_args()

    if args.validate:
        return run_validator()

    BrainBuilder(dry_run=args.dry_run).build()
    return 0


if __name__ == "__main__":
    sys.exit(main())
