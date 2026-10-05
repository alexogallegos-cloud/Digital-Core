# Capa 1 — Lenguaje: El Vocabulario Empresarial

> Capa 1 del Gemelo Cognitivo del Sistema. Metodología Enterprise Brain · Digital Core.

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

```sql
CREATE TABLE vocabulary (
    id TEXT PRIMARY KEY,          -- slug: "linea-credito"
    term TEXT NOT NULL,           -- "línea de crédito"
    definition TEXT,              -- definición operacional
    scope TEXT,                   -- "enterprise" | "system" | "domain"
    domain TEXT,                  -- dominio de negocio donde aplica
    maturity TEXT,                -- "confirmed" | "proposed" | "deprecated"
    source_system TEXT,           -- sistema de origen
    est TEXT,                     -- "resolved" | NULL (si hubo conflicto V2)
    related_terms TEXT            -- JSON array de IDs de términos relacionados
);
CREATE VIRTUAL TABLE vocabulary_fts USING fts5(id, term, definition);
```

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
