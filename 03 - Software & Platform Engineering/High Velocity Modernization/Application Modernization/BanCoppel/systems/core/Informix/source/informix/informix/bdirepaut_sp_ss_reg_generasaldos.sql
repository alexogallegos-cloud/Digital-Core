CREATE PROCEDURE "informix".sp_ss_reg_generasaldos(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, pPeriodicidad CHAR(1))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(255);
	DEFINE cEmpresa CHAR(3);
	DEFINE cAutoridad CHAR(8);
	DEFINE cReporte CHAR(10);
	DEFINE cDescripcion CHAR(100);
	DEFINE cStatus CHAR(1);
	DEFINE cBandera CHAR(1);
	DEFINE cDescStatus CHAR(9);
	DEFINE iRecuperacion INTEGER;
	DEFINE bInTransaction BOOLEAN;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cAutoridad = '';
	LET cReporte = '';
	LET cDescripcion = '';
	LET cStatus = '';
	LET cBandera = '';
	LET cDescStatus = '';
	LET iRecuperacion = 0;
	LET bInTransaction = 'f';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				SET LOCK MODE TO WAIT 3;
				UPDATE bdirepaut:"informix".sw_reg_verificaproceso
				SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-284)
			LET cCodRet = '00919'; --EXISTE MÁS DE UN REPORTE A GENERAR. VERIFIQUE
			SET LOCK MODE TO WAIT 3;
			UPDATE bdirepaut:"informix".sw_reg_verificaproceso
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RETURN cCodRet;
	    END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-668, -535, -255, -958)
			LET bInTransaction = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ss_reg_generasaldos.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdirepaut:"informix".sw_reg_verificaproceso WHERE usuario = TRIM(pUsuario);
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		SET LOCK MODE TO WAIT 3; 
		INSERT INTO bdirepaut:"informix".sw_reg_verificaproceso(usuario,status,error_proceso,error)
		VALUES(pUsuario,'I','',TRIM(cCodRet));  
		
		IF pFecha IS NULL THEN
			LET cCodRet = '00003';
			SET LOCK MODE TO WAIT 3;
			UPDATE bdirepaut:"informix".sw_reg_verificaproceso
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		--EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		--IF cCodRet <> '00000' THEN
		--	SET LOCK MODE TO WAIT 3;
		--	UPDATE bdirepaut:"informix".sw_reg_verificaproceso
		--	SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
		--	RETURN cCodRet;
		--END IF;
		
		BEGIN WORK;
		IF bInTransaction = 'f' THEN
			COMMIT WORK;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 6;
	
		EXECUTE PROCEDURE bdirepaut:"informix".spsp_generasaldos(cEmpresa,pFecha,pPeriodicidad)
		INTO cCodRetSp,cDescCodRetSp;
	
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdirepaut:spsp_generasaldos';
		ELIF cCodRetSp::INTEGER <> 0 THEN 
			LET cCodRet = '00918'; --EL PROCESO DE GENERACIÓN NO PUDO SER COMPLETADO, INTENTE NUEVAMENTE
			SET LOCK MODE TO WAIT 3;
			UPDATE bdirepaut:"informix".sw_reg_verificaproceso
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RETURN cCodRet;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		UPDATE bdirepaut:"informix".sw_reg_verificaproceso
		SET status = 'T', error_proceso = '', error = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
