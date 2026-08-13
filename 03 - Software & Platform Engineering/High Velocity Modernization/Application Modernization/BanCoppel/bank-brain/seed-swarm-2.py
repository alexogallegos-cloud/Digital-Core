"""seed-swarm-2.py — Grupo 2 swarm extracción estratégica Bank Brain BanCoppel

Fuentes procesadas (minutas mar-abr 2026):
  - 24 Mar: Almaguer — integración/migración, legacy, cloud
  - 24 Mar: Tere Gonzalez — RFI, gobierno, mapa stakeholders
  - 24 Mar: Daniel Ángeles — arquitectura, roles TI, modelo operativo
  - 07 Abr: Value Streams — modelo operativo actual vs separación Unity
  - 13 Abr: Gestión de Talento TI — estructura, dedicación, RH
  - 13 Abr: Migración (Estrategia y Plan) — TDC, roadmap, cronograma
  - 17 Abr: Modelo Operativo y Gobierno — brechas, PMO extendida
  - 17 Abr: Riesgos — CNBV, cédula de evaluación, paternalidad
  - 17 Abr: Crédito Legacy — Pamela Cárdenas, estados de cuenta
  - 20 Abr: Roster — estructura, roles, dedicación
  - 20 Abr: Planeación próximas semanas — advisory vs assurance, fundaciones
  - 28 Abr: Testing — estrategia, herramientas, ambientes, defectos
  - 28 Abr: SmartVista interfaces — 8 batch interfaces, inventario
  - 29 Abr: Transact alineación semanal — roadmap, SIT/UAT, dependencias
"""
import sqlite3
from pathlib import Path

DB = Path(__file__).parent / "bank-brain.db"

DECISIONS = [
    # (id, date, topic, decision_text, driver_id_or_None, confidence)

    # ── Migración y roadmap ──────────────────────────────────────────────────
    ("SW2-DEC-0001", "2026-04-13", "migracion-tdc-produccion-r4",
     "La migración de tarjetas de crédito (TDC) a producción ocurrirá en R4 (diciembre 2026) sin excepción; "
     "ningún release anterior llevará TDC a producción.",
     "pablo-lorenzo", 0.90),

    ("SW2-DEC-0002", "2026-04-13", "poc-tdc-colaboradores-r3",
     "Se realizará una POC de migración TDC en R3 con un universo controlado de colaboradores internos "
     "antes del lanzamiento masivo en R4; esto mitiga el riesgo de un big-bang en producción.",
     "pablo-lorenzo", 0.80),

    ("SW2-DEC-0003", "2026-04-13", "estrategia-migracion-desactualizada-actualizar",
     "La estrategia de migración vigente contiene referencias desactualizadas a 2025 y múltiples versiones "
     "de propuestas iniciales; debe consolidarse en una versión final actualizada antes de usarse como base del roadmap.",
     None, 0.90),

    ("SW2-DEC-0004", "2026-03-24", "integracion-migracion-visibles-en-roadmap",
     "Integración con el legado y estrategia de migración deben aparecer como tópicos explícitos y priorizados "
     "en el roadmap de Unity; no pueden quedar como dependencias ocultas dentro de otros frentes.",
     None, 0.85),

    ("SW2-DEC-0005", "2026-04-29", "transact-friends-family-diferido-mayo",
     "La decisión sobre si Transact Préstamo Simple usará esquema 'friends and family' fue explícitamente "
     "diferida para revisión en mayo; no se tomará antes de esa fecha.",
     None, 0.85),

    ("SW2-DEC-0006", "2026-04-29", "arquitectura-transact-ampliada-prestamos-captacion",
     "La arquitectura de referencia de Unity para Transact fue ajustada por Angélica Tolosa para incluir "
     "préstamos y captación; la versión original estaba enfocada casi 100% en cuentas y no reflejaba el alcance real.",
     None, 0.90),

    # ── Gobernanza y modelo operativo ───────────────────────────────────────
    ("SW2-DEC-0007", "2026-04-20", "advisory-vs-assurance-distincion-formal",
     "El rol de Accenture en Unity se divide formalmente en Advisory (definición de estrategias técnicas, "
     "arquitectura, enfoques) y Assurance (seguimiento, control documental, métricas); el programa requiere "
     "mucho más Advisory que Assurance en las dimensiones críticas actuales.",
     "pablo-lorenzo", 0.95),

    ("SW2-DEC-0008", "2026-04-20", "tres-semanas-diagnostico-no-ejecucion",
     "Las tres semanas desde el 20 de abril están dedicadas a diagnóstico del estado real del programa y "
     "plan de remediación; no se ejecutarán soluciones finales ni se cerrarán todas las fundaciones en ese periodo.",
     "pablo-lorenzo", 0.95),

    ("SW2-DEC-0009", "2026-04-20", "takeover-condicional-cierre-brechas-bcp",
     "Accenture puede tomar la gobernanza del programa, pero el éxito depende de que BCP se comprometa "
     "formalmente a cerrar las brechas fundacionales identificadas; gobernar sin esos mínimos no asegura el éxito.",
     "pablo-lorenzo", 0.90),

    ("SW2-DEC-0010", "2026-04-20", "modelo-operativo-transformacion-bloqueo-critico",
     "El modelo operativo de transformación es el elemento fundacional más crítico de Unity: debe definirse "
     "antes que roles, estructura organizacional o cualquier otro fundacional; su ausencia bloquea el resto.",
     "pablo-lorenzo", 0.90),

    ("SW2-DEC-0011", "2026-04-20", "template-unico-diagnostico-fundacional",
     "Se construirá un template único de diagnóstico con esquema: To-Be ideal / mínimo indispensable para "
     "gobernar / estado actual / brecha / plan de remediación, para cada dimensión fundacional del programa.",
     "alejandro-gallegos", 0.85),

    ("SW2-DEC-0012", "2026-04-17", "change-management-dos-niveles-programa-y-release",
     "Change management se define con dos dimensiones independientes y no equivalentes: (1) change del "
     "programa completo — personas, moral, engagement, estabilidad — y (2) change por release específico "
     "— adopción y comunicación del release; confundirlos genera esfuerzos mal dirigidos.",
     "pablo-lorenzo", 0.85),

    ("SW2-DEC-0013", "2026-03-24", "inexistencia-documentacion-es-hallazgo-valido",
     "El RFI no fabricará documentos inexistentes; si un artefacto no existe, ese hecho se registra como "
     "hallazgo de madurez del programa; mapear ausencias es tan valioso como mapear presencias.",
     "alejandro-gallegos", 0.95),

    ("SW2-DEC-0014", "2026-03-24", "roadmap-junta-debe-incluir-supuestos-y-riesgos",
     "El roadmap presentado el 24 de abril a la junta directiva debe incluir explícitamente supuestos, "
     "hipótesis de trabajo y riesgos; no puede presentarse como plan sin condicionantes porque elaborar "
     "un plan de 3-4 años en pocas semanas requiere asumir muchas cosas.",
     "daniel-angeles", 0.90),

    ("SW2-DEC-0015", "2026-04-07", "planview-siendo-discontinuado",
     "Planview, la herramienta actual de gestión de iniciativas estratégicas y seguimiento de portafolio, "
     "está siendo eliminada ('se va a morir'); la transición a otra herramienta no está aún explicitada.",
     None, 0.80),

    ("SW2-DEC-0016", "2026-03-24", "berenice-aguilar-contraparte-unica-transact",
     "Berenice Aguilar Estrada fue designada como la responsable única (single point of contact) de negocio "
     "para el stream Transact, aunque existan otros product owners; esto da claridad de interlocución.",
     None, 0.85),

    ("SW2-DEC-0017", "2026-04-07", "unity-requiere-contraparte-negocio-para-endorsement",
     "El proyecto de aceleración no debe tener visto bueno únicamente desde delivery/tecnología; se requiere "
     "una contraparte de negocio (propuesta: Sergio del Valle) que valide los avances desde perspectiva comercial.",
     "alejandro-gallegos", 0.80),

    # ── Testing y calidad ───────────────────────────────────────────────────
    ("SW2-DEC-0018", "2026-04-28", "migracion-gestion-pruebas-a-xray",
     "La gestión de casos de prueba migrará de Value Edge a X-ray (integrado en Jira) para eliminar "
     "dashboards externos y unificar el proceso de calidad en una sola herramienta.",
     None, 0.85),

    ("SW2-DEC-0019", "2026-04-28", "ambientes-qa-separados-por-producto-antes-eit",
     "Se habilitarán ambientes de QA independientes por producto (BPC, Launch, OPI, SEW, Apolo) para "
     "que cada equipo pruebe en ambiente completo antes de llegar al ambiente integrado homologado (EIT).",
     None, 0.80),

    ("SW2-DEC-0020", "2026-04-28", "qa-team-size-adecuado-cuello-botella-es-dev",
     "El equipo de QA tiene suficientes FTEs; incrementar su capacidad generaría inactividad porque "
     "el equipo de desarrollo no podría resolver más defectos en paralelo; el cuello de botella está "
     "en dev, no en QA.",
     None, 0.85),

    ("SW2-DEC-0021", "2026-04-29", "modelo-sit-3m-uat-3m-tres-ciclos-transact",
     "Se adopta un modelo de tres meses para SIT y tres meses para UAT (organizados en tres ciclos cada "
     "uno) para los releases de Transact; el testing no funcional (seguridad y performance) corre "
     "en paralelo a SIT y UAT, no en secuencia.",
     "pablo-lorenzo", 0.80),

    ("SW2-DEC-0022", "2026-04-29", "simulacros-produccion-incluidos-en-releases",
     "Se incluirán simulacros de producción (production rehearsals) en el proceso de Go-Live dado que "
     "actualmente no existe un equipo de deployment con visión integral del proceso de puesta en producción.",
     "pablo-lorenzo", 0.75),

    # ── Talento y estructura ─────────────────────────────────────────────────
    ("SW2-DEC-0023", "2026-04-13", "estructura-talento-unity-no-declarada-formalmente",
     "Al crear el programa Unity no se declaró una estructura formal de personas; muchos recursos "
     "operan desde otras adscripciones o roles originales distintos; la formalización de pertenencia "
     "y dedicación es prioridad antes de cerrar cualquier otra alineación.",
     None, 0.95),

    ("SW2-DEC-0024", "2026-04-13", "cynthia-rh-tecnologia-noemi-negocio-unity",
     "Cynthia Ramirez Mejia es el punto de contacto de RH para aproximadamente el 90% de la población "
     "tecnológica de Unity; Noemí (otra BP) cubre el frente de negocio; ambas son necesarias para "
     "completar la visión total de talento del programa.",
     None, 0.95),

    # ── SmartVista / integración ─────────────────────────────────────────────
    ("SW2-DEC-0025", "2026-04-28", "smartvista-8-interfaces-batch-3-produccion",
     "SmartVista tiene exactamente 8 interfaces batch (procesos offline/batch, no APIs en línea): "
     "3 ya en ambiente productivo, 5 en ambiente dev esperando el roadmap del equipo de tarjeta de "
     "crédito (José Jaimes); su liberación depende del roadmap del equipo TDC.",
     None, 0.95),
]

POSITIONS = [
    # (stakeholder_id, topic, stance_text, sentiment, date)

    ("juan-manuel", "metodologia-gestion-unity",
     "Desconfía de que un programa de transformación de esta magnitud deba gestionarse con enfoque "
     "ágil ni dentro de los value streams existentes; propone esquema separado potencialmente waterfall "
     "o híbrido, especialmente para Transact.",
     "skeptical", "2026-04-07"),

    ("pablo-lorenzo", "takeover-gobernanza-unity",
     "El takeover de gobernanza solo es viable si va acompañado de remediación real de las fundaciones; "
     "no puede prometerse éxito solo con gobierno sin resolver las carencias estructurales; no prometerá "
     "ejecuciones que Accenture no pueda cumplir en capacidad o perfiles.",
     "cautious", "2026-04-20"),

    ("lukasz-pietrzyk", "estrategia-pruebas-unity",
     "Activamente cuestiona qué de la estrategia de pruebas se aplica 100%, qué está parcialmente "
     "implementado y qué no existe; observó que cada track gestiona integraciones de forma distinta "
     "sin repositorio común — gap fundacional del programa.",
     "critical", "2026-04-28"),

    ("arcadio", "arquitectura-empresarial-unity",
     "Responsable de la Arquitectura Empresarial; conoce la arquitectura de todo el banco incluyendo "
     "sistemas legacy (PISA), y certifica arquitecturas; se espera mayor involucramiento en sesiones "
     "técnicas de Unity del que ha tenido hasta ahora.",
     "neutral", "2026-03-24"),

    ("erica-mata", "seguridad-cumplimiento-regulatorio-unity",
     "El tema de seguridad y cumplimiento normativo tiene mucho peso en el banco; es la persona clave "
     "(CISO) para ese frente en Unity; debe incluirse en el programa de forma estructurada y desde el "
     "inicio, no de forma reactiva cuando ya hay problemas.",
     "concerned", "2026-03-24"),

    ("arturo-perez", "operacion-legado-pisa",
     "Responsable de la operación y administración de todos los sistemas que dependen del core actual "
     "PISA, incluyendo el servicio Spay; sus gerentes manejan componentes específicos (cajeros, "
     "sucursales, corresponsalías, captación); detenta el conocimiento crítico del legado que "
     "nadie más puede proveer fácilmente.",
     "neutral", "2026-03-24"),

    ("daniel-angeles", "roadmap-largo-plazo-unity",
     "Elaborar un plan de despliegue a tres o cuatro años en pocas semanas es una 'misión imposible'; "
     "insiste en que el roadmap incluya explícitamente supuestos, hipótesis y riesgos para proteger "
     "compromisos futuros; las 'claves de éxito' deben identificarse para que la fecha propuesta sea alcanzable.",
     "concerned", "2026-03-24"),

    ("luis-barragan", "estrategia-tecnica-apolo-smartvista",
     "Identificado como la mejor contraparte para la estrategia técnica de Apolo y SmartVista por "
     "afinidad de lenguaje técnico; Miguel Bucio (homologación de entornos) le reporta, lo que "
     "requiere un ajuste en el organigrama de gobernanza para reflejar esta relación correctamente.",
     "supportive", "2026-03-24"),

    ("alejandro-gallegos", "metodologia-diagnostico-rfi",
     "Establece que la inexistencia de documentación es un hallazgo válido del RFI; prioriza mapear "
     "la madurez real del programa sobre forzar documentos inexistentes; insiste en distinguir entre "
     "recursos 100% dedicados y recursos parciales como requerimiento mínimo del roster.",
     "constructive", "2026-04-13"),

    ("rodrigo", "diagnostico-unity",
     "Diseñó el instrumento de diagnóstico de Unity con alcance mucho más amplio de lo esperado: "
     "cubre gestión, talento, roles, experiencia de personas y situación general del programa, "
     "no solo change management; su diagnóstico es el insumo real para nutrir las acciones pendientes.",
     "constructive", "2026-03-24"),

    ("carlos-bc", "comite-estatus-bi-semanal",
     "Preside el comité de estatus cada dos semanas con 57 participantes; lo usa como mecanismo de "
     "presión principal donde se plantean 'pains' y dependencias no cumplidas; el nivel de presión "
     "es alto y obliga a los equipos a 'ponerse las pilas'.",
     "demanding", "2026-04-28"),

    ("pablo-lorenzo", "oportunidad-estrategica-unity-accenture",
     "Identifica Unity como caso piloto para fortalecer las capacidades de banking en México dentro "
     "de Accenture; ve la oportunidad más allá del engagement actual como desarrollo de capacidad "
     "institucional de la práctica.",
     "positive", "2026-04-20"),

    ("lukasz-pietrzyk", "integracion-fragmentada-unity",
     "Observó que no existe un repositorio común de integraciones; cada track (Transact, Apolo, "
     "SmartVista) administra sus integraciones de forma distinta y con formatos distintos; "
     "esto es una brecha fundacional que bloquea la visibilidad end-to-end.",
     "concerned", "2026-04-28"),

    ("daniel-angeles", "modelo-operativo-ti-existente",
     "Aclara que los procesos de gestión de TI ya existentes (cambios, requerimientos, incidentes, "
     "problemas) están definidos y se usarán igual para Unity; no se inventan procesos nuevos; "
     "sugiere a Octavio para operación de producción Unity y a Rogelio Aguayo para legacy.",
     "constructive", "2026-03-24"),

    ("arturo-perez", "conocimiento-legado-pisa-concentrado",
     "El banco conserva 80-90% del conocimiento sobre el sistema legado concentrado en gerentes "
     "y coordinadores; hay documentación pero la mayor parte de la lógica de negocio vive en los "
     "~12,000 SPLs y se ha transferido parcialmente al equipo de operación.",
     "neutral", "2026-03-24"),

    ("erica-mata", "proceso-autorizacion-cnbv-unity",
     "La Dirección de Riesgos se activa principalmente cuando se requiere notificación a la CNBV; "
     "el proceso requiere Cédula de Evaluación con vistos buenos de seguridad, jurídico y procesos "
     "operativos; actualmente falta un responsable integral que asegure que nadie omita requisitos críticos.",
     "concerned", "2026-04-17"),

    ("alejandro-gallegos", "gobierno-aceleracion-plan-director",
     "Establece que la fase de aceleración de seis semanas tiene dos objetivos: hacer un diligence "
     "del gobierno del Plan Director y revisar definiciones estratégicas (arquitectura futura, modelo "
     "de operación, roadmap Unity); las primeras semanas son diagnóstico, no ejecución de soluciones.",
     "constructive", "2026-04-13"),

    ("carlos-bc", "transparencia-reporting-testing",
     "El dashboard de pruebas y defectos está disponible para todos los stakeholders incluyendo al "
     "director de transformación; el comité bi-semanal presenta un estado cerrado, sin sorpresas; "
     "la transparencia es un mecanismo de control que Carlos mantiene activo deliberadamente.",
     "neutral", "2026-04-28"),
]

OPEN_ITEMS = [
    # (id, date, item_text, owner_id_or_None, priority, systems_json_array)

    ("SW2-OI-0001", "2026-04-13",
     "Lanzar encuesta breve de dedicación al proyecto Unity para la semana del 13-17 de abril; "
     "cubrir toda la población de tecnología gestionada por Cynthia Ramirez; obtener porcentaje "
     "real de dedicación de cada recurso.",
     None, "high", '["Unity"]'),

    ("SW2-OI-0002", "2026-04-13",
     "Coordinar el levantamiento de dedicación con Daniel Gabino para integrar alcance de tecnología "
     "y negocio bajo un mismo esfuerzo; evitar encuestas duplicadas entre Cynthia y Tere/Kennedy.",
     None, "high", '["Unity"]'),

    ("SW2-OI-0003", "2026-04-13",
     "Construir y acordar el TO-BE de la Dirección de Transformación de Pablo Lorenzo: definir "
     "gerencias de desarrollo, roles de seguridad y niveles inferiores al primer reporte; "
     "actualmente solo existe un AS-IS basado en roles de Plataformas Digitales y Sistemas.",
     "pablo-lorenzo", "high", '["Unity"]'),

    ("SW2-OI-0004", "2026-04-13",
     "Evaluar e incorporar al menos uno o dos KPIs/objetivos de Unity al ciclo de desempeño 2026 "
     "que arranca en mayo; definir un esquema híbrido de seguimiento para personas dedicadas y parciales; "
     "este es apenas el tercer año de medición formal de desempeño en la compañía.",
     None, "medium", '["Unity"]'),

    ("SW2-OI-0005", "2026-04-13",
     "Actualizar y consolidar la estrategia de migración: eliminar referencias desactualizadas a 2025, "
     "incorporar el plan de débito, y entregar versión unificada antes del viernes; los estimados de "
     "vendors (IWI, Awine) deben validarse internamente en testing global.",
     "pablo-lorenzo", "high", '["Atlas", "SmartVista/BPC", "Transact"]'),

    ("SW2-OI-0006", "2026-04-20",
     "Construir template único de diagnóstico fundacional (To-Be ideal / mínimo operativo / brechas) "
     "por cada dimensión del programa; cada responsable ACN llena su parte para integrarse en una "
     "vista única antes de la sesión con Navas.",
     "alejandro-gallegos", "high", '["Unity"]'),

    ("SW2-OI-0007", "2026-04-20",
     "Realizar working session con Pavel el martes y miércoles de la semana del 20 de abril; después "
     "sesión con José Luis Navas el jueves con propuesta sólida y consensuada; evitar percepción de "
     "improvisación en la presentación ejecutiva.",
     "pablo-lorenzo", "high", '["Unity"]'),

    ("SW2-OI-0008", "2026-04-29",
     "Mapear todas las dependencias críticas entre Transact y el sistema legado (ejemplos: Western Union, "
     "recargas); el legado es una 'caja gris' que dificulta construir el roadmap; Gloria debe detallar "
     "el estado y naturaleza de cada dependencia crítica.",
     None, "high", '["PISA/Informix", "Transact"]'),

    ("SW2-OI-0009", "2026-04-28",
     "Oscar Melo y Eduardo Ponce deben compartir el inventario Excel completo de las 8 interfaces batch "
     "de SmartVista (con prioridades, objetivos, funcionalidades, identificadores) más los archivos "
     "Drawio originales de los diagramas; los PDFs actuales no permiten visualización adecuada.",
     None, "high", '["SmartVista/BPC"]'),

    ("SW2-OI-0010", "2026-04-29",
     "Angélica Tolosa debe entregar el trazado de capacidades de arquitectura por release (graduation "
     "diagram: qué capacidades se activan en cada release de Transact) para el jueves; debe incluir "
     "préstamos y captación, no solo cuentas.",
     None, "high", '["Transact"]'),

    ("SW2-OI-0011", "2026-04-28",
     "Actualizar el documento de estrategia de pruebas (tiene 4 años de antigüedad): reflejar estado "
     "actual de gestión, herramientas vigentes (eliminar Value Edge obsoleto), diagramas de entornos "
     "actualizados, y estado real de automatización (Python, Postman, Appium, framework TAS).",
     None, "medium", '["Unity"]'),

    ("SW2-OI-0012", "2026-04-28",
     "Habilitar ambientes de QA separados por producto (BPC, Launch, OPI, SEW, Apolo) antes de llegar "
     "al EIT; iniciar conversaciones con Andrés, Miguel Bucio y Daniel Ángeles del Mesaní para "
     "definir plan de habilitación.",
     None, "high", '["SmartVista/BPC", "Apolo"]'),

    ("SW2-OI-0013", "2026-04-28",
     "Migrar la gestión de casos de prueba de Value Edge a X-ray (integrado en Jira) para eliminar "
     "dashboards externos; definir plan de transición que no afecte los ciclos activos de prueba.",
     None, "medium", '["Unity"]'),

    ("SW2-OI-0014", "2026-04-20",
     "Definir el North Star de negocio de Unity: visión end-to-end, cross-producto, priorizada; "
     "traducirla en journeys, funcionalidades y prioridades concretas; requiere workshops estructurados "
     "con negocio y tecnología, no reuniones regulares.",
     "pablo-lorenzo", "high", '["Unity", "Transact", "Apolo", "SmartVista/BPC"]'),

    ("SW2-OI-0015", "2026-04-17",
     "Designar un responsable integral ('paternalidad') para asegurar que la Cédula de Evaluación "
     "de Riesgos para CNBV esté completa y actualizada; actualmente nadie tiene visión end-to-end "
     "de la documentación regulatoria de Unity y hay riesgo de omisión de requisitos críticos.",
     None, "high", '["Unity"]'),

    ("SW2-OI-0016", "2026-04-17",
     "Formalizar el plan de DRP y BCP para los componentes de Unity: integrar la dimensión tecnológica "
     "(DRP) y la de procesos (BCP); actualmente no están integradas y la resiliencia operativa no "
     "está completamente estructurada.",
     None, "high", '["Unity", "Transact", "Apolo", "SmartVista/BPC"]'),

    ("SW2-OI-0017", "2026-03-24",
     "Revisar el diagnóstico de Rodrigo Kennedy con el equipo ACN para nutrir acciones pendientes; "
     "su diagnóstico tiene alcance más amplio de lo esperado (gobierno, talento, roles, experiencia "
     "del equipo, situación general del programa); usarlo como insumo real, no como presentación.",
     "alejandro-gallegos", "medium", '["Unity"]'),

    ("SW2-OI-0018", "2026-04-13",
     "Obtener el contacto de Noemí (business partner de negocio para Unity) a través de José Emiliano "
     "y agendar una sesión equivalente a la de Cynthia para completar la visión total de talento "
     "del programa incluyendo el frente de negocio.",
     None, "medium", '["Unity"]'),

    ("SW2-OI-0019", "2026-04-29",
     "Pablo Lorenzo debe crear diapositivas para explicar el mapa de ruta integrado, incluyendo "
     "documentación explícita de riesgos e hipótesis (assumptions) que justifiquen posibles retrasos "
     "futuros; las hipótesis deben apuntar a dependencias críticas como estabilidad del ambiente "
     "homologado antes de SIT.",
     "pablo-lorenzo", "high", '["Unity", "Transact"]'),

    ("SW2-OI-0020", "2026-04-29",
     "Socializar versión estable del roadmap integrado el martes siguiente; revisar el mapeo de "
     "arquitectura con el equipo Transact; coordinar revisión del modelo de capacidades activadas "
     "por release.",
     "pablo-lorenzo", "high", '["Unity", "Transact", "SmartVista/BPC", "Apolo"]'),

    ("SW2-OI-0021", "2026-04-29",
     "Sandra Figueroa y Araceli Barcena deben buscar documentación para reforzar la lista de "
     "dependencias críticas del legado con Transact; coordinar con Angélica Tolosa y Gloria para "
     "tener inventario completo.",
     None, "medium", '["PISA/Informix", "Transact"]'),

    ("SW2-OI-0022", "2026-03-24",
     "Definir estrategia de migración de datos Informix: determinar qué datos históricos permanecen "
     "on-premise y cuáles (clientes activos, saldos) migran a la nube; actualmente la estrategia "
     "no está definida y la latencia Informix bloquea el avance de la migración a nube.",
     None, "high", '["PISA/Informix", "Atlas"]'),

    ("SW2-OI-0023", "2026-04-28",
     "Definir SLAs realistas para resolución de defectos: los SLAs actuales (ej. 4 horas para defecto "
     "crítico) nunca se cumplen pero nadie ha propuesto alternativas; la deuda de incumplimiento acumulada "
     "no se está gestionando formalmente.",
     None, "medium", '["Unity"]'),

    ("SW2-OI-0024", "2026-04-07",
     "Incorporar a Sergio del Valle (o equivalente) como contraparte de negocio en el proyecto de "
     "aceleración; actualmente los avances solo tienen visto bueno desde delivery/tecnología, "
     "lo que limita la legitimidad del programa ante el frente de negocio.",
     "alejandro-gallegos", "medium", '["Unity"]'),
]


def run():
    db = sqlite3.connect(str(DB))
    db.execute("PRAGMA foreign_keys=ON")
    n_dec = n_pos = n_oi = 0
    for row in DECISIONS:
        try:
            db.execute(
                "INSERT OR IGNORE INTO decisions (id,date,topic,decision,driver_id,systems,doc_id,confidence)"
                " VALUES (?,?,?,?,?,?,NULL,?)",
                (row[0], row[1], row[2], row[3], row[4], f'["{row[2]}"]', row[5])
            )
            if db.execute("SELECT changes()").fetchone()[0]:
                n_dec += 1
        except Exception:
            pass
    for row in POSITIONS:
        try:
            db.execute(
                "INSERT INTO positions (stakeholder_id,topic,stance,quote,date,doc_id,sentiment)"
                " VALUES (?,?,?,?,?,NULL,?)",
                (row[0], row[1], row[2], row[2][:100], row[4], row[3])
            )
            n_pos += 1
        except Exception:
            pass
    for row in OPEN_ITEMS:
        try:
            db.execute(
                "INSERT OR IGNORE INTO open_items (id,date,item,owner_id,priority,systems,doc_id,status)"
                " VALUES (?,?,?,?,?,?,NULL,'open')",
                (row[0], row[1], row[2], row[3], row[4], row[5])
            )
            if db.execute("SELECT changes()").fetchone()[0]:
                n_oi += 1
        except Exception:
            pass
    db.commit()
    print(f"Swarm G2: {n_dec} decisiones · {n_pos} posiciones · {n_oi} open items insertados")
    db.close()


if __name__ == "__main__":
    run()
