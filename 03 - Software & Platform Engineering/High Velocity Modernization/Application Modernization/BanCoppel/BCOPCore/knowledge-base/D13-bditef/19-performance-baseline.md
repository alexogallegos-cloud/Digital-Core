# D13 · Transferencias Electrónicas de Fondos (TEF) — Línea Base de Performance

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- SME — SRE & AIOps (métricas de performance)
- SME — DBA IBM Informix (métricas del motor Informix)
- SME — Core Banking Transformation (SLOs del sistema TEF)

> **IMPORTANTE:** Todas las métricas de esta sección están marcadas `[DATO-REQUERIDO]` — no hay logs de producción confirmados del dominio `bditef` disponibles en el análisis actual. Las estimaciones se basan en el contexto del dominio y en los patrones observados en D05-bdisac. Los valores reales deben obtenerse del DBA IBM Informix y del área de SRE de BanCoppel antes de BUILD.
---

## Descripción

Línea base de performance del dominio `bditef` en el sistema legacy (IBM Informix IDS 14.10 / POWER-AIX). Esta línea base se usará como criterio de comparación para validar que el microservicio target `TransferenciasService` en AWS cumple o mejora la performance del sistema actual.

---

## Volumen de operaciones

| Métrica | Valor | Fuente |
|---------|-------|--------|
| Transferencias TEF enviadas por día | `[DATO-REQUERIDO]` | Logs de producción Informix |
| Transferencias TEF recibidas por día (de CECOBAN) | `[DATO-REQUERIDO]` | Logs de producción Informix |
| Reversos por día | `[DATO-REQUERIDO]` | Logs de producción Informix |
| Devoluciones CECOBAN por día | `[DATO-REQUERIDO]` | Logs de producción Informix |
| Archivos CECOBAN procesados por ciclo | `[DATO-REQUERIDO]` | Logs de producción Informix |
| Registros por archivo de cámara (promedio) | `[DATO-REQUERIDO]` | Logs de producción Informix |
| Registros por archivo de cámara (pico) | `[DATO-REQUERIDO]` | Logs de producción Informix |

---

## Tiempos de respuesta SP por categoría

### SPs transaccionales (en línea)

| SP | Tiempo promedio (ms) | Tiempo p99 (ms) | Llamadas/día |
|----|---------------------|-----------------|--------------|
| `sp_tef_grabaoperacion` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` |
| `sp_grabaoperaciontef` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` |
| `cargo_cta` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` |
| `abono_cta` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` |
| `sp_tef_reversoperacion` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` |
| `sp_tef_validahorario` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` |
| `sp_tef_valida_datos` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` |
| `cal_fecha_pre_fh` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` (fan_in=96) |

### SPs de consulta

| SP | Tiempo promedio (ms) | Tiempo p99 (ms) | Llamadas/día |
|----|---------------------|-----------------|--------------|
| `sp_consultarepop_tef` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` |
| `sp_obtenerinformaciontef` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` |
| `sp_consdevext_tef` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` |
| `cons_dev_coppel` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` |

### SPs batch (tiempo de ejecución total por ciclo)

| SP / Proceso | Tiempo promedio por ciclo | Tiempo máximo permitido |
|-------------|--------------------------|------------------------|
| `sp_tef_presentador_g` (generación de lote) | `[DATO-REQUERIDO]` | Antes del corte CECOBAN |
| `sp_tef_procesararchivo60` (por archivo) | `[DATO-REQUERIDO]` | `[SME-PENDING]` |
| `sp_tef_moverregistroshist` | `[DATO-REQUERIDO]` | Ventana nocturna (estimado 4 hrs) |
| `sp_tef_act_rep_sicam` | `[DATO-REQUERIDO]` | Antes de la apertura del día siguiente |

---

## Concurrencia y throughput

| Métrica | Valor | Fuente |
|---------|-------|--------|
| Transacciones concurrentes máximas observadas | `[DATO-REQUERIDO]` | Monitor Informix |
| Locks por segundo en hora pico | `[DATO-REQUERIDO]` | Monitor Informix |
| Deadlocks por día (Informix -691) | `[DATO-REQUERIDO]` | Logs de error Informix |
| Hora pico de transferencias (ventana) | `[SME-PENDING]` | Estimado: 09:00–13:00 días hábiles |
| Throughput pico (transacciones/minuto) | `[DATO-REQUERIDO]` | Logs de producción |

---

## Errores ESB con impacto en performance (evidencia disponible de INC-005)

Los siguientes datos SÍ están disponibles de los logs de bus y representan la única evidencia cuantitativa confirmada:

| Código ESB | Errores/día confirmados | Impacto en performance |
|------------|------------------------|----------------------|
| `4394` MbUserException | ~2,452 | Transacciones que fallan por MQ — reintentos consumen recursos |
| `3743` SOAP Timeout | ~761 | Espera de 30s por timeout — degrada throughput en hora pico |
| `3701` JNI/Axis2 error | ~356 | Fallos de comunicación — impacto menor |
| `3165` SSL error | ~320 | Fallos de conexión — impacto menor |
| `6233` sin descripción | ~264 | `[SME-PENDING]` |

> El código ESB 3743 (timeout 30s) con 761 ocurrencias/día implica que se pierden aproximadamente ~380 minutos de thread time del bus por día esperando timeouts del sistema TEF externo. Este es el mayor impacto en performance conocido y debe resolverse con el circuit breaker del target.

---

## SLOs propuestos para el target

Basados en el contexto regulatorio y en los patrones de D05-bdisac. Deben validarse contra los datos reales de `[DATO-REQUERIDO]`:

| Métrica | SLO propuesto | Justificación |
|---------|--------------|---------------|
| Latencia p99 — envío TEF | < 3,000 ms | Incluye cargo en cuenta + registro + llamada sistema externo |
| Latencia p99 — consulta | < 500 ms | Lectura de Aurora |
| Latencia p99 — ciclo de cámara | < 30 min | Ventana operativa CECOBAN |
| Disponibilidad del servicio | 99.9% mensual | = máx. 43 min downtime/mes |
| Error rate de transferencias | < 0.1% | Excluyendo rechazos de negocio legítimos |
| Tiempo de procesamiento de archivo CECOBAN | < tiempo del ciclo de cámara actual | `[DATO-REQUERIDO]` para establecer baseline |

---

## Procedimiento para captura de baseline

Antes de BUILD (Etapa 4), el DBA IBM Informix debe proveer:

1. Reporte del monitor de Informix (`onstat -g act`) con llamadas al SP por hora durante una semana representativa.
2. Logs de ejecución del ESB con tiempos de respuesta por SP para el período 2026-04 a 2026-07.
3. Tamaño actual de `tef_operaciones` y `tef_bitacora` (filas totales, size en GB).
4. Número de archivos CECOBAN procesados por ciclo y tiempo de procesamiento.
5. Reporte de contención (locks, deadlocks) en las tablas transaccionales durante hora pico.

---

## `[SME-PENDING]`

- [ ] Captura de métricas de performance del sistema legacy con el DBA IBM Informix.
- [ ] Definición del período representativo para la línea base (semana típica vs. semana de fin de mes).
- [ ] Confirmar si existen SLAs contractuales actuales de BanCoppel con CECOBAN que deban mantenerse.
- [ ] Validar los SLOs propuestos con el área de operaciones de BanCoppel.

---
*Todas las métricas son [DATO-REQUERIDO] — sin logs de producción de bditef confirmados en el análisis actual*
