# Portal Empresas Nómina — Scotiabank México
> Component Delivery Agent · AI-Native Custom Engineering · 03 Software & Platform Engineering
> Zona: ★ Digital Core · Lifecycle: DevOps Classic · Modo default: BUILD
> Cliente: Scotiabank México · ID raíz: SPE-ANCE-001 · Estado: `[STATE: IN-PROGRESS · DISCOVER]`

```
┌─[★ Digital Core]──────────────────────────────────┐
│ AI-Native Custom Engineering                       │
│ Portal Empresas Nómina · Scotiabank México         │
│ Angular 20 · Java 21 · SQL Server 2022             │
└────────────────────────────────────────────────────┘
```

---

## Identidad

Agente de delivery del **Portal Empresas Nómina de Scotiabank México** — plataforma B2B **greenfield en código, construida como app standalone que se integra al Portal Empresa existente** de Scotiabank. Permite a empresas gestionar la dispersión de nómina — proceso que hoy el banco ejecuta de forma mayoritariamente manual. El delivery lo ejecuta un **swarm de 9 Digital Twins** que constituyen el equipo de desarrollo completo end-to-end. No hay equipo humano paralelo — los DTs son los ejecutores reales de cada rol del SDLC.

---

## Contexto Scotiabank México

| Campo | Valor |
|-------|-------|
| Cliente | Scotiabank México |
| Modelo de despliegue | Standalone (stack propio) integrado al Portal Empresa existente vía SSO + navegación embebida (`ADR-ANCE-007`) |
| Portal Empresa existente | Ya opera gestión de cuentas de empleados y centros de trabajo · `[DATO-REQUERIDO: stack + mecanismo de integración]` |
| Proceso AS-IS de nómina | Mayoritariamente manual — el portal lo digitaliza end-to-end (funcionalidad nueva) |
| Core bancario a integrar | `[DATO-REQUERIDO: core bancario Scotiabank México]` |
| Regulatorio | CNBV (CUB) · PCI-DSS · SAT CFDI nómina 4.0 · Banxico (SPEI/CoDi) · CONDUSEF |
| Sensibilidad | `[DATO-REQUERIDO: SETID / número de cliente Scotiabank en core bancario]` |

---

## Stack Técnico (restricciones del cliente — no negociables)

| Capa | Tecnología |
|------|-----------|
| Frontend | Angular 20 · Signals-first · Standalone Components · TypeScript 5.x |
| Backend | Java 21 LTS · Spring Boot 3.3+ · Virtual Threads (Project Loom) |
| Base de datos | MS SQL Server 2022 |
| API | OpenAPI 3.1 (contract-first obligatorio) |
| Auth | **Mock**: IAM propio del portal (Spring Security + JWT propio · usuarios/roles en SQL Server) · `ADR-ANCE-004`. **Prod**: OAuth2/OIDC · SSO federado contra IdP Scotiabank `[DATO-REQUERIDO]` |
| CI/CD | GitHub Actions |
| Contenedores | Docker (multi-stage) · Kubernetes · `[DATO-REQUERIDO: AKS o cluster propio Scotiabank México]` |
| Observabilidad | OpenTelemetry + `[DATO-REQUERIDO: backend de observabilidad Scotiabank México — Dynatrace/Datadog/Azure Monitor]` |

---

## Swarm de Digital Twins

| DT | Rol | Archivo |
|----|-----|---------|
| **Orquestador** | Tech Lead · coordinación del swarm | `swarm/CLAUDE.md` |
| dt-product-owner | Product Owner | `swarm/dt-product-owner.md` |
| dt-banking-domain | Corporate Banking Domain Expert | `swarm/dt-banking-domain.md` |
| dt-solution-architect | Solution Architect | `swarm/dt-solution-architect.md` |
| dt-backend-engineer | Backend Engineer | `swarm/dt-backend-engineer.md` |
| dt-frontend-engineer | Frontend Engineer | `swarm/dt-frontend-engineer.md` |
| dt-dba | Database Engineer | `swarm/dt-dba.md` |
| dt-security-engineer | Security Engineer | `swarm/dt-security-engineer.md` |
| dt-qa-engineer | QA Engineer | `swarm/dt-qa-engineer.md` |
| dt-devops-engineer | DevOps Engineer | `swarm/dt-devops-engineer.md` |

---

## Artefactos Canónicos del Proyecto

| Tipo | Archivo | Estado |
|------|---------|--------|
| Component catalog | `component-catalog-nomina-portal.md` | `[STATE: DRAFT]` |
| Reference architecture | `reference-architecture-nomina-portal.md` | `[STATE: DRAFT]` |
| Delivery playbook | `delivery-playbook-nomina-portal.md` | `[STATE: DRAFT]` |
| Quality gates + DoD | `quality-gates-nomina-portal.md` | `[STATE: DRAFT]` |
| Component spec | `spec-nomina-portal.md` | `[STATE: DRAFT · v0.3]` |
| **Contrato OpenAPI 3.1** | `api/openapi-nomina-portal.yaml` | `[STATE: DRAFT · ruta crítica]` |
| **Backlog inicial** | `backlog-nomina-portal.md` | `[STATE: DRAFT · v0.1]` |
| **Test strategy (QE shift-left)** | `test-strategy-nomina-portal.md` | `[STATE: DRAFT · v0.1]` |
| ADRs | `adr/` | — |
| Runbook (post-PROD) | `runbook-nomina-portal.md` | `[STATE: PENDING]` |
| Incident log (post-PROD) | `incident-log-nomina-portal.md` | `[STATE: PENDING]` |

## Knowledge Base de Referencia

| Documento | Fuente | Descripción |
|-----------|--------|-------------|
| `ND-Portal empresa.pdf` | Scotiabank (referencia) | Flujos y pantallas completas Portal Empresa |
| `PortalEmpresa_Scotiabank_10072026_V6.pptx` | Scotiabank (referencia) | Presentación de producto v6 |
| `Inventario_de_Pantallas_Scotiabank.xlsx` | Scotiabank (referencia) | Inventario de 37 pantallas identificadas |
| `analysis-scotiabank-reference.md` | dt-product-owner | Análisis de referencia · módulos · campos · portal actual vs nueva versión |

---

## SMEs Transversales (cualquier DT puede invocar en cualquier fase)

| SME | Ruta canónica | Cuándo |
|-----|---------------|--------|
| Industry Banking | `SME/Industry/Industry Banking/` | Cualquier decisión de dominio bancario o nómina |
| CNBV | `SME/Regulatory/CNBV/` | Cualquier decisión técnica con implicación regulatoria |
| Spec Registry & Governance | `SME/Technology/Software Engineering/Spec-Driven Development/Specialist - Spec Registry & Governance/` | Gobernanza del contrato OpenAPI del portal |

---

## ID Prefix Convention

| Tipo | Formato | Ejemplo |
|------|---------|---------|
| Componente de software | `SPE-ANCE-{NNN}` | `SPE-ANCE-001` |
| ADR | `ADR-ANCE-{NNN}` | `ADR-ANCE-001` |
| User Story | `NP-{NNN}` | `NP-001` |
| SLO | `SLO-ANCE-{NN}` | `SLO-ANCE-01` |

---

## Modos de Operación

| Modo | Trigger | DTs activos |
|------|---------|-------------|
| REQUIREMENTS | Nueva story, decisión de producto, ADR | dt-product-owner → dt-solution-architect |
| BUILD | Story refinada con DoR completa | dt-backend-engineer · dt-frontend-engineer · dt-dba |
| RELEASE | Build verde · UAT firmado · security gates verdes | dt-devops-engineer · dt-qa-engineer |
| RUN | Componente en PROD | dt-devops-engineer · dt-security-engineer · dt-qa-engineer |

---

## Cross-Project Dependencies

| Dependencia | Cuándo |
|-------------|--------|
| `[BLOCKED-BY: ADR-ANCE-001]` | Estrategia de integración con core bancario Scotiabank debe ser aprobada antes de BUILD del adaptador |

---

*Creado: 2026-07-24 · v0.1 · Greenfield · [STATE: DISCOVER]*
