# D06 · Solicitudes — Catálogo de Datos

> **Componente:** Informix · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdisolic` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de código)
- Domain Expert — BanCoppel (validación funcional y de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- Risk Officer — Modernización (clasificación regulatoria CNBV)

> Toda sección marcada `[SME-PENDING]` requiere sesión de validación con el Domain Expert de BanCoppel antes de pasar a Etapa 2.
---


## Descripción

Catálogo de tablas y entidades de datos identificadas mediante análisis estático de 549 archivos SQL del dominio `bdisolic`. Las tablas están inferidas por las cláusulas `FROM`, `INSERT INTO`, `UPDATE`, `DELETE FROM` en el código SPL.

> **Limitación:** El esquema real (columnas, tipos, constraints) requiere conexión directa a la instancia Informix (`sysmaster`, `systables`, `syscolumns`). Las columnas están marcadas como `[SME-PENDING]`.

## Resumen de SPs por tipo de operación

| Tipo | Cantidad | % |
|------|---------|---|
| General | 266 | 48% |
| Consulta / Lectura | 129 | 23% |
| Reporte / Cálculo | 49 | 8% |
| Inserción / Alta | 32 | 5% |
| Actualización | 28 | 5% |
| Validación | 23 | 4% |
| Transacción financiera | 14 | 2% |
| Borrado / Cancelación | 8 | 1% |

## Tablas propias del dominio `bdisolic`

Tablas accedidas exclusivamente dentro de `bdisolic` (inferidas de 80 archivos analizados):

| Tabla | Propietario (DB) | Descripción | Volumen estimado | Fuente |
|-------|-----------------|-------------|-----------------|--------|
| `AUX_TR0001` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `BC_1` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `BDIBURO` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `BDISOLIC` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `B_ife` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `B_valida_ife` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Bandera` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Codret` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `HR0048` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `HR0050` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `IQ00012` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `IQ0002` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `P_NOMBRE` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SE` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `TR0001` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `TR0002` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `VI_Entidad_Localidad` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `VNuevoStatus` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `VTiempo` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `V_ciudad` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `V_coloniaCoppel` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `VfechaSolN` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `a` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `apellidopaterno` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `aun_prospecteo` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `ax_paso` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bandera_geo` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bandera_grupo5` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdiburo` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicheq` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicred` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdinteg` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdiprospectos` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdisolic` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cActivo` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cApellidoPaterno` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cBRM_reing` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCanal` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCanalSol` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCausa_sol` | `bdisolic` | [SME-PENDING] | [SME-PENDING] | Inferida del código |

> **[SME-PENDING]** Para cada tabla: confirmar nombre exacto, descripción de negocio, volumen aproximado de registros, y si es tabla de transacciones, catálogo o configuración.

## Tablas de dominios externos (acceso cross-DB)

Tablas en otras bases de datos accedidas por `bdisolic` vía `FROM db:tabla` o `CALL db:sp()`:

| Tabla externa | DB propietaria | Tipo de acceso | Operación | Notas |
|--------------|---------------|---------------|-----------|-------|
| `BR_TL` | `BDIBURO` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `SI_CLIENTE` | `BDINTEG` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `SI_TIPPER` | `BDINTEG` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `SS_SOLICITUDES` | `BDISOLIC` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `br_iq` | `bdiburo` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `br_rs` | `bdiburo` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `br_sc` | `bdiburo` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `br_sc_bc` | `bdiburo` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `br_scvsc` | `bdiburo` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `br_tl` | `bdiburo` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `br_tl_bc` | `bdiburo` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `br_tlmop` | `bdiburo` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `br_tlphp` | `bdiburo` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `br_tltco` | `bdiburo` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `dg_expediente` | `bdidigital` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `dg_expediente_img` | `bdidigital` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `pr_cliente` | `bdiprospectos` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `sb_regreso` | `bdiburo` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `sc_maechq` | `bdicheq` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |
| `sd_anexodefinicion` | `bdicred` | Referencia cross-DB | Lectura | `bdisolic` accede vía `CALL db:sp()` |

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
bdisolic ←→ [dominio] : [entidad compartida]
bdisolic ←→ [dominio] : [entidad compartida]
```

## Consideraciones para Etapa 2 (Data RE)

1. **Catálogo completo de tablas**: requiere `SELECT tabname FROM systables WHERE owner != 'informix'` en instancia viva
2. **Volumen real**: `SELECT COUNT(*) FROM bdisolic:tabname` en ventana de mantenimiento
3. **Constraints implícitos**: Informix permite FKs sin declaración formal — deben inferirse del código
4. **Datos sensibles**: identificar campos PII/PCI-DSS antes de migrar a ambientes no-productivos

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdisolic_*.sql*
