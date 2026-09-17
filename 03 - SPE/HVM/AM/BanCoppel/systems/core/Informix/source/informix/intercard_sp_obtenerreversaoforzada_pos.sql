CREATE PROCEDURE "informix".sp_obtenerreversaoforzada_pos (  psSecuenciaOriginal CHAR (7), psSecuencia CHAR (6), psNumTarjeta CHAR (16) )

RETURNING INTEGER, CHAR (7), CHAR (2), CHAR (4), MONEY, MONEY, MONEY, CHAR (2), CHAR (4), CHAR (1), 
CHAR (16), CHAR (1), CHAR (6), CHAR (1), CHAR (1), CHAR (5), CHAR (1000) ;

--****************************************************************************************************
-- DESCRIPCION: BUSCA EL MOVIMIENTO REVERSADO O FORZADO ORIGINAL EN MOVIMIENTOS (POS)
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 10/03/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : --ZERO 
--***************************************************************************************************

--DEFINICION DE VARIABLES
--- VARIABLES DEL SELECT DE MOVIMIENTOS
DEFINE viExisteReverzaForzada INTEGER ;
DEFINE vsRFSecuencia CHAR (7) ;
DEFINE vsRFCodigoISO CHAR (2) ;
DEFINE vsRFFechaMov CHAR (4) ;
DEFINE vmRFMonto MONEY ;
DEFINE vmRFMontoCashBack MONEY ;
DEFINE vmRFMontoRealRevFzda MONEY ;
DEFINE vsRFCodTran CHAR (2) ;
DEFINE vsRFFormato CHAR (4) ;
DEFINE vsRFMovConciliado CHAR (1) ;
DEFINE vsRFIdTerminal CHAR (16) ;
DEFINE vsRFEnLinea CHAR (1) ;
DEFINE vsRFHoraLocalTransaccion CHAR (6) ;
DEFINE vsRFMovReversado CHAR (1) ;
DEFINE vsRFCodReversa CHAR (1) ;
DEFINE vsRFCodigoCentral CHAR (5) ;

DEFINE vsQUERY2 CHAR (1000) ; 
-- VARIABLES DE MANEJO DE ERRORES
DEFINE visqlerr INTEGER ;

--INICIALIZACION DE VARIABLES

--- VARIABLES DEL SELECT DE MOVIMIENTOS
LET viExisteReverzaForzada = 0 ;
LET vsRFSecuencia = '' ;
LET vsRFCodigoISO = '' ;
LET vsRFFechaMov = '' ;
LET vmRFMonto = 0 ;
LET vmRFMontoCashBack = 0 ;
LET vmRFMontoRealRevFzda = 0 ;
LET vsRFCodTran = '' ;
LET vsRFFormato = '' ;
LET vsRFMovConciliado = '' ;
LET vsRFIdTerminal = '' ;
LET vsRFEnLinea = '' ;
LET vsRFHoraLocalTransaccion = '' ;
LET vsRFMovReversado = '' ;
LET vsRFCodReversa = '' ;
LET vsRFCodigoCentral = '' ;

LET vsQUERY2 = '' ;

-- VARIABLE DE MANEJO DE ERRORES
LET visqlerr = 0 ;

BEGIN

    IF ( TRIM ( psSecuenciaOriginal )<> '') THEN 

         LET vsQUERY2 = ' SELECT Secuencia, CodigoISO, FechaMov, Monto, MontoCashBack, '
            || 'MontoRealRevFzda, CodTran, Formato, MovConciliado, IdTerminal, EnLinea, '
            || 'HoraLocalTransaccion, MovReversado, CodReversa, CodigoCentral '
            || 'FROM Movimiento '
            || 'WHERE SecuenciaOrig = "1' || psSecuencia  || '" AND NumTarjeta = "' || psNumTarjeta || '" AND ProdInd = "02" ;' ;

        SET LOCK MODE TO WAIT  ;
        SET ISOLATION TO DIRTY READ ;

        SELECT COUNT (Secuencia) INTO viExisteReverzaForzada FROM Movimiento WHERE SecuenciaOrig =  '1' || psSecuencia  
            AND NumTarjeta = psNumTarjeta AND ProdInd = '02' ;

        IF ( viExisteReverzaForzada > 0) THEN 

            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;

            SELECT LIMIT 1 NVL (Secuencia, ''), NVL (CodigoISO, ''), NVL (FechaMov, ''), NVL (Monto, ''), NVL (MontoCashBack, ''), 
                NVL (MontoRealRevFzda, ''), NVL (CodTran, ''), NVL (Formato, ''), NVL (MovConciliado, ''), NVL (IdTerminal, ''), NVL (EnLinea, ''), 
                NVL (HoraLocalTransaccion, '000000'), NVL (MovReversado, ''), NVL (CodReversa, ''), NVL (CodigoCentral, '')
                INTO vsRFSecuencia, vsRFCodigoISO, vsRFFechaMov, vmRFMonto, vmRFMontoCashBack, vmRFMontoRealRevFzda, vsRFCodTran, vsRFFormato, 
                vsRFMovConciliado, vsRFIdTerminal, vsRFEnLinea, vsRFHoraLocalTransaccion, vsRFMovReversado, vsRFCodReversa, vsRFCodigoCentral 
                FROM Movimiento 
                WHERE SecuenciaOrig =  '1' || psSecuencia  AND NumTarjeta = psNumTarjeta AND ProdInd = '02' ; 

        END IF ;

    END IF ;    

    RETURN viExisteReverzaForzada, vsRFSecuencia, vsRFCodigoISO, vsRFFechaMov, vmRFMonto, vmRFMontoCashBack, 
            vmRFMontoRealRevFzda, vsRFCodTran, vsRFFormato, vsRFMovConciliado, vsRFIdTerminal, vsRFEnLinea, vsRFHoraLocalTransaccion, 
            vsRFMovReversado, vsRFCodReversa, vsRFCodigoCentral, vsQUERY2  ;

END

END PROCEDURE
;