# ADRs — Portal Empresas Nómina · Scotiabank México
> Architectural Decision Records · SPE-ANCE-001

## Convención de Nombre
`ADR-ANCE-{NNN}-{titulo-kebab}.md`

## ADRs Pendientes (bloqueantes primero)

| ADR | Título | Estado | Owner |
|-----|--------|--------|-------|
| `ADR-ANCE-001` | Estrategia integración con core bancario Scotiabank México | `[BLOCKER · PENDIENTE]` | dt-solution-architect |
| `ADR-ANCE-002` | API contract standards (OpenAPI 3.1 · versioning) | `[EN PROGRESO · seed en api/openapi-nomina-portal.yaml]` | dt-solution-architect |
| `ADR-ANCE-003` | Modelo de datos SQL Server (multi-tenant strategy) | `[PENDIENTE]` | dt-dba |
| `ADR-ANCE-004` | Identidad y accesos: IAM propio para el mock · SSO federado en prod | `[ACCEPTED · mock]` → prod `[PENDIENTE · DATO-REQUERIDO]` | dt-security-engineer |
| `ADR-ANCE-005` | Integración SPEI (gateway Scotiabank México) | `[PENDIENTE · DATO-REQUERIDO]` | dt-solution-architect |
| `ADR-ANCE-006` | Plataforma Kubernetes target (AKS vs. on-prem) | `[PENDIENTE · DATO-REQUERIDO]` | dt-devops-engineer |
| `ADR-ANCE-007` | Integración al Portal Empresa existente (micro-frontend · iframe · link + SSO federado) | mock: `[RESUELTO · standalone c/auth propia]` · prod: `[PENDIENTE · DATO-REQUERIDO]` | dt-solution-architect |

## Plantilla

```markdown
# ADR-ANCE-{NNN}: {Título}
Fecha: {YYYY-MM-DD}
Estado: [PROPOSED | ACCEPTED | DEPRECATED | SUPERSEDED by ADR-ANCE-{NNN}]
Owner: {dt-role}
SME consultado: {SME si aplica}

## Contexto
{Por qué esta decisión existe. Cuál es el problema a resolver.}

## Opciones evaluadas
1. **{Opción A}**
   - Ventajas: ...
   - Desventajas: ...
2. **{Opción B}**
   - Ventajas: ...
   - Desventajas: ...

## Decisión
Elegimos **{Opción X}** porque {razón técnica principal}.

## Consecuencias
- **Positivas**: ...
- **Negativas / trade-offs**: ...
- **Componentes afectados**: {SPE-ANCE-NNN, ...}
```
