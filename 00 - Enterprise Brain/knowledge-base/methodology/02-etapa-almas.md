# Etapa 2 — Almas: Los Módulos Funcionales

> Etapa 2 del Gemelo Cognitivo del Sistema. Metodología Enterprise Brain · Digital Core.
> **Eje de metodología, no de arquitectura.** Esta es la etapa 2 de cuatro del método de extracción y puebla `components.is_soul` de la extensión `SYSTEM`. No es una de las seis capas de la arquitectura; el método completo es el trabajo de la Capa 2 y su producto aterriza en la Capa 3. Ver "Los Dos Ejes del Conocimiento" en `reference-architecture-enterprise-brain.md`.
> Versión 2.0 · 2026-10-05. La v1.0 publicaba el DDL de una tabla de almas que el canon no tiene; ver la nota al final.

## Objetivo

Identificar los "personajes" del sistema, es decir los módulos funcionales con identidad propia que son actores reconocibles en el dominio de negocio, no simplemente conjuntos de código técnico.

## Qué es un Alma

Un alma es un módulo funcional que:

- Tiene **identidad propia**: puede describirse en una oración de negocio sin mencionar tecnología.
- Tiene **cohesión interna**: sus componentes trabajan juntos para una capability específica.
- Tiene **frontera reconocible**: el equipo de negocio reconoce "eso es el motor de scoring" o "ese es el módulo de pagos".

No toda agrupación técnica es un alma. Un schema de base de datos no es un alma. Un conjunto de componentes de utilidad compartidos no es un alma. Un grupo que implementa una capability de negocio reconocible sí lo es.

## Cómo se identifican las almas

1. **Fan_in y fan_out**: componentes con alto `fan_in`, es decir muchos llamadores, son candidatos a ser el núcleo de un alma. Son los concentradores del sistema.
2. **Clustering por co-llamada**: grupos que siempre se invocan juntos en los journeys forman un alma.
3. **Patrones de nombre**: prefijos o sufijos compartidos revelan cohesión intencional del equipo original.
4. **Dominio de datos**: componentes que operan principalmente sobre las mismas entidades forman un alma. La matriz CRUD de `component_data` lo hace medible.
5. **Puntos de entrada de orquestación**: las marcas `CTM_ENTRY` y `CTM_HINT` delimitan almas batch, porque el orquestador sabe cuál es la entrada al módulo. Esas marcas son de alta confianza y no se sobreescriben (Regla P3).

## Estructura en brain.db

**El alma no es una tabla: es una propiedad de un componente.** Lo decidió ADR-EB-006 al destilar el canon de la evidencia, porque ninguno de los 16 brains del estate modelaba las almas como tabla aparte y el más maduro ya las llevaba como columna.

| Campo en `components` | Qué guarda |
|-----------------------|-----------|
| `is_soul` | 1 si el componente es el núcleo de un alma |
| `soul_rank` | Orden de importancia del alma dentro del sistema |
| `archetype` | El tipo de alma: motor, orquestador, validador, pasarela, y demás |
| `display_name` | El bautismo del alma, en el idioma del negocio (Regla B30) |
| `description` | La oración de negocio que la describe |
| `domain` | Dominio de negocio primario |
| `primary_capability` | Capability que implementa, con `id` de `capabilities` |
| `fan_in` y `fan_out` | La evidencia cuantitativa que la identificó |
| `status` | Estado operativo del componente |
| `tier` | Nivel de certeza de la afirmación (Regla B37) |

Los componentes que integran el alma se relacionan con su núcleo por el grafo de llamadas, en `component_calls`. No hay una tabla de pertenencia: el alma es el núcleo más su vecindario en el grafo.

```sql
-- Las almas de un brain, por importancia declarada.
SELECT id, display_name, archetype, domain, primary_capability, fan_in, tier
FROM components
WHERE is_soul = 1
ORDER BY soul_rank;
```

## Bautismo del Alma

El `display_name` del alma se deriva del vocabulario empresarial de la Capa 1. Nunca se usa un nombre técnico de variable o de tabla. Un alma se llama "Motor de Cargos y Abonos", no `cargo_ref` ni `bdisac:sp_abono`.

Esta es la Regla B30 aplicada a la capa de almas: un nombre defectuoso es peor que uno vacío, porque miente sobre lo que el módulo hace y envenena los análisis de impacto.

## Nivel de certeza de un alma

La identificación de un alma es **inferencia, no hecho irrefutable**, y eso determina su nivel (Regla B37):

| Afirmación | Nivel | Por qué |
|-----------|-------|---------|
| El componente existe, y su `fan_in` y `fan_out` | **gold** | Se extrae del código productivo, que es hecho comprobable |
| Que ese componente es el núcleo de un alma | **silver** | Es una inferencia del analista o del DT a partir del grafo |
| El `display_name` de negocio del alma | **silver** | Es síntesis, hasta que el SME de dominio la valide |
| El archetype asignado | **silver** | Ídem |

Las tres afirmaciones silver suben a gold cuando un rol con autoridad sobre el dominio las confirma, y eso queda en `knowledge_lineage` con el validador identificado. El flujo lo opera `dt-human-reviewer`.

## Réplicas sin uso

Los sistemas heredados frecuentemente tienen copias de módulos que nunca se depuraron. Una réplica sin uso existe en el código pero no tiene tráfico de producción, y su funcionalidad está duplicada por un alma activa.

**No se marcan borrándolas ni con un estado terminal**, sino con los dos relojes de la Regla B40. La afirmación de que el componente existe sigue siendo verdad, lo que terminó es su vigencia operativa:

- `valid_from` registra desde cuándo el componente estuvo activo.
- `valid_to` registra cuándo dejó de tener tráfico, con la fecha que diga la evidencia: el último log, la última ejecución de job, la fecha del cambio que lo dejó huérfano.
- Nada se borra. `snapshot(date)` permite reconstruir qué almas estaban vigentes en cualquier fecha anterior.

**Una réplica sin uso que alimenta una decisión de retiro exige nivel gold.** Retirar un componente es una decisión de gate, y la Regla B37 no admite excepción ahí: la ausencia de tráfico debe sostenerse en logs, monitoreo o ejecuciones de jobs, que son hechos irrefutables, y no en la impresión de que nadie lo usa. Un `Retire` sobre evidencia silver es exactamente el tipo de decisión que el brain existe para evitar.

## Quién construye y quién responde

| Rol | Responsabilidad |
|-----|-----------------|
| DT de dimensión de cada brain, típicamente `dt-almas` | Extrae y propone las almas desde el grafo de llamadas |
| `dt-asset-configuration-manager` | Dueño de `components` y `component_calls`: responde por la estructura y la semántica (Regla B41) |
| `dt-operations-owner` | Responde por el sentido de negocio del alma dentro de su dominio L1 |
| `dt-knowledge-manager` | Responde por el nivel y el linaje de cada afirmación |
| `dt-human-reviewer` | Consigue que el SME de dominio valide el bautismo y el archetype |

## Instancias de referencia

- **BanCoppel Informix**: 11 almas sobre los dominios D01 a D16, con 16 instancias, de las cuales 5 son réplicas sin uso. Ejemplos activos: Motor de Cargos y Abonos como concentrador de D01, Procesador SPEI en D08, y Motor de Scoring Crediticio. Las 5 réplicas son candidatas a retiro en el assessment 7R, sujetas al nivel gold que exige esa decisión.
- **BanCoppel AppMóvil**: almas de canales digitales, como Autenticación de Sesión, Transacciones Móviles y Consulta de Saldo.

---

## Nota de cambios respecto a la v1.0

La v1.0 publicaba un bloque de DDL que declaraba una tabla de almas, con campos para el componente central, el conteo, la capability y las réplicas. Ninguna de esas columnas existe en el canon, y la tabla tampoco: `templates/schema.sql` declara explícitamente que `is_soul` es una columna de `components` y no una tabla, porque así lo resolvió ADR-EB-006 al destilar el canon de los 16 brains del estate.

Era la última referencia viva a esa tabla en toda la metodología, y el QA del 2026-10-05 la detectó. Un documento de metodología que publica DDL inexistente es particularmente dañino: alguien lo copia para arrancar un brain nuevo y construye sobre una estructura que ningún validador reconoce.

Los otros cambios de esta versión: `etb_l3` pasó a ser `primary_capability` con referencia a `capabilities`; el mecanismo de réplicas sin uso pasó de un estado terminal a los dos relojes de B40; y se agregaron el nivel de certeza por tipo de afirmación (B37) y la tabla de responsabilidades por DT (B41), que no existían cuando se escribió la v1.0.
