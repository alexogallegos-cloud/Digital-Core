# D06 · Solicitudes — Arquitectura Target

> **Componente:** Informix · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdisolic` · Target: **AWS Aurora PostgreSQL**
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

**Patrón:** Workflow engine para solicitudes multi-paso

El dominio `bdisolic` es de tipo **workflow**. Su migración sigue este patrón porque Solicitudes de productos financieros. 549 SPs.

## Topología AWS target

```
┌────────────────────────────────────────────────────────────┐
│  D06 · Solicitudes — AWS Target                 │
│                                                             │
│  [ACL — API Gateway]                                        │
│       │  REST / gRPC / AsyncAPI                             │
│       ▼                                                     │
│  [Step Functions + Lambda]                                         │
│       │                                                     │
│  ┌────┴────────────────────────────┐                        │
│  ▼                                 ▼                        │
│  [Aurora PostgreSQL]              [EventBridge]               │
│  (migrado de bdisolic)          (reemplaza cross-DB calls)      │
│       │                                                     │
│  [SQS]     [CloudWatch + X-Ray]                  │
│  (DLQ + reintentos)   (observabilidad)                      │
└────────────────────────────────────────────────────────────┘
```

## SPs públicos → endpoints API candidatos

Estos SPs tienen el mayor fan-in — son los puntos de entrada del dominio que se convierten en API:

| SP (Informix) | Fan-in | Endpoint target |
|--------------|--------|----------------|
| `sp_asigna_solicitud_soc` | 236 callers | REST endpoint / evento |
| `determina_lincred_tc_cjunk` | 208 callers | REST endpoint / evento |
| `sp_obtienegrupo` | 174 callers | REST endpoint / evento |
| `sp_consultarfacturacionos2` | 168 callers | REST endpoint / evento |
| `califica_scoring2_cjunk` | 167 callers | REST endpoint / evento |

> **[SME-PENDING — Core Banking Transformation]** Para cada SP: definir si es síncrono (REST/gRPC) o asíncrono (evento). El criterio: ¿el caller necesita la respuesta en el mismo request? Sí → REST. No → EventBridge/SNS.

## Anti-Corruption Layer (ACL) — contratos a diseñar

Para cada dependencia cross-DB, el ACL traduce `CALL db:sp()` a una llamada API:

| Dependencia actual | Volumen | Tipo de contrato | Responsable |
|-------------------|---------|-----------------|------------|
| `bdisolic` → `bdicred` | 89 | API interna / evento | [SME-PENDING] |
| `bdisolic` → `bdinteg` | 81 | API interna / evento | [SME-PENDING] |
| `bdisolic` → `bdimnsj` | 23 | API interna / evento | [SME-PENDING] |
| `bdisolic` → `bdiburo` | 16 | API interna / evento | [SME-PENDING] |
| `bdisolic` → `bdiprospectos` | 15 | API interna / evento | [SME-PENDING] |

## Servicios AWS seleccionados

| Componente | Servicio AWS | Justificación |
|-----------|-------------|--------------|
| Cómputo | Step Functions + Lambda | Apropiado para tipo workflow |
| Base de datos | Aurora PostgreSQL | Reemplaza instancia Informix bdisolic |
| Eventos/mensajes | EventBridge | Reemplaza cross-DB calls asincrónicos |
| Colas + DLQ | SQS | Retry pattern para operaciones fallidas |
| Feature flags | AWS AppConfig | Reemplaza tabla `mnsj_param` / tablas de config |
| Cifrado PII | AWS KMS (CMK) | LFPDPPP + CNBV — datos personales y financieros |
| Observabilidad | CloudWatch + X-Ray | Métricas, logs estructurados, distributed tracing |
| Auditoría | AWS CloudTrail | Audit trail para CNBV (retención 5 años) |

## Pre-requisitos para iniciar BUILD

El dominio `Solicitudes` no puede entrar a BUILD hasta que estén disponibles:
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


---
*Generado por: Cloud Architect — AWS Banking · 2026-07-03 · [SME-PENDING] requiere validación de Core Banking Transformation*
