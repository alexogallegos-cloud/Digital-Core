CREATE PROCEDURE "informix".sp_can_tknxpira_bei( pfecha DATE)
RETURNING CHAR(5);
----------------------------------------------------------------------------------------------------------------------------------------
-- Realiza: Gabriela Aguilar
-- Actividad: Valida los token que se encuentra en la tabla bei_tokenexpira los cuales ya paso su fecha de caducidad y no fueron renovados.
-- Se requiere cancelarlos para que el cliente pueda solicitar los nuevos dispositivos Token.
-- Solicita: Alejandro Vazquez
-- Fecha: 30/07/2019
------------------------------------------------------------------------------------------------------------------------------------------

--Declaracion de variables
DEFINE vsCodRet CHAR(10);
DEFINE viSqlErr INTEGER;
DEFINE vTransaccion INTEGER;
DEFINE vNum_cliente CHAR(9);
DEFINE vNs_token    CHAR(9);
DEFINE vid_usuario INTEGER;
DEFINE vid_tipo_usuario SMALLINT;
DEFINE vnombre CHAR(150);
DEFINE vid_status_token INTEGER;
DEFINE vid_status_servicio INTEGER;
DEFINE vid_status_solicitud CHAR(1);
DEFINE vsuc_registro  CHAR(4);
DEFINE vfolio_token   VARCHAR(25);
DEFINE vSolicitud CHAR(10);
DEFINE vid_status CHAR(4);

--Asignacion de variables
LET vTransaccion=0;
LET vsCodRet = '00000';
LET viSqlErr = 0;
LET vNum_cliente = '';
LET vNs_token    = '';
LET vid_usuario=0;
LET vid_tipo_usuario=0;
LET vnombre = '';
LET vid_status_token =0;
LET vid_status_servicio=0;
LET vid_status_solicitud= ''; 
LET vsuc_registro= '';
LET vfolio_token= '';
LET vSolicitud =  '';
LET vid_status='';

Set isolation to dirty read;
SET LOCK MODE TO WAIT 3;

 
	--SET DEBUG FILE TO "/informix/gaby/bdibei/spl/sp_can_tknxpira.out";
	--TRACE ON;

BEGIN

    ON EXCEPTION SET viSqlErr --Manejador de Errores
	
        IF viSqlErr <> 0 THEN
            LET vsCodRet = viSqlErr;
            IF vTransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
			
            RETURN vsCodRet;
			
        END IF;
		
    END EXCEPTION;
	
    ON EXCEPTION IN (-535)
        LET vTransaccion = 1;
    END EXCEPTION WITH RESUME;


	
    IF vTransaccion = 1 THEN
         COMMIT WORK;
         BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
	
    IF vsCodRet = '00000' THEN
     		 
       		
		FOREACH 
			SELECT  a.num_cte, a.ns_token, a.id_usuario, a.id_tipo_usuario, a.id_status_solicitud, a.id_status_token,  a.nombre, a.id_status_servicio
            INTO vNum_cliente,vNs_token, vid_usuario, vid_tipo_usuario, vid_status_solicitud, vid_status_token,  vnombre, vid_status_servicio 
			FROM "informix".bei_tokenexpira a
			inner join bdibpi:tkn_nseries b on b.ns_token=a.ns_token and  b.f_caducidad = MDY(month(pfecha),day(pfecha),year(pfecha))
			WHERE a.id_status_solicitud = '0'
			 			
			IF (SELECT COUNT(ns_token) FROM "informix".bei_token where num_cliente = vNum_cliente and id_usuario=vid_usuario AND ns_token =vNs_token and id_status_token <> 199)> 0 THEN
						select  suc_registro,folio_token, id_status_token 
						into vsuc_registro,vfolio_token, vid_status 
						FROM "informix".bei_token where num_cliente = vNum_cliente and id_usuario=vid_usuario AND ns_token =vNs_token;
				 
						UPDATE "informix".bei_tokensolicitud SET id_status = '199' WHERE numcte = vNum_cliente and ns_token = vNs_token;
						
						UPDATE bdibpi:tkn_nseries  SET id_status = '199', f_status = current   WHERE ns_token = vNs_token; 

						INSERT INTO bdibpi:tkn_status_token (ns_token,anterior,actual,f_cambio_status, usr_cambio_status,canal) 
							VALUES(vNs_token, vid_status, '199', CURRENT, 'transBEI', '03');
										
												
						INSERT INTO "informix".bei_tokenhis(id_usuario, num_cliente, ns_token, suc_registro, folio_token, id_status_token, f_status, f_registro) 
							VALUES(vid_usuario, vNum_cliente, vNs_token, vsuc_registro, vfolio_token, '199', current, current);
							
						delete "informix".bei_token WHERE num_cliente = vNum_cliente and id_usuario=vid_usuario;
						
						INSERT INTO "informix".bei_tokenexpira_his(num_cte, id_usuario, id_tipo_usuario, ns_token, nombre, id_status_token, id_status_servicio, id_status_solicitud, id_token_vencido, f_registro_solicitud, solicitud, tipo) 
									VALUES(vNum_cliente, vid_usuario, vid_tipo_usuario, vNs_token, vnombre, '199', vid_status_servicio, vid_status_solicitud, 0, '', 0,0);
						
						delete "informix".bei_tokenexpira where num_cte=vNum_cliente and id_usuario=vid_usuario	and id_status_solicitud = '0';			
								
						select solicitud, id_status into vsolicitud, vid_status from "informix".bei_tokensolicitud  WHERE numcte = vNum_cliente and ns_token = vNs_token;
															
						UPDATE "informix".bei_solicitudtoken SET id_status = '199', f_atencion = CURRENT, usr_atiende = 'transBEI'  WHERE solicitud = vsolicitud AND numcte = vNum_cliente;

						INSERT INTO "informix".bei_stasolicitud (solicitud,anterior,actual,f_registro) VALUES(vsolicitud,vid_status,'199',CURRENT);
		
		
			
			ELSE
				INSERT INTO informix.bei_tokenexpira_his(num_cte, id_usuario, id_tipo_usuario, ns_token, nombre, id_status_token, id_status_servicio, id_status_solicitud, id_token_vencido, f_registro_solicitud, solicitud, tipo) 
						VALUES(vNum_cliente, vid_usuario, vid_tipo_usuario, vNs_token, vnombre, '199', vid_status_servicio, vid_status_solicitud, 0, '', 0,0);
						
				delete "informix".bei_tokenexpira where num_cte=vNum_cliente and id_usuario=vid_usuario	and id_status_solicitud = '0';
				
			END IF;	
		END FOREACH;	
	END IF;
	Commit;
		
	RETURN vsCodRet;
END
END PROCEDURE;