CREATE PROCEDURE "informix".sp_ss_reg_verificastatusrep(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  CHAR(100) AS path_file,
			  CHAR(50) AS nombre_file,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cPathFile CHAR(100);
	DEFINE cNomFile CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cPathFile = '';
	LET cNomFile = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = iSqlErr;
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,cPathFile,cNomFile,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ss_reg_verificastatusrep.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		--IF pUsuario = '' OR pIdFuncion = '' THEN
			--LET cCodRet = '00003';
			--RETURN cCodRet,cStatus,cPathFile,cNomFile,cErrorProceso,cError;	
		--END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		--EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		--IF cCodRet <> '00000' THEN
			--RETURN cCodRet,cStatus,cPathFile,cNomFile,cErrorProceso,cError;
		--END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT status,path_file,nombre_file,error_proceso,error
		INTO cStatus,cPathFile,cNomFile,cErrorProceso,cError
		FROM bdirepaut:"informix".sw_reg_statusproceso WHERE usuario = TRIM(pUsuario);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,cPathFile,cNomFile,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
