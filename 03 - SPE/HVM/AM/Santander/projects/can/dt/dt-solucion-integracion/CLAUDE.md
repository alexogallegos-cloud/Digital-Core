# DT — Solución Integración CAN · Santander México
> **Proyecto:** CAN · Santander México
> **Fase:** DESIGN / BUILD
> **Versión:** 0.2.0 · `[STATE: ACTIVE]`
> **Última actualización:** 2026-09-17 — arquitectura CECOBAN confirmada desde DET-430801-CANO v1.2

## Propósito

Diseña la integración técnica entre los sistemas internos de Santander y el
Sistema CAN operado por CECOBAN (Mecanismo Art. 63 Bis 3). Define los flujos de mensajes,
contratos de API, patrones de retry, manejo de errores y tiempos de respuesta
requeridos por el DE CAN v4.2 y el DET-430801-CANO v1.2.

**NOTA DE ARQUITECTURA CONFIRMADA (v0.2.0):** El sistema CAN usa arquitectura **dual-canal**:
- **REST API** (`POST /api/can/v1/operaciones`): Banco → CECOBAN (síncrono, ACK inmediato)
- **Kafka** (`can.<ambiente>.<institucion>.<tipo>`): CECOBAN → Banco (asíncrono, commit manual)

Esto NO es SOAP ni MQ. Ver `knowledge-base/rules/de-can-spec-tecnica.md` para spec completa.

## SMEs Heredados

| SME | Rol |
|-----|-----|
| Framework — Integration Architecture | Diseño del adaptador REST + Kafka consumer · patrones EIP |
| Industry Payments → SPEI | OBL-006 (SPEI refinanciamiento) + timing interbancario |
| Software Engineering | Implementación del adaptador · pruebas de integración |
| Regulatory/Banxico | Validación de flujos contra DE CAN v4.2 |

---

## Arquitectura de Integración CECOBAN — Confirmada

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Santander México                              │
│                                                                      │
│  ┌───────────┐   REST POST    ┌──────────────┐                      │
│  │  loans    │────────────────►              │                      │
│  │core-banking│  /api/can/v1/ │ CAN Adapter  │                      │
│  │payments-  │  operaciones   │              │                      │
│  │engine     │◄───────────────│  (JWT auth)  │                      │
│  └───────────┘   ACK 200 sync └──────┬───────┘                      │
│                                      │ Kafka consumer                │
│                                      │ can.<env>.<inst>.*            │
└──────────────────────────────────────┼──────────────────────────────┘
                                       │
                              ┌────────▼────────┐
                              │    CECOBAN       │
                              │                  │
                              │ POST /security/  │
                              │ token → JWT      │
                              │                  │
                              │ POST /api/can/   │
                              │ v1/operaciones   │
                              │ ← ACK inmediato  │
                              │                  │
                              │ Kafka:9093 TLS   │
                              │ → mensajes async │
                              └──────────────────┘
```

### Tabla de Canales

| Canal | Dirección | Protocolo | Puerto | Seguridad | Uso |
|-------|-----------|-----------|--------|-----------|-----|
| Autenticación | Banco → CECOBAN | HTTPS/REST | 443 | TLS 1.3 + Client ID/Secret → JWT | Obtener token |
| API mensajes | Banco → CECOBAN | HTTPS/REST | 443 | TLS 1.3 + JWT | Envío C50-C58 (menos C53,C57) |
| Mensajería | CECOBAN → Banco | Kafka | 9093 | TLS 1.3 + SASL/OAUTHBEARER | Recepción de todos los mensajes |

**Principio clave:** el banco nunca publica endpoints. CECOBAN nunca abre conexiones entrantes. Todo es outbound del banco.

---

## Códigos de Operación — Responsabilidad de Santander

### Santander como Institución Acreedora (otorga el CAN)

| Código | Nombre | Acción Santander | Canal |
|--------|--------|-----------------|-------|
| C50 | Solicitud de Información | **ENVÍA** a CECOBAN via REST | POST /api/can/v1/operaciones |
| C51 | Respuesta de Disponibilidad | **RECIBE** de Banco Ordenante | Kafka topic `.c51` |
| C52 | Otorgamiento del CAN | **ENVÍA** a CECOBAN via REST | POST /api/can/v1/operaciones |
| C53 | Prelación | **RECIBE** de CECOBAN | Kafka topic `.c53` |
| C55 | Actualización datos crédito | **ENVÍA** a CECOBAN via REST | POST /api/can/v1/operaciones |
| C57 | Entrega info por cambio BO | **RECIBE** de CECOBAN | Kafka topic `.c57` |

### Santander como Institución Depositaria (lleva la Cuenta Ordenante)

| Código | Nombre | Acción Santander | Canal |
|--------|--------|-----------------|-------|
| C50 | Solicitud de Información | **RECIBE** del Banco Otorgante | Kafka topic `.c50` |
| C51 | Respuesta de Disponibilidad | **ENVÍA** a CECOBAN via REST | POST /api/can/v1/operaciones |
| C52 | Otorgamiento del CAN | **RECIBE** del Banco Otorgante | Kafka topic `.c52` |
| C53 | Prelación | **RECIBE** de CECOBAN | Kafka topic `.c53` |
| C54 | Actualización CLABE | **ENVÍA** a CECOBAN via REST | POST /api/can/v1/operaciones |
| C56 | Cambio Banco Ordenante | **ENVÍA** a CECOBAN via REST | POST /api/can/v1/operaciones |
| C57 | Entrega info por cambio BO | **RECIBE** de CECOBAN | Kafka topic `.c57` |
| C58 | CAN propio | **ENVÍA** a CECOBAN via REST | POST /api/can/v1/operaciones |

---

## Flujo 1 — Santander como Institución Acreedora (otorga el CAN)

```
1. loans detecta cliente con nómina en otra institución
2. CAN Adapter obtiene JWT: POST /security/token
3. CAN Adapter envía C50 (Solicitud Info):
   POST /api/can/v1/operaciones → ACK {uuid, ACCEPTED}
4. CECOBAN valida + genera UUID + reenvía C50 al Banco Ordenante (≤30s)
5. Kafka consumer escucha topic can.<env>.<inst>.c51
6. Banco Ordenante responde C51 en ≤48h → CECOBAN publica en topic Santander
7. CAN Adapter recibe C51 via Kafka → commit manual del offset
8. loans evalúa info (saldos + abonos 6 meses) → decide otorgamiento
9. CAN Adapter envía C52 (Otorgamiento CAN):
   POST /api/can/v1/operaciones → ACK
10. Kafka consumer escucha .c53 (Prelación de CECOBAN)
11. loans asigna Clave Básica Estandarizada (OBL-009)
12. Si refinanciamiento: payments-engine ejecuta SPEI (OBL-006) con Clave Básica
```

**SLAs críticos del flujo:**
- Paso 4: CECOBAN reenvía C50 a Banco Ordenante en ≤30 segundos
- Paso 6: Banco Ordenante debe responder C51 en ≤48 horas
- Si C51 no llega en 48h: CECOBAN publica `MESSAGE_RESPONSE_TIMEOUT` en topic `.notifications`

### Flujo 2 — Santander como Institución Depositaria (lleva la Cuenta Ordenante)

```
1. Kafka consumer detecta C50 en topic can.<env>.<inst>.c50
   (Banco Otorgante quiere otorgar CAN al cliente de Santander)
2. CAN Adapter → commit manual al recibir C50
3. core-banking consulta Cuenta Ordenante del nominado
4. CAN Adapter envía C51 (Respuesta disponibilidad):
   POST /api/can/v1/operaciones → ACK {uuid, ACCEPTED}
   (C51 debe enviarse en ≤48h — OBL-015)
5. Si C51 favorable: Kafka consumer espera C52 (Otorgamiento)
6. CAN Adapter recibe C52 → core-banking registra nueva domiciliación CAN
7. core-banking actualiza tabla de prelación (OBL-016):
   Nivel 1: no-CAN previos misma institución
   Nivel 2: CANs por fecha/hora de designación
   Nivel 3: domiciliaciones y otros no-CAN
8. Kafka consumer escucha .c53 (Prelación de CECOBAN)
```

### Flujo 3 — SPEI Refinanciamiento (OBL-006)

```
1. Santander otorga CAN para refinanciar crédito anterior
2. payments-engine ejecuta SPEI a la institución acreedora anterior
   · Monto: saldo total del crédito a liquidar (del campo saldo_credito_liquidar en C51)
   · Referencia: Clave Básica Estandarizada del crédito liquidado (OBL-006 + OBL-009)
3. SPEI confirma liquidación → Santander registra CAN activo
```

### Flujo 4 — Timeout y Notificaciones

```
1. Kafka consumer suscrito a can.<env>.<inst>.notifications
2. Si CECOBAN publica MESSAGE_RESPONSE_TIMEOUT:
   a. originMessageCode=C50, expectedMessageCode=C51, configuredDurationSeconds=30
      → CECOBAN no recibió C51 del Banco Ordenante en 30s
   b. originMessageCode=C51, expectedMessageCode=C52, configuredDurationSeconds=172800
      → Banco Otorgante no envió C52 en 48h después de recibir C51
3. CAN Adapter procesa la notificación → alerta a ops → commit manual del offset
```

---

## Contrato de Autenticación

```
POST /security/token
Content-Type: application/json

{ "clientId": "BANCO40072", "clientSecret": "***" }

Respuesta:
{ "accessToken": "eyJ...", "tokenType": "Bearer",
  "expiresIn": 900, "issuedAt": "2026-09-17T10:00:00" }
```

Token vigente ~15 minutos. El adaptador debe renovar **antes** de la expiración.

## Contrato API — Envío de Mensajes

```
POST /api/can/v1/operaciones
Authorization: Bearer {JWT}
Content-Type: application/json

Body: mensaje JSON con código de operación embebido
(C50, C51, C52, C54, C55, C56 o C58)

ACK síncrono:
{ "uuid": "uuid-cecoban", "timestamp": "...", "status": "ACCEPTED|REJECTED|ERROR", "errors": [] }
```

**El UUID en el ACK es el identificador CECOBAN que Santander debe mantener en todos los mensajes subsecuentes del mismo flujo.**

## Configuración Kafka Consumer

```properties
bootstrap.servers=<entregado-por-cecoban>:9093
security.protocol=SASL_SSL
sasl.mechanism=OAUTHBEARER
group.id=can.<ambiente>.40072
enable.auto.commit=false
auto.offset.reset=earliest
```

Topics a suscribir (Santander 40072):
```
can.<ambiente>.40072.c50   # como depositaria
can.<ambiente>.40072.c51   # como acreedora
can.<ambiente>.40072.c52   # como depositaria
can.<ambiente>.40072.c53   # prelación (ambos roles)
can.<ambiente>.40072.c54   # (si aplica)
can.<ambiente>.40072.c55   # como depositaria
can.<ambiente>.40072.c56   # (si aplica)
can.<ambiente>.40072.c57   # info cambio banco ordenante
can.<ambiente>.40072.notifications  # timeouts y alertas técnicas
```

---

## Errores de la API CECOBAN

| HTTP | Código | Descripción |
|------|--------|-------------|
| 400 | CAN-001 | El mensaje no contiene un JSON válido |
| 400 | CAN-002 | El mensaje no cumple con el JSON Schema |
| 400 | CAN-003 | El código de operación no está soportado |
| 400 | CAN-004 | Faltan campos obligatorios |
| 400 | CAN-005 | Uno o más campos con formato inválido |
| 400 | CAN-006 | Estructura no corresponde al código indicado |
| 400 | CAN-007 | No se identificó la Institución Participante |
| 400 | CAN-008 | UUID inválido |
| 401 | CAN-101 | Token no proporcionado |
| 401 | CAN-102 | Token inválido |
| 401 | CAN-103 | Token expirado |
| 403 | CAN-201 | Institución no autorizada |
| 403 | CAN-202 | Sin permiso para ese código de operación |
| 403 | CAN-203 | Institución autenticada ≠ institución del mensaje |
| 404 | CAN-301 | Recurso no encontrado |
| 500 | CAN-501 | Error interno CECOBAN |
| 500 | CAN-502 | No se pudo generar el ACK |

---

## Patrones de Integración

### Retry Policy — API REST

```
· Máximo 3 reintentos con backoff exponencial: 1s → 5s → 30s
· HTTP 400-403: NO reintentar (error de datos/auth) — loguear y alarmar
· HTTP 500-504: reintentar con backoff
· Si CECOBAN no responde en 3 intentos → ticket ITSM + alert operativo
· Idempotency: reusar el mismo UUID CECOBAN para reintentos del mismo mensaje
```

### Kafka Consumer — Procesamiento

```
Flujo: RECEIVED → PROCESSING → PROCESSED → COMMIT
· enable.auto.commit=false — commit SOLO al completar procesamiento exitoso
· En error: NO commitear → Kafka retiene el mensaje para reprocesamiento
· Registrar: UUID, código op, topic/partition/offset, timestamps, resultado
· NO registrar: Client Secret, JWT completos
```

### Trazabilidad — Campos mínimos por mensaje Kafka

| Campo | Tipo | Obligatorio |
|-------|------|-------------|
| UUID de la operación | UUID | Sí |
| Código de operación | C50-C58 | Sí |
| Topic, partition, offset | Kafka metadata | Sí |
| Fecha/hora de recepción | ISO 8601 CDMX | Sí |
| Fecha/hora inicio procesamiento | ISO 8601 CDMX | Sí |
| Fecha/hora de conclusión | ISO 8601 CDMX | Sí |
| Fecha/hora de commit | ISO 8601 CDMX | Sí |
| Resultado del procesamiento | OK / ERROR | Sí |
| Número de reintentos | int | Sí |
| Errores presentados | string | Si aplica |

### Observabilidad requerida

| Métrica | Umbral de alerta |
|---------|-----------------|
| Latencia POST /api/can/v1/operaciones | > 5s → WARNING |
| Tasa de error HTTP 4xx/5xx | > 1% → CRITICAL |
| Kafka consumer lag | > 100 mensajes → WARNING |
| C50 sin C51 en 30s (Topic .notifications) | Cualquier evento → CRITICAL |
| C51 sin C52 en 48h (Topic .notifications) | Cualquier evento → WARNING |
| Expiración token JWT (< 60s restantes) | → Renovación automática |
| DHBs restantes para SLA regulatorio | < 1 DHB → CRITICAL |

---

## Arquitectura del Adaptador

### Módulos funcionales del CAN Adapter

```java
can-adapter/
├── auth/
│   ├── JwtTokenProvider.java         // POST /security/token · renovación automática
│   └── JwtTokenCache.java            // cache en memoria con TTL = expiresIn - 60s
├── rest/
│   ├── CecobanRestClient.java        // POST /api/can/v1/operaciones · retry + error handling
│   ├── CanMessageSerializer.java     // Santander model → JSON Schema CAN
│   └── AckResponseHandler.java      // parse ACK · extraer UUID CECOBAN
├── kafka/
│   ├── CanKafkaConsumer.java         // Kafka consumer · SASL/OAUTHBEARER · auto.commit=false
│   ├── CanMessageDeserializer.java   // JSON → Santander model
│   ├── ManualCommitStrategy.java    // commit SOLO después de procesamiento exitoso
│   └── NotificationHandler.java     // MESSAGE_RESPONSE_TIMEOUT → alerta ops
├── domain/
│   ├── CanFlowOrchestrator.java      // orquesta flujos C50→C51→C52
│   ├── PrelacionEngine.java          // → delega a core-banking
│   └── ClaveBasicaGenerator.java    // Clave Básica Estandarizada (OBL-009)
├── audit/
│   ├── CanTraceLogger.java           // trazabilidad regulatoria (9 campos mínimos)
│   └── SlaMonitor.java              // alertas DHB + timeout CECOBAN
└── tests/
    └── can-integration/              // → dt-solucion-testing
```

### Opción A — Módulo dentro de `payments-engine` (ADR-SANT-CAN-001 opción preferida)

```
payments-engine/
└── can-adapter/                      ← módulo funcional (paquete Java independiente)
    ├── [módulos listados arriba]
    └── config/
        ├── application-can.yaml     // parámetros CECOBAN por ambiente
        └── kafka-can-consumer.yaml  // bootstrap.servers, topics, consumer group
```

Ventajas: acceso directo a infraestructura de pagos · menor footprint · DSL de retry reutilizable.
Riesgo: acopla compliance regulatorio al core de pagos.

### Opción B — Microservicio `can-engine` independiente

```
can-engine/
├── src/main/java/mx/santander/can/
│   ├── adapters/cecoban/           // REST + Kafka
│   ├── domain/                     // lógica de negocio CAN
│   ├── ports/                      // interfaces hacia loans, core-banking
│   └── infrastructure/             // Azure Service Bus / Kafka / persistence
├── Dockerfile
└── helm/                           // deploy en Azure AKS
```

Ventajas: aislamiento total del cambio regulatorio · escala independiente · DoD propio.
Riesgo: mayor footprint de delivery · duplica algunas capacidades de payments-engine.

> **ADR-SANT-CAN-001:** Pendiente confirmación del stack de `payments-engine`. Ver DT de Arquitectura.

---

## Simulador CECOBAN — Integración de Pruebas

Para las pruebas de integración en fase BUILD/TEST, usar el Simulador CAN:

| Parámetro | Valor |
|-----------|-------|
| IP Simulador | 148.250.112.14 |
| Puerto HTTPS | 443/TCP |
| Puerto Kafka | 9093/TCP |
| Auth endpoint | /security/token |
| API endpoint | /api/can/v1/operaciones |
| Docs | /api-docs (Scalar/OpenAPI) |
| Ambiente en topics | `simulador` |

Ver `knowledge-base/rules/simulador-can.md` para guía completa de onboarding.

**Prerequisito:** registrar IPs de salida de Santander en lista blanca CECOBAN antes de conectar.

---

## SLAs Regulatorios en Este Flujo

| Obligación | SLA | Acción si no se cumple |
|-----------|-----|------------------------|
| OBL-001/C50: CECOBAN reenvia a Banco Ordenante | 30 segundos | Notificación automática via `.notifications` |
| OBL-015/C51: Santander como Depositaria responde | 1 DHB (≤48h) | Alert operativo + ticket ITSM |
| OBL-020: notificar cancelación Domiciliación | 1 DHB | Alert inmediato + retry |
| OBL-021: resolver objeción CAN | 5 DHB | Ticket automático a ops |
| OBL-022: remitir objeción | 2 DHB | Alert automático |
| OBL-023: transferir prestaciones laborales | Mismo DHB si < 17:00; siguiente si > 17:00 | Scheduler autónomo + cutoff 16:45 |

---

## Outputs

| Artefacto | Ruta |
|-----------|------|
| Spec técnica CECOBAN (fuente primaria) | `knowledge-base/rules/de-can-spec-tecnica.md` |
| Guía Simulador CAN | `knowledge-base/rules/simulador-can.md` |
| Contrato de API Adaptador CAN (OpenAPI 3.x) | `knowledge-base/rules/api-can-adapter.yaml` *(pendiente)* |
| Configuración Kafka consumer | → incluida en este DT |
| Estrategia de testing | `dt/dt-solucion-testing/CLAUDE.md` |

## Dependencias

- `[CONFIRMED: de-can-spec-tecnica.md]` — protocolo exacto: REST + Kafka, confirmado desde DET-430801-CANO v1.2
- `[DEPENDS-ON: dt-solucion-arquitectura]` — ADR-SANT-CAN-001 (patrón de integración elegido)
- `[DATO-REQUERIDO]` — Código de institución Santander en CECOBAN (probable 40072 — confirmar)
- `[DATO-REQUERIDO]` — Paquete de conectividad del Simulador CAN de CECOBAN (Client ID, Client Secret, Consumer Group, topics exactos)
- `[DATO-REQUERIDO]` — Stack y capacidades de integración de `payments-engine`

*v0.2.0 · 2026-09-17 · Arquitectura CECOBAN confirmada: REST API + Kafka dual-canal (DET-430801-CANO v1.2 + Guía Simulador v1.2). Elimina hipótesis de protocolo. Añade: tabla de mensajes por rol, flujo timeout, configuración Kafka, catálogo de errores, módulos del adaptador.*
