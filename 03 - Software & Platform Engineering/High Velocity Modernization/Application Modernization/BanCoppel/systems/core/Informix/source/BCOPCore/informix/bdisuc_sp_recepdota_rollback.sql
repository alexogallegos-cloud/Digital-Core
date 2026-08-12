CREATE PROCEDURE "informix".sp_recepdota_rollback(pFolio CHAR(8))
RETURNING CHAR(5);

DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;

LET cCodret	= '00000';
LET iSqlErr = 0;

--SET DEBUG FILE TO '/informix/jepolanco/sp_recepdota_rollback.out';
--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN  cCodRet;
			END IF;
		END EXCEPTION;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		UPDATE bdisuc:"informix".ss_mae_entradasalida SET status = '11' WHERE folio_oper = pFolio;
		
		RETURN cCodRet;
	END
END PROCEDURE;