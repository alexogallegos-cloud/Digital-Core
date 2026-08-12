# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Baseline de Performance

> **Componente:** BCOPCore · SPE-AM-001 · TEST Phase
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---

## Estado del baseline

> `[DATO-REQUERIDO]` — El baseline de performance de `bdilide` requiere métricas reales del sistema legacy en producción. Los valores en este documento son estimaciones basadas en el análisis de SPs y el contexto del negocio. El DBA IBM Informix debe capturar las métricas reales durante el período de observación previo al análisis de capacidad del target.

## SPs críticos para el SLO de performance

### Consulta LIDE (transaccional — ruta crítica)

El SP de consulta LIDE es el más crítico desde la perspectiva de performance porque bloquea la operación del cliente hasta recibir respuesta. Está en la ruta crítica de onboarding (D01), autenticación (D02) y otorgamiento de crédito (D03).

| SP | Tipo | SLO target | Baseline legacy | Notas |
|----|------|:----------:|:--------------:|-------|
| SP consulta LIDE por `num_cte` | Transaccional | < 50ms p99 | `[DATO-REQUERIDO]` | Determina el timeout del LideService (200ms total) |
| `sp_checacurp` | Transaccional | < 50ms p99 | `[DATO-REQUERIDO]` | Verificación de CURP en LIDE |

### Procesos batch (SLO de ventana de ejecución)

| Proceso | Ventana permitida | Duración estimada | Baseline legacy |
|---------|:----------------:|:-----------------:|:---------------:|
| `ejecutor_diario` | 22:00 – 23:00 CDMX (1 hora) | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` |
| `sp_acumulacionoperaciones` | 23:00 – 04:00 CDMX (5 horas) | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` |
| `sp_cargainformesat` (mensual) | Ventana de mantenimiento (6 horas) | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` |

> La duración del `sp_acumulacionoperaciones` depende críticamente del volumen de clientes activos con movimientos en efectivo. Con ~3 millones de clientes BanCoppel, el batch puede tardar entre 1 y 5 horas dependiendo del índice sobre `sl_movefec`. `[DATO-REQUERIDO]` — confirmar el volumen real con DBA.

## Estimaciones de carga transaccional

| Métrica | Estimación | Base |
|---------|:----------:|------|
| Consultas LIDE por hora (peak) | `[DATO-REQUERIDO]` | Proporción de operaciones de alto riesgo en D01/D02/D03 |
| Consultas LIDE por día | `[DATO-REQUERIDO]` | — |
| Volumen diario de movimientos procesados por PLD | `[DATO-REQUERIDO]` | Función del volumen transaccional de BanCoppel |
| Registros en `sl_movefec` al inicio del batch | `[DATO-REQUERIDO]` | Crítico para dimensionar el tiempo del batch |
| Registros en `sl_movefec_his` (histórico 10 años) | `[DATO-REQUERIDO]` | Crítico para el plan de migración de datos |

## Indicadores de salud del motor PLD

| Indicador | Cálculo | Umbral de alerta |
|-----------|---------|-----------------|
| Tiempo de finalización del batch diario | `hora_fin - hora_inicio` en `sl_procesos` | Si supera las 04:00 CDMX → alerta |
| Clientes acumulados vs. histórico | `COUNT(sl_retlide) / AVG_30_dias` | Si < 80% del promedio → posible error en batch |
| Archivos SAT generados vs. esperados | Recuento mensual | Si ≠ 1 archivo por período → alerta |

## Dimensionamiento target

Basado en el análisis estático y la arquitectura target:

| Componente | Configuración mínima | Justificación |
|-----------|---------------------|--------------|
| LideService (ECS Fargate) | 2 vCPU, 4 GB RAM, 3 instancias mínimas | Consultas transaccionales rápidas; 3 instancias para HA |
| PldBatchService (ECS Fargate) | 4 vCPU, 8 GB RAM, 1 instancia (escalable) | Batch con potencialmente millones de registros |
| Aurora PostgreSQL | db.r6g.large (Multi-AZ) | Operaciones NUMERIC con cálculo financiero |
| Aurora — storage | `[DATO-REQUERIDO]` | Depende del volumen de `sl_movefec_his` |
| S3 archivos regulatorios | `[DATO-REQUERIDO]` | Depende del tamaño de archivos SAT/CNBV/SHCP |

## Procedimiento para captura del baseline real

```
Instrucción para DBA IBM Informix:

1. Activar el registro de tiempos en `sl_procesos` durante 2 semanas:
   - fecha_inicio y fecha_fin de cada ejecución de `ejecutor_diario`
   - fecha_inicio y fecha_fin de `sp_acumulacionoperaciones`
   - fecha_inicio y fecha_fin de `sp_cargainformesat` (si aplica en el período)

2. Capturar el volumen de registros:
   SELECT tabname, COUNT(*) FROM {tabla} -- para sl_movefec, sl_movefec_his, sl_retlide, sl_exentos

3. Capturar tiempo de respuesta del SP de consulta LIDE:
   - Medir en logs de los sistemas llamantes (D01, D02, D03)
   - Si no hay logs disponibles: ejecutar 1,000 consultas de prueba y medir el p50/p95/p99

4. Documentar los resultados en este archivo en la sección [DATO-REQUERIDO]
```

## `[SME-PENDING]`

- [ ] DBA IBM Informix: capturar los datos de performance del sistema legacy durante 2 semanas.
- [ ] SRE & AIOps: confirmar la configuración de Aurora para optimizar las consultas del motor PLD.
- [ ] QA Lead: incluir pruebas de performance (JMeter o k6) para el LideService con el volumen estimado de consultas.
- [ ] Cloud Architect: confirmar que la configuración de Aurora es suficiente para el batch más largo esperado.

---
*Generado: DBA IBM Informix + SRE & AIOps · 2026-08-03*
