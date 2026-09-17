CREATE PROCEDURE "informix".sp_obtenerparametros(cEmpresa CHAR(3), iParametro INTEGER)
 RETURNING
 CHAR(5), CHAR (20);

--DEFINICION DE VARIABLES
    DEFINE iSqlErr INTEGER;
    DEFINE cCodret CHAR (5);
    DEFINE cValor  CHAR (20);
	
--INICIALIZACION DE VARIABLES
	LET cCodret = "00000";
	LET cValor  = "";
	LET iSqlErr = 0;

    -- SET DEBUG FILE TO "/tmp/sp_obtenerparametros.out";
    -- TRACE ON;

	BEGIN
 
	    ON EXCEPTION SET iSqlErr
	        IF iSqlErr <> 0 THEN
	            LET cCodret = iSqlErr;
				RETURN cCodret, cValor;
	        END IF;
	    END EXCEPTION;
		
		---SET ISOLATION TO CURSOR STABILITY;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 10;
		
	    IF iParametro <> 0 AND TRIM(cEmpresa) <> '' AND cEmpresa IS NOT NULL THEN
		
	        SELECT valor
	        INTO cValor
	        FROM bdisolic:"informix".ss_param
	        WHERE empresa = cEmpresa 
			AND secuencia = iParametro;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				LET cCodret = "00002";
			END IF;
			
	    ELSE
			LET cCodret = "00001";
	    END IF;
		
	    RETURN cCodret, cValor;

	END;
END PROCEDURE
