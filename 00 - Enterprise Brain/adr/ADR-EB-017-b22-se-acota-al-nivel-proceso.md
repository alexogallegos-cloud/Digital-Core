# ADR-EB-017 — Qué conocimiento ata a un proceso, y qué conocimiento está por encima de los procesos

> Estado: **APROBADO** · Propuesto: 2026-11-03 · Aprobado: 2026-11-03 · Asset: Enterprise Brain · Digital Core
> Acota la Regla B22 y la dimensión D7. Cierra la decisión que `ADR-EB-015` dejó declarada.

<!-- PROPAGACION
canon/brain-rules.md :: ADR-EB-017
canon/brain-rules.md :: nivel empresa
dt/dt-brain-auditor/validate.py :: EXENTOS_POR_NIVEL
dt/dt-brain-auditor/test-validate.py :: nivel empresa no cuenta como huérfano
dt/dt-brain-auditor/CLAUDE.md :: nivel empresa
-->

---

## Contexto

La Regla B22 dice que todo conocimiento del brain ata a un proceso de negocio, y la dimensión D7 del Brain Auditor lo mide contando filas con `process_id` nulo. Es hallazgo bloqueante: un brain no se activa con conocimiento huérfano.

La regla se escribió cuando todo el conocimiento del brain entraba por el sistema. El vocabulario salía de nombres de stored procedures, las reglas de las condiciones del código, los journeys de la secuencia de operaciones. Todo eso pertenece a un proceso, y preguntarle a qué proceso pertenece siempre tiene respuesta.

`ADR-EB-015` introdujo la Etapa 0, que entra por otro lado. Al correrla por primera vez de punta a punta contra un documento real, el auditor reprobó: diecinueve filas sin `process_id`, diez de `measurements` y nueve de `knowledge_gaps`.

No es un defecto de la extracción. **Los ingresos totales de una empresa no pertenecen a un proceso de negocio.** Tampoco su año de fundación, ni un hueco sobre quién es la compañía, ni la ausencia de una fuente. Son afirmaciones sobre la empresa como un todo, un nivel por encima de sus operaciones.

Hoy el brain solo puede hacer dos cosas con ellas, y las dos son malas: dejarlas huérfanas y reprobar para siempre, o inventarles un proceso que no les corresponde para que el auditor calle.

---

## Decisión

### 1. B22 exige proceso al conocimiento de nivel proceso

La regla se acota. Lo exigible es que **todo conocimiento que pertenece a un proceso declare cuál**. El conocimiento de nivel empresa, el que describe a la compañía como un todo y no a una de sus operaciones, no tiene proceso al que atar, y **declararle uno falso es peor que dejarlo sin él**: contamina las consultas por proceso con filas que no son de ningún proceso, y lo hace de forma indistinguible de las que sí lo son.

La intención original de B22 queda intacta. Una regla de negocio que no ata a un proceso sigue siendo un hallazgo, porque no se sabe a quién afecta si cambia. Un riesgo sin proceso sigue sin decir qué operación pone en peligro. Eso no cambia.

### 2. La excepción se reconoce por el ancla, nunca por la ausencia del dato

Esta es la parte que hace que la excepción no sea una puerta trasera. Una fila no queda exenta porque le falte `process_id`: queda exenta porque **declara positivamente que su ancla es la empresa**.

| Tabla | Qué la vuelve de nivel empresa |
|---|---|
| `measurements` | `entity_table = 'company_profile'` |
| `costs` | `entity_table = 'company_profile'` |
| `knowledge_gaps` | `gap_type = 'source'`, o `domain` en (`identidad`, `fuentes`) |

Si el criterio fuera "no tiene proceso, entonces está exento", cualquier cargador descuidado lavaría su conocimiento huérfano con solo omitir el campo, y D7 dejaría de poder dar negativo. Con el ancla positiva, una regla sin proceso sigue siendo hallazgo y una medición de la empresa no lo es, y las dos cosas se distinguen leyendo la fila.

### 3. Lo exento se cuenta y se reporta

D7 reporta cuántas filas quedaron fuera por nivel. Una excepción que no se ve es una excepción que crece sola: si un día ese número se dispara, alguien tiene que poder notarlo sin leer el código del validador.

---

## Consecuencias

**Lo que se gana.** La Etapa 0 puede ejecutarse y el brain activarse. Un brain que estudió a su cliente deja de reprobar por haberlo estudiado.

**Lo que cuesta.** B22 deja de ser una frase de una línea y pasa a tener una excepción cerrada que hay que conocer. Se acepta porque la alternativa es peor: una regla que obliga a mentir para cumplirla se cumple mintiendo.

**Lo que no cambia.** D7 sigue siendo bloqueante y sigue pudiendo dar negativo. Una fila de `rules`, `vocabulary`, `risks` o cualquier otra tabla de nivel proceso sin `process_id` reprueba igual que antes.

---

## Alternativas consideradas y rechazadas

**Declarar un proceso canónico de nivel empresa y atar la Etapa 0 a él.** No toca B22 y D7 pasa sin excepciones. Se rechaza porque crea un proceso que no es un proceso: toda consulta por proceso lo encontraría mezclado con los reales, y el brain tendría que explicar en cada respuesta que ese no cuenta. El problema se mueve de sitio en vez de resolverse.

**Dejarlo abierto.** Es honesto y fue el estado entre `ADR-EB-015` y este ADR. Se rechaza como estado permanente porque bloquea la activación de cualquier brain que corra la etapa, y la Etapa 0 es la primera del método.

**Sacar `measurements` y `knowledge_gaps` de las tablas que D7 vigila.** Más simple de implementar. Se rechaza porque tira el caso bueno junto con el malo: una medición de latencia de un proceso sí pertenece a ese proceso, y un hueco sobre una regla de cobranza también. Lo que varía no es la tabla, es la fila.

---

*ADR canónico del asset Enterprise Brain · Digital Core · Accenture México*
