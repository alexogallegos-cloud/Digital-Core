# D12 · Contabilidad — Journeys de Negocio

> **Componente:** Informix · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdicont` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 4 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — SAT** (`SME/Regulatory/SAT/`)
- **SME Regulatorio — IPAB** (`SME/Regulatory/IPAB/`)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Resumen del dominio

`19 SPs` · **10 journeys orquestadores** · **0 servicios expuestos** · reguladores: SAT, IPAB, CNBV

Los journeys y sus objetivos se derivaron del call graph + vocabulario de negocio (`vocabulary-knowledge-base-bcop.md`). El nombre técnico del SP se conserva para trazabilidad.

## Journeys orquestadores

### consulta saldos diarios
> SP: `sp_cont_conssaldosdiariosb4` · fan_out 84 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg

### producto-transacción
> SP: `sp_cont_productotransaccionb5` · fan_out 72 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg

### carga movimiento
> SP: `sp_cont_cargamovimientob3` · fan_out 63 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg

### catálogo
> SP: `sp_cont_catalogob3` · fan_out 55 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg

### divisas
> SP: `sp_cont_divisasb4` · fan_out 55 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg

### empresas
> SP: `sp_cont_empresasb3` · fan_out 55 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg

### genera
> SP: `sp_gen_devob3` · fan_out 55 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg

### empresas
> SP: `sp_si_empresasb4` · fan_out 55 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg

### carga manual
> SP: `sp_cam_cargamanualb3` · fan_out 50 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg

### monitor y archivo
> SP: `sp_cam_monitorarchivosb3` · fan_out 37 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg

## `[SME-PENDING]` Validación con Domain Expert

- [ ] Confirmar el nombre de negocio oficial de cada journey (los objetivos son inferidos del vocabulario).
- [ ] Validar el canal/actor real que dispara cada journey.
- [ ] Confirmar journeys no visibles en el call graph estático (triggers, EXEC dinámico).

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json + flow-data.json*