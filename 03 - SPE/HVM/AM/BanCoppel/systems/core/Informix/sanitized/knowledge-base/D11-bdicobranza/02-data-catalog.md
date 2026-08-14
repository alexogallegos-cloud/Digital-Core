# D11 · Cobranza — Catálogo de Datos

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicobranza` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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

Catálogo de tablas y entidades de datos identificadas mediante análisis estático de 311 archivos SQL del dominio `bdicobranza`. Las tablas están inferidas por las cláusulas `FROM`, `INSERT INTO`, `UPDATE`, `DELETE FROM` en el código SPL.

> **Limitación:** El esquema real (columnas, tipos, constraints) requiere conexión directa a la instancia Informix (`sysmaster`, `systables`, `syscolumns`). Las columnas están marcadas como `[SME-PENDING]`.

## Resumen de SPs por tipo de operación

| Tipo | Cantidad | % |
|------|---------|---|
| General | 187 | 60% |
| Consulta / Lectura | 46 | 14% |
| Reporte / Cálculo | 34 | 10% |
| Actualización | 14 | 4% |
| Transacción financiera | 14 | 4% |
| Inserción / Alta | 11 | 3% |
| Validación | 4 | 1% |
| Borrado / Cancelación | 1 | 0% |

## Tablas propias del dominio `bdicobranza`

Tablas accedidas exclusivamente dentro de `bdicobranza` (inferidas de 80 archivos analizados):

| Tabla | Propietario (DB) | Descripción | Volumen estimado | Fuente |
|-------|-----------------|-------------|-----------------|--------|
| `1` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Bdicobranza` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CB_INFO_PREVENTIVA` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CodRet2` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Codigo_Retorno` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CreditoAutoriza` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `MAXSecuencia` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `MAXSecuencia2` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `P_cod_ret` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `STATISTICS` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `TME_ENCABEZADOS` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `TME_ENCABEZADOSEXCEL` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `TRIM` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `VFecha_convenio` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `VLlamadas_exitosas` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `VLlamadas_no_exitosas` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `VNUmero_Llam` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `VNombre_campana` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Vempresa` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Vfecha_insert` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Vfh_insert` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Vnum_pagos` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `archivosacucomp_tmp` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `atento_movimientos` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `batch` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `batch_mmoras_reest` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `batch_mprev` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `batch_mprev_reest` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicobranza` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicred` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdinteg` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdisitesp` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdisolic` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cActivo` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cApellPaterno` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cApellidoPaterno` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cArch_captacion_pf1` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cArch_captacion_pf2` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cArch_captacion_pf3` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cArch_captacion_pm` | `bdicobranza` | [SME-PENDING] | [SME-PENDING] | Inferida del código |

> **[SME-PENDING]** Para cada tabla: confirmar nombre exacto, descripción de negocio, volumen aproximado de registros, y si es tabla de transacciones, catálogo o configuración.

## Tablas de dominios externos (acceso cross-DB)

Tablas en otras bases de datos accedidas por `bdicobranza` vía `FROM db:tabla` o `CALL db:sp()`:

| Tabla externa | DB propietaria | Tipo de acceso | Operación | Notas |
|--------------|---------------|---------------|-----------|-------|
| `CB_COMPAC` | `BDICOBRANZA` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `acl_producto` | `bdiaclaracion` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `cb_gestion_telefonica` | `Bdicobranza` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `cb_param` | `Bdicobranza` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `mnsjr_trx_batch` | `bdimnsj` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `mnsjr_trx_batch_his` | `bdimnsj` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `sc_maechq` | `bdicheq` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `sd_amortiza_credito` | `bdicred` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `sd_amortiza_creditocrd` | `bdicred` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `sd_cifracontroldirectorioaltasycambios` | `bdicred` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `sd_conceptospagomanual` | `bdicred` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `sd_conceptospagomanualcrd` | `bdicred` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `sd_ctascarg` | `bdicred` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `sd_directorioaltasycambios` | `bdicred` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `sd_fechas` | `bdicred` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `sd_grado_riesgo` | `bdicred` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `sd_hist_reserva` | `bdicred` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `sd_indicador_cred` | `bdicred` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `sd_indicador_cred_crd` | `bdicred` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |
| `sd_info_edocta` | `bdicred` | Referencia cross-DB | Lectura | `bdicobranza` accede vía `CALL db:sp()` |

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
bdicobranza ←→ [dominio] : [entidad compartida]
bdicobranza ←→ [dominio] : [entidad compartida]
```

## Consideraciones para Etapa 2 (Data RE)

1. **Catálogo completo de tablas**: requiere `SELECT tabname FROM systables WHERE owner != 'informix'` en instancia viva
2. **Volumen real**: `SELECT COUNT(*) FROM bdicobranza:tabname` en ventana de mantenimiento
3. **Constraints implícitos**: Informix permite FKs sin declaración formal — deben inferirse del código
4. **Datos sensibles**: identificar campos PII/PCI-DSS antes de migrar a ambientes no-productivos

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdicobranza_*.sql*
