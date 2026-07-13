# D05 · Saldos y Cuentas — Catálogo de Datos

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdisac` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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

Catálogo de tablas y entidades de datos identificadas mediante análisis estático de 563 archivos SQL del dominio `bdisac`. Las tablas están inferidas por las cláusulas `FROM`, `INSERT INTO`, `UPDATE`, `DELETE FROM` en el código SPL.

> **Limitación:** El esquema real (columnas, tipos, constraints) requiere conexión directa a la instancia Informix (`sysmaster`, `systables`, `syscolumns`). Las columnas están marcadas como `[SME-PENDING]`.

## Resumen de SPs por tipo de operación

| Tipo | Cantidad | % |
|------|---------|---|
| General | 201 | 35% |
| Reporte / Cálculo | 144 | 25% |
| Consulta / Lectura | 83 | 14% |
| Validación | 46 | 8% |
| Transacción financiera | 39 | 6% |
| Inserción / Alta | 27 | 4% |
| Actualización | 20 | 3% |
| Borrado / Cancelación | 3 | 0% |

## Tablas propias del dominio `bdisac`

Tablas accedidas exclusivamente dentro de `bdisac` (inferidas de 80 archivos analizados):

| Tabla | Propietario (DB) | Descripción | Volumen estimado | Fuente |
|-------|-----------------|-------------|-----------------|--------|
| `1` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `10` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `11` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `12` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `13` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `15` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `17` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `18` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `19` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `2` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `21` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `22` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `26` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `3` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `30` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `32` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `4` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `5` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `6` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `7` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `8` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `9` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `BDISAC` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Bdisac` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CDia` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CHARINDEX` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CTECREDITOSOL` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CTECREDITOSOL2` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CTECUENTAS` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CTE_HUELLA` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CdRetVerSis` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Cid_sucursal` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CodRetRev` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `DFecha_hoy_Sky` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Folio_Confirma` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `STATISTICS` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `TABLA` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `TBL_CLIENTES_TMP` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `TB_CONTEO` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `TB_SAC_ALTACTES_MINUTO_CTEPF` | `bdisac` | [SME-PENDING] | [SME-PENDING] | Inferida del código |

> **[SME-PENDING]** Para cada tabla: confirmar nombre exacto, descripción de negocio, volumen aproximado de registros, y si es tabla de transacciones, catálogo o configuración.

## Tablas de dominios externos (acceso cross-DB)

Tablas en otras bases de datos accedidas por `bdisac` vía `FROM db:tabla` o `CALL db:sp()`:

| Tabla externa | DB propietaria | Tipo de acceso | Operación | Notas |
|--------------|---------------|---------------|-----------|-------|
| `Sac_EGlobal_Archivos` | `BdiSac` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `Sac_EGlobal_Banco` | `BdiSac` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `Sac_EGlobal_Detalle` | `BdiSac` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `Sac_EGlobal_Encabezado` | `BdiSac` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `Sac_EGlobal_Mensajes_Error` | `BdiSac` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `Sac_EGlobal_NoConcil` | `BdiSac` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `Sac_EGlobal_Sumario` | `BdiSac` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `Sac_Param` | `BdiSac` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `Sac_Procesos` | `BdiSac` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `Sc_Bines` | `BdiCheq` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `Sc_Fechas` | `BdiCheq` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `Sc_MovDia` | `BdiCheq` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `Sc_MovHis` | `BdiCheq` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `Sc_Movhis` | `BdiCheq` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `co_sdodias` | `bdicont` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `sac_convenios` | `BDISAC` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `sac_fechas` | `Bdisac` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `sac_param` | `Bdisac` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `sc_contab` | `bdicheq` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |
| `sc_maechq` | `bdicheq` | Referencia cross-DB | Lectura | `bdisac` accede vía `CALL db:sp()` |

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
bdisac ←→ [dominio] : [entidad compartida]
bdisac ←→ [dominio] : [entidad compartida]
```

## Consideraciones para Etapa 2 (Data RE)

1. **Catálogo completo de tablas**: requiere `SELECT tabname FROM systables WHERE owner != 'informix'` en instancia viva
2. **Volumen real**: `SELECT COUNT(*) FROM bdisac:tabname` en ventana de mantenimiento
3. **Constraints implícitos**: Informix permite FKs sin declaración formal — deben inferirse del código
4. **Datos sensibles**: identificar campos PII/PCI-DSS antes de migrar a ambientes no-productivos

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdisac_*.sql*
