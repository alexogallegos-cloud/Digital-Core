CREATE PROCEDURE "informix".sp_asigna_solicitud_mc(pEmpresa CHAR(3), pStatus CHAR(2), ejecutivo_mc CHAR(8))
RETURNING CHAR(6)       AS codigo_retorno,
          VARCHAR(20,1) AS numero_solicitud,
		  VARCHAR(20,1) AS numero_cliente;

DEFINE cCodRet		    CHAR(6);
DEFINE iSqlErr		    INTEGER;
DEFINE iSamErr		    INTEGER;
DEFINE cErrorInfo	    VARCHAR(80);

DEFINE cCodRet2         CHAR(6);
DEFINE cMensajeRet2     VARCHAR(80);	
DEFINE cNumSolicitud	CHAR(20);
DEFINE cNumCte			CHAR(20);

LET cCodRet			= "000000";
LET iSqlErr			= 0;
LET iSamErr			= 0;
LET cErrorInfo		= "";

LET cCodRet2        = "";
LET cMensajeRet2    = "";
LET cNumSolicitud	= "";
LET cNumCte			= "";

BEGIN
ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
IF iSqlErr != 0 THEN
	LET cCodRet = iSqlErr::CHAR(8);
	RETURN NVL(cCodRet,''),NVL(cNumSolicitud,''),NVL(cNumCte,'');
END IF;
END EXCEPTION; 	

--SET DEBUG FILE TO "/informix/paulq/sp_asigna_solicitud_mc.out";
--TRACE ON;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

IF TRIM(NVL(pEmpresa,"")) = "" OR TRIM(NVL(pStatus,"")) = "" OR TRIM(NVL(ejecutivo_mc,"")) = "" THEN
	LET cCodRet = "000001"; --SE VALIDA QUE LA EJECUCIÓN CONTENGA LOS PARAMETROS REQUERIDOS
	RETURN NVL(cCodRet,''),NVL(cNumSolicitud,''),NVL(cNumCte,'');
END IF;

-- PARA DESBLOQUEAR SOLICITUDES PENDIENTES POR EL ANALISTA
DELETE FROM "informix".ss_cte_procesando WHERE usuario = ejecutivo_mc;

FOREACH WITH HOLD
	SELECT num_solicitud, numcte 
	  INTO cNumSolicitud, cNumCte
	  FROM "informix".ss_solicitudes_mc 			 
	 WHERE empresa = pEmpresa
	   AND status_ini = pStatus AND status_fin = ""
  ORDER BY tipo_alta ASC, num_producto ASC, hora_insert ASC
  
  EXECUTE PROCEDURE "informix".sp_mc_sol_procesando(cNumCte,ejecutivo_mc,1)
  INTO cCodRet2, cMensajeRet2;

  IF cCodRet2 = -268 THEN
	CONTINUE FOREACH;
  ELIF cCodRet2 = '000000' THEN 
	RETURN NVL(cCodRet2,''),NVL(cNumSolicitud,''),NVL(cNumCte,'');
	EXIT FOREACH;    
  END IF;
END FOREACH;

IF DBINFO("sqlca.sqlerrd2") = 0 THEN
	LET cCodRet = "000002"; --NO HAY CLIENTES POR ASIGNAR
	RETURN NVL(cCodRet,''),NVL(cNumSolicitud,''),NVL(cNumCte,'');
END IF;

END
END PROCEDURE
