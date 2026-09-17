CREATE PROCEDURE "informix".sp_nombreempleado (p_sNumeroEmpleado CHAR(8))

     RETURNING	CHAR(45) AS nombreEmpleado;

	--definicion de variables--	    
	DEFINE resultado_nombreEmpleado 	CHAR(45);
	DEFINE iSqlErr                  	INTEGER;
	
     -- InicializaciÃ³n de las variables.
	LET resultado_nombreEmpleado = '';

    SET ISOLATION TO DIRTY READ;
			
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    	LET resultado_nombreEmpleado = '';
                    RETURN resultado_nombreEmpleado;
                END IF;
            END EXCEPTION;

		SELECT DISTINCT si_ejecut.nombre
		INTO resultado_nombreEmpleado
		FROM si_ejecut
		WHERE ejecutivo = p_sNumeroEmpleado;
		RETURN resultado_nombreEmpleado;
	END
END PROCEDURE;