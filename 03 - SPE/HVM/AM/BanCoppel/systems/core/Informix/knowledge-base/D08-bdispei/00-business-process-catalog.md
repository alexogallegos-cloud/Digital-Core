# D08 · SPEI — Catálogo de Procesos de Negocio

> **Componente:** Informix · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdispei` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 2 · Riesgo: **CRÍTICO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — Banxico** (`SME/Regulatory/Banxico/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Rol del dominio

`bdispei` · Wave 2 · Riesgo CRÍTICO. 46 SPs; 10 procesos orquestados + 0 servicios expuestos.

## Inventario de procesos de negocio identificados

| ID | Proceso (objetivo) | SP entry point | Tipo | Reg |
|----|--------------------|----------------|------|:---:|
| BP-D08-01 | aplica orden de pago | `spei_aplicaordenpago` | Orquestador | 🔴 |
| BP-D08-02 | recibe cancelación | `spei_reccancelacion` | Orquestador | 🔴 |
| BP-D08-03 | recibe devolución | `spei_recdevolucion` | Orquestador | 🔴 |
| BP-D08-04 | recibe orden extemporánea | `spei_recextemporanea` | Orquestador | 🔴 |
| BP-D08-05 | recibe orden de pago | `spei_recordenpago` | Orquestador | 🔴 |
| BP-D08-06 | recibe orden de pago | `spei_recordenpago_ws` | Orquestador | 🔴 |
| BP-D08-07 | devolución · CoDi — Cobro Digital | `spei_devcodi` | Orquestador | 🔴 |
| BP-D08-08 | recepción error · CoDi — Cobro Digital | `spei_recerrorescodi` | Orquestador | 🔴 |
| BP-D08-09 | orden y cliente · CoDi — Cobro Digital | `sp_regordenctecte_bex_codi_exp1` | Orquestador |  |
| BP-D08-10 | orden y cliente · CoDi — Cobro Digital | `sp_regordenctecte_bex_codi` | Orquestador |  |

> Detalle de cadenas de llamadas en `01-journey.md` · reglas y fórmulas en `04-business-rules.md`.

## `[SME-PENDING]`
- [ ] Nombre de negocio oficial de cada proceso.
- [ ] Frecuencia y criticidad operativa.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json*