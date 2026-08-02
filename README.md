# Digital Core

Ecosistema de **Component Delivery Agents** de Accenture México (Technology, Digital Core). Cada offering gobierna el lifecycle end-to-end (SDLC de 8 fases) de un tipo específico de componente técnico, desde DISCOVER hasta ITERATE.

> Ecosistema independiente. Las reglas operativas de los agentes viven en `AGENTES-UNIVERSAL-RULES-DC.md` y el contexto raíz en `CLAUDE.md`.

---

## Los 7 offerings

| # | Carpeta | Offering | Lifecycle variant |
|---|---------|----------|-------------------|
| 1 | `01 - TS&T/` | Technology Strategy & Transformation | Arch Lifecycle |
| 2 | `02 - AI Enabled Enterprise/` | AI Enabled Enterprise | MLOps |
| 3 | `03 - Software & Platform Engineering/` | Software & Platform Engineering | DevOps classic |
| 4 | `04 - Intelligent Infrastructure/` | Intelligent Infrastructure | GitOps + IaC |
| 5 | `05 - Modern Data Platform/` | Modern Data Platform | DataOps |
| 6 | `06 - Innovation/` | Innovation | PoC Lifecycle |
| 7 | `07 - AMS Reinvention/` | AMS Reinvention | AIOps + ITIL |

SDLC canónico: **DISCOVER → DESIGN → BUILD → TEST → RELEASE → OPERATE → OBSERVE → ITERATE**.

---

## Estructura del repositorio

```
Digital Core/
├── CLAUDE.md                          ← contexto raíz del ecosistema
├── AGENTES-UNIVERSAL-RULES-DC.md      ← reglas universales (delivery SDLC)
├── CLAUDE-TEMPLATE-DC.md              ← plantilla canónica de Component Delivery Agent
├── 01 - TS&T/  …  07 - AMS Reinvention/   ← un Component Delivery Agent por offering
└── site/                              ← sitio estático público (S3 + CloudFront)
```

Outputs canónicos por offering: `component-catalog-{slug}.md`, `reference-architecture-{slug}.md`, `delivery-playbook-{slug}.md`, `quality-gates-{slug}.md`. Por componente real: `spec-*.md`, `runbook-*.md`, `adr/{NNN}-*.md`.

El contenido más desarrollado hoy es **03 Software & Platform Engineering → High Velocity Modernization → Mainframe Modernization**, incluido el lab de codebase sintético y el specialist de Reverse Engineering.

---

## Sitio estático (`site/`)

Publica las metodologías y entregables, offering por offering, vía CloudFront sobre un bucket S3 privado (acceso OAC). Ver [`site/README.md`](site/README.md) para detalle de rebuild, infraestructura Terraform y despliegue.

```bash
python site/_build.py          # regenera el contenido desde el árbol de agentes
cd site/infra && terraform init && terraform apply -var="suffix=ago-2026"
```

> El estado de Terraform (`*.tfstate`), los plugins (`.terraform/`) y los `*.tfvars` están excluidos vía `.gitignore`. El `.terraform.lock.hcl` sí se versiona.

---

## Relación con `Solutioning/`

Digital Core **gobierna el lifecycle** del componente (fases, gates, DoD, reference architecture, observability). El ecosistema hermano `SME/` **ejecuta el delivery operativo** (código, IaC, modelo, pipeline concreto). Cada Component Delivery Agent declara prescriptivamente qué SMEs ejecutan cada fase en la sección "Handoffs Canónicos hacia Solutioning" de su `CLAUDE.md`.

El pipeline comercial (DIP, propuestas, solution plans, deals) es territorio exclusivo de `Solutioning/Solutioning - *`, fuera del alcance de este repositorio.

---

## Contexto

- **Organización:** Accenture México — Technology, Digital Core
- **Industrias objetivo:** servicios financieros (banca, wealth, seguros), aerolíneas, hospitalidad, retail
- **Geografía:** México y LATAM
- **Regulación de referencia:** CNBV, Banxico, CONDUSEF, DORA, PCI-DSS, ISO 27001, SOC 2

---

*Cómo crear un offering o sub-agente nuevo:* copiar `CLAUDE-TEMPLATE-DC.md` como `CLAUDE.md` en la carpeta destino y completar los placeholders (incluye checklist de calidad obligatorio).