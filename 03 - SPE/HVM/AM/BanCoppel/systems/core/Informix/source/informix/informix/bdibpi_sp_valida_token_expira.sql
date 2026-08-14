CREATE PROCEDURE "informix".sp_valida_token_expira(pEmpresa CHAR(3), pNumCte CHAR(9))
	RETURNING CHAR(5);

----------------------------------------------------------------------------------------------------------------------------------------
-- Realizó: Manuel Ramos Figueroa
-- Actividad: Valida si el cliente tiene un dispositivo token por expirar.
-- Solicitó: Walber Castro
-- Fecha de Solicitud: 23/12/2013
----------------------------------------------------------------------------------------------------------------------------------------

	DEFINE cCodRet		CHAR(5);
	DEFINE iSql_err		INTEGER;
	DEFINE cNS_token	CHAR(10);
	DEFINE bStatusSol	BOOLEAN;
	
	LET cCodRet			= '00000';
	LET iSql_err		= 0;
	LET cNS_token		= '';
	LET bStatusSol		= 'F';
	
  --SET DEBUG FILE TO "/home/informix/bibiana/sp_valida_token_expira.out";
  --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	
	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		
		SELECT ns_token 
		INTO cNS_token 
		FROM bdinteg:"informix".si_bpitoken 
		WHERE empresa = pEmpresa 
		AND num_cliente = pNumCte; 
		
		SELECT id_status_solicitud 
		INTO bStatusSol 
		FROM bdibpi:"informix".tkn_tokenexpira 
		WHERE numcte = pNumCte 
		AND ns_token = cNS_token;
		
		IF bStatusSol = 'T' THEN
			LET cCodRet = '00001';
		ELIF bStatusSol = 'F' THEN
			LET cCodRet = '00000';
		ELSE
			LET cCodRet = '00002';
		END IF;
		
		RETURN cCodRet;
	END
END PROCEDURE;