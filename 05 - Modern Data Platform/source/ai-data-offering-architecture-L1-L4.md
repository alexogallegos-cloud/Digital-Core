# AI & Data — Offering Architecture L1-L4 (slide oficial Accenture)

> Fuente: slide "AI & Data: Offering architecture L1-L4" del Digital Core Offering Domain (Accenture).
> Capturado 2026-05-31. Es la **taxonomía canónica** que gobierna la estructura de sub-offerings de este offering.
> Honestidad de datos: transcripción literal del slide. No inferir ni completar columnas vacías.

---

## Jerarquía

| Nivel | Etiqueta del slide | Valor |
|-------|--------------------|-------|
| **L1** | RP | **Digital Core** |
| **L2** | Offering Domain | **Scaled AI Foundation** · **AI-ready Data** |
| **L3** | Sub Offering | ver tablas abajo |
| **L4** | Solution | ver tablas abajo |

**Reconciliación con la estructura del repo Digital Core:**

El repo tiene 7 offerings bajo Digital Core. Los offering domains del slide se realizan COMO carpetas de domain DENTRO del offering correspondiente:

- `05 - Modern Data Platform/` es el **offering** (L1 del repo). Dentro vive el **offering domain `AI-ready Data/`**, que agrupa los 4 sub-offerings L3. Estructura:
  ```
  05 - Modern Data Platform/        (offering)
  └─ AI-ready Data/                  (offering domain)
     ├─ Data Migration/             (sub-offering L3)
     ├─ Data Modernization/         (sub-offering L3)
     ├─ Knowledge Engineering Services/ (sub-offering L3)
     └─ Data Managed Services/      (sub-offering L3)
  ```
- `02 - AI Enabled Enterprise/` aloja el **offering domain Scaled AI Foundation**. *(Pendiente de reconciliar cuando se trabaje el offering 02.)*

NOTA: "Modern Data Platform" (offering) NO equivale a "AI-ready Data" (offering domain) — el domain es un nivel intermedio dentro del offering. El slide agrupa Scaled AI Foundation + AI-ready Data bajo el título "AI & Data"; en este repo esos dos domains se reparten entre los offerings 02 y 05 respectivamente.

---

## L2: AI-ready Data → Sub-Offerings (L3) y Solutions (L4)

### L3 — Data Migration
> *Migration of legacy data estate to new target platforms using AI/Agents; getting data ready for AI in a fraction of the time.*

L4 Solutions:
- AI-Accelerated Migration
- Data Product Factory

### L3 — Data Modernization
> *Modernization of data estates powered by industry data products and data federated closer to LoBs using AI/Agents.*

L4 Solutions:
- Data Products & Strategy
- AI for BI (AI4BI)
- Data Agents
- Txn & Realtime Data Modernization

### L3 — Knowledge Engineering Services
> *Build knowledge layer encompassing semantic & ontologies to turn raw data into contextualized enterprise knowledge.*

L4 Solutions:
- Knowledge Agents
- Scaled ontology creation

### L3 — Data Managed Services
> *Operate data and knowledge as a long-term service using AI/Agents.*

L4 Solutions:
- Data Ops
- Data to Knowledge Ops
- Autonomous BI Ops
- AI Lifecycle Management

---

## L2: Scaled AI Foundation → Sub-Offerings (L3) y Solutions (L4)
> Pertenece al offering **02 AI Enabled Enterprise**. Se transcribe aquí solo por completitud del slide; NO se desarrolla bajo Modern Data Platform.

### L3 — Core Excavation
> *See what's buried in the code and the process. AI-driven extraction of legacy complexity and institutional knowledge.*
L4: Code Archaeology · Institutional Archaeology

### L3 — AI Architecture Foundation
> *Mapping AI architecture to enterprise architecture — where AI should observe, decide, and act vs. where deterministic guarantees hold.*
L4: Agentic DMZ · AI-Native Architecture Design · Trust Engineering · Core System + IDB / Core System + Ontology Activation

### L3 — Agentcraft
> *Agents for the core. Design and deploy agents in compliance-heavy, latency-sensitive, failure-intolerant environments.*
L4: Agent Design · Agent Development & Deployment

### L3 — Living Ontologies
> *Queryable enterprise knowledge & memory optimized to learn, evolve, and solve specific business problems unsolvable in the pre-AI era.*
L4: Business Problem-Applied Enterprise Knowledge (leveraging Knowledge Engineering) · AI-Native Pattern Discovery · Challengers