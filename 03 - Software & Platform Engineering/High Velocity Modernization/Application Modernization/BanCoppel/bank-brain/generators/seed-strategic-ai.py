"""
seed-strategic-ai.py â€” Inteligencia EstratÃ©gica AI-extraÃ­da para Bank Brain
Fuente: 33 minutas Plan Director Unity (abril 2026)
MÃ©todo: anÃ¡lisis semÃ¡ntico implÃ­cito + explÃ­cito (4 batches en paralelo)

IDs nuevos: AI-DEC-NNNN (decisiones) Â· AI-OI-NNNN (open items)
IDs existentes preservados: DEC-0001â€“0074 Â· OI-0001â€“0418

Correr: python seed-strategic-ai.py
Es idempotente: INSERT OR IGNORE en decisions y open_items.
Positions no tiene constraint UNIQUE; correr dos veces duplica posiciones.
"""

import json, sqlite3
from pathlib import Path

DB = Path(__file__).parent.parent / "digital-brain" / "bank-brain.db"

# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# DECISIONS â€” (date, topic, decision, driver_id, confidence)
# topic âˆˆ {apolo,smartvista,transact,atlas,pisa,arquitectura,seguridad,
#           gobierno,cronograma,datos,integracion,testing,regulatorio,general}
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
DECISIONS_RAW = [
    # â”€â”€ 10 Abril Â· Transact Plan Director â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("2026-04-10","transact","El negocio seleccionÃ³ el Escenario 2 (riesgo intermedio) como base del plan de implementaciÃ³n de Transact, descartando tanto el escenario conservador como el agresivo.",None,"high"),
    ("2026-04-10","transact","La cuenta N4 fue priorizada para el desarrollo inicial de Transact por generar entre el 80% y 90% de los ingresos; los demÃ¡s productos quedan subordinados a este arranque.",None,"high"),
    ("2026-04-10","cronograma","La implementaciÃ³n de depÃ³sitos (Transact) comienza en 2028 con migraciÃ³n posterior; los crÃ©ditos se comprometen a Q4 2028 con un solo producto, un solo canal y sin migraciÃ³n inicial.",None,"high"),
    ("2026-04-10","transact","Se adopta el principio de cero personalizaciÃ³n para Transact: solo configuraciÃ³n mÃ­nima de la plataforma Temenos; las 18 configuraciones/customizaciones de integraciÃ³n identificadas (deltas) son el alcance cerrado de adaptaciones.",None,"high"),
    ("2026-04-10","integracion","Los equipos de canales confirmaron que NO pueden comprometerse con el plan actual de integraciÃ³n con canales; esto obliga a crear un plan unificado de fechas de integraciÃ³n como prerrequisito del roadmap de Transact.",None,"high"),
    ("2026-04-10","cronograma","La implementaciÃ³n de la cuenta N4 en Transact tiene como dependencia crÃ­tica que la capacidad de tarjeta de dÃ©bito sea priorizada en la prÃ³xima planificaciÃ³n PI; sin ello la fecha corre riesgo.",None,"high"),
    ("2026-04-10","transact","El equipo tÃ©cnico de Transact confirmÃ³ su capacidad para cumplir las fechas acordadas a pesar del cambio en el producto MVP de cuenta, seÃ±alizando confianza interna en el plan.",None,"medium"),
    ("2026-04-10","transact","El alcance de cuentas de Transact incluye funcionalidad de cheques e inversiones (depÃ³sitos a plazo con tasas personalizadas) como parte del MVP de cuenta N4.",None,"medium"),
    # â”€â”€ 15 Abril Â· Testing â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("2026-04-15","gobierno","El programa de aceleraciÃ³n de 6 semanas impulsado por Juan Manuel se enfoca en gobierno y tecnologÃ­a con el objetivo explÃ­cito de identificar pain points y proponer remediaciones concretas.","juan-manuel","high"),
    ("2026-04-15","testing","La planificaciÃ³n del roadmap se estructura en drops (ventanas de entrega) en lugar de releases para eliminar ambigÃ¼edad semÃ¡ntica dentro del programa Unity; Drop One abarca abril 2026 a marzo 2028.","pablo-lorenzo","high"),
    ("2026-04-15","testing","El ambiente homologado es el Ãºnico entorno de pruebas para SIT, UAT y Performance; construirlo tomÃ³ mÃ¡s de 2 aÃ±os y aÃºn no es un verdadero preproductivo; esta restricciÃ³n estructural se acepta como estado actual.",None,"high"),
    ("2026-04-15","testing","El criterio de salida real del SIT exige resoluciÃ³n del 100% de defectos antes de pasar a UAT, aunque el umbral formal sea del 80%; el negocio impone el criterio mÃ¡s estricto de facto, elevando el riesgo de bloqueos.",None,"high"),
    ("2026-04-15","testing","Las pruebas de seguridad tienen prioridad exclusiva sobre el ambiente homologado, deteniendo todas las demÃ¡s actividades de testing; esto convierte al equipo de seguridad en un bloqueante potencial del cronograma.",None,"high"),
    ("2026-04-15","testing","La extensiÃ³n sistemÃ¡tica del SIT hasta 5 meses (caso Apolo) y del UAT hasta 2 meses se confirma como desviaciÃ³n estructural del programa; la causa raÃ­z del UAT es la baja dedicaciÃ³n del negocio a las pruebas.",None,"high"),
    ("2026-04-15","testing","BPC (proveedor de SmartVista) incumple consistentemente los SLAs de resoluciÃ³n de defectos, tardando dÃ­as o semanas; esto se establece como riesgo estructural del programa que debe gestionarse como dependencia de proveedor.",None,"high"),
    ("2026-04-15","testing","La automatizaciÃ³n de testing cubre cerca del 100% de las rutas crÃ­ticas de alto valor de negocio (abonos, cargos, pagos de crÃ©ditos en CW); el enfoque de ROI guÃ­a la selecciÃ³n de quÃ© automatizar.",None,"medium"),
    # â”€â”€ 16 Abril Â· Atlas + MigraciÃ³n E2E â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("2026-04-16","gobierno","Juan Manuel solicitÃ³ urgentemente un plan integral E2E con cronograma consolidado para presentar ante la junta directiva de accionistas el 24 de abril; seÃ±alÃ³ que los planes existentes estaban demasiado fragmentados por stream.","juan-manuel","high"),
    ("2026-04-16","atlas","La migraciÃ³n de datos a producciÃ³n solo se realizarÃ¡ una vez que las Pruebas de AceptaciÃ³n de Usuario (UAT) estÃ©n completamente finalizadas; esta secuencia se confirma como polÃ­tica del programa.",None,"high"),
    ("2026-04-16","atlas","Se incorporaron dry runs integrales de ETL (simulacros previos a UAT) para estabilizar el pipeline de migraciÃ³n y validar calidad de datos antes del UAT; este paso no existÃ­a en el plan original.","pablo-lorenzo","high"),
    ("2026-04-16","atlas","Se decidiÃ³ agregar Dress Rehearsals (2-3 simulacros de go-live en ambiente preproductivo) despuÃ©s de UAT y antes de producciÃ³n para afinar el runbook operativo.","pablo-lorenzo","high"),
    ("2026-04-16","atlas","El Proyecto Atlas tiene una estructura de 2 aÃ±os dividida en 4 fases metodolÃ³gicas: Crawl (hasta ago-2026), Walk, Run y Fly; es el primer esfuerzo de migraciÃ³n de datos en la historia del banco.",None,"high"),
    ("2026-04-16","atlas","La Fase 1 Crawl de Atlas debe completarse en agosto 2026 con: golden record bÃ¡sico del dominio de clientes, infraestructura en GCP, MDM v1, pipelines de matching y carga completa de clientes.",None,"high"),
    ("2026-04-16","pisa","La Fase 3 Run de Atlas incluye la migraciÃ³n de clientes desde PISA hacia los sistemas destino (+25 millones de clientes) con integraciÃ³n con Grupo Coppel, Forex, Adobe CDP y Salesforce.",None,"medium"),
    # â”€â”€ 23 Abril Â· Apolo + Legacy + SmartVista â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("2026-04-23","gobierno","Se acordÃ³ realizar actualizaciones semanales del roadmap integral (45 min, miÃ©rcoles o jueves) durante las prÃ³ximas 2 semanas; el roadmap aÃºn estÃ¡ en iteraciÃ³n activa en la semana 4 del programa de aceleraciÃ³n.","pablo-lorenzo","high"),
    ("2026-04-23","apolo","El inventario de APIs de Apolo (~600 APIs totales) no estÃ¡ consolidado; cada building block mantiene su propia documentaciÃ³n y no existe vista unificada de interfaces; esto se establece como brecha crÃ­tica para el roadmap.",None,"high"),
    ("2026-04-23","apolo","La latencia de 5 segundos promedio en la capa proxy de Apolo en producciÃ³n es un problema crÃ­tico identificado; se anticipa que empeorarÃ¡ con la implementaciÃ³n de Web Methods y el cifrado de datos sensibles.",None,"high"),
    ("2026-04-23","seguridad","Se confirma que los datos personales en Apolo (nombre, CURP, RFC, telÃ©fono, email) no estÃ¡n cifrados en reposo y la base de datos en AWS reside fuera del territorio mexicano; hallazgo de incumplimiento regulatorio.",None,"high"),
    ("2026-04-23","apolo","El ciclo de vida completo de una API de Apolo desde diseÃ±o hasta producciÃ³n toma aproximadamente 4 meses; la actualizaciÃ³n de diagramas de arquitectura depende de insumos de Play Digital.",None,"medium"),
    ("2026-04-23","pisa","Se confirma que no existe un punto de contacto centralizado con control global del sistema Legacy PISA; el conocimiento estÃ¡ fragmentado entre mÃºltiples personas y equipos, sin ownership unificado.",None,"high"),
    ("2026-04-23","pisa","SmartVista, BPC e Interact estÃ¡n planificados para decommission gradual; Informix es el componente mÃ¡s complejo y requiere un barrido especÃ­fico para habilitar nuevas funcionalidades.",None,"high"),
    ("2026-04-23","regulatorio","Los expedientes entregados a la CNBV para Transact, SmartVista y Apolo son la fuente mÃ¡s eficiente de arquitecturas de referencia para el mapeo de interfaces del Legacy.",None,"medium"),
    ("2026-04-23","smartvista","El roadmap actual de SmartVista cubre Ãºnicamente Tarjeta de CrÃ©dito (TDC); la Tarjeta de DÃ©bito (TDD) no estÃ¡ en el backlog, carece de estimaciones, riesgos y dependencias documentadas, aunque el negocio la espera para Q1 2027.",None,"high"),
    ("2026-04-23","smartvista","No existe inventario consolidado de interfaces de SmartVista; solo existen inventarios para R2 y R3; R4 estÃ¡ completamente sin documentar; el mapeo de capacidades empresariales tampoco ha comenzado formalmente.",None,"high"),
    ("2026-04-23","smartvista","El equipo de SmartVista conoce el modelo de capacidades funcionales a nivel presentaciÃ³n pero declara que la implementaciÃ³n real es otra conversaciÃ³n; seÃ±al de brecha significativa entre diseÃ±o teÃ³rico y estado real.",None,"high"),
    ("2026-04-23","pisa","Juan Manuel dejÃ³ claro que la contabilidad permanece en el sistema legado (PISA/IPISA) y no serÃ¡ migrada a los sistemas destino en el alcance actual de Unity.","juan-manuel","high"),
    ("2026-04-23","transact","El mapeo de capacidades por release (evoluciÃ³n cronolÃ³gica) es una necesidad crÃ­tica para Transact: sin esa vista no se pueden detectar capacidades huÃ©rfanas ni conflictos de duplicaciÃ³n entre sistemas.","lukasz-pietrzyk","high"),
    ("2026-04-23","integracion","La definiciÃ³n del inventario de interfaces y su progresiÃ³n por release es responsabilidad exclusiva del banco (Sandra y Araceli), no del equipo de apoyo ACN.",None,"high"),
    ("2026-04-23","transact","El roadmap de capacidades estÃ¡ construido solo en target state (estado final) y carece de una vista cronolÃ³gica por release â€” brecha reconocida colectivamente que debe subsanarse antes de consolidar el plan director.","lukasz-pietrzyk","medium"),
    # â”€â”€ 24 Abril Â· SmartVista Roadmap + Transact Roadmap â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("2026-04-24","smartvista","R3 se liberarÃ¡ de forma separada e independiente para cumplir compromisos existentes con el negocio. La propuesta de agrupar R3 y R4 fue descartada porque el negocio (Sergio del Valle) la rechazarÃ­a dado los retrasos acumulados.","pablo-lorenzo","high"),
    ("2026-04-24","smartvista","R4 adoptarÃ¡ una nueva estrategia de testing integral exhaustivo (SIT/UAT transversales de 3-4 meses + NFT/performance + simulacros de producciÃ³n), lo que empujarÃ¡ su fecha de liberaciÃ³n a principios de febrero.","pablo-lorenzo","high"),
    ("2026-04-24","gobierno","Sergio del Valle fue confirmado como sponsor ejecutivo clave de las decisiones de roadmap y producto de SmartVista. El plan debe validarse con Ã©l antes de cualquier presentaciÃ³n a Juan Manuel.",None,"high"),
    ("2026-04-24","smartvista","Copel Pay irÃ¡ a SmartVista. Representa una extensiÃ³n del crÃ©dito Coppel existente en una tarjeta Mastercard para uso en cualquier establecimiento. Fechas de onboarding pendientes de confirmar con David Estrada.",None,"medium"),
    ("2026-04-24","smartvista","Solo la Tarjeta de CrÃ©dito ClÃ¡sica estÃ¡ en el alcance comprometido hasta 2028. Productos como Platino y otros tipos de TDC quedan fuera del roadmap planificado.",None,"high"),
    ("2026-04-24","integracion","El onboarding N4 (Cuenta Efectiva Digital) va con Transact; el R3 (Apolo en BanCoppel) estÃ¡ asociado a la Tarjeta Digital en SmartVista. El onboarding Offi y Apolo estÃ¡n ligados a la Tarjeta de CrÃ©dito ClÃ¡sica en SmartVista.",None,"high"),
    ("2026-04-24","apolo","En el cronograma actual la versiÃ³n N4 de Cuenta Digital que se libera es legacy; sin embargo, en el punto de lanzamiento definitivo la creaciÃ³n de cuentas N4 se realizarÃ¡ en Apolo.",None,"medium"),
    ("2026-04-24","cronograma","El roadmap se extiende hasta 2028. Existe un bloqueador mayor por la fragmentaciÃ³n absoluta del sistema legado: no hay una persona con el conocimiento completo de fechas, desarrollos y dependencias.","lukasz-pietrzyk","high"),
    ("2026-04-24","transact","Cuentas Efectivas Digitales N2 y N4, y Cuenta NÃ³mina N4 operarÃ¡n en Transact. El onboarding de las tres se realizarÃ¡ a travÃ©s de promotoria (Apolo). Solo Inversiones y PagarÃ©s estÃ¡n en el alcance comprometido hasta 2028.",None,"high"),
    ("2026-04-24","transact","PrÃ©stamo Simple es el Ãºnico producto de prÃ©stamos incluido en la planificaciÃ³n hasta 2028. PrÃ©stamo Revolvente, NÃ³mina y Anticipo NÃ³mina estÃ¡n fuera del alcance.",None,"high"),
    ("2026-04-24","cronograma","La decisiÃ³n sobre la fecha de inicio del PrÃ©stamo Simple (Q4 2026 solicitado vs Q2 2027) serÃ¡ tomada a nivel ejecutivo por Juan Manuel y Sergio del Valle. El SIT/UAT se propone en 3 meses cada uno.","juan-manuel","high"),
    ("2026-04-24","integracion","Western Union que actualmente usa el core legado debe activar una nueva integraciÃ³n con Transact. Esta es una dependencia crÃ­tica que afecta el timing de la Cuenta Efectiva Digital N4.",None,"high"),
    ("2026-04-24","testing","Se propuso estandarizar y agrupar las fases SIT y UAT en ciclos transversales de 3 meses cada uno (con ciclos internos de 1 mes), mÃ¡s dress rehearsals de simulacro de producciÃ³n.","pablo-lorenzo","high"),
    ("2026-04-24","gobierno","Debe solicitarse sesiÃ³n ejecutiva con Sergio del Valle para presentar y obtener feedback sobre la evoluciÃ³n del mapa integral antes de escalarlo a Juan Manuel.","pablo-lorenzo","medium"),
    # â”€â”€ 28 Abril Â· Testing + Arquitectura + Atlas + SmartVista Interfaces â”€â”€â”€â”€
    ("2026-04-28","testing","Se decidiÃ³ migrar la gestiÃ³n de pruebas hacia X-ray (integrado en Jira), eliminando los dashboards externos actuales (Value Edge). Esta transiciÃ³n busca centralizar la visibilidad de test management.",None,"high"),
    ("2026-04-28","testing","Se estableciÃ³ la visiÃ³n de habilitar ambientes de QA separados por producto (BPC, Launch, OPI, SEW, Apollo) antes de llegar al ambiente EIT (homologado integrado).",None,"high"),
    ("2026-04-28","testing","Las desviaciones en la planificaciÃ³n de pruebas alcanzan hasta el 200% respecto al objetivo (mÃ¡ximo 10%), porque los retrasos de desarrollo se comen el tiempo de QA sin mover la fecha lÃ­mite final.",None,"high"),
    ("2026-04-28","testing","Los SLAs de resoluciÃ³n de defectos (ej. 4 horas para crÃ­ticos) son reconocidos como demasiado agresivos y rara vez se cumplen; nadie ha propuesto SLAs mÃ¡s realistas, lo que perpetÃºa el incumplimiento formal.",None,"medium"),
    ("2026-04-28","testing","El ciclo completo de QA fue reiniciado en un proyecto previo porque la definiciÃ³n inicial fue incorrecta: HUs mal definidas, alcance en evoluciÃ³n y compromisos informales sin control. LecciÃ³n aprendida que debe incorporarse al DoR.",None,"medium"),
    ("2026-04-28","testing","El ambiente pre-producciÃ³n solo soporta hasta 50 transacciones por minuto, cuando la aplicaciÃ³n real tiene ~18,000 usuarios. El ambiente es inadecuado para pruebas de performance representativas.",None,"high"),
    ("2026-04-28","testing","La estrategia de pruebas actual del banco tiene 4 aÃ±os de antigÃ¼edad y estÃ¡ desactualizada. Requiere revisiÃ³n integral para reflejar el estado actual de gestiÃ³n, herramientas y automatizaciÃ³n en el contexto Unity.",None,"medium"),
    ("2026-04-28","testing","El UAT se ejecuta con apoyo del equipo de QA porque el Ã¡rea de negocio no tiene capacidad de tiempo suficiente; esto prolonga las pruebas de 4 semanas planificadas a 4 meses reales.",None,"high"),
    ("2026-04-28","arquitectura","Se confirmÃ³ la necesidad de incorporar proactivamente Arquitectos de SoluciÃ³n en las cÃ©lulas de desarrollo desde la fase de diseÃ±o para garantizar cumplimiento de estÃ¡ndares.",None,"high"),
    ("2026-04-28","apolo","Lenin, arquitecto de soluciÃ³n clave en Apolo, sale el 31 de mayo sin haber identificado formalmente a su reemplazo ni transferido conocimiento al banco. Solo pasÃ³ contexto a JoaquÃ­n Pichardo de ACN â€” riesgo crÃ­tico de continuidad.","lukasz-pietrzyk","high"),
    ("2026-04-28","arquitectura","La resoluciÃ³n de hallazgos de deuda tÃ©cnica estÃ¡ bloqueada por la prioridad de releases: solo 9 de los hallazgos abiertos han sido resueltos.",None,"high"),
    ("2026-04-28","apolo","Se detectaron latencias de 5 segundos en la ejecuciÃ³n de cualquier API de Apolo. El equipo de Arquitectura aclarÃ³ que esto es un problema de solution architecture, no de pruebas no funcionales.","lukasz-pietrzyk","high"),
    ("2026-04-28","smartvista","Existe una brecha de documentaciÃ³n crÃ­tica: no se tiene certeza de si todos los mÃ³dulos de SmartVista han sido contratados. El equipo de Arquitectura estima tener primeras versiones del anÃ¡lisis a mediados de mayo.",None,"high"),
    ("2026-04-28","arquitectura","Se acordÃ³ desarrollar directrices y recomendaciones formales sobre cuÃ¡ndo utilizar cachÃ© para APIs, fundamental para optimizar tiempos en el escenario multi-cloud con sistemas legados.",None,"medium"),
    ("2026-04-28","smartvista","La soluciÃ³n del autorizador de pagos en SmartVista se trabaja en dos vÃ­as paralelas: mejoras a la arquitectura actual del autorizador y habilitaciÃ³n del autorizador en SmartVista.",None,"medium"),
    ("2026-04-28","atlas","Atlas Fase 2 (MDM con Golden Record) debe estar en producciÃ³n antes de finales de septiembre 2026 â€” dependencia crÃ­tica antes de la migraciÃ³n de TDC clÃ¡sica en SmartVista proyectada para diciembre 2026.","lukasz-pietrzyk","high"),
    ("2026-04-28","regulatorio","Se identificÃ³ riesgo normativo: ID de producto de TDC clÃ¡sica difiere entre legado (6001) y SmartVista (4900). El ID 4900 no estÃ¡ declarado ante Banco de MÃ©xico. Se acordÃ³ proceder con ID 4900 asumiendo esfuerzo adicional en reportes regulatorios.",None,"high"),
    ("2026-04-28","atlas","La puesta en producciÃ³n del Golden Record a finales de septiembre 2026 solo contempla la carga de datos en el MDM. AÃºn falta definir la integraciÃ³n detallada del MDM con plataformas y canales.","lukasz-pietrzyk","high"),
    ("2026-04-28","datos","El Ã¡rea de Negocio estÃ¡ evadiendo su responsabilidad en el proyecto Atlas: debe ser parte del comitÃ© y proveer las definiciones para el Golden Record, pero percibe que no le corresponde participar.",None,"high"),
    ("2026-04-28","atlas","Las metodologÃ­as de migraciÃ³n de SmartVista y Transact estÃ¡n completamente aisladas. Se decidiÃ³ usar la metodologÃ­a de SmartVista (trabajada con IWI para TDC) como habilitador para la migraciÃ³n de Transact.",None,"high"),
    ("2026-04-28","pisa","No existe un punto de contacto Ãºnico para el sistema legado completo â€” estÃ¡ muy disperso entre muchas personas. La Ãºnica persona del legacy que se ha acercado proactivamente para tratar coexistencia con la migraciÃ³n es MartÃ­n Alejandro LÃ³pez.",None,"high"),
    ("2026-04-28","testing","Se propuso metodologÃ­a de testing transversal con SIT y UAT de 3 meses cada uno (ciclos internos de 1 mes), pruebas no funcionales en paralelo, y dress rehearsals (3 simulacros de 1 mes) con participaciÃ³n de Negocio, Operaciones, TI y QA.","pablo-lorenzo","high"),
    ("2026-04-28","smartvista","Se identificaron 8 interfaces batch de SmartVista: 3 ya en producciÃ³n, 5 en desarrollo pendientes de liberaciÃ³n. No existe un Excel consolidado del inventario.",None,"high"),
    ("2026-04-28","integracion","Existen interfaces inversas de conciliaciÃ³n SmartVista â†’ legacy que aÃºn no estÃ¡n en producciÃ³n y son necesarias para proveer archivos de conciliaciÃ³n generados en la operaciÃ³n actual.",None,"high"),
    ("2026-04-28","integracion","El proceso de gestiÃ³n de cambios en interfaces SmartVista se hace vÃ­a email de JosÃ© Jaimes â†’ Jira â†’ dev â†’ ciclos de prueba. No hay un proceso estandarizado formal.",None,"medium"),
    ("2026-04-28","arquitectura","El equipo de Unity gestiona ademÃ¡s APIs no estÃ¡ndar para necesidades particulares del Core Banking System (disposiciones, pagos, notificaciones de cobranza), arquitectura ad-hoc fuera del estÃ¡ndar corporativo.",None,"medium"),
    ("2026-04-28","integracion","El alcance del diligence se extendiÃ³ de identificaciÃ³n de brechas a elaboraciÃ³n de roadmap integral hasta 2028, por solicitud explÃ­cita de Juan Manuel.","pablo-lorenzo","high"),
    ("2026-04-28","smartvista","Se clarificÃ³ la taxonomÃ­a de integraciones SmartVista en dos categorÃ­as: APIs para interacciones en lÃ­nea con canales e interfaces batch offline que complementan la operaciÃ³n.","lukasz-pietrzyk","high"),
    ("2026-04-28","gobierno","No existe un inventario consolidado de las 8 integraciones SmartVista en un solo documento formal; cada track administra sus integraciones de forma distinta â€” brecha de gobernanza reconocida colectivamente.","pablo-lorenzo","high"),
    ("2026-04-28","gobierno","El flujo de cambios a interfaces se gestiona informalmente vÃ­a correo electrÃ³nico antes de crear tarjetas en Jira; no existe un proceso formal de change management con gate de revisiÃ³n arquitectÃ³nica.",None,"medium"),
    ("2026-04-28","smartvista","Existe confusiÃ³n documentada sobre si el autorizador de SmartVista fue comprado; la habilitaciÃ³n del autorizador estÃ¡ en fases muy tempranas â€” apenas siendo convocada Arquitectura Empresarial.",None,"high"),
    ("2026-04-28","arquitectura","El proyecto Atlas estÃ¡ liderado por arquitectura de grupo (datos), pero aÃºn no se ha definido quÃ© arquitectos con conocimiento de banca se asignarÃ¡n â€” crÃ­tico para la definiciÃ³n del Golden Source del cliente.","lukasz-pietrzyk","medium"),
    ("2026-04-28","integracion","TensiÃ³n multi-cloud identificada: plataforma de datos en GCP, mayorÃ­a de procesadores bancarios en AWS o on-prem; requerimientos de latencia y revisiones preventivas no han sido formalmente evaluados.","lukasz-pietrzyk","medium"),
    # â”€â”€ 29 Abril Â· Transact + Apolo + Unity-Legado â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("2026-04-29","transact","La arquitectura empresarial de referencia de Unity fue ajustada para incluir prÃ©stamos y captaciÃ³n; originalmente estaba enfocada casi al 100% en cuentas. El ajuste fue realizado por EY (AngÃ©lica Tolosa).",None,"high"),
    ("2026-04-29","transact","Se acordÃ³ documentar estados intermedios de la arquitectura por release (no solo el End State), para poder medir progreso real y comunicarlo a Juan Manuel; entrega comprometida para el jueves.","pablo-lorenzo","high"),
    ("2026-04-29","cronograma","Se propuso un modelo de 3 meses para SIT y 3 meses para UAT organizados en 3 ciclos, con testing no funcional (seguridad y rendimiento) corriendo en paralelo â€” modelo mÃ¡s conservador y realista que el actual.","pablo-lorenzo","high"),
    ("2026-04-29","cronograma","Se incorporaron simulacros de producciÃ³n (3D reversals) al roadmap propuesto porque actualmente no existe un equipo de deployment con visiÃ³n integral del Go-Live.","pablo-lorenzo","medium"),
    ("2026-04-29","pisa","El legado fue caracterizado colectivamente como caja gris: no hay visibilidad suficiente de dependencias con Transact (ej. Western Union, recargas) para construir el roadmap â€” urgencia de documentaciÃ³n explicitada.","pablo-lorenzo","high"),
    ("2026-04-29","cronograma","El anÃ¡lisis y diseÃ±o del prÃ©stamo simple en Transact se moviÃ³ un cuarto y medio a la derecha en el roadmap para garantizar los nuevos ciclos SIT/UAT de 3 meses sin sobreposiciÃ³n.",None,"medium"),
    ("2026-04-29","transact","La estrategia de lanzamiento del prÃ©stamo simple (friends and family vs. apertura amplia) no estÃ¡ definida aÃºn; se revisarÃ¡ en mayo â€” decisiÃ³n implÃ­cita de posponer ese alcance.",None,"medium"),
    ("2026-04-29","cronograma","El roadmap integrado solo reflejarÃ¡ trabajo con plan formal definido; cualquier iniciativa futura sin planificaciÃ³n se documentarÃ¡ explÃ­citamente como supuesto (assumption) para delimitar el alcance.","pablo-lorenzo","high"),
    ("2026-04-29","apolo","Apolo R4 incluye 11 historias de usuario incrementales ya planificadas y estimadas; fecha objetivo: lanzamiento a mercado abierto diciembre 2026 â€” esta es la fecha lÃ­mite de negocio.",None,"high"),
    ("2026-04-29","apolo","La Cuenta Efectiva Digital N4 operarÃ¡ en dos fases: conecta inicialmente a Legacy; una vez que Transact finalice el desarrollo de cuentas, Apolo reapuntarÃ¡ a Transact. DecisiÃ³n de arquitectura en dos etapas confirmada.",None,"high"),
    ("2026-04-29","apolo","Los desarrollos de Apollo App deben estar listos a mÃ¡s tardar en R4; es la fecha lÃ­mite establecida por negocio para incluir experiencia en app en el lanzamiento al mercado abierto.",None,"high"),
    ("2026-04-29","smartvista","El equipo que desarrolla SmartVista R4 (TDC) es el mismo que debe atender el impacto de ORE â€” riesgo de capacidad identificado y documentado como dependencia crÃ­tica.",None,"medium"),
    ("2026-04-29","regulatorio","La carpeta normativa CNBV solo tiene informaciÃ³n hasta R3 y necesita actualizaciones con los desarrollos de R4 para la salida a mercado abierto en diciembre 2026 â€” riesgo regulatorio activo.","pablo-lorenzo","high"),
    ("2026-04-29","pisa","No existe un punto de contacto Ãºnico para todo el legado de PISA/canales/reportes; el intento inicial con Octavio fracasÃ³. La coordinaciÃ³n de legado es fragmentada por aplicativo â€” brecha de gobernanza estructural.","pablo-lorenzo","high"),
    ("2026-04-29","pisa","La conexiÃ³n del switch de transacciones de cajeros y POS con el nuevo stack (Iglobe) estÃ¡ proyectada para Q1/Q2 2027; Unity planea contactar al equipo de JosÃ© Alberto a principios de 2027 para iniciar diseÃ±o.",None,"medium"),
    ("2026-04-29","pisa","Ares (banca empresarial) opera sobre PISA y se integrarÃ¡ a Transact en una segunda fase; Credit Risk es un componente satÃ©lite sin plan de integraciÃ³n directo a Unity.",None,"medium"),
    ("2026-04-29","datos","La reporterÃ­a de SmartVista se gestionarÃ¡ de forma separada del legado porque SmartVista tendrÃ¡ su propia base de datos independiente.",None,"medium"),
    ("2026-04-29","pisa","Muchos Ã­tems del listado de aplicativos legados son agrupaciones de stored procedures que consumen mÃºltiples canales, no aplicativos reales; el inventario necesita revalidaciÃ³n.",None,"medium"),
    ("2026-04-29","gobierno","Se acordÃ³ planificar workshops detalladas de legado que incluyan personal crÃ­tico del programa Unity para que el ejercicio sea recÃ­proco y no solo unilateral del lado legacy.","pablo-lorenzo","high"),
    # â”€â”€ 30 Abril Â· Apolo Roadmap + SmartVista Semanal â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("2026-04-30","cronograma","R4 confirmado en el plan: Arturo Valdivieso confirmÃ³ que R4 debe incluirse porque ya estÃ¡ dimensionado y en construcciÃ³n; no es opcional.",None,"high"),
    ("2026-04-30","cronograma","Fecha de R3 corregida: no serÃ¡ en abril sino en julio (Q3) para Apolo y SmartVista. La correcciÃ³n se hizo explÃ­citamente durante la sesiÃ³n.","pablo-lorenzo","high"),
    ("2026-04-30","apolo","La secciÃ³n Apolo en el roadmap se renombra a Canales para evitar confusiÃ³n y reflejar correctamente que Apolo es un canal de captura, no un sistema core.",None,"high"),
    ("2026-04-30","apolo","Apolo no genera productos bancarios: captura informaciÃ³n y la inyecta al legado para su creaciÃ³n. La transmisiÃ³n hacia legado se considera Go Live porque requiere capas intermedias.",None,"high"),
    ("2026-04-30","apolo","El onboarding digital de cuentas Nivel 4 (E4) se estructura en dos fases: Fase 1 acerca al MVP; Fase 2 crea el producto, estimada entre Q4 2026 y Q1 2027.",None,"high"),
    ("2026-04-30","cronograma","R4 abierto a mercado: meta diciembre 2026, incluye trabajo de Apolo en la aplicaciÃ³n y 11 historias de usuario esenciales.",None,"high"),
    ("2026-04-30","cronograma","R4.5 sin definiciÃ³n cerrada: su alcance depende de funcionalidades de medios de pago (Spay, tarjeta de dÃ©bito) que aÃºn estÃ¡n en definiciÃ³n y dimensionamiento.",None,"medium"),
    ("2026-04-30","cronograma","Se estableciÃ³ reuniÃ³n semanal cada martes para revisar cambios en roadmap junto a assumptions y riesgos, como mecanismo de gobierno recurrente del track.",None,"high"),
    ("2026-04-30","smartvista","R4 se divide en tres liberaciones independientes a producciÃ³n para cumplir objetivos comerciales y permitir liberar canales individualmente; la Ãºltima entrega (R4.5) extiende hasta la tercera semana de enero 2027.","pablo-lorenzo","high"),
    ("2026-04-30","testing","Se implementarÃ¡n ciclos separados de SIT y UAT de mÃ­nimo un mes cada uno; actualmente se ejecuta un ciclo Ãºnico donde distintas personas prueban los mismos casos â€” prÃ¡ctica que se elimina.","pablo-lorenzo","high"),
    ("2026-04-30","cronograma","Se implementarÃ¡n ejercicios de simulacro a producciÃ³n (rehearsal) para mejorar el runbook de deployment y asegurar la integraciÃ³n de negocio, operaciones y TI antes de cada release.","pablo-lorenzo","high"),
    ("2026-04-30","integracion","Se acordÃ³ realizar workshops enfocados y planificados con el equipo de Legado â€” uno por track (Transact y SmartVista por separado) â€” para identificar insumos y prioridades.","pablo-lorenzo","high"),
    ("2026-04-30","apolo","La cuenta efectiva digital de Apolo se conectarÃ¡ primero a Legado y posteriormente a Transact; la secuencia de integraciÃ³n quedÃ³ establecida explÃ­citamente.",None,"high"),
    ("2026-04-30","gobierno","El roadmap debe ser integral e incluir hipÃ³tesis (assumptions), riesgos y los impactos de Atlas y Legado, ademÃ¡s de los planes de todos los streams; el formato actual es insuficiente.","pablo-lorenzo","high"),
    ("2026-04-30","gobierno","DiagnÃ³stico acordado: los problemas del programa son de metodologÃ­a y coordinaciÃ³n, no de talento. Esta distinciÃ³n es relevante para el tipo de intervenciÃ³n a proponer.","pablo-lorenzo","high"),
    # â”€â”€ 7 Abril Â· Apolo + SmartVista + Transact Arquitectura â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("2026-04-07","arquitectura","Los arquitectos deben tener mayor implicaciÃ³n en los grupos de trabajo desde el inicio del desarrollo para asegurar alineaciÃ³n de Apolo con principios de arquitectura; se eliminarÃ¡n validaciones a posteriori.","arcadio","high"),
    ("2026-04-07","arquitectura","Todos los planes de trabajo de hallazgos de remediaciÃ³n deben pasar por supervisiÃ³n y visto bueno del equipo de arquitectura; hallazgos que extienden mÃ¡s allÃ¡ de R3 tienen plan formal con fechas agosto-septiembre.","arcadio","high"),
    ("2026-04-07","apolo","La funcionalidad de clientes existentes debe priorizarse antes de salida a mercado abierto: el hit rate en Friends and Family fue menor al 10% porque la mayorÃ­a ya son clientes existentes.",None,"high"),
    ("2026-04-07","apolo","Causa raÃ­z identificada: Apolo fue concebido como proyecto de TI sin participaciÃ³n de negocio, lo que generÃ³ fallas de implementaciÃ³n (reglas y motores) que se convirtieron en remediaciones del R2.","pablo-lorenzo","high"),
    ("2026-04-07","apolo","Desacoplamiento SP a APIs: aproximadamente 60% de los servicios ya son microservicios; 40% todavÃ­a usa llamadas directas a stored procedures. El plan incluye completar el desacoplamiento.",None,"medium"),
    ("2026-04-07","integracion","Existe un proyecto futuro para reemplazar APG por MuleSoft. El contrato con APG finaliza en 2027 y la implementaciÃ³n de Octa para el proyecto Aries ya retrasÃ³ el programa seis meses.",None,"high"),
    ("2026-04-07","arquitectura","El DRP debe ligarse para incluir Apolo y SmartVista en conjunto; Apolo no funciona de manera aislada y actualmente no existe gobierno transversal para planificar el aumento de transaccionalidad.",None,"high"),
    ("2026-04-07","apolo","El 97% del trÃ¡fico de onboarding proviene de campaÃ±as de trÃ¡fico pagado; implementar monitoreo para detectar fallas y detener campaÃ±as rÃ¡pidamente es crÃ­tico para evitar pÃ©rdidas.",None,"high"),
    ("2026-04-07","smartvista","El alcance de SmartVista se redujo de 50 funcionalidades solicitadas a 19 esenciales para el lanzamiento al mercado abierto (R4); las restantes quedaron en backlog.",None,"high"),
    ("2026-04-07","smartvista","A diferencia de otros tracks, todos los hallazgos de SmartVista deben resolverse sin excepciÃ³n por dependencia con el legado; los tickets ya estÃ¡n elevados con BPC para resoluciÃ³n.",None,"high"),
    ("2026-04-07","smartvista","La migraciÃ³n del portafolio TDC se planea en 4 olas post-R4, usando criterio de ID de producto + ID de cliente (no BIN) para evitar dividir la informaciÃ³n del cliente entre legado y SmartVista.",None,"high"),
    ("2026-04-07","smartvista","Dos precondiciones obligatorias para iniciar la migraciÃ³n TDC: 1) implementaciÃ³n del preautorizador y 2) detenciÃ³n de la originaciÃ³n de tarjetas en PISA.",None,"high"),
    ("2026-04-07","smartvista","MigraciÃ³n completa del portafolio TDC (99% producto clÃ¡sico) podrÃ­a finalizar en 2027; el roadmap confirmado llega solo hasta fin de 2026.",None,"high"),
    ("2026-04-07","seguridad","Se agregÃ³ personalizaciÃ³n de autenticaciÃ³n por JWT a SmartVista por revisiones de seguridad. Existe preocupaciÃ³n de que interfaces temporales pasen datos sensibles a un legado no completamente certificado en PCI.",None,"high"),
    ("2026-04-07","smartvista","Los componentes de SmartVista exponen datos al legado mediante S3 (AWS Transfer Family) para contabilidad, maquila, prevenciÃ³n de fraudes, conciliaciones y estados de cuenta; estas interfaces son temporales.",None,"medium"),
    ("2026-04-07","cronograma","Para R3, la deuda tÃ©cnica, la transiciÃ³n y la remediaciÃ³n se integran en un Ãºnico plan de gestiÃ³n del track; diferente al R2 donde se gestionaron de forma aislada. LecciÃ³n aprendida aplicada.","pablo-lorenzo","high"),
    ("2026-04-07","smartvista","El presupuesto base de SmartVista debe ajustarse y el business case debe alinearse a las metas de 2030 â€” la alineaciÃ³n actual no refleja la realidad del alcance.",None,"high"),
    ("2026-04-07","transact","Transact opera con arquitectura transitoria en producciÃ³n y carece de Arquitectura Objetivo (To-Be) definida; incluso la arquitectura transitoria actual no estÃ¡ 100% cerrada.",None,"high"),
    ("2026-04-07","transact","Solo las brechas de ambientes y la capa de seguridad tienen plan de remediaciÃ³n con responsable y fecha comprometida; todas las demÃ¡s brechas crÃ­ticas de alto impacto estÃ¡n sin plan.","pablo-lorenzo","high"),
    ("2026-04-07","transact","El principal cuello de botella de Transact son los equipos externos (Apolo, SmartVista) que no pueden asignar personal por otros compromisos; podrÃ­a retrasar la finalizaciÃ³n significativamente despuÃ©s de 2030.",None,"high"),
    ("2026-04-07","transact","La plataforma de Transact estÃ¡ crÃ­ticamente desactualizada sin haber recibido actualizaciones desde octubre de 2015 â€” mÃ¡s de 10 aÃ±os sin versiÃ³n nueva.",None,"high"),
    ("2026-04-07","transact","Transact presenta desincronizaciones constantes en producciÃ³n entre sus herramientas internas (TDH) y fallos en interfaces contables; la soluciÃ³n en producciÃ³n no es estable.",None,"high"),
    ("2026-04-07","transact","MÃ¡s de 15,000 stored procedures en el core legado soportan SPEI y autorizaciones de tarjetas; las Ã¡reas de pagos tienen dependencia crÃ­tica de esta lÃ³gica.",None,"high"),
    ("2026-04-07","transact","El despliegue del aplicativo Transact se realiza de forma manual; no hay automatizaciÃ³n de deployment. Los procesos burocrÃ¡ticos de tickets toman aproximadamente 30 dÃ­as para habilitar prerrequisitos de instalaciÃ³n.",None,"high"),
    ("2026-04-07","transact","El benchmark actual de Transact en producciÃ³n solo soporta 50 transacciones por minuto â€” RNF de rendimiento insuficiente para una operaciÃ³n bancaria a escala.",None,"high"),
    # â”€â”€ 8 Abril Â· Datos, IntegraciÃ³n, Legacy, Estrategia â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("2026-04-08","datos","Se estÃ¡ definiendo un plan de migraciÃ³n unificado para TDC (PISA â†’ SmartVista) y Banca Minorista (captaciÃ³n y prÃ©stamo personal); debe estar listo antes del viernes.",None,"high"),
    ("2026-04-08","datos","La migraciÃ³n serÃ¡ 100% automÃ¡tica mediante ETL con AWS Glue; la data de PISA se deposita en un bucket S3 de AWS para que el proveedor de carga la tome y la cargue en SmartVista.",None,"high"),
    ("2026-04-08","datos","Se decidiÃ³ contar con ambientes exclusivos (desarrollo, pruebas, UAT) para tareas de migraciÃ³n; los ambientes preproductivos y productivos serÃ¡n compartidos.",None,"medium"),
    ("2026-04-08","atlas","Toda la plataforma de datos Arquitectura 2.0 (incluyendo Atlas/MDM) estarÃ¡ en GCP para unificar la capa de datos, a pesar de que el banco opera principalmente en AWS.",None,"high"),
    ("2026-04-08","atlas","El Maestro de Clientes (MDM en Atlas) debe convertirse en la fuente autoritativa de datos de clientes, quitando esta funciÃ³n a los sistemas core. Transact actualmente obtiene datos de cliente directamente de PISA â€” esta dependencia debe eliminarse.",None,"high"),
    ("2026-04-08","atlas","El piloto de la Customer Data Platform (CDP) de Atlas iniciarÃ¡ en el banco, no en Afore ni CrÃ©dito Coppel. La capa inicial de sincronizaciÃ³n de clientes y CDP debe estar operativa para mediados de 2026.",None,"high"),
    ("2026-04-08","datos","El equipo no tiene experiencia previa con AWS Glue; se priorizarÃ¡ la transferencia de conocimiento con el proveedor antes de iniciar la ejecuciÃ³n de la migraciÃ³n.",None,"high"),
    ("2026-04-08","datos","El dominio de clientes ya estÃ¡ gobernado al 99.5%; la Fase 2 de gobierno de datos iniciarÃ¡ para incluir el dominio de productos. La calidad de datos requerirÃ¡ anÃ¡lisis profundo en la migraciÃ³n.",None,"medium"),
    ("2026-04-08","integracion","El estÃ¡ndar contract first estÃ¡ confirmado como prÃ¡ctica de diseÃ±o de APIs; la especificaciÃ³n (RAML o Swagger), el contrato y la matriz de transformaciÃ³n son obligatorios antes de desarrollo.",None,"high"),
    ("2026-04-08","integracion","Se propone el Strangler Pattern para casos especÃ­ficos como SPEI, para gestionar entradas y salidas en sistemas legados durante la transiciÃ³n.",None,"medium"),
    ("2026-04-08","integracion","La integraciÃ³n a nivel de datos (ETLs y data hub) estÃ¡ separada de la arquitectura de APIs; ambas capas deben mantenerse conceptualmente distintas.",None,"medium"),
    ("2026-04-08","integracion","El promedio de tres redespliegues por cada despliegue original es un pain point identificado, causado principalmente por incorrecta configuraciÃ³n de rangos de IP entre MuleSoft y APG.",None,"medium"),
    ("2026-04-08","integracion","El API marketplace es actualmente solo interno; no existe acceso externo, incluyendo para Coppel (la empresa hermana). Este es un gap a revisar.",None,"medium"),
    ("2026-04-08","integracion","No existe proceso formal de onboarding para equipos que inician desarrollo de APIs; los accesos a herramientas se proporcionan de forma incremental.",None,"medium"),
    ("2026-04-08","pisa","El objetivo fundamental de Unity es poder decomisionar PISA, pero no existe un mapa funcional de PISA a nivel de arquitectura empresarial, lo que impide cerrar el gap entre sistema legado y priorizaciÃ³n de funcionalidades.","pablo-lorenzo","high"),
    ("2026-04-08","pisa","ActualizaciÃ³n de business case acordada: el time to market y la habilitaciÃ³n de nuevas funcionalidades son mÃ¡s beneficiosos financieramente que el desmantelamiento inmediato de la infraestructura.","pablo-lorenzo","high"),
    ("2026-04-08","pisa","Se adoptÃ³ Seriam como BRM para migrar los 13,000-14,000 stored procedures de PISA; el principio de arquitectura es complementar el core sin modificar la caja para evitar problemas en futuras actualizaciones.",None,"high"),
    ("2026-04-08","pisa","Offi y C Web: la iniciativa mÃ¡s reciente es migrarlos a la nube desde cero en tecnologÃ­as modernas, priorizando por criticidad lo que Apolo no cubrirÃ¡.",None,"medium"),
    ("2026-04-08","datos","Se estÃ¡ considerando implementar Change Data Capture (CDC) para extraer datos (saldos, cuentas, clientes) de la base central Informix â€” estrategia de desacoplamiento no destructiva.",None,"medium"),
    ("2026-04-08","pisa","Caso probado de desacoplamiento SPEI: mover la firma de transacciones al bus aumentÃ³ la capacidad de procesamiento de 450 a 1,600 SPEI por segundo y redujo la carga en la base central.",None,"high"),
    ("2026-04-08","gobierno","Unity busca habilitar el 60% de la estrategia del Plan 2030; sin embargo, la planeaciÃ³n actual excluye Ã¡reas crÃ­ticas habilitadoras: Operaciones, Normatividad, Contabilidad y ReporterÃ­a a la autoridad.","pablo-lorenzo","high"),
    ("2026-04-08","gobierno","No existe un plan de gobierno integral end-to-end ni un roadmap maestro transversal; los mapas existentes son colecciones de roadmaps individuales por dominio, sin coordinaciÃ³n de value streams ni responsable Ãºnico.","pablo-lorenzo","high"),
    ("2026-04-08","cronograma","El roadmap es considerado realista solo a corto plazo (hasta 2027) para onboarding y originaciÃ³n; mÃ¡s allÃ¡, la capacidad instalada y la complejidad de paralelismos hacen inviable la planeaciÃ³n actual.","pablo-lorenzo","high"),
    ("2026-04-08","gobierno","Se cuestionÃ³ la metodologÃ­a Ã¡gil para este proyecto, sugiriendo que no es un entorno VUCA y que el agile actual impide establecer compromisos de tiempo y fecha precisos.","pablo-lorenzo","medium"),
    ("2026-04-08","gobierno","Se identificaron cinco estrategias de proyecto faltantes o inmaduras: monitoreo y soporte, deployment, migraciÃ³n, testing y rollout. El enfoque se ha centrado demasiado en la funcionalidad del producto.","pablo-lorenzo","high"),
    ("2026-04-08","cronograma","El crecimiento proyectado relacionado con Unity en nÃ³mina es del 5%, impulsado por las funcionalidades habilitadas y no por el core en sÃ­ mismo â€” correcciÃ³n importante de expectativas de negocio.",None,"medium"),
    ("2026-04-08","gobierno","Los proveedores de software (ej. SmartVista) solo pueden ofrecer visiÃ³n dentro de los lÃ­mites de su propio producto; el banco debe establecer una visiÃ³n integral por encima de los distintos vendors.","pablo-lorenzo","high"),
]

# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# POSITIONS â€” (stakeholder_id, topic, stance, sentiment, date)
# sentiment âˆˆ {supportive, concerned, blocking, neutral}
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
POSITIONS = [
    ("pablo-lorenzo","cronograma","Pablo Lorenzo asume la responsabilidad de construir el plan integrado E2E que el programa no tiene; considera los planes existentes fragmentados e insuficientes para sostener compromisos ante la junta directiva.","concerned","2026-04-16"),
    ("pablo-lorenzo","testing","Pablo Lorenzo identifica los pain points de testing (SIT hasta 5 meses, UAT hasta 2 meses, ambiente Ãºnico compartido) como riesgos sistÃ©micos del programa, no como anomalÃ­as puntuales.","concerned","2026-04-15"),
    ("pablo-lorenzo","atlas","Pablo Lorenzo propone activamente mejoras al plan de migraciÃ³n (dry runs y dress rehearsals) que no existÃ­an en el plan original; considera el plan de migraciÃ³n actual incompleto y riesgoso.","concerned","2026-04-16"),
    ("pablo-lorenzo","integracion","Pablo Lorenzo reconoce que la integraciÃ³n de Transact con canales es una dependencia bloqueante no resuelta en el plan actual y toma la responsabilidad de crear el plan unificado.","concerned","2026-04-10"),
    ("lukasz-pietrzyk","smartvista","Lukasz Pietrzyk presiona sistemÃ¡ticamente por obtener visiÃ³n integral de SmartVista incluyendo TDD, aunque el equipo informa que no estÃ¡ en el backlog. Ve brechas de alcance que podrÃ­an afectar el roadmap Unity completo.","concerned","2026-04-23"),
    ("lukasz-pietrzyk","arquitectura","Lukasz Pietrzyk impulsa activamente el inicio del mapeo formal de capacidades empresariales para SmartVista, reconociendo que no ha comenzado. Identifica esto como un riesgo fundacional.","concerned","2026-04-23"),
    ("lukasz-pietrzyk","integracion","Lukasz Pietrzyk identifica la falta de un inventario consolidado de interfaces en todos los streams (Apolo, SmartVista, Legacy) como un gap diagnÃ³stico crÃ­tico.","concerned","2026-04-23"),
    ("juan-manuel","cronograma","Juan Manuel solicitÃ³ urgentemente el plan E2E para la junta directiva del 24 de abril; su postura seÃ±ala insatisfacciÃ³n con los planes fragmentados por stream y presiÃ³n ejecutiva para obtener compromisos de fechas ante el consejo.","concerned","2026-04-16"),
    ("juan-manuel","gobierno","Juan Manuel es el driver del diligence de 6 semanas sobre gobierno y tecnologÃ­a; su postura implÃ­cita es que el programa Unity no tiene el nivel de madurez de governance esperado para un programa de esta magnitud.","concerned","2026-04-15"),
    ("lukasz-pietrzyk","transact","Lukasz considera la vista de capacidades por release como crÃ­tica y no negociable para el plan director Unity: sin ella es imposible garantizar que ninguna capacidad quede huÃ©rfana ni detectar conflictos de duplicaciÃ³n.","concerned","2026-04-23"),
    ("lukasz-pietrzyk","atlas","Lukasz estÃ¡ preocupado especÃ­ficamente por la latencia en la integraciÃ³n del Golden Record con consumidores en AWS dado que el MDM residirÃ¡ en Google Cloud â€” riesgo tÃ©cnico no resuelto que podrÃ­a comprometer el timeline de diciembre 2026.","concerned","2026-04-28"),
    ("lukasz-pietrzyk","apolo","Lukasz percibe la salida de Lenin como un riesgo crÃ­tico de continuidad en Apolo y actuÃ³ de inmediato ofreciendo contactar a Miguel Bucio. El banco no tiene plan de sucesiÃ³n para roles arquitectÃ³nicos clave.","concerned","2026-04-28"),
    ("lukasz-pietrzyk","arquitectura","Lukasz seÃ±alÃ³ que el problema de latencia de 5 segundos en APIs de Apolo es un problema de diseÃ±o de soluciÃ³n, no de QA â€” delimita explÃ­citamente responsabilidades.","neutral","2026-04-28"),
    ("pablo-lorenzo","cronograma","Pablo Lorenzo propuso la estrategia transgresora de agrupar R3 y R4 con testing exhaustivo, pero reconociÃ³ que el negocio la rechazarÃ­a. Muestra pragmatismo polÃ­tico: prioriza viabilidad organizacional sobre optimizaciÃ³n tÃ©cnica.","neutral","2026-04-24"),
    ("pablo-lorenzo","testing","Pablo Lorenzo es el principal impulsor de la metodologÃ­a de testing transversal (SIT/UAT de 3 meses + dress rehearsals). Su postura es que la integraciÃ³n debe verse como parte del desarrollo, no como fase separada.","supportive","2026-04-28"),
    ("pablo-lorenzo","atlas","Pablo Lorenzo identifica el riesgo de participaciÃ³n del Ã¡rea de Negocio en Atlas como una de las amenazas de gobernanza mÃ¡s importantes. Sin sponsor de negocio el Golden Record no puede completarse correctamente.","concerned","2026-04-28"),
    ("juan-manuel","pisa","Juan Manuel dejÃ³ claro explÃ­citamente que la contabilidad permanece en el sistema legado â€” postura de autoridad que cierra cualquier discusiÃ³n sobre migrar la contabilidad en el alcance actual de Unity.","neutral","2026-04-23"),
    ("daniel-angeles","testing","Daniel Ãngeles del MesanÃ­ es uno de los interlocutores clave para habilitar nuevos ambientes separados por producto; su participaciÃ³n es requerida para resolver la limitaciÃ³n de ambientes que afecta crÃ­ticamente el testing.","neutral","2026-04-28"),
    ("pablo-lorenzo","gobierno","Pablo Lorenzo explicitÃ³ en mÃºltiples sesiones que el programa Unity opera sin inventarios centralizados de integraciones y sin roadmaps unificados; lo posicionÃ³ como la brecha fundacional que impulsa el diligence completo.","concerned","2026-04-28"),
    ("pablo-lorenzo","cronograma","Pablo Lorenzo liderÃ³ la propuesta del modelo 3+3 meses de SIT/UAT con testing no funcional en paralelo y simulacros de producciÃ³n; lo presentÃ³ como condiciÃ³n para que el roadmap sea creÃ­ble ante Juan Manuel.","supportive","2026-04-29"),
    ("pablo-lorenzo","pisa","Pablo Lorenzo reconociÃ³ el legado como caja gris que impide la construcciÃ³n del roadmap; convocÃ³ mÃºltiples stakeholders de legacy para documentar dependencias crÃ­ticas, seÃ±alando que sin eso el roadmap integrado es inestable.","concerned","2026-04-29"),
    ("lukasz-pietrzyk","arquitectura","Lukasz exhibiÃ³ preocupaciÃ³n explÃ­cita ante la partida de Lenin sin sucesor identificado ni knowledge transfer formal; cuestionÃ³ directamente la situaciÃ³n y tomÃ³ acciÃ³n para contactar a Miguel Bucio.","concerned","2026-04-28"),
    ("lukasz-pietrzyk","smartvista","Lukasz seÃ±alÃ³ que la documentaciÃ³n sobre el autorizador de SmartVista era confusa y que posiblemente el mÃ³dulo no fue adquirido; presionÃ³ para obtener claridad sobre quÃ© mÃ³dulos estÃ¡n contratados.","concerned","2026-04-28"),
    ("lukasz-pietrzyk","arquitectura","Lukasz cuestionÃ³ que solo 9 hallazgos de arquitectura hayan sido resueltos y que la mayorÃ­a sigan abiertos; expresa implÃ­citamente que la prioridad de releases por sobre deuda tÃ©cnica es una decisiÃ³n de riesgo alto.","concerned","2026-04-28"),
    ("lukasz-pietrzyk","integracion","Lukasz identificÃ³ tensiÃ³n multi-cloud no resuelta (GCP para datos, AWS para procesadores bancarios) y preguntÃ³ si se habÃ­an evaluado los requerimientos de latencia desde perspectiva bancaria â€” seÃ±al de riesgo arquitectÃ³nico implÃ­cito.","concerned","2026-04-28"),
    ("arturo-perez","pisa","Arturo PÃ©rez solicitÃ³ mÃ¡s contexto antes de comprometerse con la sesiÃ³n; propuso reencuadrar la conversaciÃ³n desde quÃ© necesita Unity del legado en lugar de revisar aplicativos en un listado â€” postura de resistencia funcional.","concerned","2026-04-29"),
    ("arturo-perez","gobierno","Arturo PÃ©rez propuso un grupo de chat de Google para seguimiento porque las sesiones calendarizadas son insuficientes para el ritmo de cambios; postura pragmÃ¡tica que revela que la coordinaciÃ³n formal no estÃ¡ funcionando.","neutral","2026-04-29"),
    ("juan-manuel","cronograma","Juan Manuel solicitÃ³ explÃ­citamente apoyo especial para construir el roadmap integrado unificando los roadmaps individuales por stream; su peticiÃ³n directa a Accenture revela insatisfacciÃ³n implÃ­cita con el estado actual del programa.","concerned","2026-04-28"),
    ("juan-manuel","integracion","Juan Manuel identificÃ³ la revisiÃ³n del inventario de integraciones como necesidad fundacional del diligence; el hecho de que no exista ese inventario centralizado es una brecha que Ã©l mismo hizo visible ante el equipo externo.","concerned","2026-04-28"),
    ("rodrigo","apolo","Rodrigo confirmÃ³ que el Business Case de Apolo contempla diferentes incrementos hasta 2028; al validar este alcance se posicionÃ³ como defensor de la inclusiÃ³n de todos los tracks de Apolo en el roadmap integrado.","supportive","2026-04-29"),
    ("pablo-lorenzo","gobierno","Pablo Lorenzo diagnosticÃ³ que los problemas del programa son de metodologÃ­a y coordinaciÃ³n, no de talento â€” postura que protege al equipo pero exige un cambio estructural de proceso que implica una intervenciÃ³n a nivel de gobierno.","supportive","2026-04-30"),
    ("arcadio","arquitectura","Arcadio estableciÃ³ que todos los planes de remediaciÃ³n deben pasar por supervisiÃ³n y visto bueno de su equipo de arquitectura, y que los arquitectos deben participar desde el inicio de los grupos de trabajo. Es una postura de control de calidad tÃ©cnica proactiva.","supportive","2026-04-07"),
    ("pablo-lorenzo","apolo","Pablo Lorenzo identificÃ³ que la ausencia de negocio desde el origen de Apolo es la causa raÃ­z de las brechas del R2. Esta lectura retrospectiva implica que el modelo de delivery fue incorrecto desde el diseÃ±o, no solo en la ejecuciÃ³n.","concerned","2026-04-07"),
    ("lukasz-pietrzyk","apolo","Lukasz estuvo presente en la sesiÃ³n de Apolo Arquitectura como arquitecto global, alineado con el diagnÃ³stico de que el proceso concentra riesgo al final del ciclo. Su participaciÃ³n implica respaldo tÃ©cnico a las conclusiones de remediaciÃ³n planteadas.","supportive","2026-04-07"),
    ("luis-barragan","smartvista","Luis BarragÃ¡n seÃ±alÃ³ que el producto SmartVista inicialmente no se concibiÃ³ en sus tres etapas (originaciÃ³n, operaciÃ³n y postventa) y que las polÃ­ticas de crÃ©dito no se integraron desde el inicio. Identifica el problema como un defecto de scope original.","concerned","2026-04-07"),
    ("pablo-lorenzo","smartvista","Pablo Lorenzo aplicÃ³ la lecciÃ³n del R2: para R3, la deuda tÃ©cnica, la transiciÃ³n y la remediaciÃ³n se integran en un Ãºnico plan de gestiÃ³n del track. Su postura es explÃ­citamente correctiva respecto al modelo anterior.","supportive","2026-04-07"),
    ("pablo-lorenzo","transact","Pablo Lorenzo evidencia una preocupaciÃ³n aguda con Transact: la plataforma no tiene actualizaciones desde octubre de 2015 y opera sin arquitectura To-Be definida, mientras el roadmap se extiende a 2029. Considera este estado inconsistente e inviable.","concerned","2026-04-07"),
    ("lukasz-pietrzyk","transact","Lukasz Pietrzyk identificÃ³ que el modelo hÃ­brido de integraciÃ³n y la forma Ã¡gil en que los canales abordan los cambios impiden establecer compromisos de tiempo y fecha con precisiÃ³n. SeÃ±ala un problema estructural del modelo de delivery de Transact.","concerned","2026-04-07"),
    ("luis-barragan","transact","Luis BarragÃ¡n es consciente de los cuellos de botella por procesos burocrÃ¡ticos (30 dÃ­as para habilitar un ambiente) y de la dependencia crÃ­tica en equipos externos. Su presencia sugiere que estÃ¡ gestionando expectativas hacia arriba en el programa.","concerned","2026-04-07"),
    ("karina-zepeda","transact","Karina Zepeda participÃ³ en la revisiÃ³n de arquitectura de Transact, confirmando que el equipo ACN tiene visibilidad directa de las brechas crÃ­ticas identificadas â€” ausencia de To-Be, plataforma obsoleta, despliegue manual.","neutral","2026-04-07"),
    ("lukasz-pietrzyk","datos","Lukasz Pietrzyk participÃ³ en la sesiÃ³n de datos y migraciÃ³n como arquitecto global, alineando el enfoque de migraciÃ³n automÃ¡tica por ETL y la separaciÃ³n de arquitectura de datos en GCP. Su presencia valida tÃ©cnicamente las decisiones de Atlas.","supportive","2026-04-08"),
    ("pablo-lorenzo","datos","Pablo Lorenzo impulsÃ³ la coordinaciÃ³n de los planes de migraciÃ³n TDC y banca minorista como un plan unificado; reconoce que la capacidad del personal es el principal cuello de botella para la ejecuciÃ³n.","concerned","2026-04-08"),
    ("pablo-lorenzo","integracion","Pablo Lorenzo empujÃ³ por una visiÃ³n holÃ­stica de la arquitectura de interoperabilidad que trascienda la capa de APIs e incluya orquestaciÃ³n de procesos, integraciÃ³n de datos, observabilidad y coexistencia MDM. La visiÃ³n actual de integraciÃ³n es demasiado estrecha.","concerned","2026-04-08"),
    ("arturo-perez","pisa","Arturo PÃ©rez confirmÃ³ que la visiÃ³n funcional de PISA existe en manuales de usuario y reglas de negocio auditadas, y que el conocimiento reside en el personal. Postura de colaboraciÃ³n activa en la extracciÃ³n de reglas del sistema legado.","supportive","2026-04-08"),
    ("alejandro-gallegos","pisa","Alejandro Gallegos participÃ³ en la sesiÃ³n de arquitectura legacy como observador del diagnÃ³stico sobre la falta de mapa funcional de PISA y la necesidad de actualizar el business case. Tiene conocimiento directo de estos gaps.","neutral","2026-04-08"),
    ("salomon-monroy","pisa","SalomÃ³n Monroy participÃ³ en la sesiÃ³n de arquitectura legacy, alineado con el diagnÃ³stico de estrategia de decomisiÃ³n de PISA y la adopciÃ³n de BRM con Seriam. Observador de las decisiones de estrategia de desacoplamiento.","neutral","2026-04-08"),
    ("pablo-lorenzo","gobierno","Pablo Lorenzo identificÃ³ el desalineamiento significativo entre expectativas de negocio y capacidad de TI, y la ausencia de gobierno end-to-end como el problema mÃ¡s crÃ­tico del programa. Requiere un responsable Ãºnico accountable y un roadmap maestro transversal.","concerned","2026-04-08"),
    ("luis-barragan","gobierno","Luis BarragÃ¡n es consciente del problema de capacidad: proyectos transversales como Transact compiten con 18 desarrollos existentes y solo cinco personas soportan la operaciÃ³n de captaciÃ³n completa. Postura implÃ­cita de alarma sobre la sostenibilidad del modelo.","concerned","2026-04-08"),
    ("pablo-lorenzo","cronograma","Pablo Lorenzo cuestionÃ³ la metodologÃ­a Ã¡gil para este proyecto al seÃ±alar que no es un entorno VUCA, y que el modelo impide establecer compromisos precisos. Postura estratÃ©gica significativa que podrÃ­a impactar el modelo de delivery de todo el programa.","concerned","2026-04-08"),
    ("brenda","gobierno","Brenda fue identificada como el canal formal para solicitar los expedientes CNBV; su postura es de colaboraciÃ³n pero implica que la obtenciÃ³n de esos documentos requiere gestiÃ³n formal a travÃ©s de su Ã¡rea.","neutral","2026-04-23"),
    ("carlos-bc","gobierno","Carlos lidera el comitÃ© de estatus quincenal con 57 invitados donde se plantean dependencias no cumplidas; su alta presiÃ³n sobre el programa implica un rol de oversight activo con expectativas muy altas de puntualidad y entrega.","concerned","2026-04-28"),
    ("gabriela-maximiliano","gobierno","Gabriela Maximiliano fue identificada como responsable de invitar a Cristian Zazueta a las reuniones semanales de SmartVista y Transact â€” su postura de coordinaciÃ³n operativa la posiciona como facilitadora de la integraciÃ³n entre Atlas y los streams.","neutral","2026-04-28"),
    ("rodrigo","gobierno","Rodrigo confirma el business case de Apolo hasta 2028; su postura al validar el alcance estratÃ©gico sin cuestionarlo implica respaldo al roadmap propuesto aunque sin comprometerse en fechas tÃ©cnicas.","supportive","2026-04-29"),
    ("erica-mata","seguridad","Erica Mata (CISO) tiene preocupaciÃ³n implÃ­cita sobre si las interfaces temporales de SmartVista con el legado estÃ¡n pasando datos sensibles a un sistema legado no completamente certificado en PCI â€” riesgo de seguridad estructural del programa.","concerned","2026-04-07"),
    ("karina-zepeda","pisa","Karina Zepeda participÃ³ como liaison del equipo ACN con el legacy; su presencia en sesiones de arquitectura del sistema legado indica que el equipo ACN estÃ¡ construyendo conocimiento directo de PISA para el diligence.","neutral","2026-04-23"),
    ("pablo-lorenzo","cronograma","Pablo Lorenzo impulsa una postura agresiva hacia el roadmap: divide R4 en tres liberaciones independientes, exige que el roadmap sea integral con assumptions y riesgos, y establece ciclos de prueba separados. Implica que el programa ha operado con planeaciÃ³n naÃ¯ve hasta ahora.","concerned","2026-04-30"),
    ("emmy","apolo","Emmy (Apoyo Negocio) fue identificada como contacto para clarificar requerimientos de onboarding N4 y la estrategia de negocio; su presencia implica que el Ã¡rea de negocio tiene representaciÃ³n aunque limitada en las mesas tÃ©cnicas.","neutral","2026-04-23"),
    # â”€â”€ 3 posiciones adicionales (clave natural distinta a las anteriores) â”€â”€
    ("alejandro-gallegos","integracion","Alejandro Gallegos participÃ³ en la sesiÃ³n de arquitectura de integraciÃ³n del 8 de abril como observador del diagnÃ³stico sobre el API marketplace y el estÃ¡ndar contract-first; tiene visibilidad directa de las brechas de onboarding y la falta de proceso formal para equipos que consumen APIs.","neutral","2026-04-08"),
    ("salomon-monroy","cronograma","SalomÃ³n Monroy participÃ³ como observador en la sesiÃ³n de estrategia y roadmap del 8 de abril donde Pablo Lorenzo expuso las cinco estrategias faltantes del programa; su presencia implica que el equipo ACN tiene evidencia directa del gap entre el alcance del negocio y la capacidad operativa de Unity.","neutral","2026-04-08"),
    ("brenda","regulatorio","Brenda Pichardo fue identificada como el canal para obtener los expedientes CNBV que contienen arquitecturas de referencia de Apolo, SmartVista y Transact; su postura implica que el acceso a documentaciÃ³n regulatoria estratÃ©gica requiere gestiÃ³n formal a travÃ©s de su Ã¡rea, lo que introduce fricciÃ³n en el proceso de diligence.","neutral","2026-04-28"),
]

# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# OPEN_ITEMS â€” (date, item, owner_id, priority, systems_list)
# priority âˆˆ {high, medium, low}
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
OPEN_ITEMS_RAW = [
    # â”€â”€ 10 Abril Â· Transact â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("2026-04-10","Crear plan unificado de fechas para la integraciÃ³n de Transact con canales; los equipos de canales confirmaron que no pueden asumir el compromiso actual del plan de integraciÃ³n.",None,"high",["transact","integracion"]),
    ("2026-04-10","Detallar planes de trabajo para 2026 y 2027 e incluir el plan de migraciÃ³n para 2028 reflejando los cambios solicitados por el negocio (cuenta N4 priorizada, Escenario 2).","pablo-lorenzo","high",["transact"]),
    ("2026-04-10","Compartir lista completa de integraciones de Transact con volumetrÃ­a de transacciones, clientes y nÃºmero de cuentas en formato editable.",None,"high",["transact","integracion"]),
    ("2026-04-10","Documentar los supuestos internos y externos utilizados para estimar los tiempos de implementaciÃ³n de Transact, incluyendo la dependencia crÃ­tica de disponibilidad de tarjeta de dÃ©bito en la prÃ³xima PI.",None,"medium",["transact"]),
    # â”€â”€ 15 Abril Â· Testing â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("2026-04-15","Crear roadmap integrado transversal hasta 2030 que unifique las visiones de Transact, Apolo, SmartVista y Legacy con capas de anÃ¡lisis, diseÃ±o, construcciÃ³n y testing por drops.","pablo-lorenzo","high",["transact","apolo","smartvista","pisa"]),
    ("2026-04-15","Identificar y documentar plan de remediaciÃ³n para los pain points sistÃ©micos del testing: SIT extendido hasta 5 meses, UAT extendido hasta 2 meses por baja dedicaciÃ³n del negocio, conflicto de ambiente Ãºnico, e incumplimiento de SLAs de BPC.",None,"high",["testing","smartvista","apolo"]),
    # â”€â”€ 16 Abril Â· Atlas â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("2026-04-16","Crear y presentar el plan integrado E2E â€” incluyendo inputs de Transact, Apolo, SmartVista y Legacy â€” para la junta directiva de accionistas del 24 de abril.","pablo-lorenzo","high",["transact","apolo","smartvista","pisa","atlas"]),
    ("2026-04-16","Generar plan general detallado del Proyecto Atlas en conjunto con el equipo de Arquitectura para presentar esta semana; incluir las 4 fases (Crawl/Walk/Run/Fly) con fechas concretas.",None,"high",["atlas"]),
    ("2026-04-16","Incorporar dry runs (simulacros integrales de ETL antes de UAT) y Dress Rehearsals (2-3 simulacros de go-live en preproductivo) al plan de migraciÃ³n de datos de cada ola de Atlas.","pablo-lorenzo","high",["atlas","pisa"]),
    # â”€â”€ 23 Abril Â· Apolo + Legacy + SmartVista â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("2026-04-23","Consolidar el inventario de APIs de Apolo (~600 APIs) separadas por building block en una vista unificada; obtener acceso de solo lectura a la documentaciÃ³n de integraciones de Apolo TDC (R3).",None,"high",["apolo","integracion"]),
    ("2026-04-23","Identificar al arquitecto responsable del track Apolo N4/dÃ©bito para obtener visiÃ³n completa de interfaces de ese alcance.",None,"high",["apolo"]),
    ("2026-04-23","Investigar si existe un plan formal para reducir la latencia de 5 segundos en la capa proxy de Apolo en producciÃ³n, considerando que la situaciÃ³n empeorarÃ¡ con Web Methods y el cifrado de datos sensibles.",None,"high",["apolo"]),
    ("2026-04-23","Verificar el estatus regulatorio (CNBV, Banxico, Ley de ProtecciÃ³n de Datos) de los datos personales de Apolo almacenados sin cifrar en AWS fuera del territorio mexicano (CURP, RFC, telÃ©fono, email).",None,"high",["apolo","seguridad","regulatorio"]),
    ("2026-04-23","Contactar a Juan AndrÃ©s, Ã“scar Melo o Luis BarragÃ¡n para solicitar y analizar el inventario completo de APIs del sistema Legacy (600-700 APIs existentes del equipo de habilitadores).","pablo-lorenzo","high",["pisa","integracion"]),
    ("2026-04-23","Solicitar a Brenda Pichardo los expedientes entregados a la CNBV para Transact, SmartVista y Apolo como fuente de arquitecturas de referencia e inventario de interfaces del Legacy.","brenda","high",["pisa","transact","smartvista","apolo","regulatorio"]),
    ("2026-04-23","Documentar el alcance funcional de PISA y sus customizaciones mediante entrevistas con subdirectores de desarrollo y operaciones, para reflejar la cobertura real en el diagrama de arquitectura del programa.",None,"medium",["pisa"]),
    ("2026-04-23","Formalizar el requerimiento de Tarjeta de DÃ©bito (TDD) para SmartVista con Sergio del Valle; actualmente no estÃ¡ en el backlog y carece de estimaciones, riesgos y dependencias documentadas.",None,"high",["smartvista"]),
    ("2026-04-23","Solicitar inventario de interfaces R2 y R3 de SmartVista/TDC con detalle de sistemas de origen y destino.","pablo-lorenzo","high",["smartvista","integracion"]),
    ("2026-04-23","Planificar reuniÃ³n formal para iniciar el ejercicio de mapeo de capacidades empresariales de SmartVista; Ana Rosa y Leonardo confirmarÃ¡n los participantes del equipo de arquitectura.","pablo-lorenzo","high",["smartvista","arquitectura"]),
    # â”€â”€ 24 Abril Â· SmartVista + Transact â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("2026-04-24","Organizar sesiÃ³n de mapeo de capacidades de arquitectura funcional de Apolo con equipos de arquitectura y lÃ­deres tÃ©cnicos; consultar con Leonardo cuÃ¡les arquitectos deben participar.","pablo-lorenzo","high",["apolo","arquitectura"]),
    ("2026-04-24","Validar el plan integral (assumptions, alcance, roadmap) con Sergio del Valle antes de presentarlo a Juan Manuel.","pablo-lorenzo","high",["cronograma","gobierno"]),
    ("2026-04-24","Contactar a David Estrada para obtener fechas y cronograma del proyecto Copel Pay y definir si habrÃ¡ front dedicado de onboarding o se manejarÃ¡ vÃ­a promociones.",None,"medium",["smartvista"]),
    ("2026-04-24","Confirmar con Araceli Barcena (PM de Transact) si la versiÃ³n N4 de Cuenta Digital usa Apolo o el back de sucursal para el onboarding.",None,"high",["transact","apolo"]),
    ("2026-04-24","Proveer listado de dependencias crÃ­ticas del legacy para Transact incluyendo Western Union, recargas de tiempo aire y pago de servicios â€” enviar antes del siguiente miÃ©rcoles.",None,"high",["transact","pisa","integracion"]),
    ("2026-04-24","Solicitar sesiÃ³n ejecutiva con Sergio del Valle para presentar y obtener feedback sobre la evoluciÃ³n del mapa integral de Unity hasta 2028.","pablo-lorenzo","high",["cronograma","gobierno"]),
    # â”€â”€ 28 Abril Â· Testing + Arquitectura + Atlas + SmartVista Interfaces â”€â”€â”€â”€
    ("2026-04-28","Iniciar conversaciones con AndrÃ©s, Bucio y Daniel Ãngeles para habilitar ambientes de QA separados por producto (BPC, Launch, OPI, SEW, Apollo) previos al ambiente EIT integrado.","daniel-angeles","high",["testing","apolo","smartvista","transact"]),
    ("2026-04-28","Actualizar la estrategia de pruebas del banco (4 aÃ±os de antigÃ¼edad): revisar herramientas, diagramas de entornos y reflejar estado actual de gestiÃ³n, automatizaciÃ³n y desempeÃ±o.","pablo-lorenzo","medium",["testing"]),
    ("2026-04-28","Socializar con todos los participantes del plan director las brechas crÃ­ticas de testing, las remediaciones propuestas y el enfoque del roadmap integrado â€” alineando supuestos de tiempos de prueba.","pablo-lorenzo","high",["testing","cronograma"]),
    ("2026-04-28","Contactar a Miguel Bucio para revisar la situaciÃ³n crÃ­tica del reemplazo de Lenin (arquitecto Apolo, sale el 31 de mayo), las asignaciones de arquitectos a value streams y las acciones de mitigaciÃ³n necesarias.","lukasz-pietrzyk","high",["apolo","arquitectura"]),
    ("2026-04-28","Verificar quÃ© mÃ³dulos de SmartVista estÃ¡n contratados por BanCoppel, incluyendo el mÃ³dulo autorizador; primera versiÃ³n del anÃ¡lisis esperada a mediados de mayo.",None,"high",["smartvista"]),
    ("2026-04-28","Gestionar inclusiÃ³n del equipo Accenture en la sesiÃ³n con el proveedor SmartVista para revisar quÃ© mÃ³dulos de la plataforma estÃ¡n contratados y habilitados.","lukasz-pietrzyk","high",["smartvista"]),
    ("2026-04-28","Agendar sesiÃ³n de API onboarding con Gabriel Alejandro Maldonado HernÃ¡ndez y Anayeli Ortiz para revisar el procedimiento de incorporaciÃ³n de API.",None,"medium",["arquitectura","integracion"]),
    ("2026-04-28","Consultar a Cristian el estado de asignaciÃ³n de arquitectos con conocimiento bancario al proyecto Atlas para evitar desviaciones en el trabajo posterior.","lukasz-pietrzyk","medium",["atlas","arquitectura"]),
    ("2026-04-28","Desarrollar guÃ­as de arquitectura sobre cuÃ¡ndo y cÃ³mo usar cachÃ© para APIs, considerando integraciÃ³n multi-cloud con legado (Transact y SmartVista); incluir en estÃ¡ndares de arquitectura de Unity.",None,"medium",["arquitectura","smartvista","transact"]),
    ("2026-04-28","Cristian Zazueta debe compartir el plan de trabajo detallado de Atlas (Fase 1 y Fase 2) incluyendo hitos y dependencias crÃ­ticas con el equipo ACN.",None,"high",["atlas"]),
    ("2026-04-28","Cristian Zazueta debe compartir el documento de definiciÃ³n funcional de la carga de datos en SmartVista con BPC (datos para validar la migraciÃ³n de TDC clÃ¡sica).",None,"high",["atlas","smartvista"]),
    ("2026-04-28","Invitar a Cristian Zazueta a las reuniones semanales de SmartVista, Transact y Apolo â€” con prioridad en SmartVista y Transact por ser las migraciones mÃ¡s crÃ­ticas.","gabriela-maximiliano","high",["atlas","smartvista","transact"]),
    ("2026-04-28","Mapear y cuantificar el esfuerzo adicional no mapeado requerido para modificar reportes operativos y regulatorios ante el cambio de ID de producto 6001 â†’ 4900 en SmartVista, y gestionar el perÃ­odo de convivencia de ambos IDs ante Banxico.",None,"high",["regulatorio","smartvista"]),
    ("2026-04-28","Definir la estrategia detallada de integraciÃ³n del MDM (Golden Record en Google Cloud) con SmartVista y Transact (en AWS): APIs, conexiones multi-cloud y manejo de latencia â€” hito requerido antes de septiembre 2026.",None,"high",["atlas","smartvista","transact","datos"]),
    ("2026-04-28","Identificar y documentar las interfaces inversas de conciliaciÃ³n (de legado hacia SmartVista) que aÃºn no estÃ¡n en producciÃ³n; determinar plan de habilitaciÃ³n y responsable.",None,"high",["smartvista","pisa"]),
    ("2026-04-28","Oscar Melo y Eduardo Ponce deben compartir el fichero Excel del inventario de interfaces batch de SmartVista con prioridades, objetivos, funcionalidades e identificadores.",None,"high",["smartvista","integracion"]),
    ("2026-04-28","Oscar Melo y Eduardo Ponce deben enviar los archivos originales en formato Draw.io de los flujos de interfaces SmartVista (los PDFs actuales son inadecuados para el anÃ¡lisis).",None,"medium",["smartvista","integracion"]),
    ("2026-04-28","Agendar sesiÃ³n con el equipo QA a principios de la semana siguiente para socializar brechas crÃ­ticas, remediaciones y el enfoque propuesto para el roadmap integrado de pruebas, alineando supuestos de tiempos con mejores prÃ¡cticas.","pablo-lorenzo","high",["testing"]),
    ("2026-04-28","Proponer SLAs mÃ¡s realistas para resoluciÃ³n de defectos (los actuales â€”4 horas para crÃ­ticosâ€” nunca se cumplen); el equipo de QA no tiene alternativa definida y este punto quedÃ³ abierto.",None,"medium",["testing"]),
    # â”€â”€ 29 Abril Â· Transact + Apolo + Legado â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("2026-04-29","Entregar trazado de capacidades de arquitectura a lo largo del tiempo (progreso por releases, no solo End State) para su revisiÃ³n el martes siguiente.",None,"high",["transact","arquitectura"]),
    ("2026-04-29","Detallar el estado de dependencias crÃ­ticas entre Transact y el legado (Western Union, recargas y otros servicios); coordinar con Gloria y buscar documentaciÃ³n existente.",None,"high",["transact","pisa"]),
    ("2026-04-29","Preparar versiÃ³n estable del roadmap integrado para Juan Manuel con diapositivas explicativas, riesgos documentados e hipÃ³tesis que justifiquen posibles retrasos futuros; listo para socializar el martes.","pablo-lorenzo","high",["transact","apolo","smartvista"]),
    ("2026-04-29","Agendar sesiÃ³n de 30 minutos con Luis Arturo Valdivieso Cruz el 30 de abril para revisar en detalle el roadmap de Apolo R4.","pablo-lorenzo","high",["apolo"]),
    ("2026-04-29","Actualizar la carpeta normativa CNBV incorporando los desarrollos de Apolo R4 necesarios para la salida a mercado abierto en diciembre 2026.",None,"high",["apolo","regulatorio"]),
    ("2026-04-29","Clarificar si existen tareas de migraciÃ³n o dependencias crÃ­ticas con Legacy para SmartVista R3 y R4, y evaluar opciones para asumir riesgos y acortar Go-Lives.",None,"high",["smartvista","pisa","cronograma"]),
    ("2026-04-29","Crear grupo de chat de Google para seguimiento Ã¡gil de temas de legado, sumando gerentes del equipo de Arturo PÃ©rez.","arturo-perez","medium",["pisa","gobierno"]),
    ("2026-04-29","Planificar workshops detalladas de impacto de Unity en legado por aplicativo (CW/Offi, cajeros, POS, Ares), incluyendo personal crÃ­tico de los streams Apolo, SmartVista y Transact.","pablo-lorenzo","high",["pisa","apolo","smartvista","transact"]),
    ("2026-04-29","Confirmar si los sistemas legados actuales de POS/ATM serÃ¡n dados de baja para la conexiÃ³n con Iglobe â€” implicaciÃ³n arquitectÃ³nica no resuelta.",None,"high",["smartvista","pisa"]),
    ("2026-04-29","Revalidar el inventario de aplicativos legados identificados, separando aplicativos reales de agrupaciones de stored procedures, con participaciÃ³n de equipos de desarrollo de Unity.",None,"medium",["pisa","gobierno"]),
    ("2026-04-29","Verificar si la integraciÃ³n de Onbase a Transact que ya existe corresponde a la Transact de Unity o a otra instancia â€” dato crÃ­tico para evitar doble trabajo.",None,"medium",["transact","pisa"]),
    # â”€â”€ 30 Abril â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("2026-04-30","Actualizar el roadmap para reflejar la divisiÃ³n de R4 en tres liberaciones independientes y validar assumptions y riesgos del plan.","pablo-lorenzo","high",["smartvista","apolo"]),
    ("2026-04-30","Identificar un Ãºnico punto de contacto con el equipo de Legado y planificar workshops enfocados por track (uno para Transact, uno para SmartVista).",None,"high",["pisa","transact","smartvista"]),
    ("2026-04-30","Estandarizar y unificar los formatos de los inventarios de interfaces â€” trabajo a realizar despuÃ©s de que finalice el diligence de Accenture.",None,"medium",["integracion","smartvista","transact"]),
    # â”€â”€ 7 Abril â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("2026-04-07","Priorizar el desarrollo de la funcionalidad de clientes existentes para R3/R4 antes de la salida a mercado abierto â€” cambio que modifica la esencia de Apolo.",None,"high",["apolo"]),
    ("2026-04-07","Compartir inventario de desacoplamiento de APIs especificando la proporciÃ³n de microservicios desacoplados versus stored procedures directos (actualmente 60/40).",None,"medium",["apolo","integracion"]),
    ("2026-04-07","Ligar el DRP para que incluya Apolo y SmartVista de forma conjunta; actualmente no existe gobierno transversal de transaccionalidad.",None,"high",["apolo","smartvista"]),
    ("2026-04-07","Implementar pruebas de rendimiento formales para evaluar capacidad de Apolo bajo volÃºmenes de producciÃ³n â€” aÃºn no realizadas.",None,"high",["apolo"]),
    ("2026-04-07","Implementar herramientas de monitoreo para detectar fallas y detener campaÃ±as de trÃ¡fico pagado (97% del trÃ¡fico de onboarding) para evitar pÃ©rdidas.",None,"high",["apolo"]),
    ("2026-04-07","Compartir el roadmap R4 de SmartVista incluyendo riesgos y dependencias mapeadas por equipos de TI.",None,"high",["smartvista","cronograma"]),
    ("2026-04-07","Ajustar el presupuesto base de SmartVista y alinear el business case a las metas de 2030.",None,"high",["smartvista"]),
    ("2026-04-07","Implementar el preautorizador de SmartVista como precondiciÃ³n obligatoria para iniciar la migraciÃ³n de portafolio TDC.",None,"high",["smartvista","atlas"]),
    ("2026-04-07","Compartir la visiÃ³n de interfaces, manual de monitoreo y documentos de SmartVista para revisiÃ³n del equipo (responsable: Jose Jaimes Ortiz).",None,"medium",["smartvista","integracion"]),
    ("2026-04-07","Definir la Arquitectura Objetivo (To-Be) de Transact â€” actualmente inexistente mientras el roadmap se proyecta a 2029.",None,"high",["transact","arquitectura"]),
    ("2026-04-07","Completar la recopilaciÃ³n de Requisitos No Funcionales (RNF) de rendimiento para Transact â€” el benchmark actual es solo 50 transacciones por minuto.",None,"high",["transact"]),
    ("2026-04-07","Resolver la desactualizaciÃ³n crÃ­tica de la plataforma Transact, que no ha recibido actualizaciones desde octubre de 2015.",None,"high",["transact"]),
    ("2026-04-07","Implementar automatizaciÃ³n del proceso de deployment para Transact y sus componentes â€” actualmente todo es manual y burocrÃ¡tico (~30 dÃ­as para habilitar prerrequisitos).",None,"medium",["transact"]),
    ("2026-04-07","Realizar revisiÃ³n exhaustiva de seguridad a nivel aplicativo de Transact â€” las brechas de infraestructura estÃ¡n identificadas pero falta la revisiÃ³n aplicativa.",None,"high",["transact","seguridad"]),
    # â”€â”€ 8 Abril â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ("2026-04-08","Generar y compartir el plan integral de migraciÃ³n unificado (TDC y Banca Minorista) antes del viernes; responsable: Christian Zazueta.",None,"high",["datos","atlas","smartvista"]),
    ("2026-04-08","Compartir el diccionario de datos completo y los orÃ­genes mapeados del dominio de clientes; responsable: Christian Zazueta.",None,"medium",["datos","atlas"]),
    ("2026-04-08","Compartir slides de Atlas y detalles especÃ­ficos del proyecto con el equipo de Accenture; responsable: RaÃºl Goycoolea.",None,"medium",["atlas"]),
    ("2026-04-08","Priorizar la transferencia de conocimiento de AWS Glue con el proveedor antes de iniciar la ejecuciÃ³n de la migraciÃ³n automatizada.",None,"high",["datos","atlas"]),
    ("2026-04-08","Coordinar sesiÃ³n de seguimiento para discutir temas de migraciÃ³n y gobierno de datos entre BanCoppel y Accenture.",None,"medium",["datos","gobierno"]),
    ("2026-04-08","Revisar el setup actual del marketplace de APIs para confirmar la arquitectura para accesos internos y externos, incluyendo Coppel.",None,"medium",["integracion"]),
    ("2026-04-08","Formalizar un proceso de onboarding para equipos que inician el desarrollo de APIs â€” actualmente inexistente, accesos se dan de forma incremental.",None,"medium",["integracion","gobierno"]),
    ("2026-04-08","Definir el objetivo de capacidad mÃ¡xima para las pruebas de rendimiento del flujo completo de Apolo â€” el objetivo inicial de 50 usuarios/60 segundos es insuficiente para producciÃ³n.",None,"high",["apolo","integracion","testing"]),
    ("2026-04-08","Producir un mapeo de arquitectura a nivel empresarial (no aplicativo) para identificar componentes o mÃ³dulos de PISA no cubiertos por Transact, SmartVista ni Apolo.",None,"high",["pisa","arquitectura"]),
    ("2026-04-08","Reunirse con Luis BarragÃ¡n y Fabiola Corrales para extraer el know-how sobre la contabilidad de PISA con miras a una posible migraciÃ³n a plataforma modernizada.","luis-barragan","high",["pisa"]),
    ("2026-04-08","Actualizar el business case de Unity para reflejar que el time to market y la habilitaciÃ³n de nuevas funcionalidades son mÃ¡s beneficiosos financieramente que el desmantelamiento inmediato de infraestructura.","pablo-lorenzo","high",["pisa","gobierno"]),
    ("2026-04-08","Evaluar y formalizar el plan de implementaciÃ³n de Change Data Capture (CDC) para extracciÃ³n de datos de saldos, cuentas y clientes de la base central Informix.",None,"medium",["pisa","datos"]),
    ("2026-04-08","Asegurar la participaciÃ³n activa de las Ã¡reas de Operaciones, Fiscal, Contabilidad y Normatividad en las mesas de planificaciÃ³n del programa Unity â€” actualmente excluidas.",None,"high",["gobierno","regulatorio"]),
    ("2026-04-08","Desarrollar propuestas de acciones correctivas enfocadas en la direcciÃ³n y estructura del plan de proyecto integral end-to-end de Unity.","pablo-lorenzo","high",["gobierno"]),
    ("2026-04-08","Establecer un responsable Ãºnico (accountable) para el gobierno integral end-to-end del programa Unity â€” brecha crÃ­tica identificada en el diagnÃ³stico estratÃ©gico.",None,"high",["gobierno"]),
    ("2026-04-08","Desarrollar una visiÃ³n de roadmap de negocio a largo plazo (2 a 3 aÃ±os) que guÃ­e las decisiones a nivel de programa/banco, trascendiendo los dominios individuales.",None,"high",["cronograma","gobierno"]),
    ("2026-04-08","Validar con Arcadio la documentaciÃ³n pendiente referente al proyecto Atlas y compartirla lo antes posible.","arcadio","medium",["atlas"]),
]

# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# AsignaciÃ³n de IDs secuenciales
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
DECISIONS = [
    (f"AI-DEC-{i+1:04d}", d[0], d[1], d[2], d[3], d[4])
    for i, d in enumerate(DECISIONS_RAW)
]

OPEN_ITEMS = [
    (f"AI-OI-{i+1:04d}", r[0], r[1], r[2], r[3], json.dumps(r[4]))
    for i, r in enumerate(OPEN_ITEMS_RAW)
]


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
def run():
    db = sqlite3.connect(str(DB))
    db.execute("PRAGMA foreign_keys=ON")

    n_dec = n_pos = n_oi = 0

    for row in DECISIONS:
        # row = (id, date, topic, decision, driver_id, confidence)
        try:
            db.execute(
                "INSERT OR IGNORE INTO decisions "
                "(id, date, topic, decision, driver_id, systems, doc_id, confidence) "
                "VALUES (?,?,?,?,?,?,NULL,?)",
                (row[0], row[1], row[2], row[3], row[4],
                 json.dumps([row[2]]), row[5])
            )
            if db.execute("SELECT changes()").fetchone()[0]:
                n_dec += 1
        except Exception as e:
            print(f"WARN decision {row[0]}: {e}")

    for row in POSITIONS:
        # row = (stakeholder_id, topic, stance, sentiment, date)
        try:
            db.execute(
                "INSERT INTO positions "
                "(stakeholder_id, topic, stance, quote, date, doc_id, sentiment) "
                "VALUES (?,?,?,?,?,NULL,?)",
                (row[0], row[1], row[2], row[2][:120], row[4], row[3])
            )
            n_pos += 1
        except Exception as e:
            print(f"WARN position {row[0]}/{row[1]}: {e}")

    for row in OPEN_ITEMS:
        # row = (id, date, item, owner_id, priority, systems_json)
        try:
            db.execute(
                "INSERT OR IGNORE INTO open_items "
                "(id, date, item, owner_id, priority, systems, doc_id, status) "
                "VALUES (?,?,?,?,?,?,NULL,'open')",
                (row[0], row[1], row[2], row[3], row[4], row[5])
            )
            if db.execute("SELECT changes()").fetchone()[0]:
                n_oi += 1
        except Exception as e:
            print(f"WARN open_item {row[0]}: {e}")

    db.commit()
    print(f"seed-strategic-ai completado:")
    print(f"  Decisiones insertadas : {n_dec} / {len(DECISIONS)}")
    print(f"  Posiciones insertadas : {n_pos} / {len(POSITIONS)}")
    print(f"  Open items insertados : {n_oi} / {len(OPEN_ITEMS)}")
    db.close()


if __name__ == "__main__":
    run()