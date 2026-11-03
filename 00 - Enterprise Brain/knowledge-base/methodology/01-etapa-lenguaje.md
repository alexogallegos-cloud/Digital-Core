# Etapa 1 — Lenguaje: El Vocabulario Empresarial

> Etapa 1 del Gemelo Cognitivo del Sistema. Metodología Enterprise Brain · Digital Core.
> **Eje de metodología, no de arquitectura.** Esta es la etapa 1 de cinco del método de extracción y puebla `vocabulary` de la extensión `SYSTEM`. No es una de las seis capas de la arquitectura; el método completo es el trabajo de la Capa 2 y su producto aterriza en la Capa 3. Ver "Los Dos Ejes del Conocimiento" en `reference-architecture-enterprise-brain.md`.

## Objetivo

Extraer y estructurar el vocabulario nativo del sistema legacy — los términos que el sistema usa para nombrar sus conceptos, procesos, actores y estados — para que todo artefacto posterior (almas, journeys, reglas) hable el mismo idioma de negocio.

## Por qué es la primera capa

El vocabulario es la semilla del conocimiento. Un `business_name` de regla que usa "lincred" (en lugar de "línea de crédito") o "ctemoral" (en lugar de "persona moral") es un nombre que solo entiende quien escribió el código. La Capa 1 traduce el lenguaje de máquina al lenguaje de negocio, y ese lenguaje se propaga a todas las capas posteriores.

## Fuentes de vocabulario

| Fuente | Tipo de señal | Ejemplo |
|--------|---------------|---------|
| Nombres de SPs / programas | Entidades funcionales | `sp_autoriza_credito` → "autorizar crédito" |
| Nombres de tablas y columnas | Entidades de datos | `ctemoral` → "persona moral" |
| Comentarios en código fuente | Contexto semántico | `-- calcula IVA sobre monto bruto` |
| Parámetros de entrada/salida | Flujo de información | `@importe_neto`, `@tasa_anual` |
| Códigos de error | Estados y condiciones | `ERRO-4391` → "crédito cancelado" |
| Mensajes a usuario final | Lenguaje del cliente | "Su saldo disponible es..." |
| Documentación técnica (docs/) | Definiciones oficiales | Manuales, runbooks, especificaciones |

## Estructura en brain.db

El DDL ejecutable vive en [`templates/schema.sql`](../../templates/schema.sql) y es la única fuente de verdad (ADR-EB-006). Este documento no lo transcribe: lo describe.

**Campos de `vocabulary`**

| Campo | Qué guarda |
|-------|-----------|
| `term` | El término tal como lo usa el negocio |
| `definition` | Su significado en el dominio |
| `categoria` | Tipo de término |
| `scope` | Alcance en que aplica |
| `domain` | Dominio de negocio |
| `maturity` | `confirmed`, `proposed` o `deprecated` |
| `source_system` | Sistema del que se extrajo |
| `aliases` | Otras formas de nombrar lo mismo. Reemplaza al `related_terms` que esta guía documentaba y que nunca existió en el canon |
| `est` | `resolved` cuando un conflicto de vocabulario se dirimió (Regla V2) |

Más `tier`, que declara el nivel de certeza de la afirmación (Regla B37), y `process_id`, que la ata a un proceso de negocio (Regla B22).

## Proceso de extracción (canónico)

1. **Mine de señales**: extractor identifica todos los identificadores del código fuente (SPs, tablas, parámetros, comentarios).
2. **Normalización**: camelCase/snake_case/abreviatura → forma canónica legible.
3. **Cruce con vocabulario empresarial** (Regla V1): confirmar / enriquecer / proponer.
4. **Clustering semántico**: agrupar variantes del mismo concepto.
5. **Definición por síntesis LLM**: descripción operacional desde el código fuente.
6. **Carga**: INSERT en `vocabulary` con `maturity='confirmed'` (existentes) o `'proposed'` (nuevos candidatos).

## Regla V1 — Vocabulario Empresarial como Semilla Cross-Sistema

Todo extractor de vocabulario DEBE:

1. Cargar el vocabulario empresarial del bank-brain como capa de referencia antes de procesar el sistema.
2. Cruzar los términos extraídos contra el vocabulario en 3 categorías:
   - **Confirmar**: mismo término, mismo significado — el sistema valida el término empresarial.
   - **Enriquecer**: término existente, contexto nuevo — añadir al `definition` del banco.
   - **Proponer**: término no existe — candidato para la versión N+1 del vocabulario.
3. Nombrar reglas y journeys con términos del vocabulario empresarial — nunca con nombres de variables internas.

## Instancias de referencia

- **BanCoppel Informix**: 634 términos confirmados (Ola A + lincred/aumlincred/consutacat). Vocabulario empresarial en `bank-brain/knowledge-base/vocab/vocab-bancoppel-v{N}.json`.
- **BanCoppel AppMovil**: cruza contra el mismo vocabulario empresarial del banco — términos compartidos se confirman automáticamente.
- **Banamex GemCog**: vocabulario Unisys independiente — pendiente cruce con vocabulario empresarial Banamex (Ola 4).
