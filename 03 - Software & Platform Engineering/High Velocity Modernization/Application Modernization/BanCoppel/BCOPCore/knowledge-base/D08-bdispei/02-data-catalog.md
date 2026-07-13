# D08 · SPEI — Catálogo de Datos

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdispei` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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

Catálogo de tablas y entidades de datos identificadas mediante análisis estático de 197 archivos SQL del dominio `bdispei`. Las tablas están inferidas por las cláusulas `FROM`, `INSERT INTO`, `UPDATE`, `DELETE FROM` en el código SPL.

> **Limitación:** El esquema real (columnas, tipos, constraints) requiere conexión directa a la instancia Informix (`sysmaster`, `systables`, `syscolumns`). Las columnas están marcadas como `[SME-PENDING]`.

## Resumen de SPs por tipo de operación

| Tipo | Cantidad | % |
|------|---------|---|
| General | 109 | 55% |
| Transacción financiera | 48 | 24% |
| Validación | 12 | 6% |
| Consulta / Lectura | 9 | 4% |
| Borrado / Cancelación | 7 | 3% |
| Actualización | 7 | 3% |
| Reporte / Cálculo | 3 | 1% |
| Inserción / Alta | 2 | 1% |

## Tablas propias del dominio `bdispei`

Tablas accedidas exclusivamente dentro de `bdispei` (inferidas de 80 archivos analizados):

| Tabla | Propietario (DB) | Descripción | Volumen estimado | Fuente |
|-------|-----------------|-------------|-----------------|--------|
| `CTRLTABLAS` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `END` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `IF` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `LENGTH` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `NoRegistros` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `NuevoPk` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `STATISTICS` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `aux1` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `aux2` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicheq` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdinteg` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdispei` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bditransfer` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodRet5` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodRet6` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodRet7` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodret` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCtaOper` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCuenta` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCuentaChq` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCveRastreo` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cDisponible` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cFlagSpei` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cFolioOrigen` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cIndDisponible` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cNumCte` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cNumTarjeta` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cStatus` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cStatusProc` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cTpoPersona` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cTranAbono` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cTranAbonoInt` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cTsaPond` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cargos_spei` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `chrSpeiActivo` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `codretfirma` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `dFechaHoy` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `dIva` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `dtFechaOp` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `en` | `bdispei` | [SME-PENDING] | [SME-PENDING] | Inferida del código |

> **[SME-PENDING]** Para cada tabla: confirmar nombre exacto, descripción de negocio, volumen aproximado de registros, y si es tabla de transacciones, catálogo o configuración.

## Tablas de dominios externos (acceso cross-DB)

Tablas en otras bases de datos accedidas por `bdispei` vía `FROM db:tabla` o `CALL db:sp()`:

| Tabla externa | DB propietaria | Tipo de acceso | Operación | Notas |
|--------------|---------------|---------------|-----------|-------|
| `bancos` | `paginterban, bdispeua` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `convenio_mn` | `terceros` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `sc_acummesctanvl2` | `bdicheq` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `sc_bloqueo` | `bdicheq` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `sc_creditohipotecario` | `bdicheq` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `sc_ctabloqueo` | `bdicheq` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `sc_cuenta_telefono` | `bdicheq` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `sc_fechas` | `bdicheq` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `sc_limites_producto` | `bdicheq` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `sc_maechq` | `bdicheq` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `sc_movdia` | `bdicheq` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `sc_movhis` | `bdicheq` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `sc_param` | `bdicheq` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `sc_tarjeta` | `bdicheq` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `sc_transacc_exentas_limprod` | `bdicheq` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `sd_cat_prod_finac` | `bdicred` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `si_cliente` | `bdinteg, bdicent` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `si_ctepm` | `bdinteg` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `si_ejecut` | `bdinteg` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |
| `si_fechas` | `bdinteg, bdicent` | Referencia cross-DB | Lectura | `bdispei` accede vía `CALL db:sp()` |

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
bdispei ←→ [dominio] : [entidad compartida]
bdispei ←→ [dominio] : [entidad compartida]
```

## Consideraciones para Etapa 2 (Data RE)

1. **Catálogo completo de tablas**: requiere `SELECT tabname FROM systables WHERE owner != 'informix'` en instancia viva
2. **Volumen real**: `SELECT COUNT(*) FROM bdispei:tabname` en ventana de mantenimiento
3. **Constraints implícitos**: Informix permite FKs sin declaración formal — deben inferirse del código
4. **Datos sensibles**: identificar campos PII/PCI-DSS antes de migrar a ambientes no-productivos

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdispei_*.sql*
