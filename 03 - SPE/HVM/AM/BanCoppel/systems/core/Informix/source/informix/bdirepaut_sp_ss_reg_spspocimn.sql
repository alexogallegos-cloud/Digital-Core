CREATE PROCEDURE "informix".sp_ss_reg_spspocimn(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, pBandera CHAR(1))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(255);
	DEFINE cEmpresa CHAR(3);
	DEFINE cTipo CHAR(1);
	DEFINE cBandera CHAR(1);
	DEFINE cDescStatus CHAR(9);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cTipo = '';
	LET cBandera = '';
	LET cDescStatus = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ss_reg_spspocimn.out';
		--TRACE ON;
		
		IF pFecha IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		--EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		--IF cCodRet <> '00000' THEN
		--	RETURN cCodRet;
		--END IF;
		
		IF NVL(pBandera,'') = '1' THEN
			LET cTipo = 'D';
		ELIF NVL(pBandera,'') = '2' THEN
			LET cTipo = 'M';
		END IF;	
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		EXECUTE PROCEDURE bdirepaut:"informix".spsp_ocimn(pFecha,cEmpresa,cTipo)
		INTO cCodRetSp,cDescCodRetSp;
	
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdirepaut:spsp_ocimn';
		ELIF cCodRetSp::INTEGER = 1 THEN 
			LET cCodRet = '00003'; 
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
