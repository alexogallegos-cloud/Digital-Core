# D14 · Banca Electrónica Institucional (BEI) — Excepciones y Manejo de Errores

> **Componente:** Informix · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático de excepciones en código SPL)
- Domain Expert — BanCoppel (validación del comportamiento esperado)
- Core Banking Transformation (mapeo de excepciones en target middleware)
- SRE & AIOps (runbooks de operación ante cada excepción)
- Cybersecurity (excepciones regulatorias — CNBV audit trail)

> `[SME-PENDING]` = requiere sesión de validación con el Domain Expert BanCoppel antes de Etapa 2.
---

## Descripción

Catálogo de excepciones del dominio `bdibei`. El análisis estático ha verificado 2 SPs del callgraph en detalle (`getrandomcode`, `desbloque`). Los 294 SPs aislados requieren análisis de Etapa 2.

**PRIORIDAD CRÍTICA:** los 5 códigos de error del ESB documentados en INC-006 afectan pagos masivos de este dominio. El código 4394 en el contexto del batch de nómina es el escenario de mayor riesgo del proyecto SPE-AM-001.

## Resumen de análisis estático (42 SPs callgraph)

| Métrica | Valor |
|---------|-------|
| SPs con RAISE EXCEPTION detectados | `[SME-PENDING]` — análisis Etapa 2 |
| SPs con ON EXCEPTION detectados | `[SME-PENDING]` — análisis Etapa 2 |
| Códigos de excepción capturados únicos | `[SME-PENDING]` |
| SPs con manejo `ON EXCEPTION … END EXCEPTION` | `[SME-PENDING]` |

## RAISE EXCEPTION — excepciones lanzadas por el dominio BEI

> `[SME-PENDING]` — requiere análisis del código fuente de los 42 SPs del callgraph y los 294 aislados.

| Código esperado | Frecuencia | SP origen probable | Significado probable |
|----------------|-----------|-------------------|--------------------|
| `[SME-PENDING]` | — | SPs de validación de convenio y dispersión | — |

## ON EXCEPTION — códigos capturados detectados en análisis

> Los SPs verificados (`getrandomcode`, `desbloque`) no tienen bloques `ON EXCEPTION` visibles en el análisis de sp-specs. Los 294 SPs aislados tienen alta probabilidad de manejar excepciones dado el patrón observado en otros dominios BanCoppel.

---

## BLOQUE CRÍTICO — Códigos de error ESB (INC-006)

> **Fuente:** `migration-risk-register.md` P655-R005 · `21-observability-runbook.md` INC-D14-01
> **Fecha de evidencia:** logs 2026-04-24

Los siguientes 5 códigos de error del ESB de BanCoppel **no están documentados en los runbooks actuales del dominio bdibei**. Afectan todas las integraciones ESB, incluyendo los pagos masivos y la dispersión de nómina de BEI.

### Código 4394 — IBM MQ MbUserException (MÁXIMA PRIORIDAD)

| Atributo | Valor |
|----------|-------|
| **Código** | `4394` |
| **Descripción técnica** | IBM MQ Message Broker User Exception — excepción no manejada en el plugin Java del ESB |
| **Frecuencia sistema** | 2,452 ocurrencias/día (total BanCoppel — proporción BEI `[DATO-REQUERIDO]`) |
| **Protocolo ESB** | IBM Integration Bus (IIB) / IBM MQ |
| **Prioridad** | CRÍTICA — máxima en este dominio |

**Por qué es crítico específicamente para el batch de nómina BEI:**

En transacciones en línea (canal web, app móvil), un error 4394 afecta a un solo cliente que puede reintentar. En el batch de nómina BEI, el SP recorre un lote de cientos o miles de beneficiarios secuencialmente. Si el error 4394 ocurre durante el procesamiento del lote y el batch no tiene `ON EXCEPTION` con reintentos y `ROLLBACK` parcial adecuados:

```
Escenario de riesgo máximo:
  1. Scheduler ejecuta sp_bei_batch_nomina() [nombre real = SME-PENDING]
  2. El batch inicia el recorrido de 5,000 beneficiarios
  3. En el beneficiario #1,247, la llamada al ESB devuelve error 4394
  4. Si el SP no tiene ON EXCEPTION → el bloque SQL lanza error Informix
  5. Si no hay ROLLBACK parcial → todos los 5,000 registros quedan en estado inconsistente
  6. Si el scheduler no tiene retry del job → el batch no se vuelve a ejecutar
  7. La quincena cierra: 5,000 empleados sin pago
```

**Plan de mitigación para el target (microservicio BEIDispersionService):**
1. Implementar retry con backoff exponencial para llamadas al ESB/MSK (max 3 intentos · 2s · 4s · 8s).
2. Procesamiento de lotes con checkpoint: si falla un subgrupo, los completados se mantienen y solo se reintenta el subgrupo fallido.
3. Alerta automática P1 si el batch de nómina no completa en ≤ 2× el tiempo esperado.
4. Tabla de reconciliación `bei_dispersiones_pendientes` para registros sin confirmación.
5. Notificación automática a operaciones BEI si el job falla (no solo log).

**Equivalente en target:** `com.bancoppel.bei.exception.ESBMessagingException` con código `ESB-4394`. Mapear a HTTP 503 (Service Unavailable) con `Retry-After` header en la API externa.

---

### Código 3743 — SOAP Handle Timed-out

| Atributo | Valor |
|----------|-------|
| **Código** | `3743` |
| **Descripción técnica** | Timeout en conexión SOAP/JNI con sistema externo (~30 segundos) |
| **Frecuencia sistema** | 761 ocurrencias/día |
| **Impacto BEI** | Pagos masivos que dependen de servicios SOAP externos (validaciones de beneficiario, SPEI) |

**Comportamiento actual:** el SP espera la respuesta del ESB hasta el timeout de ~30s. En un batch de nómina con miles de beneficiarios, si cada uno genera un timeout de 30s, el batch puede tardar horas en completar o fallar por timeout del job.

**Mitigación target:** timeout agresivo (5s) + circuit breaker (Resilience4j). Pasar al siguiente beneficiario y marcar el actual como PENDIENTE para reconciliación posterior.

**Equivalente en target:** `com.bancoppel.bei.exception.ESBTimeoutException` → HTTP 504.

---

### Código 3701 — JNI/Axis2 non-SOAP call error

| Atributo | Valor |
|----------|-------|
| **Código** | `3701` |
| **Descripción técnica** | Error en JNI Call — Axis2Invoker fallo de comunicación, llamada no-SOAP |
| **Frecuencia sistema** | 356 ocurrencias/día |
| **Impacto BEI** | Integraciones legado que usan Axis2 para comunicación con sistemas externos BEI |

**Mitigación target:** eliminar la dependencia de JNI/Axis2. El target usará clientes HTTP nativos (OkHttp / Apache HttpClient) o AWS SDK según el servicio destino.

**Equivalente en target:** `com.bancoppel.bei.exception.ESBProtocolException` → HTTP 502.

---

### Código 3165 — SSL socket error on connect

| Atributo | Valor |
|----------|-------|
| **Código** | `3165` |
| **Descripción técnica** | Error SSL al establecer conexión TLS con endpoint externo |
| **Frecuencia sistema** | 320 ocurrencias/día |
| **Impacto BEI** | Comunicaciones HTTPS con servicios externos (validaciones, notificaciones) |

**Causa probable:** certificado expirado, versión TLS incompatible (TLS 1.0/1.1 deprecados), o error de handshake por renovación de certificado en el servidor destino.

**Mitigación target:** certificados gestionados por AWS Certificate Manager. Forzar TLS 1.2+. Alerta proactiva 30 días antes de expiración de certificados de endpoints externos.

**Equivalente en target:** `javax.net.ssl.SSLException` → capturar y escalar a `ESBSSLException` → HTTP 503.

---

### Código 6233 — Sin descripción disponible

| Atributo | Valor |
|----------|-------|
| **Código** | `6233` |
| **Descripción técnica** | `[SME-PENDING]` — código no documentado en manual ESB BanCoppel |
| **Frecuencia sistema** | 264 ocurrencias/día |
| **Impacto BEI** | `[SME-PENDING]` |

**Acción requerida:** `[SME-PENDING]` sesión con equipo ESB BanCoppel para obtener descripción. Hasta entonces, tratar como error genérico de ESB con mismo patrón de mitigación que 4394.

---

## Mapeo de excepciones ESB al target

| Código ESB actual | Excepción Java target | HTTP status | Estrategia de manejo |
|------------------|-----------------------|-------------|---------------------|
| 4394 (IBM MQ) | `ESBMessagingException` | 503 | Retry x3 + checkpoint batch + alerta P1 |
| 3743 (SOAP timeout) | `ESBTimeoutException` | 504 | Retry x2 + circuit breaker 5s |
| 3701 (JNI/Axis2) | `ESBProtocolException` | 502 | Retry x1 + fallback degradado |
| 3165 (SSL) | `ESBSSLException` | 503 | Alert inmediato + no retry (SSL no mejora con retry) |
| 6233 (desconocido) | `ESBUnknownException` | 503 | Retry x2 + alerta + `[SME-PENDING]` |

---

## Excepciones de negocio esperadas en el dominio BEI

Estas excepciones son parte del diseño de negocio y deben mapearse a respuestas HTTP específicas en el target:

| Condición | Código de retorno Informix actual | HTTP target | Descripción |
|-----------|----------------------------------|-------------|-------------|
| Convenio inactivo/bloqueado | `[SME-PENDING]` | 403 Forbidden | Empresa no autorizada para dispersar |
| Límite de dispersión excedido | `[SME-PENDING]` | 422 Unprocessable | Monto supera límite del convenio |
| CLABE beneficiario inválida | `[SME-PENDING]` | 400 Bad Request | Dígito verificador CLABE incorrecto |
| Beneficiario dado de baja | `[SME-PENDING]` | 422 Unprocessable | Beneficiario inactivo en nómina |
| Dispersión fuera de horario | `[SME-PENDING]` | 422 Unprocessable | Después del horario máximo del convenio |
| Duplicado de archivo nómina | `[SME-PENDING]` | 409 Conflict | Folio ya procesado (idempotencia) |

---

## Patrones de excepción críticos en SPs verificados

### `getrandomcode` — sin manejo de excepción detectado

El SP `getrandomcode` (9 bloques de cálculo LCG + 1 acceso a `systables`) no tiene bloques `ON EXCEPTION` visibles en el análisis. Esto significa que cualquier error de `systables` (tabla locked, instancia no disponible) causaría una excepción Informix no manejada que propagaría al caller.

**Riesgo:** si `systables` está locked durante el login de una empresa vía BEI, la autenticación falla sin mensaje de error amigable.

**Mitigación target:** el generador de OTP en el microservicio target no debe depender de ninguna tabla de base de datos para su semilla. Usar `java.security.SecureRandom` puro.

---

## Códigos de excepción Informix comunes relevantes para BEI

| Código | Descripción | Contexto BEI |
|--------|-------------|-------------|
| `-268` | Unique constraint violation | Folio duplicado de dispersión |
| `-271` | NOT NULL constraint | Campo requerido en registro de beneficiario |
| `-691` | Deadlock | Contención en tabla `bei_dispersiones` durante batch |
| `-243` | Could not lock record | Timeout de lock en procesamiento paralelo |
| `100` | Not found (SQLNOTFOUND) | Beneficiario o convenio no encontrado |
| `-746` | Row size too large | Inserción con datos de empresa muy largos |

---
*Generado por: Specialist — Informix SPL Analysis + DT-Riesgos · 2026-08-03 · Fuente: INC-006 (P655-R005), sp-specs-bdibei.md, migration-risk-register.md, 21-observability-runbook.md*
