# D12 · Contabilidad — Contratos de API (OpenAPI / AsyncAPI)

> **Componente:** Informix · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdicont` → Target: Lambda (idempotente)
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

Este documento define los **contratos de interfaz** que el microservicio target de `Contabilidad` debe exponer para reemplazar las llamadas `CALL bdicont:sp_nombre()` del sistema Informix. Sin estos contratos, los 19 SPs de los dominios callers no pueden migrar.

## Protocolo de contrato seleccionado

**Patrón:** Event sourcing — ledger inmutable
- SPs de alta frecuencia y respuesta síncrona → **REST (OpenAPI 3.1)**
- SPs de notificación o batch → **AsyncAPI / EventBridge event schema**
- Transacciones que cruzan múltiples dominios → **Saga pattern** con compensating transactions

## Endpoints API candidatos

Los siguientes SPs tienen el mayor fan-in — son los contratos de mayor prioridad:


### API-D12-01: `sp_consultaparametrosgenerales2` → `POST /consultaparametrosgenerales2`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicont:sp_consultaparametrosgenerales2` |
| Fan-in (callers actuales) | 16 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 16 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /consultaparametrosgenerales2:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: consultaparametrosgenerales2
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

### API-D12-02: `sp_datosdiahoy_cod47_2` → `POST /datosdiahoy-cod47-2`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicont:sp_datosdiahoy_cod47_2` |
| Fan-in (callers actuales) | 16 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 16 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /datosdiahoy-cod47-2:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: datosdiahoycod472
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

### API-D12-03: `sp_ope_catalogomotivos2` → `POST /ope-catalogomotivos2`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicont:sp_ope_catalogomotivos2` |
| Fan-in (callers actuales) | 16 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 16 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /ope-catalogomotivos2:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: opecatalogomotivos2
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

### API-D12-04: `sp_si_empresasb4` → `POST /si-empresasb4`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicont:sp_si_empresasb4` |
| Fan-in (callers actuales) | 1 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 1 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /si-empresasb4:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: siempresasb4
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

### API-D12-05: `sp_cam_asigna_rev_firmasb3` → `POST /cam-asigna-rev-firmasb3`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicont:sp_cam_asigna_rev_firmasb3` |
| Fan-in (callers actuales) | 0 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 0 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /cam-asigna-rev-firmasb3:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: camasignarevfirmasb3
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
  title: Contabilidad Events
  version: '1.0.0-DRAFT'
channels:
  bdicont/events:
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
