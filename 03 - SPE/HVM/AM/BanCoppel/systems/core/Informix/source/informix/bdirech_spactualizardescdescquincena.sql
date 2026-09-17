CREATE PROCEDURE "informix".spactualizardescdescquincena (p_sNumEmpleado CHAR(8), p_mDescAplicado MONEY(10,0))
RETURNING CHAR(5) AS CodigoRetorno;

DEFINE iSqlErr			INTEGER;
DEFINE v_sCodRet       	CHAR(5);
	
	-----------------------------------------------------------
	--SET DEBUG FILE TO "/tmp/prisma/spactualizardescdescquincena.out"; 
	--TRACE ON;
    -----------------------------------------------------------
	
	LET v_sCodRet = '00000';
	LET iSqlErr   = 0;
	
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION 
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				INSERT INTO bdirech:"informix".rec_errores(descripcion) VALUES ('saddq '||iSqlErr);
				RETURN v_sCodRet;
			END IF;
		END EXCEPTION;
		
		IF NVL(p_sNumEmpleado, '') = '' THEN
			LET v_sCodRet = '00001';
			RETURN v_sCodRet;
		END IF;
		
		IF EXISTS (SELECT numempleado FROM bdirech:"informix".rec_descquincena WHERE numempleado = p_sNumEmpleado) THEN				
			UPDATE bdirech:"informix".rec_descquincena SET descaplicado = p_mDescAplicado
			WHERE numempleado = p_sNumEmpleado;	
		ELSE
			LET V_sCodret = '00002';
		END IF;		
		
		RETURN v_sCodRet;		
	END;
END PROCEDURE

