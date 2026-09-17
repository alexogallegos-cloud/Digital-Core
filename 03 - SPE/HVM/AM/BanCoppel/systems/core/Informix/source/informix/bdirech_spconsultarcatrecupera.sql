CREATE PROCEDURE "informix".spconsultarcatrecupera (p_iIdRecupera SMALLINT)
RETURNING CHAR(5) AS CodigoRetorno, SMALLINT AS IdRecupera, CHAR(80) AS DesRecupera, DATE AS FechaInsert
	
	DEFINE iSqlErr			INTEGER;

	DEFINE v_sCodRet       	CHAR(5);
	DEFINE v_iIdRecupera	SMALLINT;
	DEFINE v_sDesRecupera	CHAR(80);
	DEFINE v_dFechaInsert	DATE;
	
	--SET DEBUG FILE TO "/tmp/spconsultarcatrecupera.out"; 
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
		
		IF NVL(p_iIdRecupera,'') = '' THEN
			LET p_iIdRecupera = NULL;
		END IF
		
		FOREACH
			SELECT idrecupera, desrecupera, fechainsert
			INTO v_iIdRecupera, v_sDesRecupera, v_dFechaInsert
			FROM bdirech:rec_catrecupera
			WHERE idrecupera = NVL(p_iIdRecupera, idrecupera)
			ORDER BY idrecupera
			
			RETURN v_sCodRet, v_iIdRecupera, v_sDesRecupera, v_dFechaInsert WITH RESUME;
		END FOREACH;
	END
END PROCEDURE
