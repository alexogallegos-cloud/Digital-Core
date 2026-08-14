"""seed-swarm-3.py â€” Grupo 3 swarm extracciÃ³n estratÃ©gica Bank Brain BanCoppel

Fuentes procesadas (minutas abr-2026):
  - 14 Abr: Business Case Update + Portfolio Management
  - 17 Mar: Intro Daniel Ãngeles / Plan Director ACN
  - 23 Abr: SmartVista AlineaciÃ³n Semanal (semana 4)
  - 25 Mar: Daniel Ãngeles â€” mapa legacy, seguridad, sesiones
  - 28 Abr: AlineaciÃ³n Arquitectura Unity
  - 28 Abr: Testing â€” Estrategia y pain points
  - 30 Abr: SmartVista AlineaciÃ³n Semanal â€” Roadmap R4
"""
import sqlite3
from pathlib import Path

DB = Path(__file__).parent.parent / "digital-brain" / "bank-brain.db"

# (id, date, topic, decision_text, driver_id_or_None, confidence)
DECISIONS = [
    # â”€â”€ Business Case (14-Apr) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("SW3-DEC-001", "2026-04-14", "business-case-estructura",
     "Business case de Unity se estructura en dos componentes: valor habilitado (incremento cartera/productos) y costos comparados Unity vs legacy. Rango bajo = eficiencia de costos; rango alto = impacto en negocio.",
     None, 0.95),

    ("SW3-DEC-002", "2026-04-14", "business-case-prioridad",
     "Prioridad inmediata del business case: cuantificaciÃ³n de costos y estrategia de decomisionamiento (rango bajo del caso), por presiÃ³n directa de Juan Manuel.",
     "juan-manuel", 0.90),

    ("SW3-DEC-003", "2026-04-14", "business-case-supuestos",
     "El business case previo existe pero requiere validaciÃ³n y ajuste de supuestos. Se usarÃ¡n costos histÃ³ricos 2023-2025 y presupuesto 2026 como base para proyecciones hasta 2030.",
     None, 0.88),

    ("SW3-DEC-004", "2026-04-14", "decomisionamiento-apo",
     "El decomisionamiento de aplicaciones se modelarÃ¡ a partir del ejercicio APO (Application Portfolio Optimization), que clasificarÃ¡ aplicativos en: eliminar, mantener o transformar, con timeline de decomiso.",
     None, 0.92),

    ("SW3-DEC-005", "2026-04-14", "costos-oportunidad-bc",
     "Se incorporarÃ¡n costos de oportunidad en el business case (escenarios de indisponibilidad: caÃ­das SPEI, fallas en apps). Comparativa Legacy (8h recuperaciÃ³n) vs Unity (2h) para justificar inversiÃ³n mÃ¡s allÃ¡ de costos directos.",
     None, 0.85),

    ("SW3-DEC-006", "2026-04-14", "bc-coexistencia-legacy-unity",
     "El business case reflejarÃ¡ coexistencia real entre Unity y legacy. No se asumirÃ¡ eliminaciÃ³n total inmediata de PISA; se incluirÃ¡ el costo total de operaciÃ³n paralela.",
     None, 0.90),

    # â”€â”€ Arquitectura y Legado (17-Mar) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("SW3-DEC-007", "2026-03-17", "legacy-stop-desarrollo-pisa",
     "DecisiÃ³n arquitectÃ³nica de dejar de desarrollar en PISA/Informix. T-24/Transact y demÃ¡s sistemas Unity solo consultarÃ¡n datos del core legacy sin invocar lÃ³gica SPL. La capa de interoperabilidad (Lambdas o WAS) desacopla los sistemas nuevos de los procedimientos almacenados.",
     "daniel-angeles", 0.88),

    ("SW3-DEC-008", "2026-03-17", "repositorio-datos-por-encima-vendors",
     "Se implementarÃ¡ un repositorio de datos por encima de los vendors para mantener el control de BanCoppel y permitir explotaciÃ³n analÃ­tica futura sin dependencia de proveedores individuales.",
     "lukasz-pietrzyk", 0.82),

    ("SW3-DEC-009", "2026-03-17", "plan-director-seis-semanas",
     "Accenture ejecutarÃ¡ plan director de seis semanas estructurado en dos bloques: Gobierno del programa (takeover/co-liderazgo a partir de semana 7) y Estrategia TecnolÃ³gica (6 diagnÃ³sticos: alineaciÃ³n, arquitectura, modelo operativo, roadmap, change management, business case).",
     "pablo-lorenzo", 0.95),

    # â”€â”€ Gobernanza y contactos clave (25-Mar) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("SW3-DEC-010", "2026-03-25", "arturo-perez-punto-contacto-legacy",
     "Arturo PÃ©rez queda como referente principal y punto de contacto Ãºnico del frente Legacy. Los responsables especÃ­ficos por servicio participarÃ¡n en conversaciones de detalle, pero Arturo coordina al grupo.",
     "daniel-angeles", 0.93),

    ("SW3-DEC-011", "2026-03-25", "seguridad-compliance-desde-arranque",
     "Arquitectura, OSI (Oficina de Seguridad de la InformaciÃ³n) y seguridad/compliance deben integrarse desde el inicio del programa. Si se integran tarde pedirÃ¡n contexto de todo lo trabajado y retrasarÃ¡n el avance.",
     "daniel-angeles", 0.92),

    ("SW3-DEC-012", "2026-03-25", "erica-mata-referente-seguridad",
     "Erica Mata (CISO) queda como referente principal de seguridad. Frank Eduardo Ortiz Iglesias es posible contacto operativo de apoyo. Se aÃ±ade caja transversal de compliance/seguridad a la estructura del proyecto.",
     "pablo-lorenzo", 0.90),

    # â”€â”€ SmartVista alcance y TD (23-Abr) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("SW3-DEC-013", "2026-04-23", "smartvista-td-fuera-de-alcance",
     "Tarjeta de DÃ©bito (TD) NO estÃ¡ en el alcance actual de SmartVista/BPC. Tentativa de negocio: Q1 2027. TD pertenece al plan N4 de Apolo y al plan director; no estÃ¡ en el backlog de SmartVista, sin riesgos ni dependencias asociadas formalmente.",
     None, 0.95),

    ("SW3-DEC-014", "2026-04-23", "smartvista-inventario-interfaces-incompleto",
     "El inventario oficial de interfaces de SmartVista/TDC solo existe para releases R2 y R3. No existe inventario para R4. No hay un inventario comÃºn consolidado de todas las interfaces. Contacto para solicitar R2/R3: Juan AndrÃ©s MorÃ­n (Director Habilitadores, vertical ambientes).",
     None, 0.93),

    ("SW3-DEC-015", "2026-04-23", "smartvista-mapeo-capacidades-no-iniciado",
     "La construcciÃ³n del diagrama empresarial de referencia y mapeo de capacidades funcionales de arquitectura para SmartVista no han comenzado formalmente. Se requiere sesiÃ³n de seguimiento con arquitectura y lÃ­deres tÃ©cnicos.",
     "lukasz-pietrzyk", 0.90),

    # â”€â”€ Arquitectura Unity (28-Abr) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("SW3-DEC-016", "2026-04-28", "arquitectura-solucion-en-celulas",
     "Se incorporarÃ¡n proactivamente arquitectos de soluciÃ³n (AS) internos en cÃ©lulas de desarrollo para garantizar cumplimiento de estÃ¡ndares desde la fase de diseÃ±o. Ya se identificaron tres AS internos; ademÃ¡s se cuenta con equipo IU para proyectos estratÃ©gicos como Unity y N4.",
     None, 0.88),

    ("SW3-DEC-017", "2026-04-28", "riesgo-salida-lenin-apolo",
     "La salida de Lenin (arquitecto de soluciÃ³n clave de Apolo) el 31 de mayo es riesgo crÃ­tico: no hay reemplazo formal identificado ni transferencia de conocimiento documentada. Solo pasÃ³ contexto a JoaquÃ­n Pichardo (ACN). Lukasz contactarÃ¡ a Miguel Bucio para definir acciones.",
     "lukasz-pietrzyk", 0.95),

    ("SW3-DEC-018", "2026-04-28", "arquitectura-valida-diseno-no-nfr",
     "Arquitectura valida diseÃ±o de soluciÃ³n, NO requerimientos no funcionales ni pruebas de rendimiento. Latencias de 5 segundos en APIs Apolo son problema de diseÃ±o de soluciÃ³n (SA). Arquitectura de IntegraciÃ³n puede dar opciones solo si el AS realiza diagnÃ³stico y presenta propuesta.",
     None, 0.90),

    ("SW3-DEC-019", "2026-04-28", "smartvista-modulos-contratados-sin-inventario",
     "Existe brecha de documentaciÃ³n sobre mÃ³dulos de SmartVista contratados y habilitados. Equipo de arquitectura estÃ¡ en proceso de verificaciÃ³n; primeras versiones del anÃ¡lisis esperadas a mediados de mayo 2026.",
     None, 0.88),

    ("SW3-DEC-020", "2026-04-28", "guias-cache-api",
     "Se desarrollarÃ¡n directrices y recomendaciones sobre cuÃ¡ndo usar cachÃ© en APIs, fundamentales para optimizar tiempos y reducir consultas en el escenario multi-nube con sistemas legados (Transact y SmartVista).",
     None, 0.80),

    # â”€â”€ Testing (28-Abr) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("SW3-DEC-021", "2026-04-28", "qa-fte-adecuado-no-escalar",
     "El equipo QA considera adecuado su nÃºmero de FTE. Aumentar capacidad solo generarÃ­a mÃ¡s defectos que los equipos de desarrollo no podrÃ­an resolver a tiempo, dejando a QA inactivo. No se escalarÃ¡ el equipo sin cambiar el proceso upstream.",
     None, 0.82),

    ("SW3-DEC-022", "2026-04-28", "qa-ambiente-performance-insuficiente",
     "El ambiente de performance actual (pre-producciÃ³n 'sÃºper recortado') solo soporta 50 transacciones/minuto. Insuficiente para 18,000 usuarios en aplicaciÃ³n. QA ahora es responsable de solicitar y gestionar ambientes separados por producto antes de convergir en EIT.",
     None, 0.90),

    # â”€â”€ SmartVista Roadmap R4 (30-Abr) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("SW3-DEC-023", "2026-04-30", "r3-go-live-julio-sin-migracion",
     "R3 (Tarjeta de CrÃ©dito FÃ­sica Friends and Family) tendrÃ¡ Go-Live en julio 2026. No incluye migraciÃ³n. Canales: App, Web y SmartVista.",
     "pablo-lorenzo", 0.92),

    ("SW3-DEC-024", "2026-04-30", "r4-split-tres-liberaciones",
     "R4 de SmartVista (expansiÃ³n a nuevos clientes, comercializaciÃ³n abierta en diciembre) se divide en tres liberaciones independientes para cumplir objetivos comerciales. Liberaciones inician Q4 2026; componente App termina en diciembre; liberaciÃ³n final (R4.5) en tercera semana de enero 2027.",
     "pablo-lorenzo", 0.95),

    ("SW3-DEC-025", "2026-04-30", "sit-uat-ciclos-separados-minimo-un-mes",
     "Se implementarÃ¡n ciclos separados de SIT y UAT de mÃ­nimo un mes cada uno. Actualmente se hace un ciclo Ãºnico donde distintas personas prueban los mismos casos. TambiÃ©n se implementarÃ¡n rehearsals de producciÃ³n para mejorar runbook de deployment.",
     None, 0.90),

    # â”€â”€ Control TÃ©cnico y Terceros (8-Abr) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("SW3-DEC-026", "2026-04-08", "80-pct-capacidad-unity-externa",
     "Aproximadamente el 80% de la capacidad de Unity depende de terceros. La gestiÃ³n de terceros no es un tema complementario sino un componente estructural del modelo operativo. La estructura interna no es suficientemente robusta para ejecutar el desarrollo por sÃ­ sola.",
     None, 0.92),

    ("SW3-DEC-027", "2026-04-08", "sla-contratos-no-gestionados-operativamente",
     "Los SLAs definidos en contratos de proveedores autorizados regulatoriamente no se estÃ¡n midiendo ni gestionando operativamente. No existe tablero ni repositorio consolidado por proveedor. La operaciÃ³n actual es reactiva: se detectan problemas cuando ya ocurrieron.",
     None, 0.95),

    ("SW3-DEC-028", "2026-04-08", "145-servicios-sin-bafo-riesgo-critico",
     "Existen 145 servicios en compras desde noviembre sin BAFO cerrado. El ciclo contractual completo toma mÃ­nimo 6 meses (70 dÃ­as solo para cerrar BAFO con Compras). Los proveedores ya no aceptan continuar solo bajo esquemas temporales de riesgo. Riesgo crÃ­tico para continuidad del programa.",
     "brenda", 0.95),

    # â”€â”€ Portfolio Management (14-Abr) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("SW3-DEC-029", "2026-04-14", "unity-fuera-modelo-portfolio-estandar",
     "Unity ha operado histÃ³ricamente como iniciativa aislada fuera del modelo estÃ¡ndar de portafolio. No sigue el proceso de priorizaciÃ³n (DEF/BNEA/ranking con directores). Portfolio Management (Leticia DÃ­az) no habÃ­a participado formalmente en Unity hasta ahora.",
     None, 0.95),

    ("SW3-DEC-030", "2026-04-14", "unity-clasificado-discrecional-no-estrategico",
     "Unity, originalmente clasificada como iniciativa estratÃ©gica (ranking #2), estÃ¡ ahora fragmentada en mÃºltiples iniciativas y clasificada como 'discrecional'. Objetivo: recuperar su estatus como iniciativa estratÃ©gica formal para recuperar prioridad real.",
     None, 0.88),
]

# (stakeholder_id, topic, stance_text, sentiment, date)
POSITIONS = [
    ("juan-manuel", "business-case-costos",
     "InterÃ©s principal: anÃ¡lisis de costos. Hay gasto significativo sin previsiÃ³n adecuada; exige business case sÃ³lido que justifique la inversiÃ³n con datos reales.",
     "negative", "2026-04-14"),

    ("daniel-angeles", "arquitectura-legacy",
     "Propone dejar de desarrollar en PISA. T-24 y otros sistemas deben consultar solo datos del core legacy sin pedirle su lÃ³gica a travÃ©s de SPLs. Sugiere Lambdas o WAS para capa de interoperabilidad.",
     "positive", "2026-03-17"),

    ("daniel-angeles", "gobernanza-silos",
     "El programa opera en silos sin comunicaciÃ³n con el equipo de legado. Falta de accountability es comÃºn en el banco. Se necesita nueva gobernanza con punto de contacto Ãºnico por frente.",
     "negative", "2026-03-17"),

    ("daniel-angeles", "compliance-seguridad-desde-arranque",
     "Arquitectura, OSI y seguridad deben integrarse desde el inicio. Si entran tarde pedirÃ¡n contexto de todo y retrasarÃ¡n el avance. Es una condiciÃ³n no negociable para Ã©l.",
     "positive", "2026-03-25"),

    ("rodrigo", "diagnostico-unity-talento",
     "El principal problema de Unity no es tecnolÃ³gico: es gestiÃ³n de talento (60% rotaciÃ³n), accountability, comunicaciÃ³n y liderazgo. 200+ hallazgos levantados en 61-65 entrevistas entre diciembre-enero. Business case desactualizado.",
     "negative", "2026-03-25"),

    ("rodrigo", "change-management-insuficiente",
     "El change management de Unity consiste solo en manuales y capacitaciÃ³n. Faltan mapa de stakeholders, evaluaciÃ³n de adopciÃ³n del modelo y estrategia integral. MetodologÃ­a heterogÃ©nea: Gyra vs manual (Temenos no quiere usar Gyra).",
     "negative", "2026-03-25"),

    ("lukasz-pietrzyk", "smartvista-arquitectura-brecha",
     "El ejercicio de mapeo de capacidades empresariales para SmartVista no ha comenzado formalmente. Es necesario refrescar el tema con el equipo de arquitectura para identificar posibles brechas antes de que avance el release.",
     "negative", "2026-04-23"),

    ("lukasz-pietrzyk", "apolo-salida-lenin-riesgo",
     "La salida de Lenin el 31 de mayo es un riesgo crÃ­tico que requiere atenciÃ³n inmediata. Solo JoaquÃ­n Pichardo recibiÃ³ contexto. Si no se actÃºa ahora, Apolo quedarÃ¡ sin arquitecto de soluciÃ³n con conocimiento profundo.",
     "negative", "2026-04-28"),

    ("lukasz-pietrzyk", "apolo-latencia-apis-diseno",
     "Las latencias de 5 segundos en cualquier API de Apolo son un problema de diseÃ±o de soluciÃ³n, no de operaciones. Requiere que el arquitecto de soluciÃ³n haga diagnÃ³stico y proponga soluciÃ³n; arquitectura de integraciÃ³n solo puede apoyar con opciones despuÃ©s.",
     "negative", "2026-04-28"),

    ("brenda", "gestion-terceros-inmadura",
     "El Ã¡rea de RMO es nueva e inmadura para funciones avanzadas de gobierno de terceros. Actualmente solo cubre contrataciÃ³n y pago. No existe historial consolidado por proveedor, ni visiÃ³n integral del desempeÃ±o acumulado. La operaciÃ³n es reactiva.",
     "negative", "2026-04-08"),

    ("pablo-lorenzo", "arquitectura-marco-referencia-adaptacion",
     "La arquitectura propuesta por Accenture es un marco de referencia que debe adaptarse para definir la target architecture de BanCoppel. Las piezas deben subirse sincronizadas con las piezas de negocio para reducir el riesgo.",
     "positive", "2026-03-17"),

    ("pablo-lorenzo", "smartvista-r4-split-agresivo",
     "Propone ser mÃ¡s agresivos con la propuesta de R4: dividirlo en tres liberaciones independientes permite cumplir compromisos comerciales de diciembre mientras se gana tiempo para componentes mÃ¡s complejos hasta enero 2027.",
     "positive", "2026-04-30"),

    ("erica-mata", "seguridad-agenda-limitada",
     "Alta probabilidad de que Erica Mata delegue parte del trabajo en su equipo (Frank Ortiz). Conseguir 30 minutos con ella directamente es un logro por sÃ­ mismo dado su agenda. Seguridad no puede ser un frente de Ãºltima hora.",
     "neutral", "2026-03-25"),

    ("arturo-perez", "legacy-coordinacion-contextualizado",
     "Arturo ya fue contextualizado por Daniel Ãngeles sobre la iniciativa y fue quien compartiÃ³ la tabla de responsables por servicio. Acepta fungir como referente principal del frente legacy; los especialistas por servicio participarÃ¡n en detalles.",
     "positive", "2026-03-25"),

    (None, "portfolio-unity-modelo-gestion",
     "Leticia DÃ­az (Portfolio Management) y Mireya HernÃ¡ndez evalÃºan dos modelos: portafolio independiente de transformaciÃ³n vs integraciÃ³n de Unity en value streams existentes (Apoloâ†’onboarding, Smart Vistaâ†’tarjetas, Transactâ†’prÃ©stamos/captaciÃ³n). DecisiÃ³n determinante para el futuro del programa.",
     "neutral", "2026-04-14"),

    (None, "qa-testing-resistencia-cultural",
     "Rosa Margarita RamÃ­rez (QA): La estrategia de pruebas estÃ¡ bien estructurada pero muchos puntos no se implementan en la prÃ¡ctica. Hay resistencia cultural a documentar; QA realiza retrabajo constante para definir flujos. Las HU en Jira estÃ¡n mal redactadas y son ambiguas. Implementar la plantilla obligatoria tomÃ³ 6 meses.",
     "negative", "2026-04-28"),

    (None, "deuda-tecnica-vs-releases",
     "MarÃ­a Mercedes Espinosa (Arquitectura): Los equipos quieren resolver hallazgos de deuda tÃ©cnica pero las prioridades de los releases prevalecen. Los equipos saben que resolver hallazgos es condiciÃ³n para entrar a mercado abierto, pero la capacidad instalada no alcanza.",
     "negative", "2026-04-28"),

    (None, "uat-negocio-no-participa",
     "El Ã¡rea de negocio tiene problemas de tiempo para UAT; QA debe apoyar la ejecuciÃ³n, lo que prolonga las pruebas de 4 semanas a 4 meses. Los usuarios traen casos fuera de alcance por inseguridad (ej. remesas al probar TDC). LecciÃ³n aprendida: el proceso QA tuvo que repetirse completamente una vez por HU mal definidas.",
     "negative", "2026-04-28"),
]

# (id, date, item_text, owner_id_or_None, priority, systems_json)
OPEN_ITEMS = [
    ("SW3-OI-001", "2026-04-14",
     "Obtener datos de costos de nÃ³mina para el business case: requiere headcount por centro de costo y asignaciÃ³n porcentual a Unity vs otros proyectos. Es el principal gap de informaciÃ³n del modelo de costos.",
     None, "high", '["PISA","Transact","Apolo","SmartVista"]'),

    ("SW3-OI-002", "2026-04-14",
     "Validar y ajustar supuestos del business case previo. Riesgo de doble contabilizaciÃ³n de beneficios identificado. Las proyecciones actuales son preliminares y deben robustecerse con datos reales.",
     None, "high", '["Transact","Apolo","SmartVista"]'),

    ("SW3-OI-003", "2026-04-14",
     "Completar ejercicio APO (Application Portfolio Optimization) para identificar aplicativos a eliminar, mantener y transformar, con timeline de decomisionamiento y olas de decomiso por aplicativo.",
     None, "high", '["PISA","Atlas"]'),

    ("SW3-OI-004", "2026-04-14",
     "Formalizar Unity como iniciativa estratÃ©gica en el proceso de priorizaciÃ³n de portafolio (DEF + BNEA + ranking con directores). Actualmente clasificada como discrecional; necesita recuperar posiciÃ³n estratÃ©gica.",
     "luis-barragan", "high", '["Apolo","Transact","SmartVista"]'),

    ("SW3-OI-005", "2026-04-14",
     "Decidir modelo de gestiÃ³n de portafolio para Unity: (a) portafolio independiente de transformaciÃ³n con priorizaciÃ³n propia, o (b) integraciÃ³n en value streams existentes (Apolo/Smart Vista/Transact). DecisiÃ³n determinante para el gobierno futuro.",
     "luis-barragan", "critical", '["Apolo","Transact","SmartVista"]'),

    ("SW3-OI-006", "2026-03-17",
     "Agendar kick-off formal con Juan Manuel para confirmar: (1) director de Unity (Pablo Medinavitia en onboarding), (2) lÃ­deres de proyecto por plataforma vÃ­a Luis BarragÃ¡n, (3) punto de contacto de arquitectura (Arcadio), (4) responsable de Change Management.",
     "gabriela-maximiliano", "critical", '["Apolo","Transact","SmartVista","PISA"]'),

    ("SW3-OI-007", "2026-03-25",
     "Coordinar sesiÃ³n introductoria formal con Arturo PÃ©rez: presentarle la iniciativa, usarla como reuniÃ³n introductoria y pedirle orientaciÃ³n sobre cÃ³mo coordinar a su equipo de Legacy.",
     "karina-zepeda", "high", '["PISA","MuleSoft"]'),

    ("SW3-OI-008", "2026-03-25",
     "Conseguir espacio de 30 minutos con Erica Mata (CISO) para alinear integraciÃ³n de seguridad/OSI desde el arranque. Alta dificultad por agenda; se considera Frank Ortiz como alternativa operativa.",
     "pablo-lorenzo", "high", '["Apolo","Transact","SmartVista","PISA"]'),

    ("SW3-OI-009", "2026-04-23",
     "Formalizar el requerimiento de Tarjeta de DÃ©bito (TD) para SmartVista con Sergio del Valle. Sin formalizaciÃ³n no hay backlog, riesgos ni dependencias registradas. Expectativa de negocio: Q1 2027.",
     None, "medium", '["SmartVista","Apolo"]'),

    ("SW3-OI-010", "2026-04-23",
     "Pablo Lorenzo contactarÃ¡ a Juan AndrÃ©s MorÃ­n (Director Habilitadores, vertical ambientes) para solicitar inventario de interfaces de SmartVista R2 y R3.",
     "pablo-lorenzo", "high", '["SmartVista","MuleSoft"]'),

    ("SW3-OI-011", "2026-04-23",
     "Planificar sesiÃ³n de mapeo de capacidades empresariales de SmartVista con equipo de arquitectura y lÃ­deres tÃ©cnicos. Ana Rosa y Leonardo HernÃ¡ndez confirmarÃ¡n nombres de asistentes del equipo de Arquitectura de BanCoppel.",
     "pablo-lorenzo", "high", '["SmartVista"]'),

    ("SW3-OI-012", "2026-04-28",
     "Lukasz Pietrzyk contactarÃ¡ a Miguel Bucio para revisar: (1) situaciÃ³n crÃ­tica del reemplazo de Lenin en Apolo (salida 31-mayo), (2) transferencia formal de conocimiento, (3) asignaciÃ³n de AS a value streams. Riesgo crÃ­tico sin reemplazo identificado.",
     "lukasz-pietrzyk", "critical", '["Apolo"]'),

    ("SW3-OI-013", "2026-04-28",
     "Confirmar quÃ© mÃ³dulos de SmartVista estÃ¡n contratados y habilitados. Julio CÃ©sar Quiroga tiene pendiente sesiÃ³n con el proveedor BPC para clarificar mÃ³dulos activos. Primeras versiones del anÃ¡lisis esperadas a mediados de mayo.",
     None, "high", '["SmartVista"]'),

    ("SW3-OI-014", "2026-04-28",
     "Agendar sesiÃ³n de inducciÃ³n de gobierno y onboarding de API con Gabriel Maldonado HernÃ¡ndez y Anayeli Ortiz (Scrum Master equipo de gobierno). DocumentaciÃ³n disponible en Confluence.",
     "alejandro-gallegos", "medium", '["Apolo","MuleSoft"]'),

    ("SW3-OI-015", "2026-04-28",
     "Desarrollar directrices y recomendaciones formales sobre cuÃ¡ndo usar cachÃ© en APIs. Incluir en guÃ­as de arquitectura y organizar sesiÃ³n de seguimiento especÃ­fica. CrÃ­tico para escenario multi-nube con Transact y SmartVista como backends.",
     None, "medium", '["Apolo","Transact","SmartVista","MuleSoft"]'),

    ("SW3-OI-016", "2026-04-08",
     "Extraer SLAs de contratos autorizados por comisiÃ³n (universo ~25 proveedores Unity) y crear mecanismo consolidado de mediciÃ³n. Depurar muestra inicial con contratos que incluyan penalizaciones y parÃ¡metros de disponibilidad.",
     "brenda", "high", '["Transact","Apolo","SmartVista","MuleSoft"]'),

    ("SW3-OI-017", "2026-04-08",
     "Resolver situaciÃ³n de 145 servicios en compras sin BAFO cerrado desde noviembre 2025. Expeditar ciclo contractual (actualmente mÃ­n. 6 meses). Los proveedores ya no aceptan continuar bajo esquemas temporales de riesgo. Riesgo crÃ­tico para continuidad de Unity.",
     "brenda", "critical", '["Apolo","Transact","SmartVista","MuleSoft","Atlas"]'),

    ("SW3-OI-018", "2026-04-28",
     "Equipo QA actualizarÃ¡ documento de estrategia de pruebas: diapositivas de herramientas desactualizadas (estrategia de hace 4 aÃ±os), diagramas de ambientes para reflejar estado actual. Plan de migraciÃ³n a X-ray (integrado en Jira) para eliminar dashboards externos.",
     None, "medium", '["Apolo","Transact","SmartVista"]'),

    ("SW3-OI-019", "2026-04-30",
     "Pablo Lorenzo actualizarÃ¡ el roadmap de SmartVista para reflejar: (1) divisiÃ³n de R4 en tres liberaciones independientes, (2) assumptions y riesgos explÃ­citos, (3) dependencias con Apolo (onboarding fÃ­sico Offi). RevisiÃ³n en siguiente alineaciÃ³n semanal (martes 5 mayo).",
     "pablo-lorenzo", "high", '["SmartVista","Apolo"]'),

    ("SW3-OI-020", "2026-04-30",
     "Identificar Ãºnico punto de contacto del equipo Legacy para coordinaciÃ³n con SmartVista. Actualmente existe desconexiÃ³n crÃ­tica: stakeholders Legacy no conocen el impacto en Unity ni tienen claridad en fechas de entrega. Se requieren workshops especÃ­ficos (uno para Transact, otro para SmartVista).",
     "arturo-perez", "high", '["PISA","Transact","SmartVista"]'),

    ("SW3-OI-021", "2026-04-14",
     "Agendar sesiones recurrentes (1-2 hrs) para construcciÃ³n iterativa del business case con equipo financiero y tÃ©cnico. ValidaciÃ³n interna inicial con SalomÃ³n Monroy. Modelo colaborativo para refinamiento de supuestos.",
     "salomon-monroy", "medium", '["PISA","Transact","Apolo","SmartVista"]'),

    ("SW3-OI-022", "2026-04-08",
     "Crear directorio vivo y consolidado de todos los recursos asignados a Unity: roles, responsabilidades, posiciones cubiertas y faltantes. Cintia RamÃ­rez y Luis BarragÃ¡n tienen versiÃ³n preliminar. Daniel Gabino (Mejora Continua) construye mapeo complementario. Agendar sesiÃ³n de revisiÃ³n con Cintia.",
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
        f"Swarm G3: {n_dec} decisiones Â· {n_pos} posiciones Â· {n_oi} open items insertados"
    )
    db.close()


if __name__ == "__main__":
    run()