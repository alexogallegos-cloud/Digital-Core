# D01 · Canal Digital Web — Journeys de Negocio

> **Componente:** Informix · SPE-AM-001 · **Etapa 3 — Business Logic Extraction**
> **Base de datos:** `bdicnweb` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 6 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-04 · *generado del análisis del código (reemplaza plantilla)*

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de reglas)
- Domain Expert — BanCoppel (validación funcional de negocio)
- **SME — Modelo Operativo Bancario** (BIAN Service Domains · capacidades retail banking · cadena de valor · mapeo dominio técnico ↔ capacidad de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)


> Secciones marcadas `[SME-PENDING]` requieren validación del Domain Expert o SME regulador antes de BUILD.
---


## Resumen del dominio

`2,122 SPs` · **10 journeys orquestadores** · **0 servicios expuestos** · reguladores: —

Los journeys y sus objetivos se derivaron del call graph + vocabulario de negocio (`vocabulary-knowledge-base-bcop.md`). El nombre técnico del SP se conserva para trazabilidad.

## Journeys orquestadores

### cédula contable y nombre
> SP: `sp_cedulacontablenombre` · fan_out 124 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg
- `sp_consultaclienteseindividual` — consulta cliente y identificador → bdisitesp
- `sp_status_sol_audexcel2` — estatus, solicitud, auditoría y celular → bdicred
- `sp_evaldispefec_cred` — crédito → bdicred
- `sp_relacion_consultadatosrpt` — consulta datos y reporte → bdinteg
- `sp_cac_consultasolincrelincred` — consulta solicitud de crédito, crédito y línea de crédito → bdicred
- `sp_cac_asignasolanalista` — asigna solicitud y analista → bdicred

### consulta cédulas usuarios
> SP: `sp_conscedulasusuariosccl` · fan_out 124 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg
- `sp_consultaclienteseindividual` — consulta cliente y identificador → bdisitesp
- `sp_status_sol_audexcel2` — estatus, solicitud, auditoría y celular → bdicred
- `sp_evaldispefec_cred` — crédito → bdicred
- `sp_relacion_consultadatosrpt` — consulta datos y reporte → bdinteg
- `sp_cac_consultasolincrelincred` — consulta solicitud de crédito, crédito y línea de crédito → bdicred
- `sp_cac_asignasolanalista` — asigna solicitud y analista → bdicred

### consulta reportes cuentas inactivas · Art. 61 LIC
> SP: `sp_consreportesctasinactivasart61` · fan_out 124 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg
- `sp_consultaclienteseindividual` — consulta cliente y identificador → bdisitesp
- `sp_status_sol_audexcel2` — estatus, solicitud, auditoría y celular → bdicred
- `sp_evaldispefec_cred` — crédito → bdicred
- `sp_relacion_consultadatosrpt` — consulta datos y reporte → bdinteg
- `sp_cac_consultasolincrelincred` — consulta solicitud de crédito, crédito y línea de crédito → bdicred
- `sp_cac_asignasolanalista` — asigna solicitud y analista → bdicred

### consulta reportes cuentas inactivas (totales) · Art. 61 LIC
> SP: `sp_consreportesctasinactivasart61_totales` · fan_out 124 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg
- `sp_consultaclienteseindividual` — consulta cliente y identificador → bdisitesp
- `sp_status_sol_audexcel2` — estatus, solicitud, auditoría y celular → bdicred
- `sp_evaldispefec_cred` — crédito → bdicred
- `sp_relacion_consultadatosrpt` — consulta datos y reporte → bdinteg
- `sp_cac_consultasolincrelincred` — consulta solicitud de crédito, crédito y línea de crédito → bdicred
- `sp_cac_asignasolanalista` — asigna solicitud y analista → bdicred

### consulta fechas · Art. 61 LIC
> SP: `sp_consultafechasart61` · fan_out 124 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg
- `sp_consultaclienteseindividual` — consulta cliente y identificador → bdisitesp
- `sp_status_sol_audexcel2` — estatus, solicitud, auditoría y celular → bdicred
- `sp_evaldispefec_cred` — crédito → bdicred
- `sp_relacion_consultadatosrpt` — consulta datos y reporte → bdinteg
- `sp_cac_consultasolincrelincred` — consulta solicitud de crédito, crédito y línea de crédito → bdicred
- `sp_cac_asignasolanalista` — asigna solicitud y analista → bdicred

### consulta información, reporte y detalle
> SP: `sp_consultainforeportebc_detalleconsultas` · fan_out 124 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg
- `sp_consultaclienteseindividual` — consulta cliente y identificador → bdisitesp
- `sp_status_sol_audexcel2` — estatus, solicitud, auditoría y celular → bdicred
- `sp_evaldispefec_cred` — crédito → bdicred
- `sp_relacion_consultadatosrpt` — consulta datos y reporte → bdinteg
- `sp_cac_consultasolincrelincred` — consulta solicitud de crédito, crédito y línea de crédito → bdicred
- `sp_cac_asignasolanalista` — asigna solicitud y analista → bdicred

### obtiene imágenes y cliente (últimas)
> SP: `sp_obtieneultimasimagenesdigicte` · fan_out 124 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg
- `sp_consultaclienteseindividual` — consulta cliente y identificador → bdisitesp
- `sp_status_sol_audexcel2` — estatus, solicitud, auditoría y celular → bdicred
- `sp_evaldispefec_cred` — crédito → bdicred
- `sp_relacion_consultadatosrpt` — consulta datos y reporte → bdinteg
- `sp_cac_consultasolincrelincred` — consulta solicitud de crédito, crédito y línea de crédito → bdicred
- `sp_cac_asignasolanalista` — asigna solicitud y analista → bdicred

### bloquea cuenta reporte, cuentas y crédito (masivo)
> SP: `sp_reportebloqueoctasmasivocre` · fan_out 124 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg
- `sp_consultaclienteseindividual` — consulta cliente y identificador → bdisitesp
- `sp_status_sol_audexcel2` — estatus, solicitud, auditoría y celular → bdicred
- `sp_evaldispefec_cred` — crédito → bdicred
- `sp_relacion_consultadatosrpt` — consulta datos y reporte → bdinteg
- `sp_cac_consultasolincrelincred` — consulta solicitud de crédito, crédito y línea de crédito → bdicred
- `sp_cac_asignasolanalista` — asigna solicitud y analista → bdicred

### desbloquea cuenta reporte, cuentas y crédito (masivo)
> SP: `sp_reportedesbloqueoctasmasivocre` · fan_out 124 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg
- `sp_consultaclienteseindividual` — consulta cliente y identificador → bdisitesp
- `sp_status_sol_audexcel2` — estatus, solicitud, auditoría y celular → bdicred
- `sp_evaldispefec_cred` — crédito → bdicred
- `sp_relacion_consultadatosrpt` — consulta datos y reporte → bdinteg
- `sp_cac_consultasolincrelincred` — consulta solicitud de crédito, crédito y línea de crédito → bdicred
- `sp_cac_asignasolanalista` — asigna solicitud y analista → bdicred

### consulta usuario y cédula de identificación
> SP: `sp_usuariocedulacons` · fan_out 124 · callers externos 0 · disparado por: App/Batch/Canal

Secuencia de invocaciones (cadena del call graph):

- `sp_cnsif_confirmaejecutivo` — confirma ejecutivo → bdinteg
- `sp_consultaclienteseindividual` — consulta cliente y identificador → bdisitesp
- `sp_status_sol_audexcel2` — estatus, solicitud, auditoría y celular → bdicred
- `sp_evaldispefec_cred` — crédito → bdicred
- `sp_relacion_consultadatosrpt` — consulta datos y reporte → bdinteg
- `sp_cac_consultasolincrelincred` — consulta solicitud de crédito, crédito y línea de crédito → bdicred
- `sp_cac_asignasolanalista` — asigna solicitud y analista → bdicred

## `[SME-PENDING]` Validación con Domain Expert

- [ ] Confirmar el nombre de negocio oficial de cada journey (los objetivos son inferidos del vocabulario).
- [ ] Validar el canal/actor real que dispara cada journey.
- [ ] Confirmar journeys no visibles en el call graph estático (triggers, EXEC dinámico).

---
*Generado por update-knowledge-base.py · Etapa 3 · fuente: journeys-data.json + flow-data.json*