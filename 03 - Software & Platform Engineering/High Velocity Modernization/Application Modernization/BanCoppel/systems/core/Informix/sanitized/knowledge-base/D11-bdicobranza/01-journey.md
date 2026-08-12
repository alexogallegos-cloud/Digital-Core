# D11 · Cobranza — Journeys de Negocio

> **Componente:** LegacyCore · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdicobranza` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 2 · Riesgo: **MEDIO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — LegacyCore (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)
- **SME Regulatorio — CONDUSEF** (`SME/Regulatory/CONDUSEF/`)

> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Resumen del dominio

`82 SPs` · **10 journeys orquestadores** · **1 servicios expuestos** · reguladores: CNBV, CONDUSEF

Los journeys y sus objetivos se derivaron del call graph + vocabulario de negocio (`vocabulary-knowledge-base-lgc.md`). El nombre técnico del SP se conserva para trazabilidad.

## Journeys orquestadores

### construye etiqueta y XML
> SP: `fn_formaretiquetaxml` · fan_out 43 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_consulta_saldos_general` — consulta saldos (general) → bdicred
- `sp_sustituirse` — sp_sustituirse → bdisitesp
- `sp_eliminarse` — elimina → bdisitesp
- `sp_registra_evento` — registra evento/notificación → bdimnsj

### genera fecha de pago de reestructura (de baja)
> SP: `sp_generafechpagoreestructura_baja` · fan_out 8 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `monthadd` — monthadd → bdicred
- `sp_registra_evento` — registra evento/notificación → bdimnsj

### consulta local alertas
> SP: `sp_cilocconsultaalertas` · fan_out 6 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_sustituirse` — sp_sustituirse → bdisitesp
- `sp_eliminarse` — elimina → bdisitesp

### consulta local marcas de cuenta
> SP: `sp_cilocconsultamarcas` · fan_out 6 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_sustituirse` — sp_sustituirse → bdisitesp
- `sp_eliminarse` — elimina → bdisitesp

### consulta local situaciones de cuenta y marcas de cuenta
> SP: `sp_cilocconsultasituacionesmarcas` · fan_out 6 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_sustituirse` — sp_sustituirse → bdisitesp
- `sp_eliminarse` — elimina → bdisitesp

### genera reporte, alertas y cliente
> SP: `sp_cilocgenerarptalertascte` · fan_out 6 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_sustituirse` — sp_sustituirse → bdisitesp
- `sp_eliminarse` — elimina → bdisitesp

### genera reporte, marcas de cuenta y cliente
> SP: `sp_cilocgenerarptmarcascte` · fan_out 6 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_sustituirse` — sp_sustituirse → bdisitesp
- `sp_eliminarse` — elimina → bdisitesp

### genera reporte, causa y cliente
> SP: `sp_cilocgenerarptsituacioncausacte` · fan_out 6 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_sustituirse` — sp_sustituirse → bdisitesp
- `sp_eliminarse` — elimina → bdisitesp

### genera reporte (total)
> SP: `sp_cilocgenerarpttotalalarmas` · fan_out 6 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_sustituirse` — sp_sustituirse → bdisitesp
- `sp_eliminarse` — elimina → bdisitesp

### genera reporte y marcas de cuenta (total)
> SP: `sp_cilocgenerarpttotalmarcas` · fan_out 6 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_sustituirse` — sp_sustituirse → bdisitesp
- `sp_eliminarse` — elimina → bdisitesp

## Servicios expuestos (endpoints — alto fan-in)

| SP | Objetivo | callers ext | reg |
|----|----------|------------:|:---:|
| `sp_inserta_bitacora_cob` | inserta bitácora | 197 |  |

## `[SME-PENDING]` Validación con Domain Expert

- [ ] Confirmar el nombre de negocio oficial de cada journey (los objetivos son inferidos del vocabulario).
- [ ] Validar el canal/actor real que dispara cada journey.
- [ ] Confirmar journeys no visibles en el call graph estático (triggers, EXEC dinámico).

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json + flow-data.json*