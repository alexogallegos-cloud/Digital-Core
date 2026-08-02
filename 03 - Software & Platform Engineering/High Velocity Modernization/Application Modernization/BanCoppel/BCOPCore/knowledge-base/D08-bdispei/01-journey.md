# D08 · SPEI — Journeys de Negocio

> **Componente:** BCOPCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdispei` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 2 · Riesgo: **CRÍTICO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — Banxico** (`SME/Regulatory/Banxico/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Resumen del dominio

`46 SPs` · **10 journeys orquestadores** · **0 servicios expuestos** · reguladores: Banxico

Los journeys y sus objetivos se derivaron del call graph + vocabulario de negocio (`vocabulary-knowledge-base-bcop.md`). El nombre técnico del SP se conserva para trazabilidad.

## Journeys orquestadores

### aplica orden de pago
> SP: `spei_aplicaordenpago` · fan_out 15 · callers externos 0 · disparado por: App/Batch/Canal · **REGULATORIO**

Secuencia de invocaciones (cadena del call graph):

- `abono_ref` — abono → bdicheq
- `sp_registra_evento` — registra evento/notificación → bdimnsj
- `cargo_ref` — cargo → bdicheq

### recibe cancelación
> SP: `spei_reccancelacion` · fan_out 14 · callers externos 0 · disparado por: App/Batch/Canal · **REGULATORIO**

Secuencia de invocaciones (cadena del call graph):

- `abono_ref` — abono → bdicheq
- `sp_registra_evento` — registra evento/notificación → bdimnsj
- `cargo_ref` — cargo → bdicheq

### recibe devolución
> SP: `spei_recdevolucion` · fan_out 14 · callers externos 0 · disparado por: App/Batch/Canal · **REGULATORIO**

Secuencia de invocaciones (cadena del call graph):

- `abono_ref` — abono → bdicheq
- `sp_registra_evento` — registra evento/notificación → bdimnsj
- `cargo_ref` — cargo → bdicheq

### recibe orden extemporánea
> SP: `spei_recextemporanea` · fan_out 14 · callers externos 0 · disparado por: App/Batch/Canal · **REGULATORIO**

Secuencia de invocaciones (cadena del call graph):

- `abono_ref` — abono → bdicheq
- `sp_registra_evento` — registra evento/notificación → bdimnsj
- `cargo_ref` — cargo → bdicheq

### recibe orden de pago
> SP: `spei_recordenpago` · fan_out 14 · callers externos 0 · disparado por: App/Batch/Canal · **REGULATORIO**

Secuencia de invocaciones (cadena del call graph):

- `abono_ref` — abono → bdicheq
- `sp_registra_evento` — registra evento/notificación → bdimnsj
- `cargo_ref` — cargo → bdicheq

### recibe orden de pago
> SP: `spei_recordenpago_ws` · fan_out 12 · callers externos 0 · disparado por: App/Batch/Canal · **REGULATORIO**

Secuencia de invocaciones (cadena del call graph):

- `abono_ref` — abono → bdicheq
- `sp_registra_evento` — registra evento/notificación → bdimnsj
- `cargo_ref` — cargo → bdicheq

### devolución · CoDi — Cobro Digital
> SP: `spei_devcodi` · fan_out 10 · callers externos 0 · disparado por: App/Batch/Canal · **REGULATORIO**

Secuencia de invocaciones (cadena del call graph):

- `cargo_ref` — cargo → bdicheq

### recepción error · CoDi — Cobro Digital
> SP: `spei_recerrorescodi` · fan_out 10 · callers externos 0 · disparado por: App/Batch/Canal · **REGULATORIO**

Secuencia de invocaciones (cadena del call graph):

- `cargo_ref` — cargo → bdicheq

### orden y cliente · CoDi — Cobro Digital
> SP: `sp_regordenctecte_bex_codi_exp1` · fan_out 10 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `cargo_ref` — cargo → bdicheq

### orden y cliente · CoDi — Cobro Digital
> SP: `sp_regordenctecte_bex_codi` · fan_out 9 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `cargo_ref` — cargo → bdicheq

## `[SME-PENDING]` Validación con Domain Expert

- [ ] Confirmar el nombre de negocio oficial de cada journey (los objetivos son inferidos del vocabulario).
- [ ] Validar el canal/actor real que dispara cada journey.
- [ ] Confirmar journeys no visibles en el call graph estático (triggers, EXEC dinámico).

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json + flow-data.json*