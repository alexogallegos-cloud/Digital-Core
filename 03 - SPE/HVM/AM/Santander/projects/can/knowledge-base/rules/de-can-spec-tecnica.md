# Especificaciones Técnicas CAN — Integración CECOBAN
> Fuente: Documento de Especificaciones Técnicas CAN v1.2 (DET-430801-CANO · 19/08/2026)
> Complementa: DE CAN v4.2 (25/08/2026) · Guía Simulador CAN v1.2 (19/08/2026)

---

## Arquitectura de Integración

La integración entre las Instituciones Participantes y CECOBAN se realiza mediante **dos mecanismos independientes**:

| Canal | Dirección | Protocolo | Puerto | Seguridad | Uso |
|-------|-----------|-----------|--------|-----------|-----|
| Autenticación | Institución → CECOBAN | HTTPS/REST | TCP/443 | TLS 1.3 + Client ID/Secret → JWT | Obtener token |
| API CAN | Institución → CECOBAN | HTTPS/REST | TCP/443 | TLS 1.3 + JWT | Envío de mensajes |
| Documentación | Institución → CECOBAN | HTTPS | TCP/443 | TLS 1.3 | Scalar/OpenAPI (/api-docs) |
| Mensajería CAN | CECOBAN → Institución | Kafka | TCP/9093 | TLS 1.3 + SASL/OAUTHBEARER + JWT | Recepción de mensajes |

**Principio fundamental:** todas las conexiones son **iniciadas por la Institución hacia CECOBAN**. CECOBAN nunca abre conexiones entrantes hacia la Institución. El banco no publica endpoints ni abre puertos de entrada.

---

## Flujo Operativo Completo

```
1. Institución obtiene JWT via POST /security/token
2. Institución envía mensaje via POST /api/can/v1/operaciones
3. CECOBAN valida el mensaje
4. CECOBAN genera ACK (síncrono) → HTTP 200 con uuid + status ACCEPTED
5. CECOBAN procesa la solicitud (asíncrono)
6. CECOBAN publica el mensaje al destinatario en su topic Kafka
7. Institución consume el mensaje via Kafka
8. Institución procesa el mensaje
9. Institución confirma procesamiento via commit manual del offset
```

---

## Convenciones Generales

| Elemento | Valor |
|----------|-------|
| Formato de mensajes | JSON |
| Codificación | UTF-8 |
| Protocolo REST | HTTPS / TLS 1.3 |
| Protocolo mensajería | Kafka / TLS 1.3 |
| Formato de fecha y hora | ISO 8601 — Hora CDMX, sin zona horaria ni offset UTC |
| Ejemplo fecha válida | `2026-08-18T14:35:28` |
| Identificador de operación | UUID |
| Zona horaria | Hora del Centro de México (CDMX) |

---

## Autenticación — JWT

### Endpoint de autenticación
```
POST /security/token
Content-Type: application/json
```

### Solicitud
```json
{
  "clientId": "BANCO40014",
  "clientSecret": "********"
}
```

### Respuesta exitosa (HTTP 200)
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tokenType": "Bearer",
  "expiresIn": 900,
  "issuedAt": "2026-07-09T15:30:45"
}
```

- `expiresIn` en segundos (valor de referencia: 900s = 15 minutos)
- La Institución debe renovar el token **antes** de su expiración
- El token debe usarse en el header `Authorization: Bearer {token}`
- El token NO debe incluirse en logs, evidencias ni correos

### Errores de autenticación
| HTTP | Descripción |
|------|-------------|
| 400 | Solicitud inválida |
| 401 | Credenciales inválidas |
| 500 | Error interno |

---

## API REST — Envío de Mensajes

### Endpoint único
```
POST /api/can/v1/operaciones
Authorization: Bearer {JWT}
Content-Type: application/json
```

El código de operación se identifica a partir del **contenido del JSON**. No existen endpoints separados por código (C50, C51, etc.).

### Mensajes que acepta la API (Institución → CECOBAN)
| Código | Emisor | Recibe via REST |
|--------|--------|-----------------|
| C50 | Banco Otorgante | Sí |
| C51 | Banco Ordenante | Sí |
| C52 | Banco Otorgante | Sí |
| C53 | CECOBAN | No — generado por CECOBAN |
| C54 | Banco Ordenante | Sí |
| C55 | Banco Otorgante | Sí |
| C56 | Banco Ordenante | Sí |
| C57 | CECOBAN | No — generado por CECOBAN |
| C58 | Banco Ordenante o Otorgante | Sí |

**C53 y C57 son generados por CECOBAN** y entregados vía Kafka. Las instituciones **nunca envían** C53 ni C57 a la API.

### ACK de respuesta

Toda solicitud recibida genera un ACK síncrono:

```json
{
  "uuid": "550e8400-e29b-41d4-a716-446655440000",
  "timestamp": "2026-08-18T14:35:28",
  "status": "ACCEPTED",
  "errors": []
}
```

Posibles valores de `status`:
| Valor | Descripción |
|-------|-------------|
| `ACCEPTED` | Mensaje recibido, validado técnicamente y aceptado para procesamiento |
| `REJECTED` | Mensaje rechazado por validación de auth, estructura, schema o datos |
| `ERROR` | Falla técnica interna de CECOBAN |

El ACK confirma recepción técnica. **No implica que la operación funcional haya concluido**. La respuesta funcional llega posteriormente via Kafka.

### Códigos HTTP de la API
| HTTP | Status | Descripción |
|------|--------|-------------|
| 200 | ACCEPTED | Mensaje recibido y aceptado correctamente |
| 400 | REJECTED | Error en estructura o contenido del JSON |
| 401 | REJECTED | Token no proporcionado, inválido o expirado |
| 403 | REJECTED | Institución sin autorización para esa operación |
| 404 | REJECTED | Recurso solicitado no encontrado |
| 500 | ERROR | Error interno de CECOBAN |

---

## Canal de Mensajería — Kafka

CECOBAN entrega mensajes a las instituciones via Kafka. Cada institución tiene topics exclusivos.

### Configuración del consumidor Kafka
```
bootstrap.servers=<HOST_KAFKA>:9093
security.protocol=SASL_SSL
sasl.mechanism=OAUTHBEARER
group.id=<CONSUMER_GROUP>
enable.auto.commit=false
auto.offset.reset=earliest
```

- Puerto: TCP/9093
- TLS: 1.3 obligatorio
- Autenticación: SASL/OAUTHBEARER con JWT (mismo token obtenido de `/security/token`)
- Commit: **manual** — `enable.auto.commit=false`
- Credenciales (Client ID + Client Secret): entregadas por CECOBAN via **KeyPass**

### Nomenclatura de topics
```
can.<ambiente>.<institucion>.<tipo>
```

Ejemplo para Santander (institución 40072) en producción:
```
can.produccion.40072.c50
can.produccion.40072.c51
can.produccion.40072.c52
can.produccion.40072.c53
can.produccion.40072.c54
can.produccion.40072.c55
can.produccion.40072.c56
can.produccion.40072.c57
can.produccion.40072.c58
can.produccion.40072.notifications
```

Ambientes disponibles: `simulador` | `produccion`

### Consumer Group
```
can.<ambiente>.<institucion>
```
El Consumer Group debe mantenerse estable para conservar el seguimiento de offsets.

### Flujo de procesamiento de mensajes
```
RECEIVED → PROCESSING → PROCESSED → COMMIT
```

Si el procesamiento falla: **no confirmar el offset**. El mensaje permanece disponible para reprocesamiento.

### Mensajes entregados por CECOBAN via Kafka (destinatario funcional)
| Código | Entregado a | Medio |
|--------|-------------|-------|
| C50 | Banco Ordenante | Kafka |
| C51 | Banco Otorgante | Kafka |
| C52 | Banco Ordenante | Kafka |
| C53 | Banco Ordenante + Banco Otorgante | Kafka (generado por CECOBAN) |
| C54 | Banco Otorgante | Kafka |
| C55 | Banco Ordenante | Kafka |
| C56 | Banco Otorgante + Banco Ordenante | Kafka |
| C57 | Banco Otorgante + Banco Ordenante | Kafka (generado por CECOBAN) |
| C58 | CECOBAN (no hay entrega posterior) | — |

---

## Resumen de Mensajes por Código

| Código | Nombre | Emisor (REST) | Destinatario funcional (Kafka) |
|--------|--------|---------------|-------------------------------|
| C50 | Solicitud de Información y Disponibilidad | Banco Otorgante | Banco Ordenante |
| C51 | Respuesta de Disponibilidad | Banco Ordenante | Banco Otorgante |
| C52 | Otorgamiento de Crédito CAN | Banco Otorgante | Banco Ordenante |
| C53 | Prelación | CECOBAN (generado) | Banco Ordenante + Banco Otorgante |
| C54 | Actualización de Cuenta CLABE | Banco Ordenante | Banco Otorgante |
| C55 | Actualización de Datos del Crédito | Banco Otorgante | Banco Ordenante |
| C56 | Cambio de Banco Ordenante | Banco Ordenante | Banco Otorgante + Banco Ordenante |
| C57 | Entrega de Información de Créditos | CECOBAN (generado) | Banco Otorgante + Banco Ordenante |
| C58 | Otorgamiento/Mantenimiento CAN propio | Banco Ordenante o Otorgante | CECOBAN (sin entrega posterior) |

---

## Notificaciones de Expiración de Tiempo

CECOBAN publica eventos `MESSAGE_RESPONSE_TIMEOUT` en el topic `.notifications` cuando expira la ventana para recibir un mensaje esperado.

### Flujos con timeout
| Origen | Esperado | Plazo | `configuredDurationSeconds` |
|--------|----------|-------|-----------------------------|
| C50 | C51 | 30 segundos | 30 |
| C51 | C52 | 48 horas | 172800 |

### Contrato de notificación
```json
{
  "notificationId": "uuid",
  "notificationType": "MESSAGE_RESPONSE_TIMEOUT",
  "occurredAt": "2026-08-11T14:00:31",
  "institutionId": "40072",
  "environment": "produccion",
  "severity": "WARNING",
  "operation": {
    "operationUuid": "550e8400-e29b-41d4-a716-446655440000",
    "expedienteId": "uuid",
    "originMessageCode": "C50",
    "expectedMessageCode": "C51",
    "originInstitution": "40072",
    "expectedInstitution": "40014"
  },
  "timeout": {
    "windowStartedAt": "2026-08-11T14:00:00",
    "deadlineAt": "2026-08-11T14:00:30",
    "detectedAt": "2026-08-11T14:00:31",
    "configuredDurationSeconds": 30
  },
  "status": "EXPIRED",
  "reasonCode": "EXPECTED_MESSAGE_NOT_RECEIVED",
  "message": "Expiró la ventana de recepción del mensaje C51."
}
```

Las notificaciones se consumen y confirman via el mismo mecanismo Kafka (commit manual).

---

## Catálogo de Errores de la API

### HTTP 400 — Bad Request
| Código | Mensaje |
|--------|---------|
| CAN-001 | El mensaje no contiene un JSON válido. |
| CAN-002 | El mensaje no cumple con el JSON Schema. |
| CAN-003 | El código de operación no está soportado. |
| CAN-004 | Faltan campos obligatorios. |
| CAN-005 | Uno o más campos contienen un formato inválido. |
| CAN-006 | La estructura del mensaje no corresponde al código de operación indicado. |
| CAN-007 | No fue posible identificar la Institución Participante. |
| CAN-008 | El UUID es inválido. |

### HTTP 401 — Unauthorized
| Código | Mensaje |
|--------|---------|
| CAN-101 | Token de autenticación no proporcionado. |
| CAN-102 | Token de autenticación inválido. |
| CAN-103 | Token de autenticación expirado. |

### HTTP 403 — Forbidden
| Código | Mensaje |
|--------|---------|
| CAN-201 | Institución no autorizada. |
| CAN-202 | La Institución no tiene permisos para enviar ese código de operación. |
| CAN-203 | La Institución autenticada no corresponde con la indicada en el mensaje. |

### HTTP 404 — Not Found
| Código | Mensaje |
|--------|---------|
| CAN-301 | Recurso solicitado no encontrado. |

### HTTP 500 — Internal Server Error
| Código | Mensaje |
|--------|---------|
| CAN-501 | Error interno durante el procesamiento de la solicitud. |
| CAN-502 | No fue posible generar el acuse de recepción. |

---

## Trazabilidad Obligatoria — Kafka

Por cada mensaje Kafka procesado, la Institución debe registrar mínimo:

| Campo | Descripción |
|-------|-------------|
| UUID | Identificador de la operación |
| Código de operación | C50, C51, … C58 |
| Topic, partition, offset | Posición exacta en Kafka |
| Fecha y hora de recepción | Timestamp de consumo |
| Fecha y hora de inicio de procesamiento | Timestamp interno |
| Fecha y hora de conclusión | Timestamp interno |
| Fecha y hora de commit | Timestamp del offset confirm |
| Resultado del procesamiento | OK / ERROR |
| Número de reintentos | Contador |
| Fecha, hora y resultado de cada reintento | Log de reintentos |
| Código y descripción de errores | Si aplica |

**Prohibido incluir en logs**: Client Secret, tokens JWT completos, ni otras credenciales.

---

## Seguridad — Componentes

| Componente | Propósito |
|------------|-----------|
| TLS 1.3 | Cifrado de todas las comunicaciones |
| JWT | Autenticación de APIs REST y Canal Kafka |
| HTTPS | Transporte seguro REST |
| Certificado Digital | Identificación del servidor CECOBAN |
| SASL/OAUTHBEARER | Mecanismo Kafka para presentar JWT |
| KeyPass | Canal seguro para entrega de credenciales (Client ID + Client Secret) |

---

## Credenciales por Ambiente

Cada ambiente (Simulador / Producción) opera de forma independiente con credenciales propias:

| Credencial | Descripción |
|------------|-------------|
| Código de Institución | Identificador de la Institución (ej: 40072 para Santander) |
| Client ID | Identificador técnico para autenticación |
| Client Secret | Credencial para obtener JWT — entregada via KeyPass |
| URL Base de APIs | URL del servicio REST |
| URL Servicio de Autenticación | URL para obtener JWT |
| URL Canal de Mensajería | Bootstrap server Kafka |
| Topic Asignado | Topics autorizados para consumo |
| Consumer Group | Identificador del consumidor Kafka |
| Topic de Notificaciones | `can.<ambiente>.<institucion>.notifications` |
| Puerto API | TCP/443 |
| Puerto Kafka | TCP/9093 |
| Seguridad Kafka | TLS 1.3 + SASL/OAUTHBEARER con JWT |

---

## Contratos JSON — Documentos Oficiales

| Código | Documento |
|--------|-----------|
| C50 | CAN Codigo 50 schema.json |
| C51 | CAN Codigo 51 schema.json |
| C52 | CAN Codigo 52 schema.json |
| C53 | CAN Codigo 53 schema.json |
| C54 | CAN Codigo 54 schema.json |
| C55 | CAN Codigo 55 schema.json |
| C56 | CAN Codigo 56 schema.json |
| C57 | CAN Codigo 57 schema.json |
| C58 | CAN Codigo 58 schema.json |
| Notificación | CAN Schema notification-msg-timeout.json |

---

## Catálogos de Referencia (CECOBAN)

Los catálogos forman parte de los contratos JSON publicados por CECOBAN:

- Catálogo Bancos
- Catálogo Causas de Rechazo
- Catálogo Código de Operación
- Catálogo Estado de Solicitud
- Catálogo Estatus
- Catálogo Frecuencia
- Catálogo Información del Nominado
- Catálogo Meses
- Catálogo Periodicidad
- Catálogo Tipo de Crédito

---

*Fuente: DET-430801-CANO v1.2 (19/08/2026) + DE CAN v4.2 (25/08/2026) + Guía Simulador CAN v1.2 (19/08/2026) · Extraído 2026-09-17*
