<!--
  Documento: taxonomía de componentes del ciclo de entrega
  Proyecto:  SDLC Reinvent (03 - SPE/HVM/MM/Banamex/projects/sdlc-reinvent/)
  Audiencia: equipo interno de Accenture. No es material de cliente.
  Versión:   v1.0 · 2026-10-29
  Nivel 1 fijado por el usuario. Nivel 2 propuesto aquí, pendiente de revisión.
  Regla de uso: el nivel 2 NO va en la lámina de enfoque. Quince o veinte casillas
  devuelven el artefacto a la rúbrica que ya se descartó dos veces.
-->

# Los componentes del ciclo de entrega

El nivel uno son cinco: **Procesos, Artefactos, Tecnología, Talento y Gobierno**. Medición no es un sexto componente; vive dentro de Gobierno. Esa decisión ya está tomada y este documento no la reabre.

Lo que sigue es el nivel dos propuesto para los cinco, de modo que la profundidad quede pareja. Si solo Tecnología tuviera subcomponentes, la taxonomía se vería coja y eso es lo primero que nota alguien que dirigió una fábrica de software.

---

## La línea de corte, antes de la lista

Procesos, Artefactos y Gobierno se encabalgan en este caso concreto, porque los veintiún puntos de control del levantamiento son simultáneamente un paso de la secuencia, un documento que alguien produce y una compuerta que alguien autoriza. Sin una regla de corte, los tres componentes dirían lo mismo con distintas palabras.

La regla es esta. **Procesos** habla de la secuencia y de lo que espera a qué. **Artefactos** habla de lo que hay que producir para avanzar. **Gobierno** habla de quién decide, con qué criterio y con qué evidencia. El mismo control aparece en los tres, pero cada componente dice una cosa distinta sobre él.

---

## El estado inicial de los cinco

Es el punto de partida declarado, el nivel Emergente, y es de donde salen los tres saltos. Lo fijó el usuario el 29 de octubre de 2026.

| Componente | Estado inicial | De dónde sale el calificador |
|---|---|---|
| Procesos | Definido | Las seis etapas del levantamiento de 2025, montadas sobre herramientas y controles del grupo |
| Artefactos | Definidos | Veintiún puntos de control nombrados, más tres cuestionarios de entrada. Ninguno con tiempo medido |
| Tecnología | En proceso | Siete herramientas de gestión y gobierno. Ni ambientes, ni cadena de despliegue, ni automatización de pruebas, ni portal |
| Talento | Alrededor de 7,000 | Personas en Sistemas, de unas 18,000 en Tecnología y Operaciones, según la entrevista de abril de 2025 |
| Gobierno | Definido | Compuertas, criterio de aprobación y marco regulatorio existen. La medición del ciclo no |

**Por qué este punto de partida es generoso, y por qué conviene que lo sea.** Tres de los cinco están definidos. No es el retrato de una organización desordenada: es el de una organización que tiene proceso, artefactos y gobierno, y a la que le falta la tecnología de ingeniería y el denominador. Esa lectura es la correcta y además es la única que un director que construyó esa casa va a aceptar sin discutir.

**Dos cosas que el calificador tiene que decir, o el estado inicial engaña.**

La primera es que *definido* no es lo mismo que *propio*. Procesos, Artefactos y Gobierno están definidos sobre rieles del grupo, y eso es precisamente lo que no sobrevive a la separación. Si el estado inicial dice solo *definido*, perdemos el argumento de prioridad, que es el que contesta la objeción de la propuesta anterior.

La segunda es que Gobierno no puede decir *definido* a secas, porque Medición vive dentro de Gobierno y la medición del ciclo no existe. El calificador *sin medición del ciclo* resuelve la contradicción. Sin él, un lector atento pregunta qué estamos midiendo entonces, y tiene razón.

**El número de Talento tiene tres huecos y hay que declararlos.** La cifra es aproximada, no trae corte declarado y tiene dieciocho meses. No sabemos qué parte de esas 7,000 personas son desarrolladores, que es el subconjunto que importa, porque la agenda declarada es reducir gente de desarrollo. Y no sabemos la composición entre plantilla propia y terceros, sin la cual no se puede dibujar la pirámide de antes y después. Es el dato que conviene pedir en la sesión.

---

## 1. Procesos

La secuencia del trabajo y lo que espera a qué.

| Subcomponente | Qué cubre | Estado en el levantamiento de 2025 |
|---|---|---|
| Entrada y priorización de la demanda | Cómo entra el trabajo, cómo se estima y cómo se ordena la cola | Existe, etapa 1. La cola anual es una bolsa de tiempo sin medir |
| Flujo de entrega, de diseño a liberación | Diseño, construcción, prueba y liberación | Sepultado dentro de Planeación de la Ejecución y Ejecución, no son etapas propias |
| Traspasos y esperas entre etapas | El tiempo muerto entre fases, invisible en los reportes de velocidad | No aparece. Es la razón de ser de la línea base |
| Cambio, liberación y operación posterior | Control de cambio, plan de despliegue, reversa, ventana, post implementación | Existe. Monitoreo y Control no declara resultado |

---

## 2. Artefactos

Lo que hay que producir para que el trabajo avance.

| Subcomponente | Qué cubre | Estado en el levantamiento de 2025 |
|---|---|---|
| Permisos, atestaciones y aprobaciones | Los trece artefactos de control nombrados como insumo, más los tres cuestionarios obligatorios de entrada | Es la parte más densa del mapa. Ninguno con tiempo medido |
| Especificación y requerimientos | Épicas, historias, documento de alcance, diseños de negocio y de tecnología. **Con Spec-Driven Development este subcomponente cambia de naturaleza: la especificación deja de ser documentación de entrada y pasa a mandar sobre el plan, las tareas y el código** | Existe, repartido entre Iniciación y Planeación, y hoy como documento pasivo |
| Evidencia de cumplimiento y auditoría | Reporte de salida de pruebas, evaluación de vulnerabilidades, bitácora de acciones | Existe y se redacta a mano. Es lo que el salto tres genera desde la cadena |
| Conocimiento del banco | Reglas de negocio, arquitectura, decisiones pasadas, historial de incidentes | Disperso. Es lo que vuelve útil a la inteligencia artificial, y donde ya tenemos 1,583 reglas extraídas del core |

---

## 3. Tecnología

Las herramientas de la cadena. Cuatro capacidades y una capa de consumo encima de ellas.

| Subcomponente | Qué cubre | Estado en el levantamiento de 2025 |
|---|---|---|
| Herramientas de gestión del trabajo y del gobierno | Las siete herramientas documentadas | Es lo único que el banco demostrablemente tiene. Una lleva el nombre del grupo |
| Ambientes y datos de prueba | Provisión de ambientes, datos sintéticos, core emulado | No aparece. Es lo que Origen ataca con el laboratorio y los arquetipos |
| Cadena de integración y despliegue | Control de versiones, integración continua, despliegue | No aparece. El control de versiones va nombrado aquí dentro de forma deliberada, porque su ausencia es uno de los cuatro hallazgos y no puede quedar implícito |
| Calidad y automatización de pruebas | Pruebas automatizadas, regresión, gestión de datos de prueba | No aparece. En un banco los datos de prueba son un problema regulatorio, no de herramienta |
| Portal del desarrollador | Capa de consumo sobre las tres capacidades anteriores | No aparece |

**Por qué el portal va aparte.** Un portal del desarrollador no es hermano de la ambientación ni de la cadena de despliegue: es la superficie por la que el desarrollador las consume. Ponerlos como pares mezcla un piso con lo que contiene.

**Advertencia de alcance.** Nombrar el portal vuelve a Backstage estructuralmente pertinente, y Backstage quedó como única adyacencia posible y solo si el banco lo trae. Se sostiene mientras la taxonomía se presente completa y el portal aparezca como una casilla entre veintidós, no como el destino. Si en la sesión se convierte en el tema, nos salimos de la conversación del ciclo.

---

## 4. Talento

Forma, tamaño y capacidad de quien hace el trabajo.

| Subcomponente | Qué cubre | Por qué importa en este caso |
|---|---|---|
| Forma y tamaño del equipo | Equipos de tres a cinco contra ocho a doce. Permanencia del equipo, que depende del fondeo y por eso se cruza con Gobierno | Es el número concreto de la pirámide que pide el Director de Operaciones |
| Roles y pirámide técnica | El ingeniero desplazado de escribir a dirigir. La capa de coordinación, seguimiento y reporte | Es textualmente su agenda: menos gente de desarrollo, más seniority, menos gestores |
| Capacidad propia contra contratada | Qué se hace adentro y qué con terceros | Él ya dijo que el banco depende demasiado de terceros, y ya reinternalizó operaciones antes |
| Habilidades y criterio de uso de la inteligencia artificial | Umbral de aceptación de sugerencias, criterio de revisión, cuándo no usarla | Sin esto la adopción sube el rendimiento y también la inestabilidad |

---

## 5. Gobierno

Quién decide, con qué criterio y con qué evidencia.

| Subcomponente | Qué cubre | Estado |
|---|---|---|
| Medición y línea base | Qué se mide del ciclo, contra qué se compara, quién lo mira | Inexistente para el ciclo. Es el salto uno |
| Compuertas y criterio de aprobación | Los veintiún puntos de control y su enrutamiento por riesgo en ocho dimensiones | Existen las compuertas, no el criterio diferenciado. Es el salto tres |
| Riesgo, cumplimiento y regulación | Qué exige el regulador local y qué viene del supervisor de la matriz | Mezclado. Separarlo es parte del salto uno |
| Arquitectura y estándares | Qué se decide una vez y vale para todos los equipos. **Su forma verificable por máquina es la constitución de Spec-Driven Development: tecnologías permitidas, patrones, requisitos de seguridad y estándares de calidad, declarados también para la máquina** | Existe como validación de impactos, no como estándar reutilizable |
| Portafolio y fondeo | Cómo se asigna el dinero y por cuánto tiempo | Anual y por proyecto. Es donde se rompen estas transformaciones: el equipo puede ser ágil y el ciclo seguirá siendo lento |

---

## Dónde cae cada hallazgo

Sirve de prueba de que la taxonomía cubre el expediente y no al revés.

| Hallazgo | Componente | Subcomponente |
|---|---|---|
| El ciclo documentado corre sobre rieles del grupo | Gobierno | Riesgo, cumplimiento y regulación |
| Veintiún puntos de control, ninguno con tiempo medido | Gobierno | Medición y línea base |
| Un control aparece dos veces | Artefactos | Permisos, atestaciones y aprobaciones |
| Monitoreo y Control sin resultado declarado | Procesos | Cambio, liberación y operación posterior |
| En las siete herramientas no aparece la ingeniería | Tecnología | Cadena de integración y despliegue, y Calidad |
| Dos meses para liberar presupuesto ya decidido | Gobierno | Portafolio y fondeo |

---

## Qué enciende cada salto

El nivel uno es lo que va en la lámina. Esta tabla es la que lo sostiene por debajo.

| Salto | Componentes que enciende | Subcomponentes que toca |
|---|---|---|
| Uno, Medir | Gobierno y Artefactos | Medición y línea base; Riesgo, cumplimiento y regulación; Permisos, atestaciones y aprobaciones |
| Dos, Probar | Procesos, Tecnología, Talento y **Artefactos** | Flujo de entrega; Traspasos y esperas; Ambientes y datos de prueba; Cadena de integración y despliegue; Calidad; Forma y tamaño del equipo; Roles y pirámide; **Especificación y requerimientos** |
| Tres, Enrutar | Gobierno, Artefactos y Procesos | Compuertas y criterio de aprobación; Evidencia de cumplimiento; Traspasos y esperas |

El encendido parcial es el argumento, no decoración. El salto uno no toca plantilla ni herramientas, y por eso es barato. El salto dos no toca ningún control, y por eso es aprobable en un banco regulado.

---

## Spec-Driven Development, y dónde entra

Lectura completa en [`../palancas/pov-sdd-speckit.md`](../palancas/pov-sdd-speckit.md), contrastada contra fuente primaria.

Es un cambio de estado de dos subcomponentes que ya existen, no un componente nuevo. En Artefactos, la especificación pasa de documento pasivo a plano de control. En Gobierno, la constitución es la forma verificable por máquina de la arquitectura y del marco regulatorio.

**Entra en el salto dos y se cobra en el salto tres.** El salto uno no lo ejecuta, pero lo alimenta: separar cuáles controles exige el regulador local y cuáles vienen del grupo es el insumo directo de la constitución. Por eso Artefactos deja de estar apagado en el salto dos.

**Tiene un prerrequisito duro.** No hay Spec-Driven Development sin control de versiones ni cadena de despliegue, y ninguno de los dos aparece en el levantamiento de 2025. Es la razón concreta por la cual Tecnología arranca *en proceso* y por la cual el orden de los saltos no es negociable.

---

## Lo que queda abierto

El portal del desarrollador es el único subcomponente que entra con una decisión comercial detrás. Conviene decidir antes de la sesión si se nombra o si se deja fuera del nivel dos hasta que el banco lo traiga.

La permanencia del equipo aparece en Talento pero su instrumento, el fondeo, vive en Gobierno. Es un cruce deliberado y hay que sostenerlo con la misma frase las dos veces, o se lee como duplicidad.

El levantamiento de 2025 está marcado como no exhaustivo y tiene un año. Toda la columna de estado de este documento hereda esa caducidad.
