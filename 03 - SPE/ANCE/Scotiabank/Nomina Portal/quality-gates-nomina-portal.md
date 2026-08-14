# Quality Gates — Portal Empresas Nómina · Scotiabank México
> SPE-ANCE-001 · Hereda DoD-SPE-01..08 · Última actualización: 2026-07-24

---

## Gates por Fase

### DISCOVER → DESIGN

| Gate | Criterio | Owner |
|------|---------|-------|
| DoR completa | Todos los `[DATO-REQUERIDO]` críticos resueltos o con owner y fecha | dt-product-owner |
| ADR-ANCE-001 firmado | Estrategia integración core bancario Scotiabank definida y aprobada | dt-solution-architect |
| OpenAPI 3.1 draft | Contrato inicial del portal publicado y revisado | dt-solution-architect |
| Regulatorio declared | CNBV · SAT · PCI-DSS: impactos identificados y owner asignado | dt-security-engineer |

### DESIGN → BUILD

| Gate | Criterio | Owner |
|------|---------|-------|
| API contract final | OpenAPI 3.1 firmado · mock server corriendo | dt-solution-architect |
| DB schema aprobado | `ADR-ANCE-003` firmado · schema revisado por dt-dba | dt-dba |
| Auth strategy definida | `ADR-ANCE-004` firmado · IdP Scotiabank México confirmado | dt-security-engineer |
| Threat model | STRIDE completado sobre el portal | dt-security-engineer |
| CI pipeline verde | Pipeline base con SAST · SCA · secrets scan configurados | dt-devops-engineer |

### BUILD → TEST

| Gate | Criterio | Owner |
|------|---------|-------|
| Unit test coverage | ≥ 80% módulos críticos · ≥ 70% global | dt-qa-engineer |
| SAST verde | Cero vulnerabilidades High/Critical (SonarQube/Semgrep) | dt-security-engineer |
| SCA verde | Sin CVEs High/Critical en dependencias (Snyk/Dependabot) | dt-security-engineer |
| Secrets scan verde | Cero secrets en código (gitleaks/TruffleHog) | dt-security-engineer |
| Contract tests | Pact verde: Frontend↔API · API↔Core Banking Adapter | dt-qa-engineer |
| Code review | ≥ 1 reviewer DT + checks linter | Orquestador |

### TEST → RELEASE

| Gate | Criterio | Owner |
|------|---------|-------|
| Integration tests | Suite de integración verde en QA | dt-qa-engineer |
| E2E tests | Flujos críticos de nómina verde (Playwright) | dt-qa-engineer |
| Performance test | Latencia P95 < 500ms · throughput objetivo alcanzado | dt-qa-engineer |
| DAST verde | OWASP ZAP/Burp verde en STG | dt-security-engineer |
| UAT sign-off | dt-product-owner confirma criterios de aceptación | dt-product-owner |
| CNBV compliance | Flujos regulados validados contra CUB | dt-security-engineer + SME CNBV |
| SAT CFDI | Complemento nómina v1.2 válido ante el PAC | dt-backend-engineer + SME SAT |
| Rollback plan | Plan documentado y probado en STG | dt-devops-engineer |

### RELEASE → OPERATE

| Gate | Criterio | Owner |
|------|---------|-------|
| Canary health | Canary 10% corriendo ≥ 30 min sin alertas P1/P2 | dt-devops-engineer |
| Observabilidad activa | Logs + métricas RED + tracing OTEL activos en PROD | dt-devops-engineer |
| SLOs configurados | Alertas de SLO activas con paging | dt-devops-engineer |
| CAB Scotiabank México | Aprobación del Change Advisory Board de Scotiabank México | dt-devops-engineer |
| On-call definido | Rotación definida con backup | dt-devops-engineer |

---

## Definition of Done Específica del Portal

Hereda DoD-SPE-01..08 + criterios adicionales:

- [ ] **DoD-ANCE-01**: CFDI de nómina generado es válido ante el SAT (PAC confirma) — aplica a flows que producen CFDI.
- [ ] **DoD-ANCE-02**: Datos de CLABE y número de cuenta enmascarados en logs (PCI-DSS) — validado por dt-security-engineer.
- [ ] **DoD-ANCE-03**: Contract test entre `SPE-ANCE-002` y `SPE-ANCE-003` (Core Banking Adapter) verde — garantiza integración con core bancario.
- [ ] **DoD-ANCE-04**: Instrucción de dispersión produce trazabilidad completa: empresa → nómina → dispersión → SPEI tx → confirmación — auditable.
- [ ] **DoD-ANCE-05**: Flujos regulados CNBV (altas de empresa, reportes) pasan por sign-off del SME CNBV antes de RELEASE.

---

## SLOs del Portal

| ID | Métrica | Target | Alerta |
|----|---------|--------|--------|
| SLO-ANCE-01 | Disponibilidad mensual | ≥ 99.9% | < 99.5% → P1 |
| SLO-ANCE-02 | Latencia API P95 (síncrono) | < 500ms | > 800ms → P2 |
| SLO-ANCE-03 | Latencia dispersión E2E | < 2 min | > 5 min → P2 |
| SLO-ANCE-04 | Error rate (7 días) | < 0.1% | > 0.5% → P1 |
| SLO-ANCE-05 | CFDI generation success rate | ≥ 99.5% | < 99% → P2 |

---

*Creado: 2026-07-24 · v0.1 · [STATE: DRAFT]*
