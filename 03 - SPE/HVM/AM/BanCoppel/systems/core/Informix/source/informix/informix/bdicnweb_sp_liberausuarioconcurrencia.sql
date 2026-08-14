CREATE PROCEDURE "informix".sp_liberausuarioconcurrencia(pIdSession char(40))
	returning CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cStatusFuncionalidad CHAR(1);
	DEFINE iSqlErr INT;
	
	LET cCodRet = '00000';
	LET cStatusFuncionalidad = '';
	LET iSqlErr = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		IF pIdSession = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		IF LENGTH(pIdSession) < 30 THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		SET LOCK MODE TO WAIT;		
		UPDATE sw_tr_concurrencia
		SET status_acceso = '0',
			usuario = '',
			id_session = ''
		WHERE id_session = pIdSession;
			
		RETURN cCodRet;
			
	END;
END PROCEDURE;