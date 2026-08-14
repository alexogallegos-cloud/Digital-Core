# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Diccionario de Datos

> **Componente:** Informix · SPE-AM-001 · Etapa 2 — Schema Analysis
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---

## Nota sobre el origen de este diccionario

Este diccionario se construye desde el análisis estático del código SPL (variables, parámetros y columnas mencionadas en los 101 SPs). El schema real de las tablas solo puede obtenerse ejecutando `SELECT * FROM syscolumns WHERE tabid IN (SELECT tabid FROM systables WHERE tabname LIKE 'sl_%')` directamente en el motor Informix. `[DATO-REQUERIDO]` — DBA IBM Informix debe completar este diccionario con los tipos reales de syscolumns.

## Campos identificados en parámetros y variables de los SPs

| Campo / Variable | Tipo Informix inferido | Aparece en SP | Descripción inferida |
|-----------------|----------------------|---------------|----------------------|
| `paniomes` | `CHAR(6)` | `borramovs_movefechis` | Año y mes de proceso (AAAAMM) |
| `pFechaProceso` | `DATE` | `ejecutor_diario`, `sp_acumulacionoperaciones` | Fecha del proceso batch |
| `pCve_Usuario` | `CHAR(8)` | `ejecutor_diario`, `sp_acumulacionoperaciones` | Clave de usuario que ejecuta el proceso |
| `pFechaIni` | `DATE` | `sp_actparamtraspmovefec` | Fecha de inicio del rango de proceso |
| `pFechaFin` | `DATE` | `sp_actparamtraspmovefec` | Fecha de fin del rango de proceso |
| `pTipo` | `CHAR(1)` | `sp_actualizacodfechaenvio` | Tipo de archivo/proceso |
| `pNomArch` | `CHAR(16)` | `sp_actualizacodfechaenvio` | Nombre del archivo enviado |
| `pCod_Envio` | `CHAR(5)` | `sp_actualizacodfechaenvio` | Código de envío al regulador |
| `pStatus` | `CHAR(1)` | `sp_actualizacodfechaenvio` | Status del envío |
| `pcEmpresa` | `CHAR(3)` | `sp_actualizaide_31052013` | Código de empresa |
| `pRFC` | `CHAR(13)` | `sp_actualizainformesat`, `sp_actualizaresultadosat` | RFC del cliente (13 caracteres) |
| `cNumCte` | `CHAR(20)` | `sp_actualizarfclide` | Número de cliente BanCoppel |
| `cRfcAnt` | `CHAR(13)` | `sp_actualizarfclide` | RFC anterior del cliente |
| `cRfcActual` | `CHAR(13)` | `sp_actualizarfclide` | RFC actual del cliente |
| `cAnioMes1` | `CHAR(6)` | `sp_actualizarfclide` | Año-mes de inicio del rango (AAAAMM) |
| `cAnioMes2` | `CHAR(6)` | `sp_actualizarfclide` | Año-mes de fin del rango (AAAAMM) |
| `pEmpresa` | `CHAR(3)` | `sp_acumulacionoperaciones` | Código de empresa BanCoppel |
| `pFechaultimodia` | `DATE` | `sp_acumulacionoperaciones` | Fecha del último día del período |
| `pCurp` | `CHAR(18)` | `sp_checacurp` | CURP del cliente (18 caracteres) |

## Variables de control de proceso relevantes

| Variable | Tipo | SP | Significado |
|----------|------|----|-------------|
| `vmMontLimite` | `MONEY(16,2)` | `sp_acumulacionoperaciones` | Umbral PLD — monto límite para acumulación |
| `viPorcaRecau` | `MONEY(16,2)` | `sp_acumulacionoperaciones` | Porcentaje de recaudación IDE |
| `vmImpTotDep` | `MONEY` | `sp_acumulacionoperaciones` | Importe total de depósitos del período |
| `vmImpTotIde` | `MONEY` | `sp_acumulacionoperaciones` | Importe total IDE del período |
| `vmImpGrabar` | `MONEY` | `sp_acumulacionoperaciones` | Importe a grabar post-umbral |
| `vmMontoRecaudar` | `MONEY` | `sp_acumulacionoperaciones` | Monto de recaudación IDE calculado |
| `vcAnioMes2` | `CHAR(6)` | `sp_acumulacionoperaciones` | Año-mes de proceso |
| `vcNumCte` | `CHAR(20)` | `sp_acumulacionoperaciones` | Número de cliente en proceso |
| `vcRfc` | `CHAR(13)` | `sp_acumulacionoperaciones` | RFC del cliente en proceso |
| `vdFechaInsert` | `DATE` | `sp_acumulacionoperaciones` | Fecha de inserción del registro |
| `vcProceso` | `CHAR(10)` | `sp_acumulacionoperaciones` | Identificador del proceso batch |
| `vcTipoCta` | `CHAR(1)` | `sp_acumulacionoperaciones` | Tipo de cuenta (ahorro/cheques/crédito) |
| `vcNumReferencia` | `CHAR(20)` | `sp_acumulacionoperaciones` | Número de referencia de la operación |

## Campos de retorno estándar del dominio

El dominio usa una convención uniforme de retorno de error:

| Variable | Tipo | Convención |
|----------|------|-----------|
| `vcodret` / `vcCodRet` / `cCodRet` | `CHAR(5)` o `CHAR(6)` | Código de retorno del SP (ver tabla de códigos en `06-exceptions.md`) |
| `vsqlerr` / `iSql_Err` / `sql_err` | `INTEGER` | Código de error SQL de Informix |
| `isam_err` / `viIsamErr` | `INTEGER` | Código de error ISAM de Informix |
| `desc_err` / `vcDescErr` / `cMensaje` | `CHAR(50)` o `CHAR(60)` | Descripción del error |

## Convención de nomenclatura de tablas `bdilide`

| Prefijo | Significado | Ejemplos |
|---------|-------------|---------|
| `sl_` | Sistema LIDE/PLD (producción) | `sl_movefec`, `sl_retlide`, `sl_parametros` |
| `sl_*_his` | Histórico (archive) | `sl_movefec_his` |
| `sl_*temp` | Temporal de trabajo | `sl_exentostemp` |
| `sl_archivo*` | Archivos de intercambio regulatorio | `sl_archsat`, `sl_archivoconsulta`, `sl_archivocontrol` |
| `sl_con*` | Consultas/conciliación | `sl_consat` |

## `[SME-PENDING]`

- [ ] DBA IBM Informix: completar este diccionario con tipos reales de `syscolumns` y longitudes exactas.
- [ ] Identificar campos regulatorios obligatorios (campos que deben reportarse a CNBV/SHCP/SAT).
- [ ] Confirmar si `vmMontLimite` ($7,500 USD equiv. MXN) y `viPorcaRecau` están en `sl_parametros` o hardcodeados.
- [ ] Documentar el ciclo de vida de `sl_exentos` — ¿se sincroniza desde el SAT automáticamente?

---
*Generado: análisis estático bdilide · 2026-08-03*
