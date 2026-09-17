CREATE PROCEDURE "informix".spconsultarprocesos (p_dFechaProceso DATE, p_IdProceso SMALLINT)
RETURNING CHAR(5)  AS CodigoRetorno,
		  DATE	   AS FechaProceso,
		  SMALLINT AS IdProceso,
		  CHAR(40) AS DescripcionProceso,
		  CHAR(1)  AS Estatus

	DEFINE iSqlErr			INTEGER;

	DEFINE v_sCodRet       	CHAR(5);
	DEFINE v_dFechaProceso 	DATE;
	DEFINE v_iIdProceso	 	SMALLINT;
	DEFINE v_sEstatus		CHAR(1);
	DEFINE v_sDescripcion  	CHAR(40);
	
	--SET DEBUG FILE TO "/tmp/Vladi/spconsultarprocesos.out"; 
	--TRACE ON;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet, '', '', '', '';
			END IF;
		END EXCEPTION;

		LET v_sCodRet = '00000';
		
		LET v_dFechaProceso = '';
		LET v_iIdProceso = 0;
		LET v_sEstatus = '';
		LET v_sDescripcion = '';

		--// ********************************************************************
		--// Valida parámetros de entrada, la fecha es obligatria
		--// ********************************************************************
		IF NVL(p_dFechaProceso, '') = '' THEN
			LET v_sCodRet = '00001';
			RETURN v_sCodRet , '', '','','';
		END IF
		
		IF p_IdProceso = '' THEN
			LET p_IdProceso = NULL;
		END IF

		FOREACH
			SELECT fechaproceso, idprocesos, desprocesos, estatus
			INTO v_dFechaProceso, v_iIdProceso, v_sDescripcion, v_sEstatus
			FROM bdirech:rec_procesos
			WHERE fechaproceso = p_dFechaProceso AND idprocesos = NVL(p_IdProceso, idprocesos)
			ORDER BY idprocesos
			
			RETURN v_sCodRet, v_dFechaProceso, v_iIdProceso, v_sDescripcion, v_sEstatus WITH RESUME;
		END FOREACH;
	END
END PROCEDURE
