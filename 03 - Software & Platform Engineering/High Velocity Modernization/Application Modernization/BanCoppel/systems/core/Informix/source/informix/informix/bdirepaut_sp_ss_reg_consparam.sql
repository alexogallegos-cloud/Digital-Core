CREATE PROCEDURE "informix".sp_ss_reg_consparam(pUsuario CHAR(8), pIdFuncion CHAR(10), pClave INTEGER)
    RETURNING CHAR(5) AS codRet,
		CHAR(255) AS valor_param;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cValorParam CHAR(255);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cValorParam = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cValorParam;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ss_reg_consparam.out';
		--TRACE ON;
		
		IF pClave IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cValorParam;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		--EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		--IF cCodRet <> '00000' THEN
			--RETURN cCodRet, cValorParam;
		--END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT valorparam INTO cValorParam
		FROM bdirepaut:"informix".sp_param WHERE empresa = '001' AND claveparam = pClave;
		
		IF NVL(cValorParam,'') = '' THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, TRIM(cValorParam);
		
	END;
END PROCEDURE
