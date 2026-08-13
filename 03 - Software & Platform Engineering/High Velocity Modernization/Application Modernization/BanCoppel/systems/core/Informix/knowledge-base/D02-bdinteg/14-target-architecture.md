# D02 · Integración y Autenticación — Arquitectura Target

> **Componente:** Informix · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdinteg` · Target: **AWS Aurora PostgreSQL**
> **Wave:** Wave 5 · Riesgo: **CRÍTICO**
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

**Patrón:** AuthService centralizado — todos los dominios dependen de él

El dominio `bdinteg` es de tipo **auth**. Su migración sigue este patrón porque Backbone de autenticación. sp_cnsif_confirmaejecutivo (2,400 callers). 2,034 SPs.

## Topología AWS target

```
┌────────────────────────────────────────────────────────────┐
│  D02 · Integración y Autenticación — AWS Target                 │
│                                                             │
│  [ACL — API Gateway]                                        │
│       │  REST / gRPC / AsyncAPI                             │
│       ▼                                                     │
│  [Lambda + Cognito]                                         │
│       │                                                     │
│  ┌────┴────────────────────────────┐                        │
│  ▼                                 ▼                        │
│  [Aurora PostgreSQL + ElastiCache (Redis)]              [EventBridge]               │
│  (migrado de bdinteg)          (reemplaza cross-DB calls)      │
│       │                                                     │
│  [SQS]     [CloudWatch + X-Ray]                  │
│  (DLQ + reintentos)   (observabilidad)                      │
└────────────────────────────────────────────────────────────┘
```

## SPs públicos → endpoints API candidatos

Estos SPs tienen el mayor fan-in — son los puntos de entrada del dominio que se convierten en API:

| SP (Informix) | Fan-in | Endpoint target |
|--------------|--------|----------------|
| `sp_cnsif_confirmaejecutivo` | 2,400 callers | REST endpoint / evento |
| `sp_cnsif_permisosejecutivo` | 621 callers | REST endpoint / evento |
| `sp_valida_perfil_usuario` | 388 callers | REST endpoint / evento |
| `sp_desc_ret` | 358 callers | REST endpoint / evento |
| `sp_cuentadoctos_soc` | 354 callers | REST endpoint / evento |

> **[SME-PENDING — Core Banking Transformation]** Para cada SP: definir si es síncrono (REST/gRPC) o asíncrono (evento). El criterio: ¿el caller necesita la respuesta en el mismo request? Sí → REST. No → EventBridge/SNS.

## Anti-Corruption Layer (ACL) — contratos a diseñar

Para cada dependencia cross-DB, el ACL traduce `CALL db:sp()` a una llamada API:

| Dependencia actual | Volumen | Tipo de contrato | Responsable |
|-------------------|---------|-----------------|------------|
| `bdinteg` → `bdicheq` | 194 | API interna / evento | [SME-PENDING] |
| `bdinteg` → `bdicred` | 165 | API interna / evento | [SME-PENDING] |
| `bdinteg` → `bdimnsj` | 79 | API interna / evento | [SME-PENDING] |
| `bdinteg` → `bdisolic` | 51 | API interna / evento | [SME-PENDING] |
| `bdinteg` → `bdisitesp` | 40 | API interna / evento | [SME-PENDING] |

## Servicios AWS seleccionados

| Componente | Servicio AWS | Justificación |
|-----------|-------------|--------------|
| Cómputo | Lambda + Cognito | Apropiado para tipo auth |
| Base de datos | Aurora PostgreSQL + ElastiCache (Redis) | Reemplaza instancia Informix bdinteg |
| Eventos/mensajes | EventBridge | Reemplaza cross-DB calls asincrónicos |
| Colas + DLQ | SQS | Retry pattern para operaciones fallidas |
| Feature flags | AWS AppConfig | Reemplaza tabla `mnsj_param` / tablas de config |
| Cifrado PII | AWS KMS (CMK) | LFPDPPP + CNBV — datos personales y financieros |
| Observabilidad | CloudWatch + X-Ray | Métricas, logs estructurados, distributed tracing |
| Auditoría | AWS CloudTrail | Audit trail para CNBV (retención 5 años) |

## Pre-requisitos para iniciar BUILD

El dominio `Integración y Autenticación` no puede entrar a BUILD hasta que estén disponibles:
- **Dominios upstream:** Cheques / Cuentas, Créditos, Mensajería, Solicitudes
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
