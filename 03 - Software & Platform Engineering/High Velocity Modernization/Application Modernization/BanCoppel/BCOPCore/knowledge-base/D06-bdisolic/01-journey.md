# D06 · Solicitudes — Journeys de Negocio

> **Componente:** BCOPCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdisolic` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 3 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CNBV** (`Solutioning/Delivery - SME/Regulatory/CNBV/`)
- **SME Regulatorio — CONDUSEF** (`Solutioning/Delivery - SME/Regulatory/CONDUSEF/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Resumen del dominio

`84 SPs` · **10 journeys orquestadores** · **5 servicios expuestos** · reguladores: CNBV, CONDUSEF

Los journeys y sus objetivos se derivaron del call graph + vocabulario de negocio (`vocabulary-knowledge-base-bcop.md`). El nombre técnico del SP se conserva para trazabilidad.

## Journeys orquestadores

### determina línea de crédito
> SP: `determina_lincred_tc_cjunk` · fan_out 6 · callers externos 199 · disparado por: D01, BDIBURO, D03

Secuencia de invocaciones (cadena del call graph):

- `sp_obtienegrupo` — obtiene grupo
  - `mesesvalidoscte` — valida mes y cliente → bdinteg
- `sp_obtiene_tasa_int_diferenciadas` — obtiene tasa y interés → bdicred

### califica scoring crediticio
> SP: `califica_scoring2_cjunk` · fan_out 19 · callers externos 154 · disparado por: D01, BDIBURO

Secuencia de invocaciones (cadena del call graph):

- `sp_registra_evento` — registra evento/notificación → bdimnsj
- `determina_lincred_tc_cjunk` — determina línea de crédito
  - `sp_obtienegrupo` — obtiene grupo
    - `mesesvalidoscte` — valida mes y cliente → bdinteg
  - `sp_obtiene_tasa_int_diferenciadas` — obtiene tasa y interés → bdicred
- `valor_divisa_pesos` — valor y divisa → bdinteg
- `sp_valida2credito` — valida crédito → bdicred
- `sp_consultareferencias` — consulta referencia → bdinteg

### califica scoring crediticio
> SP: `califica_scoring_cjunk` · fan_out 17 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_registra_evento` — registra evento/notificación → bdimnsj

### califica scoring crediticio y motor de decisión
> SP: `califica_scoring_cjunk_motor` · fan_out 16 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_registra_evento` — registra evento/notificación → bdimnsj

### califica scoring crediticio
> SP: `califica_scoring_cjunk_precal_opt` · fan_out 16 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_registra_evento` — registra evento/notificación → bdimnsj

### califica scoring crediticio
> SP: `califica_scoring_cjunk_pbagh` · fan_out 15 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_registra_evento` — registra evento/notificación → bdimnsj

### califica scoring crediticio
> SP: `califica_scoring_cjunk_precal` · fan_out 15 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_registra_evento` — registra evento/notificación → bdimnsj

### califica scoring crediticio y motor de decisión
> SP: `califica_scoring_cjunk_precal_opt_motor` · fan_out 15 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_registra_evento` — registra evento/notificación → bdimnsj

### califica scoring crediticio
> SP: `califica_scoring_cjunk_pba` · fan_out 14 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_registra_evento` — registra evento/notificación → bdimnsj

### obtiene productos
> SP: `sp_obtiene_productos` · fan_out 9 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `monthadd` — monthadd → bdicred

## Servicios expuestos (endpoints — alto fan-in)

| SP | Objetivo | callers ext | reg |
|----|----------|------------:|:---:|
| `sp_asigna_solicitud_soc` | asigna solicitud y Sistema Operativo Central | 236 |  |
| `sp_consultarfacturacionos2` | consulta facturación | 168 |  |
| `sp_cons_empleado_mc` | consulta empleado | 148 |  |
| `sp_elimina_emp_mc` | elimina | 144 |  |
| `sp_obtienecompingresos_mc` | obtiene ingreso (complemento) | 139 |  |

## `[SME-PENDING]` Validación con Domain Expert

- [ ] Confirmar el nombre de negocio oficial de cada journey (los objetivos son inferidos del vocabulario).
- [ ] Validar el canal/actor real que dispara cada journey.
- [ ] Confirmar journeys no visibles en el call graph estático (triggers, EXEC dinámico).

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json + flow-data.json*