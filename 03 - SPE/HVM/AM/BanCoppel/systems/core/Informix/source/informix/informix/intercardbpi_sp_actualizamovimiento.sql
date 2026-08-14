CREATE PROCEDURE "informix".sp_actualizamovimiento( psSecuencia CHAR (6),  psNumTarjeta CHAR (16), psTipoMovimiento CHAR (2), pdtFechaHoraInAuth DATETIME YEAR TO FRACTION )
RETURNING CHAR(100) ;

--****************************************************************************************************
-- DESCRIPCION: MARCA EL REGISTRO ORIGINAL COMO CONCILIADO ( ATM Y POS )
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 01/07/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO :  Casanova Edeza Hector Juan   -- ZERO  
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */

DEFINE vsNomSecuencia CHAR (30) ;

DEFINE vsmensajeError  CHAR (100) ; 

/* INICIALIZACION DE VARIABLES */

LET vsmensajeError = '' ;

BEGIN
        
            --actualizar el movimiento en la tabla como conciliado
            LET vsmensajeError = 'UPDATE Movimiento SET MovConciliado = "V"  WHERE Secuencia = "1' || psSecuencia || '" AND ProdInd = "' || psTipoMovimiento ||  
            ' " AND NumTarjeta = "'  || psNumTarjeta || '" ;' ;
            UPDATE Movimiento SET MovConciliado = 'V'  WHERE Secuencia = '1' || psSecuencia AND NumTarjeta = psNumTarjeta 
                AND ProdInd = psTipoMovimiento AND FechaHoraInAuth = pdtFechaHoraInAuth;

        LET vsmensajeError = '' ;

    RETURN vsmensajeError  ;

END

END PROCEDURE 
;