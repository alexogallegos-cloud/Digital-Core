# D10 · Sucursales — Catálogo de Procesos de Negocio

> **Componente:** LegacyCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdisuc` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 3 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — LegacyCore (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CNBV** (`Solutioning/Delivery - SME/Regulatory/CNBV/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Rol del dominio

`bdisuc` · Wave 3 · Riesgo ALTO. 37 SPs; 2 procesos orquestados + 6 servicios expuestos.

## Inventario de procesos de negocio identificados

| ID | Proceso (objetivo) | SP entry point | Tipo | Reg |
|----|--------------------|----------------|------|:---:|
| BP-D10-01 | realiza el pase contable (canal web) | `pasecont_web_2` | Orquestador |  |
| BP-D10-02 | reinicia cajero automático | `sp_reiniciapaseatm` | Orquestador |  |
| BP-D10-03 | consulta datos, piezas de efectivo y Billetes y Monedas | `sp_consultadatospiezas_bym3` | Servicio expuesto |  |
| BP-D10-04 | consulta catálogo [typo] dictamen y Billetes y Monedas | `sp_consutacat_dictamen_bym` | Servicio expuesto |  |
| BP-D10-05 | consulta datos, piezas de efectivo y Billetes y Monedas (totales) | `sp_consultadatospiezas_bym3_totales` | Servicio expuesto |  |
| BP-D10-06 | consulta datos, piezas de efectivo y Billetes y Monedas | `sp_consultadatospiezas_bym2` | Servicio expuesto |  |
| BP-D10-07 | consulta catálogo, estatus y Billetes y Monedas | `sp_consultacat_estatus_bym` | Servicio expuesto |  |
| BP-D10-08 | consulta catálogo de denominaciones y Billetes y Monedas | `sp_consulta_catdenominacion_bym` | Servicio expuesto |  |

> Detalle de cadenas de llamadas en `01-journey.md` · reglas y fórmulas en `04-business-rules.md`.

## `[SME-PENDING]`
- [ ] Nombre de negocio oficial de cada proceso.
- [ ] Frecuencia y criticidad operativa.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json*