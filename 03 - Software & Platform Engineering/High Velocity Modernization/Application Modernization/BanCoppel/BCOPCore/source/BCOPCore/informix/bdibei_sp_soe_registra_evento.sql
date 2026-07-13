CREATE PROCEDURE "informix".sp_soe_registra_evento(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pNoIdentificacion CHAR(30), pEmailAlterno CHAR(50), pCodEmail CHAR(8))
	RETURNING CHAR(5) AS codret

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dFechaMail DATETIME YEAR TO SECOND;
	DEFINE eMailAlterno CHAR(50);
	DEFINE vnumgenerico CHAR(20);
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dFechaMail = NULL;
	LET eMailAlterno = '';
	LET vnumgenerico = '000000000';
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_registra_evento.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pNoIdentificacion = '' OR pCodEmail = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		-- EjecuciÃ³n del correo que se enviara
		LET dFechaMail = current;
		
		EXECUTE FUNCTION bdimnsj:"informix".sp_registra_evento
			('1'
			, 'SOE_CODAUT'
			, TRIM(vnumgenerico)
			,''
			,''
			,'1'
			, TRIM(pNoIdentificacion)
			, TRIM(pCodEmail)
			,''
			,''
			,''
			,''
			,''
			,''
			,''
			,''
			,TRIM(pEmailAlterno)
			,''
			,'1'
			,'0'
			,'0'
			,'0'
			,'0'
			,dFechaMail
			,dFechaMail) INTO cCodRet;
			
		RETURN cCodRet;
	
	END;
	
	
END PROCEDURE;