# D12 · Contabilidad — Catálogo de Procesos de Negocio

> **Componente:** LegacyCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdicont` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 4 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — LegacyCore (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — SAT** (`Solutioning/Delivery - SME/Regulatory/SAT/`)
- **SME Regulatorio — IPAB** (`Solutioning/Delivery - SME/Regulatory/IPAB/`)
- **SME Regulatorio — CNBV** (`Solutioning/Delivery - SME/Regulatory/CNBV/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Rol del dominio

`bdicont` · Wave 4 · Riesgo ALTO. 19 SPs; 10 procesos orquestados + 0 servicios expuestos.

## Inventario de procesos de negocio identificados

| ID | Proceso (objetivo) | SP entry point | Tipo | Reg |
|----|--------------------|----------------|------|:---:|
| BP-D12-01 | consulta saldos diarios | `sp_cont_conssaldosdiariosb4` | Orquestador |  |
| BP-D12-02 | producto-transacción | `sp_cont_productotransaccionb5` | Orquestador |  |
| BP-D12-03 | carga movimiento | `sp_cont_cargamovimientob3` | Orquestador |  |
| BP-D12-04 | catálogo | `sp_cont_catalogob3` | Orquestador |  |
| BP-D12-05 | divisas | `sp_cont_divisasb4` | Orquestador |  |
| BP-D12-06 | empresas | `sp_cont_empresasb3` | Orquestador |  |
| BP-D12-07 | genera | `sp_gen_devob3` | Orquestador |  |
| BP-D12-08 | empresas | `sp_si_empresasb4` | Orquestador |  |
| BP-D12-09 | carga manual | `sp_cam_cargamanualb3` | Orquestador |  |
| BP-D12-10 | monitor y archivo | `sp_cam_monitorarchivosb3` | Orquestador |  |

> Detalle de cadenas de llamadas en `01-journey.md` · reglas y fórmulas en `04-business-rules.md`.

## `[SME-PENDING]`
- [ ] Nombre de negocio oficial de cada proceso.
- [ ] Frecuencia y criticidad operativa.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json*