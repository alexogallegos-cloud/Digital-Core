# Coppel Retail — Component Delivery Agent
> Agente de delivery para el ecosistema eCommerce de Grupo Coppel (Tiendas Coppel).
> Hereda las reglas universales del ecosistema Digital Core.

---

## CONTEXTO DEL CLIENTE

**Cliente**: Grupo Coppel — Unidad Retail (Tiendas Coppel)
**Contacto**: alejandro.gallegos@accenture.com
**Industria**: Retail + eCommerce (México y Argentina)
**Segmento objetivo**: C, D, E — mercado masivo y sub-bancarizado

### Las 3 unidades del Grupo

| Unidad | Negocio | Digital Brain |
|--------|---------|---------------|
| **Tiendas Coppel** | Retail — ropa, electrónicos, muebles | **Este agente** |
| BanCoppel | Banco — crédito, TDC, nómina | `AM/BanCoppel/` |
| Afore Coppel | Ahorro para el retiro | Fuera de scope actual |

**Relación crítica**: La base de clientes de BanCoppel = compradores a crédito de Coppel. El MDM ATLAS (GCP/AlloyDB) es compartido por las 3 unidades → Golden Record unificado.

---

## ENGAGEMENTS ACTIVOS

### 1. Managed Services N3 — eCommerce
- **ID**: Sin MMS ID asignado
- **Stage**: S0 — propuesta entregada 2026-08-06
- **Modelo**: Pure N3 (Coppel absorbe N1/N2; Accenture solo N3)
- **Sizing**: 4.5 FTE Año 1 / 4.0 FTE Año 2+
- **Carpeta**: `Solutioning/Proposals - Clients/Coppel/Managed Services N3/`
- **Incumbente**: Publicis Sapient (2+ años, MTTR 20 días — no cumple SLA P1 de 5 días)
- **Win theme**: Accenture como guardian de la migración Composable — conoce el destino

### 2. FinOps Operating Model
- **Stage**: Propuesta entregada, en seguimiento
- **Carpeta**: `Solutioning/Proposals - Clients/Coppel/FinOps Op Model/`

---

## DIGITAL BRAIN

El Digital Brain de Coppel Retail vive en:

```
systems/core/ecommerce/
├── digital-brain/
│   ├── brain.db          ← SQLite (gitignored) — regenerar con build-brain.py
│   ├── brain.py          ← CoppelRetailBrain API
│   └── build-brain.py    ← Pipeline de construcción
├── generators/
│   └── build-portal.py   ← Genera portal/index.html
├── portal/
│   └── index.html        ← NUNCA editar directamente — siempre regenerar
├── dt/
│   ├── dt-historia-grupo-coppel.md     ← Historia y ADN del Grupo
│   ├── dt-landscape-ecommerce-mx.md    ← Landscape eCommerce México
│   ├── dt-plataforma-as-is.md          ← Estado AS-IS de Coppel.com
│   └── dt-transformacion-composable.md ← Transformación Composable
└── knowledge-base/
```

### Regla de oro — Portal HTML

`portal/*.html` NUNCA se edita a mano. Siempre regenerar:

```bash
# Desde la raíz del proyecto Coppel/
PYTHONUTF8=1 python systems/core/ecommerce/digital-brain/build-brain.py --reset
PYTHONUTF8=1 python systems/core/ecommerce/generators/build-portal.py
```

### Usar el Brain desde Python

```python
from systems.core.ecommerce.digital_brain.brain import CoppelRetailBrain

with CoppelRetailBrain() as brain:
    print(brain.summary())
    print(brain.risks('critical'))
    print(brain.capabilities(domain='ecommerce'))
    print(brain.search('apollo federation'))
```

---

## STACK TECNOLÓGICO COPPEL.COM

### Plataforma AS-IS (en transición)

| Capa | Tecnología | Estado |
|------|-----------|--------|
| Frontend | Next.js + Akamai CDN | Activo (destino) |
| API | Apollo Federation (6 subgraphs) + Apigee | Activo |
| Commerce | SFCC APIs headless + HCL Commerce (legado) | Migrando |
| Search/PIM | LucidWorks | Activo/Migrando |
| Pagos | eGlobal (PCI scope) | Activo |
| Backend | Node.js, Go, Java, Python (100+ servicios GKE) | Activo |
| DB | MongoDB, PostgreSQL, Firestore, Redis | Activo |
| Infra | 14 GKEs en GCP (3 zonas, auto-scaling) | Activo |
| Observabilidad | Datadog (nivel 4 — solo lectura para N3) | Activo |
| ITSM | InvGate → Salesforce (en migración) | Migrando |

### Los 5 Proyectos GCP

| Proyecto | Propósito | Estado |
|----------|-----------|--------|
| `cpl-ec-hcl-be-prod` | HCL Commerce legacy (150+ servicios) | Migrando/deprecando |
| `cpl-ec-dcplig-prod` | Composable Commerce (Next.js + Apollo) | Activo, creciendo |
| `cpl-ec-app-be-prod` | App móvil backend (iOS/Android) | Activo |
| `cpl-ec-sfcc-prod` | SFCC APIs headless | Activo |
| `cpl-ec-pci-tdc-prod` | Pagos PCI-DSS (eGlobal) | Activo, restringido |

---

## KPIs Y SLAS

| KPI | Valor | Fuente |
|-----|-------|--------|
| Impacto por minuto indisponible | $180,000 MXN | Q&A MS N3 |
| Tickets N3 steady state | 15/mes | Q&A MS N3 |
| Tickets N3 temporada alta | 20-25/mes | Q&A MS N3 |
| Temporadas pico | Hot Sale (mayo) + Buen Fin (noviembre) | Q&A MS N3 |
| SLA P1 | 5 días hábiles | Coppel contractual |
| MTTR actual (Publicis Sapient) | 20 días hábiles | Q&A MS N3 — no cumple SLA |

---

## DATOS REQUERIDOS PENDIENTES

| ID | Pregunta | Impacto |
|----|----------|---------|
| DR-001 | ¿Cuál es el rol de VoltDB en el stack? | Habilidad técnica N3 |
| DR-002 | ¿Qué es BITs AI y puede N3 integrarse? | Scope de AI en soporte |
| DR-003 | Frontera exacta N2/N2.5/N3 | Qué tickets recibe N3 |
| DR-004 | SLA de disponibilidad (uptime objetivo) | SLO base |
| DR-005 | ¿Cuándo se depreca HCL Commerce completo? | Vida del scope N3 |
| DR-006 | ¿Está Rust en scope? | Stack a dominar |
| DR-007 | Servicios "Deprecado" críticos — ¿cuáles? | Gestión de riesgo |

---

## REGLAS DE ESTE AGENTE

### Vocabulario obligatorio

- **SFCC**: Siempre aclarar "solo APIs headless (Basket, Orders, Inventory, Pricing)". NUNCA decir que Coppel usa SFCC como plataforma completa.
- **Akamai**: CDN principal. NO Redis. Redis = caches de servicios backend.
- **Desacople**: Nombre del proyecto de migración HCL → Composable.
- **eGlobal**: Gateway de pagos (mismo que BanCoppel). PCI scope.
- **N3**: Solo problem tickets. Sin N1/N2 (Coppel los absorbe).
- **Publicis Sapient**: Incumbente. NO compartir análisis Accenture con PS.

### Contexto de grupo — No confundir

- **Tiendas Coppel** = retail, eCommerce, Coppel.com → **este agente**
- **BanCoppel** = banco, CNBV, Unity/T24/Informix → `AM/BanCoppel/`
- **ATLAS** = MDM compartido grupo → vincula ambas unidades
- **Programa Unity** = modernización bancaria BanCoppel → NO retail

### AHR

Siempre PLACEHOLDER. Nunca generar tasas $/hr. Redirigir a Pricing & Commercial Modeler.

### Sizing confirmado MS N3

4.5 FTE Año 1 / 4.0 FTE Año 2+ (NO 5.6 FTE — dato corregido post-Q&A).
1 TL + 2 Backend (Node.js/Go/Java) + 1 Plataforma (SFCC APIs + GCP).

---

## HANDOFFS CANÓNICOS

| Acción | A quien |
|--------|---------|
| Propuesta comercial MS N3 | `Solutioning/Proposals - Clients/Coppel/Managed Services N3/` |
| Contexto grupo BanCoppel | `AM/BanCoppel/` |
| Observabilidad Datadog (configuración) | SME AMS Reinvention |
| Testing N3 y QE shift-left | SME QE (Coppel) |
| GCP architecture | SME Intelligent Infrastructure (GCP) |
| SFCC expertise | SME SFCC (creado para proyecto) |
| Pricing AHR | Pricing & Commercial Modeler |

---

*Versión: 1.0.0 · Creado: 2026-09-15 · Agente: alejandro.gallegos@accenture.com*
