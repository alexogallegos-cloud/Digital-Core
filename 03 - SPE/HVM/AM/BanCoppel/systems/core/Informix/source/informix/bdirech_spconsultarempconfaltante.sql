CREATE PROCEDURE "informix".spconsultarempconfaltante ()
RETURNING CHAR(5) AS CodigoRetorno,
		  CHAR(8) AS NumEmpleado
		
	DEFINE iSqlErr          INTEGER;
							
	DEFINE v_sCodRet        CHAR(5);
	DEFINE v_sNumEmpleado	CHAR(8);
	
	--SET DEBUG FILE TO  "/tmp/Vladi/spconsultarempconfaltante.out"; 
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
			SELECT numempleado INTO v_sNumEmpleado FROM bdirech:"informix".rec_confaltante
			WHERE saldoactual > 0 --Tengan Saldo
			AND idrecupera IN (2,6) --Via Nomina, Nómina Fijo
			AND idestatus IN(1,2) -- 1 Pendiente de aplicar, 2 Aplicado
			GROUP BY numempleado
				
			RETURN v_sCodRet, v_sNumEmpleado WITH RESUME;
		END FOREACH;
	END
END PROCEDURE
