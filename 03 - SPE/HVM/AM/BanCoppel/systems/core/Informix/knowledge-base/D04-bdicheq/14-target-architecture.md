# D04 · Cheques / Cuentas — Arquitectura Target

> **Componente:** Informix · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdicheq` · Target: **AWS Aurora PostgreSQL**
> **Wave:** Wave 4 · Riesgo: **CRÍTICO**
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

**Patrón:** Transactional Outbox + Saga pattern para transacciones distribuidas

El dominio `bdicheq` es de tipo **financial**. Su migración sigue este patrón porque Primitivos cargo_ref (561) y abono_ref (520). 1,535 SPs. Atomicidad financiera.

## Topología AWS target

```
┌────────────────────────────────────────────────────────────┐
│  D04 · Cheques / Cuentas — AWS Target                 │
│                                                             │
│  [ACL — API Gateway]                                        │
│       │  REST / gRPC / AsyncAPI                             │
│       ▼                                                     │
│  [ECS Fargate (JVM) o Lambda SnapStart]                                         │
│       │                                                     │
│  ┌────┴────────────────────────────┐                        │
│  ▼                                 ▼                        │
│  [Aurora PostgreSQL Multi-AZ]              [EventBridge]               │
│  (migrado de bdicheq)          (reemplaza cross-DB calls)      │
│       │                                                     │
│  [SQS con DLQ]     [CloudWatch + X-Ray]                  │
│  (DLQ + reintentos)   (observabilidad)                      │
└────────────────────────────────────────────────────────────┘
```

## SPs públicos → endpoints API candidatos

Estos SPs tienen el mayor fan-in — son los puntos de entrada del dominio que se convierten en API:

| SP (Informix) | Fan-in | Endpoint target |
|--------------|--------|----------------|
| `cargo_ref` | 561 callers | REST endpoint / evento |
| `abono_ref` | 520 callers | REST endpoint / evento |
| `reversion` | 377 callers | REST endpoint / evento |
| `sp_generafolionomina` | 253 callers | REST endpoint / evento |
| `bloqueo_cta` | 184 callers | REST endpoint / evento |

> **[SME-PENDING — Core Banking Transformation]** Para cada SP: definir si es síncrono (REST/gRPC) o asíncrono (evento). El criterio: ¿el caller necesita la respuesta en el mismo request? Sí → REST. No → EventBridge/SNS.

## Anti-Corruption Layer (ACL) — contratos a diseñar

Para cada dependencia cross-DB, el ACL traduce `CALL db:sp()` a una llamada API:

| Dependencia actual | Volumen | Tipo de contrato | Responsable |
|-------------------|---------|-----------------|------------|
| `bdicheq` → `bdinteg` | 130 | API interna / evento | [SME-PENDING] |
| `bdicheq` → `bdispei` | 74 | API interna / evento | [SME-PENDING] |
| `bdicheq` → `bdimnsj` | 72 | API interna / evento | [SME-PENDING] |
| `bdicheq` → `bdicred` | 45 | API interna / evento | [SME-PENDING] |
| `bdicheq` → `bdiprog` | 43 | API interna / evento | [SME-PENDING] |

## Servicios AWS seleccionados

| Componente | Servicio AWS | Justificación |
|-----------|-------------|--------------|
| Cómputo | ECS Fargate (JVM) o Lambda SnapStart | Apropiado para tipo financial |
| Base de datos | Aurora PostgreSQL Multi-AZ | Reemplaza instancia Informix bdicheq |
| Eventos/mensajes | EventBridge | Reemplaza cross-DB calls asincrónicos |
| Colas + DLQ | SQS con DLQ | Retry pattern para operaciones fallidas |
| Feature flags | AWS AppConfig | Reemplaza tabla `mnsj_param` / tablas de config |
| Cifrado PII | AWS KMS (CMK) | LFPDPPP + CNBV — datos personales y financieros |
| Observabilidad | CloudWatch + X-Ray | Métricas, logs estructurados, distributed tracing |
| Auditoría | AWS CloudTrail | Audit trail para CNBV (retención 5 años) |

## Pre-requisitos para iniciar BUILD

El dominio `Cheques / Cuentas` no puede entrar a BUILD hasta que estén disponibles:
- **Dominios upstream:** SPEI, Mensajería
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
