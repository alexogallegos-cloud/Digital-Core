CREATE PROCEDURE "informix".sp_buscarclientespornumero (p_sNumeroCliente CHAR(30))

     RETURNING	CHAR(20) AS noCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, CHAR(30) AS segundoNombre;

	--definicion de variables--	    
	DEFINE resultado_numeroCliente 		CHAR(20);
	DEFINE resultado_primerApellido		CHAR(30);
	DEFINE resultado_segundoApellido	CHAR(30);
    DEFINE resultado_primerNombre		CHAR(30);
    DEFINE resultado_segundoNombre		CHAR(30);
    DEFINE resultado_numerotransfer     CHAR(30);
  
    DEFINE iSqlErr                      INTEGER;
	
     	-- InicializaciÃ³n de las variables.
	LET resultado_numeroCliente = '';
	LET resultado_primerApellido = '';
	LET resultado_segundoApellido = '';
	LET resultado_primerNombre = '';
	LET resultado_segundoNombre = '';
  

    SET ISOLATION TO DIRTY READ;
			
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_numeroCliente = '';
                    LET resultado_primerApellido = '';
                    LET resultado_segundoApellido = '';
                    LET resultado_primerNombre = '';
                    LET resultado_segundoNombre = '';
                   
                    RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;
                END IF;
        END EXCEPTION;

	SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno
		INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
		FROM bdinteg:si_cliente
		WHERE p_sNumeroCliente = numcte;
    

   IF ( resultado_primerNombre IS NULL) THEN 
    
      SELECT bditransfer:tf_maecte.numcte 
      INTO resultado_numerotransfer
         FROM bditransfer:tf_maecte
        WHERE bditransfer:tf_maecte.numcte_tf = p_sNumeroCliente;
      
     SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno
		INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
		FROM bdinteg:si_cliente
		WHERE resultado_numerotransfer = numcte;
     

    END IF;
      
    

   RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;

		

	END
END PROCEDURE;