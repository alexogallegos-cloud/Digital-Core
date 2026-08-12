# D07 · Aclaraciones — Catálogo de Datos

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdiaclaracion` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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

Catálogo de tablas y entidades de datos identificadas mediante análisis estático de 232 archivos SQL del dominio `bdiaclaracion`. Las tablas están inferidas por las cláusulas `FROM`, `INSERT INTO`, `UPDATE`, `DELETE FROM` en el código SPL.

> **Limitación:** El esquema real (columnas, tipos, constraints) requiere conexión directa a la instancia Informix (`sysmaster`, `systables`, `syscolumns`). Las columnas están marcadas como `[SME-PENDING]`.

## Resumen de SPs por tipo de operación

| Tipo | Cantidad | % |
|------|---------|---|
| Consulta / Lectura | 94 | 40% |
| General | 70 | 30% |
| Reporte / Cálculo | 30 | 12% |
| Inserción / Alta | 13 | 5% |
| Validación | 11 | 4% |
| Actualización | 5 | 2% |
| Borrado / Cancelación | 5 | 2% |
| Transacción financiera | 4 | 1% |

## Tablas propias del dominio `bdiaclaracion`

Tablas accedidas exclusivamente dentro de `bdiaclaracion` (inferidas de 80 archivos analizados):

| Tabla | Propietario (DB) | Descripción | Volumen estimado | Fuente |
|-------|-----------------|-------------|-----------------|--------|
| `0` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `1` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `ACL_RECUPERACION_SALDOS` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `BDINTEG` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CSecuencia` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CSecuencia_acl_mov` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `CnumCuenta` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Ctrans_no_procede` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `DiasCalc` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Es_Nacional` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `Ipky_movimiento` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `STATISTICS` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `accionBitacora` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_aclaracion` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_asociacion_origen` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_asociacion_origen_evento_canal` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_bitacora_cambio_pass` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_bitacora_eventos_siem` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_cat_bines` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_cat_datosnoconv` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_cat_tipo_aclaracion` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_cat_tokenPY` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_cierre_masivo` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_concentrado_robo_identidad` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_control_cuentas_pendientes_cancelar` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_control_r27` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_entrada_bitacora` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_estatus_aclaracion` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_estatus_canales` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_estatus_corporativo` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_folio_Aclaracion` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_folio_aclaracion_acl_aclaracion` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_integracion_cta` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_movimiento` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_no_procedenterbt` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_notificacion_det` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_origen_Evento` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_origen_evento` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_producto` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |
| `acl_rango_importe` | `bdiaclaracion` | [SME-PENDING] | [SME-PENDING] | Inferida del código |

> **[SME-PENDING]** Para cada tabla: confirmar nombre exacto, descripción de negocio, volumen aproximado de registros, y si es tabla de transacciones, catálogo o configuración.

## Tablas de dominios externos (acceso cross-DB)

Tablas en otras bases de datos accedidas por `bdiaclaracion` vía `FROM db:tabla` o `CALL db:sp()`:

| Tabla externa | DB propietaria | Tipo de acceso | Operación | Notas |
|--------------|---------------|---------------|-----------|-------|
| `bines` | `intercard` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `binproducto` | `intercard` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `bit_pinoffline` | `intercard` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `bitacora_fda` | `intercard` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `bitacoracambiosstatustarjeta` | `intercard` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `bitacoracambiostarjeta` | `intercard` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `bitacoracancelaciontarjetas` | `intercard` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `bitacorapinoffline` | `intercard` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `mnsjr_trx_online` | `bdimnsj` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `mnsjr_trx_online_his` | `bdimnsj` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `movimiento` | `intercard` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `movimientohistorico` | `intercard` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `sc_bloqueo` | `bdicheq` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `sc_fechas` | `bdicheq` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `sc_maechq` | `bdicheq` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `sc_maenoc` | `bdicheq` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `sc_movdia` | `bdicheq` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `sc_movhis` | `bdicheq` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `sc_movhis_old` | `bdicheq` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |
| `sc_opcionbloqueo` | `bdicheq` | Referencia cross-DB | Lectura | `bdiaclaracion` accede vía `CALL db:sp()` |

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
bdiaclaracion ←→ [dominio] : [entidad compartida]
bdiaclaracion ←→ [dominio] : [entidad compartida]
```

## Consideraciones para Etapa 2 (Data RE)

1. **Catálogo completo de tablas**: requiere `SELECT tabname FROM systables WHERE owner != 'informix'` en instancia viva
2. **Volumen real**: `SELECT COUNT(*) FROM bdiaclaracion:tabname` en ventana de mantenimiento
3. **Constraints implícitos**: Informix permite FKs sin declaración formal — deben inferirse del código
4. **Datos sensibles**: identificar campos PII/PCI-DSS antes de migrar a ambientes no-productivos

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdiaclaracion_*.sql*
