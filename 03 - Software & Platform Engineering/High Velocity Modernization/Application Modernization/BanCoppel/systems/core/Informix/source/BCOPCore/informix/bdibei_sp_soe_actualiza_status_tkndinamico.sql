CREATE PROCEDURE "informix".sp_soe_actualiza_status_tkndinamico(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pStatusToken INTEGER, pNsToken CHAR(10), pIdUsuario INTEGER)
	RETURNING CHAR(5) AS codret,
			INTEGER AS status;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iStatus INTEGER;
	DEFINE iExiste INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iStatus = 0;
	LET iExiste = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, pStatusToken;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_actualiza_status_tkndinamico.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pStatusToken = '' OR pNsToken = '' OR pIdUsuario = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, pStatusToken;
		END IF;
		
		-- ValidaciÃ³n de acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, pStatusToken;
		END IF;
		
		SELECT COUNT(*)
		INTO iExiste
		FROM bdibei:"informix".bei_token a, bdibei:"informix".bei_usuario b
		WHERE a.num_cliente = pNumCliente
			AND a.id_usuario = pIdUsuario
			AND b.num_cliente = a.num_cliente
			AND b.id_usuario = a.id_usuario;
			
		IF iExiste = 0 THEN
			LET cCodRet = '00053';
		ELSE
			IF pStatusToken = 160 THEN
				LET pStatusToken = 140;
			END IF;
			
			UPDATE bdibei:"informix".bei_token
			SET id_status_token = pStatusToken,
				f_status = CURRENT
			WHERE num_cliente = pNumCliente
				AND id_usuario = pIdUsuario
				AND ns_token = pNsToken;
			
		END IF;
		
		RETURN cCodRet, pStatusToken;
		
	END;
	
END PROCEDURE;