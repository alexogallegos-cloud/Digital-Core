# Análisis WAS — BanCoppel Informix · revision-ofiweb-20261031
> Generado: 2026-11-04 15:30 · `generators/analyze-was-logs.py` v1.0

## Contexto

Estos logs corresponden a la **capa Java/SOAP (IBM WebSphere 9.0.5.15 / AIX 7.2)** que envuelve el core Informix IDS 14.10. No son logs del motor Informix directamente — son del middleware Java que expone los Stored Procedures como SOAP web services.

**Stack observado:**
```
Cliente (sucursal/caja)  →  WAS ClusterMember1_OfiWeb  →  SOAP  →  Informix SP
  BcplSucApp / CajaNacionalApp        Spring MVC                  core bancario
```

**Nota de trazabilidad:** los nombres de operación SOAP (PascalCase, p. ej. `SpgeneraReportePpWeb`) corresponden a contratos Java, no necesariamente 1:1 con los nombres snake_case de los SPs en brain.db. La correspondencia requiere inspección del código fuente Java.

## Servidores analizados

| Nodo | Archivos | Líneas totales | SOAP resp | HTTP ops |
|------|----------|---------------|-----------|----------|
| `puresys38` | 10 | 1,880,751 | 481,951 | 0 |

## Resumen ejecutivo

| Métrica | Valor |
|---------|-------|
| Operaciones SOAP distintas | 410 |
| Llamadas SOAP totales (responses) | 481,951 |
| Llamadas con retcode negativo | 290 (0.06%) |
| Endpoints HTTP (business) | 0 |
| Llamadas HTTP (business) | 0 |
| Excepciones Java distintas | 3 |
| Total excepciones capturadas | 1,204 |
| Contextos SOAP activos | 52 |

### Contextos SOAP (grupos de aplicación)

| Contexto | Llamadas | % |
|----------|----------|---|
| `Caja` | 235,320 | 48.8% |
| `CajaCliente` | 178,299 | 37.0% |
| `CajaCaptacion` | 118,950 | 24.7% |
| `ObtenerFec` | 116,281 | 24.1% |
| `Caja2` | 78,137 | 16.2% |
| `Cliente2` | 59,616 | 12.4% |
| `SolicitudesCred` | 58,237 | 12.1% |
| `Login` | 42,851 | 8.9% |
| `Cliente` | 17,472 | 3.6% |
| `PagoServicios` | 11,099 | 2.3% |
| `DatosCliente` | 7,999 | 1.7% |
| `ExpedienteDigital` | 6,573 | 1.4% |
| `SistemaCredito` | 6,477 | 1.3% |
| `MantTarjeta` | 5,040 | 1.0% |
| `CuentaNomina` | 3,772 | 0.8% |
| `FamiliPpeSegclub` | 2,774 | 0.6% |
| `ServiciosTarj` | 2,772 | 0.6% |
| `CambioDeInstruccion` | 2,244 | 0.5% |
| `Nip` | 2,050 | 0.4% |
| `Caja3` | 1,750 | 0.4% |

## Catálogo de servicios SOAP

Ordenados por volumen de llamadas (solo operaciones con ≥5 respuestas).

| # | Operación | Llamadas | Errores (ret<0) | Err% | Retcodes principales |
|---|-----------|----------|----------------|------|----------------------|
| 1 | `ObtenerFecHoy` | 58,137 | 0 | 0.0% |  |
| 2 | `ConSdos2Web` | 31,699 | 0 | 0.0% | `00000`×31379, `00122`×198, `00100`×122 |
| 3 | `SpConsFlagreTarj` | 30,068 | 0 | 0.0% | `00000`×30068 |
| 4 | `SpObtCtesPreAprobadosNotificar` | 20,124 | 0 | 0.0% | `000000`×179445, `00000`×34, `000`×2, `00008`×1, `00116`×1 |
| 5 | `ConsultarHuellaCliente` | 18,101 | 0 | 0.0% | `000`×18076, `132`×25 |
| 6 | `SpValidarRostroCliente` | 17,571 | 0 | 0.0% |  |
| 7 | `SpObtParamSorteo` | 17,541 | 0 | 0.0% | `00000`×17541 |
| 8 | `SpValClubProteccionWeb` | 17,036 | 0 | 0.0% | `00000`×17036 |
| 9 | `ConsNumCte` | 15,992 | 0 | 0.0% | `00000`×15992 |
| 10 | `SpObtenerDatosCvWeb` | 15,816 | 0 | 0.0% |  |
| 11 | `AdmConsultaSuc` | 15,682 | 0 | 0.0% | `00000`×15682 |
| 12 | `SpObtenGrupoCliente` | 15,167 | 0 | 0.0% | `00000`×15167 |
| 13 | `SpConsultaCteN2` | 11,784 | 0 | 0.0% | `00002`×11784 |
| 14 | `ConsultarValorParametro` | 11,169 | 0 | 0.0% | `00000`×11169 |
| 15 | `SpObtenerParametroCheq` | 10,243 | 0 | 0.0% | `00000`×10243 |
| 16 | `SpConsultaPreAprobado` | 10,144 | 33 | 0.3% | `00008`×7676, `00000`×2266, `00002`×163, `-284`×33 ⚠, `00010`×4 |
| 17 | `ValorDivisaPesos` | 10,014 | 0 | 0.0% | `00000`×10014 |
| 18 | `CargoRef` | 9,695 | 0 | 0.0% | `000`×9691, `400`×4 |
| 19 | `ValFechasWeb` | 8,644 | 0 | 0.0% | `00000`×8633, `00809`×11 |
| 20 | `AbonoRefWeb` | 7,407 | 0 | 0.0% | `00000`×7396, `00301`×4, `00151`×4, `00959`×3 |
| 21 | `ValidaAbonoRefWeb` | 6,010 | 0 | 0.0% | `00000`×5814, `00371`×162, `00397`×31, `00374`×2, `00200`×1 |
| 22 | `AdmConsEjecutivo` | 5,742 | 0 | 0.0% | `00000`×5735, `02004`×7 |
| 23 | `SpConsParamBanderaProdWeb` | 5,376 | 0 | 0.0% | `00000`×5376 |
| 24 | `SpSorteoBancoppelWeb` | 5,347 | 0 | 0.0% | `00116`×5347 |
| 25 | `SpConsSdoGen` | 4,390 | 0 | 0.0% | `00000`×4390 |
| 26 | `SpGuardaTaggeoOneClick` | 4,279 | 0 | 0.0% |  |
| 27 | `ConsultarClienteNumCta` | 3,986 | 0 | 0.0% | `00000`×4031, `00100`×58, `00001`×15, `02200`×3 |
| 28 | `SpConsSolicCredMovilPopup` | 3,830 | 0 | 0.0% | `00000`×2767, `000`×1288 |
| 29 | `SpConsultaProducto` | 3,539 | 0 | 0.0% | `00000`×3538, `00002`×1 |
| 30 | `ConsSdos2Web` | 3,293 | 0 | 0.0% | `00000`×3278, `00398`×7, `00015`×4, `00100`×3, `00279`×1 |
| 31 | `SpObtieneParametro` | 2,916 | 0 | 0.0% | `00000`×2916 |
| 32 | `SpConsSdoTicketWeb` | 2,810 | 0 | 0.0% | `00000`×2810 |
| 33 | `spInserAlertaExlimblo` | 2,590 | 0 | 0.0% | `00000`×2590 |
| 34 | `SpValidaHuellaCteDec` | 2,368 | 0 | 0.0% | `00000`×2318, `00002`×50 |
| 35 | `SpValidaHuellaIneCte` | 2,361 | 0 | 0.0% | `00000`×2309, `00002`×52 |
| 36 | `SpObtenerNacCliente` | 2,317 | 0 | 0.0% | `00000`×2306, `00001`×11 |
| 37 | `ConsEdadCte` | 2,313 | 0 | 0.0% | `00000`×2313 |
| 38 | `SpGuardaPreAprobadoNotificar` | 2,186 | 0 | 0.0% | `00000`×2186 |
| 39 | `SpConsultaSaldoCorteMin` | 2,057 | 0 | 0.0% | `00000`×2057 |
| 40 | `SpValidaPreEdoCta` | 1,855 | 0 | 0.0% | `00000`×1855 |
| 41 | `SpConsultaSaldosCobranzaSucs` | 1,716 | 0 | 0.0% |  |
| 42 | `SpValidaCteHuella` | 1,485 | 0 | 0.0% | `00000`×1485 |
| 43 | `SpBuscarCtesaMigrarWeb` | 1,455 | 0 | 0.0% | `00000`×1271, `00001`×180 |
| 44 | `ConsultMovsWeb` | 1,431 | 0 | 0.0% | `00000`×7060 |
| 45 | `ConsultaEmpleado` | 1,406 | 0 | 0.0% | `00000`×1406 |
| 46 | `SpValFolSmsCoppelWeb` | 1,379 | 0 | 0.0% | `00000`×1377, `00001`×2 |
| 47 | `ObtDatosCaratula` | 1,373 | 0 | 0.0% | `00001`×1021, `00000`×352 |
| 48 | `SpDeterminaLineaPreAprobados` | 1,355 | 0 | 0.0% | `000003`×1203, `000010`×84, `000000`×68 |
| 49 | `SpObtClaveTarjeta` | 1,153 | 0 | 0.0% | `00000`×1145, `00001`×8 |
| 50 | `ConsImgNula` | 1,099 | 0 | 0.0% | `000`×1094, `00000`×5 |
| 51 | `InsertRegistroExp` | 1,094 | 0 | 0.0% | `000`×1094 |
| 52 | `InsertaImgPrevio` | 1,093 | 0 | 0.0% | `000`×1093 |
| 53 | `SpClienteVencidoBisWeb` | 1,033 | 0 | 0.0% | `00000`×1012, `00001`×15, `004`×6 |
| 54 | `PrincipalReferWeb` | 1,028 | 0 | 0.0% | `00000`×1027, `2665`×1 |
| 55 | `SpRegistroCteTitularCvWeb` | 1,015 | 0 | 0.0% | `00000`×1015 |
| 56 | `SpgeneraReportePpWeb` | 1,004 | 251 | 25.0% ⚠ | `00000`×630, `-1202`×251 ⚠, `00001`×123 |
| 57 | `ConsNomTit` | 999 | 0 | 0.0% | `000`×952, `100`×47 |
| 58 | `SpObtenerCtasCte2Web` | 995 | 0 | 0.0% |  |
| 59 | `AsignacionNipPinOffline` | 970 | 0 | 0.0% | `00`×970 |
| 60 | `SpGrabaRespCliente` | 970 | 0 | 0.0% | `00000`×970 |
| … | *(+243 operaciones con < llamadas)* | | | | |

### Servicios con errores (retcode negativo)

| Operación | Total calls | Errores | Err% | Retcodes de error |
|-----------|-------------|---------|------|------------------|
| `SpgeneraReportePpWeb` | 1,004 | 251 | 25.0% | `-1202`×251 |
| `SpConsultaPreAprobado` | 10,144 | 33 | 0.3% | `-284`×33 |
| `SpConsCteBpiWeb` | 71 | 5 | 7.0% | `-0001`×5 |
| `PaseContWeb` | 32 | 1 | 3.1% | `-268`×1 |

### Distribución horaria — SOAP responses (hora CST)

```
  00h                             0  ( 0.0%)
  01h                             0  ( 0.0%)
  02h                             0  ( 0.0%)
  03h                             0  ( 0.0%)
  04h                             0  ( 0.0%)
  05h                             0  ( 0.0%)
  06h                             0  ( 0.0%)
  07h                            24  ( 0.0%)
  08h                           749  ( 0.2%)
  09h  ████                  31,040  ( 6.4%)
  10h  ██████████████        99,670  (20.7%)
  11h  ██████████████████    134,151  (27.8%)
  12h  ████████████████████  142,089  (29.5%)
  13h  ██████████            73,949  (15.3%)
  14h                             0  ( 0.0%)
  15h                             0  ( 0.0%)
  16h                             0  ( 0.0%)
  17h                             0  ( 0.0%)
  18h                             0  ( 0.0%)
  19h                             0  ( 0.0%)
  20h                             0  ( 0.0%)
  21h                           244  ( 0.1%)
  22h                            35  ( 0.0%)
  23h                             0  ( 0.0%)
```

## Catálogo de excepciones Java

*Extraído de SystemErr.log — primera línea de cada stack trace.*

| Excepción | Ocurrencias | Mensaje más frecuente |
|-----------|-------------|----------------------|
| `BusinessException` | 669 | No se Encontro Sesión Asociada. |
| `NestedServletException` | 533 | Request processing failed; nested exception is java.lang.NullPointerException |
| `PersistenciaException` | 2 | mx.com.solser.persistence.cplasu.ws.exceptions.ClienteSoapException: Se presentó |

### Errores registrados en SystemOut (nivel ERROR)

| Clase | Ocurrencias | Mensaje frecuente |
|-------|-------------|------------------|
| `RemesasBusinessImpl` | 15,694 | TRANSACCION 8709 - BUSINESS - actualizó estado |
| `ProductosDaoImpl` | 3,772 | Ocurrió un error al intentar  consultar catalogos de productos  y/o estatus.null |
| `AfectaTablasBusinessImpl` | 2,505 | AFECTA TABLAS -- DIARIOS -- OBTENIENDO VDIARIOS |
| `VarqueoDesgloseBusiness` | 1,199 | VarqueoDesgloseBusiness ::: Obteniendo desglose de dotacion de la tabla VDESGDOT |
| `ParametrosWebBusiness` | 1,131 | null |
| `XmlMarshaller` | 1,055 | mx.com.solser.persistence.cplasu.ws.exceptions.XmlMarshallerException: Campo esp |
| `RestErrorHandler` | 943 | Se maneja Error, y se manda respuesta:Tarjeta cancelada/bloqueada |
| `BitacoraDaoImpl` | 454 | Alguno de los campos excede el número de caracteres permitido. |
| `PrestamoCoppelBusiness` | 105 | ERROR EN INICIO SESION REST - BUSINESS - Error: 404 Not Found, Causa: null |
| `VMovimientoDudosoDaoImpl` | 74 | validaExistenciaMovimientoDudoso :: No existe movimiento dudoso VMovimientoDudos |
| `SolicitudRecoleccionDotacionEfectivoImpl` | 38 | obtenerInformacion - Finaliza |
| `SeguimientoSolicCreditoBusiness` | 35 | Error al generar Reporte Contrato Múltiple Captación |
| `CancelacionCreditoBusiness` | 34 | Error al Consultar El Cliente de Retencion. Codigo de Retorno: 00002 |
| `SacWUCatCiudadesDAOImpl` | 24 | Error: |
| `HuellasBusiness` | 20 | Error al enviar la huella del cliente... |
| `StoredProcedureDaoImpl` | 18 | Error en FNCONSULTAITRAN.Required input parameter 'pSucursal' is missing |
| `Db2Access` | 18 | Error de conexion |
| `PagoDeCreditosBancoppelBusinessImpl` | 17 | null363 |
| `RetiroTarjetaDeCreditoBusinessImpl` | 14 | guardarSobranteCaja :mx.com.solser.cplasu.exception.PersistenciaException |
| `SiProdcutoDaoImpl` | 13 | Error al traer el campo valor de la tabla parametro |

## Endpoints HTTP (frontend → WAS)

*Solo operaciones de negocio (excluye activos estáticos).*

### Por contexto de aplicación

| Contexto | Llamadas | % |
|----------|----------|---|

### Top 50 operaciones HTTP

| # | Operación | Llamadas | Errores HTTP (≥400) |
|---|-----------|----------|---------------------|

### Distribución de códigos HTTP

| Status | Descripción | Llamadas |
|--------|-------------|----------|

## Señales para la migración Informix

Observaciones directamente relevantes para `SPE-AM-001`:

- **Tasa de error SOAP baja (0.06%)** — base sana para parallel-run; threshold del SLO DoD-SPE-AM-01 es ≤0.05% de divergencia.

- **Servicio con más errores:** `SpgeneraReportePpWeb` — 251 errores / 1,004 llamadas (25.0%). Investigar causa raíz antes del cutover de esta operación.

- **BusinessException: 669 ocurrencias** — mensajes principales: "No se Encontro Sesión Asociada."×669. Estas excepciones son reglas de negocio en la capa Java que deberán mapearse a equivalentes en la arquitectura target.

- **52 contextos SOAP activos** — `Caja`, `CajaCliente`, `CajaCaptacion`, `ObtenerFec`, `Caja2`, `Cliente2`, `SolicitudesCred`, `Login`. Cada contexto es un WAR/módulo Java independiente que envuelve SPs de Informix; cada uno requiere un Anti-Corruption Layer propio en el target.

- **Operaciones de mayor volumen:** `ObtenerFecHoy`×58,137, `ConSdos2Web`×31,699, `SpConsFlagreTarj`×30,068. Estas operaciones son candidatas prioritarias para parallel-run desde el inicio de BUILD.

---
*Evidencia: `source/logs/revision-ofiweb-20261031/` · Generado: 2026-11-04 15:30*