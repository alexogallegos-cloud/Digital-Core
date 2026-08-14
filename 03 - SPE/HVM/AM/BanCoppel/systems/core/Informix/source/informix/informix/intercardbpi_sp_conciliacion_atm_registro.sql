CREATE PROCEDURE "informix".sp_conciliacion_atm_registro( 
psNumEmpleado CHAR (8), 
psArchivoOrigen CHAR (3), 
psActividad CHAR (25),
psUsuarioParametros CHAR (8),
psSecuenciaAuth CHAR (6) ,
psNumTarjeta CHAR (16) ,
psFecha CHAR (8) ,
psHora CHAR (8) ,
psAdquiriente CHAR (4) ,
psNumCuenta CHAR (13) ,
psDescripcion CHAR (15) ,
psIndicadordeReversa CHAR (19) ,
psCodigoISO CHAR (2)  ,
psSecuenciaCajero CHAR (12) ,
pmMonto MONEY ,
psNombreComercio CHAR (30) ,
psReferenciaTransaccion  CHAR (23) , --''
psRFC CHAR (16) , --''
psNumCajero CHAR (14),
piNumRegistro INTEGER,
psResp CHAR(6),  --nuevo
psOrden CHAR(6), 
psRed CHAR(7), 
psDolares CHAR(7), 
psNumAutorizacion CHAR(6), 
psCodPais CHAR(2), 
psMontoOrigen CHAR(13), 
psCodMoneda CHAR(3), 
pmMontoSurcharge MONEY(16,2), 
pmDonativo MONEY(16,2), 
psEmpresa CHAR(4), 
psCompania CHAR(10), 
pmMonto_LoyaltyFee MONEY(16,2), 
pmMonto_UsoLinea MONEY(16,2), 
psNomBancoEmisor CHAR(20), 
psBanderaAdquiriente CHAR(1)  --nuevo
)

RETURNING INTEGER, CHAR (500) ;

--****************************************************************************************************
-- DESCRIPCION: PROCEDO DE CONCILIACION A UN REGISTRO
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 01/07/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO :  : 15/04/2010 Casanova Edeza Hector Juan  --se agregan los parametros Resp,Orden,Red,Dolares,NumAutorizacion,CodPais, MontoOrigen,CodMoneda,MontoSurcharge,Donativo,Empresa,Compañia,Monto_LoyaltyFee,Monto_UsoLinea,NomBancoEmisor y BanderaAdquiriente para que se guarden en la tabla Log_ATM .
-- MODIFICADO :  : 11/05/2010 Casanova Edeza Hector Juan  --Se modifico la logica para que el monto representado en el archivo se le reste el monto surcharge debido a que se reporta el monto del retiro + la comision surcharge.
-- MODIFICADO :  : 14/05/2010 Casanova Edeza Hector Juan  --Se pasa el parametro del monto surcharge al sp de tipo conciliacion para relizar validaciones extras de la transaccion.
--***************************************************************************************************

--CHECAR LO DE LA REFRENCIA
DEFINE vsmensajeError CHAR (500) ;
DEFINE vsReferencia CHAR (40) ;

DEFINE vsDESCRIPCION2 CHAR (100) ;
DEFINE vsDESCRIPCION3 CHAR (100) ;

DEFINE vsQUERY1 CHAR (1000) ;   --SELECT DE MOVIMIENTO
DEFINE vsQUERY2 CHAR (2000) ;    --INSERT DE MOVCONCILIADOS

DEFINE vsREGISTROCENTRAL1 CHAR (250) ;
DEFINE vsREGISTROCENTRAL2 CHAR (250) ;

/*  DEFINICION DE VARIABLES */

--- VARIABLES DEL SELECT DE MOVIMIENTOS
DEFINE vsMovSecuencia CHAR (7) ;    --ClaveAutorizacionDeTransaccion
DEFINE vsMovSecuenciaExtendida CHAR (16) ;    --ClaveAutorizacionDeTransaccion
DEFINE vsMovCodigoISO CHAR (2) ;
DEFINE vmMovMonto  MONEY ;
DEFINE vsMovMovConciliado  CHAR (1) ;
DEFINE vsMovMovReversado CHAR (1) ;
DEFINE vsMovFechaMov CHAR (4) ;
DEFINE vsMovCodigoCentral CHAR (5) ;
DEFINE vsMovSecuenciaOrig CHAR (7) ;
DEFINE vsMovHoraMov CHAR (6) ;
DEFINE vsMovCodReversa CHAR (1) ;
DEFINE vmMovMontoRealRevFzda MONEY ;
DEFINE vsMovIdTerminal CHAR (16) ;
DEFINE vsMovEnLinea CHAR (1) ;
DEFINE vsMovEsNacional CHAR (1) ;
DEFINE vsMovFechaLocalTransaccion CHAR (4) ;
DEFINE vsMovHoraLocalTransaccion CHAR (6) ;
--DEFINE vdtMovFechaHoraInAuthorizer CHAR (25) ;
DEFINE vdtMovFechaHoraInAuthorizer DATETIME YEAR TO FRACTION ;
DEFINE vsMovPermiteComisionPendiente CHAR (1) ;
DEFINE vsMovGeneroComisionPendiente CHAR (1) ;
DEFINE vsMovSecComision CHAR (7) ;
DEFINE vsMovComisionEnLinea CHAR (1) ;
DEFINE vmMovMontoComision MONEY ;
DEFINE vsMovCodigoRetComision CHAR (5) ;
DEFINE vmMovMontoSurcharge MONEY ;
DEFINE vsMovSecSurcharge CHAR (7) ;
DEFINE vsMovIdComercio CHAR (10) ;
DEFINE vmMovMontoCashBack  MONEY ;
DEFINE vmMovMontoComCashBack  MONEY ;
DEFINE vmMovMontoRetenido MONEY ;
DEFINE vsMovMoneda CHAR (3) ;
DEFINE vsMovSecuenciaCashBack  CHAR (7) ;
DEFINE vsMonvSecuenciaComCashBack CHAR (7) ;
DEFINE viStatusConSurcharge     INTEGER ;
DEFINE vsStatusComision CHAR (1) ;

--VARIABLES DE ENTORNO
DEFINE vsCodTran  CHAR (2) ;
DEFINE vsProdInd CHAR (2) ;
DEFINE vsFormato CHAR (4) ;
DEFINE vsRegistrado CHAR (1) ;
DEFINE vsCodRespBASE24 CHAR (3) ;
DEFINE vsFuenteId CHAR (3) ;
DEFINE vsNacional  CHAR (1) ;
DEFINE vsTarjetaNoRelacionada CHAR (1) ;
DEFINE vsEsPropio CHAR (1) ;
DEFINE vsEsConvenio CHAR (1) ;

DEFINE vsCodAux1 CHAR (2) ;
DEFINE vsCodAux2 CHAR (2) ;
DEFINE viContador INTEGER ;

DEFINE vmMontoTran MONEY ;

DEFINE viTipodeTransaccion INTEGER ;
DEFINE viStatusTarjeta INTEGER ;

DEFINE viStatusConciliacion  INTEGER ;

DEFINE vsSecEnviadaCentral CHAR (7) ;
DEFINE vsTipoEnviadaCentral CHAR (1) ;

DEFINE vsTipoRecibidaCentral     CHAR (1) ;
DEFINE vsTnrCobroComisionCtaIndividual  CHAR (1) ;
DEFINE vmTnrMontoComisionCtaIndividual MONEY ;

DEFINE vsCodRet CHAR (5) ;
DEFINE vsCodRetSurcharge CHAR (5) ;
DEFINE vsFechaAplib DATETIME YEAR TO FRACTION ;
DEFINE vsFechaReporteBreve DATETIME YEAR TO FRACTION ;
DEFINE vsFechaLocalTransaccion CHAR (4) ;
DEFINE vsFechaLocalTransaccionMMDD CHAR (4) ;
DEFINE vsHoraLocalTransaccion CHAR (6) ;

DEFINE vsTipoTransaccionConciliacion CHAR (4) ;
DEFINE vsFolioSucursal CHAR (16) ; /* de 15 a 16 No se usa*/
DEFINE vsDocumento CHAR (16) ; /* de 15 a 16*/
DEFINE vsTipoTransaccionSucursal CHAR (4) ;

DEFINE viGenRefTipoMovimiento INTEGER ;
DEFINE vsReferenciaComision CHAR (20) ;
DEFINE vsClaveAutorizacionDeTransaccion CHAR (7) ;
DEFINE vmMontoReversa MONEY ;

DEFINE viExisteEnMovimiento INTEGER ;
DEFINE vsCobrable CHAR (1) ;
DEFINE vsTransConciliado CHAR (1) ;
DEFINE vsStatusTarjeta CHAR (3) ;

DEFINE vsTipoConciliacion CHAR (2) ;
DEFINE vsTipoCajero CHAR (1) ;

--VARIABLES DE MANEJO DE ERRORES
DEFINE visqlerr   INTEGER ;
DEFINE viCodRet   INTEGER ;


DEFINE vsTemp CHAR (8) ;
/* INICIALIZACION DE VARIABLES */
LET vsmensajeError  = '' ;

LET vsReferencia = '' ;

--VARIABLES LOG 
LET vsDESCRIPCION2 = '' ;
LET vsDESCRIPCION3 = '' ;

LET vsQUERY1 = '' ;
LET vsQUERY2 = '' ;

LET vsREGISTROCENTRAL1 = '' ;
LET vsREGISTROCENTRAL2 = '' ;

--- VARIABLES DEL SELECT DE MOVIMIENTOS
LET vsMovSecuencia = '' ;
LET vsMovCodigoISO = '' ;
LET vmMovMonto = 0 ;
LET vsMovMovConciliado = '' ;
LET vsMovMovReversado = '' ;
LET vsMovFechaMov = '' ;
LET vsMovCodigoCentral = '' ;
LET vsMovSecuenciaOrig = '' ;
LET vsMovHoraMov = '' ;
LET vsMovCodReversa = '' ;
LET vmMovMontoRealRevFzda =  0 ;
LET vsMovIdTerminal = '' ;
LET vsMovEnLinea = '' ;
LET vsMovEsNacional = '' ;
LET vsMovFechaLocalTransaccion = '' ;
LET vsMovHoraLocalTransaccion = '' ;
LET vdtMovFechaHoraInAuthorizer = NULL ;
LET vsMovPermiteComisionPendiente = '' ;
LET vsMovGeneroComisionPendiente = '' ;
LET vsMovSecComision = '' ;
LET vsMovComisionEnLinea = '' ; 
LET vmMovMontoComision = 0 ;
LET vsMovCodigoRetComision = '' ;
LET vmMovMontoSurcharge = 0 ;
LET vsMovSecSurcharge = '' ;
LET vsMovIdComercio = '' ;
LET  vmMovMontoCashBack  = 0 ;
LET  vmMovMontoComCashBack  = 0 ;
LET vmMovMontoRetenido = 0 ;
LET vsMovSecuenciaCashBack = '' ;
LET vsMonvSecuenciaComCashBack  = '' ;
LET vsMovSecComision   = '' ;
LET viStatusConSurcharge = 0 ;
LET vsStatusComision = '' ;

-- VARIABLES DE ENTORNO

LET vsCodTran  = '00' ;
LET vsProdInd = '01' ;
LET vsFormato = '0200' ;
LET vsRegistrado = 'F' ;
LET vsFuenteId = '000' ;
LET vsNacional = 'v' ;
LET vsTarjetaNoRelacionada = 'F' ;
LET vsEsPropio = 'V' ;
LET vsEsConvenio = 'V' ;

LET vsCodAux1 = '00' ;
LET vsCodAux2 = '00' ;
LET viContador = 0 ;
LET vmMontoTran = 0 ;

LET viTipodeTransaccion  = 0 ;
LET viStatusTarjeta  = 0 ;

LET viStatusConciliacion = 0 ;
LET vsSecEnviadaCentral = '' ;
LET vsTipoEnviadaCentral  = '' ;

LET vsTipoRecibidaCentral = '' ;
LET vsTnrCobroComisionCtaIndividual  = '' ;
LET vmTnrMontoComisionCtaIndividual = 0 ;

LET vsCodRet  = NULL ;
LET vsCodRetSurcharge = NULL ;
LET vsFechaAplib = NULL ;
LET vsFechaReporteBreve = NULL ;
LET vsFechaLocalTransaccion = '' ;
LET vsFechaLocalTransaccionMMDD = '';
LET vsHoraLocalTransaccion = '' ;

LET vsTipoTransaccionConciliacion  = '' ;
LET vsFolioSucursal = '' ;
LET vsDocumento = '' ;
LET vsTipoTransaccionSucursal = '' ;

LET viGenRefTipoMovimiento  = 0 ; 
LET  vsReferenciaComision = '' ;
LET vsClaveAutorizacionDeTransaccion  = '' ;
LET vmMontoReversa = 0;
LET viExisteEnMovimiento  = 0 ;
LET vsTransConciliado  = 'F' ;
LET vsCobrable = 'F' ;

LET vsStatusTarjeta = '' ;

LET vsMovMoneda = '01' ;
LET vsCodRespBASE24 = '' ;

LET vsTipoCajero = '' ;

--VARIABLE DE MANEJO DE ERRORES
LET viCodRet = "0";
LET visqlerr = 0;

LET vsTemp = '' ;

LET vsTipoConciliacion = '' ;

BEGIN

    ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF visqlerr <> 0 THEN             

  --SET DEBUG FILE TO "/home/informix/jydg/sp_conciliacion_atm_registro.out";
  --TRACE ON;

            
            --GUARDA EL REGISTRO DEL LOG DE LA TRANSACCION ACTUAL

            EXECUTE PROCEDURE sp_Insertar_Bitacora ( psNumEmpleado, psArchivoOrigen, psActividad, ' ('|| visqlerr || ')  ' || vsmensajeError ||  '-- Registro Num: ' 
                    || piNumRegistro ) INTO viCodRet ;
					
			--SE AGREGA EL MONTO DE LAS TRANSACCIONES CON SURCHARGE AL MONTO TOTAL DE LA TRANSACCION (MONTO ORIGINAL DEL ARCHIVO)
			IF ((pmMonto > 0) AND (pmMontoSurcharge > 0)) THEN -- OPERACION DE RETIRO
				LET pmMonto = pmMonto + pmMontoSurcharge;
			END IF;
			
            EXECUTE PROCEDURE sp_Insertar_LOG_ATM ( psArchivoOrigen, psAdquiriente, psNumTarjeta, psNumCuenta, 
            psDescripcion, psIndicadordeReversa, psCodigoISO, psSecuenciaCajero, psFecha, psHora, pmMonto,  psNumCajero, psSecuenciaAuth,
			psResp, psOrden, psRed, psDolares, psNumAutorizacion, psCodPais,  psMontoOrigen,  --nuevo
			psCodMoneda, pmMontoSurcharge, pmDonativo, psEmpresa, psCompania,  --nuevo
			pmMonto_LoyaltyFee, pmMonto_UsoLinea, psNomBancoEmisor, psBanderaAdquiriente, --nuevo
            vsQUERY1 , vsMovCodigoISO, vsMovSecuencia, vsMovSecuenciaOrig, vsMovCodReversa, 
            vsMovComisionEnLinea, vsMovPermiteComisionPendiente, vsMovGeneroComisionPendiente, vsMovSecComision, 
            vmMovMontoComision,  vsMovCodigoRetComision, vmMovMonto, vmMovMontoRealRevFzda, vsMovMovConciliado , vsMovFechaMov, 
            vsMovHoraMov,vsMovMovReversado, vsMovEnLinea, vsMovIdTerminal, vsDESCRIPCION2 , vsDESCRIPCION3, 
            vsREGISTROCENTRAL1, vsREGISTROCENTRAL2, vsQUERY2 , viStatusConciliacion, vsTipoConciliacion ) INTO viCodRet  ;

           RETURN visqlerr, vsmensajeError ;

        END IF; 
    END EXCEPTION;

	
		--SE RESTA EL MONTO DE LAS TRANSACCIONES CON SURCHARGE AL MONTO TOTAL DE LA TRANSACCION
		IF ((pmMonto > 0) AND (pmMontoSurcharge > 0)) THEN -- OPERACION DE RETIRO
			LET pmMonto = pmMonto - pmMontoSurcharge;
		END IF;
		
        -- VALORES PREDETERMINADOS PARA ESTOS CAMPOS 

        LET vsReferencia = psSecuenciaCajero ;

        --ASIGNA EL CODIGO DE TRANSACCION CORRSPONDIENTE A LA DESCRIPCION DE LA TRANSACCION
        IF ( SUBSTRING (psDescripcion FROM 1 FOR 8 ) = 'RETIRO'  OR SUBSTRING (psDescripcion FROM 1 FOR 8 ) = 'VTA_ELEC' ) THEN 
            LET vsCodTran = '01' ;
            IF ( SUBSTRING (psIndicadordeReversa FROM 1 FOR 8 ) = 'REVERSAL') THEN 
                LET vsFormato = '0420' ;    --SI ES REVERSA CAMBIA EL CODIGO DEL FORMIATO
            END IF ;
        ELIF ( SUBSTRING (psDescripcion FROM 1 FOR 8 ) = 'CONSULTA' ) THEN 
            LET vsCodTran = '31';
        ELIF ( SUBSTRING (psDescripcion FROM 1 FOR 8 ) = 'CAMB_NIP' ) THEN 
            LET vsCodTran = '81' ;
        END IF ; 

        IF ( SUBSTRING ( psAdquiriente FROM 1 FOR 8  ) = 'VISA' )  THEN --TRANSACCION INTERNACIONAL
            LET vsNacional = 'F' ;
        ELSE  --TRANSACCION NACIONAL
            LET vsNacional = 'V' ;
        END IF ;

        LET  vsCodRespBASE24  = LPAD ( TRIM ( psCodigoISO ), 3, "0" ) ;
        
        IF ( psCodigoISO = '00' ) THEN -- CHECA QUE LA TRANSACCION ESTE APROVADA
               
            IF (psAdquiriente = 'VISA' )  AND  ( SUBSTRING (psDescripcion FROM 1 FOR 8 ) <> 'CONSULTA'  AND  SUBSTRING (psDescripcion FROM 1 FOR 8 ) <> 'RETIRO'  ) THEN
                 --ES UNA TRANSACCION INTERNACIONAL Y NO ES CONSULTA NI RETIRO Y SERA IGNORADA
                LET vsDESCRIPCION3 = 'Aviso. Transaccion VISA Ignorada' ;
                LET vsTipoConciliacion = 'B' ;

            ELSE    --TRANSACCION NACIONAL O INTERNACIONAL (CONSULTA O RETIRO)
                LET vsmensajeError = 'Obtiene Informacion del adquiriente de la transaccion -- sp_EsPropio( ' || 
                psAdquiriente || ' ) INTO vsEsPropio ;'   ;
                --REGRESA UN V O F INDICANDO SI LA TRANS SE REALIZO EN UN CAJERO PROPIO (COPPEL)
                EXECUTE PROCEDURE sp_EsPropio( psAdquiriente ) INTO vsEsPropio ;
                LET vsmensajeError = 'Obtiene Informacion del adquiriente de la transaccion -- sp_EsConvenio( ' 
                || psAdquiriente || ' ) INTO vsEsConvenio;'   ;
                EXECUTE PROCEDURE sp_EsConvenio( psAdquiriente ) INTO vsEsConvenio ;
                
                LET vsmensajeError = 'Obtiene datos de la transaccion de la tabla de movimientos -- ' ||
                'sp_ObtenerDatosTransaccionDBMovimiento_ATM ( ' || psDescripcion || ', ' || psNumTarjeta|| ', ' || 
                vsFormato|| ', ' || vsProdInd|| ', ' || vsCodTran || ', ' || psFecha || ', ' || psHora || ', ' || psSecuenciaCajero || ', ' || 
                psAdquiriente || ', ' || psSecuenciaAuth  || ') ' ;

                EXECUTE PROCEDURE sp_ObtenerDatosTransaccionDBMovimiento_ATM
                ( psDescripcion,  psNumTarjeta,  vsFormato, vsProdInd,  vsCodTran, psFecha, psHora, psSecuenciaCajero, 
                psAdquiriente, psSecuenciaAuth ) 
                INTO  viExisteEnMovimiento, vsMovSecuencia, vsMovSecuenciaExtendida, vsMovCodigoISO, vmMovMonto, vsMovMovConciliado, 
                vsMovMovReversado, vsMovFechaMov, vsMovCodigoCentral, vsMovSecuenciaOrig, vsMovHoraMov, 
                vsMovCodReversa, vmMovMontoRealRevFzda, vsMovIdTerminal, vsMovEnLinea, vsMovEsNacional, 
                vsMovFechaLocalTransaccion, vsMovHoraLocalTransaccion, vdtMovFechaHoraInAuthorizer, 
                vsMovPermiteComisionPendiente, vsMovGeneroComisionPendiente, vsMovSecComision, 
                vsMovComisionEnLinea, vmMovMontoComision, vsMovCodigoRetComision, vmMovMontoSurcharge, 
                vsMovSecSurcharge,  vmMovMontoCashBack, vmMovMontoComCashBack, vsMovSecuenciaCashBack, 
                vsMonvSecuenciaComCashBack, vsQUERY1 ; 
                
                LET vsFechaLocalTransaccion = SUBSTRING ( psFecha FROM 1 FOR 2 ) || SUBSTRING ( psFecha FROM 4 FOR 2 ) ;
                LET vsFechaLocalTransaccionMMDD = SUBSTRING ( psFecha FROM 4 FOR 2 ) || SUBSTRING ( psFecha FROM 1 FOR 2 );
                LET vsHoraLocalTransaccion =  REPLACE (psHora, ':', '' ) ;

                --Si la bandera indica que si se generó una comisión pendiente, se verifica si efectivamente 
                --existe un registro para la comisión pendiente, dado que si el movimiento fue reversado totalmente, 
                --dicho registro se debió haber eliminado y por lo tanto, se debería considerar como si no se hubiera generado la
                --comisión pendiente.
                IF ( viExisteEnMovimiento = 1 ) THEN 
                    LET vsRegistrado = 'V' ;
                ELSE
                    LET vsRegistrado = 'F' ;
                END IF ;

                LET vmMontoTran  = vmMovMonto ;       -- ESTE MONTO VA EN EL LOG. EN EL MONTO
                
                EXECUTE PROCEDURE sp_GetTypeOfTransaction( vsProdInd, vsFormato , vsCodTran , 0 ,  0 ) INTO viTipodeTransaccion  ;

                EXECUTE PROCEDURE sp_EstaBloqueadaoCancelada( psNumTarjeta, SUBSTRING ( psFecha FROM 4 FOR 2) || '/' || 
                SUBSTRING ( psFecha FROM 1 FOR 2) || '/' ||  SUBSTRING ( psFecha FROM 7 FOR 2), psHora ) INTO  viStatusTarjeta, vsStatusTarjeta ;

                IF ( vsEsPropio = 'V' ) THEN -- CAJEROS PROPIOS
                    LET vsTipoCajero = '1' ;
                ELIF ( vsEsConvenio = 'V' ) THEN --CAJEROS EN CONVENIO
                    LET vsTipoCajero = '2' ;
                ELIF ( vsMovEsNacional = 'F' ) THEN  --CAJEROS INTERNACIONALES
                    LET vsTipoCajero = '3' ;
                ELSE -- CAJEROS EN RED  
                    LET vsTipoCajero = '4' ;
                END IF ;

                LET vsmensajeError = 'Clasificacion de Conciliacion --  sp_Tipo_Conciliacion_ATM ' ;

		--Se cambio vsFolioSucursal X vsMovSecuenciaExtendida  
                EXECUTE PROCEDURE sp_Tipo_Conciliacion_ATM ( viExisteEnMovimiento, vsTipoCajero, viStatusTarjeta, SUBSTRING (psDescripcion FROM 1 FOR 8 ), 
                vsMovMovConciliado, psCodigoISO, vsMovCodigoISO, vsMovCodigoCentral, pmMonto, vmMovMonto,
                SUBSTRING (psIndicadordeReversa FROM 1 FOR 8 ), vsMovCodReversa, vsMovMovReversado, vsMovSecuenciaOrig, vsNacional, 
                viGenRefTipoMovimiento, psAdquiriente, vsMovSecuencia,  psUsuarioParametros, psArchivoOrigen, 
                psNumTarjeta, vsDocumento, vsMovSecuenciaExtendida , vsFolioSucursal, vsMovMoneda, vsReferencia, 
                vmMovMontoCashBack, psRFC, psReferenciaTransaccion, vmMovMontoComision, vmMovMontoRealRevFzda, 
                vmMontoTran, psNumCajero, vsMovSecComision, vsFechaLocalTransaccionMMDD, vsHoraLocalTransaccion, pmMontoSurcharge)  
                INTO vsClaveAutorizacionDeTransaccion, vsMovSecComision, viStatusConciliacion, vsDESCRIPCION2, vsDESCRIPCION3, 
                vsREGISTROCENTRAL1, vsREGISTROCENTRAL2, vmMontoReversa, viTipodeTransaccion, vsSecEnviadaCentral, vsTipoEnviadaCentral,
                vsTipoConciliacion ;

            END IF ;  --IF (psAdquiriente = 'VISA' )  AND  (psDescripcion =! 'CONSULTA'  AND  psDescripcion =! 'RETIRO'  ) 

        ELSE --SI ES DISTINTO DE 00
            --LET vsDESCRIPCION2 = 'Aviso. Transaccion con numero de Cuenta no asociada. NumTarjeta:[' || psNumTarjeta || ']' ;
            LET vsDESCRIPCION2 = 'Aviso. Transaccion Rechazada  CodigoISo: [' || psCodigoISO || ']' ;
            LET viStatusConciliacion = 17 ;
            LET vsTipoConciliacion = 'A' ;
            LET vsmensajeError = 'sp_ActualizaMovimiento ( "1' || psSecuenciaAuth || '", "' || psNumTarjeta || '", "01")' ;
            --EXECUTE PROCEDURE sp_ActualizaMovimiento ( psSecuenciaAuth, psNumTarjeta, '01' ) INTO vsmensajeError ;
        END IF ; -- ---IF ( psCodigoISO = '00' ) 

        IF ( viStatusConciliacion <> 0) THEN 
         -- ESCRIBE EN LA TABLA DE MOVCONCILIADOS
            LET vsmensajeError = 'Guarda en la Tabla de MovConciliados --  sp_InsertaMovConciliados ' ;  

            EXECUTE PROCEDURE sp_InsertaMovConciliados (
                vsClaveAutorizacionDeTransaccion , 
                psCodigoISO ,
                vsCodRespBASE24 , 
                vsCodRet  ,    
                vsCodRetSurcharge ,
                vsMovCodReversa , 
                vsCodTran , 
                vsEsConvenio ,   
                vsEspropio , 
                vsFechaAplib ,	
                SUBSTRING (REPLACE ( REPLACE ( REPLACE (CURRENT, '-', ''  ), ':', '' ), ' ', '' ) FROM 1 FOR 14 ),  --fechadeconciliacion  '20071205133103',
                vsFechaReporteBreve,    
                SUBSTRING ( psFecha FROM 4 FOR 2 ) ||  '/' || SUBSTRING ( psFecha FROM 1 FOR 2 ) || '/' || SUBSTRING ( psFecha FROM 7 FOR 2 ),
                vdtMovFechaHoraInAuthorizer,  
                vsFechaLocalTransaccion ,  
                vsFormato , 
                vsFuenteId , 
                psHora,
                vsHoraLocalTransaccion,  
                vsMovIdComercio , 
                psAdquiriente, 
                vmMovMontoCashBack , 
                vmMovMontoComCashBack , 
                vmMovMontoComision ,
                pmMonto ,
                vmMovMontoRealRevFzda ,
                vmMontoTran ,
                vmMovMontoSurcharge ,
                vsMovMovReversado , 
                vsNacional , 
                psNombreComercio  , 
                psNumCuenta , 
                psNumTarjeta , 
                vsProdInd , 
                vsReferencia , 
                psReferenciaTransaccion , 
                vsRegistrado , 
                psRFC  , 
                vsSecEnviadaCentral , 
                vsMovSecSurcharge , 
                vsMovSecuenciaCashBack , 
                vsMonvSecuenciaComCashBack  , 
                vsMovSecComision , 
                viStatusConSurcharge  ,
                vsMovCodigoCentral, 
                vsStatusComision , 
                viStatusConciliacion ,
                vsStatusTarjeta, --viStatusTarjeta , 
                vsTipoEnviadaCentral , 
                psArchivoOrigen , 
                vsTipoRecibidaCentral,
                vsTnrCobroComisionCtaIndividual,
                vmTnrMontoComisionCtaIndividual
                ) 
                INTO vsQUERY2 ;   

        END IF ;

   
         IF ( ( viExisteEnMovimiento > 0 ) AND ( viStatusConciliacion <> 0) ) THEN
            --actualizar el movimiento en la tabla como conciliado
            LET vsmensajeError = 'sp_ActualizaMovimiento ( "1' || psSecuenciaAuth || '", "' || psNumTarjeta || '", "01", "' || vdtMovFechaHoraInAuthorizer || '")' ;
            EXECUTE PROCEDURE sp_ActualizaMovimiento ( psSecuenciaAuth, psNumTarjeta, '01',  vdtMovFechaHoraInAuthorizer ) INTO vsmensajeError ;
        END IF ;        

        --GUARDA EL REGISTRO DEL LOG DE LA TRANSACCION ACTUAL
        LET vsmensajeError = 'Guarda el recorrido de la transaccion en LOG_ATM -- sp_Insertar_LOG_ATM ( ) ' ;

		--SE AGREGA EL MONTO DE LAS TRANSACCIONES CON SURCHARGE AL MONTO TOTAL DE LA TRANSACCION (MONTO ORIGINAL DEL ARCHIVO)
		IF ((pmMonto > 0) AND (pmMontoSurcharge > 0)) THEN -- OPERACION DE RETIRO
			LET pmMonto = pmMonto + pmMontoSurcharge;
		END IF;
			
        EXECUTE PROCEDURE sp_Insertar_LOG_ATM ( psArchivoOrigen, psAdquiriente, psNumTarjeta, psNumCuenta, 
        psDescripcion, psIndicadordeReversa, psCodigoISO, psSecuenciaCajero, psFecha, psHora, pmMonto, psNumCajero, psSecuenciaAuth,
		psResp, psOrden, psRed, psDolares, psNumAutorizacion, psCodPais,  psMontoOrigen,  --nuevo
		psCodMoneda, pmMontoSurcharge, pmDonativo, psEmpresa, psCompania,  --nuevo
		pmMonto_LoyaltyFee, pmMonto_UsoLinea, psNomBancoEmisor, psBanderaAdquiriente, --nuevo
        vsQUERY1 , vsMovCodigoISO, vsMovSecuencia, vsMovSecuenciaOrig, vsMovCodReversa, 
        vsMovComisionEnLinea, vsMovPermiteComisionPendiente, vsMovGeneroComisionPendiente, vsMovSecComision, 
        vmMovMontoComision,  vsMovCodigoRetComision, vmMovMonto, vmMovMontoRealRevFzda, vsMovMovConciliado , vsMovFechaMov, 
        vsMovHoraMov,vsMovMovReversado, vsMovEnLinea, vsMovIdTerminal, vsDESCRIPCION2 , vsDESCRIPCION3, 
        vsREGISTROCENTRAL1, vsREGISTROCENTRAL2, vsQUERY2 , viStatusConciliacion, vsTipoConciliacion ) INTO viCodRet  ;

    
    RETURN visqlerr, vsmensajeError ;
   
END

END PROCEDURE
/*DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: PROCEDO DE CONCILIACION A UN REGISTRO DE ATM.',
'Fecha: 2008/01/07',
'Version: 20080107.1025',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agregan los parametros Resp,Orden,Red,Dolares,NumAutorizacion,CodPais, MontoOrigen,CodMoneda,MontoSurcharge,Donativo,Empresa,Compañia,Monto_LoyaltyFee,Monto_UsoLinea,NomBancoEmisor y BanderaAdquiriente para que se guarden en la tabla Log_ATM .',
'Fecha: 2010/04/15',
'Version: 20100415.1859',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Modificacion',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se modifico la logica para que el monto representado en el archivo se le reste el monto surcharge debido a que se reporta el monto del retiro + la comision surcharge.',
'Fecha: 2010/05/11',
'Version: 20100511.1854',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Modificacion',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se pasa el parametro del monto surcharge al sp de tipo conciliacion para relizar validaciones extras de la transaccion.',
'Fecha: 2010/05/14',
'Version: 20100514.1854',
'BD: Intercard'*/;

CREATE PROCEDURE "informix".sp_borrararchconaut(
psNumeroEmpleado CHAR(8)
)

RETURNING INTEGER;

--****************************************************************************************************
-- DESCRIPCION:  BORRA ARCHIVOS DEL SERVIDOR
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 29/09/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard -- Automatico
--***************************************************************************************************

/* DEFINICION DE VARIABLES*/
DEFINE viSqlErr INTEGER;
DEFINE viContador INTEGER;
DEFINE vsNomArchivo CHAR (25);
DEFINE vsRuta_Repositorio_AIX CHAR(90);
DEFINE vsArchivoOrigen CHAR(3);
DEFINE vsRuta_Repositorio_WIN CHAR(90);
DEFINE viDias INTEGER;
DEFINE vsSQLC CHAR(100);
DEFINE vdFecha DATE;
DEFINE vsActividad CHAR(25);


/* INICIALIZACION DE VARIABLES */
LET viSqlErr = 0;
LET viContador = 0;
LET vsNomArchivo = '';
LET vsRuta_Repositorio_AIX = '';
LET vsArchivoOrigen = '';
LET vsRuta_Repositorio_WIN = '';
LET viDias = 0;
LET vsSQLC = ''; 
LET vdFecha = CURRENT;
LET vsActividad = '';


-- set debug file to "/tmp/conciliacion/pruebaborrado.txt";
-- Trace on;

BEGIN

ON EXCEPTION SET viSqlErr
	IF viSqlErr <> 0 THEN
	RETURN viSqlErr;
	
	END IF;
END EXCEPTION;

		LET viContador = 0 ;		
		WHILE (viContador < 11) --VERIFICA LA EXISTENCIA DE LOS 11 TIPOS DE ARCHIVO A CONCILIAR
				
			LET viContador = viContador + 1 ;			LET vsNomArchivo = '';
						
			--SE OBTIENE EL NOMBRE DEL ARCHIVO 			
			EXECUTE PROCEDURE sp_obtenernombrearchivo  ( viContador ) INTO vsNomArchivo, vsRuta_Repositorio_AIX, vsArchivoOrigen, vsRuta_Repositorio_WIN;
			--OBTENEMOS LA CANTIDAD DE DIAS QUE LSO ARCHIVOS PODRAN ESTAR EN EL SERVIDOR			
			SET ISOLATION TO DIRTY READ ;
			SELECT valor INTO viDias FROM intercard:param_conciliacionauto WHERE descripcion = vsArchivoOrigen;
			--LOS DIAS TIENEN QUE SER MAYOR A CERO PARA PODER PROCEDER CON EL BORRADO DE ARCHIVOS 	
			IF(viDias > 0) THEN
				LET vsSQLC ='';				
				IF( viContador >= 5 ) AND ( viContador <= 8 ) THEN--EN ESTE RANGO SE ENCUENTRAN LOS ARCHIVOS ATM
					LET	vdFecha = CURRENT::DATE -(1) - viDias;					LET vsNomArchivo = SUBSTRING(vsNomArchivo FROM 1 FOR 10);					--LE AGREGAMOS LA NUEVA FECHA PARA QUE BORRE LOS ARCHIVOS INDICADOS					
					LET vsNomArchivo = TRIM(vsNomArchivo) || SUBSTRING (vdFecha FROM 4 FOR 2 ) || SUBSTRING (vdFecha FROM 1 FOR 2 ) || SUBSTRING (vdFecha FROM 9 FOR 2 ) || '.txt' ;
											
				ELIF (( viContador >= 1 ) AND ( viContador <= 4 )) OR (( viContador >= 9 ) AND ( viContador <= 13 )) THEN--EN ESTE RANGO SE ENCUENTRAN LOS ARCHIVOS POS , INTERREDES Y CORRESPONSALES
					IF ( viContador = 13 ) THEN--SOLO SI ES ARCHIVO PNC 
						LET	vdFecha = CURRENT::DATE -(1) - viDias;
						LET vsNomArchivo = SUBSTRING(vsNomArchivo FROM 1 FOR 8);						
						LET vsNomArchivo = TRIM(vsNomArchivo) || SUBSTRING (vdFecha FROM 4 FOR 2 ) || SUBSTRING (vdFecha FROM 1 FOR 2 ) || SUBSTRING (vdFecha FROM 7 FOR 4 ) || '.txt' ;
					ELSE --POS NORMALES
						LET vsNomArchivo = SUBSTRING(vsNomArchivo FROM 1 FOR 8);	
						LET	vdFecha = CURRENT::DATE - viDias;
						LET vsNomArchivo = TRIM(vsNomArchivo) || SUBSTRING (vdFecha FROM 4 FOR 2 ) || SUBSTRING (vdFecha FROM 1 FOR 2 ) || SUBSTRING (vdFecha FROM 7 FOR 4 ) || '.txt' ;		
					END IF;
				END IF;
				
				--SE ARMA EL NOMBRE DEL ARCHIVO BORRADO ES DECIR UNA DESCRIPCION QUE SE INSERTARA EN LA TABLA DE BITACORA_CONCILIACION
				LET vsActividad = 'ARCH ' || TRIM(vsArchivoOrigen) || '_' || SUBSTRING (vdFecha FROM 4 FOR 2 ) || SUBSTRING (vdFecha FROM 1 FOR 2 ) || SUBSTRING (vdFecha FROM 9 FOR 2 ) || ' BORRADO';	
				--SI NO EXISTE EL NOMBRE ARMADO ANTERIORMENTE EN LA TABLA BITACORA CONCILIACION SE PROCEDERA A BORRAR EL ARCHIVO DEL SERVIDOR Y SE INSERTA INFORMACION EN BITACORA CONCILIACION
				SET ISOLATION TO DIRTY READ ;
				IF NOT EXISTS(SELECT actividad FROM bitacora_conciliacion WHERE actividad = vsActividad) THEN					
					LET vsSQLC = 'rm -f ' || TRIM(vsRuta_Repositorio_AIX) || '/' || TRIM(vsNomArchivo); 
					SYSTEM vsSQLC;
					EXECUTE PROCEDURE sp_insertar_bitacora ( psNumeroEmpleado, vsArchivoOrigen, vsActividad, '') INTO viSQlErr ;	
				END IF;				
				
			END IF;
			
		END WHILE;		
	RETURN viSqlErr;	
					
END

END PROCEDURE
/*DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: BORRA ARCHIVOS DE CONCILIACION DEL SERVIDOR.',
'Fecha: 2008/09/29',
'Version: 20090829.0933',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Corresponsales',
'Folio: 1122',
'Solicito: Jose Luis Puebla',
'Descripcion: Se modifico el flujo para que contemple los nuevos archivos archivos de corresponsales de pagos(CCP), depositos(CCD) se manejan como archivos de POS durante el proceso de borrado de archivos en el servidor.',
'Fecha: 2010/04/26',
'Version: 20100426.0920',
'BD: Intercard'*/;

CREATE PROCEDURE "informix".sp_consultaconadmincorr(
psArchivoOrigen CHAR(3),
pdFecha DATE
)

RETURNING	CHAR(3) AS archivoorigen, CHAR(23) AS nomarchivo325, CHAR(23) AS nomarchivocom, DATE AS fecharegistro, DATE AS fecha, CHAR(4) AS prodtarjeta, CHAR(16) AS tarjeta,
			CHAR(12) AS cuenta, CHAR(1) AS tipomov, CHAR(4) AS tran_central, CHAR(16) AS folio325, MONEY(16,6) AS monto325, CHAR(1) AS estatus, CHAR(4) AS txnliberacion, CHAR(19) AS cuentac,
			CHAR(19) AS cuentaa, CHAR(16) AS foliosif, MONEY(16,6) AS montosif, CHAR(8) AS usuario;

--****************************************************************************************************
-- DESCRIPCION: Consulta de administracion de corresponsales, obtiene informacion de tabla conadmin.
-- AUTOR : Rochin Rocha Edgar Ivan 
-- FECHA : 04/22/2010
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica
--****************************************************************************************************
--DECLARA VARIABLES
DEFINE vsarchivoorigen		CHAR(3);
DEFINE vsnomarchivo325		CHAR(23);
DEFINE vsnomarchivocom		CHAR(23);
DEFINE vdfecharegistro		DATE;
DEFINE vdfecha				DATE;
DEFINE vsprodtarjeta		CHAR(4);
DEFINE vstarjeta			CHAR(16);
DEFINE vscuenta				CHAR(12);
DEFINE vstipomov			CHAR(1);
DEFINE vstran_central		CHAR(4);
DEFINE vsfolio325			CHAR(16);
DEFINE vmmonto325			MONEY(16,6);
DEFINE vsestatus			CHAR(1);
DEFINE vstxnliberacion		CHAR(4);
DEFINE vscuentac			CHAR(19);
DEFINE vscuentaa			CHAR(19);
DEFINE vsfoliosif			CHAR(16);
DEFINE vmmontosif			MONEY(16,6);
DEFINE vsusuario			CHAR(8);

DEFINE viSqlErr				INTEGER;

--INICIA VARIABLES
LET vsarchivoorigen = '';
LET vsnomarchivo325 = '';
LET vsnomarchivocom = '';
LET vdfecharegistro = CURRENT;
LET vdfecha = CURRENT;
LET vsprodtarjeta = '';
LET vstarjeta = '';
LET vscuenta = '';
LET vstipomov = '';
LET vstran_central = '';
LET vsfolio325 = '';
LET vmmonto325 = 0.0;
LET vsestatus = '';
LET vstxnliberacion = '';
LET vscuentac = '';
LET vscuentaa = '';
LET vsfoliosif = '';
LET vmmontosif = 0.0;
LET vsusuario = '';

LET viSqlErr = 0;

--SET debug file to "/home/sysifx/conciliacion/Corresponsales/_consultaconadmincorr.sql";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
	RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vsusuario WITH RESUME;
	END IF; 
END EXCEPTION ;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
--Verifica si el parametro archivo origen fue proporcionado en blanco o nulo.
IF(psArchivoOrigen = "") OR (psArchivoOrigen IS NULL)THEN
	--El campo archivo origen esta en blanco o nulo.
	LET vsarchivoorigen = '001';
	RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vsusuario WITH RESUME;
--Verifica si el parametro fecha fue proporcionado en blanco o nulo.
ELIF(pdFecha = "") OR (pdFecha IS NULL)THEN
	--El campo fecha esta en blanco o nulo.
	LET vsarchivoorigen = '002';
	RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vsusuario WITH RESUME;
ELSE
	--Devuelve los registros de tabla conadmin correspondientes al tipo de archivoorigen.
	FOREACH
	SELECT archivoorigen, nomarchivo325, nomarchivocom, fecharegistro, fecha, prodtarjeta, tarjeta, cuenta, tipomov, tran_central, folio325, monto325, estatus, txnliberacion,
		   cuentac, cuentaa, foliosif, montosif, usuario
	INTO   vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vsusuario
	FROM   intercard:conadmin
	WHERE  archivoorigen = psArchivoOrigen AND pdFecha BETWEEN fecha AND fecha ORDER BY keyx ASC

	RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vsusuario WITH RESUME;
	END FOREACH
END IF;

END
END PROCEDURE
/*DOCUMENT
'AUTOR: Rochin Rocha Edgar Ivan',
'Proyecto: Conciliacion Automatica',
'Descripcion: Consulta de administracion de corresponsales, obtiene informacion de tabla conadmin.',
'Fecha: 04/22/2010',
'Version: 20100422.1025',
'BD: Intercard'*/;

CREATE PROCEDURE "informix".sp_regeneracion_movimientohistorico
(
pdFechaInicial DATETIME YEAR TO FRACTION (5),
pdFechaFinal DATETIME YEAR TO FRACTION (5)
)
RETURNING INTEGER AS X, CHAR(500) AS DescripcionError, DATETIME YEAR TO FRACTION (5) AS InicioT, DATETIME YEAR TO FRACTION (5) AS FinT,
          INTEGER AS NUMREG;

--****************************************************************************************************
-- DESCRIPCION: Regenera secuencias extendidas y Surcharge de los movimientos históricos Intercard
-- AUTOR : Luis Antonio Gómez Santiago
-- FECHA : 13/07/2010
-- BD: Intercard
-- SISTEMA : SIF
--***************************************************************************************************

DEFINE vsDecripcionError CHAR(500);
DEFINE viSqlErr INTEGER;

DEFINE vsFlagEnTransaccion CHAR(1);
DEFINE viContadorRegistros INTEGER;
DEFINE viContadorRegistrosTot INTEGER;

DEFINE v_secuencia VARCHAR(7);
DEFINE v_numtarjeta VARCHAR(16);
DEFINE v_fechahorainauth DATETIME YEAR TO FRACTION (5);
DEFINE v_prodind VARCHAR(2);
DEFINE v_montosurcharge DECIMAL(19,4);
DEFINE v_fechalocaltransaccion VARCHAR(4);
DEFINE v_horalocaltransaccion VARCHAR(6);
DEFINE vdInicio DATETIME YEAR TO FRACTION (5);
DEFINE vdFin DATETIME YEAR TO FRACTION (5);

LET vsDecripcionError = "";
LET viSqlErr = 0;
LET v_secuencia = "";
LET v_numtarjeta = "";
LET v_fechahorainauth = CURRENT;
LET v_prodind = "";
LET v_montosurcharge = 0.0;
LET vdInicio = CURRENT;
LET vdFin = CURRENT;
LET v_fechalocaltransaccion = "";
LET v_horalocaltransaccion = "";

BEGIN

ON EXCEPTION SET viSqlErr
	IF viSqlErr <> 0 THEN 
		RETURN viSqlErr, vsDecripcionError, vdInicio, vdFin, viContadorRegistrosTot;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/home/informix/secuencia.out";
--TRACE ON;

IF(pdFechaInicial = "") OR (pdFechaFinal IS NULL) THEN
    LET viSqlErr = 1 ;	
    RETURN viSqlErr, vsDecripcionError, vdInicio, vdFin, viContadorRegistrosTot;
END IF;

IF (pdFechaInicial = "") OR (pdFechaFinal IS NULL) THEN
    LET viSqlErr = 2;	
    RETURN viSqlErr, vsDecripcionError, vdInicio, vdFin, viContadorRegistrosTot;
END IF;

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;
LET viContadorRegistrosTot = 0;

FOREACH WITH HOLD                  
           select {+INDEX(intercard:movimientohistorico idx_movimiento3)}                         
                secuencia, numtarjeta, fechahorainauth, prodind, montosurcharge 
           into v_secuencia, v_numtarjeta, v_fechahorainauth, v_prodind, v_montosurcharge 
           from intercard:movimientohistorico
           where fechahorainauth between pdFechaInicial and pdFechaFinal      
           IF(vsFlagEnTransaccion = 'F') THEN
              BEGIN WORK;
                LET vsFlagEnTransaccion = 'V';
            END IF;

           IF (v_prodind = '01' AND v_montosurcharge > 0.0) THEN
               update {+INDEX(intercard:movimientohistorico idx_movimiento3)}         
                         intercard:movimientohistorico
                     set secuenciaextendida = 
                             (fechalocaltransaccion || substring(horalocaltransaccion from 1 for 4)  || secuencia),
                         surcharge = 'V'
                     where fechahorainauth = v_fechahorainauth and
                           numtarjeta = v_numtarjeta and
                           secuencia = v_secuencia; 
           ELSE
               update {+INDEX(intercard:movimientohistorico idx_movimiento3)}         
                         intercard:movimientohistorico
                     set secuenciaextendida = 
                         (fechalocaltransaccion || substring(horalocaltransaccion from 1 for 4)  || secuencia) 
                     where fechahorainauth = v_fechahorainauth and
                           numtarjeta = v_numtarjeta and
                           secuencia = v_secuencia; 
           END IF;

           LET viContadorRegistros = viContadorRegistros + 1;           

           IF (viContadorRegistros = 10000) THEN
              COMMIT WORK;
              LET vsFlagEnTransaccion = 'F';
              LET viContadorRegistrosTot = viContadorRegistrosTot + viContadorRegistros;
              LET viContadorRegistros = 0;
              CONTINUE FOREACH;
           END IF;
        END FOREACH;
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN
           COMMIT WORK;           
           LET vsFlagEnTransaccion = 'F';
           LET viContadorRegistrosTot = viContadorRegistrosTot + viContadorRegistros;
        END IF;
END
LET vdFin = current;
RETURN viSqlErr, vsDecripcionError, vdInicio, vdFin, viContadorRegistrosTot;
END PROCEDURE;