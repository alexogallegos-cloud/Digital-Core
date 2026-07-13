CREATE PROCEDURE "informix".sp_esconvenio( psIdReceptor CHAR (4) )
RETURNING CHAR(1) ;

/*  DEFINICION DE VARIABLES */
DEFINE vsEsConvenio  CHAR (1) ; 
DEFINE vsiNumRegistros  INTEGER ;

/* INICIALIZACION DE VARIABLES */
LET vsEsConvenio = 'F' ;
LET vsiNumRegistros  = 0 ;
BEGIN 

    SET LOCK MODE TO WAIT  ;
    SET ISOLATION TO DIRTY READ ;
    --CHECA SI LA TRANSACCION SE REALIZO EN CAJERO PROPIO
    SELECT COUNT (FIID) INTO vsiNumRegistros  FROM CajerosPropios  WHERE FIID = psIdReceptor  ;
    
    IF ( vsiNumRegistros > 0 ) THEN 
        LET vsEsConvenio  = 'V' ;
    ELSE
        LET vsEsConvenio  = 'F' ;
    END IF ;
END     
    RETURN  vsEsConvenio ;

END PROCEDURE 
;