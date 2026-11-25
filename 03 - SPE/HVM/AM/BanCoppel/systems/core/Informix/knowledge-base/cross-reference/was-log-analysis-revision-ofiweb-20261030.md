# Análisis WAS — BanCoppel Informix · revision-ofiweb-20261030
> Generado: 2026-11-04 15:31 · `generators/analyze-was-logs.py` v1.0

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
| `WAS1-puresys20` | 7 | 1,353,406 | 348,596 | 2,115,430 |
| `WAS2-puresys30` | 10 | 1,699,455 | 418,428 | 0 |

## Resumen ejecutivo

| Métrica | Valor |
|---------|-------|
| Operaciones SOAP distintas | 445 |
| Llamadas SOAP totales (responses) | 767,024 |
| Llamadas con retcode negativo | 462 (0.06%) |
| Endpoints HTTP (business) | 797 |
| Llamadas HTTP (business) | 2,115,430 |
| Excepciones Java distintas | 4 |
| Total excepciones capturadas | 1,687 |
| Contextos SOAP activos | 47 |

### Contextos SOAP (grupos de aplicación)

| Contexto | Llamadas | % |
|----------|----------|---|
| `Caja` | 364,558 | 47.5% |
| `CajaCliente` | 266,687 | 34.8% |
| `ObtenerFec` | 182,289 | 23.8% |
| `CajaCaptacion` | 181,133 | 23.6% |
| `Caja2` | 119,970 | 15.6% |
| `SolicitudesCred` | 106,000 | 13.8% |
| `Cliente2` | 100,680 | 13.1% |
| `Login` | 69,854 | 9.1% |
| `Cliente` | 29,942 | 3.9% |
| `PagoServicios` | 19,132 | 2.5% |
| `DatosCliente` | 14,964 | 2.0% |
| `ExpedienteDigital` | 10,968 | 1.4% |
| `SistemaCredito` | 10,661 | 1.4% |
| `MantTarjeta` | 9,748 | 1.3% |
| `CuentaNomina` | 7,863 | 1.0% |
| `AdmonSuC` | 6,065 | 0.8% |
| `ServiciosTarj` | 5,815 | 0.8% |
| `FamiliPpeSegclub` | 5,464 | 0.7% |
| `CambioDeInstruccion` | 4,672 | 0.6% |
| `Nip` | 4,054 | 0.5% |

## Catálogo de servicios SOAP

Ordenados por volumen de llamadas (solo operaciones con ≥5 respuestas).

| # | Operación | Llamadas | Errores (ret<0) | Err% | Retcodes principales |
|---|-----------|----------|----------------|------|----------------------|
| 1 | `ObtenerFecHoy` | 91,138 | 0 | 0.0% |  |
| 2 | `ConSdos2Web` | 48,633 | 0 | 0.0% | `00000`×48011, `00122`×371, `00100`×251 |
| 3 | `SpConsFlagreTarj` | 45,279 | 0 | 0.0% | `00000`×45279 |
| 4 | `SpObtCtesPreAprobadosNotificar` | 40,263 | 0 | 0.0% | `000000`×272955, `00000`×12, `00008`×1, `000`×1, `00002`×1 |
| 5 | `ConsultarHuellaCliente` | 28,360 | 0 | 0.0% | `000`×28312, `132`×48 |
| 6 | `SpObtParamSorteo` | 26,798 | 0 | 0.0% | `00000`×26798 |
| 7 | `SpValClubProteccionWeb` | 25,809 | 0 | 0.0% | `00000`×25809 |
| 8 | `SpValidarRostroCliente` | 25,725 | 0 | 0.0% |  |
| 9 | `AdmConsultaSuc` | 25,367 | 0 | 0.0% | `00000`×25367 |
| 10 | `ConsNumCte` | 24,505 | 0 | 0.0% | `00000`×24505 |
| 11 | `SpObtenGrupoCliente` | 23,143 | 0 | 0.0% | `00000`×23143 |
| 12 | `SpObtenerDatosCvWeb` | 22,828 | 0 | 0.0% | `000`×57 |
| 13 | `SpObtenerParametroCheq` | 19,096 | 0 | 0.0% | `00000`×19096 |
| 14 | `SpConsultaCteN2` | 17,308 | 0 | 0.0% | `00002`×17307, `00004`×1 |
| 15 | `ConsultarValorParametro` | 16,704 | 0 | 0.0% | `00000`×16704 |
| 16 | `SpConsultaPreAprobado` | 14,772 | 41 | 0.3% | `00008`×11435, `00000`×3096, `00002`×195, `-284`×41 ⚠, `00010`×3 |
| 17 | `ValorDivisaPesos` | 14,236 | 0 | 0.0% | `00000`×14236 |
| 18 | `CargoRef` | 13,972 | 0 | 0.0% | `000`×13951, `400`×9, `300`×8, `200`×4 |
| 19 | `ValFechasWeb` | 13,701 | 0 | 0.0% | `00000`×13608, `00809`×93 |
| 20 | `AbonoRefWeb` | 12,775 | 0 | 0.0% | `00000`×12748, `00301`×10, `00151`×8, `00959`×7, `00371`×2 |
| 21 | `ValidaAbonoRefWeb` | 9,890 | 0 | 0.0% | `00000`×9646, `00371`×200, `00397`×40, `00200`×4 |
| 22 | `AdmConsEjecutivo` | 9,554 | 0 | 0.0% | `00000`×9532, `02004`×22 |
| 23 | `SpConsParamBanderaProdWeb` | 9,324 | 0 | 0.0% | `00000`×9324 |
| 24 | `SpSorteoBancoppelWeb` | 8,193 | 0 | 0.0% | `00116`×8193 |
| 25 | `ConsultarClienteNumCta` | 7,454 | 0 | 0.0% | `00000`×7832, `00100`×131, `00001`×18, `02200`×12 |
| 26 | `SpConsSolicCredMovilPopup` | 6,767 | 2 | 0.0% | `00000`×4922, `000`×2141, `-284`×2 ⚠ |
| 27 | `SpConsSdoGen` | 5,979 | 0 | 0.0% | `00000`×5979 |
| 28 | `SpGuardaTaggeoOneClick` | 5,654 | 0 | 0.0% |  |
| 29 | `SpConsultaProducto` | 4,928 | 0 | 0.0% | `00000`×4928 |
| 30 | `ConsSdos2Web` | 4,646 | 0 | 0.0% | `00000`×4610, `00398`×24, `00279`×11, `00015`×1 |
| 31 | `SpObtieneParametro` | 4,527 | 0 | 0.0% | `00000`×4527 |
| 32 | `spInserAlertaExlimblo` | 4,040 | 0 | 0.0% | `00000`×4040 |
| 33 | `SpConsSdoTicketWeb` | 3,890 | 0 | 0.0% | `00000`×3890 |
| 34 | `SpValidaCteHuella` | 3,175 | 0 | 0.0% | `00000`×3175 |
| 35 | `SpValidaHuellaIneCte` | 3,099 | 0 | 0.0% | `00000`×3047, `00002`×52 |
| 36 | `SpValidaHuellaCteDec` | 3,050 | 0 | 0.0% | `00000`×3005, `00002`×45 |
| 37 | `SpObtenerNacCliente` | 3,005 | 0 | 0.0% | `00000`×2994, `00001`×11 |
| 38 | `ConsEdadCte` | 3,002 | 0 | 0.0% | `00000`×3002 |
| 39 | `SpGuardaPreAprobadoNotificar` | 2,871 | 0 | 0.0% | `00000`×2871 |
| 40 | `SpBuscarCtesaMigrarWeb` | 2,862 | 0 | 0.0% | `00000`×2579, `00001`×276 |
| 41 | `SpConsultaSaldoCorteMin` | 2,791 | 0 | 0.0% | `00000`×2791 |
| 42 | `SpValFolSmsCoppelWeb` | 2,657 | 0 | 0.0% | `00000`×2655, `00001`×2 |
| 43 | `SpDeterminaLineaPreAprobados` | 2,527 | 0 | 0.0% | `000003`×2249, `000010`×164, `000000`×114 |
| 44 | `SpValidaPreEdoCta` | 2,494 | 0 | 0.0% | `00000`×2494 |
| 45 | `SpObtClaveTarjeta` | 2,483 | 0 | 0.0% | `00000`×2466, `00001`×17 |
| 46 | `SpConsultaSaldosCobranzaSucs` | 2,467 | 0 | 0.0% |  |
| 47 | `ConsultMovsWeb` | 2,456 | 0 | 0.0% | `00000`×12020 |
| 48 | `ObtDatosCaratula` | 2,331 | 0 | 0.0% | `00001`×1755, `00000`×576 |
| 49 | `ConsNomTit` | 2,185 | 0 | 0.0% | `000`×1991, `100`×194 |
| 50 | `SpObtenerCtasCte2Web` | 2,101 | 0 | 0.0% |  |
| 51 | `ConsultaEmpleado` | 2,066 | 0 | 0.0% | `00000`×2066 |
| 52 | `AsignacionNipPinOffline` | 1,965 | 0 | 0.0% | `00`×1954, `96`×11 |
| 53 | `SpConfirmaPinOffline` | 1,952 | 0 | 0.0% |  |
| 54 | `SpSnRetrieveClientStatus` | 1,922 | 0 | 0.0% | `00002`×1626, `00000`×296 |
| 55 | `ConsCtesFirXNumCtaPer2` | 1,921 | 0 | 0.0% | `000`×1935 |
| 56 | `ConsImgNula` | 1,877 | 0 | 0.0% | `000`×1827, `00000`×50 |
| 57 | `PaseContWeb2` | 1,839 | 0 | 0.0% | `00000`×1838, `00110`×1 |
| 58 | `InsertaImgPrevio` | 1,827 | 0 | 0.0% | `000`×1827 |
| 59 | `InsertRegistroExp` | 1,827 | 0 | 0.0% | `000`×1827 |
| 60 | `SpObtieneInfProd2` | 1,813 | 0 | 0.0% | `00000`×1812, `00001`×1 |
| … | *(+286 operaciones con < llamadas)* | | | | |

### Servicios con errores (retcode negativo)

| Operación | Total calls | Errores | Err% | Retcodes de error |
|-----------|-------------|---------|------|------------------|
| `SpgeneraReportePpWeb` | 1,674 | 397 | 23.7% | `-1202`×397 |
| `SpConsultaPreAprobado` | 14,772 | 41 | 0.3% | `-284`×41 |
| `SpConsCteBpiWeb` | 125 | 20 | 16.0% | `-0001`×20 |
| `ArqueoSucursal` | 79 | 2 | 2.5% | `-268`×2 |
| `SpConsSolicCredMovilPopup` | 6,767 | 2 | 0.0% | `-284`×2 |

### Distribución horaria — SOAP responses (hora CST)

```
  00h                             0  ( 0.0%)
  01h                             0  ( 0.0%)
  02h                             0  ( 0.0%)
  03h                             0  ( 0.0%)
  04h                             0  ( 0.0%)
  05h                             0  ( 0.0%)
  06h                             0  ( 0.0%)
  07h                            70  ( 0.0%)
  08h                         3,154  ( 0.4%)
  09h  █████                 59,840  ( 7.8%)
  10h  ███████████████       170,776  (22.3%)
  11h  ███████████████████   215,571  (28.1%)
  12h  ████████████████████  216,245  (28.2%)
  13h  ████████              90,487  (11.8%)
  14h                             0  ( 0.0%)
  15h                             0  ( 0.0%)
  16h                             0  ( 0.0%)
  17h                             0  ( 0.0%)
  18h                             0  ( 0.0%)
  19h                             0  ( 0.0%)
  20h                         8,076  ( 1.1%)
  21h                         2,779  ( 0.4%)
  22h                            26  ( 0.0%)
  23h                             0  ( 0.0%)
```

## Catálogo de excepciones Java

*Extraído de SystemErr.log — primera línea de cada stack trace.*

| Excepción | Ocurrencias | Mensaje más frecuente |
|-----------|-------------|----------------------|
| `BusinessException` | 1,005 | No se Encontro Sesión Asociada. |
| `NestedServletException` | 670 | Request processing failed; nested exception is java.lang.NullPointerException |
| `EmptyResultDataAccessException` | 10 | Incorrect result size: expected 1, actual 0 |
| `PersistenciaException` | 2 | mx.com.solser.persistence.cplasu.ws.exceptions.ClienteSoapException: Se presentó |

### Errores registrados en SystemOut (nivel ERROR)

| Clase | Ocurrencias | Mensaje frecuente |
|-------|-------------|------------------|
| `RemesasBusinessImpl` | 20,494 | TRANSACCION 8709 - BUSINESS - actualizó estado |
| `ProductosDaoImpl` | 6,622 | Ocurrió un error al intentar  consultar catalogos de productos  y/o estatus.null |
| `AfectaTablasBusinessImpl` | 4,095 | AFECTA TABLAS -- DIARIOS -- OBTENIENDO VDIARIOS |
| `ParametrosWebBusiness` | 2,024 | null |
| `VarqueoDesgloseBusiness` | 1,773 | VarqueoDesgloseBusiness ::: Obteniendo desglose de dotacion de la tabla VDESGDOT |
| `RestErrorHandler` | 1,647 | Se maneja Error, y se manda respuesta:Tarjeta cancelada/bloqueada |
| `XmlMarshaller` | 1,522 | mx.com.solser.persistence.cplasu.ws.exceptions.XmlMarshallerException: Campo esp |
| `SolicitudRecoleccionDotacionEfectivoImpl` | 1,426 | obtenerInformacion - Finaliza |
| `BitacoraDaoImpl` | 703 | Alguno de los campos excede el número de caracteres permitido. |
| `PrestamoCoppelBusiness` | 202 | ERROR EN INICIO SESION REST - BUSINESS - Error: 404 Not Found, Causa: null |
| `VMovimientoDudosoDaoImpl` | 97 | validaExistenciaMovimientoDudoso :: No existe movimiento dudoso VMovimientoDudos |
| `SiProdcutoDaoImpl` | 90 | Error al traer el campo valor de la tabla parametro |
| `SeguimientoSolicCreditoBusiness` | 67 | Error al generar Reporte Contrato Múltiple Captación |
| `StoredProcedureDaoImpl` | 65 | Ocurrió un error al ejecutar FN_CONSDIRECCIONCARDIF.CallableStatementCallback; b |
| `Db2Access` | 36 | Error de conexion |
| `PagoDeCreditosBancoppelBusinessImpl` | 32 | null363 |
| `HuellasBusiness` | 31 | Error al enviar la huella del cliente... |
| `CardifBusiness` | 30 | Error al generar reporte: |
| `SacWUCatCiudadesDAOImpl` | 29 | Error: |
| `ParametrosDaoImpl` | 19 | Error: |

## Endpoints HTTP (frontend → WAS)

*Solo operaciones de negocio (excluye activos estáticos).*

### Por contexto de aplicación

| Contexto | Llamadas | % |
|----------|----------|---|
| `CajaNacionalServ` | 1,283,763 | 60.7% |
| `BcplSucServ` | 430,782 | 20.4% |
| `CajaPilotoServ` | 155,597 | 7.4% |
| `PlataformaPilotoServ` | 102,890 | 4.9% |
| `BcplSucApp` | 72,327 | 3.4% |
| `CajaNacionalApp` | 43,286 | 2.0% |
| `PlataformaPilotoApp` | 20,138 | 1.0% |
| `CajaPilotoApp` | 4,598 | 0.2% |
| `CajaPilServ` | 726 | 0.0% |
| `BcplSucursalServ` | 681 | 0.0% |
| `CajaPilApp` | 370 | 0.0% |
| `CPlaSuApp-1.0.0` | 148 | 0.0% |
| `BcplSucursalApp` | 124 | 0.0% |

### Top 50 operaciones HTTP

| # | Operación | Llamadas | Errores HTTP (≥400) |
|---|-----------|----------|---------------------|
| 1 | `obtenerMensajesIerrcom.go` | 236,724 | 0 |
| 2 | `consulta_ParametrosWeb.go` | 129,903 | 0 |
| 3 | `obtieneRangoEfectivoCajero.go` | 93,184 | 0 |
| 4 | `validaMovimientosDudosos.go` | 90,017 | 0 |
| 5 | `CPlaSuFX.jar!` | 78,958 | 78958 |
| 6 | `SpObtCtesPreAprobadosNotificar.go` | 74,632 | 0 |
| 7 | `obtieneArqueoCajero.go` | 64,814 | 0 |
| 8 | `obtieneArqueoParametrosCajero.go` | 58,283 | 0 |
| 9 | `consulta_Parametros.go` | 57,973 | 0 |
| 10 | `consultarSaldoCaptacion.go` | 55,873 | 0 |
| 11 | `consultaParametrosBiometria.go` | 53,121 | 0 |
| 12 | `consultaConfWebServicio.go` | 40,751 | 0 |
| 13 | `consultaHuellaCliente.go` | 37,132 | 0 |
| 14 | `pasvalidacionTransaccion.go` | 36,794 | 0 |
| 15 | `consultaConfiguracionServicio.go` | 36,559 | 0 |
| 16 | `consultaParametroWebOneClick.go` | 34,180 | 0 |
| 17 | `javax.xml.ws.spi.Provider` | 30,425 | 30425 |
| 18 | `obtenerArqueo.go` | 28,058 | 0 |
| 19 | `obtenerDatosCobranza.go` | 26,642 | 0 |
| 20 | `consultaParametrosWeb.go` | 24,343 | 0 |
| 21 | `validaActualizacionTelefonos.go` | 24,081 | 0 |
| 22 | `requiereHuellaSupervisor.go` | 22,059 | 0 |
| 23 | `consultaClienteN2.go` | 21,514 | 0 |
| 24 | `login.go` | 20,260 | 0 |
| 25 | `consultaMensajeValidacionCuenta.go` | 19,470 | 0 |
| 26 | `consultaParametros.go` | 18,983 | 21 |
| 27 | `recuperarValorUDIS.go` | 17,812 | 0 |
| 28 | `consultaParametrosOneclick.go` | 16,891 | 0 |
| 29 | `consultaPreAprobado.go` | 16,891 | 0 |
| 30 | `afectarCuentaRetiro.go` | 16,456 | 0 |
| 31 | `consultaPropiedades.go` | 15,841 | 0 |
| 32 | `consNumCteTipo.go` | 15,181 | 0 |
| 33 | `consultaSucursal.go` | 14,400 | 0 |
| 34 | `recuperarAvisoPrivacidad.go` | 14,399 | 0 |
| 35 | `validasesion.go` | 14,376 | 0 |
| 36 | `consultaParametrosLogin.go` | 14,368 | 0 |
| 37 | `consultaParametrosWebLogin.go` | 14,368 | 0 |
| 38 | `validaAbonoRef.go` | 14,353 | 0 |
| 39 | `grabarDepositoEnEfectivo.go` | 13,784 | 0 |
| 40 | `consultaParametroWeb.go` | 13,408 | 0 |
| 41 | `actualizaAperturaCajero.go` | 12,565 | 0 |
| 42 | `consultaEstatusProducto.go` | 10,945 | 0 |
| 43 | `consultaTipoProducto.go` | 10,943 | 0 |
| 44 | `consultaTipoSol.go` | 10,942 | 0 |
| 45 | `obtenerMensajeIerrcom.go` | 10,085 | 0 |
| 46 | `componenteConsultaClientes.go` | 10,034 | 0 |
| 47 | `consultaParametrosAltaUnica.go` | 9,839 | 0 |
| 48 | `cerrarsession.go` | 9,151 | 0 |
| 49 | `consultaSolicitudesCreditoMovilPopup.go` | 7,854 | 0 |
| 50 | `consultaBines.go` | 7,770 | 0 |

### Distribución de códigos HTTP

| Status | Descripción | Llamadas |
|--------|-------------|----------|
| 200 | OK | 4,247,458 |
| 400 | Bad Request | 21 |
| 404 | Not Found | 189,861 |

## Señales para la migración Informix

Observaciones directamente relevantes para `SPE-AM-001`:

- **Tasa de error SOAP baja (0.06%)** — base sana para parallel-run; threshold del SLO DoD-SPE-AM-01 es ≤0.05% de divergencia.

- **Servicio con más errores:** `SpgeneraReportePpWeb` — 397 errores / 1,674 llamadas (23.7%). Investigar causa raíz antes del cutover de esta operación.

- **BusinessException: 1,005 ocurrencias** — mensajes principales: "No se Encontro Sesión Asociada."×1003; "Error al generar reporte de Conciliacion de Movimientos"×2. Estas excepciones son reglas de negocio en la capa Java que deberán mapearse a equivalentes en la arquitectura target.

- **47 contextos SOAP activos** — `Caja`, `CajaCliente`, `ObtenerFec`, `CajaCaptacion`, `Caja2`, `SolicitudesCred`, `Cliente2`, `Login`. Cada contexto es un WAR/módulo Java independiente que envuelve SPs de Informix; cada uno requiere un Anti-Corruption Layer propio en el target.

- **Operaciones de mayor volumen:** `ObtenerFecHoy`×91,138, `ConSdos2Web`×48,633, `SpConsFlagreTarj`×45,279. Estas operaciones son candidatas prioritarias para parallel-run desde el inicio de BUILD.

---
*Evidencia: `source/logs/revision-ofiweb-20261030/` · Generado: 2026-11-04 15:31*