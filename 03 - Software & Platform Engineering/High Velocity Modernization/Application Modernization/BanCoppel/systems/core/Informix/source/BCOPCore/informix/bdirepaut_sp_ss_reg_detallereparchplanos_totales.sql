CREATE PROCEDURE "informix".sp_ss_reg_detallereparchplanos_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, 
pPeriodicidad CHAR(1), pAutoridad CHAR(8))
    RETURNING CHAR(5) AS codRet,
		INTEGER AS num_registros;

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
	DEFINE iNumRegistros INTEGER;
	
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
	LET iNumRegistros = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iNumRegistros;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ss_reg_detallereparchplanos_totales.out';
		--TRACE ON;
		
		IF pFecha IS NULL OR pAutoridad = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		--EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		--IF cCodRet <> '00000' THEN
			--RETURN cCodRet, iNumRegistros;
		--END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM bdirepaut:"informix".sw_reg_reparchivosplanos WHERE usuario_proceso = TRIM(pUsuario);
			
		IF TRIM(UPPER(pAutoridad)) = 'OTROS' THEN
		
			INSERT INTO bdirepaut:"informix".sw_reg_reparchivosplanos(autoridad,reporte,descripcion,desc_status,usuario_proceso,fecha_proceso)
			SELECT r.identautoridad,r.clavereporte,r.descripreporte,(CASE WHEN p.statusproceso = 'S' THEN 'SATISFECHO' ELSE p.statusproceso END),
			pUsuario,pFecha
			FROM bdirepaut:"informix".sp_clavesreportes AS r, bdirepaut:"informix".sp_controlproceso AS p
			WHERE r.identautoridad = p.identautoridad
			AND r.empresa = '001'
			AND r.empresa = p.empresa
			AND r.clavereporte = p.clavereporte
			AND r.claveperiodicidad = (CASE WHEN pPeriodicidad = '' THEN r.claveperiodicidad ELSE pPeriodicidad END)
			AND p.fechacontroldia = pFecha
			AND p.empresa = '001'
			AND p.statusproceso IN('S')
			AND TRIM(UPPER(p.identautoridad)) <> 'CNBV' AND TRIM(UPPER(p.identautoridad)) <> 'BANXICO'
			ORDER BY r.clavereporte;

			SELECT COUNT(*) INTO iNumRegistros
			FROM bdirepaut:"informix".sw_reg_reparchivosplanos
			WHERE usuario_proceso = pUsuario AND fecha_proceso = pFecha
			AND TRIM(UPPER(autoridad)) <> 'CNBV' AND TRIM(UPPER(autoridad)) <> 'BANXICO';
			
		ELSE
		
			INSERT INTO bdirepaut:"informix".sw_reg_reparchivosplanos(autoridad,reporte,descripcion,desc_status,usuario_proceso,fecha_proceso)
			SELECT r.identautoridad,r.clavereporte,r.descripreporte,(CASE WHEN p.statusproceso = 'S' THEN 'SATISFECHO' ELSE p.statusproceso END),
			pUsuario,pFecha
			FROM bdirepaut:"informix".sp_clavesreportes AS r, bdirepaut:"informix".sp_controlproceso AS p
			WHERE r.identautoridad = p.identautoridad
			AND r.empresa = '001'
			AND r.empresa = p.empresa
			AND r.clavereporte = p.clavereporte
			AND r.claveperiodicidad = (CASE WHEN pPeriodicidad = '' THEN r.claveperiodicidad ELSE pPeriodicidad END)
			AND p.fechacontroldia = pFecha
			AND p.empresa = '001'
			AND p.statusproceso IN('S')
			AND TRIM(UPPER(p.identautoridad)) = TRIM(UPPER(pAutoridad))
			ORDER BY r.clavereporte;
			
			SELECT COUNT(*) INTO iNumRegistros
			FROM bdirepaut:"informix".sw_reg_reparchivosplanos
			WHERE usuario_proceso = pUsuario AND fecha_proceso = pFecha
			AND TRIM(UPPER(autoridad)) = TRIM(UPPER(pAutoridad));
			
		END IF;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00091';
		END IF;
		
		RETURN cCodRet, NVL(iNumRegistros,0);
		
	END;
END PROCEDURE
