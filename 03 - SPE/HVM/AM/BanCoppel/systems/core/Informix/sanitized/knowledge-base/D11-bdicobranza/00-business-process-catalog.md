# D11 · Cobranza — Catálogo de Procesos de Negocio

> **Componente:** LegacyCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdicobranza` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 2 · Riesgo: **MEDIO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — LegacyCore (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)
- **SME Regulatorio — CONDUSEF** (`SME/Regulatory/CONDUSEF/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Rol del dominio

`bdicobranza` · Wave 2 · Riesgo MEDIO. 82 SPs; 10 procesos orquestados + 1 servicios expuestos.

## Inventario de procesos de negocio identificados

| ID | Proceso (objetivo) | SP entry point | Tipo | Reg |
|----|--------------------|----------------|------|:---:|
| BP-D11-01 | construye etiqueta y XML | `fn_formaretiquetaxml` | Orquestador |  |
| BP-D11-02 | genera fecha de pago de reestructura (de baja) | `sp_generafechpagoreestructura_baja` | Orquestador |  |
| BP-D11-03 | consulta local alertas | `sp_cilocconsultaalertas` | Orquestador |  |
| BP-D11-04 | consulta local marcas de cuenta | `sp_cilocconsultamarcas` | Orquestador |  |
| BP-D11-05 | consulta local situaciones de cuenta y marcas de cuenta | `sp_cilocconsultasituacionesmarcas` | Orquestador |  |
| BP-D11-06 | genera reporte, alertas y cliente | `sp_cilocgenerarptalertascte` | Orquestador |  |
| BP-D11-07 | genera reporte, marcas de cuenta y cliente | `sp_cilocgenerarptmarcascte` | Orquestador |  |
| BP-D11-08 | genera reporte, causa y cliente | `sp_cilocgenerarptsituacioncausacte` | Orquestador |  |
| BP-D11-09 | genera reporte (total) | `sp_cilocgenerarpttotalalarmas` | Orquestador |  |
| BP-D11-10 | genera reporte y marcas de cuenta (total) | `sp_cilocgenerarpttotalmarcas` | Orquestador |  |
| BP-D11-11 | inserta bitácora | `sp_inserta_bitacora_cob` | Servicio expuesto |  |

> Detalle de cadenas de llamadas en `01-journey.md` · reglas y fórmulas en `04-business-rules.md`.

## `[SME-PENDING]`
- [ ] Nombre de negocio oficial de cada proceso.
- [ ] Frecuencia y criticidad operativa.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json*