# ADR-EB-018 — Del consejo a la acción: el catálogo de acciones y su linaje entran al CORE

> Estado: **APROBADO** · Propuesto: 2026-11-11 · Aprobado: 2026-11-11 · Asset: Enterprise Brain · Digital Core
> Cierra las Reglas B38 y B39. Segundo uso del tercer fundamento del CORE (`ADR-EB-012`). Lleva el CORE de 23 a 25 tablas.

<!-- PROPAGACION
templates/schema.sql :: CREATE TABLE IF NOT EXISTS action_catalog
templates/schema.sql :: CREATE TABLE IF NOT EXISTS actions
templates/brain.py :: def evalua_accion
templates/build-brain.py :: action-catalog-seed.sql
canon/brain-rules.md :: ADR-EB-018
canon/brain-rules.md :: action_catalog
quality-gates-enterprise-brain.md :: never_below_a3
dt/dt-brain-auditor/validate.py :: d11_autonomia
dt/dt-brain-auditor/test-validate.py :: la_semilla_del_asset_pasa
dt/dt-change-manager/CLAUDE.md :: action_catalog
-->

---

## Contexto

B38 y B39 estaban en el canon desde la primera versión y eran las dos últimas reglas que el índice declaraba sin artefacto verificable.

B39 describe cuatro niveles de autonomía y afirma que el nivel **se gana con historial y se pierde con incidentes**. Nada registraba ese historial. No se podía saber después con qué nivel se ejecutó algo, ni quién lo aprobó, ni sobre qué conocimiento se sustentó, así que tampoco se podía ganar autonomía con evidencia ni devolverla tras un incidente. La regla contradecía lo que el propio canon exige en B42: una política que vive en un documento y no en el filtro no es política sino intención.

B38 tenía el mismo problema por otro lado. Dice que **cada caso de uso se ancla a una sub-capacidad ITOM, y no a una lista suelta de ideas**, y los casos de uso vivían exactamente como esa lista suelta: párrafos y tablas de ejemplo dentro del canon, sin identificador, sin dueño y sin forma de preguntarle al brain qué está autorizado a hacer.

El modo de falla que esto habilitaba no es teórico. Un brain que ejecuta sin registro de ejecuciones es un brain al que no se le puede hacer la pregunta que importa después de un incidente: qué hizo, con qué nivel, con qué conocimiento y quién lo autorizó.

---

## Decisión

### 1. Dos tablas al CORE, no una

`action_catalog` es la política: qué tipo de acción está preautorizado y hasta qué nivel. `actions` es el linaje: una fila por ejecución, con su nivel, el conocimiento que la sustentó, quién aprobó y cómo salió.

Son dos objetos distintos y colapsarlos pierde información en los dos sentidos. Un tipo sin ejecuciones es política vigente, no un vacío. Y una ejecución cuyo tipo no está en el catálogo es una acción que nadie autorizó, que no es un silencio sino el hallazgo.

El ingreso usa el **tercer fundamento** de `ADR-EB-012`, con sus tres condiciones:

| Condición | Cómo se cumple |
|---|---|
| La regla ya está aprobada y no se escribe junto con la tabla | B38 y B39 rigen desde el canon v2.0 (2026-09-29), catorce ADRs antes de este |
| Ninguna tabla existente puede sostener la capacidad | `decisions` pertenece a la extensión `project` y registra la decisión, no la ejecución, así que deja fuera a los brains `system` y `enterprise`. `knowledge_lineage` traza el conocimiento, no lo que el brain hizo con él. `signals` registra lo observado, no lo actuado |
| El ADR nombra la frase exacta que queda incumplida | B39, *"se gana con historial y se pierde con incidentes"*, y B38, *"cada caso de uso se ancla a una sub-capacidad ITOM, y no a una lista suelta de ideas"* |

### 2. El nivel lo resuelve un método, no una declaración

La parte que hace que B39 deje de ser intención no es el DDL, es que el nivel se calcule antes de ejecutar. `brain.py` lo resuelve en `evalua_accion()` con tres cortes en orden: sin fila en el catálogo no hay autorización que invocar; A2 y A3 exigen conocimiento gold y con silver o bronze el techo es A1; y A3 sin aprobador declarado no se dispara. La respuesta siempre dice por qué.

`registrar_accion()` consulta ese veredicto **antes** de escribir y se niega si el nivel pedido excede el permitido. Escribir primero y auditar después es justo lo que dejaba la regla sin efecto. `autonomia()` es la vista con la que un tipo sube a A2 por historial limpio o regresa a A3 por incidente.

### 3. La semilla es la lista exigible, no la exhaustiva

`templates/action-catalog-seed.sql` siembra veinte casos de uso repartidos en los seis dominios ITOM. Un brain concreto añade los suyos; lo que no puede es ejecutar una acción que no esté en su catálogo, porque `evalua_accion()` la niega por falta de autorización.

Al instanciar hay dos rebindes, y el Brain Auditor avisa cuando quedan pendientes: `accountable_role` trae el nombre del rol canónico y en un brain real apunta al `id` de `stakeholders` de esa organización; `tool` trae la categoría de herramienta y en un brain real trae el producto que el cliente opera.

### 4. La aprobación permanente se marca en la fila, no se deduce de la lista

Los cuatro tipos que B39 enumera como nunca-bajo-A3 son un **piso y no una lista cerrada**. Lo que manda es el criterio, que son dos razones y no una: o el efecto sobre lo que ya ocurrió no se recupera, o hay consecuencia regulatoria directa. Conviene no colapsarlas en la palabra *irreversible*, porque muchos de estos cambios sí se deshacen — bajar un parámetro se revierte con otro UPDATE. Lo que no se revierte es el tiempo que estuvo vigente, con las operaciones que ocurrieron mientras tanto.

Por eso la marca vive en la columna `never_below_a3` de cada fila y la semilla la usa también en un quinto caso que el canon no enumera, escalar formalmente un hallazgo con consecuencia regulatoria ante el supervisor. La dimensión D11 valida el invariante, que una fila marcada esté en A3, y no la pertenencia a una lista de cuatro nombres. Validar la lista habría dejado fuera al primer caso legítimo que no estuviera en ella.

### 5. Dueño y verificación

Las dos tablas son de `dt-change-manager`, dueño del lado Change del puente calloso (B24) y responsable del gobierno del cambio en producción. La propiedad es sobre la estructura y la semántica, no sobre el contenido (B41).

La **dimensión D11 del Brain Auditor** mide lo que los gates de RELEASE declaran bloqueante: ninguna ejecución en A2 o A3 sin conocimiento gold, ninguna A3 sin aprobador, ninguna ejecución que invoque un tipo fuera del catálogo, ningún tipo de aprobación permanente degradado, ningún caso de uso sin ancla ITOM y ningún tipo que reescriba el registro de otra herramienta por debajo de A3. Lo que no reprueba es el catálogo vacío: un brain en DISCOVER todavía no ejecuta nada y exigirle casos sembrados sería reprobarlo por estar empezando.

---

## Lo que esta decisión todavía no modela

La **anatomía de un caso de uso** de B38 declara ocho cosas. El catálogo modela cinco: el dominio ITOM que potencia, la herramienta que recibe el artefacto, el rol accountable, la descripción y el nivel. Quedan fuera cuatro, y hoy viven en la prosa de cada descripción:

| Lo que B38 pide | Dónde está hoy |
|---|---|
| El DT que lo ejecuta (B29) | Implícito en el rol accountable, no declarado |
| El eslabón de la cadena de valor que lo ancla (B27) | No está |
| El nivel con que sale el artefacto, normalmente silver (B37) | En la descripción, en prosa |
| El KPI que mueve | No está, y es el que B38 llama la medida de que el caso escala |

Se declara como hueco abierto y no como cerrado. Cerrarlo pide columnas nuevas en `action_catalog`, y eso es otra decisión: las dos primeras son derivables dentro del asset, pero el eslabón y el KPI son del cliente, así que en la semilla quedarían nulas y el auditor solo podría avisar. Mientras tanto, la afirmación honesta es que B38 tiene artefacto para su mapa ITOM y para su frontera con las herramientas dedicadas, y que su anatomía completa está a medio modelar.

---

## Consecuencias

**Lo que se gana.** Las dos últimas reglas sin artefacto quedan con artefacto, y con uno que puede dar negativo. El índice del canon deja de prometer lo que su esquema no cumple, que es el modo de falla que este asset persigue desde `ADR-EB-012`. Un brain que ejecuta puede ser auditado después.

**Lo que cuesta.** Dos tablas que ningún brain del estate implementa hoy. Es el segundo uso del tercer fundamento y conviene que se note: entran por regla aprobada y no por evidencia destilada, y el día que un brain real las use dirá si el modelo aguanta.

**Lo que cambia en el build.** `actions` y `action_catalog` se preservan entre reconstrucciones, igual que `queries`. El contenido de las dos no se puede reconstruir desde el código fuente: una ejecución ocurrió y un rebinde de roles lo hizo una persona. Un rebuild que las borrara destruiría justo la evidencia con la que se gana o se pierde autonomía.

**Lo que no cambia.** El brain sigue sin sustituir a las herramientas dedicadas. `creates_only` deja explícito que la regla general es crear por la puerta de entrada de la herramienta, y las filas que sí modifican el registro que otra custodia como verdad están en A3 con dueño humano.

---

## Alternativas consideradas y rechazadas

**Una sola tabla de ejecuciones con el nivel en cada fila.** Más simple y suficiente para auditar el pasado. Se rechaza porque la política quedaría repetida en cada ejecución y no habría dónde declarar un tipo preautorizado que todavía no se ejecutó, que es la mitad del valor: el catálogo es lo que el brain puede hacer, no solo lo que hizo.

**Reutilizar `decisions`.** Evita tablas nuevas. Se rechaza porque `decisions` vive en la extensión `project`, así que los brains `system` y `enterprise` se quedarían sin lugar donde registrar, y porque una decisión y una ejecución no son el mismo objeto: entre una y otra está precisamente el nivel de autonomía que B39 gobierna.

**Dejar el catálogo en prosa dentro del canon.** Es el estado que trajo este ADR. Se rechaza porque es el que B38 contradice con todas sus letras.

**Hacer el catálogo exhaustivo desde el asset.** Se rechaza por imposible de mantener y por falso: los casos de uso de un cliente dependen de sus herramientas y de su operación. La semilla es el piso exigible y cada brain crece sobre ella.

---

*ADR canónico del asset Enterprise Brain · Digital Core · Accenture México*
