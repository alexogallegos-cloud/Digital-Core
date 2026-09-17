CREATE PROCEDURE "informix".sp_ctepr_actbanparametrico(pNumcte CHAR(20),pBanParam CHAR(1))

RETURNING CHAR(6) AS CodRet;

	-- DECLARACION DE VARIABLES
	DEFINE cCodRet 			CHAR(6);
	DEFINE iSqlerr			INTEGER;

	-- INICIALIZA VARIABLES
	LET cCodRet = '000000';
	

	
	BEGIN
		ON EXCEPTION SET iSqlerr
			IF iSqlerr != 0 THEN
				LET cCodret = iSqlerr;
				RETURN cCodret;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;  	
		
		--SET DEBUG FILE TO '/dbexportb/marioolivo/sp_ctepr_actbanparametrico.out';
		--TRACE ON;
		
		--VALIDA PARAMETROS
		IF NVL(pNumcte,'')= '' OR  NVL(pBanParam,'')= '' THEN
			LET cCodRet = '000001';
		END IF 
		
		IF cCodret::INTEGER = 0 THEN
			UPDATE "informix".pr_cliente SET envio_parametrico = pBanParam
			WHERE empresa = '001'
			AND numcte_pros = TRIM(pNumcte);
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodret = '000002'; --NO ACTUALIZO LA BANDERA DEL PARAMETRICO
			END IF;
		END IF;
		
		RETURN cCodret;
		
	END;
END PROCEDURE
