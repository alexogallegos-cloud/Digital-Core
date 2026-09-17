CREATE PROCEDURE "informix".sp_getsecuenciatrancon( )
RETURNING CHAR(10), CHAR(150) ;

/*  DEFINICION DE VARIABLES */
DEFINE vsSecuencia  CHAR (10) ; 

DEFINE vsNomSecuencia CHAR (30) ;

DEFINE vsSectorErr  CHAR (150) ; 

/* INICIALIZACION DE VARIABLES */

LET vsSecuencia  = '0' ;
LET vsSectorErr = '' ;

BEGIN

     --TOMA Y ACTUALIZA LA SECUECIA CORESPONDIENTE PARA LA TRANSACCION ACTUAL DEL CAMPO SECTRANCON
        LET vsSectorErr = 'SELECT NVL( Secuencia, "1") FROM SecuenciaInterCard Where NombreSecuencia = "SecTranCon" ' ;
        SET LOCK MODE TO WAIT  ;
        SET ISOLATION TO DIRTY READ ;
        SELECT NVL( Secuencia, '1') INTO vsSecuencia FROM SecuenciaInterCard Where NombreSecuencia = 'SecTranCon'  ; 

        IF ( vsSecuencia = '999999' ) THEN
            LET vsSectorErr = 'UPDATE SecuenciaInterCard SET secuencia = 1 Where NombreSecuencia = "SecTranCon" ' ;
            UPDATE SecuenciaInterCard SET secuencia = 1 Where NombreSecuencia = 'SecTranCon'   ;
        ELSE
           LET vsSectorErr = 'UPDATE SecuenciaInterCard SET secuencia = secuencia + 1 Where NombreSecuencia = "SecTranCon" ' ;
            UPDATE SecuenciaInterCard SET secuencia = secuencia + 1 Where NombreSecuencia = 'SecTranCon' ;
        END IF ;

        LET vsSectorErr = '' ;

    RETURN vsSecuencia, vsSectorErr  ;

END

END PROCEDURE 
;