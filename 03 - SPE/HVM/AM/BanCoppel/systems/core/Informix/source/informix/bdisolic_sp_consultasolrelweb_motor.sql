CREATE PROCEDURE "informix".sp_consultasolrelweb_motor()
RETURNING CHAR(6)  AS COD_RET;

--DECLARACIÃ?Â?N DE VARIABLES
DEFINE iSqlErr         	INTEGER;
DEFINE iIsamErr        	INTEGER;
DEFINE cErrorInfo      	CHAR(80);
DEFINE cCodRet         	CHAR(6);
DEFINE cEmpresa         CHAR(3);
DEFINE cNumCte          CHAR(20);
DEFINE cNumSolicitud    CHAR(20);
DEFINE cStatusSol		CHAR(2);
DEFINE cTipoMov 		CHAR(1);
DEFINE cNumSolRef		CHAR(20);
DEFINE iNuevoParam		INTEGER;
DEFINE dtTiempoEnvioEC	DATETIME YEAR to SECOND;
DEFINE cTiempo			CHAR(20);
--INICIALIZACIÃ?Â?N DE VARIABLES
LET iSqlErr        	= 0;
LET iIsamErr       	= 0;
LET cErrorInfo     	= "";
LET cCodRet        	= "000000";
LET cEmpresa       	= "";
LET cNumCte        	= "";
LET cNumSolicitud 	= "";
LET cStatusSol		= "";
LET cTipoMov 		= "";
LET cNumSolRef		= "";
LET iNuevoParam		= 0;
LET cTiempo			= "";

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN TRIM(cCodRet);
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO "/informix/LeonardoFigueroa/web/sp_consultasolrelweb_motor.out";
	--TRACE ON;
	SELECT valor INTO cTiempo FROM bdisolic:ss_param where secuencia = 370;
	
	IF TRIM(NVL(cTiempo,'')) <> '' THEN
		FOREACH WITH HOLD
			SELECT a.empresa,a.num_cte,a.num_solicitud,b.status_solicitud,c.tipo_movimiento,c.num_solicitud_ref
			INTO cEmpresa,cNumCte, cNumSolicitud,cStatusSol,cTipoMov,cNumSolRef
			FROM bdisolic:"informix".ss_solicitudes b
            INNER JOIN bdisolic:"informix".ss_resum_scor_fin c ON b.empresa=c.empresa and b.num_solicitud = c.num_solicitud
            INNER JOIN bdisolic:"informix".ss_enviossolicitudesmotor a ON a.status_consumo = "1" and b.num_solicitud = a.num_solicitud 
			WHERE status_solicitud='EC' AND b.canal_sol = 4
			ORDER BY a.fecha_insert DESC		

			IF NVL(cStatusSol,'') = 'EC' THEN
				SELECT fecha_hora
				INTO  dtTiempoEnvioEC
				FROM bdisolic:"informix".ss_autorizacion 
				WHERE num_solicitud = cNumSolicitud
				AND status_solicitud = 'EC';
											
				IF CURRENT::DATETIME YEAR TO SECOND - dtTiempoEnvioEC >= cTiempo THEN
					IF TRIM(NVL(cTipoMov,'')) = 'M' THEN				
						SELECT COUNT(num_solicitud) INTO iNuevoParam FROM bdisolic:"informix".ss_nuevo_parametrico WHERE num_solicitud = cNumSolRef;
						IF iNuevoParam > 0 THEN
							DELETE FROM bdisolic:"informix".ss_enviossolicitudesmotor WHERE num_solicitud = TRIM(cNumSolicitud);
							INSERT INTO  bdisolic:"informix".ss_enviossolicitudesmotor
							(empresa, num_solicitud, num_cte, status_consumo, fecha_insert, status_respuesta)
							VALUES  (cEmpresa,cNumSolicitud, cNumCte , 0, current, '');
						END IF;
					ELSE
						SELECT COUNT(num_solicitud) INTO iNuevoParam FROM bdisolic:"informix".ss_nuevo_parametrico WHERE num_solicitud = cNumSolicitud;
						IF iNuevoParam > 0 THEN
							DELETE FROM bdisolic:"informix".ss_enviossolicitudesmotor WHERE num_solicitud = TRIM(cNumSolicitud);
							INSERT INTO  bdisolic:"informix".ss_enviossolicitudesmotor
							(empresa, num_solicitud, num_cte, status_consumo, fecha_insert, status_respuesta)
							VALUES  (cEmpresa,cNumSolicitud, cNumCte , 0, current, '');
						END IF;
					END IF;							
				END IF;			
			ELSE
				DELETE FROM bdisolic:"informix".ss_enviossolicitudesmotor WHERE num_solicitud = TRIM(cNumSolicitud);
			END IF;
		END FOREACH;
	END IF;
	RETURN TRIM(cCodRet);
	
END;
END PROCEDURE
