# D04 · Cheques / Cuentas — Contratos de API (OpenAPI / AsyncAPI)

> **Componente:** Informix · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdicheq` → Target: ECS Fargate (JVM) o Lambda SnapStart
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático y equivalencias)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- Cloud Architect — AWS Banking (arquitectura target y servicios AWS)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- Core Banking Transformation (ACL design y API contracts)
- Industry Banking / Domain Expert BanCoppel (validación funcional)
- Cybersecurity (PII, CNBV, LFPDPPP, PCI-DSS)
- SRE & AIOps (observabilidad y runbooks)
- Data & ML — Data Architect (migración de datos, CDC Debezium)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.
---


## Propósito

Este documento define los **contratos de interfaz** que el microservicio target de `Cheques / Cuentas` debe exponer para reemplazar las llamadas `CALL bdicheq:sp_nombre()` del sistema Informix. Sin estos contratos, los 111 SPs de los dominios callers no pueden migrar.

## Protocolo de contrato seleccionado

**Patrón:** Transactional Outbox + Saga pattern para transacciones distribuidas
- SPs de alta frecuencia y respuesta síncrona → **REST (OpenAPI 3.1)**
- SPs de notificación o batch → **AsyncAPI / EventBridge event schema**
- Transacciones que cruzan múltiples dominios → **Saga pattern** con compensating transactions

## Endpoints API candidatos

Los siguientes SPs tienen el mayor fan-in — son los contratos de mayor prioridad:


### API-D04-01: `cargo_ref` → `POST /cargo-ref`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicheq:cargo_ref` |
| Fan-in (callers actuales) | 561 |
| Protocolo target | AsyncAPI (evento) |
| Callers que deben migrar | 561 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /cargo-ref:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: cargoref
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                # [SME-PENDING] Mapear parámetros del SP a campos JSON
                # Ver 03-data-dictionary.md para firmas de parámetros
      responses:
        '200':
          description: "[SME-PENDING] Descripción del retorno exitoso"
        '400':
          description: "[SME-PENDING] Errores de validación (RAISE EXCEPTION)"
        '500':
          description: "Error interno del servicio"
```

### API-D04-02: `abono_ref` → `POST /abono-ref`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicheq:abono_ref` |
| Fan-in (callers actuales) | 520 |
| Protocolo target | AsyncAPI (evento) |
| Callers que deben migrar | 520 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /abono-ref:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: abonoref
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                # [SME-PENDING] Mapear parámetros del SP a campos JSON
                # Ver 03-data-dictionary.md para firmas de parámetros
      responses:
        '200':
          description: "[SME-PENDING] Descripción del retorno exitoso"
        '400':
          description: "[SME-PENDING] Errores de validación (RAISE EXCEPTION)"
        '500':
          description: "Error interno del servicio"
```

### API-D04-03: `reversion` → `POST /reversion`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicheq:reversion` |
| Fan-in (callers actuales) | 377 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 377 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /reversion:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: reversion
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                # [SME-PENDING] Mapear parámetros del SP a campos JSON
                # Ver 03-data-dictionary.md para firmas de parámetros
      responses:
        '200':
          description: "[SME-PENDING] Descripción del retorno exitoso"
        '400':
          description: "[SME-PENDING] Errores de validación (RAISE EXCEPTION)"
        '500':
          description: "Error interno del servicio"
```

### API-D04-04: `sp_generafolionomina` → `POST /generafolionomina`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicheq:sp_generafolionomina` |
| Fan-in (callers actuales) | 253 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 253 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /generafolionomina:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: generafolionomina
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                # [SME-PENDING] Mapear parámetros del SP a campos JSON
                # Ver 03-data-dictionary.md para firmas de parámetros
      responses:
        '200':
          description: "[SME-PENDING] Descripción del retorno exitoso"
        '400':
          description: "[SME-PENDING] Errores de validación (RAISE EXCEPTION)"
        '500':
          description: "Error interno del servicio"
```

### API-D04-05: `bloqueo_cta` → `POST /bloqueo-cta`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicheq:bloqueo_cta` |
| Fan-in (callers actuales) | 184 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 184 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /bloqueo-cta:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: bloqueocta
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                # [SME-PENDING] Mapear parámetros del SP a campos JSON
                # Ver 03-data-dictionary.md para firmas de parámetros
      responses:
        '200':
          description: "[SME-PENDING] Descripción del retorno exitoso"
        '400':
          description: "[SME-PENDING] Errores de validación (RAISE EXCEPTION)"
        '500':
          description: "Error interno del servicio"
```


## Contratos de eventos (para SPs invocados asincrónicamente)

```yaml
# AsyncAPI 2.6 draft — completar con Architect AM
asyncapi: '2.6.0'
info:
  title: Cheques / Cuentas Events
  version: '1.0.0-DRAFT'
channels:
  bdicheq/events:
    publish:
      message:
        name: "[SME-PENDING] Tipo de evento principal"
        payload:
          type: object
          # [SME-PENDING] Definir schema del evento
```

## Convenciones obligatorias para todos los contratos

| Convención | Estándar | Razón |
|-----------|----------|-------|
| Versionado | `/v1/` en el path | Cambios backward-compatible sin romper callers |
| Autenticación | Bearer JWT (Cognito) | Reemplaza `bdinteg:sp_cnsif_confirmaejecutivo` |
| Formato de fechas | ISO 8601 con timezone `America/Mexico_City` | Equivalencia con DATETIME Informix |
| Montos financieros | `string` en JSON (no `number`) | Previene pérdida de precisión en MONEY |
| Códigos de error | HTTP 4xx/5xx + error body estándar | Reemplaza `RAISE EXCEPTION` codes |
| Idempotency | Header `Idempotency-Key` obligatorio | Previene duplicados en reintentos |

## Pendientes antes de aprobar contratos

- [ ] **Domain Expert BanCoppel** — validar que los endpoints reflejan los casos de uso reales
- [ ] **QA Lead — Equivalencia Funcional** — verificar que los contratos permiten reproducir los casos de prueba del golden master
- [ ] **Cybersecurity** — revisar que no se exponen datos PII en paths/headers
- [ ] **Core Banking Transformation** — aprobar el patrón de errores y autenticación

---
*Generado por: Core Banking Transformation + Cloud Architect AWS Banking · 2026-07-03 · [SME-PENDING] requiere validación Domain Expert*
