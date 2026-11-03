# ADR-EB-013 — La consulta como objeto: el lado del consumo entra al esquema

> Estado: **APROBADO** · Propuesto: 2026-10-06 · Aprobado: 2026-10-06 · Asset: Enterprise Brain · Digital Core
> Segundo uso del tercer fundamento del CORE (ADR-EB-012). Da soporte de esquema a las Reglas B45, B42 y B43.


<!-- PROPAGACION
templates/schema.sql :: CREATE TABLE IF NOT EXISTS queries
dt/dt-knowledge-manager/CLAUDE.md :: `queries`
-->

---

## Contexto

El canon gobierna con mucho detalle cómo se construye el conocimiento y casi nada cómo se consume. Hay reglas para el vocabulario, las almas, los journeys, las reglas de negocio, el linaje, los niveles de certeza, la bitemporalidad y el roster de quienes lo construyen. Del otro lado del mostrador, donde alguien pregunta algo y el brain responde, no había nada en el esquema.

Esa asimetría dejó sin piso a tres reglas a la vez, y las tres se aprobaron en las últimas semanas sin que nadie notara que compartían el mismo hueco.

**B42 exige autorizar por propósito.** Dice que el mismo dato se concede para documentar una causa raíz y se niega para comparar desempeño entre proveedores, porque la autorización es del par solicitante y propósito. Pero el propósito solo existe en el momento en que alguien pregunta, y no había ninguna tabla donde ese momento quedara registrado. La propia regla cierra diciendo que una política que vive en un documento y no en el filtro no es política sino intención: sin un objeto consulta, B42 era exactamente eso.

**B43 exige medir el uso.** Es uno de sus cinco ejes. No había nada que contar. El brain podía reportar cuántas reglas tiene y de qué nivel, pero no cuántas veces alguien le preguntó algo, ni qué le preguntaron, ni cuánto tardó en responder.

**B43 también exige trazar la decisión.** Y aquí el hueco era más fino. La tabla `decisions` existía con diez columnas que describen la decisión como artefacto de arquitectura — título, contexto, alternativas, consecuencias, estatus — pero no guardaba el conocimiento que la sostuvo, ni el nivel que ese conocimiento tenía al decidir, ni quién decidió, ni qué pasó después. B37 traza de dónde viene lo que el brain sabe y la decisión traza qué se hizo, pero las dos puntas no se unían.

### Por qué la consulta es el eslabón

Decidir rehospedar una aplicación es la decisión, migrarla es la acción y el mapa de sus dependencias es el conocimiento. Son tres objetos distintos, y el canon ya tenía tablas para el primero y el tercero. Lo que faltaba era el momento en que el tercero se convierte en el primero, y ese momento es una consulta: alguien preguntó algo, el brain respondió con cierta evidencia y cierto nivel de certeza, y de esa respuesta salió una decisión.

Sin ese eslabón, cuando una decisión sale mal no hay forma de saber si el brain la informó mal o si la informó bien y el humano decidió otra cosa. Y esa distinción es la única que permite que el brain corrija su propio razonamiento en lugar de cargar con culpas ajenas.

---

## Decisión

### 1. `queries` entra al CORE

Una tabla para el objeto consulta, con las seis etapas de B45 reflejadas en sus columnas.

Fundamento que la sostiene: el tercero de ADR-EB-012, la exigencia de regla. Se cumplen las tres condiciones:

- Las reglas que la invocan — B42, B43 y B45 — ya están aprobadas y no se escribieron junto con la tabla.
- Ninguna tabla existente puede sostenerla. `knowledge_lineage` registra de dónde viene una afirmación, no quién la pidió ni para qué; `findings` registra lo que el brain descubre por su cuenta, no lo que le preguntan; `signals` es el bus entre brains, no la puerta de entrada de un humano.
- Las frases que quedan incumplidas sin ella están nombradas arriba, una por regla.

**El CORE pasa de 17 a 18 tablas.**

Lo que la tabla guarda y por qué cada cosa:

| Etapa de B45 | Columnas | Regla que lo exige |
|--------------|----------|--------------------|
| Admisión | `requester`, `requester_org`, `purpose`, `asked_at` | B42 — sin propósito no cruza frontera |
| Resolución | `question`, `anchor_table`, `anchor_id` | B35 y B27 — toda pregunta se ancla en la cadena de valor |
| Razonamiento y respuesta | `tier_summary`, `gaps_declared`, `denied_reason` | B37 y B17 — declara su certeza y lo que faltó |
| Registro | `decision_id`, `latency_ms`, `answered_at` | B43 — uso, desempeño y trazabilidad |

`purpose` es `NOT NULL` a propósito. Es el único `NOT NULL` del canon que existe para impedir un uso, no para garantizar una integridad: una consulta sin propósito declarado no se admite, y la restricción vive en el esquema justamente para que no dependa de que el código la recuerde.

`requester` guarda un rol de `stakeholders`, no el nombre de una persona. El brain modela la organización del cliente, no a su gente, y un registro de quién preguntó qué se convierte en un instrumento de vigilancia si guarda nombres.

### 2. `decisions` gana diez columnas

No es una tabla nueva: es la tabla de la extensión PROJECT que B43 necesitaba y no tenía.

Se agrupan en tres cosas. La evidencia que la sostuvo — `knowledge_refs` y `knowledge_tier` — con el nivel **que ese conocimiento tenía al decidir**, no el que tiene hoy. Por B40 el nivel pudo cambiar después, y lo que importa para juzgar una decisión es lo que se sabía en el momento, no lo que se supo luego. La autoría — `decided_by` y `decided_at` — con el rol accountable que B39 ya exige para cualquier acción de nivel A3. Y el resultado — `outcome`, `outcome_kpi_id`, `outcome_measured_at`, `outcome_notes` — más `options_rejected`, que guarda lo descartado y por qué.

`query_id` es la columna que cierra el eslabón: qué consulta motivó la decisión.

### 3. El resultado es lo que vuelve aprendiz al brain

`outcome` es la columna más incómoda del canon y la más importante de este ADR. Si el brain aconsejó algo y el KPI no se movió como se esperaba, esa fila dice que se equivocó.

Es deliberado que quede registrado. Un brain que acumula consejos sin verificar su acierto no mejora, y pierde el derecho a que le crean. El eje de trazabilidad de decisión de B43 reporta la tasa de acierto, y una tasa baja no es una métrica a esconder sino el hallazgo que corrige el razonamiento.

### 4. `knowledge_lineage.exposed_for`

Una columna en la tabla de linaje: con qué propósitos se ha consultado esa afirmación. Es lo que permite auditar B42 por el lado del dato y no solo por el lado de la consulta — poder preguntar qué propósitos han tocado una afirmación sensible, sin recorrer el registro completo de consultas.

### 5. La sensibilidad no se agrega: ya existía

Se evaluó agregar una columna `sensitivity` a `data_entities` para el control de acceso de B42. **Se rechazó**: la tabla ya tiene `classification`, que hace exactamente eso. Lo que se hizo fue anotar en el esquema que esa columna es el mecanismo de B42, porque la columna existía desde ADR-EB-009 sin que nada declarara para qué sirve.

Es el segundo caso en este asset de una columna a punto de duplicarse porque su propósito no estaba escrito. Vale la pena el hábito de anotar el porqué junto al qué.

---

## Consecuencias

- **El CORE pasa de 17 a 18 tablas.** Deben actualizarse la Regla B15, el encabezado de `templates/schema.sql`, la dimensión D1 del Brain Auditor, las constantes de `validate.py`, `quality-gates-enterprise-brain.md` y el mapa de tablas generado.
- **`brain.py` gana el ciclo de consulta**: `abrir_consulta`, `responder` y `registrar_consulta`. Sin ellos la tabla queda vacía y la regla sigue siendo una intención.
- **`autoevaluacion()` se vuelve implementable.** Los cinco ejes de B43 ya tienen de dónde leer: `queries` da uso y desempeño, `costs` da costo, `knowledge_lineage` da frescura vía la latencia bitemporal de B40, y `decisions` da trazabilidad.
- **Dueño de `queries`: `dt-knowledge-manager`**, que ya posee `knowledge_lineage`. El registro de consultas es el lado del consumo del mismo linaje, y tenerlos en el mismo dueño es lo que permite unir de dónde vino una afirmación con quién la pidió.
- **Dueño de la política de B42: `dt-it-risk-manager`.** Ninguno de los veinte DTs declaraba B42 en su `CLAUDE.md`, así que la regla no tenía dueño. Se asigna a `dt-it-risk-manager`, que ya responde por las obligaciones regulatorias y los riesgos, y el control de acceso es de esa naturaleza. La separación importa: `dt-it-risk-manager` define la política, `dt-knowledge-manager` guarda el registro y `dt-brain-auditor` audita que coincidan. Quien fija la política no debe ser el dueño del registro con que se verifica.
- **Los propósitos permitidos por tipo de solicitante son una lista en el código, no en el esquema.** Es una decisión consciente: la frontera de cliente de B42 es absoluta y no debe poder ablandarse con un `UPDATE`.
- **Ningún brain del estate tiene esta tabla.** Como `measurements` y `costs`, nace sin evidencia, y eso queda declarado en lugar de escondido.

## Alternativas consideradas y rechazadas

**Un log de aplicación en vez de una tabla.** Rechazada: un log no se puede unir con `decisions` ni con `knowledge_lineage`, y el valor entero de esta decisión está en esas uniones. Además un log se rota y el canon necesita que el registro sobreviva, sobre todo si el brain se archiva por B44.

**Guardar el propósito en `knowledge_lineage` y nada más.** Rechazada: resuelve la auditoría por el lado del dato pero no da identidad a la consulta, así que no sirve para medir uso, ni para rastrear una decisión hasta la respuesta que la motivó, ni para registrar una consulta que fue **negada** — que es precisamente la que más importa auditar.

**Extender `signals`.** Rechazada: `signals` es el bus entre brains y una consulta tiene otro emisor, otro ciclo y otra razón de existir. Forzarla habría colapsado dos conceptos que el canon mantiene separados a propósito.

**Guardar el nombre de la persona que pregunta.** Rechazada: el brain modela roles, no personas. Un registro con nombres se convierte en un instrumento de vigilancia del equipo del cliente, y ese no es el propósito del asset.

**Dejar `purpose` nullable y validarlo en el código.** Rechazada: B42 dice que la restricción se aplica al consultar y que negado es el estado por defecto. Una restricción que depende de que el código la recuerde es la clase de política que la propia regla descalifica.
