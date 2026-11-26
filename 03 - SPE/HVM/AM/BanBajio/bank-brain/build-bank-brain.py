"""
build-bank-brain.py — Pipeline del bank-brain de BanBajío
Versión: 1.0.0 · Enterprise Brain · Digital Core · Accenture México

Instanciado desde `00 - Enterprise Brain/templates/build-brain.py`.

EL ESQUEMA NO SE COPIA. ADR-EB-006 fija que `templates/schema.sql` es la única
fuente de verdad del DDL, y el modo de falla documentado del asset es
precisamente transcribirlo: la copia deriva y nadie se entera. Este build
resuelve el esquema subiendo por el árbol hasta el asset y falla ruidosamente
si no lo alcanza. La Regla B1 pide que el brain responda sin el asset montado,
y eso lo cumple `bank-brain.db` una vez construida; construirla sí requiere el
canon vigente, que es justo lo que queremos.

CORPUS: solo información pública al 2026-11-25. Ningún documento del cliente,
ninguna entrevista, ningún código. Lo que no está publicado se declara en
`knowledge_gaps`, nunca se completa por verosimilitud (Regla B17).

USO:
    python build-bank-brain.py              # construye bank-brain.db
    python build-bank-brain.py --dry-run    # construye en memoria
    python build-bank-brain.py --validate   # corre el Brain Auditor

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
    Quien cruza el primer tramo es un extractor de `extractors/`, que emite a
    knowledge-base/extracted/ y nunca escribe en brain.db (ADR-EB-015).
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
ACTION_SEED_PATH = HERE / "action-catalog-seed.sql"
KB_PATH = HERE / "knowledge-base"
SEEDS_PATH = HERE / "seeds"
EXTRACTORS_PATH = HERE / "extractors"


def asset_root() -> Path | None:
    """Localiza el asset Enterprise Brain subiendo por el árbol."""
    for p in [HERE, *HERE.parents]:
        cand = p / "00 - Enterprise Brain"
        if cand.is_dir():
            return cand
    return None


def schema_path() -> Path:
    """El DDL vive en el asset y solo ahí (ADR-EB-006).

    Sin copia local de respaldo a propósito: una copia que nadie compara con el
    original es la forma en que el canon y la instancia dejan de coincidir sin
    que ninguna de las dos lo note.
    """
    root = asset_root()
    if root and (root / "templates" / "schema.sql").exists():
        return root / "templates" / "schema.sql"
    raise FileNotFoundError(
        "No se alcanzó 00 - Enterprise Brain/templates/schema.sql. "
        "El DDL canónico no se copia a la instancia (ADR-EB-006): monta el "
        "asset o corre el build desde el repositorio completo."
    )

# El pipeline de fuentes es opcional para una instancia, no para el canon: si
# la carpeta está, sus módulos quedan importables; si no, el build sigue y el
# catálogo lo declara.
if EXTRACTORS_PATH.is_dir():
    sys.path.insert(0, str(EXTRACTORS_PATH))

BRAIN_VERSION = "1.0.0"

# ── IDENTIDAD — Reglas B13, B14, B18, B19 ────────────────────────────────────

SYSTEM_INFO = {
    "slug": "banbajio-bank-brain",
    "display_name": "Banco del Bajío",
    "brain_type": "enterprise",
    "hemisphere": "change",          # cubre ambos; la columna admite uno solo
    "togaf_type": None,              # un brain de empresa no es un sistema
    "togaf_state": None,
    "togaf_abb": None,
    # Industria ANCLA — fija el nombre del brain de cliente ({industria}-brain)
    "industry": "banca",
    "industry_sme": "SME/Industry/Industry Banking",
    "capability_model": "Banking Enterprise Technology Blueprint V5.0 "
                        "(7 dominios, 57 L2, 261 L3) con el catálogo L4 de banca "
                        "mexicana v3.4 (271 L4 en 26 L3)",
    "process_ontology": "Procesos por producto financiero del Logical Operating "
                        "Model Digital Bank 4.0, capa México",
    "process_ontology_version": "DB40 L0/L1/L2",
    "itom_model": "IT Operating Model v9.0 (38 procesos en 6 dominios)",
    "itom_sme": "SME/Framework/IT Operating Model",
    # Banca no tiene eje de ramo, a diferencia de seguros (ADR-EB-007).
    "lob_dimension": None,
    "version": BRAIN_VERSION,
    "status": "discovered",          # → 'active' solo tras Brain Auditor PASS
    "source_of_truth": "knowledge-base/ (corpus curado de registros públicos: "
                       "CNBV, Banco de México, Bolsa Mexicana de Valores, "
                       "reportes anuales y prensa financiera)",
    "build_agent": "Enjambre de 24 Digital Twins canónicos (Regla B41)",
}

# ── ONTOLOGÍA — Regla B20 ────────────────────────────────────────────────────
# Toda empresa compone su ontología de los ETB que le corresponden más sus
# extensiones propias. Exactamente una lleva role='primary'.
# Ejemplo real (Liverpool): retail primary + financial_services secondary.

ONTOLOGY_BINDINGS = [
    {
        "ontology": "banca",
        "role": "primary",
        # etb | bian | regulatory | it-capability | value-chain | client-logical
        "model_type": "etb",
        "catalog": "Banking Enterprise Technology Blueprint V5.0",
        "catalog_version": "5.0",
        "industry_sme": "SME/Industry/Industry Banking",
        "regulators": ["CNBV", "Banco de México", "CONDUSEF", "IPAB", "UIF", "SHCP"],
        "l3_base": 261,
        "l3_extension": 0,
        "rationale": "Institución de banca múltiple con licencia mexicana. Es la "
                     "ontología ancla y fija el nombre del brain (Regla B18). La "
                     "capa México del Industry SME ya está resuelta, a diferencia "
                     "de Banco Ripley: el catálogo L4 trae 271 operaciones en 26 "
                     "capacidades L3, validadas contra regulación y plataformas "
                     "mexicanas. Las extensiones propias de BanBajío se marcan con "
                     "is_extension en capabilities, no abren un binding aparte.",
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
        "rationale": "La cara de TI de la ontología de dos caras. Los 38 procesos "
                     "son la rejilla contra la que se mide la evidencia que el "
                     "brain vaya reuniendo del habilitador tecnológico.",
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
        "rationale": "Vocabulario de interoperabilidad para traducir capacidades a "
                     "dominios de servicio cuando entre al alcance una plataforma "
                     "de mercado. Hoy sin capacidades mapeadas y declarado así.",
    },
]

# ── CORPUS — de dónde sale cada afirmación ───────────────────────────────────
# El brain refleja lo que la empresa ES (Regla B25) y todo lo que afirma declara
# su fuente (B37). Con corpus exclusivamente público, nada de lo que describe la
# tecnología del banco puede entrar en gold: lo publicado por la propia emisora
# es intención o reporte, no el sistema productivo.

SRC_REPORTE = "Reporte trimestral 3T26 y comunicados de resultados de la emisora"
SRC_BMV = "Bolsa Mexicana de Valores, eventos relevantes de la emisora"
SRC_SITIO = "Sitio institucional del banco, sección de agronegocios y empresas"
SRC_PRENSA = "Prensa financiera mexicana, 2025 y 2026"
SRC_ANUAL = "Reporte Anual 2023 presentado ante la Bolsa Mexicana de Valores"

# ── IDENTIDAD DE LA EMPRESA — Etapa 0 (ADR-EB-015) ───────────────────────────

COMPANY_PROFILE = [{
    "slug": SYSTEM_INFO["slug"],
    "tier": "silver",
    "legal_name": "Banco del Bajío, S.A., Institución de Banca Múltiple",
    "display_name": "BanBajío",
    "founded_year": 1994,
    "ownership": "publica",
    "parent_group": None,
    "ticker": "BBAJIO",
    "hq_country": "México",
    "geographies": ["México"],
    "industries": ["banca"],
    "business_model": "Banca múltiple de nicho empresarial. Coloca crédito a "
                      "empresas, a la pequeña y mediana empresa, al sector "
                      "agropecuario y a gobiernos estatales y municipales, y "
                      "obtiene su resultado principalmente del margen financiero. "
                      "En el crédito agropecuario opera apalancado en fondeo y "
                      "garantías de banca de segundo piso, y llega al productor "
                      "pequeño por una red de intermediarios en lugar de hacerlo "
                      "con sucursal propia.",
    "source_ref": SRC_ANUAL,
}]

# ── TRAYECTORIA — Regla B26 ──────────────────────────────────────────────────
# La historia explica el porqué de la tecnología. Cada hito lleva el nivel que
# le corresponde por su fuente, y el de fundación entra en bronze a propósito:
# tres fuentes públicas dan tres fechas distintas y ninguna es un acta.

BUSINESS_MILESTONES = [
    {
        "id": "MIL-001", "tier": "bronze", "occurred_year": 1994,
        "milestone_type": "fundacion",
        "title": "Constitución del banco en León, Guanajuato",
        "description": "Nace por iniciativa de un grupo de empresarios del Bajío "
                       "y de la Ciudad de México, con 28 empleados y vocación "
                       "regional. La fecha exacta está en disputa entre fuentes "
                       "públicas y se declara como hueco.",
        "impact": "Fija dos rasgos que siguen vigentes: origen regional fuera de "
                  "la Ciudad de México y clientela empresarial desde el día uno, "
                  "no banca de consumo masivo.",
        "source_ref": SRC_PRENSA, "valid_from": "1994-01-01",
    },
    {
        "id": "MIL-002", "tier": "bronze", "occurred_year": 1994,
        "milestone_type": "crisis",
        "title": "Arranque durante la crisis financiera de 1994 y 1995",
        "description": "El banco inicia operaciones en el peor momento del "
                       "sistema bancario mexicano moderno.",
        "impact": "Arranca sin la cartera heredada que cargó a los bancos ya "
                  "establecidos, y con ella sin los sistemas de esa generación. "
                  "Es la hipótesis que hay que verificar contra el estate real: "
                  "un banco de 1994 no tiene por qué cargar un núcleo de los "
                  "años setenta.",
        "source_ref": SRC_PRENSA, "valid_from": "1994-12-01",
    },
    {
        "id": "MIL-003", "tier": "silver", "occurred_year": 2017,
        "milestone_type": "ipo",
        "title": "Oferta pública inicial en la Bolsa Mexicana de Valores",
        "description": "Las acciones empiezan a cotizar el 8 de junio de 2017. "
                       "La oferta global colocó 24.04% del capital social a 29.50 "
                       "pesos por acción, hasta 9,089 millones de pesos con "
                       "sobreasignación, repartida entre México y mercados "
                       "internacionales. En la parte secundaria, el fondo "
                       "soberano de Singapur redujo su participación.",
        "impact": "Somete al banco al régimen de emisora: reportes trimestrales, "
                  "eventos relevantes y reporte anual. Esa obligación es, hoy, la "
                  "única razón por la que este brain tiene algo que leer.",
        "source_ref": SRC_BMV, "valid_from": "2017-06-08",
    },
    {
        "id": "MIL-004", "tier": "silver", "occurred_year": 2026,
        "milestone_type": "reestructura",
        "title": "Relevo en la dirección general y reestructura organizacional",
        "description": "El consejo de administración confirmó al nuevo director "
                       "general en abril de 2026 y el relevo ocurrió en mayo. La "
                       "reestructura organizacional quedó reportada como evento "
                       "relevante ante la Bolsa Mexicana de Valores.",
        "impact": "Abre el ciclo estratégico vigente, que empuja el crecimiento "
                  "fuera de la región de origen. Un brain que se construya ahora "
                  "retrata una organización en movimiento, no una estable.",
        "source_ref": SRC_BMV, "valid_from": "2026-05-01",
    },
    {
        "id": "MIL-005", "tier": "silver", "occurred_year": 2026,
        "milestone_type": "reestructura",
        "title": "Calificación nacional AAA.mx de Moody's Local México",
        "description": "La emisora reportó haber alcanzado la máxima calificación "
                       "en escala nacional.",
        "impact": "Mejora las condiciones de fondeo, que es la materia prima del "
                  "modelo de negocio.",
        "source_ref": SRC_BMV, "valid_from": "2026-01-01",
    },
]

# ── LO QUE MUEVE A LA EMPRESA — Etapa 0 ──────────────────────────────────────
# Un pilar declarado en un reporte es INTENCIÓN, no hecho (B37): silver por
# origen. Marcarlo gold contaminaría todo lo que cuelgue del driver.

STRATEGIC_DRIVERS = [
    {
        "id": "DRV-001", "tier": "silver", "driver_type": "objetivo",
        "title": "Duplicar el negocio empresarial en la Ciudad de México hacia 2030",
        "description": "La dirección general declaró públicamente la intención de "
                       "colocar la mitad del negocio en la Ciudad de México y de "
                       "desplegarse con fuerza también en Monterrey y Guadalajara.",
        "horizon": "2030", "priority": "alta", "status": "en_ejecucion",
        "declared_by": "STK-001", "source_ref": SRC_PRENSA,
        "valid_from": "2026-08-19",
    },
    {
        "id": "DRV-002", "tier": "silver", "driver_type": "pilar",
        "title": "Crecer por encima del sistema bancario",
        "description": "Declarado como mandato de la institución. La cartera creció "
                       "16.5% anual a septiembre de 2026, aproximadamente 1.8 veces "
                       "el ritmo del sistema.",
        "horizon": "2030", "priority": "alta", "status": "en_ejecucion",
        "declared_by": "STK-001", "source_ref": SRC_PRENSA,
        "valid_from": "2026-01-01",
    },
    {
        "id": "DRV-003", "tier": "silver", "driver_type": "objetivo",
        "title": "Entrar al grupo de los ocho bancos más grandes de México",
        "description": "Ambición declarada en entrevistas públicas de 2026. El "
                       "banco se describe a sí mismo como el octavo del sistema "
                       "por activos y el tercero de control mexicano.",
        "horizon": "2030", "priority": "alta", "status": "declarado",
        "declared_by": "STK-001", "source_ref": SRC_PRENSA,
        "valid_from": "2026-01-01",
    },
    {
        "id": "DRV-004", "tier": "silver", "driver_type": "pilar",
        "title": "Transformación digital dentro del plan estratégico",
        "description": "La banca digital pasó a ser el canal principal en 2024, "
                       "con crecimiento anual de 30%, y 83% de las transacciones "
                       "ocurren en canales no asistidos, sumando banca digital y "
                       "cajero automático.",
        "horizon": "2026", "priority": "alta", "status": "en_ejecucion",
        "declared_by": "STK-002", "source_ref": SRC_PRENSA,
        "valid_from": "2024-01-01",
    },
    {
        "id": "DRV-005", "tier": "silver", "driver_type": "objetivo",
        "title": "Guía financiera 2026",
        "description": "Crecimiento de cartera de 11 a 12%, de depósitos de 10 a "
                       "11%, y utilidad neta de 8,400 a 9,000 millones de pesos. "
                       "Revisada con los resultados del segundo trimestre.",
        "horizon": "2026-12-31", "priority": "alta", "status": "en_ejecucion",
        "declared_by": "STK-001", "source_ref": SRC_REPORTE,
        "valid_from": "2026-07-29",
    },
]

# Criterio de salida de la Etapa 0: cada driver se ata a algo que el brain ya
# cargó, o se declara su hueco. Un driver sin ningún link es hallazgo.
DRIVER_LINKS = [
    {"id": 1, "tier": "silver", "driver_id": "DRV-001",
     "entity_table": "products", "entity_id": "PRD-001", "relation": "sirve",
     "rationale": "El crecimiento en la Ciudad de México se declaró sobre el "
                  "negocio empresarial, que es la línea de este producto.",
     "source_ref": SRC_PRENSA},
    {"id": 2, "tier": "silver", "driver_id": "DRV-002",
     "entity_table": "kpis", "entity_id": "KPI-001", "relation": "mide",
     "rationale": "La participación en crédito empresarial es la medida pública "
                  "con la que la propia institución sustenta el mandato.",
     "source_ref": SRC_REPORTE},
    {"id": 3, "tier": "silver", "driver_id": "DRV-004",
     "entity_table": "capabilities", "entity_id": "CAP-7.1.4", "relation": "sirve",
     "rationale": "El canal digital como canal principal se sostiene sobre la "
                  "capacidad de acceso del cliente.",
     "source_ref": SRC_PRENSA},
]

# ── CIFRAS — ADR-EB-012 ──────────────────────────────────────────────────────
# Las cifras NO viven en company_profile: son mediciones ancladas a ella, con su
# fecha de corte. Una meta no es una medición y se distingue por source_type.

MEASUREMENTS = [
    {"id": 1, "tier": "silver", "entity_table": "company_profile",
     "entity_id": SYSTEM_INFO["slug"], "metric": "cartera_credito_total",
     "value_num": 312368, "value_text": None, "unit": "millones de MXN",
     "measured_at": "2026-09-30", "period_start": None, "period_end": "2026-09-30",
     "source_type": "report", "source_ref": SRC_REPORTE, "process_id": None},
    {"id": 2, "tier": "silver", "entity_table": "company_profile",
     "entity_id": SYSTEM_INFO["slug"], "metric": "depositos_total",
     "value_num": 310315, "value_text": None, "unit": "millones de MXN",
     "measured_at": "2026-09-30", "period_start": None, "period_end": "2026-09-30",
     "source_type": "report", "source_ref": SRC_REPORTE, "process_id": None},
    {"id": 3, "tier": "silver", "entity_table": "company_profile",
     "entity_id": SYSTEM_INFO["slug"], "metric": "crecimiento_anual_cartera",
     "value_num": 16.5, "value_text": None, "unit": "%",
     "measured_at": "2026-09-30", "period_start": "2025-09-30",
     "period_end": "2026-09-30",
     "source_type": "report", "source_ref": SRC_REPORTE, "process_id": None},
    {"id": 4, "tier": "silver", "entity_table": "company_profile",
     "entity_id": SYSTEM_INFO["slug"], "metric": "crecimiento_anual_depositos",
     "value_num": 13.1, "value_text": None, "unit": "%",
     "measured_at": "2026-09-30", "period_start": "2025-09-30",
     "period_end": "2026-09-30",
     "source_type": "report", "source_ref": SRC_REPORTE, "process_id": None},
    {"id": 5, "tier": "silver", "entity_table": "company_profile",
     "entity_id": SYSTEM_INFO["slug"], "metric": "utilidad_neta_trimestral",
     "value_num": 1782, "value_text": None, "unit": "millones de MXN",
     "measured_at": "2026-09-30", "period_start": "2026-07-01",
     "period_end": "2026-09-30",
     "source_type": "report", "source_ref": SRC_REPORTE, "process_id": None},
    {"id": 6, "tier": "silver", "entity_table": "company_profile",
     "entity_id": SYSTEM_INFO["slug"], "metric": "utilidad_neta_trimestral",
     "value_num": 2118, "value_text": None, "unit": "millones de MXN",
     "measured_at": "2026-06-30", "period_start": "2026-04-01",
     "period_end": "2026-06-30",
     "source_type": "report", "source_ref": SRC_REPORTE, "process_id": None},
    {"id": 7, "tier": "silver", "entity_table": "company_profile",
     "entity_id": SYSTEM_INFO["slug"], "metric": "utilidad_neta_trimestral",
     "value_num": 2042, "value_text": None, "unit": "millones de MXN",
     "measured_at": "2026-03-31", "period_start": "2026-01-01",
     "period_end": "2026-03-31",
     "source_type": "report", "source_ref": SRC_REPORTE, "process_id": None},
    {"id": 8, "tier": "silver", "entity_table": "company_profile",
     "entity_id": SYSTEM_INFO["slug"], "metric": "indice_capitalizacion",
     "value_num": 14.8, "value_text": "preliminar", "unit": "%",
     "measured_at": "2026-09-30", "period_start": None, "period_end": "2026-09-30",
     "source_type": "report", "source_ref": SRC_REPORTE, "process_id": None},
    {"id": 9, "tier": "bronze", "entity_table": "company_profile",
     "entity_id": SYSTEM_INFO["slug"], "metric": "sucursales",
     "value_num": 326, "value_text": "fuentes públicas divergen entre 295 y 326",
     "unit": "sucursales",
     "measured_at": "2026-11-25", "period_start": None, "period_end": None,
     "source_type": "report", "source_ref": SRC_SITIO, "process_id": None},
    {"id": 10, "tier": "silver", "entity_table": "company_profile",
     "entity_id": SYSTEM_INFO["slug"], "metric": "transacciones_canal_no_asistido",
     "value_num": 83, "value_text": "banca digital y cajero automático", "unit": "%",
     "measured_at": "2024-12-31", "period_start": "2024-01-01",
     "period_end": "2024-12-31",
     "source_type": "report", "source_ref": SRC_PRENSA, "process_id": None},
    {"id": 11, "tier": "silver", "entity_table": "company_profile",
     "entity_id": SYSTEM_INFO["slug"], "metric": "crecimiento_banca_digital",
     "value_num": 30, "value_text": None, "unit": "%",
     "measured_at": "2024-12-31", "period_start": "2023-12-31",
     "period_end": "2024-12-31",
     "source_type": "report", "source_ref": SRC_PRENSA, "process_id": None},
    {"id": 12, "tier": "silver", "entity_table": "company_profile",
     "entity_id": SYSTEM_INFO["slug"], "metric": "utilidad_neta_objetivo_anual",
     "value_num": None, "value_text": "8,400 a 9,000 millones de MXN",
     "unit": "millones de MXN",
     "measured_at": "2026-12-31", "period_start": "2026-01-01",
     "period_end": "2026-12-31",
     "source_type": "forecast", "source_ref": SRC_REPORTE, "process_id": None},
]

# ── PROCESOS — Regla B19 y B22 ───────────────────────────────────────────────
# El brain NO inventa la semántica de su industria: la toma del Industry SME.
# Estos 28 procesos de primer nivel son el Logical Operating Model Digital Bank
# 4.0 tal como lo publica `SME/Industry/Industry Banking/knowledge_base/
# banking-logical-om-db40.md`, con el identificador que ese catálogo sugiere.
# Es el modelo de cómo DEBERÍA operar un banco. Lo que BanBajío hace realmente
# se compara contra esta rejilla, y la brecha entre ambos es el hallazgo.

SRC_SME_DB40 = ("SME/Industry/Industry Banking/knowledge_base/"
                "banking-logical-om-db40.md")

_DB40 = [
    # (process_id, código L1, nombre, L0, L2 principales)
    ("P-STR-001", "S1", "Enterprise Strategy & Performance Mgmt", "STRATEGIZE",
     "Enterprise Strategy Management, Enterprise Performance Management"),
    ("P-POR-001", "S2", "Business Portfolio Mgmt", "STRATEGIZE",
     "Portfolio Planning & Strategy, Market & Opportunity Analysis, "
     "Organic Portfolio Development, Inorganic Portfolio Development"),
    ("P-SRH-001", "S3", "Stakeholder Relationship Mgmt", "STRATEGIZE",
     "Stakeholder Management Strategy, Stakeholder Interaction Management"),
    ("P-ESG-001", "S4", "Enterprise Sustainability", "STRATEGIZE",
     "ESG Strategy, ESG Risk Management, ESG Reporting & Performance Management, "
     "Stakeholder Engagement"),
    ("P-BRD-001", "S5", "Brand Strategy", "STRATEGIZE",
     "Market & Customer Analysis, Brand Establishment & Execution, "
     "Brand Enhancement"),
    ("P-INN-001", "S6", "Innovation", "STRATEGIZE",
     "Innovation Strategy, Ideation Strategy, Innovation Culture"),
    ("P-MKT-001", "O1", "Marketing", "OPERATIONALIZE",
     "Marketing Intelligence, Marketing Strategy & Planning, Channel & Content, "
     "Promotional Marketing, Marketing Operations"),
    ("P-VTA-001", "O2", "Sales", "OPERATIONALIZE",
     "Sales Strategy & Planning, Pricing Management, Sales Execution, "
     "Sales Enablement"),
    ("P-SVC-001", "O3", "Customer Service", "OPERATIONALIZE",
     "Customer Onboarding & Management, Service Operations, Service Enablement, "
     "AML/KYC Compliance"),
    ("P-CEX-001", "O4", "Customer Experience", "OPERATIONALIZE",
     "CX Design, CX Management, Loyalty & Member Program"),
    ("P-ECO-001", "O5", "Ecosystem & Partner Mgmt", "OPERATIONALIZE",
     "Ecosystem Design, Ecosystem Orchestration"),
    ("P-PDV-001", "O6", "Product Design & Development", "OPERATIONALIZE",
     "Product Research, Product Development, Product Launch, "
     "Product Lifecycle Management"),
    ("P-OPS-001", "O7", "Cross Products Processing & Servicing", "OPERATIONALIZE",
     "Origination, Contract Servicing, Payment Services, Cards & Merchants "
     "Processing & Servicing, Cash Management, Interest & Fees Management, "
     "Clearing & Settlement Service, Collection & Defaults Management, "
     "Collateral Management, Fraud & AML"),
    ("P-BPO-001", "O8", "Banking Products Operations Mgmt", "OPERATIONALIZE",
     "Lending Management, Deposits Management, Cards & Merchant Management, "
     "Wealth Management, Insurance, Trade Finance Management, Mutual Funds, "
     "Equity, Treasury Banking Management, Off-balance"),
    ("P-RSK-001", "O9", "Enterprise Risk Management", "OPERATIONALIZE",
     "Enterprise Risk Management Strategy, Enterprise Risk Evaluation & "
     "Assessment, Enterprise Risk Operations"),
    ("P-FIN-001", "E1", "Finance", "ENABLE",
     "Invoice to Pay, Accounts Receivables, Record to Report, Business "
     "Consolidation & Reporting, Financial Planning & Analysis, Tax, Treasury"),
    ("P-BPM-001", "E2", "Business Process Mgmt", "ENABLE",
     "BPM Strategy & Governance, BPM Execution, BPM Architecture & Methods, "
     "BPM Technology & Platform, BPM Enablement & Support"),
    ("P-RES-001", "E3", "Business Resilience", "ENABLE",
     "Business Resilience Strategy, Business Resilience Operations"),
    ("P-SEC-001", "E4", "Enterprise Security", "ENABLE",
     "Security Strategy & Business Alignment, Security Diagnostics & Operations"),
    ("P-GVN-001", "E5", "Governance & Compliance", "ENABLE",
     "Enterprise Governance Management, Compliance Management"),
    ("P-ITM-001", "E6", "IT", "ENABLE", "IT Operations, IT Service Management"),
    ("P-INF-001", "E7", "Infrastructure & Facility Mgmt", "ENABLE",
     "Real Estate Management, Facility Management, Technology Infrastructure "
     "Control"),
    ("P-KNW-001", "E8", "Knowledge & Document Mgmt", "ENABLE",
     "Knowledge & Document Management Strategy, Knowledge Management Operations"),
    ("P-LEG-001", "E9", "Legal & Regulatory Affairs", "ENABLE",
     "Legal Services Management, Regulatory Affairs Management, Responsible AI"),
    ("P-RHU-001", "E10", "Human Resources", "ENABLE",
     "HR Strategy, Access Talent, Create Talent, Unlock Potential, Reward, "
     "Transition, HR Enablement"),
    ("P-DAT-001", "E11", "Data Management", "ENABLE",
     "Enterprise Data Strategy, Master Data Management, Data Operations, "
     "Data Lifecycle Management"),
    ("P-ANA-001", "E12", "Insights & Analytics", "ENABLE",
     "Marketing Analytics, Research & Development Analytics, Sourcing & "
     "Procurement Analytics, Operations Intelligence & Monitoring, Financial "
     "Controlling & Reporting Analytics, HR Analytics, Business Foundation "
     "Analytics"),
    ("P-SCM-001", "E13", "Supply Chain", "ENABLE",
     "Supply Chain Relationships & Partnerships, Sourcing & Procurement "
     "Analytics, Supply Chain Procurement"),
]

PROCESSES = [{
    "id": pid, "tier": "silver", "ontology": "banca-db40",
    "ontology_version": "Digital Bank 4.0 LOM", "lob": None,
    "l1_name": f"{cod} {nombre}", "l2_name": None, "l3_name": None,
    "l4_name": None,
    "description": f"Dominio {l0} del Logical Operating Model. Procesos de "
                   f"segundo nivel: {l2s}.",
    "capability_id": None, "systems": None,
    # Sin evidencia del estate no se afirma cobertura. Poner COVERED aquí sería
    # describir el modelo y no al banco, que es justo lo que B25 prohíbe.
    "coverage_status": None,
    "source_sme": "SME/Industry/Industry Banking",
} for pid, cod, nombre, l0, l2s in _DB40]

# ── CAPACIDADES — Reglas B20 y B21 ───────────────────────────────────────────
# Las del ETB que la evidencia pública sostiene, más las extensiones propias de
# BanBajío. `is_extension=1` marca lo que el catálogo global no modela: la banca
# de segundo piso y el canal de intermediarios no existen en el ETB V5.0, y eso
# es brecha del modelo, no del banco.

CAPABILITIES = [
    {"id": "CAP-3.3.1", "tier": "silver", "ontology": "banca",
     "ontology_version": "5.0", "catalog_source": "Banking ETB V5.0",
     "is_extension": 0, "l1_name": "3. Product & Service",
     "l2_name": "3.3 Lending", "l3_name": "Credit Structuring & Approval",
     "definition": "Estructuración y aprobación de crédito. Es el corazón del "
                   "modelo de BanBajío: empresarial, pequeña y mediana empresa, "
                   "agronegocios y gobierno.",
     "regulation": ["CNBV", "Banco de México"],
     "coverage_status": None, "process_id": "P-BPO-001",
     "coverage_confidence": "low",
     "coverage_evidence": "El reporte anual declara un equipo de análisis de "
                          "crédito dedicado e independiente para empresarial, "
                          "pequeña y mediana empresa y agronegocios. No hay "
                          "evidencia pública del sistema que lo ejecuta.",
     "primary_system": None, "component_count": 0},
    {"id": "CAP-3.3.4", "tier": "silver", "ontology": "banca",
     "ontology_version": "5.0", "catalog_source": "Banking ETB V5.0",
     "is_extension": 0, "l1_name": "3. Product & Service",
     "l2_name": "3.3 Lending", "l3_name": "Credit Servicing Management",
     "definition": "Administración del crédito a lo largo de su vida.",
     "regulation": ["CNBV"],
     "coverage_status": None, "process_id": "P-BPO-001",
     "coverage_confidence": "low",
     "coverage_evidence": "Se infiere del tamaño de la cartera reportada. Sin "
                          "evidencia del sistema.",
     "primary_system": None, "component_count": 0},
    {"id": "CAP-3.2.4", "tier": "silver", "ontology": "banca",
     "ontology_version": "5.0", "catalog_source": "Banking ETB V5.0",
     "is_extension": 0, "l1_name": "3. Product & Service",
     "l2_name": "3.2 Accounts and Deposits",
     "l3_name": "Deposit Account Servicing",
     "definition": "Operación de cuentas de depósito.",
     "regulation": ["CNBV", "Banco de México", "IPAB"],
     "coverage_status": None, "process_id": "P-BPO-001",
     "coverage_confidence": "low",
     "coverage_evidence": "Depósitos por 310,315 millones de pesos al cierre de "
                          "septiembre de 2026.",
     "primary_system": None, "component_count": 0},
    {"id": "CAP-3.4.3", "tier": "silver", "ontology": "banca",
     "ontology_version": "5.0", "catalog_source": "Banking ETB V5.0",
     "is_extension": 0, "l1_name": "3. Product & Service",
     "l2_name": "3.4 Payments", "l3_name": "Core Payment Processing",
     "definition": "Procesamiento central de pagos, incluido el masivo.",
     "regulation": ["Banco de México", "CNBV"],
     "coverage_status": None, "process_id": "P-OPS-001",
     "coverage_confidence": "medium",
     "coverage_evidence": "Un comunicado del proveedor declara que el banco "
                          "modernizó el procesamiento de pagos y los pagos "
                          "masivos con Volante Technologies. Anclado a O7 y no a "
                          "O8 porque el procesamiento transversal de pagos vive "
                          "ahí; el mapa del Industry SME solo desambigua a nivel "
                          "L1 y el criterio queda declarado como hueco.",
     "primary_system": None, "component_count": 0},
    {"id": "CAP-7.1.4", "tier": "silver", "ontology": "banca",
     "ontology_version": "5.0", "catalog_source": "Banking ETB V5.0",
     "is_extension": 0, "l1_name": "7. Customer & Partner Mgmt",
     "l2_name": "7.1 Customer Management",
     "l3_name": "Customer Access Management",
     "definition": "Acceso del cliente a sus productos por los canales del banco.",
     "regulation": ["CNBV", "CONDUSEF"],
     "coverage_status": None, "process_id": "P-SVC-001",
     "coverage_confidence": "medium",
     "coverage_evidence": "La banca digital es el canal principal desde 2024 y "
                          "83% de las transacciones ocurren en canales no "
                          "asistidos.",
     "primary_system": None, "component_count": 0},
    {"id": "CAP-5.9.2", "tier": "silver", "ontology": "banca",
     "ontology_version": "5.0", "catalog_source": "Banking ETB V5.0",
     "is_extension": 0, "l1_name": "5. Enterprise Functions",
     "l2_name": "5.9 Risk Management", "l3_name": "Risk Assessment",
     "definition": "Evaluación del riesgo de crédito y de la cartera.",
     "regulation": ["CNBV", "Banco de México"],
     "coverage_status": None, "process_id": "P-RSK-001",
     "coverage_confidence": "low",
     "coverage_evidence": "El reporte anual declara gestión de riesgo "
                          "especializada por segmento. Anclado a O9 y no a E5, "
                          "siguiendo la corrección del Industry SME de 2026-10-16.",
     "primary_system": None, "component_count": 0},
    {"id": "CAP-EXT-001", "tier": "silver", "ontology": "banca",
     "ontology_version": "5.0", "catalog_source": "Extensión propia de BanBajío",
     "is_extension": 1, "l1_name": "3. Product & Service",
     "l2_name": "3.3 Lending",
     "l3_name": "Fondeo y garantías de banca de segundo piso",
     "definition": "Originación de crédito agropecuario apalancada en fondeo, "
                   "garantías y apoyos de fideicomisos públicos de segundo piso. "
                   "El ETB V5.0 no modela banca de segundo piso: es brecha del "
                   "catálogo global frente al mercado mexicano, del mismo tipo "
                   "que la ausencia de remesas que el Industry SME ya documentó.",
     "regulation": ["CNBV", "SHCP"],
     "coverage_status": None, "process_id": "P-BPO-001",
     "coverage_confidence": "medium",
     "coverage_evidence": "El sitio institucional documenta programas y factoraje "
                          "con fondeo y garantías del fideicomiso de segundo piso "
                          "del sector agropecuario.",
     "primary_system": None, "component_count": 0},
    {"id": "CAP-EXT-002", "tier": "silver", "ontology": "banca",
     "ontology_version": "5.0", "catalog_source": "Extensión propia de BanBajío",
     "is_extension": 1, "l1_name": "7. Customer & Partner Mgmt",
     "l2_name": "7.2 Partner Management",
     "l3_name": "Dispersión de crédito por agentes parafinancieros",
     "definition": "Colocación de crédito al productor pequeño a través de un "
                   "segundo intermediario: uniones de crédito, parafinancieras, "
                   "organizaciones auxiliares y uniones ganaderas. El riesgo, el "
                   "expediente y la trazabilidad del crédito no viven en la "
                   "sucursal, y eso cambia qué sistemas los sostienen.",
     "regulation": ["CNBV", "CONDUSEF"],
     "coverage_status": None, "process_id": "P-ECO-001",
     "coverage_confidence": "medium",
     "coverage_evidence": "Declarado en el sitio institucional y en prensa.",
     "primary_system": None, "component_count": 0},
]

# ── PRODUCTOS Y KPI — Regla B27 ──────────────────────────────────────────────
# Las líneas que la evidencia pública sostiene. El catálogo comercial completo
# no es público y queda declarado como hueco: estos son niveles de línea, no de
# producto contratable.

PRODUCTS = [
    {"id": "PRD-001", "tier": "silver", "name": "Crédito empresarial",
     "description": "Financiamiento a empresas. Es la línea sobre la que se "
                    "declaró la ambición de crecimiento en la Ciudad de México.",
     "product_type": "credito", "product_line": "banca-empresas",
     "status": "active", "channel": "sucursal", "process_id": "P-BPO-001",
     "regulation": ["CNBV", "Banco de México"],
     "owner_domain": "Banca Empresarial", "launched_at": None,
     "source_doc": SRC_ANUAL},
    {"id": "PRD-002", "tier": "silver",
     "name": "Crédito a la pequeña y mediana empresa",
     "description": "Financiamientos desde 500 mil hasta 50 millones de pesos, "
                    "colocados por ejecutivos especializados en la red de "
                    "sucursales.",
     "product_type": "credito", "product_line": "banca-pyme",
     "status": "active", "channel": "sucursal", "process_id": "P-BPO-001",
     "regulation": ["CNBV", "CONDUSEF"],
     "owner_domain": "Banca PyME", "launched_at": None, "source_doc": SRC_SITIO},
    {"id": "PRD-003", "tier": "silver", "name": "Crédito a agronegocios",
     "description": "Crédito al sector agropecuario y rural con fondeo, garantías "
                    "y apoyos de banca de segundo piso.",
     "product_type": "credito", "product_line": "agronegocios",
     "status": "active", "channel": "all", "process_id": "P-BPO-001",
     "regulation": ["CNBV", "SHCP"],
     "owner_domain": "Agronegocios", "launched_at": None, "source_doc": SRC_SITIO},
    {"id": "PRD-004", "tier": "silver", "name": "Factoraje para agronegocios",
     "description": "Factoraje con el esquema del fideicomiso de segundo piso del "
                    "sector agropecuario.",
     "product_type": "credito", "product_line": "agronegocios",
     "status": "active", "channel": "sucursal", "process_id": "P-BPO-001",
     "regulation": ["CNBV"],
     "owner_domain": "Agronegocios", "launched_at": None, "source_doc": SRC_SITIO},
    {"id": "PRD-005", "tier": "bronze", "name": "Crédito a gobierno",
     "description": "Financiamiento a entidades de gobierno. El banco se describe "
                    "públicamente como banco para gobierno, sin detalle del "
                    "catálogo.",
     "product_type": "credito", "product_line": "gobierno",
     "status": "active", "channel": "sucursal", "process_id": "P-BPO-001",
     "regulation": ["CNBV", "SHCP"],
     "owner_domain": "Gobierno", "launched_at": None, "source_doc": SRC_SITIO},
    {"id": "PRD-006", "tier": "silver", "name": "Captación y cuentas de depósito",
     "description": "Cuentas de depósito para personas y empresas. Sostiene los "
                    "310,315 millones de pesos de depósitos reportados.",
     "product_type": "cuenta", "product_line": "captacion",
     "status": "active", "channel": "all", "process_id": "P-BPO-001",
     "regulation": ["CNBV", "Banco de México", "IPAB"],
     "owner_domain": "Captación", "launched_at": None, "source_doc": SRC_REPORTE},
]

KPIS = [
    {"id": "KPI-001", "tier": "silver", "product_id": "PRD-001",
     "name": "Participación nacional en crédito empresarial",
     "description": "Medida con la que la institución sustenta públicamente el "
                    "mandato de crecer por encima del sistema.",
     "metric_type": "tasa", "unit": "%", "target": None, "current": "6.4",
     "frequency": "mensual", "process_id": "P-BPO-001",
     "data_source": None, "owner": "STK-001", "status": "active"},
]

# ── QUIÉN RESPONDE — ADR-EB-009 ──────────────────────────────────────────────
# Por rol, nunca por nombre: el DDL lo pide y la frontera interna de B42 lo
# exige. Un portal compartible no debe poder nombrar personas del cliente.

STAKEHOLDERS_BANCO = [
    {"id": "STK-001", "tier": "silver", "name": "Dirección General",
     "stakeholder_type": "executive_sponsor", "organization": "BanBajío",
     "role": "Responsable del mandato de crecimiento", "area": "Dirección General",
     "raci": "accountable", "influence": "high",
     "concern": "Crecer por encima del sistema y ganar participación fuera de la "
                "región de origen",
     "capability_id": None, "hemisphere": "both", "confidence": "confirmed",
     "active": 1, "source_doc": SRC_BMV},
    {"id": "STK-002", "tier": "silver",
     "name": "Dirección Ejecutiva de Tecnología",
     "stakeholder_type": "it_owner", "organization": "BanBajío",
     "role": "Responsable de la tecnología del banco", "area": "Tecnología",
     "raci": "accountable", "influence": "high",
     "concern": "Sostener la operación y ejecutar la renovación de canales",
     "capability_id": None, "hemisphere": "both", "confidence": "confirmed",
     "active": 1, "source_doc": SRC_PRENSA},
    {"id": "STK-003", "tier": "silver",
     "name": "Dirección Corporativa de Banca Digital",
     "stakeholder_type": "business_owner", "organization": "BanBajío",
     "role": "Responsable del canal digital", "area": "Banca Digital",
     "raci": "accountable", "influence": "high",
     "concern": "El canal digital como canal principal del banco",
     "capability_id": "CAP-7.1.4", "hemisphere": "run", "confidence": "confirmed",
     "active": 1, "source_doc": SRC_PRENSA},
]

# Los reguladores entran en gold por origen: una ley publicada no es debatible
# (B37). Van en lote aparte porque su `source_type` es 'regulation' y el del
# resto es 'doc', y mezclarlos obligaría a aplanar uno de los dos.
STAKEHOLDERS_REGULADORES = [
    {"id": "STK-004", "tier": "gold", "name": "CNBV",
     "stakeholder_type": "regulator", "organization": "Estado mexicano",
     "role": "Supervisión y regulación de banca múltiple", "area": "Externo",
     "raci": "consulted", "influence": "high",
     "concern": "Solvencia, cumplimiento y reportes regulatorios",
     "capability_id": None, "hemisphere": "run", "confidence": "confirmed",
     "active": 1, "source_doc": "Ley de Instituciones de Crédito"},
    {"id": "STK-005", "tier": "gold", "name": "Banco de México",
     "stakeholder_type": "regulator", "organization": "Estado mexicano",
     "role": "Regulación monetaria y de sistemas de pago", "area": "Externo",
     "raci": "consulted", "influence": "high",
     "concern": "Sistemas de pago y operaciones del banco central",
     "capability_id": None, "hemisphere": "run", "confidence": "confirmed",
     "active": 1, "source_doc": "Ley del Banco de México"},
    {"id": "STK-006", "tier": "gold", "name": "CONDUSEF",
     "stakeholder_type": "regulator", "organization": "Estado mexicano",
     "role": "Protección al usuario de servicios financieros", "area": "Externo",
     "raci": "consulted", "influence": "medium",
     "concern": "Transparencia, comisiones y atención de reclamaciones",
     "capability_id": None, "hemisphere": "run", "confidence": "confirmed",
     "active": 1, "source_doc": "Ley de Protección y Defensa al Usuario"},
    {"id": "STK-007", "tier": "gold", "name": "IPAB",
     "stakeholder_type": "regulator", "organization": "Estado mexicano",
     "role": "Seguro de depósitos", "area": "Externo",
     "raci": "informed", "influence": "medium",
     "concern": "Cobertura y reporte de las obligaciones garantizadas",
     "capability_id": "CAP-3.2.4", "hemisphere": "run", "confidence": "confirmed",
     "active": 1, "source_doc": "Ley de Protección al Ahorro Bancario"},
    {"id": "STK-008", "tier": "gold", "name": "UIF",
     "stakeholder_type": "regulator", "organization": "Estado mexicano",
     "role": "Prevención de lavado de dinero", "area": "Externo",
     "raci": "informed", "influence": "high",
     "concern": "Reportes de operaciones y cumplimiento del régimen de prevención",
     "capability_id": None, "hemisphere": "run", "confidence": "confirmed",
     "active": 1, "source_doc": "Disposiciones de carácter general, Artículo 115"},
]

# ── PROVEEDORES Y TECNOLOGÍA ─────────────────────────────────────────────────

SUPPLIERS = [
    {"id": "SUP-001", "tier": "silver", "name": "FIRA",
     "business_name": "Fideicomisos Instituidos en Relación con la Agricultura",
     "kind": "strategic_partner", "criticality": "critical",
     "regulatory_flag": 1, "contract_ref": None, "contract_end": None,
     "slo_id": None,
     "exit_plan": None,
     "process_id": "P-BPO-001", "itom_layer_id": None, "status": "active",
     "owner_role": "STK-001",
     "description": "Banca de segundo piso del sector agropecuario. Provee "
                    "fondeo, garantías y apoyos que sostienen la línea de "
                    "agronegocios. Sin plan de salida declarado, lo que en un "
                    "proveedor crítico es hallazgo por definición del esquema.",
     "source_doc": SRC_SITIO},
    {"id": "SUP-002", "tier": "silver", "name": "Volante Technologies",
     "business_name": "Proveedor de la plataforma de pagos",
     "kind": "software_vendor", "criticality": "high",
     "regulatory_flag": 1, "contract_ref": None, "contract_end": None,
     "slo_id": None, "exit_plan": None,
     "process_id": "P-OPS-001", "itom_layer_id": None, "status": "active",
     "owner_role": "STK-002",
     "description": "Comunicado público declara su uso para acelerar el "
                    "procesamiento de pagos y mejorar los pagos masivos.",
     "source_doc": SRC_PRENSA},
]

TECHNOLOGY_COMPONENTS = [
    {"id": "TEC-001", "tier": "silver",
     "name": "Plataforma de procesamiento de pagos de Volante Technologies",
     "category": "platform", "record_scope": None,
     "vendor": "Volante Technologies", "version": None, "hosting": None,
     "location": None, "status": "active", "support_status": "supported",
     "end_of_support": None, "standard_status": None, "itom_layer_id": None,
     "description": "Único componente de tecnología del banco con nombre propio "
                    "en fuente pública. Todo lo demás, empezando por el núcleo "
                    "bancario, está declarado como hueco.",
     "source_doc": SRC_PRENSA},
]

ITOM_LAYER = [
    {"id": "ITOM-001", "tier": "silver", "layer": "it-management",
     "technology": "it-organization", "maturity": None,
     "coverage_status": "partial",
     "evidence": "La antigua Dirección de Transformación Digital se convirtió en "
                 "Dirección Ejecutiva de Tecnología y se creó una Dirección "
                 "Corporativa de Banca Digital. Ambas reportan a la Dirección "
                 "General, lo que coloca la tecnología a un nivel de decisión "
                 "directo.",
     "process_id": "P-ITM-001",
     "itom_sme": "SME/Framework/IT Operating Model"},
]

# ── DEPENDENCIAS — Regla B5 ──────────────────────────────────────────────────
# Declaradas desde la perspectiva de ESTE brain. Solo lo que tiene evidencia
# pública directa. La participación en los sistemas de pago del banco central es
# cierta para cualquier banco múltiple, pero sin fuente específica es inferencia
# y va a knowledge_gaps, no aquí.

CROSS_DEPENDENCIES = [
    {"id": "DEP-001", "tier": "silver", "other_system": "FIRA",
     "dependency_type": "feeds", "direction": "outbound", "volume": 0,
     "domains": ["agronegocios"], "regulation": ["CNBV", "SHCP"],
     "description": "El banco depende del fondeo, las garantías y los apoyos del "
                    "fideicomiso de segundo piso para su línea agropecuaria.",
     "criticality": "critical",
     "evidence": "Programas y factoraje con ese esquema publicados en el sitio "
                 "institucional del banco.",
     "origin_artifact": SRC_SITIO},
]

# ── HUECOS — Regla B17 ───────────────────────────────────────────────────────
# Ningún hueco se deja muerto: cada uno lleva la pregunta concreta que hay que
# hacerle a alguien. En un brain de corpus público esta es la tabla más valiosa,
# porque delimita hasta dónde puede opinar.
#
# El `domain` poblado es lo que ADR-EB-017 reconoce como ancla positiva de
# conocimiento de nivel empresa, exento de process_id. No es un campo cosmético.

HOY = "2026-11-25"

KNOWLEDGE_GAPS = [
    {"id": "GAP-BBAJIO-001", "gap_type": "dato", "dimension": "tecnología",
     "domain": "núcleo bancario", "process_id": "P-BPO-001",
     "description": "No hay fuente pública que identifique el núcleo bancario "
                    "del banco, ni si ha sido reemplazado alguna vez.",
     "impact": "Sin esto el brain no puede opinar sobre modernización, "
               "equivalencia funcional ni riesgo de migración. Es el hueco que "
               "bloquea todo lo demás.",
     "required_for": "DISCOVER", "owner": "dt-domain-architect",
     "resolution_action": "Consulta al cliente: ¿qué plataforma sostiene cuentas, "
                          "crédito y contabilidad, de qué año es y qué tan "
                          "modificada está?",
     "status": "open", "opened_at": HOY, "resolved_at": None},
    {"id": "GAP-BBAJIO-002", "gap_type": "dato", "dimension": "negocio",
     "domain": "identidad", "process_id": None,
     "description": "Tres fuentes públicas dan tres fechas distintas de "
                    "constitución en 1994: 1 de julio, 4 de julio y 2 de "
                    "diciembre.",
     "impact": "Menor para el negocio, real para el reloj bitemporal de B40: el "
               "hito de fundación queda en bronze y no puede anclar nada.",
     "required_for": "DISCOVER", "owner": "dt-client-intelligence",
     "resolution_action": "Consulta dt-source-steward: ¿qué dice el acta "
                          "constitutiva o el registro en la CNBV?",
     "status": "open", "opened_at": HOY, "resolved_at": None},
    {"id": "GAP-BBAJIO-003", "gap_type": "dato", "dimension": "negocio",
     "domain": "red de distribución", "process_id": "P-SVC-001",
     "description": "El número de sucursales varía entre 295 y 326 según la "
                    "fuente y la fecha, y ninguna es un corte oficial reciente.",
     "impact": "La red física es el denominador de cualquier cálculo de "
               "cobertura o de costo por canal.",
     "required_for": "DESIGN", "owner": "dt-distribution-owner",
     "resolution_action": "Consulta dt-source-steward: ¿cuál es el número de "
                          "sucursales y cajeros al cierre del trimestre vigente, "
                          "según el reporte a la CNBV?",
     "status": "open", "opened_at": HOY, "resolved_at": None},
    {"id": "GAP-BBAJIO-004", "gap_type": "dato", "dimension": "negocio",
     "domain": "identidad", "process_id": None,
     "description": "La clave de cotización aparece como BBAJIO en unas fuentes "
                    "y como BBAJIOO en otras, por la serie de la acción.",
     "impact": "Afecta la trazabilidad automatizada de eventos relevantes y "
               "reportes trimestrales, que son la fuente viva de este brain.",
     "required_for": "DISCOVER", "owner": "dt-source-steward",
     "resolution_action": "Consulta dt-source-steward: ¿cuál es la clave de "
                          "pizarra y cuál la serie en el listado oficial de la "
                          "Bolsa Mexicana de Valores?",
     "status": "open", "opened_at": HOY, "resolved_at": None},
    {"id": "GAP-BBAJIO-005", "gap_type": "dato", "dimension": "negocio",
     "domain": "identidad", "process_id": None,
     "description": "La estructura accionaria vigente no está en el corpus. Solo "
                    "consta el movimiento del fondo soberano de Singapur durante "
                    "la oferta de 2017.",
     "impact": "El control accionario condiciona la velocidad de decisión en "
               "inversiones de tecnología.",
     "required_for": "DESIGN", "owner": "dt-client-intelligence",
     "resolution_action": "Consulta dt-source-steward: ¿qué dice el reporte anual "
                          "más reciente sobre accionistas de control?",
     "status": "open", "opened_at": HOY, "resolved_at": None},
    {"id": "GAP-BBAJIO-006", "gap_type": "dato", "dimension": "negocio",
     "domain": "catálogo de productos", "process_id": "P-PDV-001",
     "description": "Los seis productos cargados son líneas de negocio, no "
                    "productos contratables. El catálogo comercial completo no "
                    "es público.",
     "impact": "La cadena de valor de B27 arranca en un eslabón grueso, y "
               "cualquier traza producto a componente hereda esa imprecisión.",
     "required_for": "DESIGN", "owner": "dt-product-owner",
     "resolution_action": "Consulta Industry Banking SME: ¿cuáles de los 89 "
                          "productos de la taxonomía de banca múltiple mexicana "
                          "ofrece esta institución?",
     "status": "open", "opened_at": HOY, "resolved_at": None},
    {"id": "GAP-BBAJIO-007", "gap_type": "dato", "dimension": "negocio",
     "domain": "medición", "process_id": "P-STR-001",
     "description": "No hay KPI públicos por producto. Solo existe uno, la "
                    "participación en crédito empresarial.",
     "impact": "La cadena de B27 queda cortada entre Producto y KPI, y sin ese "
               "eslabón el brain no puede decir si un componente mueve una aguja.",
     "required_for": "BUILD", "owner": "dt-demand-manager",
     "resolution_action": "Consulta al cliente: ¿qué indicadores sigue la "
                          "dirección por línea de negocio y con qué frecuencia?",
     "status": "open", "opened_at": HOY, "resolved_at": None},
    {"id": "GAP-BBAJIO-008", "gap_type": "dato", "dimension": "tecnología",
     "domain": "landscape", "process_id": "P-ITM-001",
     "description": "No existe inventario de aplicaciones. Las carpetas de "
                    "sistemas y proyectos están vacías a propósito (Regla B8).",
     "impact": "Sin estate no hay cara de evidencia: el brain hoy solo tiene el "
               "lado del modelo, y la brecha entre ambos es justo lo que "
               "produciría el hallazgo.",
     "required_for": "BUILD", "owner": "dt-domain-architect",
     "resolution_action": "Consulta al cliente: ¿existe inventario de "
                          "aplicaciones, base de datos de configuración o mapa de "
                          "arquitectura que se pueda compartir?",
     "status": "open", "opened_at": HOY, "resolved_at": None},
    {"id": "GAP-BBAJIO-009", "gap_type": "validación", "dimension": "tecnología",
     "domain": "sistemas de pago", "process_id": "P-OPS-001",
     "description": "Toda institución de banca múltiple participa en los sistemas "
                    "de pago del banco central, pero no hay fuente específica de "
                    "este banco. No se declara como dependencia para no afirmar "
                    "por verosimilitud.",
     "impact": "Faltan dependencias que casi con certeza existen, y su ausencia "
               "es más honesta que inventarlas.",
     "required_for": "DESIGN", "owner": "dt-domain-architect",
     "resolution_action": "Consulta Industry Payments SME: ¿en qué sistemas de "
                          "pago y cámaras participa esta institución, y con qué "
                          "evidencia documental se confirma?",
     "status": "open", "opened_at": HOY, "resolved_at": None},
    {"id": "GAP-BBAJIO-010", "gap_type": "validación", "dimension": "negocio",
     "domain": "ontología", "process_id": "P-OPS-001",
     "description": "El procesamiento central de pagos se ancló a O7 y no a O8. "
                    "El mapa de correspondencia del Industry SME solo desambigua "
                    "al nivel de dominio L1 del ETB.",
     "impact": "Un anclaje equivocado propaga error a toda consulta que recorra "
               "la cadena por proceso. El propio SME ya corrigió nueve anclajes "
               "mal puestos en su catálogo, así que no es un riesgo teórico.",
     "required_for": "BUILD", "owner": "dt-domain-architect",
     "resolution_action": "Consulta Industry Banking SME: ¿3.4.3 Core Payment "
                          "Processing ancla en O7 Cross Products Processing o en "
                          "O8 Banking Products Operations?",
     "status": "open", "opened_at": HOY, "resolved_at": None},
    {"id": "GAP-BBAJIO-011", "gap_type": "decisión", "dimension": "negocio",
     "domain": "ontología", "process_id": "P-BPO-001",
     "description": "El Banking ETB V5.0 no modela banca de segundo piso ni el "
                    "canal de agentes parafinancieros. Se cargaron como "
                    "extensiones propias, no como capacidades del catálogo.",
     "impact": "Es brecha del modelo global frente al mercado mexicano, del mismo "
               "tipo que la ausencia de remesas que el Industry SME ya documentó. "
               "Sube como patrón anonimizado, nunca como caso del cliente (B42).",
     "required_for": "DESIGN", "owner": "dt-knowledge-manager",
     "resolution_action": "Consulta Industry Banking SME: ¿el fondeo de segundo "
                          "piso merece capacidad propia en la capa México, igual "
                          "que se resolvió la ausencia de remesas?",
     "status": "open", "opened_at": HOY, "resolved_at": None},
    {"id": "GAP-BBAJIO-012", "gap_type": "dato", "dimension": "tecnología",
     "domain": "cobertura", "process_id": "P-ITM-001",
     "description": "Los 28 procesos del modelo operativo están cargados sin "
                    "estado de cobertura, porque no hay evidencia del estate que "
                    "permita afirmar cuáles cubre el banco y cómo.",
     "impact": "El brain hoy describe cómo debería operar un banco, no cómo opera "
               "este. Afirmar cobertura sin evidencia sería violar B25.",
     "required_for": "BUILD", "owner": "dt-domain-architect",
     "resolution_action": "Consulta al cliente: ¿qué sistema ejecuta cada uno de "
                          "los procesos de primer nivel del modelo operativo?",
     "status": "open", "opened_at": HOY, "resolved_at": None},
    {"id": "GAP-BBAJIO-013", "gap_type": "dato", "dimension": "negocio",
     "domain": "estrategia", "process_id": "P-STR-001",
     "description": "Dos impulsores estratégicos quedaron sin traza de vuelta: la "
                    "ambición de entrar al grupo de los ocho bancos más grandes y "
                    "la guía financiera del año.",
     "impact": "Es el criterio de salida de la Etapa 0. Un impulsor sin ninguna "
               "liga significa que el brain no cubre esa parte del estate, o que "
               "la empresa declara una prioridad que su tecnología no sostiene.",
     "required_for": "DISCOVER", "owner": "dt-client-intelligence",
     "resolution_action": "Consulta dt-value-manager: ¿qué capacidad o producto "
                          "sostiene cada uno de esos dos impulsores?",
     "status": "open", "opened_at": HOY, "resolved_at": None},
    {"id": "GAP-BBAJIO-014", "gap_type": "dato", "dimension": "tecnología",
     "domain": "inversión", "process_id": "P-ITM-001",
     "description": "Una nota de prensa sin fecha confiable reporta una inversión "
                    "inicial de 250 millones de pesos en un proyecto de tres años "
                    "para renovar canales electrónicos, y una cifra total de "
                    "2,150 millones. No se cargó como medición por eso.",
     "impact": "La inversión en canales fecharía el ciclo de renovación "
               "tecnológica, que es justo lo que explicaría el estado del estate.",
     "required_for": "DESIGN", "owner": "dt-source-steward",
     "resolution_action": "Consulta dt-source-steward: ¿de qué año es esa nota y "
                          "qué dice el reporte anual sobre inversión en "
                          "tecnología por ejercicio?",
     "status": "open", "opened_at": HOY, "resolved_at": None},
    {"id": "GAP-BBAJIO-015", "gap_type": "decisión", "dimension": "regulatoria",
     "domain": "proveedores", "process_id": "P-BPO-001",
     "description": "El proveedor crítico de fondeo de segundo piso está cargado "
                    "sin plan de salida.",
     "impact": "El propio esquema trata un proveedor crítico sin plan de salida "
               "como hallazgo. Aquí la concentración no es contractual sino "
               "estructural: es banca de desarrollo y no tiene sustituto de "
               "mercado, lo que hace la pregunta más seria, no menos.",
     "required_for": "DESIGN", "owner": "dt-supplier-relationship-manager",
     "resolution_action": "Consulta al cliente: ¿qué pasa con la línea "
                          "agropecuaria si cambian las condiciones de fondeo de "
                          "segundo piso?",
     "status": "open", "opened_at": HOY, "resolved_at": None},
]


class BrainBuilder:
    def __init__(self, db_path: Path = DB_PATH, dry_run: bool = False):
        self.db_path = db_path
        self.dry_run = dry_run
        self.counts: dict[str, int] = {}
        self.db: sqlite3.Connection | None = None
        self._cosechas: list | None = None
        #: Huecos que `load_source_catalog` descubre y que `load_knowledge_gaps`
        #: escribe: una fuente ausente es una brecha, no un renglón vacío.
        self._huecos_de_fuentes: list = []

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
    #: archivado. Lo mismo vale para la autonomía de B39: una ejecución ya
    #: ocurrió y el rebinde de roles del catálogo lo hizo una persona, así que
    #: un rebuild que las borrara destruiría justo la evidencia con la que un
    #: tipo de acción gana o pierde nivel (ADR-EB-018).
    #: Se preservan entre builds, y son la excepción a la idempotencia dura.
    RUNTIME_TABLES = ("queries", "action_catalog", "actions")

    def init_schema(self):
        """
        Idempotencia dura: DROP explícito antes de CREATE. Un rebuild produce
        siempre el mismo resultado, sin drift acumulado de corridas anteriores.

        Las tablas de `RUNTIME_TABLES` se preservan y se reinsertan después,
        porque su contenido no se puede reconstruir desde el código fuente.
        """
        ruta = schema_path()
        print(f"  esquema: {ruta.parent.parent.name}/templates/schema.sql (asset)")
        schema = ruta.read_text(encoding="utf-8")
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

        self.siembra_catalogo_acciones()
        self.db.commit()

    def siembra_catalogo_acciones(self):
        """
        Regla B38 — un brain sin catálogo de acciones solo puede observar y
        proponer, porque `evalua_accion()` niega todo lo que no esté ahí.

        Siembra solo cuando el catálogo quedó vacío: si el build anterior lo
        preservó, la semilla no pisa lo que el brain ya tiene rebindeado a sus
        propios roles y herramientas. Un brain que no copió el archivo sigue
        construyendo y es D11 del auditor quien reporta el catálogo vacío, no
        el builder (ADR-EB-018).
        """
        if not ACTION_SEED_PATH.is_file():
            return
        try:
            n = self.db.execute("SELECT COUNT(*) FROM action_catalog").fetchone()[0]
        except sqlite3.Error:
            return
        if n:
            return
        self.db.executescript(ACTION_SEED_PATH.read_text(encoding="utf-8"))
        total = self.db.execute("SELECT COUNT(*) FROM action_catalog").fetchone()[0]
        print(f"  action_catalog: {total} casos de uso sembrados desde el asset")

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

    def _insert_tiered(self, table: str, rows: list[dict], *, source_type: str,
                       source_ref, id_field: str = "id") -> int:
        """Inserta un lote cuyas filas traen cada una su propio `tier`.

        `_insert` aplica un solo tier a todo el lote y escribe ese valor en el
        linaje. Aquí conviven afirmaciones de distinto nivel dentro de la misma
        tabla: la fecha de fundación es bronze porque tres fuentes la
        contradicen, mientras el resto de la trayectoria es silver. Aplanarlas
        al primer tier sería perder exactamente lo que B37 vino a conservar, y
        peor, sería afirmar con más certeza de la que hay.

        Separa además `valid_from`, que es dato de linaje de B40 y no columna de
        la tabla: `_insert` lo lee de la fila pero arma el INSERT con todas sus
        claves, así que una fila con vigencia rompía la escritura.
        """
        if not rows:
            self.counts[table] = 0
            return 0
        filas = [{k: v for k, v in r.items() if k != "valid_from"} for r in rows]
        cols = list(filas[0].keys())
        ph = ",".join("?" * len(cols))
        self.db.executemany(
            f'INSERT OR REPLACE INTO "{table}" ({",".join(cols)}) VALUES ({ph})',
            [
                tuple(
                    json.dumps(f[c], ensure_ascii=False)
                    if isinstance(f[c], (list, dict)) else f[c]
                    for c in cols
                )
                for f in filas
            ],
        )
        for r in rows:
            self.record_lineage(
                table,
                str(r.get(id_field) or r.get("id") or r.get("slug") or ""),
                r.get("tier", "bronze"), source_type,
                (source_ref(r) if callable(source_ref) else source_ref) or "",
                valid_from=r.get("valid_from"),
            )
        self.counts[table] = len(rows)
        return len(rows)

    # ── Cosechas del pipeline de fuentes (ADR-EB-015) ────────────────────────

    def cosechas(self) -> list:
        """Lo que los extractores dejaron en `knowledge-base/extracted/`.

        Se lee una sola vez por build: un rebuild no debe depender del orden
        en que los cargadores pregunten para ver lo mismo.
        """
        if self._cosechas is None:
            carpeta = KB_PATH / "extracted"
            self._cosechas = ([
                json.loads(p.read_text(encoding="utf-8"))
                for p in sorted(carpeta.glob("*.json"))
            ] if carpeta.is_dir() else [])
            if self._cosechas:
                print(f"  pipeline: {len(self._cosechas)} cosecha(s) de extractores")
        return self._cosechas

    @staticmethod
    def _alinea(filas: list) -> list:
        """Mismas columnas para todas las filas del lote.

        `_insert` toma los nombres de columna de la primera fila. Dos cosechas
        de fuentes distintas pueden traer campos distintos para la misma tabla,
        y sin alinear primero el INSERT escribe valores en la columna de al
        lado. Falla silenciosa, de las caras.
        """
        cols = []
        for f in filas:
            for c in f:
                if c not in cols:
                    cols.append(c)
        return [{c: f.get(c) for c in cols} for f in filas]

    def _insert_cosecha(self, table: str, id_field: str = "id") -> int:
        """Escribe en el brain lo que los extractores cosecharon para esa tabla.

        El extractor emite, el cargador escribe: esta es la mitad de abajo del
        contrato de ADR-EB-015 y el único punto donde una cosecha toca el brain.

        El linaje se registra fila por fila y no en bloque, porque dentro de
        una misma corrida pueden convivir tiers distintos y aplanarlos al
        primero sería perder justo lo que B37 vino a conservar.
        """
        lote = []
        for cosecha in self.cosechas():
            for item in cosecha.get("registros", {}).get(table, []):
                lote.append((item, cosecha["fuente"], cosecha))
        if not lote:
            self.counts[table] = 0
            return 0
        self._insert(table, self._alinea([i["fila"] for i, _, _ in lote]),
                     id_field=id_field)
        for item, fuente, cosecha in lote:
            fila = item["fila"]
            # Hay tablas cuya identidad es compuesta: una arista del grafo de
            # llamadas es el par origen-destino, y quedarse con el origen
            # colapsaria todas las salidas de un componente en una sola fila
            # de linaje.
            if isinstance(id_field, tuple):
                ident = "|".join(str(fila.get(c, "")) for c in id_field)
            else:
                ident = str(fila.get(id_field) or fila.get("id")
                            or fila.get("slug") or item["source_ref"])
            self.record_lineage(
                table,
                ident,
                item["tier"], fuente["source_type_linaje"], item["source_ref"],
                asserted_by=cosecha["extractor"], method=cosecha["familia"],
                notes=fuente.get("tier_basis"),
            )
        return len(lote)

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
        # La ontologia que un brain ancla es una decision declarada en su
        # propia configuracion, igual que system_info: entra gold por origen.
        # Sin esto, assert_lineage reprobaba al template recien copiado.
        self._insert(
            "ontology_bindings", ONTOLOGY_BINDINGS,
            source_type="signed_artifact",
            source_ref=lambda r: f"CLAUDE.md#ontologia:{r.get('ontology')}",
            tier="gold", id_field="ontology",
        )

    def load_cross_dependencies(self):
        """
        Regla B5 — se declaran desde la perspectiva de ESTE brain
        (other_system + direction), con evidencia y origin_artifact.
        """
        self._insert_tiered("cross_dependencies", CROSS_DEPENDENCIES,
                            source_type="doc",
                            source_ref=lambda r: r["origin_artifact"])

    def load_knowledge_gaps(self):
        """
        Regla B17 — ningún hueco se deja muerto. Cada dato faltante se declara
        con resolution_action redactada como consulta concreta a un SME.

        Absorbe tres orígenes: los huecos propios del brain, los que los
        extractores declararon al no encontrar algo, y las fuentes que el
        catálogo marcó ausentes. Los tres son la misma cosa vista desde
        distinto lado, y separarlos en tablas los volvería invisibles.
        """
        propios: list[dict] = list(KNOWLEDGE_GAPS)
        for h in propios:
            self.record_lineage("knowledge_gaps", h["id"], "silver",
                                "doc", "knowledge-base/source-catalog.md",
                                asserted_by="dt-client-intelligence",
                                valid_from=h.get("opened_at"))
        del_pipeline = [h for c in self.cosechas()
                        for h in c.get("knowledge_gaps", [])]
        filas = self._alinea(propios + del_pipeline + self._huecos_de_fuentes)
        self._insert("knowledge_gaps", filas)
        # Un hueco tambien es una afirmacion y tambien declara su procedencia:
        # "no lo encontre en esta fuente" se verifica distinto que "nadie lo ha
        # buscado".
        for cosecha in self.cosechas():
            for h in cosecha.get("knowledge_gaps", []):
                self.record_lineage(
                    "knowledge_gaps", h.get("id", ""), "bronze",
                    cosecha["fuente"]["source_type_linaje"], cosecha["fuente"]["id"],
                    asserted_by=cosecha["extractor"], method=cosecha["familia"])
        for h in self._huecos_de_fuentes:
            self.record_lineage("knowledge_gaps", h.get("id", ""), "silver",
                                "signed_artifact", "source-catalog.md",
                                asserted_by="dt-source-steward")

    def load_itom_layer(self):
        """
        Regla B23 — ontología de IT Operating Model, anclada al SME.
        El brain declara qué dominios ITOM cubre y en qué nivel de madurez.
        El modelo completo (procesos, roles, BSC) vive en el SME.

        Valores canónicos de `layer` (ITOM v9.0):
          customer-engagement | it-strategy | delivery |
          technology-operations | information-analytics | it-management
        """
        self._insert_tiered("itom_layer", ITOM_LAYER, source_type="doc",
                            source_ref=SRC_PRENSA)

    def load_capabilities(self):
        """
        Regla B21 — ontología de negocio, OBLIGATORIA en todo brain.
        Cada capability declara su `ontology` de origen (FK a
        ontology_bindings) y si es extensión propia de la empresa
        (`is_extension=1`). La regulación viaja con la capability.

        Para un brain de proyecto es el modelo contra el cual se mide el
        cambio: qué capabilities toca la migración, qué obligaciones cubre.
        """
        self._insert_tiered("capabilities", CAPABILITIES, source_type="doc",
                            source_ref=lambda r: r["coverage_evidence"])

    # ── CORE — cadena de valor (Regla B27) ───────────────────────────────────

    def load_products(self):
        """
        Catálogo de productos del cliente (Regla B27 — orientación a producto).
        Punto de partida de la cadena: Producto → KPI → Proceso → Componente.
        Lo puebla ETB vía el Industry SME; TOGAF lo ubica en el dominio B (B28, B36).
        """
        self._insert_tiered("products", PRODUCTS, source_type="doc",
                            source_ref=lambda r: r["source_doc"])

    def load_kpis(self):
        """
        KPIs vinculados a producto y proceso (Regla B27).
        Change fija `target`; Run mide `current` — análogo a slos del puente.
        """
        self._insert_tiered("kpis", KPIS, source_type="report",
                            source_ref=SRC_REPORTE)

    # ── CORE — estructura TOGAF (ADR-EB-009) ─────────────────────────────────

    def load_stakeholders(self):
        """Dominio B. Los portales compartibles usan role y stakeholder_type, nunca nombres."""
        self._insert_tiered("stakeholders", STAKEHOLDERS_BANCO,
                            source_type="doc",
                            source_ref=lambda r: r["source_doc"])
        propios = self.counts["stakeholders"]
        # Los reguladores entran gold por origen: su fuente es la ley.
        self._insert("stakeholders", STAKEHOLDERS_REGULADORES,
                     source_type="regulation",
                     source_ref=lambda r: r["source_doc"], tier="gold")
        self.counts["stakeholders"] = propios + len(STAKEHOLDERS_REGULADORES)

    def load_suppliers(self):
        """
        Regla B41 / ADR-EB-011 — proveedores y socios estratégicos. Poseída por
        Supplier Relationship Manager; cierra los procesos ITOM 4 y 5.

        Un proveedor se evalúa contra su SLO medido (`slo_id`), nunca contra su
        propuesta. `criticality='critical'` sin `exit_plan` es hallazgo.
        """
        self._insert_tiered("suppliers", SUPPLIERS, source_type="doc",
                            source_ref=lambda r: r["source_doc"])

    def load_source_catalog(self):
        """
        ADR-EB-014 y ADR-EB-015 — catálogo de fuentes. Poseída por
        `dt-source-steward`. Es el PRIMER paso de todo build: antes de poblar
        nada, el brain declara con qué fuentes cuenta y cuáles le faltan.

        El `natural_tier` se deriva de `source_type` según la tabla F2 del DT,
        nunca de captura libre: ninguna afirmación puede superar el tier de la
        fuente que la sostiene (B37). Toda fila con `status='ausente'` genera
        su fila en `knowledge_gaps` con `gap_type='source'`.

        El catálogo se levanta a mano en DISCOVER y vive en
        `knowledge-base/source-catalog.md` hasta esta primera carga. De aquí en
        adelante manda la tabla (ADR-EB-014).
        """
        md = KB_PATH / "source-catalog.md"
        if not md.exists():
            self._insert("source_catalog", [])
            return
        try:
            import contrato
        except ImportError:
            # Una instancia puede no haber copiado `extractors/`. Se declara en
            # vez de fallar: sin pipeline el brain sigue siendo válido, solo
            # más ciego, y eso es exactamente lo que este catálogo mide.
            print("  source_catalog: falta extractors/; el catálogo no se cargó")
            self._insert("source_catalog", [])
            return
        catalogo = contrato.Catalogo.desde(md)
        filas = [{
            "id": f.id, "ontology": f.ontology or SYSTEM_INFO.get("industry", ""),
            "name": f.name, "source_type": f.source_type,
            "generator_type": f.generator_type, "cadence": f.cadence,
            "status": f.status, "natural_tier": f.natural_tier,
            "coverage_pct": f.coverage_pct, "enables": None,
            "location": f.location, "last_refresh": f.last_refresh or None,
            "owner": f.owner or "dt-source-steward",
        } for f in catalogo.fuentes.values()]
        self._insert("source_catalog", filas,
                     source_type="signed_artifact",
                     source_ref=lambda r: f"source-catalog.md#{r['id']}",
                     tier="silver")
        hoy = datetime.now(timezone.utc).date().isoformat()
        for f in filas:
            if f["status"] != "ausente":
                continue
            # La ausencia se ve igual que el silencio si nadie la declara.
            self._huecos_de_fuentes.append({
                "id": f"GAP-SRC-{f['id']}", "gap_type": "source",
                "dimension": "tecnología", "domain": "fuentes", "process_id": None,
                "description": f"{f['name']} no está disponible para este brain",
                "impact": "Todo lo que esa fuente habilitaba queda fuera del alcance "
                          "del brain, y nada lo advierte si no se declara aquí",
                "required_for": "DISCOVER", "owner": f.get("owner"),
                "resolution_action": f"Consulta dt-source-steward: ¿cómo se obtiene "
                                     f"{f['name']}, y qué deja de responder el brain sin ella?",
                "status": "open", "opened_at": hoy, "resolved_at": None,
            })

    def load_company_profile(self):
        """
        ADR-EB-015, Etapa 0 — la ficha de identidad. Poseída por
        `dt-client-intelligence`. Una sola fila, con el mismo slug que
        `system_info`.

        Las CIFRAS no van aquí: ingresos, empleados y participación de mercado
        son filas de `measurements` ancladas a esta tabla.

        Las filas declaradas se cargan primero y la cosecha de un extractor, si
        existe, las pisa: un documento leído por el pipeline vale más que una
        captura a mano.
        """
        self._insert_tiered("company_profile", COMPANY_PROFILE,
                            source_type="doc",
                            source_ref=lambda r: r["source_ref"],
                            id_field="slug")
        propios = self.counts["company_profile"]
        self._insert_cosecha("company_profile", id_field="slug")
        self.counts["company_profile"] += propios

    def load_business_milestones(self):
        """
        ADR-EB-015, Etapa 0 — la trayectoria que explica por qué la empresa es
        como es hoy. Su tier es silver o bronze por origen: una nota de prensa
        no es un hecho firmado.
        """
        self._insert_tiered("business_milestones", BUSINESS_MILESTONES,
                            source_type="doc",
                            source_ref=lambda r: r["source_ref"])
        propios = self.counts["business_milestones"]
        self._insert_cosecha("business_milestones")
        self.counts["business_milestones"] += propios

    def load_strategic_drivers(self):
        """
        ADR-EB-015, Etapa 0 — pilares, objetivos, retos y amenazas, tipados en
        una sola tabla porque comparten estructura y se consultan juntos.

        Un pilar declarado en un reporte anual es INTENCIÓN, no hecho: su tier
        es silver por origen (B37). Marcarlo gold contamina todo lo que cuelgue
        del driver.
        """
        self._insert_tiered("strategic_drivers", STRATEGIC_DRIVERS,
                            source_type="doc",
                            source_ref=lambda r: r["source_ref"])
        propios = self.counts["strategic_drivers"]
        self._insert_cosecha("strategic_drivers")
        self.counts["strategic_drivers"] += propios

    def load_driver_links(self):
        """
        ADR-EB-015, Etapa 0 — la traza de vuelta que convierte el estudio del
        cliente en eje rector y no en prólogo.

        Criterio de salida de la Etapa 0: cada driver tiene al menos un link, o
        está declarado como hueco. Un driver sin ningún link es un hallazgo, no
        un silencio: o el brain no cubre esa parte del estate, o la empresa
        declara una prioridad que su tecnología no sostiene.

        Un documento no puede poblarla: la traza de vuelta necesita el estate,
        no la narrativa. La cosecha de `doc-identidad` trae el hueco por cada
        driver; el link lo pone quien conoce lo cargado.
        """
        self._insert_tiered("driver_links", DRIVER_LINKS, source_type="doc",
                            source_ref=lambda r: r["source_ref"])
        propios = self.counts["driver_links"]
        self._insert_cosecha("driver_links")
        self.counts["driver_links"] += propios

    def load_measurements(self):
        """
        ADR-EB-012 — toda medición del brain, genérica por `entity_table`.
        Las cifras de negocio de la Etapa 0 anclan aquí a `company_profile`.

        `source_type='forecast'` distingue una meta de una medición. Meterlas
        juntas mete el futuro en la serie histórica y después nadie las separa.
        """
        # `recorded_at` es el reloj del brain (B40) y lo pone el build, nunca la
        # captura: cuándo lo supo el brain no es dato de la fuente.
        ahora = datetime.now(timezone.utc).isoformat(timespec="seconds")
        filas = [dict(m, recorded_at=ahora) for m in MEASUREMENTS]
        self._insert_tiered("measurements", filas,
                            source_type="report",
                            source_ref=lambda r: r["source_ref"])
        propios = self.counts["measurements"]
        self._insert_cosecha("measurements")
        self.counts["measurements"] += propios

    def load_costs(self):
        """
        ADR-EB-012 — el costo de lo que el brain describe. Gemela de
        `measurements` y, como ella, genérica por entidad.
        """
        self._insert("costs", [])

    def load_technology_components(self):
        """Dominio T: qué opera TI. Cómo lo opera va en itom_layer (B36)."""
        self._insert_tiered("technology_components", TECHNOLOGY_COMPONENTS,
                            source_type="doc",
                            source_ref=lambda r: r["source_doc"])

    def load_data_entities(self):
        """Dominio D. En brains de sistema se deriva de las referencias componente-tabla."""
        self._insert("data_entities", [])

    # ── Extensión ENTERPRISE ─────────────────────────────────────────────────

    def load_federated_brains(self):
        """
        Regla B4 — federación por ATTACH, nunca por copia. El brain de empresa
        declara qué brains de sistema y de proyecto cuelgan de él; el cruce lo
        razona `callosum.py` en tiempo de consulta.

        Una fila por brain federado, con la ruta relativa a su `brain.db`. Si
        un brain declarado no se puede atar, `brain_attached` queda en 0 y eso
        es un hecho del build, no un error que se traga.
        """
        # Vacío y declarado: no hay brains de sistema ni de proyecto todavía.
        # Las carpetas systems/ y projects/ están creadas y vacías a propósito
        # (Regla B8): un sistema se abre cuando la evidencia lo prueba.
        self._insert("federated_brains", [])

    def load_documents(self):
        """
        El corpus documental del cliente, íntegro. Es la red de seguridad de
        cero pérdida: la destilación se queda con lo que entendió, y el texto
        completo indexado garantiza que lo que no entendió siga ahí.

        Lee `knowledge-base/`, nunca `source/` directo (Regla P1). En un brain
        de empresa suele ser la única tabla de contenido, y de ella depende que
        `search()` responda algo.
        """
        rows = []
        if KB_PATH.is_dir():
            for f in sorted(KB_PATH.rglob("*.md")):
                texto = f.read_text(encoding="utf-8", errors="replace")
                rows.append({
                    "path": f.relative_to(KB_PATH.parent).as_posix(),
                    "filename": f.name,
                    "categoria": f.parent.name if f.parent != KB_PATH else "raiz",
                    "n_lineas": len(texto.splitlines()),
                    "contenido": texto,
                })
        # Sin `valid_from`: la fecha del archivo es del sistema de archivos, no
        # del documento. Inventarla sería peor que el aviso de B40.
        self._insert("documents", rows, source_type="doc",
                     source_ref=lambda r: r["path"], tier="silver",
                     id_field="path")

    # ── Extensión SYSTEM ─────────────────────────────────────────────────────

    def load_component_data(self):
        """Matriz CRUD aplicación-dato. Patrón de Informix sp_table_refs."""
        self._insert("component_data", [])

    def load_components(self):
        """
        Las piezas del sistema. El extractor `codigo-componentes` las emite en
        gold, porque el codigo fuente productivo es hecho irrefutable: es el
        sistema (B37).

        Lo que el parser NO emite y alguien tiene que poner: el nombre de
        negocio, el dominio, la capability que sirve y si es alma. Son juicio,
        y por eso llegan con `fill_quality='partial'`.
        """
        self._insert_cosecha("components")

    def load_component_calls(self):
        """
        El grafo de llamadas. De el se leen las almas: un componente con mucho
        fan-in no es automaticamente un alma, pero ninguna alma tiene poco.

        Una llamada solo entra si su destino es un componente de este brain.
        Un nombre invocado que no resuelve es dependencia externa y va a
        `cross_dependencies`, nunca a un nodo inventado.
        """
        self._insert_cosecha("component_calls",
                             id_field=("from_component", "to_component"))

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
        self._insert_tiered("processes", PROCESSES, source_type="doc",
                            source_ref=SRC_SME_DB40)

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
        """Reconstruye los índices de búsqueda desde las tablas ya cargadas.

        `documents_fts` estaba declarado en el esquema y nadie lo poblaba. En
        un brain de empresa, cuya única tabla de contenido es `documents`, eso
        dejaba `search()` sin nada que responder.

        El error ya no se traga: un índice que no se puede reconstruir es un
        problema del build, y una excepción amplia que devuelve en silencio lo
        vuelve indistinguible de un índice vacío legítimo.
        """
        pares = [
            ("rules_fts", "rules", "id, business_name, description, fragmento"),
            ("vocabulary_fts", "vocabulary", "id, term, definition"),
            ("components_fts", "components", "id, name, display_name, description"),
            ("documents_fts", "documents", "path, filename, contenido"),
        ]
        existentes = {
            r["name"] for r in self.db.execute(
                "SELECT name FROM sqlite_master WHERE type IN ('table','view')")
        }
        for fts, src, cols in pares:
            if fts not in existentes or src not in existentes:
                continue
            self.db.execute(f"DELETE FROM {fts}")
            self.db.execute(f"INSERT INTO {fts} SELECT {cols} FROM {src}")

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
        # Una signal no es conocimiento del cliente: es el registro de esta
        # corrida. Declararla como job_run la deja con linaje sin inventarle
        # una fuente, y evita abrir una lista de tablas exentas, que es donde
        # se esconden las cosas.
        self._insert("signals", rows, source_type="job_run",
                     source_ref="build-brain.py", tier="gold", id_field="signal")

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

        # Antes de poblar nada: con qué fuentes cuenta este brain y cuáles le
        # faltan (ADR-EB-015). Una ausencia no declarada se ve igual que un
        # silencio, y es la diferencia entre no saber y no haber mirado.
        self.load_source_catalog()

        # CORE — ningún brain está exento
        self.load_system_info()
        self.load_ontology_bindings()

        # Etapa 0 — Identidad: quién es la empresa, de dónde viene y qué la
        # mueve, antes de que el método toque una línea de código (ADR-EB-015)
        self.load_company_profile()
        self.load_business_milestones()
        self.load_strategic_drivers()
        self.load_measurements()        # ADR-EB-012 — incluye las cifras de negocio
        self.load_costs()               # ADR-EB-012
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
        # Va al final del CORE: ata los drivers con lo que ya se cargó. Es el
        # criterio de salida de la Etapa 0 y lo que la vuelve eje rector.
        self.load_driver_links()
        self.load_knowledge_gaps()

        bt = SYSTEM_INFO["brain_type"]
        if bt not in ("system", "project", "enterprise"):
            raise ValueError(
                f"brain_type '{bt}' no existe; son enterprise, project o system. "
                f"Sin rama, el build termina vacío y parece exitoso")
        if bt == "enterprise":
            # Extensión ENTERPRISE
            self.load_federated_brains()   # Regla B4 — federación por ATTACH
            self.load_documents()          # corpus íntegro, cero pérdida
        if bt == "system":
            self.load_components()
            self.load_component_calls()   # el grafo del que se leen las almas
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
    # El template contaba niveles de carpeta a mano y por eso no encontraba el
    # asset desde una instancia a otra profundidad. Se reusa `asset_root()`,
    # que ya sabe localizarlo subiendo por el árbol.
    root = asset_root()
    validador = (root / "dt" / "dt-brain-auditor" / "validate.py") if root else Path("")
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
