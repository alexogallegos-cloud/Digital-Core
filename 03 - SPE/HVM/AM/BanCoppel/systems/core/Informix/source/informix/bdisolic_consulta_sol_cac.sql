CREATE PROCEDURE "informix".consulta_sol_cac()
RETURNING CHAR(6)  AS resultado,
          CHAR(80) AS mensaje;


--Declaración de Variables
DEFINE iSqlErr         		INTEGER;
DEFINE iIsamErr        		INTEGER;
DEFINE cErrorInfo      		CHAR(80);
DEFINE cCodRet         		CHAR(6);
DEFINE cMensajeRet     		CHAR(80);



--Inicialización de Variables
LET iSqlErr            	= 0;
LET iIsamErr           	= 0;
LET cErrorInfo         	= "";
LET cCodRet            	= "000000";
LET cMensajeRet        	= "";

BEGIN



ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN TRIM(cCodRet), TRIM(cMensajeRet);
   END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "/respaldosbd/hectorb/consulta_sol_cac.out";
-- TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


	IF EXISTS(SELECT num_solicitud FROM bdisolic:"informix".ss_solicitudes_cac WHERE status = "LC") THEN
		LET cCodRet =  "000000";
		LET cMensajeRet = "EXISTEN SOLICITUDES PENDIENTES POR ATENDER";
	ELSE	
		LET cCodRet =  "000002";
		LET cMensajeRet = "NO EXISTEN SOLICITUDES PENDIENTES POR ATENDER";
	END IF;

	
	RETURN TRIM(cCodRet), TRIM(cMensajeRet);

END
END PROCEDURE
