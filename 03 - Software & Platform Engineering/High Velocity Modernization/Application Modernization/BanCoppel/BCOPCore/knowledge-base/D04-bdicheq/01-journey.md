# D04 · Cheques / Cuentas — Journeys de Negocio

> **Componente:** BCOPCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdicheq` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 4 · Riesgo: **CRÍTICO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CNBV** (`Solutioning/Delivery - SME/Regulatory/CNBV/`)
- **SME Regulatorio — TESOFE** (`Solutioning/Delivery - SME/Regulatory/TESOFE/`)
- **SME Regulatorio — IPAB** (`Solutioning/Delivery - SME/Regulatory/IPAB/`)
- **SME Regulatorio — CONDUSEF** (`Solutioning/Delivery - SME/Regulatory/CONDUSEF/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Resumen del dominio

`111 SPs` · **10 journeys orquestadores** · **1 servicios expuestos** · reguladores: CNBV, TESOFE, IPAB, CONDUSEF

Los journeys y sus objetivos se derivaron del call graph + vocabulario de negocio (`vocabulary-knowledge-base-bcop.md`). El nombre técnico del SP se conserva para trazabilidad.

## Journeys orquestadores

### cargo
> SP: `cargo_ref` · fan_out 27 · callers externos 425 · disparado por: D01, D05, BDITEF, D03, D07

Secuencia de invocaciones (cadena del call graph):

- `reversion` — reversa
  - `sp_cons_sdodisp_x_tpcalculo` — consulta saldo disponible y tipo de cálculo
  - `abono_ref` — abono
  - `sp_registra_evento` — registra evento/notificación → bdimnsj
  - `sp_generafolionomina` — genera folio de nómina
  - `sp_reversionsac` — reversa → bdisac
  - `reversion` — reversa → bdisuc
  - `sp_reversa_acum_x` — sp_reversa_acum_x → bdinteg
- `abono_ref` — abono
- `sp_cons_sdodisp_x_tpcalculo` — consulta saldo disponible y tipo de cálculo

### abono
> SP: `abono_ref` · fan_out 7 · callers externos 410 · disparado por: D05, D01, D03, D07, BDITARJETA

### reversa
> SP: `reversion` · fan_out 18 · callers externos 315 · disparado por: D05, D01, D03, BDITRANSFER, BDIBPI

Secuencia de invocaciones (cadena del call graph):

- `sp_cons_sdodisp_x_tpcalculo` — consulta saldo disponible y tipo de cálculo
- `abono_ref` — abono
- `sp_registra_evento` — registra evento/notificación → bdimnsj
- `cargo_ref` — cargo
  - `abono_ref` — abono
  - `sp_cons_sdodisp_x_tpcalculo` — consulta saldo disponible y tipo de cálculo
  - `sp_inserta_msjafore` — inserta mensaje AFORE → bdinteg
  - `sp_limite_max` — (máximo) → bdinteg
  - `sp_validafecha` — valida fecha → bdispei · reg
- `sp_generafolionomina` — genera folio de nómina

### bloquea cuenta cuenta
> SP: `bloqueo_cta` · fan_out 14 · callers externos 168 · disparado por: D01, D07, D02, D03

Secuencia de invocaciones (cadena del call graph):

- `sp_cons_sdodisp_x_tpcalculo` — consulta saldo disponible y tipo de cálculo
- `abono_ref` — abono
- `sp_registra_evento` — registra evento/notificación → bdimnsj
- `cargo_ref` — cargo
  - `reversion` — reversa
    - `sp_cons_sdodisp_x_tpcalculo` — consulta saldo disponible y tipo de cálculo
    - `abono_ref` — abono
    - `sp_registra_evento` — registra evento/notificación → bdimnsj
    - `sp_generafolionomina` — genera folio de nómina
    - `sp_reversionsac` — reversa → bdisac

### ischar
> SP: `ischar` · fan_out 97 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg

### cargo y punto de venta
> SP: `cargo_ref_pos` · fan_out 28 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_registra_evento` — registra evento/notificación → bdimnsj

### cargo
> SP: `cargon_ref` · fan_out 24 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_registra_evento` — registra evento/notificación → bdimnsj

### cargo (canal web)
> SP: `cargon_ref_web` · fan_out 24 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_registra_evento` — registra evento/notificación → bdimnsj

### genera nómina
> SP: `sp_nom_gendata_disp` · fan_out 23 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg
- `sp_split_cadena` — sp_split_cadena → bdicnweb
- `sp_registra_evento` — registra evento/notificación → bdimnsj

### genera nómina, movimiento y mes
> SP: `sp_nom_gen_mov_mes` · fan_out 23 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg
- `sp_split_cadena` — sp_split_cadena → bdicnweb
- `sp_registra_evento` — registra evento/notificación → bdimnsj

## Servicios expuestos (endpoints — alto fan-in)

| SP | Objetivo | callers ext | reg |
|----|----------|------------:|:---:|
| `sp_cons_sdodisp_x_tpcalculo` | consulta saldo disponible y tipo de cálculo | 55 |  |

## `[SME-PENDING]` Validación con Domain Expert

- [ ] Confirmar el nombre de negocio oficial de cada journey (los objetivos son inferidos del vocabulario).
- [ ] Validar el canal/actor real que dispara cada journey.
- [ ] Confirmar journeys no visibles en el call graph estático (triggers, EXEC dinámico).

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json + flow-data.json*