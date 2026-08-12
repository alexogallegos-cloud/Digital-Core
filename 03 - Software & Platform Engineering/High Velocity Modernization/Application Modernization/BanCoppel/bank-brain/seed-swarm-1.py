"""seed-swarm-1.py — Grupo 1 swarm extracción estratégica Bank Brain BanCoppel

Documentos procesados (9 minutas, 20-Mar-2026 al 29-Abr-2026):
  - 20-Mar: Reorganización Unity + roles Kreios/ACN (Plan Director)
  - 06-Abr: Workshop DRP Transact + Cobranza + Kick-Off aceleración
  - 10-Abr: Revisión roadmap actualizado (Escenario 2 adoptado)
  - 15-Abr: Migración/Atlas follow-up (Pablo + Christian Zazueta)
  - 16-Abr: Business Case update — 23 aplicativos + costos reales
  - 24-Abr: Revisión roadmap Transact (productos, pruebas, sponsors)
  - 28-Abr: Business North Star 2030 (Teresa + Joaquín + José)
  - 28-Abr: Alineación interfaces batch SmartVista (Oscar + Eduardo)
  - 29-Abr: Alineación semanal Apolo (roadmap integrado + R4)
"""
import sqlite3
from pathlib import Path

DB = Path(__file__).parent / "bank-brain.db"

DECISIONS = [
    # (id, date, topic, decision_text, driver_id_or_None, confidence)
    # topic ∈ {apolo, smartvista, transact, atlas, pisa, arquitectura, seguridad, gobierno, cronograma, datos, integracion, testing, regulatorio, general}
    # confidence ∈ {high, medium, low}

    # === 10-Abr-2026: Revisión roadmap ===
    (
        "SW1-DEC-0001", "2026-04-10", "cronograma",
        "Escenario 2 del roadmap adoptado como base de trabajo por ser opción de riesgo intermedio; "
        "Escenario 1 descartado porque requería detener upgrades y prioridades ya definidas en el último PI Planning",
        "juan-manuel", "high"
    ),
    (
        "SW1-DEC-0002", "2026-04-10", "transact",
        "Frente de depósitos/cuentas priorizado sobre crédito por concentrar 80-90% del ingreso del negocio; "
        "el producto prioritario de cuentas (N4/Cuenta Efectiva Digital) es el ancla del roadmap",
        "juan-manuel", "high"
    ),
    (
        "SW1-DEC-0003", "2026-04-10", "apolo",
        "Crédito arranca como MVP acotado: un producto simple no garantizado (unsecured consumer credit), "
        "un solo canal inicial (promotoría/office), sin migración en primera etapa; postventa permanece en esquema legado",
        None, "high"
    ),
    (
        "SW1-DEC-0004", "2026-04-10", "smartvista",
        "Capacidad de tarjeta de débito incorporada como dependencia crítica explícita del roadmap; "
        "requerida tanto para go-live de cuentas como para migración completa del portafolio; debe priorizarse en siguiente PI Planning",
        None, "high"
    ),
    (
        "SW1-DEC-0005", "2026-04-10", "transact",
        "Principio de mínima personalización en Transact establecido como base de solución; "
        "ya existen 18 deltas identificados (configuraciones, integraciones y customizaciones), estimados y en proceso de certificación",
        None, "high"
    ),

    # === 16-Abr-2026: Business Case ===
    (
        "SW1-DEC-0006", "2026-04-16", "general",
        "Alcance del business case reducido a 23 aplicativos prioritarios seleccionados por Juan Manuel; "
        "todos cuentan con evaluación APO previa que determina si migrar, mantener o decomisionar",
        "juan-manuel", "high"
    ),
    (
        "SW1-DEC-0007", "2026-04-16", "general",
        "Costos reales de facturas adoptados como base del business case; presupuestos y data collection "
        "descartados como fuente primaria por inconsistencias significativas entre fuentes",
        None, "high"
    ),
    (
        "SW1-DEC-0008", "2026-04-16", "pisa",
        "Decomisionamiento real será menor al proyectado inicialmente; la mayoría de los 23 aplicativos "
        "depende de OLTP (PISA), lo que limita el desacople inmediato y genera nuevos proyectos de alto esfuerzo",
        None, "high"
    ),
    (
        "SW1-DEC-0009", "2026-04-16", "general",
        "Proyección de costos futura (2027-2030) se construirá combinando histórico reciente, inflación "
        "y conocimiento actual del programa; proyección original de 7 años (~120-140B MXN) ya no refleja la realidad",
        None, "medium"
    ),

    # === 15-Abr-2026: Migración/Atlas follow-up ===
    (
        "SW1-DEC-0010", "2026-04-15", "atlas",
        "Paso de simulacros integrales de ETL (MOX/drive runs) añadido al proceso de migración antes de UAT; "
        "actualmente no existe este paso: los datos pasan directamente de pruebas por stream a UAT",
        "pablo-lorenzo", "high"
    ),
    (
        "SW1-DEC-0011", "2026-04-15", "atlas",
        "Dress Rehearsals (2-3 por ola) incorporados al marco operativo de releases después de UAT y antes de "
        "producción para afinar el runbook; el plan anterior no los incluía y pasaba directamente a producción",
        "pablo-lorenzo", "high"
    ),
    (
        "SW1-DEC-0012", "2026-04-15", "atlas",
        "Atlas planificado a 2 años en 4 fases de 6 meses (Crawl→Walk→Run→Fly): "
        "Crawl termina ago-2026 con MDM golden record de clientes en GCP; "
        "Run integra Grupo Copel + Adobe CDP + PISA migration (25M+ clientes); Fly = handover a operaciones",
        None, "high"
    ),
    (
        "SW1-DEC-0013", "2026-04-15", "datos",
        "Migración a producción no se realizará hasta que UAT esté completo; este esfuerzo es el primero "
        "de migración en la institución y no existe precedente interno",
        None, "high"
    ),

    # === 20-Mar-2026: Reorganización Unity ===
    (
        "SW1-DEC-0014", "2026-03-20", "gobierno",
        "Accenture asumirá el gobierno de Unity tras el diagnóstico de 6 semanas (Plan Director), "
        "liderando implementación y coordinación con la operación AMS/IMS por los próximos tres años a partir de la semana 7",
        "juan-manuel", "high"
    ),
    (
        "SW1-DEC-0015", "2026-03-20", "gobierno",
        "Kreios ejecuta Change Management con metodología Crocker (organización no tiene madurez para ADCAR); "
        "Accenture evalúa Change Management a nivel estratégico; roles son complementarios, no duplicados",
        None, "medium"
    ),

    # === 24-Abr-2026: Revisión roadmap Transact ===
    (
        "SW1-DEC-0016", "2026-04-24", "smartvista",
        "SmartVista no tiene nada planificado para tarjeta de débito en su backlog; "
        "gap crítico que bloquea el roadmap de cuentas y debe ser resuelto con urgencia",
        None, "high"
    ),
    (
        "SW1-DEC-0017", "2026-04-24", "transact",
        "Alcance de Transact hasta 2028: Cuentas Efectivas Digitales N2 y N4 + Cuenta Nómina N4 + Inversiones/Pagarés + Préstamo Simple; "
        "Préstamo Revolvente, Nómina y Anticipo Nómina explícitamente excluidos de este horizonte",
        None, "high"
    ),
    (
        "SW1-DEC-0018", "2026-04-24", "transact",
        "Onboarding de los tres productos de captación (N2, N4, Nómina) será exclusivamente a través de promotoría (Apolo); "
        "Go-Live de captación programado para Q1 2028",
        None, "high"
    ),
    (
        "SW1-DEC-0019", "2026-04-24", "gobierno",
        "Sergio del Valle identificado como nuevo sponsor ejecutivo de alto nivel reemplazando a Stephanie Ley; "
        "junto a Juan Manuel toma decisiones ejecutivas incluyendo priorización del Préstamo Simple",
        None, "high"
    ),
    (
        "SW1-DEC-0020", "2026-04-24", "testing",
        "Plan integral de pruebas estandarizado: tres ciclos de 1 mes para SIT y 3 meses para UAT "
        "con simulacros de producción incluidos; SIT/UAT se agrupan por funcionalidades relacionadas en un solo ciclo",
        None, "high"
    ),

    # === 28-Abr-2026: Business North Star ===
    (
        "SW1-DEC-0021", "2026-04-28", "general",
        "Meta financiera 2030 está en revisión metodológica de costos; cifra previamente socializada de 30,000M MXN "
        "no debe tratarse como definitiva ni comunicarse como cerrada; proyección puede ajustarse sacrificando eficiencia en corto plazo",
        None, "high"
    ),
    (
        "SW1-DEC-0022", "2026-04-28", "gobierno",
        "Unity enmarcado como habilitador relevante pero no el único habilitador de la estrategia 2030; "
        "el deliverable se concentrará en el North Star de Unity, no en gobernar toda la estrategia corporativa",
        None, "high"
    ),
    (
        "SW1-DEC-0023", "2026-04-28", "general",
        "Lenguaje de canales corregido en toda la narrativa: sin 'renovación total' de app, sucursal, CAT o promotoría; "
        "el mensaje correcto es mejoras incrementales, digitalización y cambios de proceso",
        None, "high"
    ),
    (
        "SW1-DEC-0024", "2026-04-28", "general",
        "Transformación de productos leída como digitalización + personalización (tasas diferenciadas, reglas adaptadas, experiencias por perfil), "
        "no como lanzamiento neto de productos nuevos; la mayor parte de las capacidades ya existen en legado",
        None, "high"
    ),
    (
        "SW1-DEC-0025", "2026-04-28", "pisa",
        "Hasta mediados de 2027 la mayor parte del valor seguirá dependiendo del BAU y del legado; "
        "el impacto más fuerte de Unity se materializará cuando las nuevas plataformas estén operando y liberen capacidades incrementales",
        None, "high"
    ),

    # === 28-Abr-2026: Alineación SmartVista interfaces ===
    (
        "SW1-DEC-0026", "2026-04-28", "integracion",
        "8 interfaces batch identificadas para SmartVista; 3 ya en ambiente productivo; "
        "5 restantes en dev pendientes de alineación con equipo de tarjeta de crédito (José Jaimes); "
        "el equipo también desarrolla APIs no-standard para CBS (disposiciones, pagos, notificaciones de cobranza)",
        None, "high"
    ),
    (
        "SW1-DEC-0027", "2026-04-28", "integracion",
        "Interfaces batch de SmartVista reciben cambios vía email desde el equipo de tarjetas, "
        "luego se crean tickets Jira en dev; incidentes en producción siempre tienen máxima prioridad",
        None, "medium"
    ),

    # === 29-Abr-2026: Alineación semanal Apolo ===
    (
        "SW1-DEC-0028", "2026-04-29", "apolo",
        "N4 Cuenta Efectiva Digital conecta onboarding inicialmente al producto legacy; "
        "una vez que Transact finalice el desarrollo de cuentas, Apolo reapuntará a Transact (dos fases de integración)",
        None, "high"
    ),
    (
        "SW1-DEC-0029", "2026-04-29", "apolo",
        "Apollo R4 = 11 historias de usuario incrementales, ya planificadas y estimadas; "
        "necesarias para salida a mercado abierto en diciembre 2026; Apollo App debe estar lista para R4 como fecha límite de negocio",
        None, "high"
    ),
    (
        "SW1-DEC-0030", "2026-04-29", "cronograma",
        "Roadmap integrado solo refleja trabajo con plan formal definido; "
        "iniciativas futuras sin planificación (Google Pay, Agenda de Deditos) se incluyen explícitamente en sección de supuestos",
        None, "medium"
    ),

    # === 6-Abr-2026: Kick-Off + DRP + Cobranza ===
    (
        "SW1-DEC-0031", "2026-04-06", "gobierno",
        "Programa Unity aprobado en mayo 2023; incidente de ciberseguridad del 14-abr-2024 forzó 7 meses en Culiacán "
        "y disrumpió el plan original; 80% de iniciativas tecnológicas para meta 2030 son Unity-relacionadas (~40% de ingresos del banco)",
        None, "high"
    ),
    (
        "SW1-DEC-0032", "2026-04-06", "gobierno",
        "E&Y cubre el ecosistema Transact (core bancario); Accenture lidera la visión de portafolio del Plan Director; "
        "división de alcances clara para evitar solapamiento entre consultoras",
        None, "high"
    ),
    (
        "SW1-DEC-0033", "2026-04-06", "seguridad",
        "DRP de Transact acotado inicialmente a capa aplicativa (backup and restore) en AWS (Virginia y Oregón); "
        "contrato Temenos no incluye implementación de DRP; DRP con backup/restore cumple auditoría pero RTO 24-72h no es operativamente aceptable",
        None, "high"
    ),
    (
        "SW1-DEC-0034", "2026-04-06", "seguridad",
        "Juan Manuel exigió inicio inmediato en ambientes no productivos de Transact para DRP; "
        "rechazó postergación a Q1 2027 como pretextos; el banco lleva 5 años sin DRP en producción y una caída sería catastrófica",
        "juan-manuel", "high"
    ),
    (
        "SW1-DEC-0035", "2026-04-06", "seguridad",
        "DRP de CSE (Crédito Simple Empresarial) debe incluir Unity Consumo; "
        "CSE solo no justifica el esfuerzo por su bajo volumen; se busca apoyo externo (Accenture/EY) para liderazgo integral del DRP",
        "juan-manuel", "high"
    ),
    (
        "SW1-DEC-0036", "2026-04-06", "apolo",
        "Cobranza no forma parte directa del programa Unity pero es módulo estratégico crítico; "
        "Smart Vista gestiona cobranza de TDC; Transact gestiona cobranza de préstamos personales; Apolo gestiona contactabilidad",
        None, "high"
    ),
]

POSITIONS = [
    # (stakeholder_id, topic, stance_text, sentiment, date)
    # sentiment ∈ {supportive, concerned, blocking, neutral}

    # juan-manuel
    (
        "juan-manuel", "cronograma",
        "Puso sobre la mesa la capacidad real requerida para el Escenario 1 y concluyó que implicaría detener upgrades; "
        "su análisis llevó a la adopción del Escenario 2 como base del roadmap",
        "supportive", "2026-04-10"
    ),
    (
        "juan-manuel", "seguridad",
        "Rechazó la postergación del DRP de Transact como 'puros pretextos'; exigió inicio inmediato en ambientes no productivos; "
        "señaló que el banco lleva 5 años sin DRP en producción y que una caída podría ser catastrófica",
        "blocking", "2026-04-06"
    ),
    (
        "juan-manuel", "gobierno",
        "Identificó la ausencia de un responsable único de DRP end-to-end como brecha crítica de gobernanza; "
        "responsabilidad actualmente segmentada entre legado y Transact sin un dueño integral",
        "concerned", "2026-04-06"
    ),
    (
        "juan-manuel", "general",
        "Solicitó urgentemente un plan integral end-to-end con cronograma para la junta directiva del 24 de abril; "
        "los planes por stream existentes carecen de capa de integración y son insuficientes",
        "concerned", "2026-04-15"
    ),

    # rodrigo (Kennedy Ramirez — Estrategia/Negocio)
    (
        "rodrigo", "gobierno",
        "El personal está 'harto' de ser entrevistado; demanda acciones concretas, no más diagnósticos ni assessments; "
        "enfatizó que la documentación existente debe usarse para evitar duplicar esfuerzos",
        "blocking", "2026-03-20"
    ),
    (
        "rodrigo", "cronograma",
        "Confirmó que el Business Case de Apolo contempla diferentes incrementos hasta 2028; "
        "respalda que el roadmap refleje el alcance de Apolo en ese horizonte",
        "supportive", "2026-04-29"
    ),

    # arturo-perez (Líder Legacy/PISA)
    (
        "arturo-perez", "seguridad",
        "Presente en el workshop de DRP como responsable actual del DRP del legado; "
        "la segmentación del DRP entre legado (su cargo) y Transact (nuevo) es la causa raíz de la brecha de gobernanza identificada",
        "neutral", "2026-04-06"
    ),

    # arcadio (Líder Arquitectura)
    (
        "arcadio", "arquitectura",
        "Solicitó al equipo Accenture buscar sinergias con las directrices internas de arquitectura para acelerar necesidades "
        "de corto y mediano plazo y asegurar que mejoras convivan con Unity sin replicar ni rehacer esfuerzos",
        "neutral", "2026-04-06"
    ),

    # alejandro-gallegos (Lead ACN)
    (
        "alejandro-gallegos", "seguridad",
        "Planteó la necesidad de una visión holística del DRP con modelo operativo failover/failback; "
        "señaló que la suma de SLAs individuales de capas (AWS, plataformas) no garantiza el RTO/RPO del sistema completo",
        "concerned", "2026-04-06"
    ),
    (
        "alejandro-gallegos", "gobierno",
        "Identificado como conector entre delivery Accenture y operaciones AMS/IMS del banco; "
        "rol de puente entre Unity y la operación en producción",
        "neutral", "2026-04-06"
    ),

    # pablo-lorenzo (Director ACN)
    (
        "pablo-lorenzo", "testing",
        "Propuso activamente la adición de dry runs (MOX) y dress rehearsals al marco de migración; "
        "elementos que no existían en el plan original; impulsor de calidad y robustez del proceso de migración",
        "supportive", "2026-04-15"
    ),
    (
        "pablo-lorenzo", "cronograma",
        "Trabajó urgentemente en plan integrado para junta directiva del 24 de abril; "
        "consolidó insumos de Transact, Apolo, SmartVista y legado; propuso fases más conservadoras para SIT/UAT/NFT",
        "supportive", "2026-04-15"
    ),

    # lukasz-pietrzyk (Global Architect ACN)
    (
        "lukasz-pietrzyk", "arquitectura",
        "Líder de la estrategia tecnológica en el diligence de 6 semanas; presente en alineaciones clave de SmartVista y Apolo; "
        "impulsor de la arquitectura empresarial bajo el marco Unity",
        "supportive", "2026-04-28"
    ),

    # brenda (Gestión Proveedores)
    (
        "brenda", "general",
        "Se comprometió a compartir la proyección original de 7 años (2022-2023), base detallada de contratos "
        "y facturas de 2025, e identificación de proveedores clave para validar el business case de Unity",
        "supportive", "2026-04-16"
    ),

    # karina-zepeda (ACN Delivery)
    (
        "karina-zepeda", "gobierno",
        "Designada para la reunión de pre-alineación con Kreios junto a Joaquín para definir roles y estrategia "
        "de Change Management antes de presentar el plan a negocio (Rodrigo + Teresa)",
        "neutral", "2026-03-20"
    ),

    # salomon-monroy (ACN Delivery)
    (
        "salomon-monroy", "gobierno",
        "Identificado como líder del programa Accenture para Unity en el kick-off; "
        "presente como responsable de delivery del equipo ACN",
        "neutral", "2026-04-06"
    ),

    # gabriela-maximiliano (ACN Delivery)
    (
        "gabriela-maximiliano", "gobierno",
        "Identificada como punto de conexión entre Unity y operaciones AMS/IMS en la estructura del programa; "
        "rol crítico para continuidad operativa durante la transición",
        "neutral", "2026-04-06"
    ),

    # carlos-bc (Ejecutivo Steering)
    (
        "carlos-bc", "gobierno",
        "El comité quincenal con Carlos es el punto formal de presentación de resultados del diligence Accenture; "
        "implica peso ejecutivo en el proceso de validación de avances del Plan Director",
        "neutral", "2026-04-06"
    ),

    # luis-barragan (Director Unity BCP)
    (
        "luis-barragan", "cronograma",
        "Director Unity BCP presente en la estructura del programa; "
        "sus compromisos de capacidad de equipo son un supuesto no cerrado que condiciona la viabilidad del roadmap",
        "neutral", "2026-04-10"
    ),
]

OPEN_ITEMS = [
    # (id, date, item_text, owner_id_or_None, priority, systems_json_array)
    # priority ∈ {high, medium, low}

    # === 10-Abr-2026: Roadmap ===
    (
        "SW1-OI-0001", "2026-04-10",
        "Consolidar y unificar referencias de fechas del roadmap: existen ambigüedades entre cierre 2027, 1T28 y 4T28 "
        "en distintos documentos y conversaciones; la versión final debe aclarar y unificar la línea base",
        None, "high", '["cronograma","transact","apolo"]'
    ),
    (
        "SW1-OI-0002", "2026-04-10",
        "Confirmar nombre exacto del producto prioritario de cuentas/depósitos: "
        "mencionado inconsistentemente como N4 y Cuenta Efectiva Digital en la misma reunión",
        None, "medium", '["transact"]'
    ),
    (
        "SW1-OI-0003", "2026-04-10",
        "Construir inventario consolidado de APIs y servicios actualmente expuestos a canales para crédito y cuentas "
        "(apertura/cierre, cobranza, pagos entrantes/salientes); brecha crítica identificada para validar el roadmap",
        None, "high", '["integracion","apolo","transact"]'
    ),
    (
        "SW1-OI-0004", "2026-04-10",
        "Desarrollar con negocio el proceso de originación en Apolo para cuentas y crédito; "
        "actualmente no existe en Apollo y es un supuesto crítico no resuelto del roadmap",
        None, "high", '["apolo"]'
    ),
    (
        "SW1-OI-0005", "2026-04-10",
        "Obtener documentación técnica detallada de arquitectura actual de Transact: "
        "relación con TDH, interfaces actuales, integración DWH/General Ledger, stack tecnológico, sizing, módulos activados y evolución por hitos",
        None, "high", '["transact","arquitectura"]'
    ),
    (
        "SW1-OI-0006", "2026-04-10",
        "Levantar volumetrías reales necesarias para estrategia de migración: "
        "número de cuentas, número de clientes, saldos y demás datos de capacidad para Atlas",
        None, "high", '["datos","atlas"]'
    ),
    (
        "SW1-OI-0007", "2026-04-10",
        "Obtener compromisos cerrados de fechas y capacidad de los equipos dependientes del roadmap: "
        "Apollo, SmartVista, Canales, Testing y Migración; actualmente ninguno tiene compromiso formal",
        None, "high", '["cronograma","apolo","smartvista"]'
    ),

    # === 16-Abr-2026: Business Case ===
    (
        "SW1-OI-0008", "2026-04-16",
        "Resolver atribución de costos IBM: actualmente una sola factura agrupa múltiples sistemas; "
        "necesita mapeo aplicativo→contrato específico para el business case; requiere validación con equipos técnicos",
        "brenda", "high", '["general"]'
    ),
    (
        "SW1-OI-0009", "2026-04-16",
        "Reconstruir proyección de costos 2027-2030; "
        "la proyección original de 7 años (~120-140B MXN de 2022-2023) ya no refleja la realidad post-Temenos y cambios de metodología de costos",
        None, "high", '["general","cronograma"]'
    ),

    # === 15-Abr-2026: Atlas/Migración ===
    (
        "SW1-OI-0010", "2026-04-15",
        "Generar plan detallado de Atlas junto con equipo de Arquitectura (objetivo: entre 15-16 de abril); "
        "sincronizar fechas del plan detallado Atlas con el plan integral end-to-end de Unity",
        None, "high", '["atlas","arquitectura"]'
    ),

    # === 24-Abr-2026: Roadmap Transact ===
    (
        "SW1-OI-0011", "2026-04-24",
        "Resolver gap crítico de SmartVista: no tiene nada planificado para tarjeta de débito en su backlog; "
        "esta capacidad es dependencia crítica del roadmap de cuentas y debe incorporarse en siguiente PI Planning",
        None, "high", '["smartvista","cronograma"]'
    ),
    (
        "SW1-OI-0012", "2026-04-24",
        "Agendar sesión ejecutiva con Sergio del Valle para presentar roadmap integral y decidir fecha de inicio "
        "del Préstamo Simple (Q4-2026 vs Q2-2027); decisión requiere análisis de capacidad",
        "pablo-lorenzo", "high", '["transact","cronograma","gobierno"]'
    ),
    (
        "SW1-OI-0013", "2026-04-24",
        "Definir integración de Western Union con Transact; actualmente Western Union usa el core legado y debe "
        "activar nueva integración para habilitar Cuenta Efectiva Digital N4 (dependency bloqueante)",
        None, "high", '["transact","integracion"]'
    ),
    (
        "SW1-OI-0014", "2026-04-24",
        "Proveer listado detallado de dependencias críticas del legado incluyendo Western Union, "
        "recargas de tiempo aire y pago de servicios (Gloria Coll, antes del siguiente seguimiento del miércoles)",
        None, "high", '["transact","integracion","pisa"]'
    ),

    # === 28-Abr-2026: Business North Star ===
    (
        "SW1-OI-0015", "2026-04-28",
        "Seguros aún está definiendo el detalle de su estrategia; "
        "no puede fijarse en la narrativa Unity hasta tener claridad suficiente; requiere seguimiento específico",
        None, "medium", '["general"]'
    ),
    (
        "SW1-OI-0016", "2026-04-28",
        "Revisar con Paola Mercado si existe material avanzado sobre remesas; "
        "clarificar vínculo de remesas con captación (saldo entrante) y su alcance dentro de Unity",
        None, "medium", '["integracion","general"]'
    ),
    (
        "SW1-OI-0017", "2026-04-28",
        "Clarificar estado de iniciativa CRM en CAT/call center; reportada como lenta por personas clave; "
        "evaluar si representa una renovación del canal o solo una herramienta de soporte",
        None, "medium", '["general"]'
    ),
    (
        "SW1-OI-0018", "2026-04-28",
        "Definir alcance de impacto Unity en tienda/promotoría; Teresa González es enfática en que no hay impacto "
        "directo de Unity ahí y hay definiciones no cerradas (posible front único); requiere decisión ejecutiva",
        None, "medium", '["apolo","gobierno"]'
    ),

    # === 28-Abr-2026: SmartVista interfaces ===
    (
        "SW1-OI-0019", "2026-04-28",
        "5 de las 8 interfaces batch de SmartVista pendientes de liberación en dev; "
        "requieren alineación con equipo de tarjeta de crédito (José Jaimes) para definir prioridad y timing",
        None, "medium", '["smartvista","integracion"]'
    ),
    (
        "SW1-OI-0020", "2026-04-28",
        "Interfaces inversas de conciliación SmartVista (2 interfaces) aún no están en producción; "
        "necesarias para proveer archivos de conciliación a SmartVista desde la operación actual",
        None, "high", '["smartvista","integracion"]'
    ),
    (
        "SW1-OI-0021", "2026-04-28",
        "Compartir fichero Excel inventario de interfaces SmartVista (prioridad, IDs, objetivos, funcionalidades, docs) "
        "y archivos DrawIO originales de flujos para visualización detallada (Oscar Melo + Eduardo Ponce)",
        None, "medium", '["smartvista","integracion"]'
    ),

    # === 29-Abr-2026: Apolo ===
    (
        "SW1-OI-0022", "2026-04-29",
        "Actualizar carpeta normativa CNBV con información de R4 de Apolo; "
        "actualmente solo cubre hasta R3; es requerimiento necesario para la salida a mercado abierto de diciembre 2026",
        None, "high", '["apolo","regulatorio"]'
    ),
    (
        "SW1-OI-0023", "2026-04-29",
        "Evaluar y resolver conflicto de capacidad en SmartVista: el mismo equipo desarrolla TDC R4 "
        "y el impacto de ORE (OFI); riesgo de cuello de botella en fechas críticas del cronograma",
        None, "high", '["smartvista","cronograma"]'
    ),

    # === 6-Abr-2026: DRP + Cobranza ===
    (
        "SW1-OI-0024", "2026-04-06",
        "Corregir tres gaps de replicación identificados en DRP Transact: "
        "falta replicación de file systems entre regiones (Virginia-Oregón), sin replicación de ccrs (K8s), "
        "Redis con problemas en ambas regiones",
        None, "high", '["transact","seguridad"]'
    ),
    (
        "SW1-OI-0025", "2026-04-06",
        "Designar responsable único de DRP end-to-end en el banco; "
        "la responsabilidad actual está segmentada entre legado (Arturo/Tavo) y Transact sin un dueño integral; "
        "contactar oficina de riesgos y Gerente Nacional de DRPs",
        None, "high", '["seguridad","gobierno"]'
    ),
    (
        "SW1-OI-0026", "2026-04-06",
        "Completar Documento de Especificación Funcional (DEF) de Cobranza con requerimientos detallados "
        "para SmartVista y Transact, incluyendo planes de segunda oportunidad, digitalización y cobranza direccionada",
        None, "medium", '["smartvista","transact","apolo"]'
    ),

    # === 20-Mar-2026: Kreios ===
    (
        "SW1-OI-0027", "2026-03-20",
        "Realizar reunión de pre-alineación entre ACN (Joaquín + Karina) y Kreios para definir roles y estrategia "
        "de Change Management antes de la sesión con negocio (Rodrigo + Teresa González); evitar imagen de desalineación",
        "karina-zepeda", "high", '["gobierno"]'
    ),
]


def run():
    db = sqlite3.connect(str(DB))
    db.execute("PRAGMA foreign_keys=ON")
    n_dec = n_pos = n_oi = 0

    for row in DECISIONS:
        try:
            db.execute(
                "INSERT OR IGNORE INTO decisions "
                "(id,date,topic,decision,driver_id,systems,doc_id,confidence) "
                "VALUES (?,?,?,?,?,?,NULL,?)",
                (row[0], row[1], row[2], row[3], row[4], f'["{row[2]}"]', row[5])
            )
            if db.execute("SELECT changes()").fetchone()[0]:
                n_dec += 1
        except Exception as e:
            print(f"  [WARN] Decision {row[0]}: {e}")

    for row in POSITIONS:
        try:
            db.execute(
                "INSERT INTO positions "
                "(stakeholder_id,topic,stance,quote,date,doc_id,sentiment) "
                "VALUES (?,?,?,?,?,NULL,?)",
                (row[0], row[1], row[2], row[2][:100], row[4], row[3])
            )
            n_pos += 1
        except Exception as e:
            print(f"  [WARN] Position {row[0]}/{row[1]}: {e}")

    for row in OPEN_ITEMS:
        try:
            db.execute(
                "INSERT OR IGNORE INTO open_items "
                "(id,date,item,owner_id,priority,systems,doc_id,status) "
                "VALUES (?,?,?,?,?,?,NULL,'open')",
                (row[0], row[1], row[2], row[3], row[4], row[5])
            )
            if db.execute("SELECT changes()").fetchone()[0]:
                n_oi += 1
        except Exception as e:
            print(f"  [WARN] OpenItem {row[0]}: {e}")

    db.commit()
    print(
        f"Swarm G1: {n_dec} decisiones · {n_pos} posiciones · {n_oi} open items insertados"
    )
    db.close()


if __name__ == "__main__":
    run()
