# D05 · Saldos y Cuentas — Procesos Batch y Schedulers

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdisac` · IBM Informix IDS 14.10 / POWER-AIX
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

| Job | SP principal | Frecuencia confirmada | Riesgo | Fuente |
|-----|-------------|----------------------|--------|--------|
| `RemesasAPPRIZAAutomaticas` | `sp_app_confirmpayment` | ~61,280 calls/día · cada ~20-60 min | ALTO — P655-R003 | Logs 2026-04-24 |
| Otros batch de bdisac | [SME-PENDING] | Requiere inventario scheduler AIX | [SME-PENDING] | crontab -u informix |

## Detalle por proceso batch

### BATCH-D05-01 · RemesasAPPRIZAAutomaticas — Reconciliación APPRIZA

> **Fuente:** `source/logs/transacciones_bus_20260424_*.log` · Fecha: 2026-04-24

| Atributo | Valor |
|----------|-------|
| Nombre en logs | `RemesasAPPRIZAAutomaticas` |
| DSN | `ifx_bdisac_remesas` |
| SP principal | `sp_app_confirmpayment` → APPRIZA (CFPA) |
| SPs auxiliares | `sp_app_recordorder` (graba PENDIENTE), `sp_app_getorder` (consulta estado) |
| Volumen producción | 61,280 llamadas/día · 56,117 exitosas · 5,163 fallidas (8.7%) |
| Scheduler actual | [SME-PENDING] — cron AIX u orquestador externo; timing irregular en logs |
| Target AWS | AWS EventBridge Scheduler + Step Functions |

**Comportamiento observado en producción (transacción `id=714261829804`, 2026-04-24):**

```
18:03 — excepción en ConfirmPayment.java:179
       → sp_app_recordorder registra PENDIENTE
19:15 — batch encuentra PENDIENTE → reintenta → APPRIZA 9999
19:45 — reintenta → APPRIZA 9999
20:03 — reintenta → APPRIZA 9999
...  (13 reintentos durante 5+ horas)
23:59 — transacción sin resolver · estado final: PENDIENTE indefinido
```

**Defectos del diseño actual:**
- Sin `max_retries` — ciclo infinito
- Sin circuit breaker — no detecta degradación de APPRIZA
- Sin backoff exponencial
- Sin notificación al cliente ni devolución automática tras N fallos
- UUID de sesión fijo `22e4e9ee-32ea-484e-b89f-2573549bc625` en todas las llamadas

**Diseño target recomendado:**
```
EventBridge Scheduler → Step Functions
  Retry: máx 3 intentos, backoff exponencial (1min → 5min → 30min)
  On max_retries:
    → INSERT INTO reconciliacion_remesas (estado='PENDIENTE_MANUAL')
    → NotificaciónCliente (SMS/push)
    → Flag regulatorio CNBV (Banxico Circular 14/2017 — plazo 2 días hábiles)
  Circuit breaker (Resilience4j): 50% errores en 60s → OPEN; half-open tras 5min
```



## Acción crítica: inventario del scheduler AIX

**[SME-PENDING — DBA BanCoppel]** Ejecutar en el servidor AIX:

```bash
# Listar todos los cron jobs del usuario informix:
crontab -u informix -l

# Buscar referencias a SPs del dominio bdisac:
grep -r "bdisac" /var/spool/cron/ 2>/dev/null

# Si usan UC4 / Control-M: extraer jobs con filtro "bdisac"
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
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdisac_*.sql (análisis estático de 58 archivos SQL) · análisis de patrones de nombres + código*

<!-- LOG-DATA-BEGIN -->
## Procesos batch detectados en logs — 2026-04-24
> Fuente: `source/logs/transacciones_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

| Servicio | Referencia muestra | Hora primer disparo |
|----------|-------------------|---------------------|
| `RemesasAPPRIZAAutomaticas` | `GetPayment_20260424_184342` | — |
| `RemesasBTSAutomaticas` | `payc_recupera_20260424_084553` | — |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->
