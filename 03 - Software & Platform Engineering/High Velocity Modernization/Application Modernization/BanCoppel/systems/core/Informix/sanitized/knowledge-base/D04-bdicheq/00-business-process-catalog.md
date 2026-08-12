# D04 · Cheques / Cuentas — Catálogo de Procesos de Negocio

> **Componente:** LegacyCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdicheq` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 4 · Riesgo: **CRÍTICO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — LegacyCore (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)
- **SME Regulatorio — TESOFE** (`SME/Regulatory/TESOFE/`)
- **SME Regulatorio — IPAB** (`SME/Regulatory/IPAB/`)
- **SME Regulatorio — CONDUSEF** (`SME/Regulatory/CONDUSEF/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Rol del dominio

`bdicheq` · Wave 4 · Riesgo CRÍTICO. 111 SPs; 10 procesos orquestados + 1 servicios expuestos.

## Inventario de procesos de negocio identificados

| ID | Proceso (objetivo) | SP entry point | Tipo | Reg |
|----|--------------------|----------------|------|:---:|
| BP-D04-01 | cargo | `cargo_ref` | Orquestador |  |
| BP-D04-02 | abono | `abono_ref` | Orquestador |  |
| BP-D04-03 | reversa | `reversion` | Orquestador |  |
| BP-D04-04 | bloquea cuenta cuenta | `bloqueo_cta` | Orquestador |  |
| BP-D04-05 | ischar | `ischar` | Orquestador |  |
| BP-D04-06 | cargo y punto de venta | `cargo_ref_pos` | Orquestador |  |
| BP-D04-07 | cargo | `cargon_ref` | Orquestador |  |
| BP-D04-08 | cargo (canal web) | `cargon_ref_web` | Orquestador |  |
| BP-D04-09 | genera nómina | `sp_nom_gendata_disp` | Orquestador |  |
| BP-D04-10 | genera nómina, movimiento y mes | `sp_nom_gen_mov_mes` | Orquestador |  |
| BP-D04-11 | consulta saldo disponible y tipo de cálculo | `sp_cons_sdodisp_x_tpcalculo` | Servicio expuesto |  |

> Detalle de cadenas de llamadas en `01-journey.md` · reglas y fórmulas en `04-business-rules.md`.

## `[SME-PENDING]`
- [ ] Nombre de negocio oficial de cada proceso.
- [ ] Frecuencia y criticidad operativa.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json*