# D02 · Integración y Autenticación — Contratos de API (OpenAPI / AsyncAPI)

> **Componente:** BCOPCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdinteg` → Target: Lambda + Cognito
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

Este documento define los **contratos de interfaz** que el microservicio target de `Integración y Autenticación` debe exponer para reemplazar las llamadas `CALL bdinteg:sp_nombre()` del sistema Informix. Sin estos contratos, los 220 SPs de los dominios callers no pueden migrar.

## Protocolo de contrato seleccionado

**Patrón:** AuthService centralizado — todos los dominios dependen de él
- SPs de alta frecuencia y respuesta síncrona → **REST (OpenAPI 3.1)**
- SPs de notificación o batch → **AsyncAPI / EventBridge event schema**
- Transacciones que cruzan múltiples dominios → **Saga pattern** con compensating transactions

## Endpoints API candidatos

Los siguientes SPs tienen el mayor fan-in — son los contratos de mayor prioridad:


### API-D02-01: `sp_cnsif_confirmaejecutivo` → `POST /cnsif-confirmaejecutivo`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdinteg:sp_cnsif_confirmaejecutivo` |
| Fan-in (callers actuales) | 2,400 |
| Protocolo target | AsyncAPI (evento) |
| Callers que deben migrar | 2,400 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /cnsif-confirmaejecutivo:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: cnsifconfirmaejecutivo
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

### API-D02-02: `sp_cnsif_permisosejecutivo` → `POST /cnsif-permisosejecutivo`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdinteg:sp_cnsif_permisosejecutivo` |
| Fan-in (callers actuales) | 621 |
| Protocolo target | AsyncAPI (evento) |
| Callers que deben migrar | 621 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /cnsif-permisosejecutivo:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: cnsifpermisosejecutivo
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

### API-D02-03: `sp_valida_perfil_usuario` → `POST /valida-perfil-usuario`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdinteg:sp_valida_perfil_usuario` |
| Fan-in (callers actuales) | 388 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 388 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /valida-perfil-usuario:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: validaperfilusuario
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

### API-D02-04: `sp_desc_ret` → `POST /desc-ret`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdinteg:sp_desc_ret` |
| Fan-in (callers actuales) | 358 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 358 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /desc-ret:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: descret
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

### API-D02-05: `sp_cuentadoctos_soc` → `POST /cuentadoctos-soc`

| Atributo | Valor |
|----------|-------|
| SP origen | `bdinteg:sp_cuentadoctos_soc` |
| Fan-in (callers actuales) | 354 |
| Protocolo target | OpenAPI 3.1 (REST) |
| Callers que deben migrar | 354 SPs en otros dominios |

**[SME-PENDING — Core Banking Transformation + Domain Expert BanCoppel]**
```yaml
# OpenAPI 3.1 draft — completar con Domain Expert
paths:
  /cuentadoctos-soc:
    post:
      summary: "[SME-PENDING] Descripción de negocio del endpoint"
      operationId: cuentadoctossoc
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
  title: Integración y Autenticación Events
  version: '1.0.0-DRAFT'
channels:
  bdinteg/events:
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
