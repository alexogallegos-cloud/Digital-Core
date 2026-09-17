CREATE PROCEDURE "informix".spactualizarprocesos (p_dFechaProceso DATE, p_IdProceso SMALLINT, p_sEstatus CHAR(1))
RETURNING CHAR(5) AS CodigoRetorno
	
	DEFINE iSqlErr          INTEGER;

	DEFINE v_sCodRet        CHAR(5);
	---------------------------------------------------------------
	--SET DEBUG FILE TO  "/tmp/prisma/spactualizarprocesos.out"; 
	--TRACE ON;
    ---------------------------------------------------------------
	LET v_sCodRet = '00000';	
	
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet;
			END IF;
		END EXCEPTION;

		--// Valida parámetros de entrada
		IF NVL(p_dFechaProceso, '') = '' OR NVL(p_IdProceso, '') = '' OR NVL(p_sEstatus, '') = ''THEN
			LET v_sCodRet = '00001';
			RETURN v_sCodRet;
		END IF
		
		IF EXISTS(SELECT fechaproceso FROM bdirech:rec_procesos WHERE idprocesos = p_IdProceso) THEN
			UPDATE bdirech:rec_procesos SET fechaproceso = p_dFechaProceso, estatus = p_sEstatus 
			WHERE fechaproceso = p_dFechaProceso AND idprocesos = p_IdProceso;
		ELSE
			LET v_sCodRet = '00002';
		END IF;
		
		RETURN v_sCodRet;
	END
END PROCEDURE
