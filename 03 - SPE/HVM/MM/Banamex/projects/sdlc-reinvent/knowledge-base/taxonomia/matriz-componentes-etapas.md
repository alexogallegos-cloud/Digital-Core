<!--
  Documento: matriz de los cinco componentes contra las tres etapas del método
  Proyecto:  SDLC Reinvent (03 - SPE/HVM/MM/Banamex/projects/sdlc-reinvent/)
  Audiencia: equipo interno de Accenture. No es material de cliente.
  Versión:   v1.0 · 2026-10-29
  Complementa componentes-del-sdlc.md (taxonomía) y ../palancas/pov-sdd-speckit.md (lectura del método).
  Advertencia de evidencia: la columna de etapa tres es construcción nuestra. No hay
  evidencia empresarial publicada que la respalde. Ver la sección final.
-->

# Los cinco componentes contra las tres etapas

## Qué distingue a cada etapa

No es el nivel de automatización. Es **cuál es la unidad de trabajo de la máquina y quién es el autor de qué.**

En **AI-Assisted Development**, la unidad es la sugerencia. El humano sigue siendo autor de todo; la máquina ayuda dentro de una tarea que el humano ya definió.

En **Spec-Driven Development**, la unidad es la tarea derivada de una especificación. El humano es autor de la intención; la máquina, de la implementación.

En **Skill-Driven Development**, la unidad es la capacidad compuesta. El humano cura el catálogo y verifica el resultado; la máquina ensambla lo que ya está resuelto.

Hay un segundo eje que distingue sobre todo a la etapa tres, y es el que más importa: **cómo aprende el equipo**. Spec-Driven Development crece de forma lineal, porque cada sesión arranca en frío y el equipo vuelve a hacer las mismas correcciones. Skill-Driven Development compone, porque una corrección se codifica una vez y esa categoría de error desaparece. La especificación codifica el qué, no el cómo, y por eso no captura las convenciones aprendidas que persisten entre tareas. Lectura completa en [desarrollo-dirigido-por-capacidades.md](../palancas/desarrollo-dirigido-por-capacidades.md).

---

## La matriz, en una línea por celda

| | Etapa 1, AI-Assisted Development | Etapa 2, Spec-Driven Development | Etapa 3, Skill-Driven Development |
|---|---|---|---|
| **Procesos** | El proceso no cambia | El proceso se ordena alrededor de la especificación | El proceso solo se aplica a lo que no se ha resuelto antes |
| **Artefactos** | Más documentos, no mejor gobierno | La especificación manda sobre el plan, las tareas y el código | Las correcciones dejan de repetirse |
| **Tecnología** | Se agrega un asistente de código a las herramientas actuales | La cadena de integración y despliegue pasa de complemento a prerrequisito | Se suma una capa de conocimiento: memoria, grafo del código y vocabulario |
| **Talento** | No cambia. Mismo tamaño, mismos perfiles, y la capa de coordinación intacta | Menos gente por entrega y más experimentada. Especificar es más difícil que programar | Equipos pequeños y senior, más un perfil nuevo que mantiene el conocimiento reutilizable |
| **Gobierno** | No cambia, y queda corto frente a código que la máquina ayudó a escribir | Las reglas no negociables se declaran de forma verificable antes del código | Se certifica la capacidad, no cada cambio, y la certificación caduca |

---

## Las quince intersecciones

### Procesos

**AI-Assisted Development.** El proceso no cambia. Las seis etapas siguen siendo seis, los traspasos siguen donde estaban y las esperas entre fases no se mueven, porque la IA acelera lo que ocurre dentro de una tarea y no lo que ocurre entre dos. Es la razón precisa por la cual desplegar asistentes sin tocar el proceso no mueve el tiempo de salida, y por la cual los tableros de velocidad pueden mejorar mientras la entrega se sigue sintiendo lenta.

**Spec-Driven Development.** El proceso se reordena alrededor de un solo artefacto. Las fases dejan de ser una secuencia de entregables distintos y pasan a ser refinamiento progresivo de lo mismo: constitución, especificación, plan, tareas, implementación. Los traspasos se reducen porque desaparece la retraducción del intento en cada frontera, que es donde se pierde información y se consume tiempo.

**Skill-Driven Development.** El proceso deja de instanciarse completo para cada iniciativa. Lo repetible ya está resuelto en el catálogo y el proceso solo cubre lo que es nuevo. La pregunta de apertura deja de ser qué pasos sigo y pasa a ser qué parte de esto ya existe.

### Artefactos

**AI-Assisted Development.** Los artefactos siguen siendo documentos y la IA ayuda a redactarlos más rápido. El efecto neto es más documentación, no mejor gobierno. Hay un riesgo concreto que conviene nombrar: el volumen de texto que nadie lee crece más rápido que antes, y la ambigüedad que obliga a coordinar sigue intacta.

**Spec-Driven Development.** La especificación deja de ser documento y pasa a ser plano de control: versionada, con criterios de aceptación explícitos, y de ella se derivan el plan, las tareas y el código. Los veintiún artefactos de permiso dejan de ser papeles sueltos que alguien persigue y pasan a ser condiciones declaradas, verificables antes de que exista implementación.

**Skill-Driven Development.** Las correcciones dejan de repetirse. Un equipo en Spec-Driven Development vuelve a hacer la misma corrección en cada iniciativa, porque la especificación describe el resultado deseado pero no captura las convenciones aprendidas que persisten entre tareas, y cada sesión arranca en frío. Un equipo en Skill-Driven Development codifica una corrección una sola vez y esa categoría de error desaparece. Es la diferencia entre aprender de forma lineal y aprender de forma compuesta, y es el argumento entero de esta etapa.

### Tecnología

**AI-Assisted Development.** Un asistente de código montado sobre la cadena que haya. Si no hay control de versiones, ni integración continua, ni pruebas automatizadas, el asistente acelera el tecleo y nada más. Es exactamente la situación del punto de partida del banco, y explica por qué Tecnología arranca en proceso y no en definido.

**Spec-Driven Development.** La cadena de integración y despliegue pasa de complemento a prerrequisito. Control de versiones, integración y despliegue, pruebas automatizadas y ambientes a demanda. Sin ellos el método simplemente no corre, porque la validación continua contra la especificación no tiene dónde ejecutarse. Es el prerrequisito duro del enfoque y la razón por la cual el orden de los saltos no es negociable.

**Skill-Driven Development.** La plataforma deja de exponer herramientas y pasa a exponer capacidades, sobre tres piezas concretas de infraestructura: memoria de sesión, que es un almacén consultable de decisiones y transcripciones pasadas; grafo de conocimiento del código, que contesta qué se rompe si cambio esto; y vocabulario de comandos, para que el agente no adivine sintaxis. **De las tres, el grafo del código ya existe para el core de este banco y lo construimos nosotros:** 1,583 reglas trazadas al programa y a la línea, 152 programas, dependencias cruzadas y 2,668 términos normalizados. El portal del desarrollador es donde esas capacidades se publican, se versionan y se consumen.

### Talento

**AI-Assisted Development.** El mismo equipo con los mismos roles, tecleando más rápido. La capa de coordinación no se mueve ni un puesto, porque las tareas siguen siendo ambiguas y alguien tiene que seguir reconciliándolas. Es el punto donde la expectativa de reducir gestores se frustra, y conviene decirlo antes de que ocurra.

**Spec-Driven Development.** El ingeniero pasa de escribir a declarar y revisar, y el equipo baja de ocho a doce personas a entre tres y cinco. La coordinación se reduce por mecanismo y no por decreto: una tarea con entradas, salidas y criterios de validación explícitos no necesita quien la reconcilie con las demás. Esta es la conexión directa con la agenda declarada de reducir gestores, y es un argumento de causa, no de consigna.

**Skill-Driven Development.** Aparece un rol que hoy no existe en el banco: quien cura el catálogo de capacidades. Son pocos, muy senior, y su producto medible es la reutilización. Es la forma concreta de la pirámide invertida que el banco dice querer, con un entregable propio en lugar de un objetivo de plantilla.

#### La respuesta corta sobre el talento: baja, pero no de forma uniforme

**¿Crece o disminuye?** Disminuye, y no desde el principio. En la etapa uno no baja nada: el equipo es el mismo y la capa de coordinación tampoco se mueve, porque las tareas siguen siendo ambiguas y alguien tiene que seguir reconciliándolas. La reducción empieza en la etapa dos y viene de dos lugares distintos, que conviene no mezclar. Menos gente por unidad de entrega en el lado de ingeniería, y menos trabajo de coordinación porque las tareas dejan de necesitar quien las reconcilie.

**¿Dónde sale realmente el número?** De la coordinación, no de la ingeniería. Esa distinción importa porque es la que conecta con la agenda declarada de reducir gestores. La capa de seguimiento, reporte y administración existe porque el trabajo es ambiguo; cuando la especificación lleva criterios de validación explícitos, esa capa pierde su razón de ser. Eso es una causa, no una consigna.

**¿Se requiere gente más experimentada?** Sí, y es el cambio más fuerte de la fila. La pirámide se invierte en proporción: escribir una especificación que una máquina pueda ejecutar y después juzgar si lo que produjo sirve es más difícil que escribir el código. En la etapa tres aparece además un perfil que hoy no existe en el banco, el que mantiene el conocimiento reutilizable, y su producto medible es la reutilización y no la funcionalidad entregada.

**Lo que no se promete.** Ninguna magnitud. La relación de equipos de tres a cinco contra ocho a doce es una cifra genérica de la industria, no una medición de este banco, y la regla del proyecto es que no se compromete un número sin línea base. Se compromete la dirección.

**El riesgo que hay que nombrar.** Si baja la entrada de perfiles junior porque la máquina hace el trabajo de entrada, en cinco años no hay de dónde salgan los senior que el modelo exige. Para un banco que declaró que quiere capacidad propia en lugar de contratada, ese es un problema de cantera, no de productividad, y no se resuelve solo. Conviene ponerlo sobre la mesa antes de que lo ponga alguien más.

---

### Gobierno

**AI-Assisted Development.** El gobierno no cambia y empieza a quedar corto. Los controles siguen siendo de paso único y ahora revisan código que un humano no escribió del todo, con el mismo criterio con el que revisaban código escrito a mano. Es donde aparece la exposición de cumplimiento sin que nadie la declare, y es la etapa más peligrosa de las tres precisamente porque parece inofensiva.

Hay una forma más dura de decirlo, y es exacta. La etapa uno tiene dos caras: asistida cuando está gobernada, y prompting no estructurado con corrección sobre la marcha cuando no lo está. **Sin control de versiones, sin integración continua y sin automatización de pruebas no existe mecanismo alguno que distinga una de la otra.** Ese es el estado declarado del banco en Tecnología, y es la razón concreta por la cual la cadena de ingeniería es prerrequisito y no complemento.

**Spec-Driven Development.** La constitución convierte los estándares de arquitectura, los requisitos de seguridad y el marco regulatorio en reglas que se comprueban antes de que se escriba código. Las compuertas se enrutan por riesgo en lugar de aplicarse por igual, y el rastro de especificación a código produce la evidencia de cumplimiento por construcción y no por esfuerzo. Aquí vive también la medición, que es subcomponente de Gobierno: es la primera etapa en la que el ciclo tiene denominador.

**Skill-Driven Development.** El gobierno se mueve del cambio a la capacidad. Se certifica una vez la capacidad y cada uso hereda esa certificación, con su evidencia. Es la diferencia entre auditar mil cambios y auditar cuarenta capacidades, y es el único argumento de esta matriz que un regulador reconoce de inmediato.

Y aparece un objeto de control que hoy no existe: **la biblioteca de capacidades es un activo gobernado**, que hay que versionar, certificar y caducar. Una capacidad obsoleta que un agente aplica con convicción no es un defecto de software, es un incidente de cumplimiento. La literatura señala que el mantenimiento de la biblioteca, con sus duplicados y regresiones, es el riesgo principal de este enfoque y no una nota al pie. La certificación tiene que tener vencimiento.

---

## Lo que la matriz revela, y es el hallazgo

Léase la primera columna completa. En los cinco componentes, la etapa uno no cambia nada o empeora las cosas. El proceso sigue igual, la documentación crece sin mejorar el gobierno, el asistente corre sobre una cadena que no existe, el equipo y sus gestores quedan intactos, y los controles revisan con criterio viejo un código de origen nuevo.

**Esa columna es el mejor argumento del expediente.** Dice, con la taxonomía del propio banco y sin una sola cifra de proveedor, que comprar licencias de asistente de código es la forma más cara de no cambiar nada. Y dice por qué el salto uno es medir: sin denominador, la etapa uno se vive como progreso.

Conviene decirlo sin tono de reproche. No es un error del banco: es el estado en el que está casi todo el mercado, incluidos los referentes que citamos.

---

## Dónde está el banco, y qué falta saber

El punto de partida declarado es Emergente, con Tecnología en proceso. En términos de esta matriz, el banco **no ha completado la etapa uno**: la automatización de tickets es un paso previo al asistente de código, y la cadena sobre la que ese asistente correría no está en el mapa de 2025.

Hay dos datos que no tenemos y que cambian el diagnóstico. El primero es si hay asistentes de código desplegados hoy, con cuántas licencias y con qué uso real. El segundo es si existe control de versiones y cadena de despliegue fuera del alcance de aquel levantamiento, que estaba marcado como no exhaustivo. Las dos preguntas se contestan en la sesión y las dos son baratas de preguntar.

---

## Advertencia de evidencia

Las columnas uno y dos descansan en fuentes verificables. En la columna tres hay que separar dos cosas. **El problema está documentado:** un modelo de lenguaje es, por construcción, sin estado, y cada sesión empieza sin memoria de la anterior, lo que valida la amnesia de sesión como fenómeno real. **El nombre y el beneficio, no:** Skill-Driven Development no tiene definición establecida, la referencia más cercana es la entrada de blog de un solo autor, y la afirmación de crecimiento compuesto no aparece probada en la literatura.

Conviene recordar además que incluso la etapa dos tiene evidencia controlada delgada: el piloto más riguroso que encontramos no halló diferencia significativa en detección de defectos con especificación contra sin ella. Y que ninguna cifra que circula sobre estas etapas sobrevive la pregunta de la fuente, empezando por las de líneas de código por unidad de tiempo, que además miden lo que no importa.

Eso no invalida la dirección. Obliga a presentarla como dirección y no como resultado, y refuerza el argumento del salto uno: sin línea base, ninguna de las tres etapas se puede demostrar ni desmentir.
