# D11 · Cobranza — Procesos Batch y Schedulers

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdicobranza` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 2 · Riesgo: **MEDIO**
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, code extraction)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2) ← NUEVO
- Industry Banking + Domain Expert LegacyCore (validación funcional)
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
| `sp_calculacobranza` | 1276 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟡 MEDIO |
| `sp_cat_depura_cte_tel_inactivo` | 510 | [SME-PENDING] — probablemente nocturno (mantenimiento) | Step Function / Lambda con paginación idempotente | 🟠 ALTO |
| `sp_cat_depura_tel_inactivo` | 465 | [SME-PENDING] — probablemente nocturno (mantenimiento) | Step Function / Lambda con paginación idempotente | 🟠 ALTO |
| `sp_cat_consulta_generales` | 433 | [SME-PENDING] — diario o semanal | AWS Glue / Lambda + S3 output | 🟢 BAJO |
| `sp_cat_genera_testigo` | 307 | [SME-PENDING] — diario o semanal | AWS Glue / Lambda + S3 output | 🟢 BAJO |
| `sp_cat_cierrellamadas` | 301 | [SME-PENDING] — validar en scheduler AIX | Step Function orquestado (pasos atómicos) | 🔴 ALTO |
| `sp_calcularcobranzapreventiva_contingencia` | 270 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟢 BAJO |
| `sp_calcula_cobranza_administrativa` | 268 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟢 BAJO |
| `sp_cat_cargeneracion` | 265 | [SME-PENDING] — diario o semanal | AWS Glue / Lambda + S3 output | 🟢 BAJO |
| `sp_calcularcobranzapreventiva` | 221 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟢 BAJO |
| `sp_actualiza_contacto_historico` | 65 | [SME-PENDING] — probablemente nocturno | Lambda + archivado S3/Glacier | 🟡 MEDIO |

## Detalle por proceso batch


### `sp_calculacobranza` (1276 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicobranza:`, `bdicobranza:cb_cat_resultado_llamada`, `bdicobranza:cb_compac`, `bdicobranza:cb_param_campania`, `bdicobranza:cb_registro_llamadas` · Escritura: `bdicobranza:cb_archivo_cat` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda / ECS Fargate CronJob |
| Riesgo | 🟡 MEDIO — SP complejo — requiere análisis detallado |


### `sp_cat_depura_cte_tel_inactivo` (510 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicobranza:`, `bdicobranza:cb_mail_cliente`, `bdicobranza:cb_mail_configuracion`, `bdicobranza:cb_telefonos`, `bdicred:` · Escritura: `bdicobranza:`, `bdinteg:`, `bdinteg:si_mensajes_enviar`, `bdisitesp:` |
| Frecuencia estimada | [SME-PENDING] — probablemente nocturno (mantenimiento) |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Step Function / Lambda con paginación idempotente |
| Riesgo | 🟠 ALTO — Elimina datos — riesgo de pérdida si falla a mitad |


### `sp_cat_depura_tel_inactivo` (465 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicobranza:`, `bdicobranza:cb_mail_cliente`, `bdicobranza:cb_mail_configuracion`, `bdicobranza:cb_telefonos`, `bdicred:` · Escritura: `bdicobranza:`, `bdinteg:`, `bdinteg:si_mensajes_enviar` |
| Frecuencia estimada | [SME-PENDING] — probablemente nocturno (mantenimiento) |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Step Function / Lambda con paginación idempotente |
| Riesgo | 🟠 ALTO — Elimina datos — riesgo de pérdida si falla a mitad |


### `sp_cat_consulta_generales` (433 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicobranza:`, `bdicobranza:cb_param_campania`, `bdicred:sd_maecredcrd`, `bdinteg:`, `bdinteg:si_catcalles` · Escritura: `bdicobranza:cb_registro_llamadas` |
| Frecuencia estimada | [SME-PENDING] — diario o semanal |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | AWS Glue / Lambda + S3 output |
| Riesgo | 🟢 BAJO — Solo lectura y generación — bajo riesgo en migración |


### `sp_cat_genera_testigo` (307 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicobranza:cb_param_campania`, `paso_testpp`, `paso_testtdc` · Escritura: `STATISTICS` |
| Frecuencia estimada | [SME-PENDING] — diario o semanal |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | AWS Glue / Lambda + S3 output |
| Riesgo | 🟢 BAJO — Solo lectura y generación — bajo riesgo en migración |


### `sp_cat_cierrellamadas` (301 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicobranza:`, `bdicobranza:cb_cat_movimientos`, `bdicred:sd_fechas`, `cb_registro_llamadas`, `ctas_adepurar` · Escritura: `STATISTICS`, `cb_cat_movimientos_his` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Step Function orquestado (pasos atómicos) |
| Riesgo | 🔴 ALTO — Proceso regulatorio/contable — equivalencia exacta requerida |


### `sp_calcularcobranzapreventiva_contingencia` (270 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicobranza:cb_compac`, `bdicred:sd_amortiza_credito`, `bdicred:sd_maecred`, `bdicred:sd_maecredanexo`, `bdicred:sd_maesdos` · Escritura: `CB_INFO_PREVENTIVA`, `cb_bitacora_cob` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda / ECS Fargate CronJob |
| Riesgo | 🟢 BAJO — Proceso simple de mantenimiento |


### `sp_calcula_cobranza_administrativa` (268 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicobranza:cb_info_administrativa`, `bdicobranza:cb_param_campanias`, `bdicred:sd_amortiza_credito`, `bdicred:sd_maecredanexo`, `bdicred:sd_movhis` · Escritura: `bdicobranza:cb_bitacora_cob`, `cb_bitacora_cob`, `cb_info_administrativa` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda / ECS Fargate CronJob |
| Riesgo | 🟢 BAJO — Proceso simple de mantenimiento |


### `sp_cat_cargeneracion` (265 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicobranza:`, `bdicobranza:cb_compac_montomin`, `bdicobranza:cb_param_campania`, `bdinteg:si_empresas`, `cb_cat_directorio_cte` · Escritura: — |
| Frecuencia estimada | [SME-PENDING] — diario o semanal |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | AWS Glue / Lambda + S3 output |
| Riesgo | 🟢 BAJO — Solo lectura y generación — bajo riesgo en migración |


### `sp_calcularcobranzapreventiva` (221 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicobranza:cb_compac`, `bdicobranza:cb_info_preventiva`, `bdicobranza:cb_param_campanias`, `bdicred:sd_amortiza_credito`, `bdicred:sd_maecred` · Escritura: `CB_INFO_PREVENTIVA`, `cb_bitacora_cob` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda / ECS Fargate CronJob |
| Riesgo | 🟢 BAJO — Proceso simple de mantenimiento |

## Acción crítica: inventario del scheduler AIX

**[SME-PENDING — DBA LegacyCore]** Ejecutar en el servidor AIX:

```bash
# Listar todos los cron jobs del usuario informix:
crontab -u informix -l

# Buscar referencias a SPs del dominio bdicobranza:
grep -r "bdicobranza" /var/spool/cron/ 2>/dev/null

# Si usan UC4 / Control-M: extraer jobs con filtro "bdicobranza"
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
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdicobranza_*.sql (análisis estático de 70 archivos SQL) · análisis de patrones de nombres + código*
