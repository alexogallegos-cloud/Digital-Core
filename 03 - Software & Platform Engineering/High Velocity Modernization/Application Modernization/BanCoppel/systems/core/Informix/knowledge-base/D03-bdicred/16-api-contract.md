# D03 · Créditos — Contratos de API (OpenAPI / AsyncAPI)

> **Componente:** Informix · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdicred` → Target: ECS Fargate (JVM) o Lambda SnapStart
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

Este documento define los **contratos de interfaz** que el microservicio target de `Créditos` debe exponer para reemplazar las llamadas `CALL bdicred:sp_nombre()` del sistema Informix. Sin estos contratos, los 380 SPs de los dominios callers no pueden migrar.

## Protocolo de contrato seleccionado

**Patrón:** Transactional Outbox + Saga pattern para transacciones distribuidas
- SPs de alta frecuencia y respuesta síncrona → **REST (OpenAPI 3.1)**
- SPs de notificación o batch → **AsyncAPI / EventBridge event schema**
- Transacciones que cruzan múltiples dominios → **Saga pattern** con compensating transactions

## Endpoints API candidatos

Los siguientes SPs tienen el mayor fan-in — son los contratos de mayor prioridad:


### API-D03-01: `sp_consulta_saldos_general` → `POST /consulta-saldos-general`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicred:sp_consulta_saldos_general` |
| Fan-in (callers actuales) | 435 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 435 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /consulta-saldos-general:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: consultasaldosgeneral
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

### API-D03-02: `sp_mon_buro_conssolcredlincred2` → `POST /mon-buro-conssolcredlincred2`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicred:sp_mon_buro_conssolcredlincred2` |
| Fan-in (callers actuales) | 325 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 325 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /mon-buro-conssolcredlincred2:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: monburoconssolcredlincred2
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

### API-D03-03: `sp_inserta_productos` → `POST /inserta-productos`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicred:sp_inserta_productos` |
| Fan-in (callers actuales) | 305 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 305 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /inserta-productos:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: insertaproductos
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

### API-D03-04: `sp_consulta_frecpago` → `POST /consulta-frecpago`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicred:sp_consulta_frecpago` |
| Fan-in (callers actuales) | 303 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 303 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /consulta-frecpago:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: consultafrecpago
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

### API-D03-05: `sp_conspoliticacreditoprod` → `POST /conspoliticacreditoprod`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdicred:sp_conspoliticacreditoprod` |
| Fan-in (callers actuales) | 303 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 303 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /conspoliticacreditoprod:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: conspoliticacreditoprod
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
  title: Créditos Events
  version: '1.0.0-DRAFT'
channels:
  bdicred/events:
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
