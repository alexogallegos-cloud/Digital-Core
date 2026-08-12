CREATE PROCEDURE "informix".sp_ss_reg_catperiodaut(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1))
    RETURNING CHAR(5) AS codRet,
		CHAR(2) AS clave,
		CHAR(50) AS descripcion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cClave CHAR(2);
	DEFINE cDescripcion CHAR(50);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cClave = '';
	LET cDescripcion = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cClave, cDescripcion;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ss_reg_catperiodaut.out';
		--TRACE ON;
		
		IF pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		--EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		--IF cCodRet <> '00000' THEN
			--RETURN cCodRet, cClave, cDescripcion;
		--END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pIdConsulta = '1' THEN
		
			FOREACH
				SELECT claveperiodicidad, descripperiodicida 
				INTO cClave, cDescripcion
				FROM bdirepaut:"informix".sp_periodicidad 
				WHERE empresa = '001' ORDER BY claveperiodicidad, descripperiodicida
				
				RETURN cCodRet, TRIM(cClave), TRIM(UPPER(cDescripcion)) WITH RESUME;	
			END FOREACH;
		
			IF NVL(cClave,'') = '' THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cClave, cDescripcion;
			END IF;
		
		ELIF pIdConsulta = '2' THEN
		
			FOREACH
				SELECT id_autoridad, desc_autoridad 
				INTO cClave, cDescripcion
				FROM bdirepaut:"informix".sw_reg_catautoridad ORDER BY desc_autoridad ASC
				
				RETURN cCodRet, TRIM(cClave), TRIM(UPPER(cDescripcion)) WITH RESUME;	
			END FOREACH;
		
			IF NVL(cClave,'') = '' THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cClave, cDescripcion;
			END IF;
		
		END IF;
		
	END;
END PROCEDURE
