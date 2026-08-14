CREATE PROCEDURE "informix".spconsultarcatconcepto (p_iIdConcepto SMALLINT)
RETURNING CHAR(5) AS CodigoRetorno, SMALLINT AS IdConcepto, CHAR(80) AS DesConcepto,  DATE AS FechaInsert
	
	DEFINE iSqlErr			INTEGER;

	DEFINE v_sCodRet       	CHAR(5);
	DEFINE v_iIdConcepto	SMALLINT;
	DEFINE v_sDesConcepto	CHAR(80);
	DEFINE v_dFechaInsert	DATE;
	
	--SET DEBUG FILE TO "/tmp/Vladi/spconsultarcatconcepto.out"; 
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
		LET v_iIdConcepto = 0;
		LET v_sDesConcepto = '';
		LET v_dFechaInsert = '';
		
		IF p_iIdConcepto = '' THEN
			LET p_iIdConcepto = NULL;
		END IF
		
		FOREACH
			SELECT idconcepto, desconcepto, fechainsert
			INTO v_iIdConcepto, v_sDesConcepto, v_dFechaInsert
			FROM bdirech:rec_catconcepto
			WHERE idconcepto = NVL(p_iIdConcepto, idconcepto)
			
			RETURN v_sCodRet, v_iIdConcepto, v_sDesConcepto, v_dFechaInsert WITH RESUME;
		END FOREACH;
	END
END PROCEDURE
