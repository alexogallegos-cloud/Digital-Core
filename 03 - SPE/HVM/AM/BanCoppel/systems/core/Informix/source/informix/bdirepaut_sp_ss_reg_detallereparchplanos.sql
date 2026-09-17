CREATE PROCEDURE "informix".sp_ss_reg_detallereparchplanos(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, 
pPeriodicidad CHAR(1), pAutoridad CHAR(8), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codRet,
		CHAR(8) AS autoridad,
		CHAR(10) AS reporte,
		CHAR(100) AS descripcion,
		CHAR(10) AS desc_status,
		INTEGER AS id_registro;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cAutoridad CHAR(8);
	DEFINE cReporte CHAR(10);
	DEFINE cDescripcion CHAR(100);
	DEFINE cStatus CHAR(1);
	DEFINE cDescStatus CHAR(10);
	DEFINE iIdRegistro INTEGER;
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cAutoridad = '';
	LET cReporte = '';
	LET cDescripcion = '';
	LET cStatus = '';
	LET cDescStatus = '';
	LET iIdRegistro = 0;
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cAutoridad, cReporte, cDescripcion, cDescStatus, iIdRegistro;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ss_reg_detallereparchplanos.out';
		--TRACE ON;
		
		IF pFecha IS NULL OR pAutoridad = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cAutoridad, cReporte, cDescripcion, cDescStatus, iIdRegistro;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cAutoridad, cReporte, cDescripcion, cDescStatus, iIdRegistro;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		--EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		--IF cCodRet <> '00000' THEN
			--RETURN cCodRet, cAutoridad, cReporte, cDescripcion, cDescStatus, iIdRegistro;
		--END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF TRIM(UPPER(pAutoridad)) = 'OTROS' THEN
		
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion autoridad,reporte,descripcion,desc_status,id_serial
				INTO cAutoridad,cReporte,cDescripcion,cDescStatus,iIdRegistro
				FROM bdirepaut:"informix".sw_reg_reparchivosplanos
				WHERE usuario_proceso = pUsuario AND fecha_proceso = pFecha
				AND TRIM(UPPER(autoridad)) <> 'CNBV' AND TRIM(UPPER(autoridad)) <> 'BANXICO'
				ORDER BY id_serial ASC
			
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, TRIM(UPPER(cAutoridad)), TRIM(UPPER(cReporte)), TRIM(UPPER(cDescripcion)), cDescStatus, iIdRegistro WITH RESUME;	
			END FOREACH;
			
		ELSE
		
			FOREACH
			
				SELECT SKIP pRegistros FIRST pRecuperacion autoridad,reporte,descripcion,desc_status,id_serial
				INTO cAutoridad,cReporte,cDescripcion,cDescStatus,iIdRegistro
				FROM bdirepaut:"informix".sw_reg_reparchivosplanos
				WHERE usuario_proceso = pUsuario AND fecha_proceso = pFecha
				AND TRIM(UPPER(autoridad)) = TRIM(UPPER(pAutoridad))
				ORDER BY id_serial ASC
			
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, TRIM(UPPER(cAutoridad)), TRIM(UPPER(cReporte)), TRIM(UPPER(cDescripcion)), cDescStatus, iIdRegistro WITH RESUME;	
			END FOREACH;
			
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00091';
			RETURN cCodRet, cAutoridad, cReporte, cDescripcion, cDescStatus, iIdRegistro;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cAutoridad, cReporte, cDescripcion, cDescStatus, iIdRegistro;
		END IF;
		
	END;
END PROCEDURE
