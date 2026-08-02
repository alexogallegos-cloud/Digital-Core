# Validación de Fidelidad — Modelo de Datos SAP Core Banking

> **Emisor:** SME SAP Banking Services (`SME/Platform/SAP/SAP Banking Services/`)
> **Objeto:** `seed-sap-banking-ecc-scale-graph` (~1,500 tablas) del Reference Data Lab
> **Propósito:** gate de credibilidad antes de que `Data Migration · Fase 1` consuma el modelo
> **Fecha:** 2026-05-31

## Veredicto

**`APROBADO`** (rev. 2 · 2026-06-01) — el modelo es **fiel al patrón de un core bancario sobre SAP** y apto para entrenamiento/discovery y demos internas (`[uso interno]`, sin IP de cliente). El `[GAP 1]` de nomenclatura (rev. 1) quedó **cerrado**: ahora usa nombres de tabla SAP reales por módulo. Observaciones residuales menores abajo.

> Rev. 1 (2026-05-31) fue `APROBADO CON OBSERVACIONES`; el cierre del GAP de nombres elevó el veredicto a `APROBADO`.

## Validación por criterio

| Criterio | Resultado | Nota |
|----------|-----------|------|
| Cobertura de módulos | ✅ | BP · FS-AM/BCA · FS-CML · FI-GL · CO · payments · cards · channels · collateral · DMEE — refleja un core bancario SAP realista |
| Arquetipos de tabla | ✅ | master / transaccional / texto / customizing / totales en proporciones plausibles (master ~8%, txn ~48%, cust ~24%) |
| Tablas hub | ✅ | `T001` (company code, fan-in 909), `TCURC/TCURX` (moneda), `SKA1/SKB1` (GL), `BUT000` (Business Partner) son **exactamente** las que SAP referencia transversalmente |
| Semántica de FK | ✅ | columnas FK correctas: BUKRS→T001, WAERS→TCURC/TCURX, PARTNER→BUT000, SAKNR→SKA1 |
| Convenciones de campo | ✅ | MANDT (CLNT), claves ALPHA con ceros, DATS, CURR + TCURX por moneda — correcto |
| Acoplamiento transversal | ✅ | 26 tablas compartidas ≥3 módulos; el patrón (customizing/master comunes) es el real |
| Nomenclatura | ✅ | hubs reales (BUT000/T001/SKA1/...) + tablas prominentes reales por módulo (BSEG/BKPF/BKK40/BKKIT/VDARL/VDBEPP/REGUH/FEBEP/COEP/CMS_OBJ...); la cola larga usa el **prefijo de familia SAP real** por módulo (BKK*/VD*/BS*/FEB*/CMS*/CO*/REGU*) + secuencia |

## Observaciones / `[GAP]`

1. `[RESUELTO rev.2]` **Nomenclatura**: las ~1,500 tablas usan nombres SAP reales — las prominentes con su nombre exacto (curadas por módulo) y la cola larga con el prefijo de familia real + secuencia (p. ej. BKK137, VD142). `[OBSERVACIÓN residual]` la cola larga no es un mapeo 1:1 al diccionario DDIC completo (sería un catálogo exhaustivo), pero ya no hay nombres no-SAP.
2. `[OBSERVACIÓN]` **DDL por tabla es de referencia**: los esquemas son ilustrativos (tipos SAP plausibles), no el diccionario de datos SAP campo-por-campo. Las columnas FK sí corresponden 1:1 a las aristas del grafo (correcto para discovery).
3. `[OBSERVACIÓN]` **Tablas aisladas (~165)**: customizing sin referencias entrantes. Es realista (mucho customizing SAP queda sin uso → RETIRE), pero la proporción es algo alta; aceptable para ejercitar el hallazgo de dead/retire.

## Nota de credibilidad para el deliverable

Lo que SÍ se puede afirmar: *"modelo de referencia de un core bancario SAP, validado en fidelidad por SME SAP Banking Services, sin IP/PII de cliente — topología, hubs, módulos y acoplamiento fieles al patrón SAP for Banking"*.
Lo que NO se debe afirmar: que provenga de un cliente real, ni que el catálogo de nombres/campos sea el diccionario SAP exacto.

**Habilitación:** con este sign-off (`APROBADO`), `Data Migration · Fase 1` consume el modelo como base creíble para el discovery a escala, incluyendo showcase. Única salvedad residual: la cola larga de nombres no es el diccionario DDIC exhaustivo (no bloqueante).

---
*SME SAP Banking Services · sub del SME SAP · `[GATE]` de fidelidad del Reference Data Lab.*