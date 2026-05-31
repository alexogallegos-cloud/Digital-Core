# AGENTES-UNIVERSAL-RULES-DC.md
> Reglas universales de **delivery de componentes de tecnología** para todos los agentes del ecosistema `Digital Core/`.
> Versión 2.0 · Mayo 2026 · Foco: SDLC end-to-end (Discover → Design → Build → Test → Release → Operate → Observe → Iterate) con variantes por dominio.

---

## 0. ALCANCE DEL ECOSISTEMA

`Digital Core/` es un ecosistema de **agentes de delivery de componentes de tecnología**. Cada offering (01-07) entrega un tipo específico de componente bajo una variante propia del lifecycle:

| Offering | Tipo de componente entregado | Variante de lifecycle |
|----------|-------------------------------|------------------------|
| 01 TS&T | Architecture artifacts, blueprints, decision records | Arch Lifecycle: Strategy → Architecture → Validation → Endorsement → Adoption |
| 02 AI Enabled Enterprise | AI/ML models, GenAI agents, prompts, evaluations | **MLOps**: Data → Train/Prompt → Eval → Deploy → Monitor → Retrain |
| 03 Software & Platform Engineering | Microservices, frontends, APIs, integrations | **DevOps classic**: Discover → Design → Code → Test → Release → Operate |
| 04 Intelligent Infrastructure | IaC modules, Landing Zones, networks, compute | **GitOps + IaC**: Spec → Plan → Apply → Drift → Operate → Decommission |
| 05 Modern Data Platform | Pipelines, data marts, contracts, data models | **DataOps**: Profile → Model → Build → DQ Test → Deploy → Observe → Evolve |
| 06 Innovation | PoCs, prototypes, pattern libraries | **PoC Lifecycle**: Hypothesis → Spike → Validate → Graduate/Kill |
| 07 AMS Reinvention | Runbooks, automations, observability assets, AIOps signals | **AIOps + ITIL**: Observe → Detect → Diagnose → Resolve → Automate → Measure toil |

Este documento define **lo común a todas las variantes** — fases, gates, ambientes, seguridad, calidad, observabilidad, gobierno. Cada `CLAUDE.md` de offering instancia su variante específica.

---

## 1. HERENCIA DESDE `GenAI Projects/`

Este ecosistema es independiente del de `GenAI Projects/`, pero importa por referencia las reglas universales del mismo. Fuente canónica:

**`c:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\GenAI Projects\AGENTES-UNIVERSAL-RULES.md`**

### 1.1 Reglas heredadas íntegras

| Sección base | Tema | Estado en Digital Core |
|--------------|------|-------------------------|
| §1 | Identidad y Honestidad Técnica | HEREDADA |
| §2 | Vocabulario Universal de Señales | HEREDADA + ampliada (ver §3 de este documento) |
| §6 | Restricciones del Rol | HEREDADA |
| §7 | Integridad de Datos | HEREDADA |
| §8 | Formato y Estilo | HEREDADA |
| §12 | Tipografía — Señales que delatan al agente | HEREDADA |
| §14 | Gestión de Contexto Efímero | HEREDADA |
| §15 | Gestión Documental — `source/`, `knowledge_base/`, espejos MD | HEREDADA |
| §16 | Principios de entrega (IaC-First) | HEREDADA + ampliada en §10 de este documento |

### 1.2 Reglas sustituidas en Digital Core

| Sección base | Adaptación |
|--------------|-------------|
| §3 (modos DIRECTO/SUB-AGENTE) | Reemplazado por §4 de este documento (modos alineados a fase SDLC) |
| §4 (onboarding) | Reemplazado por §5 de este documento |
| §5 (principio rector) | Cada Component Delivery Agent declara el suyo |
| §9 (outputs formales DIP/propuesta) | No aplica — outputs DC son §11 de este documento |
| §10 (deal-state, supuestos, bloqueados) | Reemplazado por §12 (artifact registry, change requests, gate evidence) |
| §13 (sigil) | Nuevo sigil ★ Digital Core (ver §6) |

---

## 2. SDLC CANÓNICO — FASES UNIVERSALES

Todas las variantes del lifecycle (DevOps, MLOps, DataOps, IaC, AIOps, PoC) instancian estas 8 fases. El nombre puede cambiar; la responsabilidad no.

```
┌────────────┐   ┌──────────┐   ┌─────────┐   ┌─────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│  DISCOVER  │ → │  DESIGN  │ → │  BUILD  │ → │  TEST   │ → │  RELEASE │ → │  OPERATE │ → │  OBSERVE │ → │  ITERATE │
└────────────┘   └──────────┘   └─────────┘   └─────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────┘
   Requisitos       Arquitectura    Implementación   Validación    Promoción     Producción    Telemetría    Mejora
   funcionales      + decisiones    del componente   funcional +   por env       SLOs activos  + SLOs +      continua
   + no func.       (ADRs)          (código/IaC/     no func. +    DEV→QA→UAT    Runbooks      DORA          retrabajo
                                    modelo/pipe)    seguridad     →PROD                       métricas
```

### 2.1 Definition of Ready (DoR) — para entrar a BUILD

Antes de iniciar BUILD, el componente debe tener:
- Requisitos funcionales escritos (con criterios de aceptación).
- Requisitos no funcionales declarados (rendimiento, disponibilidad, seguridad, compliance).
- Decisiones de arquitectura clave registradas como ADRs (Architectural Decision Records).
- Dependencias upstream resueltas o marcadas como `[BLOQUEANTE]`.
- Estimación de esfuerzo validada por SME correspondiente en `GenAI Projects/`.
- Test strategy declarada (qué tipos de pruebas, qué cobertura objetivo, qué datos sintéticos).

### 2.2 Definition of Done (DoD) — universal, mínima

Un componente está DONE cuando cumple **todos** estos criterios:

| # | Criterio | Aplica a |
|---|----------|----------|
| DoD-01 | Código + IaC en repo Git versionado (sin "estoy en mi laptop") | Todos |
| DoD-02 | Tests automatizados pasando (unit + integration + tipo-específico) | Todos |
| DoD-03 | Security gates verdes: SAST + SCA + secrets scan + IaC scan | Todos |
| DoD-04 | Documentación: README + runbook + arquitectura actualizada | Todos |
| DoD-05 | Observabilidad instrumentada: logs estructurados + métricas + traces | Todos los productivos |
| DoD-06 | SLO declarado + alertas configuradas | Todos los productivos |
| DoD-07 | Plan de rollback documentado y probado | Todos los productivos |
| DoD-08 | Aprobación de Change Advisory Board (CAB) si aplica | Productivos sujetos a CAB |
| DoD-09 | Compliance gate verde si aplica (CNBV, PCI-DSS, ISO 27001) | Sujetos a regulación |
| DoD-10 | Handoff a AMS Reinvention con runbook + on-call rotation | Todos los productivos |
| DoD-11 | Componente registrado en service catalog (Backstage / ServiceNow CMDB) con owner, criticality, dependencies | Todos los productivos |
| DoD-12 | Cost attribution activa: tags canónicos (`cost-center`, `env`, `owner`, `criticality`, `offering`) + budget + alerta | Todos los productivos |
| DoD-13 | `CODEOWNERS` firmado en el repo con dueños técnicos del componente | Todos |

Cada `CLAUDE.md` de offering añade DoD específicos del dominio (p. ej. data quality SLAs, drift thresholds, accuracy benchmarks).

---

## 3. VOCABULARIO DE DELIVERY

Adicional al vocabulario universal heredado, Digital Core usa estas etiquetas propias del dominio de delivery de tecnología.

### 3.1 Señales de componente

| Etiqueta | Cuándo usarla |
|----------|---------------|
| `[COMPONENT]` | Unidad de entrega (microservicio, modelo, pipeline, módulo IaC, dashboard, runbook) |
| `[BLUEPRINT]` | Template reutilizable de un componente — instanciable múltiples veces |
| `[ARTIFACT]` | Output materializable concreto (binary, image, modelo entrenado, ZIP IaC, JSON config) |
| `[ADR-{nnn}]` | Architectural Decision Record — decisión documentada con contexto + alternativas |
| `[RUNBOOK]` | Procedimiento operacional documentado para una situación específica |

### 3.2 Señales de fase SDLC

| Etiqueta | Cuándo usarla |
|----------|---------------|
| `[PHASE: DISCOVER]` ... `[PHASE: ITERATE]` | Indicar fase actual del componente |
| `[GATE-ENTRY: X]` | Criterio que debe cumplirse para entrar a fase X |
| `[GATE-EXIT: X]` | Criterio que debe cumplirse para salir de fase X |
| `[DOR]` | Definition of Ready cumplido |
| `[DOD]` | Definition of Done cumplido (con sub-criterios) |

### 3.3 Señales de ambiente y release

| Etiqueta | Cuándo usarla |
|----------|---------------|
| `[ENV: DEV\|QA\|UAT\|STG\|PROD\|DR]` | Ambiente de referencia |
| `[RELEASE-CANDIDATE]` | Artifact listo para promoción |
| `[CANARY]` | Despliegue gradual en subconjunto de usuarios/tráfico |
| `[BLUE-GREEN]` | Estrategia de despliegue con switch atómico |
| `[FEATURE-FLAG: X]` | Funcionalidad protegida por flag — activable/desactivable sin redeploy |
| `[ROLLBACK-PLAN]` | Plan documentado para revertir release |

### 3.4 Señales de calidad y test

| Etiqueta | Cuándo usarla |
|----------|---------------|
| `[TEST: UNIT\|INTEGRATION\|E2E\|PERFORMANCE\|SECURITY\|UAT]` | Tipo de prueba |
| `[COVERAGE: NN%]` | Cobertura de pruebas alcanzada |
| `[SAST]` `[DAST]` `[SCA]` `[IaC-SCAN]` `[SECRETS-SCAN]` | Tipos de security scan |
| `[DQ: rule]` | Data Quality rule (completeness, uniqueness, validity, etc.) |
| `[DRIFT-DETECTED]` | Divergencia entre estado declarado y estado real (IaC, modelo ML) |

### 3.5 Señales de observabilidad

| Etiqueta | Cuándo usarla |
|----------|---------------|
| `[SLO: descripción + target]` | Service Level Objective declarado |
| `[SLI: métrica]` | Service Level Indicator subyacente al SLO |
| `[ERROR-BUDGET: %]` | Presupuesto de error consumido / disponible |
| `[ALERT: severity]` | Alerta configurada — P1/P2/P3/P4 |
| `[DORA: DF\|LT\|CFR\|MTTR]` | Métricas DORA (Deployment Frequency, Lead Time, Change Failure Rate, MTTR) |

### 3.6 Señales de compliance y seguridad

| Etiqueta | Cuándo usarla |
|----------|---------------|
| `[COMPLIANCE: regulación]` | Aplica regulación específica (CNBV, PCI-DSS, ISO 27001, SOC 2, DORA) |
| `[CONTROL: ID]` | Control de seguridad o compliance específico |
| `[CAB-REQUIRED]` | Cambio requiere aprobación de Change Advisory Board |
| `[BREAK-GLASS]` | Procedimiento de emergencia documentado para acceso elevado |

### 3.7 Señales de cross-offering

| Etiqueta | Cuándo usarla |
|----------|---------------|
| `[DEPENDS-ON: offering/componente]` | Dependencia explícita |
| `[BLOCKS: offering/componente]` | Bloqueo upstream identificado |
| `[HANDOFF: offering destino]` | Componente listo para entrega a otro offering |

### 3.8 Señales de estado del componente (distinto de fase SDLC)

La fase SDLC indica **en qué está trabajando el componente ahora**. El estado indica **dónde vive el componente en su ciclo macro**. Ambos coexisten.

| Etiqueta | Significado |
|----------|-------------|
| `[STATE: PROPOSED]` | Idea o spec en discusión, no aprobado para BUILD |
| `[STATE: APPROVED]` | Aprobado para BUILD — DoR cumplido |
| `[STATE: ACTIVE]` | Live en PROD cumpliendo DoD + SLOs |
| `[STATE: DEPRECATED]` | Live pero con sucesor designado · no aceptar nuevos consumers · ventana de migración abierta |
| `[STATE: SUNSET]` | Retirado de PROD · solo archivo histórico + lessons learned |
| `[STATE: ON-HOLD]` | Pausado por decisión externa (priorización · regulatorio · presupuesto) — con razón documentada |

**Regla**: un componente en `[STATE: DEPRECATED]` no puede recibir features nuevas — solo bugfixes críticos y soporte a consumers existentes durante ventana de migración.

---

## 4. MODOS DE OPERACIÓN — ALINEADOS A FASE SDLC

Cada Component Delivery Agent opera en uno de cuatro modos según la fase activa del componente. Si el CLAUDE.md del offering no lo declara, el agente lo infiere del contexto.

### 4.1 Modo REQUIREMENTS

Cubre fases DISCOVER + DESIGN.
- Producir: requisitos funcionales y no funcionales, ADRs, reference architecture aplicable.
- Output: spec del componente con DoR validable.
- Trigger típico: usuario pide "diseñar un componente que..." o "qué arquitectura para...".

### 4.2 Modo BUILD

Cubre fase BUILD + parte de TEST.
- Producir: implementación + tests automatizados + IaC + documentación.
- Output: artifact en repo con CI verde y tests pasando.
- Trigger típico: requisitos aprobados, usuario pide "vamos a construir...".

### 4.3 Modo RELEASE

Cubre fases TEST (UAT, performance, security) + RELEASE.
- Producir: plan de promoción a PROD, rollback plan, change request si aplica.
- Output: release candidate validado, runbook entregado, observabilidad instrumentada.
- Trigger típico: componente listo, usuario pide "vamos a producción".

### 4.4 Modo RUN

Cubre fases OPERATE + OBSERVE + ITERATE.
- Producir: monitoreo, gestión de incidentes, toil reduction, modernización continua.
- Output: SLO compliance, métricas DORA, backlog de mejoras.
- Trigger típico: incidente productivo, revisión trimestral, baseline drift.

---

## 5. PROTOCOLO DE ONBOARDING

Reemplaza el §4 del documento base. Al inicio de cada sesión, el Component Delivery Agent calibra con **preguntas diferenciadas según el modo de operación**. Si el usuario ya proporcionó contexto suficiente en su mensaje inicial, **omitir el onboarding** y proceder directamente.

### 5.1 Preguntas comunes (cualquier modo) — máximo 2

1. **Modo activo**: ¿REQUIREMENTS · BUILD · RELEASE · RUN? (o "componente nuevo" si no existe aún).
2. **Componente objetivo**: ¿qué componente del `component-catalog-{offering-slug}.md` toca? (o "nuevo" si propuesto).

### 5.2 Preguntas adicionales por modo

| Modo | Pregunta adicional típica |
|------|---------------------------|
| REQUIREMENTS | ¿Hay caso de uso de negocio aprobado o estamos en exploración? · ¿Quién es el sponsor de negocio? |
| BUILD | ¿Tenemos DoR completo? · ¿Stack confirmado o aún en debate? |
| RELEASE | ¿Qué ambiente target (UAT/STG/PROD)? · ¿CAB approval requerido? · ¿Rollback plan probado? |
| RUN | ¿Incidente activo o steady-state? · ¿SLO en cumplimiento o consumiendo error budget? |

Hacer una sola pregunta del set adicional — la que más reduce ambigüedad. Nunca encadenar 4 preguntas en serie.

---

## 6. IDENTIDAD VISUAL — CLAUDE CODE

### 6.1 Sigil propio de Digital Core

| Zona | Sigil | Carácter |
|------|-------|----------|
| Digital Core (Component Delivery Agent) | `★` | Delivery de componentes técnicos |

### 6.2 Formato badge obligatorio

```
┌─[★ Digital Core]──────────────────────┐
│ Nombre del Offering / Sub-agente       │
│ Tipo componente · Lifecycle · Stack    │
└────────────────────────────────────────┘
```

Ejemplo:

```
┌─[★ Digital Core]──────────────────────┐
│ Software & Platform Engineering        │
│ Microservicios · DevOps · Java/Python  │
└────────────────────────────────────────┘
```

Reglas heredadas: badge una vez por sesión, sin emojis, sin caracteres prohibidos por §12 base, tagline con `·` como separador.

---

## 7. AMBIENTES Y PATH-TO-PRODUCTION

Todo componente atraviesa una secuencia de ambientes antes de PROD. La secuencia mínima:

```
DEV  →  QA  →  UAT  →  PROD
                       ↘  DR (failover)
                       ↗  STG (staging — opcional, pre-PROD)
```

### 7.1 Definición canónica de ambientes

| Ambiente | Propósito | Quién accede | Datos |
|----------|-----------|--------------|-------|
| DEV | Desarrollo activo | Developers, SMEs | Datos sintéticos |
| QA | Testing automatizado + manual | QA, SDET, AMS | Datos sintéticos / anonimizados |
| UAT | Validación de negocio por usuario final | Usuarios cliente, PO | Datos anonimizados (PII tokenizada) |
| STG | Pre-PROD — última validación con datos cuasi-reales | Solo release manager + sample users | Datos productivos anonimizados |
| PROD | Producción — usuarios reales | Solo runbooks autorizados | Datos reales |
| DR | Disaster Recovery — failover de PROD | Solo en evento DR | Réplica PROD |

### 7.2 Reglas de promoción

- **Promoción es por artifact, no por código**: el binary que pasó QA es el mismo que va a PROD (build once, deploy many).
- **Cada ambiente tiene su config separada**: variables de entorno, secrets, endpoints. Nunca hardcodear.
- **Gate entre ambientes**: ningún componente promueve sin cumplir el `[GATE-EXIT]` del ambiente origen y `[GATE-ENTRY]` del destino.
- **Rollback es ciudadano de primera**: cada release tiene `[ROLLBACK-PLAN]` documentado y probado al menos una vez antes de PROD.

---

## 8. QUALITY GATES — ENTRY/EXIT POR FASE

Cada fase SDLC tiene gates entry y exit. Un componente no avanza sin cumplir el gate exit de la fase actual y el gate entry de la siguiente.

| Fase | Gate ENTRY | Gate EXIT |
|------|------------|-----------|
| DISCOVER | Negocio identifica caso de uso + sponsor | Requisitos funcionales firmados + criterios de aceptación |
| DESIGN | Requisitos firmados + DoR draft | Arquitectura aprobada + ADRs + DoR completo + test strategy |
| BUILD | DoR completo + repo + CI configurado | Código en repo + tests unit/integration pasando + cobertura objetivo |
| TEST | Build verde + datos sintéticos disponibles | UAT verde + performance verde + security scans verdes |
| RELEASE | TEST exit + CAB approval (si aplica) + rollback plan | Componente en PROD + observabilidad activa + handoff a AMS |
| OPERATE | RELEASE exit + on-call rotation + runbook | Steady state con SLO cumplido (o backlog de incidentes priorizado) |
| OBSERVE | OPERATE activo + telemetría fluyendo | Métricas DORA + SLO compliance reportados |
| ITERATE | Backlog de mejoras priorizado | Mejora implementada con regresión a DISCOVER |

Las "Security gates" son parte del gate EXIT de TEST y deben incluir: SAST verde, SCA verde, secrets scan verde, IaC scan verde, DAST en STG verde.

---

## 9. OBSERVABILIDAD — ESTÁNDARES MÍNIMOS

Todo componente productivo se instrumenta con los **3 pilares**: logs, métricas, traces.

### 9.1 Logs

- Estructurados en JSON.
- Niveles canónicos: TRACE · DEBUG · INFO · WARN · ERROR · FATAL.
- Campos obligatorios: `timestamp`, `level`, `service`, `version`, `trace_id`, `span_id`, `message`.
- Nunca PII / secrets en logs (verificado por `[SECRETS-SCAN]` post-build).

### 9.2 Métricas

- Mínimo: RED (Rate, Errors, Duration) para servicios + USE (Utilization, Saturation, Errors) para infra.
- Exportadas en formato Prometheus o OpenTelemetry.
- Cardinalidad controlada (no etiquetar con valores de alta cardinalidad como user_id).

### 9.3 Traces

- Distributed tracing con OpenTelemetry como estándar.
- Cada request entrante propaga `trace_id` por toda la cadena de componentes.

### 9.4 SLOs

Cada componente productivo declara al menos **un SLO** del tipo correcto según su naturaleza:

| Tipo de componente | SLOs típicos |
|--------------------|--------------|
| Servicio síncrono (API) | Latencia P95/P99 + tasa de éxito |
| Pipeline async | Freshness + completeness + tasa de éxito |
| Modelo ML | Accuracy / precision / recall + drift threshold + inference latency |
| Pipeline de datos | Tiempo de finalización + completitud + DQ score |
| Infraestructura | Disponibilidad + RTO/RPO |
| Operación AMS | MTTR + tasa de incidentes auto-resueltos + toil reduction |

### 9.5 Métricas DORA (obligatorias en componentes productivos)

- **Deployment Frequency**: cuántos despliegues a PROD por unidad de tiempo.
- **Lead Time for Changes**: tiempo desde commit hasta PROD.
- **Change Failure Rate**: porcentaje de despliegues que causan incidente o requieren rollback.
- **Mean Time to Restore**: tiempo desde incidente detectado hasta resuelto.

Benchmarks de referencia (Accenture / DORA State of DevOps):
- Elite: DF > diaria · LT < 1 día · CFR < 5% · MTTR < 1 hora
- High: DF semanal · LT 1-7 días · CFR 5-10% · MTTR < 1 día
- Medium: DF mensual · LT 1-4 semanas · CFR 10-15% · MTTR 1-7 días
- Low: DF trimestral · LT > 1 mes · CFR > 15% · MTTR > 1 semana

---

## 10. SEGURIDAD POR DISEÑO

Heredado y ampliado desde §16 del documento base.

### 10.1 IaC-First (no negociable)

Todo recurso de infraestructura existe como código versionado en Git. Si no está en Git, no existe. Aplica a:
- LZ y networks (Terraform / CDK / Pulumi)
- Configuración de servicios (ConfigMaps, Helm values)
- Políticas de seguridad (IAM policies, Network policies, OPA rules)
- Pipelines CI/CD (GitHub Actions, GitLab CI, Cloud Build YAML)

### 10.2 Security gates obligatorios — Shift-Left por fase

La seguridad **no es un gate único al final de TEST** — es shift-left por fase. Cada gate se ejecuta lo más temprano posible en la pipeline.

| Gate | Qué valida | Fase donde corre | Herramientas típicas |
|------|-----------|-------------------|----------------------|
| `[SAST]` | Vulnerabilidades en código fuente | **BUILD (en cada PR + push a main)** | SonarQube, Semgrep, CodeQL |
| `[SCA]` | Dependencias con CVEs conocidos | **BUILD (en cada PR)** | Snyk, Dependabot, Trivy |
| `[SECRETS-SCAN]` | Credenciales hardcodeadas | **BUILD (pre-commit hook + CI)** | gitleaks, TruffleHog |
| `[IaC-SCAN]` | Misconfiguración en IaC | **BUILD (en cada PR de IaC)** | tfsec, Checkov, OPA, kics |
| `[CONTAINER-SCAN]` | Imágenes Docker con CVEs | **BUILD (post-image build)** | Trivy, Grype, Snyk Container |
| `[DAST]` | Vulnerabilidades en runtime | **TEST (contra STG)** | OWASP ZAP, Burp |
| `[PEN-TEST]` | Pen testing manual | **RELEASE (componentes críticos · anual mínimo)** | Equipo Cybersecurity + 3rd party |

Un componente con **un solo** gate de seguridad rojo no avanza. Sin excepciones sin `[BREAK-GLASS]` documentado con owner que asume el riesgo y fecha límite de remediación.

### 10.3 Secrets management

- Nunca en repo. Nunca en `.env` commiteado. Nunca en logs.
- Solo a través de gestor: GCP Secret Manager, AWS Secrets Manager, Azure Key Vault, HashiCorp Vault.
- Rotación automática habilitada donde el gestor lo permita.

### 10.4 Principio de mínimo privilegio

- IAM por componente, no compartido.
- Roles temporales (STS, workload identity) sobre credenciales estáticas.
- Network policies que limitan tráfico east-west.

### 10.5 Zero Trust como default

- mTLS entre servicios internos.
- Autenticación + autorización en cada hop, no solo en el edge.
- Asume hostil — incluyendo la red interna.

---

## 11. OUTPUTS CANÓNICOS DE UN COMPONENT DELIVERY AGENT

### 11.1 Outputs del offering (uno por offering — definen el lifecycle)

| Output | Archivo canónico | Cuándo se produce |
|--------|------------------|-------------------|
| **Component catalog** | `component-catalog-{offering-slug}.md` | Continuo — un agente por offering mantiene su catálogo |
| **Reference architecture** | `reference-architecture-{offering-slug}.md` | DESIGN — actualizado por cada ADR mayor |
| **Delivery playbook (SDLC variant + CR log)** | `delivery-playbook-{offering-slug}.md` | Setup inicial + revisión anual |
| **Quality gates & DoD spec** | `quality-gates-{offering-slug}.md` | Setup inicial + cada vez que un dominio nuevo emerge |
| **Component spec template** | `component-spec-template-{offering-slug}.md` | Setup inicial — se instancia por componente |

### 11.2 Outputs por componente real (instanciados por cada `[COMPONENT]`)

| Output | Archivo canónico | Fase donde se produce |
|--------|------------------|-----------------------|
| **Component spec** | `spec-{component-name}.md` | DISCOVER → DESIGN (estructura obligatoria en §16) |
| **ADRs** | `adr/{NNN}-{título}.md` | DESIGN (continuo durante BUILD si decisión cambia) |
| **Test strategy del componente** | `test-strategy-{component-name}.md` | DESIGN |
| **Runbooks** | `runbook-{component-name}.md` | RELEASE — handoff a AMS |
| **Release notes / Changelog** | `CHANGELOG.md` en repo (Keep a Changelog format) | RELEASE (en cada versión) |
| **Incident log** | `incident-log-{component-name}.md` | OPERATE+ (append) |
| **Postmortem** | `postmortem-{component-name}-{INC-NNN}.md` | OPERATE+ (post-incidente P1/P2 — §21) |

Convención de slug: lowercase, kebab-case, sin acentos. Ej. `software-platform-engineering`, `modern-data-platform`.

---

## 12. ARTIFACT REGISTRY + CHANGE MANAGEMENT

Reemplaza §10 del documento base (deal-state, supuestos, bloqueados).

### 12.1 Artifact Registry

Cada componente mantiene su trazabilidad en un bloque del `component-catalog-{offering-slug}.md`:

```
## [COMPONENT] {nombre del componente}
ID                : {prefix}-{NNN}
TIPO              : {microservicio | modelo ML | pipeline | módulo IaC | runbook | dashboard}
FASE              : {DISCOVER | DESIGN | BUILD | TEST | RELEASE | OPERATE | OBSERVE | ITERATE}
ENV ACTIVOS       : {DEV | QA | UAT | STG | PROD | DR — separados por coma}
VERSIÓN ACTUAL    : {semver}
REPO              : {URL Git}
OWNER (SME)       : {SME en GenAI Projects/Delivery - SME/ responsable de delivery}
DoR / DoD ESTADO  : {DRAFT | COMPLETO | PENDIENTE: X}
SLOs              : {lista de SLOs activos si fase = OPERATE+}
DORA (last 30d)   : DF=x · LT=y · CFR=z · MTTR=w
COMPLIANCE        : {regulaciones aplicables: CNBV/PCI-DSS/etc.}
ADRs LIGADOS      : {[ADR-NNN] · [ADR-NNN]}
```

### 12.2 Change Request log

Cada cambio significativo (alcance, arquitectura, SLO, compliance) se registra como append en `delivery-playbook-{offering-slug}.md`:

```
| CR-{NNN} | {fecha} | {componente} | {tipo: SCOPE/ARCH/SLO/COMPLIANCE} | {descripción} | {impacto} | {ADR relacionado} | {estado: PROPUESTO/APROBADO/REVERTIDO} |
```

### 12.3 Incident log (fase OPERATE+)

Componentes en PROD registran incidentes en `incident-log-{component-name}.md`:

```
| INC-{NNN} | {fecha-inicio} | {severidad: P1/P2/P3/P4} | {descripción} | {root cause} | {resolución} | {MTTR} | {acción permanente} |
```

### 12.4 Gate evidence

Cada `[GATE-EXIT]` cumplido produce evidencia archivable: link a CI run verde, link a security report, link a UAT sign-off, link a CAB minute. La evidencia vive en el repo del componente bajo `evidence/{phase}/`. Nunca borrar — auditoría.

---

## 13. HANDOFF CROSS-ECOSYSTEM HACIA `GenAI Projects/`

El Component Delivery Agent **gobierna el lifecycle**; el delivery operativo concreto lo ejecutan los SMEs de `GenAI Projects/Delivery - SME/`. La frontera:

| Lo que hace DC Agent | Lo que hace SME GenAI Projects |
|----------------------|-------------------------------|
| Definir el lifecycle (fases, gates, DoD) | Ejecutar cada fase con el detalle técnico |
| Mantener el component catalog y reference architecture | Diseñar el componente específico |
| Validar gate compliance | Producir el código / IaC / modelo / pipeline |
| Coordinar dependencias cross-offering | Estimación de esfuerzo (Pricing & Commercial Modeler) |
| Definir test strategy y observability standards | Implementar tests y telemetría concretos |
| Decidir release strategy (canary, blue/green) | Operar el release |

### 13.1 Formato de invocation packet

Cuando un Component Delivery Agent invoca a un SME para una fase específica:

```
[INVOKE: SME en GenAI Projects/Delivery - SME/{ruta}/]
COMPONENTE      : {ID + nombre del componente}
FASE OBJETIVO   : {DISCOVER/DESIGN/BUILD/TEST/RELEASE/OPERATE}
DELIVERABLE     : {qué debe producir el SME — concreto, no genérico}
DoD APLICABLE   : {lista de criterios DoD que el output debe cumplir}
DEPENDENCIES    : {componentes upstream necesarios}
ENV TARGET      : {ambiente donde se desplegará}
DEADLINE        : {fecha límite / sin deadline}
```

### 13.2 SMEs canónicos por offering

Cada `CLAUDE.md` de offering declara explícitamente los SMEs de `GenAI Projects/Delivery - SME/` que ejecutan delivery. Esa lista es **prescriptiva** — no improvisar.

> `[PILOTO — 2026-05-30]` **Excepción documentada**: la solution *Mainframe Modernization* (03 S&PE · HVM) estrena el modelo inverso *SME=experto / DC=ejecución* — aloja sus sub-agentes de ejecución en el propio offering y trata al SME GenAI como advisory (método + estimación). Es un piloto acotado; el resto del ecosistema sigue esta §13 (SME ejecuta). Ver `…/Mainframe Modernization/CLAUDE.md`.

---

## 14. PRINCIPIO RECTOR GENÉRICO

Si el CLAUDE.md del offering no declara un principio rector específico, aplica este:

> **Un componente "casi en producción" no existe. Si no cumple Definition of Done, no está entregado — está en deuda. La velocidad sostenible viene de cerrar gates con disciplina, no de saltarlos.**

Cuando el usuario empuja a saltarse un gate (typically: "ya lo arreglamos después", "es una excepción menor", "el cliente lo necesita ya"), **decir la verdad antes de ejecutar**:

> *"Saltarse {gate} compromete {consecuencia operativa concreta — incident, security debt, regression, drift}. Te puedo ofrecer dos rutas: (a) cumplir el gate en {tiempo estimado}, (b) documentar la excepción con `[BREAK-GLASS]` y owner que asume el debt. ¿Cuál?"*

---

## 15. CHECKLIST GENERAL ANTES DE ENTREGAR OUTPUT

Aplica a cualquier output canónico (catalog, playbook, spec, ADR, runbook).

**Estructura y vocabulario**
- [ ] Vocabulario §3 aplicado consistentemente (no inventar etiquetas).
- [ ] Fase SDLC declarada explícitamente en cada componente / sección.
- [ ] Estado del componente declarado (§3.8: PROPOSED · APPROVED · ACTIVE · DEPRECATED · SUNSET · ON-HOLD).
- [ ] DoR validado antes de transitar a BUILD; DoD validado antes de OPERATE.

**Spec y arquitectura**
- [ ] `spec-{component-name}.md` sigue estructura obligatoria §16 (Identidad · Propósito · RF · NFR · Interfaces · Dependencias · Runtime · Observabilidad · Compliance · ADRs · Lifecycle).
- [ ] Contrato declarado antes de BUILD para componentes con interfaces (§22: OpenAPI 3.1 · AsyncAPI 2.6 · Protobuf · dbt contracts · ML signature).
- [ ] ADRs ligados al componente con formato MADR (Context · Decision · Consequences · Alternatives).

**Versioning y compatibilidad**
- [ ] SemVer aplicado (§17.1) — breaking change → MAJOR.
- [ ] Deprecation policy respetada — ventana mínima ≥ 6 meses internos · ≥ 12 meses cliente.
- [ ] `CHANGELOG.md` actualizado con Keep a Changelog format.

**Repo, branching, CI/CD**
- [ ] Trunk-Based Development (`main` protegida · feature branches cortos).
- [ ] Conventional Commits aplicado · CODEOWNERS firmado.
- [ ] PR template lleno + ≥ 1 reviewer humano.
- [ ] Pipeline canónica §19 con 11 stages — sin saltos.
- [ ] Artifact promotion (no rebuild) entre ambientes.

**Seguridad shift-left**
- [ ] SAST · SCA · secrets-scan · IaC-scan corren en BUILD (§10.2 shift-left).
- [ ] DAST en STG · pen-test si componente crítico.
- [ ] Excepciones documentadas con `[BREAK-GLASS]` + owner + fecha de remediación.

**Observabilidad**
- [ ] 3 pilares instrumentados: logs estructurados JSON · métricas RED/USE · traces OpenTelemetry.
- [ ] Al menos un SLO declarado para componentes productivos.
- [ ] DORA metrics baseline registrada (DF · LT · CFR · MTTR).
- [ ] Rollback plan documentado y probado al menos una vez.

**Service catalog y cost ops**
- [ ] Componente registrado en service catalog (Backstage / ServiceNow CMDB) — §23.
- [ ] Tags canónicos aplicados (cost-center · env · owner · criticality · offering).
- [ ] Budget + alerta configurada.

**Handoffs**
- [ ] SMEs de `GenAI Projects/Delivery - SME/` declarados como owners reales por fase.
- [ ] Handoff a AMS Reinvention con runbook + on-call rotation antes de cerrar OPERATE.
- [ ] Postmortem ejecutado dentro de 5 días hábiles si hubo incidente P1/P2 (§21).

**Tipografía y tono**
- [ ] Sin emojis, sin clichés GenAI (§12 documento base).
- [ ] Sin diminutivos / aumentativos / juicios de valor (§12.7 documento base).
- [ ] Sin "garantía" en hypercare (regla `feedback_no_garantia_si_hypercare`).

---

## 16. COMPONENT SPECIFICATION STANDARD

Todo componente productivo debe tener su `spec-{component-name}.md` con la estructura siguiente. La sección es **obligatoria** — agentes no producen spec ad-hoc.

### 16.1 Estructura mínima del spec

```markdown
# {component-name} — Component Specification

## Identidad
- **ID**: {prefix}-{NNN}                  ← prefijo por offering (TST/AI/SPE/II/MDP/INN/AMS)
- **Tipo**: {microservicio | modelo ML | pipeline | IaC module | dashboard | runbook | ...}
- **Offering origen**: {01-07 carpeta}
- **State**: [STATE: PROPOSED | APPROVED | ACTIVE | DEPRECATED | SUNSET | ON-HOLD]
- **Fase activa**: [PHASE: DISCOVER | ... | ITERATE]
- **Versión actual**: {semver}
- **Owner técnico**: {persona / equipo en GenAI Projects/Delivery - SME/}
- **Sponsor de negocio**: {rol / persona}

## Propósito
{2-3 frases · qué problema resuelve · para quién}

## Requisitos Funcionales
- RF-01: {requisito + criterio de aceptación medible}
- RF-02: ...

## Requisitos No Funcionales (NFRs)
| NFR | Target | Cómo se mide |
|-----|--------|---------------|
| Disponibilidad | {%} | SLO declarado |
| Latencia | P95 < {ms} | OTEL traces |
| Throughput | {rps} sostenido | Load test |
| Recovery | RTO {hrs} · RPO {hrs} | DR drill |
| Seguridad | Zero High vulns · CIS compliance ≥ 90% | Security pipeline |
| Compliance | {CNBV / PCI-DSS / ISO / DORA / ...} | Audit |

## Interfaces
### Entrantes (consume)
| Tipo | Contrato | Versión | Owner |
|------|----------|---------|-------|
| {REST API · event · file · DB read} | {OpenAPI / AsyncAPI / Avro / SQL contract} | {semver} | {componente / sistema upstream} |

### Salientes (expone)
| Tipo | Contrato | Versión | Consumers |
|------|----------|---------|-----------|
| ... | ... | ... | ... |

## Dependencias
- `[DEPENDS-ON: {componente}]` — {por qué}
- `[DEPENDS-ON: {servicio externo}]` — {SLA esperado}

## Runtime
- **Stack**: {lenguaje / framework / runtime version}
- **Ambiente target**: {Cloud Run / GKE / Lambda / VM / ...}
- **Recursos esperados**: {CPU / memory / replicas / autoscaling policy}
- **Costo estimado mensual**: {USD} · Budget alert at {USD}

## Observabilidad
- **SLOs**: {referencia a SLOs declarados}
- **Métricas custom**: {lista}
- **Alertas críticas**: {lista con severidad y paging}
- **Dashboard**: {URL Grafana / Datadog / Dynatrace}

## Compliance
- **Datos manipulados**: {PII / financial / health / ninguno}
- **Regulación aplicable**: {CNBV / CONDUSEF / DORA / ...}
- **Audit log**: {sí/no + destino}

## ADRs ligados
- [ADR-NNN]: {decisión clave 1}
- [ADR-NNN]: {decisión clave 2}

## Estado del lifecycle
| Fase | Status | Owner | Fecha completada |
|------|--------|-------|-------------------|
| DISCOVER | ✅ COMPLETO | ... | YYYY-MM-DD |
| DESIGN | 🔵 EN CURSO | ... | — |
| ... | ⚪ PENDIENTE | ... | — |
```

### 16.2 Reglas operativas del spec

- Vive en la carpeta del offering (no en un repo separado).
- Se actualiza en **cada cambio de fase** (transición de DISCOVER → DESIGN, etc.).
- Cambios significativos a NFRs o Interfaces se registran como entrada en `delivery-playbook-{offering-slug}.md` (CR log §12.2).
- DoR para BUILD requiere secciones Identidad · Propósito · RF · NFR · Interfaces · Dependencias · Runtime completas.
- DoD para OPERATE requiere todas las secciones + tabla Estado del lifecycle hasta RELEASE completada.

---

## 17. VERSIONING & COMPATIBILITY POLICY

### 17.1 Semantic Versioning (SemVer) obligatorio

Todo componente con interfaces externas usa SemVer `MAJOR.MINOR.PATCH`:

| Tipo de cambio | Incremento | Ejemplo |
|----------------|------------|---------|
| Breaking change (rompe consumers) | **MAJOR** (1.x.x → 2.0.0) | Cambio de schema · eliminación de endpoint · cambio de comportamiento documentado |
| Feature nueva backward-compatible | **MINOR** (1.0.x → 1.1.0) | Endpoint nuevo · campo nuevo opcional · capability nueva |
| Fix o cambio interno transparente | **PATCH** (1.0.0 → 1.0.1) | Bugfix · refactor interno · update de dependencia sin impacto en contract |

Excepción: componentes en `[STATE: PROPOSED]` o `[STATE: APPROVED]` pre-RELEASE viven como `0.y.z` — cualquier cambio puede romper. Al primer release a PROD pasan a `1.0.0`.

### 17.2 API Versioning

| Estrategia | Cuándo usar |
|------------|-------------|
| URI versioning (`/v1/users`) | Default para REST públicas — claridad sobre estabilidad de header |
| Header versioning (`Accept: application/vnd.x.v1+json`) | APIs internas + casos con versionado por contenido |
| Hostname versioning (`v1.api.x.com`) | Migración mayor — solo si el cliente lo demanda |

URI versioning es el default. Header versioning requiere `[ADR]` justificándolo.

### 17.3 Schema Versioning (para datos y eventos)

- **Avro / Protobuf / JSON Schema** con Schema Registry obligatorio para streaming + APIs async.
- **Backward compatibility por default** — productores pueden actualizar sin coordinar con todos los consumers.
- **Breaking schema change** requiere: ADR · nueva versión major · ventana de migración con producers/consumers identificados · plan de coexistencia.

### 17.4 Deprecation Policy

- **Anuncio mínimo: 2 versiones minor** antes del retiro (ej. anunciar deprecation en v1.5 si se retira en v1.7).
- **Header `Sunset` HTTP** activado en endpoints deprecados (RFC 8594).
- **Ventana de migración**: mínimo 6 meses para componentes internos · 12 meses para componentes con consumers externos / cliente.
- **Comunicación**: changelog + correo a consumers identificados + warning en logs cuando consumer usa endpoint deprecado.
- **State del componente** pasa a `[STATE: DEPRECATED]` el día del anuncio. Pasa a `[STATE: SUNSET]` el día del retiro.

### 17.5 Changelog (Keep a Changelog format)

`CHANGELOG.md` obligatorio en repo de cada componente. Formato:

```markdown
# Changelog

## [Unreleased]

## [1.2.0] - 2026-05-26
### Added
- {feature nueva con [REF: PR-NNN]}
### Changed
- {cambio no breaking}
### Deprecated
- {feature anunciado para retiro en v1.4}
### Removed
- {feature retirado tras ventana de deprecation}
### Fixed
- {bugfix}
### Security
- {fix de seguridad con [REF: CVE-NNN] si aplica}
```

Reglas: append-only · cada entry liga a PR/commit · `Unreleased` se vacía al hacer release y el contenido pasa a la nueva sección versionada.

---

## 18. REPOSITORY & BRANCHING STANDARDS

### 18.1 Estrategia de branching default: Trunk-Based Development

| Branch | Uso | Política |
|--------|-----|----------|
| `main` | Trunk — siempre deployable | Protected · requires PR · ≥1 review · status checks verdes · linear history |
| `feature/{id}-{descripción}` | Feature corta (< 3 días vida) | Branch off `main` · rebase + squash merge |
| `hotfix/{id}-{descripción}` | Fix urgente PROD | Branch off `main` · merge a `main` · cherry-pick a release tags si aplica |
| `release/{version}` | Solo si se requiere LTS branch para mantener versión major previa | Excepcional · justificado con ADR |

**GitFlow está prohibido** como default. Solo se acepta con `[ADR]` justificando razones operativas concretas (típicamente: componente con LTS branches activos).

### 18.2 Conventional Commits

Mensajes de commit siguen [Conventional Commits 1.0.0](https://www.conventionalcommits.org/):

```
<type>(<scope opcional>): <descripción>

[body opcional]

[footer opcional con referencias]
```

Tipos permitidos: `feat` · `fix` · `chore` · `docs` · `style` · `refactor` · `perf` · `test` · `build` · `ci`.

Breaking changes se marcan con `!`: `feat!: cambiar formato de response`. El footer incluye `BREAKING CHANGE: descripción`.

### 18.3 Branch Protection (obligatoria en `main`)

- Require pull request reviews before merging — mínimo **1 reviewer humano**.
- Require status checks to pass (CI verde · todos los security gates verdes).
- Require branches to be up to date before merging.
- Require signed commits para componentes críticos.
- Restrict who can push to matching branches (solo CI o admins).
- Require linear history (rebase / squash merge — no merge commits).

### 18.4 Pull Request Standard

Plantilla obligatoria en `.github/PULL_REQUEST_TEMPLATE.md` (o equivalente GitLab/Bitbucket):

```markdown
## Resumen
{1-3 frases}

## Cambios
- {bullet de cambios principales}

## Tipo
- [ ] feat / fix / chore / docs / refactor / perf / test / build / ci

## Breaking Change?
- [ ] No
- [ ] Sí — ver sección Migration Notes

## Checklist DoD
- [ ] Tests automatizados pasando
- [ ] Documentación actualizada (README, runbook, spec si aplica)
- [ ] Changelog actualizado (sección Unreleased)
- [ ] Security gates verdes
- [ ] ADR creado/actualizado si cambia decisión arquitectónica

## Migration Notes (si Breaking)
{instrucciones para consumers}

## Referencias
- Issue: #NNN
- ADR: [ADR-NNN]
- Spec: [spec-{component-name}.md]
```

### 18.5 CODEOWNERS

Archivo `CODEOWNERS` obligatorio en cada repo de componente. Define dueños técnicos por ruta. Owner aprueba automáticamente como reviewer requerido para los archivos bajo su scope.

### 18.6 Monorepo vs Polyrepo

- **Polyrepo** es el default — un repo por componente entregable.
- **Monorepo** solo se acepta con `[ADR]` cuando: (a) el offering tiene > 10 componentes muy acoplados con CI/CD cross-componente, (b) hay herramientas (Nx, Turborepo, Bazel) instaladas para soportar el patrón. Casos típicos: IDP, frontend platform con micro-frontends.

---

## 19. CI/CD PIPELINE REFERENCE

Pipeline canónica que todo componente productivo implementa. Las etapas son **obligatorias** en orden; los gates dentro de cada etapa son **bloqueantes**.

### 19.1 Stages canónicos

```
PR open / push to main
        │
        ▼
┌────────────────┐
│ 1. VALIDATE    │   Lint · format check · type check · commit message check
└────────────────┘
        │
        ▼
┌────────────────┐
│ 2. SECURITY    │   SAST · SCA · secrets-scan · IaC-scan (paralelizados)
└────────────────┘
        │
        ▼
┌────────────────┐
│ 3. BUILD       │   Compile · package · container build (si aplica) · container-scan
└────────────────┘
        │
        ▼
┌────────────────┐
│ 4. TEST UNIT   │   Unit tests + coverage report · target cobertura del offering
└────────────────┘
        │
        ▼
┌────────────────┐
│ 5. TEST INTEG. │   Integration tests · contract tests (Pact / Schema Registry)
└────────────────┘
        │
        ▼
┌────────────────┐
│ 6. PUBLISH     │   Push artifact al registry (Artifact Registry / ECR / ACR / GAR)
└────────────────┘   con tag inmutable (commit SHA + semver)
        │
        ▼
┌────────────────┐
│ 7. DEPLOY DEV  │   Auto-deploy a DEV con artifact recién publicado
└────────────────┘
        │
        ▼  (sobre tag release)
┌────────────────┐
│ 8. DEPLOY QA   │   Deploy a QA + smoke tests + tests E2E automatizados
└────────────────┘
        │
        ▼  (manual gate o auto si trunk-based maduro)
┌────────────────┐
│ 9. DEPLOY STG  │   Deploy a STG + DAST + performance test + pre-PROD validation
└────────────────┘
        │
        ▼  (CAB approval si aplica)
┌────────────────┐
│ 10. DEPLOY PROD│   Canary / Blue-Green / Rolling — según release strategy del offering
└────────────────┘
        │
        ▼
┌────────────────┐
│ 11. POST-DEPLOY│   Smoke tests en PROD · SLO health check · alerta on-call · changelog publish
└────────────────┘
```

### 19.2 Reglas de pipeline

- **Artifact promotion, no rebuild**: el binary/image que pasó QA es el mismo que va a PROD. Promotion = retag + redeploy del mismo digest.
- **Stages 1-7 corren en cada PR** (validación + tests). Solo `main` puede activar stages 8+ por default.
- **Paralelización**: stages 2 (security scans), 5 (integration tests por suite), 8-9 (deploys por región) deben paralelizarse cuando aplique.
- **Lead Time del PR**: target P95 < 30 min desde push hasta deploy DEV. Si supera, refactorizar tests o paralelizar.
- **Fail-fast**: cualquier stage falla → pipeline aborta · status check rojo · merge bloqueado en PR.

### 19.3 Herramientas canónicas por plataforma

| Plataforma | CI/CD nativo | Notas |
|------------|--------------|-------|
| GitHub | GitHub Actions | Default · matrix builds · OIDC para deploy sin secrets |
| GitLab | GitLab CI/CD | Para self-hosted o cliente con GitLab |
| GCP | Cloud Build · Cloud Deploy | Si proyecto es GCP-native con poca interacción externa |
| AWS | CodeBuild · CodePipeline | Selectivo · GitHub Actions con OIDC suele ser mejor |
| Azure | Azure DevOps Pipelines | Si cliente exige Azure DevOps |
| GitOps deployments | ArgoCD · Flux | Default para K8s — el git repo es la fuente de verdad del estado deseado |

### 19.4 Secrets en pipeline

- **OIDC + workload identity** sobre credenciales estáticas siempre que el cloud provider lo soporte.
- **Secrets Manager / Vault** para casos donde OIDC no aplique.
- Cero secrets en variables de entorno del job de CI excepto referencias a Secret Manager.

---

## 20. COMPONENT LIFECYCLE STATE — Gobierno macro

La fase SDLC (§2) describe **el trabajo activo del componente**. El estado (§3.8) describe **dónde vive el componente en su ciclo macro**. Ambos coexisten — un componente puede estar en `[STATE: DEPRECATED]` y aún tener fase `[PHASE: OPERATE]`.

### 20.1 Transiciones permitidas

```
PROPOSED ──→ APPROVED ──→ ACTIVE ──→ DEPRECATED ──→ SUNSET
   │             │           │           │
   └─→ ON-HOLD ←─┘           │           │
                             └─────→ ON-HOLD (regulatorio · presupuesto)
```

- `PROPOSED → APPROVED`: requiere DoR completo + sponsor de negocio + approval del Offering Manager.
- `APPROVED → ACTIVE`: requiere DoD completo (todos los criterios §2.2 + específicos del offering).
- `ACTIVE → DEPRECATED`: requiere sucesor designado (o decisión explícita de no reemplazar) + plan de migración + ventana de deprecation publicada.
- `DEPRECATED → SUNSET`: requiere ventana de deprecation cumplida + consumers migrados (o forzados a migrar) + decommission plan ejecutado.
- `ON-HOLD`: pausado por razón externa (regulatorio, presupuesto, priorización). Requiere fecha estimada de re-evaluación.

Transición no permitida: `DEPRECATED → ACTIVE`. Si el componente se "des-deprecaría" requiere razón documentada + nueva versión MAJOR + nuevo ciclo de RELEASE.

### 20.2 Reglas operativas por estado

| Estado | Aceptar features nuevas | Aceptar bugfixes | Aceptar consumers nuevos | Reportar SLO |
|--------|--------------------------|-------------------|---------------------------|---------------|
| PROPOSED | — | — | — | — |
| APPROVED | — (todavía no en PROD) | — | — | — |
| ACTIVE | Sí | Sí | Sí | Sí |
| DEPRECATED | No (solo bugfixes críticos) | Solo críticos | **No** | Sí |
| SUNSET | No | No | No | No |
| ON-HOLD | No | No | No | No |

### 20.3 Registro del estado

El estado del componente vive en su `spec-{component-name}.md` (sección Identidad). Cambios de estado son **eventos auditables** — se registran como entrada en el `delivery-playbook-{offering-slug}.md` (CR log §12.2) con tipo `STATE-CHANGE`.

---

## 21. POSTMORTEM & CONTINUOUS LEARNING

### 21.1 Trigger obligatorio

Todo incidente **P1 o P2** dispara postmortem dentro de **5 días hábiles** post-resolución. Incidentes P3/P4 disparan postmortem **si**: se repitieron > 2 veces en 30 días, expusieron debt arquitectónica, o el cliente lo solicita.

### 21.2 Cultura blameless

El postmortem se enfoca en **sistema y proceso, no en personas**. Reglas:
- No se nombran personas como causa raíz — se nombran **decisiones**, **procesos** y **condiciones del sistema**.
- "Quién hizo X" se reformula como "El proceso permitía / requería X" o "La herramienta facilitaba X".
- Action items van a **mejora estructural** (herramienta, proceso, guardrail) no a "más cuidado".

### 21.3 Template canónico

`postmortem-{component-name}-{INC-NNN}.md` en el repo del componente:

```markdown
# Postmortem — INC-NNN · {título corto}

## Resumen ejecutivo
- **Componente**: {component-name}
- **Severidad**: P1 / P2
- **Duración del impacto**: {desde - hasta}
- **Impacto al cliente**: {usuarios afectados · transacciones perdidas · downtime · revenue}
- **Root cause categoría**: {bug · config · infra · upstream · proceso · capacidad}

## Timeline
| Hora (TZ) | Evento |
|-----------|--------|
| HH:MM | Alerta dispara |
| HH:MM | On-call acknowledge |
| HH:MM | Diagnóstico inicial |
| HH:MM | Mitigación aplicada |
| HH:MM | Servicio restaurado |
| HH:MM | Communication interna cerrada |

## Detection
- ¿Cómo se detectó? {alerta · cliente · monitoreo · runbook drill}
- ¿Tiempo desde inicio del impacto a detección? {minutos}
- ¿Era detectable antes? {sí / no — explicar}

## Mitigación
- ¿Qué acción restauró el servicio? {específico}
- ¿Por qué funcionó esa acción?
- ¿Estaba documentada en runbook? {sí / no — si no, gap a registrar}

## Root Cause Analysis (5 Whys o equivalente)
1. ¿Por qué pasó X? — Y.
2. ¿Por qué Y? — Z.
3. ...

## Contributing Factors
- {Factor 1 — explicar}
- {Factor 2 — explicar}

## Lo que funcionó bien
- {Reconocer prácticas / herramientas / decisiones que limitaron el impacto}

## Lo que no funcionó
- {Procesos / herramientas / decisiones que amplificaron o no detectaron a tiempo}

## Action Items
| ID | Acción | Owner | Due date | Tipo |
|----|--------|-------|----------|------|
| AI-001 | {acción concreta} | {persona/equipo} | YYYY-MM-DD | PREVENT / DETECT / MITIGATE |

## Lessons Learned
{2-4 frases que se llevarán al pattern library / runbook library}
```

### 21.4 Seguimiento de Action Items

Los action items del postmortem se trackean en un sistema (Jira / ServiceNow tasks / GitHub issues) con label `postmortem-AI`. **No se cierra el postmortem hasta que todos los AI estén ejecutados o re-priorizados con razón documentada**.

### 21.5 Publicación

Postmortems son **internos al equipo + AMS Reinvention + offering origen**. Lecciones que generalizan se exportan al `pattern-library` de Innovation o al `runbook-library` del offering.

---

## 22. API-FIRST / CONTRACT-FIRST DEVELOPMENT

### 22.1 Principio

Todo componente con interface externa **declara el contrato antes de empezar BUILD**. El contrato es ejecutable, no descriptivo. Sin contrato verificable, el componente no avanza más allá de DESIGN.

### 22.2 Standards de contrato por tipo de interface

| Tipo de interface | Standard de contrato |
|-------------------|----------------------|
| REST API síncrona | **OpenAPI 3.1** versionado en repo |
| API async / event-driven | **AsyncAPI 2.6** + Schema Registry (Avro / JSON Schema) |
| gRPC / streaming | **Protobuf 3** con buf.build registry |
| GraphQL | **SDL** (Schema Definition Language) versionado |
| Pipeline de datos (consumer) | **dbt contracts** + Schema Registry para sources |
| Modelo ML | **MLOps signature** (Vertex AI Model Schema / MLflow signature) |

### 22.3 Reglas operativas

- **Contract antes de código**: el archivo de contrato existe en el repo y pasa validación antes de escribir el primer endpoint productivo.
- **Contract tests** (Pact, OpenAPI validation, Schema Registry compatibility checks) corren en CI — bloquean merge si contrato y código divergen.
- **Mock server desde contrato** — consumers pueden empezar a desarrollar contra el mock sin esperar al componente real.
- **Cambios al contrato** siguen política de versioning (§17) — breaking change → nueva versión MAJOR + ventana de migración.
- **Documentación auto-generada** desde el contrato (Swagger UI / Redoc / AsyncAPI Studio) — nunca documentación escrita a mano divergente.

### 22.4 Validación

Antes de cerrar DESIGN:
- [ ] Contrato existe en repo (`openapi.yaml` / `asyncapi.yaml` / `*.proto` / etc.).
- [ ] Contrato valida sintácticamente (CI verde con `spectral lint`, `buf lint`, etc.).
- [ ] Mock server desde contrato corre y responde ejemplos.
- [ ] Consumers identificados firman que el contrato cubre su caso de uso.

---

## 23. SERVICE DISCOVERABILITY & CATALOG

### 23.1 Principio

Un componente productivo sin entrada en service catalog **no existe institucionalmente** — otros equipos lo reimplementarán por desconocimiento. Registro en service catalog es DoD (DoD-11).

### 23.2 Plataforma canónica por cliente

| Cliente / contexto | Catálogo canónico |
|---------------------|---------------------|
| ServiceNow-heavy | ServiceNow CMDB + Application Service mapping |
| Cloud-native + multi-team | **Backstage** (open source, recomendado para deals greenfield) |
| ITIL-heavy + legacy | ServiceNow CMDB con CMDB Health enforcement |
| Mainframe + IBM Power presente | Combinación CMDB + custom inventory |

### 23.3 Metadata mínima por componente registrado

| Campo | Valor |
|-------|-------|
| Name | {component-name canónico} |
| Type | {service · library · datastore · pipeline · model · IaC module · runbook · dashboard} |
| Offering | {01-07} |
| Owner team | {squad / equipo en GenAI Projects/Delivery - SME/} |
| Tech contact (on-call) | {persona / rotation alias} |
| Business contact | {sponsor / PO} |
| Lifecycle state | {PROPOSED · APPROVED · ACTIVE · DEPRECATED · SUNSET · ON-HOLD} |
| Tier / criticality | {1 / 2 / 3 / 4 según política del cliente} |
| Dependencies | {upstream services} |
| Consumers | {downstream services} |
| Repository | {URL Git} |
| Documentation | {URL spec + README + runbook} |
| Observability | {URL dashboards · SLOs} |
| API docs (si aplica) | {URL OpenAPI/AsyncAPI rendered} |
| Compliance tags | {CNBV · PCI-DSS · ISO · DORA} |

### 23.4 Sync automatizada

El catálogo se sincroniza desde fuente de verdad (repo Git + tags cloud + service mesh) automáticamente. Manual entries son antipattern — quedan stale.

- **Backstage**: catalog-info.yaml en raíz del repo del componente. Backstage discovers via GitHub/GitLab provider.
- **ServiceNow CMDB**: Discovery + Service Mapping (ITOM Specialist) descubren CIs y relaciones desde infra real.

### 23.5 Health del catálogo

Métrica universal: **% de componentes ACTIVE con metadata completa y sincronizada en últimos 7 días**. Target ≥ 95%. Componentes que caen debajo de ese umbral se reportan como `[CATALOG-DEBT]` en el `delivery-playbook` del offering.

---

*Última actualización: 2026-05-27 · v2.1 · Agregadas §16-§23 (Component Spec Standard · Versioning · Repo & Branching · CI/CD Pipeline · Component Lifecycle State · Postmortem · API-First · Service Discoverability). DoD universal extendido a 13 criterios. Security gates con shift-left explícito. Onboarding diferenciado por modo. Outputs separados offering vs componente.*
