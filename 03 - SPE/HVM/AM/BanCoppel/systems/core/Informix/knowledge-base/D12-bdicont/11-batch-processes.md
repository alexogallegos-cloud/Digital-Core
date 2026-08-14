# D12 · Contabilidad — Procesos Batch y Schedulers

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdicont` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 4 · Riesgo: **ALTO**
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
| `gen_totalbalanza` | 1169 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟡 MEDIO |
| `gen_totaliz` | 1132 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟡 MEDIO |
| `gen_totalizvar` | 859 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟡 MEDIO |
| `pasecont` | 795 | [SME-PENDING] — probablemente nocturno | Lambda + particionamiento PostgreSQL | 🟡 MEDIO |
| `libromayor_diariosaux` | 607 | [SME-PENDING] — validar en scheduler AIX | Step Function + ECS Task (alto volumen) | 🟢 BAJO |
| `libromayor_historicosaux` | 597 | [SME-PENDING] — probablemente nocturno | Lambda + archivado S3/Glacier | 🟡 MEDIO |
| `libromayor_historicos` | 552 | [SME-PENDING] — probablemente nocturno | Lambda + archivado S3/Glacier | 🟡 MEDIO |
| `libromayor_diarios` | 549 | [SME-PENDING] — validar en scheduler AIX | Step Function + ECS Task (alto volumen) | 🟢 BAJO |
| `auxiliares2` | 516 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟡 MEDIO |
| `auxiliares3` | 516 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟡 MEDIO |
| `gen_repbalccpba` | 504 | [SME-PENDING] — diario o semanal | Lambda / ECS Fargate CronJob | 🟢 BAJO |
| `gen_repbal` | 497 | [SME-PENDING] — diario o semanal | Lambda / ECS Fargate CronJob | 🟢 BAJO |
| `cierre` | 444 | [SME-PENDING] — validar en scheduler AIX | Step Function orquestado (pasos atómicos) | 🔴 ALTO |
| `gen_repbalreg` | 441 | [SME-PENDING] — diario o semanal | Lambda / ECS Fargate CronJob | 🟢 BAJO |
| `auditapase_ant` | 349 | [SME-PENDING] — probablemente nocturno | Lambda + particionamiento PostgreSQL | 🟡 MEDIO |

## Detalle por proceso batch


### `gen_totalbalanza` (1169 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `balan`, `bdinteg:si_catalog`, `bdinteg:si_sucursales`, `bdirepaut:sp_preciocontable`, `co_balanza` · Escritura: `co_balanza` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda / ECS Fargate CronJob |
| Riesgo | 🟡 MEDIO — SP complejo — requiere análisis detallado |


### `gen_totaliz` (1132 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `co_balprev`, `co_param` · Escritura: `co_balprev` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda / ECS Fargate CronJob |
| Riesgo | 🟡 MEDIO — SP complejo — requiere análisis detallado |


### `gen_totalizvar` (859 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `co_balprev`, `co_paramcta` · Escritura: `co_balprev` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda / ECS Fargate CronJob |
| Riesgo | 🟡 MEDIO — SP complejo — requiere análisis detallado |


### `pasecont` (795 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicont:co_detpol`, `bdicont:co_poldet`, `bdicont:co_poliza`, `bdinteg:si_ejecut`, `bdinteg:si_param` · Escritura: `bdicont:co_detpol`, `bdicont:co_poldet`, `bdicont:co_poliza`, `bdinteg:sx_contproc`, `sd_contproc` |
| Frecuencia estimada | [SME-PENDING] — probablemente nocturno |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda + particionamiento PostgreSQL |
| Riesgo | 🟡 MEDIO — Archiva datos — riesgo de duplicados si se reinicia |


### `libromayor_diariosaux` (607 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicont:`, `bdicont:co_libmadet`, `bdicont:tmp_auxiliares`, `bdicont:tmp_ciudades`, `bdicont:tmp_minmaxfechasaldos` · Escritura: `STATISTICS`, `bdicont:`, `bdicont:tmp_minmaxfechasaldos`, `bdicont:tmp_saldos`, `bdicont:tmp_saldosfinales` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Step Function + ECS Task (alto volumen) |
| Riesgo | 🟢 BAJO — Solo lectura y generación — bajo riesgo en migración |


### `libromayor_historicosaux` (597 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicont:`, `bdicont:co_libmadet`, `bdicont:tmp_auxiliares`, `bdicont:tmp_ciudades`, `bdicont:tmp_minmaxfechasaldos` · Escritura: `STATISTICS`, `bdicont:`, `bdicont:tmp_minmaxfechasaldos`, `bdicont:tmp_saldos`, `bdicont:tmp_saldosfinales` |
| Frecuencia estimada | [SME-PENDING] — probablemente nocturno |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda + archivado S3/Glacier |
| Riesgo | 🟡 MEDIO — Archiva datos — riesgo de duplicados si se reinicia |


### `libromayor_historicos` (552 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicont:`, `bdicont:co_libmadet`, `bdicont:tmp_ciudades`, `bdicont:tmp_minmaxfechasaldos`, `bdicont:tmp_monedas` · Escritura: `STATISTICS`, `bdicont:`, `bdicont:tmp_minmaxfechasaldos`, `bdicont:tmp_saldos`, `bdicont:tmp_saldosfinales` |
| Frecuencia estimada | [SME-PENDING] — probablemente nocturno |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda + archivado S3/Glacier |
| Riesgo | 🟡 MEDIO — Archiva datos — riesgo de duplicados si se reinicia |


### `libromayor_diarios` (549 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicont:`, `bdicont:co_libmadet`, `bdicont:tmp_ciudades`, `bdicont:tmp_minmaxfechasaldos`, `bdicont:tmp_monedas` · Escritura: `STATISTICS`, `bdicont:`, `bdicont:tmp_minmaxfechasaldos`, `bdicont:tmp_saldos`, `bdicont:tmp_saldosfinales` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Step Function + ECS Task (alto volumen) |
| Riesgo | 🟢 BAJO — Solo lectura y generación — bajo riesgo en migración |


### `auxiliares2` (516 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicont:co_diasaux`, `bdicont:co_fechas`, `bdicont:co_histdiasaux`, `bdicont:co_historico`, `bdicont:co_mensual` · Escritura: `bdicont:co_diasaux`, `bdicont:co_histdiasaux`, `co_histdiasaux` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda / ECS Fargate CronJob |
| Riesgo | 🟡 MEDIO — SP complejo — requiere análisis detallado |


### `auxiliares3` (516 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicont:co_diasaux`, `bdicont:co_fechas`, `bdicont:co_histdiasaux`, `bdicont:co_historico`, `bdicont:co_mensual` · Escritura: `bdicont:co_diasaux`, `bdicont:co_histdiasaux`, `co_histdiasaux` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda / ECS Fargate CronJob |
| Riesgo | 🟡 MEDIO — SP complejo — requiere análisis detallado |

## Acción crítica: inventario del scheduler AIX

**[SME-PENDING — DBA BanCoppel]** Ejecutar en el servidor AIX:

```bash
# Listar todos los cron jobs del usuario informix:
crontab -u informix -l

# Buscar referencias a SPs del dominio bdicont:
grep -r "bdicont" /var/spool/cron/ 2>/dev/null

# Si usan UC4 / Control-M: extraer jobs con filtro "bdicont"
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
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdicont_*.sql (análisis estático de 70 archivos SQL) · análisis de patrones de nombres + código*
