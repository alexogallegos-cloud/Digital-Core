"""
seed-strategic-ai.py — Inteligencia Estratégica AI-extraída para Bank Brain
Fuente: 33 minutas Plan Director Unity (abril 2026)
Método: análisis semántico implícito + explícito (4 batches en paralelo)

IDs nuevos: AI-DEC-NNNN (decisiones) · AI-OI-NNNN (open items)
IDs existentes preservados: DEC-0001–0074 · OI-0001–0418

Correr: python seed-strategic-ai.py
Es idempotente: INSERT OR IGNORE en decisions y open_items.
Positions no tiene constraint UNIQUE; correr dos veces duplica posiciones.
"""

import json, sqlite3
from pathlib import Path

DB = Path(__file__).parent / "bank-brain.db"

# ─────────────────────────────────────────────────────────────────────────────
# DECISIONS — (date, topic, decision, driver_id, confidence)
# topic ∈ {apolo,smartvista,transact,atlas,pisa,arquitectura,seguridad,
#           gobierno,cronograma,datos,integracion,testing,regulatorio,general}
# ─────────────────────────────────────────────────────────────────────────────
DECISIONS_RAW = [
    # ── 10 Abril · Transact Plan Director ────────────────────────────────────
    ("2026-04-10","transact","El negocio seleccionó el Escenario 2 (riesgo intermedio) como base del plan de implementación de Transact, descartando tanto el escenario conservador como el agresivo.",None,"high"),
    ("2026-04-10","transact","La cuenta N4 fue priorizada para el desarrollo inicial de Transact por generar entre el 80% y 90% de los ingresos; los demás productos quedan subordinados a este arranque.",None,"high"),
    ("2026-04-10","cronograma","La implementación de depósitos (Transact) comienza en 2028 con migración posterior; los créditos se comprometen a Q4 2028 con un solo producto, un solo canal y sin migración inicial.",None,"high"),
    ("2026-04-10","transact","Se adopta el principio de cero personalización para Transact: solo configuración mínima de la plataforma Temenos; las 18 configuraciones/customizaciones de integración identificadas (deltas) son el alcance cerrado de adaptaciones.",None,"high"),
    ("2026-04-10","integracion","Los equipos de canales confirmaron que NO pueden comprometerse con el plan actual de integración con canales; esto obliga a crear un plan unificado de fechas de integración como prerrequisito del roadmap de Transact.",None,"high"),
    ("2026-04-10","cronograma","La implementación de la cuenta N4 en Transact tiene como dependencia crítica que la capacidad de tarjeta de débito sea priorizada en la próxima planificación PI; sin ello la fecha corre riesgo.",None,"high"),
    ("2026-04-10","transact","El equipo técnico de Transact confirmó su capacidad para cumplir las fechas acordadas a pesar del cambio en el producto MVP de cuenta, señalizando confianza interna en el plan.",None,"medium"),
    ("2026-04-10","transact","El alcance de cuentas de Transact incluye funcionalidad de cheques e inversiones (depósitos a plazo con tasas personalizadas) como parte del MVP de cuenta N4.",None,"medium"),
    # ── 15 Abril · Testing ───────────────────────────────────────────────────
    ("2026-04-15","gobierno","El programa de aceleración de 6 semanas impulsado por Juan Manuel se enfoca en gobierno y tecnología con el objetivo explícito de identificar pain points y proponer remediaciones concretas.","juan-manuel","high"),
    ("2026-04-15","testing","La planificación del roadmap se estructura en drops (ventanas de entrega) en lugar de releases para eliminar ambigüedad semántica dentro del programa Unity; Drop One abarca abril 2026 a marzo 2028.","pablo-lorenzo","high"),
    ("2026-04-15","testing","El ambiente homologado es el único entorno de pruebas para SIT, UAT y Performance; construirlo tomó más de 2 años y aún no es un verdadero preproductivo; esta restricción estructural se acepta como estado actual.",None,"high"),
    ("2026-04-15","testing","El criterio de salida real del SIT exige resolución del 100% de defectos antes de pasar a UAT, aunque el umbral formal sea del 80%; el negocio impone el criterio más estricto de facto, elevando el riesgo de bloqueos.",None,"high"),
    ("2026-04-15","testing","Las pruebas de seguridad tienen prioridad exclusiva sobre el ambiente homologado, deteniendo todas las demás actividades de testing; esto convierte al equipo de seguridad en un bloqueante potencial del cronograma.",None,"high"),
    ("2026-04-15","testing","La extensión sistemática del SIT hasta 5 meses (caso Apolo) y del UAT hasta 2 meses se confirma como desviación estructural del programa; la causa raíz del UAT es la baja dedicación del negocio a las pruebas.",None,"high"),
    ("2026-04-15","testing","BPC (proveedor de SmartVista) incumple consistentemente los SLAs de resolución de defectos, tardando días o semanas; esto se establece como riesgo estructural del programa que debe gestionarse como dependencia de proveedor.",None,"high"),
    ("2026-04-15","testing","La automatización de testing cubre cerca del 100% de las rutas críticas de alto valor de negocio (abonos, cargos, pagos de créditos en CW); el enfoque de ROI guía la selección de qué automatizar.",None,"medium"),
    # ── 16 Abril · Atlas + Migración E2E ─────────────────────────────────────
    ("2026-04-16","gobierno","Juan Manuel solicitó urgentemente un plan integral E2E con cronograma consolidado para presentar ante la junta directiva de accionistas el 24 de abril; señaló que los planes existentes estaban demasiado fragmentados por stream.","juan-manuel","high"),
    ("2026-04-16","atlas","La migración de datos a producción solo se realizará una vez que las Pruebas de Aceptación de Usuario (UAT) estén completamente finalizadas; esta secuencia se confirma como política del programa.",None,"high"),
    ("2026-04-16","atlas","Se incorporaron dry runs integrales de ETL (simulacros previos a UAT) para estabilizar el pipeline de migración y validar calidad de datos antes del UAT; este paso no existía en el plan original.","pablo-lorenzo","high"),
    ("2026-04-16","atlas","Se decidió agregar Dress Rehearsals (2-3 simulacros de go-live en ambiente preproductivo) después de UAT y antes de producción para afinar el runbook operativo.","pablo-lorenzo","high"),
    ("2026-04-16","atlas","El Proyecto Atlas tiene una estructura de 2 años dividida en 4 fases metodológicas: Crawl (hasta ago-2026), Walk, Run y Fly; es el primer esfuerzo de migración de datos en la historia del banco.",None,"high"),
    ("2026-04-16","atlas","La Fase 1 Crawl de Atlas debe completarse en agosto 2026 con: golden record básico del dominio de clientes, infraestructura en GCP, MDM v1, pipelines de matching y carga completa de clientes.",None,"high"),
    ("2026-04-16","pisa","La Fase 3 Run de Atlas incluye la migración de clientes desde PISA hacia los sistemas destino (+25 millones de clientes) con integración con Grupo Coppel, Forex, Adobe CDP y Salesforce.",None,"medium"),
    # ── 23 Abril · Apolo + Legacy + SmartVista ───────────────────────────────
    ("2026-04-23","gobierno","Se acordó realizar actualizaciones semanales del roadmap integral (45 min, miércoles o jueves) durante las próximas 2 semanas; el roadmap aún está en iteración activa en la semana 4 del programa de aceleración.","pablo-lorenzo","high"),
    ("2026-04-23","apolo","El inventario de APIs de Apolo (~600 APIs totales) no está consolidado; cada building block mantiene su propia documentación y no existe vista unificada de interfaces; esto se establece como brecha crítica para el roadmap.",None,"high"),
    ("2026-04-23","apolo","La latencia de 5 segundos promedio en la capa proxy de Apolo en producción es un problema crítico identificado; se anticipa que empeorará con la implementación de Web Methods y el cifrado de datos sensibles.",None,"high"),
    ("2026-04-23","seguridad","Se confirma que los datos personales en Apolo (nombre, CURP, RFC, teléfono, email) no están cifrados en reposo y la base de datos en AWS reside fuera del territorio mexicano; hallazgo de incumplimiento regulatorio.",None,"high"),
    ("2026-04-23","apolo","El ciclo de vida completo de una API de Apolo desde diseño hasta producción toma aproximadamente 4 meses; la actualización de diagramas de arquitectura depende de insumos de Play Digital.",None,"medium"),
    ("2026-04-23","pisa","Se confirma que no existe un punto de contacto centralizado con control global del sistema Legacy PISA; el conocimiento está fragmentado entre múltiples personas y equipos, sin ownership unificado.",None,"high"),
    ("2026-04-23","pisa","SmartVista, BPC e Interact están planificados para decommission gradual; Informix es el componente más complejo y requiere un barrido específico para habilitar nuevas funcionalidades.",None,"high"),
    ("2026-04-23","regulatorio","Los expedientes entregados a la CNBV para Transact, SmartVista y Apolo son la fuente más eficiente de arquitecturas de referencia para el mapeo de interfaces del Legacy.",None,"medium"),
    ("2026-04-23","smartvista","El roadmap actual de SmartVista cubre únicamente Tarjeta de Crédito (TDC); la Tarjeta de Débito (TDD) no está en el backlog, carece de estimaciones, riesgos y dependencias documentadas, aunque el negocio la espera para Q1 2027.",None,"high"),
    ("2026-04-23","smartvista","No existe inventario consolidado de interfaces de SmartVista; solo existen inventarios para R2 y R3; R4 está completamente sin documentar; el mapeo de capacidades empresariales tampoco ha comenzado formalmente.",None,"high"),
    ("2026-04-23","smartvista","El equipo de SmartVista conoce el modelo de capacidades funcionales a nivel presentación pero declara que la implementación real es otra conversación; señal de brecha significativa entre diseño teórico y estado real.",None,"high"),
    ("2026-04-23","pisa","Juan Manuel dejó claro que la contabilidad permanece en el sistema legado (PISA/IPISA) y no será migrada a los sistemas destino en el alcance actual de Unity.","juan-manuel","high"),
    ("2026-04-23","transact","El mapeo de capacidades por release (evolución cronológica) es una necesidad crítica para Transact: sin esa vista no se pueden detectar capacidades huérfanas ni conflictos de duplicación entre sistemas.","lukasz-pietrzyk","high"),
    ("2026-04-23","integracion","La definición del inventario de interfaces y su progresión por release es responsabilidad exclusiva del banco (Sandra y Araceli), no del equipo de apoyo ACN.",None,"high"),
    ("2026-04-23","transact","El roadmap de capacidades está construido solo en target state (estado final) y carece de una vista cronológica por release — brecha reconocida colectivamente que debe subsanarse antes de consolidar el plan director.","lukasz-pietrzyk","medium"),
    # ── 24 Abril · SmartVista Roadmap + Transact Roadmap ────────────────────
    ("2026-04-24","smartvista","R3 se liberará de forma separada e independiente para cumplir compromisos existentes con el negocio. La propuesta de agrupar R3 y R4 fue descartada porque el negocio (Sergio del Valle) la rechazaría dado los retrasos acumulados.","pablo-lorenzo","high"),
    ("2026-04-24","smartvista","R4 adoptará una nueva estrategia de testing integral exhaustivo (SIT/UAT transversales de 3-4 meses + NFT/performance + simulacros de producción), lo que empujará su fecha de liberación a principios de febrero.","pablo-lorenzo","high"),
    ("2026-04-24","gobierno","Sergio del Valle fue confirmado como sponsor ejecutivo clave de las decisiones de roadmap y producto de SmartVista. El plan debe validarse con él antes de cualquier presentación a Juan Manuel.",None,"high"),
    ("2026-04-24","smartvista","Copel Pay irá a SmartVista. Representa una extensión del crédito Coppel existente en una tarjeta Mastercard para uso en cualquier establecimiento. Fechas de onboarding pendientes de confirmar con David Estrada.",None,"medium"),
    ("2026-04-24","smartvista","Solo la Tarjeta de Crédito Clásica está en el alcance comprometido hasta 2028. Productos como Platino y otros tipos de TDC quedan fuera del roadmap planificado.",None,"high"),
    ("2026-04-24","integracion","El onboarding N4 (Cuenta Efectiva Digital) va con Transact; el R3 (Apolo en BanCoppel) está asociado a la Tarjeta Digital en SmartVista. El onboarding Offi y Apolo están ligados a la Tarjeta de Crédito Clásica en SmartVista.",None,"high"),
    ("2026-04-24","apolo","En el cronograma actual la versión N4 de Cuenta Digital que se libera es legacy; sin embargo, en el punto de lanzamiento definitivo la creación de cuentas N4 se realizará en Apolo.",None,"medium"),
    ("2026-04-24","cronograma","El roadmap se extiende hasta 2028. Existe un bloqueador mayor por la fragmentación absoluta del sistema legado: no hay una persona con el conocimiento completo de fechas, desarrollos y dependencias.","lukasz-pietrzyk","high"),
    ("2026-04-24","transact","Cuentas Efectivas Digitales N2 y N4, y Cuenta Nómina N4 operarán en Transact. El onboarding de las tres se realizará a través de promotoria (Apolo). Solo Inversiones y Pagarés están en el alcance comprometido hasta 2028.",None,"high"),
    ("2026-04-24","transact","Préstamo Simple es el único producto de préstamos incluido en la planificación hasta 2028. Préstamo Revolvente, Nómina y Anticipo Nómina están fuera del alcance.",None,"high"),
    ("2026-04-24","cronograma","La decisión sobre la fecha de inicio del Préstamo Simple (Q4 2026 solicitado vs Q2 2027) será tomada a nivel ejecutivo por Juan Manuel y Sergio del Valle. El SIT/UAT se propone en 3 meses cada uno.","juan-manuel","high"),
    ("2026-04-24","integracion","Western Union que actualmente usa el core legado debe activar una nueva integración con Transact. Esta es una dependencia crítica que afecta el timing de la Cuenta Efectiva Digital N4.",None,"high"),
    ("2026-04-24","testing","Se propuso estandarizar y agrupar las fases SIT y UAT en ciclos transversales de 3 meses cada uno (con ciclos internos de 1 mes), más dress rehearsals de simulacro de producción.","pablo-lorenzo","high"),
    ("2026-04-24","gobierno","Debe solicitarse sesión ejecutiva con Sergio del Valle para presentar y obtener feedback sobre la evolución del mapa integral antes de escalarlo a Juan Manuel.","pablo-lorenzo","medium"),
    # ── 28 Abril · Testing + Arquitectura + Atlas + SmartVista Interfaces ────
    ("2026-04-28","testing","Se decidió migrar la gestión de pruebas hacia X-ray (integrado en Jira), eliminando los dashboards externos actuales (Value Edge). Esta transición busca centralizar la visibilidad de test management.",None,"high"),
    ("2026-04-28","testing","Se estableció la visión de habilitar ambientes de QA separados por producto (BPC, Launch, OPI, SEW, Apollo) antes de llegar al ambiente EIT (homologado integrado).",None,"high"),
    ("2026-04-28","testing","Las desviaciones en la planificación de pruebas alcanzan hasta el 200% respecto al objetivo (máximo 10%), porque los retrasos de desarrollo se comen el tiempo de QA sin mover la fecha límite final.",None,"high"),
    ("2026-04-28","testing","Los SLAs de resolución de defectos (ej. 4 horas para críticos) son reconocidos como demasiado agresivos y rara vez se cumplen; nadie ha propuesto SLAs más realistas, lo que perpetúa el incumplimiento formal.",None,"medium"),
    ("2026-04-28","testing","El ciclo completo de QA fue reiniciado en un proyecto previo porque la definición inicial fue incorrecta: HUs mal definidas, alcance en evolución y compromisos informales sin control. Lección aprendida que debe incorporarse al DoR.",None,"medium"),
    ("2026-04-28","testing","El ambiente pre-producción solo soporta hasta 50 transacciones por minuto, cuando la aplicación real tiene ~18,000 usuarios. El ambiente es inadecuado para pruebas de performance representativas.",None,"high"),
    ("2026-04-28","testing","La estrategia de pruebas actual del banco tiene 4 años de antigüedad y está desactualizada. Requiere revisión integral para reflejar el estado actual de gestión, herramientas y automatización en el contexto Unity.",None,"medium"),
    ("2026-04-28","testing","El UAT se ejecuta con apoyo del equipo de QA porque el área de negocio no tiene capacidad de tiempo suficiente; esto prolonga las pruebas de 4 semanas planificadas a 4 meses reales.",None,"high"),
    ("2026-04-28","arquitectura","Se confirmó la necesidad de incorporar proactivamente Arquitectos de Solución en las células de desarrollo desde la fase de diseño para garantizar cumplimiento de estándares.",None,"high"),
    ("2026-04-28","apolo","Lenin, arquitecto de solución clave en Apolo, sale el 31 de mayo sin haber identificado formalmente a su reemplazo ni transferido conocimiento al banco. Solo pasó contexto a Joaquín Pichardo de ACN — riesgo crítico de continuidad.","lukasz-pietrzyk","high"),
    ("2026-04-28","arquitectura","La resolución de hallazgos de deuda técnica está bloqueada por la prioridad de releases: solo 9 de los hallazgos abiertos han sido resueltos.",None,"high"),
    ("2026-04-28","apolo","Se detectaron latencias de 5 segundos en la ejecución de cualquier API de Apolo. El equipo de Arquitectura aclaró que esto es un problema de solution architecture, no de pruebas no funcionales.","lukasz-pietrzyk","high"),
    ("2026-04-28","smartvista","Existe una brecha de documentación crítica: no se tiene certeza de si todos los módulos de SmartVista han sido contratados. El equipo de Arquitectura estima tener primeras versiones del análisis a mediados de mayo.",None,"high"),
    ("2026-04-28","arquitectura","Se acordó desarrollar directrices y recomendaciones formales sobre cuándo utilizar caché para APIs, fundamental para optimizar tiempos en el escenario multi-cloud con sistemas legados.",None,"medium"),
    ("2026-04-28","smartvista","La solución del autorizador de pagos en SmartVista se trabaja en dos vías paralelas: mejoras a la arquitectura actual del autorizador y habilitación del autorizador en SmartVista.",None,"medium"),
    ("2026-04-28","atlas","Atlas Fase 2 (MDM con Golden Record) debe estar en producción antes de finales de septiembre 2026 — dependencia crítica antes de la migración de TDC clásica en SmartVista proyectada para diciembre 2026.","lukasz-pietrzyk","high"),
    ("2026-04-28","regulatorio","Se identificó riesgo normativo: ID de producto de TDC clásica difiere entre legado (6001) y SmartVista (4900). El ID 4900 no está declarado ante Banco de México. Se acordó proceder con ID 4900 asumiendo esfuerzo adicional en reportes regulatorios.",None,"high"),
    ("2026-04-28","atlas","La puesta en producción del Golden Record a finales de septiembre 2026 solo contempla la carga de datos en el MDM. Aún falta definir la integración detallada del MDM con plataformas y canales.","lukasz-pietrzyk","high"),
    ("2026-04-28","datos","El área de Negocio está evadiendo su responsabilidad en el proyecto Atlas: debe ser parte del comité y proveer las definiciones para el Golden Record, pero percibe que no le corresponde participar.",None,"high"),
    ("2026-04-28","atlas","Las metodologías de migración de SmartVista y Transact están completamente aisladas. Se decidió usar la metodología de SmartVista (trabajada con IWI para TDC) como habilitador para la migración de Transact.",None,"high"),
    ("2026-04-28","pisa","No existe un punto de contacto único para el sistema legado completo — está muy disperso entre muchas personas. La única persona del legacy que se ha acercado proactivamente para tratar coexistencia con la migración es Martín Alejandro López.",None,"high"),
    ("2026-04-28","testing","Se propuso metodología de testing transversal con SIT y UAT de 3 meses cada uno (ciclos internos de 1 mes), pruebas no funcionales en paralelo, y dress rehearsals (3 simulacros de 1 mes) con participación de Negocio, Operaciones, TI y QA.","pablo-lorenzo","high"),
    ("2026-04-28","smartvista","Se identificaron 8 interfaces batch de SmartVista: 3 ya en producción, 5 en desarrollo pendientes de liberación. No existe un Excel consolidado del inventario.",None,"high"),
    ("2026-04-28","integracion","Existen interfaces inversas de conciliación SmartVista → legacy que aún no están en producción y son necesarias para proveer archivos de conciliación generados en la operación actual.",None,"high"),
    ("2026-04-28","integracion","El proceso de gestión de cambios en interfaces SmartVista se hace vía email de José Jaimes → Jira → dev → ciclos de prueba. No hay un proceso estandarizado formal.",None,"medium"),
    ("2026-04-28","arquitectura","El equipo de Unity gestiona además APIs no estándar para necesidades particulares del Core Banking System (disposiciones, pagos, notificaciones de cobranza), arquitectura ad-hoc fuera del estándar corporativo.",None,"medium"),
    ("2026-04-28","integracion","El alcance del diligence se extendió de identificación de brechas a elaboración de roadmap integral hasta 2028, por solicitud explícita de Juan Manuel.","pablo-lorenzo","high"),
    ("2026-04-28","smartvista","Se clarificó la taxonomía de integraciones SmartVista en dos categorías: APIs para interacciones en línea con canales e interfaces batch offline que complementan la operación.","lukasz-pietrzyk","high"),
    ("2026-04-28","gobierno","No existe un inventario consolidado de las 8 integraciones SmartVista en un solo documento formal; cada track administra sus integraciones de forma distinta — brecha de gobernanza reconocida colectivamente.","pablo-lorenzo","high"),
    ("2026-04-28","gobierno","El flujo de cambios a interfaces se gestiona informalmente vía correo electrónico antes de crear tarjetas en Jira; no existe un proceso formal de change management con gate de revisión arquitectónica.",None,"medium"),
    ("2026-04-28","smartvista","Existe confusión documentada sobre si el autorizador de SmartVista fue comprado; la habilitación del autorizador está en fases muy tempranas — apenas siendo convocada Arquitectura Empresarial.",None,"high"),
    ("2026-04-28","arquitectura","El proyecto Atlas está liderado por arquitectura de grupo (datos), pero aún no se ha definido qué arquitectos con conocimiento de banca se asignarán — crítico para la definición del Golden Source del cliente.","lukasz-pietrzyk","medium"),
    ("2026-04-28","integracion","Tensión multi-cloud identificada: plataforma de datos en GCP, mayoría de procesadores bancarios en AWS o on-prem; requerimientos de latencia y revisiones preventivas no han sido formalmente evaluados.","lukasz-pietrzyk","medium"),
    # ── 29 Abril · Transact + Apolo + Unity-Legado ───────────────────────────
    ("2026-04-29","transact","La arquitectura empresarial de referencia de Unity fue ajustada para incluir préstamos y captación; originalmente estaba enfocada casi al 100% en cuentas. El ajuste fue realizado por EY (Angélica Tolosa).",None,"high"),
    ("2026-04-29","transact","Se acordó documentar estados intermedios de la arquitectura por release (no solo el End State), para poder medir progreso real y comunicarlo a Juan Manuel; entrega comprometida para el jueves.","pablo-lorenzo","high"),
    ("2026-04-29","cronograma","Se propuso un modelo de 3 meses para SIT y 3 meses para UAT organizados en 3 ciclos, con testing no funcional (seguridad y rendimiento) corriendo en paralelo — modelo más conservador y realista que el actual.","pablo-lorenzo","high"),
    ("2026-04-29","cronograma","Se incorporaron simulacros de producción (3D reversals) al roadmap propuesto porque actualmente no existe un equipo de deployment con visión integral del Go-Live.","pablo-lorenzo","medium"),
    ("2026-04-29","pisa","El legado fue caracterizado colectivamente como caja gris: no hay visibilidad suficiente de dependencias con Transact (ej. Western Union, recargas) para construir el roadmap — urgencia de documentación explicitada.","pablo-lorenzo","high"),
    ("2026-04-29","cronograma","El análisis y diseño del préstamo simple en Transact se movió un cuarto y medio a la derecha en el roadmap para garantizar los nuevos ciclos SIT/UAT de 3 meses sin sobreposición.",None,"medium"),
    ("2026-04-29","transact","La estrategia de lanzamiento del préstamo simple (friends and family vs. apertura amplia) no está definida aún; se revisará en mayo — decisión implícita de posponer ese alcance.",None,"medium"),
    ("2026-04-29","cronograma","El roadmap integrado solo reflejará trabajo con plan formal definido; cualquier iniciativa futura sin planificación se documentará explícitamente como supuesto (assumption) para delimitar el alcance.","pablo-lorenzo","high"),
    ("2026-04-29","apolo","Apolo R4 incluye 11 historias de usuario incrementales ya planificadas y estimadas; fecha objetivo: lanzamiento a mercado abierto diciembre 2026 — esta es la fecha límite de negocio.",None,"high"),
    ("2026-04-29","apolo","La Cuenta Efectiva Digital N4 operará en dos fases: conecta inicialmente a Legacy; una vez que Transact finalice el desarrollo de cuentas, Apolo reapuntará a Transact. Decisión de arquitectura en dos etapas confirmada.",None,"high"),
    ("2026-04-29","apolo","Los desarrollos de Apollo App deben estar listos a más tardar en R4; es la fecha límite establecida por negocio para incluir experiencia en app en el lanzamiento al mercado abierto.",None,"high"),
    ("2026-04-29","smartvista","El equipo que desarrolla SmartVista R4 (TDC) es el mismo que debe atender el impacto de ORE — riesgo de capacidad identificado y documentado como dependencia crítica.",None,"medium"),
    ("2026-04-29","regulatorio","La carpeta normativa CNBV solo tiene información hasta R3 y necesita actualizaciones con los desarrollos de R4 para la salida a mercado abierto en diciembre 2026 — riesgo regulatorio activo.","pablo-lorenzo","high"),
    ("2026-04-29","pisa","No existe un punto de contacto único para todo el legado de PISA/canales/reportes; el intento inicial con Octavio fracasó. La coordinación de legado es fragmentada por aplicativo — brecha de gobernanza estructural.","pablo-lorenzo","high"),
    ("2026-04-29","pisa","La conexión del switch de transacciones de cajeros y POS con el nuevo stack (Iglobe) está proyectada para Q1/Q2 2027; Unity planea contactar al equipo de José Alberto a principios de 2027 para iniciar diseño.",None,"medium"),
    ("2026-04-29","pisa","Ares (banca empresarial) opera sobre PISA y se integrará a Transact en una segunda fase; Credit Risk es un componente satélite sin plan de integración directo a Unity.",None,"medium"),
    ("2026-04-29","datos","La reportería de SmartVista se gestionará de forma separada del legado porque SmartVista tendrá su propia base de datos independiente.",None,"medium"),
    ("2026-04-29","pisa","Muchos ítems del listado de aplicativos legados son agrupaciones de stored procedures que consumen múltiples canales, no aplicativos reales; el inventario necesita revalidación.",None,"medium"),
    ("2026-04-29","gobierno","Se acordó planificar workshops detalladas de legado que incluyan personal crítico del programa Unity para que el ejercicio sea recíproco y no solo unilateral del lado legacy.","pablo-lorenzo","high"),
    # ── 30 Abril · Apolo Roadmap + SmartVista Semanal ────────────────────────
    ("2026-04-30","cronograma","R4 confirmado en el plan: Arturo Valdivieso confirmó que R4 debe incluirse porque ya está dimensionado y en construcción; no es opcional.",None,"high"),
    ("2026-04-30","cronograma","Fecha de R3 corregida: no será en abril sino en julio (Q3) para Apolo y SmartVista. La corrección se hizo explícitamente durante la sesión.","pablo-lorenzo","high"),
    ("2026-04-30","apolo","La sección Apolo en el roadmap se renombra a Canales para evitar confusión y reflejar correctamente que Apolo es un canal de captura, no un sistema core.",None,"high"),
    ("2026-04-30","apolo","Apolo no genera productos bancarios: captura información y la inyecta al legado para su creación. La transmisión hacia legado se considera Go Live porque requiere capas intermedias.",None,"high"),
    ("2026-04-30","apolo","El onboarding digital de cuentas Nivel 4 (E4) se estructura en dos fases: Fase 1 acerca al MVP; Fase 2 crea el producto, estimada entre Q4 2026 y Q1 2027.",None,"high"),
    ("2026-04-30","cronograma","R4 abierto a mercado: meta diciembre 2026, incluye trabajo de Apolo en la aplicación y 11 historias de usuario esenciales.",None,"high"),
    ("2026-04-30","cronograma","R4.5 sin definición cerrada: su alcance depende de funcionalidades de medios de pago (Spay, tarjeta de débito) que aún están en definición y dimensionamiento.",None,"medium"),
    ("2026-04-30","cronograma","Se estableció reunión semanal cada martes para revisar cambios en roadmap junto a assumptions y riesgos, como mecanismo de gobierno recurrente del track.",None,"high"),
    ("2026-04-30","smartvista","R4 se divide en tres liberaciones independientes a producción para cumplir objetivos comerciales y permitir liberar canales individualmente; la última entrega (R4.5) extiende hasta la tercera semana de enero 2027.","pablo-lorenzo","high"),
    ("2026-04-30","testing","Se implementarán ciclos separados de SIT y UAT de mínimo un mes cada uno; actualmente se ejecuta un ciclo único donde distintas personas prueban los mismos casos — práctica que se elimina.","pablo-lorenzo","high"),
    ("2026-04-30","cronograma","Se implementarán ejercicios de simulacro a producción (rehearsal) para mejorar el runbook de deployment y asegurar la integración de negocio, operaciones y TI antes de cada release.","pablo-lorenzo","high"),
    ("2026-04-30","integracion","Se acordó realizar workshops enfocados y planificados con el equipo de Legado — uno por track (Transact y SmartVista por separado) — para identificar insumos y prioridades.","pablo-lorenzo","high"),
    ("2026-04-30","apolo","La cuenta efectiva digital de Apolo se conectará primero a Legado y posteriormente a Transact; la secuencia de integración quedó establecida explícitamente.",None,"high"),
    ("2026-04-30","gobierno","El roadmap debe ser integral e incluir hipótesis (assumptions), riesgos y los impactos de Atlas y Legado, además de los planes de todos los streams; el formato actual es insuficiente.","pablo-lorenzo","high"),
    ("2026-04-30","gobierno","Diagnóstico acordado: los problemas del programa son de metodología y coordinación, no de talento. Esta distinción es relevante para el tipo de intervención a proponer.","pablo-lorenzo","high"),
    # ── 7 Abril · Apolo + SmartVista + Transact Arquitectura ─────────────────
    ("2026-04-07","arquitectura","Los arquitectos deben tener mayor implicación en los grupos de trabajo desde el inicio del desarrollo para asegurar alineación de Apolo con principios de arquitectura; se eliminarán validaciones a posteriori.","arcadio","high"),
    ("2026-04-07","arquitectura","Todos los planes de trabajo de hallazgos de remediación deben pasar por supervisión y visto bueno del equipo de arquitectura; hallazgos que extienden más allá de R3 tienen plan formal con fechas agosto-septiembre.","arcadio","high"),
    ("2026-04-07","apolo","La funcionalidad de clientes existentes debe priorizarse antes de salida a mercado abierto: el hit rate en Friends and Family fue menor al 10% porque la mayoría ya son clientes existentes.",None,"high"),
    ("2026-04-07","apolo","Causa raíz identificada: Apolo fue concebido como proyecto de TI sin participación de negocio, lo que generó fallas de implementación (reglas y motores) que se convirtieron en remediaciones del R2.","pablo-lorenzo","high"),
    ("2026-04-07","apolo","Desacoplamiento SP a APIs: aproximadamente 60% de los servicios ya son microservicios; 40% todavía usa llamadas directas a stored procedures. El plan incluye completar el desacoplamiento.",None,"medium"),
    ("2026-04-07","integracion","Existe un proyecto futuro para reemplazar APG por MuleSoft. El contrato con APG finaliza en 2027 y la implementación de Octa para el proyecto Aries ya retrasó el programa seis meses.",None,"high"),
    ("2026-04-07","arquitectura","El DRP debe ligarse para incluir Apolo y SmartVista en conjunto; Apolo no funciona de manera aislada y actualmente no existe gobierno transversal para planificar el aumento de transaccionalidad.",None,"high"),
    ("2026-04-07","apolo","El 97% del tráfico de onboarding proviene de campañas de tráfico pagado; implementar monitoreo para detectar fallas y detener campañas rápidamente es crítico para evitar pérdidas.",None,"high"),
    ("2026-04-07","smartvista","El alcance de SmartVista se redujo de 50 funcionalidades solicitadas a 19 esenciales para el lanzamiento al mercado abierto (R4); las restantes quedaron en backlog.",None,"high"),
    ("2026-04-07","smartvista","A diferencia de otros tracks, todos los hallazgos de SmartVista deben resolverse sin excepción por dependencia con el legado; los tickets ya están elevados con BPC para resolución.",None,"high"),
    ("2026-04-07","smartvista","La migración del portafolio TDC se planea en 4 olas post-R4, usando criterio de ID de producto + ID de cliente (no BIN) para evitar dividir la información del cliente entre legado y SmartVista.",None,"high"),
    ("2026-04-07","smartvista","Dos precondiciones obligatorias para iniciar la migración TDC: 1) implementación del preautorizador y 2) detención de la originación de tarjetas en PISA.",None,"high"),
    ("2026-04-07","smartvista","Migración completa del portafolio TDC (99% producto clásico) podría finalizar en 2027; el roadmap confirmado llega solo hasta fin de 2026.",None,"high"),
    ("2026-04-07","seguridad","Se agregó personalización de autenticación por JWT a SmartVista por revisiones de seguridad. Existe preocupación de que interfaces temporales pasen datos sensibles a un legado no completamente certificado en PCI.",None,"high"),
    ("2026-04-07","smartvista","Los componentes de SmartVista exponen datos al legado mediante S3 (AWS Transfer Family) para contabilidad, maquila, prevención de fraudes, conciliaciones y estados de cuenta; estas interfaces son temporales.",None,"medium"),
    ("2026-04-07","cronograma","Para R3, la deuda técnica, la transición y la remediación se integran en un único plan de gestión del track; diferente al R2 donde se gestionaron de forma aislada. Lección aprendida aplicada.","pablo-lorenzo","high"),
    ("2026-04-07","smartvista","El presupuesto base de SmartVista debe ajustarse y el business case debe alinearse a las metas de 2030 — la alineación actual no refleja la realidad del alcance.",None,"high"),
    ("2026-04-07","transact","Transact opera con arquitectura transitoria en producción y carece de Arquitectura Objetivo (To-Be) definida; incluso la arquitectura transitoria actual no está 100% cerrada.",None,"high"),
    ("2026-04-07","transact","Solo las brechas de ambientes y la capa de seguridad tienen plan de remediación con responsable y fecha comprometida; todas las demás brechas críticas de alto impacto están sin plan.","pablo-lorenzo","high"),
    ("2026-04-07","transact","El principal cuello de botella de Transact son los equipos externos (Apolo, SmartVista) que no pueden asignar personal por otros compromisos; podría retrasar la finalización significativamente después de 2030.",None,"high"),
    ("2026-04-07","transact","La plataforma de Transact está críticamente desactualizada sin haber recibido actualizaciones desde octubre de 2015 — más de 10 años sin versión nueva.",None,"high"),
    ("2026-04-07","transact","Transact presenta desincronizaciones constantes en producción entre sus herramientas internas (TDH) y fallos en interfaces contables; la solución en producción no es estable.",None,"high"),
    ("2026-04-07","transact","Más de 15,000 stored procedures en el core legado soportan SPEI y autorizaciones de tarjetas; las áreas de pagos tienen dependencia crítica de esta lógica.",None,"high"),
    ("2026-04-07","transact","El despliegue del aplicativo Transact se realiza de forma manual; no hay automatización de deployment. Los procesos burocráticos de tickets toman aproximadamente 30 días para habilitar prerrequisitos de instalación.",None,"high"),
    ("2026-04-07","transact","El benchmark actual de Transact en producción solo soporta 50 transacciones por minuto — RNF de rendimiento insuficiente para una operación bancaria a escala.",None,"high"),
    # ── 8 Abril · Datos, Integración, Legacy, Estrategia ─────────────────────
    ("2026-04-08","datos","Se está definiendo un plan de migración unificado para TDC (PISA → SmartVista) y Banca Minorista (captación y préstamo personal); debe estar listo antes del viernes.",None,"high"),
    ("2026-04-08","datos","La migración será 100% automática mediante ETL con AWS Glue; la data de PISA se deposita en un bucket S3 de AWS para que el proveedor de carga la tome y la cargue en SmartVista.",None,"high"),
    ("2026-04-08","datos","Se decidió contar con ambientes exclusivos (desarrollo, pruebas, UAT) para tareas de migración; los ambientes preproductivos y productivos serán compartidos.",None,"medium"),
    ("2026-04-08","atlas","Toda la plataforma de datos Arquitectura 2.0 (incluyendo Atlas/MDM) estará en GCP para unificar la capa de datos, a pesar de que el banco opera principalmente en AWS.",None,"high"),
    ("2026-04-08","atlas","El Maestro de Clientes (MDM en Atlas) debe convertirse en la fuente autoritativa de datos de clientes, quitando esta función a los sistemas core. Transact actualmente obtiene datos de cliente directamente de PISA — esta dependencia debe eliminarse.",None,"high"),
    ("2026-04-08","atlas","El piloto de la Customer Data Platform (CDP) de Atlas iniciará en el banco, no en Afore ni Crédito Coppel. La capa inicial de sincronización de clientes y CDP debe estar operativa para mediados de 2026.",None,"high"),
    ("2026-04-08","datos","El equipo no tiene experiencia previa con AWS Glue; se priorizará la transferencia de conocimiento con el proveedor antes de iniciar la ejecución de la migración.",None,"high"),
    ("2026-04-08","datos","El dominio de clientes ya está gobernado al 99.5%; la Fase 2 de gobierno de datos iniciará para incluir el dominio de productos. La calidad de datos requerirá análisis profundo en la migración.",None,"medium"),
    ("2026-04-08","integracion","El estándar contract first está confirmado como práctica de diseño de APIs; la especificación (RAML o Swagger), el contrato y la matriz de transformación son obligatorios antes de desarrollo.",None,"high"),
    ("2026-04-08","integracion","Se propone el Strangler Pattern para casos específicos como SPEI, para gestionar entradas y salidas en sistemas legados durante la transición.",None,"medium"),
    ("2026-04-08","integracion","La integración a nivel de datos (ETLs y data hub) está separada de la arquitectura de APIs; ambas capas deben mantenerse conceptualmente distintas.",None,"medium"),
    ("2026-04-08","integracion","El promedio de tres redespliegues por cada despliegue original es un pain point identificado, causado principalmente por incorrecta configuración de rangos de IP entre MuleSoft y APG.",None,"medium"),
    ("2026-04-08","integracion","El API marketplace es actualmente solo interno; no existe acceso externo, incluyendo para Coppel (la empresa hermana). Este es un gap a revisar.",None,"medium"),
    ("2026-04-08","integracion","No existe proceso formal de onboarding para equipos que inician desarrollo de APIs; los accesos a herramientas se proporcionan de forma incremental.",None,"medium"),
    ("2026-04-08","pisa","El objetivo fundamental de Unity es poder decomisionar PISA, pero no existe un mapa funcional de PISA a nivel de arquitectura empresarial, lo que impide cerrar el gap entre sistema legado y priorización de funcionalidades.","pablo-lorenzo","high"),
    ("2026-04-08","pisa","Actualización de business case acordada: el time to market y la habilitación de nuevas funcionalidades son más beneficiosos financieramente que el desmantelamiento inmediato de la infraestructura.","pablo-lorenzo","high"),
    ("2026-04-08","pisa","Se adoptó Seriam como BRM para migrar los 13,000-14,000 stored procedures de PISA; el principio de arquitectura es complementar el core sin modificar la caja para evitar problemas en futuras actualizaciones.",None,"high"),
    ("2026-04-08","pisa","Offi y C Web: la iniciativa más reciente es migrarlos a la nube desde cero en tecnologías modernas, priorizando por criticidad lo que Apolo no cubrirá.",None,"medium"),
    ("2026-04-08","datos","Se está considerando implementar Change Data Capture (CDC) para extraer datos (saldos, cuentas, clientes) de la base central Informix — estrategia de desacoplamiento no destructiva.",None,"medium"),
    ("2026-04-08","pisa","Caso probado de desacoplamiento SPEI: mover la firma de transacciones al bus aumentó la capacidad de procesamiento de 450 a 1,600 SPEI por segundo y redujo la carga en la base central.",None,"high"),
    ("2026-04-08","gobierno","Unity busca habilitar el 60% de la estrategia del Plan 2030; sin embargo, la planeación actual excluye áreas críticas habilitadoras: Operaciones, Normatividad, Contabilidad y Reportería a la autoridad.","pablo-lorenzo","high"),
    ("2026-04-08","gobierno","No existe un plan de gobierno integral end-to-end ni un roadmap maestro transversal; los mapas existentes son colecciones de roadmaps individuales por dominio, sin coordinación de value streams ni responsable único.","pablo-lorenzo","high"),
    ("2026-04-08","cronograma","El roadmap es considerado realista solo a corto plazo (hasta 2027) para onboarding y originación; más allá, la capacidad instalada y la complejidad de paralelismos hacen inviable la planeación actual.","pablo-lorenzo","high"),
    ("2026-04-08","gobierno","Se cuestionó la metodología ágil para este proyecto, sugiriendo que no es un entorno VUCA y que el agile actual impide establecer compromisos de tiempo y fecha precisos.","pablo-lorenzo","medium"),
    ("2026-04-08","gobierno","Se identificaron cinco estrategias de proyecto faltantes o inmaduras: monitoreo y soporte, deployment, migración, testing y rollout. El enfoque se ha centrado demasiado en la funcionalidad del producto.","pablo-lorenzo","high"),
    ("2026-04-08","cronograma","El crecimiento proyectado relacionado con Unity en nómina es del 5%, impulsado por las funcionalidades habilitadas y no por el core en sí mismo — corrección importante de expectativas de negocio.",None,"medium"),
    ("2026-04-08","gobierno","Los proveedores de software (ej. SmartVista) solo pueden ofrecer visión dentro de los límites de su propio producto; el banco debe establecer una visión integral por encima de los distintos vendors.","pablo-lorenzo","high"),
]

# ─────────────────────────────────────────────────────────────────────────────
# POSITIONS — (stakeholder_id, topic, stance, sentiment, date)
# sentiment ∈ {supportive, concerned, blocking, neutral}
# ─────────────────────────────────────────────────────────────────────────────
POSITIONS = [
    ("pablo-lorenzo","cronograma","Pablo Lorenzo asume la responsabilidad de construir el plan integrado E2E que el programa no tiene; considera los planes existentes fragmentados e insuficientes para sostener compromisos ante la junta directiva.","concerned","2026-04-16"),
    ("pablo-lorenzo","testing","Pablo Lorenzo identifica los pain points de testing (SIT hasta 5 meses, UAT hasta 2 meses, ambiente único compartido) como riesgos sistémicos del programa, no como anomalías puntuales.","concerned","2026-04-15"),
    ("pablo-lorenzo","atlas","Pablo Lorenzo propone activamente mejoras al plan de migración (dry runs y dress rehearsals) que no existían en el plan original; considera el plan de migración actual incompleto y riesgoso.","concerned","2026-04-16"),
    ("pablo-lorenzo","integracion","Pablo Lorenzo reconoce que la integración de Transact con canales es una dependencia bloqueante no resuelta en el plan actual y toma la responsabilidad de crear el plan unificado.","concerned","2026-04-10"),
    ("lukasz-pietrzyk","smartvista","Lukasz Pietrzyk presiona sistemáticamente por obtener visión integral de SmartVista incluyendo TDD, aunque el equipo informa que no está en el backlog. Ve brechas de alcance que podrían afectar el roadmap Unity completo.","concerned","2026-04-23"),
    ("lukasz-pietrzyk","arquitectura","Lukasz Pietrzyk impulsa activamente el inicio del mapeo formal de capacidades empresariales para SmartVista, reconociendo que no ha comenzado. Identifica esto como un riesgo fundacional.","concerned","2026-04-23"),
    ("lukasz-pietrzyk","integracion","Lukasz Pietrzyk identifica la falta de un inventario consolidado de interfaces en todos los streams (Apolo, SmartVista, Legacy) como un gap diagnóstico crítico.","concerned","2026-04-23"),
    ("juan-manuel","cronograma","Juan Manuel solicitó urgentemente el plan E2E para la junta directiva del 24 de abril; su postura señala insatisfacción con los planes fragmentados por stream y presión ejecutiva para obtener compromisos de fechas ante el consejo.","concerned","2026-04-16"),
    ("juan-manuel","gobierno","Juan Manuel es el driver del diligence de 6 semanas sobre gobierno y tecnología; su postura implícita es que el programa Unity no tiene el nivel de madurez de governance esperado para un programa de esta magnitud.","concerned","2026-04-15"),
    ("lukasz-pietrzyk","transact","Lukasz considera la vista de capacidades por release como crítica y no negociable para el plan director Unity: sin ella es imposible garantizar que ninguna capacidad quede huérfana ni detectar conflictos de duplicación.","concerned","2026-04-23"),
    ("lukasz-pietrzyk","atlas","Lukasz está preocupado específicamente por la latencia en la integración del Golden Record con consumidores en AWS dado que el MDM residirá en Google Cloud — riesgo técnico no resuelto que podría comprometer el timeline de diciembre 2026.","concerned","2026-04-28"),
    ("lukasz-pietrzyk","apolo","Lukasz percibe la salida de Lenin como un riesgo crítico de continuidad en Apolo y actuó de inmediato ofreciendo contactar a Miguel Bucio. El banco no tiene plan de sucesión para roles arquitectónicos clave.","concerned","2026-04-28"),
    ("lukasz-pietrzyk","arquitectura","Lukasz señaló que el problema de latencia de 5 segundos en APIs de Apolo es un problema de diseño de solución, no de QA — delimita explícitamente responsabilidades.","neutral","2026-04-28"),
    ("pablo-lorenzo","cronograma","Pablo Lorenzo propuso la estrategia transgresora de agrupar R3 y R4 con testing exhaustivo, pero reconoció que el negocio la rechazaría. Muestra pragmatismo político: prioriza viabilidad organizacional sobre optimización técnica.","neutral","2026-04-24"),
    ("pablo-lorenzo","testing","Pablo Lorenzo es el principal impulsor de la metodología de testing transversal (SIT/UAT de 3 meses + dress rehearsals). Su postura es que la integración debe verse como parte del desarrollo, no como fase separada.","supportive","2026-04-28"),
    ("pablo-lorenzo","atlas","Pablo Lorenzo identifica el riesgo de participación del área de Negocio en Atlas como una de las amenazas de gobernanza más importantes. Sin sponsor de negocio el Golden Record no puede completarse correctamente.","concerned","2026-04-28"),
    ("juan-manuel","pisa","Juan Manuel dejó claro explícitamente que la contabilidad permanece en el sistema legado — postura de autoridad que cierra cualquier discusión sobre migrar la contabilidad en el alcance actual de Unity.","neutral","2026-04-23"),
    ("daniel-angeles","testing","Daniel Ángeles del Mesaní es uno de los interlocutores clave para habilitar nuevos ambientes separados por producto; su participación es requerida para resolver la limitación de ambientes que afecta críticamente el testing.","neutral","2026-04-28"),
    ("pablo-lorenzo","gobierno","Pablo Lorenzo explicitó en múltiples sesiones que el programa Unity opera sin inventarios centralizados de integraciones y sin roadmaps unificados; lo posicionó como la brecha fundacional que impulsa el diligence completo.","concerned","2026-04-28"),
    ("pablo-lorenzo","cronograma","Pablo Lorenzo lideró la propuesta del modelo 3+3 meses de SIT/UAT con testing no funcional en paralelo y simulacros de producción; lo presentó como condición para que el roadmap sea creíble ante Juan Manuel.","supportive","2026-04-29"),
    ("pablo-lorenzo","pisa","Pablo Lorenzo reconoció el legado como caja gris que impide la construcción del roadmap; convocó múltiples stakeholders de legacy para documentar dependencias críticas, señalando que sin eso el roadmap integrado es inestable.","concerned","2026-04-29"),
    ("lukasz-pietrzyk","arquitectura","Lukasz exhibió preocupación explícita ante la partida de Lenin sin sucesor identificado ni knowledge transfer formal; cuestionó directamente la situación y tomó acción para contactar a Miguel Bucio.","concerned","2026-04-28"),
    ("lukasz-pietrzyk","smartvista","Lukasz señaló que la documentación sobre el autorizador de SmartVista era confusa y que posiblemente el módulo no fue adquirido; presionó para obtener claridad sobre qué módulos están contratados.","concerned","2026-04-28"),
    ("lukasz-pietrzyk","arquitectura","Lukasz cuestionó que solo 9 hallazgos de arquitectura hayan sido resueltos y que la mayoría sigan abiertos; expresa implícitamente que la prioridad de releases por sobre deuda técnica es una decisión de riesgo alto.","concerned","2026-04-28"),
    ("lukasz-pietrzyk","integracion","Lukasz identificó tensión multi-cloud no resuelta (GCP para datos, AWS para procesadores bancarios) y preguntó si se habían evaluado los requerimientos de latencia desde perspectiva bancaria — señal de riesgo arquitectónico implícito.","concerned","2026-04-28"),
    ("arturo-perez","pisa","Arturo Pérez solicitó más contexto antes de comprometerse con la sesión; propuso reencuadrar la conversación desde qué necesita Unity del legado en lugar de revisar aplicativos en un listado — postura de resistencia funcional.","concerned","2026-04-29"),
    ("arturo-perez","gobierno","Arturo Pérez propuso un grupo de chat de Google para seguimiento porque las sesiones calendarizadas son insuficientes para el ritmo de cambios; postura pragmática que revela que la coordinación formal no está funcionando.","neutral","2026-04-29"),
    ("juan-manuel","cronograma","Juan Manuel solicitó explícitamente apoyo especial para construir el roadmap integrado unificando los roadmaps individuales por stream; su petición directa a Accenture revela insatisfacción implícita con el estado actual del programa.","concerned","2026-04-28"),
    ("juan-manuel","integracion","Juan Manuel identificó la revisión del inventario de integraciones como necesidad fundacional del diligence; el hecho de que no exista ese inventario centralizado es una brecha que él mismo hizo visible ante el equipo externo.","concerned","2026-04-28"),
    ("rodrigo","apolo","Rodrigo confirmó que el Business Case de Apolo contempla diferentes incrementos hasta 2028; al validar este alcance se posicionó como defensor de la inclusión de todos los tracks de Apolo en el roadmap integrado.","supportive","2026-04-29"),
    ("pablo-lorenzo","gobierno","Pablo Lorenzo diagnosticó que los problemas del programa son de metodología y coordinación, no de talento — postura que protege al equipo pero exige un cambio estructural de proceso que implica una intervención a nivel de gobierno.","supportive","2026-04-30"),
    ("arcadio","arquitectura","Arcadio estableció que todos los planes de remediación deben pasar por supervisión y visto bueno de su equipo de arquitectura, y que los arquitectos deben participar desde el inicio de los grupos de trabajo. Es una postura de control de calidad técnica proactiva.","supportive","2026-04-07"),
    ("pablo-lorenzo","apolo","Pablo Lorenzo identificó que la ausencia de negocio desde el origen de Apolo es la causa raíz de las brechas del R2. Esta lectura retrospectiva implica que el modelo de delivery fue incorrecto desde el diseño, no solo en la ejecución.","concerned","2026-04-07"),
    ("lukasz-pietrzyk","apolo","Lukasz estuvo presente en la sesión de Apolo Arquitectura como arquitecto global, alineado con el diagnóstico de que el proceso concentra riesgo al final del ciclo. Su participación implica respaldo técnico a las conclusiones de remediación planteadas.","supportive","2026-04-07"),
    ("luis-barragan","smartvista","Luis Barragán señaló que el producto SmartVista inicialmente no se concibió en sus tres etapas (originación, operación y postventa) y que las políticas de crédito no se integraron desde el inicio. Identifica el problema como un defecto de scope original.","concerned","2026-04-07"),
    ("pablo-lorenzo","smartvista","Pablo Lorenzo aplicó la lección del R2: para R3, la deuda técnica, la transición y la remediación se integran en un único plan de gestión del track. Su postura es explícitamente correctiva respecto al modelo anterior.","supportive","2026-04-07"),
    ("pablo-lorenzo","transact","Pablo Lorenzo evidencia una preocupación aguda con Transact: la plataforma no tiene actualizaciones desde octubre de 2015 y opera sin arquitectura To-Be definida, mientras el roadmap se extiende a 2029. Considera este estado inconsistente e inviable.","concerned","2026-04-07"),
    ("lukasz-pietrzyk","transact","Lukasz Pietrzyk identificó que el modelo híbrido de integración y la forma ágil en que los canales abordan los cambios impiden establecer compromisos de tiempo y fecha con precisión. Señala un problema estructural del modelo de delivery de Transact.","concerned","2026-04-07"),
    ("luis-barragan","transact","Luis Barragán es consciente de los cuellos de botella por procesos burocráticos (30 días para habilitar un ambiente) y de la dependencia crítica en equipos externos. Su presencia sugiere que está gestionando expectativas hacia arriba en el programa.","concerned","2026-04-07"),
    ("karina-zepeda","transact","Karina Zepeda participó en la revisión de arquitectura de Transact, confirmando que el equipo ACN tiene visibilidad directa de las brechas críticas identificadas — ausencia de To-Be, plataforma obsoleta, despliegue manual.","neutral","2026-04-07"),
    ("lukasz-pietrzyk","datos","Lukasz Pietrzyk participó en la sesión de datos y migración como arquitecto global, alineando el enfoque de migración automática por ETL y la separación de arquitectura de datos en GCP. Su presencia valida técnicamente las decisiones de Atlas.","supportive","2026-04-08"),
    ("pablo-lorenzo","datos","Pablo Lorenzo impulsó la coordinación de los planes de migración TDC y banca minorista como un plan unificado; reconoce que la capacidad del personal es el principal cuello de botella para la ejecución.","concerned","2026-04-08"),
    ("pablo-lorenzo","integracion","Pablo Lorenzo empujó por una visión holística de la arquitectura de interoperabilidad que trascienda la capa de APIs e incluya orquestación de procesos, integración de datos, observabilidad y coexistencia MDM. La visión actual de integración es demasiado estrecha.","concerned","2026-04-08"),
    ("arturo-perez","pisa","Arturo Pérez confirmó que la visión funcional de PISA existe en manuales de usuario y reglas de negocio auditadas, y que el conocimiento reside en el personal. Postura de colaboración activa en la extracción de reglas del sistema legado.","supportive","2026-04-08"),
    ("alejandro-gallegos","pisa","Alejandro Gallegos participó en la sesión de arquitectura legacy como observador del diagnóstico sobre la falta de mapa funcional de PISA y la necesidad de actualizar el business case. Tiene conocimiento directo de estos gaps.","neutral","2026-04-08"),
    ("salomon-monroy","pisa","Salomón Monroy participó en la sesión de arquitectura legacy, alineado con el diagnóstico de estrategia de decomisión de PISA y la adopción de BRM con Seriam. Observador de las decisiones de estrategia de desacoplamiento.","neutral","2026-04-08"),
    ("pablo-lorenzo","gobierno","Pablo Lorenzo identificó el desalineamiento significativo entre expectativas de negocio y capacidad de TI, y la ausencia de gobierno end-to-end como el problema más crítico del programa. Requiere un responsable único accountable y un roadmap maestro transversal.","concerned","2026-04-08"),
    ("luis-barragan","gobierno","Luis Barragán es consciente del problema de capacidad: proyectos transversales como Transact compiten con 18 desarrollos existentes y solo cinco personas soportan la operación de captación completa. Postura implícita de alarma sobre la sostenibilidad del modelo.","concerned","2026-04-08"),
    ("pablo-lorenzo","cronograma","Pablo Lorenzo cuestionó la metodología ágil para este proyecto al señalar que no es un entorno VUCA, y que el modelo impide establecer compromisos precisos. Postura estratégica significativa que podría impactar el modelo de delivery de todo el programa.","concerned","2026-04-08"),
    ("brenda","gobierno","Brenda fue identificada como el canal formal para solicitar los expedientes CNBV; su postura es de colaboración pero implica que la obtención de esos documentos requiere gestión formal a través de su área.","neutral","2026-04-23"),
    ("carlos-bc","gobierno","Carlos lidera el comité de estatus quincenal con 57 invitados donde se plantean dependencias no cumplidas; su alta presión sobre el programa implica un rol de oversight activo con expectativas muy altas de puntualidad y entrega.","concerned","2026-04-28"),
    ("gabriela-maximiliano","gobierno","Gabriela Maximiliano fue identificada como responsable de invitar a Cristian Zazueta a las reuniones semanales de SmartVista y Transact — su postura de coordinación operativa la posiciona como facilitadora de la integración entre Atlas y los streams.","neutral","2026-04-28"),
    ("rodrigo","gobierno","Rodrigo confirma el business case de Apolo hasta 2028; su postura al validar el alcance estratégico sin cuestionarlo implica respaldo al roadmap propuesto aunque sin comprometerse en fechas técnicas.","supportive","2026-04-29"),
    ("erica-mata","seguridad","Erica Mata (CISO) tiene preocupación implícita sobre si las interfaces temporales de SmartVista con el legado están pasando datos sensibles a un sistema legado no completamente certificado en PCI — riesgo de seguridad estructural del programa.","concerned","2026-04-07"),
    ("karina-zepeda","pisa","Karina Zepeda participó como liaison del equipo ACN con el legacy; su presencia en sesiones de arquitectura del sistema legado indica que el equipo ACN está construyendo conocimiento directo de PISA para el diligence.","neutral","2026-04-23"),
    ("pablo-lorenzo","cronograma","Pablo Lorenzo impulsa una postura agresiva hacia el roadmap: divide R4 en tres liberaciones independientes, exige que el roadmap sea integral con assumptions y riesgos, y establece ciclos de prueba separados. Implica que el programa ha operado con planeación naïve hasta ahora.","concerned","2026-04-30"),
    ("emmy","apolo","Emmy (Apoyo Negocio) fue identificada como contacto para clarificar requerimientos de onboarding N4 y la estrategia de negocio; su presencia implica que el área de negocio tiene representación aunque limitada en las mesas técnicas.","neutral","2026-04-23"),
    # ── 3 posiciones adicionales (clave natural distinta a las anteriores) ──
    ("alejandro-gallegos","integracion","Alejandro Gallegos participó en la sesión de arquitectura de integración del 8 de abril como observador del diagnóstico sobre el API marketplace y el estándar contract-first; tiene visibilidad directa de las brechas de onboarding y la falta de proceso formal para equipos que consumen APIs.","neutral","2026-04-08"),
    ("salomon-monroy","cronograma","Salomón Monroy participó como observador en la sesión de estrategia y roadmap del 8 de abril donde Pablo Lorenzo expuso las cinco estrategias faltantes del programa; su presencia implica que el equipo ACN tiene evidencia directa del gap entre el alcance del negocio y la capacidad operativa de Unity.","neutral","2026-04-08"),
    ("brenda","regulatorio","Brenda Pichardo fue identificada como el canal para obtener los expedientes CNBV que contienen arquitecturas de referencia de Apolo, SmartVista y Transact; su postura implica que el acceso a documentación regulatoria estratégica requiere gestión formal a través de su área, lo que introduce fricción en el proceso de diligence.","neutral","2026-04-28"),
]

# ─────────────────────────────────────────────────────────────────────────────
# OPEN_ITEMS — (date, item, owner_id, priority, systems_list)
# priority ∈ {high, medium, low}
# ─────────────────────────────────────────────────────────────────────────────
OPEN_ITEMS_RAW = [
    # ── 10 Abril · Transact ────────────────────────────────────────────────────
    ("2026-04-10","Crear plan unificado de fechas para la integración de Transact con canales; los equipos de canales confirmaron que no pueden asumir el compromiso actual del plan de integración.",None,"high",["transact","integracion"]),
    ("2026-04-10","Detallar planes de trabajo para 2026 y 2027 e incluir el plan de migración para 2028 reflejando los cambios solicitados por el negocio (cuenta N4 priorizada, Escenario 2).","pablo-lorenzo","high",["transact"]),
    ("2026-04-10","Compartir lista completa de integraciones de Transact con volumetría de transacciones, clientes y número de cuentas en formato editable.",None,"high",["transact","integracion"]),
    ("2026-04-10","Documentar los supuestos internos y externos utilizados para estimar los tiempos de implementación de Transact, incluyendo la dependencia crítica de disponibilidad de tarjeta de débito en la próxima PI.",None,"medium",["transact"]),
    # ── 15 Abril · Testing ────────────────────────────────────────────────────
    ("2026-04-15","Crear roadmap integrado transversal hasta 2030 que unifique las visiones de Transact, Apolo, SmartVista y Legacy con capas de análisis, diseño, construcción y testing por drops.","pablo-lorenzo","high",["transact","apolo","smartvista","pisa"]),
    ("2026-04-15","Identificar y documentar plan de remediación para los pain points sistémicos del testing: SIT extendido hasta 5 meses, UAT extendido hasta 2 meses por baja dedicación del negocio, conflicto de ambiente único, e incumplimiento de SLAs de BPC.",None,"high",["testing","smartvista","apolo"]),
    # ── 16 Abril · Atlas ──────────────────────────────────────────────────────
    ("2026-04-16","Crear y presentar el plan integrado E2E — incluyendo inputs de Transact, Apolo, SmartVista y Legacy — para la junta directiva de accionistas del 24 de abril.","pablo-lorenzo","high",["transact","apolo","smartvista","pisa","atlas"]),
    ("2026-04-16","Generar plan general detallado del Proyecto Atlas en conjunto con el equipo de Arquitectura para presentar esta semana; incluir las 4 fases (Crawl/Walk/Run/Fly) con fechas concretas.",None,"high",["atlas"]),
    ("2026-04-16","Incorporar dry runs (simulacros integrales de ETL antes de UAT) y Dress Rehearsals (2-3 simulacros de go-live en preproductivo) al plan de migración de datos de cada ola de Atlas.","pablo-lorenzo","high",["atlas","pisa"]),
    # ── 23 Abril · Apolo + Legacy + SmartVista ───────────────────────────────
    ("2026-04-23","Consolidar el inventario de APIs de Apolo (~600 APIs) separadas por building block en una vista unificada; obtener acceso de solo lectura a la documentación de integraciones de Apolo TDC (R3).",None,"high",["apolo","integracion"]),
    ("2026-04-23","Identificar al arquitecto responsable del track Apolo N4/débito para obtener visión completa de interfaces de ese alcance.",None,"high",["apolo"]),
    ("2026-04-23","Investigar si existe un plan formal para reducir la latencia de 5 segundos en la capa proxy de Apolo en producción, considerando que la situación empeorará con Web Methods y el cifrado de datos sensibles.",None,"high",["apolo"]),
    ("2026-04-23","Verificar el estatus regulatorio (CNBV, Banxico, Ley de Protección de Datos) de los datos personales de Apolo almacenados sin cifrar en AWS fuera del territorio mexicano (CURP, RFC, teléfono, email).",None,"high",["apolo","seguridad","regulatorio"]),
    ("2026-04-23","Contactar a Juan Andrés, Óscar Melo o Luis Barragán para solicitar y analizar el inventario completo de APIs del sistema Legacy (600-700 APIs existentes del equipo de habilitadores).","pablo-lorenzo","high",["pisa","integracion"]),
    ("2026-04-23","Solicitar a Brenda Pichardo los expedientes entregados a la CNBV para Transact, SmartVista y Apolo como fuente de arquitecturas de referencia e inventario de interfaces del Legacy.","brenda","high",["pisa","transact","smartvista","apolo","regulatorio"]),
    ("2026-04-23","Documentar el alcance funcional de PISA y sus customizaciones mediante entrevistas con subdirectores de desarrollo y operaciones, para reflejar la cobertura real en el diagrama de arquitectura del programa.",None,"medium",["pisa"]),
    ("2026-04-23","Formalizar el requerimiento de Tarjeta de Débito (TDD) para SmartVista con Sergio del Valle; actualmente no está en el backlog y carece de estimaciones, riesgos y dependencias documentadas.",None,"high",["smartvista"]),
    ("2026-04-23","Solicitar inventario de interfaces R2 y R3 de SmartVista/TDC con detalle de sistemas de origen y destino.","pablo-lorenzo","high",["smartvista","integracion"]),
    ("2026-04-23","Planificar reunión formal para iniciar el ejercicio de mapeo de capacidades empresariales de SmartVista; Ana Rosa y Leonardo confirmarán los participantes del equipo de arquitectura.","pablo-lorenzo","high",["smartvista","arquitectura"]),
    # ── 24 Abril · SmartVista + Transact ─────────────────────────────────────
    ("2026-04-24","Organizar sesión de mapeo de capacidades de arquitectura funcional de Apolo con equipos de arquitectura y líderes técnicos; consultar con Leonardo cuáles arquitectos deben participar.","pablo-lorenzo","high",["apolo","arquitectura"]),
    ("2026-04-24","Validar el plan integral (assumptions, alcance, roadmap) con Sergio del Valle antes de presentarlo a Juan Manuel.","pablo-lorenzo","high",["cronograma","gobierno"]),
    ("2026-04-24","Contactar a David Estrada para obtener fechas y cronograma del proyecto Copel Pay y definir si habrá front dedicado de onboarding o se manejará vía promociones.",None,"medium",["smartvista"]),
    ("2026-04-24","Confirmar con Araceli Barcena (PM de Transact) si la versión N4 de Cuenta Digital usa Apolo o el back de sucursal para el onboarding.",None,"high",["transact","apolo"]),
    ("2026-04-24","Proveer listado de dependencias críticas del legacy para Transact incluyendo Western Union, recargas de tiempo aire y pago de servicios — enviar antes del siguiente miércoles.",None,"high",["transact","pisa","integracion"]),
    ("2026-04-24","Solicitar sesión ejecutiva con Sergio del Valle para presentar y obtener feedback sobre la evolución del mapa integral de Unity hasta 2028.","pablo-lorenzo","high",["cronograma","gobierno"]),
    # ── 28 Abril · Testing + Arquitectura + Atlas + SmartVista Interfaces ────
    ("2026-04-28","Iniciar conversaciones con Andrés, Bucio y Daniel Ángeles para habilitar ambientes de QA separados por producto (BPC, Launch, OPI, SEW, Apollo) previos al ambiente EIT integrado.","daniel-angeles","high",["testing","apolo","smartvista","transact"]),
    ("2026-04-28","Actualizar la estrategia de pruebas del banco (4 años de antigüedad): revisar herramientas, diagramas de entornos y reflejar estado actual de gestión, automatización y desempeño.","pablo-lorenzo","medium",["testing"]),
    ("2026-04-28","Socializar con todos los participantes del plan director las brechas críticas de testing, las remediaciones propuestas y el enfoque del roadmap integrado — alineando supuestos de tiempos de prueba.","pablo-lorenzo","high",["testing","cronograma"]),
    ("2026-04-28","Contactar a Miguel Bucio para revisar la situación crítica del reemplazo de Lenin (arquitecto Apolo, sale el 31 de mayo), las asignaciones de arquitectos a value streams y las acciones de mitigación necesarias.","lukasz-pietrzyk","high",["apolo","arquitectura"]),
    ("2026-04-28","Verificar qué módulos de SmartVista están contratados por BanCoppel, incluyendo el módulo autorizador; primera versión del análisis esperada a mediados de mayo.",None,"high",["smartvista"]),
    ("2026-04-28","Gestionar inclusión del equipo Accenture en la sesión con el proveedor SmartVista para revisar qué módulos de la plataforma están contratados y habilitados.","lukasz-pietrzyk","high",["smartvista"]),
    ("2026-04-28","Agendar sesión de API onboarding con Gabriel Alejandro Maldonado Hernández y Anayeli Ortiz para revisar el procedimiento de incorporación de API.",None,"medium",["arquitectura","integracion"]),
    ("2026-04-28","Consultar a Cristian el estado de asignación de arquitectos con conocimiento bancario al proyecto Atlas para evitar desviaciones en el trabajo posterior.","lukasz-pietrzyk","medium",["atlas","arquitectura"]),
    ("2026-04-28","Desarrollar guías de arquitectura sobre cuándo y cómo usar caché para APIs, considerando integración multi-cloud con legado (Transact y SmartVista); incluir en estándares de arquitectura de Unity.",None,"medium",["arquitectura","smartvista","transact"]),
    ("2026-04-28","Cristian Zazueta debe compartir el plan de trabajo detallado de Atlas (Fase 1 y Fase 2) incluyendo hitos y dependencias críticas con el equipo ACN.",None,"high",["atlas"]),
    ("2026-04-28","Cristian Zazueta debe compartir el documento de definición funcional de la carga de datos en SmartVista con BPC (datos para validar la migración de TDC clásica).",None,"high",["atlas","smartvista"]),
    ("2026-04-28","Invitar a Cristian Zazueta a las reuniones semanales de SmartVista, Transact y Apolo — con prioridad en SmartVista y Transact por ser las migraciones más críticas.","gabriela-maximiliano","high",["atlas","smartvista","transact"]),
    ("2026-04-28","Mapear y cuantificar el esfuerzo adicional no mapeado requerido para modificar reportes operativos y regulatorios ante el cambio de ID de producto 6001 → 4900 en SmartVista, y gestionar el período de convivencia de ambos IDs ante Banxico.",None,"high",["regulatorio","smartvista"]),
    ("2026-04-28","Definir la estrategia detallada de integración del MDM (Golden Record en Google Cloud) con SmartVista y Transact (en AWS): APIs, conexiones multi-cloud y manejo de latencia — hito requerido antes de septiembre 2026.",None,"high",["atlas","smartvista","transact","datos"]),
    ("2026-04-28","Identificar y documentar las interfaces inversas de conciliación (de legado hacia SmartVista) que aún no están en producción; determinar plan de habilitación y responsable.",None,"high",["smartvista","pisa"]),
    ("2026-04-28","Oscar Melo y Eduardo Ponce deben compartir el fichero Excel del inventario de interfaces batch de SmartVista con prioridades, objetivos, funcionalidades e identificadores.",None,"high",["smartvista","integracion"]),
    ("2026-04-28","Oscar Melo y Eduardo Ponce deben enviar los archivos originales en formato Draw.io de los flujos de interfaces SmartVista (los PDFs actuales son inadecuados para el análisis).",None,"medium",["smartvista","integracion"]),
    ("2026-04-28","Agendar sesión con el equipo QA a principios de la semana siguiente para socializar brechas críticas, remediaciones y el enfoque propuesto para el roadmap integrado de pruebas, alineando supuestos de tiempos con mejores prácticas.","pablo-lorenzo","high",["testing"]),
    ("2026-04-28","Proponer SLAs más realistas para resolución de defectos (los actuales —4 horas para críticos— nunca se cumplen); el equipo de QA no tiene alternativa definida y este punto quedó abierto.",None,"medium",["testing"]),
    # ── 29 Abril · Transact + Apolo + Legado ─────────────────────────────────
    ("2026-04-29","Entregar trazado de capacidades de arquitectura a lo largo del tiempo (progreso por releases, no solo End State) para su revisión el martes siguiente.",None,"high",["transact","arquitectura"]),
    ("2026-04-29","Detallar el estado de dependencias críticas entre Transact y el legado (Western Union, recargas y otros servicios); coordinar con Gloria y buscar documentación existente.",None,"high",["transact","pisa"]),
    ("2026-04-29","Preparar versión estable del roadmap integrado para Juan Manuel con diapositivas explicativas, riesgos documentados e hipótesis que justifiquen posibles retrasos futuros; listo para socializar el martes.","pablo-lorenzo","high",["transact","apolo","smartvista"]),
    ("2026-04-29","Agendar sesión de 30 minutos con Luis Arturo Valdivieso Cruz el 30 de abril para revisar en detalle el roadmap de Apolo R4.","pablo-lorenzo","high",["apolo"]),
    ("2026-04-29","Actualizar la carpeta normativa CNBV incorporando los desarrollos de Apolo R4 necesarios para la salida a mercado abierto en diciembre 2026.",None,"high",["apolo","regulatorio"]),
    ("2026-04-29","Clarificar si existen tareas de migración o dependencias críticas con Legacy para SmartVista R3 y R4, y evaluar opciones para asumir riesgos y acortar Go-Lives.",None,"high",["smartvista","pisa","cronograma"]),
    ("2026-04-29","Crear grupo de chat de Google para seguimiento ágil de temas de legado, sumando gerentes del equipo de Arturo Pérez.","arturo-perez","medium",["pisa","gobierno"]),
    ("2026-04-29","Planificar workshops detalladas de impacto de Unity en legado por aplicativo (CW/Offi, cajeros, POS, Ares), incluyendo personal crítico de los streams Apolo, SmartVista y Transact.","pablo-lorenzo","high",["pisa","apolo","smartvista","transact"]),
    ("2026-04-29","Confirmar si los sistemas legados actuales de POS/ATM serán dados de baja para la conexión con Iglobe — implicación arquitectónica no resuelta.",None,"high",["smartvista","pisa"]),
    ("2026-04-29","Revalidar el inventario de aplicativos legados identificados, separando aplicativos reales de agrupaciones de stored procedures, con participación de equipos de desarrollo de Unity.",None,"medium",["pisa","gobierno"]),
    ("2026-04-29","Verificar si la integración de Onbase a Transact que ya existe corresponde a la Transact de Unity o a otra instancia — dato crítico para evitar doble trabajo.",None,"medium",["transact","pisa"]),
    # ── 30 Abril ──────────────────────────────────────────────────────────────
    ("2026-04-30","Actualizar el roadmap para reflejar la división de R4 en tres liberaciones independientes y validar assumptions y riesgos del plan.","pablo-lorenzo","high",["smartvista","apolo"]),
    ("2026-04-30","Identificar un único punto de contacto con el equipo de Legado y planificar workshops enfocados por track (uno para Transact, uno para SmartVista).",None,"high",["pisa","transact","smartvista"]),
    ("2026-04-30","Estandarizar y unificar los formatos de los inventarios de interfaces — trabajo a realizar después de que finalice el diligence de Accenture.",None,"medium",["integracion","smartvista","transact"]),
    # ── 7 Abril ───────────────────────────────────────────────────────────────
    ("2026-04-07","Priorizar el desarrollo de la funcionalidad de clientes existentes para R3/R4 antes de la salida a mercado abierto — cambio que modifica la esencia de Apolo.",None,"high",["apolo"]),
    ("2026-04-07","Compartir inventario de desacoplamiento de APIs especificando la proporción de microservicios desacoplados versus stored procedures directos (actualmente 60/40).",None,"medium",["apolo","integracion"]),
    ("2026-04-07","Ligar el DRP para que incluya Apolo y SmartVista de forma conjunta; actualmente no existe gobierno transversal de transaccionalidad.",None,"high",["apolo","smartvista"]),
    ("2026-04-07","Implementar pruebas de rendimiento formales para evaluar capacidad de Apolo bajo volúmenes de producción — aún no realizadas.",None,"high",["apolo"]),
    ("2026-04-07","Implementar herramientas de monitoreo para detectar fallas y detener campañas de tráfico pagado (97% del tráfico de onboarding) para evitar pérdidas.",None,"high",["apolo"]),
    ("2026-04-07","Compartir el roadmap R4 de SmartVista incluyendo riesgos y dependencias mapeadas por equipos de TI.",None,"high",["smartvista","cronograma"]),
    ("2026-04-07","Ajustar el presupuesto base de SmartVista y alinear el business case a las metas de 2030.",None,"high",["smartvista"]),
    ("2026-04-07","Implementar el preautorizador de SmartVista como precondición obligatoria para iniciar la migración de portafolio TDC.",None,"high",["smartvista","atlas"]),
    ("2026-04-07","Compartir la visión de interfaces, manual de monitoreo y documentos de SmartVista para revisión del equipo (responsable: Jose Jaimes Ortiz).",None,"medium",["smartvista","integracion"]),
    ("2026-04-07","Definir la Arquitectura Objetivo (To-Be) de Transact — actualmente inexistente mientras el roadmap se proyecta a 2029.",None,"high",["transact","arquitectura"]),
    ("2026-04-07","Completar la recopilación de Requisitos No Funcionales (RNF) de rendimiento para Transact — el benchmark actual es solo 50 transacciones por minuto.",None,"high",["transact"]),
    ("2026-04-07","Resolver la desactualización crítica de la plataforma Transact, que no ha recibido actualizaciones desde octubre de 2015.",None,"high",["transact"]),
    ("2026-04-07","Implementar automatización del proceso de deployment para Transact y sus componentes — actualmente todo es manual y burocrático (~30 días para habilitar prerrequisitos).",None,"medium",["transact"]),
    ("2026-04-07","Realizar revisión exhaustiva de seguridad a nivel aplicativo de Transact — las brechas de infraestructura están identificadas pero falta la revisión aplicativa.",None,"high",["transact","seguridad"]),
    # ── 8 Abril ───────────────────────────────────────────────────────────────
    ("2026-04-08","Generar y compartir el plan integral de migración unificado (TDC y Banca Minorista) antes del viernes; responsable: Christian Zazueta.",None,"high",["datos","atlas","smartvista"]),
    ("2026-04-08","Compartir el diccionario de datos completo y los orígenes mapeados del dominio de clientes; responsable: Christian Zazueta.",None,"medium",["datos","atlas"]),
    ("2026-04-08","Compartir slides de Atlas y detalles específicos del proyecto con el equipo de Accenture; responsable: Raúl Goycoolea.",None,"medium",["atlas"]),
    ("2026-04-08","Priorizar la transferencia de conocimiento de AWS Glue con el proveedor antes de iniciar la ejecución de la migración automatizada.",None,"high",["datos","atlas"]),
    ("2026-04-08","Coordinar sesión de seguimiento para discutir temas de migración y gobierno de datos entre BanCoppel y Accenture.",None,"medium",["datos","gobierno"]),
    ("2026-04-08","Revisar el setup actual del marketplace de APIs para confirmar la arquitectura para accesos internos y externos, incluyendo Coppel.",None,"medium",["integracion"]),
    ("2026-04-08","Formalizar un proceso de onboarding para equipos que inician el desarrollo de APIs — actualmente inexistente, accesos se dan de forma incremental.",None,"medium",["integracion","gobierno"]),
    ("2026-04-08","Definir el objetivo de capacidad máxima para las pruebas de rendimiento del flujo completo de Apolo — el objetivo inicial de 50 usuarios/60 segundos es insuficiente para producción.",None,"high",["apolo","integracion","testing"]),
    ("2026-04-08","Producir un mapeo de arquitectura a nivel empresarial (no aplicativo) para identificar componentes o módulos de PISA no cubiertos por Transact, SmartVista ni Apolo.",None,"high",["pisa","arquitectura"]),
    ("2026-04-08","Reunirse con Luis Barragán y Fabiola Corrales para extraer el know-how sobre la contabilidad de PISA con miras a una posible migración a plataforma modernizada.","luis-barragan","high",["pisa"]),
    ("2026-04-08","Actualizar el business case de Unity para reflejar que el time to market y la habilitación de nuevas funcionalidades son más beneficiosos financieramente que el desmantelamiento inmediato de infraestructura.","pablo-lorenzo","high",["pisa","gobierno"]),
    ("2026-04-08","Evaluar y formalizar el plan de implementación de Change Data Capture (CDC) para extracción de datos de saldos, cuentas y clientes de la base central Informix.",None,"medium",["pisa","datos"]),
    ("2026-04-08","Asegurar la participación activa de las áreas de Operaciones, Fiscal, Contabilidad y Normatividad en las mesas de planificación del programa Unity — actualmente excluidas.",None,"high",["gobierno","regulatorio"]),
    ("2026-04-08","Desarrollar propuestas de acciones correctivas enfocadas en la dirección y estructura del plan de proyecto integral end-to-end de Unity.","pablo-lorenzo","high",["gobierno"]),
    ("2026-04-08","Establecer un responsable único (accountable) para el gobierno integral end-to-end del programa Unity — brecha crítica identificada en el diagnóstico estratégico.",None,"high",["gobierno"]),
    ("2026-04-08","Desarrollar una visión de roadmap de negocio a largo plazo (2 a 3 años) que guíe las decisiones a nivel de programa/banco, trascendiendo los dominios individuales.",None,"high",["cronograma","gobierno"]),
    ("2026-04-08","Validar con Arcadio la documentación pendiente referente al proyecto Atlas y compartirla lo antes posible.","arcadio","medium",["atlas"]),
]

# ─────────────────────────────────────────────────────────────────────────────
# Asignación de IDs secuenciales
# ─────────────────────────────────────────────────────────────────────────────
DECISIONS = [
    (f"AI-DEC-{i+1:04d}", d[0], d[1], d[2], d[3], d[4])
    for i, d in enumerate(DECISIONS_RAW)
]

OPEN_ITEMS = [
    (f"AI-OI-{i+1:04d}", r[0], r[1], r[2], r[3], json.dumps(r[4]))
    for i, r in enumerate(OPEN_ITEMS_RAW)
]


# ─────────────────────────────────────────────────────────────────────────────
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