CREATE PROCEDURE "informix".spgenerarfechasquincenas2(pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING CHAR(5) AS CodigoRetorno, DATE AS FechaQuincena
	
DEFINE iSqlErr			INTEGER;
DEFINE v_sCodRet       	CHAR(5);	
DEFINE v_dFechaQuincena	DATE;

--SET DEBUG FILE TO "/dbexportb/Fabiola/spgenerarfechasquincenas.out"; 
--TRACE ON;
	
SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET v_sCodRet = iSqlErr;
			RETURN v_sCodRet, '';
		END IF;
	END EXCEPTION;
	
	LET v_sCodRet = '00000';		
	
	FOREACH
		SELECT SKIP pRegistros FIRST pRecuperacion
		valor INTO v_dFechaQuincena FROM bdirech:"informix".rec_param WHERE secuencia = 1
		RETURN v_sCodRet, v_dFechaQuincena WITH RESUME;
	END FOREACH;
	
	FOREACH
		SELECT SKIP pRegistros FIRST pRecuperacion
		DISTINCT(fechadesc) INTO v_dFechaQuincena FROM bdirech:"informix".rec_deschistorico ORDER BY fechadesc DESC				
		RETURN v_sCodRet, v_dFechaQuincena WITH RESUME;
	END FOREACH;
	
END
END PROCEDURE
