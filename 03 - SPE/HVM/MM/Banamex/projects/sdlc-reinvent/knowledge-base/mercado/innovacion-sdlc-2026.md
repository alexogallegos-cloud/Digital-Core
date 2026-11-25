<!--
  Documento: investigación de innovación del ciclo de entrega, insumo del roster de Digital Twins
  Proyecto:  SDLC Reinvent (03 - SPE/HVM/MM/Banamex/projects/sdlc-reinvent/)
  Audiencia: equipo interno de Accenture. No es material de cliente.
  Versión:   v1.0, 29 de octubre de 2026
  Complementa, no sustituye, la sección 7 del estudio de mercado, que ya cubre DORA 2024, DORA 2025
  y el ensayo de METR. Aquí va solo lo que esa sección no tiene.
-->

# La innovación del ciclo de entrega, y qué de eso está probado

**Fecha de corte de la investigación: 29 de octubre de 2026.**

## Para qué se hizo esta búsqueda

El roster de Digital Twins de este proyecto necesita dos cosas que no se inventan: un reparto de preguntas que corresponda a cómo el mercado entiende hoy el problema, y una línea clara entre lo que está medido y lo que es material de proveedor. Sin lo segundo, cada twin terminaría repitiendo cifras de marketing como si fueran hallazgos.

La conclusión de la búsqueda, en una frase: **hay mucho movimiento conceptual y casi ninguna medición independiente de tiempo de salida**. Las cifras que circulan son de un solo caso, autorreportadas, o aritmética sobre una anécdota. Eso no debilita la propuesta, la ordena: confirma que la línea base es el primer entregable y no un trámite previo.

---

## 1. Lo nuevo del informe DORA 2025 que no está en el estudio de mercado

La sección 7 del estudio ya tiene el hallazgo principal, que la inteligencia artificial amplifica el sistema de ingeniería existente. Lo que no tiene son las dos estructuras con las que el informe organiza ese hallazgo, y las dos son directamente utilizables.

**Los siete arquetipos de equipo.** El informe clasifica a los equipos encuestados en siete perfiles cruzando rendimiento, inestabilidad y bienestar. Los nombres que reportan las reseñas son Dificultades Fundacionales, Cuello de Botella Heredado, Limitado por el Proceso, Alto Impacto y Baja Cadencia, Estable y Metódico, Pragmático, y Alto Desempeño Armónico. Los extremos se describen como 20% de los equipos en el perfil armónico y 10% en dificultades fundacionales.

Para nosotros esto vale como instrumento, no como dato: es una pregunta que se le puede hacer a un equipo piloto en una sesión y que produce una ubicación comparable contra una muestra de casi cinco mil profesionales. El perfil Limitado por el Proceso y el de Cuello de Botella Heredado son los dos candidatos obvios para un banco con veintiún controles y un core de décadas, y ninguno de los dos se arregla con asistentes de código.

**El modelo de capacidades de inteligencia artificial.** El informe propone siete capacidades que determinan si la adopción de inteligencia artificial produce resultado o produce deuda. Las reseñas coinciden en estas: una postura declarada y comunicada sobre el uso aceptable, un ecosistema de datos sano, datos internos accesibles para las herramientas, control de versiones fuerte, trabajo en lotes pequeños, foco en el usuario, y plataformas internas de calidad.

Esa lista es casi un espejo del diagnóstico que ya tenemos del banco. Control de versiones y plataforma interna son exactamente dos de los huecos del mapa de 2025. Datos internos accesibles es exactamente lo que el conocimiento del banco cargado resuelve. Es decir, el informe no nos pide cambiar la propuesta: le pone nombre de capacidad medida a cuatro piezas que ya estaban dentro.

**La paradoja de productividad.** Un análisis secundario reporta que los desarrolladores individuales integraron 98% más solicitudes de cambio mientras el rendimiento de entrega de la organización se mantuvo esencialmente plano. Esa cifra viene de un proveedor de analítica de ingeniería y no está verificada contra el informe original, así que no se usa frente al cliente como número. Se usa como forma de decir algo que sí sostenemos: la velocidad local no es velocidad del sistema.

Fuentes: [anuncio del informe 2025 en Google Cloud](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report), [reseña de Splunk](https://www.splunk.com/en_us/blog/learn/state-of-devops.html), [síntesis de Faros](https://faros.ai/blog/key-takeaways-from-the-dora-report-2025), [entrevista con el autor principal en Jellyfish](https://jellyfish.co/blog/2025-dora-report/), [análisis de la paradoja en Typo](https://typoapp.io/blog/ai-impact-dora-metrics), [cobertura de TechTarget](https://www.techtarget.com/searchsoftwarequality/news/366631712/Google-DORA-Software-delivery-caught-up-to-AI-coding-tools).

---

## 2. El desplazamiento del cuello de botella, y la tensión con nuestro propio diagrama

Las casas de análisis coinciden en una secuencia de tres fases. Entre 2023 y 2024 la inteligencia artificial entró en codificación y pruebas unitarias. En 2025 se extendió a diseño, documentación y generación de pruebas. En 2026 el movimiento es hacia agentes orquestados de punta a punta. Esa secuencia externa corrobora las tres etapas de método que ya usamos, lo cual conviene decir porque significa que no inventamos una escalera para esta propuesta.

El argumento que acompaña esa secuencia es que **codificar dejó de ser la restricción, y el cuello de botella se corre a los pasos de la izquierda y de la derecha de la construcción**, que siguen corriendo a velocidad humana: planear, revisar, probar y desplegar.

Aquí hay una tensión con nuestro diagrama de chevrones que conviene nombrar antes de que alguien la note en la sala. Nuestro conteo de casos muestra que en la etapa de asistencia la inteligencia artificial toca los extremos del ciclo y no el medio, y que es la especificación la que entra al medio. La tesis externa dice lo contrario sobre dónde está la restricción: que el medio ya está resuelto y lo que falta son los extremos.

Las dos cosas pueden ser ciertas a la vez y en Banamex probablemente lo son. En una organización con cadena de ingeniería madura, el medio ya corre y la restricción son los extremos. En un banco sin control de versiones declarado ni integración continua en el mapa del proceso, el medio no está resuelto en absoluto. **La tesis de la industria asume una cadena que este banco todavía no tiene**, y esa es precisamente la razón por la que nuestro orden de trabajo empieza por medir y por construir cadena en vez de empezar por agentes.

El dato de adopción que acompaña esto es útil: alrededor de 84% a 90% de los desarrolladores ya usan herramientas asistidas, pero solo cerca de 13% de los equipos las tienen operando a lo largo del ciclo completo. Proviene de una consultora y no de un censo, así que se trata como indicativo. Dicho con cuidado, sirve para cerrar la objeción más probable del banco, que es creer que comprar licencias ya es tener el ciclo cubierto.

Fuentes: [el cuaderno de ciclo nativo de inteligencia artificial de Anthropic](https://claude.com/resources/articles/the-ai-native-sdlc-playbook), [Ciklum sobre el ciclo agéntico en 2026](https://www.ciklum.com/blog/ai-revolutionize-software-development-lifecycle/), [EPAM sobre el ciclo nativo](https://www.epam.com/about/newsroom/in-the-news/2026/from-traditional-software-to-a-native-ai-sdlc-how-genai-is-redefining-engineering), [Keyhole Software sobre adopción en 2026](https://keyholesoftware.com/?p=160747).

Advertencia de origen: las cuatro fuentes de este bloque tienen interés comercial en el tema. Ninguna presenta medición independiente de tiempo de salida de punta a punta tras adoptar un ciclo agéntico completo. Lo que se toma de aquí es el marco, no las cifras.

---

## 3. La evidencia de control producida por la cadena

Este es el bloque más útil para un banco y el peor documentado del mercado. No se encontró guía de supervisor sobre evidencia de cambio generada automáticamente. Lo que hay es práctica de proveedor, y conviene saber que es eso.

Lo que sí está razonablemente asentado como práctica:

**La cadena es un sistema de control de cambios regulado, no una herramienta de ingeniería.** En un banco, el camino que lleva un artefacto a producción tiene que producir evidencia de que la liberación no debilitó los controles. Esa es la lectura que vuelve a la cadena un asunto de riesgo y no de preferencia técnica, y es el argumento con el que se defiende su costo.

**Promoción lineal.** El artefacto que pasó las pruebas en el ambiente previo es el mismo que se promueve a producción, y las compuertas de promoción aplican aprobaciones, ventanas de cambio y verificación de política. Esto importa porque elimina la pregunta de si lo probado y lo liberado son lo mismo, que hoy en el banco solo se responde documentalmente.

**Política como código antes del despliegue.** Las reglas de cumplimiento se evalúan contra el cambio antes de que ocurra, y la evaluación misma queda como rastro de auditoría. Es la diferencia entre probar que se revisó y probar que no se podía pasar sin cumplir.

**La compuerta como recolectora de evidencia.** En lugar de que una persona junte capturas de pantalla, bitácoras y marcas de tiempo de aprobación, la compuerta las extrae de las herramientas que ya las producen y las concentra en un punto de decisión.

Y un hallazgo incómodo que vale la pena conocer antes de que lo use alguien más: un análisis de 2021 reporta que **las aprobaciones externas se correlacionan negativamente con el tiempo de entrega, la frecuencia de despliegue y el tiempo de recuperación, y no se correlacionan con la tasa de fallas en cambios**. Es decir, frenan y no protegen. La fuente es material de proveedor presentado en una sesión profesional, no un estudio arbitrado, y la afirmación es lo bastante fuerte como para que usarla sin ese matiz sea un riesgo. Se guarda aquí, se verifica antes de llevarla a una sala, y no se pone en un entregable de cliente en esta forma.

Fuentes: [integración y despliegue seguros en entornos regulados, Elliptic](https://www.elliptic.co/corpus/gen-3753/secure-coding/secure-ci-cd-for-regulated-environments.html), [gobierno del ciclo, Kosli](https://kosli.com/sdlc-governance), [evidencia en lugar de capturas de pantalla, Kosli](https://www.kosli.com/blog/evidence_not_screenshots-_how_teams_stay_always_audit-ready_in_servicenow/), [presentación sobre DevOps y aprobaciones, BCS Edimburgo 2021](https://edinburgh.bcs.org/events/2021/devops.pdf).

---

## 4. Plataforma interna y caminos pavimentados, con las cifras en su sitio

El mercado da por hecho que una plataforma interna con caminos de arranque listos acorta el tiempo de entrega. La evidencia disponible es toda de caso único o de proveedor.

Lo que circula: una aseguradora reporta 67% de reducción en tiempo de entrega y cinco veces más despliegues en más de cuarenta equipos; un banco digital reporta pasar de semanas a horas con la mitad de fallas en cambios; artículos de industria manejan rangos de 30% a 50% y de 40% a 60% sin nombrar la base de cálculo. Un artículo llega a reportar una mejora de 336 veces, que es aritmética sobre una anécdota.

**Ninguna de estas cifras entra en un entregable de este proyecto**, por la regla de no comprometer porcentajes sin línea base. Entran como lo que son: señal de que el patrón funciona en otros, con magnitud desconocida para este banco.

Lo que sí es aprovechable del bloque es la guía de medición, que coincide con la nuestra: medir las cuatro métricas de entrega por equipo, más tiempo de incorporación de una persona nueva y adopción real del camino pavimentado. Y una frase que vale como criterio de diseño: si el tiempo de entrega y el tiempo de recuperación no se mueven, lo que se construyó es un producto interno en el que los equipos no confían.

El pronóstico de que ocho de cada diez organizaciones grandes de software tendrán equipo de plataforma para 2026 es un pronóstico de adopción, no de resultado, y así hay que leerlo.

Fuentes: [caso de aseguradora en plataforma, Rapid Data](https://www.rapiddata.com/insights/case-studies/india-insurer-platform-engineering), [DevX sobre plataformas internas en 2026](https://www.devx.com/development/platform-engineering-internal-developer-platforms-2026/), [Apptension sobre caminos pavimentados](https://apptension.com/guides/platform-engineering-golden-paths-for-faster-delivery), [Jellyfish sobre caminos pavimentados](https://jellyfish.co/library/platform-engineering/golden-paths/).

---

## 5. El atasco en la entrada, que es donde está nuestro espacio

El hallazgo propio más importante del expediente es que las etapas uno y dos del proceso objetivo de 2025 están nombradas y nunca diseñadas, y que ahí vive el dato de alrededor de dos meses para liberar presupuesto ya decidido.

La literatura de gestión de flujo tiene nombre para eso y lo trata como una clase de problema conocida. El marco de portafolio describe el atasco de portafolio como un bloqueo que impide revisar, analizar, aprobar e implementar las iniciativas más significativas, y lo atribuye a lotes de trabajo sobredimensionados que dejan a quien decide sin tiempo para evaluar todo lo que está en vuelo. También establece que antes de admitir trabajo nuevo hay que entender la capacidad del equipo que lo recibirá, que es justamente lo que una cola anual de más de doscientas iniciativas no hace.

Las métricas de flujo que propone ese cuerpo de práctica, velocidad, tiempo, eficiencia, carga y distribución, se leen en relación unas con otras y no por separado. La eficiencia de flujo, que es la proporción entre tiempo trabajando y tiempo total transcurrido, es la que hace visible la espera, y es la métrica que falta en el modelo actual del banco: con veintiún controles y ninguno con tiempo medido, la eficiencia de flujo del ciclo es literalmente desconocida.

Esto confirma que el enrutador de la demanda merece ser un twin propio y no un subcomponente: es una clase de problema con cuerpo de práctica, con métrica específica, y es la única parte del ciclo que nadie ha diseñado todavía en este banco.

Fuentes: [flujo de portafolio en el marco escalado](https://scaledagileframework.com/portfolio-flow/), [qué fluye por un flujo de valor de software, Planview](https://blog.planview.com/what-flows-through-a-software-value-stream/), [gestión de flujo de valor, IBM](https://www.ibm.com/think/topics/value-stream-management), [métricas de flujo y cuellos de botella, The New Stack](https://thenewstack.io/flow-measurements-can-eliminate-bottlenecks-in-development/).

---

## 6. Qué se lleva el roster de Digital Twins de esta investigación

| Hallazgo | Qué cambia en el roster |
|---|---|
| El informe de 2025 trae un modelo de siete capacidades, y cuatro de ellas son huecos ya detectados en el banco | El twin de plataforma y el de línea base heredan ese modelo como lista de verificación externa, no como opinión nuestra |
| Los siete arquetipos permiten ubicar a un equipo contra una muestra amplia | El twin de adopción lo usa como instrumento de diagnóstico del equipo piloto |
| La restricción se corre a los extremos del ciclo, pero esa tesis supone una cadena que el banco no tiene | El twin del método es el dueño de esa tensión, y es quien impide saltar a agentes antes de tener cadena |
| No hay guía de supervisor sobre evidencia automatizada | El aseguramiento regulatorio se separa del gobierno y se vuelve twin propio, porque la pregunta de si el auditor acepta la evidencia no la responde quien diseña la compuerta |
| Todas las cifras de reducción son de caso único o de proveedor | El dueño del caso de valor existe para decir qué se puede comprometer, y el auditor de evidencia existe para que ninguna de esas cifras entre sin su marca de origen |
| El atasco en la entrada es una clase de problema con cuerpo de práctica y métrica propia | El enrutador de la demanda queda como twin, con la eficiencia de flujo como métrica a instrumentar |

---

## 7. Frescura y confianza

| Bloque | Fecha del dato | Confianza | Qué revalidar |
|---|---|---|---|
| Arquetipos y capacidades del informe 2025 | Publicación de 2025 | Media. Todo viene de reseñas, no del informe original | Verificar la lista exacta de siete capacidades y los porcentajes de arquetipo contra el documento primario, que ya está enlazado en el estudio de mercado |
| Paradoja de productividad, 98% más solicitudes integradas | 2025 | Baja. Proveedor de analítica, cifra no verificada | No usar como número frente al cliente hasta verificar |
| Desplazamiento del cuello de botella y fases 2023 a 2026 | 2026 | Media como marco, baja como medición | Sirve el marco. Las cifras no |
| Adopción de 84% a 90% y solo 13% con ciclo completo | 2026 | Baja. Consultora, sin método publicado | Buscar una fuente con método antes de citarla |
| Práctica de evidencia en cadena regulada | 2025 y 2026 | Media. Práctica asentada, fuentes con interés comercial | No hay guía de supervisor. Confirmar criterio con riesgo y auditoría del banco |
| Aprobaciones externas que frenan y no protegen | 2021 | Baja. Material de proveedor, afirmación fuerte | Verificar contra la fuente original antes de llevarla a una sala |
| Cifras de plataforma interna, de 30% a 67% | 2025 y 2026 | Baja. Caso único o sin base de cálculo | No entran en entregables. Señal direccional solamente |
| Atasco de portafolio y métricas de flujo | Cuerpo de práctica vigente | Alta como marco conceptual | Nada que revalidar. Falta instrumentarlo en el banco |

---

*Investigación cerrada el 29 de octubre de 2026. Complementa la sección 7 del estudio de mercado, que conserva la evidencia sobre DORA 2024, DORA 2025 y el ensayo de METR.*
