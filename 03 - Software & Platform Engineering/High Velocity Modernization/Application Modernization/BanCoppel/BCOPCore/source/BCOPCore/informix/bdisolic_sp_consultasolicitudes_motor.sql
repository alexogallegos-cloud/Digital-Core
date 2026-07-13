CREATE PROCEDURE "informix".sp_consultasolicitudes_motor()
RETURNING CHAR(6)  AS COD_RET,
		  CHAR(3)  AS EMPRESA,
		  CHAR(20) AS NUMCTE,
		  CHAR(20) AS NUM_SOLICITUD;

--DECLARACIÃN DE VARIABLES
DEFINE iSqlErr         	INTEGER;
DEFINE iIsamErr        	INTEGER;
DEFINE cErrorInfo      	CHAR(80);
DEFINE cCodRet         	CHAR(6);
DEFINE cEmpresa         CHAR(3);
DEFINE cNumCte          CHAR(20);
DEFINE cNumSolicitud    CHAR(20);
DEFINE iNumreg    		INTEGER;
DEFINE cNumProducto		CHAR(4);
DEFINE iContador		INTEGER;
--INICIALIZACIÃN DE VARIABLES
LET iSqlErr        = 0;
LET iIsamErr       = 0;
LET cErrorInfo     = "";
LET cCodRet        = "000000";
LET cEmpresa       = "";
LET cNumCte        = "";
LET cNumSolicitud  = "";
LET iNumreg  	   = 0;
LET cNumProducto   = "";
LET iContador 	   = 0;
BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
		  LET cCodRet = iSqlErr;
		  RETURN TRIM(cCodRet),"","","";
	   END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO "/home/sysifx/LeonardoFigueroa/Motor/sp_consultasolicitudes_motor.out";
	--TRACE ON;
	
	--SET debug file to '/home/sysifx/VeraMariscal/sp_consultasolicitudes_motor.out';
    --TRACE ON;

	EXECUTE PROCEDURE bdisolic:'informix'.sp_consultasolrelweb_motor()
    INTO cCodRet;

	FOREACH WITH HOLD
 
		SELECT empresa,num_cte,num_solicitud
		INTO cEmpresa,cNumCte,cNumSolicitud
		FROM bdisolic:"informix".ss_enviossolicitudesmotor
		WHERE status_consumo = "0"
		ORDER BY fecha_insert DESC
		
		SELECT COUNT(*) INTO iContador FROM BDISOLIC:"informix".ss_enviossolicitudesmotor WHERE num_solicitud = cNumSolicitud;

		IF iContador >1 THEN
			LET iContador = 0;
			SELECT COUNT(*) INTO iContador FROM BDISOLIC:"informix".ss_enviossolicitudesmotor WHERE num_solicitud = cNumSolicitud AND status_consumo=1 AND status_respuesta<>"";
			IF iContador > 0 THEN
				DELETE FROM BDISOLIC:"informix".ss_enviossolicitudesmotor WHERE num_solicitud = cNumSolicitud AND num_cte=cNumCte AND status_consumo=0 AND status_respuesta="";
				CONTINUE FOREACH;
			ELSE
				DELETE FROM BDISOLIC:"informix".ss_enviossolicitudesmotor WHERE num_solicitud = cNumSolicitud AND num_cte=cNumCte  AND fecha_insert <> (SELECT MAX(fecha_insert) FROM "informix".ss_enviossolicitudesmotor WHERE num_solicitud = cNumSolicitud AND num_cte=cNumCte AND status_consumo="0" AND status_respuesta = "" AND empresa='001');
				CONTINUE FOREACH;
			END IF;
		END IF;
	END FOREACH;
	
	FOREACH WITH HOLD
		SELECT empresa,num_cte,num_solicitud
			INTO cEmpresa,cNumCte,cNumSolicitud
		FROM bdisolic:"informix".ss_enviossolicitudesmotor
		WHERE status_consumo = "0"
		ORDER BY fecha_insert DESC

		SELECT num_producto 
        INTO cNumProducto
        FROM BDISOLIC:"informix".ss_solicitudes 
        WHERE num_solicitud = cNumSolicitud;
        
        IF NOT EXISTS(SELECT numproducto from bdicred:"informix".sd_productos_motor WHERE numproducto = cNumProducto) THEN
            DELETE FROM BDISOLIC:"informix".ss_enviossolicitudesmotor  
            WHERE num_solicitud = cNumSolicitud;
            LET cNumProducto = "";
            CONTINUE FOREACH;
        END IF;
		
        LET cNumProducto = "";
		LET iNumreg = iNumreg + 1;

		RETURN cCodRet,TRIM(NVL(cEmpresa,"")),TRIM(NVL(cNumCte,"")),TRIM(NVL(cNumSolicitud,"")) WITH RESUME;
	END FOREACH;
	--LIMPIAR VARIABLES
	LET cEmpresa 		= "";
	LET cNumCte  		= "";
	LET cNumSolicitud 	= "";
	
	--SI LA BUSQUEDA ESTA VACIA
	IF iNumreg = 0 THEN
		LET cCodRet = "000001";
		RETURN TRIM(cCodRet),"","","";
	END IF;
END;
END PROCEDURE
