<!--
  Documento: análisis del diseño to-be de SDLC que Accenture entregó en 2025
  Fuente:    source/docs/20250915_Banamex_SDLC.pptx, 45 láminas, septiembre de 2025
  Proyecto:  SDLC Reinvent (03 - SPE/HVM/MM/Banamex/projects/sdlc-reinvent/)
  Audiencia: equipo interno de Accenture. No es material de cliente.
  Versión:   v1.0 · 2026-10-29
  Complementa knowledge-base/linea-base/proceso-asis-2025.md, que describe el as-is.
-->

# El to-be que ya entregamos, y lo que obliga a cambiar

**Conclusión primero, y es incómoda.** Este documento no es un levantamiento del proceso actual. Es un **diseño de SDLC objetivo que Accenture preparó para el banco en septiembre de 2025**, con nueve etapas, modelo de roles completo, controles por etapa y un stack de herramientas nombrado por producto. Lo firma un Managing Director de Servicios Financieros de Accenture México.

Es decir, el rediseño del ciclo de entrega que estamos a punto de proponer **ya lo propusimos hace trece meses**. Si entramos a la sesión sin reconocerlo, la primera persona en la sala que estuvo en aquella presentación nos va a preguntar por qué estamos rediseñando lo que ya diseñamos. Esa pregunta hay que contestarla nosotros primero.

Y hay una lectura mucho mejor disponible. La pregunta más valiosa que podemos llevar no es un diagnóstico nuestro, es esta: **se diseñó esto hace trece meses, ¿qué pasó?** La respuesta, cualquiera que sea, vale más que cualquier lámina que podamos preparar.

---

## Qué es exactamente este documento

Cuarenta y cinco láminas, fechadas septiembre de 2025, tituladas *Accenture SDLC*. Cuatro secciones: Introducción, Roles Clave, Proceso y Herramientas. **Todas las láminas llevan el sello "documento preliminar, para discusión"**, y la lámina del stack lleva además la marca "Ilustrativo". No es un entregable cerrado.

La lámina 7 es la pieza que define su naturaleza: una tabla de **as-is contra to-be** que declara "los principales cambios en la forma de trabajar entre la operación actual en Banamex y el modelo operativo de SDLC propuesto". No describe el banco: propone reemplazarlo.

**Una inconsistencia que conviene revisar antes de citarlo.** La lámina 32 es una carta de presentación firmada por el Managing Director, pero su texto ofrece "asesoramiento especializado en el diseño y ejecución eficiente de los procesos de **adquisición tecnológica**", que no es el tema del resto del documento. O la carta viene de otra propuesta y quedó pegada aquí, o el encargo original era otro y el contenido se amplió. Vale la pena saber cuál antes de usar el documento como referencia de un compromiso.

**Y un desorden de fechas.** Este to-be es de septiembre de 2025 y el mapa del as-is que tenemos está fechado en octubre de 2025. El diseño objetivo es anterior al levantamiento del proceso actual. Puede ser que las fechas sean laxas, o que el mapa de octubre venga de un encargo posterior. Hay que resolverlo, porque diseñar el destino antes de levantar el punto de partida es exactamente la crítica que nos hicieron con la versión 3.3.

---

## Qué contiene, y qué de eso nos sirve

### Un proceso de nueve etapas

Gestión de la Demanda, Aprobación y Definición del Backlog, Diseño de Capacidades de Alto Nivel, Evaluación Técnica (que en la segunda versión del mismo documento se llama Planear), Visualizar y Preparar, Construir y Evolucionar, Pruebas y Aprobación, Despliegue y Cierre.

Es un ciclo de ingeniería, no de administración de proyectos. Esa es la diferencia de fondo con el mapa de octubre, cuyas seis etapas son la secuencia canónica de gestión de proyectos y donde diseño, construcción y prueba están sepultados como renglones de una lista. **El to-be ya corrigió ese hallazgo nuestro.** Hay que dejar de presentarlo como si nadie lo hubiera visto.

### Jerarquía de asignación presupuestal

La lámina 4 propone un modelo Lean-Agile de tres ritmos: anual para planeación y presupuestación de épicas, semestral para aprobación de presupuesto a nivel portafolio, y **trimestral para liberación de fondos y ajuste de capacidad**. Eso ataca de frente el subcomponente de Portafolio y fondeo de nuestra taxonomía, y es la respuesta al caso de ING, donde el modelo de financiamiento anual es lo que rompe estas transformaciones.

Conviene retenerlo: si ese modelo ya se propuso y no se adoptó, el obstáculo no es de método.

### Veintiún controles, los mismos que en el as-is

La lámina 15 lista los controles sugeridos para pasar de etapa, de la tres a la nueve. Contados uno por uno son **veintiuno**, el mismo número que los puntos de control nombrados en el mapa del as-is.

**Ese dato es importante y hay que usarlo con cuidado.** El to-be de 2025 no reduce la cantidad de compuertas. Lo que hace, y es mérito real, es volverlas nativas de ingeniería en lugar de documentales: revisión de código entre pares, verificaciones de integración continua, pruebas unitarias y automáticas superadas, validación en demo de sprint, aprobación del comité de cambios, plan de reversa validado. Son controles que se ejecutan solos en vez de perseguirse por correo.

Pero el número no baja. Y ahí está el espacio que nos queda: **ni el proceso actual ni el to-be de 2025 enrutan los controles por riesgo.** Los dos los aplican por igual a un ajuste de etiqueta y a un cambio en el motor de pagos. Esa sigue siendo la palanca sin tocar, y ahora podemos decirlo con los dos documentos del banco en la mano en lugar de con una opinión.

### Un modelo de roles completo, de sabor SAFe

Product Owner, IT Product Owner, Scrum Master, Business Analyst, Developer, Senior Developer, Tester, diseñador de experiencia, Arquitecto de Solución, Arquitecto de Seguridad, System Owner, DevOps Engineer y Release Manager. Cruzados: Business Owner, Journey Strategist, Project Manager, Release Train Engineer y Test Lead. De supervisión: Executive, Portfolio Manager, Epic Owner y Product Manager. Y participación puntual de Legal, Cumplimiento y usuarios finales.

**Aquí hay una tensión que nadie ha nombrado.** El vocabulario es inequívocamente SAFe: Épicas, Release Train Engineer, planeación de incrementos, Epic Owner. Y la propia lámina 31 del documento, que compara marcos, dice que SAFe es el más apropiado para **modelos de abastecimiento con socios**, mientras que LeSS y el modelo Spotify son los apropiados para **modelos internos**.

La agenda declarada del Director de Operaciones es exactamente la contraria: reducir dependencia de terceros y subir capacidad propia. Proponerle un marco que nuestro propio documento clasifica como el más adecuado para trabajar con socios es un problema que hay que ver antes de que lo vea él.

Segundo detalle de la misma lista: aparecen Project Manager, Release Train Engineer, Portfolio Manager, Scrum Master y Journey Strategist. Es **una capa de coordinación considerable**, y la agenda declarada es reducirla.

### Un stack de herramientas nombrado por producto

La lámina 29, marcada como ilustrativa, nombra proveedor por proveedor. Lo relevante para nosotros:

| Capacidad | Herramienta propuesta en 2025 | Por qué importa ahora |
|---|---|---|
| Portal del desarrollador | **Backstage** | Es el vehículo que decidimos excluir salvo que el banco lo traiga. Ya está en nuestra propia propuesta de hace trece meses |
| Asistente de código | **GitHub Copilot** | La etapa uno de nuestras tres no es hipotética para este banco: ya se propuso por nombre |
| Métricas de ingeniería | **LinearB** | La medición del ciclo estaba contemplada. Nuestro "no hay línea base" necesita matiz |
| Control de versiones, integración y despliegue | GitHub y GitHub Actions | El hueco de ingeniería del as-is ya tenía solución diseñada |
| Infraestructura como código | Terraform | Coincide con los arquetipos del laboratorio |
| Gestión de servicio, registro y gobierno automatizado | ServiceNow | Otro de los vehículos excluidos |
| Gestión de datos de prueba | K2View y YData | El problema regulatorio de datos de prueba ya estaba identificado |
| Observabilidad | Dynatrace, OpenTelemetry, Prometheus, Grafana | Coincide con lo que opera el banco |

También aparecen Jira, Confluence, Mural, Snyk, Sysdig, Selenium, Zephyr, GoLive, LoadRunner, HashiCorp Vault, Azure Active Directory, Gremlin, Apptio, Figura, MuleSoft y PagerDuty.

---

## Las nueve etapas, una por una

De las nueve, **solo siete tienen flujo detallado**. Las etapas uno y dos aparecen nombradas en la vista de extremo a extremo y no vuelven a aparecer: no tienen diagrama de carriles, ni entregables, ni controles. Las siete restantes están documentadas dos veces, en las láminas 16 a 26 y otra vez en las láminas 35 a 45, con diferencias menores de nombre y de reparto de carriles.

| # | Etapa | Flujo | Entregables declarados | Controles de salida |
|---|---|---|---|---|
| 1 | Gestión de la Demanda | **No** | Sin documentar | Sin documentar |
| 2 | Aprobación y Definición del Backlog | **No** | Sin documentar | Sin documentar |
| 3 | Diseño de Capacidades de Alto Nivel | Sí | Backlog de capacidades; priorización inicial de funcionalidades; arquitectura de solución de alto nivel; riesgos identificados | Revisión arquitectónica de alto nivel; aprobación de funcionalidades por Negocio |
| 4 | Evaluación Técnica, llamada Planear en la segunda versión | Sí | Backlog priorizado a nivel funcionalidad; roadmap de funcionalidades; arquitectura de solución; dependencias identificadas; definición preliminar de releases de tres a seis meses; cotización de TI | Validación de factibilidad técnica y de negocio; aprobación de dependencias críticas; alineación con capacidad de equipo y presupuesto |
| 5 | Visualizar y Preparar | Sí | Plan de sprints detallado; backlog priorizado por sprint a nivel historia de usuario; documentación técnica; plan de release trimestral; criterios de aceptación | Validación del plan detallado por stakeholders; revisión de dependencias entre equipos; aprobación formal del plan de release |
| 6 | Construir y Evolucionar | Sí | Incrementos de software; código versionado; documentación técnica ligera; actualización de backlog | Revisión de código entre pares y verificaciones de integración continua; pruebas unitarias y automáticas superadas; validación en demo de sprint |
| 7 | Pruebas y Aprobación | Sí | Resultados de pruebas funcionales; pruebas no funcionales de desempeño y seguridad; reporte de defectos y remediación | Cien por ciento de criterios de aceptación cumplidos; defectos críticos resueltos; firma de aceptación del dueño de producto o del negocio |
| 8 | Despliegue | Sí | Paquete de release; guiones de despliegue automatizado; documentación operativa; lista de verificación de salida a producción | Validación en ambiente de preproducción; aprobación del comité de cambios; plan de reversa validado; validación de accesos y monitoreo activo |
| 9 | Cierre | Sí | Lecciones aprendidas; reporte de cierre; actualización de documentación; transferencia a soporte | Revisión posterior a la implementación; confirmación de soporte activo; firma de cierre por stakeholders clave |

Veintiún controles en total, repartidos entre las etapas tres y nueve.

### El hueco, y no es menor

**Las dos etapas sin diseñar son exactamente la entrada del embudo.** Gestión de la Demanda, que es entender las prioridades estratégicas de cada área, y Aprobación y Definición del Backlog, que es revisar el roadmap de tres años y asignar presupuesto por portafolio.

Ahí vive la cola de priorización anual. Ahí vive también el único dato propio y reciente que tenemos sobre el ciclo del banco: alrededor de dos meses para liberar el presupuesto de una iniciativa que la dirección ya había decidido hacer.

Es decir, **el to-be de 2025 diseñó con detalle la parte del ciclo donde el tiempo probablemente no se va, y dejó sin diseñar la parte donde sí**. No es un reproche al documento, que está marcado como preliminar: es la brecha concreta que podemos ofrecer cerrar, y es nuestra sin competencia porque nadie la ha tocado.

La jerarquía de fondeo de la lámina cuatro, con liberación trimestral de presupuesto, es el único material que existe sobre esas dos etapas, y está en la sección de introducción, no en la de proceso.

---

## Qué obliga a cambiar en nuestro paquete

**Primero, la frase "en las siete herramientas no aparece la ingeniería" necesita una segunda oración.** Sigue siendo cierta del mapa de octubre de 2025. Pero el diseño que cierra ese hueco ya existe y lo hicimos nosotros. La afirmación correcta es más fuerte, no más débil: el hueco está identificado, la solución está diseñada, y trece meses después seguimos sin saber si se construyó.

**Segundo, "no hay línea base" hay que decirlo con precisión.** Lo que no hay es la medición. La herramienta para medir estaba propuesta y la recolección de métricas de costo, tiempos, defectos y satisfacción está escrita como actividad de la etapa nueve. Nuestra pregunta deja de ser "nadie ha medido" y pasa a ser **"se diseñó la medición, ¿se instrumentó?"**. Es una pregunta mejor porque no se puede contestar con una opinión.

**Tercero, Backstage y ServiceNow dejan de ser vehículos que elegimos excluir y pasan a ser antecedentes.** La decisión de no venderlos sigue en pie y es correcta. Pero no podemos actuar como si no existieran en nuestro propio expediente: si alguien en la sala tiene esta presentación, el silencio se lee como omisión.

**Cuarto, tenemos los dos extremos y no los estábamos usando juntos.** El mapa de octubre es el ciclo real del banco, sobre rieles del grupo. Este documento es el destino propuesto. La brecha entre los dos, trece meses después, es el objeto de la conversación. No hace falta inventar un diagnóstico: hay que medir cuánto de ese to-be se volvió realidad.

**Quinto, y es lo que más vale.** La pregunta de apertura deja de ser nuestra y pasa a ser suya. *Esto se diseñó en septiembre de 2025. ¿Qué se implementó, qué se detuvo y por qué?* Las respuestas posibles son pocas y todas útiles: nunca se aprobó, se aprobó y se estancó, se implementó parcialmente, o lo sustituyó el alcance que ganó el otro proveedor. Cada una lleva a una propuesta distinta, y ninguna se puede adivinar desde afuera.

---

## Lo que hay que averiguar antes de la sesión

Si esta presentación se entregó al banco, a quién y en qué foro. Si hubo decisión sobre ella. Qué parte del stack se implementó, en particular si hay control de versiones, integración continua y asistente de código operando hoy. Si el modelo de nueve etapas se adoptó en algún dominio. Qué relación tiene con el alcance de simplificación de proceso que ganó el otro proveedor, porque podrían estar trabajando sobre este mismo diseño.

Y la pregunta de consistencia interna: por qué la carta de presentación habla de adquisición tecnológica y el contenido es de ciclo de entrega.

Ninguna de estas se contesta desde fuera, y todas son baratas de preguntar adentro.
