CREATE PROCEDURE "informix".sp_finalizar_revision_cac(pEmpresa CHAR(3),
													 pNumSolicitud CHAR(20),
													 pEjecutivo CHAR(8),
													 pLincredSugCAC DECIMAL(18,2),
													 pComprobante CHAR (1),
													 pObservaciones CHAR (200)
													 )
RETURNING CHAR(6)           AS cod_ret,
          VARCHAR(100,1)    AS mensaje_ret;


DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cErrorInfo      VARCHAR(255,1);
DEFINE cCodRet         CHAR(6);
DEFINE cMensajeRet     VARCHAR(100,1);
DEFINE cNuevoStatus    CHAR(2);
DEFINE cCausa_sol      CHAR(3);
DEFINE cMensajeStatus  VARCHAR(100,1);
DEFINE cStatusSol    CHAR(2);
DEFINE iActMonto    INTEGER;
DEFINE cBegin    CHAR(1);

LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = "";
LET cCodRet            = "000000";
LET cMensajeRet        = "CONSULTA EXITOSA";
LET cNuevoStatus       = "";
LET cCausa_sol         = "";
LET cMensajeStatus     = "";
LET cStatusSol     = "";
LET iActMonto = 0;
LET cBegin = "N";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet     = iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN TRIM(cCodRet),cMensajeRet;
	 IF cBegin = "S" THEN
			ROLLBACK WORK;
	 END IF;
   END IF;
END EXCEPTION;
/*
ON EXCEPTION IN (-535)
	COMMIT WORK;
	BEGIN WORK;
	LET cBegin = "S";
END EXCEPTION WITH RESUME;

BEGIN WORK;
LET cBegin = "S";*/

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/informix/gpe/sp_finalizar_revision_cac.out';
--TRACE ON;

IF  NVL(pEmpresa,"") = "" OR NVL(pEjecutivo,"") = "" OR NVL(pNumSolicitud,"") = ""  THEN
	LET cCodRet      = "000001";
	LET cMensajeRet  = "FALTA UN PARÃMETRO DE ENTRADA REQUERIDO PAR LA CONSULTA";
ELSE
	SELECT a.status_solicitud
	INTO cStatusSol
	FROM bdisolic:"informix".ss_solicitudes a
	INNER JOIN bdisolic:"informix".ss_solicitudes_cac b ON (a.num_solicitud = b.num_solicitud )--AND a.status_solicitud = b.status)
	WHERE b.num_solicitud = pNumSolicitud
	AND b.empresa = pEmpresa;

	/*IF NVL(cStatusSol,"") <> "LC"  AND NVL(cStatusSol,"") <> "MC" THEN --INC 27 195 Se contempla el estatus de MC para los productos de PrÃ©stamos
		LET cCodRet     = "000002";
		LET cMensajeRet = "VERIFIQUE LA INFORMACIÃ?N PROPORCIONADA";
	ELSE*/
		IF pLincredSugCAC = 0 THEN
			LET cNuevoStatus = 'RT';
			LET cCausa_sol = 'CPS';
	        LET cMensajeStatus= 'CAPACIDAD DE PAGO SATURADA';
		ELSE
            SELECT status_hereda INTO cNuevoStatus FROM bdisolic:ss_solicitudes_mc WHERE num_solicitud = pNumSolicitud	AND empresa = pEmpresa; 
            IF NVL(cNuevoStatus,'') = '' THEN
               LET cNuevoStatus = 'AT';
            END IF;
            LET cCausa_sol = '';
            LET cMensajeStatus= 'SOLICITUD AUTORIZADA';
            LET iActMonto = 1;
		END IF;
	    IF NVL(cStatusSol,"") = "LC"  THEN
			--se actualiza el status de la solicitud, en el maestro de solicitudes
			EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol
			(pEmpresa,pEjecutivo,pNumSolicitud, cNuevoStatus, cCausa_sol, cMensajeStatus )
						INTO cCodRet;
		END IF;
	    IF cCodRet::INTEGER <> 0 THEN
	        LET cCodRet= '00006'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
			LET cMensajeRet = "OCURRIÃ? UN ERROR AL EJECUTAR EL PROCEDIMIENTO: sp_actualiza_status_sol";
			RETURN TRIM(cCodRet),cMensajeRet;
	    END IF;

		--se actualiza el status de la solicitud  en la tabla de revision
		UPDATE bdisolic:"informix".ss_solicitudes_cac
			SET status = cNuevoStatus,
				ejecutivo_atiende = '',
				ejecutivo_autoriza = pEjecutivo,
				comprobante_valido = pComprobante,
				observaciones = pObservaciones,
				fecha_determinacion = CURRENT,
				revisado = "S"
		WHERE num_solicitud = pNumSolicitud
		AND status = cStatusSol
		AND empresa = pEmpresa;

		--se actualiza el status de la solicitud  en la tabla de paginacion SDFM

		UPDATE bdisolic:"informix".ss_paginacion_solicitudes_cac
			SET num_analista = pEjecutivo,
				nombre_analista = '',
				consulta = 'SI'
		WHERE   ejecutivo <> pEjecutivo
		AND		num_solicitud = pNumSolicitud;


		IF iActMonto = 1 THEN --Se actualiza el monto de la solicitud
			UPDATE bdisolic:"informix".ss_solicitudes
				SET monto_solicitado = pLincredSugCAC
			WHERE num_solicitud = pNumSolicitud
			AND status_solicitud = cNuevoStatus
			AND empresa = pEmpresa;
		END IF;
		--Se elimina de la tabla de control de solicitudes en proceso de revision
		DELETE FROM bdisolic:"informix".ss_sol_revision_cac
		WHERE num_solicitud = pNumSolicitud
		AND ejecutivo_atiende = pEjecutivo
		AND empresa = pEmpresa;

	--END IF;
/*	IF cBegin = "S" THEN
		IF  cCodRet::INTEGER = 0 THEN
			COMMIT WORK;
		ELSE
			ROLLBACK WORK;
		END IF;
	END IF;*/
END IF;

RETURN  TRIM(cCodRet),cMensajeRet;

END
END PROCEDURE
