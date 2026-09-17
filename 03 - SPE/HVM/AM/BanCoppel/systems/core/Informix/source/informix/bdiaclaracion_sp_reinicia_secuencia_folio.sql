CREATE PROCEDURE "informix".sp_reinicia_secuencia_folio()

    RETURNING	  CHAR (1) AS ret; 
    DEFINE ret		CHAR(1);
    LET ret	= '1';

	SET ISOLATION TO DIRTY READ;
			
	BEGIN
        

--obteniendo el valor maximo de la sentencia
	
       ALTER SEQUENCE "informix".SECUENCIA_FOLIO_CSUAC restart with 1;

       RETURN  ret;
		
    END
END PROCEDURE;