<!--
  Documento: el proceso de entrega documentado en el levantamiento de 2025
  Fuente:    lámina "Banamex Transformación | Alcance", marcada "No exhaustivo"
  Fecha del dato: octubre de 2025. Un año de antigüedad al 28 de octubre de 2026.
  Proyecto:  SDLC Reinvent (03 - SPE/HVM/MM/Banamex/projects/sdlc-reinvent/)
  Audiencia: equipo interno de Accenture. No es material de cliente.
-->

# El proceso tal como se levantó en 2025

**Advertencia de vigencia antes que nada.** Este levantamiento es de octubre de 2025 y la lámina original está marcada como no exhaustiva. Tiene un año. En ese año el banco cambió de accionista mayoritario y de presidente del consejo. Es la única descripción específica del ciclo de Banamex que tenemos, y también la pieza que no se puede volver a presentar sin refrescar.

Dicho eso, leída con cuidado contiene el hallazgo más fuerte del expediente, y no es la lentitud.

---

## El hallazgo: el proceso documentado es de Citi, no de Banamex

Tres evidencias convergen.

**Las herramientas.** El ciclo corre sobre siete herramientas: PTS, Confluence, Jira, Risk Review Platform, Reviews@Citi, Architecture Center y ServiceNow. Una de ellas lleva el nombre de la matriz en el propio nombre, y aparece como herramienta de tres de las seis etapas.

**Los controles.** Export Compliance y Cross Border Attestation son controles propios de un banco global sujeto a régimen estadounidense. Un grupo financiero mexicano independiente no necesariamente los conserva, y desde luego no con ese nombre ni esa instancia.

**El vocabulario regulatorio.** Las menciones a MRA sin mapear atraviesan cuatro de las seis etapas, con plan de remediación en Iniciación, análisis de causa raíz y criterios en Planeación, y aprobación de aceptación en Post Implementación. Ese es el mundo de los requerimientos regulatorios del supervisor de la matriz, no el de la Comisión Nacional Bancaria y de Valores.

**La consecuencia, y es la que cambia la conversación.** El ciclo de entrega actual no es solo lento: es prestado. Está construido sobre plataformas, controles y obligaciones regulatorias que desaparecen con la separación. Rediseñarlo no es un proyecto de eficiencia que se pueda posponer. Es un entregable obligatorio de la separación, con la misma fecha dura que todo lo demás.

Eso contesta de raíz la objeción de prioridad. No estamos proponiendo mejorar algo que funciona. Estamos señalando que una pieza del programa de separación no tiene dueño.

---

## El segundo hallazgo: es un ciclo de gestión de proyectos, no de ingeniería

Las seis etapas son Gestión de la Demanda, Iniciación, Planeación de la Ejecución, Ejecución, Post Implementación, y Monitoreo y Control. Es la secuencia canónica de administración de proyectos.

Diseño, construcción y prueba no son etapas. Son actividades sepultadas dentro de Planeación de la Ejecución y de Ejecución. En un ciclo de entrega de software, las tres fases donde ocurre el trabajo aparecen como renglones de una lista.

Y en la lista de herramientas no hay control de versiones, no hay motor de integración y despliegue continuo, y no hay herramienta de automatización de pruebas. Las siete herramientas documentadas son de gestión, gobierno y riesgo. O la ingeniería quedó fuera del alcance del levantamiento, o no está gobernada. En cualquiera de los dos casos es un hallazgo, y hay que preguntarlo.

Para un interlocutor que dirigió una fábrica de software, esta observación es más potente que cualquier cifra de lentitud: su ciclo documentado administra proyectos, no entrega software.

---

## El tercer hallazgo: una etapa entera cuyo producto son reportes

Monitoreo y Control recibe como insumos solamente Incidencias y Riesgos. No produce ningún resultado: la casilla está vacía. Sus actividades son mantener el calendario, mantener el estatus, comunicación, mantener la lista del equipo, gestionar riesgos, gestionar incidencias y aprobar criterios de éxito e indicadores.

Es una sexta parte del ciclo documentado dedicada a administrar, informar y coordinar, sin entregar nada al cliente final. Es, con precisión, el trabajo de gestor que el Director de Operaciones quiere eliminar. No hay que argumentarlo: está en su propio mapa, con casilla de resultados vacía.

---

## El cuarto hallazgo: los puntos de control

Contando solo lo que aparece nombrado de forma explícita en la lámina:

**Como insumo de alguna etapa, trece artefactos de permiso, aprobación o atestación:** Permiso para Diseñar, Permiso para Construir, Atestación CART, Export Compliance, Aprobación de Seguridad de la Información, Atestación de permiso para desplegar, Aprobación CART, Atestación transfronteriza, Aprobación de inteligencia artificial y aprendizaje automático, Aprobación de Implementación, Número de Control de Cambio, Aprobación de Cierre, y Aprobación de Aceptación de criterios para MRA sin mapear.

**Como actividad, al menos cinco más:** Aprobar o rechazar la solicitud, Punto de control 1 con TISO, Aprobación IEP, Atestación y aprobación de seguridad de la información, y Aprobación de criterios de éxito e indicadores.

**Y tres cuestionarios obligatorios en la entrada:** Cumplimiento, Privacidad de Datos, y Mandatorio de Negocio y Tecnología.

Un detalle que conviene verificar antes de usarlo: **CART aparece dos veces**, como atestación en Planeación de la Ejecución y como aprobación en Ejecución. Puede ser un control en dos momentos por diseño, o puede ser duplicidad. Es exactamente el tipo de pregunta que la medición responde.

Dieciocho puntos de control nombrados, más tres cuestionarios de entrada, antes de contar los que el levantamiento omitió por no ser exhaustivo. Esa cifra es el argumento de la gobernanza por puntuación: no se trata de quitar controles, sino de que dieciocho controles de paso único son indistinguibles entre sí en costo de tiempo, sin importar si el cambio es un ajuste de etiqueta o una modificación al motor de pagos.

---

## Transcripción del levantamiento

### Etapa 1. Gestión de la Demanda

| | |
|---|---|
| Insumos | Información general de iniciativa, programa o proyecto; Categoría de Inversión; Cuestionario de Cumplimiento; Cuestionario de Privacidad de Datos; Cuestionario Mandatorio de Negocio y Tecnología; Estimación Inicial |
| Actividades | Crear solicitud de identificador; Revisar solicitud; Crear estimación; Evaluación de la solicitud en alcance y estimación; Aprobar o rechazar la solicitud |
| Resultados | Iniciativa aprobada |
| Herramientas | PTS, Confluence |

### Etapa 2. Iniciación

| | |
|---|---|
| Insumos | Épicas; User Stories de alto nivel; Plan de Remediación solo para MRA sin mapear; Arranque del programa o proyecto |
| Actividades | Documentación de requerimientos iniciales y User Stories; Identificación de sistemas impactados; Punto de control 1 con TISO; Aprobación IEP; Definir el modelo de gobierno; Identificar riesgos potenciales; Identificar requerimientos de nueva infraestructura si se necesita |
| Resultados | Involucramiento de TISO; Plan de trabajo con estimación inicial; Backlog inicial |
| Herramientas | Jira, PTS, Confluence, Risk Review Platform |

### Etapa 3. Planeación de la Ejecución

| | |
|---|---|
| Insumos | Documento de Alcance; Permiso para Diseñar; Permiso para Construir; Plan de Pruebas de Tecnología; Atestación CART; Export Compliance; Análisis de Causa Raíz para MRA sin mapear; Criterios de éxito e indicadores para MRA sin mapear |
| Actividades | Plan de trabajo detallado; Definir requerimientos y diseños de negocio y tecnología; Refinamiento a User Stories detalladas; Atestación y aprobación de seguridad de la información; Identificar cambios materiales esperados; Validación de impactos de arquitectura; Evaluar elegibilidad de pruebas de desempeño |
| Resultados | Validación de pruebas; Liberación a Producción de forma iterativa |
| Herramientas | Jira, PTS, Confluence, Risk Review Platform, Reviews@Citi, Architecture Center |

### Etapa 4. Ejecución

| | |
|---|---|
| Insumos | Backlog del sprint; Aprobación de Seguridad de la Información; Atestación de permiso para desplegar; Aprobación CART; Atestación transfronteriza; Aprobación de inteligencia artificial y aprendizaje automático; Reporte de Salida de Pruebas; Aprobación de Implementación; Número de Control de Cambio |
| Actividades | Desarrollo de software y pruebas unitarias; Pruebas de integración, aceptación de usuario, regresión, no impacto y desempeño; Evaluación de vulnerabilidades; Validación con Soporte de Producción; Documentación de Solicitudes de Cambio con plan de despliegue, estrategia de reversa y validaciones posteriores; Cumplir con los artefactos del ciclo de desarrollo |
| Resultados | Liberación a Producción; Gestión de Incidentes; Validación con Negocio y Tecnología |
| Herramientas | Jira, PTS, Confluence, Risk Review Platform, Reviews@Citi, Architecture Center, ServiceNow |

### Etapa 5. Post Implementación

| | |
|---|---|
| Insumos | Resultados y acciones de la Revisión Post Implementación; Aprobación de Cierre; Aprobación de Aceptación de criterios para MRA sin mapear |
| Actividades | Documentar lecciones aprendidas y plan de acción; Documentar retroalimentación del cliente de forma opcional; Validar que todos los entregables estén completos y actualizados; Confirmar que se cumplieron los Factores Críticos de Éxito; Cerrar riesgos e incidencias; Bitácora de acciones completada; Cerrar User Stories y Solicitudes de Cambio |
| Resultados | Proyecto o programa completado |
| Herramientas | Jira, PTS, Confluence, Risk Review Platform, ServiceNow |

### Etapa 6. Monitoreo y Control

| | |
|---|---|
| Insumos | Incidencias; Riesgos |
| Actividades | Mantener el calendario; Mantener el estatus; Comunicación; Mantener la lista del equipo; Gestionar riesgos; Gestionar incidencias; Criterios Críticos de Éxito e Indicadores aprobados |
| Resultados | Ninguno declarado |
| Herramientas | Ninguna declarada |

---

## Preguntas que este mapa abre y la medición responde

Cuánto tarda cada permiso y cada atestación, de solicitud a resolución. Es la cifra que convierte dieciocho controles en un número de días.

Si CART en Planeación y CART en Ejecución son dos controles o uno duplicado.

Qué proporción de los dieciocho controles sobrevive a la separación de la matriz, y cuáles hay que reconstruir sobre plataforma propia antes de 2029.

Dónde viven hoy el control de versiones, la integración continua y la automatización de pruebas, que no aparecen en el mapa.

Cuántas personas sostienen la etapa de Monitoreo y Control, cuya casilla de resultados está vacía.

Qué cambió en este proceso entre octubre de 2025 y hoy, considerando que entre medias el banco cambió de dueño.

---

## Cómo usarlo con el cliente

**No se presenta como diagnóstico.** Se presenta como lo que es: el levantamiento que hicimos hace un año, marcado como no exhaustivo, que sirve para formular preguntas y no para concluir. Decirlo nosotros primero desarma la objeción que ya nos hicieron.

**La línea que sí se afirma con seguridad** es la de la dependencia: el proceso documentado corre sobre herramientas y controles de la matriz. Esa es verificable a simple vista en el propio mapa del banco, y es la que convierte este trabajo en parte del programa de separación en lugar de una mejora opcional.
