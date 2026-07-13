# D01 · Canal Digital Web — Catálogo de Datos

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicnweb` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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

Catálogo de tablas y entidades de datos identificadas mediante análisis estático de 2184 archivos SQL del dominio `bdicnweb`. Las tablas están inferidas por las cláusulas `FROM`, `INSERT INTO`, `UPDATE`, `DELETE FROM` en el código SPL.

> **Limitación:** El esquema real (columnas, tipos, constraints) requiere conexión directa a la instancia Informix (`sysmaster`, `systables`, `syscolumns`). Las columnas están marcadas como `[SME-PENDING]`.

## Resumen de SPs por tipo de operación

| Tipo | Cantidad | % |
|------|---------|---|
| General | 887 | 40% |
| Consulta / Lectura | 677 | 30% |
| Reporte / Cálculo | 188 | 8% |
| Validación | 159 | 7% |
| Actualización | 95 | 4% |
| Inserción / Alta | 67 | 3% |
| Transacción financiera | 63 | 2% |
| Borrado / Cancelación | 48 | 2% |

## Tablas propias del dominio `bdicnweb`

Tablas accedidas exclusivamente dentro de `bdicnweb` (inferidas de 80 archivos analizados):

| Tabla | Propietario (DB) | Descripción | Volumen estimado | Fuente |
|-------|-----------------|-------------|-----------------|--------|
| `1` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `11` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `14` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `15` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `17` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `3` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `4` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `5` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `6` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `7` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `9` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `BDIDIGITAL` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CHAR` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CHARINDEX` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `DE` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `DfechaSol` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Intercard` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `P_COD_RET` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SCodRet` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `STATISTICS` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SUBSTR` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `TRIM` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bServLun` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdiatmist` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdibi` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdiburo` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicheq` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicntchq` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicnweb` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicont` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicred` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdidigital` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdilide` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdinteg` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdinvers` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdiprospectos` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdirech` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdireports` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdirst` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdisac` | `bdicnweb` | [SME-PENDING] | [SME-PENDING] | Inferida del código |

> **[SME-PENDING]** Para cada tabla: confirmar nombre exacto, descripción de negocio, volumen aproximado de registros, y si es tabla de transacciones, catálogo o configuración.

## Tablas de dominios externos (acceso cross-DB)

Tablas en otras bases de datos accedidas por `bdicnweb` vía `FROM db:tabla` o `CALL db:sp()`:

| Tabla externa | DB propietaria | Tipo de acceso | Operación | Notas |
|--------------|---------------|---------------|-----------|-------|
| `Sac_MovimientosHistorial` | `BdiSac` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `acl_producto` | `bdiaclaracion` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `atm_tarjeta_admin` | `bdiatmist` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `bei_contratacion` | `bdibei` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `bei_servicio` | `bdibei` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `bitacora_msi` | `intercard` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `bpi_usuario` | `bdibpi` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `cb_param` | `bdicobranza` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `cb_rep_cart_quebrantar` | `bdicobranza` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `cce_cheques_det` | `bditef` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `cce_cheques_dev` | `bditef` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `cce_cheques_img` | `bditef` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `cce_detalle` | `bditef` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `cce_encabezado` | `bditef` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `cce_gransumario` | `bditef` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `cce_mapeo_cecoban` | `bditef` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `cce_param` | `bditef` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `cce_sumario` | `bditef` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `cce_usuarios_revision` | `bditef` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |
| `dg_params` | `BDIDIGITAL` | Referencia cross-DB | Lectura | `bdicnweb` accede vía `CALL db:sp()` |

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
bdicnweb ←→ [dominio] : [entidad compartida]
bdicnweb ←→ [dominio] : [entidad compartida]
```

## Consideraciones para Etapa 2 (Data RE)

1. **Catálogo completo de tablas**: requiere `SELECT tabname FROM systables WHERE owner != 'informix'` en instancia viva
2. **Volumen real**: `SELECT COUNT(*) FROM bdicnweb:tabname` en ventana de mantenimiento
3. **Constraints implícitos**: Informix permite FKs sin declaración formal — deben inferirse del código
4. **Datos sensibles**: identificar campos PII/PCI-DSS antes de migrar a ambientes no-productivos

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdicnweb_*.sql*
