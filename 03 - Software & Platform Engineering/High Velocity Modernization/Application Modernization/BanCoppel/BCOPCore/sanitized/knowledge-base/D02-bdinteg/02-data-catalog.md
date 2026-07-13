# D02 · Integración y Autenticación — Catálogo de Datos

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdinteg` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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

Catálogo de tablas y entidades de datos identificadas mediante análisis estático de 2034 archivos SQL del dominio `bdinteg`. Las tablas están inferidas por las cláusulas `FROM`, `INSERT INTO`, `UPDATE`, `DELETE FROM` en el código SPL.

> **Limitación:** El esquema real (columnas, tipos, constraints) requiere conexión directa a la instancia Informix (`sysmaster`, `systables`, `syscolumns`). Las columnas están marcadas como `[SME-PENDING]`.

## Resumen de SPs por tipo de operación

| Tipo | Cantidad | % |
|------|---------|---|
| General | 1060 | 52% |
| Consulta / Lectura | 461 | 22% |
| Validación | 137 | 6% |
| Reporte / Cálculo | 129 | 6% |
| Inserción / Alta | 109 | 5% |
| Actualización | 102 | 5% |
| Borrado / Cancelación | 29 | 1% |
| Transacción financiera | 7 | 0% |

## Tablas propias del dominio `bdinteg`

Tablas accedidas exclusivamente dentro de `bdinteg` (inferidas de 80 archivos analizados):

| Tabla | Propietario (DB) | Descripción | Volumen estimado | Fuente |
|-------|-----------------|-------------|-----------------|--------|
| `1` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `2` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `3` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `4` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `RMONTO_FINANCIADO` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SD_MAECRED` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SFolio` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SI_CORREOS` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SI_CTEPF` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `SNumTel` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `STATISTICS` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `TRIM` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `V_REG` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `V_TOT_REG` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `ax_fecha` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `axel` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bBoolValue` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdibei` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdibpi` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicheq` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicntchq` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicnweb` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdicred` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdidigital` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdinteg` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdinvers` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdiprog` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdiprospectos` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdirepaut` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdisitesp` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bdisolic` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bditarjcop` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `bditransfer` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cActividadGiro` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cApellPaterContactoRepLeg` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cApellPaterFirmantes` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cBanPresDescrip` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cBanRecDescrip` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCURP` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `cCalleFiscal` | `bdinteg` | [SME-PENDING] | [SME-PENDING] | Inferida del código |

> **[SME-PENDING]** Para cada tabla: confirmar nombre exacto, descripción de negocio, volumen aproximado de registros, y si es tabla de transacciones, catálogo o configuración.

## Tablas de dominios externos (acceso cross-DB)

Tablas en otras bases de datos accedidas por `bdinteg` vía `FROM db:tabla` o `CALL db:sp()`:

| Tabla externa | DB propietaria | Tipo de acceso | Operación | Notas |
|--------------|---------------|---------------|-----------|-------|
| `Tipotarjeta` | `intercard` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `ax_paso` | `bdisolic` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `binproducto` | `intercard` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `cb_bitacora_cob` | `bdicobranza` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `co_detpol` | `bdicont` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `co_horas` | `bdicont` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `co_poliza` | `bdicont` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `detalle_maquila` | `intercard` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `dom_autorizaciones` | `bdidomi` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `dom_cce_detalle` | `bdidomi` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `dom_parametros` | `bdidomi` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `sac_fechas` | `bdisac` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `sc_fechas` | `bdicheq` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `sc_firmantes` | `bdicheq` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `sc_maechq` | `bdicheq` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `sc_maenoc` | `bdicheq` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `sc_movdia` | `bdicheq` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `sc_movhis` | `bdicheq` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `sc_movhis_old` | `bdicheq` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |
| `sc_movhis_old2` | `bdicheq` | Referencia cross-DB | Lectura | `bdinteg` accede vía `CALL db:sp()` |

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
bdinteg ←→ [dominio] : [entidad compartida]
bdinteg ←→ [dominio] : [entidad compartida]
```

## Consideraciones para Etapa 2 (Data RE)

1. **Catálogo completo de tablas**: requiere `SELECT tabname FROM systables WHERE owner != 'informix'` en instancia viva
2. **Volumen real**: `SELECT COUNT(*) FROM bdinteg:tabname` en ventana de mantenimiento
3. **Constraints implícitos**: Informix permite FKs sin declaración formal — deben inferirse del código
4. **Datos sensibles**: identificar campos PII/PCI-DSS antes de migrar a ambientes no-productivos

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdinteg_*.sql*
