# D01 · Canal Digital Web — Procesos Batch y Schedulers

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdicnweb` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** ÚLTIMO · Riesgo: **ALTO**
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
| `sp_adm_consultabitacora_usuarios` | 8779 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟡 MEDIO |
| `sp_adm_consultabitacora_usuarios_totales` | 8665 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟡 MEDIO |
| `sp_actualizareportespendientesarqueosuc` | 6471 | [SME-PENDING] — diario o semanal | AWS Glue / Lambda + S3 + QuickSight | 🟢 BAJO |
| `sp_actualizareportespendientesentradasalida` | 6417 | [SME-PENDING] — diario o semanal | AWS Glue / Lambda + S3 + QuickSight | 🟢 BAJO |
| `sp_adminitasas_cargarchivo` | 5927 | [SME-PENDING] — probablemente nocturno | AWS Glue + S3 staging | 🟡 MEDIO |
| `sp_admintasas_bitacoraerror` | 3980 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟡 MEDIO |
| `sp_admintasas_consultabitacora` | 3847 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟡 MEDIO |
| `sp_abono_ref_masivo` | 1642 | [SME-PENDING] — validar en scheduler AIX | Lambda / ECS Fargate CronJob | 🟡 MEDIO |

## Detalle por proceso batch


### `sp_adm_consultabitacora_usuarios` (8779 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicheq:`, `bdicnweb:`, `bdicnweb:sw_cg_billetesfalsos`, `bdicnweb:sw_verificastatusarchivodeclaracionide`, `bdicnweb:sw_verificastatusentradasalida` · Escritura: `STATISTICS`, `bdicheq:`, `bdicnweb:`, `bdicred:`, `bdilide:` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda / ECS Fargate CronJob |
| Riesgo | 🟡 MEDIO — SP complejo — requiere análisis detallado |


### `sp_adm_consultabitacora_usuarios_totales` (8665 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicheq:`, `bdicnweb:`, `bdicnweb:sw_cg_billetesfalsos`, `bdicnweb:sw_verificastatusarchivodeclaracionide`, `bdicnweb:sw_verificastatusentradasalida` · Escritura: `STATISTICS`, `bdicheq:`, `bdicnweb:`, `bdicred:`, `bdilide:` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda / ECS Fargate CronJob |
| Riesgo | 🟡 MEDIO — SP complejo — requiere análisis detallado |


### `sp_actualizareportespendientesarqueosuc` (6471 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicnweb:`, `bdicnweb:sw_cg_billetesfalsos`, `bdicnweb:sw_verificastatusarchivodeclaracionide`, `bdicnweb:sw_verificastatusentradasalida`, `bdilide:` · Escritura: `STATISTICS`, `bdicnweb:`, `bdilide:`, `bdinteg:`, `bdirst:` |
| Frecuencia estimada | [SME-PENDING] — diario o semanal |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | AWS Glue / Lambda + S3 + QuickSight |
| Riesgo | 🟢 BAJO — Solo lectura y generación — bajo riesgo en migración |


### `sp_actualizareportespendientesentradasalida` (6417 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicnweb:`, `bdicnweb:sw_cg_billetesfalsos`, `bdicnweb:sw_verificastatusarchivodeclaracionide`, `bdicnweb:sw_verificastatusentradasalida`, `bdilide:` · Escritura: `STATISTICS`, `bdicnweb:`, `bdilide:`, `bdinteg:`, `bdirst:` |
| Frecuencia estimada | [SME-PENDING] — diario o semanal |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | AWS Glue / Lambda + S3 + QuickSight |
| Riesgo | 🟢 BAJO — Solo lectura y generación — bajo riesgo en migración |


### `sp_adminitasas_cargarchivo` (5927 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `TRIM`, `bdiaclaracion:acl_aclaracion`, `bdiaclaracion:acl_producto`, `bdicheq:`, `bdicheq:sc_admintasas_inv_estatus` · Escritura: `bdicheq:`, `bdicheq:sc_admintasas_inv_clientes`, `bdicheq:sc_admintasas_inv_estatus`, `bdicheq:sc_admintasas_inv_sucursales`, `bdicheq:sc_admintasas_invcreciente` |
| Frecuencia estimada | [SME-PENDING] — probablemente nocturno |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | AWS Glue + S3 staging |
| Riesgo | 🟡 MEDIO — Archiva datos — riesgo de duplicados si se reinicia |


### `sp_admintasas_bitacoraerror` (3980 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicheq:`, `bdicheq:sc_fechas`, `bdicheq:sc_maechq`, `bdicheq:sc_movhis`, `bdicheq:sc_movhis_old` · Escritura: `bdicnweb:`, `bdinvers:`, `informix` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda / ECS Fargate CronJob |
| Riesgo | 🟡 MEDIO — SP complejo — requiere análisis detallado |


### `sp_admintasas_consultabitacora` (3847 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicheq:`, `bdicheq:sc_fechas`, `bdicheq:sc_maechq`, `bdicheq:sc_movhis`, `bdicheq:sc_movhis_old` · Escritura: `bdicnweb:`, `bdinvers:`, `informix` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda / ECS Fargate CronJob |
| Riesgo | 🟡 MEDIO — SP complejo — requiere análisis detallado |


### `sp_abono_ref_masivo` (1642 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicheq:`, `bdicheq:sc_areabloqueo`, `bdicheq:sc_bloqueo`, `bdicheq:sc_histbloq`, `bdicheq:sc_mae_estatus` · Escritura: `bdicnweb:`, `bdicnweb:sw_tr_cargamasiva_bloqueocap`, `bdicnweb:sw_tr_cargamasiva_bloqueocap_hist`, `bdicnweb:sw_tr_cargamasiva_cancelacioncre`, `bdicnweb:sw_tr_cargamasiva_cancelacioncre_hist` |
| Frecuencia estimada | [SME-PENDING] — validar en scheduler AIX |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Lambda / ECS Fargate CronJob |
| Riesgo | 🟡 MEDIO — SP complejo — requiere análisis detallado |

## Acción crítica: inventario del scheduler AIX

**[SME-PENDING — DBA LegacyCore]** Ejecutar en el servidor AIX:

```bash
# Listar todos los cron jobs del usuario informix:
crontab -u informix -l

# Buscar referencias a SPs del dominio bdicnweb:
grep -r "bdicnweb" /var/spool/cron/ 2>/dev/null

# Si usan UC4 / Control-M: extraer jobs con filtro "bdicnweb"
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
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdicnweb_*.sql (análisis estático de 57 archivos SQL) · análisis de patrones de nombres + código*
