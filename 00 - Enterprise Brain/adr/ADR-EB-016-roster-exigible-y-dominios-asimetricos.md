# ADR-EB-016 — Qué exige B41 realmente, y qué hacer con un dominio que solo existe en una industria

> Estado: **APROBADO** · Propuesto: 2026-11-03 · Aprobado: 2026-11-03 · Asset: Enterprise Brain · Digital Core
> Reformula la exigencia de la Regla B41. Cierra la pregunta abierta de `dt-sustainability-owner`.

<!-- PROPAGACION
canon/brain-rules.md :: roster exigible
canon/brain-rules.md :: DTs de dimensión
dt/dt-sustainability-owner/CLAUDE.md :: ADR-EB-016
dt/cobertura-dt.md :: roster exigible
-->

---

## Contexto

La Regla B41 dice que **todo brain implementa los 24 DTs canónicos**. La auditoría de noviembre de 2026 midió el cumplimiento en los ocho clientes del estate y el resultado fue inequívoco: se instancian 44 nombres distintos de Digital Twin y la intersección con el roster canónico es **vacía**. Ni un solo brain implementa ni uno solo de los 24. Tampoco hay una sola mención de B41 ni de `ADR-EB-011` en todo el árbol de brains.

Esto admite dos lecturas y hay que elegir una, porque hoy conviven y se estorban.

La primera es que la flota incumple el canon y los ocho brains deberían reprobar. La segunda es que la regla está mal formulada: los 44 nombres que la flota usa no son desviaciones, son **DTs de dimensión**, cada uno especializado en una materia del sistema concreto, y responden a una necesidad que el roster canónico no cubre. `dt-spei`, `dt-autorizador-pagos`, `dt-catalogo-errores` o `dt-java-analysis` no son versiones mal nombradas de ningún rol canónico: son otra cosa.

El propio `ADR-EB-011` ya lo había anticipado al declarar que los DTs de dimensión que ya existen no se sustituyen. Lo que nunca se hizo fue llevar esa excepción al enunciado de la regla, que siguió diciendo "todo brain implementa los 24".

### La pregunta abierta que arrastra `dt-sustainability-owner`

Ese DT declara en su propio cuerpo una asimetría y pide resolverla por ADR: el dominio tiene un L1 propio en banca (6 Responsible Business, con dos L2 y siete capacidades), aparece degradado a capacidad L3 en retail (7.3.5 dentro de Corporate Services) y **no existe en absoluto** en seguros, ni en ACORD ni en los ETB de ramo. La pregunta que formula es si el dominio es canónico para todo brain o si es una particularidad bancaria que el roster generaliza de más.

Las dos cosas son el mismo problema: qué significa que algo sea canónico cuando la realidad de abajo no lo refleja.

---

## Decisión

### 1. B41 exige roles, no nombres de carpeta

La regla se reformula. Lo exigible no es que existan 24 carpetas con nombres canónicos, sino que **ninguna de las 24 responsabilidades quede sin dueño declarado**. Un brain cumple B41 cuando, para cada uno de los 24 roles, existe un DT que lo asume, con el nombre que ese brain use.

La diferencia es práctica y no retórica. Bajo la formulación vieja, los ocho brains del estate reprueban y la regla es letra muerta. Bajo la nueva, lo que se audita es cobertura de responsabilidad, que es lo que la regla quería decir desde el principio y es lo que de verdad importa: un brain sin nadie que responda por la calidad del conocimiento tiene un problema real, se llame como se llame quien lo asuma.

### 2. Dos poblaciones de DT, con exigencias distintas

| Población | Qué es | Exigencia |
|---|---|---|
| **Roster exigible** | Los 24 roles canónicos de B41 | Cobertura completa: ninguna responsabilidad huérfana |
| **DTs de dimensión** | Especialistas en una materia del sistema concreto | Libres. Cada brain instancia los que su materia pida |

Los 44 nombres que la flota usa hoy caen casi todos en la segunda población y dejan de ser desviación. Lo que sí es hallazgo es la responsabilidad sin dueño.

### 3. Un dominio asimétrico se conserva y se declara

`dt-sustainability-owner` **se mantiene en el roster**. El criterio para conservar un dominio que no existe en todas las industrias no es su presencia en los catálogos sino si la responsabilidad existe en el negocio real, y en seguros y retail existe aunque el catálogo no la nombre: hay obligaciones de reporte, de inclusión y de gobierno ambiental que alguien responde.

La condición es que la asimetría se declare, que es lo que ese DT ya hace. **Un dominio sin equivalente en un catálogo no se elimina del roster: se instancia declarando el hueco.** Eliminarlo haría que la responsabilidad desapareciera del brain justo en las industrias donde el catálogo no ayuda a verla, que es donde más falta hace.

Esto generaliza más allá de sostenibilidad y aplica a cualquier dominio futuro en la misma situación.

---

## Consecuencias

**Lo que se gana.** B41 pasa de ser incumplible a ser auditable. La dimensión de roster que `ADR-EB-011` pedía y nunca se implementó ahora tiene algo que medir: no la existencia de 24 carpetas, sino 24 responsabilidades con dueño.

**Lo que cuesta.** Cada brain tiene que declarar su mapeo de rol a DT propio, que es trabajo que hoy no hace ninguno. Mientras no lo haga, su cobertura de B41 es desconocida y no cero, y esa distinción importa: desconocido es un hueco declarable, cero es un juicio que la evidencia no sostiene.

**Lo que no cambia.** El roster de 24 sigue siendo el catálogo de responsabilidades y sigue creciendo por ADR. Lo que cambia es qué se le exige a un brain concreto.

---

## Alternativas consideradas y rechazadas

**Exigir los 24 nombres literales en todo brain.** Es lo que dice la regla hoy. Se rechaza porque la evidencia es contundente: cero de ocho, tres meses después de aprobada. Una regla que nadie cumple y que nadie citó nunca no está siendo incumplida, está mal escrita.

**Bajar B41 a recomendación.** Se rechaza porque el problema que la originó es real: sin roster, nadie responde por la calidad del conocimiento ni por el linaje, y eso sí se vio en el estate.

**Eliminar `dt-sustainability-owner` del roster por falta de evidencia cross-industria.** Se rechaza porque confunde ausencia en el catálogo con ausencia en el negocio. Los catálogos de seguros son de 2023 y anteriores al endurecimiento regulatorio de ESG; modelar el roster sobre esa foto lo deja viejo por diseño.

**Crear una categoría D para los DTs de dimensión.** Se rechaza porque no son canónicos y por tanto no pertenecen al roster. Darles categoría los volvería enumerables, y su número depende de cada sistema.

---

*ADR canónico del asset Enterprise Brain · Digital Core · Accenture México*
