# Etapa 3 — Biografía: Los Customer Journeys

> Etapa 3 del Gemelo Cognitivo del Sistema. Metodología Enterprise Brain · Digital Core.
> **Eje de metodología, no de arquitectura.** Esta es la etapa 3 de cuatro del método de extracción y puebla `journeys` de la extensión `SYSTEM`. No es una de las seis capas de la arquitectura; el método completo es el trabajo de la Capa 2 y su producto aterriza en la Capa 3. Ver "Los Dos Ejes del Conocimiento" en `reference-architecture-enterprise-brain.md`.

## Objetivo

Extraer los flujos de negocio del sistema — cómo una transacción o proceso de negocio traversa el sistema desde el entry point hasta el resultado — para que el equipo de modernización entienda el "cuándo" y el "cómo" además del "qué".

## Qué es un Journey

Un journey es:

- Un **entry point** identificable: un SP llamado desde fuera (ESB, CTM, canal digital, API externa).
- Un **call graph** desde ese entry point hasta los SPs de dominio que ejecuta.
- Una **narrativa de negocio** que describe el proceso en términos del cliente o del operador.
- Los **dominios involucrados** — un journey cross-domain es de alta complejidad y alto riesgo de equivalencia.

## Tipos de entry points

| Tipo | Señal en código/brain | Ejemplo |
|------|----------------------|---------|
| CTM_ENTRY | Job Control Language que llama directamente el SP | Batch nocturno de liquidación |
| ESB_EXPOSED | SP con llamadas desde ESB documentadas en logs de producción | API de autorización de tarjetas |
| CHANNEL | SP invocado desde canal digital (app móvil, banca internet) | Consulta de saldo, transferencia SPEI |
| SCHEDULED | SP con trigger de scheduler interno o externo | Proceso de corte mensual |

## Proceso de extracción

1. **Identificar entry points**: SPs con fan_in=0 (no llamados internamente) + CTM_ENTRY + ESB_EXPOSED (desde logs de producción) + CHANNEL.
2. **Recorrer el call graph**: seguir la cadena de llamadas desde cada entry point hasta los SPs hoja.
3. **Sintetizar narrativa**: leer los SPs involucrados y construir la descripción de negocio del journey.
4. **Identificar dominios**: detectar si el journey cruza múltiples dominios (cross-domain = complejidad alta).
5. **Calcular métricas**: profundidad del call graph, total de SPs involucrados.

## Estructura en brain.db

El DDL ejecutable vive en [`templates/schema.sql`](../../templates/schema.sql) y es la única fuente de verdad (ADR-EB-006). Este documento no lo transcribe: lo describe.

**Campos de `journeys`**

| Campo | Qué guarda |
|-------|-----------|
| `entry_component` | Componente que da entrada al journey. Antes documentado como `entry_sp`, nombre que nunca existió |
| `display_name` | Nombre del journey en el idioma del negocio |
| `description` | Narrativa de negocio |
| `call_depth` | Profundidad máxima del grafo de llamadas |
| `component_count` | Cuántos componentes recorre. Antes documentado como `sp_count` |
| `source_type` | Cómo se descubrió: entrada de orquestador, expuesto por ESB, canal o programado |

Más `tier`, que declara el nivel de certeza de la afirmación (Regla B37), y `process_id`, que la ata a un proceso de negocio (Regla B22).

## Phase B — CALLEE_INFO Lookup

Una extensión del portal de journeys que anota cada nodo CALL del flowchart con la descripción de negocio y el conteo de reglas del SP llamado, con link clickeable a su página de detalle.

Beneficio: el analista de modernización navega el journey entendiendo el propósito de negocio de cada SP en el flujo, no solo su nombre técnico.

Implementación en BanCoppel: `build-sp-detail-pages.py` — 166 SPs cubiertos, 59/131 con link clickeable, 14/131 con descripción de callee en el nodo CALL.

## Instancias de referencia

- **BanCoppel Informix**: 166 journeys extraídos (D01-D16 completo). Entry points: CTM_ENTRY=155, ESB_EXPOSED=552 SPs con métricas reales de producción (evidencia ESB 2026-04-24). 16 dominios cubiertos.
- **Banamex GemCog**: journeys del sistema Unisys S500 — mapeo de transacciones DMSII.
