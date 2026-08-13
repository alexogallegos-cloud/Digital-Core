CREATE PROCEDURE "informix".sp_existemovimientooriginal_estareversado( psSecuenciaOrig CHAR (7), psNumtarjeta CHAR (16) )
RETURNING INTEGER, INTEGER ;


--****************************************************************************************************
-- DESCRIPCION: IDENTIFICA SI LA TRANSACCION ORIGINAL ESTA REVERSADA
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 10/03/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : --ZERO 
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */

DEFINE viExiste INTEGER ;

DEFINE vsMovReversado CHAR (1) ;
DEFINE vsCodigoISO CHAR (2) ;
DEFINE viEstaReversado INTEGER ;
DEFINE viExistemovimientoOriginal INTEGER ;

/* INICIALIZACION DE VARIABLES */
LET viExiste = 0 ;

LET vsMovReversado = '' ;
LET vsCodigoISO = '' ;
LET viEstaReversado = -1 ;
LET viExistemovimientoOriginal = -1 ;

BEGIN 

    SET LOCK MODE TO WAIT 3 ;
    SET ISOLATION TO DIRTY READ ;

    SELECT COUNT ( NumTarjeta )  INTO viExiste FROM Movimiento 
    WHERE Secuencia = psSecuenciaOrig AND  NumTarjeta = psNumtarjeta ;
    
    IF ( viExiste = 1 ) THEN

        SET LOCK MODE TO WAIT  ;
        SET ISOLATION TO DIRTY READ ;

        SELECT NVL ( MovReversado , 'F' ), NVL ( CodigoISO, '' )  INTO vsMovReversado, vsCodigoISO FROM Movimiento 
        WHERE Secuencia = psSecuenciaOrig AND  NumTarjeta = psNumtarjeta ;

        IF ( vsMovReversado = 'F' ) THEN -- EXISTE Y NO ESTA REVERESADO
            LET viEstaReversado = 2 ;
        ELIF ( vsMovReversado = 'V' ) THEN --EXISTE Y YA ESTA REVERESADO
            LET viEstaReversado = 1 ;
        ELSE    -- EXISTE PERO TIENE NO ESTA CORRECTO (NO ES V NI F) SE TOMA COMO NO REVERSADO
            LET viEstaReversado = 2 ;
            --LET viEstaReversado = 3 ;
        END IF ;

        IF ( vsCodigoISO = '00' ) THEN --EXISTE Y ESTA APROVADO
            LET viExistemovimientoOriginal  = 1 ;
        ELIF ( vsCodigoISO <> '00' ) THEN -- EXISTE Y ESTA RECHAZADO
            LET viExistemovimientoOriginal  = 2 ;
        ELSE    -- EN CASO DE ERROR SE TOMA COMO RECHAZADO
            LET viExistemovimientoOriginal  = 2 ;
            --LET viExistemovimientoOriginal  = 3 ;
        END IF ;

    ELSE -- NO EXISTE EL MOVIMIENTO
        LET viEstaReversado = 0 ;
        LET viExistemovimientoOriginal = 0 ;
    END IF ;

    RETURN viExistemovimientoOriginal, viEstaReversado ;

END 
END PROCEDURE ;