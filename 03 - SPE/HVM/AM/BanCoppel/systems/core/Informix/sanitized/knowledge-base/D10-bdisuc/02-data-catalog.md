# D10 · Sucursales — Catálogo de Datos

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdisuc` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de código)
- Domain Expert — LegacyCore (validación funcional y de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- Risk Officer — Modernización (clasificación regulatoria CNBV)

> Toda sección marcada `[SME-PENDING]` requiere sesión de validación con el Domain Expert de LegacyCore antes de pasar a Etapa 2.
---


## Descripción

Catálogo de tablas y entidades de datos identificadas mediante análisis estático de 293 archivos SQL del dominio `bdisuc`. Las tablas están inferidas por las cláusulas `FROM`, `INSERT INTO`, `UPDATE`, `DELETE FROM` en el código SPL.

> **Limitación:** El esquema real (columnas, tipos, constraints) requiere conexión directa a la instancia Informix (`sysmaster`, `systables`, `syscolumns`). Las columnas están marcadas como `[SME-PENDING]`.

## Resumen de SPs por tipo de operación

| Tipo | Cantidad | % |
|------|---------|---|
| General | 187 | 63% |
| Consulta / Lectura | 56 | 19% |
| Reporte / Cálculo | 14 | 4% |
| Inserción / Alta | 12 | 4% |
| Validación | 12 | 4% |
| Actualización | 8 | 2% |
| Borrado / Cancelación | 4 | 1% |

## Tablas propias del dominio `bdisuc`

Tablas accedidas exclusivamente dentro de `bdisuc` (inferidas de 80 archivos analizados):

| Tabla | Propietario (DB) | Descripción | Volumen estimado | Fuente |
|-------|-----------------|-------------|-----------------|--------|
| `1` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `4` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `7` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `BdiTarjeta` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Contador` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `FROM` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `INTEGER` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SMALLINT` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SS_Param_cajagen` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicont` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdinteg` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdisuc` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cAuxCons` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCaja` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCajaAnt` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCantidad` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cClave` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodRet` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodret` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cConsecutivoCaja` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cContraparte` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cDenominacion` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cDenominacion2` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cDesCvePieza` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cDesDictamen` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cDesEstatus` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cDesTipoPago` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cDescripcion` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cDictamen` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cEjecutivo` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cEstadoBanxico` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cEstadoDes` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cEstatus` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cEstatusSobrantre` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cFecha` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cFechaHoy` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cFolio_Oper` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cHoraAParam` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cIdProvCaja` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cIdentificacionDes` | `bdisuc` | [SME-PENDING] | [SME-PENDING] | Inferida del código |

> **[SME-PENDING]** Para cada tabla: confirmar nombre exacto, descripción de negocio, volumen aproximado de registros, y si es tabla de transacciones, catálogo o configuración.

## Tablas de dominios externos (acceso cross-DB)

Tablas en otras bases de datos accedidas por `bdisuc` vía `FROM db:tabla` o `CALL db:sp()`:

| Tabla externa | DB propietaria | Tipo de acceso | Operación | Notas |
|--------------|---------------|---------------|-----------|-------|
| `co_detpol` | `bdicont` | Referencia cross-DB | Lectura | `bdisuc` accede vía `CALL db:sp()` |
| `co_fechas` | `bdicont` | Referencia cross-DB | Lectura | `bdisuc` accede vía `CALL db:sp()` |
| `co_histsdodias` | `bdicont` | Referencia cross-DB | Lectura | `bdisuc` accede vía `CALL db:sp()` |
| `co_poldet` | `bdicont` | Referencia cross-DB | Lectura | `bdisuc` accede vía `CALL db:sp()` |
| `co_poldet_20240518` | `bdicont` | Referencia cross-DB | Lectura | `bdisuc` accede vía `CALL db:sp()` |
| `co_poliza` | `bdicont` | Referencia cross-DB | Lectura | `bdisuc` accede vía `CALL db:sp()` |
| `co_sdodias` | `bdicont` | Referencia cross-DB | Lectura | `bdisuc` accede vía `CALL db:sp()` |
| `si_catalog` | `bdinteg` | Referencia cross-DB | Lectura | `bdisuc` accede vía `CALL db:sp()` |
| `si_ejecut` | `bdinteg` | Referencia cross-DB | Lectura | `bdisuc` accede vía `CALL db:sp()` |
| `si_fechas` | `bdinteg` | Referencia cross-DB | Lectura | `bdisuc` accede vía `CALL db:sp()` |
| `si_metales` | `bdinteg` | Referencia cross-DB | Lectura | `bdisuc` accede vía `CALL db:sp()` |
| `si_param` | `bdinteg` | Referencia cross-DB | Lectura | `bdisuc` accede vía `CALL db:sp()` |
| `si_plazas` | `bdinteg` | Referencia cross-DB | Lectura | `bdisuc` accede vía `CALL db:sp()` |
| `si_plazas_cajagen` | `bdinteg` | Referencia cross-DB | Lectura | `bdisuc` accede vía `CALL db:sp()` |
| `si_regional` | `bdinteg` | Referencia cross-DB | Lectura | `bdisuc` accede vía `CALL db:sp()` |
| `si_sucursales` | `bdinteg` | Referencia cross-DB | Lectura | `bdisuc` accede vía `CALL db:sp()` |
| `si_transacc` | `bdinteg` | Referencia cross-DB | Lectura | `bdisuc` accede vía `CALL db:sp()` |
| `sysshmvals` | `sysmaster` | Referencia cross-DB | Lectura | `bdisuc` accede vía `CALL db:sp()` |

> **[SME-PENDING]** Validar ownership y acuerdos de acceso entre dominios. En el target, cada acceso cross-DB se convierte en llamada API o evento — requiere contrato de interfaz.

## Entidades de datos candidatas (modelado target)

Basado en el análisis de nombres de tablas, las siguientes **entidades de negocio** son candidatas para el modelo de datos target:

```
[SME-PENDING] Completar con Domain Expert:
- ¿Qué entidades son maestros (catálogos)?
- ¿Qué entidades son transaccionales?
- ¿Qué entidades son temporales / de staging?
- ¿Qué datos deben migrarse en la fase de cutover?
- ¿Qué datos históricos requieren archivado?
```

## Flujo de datos entre dominios

```
[SME-PENDING] Diagrama de flujo de datos:
bdisuc ←→ [dominio] : [entidad compartida]
bdisuc ←→ [dominio] : [entidad compartida]
```

## Consideraciones para Etapa 2 (Data RE)

1. **Catálogo completo de tablas**: requiere `SELECT tabname FROM systables WHERE owner != 'informix'` en instancia viva
2. **Volumen real**: `SELECT COUNT(*) FROM bdisuc:tabname` en ventana de mantenimiento
3. **Constraints implícitos**: Informix permite FKs sin declaración formal — deben inferirse del código
4. **Datos sensibles**: identificar campos PII/PCI-DSS antes de migrar a ambientes no-productivos

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdisuc_*.sql*
