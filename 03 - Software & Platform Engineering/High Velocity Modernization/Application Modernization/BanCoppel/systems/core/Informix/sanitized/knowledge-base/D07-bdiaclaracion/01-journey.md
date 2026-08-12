# D07 · Aclaraciones — Journeys de Negocio

> **Componente:** LegacyCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdiaclaracion` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 2 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — LegacyCore (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CONDUSEF** (`SME/Regulatory/CONDUSEF/`)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Resumen del dominio

`84 SPs` · **10 journeys orquestadores** · **0 servicios expuestos** · reguladores: CONDUSEF, CNBV

Los journeys y sus objetivos se derivaron del call graph + vocabulario de negocio (`vocabulary-knowledge-base-lgc.md`). El nombre técnico del SP se conserva para trazabilidad.

## Journeys orquestadores

### busca beneficiarios y cuenta
> SP: `sp_fal_busca_beneficiarios_por_cuenta` · fan_out 20 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `bloqueo_cta` — bloquea cuenta cuenta → bdicheq
- `cargo_ref` — cargo → bdicheq
- `abono_ref` — abono → bdicheq
- `sp_consulta_saldos_general` — consulta saldos (general) → bdicred

### busca documentos (faltantes)
> SP: `sp_fal_busca_documentos_faltantes` · fan_out 20 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `bloqueo_cta` — bloquea cuenta cuenta → bdicheq
- `cargo_ref` — cargo → bdicheq
- `abono_ref` — abono → bdicheq
- `sp_consulta_saldos_general` — consulta saldos (general) → bdicred

### busca pagarés y cliente
> SP: `sp_fal_busca_pagares_cliente` · fan_out 20 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `bloqueo_cta` — bloquea cuenta cuenta → bdicheq
- `cargo_ref` — cargo → bdicheq
- `abono_ref` — abono → bdicheq
- `sp_consulta_saldos_general` — consulta saldos (general) → bdicred

### busca producto, cheque y cliente (débito)
> SP: `sp_fal_busca_producto_deb_cheq_cliente` · fan_out 20 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `bloqueo_cta` — bloquea cuenta cuenta → bdicheq
- `cargo_ref` — cargo → bdicheq
- `abono_ref` — abono → bdicheq
- `sp_consulta_saldos_general` — consulta saldos (general) → bdicred

### busca producto, cheque y cliente (débito)
> SP: `sp_fal_busca_producto_deb_cheq_cliente_1` · fan_out 20 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `bloqueo_cta` — bloquea cuenta cuenta → bdicheq
- `cargo_ref` — cargo → bdicheq
- `abono_ref` — abono → bdicheq
- `sp_consulta_saldos_general` — consulta saldos (general) → bdicred

### busca producto, cheque y cliente (débito)
> SP: `sp_fal_busca_producto_deb_cheq_cliente_2` · fan_out 20 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `bloqueo_cta` — bloquea cuenta cuenta → bdicheq
- `cargo_ref` — cargo → bdicheq
- `abono_ref` — abono → bdicheq
- `sp_consulta_saldos_general` — consulta saldos (general) → bdicred

### busca producto, cheque y cliente (débito)
> SP: `sp_fal_busca_producto_deb_cheq_cliente_3` · fan_out 20 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `bloqueo_cta` — bloquea cuenta cuenta → bdicheq
- `cargo_ref` — cargo → bdicheq
- `abono_ref` — abono → bdicheq
- `sp_consulta_saldos_general` — consulta saldos (general) → bdicred

### busca producto, cuenta, cliente y identificador (débito)
> SP: `sp_fal_busca_producto_pcuenta_deb_cte_fallecido` · fan_out 20 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `bloqueo_cta` — bloquea cuenta cuenta → bdicheq
- `cargo_ref` — cargo → bdicheq
- `abono_ref` — abono → bdicheq
- `sp_consulta_saldos_general` — consulta saldos (general) → bdicred

### cancela cuenta (débito)
> SP: `sp_fal_cancelacion_cuenta_debito` · fan_out 20 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `bloqueo_cta` — bloquea cuenta cuenta → bdicheq
- `cargo_ref` — cargo → bdicheq
- `abono_ref` — abono → bdicheq
- `sp_consulta_saldos_general` — consulta saldos (general) → bdicred

### consulta ciudades
> SP: `sp_fal_consulta_ciudades` · fan_out 17 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `bloqueo_cta` — bloquea cuenta cuenta → bdicheq
- `cargo_ref` — cargo → bdicheq
- `abono_ref` — abono → bdicheq
- `sp_consulta_saldos_general` — consulta saldos (general) → bdicred

## `[SME-PENDING]` Validación con Domain Expert

- [ ] Confirmar el nombre de negocio oficial de cada journey (los objetivos son inferidos del vocabulario).
- [ ] Validar el canal/actor real que dispara cada journey.
- [ ] Confirmar journeys no visibles en el call graph estático (triggers, EXEC dinámico).

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json + flow-data.json*