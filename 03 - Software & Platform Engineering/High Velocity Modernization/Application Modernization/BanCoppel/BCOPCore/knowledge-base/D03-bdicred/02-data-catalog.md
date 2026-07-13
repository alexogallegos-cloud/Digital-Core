# D03 · Créditos — Catálogo de Datos

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicred` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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

Catálogo de tablas y entidades de datos identificadas mediante análisis estático de 1650 archivos SQL del dominio `bdicred`. Las tablas están inferidas por las cláusulas `FROM`, `INSERT INTO`, `UPDATE`, `DELETE FROM` en el código SPL.

> **Limitación:** El esquema real (columnas, tipos, constraints) requiere conexión directa a la instancia Informix (`sysmaster`, `systables`, `syscolumns`). Las columnas están marcadas como `[SME-PENDING]`.

## Resumen de SPs por tipo de operación

| Tipo | Cantidad | % |
|------|---------|---|
| General | 1060 | 64% |
| Consulta / Lectura | 219 | 13% |
| Reporte / Cálculo | 121 | 7% |
| Transacción financiera | 96 | 5% |
| Inserción / Alta | 46 | 2% |
| Actualización | 44 | 2% |
| Borrado / Cancelación | 33 | 2% |
| Validación | 31 | 1% |

## Tablas propias del dominio `bdicred`

Tablas accedidas exclusivamente dentro de `bdicred` (inferidas de 80 archivos analizados):

| Tabla | Propietario (DB) | Descripción | Volumen estimado | Fuente |
|-------|-----------------|-------------|-----------------|--------|
| `1` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `5` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `6` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `7` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CanalSol` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CodRet` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CreditosCrd` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `DECIMAL` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `FechaHoy` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Interactivo` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `NumCredito` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `P_COD_RET` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `P_ERROR` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SD_CONCEPFINA` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SD_DETCOMI` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SD_DETCOMIHIPOT` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SD_DETMINIS` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SD_FECHAS` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SD_FUENTES_X_CRED` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SD_INDICADOR_CRED` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SD_MAECONTRATO` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SD_MAECRED` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SD_MAECREDANEXO` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SD_MAESDOS` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SD_MOVDIA` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SD_PAGINTER` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SD_PAGOCAPIT` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SD_REVTASA_HIST` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SD_UNIDADPROD` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SG_AVAL` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SG_COMER` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SG_FIDUC` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SG_FINAN` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SG_HIPOT` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SG_MAEGARAN` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SG_PREND` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SG_SEGUR` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Sd_amortiza_credito` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Sd_diferir` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Sd_maesdos` | `bdicred` | [SME-PENDING] | [SME-PENDING] | Inferida del código |

> **[SME-PENDING]** Para cada tabla: confirmar nombre exacto, descripción de negocio, volumen aproximado de registros, y si es tabla de transacciones, catálogo o configuración.

## Tablas de dominios externos (acceso cross-DB)

Tablas en otras bases de datos accedidas por `bdicred` vía `FROM db:tabla` o `CALL db:sp()`:

| Tabla externa | DB propietaria | Tipo de acceso | Operación | Notas |
|--------------|---------------|---------------|-----------|-------|
| `SS_CONCEPFINA` | `BDISOLIC` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `SS_DETCOMI` | `BDISOLIC` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `SS_DETCOMIHIPOT` | `BDISOLIC` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `SS_DETMINIS` | `BDISOLIC` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `SS_FUENTES_X_SOL` | `BDISOLIC` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `SS_MAECONTRATO` | `BDISOLIC` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `SS_SOLICITUDES` | `BDISOLIC` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `SS_UNIDADPROD` | `BDISOLIC` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `br_sc` | `bdiburo` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `cb_compac` | `bdicobranza` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `cb_rep_cart_quebrantar` | `bdicobranza` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `co_detpol` | `bdicont` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `co_poldet` | `bdicont` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `co_poliza` | `bdicont` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `sc_docret_sbc` | `bdicheq` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `sc_maechq` | `bdicheq` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `sc_tarjeta` | `bdicheq` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `sd_fechas` | `bdinteg` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `sdos_dia` | `axcred` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |
| `si_bitacora_ife` | `bdinteg` | Referencia cross-DB | Lectura | `bdicred` accede vía `CALL db:sp()` |

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
bdicred ←→ [dominio] : [entidad compartida]
bdicred ←→ [dominio] : [entidad compartida]
```

## Consideraciones para Etapa 2 (Data RE)

1. **Catálogo completo de tablas**: requiere `SELECT tabname FROM systables WHERE owner != 'informix'` en instancia viva
2. **Volumen real**: `SELECT COUNT(*) FROM bdicred:tabname` en ventana de mantenimiento
3. **Constraints implícitos**: Informix permite FKs sin declaración formal — deben inferirse del código
4. **Datos sensibles**: identificar campos PII/PCI-DSS antes de migrar a ambientes no-productivos

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdicred_*.sql*
