CREATE PROCEDURE "informix".sp_limpieza_motor()

	RETURNING CHAR(5)
	
	--Declaracion de variables
	DEFINE iSqlErr                  INTEGER;
	DEFINE cCodRet                  CHAR(6); 
	DEFINE iRegCommit               INTEGER;
	DEFINE iCont                    INTEGER;
	DEFINE iCont2                   INTEGER;
	DEFINE vNumSolicitud            CHAR(20);
	DEFINE vNumSolicitud2           CHAR(20);
	DEFINE vNumSolicitud3           CHAR(20);

	--Inicializacion de variables
	LET cCodRet      	                = '00000'; 
	LET iRegCommit      	            = 100;
	LET iCont      	                    = 0;
	LET iCont2     	                    = 0;

	--INICIALIZACION DE VARIABLES DATOS DEL CLIENTE
	LET vNumSolicitud      	            =""; 
	LET vNumSolicitud2     	            ="";
	LET vNumSolicitud3     	            ="";	
	
	--DECLARACION DE VARIABLES DE ERROR
	LET iSqlErr							            = 0;	
	
	SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO '/home/e10000315/motor/sp_limpieza_motor.out';
	--TRACE ON;
	
	--SET DEBUG FILE TO '/home/c90077639/new_sp_limpieza_motor/sp_limpieza_motor.out';
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
		   IF iSqlErr <> 0 THEN
					LET cCodRet = iSqlErr;
				RETURN cCodRet;
		   END IF;
		END EXCEPTION;
			
BEGIN WORK;	
			FOREACH WITH HOLD
					
					SELECT num_solicitud
					INTO vNumSolicitud
					FROM bdisolic:"informix".ss_enviossolicitudesmotor
					WHERE status_consumo = "0" and fecha_insert <= today -1
									
				    LET iCont = iCont + 1;
					
					UPDATE bdisolic:"informix".ss_enviossolicitudesmotor
					SET status_consumo = "3" WHERE num_solicitud = vNumSolicitud and status_consumo = "0";
									
				   	
				IF iCont >= iRegCommit THEN ---CAMBIAR A 100
						LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			
		
			FOREACH WITH HOLD
					
					SELECT num_solicitud
					INTO vNumSolicitud2
					FROM bdisolic:"informix".ss_solicitudes
					where fecha_insert < today and envio_parametrico in (1,6) and status_solicitud = 'EC' --Se agrega envio parametrico 6
					
									
				    LET iCont2 = iCont2 + 1;
					
					UPDATE bdisolic:"informix".ss_solicitudes
					SET envio_parametrico = 4 WHERE num_solicitud = vNumSolicitud2 and envio_parametrico in (1,6) and status_solicitud = 'EC';
									
				   	
				IF iCont2 >= iRegCommit THEN ---CAMBIAR A 100
						LET iCont2 = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			
---Modificacion 13-11-2024. 
---Se agrega actualizacion de status_consumo a solicitudes que se encuentran en la tabla ss_enviossolicitudesmotor_pp para evitar el rechazo incorrecto de solicitudes
			FOREACH WITH HOLD
					
					SELECT num_solicitud
					INTO vNumSolicitud3
					FROM bdisolic:"informix".ss_enviossolicitudesmotor_pp
					WHERE status_consumo = "0" and fecha_insert <= today -1
									
				    LET iCont = iCont + 1;
					
					UPDATE bdisolic:"informix".ss_enviossolicitudesmotor_pp
					SET status_consumo = "3" WHERE num_solicitud = vNumSolicitud3 and status_consumo = "0" ;
									
				   	
				IF iCont >= iRegCommit THEN ---CAMBIAR A 100
						LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
			END FOREACH;

COMMIT WORK;

RETURN cCodRet;

	END;
END PROCEDURE
