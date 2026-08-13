# Análisis WAS — BanCoppel Informix · 2026-08-07
> Generado: 2026-08-07 21:05 · `generators/analyze-was-logs.py` v1.0

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
| `10.27.31.20` | 6 | 1,280,955 | 282,751 | 557,222 |
| `10.27.31.32` | 6 | 1,141,141 | 251,643 | 1,767,594 |

## Resumen ejecutivo

| Métrica | Valor |
|---------|-------|
| Operaciones SOAP distintas | 466 |
| Llamadas SOAP totales (responses) | 534,394 |
| Llamadas con retcode negativo | 906 (0.17%) |
| Endpoints HTTP (business) | 797 |
| Llamadas HTTP (business) | 2,324,816 |
| Excepciones Java distintas | 4 |
| Total excepciones capturadas | 5,789 |
| Contextos SOAP activos | 53 |

### Contextos SOAP (grupos de aplicación)

| Contexto | Llamadas | % |
|----------|----------|---|
| `Caja` | 201,556 | 37.7% |
| `ObtenerFec` | 137,007 | 25.6% |
| `CajaCliente` | 128,604 | 24.1% |
| `SolicitudesCred` | 115,739 | 21.7% |
| `CajaCaptacion` | 94,165 | 17.6% |
| `Cliente2` | 89,688 | 16.8% |
| `Caja2` | 83,357 | 15.6% |
| `Login` | 62,847 | 11.8% |
| `Cliente` | 28,307 | 5.3% |
| `DatosCliente` | 18,094 | 3.4% |
| `AdmonSuC` | 16,348 | 3.1% |
| `SistemaCredito` | 13,142 | 2.5% |
| `ExpedienteDigital` | 12,952 | 2.4% |
| `MantTarjeta` | 11,025 | 2.1% |
| `PagoServicios` | 10,352 | 1.9% |
| `CuentaNomina` | 7,931 | 1.5% |
| `FamiliPpeSegclub` | 6,505 | 1.2% |
| `ServiciosTarj` | 5,689 | 1.1% |
| `CambioDeInstruccion` | 4,945 | 0.9% |
| `Nip` | 4,670 | 0.9% |

## Catálogo de servicios SOAP

Ordenados por volumen de llamadas (solo operaciones con ≥5 respuestas).

| # | Operación | Llamadas | Errores (ret<0) | Err% | Retcodes principales |
|---|-----------|----------|----------------|------|----------------------|
| 1 | `ObtenerFecHoy` | 68,504 | 0 | 0.0% |  |
| 2 | `SpObtCtesPreAprobadosNotificar` | 52,259 | 0 | 0.0% | `000000`×118129 |
| 3 | `ConSdos2Web` | 28,684 | 0 | 0.0% | `00000`×21043, `00004`×7413, `00122`×135, `00100`×93 |
| 4 | `AdmConsultaSuc` | 23,349 | 0 | 0.0% | `00000`×23349 |
| 5 | `SpConsFlagreTarj` | 19,829 | 0 | 0.0% | `00000`×19829 |
| 6 | `ConsultarHuellaCliente` | 16,919 | 0 | 0.0% | `000`×16805, `110`×98, `132`×16 |
| 7 | `SpConsParamBanderaProdWeb` | 12,431 | 0 | 0.0% | `00000`×12431 |
| 8 | `SpValidarRostroCliente` | 12,430 | 0 | 0.0% |  |
| 9 | `SpObtParamSorteo` | 11,701 | 0 | 0.0% | `00000`×11701 |
| 10 | `SpObtenerDatosCvWeb` | 11,534 | 0 | 0.0% |  |
| 11 | `ConsultarValorParametro` | 11,507 | 0 | 0.0% | `00000`×11507 |
| 12 | `ConsNumCte` | 11,422 | 381 | 3.3% | `00000`×11041, `-674`×381 ⚠ |
| 13 | `SpValClubProteccionWeb` | 11,310 | 0 | 0.0% | `00000`×11310 |
| 14 | `ValFechasWeb` | 10,269 | 0 | 0.0% | `00000`×10034, `00809`×235 |
| 15 | `SpObtenGrupoCliente` | 9,234 | 0 | 0.0% | `00000`×9234 |
| 16 | `ConsultarClienteNumCta` | 9,018 | 0 | 0.0% | `00000`×9136, `00100`×127, `00001`×25, `02200`×8 |
| 17 | `SpConsSolicCredMovilPopup` | 8,505 | 0 | 0.0% | `00000`×6165, `000`×3043 |
| 18 | `AdmConsEjecutivo` | 8,071 | 0 | 0.0% | `00000`×8053, `02004`×18 |
| 19 | `SpObtenerParametroCheq` | 7,443 | 0 | 0.0% | `00000`×7443 |
| 20 | `SpConsultaCteN2` | 7,108 | 0 | 0.0% | `00002`×7107, `00004`×1 |
| 21 | `SpConsultaPreAprobado` | 6,707 | 15 | 0.2% | `00008`×5009, `00000`×1568, `00002`×110, `-284`×15 ⚠, `00012`×5 |
| 22 | `AbonoRefWeb` | 6,621 | 0 | 0.0% | `00000`×6616, `00959`×3, `00301`×2 |
| 23 | `ValorDivisaPesos` | 5,517 | 0 | 0.0% | `00000`×5517 |
| 24 | `CargoRef` | 5,417 | 0 | 0.0% | `000`×5413, `300`×2, `200`×1, `400`×1 |
| 25 | `PaseContWeb2` | 5,382 | 0 | 0.0% | `00000`×5379, `00110`×3 |
| 26 | `SpConsSdoGen` | 4,847 | 0 | 0.0% | `00000`×4847 |
| 27 | `SpConsultaProducto` | 4,124 | 0 | 0.0% | `00000`×4124 |
| 28 | `ValidaAbonoRefWeb` | 4,014 | 0 | 0.0% | `00000`×3978, `00371`×36 |
| 29 | `SpSorteoBancoppelWeb` | 3,831 | 0 | 0.0% | `00116`×3831 |
| 30 | `ConsSdos2Web` | 3,766 | 0 | 0.0% | `00000`×3753, `00398`×6, `00015`×4, `00100`×3 |
| 31 | `spInserAlertaExlimblo` | 3,327 | 0 | 0.0% | `00000`×3327 |
| 32 | `SpConsSdoTicketWeb` | 3,200 | 0 | 0.0% | `00000`×3200 |
| 33 | `SpValidaCteHuella` | 3,055 | 0 | 0.0% | `00000`×3055 |
| 34 | `SpBuscarCtesaMigrarWeb` | 3,012 | 2 | 0.1% | `00000`×2819, `00001`×184, `-391`×2 ⚠ |
| 35 | `ObtDatosCaratula` | 2,944 | 0 | 0.0% | `00001`×2329, `00000`×615 |
| 36 | `SpValFolSmsCoppelWeb` | 2,866 | 0 | 0.0% | `00000`×2860, `00001`×6 |
| 37 | `SpObtieneParametro` | 2,545 | 0 | 0.0% | `00000`×2545 |
| 38 | `SpObtClaveTarjeta` | 2,466 | 0 | 0.0% | `00000`×2460, `00001`×6 |
| 39 | `SpConsultaSaldoCorteMin` | 2,384 | 0 | 0.0% | `00000`×2384 |
| 40 | `AsignacionNipPinOffline` | 2,302 | 0 | 0.0% | `00`×2296, `96`×6 |
| 41 | `SpConfirmaPinOffline` | 2,287 | 0 | 0.0% |  |
| 42 | `SpDeterminaLineaPreAprobados` | 2,189 | 0 | 0.0% | `000003`×1907, `000010`×153, `000000`×129 |
| 43 | `ConsImgNula` | 2,186 | 0 | 0.0% | `000`×2158, `00000`×28 |
| 44 | `InsertaImgPrevio` | 2,159 | 0 | 0.0% | `000`×2159 |
| 45 | `InsertRegistroExp` | 2,159 | 0 | 0.0% | `000`×2159 |
| 46 | `SpValidaPreEdoCta` | 2,061 | 0 | 0.0% | `00000`×2061 |
| 47 | `SpConsultaSaldosCobranzaSucs` | 2,060 | 0 | 0.0% |  |
| 48 | `SpObtenerCtasCte2Web` | 1,971 | 0 | 0.0% |  |
| 49 | `ConsNomTit` | 1,910 | 0 | 0.0% | `000`×1856, `100`×54 |
| 50 | `SpObtieneInfProd2` | 1,871 | 0 | 0.0% | `00000`×1870, `00001`×1 |
| 51 | `SpgeneraReportePpWeb` | 1,818 | 485 | 26.7% ⚠ | `00000`×1127, `-1202`×485 ⚠, `00001`×206 |
| 52 | `ConsCtesFirXNumCtaPer2` | 1,816 | 0 | 0.0% | `000`×1829 |
| 53 | `SpSnRetrieveClientStatus` | 1,815 | 0 | 0.0% | `00002`×1456, `00000`×359 |
| 54 | `TotComp2Web` | 1,792 | 0 | 0.0% | `00000`×1711, `00001`×81 |
| 55 | `ConsTipoCte` | 1,776 | 0 | 0.0% | `00000`×1776 |
| 56 | `PaseSucursal` | 1,670 | 0 | 0.0% | `00000`×1670 |
| 57 | `SpConsultaParametrosCuentaNomina` | 1,526 | 0 | 0.0% | `00000`×1526 |
| 58 | `ConsultaEmpleado` | 1,453 | 0 | 0.0% | `00000`×1453 |
| 59 | `TotCompCrd` | 1,388 | 0 | 0.0% | `00000`×1118 |
| 60 | `ConsultMovsWeb` | 1,326 | 0 | 0.0% | `00000`×6499 |
| … | *(+289 operaciones con < llamadas)* | | | | |

### Servicios con errores (retcode negativo)

| Operación | Total calls | Errores | Err% | Retcodes de error |
|-----------|-------------|---------|------|------------------|
| `SpgeneraReportePpWeb` | 1,818 | 485 | 26.7% | `-1202`×485 |
| `ConsNumCte` | 11,422 | 381 | 3.3% | `-674`×381 |
| `SpConsCteBpiWeb` | 132 | 21 | 15.9% | `-0001`×21 |
| `SpConsultaPreAprobado` | 6,707 | 15 | 0.2% | `-284`×15 |
| `SpBuscarCtesaMigrarWeb` | 3,012 | 2 | 0.1% | `-391`×2 |
| `ArqueoSucursal` | 265 | 1 | 0.4% | `-268`×1 |
| `spActualizaCteRemesa` | 81 | 1 | 1.2% | `-268`×1 |

### Distribución horaria — SOAP responses (hora CST)

```
  00h                             0  ( 0.0%)
  01h                             0  ( 0.0%)
  02h                             0  ( 0.0%)
  03h                             0  ( 0.0%)
  04h                             0  ( 0.0%)
  05h                             0  ( 0.0%)
  06h                             0  ( 0.0%)
  07h                            36  ( 0.0%)
  08h                         3,016  ( 0.6%)
  09h  █████                 46,928  ( 8.8%)
  10h  ████████████████████  163,895  (30.7%)
  11h  ███████████████       130,161  (24.4%)
  12h  ████████              71,352  (13.4%)
  13h  ███████               64,842  (12.1%)
  14h                         2,276  ( 0.4%)
  15h                             0  ( 0.0%)
  16h                             0  ( 0.0%)
  17h                             0  ( 0.0%)
  18h                             0  ( 0.0%)
  19h                             0  ( 0.0%)
  20h  █████                 44,793  ( 8.4%)
  21h                         7,002  ( 1.3%)
  22h                            93  ( 0.0%)
  23h                             0  ( 0.0%)
```

## Catálogo de excepciones Java

*Extraído de SystemErr.log — primera línea de cada stack trace.*

| Excepción | Ocurrencias | Mensaje más frecuente |
|-----------|-------------|----------------------|
| `BusinessException` | 4,179 | No se Encontro Sesión Asociada. |
| `NestedServletException` | 1,588 | Request processing failed; nested exception is java.lang.NullPointerException |
| `EmptyResultDataAccessException` | 21 | Incorrect result size: expected 1, actual 0 |
| `DataIntegrityViolationException` | 1 | CallableStatementCallback; SQL [{call FNBITACORA_TIMESTAMPS_INSTR(?, ?, ?, ?, ?, |

### Errores registrados en SystemOut (nivel ERROR)

| Clase | Ocurrencias | Mensaje frecuente |
|-------|-------------|------------------|
| `RemesasBusinessImpl` | 8,801 | TRANSACCION 8709 - BUSINESS - actualizó estado |
| `RestErrorHandler` | 8,722 | Se maneja Error, y se manda respuesta:Sistema temporalmente fuera de servicio. |
| `ProductosDaoImpl` | 8,600 | Ocurrió un error al intentar  consultar catalogos de productos  y/o estatus.null |
| `AfectaTablasBusinessImpl` | 4,044 | AFECTA TABLAS -- DIARIOS -- OBTENIENDO VDIARIOS |
| `ParametrosWebBusiness` | 2,436 | null |
| `XmlMarshaller` | 1,420 | mx.com.solser.persistence.cplasu.ws.exceptions.XmlMarshallerException: Campo esp |
| `VarqueoDesgloseBusiness` | 1,314 | VarqueoDesgloseBusiness ::: Obteniendo desglose de dotacion de la tabla VDESGDOT |
| `SolicitudRecoleccionDotacionEfectivoImpl` | 1,117 | obtenerInformacion - Finaliza |
| `VMovimientoDudosoDaoImpl` | 448 | validaExistenciaMovimientoDudoso :: No existe movimiento dudoso VMovimientoDudos |
| `GeneralCajaBusinessImpl` | 383 | ERROR EN EL DESGLOSE DE CHEQUES (Backend) :: -674 |
| `PrestamoCoppelBusiness` | 350 | ERROR EN INICIO SESION REST - BUSINESS - Error: 404 Not Found, Causa: null |
| `SiProdcutoDaoImpl` | 156 | Error al traer el campo valor de la tabla parametro |
| `HuellasBusiness` | 105 | Error al enviar la huella del cliente... |
| `PagoServicioBusinessImpl` | 56 | obtenerServiciosEtapaEjecucion :mx.com.solser.cplasu.exception.BusinessException |
| `BitacoraDaoImpl` | 34 | Alguno de los campos excede el número de caracteres permitido. |
| `PagoDeCreditosBancoppelBusinessImpl` | 32 | null363 |
| `ReportesBusinessImpl` | 32 | JRException ERROR: Ocurrio un problema en la generacion del archivo.net.sf.jaspe |
| `OrdenesPagoBusinessImpl` | 30 | TRANSACCION 8702 - BUSINESS - ERROR GUARDAR PAGO |
| `CancelacionCreditoBusiness` | 20 | Error al Consultar El Cliente de Retencion. Codigo de Retorno: 00002 |
| `StoredProcedureDaoImpl` | 20 | No fue posible insertar el registro en bitácora - FNCONCILIAMOVIMIENTOS. |

## Endpoints HTTP (frontend → WAS)

*Solo operaciones de negocio (excluye activos estáticos).*

### Por contexto de aplicación

| Contexto | Llamadas | % |
|----------|----------|---|
| `CajaNacionalServ` | 1,445,122 | 62.2% |
| `BcplSucServ` | 713,288 | 30.7% |
| `BcplSucApp` | 118,412 | 5.1% |
| `CajaNacionalApp` | 46,650 | 2.0% |
| `CajaTemporalServ` | 579 | 0.0% |
| `PlataformaTemporalServ` | 314 | 0.0% |
| `CPlaSuApp-1.0.0` | 299 | 0.0% |
| `CajaPilotoApp` | 96 | 0.0% |
| `CajaTemporalApp` | 35 | 0.0% |
| `PlataformaTemporalApp` | 16 | 0.0% |
| `CajaPilApp` | 2 | 0.0% |
| `_WS` | 2 | 0.0% |
| `CajaPilotoServ` | 1 | 0.0% |

### Top 50 operaciones HTTP

| # | Operación | Llamadas | Errores HTTP (≥400) |
|---|-----------|----------|---------------------|
| 1 | `obtenerMensajesIerrcom.go` | 265,462 | 0 |
| 2 | `consulta_ParametrosWeb.go` | 123,861 | 0 |
| 3 | `CPlaSuFX.jar!` | 107,005 | 107005 |
| 4 | `SpObtCtesPreAprobadosNotificar.go` | 103,107 | 0 |
| 5 | `validaMovimientosDudosos.go` | 101,483 | 0 |
| 6 | `obtieneRangoEfectivoCajero.go` | 101,356 | 0 |
| 7 | `obtieneArqueoCajero.go` | 74,267 | 0 |
| 8 | `consultaParametrosBiometria.go` | 58,233 | 0 |
| 9 | `obtieneArqueoParametrosCajero.go` | 56,707 | 0 |
| 10 | `consulta_Parametros.go` | 53,894 | 0 |
| 11 | `consultaConfiguracionServicio.go` | 53,208 | 0 |
| 12 | `consultarSaldoCaptacion.go` | 50,141 | 0 |
| 13 | `consultaConfWebServicio.go` | 39,510 | 0 |
| 14 | `consultaHuellaCliente.go` | 38,008 | 0 |
| 15 | `pasvalidacionTransaccion.go` | 34,192 | 0 |
| 16 | `consultaParametrosWeb.go` | 33,917 | 0 |
| 17 | `obtenerArqueo.go` | 31,489 | 0 |
| 18 | `javax.xml.ws.spi.Provider` | 29,770 | 29770 |
| 19 | `consultaParametroWebOneClick.go` | 28,240 | 0 |
| 20 | `consultaParametros.go` | 27,392 | 0 |
| 21 | `obtenerDatosCobranza.go` | 25,466 | 0 |
| 22 | `validaActualizacionTelefonos.go` | 21,886 | 0 |
| 23 | `consultaPropiedades.go` | 20,088 | 0 |
| 24 | `consultaMensajeValidacionCuenta.go` | 19,242 | 0 |
| 25 | `consultaClienteN2.go` | 18,722 | 0 |
| 26 | `consultaSucursal.go` | 18,471 | 0 |
| 27 | `recuperarAvisoPrivacidad.go` | 18,471 | 0 |
| 28 | `validasesion.go` | 18,455 | 0 |
| 29 | `consultaParametrosLogin.go` | 18,443 | 0 |
| 30 | `consultaParametrosWebLogin.go` | 18,442 | 0 |
| 31 | `requiereHuellaSupervisor.go` | 18,193 | 0 |
| 32 | `consultaParametroWeb.go` | 17,271 | 0 |
| 33 | `componenteConsultaClientes.go` | 17,241 | 0 |
| 34 | `consultaEstatusProducto.go` | 16,924 | 0 |
| 35 | `consultaTipoSol.go` | 16,923 | 0 |
| 36 | `consultaTipoProducto.go` | 16,923 | 0 |
| 37 | `actualizaAperturaCajero.go` | 16,535 | 0 |
| 38 | `login.go` | 16,524 | 0 |
| 39 | `recuperarValorUDIS.go` | 14,967 | 0 |
| 40 | `consNumCteTipo.go` | 14,156 | 0 |
| 41 | `consultaParametrosOneclick.go` | 14,120 | 0 |
| 42 | `consultaPreAprobado.go` | 14,119 | 0 |
| 43 | `afectarCuentaRetiro.go` | 13,823 | 0 |
| 44 | `validaAbonoRef.go` | 13,531 | 0 |
| 45 | `grabarDepositoEnEfectivo.go` | 12,841 | 0 |
| 46 | `consultaSolicitudesCreditoMovilPopup.go` | 11,928 | 0 |
| 47 | `consultaParametrosAltaUnica.go` | 11,889 | 0 |
| 48 | `cerrarsession.go` | 11,635 | 0 |
| 49 | `obtenerMensajeIerrcom.go` | 8,493 | 0 |
| 50 | `consultaBines.go` | 7,498 | 0 |

### Distribución de códigos HTTP

| Status | Descripción | Llamadas |
|--------|-------------|----------|
| 200 | OK | 4,693,122 |
| 404 | Not Found | 220,451 |

## Señales para la migración Informix

Observaciones directamente relevantes para `SPE-AM-001`:

- **Tasa de error SOAP baja (0.17%)** — base sana para parallel-run; threshold del SLO DoD-SPE-AM-01 es ≤0.05% de divergencia.

- **Servicio con más errores:** `SpgeneraReportePpWeb` — 485 errores / 1,818 llamadas (26.7%). Investigar causa raíz antes del cutover de esta operación.

- **BusinessException: 4,179 ocurrencias** — mensajes principales: "No se Encontro Sesión Asociada."×4167; "Error al generar reporte de Conciliacion de Movimientos"×11; "Error al generar reporte de Conciliacion de Movimientosmx.com.solser.cplasu.exception.BusinessExcept"×1. Estas excepciones son reglas de negocio en la capa Java que deberán mapearse a equivalentes en la arquitectura target.

- **53 contextos SOAP activos** — `Caja`, `ObtenerFec`, `CajaCliente`, `SolicitudesCred`, `CajaCaptacion`, `Cliente2`, `Caja2`, `Login`. Cada contexto es un WAR/módulo Java independiente que envuelve SPs de Informix; cada uno requiere un Anti-Corruption Layer propio en el target.

- **Operaciones de mayor volumen:** `ObtenerFecHoy`×68,504, `SpObtCtesPreAprobadosNotificar`×52,259, `ConSdos2Web`×28,684. Estas operaciones son candidatas prioritarias para parallel-run desde el inicio de BUILD.

---
*Evidencia: `source/logs/2026-08-07/` · Generado: 2026-08-07 21:05*