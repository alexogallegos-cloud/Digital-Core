# Component Catalog — Portal Empresas Nómina · Scotiabank México
> Catálogo vivo · SPE-ANCE-001 · Última actualización: 2026-07-24

---

## Componentes del Portal

| ID | Nombre | Tipo | Tecnología | Owner DT | Estado |
|----|--------|------|-----------|----------|--------|
| `SPE-ANCE-001` | Portal Frontend | SPA | Angular 20 · TypeScript | dt-frontend-engineer | `DISCOVER` |
| `SPE-ANCE-002` | Nómina API | Microservicio REST | Java 21 · Spring Boot 3.3 | dt-backend-engineer | `DISCOVER` |
| `SPE-ANCE-003` | Core Banking Adapter | Microservicio adaptador | Java 21 · Spring Boot 3.3 | dt-backend-engineer | `DISCOVER` |
| `SPE-ANCE-004` | Auth Gateway | Auth proxy | OAuth2/OIDC · `[TBD]` | dt-security-engineer | `DISCOVER` |
| `SPE-ANCE-005` | Nómina DB | Base de datos | MS SQL Server 2022 | dt-dba | `DISCOVER` |
| `SPE-ANCE-006` | SPEI Adapter | Microservicio adaptador | Java 21 · Spring Boot 3.3 | dt-backend-engineer | `DISCOVER` |

---

## Descripción por Componente

### SPE-ANCE-001 · Portal Frontend
SPA Angular 20 Signals-first. UI para empresas: alta, gestión de nóminas, instrucción de dispersión, consulta de movimientos, descarga de CFDI. Consume `SPE-ANCE-002` vía OpenAPI 3.1. Auth delegado a `SPE-ANCE-004`.

### SPE-ANCE-002 · Nómina API
Backend principal. Orquesta los flujos de negocio: onboarding de empresa, carga de layouts, validación CNBV/SAT, instrucción de dispersión, consulta de movimientos. Persiste en `SPE-ANCE-005`. Delega a `SPE-ANCE-003` para operaciones del core bancario y a `SPE-ANCE-006` para instrucciones SPEI.

### SPE-ANCE-003 · Core Banking Adapter
Anti-corruption layer entre el portal y el `[DATO-REQUERIDO: core bancario Scotiabank México]`. Abstrae la complejidad del sistema origen. Patrón de integración `[DATO-REQUERIDO: pendiente ADR-ANCE-001]`. Consume `[DATO-REQUERIDO: capacidades del core bancario relevantes para nómina]`.

### SPE-ANCE-004 · Auth Gateway
Gestión de identidad y sesiones para empresas. Integración con IdP de Scotiabank México `[DATO-REQUERIDO]`. Emite JWT para consumo de `SPE-ANCE-002`. Manejo de roles: Administrador empresa · Operador nómina · Auditor.

### SPE-ANCE-005 · Nómina DB
Esquema SQL Server 2022. Entidades: Empresa · Empleado · Nómina · Layout · Dispersión · Movimiento · CFDI. El diseño de esquema sigue `[DEPENDS-ON: ADR-ANCE-003]` — modelo de datos pendiente.

### SPE-ANCE-006 · SPEI Adapter
Integración con gateway SPEI de Scotiabank México `[DATO-REQUERIDO]`. Envía instrucciones de dispersión masiva, recibe confirmaciones, maneja reintentos y notificaciones. Circulares Banxico vigentes aplicables.

---

## Dependencias entre Componentes

```
[Browser]
    ↓ HTTPS
[SPE-ANCE-001 · Angular Frontend]
    ↓ OpenAPI 3.1 / JWT
[SPE-ANCE-004 · Auth Gateway] ←→ [IdP Scotiabank México]
    ↓
[SPE-ANCE-002 · Nómina API]
    ├─→ [SPE-ANCE-005 · SQL Server 2022]
    ├─→ [SPE-ANCE-003 · Core Banking Adapter] → [[DATO-REQUERIDO: Core bancario Scotiabank México]]
    └─→ [SPE-ANCE-006 · SPEI Adapter] → [Gateway SPEI Scotiabank México]
                                              ↓
                                         [Banxico SPEI]
```

---

## Registro de ADRs por Componente

| ADR | Componente afectado | Decisión | Estado |
|-----|---------------------|---------|--------|
| `ADR-ANCE-001` | SPE-ANCE-003 | Estrategia integración core bancario Scotiabank | `[PENDING]` |
| `ADR-ANCE-002` | SPE-ANCE-002 | API contract standards (OpenAPI 3.1) | `[PENDING]` |
| `ADR-ANCE-003` | SPE-ANCE-005 | Modelo de datos nómina en SQL Server | `[PENDING]` |
| `ADR-ANCE-004` | SPE-ANCE-004 | IdP y estrategia OAuth2/OIDC | `[PENDING]` |
| `ADR-ANCE-005` | SPE-ANCE-006 | Estrategia integración SPEI | `[PENDING]` |

---

*Creado: 2026-07-24 · v0.1 · [STATE: DRAFT · DISCOVER]*
