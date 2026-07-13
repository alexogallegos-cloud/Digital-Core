# D01 · Canal Digital Web — Contratos de API (OpenAPI / AsyncAPI)

> **Componente:** BCOPCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdicnweb` → Target: API Gateway + Lambda
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

Este documento define los **contratos de interfaz** que el microservicio target de `Canal Digital Web` debe exponer para reemplazar las llamadas `CALL bdicnweb:sp_nombre()` del sistema Informix. Sin estos contratos, los 2122 SPs de los dominios callers no pueden migrar.

## Protocolo de contrato seleccionado

**Patrón:** BFF (Backend for Frontend) + strangler-fig
- SPs de alta frecuencia y respuesta síncrona → **REST (OpenAPI 3.1)**
- SPs de notificación o batch → **AsyncAPI / EventBridge event schema**
- Transacciones que cruzan múltiples dominios → **Saga pattern** con compensating transactions

## Endpoints API candidatos

Los siguientes SPs tienen el mayor fan-in — son los contratos de mayor prioridad:


### API-D01-01: `sp_split_cadena` → `POST /split-cadena`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicnweb:sp_split_cadena` |
| Fan-in (callers actuales) | 857 |
| Protocolo target | AsyncAPI (evento) |
| Callers que deben migrar | 857 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /split-cadena:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: splitcadena
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

### API-D01-02: `sp_ope_consultarutalmacenamientoxml` → `POST /ope-consultarutalmacenamientoxml`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicnweb:sp_ope_consultarutalmacenamientoxml` |
| Fan-in (callers actuales) | 372 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 372 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /ope-consultarutalmacenamientoxml:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: opeconsultarutalmacenamientoxml
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

### API-D01-03: `sp_bitacora` → `POST /bitacora`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicnweb:sp_bitacora` |
| Fan-in (callers actuales) | 345 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 345 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /bitacora:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: bitacora
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

### API-D01-04: `sp_generararchivo_rst` → `POST /generararchivo-rst`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicnweb:sp_generararchivo_rst` |
| Fan-in (callers actuales) | 345 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 345 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /generararchivo-rst:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: generararchivorst
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

### API-D01-05: `sp_obtieneencabezadomasivo` → `POST /obtieneencabezadomasivo`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicnweb:sp_obtieneencabezadomasivo` |
| Fan-in (callers actuales) | 314 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 314 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /obtieneencabezadomasivo:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: obtieneencabezadomasivo
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
  title: Canal Digital Web Events
  version: '1.0.0-DRAFT'
channels:
  bdicnweb/events:
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
