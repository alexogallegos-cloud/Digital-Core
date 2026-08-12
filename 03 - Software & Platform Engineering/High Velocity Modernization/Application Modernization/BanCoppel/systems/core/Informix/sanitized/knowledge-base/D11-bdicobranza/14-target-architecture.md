# D11 · Cobranza — Arquitectura Target

> **Componente:** LegacyCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdicobranza` · Target: **AWS Aurora PostgreSQL**
> **Wave:** Wave 2 · Riesgo: **MEDIO**
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


## Principio arquitectónico para este dominio

**Patrón:** Collections workflow con reintentos automáticos

El dominio `bdicobranza` es de tipo **collections**. Su migración sigue este patrón porque Cobranza y recuperación de cartera. 311 SPs.

## Topología AWS target

```
┌────────────────────────────────────────────────────────────┐
│  D11 · Cobranza — AWS Target                 │
│                                                             │
│  [ACL — API Gateway]                                        │
│       │  REST / gRPC / AsyncAPI                             │
│       ▼                                                     │
│  [Step Functions + Lambda]                                         │
│       │                                                     │
│  ┌────┴────────────────────────────┐                        │
│  ▼                                 ▼                        │
│  [Aurora PostgreSQL]              [EventBridge Scheduler]               │
│  (migrado de bdicobranza)          (reemplaza cross-DB calls)      │
│       │                                                     │
│  [SQS]     [CloudWatch + X-Ray]                  │
│  (DLQ + reintentos)   (observabilidad)                      │
└────────────────────────────────────────────────────────────┘
```

## SPs públicos → endpoints API candidatos

Estos SPs tienen el mayor fan-in — son los puntos de entrada del dominio que se convierten en API:

| SP (Informix) | Fan-in | Endpoint target |
|--------------|--------|----------------|
| `sp_inserta_bitacora_cob` | 406 callers | REST endpoint / evento |
| `sp_cat_graba_telefono_adicional` | 15 callers | REST endpoint / evento |
| `sp_cat_gen_info_admin` | 7 callers | REST endpoint / evento |
| `sp_consultacuentascliente_bis` | 4 callers | REST endpoint / evento |
| `sp_consultacuentascliente_crd` | 4 callers | REST endpoint / evento |

> **[SME-PENDING — Core Banking Transformation]** Para cada SP: definir si es síncrono (REST/gRPC) o asíncrono (evento). El criterio: ¿el caller necesita la respuesta en el mismo request? Sí → REST. No → EventBridge/SNS.

## Anti-Corruption Layer (ACL) — contratos a diseñar

Para cada dependencia cross-DB, el ACL traduce `CALL db:sp()` a una llamada API:

| Dependencia actual | Volumen | Tipo de contrato | Responsable |
|-------------------|---------|-----------------|------------|
| `bdicobranza` → `bdicred` | 74 | API interna / evento | [SME-PENDING] |
| `bdicobranza` → `bdinteg` | 57 | API interna / evento | [SME-PENDING] |
| `bdicobranza` → `bdimnsj` | 53 | API interna / evento | [SME-PENDING] |
| `bdicobranza` → `bdisitesp` | 27 | API interna / evento | [SME-PENDING] |
| `bdicobranza` → `bdimonitorcob` | 12 | API interna / evento | [SME-PENDING] |

## Servicios AWS seleccionados

| Componente | Servicio AWS | Justificación |
|-----------|-------------|--------------|
| Cómputo | Step Functions + Lambda | Apropiado para tipo collections |
| Base de datos | Aurora PostgreSQL | Reemplaza instancia Informix bdicobranza |
| Eventos/mensajes | EventBridge Scheduler | Reemplaza cross-DB calls asincrónicos |
| Colas + DLQ | SQS | Retry pattern para operaciones fallidas |
| Feature flags | AWS AppConfig | Reemplaza tabla `mnsj_param` / tablas de config |
| Cifrado PII | AWS KMS (CMK) | LFPDPPP + CNBV — datos personales y financieros |
| Observabilidad | CloudWatch + X-Ray | Métricas, logs estructurados, distributed tracing |
| Auditoría | AWS CloudTrail | Audit trail para CNBV (retención 5 años) |

## Pre-requisitos para iniciar BUILD

El dominio `Cobranza` no puede entrar a BUILD hasta que estén disponibles:
- **Dominios upstream:** Mensajería
- **ACL diseñada y aprobada** por Core Banking Transformation
- **API contracts** de `16-api-contract.md` aprobados por Domain Expert LegacyCore
- **Golden master** capturado (ver `10-test-strategy.md`)
- **Schema real** completado por DBA IBM Informix (ver `12-er-model.md` Etapa 2)

## Regulación aplicable en AWS

| Regulación | Impacto en arquitectura |
|-----------|------------------------|
| CNBV | [SME-PENDING — Cybersecurity + Industry Banking] |
| CONDUSEF | [SME-PENDING — Cybersecurity + Industry Banking] |


---
*Generado por: Cloud Architect — AWS Banking · 2026-07-03 · [SME-PENDING] requiere validación de Core Banking Transformation*
