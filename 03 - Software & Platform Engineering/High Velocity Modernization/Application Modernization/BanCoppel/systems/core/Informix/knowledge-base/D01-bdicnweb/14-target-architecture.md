# D01 · Canal Digital Web — Arquitectura Target

> **Componente:** Informix · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdicnweb` · Target: **AWS Aurora PostgreSQL**
> **Wave:** ÚLTIMO · Riesgo: **ALTO**
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


## Principio arquitectónico para este dominio

**Patrón:** BFF (Backend for Frontend) + strangler-fig

El dominio `bdicnweb` es de tipo **orchestrator**. Su migración sigue este patrón porque Orquestación del canal web/móvil. 2,184 SPs. Mayor fan-out del sistema.

## Topología AWS target

```
┌────────────────────────────────────────────────────────────┐
│  D01 · Canal Digital Web — AWS Target                 │
│                                                             │
│  [ACL — API Gateway]                                        │
│       │  REST / gRPC / AsyncAPI                             │
│       ▼                                                     │
│  [API Gateway + Lambda]                                         │
│       │                                                     │
│  ┌────┴────────────────────────────┐                        │
│  ▼                                 ▼                        │
│  [Aurora PostgreSQL]              [EventBridge]               │
│  (migrado de bdicnweb)          (reemplaza cross-DB calls)      │
│       │                                                     │
│  [SQS]     [CloudWatch + X-Ray]                  │
│  (DLQ + reintentos)   (observabilidad)                      │
└────────────────────────────────────────────────────────────┘
```

## SPs públicos → endpoints API candidatos

Estos SPs tienen el mayor fan-in — son los puntos de entrada del dominio que se convierten en API:

| SP (Informix) | Fan-in | Endpoint target |
|--------------|--------|----------------|
| `sp_split_cadena` | 857 callers | REST endpoint / evento |
| `sp_ope_consultarutalmacenamientoxml` | 372 callers | REST endpoint / evento |
| `sp_bitacora` | 345 callers | REST endpoint / evento |
| `sp_generararchivo_rst` | 345 callers | REST endpoint / evento |
| `sp_obtieneencabezadomasivo` | 314 callers | REST endpoint / evento |

> **[SME-PENDING — Core Banking Transformation]** Para cada SP: definir si es síncrono (REST/gRPC) o asíncrono (evento). El criterio: ¿el caller necesita la respuesta en el mismo request? Sí → REST. No → EventBridge/SNS.

## Anti-Corruption Layer (ACL) — contratos a diseñar

Para cada dependencia cross-DB, el ACL traduce `CALL db:sp()` a una llamada API:

| Dependencia actual | Volumen | Tipo de contrato | Responsable |
|-------------------|---------|-----------------|------------|
| `bdicnweb` → `bdinteg` | 15,304 | API interna / evento | [SME-PENDING] |
| `bdicnweb` → `bdicred` | 10,903 | API interna / evento | [SME-PENDING] |
| `bdicnweb` → `bdisuc` | 6,094 | API interna / evento | [SME-PENDING] |
| `bdicnweb` → `bdirech` | 3,541 | API interna / evento | [SME-PENDING] |
| `bdicnweb` → `bdisac` | 3,464 | API interna / evento | [SME-PENDING] |

## Servicios AWS seleccionados

| Componente | Servicio AWS | Justificación |
|-----------|-------------|--------------|
| Cómputo | API Gateway + Lambda | Apropiado para tipo orchestrator |
| Base de datos | Aurora PostgreSQL | Reemplaza instancia Informix bdicnweb |
| Eventos/mensajes | EventBridge | Reemplaza cross-DB calls asincrónicos |
| Colas + DLQ | SQS | Retry pattern para operaciones fallidas |
| Feature flags | AWS AppConfig | Reemplaza tabla `mnsj_param` / tablas de config |
| Cifrado PII | AWS KMS (CMK) | LFPDPPP + CNBV — datos personales y financieros |
| Observabilidad | CloudWatch + X-Ray | Métricas, logs estructurados, distributed tracing |
| Auditoría | AWS CloudTrail | Audit trail para CNBV (retención 5 años) |

## Pre-requisitos para iniciar BUILD

El dominio `Canal Digital Web` no puede entrar a BUILD hasta que estén disponibles:
- **Dominios upstream:** Integración y Autenticación, Créditos, Sucursales, Saldos y Cuentas
- **ACL diseñada y aprobada** por Core Banking Transformation
- **API contracts** de `16-api-contract.md` aprobados por Domain Expert BanCoppel
- **Golden master** capturado (ver `10-test-strategy.md`)
- **Schema real** completado por DBA IBM Informix (ver `12-er-model.md` Etapa 2)

## Regulación aplicable en AWS

| Regulación | Impacto en arquitectura |
|-----------|------------------------|
| CNBV | [SME-PENDING — Cybersecurity + Industry Banking] |
| LFPDPPP | [SME-PENDING — Cybersecurity + Industry Banking] |


---
*Generado por: Cloud Architect — AWS Banking · 2026-07-03 · [SME-PENDING] requiere validación de Core Banking Transformation*
