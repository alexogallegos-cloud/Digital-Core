CREATE PROCEDURE "informix".sp_wu_reasoncode(pbanderareversion VARCHAR(1))

	RETURNING VARCHAR(5) AS iCodRet, VARCHAR(50) as iMensaje, VARCHAR(3) as iReasonCode,VARCHAR(70) AS iReasonDesc;

	DEFINE iCodRet 				VARCHAR(5);
	DEFINE iMensaje				VARCHAR(50);
	DEFINE iSqlErr 				INTEGER;
	DEFINE cBanderaReversion 	VARCHAR(1);
	DEFINE cReasonCode			VARCHAR(3);
	DEFINE cReasonDesc			VARCHAR(70);
	DEFINE cEstatusReasoncode	VARCHAR(1);
	
	--SET DEBUG FILE TO '/home/sysifx/HMLG/sp_confpago_remesa.out';
	--TRACE ON;
		
	LET iCodRet = "00000";
	LET iMensaje = '';
	LET iSqlErr = 0;
	LET cBanderaReversion = '';
	LET cReasonCode = '';
	LET cReasonDesc = '';
	LET cEstatusReasoncode = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF (iSqlErr != 0) THEN
				LET iCodRet = iSqlErr;
				LET iMensaje = "Ejecucion NO Exitosa Error BD";
				RETURN iCodRet,iMensaje,cReasonCode,cReasonDesc;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		LET cBanderaReversion = pbanderareversion;
		
		IF cBanderaReversion = 'A' THEN
		
			SELECT FIRST 1 reasoncode, reasondesc 
			INTO cReasonCode, cReasonDesc
			FROM sac_wu_reasoncode
			WHERE banderareversion = 'A'
			AND estatusreasoncode = 'A';
			
			LET iMensaje = "Ejecucion SP reasoncode Exitosa";
		
		ELIF cBanderaReversion = 'M' THEN
		
			SELECT FIRST 1 reasoncode, reasondesc 
			INTO cReasonCode, cReasonDesc
			FROM sac_wu_reasoncode
			WHERE banderareversion = 'M'
			AND estatusreasoncode = 'A';
			
			LET iMensaje = "Ejecucion SP reasoncode Exitosa";
		
		ELSE 
			LET iCodRet = "00001";				
			LET iMensaje =  "BanderaReversion Ingresada NO Valida";
		END IF;
			
		RETURN iCodRet,iMensaje,cReasonCode,cReasonDesc;
		
	END;

END PROCEDURE;