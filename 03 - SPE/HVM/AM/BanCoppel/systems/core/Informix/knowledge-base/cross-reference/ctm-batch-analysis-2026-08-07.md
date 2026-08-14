# Análisis Batch Control-M — BanCoppel Informix · 2026-08-07
> Generado: 2026-08-07 21:16 · `generators/analyze-ctm-logs.py` v1.0

## Contexto

Jobs del scheduler **BMC Control-M** que se ejecutan sobre el servidor Informix IDS 14.10 (`DCMSIF01` / `ifxsif01`). Los archivos de salida capturan el trace completo del shell (`set -x`) más la salida de `dbaccess`.

## Resumen de ejecución

| Métrica | Valor |
|---------|-------|
| Jobs analizados | 1 |
| Exitosos (código 000) | 1 |
| Con errores Informix | 0 |
| Con advertencias | 0 |
| Bases de datos accedidas | 1 (`bdicheq`) |

## Detalle por job

| Estado | Job | BD | SQL | Inicio | Duración | Código | Filas |
|--------|-----|----|-----|--------|----------|--------|-------|
| ✅ | `CIERRECAP_INVCREC_PARAM_PRO` | `bdicheq` | `eje_cierrechqinvcrecparam.sql` | 23:20:20 | 36s | `000` | 1 retrieved |

## Errores detectados

Ninguno — todos los jobs terminaron sin errores Informix.

## Señales para la migración Informix

- **BDs batch activas**: `bdicheq` — estas BDs tienen jobs de cierre diario que deben reproducirse en el target.
- **Scripts SQL de cierre**: `eje_cierrechqinvcrecparam.sql` — buscar en `source/informix/` para análisis de equivalencia funcional.
- **Scheduler**: Control-M 9.0.22.x en `DCMSIF01` — la migración debe incluir la replicación del calendar/schedule en el target (preferentemente AWS EventBridge Scheduler o Step Functions).

---
*Evidencia: `source/logs/2026-08-07/` · Generado: 2026-08-07 21:16*