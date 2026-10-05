"""
seed-decisions.py
Puebla decisions_history con los ADRs del proyecto SPE-AM-001 (BanCoppel Informix).
Los ADRs están documentados en los CLAUDE.md de la jerarquía AM — no existen
como archivos independientes, por lo que se extraen aquí de forma estructurada.

Uso: python generators/seed-decisions.py [--dry-run]
"""
import sqlite3
import pathlib
import sys
import json
from datetime import date

BRAIN = pathlib.Path(__file__).parent.parent / "digital-brain" / "brain.db"
DRY_RUN = "--dry-run" in sys.argv

# ---------------------------------------------------------------------------
# ADRs del proyecto SPE-AM-001 — BanCoppel Application Modernization (Informix)
# Fuente: Application Modernization CLAUDE.md + Informix CLAUDE.md (v2.3.0)
# ---------------------------------------------------------------------------
ADRS = [
    {
        "decision_id": "ADR-SPE-AM-001",
        "date": "2026-05-28",
        "context": (
            "Cada capability del sistema Informix (PISA) debe recibir una decisión "
            "7R antes de entrar a DESIGN. Sin esta decisión firmada, no hay DoR "
            "para el sprint de modernización. El sistema tiene 49 dominios (D01-D49) "
            "con 12,812 SPs y 261 capacidades ETB L3 mapeadas."
        ),
        "decision": (
            "Aplicar la taxonomía 7R de AWS/Gartner (Rehost · Replatform · Refactor · "
            "Repurchase · Retain · Retire · Relocate) por capability ETB L3, "
            "documentando la decisión en el brain.db campo sp_capabilities.migration_fate "
            "y en el Solution Plan SP-04. Decisión firmada por arquitecto + sponsor "
            "de negocio antes de cada wave."
        ),
        "alternatives": (
            "1. Decisión 7R a nivel de dominio completo (D01-D49) — descartada: "
            "granularidad insuficiente, capacidades dentro de un mismo dominio tienen "
            "fates distintos (ej. D03-Créditos: parte Refactor, parte Retain). "
            "2. Decisión única big-bang al inicio del programa — descartada: "
            "la complejidad de 12,812 SPs hace inviable un análisis completo antes "
            "de tener evidencia empírica del brain."
        ),
        "consequences": (
            "Positivas: granularidad adecuada para priorizar waves · base para "
            "equivalence testing · input directo al pricing CCM. "
            "Negativas: requiere actualización continua del brain conforme avanza "
            "el análisis AS-IS · riesgo de inconsistencia si sp_capabilities.migration_fate "
            "no se sincroniza con el Solution Plan."
        ),
        "status": "accepted",
        "domain": "all",
        "related_sps": json.dumps([]),
    },
    {
        "decision_id": "ADR-SPE-AM-002",
        "date": "2026-05-28",
        "context": (
            "Informix PISA es un SoR core bancario con 30+ años en producción. "
            "No puede apagarse durante la migración. Se necesita un patrón de "
            "coexistencia que permita migrar capability por capability sin interrupción "
            "del servicio bancario ni riesgo de pérdida de transacciones."
        ),
        "decision": (
            "Strangler-Fig por capability como patrón de coexistencia por defecto. "
            "Una fachada (Anti-Corruption Layer) enruta tráfico al legacy o al "
            "nuevo sistema por feature flag por capability ETB L3. "
            "El parallel-run mínimo es 2 sprints en producción shadow antes de cutover."
        ),
        "alternatives": (
            "1. Branch-by-Abstraction — válido para capabilities que no tienen "
            "boundary externo claro; se aplica como variante dentro del Strangler-Fig "
            "cuando aplique. "
            "2. Big-bang cutover — descartado: riesgo regulatorio CNBV + "
            "imposibilidad de rollback en ventana de fin de semana para un sistema "
            "con 12,812 SPs y 166 customer journeys activos."
        ),
        "consequences": (
            "Positivas: rollback trivial por feature flag · riesgo reducido capability "
            "por capability · cumplimiento CNBV al no haber downtime. "
            "Negativas: coexistencia implica doble on-call · ACL debe mantenerse "
            "durante ventana de migración (min 6 meses internos · 12 meses consumers externos) · "
            "complejidad operativa del comparator en parallel-run."
        ),
        "status": "accepted",
        "domain": "all",
        "related_sps": json.dumps([]),
    },
    {
        "decision_id": "ADR-SPE-AM-003",
        "date": "2026-05-28",
        "context": (
            "Informix IDS 14.10 sobre IBM POWER/AIX gestiona 60TB de datos con "
            "tipos propietarios (MONEY, DATETIME, SERIAL). El target es AWS Aurora "
            "PostgreSQL. La migración de datos es el mayor riesgo de equivalencia "
            "funcional — especialmente el manejo de decimales MONEY vs NUMERIC en PostgreSQL."
        ),
        "decision": (
            "CDC dual-write con Debezium + Kafka Connect durante el parallel-run. "
            "Para el bulk inicial: full export desde Informix + transformación ETL "
            "con validación de conteos y checksums por tabla. "
            "Para delta: CDC continuo hasta cutover. "
            "Conversión MONEY → NUMERIC(19,4) en PostgreSQL con test de redondeo "
            "obligatorio (SLO-AM-01: drift < 0.05%)."
        ),
        "alternatives": (
            "1. Bulk + delta manual (sin CDC) — descartado: riesgo de lag en "
            "tablas de alta frecuencia (D08-SPEI · D01-Canal Web con >813 endpoints ATM). "
            "2. Replicación Informix nativa — descartado: no disponible hacia PostgreSQL "
            "sin middleware propietario IBM."
        ),
        "consequences": (
            "Positivas: zero-downtime migration · validación continua de equivalencia "
            "de datos · rollback posible hasta el cutover final. "
            "Negativas: infraestructura adicional (Kafka cluster) · latencia de CDC "
            "introduce ventana de inconsistencia < 1s que debe ser aceptada por "
            "el negocio · tipos SERIAL de Informix requieren secuencias PostgreSQL "
            "con manejo de colisiones."
        ),
        "status": "accepted",
        "domain": "D01,D03,D04,D05,D08",
        "related_sps": json.dumps([]),
    },
    {
        "decision_id": "ADR-SPE-AM-004",
        "date": "2026-05-28",
        "context": (
            "Diferentes capabilities del sistema tienen perfiles de carga distintos: "
            "capabilities batch (155 CTM_ENTRY · 1,459 batch_orchestrators) vs. "
            "capabilities OLTP síncronas (552 SPs con métricas ESB producción). "
            "El target runtime debe adecuarse a cada perfil."
        ),
        "decision": (
            "Runtime diferenciado por perfil: "
            "(a) OLTP síncrono → microservicios Java 21 + Quarkus sobre EKS con "
            "HPA (Horizontal Pod Autoscaler); "
            "(b) Batch orquestado → AWS Batch + Step Functions reemplazando Control-M "
            "como scheduler; "
            "(c) Reportería regulatoria → AWS Lambda + S3 para jobs de reporte "
            "CNBV/Banxico (frecuencia mensual/trimestral, sin SLO de latencia estricto)."
        ),
        "alternatives": (
            "1. Runtime único (todo EKS) — descartado: sobredimensionamiento para "
            "workloads batch de ventana nocturna · costo innecesario. "
            "2. Serverless total (Lambda) — descartado: cold start incompatible "
            "con SLO P95 < 200ms de OLTP bancario."
        ),
        "consequences": (
            "Positivas: costo optimizado por perfil · escalado independiente OLTP vs batch · "
            "AWS Batch reemplaza dependencia de licencia Control-M. "
            "Negativas: tres runtimes implican tres pipelines CI/CD distintos · "
            "equipo requiere expertise en EKS + AWS Batch + Lambda."
        ),
        "status": "accepted",
        "domain": "all",
        "related_sps": json.dumps([]),
    },
    {
        "decision_id": "ADR-SPE-AM-005",
        "date": "2026-05-28",
        "context": (
            "El análisis de 12,812 SPs en SPL (Stored Procedure Language de Informix) "
            "requiere herramientas AI-assisted para escalar. SPL es un lenguaje "
            "poco soportado por herramientas comerciales de transpilación. "
            "El equipo necesita decidir el stack de herramientas para la fase DISCOVER."
        ),
        "decision": (
            "Stack AI-assisted custom: "
            "(a) Extracción y análisis — pipeline Python custom (mine-source.py · "
            "extract-rules.py · enrich-rules.py · build-brain.py) sobre código SPL raw; "
            "(b) Síntesis de business_name — Claude API (scatter-gather por lotes de "
            "70-80 SPs) con lectura del fuente completo (ADR-SPE-AM-010); "
            "(c) Transpilación — no automatizada en Fase 1; se evalúa Amazon Q Developer "
            "Transform para Fase BUILD una vez validada equivalencia en DISCOVER. "
            "Herramientas comerciales (ISPIRER · Striim) evaluadas pero descartadas "
            "por soporte limitado de SPL propietario."
        ),
        "alternatives": (
            "1. ISPIRER MnMTK — descartado: soporte Informix SPL limitado · "
            "costo de licencia alto para un sistema que se migra una sola vez. "
            "2. Amazon Q Developer Transform — evaluando para BUILD; no disponible "
            "para DISCOVER (requiere código en Java/COBOL como input)."
        ),
        "consequences": (
            "Positivas: control total del pipeline · adaptable a las particularidades "
            "del SPL BanCoppel (MONEY, FOREACH, tipos propietarios) · sin licencias. "
            "Negativas: mantenimiento del pipeline propio · dependencia del Claude API "
            "para síntesis semántica · transpilación manual requiere mayor esfuerzo BUILD."
        ),
        "status": "accepted",
        "domain": "all",
        "related_sps": json.dumps([]),
    },
    {
        "decision_id": "ADR-SPE-AM-006",
        "date": "2026-06-15",
        "context": (
            "Informix IDS 14.10 usa tipos propietarios con semántica específica: "
            "MONEY (8 bytes, punto fijo 2 decimales sin redondeo IEEE 754) · "
            "DATETIME (con precisión hasta fracciones de segundo) · SERIAL (autoincrement "
            "propietario). PostgreSQL tiene NUMERIC, TIMESTAMP WITH TIME ZONE y SEQUENCE "
            "que difieren en comportamiento edge-case. El riesgo de divergencia "
            "en operaciones financieras es crítico (CNBV exige cuadratura exacta)."
        ),
        "decision": (
            "Mapeo explícito documentado y testeado por tipo: "
            "MONEY → NUMERIC(19,4) con test de redondeo bancario (método half-even "
            "banker's rounding para cumplir CNBV) · "
            "DATETIME YEAR TO FRACTION → TIMESTAMP(3) WITH TIME ZONE en UTC · "
            "SERIAL → SEQUENCE PostgreSQL con seed en MAX(id)+1 post-migración bulk · "
            "VARCHAR/CHAR → TEXT con collation C.UTF-8. "
            "Obligatorio: golden master tests sobre 100 transacciones representativas "
            "de cada tipo antes de aprobar el schema de target."
        ),
        "alternatives": (
            "1. Mapeo automático via herramienta ETL — descartado: las herramientas "
            "comerciales mapean MONEY → FLOAT (pérdida de precisión inaceptable "
            "para operaciones bancarias). "
            "2. Mantener NUMERIC(15,2) — descartado: insuficiente para montos en MXN "
            "con impuestos acumulados (riesgo desbordamiento en portafolios > 10B MXN)."
        ),
        "consequences": (
            "Positivas: eliminación del riesgo de divergencia financiera · "
            "cuadratura CNBV garantizada · tests de tipos como artefacto de compliance. "
            "Negativas: mapeo manual requiere validación por DBA IBM Informix + "
            "QA Equivalencia Funcional · SERIAL con MAX+1 tiene ventana de colisión "
            "si hay inserts concurrentes durante el bulk (requiere lock de tabla)."
        ),
        "status": "accepted",
        "domain": "D03,D04,D05,D08,D12",
        "related_sps": json.dumps([]),
    },
    {
        "decision_id": "ADR-SPE-AM-007",
        "date": "2026-07-16",
        "context": (
            "No aplica a BanCoppel Informix (SPE-AM-001). "
            "Este ADR es canónico del template AM para proyectos SAP ECC → S/4HANA. "
            "Instancia de referencia: Gentera SPE-AM-002."
        ),
        "decision": "N/A para este proyecto — ver Gentera SPE-AM-002.",
        "alternatives": "N/A",
        "consequences": "N/A",
        "status": "not-applicable",
        "domain": "n/a",
        "related_sps": json.dumps([]),
    },
    {
        "decision_id": "ADR-SPE-AM-008",
        "date": "2026-08-12",
        "context": (
            "El programa BanCoppel tiene múltiples sistemas (Informix, SmartVista/BPC, "
            "Control-M, sistemas externos) que necesitan una estructura de carpetas "
            "y una taxonomía de clasificación consistente. Sin taxonomía, el "
            "bank-brain no puede federar consultas cross-sistema de forma uniforme."
        ),
        "decision": (
            "Taxonomía TOGAF 9 como base de clasificación: "
            "core (SoR alta criticidad) · processors (procesadores especializados) · "
            "channels (SoD · Strangler-Fig) · data (Data Architecture domain) · "
            "integration (ESB/iPaaS · transitional) · compliance (SoR regulatorio). "
            "Estructura canónica: systems/{togaf_type}/{sistema}/ con subdirs "
            "source/digital-brain/knowledge-base/generators/dt/portal/old/CLAUDE.md. "
            "Metadata TOGAF obligatoria en cada CLAUDE.md: togaf_type · togaf_state · "
            "togaf_system_of · togaf_abb · bian_domains."
        ),
        "alternatives": (
            "1. Clasificación por wave de migración — descartada: la wave es "
            "operativa (cuándo migrar), no estructural (qué es el sistema). "
            "2. Clasificación plana sin subcarpetas — descartada: con 49+ dominios "
            "y múltiples sistemas, la navegación sin taxonomía es inviable."
        ),
        "consequences": (
            "Positivas: federación brain-brain vía SQLite ATTACH · vocabulario "
            "compartido entre sistemas · Reglas B1-B12 aplicables uniformemente. "
            "Negativas: requiere migration de estructuras existentes cuando se "
            "descubren sistemas nuevos · TOGAF_type puede ser ambiguo para sistemas "
            "híbridos (ej. Control-M es integration pero tiene características de core)."
        ),
        "status": "accepted",
        "domain": "all",
        "related_sps": json.dumps([]),
    },
    {
        "decision_id": "ADR-SPE-AM-009",
        "date": "2026-08-07",
        "context": (
            "Las 8,955 reglas extraídas del sistema Informix necesitan un esquema "
            "de IDs estable y business_names de calidad que permitan trazabilidad "
            "entre el código fuente SPL y los artefactos de migración. "
            "El ID debe ser único, derivable mecánicamente y persistir entre "
            "reconstrucciones del brain."
        ),
        "decision": (
            "Formato canónico de ID: {PREFIX}-{db}-{sp_short}-{line} "
            "donde PREFIX = clase (NEGOCIO/INFRA/ENSAMBLAJE/PRESENTACION), "
            "db = base de datos Informix, sp_short = primeros 20 chars del nombre SP, "
            "line = número de línea en el fuente. "
            "Dos capas de enriquecimiento: "
            "(1) Sintáctica — heurísticas SPL (prefijo húngaro, señales RAISE EXCEPTION, "
            "fórmulas con MONEY/DIV/ROUND). "
            "(2) Semántica — síntesis LLM leyendo el SP completo (ADR-SPE-AM-010). "
            "Quality gate: COUNT(*) WHERE business_name IS NULL = 0 antes de entregar catálogo."
        ),
        "alternatives": (
            "1. UUID aleatorio — descartado: no derivable, rompe trazabilidad en "
            "reconstrucciones del brain. "
            "2. Solo nombre del SP como ID — descartado: un SP puede tener múltiples "
            "reglas en líneas distintas; no es único."
        ),
        "consequences": (
            "Positivas: IDs estables entre rebuilds · trazabilidad directa a línea "
            "de código fuente · quality gate bloquea catálogos incompletos. "
            "Negativas: sp_short de 20 chars puede colisionar entre SPs con nombres "
            "similares (mitigado con db prefix) · IDs no son legibles para el negocio "
            "(son técnicos, el business_name es la cara legible)."
        ),
        "status": "accepted",
        "domain": "all",
        "related_sps": json.dumps([]),
    },
    {
        "decision_id": "ADR-SPE-AM-010",
        "date": "2026-08-12",
        "context": (
            "La síntesis de business_name para 8,955 reglas requiere leer el código "
            "fuente completo del SP — no el fragmento de la regla. Las heurísticas "
            "sintácticas (ADR-SPE-AM-009 Capa 1) producen nombres con errores factuales "
            "cuando operan sobre fragmentos truncados (ej. código 439 ≠ crédito cancelado, "
            "ctemoral ≠ solo 'temporal' — es 'persona moral'). "
            "Se necesita una política que garantice calidad semántica a escala."
        ),
        "decision": (
            "Síntesis LLM como generación primaria (no enriquecimiento) del business_name. "
            "Protocolo: extractor emite business_name = null · agente Lee el SP completo "
            "via Read tool (nunca fragmento) · produce nombre en lenguaje de negocio "
            "bancario MX · result se graba como rule_enrichment_log.method='llm_synthesis_source_read'. "
            "Pattern scatter-gather: lotes de 70-80 SPs por agente (respeta contexto LLM) · "
            "resultado JSON {id: name} · colectar + dedup + guardia anti-genérico · "
            "apply como source_read en brain.db. "
            "Fuente de verdad: brain.db (no business-rules-v3.json — ese es un output derivado)."
        ),
        "alternatives": (
            "1. Heurísticas sintácticas puras — descartado: tasa de errores factuales "
            "inaceptable en contexto regulatorio (CNBV requiere descripción precisa "
            "de reglas de negocio en auditorías). "
            "2. Síntesis sobre fragmento de regla — descartado: fragmento truncado "
            "pierde contexto del SP y produce nombres incorrectos (evidencia: "
            "'ctemoral' interpretado como 'temporal' en lugar de 'persona moral')."
        ),
        "consequences": (
            "Positivas: business_names precisos y verificables contra código fuente · "
            "calidad audit-ready para CNBV · eliminación de nombres genéricos y "
            "nombres con tokens de código (bdixxx, sp_xxx). "
            "Negativas: costo de API Claude por cada lote de síntesis · "
            "requiere re-síntesis cuando cambia el código fuente · "
            "latencia: ~2-3 min por lote de 70-80 SPs (aceptable para DISCOVER, "
            "no para pipelines de CI/CD en tiempo real)."
        ),
        "status": "accepted",
        "domain": "all",
        "related_sps": json.dumps([]),
    },
]


def seed(db: sqlite3.Connection) -> None:
    if DRY_RUN:
        print(f"\n[DRY-RUN] {len(ADRS)} ADRs a insertar en decisions_history:\n")
        for adr in ADRS:
            print(f"  {adr['decision_id']:<22} [{adr['status']:<16}] {adr['date']}  dominio={adr['domain']}")
        return

    db.execute("DELETE FROM decisions_history WHERE decision_id LIKE 'ADR-SPE-AM-%'")
    db.executemany(
        "INSERT INTO decisions_history "
        "(decision_id, date, context, decision, alternatives, consequences, status, domain, related_sps) "
        "VALUES (:decision_id, :date, :context, :decision, :alternatives, :consequences, :status, :domain, :related_sps)",
        ADRS,
    )
    db.commit()
    print(f"\ndecisions_history: {len(ADRS)} ADRs insertados ({date.today()})")


def main() -> None:
    if not BRAIN.exists():
        print(f"ERROR: brain.db no encontrado en {BRAIN}")
        sys.exit(1)

    with sqlite3.connect(BRAIN) as db:
        db.row_factory = sqlite3.Row

        print(f"Sembrando {len(ADRS)} ADRs en decisions_history...")
        seed(db)

        if not DRY_RUN:
            print("\nEstado por status:")
            cur = db.execute(
                "SELECT status, COUNT(*) n FROM decisions_history GROUP BY status ORDER BY n DESC"
            )
            for r in cur:
                print(f"  {r['status']:<20} {r['n']}")

            print("\nknowledge_completeness:")
            cur = db.execute("SELECT dimension, total_items, fill_pct FROM knowledge_completeness")
            for r in cur:
                icon = "✅" if r["fill_pct"] == 100 else ("⚠️" if r["fill_pct"] > 0 else "❌")
                print(f"  {icon} {r['dimension']:<15} {r['total_items']:>6} ítems  {r['fill_pct']:.0f}%")


if __name__ == "__main__":
    main()