# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Contratos de API

> **Componente:** BCOPCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---

## Principios de diseño de API para D15

1. **Toda consulta LIDE es síncrona y bloqueante**: la verificación de un cliente en LIDE no puede ser asíncrona. El caller necesita la respuesta antes de proceder.
2. **Timeout estricto**: si LIDE no responde en 200ms (transaccional) o 5s (consulta), la respuesta predeterminada es DENY. `[COMPLIANCE-SIGN-OFF-REQUIRED]`
3. **Sin datos PII en logs**: los endpoints que reciben RFC, CURP o `num_cte` nunca los registran en logs. Solo el `requestId` para trazabilidad.
4. **Autenticación mTLS**: todos los endpoints del LideService requieren certificado de cliente — no hay acceso anónimo.

## Endpoints del LideService (transaccionales)

### GET /lide/v1/clientes/{numCte}/status

Verifica si un cliente está en la lista LIDE.

**Request:**
```
GET /lide/v1/clientes/{numCte}/status
Authorization: mTLS
X-Request-ID: uuid
X-Calling-System: {bdicnweb|bdinteg|bdicred}
```

**Response 200 — cliente libre:**
```json
{
  "requestId": "uuid",
  "numCte": "[ENMASCARADO EN LOGS]",
  "status": "LIBRE",
  "timestamp": "2026-08-03T10:00:00.000-06:00",
  "version": "v1"
}
```

**Response 200 — cliente en LIDE:**
```json
{
  "requestId": "uuid",
  "numCte": "[ENMASCARADO EN LOGS]",
  "status": "EN_LIDE",
  "codigoMotivo": "[DATO-REQUERIDO]",
  "timestamp": "2026-08-03T10:00:00.000-06:00",
  "version": "v1"
}
```

**Response 503 — servicio no disponible (falla segura):**
```json
{
  "requestId": "uuid",
  "status": "SERVICIO_NO_DISPONIBLE",
  "accion": "DENY",
  "retryAfter": 30,
  "timestamp": "2026-08-03T10:00:00.000-06:00"
}
```

### GET /lide/v1/clientes/curp/{curp}/status

Verifica un cliente por CURP (equivalente al SP `sp_checacurp`).

```
GET /lide/v1/clientes/curp/{curp}/status
Respuesta: igual que el endpoint por numCte
```

### POST /lide/v1/operaciones/acumular

Disparador del proceso de acumulación (uso interno del PldBatchService).

```
POST /lide/v1/operaciones/acumular
Content-Type: application/json
Authorization: mTLS (solo PldBatchService autorizado)

{
  "empresa": "BCO",
  "fechaProceso": "2026-08-03",
  "cveUsuario": "BATCH001",
  "fechaUltimoDia": "2026-08-31"
}
```

**Response 202 Accepted:**
```json
{
  "requestId": "uuid",
  "jobId": "job-2026-08-03-acumulacion",
  "status": "ACEPTADO",
  "estimatedCompletionMinutes": 45
}
```

## Endpoints del PldBatchService (batch/regulatorio)

### POST /pld/v1/batch/ejecutor-diario

Disparado por EventBridge Scheduler. Equivalente al `ejecutor_diario`.

```
POST /pld/v1/batch/ejecutor-diario
Authorization: IAM Role (EventBridge)

{
  "fechaProceso": "2026-08-03",
  "cveUsuario": "SCHEDULER"
}
```

### POST /pld/v1/sat/informe

Inicia la generación y envío del informe SAT. Equivalente a `sp_cargainformesat`.

```
POST /pld/v1/sat/informe
Authorization: mTLS (solo usuario de Cumplimiento autorizado)

{
  "periodo": "202607"
}
```

**Response 202 Accepted** con `jobId` para seguimiento.

### POST /pld/v1/sat/resultado

Procesa el archivo de resultado del SAT. Equivalente a `sp_cargaresultadosat`.

```
POST /pld/v1/sat/resultado
Content-Type: multipart/form-data
Authorization: mTLS

archivo: [archivo de resultado SAT]
periodo: "202607"
```

## Códigos de error del LideService

| Código HTTP | Código aplicación | Significado |
|:-----------:|:-----------------:|-------------|
| 200 | `00000` | Éxito |
| 200 | `EN_LIDE` | Cliente en lista — debe ser tratado como error de negocio por el caller |
| 400 | `PARAM_INVALIDO` | RFC o CURP con formato incorrecto |
| 409 | `PROCESO_YA_EJECUTADO` | Acumulación del día ya procesada (equivalente al código `018` del SP) |
| 500 | `PARAM_NO_CONFIGURADO` | `vmMontLimite` o `viPorcaRecau` no configurados en Aurora |
| 503 | `SERVICIO_NO_DISPONIBLE` | LideService degradado — el caller debe implementar falla segura (DENY) |

## `[SME-PENDING]`

- [ ] Core Banking Transformation: validar el diseño de los endpoints con los equipos de D01-bdicnweb, D02-bdinteg y D03-bdicred (los callers).
- [ ] Área de Cumplimiento: confirmar que el comportamiento de falla segura (DENY cuando LIDE no responde) es el correcto desde la perspectiva regulatoria.
- [ ] Definir el contrato de datos del campo `codigoMotivo` en la respuesta `EN_LIDE`.
- [ ] Confirmar el SLA de respuesta del LideService: ¿200ms es alcanzable con Aurora Multi-AZ?
- [ ] Diseñar el contrato OpenAPI 3.0 completo y registrarlo en el API Gateway de BCOPCore.

---
*Generado: Core Banking Transformation + Cloud Architect · 2026-08-03*
