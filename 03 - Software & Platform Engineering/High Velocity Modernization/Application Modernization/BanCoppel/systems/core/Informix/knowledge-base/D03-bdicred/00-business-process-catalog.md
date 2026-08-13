# D03 · Créditos — Catálogo de Procesos de Negocio

> **Componente:** Informix · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdicred` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 4 · Riesgo: **CRÍTICO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)
- **SME Regulatorio — SAT** (`SME/Regulatory/SAT/`)
- **SME Regulatorio — CONDUSEF** (`SME/Regulatory/CONDUSEF/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Rol del dominio

`bdicred` · Wave 4 · Riesgo CRÍTICO. 380 SPs; 10 procesos orquestados + 6 servicios expuestos.

## Inventario de procesos de negocio identificados

| ID | Proceso (objetivo) | SP entry point | Tipo | Reg |
|----|--------------------|----------------|------|:---:|
| BP-D03-01 | consulta Buró de Crédito, solicitud, crédito y línea de crédito | `sp_mon_buro_conssolcredlincred2` | Orquestador |  |
| BP-D03-02 | consulta saldos (general) | `sp_consulta_saldos_general` | Orquestador |  |
| BP-D03-03 | consulta sub-producto | `sp_consulta_subproducto` | Orquestador |  |
| BP-D03-04 | obtiene documentos | `sp_obtenerdoctosdigitalizar` | Orquestador |  |
| BP-D03-05 | inserta sub-producto | `sp_inserta_subproducto` | Orquestador |  |
| BP-D03-06 | consulta productos | `sp_consulta_productos` | Orquestador |  |
| BP-D03-07 | consulta crédito (por fallecimiento) | `sp_consultacredbloqfallecimiento` | Orquestador |  |
| BP-D03-08 | traspaso entre cuentas cuenta, crédito y Sistema Operativo Central | `sp_traspasocuentas_cred_soc` | Orquestador |  |
| BP-D03-09 | consulta saldo | `sp_consulta_sdo_apoyo` | Orquestador |  |
| BP-D03-10 | consulta solicitud de crédito, crédito y línea de crédito | `sp_cac_consultasolincrelincred` | Orquestador |  |
| BP-D03-11 | inserta productos | `sp_inserta_productos` | Servicio expuesto |  |
| BP-D03-12 | consulta frecuencia de pago | `sp_consulta_frecpago` | Servicio expuesto |  |
| BP-D03-13 | consulta política de crédito, crédito y producto | `sp_conspoliticacreditoprod` | Servicio expuesto |  |
| BP-D03-14 | mensaje (activos) | `sp_mensajes_activos` | Servicio expuesto |  |
| BP-D03-15 | elimina (temporal) | `sp_eliminatemp` | Servicio expuesto |  |
| BP-D03-16 | obtiene cuentas y medio de acceso | `sp_obtenctasmedioacceso` | Servicio expuesto |  |

> Detalle de cadenas de llamadas en `01-journey.md` · reglas y fórmulas en `04-business-rules.md`.

## `[SME-PENDING]`
- [ ] Nombre de negocio oficial de cada proceso.
- [ ] Frecuencia y criticidad operativa.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json*