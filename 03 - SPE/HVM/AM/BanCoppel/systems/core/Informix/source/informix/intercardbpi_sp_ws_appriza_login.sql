CREATE PROCEDURE "informix".sp_ws_appriza_login(pTokenId CHAR(80))

RETURNING CHAR(5), CHAR(100);

--Definicion de Variables
DEFINE iSqlErr 	   INTEGER;
DEFINE iIsamError  INTEGER;
DEFINE cCodRet    CHAR(5);
DEFINE cDescipcion CHAR(100);
DEFINE cIdOper	   INTEGER;


--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCodRet = '00000';
LET cDescipcion = 'Consulta Exitosa.';
LET cIdOper = 0;



BEGIN
	ON EXCEPTION SET iSqlErr
		--SET DEBUG FILE TO '/tmp/cristo/sp_ws_afore_cctes.out';
		--TRACE ON;
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescipcion = '';
			
		END IF;
		
		RETURN cCodRet,cDescipcion;
		
	END EXCEPTION;

	--log
	--SET DEBUG FILE TO '/tmp/cristo/sp_ws_afore_ctes.out';
	--TRACE ON;

	SET LOCK MODE TO WAIT 10;

	--Se valida que alguno de los parametros de entrada no venga nulo

	IF NVL(pTokenId, '') = '' THEN
		LET cCodRet = '00001';
		LET cDescipcion = 'Error. Parametros de entrada vacios.';

	ELSE
	
		UPDATE "informix".mc_parametros SET valordefault=pTokenId 
		WHERE etiqueta='TokenId' AND tipo='E'
		AND id_oper IN (SELECT id_oper FROM "informix".mc_operaciones WHERE id_ws='5');
		
	END IF;
	
	RETURN cCodRet,cDescipcion;
	
END;
END PROCEDURE;