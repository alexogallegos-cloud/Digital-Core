# D05 · Saldos y Cuentas — Catálogo de Procesos de Negocio

> **Componente:** BCOPCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdisac` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 3 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CNBV** (`Solutioning/Delivery - SME/Regulatory/CNBV/`)
- **SME Regulatorio — IPAB** (`Solutioning/Delivery - SME/Regulatory/IPAB/`)
- **SME Regulatorio — SAT** (`Solutioning/Delivery - SME/Regulatory/SAT/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Rol del dominio

`bdisac` · Wave 3 · Riesgo ALTO. 145 SPs; 10 procesos orquestados + 3 servicios expuestos.

## Inventario de procesos de negocio identificados

| ID | Proceso (objetivo) | SP entry point | Tipo | Reg |
|----|--------------------|----------------|------|:---:|
| BP-D05-01 | valida nómina, beneficiario y beneficiarios | `sp_validanombenefbts` | Orquestador |  |
| BP-D05-02 | obtiene parámetro | `sp_obtieneparametro` | Orquestador |  |
| BP-D05-03 | valida beneficiarios | `sp_validarembtsensac` | Orquestador |  |
| BP-D05-04 | ordenante (canal app) | `sp_app_queryorder` | Orquestador |  |
| BP-D05-05 | guarda respuesta y archivo | `sp_sac_wu_guardarespuesta_search` | Orquestador |  |
| BP-D05-06 | dígito verificador (canal app) | `sp_app_valdigito` | Orquestador |  |
| BP-D05-07 | (canal app, sub-, tipo) | `sp_app_submitpayreversal` | Orquestador |  |
| BP-D05-08 | (canal app, sub-, tipo) | `sp_app_submitpayment` | Orquestador |  |
| BP-D05-09 | obtiene información y identificación (canal app) | `sp_app_obtieneinfoidentificacion` | Orquestador |  |
| BP-D05-10 | obtiene beneficiarios, información y identificación | `sp_bts_obtieneinfoidentificacion` | Orquestador |  |
| BP-D05-11 | valida beneficiarios | `sp_validabts` | Servicio expuesto |  |
| BP-D05-12 | consulta información y beneficiarios | `sp_consinfobtssif` | Servicio expuesto |  |
| BP-D05-13 | consulta | `sp_sac_consucursales` | Servicio expuesto |  |

> Detalle de cadenas de llamadas en `01-journey.md` · reglas y fórmulas en `04-business-rules.md`.

## `[SME-PENDING]`
- [ ] Nombre de negocio oficial de cada proceso.
- [ ] Frecuencia y criticidad operativa.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json*