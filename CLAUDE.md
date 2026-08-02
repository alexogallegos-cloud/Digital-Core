# Digital Core — Ecosistema de Component Delivery Agents (Accenture México)
> Este archivo es cargado automáticamente por Claude en todas las carpetas del proyecto.
> Define el contexto raíz del ecosistema Digital Core y activa las reglas universales `AGENTES-UNIVERSAL-RULES-DC.md`.

---

## REGLAS UNIVERSALES

**Lee y aplica `AGENTES-UNIVERSAL-RULES-DC.md`** antes de responder cualquier solicitud en este ecosistema.

Ese documento define, para todos los Component Delivery Agents:
- Herencia respecto a `AGENTES-UNIVERSAL-RULES.md` del ecosistema `Solutioning/`
- SDLC canónico de 8 fases (DISCOVER → DESIGN → BUILD → TEST → RELEASE → OPERATE → OBSERVE → ITERATE)
- Definition of Ready (DoR) y Definition of Done (DoD) universal
- Vocabulario propio de delivery (componente, blueprint, artifact, gate, environment, SLO, DORA, runbook, ADR)
- Modos de operación alineados a fase SDLC (REQUIREMENTS · BUILD · RELEASE · RUN)
- Protocolo de handoff cross-ecosystem hacia los SMEs de `SME/`
- Outputs canónicos (component-catalog, reference-architecture, delivery-playbook, quality-gates, runbooks, ADRs)
- Quality gates entry/exit por fase, security gates, observability standards, métricas DORA
- Coordinación entre los 7 offerings vía dependencias de delivery (no portafolio)

Si el `CLAUDE.md` de un offering contradice una regla universal de Digital Core, el `CLAUDE.md` del offering prevalece para ese punto específico.

---

## QUÉ ES ESTE ECOSISTEMA

`Digital Core/` es un ecosistema **independiente** de **agentes de delivery de componentes de tecnología** que entregan a producción siguiendo el SDLC end-to-end. Cada uno de los 7 offerings gobierna el lifecycle de un tipo específico de componente:

| Offering | Tipo de componente que entrega | Lifecycle variant |
|----------|-------------------------------|-------------------|
| 01 TS&T | Architecture artifacts, blueprints, decision records | Arch Lifecycle |
| 02 AI Enabled Enterprise | AI/ML models, GenAI agents, prompts, evaluaciones | **MLOps** |
| 03 Software & Platform Engineering | Microservicios, frontends, APIs, integraciones | **DevOps classic** |
| 04 Intelligent Infrastructure | IaC modules, Landing Zones, networks, compute | **GitOps + IaC** |
| 05 Modern Data Platform | Pipelines, data marts, contracts, data models | **DataOps** |
| 06 Innovation | PoCs, prototypes, pattern libraries | **PoC Lifecycle** |
| 07 AMS Reinvention | Runbooks, automations, observability assets, AIOps signals | **AIOps + ITIL** |

**Frontera con `Solutioning/`**:
- Digital Core/ **gobierna el lifecycle** del componente — fases, gates, DoD, reference architecture, observability standards.
- SME/ **ejecuta el delivery operativo** — código, IaC, modelo, pipeline concreto.
- Cada Component Delivery Agent declara prescriptivamente qué SME(s) de `Solutioning/` ejecutan cada fase de su lifecycle.

**No hay frontera con propuestas y deals** — ese es territorio exclusivo de `Solutioning/Solutioning - *`. Digital Core opera sobre componentes técnicos en construcción y operación, no sobre pipeline comercial.

---

## LOS 7 OFFERINGS — ORDEN CANÓNICO

| # | Carpeta | Offering | Lifecycle variant | Mantra |
|---|---------|----------|-------------------|--------|
| 1 | `01 - TS&T/` | Technology Strategy & Transformation | Arch Lifecycle | TS&T defines direction |
| 2 | `02 - AI Enabled Enterprise/` | AI Enabled Enterprise | MLOps | AI drives outcomes |
| 3 | `03 - Software & Platform Engineering/` | Software & Platform Engineering | DevOps classic | Engineering builds |
| 4 | `04 - Intelligent Infrastructure/` | Intelligent Infrastructure | GitOps + IaC | Infrastructure runs |
| 5 | `05 - Modern Data Platform/` | Modern Data Platform | DataOps | Data enables trust |
| 6 | `06 - Innovation/` | Innovation | PoC Lifecycle | Innovation explores |
| 7 | `07 - AMS Reinvention/` | AMS Reinvention | AIOps + ITIL | AMS reinvents continuously |

**Mantra transversal**: *Ecosystem Partners amplify* — partners (AWS, Microsoft, Google, SAP, Salesforce, ServiceNow, Oracle, IBM, etc.) se materializan en el stack tecnológico de referencia de cada offering, no como agente propio.

---

## ESTRUCTURA DEL ECOSISTEMA

```
Digital Core/
├── CLAUDE.md                                       ← este archivo (raíz)
├── AGENTES-UNIVERSAL-RULES-DC.md                   ← reglas universales (delivery SDLC)
├── CLAUDE-TEMPLATE-DC.md                           ← plantilla canónica de Component Delivery Agent
├── 01 - TS&T/
│   ├── CLAUDE.md                                   ← Component Delivery Agent — Arch Lifecycle
│   ├── component-catalog-tst.md
│   ├── reference-architecture-tst.md
│   ├── delivery-playbook-tst.md
│   ├── quality-gates-tst.md
│   └── adr/
├── 02 - AI Enabled Enterprise/                     ← MLOps
├── 03 - Software & Platform Engineering/           ← DevOps classic
├── 04 - Intelligent Infrastructure/                ← GitOps + IaC
├── 05 - Modern Data Platform/                      ← DataOps
├── 06 - Innovation/                                ← PoC Lifecycle
└── 07 - AMS Reinvention/                           ← AIOps + ITIL
```

Outputs canónicos por offering: `component-catalog-{slug}.md`, `reference-architecture-{slug}.md`, `delivery-playbook-{slug}.md`, `quality-gates-{slug}.md`, `component-spec-template-{slug}.md`. Por componente real: `spec-{component-name}.md`, `runbook-{component-name}.md`, `incident-log-{component-name}.md`, `adr/{NNN}-{título}.md`.

---

## CONTEXTO DE NEGOCIO

- **Organización**: Accenture México — Technology, Digital Core
- **Usuario**: alejandro.gallegos@accenture.com
- **Industrias objetivo**: Servicios financieros (banca, wealth, seguros), aerolíneas, hospitalidad, retail
- **Geografía**: México y LATAM
- **Monedas de trabajo**: MXN y USD
- **Regulación relevante por default**: CNBV, Banxico, CONDUSEF (México), DORA (grupos europeos), PCI-DSS, ISO 27001, SOC 2

---

## RELACIÓN CON `Solutioning/`

| Dimensión | Digital Core/ | Solutioning/ |
|-----------|---------------|------------------|
| Foco | Lifecycle del componente técnico | Delivery del deal comercial |
| Tiempo | Sprints / releases / SLOs | Stages S0→S3 / gates / commitments |
| Output | Component catalog · reference arch · runbooks · ADRs · DORA metrics | DIP · propuesta · solution plan · contrato |
| Audiencia | Arquitectos · Devs · SREs · Owners de componentes | Account Lead · Solution Architect · Cliente comercial |
| Modo de entrega | Componente en producción cumpliendo DoD | Deal firmado entrando a delivery |

**Ruta cross-ecosystem**:
- Reglas universales base (comunes): capa COMÚN `../AGENTES-UNIVERSAL-RULES-CORE.md`, heredada por Digital Core vía `AGENTES-UNIVERSAL-RULES-DC.md`
- SMEs ejecutores de delivery: `c:\...\Solutioning\SME\`
- Showcase visual del Digital Core: `c:\...\Solutioning\Delivery - Showcase\Showcase - Digital Core\`

Cada Component Delivery Agent declara prescriptivamente la lista de SMEs de `SME/` que ejecutan cada fase de su lifecycle. Esa lista vive en la sección "Handoffs Canónicos hacia Solutioning" del `CLAUDE.md` del offering.

---

## CONVENCIÓN DE ARCHIVOS CANÓNICOS

| Tipo de artefacto | Nombre canónico |
|-------------------|-----------------|
| Plantilla canónica de Component Delivery Agent | `CLAUDE-TEMPLATE-DC.md` (raíz) |
| Component catalog (catálogo vivo del offering) | `component-catalog-{offering-slug}.md` |
| Reference architecture del offering | `reference-architecture-{offering-slug}.md` |
| Delivery playbook (SDLC variant + change log) | `delivery-playbook-{offering-slug}.md` |
| Quality gates + DoD del offering | `quality-gates-{offering-slug}.md` |
| Component spec template (para nuevos componentes) | `component-spec-template-{offering-slug}.md` |
| Spec por componente real | `spec-{component-name}.md` |
| Architectural Decision Record | `adr/{NNN}-{título}.md` |
| Runbook operacional por componente | `runbook-{component-name}.md` |
| Test strategy por componente | `test-strategy-{component-name}.md` |
| Release notes por versión de componente | `release-notes-{component-name}-{version}.md` |
| Incident log por componente productivo | `incident-log-{component-name}.md` |

Nunca crear archivos alternativos ni paralelos a los canónicos existentes.

**Creación de offering o sub-agente nuevo:** copiar `CLAUDE-TEMPLATE-DC.md` como `CLAUDE.md` en la carpeta destino y completar los placeholders. El template incluye checklist de calidad obligatorio antes de entregar.

---

*Última actualización: 2026-05-26 · v2.0 · Pivote a Component Delivery Agents con SDLC end-to-end. Sustituye la v1.0 portfolio-only.*
