# D06 · Solicitudes — Procesos Batch y Schedulers

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdisolic` · IBM Informix IDS 14.10 / POWER-AIX
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
| `sp_adn_reporteinfodisp` | 144 | [SME-PENDING] — diario o semanal | AWS Glue / Lambda + S3 + QuickSight | 🟢 BAJO |
| `sp_adn_reporteinfodisp_web` | 144 | [SME-PENDING] — diario o semanal | AWS Glue / Lambda + S3 + QuickSight | 🟢 BAJO |
| `sp_adn_inforeportes` | 128 | [SME-PENDING] — diario o semanal | AWS Glue / Lambda + S3 + QuickSight | 🟢 BAJO |
| `sp_adn_inforeportes_web` | 128 | [SME-PENDING] — diario o semanal | AWS Glue / Lambda + S3 + QuickSight | 🟢 BAJO |
| `sp_adn_repgeneral` | 76 | [SME-PENDING] — diario o semanal | AWS Glue / Lambda + S3 output | 🟢 BAJO |

## Detalle por proceso batch


### `sp_adn_reporteinfodisp` (144 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicred:` · Escritura: — |
| Frecuencia estimada | [SME-PENDING] — diario o semanal |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | AWS Glue / Lambda + S3 + QuickSight |
| Riesgo | 🟢 BAJO — Solo lectura y generación — bajo riesgo en migración |


### `sp_adn_reporteinfodisp_web` (144 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicred:` · Escritura: — |
| Frecuencia estimada | [SME-PENDING] — diario o semanal |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | AWS Glue / Lambda + S3 + QuickSight |
| Riesgo | 🟢 BAJO — Solo lectura y generación — bajo riesgo en migración |


### `sp_adn_inforeportes` (128 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicred:`, `bdicred:sd_definicion`, `bdinteg:` · Escritura: — |
| Frecuencia estimada | [SME-PENDING] — diario o semanal |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | AWS Glue / Lambda + S3 + QuickSight |
| Riesgo | 🟢 BAJO — Solo lectura y generación — bajo riesgo en migración |


### `sp_adn_inforeportes_web` (128 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: `bdicred:`, `bdicred:sd_definicion`, `bdinteg:` · Escritura: — |
| Frecuencia estimada | [SME-PENDING] — diario o semanal |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | AWS Glue / Lambda + S3 + QuickSight |
| Riesgo | 🟢 BAJO — Solo lectura y generación — bajo riesgo en migración |


### `sp_adn_repgeneral` (76 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | [SME-PENDING] — extraer firma del SP |
| Retorna | [SME-PENDING] |
| Tablas afectadas | Lectura: [SME-PENDING] · Escritura: — |
| Frecuencia estimada | [SME-PENDING] — diario o semanal |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | AWS Glue / Lambda + S3 output |
| Riesgo | 🟢 BAJO — Solo lectura y generación — bajo riesgo en migración |

## Acción crítica: inventario del scheduler AIX

**[SME-PENDING — DBA BanCoppel]** Ejecutar en el servidor AIX:

```bash
# Listar todos los cron jobs del usuario informix:
crontab -u informix -l

# Buscar referencias a SPs del dominio bdisolic:
grep -r "bdisolic" /var/spool/cron/ 2>/dev/null

# Si usan UC4 / Control-M: extraer jobs con filtro "bdisolic"
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
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdisolic_*.sql (análisis estático de 70 archivos SQL) · análisis de patrones de nombres + código*

<!-- LOG-DATA-BEGIN -->
## Procesos batch detectados en logs — 2026-04-24
> Fuente: `source/logs/transacciones_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

| Servicio | Referencia muestra | Hora primer disparo |
|----------|-------------------|---------------------|
| `RemesasAPPRIZAAutomaticas` | `ConfirmPayment_20260424_103403` | — |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->
