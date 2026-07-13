# D05 · Saldos y Cuentas — Journeys de Negocio

> **Componente:** LegacyCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdisac` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 3 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — LegacyCore (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CNBV** (`Solutioning/Delivery - SME/Regulatory/CNBV/`)
- **SME Regulatorio — IPAB** (`Solutioning/Delivery - SME/Regulatory/IPAB/`)
- **SME Regulatorio — SAT** (`Solutioning/Delivery - SME/Regulatory/SAT/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Resumen del dominio

`145 SPs` · **10 journeys orquestadores** · **3 servicios expuestos** · reguladores: CNBV, IPAB, SAT

Los journeys y sus objetivos se derivaron del call graph + vocabulario de negocio (`vocabulary-knowledge-base-lgc.md`). El nombre técnico del SP se conserva para trazabilidad.

## Journeys orquestadores

### valida nómina, beneficiario y beneficiarios
> SP: `sp_validanombenefbts` · fan_out 3 · callers externos 239 · disparado por: D01, D02

### obtiene parámetro
> SP: `sp_obtieneparametro` · fan_out 3 · callers externos 176 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `sp_validanombenefbts` — valida nómina, beneficiario y beneficiarios
- `sp_sac_guardamensajeerror` — guarda mensaje y error

### valida beneficiarios
> SP: `sp_validarembtsensac` · fan_out 7 · callers externos 159 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `sp_sac_guardamensajeerror` — guarda mensaje y error
- `abono_ref` — abono → bdicheq
- `reversion` — reversa → bdicheq

### ordenante (canal app)
> SP: `sp_app_queryorder` · fan_out 14 · callers externos 154 · disparado por: D01

### guarda respuesta y archivo
> SP: `sp_sac_wu_guardarespuesta_search` · fan_out 3 · callers externos 161 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `sp_sac_consucursales` — consulta

### dígito verificador (canal app)
> SP: `sp_app_valdigito` · fan_out 3 · callers externos 157 · disparado por: D01

### (canal app, sub-, tipo)
> SP: `sp_app_submitpayreversal` · fan_out 2 · callers externos 156 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `sp_sac_guardamensajeerror` — guarda mensaje y error

### (canal app, sub-, tipo)
> SP: `sp_app_submitpayment` · fan_out 2 · callers externos 155 · disparado por: D01

### obtiene información y identificación (canal app)
> SP: `sp_app_obtieneinfoidentificacion` · fan_out 5 · callers externos 152 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `sp_bitacoraapertura` — bitácora y apertura → bdinteg
- `sp_registra_telefonos` — registra teléfonos → bdinteg
- `sp_actvalidacioncofetel` — actualiza teléfono → bdinteg

### obtiene beneficiarios, información y identificación
> SP: `sp_bts_obtieneinfoidentificacion` · fan_out 2 · callers externos 152 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `sp_sac_guardamensajeerror` — guarda mensaje y error

## Servicios expuestos (endpoints — alto fan-in)

| SP | Objetivo | callers ext | reg |
|----|----------|------------:|:---:|
| `sp_validabts` | valida beneficiarios | 182 |  |
| `sp_consinfobtssif` | consulta información y beneficiarios | 162 |  |
| `sp_sac_consucursales` | consulta | 157 |  |

## `[SME-PENDING]` Validación con Domain Expert

- [ ] Confirmar el nombre de negocio oficial de cada journey (los objetivos son inferidos del vocabulario).
- [ ] Validar el canal/actor real que dispara cada journey.
- [ ] Confirmar journeys no visibles en el call graph estático (triggers, EXEC dinámico).

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json + flow-data.json*