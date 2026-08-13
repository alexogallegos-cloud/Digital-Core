CREATE PROCEDURE "informix".sp_consultar_envios_coppel()
RETURNING CHAR(6)  AS COD_RET,
		  CHAR(80) AS MENSAJE_EJEC,
		  CHAR(3)  AS EMPRESA,
		  CHAR(20) AS NUMCTE,
		  CHAR(20) AS NUM_SOLICITUD;

--DECLARACIÓN DE VARIABLES
DEFINE iSqlErr         	INTEGER;
DEFINE iIsamErr        	INTEGER;
DEFINE iCantReg        	INTEGER;
DEFINE cErrorInfo      	CHAR(80);
DEFINE cCodRet         	CHAR(6);
DEFINE cMensajeRet      CHAR(80);
DEFINE cEmpresa         CHAR(3);
DEFINE cNumCte          CHAR(20);
DEFINE cNumSolicitud    CHAR(20);
DEFINE iNumreg    		INTEGER;

--INICIALIZACIÓN DE VARIABLES
LET iSqlErr        = 0;
LET iIsamErr       = 0;
LET iCantReg       = 0;
LET cErrorInfo     = "";
LET cCodRet        = "000000";
LET cMensajeRet    = "PROCESO EXITOSO";

LET cEmpresa       = "";
LET cNumCte        = "";
LET cNumSolicitud  = "";
LET iNumreg  	   = 0;

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
		  LET cCodRet = iSqlErr;
		  LET cMensajeRet = cErrorInfo;
		  RETURN TRIM(cCodRet), TRIM(cMensajeRet),"","","";
	   END IF;
	END EXCEPTION;

	-- SET DEBUG FILE TO "/home/sysifx/jesusm/sp_consultar_envios_coppel";
	-- TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	FOREACH WITH HOLD
		SELECT empresa,numcte,num_solicitud
			INTO cEmpresa,cNumCte,cNumSolicitud
		FROM bdisolic:"informix".ss_solicitudes
		WHERE envio_parametrico = "1"
		AND status_solicitud = "EC"
		
		LET iNumreg = iNumreg + 1;
		
		RETURN cCodRet, TRIM(cMensajeRet),NVL(cEmpresa,""),NVL(cNumCte,""),NVL(cNumSolicitud,"") WITH RESUME;
	END FOREACH;
	
	IF iNumreg = 0 THEN
		LET cCodRet = "000001";
		LET cMensajeRet = "No se encontro información";
		RETURN cCodRet, cMensajeRet,NVL(cEmpresa,""),NVL(cNumCte,""),NVL(cNumSolicitud,"");
	END IF;	
	
END
END PROCEDURE 
