# GAP — Brechas del Proceso de Suscripción
> Generado: 2026-09-03 · 26 pain points aplicables a suscripción

---

## El Gap Central: HSD como Sistema Crítico

La **Hoja de Suscripción de Daños (HSD)** es un archivo Excel que actúa como el sistema
de cálculo técnico de la suscripción — tarificación, cúmulos, condiciones especiales,
carga de ubicaciones. No es un sistema tecnológico: es una herramienta manual sin integración.

**Consecuencias directas:**
- Sin trazabilidad automática de cambios en el cálculo técnico
- Sin integración con Vector (el expediente no captura el cálculo técnico)
- Sin integración con ERN (resultados catastróficos se copian a mano)
- Sin integración con SAFAC (condiciones de cesión se trasladan manualmente)
- Sin versionamiento: ¿qué HSD corresponde a qué folio en qué versión?
- Riesgo de error humano en cada transcripción

**Capacidad ETB faltante**: 6.3.2 Risk Assessment & Rating — el motor de tarificación
y cálculo técnico no existe como sistema. Es el gap más crítico del landscape.

---

## Mapa de Brechas por Fase

| Fase | Gap identificado | Causa raíz | ETB afectado |
|------|-----------------|------------|--------------|
| Preparación de la información | SINCO solo permite búsqueda por razón social + dirección; sin identificador confiable de cliente | Limitación de sistema | 6.3.1 |
| Evaluación del riesgo | ERN → HSD manual; sin API de resultados catastróficos | Falta de integración | 6.3.2 / 6.3.3 |
| Carga en HSD | HSD es Excel — sin integración, sin control de versiones | Ausencia de sistema | 6.3.2 |
| Definición de cotización | Condiciones técnicas se negocian por correo/WhatsApp | Sin sistema de negociación | 6.3.4 / 6.3.5 |
| Negociación | Sin pipeline de cotizaciones; cada caso es ad-hoc | Sin gestión de pipeline | 6.3.5 |
| Emisión (post-suscripción) | Recaptura manual de condiciones aprobadas en General Daños | Falta de integración | 6.4 |

---

## Pain Points de Suscripción (26 identificados)

### Con causa tecnológica confirmada

| ID | Categoría | Descripción | Causa tecnológica | Mejora propuesta |
|----|-----------|-------------|-------------------|-----------------|
| 5.01.1 | Avance condicionado por otras áreas y terceros | El responsable debe solicitar y dar seguimiento a faltantes, aclaracio | El canal existente (Vector) no es la unica fuente de la verdad debido a que la i | Concentrar en el registro del caso la información necesaria para conocer y segui |
| 5.03.1 | Avance condicionado por otras áreas y terceros | No existe una vista única del estado de las gestiones con otras áreas, | Las herramientas internas no actualizan automáticamente el avance de las gestion | Dar visibilidad en un mismo punto al estado actualizado de las gestiones pendien |
| 3.02.2 | Datos incompletos o inconsistentes | El suscriptor debe realizar búsquedas con distintas variantes de razón | Sistema  unicamente te permite busacr por razon social y direccion y no por el i | Permitir buscar y relacionar registros mediante un identificador confiable de cl |
| 3.02.5 | Datos incompletos o inconsistentes | La solicitud puede ser canalizada a una línea de negocio o equipo inco | El sistema no corrige automáticamente clasificaciones ambiguas o incorrectas. | Detectar datos faltantes o clasificaciones ambiguas antes de enviar el caso al e |
| 2.02.1 | Datos y documentos que requieren preparación manua | El suscriptor debe construir o adaptar manualmente el documento de pro | El documento de propuesta no se genera automaticamente a partir de las condicion | Permitir generar la propuesta a partir de las condiciones aprobadas del caso. |
| 1.01.1 | Información dispersa y herramientas no conectadas | El suscriptor debe revisar y reconciliar solicitudes, seguimientos y n | El sistema no integra automáticamente la información generada en correo, Monitor | Incorporar al registro del caso la información relevante generada en otros canal |
| 1.02.1 | Información dispersa y herramientas no conectadas | El suscriptor debe consultar y descargar por separado la siniestralida | La información esta fragmentada en diferentes sistemas | Dar acceso a una vista consolidada de la siniestralidad e historial de la cuenta |
| 1.03.1 | Información dispersa y herramientas no conectadas | En el handoff entre Suscripción y Emisión, los responsables deben reco | No hay controles que validen automáticamente que toda la información final sea c | Validar la consistencia de slip, registros, autorizaciones y soportes antes de t |
| 1.04.1 | Información dispersa y herramientas no conectadas | El responsable debe recapturar o trasladar manualmente información ent | Las herramientas utilizadas en el proceso no cuentan de forma uniforme con inter | Permitir que los datos necesarios pasen entre Vector y los sistemas operativos s |
| 1.04.2 | Información dispersa y herramientas no conectadas | El suscriptor debe volver a capturar en la HSD información que ya está | La HSD no recibe directamente la información contenida en el slip y en los archi | Permitir reutilizar directamente en HSD la información ya disponible en el exped |
| 1.04.3 | Información dispersa y herramientas no conectadas | El suscriptor debe trasladar manualmente los resultados de ERN a la HS | Los sistemas utilizados en el proceso no están concetados entre sí por limitante | Permitir que los resultados de ERN puedan utilizarse directamente en HSD. |
| 1.04.4 | Información dispersa y herramientas no conectadas | El responsable debe volver a capturar manualmente en General Daños cob | Los sistemas utilizados en el proceso no están concetados entre sí por limitante | Permitir reutilizar en General Daños las condiciones ya definidas en las etapas  |
| 1.05.1 | Información dispersa y herramientas no conectadas | Los indicadores basados en Vector no reflejan todo el recorrido de alg | Los reportes de tiempos y estatus utilizan principalmente la información registr | Incorporar en los indicadores la actividad relevante que ocurre fuera de Vector. |
| 4.01.1 | Reglas y controles no automatizados | La completitud y congruencia del expediente debe ser revisada manualme | No se validan automáticamente todos los requisitos que corresponden a cada produ | Incorporar validaciones de los requisitos aplicables según producto y tipo de ca |
| 4.02.1 | Reglas y controles no automatizados | El responsable debe consultar reglas, guías o referencias fuera de la  | La herramienta operativa no contiene todas las reglas que necesita aplicar el us | Hacer disponibles dentro de la herramienta las reglas necesarias para ejecutar e |
| 4.03.1 | Reglas y controles no automatizados | El suscriptor debe reunir, convertir y comparar manualmente distintas  | No hay un sistema que considere todas las reglas de negocio para determinar el r | Permitir evaluar en conjunto las restricciones necesarias para determinar la par |
| 4.04.1 | Reglas y controles no automatizados | Las asignaciones de las aprobaciones dependiendo del facultamiento del | La herramienta no compara automáticamente el facultamiento del suscriptor y asig | Identificar cuándo se necesita una aprobación y dirigir el caso al nivel de auto |
| 4.04.2 | Reglas y controles no automatizados | El suscriptor debe cotejar manualmente el slip de directo con el respa | No existe una validación automática que confirme que ambos documentos contienen  | Validar la consistencia entre las condiciones de directo y el respaldo de Reaseg |
| 7.01.7 | Sistemas inestables o con limitaciones funcionales | El suscriptor debe cargar varias veces la información de un mismo caso | La herramienta limita la cantidad de elementos que pueden procesarse en una sola | Permitir cargar en una sola vez todos los elementos que pertenecen a un mismo ca |
| 7.03.1 | Sistemas inestables o con limitaciones funcionales | Cada área de negocio desarrolla y mantiene herramientas propias para r | Las capacidades de cálculo de las herramientas oficiales no cubren de la misma f | Ampliar la cobertura de las herramientas oficiales para atender los cálculos y r |
| 6.01.1 | Versiones y cambios gestionados manualmente | El suscriptor debe identificar manualmente cuál es la versión vigente  | El repositorio conserva documentos, pero no concentra los acuerdos y cambios neg | Mantener un historial de versiones que permita identificar cuál es la vigente. |
| 6.02.1 | Versiones y cambios gestionados manualmente | Cuando cambia una condición negociada, el suscriptor debe identificar  | Son varios sistemas involucrados que están fragmentados y que requieren que se r | Permitir que un cambio se refleje en los cálculos y registros relacionados sin r |

### Con alta manualidad

| ID | Categoría | Descripción | Proceso manual identificado |
|----|-----------|-------------|----------------------------|
| 3.02.2 | Datos incompletos o inconsistentes | El suscriptor debe realizar búsquedas con distintas variantes de razón | La busqueda del cliente de folios es manual |
| 3.02.3 | Datos incompletos o inconsistentes | El suscriptor debe reconstruir manualmente la secuencia correcta de lo | — |
| 3.02.4 | Datos incompletos o inconsistentes | El suscriptor debe revisar y reclasificar manualmente siniestros cuand | La informacion registrada en siniestralidad es erronea y se herada al consultar  |
| 3.02.5 | Datos incompletos o inconsistentes | La solicitud puede ser canalizada a una línea de negocio o equipo inco | No se hace una validación de los datos antes de asignar el folio al equipo corre |
| 2.01.1 | Datos y documentos que requieren preparación manua | El responsable debe descargar, clasificar y ordenar manualmente archiv | No hay un formato obligatorio porque los brokers mandan a varias aseguradoras. E |
| 2.02.1 | Datos y documentos que requieren preparación manua | El suscriptor debe construir o adaptar manualmente el documento de pro | — |
| 1.01.1 | Información dispersa y herramientas no conectadas | El suscriptor debe revisar y reconciliar solicitudes, seguimientos y n | En ciertos productos y canales, la gestión del caso comienza fuera de Vector y e |
| 1.02.1 | Información dispersa y herramientas no conectadas | El suscriptor debe consultar y descargar por separado la siniestralida | — |
| 1.03.1 | Información dispersa y herramientas no conectadas | En el handoff entre Suscripción y Emisión, los responsables deben reco | — |
| 1.04.1 | Información dispersa y herramientas no conectadas | El responsable debe recapturar o trasladar manualmente información ent | — |
| 1.04.2 | Información dispersa y herramientas no conectadas | El suscriptor debe volver a capturar en la HSD información que ya está | — |
| 1.04.3 | Información dispersa y herramientas no conectadas | El suscriptor debe trasladar manualmente los resultados de ERN a la HS | — |
| 1.04.4 | Información dispersa y herramientas no conectadas | El responsable debe volver a capturar manualmente en General Daños cob | — |
| 4.01.1 | Reglas y controles no automatizados | La completitud y congruencia del expediente debe ser revisada manualme | Los requisitos no siempre se validan de una sola vez al ingresar la solicitud, p |
| 4.03.1 | Reglas y controles no automatizados | El suscriptor debe reunir, convertir y comparar manualmente distintas  | — |
| 4.04.1 | Reglas y controles no automatizados | Las asignaciones de las aprobaciones dependiendo del facultamiento del | La revisión del facultamiento se realiza como un control separado después de pre |
| 4.04.2 | Reglas y controles no automatizados | El suscriptor debe cotejar manualmente el slip de directo con el respa | — |
| 7.01.7 | Sistemas inestables o con limitaciones funcionales | El suscriptor debe cargar varias veces la información de un mismo caso | — |
| 6.01.1 | Versiones y cambios gestionados manualmente | El suscriptor debe identificar manualmente cuál es la versión vigente  | Los cambios pueden acordarse por distintos canales sin un paso único para cerrar |
| 6.02.1 | Versiones y cambios gestionados manualmente | Cuando cambia una condición negociada, el suscriptor debe identificar  | — |

---

## Pasos Sin Sistema (manualidad estructural)

De los 541 pasos del proceso, **145 (27%) no tienen
ningún sistema registrado**. Estos pasos se ejecutan con herramientas fuera del stack
de sistemas (correo, Excel, Teams, WhatsApp, llamadas telefónicas).

Muestra de pasos sin sistema (primeros 20):

| ID | LoB | Fase | Paso |
|----|-----|------|------|
| 1.1.1.2.3A.3 | Property | Preparación de la información | Paso 6A.3. Comparar las condiciones anteriores con la nueva solicitud para ident |
| 1.1.1.4.2B.2 | Property | Preparación de la información | Paso 8B.2. Cuando la información no está disponible para el suscriptor, solicita |
| 1.1.1.4.3 | Property | Preparación de la información | Paso 9. Ordenar, limpiar y estandarizar la información recibida para utilizarla  |
| 1.1.2.3.1A.1 | Property | Evaluación del riesgo | Paso 15A.1. Preparar y validar la información de las ubicaciones en el formato r |
| 1.1.2.4.1 | Property | Evaluación del riesgo | Paso 17. Consultar la Guía de Suscripción para confirmar que el riesgo, las cobe |
| 1.1.2.4.2 | Property | Evaluación del riesgo | Paso 18. Determinar si el giro, la exposición o la capacidad solicitada requiere |
| 1.1.2.4.2A.1 | Property | Evaluación del riesgo | Paso 18A.1. Solicitar la inspección o el reporte de Ingeniería requerido para co |
| 1.1.3.1.2A.1 | Property | Definición de la cotización | Paso 20A.1. Cuando una condición exceda el facultamiento del suscriptor, solicit |
| 1.1.3.2.1A.1 | Property | Definición de la cotización | Paso 21A.1. Cuando se requiera coaseguro, definir la participación de Axa, el po |
| 1.1.3.2.1A.2 | Property | Definición de la cotización | Paso 21A.2. Solicitar y obtener la confirmación de las participaciones y condici |
| 1.1.3.3.2 | Property | Definición de la cotización | Paso 23. Abrir el machote vigente del slip y preparar una copia de trabajo para  |
| 1.1.3.3.3 | Property | Definición de la cotización | Paso 24. Construir la propuesta revisando sección por sección las coberturas, lí |
| 1.1.3.3.3B.1 | Property | Definición de la cotización | Paso 24B.1. Cuando exista Reaseguro Facultativo, comparar el slip de directo con |
| 1.1.4.1.2 | Property | Negociación de la cotización | Paso 27. Revisar la respuesta del agente, bróker o conducto para confirmar si la |
| 1.1.4.1.2A.2 | Property | Negociación de la cotización | Paso 27A.2. Actualizar el slip con los cambios aceptados y controlar su versión  |
| 1.1.4.2.1 | Property | Negociación de la cotización | Paso 28. Consolidar la versión final aceptada del slip para confirmar las condic |
| 1.2.1.3.1 | Property | Preparación de la colocación | Paso 3. Definir la estrategia de colocación y los conductos de mercado considera |
| 1.2.1.4.1 | Property | Preparación de la colocación | Paso 4. Preparar la oferta Facultativa que será presentada a mercados, consolida |
| 1.2.2.1.1 | Property | Colocación en mercados | Paso 5. Enviar la solicitud Facultativa a los brokers de Reaseguro y/o reasegura |
| 1.2.2.2.2 | Property | Colocación en mercados | Paso 7. Recibir las cotizaciones y términos ofrecidos por brokers/reaseguradores |
| … | … | … | *+125 pasos adicionales* |

---

## Brechas ETB — Capacidades Faltantes

| ETB ID | Capacidad | Estado en AXA | Brecha |
|--------|-----------|--------------|--------|
| 6.3.1 | Risk Information Management | PARTIAL — SINCO limitado | Sin identificador único de riesgo cross-sistema |
| 6.3.2 | Risk Assessment & Rating | **GAP** — HSD Excel | Motor de tarificación no existe como sistema |
| 6.3.3 | Catastrophe Modelling | PARTIAL — ERN confirmado | Resultados no se integran automáticamente |
| 6.3.4 | Quote Management | **GAP** — HSD + correo | Sin sistema de gestión de cotizaciones |
| 6.3.5 | Negotiation & Placement | **GAP** — correo/WhatsApp | Sin pipeline de negociación |
| 6.4   | Policy Administration | PARTIAL — General Daños | Recaptura manual desde slip |
| 6.5   | Reinsurance Management | PARTIAL — SAFAC | Solo estructura lineal |
| 4.1   | Distribution Management | **SCAFFOLD** — sin confirmar | Sin portal de agentes |
| 8.1   | Integration Platform | **SCAFFOLD** — sin confirmar | Sin API gateway entre sistemas |

---

*Generado por build-underwriting-intelligence.py el 2026-09-03*