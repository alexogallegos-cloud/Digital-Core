# D10 · Sucursales — Procesos Batch y Schedulers

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdisuc` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 3 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, code extraction)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2) ← NUEVO
- Industry Banking + Domain Expert BanCoppel (validación funcional)
- Cybersecurity (riesgos PII, regulación CNBV/LFPDPPP)
- QA Lead — Equivalencia Funcional (estrategia de pruebas) ← NUEVO
- Cloud Architect AWS Banking (arquitectura target) ← NUEVO
> [SME-PENDING] = requiere sesión de validación antes de Etapa 2.
---

## Por qué los procesos batch son invisibles al callgraph

Los SPs batch son invocados por un **scheduler externo** (cron AIX, UC4, Control-M o script shell) — ningún otro SP los llama. Por eso su `fan_in = 0` en el callgraph, haciéndolos indistinguibles del código muerto en el análisis estático. La diferencia es crítica: **código muerto = no migrar**, **batch = migrar como job**.

## Resumen de procesos batch identificados

| SP | LOC | Frecuencia estimada | Target recomendado | Riesgo |
|----|-----|--------------------|--------------------|--------|
| `manejacajageneral` | 426 | [SME-PENDING] — diario o semanal | AWS Glue / Lambda + S3 output | 🟢 BAJO |
| `sp_afecta_cajageneral` | 368 | [SME-PENDING] — diario o semanal | AWS Glue / Lambda + S3 output | 🟢 BAJO |
| `consultacajageneral2` | 247 | [SME-PENDING] — diario o semanal | AWS Glue / Lambda + S3 output | 🟢 BAJO |
| `consultacajageneral` | 192 | [SME-PENDING] — diario o semanal | AWS Glue / Lambda + S3 output | 🟢 BAJO |
| `sp_arqueocedulacontable` | 171 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🔴 ALTO |
| `consultacajageneral2_totales` | 155 | [SME-PENDING] — diario o semanal | AWS Glue / Lambda + S3 output | 🟢 BAJO |
| `sp_consulta_cajageneral` | 136 | [SME-PENDING] — diario o semanal | AWS Glue / Lambda + S3 output | 🟢 BAJO |
| `sp_arqueoatms` | 127 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟢 BAJO |
| `sp_arqueossuc_atm_web` | 61 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟢 BAJO |
| `sp_arqueossuc` | 60 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟢 BAJO |
| `sp_arqueossuc_web` | 60 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟢 BAJO |
| `sp_arqueossuc_atm` | 59 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟢 BAJO |
| `sp_arqueo_atm` | 53 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟢 BAJO |
| `genera_update_index` | 33 | [SME-PENDING] — diario o semanal | AWS Glue / Lambda + S3 output | 🟢 BAJO |

## Detalle por proceso batch


### `manejacajageneral` (426 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdinteg:si_catalog`, `bdinteg:si_regional`, `bdinteg:si_sucursales`, `co_auditpase`, `co_auxiliar` · Escritura: `co_auditpase`, `co_detpol`, `co_poliza`, `ss_cajageneral`, `ss_proveedores` |
| Frecuencia estimada | [SME-PENDING] — diario o semanal |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | AWS Glue / Lambda + S3 output |
| Riesgo | 🟢 BAJO — Solo lectura y generación — bajo riesgo en migración |


### `sp_afecta_cajageneral` (368 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdinteg:`, `bdisuc:`, `bdisuc:ss_cajageneral` · Escritura: `bdisuc:` |
| Frecuencia estimada | [SME-PENDING] — diario o semanal |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | AWS Glue / Lambda + S3 output |
| Riesgo | 🟢 BAJO — Solo lectura y generación — bajo riesgo en migración |


### `consultacajageneral2` (247 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdinteg:si_divisas`, `bdinteg:si_plazas_cajagen`, `bdisuc:`, `bdisuc:ss_cajageneral`, `bdisuc:ss_proveedores` · Escritura: — |
| Frecuencia estimada | [SME-PENDING] — diario o semanal |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | AWS Glue / Lambda + S3 output |
| Riesgo | 🟢 BAJO — Solo lectura y generación — bajo riesgo en migración |


### `consultacajageneral` (192 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdinteg:si_divisas`, `bdinteg:si_plazas_cajagen`, `bdisuc:ss_cajageneral`, `bdisuc:ss_proveedores`, `ss_proveedores` · Escritura: — |
| Frecuencia estimada | [SME-PENDING] — diario o semanal |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | AWS Glue / Lambda + S3 output |
| Riesgo | 🟢 BAJO — Solo lectura y generación — bajo riesgo en migración |


### `sp_arqueocedulacontable` (171 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdisuc:`, `ss_reportecedula` · Escritura: `ss_arqueo_panamericano` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda / ECS Fargate CronJob |
| Riesgo | 🔴 ALTO — Proceso regulatorio/contable — equivalencia exacta requerida |


### `consultacajageneral2_totales` (155 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdinteg:`, `bdinteg:si_divisas`, `bdinteg:si_plazas_cajagen`, `bdisuc:`, `bdisuc:ss_cajageneral` · Escritura: — |
| Frecuencia estimada | [SME-PENDING] — diario o semanal |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | AWS Glue / Lambda + S3 output |
| Riesgo | 🟢 BAJO — Solo lectura y generación — bajo riesgo en migración |


### `sp_consulta_cajageneral` (136 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicont:co_fechas`, `bdicont:co_poldet_20240518`, `bdisuc:` · Escritura: — |
| Frecuencia estimada | [SME-PENDING] — diario o semanal |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | AWS Glue / Lambda + S3 output |
| Riesgo | 🟢 BAJO — Solo lectura y generación — bajo riesgo en migración |


### `sp_arqueoatms` (127 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdinteg:si_sucursales`, `bdisuc:ss_corteadminview`, `bdisuc:ss_relacionccid`, `ss_operaciones` · Escritura: — |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda / ECS Fargate CronJob |
| Riesgo | 🟢 BAJO — Proceso simple de mantenimiento |


### `sp_arqueossuc_atm_web` (61 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: [SME-PENDING] · Escritura: `ss_saldossuc` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda / ECS Fargate CronJob |
| Riesgo | 🟢 BAJO — Proceso simple de mantenimiento |


### `sp_arqueossuc` (60 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: [SME-PENDING] · Escritura: `ss_saldossuc` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda / ECS Fargate CronJob |
| Riesgo | 🟢 BAJO — Proceso simple de mantenimiento |

## Acción crítica: inventario del scheduler AIX

**[SME-PENDING — DBA BanCoppel]** Ejecutar en el servidor AIX:

```bash
# Listar todos los cron jobs del usuario informix:
crontab -u informix -l

# Buscar referencias a SPs del dominio bdisuc:
grep -r "bdisuc" /var/spool/cron/ 2>/dev/null

# Si usan UC4 / Control-M: extraer jobs con filtro "bdisuc"
# Documentar: SP invocado, horario, parámetros, dependencias de otros jobs
```

Sin este inventario, es imposible replicar la calendarización exacta en AWS EventBridge Scheduler.

## Consideraciones de migración de batch

### 1. COMMIT parcial (riesgo de inconsistencia)
Los SPs batch Informix típicamente hacen `COMMIT WORK` cada N registros. Si el job falla a mitad, la tabla queda en estado parcialmente procesada. En el target:
- Usar idempotencia con checkpoint: guardar el último registro procesado
- Implementar DELETE / MOVE en lotes con re-entryability
- Agregar Dead Letter Queue (DLQ) para registros con error

### 2. Ventana de mantenimiento
Los procesos de purga y archivado asumen disponibilidad nocturna exclusiva. En AWS:
- Coordinar con el CDC de Debezium — no ejecutar batch mientras hay replicación activa
- Definir ventana de mantenimiento en AWS RDS/Aurora

### 3. Monitoreo
- Implementar CloudWatch alarms para cada job batch (duración, registros procesados, errores)
- Step Functions da visibilidad de cada paso y permite re-run desde el punto de fallo


---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdisuc_*.sql (análisis estático de 70 archivos SQL) · análisis de patrones de nombres + código*
