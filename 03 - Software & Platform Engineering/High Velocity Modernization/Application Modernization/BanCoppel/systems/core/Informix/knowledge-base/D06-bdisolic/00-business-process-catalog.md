# D06 · Solicitudes — Catálogo de Procesos de Negocio

> **Componente:** BCOPCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdisolic` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 3 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)
- **SME Regulatorio — CONDUSEF** (`SME/Regulatory/CONDUSEF/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Rol del dominio

`bdisolic` · Wave 3 · Riesgo ALTO. 84 SPs; 10 procesos orquestados + 5 servicios expuestos.

## Inventario de procesos de negocio identificados

| ID | Proceso (objetivo) | SP entry point | Tipo | Reg |
|----|--------------------|----------------|------|:---:|
| BP-D06-01 | determina línea de crédito | `determina_lincred_tc_cjunk` | Orquestador |  |
| BP-D06-02 | califica scoring crediticio | `califica_scoring2_cjunk` | Orquestador |  |
| BP-D06-03 | califica scoring crediticio | `califica_scoring_cjunk` | Orquestador |  |
| BP-D06-04 | califica scoring crediticio y motor de decisión | `califica_scoring_cjunk_motor` | Orquestador |  |
| BP-D06-05 | califica scoring crediticio | `califica_scoring_cjunk_precal_opt` | Orquestador |  |
| BP-D06-06 | califica scoring crediticio | `califica_scoring_cjunk_pbagh` | Orquestador |  |
| BP-D06-07 | califica scoring crediticio | `califica_scoring_cjunk_precal` | Orquestador |  |
| BP-D06-08 | califica scoring crediticio y motor de decisión | `califica_scoring_cjunk_precal_opt_motor` | Orquestador |  |
| BP-D06-09 | califica scoring crediticio | `califica_scoring_cjunk_pba` | Orquestador |  |
| BP-D06-10 | obtiene productos | `sp_obtiene_productos` | Orquestador |  |
| BP-D06-11 | asigna solicitud y Sistema Operativo Central | `sp_asigna_solicitud_soc` | Servicio expuesto |  |
| BP-D06-12 | consulta facturación | `sp_consultarfacturacionos2` | Servicio expuesto |  |
| BP-D06-13 | consulta empleado | `sp_cons_empleado_mc` | Servicio expuesto |  |
| BP-D06-14 | elimina | `sp_elimina_emp_mc` | Servicio expuesto |  |
| BP-D06-15 | obtiene ingreso (complemento) | `sp_obtienecompingresos_mc` | Servicio expuesto |  |

> Detalle de cadenas de llamadas en `01-journey.md` · reglas y fórmulas en `04-business-rules.md`.

## `[SME-PENDING]`
- [ ] Nombre de negocio oficial de cada proceso.
- [ ] Frecuencia y criticidad operativa.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json*