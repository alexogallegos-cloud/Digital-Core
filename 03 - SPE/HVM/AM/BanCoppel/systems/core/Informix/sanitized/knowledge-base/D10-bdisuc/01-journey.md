# D10 · Sucursales — Journeys de Negocio

> **Componente:** LegacyCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdisuc` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 3 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — LegacyCore (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Resumen del dominio

`37 SPs` · **2 journeys orquestadores** · **6 servicios expuestos** · reguladores: CNBV

Los journeys y sus objetivos se derivaron del call graph + vocabulario de negocio (`vocabulary-knowledge-base-lgc.md`). El nombre técnico del SP se conserva para trazabilidad.

## Journeys orquestadores

### realiza el pase contable (canal web)
> SP: `pasecont_web_2` · fan_out 2 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg

### reinicia cajero automático
> SP: `sp_reiniciapaseatm` · fan_out 2 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg

## Servicios expuestos (endpoints — alto fan-in)

| SP | Objetivo | callers ext | reg |
|----|----------|------------:|:---:|
| `sp_consultadatospiezas_bym3` | consulta datos, piezas de efectivo y Billetes y Monedas | 381 |  |
| `sp_consutacat_dictamen_bym` | consulta catálogo [typo] dictamen y Billetes y Monedas | 378 |  |
| `sp_consultadatospiezas_bym3_totales` | consulta datos, piezas de efectivo y Billetes y Monedas (totales) | 376 |  |
| `sp_consultadatospiezas_bym2` | consulta datos, piezas de efectivo y Billetes y Monedas | 376 |  |
| `sp_consultacat_estatus_bym` | consulta catálogo, estatus y Billetes y Monedas | 375 |  |
| `sp_consulta_catdenominacion_bym` | consulta catálogo de denominaciones y Billetes y Monedas | 374 |  |

## `[SME-PENDING]` Validación con Domain Expert

- [ ] Confirmar el nombre de negocio oficial de cada journey (los objetivos son inferidos del vocabulario).
- [ ] Validar el canal/actor real que dispara cada journey.
- [ ] Confirmar journeys no visibles en el call graph estático (triggers, EXEC dinámico).

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json + flow-data.json*