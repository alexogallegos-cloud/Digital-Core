# D10 · Sucursales — Contratos de API (OpenAPI / AsyncAPI)

> **Componente:** LegacyCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdisuc` → Target: Lambda
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático y equivalencias)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- Cloud Architect — AWS Banking (arquitectura target y servicios AWS)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- Core Banking Transformation (ACL design y API contracts)
- Industry Banking / Domain Expert LegacyCore (validación funcional)
- Cybersecurity (PII, CNBV, LFPDPPP, PCI-DSS)
- SRE & AIOps (observabilidad y runbooks)
- Data & ML — Data Architect (migración de datos, CDC Debezium)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.
---


## Propósito

Este documento define los **contratos de interfaz** que el microservicio target de `Sucursales` debe exponer para reemplazar las llamadas `CALL bdisuc:sp_nombre()` del sistema Informix. Sin estos contratos, los 37 SPs de los dominios callers no pueden migrar.

## Protocolo de contrato seleccionado

**Patrón:** Branch-as-a-Service — operaciones de caja como microservicio
- SPs de alta frecuencia y respuesta síncrona → **REST (OpenAPI 3.1)**
- SPs de notificación o batch → **AsyncAPI / EventBridge event schema**
- Transacciones que cruzan múltiples dominios → **Saga pattern** con compensating transactions

## Endpoints API candidatos

Los siguientes SPs tienen el mayor fan-in — son los contratos de mayor prioridad:


### API-D10-01: `sp_consultadatospiezas_bym3` → `POST /consultadatospiezas-bym3`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdisuc:sp_consultadatospiezas_bym3` |
| Fan-in (callers actuales) | 381 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 381 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert LegacyCore]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /consultadatospiezas-bym3:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: consultadatospiezasbym3
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

### API-D10-02: `sp_consutacat_dictamen_bym` → `POST /consutacat-dictamen-bym`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdisuc:sp_consutacat_dictamen_bym` |
| Fan-in (callers actuales) | 378 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 378 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert LegacyCore]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /consutacat-dictamen-bym:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: consutacatdictamenbym
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

### API-D10-03: `sp_consultadatospiezas_bym3_totales` → `POST /consultadatospiezas-bym3-totales`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdisuc:sp_consultadatospiezas_bym3_totales` |
| Fan-in (callers actuales) | 376 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 376 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert LegacyCore]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /consultadatospiezas-bym3-totales:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: consultadatospiezasbym3totales
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

### API-D10-04: `sp_consultadatospiezas_bym2` → `POST /consultadatospiezas-bym2`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdisuc:sp_consultadatospiezas_bym2` |
| Fan-in (callers actuales) | 376 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 376 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert LegacyCore]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /consultadatospiezas-bym2:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: consultadatospiezasbym2
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

### API-D10-05: `sp_consultacat_estatus_bym` → `POST /consultacat-estatus-bym`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdisuc:sp_consultacat_estatus_bym` |
| Fan-in (callers actuales) | 375 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 375 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert LegacyCore]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /consultacat-estatus-bym:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: consultacatestatusbym
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
  title: Sucursales Events
  version: '1.0.0-DRAFT'
channels:
  bdisuc/events:
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

- [ ] **Domain Expert LegacyCore** — validar que los endpoints reflejan los casos de uso reales
- [ ] **QA Lead — Equivalencia Funcional** — verificar que los contratos permiten reproducir los casos de prueba del golden master
- [ ] **Cybersecurity** — revisar que no se exponen datos PII en paths/headers
- [ ] **Core Banking Transformation** — aprobar el patrón de errores y autenticación

---
*Generado por: Core Banking Transformation + Cloud Architect AWS Banking · 2026-07-03 · [SME-PENDING] requiere validación Domain Expert*
