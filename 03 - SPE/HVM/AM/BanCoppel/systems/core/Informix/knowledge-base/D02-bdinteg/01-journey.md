# D02 · Integración y Auth — Journeys de Negocio

> **Componente:** Informix · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
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


## Resumen del dominio

`220 SPs` · **10 journeys orquestadores** · **6 servicios expuestos** · reguladores: CNBV

Los journeys y sus objetivos se derivaron del call graph + vocabulario de negocio (`vocabulary-knowledge-base-bcop.md`). El nombre técnico del SP se conserva para trazabilidad.

## Journeys orquestadores

### cuenta, documentos y Sistema Operativo Central
> SP: `sp_cuentadoctos_soc` · fan_out 2 · callers externos 354 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `digver11` — digver11 → bdicheq
- `ctaclabe` — cuenta CLABE → bdicheq

### consulta clientes y dictamen
> SP: `sp_dicta_consultactesdictamen2` · fan_out 3 · callers externos 268 · disparado por: D01

### documentos (fusionados)
> SP: `sp_doctosfusionados` · fan_out 5 · callers externos 226 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_permisosejecutivo` — ejecutivo
- `sp_desfusion_ctescred` — fusiona cuentas clientes y crédito → bdicred

### obtiene huellas biométricas
> SP: `sp_obthuellasactes` · fan_out 2 · callers externos 228 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_permisosejecutivo` — ejecutivo
- `obtenperiodos_edocuentacrd` — obtiene periodo, estado y cuenta → bdicred

### desbloqueo cuentas
> SP: `sp_desbctasfus_consctas` · fan_out 4 · callers externos 219 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `sp_cons_sdodisp_x_tpcalculo` — consulta saldo disponible y tipo de cálculo → bdicheq
- `sp_consulta_saldos_general` — consulta saldos (general) → bdicred
- `sp_consulta_datos_general` — consulta datos (general) → bdicred
- `sp_consultasaldocorte` — consulta saldo → bdicred

### desbloqueo cuentas
> SP: `sp_desbctasfus` · fan_out 2 · callers externos 217 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `bloqueo_cta` — bloquea cuenta cuenta → bdicheq
- `sp_desbloqueocuenta` — desbloquea cuenta cuenta → bdicred

### desbloqueo cuentas y nombre
> SP: `sp_desbctasfus_obtnombresupana` · fan_out 4 · callers externos 214 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `sp_inserta_bitacora_cob` — inserta bitácora → bdicobranza
- `sp_actualiza_status_sol` — actualiza estatus y solicitud → bdisolic

### consulta producto de cliente
> SP: `sp_cnsif_consprodcte` · fan_out 15 · callers externos 205 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_permisosejecutivo` — ejecutivo
- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo
- `sp_cons_sdodisp_x_tpcalculo` — consulta saldo disponible y tipo de cálculo → bdicheq
- `sp_consulta_saldos_general` — consulta saldos (general) → bdicred
- `sp_validacte_transfer` — valida cliente → bdicnweb
- `sp_consulta_datos_general` — consulta datos (general) → bdicred
- `sp_consultasaldocorte` — consulta saldo → bdicred

### bloquea cuenta cuentas
> SP: `sp_bloqueactas` · fan_out 3 · callers externos 210 · disparado por: D01

Secuencia de invocaciones (cadena del call graph):

- `bloqueo_cta` — bloquea cuenta cuenta → bdicheq
- `sp_bloqueocuenta` — bloquea cuenta cuenta → bdicred

### modificación dictamen
> SP: `sp_dicta_modificaciondictamen` · fan_out 2 · callers externos 196 · disparado por: D01

## Servicios expuestos (endpoints — alto fan-in)

| SP | Objetivo | callers ext | reg |
|----|----------|------------:|:---:|
| `sp_valida_perfil_usuario` | valida perfil de usuario y usuario | 388 |  |
| `sp_desc_ret` | sp_desc_ret | 356 |  |
| `sp_consultacoloniascp` | consulta colonias y código postal | 281 |  |
| `sp_dicta_actualizastatusalerta` | actualiza estatus y alerta | 270 |  |
| `sp_consultaciudades` | consulta ciudades | 265 |  |
| `sp_fustraspasotelefonos_soc` | fusión de cuentas teléfonos y Sistema Operativo Central | 239 |  |

## `[SME-PENDING]` Validación con Domain Expert

- [ ] Confirmar el nombre de negocio oficial de cada journey (los objetivos son inferidos del vocabulario).
- [ ] Validar el canal/actor real que dispara cada journey.
- [ ] Confirmar journeys no visibles en el call graph estático (triggers, EXEC dinámico).

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json + flow-data.json*