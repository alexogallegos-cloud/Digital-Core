# D07 · Aclaraciones — Catálogo de Procesos de Negocio

> **Componente:** BCOPCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdiaclaracion` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 2 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CONDUSEF** (`SME/Regulatory/CONDUSEF/`)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Rol del dominio

`bdiaclaracion` · Wave 2 · Riesgo ALTO. 84 SPs; 10 procesos orquestados + 0 servicios expuestos.

## Inventario de procesos de negocio identificados

| ID | Proceso (objetivo) | SP entry point | Tipo | Reg |
|----|--------------------|----------------|------|:---:|
| BP-D07-01 | busca beneficiarios y cuenta | `sp_fal_busca_beneficiarios_por_cuenta` | Orquestador |  |
| BP-D07-02 | busca documentos (faltantes) | `sp_fal_busca_documentos_faltantes` | Orquestador |  |
| BP-D07-03 | busca pagarés y cliente | `sp_fal_busca_pagares_cliente` | Orquestador |  |
| BP-D07-04 | busca producto, cheque y cliente (débito) | `sp_fal_busca_producto_deb_cheq_cliente` | Orquestador |  |
| BP-D07-05 | busca producto, cheque y cliente (débito) | `sp_fal_busca_producto_deb_cheq_cliente_1` | Orquestador |  |
| BP-D07-06 | busca producto, cheque y cliente (débito) | `sp_fal_busca_producto_deb_cheq_cliente_2` | Orquestador |  |
| BP-D07-07 | busca producto, cheque y cliente (débito) | `sp_fal_busca_producto_deb_cheq_cliente_3` | Orquestador |  |
| BP-D07-08 | busca producto, cuenta, cliente y identificador (débito) | `sp_fal_busca_producto_pcuenta_deb_cte_fallecido` | Orquestador |  |
| BP-D07-09 | cancela cuenta (débito) | `sp_fal_cancelacion_cuenta_debito` | Orquestador |  |
| BP-D07-10 | consulta ciudades | `sp_fal_consulta_ciudades` | Orquestador |  |

> Detalle de cadenas de llamadas en `01-journey.md` · reglas y fórmulas en `04-business-rules.md`.

## `[SME-PENDING]`
- [ ] Nombre de negocio oficial de cada proceso.
- [ ] Frecuencia y criticidad operativa.

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json*