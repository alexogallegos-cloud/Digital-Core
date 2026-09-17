CREATE PROCEDURE "informix".sp_busca_productos_credito()

	RETURNING CHAR(30) AS nombreProducto;

	--definicion de variables--	    
	DEFINE resultado_nombreProducto 		CHAR(30);
	DEFINE iSqlErr                          	INTEGER;
	
	-- InicializaciÃ³n de las variables.
	LET resultado_nombreProducto = '';

	SET ISOLATION TO dirty READ;
			
	BEGIN

        ON EXCEPTION
            SET iSqlErr
            	IF iSqlErr <> 0 THEN
                	LET resultado_nombreProducto = '';
                	RETURN resultado_nombreProducto;
           	END IF;
        END EXCEPTION;

       	 FOREACH
			SELECT nombre_prod
			INTO resultado_nombreProducto
			FROM bdicred:sd_definicion
			RETURN resultado_nombreProducto WITH RESUME;
       	 END FOREACH;
	END
END PROCEDURE;