# Simulador CAN — Guía de Conexión y Validación de Acceso
> Fuente: Guía de Conexión y Validación de Acceso al Simulador CAN v1.2 (19/08/2026)
> Propósito: Configurar y validar la conectividad técnica con el Simulador CECOBAN antes de UAT y Producción

---

## Propósito del Simulador

El Simulador CAN permite que la Institución Participante pruebe la **integración técnica de entrada y salida**. Las reglas, datos y respuestas del Simulador son demostrativas — **no sustituyen el comportamiento funcional definitivo del Sistema CAN**.

---

## Parámetros de Conexión del Simulador CAN

| Parámetro | Valor | Estado |
|-----------|-------|--------|
| IP del Simulador CAN | `148.250.112.14` | Asignado |
| Puerto HTTPS | `443/TCP` | Definido |
| Puerto Kafka | `9093/TCP` | Definido |
| Ruta de autenticación | `/security/token` | Definido |
| Ruta API de mensajes | `/api/can/v1/operaciones` | Definido |
| Ruta de documentación | `/api-docs` | Definido |
| Seguridad API | TLS 1.3 + JWT | Definido |
| Seguridad Kafka | TLS 1.3 + SASL/OAUTHBEARER + JWT | Definido |
| Topic de notificaciones | `can.<ambiente>.<institucion>.notifications` | Definido |

El Bootstrap Server, nombres DNS, Client ID, Client Secret, Consumer Group y lista de topics se entregan junto con el **paquete de conectividad del Simulador** via KeyPass.

---

## Nomenclatura de Topics — Ambiente Simulador

Para una institución con código `40072` (referencia Santander):

```
can.simulador.40072.c50
can.simulador.40072.c51
can.simulador.40072.c52
can.simulador.40072.c53
can.simulador.40072.c54
can.simulador.40072.c55
can.simulador.40072.c56
can.simulador.40072.c57
can.simulador.40072.c58
can.simulador.40072.notifications
```

Consumer Group: `can.simulador.40072`

---

## Reglas de Firewall Requeridas

```
<IP/NAT_BANCO_AUTORIZADA> -> 148.250.112.14:443/TCP   (HTTPS + autenticación)
<IP/NAT_BANCO_AUTORIZADA> -> 148.250.112.14:9093/TCP  (Kafka)
```

La Institución debe informar a CECOBAN **antes de conectarse** las IPs públicas o NAT de salida que utilizará. Conexiones desde IPs no registradas serán rechazadas aunque las credenciales sean correctas.

### Información a enviar a CECOBAN
| Dato | Información requerida |
|------|-----------------------|
| Institución | Santander México |
| Código de Institución | 40072 (confirmar con CECOBAN) |
| IP/NAT de origen para HTTPS | Por definir |
| IP/NAT de origen para Kafka | Por definir |
| Contacto técnico | Por definir |
| Observaciones de red | Por definir |

---

## Paso 1 — Resolución DNS

Cuando CECOBAN entregue los nombres DNS, registrarlos en DNS interno o en el archivo hosts apuntando a `148.250.112.14`:

```
# Windows: C:\Windows\System32\drivers\etc\hosts
148.250.112.14 nombre-api-entregado-por-cecoban
148.250.112.14 nombre-kafka-entregado-por-cecoban
```

**Validación DNS (PowerShell):**
```powershell
nslookup nombre-api-entregado-por-cecoban
nslookup nombre-kafka-entregado-por-cecoban
```

Nota: ICMP (ping) puede estar bloqueado — no usarlo como prueba de conectividad.

---

## Paso 2 — Validar Conectividad HTTPS (Puerto 443)

```powershell
Test-NetConnection 148.250.112.14 -Port 443
# Resultado esperado: TcpTestSucceeded : True
```

Alternativa:
```
telnet 148.250.112.14 443
```

---

## Paso 3 — Validar Documentación API

Acceder a `https://<nombre-api>/api-docs` en el navegador. Debe mostrar la documentación Scalar/OpenAPI con el endpoint de autenticación y la API única de mensajes.

---

## Paso 4 — Obtener JWT

```bash
curl -X POST https://<nombre-api>/security/token \
  -H "Content-Type: application/json" \
  -d '{"clientId": "BANCO40014", "clientSecret": "********"}'
```

Respuesta esperada:
```json
{
  "accessToken": "eyJhbGciOi...",
  "tokenType": "Bearer",
  "expiresIn": 900,
  "issuedAt": "2026-08-18T14:35:28"
}
```

---

## Paso 5 — Enviar Mensaje de Prueba via API

```bash
curl -X POST "${CAN_API_BASE_URL}/api/can/v1/operaciones" \
  -H "Authorization: Bearer ${CAN_JWT}" \
  -H "Content-Type: application/json" \
  --data-binary @c50-prueba.json
```

ACK esperado:
```json
{
  "uuid": "550e8400-e29b-41d4-a716-446655440000",
  "timestamp": "2026-08-18T14:35:28",
  "status": "ACCEPTED",
  "errors": []
}
```

Registrar el UUID y la hora de la operación.

---

## Paso 6 — Validar Conectividad Kafka (Puerto 9093)

```powershell
Test-NetConnection 148.250.112.14 -Port 9093
# Resultado esperado: TcpTestSucceeded : True
```

Una conexión TCP exitosa solo confirma la ruta de red. La validación completa requiere establecer TLS, autenticarse via JWT y obtener metadata de Kafka.

---

## Paso 7 — Configurar Consumidor Kafka

```properties
bootstrap.servers=<HOST_KAFKA>:9093
security.protocol=SASL_SSL
sasl.mechanism=OAUTHBEARER
group.id=can.simulador.40072
enable.auto.commit=false
auto.offset.reset=earliest
```

El JWT se proporciona al mecanismo OAUTHBEARER del cliente Kafka. La Institución renueva el token antes de su expiración.

---

## Paso 8 — Prueba de Extremo a Extremo

### Banco → CECOBAN
1. Obtener JWT via `POST /security/token`
2. Enviar mensaje CAN via `POST /api/can/v1/operaciones`
3. Confirmar HTTP 200 y ACK con status ACCEPTED
4. Registrar UUID y hora

### CECOBAN → Banco
1. Mantener consumidor Kafka activo con JWT vigente
2. CECOBAN publica mensaje de prueba en el topic autorizado
3. Recibir el mensaje; registrar topic/partition/offset
4. Procesar el JSON
5. Realizar commit manual del offset
6. CECOBAN verifica el avance del offset en el monitoreo del Simulador

### Criterio de éxito
La conectividad se considera validada cuando la Institución puede:
- Autenticarse y obtener JWT
- Enviar un mensaje y recibir ACK
- Autenticarse en Kafka
- Consumir un mensaje de un topic autorizado
- Confirmar el procesamiento via commit manual

---

## Evidencias Requeridas (sin exponer secretos)

| Evidencia | Descripción |
|-----------|-------------|
| Resultado nslookup | Resolución DNS de hosts API y Kafka |
| Test-NetConnection 443 | Confirmación TCP a puerto 443 |
| Acceso /api-docs | Screenshot de la documentación Scalar |
| HTTP status JWT | Código HTTP de `/security/token` (sin mostrar token) |
| ACK de /api/can/v1/operaciones | JSON de respuesta con UUID |
| Test-NetConnection 9093 | Confirmación TCP a puerto 9093 |
| Log conexión Kafka | Sin credenciales ni tokens |
| Topic, partition, offset recibido | Del mensaje de prueba Kafka |
| Evidencia commit | Confirmación del offset |
| Notificación MESSAGE_RESPONSE_TIMEOUT | Del topic `.notifications` cuando aplique |

---

## Solución de Problemas

| Síntoma | Posible causa | Acción recomendada |
|---------|---------------|-------------------|
| DNS no resuelve | DNS/hosts no configurado | Validar registro interno o archivo hosts |
| 443 no conecta | Firewall/NAT/lista blanca | Confirmar IP origen registrada y salida TCP/443 |
| 401 en /security/token | Client ID/Secret inválido | Validar credenciales con CECOBAN |
| 403 en API | Institución/permiso no autorizado | Validar código de institución, scopes y lista blanca |
| 400 en API | JSON/Schema inválido | Validar mensaje contra el JSON Schema correspondiente |
| 9093 no conecta | Firewall/NAT/lista blanca | Confirmar salida TCP/9093 e IP de origen registrada |
| TLS Kafka falla | Certificado/hostname/confianza | Validar DNS y cadena de confianza |
| Kafka autentica pero no consume | Topic/ACL/Consumer Group | Validar topic autorizado y configuración de group.id |
| 404 en API | Recurso no encontrado | Validar la ruta y el recurso conforme al contrato de la API |

---

## Datos para Incidente (sin Client Secret ni JWT completo)

- Institución y código
- Fecha y hora del incidente
- IP/NAT de origen utilizada
- Host y puerto destino
- UUID de la operación (si existe)
- Código HTTP o mensaje de error
- Para Kafka: topic, partition, offset y Consumer Group

---

## Lista de Verificación — Checklist de Conectividad

| # | Actividad | Estado |
|---|-----------|--------|
| 1 | IPs de origen registradas en lista blanca CECOBAN | ☐ |
| 2 | DNS o archivo hosts configurado | ☐ |
| 3 | TCP/443 confirmado | ☐ |
| 4 | Documentación /api-docs accesible | ☐ |
| 5 | JWT obtenido exitosamente | ☐ |
| 6 | Mensaje C50 enviado con ACK ACCEPTED | ☐ |
| 7 | TCP/9093 confirmado | ☐ |
| 8 | Kafka configurado con TLS + JWT | ☐ |
| 9 | Topic(s) autorizado(s) suscritos | ☐ |
| 10 | Mensaje recibido de Kafka | ☐ |
| 11 | Commit manual realizado | ☐ |
| 12 | Notificación del topic `.notifications` consumida | ☐ |

---

*Fuente: Guía de Conexión y Validación de Acceso al Simulador CAN v1.2 (19/08/2026) · Extraído 2026-09-17*
