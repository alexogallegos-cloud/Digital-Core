# Vocabulario del autorizador e-global

Términos, funciones y catálogos que el autorizador usa en su operación diaria, extraídos de su propio log. Es el punto de partida para cruzar contra el vocabulario empresarial del banco conforme a la Regla V1.

> Generado desde `digital-brain/brain.db` por `generators/build-knowledge-base.py`. No editar a mano. Construido el 2026-11-04.
> Las cifras agregan 2 lote(s) de evidencia, 2,861,405 transacciones en total:
> - `authorizerj.eglobal.20261104`: 16,412 transacciones en 20 minutos (00:02:40 a 00:22:39), 30 archivos.
> - `eglobal.authorizer.20261103`: 2,844,993 transacciones en 1438 minutos (00:00:00 a 23:57:42), 118 archivos.

---

## Funciones del autorizador por categoría

### Acceso datos

78 funciones, 90,027,810 invocaciones.

| Función | Invocaciones | Por transacción | Latencia media | Descripción |
|---------|--------------|-----------------|----------------|-------------|
| `dbGetDatosTransaccion` | 4,988,651 | 1.64 | 2.7 ms | Pendiente de documentar |
| `dbGetDataHsmCard` | 4,145,697 | 1.32 | 1.9 ms | Obtiene del HSM los datos criptograficos de la tarjeta |
| `dbUpdateMovimientoSeAutorizo` | 3,344,555 | 1.25 | 0.8 ms | Marca el resultado de la autorizacion sobre el movimiento |
| `dbGetandValidateHostResponse` | 3,182,807 | 1.17 | 2.4 ms | Traduce el codigo de retorno del core al codigo de respuesta ISO |
| `dbGetCuentaTarjeta` | 2,870,408 | 1.00 | 2.2 ms | Resuelve la cuenta asociada a la tarjeta |
| `dbGetTipoTarjeta` | 2,861,485 | 1.00 | 1.7 ms | Determina si el BIN es propio de BanCoppel o de otro emisor |
| `dbEsTarjetaAdicional` | 2,861,404 | 1.00 | 2.4 ms | Determina si la tarjeta es adicional de un titular |
| `dbGetDatosTarjeta` | 2,861,361 | 1.00 | 3.7 ms | Pendiente de documentar |
| `dbInsertMovimiento` | 2,861,268 | 1.00 | 9.8 ms | Registra el movimiento en el core antes de autorizar |
| `dbgetValAuth` | 2,861,249 | 1.00 | 4.5 ms | Pendiente de documentar |
| `dbGetProductoTarjeta` | 2,858,332 | 1.00 | 2.0 ms | Resuelve el producto comercial al que pertenece la tarjeta |
| `dbGetStatusTarjeta` | 2,858,189 | 1.00 | 1.7 ms | Consulta el estatus vigente de la tarjeta |
| `dbGetMontoParametros` | 2,798,614 | 0.97 | 1.3 ms | Recupera los parametros de monto aplicables a la transaccion |
| `dbUpdateMovimientoCobraComisionesEnLinea` | 2,798,601 | 0.97 | 0.8 ms | Pendiente de documentar |
| `dbValidateGiroDeNegocio` | 2,761,432 | 0.97 | 1.5 ms | Valida el giro de negocio (MCC) del comercio |
| `dbValidaComercioDudoso` | 2,761,387 | 0.97 | 1.9 ms | Verifica si el comercio esta marcado como dudoso |
| `dbValidateandInsertGiroNeg` | 2,761,227 | 0.97 | 1.7 ms | Pendiente de documentar |
| `dbUpdateTarjeta` | 2,741,608 | 0.82 | 1.0 ms | Pendiente de documentar |
| `dbUpdateMovimientoBCentral` | 2,699,604 | 0.93 | 0.8 ms | Pendiente de documentar |
| `dbTransformaTransaccion` | 2,699,595 | 0.93 | 0.0 ms | Transforma el tipo de transaccion para la respuesta al cliente |
| `dbUpdateMovimientoFechaAplicCentralyCodigoCentral` | 2,699,576 | 0.93 | 0.8 ms | Pendiente de documentar |
| `dbGetSoportaCVV2Dinamico` | 2,629,033 | 0.95 | 1.9 ms | Verifica si la tarjeta soporta CVV2 dinamico |
| `dbCobroComisionEnLinea` | 2,240,249 | 0.69 | 2.0 ms | Aplica el cobro de comision en linea cuando corresponde |
| `dbUpdateMovimientoRespuestaCentralComisionesEnLinea` | 2,167,048 | 0.66 | 0.8 ms | Pendiente de documentar |
| `dbUpdateTarjetaporComisiones` | 2,167,048 | 0.66 | 1.7 ms | Pendiente de documentar |
| `dbInsertaARQCCalculado` | 1,673,972 | 0.42 | 1.0 ms | Pendiente de documentar |
| `dbExisteARQCCalculado` | 1,673,943 | 0.42 | 3.2 ms | Pendiente de documentar |
| `dbGetPermiteTransaccionesDigitadas` | 1,162,302 | 0.57 | 2.0 ms | Verifica si la tarjeta admite transacciones digitadas |
| `dbAfiliacionCOF_NO_Permitida` | 1,162,286 | 0.57 | 1.8 ms | Verifica si la afiliacion tiene prohibido el cargo con tarjeta en archivo |
| `dbGetValidaCVV2PorProducto` | 1,159,255 | 0.56 | 1.4 ms | Pendiente de documentar |
| `dbGetATCTarjeta` | 1,089,411 | 0.28 | 1.4 ms | Pendiente de documentar |
| `dbRegistraATCTarjeta` | 1,089,410 | 0.28 | 0.7 ms | Pendiente de documentar |
| `dbUpdateATCTarjeta` | 1,089,144 | 0.28 | 1.7 ms | Pendiente de documentar |
| `dbMaxContadorCVV2InvalidoPorTarjeta` | 840,676 | 0.38 | 1.6 ms | Pendiente de documentar |
| `dbUpdateContadorCVV2ValidoPorTarjeta` | 770,825 | 0.35 | 1.7 ms | Pendiente de documentar |
| `dbGetMarcaTarjeta` | 720,504 | 0.17 | 1.3 ms | Pendiente de documentar |
| `dbRegistraSQLAlerta` | 645,119 | 0.32 | 3.2 ms | Pendiente de documentar |
| `dbRegistraTarjeta_Rechazos` | 634,561 | 0.31 | 3.4 ms | Registra el rechazo en la bitacora de la tarjeta |
| `dbRegistraTokenPO_PY` | 621,514 | 0.29 | 1.8 ms | Pendiente de documentar |
| `dbGetPermiteTransMOTOInternet` | 572,917 | 0.26 | 2.0 ms | Pendiente de documentar |
| `dbAfiliacionPermiteCVV2Dual` | 453,890 | 0.21 | 1.4 ms | Pendiente de documentar |
| `dbActualizaTarjeta_indicadorEnvioEcommerce` | 394,418 | 0.17 | 2.0 ms | Pendiente de documentar |
| `dbAfiliacionPermitida` | 196,395 | 0.09 | 1.5 ms | Pendiente de documentar |
| `dbGetEsPropio` | 141,623 | 0.04 | 1.6 ms | Pendiente de documentar |
| `dbGetEsConvenio` | 141,619 | 0.04 | 2.1 ms | Pendiente de documentar |
| `dbGetSecuenciaCashBack` | 132,324 | 0.03 | 2.8 ms | Pendiente de documentar |
| `dbUpdateMovimientoSecuenciaCashBack` | 132,324 | 0.03 | 0.8 ms | Pendiente de documentar |
| `dbGetFlagCOFSinOTID` | 123,365 | 0.11 | 1.3 ms | Pendiente de documentar |
| `dbRegistraTokenTM_TV` | 115,271 | 0.04 | 2.1 ms | Pendiente de documentar |
| `dbRegistraTokenPC` | 98,139 | 0.09 | 1.1 ms | Pendiente de documentar |
| `dbGetMaxSaldoAMostrar` | 90,122 | 0.03 | 1.6 ms | Pendiente de documentar |
| `dbMaxContadorNIPInvalidoPorTarjeta` | 75,115 | 0.02 | 1.6 ms | Pendiente de documentar |
| `dbCobroComisionEnLineaPorSecuencia` | 72,085 | 0.02 | 2.1 ms | Pendiente de documentar |
| `dbChecaReversa` | 70,749 | 0.02 | 3.1 ms | Pendiente de documentar |
| `dbUpdateMovimientoCVV2Dual` | 63,229 | 0.03 | 0.8 ms | Pendiente de documentar |
| `dbRegistraMovimientoCOF` | 59,543 | 0.04 | 0.8 ms | Registra el movimiento de tarjeta en archivo (card on file) |
| `dbUpdateMovimientoSecuenciaComision` | 51,913 | 0.01 | 0.8 ms | Pendiente de documentar |
| `dbUpdateContadorNIPValidoPorTarjeta` | 48,554 | 0.01 | 1.5 ms | Pendiente de documentar |
| `dbUpdateContadorCVV2InvalidoPorTarjeta` | 41,712 | 0.02 | 1.5 ms | Pendiente de documentar |
| `dbCobroComisionEnLineaParaReversos` | 23,379 | 0.01 | 7.0 ms | Pendiente de documentar |
| `dbGetSecuenciaOrig` | 23,350 | 0.01 | 1.9 ms | Pendiente de documentar |
| `dbUpdateAcumuladosTarjeta` | 23,350 | 0.01 | 8.6 ms | Pendiente de documentar |
| `dbUpdateMovReversado` | 23,350 | 0.01 | 4.5 ms | Pendiente de documentar |
| `dbgetTipoTranDigitada` | 23,308 | 0.01 | 2.5 ms | Pendiente de documentar |
| `dbInsertaPrimerTranCEenBitacora` | 12,055 | 0.01 | 4.4 ms | Pendiente de documentar |
| `dbRegistraTokenQ6` | 2,903 | 0.00 | 2.3 ms | Pendiente de documentar |
| `dbGetNacIntTranOriginal` | 2,684 | 0.00 | 6.1 ms | Pendiente de documentar |
| `dbPutBlockCard` | 2,629 | 0.00 | 2.9 ms | Pendiente de documentar |
| `dbUpdateContadorNIPInvalidoPorTarjeta` | 1,053 | 0.00 | 1.5 ms | Pendiente de documentar |
| `dbValidaSecuenciaOriginalEnReversaATM` | 443 | 0.00 | 2.0 ms | Pendiente de documentar |
| `dbCobroComisionFueraDeLinea` | 129 | 0.00 | 2.3 ms | Pendiente de documentar |
| `dbInsertaMovimientoPorExcepcion` | 117 | 0.00 | 3.5 ms | Pendiente de documentar |
| `dbGetFolioSucCashOrigen` | 114 | 0.00 | 2.0 ms | Pendiente de documentar |
| `dbGetPermiteTransaccionesTAG` | 97 | 0.00 | 1.7 ms | Pendiente de documentar |
| `dbGetFlagFastFounds` | 83 | 0.00 | 1.3 ms | Pendiente de documentar |
| `dbRegistraTokenCT_S7` | 83 | 0.00 | 0.2 ms | Pendiente de documentar |
| `dbValidaComercioSinATC` | 14 | 0.00 | 3.9 ms | Pendiente de documentar |
| `dbUpdateMovimientoCobraComisionesFueraDeLinea` | 12 | 0.00 | 1.1 ms | Pendiente de documentar |

### Orquestacion

3 funciones, 15,789,202 invocaciones.

| Función | Invocaciones | Por transacción | Latencia media | Descripción |
|---------|--------------|-----------------|----------------|-------------|
| `GetTypeOfTransaction` | 10,711,459 | 3.64 | 0.0 ms | Clasifica la transaccion por producto, tipo de mensaje ISO y monto |
| `Autoriza` | 2,861,355 | 1.00 | 61.4 ms | Orquestador principal del ciclo de autorizacion |
| `RxAutorizaTransaccion` | 2,216,388 | 0.69 | 63.1 ms | Ejecuta la secuencia de validaciones de negocio de la transaccion |

### Construccion mensaje

3 funciones, 8,395,386 invocaciones.

| Función | Invocaciones | Por transacción | Latencia media | Descripción |
|---------|--------------|-----------------|----------------|-------------|
| `BuildHostMessage` | 2,858,323 | 1.00 | 0.2 ms | Arma la llamada al core con los parametros de la transaccion |
| `BuiltDescription` | 2,837,496 | 0.99 | 0.1 ms | Pendiente de documentar |
| `BuiltClientMessage` | 2,699,567 | 0.93 | 16.4 ms | Arma el mensaje ISO 8583 de respuesta hacia la red |

### Validacion

3 funciones, 6,878,806 invocaciones.

| Función | Invocaciones | Por transacción | Latencia media | Descripción |
|---------|--------------|-----------------|----------------|-------------|
| `bTarjetaVIP` | 2,861,324 | 1.00 | 1.8 ms | Determina si la tarjeta pertenece a un cliente VIP |
| `ValidateDigitoVerificador` | 2,858,207 | 1.00 | 0.0 ms | Valida el digito verificador del numero de tarjeta (Luhn) |
| `ValidateServiceCode` | 1,159,275 | 0.56 | 1.7 ms | Valida el codigo de servicio de la banda de la tarjeta |

### Invocacion core

3 funciones, 3,344,722 invocaciones.

| Función | Invocaciones | Por transacción | Latencia media | Descripción |
|---------|--------------|-----------------|----------------|-------------|
| `ExecuteSP` | 2,699,603 | 0.93 | 14.8 ms | Invoca el stored procedure del core Informix que aplica el movimiento |
| `ExecuteSP_Registra_Evento` | 645,116 | 0.32 | 3.2 ms | Pendiente de documentar |
| `ExecuteSP_Registra_Evento_PINChip` | 3 | 0.00 | 3.3 ms | Pendiente de documentar |

### Otro

5 funciones, 2,852,317 invocaciones.

| Función | Invocaciones | Por transacción | Latencia media | Descripción |
|---------|--------------|-----------------|----------------|-------------|
| `UpdateMovimientoAuthHost` | 2,699,596 | 0.93 | 0.9 ms | Pendiente de documentar |
| `ATMDudoso` | 76,517 | 0.02 | 1.9 ms | Pendiente de documentar |
| `GetBankDescription` | 76,078 | 0.02 | 1.7 ms | Pendiente de documentar |
| `BuscaMontosCashBack` | 115 | 0.00 | 2.1 ms | Pendiente de documentar |
| `BuscaSecuenciaOriginalDePOS` | 11 | 0.00 | 4.7 ms | Pendiente de documentar |

## Tipos de transacción

| Tipo | Código interno | Mensaje ISO | Producto | Volumen |
|------|----------------|-------------|----------|--------|
| Compra pos | `00` | `0200` | `02` | 2,593,267 |
| Cash back pos | `09` | `0200` | `02` | 132,325 |
| Retiro atm | `01` | `0200` | `01` | 65,143 |
| Validacion cuenta | `81` | `0200` | `02` | 35,766 |
| Reversa pos | `00` | `0200` | `02` | 22,877 |
| Consulta atm | `31` | `0200` | `01` | 10,935 |
| Reversa atm | `01` | `0200` | `01` | 439 |
| Reversa pos | `00` | `0420` | `02` | 428 |
| Sin etiqueta | `09` | `0420` | `02` | 98 |
| Sin etiqueta | `26` | `0200` | `02` | 83 |
| Sin etiqueta | `09` | `0200` | `02` | 31 |
| Reversa pos | `00` | `0421` | `02` | 6 |
| Reversa atm | `31` | `0200` | `01` | 3 |
| Sin etiqueta | `00` | `0200` | `02` | 2 |
| Reversa atm | `01` | `0420` | `01` | 1 |
| Sin etiqueta | `09` | `0421` | `02` | 1 |

## Modos de entrada en el punto de venta

| Código | Descripción | Volumen | Participación |
|--------|-------------|---------|---------------|
| `05` | Chip leido, cvv confiable | 1,111,995 | 39.2% |
| `01` | Manual | 898,423 | 31.7% |
| `07` | Contactless emv | 562,359 | 19.8% |
| `10` | Card on file | 263,883 | 9.3% |
| `80` | Fallback | 738 | 0.0% |
| `00` | Desconocida | 81 | 0.0% |
| `90` | Banda magnetica leida y su contenido es proporcionado integro al adquirente | 18 | 0.0% |
| `02` | Banda magnetica leida. el contenido de la misma fue editado | 17 | 0.0% |
| `81` | Manual | 4 | 0.0% |

## Banderas de contexto de la transacción

Marcadores que el autorizador imprime cuando la transacción cumple cierta condición. Describen el perfil del tráfico real del banco.

| Bandera | Transacciones | Participación |
|---------|---------------|---------------|
| Sin hash | 2,861,368 | 100.0% |
| Sin otp | 2,861,367 | 100.0% |
| Bin propio | 2,858,446 | 99.9% |
| Digitada | 1,159,356 | 40.5% |
| Cvv2 dinamico | 800,722 | 28.0% |
| Cargo automatico | 550,074 | 19.2% |
| Internacional | 212,213 | 7.4% |
| Es retiro | 65,143 | 2.3% |

## Tokens propietarios del mensaje ISO

Campos privados que viajan dentro del mensaje. El estado indica si el autorizador los encontró, no los encontró, o los pasó sin interpretar.

| Token | Estado | Volumen |
|-------|--------|--------|
| `PC` | Ausente | 2,663,292 |
| `C0` | Ausente | 1,115,229 |
| `TV` | Ausente | 1,007,880 |
| `PJ` | Ausente | 976,045 |
| `PO` | Ausente | 612,153 |
| `Q6` | Ausente | 276,296 |
| `B4` | Ausente | 187,271 |
| `PJ` | Presente | 186,262 |
| `17` | Paseado | 181,816 |
| `TV` | Presente | 115,271 |
| `PC` | Presente | 98,139 |
| `04` | Ausente | 52,157 |
| `PO` | Presente | 9,362 |
| `TM` | Ausente | 400 |
| `CT` | Ausente | 80 |
| `CZ` | Ausente | 67 |
| `B2` | Ausente | 30 |

## Giros de negocio más frecuentes

Los veinte códigos de giro de comercio con más tráfico.

| Giro | Transacciones |
|------|---------------|
| `5399` | 338,240 |
| `5422` | 289,889 |
| `5499` | 272,588 |
| `5411` | 227,733 |
| `4899` | 186,738 |
| `5541` | 158,442 |
| `7311` | 123,159 |
| `4814` | 116,866 |
| `5818` | 78,966 |
| `5912` | 72,257 |
| `5311` | 69,208 |
| `4121` | 59,238 |
| `5814` | 57,996 |
| `4816` | 56,963 |
| `6300` | 39,164 |
| `7399` | 38,168 |
| `4900` | 36,841 |
| `5812` | 36,494 |
| `5734` | 33,245 |
| `5251` | 23,054 |
