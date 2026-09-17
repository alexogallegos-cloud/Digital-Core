CREATE PROCEDURE "informix".sp_actualizasolicitudes_motor_adn(cNumCte char(20), cNumSolicitud char(20), cStatusRespuesta char(2))
RETURNING CHAR(6) AS COD_RET

--DECLARACIÃN DE VARIABLES
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6); 

--INICIALIZACIÃN DE VARIABLES
LET iSqlErr = 0;
LET cCodRet = "000000";

BEGIN

	ON EXCEPTION SET iSqlErr
	IF iSqlErr != 0 THEN
		LET cCodRet = iSqlErr;
		RETURN TRIM(cCodRet);
	END IF;

	END EXCEPTION;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    --SET DEBUG FILE TO '/home/e97892149/sp_actualizasolicitudes_motor_adn'||trim(pNumSol)||'.out';
	--TRACE ON;
	
	UPDATE bdisolic:"informix".ss_enviossolicitudesmotor_adn
	SET status_consumo = "1", status_respuesta = cStatusRespuesta
	WHERE empresa='001'
	AND num_solicitud = cNumSolicitud 
	AND num_cte=cNumCte 
	AND status_consumo="0" 
	AND status_respuesta = ""
	AND fecha_insert = (SELECT MAX(fecha_insert) 
	FROM bdisolic:"informix".ss_enviossolicitudesmotor_adn 
	WHERE empresa='001'
	AND num_solicitud = cNumSolicitud 
	AND num_cte=cNumCte 
	AND status_consumo="0" 
	AND status_respuesta = "");
	
	RETURN cCodRet;
END;
END procedure;