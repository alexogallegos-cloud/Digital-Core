CREATE PROCEDURE "informix".spvalidarprocesos (p_dFechaProceso DATE, p_iIdProceso SMALLINT)

	RETURNING CHAR(5) AS retorno, CHAR(2) AS Estatus, INTEGER AS CantErrores;

	DEFINE iSqlErr			INTEGER;
	DEFINE v_sValRetorno	CHAR(5);
	DEFINE v_sDescproceso	CHAR(40);
	DEFINE v_sEstatus	    CHAR(2);
	DEFINE v_iErrores		INTEGER;
	
	-----------------------------------------------------------------------
	--SET DEBUG FILE TO "/tmp/prisma/spvalidarprocesos.out"; ";
	--TRACE ON;
	-----------------------------------------------------------------------

	LET v_sValRetorno = '00000';	
	LET v_sEstatus = 0;
	LET v_iErrores = 0;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sValRetorno = iSqlErr;
				RETURN v_sValRetorno, '','';
			END IF;
		END EXCEPTION;
		
		--LOS PARAMETROS NO DEBEN SER NULOS
			IF NVL(p_dFechaProceso,'')='' OR NVL(p_iIdProceso,'')='' THEN
				LET v_sValRetorno = '00001';	
				RETURN v_sValRetorno, '','';
			END IF;
			
			SELECT estatus INTO v_sEstatus FROM bdirech:rec_procesos WHERE fechaproceso = p_dFechaProceso AND idprocesos = p_iIdProceso;
			SELECT COUNT(*) INTO v_iErrores FROM bdirech:rec_errores;
							
			IF v_sEstatus IS NULL THEN			
				LET v_sValRetorno = '00002';
				LET v_sEstatus = '-1';			
			END IF 
	
		RETURN v_sValRetorno,v_sEstatus, v_iErrores;
	END;    	
				
END PROCEDURE 
