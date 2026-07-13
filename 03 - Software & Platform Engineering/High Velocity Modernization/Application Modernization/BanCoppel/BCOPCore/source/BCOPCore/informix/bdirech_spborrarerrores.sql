CREATE PROCEDURE "informix".spborrarerrores ()
RETURNING CHAR(5) AS CodigoRetorno
	
	DEFINE iSqlErr			INTEGER;
	DEFINE v_sCodRet       	CHAR(5);
	
	--SET DEBUG FILE TO "/dbexportb/Fabiola/spborrarerrores.out"; 
	--TRACE ON;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet;
			END IF;
		END EXCEPTION;
				
		LET v_sCodRet = '00001';
		
		DELETE FROM bdirech:rec_errores;
		
		LET v_sCodRet = '00000';
		
		RETURN v_sCodRet;
	END
END PROCEDURE
