CREATE PROCEDURE "informix".sp_actualiza_info_cac
(
pEmpresa 		CHAR(3),
pNumSol      	CHAR(50),
pIngreso		DECIMAL(18,2),
pOtrosCompromisos	DECIMAL(18,2),
pCompValido		CHAR(1)
)

RETURNING
	CHAR(6) 		AS cod_ret,
	VARCHAR(80) 	AS desc_ret;  
	
	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE cErrorInfo			VARCHAR(80);
    DEFINE cCodRet				CHAR(6);
    DEFINE cMensajeRet			VARCHAR(80);
		
	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '000000';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_actualiza_info_cac.out';
	--TRACE ON;


	-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
    IF NVL(pEmpresa,'') = '' OR NVL(pNumSol,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
	ELSE
		UPDATE bdisolic:"informix".ss_solicitudes_cac
		SET 	ingreso_cac	 = pIngreso,
				compromisos_cac	  = pOtrosCompromisos,
				comprobante_valido_cac  = pCompValido
		WHERE num_solicitud = pNumSol
		AND empresa = pEmpresa;
    END IF;

	RETURN cCodRet, cMensajeRet;

END;
END PROCEDURE
