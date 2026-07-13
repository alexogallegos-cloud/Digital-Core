CREATE PROCEDURE "informix".sp_registra_sol_revision_cac(pEmpresa       CHAR(3), 
                                                        pNumSolicitud   CHAR(20),
														pEjecutivo      CHAR(8))
RETURNING CHAR(6)  AS resultado,
		  CHAR(80) AS MensajeRes;


--Declaración de Variables
DEFINE iSqlErr         		INTEGER;
DEFINE iIsamErr        		INTEGER;
DEFINE cErrorInfo      		CHAR(80);
DEFINE cCodRet         		CHAR(6);
DEFINE cMensajeRet          CHAR(80);
DEFINE cNomEjecutivo        CHAR(45);
DEFINE cEjec_Atde           CHAR(20);
DEFINE cStatSol				CHAR(2);
DEFINE cMensaje1			CHAR(80);
DEFINE cMensaje2			CHAR(80);
DEFINE iBanderaAutorizada	INTEGER;
DEFINE iBanderaAtiende		INTEGER;
DEFINE cEjec_Aut			CHAR(20);



--Inicialización de Variables
LET iSqlErr            	= 0;
LET iIsamErr           	= 0;
LET cErrorInfo         	= "";
LET cCodRet            	= "000000";
LET cMensajeRet         = "PROCESO EXITOSO";
LET cNomEjecutivo       = "";
LET cEjec_Atde          = "";
LET cStatSol			= "";
LET cMensaje1			= "ESTA SOLICITUD YA FUÉ ATENDIDA POR:";
LET cMensaje2 			= "SOLICITUD ESTÁ SIENDO ATENDIDA POR:";
LET iBanderaAutorizada	= 0;
LET iBanderaAtiende		= 0;
LET cEjec_Aut			= "";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
	  LET cMensajeRet = cErrorInfo;
      RETURN TRIM(cCodRet), cMensajeRet;
   END IF;
END EXCEPTION;

 --SET DEBUG FILE TO '/respaldosbd/Morales/sp_registra_sol_revision_cac.out';
 --TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	IF  (pEmpresa = ""  OR pNumSolicitud = "" OR pEjecutivo = "") THEN
		LET cCodRet =  "000001";  --Parametros de entrada incompletos
		LET cMensajeRet = "PARÁMETROS DE ENTRADA INCORRECTOS";
		RETURN TRIM(cCodRet), cMensajeRet;
	END IF;	

	SELECT a.status_solicitud, b.ejecutivo_atiende, b.ejecutivo_autoriza
	INTO cStatSol, cEjec_Atde, cEjec_Aut
	FROM bdisolic:"informix".ss_solicitudes a,
		bdisolic:"informix".ss_solicitudes_cac b
	WHERE a.num_solicitud = b.num_solicitud
	AND a.status_solicitud = b.status
	AND b.num_solicitud = pNumSolicitud
	AND b.empresa = pEmpresa;
	
	IF cStatSol <> 'LC' THEN 
		LET cCodRet =  "000002";  --Solicitud ya fue atendida
		LET cMensajeRet =  cMensaje1;
		
	ELIF EXISTS(SELECT num_solicitud FROM bdisolic:"informix".ss_sol_revision_cac WHERE num_solicitud = pNumSolicitud ) THEN
			
		SELECT ejecutivo_atiende
		INTO cEjec_Atde
		FROM bdisolic:"informix".ss_sol_revision_cac 
		WHERE empresa =  pEmpresa
		AND num_solicitud = pNumSolicitud;	
		IF  cEjec_Atde <> pEjecutivo THEN
			LET iBanderaAtiende = 1;
			LET cCodRet =  "000003";  --Solicitud está siendo atendida
			LET cMensajeRet =  cMensaje2;
		END IF
	ELSE
		INSERT INTO bdisolic:"informix".ss_sol_revision_cac(empresa,num_solicitud,ejecutivo_atiende, fecha_insert)
		VALUES(pEmpresa, pNumSolicitud, pEjecutivo, CURRENT);
			
		UPDATE 	bdisolic:"informix".ss_solicitudes_cac
		SET ejecutivo_atiende = pEjecutivo
		WHERE num_solicitud = pNumSolicitud;	
	END IF;	

	IF  (iBanderaAtiende = 1 ) OR (cStatSol <> 'LC') THEN
			SELECT nombre 
			INTO cNomEjecutivo
			FROM bdinteg:"informix".si_ejecut
			WHERE empresa = pEmpresa
			AND ejecutivo = CASE WHEN iBanderaAtiende = 1 THEN cEjec_Atde ELSE cEjec_Aut END;
			
	END IF;
		LET cMensajeRet =  TRIM(cMensajeRet) || " " || cNomEjecutivo;
	RETURN TRIM(cCodRet), cMensajeRet;

END
END PROCEDURE
