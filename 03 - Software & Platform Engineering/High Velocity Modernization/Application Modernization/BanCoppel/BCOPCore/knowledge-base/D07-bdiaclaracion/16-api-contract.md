# D07 · Aclaraciones — Contratos de API (OpenAPI / AsyncAPI)

> **Componente:** BCOPCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdiaclaracion` → Target: Lambda + Step Functions
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

Este documento define los **contratos de interfaz** que el microservicio target de `Aclaraciones` debe exponer para reemplazar las llamadas `CALL bdiaclaracion:sp_nombre()` del sistema Informix. Sin estos contratos, los 84 SPs de los dominios callers no pueden migrar.

## Protocolo de contrato seleccionado

**Patrón:** Audit-first — todo con CloudTrail + registro inmutable
- SPs de alta frecuencia y respuesta síncrona → **REST (OpenAPI 3.1)**
- SPs de notificación o batch → **AsyncAPI / EventBridge event schema**
- Transacciones que cruzan múltiples dominios → **Saga pattern** con compensating transactions

## Endpoints API candidatos

Los siguientes SPs tienen el mayor fan-in — son los contratos de mayor prioridad:


### API-D07-01: `sp_fal_cancelacion_cuenta_credito` → `POST /fal-cancelacion-cuenta-credito`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdiaclaracion:sp_fal_cancelacion_cuenta_credito` |
| Fan-in (callers actuales) | 40 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 40 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /fal-cancelacion-cuenta-credito:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: falcancelacioncuentacredito
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

### API-D07-02: `sp_fal_cancelacion_cuenta_debito` → `POST /fal-cancelacion-cuenta-debito`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdiaclaracion:sp_fal_cancelacion_cuenta_debito` |
| Fan-in (callers actuales) | 40 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 40 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /fal-cancelacion-cuenta-debito:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: falcancelacioncuentadebito
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

### API-D07-03: `sp_fal_liquidacion_asignar_analista` → `POST /fal-liquidacion-asignar-analista`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdiaclaracion:sp_fal_liquidacion_asignar_analista` |
| Fan-in (callers actuales) | 34 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 34 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /fal-liquidacion-asignar-analista:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: falliquidacionasignaranalista
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

### API-D07-04: `sp_fal_obtener_saldo_debito` → `POST /fal-obtener-saldo-debito`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdiaclaracion:sp_fal_obtener_saldo_debito` |
| Fan-in (callers actuales) | 33 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 33 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /fal-obtener-saldo-debito:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: falobtenersaldodebito
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

### API-D07-05: `sp_fal_asignar_analista_credito` → `POST /fal-asignar-analista-credito`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdiaclaracion:sp_fal_asignar_analista_credito` |
| Fan-in (callers actuales) | 21 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 21 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /fal-asignar-analista-credito:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: falasignaranalistacredito
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
  title: Aclaraciones Events
  version: '1.0.0-DRAFT'
channels:
  bdiaclaracion/events:
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
