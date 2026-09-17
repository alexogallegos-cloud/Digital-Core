CREATE PROCEDURE "informix".sp_sac_verificastatusgridrepventanilla(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
		INTEGER AS total,
		CHAR(15) AS proceso;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cBanDetError CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iTotal INTEGER;
	DEFINE iProcesados INTEGER;
	DEFINE iNoProcesados INTEGER;
	DEFINE cProceso CHAR(15);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cBanDetError = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iTotal = 0;
	LET iProcesados = 0;
	LET iNoProcesados = 0;
	LET cProceso='';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,cErrorProceso,cError,iTotal,cProceso;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_verificastatusarchivo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cErrorProceso,cError,iTotal,cProceso;
		END IF;		
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cErrorProceso,cError,iTotal,cProceso;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status,error_proceso,error,total_registros,tipo_proceso
		INTO cStatus,cErrorProceso,cError,iTotal,cProceso
		FROM "informix".sw_sac_reporteventanillagrid
		WHERE usuario = TRIM(pUsuario);
		
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			RETURN cCodRet,'I','','','',0;
		ELSE 			
			RETURN cCodRet,cStatus,cErrorProceso,cError,iTotal,cProceso;
		END IF;	
		
	END;
END PROCEDURE;