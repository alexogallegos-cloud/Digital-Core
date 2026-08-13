# D08 · SPEI — Contratos de API (OpenAPI / AsyncAPI)

> **Componente:** Informix · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdispei` → Target: ECS Fargate (JVM) + Lambda
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

Este documento define los **contratos de interfaz** que el microservicio target de `SPEI` debe exponer para reemplazar las llamadas `CALL bdispei:sp_nombre()` del sistema Informix. Sin estos contratos, los 46 SPs de los dominios callers no pueden migrar.

## Protocolo de contrato seleccionado

**Patrón:** Event-driven + certificación Banxico SPEI
- SPs de alta frecuencia y respuesta síncrona → **REST (OpenAPI 3.1)**
- SPs de notificación o batch → **AsyncAPI / EventBridge event schema**
- Transacciones que cruzan múltiples dominios → **Saga pattern** con compensating transactions

## Endpoints API candidatos

Los siguientes SPs tienen el mayor fan-in — son los contratos de mayor prioridad:


### API-D08-01: `sp_validafecha` → `POST /validafecha`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdispei:sp_validafecha` |
| Fan-in (callers actuales) | 52 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 52 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /validafecha:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: validafecha
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

### API-D08-02: `spei_recerrorescodi` → `POST /spei-recerrorescodi`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdispei:spei_recerrorescodi` |
| Fan-in (callers actuales) | 27 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 27 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /spei-recerrorescodi:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: speirecerrorescodi
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

### API-D08-03: `sp_regordenctecte_pp` → `POST /regordenctecte-pp`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdispei:sp_regordenctecte_pp` |
| Fan-in (callers actuales) | 9 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 9 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /regordenctecte-pp:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: regordenctectepp
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

### API-D08-04: `spei_recdevolucion` → `POST /spei-recdevolucion`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdispei:spei_recdevolucion` |
| Fan-in (callers actuales) | 2 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 2 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /spei-recdevolucion:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: speirecdevolucion
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

### API-D08-05: `spei_recextemporanea` → `POST /spei-recextemporanea`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdispei:spei_recextemporanea` |
| Fan-in (callers actuales) | 2 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 2 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /spei-recextemporanea:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: speirecextemporanea
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
  title: SPEI Events
  version: '1.0.0-DRAFT'
channels:
  bdispei/events:
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
