CREATE PROCEDURE "informix".spborrardescquincena ()
RETURNING CHAR(5) AS CodigoRetorno
	
	DEFINE iSqlErr			INTEGER;

	DEFINE v_sCodRet       	CHAR(5);
	
	--SET DEBUG FILE TO "/tmp/Vladi/spborrardescquincena.out"; 
	--TRACE ON;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet;
			END IF;
		END EXCEPTION;
		
		LET v_sCodRet = '00000';
		
		DELETE FROM bdirech:rec_descquincena;
		
		RETURN v_sCodRet;
	END
END PROCEDURE
