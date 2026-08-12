# D04 · Cheques / Cuentas — Catálogo de Datos

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicheq` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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

Catálogo de tablas y entidades de datos identificadas mediante análisis estático de 1535 archivos SQL del dominio `bdicheq`. Las tablas están inferidas por las cláusulas `FROM`, `INSERT INTO`, `UPDATE`, `DELETE FROM` en el código SPL.

> **Limitación:** El esquema real (columnas, tipos, constraints) requiere conexión directa a la instancia Informix (`sysmaster`, `systables`, `syscolumns`). Las columnas están marcadas como `[SME-PENDING]`.

## Resumen de SPs por tipo de operación

| Tipo | Cantidad | % |
|------|---------|---|
| General | 953 | 62% |
| Consulta / Lectura | 173 | 11% |
| Reporte / Cálculo | 114 | 7% |
| Transacción financiera | 84 | 5% |
| Borrado / Cancelación | 61 | 3% |
| Actualización | 53 | 3% |
| Validación | 53 | 3% |
| Inserción / Alta | 44 | 2% |

## Tablas propias del dominio `bdicheq`

Tablas accedidas exclusivamente dentro de `bdicheq` (inferidas de 80 archivos analizados):

| Tabla | Propietario (DB) | Descripción | Volumen estimado | Fuente |
|-------|-----------------|-------------|-----------------|--------|
| `FROM` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `FechaHoy` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Interactivo` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `STATISTICS` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `analiza` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `aux_auditerr` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdibei` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicheq` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicnweb` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicred` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdinteg` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bditransfer` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCelularCli` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodRet` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodRet3` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodRetCR` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodRetCS` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodRetConsSdo` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodRetGF` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodRetIndicador` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodRetSp1` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodRetSpCons` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodRetSpReten` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cConsecutivoCentral` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCorreoCli` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCtaCargoInaccta` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCuenta` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCuenta_eje` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cDescripcionProducto` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cEmpresaEmpleado` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cExiste` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cFech_param` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cFech_param_ini` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cFechaAltaCta` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cFechaNacOConstitucion` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cFirmantes` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cHoraCierreSPEI` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cIvaCom` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cMensajeRet` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cMontoMin` | `bdicheq` | [SME-PENDING] | [SME-PENDING] | Inferida del código |

> **[SME-PENDING]** Para cada tabla: confirmar nombre exacto, descripción de negocio, volumen aproximado de registros, y si es tabla de transacciones, catálogo o configuración.

## Tablas de dominios externos (acceso cross-DB)

Tablas en otras bases de datos accedidas por `bdicheq` vía `FROM db:tabla` o `CALL db:sp()`:

| Tabla externa | DB propietaria | Tipo de acceso | Operación | Notas |
|--------------|---------------|---------------|-----------|-------|
| `acl_aclaracion` | `bdiaclaracion` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `cce_cheques_det` | `bditef` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `cce_cheques_dev` | `bditef` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `co_auxiliar` | `bdicont` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `co_ctrlpoliza` | `bdicont` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `productotarjeta` | `intercard` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `sac_movimientos` | `bdisac` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `sd_param` | `bdicred` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `sd_secpago` | `bdicred` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `sd_tarjeta` | `bdicred` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `se_ctessitespcte` | `bdisitesp` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `si_bancos` | `bdinteg` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `si_canales` | `bdinteg` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `si_catalog` | `bdinteg` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `si_cliente` | `bdinteg` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `si_cliente_nivel` | `bdinteg` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `si_ctepf` | `bdinteg` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `si_ctepm` | `bdinteg` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `si_cterelacionado` | `bdinteg` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |
| `si_ejecut` | `bdinteg` | Referencia cross-DB | Lectura | `bdicheq` accede vía `CALL db:sp()` |

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
bdicheq ←→ [dominio] : [entidad compartida]
bdicheq ←→ [dominio] : [entidad compartida]
```

## Consideraciones para Etapa 2 (Data RE)

1. **Catálogo completo de tablas**: requiere `SELECT tabname FROM systables WHERE owner != 'informix'` en instancia viva
2. **Volumen real**: `SELECT COUNT(*) FROM bdicheq:tabname` en ventana de mantenimiento
3. **Constraints implícitos**: Informix permite FKs sin declaración formal — deben inferirse del código
4. **Datos sensibles**: identificar campos PII/PCI-DSS antes de migrar a ambientes no-productivos

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdicheq_*.sql*
