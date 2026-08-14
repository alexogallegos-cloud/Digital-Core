# Delivery Playbook — Portal Empresas Nómina · Scotiabank México
> SPE-ANCE-001 · DevOps Classic variant · Última actualización: 2026-07-24

---

## Lifecycle Activo

| Fase canónica | Nombre en este proyecto | Estado | Owner DT |
|---------------|------------------------|--------|----------|
| DISCOVER | Story Refinement + API Contract + ADRs + **casos de prueba tempranos** | `[IN-PROGRESS]` | dt-product-owner · dt-solution-architect · dt-qa-engineer |
| DESIGN | Solution Design + ADRs + DB Schema + **test design** | `[PENDING]` | dt-solution-architect · dt-dba · dt-qa-engineer |
| BUILD | Code + Unit Tests + CI verde | `[PENDING]` | dt-backend-engineer · dt-frontend-engineer · dt-dba |
| TEST | Integration · E2E · Security · Performance · UAT | `[PENDING]` | dt-qa-engineer |
| RELEASE | Deploy canary via CI/CD | `[PENDING]` | dt-devops-engineer |
| OPERATE | Producción activa con SLOs | `[PENDING]` | dt-devops-engineer |
| OBSERVE | Telemetría + DORA | `[PENDING]` | dt-devops-engineer · dt-qa-engineer |
| ITERATE | Refactor · Feature evolution | `[PENDING]` | swarm completo |

---

## Protocolo de Operación del Swarm

### Flujo de una User Story (modo normal)

```
[dt-product-owner]
  │ Crea NP-{NNN}: story + criterios de aceptación + DoR check
  ↓
[dt-qa-engineer]  ← SHIFT-LEFT · identificación temprana de casos de prueba
  │ Deriva casos de prueba de los criterios de aceptación + spec + contrato OpenAPI
  │ ANTES de BUILD. Detecta ambigüedades y criterios no testeables → feedback al PO.
  ↓
[Orquestador]
  │ Valida DoR (incl. casos de prueba identificados) · asigna DTs · declara dependencias
  ↓
[dt-solution-architect]
  │ Solution design + API contract (OpenAPI 3.1) + ADR si aplica
  ↓
[dt-backend-engineer + dt-frontend-engineer + dt-dba]  ← en paralelo
  │ Implementación guiada por los casos de prueba ya identificados · PR · CI verde
  ↓
[dt-security-engineer]
  │ Security review · SAST · SCA · secrets scan
  ↓
[dt-qa-engineer]
  │ Ejecuta los casos ya identificados: integration · E2E · contract tests · UAT sign-off
  ↓
[dt-devops-engineer]
  │ Canary deploy → PROD → observabilidad activa
  ↓
[dt-product-owner]
  │ Acepta story · cierra NP-{NNN}
```

> **Quality Engineering shift-left (estándar permanente del swarm)**: la identificación de casos de prueba ocurre en DISCOVER/DESIGN, no en TEST. Un criterio de aceptación del que no se puede derivar un caso de prueba concreto no está bien escrito — dt-qa-engineer lo regresa al PO antes de que entre a BUILD. Catálogo vivo en `test-strategy-nomina-portal.md`.

### Activación de SMEs

Cualquier DT puede invocar un SME en su dominio sin necesidad de aprobación del Orquestador. El DT declara en su PR o en el artefacto correspondiente qué SME consultó y qué decisión adoptó.

Formato de invocación:
```
[INVOKE: SME/{ruta}]
CONTEXTO  : {descripción del problema}
PREGUNTA  : {decisión o validación requerida}
OUTPUT    : {artefacto esperado del SME}
```

---

## Definition of Ready (DoR) — Portal Nómina

Una story está lista para BUILD cuando:
- [ ] Criterios de aceptación escritos y firmados por dt-product-owner
- [ ] **Casos de prueba identificados por dt-qa-engineer a partir de los criterios de aceptación (QE shift-left)** — cada criterio tiene al menos un caso de prueba concreto y testeable
- [ ] API contract definido en OpenAPI 3.1 (dt-solution-architect)
- [ ] Dependencias con core bancario/SPEI clarificadas o marcadas como `[DATO-REQUERIDO]` con owner
- [ ] Implicaciones regulatorias CNBV/SAT/PCI declaradas
- [ ] Estimación de complejidad asignada por el Orquestador
- [ ] ADR creado si la story involucra una decisión arquitectónica

---

## Definition of Done (DoD) — Portal Nómina

Hereda DoD-SPE-01..08 + adiciones específicas:

- [ ] Código en repo con CI verde · branch protection activo
- [ ] Unit tests ≥ 80% cobertura en módulos críticos · ≥ 70% global
- [ ] API contract publicado y versionado en `adr/` o Backstage
- [ ] Contract tests (Pact) verdes entre Frontend ↔ API · API ↔ Core Banking Adapter
- [ ] SAST + SCA + secrets scan verdes (cero High/Critical)
- [ ] Validación CNBV/SAT si la story toca flujos regulados (dt-security-engineer sign-off)
- [ ] Runbook actualizado si se agrega nuevo failure mode
- [ ] Logs estructurados + métricas RED + tracing OTEL activos
- [ ] SLO declarado y alerta configurada
- [ ] Rollback plan documentado y probado en QA
- [ ] dt-product-owner confirma criterios de aceptación

---

## Ambientes

| Ambiente | Trigger de deploy | Owner |
|----------|------------------|-------|
| DEV | Push a rama feature | dt-backend-engineer / dt-frontend-engineer |
| QA | Merge a `main` | CI/CD automático (dt-devops-engineer) |
| UAT | Tag `uat-*` | dt-devops-engineer · dt-qa-engineer |
| STG | Tag `stg-*` + DAST verde | dt-devops-engineer · dt-security-engineer |
| PROD | Tag semver + CAB Scotiabank México + canary | dt-devops-engineer |

---

## Cadencia de Sprints

| Evento | Frecuencia | Owner |
|--------|-----------|-------|
| Sprint Planning | Inicio de sprint (2 semanas) | Orquestador + dt-product-owner |
| Story refinement | 2× por sprint | dt-product-owner + dt-solution-architect |
| Demo interno swarm | Fin de sprint | Todos los DTs |
| Retrospectiva | Fin de sprint | Orquestador |
| DORA review | Mensual | dt-devops-engineer |

---

## DORA Elite Targets

| Métrica | Target Elite | Mínimo aceptable |
|---------|-------------|-----------------|
| Deployment Frequency | ≥ diaria a DEV/QA | Semanal |
| Lead Time for Changes | < 1 día | < 1 semana |
| Change Failure Rate | < 5% | < 15% |
| MTTR | < 1 hora | < 1 día |

---

## Change Log

| Versión | Fecha | Cambio |
|---------|-------|--------|
| v0.1 | 2026-07-24 | Creación inicial · DISCOVER |
| v0.2 | 2026-07-24 | QE shift-left: identificación temprana de casos de prueba en DoR y flujo · dt-qa-engineer en DISCOVER/DESIGN |
