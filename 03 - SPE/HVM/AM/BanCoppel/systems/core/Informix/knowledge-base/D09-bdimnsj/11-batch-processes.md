# D09 · Mensajería — Procesos Batch y Schedulers

> **Componente:** Informix · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdimnsj` · IBM Informix IDS 14.10 / POWER-AIX
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático)
- Domain Expert — BanCoppel / Mensajería (validación funcional)
- Architect — Application Modernization (diseño target EventBus/AsyncAPI)
- QA Lead — Equivalencia funcional (casos de prueba)

> Secciones `[SME-PENDING]` requieren sesión de validación antes de Etapa 2.
---


## Por qué los procesos batch son invisibles al call graph

Los SPs batch son invocados por un **scheduler externo** (cron AIX, UC4, Control-M, o script shell) — ningún otro SP los llama. Por eso su `fan_in = 0` en el call graph, lo que los hace indistinguibles del código muerto en el análisis estático. La diferencia es crítica: **código muerto = no migrar**, **batch = migrar como job**.

## Resumen

| SP | LOC | Tipo | Frecuencia | Target | Riesgo |
|----|-----|------|-----------|--------|--------|
| `sp_depura_mensajes` | 685 | Purga transaccional | Nocturno | Step Function / Lambda | 🔴 ALTO |
| `sp_suscriptores_act` | 403 | Sync Latinia (PII) | Diario | EventBridge + Lambda | 🟠 ALTO |
| `sp_mover_mensajes` | 252 | Archivado | Nocturno | CronJob + PG partitions | 🟡 MEDIO |
| `sp_genera_reporte_sms` | 247 | Reportería | Diario/Semanal | Glue / Lambda + S3 | 🟢 BAJO |
| `sp_notifica_resultados` | 190 | Notificación resultados | [SME-PENDING] | Lambda | 🟡 MEDIO |
| `sp_movregistroshist` | 101 | Archivado histórico | Nocturno | CronJob | 🟢 BAJO |
| `sp_depura_mnsjr_bitacora_sms` | 139 | Purga logs | Periódico | Lambda + TTL | 🟢 BAJO |
| `sp_monitor_ckpt` | 65 | Heartbeat/Monitoreo | Frecuente | CloudWatch HealthCheck | 🟡 MEDIO |

## Detalle por proceso batch


### `sp_depura_mensajes` (685 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | `pdFecha DATE` |
| Retorna | `CHAR(5) código + VARCHAR(50) mensaje` |
| Tablas afectadas | notif_online_default (DELETE), mnsj_errores (INSERT), mnsj_procesos (INSERT) |
| Frecuencia estimada | [SME-PENDING] — probablemente nocturno o por ventana de mantenimiento |
| Scheduler actual | [SME-PENDING] ¿UC4 / Control-M / cron AIX? |
| Target recomendado | Job Lambda / Step Function o Kubernetes CronJob |
| Riesgo | 🔴 ALTO — COMMIT cada 1,000 rows; en target debe reproducirse idempotencia o usar DELETE con paginación |

Purga la tabla notif_online_default eliminando registros procesados. Usa commit cada 1,000 registros para evitar lock escalation. Registra progreso en mnsj_procesos y errores en mnsj_errores.

### `sp_suscriptores_act` (403 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | `(sin parámetros)` |
| Retorna | `CHAR(5) + CHAR(200) mensaje` |
| Tablas afectadas | Lectura de suscriptores → envío a Latinia API (externa) |
| Frecuencia estimada | Diaria nocturna (inferida — no tiene parámetro de fecha) |
| Scheduler actual | [SME-PENDING] — probablemente UC4 o cron AIX post-cierre |
| Target recomendado | AWS EventBridge Scheduler → Lambda → Latinia API / SNS Pinpoint |
| Riesgo | 🟠 ALTO — contiene datos PII (teléfonos, correos). LFPDPPP: datos personales no pueden salir de MX sin contrato DPA. Verificar si Latinia está en MX. |

Sincroniza suscriptores con Latinia. Genera archivo con datos de clientes (teléfono, email, carrier) y lo envía a la plataforma de mensajería. Última modificación: enero 2024 — proceso activo.

### `sp_mover_mensajes` (252 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | `[SME-PENDING]` |
| Retorna | `[SME-PENDING]` |
| Tablas afectadas | Tabla activa (DELETE) → tabla histórica (INSERT) |
| Frecuencia estimada | [SME-PENDING] — probablemente nocturno |
| Scheduler actual | [SME-PENDING] |
| Target recomendado | Job de archivado con particionamiento por fecha en PostgreSQL |
| Riesgo | 🟡 MEDIO — si la tabla histórica es muy grande, el archivado puede ser lento en el cutover |

Mueve mensajes procesados de la tabla activa a una tabla histórica. Patrón de archivado transaccional.

### `sp_genera_reporte_sms` (247 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | `[SME-PENDING]` |
| Retorna | `[SME-PENDING]` |
| Tablas afectadas | Lectura de 7 tablas, escritura en tabla de reportes |
| Frecuencia estimada | [SME-PENDING] — probable: diario o semanal |
| Scheduler actual | [SME-PENDING] |
| Target recomendado | Job de reportería — candidato a AWS Glue o Lambda con S3 output |
| Riesgo | 🟢 BAJO — proceso de lectura, impacto en migración mínimo |

Genera reporte de SMS enviados. Lee de 7 tablas. Probablemente produce un archivo CSV o inserta en tabla de reportes.

### `sp_movregistroshist` (101 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | `[SME-PENDING]` |
| Retorna | `[SME-PENDING]` |
| Tablas afectadas | Tabla activa → histórico |
| Frecuencia estimada | [SME-PENDING] |
| Scheduler actual | [SME-PENDING] |
| Target recomendado | CronJob + particionamiento PostgreSQL o archivado en S3/Glacier |
| Riesgo | 🟢 BAJO |

Mueve registros a tabla histórica. Patrón de retención de datos.

### `sp_depura_mnsjr_bitacora_sms` (139 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | `[SME-PENDING]` |
| Retorna | `[SME-PENDING]` |
| Tablas afectadas | mnsjr_bitacora_err (DELETE) |
| Frecuencia estimada | [SME-PENDING] |
| Scheduler actual | [SME-PENDING] |
| Target recomendado | Lambda + política de retención CloudWatch Logs |
| Riesgo | 🟢 BAJO |

Purga bitácora de errores SMS. Mantenimiento de tabla de logs.

### `sp_monitor_ckpt` (65 LOC)

| Atributo | Valor |
|----------|-------|
| Parámetros | `[SME-PENDING]` |
| Retorna | `[SME-PENDING]` |
| Tablas afectadas | Lectura de estado + escritura de log de monitoreo |
| Frecuencia estimada | Probablemente cada 5-15 minutos (heartbeat) |
| Scheduler actual | [SME-PENDING] |
| Target recomendado | CloudWatch Health Check o AWS ECS Health Check — NO migrar como SP |
| Riesgo | 🟡 MEDIO — el concepto de "checkpoint Informix" no existe en PostgreSQL; el patrón de monitoreo debe rediseñarse |

Monitoreo de checkpoints del motor Informix. Posiblemente verifica que los procesos de mensajería estén activos.


## Acción crítica: inventario del scheduler AIX

**[SME-PENDING — DBA BanCoppel]** Ejecutar en el servidor AIX:

```bash
# Listar todos los cron jobs del usuario informix:
crontab -u informix -l

# Buscar referencias a sp_depura o sp_suscriptores:
grep -r "sp_depura\|sp_suscriptores\|sp_genera_reporte\|sp_mover" /var/spool/cron/

# Si usan UC4 o Control-M: extraer jobs con filtro "bdimnsj"
```

Sin este inventario, es imposible replicar la calendarización en el target.

## Consideraciones de migración de batch

### 1. sp_depura_mensajes — riesgo de COMMIT parcial

El SP hace `COMMIT WORK` cada 1,000 registros. Si el job falla a mitad, la tabla queda en estado parcialmente purgada. En el target:
- Usar `DELETE ... LIMIT 1000` en un loop idempotente
- Registrar el último secuencial procesado para reanudar
- Agregar DLQ (Dead Letter Queue) para errores

### 2. sp_suscriptores_act — datos PII hacia Latinia

El SP genera un payload con **teléfonos y correos de clientes** y los envía a Latinia. En el target:
- Cifrar en tránsito (TLS 1.2+) y en reposo (KMS)
- Verificar contrato DPA con Latinia (transferencia de datos personales a tercero)
- Implementar tokenización si Latinia opera fuera de MX
- Audit log de cada envío (CNBV / LFPDPPP)

### 3. Ventana de mantenimiento para batch

Los procesos de purga y archivado asumen disponibilidad de la tabla durante la noche. En AWS:
- Coordinar ventanas de mantenimiento con las tablas fuente
- Evitar solapamiento con procesos de replicación CDC (Debezium)

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdimnsj_*.sql + análisis de patrones de nombres y código*

<!-- LOG-DATA-BEGIN -->
## Procesos batch detectados en logs — 2026-04-24
> Fuente: `source/logs/transacciones_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

> Sin patrones batch identificados en los logs para este dominio.
> Indicador: servicios con referencia de timestamp fijo (p. ej. `_20260424_000000`).
<!-- LOG-DATA-END -->
