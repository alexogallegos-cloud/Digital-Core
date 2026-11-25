<!--
  Documento: roster y mapa de cobertura de los Digital Twins de SDLC Reinvent
  Proyecto:  03 - SPE/HVM/MM/Banamex/projects/sdlc-reinvent/
  Audiencia: equipo interno de Accenture. No es material de cliente.
  Versión:   v1.0, 29 de octubre de 2026
-->

# El roster de Digital Twins, y qué cubre cada uno

Doce twins. Cada uno responde una pregunta que ningún otro responde, y esa es la única regla que define el roster. Si dos responden la misma pregunta, uno sobra, y la forma de resolverlo es declararlo aquí, no decidirlo en el momento.

El roster se derivó de tres cosas: la taxonomía de cinco componentes que ya está cerrada, el catálogo de ocho palancas y catorce métricas que vive en el brain, y la investigación de mercado de octubre de 2026 que está en `knowledge-base/mercado/innovacion-sdlc-2026.md`. Cada SME heredado se verificó contra el árbol real de `SME/`: treinta y siete rutas distintas, las treinta y siete existen.

---

## Las tres categorías

Los twins no tienen todos el mismo sistema de coordenadas, y confundirlos es lo que deja huecos.

**Categoría A, los cinco componentes del ciclo.** Razonan sobre el ciclo de entrega del banco y su cobertura se mide contra la taxonomía de cinco componentes. Uno por componente, sin excepción y sin añadidos.

**Categoría B, los tres cruces.** Trabajan sobre subcomponentes de dos componentes distintos. Son twins propios y no subcomponentes porque su pregunta no la responde ninguno de los dos componentes que cruzan. **Ninguno de los tres reabre la taxonomía.** Son cinco componentes y siguen siendo cinco.

**Categoría C, los cuatro del programa.** No razonan sobre el ciclo del banco: hacen que la propuesta exista, avance y se sostenga. Su cobertura se mide contra el estado del programa, no contra el ciclo.

---

## El roster

| ID | Twin | Categoría | Componente | Pregunta central |
|---|---|---|---|---|
| DT-01 | Arquitecto de Procesos de Entrega | A | Procesos | ¿Dónde espera el trabajo entre una etapa y la siguiente, y quién lo tiene detenido? |
| DT-02 | Custodio de la Especificación | A | Artefactos | ¿Esta especificación alcanza para que alguien que no estuvo en la conversación construya lo correcto? |
| DT-03 | Ingeniero de Plataforma de Entrega | A | Tecnología | ¿Puede un cambio salir hoy sin que una persona toque el camino? |
| DT-04 | Arquitecto de la Plantilla de Ingeniería | A | Talento | ¿Qué forma tiene el equipo que entrega así, y en qué se parece al que hay? |
| DT-05 | Oficial de Gobierno del Ciclo | A | Gobierno | ¿Quién decide esto, con qué criterio, y por cuánto tiempo vale esa decisión? |
| DT-06 | Enrutador de la Demanda | B | Procesos y Gobierno | ¿Por qué ruta debe entrar este trabajo, y cuánto espera antes de que alguien lo toque? |
| DT-07 | Ingeniero de Línea Base y Telemetría | B | Gobierno y Tecnología | ¿Cuánto tarda hoy un cambio en llegar a producción, y con qué dispersión? |
| DT-08 | Responsable de Aseguramiento Regulatorio | B | Gobierno y Artefactos | ¿El auditor interno y el supervisor aceptan esta evidencia sin que nadie la transcriba? |
| DT-09 | Líder del Método de Ingeniería | C | Transversal | ¿En qué etapa del método está este equipo, y qué le falta para la siguiente? |
| DT-10 | Líder de Adopción | C | Talento y Procesos | ¿Por qué un equipo usaría esto en vez del camino que ya conoce? |
| DT-11 | Dueño del Caso de Valor y el Tiempo de Salida | C | Transversal | ¿Qué podemos comprometer hoy con la evidencia que tenemos, y qué no? |
| DT-12 | Auditor de Evidencia de la Propuesta | C | Sobre lo que escribimos | ¿Esta afirmación tiene fuente, fecha y nivel de confianza declarados? |

---

## Por qué doce, y por qué estos cruces

Los cinco de la categoría A no se discuten: la taxonomía está cerrada y cada componente necesita un dueño.

Los tres cruces se justifican uno por uno, porque cada uno es una decisión que alguien podría cuestionar.

**El Enrutador de la Demanda** existe porque las etapas uno y dos del proceso objetivo de 2025 están nombradas y nunca diseñadas. No tienen diagrama de carriles, ni entregables, ni controles. Es la única parte del ciclo que nadie ha tocado, y es donde vive el único dato propio y reciente que tenemos sobre el tiempo del banco, alrededor de dos meses para liberar un presupuesto ya decidido. Además la literatura de flujo trata el atasco de entrada como una clase de problema con cuerpo de práctica y métrica propia. No es un subcomponente de Procesos porque la mitad de su problema es política de fondeo, que vive en Gobierno.

**El Ingeniero de Línea Base** existe porque la medición es la brecha raíz del programa y porque la pregunta de cuánto tarda hoy un cambio no la responde ni quien diseña el gobierno ni quien construye la cadena. Es un cruce real: el qué se mide es decisión de Gobierno y el de dónde sale el dato es cuestión de Tecnología.

**El Aseguramiento Regulatorio** existe por el hallazgo más incómodo de la investigación de mercado: no se encontró guía de supervisor sobre evidencia de cambio generada automáticamente. Es decir, se puede automatizar impecablemente una evidencia que después nadie acepta. Quien diseña la compuerta no puede ser quien responda por su aceptación externa, porque es juez y parte.

Los cuatro de la categoría C existen porque la propuesta anterior se cayó por razones que no eran del ciclo: método sin datos, un mapa de octubre de 2025 presentado sin refrescar en octubre de 2026, y cifras sin base. Esas fallas necesitan dueño declarado.

---

## Mapa de cobertura, componentes

| Componente | Twin dueño | Twins que lo cruzan |
|---|---|---|
| Procesos | DT-01 | DT-06 entrada, DT-10 conducta |
| Artefactos | DT-02 | DT-08 aceptación de la evidencia |
| Tecnología | DT-03 | DT-07 instrumentación |
| Talento | DT-04 | DT-10 adopción |
| Gobierno | DT-05 | DT-06 fondeo, DT-07 medición, DT-08 aseguramiento |

Gobierno es el componente que más cruces recibe, tres de tres. Es consistente con el expediente: tres de los seis hallazgos caen en Gobierno, y la medición vive dentro de él en el siguiente nivel.

---

## Mapa de cobertura, palancas

| Palanca | Twin dueño |
|---|---|
| PAL-00 Línea base y telemetría del ciclo | DT-07 |
| PAL-01 Triage de dos dimensiones | DT-06 |
| PAL-02 Consolidación de decisiones en cuatro compuertas | DT-05 |
| PAL-03 Mínimos técnicos de integración, pruebas y ambientes | DT-03 |
| PAL-04 Core emulado y datos sintéticos | DT-03 |
| PAL-05 Asistencia de agentes en las etapas del ciclo | DT-09 |
| PAL-06 Monitoreo y control transversal automatizado | DT-07 |
| PAL-07 Catálogo y autoservicio del desarrollador | DT-03 |

Las ocho tienen dueño y ninguna tiene dos. DT-03 concentra tres, que es coherente con que Tecnología sea el componente con más subcomponentes y el único cuyo estado inicial es En proceso.

**Siete de los doce twins no son dueños de ninguna palanca.** No es un defecto del roster: es una lectura del catálogo. Las palancas describen trabajo de ejecución, y donde no hay palanca lo que hay es trabajo de diseño todavía pendiente. Los siete sin palanca son exactamente donde el programa no tiene aún qué ejecutar.

---

## Mapa de cobertura, métricas

| Métrica | Quién responde por medirla | Quién responde por moverla |
|---|---|---|
| M-DES-01 Lead time de punta a punta | DT-07 | DT-01 |
| M-DES-02 Tiempo de espera en compuertas | DT-07 | DT-05 |
| M-DES-03 Predictibilidad | DT-07 | DT-06 |
| M-DES-04 Frecuencia de despliegue | DT-07 | DT-03 |
| M-DES-05 Tasa de fallas en cambios | DT-07 | DT-03 |
| M-CTL-01 Evidencia completa en la compuerta | DT-07 | DT-08 |
| M-CTL-02 Vulnerabilidades críticas en producción | DT-07 | DT-03 |
| M-CTL-03 Tasa de retrabajo | DT-07 | DT-09 |
| M-CTL-04 Excepciones y hallazgos | DT-07 | DT-08 |
| M-ADO-01 Satisfacción | DT-10 | DT-10 |
| M-ADO-02 Uso | DT-10 | DT-03 |
| M-ADO-03 Adopción por el nuevo modelo | DT-10 | DT-06 |
| M-ADO-04 Permanencia | DT-10 | DT-10 |
| M-ADO-05 Compuertas aprobadas a la primera | DT-10 | DT-02 |

Las catorce tienen dueño de medición y dueño de movimiento, y en ningún caso son el mismo twin salvo en las dos de adopción que solo el Líder de Adopción puede mover. Esa separación es deliberada: quien mueve un número no debería ser quien lo mide.

---

## Dos huecos que el roster deja a la vista

**El catálogo de palancas no tiene una para la especificación.** El Custodio de la Especificación no es dueño de ninguna de las ocho. PAL-05 cubre la asistencia de agentes y PAL-04 el core emulado, pero la pieza que hace posible la segunda etapa del método, la especificación que gobierna sobre el plan y el código, no tiene palanca propia. O falta una palanca en el catálogo, o la segunda etapa del método no tiene cómo ejecutarse. Hay que resolverlo antes de que el paquete se presente.

**El catálogo de métricas no mide talento.** El Arquitecto de la Plantilla no responde por ninguna de las catorce. El componente sobre el que el interlocutor ha hablado en público de forma más concreta, menos dependencia de terceros y menos capa de coordinación, es el único sin instrumento. Si la conversación va hacia la pirámide, llegamos sin número.

Los dos huecos se registran aquí y se escalan al brain. Ninguno se rellena inventando una palanca o una métrica que el brain no tiene.

---

## Dónde cae cada hallazgo del expediente

| Hallazgo | Twin que responde |
|---|---|
| El ciclo documentado corre sobre rieles del grupo | DT-08 |
| Veintiún puntos de control, ninguno con tiempo medido | DT-07, y DT-05 para el rediseño |
| Un control aparece dos veces | DT-05 |
| Monitoreo y Control sin resultado declarado | DT-01 |
| En las siete herramientas no aparece la ingeniería | DT-03 |
| Dos meses para liberar presupuesto ya decidido | DT-06 |
| Las etapas uno y dos del diseño de 2025 nunca se diseñaron | DT-06 |
| Ni el as-is ni el to-be enrutan por riesgo, los dos tienen veintiún controles | DT-05 |

---

## Orden de invocación

Para una pregunta que entra al proyecto, el orden es casi siempre el mismo y no es arbitrario.

Primero habla **DT-07**, porque la respuesta a casi todo empieza por si existe el dato. Después habla el twin del componente al que pertenece la pregunta. Si la pregunta toca la entrada del embudo, habla **DT-06** antes que **DT-01**. Si toca evidencia, **DT-08** habla después de **DT-05** y puede vetar. Si la pregunta es sobre el método o sobre agentes, **DT-09** habla antes que cualquier twin de componente, porque decide si la pregunta siquiera aplica a la etapa en la que está el equipo.

Antes de que algo salga del expediente, hablan **DT-11** y **DT-12**, en ese orden: uno decide qué se compromete, el otro verifica que cada afirmación traiga fuente, fecha y nivel de confianza.

---

## Qué le falta a cada twin para pasar a ACTIVE

Los doce están en SCAFFOLD. Pasan a ACTIVE cuando tienen un artefacto propio bajo su control y una verificación registrada.

| Twin | Qué necesita |
|---|---|
| DT-01 | El mapa de las nueve etapas con traspasos y esperas, reconciliando las dos versiones del documento de 2025 |
| DT-02 | La constitución instanciada en forma verificable por máquina |
| DT-03 | Que se cierren las decisiones D-01 y D-02 de toolchain. Hasta entonces está bloqueado por diseño |
| DT-04 | El inventario de equipos de desarrollo por dominio, que es DATO-REQUERIDO del banco |
| DT-05 | El mapeo de los veintiún controles a cuatro compuertas, validado con riesgo y cumplimiento |
| DT-06 | El diseño de las etapas uno y dos, que hoy no existe en ningún documento |
| DT-07 | Acceso de lectura a la telemetría del repositorio y del pipeline. Es la brecha más barata y la que condiciona a todas |
| DT-08 | La respuesta del banco sobre qué forma de evidencia acepta auditoría interna. Conviene pedirla temprano |
| DT-09 | El criterio explícito de paso entre las tres etapas |
| DT-10 | El equipo piloto definido y su diagnóstico de arquetipo |
| DT-11 | La línea base. Sin ella su respuesta a todo es la misma |
| DT-12 | Nada externo. Puede empezar hoy con la tabla de frescura del estudio de innovación, que tiene cuatro bloques en confianza baja |

Nueve de los doce esperan algo del banco o de una decisión conjunta. Tres pueden avanzar hoy: DT-09 con el criterio de paso, DT-12 con la verificación del expediente, y DT-01 con la reconciliación de las dos versiones del proceso, que es trabajo documental que ya tenemos en casa.

---

## Reglas del roster

- Una pregunta, un twin. Si dos la responden, se declara aquí cuál la pierde.
- Un twin no inventa el conocimiento de un SME. Lo declara como consulta concreta al SME identificado.
- Los twins viven en `dt/` en minúsculas. Nunca `DTs/`, `Dts/` ni `digital-twins/`.
- Un twin no rellena un hueco del brain inventando una palanca o una métrica. Lo declara como brecha.
- Ningún twin genera tarifas ni costo hora. Siempre se redirige al modelador de precios.
- Ningún twin escribe nombres de personas ni cargos del cliente. Los interlocutores entran como rol.

---

*Roster creado el 29 de octubre de 2026, derivado de la taxonomía de componentes, del catálogo de palancas y métricas del brain, y de la investigación de mercado de la misma fecha.*
