# Capa 2 — Almas: Los Módulos Funcionales

> Capa 2 del Gemelo Cognitivo del Sistema. Metodología Enterprise Brain · Digital Core.

## Objetivo

Identificar los "personajes" del sistema — los módulos funcionales con identidad propia que son actores reconocibles en el dominio de negocio, no simplemente conjuntos de código técnico.

## Qué es un Alma

Un alma es un módulo funcional que:

- Tiene **identidad propia** — puede describirse en una oración de negocio sin mencionar tecnología.
- Tiene **cohesión interna** — sus SPs/programas trabajan juntos para una capability específica.
- Tiene **frontera reconocible** — el equipo de negocio reconoce "eso es el motor de scoring" o "ese es el módulo de pagos SPEI".

No toda agrupación técnica es un alma. Un schema de base de datos no es un alma. Un conjunto de SPs de utilidad compartidos no es un alma. Un grupo que implementa una capability de negocio reconocible sí lo es.

## Cómo se identifican las almas

1. **Fan_in / fan_out**: SPs con alto fan_in (muchos llamadores) son candidatos a ser el núcleo de un alma — son los "hubs" del sistema.
2. **Clustering por co-llamada**: grupos de SPs que siempre se llaman juntos en los journeys forman un alma.
3. **Naming patterns**: prefijos o sufijos compartidos revelan cohesión intencional del equipo original (ej. todos los `sp_*_credito` forman el alma de crédito).
4. **Dominio de datos**: SPs que operan principalmente sobre las mismas tablas core forman un alma.
5. **Entry points de orquestación**: CTM_ENTRY y CTM_HINT marcan fronteras de almas batch — el orquestador sabe cuál es la entrada al módulo.

## Estructura en brain.db

```sql
CREATE TABLE souls (
    id TEXT PRIMARY KEY,           -- slug: "cargo-ref"
    display_name TEXT NOT NULL,    -- "Motor de Cargos y Abonos"
    description TEXT,              -- descripción funcional de negocio (1-2 oraciones)
    domain TEXT,                   -- dominio de negocio primario
    core_sp TEXT,                  -- SP central del alma (hub del cluster)
    sp_count INTEGER,              -- cuántos SPs la componen
    etb_l3 TEXT,                   -- capability ETB L3 primaria que implementa
    replicas INTEGER DEFAULT 0,    -- réplicas muertas / instancias duplicadas encontradas
    status TEXT DEFAULT 'active'   -- active | deprecated | dead (réplica sin uso)
);
```

## Bautismo del Alma

El nombre (`display_name`) del alma se deriva del vocabulario empresarial (Capa 1). Nunca se usa un nombre técnico de variable o tabla. El alma "Motor de Cargos y Abonos" no se llama "cargo_ref" ni "bdisac:sp_abono".

## Réplicas muertas

Los sistemas legacy frecuentemente tienen copias de módulos que nunca fueron depuradas. Una réplica muerta es un alma con `status='dead'` — existe en el código pero no tiene tráfico de producción y su funcionalidad está duplicada por otra alma activa. Documentar réplicas muertas es importante para el assessment 7R: son candidatos directos a `Retire`.

## Instancias de referencia

- **BanCoppel Informix**: 11 almas sobre D01-D16, 16 instancias (5 réplicas muertas).
  - Ejemplos activos: Motor de Cargos y Abonos (`cargo_ref`, hub D01), Procesador SPEI (`sp_autoriza_pagos_spei`, D08), Motor de Scoring Crediticio.
  - Réplicas muertas: 5 módulos con funcionalidad duplicada, candidatos a `Retire` en la decisión 7R.
- **BanCoppel AppMovil**: almas de canales digitales — Autenticación de Sesión, Transacciones Móviles, Consulta de Saldo.
