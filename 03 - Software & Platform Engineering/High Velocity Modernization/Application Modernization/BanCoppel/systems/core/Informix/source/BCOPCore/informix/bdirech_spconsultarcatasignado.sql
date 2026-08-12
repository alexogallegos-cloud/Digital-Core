CREATE PROCEDURE "informix".spconsultarcatasignado (p_iIdAsignado SMALLINT)
RETURNING CHAR(5) AS CodigoRetorno, SMALLINT AS IdAsignado, CHAR(80) AS DesAsignado, DATE AS FechaInsert
	
	DEFINE iSqlErr			INTEGER;

	DEFINE v_sCodRet       	CHAR(5);
	DEFINE v_iIdAsignado	SMALLINT;
	DEFINE v_sDesAsignado	CHAR(80);
	DEFINE v_dFechaInsert	DATE;
	
	--SET DEBUG FILE TO "/tmp/Vladi/spconsultarcatasignado.out"; 
	--TRACE ON;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet,'','', '';
			END IF;
		END EXCEPTION;
		
		LET v_sCodRet = '00000';
		LET v_iIdAsignado = 0;
		LET v_sDesAsignado = '';
		LET v_dFechaInsert = '';
		
		IF p_iIdAsignado = '' THEN
			LET p_iIdAsignado = NULL;
		END IF
		
		FOREACH
			SELECT idasignado, desasignado, fechainsert
			INTO v_iIdAsignado, v_sDesAsignado, v_dFechaInsert
			FROM bdirech:rec_catasignado
			WHERE idasignado = NVL(p_iIdAsignado, idasignado)
			
			RETURN v_sCodRet, v_iIdAsignado, v_sDesAsignado, v_dFechaInsert WITH RESUME;
		END FOREACH;
	END
END PROCEDURE
