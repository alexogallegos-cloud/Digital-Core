# D03 · Créditos — Journeys de Negocio

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


## Resumen del dominio

`380 SPs` · **10 journeys orquestadores** · **6 servicios expuestos** · reguladores: CNBV, SAT, CONDUSEF

Los journeys y sus objetivos se derivaron del call graph + vocabulario de negocio (`vocabulary-knowledge-base-bcop.md`). El nombre técnico del SP se conserva para trazabilidad.

## Journeys orquestadores

### consulta Buró de Crédito, solicitud, crédito y línea de crédito
> SP: `sp_mon_buro_conssolcredlincred2` · fan_out 6 · callers externos 325 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `genmov` — genera movimiento
- `actualizarregistroburo` — actualiza registro y Buró de Crédito → bdiburo
- `burocred` — Buró de Crédito y crédito → bdiburo
- `ins_buro_credito` — Buró de Crédito y crédito → bdiburo
- `sp_actualiza_statusmttobcycc` — actualiza estatus → bdisolic

### consulta saldos (general)
> SP: `sp_consulta_saldos_general` · fan_out 4 · callers externos 303 · disparado por: D01, D02, D07, D11, BDIVR

Secuencia de invocaciones (cadena del call graph):

- `monthadd` — monthadd
- `sp_inserta_bitacora` — inserta bitácora

### consulta sub-producto
> SP: `sp_consulta_subproducto` · fan_out 8 · callers externos 298 · disparado por: D01

### obtiene documentos
> SP: `sp_obtenerdoctosdigitalizar` · fan_out 4 · callers externos 300 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `sp_desc_ret` — sp_desc_ret → bdinteg
- `sp_consulta_saldos_general` — consulta saldos (general)
  - `monthadd` — monthadd
  - `sp_inserta_bitacora` — inserta bitácora

### inserta sub-producto
> SP: `sp_inserta_subproducto` · fan_out 8 · callers externos 275 · disparado por: D01

### consulta productos
> SP: `sp_consulta_productos` · fan_out 8 · callers externos 272 · disparado por: D01

### consulta crédito (por fallecimiento)
> SP: `sp_consultacredbloqfallecimiento` · fan_out 3 · callers externos 248 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `monthadd` — monthadd
- `sp_inserta_bitacora_cob` — inserta bitácora → bdicobranza

### traspaso entre cuentas cuenta, crédito y Sistema Operativo Central
> SP: `sp_traspasocuentas_cred_soc` · fan_out 2 · callers externos 238 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `genmov` — genera movimiento

### consulta saldo
> SP: `sp_consulta_sdo_apoyo` · fan_out 4 · callers externos 203 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `monthadd` — monthadd
- `sp_inserta_bitacora` — inserta bitácora

### consulta solicitud de crédito, crédito y línea de crédito
> SP: `sp_cac_consultasolincrelincred` · fan_out 2 · callers externos 150 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `sp_inserta_bitacora_cob` — inserta bitácora → bdicobranza

## Servicios expuestos (endpoints — alto fan-in)

| SP | Objetivo | callers ext | reg |
|----|----------|------------:|:---:|
| `sp_inserta_productos` | inserta productos | 304 |  |
| `sp_consulta_frecpago` | consulta frecuencia de pago | 303 |  |
| `sp_conspoliticacreditoprod` | consulta política de crédito, crédito y producto | 303 |  |
| `sp_mensajes_activos` | mensaje (activos) | 299 |  |
| `sp_eliminatemp` | elimina (temporal) | 286 |  |
| `sp_obtenctasmedioacceso` | obtiene cuentas y medio de acceso | 285 |  |

## `[SME-PENDING]` Validación con Domain Expert

- [ ] Confirmar el nombre de negocio oficial de cada journey (los objetivos son inferidos del vocabulario).
- [ ] Validar el canal/actor real que dispara cada journey.
- [ ] Confirmar journeys no visibles en el call graph estático (triggers, EXEC dinámico).

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json + flow-data.json*