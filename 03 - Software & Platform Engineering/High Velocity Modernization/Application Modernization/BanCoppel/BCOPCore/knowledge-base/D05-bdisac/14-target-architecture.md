# D05 · Saldos y Cuentas — Arquitectura Target

> **Componente:** BCOPCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdisac` · Target: **AWS Aurora PostgreSQL**
> **Wave:** Wave 3 · Riesgo: **ALTO**
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

**Patrón:** CQRS — read model separado

El dominio `bdisac` es de tipo **query**. Su migración sigue este patrón porque Consulta y administración de saldos. 563 SPs.

## Topología AWS target

```
┌────────────────────────────────────────────────────────────┐
│  D05 · Saldos y Cuentas — AWS Target                 │
│                                                             │
│  [ACL — API Gateway]                                        │
│       │  REST / gRPC / AsyncAPI                             │
│       ▼                                                     │
│  [Lambda]                                         │
│       │                                                     │
│  ┌────┴────────────────────────────┐                        │
│  ▼                                 ▼                        │
│  [Aurora PostgreSQL + ElastiCache (Redis)]              [EventBridge]               │
│  (migrado de bdisac)          (reemplaza cross-DB calls)      │
│       │                                                     │
│  [SQS]     [CloudWatch + X-Ray]                  │
│  (DLQ + reintentos)   (observabilidad)                      │
└────────────────────────────────────────────────────────────┘
```

## SPs públicos → endpoints API candidatos

Estos SPs tienen el mayor fan-in — son los puntos de entrada del dominio que se convierten en API:

| SP (Informix) | Fan-in | Endpoint target |
|--------------|--------|----------------|
| `sp_sac_guardamensajeerror` | 321 callers | REST endpoint / evento |
| `sp_validanombenefbts` | 243 callers | REST endpoint / evento |
| `sp_sac_consucursales` | 195 callers | REST endpoint / evento |
| `sp_validabts` | 182 callers | REST endpoint / evento |
| `sp_obtieneparametro` | 176 callers | REST endpoint / evento |

> **[SME-PENDING — Core Banking Transformation]** Para cada SP: definir si es síncrono (REST/gRPC) o asíncrono (evento). El criterio: ¿el caller necesita la respuesta en el mismo request? Sí → REST. No → EventBridge/SNS.

## Anti-Corruption Layer (ACL) — contratos a diseñar

Para cada dependencia cross-DB, el ACL traduce `CALL db:sp()` a una llamada API:

| Dependencia actual | Volumen | Tipo de contrato | Responsable |
|-------------------|---------|-----------------|------------|
| `bdisac` → `bdicheq` | 331 | API interna / evento | [SME-PENDING] |
| `bdisac` → `bdinteg` | 145 | API interna / evento | [SME-PENDING] |
| `bdisac` → `bdicred` | 49 | API interna / evento | [SME-PENDING] |
| `bdisac` → `bditef` | 42 | API interna / evento | [SME-PENDING] |
| `bdisac` → `bdicnweb` | 29 | API interna / evento | [SME-PENDING] |

## Servicios AWS seleccionados

| Componente | Servicio AWS | Justificación |
|-----------|-------------|--------------|
| Cómputo | Lambda | Apropiado para tipo query |
| Base de datos | Aurora PostgreSQL + ElastiCache (Redis) | Reemplaza instancia Informix bdisac |
| Eventos/mensajes | EventBridge | Reemplaza cross-DB calls asincrónicos |
| Colas + DLQ | SQS | Retry pattern para operaciones fallidas |
| Feature flags | AWS AppConfig | Reemplaza tabla `mnsj_param` / tablas de config |
| Cifrado PII | AWS KMS (CMK) | LFPDPPP + CNBV — datos personales y financieros |
| Observabilidad | CloudWatch + X-Ray | Métricas, logs estructurados, distributed tracing |
| Auditoría | AWS CloudTrail | Audit trail para CNBV (retención 5 años) |

## Pre-requisitos para iniciar BUILD

El dominio `Saldos y Cuentas` no puede entrar a BUILD hasta que estén disponibles:
- **Dominios upstream:** (sin prereqs en dominios anteriores)
- **ACL diseñada y aprobada** por Core Banking Transformation
- **API contracts** de `16-api-contract.md` aprobados por Domain Expert BanCoppel
- **Golden master** capturado (ver `10-test-strategy.md`)
- **Schema real** completado por DBA IBM Informix (ver `12-er-model.md` Etapa 2)

## Regulación aplicable en AWS

| Regulación | Impacto en arquitectura |
|-----------|------------------------|
| CNBV | [SME-PENDING — Cybersecurity + Industry Banking] |


---
*Generado por: Cloud Architect — AWS Banking · 2026-07-03 · [SME-PENDING] requiere validación de Core Banking Transformation*
