# D07 · Aclaraciones — Arquitectura Target

> **Componente:** BCOPCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdiaclaracion` · Target: **AWS Aurora PostgreSQL**
> **Wave:** Wave 2 · Riesgo: **ALTO**
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

**Patrón:** Audit-first — todo con CloudTrail + registro inmutable

El dominio `bdiaclaracion` es de tipo **regulatory**. Su migración sigue este patrón porque Disputas y reclamaciones. 232 SPs. Regulatorio CNBV.

## Topología AWS target

```
┌────────────────────────────────────────────────────────────┐
│  D07 · Aclaraciones — AWS Target                 │
│                                                             │
│  [ACL — API Gateway]                                        │
│       │  REST / gRPC / AsyncAPI                             │
│       ▼                                                     │
│  [Lambda + Step Functions]                                         │
│       │                                                     │
│  ┌────┴────────────────────────────┐                        │
│  ▼                                 ▼                        │
│  [Aurora PostgreSQL]              [EventBridge]               │
│  (migrado de bdiaclaracion)          (reemplaza cross-DB calls)      │
│       │                                                     │
│  [SQS FIFO]     [CloudWatch + X-Ray]                  │
│  (DLQ + reintentos)   (observabilidad)                      │
└────────────────────────────────────────────────────────────┘
```

## SPs públicos → endpoints API candidatos

Estos SPs tienen el mayor fan-in — son los puntos de entrada del dominio que se convierten en API:

| SP (Informix) | Fan-in | Endpoint target |
|--------------|--------|----------------|
| `sp_fal_cancelacion_cuenta_credito` | 40 callers | REST endpoint / evento |
| `sp_fal_cancelacion_cuenta_debito` | 40 callers | REST endpoint / evento |
| `sp_fal_liquidacion_asignar_analista` | 34 callers | REST endpoint / evento |
| `sp_fal_obtener_saldo_debito` | 33 callers | REST endpoint / evento |
| `sp_fal_asignar_analista_credito` | 21 callers | REST endpoint / evento |

> **[SME-PENDING — Core Banking Transformation]** Para cada SP: definir si es síncrono (REST/gRPC) o asíncrono (evento). El criterio: ¿el caller necesita la respuesta en el mismo request? Sí → REST. No → EventBridge/SNS.

## Anti-Corruption Layer (ACL) — contratos a diseñar

Para cada dependencia cross-DB, el ACL traduce `CALL db:sp()` a una llamada API:

| Dependencia actual | Volumen | Tipo de contrato | Responsable |
|-------------------|---------|-----------------|------------|
| `bdiaclaracion` → `bdinteg` | 452 | API interna / evento | [SME-PENDING] |
| `bdiaclaracion` → `bdicheq` | 153 | API interna / evento | [SME-PENDING] |
| `bdiaclaracion` → `bdicred` | 139 | API interna / evento | [SME-PENDING] |
| `bdiaclaracion` → `bdidomi` | 40 | API interna / evento | [SME-PENDING] |
| `bdiaclaracion` → `bdimnsj` | 34 | API interna / evento | [SME-PENDING] |

## Servicios AWS seleccionados

| Componente | Servicio AWS | Justificación |
|-----------|-------------|--------------|
| Cómputo | Lambda + Step Functions | Apropiado para tipo regulatory |
| Base de datos | Aurora PostgreSQL | Reemplaza instancia Informix bdiaclaracion |
| Eventos/mensajes | EventBridge | Reemplaza cross-DB calls asincrónicos |
| Colas + DLQ | SQS FIFO | Retry pattern para operaciones fallidas |
| Feature flags | AWS AppConfig | Reemplaza tabla `mnsj_param` / tablas de config |
| Cifrado PII | AWS KMS (CMK) | LFPDPPP + CNBV — datos personales y financieros |
| Observabilidad | CloudWatch + X-Ray | Métricas, logs estructurados, distributed tracing |
| Auditoría | AWS CloudTrail | Audit trail para CNBV (retención 5 años) |

## Pre-requisitos para iniciar BUILD

El dominio `Aclaraciones` no puede entrar a BUILD hasta que estén disponibles:
- **Dominios upstream:** Mensajería
- **ACL diseñada y aprobada** por Core Banking Transformation
- **API contracts** de `16-api-contract.md` aprobados por Domain Expert BanCoppel
- **Golden master** capturado (ver `10-test-strategy.md`)
- **Schema real** completado por DBA IBM Informix (ver `12-er-model.md` Etapa 2)

## Regulación aplicable en AWS

| Regulación | Impacto en arquitectura |
|-----------|------------------------|
| CNBV | [SME-PENDING — Cybersecurity + Industry Banking] |
| CONDUSEF | [SME-PENDING — Cybersecurity + Industry Banking] |
| LFPDPPP | [SME-PENDING — Cybersecurity + Industry Banking] |


---
*Generado por: Cloud Architect — AWS Banking · 2026-07-03 · [SME-PENDING] requiere validación de Core Banking Transformation*
