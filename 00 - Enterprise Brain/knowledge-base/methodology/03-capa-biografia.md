# Capa 3 — Biografía: Los Customer Journeys

> Capa 3 del Gemelo Cognitivo del Sistema. Metodología Enterprise Brain · Digital Core.

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

```sql
CREATE TABLE journeys (
    id TEXT PRIMARY KEY,           -- slug: "journey-autorizar-pago-spei"
    entry_sp TEXT NOT NULL,        -- SP entry point (ID canónico db:sp_name)
    display_name TEXT,             -- "Autorización de Pago SPEI"
    description TEXT,              -- narrativa de negocio del journey
    domain TEXT,                   -- dominio de negocio primario
    cross_domains TEXT,            -- JSON array — dominios secundarios involucrados
    call_depth INTEGER,            -- profundidad máxima del call graph
    sp_count INTEGER,              -- total de SPs en el journey
    source_type TEXT               -- "ctm_entry" | "esb_exposed" | "channel" | "scheduled"
);
```

## Phase B — CALLEE_INFO Lookup

Una extensión del portal de journeys que anota cada nodo CALL del flowchart con la descripción de negocio y el conteo de reglas del SP llamado, con link clickeable a su página de detalle.

Beneficio: el analista de modernización navega el journey entendiendo el propósito de negocio de cada SP en el flujo, no solo su nombre técnico.

Implementación en BanCoppel: `build-sp-detail-pages.py` — 166 SPs cubiertos, 59/131 con link clickeable, 14/131 con descripción de callee en el nodo CALL.

## Instancias de referencia

- **BanCoppel Informix**: 166 journeys extraídos (D01-D16 completo). Entry points: CTM_ENTRY=155, ESB_EXPOSED=552 SPs con métricas reales de producción (evidencia ESB 2026-04-24). 16 dominios cubiertos.
- **Banamex GemCog**: journeys del sistema Unisys S500 — mapeo de transacciones DMSII.
