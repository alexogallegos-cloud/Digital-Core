CREATE PROCEDURE "informix".spconsultarcatestatus (p_iIdEstatus SMALLINT)
RETURNING CHAR(5) AS CodigoRetorno, SMALLINT AS IdEstatus, CHAR(80) AS DesEstatus, DATE AS FechaInsert
	
	DEFINE iSqlErr			INTEGER;

	DEFINE v_sCodRet       	CHAR(5);
	DEFINE v_iIdEstatus		SMALLINT;
	DEFINE v_sDesEstatus	CHAR(80);
	DEFINE v_dFechaInsert	DATE;
	
	--SET DEBUG FILE TO "/tmp/spconsultarcatestatus.out"; 
	--TRACE ON;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet,'','','';
			END IF;
		END EXCEPTION;
		
		LET v_sCodRet = '00000';				
		
		IF NVL(p_iIdEstatus,'') = '' THEN
			LET p_iIdEstatus = NULL;
		END IF
		
		FOREACH
			SELECT idestatus, desestatus, fechainsert
			INTO v_iIdEstatus, v_sDesEstatus, v_dFechaInsert
			FROM bdirech:rec_catestatus
			WHERE idestatus = NVL(p_iIdEstatus, idestatus)
			ORDER BY idestatus
			
			RETURN v_sCodRet, v_iIdEstatus, v_sDesEstatus, v_dFechaInsert WITH RESUME;
		END FOREACH;
	END
END PROCEDURE
