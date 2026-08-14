# D09 · Mensajería — Catálogo de Datos

> **Componente:** Informix · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdimnsj` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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

Catálogo de tablas y entidades de datos identificadas mediante análisis estático de 47 archivos SQL del dominio `bdimnsj`. Las tablas están inferidas por las cláusulas `FROM`, `INSERT INTO`, `UPDATE`, `DELETE FROM` en el código SPL.

> **Limitación:** El esquema real (columnas, tipos, constraints) requiere conexión directa a la instancia Informix (`sysmaster`, `systables`, `syscolumns`). Las columnas están marcadas como `[SME-PENDING]`.

## Resumen de SPs por tipo de operación

| Tipo | Cantidad | % |
|------|---------|---|
| General | 27 | 57% |
| Inserción / Alta | 11 | 23% |
| Actualización | 3 | 6% |
| Reporte / Cálculo | 3 | 6% |
| Validación | 2 | 4% |
| Transacción financiera | 1 | 2% |

## Tablas propias del dominio `bdimnsj`

Tablas accedidas exclusivamente dentro de `bdimnsj` (inferidas de 47 archivos analizados):

| Tabla | Propietario (DB) | Descripción | Volumen estimado | Fuente |
|-------|-----------------|-------------|-----------------|--------|
| `12` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `STATISTICS` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bandera` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicheq` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicred` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdimnsj` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdinteg` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodAlerta` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodRet` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodRet2` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCodRetSp` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCompany` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cDia` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cFechaSolitud` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cMaxregistros` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cNomCiudad` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cNomEstado` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cNumCte` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cNumCte2` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cPCodRet` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cPCodRet1` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cPCodRet2` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cPCodRet3` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cPCodRet4` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cPCodRet5` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cPais` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cSucursal` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `claveSinonimo` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cod_ret` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cod_ret2` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `dSecuencia` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `existe` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `iActInac` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `iExist` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `iexiste` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `iexiste2` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `iexiste3` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `iexistec` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `iprioridad` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `mnsj_cat_sinonimos` | `bdimnsj` | [SME-PENDING] | [SME-PENDING] | Inferida del código |

> **[SME-PENDING]** Para cada tabla: confirmar nombre exacto, descripción de negocio, volumen aproximado de registros, y si es tabla de transacciones, catálogo o configuración.

## Tablas de dominios externos (acceso cross-DB)

Tablas en otras bases de datos accedidas por `bdimnsj` vía `FROM db:tabla` o `CALL db:sp()`:

| Tabla externa | DB propietaria | Tipo de acceso | Operación | Notas |
|--------------|---------------|---------------|-----------|-------|
| `sc_cuenta_telefono` | `bdicheq` | Referencia cross-DB | Lectura | `bdimnsj` accede vía `CALL db:sp()` |
| `sd_fechas` | `bdicred` | Referencia cross-DB | Lectura | `bdimnsj` accede vía `CALL db:sp()` |
| `si_bitsmstels` | `bdinteg` | Referencia cross-DB | Lectura | `bdimnsj` accede vía `CALL db:sp()` |
| `si_ciudades` | `bdinteg` | Referencia cross-DB | Lectura | `bdimnsj` accede vía `CALL db:sp()` |
| `si_cliente` | `bdinteg` | Referencia cross-DB | Lectura | `bdimnsj` accede vía `CALL db:sp()` |
| `si_ctepf` | `bdinteg` | Referencia cross-DB | Lectura | `bdimnsj` accede vía `CALL db:sp()` |
| `si_estados` | `bdinteg` | Referencia cross-DB | Lectura | `bdimnsj` accede vía `CALL db:sp()` |
| `si_ptf` | `bdinteg` | Referencia cross-DB | Lectura | `bdimnsj` accede vía `CALL db:sp()` |
| `si_sucursales` | `bdinteg` | Referencia cross-DB | Lectura | `bdimnsj` accede vía `CALL db:sp()` |
| `si_telefonos` | `bdinteg` | Referencia cross-DB | Lectura | `bdimnsj` accede vía `CALL db:sp()` |
| `si_telefonos_actual` | `bdinteg` | Referencia cross-DB | Lectura | `bdimnsj` accede vía `CALL db:sp()` |
| `syscheckpoint` | `sysmaster` | Referencia cross-DB | Lectura | `bdimnsj` accede vía `CALL db:sp()` |
| `tarjeta` | `intercard` | Referencia cross-DB | Lectura | `bdimnsj` accede vía `CALL db:sp()` |

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
bdimnsj ←→ [dominio] : [entidad compartida]
bdimnsj ←→ [dominio] : [entidad compartida]
```

## Consideraciones para Etapa 2 (Data RE)

1. **Catálogo completo de tablas**: requiere `SELECT tabname FROM systables WHERE owner != 'informix'` en instancia viva
2. **Volumen real**: `SELECT COUNT(*) FROM bdimnsj:tabname` en ventana de mantenimiento
3. **Constraints implícitos**: Informix permite FKs sin declaración formal — deben inferirse del código
4. **Datos sensibles**: identificar campos PII/PCI-DSS antes de migrar a ambientes no-productivos

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdimnsj_*.sql*
