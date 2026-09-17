CREATE PROCEDURE "informix".sp_blqconsultabloqueocap(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pTipoMov CHAR(1))
	RETURNING CHAR(5) AS codret,
			CHAR(5) AS codretsp,
			CHAR(50) AS desc_bloqueo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE cDesBloqueo CHAR(50);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDesBloqueo = '';
	LET iSqlErr = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodRetSp, cDesBloqueo;
		END EXCEPTION;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pTipoMov = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodRetSp, cDesBloqueo;
		END IF;
		
		IF pTipoMov NOT IN ('D', 'B') THEN
			LET cCodRet = '00005';
			RETURN cCodRet, cCodRetSp, cDesBloqueo;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodRetSp, cDesBloqueo;
		END IF;
		
		-- Busqueda del estatus de la cuenta
		EXECUTE PROCEDURE bdicheq:sp_blqvalbloqueocta(pCuenta) INTO cCodRetSp, cDesBloqueo;
		
		IF pTipoMov = 'B' THEN
			IF cCodRetSp = '10000' THEN
				LET cCodRet = '00173';
			END IF;
		ELIF pTipoMov = 'D' THEN
			IF cCodRetSp <> '10000' THEN
				LET cCodRet = '00172';
			END IF;
		END IF;
		
		RETURN cCodRet, cCodRetSp, cDesBloqueo;
		
	END;
	
END PROCEDURE;