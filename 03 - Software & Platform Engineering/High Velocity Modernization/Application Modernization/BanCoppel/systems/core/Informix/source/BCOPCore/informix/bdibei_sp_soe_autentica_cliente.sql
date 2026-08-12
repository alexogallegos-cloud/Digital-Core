CREATE PROCEDURE "informix".sp_soe_autentica_cliente(pUsuario CHAR(8), pIdFuncion CHAR(10), pCodEmail CHAR(8), pAutenticar CHAR(1))
	RETURNING CHAR(5) AS codret, INTEGER AS regs_afectados;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegs SMALLINT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegs = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegs;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_autentica_cliente.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCodEmail = '' OR pAutenticar = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegs;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegs;
		END IF;
		
		IF pAutenticar NOT IN('0', '1') THEN
			LET cCodRet = '00049';
			RETURN cCodRet, iNoRegs;
		END IF;
		
		IF pAutenticar = '0' THEN
			LET pAutenticar = 'f';
		ELIF pAutenticar = '1' THEN
			LET pAutenticar = 't';
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		UPDATE bdibei:"informix".soe_codigo_email
		SET usu_autenticado = pAutenticar
		WHERE codigo_email = pCodEmail;
		
		LET iNoRegs = dbinfo('sqlca.sqlerrd2');
		
		RETURN cCodRet, iNoRegs;
	
	END;
	
END PROCEDURE;