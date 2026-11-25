<!--
  Documento: lectura del Punto de Vista de Accenture sobre ciclo de desarrollo con IA
  Fuente:    source/docs/AI_SDLC__Point_of_view_es-LATAM.pptx (13 láminas, es-LATAM)
  Proyecto:  SDLC Reinvent (03 - SPE/HVM/MM/Banamex/projects/sdlc-reinvent/)
  Audiencia: equipo interno de Accenture. No es material de cliente.
  Versión:   v1.0 · 2026-10-28
-->

# El Punto de Vista de Accenture sobre el ciclo con IA, y qué hacemos con él

**Conclusión primero.** La tesis que habíamos construido para Banamex de forma independiente, que el tiempo de salida está dominado por esperas y no por tecleo, y que hay que medir antes de automatizar, ya es doctrina de casa. Este documento la dice con más precisión que nosotros y con mecanismos concretos. Eso nos deja en una posición mucho mejor: no llegamos con una opinión, llegamos aplicando una postura de firma.

Hay una trampa que evitar, y es la misma que hundió la versión 3.3. Las cifras de este punto de vista describen un ciclo genérico, no el de Banamex. Si las presentamos como si fueran del banco, repetimos el error exacto que nos costó la propuesta.

---

## Qué dice el documento

### El diagnóstico que coincide con el nuestro

La lámina tres es la pieza central. Describe un ciclo de siete fases, de ocho a doce semanas y de ocho a doce personas, y dibuja las esperas entre fases de forma explícita: de dos a tres días entre requerimientos y diseño, de tres a cinco entre diseño y planeación, de uno a dos antes de desarrollo, de dos a cinco antes de pruebas, de uno a tres antes de liberación y de uno a dos al final.

El texto que acompaña ese dibujo vale la propuesta entera: "Handoffs, aprobaciones y esperas entre fases agregan de 10 a 20 días a cada ciclo. Estos retrasos son invisibles en los reportes de velocidad de los sprints, pero explican por qué los clientes todavía se sienten trabados, incluso después de adoptar Agile."

Y el encabezado de la lámina es todavía más útil: "Las líneas en rojo son retrasos que no vemos en los reports del sprint."

### Los tres pilares, y por qué el orden importa

El marco tiene tres dimensiones que el documento declara simultáneas y obligatorias. Herramientas y plataforma es el motor. Ingeniería de contexto, entendida como el conocimiento institucional que alimenta a la IA, reglas de negocio, estándares de código, arquitectura, código base, decisiones pasadas e historial de incidentes, es la diferenciación. Y el modelo de operación es el habilitador, descrito como "el sistema humano que viabiliza o limita la IA".

La frase que mejor resume el argumento es el título del segundo acto: "El Modelo tiene que cambiar, no solo la herramienta", con el subtítulo "El desarrollo acelerado por IA expone todos los cuellos de botella humanos". Es exactamente la lectura de la evidencia externa que ya teníamos: la IA amplifica el sistema de ingeniería que ya existe.

### Las cuatro palancas

**Acelerar cada fase.** Mantiene la estructura actual y acorta cada paso, con porcentajes de apoyo de IA por fase que van de 20 a 35% en requerimientos y diseño, de 40 a 60% en desarrollo, de 60 a 80% en pruebas y de 70 a 90% en liberación. El propio documento es honesto sobre el límite: "¿Y los retrasos entre ellas? Continúan; eso es lo que abordan las próximas palancas." Esa honestidad es la que hay que conservar.

**Gobernanza por puntuación.** Es el mecanismo más valioso del documento para nuestro caso. Un motor puntúa cada cambio en ocho dimensiones, complejidad, riesgo, regulatorio, urgencia, alineamiento estratégico, impacto en el negocio, reversibilidad y confianza de la IA, y lo enruta por una de cuatro vías: ejecución automática sin notificación, revisión acelerada con acuerdo de servicio de dos horas, revisión estándar al siguiente día hábil, o revisión elevada con arquitecto y seguridad. La afirmación es que más del 80% de los cambios avanzan sin revisión humana, con "cero gaps de compliance: calibrado por riesgo, no por un proceso único". El principio que lo encabeza es el que hay que decirle a un director de operaciones: "No todo cambio merece una reunión. Solo aquellos que exigen criterio."

**Spec-Driven Development.** Comprime el ciclo de ocho a doce semanas a entre tres y cinco días, con un único punto de decisión humana antes de que se escriba código. El principio: "No empieces con el código. Empieza con la intención. La especificación es el plan de ejecución."

**Ingeniería de arnés.** Define cuatro elementos alrededor del agente: contexto, que es la memoria institucional construida una vez y usada en todas las sesiones; alcance, que son los límites explícitos de lo que puede tocar; herramientas, que son las interfaces y canalizaciones con las que actúa; y lazo de validación, con compuertas de prueba embebidas para que el agente valide su propio trabajo y escale cuando haya incertidumbre.

### El camino, y lo que el propio documento pide hacer primero

Tres fases. Pathfinder en los meses uno a tres, con un equipo y un producto de punta a punta, métricas de línea base establecidas y acordadas, base de conocimiento inicial y sin reorganización. Aceleración en los meses cuatro a nueve, con tres a cinco equipos, un centro de excelencia de tres a cinco personas y el motor de puntuación en vivo. Multiplicación a partir del mes diez.

Y las tres acciones que propone iniciar de inmediato, en orden. La primera es la que nos importa: **"Establece el baseline de las métricas actuales, story points por sprint, time-to-market, tiempo de espera por ciclo. Formaliza esos números antes de cualquier adopción de herramientas de IA."** La segunda es elegir un equipo y un producto para el programa de noventa días. La tercera es definir el frente de compromiso, costo, ingreso o calidad, con meta y plazo.

---

## Qué nos resuelve para Banamex

**Nos da respaldo de firma para el argumento central.** No vamos a decirle al director de operaciones "creemos que el tiempo se va en esperas". Vamos a decirle que es la postura de Accenture, que la cuantifica en diez a veinte días por ciclo, y que la razón por la que no se ve es que los reportes de sprint no la miden. Viniendo de alguien que adoptó Agile en un banco mexicano en 2015 y que sabe perfectamente que sus reportes de velocidad se ven bien, ese argumento aterriza.

**Nos da el número de la pirámide.** El modelo de operación propone pods de tres a cinco personas contra los ocho a doce de hoy, y el cambio de mentalidad de codificador a orquestador. Esa es, en una línea, la respuesta a lo que Leyva pide: menos gente, más técnica. No es una consigna, es una forma de equipo con tamaño declarado.

**Nos da el mecanismo para quitar gestores sin quitar controles.** La gobernanza por puntuación es la única manera honesta de contestar la pregunta regulatoria. No se eliminan las aprobaciones, se enrutan por riesgo, y ochenta por ciento de los cambios deja de pasar por una reunión. Para un banco bajo Circular Única eso es la diferencia entre una propuesta viable y una ilegal.

**Nos da la escalera completa.** Tres semanas de medición, que es lo que pide nuestro documento de una página, y después noventa días de Pathfinder con un equipo y un producto. No es una invención nuestra: el propio punto de vista pone la línea base antes de cualquier herramienta y el piloto sin reorganización. Eso convierte nuestra petición pequeña en el primer peldaño de un camino de firma, en lugar de un encargo suelto.

**Y nos da el formato que Leyva dijo que compra.** Un equipo, un producto, sin reorganización, sin despliegue de gran corte. Es textualmente "ladrillo a ladrillo".

---

## Qué hay que cambiar antes de usarlo con Banamex

**Las cifras del ciclo son genéricas y hay que decirlo.** Siete fases, ocho a doce semanas, ocho a doce personas, diez a veinte días de espera. Eso no es Banamex, es el patrón de la industria. Si lo llevamos sin esa advertencia, el interlocutor va a pedir la fuente y vamos a tener que decir que no es su banco. Esa es exactamente la escena que nos costó la propuesta anterior. La forma correcta de presentarlo es como la hipótesis que la medición de tres semanas va a confirmar o refutar con datos suyos.

**El objetivo de duplicar la productividad en la fase uno no se compromete.** El documento lo pone como resultado de Pathfinder, y la regla del proyecto es que no se compromete ninguna métrica sin línea base. El propio punto de vista está de acuerdo, porque su primera acción es establecer la línea base antes de nada. Hay que presentarlo como meta del piloto, no como promesa de la propuesta.

**La tasa de aceptación de IA de 35% es un umbral, no un resultado.** El documento la marca como requerida en la fase uno. Conviene ligarla con la evidencia externa que ya tenemos: en el estudio controlado de 2025, desarrolladores expertos aceptaron menos del 44% de las sugerencias y aun así tardaron más. El umbral del punto de vista es realista y conviene citarlo junto con esa evidencia, porque es lo que nos distingue de quien llega prometiendo milagros.

**Los nombres de herramientas se quedan fuera.** El documento menciona asistentes de código por nombre. Para Banamex eso es un campo minado: hay dos vehículos internos con supuestos de herramientas en conflicto y la decisión no está tomada. La propuesta tiene que ser neutral de herramienta hasta que la medición diga dónde está el cuello de botella.

**La palabra agente hay que dosificarla.** El cuarto pilar y el destino del documento descansan en orquestación de agentes. Es correcto y es el futuro, pero en una primera conversación con un director de operaciones que acaba de rechazar una propuesta por poco aterrizada, abrir con autonomía agéntica es volver a lo abstracto. Entra en la fase dos, no en la lámina uno.

---

## Cómo queda el encadenamiento con lo demás

| Pieza | De dónde sale | Qué aporta |
|---|---|---|
| El tiempo se va en esperas, no en tecleo | Este punto de vista, lámina 3 | Respaldo de firma con cifra de 10 a 20 días por ciclo |
| Medir antes de automatizar | Este punto de vista, lámina 12, acción 1 | Convierte nuestra petición de tres semanas en doctrina, no capricho |
| La IA amplifica el sistema que ya existe | DORA 2024 y 2025, estudio METR 2025 | Evidencia externa que coincide y da credibilidad al matiz |
| Equipos permanentes con tarjeta de resultados compartida | Caso DBS, 2018 | Precedente bancario del modelo de operación |
| Capacidad propia en vez de contratada | Caso DBS y trayectoria de Leyva en BBVA | Es su propia biografía profesional |
| Consolidar antes de acelerar | BBVA, Santander y Banorte | Los tres competidores locales lo hicieron en ese orden |
| Pods de 3 a 5 contra 8 a 12 | Este punto de vista, lámina 5 | El número concreto de la pirámide que pide el director de operaciones |
| Gobernanza por puntuación en ocho dimensiones | Este punto de vista, lámina 8 | El mecanismo para quitar gestores sin quitar controles |
| Línea base que caduca | Nuestro análisis | La urgencia, porque entra el proceso nuevo del otro proveedor |

---

## Vacío

El documento no trae fecha de publicación ni autoría visible en el texto extraído. Antes de citarlo como postura vigente de la firma frente a un cliente, conviene confirmar su versión, su fecha y si hay una edición más reciente.
