# D01 · Canal Digital Web — Catálogo de Procesos de Negocio

> **Componente:** Informix · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdicnweb` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 6 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)


> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Rol del dominio

`bdicnweb` · Wave 6 · Riesgo ALTO. 2,122 SPs; 10 procesos orquestados + 0 servicios expuestos.

## Inventario de procesos de negocio identificados

| ID | Proceso (objetivo) | SP entry point | Tipo | Reg |
|----|--------------------|----------------|------|:---:|
| BP-D01-01 | cédula contable y nombre | `sp_cedulacontablenombre` | Orquestador |  |
| BP-D01-02 | consulta cédulas usuarios | `sp_conscedulasusuariosccl` | Orquestador |  |
| BP-D01-03 | consulta reportes cuentas inactivas · Art. 61 LIC | `sp_consreportesctasinactivasart61` | Orquestador |  |
| BP-D01-04 | consulta reportes cuentas inactivas (totales) · Art. 61 LIC | `sp_consreportesctasinactivasart61_totales` | Orquestador |  |
| BP-D01-05 | consulta fechas · Art. 61 LIC | `sp_consultafechasart61` | Orquestador |  |
| BP-D01-06 | consulta información, reporte y detalle | `sp_consultainforeportebc_detalleconsultas` | Orquestador |  |
| BP-D01-07 | obtiene imágenes y cliente (últimas) | `sp_obtieneultimasimagenesdigicte` | Orquestador |  |
| BP-D01-08 | bloquea cuenta reporte, cuentas y crédito (masivo) | `sp_reportebloqueoctasmasivocre` | Orquestador |  |
| BP-D01-09 | desbloquea cuenta reporte, cuentas y crédito (masivo) | `sp_reportedesbloqueoctasmasivocre` | Orquestador |  |
| BP-D01-10 | consulta usuario y cédula de identificación | `sp_usuariocedulacons` | Orquestador |  |

> Detalle de cadenas de llamadas en `01-journey.md` · reglas y fórmulas en `04-business-rules.md`.

## `[SME-PENDING]`
- [ ] Nombre de negocio oficial de cada proceso.
- [ ] Frecuencia y criticidad operativa.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json*