CREATE PROCEDURE "informix".sp_consulta_estados(p_skip INT, p_Pais CHAR(3))

     RETURNING	CHAR(4) AS pais, CHAR(4) AS numeroEstado, CHAR(30) AS nombreEstado;

	--definicion de variables--	    
	DEFINE resultado_pais           CHAR(4);
    	DEFINE resultado_numeroEstado   CHAR(4);
    	DEFINE resultado_nombreEstado   CHAR(30);
    	DEFINE iSqlErr                  INTEGER;
		
     -- InicializaciÃ³n de las variables.
	LET resultado_pais = '';
	LET resultado_numeroEstado = '';
    LET resultado_nombreEstado = '';

    SET ISOLATION TO DIRTY READ;
				
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_pais = '';
                    LET resultado_numeroEstado = '';
                    LET resultado_nombreEstado = '';
                    RETURN resultado_pais, resultado_numeroEstado, resultado_nombreEstado;
                END IF;
        END EXCEPTION;

		FOREACH       
	     	SELECT SKIP p_skip DISTINCT pais, estado, nombre
	          INTO resultado_pais, resultado_numeroEstado, resultado_nombreEstado
	          FROM bdinteg:si_estados 
              WHERE pais = p_Pais
              ORDER BY pais asC, nombre asC, estado asC
	          RETURN resultado_pais, resultado_numeroEstado, resultado_nombreEstado WITH RESUME;
		END FOREACH;
	END
END PROCEDURE;