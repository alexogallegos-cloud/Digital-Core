# D02 · Integración y Auth — Catálogo de Procesos de Negocio

> **Componente:** BCOPCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdinteg` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 5 · Riesgo: **CRÍTICO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Rol del dominio

`bdinteg` · Wave 5 · Riesgo CRÍTICO. 220 SPs; 10 procesos orquestados + 6 servicios expuestos.

## Inventario de procesos de negocio identificados

| ID | Proceso (objetivo) | SP entry point | Tipo | Reg |
|----|--------------------|----------------|------|:---:|
| BP-D02-01 | cuenta, documentos y Sistema Operativo Central | `sp_cuentadoctos_soc` | Orquestador |  |
| BP-D02-02 | consulta clientes y dictamen | `sp_dicta_consultactesdictamen2` | Orquestador |  |
| BP-D02-03 | documentos (fusionados) | `sp_doctosfusionados` | Orquestador |  |
| BP-D02-04 | obtiene huellas biométricas | `sp_obthuellasactes` | Orquestador |  |
| BP-D02-05 | desbloqueo cuentas | `sp_desbctasfus_consctas` | Orquestador |  |
| BP-D02-06 | desbloqueo cuentas | `sp_desbctasfus` | Orquestador |  |
| BP-D02-07 | desbloqueo cuentas y nombre | `sp_desbctasfus_obtnombresupana` | Orquestador |  |
| BP-D02-08 | consulta producto de cliente | `sp_cnsif_consprodcte` | Orquestador |  |
| BP-D02-09 | bloquea cuenta cuentas | `sp_bloqueactas` | Orquestador |  |
| BP-D02-10 | modificación dictamen | `sp_dicta_modificaciondictamen` | Orquestador |  |
| BP-D02-11 | valida perfil de usuario y usuario | `sp_valida_perfil_usuario` | Servicio expuesto |  |
| BP-D02-12 | sp_desc_ret | `sp_desc_ret` | Servicio expuesto |  |
| BP-D02-13 | consulta colonias y código postal | `sp_consultacoloniascp` | Servicio expuesto |  |
| BP-D02-14 | actualiza estatus y alerta | `sp_dicta_actualizastatusalerta` | Servicio expuesto |  |
| BP-D02-15 | consulta ciudades | `sp_consultaciudades` | Servicio expuesto |  |
| BP-D02-16 | fusión de cuentas teléfonos y Sistema Operativo Central | `sp_fustraspasotelefonos_soc` | Servicio expuesto |  |

> Detalle de cadenas de llamadas en `01-journey.md` · reglas y fórmulas en `04-business-rules.md`.

## `[SME-PENDING]`
- [ ] Nombre de negocio oficial de cada proceso.
- [ ] Frecuencia y criticidad operativa.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json*