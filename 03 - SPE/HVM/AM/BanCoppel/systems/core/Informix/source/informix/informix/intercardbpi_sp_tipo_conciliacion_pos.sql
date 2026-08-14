CREATE PROCEDURE "informix".sp_tipo_conciliacion_pos( 
psUsuarioParametros CHAR (8), psArchivoOrigen CHAR (3), psNumTarjeta CHAR(16), psCodigoISO CHAR (2), psNombreComercio CHAR (30),  psRFC CHAR(16), 
psSecuenciaAuth CHAR (6), pmMonto MONEY, pmMontoCashBack MONEY, psMoneda CHAR (3), psCodTran CHAR (2), psRefTransaccion CHAR (23),
psDivisa CHAR (3), pmMontoDivisa MONEY, psFormadePago CHAR(1),
piExisteEnMovimiento INTEGER, psMovSecuencia CHAR(7), psSecuenciaExtendida CHAR(16), psMovMovConciliado CHAR (1), psMovMoneda CHAR(3), pmMovMonto MONEY,
pmMovMontoCashBack MONEY, pmMovMontoComision MONEY, pmMovMontoRealRevFzda MONEY,
psMovCodTran CHAR (2), psmovFormato CHAR (4), psMovSecuenciaCashBack CHAR (7), pmMovMontoComCashBack MONEY, psMovSecuenciaComCashBack CHAR (7),
psCodigoCentral CHAR (5),
piExisteReverzaForzada INTEGER,  psRFCodigoCentral CHAR (5), psRFSecuencia CHAR (7), psRFCodigoISO CHAR (2), psRFFormato CHAR (4), 
vsRFCodTran CHAR (2), vmRFMonto MONEY, vmRFMontoCashBack MONEY,
psTipoTransaccion CHAR (2), psConvenioInterEmpresa CHAR (10), psTipoTransInterEmpresa CHAR (4), pmMontoComInterEmpresa MONEY, psFechaLocalTransaccion CHAR (4), psHoraLocalTransaccion CHAR (6), psTransaccionOrigen CHAR (4) )
RETURNING CHAR (7), CHAR (7), INTEGER, CHAR (100), CHAR (100), CHAR (200), CHAR (250), CHAR (250), MONEY, INTEGER, CHAR (7), CHAR (7), CHAR (7), 
CHAR (1), CHAR (2) ;

--****************************************************************************************************
-- DESCRIPCION: ASIGNA EL TIPO DE CONCILIACION PARA POS
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 10/03/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : 17/06/2008 --ZERO 
-- MODIFICADO : 05/11/2009 --  Casanova Edeza Hector Juan.  
-- MODIFICADO : 14/04/2010 --  Jacqueline Dominguez - Folio Extendido.
--***************************************************************************************************

DEFINE vsMovSecuenciaCashBack CHAR (7) ;
DEFINE vsMovSecuenciaComCashBack  CHAR (7) ;

DEFINE vsClaveAutorizacionDeTransaccion CHAR (7) ;
DEFINE vsSecuencia CHAR (6) ;
DEFINE vsMovSecuenciaOrig CHAR (6) ;

DEFINE viStatusConciliacion INTEGER ;
DEFINE vsFolioSucursal CHAR (16);
DEFINE viTipoTransaccionPOS INTEGER ;

DEFINE vsTipoTran CHAR (2) ;
DEFINE vsMovCodReversa CHAR (1) ;
DEFINE vsSecEnviadaCentral CHAR (7);

DEFINE vsReferencia CHAR (40) ;
DEFINE vsReferenciaComision CHAR (40) ;
DEFINE vsMovSecComision CHAR (7) ;
DEFINE vmMontoReversa MONEY ;

DEFINE vsDESCRIPCION1 CHAR (100) ;
DEFINE vsDESCRIPCION2 CHAR (100) ;
DEFINE vsDESCRIPCION3 CHAR (200) ;

DEFINE vsTipoEnviadaCentral CHAR (1) ;
DEFINE vsDocumento CHAR (15) ;
DEFINE vsFolioOrig CHAR(15) ;
DEFINE vsDocumentoOrig CHAR(7);
DEFINE vsTransaccionOrig CHAR(4);
DEFINE vsSecuenciaComision CHAR (7) ;

DEFINE vmMontoOrig MONEY ;

DEFINE vsNumCajero CHAR (14) ;

DEFINE vsReferenciaTransaccion CHAR(23) ;
DEFINE viGenRefTipoMovimiento INTEGER ;
DEFINE viTipodeTransaccion INTEGER ;
DEFINE EnLinea CHAR (1) ;
DEFINE vsNuevaSecuencia CHAR (6) ;

DEFINE vsREGISTROCENTRAL1 CHAR (250) ;
DEFINE vsREGISTROCENTRAL2 CHAR (250) ;

DEFINE PREFIJO_SEC_EL CHAR (1) ;
DEFINE PREFIJO_SEC_FL CHAR (1) ;
DEFINE PREFIJO_SEC_CASH_BACK CHAR (1) ;
DEFINE PREFIJO_SEC_INTERBACARIO CHAR (1) ;

DEFINE TC_FORZADA CHAR (4) ;
DEFINE TS_FORZADA CHAR (4) ;
DEFINE TC_CFORZADA CHAR (4) ;
DEFINE TS_CFORZADA CHAR (4) ;
DEFINE TC_CRETIRO CHAR (4) ;
DEFINE TS_CRETIRO CHAR (4) ;
DEFINE TC_DEVOLUCION_POS CHAR (4) ;
DEFINE TS_DEVOLUCION_POS CHAR (4) ;
DEFINE TC_COMPRA CHAR (4) ;
DEFINE TS_COMPRA CHAR (4) ;
DEFINE TS_PAGO_INTERBANCARIO CHAR (4) ;
DEFINE TC_PAGO_INTERBANCARIO CHAR (4) ;

DEFINE TC_CASHADVANCE CHAR (4) ;
DEFINE TC_CCOMISIONCASHADVANCE CHAR (4) ;
DEFINE TC_CCOMISIONCASHBACK CHAR (4) ;
DEFINE TC_CASHBACK CHAR (4) ;

DEFINE TS_CASHADVANCE CHAR (4) ;
DEFINE TS_CCOMISIONCASHADVANCE CHAR (4) ;
DEFINE TS_CCOMISIONCASHBACK CHAR (4) ;
DEFINE TS_CASHBACK CHAR (4) ;

DEFINE TC_RPARCIAL CHAR (4) ;
DEFINE TS_RPARCIAL CHAR (4) ;

DEFINE TC_CCOMPRA CHAR (4) ;
DEFINE TS_CCOMPRA CHAR (4) ;

DEFINE ESTADO1 CHAR (2) ;

DEFINE viTipodeTransaccion_POS INTEGER ;

DEFINE l_sHoraLocalTransaccion CHAR (4) ;
DEFINE PREFIJO_SEC_I CHAR (1) ;

 --SET DEBUG FILE TO "/informixuc7/perifericos/sp_tipo_conciliacion_posjy.out";
 --TRACE ON;

LET PREFIJO_SEC_I  = 'i' ;
LET ESTADO1 = '' ;
LET vsMovSecuenciaCashBack = '' ;
LET vsMovSecuenciaComCashBack  = '' ;
LET vsClaveAutorizacionDeTransaccion = '' ;
LET vsSecuencia = '' ;
LET vsMovSecuenciaOrig = '' ;
LET viStatusConciliacion = 0 ;
LET vsFolioSucursal = '' ;
LET viTipoTransaccionPOS = 0 ;
LET vsTipoTran = '' ;
LET vsMovCodReversa = '' ;
LET vsSecEnviadaCentral = '' ;
LET vsReferencia = '' ;
LET vsReferenciaComision = '' ;
LET vsMovSecComision = '' ;
LET vmMontoReversa = 0 ;
LET vsDESCRIPCION1 = '' ;
LET vsDESCRIPCION2 = '' ;
LET vsDESCRIPCION3 = '' ;
LET vsTipoEnviadaCentral = '' ;
LET vsDocumento = '' ;
LET vsFolioOrig = '000000000000000' ;
LET vsDocumentoOrig = '0000000' ;
LET vsTransaccionOrig = '0000' ;
LET vsSecuenciaComision = '' ;
LET vsReferenciaTransaccion = '' ;
LET vmMontoOrig = 0 ;
LET vsNumCajero = '' ;
LET viGenRefTipoMovimiento = 0 ;
LET viTipodeTransaccion = 0 ;
LET EnLinea = '' ;
LET vsNuevaSecuencia = '' ;
LET vsREGISTROCENTRAL1 = '' ;
LET vsREGISTROCENTRAL2 = '' ;
LET PREFIJO_SEC_EL = '1' ;
LET PREFIJO_SEC_FL = '2' ;
LET PREFIJO_SEC_INTERBACARIO = '3' ;
LET PREFIJO_SEC_CASH_BACK  = '4' ;
LET TC_FORZADA = '0801' ;
LET TS_FORZADA = '0801' ;
LET TC_CFORZADA  = '0803' ;
LET TS_CFORZADA  = '0803' ;
LET TC_CRETIRO = '0802' ;
LET TS_CRETIRO = '0802' ;
LET TC_DEVOLUCION_POS = '0813' ;
LET TS_DEVOLUCION_POS = '0813' ;
LET TC_COMPRA = '0801' ;
LET TS_COMPRA = '0801' ;
LET TS_PAGO_INTERBANCARIO = '0814' ;
LET TC_PAGO_INTERBANCARIO = '0814' ;
LET TC_RPARCIAL  = '0800' ;
LET TS_RPARCIAL  = '0800' ;
LET TC_CASHADVANCE = '0806' ;
LET TC_CCOMISIONCASHADVANCE = '0816' ;
LET TC_CCOMISIONCASHBACK = '0815' ;
LET TC_CASHBACK = '0805' ;
LET TS_CASHADVANCE = '0806' ;
LET TS_CCOMISIONCASHADVANCE = '0816' ;
LET TS_CCOMISIONCASHBACK = '0815' ;
LET TS_CASHBACK = '0805' ;
LET TC_CCOMPRA = '0803' ;
LET TS_CCOMPRA = '0803' ;
LET viTipodeTransaccion_POS = 0 ;

BEGIN 
    
	-- Modificacion InterRedes 2009/11/05
	IF (psTransaccionOrigen = '0003') THEN  --TRANSACCION ORIGINADA EN TIENDAS COPPEL
		LET TC_FORZADA = '0881' ;
		LET TS_FORZADA = '0881' ;
		LET TC_COMPRA = '0881' ;
		LET TS_COMPRA = '0881' ;
		LET TC_DEVOLUCION_POS = '0883' ;
		LET TS_DEVOLUCION_POS = '0883' ;
	ELSE --TRANSACCION DE EGLABAL
		LET TC_FORZADA = '0801' ;
		LET TS_FORZADA = '0801' ;
		LET TC_COMPRA = '0801' ;
		LET TS_COMPRA = '0801' ;
		LET TC_DEVOLUCION_POS = '0813' ;
		LET TS_DEVOLUCION_POS = '0813' ;
	END IF ;

    LET l_sHoraLocalTransaccion = SUBSTRING (psHoraLocalTransaccion FROM 1 FOR 4);	
    LET vsReferenciaTransaccion = psRefTransaccion ;
    IF ( piExisteReverzaForzada > 0 ) THEN  --SI EXISTE UN MOVIMIENTO ORIGINAL. IDENTIFICA SI EL MOVIMIENTO ES UNA REVERSA O FORZADA

        LET vsClaveAutorizacionDeTransaccion = psRFSecuencia  ;

        EXECUTE PROCEDURE sp_GetTypeOfTransaction( '02', psRFFormato, vsRFCodTran, vmRFMonto, vmRFMontoCashBack ) INTO viTipodeTransaccion ;
        IF ( viTipodeTransaccion = 204 ) THEN  --REVERSA_POS
            LET vsDESCRIPCION1 = 'La transaccion Hace match con una Reversa' ;
            LET vsTipoTran = '02' ;
            LET vsMovCodReversa = '1' ;
        ELIF ( viTipodeTransaccion = 205 ) THEN  --FORZADA_POS
            LET vsDESCRIPCION1 = 'La transaccion Hace match con una Forzada' ;
            LET vsTipoTran = '01' ;
        ELIF ( viTipodeTransaccion = 212 ) THEN  --REVERSA_CASHBACK_POS
            LET vsDESCRIPCION1 = 'La transacción hace match con una Reversa Cash Back' ;
            LET vsTipoTran = '09' ;
        ELIF ( viTipodeTransaccion = 213 ) THEN  --REVERSA_REVERSA_CASHADVANCE_POS
            LET vsDESCRIPCION1 = 'La transacción hace match con una Reversa Cash Advance' ;
            LET vsTipoTran = '09' ;
        ELSE
            LET vsDESCRIPCION1 = 'El tipo de transaccion no coincide con ninguno de los establecidos' ;
        END IF ;

    ELSE -- EL MOVIMINETO ES UNA COMPRA O UNA DEVOLUCION YA QUE NO EXISTE MOVIMIENTO QUE 
                --CONCUERDE CON LA SECUENCIA ORIGINAL

        LET vsClaveAutorizacionDeTransaccion = psMovSecuencia  ;
        LET vsSecuencia = SUBSTRING ( LPAD ( TRIM ( psMovSecuencia  ), 7, '0' ) FROM 2 FOR 7 ) ;

         --ASIGNA LA CLAVE DE LA TRANSACCION SEGUN LA DESCRIPCION DE ESTA
        IF ( ( psTipoTransaccion = '01' ) AND ( psCodTran = '00' ) ) THEN  
            LET viTipodeTransaccion = 203 ; -- COMPRA_POS
        ELIF ( ( psTipoTransaccion = '01' OR psTipoTransaccion = '09' ) AND ( psCodTran <> '00' ) AND ( pmMonto > 0 ) AND ( pmMonto > pmMontoCashBack ) AND ( pmMontoCashBack > 0 ) ) THEN  
            LET viTipodeTransaccion = 210 ; -- CASHBACK_POS
        ELIF ( ( psTipoTransaccion = '01' OR psTipoTransaccion = '09' ) AND ( psCodTran <> '00' ) AND ( pmMonto > 0 ) AND ( pmMonto = pmMontoCashBack ) ) THEN  
            LET viTipodeTransaccion = 211 ; -- CASHADVANCE_POS
        ELIF ( ( psTipoTransaccion = '21' ) AND ( psCodTran = '00' ) ) THEN
            LET viTipodeTransaccion= 208 ; -- DEVOLUCION_POS
        ELSE
            LET viTipodeTransaccion= 201 ; -- RETIRO_ATM    Es una Trans. Internacional
        END IF ;

        IF ( ( psTipoTransaccion = '21' ) AND (psMovCodTran = '00' ) ) THEN
            LET vsDESCRIPCION1 = 'La transaccion es una DEVOLUCION que hace match con una Compra' ;
            LET vsTipoTran = '02' ;
        ELIF ( ( psTipoTransaccion = '01' ) AND (psMovCodTran = '00' ) ) THEN
            LET vsDESCRIPCION1 = 'La transaccion Hace match con una Compra' ;
            LET vsTipoTran = '00' ;
        ELIF ( ( psTipoTransaccion = '01' OR psTipoTransaccion = '09' ) AND (psMovCodTran = '00' )  AND ( pmMovMonto > 0 ) AND ( pmMovMonto > pmMovMontoCashBack ) AND ( pmMovMontoCashBack > 0) ) THEN
            LET vsDESCRIPCION1 = 'La transaccion Hace match con un Cash Back' ;
            LET vsTipoTran = '09' ;
        ELIF ( ( psTipoTransaccion = '01' OR psTipoTransaccion = '09' ) AND (psMovCodTran = '00' ) AND ( pmMovMonto = pmMovMontoCashBack ) ) THEN
            LET vsDESCRIPCION1 = 'La transaccion Hace match con un Cash Advance' ;
            LET vsTipoTran = '09' ;
        ELIF ( psTipoTransaccion = '02' )   THEN
            LET vsDESCRIPCION1 = 'La transaccion es ATM Internacional' ;
		ELIF ( ( psTipoTransaccion = '01' ) AND (psMovCodTran = '01' ) ) THEN --// Ajuste para transacciones internacionales codtran=01
            LET vsDESCRIPCION1 = 'La transaccion Hace match con una Compra' ;
            LET vsTipoTran = '00' ;
        ELSE
            LET vsDESCRIPCION1 = 'La transaccion no es una Compra' ;        
        END IF ;

        IF ( psMovMovConciliado = 'V' and piExisteEnMovimiento=2) THEN 
            LET EnLinea = 'D' ;
        ELSE
            LET EnLinea = '' ;
        END IF ;
            
    END IF ;

IF ( piExisteEnMovimiento > 0 ) THEN  --SI EXISTE UN MOVIMIENTO ORIGINAL. IDENTIFICA SI EL MOVIMIENTO ES UNA REVERSA O FORZADA
    IF ( piExisteReverzaForzada > 0 ) THEN  --SI EXISTE UN MOVIMIENTO ORIGINAL. IDENTIFICA SI EL MOVIMIENTO ES UNA REVERSA O FORZADA
        IF ( vsTipoTran <> '' ) THEN  

            --TIPO 1
            IF ( (psRFCodigoISO = '00' ) AND ( psRFCodigoCentral = '00000' ) AND ( psMovMovConciliado <> 'V' ) 
                AND ( pmMonto = vmRFMonto ) AND ( viTipodeTransaccion = 205 ) ) THEN  --FORZADA_POS
                LET ESTADO1 = '1' ;
                LET vsDESCRIPCION2 = 'Conciliacion Correcta Forzada' ;

                LET viGenRefTipoMovimiento = 4 ; --FORZADA

                 EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, psNombreComercio, psRFSecuencia ) INTO vsReferencia ;

                LET vsDocumento = psRFSecuencia ;
                IF psSecuenciaExtendida is null THEN
                    LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
                ELSE
                    LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
                END IF;


                LET vsSecEnviadaCentral = vsDocumento ;
               
                IF EnLinea = 'D' THEN
                    LET vsTipoEnviadaCentral = 'D' ;
                ELSE
                    LET vsTipoEnviadaCentral = 'C' ;
                END IF

                --GUARDA EL REGISTRO CORRESPONDIENTE A LA TRANSACCION ACTUAL
                EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_FORZADA, 
                vsFolioSucursal, TS_FORZADA, psNumTarjeta, vsDocumento, pmMonto, psMovMoneda,
                vsReferencia, vsFolioOrig , vsDocumentoOrig , vsTransaccionOrig , vmMontoOrig, pmMovMontoCashBack , 
                psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, psTipoTransInterEmpresa, 
                pmMontoComInterEmpresa, psConvenioInterEmpresa ) INTO vsREGISTROCENTRAL1 ;

                IF ( pmMovMontoComision > 0) THEN   

                    EXECUTE PROCEDURE sp_GetSecuencia (0) INTO vsMovSecComision  ; -- CON 0 OBTIENE LA SECUENCIA PARA EL COBRO DE LA COMISION

                    LET vsMovSecComision = LPAD ( TRIM ( vsMovSecComision ), 6, '0' ) ;
                    LET vsDocumento =  PREFIJO_SEC_FL  || vsMovSecComision ;
    		    IF psSecuenciaExtendida is null THEN
            		LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
                ELSE
                    LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
                END IF;


                    LET viGenRefTipoMovimiento = 12 ; --COMISIONFORZADA
                    --genera la referencia para el registro de la comision a cobrar por el movimiento
                    EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, psNumTarjeta, '' ) INTO vsReferenciaComision  ;

                    IF EnLinea = 'D' THEN
                        LET vsTipoEnviadaCentral = 'D' ;
                    END IF
                        
                    -- CUARDA EL REGISTRO CORRESPONDIENTE AL COBRO DE LA COMISION DE LA TRANSACCION ACTUAL
                    EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_FORZADA, 
                    vsFolioSucursal, TS_FORZADA, psNumTarjeta, vsDocumento, pmMovMontoComision, psMovMoneda, 
                    vsReferenciaComision , vsFolioOrig , vsDocumentoOrig, vsTransaccionOrig , vmMontoOrig, pmMovMontoCashBack , 
                    psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, '', 
                    0.0, ''  ) INTO vsREGISTROCENTRAL2 ;

                    LET vsSecuenciaComision = PREFIJO_SEC_FL || vsMovSecComision ; 

                END IF ;

                LET viStatusConciliacion  = 2 ; 

             -- TIPO 2
            ELIF ( (psRFCodigoISO = '00' ) AND ( psRFCodigoCentral = '00000' ) AND ( psMovMovConciliado <> 'V' ) 
            AND ( pmMonto <> vmRFMonto ) AND ( viTipodeTransaccion = 205 ) ) THEN  --FORZADA_POS

                LET ESTADO1 = '2' ;
                LET vsDESCRIPCION2 = 'Diferencia en Montos Forzada o Reverso' ;

                LET viGenRefTipoMovimiento = 4 ; --FORZADA

                 EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, psNombreComercio, psRFSecuencia ) INTO vsReferencia ;

                LET vsDocumento = psRFSecuencia ;
        		IF psSecuenciaExtendida is null THEN
                	LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
                ELSE
                    LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
                END IF;


                LET vsSecEnviadaCentral = vsDocumento ;
                
                IF EnLinea = 'D' THEN
                    LET vsTipoEnviadaCentral = 'D' ;
                ELSE
                    LET vsTipoEnviadaCentral = 'C' ;
                END IF

                --GUARDA EL REGISTRO CORRESPONDIENTE A LA TRANSACCION ACTUAL
                EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_FORZADA, 
                    vsFolioSucursal, TS_FORZADA, psNumTarjeta, vsDocumento, pmMonto, psMovMoneda,
                    vsReferencia, vsFolioOrig , vsDocumentoOrig , vsTransaccionOrig , vmMontoOrig, pmMovMontoCashBack , 
                    psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, psTipoTransInterEmpresa, 
                    pmMontoComInterEmpresa, psConvenioInterEmpresa ) INTO vsREGISTROCENTRAL1 ;

                IF ( pmMovMontoComision > 0) THEN   

                    EXECUTE PROCEDURE sp_GetSecuencia (0) INTO vsMovSecComision  ; -- CON 0 OBTIENE LA SECUENCIA PARA EL COBRO DE LA COMISION

                    LET vsMovSecComision = LPAD ( TRIM ( vsMovSecComision ), 6, '0' ) ;
                    LET vsDocumento =  PREFIJO_SEC_FL  || vsMovSecComision ;
        		    IF psSecuenciaExtendida is null THEN
                    	LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
        		    ELSE
                    	LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
        		    END IF;


                    LET viGenRefTipoMovimiento = 12 ; --COMISIONFORZADA
                    --genera la referencia para el registro de la comision a cobrar por el movimiento
                    EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, psNumTarjeta, '' ) INTO vsReferenciaComision  ;

                    IF EnLinea = 'D' THEN
                        LET vsTipoEnviadaCentral = 'D' ;
                    END IF
                        
                    -- CUARDA EL REGISTRO CORRESPONDIENTE AL COBRO DE LA COMISION DE LA TRANSACCION ACTUAL
                    EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_FORZADA, 
                    vsFolioSucursal, TS_FORZADA, psNumTarjeta, vsDocumento, pmMovMontoComision, psMovMoneda, 
                    vsReferenciaComision , vsFolioOrig , vsDocumentoOrig, vsTransaccionOrig , vmMontoOrig, pmMovMontoCashBack , 
                    psRFC , vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, '', 
                    0.0, '' ) INTO vsREGISTROCENTRAL2 ;

                    LET vsSecuenciaComision = PREFIJO_SEC_FL || vsMovSecComision ; 

                END IF ;

                LET viStatusConciliacion  = 4 ; 

             -- TIPO 3
            ELIF ( ( (psRFCodigoISO <> '00' ) OR ( psRFCodigoCentral <> '00000' ) OR ( psMovMovConciliado = 'V' ) ) 
            AND ( viTipodeTransaccion = 205 ) AND (psMovMovConciliado <> 'V') ) THEN  --FORZADA_POS

                LET ESTADO1 = '3' ;
                LET vsDESCRIPCION2 = 'Prosa tiene la transaccion Autorizada Reverso o Forzada, el Autorizador Negada !!!' ;

                LET viGenRefTipoMovimiento = 4 ; --FORZADA

                 EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, psNombreComercio, psRFSecuencia ) INTO vsReferencia ;

                LET vsDocumento = psRFSecuencia ;
        		IF psSecuenciaExtendida is null THEN
                	LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
        		ELSE
                	LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
        		END IF;


                LET vsSecEnviadaCentral = vsDocumento ;
                
                IF EnLinea = 'D' THEN
                    LET vsTipoEnviadaCentral = 'D' ;
                ELSE
                    LET vsTipoEnviadaCentral = 'C' ;
                END IF

                --GUARDA EL REGISTRO CORRESPONDIENTE A LA TRANSACCION ACTUAL
                EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_FORZADA, 
                    vsFolioSucursal, TS_FORZADA, psNumTarjeta, vsDocumento, pmMonto, psMovMoneda,
                    vsReferencia, vsFolioOrig , vsDocumentoOrig , vsTransaccionOrig , vmMontoOrig, pmMovMontoCashBack , 
                    psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, psTipoTransInterEmpresa, 
                    pmMontoComInterEmpresa, psConvenioInterEmpresa ) INTO vsREGISTROCENTRAL1 ;

                IF ( pmMovMontoComision > 0) THEN   

                    EXECUTE PROCEDURE sp_GetSecuencia (0) INTO vsMovSecComision  ; -- CON 0 OBTIENE LA SECUENCIA PARA EL COBRO DE LA COMISION

                    LET vsMovSecComision = LPAD ( TRIM ( vsMovSecComision ), 6, '0' ) ;
                    LET vsDocumento =  PREFIJO_SEC_FL  || vsMovSecComision ;
                    IF psSecuenciaExtendida is null THEN
                         LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
                    ELSE
                         LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
                     END IF;


                    LET viGenRefTipoMovimiento = 12 ; --COMISIONFORZADA
                    --genera la referencia para el registro de la comision a cobrar por el movimiento
                    EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, psNumTarjeta, '' ) INTO vsReferenciaComision  ;

                    IF EnLinea = 'D' THEN
                        LET vsTipoEnviadaCentral = 'D' ;
                    END IF 

                    -- CUARDA EL REGISTRO CORRESPONDIENTE AL COBRO DE LA COMISION DE LA TRANSACCION ACTUAL
                    EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_FORZADA, 
                    vsFolioSucursal, TS_FORZADA, psNumTarjeta, vsDocumento, pmMovMontoComision, psMovMoneda, 
                    vsReferenciaComision , vsFolioOrig , vsDocumentoOrig, vsTransaccionOrig , vmMontoOrig, pmMovMontoCashBack , 
                    psRFC , vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, '', 
                    0.0, '' ) INTO vsREGISTROCENTRAL2 ;

                    LET vsSecuenciaComision = PREFIJO_SEC_FL || vsMovSecComision ; 

                END IF ;

                IF ( pmMonto = vmRFMonto ) THEN     
                    LET viStatusConciliacion  = 2 ; 
                ELSE
                    LET viStatusConciliacion  = 4 ; 
                END IF ;

            -- TIPO 4
            ELIF ( ( (psRFCodigoISO<> '00' ) OR ( psRFCodigoCentral <> '00000' ) OR ( psMovMovConciliado = 'V' ) ) 
            AND  ( ( viTipodeTransaccion <> 205 ) OR (psMovMovConciliado = 'V') ) AND ( psMovMovConciliado = 'V')  ) THEN  --FORZADA_POS
                LET ESTADO1 = '4' ;
                --Ya fueron procesadas anteriormente
                LET viStatusConciliacion  = 9 ; 

            END IF ;

        END IF ;

    ELSE    --ES UNA COMPRA O UNA DEVOLUCION.

        -- TIPO 5
        IF ( ( ( psCodigoCentral = '00000' ) AND ( psCodigoISO = '00' ) AND ( ( psMovMovConciliado <> 'V' ) OR ( psTipoTransaccion = '21' ) ) ) 
        AND ( pmMovMonto = pmMonto )  AND ( psTipoTransaccion = '21'  ) ) THEN 

            LET ESTADO1 = '5' ;

            LET vsDESCRIPCION2 = 'Conciliacion Correcta en Devolucion' ;

            EXECUTE PROCEDURE sp_GetSecuencia (0) INTO vsNuevaSecuencia ;            

            LET viGenRefTipoMovimiento = 3 ; --DEVOLUCION
            EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, vsNuevaSecuencia, '' ) INTO vsReferencia ;

            LET vsNuevaSecuencia =  LPAD ( TRIM ( vsNuevaSecuencia ), 6, '0' ) ;

            LET vsDocumento = PREFIJO_SEC_FL || vsNuevaSecuencia ;
            IF psSecuenciaExtendida is null THEN
                 LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
            ELSE
                 LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
            END IF;


            LET vsSecEnviadaCentral = vsDocumento ;
            
            IF EnLinea = 'D' THEN
                LET vsTipoEnviadaCentral = 'D' ;
            ELSE
                LET vsTipoEnviadaCentral = 'A' ;
            END IF 

            --GUARDA EL REGISTRO CORRESPONDIENTE A LA TRANSACCION ACTUAL
            EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_DEVOLUCION_POS, 
            vsFolioSucursal, TS_DEVOLUCION_POS, psNumTarjeta, vsDocumento, pmMonto, psMovMoneda,
            vsReferencia, vsFolioOrig , vsDocumentoOrig , vsTransaccionOrig , vmMontoOrig, pmMovMontoCashBack , 
            psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, psTipoTransInterEmpresa, 
            pmMontoComInterEmpresa, psConvenioInterEmpresa ) INTO vsREGISTROCENTRAL1 ;
            
            LET vsDESCRIPCION3 = 'La devolucion con secuencia: ' || PREFIJO_SEC_FL || vsNuevaSecuencia || ' y monto de: ' || pmMovMonto 
            || ' se le encontro su movimiento original con secuencia: ' || PREFIJO_SEC_EL || psSecuenciaAuth || ' con monto de: ' || pmMonto ;

            LET viStatusConciliacion  = 2 ; 
            
        -- TIPO 6
        ELIF ( ( ( psCodigoCentral = '00000' ) AND ( psCodigoISO = '00' ) AND ( ( psMovMovConciliado <> 'V' ) OR ( psTipoTransaccion = '21' ) ) ) 
        AND ( pmMovMonto = pmMonto )  AND ( psTipoTransaccion = '01'  ) AND ( psMovCodTran = '00' OR psMovCodTran = '01' ) )  THEN 

            LET ESTADO1 = '6' ;

            LET vsSecuencia = LPAD ( TRIM ( psSecuenciaAuth ), 6, '0' ) ;

            LET viGenRefTipoMovimiento = 2 ; --COMPRA
            EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, psNombreComercio, vsSecuencia ) INTO vsReferencia ;

            LET vsDocumento = PREFIJO_SEC_EL || vsSecuencia ;
            IF psSecuenciaExtendida is null THEN
                 LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
            ELSE
                 LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
            END IF;


            LET vsSecEnviadaCentral = vsDocumento ;
            
            IF EnLinea = 'D' THEN
                LET vsTipoEnviadaCentral = 'D' ;
            ELSE
                LET vsTipoEnviadaCentral = 'C' ;
            END IF

            --GUARDA EL REGISTRO CORRESPONDIENTE A LA TRANSACCION ACTUAL
            EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_COMPRA, 
            vsFolioSucursal, TS_COMPRA, psNumTarjeta, vsDocumento, pmMonto, psMovMoneda,
            vsReferencia, vsFolioOrig , vsDocumentoOrig , vsTransaccionOrig , vmMontoOrig, pmMovMontoCashBack , 
            psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, psTipoTransInterEmpresa, 
            pmMontoComInterEmpresa, psConvenioInterEmpresa ) INTO vsREGISTROCENTRAL1 ;

            IF ( pmMovMontoComision > 0) THEN

                EXECUTE PROCEDURE sp_GetSecuencia (0) INTO vsMovSecComision  ; -- CON 0 OBTIENE LA SECUENCIA PARA EL COBRO DE LA COMISION

                LET vsDocumento =  PREFIJO_SEC_FL || LPAD ( TRIM ( vsMovSecComision ), 6, '0' ) ; 
                IF psSecuenciaExtendida is null THEN
                         LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
                ELSE
                     LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
                END IF;


                LET viGenRefTipoMovimiento = 10 ;                --genera la referencia para el registro de la comision a cobrar por el movimiento
                EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, psNumTarjeta, '' ) INTO vsReferenciaComision  ;
                
                
                IF EnLinea = 'D' THEN
                    LET vsTipoEnviadaCentral = 'D' ;
                END IF

                -- CUARDA EL REGISTRO CORRESPONDIENTE AL COBRO DE LA COMISION DE LA TRANSACCION ACTUAL
                EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_CCOMPRA, 
                vsFolioSucursal, TS_CCOMPRA, psNumTarjeta, vsDocumento, pmMovMontoComision, psMovMoneda, 
                vsReferenciaComision , vsFolioOrig , vsDocumentoOrig, vsTransaccionOrig , vmMontoOrig, pmMovMontoCashBack , 
                psRFC , vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, '', 
                0.0, ''  ) INTO vsREGISTROCENTRAL2 ;

                LET vsSecuenciaComision = PREFIJO_SEC_FL || LPAD ( TRIM ( vsMovSecComision ), 6, '0' ) ; 

            END IF ;
            
            LET viStatusConciliacion  = 2 ; 

        -- TIPO 7
        ELIF ( ( ( psCodigoCentral = '00000' ) AND ( psCodigoISO = '00' ) AND ( ( psMovMovConciliado <> 'V' ) OR ( psTipoTransaccion = '21' ) ) ) 
        AND ( pmMovMonto = pmMonto )  AND ( psTipoTransaccion = '01'  OR psTipoTransaccion = '09' ) AND ( psMovCodTran = '09' ) AND ( pmMovMonto > 0 ) AND 
        ( pmMovMonto > pmMovMontoCashBack ) )  THEN 

            LET ESTADO1 = '7' ;
            LET viTipodeTransaccion = 203 ; -- COMPRA_POS

            LET vsSecuencia = LPAD ( TRIM ( psSecuenciaAuth ), 6, '0' ) ;

            LET viGenRefTipoMovimiento = 2 ; --COMPRA
            EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, psNombreComercio, vsSecuencia ) INTO vsReferencia ;

            LET vsDocumento = PREFIJO_SEC_EL || vsSecuencia ;
            IF psSecuenciaExtendida is null THEN
                LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
            ELSE
                LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
            END IF;

            LET vsSecEnviadaCentral = vsDocumento ;
            
            IF EnLinea = 'D' THEN
                LET vsTipoEnviadaCentral = 'D' ;
            ELSE    
                LET vsTipoEnviadaCentral = 'C' ;
            END IF

            --GUARDA EL REGISTRO CORRESPONDIENTE A LA TRANSACCION ACTUAL
            EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_COMPRA, 
            vsFolioSucursal, TS_COMPRA, psNumTarjeta, vsDocumento, pmMonto, psMovMoneda,
            vsReferencia, vsFolioOrig , vsDocumentoOrig , vsTransaccionOrig , vmMontoOrig, pmMovMontoCashBack , 
            psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, psTipoTransInterEmpresa, 
            pmMontoComInterEmpresa, psConvenioInterEmpresa ) INTO vsREGISTROCENTRAL1 ;

            LET viTipodeTransaccion = 210 ; -- CASHBACK_POS

            LET viGenRefTipoMovimiento = 20 ; --CASHBACK
            EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, 'CASH BACK', vsSecuencia ) INTO vsReferencia ;

            LET vsDocumento = PREFIJO_SEC_CASH_BACK || psMovSecuenciaCashBack ;
            IF psSecuenciaExtendida is null THEN
                 LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
            ELSE
                 LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
            END IF;


            LET vsMovSecuenciaCashBack = vsDocumento ;
            LET vsTipoEnviadaCentral = 'C' ;



            LET psArchivoOrigen  = psArchivoOrigen;
            LET vsTipoEnviadaCentral = vsTipoEnviadaCentral ;
            LET vsFolioSucursal = vsFolioSucursal ;
            LET psNumTarjeta  = psNumTarjeta ;
            LET vsDocumento = vsDocumento ;
            LET pmMovMontoCashBack = pmMovMontoCashBack ;
            LET psMovMoneda = psMovMoneda ;
            LET vsReferencia = vsReferencia ;
            LET vsFolioOrig  = vsFolioOrig ;
            LET vsDocumentoOrig  = vsDocumentoOrig ;
            LET vsTransaccionOrig  = vsTransaccionOrig ;
            LET vmMontoOrig = vmMontoOrig ;
            LET pmMovMontoCashBack  = pmMovMontoCashBack ;
            LET psRFC = psRFC ;
            LET vsReferenciaTransaccion = vsReferenciaTransaccion ;
            LET psDivisa = psDivisa ;
            LET pmMontoDivisa = pmMontoDivisa ;
            LET psFormadePago = psFormadePago ;
            LET vsNumCajero = vsNumCajero ;

            
            IF EnLinea = 'D' THEN
                LET vsTipoEnviadaCentral = 'D' ;
            END IF
            
            --GUARDA EL REGISTRO CORRESPONDIENTE A LA TRANSACCION ACTUAL
            EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_CASHBACK, 
            vsFolioSucursal, TS_CASHBACK, psNumTarjeta, vsDocumento, pmMovMontoCashBack, psMovMoneda,
            vsReferencia, vsFolioOrig , vsDocumentoOrig , vsTransaccionOrig , vmMontoOrig, pmMovMontoCashBack , 
            psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, '', 
            0.0, ''  ) INTO vsREGISTROCENTRAL2 ;

            LET viStatusConciliacion  = 2 ; 

        -- TIPO 8
        ELIF ( ( ( psCodigoCentral = '00000' ) AND ( psCodigoISO = '00' ) AND ( ( psMovMovConciliado <> 'V' ) OR ( psTipoTransaccion = '21' ) ) ) 
        AND ( pmMovMonto = pmMonto )  AND ( psTipoTransaccion = '01'  OR psTipoTransaccion = '09' ) AND ( psMovCodTran = '09' ) AND ( pmMovMonto > 0 ) AND 
        ( pmMovMonto <= pmMovMontoCashBack ) )  THEN 

            LET ESTADO1 = '8' ;

            LET vsSecuencia = PREFIJO_SEC_FL || LPAD ( TRIM ( psSecuenciaAuth ), 6, '0' ) ;  --HECTOR 04/04/2008

            LET viGenRefTipoMovimiento = 21 ; --CASHADVANCE
            EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, 'CASH ADVANCE', vsSecuencia ) INTO vsReferencia ;

            LET vsDocumento = PREFIJO_SEC_CASH_BACK  || LPAD ( TRIM ( psMovSecuenciaCashBack ), 6, '0' ) ;
            IF psSecuenciaExtendida is null THEN
                 LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
            ELSE
                 LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
            END IF;


            LET vsSecEnviadaCentral = vsDocumento ;
            LET vsMovSecuenciaCashBack = vsDocumento ;
            
            IF EnLinea = 'D' THEN
                LET vsTipoEnviadaCentral = 'D' ;
            ELSE
                LET vsTipoEnviadaCentral = 'C' ;
            END IF

            --GUARDA EL REGISTRO CORRESPONDIENTE A LA TRANSACCION ACTUAL
            EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_CASHADVANCE, 
            vsFolioSucursal, TS_CASHADVANCE, psNumTarjeta, vsDocumento, pmMovMontoCashBack, psMovMoneda,
            vsReferencia, vsFolioOrig , vsDocumentoOrig , vsTransaccionOrig , vmMontoOrig, pmMovMontoCashBack , 
            psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, psTipoTransInterEmpresa, 
            pmMontoComInterEmpresa, psConvenioInterEmpresa ) INTO vsREGISTROCENTRAL1 ;
            
            IF ( pmMovMontoComision > 0 ) THEN 

                LET vsDocumento = PREFIJO_SEC_CASH_BACK || LPAD ( TRIM ( psMovSecuenciaComCashBack ), 6, '0' ) ;
                IF psSecuenciaExtendida is null THEN
                     LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
                ELSE
                     LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
                END IF;


                LET viGenRefTipoMovimiento = 21 ;                --genera la referencia para el registro de la comision a cobrar por el movimiento
                EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, 'COMISION CASH ADVANCE', vsSecuencia ) INTO vsReferenciaComision ;
                
                IF EnLinea = 'D' THEN
                    LET vsTipoEnviadaCentral = 'D' ;
                END IF

                -- CUARDA EL REGISTRO CORRESPONDIENTE AL COBRO DE LA COMISION DE LA TRANSACCION ACTUAL
                EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_CCOMISIONCASHADVANCE, 
                vsFolioSucursal, TS_CCOMISIONCASHADVANCE, psNumTarjeta, vsDocumento, pmMovMontoComision /*pmMovMontoComCashBack*/, psMovMoneda, 
                vsReferenciaComision , vsFolioOrig , vsDocumentoOrig, vsTransaccionOrig , vmMontoOrig, pmMovMontoCashBack , 
                psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, '', 
                0.0, '' ) INTO vsREGISTROCENTRAL2 ;

                LET vsMovSecuenciaComCashBack =  LPAD ( TRIM ( psMovSecuenciaComCashBack ), 6, '0' ) ; 

            END IF ;

            LET viStatusConciliacion  = 2 ; 

        ELIF ( ( ( psCodigoCentral = '00000' ) AND ( psCodigoISO = '00' ) AND ( ( psMovMovConciliado <> 'V' ) OR ( psTipoTransaccion = '21' ) ) ) 
        AND ( pmMovMonto = pmMonto )  AND ( ( psTipoTransaccion <> '21'  ) AND ( psTipoTransaccion <> '01'  ) ) ) THEN 
            --TIPO 9
            IF ( psTipoTransaccion = '02'  ) THEN 
                LET ESTADO1 = '9' ;

                LET vsDESCRIPCION2 = 'Aviso. Los Retiros ATM Internacionales son descartados' ;
                LET vsDESCRIPCION3 = '       en el archivo 325 y procesados en el Stat07.' ;

                --LET ESTADO2 = '9' ;
            ELSE --TIPO 10
                LET ESTADO1 = '10' ;

                LET vsDESCRIPCION2 = 'No se puede definir la Transaccion.' ;
                LET viStatusConciliacion  = 7 ; 

            END IF ;

        -- TIPO 11
        ELIF ( ( ( psCodigoCentral = '00000' ) AND ( psCodigoISO = '00' ) AND ( ( psMovMovConciliado <> 'V' ) OR ( psTipoTransaccion = '21' ) ) ) 
        AND ( pmMovMonto <> pmMonto )  AND ( psTipoTransaccion = '21'  ) AND (pmMovMonto >pmMonto) ) THEN 

            LET ESTADO1 = '11' ;

            EXECUTE PROCEDURE sp_GetSecuencia (0) INTO vsNuevaSecuencia ; -- CON 0 OBTIENE LA SECUENCIA PARA EL COBRO DE LA COMISION

            LET viGenRefTipoMovimiento = 3 ;            --genera la referencia para el registro de la comision a cobrar por el movimiento
            EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, vsNuevaSecuencia, '' ) INTO vsReferencia ;

            LET vsDocumento = PREFIJO_SEC_FL || LPAD ( TRIM ( vsNuevaSecuencia ), 6, '0' ) ;
            IF psSecuenciaExtendida is null THEN
                 LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
            ELSE
                 LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
            END IF;


            LET vsSecEnviadaCentral = vsDocumento ;
            
            IF EnLinea = 'D' THEN
                LET vsTipoEnviadaCentral = 'D' ;
            ELSE
                LET vsTipoEnviadaCentral = 'A' ;
            END IF

            --GUARDA EL REGISTRO CORRESPONDIENTE A LA TRANSACCION ACTUAL
            EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_DEVOLUCION_POS, 
            vsFolioSucursal, TS_DEVOLUCION_POS, psNumTarjeta, vsDocumento, pmMonto, psMovMoneda,
            vsReferencia, vsFolioOrig, vsDocumentoOrig, vsTransaccionOrig, vmMontoOrig, pmMovMontoCashBack , 
            psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, psTipoTransInterEmpresa, 
            pmMontoComInterEmpresa, psConvenioInterEmpresa ) INTO vsREGISTROCENTRAL1 ;

                LET vsDESCRIPCION2 = 'La devolucion con secuencia: ' || PREFIJO_SEC_FL || vsNuevaSecuencia || ' y monto de: ' || pmMovMonto 
                || ' se le encontro su movimiento original con secuencia: ' || PREFIJO_SEC_EL || psSecuenciaAuth || ' con monto de: ' || pmMonto ;

            LET viStatusConciliacion  = 4 ; 

        -- TIPO 12
        ELIF ( ( ( psCodigoCentral = '00000' ) AND ( psCodigoISO = '00' ) AND ( ( psMovMovConciliado <> 'V' ) OR ( psTipoTransaccion = '21' ) ) ) 
        AND ( pmMovMonto <> pmMonto )  AND ( psTipoTransaccion = '21'  ) AND (pmMovMonto <= pmMonto) ) THEN 
        
        LET ESTADO1 = '12' ;
        LET viStatusConciliacion  = 7 ; 

        -- TIPO 13
       ELIF ( ( ( psCodigoCentral = '00000' ) AND ( psCodigoISO = '00' ) AND ( ( psMovMovConciliado <> 'V' ) OR ( psTipoTransaccion = '21' ) ) ) 
        AND ( pmMovMonto <> pmMonto )  AND ( psTipoTransaccion = '01'  )  AND ( psMovCodTran = '00' OR psMovCodTran = '01' ) ) THEN 

            LET ESTADO1 = '13' ;

            LET viGenRefTipoMovimiento = 2 ;            --genera la referencia para el registro de la comision a cobrar por el movimiento
            EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, psNombreComercio, psSecuenciaAuth ) INTO vsReferencia ;

            LET vsDocumento = PREFIJO_SEC_EL || LPAD ( TRIM ( psSecuenciaAuth ), 6, '0' ) ;
            IF psSecuenciaExtendida is null THEN
                 LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
            ELSE
                 LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
            END IF;


            LET vsSecEnviadaCentral = vsDocumento ;
            
            IF EnLinea = 'D' THEN
                LET vsTipoEnviadaCentral = 'D' ;
            ELSE
                LET vsTipoEnviadaCentral = 'C' ;
            END IF

            --GUARDA EL REGISTRO CORRESPONDIENTE A LA TRANSACCION ACTUAL
            EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_COMPRA,
            vsFolioSucursal, TS_COMPRA, psNumTarjeta, vsDocumento, pmMonto, psMovMoneda,
            vsReferencia, vsFolioOrig, vsDocumentoOrig, vsTransaccionOrig, vmMontoOrig, pmMovMontoCashBack , 
            psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, psTipoTransInterEmpresa, 
            pmMontoComInterEmpresa, psConvenioInterEmpresa ) INTO vsREGISTROCENTRAL1 ;

            IF ( pmMovMontoComision  > 0) THEN

                 EXECUTE PROCEDURE sp_GetSecuencia (0) INTO vsMovSecComision  ; -- CON 0 OBTIENE LA SECUENCIA PARA EL COBRO DE LA COMISION

                LET vsDocumento =  PREFIJO_SEC_FL || LPAD ( TRIM ( vsMovSecComision ), 6, '0' ) ; 
                IF psSecuenciaExtendida is null THEN
                     LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
                ELSE
                     LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
                END IF;


                LET viGenRefTipoMovimiento = 10 ;                --genera la referencia para el registro de la comision a cobrar por el movimiento
                EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, psNumTarjeta, '' ) INTO vsReferenciaComision  ;
                
                IF EnLinea = 'D' THEN
                    LET vsTipoEnviadaCentral = 'D' ;
                END IF
                    
                -- CUARDA EL REGISTRO CORRESPONDIENTE AL COBRO DE LA COMISION DE LA TRANSACCION ACTUAL
                EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_CCOMPRA, 
                vsFolioSucursal, TS_CCOMPRA, psNumTarjeta, vsDocumento, pmMovMontoComision, psMovMoneda, 
                vsReferenciaComision , vsFolioOrig , vsDocumentoOrig, vsTransaccionOrig , vmMontoOrig, pmMovMontoCashBack , 
                psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, '', 
                0.0, '' ) INTO vsREGISTROCENTRAL2 ;

                LET vsSecuenciaComision = PREFIJO_SEC_FL || LPAD ( TRIM ( vsMovSecComision ), 6, '0' ) ; 

            END IF ;

            LET viStatusConciliacion  = 4 ; 

        -- TIPO 14
        ELIF ( ( ( psCodigoCentral = '00000' ) AND ( psCodigoISO = '00' ) AND ( ( psMovMovConciliado <> 'V' ) OR ( psTipoTransaccion = '21' ) ) ) 
        AND ( pmMovMonto <> pmMonto )  AND ( psTipoTransaccion = '01' OR psTipoTransaccion = '09' )  AND ( psMovCodTran = '09' ) AND ( pmMovMonto > 0 ) 
        AND ( pmMovMonto > pmMovMontoCashBack )  ) THEN 

            LET ESTADO1 = '14' ;

            LET viGenRefTipoMovimiento = 2 ;            --genera la referencia para el registro de la comision a cobrar por el movimiento
            EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, psNombreComercio, psSecuenciaAuth ) INTO vsReferencia ;

            LET vsDocumento = PREFIJO_SEC_EL || LPAD ( TRIM ( psSecuenciaAuth ), 6, '0' ) ;
            IF psSecuenciaExtendida is null THEN
                 LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
            ELSE
                 LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
            END IF;


            LET vsSecEnviadaCentral = vsDocumento ;
            
            IF EnLinea = 'D' THEN
                LET vsTipoEnviadaCentral = 'D' ;
            ELSE
                LET vsTipoEnviadaCentral = 'C' ;
            END IF

            --GUARDA EL REGISTRO CORRESPONDIENTE A LA TRANSACCION ACTUAL
            EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_COMPRA,
            vsFolioSucursal, TS_COMPRA, psNumTarjeta, vsDocumento, ( pmMonto - pmMontoCashBack ), psMovMoneda,
            vsReferencia, vsFolioOrig, vsDocumentoOrig, vsTransaccionOrig, vmMontoOrig, pmMovMontoCashBack , 
            psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, psTipoTransInterEmpresa, 
            pmMontoComInterEmpresa, psConvenioInterEmpresa ) INTO vsREGISTROCENTRAL1 ;

            LET viGenRefTipoMovimiento = 210 ;            --genera la referencia para el registro de la comision a cobrar por el movimiento
            EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, 'CASH BACK', psSecuenciaAuth ) INTO vsReferencia ;

            LET vsDocumento = PREFIJO_SEC_CASH_BACK || LPAD ( TRIM ( psMovSecuenciaCashBack ), 6, '0' ) ;
            IF psSecuenciaExtendida is null THEN
                 LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
            ELSE
                 LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
            END IF;


            LET vsMovSecuenciaCashBack = vsDocumento ;
            
            IF EnLinea = 'D' THEN
                LET vsTipoEnviadaCentral = 'D' ;
            ELSE
                LET vsTipoEnviadaCentral = 'C' ;
            END IF

            --GUARDA EL REGISTRO CORRESPONDIENTE A LA TRANSACCION ACTUAL
            EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_CASHBACK,
            vsFolioSucursal, TS_CASHBACK, psNumTarjeta, vsDocumento, pmMontoCashBack, psMovMoneda,
            vsReferencia, vsFolioOrig, vsDocumentoOrig, vsTransaccionOrig, vmMontoOrig, pmMovMontoCashBack , 
            psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, '', 
            0.0, ''  ) INTO vsREGISTROCENTRAL2 ;

            LET viStatusConciliacion  = 4 ; 

        -- TIPO 15
        ELIF ( ( ( psCodigoCentral = '00000' ) AND ( psCodigoISO = '00' ) AND ( ( psMovMovConciliado <> 'V' ) OR ( psTipoTransaccion = '21' ) ) ) 
        AND ( pmMovMonto <> pmMonto )  AND ( psTipoTransaccion = '01' OR psTipoTransaccion = '09' )  AND ( psMovCodTran = '09' ) AND ( pmMovMonto > 0 ) 
        AND ( pmMovMonto = pmMovMontoCashBack )  ) THEN 

            LET ESTADO1 = '15' ;

            LET viGenRefTipoMovimiento = 21 ;            --genera la referencia para el registro de la comision a cobrar por el movimiento
            EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, 'CASH ADVANCE', psSecuenciaAuth ) INTO vsReferencia ;

            LET vsDocumento = PREFIJO_SEC_CASH_BACK || LPAD ( TRIM ( psMovSecuenciaCashBack ), 6, '0' ) ;
            IF psSecuenciaExtendida is null THEN
                 LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
            ELSE
                 LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
            END IF;


            LET vsSecEnviadaCentral = vsDocumento ;
            LET vsMovSecuenciaCashBack = vsDocumento ;
            
            IF EnLinea = 'D' THEN
                LET vsTipoEnviadaCentral = 'D' ;
            ELSE
                LET vsTipoEnviadaCentral = 'C' ;
            END IF

            --GUARDA EL REGISTRO CORRESPONDIENTE A LA TRANSACCION ACTUAL
            EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_CASHADVANCE,
            vsFolioSucursal, TS_CASHADVANCE, psNumTarjeta, vsDocumento, pmMontoCashBack, psMovMoneda,
            vsReferencia, vsFolioOrig, vsDocumentoOrig, vsTransaccionOrig, vmMontoOrig, pmMovMontoCashBack , 
            psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago , vsNumCajero, psTipoTransInterEmpresa, 
            pmMontoComInterEmpresa, psConvenioInterEmpresa ) INTO vsREGISTROCENTRAL1 ;

            IF ( pmMontoCashBack > 0) THEN

                LET vsDocumento =  PREFIJO_SEC_CASH_BACK || LPAD ( TRIM ( psMovSecuenciaComCashBack ), 6, '0' ) ;
                IF psSecuenciaExtendida is null THEN
                     LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
                ELSE
                     LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
                END IF;

                LET vsTipoEnviadaCentral = 'C' ;
                LET vsMovSecuenciaComCashBack = LPAD ( TRIM ( psMovSecuenciaComCashBack ), 6, '0' ) ;
                LET viGenRefTipoMovimiento = 21 ;
                --genera la referencia para el registro de la comision a cobrar por el movimiento
                EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, 'COMISION CASH ADVANCE', vsSecuencia ) INTO vsReferenciaComision ;
                
                IF EnLinea = 'D' THEN
                    LET vsTipoEnviadaCentral = 'D' ;
                END IF

                -- CUARDA EL REGISTRO CORRESPONDIENTE AL COBRO DE LA COMISION DE LA TRANSACCION ACTUAL
                EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_CCOMISIONCASHADVANCE, 
                vsFolioSucursal, TS_CCOMISIONCASHADVANCE, psNumTarjeta, vsDocumento, pmMovMontoComision /*pmMovMontoComCashBack*/, psMovMoneda, 
                vsReferenciaComision , vsFolioOrig , vsDocumentoOrig, vsTransaccionOrig , vmMontoOrig, pmMovMontoCashBack , 
                psRFC , vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, '', 
                0.0, '' ) INTO vsREGISTROCENTRAL2 ;

            END IF ;

            LET viStatusConciliacion  = 4 ; 

        -- TIPO 16
       ELIF ( ( ( psCodigoCentral = '00000' ) AND ( psCodigoISO = '00' ) AND ( ( psMovMovConciliado <> 'V' ) OR ( psTipoTransaccion = '21' ) ) ) 
        AND ( pmMovMonto <> pmMonto )  AND ( psTipoTransaccion = '02'  )  ) THEN 

            LET ESTADO1 = '16' ;

            LET vsDESCRIPCION2 = 'Aviso. Los Retiros ATM Internacionales son descartados' ;
            LET vsDESCRIPCION3 = '       en el archivo 325 y procesados en el Stat07.' ;

        -- TIPO 17
        ELIF ( ( ( psCodigoCentral = '00000' ) AND ( psCodigoISO = '00' ) AND ( ( psMovMovConciliado <> 'V' ) OR ( psTipoTransaccion = '21' ) ) ) 
        AND ( pmMovMonto <> pmMonto )  AND ( psTipoTransaccion = '02'  )  ) THEN 

            LET ESTADO1 = '17' ;

            LET vsDESCRIPCION2 = 'No se puede definir la Transaccion.' ;
            LET viStatusConciliacion  = 7 ; 

        -- TIPO 18
        ELIF ( ( ( psCodigoCentral <> '00000' ) OR ( psCodigoISO <> '00' ) OR  ( psMovMovConciliado = 'V' ) ) AND ( psTipoTransaccion = '21' ) ) THEN 

            LET ESTADO1 = '18' ;

            LET viStatusConciliacion  = 7 ; 

        -- TIPO 19
        ELIF ( ( ( psCodigoCentral <> '00000' ) OR ( psCodigoISO <> '00' ) OR  ( psMovMovConciliado = 'V' ) ) AND ( psTipoTransaccion <> '21' ) 
        AND ( psMovMovConciliado <> 'V' ) AND ( psTipoTransaccion = '01' ) AND ( psMovCodTran = '00' OR psMovCodTran = '01' ) ) THEN 

            LET ESTADO1 = '19' ;

            LET viGenRefTipoMovimiento = 2 ;            --genera la referencia para el registro de la comision a cobrar por el movimiento
            EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, psNombreComercio, psSecuenciaAuth ) INTO vsReferencia ;

            LET vsDocumento = PREFIJO_SEC_EL || LPAD ( TRIM ( psSecuenciaAuth ), 6, '0' ) ;
            IF psSecuenciaExtendida is null THEN
                 LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
            ELSE
                 LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
            END IF;


            LET vsSecEnviadaCentral = vsDocumento ;
            
            IF EnLinea = 'D' THEN
                LET vsTipoEnviadaCentral = 'D' ;
            ELSE
                LET vsTipoEnviadaCentral = 'C' ;
            END IF

            --GUARDA EL REGISTRO CORRESPONDIENTE A LA TRANSACCION ACTUAL
            EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_COMPRA,
            vsFolioSucursal, TS_COMPRA, psNumTarjeta, vsDocumento, pmMonto, psMovMoneda,
            vsReferencia, vsFolioOrig, vsDocumentoOrig, vsTransaccionOrig, vmMontoOrig, pmMovMontoCashBack , 
            psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, psTipoTransInterEmpresa, 
            pmMontoComInterEmpresa, psConvenioInterEmpresa ) INTO vsREGISTROCENTRAL1 ;

            IF ( pmMovMontoComision > 0) THEN

                EXECUTE PROCEDURE sp_GetSecuencia (0) INTO vsMovSecComision  ; -- CON 0 OBTIENE LA SECUENCIA PARA EL COBRO DE LA COMISION

                LET vsDocumento =  PREFIJO_SEC_FL || LPAD ( TRIM ( vsMovSecComision ), 6, '0' ) ; 
                IF psSecuenciaExtendida is null THEN
                     LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
                ELSE
                     LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
                END IF;


                LET viGenRefTipoMovimiento = 10 ;                --genera la referencia para el registro de la comision a cobrar por el movimiento
                EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, psNumTarjeta, '' ) INTO vsReferenciaComision  ;

                IF EnLinea = 'D' THEN
                    LET vsTipoEnviadaCentral = 'D' ;
                END IF

                -- CUARDA EL REGISTRO CORRESPONDIENTE AL COBRO DE LA COMISION DE LA TRANSACCION ACTUAL
                EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_CCOMPRA, 
                vsFolioSucursal, TS_CCOMPRA, psNumTarjeta, vsDocumento, pmMovMontoComision, psMovMoneda, 
                vsReferenciaComision , vsFolioOrig , vsDocumentoOrig, vsTransaccionOrig , vmMontoOrig, pmMovMontoCashBack , 
                psRFC , vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, '', 
                0.0, '' ) INTO vsREGISTROCENTRAL2 ;

                LET vsSecuenciaComision = PREFIJO_SEC_FL || LPAD ( TRIM ( vsMovSecComision ), 6, '0' ) ; 

            END IF ;

            IF ( pmMovMonto = pmMonto ) THEN
                LET viStatusConciliacion  = 2 ; 
            ELSE
                LET viStatusConciliacion  = 4 ; 
            END IF ;

        -- TIPO 20
        ELIF ( ( ( psCodigoCentral <> '00000' ) OR ( psCodigoISO <> '00' ) OR  ( psMovMovConciliado = 'V' ) ) AND ( psTipoTransaccion <> '21' ) 
        AND ( psMovMovConciliado <> 'V' ) AND ( psTipoTransaccion = '01' OR psTipoTransaccion = '09' ) AND ( psMovCodTran = '09' )  AND ( pmMovMonto > 0 ) 
        AND ( pmMovMonto > pmMovMontoCashBack ) ) THEN 

            LET ESTADO1 = '20' ;
            LET viTipodeTransaccion = 203 ; --COMPRA_POS

            LET viGenRefTipoMovimiento = 2 ;            --genera la referencia para el registro de la comision a cobrar por el movimiento
            EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, psNombreComercio, psSecuenciaAuth ) INTO vsReferencia ;

            LET vsDocumento = PREFIJO_SEC_EL || LPAD ( TRIM ( psSecuenciaAuth ), 6, '0' ) ;
            IF psSecuenciaExtendida is null THEN
                 LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
            ELSE
                 LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
            END IF;


            LET vsSecEnviadaCentral = vsDocumento ;
            
            IF EnLinea = 'D' THEN
                LET vsTipoEnviadaCentral = 'D' ;
            ELSE
                LET vsTipoEnviadaCentral = 'C' ;
            END IF

            --GUARDA EL REGISTRO CORRESPONDIENTE A LA TRANSACCION ACTUAL
            EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_COMPRA,
            vsFolioSucursal, TS_COMPRA, psNumTarjeta, vsDocumento, ( pmMonto - pmMovMontoCashBack ), psMovMoneda,
            vsReferencia, vsFolioOrig, vsDocumentoOrig, vsTransaccionOrig, vmMontoOrig, pmMovMontoCashBack , 
            psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, psTipoTransInterEmpresa, 
            pmMontoComInterEmpresa, psConvenioInterEmpresa ) INTO vsREGISTROCENTRAL1 ;

            LET viTipodeTransaccion = 210 ; --CASHBACK_POS

            LET viGenRefTipoMovimiento = 20 ;            --genera la referencia para el registro de la comision a cobrar por el movimiento
            EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, 'CASH BACK', psSecuenciaAuth ) INTO vsReferencia ;

            LET vsDocumento = PREFIJO_SEC_CASH_BACK || LPAD ( TRIM ( psMovSecuenciaCashBack ), 6, '0' ) ;
            IF psSecuenciaExtendida is null THEN
                 LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
            ELSE
                 LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
            END IF;


            LET vsMovSecuenciaCashBack = vsDocumento ;
            
            IF EnLinea = 'D' THEN
                LET vsTipoEnviadaCentral = 'D' ;
            ELSE
                LET vsTipoEnviadaCentral = 'C' ;
            END IF

            --GUARDA EL REGISTRO CORRESPONDIENTE A LA TRANSACCION ACTUAL
            EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_CASHBACK,
            vsFolioSucursal, TS_CASHBACK, psNumTarjeta, vsDocumento, pmMovMontoCashBack, psMovMoneda,
            vsReferencia, vsFolioOrig, vsDocumentoOrig, vsTransaccionOrig, vmMontoOrig, pmMovMontoCashBack , 
            psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, '', 
            0.0, '' ) INTO vsREGISTROCENTRAL2 ;

            IF ( pmMovMonto = pmMonto ) THEN
                LET viStatusConciliacion  = 2 ; 
            ELSE
                LET viStatusConciliacion  = 4 ; 
            END IF ;

        -- TIPO 21
        ELIF ( ( ( psCodigoCentral <> '00000' ) OR ( psCodigoISO <> '00' ) OR  ( psMovMovConciliado = 'V' ) ) AND ( psTipoTransaccion <> '21' ) 
        AND ( psMovMovConciliado <> 'V' ) AND ( psTipoTransaccion = '01' OR psTipoTransaccion = '09' ) AND ( psMovCodTran = '09' )  AND ( pmMovMonto > 0 ) 
        AND ( pmMovMonto = pmMovMontoCashBack ) ) THEN 

            LET ESTADO1 = '21' ;

            LET viGenRefTipoMovimiento = 21 ;            --genera la referencia para el registro de la comision a cobrar por el movimiento
            EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, 'CASH ADVANCE', psSecuenciaAuth ) INTO vsReferencia ;

            LET vsDocumento = PREFIJO_SEC_CASH_BACK || LPAD ( TRIM ( psMovSecuenciaCashBack ), 6, '0' ) ;
            IF psSecuenciaExtendida is null THEN
                 LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
            ELSE
                 LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
            END IF;


            LET vsSecEnviadaCentral = vsDocumento ;
            LET vsMovSecuenciaCashBack = vsDocumento ;
            
            IF EnLinea = 'D' THEN
                LET vsTipoEnviadaCentral = 'D' ;
            ELSE
                LET vsTipoEnviadaCentral = 'C' ;
            END IF

            --GUARDA EL REGISTRO CORRESPONDIENTE A LA TRANSACCION ACTUAL
            EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_CASHADVANCE,
            vsFolioSucursal, TS_CASHADVANCE, psNumTarjeta, vsDocumento, pmMovMontoCashBack, psMovMoneda,
            vsReferencia, vsFolioOrig, vsDocumentoOrig, vsTransaccionOrig, vmMontoOrig, pmMovMontoCashBack , 
            psRFC, vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, psTipoTransInterEmpresa, 
            pmMontoComInterEmpresa, psConvenioInterEmpresa ) INTO vsREGISTROCENTRAL1 ;

            --IF ( pmMovMontoComCashBack > 0) THEN                
            IF ( pmMovMontoComision > 0 ) THEN 

                LET vsDocumento =  PREFIJO_SEC_CASH_BACK || LPAD ( TRIM ( psMovSecuenciaComCashBack ), 6, '0' ) ;
                IF psSecuenciaExtendida is null THEN
                     LET vsFolioSucursal = psUsuarioParametros || vsDocumento ;
                ELSE
                     LET vsFolioSucursal = PREFIJO_SEC_I || psFechaLocalTransaccion || l_sHoraLocalTransaccion || vsDocumento;
                END IF;


                LET vsMovSecuenciaComCashBack = LPAD ( TRIM ( psMovSecuenciaComCashBack ), 6, '0' ) ;

                LET viGenRefTipoMovimiento = 21 ;                --genera la referencia para el registro de la comision a cobrar por el movimiento
                EXECUTE PROCEDURE sp_GeneraReferencia( viGenRefTipoMovimiento, 'COMISION CASH ADVANCE', vsSecuencia ) INTO vsReferenciaComision ;

                IF EnLinea = 'D' THEN
                    LET vsTipoEnviadaCentral = 'D' ;
                END IF

                -- CUARDA EL REGISTRO CORRESPONDIENTE AL COBRO DE LA COMISION DE LA TRANSACCION ACTUAL
                EXECUTE PROCEDURE  sp_InsertarCentral ( psArchivoOrigen, vsTipoEnviadaCentral, TC_CCOMISIONCASHADVANCE, 
                vsFolioSucursal, TC_CCOMISIONCASHADVANCE, psNumTarjeta, vsDocumento, pmMovMontoComision /*pmMovMontoComCashBack*/, psMovMoneda, 
                vsReferenciaComision , vsFolioOrig , vsDocumentoOrig, vsTransaccionOrig , vmMontoOrig, pmMovMontoCashBack , 
                psRFC , vsReferenciaTransaccion, psDivisa, pmMontoDivisa, psFormadePago, vsNumCajero, '', 
                0.0, '' ) INTO vsREGISTROCENTRAL2 ;                

            END IF ;

            IF ( pmMovMonto = pmMonto ) THEN
                LET viStatusConciliacion  = 2 ; 
            ELSE
                LET viStatusConciliacion  = 4 ; 
            END IF ;

        -- TIPO 22
        ELIF ( ( ( psCodigoCentral <> '00000' ) OR ( psCodigoISO <> '00' ) OR  ( psMovMovConciliado = 'V' ) ) AND ( psTipoTransaccion <> '21' ) 
        AND ( psMovMovConciliado <> 'V' ) AND ( psTipoTransaccion = '02' ) ) THEN 

            LET ESTADO1 = '22' ;

            LET vsDESCRIPCION2 = 'Aviso. Los Retiros ATM Internacionales son descartados' ;
            LET vsDESCRIPCION3 = '       en el archivo 325 y procesados en el Stat07.' ;

        -- TIPO 23
        ELIF ( ( ( psCodigoCentral <> '00000' ) OR ( psCodigoISO <> '00' ) OR  ( psMovMovConciliado = 'V' ) ) AND ( psTipoTransaccion <> '21' ) 
        AND ( psMovMovConciliado <> 'V' ) AND ( psTipoTransaccion <> '02' ) ) THEN 

            LET ESTADO1 = '23' ;

            LET vsDESCRIPCION2 = 'No se puede definir la Transaccion.' ;
            LET viStatusConciliacion  = 7 ; 

        -- TIPO 24
        ELIF ( ( ( psCodigoCentral <> '00000' ) OR ( psCodigoISO <> '00' ) OR  ( psMovMovConciliado = 'V' ) ) AND ( psTipoTransaccion <> '21' ) 
        AND ( psMovMovConciliado = 'V' )  ) THEN 

            LET ESTADO1 = '24' ;

            LET vsDESCRIPCION2 = 'La Transaccion ya fue Conciliada Anteriormente (BD).' ;
            LET viStatusConciliacion  = 9 ; 

        END IF ;

    END IF ;

--ELSE  --NO SE ENCONTRO EL MOVIMIENTO ORIGINAL EN LA TABLA DE MOVIMIENTO
     -- casos desde tipo 25 hasta tipo 31 que estan en sp_tipo_conciliacion_pos2
    -- TIPO 25
    --IF ( psTipoTransaccion = '21' ) THEN 
    --END IF 
-- casos hasta tipo 31 que estan en sp_tipo_conciliacion_pos2
END IF ;
RETURN vsClaveAutorizacionDeTransaccion, vsSecuenciaComision, viStatusConciliacion, vsDESCRIPCION1, vsDESCRIPCION2, 
    vsDESCRIPCION3, vsREGISTROCENTRAL1, vsREGISTROCENTRAL2, vmMontoReversa, viTipodeTransaccion, 
    vsSecEnviadaCentral, vsMovSecuenciaCashBack, vsMovSecuenciaComCashBack, vsTipoEnviadaCentral, ESTADO1 ;
END
END PROCEDURE
;