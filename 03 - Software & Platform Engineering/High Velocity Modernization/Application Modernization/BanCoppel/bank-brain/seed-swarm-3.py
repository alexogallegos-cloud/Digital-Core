"""seed-swarm-3.py — Grupo 3 swarm extracción estratégica Bank Brain BanCoppel

Fuentes procesadas (minutas abr-2026):
  - 14 Abr: Business Case Update + Portfolio Management
  - 17 Mar: Intro Daniel Ángeles / Plan Director ACN
  - 23 Abr: SmartVista Alineación Semanal (semana 4)
  - 25 Mar: Daniel Ángeles — mapa legacy, seguridad, sesiones
  - 28 Abr: Alineación Arquitectura Unity
  - 28 Abr: Testing — Estrategia y pain points
  - 30 Abr: SmartVista Alineación Semanal — Roadmap R4
"""
import sqlite3
from pathlib import Path

DB = Path(__file__).parent / "bank-brain.db"

# (id, date, topic, decision_text, driver_id_or_None, confidence)
DECISIONS = [
    # ── Business Case (14-Apr) ──────────────────────────────────────────────
    ("SW3-DEC-001", "2026-04-14", "business-case-estructura",
     "Business case de Unity se estructura en dos componentes: valor habilitado (incremento cartera/productos) y costos comparados Unity vs legacy. Rango bajo = eficiencia de costos; rango alto = impacto en negocio.",
     None, 0.95),

    ("SW3-DEC-002", "2026-04-14", "business-case-prioridad",
     "Prioridad inmediata del business case: cuantificación de costos y estrategia de decomisionamiento (rango bajo del caso), por presión directa de Juan Manuel.",
     "juan-manuel", 0.90),

    ("SW3-DEC-003", "2026-04-14", "business-case-supuestos",
     "El business case previo existe pero requiere validación y ajuste de supuestos. Se usarán costos históricos 2023-2025 y presupuesto 2026 como base para proyecciones hasta 2030.",
     None, 0.88),

    ("SW3-DEC-004", "2026-04-14", "decomisionamiento-apo",
     "El decomisionamiento de aplicaciones se modelará a partir del ejercicio APO (Application Portfolio Optimization), que clasificará aplicativos en: eliminar, mantener o transformar, con timeline de decomiso.",
     None, 0.92),

    ("SW3-DEC-005", "2026-04-14", "costos-oportunidad-bc",
     "Se incorporarán costos de oportunidad en el business case (escenarios de indisponibilidad: caídas SPEI, fallas en apps). Comparativa Legacy (8h recuperación) vs Unity (2h) para justificar inversión más allá de costos directos.",
     None, 0.85),

    ("SW3-DEC-006", "2026-04-14", "bc-coexistencia-legacy-unity",
     "El business case reflejará coexistencia real entre Unity y legacy. No se asumirá eliminación total inmediata de PISA; se incluirá el costo total de operación paralela.",
     None, 0.90),

    # ── Arquitectura y Legado (17-Mar) ──────────────────────────────────────
    ("SW3-DEC-007", "2026-03-17", "legacy-stop-desarrollo-pisa",
     "Decisión arquitectónica de dejar de desarrollar en PISA/Informix. T-24/Transact y demás sistemas Unity solo consultarán datos del core legacy sin invocar lógica SPL. La capa de interoperabilidad (Lambdas o WAS) desacopla los sistemas nuevos de los procedimientos almacenados.",
     "daniel-angeles", 0.88),

    ("SW3-DEC-008", "2026-03-17", "repositorio-datos-por-encima-vendors",
     "Se implementará un repositorio de datos por encima de los vendors para mantener el control de BanCoppel y permitir explotación analítica futura sin dependencia de proveedores individuales.",
     "lukasz-pietrzyk", 0.82),

    ("SW3-DEC-009", "2026-03-17", "plan-director-seis-semanas",
     "Accenture ejecutará plan director de seis semanas estructurado en dos bloques: Gobierno del programa (takeover/co-liderazgo a partir de semana 7) y Estrategia Tecnológica (6 diagnósticos: alineación, arquitectura, modelo operativo, roadmap, change management, business case).",
     "pablo-lorenzo", 0.95),

    # ── Gobernanza y contactos clave (25-Mar) ──────────────────────────────
    ("SW3-DEC-010", "2026-03-25", "arturo-perez-punto-contacto-legacy",
     "Arturo Pérez queda como referente principal y punto de contacto único del frente Legacy. Los responsables específicos por servicio participarán en conversaciones de detalle, pero Arturo coordina al grupo.",
     "daniel-angeles", 0.93),

    ("SW3-DEC-011", "2026-03-25", "seguridad-compliance-desde-arranque",
     "Arquitectura, OSI (Oficina de Seguridad de la Información) y seguridad/compliance deben integrarse desde el inicio del programa. Si se integran tarde pedirán contexto de todo lo trabajado y retrasarán el avance.",
     "daniel-angeles", 0.92),

    ("SW3-DEC-012", "2026-03-25", "erica-mata-referente-seguridad",
     "Erica Mata (CISO) queda como referente principal de seguridad. Frank Eduardo Ortiz Iglesias es posible contacto operativo de apoyo. Se añade caja transversal de compliance/seguridad a la estructura del proyecto.",
     "pablo-lorenzo", 0.90),

    # ── SmartVista alcance y TD (23-Abr) ────────────────────────────────────
    ("SW3-DEC-013", "2026-04-23", "smartvista-td-fuera-de-alcance",
     "Tarjeta de Débito (TD) NO está en el alcance actual de SmartVista/BPC. Tentativa de negocio: Q1 2027. TD pertenece al plan N4 de Apolo y al plan director; no está en el backlog de SmartVista, sin riesgos ni dependencias asociadas formalmente.",
     None, 0.95),

    ("SW3-DEC-014", "2026-04-23", "smartvista-inventario-interfaces-incompleto",
     "El inventario oficial de interfaces de SmartVista/TDC solo existe para releases R2 y R3. No existe inventario para R4. No hay un inventario común consolidado de todas las interfaces. Contacto para solicitar R2/R3: Juan Andrés Morín (Director Habilitadores, vertical ambientes).",
     None, 0.93),

    ("SW3-DEC-015", "2026-04-23", "smartvista-mapeo-capacidades-no-iniciado",
     "La construcción del diagrama empresarial de referencia y mapeo de capacidades funcionales de arquitectura para SmartVista no han comenzado formalmente. Se requiere sesión de seguimiento con arquitectura y líderes técnicos.",
     "lukasz-pietrzyk", 0.90),

    # ── Arquitectura Unity (28-Abr) ─────────────────────────────────────────
    ("SW3-DEC-016", "2026-04-28", "arquitectura-solucion-en-celulas",
     "Se incorporarán proactivamente arquitectos de solución (AS) internos en células de desarrollo para garantizar cumplimiento de estándares desde la fase de diseño. Ya se identificaron tres AS internos; además se cuenta con equipo IU para proyectos estratégicos como Unity y N4.",
     None, 0.88),

    ("SW3-DEC-017", "2026-04-28", "riesgo-salida-lenin-apolo",
     "La salida de Lenin (arquitecto de solución clave de Apolo) el 31 de mayo es riesgo crítico: no hay reemplazo formal identificado ni transferencia de conocimiento documentada. Solo pasó contexto a Joaquín Pichardo (ACN). Lukasz contactará a Miguel Bucio para definir acciones.",
     "lukasz-pietrzyk", 0.95),

    ("SW3-DEC-018", "2026-04-28", "arquitectura-valida-diseno-no-nfr",
     "Arquitectura valida diseño de solución, NO requerimientos no funcionales ni pruebas de rendimiento. Latencias de 5 segundos en APIs Apolo son problema de diseño de solución (SA). Arquitectura de Integración puede dar opciones solo si el AS realiza diagnóstico y presenta propuesta.",
     None, 0.90),

    ("SW3-DEC-019", "2026-04-28", "smartvista-modulos-contratados-sin-inventario",
     "Existe brecha de documentación sobre módulos de SmartVista contratados y habilitados. Equipo de arquitectura está en proceso de verificación; primeras versiones del análisis esperadas a mediados de mayo 2026.",
     None, 0.88),

    ("SW3-DEC-020", "2026-04-28", "guias-cache-api",
     "Se desarrollarán directrices y recomendaciones sobre cuándo usar caché en APIs, fundamentales para optimizar tiempos y reducir consultas en el escenario multi-nube con sistemas legados (Transact y SmartVista).",
     None, 0.80),

    # ── Testing (28-Abr) ────────────────────────────────────────────────────
    ("SW3-DEC-021", "2026-04-28", "qa-fte-adecuado-no-escalar",
     "El equipo QA considera adecuado su número de FTE. Aumentar capacidad solo generaría más defectos que los equipos de desarrollo no podrían resolver a tiempo, dejando a QA inactivo. No se escalará el equipo sin cambiar el proceso upstream.",
     None, 0.82),

    ("SW3-DEC-022", "2026-04-28", "qa-ambiente-performance-insuficiente",
     "El ambiente de performance actual (pre-producción 'súper recortado') solo soporta 50 transacciones/minuto. Insuficiente para 18,000 usuarios en aplicación. QA ahora es responsable de solicitar y gestionar ambientes separados por producto antes de convergir en EIT.",
     None, 0.90),

    # ── SmartVista Roadmap R4 (30-Abr) ─────────────────────────────────────
    ("SW3-DEC-023", "2026-04-30", "r3-go-live-julio-sin-migracion",
     "R3 (Tarjeta de Crédito Física Friends and Family) tendrá Go-Live en julio 2026. No incluye migración. Canales: App, Web y SmartVista.",
     "pablo-lorenzo", 0.92),

    ("SW3-DEC-024", "2026-04-30", "r4-split-tres-liberaciones",
     "R4 de SmartVista (expansión a nuevos clientes, comercialización abierta en diciembre) se divide en tres liberaciones independientes para cumplir objetivos comerciales. Liberaciones inician Q4 2026; componente App termina en diciembre; liberación final (R4.5) en tercera semana de enero 2027.",
     "pablo-lorenzo", 0.95),

    ("SW3-DEC-025", "2026-04-30", "sit-uat-ciclos-separados-minimo-un-mes",
     "Se implementarán ciclos separados de SIT y UAT de mínimo un mes cada uno. Actualmente se hace un ciclo único donde distintas personas prueban los mismos casos. También se implementarán rehearsals de producción para mejorar runbook de deployment.",
     None, 0.90),

    # ── Control Técnico y Terceros (8-Abr) ─────────────────────────────────
    ("SW3-DEC-026", "2026-04-08", "80-pct-capacidad-unity-externa",
     "Aproximadamente el 80% de la capacidad de Unity depende de terceros. La gestión de terceros no es un tema complementario sino un componente estructural del modelo operativo. La estructura interna no es suficientemente robusta para ejecutar el desarrollo por sí sola.",
     None, 0.92),

    ("SW3-DEC-027", "2026-04-08", "sla-contratos-no-gestionados-operativamente",
     "Los SLAs definidos en contratos de proveedores autorizados regulatoriamente no se están midiendo ni gestionando operativamente. No existe tablero ni repositorio consolidado por proveedor. La operación actual es reactiva: se detectan problemas cuando ya ocurrieron.",
     None, 0.95),

    ("SW3-DEC-028", "2026-04-08", "145-servicios-sin-bafo-riesgo-critico",
     "Existen 145 servicios en compras desde noviembre sin BAFO cerrado. El ciclo contractual completo toma mínimo 6 meses (70 días solo para cerrar BAFO con Compras). Los proveedores ya no aceptan continuar solo bajo esquemas temporales de riesgo. Riesgo crítico para continuidad del programa.",
     "brenda", 0.95),

    # ── Portfolio Management (14-Abr) ──────────────────────────────────────
    ("SW3-DEC-029", "2026-04-14", "unity-fuera-modelo-portfolio-estandar",
     "Unity ha operado históricamente como iniciativa aislada fuera del modelo estándar de portafolio. No sigue el proceso de priorización (DEF/BNEA/ranking con directores). Portfolio Management (Leticia Díaz) no había participado formalmente en Unity hasta ahora.",
     None, 0.95),

    ("SW3-DEC-030", "2026-04-14", "unity-clasificado-discrecional-no-estrategico",
     "Unity, originalmente clasificada como iniciativa estratégica (ranking #2), está ahora fragmentada en múltiples iniciativas y clasificada como 'discrecional'. Objetivo: recuperar su estatus como iniciativa estratégica formal para recuperar prioridad real.",
     None, 0.88),
]

# (stakeholder_id, topic, stance_text, sentiment, date)
POSITIONS = [
    ("juan-manuel", "business-case-costos",
     "Interés principal: análisis de costos. Hay gasto significativo sin previsión adecuada; exige business case sólido que justifique la inversión con datos reales.",
     "negative", "2026-04-14"),

    ("daniel-angeles", "arquitectura-legacy",
     "Propone dejar de desarrollar en PISA. T-24 y otros sistemas deben consultar solo datos del core legacy sin pedirle su lógica a través de SPLs. Sugiere Lambdas o WAS para capa de interoperabilidad.",
     "positive", "2026-03-17"),

    ("daniel-angeles", "gobernanza-silos",
     "El programa opera en silos sin comunicación con el equipo de legado. Falta de accountability es común en el banco. Se necesita nueva gobernanza con punto de contacto único por frente.",
     "negative", "2026-03-17"),

    ("daniel-angeles", "compliance-seguridad-desde-arranque",
     "Arquitectura, OSI y seguridad deben integrarse desde el inicio. Si entran tarde pedirán contexto de todo y retrasarán el avance. Es una condición no negociable para él.",
     "positive", "2026-03-25"),

    ("rodrigo", "diagnostico-unity-talento",
     "El principal problema de Unity no es tecnológico: es gestión de talento (60% rotación), accountability, comunicación y liderazgo. 200+ hallazgos levantados en 61-65 entrevistas entre diciembre-enero. Business case desactualizado.",
     "negative", "2026-03-25"),

    ("rodrigo", "change-management-insuficiente",
     "El change management de Unity consiste solo en manuales y capacitación. Faltan mapa de stakeholders, evaluación de adopción del modelo y estrategia integral. Metodología heterogénea: Gyra vs manual (Temenos no quiere usar Gyra).",
     "negative", "2026-03-25"),

    ("lukasz-pietrzyk", "smartvista-arquitectura-brecha",
     "El ejercicio de mapeo de capacidades empresariales para SmartVista no ha comenzado formalmente. Es necesario refrescar el tema con el equipo de arquitectura para identificar posibles brechas antes de que avance el release.",
     "negative", "2026-04-23"),

    ("lukasz-pietrzyk", "apolo-salida-lenin-riesgo",
     "La salida de Lenin el 31 de mayo es un riesgo crítico que requiere atención inmediata. Solo Joaquín Pichardo recibió contexto. Si no se actúa ahora, Apolo quedará sin arquitecto de solución con conocimiento profundo.",
     "negative", "2026-04-28"),

    ("lukasz-pietrzyk", "apolo-latencia-apis-diseno",
     "Las latencias de 5 segundos en cualquier API de Apolo son un problema de diseño de solución, no de operaciones. Requiere que el arquitecto de solución haga diagnóstico y proponga solución; arquitectura de integración solo puede apoyar con opciones después.",
     "negative", "2026-04-28"),

    ("brenda", "gestion-terceros-inmadura",
     "El área de RMO es nueva e inmadura para funciones avanzadas de gobierno de terceros. Actualmente solo cubre contratación y pago. No existe historial consolidado por proveedor, ni visión integral del desempeño acumulado. La operación es reactiva.",
     "negative", "2026-04-08"),

    ("pablo-lorenzo", "arquitectura-marco-referencia-adaptacion",
     "La arquitectura propuesta por Accenture es un marco de referencia que debe adaptarse para definir la target architecture de BanCoppel. Las piezas deben subirse sincronizadas con las piezas de negocio para reducir el riesgo.",
     "positive", "2026-03-17"),

    ("pablo-lorenzo", "smartvista-r4-split-agresivo",
     "Propone ser más agresivos con la propuesta de R4: dividirlo en tres liberaciones independientes permite cumplir compromisos comerciales de diciembre mientras se gana tiempo para componentes más complejos hasta enero 2027.",
     "positive", "2026-04-30"),

    ("erica-mata", "seguridad-agenda-limitada",
     "Alta probabilidad de que Erica Mata delegue parte del trabajo en su equipo (Frank Ortiz). Conseguir 30 minutos con ella directamente es un logro por sí mismo dado su agenda. Seguridad no puede ser un frente de última hora.",
     "neutral", "2026-03-25"),

    ("arturo-perez", "legacy-coordinacion-contextualizado",
     "Arturo ya fue contextualizado por Daniel Ángeles sobre la iniciativa y fue quien compartió la tabla de responsables por servicio. Acepta fungir como referente principal del frente legacy; los especialistas por servicio participarán en detalles.",
     "positive", "2026-03-25"),

    (None, "portfolio-unity-modelo-gestion",
     "Leticia Díaz (Portfolio Management) y Mireya Hernández evalúan dos modelos: portafolio independiente de transformación vs integración de Unity en value streams existentes (Apolo→onboarding, Smart Vista→tarjetas, Transact→préstamos/captación). Decisión determinante para el futuro del programa.",
     "neutral", "2026-04-14"),

    (None, "qa-testing-resistencia-cultural",
     "Rosa Margarita Ramírez (QA): La estrategia de pruebas está bien estructurada pero muchos puntos no se implementan en la práctica. Hay resistencia cultural a documentar; QA realiza retrabajo constante para definir flujos. Las HU en Jira están mal redactadas y son ambiguas. Implementar la plantilla obligatoria tomó 6 meses.",
     "negative", "2026-04-28"),

    (None, "deuda-tecnica-vs-releases",
     "María Mercedes Espinosa (Arquitectura): Los equipos quieren resolver hallazgos de deuda técnica pero las prioridades de los releases prevalecen. Los equipos saben que resolver hallazgos es condición para entrar a mercado abierto, pero la capacidad instalada no alcanza.",
     "negative", "2026-04-28"),

    (None, "uat-negocio-no-participa",
     "El área de negocio tiene problemas de tiempo para UAT; QA debe apoyar la ejecución, lo que prolonga las pruebas de 4 semanas a 4 meses. Los usuarios traen casos fuera de alcance por inseguridad (ej. remesas al probar TDC). Lección aprendida: el proceso QA tuvo que repetirse completamente una vez por HU mal definidas.",
     "negative", "2026-04-28"),
]

# (id, date, item_text, owner_id_or_None, priority, systems_json)
OPEN_ITEMS = [
    ("SW3-OI-001", "2026-04-14",
     "Obtener datos de costos de nómina para el business case: requiere headcount por centro de costo y asignación porcentual a Unity vs otros proyectos. Es el principal gap de información del modelo de costos.",
     None, "high", '["PISA","Transact","Apolo","SmartVista"]'),

    ("SW3-OI-002", "2026-04-14",
     "Validar y ajustar supuestos del business case previo. Riesgo de doble contabilización de beneficios identificado. Las proyecciones actuales son preliminares y deben robustecerse con datos reales.",
     None, "high", '["Transact","Apolo","SmartVista"]'),

    ("SW3-OI-003", "2026-04-14",
     "Completar ejercicio APO (Application Portfolio Optimization) para identificar aplicativos a eliminar, mantener y transformar, con timeline de decomisionamiento y olas de decomiso por aplicativo.",
     None, "high", '["PISA","Atlas"]'),

    ("SW3-OI-004", "2026-04-14",
     "Formalizar Unity como iniciativa estratégica en el proceso de priorización de portafolio (DEF + BNEA + ranking con directores). Actualmente clasificada como discrecional; necesita recuperar posición estratégica.",
     "luis-barragan", "high", '["Apolo","Transact","SmartVista"]'),

    ("SW3-OI-005", "2026-04-14",
     "Decidir modelo de gestión de portafolio para Unity: (a) portafolio independiente de transformación con priorización propia, o (b) integración en value streams existentes (Apolo/Smart Vista/Transact). Decisión determinante para el gobierno futuro.",
     "luis-barragan", "critical", '["Apolo","Transact","SmartVista"]'),

    ("SW3-OI-006", "2026-03-17",
     "Agendar kick-off formal con Juan Manuel para confirmar: (1) director de Unity (Pablo Medinavitia en onboarding), (2) líderes de proyecto por plataforma vía Luis Barragán, (3) punto de contacto de arquitectura (Arcadio), (4) responsable de Change Management.",
     "gabriela-maximiliano", "critical", '["Apolo","Transact","SmartVista","PISA"]'),

    ("SW3-OI-007", "2026-03-25",
     "Coordinar sesión introductoria formal con Arturo Pérez: presentarle la iniciativa, usarla como reunión introductoria y pedirle orientación sobre cómo coordinar a su equipo de Legacy.",
     "karina-zepeda", "high", '["PISA","MuleSoft"]'),

    ("SW3-OI-008", "2026-03-25",
     "Conseguir espacio de 30 minutos con Erica Mata (CISO) para alinear integración de seguridad/OSI desde el arranque. Alta dificultad por agenda; se considera Frank Ortiz como alternativa operativa.",
     "pablo-lorenzo", "high", '["Apolo","Transact","SmartVista","PISA"]'),

    ("SW3-OI-009", "2026-04-23",
     "Formalizar el requerimiento de Tarjeta de Débito (TD) para SmartVista con Sergio del Valle. Sin formalización no hay backlog, riesgos ni dependencias registradas. Expectativa de negocio: Q1 2027.",
     None, "medium", '["SmartVista","Apolo"]'),

    ("SW3-OI-010", "2026-04-23",
     "Pablo Lorenzo contactará a Juan Andrés Morín (Director Habilitadores, vertical ambientes) para solicitar inventario de interfaces de SmartVista R2 y R3.",
     "pablo-lorenzo", "high", '["SmartVista","MuleSoft"]'),

    ("SW3-OI-011", "2026-04-23",
     "Planificar sesión de mapeo de capacidades empresariales de SmartVista con equipo de arquitectura y líderes técnicos. Ana Rosa y Leonardo Hernández confirmarán nombres de asistentes del equipo de Arquitectura de BanCoppel.",
     "pablo-lorenzo", "high", '["SmartVista"]'),

    ("SW3-OI-012", "2026-04-28",
     "Lukasz Pietrzyk contactará a Miguel Bucio para revisar: (1) situación crítica del reemplazo de Lenin en Apolo (salida 31-mayo), (2) transferencia formal de conocimiento, (3) asignación de AS a value streams. Riesgo crítico sin reemplazo identificado.",
     "lukasz-pietrzyk", "critical", '["Apolo"]'),

    ("SW3-OI-013", "2026-04-28",
     "Confirmar qué módulos de SmartVista están contratados y habilitados. Julio César Quiroga tiene pendiente sesión con el proveedor BPC para clarificar módulos activos. Primeras versiones del análisis esperadas a mediados de mayo.",
     None, "high", '["SmartVista"]'),

    ("SW3-OI-014", "2026-04-28",
     "Agendar sesión de inducción de gobierno y onboarding de API con Gabriel Maldonado Hernández y Anayeli Ortiz (Scrum Master equipo de gobierno). Documentación disponible en Confluence.",
     "alejandro-gallegos", "medium", '["Apolo","MuleSoft"]'),

    ("SW3-OI-015", "2026-04-28",
     "Desarrollar directrices y recomendaciones formales sobre cuándo usar caché en APIs. Incluir en guías de arquitectura y organizar sesión de seguimiento específica. Crítico para escenario multi-nube con Transact y SmartVista como backends.",
     None, "medium", '["Apolo","Transact","SmartVista","MuleSoft"]'),

    ("SW3-OI-016", "2026-04-08",
     "Extraer SLAs de contratos autorizados por comisión (universo ~25 proveedores Unity) y crear mecanismo consolidado de medición. Depurar muestra inicial con contratos que incluyan penalizaciones y parámetros de disponibilidad.",
     "brenda", "high", '["Transact","Apolo","SmartVista","MuleSoft"]'),

    ("SW3-OI-017", "2026-04-08",
     "Resolver situación de 145 servicios en compras sin BAFO cerrado desde noviembre 2025. Expeditar ciclo contractual (actualmente mín. 6 meses). Los proveedores ya no aceptan continuar bajo esquemas temporales de riesgo. Riesgo crítico para continuidad de Unity.",
     "brenda", "critical", '["Apolo","Transact","SmartVista","MuleSoft","Atlas"]'),

    ("SW3-OI-018", "2026-04-28",
     "Equipo QA actualizará documento de estrategia de pruebas: diapositivas de herramientas desactualizadas (estrategia de hace 4 años), diagramas de ambientes para reflejar estado actual. Plan de migración a X-ray (integrado en Jira) para eliminar dashboards externos.",
     None, "medium", '["Apolo","Transact","SmartVista"]'),

    ("SW3-OI-019", "2026-04-30",
     "Pablo Lorenzo actualizará el roadmap de SmartVista para reflejar: (1) división de R4 en tres liberaciones independientes, (2) assumptions y riesgos explícitos, (3) dependencias con Apolo (onboarding físico Offi). Revisión en siguiente alineación semanal (martes 5 mayo).",
     "pablo-lorenzo", "high", '["SmartVista","Apolo"]'),

    ("SW3-OI-020", "2026-04-30",
     "Identificar único punto de contacto del equipo Legacy para coordinación con SmartVista. Actualmente existe desconexión crítica: stakeholders Legacy no conocen el impacto en Unity ni tienen claridad en fechas de entrega. Se requieren workshops específicos (uno para Transact, otro para SmartVista).",
     "arturo-perez", "high", '["PISA","Transact","SmartVista"]'),

    ("SW3-OI-021", "2026-04-14",
     "Agendar sesiones recurrentes (1-2 hrs) para construcción iterativa del business case con equipo financiero y técnico. Validación interna inicial con Salomón Monroy. Modelo colaborativo para refinamiento de supuestos.",
     "salomon-monroy", "medium", '["PISA","Transact","Apolo","SmartVista"]'),

    ("SW3-OI-022", "2026-04-08",
     "Crear directorio vivo y consolidado de todos los recursos asignados a Unity: roles, responsabilidades, posiciones cubiertas y faltantes. Cintia Ramírez y Luis Barragán tienen versión preliminar. Daniel Gabino (Mejora Continua) construye mapeo complementario. Agendar sesión de revisión con Cintia.",
     "luis-barragan", "high", '["Apolo","Transact","SmartVista","PISA"]'),
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
                (row[0], row[1], row[2], row[3], row[4],
                 f'["{row[2]}"]', row[5])
            )
            if db.execute("SELECT changes()").fetchone()[0]:
                n_dec += 1
        except Exception as e:
            print(f"DEC skip {row[0]}: {e}")

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
            print(f"POS skip {row[0]}/{row[1]}: {e}")

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
            print(f"OI skip {row[0]}: {e}")

    db.commit()
    print(
        f"Swarm G3: {n_dec} decisiones · {n_pos} posiciones · {n_oi} open items insertados"
    )
    db.close()


if __name__ == "__main__":
    run()