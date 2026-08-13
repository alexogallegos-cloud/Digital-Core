CREATE PROCEDURE "informix".sp_valida_status_dictamen_unificado(
	cUsuario CHAR(8),
	cPassword CHAR(8),
	cIdSession CHAR(30),
	cIpOrigen CHAR(15),
	cAgentTransTypeCode CHAR(10),
	cAgentCd CHAR(3),
	cFolio CHAR(20)
)

RETURNING 
  CHAR(4) AS cCodRet,
  VARCHAR(120) AS cMensajeResp,
  CHAR(4) AS cCodRes,
  CHAR(2) AS cCodStatus,
  VARCHAR(40) AS cDescStatus,
  VARCHAR(255) AS cCausaRechazo;

  --DEFINE VARIABLES
  DEFINE iSqlErr INTEGER;
  DEFINE cCount INTEGER;
  
  DEFINE cCodRet CHAR(4);
  DEFINE cMensajeResp VARCHAR(120);
  DEFINE cCodRes CHAR(4);
  DEFINE cCodStatus CHAR(2);
  DEFINE cDescStatus VARCHAR(40);
  DEFINE cCausaRechazo VARCHAR(255);

  LET cCodRet = '0000';
  LET cMensajeResp = 'Consulta exitosa';
  LET cCodRes = '';
  LET cCodStatus = '';
  LET cDescStatus = '';
  LET cCausaRechazo = '';
  LET cCount = 0;

BEGIN
	-- ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeResp = 'Error en base de datos';
			RETURN cCodRet,TRIM(cMensajeResp),TRIM(cCodRes),TRIM(cCodStatus),TRIM(cDescStatus),TRIM(cCausaRechazo);
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/informix/LIP/sp_valida_status_dictamen_unificado.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(cAgentTransTypeCode,'')) <> '' AND TRIM(NVL(cAgentCd, '')) <> '' AND TRIM(NVL(cUsuario,'')) <> '' AND TRIM(NVL(cPassword,'')) <> '' AND TRIM(NVL(cIpOrigen,'')) <> '' AND TRIM(NVL(cIdSession,'')) <> '' AND TRIM(NVL(cFolio, '')) <> '' THEN
	
		--VALIDAR SESIÃ?Ã?Ã?Ã?N
		EXECUTE PROCEDURE  bdisac:"informix".sp_valida_session(TRIM(cAgentTransTypeCode), TRIM(cAgentCd), TRIM(cUsuario), TRIM(cPassword), TRIM(cIpOrigen), TRIM(cIdSession) ) INTO cCodRet, cMensajeResp;
		IF TRIM(cCodRet) = '0000' THEN

			SELECT COUNT(num_solicitud) INTO cCount FROM bdisolic:"informix".ss_solicitudes WHERE num_solicitud = cFolio;
			IF(cCount > 0) THEN
				LET cCodRes= "0001";
			
			
				SELECT ss.status_solicitud, des.descripcion INTO cCodStatus,cDescStatus
				FROM bdisolic:"informix".ss_solicitudes ss
					 INNER JOIN bdinteg:si_status_solicitud des 
							 ON ss.status_solicitud = des.codigo
				WHERE ss.num_solicitud = cFolio;
				
				IF(cCodStatus = 'RT') THEN
					SELECT comentario INTO cCausaRechazo
					FROM bdisolic:"informix".ss_autorizacion
					WHERE num_solicitud = cFolio
					AND status_solicitud = 'RT';
				END IF;
				
			ELSE
	
				LET cCodRes= "0002";
		
			END IF;

		END IF;
			
	ELSE
	
		LET cCodRet= "9996";
		LET cMensajeResp = "Uno de los parametros de seguridad viene vacio";
		
	END IF;


	RETURN cCodRet,TRIM(cMensajeResp),TRIM(cCodRes),TRIM(cCodStatus),TRIM(cDescStatus),TRIM(cCausaRechazo);

END;
END PROCEDURE;