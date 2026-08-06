# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Observabilidad y Runbook

> **Componente:** BCOPCore · SPE-AM-001 · OPERATE Phase
> **Microservicio target:** LideService / PldBatchService
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03
> **Inventario:** 101 SPs · 5 en callgraph · 96 aislados (batch/regulatorio)
> **Motor regulatorio:** LIDE + PLD + SAT + CNBV/UIF + SHCP

---

**SME responsable:**
- SRE & AIOps (`SME/Technology/SRE & AIOps/`)
- Cybersecurity (alertas de anomalía en datos PLD)
- Domain Expert BanCoppel / Área de Cumplimiento (escalación regulatoria)
- Cloud Architect — AWS Banking

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.
> `[COMPLIANCE-SIGN-OFF-REQUIRED]` = cualquier cambio en umbrales de alerta del motor PLD requiere aprobación de Cumplimiento.

---

## Arquitectura de observabilidad

```
[D01-bdicnweb]   [D02-bdinteg]   [D03-bdicred]
        │                │               │
        └────────────────┼───────────────┘
                         ▼
               [LideService (ECS Fargate)]
                    │  structured logs (JSON — sin PII)
                    ▼
             [CloudWatch Logs]
                    │
                    ├── [CloudWatch Insights]
                    ├── [X-Ray — Service Map]
                    ├── [CloudWatch Metrics: bancoppel.bdilide.*]
                    └── [CloudWatch Alarms] → [SNS] → [PagerDuty + Teams Compliance]

[EventBridge Scheduler]
        │
        ▼
[PldBatchService (ECS Fargate)]
        │  structured logs (JSON — sin montos ni RFC en logs)
        ▼
[CloudWatch Logs: /ecs/pld-batch-service]
        │
        └── [Step Functions Execution History] → dashboard de estado de batch

Namespace custom: bancoppel.bdilide.*
Namespace batch:  bancoppel.bdilide.batch.*
```

---

## Métricas clave (Golden Signals)

### 1. Latency — Consulta LIDE (ruta crítica transaccional)

| Operación | Métrica de latencia | Métrica de errores | SLO |
|-----------|--------------------|--------------------|:---:|
| Consulta LIDE por numCte | `bancoppel.bdilide.lide.consulta.latency` | `bancoppel.bdilide.lide.consulta.errors` | < 50ms p99 |
| `sp_checacurp` | `bancoppel.bdilide.checacurp.latency` | `bancoppel.bdilide.checacurp.errors` | < 50ms p99 |
| Consulta Buró de Crédito | `bancoppel.bdilide.buro.consulta.latency` | `bancoppel.bdilide.buro.consulta.errors` | `[SME-PENDING]` ms |

> `[SME-PENDING]` — Los SLOs de latencia deben validarse con el QA Lead una vez obtenido el baseline real del sistema legacy.

### 2. Traffic (throughput)

| Métrica | Namespace | Descripción |
|---------|-----------|-------------|
| `bancoppel.bdilide.lide.consultas.total` | Custom | Total consultas LIDE por minuto |
| `bancoppel.bdilide.lide.resultado.en_lide` | Custom | Clientes encontrados en LIDE (tasa de detección) |
| `bancoppel.bdilide.batch.ejecutor_diario.invocaciones` | Custom | Invocaciones del ejecutor diario |
| `bancoppel.bdilide.batch.acumulacion.registros_procesados` | Custom | Registros procesados en acumulación PLD |
| `bancoppel.bdilide.sat.archivos_generados` | Custom | Archivos SAT generados por período |

### 3. Errors

| Métrica | Umbral de alarma | Severidad |
|---------|-----------------|:--------:|
| `bancoppel.bdilide.lide.consulta.errors` | > 0.1% en 5 min | 🟠 WARNING |
| `bancoppel.bdilide.lide.consulta.errors` | > 1% en 1 min | 🔴 CRÍTICO |
| `bancoppel.bdilide.servicio_no_disponible` | > 0 (DENY por timeout) | 🔴 CRÍTICO — escalar inmediatamente |
| `bancoppel.bdilide.batch.ejecutor_diario.errors` | > 0 | 🔴 CRÍTICO |
| `bancoppel.bdilide.batch.acumulacion.errors` | > 0 | 🔴 CRÍTICO |
| `bancoppel.bdilide.sat.archivo.error` | > 0 | 🔴 CRÍTICO — reporte regulatorio en riesgo |
| `bancoppel.bdilide.reporte_regulatorio.error` | > 0 | 🔴 CRÍTICO — escalar a Cumplimiento |
| Aurora `DatabaseConnections` | > 80% del max | 🟠 WARNING |

> **Regla de falla segura:** si el LideService no responde, los callers deben recibir DENY. La métrica `bancoppel.bdilide.servicio_no_disponible > 0` es el indicador más crítico del sistema — cualquier valor > 0 debe escalarse inmediatamente al Área de Cumplimiento.

### 4. Saturation

| Recurso | Métrica | Umbral |
|---------|---------|:------:|
| LideService ECS | `CpuUtilization` | > 80% → scale out |
| PldBatchService ECS | `MemoryUtilization` | > 85% durante el batch |
| Aurora connections | `DatabaseConnections / MaxConnections` | > 80% |
| S3 archivos regulatorios | espacio utilizado | Alerta si aproxima el 80% del presupuesto de almacenamiento |

---

## Patrones de carga esperados

| Ventana | Descripción | Impacto en bdilide |
|---------|-------------|-------------------|
| **Peak transaccional:** 10:00–14:00 CDMX | Horario bancario; consultas LIDE frecuentes desde D01/D02/D03 | LideService bajo carga máxima transaccional |
| **Batch nocturno:** 22:00–04:00 CDMX | Ejecutor diario + acumulación PLD | PldBatchService bajo carga máxima; LideService inactivo |
| **Batch mensual SAT:** días 1-5 del mes | Generación de informe SAT | PldBatchService con carga alta por generación de archivos |

---

## Runbook de incidentes

### INC-D15-01: LideService no disponible — falla segura activa

```
CONTEXTO:
  - Todos los callers (D01, D02, D03) reciben DENY en consultas LIDE
  - El LideService está activo como falla segura (no error real de LIDE)
  - Impacto: nuevos clientes no pueden completar onboarding; operaciones bloqueadas
  - Criticidad: CRÍTICO — escalar inmediatamente

DETECTAR:
  - Alarma: bancoppel.bdilide.servicio_no_disponible > 0 en 1 min
  - X-Ray: timeouts en el path D01/D02/D03 → LideService
  - Logs ECS: health check failures o OOM en LideService

DIAGNOSTICAR:
  1. Verificar estado del ECS Service:
       aws ecs describe-services --cluster bcop-cluster --services lide-service
     Confirmar que hay instancias RUNNING (mínimo 2)

  2. Verificar conexión a Aurora:
       CloudWatch Metric: DatabaseConnections bdilide-aurora
       Si > 80% del máximo: el pool de conexiones está saturado

  3. Revisar X-Ray para identificar el tramo que falla:
       Consulta Aurora → red → LideService → caller

  4. Verificar que los certificados mTLS no expiraron:
       aws acm describe-certificate --certificate-arn [arn-lide-cert]

RESOLVER:
  A. Si ECS tasks unhealthy: forzar redeployment
       aws ecs update-service --force-new-deployment --service lide-service
  B. Si Aurora saturado: escalar la instancia o aumentar el pool de conexiones
  C. Si certificado mTLS expirado: renovar y redeployar el LideService
  D. Si no resuelve en 5 minutos: escalar a Área de Cumplimiento (impacto regulatorio)

ESCALAR: SRE Lead → Director de Cumplimiento BanCoppel
RTO: < 5 min (impacto en operaciones de clientes + riesgo regulatorio)
NOTA REGULATORIA: Documentar todos los DENY emitidos durante la falla para reporte a Cumplimiento.
```

### INC-D15-02: Batch PLD fallido — ejecutor_diario no completó

```
CONTEXTO:
  - El batch nocturno no terminó antes de las 04:00 CDMX
  - sl_procesos muestra status incompleto o error en el ejecutor_diario
  - Impacto: fechas de proceso inconsistentes entre bdilide, bdicheq y bdicred
  - Criticidad: CRÍTICO — afecta integridad de datos regulatorios

DETECTAR:
  - Alarma: bancoppel.bdilide.batch.ejecutor_diario.errors > 0
  - Step Functions: execution en estado FAILED
  - CloudWatch Logs: errores en /ecs/pld-batch-service

DIAGNOSTICAR:
  1. Revisar el Step Functions execution history para identificar el paso que falló
  2. Verificar en sl_procesos el estado del proceso:
       SELECT proceso, status, fecha_inicio, fecha_fin
       FROM sl_procesos
       WHERE fecha_proceso = CURRENT DATE
       ORDER BY fecha_inicio DESC;
  3. Verificar si los dominios dependientes estaban disponibles:
       - bdinteg (si_fechas, si_cliente)
       - bdicheq (sc_fechas, sc_movdia)
       - bdicred (sd_fechas, sd_movhis, sd_movdia)

RESOLVER:
  A. Identificar el dominio que falló y coordinarlo con el SRE del dominio correspondiente
  B. Una vez restaurado el dominio dependiente: reejecutar el ejecutor_diario manualmente
       POST /pld/v1/batch/ejecutor-diario
       {"fechaProceso": "[fecha]", "cveUsuario": "SRE-MANUAL"}
  C. Verificar que sl_procesos muestra éxito después del re-run
  D. Notificar al Área de Cumplimiento del incidente y la resolución

ESCALAR: SRE Lead + Domain Expert BanCoppel + Director de Cumplimiento
RTO: < 2 horas (el batch debe completar antes de las 06:00 CDMX para no afectar el día siguiente)
NOTA REGULATORIA: Si el batch no puede completarse el mismo día, Cumplimiento debe evaluar si hay obligación de reportar el incidente.
```

### INC-D15-03: Fallo en reporte regulatorio SAT/CNBV/SHCP

```
CONTEXTO:
  - sp_cargainformesat o sp_cargaresultadosat fallaron o generaron archivo incorrecto
  - El reporte no fue enviado al regulador dentro del plazo
  - Criticidad: MÁXIMO — incumplimiento regulatorio potencial

DETECTAR:
  - Alarma: bancoppel.bdilide.reporte_regulatorio.error > 0
  - Alarma: bancoppel.bdilide.sat.archivo.error > 0
  - Step Functions: ejecución de batch SAT en estado FAILED

DIAGNOSTICAR:
  1. Verificar el archivo generado en S3:
       aws s3 ls s3://pld-regulatory-prod/sat/consulta/[periodo]/
       Si el archivo no existe: el SP no llegó a generar el archivo
       Si el archivo existe: verificar que el formato es correcto (comparar con un archivo anterior)

  2. Revisar CloudWatch Logs del PldBatchService para el error específico

  3. Verificar sl_procesos para el status del proceso SAT

RESOLVER:
  A. Corto plazo: notificar INMEDIATAMENTE al Área de Cumplimiento
  B. Intentar re-generar el archivo SAT:
       POST /pld/v1/sat/informe {"periodo": "[AAAAMM]"}
  C. Si el re-intento falla: escalar al DBA IBM Informix para ejecutar el SP
     directamente en el sistema legacy como medida de emergencia
  D. Una vez resuelto: enviar el archivo al SAT por el canal alternativo aprobado por Cumplimiento
  E. Documentar el incidente para el informe regulatorio requerido

ESCALAR: Director de Cumplimiento BanCoppel → SAT/CNBV/SHCP (según corresponda)
RTO: Antes del plazo regulatorio del período (confirmar plazo exacto con Cumplimiento)
NOTA CRÍTICA: En ningún caso enviar un archivo con datos incorrectos al regulador — es mejor un reporte tardío que un reporte erróneo.
```

### INC-D15-04: Divergencia de resultados LIDE en parallel-run

```
CONTEXTO:
  - Durante el parallel-run, el target retornó un resultado diferente al legacy
  - Un cliente que el legacy clasifica como LIBRE, el target clasifica como EN_LIDE (o viceversa)
  - Criticidad: MÁXIMO — cualquier divergencia es criterio de rollback

DETECTAR:
  - Sistema de comparación del parallel-run reporta divergencia
  - Métrica: bancoppel.bdilide.parallel_run.divergencias > 0

RESOLVER:
  A. ROLLBACK INMEDIATO: AppConfig feature flag al 0% (100% tráfico al legacy)
  B. Aislar el caso de divergencia: obtener el numCte y el escenario exacto
  C. Investigar en el código fuente:
       source/BCOPCore/informix/[sp-consulta-lide].sql
       vs. implementación Java del LideService
  D. Identificar la regla específica que produce el resultado diferente
  E. Corregir el target y volver a probar con golden master antes de reactivar

ESCALAR: QA Lead + Director de Cumplimiento + Arquitecto Principal BCOPCore
CRITERIO DE REANUDACIÓN: Sign-off del QA Lead + Cumplimiento que confirmen la corrección y re-validación.
NOTA: El parallel-run DEBE REINICIARSE desde cero después de una corrección — no se acumulan los días previos.
```

---

## Logs estructurados — formato obligatorio

```json
{
  "timestamp": "2026-08-03T22:30:00.000-06:00",
  "level": "INFO",
  "service": "lide-service",
  "traceId": "1-xxx-xxx",
  "spanId": "xxx",
  "operation": "consulta-lide",
  "domain": "bdilide",
  "wave": "Wave 4",
  "callingSystem": "bdicnweb",
  "durationMs": 23,
  "outcome": "LIBRE",
  "requestId": "uuid"
}
```

> **Prohibición absoluta:** nunca incluir `numCte`, `rfc`, `curp`, montos de operaciones ni el contenido del historial PLD en los logs. Solo el `requestId` y `outcome` (LIBRE/EN_LIDE/ERROR). La LFPIORPI Art. 30 prohíbe la divulgación de la información PLD. `[COMPLIANCE-SIGN-OFF-REQUIRED]`

---

## CloudWatch Dashboard — widgets obligatorios

```json
[
  {"title": "Consultas LIDE — latencia p50/p95/p99", "type": "metric",
    "metrics": [["bancoppel/bdilide", "lide.consulta.latency.p50"],
                ["bancoppel/bdilide", "lide.consulta.latency.p99"]]},
  {"title": "Servicio no disponible (DENY por falla segura)", "type": "metric",
    "metrics": [["bancoppel/bdilide", "servicio_no_disponible"]]},
  {"title": "Tasa de detección LIDE (clientes EN_LIDE / total)", "type": "metric",
    "metrics": [["bancoppel/bdilide", "lide.resultado.en_lide"],
                ["bancoppel/bdilide", "lide.consultas.total"]]},
  {"title": "Estado batch PLD nocturno", "type": "metric",
    "metrics": [["bancoppel/bdilide", "batch.ejecutor_diario.estado"],
                ["bancoppel/bdilide", "batch.acumulacion.registros_procesados"]]},
  {"title": "Reportes regulatorios (SAT/CNBV/SHCP)", "type": "metric",
    "metrics": [["bancoppel/bdilide", "sat.archivos_generados"],
                ["bancoppel/bdilide", "reporte_regulatorio.error"]]},
  {"title": "Aurora connections bdilide", "type": "metric",
    "metrics": [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "bdilide-aurora"]]},
  {"title": "ECS LideService — CPU/Memory", "type": "metric",
    "metrics": [["AWS/ECS", "CpuUtilization", "ServiceName", "lide-service"],
                ["AWS/ECS", "MemoryUtilization", "ServiceName", "lide-service"]]},
  {"title": "Divergencias parallel-run (durante período de parallel-run)", "type": "metric",
    "metrics": [["bancoppel/bdilide", "parallel_run.divergencias"]]},
  {"title": "X-Ray Service Map PLD", "type": "trace_map"}
]
```

---

*Generado: SRE & AIOps · 2026-08-03 · `[SME-PENDING]` umbrales SLO requieren validación con baseline real del legacy.*
*NOTA REGULATORIA: Este runbook debe ser revisado por el Área de Cumplimiento de BanCoppel antes de su uso en producción.*
