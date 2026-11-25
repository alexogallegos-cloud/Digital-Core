# SDLC Reinvent — Project Agent
# project_type: delivery-lifecycle-transformation
# project_state: scaffold
# proposito: eficiencia del ciclo de vida de entrega de software en todo el banco
# horizon_present: cuatro componentes vivos sin medicion comun y un toolchain en disputa
# horizon_future: ciclo de entrega medido, con compuertas de evidencia automatica y asistencia de agentes gobernada
# replaces_or_complements: complementa projects/laboratorio-aceleracion (INI-04), no lo sustituye

> **Offering**: 03 Software and Platform Engineering
> **Sub-offering**: Frictionless SDLC, variante de lifecycle DevOps clásico aumentado con agentes
> **Origen**: INI-04 del Laboratorio de Aceleración, registrado en el pipeline FY27 como Flujo 2, SDLC no contratado
> **Vehículo contractual**: no existe todavía, ver decisión D-04
> **Brain**: `digital-brain/`, API `SdlcBrain`, federa el brain del laboratorio y el del core por referencia
> **Creado**: 27 de octubre de 2026

---

## QUÉ ES ESTE PROYECTO

SDLC Reinvent gobierna la transformación del ciclo de entrega de software de Banamex. Su único
propósito es la eficiencia de ese ciclo: que un cambio tarde menos en llegar a producción, que
cueste menos llevarlo, que falle menos al llegar y que se recupere antes cuando falla.

El alcance es el banco, no el laboratorio. El Laboratorio de Aceleración es donde el modelo se
incuba y se prueba con productos reales, y ahí vive la implementación de referencia con sus
compuertas G0 a G4. Pero el objetivo del programa es que el modelo salga de ahí, y por eso vive
en su propio proyecto en lugar de quedarse como un workstream del laboratorio.

**La conclusión incómoda que el brain repite en cada consulta**: hoy nadie puede decir cuánto
tarda un cambio en llegar a producción en este banco. No hay línea base de ninguna de las once
métricas medibles del ciclo. Mientras eso siga así, cualquier promesa de eficiencia es una
opinión y el programa está expuesto a que el cliente cancele la inversión al primer tropiezo.

---

## LOS COMPONENTES DEL PROGRAMA

Cinco piezas que ya existen como propuestas o como entregables, y una sexta que no existe y de
la que dependen las demás.

| ID | Componente | Qué aporta al ciclo | Estado |
|---|---|---|---|
| C-01 | Portal de desarrollador | Catálogo, plantillas de arranque y documentación técnica en un solo lugar | Propuesta activa en S1, MVP comprometido al 27 de noviembre de 2026 |
| C-02 | Plataforma de integración y despliegue corporativa | Pipeline estándar y evidencia comparable entre equipos | S1 sin MEDDPICC formal y sin comprador económico identificado |
| C-03 | Gobierno de APIs | Contrato de API versionado y puerta única de entrada | S2B con propuesta v0.1 lista |
| C-04 | Gestión de servicio y del cambio | Normaliza el flujo donde se acumula la espera entre aceptación y despliegue | S2B en solutioning |
| C-05 | SDLC agéntico de referencia | Compuertas G0 a G4 con evidencia automática, incubadas en el laboratorio | Setup en curso bajo el Anexo B |
| C-06 | Línea base y telemetría del ciclo | Mide el ciclo actual de punta a punta | **No iniciado. Es la brecha raíz del programa** |

Los cuatro primeros tienen deal-state propio en `Solutioning/Proposals - Clients/Banamex/`. Este
proyecto no los duplica ni los gobierna comercialmente: los modela como componentes con su
dependencia, su fecha y lo que aportan al ciclo. El pipeline y la economía se leen de su
deal-state, que es la fuente.

---

## LAS OCHO PALANCAS

Cada palanca ataca una fricción concreta y mueve una métrica concreta. Consultables con
`SdlcBrain().palancas()`, y con `que_mueve(metrica)` en el sentido inverso.

PAL-00 es la línea base y la telemetría. No mueve nada por sí sola y es precondición de todas
las demás, porque sin ella ninguna puede acreditar su efecto. Las otras siete son autoservicio y
catálogo, pipeline estándar, compuertas con evidencia automática, core emulado con datos
sintéticos, contrato de API primero, cambio normalizado y asistencia de agentes en desarrollo y
pruebas.

Hoy tres de las ocho están sin bloqueo declarado y cinco esperan línea base o una decisión de
toolchain. Eso no es un defecto del modelo: es el estado real del programa.

---

## LA CONTRADICCIÓN QUE HAY QUE RESOLVER PRIMERO

Dos propuestas vivas del mismo banco asumen cosas distintas sobre el mismo toolchain, y las dos
marcan su supuesto como dato del cliente.

La propuesta del portal de desarrollador asume que el repositorio es GitLab o Bitbucket y que el
motor de integración es Jenkins o Tekton, ambos con etiqueta de dato de cliente confirmado. El
diseño de la plataforma corporativa asume GitHub Enterprise y GitHub Actions. El catálogo y las
plantillas de arranque del portal se enganchan al repositorio real y generan definiciones de
pipeline para el motor real, así que la contradicción no es cosmética: si el banco migra después
del MVP, las plantillas quedan apuntando al stack anterior y hay que rehacerlas.

Esto está registrado como CT-01 y CT-02, ambas de impacto alto, y como decisiones D-01 y D-02
que corresponden al área de ingeniería de plataforma del banco. Es lo primero que hay que llevar
a una mesa técnica, y vale la pena hacerlo antes del 27 de noviembre.

---

## LOS DOCE DIGITAL TWINS

Cada twin responde una pregunta que ningún otro responde. El roster completo, con el mapa de
cobertura por componente, palanca y métrica, está en `dt/cobertura-dt.md`. Consultable con
`SdlcBrain().dts()`, `dt(id)`, `quien_responde(texto)` y `dts_bloqueados()`.

Cinco son de **categoría A**, uno por componente del ciclo: Arquitecto de Procesos de Entrega,
Custodio de la Especificación, Ingeniero de Plataforma de Entrega, Arquitecto de la Plantilla de
Ingeniería y Oficial de Gobierno del Ciclo.

Tres son de **categoría B**, cruces entre dos componentes que ninguno de los dos resuelve solo:
Enrutador de la Demanda, Ingeniero de Línea Base y Telemetría, y Responsable de Aseguramiento
Regulatorio. **Los tres cruces no reabren la taxonomía: los componentes siguen siendo cinco.**

Cuatro son de **categoría C** y no razonan sobre el ciclo del banco sino sobre el programa: Líder
del Método de Ingeniería, Líder de Adopción, Dueño del Caso de Valor y Auditor de Evidencia de la
Propuesta.

Las ocho palancas tienen dueño y ninguna tiene dos. Las catorce métricas tienen dueño de medición
y dueño de movimiento, y salvo en adopción nunca son el mismo twin. **Siete de los doce no son
dueños de ninguna palanca, y ahí es donde el programa todavía tiene diseño pendiente y no
ejecución.** Nueve de los doce esperan un dato del banco o una decisión conjunta; tres pueden
avanzar hoy.

El roster deja dos huecos a la vista que no se rellenan inventando: el catálogo de palancas no
tiene ninguna para la especificación como artefacto que gobierna, y el catálogo de métricas no
mide talento.

---

## RELACIÓN CON EL RESTO DE LA ONTOLOGÍA BANAMEX

| Capa | Ruta | Vínculo con este proyecto |
|---|---|---|
| Run the Bank | `systems/core/unisys/` | El brain del core aporta las reglas extraídas del código, que son la materia prima de los contratos de interfaz del core emulado |
| Run the Bank | `systems/compliance/` | El marco regulatorio condiciona la evidencia de la etapa de seguridad y cumplimiento, y la decisión de alojamiento del modelo |
| Change the Bank | `projects/laboratorio-aceleracion/` | Incuba la implementación de referencia. INI-04 es el origen de este proyecto y sigue siendo su banco de pruebas |
| Change the Bank | `projects/sdlc-reinvent/` | Este proyecto |

El brain del laboratorio y el del core son insumo de consulta, no copia. Las consultas se hacen
en vivo con `lab_*` y `core_*` de la API.

---

## ESTRUCTURA

```
sdlc-reinvent/
├── CLAUDE.md                  este archivo
├── digital-brain/             sdlc-brain.db, API SdlcBrain, federa laboratorio y core
├── dt/                        Digital Twins del proyecto, uno por carpeta
│   └── cobertura-dt.md        roster y mapa de cobertura de los doce
├── generators/                generadores del portal, leen del brain
├── knowledge-base/            un subdirectorio por concern
│   ├── linea-base/            instrumentación, telemetría y método de medición
│   ├── toolchain/             inventario de herramientas y su estado
│   ├── palancas/              desarrollo de cada palanca de eficiencia
│   ├── componentes/           lo que este proyecto necesita de cada componente
│   ├── taxonomia/             los cinco componentes y la matriz contra las tres etapas
│   ├── mercado/               estudio de mercado, perfil del interlocutor e innovación del ciclo
│   ├── referencia/            inventarios y material de consulta
│   └── gobierno/              guardrails, decisiones y vehículo contractual
├── old/                       versiones retiradas
├── portal/                    HTML generado, nunca escrito a mano
└── source/
    ├── contrato/              instrumento contractual cuando exista
    └── docs/                  material del cliente y de las propuestas
```

---

## LO QUE FALTA, EN ORDEN

El brain lo responde con `datos_requeridos()` y `decisiones_abiertas()`. Resumido:

Del banco hacen falta la línea base del ciclo, el inventario de equipos de desarrollo por
dominio, acceso de lectura a la telemetría del repositorio y del pipeline, la política de cambio
con la duración real de su ventana, y los contratos de interfaz del core. De la mesa conjunta
hacen falta el alcance de la transformación, el papel del laboratorio como piloto o como
plataforma, el vehículo contractual, el alojamiento del modelo que asiste el ciclo y el dominio
del piloto. De Accenture hace falta el pricing del portal de desarrollador, que es la única
brecha que impide cerrar esa propuesta y cuya fecha es la más próxima del programa.

---

## REGLAS DE TRABAJO

- La medición va antes que la adopción. No se compromete ningún porcentaje de productividad sin
  línea base y sin piloto cerrado. La función `listo_para_comprometer()` existe para que esa
  conversación se tenga con datos y no con optimismo.
- Lo observado se distingue de lo supuesto. La fricción respaldada por una fuente del expediente
  se marca como observada; la que viene de patrón sectorial se marca como hipótesis y se queda
  ahí hasta que alguien la valide contra el banco.
- Los deal-states de los componentes son la fuente de su estado y su economía. Aquí no se
  reestiman ni se duplican.
- Las tarifas y el costo hora no se generan en este proyecto. Se redirigen al modelador de
  precios.
- Los HTML de `portal/` se generan desde `generators/` leyendo del brain. No se editan a mano.
- Los Digital Twins viven en `dt/` en minúsculas.
- Nada de nombres de personas del cliente ni de cargos, ni en el brain ni en artefactos
  compartibles. Los interlocutores entran como rol.
- El core real está fuera del alcance del laboratorio por contrato. Todo lo que lo toque necesita
  otro vehículo.
- Este entorno no se llama sandbox. Se le dice Laboratorio de Aceleración, Innovation Lab o
  Entorno de Habilitación de Ideas.

---

*Creado el 27 de octubre de 2026, v0.1, derivado de INI-04 y de los deal-states de los cuatro
componentes vivos.*
