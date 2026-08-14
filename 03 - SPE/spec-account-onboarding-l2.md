# spec-account-onboarding-l2
> Spec Driven Design · Ejemplo Hipotético · Accenture México · Digital Core
> Offering: 03 — Software & Platform Engineering · Lifecycle: DevOps Classic
> Versión: 0.1.0 · Estado: DRAFT · Fecha: 2026-06-30

---

## §00 — Header & Component Identity

### 00.1–00.6 Ficha del Componente

| Campo | Valor |
|---|---|
| **Component ID** | `spe-account-onboarding-l2` |
| **Nombre** | Servicio de Apertura Digital de Cuenta Nivel 2 |
| **Tipo** | Microservicio REST + Event-Driven |
| **Offering** | 03 — Software & Platform Engineering |
| **Lifecycle Variant** | DevOps Classic |
| **Owner — Equipo** | Squad Digital Onboarding |
| **Owner — Lead Architect** | Por designar (Accenture MX) |
| **Owner — Product Owner** | Por designar (cliente) |
| **Estado** | `DRAFT` |
| **Versión Spec** | 0.1.0 |
| **Fecha creación** | 2026-06-30 |
| **Última actualización** | 2026-06-30 |

### 00.6 Changelog

| Versión | Fecha | Autor | Cambio |
|---|---|---|---|
| 0.1.0 | 2026-06-30 | alejandro.gallegos@accenture.com | Creación inicial — spec completo para ejemplo SDD |

### 00.7 Specs Relacionados

| Spec | Relación | Dirección |
|---|---|---|
| `spe-identity-verification` | Provee resultado de verificación biométrica | Upstream |
| `spe-aml-screening` | Provee resultado de revisión PLD/AML | Upstream |
| `spe-core-banking-adapter` | Recibe instrucción de apertura de cuenta | Downstream |
| `spe-notification-service` | Consume eventos para notificar al cliente | Downstream |
| `mdp-customer-data-contract` | Data contract compartido — entidad Customer | Peer |

### 00.8 Glosario

| Término | Definición |
|---|---|
| Cuenta N2 | Cuenta de depósito Nivel 2 per Disposiciones CNBV — límite mensual 3,000 UDIS (~$25,000 MXN) |
| CURP | Clave Única de Registro de Población — identificador único de personas físicas en México |
| KYC | Know Your Customer — proceso de debida diligencia de identidad del cliente |
| PLD | Prevención de Lavado de Dinero — cumplimiento SHCP/LFPIORPI |
| RENAPO | Registro Nacional de Población — autoridad oficial de validación de CURP |
| UDIS | Unidades de Inversión — unidad indexada a inflación usada para límites regulatorios |
| Liveness | Prueba biométrica que verifica que la imagen capturada proviene de una persona viva (anti-spoofing) |
| ApplicationSession | Entidad que representa el estado de una solicitud de apertura en curso |
| Outbox Pattern | Patrón de publicación de eventos via tabla transaccional para garantizar at-least-once delivery |

---

## §01 — Propósito y Contexto de Negocio

### 01.1 Problem Statement

El proceso actual de apertura de cuenta requiere presencia física en sucursal, toma entre 3 y 5 días hábiles, y tiene una tasa de abandono del 67% en el paso de entrega de documentos. En el segmento objetivo (adultos no bancarizados o sub-bancarizados en México, 25–45 años, smartphone-first), la tolerancia de espera es < 10 minutos y el canal preferido es el móvil.

La regulación CNBV (Disposiciones de carácter general aplicables a las instituciones de crédito, Art. 320-Bis) permite apertura de cuenta Nivel 2 de forma 100% digital con CURP y validación biométrica — sin documentación física. Este componente implementa ese journey end-to-end.

### 01.2 Business Value

| Métrica | Estado Actual | Target Post-Implementación |
|---|---|---|
| Tiempo promedio de apertura | 3–5 días hábiles | < 8 minutos |
| Tasa de abandono en onboarding | 67% | < 25% |
| Costo por cuenta aperturada | $450 MXN | $85 MXN |
| Cuentas aperturadas por mes (digital) | 0 | 15,000 |
| NPS del proceso de onboarding | 12 | ≥ 55 |
| Tasa de fraude en onboarding | N/A (canal presencial) | ≤ 0.05% |

### 01.3 Bounded Context

**Nombre**: `CustomerOnboarding`

**Límites**: Este contexto es responsable del journey completo desde la solicitud hasta la activación de la cuenta. No gestiona productos (crédito, inversión), ni transacciones post-apertura, ni la relación comercial continua con el cliente. La entidad `Customer` se origina aquí y se comparte (read-only) con contextos downstream a través del Event Bus.

### 01.4 Scope

**Dentro del scope — MVP:**
- Captura de datos personales del solicitante (CURP, nombre, email, teléfono)
- Validación de CURP contra RENAPO (fuente oficial)
- Verificación biométrica facial: liveness detection + match contra foto de CURP
- Screening PLD/AML contra listas (OFAC, ONU, SHCP-PLDFT)
- Generación y firma digital del contrato de adhesión
- Apertura de cuenta en core bancario (vía adapter)
- Notificación al cliente por SMS, push notification y email

**Fuera del scope explícito:**
- Asignación y envío de tarjeta de débito física (componente `spe-card-issuance`)
- Onboarding de personas morales (spec independiente)
- Cuentas Nivel 1, 3 y 4 (specs independientes por nivel regulatorio)
- Gestión post-apertura: cambio de datos, bajas, upgrades de nivel
- KYC extendido para Nivel 3/4

### 01.5 Stakeholders

| Rol | Responsabilidad en este spec |
|---|---|
| Product Owner (cliente) | Priorización de capacidades, aceptación formal del spec |
| Lead Architect (ACN) | Decisiones de arquitectura, firma de ADRs |
| Compliance Officer (cliente) | Validación de controles CNBV/PLD/LFPDPPP, sign-off regulatorio |
| Core Banking Owner (cliente) | Interfaz con sistema origen, SLA del adapter |
| CISO (cliente) | Aprobación de threat model y catálogo de controles §06 |
| SME Software Engineering (ACN) | Autor principal del spec técnico |
| SME Data Architect (ACN) | Autor de §04 |
| SME Cloud Security & DevSecOps (ACN) | Autor de §06.3–06.7 |
| SME GRC (ACN) | Autor de §06.8 |

### 01.6 Métricas de Éxito (Negocio)

- **Conversión**: solicitudes iniciadas → cuentas activas ≥ 75% al mes 3
- **Time-to-account**: mediana ≤ 8 minutos desde inicio hasta cuenta activa
- **Tasa de fraude**: ≤ 0.05% de cuentas aperturadas en primeros 90 días
- **Cumplimiento CNBV**: 0 observaciones en primera auditoría post go-live

### 01.7 Restricciones de Negocio

| Restricción | Fuente | Impacto en el diseño |
|---|---|---|
| Canal 100% digital, sin firma física | Decisión de producto | Requiere firma electrónica válida (NOM-151 o equivalente) |
| Solo personas físicas con CURP mexicano | CNBV Art. 320-Bis | CURP obligatorio; extranjeros con CURP también aplican |
| Límite operacional 3,000 UDIS/mes (~$25k MXN) | CNBV Art. 320-Bis | Lógica de control de límite en core bancario, no en este servicio |
| Retención de evidencia KYC por 10 años | CNBV + LFPIORPI | Almacenamiento seguro cifrado; biometría no se puede eliminar antes del plazo |
| No revelar razón de rechazo AML al cliente | SHCP — LFPIORPI Art. 24 (tipping-off) | Mensaje genérico al cliente; log interno completo para cumplimiento |
| Go-live MVP: Q4 2026 | Roadmap producto | Restricción de alcance: CAP-001 a CAP-007 únicamente |

---

## §02 — Capacidades Funcionales

### 02.1 Catálogo de Capacidades

| ID | Capacidad | Actor | Prioridad MoSCoW |
|---|---|---|---|
| CAP-001 | Iniciar solicitud de apertura | Cliente (app móvil / web) | Must |
| CAP-002 | Validar CURP contra RENAPO | Sistema (automático) | Must |
| CAP-003 | Capturar y verificar identidad biométrica | Cliente + Sistema | Must |
| CAP-004 | Ejecutar screening PLD/AML | Sistema (automático) | Must |
| CAP-005 | Generar y firmar contrato de adhesión | Cliente | Must |
| CAP-006 | Aperturar cuenta en core bancario | Sistema (automático) | Must |
| CAP-007 | Notificar al cliente sobre resultado | Sistema (automático) | Must |
| CAP-008 | Consultar estado de solicitud en curso | Cliente | Should |
| CAP-009 | Reanudar solicitud abandonada | Cliente | Should |
| CAP-010 | Generar reporte de auditoría por solicitud | Oficial de Cumplimiento | Must |

### 02.2–02.5 Detalle por Capacidad

#### CAP-001 — Iniciar solicitud de apertura

| Campo | Detalle |
|---|---|
| **Actor** | Cliente desde app móvil o navegador web |
| **Pre-condición** | El CURP no tiene cuenta activa ni solicitud abierta con el banco |
| **Post-condición** | `ApplicationSession` creada con status `INITIATED`; evento `OnboardingStarted` emitido |
| **BR-001** | Una misma persona (CURP) solo puede tener una solicitud activa en paralelo |
| **BR-002** | La sesión expira si no se completa en 72 horas desde su creación |
| **BR-003** | El cliente debe aceptar explícitamente términos y aviso de privacidad; sin esto no se crea la sesión |
| **Caso borde** | CURP con cuenta ya existente → `409 CURP_ALREADY_EXISTS` |
| **Caso borde** | CURP con formato inválido → `422 CURP_FORMAT_INVALID` (validación en cliente antes de API) |
| **Caso borde** | Solicitud previa activa → `409 APPLICATION_ALREADY_IN_PROGRESS` con applicationId existente |

#### CAP-003 — Capturar y verificar identidad biométrica

| Campo | Detalle |
|---|---|
| **Actor** | Cliente (captura en dispositivo) + proveedor biométrico externo (verificación) |
| **Pre-condición** | CAP-002 completado con resultado `CURP_VALID` |
| **Post-condición** | `ApplicationSession.biometricStatus = VERIFIED` o `REJECTED`; evento `BiometricVerificationCompleted` emitido |
| **BR-007** | Máximo 3 intentos de liveness antes de suspender la sesión 24 horas |
| **BR-008** | Facial match score debe ser ≥ 0.85 para aprobar (comparado vs. foto de CURP en RENAPO) |
| **BR-009** | Liveness score debe ser ≥ 0.90 (anti-spoofing — previene uso de fotos impresas o pantallas) |
| **Caso borde** | Foto con gafas oscuras / obstrucción facial → instrucción al usuario, no cuenta como intento |
| **Caso borde** | Iluminación insuficiente detectada → instrucción al usuario, no cuenta como intento |
| **Caso borde** | 3 intentos fallidos → sesión a `ABANDONED`, notificación al cliente, bloqueo 24h en CURP |

#### CAP-004 — Screening PLD/AML

| Campo | Detalle |
|---|---|
| **Actor** | Sistema (automático post-biometría) |
| **Pre-condición** | `ApplicationSession.biometricStatus = VERIFIED` |
| **Post-condición** | `amlStatus = CLEARED` o `REJECTED`; evento `AMLScreeningCompleted` emitido |
| **BR-011** | Consulta de listas: OFAC SDN, ONU Consolidada, SHCP-PLDFT lista interna, Interpol |
| **BR-012** | Match exacto o fuzzy ≥ 0.90 en nombre completo + fecha de nacimiento → rechazo automático |
| **BR-013** | Match fuzzy entre 0.70 y 0.89 → escalada manual a Oficial de Cumplimiento (no bloquea automáticamente) |
| **BR-014** | Al rechazar por AML: mensaje genérico al cliente ("No fue posible completar tu solicitud"); log interno con razón real |
| **Caso borde** | Proveedor AML no disponible > 5 min → escalada a Oficial de Cumplimiento; sesión en `PENDING_REVIEW` |

### 02.6 Domain Events por Capacidad

| Evento | Capacidad | Trigger |
|---|---|---|
| `OnboardingStarted` | CAP-001 | Sesión creada exitosamente |
| `CURPValidated` | CAP-002 | RENAPO confirma CURP válido |
| `BiometricVerificationCompleted` | CAP-003 | Proveedor biométrico retorna resultado |
| `AMLScreeningCompleted` | CAP-004 | Proveedor AML retorna resultado |
| `ContractSigned` | CAP-005 | Cliente firma contrato digitalmente |
| `AccountOpened` | CAP-006 | Core bancario confirma cuenta creada |
| `OnboardingCompleted` | CAP-006→007 | Journey completo — éxito end-to-end |
| `OnboardingRejected` | CAP-003 / CAP-004 | Rechazo biométrico definitivo o AML |
| `OnboardingAbandoned` | CAP-002 / sistema | Sesión expirada (72h) o max intentos |

### 02.7 Mapa de Capacidades → Bounded Context

Todas las capacidades CAP-001 a CAP-010 pertenecen íntegramente al bounded context `CustomerOnboarding`. La entidad `Account` se origina en `CoreBanking` al procesar CAP-006 — este servicio solo recibe el `accountId` como confirmación.

---

## §03 — Contratos de Interfaz (API / Events)

### 03.1 Endpoints REST — OpenAPI Reference

> Archivo fuente: `/api/openapi/account-onboarding-v1.yaml` (en el repo del componente)

```
Base URL producción:  https://api.{bank}.com.mx/onboarding/v1
Base URL staging:     https://api-staging.{bank}.com.mx/onboarding/v1

POST   /applications                      Iniciar solicitud                (CAP-001)
GET    /applications/{id}                 Consultar estado                 (CAP-008)
POST   /applications/{id}/resume          Reanudar sesión expirada         (CAP-009)
POST   /applications/{id}/biometric       Enviar captura biométrica        (CAP-003)
GET    /applications/{id}/contract        Obtener contrato para revisión   (CAP-005)
POST   /applications/{id}/contract/sign   Firmar contrato                  (CAP-005)
GET    /applications/{id}/audit-log       Reporte de auditoría             (CAP-010)
```

**Payload — POST /applications (request):**
```json
{
  "curp": "GAAA900101HDFXXX00",
  "firstName": "Juan",
  "paternalLastName": "García",
  "maternalLastName": "López",
  "email": "juan.garcia@email.com",
  "phone": "+525512345678",
  "channel": "MOBILE_APP",
  "deviceFingerprint": "fp_abc123def456...",
  "acceptedTerms": true,
  "acceptedPrivacyPolicy": true,
  "acceptedBiometricConsent": true
}
```

**Respuesta 201 Created:**
```json
{
  "applicationId": "app-2026-0001234",
  "status": "INITIATED",
  "nextStep": "CURP_VALIDATION",
  "expiresAt": "2026-07-03T14:30:00Z",
  "_links": {
    "self":      { "href": "/onboarding/v1/applications/app-2026-0001234" },
    "biometric": { "href": "/onboarding/v1/applications/app-2026-0001234/biometric" }
  }
}
```

### 03.4 Catálogo de Errores

| Código | HTTP Status | Descripción | Acción recomendada para el consumer |
|---|---|---|---|
| `CURP_ALREADY_EXISTS` | 409 | El CURP ya tiene cuenta activa en el banco | Redirigir al cliente a flujo de login |
| `CURP_FORMAT_INVALID` | 422 | Formato de CURP no pasa validación de estructura | Validar formato en cliente antes de enviar; mostrar instrucción |
| `CURP_NOT_FOUND_RENAPO` | 422 | CURP no registrado o no activo en RENAPO | Instruir al cliente a actualizar registro en RENAPO |
| `APPLICATION_ALREADY_IN_PROGRESS` | 409 | Solicitud activa para este CURP | Retomar sesión existente (usar CAP-009) |
| `BIOMETRIC_LIVENESS_FAILED` | 422 | Liveness score < 0.90 | Mostrar instrucciones de captura; no revelar score |
| `BIOMETRIC_MATCH_FAILED` | 422 | Facial match score < 0.85 | Mostrar instrucciones de captura |
| `BIOMETRIC_MAX_ATTEMPTS` | 429 | 3 intentos fallidos consecutivos | Sesión suspendida 24h; informar al cliente con tiempo de espera |
| `AML_REJECTED` | 403 | Cliente en listas de restricción PLD/AML | Mostrar mensaje genérico; NO revelar razón específica (LFPIORPI Art. 24) |
| `SESSION_EXPIRED` | 410 | Sesión expirada (> 72h sin completar) | Iniciar nueva solicitud |
| `CONTRACT_ALREADY_SIGNED` | 409 | Contrato ya fue firmado previamente | No reintentar; verificar estado de solicitud |
| `CORE_BANKING_UNAVAILABLE` | 503 | Error o timeout en core bancario | Reintentar después de 5 minutos; mostrar mensaje de espera al cliente |
| `INTERNAL_SERVER_ERROR` | 500 | Error inesperado del servicio | Reintentar x1; si persiste, mostrar número de caso para soporte |

### 03.5 Política de Versionado

| Tipo de cambio | Clasificación | Protocolo |
|---|---|---|
| Nuevos campos opcionales en request/response | Non-breaking | No requiere nueva versión |
| Nuevos endpoints | Non-breaking | No requiere nueva versión |
| Nuevos valores en catálogos de error | Non-breaking | No requiere nueva versión |
| Nuevos campos requeridos en request | **Breaking** | Requiere `/v2/` |
| Eliminación de campo de response | **Breaking** | Requiere `/v2/` |
| Cambio de tipo de dato | **Breaking** | Requiere `/v2/` |
| Cambio de semántica de endpoint | **Breaking** | Requiere `/v2/` |

Al publicar `/v2/`, la versión `/v1/` se mantiene activa **mínimo 12 meses** con header `Deprecation: true` y `Sunset: {fecha}` en todas las respuestas.

### 03.7 Rate Limiting y Quotas

| Endpoint | Límite | Ventana | Acción al superar |
|---|---|---|---|
| POST /applications | 5 req / CURP | 1 hora | `429 Too Many Requests` |
| POST /biometric | 3 req / applicationId | lifetime de la sesión | `429 BIOMETRIC_MAX_ATTEMPTS` |
| POST /contract/sign | 1 req / applicationId | lifetime de la sesión | `409 CONTRACT_ALREADY_SIGNED` |
| GET /applications/{id} | 60 req / min / token | 1 minuto | `429 Too Many Requests` |

### 03.8–03.9 Autenticación y SLA por Endpoint

| Endpoint | Mecanismo de Autenticación | SLA Disponibilidad |
|---|---|---|
| POST /applications | OAuth2 `client_credentials` (app móvil registrada) | 99.9% |
| POST /biometric | OAuth2 + `X-Session-Token` (bound a `applicationId` + `deviceFingerprint`) | 99.9% |
| POST /contract/sign | OAuth2 + OTP SMS confirmado en el momento | 99.95% |
| GET /applications/{id} | OAuth2 (scope `onboarding:read`) | 99.9% |
| GET /audit-log | OAuth2 (scope `compliance:read`) — solo sistemas internos | 99.5% |

---

## §04 — Modelo de Datos y Data Contracts

### 04.1 Catálogo de Entidades

| Entidad | Bounded Context Owner | Descripción |
|---|---|---|
| `ApplicationSession` | CustomerOnboarding | Estado y metadata de una solicitud de apertura en curso |
| `ApplicantProfile` | CustomerOnboarding | Datos personales del solicitante capturados durante el proceso |
| `BiometricCapture` | CustomerOnboarding | Resultado y metadata de la verificación biométrica |
| `AMLScreeningResult` | CustomerOnboarding | Resultado del screening PLD/AML por proveedor externo |
| `OnboardingContract` | CustomerOnboarding | Contrato de adhesión generado, presentado y firmado |
| `OnboardingAuditLog` | CustomerOnboarding | Registro inmutable de cada acción del proceso (append-only) |
| `Customer` | CustomerOnboarding (origen) → read-only downstream | Cliente activo post-apertura; compartido via eventos |
| `Account` | **CoreBanking** (owned) | Cuenta bancaria creada — este servicio solo recibe el `accountId` |

### 04.3 Schemas Físicos

#### Tabla: `application_sessions`

| Columna | Tipo | Constraint | Descripción |
|---|---|---|---|
| `id` | `UUID` | PK, NOT NULL | ID único de la sesión de solicitud |
| `curp` | `CHAR(18)` | NOT NULL, INDEX | CURP del solicitante |
| `status` | `VARCHAR(30)` | NOT NULL | Ver diagrama de estados §04.2 |
| `channel` | `VARCHAR(20)` | NOT NULL | `MOBILE_APP` / `WEB_BROWSER` |
| `device_fingerprint` | `VARCHAR(512)` | NULL | Fingerprint del dispositivo del cliente |
| `current_step` | `VARCHAR(50)` | NOT NULL | Paso actual en el journey |
| `biometric_attempts` | `SMALLINT` | NOT NULL DEFAULT 0 | Contador de intentos biométricos (max 3) |
| `initiated_at` | `TIMESTAMPTZ` | NOT NULL | Timestamp de inicio de la sesión |
| `expires_at` | `TIMESTAMPTZ` | NOT NULL | `initiated_at + INTERVAL '72 hours'` |
| `completed_at` | `TIMESTAMPTZ` | NULL | Timestamp de completitud exitosa |
| `rejected_at` | `TIMESTAMPTZ` | NULL | Timestamp de rechazo (biométrico o AML) |
| `rejection_reason_code` | `VARCHAR(50)` | NULL | Código interno; NO se expone al cliente si es AML |
| `core_banking_account_id` | `VARCHAR(50)` | NULL | ID asignado por core bancario al completar |
| `created_at` | `TIMESTAMPTZ` | NOT NULL | Audit timestamp de creación |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL | Audit timestamp de última modificación |

#### Tabla: `applicant_profiles` (datos cifrados en reposo)

| Columna | Tipo | PII Class | Descripción |
|---|---|---|---|
| `id` | `UUID` | — | PK |
| `application_session_id` | `UUID` | — | FK → application_sessions |
| `curp` | `VARCHAR(18)` | `PII-HIGH` | Cifrado con KMS envelope encryption |
| `first_name` | `VARCHAR(100)` | `PII-MEDIUM` | Cifrado |
| `paternal_last_name` | `VARCHAR(100)` | `PII-MEDIUM` | Cifrado |
| `maternal_last_name` | `VARCHAR(100)` | `PII-MEDIUM` | Cifrado |
| `email` | `VARCHAR(254)` | `PII-MEDIUM` | Cifrado; hash SHA-256 en columna adicional para lookup |
| `phone` | `VARCHAR(20)` | `PII-MEDIUM` | Cifrado |
| `date_of_birth` | `DATE` | `PII-HIGH` | Cifrado (extraído de CURP + confirmado con RENAPO) |

### 04.2 Diagrama de Estados — ApplicationSession

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │                    ApplicationSession — State Machine                     │
  └──────────────────────────────────────────────────────────────────────────┘

  [POST /applications]
         │
         ▼
    ┌───────────┐
    │ INITIATED │──── timeout 72h ──────────────────────────────────┐
    └───────────┘                                                    │
         │ CURP válido en RENAPO                                     │
         ▼                                                           │
    ┌───────────────┐                                                │
    │ CURP_VERIFIED │──── CURP inválido / no encontrado ─────────┐  │
    └───────────────┘                                             │  │
         │ Biometría aprobada (liveness ≥ 0.90 + match ≥ 0.85)   │  │
         ▼                                                        │  │
    ┌────────────────────┐                                        │  │
    │ BIOMETRIC_VERIFIED │──── 3 intentos fallidos ───────────┐  │  │
    └────────────────────┘                                     │  │  │
         │ AML sin coincidencias definitivas                   │  │  │
         ▼                                                     │  ▼  ▼
    ┌─────────────┐         AML match definitivo          ┌──────────────┐
    │ AML_CLEARED │────────────────────────────────────►  │   REJECTED   │
    └─────────────┘                                        └──────────────┘
         │ Contrato firmado con OTP válido                        ▲
         ▼                                                        │
    ┌──────────────────┐    AML match fuzzy → revisión manual     │
    │ CONTRACT_SIGNED  │    (status: PENDING_REVIEW) ─────────────┘
    └──────────────────┘
         │ Core bancario confirma apertura
         ▼
    ┌───────────┐                               ┌─────────────────┐
    │ COMPLETED │        timeout 72h ──────────►│   ABANDONED     │
    └───────────┘        (desde cualquier paso) └─────────────────┘
```

### 04.4 Clasificación PII por Campo

| Campo | Entidad | Clasificación | Regulación Aplicable |
|---|---|---|---|
| `curp` | ApplicantProfile | `PII-HIGH` | LFPDPPP, CNBV Disposiciones |
| `first_name`, `last_name` | ApplicantProfile | `PII-MEDIUM` | LFPDPPP |
| `email` | ApplicantProfile | `PII-MEDIUM` | LFPDPPP |
| `phone` | ApplicantProfile | `PII-MEDIUM` | LFPDPPP |
| `date_of_birth` | ApplicantProfile | `PII-HIGH` | LFPDPPP, CNBV |
| `facial_image_vector` | BiometricCapture | `PII-BIOMETRIC` | LFPDPPP Art. 3 (datos sensibles) — requiere consentimiento explícito |
| `facial_raw_image` | BiometricCapture | `PII-BIOMETRIC` | Solo en Object Storage cifrado; retención 10 años |
| `device_fingerprint` | ApplicationSession | `PII-LOW` | Aviso de privacidad |
| `ip_address` | OnboardingAuditLog | `PII-LOW` | Aviso de privacidad |

### 04.5 Event Schema — AccountOpened (Avro)

```json
{
  "namespace": "mx.accenture.digitalcore.onboarding.events",
  "type": "record",
  "name": "AccountOpened",
  "version": "1.0.0",
  "doc": "Emitido cuando el core bancario confirma la apertura exitosa de la cuenta",
  "fields": [
    { "name": "eventId",        "type": "string",  "doc": "UUID único del evento (idempotency key)" },
    { "name": "eventTimestamp", "type": "long",    "logicalType": "timestamp-millis" },
    { "name": "applicationId",  "type": "string" },
    { "name": "customerId",     "type": "string",  "doc": "ID asignado por core bancario al customer" },
    { "name": "accountNumber",  "type": "string",  "doc": "CLABE o número de cuenta asignado" },
    { "name": "accountLevel",   "type": { "type": "enum", "name": "AccountLevel",
                                          "symbols": ["N1", "N2", "N3", "N4"] } },
    { "name": "curpHash",       "type": "string",  "doc": "SHA-256 del CURP — no PII pero trazable" },
    { "name": "channel",        "type": "string",  "doc": "MOBILE_APP | WEB_BROWSER" },
    { "name": "openedAt",       "type": "long",    "logicalType": "timestamp-millis" }
  ]
}
```

### 04.6 Política de Breaking Change en Schemas

| Tipo de cambio | Clasificación | Protocolo |
|---|---|---|
| Agregar campo opcional con default | Non-breaking | Backward compatible — se puede hacer en versión minor |
| Eliminar campo | **Breaking** | Nuevo schema version; versión anterior coexiste en Schema Registry por ≥ 6 meses |
| Cambiar tipo de campo | **Breaking** | Nuevo schema version; migración de consumers antes de deprecar anterior |
| Cambiar nombre de campo | **Breaking** | Nuevo schema version |

### 04.7 Integridad Referencial Distribuida

La relación `ApplicationSession → Account` (en CoreBanking) se mantiene vía evento `AccountOpened`. Este servicio guarda el `accountId` recibido en `application_sessions.core_banking_account_id`. No hay FK entre bases de datos — la consistencia es **eventual**, garantizada por el patrón Saga coreografiado (ADR-ONB-001).

### 04.8 Política de Retención

| Entidad / Almacén | Retención | Fundamento |
|---|---|---|
| `application_sessions` (PostgreSQL) | 10 años | CNBV Art. 58 Bis |
| `applicant_profiles` (PostgreSQL cifrado) | 10 años | CNBV + LFPIORPI |
| `facial_raw_image` (Object Storage) | 10 años | CNBV Art. 58 Bis |
| `onboarding_audit_log` (PostgreSQL append-only) | 10 años | CNBV + LFPIORPI |
| Kafka events (onboarding.events) | 7 días | Solo para reprocessing; no es almacén regulatorio |

### 04.9 Data Lineage

```
  RENAPO API ──────────────────────────────────────────────────┐
                                                               ▼
  App Móvil / Web ──► [spe-account-onboarding-l2] ──────────► ApplicationSession
                             │                    ──────────► ApplicantProfile (PostgreSQL + KMS)
  Biometric Provider API ────┤                    ──────────► BiometricCapture (metadata en PG;
                             │                                  raw image en S3/GCS cifrado)
  AML Provider API ──────────┤                    ──────────► AMLScreeningResult (PostgreSQL)
                             │
                             └──── Kafka ──────────────────► onboarding.events
                                      │
                          ┌───────────┼──────────────────────┐
                          ▼           ▼                       ▼
                   CoreBanking   Notification-Service   Customer-Data-Platform
                   (Account)     (SMS/Push/Email)        (Customer 360)
```

---

## §05 — Requisitos No Funcionales (SLOs / NFRs)

### 05.1–05.3 SLOs de Disponibilidad y Performance

| Operación | SLO Disponibilidad | Latencia P50 | Latencia P95 | Latencia P99 | Throughput Peak |
|---|---|---|---|---|---|
| POST /applications | 99.9% | 150 ms | 300 ms | 500 ms | 500 req/seg |
| POST /biometric (upload + análisis) | 99.9% | 800 ms | 2,000 ms | 3,500 ms | 200 req/seg |
| POST /contract/sign | 99.95% | 200 ms | 500 ms | 800 ms | 100 req/seg |
| GET /applications/{id} | 99.9% | 50 ms | 120 ms | 200 ms | 1,000 req/seg |
| Evento `AccountOpened` (end-to-end) | 99.9% | — | — | < 30 seg desde `ContractSigned` | — |

**Error budget mensual (99.9% = 43.8 min/mes de downtime permitido)**

### 05.4 Escalabilidad

| Parámetro | Valor |
|---|---|
| Instancias mínimas (HA) | 2 |
| Instancias máximas | 20 |
| Trigger de scale-out | CPU > 70% por 2 minutos continúos O latencia P95 > 400 ms |
| Trigger de scale-in | CPU < 30% por 10 minutos continuos |
| Proyección de volumen base | 15,000 solicitudes / mes |
| Proyección a 18 meses | 50,000 solicitudes / mes |

### 05.5 Resiliencia por Dependencia

| Dependencia | Timeout | Reintentos | Circuit Breaker | Fallback |
|---|---|---|---|---|
| RENAPO API | 3 seg | 2 (backoff 1s, 3s) | Abre en 5 fallos/30s | Cache de CURPs válidos (Redis, TTL 24h) |
| Biometric Provider | 10 seg | 1 (backoff 5s) | Abre en 3 fallos/60s | Sesión a `PENDING_REVIEW`; alerta P2 |
| AML Provider | 5 seg | 2 (backoff 2s, 5s) | Abre en 5 fallos/30s | Escalada a Oficial de Cumplimiento |
| Core Banking Adapter | 5 seg | 3 (backoff exponencial) | Abre en 3 fallos/30s | Outbox retry; alerta P1 |

### 05.7 RPO / RTO

| Ambiente | RPO | RTO | Estrategia |
|---|---|---|---|
| Producción (región primaria) | 5 minutos | 15 minutos | Multi-AZ, réplica de lectura sincrónica BD |
| DR (región secundaria) | 1 hora | 4 horas | Réplica asíncrona BD; failover manual |

### 05.8 NFRs de Cumplimiento Regulatorio

- Todos los logs de auditoría deben ser **inmutables** (append-only, sin UPDATE/DELETE) para cumplir requisitos de auditoría CNBV
- Tiempo máximo de respuesta para consultas de auditoría (CAP-010): < 5 segundos (requisito operativo del Oficial de Cumplimiento)

---

## §06 — Seguridad y Cumplimiento

### 06.1 Autenticación

| Flujo | Protocolo | Proveedor de Identidad | Descripción |
|---|---|---|---|
| App móvil → API | OAuth2 `client_credentials` | IdP del banco (Keycloak / Auth0) | El app registrada obtiene token de corta duración |
| Cliente → biometría | OAuth2 + `X-Session-Token` | Generado por este servicio | Token vinculado a `applicationId` + `deviceFingerprint`; TTL = duración de sesión |
| Cliente → firma contrato | OAuth2 + OTP SMS | SMS Gateway del banco | OTP de 6 dígitos válido por 5 minutos; un solo uso |
| Sistemas internos → audit log | OAuth2 `client_credentials` | IdP interno | Scope restringido: `compliance:read` |
| Este servicio → Core Banking | mTLS (certificado mutual) | PKI interna del banco | Certificados rotados cada 90 días |

### 06.2 Modelo de Autorización

| Scope OAuth2 | Capacidades permitidas | Titular |
|---|---|---|
| `onboarding:write` | CAP-001, CAP-003, CAP-005, CAP-009 | App móvil / web (cliente) |
| `onboarding:read` | CAP-008 | App móvil / web (cliente) |
| `compliance:read` | CAP-010 | Sistema de cumplimiento interno |
| `admin:onboarding` | Consulta y anulación de sesiones activas | Solo sistemas internos — no app cliente |

### 06.3 Threat Model (STRIDE)

| Interfaz | Amenaza | Tipo STRIDE | Control Mitigante |
|---|---|---|---|
| POST /applications | Apertura de cuenta con CURP robado | **Spoofing** | Biometría liveness obligatoria (BR-009); CURP no es suficiente por sí solo |
| POST /biometric | Replay attack con video pregrabado | **Spoofing** | Liveness detection score ≥ 0.90 obligatorio |
| GET /applications/{id} | Acceso a sesión ajena adivinando ID | **EoP** | `applicationId` (UUID v4) + verificación de `sub` del token = `curp_hash` de la sesión |
| POST /contract/sign | Firma sin consentimiento real del cliente | **Tampering** | OTP SMS en el momento de la firma; TTL 5 min |
| PostgreSQL (PII) | Exfiltración de datos personales | **Info Disclosure** | Cifrado AES-256-GCM con KMS envelope encryption; columnas PII individuales cifradas |
| Object Storage (biometría) | Exfiltración de imágenes faciales | **Info Disclosure** | Bucket privado, CMEK, sin acceso público, acceso solo via signed URLs de corta duración |
| Kafka events | Consumer malicioso leyendo eventos de onboarding | **Info Disclosure** | ACL Kafka por consumer group; no incluir PII en eventos (solo `curpHash` y IDs) |
| Core Banking API | Inyección de solicitudes fraudulentas de apertura | **Tampering** | mTLS bilateral + firma HMAC-SHA256 del payload; Core valida que `applicationId` esté en estado `CONTRACT_SIGNED` |
| Admin endpoints | Anulación maliciosa de sesiones | **EoP** | Scope `admin:onboarding` restringido a service accounts internos; MFA obligatorio para operadores humanos |
| Logs de auditoría | Alteración de evidencia post-fraude | **Tampering** | Tabla append-only (triggers bloquean UPDATE/DELETE); hash encadenado tipo ledger |

### 06.4 Catálogo de Controles de Seguridad

| ID Control | Descripción | Implementación | Herramienta | Gate CI/CD |
|---|---|---|---|---|
| SEC-001 | SAST — análisis estático en cada PR | Reglas OWASP, inyección, crypto débil | SonarQube + Semgrep | Bloquea merge si hallazgo Critical o High |
| SEC-002 | SCA — escaneo de dependencias | CVEs en librerías transitivas | Snyk / OWASP Dependency-Check | Bloquea build si CVSS ≥ 7.0 sin excepción documentada |
| SEC-003 | Secrets scanning | Credenciales hardcodeadas en código o commits | GitLeaks (pre-commit hook) | Bloquea commit |
| SEC-004 | Container image scanning | Vulnerabilidades en imagen base y capas | Trivy + Wiz (CNAPP) | Bloquea deploy si Critical en imagen final |
| SEC-005 | IaC scanning | Misconfiguraciones en Terraform y Helm charts | Checkov + tfsec | Bloquea `terraform apply` si Critical |
| SEC-006 | DAST — pruebas de penetración automatizadas | Endpoints REST en ambiente staging | OWASP ZAP | Gate pre-release; bloquea si High |
| SEC-007 | Comunicación inter-servicios cifrada | mTLS entre pods del cluster | Istio service mesh (auto mTLS) | Runtime — verificado en deploy |
| SEC-008 | Cifrado en reposo de PII | Envelope encryption por registro | AWS KMS / GCP CMEK | Runtime — verificado en provisioning |
| SEC-009 | Secretos externalizados | Sin credenciales en env vars ni código | HashiCorp Vault / AWS Secrets Manager | Runtime + SEC-003 |

### 06.5 Requisitos Shift-Left (Pipeline Gates)

```
  commit ──► SEC-003 (secrets scan) ──► PR merge
                                          │
                                   SEC-001 (SAST)
                                   SEC-002 (SCA)
                                          │
                                      build image
                                          │
                                   SEC-004 (container scan)
                                   SEC-005 (IaC scan)
                                          │
                                    deploy staging
                                          │
                                   SEC-006 (DAST)
                                          │
                                    release gate ──► producción
```

### 06.6 Secrets Management

| Secreto | Almacén | Rotación |
|---|---|---|
| Credenciales BD (PostgreSQL) | HashiCorp Vault (dynamic secrets) | Automática cada 8 horas |
| API key proveedor biométrico | AWS Secrets Manager / GCP Secret Manager | Cada 90 días |
| API key proveedor AML | AWS Secrets Manager | Cada 90 días |
| Certificados mTLS (Core Banking) | Vault PKI Engine | Cada 90 días |
| OAuth2 client secret | Vault | Cada 30 días |
| KMS key para cifrado PII | KMS Key Policy (no acceso manual) | Rotación automática anual |

### 06.7 Aislamiento de Red

| Capa | Requisito |
|---|---|
| Pods del microservicio | Subnet privada — sin acceso directo desde internet |
| Acceso desde internet | Solo vía API Gateway / Load Balancer en subnet pública |
| Egress hacia RENAPO | Via NAT Gateway con IP fija (whitelistear en RENAPO) |
| Egress hacia proveedor biométrico / AML | Via Private Link / VPN dedicada (según contrato con proveedor) |
| Comunicación con Core Banking | Dentro del cluster, vía service mesh mTLS; nunca expuesto externamente |

### 06.8 Mapa de Controles Regulatorios

| Control Implementado | Norma | Referencia | Evidencia para Auditoría |
|---|---|---|---|
| Validación de identidad en fuente oficial (RENAPO) antes de apertura | CNBV — Circular 3/2012 | Anexo 1, Sección II | Log de llamada a RENAPO con timestamp + resultado en `OnboardingAuditLog` |
| Verificación biométrica con liveness detection | CNBV — Disposiciones crédito | Art. 320-Bis, fracción III | BiometricCapture con scores almacenados; evidencia inmutable |
| Screening PLD/AML previo a establecer relación comercial | SHCP — LFPIORPI | Art. 17, fracción I | AMLScreeningResult con proveedor, listas consultadas, resultado y timestamp |
| Consentimiento explícito del cliente antes de captura de biometría | LFPDPPP | Art. 8 (datos sensibles) | `acceptedBiometricConsent: true` en OnboardingAuditLog con timestamp e IP |
| Retención de evidencia KYC por 10 años | CNBV Art. 58 Bis + LFPIORPI | Art. 18 | Política de retención en BD y Object Storage; sin DELETE hasta plazo |
| No revelación de razón de rechazo AML al cliente (tipping-off) | SHCP — LFPIORPI | Art. 24 | Código de error genérico al cliente; razón real solo en logs internos con acceso restringido |
| Límite operacional 3,000 UDIS/mes por cuenta N2 | CNBV | Art. 320-Bis, fracción IV | Implementado en Core Banking (fuera del scope de este componente); este servicio solo apertura la cuenta |
| Aviso de privacidad entregado antes de recopilación de datos | LFPDPPP | Art. 8 y 13 | `acceptedPrivacyPolicy: true` + timestamp + versión del aviso en OnboardingAuditLog |

### 06.9 Requisitos de Audit Log

| Evento Auditado | Campos Obligatorios | Retención | Inmutabilidad |
|---|---|---|---|
| Inicio de sesión | `applicationId`, `curp_hash`, `ip`, `device_fp`, `channel`, `timestamp` | 10 años | Sí (append-only) |
| Validación CURP | `applicationId`, `renapo_response_code`, `latency_ms`, `timestamp` | 10 años | Sí |
| Resultado biométrico | `applicationId`, `liveness_score`, `match_score`, `attempt_number`, `result`, `timestamp` | 10 años | Sí |
| Resultado AML | `applicationId`, `provider`, `lists_checked`, `result_code`, `timestamp` | 10 años | Sí |
| Firma de contrato | `applicationId`, `contract_hash`, `otp_method`, `ip`, `timestamp` | 10 años | Sí |
| Apertura de cuenta | `applicationId`, `core_banking_account_id`, `timestamp` | 10 años | Sí |
| Rechazo con razón interna | `applicationId`, `rejection_reason_internal`, `timestamp` | 10 años | Sí |

---

## §07 — Integraciones y Dependencias

### 07.1 Dependencias Upstream

| Sistema | Contrato Consumido | Protocolo | SLA Proveedor | Fallback |
|---|---|---|---|---|
| **RENAPO API** | Validación de CURP: nombre, fecha nacimiento, estatus | REST HTTPS | 99% / P95 < 2 seg | Cache Redis (TTL 24h) + rechazo con mensaje al cliente |
| **Proveedor Biométrico** (ej: Jumio, Veriff, Incode) | Liveness detection + facial match vs. foto CURP | REST HTTPS (respuesta async via webhook) | 99.5% / P95 < 5 seg | 1 reintento automático; si falla: `PENDING_REVIEW` + alerta P2 |
| **Proveedor AML** (ej: Refinitiv World-Check, Dow Jones) | Consulta de listas OFAC, ONU, SHCP-PLDFT | REST HTTPS | 99% / P95 < 1 seg | Reintento x2; si offline > 5 min: escalada a Oficial de Cumplimiento, sesión en `PENDING_REVIEW` |
| **Core Banking Adapter** | Instrucción de apertura de cuenta N2 | REST interno (mTLS) | 99.9% / P95 < 500 ms | Outbox pattern — reintentos automáticos hasta 3x con backoff exponencial (1s, 3s, 9s) |

### 07.2 Consumidores Downstream

| Sistema Consumidor | Qué Consume | Contrato de Compatibilidad |
|---|---|---|
| **Notification Service** | Eventos `OnboardingCompleted`, `OnboardingRejected`, `OnboardingAbandoned` | Schema Avro versión 1.x — no se cambiará sin 30 días de aviso previo |
| **Core Banking Adapter** | Evento `ContractSigned` (trigger para apertura) | Schema Avro versión 1.x |
| **Customer Data Platform** | Evento `AccountOpened` (para crear Customer 360) | Schema Avro versión 1.x |
| **Fraud Analytics** | Evento `OnboardingRejected` | Schema Avro versión 1.x |
| **CRM — Re-engagement** | Evento `OnboardingAbandoned` | Schema Avro versión 1.x |

### 07.4 Patrones de Integración por Dependencia

| Dependencia | Patrón | Justificación |
|---|---|---|
| Core Banking (apertura) | **Saga coreografiada** via Kafka (ADR-ONB-001) | Evita 2PC y acoplamiento síncrono; core bancario puede estar en mantenimiento |
| Core Banking (publicación evento) | **Transactional Outbox** (ADR-ONB-002) | Garantiza que el evento se publica si y solo si la transacción en BD se confirma |
| RENAPO API | **Cache aside** con Redis | RENAPO tiene SLA bajo; cache reduce latencia y dependencia |
| Biometric Provider | **Webhook + polling fallback** | Proveedor responde async; webhook es preferido, polling cada 2s como fallback |
| AML Provider | **Síncrono con circuit breaker** | Respuesta rápida (< 1s); circuit breaker previene cascada si el proveedor cae |

### 07.6 Mapa de Topología de Eventos Kafka

```
  ┌─────────────────────────────────────────────────────────────────────┐
  │                     Kafka Topic: onboarding.events                   │
  │                     Partitions: 12 · Retention: 7 días              │
  └─────────────────────────────────────────────────────────────────────┘

  Producer: spe-account-onboarding-l2 (único)

  Eventos publicados:
  ┌─────────────────────────────┬──────────────────────────────────────┐
  │ Evento                      │ Consumer Group(s)                    │
  ├─────────────────────────────┼──────────────────────────────────────┤
  │ OnboardingStarted           │ analytics-cg                        │
  │ CURPValidated               │ analytics-cg                        │
  │ BiometricVerificationComp.  │ analytics-cg, fraud-analytics-cg    │
  │ AMLScreeningCompleted       │ analytics-cg, fraud-analytics-cg    │
  │ ContractSigned              │ core-banking-adapter-cg             │
  │ AccountOpened               │ notification-cg, cdp-cg, analytics  │
  │ OnboardingCompleted         │ notification-cg, crm-cg             │
  │ OnboardingRejected          │ notification-cg, fraud-analytics-cg │
  │ OnboardingAbandoned         │ notification-cg, crm-reengage-cg    │
  └─────────────────────────────┴──────────────────────────────────────┘
```

---

## §08 — Estrategia de Testing y Acceptance Criteria

### 08.1 Pirámide de Tests

```
                      ┌────────────────┐
                      │   E2E Tests    │  5%
                      │  (staging env) │  3 journeys críticos: éxito / rechazo biométrico / rechazo AML
                      └───────┬────────┘
                      ┌───────┴────────────┐
                      │  Contract Tests    │  15%
                      │  (Pact CDC)        │  Por cada consumer del Event Bus + por cada API upstream
                      └───────┬────────────┘
                      ┌───────┴─────────────────┐
                      │  Integration Tests       │  30%
                      │  (Testcontainers)        │  BD, Redis, Kafka, mocks WireMock para APIs externas
                      └───────┬─────────────────┘
                      ┌───────┴──────────────────────────┐
                      │         Unit Tests               │  50%
                      │  (dominio, reglas BR-*, estados) │  Lógica pura, sin infraestructura
                      └──────────────────────────────────┘

  Coverage mínimo gate CI: 80% líneas en capa de dominio
  Coverage mínimo total:   65% líneas
```

### 08.2 Contract Tests (Pact — Consumer-Driven)

| Consumer | Provider | Contratos a cubrir |
|---|---|---|
| App Móvil | `spe-account-onboarding-l2` | POST /applications, POST /biometric, POST /contract/sign |
| `spe-notification-service` | `onboarding.events` (Kafka) | Schemas Avro de todos los eventos |
| `spe-core-banking-adapter` | `onboarding.events` (Kafka) | Schema Avro `ContractSigned`, `AccountOpened` |
| `spe-account-onboarding-l2` | RENAPO API | Respuesta de validación CURP (WireMock stub en CI) |

### 08.3 Escenarios de Performance Test

| Escenario | Carga | Duración | Criterio Pass |
|---|---|---|---|
| Carga normal | 200 req/seg (POST /applications) | 10 min | P95 < 300ms, error rate < 0.1% |
| Peak de carga | 500 req/seg | 5 min | P95 < 500ms, error rate < 0.5% |
| Biometric upload stress | 200 req/seg (POST /biometric) | 5 min | P95 < 2,000ms, error rate < 0.5% |
| RENAPO degradado (cache hit) | 300 req/seg con RENAPO = timeout | 3 min | P95 < 500ms (desde cache), error rate < 0.1% |
| AML circuit breaker | AML offline durante prueba | 5 min | Sesiones a PENDING_REVIEW correctamente; 0 crashes |

### 08.4 Acceptance Criteria BDD — Escenarios Principales

```gherkin
Feature: Apertura de Cuenta Nivel 2 — Journey Completo

  Scenario: Cliente nuevo completa onboarding exitosamente
    Given un cliente con CURP "GAAA900101HDFXXX00" sin cuenta activa en el banco
    And acepta términos, política de privacidad y consentimiento biométrico
    When envía POST /applications con datos completos y válidos
    Then recibe 201 Created con applicationId y status "INITIATED"
    And el evento "OnboardingStarted" es publicado en Kafka

  Scenario: CURP ya tiene cuenta activa
    Given un cliente con CURP "GAAA900101HDFXXX00" con cuenta activa
    When envía POST /applications
    Then recibe 409 Conflict con código "CURP_ALREADY_EXISTS"
    And no se emite ningún evento
    And no se crea ninguna ApplicationSession

  Scenario: Biometría supera umbral en primer intento
    Given una ApplicationSession con status "CURP_VERIFIED"
    When el cliente envía captura biométrica con liveness_score=0.97 y match_score=0.92
    Then recibe 200 OK con biometricStatus "VERIFIED"
    And la sesión cambia a status "BIOMETRIC_VERIFIED"
    And el evento "BiometricVerificationCompleted" es emitido con result "APPROVED"

  Scenario: Cliente agota los 3 intentos biométricos
    Given una ApplicationSession con status "CURP_VERIFIED" y biometric_attempts=2
    When el cliente envía captura biométrica con liveness_score=0.45
    Then recibe 429 con código "BIOMETRIC_MAX_ATTEMPTS"
    And la sesión cambia a status "ABANDONED"
    And el evento "OnboardingAbandoned" es emitido con reason "BIOMETRIC_MAX_ATTEMPTS"
    And el cliente recibe notificación indicando suspensión de 24 horas

  Scenario: Cliente rechazado por AML — mensaje genérico
    Given una ApplicationSession con status "BIOMETRIC_VERIFIED"
    When el proveedor AML retorna match definitivo en lista OFAC
    Then la sesión cambia a status "REJECTED"
    And el cliente recibe notificación con mensaje genérico (sin revelar razón específica)
    And el log interno registra la razón completa con lista consultada
    And el evento "OnboardingRejected" es emitido con rejectionReason "AML_REJECTED"

  Scenario: Journey completo exitoso — cuenta aperturada
    Given una ApplicationSession en status "CONTRACT_SIGNED"
    When el Core Banking Adapter confirma apertura con accountId "001-234567-89"
    Then la sesión cambia a status "COMPLETED"
    And el evento "AccountOpened" es emitido con accountNumber y customerId
    And el evento "OnboardingCompleted" es emitido
    And el cliente recibe notificación de bienvenida con número de cuenta
```

### 08.5 Estrategia de Test Data

| Ambiente | Fuente de Datos | Manejo PII |
|---|---|---|
| Dev | Datos sintéticos generados (Faker + reglas CURP) | Sin datos reales |
| Staging | Datos sintéticos con distribuciones realistas | Sin datos reales; imágenes biométricas sintéticas |
| Performance | Dataset sintético de 50,000 registros pre-generados | Sin datos reales |
| UAT | Datos de empleados voluntarios del banco (consentimiento escrito) | Solo empleados que firman consentimiento |

---

## §09 — Arquitectura y Decisiones (ADRs)

### 09.1 Diagrama C4 — Nivel Context

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │                            SYSTEM CONTEXT                                 │
  │                                                                            │
  │  ┌──────────────┐                                ┌─────────────────────┐  │
  │  │  Cliente     │── abre cuenta (app/web) ──────►│                     │  │
  │  │  (Persona    │◄─ notificación de resultado ───│  Account Onboarding │  │
  │  │   Física MX) │                                │  System             │  │
  │  └──────────────┘                                │                     │  │
  │                                                  │  [spe-account-      │  │
  │  ┌──────────────────┐                            │   onboarding-l2]    │  │
  │  │  Oficial de      │── consulta auditoría ─────►│                     │  │
  │  │  Cumplimiento    │                            └──────────┬──────────┘  │
  │  └──────────────────┘                                       │             │
  │                                      ┌──────────────────────┤             │
  │          ┌───────────────────────────┼────────────┐         │             │
  │          ▼                           ▼            ▼         ▼             │
  │   ┌────────────┐           ┌──────────────┐ ┌──────────┐ ┌────────────┐  │
  │   │  RENAPO    │           │  Biometric   │ │   AML    │ │    Core    │  │
  │   │  (CURP     │           │  Provider    │ │ Provider │ │  Banking   │  │
  │   │  Validation│           │  (Liveness + │ │ (PLD/AML │ │  System    │  │
  │   │  — Gob MX) │           │   Match)     │ │  Lists)  │ │            │  │
  │   └────────────┘           └──────────────┘ └──────────┘ └────────────┘  │
  └──────────────────────────────────────────────────────────────────────────┘
```

### 09.2 Diagrama C4 — Nivel Container

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │                   spe-account-onboarding-l2 — Containers                  │
  │                                                                            │
  │  App Móvil / Web                                                           │
  │       │ HTTPS / OAuth2                                                     │
  │       ▼                                                                    │
  │  ┌─────────────────┐     Kafka (Avro)    ┌─────────────────────────────┐  │
  │  │  API Gateway    │                     │  Schema Registry             │  │
  │  │  (Rate limit,   │                     │  (Confluent / Apicurio)      │  │
  │  │   Auth, TLS)    │                     └─────────────────────────────┘  │
  │  └────────┬────────┘                                  ▲                   │
  │           │ REST                                       │ Avro schemas      │
  │           ▼                                           │                   │
  │  ┌─────────────────────────────────────────────────┐  │                   │
  │  │   Onboarding Service (Quarkus / Java 21)         │──┘                  │
  │  │                                                  │                     │
  │  │   Domain Layer: ApplicationSession, Sagas        │                     │
  │  │   Application Layer: UseCases / Commands         │──── mTLS ──► Core   │
  │  │   Infra Layer: Repos, Kafka Producer, REST clients│                    │
  │  │   Outbox Publisher (Debezium CDC)                │──── REST ──► RENAPO │
  │  └──────────────┬───────────────────────────────────┘──── REST ──► Biom.  │
  │                 │                                    ──── REST ──► AML    │
  │       ┌─────────┴──────────┐                                              │
  │       ▼                    ▼                                               │
  │  ┌──────────────┐  ┌───────────────────┐                                  │
  │  │  PostgreSQL  │  │  Redis            │                                  │
  │  │  (state,PII, │  │  (CURP cache,     │                                  │
  │  │   outbox,    │  │   rate limiting,  │                                  │
  │  │   audit log) │  │   session tokens) │                                  │
  │  └──────────────┘  └───────────────────┘                                  │
  └──────────────────────────────────────────────────────────────────────────┘
```

### 09.3 Índice de ADRs

| ID | Título | Estado | Decisión Tomada |
|---|---|---|---|
| ADR-ONB-001 | Saga vs. 2PC para apertura de cuenta | `ACCEPTED` | Saga coreografiada via Kafka — evita acoplamiento temporal con core bancario |
| ADR-ONB-002 | Outbox Pattern para garantía de entrega de eventos | `ACCEPTED` | Transactional Outbox en PostgreSQL (tabla `outbox_events`) — garantiza at-least-once |
| ADR-ONB-003 | Biometría raw en BD vs. Object Storage | `ACCEPTED` | S3/GCS con CMEK — biometría no entra a PostgreSQL; solo hash y metadata |
| ADR-ONB-004 | Cache de validaciones RENAPO | `ACCEPTED` | Cache Redis TTL 24h — reduce dependencia de RENAPO (SLA bajo) |
| ADR-ONB-005 | Quarkus vs. Spring Boot para runtime | `ACCEPTED` | Quarkus native image — startup < 50ms, footprint 60% menor, GraalVM para K8s |
| ADR-ONB-006 | PostgreSQL vs. MongoDB para state | `ACCEPTED` | PostgreSQL — transacciones ACID para Outbox + estado; schema predecible |

### 09.5 Stack Tecnológico

| Capa | Tecnología | Justificación |
|---|---|---|
| Runtime | Quarkus 3.x / Java 21 (GraalVM native) | Performance en K8s (ADR-ONB-005) |
| BD principal | PostgreSQL 16 | ACID para Outbox pattern (ADR-ONB-006) |
| Cache | Redis 7 (Cluster mode en prod) | CURP cache + rate limiting + session tokens |
| Message broker | Apache Kafka (MSK / Confluent Cloud) | Backbone de eventos; particionado por CURP hash |
| Schema management | Confluent Schema Registry / Apicurio | Avro schemas versionados; evolución controlled |
| Service mesh | Istio | mTLS automático, observabilidad de red |
| API Gateway | Kong / AWS API Gateway | Rate limiting, auth, routing |
| Secrets | HashiCorp Vault | Dynamic secrets para BD; static secrets para APIs externas |
| CI/CD | GitHub Actions + ArgoCD (GitOps) | Pipeline shift-left; deploy declarativo |
| IaC | Terraform (módulos de `04 - Intelligent Infrastructure`) | Provisioning reproducible |

---

## §10 — Infraestructura y Deployment

### 10.1–10.3 Compute por Ambiente

| Parámetro | Dev | Staging | Producción |
|---|---|---|---|
| Runtime mode | Quarkus JVM | Quarkus Native | Quarkus Native |
| CPU request / limit | 250m / 500m | 500m / 1,000m | 1,000m / 2,000m |
| Memory request / limit | 256Mi / 512Mi | 512Mi / 1Gi | 512Mi / 1Gi |
| Réplicas | 1 | 2 | min 2 / max 20 (HPA) |
| Base image | `registry.acn.com/ubi9-minimal:9.4` | idem | idem |
| PostgreSQL | Shared (namespace dev) | Dedicado (Cloud SQL / RDS) | HA Multi-AZ (Cloud SQL / RDS) |
| Redis | Shared (namespace dev) | Redis Standalone | Redis Cluster (3 primary + 3 replica) |

### 10.5 IAM — Roles y Políticas (Least Privilege)

| Service Account | Permisos | Scope |
|---|---|---|
| `onboarding-app-sa` | `postgresql:read-write` (solo tablas propias), `kafka:produce` (topic onboarding.events), `secretsmanager:GetSecretValue` (propios secrets) | Solo recursos propios |
| `onboarding-admin-sa` | `postgresql:read-write`, `kafka:admin` (onboarding.events) | Solo en break-glass, requiere MFA |
| `onboarding-readonly-sa` | `postgresql:read` (solo tablas no-PII) | Para herramientas de observabilidad |

### 10.6 Estrategia de Deployment — Canary

```
  Deploy nueva versión
         │
         ▼
  ┌─────────────────┐   Canary weight: 5% del tráfico
  │  Canary Pool    │   Duración mínima: 15 minutos
  │  (nueva versión)│   Métricas: error_rate, latencia P95
  └────────┬────────┘
           │ Métricas dentro de SLO por 15 min
           ▼
  Escalar a 25% ──► 50% ──► 100%
  (cada step: 15 min de observación)

  Rollback automático si:
  - error_rate > 1% en cualquier step
  - latencia P95 > 600ms en cualquier step
  - 0 AccountOpened en 10 minutos (anomalía funcional)
```

### 10.8 Matriz de Ambientes

| Config | Dev | Staging | Producción |
|---|---|---|---|
| RENAPO endpoint | WireMock stub local | Sandbox RENAPO (si disponible) o WireMock | Producción RENAPO |
| Biometric provider | Mock (respuesta fija configurable) | Sandbox del proveedor | Producción proveedor |
| AML provider | Mock (respuesta fija configurable) | Sandbox del proveedor | Producción proveedor |
| Core Banking Adapter | Stub Testcontainers | Ambiente UAT bancario | Producción core |
| Kafka | Kafka en Testcontainers / local Compose | Cluster de staging compartido | MSK / Confluent Production |
| KMS (cifrado PII) | Vault dev mode | KMS staging key | KMS production CMEK |
| Log level | DEBUG | INFO | INFO (WARN para librerías externas) |
| Feature flags (CAP-009 reanudar) | ON | ON | OFF hasta Q1 2027 |

---

## §11 — Observabilidad (SLIs · Alertas · Dashboards)

### 11.1 SLI Definitions

| SLO | SLI | Query Prometheus | Ventana |
|---|---|---|---|
| Disponibilidad ≥ 99.9% | Ratio de requests exitosos | `sum(rate(http_requests_total{status!~"5..",service="onboarding"}[5m])) / sum(rate(http_requests_total{service="onboarding"}[5m]))` | 30 días rolling |
| Latencia P95 ≤ 300ms (POST /applications) | Percentil 95 de latencia | `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{handler="POST /applications"}[5m]))` | 1 hora |
| Journey end-to-end ≤ 30 seg | Tiempo `ContractSigned → AccountOpened` | Métrica custom `onboarding_journey_duration_seconds` (histogram) | 1 hora |
| Error budget | Tiempo restante en error budget del mes | `1 - avg_over_time(slo:availability:ratio[30d])` / `(1 - 0.999)` | 30 días |

### 11.3 Schema de Log Estructurado

```json
{
  "timestamp":       "2026-06-30T14:32:01.234Z",
  "severity":        "INFO",
  "trace_id":        "4bf92f3577b34da6a3ce929d0e0e4736",
  "span_id":         "00f067aa0ba902b7",
  "component":       "spe-account-onboarding-l2",
  "version":         "1.0.0",
  "env":             "prod",
  "application_id":  "app-2026-0001234",
  "event":           "BiometricVerificationCompleted",
  "result":          "APPROVED",
  "liveness_score":  0.97,
  "match_score":     0.91,
  "attempt_number":  1,
  "duration_ms":     1843,
  "curp_hash":       "sha256:a3f4b2c1..."
}
```

**Nota**: El campo `curp` (raw) nunca aparece en logs. Solo `curp_hash` para trazabilidad interna.

### 11.5 Catálogo de Alertas

| Nombre de Alerta | Condición | Severidad | Canal | Runbook |
|---|---|---|---|---|
| `OnboardingErrorRateHigh` | `error_rate > 1%` por 5 min | **P2** | PagerDuty + Slack #ops-onboarding | `runbook-account-onboarding-l2.md §3.1` |
| `OnboardingLatencyDegraded` | P95 > 500ms por 5 min | **P2** | PagerDuty + Slack | `runbook §3.2` |
| `AMLProviderDown` | `aml_calls_failed > 50%` por 2 min | **P1** | PagerDuty (wake-up) | `runbook §4.1` |
| `CoreBankingUnreachable` | `core_banking_errors > 3` en 1 min | **P1** | PagerDuty (wake-up) | `runbook §4.2` |
| `RENAPOCacheExpiring` | Cache hit rate < 60% (indica RENAPO degradado) | **P3** | Slack #ops-onboarding | `runbook §4.3` |
| `BiometricProviderSlow` | P95 > 8 seg en webhook de biometría | **P2** | PagerDuty + Slack | `runbook §4.4` |
| `OnboardingAbandonedSpike` | abandoned_rate > 20% vs. baseline semanal por 15 min | **P3** | Slack #product-onboarding | `runbook §5.1` |
| `KafkaConsumerLagHigh` | consumer_lag > 10,000 mensajes en core-banking-adapter-cg | **P2** | PagerDuty + Slack | `runbook §6.1` |
| `OutboxUnprocessedItems` | outbox_pending_count > 100 por 10 min | **P2** | PagerDuty + Slack | `runbook §6.2` |

### 11.6 Dashboards Requeridos

| Dashboard | Audiencia | Panels Mínimos |
|---|---|---|
| **Onboarding Operations** | SRE / On-call | Error rate, latencia P95/P99, throughput, SLI/SLO, circuit breaker states, Kafka lag |
| **Onboarding Funnel** | Product / Business | Conversión por paso (INITIATED→COMPLETED), tasa de abandono por paso, tiempo mediano por paso |
| **Compliance & Audit** | Oficial de Cumplimiento | Volumen de sesiones por estado, rechazos AML vs. biométrico, sesiones en PENDING_REVIEW, audit log events |
| **External Dependencies** | SRE | RENAPO latencia y errores, biometric provider P95, AML provider P95, core banking P95 |

### 11.7 Error Budget Policy

| Consumo de Error Budget | Acción |
|---|---|
| < 50% consumido | Normal — releases habituales permitidos |
| 50%–75% consumido | Alerta a equipo — revisión de riesgos antes de próximo release |
| 75%–100% consumido | Freeze de releases de nuevas funcionalidades; solo fixes de SLO |
| 100% consumido (SLO violado) | Freeze total de releases; post-mortem obligatorio; revisión de SLO target |

---

## §12 — Plan de Release y Milestones

### 12.1 Breakdown por Fase SDLC

| Fase | Entregable Principal | Duración Estimada | Exit Criteria |
|---|---|---|---|
| **DISCOVER** | Este spec en estado `APPROVED` | 2 semanas | Spec firmado por Product Owner, CISO y Compliance Officer |
| **DESIGN** | OpenAPI v1.0 finalizado, ADRs aceptados, threat model aprobado | 3 semanas | Contract tests seed generados; CISO sign-off en §06 |
| **BUILD** | MVP funcional: CAP-001 a CAP-007 | 8 semanas | Cobertura ≥ 80%, todos los BDD verdes, security gates pasados |
| **TEST** | UAT con core bancario real, pruebas de integración completas | 3 semanas | 0 defectos P1/P2 abiertos; compliance sign-off formal; performance tests pasados |
| **RELEASE** | Go-live canary 5% → 100% | 2 semanas | SLOs en verde por 72h; 0 incidentes P1; runbook validado |
| **OPERATE** | Estabilización, runbook refinado | Ongoing | DORA metrics baseline establecido |

### 12.2 Estimación de Esfuerzo (MVP — Fase BUILD)

| Rol | Fase Design | Fase Build | Fase Test | Total |
|---|---|---|---|---|
| Tech Lead / Architect | 3 sem | 4 sem | 1 sem | **8 sem** |
| Senior Backend Engineer | 1 sem | 8 sem | 2 sem | **11 sem** × 2 = 22 sem |
| QA Engineer | 1 sem | 2 sem | 3 sem | **6 sem** |
| DevSecOps Engineer | 1 sem | 2 sem | 1 sem | **4 sem** |
| Compliance Analyst | 2 sem | — | 1 sem | **3 sem** |

### 12.4 RAID Log Inicial

| Tipo | Descripción | Prob. | Impacto | Mitigación |
|---|---|---|---|---|
| **Riesgo** | SLA de RENAPO API (99%) insuficiente para P95 < 300ms | Alta | Alto | Cache Redis + provider alternativo privado de validación CURP como backup |
| **Riesgo** | Core bancario sin ambiente de integración disponible para testing | Alta | Alto | Stub detallado con Testcontainers + contratos Pact desde Sprint 1 |
| **Riesgo** | Formato de respuesta RENAPO no documentado públicamente | Media | Medio | Reverse-engineering con sandbox; escalada a RENAPO si necesario |
| **Supuesto** | Proveedor biométrico tiene sandbox disponible en ≤ 2 semanas desde kick-off | — | Alto si falso | Confirmar en reunión de kick-off; tener mock completo listo |
| **Supuesto** | Schema Registry compartido estará provisionado antes del Sprint 3 | — | Medio | Incluir en Plan de Plataforma; equipo infra debe confirmar en Sprint 0 |
| **Dependencia** | Ambiente UAT del banco disponible para Fase TEST | Crítica | Alto | Incluir en acuerdo de proyecto; milestone de plataforma en §12.1 |
| **Issue** | Formato CLABE de Core Banking no documentado para el adapter | — | Medio | Workshop con equipo de Core Banking en Sprint 1 |

---

## §13 — Quality Gates / Definition of Done

### 13.1–13.2 Entry / Exit por Fase SDLC

| Fase | Entry Criteria | Exit Criteria |
|---|---|---|
| **DISCOVER → DESIGN** | Spec §01–§02 drafteados | §00–§09 completos y aprobados por stakeholders; ADRs en estado `ACCEPTED` |
| **DESIGN → BUILD** | DESIGN exit completa; ambientes dev y staging provisionados | OpenAPI v1.0 con contract tests seed generados; threat model con CISO sign-off; IaC base deployado |
| **BUILD → TEST** | BUILD entry completa | Cobertura unit ≥ 80%; BDD acceptance criteria verdes; SEC-001/002/003/004 passing; performance test local pasado |
| **TEST → RELEASE** | TEST entry completa; UAT environment con core bancario disponible | 0 defectos P1/P2 abiertos; Compliance Officer sign-off escrito; SEC-006 (DAST) passing; runbook validado en staging |
| **RELEASE → OPERATE** | Canary al 5% estable | Canary progresado al 100% sin incidentes P1; SLOs en verde 72h continuas; dashboards y alertas activos |

### 13.3 DoD Checklist — Componente Completo

```
IMPLEMENTACIÓN
  ☐ Todas las capacidades CAP-001 a CAP-007 (MVP) implementadas
  ☐ CAP-010 (audit log endpoint) implementado y probado
  ☐ OpenAPI spec actualizado y generado desde código (spec-as-code con SmallRye OpenAPI)
  ☐ Todos los acceptance criteria BDD del §08.4 en verde
  ☐ Todos los domain events del §02.6 publicados correctamente en Kafka

CALIDAD
  ☐ Cobertura de unit tests ≥ 80% en capa de dominio
  ☐ Contract tests (Pact) en verde para todos los consumers registrados
  ☐ Performance tests pasados contra SLOs del §05
  ☐ 0 defectos de severidad P1 o P2 abiertos
  ☐ Test de estado de máquina: todos los transitions de ApplicationSession cubiertos

SEGURIDAD
  ☐ SEC-001 SAST: 0 findings Critical o High
  ☐ SEC-002 SCA: 0 CVEs CVSS ≥ 7.0 sin excepción documentada y firmada
  ☐ SEC-003 Secrets scan: 0 findings en código y en historial de commits
  ☐ SEC-004 Container scan: 0 Critical en imagen final de producción
  ☐ SEC-005 IaC scan: 0 Critical en Terraform/Helm
  ☐ SEC-006 DAST: ejecutado en staging, 0 High/Critical

CUMPLIMIENTO REGULATORIO
  ☐ Todos los controles del §06.8 verificados con evidencia documentada
  ☐ Compliance Officer ha dado sign-off formal por escrito
  ☐ Audit log append-only verificado (trigger de BD bloqueando UPDATE/DELETE probado)
  ☐ Datos biométricos raw en Object Storage; nunca en PostgreSQL

OPERABILIDAD
  ☐ Dashboards del §11.6 configurados en Grafana y validados con datos reales de staging
  ☐ Todas las alertas del §11.5 configuradas, probadas y con runbook link válido
  ☐ Runbook `runbook-account-onboarding-l2.md` entregado y validado en staging (simulación de incidente)
  ☐ Logs estructurados según schema §11.3 verificados en producción
  ☐ SLIs del §11.1 visibles en dashboard con datos reales
  ☐ Canary deployment configurado en ArgoCD y probado en staging
  ☐ Política de retención de datos (§04.8) configurada en BD y Object Storage
```

### 13.4–13.6 Gates de Seguridad, Performance y Compliance

| Gate | Herramienta | Umbral de Pass | Bloquea |
|---|---|---|---|
| SAST | SonarQube + Semgrep | 0 Critical/High; Quality Gate A | Merge a `main` |
| SCA | Snyk | 0 CVSS ≥ 7.0 sin excepción | Build |
| Container scan | Trivy | 0 Critical en imagen final | Deploy a staging |
| DAST | OWASP ZAP | 0 High/Critical | Release a producción |
| Performance | k6 (script §08.3) | Todos los escenarios passing | Release a producción |
| Compliance | Sign-off manual del Oficial de Cumplimiento | Documento firmado | Release a producción |

---

## §14 — Handoffs a SMEs

### 14.1 Tabla de Asignación por Fase

| Fase SDLC | SME Ejecutor | Input que Recibe | Output que Entrega |
|---|---|---|---|
| DISCOVER → DESIGN | **Software Engineering** (`Technology/Software Engineering/`) | §00–§02 de este spec | Stack tecnológico definitivo, §03 OpenAPI draft, §05 NFRs validados |
| DISCOVER → DESIGN | **Architecture Patterns** (`Technology/Software Engineering/Specialist - Architecture Patterns/`) | §02 (capacidades + domain events) | §09 C4 diagrams, ADR-ONB-001 (Saga), DDD Bounded Context map |
| DISCOVER → DESIGN | **Data Architect** (`Technology/Data & ML/Data Architect/`) | §02 entidades, §07 integraciones | §04 completo: schemas, Avro event contracts, lineage, PII classification |
| DISCOVER → DESIGN | **Cloud Security & DevSecOps** (`Technology/Cybersecurity/Cloud Security & DevSecOps/`) | §02, §03, §07 | §06.3 Threat model (STRIDE), §06.4 Security controls, §06.5 Pipeline gates |
| DISCOVER → DESIGN | **GRC** (`Framework/ITSM/GRC/`) | §06.3, §01.7 (restricciones regulatorias) | §06.8 Mapa completo de controles CNBV / LFPIORPI / PLD |
| DISCOVER → DESIGN | **Interoperability** (`Framework/Interoperability/`) | §03 draft, §07 | §07 con patrones por dependencia, §03 API gateway policy, §03.5 versionado |
| DESIGN → BUILD | **Cloud SME** (AWS/GCP según stack cliente) | §05, §10 draft | Módulos IaC, §10 completo, pipeline de deployment en ArgoCD |
| BUILD | **Software Engineering** | Spec `APPROVED` completo | Implementación Java/Quarkus, unit tests, contract tests |
| BUILD → TEST | **Equivalence Testing** (`Technology/Software Engineering/Specialist - Equivalence Testing/`) | §08, sistema legado si aplica | Test suite de equivalencia funcional (si hay sistema legado que este reemplaza) |
| BUILD → TEST | **SI & AD Effort Estimator** (`Technology/Software Engineering/Specialist - SI & AD Effort Estimator/`) | §12 draft, §02 capacidades | §12.2 Estimación validada de esfuerzo por fase y por rol |
| ALL | **Program Management** (`Management/Program Management/`) | §12.4 RAID, §12.1 fases | §12 completo: WBS, cronograma, RAID activo, dependencias cross-componente |

### 14.2 Protocolo de Handoff

Cada handoff entre fases se materializa en:
1. **Brief de contexto** (formato: sección del spec relevante + resumen en ≤ 1 página)
2. **Sesión de alineación** (30 min máx. con SME receptor)
3. **Artefacto de handoff** firmado en el `delivery-playbook-spe.md`

### 14.3 SLA por Handoff

| Handoff | SLA de respuesta inicial del SME |
|---|---|
| Cualquier SME en fase DISCOVER → DESIGN | 2 días hábiles desde recepción del brief |
| Cloud SME (DESIGN → BUILD) | 3 días hábiles (incluye revisión de módulos IaC) |
| Equivalence Testing (BUILD → TEST) | 5 días hábiles (diseño de test suite) |
| Program Management (ongoing) | 1 día hábil para actualizaciones de RAID |

### 14.4 Ruta de Escalación

| Conflicto | Escalación |
|---|---|
| SME vs. spec (discrepancia técnica) | Lead Architect de ACN decide; ADR si cambia arquitectura |
| Spec vs. regulación (interpretación normativa) | Compliance Officer del cliente + SME GRC de ACN deciden en conjunto |
| Dependencia bloqueada (p. ej. core bancario sin ambiente) | Program Management escala a Steering Committee en < 24h |

---

*Spec `spe-account-onboarding-l2` — versión 0.1.0 — Estado: DRAFT*
*Próxima revisión: cuando stakeholders completen review de §06 (Seguridad) y §13 (Quality Gates)*
*Propietario del documento: Lead Architect del Squad Digital Onboarding*