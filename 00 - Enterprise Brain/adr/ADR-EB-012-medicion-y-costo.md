# ADR-EB-012 — Medición en el tiempo y costo: el tercer fundamento del CORE

> Estado: **APROBADO** · Propuesto: 2026-10-05 · Aprobado: 2026-10-05 · Asset: Enterprise Brain · Digital Core
> Agrega un tercer fundamento al CORE. Extiende ADR-EB-006, ADR-EB-009 y ADR-EB-011.


<!-- PROPAGACION
templates/schema.sql :: CREATE TABLE IF NOT EXISTS measurements
templates/schema.sql :: CREATE TABLE IF NOT EXISTS costs
dt/dt-demand-manager/CLAUDE.md :: `costs`
-->

---

## Contexto

El canon llegó a 45 reglas y 38 tablas sin poder responder dos preguntas que sus propias reglas exigen.

**La primera es el tiempo medido.** `kpis` y `slos` guardan un `target` y un `current`: un solo valor, el último. No hay serie histórica en ninguna de las 38 tablas. El brain puede decir cuánto vale un KPI hoy, pero no cómo llegó ahí ni si la tendencia mejora. Eso choca de frente con la definición canónica del asset, que dice que el brain **anticipa**: anticipar sobre un único punto no es anticipar, es leer un marcador.

Conviene no confundirlo con la bitemporalidad de B40. Esa regla dice desde cuándo una **afirmación** fue verdad en la empresa; una serie de medición dice cómo evolucionó un **valor**. Son ejes distintos y ambos necesarios: B40 permite responder qué sabíamos en marzo, y la serie permite responder cuánto valía la métrica en marzo.

**La segunda es el costo.** No hay una sola tabla ni una sola columna de costo en las 38. La cadena de valor de B27 va de productos a datos pasando por infraestructura, y se detiene justo antes del dinero. Dos reglas lo piden y nada lo guarda: B43 declara el costo como uno de sus cinco ejes de medición, y B41 asigna a `dt-demand-manager` el proceso 36 del modelo operativo, que es la gestión financiera de la tecnología.

### El punto ciego del método

El canon se destila de la evidencia del estate y nunca inventa (ADR-EB-006). Esa disciplina es lo que lo hace confiable, y hay que conservarla. Pero tiene un punto ciego estructural: **solo puede canonizar lo que alguien ya construyó**.

Ningún brain del estate modela costos ni series de medición. Con el criterio de destilación puro, el canon nunca los tendría, no porque no hagan falta sino porque nadie los implementó todavía. El método protege contra la invención y al mismo tiempo encierra al canon dentro de lo que el equipo ya imaginó.

ADR-EB-011 ya había abierto una puerta parcial al añadir la implicación del roster como segundo fundamento. Falta reconocer el caso en que **una regla del canon exige una capacidad que el esquema no puede sostener**.

---

## Decisión

### 1. Tercer fundamento del CORE: la exigencia de una regla

Una tabla entra al CORE por una de tres vías, y cada tabla declara cuál la sostiene:

| Fundamento | Criterio | Origen | Tablas |
|-----------|----------|--------|--------|
| **Destilación** | Existe en 3 o más brains independientes | ADR-EB-006 | La mayoría del CORE |
| **Implicación del roster** | Un DT canónico obligatorio la posee | ADR-EB-011 | `suppliers` |
| **Exigencia de regla** | Una regla vigente exige una capacidad que ninguna tabla sostiene | **este ADR** | `measurements`, `costs` |

El tercer fundamento es **más estrecho de lo que parece, y deliberadamente incómodo de usar**. Exige tres condiciones simultáneas:

- La regla que lo invoca ya está aprobada en el canon, no se escribe junto con la tabla.
- Ninguna tabla existente puede sostener la capacidad, ni siquiera forzándola.
- El ADR nombra la regla y la frase exacta que queda incumplida sin la tabla.

Sin las tres, la vía correcta sigue siendo esperar a que la evidencia aparezca. Este fundamento existe para cerrar la brecha entre lo que el canon promete y lo que su esquema puede cumplir, no para añadir tablas que parezcan buena idea.

### 2. `measurements` en el CORE

Una serie de medición genérica, aplicable a cualquier entidad que se mida.

Regla que la exige: **B43**, *"El brain se mide en cinco ejes: uso, costo, desempeño, frescura y trazabilidad de decisión"*, y la definición canónica, *"explica, anticipa y aconseja"*.

Es genérica a propósito: una sola tabla sirve para KPIs de negocio, SLOs de servicio, capacidad de infraestructura y uso del propio brain. Crear una tabla por tipo de métrica habría multiplicado el esquema sin añadir semántica, porque lo que cambia entre ellas es la entidad medida, no la estructura de la medición.

`kpis.current` y `slos.current` **se conservan** como el valor vigente, que es lo que casi toda consulta necesita. `measurements` guarda la serie. Duplicar el último valor es deliberado: evita que cada lectura simple tenga que ordenar una serie.

### 3. `costs` en el CORE

El costo de la tecnología del cliente, atribuible a lo que la cadena de valor ya modela.

Regla que la exige: **B43**, que nombra el costo como eje, y **B41**, que asigna a `dt-demand-manager` el proceso 36 del modelo operativo.

**Frontera explícita con el territorio comercial.** Esta tabla guarda lo que al cliente le cuesta operar su tecnología: licencias, nube, infraestructura, soporte. **No guarda precios, tarifas por hora ni cifras de propuesta.** Todo lo comercial sigue siendo territorio de `Pricing & Commercial Modeler` en `Solutioning/`, como ya declara el `CLAUDE.md` del asset y repiten tres DTs en sus anti-patrones. Un brain que empiece a guardar tarifas de Accenture cruzó una frontera que no le corresponde.

### 4. Nivel de certeza de una medición

Por B37, una medición que viene de monitoreo, de la ejecución de un job o de un reporte firmado es **gold por origen**: es un hecho observado. Una estimación, una proyección o un prorrateo es **silver**, porque depende del método con que se calculó. `costs.allocation_basis` existe para que esa diferencia sea auditable: un costo directo y uno prorrateado no valen lo mismo para decidir.

---

## Consecuencias

- **El CORE pasa de 15 a 17 tablas.** Deben actualizarse la Regla B15, el encabezado de `templates/schema.sql`, la dimensión D1 del Brain Auditor y las constantes de `validate.py`.
- **Las dos nacen sin evidencia en el estate**, y eso queda declarado, no escondido. Es el primer uso del tercer fundamento y conviene que se note.
- **Dueños**: `measurements` es de `dt-demand-manager` en su dimensión de negocio y `dt-service-operations-lead` en la de servicio, con el mismo patrón de propiedad compartida por columna que ya usa `slos`. `costs` es de `dt-demand-manager`.
- **`dt-demand-manager` gana el soporte que le faltaba.** B41 le asignaba el proceso 36 sin darle ninguna tabla donde registrarlo.
- **Habilita tres casos de uso de B38 que hoy no tienen piso**: pronóstico de capacidad, costo de TI por producto y KPI, y tendencia de SLO contra su compromiso.
- **No se agregan incidentes, pruebas ni ambientes**, aunque el análisis los identificó como huecos. Esperan evidencia o una regla que los exija: el tercer fundamento no es una invitación a modelar todo lo que falte.

## Alternativas consideradas y rechazadas

**Guardar la serie en `kpis` y `slos` con columnas por periodo.** Rechazada: no escala, obliga a cambiar el esquema cada vez que cambia la ventana, y no sirve para entidades que hoy no tienen columnas de medición.

**Una tabla de métricas por cada tipo de entidad.** Rechazada: lo que varía entre un KPI de negocio y una métrica de capacidad es la entidad medida, no la estructura de la medición.

**Esperar a que un brain del estate implemente costos.** Rechazada porque es exactamente el punto ciego que este ADR documenta: el canon ya promete medir costo en B43, y una promesa que el esquema no puede cumplir es la clase de deshonestidad que el QA encontró seis veces.

**Modelar el costo con el detalle de una herramienta de FinOps.** Rechazada: el brain no sustituye a la herramienta dedicada (B38). Guarda la atribución a la cadena de valor y la referencia al sistema de registro, no el detalle de facturación.
