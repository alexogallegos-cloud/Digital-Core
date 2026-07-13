CREATE PROCEDURE "informix".sp_obten_secuencia_folio()
	RETURNING CHAR (5) AS secuenciaMax;  
	--DEFINICION DE VARIABLES--	    
	
	DEFINE secuenciaMax	CHAR(5);

    --INICIALIZACION DE LAS VARIABLES--
	
	LET secuenciaMax = '';

   	
	SET ISOLATION TO DIRTY READ;
			
	BEGIN
        
		--OBTENIENDO EL VALOR MAXIMO DE LA SECUENCIA
	
		SELECT "informix".SECUENCIA_FOLIO_CSUAC.nextval 
			INTO  secuenciaMax
		FROM systables WHERE tabid = 1;

		RETURN  secuenciaMax;	
    END
END PROCEDURE;