# D02 · bdinteg — Integración y Autenticación — Observabilidad y Runbook

> **Componente:** BCOPCore · SPE-AM-001 · OPERATE Phase
> **Base de datos:** bdinteg (Integración y Autenticación)
> **Wave:** 5 · Riesgo: **CRÍTICO**
> **Última actualización:** 2026-07-31

---

**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático y equivalencias)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- Cloud Architect — AWS Banking (arquitectura target y servicios AWS)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- Core Banking Transformation (ACL design y API contracts)
- Industry Banking / Domain Expert BanCoppel (validación funcional — autenticación y gateway)
- Cybersecurity (PII, CNBV, LFPDPPP, PCI-DSS — datos de huella biométrica)
- SRE & AIOps (observabilidad y runbooks)
- Data & ML — Data Architect (migración de datos, CDC Debezium)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.

---

## Perfil del dominio

| Atributo | Valor |
|----------|-------|
| SPs totales | 220 |
| LOC totales | 464,892 |
| Ocurrencias MONEY | 18,511 |
| Referencias cross-DB | 787 |
| God procedure — LOC | `sysbldsqltextin` (213,929 LOC, 134 callees) |
| God procedure — callers | `sp_cnsif_consprodcte` (6,526 LOC, 205 callers) |
| Cross-DB primarios | bdicheq (194 refs), bdicred (165 refs), bdimnsj (79 refs) |
| Sistemas llamadores (logs) | OFI_WEB, AU_PPCOPPEL, SOBRES_DIGITALES |
| SPs observados en logs | `sp_consulta_cte_huella`, `sp_obtparamsorteo`, `sp_ws_valida_cotel` |

> **Nota de fuente:** Los perfiles completos de cada SP se deben validar contra
> `source/BCOPCore/informix/{sp_name}.sql` antes de confirmar umbrales de alarma
> en producción. Con 213,929 LOC, `sysbldsqltextin` requiere revisión de Specialist
> Informix SPL Analysis antes de cualquier decisión de migración.

---

## Patrones de carga validados (logs de producción)

| Ventana | Horario CDMX | Volumen aprox. | Sistemas activos |
|---------|-------------|----------------|-----------------|
| Pico operativo | 10:00 – 14:00 | 80 – 216 MB/hr | OFI_WEB, AU_PPCOPPEL, SOBRES_DIGITALES |
| Valle nocturno | 02:00 – 06:00 | 4 – 7 MB/hr | Procesos batch residuales |
| Ventana batch | 22:00 – 02:00 | Variable | Cierre contable, conciliaciones, reportes nocturnos |

bdinteg actúa como **gateway de autenticación central**: durante el pico de 10:00–14:00,
AU_PPCOPPEL enruta toda validación de sesión de cajeros OFI_WEB a través de
`sp_consulta_cte_huella`. Una falla en ese rango horario tiene impacto transversal inmediato
en todos los sistemas dependientes.

---

## Arquitectura de observabilidad

```
[bdinteg — Auth Gateway Service (Lambda/ECS)]
        │  structured logs (JSON)
        ▼
[CloudWatch Logs]  →  [CloudWatch Insights]  →  [Dashboard bancoppel.bdinteg]
        │
        ├─ [X-Ray traces]  →  [Service Map]  →  [Anomaly detection]
        │
        └─ [CloudWatch Metrics]  →  [Alarms]  →  [SNS → PagerDuty/Teams]

Namespace raíz: bancoppel.bdinteg.*

Fuentes adicionales:
  - Aurora (bdinteg cluster):  AWS/RDS DatabaseConnections, FreeLocalStorage
  - MSK (Kafka topic bdinteg.events):  SumOffsetLag
  - Cross-DB traces:  X-Ray spans hacia bdicheq, bdicred, bdimnsj
```

---

## Métricas clave (Golden Signals)

### 1. Latency — SPs principales

| SP (origen Informix) | Métrica de latencia | Métrica de errores | SLO |
|---------------------|--------------------|--------------------|-----|
| `sp_consulta_cte_huella` | `bancoppel.bdinteg.consulta_cte_huella.latency` | `bancoppel.bdinteg.consulta_cte_huella.errors` | [SME-PENDING] ms |
| `sp_cnsif_consprodcte` | `bancoppel.bdinteg.cnsif_consprodcte.latency` | `bancoppel.bdinteg.cnsif_consprodcte.errors` | [SME-PENDING] ms |
| `sysbldsqltextin` | `bancoppel.bdinteg.sysbldsqltextin.latency` | `bancoppel.bdinteg.sysbldsqltextin.errors` | [SME-PENDING] ms |
| `sp_obtparamsorteo` | `bancoppel.bdinteg.obtparamsorteo.latency` | `bancoppel.bdinteg.obtparamsorteo.errors` | [SME-PENDING] ms |
| `sp_ws_valida_cotel` | `bancoppel.bdinteg.ws_valida_cotel.latency` | `bancoppel.bdinteg.ws_valida_cotel.errors` | [SME-PENDING] ms |

### 2. Traffic (throughput)

| Métrica | Namespace | Descripción |
|---------|-----------|------------|
| `Invocations` | `AWS/Lambda` | Número total de invocaciones al gateway bdinteg |
| `ConcurrentExecutions` | `AWS/Lambda` | Ejecuciones concurrentes (alerta si > 80% del límite) |
| `bancoppel.bdinteg.requests.total` | Custom | Total de requests al microservicio bdinteg |
| `bancoppel.bdinteg.auth.requests` | Custom | Requests de autenticación vía AU_PPCOPPEL |

### 3. Errors

| Métrica | Umbral de alarma | Severidad |
|---------|-----------------|----------|
| `Errors` (Lambda) | > 0.1% en 5 min | WARNING |
| `Throttles` (Lambda) | > 0 en 1 min | CRITICAL |
| `bancoppel.bdinteg.errors.l4` (divergencias financieras MONEY) | > 0 | CRITICAL (rollback inmediato) |
| Aurora `DatabaseConnections` | > 80% del max | WARNING |
| Aurora `FreeLocalStorage` | < 20% | WARNING |
| `bancoppel.bdinteg.auth.failures` | > 1% en 5 min | CRITICAL (cascada de autenticación) |
| `bancoppel.bdinteg.serial.gap` | cualquier gap detectado | CRITICAL (SERIAL exhaustion) |

### 4. Saturation

| Recurso | Métrica | Umbral |
|---------|---------|--------|
| Lambda concurrencia | `ConcurrentExecutions / ReservedConcurrency` | > 80% → scale review |
| Aurora connections | `DatabaseConnections / MaxConnections` | > 80% → connection pooling |
| MSK (Kafka) lag | `SumOffsetLag` | > 10,000 mensajes → investigate |
| Cross-DB fan-out | `bancoppel.bdinteg.crossdb.latency` | [SME-PENDING] ms → investigate bdicheq/bdicred |

---

## SLOs del dominio

> `[SME-PENDING]` — Los SLOs definitivos requieren baseline de QA Lead con carga real de pico (10:00–14:00 CDMX).

| Indicador | SLO target | Error budget | Estado |
|-----------|------------|--------------|--------|
| Disponibilidad auth gateway | [SME-PENDING] % | [SME-PENDING] min/mes | Pendiente |
| Latencia p99 `sp_consulta_cte_huella` | [SME-PENDING] ms | — | Pendiente |
| Latencia p99 `sysbldsqltextin` (god SP) | [SME-PENDING] ms | — | Pendiente |
| Divergencias financieras MONEY | 0 eventos/mes | — | Pendiente |

---

## CloudWatch Dashboard — widgets obligatorios

```json
[
  {"title": "Auth latencia p50/p95/p99", "type": "metric",
    "metrics": [["bancoppel/bdinteg", "consulta_cte_huella.latency.p50"],
                ["bancoppel/bdinteg", "consulta_cte_huella.latency.p99"]]},
  {"title": "sysbldsqltextin latencia (god SP — 213,929 LOC)", "type": "metric",
    "metrics": [["bancoppel/bdinteg", "sysbldsqltextin.latency.p99"],
                ["bancoppel/bdinteg", "sysbldsqltextin.errors"]]},
  {"title": "Error rate + auth failures + MONEY divergencias", "type": "metric",
    "metrics": [["bancoppel/bdinteg", "errors.total"],
                ["bancoppel/bdinteg", "auth.failures"],
                ["bancoppel/bdinteg", "errors.l4"]]},
  {"title": "Throughput por sistema llamador", "type": "metric",
    "metrics": [["bancoppel/bdinteg", "requests.ofi_web"],
                ["bancoppel/bdinteg", "requests.au_ppcoppel"],
                ["bancoppel/bdinteg", "requests.sobres_digitales"]]},
  {"title": "Aurora connections bdinteg", "type": "metric",
    "metrics": [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "bdinteg-aurora"]]},
  {"title": "Cross-DB latency (bdicheq 194 / bdicred 165 / bdimnsj 79)", "type": "metric",
    "metrics": [["bancoppel/bdinteg", "crossdb.bdicheq.latency"],
                ["bancoppel/bdinteg", "crossdb.bdicred.latency"],
                ["bancoppel/bdinteg", "crossdb.bdimnsj.latency"]]},
  {"title": "X-Ray Service Map", "type": "trace_map"}
]
```

---

## Runbook de incidentes

### INC-D02-01: Cascada de autenticación — falla de `sp_consulta_cte_huella`

```
TRIGGER:
  - Alarma bancoppel.bdinteg.auth.failures > 1% en 5 min
  - O: bancoppel.bdinteg.consulta_cte_huella.errors supera umbral
  - O: reporte operativo de cajeros OFI_WEB sin poder autenticar clientes

IMPACTO:
  bdinteg es el gateway central de autenticación. La falla de sp_consulta_cte_huella
  bloquea toda sesión nueva de cajero en OFI_WEB y todas las validaciones de
  AU_PPCOPPEL. SOBRES_DIGITALES también queda sin auth. El impacto es inmediato
  y transversal a los tres sistemas llamadores.

DIAGNOSTICAR:
  1. CloudWatch Insights — filtrar los últimos 15 min por errores del SP:
       fields @timestamp, @message
       | filter operation = "sp_consulta_cte_huella" and outcome = "ERROR"
       | sort @timestamp desc | limit 50

  2. Digital Brain — obtener perfil del SP y sus callers actuales:
       brain.sp('sp_consulta_cte_huella')
       brain.callers_of('sp_consulta_cte_huella')
       # Confirmar cuántos callers activos existen y su fan_in; cuantificar el blast radius

  3. X-Ray — determinar si el error viene del SP propio o de una dependencia cross-DB:
       bdinteg tiene 787 llamadas cross-DB; verificar si bdicheq (194) o bdicred (165)
       están degradados y son la causa raíz real

  4. Aurora bdinteg — verificar DatabaseConnections:
       Si > 80%: hay saturación de pool; sp_consulta_cte_huella no consigue conexión

  5. Fuente del SP:
       source/BCOPCore/informix/sp_consulta_cte_huella.sql
       Validar parámetros de entrada, condiciones de error documentadas y
       lógica de verificación de huella biométrica con Specialist Informix SPL Analysis.

RESOLVER:
  A. Si error de conexión Aurora (DatabaseConnections > 80%):
       - Aumentar max_connections vía Parameter Group temporal
       - Activar RDS Proxy si no está activo
       - Notificar a DBA IBM Informix IDS y Cloud Architect AWS

  B. Si error de lógica en el SP (excepción Informix propagada):
       - Rollback de tráfico: AppConfig feature flag a 0% → tráfico vuelve a Informix legacy
       - Notificar: Specialist Informix SPL Analysis + QA Lead + Domain Expert BanCoppel
       - No intentar fix en producción sin validación contra source/

  C. Si la causa raíz es degradación cross-DB (bdicheq o bdicred no responden):
       - Activar circuit-breaker en la capa de integración de bdinteg
       - Seguir runbook INC-D04 (bdicheq) o INC-D03 (bdicred) según corresponda

ESCALAR si no resuelve en 15 min: SRE Lead + Domain Expert BanCoppel + Cybersecurity
(sp_consulta_cte_huella maneja datos de huella biométrica — posible alcance LFPDPPP)
RTO target: < 15 min (gateway de auth — impacto inmediato en operación de cajeros)
```

---

### INC-D02-02: Timeout en `sysbldsqltextin` — god SP de 213,929 LOC

```
TRIGGER:
  - Alarma bancoppel.bdinteg.sysbldsqltextin.latency.p99 supera umbral
  - O: bancoppel.bdinteg.sysbldsqltextin.errors > 0
  - O: X-Ray muestra span de sysbldsqltextin consumiendo > 80% del trace total

CONTEXTO:
  sysbldsqltextin tiene 213,929 LOC y llama directamente a 134 callees.
  Es el SP de mayor tamaño en todo D02. Un timeout en él paraliza su árbol
  completo de dependencias downstream. Su comportamiento bajo carga de pico
  (10:00–14:00 CDMX, 80–216 MB/hr) aún no ha sido validado en entorno cloud.

DIAGNOSTICAR:
  1. Digital Brain — obtener los 134 callees y evaluar el blast radius:
       brain.callees_of('sysbldsqltextin', limit=134)
       # Identificar cuáles callees tienen fan_in alto; son los de mayor cascada

  2. Digital Brain — obtener perfil y reglas del SP:
       brain.sp('bdinteg:sysbldsqltextin')
       brain.rules_of_sp('sysbldsqltextin')
       # Las reglas pueden revelar qué rama de la lógica de 213,929 LOC se está ejecutando

  3. X-Ray — localizar en qué sub-tramo interno del SP ocurre el timeout:
       Expandir el span de sysbldsqltextin y revisar los sub-spans generados
       por sus callees; el más largo es el cuello de botella primario

  4. Aurora bdinteg — verificar lock contention en las tablas base del SP:
       CloudWatch DB Load → wait events durante la ventana del incidente
       Performance Insights → top SQL statements por DB load

  5. Verificar ventana horaria del incidente:
       - Si ocurre en 22:00–02:00 (batch window): puede haber competencia con
         procesos de cierre por recursos de Aurora; coordinar con equipo de batch
       - Si ocurre en 10:00–14:00 (pico): el volumen de 80–216 MB/hr puede estar
         saturando las tablas base del SP

  6. Fuente del SP:
       source/BCOPCore/informix/sysbldsqltextin.sql
       Con 213,929 LOC, buscar las primeras secciones de lógica condicional que
       puedan actuar como cortocircuito en condiciones de error.
       Coordinar revisión con Specialist Informix SPL Analysis antes de cualquier
       intervención en producción.

RESOLVER:
  A. Si timeout por scan completo de tabla grande sin índice adecuado:
       - Identificar la tabla en Aurora Performance Insights
       - Agregar índice si el análisis de fuente lo confirma como seguro
       - Validar con DBA IBM Informix IDS antes de aplicar en producción

  B. Si timeout por lock contention (otra sesión bloquea tablas):
       - Identificar sesión bloqueante en Aurora Performance Insights
       - Matar sesión bloqueante solo con autorización explícita de DBA IBM Informix IDS
       - Activar RDS Proxy con connection multiplexing para reducir contención futura

  C. Si el SP requiere refactoring antes de que la migración sea viable:
       - Rollback de tráfico a Informix legacy vía AppConfig feature flag
       - Crear tarea de refactoring en backlog con Specialist Informix SPL Analysis
       - Documentar el escenario de falla como caso de prueba prioritario en el golden master

ESCALAR si no resuelve en 30 min: SRE Lead + Specialist Informix SPL Analysis + Cloud Architect AWS
RTO target: < 30 min (134 callees downstream quedan bloqueados durante el timeout)
```

---

### INC-D02-03: SERIAL exhaustion — brecha de IDs en rollback masivo

```
TRIGGER:
  - Alarma bancoppel.bdinteg.serial.gap detectada en Aurora
  - O: errores de inserción con código de violación de unicidad / secuencia en logs
  - O: alerta post-batch: conteo de registros insertados no coincide con rangos de
    SERIAL esperados para la noche (ventana 22:00–02:00)

CONTEXTO:
  bdinteg tiene 4,448 ocurrencias del tipo SERIAL en su schema Informix.
  En Informix, un SERIAL no recicla IDs después de un ROLLBACK — el gap queda
  permanentemente consumido. En un rollback masivo durante el batch nocturno,
  los gaps acumulados pueden agotar el rango disponible y generar colisiones en
  inserciones concurrentes durante el pico siguiente (10:00–14:00).
  Con 18,511 campos MONEY en el dominio, una colisión de IDs puede corromper
  registros financieros sin señal de error explícita.

DIAGNOSTICAR:
  1. Digital Brain — identificar SPs de bdinteg que realizan INSERTs con SERIAL:
       brain.sps_in_domain('D02')
       # Filtrar SPs con operaciones INSERT; cruzar con schema de columnas SERIAL
       # Priorizar los que tienen mayor fan_in (más llamadores)

  2. Aurora bdinteg — verificar el estado de las secuencias equivalentes:
       SELECT sequence_name, last_value, max_value,
              ROUND(last_value * 100.0 / max_value, 2) AS pct_used
       FROM information_schema.sequences
       WHERE sequence_schema = 'bdinteg'
       ORDER BY pct_used DESC;
       # Si pct_used > 90% en cualquier secuencia: riesgo inmediato de overflow

  3. CloudWatch Logs — buscar errores de inserción por colisión de clave:
       fields @timestamp, @message
       | filter @message like /duplicate key/
            or @message like /serial overflow/
            or @message like /unique constraint/
       | sort @timestamp desc | limit 100

  4. Revisar log del batch de la noche anterior (22:00–02:00):
       Cuántos ROLLBACKs ocurrieron, en qué SPs, y calcular el gap acumulado
       resultante para las secuencias afectadas

  5. Fuente del schema:
       source/BCOPCore/informix/  — buscar sentencias CREATE TABLE con SERIAL
       Validar con DBA IBM Informix IDS qué tablas críticas de bdinteg usan SERIAL
       y si ya existe una estrategia documentada de migración a BIGSERIAL o
       secuencia equivalente en Aurora PostgreSQL.

RESOLVER:
  A. Si riesgo de overflow (pct_used > 90% en secuencia crítica):
       - Coordinar con DBA IBM Informix IDS y Cloud Architect AWS
       - En Aurora PostgreSQL: ALTER SEQUENCE <nombre> RESTART WITH <nuevo_valor>
       - En Informix legacy (si aún activo): reseed en ventana de mantenimiento
         coordinada con equipo de operaciones BanCoppel
       - Registrar la intervención en el risk register con fecha y valores aplicados

  B. Si ya hay colisión de IDs en producción (inserción fallida por duplicate key):
       - Rollback inmediato de tráfico a Informix legacy vía AppConfig feature flag
       - Detener inserciones concurrentes hasta resolver la secuencia corrupta
       - Notificar: DBA IBM Informix IDS + QA Lead + Domain Expert BanCoppel + Program Manager

  C. Prevención a largo plazo:
       - Migrar todas las 4,448 ocurrencias SERIAL a BIGSERIAL o UUID en el schema
         target de Aurora; documentar como deuda técnica prioritaria
       - Agregar alarma proactiva en CloudWatch cuando pct_used > 80% en cualquier
         secuencia del dominio bdinteg
       - Incluir verificación de SERIAL gaps en el checklist de cierre de batch nocturno

ESCALAR si no resuelve en 20 min: DBA IBM Informix IDS + SRE Lead + Program Manager
RTO target: < 20 min (18,511 campos MONEY en riesgo de inconsistencia de datos)
```

---

## Logs estructurados — formato obligatorio

```json
{
  "timestamp": "2026-07-31T10:00:00.000-06:00",
  "level": "INFO",
  "service": "bdinteg-service",
  "traceId": "1-xxx-xxx",
  "spanId": "xxx",
  "operation": "sp_consulta_cte_huella",
  "domain": "bdinteg",
  "wave": "5",
  "callingSystem": "AU_PPCOPPEL",
  "durationMs": 45,
  "outcome": "SUCCESS",
  "requestId": "uuid"
}
```

> **Nota de PII:** bdinteg gestiona datos de huella biométrica (`sp_consulta_cte_huella`)
> y tokens de sesión de cajero. Nunca loguear: num_cte, num_tarjeta, datos biométricos,
> tokens de sesión. Solo loguear identificadores anonimizados.
> Marco regulatorio aplicable: LFPDPPP, CNBV Circular 3/2012, PCI-DSS 3.4.

---

### INC-D02-04 — Tabla de huellas biométricas stale (N2)

> **Diagnóstico completo**: [inc-007-d02-huellas-stale.html](../../portal/incidents/inc-007-d02-huellas-stale.html)

> **Ver risk register:** `migration-risk-register.md` · P655-R006

**Impacto funcional:** Riesgo de divergencia entre el inventario de huellas biométricas en Informix (`si_cte_huella` en bdinteg) y el stock real en PostgreSQL (`postg_huellasemps`), dado que el sistema Huellas ya migró a PostgreSQL. Con 205,079 llamadas/día a `sp_consulta_huella_actual` (punto de entrada de autenticación de TODOS los servicios), cualquier divergencia en los datos de huella afecta la autenticación biométrica transversal.

**Causa raíz (desde risk register P655-R006):** El sistema Huellas migró a PostgreSQL (`postg_huellasemps`) pero `sp_consulta_huella_actual` sigue consultando la tabla `si_cte_huella` en bdinteg (Informix). Riesgo de que el inventario de huellas en Informix no esté sincronizado con el de PostgreSQL.

**SPs afectados:** `sp_consulta_huella_actual` (205,079 llamadas/día — el SP más llamado del sistema).

**Acción requerida antes de cutover:**
1. Coordinar con el equipo de Huellas (PostgreSQL `postg_huellasemps`) para verificar si existe mecanismo de sincronización hacia `si_cte_huella` en bdinteg.
2. Si no hay sincronización: evaluar si el target de bdinteg debe apuntar directamente a `postg_huellasemps` en vez de la tabla Informix.
3. Documentar en `ADR-SPE-AM-XXX` la estrategia de acceso a huellas en el target (Informix local vs. PostgreSQL externo).
4. Registrar como prerequisito del parallel-run: la tasa de autenticación exitosa no debe divergir entre legacy y target.

---

### INC-D02-05 — ACEPTPORTA SFTP Auth Failure · Portabilidad Nómina (N2)

> **Diagnóstico completo**: [inc-008-d02-aceptporta.html](../../portal/incidents/inc-008-d02-aceptporta.html)

> **Ver risk register:** `migration-risk-register.md` · P655-R007

**Impacto funcional:** El servicio `ACEPTPORTA` (ESB → `PrestamoNominaExpedienteDigital`) falla 3,244 veces/día con error 3381 al intentar autenticarse contra el servidor SFTP `sysportabnominaapp`. El resultado es que `sp_inserta_reg_expediente_dig_img` nunca se invoca — 3,073 expedientes digitales de portabilidad de nómina quedan sin imagen por día. El flujo CNBV de portabilidad no puede completarse: `sp_consulta_reg_contr_evid_notif_porta_x_estatus` recibe solo 1 llamada/día (flujo prácticamente muerto).

**Causa raíz (desde log analysis 2026-04-24):** Las credenciales `sysportabnominaapp` en el keystore del ESB están inválidas o expiradas. Error 3381 = falla de autenticación SFTP. No hay mecanismo de reintento ni alerta configurada.

**SPs afectados:**
- `sp_inserta_reg_expediente_dig_img`: 3,073 llamadas/día, 100% fallo (SP nunca se invoca porque el SFTP falla antes)
- `sp_consulta_reg_contr_evid_notif_porta_x_estatus`: 1 llamada/día (flujo de notificación prácticamente muerto)

**Acciones requeridas:**
1. Rotar credenciales de `sysportabnominaapp` y actualizar el keystore del ESB.
2. Agregar alerta sobre error 3381 en `errores_bus_*.txt` — threshold: > 10 eventos en 5 min.
3. Migrar gestión de credenciales SFTP a Vault o AWS Secrets Manager (eliminar keystore estático).
4. Documentar escenario en `knowledge-base/D02-bdinteg/06-exceptions.md` con código 3381.

---

*Generado por: SRE & AIOps · 2026-07-31 · [SME-PENDING] umbrales de SLO requieren
baseline real con QA Lead. Perfiles de SPs — especialmente `sysbldsqltextin` (213,929 LOC)
— pendientes de validación contra `source/BCOPCore/informix/` con Specialist Informix SPL Analysis.*

<!-- LOG-DATA-BEGIN -->
## Patrones de incidente observados — Logs 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

**Error rate del dominio:** 4.37% (Normal)

### Acciones por código de error

| Código | Vol/día | Prioridad | Acción inmediata |
|--------|---------|-----------|-----------------|
| `3381` | 3,244 | ALTA | Verificar conectividad SFTP y credenciales del servidor de portabilida |
| `4395` | 524 | MEDIA | Verificar NullPointerException en el plugin Java — revisar datos de en |
| `4394` | 314 | MEDIA | Revisar MbUserException en IIB — validar que el SP devuelve el tipo es |
| `3743` | 154 | MEDIA | Aumentar timeout en configuración del canal ESB — verificar disponibil |
| `5004` | 65 | BAJA | Validar formato XML de la trama enviada — puede haber caracteres espec |
| `3701` | 6 | BAJA | Revisar endpoint SOAP — verificar que el WSDL sea accesible y la respu |

### SPs críticos para monitoring

| SP | Llamadas/día | Error% | Alerta sugerida |
|----|-------------|--------|-----------------|
| `sp_consultacten2` | 29,221 | 99.81% | Alerta si error_rate > 49.9% en 5 min |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->
