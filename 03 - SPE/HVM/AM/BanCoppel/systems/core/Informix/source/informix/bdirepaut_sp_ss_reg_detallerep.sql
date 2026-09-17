CREATE PROCEDURE "informix".sp_ss_reg_detallerep(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, 
pPeriodicidad CHAR(1), pAutoridad CHAR(8), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codRet,
		CHAR(8) AS autoridad,
		CHAR(10) AS reporte,
		CHAR(100) AS descripcion,
		CHAR(9) AS desc_status,
		CHAR(1) AS bandera;
	
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
	DEFINE cBandera CHAR(1);
	DEFINE cDescStatus CHAR(9);
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
	LET cBandera = '';
	LET cDescStatus = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cAutoridad, cReporte, cDescripcion, cDescStatus, cBandera;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ss_reg_detallerep.out';
		--TRACE ON;
		
		IF pFecha IS NULL OR pAutoridad = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cAutoridad, cReporte, cDescripcion, cDescStatus, cBandera;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cAutoridad, cReporte, cDescripcion, cDescStatus, cBandera;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		--EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		--IF cCodRet <> '00000' THEN
			--RETURN cCodRet, cAutoridad, cReporte, cDescripcion, cDescStatus, cBandera;
		--END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF TRIM(UPPER(pAutoridad)) = 'OTROS' THEN
		
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion r.identautoridad, r.clavereporte, r.descripreporte, p.statusproceso
				INTO cAutoridad, cReporte, cDescripcion, cStatus
				FROM bdirepaut:"informix".sp_clavesreportes AS r, bdirepaut:"informix".sp_controlproceso AS p
				WHERE r.identautoridad = p.identautoridad
				AND r.empresa = p.empresa
				AND r.clavereporte = p.clavereporte
				AND r.empresa = '001'
				AND p.fechacontroldia = pFecha
				AND TRIM(UPPER(p.identautoridad)) <> 'BANXICO' AND TRIM(UPPER(p.identautoridad)) <> 'CNBV' 
				AND r.claveperiodicidad = (CASE WHEN pPeriodicidad = '' THEN r.claveperiodicidad ELSE pPeriodicidad END)
				AND p.statusproceso IN('P', 'R')
				ORDER BY r.clavereporte
			
				IF NVL(cReporte,'') = 'OCIMND' THEN
					LET cBandera = '1';				
				ELIF NVL(cReporte,'') = 'OCIMNM' THEN 
					LET cBandera = '2';
				ELSE 
					LET cBandera = '';
				END IF;
				
				IF NVL(cStatus,'') = 'P' THEN
					LET cDescStatus = 'PENDIENTE';				
				ELSE 
					LET cDescStatus = 'REPROCESO';
				END IF;
			
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, TRIM(UPPER(cAutoridad)), TRIM(UPPER(cReporte)), TRIM(UPPER(cDescripcion)), cDescStatus, cBandera WITH RESUME;	
			END FOREACH;
			
		ELSE
		
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion r.identautoridad, r.clavereporte, r.descripreporte, p.statusproceso
				INTO cAutoridad, cReporte, cDescripcion, cStatus
				FROM bdirepaut:"informix".sp_clavesreportes AS r, bdirepaut:"informix".sp_controlproceso AS p
				WHERE r.identautoridad = p.identautoridad
				AND r.empresa = p.empresa
				AND r.clavereporte = p.clavereporte
				AND r.empresa = '001'
				AND p.fechacontroldia = pFecha
				AND TRIM(UPPER(p.identautoridad)) = TRIM(UPPER(pAutoridad))
				AND r.claveperiodicidad = (CASE WHEN pPeriodicidad = '' THEN r.claveperiodicidad ELSE pPeriodicidad END)
				AND p.statusproceso IN('P', 'R')
				ORDER BY r.clavereporte
			
				IF NVL(cReporte,'') = 'OCIMND' THEN
					LET cBandera = '1';				
				ELIF NVL(cReporte,'') = 'OCIMNM' THEN 
					LET cBandera = '2';
				ELSE 
					LET cBandera = '';
				END IF;
				
				IF NVL(cStatus,'') = 'P' THEN
					LET cDescStatus = 'PENDIENTE';				
				ELSE 
					LET cDescStatus = 'REPROCESO';
				END IF;
			
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, TRIM(UPPER(cAutoridad)), TRIM(UPPER(cReporte)), TRIM(UPPER(cDescripcion)), cDescStatus, cBandera WITH RESUME;	
			END FOREACH;
			
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00091';
			RETURN cCodRet, cAutoridad, cReporte, cDescripcion, cDescStatus, cBandera;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cAutoridad, cReporte, cDescripcion, cDescStatus, cBandera;
		END IF;
		
	END;
END PROCEDURE
