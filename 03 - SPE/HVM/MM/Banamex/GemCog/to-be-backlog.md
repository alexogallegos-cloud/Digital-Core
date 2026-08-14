# TO-BE Backlog — Banamex GemCog (fuera del índice AS-IS)
> Artefactos que documentan el sistema TARGET o la estrategia de migración — **no el AS-IS**.
> Extraídos del MANIFEST el 2026-07-24 para mantener el MANIFEST como índice AS-IS puro.
> Se re-indexarán en MANIFEST cuando se active la fase metodológica correspondiente.

---

## Artefactos TO-BE (Fase 2+)

| Archivo | Fase metodológica | Descripción |
|---------|-------------------|-------------|
| [migration-risk-register.md](migration-risk-register.md) | Fase 2 — Regulatory / Risk | 170 riesgos de migración · 23 caps · DEFECTO-PROD: 7 · CRÍTICO: 57 · ALTO: 65 |
| [cnbv-regulatory-impact-assessment.md](cnbv-regulatory-impact-assessment.md) | Fase 2 — Regulatory / Risk | Evaluación de Impacto Regulatorio · CNBV Circular 29/2010 · 13 reportes · v0.1-DRAFT · Owner: Regulatory SME |
| [coexistence-model.md](coexistence-model.md) | Fase 2 — Migration Governance | Artefacto P0 · Modelo de coexistencia · SoR por wave · control mutex SCIG/PAQUETECONTABLE · parallel-run operacional · gates de wave · comunicación CNBV |
| [rollback-plan.md](rollback-plan.md) | Fase 2 — Migration Governance | Plan de Rollback · criterios de activación y procedimientos de reversión por wave · v0.2-QC · Owner: Specialist - 7R Assessment |
| [migration-calendar-constraints.md](migration-calendar-constraints.md) | Fase 2 — Migration Governance | Restricciones de Calendario · períodos prohibidos y ventanas de cutover · v0.2-QC · Owner: Specialist - 7R Assessment |
| [equivalencia-strategy.md](equivalencia-strategy.md) | Fase 3 — Test & Equivalence | Estrategia de equivalencia funcional COBOL→Java · thresholds · golden-masters |
| [ubiquitous-language-target.md](ubiquitous-language-target.md) | Fase 5 — Modernize · Capa 6 | Lenguaje ubicuo del dominio TARGET (Java/cloud-native) |
| [scaffold-report.md](scaffold-report.md) | Fase 5 — Domain Seeding | Scaffold Maven por Bounded Context · naming derivado del ubiquitous language |
| [incident-log-s500-s151.md](incident-log-s500-s151.md) | Fase 2 (prerequisito) | Log de incidentes S500+S151 · v0.1-STUB · prerequisito de rollback-plan.md antes de Wave 0-A |

---

*Creado: 2026-07-24 · Separado del MANIFEST AS-IS · Se re-indexa al activar cada fase*
