"""seed-swarm-2.py â€” Grupo 2 swarm extracciÃ³n estratÃ©gica Bank Brain BanCoppel

Fuentes procesadas (minutas mar-abr 2026):
  - 24 Mar: Almaguer â€” integraciÃ³n/migraciÃ³n, legacy, cloud
  - 24 Mar: Tere Gonzalez â€” RFI, gobierno, mapa stakeholders
  - 24 Mar: Daniel Ãngeles â€” arquitectura, roles TI, modelo operativo
  - 07 Abr: Value Streams â€” modelo operativo actual vs separaciÃ³n Unity
  - 13 Abr: GestiÃ³n de Talento TI â€” estructura, dedicaciÃ³n, RH
  - 13 Abr: MigraciÃ³n (Estrategia y Plan) â€” TDC, roadmap, cronograma
  - 17 Abr: Modelo Operativo y Gobierno â€” brechas, PMO extendida
  - 17 Abr: Riesgos â€” CNBV, cÃ©dula de evaluaciÃ³n, paternalidad
  - 17 Abr: CrÃ©dito Legacy â€” Pamela CÃ¡rdenas, estados de cuenta
  - 20 Abr: Roster â€” estructura, roles, dedicaciÃ³n
  - 20 Abr: PlaneaciÃ³n prÃ³ximas semanas â€” advisory vs assurance, fundaciones
  - 28 Abr: Testing â€” estrategia, herramientas, ambientes, defectos
  - 28 Abr: SmartVista interfaces â€” 8 batch interfaces, inventario
  - 29 Abr: Transact alineaciÃ³n semanal â€” roadmap, SIT/UAT, dependencias
"""
import sqlite3
from pathlib import Path

DB = Path(__file__).parent.parent / "digital-brain" / "bank-brain.db"

DECISIONS = [
    # (id, date, topic, decision_text, driver_id_or_None, confidence)

    # â”€â”€ MigraciÃ³n y roadmap â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("SW2-DEC-0001", "2026-04-13", "migracion-tdc-produccion-r4",
     "La migraciÃ³n de tarjetas de crÃ©dito (TDC) a producciÃ³n ocurrirÃ¡ en R4 (diciembre 2026) sin excepciÃ³n; "
     "ningÃºn release anterior llevarÃ¡ TDC a producciÃ³n.",
     "pablo-lorenzo", 0.90),

    ("SW2-DEC-0002", "2026-04-13", "poc-tdc-colaboradores-r3",
     "Se realizarÃ¡ una POC de migraciÃ³n TDC en R3 con un universo controlado de colaboradores internos "
     "antes del lanzamiento masivo en R4; esto mitiga el riesgo de un big-bang en producciÃ³n.",
     "pablo-lorenzo", 0.80),

    ("SW2-DEC-0003", "2026-04-13", "estrategia-migracion-desactualizada-actualizar",
     "La estrategia de migraciÃ³n vigente contiene referencias desactualizadas a 2025 y mÃºltiples versiones "
     "de propuestas iniciales; debe consolidarse en una versiÃ³n final actualizada antes de usarse como base del roadmap.",
     None, 0.90),

    ("SW2-DEC-0004", "2026-03-24", "integracion-migracion-visibles-en-roadmap",
     "IntegraciÃ³n con el legado y estrategia de migraciÃ³n deben aparecer como tÃ³picos explÃ­citos y priorizados "
     "en el roadmap de Unity; no pueden quedar como dependencias ocultas dentro de otros frentes.",
     None, 0.85),

    ("SW2-DEC-0005", "2026-04-29", "transact-friends-family-diferido-mayo",
     "La decisiÃ³n sobre si Transact PrÃ©stamo Simple usarÃ¡ esquema 'friends and family' fue explÃ­citamente "
     "diferida para revisiÃ³n en mayo; no se tomarÃ¡ antes de esa fecha.",
     None, 0.85),

    ("SW2-DEC-0006", "2026-04-29", "arquitectura-transact-ampliada-prestamos-captacion",
     "La arquitectura de referencia de Unity para Transact fue ajustada por AngÃ©lica Tolosa para incluir "
     "prÃ©stamos y captaciÃ³n; la versiÃ³n original estaba enfocada casi 100% en cuentas y no reflejaba el alcance real.",
     None, 0.90),

    # â”€â”€ Gobernanza y modelo operativo â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("SW2-DEC-0007", "2026-04-20", "advisory-vs-assurance-distincion-formal",
     "El rol de Accenture en Unity se divide formalmente en Advisory (definiciÃ³n de estrategias tÃ©cnicas, "
     "arquitectura, enfoques) y Assurance (seguimiento, control documental, mÃ©tricas); el programa requiere "
     "mucho mÃ¡s Advisory que Assurance en las dimensiones crÃ­ticas actuales.",
     "pablo-lorenzo", 0.95),

    ("SW2-DEC-0008", "2026-04-20", "tres-semanas-diagnostico-no-ejecucion",
     "Las tres semanas desde el 20 de abril estÃ¡n dedicadas a diagnÃ³stico del estado real del programa y "
     "plan de remediaciÃ³n; no se ejecutarÃ¡n soluciones finales ni se cerrarÃ¡n todas las fundaciones en ese periodo.",
     "pablo-lorenzo", 0.95),

    ("SW2-DEC-0009", "2026-04-20", "takeover-condicional-cierre-brechas-bcp",
     "Accenture puede tomar la gobernanza del programa, pero el Ã©xito depende de que BCP se comprometa "
     "formalmente a cerrar las brechas fundacionales identificadas; gobernar sin esos mÃ­nimos no asegura el Ã©xito.",
     "pablo-lorenzo", 0.90),

    ("SW2-DEC-0010", "2026-04-20", "modelo-operativo-transformacion-bloqueo-critico",
     "El modelo operativo de transformaciÃ³n es el elemento fundacional mÃ¡s crÃ­tico de Unity: debe definirse "
     "antes que roles, estructura organizacional o cualquier otro fundacional; su ausencia bloquea el resto.",
     "pablo-lorenzo", 0.90),

    ("SW2-DEC-0011", "2026-04-20", "template-unico-diagnostico-fundacional",
     "Se construirÃ¡ un template Ãºnico de diagnÃ³stico con esquema: To-Be ideal / mÃ­nimo indispensable para "
     "gobernar / estado actual / brecha / plan de remediaciÃ³n, para cada dimensiÃ³n fundacional del programa.",
     "alejandro-gallegos", 0.85),

    ("SW2-DEC-0012", "2026-04-17", "change-management-dos-niveles-programa-y-release",
     "Change management se define con dos dimensiones independientes y no equivalentes: (1) change del "
     "programa completo â€” personas, moral, engagement, estabilidad â€” y (2) change por release especÃ­fico "
     "â€” adopciÃ³n y comunicaciÃ³n del release; confundirlos genera esfuerzos mal dirigidos.",
     "pablo-lorenzo", 0.85),

    ("SW2-DEC-0013", "2026-03-24", "inexistencia-documentacion-es-hallazgo-valido",
     "El RFI no fabricarÃ¡ documentos inexistentes; si un artefacto no existe, ese hecho se registra como "
     "hallazgo de madurez del programa; mapear ausencias es tan valioso como mapear presencias.",
     "alejandro-gallegos", 0.95),

    ("SW2-DEC-0014", "2026-03-24", "roadmap-junta-debe-incluir-supuestos-y-riesgos",
     "El roadmap presentado el 24 de abril a la junta directiva debe incluir explÃ­citamente supuestos, "
     "hipÃ³tesis de trabajo y riesgos; no puede presentarse como plan sin condicionantes porque elaborar "
     "un plan de 3-4 aÃ±os en pocas semanas requiere asumir muchas cosas.",
     "daniel-angeles", 0.90),

    ("SW2-DEC-0015", "2026-04-07", "planview-siendo-discontinuado",
     "Planview, la herramienta actual de gestiÃ³n de iniciativas estratÃ©gicas y seguimiento de portafolio, "
     "estÃ¡ siendo eliminada ('se va a morir'); la transiciÃ³n a otra herramienta no estÃ¡ aÃºn explicitada.",
     None, 0.80),

    ("SW2-DEC-0016", "2026-03-24", "berenice-aguilar-contraparte-unica-transact",
     "Berenice Aguilar Estrada fue designada como la responsable Ãºnica (single point of contact) de negocio "
     "para el stream Transact, aunque existan otros product owners; esto da claridad de interlocuciÃ³n.",
     None, 0.85),

    ("SW2-DEC-0017", "2026-04-07", "unity-requiere-contraparte-negocio-para-endorsement",
     "El proyecto de aceleraciÃ³n no debe tener visto bueno Ãºnicamente desde delivery/tecnologÃ­a; se requiere "
     "una contraparte de negocio (propuesta: Sergio del Valle) que valide los avances desde perspectiva comercial.",
     "alejandro-gallegos", 0.80),

    # â”€â”€ Testing y calidad â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("SW2-DEC-0018", "2026-04-28", "migracion-gestion-pruebas-a-xray",
     "La gestiÃ³n de casos de prueba migrarÃ¡ de Value Edge a X-ray (integrado en Jira) para eliminar "
     "dashboards externos y unificar el proceso de calidad en una sola herramienta.",
     None, 0.85),

    ("SW2-DEC-0019", "2026-04-28", "ambientes-qa-separados-por-producto-antes-eit",
     "Se habilitarÃ¡n ambientes de QA independientes por producto (BPC, Launch, OPI, SEW, Apolo) para "
     "que cada equipo pruebe en ambiente completo antes de llegar al ambiente integrado homologado (EIT).",
     None, 0.80),

    ("SW2-DEC-0020", "2026-04-28", "qa-team-size-adecuado-cuello-botella-es-dev",
     "El equipo de QA tiene suficientes FTEs; incrementar su capacidad generarÃ­a inactividad porque "
     "el equipo de desarrollo no podrÃ­a resolver mÃ¡s defectos en paralelo; el cuello de botella estÃ¡ "
     "en dev, no en QA.",
     None, 0.85),

    ("SW2-DEC-0021", "2026-04-29", "modelo-sit-3m-uat-3m-tres-ciclos-transact",
     "Se adopta un modelo de tres meses para SIT y tres meses para UAT (organizados en tres ciclos cada "
     "uno) para los releases de Transact; el testing no funcional (seguridad y performance) corre "
     "en paralelo a SIT y UAT, no en secuencia.",
     "pablo-lorenzo", 0.80),

    ("SW2-DEC-0022", "2026-04-29", "simulacros-produccion-incluidos-en-releases",
     "Se incluirÃ¡n simulacros de producciÃ³n (production rehearsals) en el proceso de Go-Live dado que "
     "actualmente no existe un equipo de deployment con visiÃ³n integral del proceso de puesta en producciÃ³n.",
     "pablo-lorenzo", 0.75),

    # â”€â”€ Talento y estructura â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("SW2-DEC-0023", "2026-04-13", "estructura-talento-unity-no-declarada-formalmente",
     "Al crear el programa Unity no se declarÃ³ una estructura formal de personas; muchos recursos "
     "operan desde otras adscripciones o roles originales distintos; la formalizaciÃ³n de pertenencia "
     "y dedicaciÃ³n es prioridad antes de cerrar cualquier otra alineaciÃ³n.",
     None, 0.95),

    ("SW2-DEC-0024", "2026-04-13", "cynthia-rh-tecnologia-noemi-negocio-unity",
     "Cynthia Ramirez Mejia es el punto de contacto de RH para aproximadamente el 90% de la poblaciÃ³n "
     "tecnolÃ³gica de Unity; NoemÃ­ (otra BP) cubre el frente de negocio; ambas son necesarias para "
     "completar la visiÃ³n total de talento del programa.",
     None, 0.95),

    # â”€â”€ SmartVista / integraciÃ³n â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("SW2-DEC-0025", "2026-04-28", "smartvista-8-interfaces-batch-3-produccion",
     "SmartVista tiene exactamente 8 interfaces batch (procesos offline/batch, no APIs en lÃ­nea): "
     "3 ya en ambiente productivo, 5 en ambiente dev esperando el roadmap del equipo de tarjeta de "
     "crÃ©dito (JosÃ© Jaimes); su liberaciÃ³n depende del roadmap del equipo TDC.",
     None, 0.95),
]

POSITIONS = [
    # (stakeholder_id, topic, stance_text, sentiment, date)

    ("juan-manuel", "metodologia-gestion-unity",
     "DesconfÃ­a de que un programa de transformaciÃ³n de esta magnitud deba gestionarse con enfoque "
     "Ã¡gil ni dentro de los value streams existentes; propone esquema separado potencialmente waterfall "
     "o hÃ­brido, especialmente para Transact.",
     "skeptical", "2026-04-07"),

    ("pablo-lorenzo", "takeover-gobernanza-unity",
     "El takeover de gobernanza solo es viable si va acompaÃ±ado de remediaciÃ³n real de las fundaciones; "
     "no puede prometerse Ã©xito solo con gobierno sin resolver las carencias estructurales; no prometerÃ¡ "
     "ejecuciones que Accenture no pueda cumplir en capacidad o perfiles.",
     "cautious", "2026-04-20"),

    ("lukasz-pietrzyk", "estrategia-pruebas-unity",
     "Activamente cuestiona quÃ© de la estrategia de pruebas se aplica 100%, quÃ© estÃ¡ parcialmente "
     "implementado y quÃ© no existe; observÃ³ que cada track gestiona integraciones de forma distinta "
     "sin repositorio comÃºn â€” gap fundacional del programa.",
     "critical", "2026-04-28"),

    ("arcadio", "arquitectura-empresarial-unity",
     "Responsable de la Arquitectura Empresarial; conoce la arquitectura de todo el banco incluyendo "
     "sistemas legacy (PISA), y certifica arquitecturas; se espera mayor involucramiento en sesiones "
     "tÃ©cnicas de Unity del que ha tenido hasta ahora.",
     "neutral", "2026-03-24"),

    ("erica-mata", "seguridad-cumplimiento-regulatorio-unity",
     "El tema de seguridad y cumplimiento normativo tiene mucho peso en el banco; es la persona clave "
     "(CISO) para ese frente en Unity; debe incluirse en el programa de forma estructurada y desde el "
     "inicio, no de forma reactiva cuando ya hay problemas.",
     "concerned", "2026-03-24"),

    ("arturo-perez", "operacion-legado-pisa",
     "Responsable de la operaciÃ³n y administraciÃ³n de todos los sistemas que dependen del core actual "
     "PISA, incluyendo el servicio Spay; sus gerentes manejan componentes especÃ­ficos (cajeros, "
     "sucursales, corresponsalÃ­as, captaciÃ³n); detenta el conocimiento crÃ­tico del legado que "
     "nadie mÃ¡s puede proveer fÃ¡cilmente.",
     "neutral", "2026-03-24"),

    ("daniel-angeles", "roadmap-largo-plazo-unity",
     "Elaborar un plan de despliegue a tres o cuatro aÃ±os en pocas semanas es una 'misiÃ³n imposible'; "
     "insiste en que el roadmap incluya explÃ­citamente supuestos, hipÃ³tesis y riesgos para proteger "
     "compromisos futuros; las 'claves de Ã©xito' deben identificarse para que la fecha propuesta sea alcanzable.",
     "concerned", "2026-03-24"),

    ("luis-barragan", "estrategia-tecnica-apolo-smartvista",
     "Identificado como la mejor contraparte para la estrategia tÃ©cnica de Apolo y SmartVista por "
     "afinidad de lenguaje tÃ©cnico; Miguel Bucio (homologaciÃ³n de entornos) le reporta, lo que "
     "requiere un ajuste en el organigrama de gobernanza para reflejar esta relaciÃ³n correctamente.",
     "supportive", "2026-03-24"),

    ("alejandro-gallegos", "metodologia-diagnostico-rfi",
     "Establece que la inexistencia de documentaciÃ³n es un hallazgo vÃ¡lido del RFI; prioriza mapear "
     "la madurez real del programa sobre forzar documentos inexistentes; insiste en distinguir entre "
     "recursos 100% dedicados y recursos parciales como requerimiento mÃ­nimo del roster.",
     "constructive", "2026-04-13"),

    ("rodrigo", "diagnostico-unity",
     "DiseÃ±Ã³ el instrumento de diagnÃ³stico de Unity con alcance mucho mÃ¡s amplio de lo esperado: "
     "cubre gestiÃ³n, talento, roles, experiencia de personas y situaciÃ³n general del programa, "
     "no solo change management; su diagnÃ³stico es el insumo real para nutrir las acciones pendientes.",
     "constructive", "2026-03-24"),

    ("carlos-bc", "comite-estatus-bi-semanal",
     "Preside el comitÃ© de estatus cada dos semanas con 57 participantes; lo usa como mecanismo de "
     "presiÃ³n principal donde se plantean 'pains' y dependencias no cumplidas; el nivel de presiÃ³n "
     "es alto y obliga a los equipos a 'ponerse las pilas'.",
     "demanding", "2026-04-28"),

    ("pablo-lorenzo", "oportunidad-estrategica-unity-accenture",
     "Identifica Unity como caso piloto para fortalecer las capacidades de banking en MÃ©xico dentro "
     "de Accenture; ve la oportunidad mÃ¡s allÃ¡ del engagement actual como desarrollo de capacidad "
     "institucional de la prÃ¡ctica.",
     "positive", "2026-04-20"),

    ("lukasz-pietrzyk", "integracion-fragmentada-unity",
     "ObservÃ³ que no existe un repositorio comÃºn de integraciones; cada track (Transact, Apolo, "
     "SmartVista) administra sus integraciones de forma distinta y con formatos distintos; "
     "esto es una brecha fundacional que bloquea la visibilidad end-to-end.",
     "concerned", "2026-04-28"),

    ("daniel-angeles", "modelo-operativo-ti-existente",
     "Aclara que los procesos de gestiÃ³n de TI ya existentes (cambios, requerimientos, incidentes, "
     "problemas) estÃ¡n definidos y se usarÃ¡n igual para Unity; no se inventan procesos nuevos; "
     "sugiere a Octavio para operaciÃ³n de producciÃ³n Unity y a Rogelio Aguayo para legacy.",
     "constructive", "2026-03-24"),

    ("arturo-perez", "conocimiento-legado-pisa-concentrado",
     "El banco conserva 80-90% del conocimiento sobre el sistema legado concentrado en gerentes "
     "y coordinadores; hay documentaciÃ³n pero la mayor parte de la lÃ³gica de negocio vive en los "
     "~12,000 SPLs y se ha transferido parcialmente al equipo de operaciÃ³n.",
     "neutral", "2026-03-24"),

    ("erica-mata", "proceso-autorizacion-cnbv-unity",
     "La DirecciÃ³n de Riesgos se activa principalmente cuando se requiere notificaciÃ³n a la CNBV; "
     "el proceso requiere CÃ©dula de EvaluaciÃ³n con vistos buenos de seguridad, jurÃ­dico y procesos "
     "operativos; actualmente falta un responsable integral que asegure que nadie omita requisitos crÃ­ticos.",
     "concerned", "2026-04-17"),

    ("alejandro-gallegos", "gobierno-aceleracion-plan-director",
     "Establece que la fase de aceleraciÃ³n de seis semanas tiene dos objetivos: hacer un diligence "
     "del gobierno del Plan Director y revisar definiciones estratÃ©gicas (arquitectura futura, modelo "
     "de operaciÃ³n, roadmap Unity); las primeras semanas son diagnÃ³stico, no ejecuciÃ³n de soluciones.",
     "constructive", "2026-04-13"),

    ("carlos-bc", "transparencia-reporting-testing",
     "El dashboard de pruebas y defectos estÃ¡ disponible para todos los stakeholders incluyendo al "
     "director de transformaciÃ³n; el comitÃ© bi-semanal presenta un estado cerrado, sin sorpresas; "
     "la transparencia es un mecanismo de control que Carlos mantiene activo deliberadamente.",
     "neutral", "2026-04-28"),
]

OPEN_ITEMS = [
    # (id, date, item_text, owner_id_or_None, priority, systems_json_array)

    ("SW2-OI-0001", "2026-04-13",
     "Lanzar encuesta breve de dedicaciÃ³n al proyecto Unity para la semana del 13-17 de abril; "
     "cubrir toda la poblaciÃ³n de tecnologÃ­a gestionada por Cynthia Ramirez; obtener porcentaje "
     "real de dedicaciÃ³n de cada recurso.",
     None, "high", '["Unity"]'),

    ("SW2-OI-0002", "2026-04-13",
     "Coordinar el levantamiento de dedicaciÃ³n con Daniel Gabino para integrar alcance de tecnologÃ­a "
     "y negocio bajo un mismo esfuerzo; evitar encuestas duplicadas entre Cynthia y Tere/Kennedy.",
     None, "high", '["Unity"]'),

    ("SW2-OI-0003", "2026-04-13",
     "Construir y acordar el TO-BE de la DirecciÃ³n de TransformaciÃ³n de Pablo Lorenzo: definir "
     "gerencias de desarrollo, roles de seguridad y niveles inferiores al primer reporte; "
     "actualmente solo existe un AS-IS basado en roles de Plataformas Digitales y Sistemas.",
     "pablo-lorenzo", "high", '["Unity"]'),

    ("SW2-OI-0004", "2026-04-13",
     "Evaluar e incorporar al menos uno o dos KPIs/objetivos de Unity al ciclo de desempeÃ±o 2026 "
     "que arranca en mayo; definir un esquema hÃ­brido de seguimiento para personas dedicadas y parciales; "
     "este es apenas el tercer aÃ±o de mediciÃ³n formal de desempeÃ±o en la compaÃ±Ã­a.",
     None, "medium", '["Unity"]'),

    ("SW2-OI-0005", "2026-04-13",
     "Actualizar y consolidar la estrategia de migraciÃ³n: eliminar referencias desactualizadas a 2025, "
     "incorporar el plan de dÃ©bito, y entregar versiÃ³n unificada antes del viernes; los estimados de "
     "vendors (IWI, Awine) deben validarse internamente en testing global.",
     "pablo-lorenzo", "high", '["Atlas", "SmartVista/BPC", "Transact"]'),

    ("SW2-OI-0006", "2026-04-20",
     "Construir template Ãºnico de diagnÃ³stico fundacional (To-Be ideal / mÃ­nimo operativo / brechas) "
     "por cada dimensiÃ³n del programa; cada responsable ACN llena su parte para integrarse en una "
     "vista Ãºnica antes de la sesiÃ³n con Navas.",
     "alejandro-gallegos", "high", '["Unity"]'),

    ("SW2-OI-0007", "2026-04-20",
     "Realizar working session con Pavel el martes y miÃ©rcoles de la semana del 20 de abril; despuÃ©s "
     "sesiÃ³n con JosÃ© Luis Navas el jueves con propuesta sÃ³lida y consensuada; evitar percepciÃ³n de "
     "improvisaciÃ³n en la presentaciÃ³n ejecutiva.",
     "pablo-lorenzo", "high", '["Unity"]'),

    ("SW2-OI-0008", "2026-04-29",
     "Mapear todas las dependencias crÃ­ticas entre Transact y el sistema legado (ejemplos: Western Union, "
     "recargas); el legado es una 'caja gris' que dificulta construir el roadmap; Gloria debe detallar "
     "el estado y naturaleza de cada dependencia crÃ­tica.",
     None, "high", '["PISA/Informix", "Transact"]'),

    ("SW2-OI-0009", "2026-04-28",
     "Oscar Melo y Eduardo Ponce deben compartir el inventario Excel completo de las 8 interfaces batch "
     "de SmartVista (con prioridades, objetivos, funcionalidades, identificadores) mÃ¡s los archivos "
     "Drawio originales de los diagramas; los PDFs actuales no permiten visualizaciÃ³n adecuada.",
     None, "high", '["SmartVista/BPC"]'),

    ("SW2-OI-0010", "2026-04-29",
     "AngÃ©lica Tolosa debe entregar el trazado de capacidades de arquitectura por release (graduation "
     "diagram: quÃ© capacidades se activan en cada release de Transact) para el jueves; debe incluir "
     "prÃ©stamos y captaciÃ³n, no solo cuentas.",
     None, "high", '["Transact"]'),

    ("SW2-OI-0011", "2026-04-28",
     "Actualizar el documento de estrategia de pruebas (tiene 4 aÃ±os de antigÃ¼edad): reflejar estado "
     "actual de gestiÃ³n, herramientas vigentes (eliminar Value Edge obsoleto), diagramas de entornos "
     "actualizados, y estado real de automatizaciÃ³n (Python, Postman, Appium, framework TAS).",
     None, "medium", '["Unity"]'),

    ("SW2-OI-0012", "2026-04-28",
     "Habilitar ambientes de QA separados por producto (BPC, Launch, OPI, SEW, Apolo) antes de llegar "
     "al EIT; iniciar conversaciones con AndrÃ©s, Miguel Bucio y Daniel Ãngeles del MesanÃ­ para "
     "definir plan de habilitaciÃ³n.",
     None, "high", '["SmartVista/BPC", "Apolo"]'),

    ("SW2-OI-0013", "2026-04-28",
     "Migrar la gestiÃ³n de casos de prueba de Value Edge a X-ray (integrado en Jira) para eliminar "
     "dashboards externos; definir plan de transiciÃ³n que no afecte los ciclos activos de prueba.",
     None, "medium", '["Unity"]'),

    ("SW2-OI-0014", "2026-04-20",
     "Definir el North Star de negocio de Unity: visiÃ³n end-to-end, cross-producto, priorizada; "
     "traducirla en journeys, funcionalidades y prioridades concretas; requiere workshops estructurados "
     "con negocio y tecnologÃ­a, no reuniones regulares.",
     "pablo-lorenzo", "high", '["Unity", "Transact", "Apolo", "SmartVista/BPC"]'),

    ("SW2-OI-0015", "2026-04-17",
     "Designar un responsable integral ('paternalidad') para asegurar que la CÃ©dula de EvaluaciÃ³n "
     "de Riesgos para CNBV estÃ© completa y actualizada; actualmente nadie tiene visiÃ³n end-to-end "
     "de la documentaciÃ³n regulatoria de Unity y hay riesgo de omisiÃ³n de requisitos crÃ­ticos.",
     None, "high", '["Unity"]'),

    ("SW2-OI-0016", "2026-04-17",
     "Formalizar el plan de DRP y BCP para los componentes de Unity: integrar la dimensiÃ³n tecnolÃ³gica "
     "(DRP) y la de procesos (BCP); actualmente no estÃ¡n integradas y la resiliencia operativa no "
     "estÃ¡ completamente estructurada.",
     None, "high", '["Unity", "Transact", "Apolo", "SmartVista/BPC"]'),

    ("SW2-OI-0017", "2026-03-24",
     "Revisar el diagnÃ³stico de Rodrigo Kennedy con el equipo ACN para nutrir acciones pendientes; "
     "su diagnÃ³stico tiene alcance mÃ¡s amplio de lo esperado (gobierno, talento, roles, experiencia "
     "del equipo, situaciÃ³n general del programa); usarlo como insumo real, no como presentaciÃ³n.",
     "alejandro-gallegos", "medium", '["Unity"]'),

    ("SW2-OI-0018", "2026-04-13",
     "Obtener el contacto de NoemÃ­ (business partner de negocio para Unity) a travÃ©s de JosÃ© Emiliano "
     "y agendar una sesiÃ³n equivalente a la de Cynthia para completar la visiÃ³n total de talento "
     "del programa incluyendo el frente de negocio.",
     None, "medium", '["Unity"]'),

    ("SW2-OI-0019", "2026-04-29",
     "Pablo Lorenzo debe crear diapositivas para explicar el mapa de ruta integrado, incluyendo "
     "documentaciÃ³n explÃ­cita de riesgos e hipÃ³tesis (assumptions) que justifiquen posibles retrasos "
     "futuros; las hipÃ³tesis deben apuntar a dependencias crÃ­ticas como estabilidad del ambiente "
     "homologado antes de SIT.",
     "pablo-lorenzo", "high", '["Unity", "Transact"]'),

    ("SW2-OI-0020", "2026-04-29",
     "Socializar versiÃ³n estable del roadmap integrado el martes siguiente; revisar el mapeo de "
     "arquitectura con el equipo Transact; coordinar revisiÃ³n del modelo de capacidades activadas "
     "por release.",
     "pablo-lorenzo", "high", '["Unity", "Transact", "SmartVista/BPC", "Apolo"]'),

    ("SW2-OI-0021", "2026-04-29",
     "Sandra Figueroa y Araceli Barcena deben buscar documentaciÃ³n para reforzar la lista de "
     "dependencias crÃ­ticas del legado con Transact; coordinar con AngÃ©lica Tolosa y Gloria para "
     "tener inventario completo.",
     None, "medium", '["PISA/Informix", "Transact"]'),

    ("SW2-OI-0022", "2026-03-24",
     "Definir estrategia de migraciÃ³n de datos Informix: determinar quÃ© datos histÃ³ricos permanecen "
     "on-premise y cuÃ¡les (clientes activos, saldos) migran a la nube; actualmente la estrategia "
     "no estÃ¡ definida y la latencia Informix bloquea el avance de la migraciÃ³n a nube.",
     None, "high", '["PISA/Informix", "Atlas"]'),

    ("SW2-OI-0023", "2026-04-28",
     "Definir SLAs realistas para resoluciÃ³n de defectos: los SLAs actuales (ej. 4 horas para defecto "
     "crÃ­tico) nunca se cumplen pero nadie ha propuesto alternativas; la deuda de incumplimiento acumulada "
     "no se estÃ¡ gestionando formalmente.",
     None, "medium", '["Unity"]'),

    ("SW2-OI-0024", "2026-04-07",
     "Incorporar a Sergio del Valle (o equivalente) como contraparte de negocio en el proyecto de "
     "aceleraciÃ³n; actualmente los avances solo tienen visto bueno desde delivery/tecnologÃ­a, "
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
    print(f"Swarm G2: {n_dec} decisiones Â· {n_pos} posiciones Â· {n_oi} open items insertados")
    db.close()


if __name__ == "__main__":
    run()
