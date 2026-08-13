# D08 · SPEI — Arquitectura Target

> **Componente:** Informix · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdispei` · Target: **AWS Aurora PostgreSQL**
> **Wave:** Wave 2 · Riesgo: **CRÍTICO**
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

**Patrón:** Event-driven + certificación Banxico SPEI

El dominio `bdispei` es de tipo **payments**. Su migración sigue este patrón porque Transferencias SPEI Banxico. 197 SPs. Certificación Banxico requerida.

## Topología AWS target

```
┌────────────────────────────────────────────────────────────┐
│  D08 · SPEI — AWS Target                 │
│                                                             │
│  [ACL — API Gateway]                                        │
│       │  REST / gRPC / AsyncAPI                             │
│       ▼                                                     │
│  [ECS Fargate (JVM) + Lambda]                                         │
│       │                                                     │
│  ┌────┴────────────────────────────┐                        │
│  ▼                                 ▼                        │
│  [Aurora PostgreSQL Multi-AZ]              [EventBridge Pipes]               │
│  (migrado de bdispei)          (reemplaza cross-DB calls)      │
│       │                                                     │
│  [SQS FIFO]     [CloudWatch + X-Ray]                  │
│  (DLQ + reintentos)   (observabilidad)                      │
└────────────────────────────────────────────────────────────┘
```

## SPs públicos → endpoints API candidatos

Estos SPs tienen el mayor fan-in — son los puntos de entrada del dominio que se convierten en API:

| SP (Informix) | Fan-in | Endpoint target |
|--------------|--------|----------------|
| `sp_validafecha` | 52 callers | REST endpoint / evento |
| `spei_recerrorescodi` | 27 callers | REST endpoint / evento |
| `sp_regordenctecte_pp` | 9 callers | REST endpoint / evento |
| `spei_recdevolucion` | 2 callers | REST endpoint / evento |
| `spei_recextemporanea` | 2 callers | REST endpoint / evento |

> **[SME-PENDING — Core Banking Transformation]** Para cada SP: definir si es síncrono (REST/gRPC) o asíncrono (evento). El criterio: ¿el caller necesita la respuesta en el mismo request? Sí → REST. No → EventBridge/SNS.

## Anti-Corruption Layer (ACL) — contratos a diseñar

Para cada dependencia cross-DB, el ACL traduce `CALL db:sp()` a una llamada API:

| Dependencia actual | Volumen | Tipo de contrato | Responsable |
|-------------------|---------|-----------------|------------|
| `bdispei` → `bdicheq` | 67 | API interna / evento | [SME-PENDING] |
| `bdispei` → `bdimnsj` | 24 | API interna / evento | [SME-PENDING] |
| `bdispei` → `bdicred` | 9 | API interna / evento | [SME-PENDING] |
| `bdispei` → `bdinteg` | 9 | API interna / evento | [SME-PENDING] |
| `bdispei` → `bditef` | 8 | API interna / evento | [SME-PENDING] |

## Servicios AWS seleccionados

| Componente | Servicio AWS | Justificación |
|-----------|-------------|--------------|
| Cómputo | ECS Fargate (JVM) + Lambda | Apropiado para tipo payments |
| Base de datos | Aurora PostgreSQL Multi-AZ | Reemplaza instancia Informix bdispei |
| Eventos/mensajes | EventBridge Pipes | Reemplaza cross-DB calls asincrónicos |
| Colas + DLQ | SQS FIFO | Retry pattern para operaciones fallidas |
| Feature flags | AWS AppConfig | Reemplaza tabla `mnsj_param` / tablas de config |
| Cifrado PII | AWS KMS (CMK) | LFPDPPP + CNBV — datos personales y financieros |
| Observabilidad | CloudWatch + X-Ray | Métricas, logs estructurados, distributed tracing |
| Auditoría | AWS CloudTrail | Audit trail para CNBV (retención 5 años) |

## Pre-requisitos para iniciar BUILD

El dominio `SPEI` no puede entrar a BUILD hasta que estén disponibles:
- **Dominios upstream:** Mensajería
- **ACL diseñada y aprobada** por Core Banking Transformation
- **API contracts** de `16-api-contract.md` aprobados por Domain Expert BanCoppel
- **Golden master** capturado (ver `10-test-strategy.md`)
- **Schema real** completado por DBA IBM Informix (ver `12-er-model.md` Etapa 2)

## Regulación aplicable en AWS

| Regulación | Impacto en arquitectura |
|-----------|------------------------|
| Banxico | [SME-PENDING — Cybersecurity + Industry Banking] |
| CNBV | [SME-PENDING — Cybersecurity + Industry Banking] |
| PCI-DSS | [SME-PENDING — Cybersecurity + Industry Banking] |


---
*Generado por: Cloud Architect — AWS Banking · 2026-07-03 · [SME-PENDING] requiere validación de Core Banking Transformation*
