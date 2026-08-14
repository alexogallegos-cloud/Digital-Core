# Reference Architecture — Portal Empresas Nómina · Scotiabank México
> SPE-ANCE-001 · Última actualización: 2026-07-24 · [STATE: DRAFT]

---

## Diagrama de Arquitectura

```
┌──────────────────────────────────────────────────────────────────────┐
│  ZONA PÚBLICA                                                         │
│                                                                       │
│   [Empresa · Browser]                                                 │
│         │ HTTPS / TLS 1.3                                             │
│         ↓                                                             │
│   [CDN / WAF] ──────────────────────────────────────────────────     │
│         │                                                             │
│         ↓                                                             │
│   [SPE-ANCE-001 · Portal Frontend · Angular 20]                       │
│         │ OpenAPI 3.1 / JWT Bearer                                    │
└─────────┼────────────────────────────────────────────────────────────┘
          │
┌─────────┼────────────────────────────────────────────────────────────┐
│  ZONA API                                                             │
│         ↓                                                             │
│   [API Gateway / Load Balancer]                                       │
│         │                                                             │
│         ├──→ [SPE-ANCE-004 · Auth Gateway · OAuth2/OIDC]             │
│         │         └──→ [IdP Scotiabank México TBD]                   │
│         │                                                             │
│         └──→ [SPE-ANCE-002 · Nómina API · Java 21 · Spring Boot 3.3] │
│                   │ JPA/Hibernate                                     │
│                   ├──→ [SPE-ANCE-005 · SQL Server 2022]              │
│                   │                                                   │
│                   │ HTTP/gRPC/MQ (TBD · ADR-ANCE-001)                │
│                   ├──→ [SPE-ANCE-003 · Core Banking Adapter · Java 21]│
│                   │                                                   │
│                   │ HTTP/MQ (TBD · ADR-ANCE-005)                     │
│                   └──→ [SPE-ANCE-006 · SPEI Adapter · Java 21]       │
└──────────────────────────────────────────────────────────────────────┘
          │                              │
┌─────────┼──────────────────────────────┐   ┌───────────┼──────────────────────────┐
│  CORE BANCARIO                        │   │  PAGOS BANXICO                      │
│  [DATO-REQUERIDO:                     │   │  [Gateway SPEI Scotiabank México TBD]│
│   core bancario Scotiabank México]    │   │       └──→ [Banxico SPEI / CoDi]    │
└───────────────────────────────────────┘   └─────────────────────────────────────┘
```

---

## Principios Arquitectónicos

| Principio | Aplicación en este proyecto |
|-----------|----------------------------|
| **API-First / Contract-First** | OpenAPI 3.1 escrito antes del primer endpoint. Mock server desde contrato (`SPE-ANCE-002`). |
| **Standalone + integración al Portal Empresa existente** | El Portal Nómina es una app standalone (código y despliegue propios) que se integra al Portal Empresa existente de Scotiabank vía SSO federado y embebido de navegación (mecanismo exacto en `ADR-ANCE-007`). Autonomía de delivery sin acoplar el ciclo de release al portal existente. |
| **Anti-Corruption Layer hacia el core bancario** | El portal es una capacidad nueva sobre el core bancario — no reemplaza ningún sistema existente. Consume el core vía `SPE-ANCE-003`, que aísla el modelo del portal del modelo del core. |
| **Defense in Depth** | WAF → API Gateway → Auth Gateway → Backend. Cada capa valida independientemente. |
| **Twelve-Factor App** | Todos los microservicios (ANCE-002, 003, 006) siguen 12-factor. Config via env vars, no hardcode. |
| **Virtual Threads by default** | Java 21 Virtual Threads en todos los servicios para I/O-bound operations (Core Banking Adapter, SPEI Adapter). |
| **Signals-first Angular** | Ningún componente Angular usa `BehaviorSubject` o `Observable` donde un Signal resuelve el caso. |

---

## ADRs Canónicos

| ADR | Decisión | Owner | Estado |
|-----|---------|-------|--------|
| `ADR-ANCE-001` | Estrategia integración con core bancario Scotiabank: REST vs. MQ vs. Java adapter directo | dt-solution-architect + SME Core Banking + SME Interoperability | `[PENDING · BLOCKER]` |
| `ADR-ANCE-002` | API contract standards: OpenAPI 3.1 contract-first · versionado URI `/v1/` | dt-solution-architect | `[PENDING]` |
| `ADR-ANCE-003` | Modelo de datos nómina en SQL Server 2022: esquema multi-tenant vs. schema-per-empresa | dt-dba + dt-solution-architect | `[PENDING]` |
| `ADR-ANCE-004` | Estrategia OAuth2/OIDC: Azure AD B2C vs. IdP interno Scotiabank México vs. Keycloak | dt-security-engineer + Scotiabank México | `[PENDING · DATO-REQUERIDO]` |
| `ADR-ANCE-005` | Integración SPEI: gateway directo Banxico vs. microservicio interno Scotiabank México | dt-solution-architect + SME SPEI + Scotiabank México | `[PENDING · DATO-REQUERIDO]` |
| `ADR-ANCE-006` | Estrategia de despliegue: AKS vs. cluster on-prem Scotiabank México | dt-devops-engineer + Scotiabank México | `[PENDING · DATO-REQUERIDO]` |

---

## Stack por Capa

| Capa | Tecnología canónica | Decisión |
|------|---------------------|---------|
| Frontend | Angular 20 · TypeScript 5.x · Angular Material | Restricción Scotiabank México |
| Backend services | Java 21 · Spring Boot 3.3 · Spring Security | Restricción Scotiabank México |
| Base de datos | MS SQL Server 2022 · JPA/Hibernate | Restricción Scotiabank México |
| API contracts | OpenAPI 3.1 | ADR-ANCE-002 |
| Auth | OAuth2/OIDC · JWT | ADR-ANCE-004 (TBD) |
| Contenedores | Docker multi-stage · distroless base | DoD-SPE-01 |
| Orquestación | Kubernetes | ADR-ANCE-006 (TBD) |
| Observabilidad | OpenTelemetry + backend TBD | `[DATO-REQUERIDO]` |
| CI/CD | GitHub Actions | Restricción Scotiabank México |

---

## Patrones de Integración Core Bancario (pendiente ADR-ANCE-001)

### Opción A — REST API
El core bancario expone APIs REST que `SPE-ANCE-003` consume directamente. Requiere confirmar disponibilidad de APIs en Scotiabank México.

### Opción B — MQ Adapter
`SPE-ANCE-003` pone mensajes en MQ → core bancario los consume. Asíncrono, mayor latencia, menor acoplamiento.

### Opción C — Java Adapter directo
Conexión directa desde `SPE-ANCE-003` al tier de aplicación del core bancario. Mayor riesgo, requiere SME Core Banking Scotiabank.

**Decisión: `[DATO-REQUERIDO]` — confirmar con equipo Scotiabank México qué interfaces expone el core bancario.**

---

## Observabilidad Target

| Señal | Herramienta | SLO |
|-------|------------|-----|
| Logs estructurados | OpenTelemetry → backend TBD | — |
| Métricas RED (Rate · Errors · Duration) | Micrometer → backend TBD | SLO-ANCE-01/02/03 |
| Tracing distribuido | OpenTelemetry · W3C TraceContext | — |
| Alertas P1/P2 | `[DATO-REQUERIDO: paging tool Scotiabank México]` | MTTR < 1h |

---

*Creado: 2026-07-24 · v0.1 · [STATE: DRAFT · DISCOVER]*
