CREATE PROCEDURE "informix".sp_reestablecer_solicitud_cac(pEmpresa CHAR(3), pNumSolicitud CHAR(20), pEjecutivo CHAR(8))
RETURNING CHAR(6)           AS cod_ret,
          VARCHAR(100,1)    AS mensaje_ret;
          

DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cErrorInfo      VARCHAR(255,1);
DEFINE cCodRet         CHAR(6);
DEFINE cMensajeRet     VARCHAR(100,1);


LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = "";
LET cCodRet            = "000000";
LET cMensajeRet        = "CONSULTA EXITOSA";


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet     = iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN TRIM(cCodRet),cMensajeRet;
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_reestablecer_solicitud_cac.out';
--TRACE ON;

IF  NVL(pEmpresa,"") = "" OR NVL(pEjecutivo,"") = "" OR NVL(pNumSolicitud,"") = ""  THEN
	LET cCodRet            = "000001";
	LET cMensajeRet        = "FALTA PARÁMETRO DE ENTRADA REQUERIDO PARA LA CONSULTA";
ELSE
	DELETE FROM bdisolic:"informix".ss_sol_revision_cac
	WHERE num_solicitud = pNumSolicitud
	AND ejecutivo_atiende = pEjecutivo
	AND empresa = pEmpresa;
	--para quitar el analista que estaba atendiendo la solicitud
	UPDATE bdisolic:"informix".ss_solicitudes_cac
		SET ejecutivo_atiende = ""
	WHERE num_solicitud = pNumSolicitud
	AND empresa = pEmpresa;
END IF;
	
RETURN  TRIM(cCodRet),cMensajeRet;
			
END
END PROCEDURE
