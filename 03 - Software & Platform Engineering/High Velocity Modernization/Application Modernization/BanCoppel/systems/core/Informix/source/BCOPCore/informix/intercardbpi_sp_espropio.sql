CREATE PROCEDURE "informix".sp_espropio( psIdReceptor CHAR (4) )
RETURNING CHAR(1) ;

/*  DEFINICION DE VARIABLES */
DEFINE vsEsPropio  CHAR (1) ; 
DEFINE vsiNumRegistros  INTEGER ;

/* INICIALIZACION DE VARIABLES */
LET vsEsPropio = 'F' ;
LET vsiNumRegistros  = 0 ;

BEGIN
    --CHECA SI LA TRANSACCION SE REALIZO EN CAJERO PROPIO
    SET LOCK MODE TO WAIT  ;
    SET ISOLATION TO DIRTY READ ;
    SELECT COUNT (FIID) INTO vsiNumRegistros  FROM Parametros WHERE FIID = psIdReceptor  ;
    
    IF ( vsiNumRegistros > 0 ) THEN 
        LET vsEsPropio  = 'V' ;
    ELSE
        LET vsEsPropio  = 'F' ;
    END IF ;
END
    RETURN  vsEsPropio ;

END PROCEDURE 
;