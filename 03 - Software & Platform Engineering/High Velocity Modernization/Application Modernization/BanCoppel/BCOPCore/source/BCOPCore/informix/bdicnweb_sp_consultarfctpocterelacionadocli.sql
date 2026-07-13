CREATE PROCEDURE "informix".sp_consultarfctpocterelacionadocli(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20))
	RETURNING CHAR(5) AS codret,
			CHAR(13) AS rfc,
			CHAR(13) AS rfc_alterno,
			SMALLINT AS tipo_relacion_cliente;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cRfc CHAR(13);
	DEFINE cRfcAlterno CHAR(13);
	DEFINE iTipoRelacionCliente SMALLINT;
	DEFINE iExiste INTEGER;
	
	LET cCodRet = '';
	LET iSqlErr = 0;
	LET cRfc = '';
	LET cRfcAlterno = '';
	LET iTipoRelacionCliente = 0;	
	LET iExiste = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cRfc, cRfcAlterno, iTipoRelacionCliente;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarfctpocterelacionadocli.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cRfc, cRfcAlterno, iTipoRelacionCliente;
		END IF;
		
		-- ValidaciÃ³n de acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cRfc, cRfcAlterno, iTipoRelacionCliente;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = pNumCliente;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00053';
			RETURN cCodRet, cRfc, cRfcAlterno, iTipoRelacionCliente;
		END IF;
		
		SELECT rfc, rfc_alterno, numeric2
		INTO cRfc, cRfcAlterno, iTipoRelacionCliente
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = pNumCliente;
		
		RETURN cCodRet, cRfc, cRfcAlterno, iTipoRelacionCliente;
	
	END;
			
END PROCEDURE;