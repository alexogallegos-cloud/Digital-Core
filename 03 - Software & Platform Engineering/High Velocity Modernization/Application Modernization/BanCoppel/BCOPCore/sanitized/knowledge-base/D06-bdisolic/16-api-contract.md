# D06 · Solicitudes — Contratos de API (OpenAPI / AsyncAPI)

> **Componente:** LegacyCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdisolic` → Target: Step Functions + Lambda
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

Este documento define los **contratos de interfaz** que el microservicio target de `Solicitudes` debe exponer para reemplazar las llamadas `CALL bdisolic:sp_nombre()` del sistema Informix. Sin estos contratos, los 84 SPs de los dominios callers no pueden migrar.

## Protocolo de contrato seleccionado

**Patrón:** Workflow engine para solicitudes multi-paso
- SPs de alta frecuencia y respuesta síncrona → **REST (OpenAPI 3.1)**
- SPs de notificación o batch → **AsyncAPI / EventBridge event schema**
- Transacciones que cruzan múltiples dominios → **Saga pattern** con compensating transactions

## Endpoints API candidatos

Los siguientes SPs tienen el mayor fan-in — son los contratos de mayor prioridad:


### API-D06-01: `sp_asigna_solicitud_soc` → `POST /asigna-solicitud-soc`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdisolic:sp_asigna_solicitud_soc` |
| Fan-in (callers actuales) | 236 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 236 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert LegacyCore]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /asigna-solicitud-soc:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: asignasolicitudsoc
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

### API-D06-02: `determina_lincred_tc_cjunk` → `POST /determina-lincred-tc-cjunk`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdisolic:determina_lincred_tc_cjunk` |
| Fan-in (callers actuales) | 208 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 208 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert LegacyCore]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /determina-lincred-tc-cjunk:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: determinalincredtccjunk
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

### API-D06-03: `sp_obtienegrupo` → `POST /obtienegrupo`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdisolic:sp_obtienegrupo` |
| Fan-in (callers actuales) | 174 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 174 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert LegacyCore]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /obtienegrupo:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: obtienegrupo
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

### API-D06-04: `sp_consultarfacturacionos2` → `POST /consultarfacturacionos2`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdisolic:sp_consultarfacturacionos2` |
| Fan-in (callers actuales) | 168 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 168 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert LegacyCore]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /consultarfacturacionos2:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: consultarfacturacionos2
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

### API-D06-05: `califica_scoring2_cjunk` → `POST /califica-scoring2-cjunk`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdisolic:califica_scoring2_cjunk` |
| Fan-in (callers actuales) | 167 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 167 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert LegacyCore]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /califica-scoring2-cjunk:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: calificascoring2cjunk
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
  title: Solicitudes Events
  version: '1.0.0-DRAFT'
channels:
  bdisolic/events:
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
