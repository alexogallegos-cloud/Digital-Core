CREATE PROCEDURE "informix".sp_busca_productos_inversiones(p_sNumeroEmpresa CHAR(3))

	RETURNING CHAR(30) AS nombreProducto;

	--definicion de variables--	    
	DEFINE resultado_nombreProducto 		CHAR(30);
	DEFINE iSqlErr                      	INTEGER;
	
	-- InicializaciÃ³n de las variables.
	LET resultado_nombreProducto = '';

	SET ISOLATION TO DIRTY READ;
			
	BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_nombreProducto = '';
                RETURN resultado_nombreProducto;
            END IF;
        END EXCEPTION;

        	FOREACH
			SELECT nombre
			INTO resultado_nombreProducto
			FROM bdinvers:sv_instrum
            WHERE empresa = p_sNumeroEmpresa
			RETURN resultado_nombreProducto WITH RESUME;
       		END FOREACH;
	END
END PROCEDURE;