CREATE PROCEDURE "informix".sp_ws_antad_login(pTokenId CHAR(32),pPassword CHAR(32))

RETURNING CHAR(5), CHAR(40);

--Definicion de Variables
DEFINE iSqlErr 	   INTEGER;
DEFINE iIsamError  INTEGER;
DEFINE cCodRet    CHAR(5);
DEFINE cDescipcion CHAR(40);
DEFINE cIdOper	   VARCHAR(6);
DEFINE cIdTran	   VARCHAR(6);

--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCodRet = '00000';
LET cDescipcion = 'Token Registrado Correctamente';
LET cIdOper = '0';
LET cIdTran = '0';



BEGIN
	ON EXCEPTION SET iSqlErr
		--SET DEBUG FILE TO '/tmp/cristo/sp_ws_antad_login.out';
		--TRACE ON;
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescipcion = 'Error al Registrar Token';
			
		END IF;
		
		RETURN cCodRet,cDescipcion;
		
	END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/cristo/sp_ws_antad_login.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--Se valida que alguno de los parametros de entrada no venga nulo

	IF NVL(pTokenId, '') = '' AND NVL(pPassword,'') THEN
		LET cCodRet = '00001';
		LET cDescipcion = 'Error. Parametros de entrada vacios.';

	ELSE

		FOREACH 
		
			SELECT id_tran INTO cIdTran 
			FROM "informix".mc_iac_transaccion 
			WHERE tran_iac in ('20087','20088')
			
			SELECT FIRST 1 id_oper INTO cIdOper FROM "informix".mc_operaciones WHERE id_tran=cIdTran;
			
			UPDATE "informix".mc_parametros SET valordefault=pTokenId 
			WHERE etiqueta='Token' AND tipo='E' AND id_oper =cIdOper;
			
			UPDATE "informix".mc_parametros SET valordefault=pPassword 
			WHERE etiqueta='Password' AND tipo='E' AND id_oper =cIdOper;
			
		END FOREACH;
		
		
	END IF;
	
	RETURN cCodRet,cDescipcion;
	
END;
END PROCEDURE;