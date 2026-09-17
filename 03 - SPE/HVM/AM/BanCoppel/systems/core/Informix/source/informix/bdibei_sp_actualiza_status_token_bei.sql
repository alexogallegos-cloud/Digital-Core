CREATE PROCEDURE "informix".sp_actualiza_status_token_bei(pIdUsuario INTEGER, pNumCte char(9), pStatus char(3), pNSToken char(10))
	RETURNING char (5), integer;

	--RealizÃ³: SOLSEr
	--Actividad: Actualiza el status y fecha de status del token asignado al cliente
	--Fecha:
	--Actividad: Se agrego la ejecucion del sp sp_set_statustoken_admtoken

 
	--ModificaciÃ³n: para detectar cuando la SOLICITUD este en 120 y se quiere ACTIVAR el token, cambia a 130 la solicitud.
	--Fecha: Septiembre 2014
	--Por: Berenice Noriega
	--Liberador en producciÃ³n: Sin liberar.	 
    --**************************************************************


DEFINE sql_err integer;
DEFINE cCod_ret char (5);
DEFINE statusAntToken char(3);
DEFINE vsolicitud char(10);
DEFINE vid_status smallint;


LET sql_err = '';
LET cCod_ret = '00000';
LET	vsolicitud='';
LET vid_status=0;

BEGIN

 ON EXCEPTION SET sql_err
          LET cCod_ret = sql_err;
      RETURN  cCod_ret, 0;
   END EXCEPTION;

	SET LOCK MODE TO WAIT 3 ;
	SET ISOLATION DIRTY READ ;

	--Se obtiene estatus viejo del token a actualizar
	SELECT id_status_token
	INTO statusAntToken
	FROM bdibei:"informix".bei_token WHERE num_cliente = pNumCte AND ns_token = pNSToken;


   IF EXISTS(SELECT num_cliente FROM bdibei:"informix".bei_usuario WHERE num_cliente = pNumcte AND id_usuario = pIdUsuario) THEN

			EXECUTE PROCEDURE bdibpi:"informix".sp_set_statustoken_admtoken(pNSToken,statusAntToken, pStatus,'transBEI','03')
			into cCod_ret; --actualiza bdibpi:tkn_nseries e inserta en bdibpi:tkn_status_token

			if cCod_ret='000' THEN

				IF pStatus='160' THEN --Cuando es desbloqueo guardara en la tkn_nseries 140
	  				LET pStatus='140';
				END IF;

					UPDATE bdibei:"informix".bei_token SET id_status_token = pStatus, f_status = CURRENT , id_usuario=pIdUsuario
					WHERE num_cliente = pNumCte AND ns_token = pNSToken;

					UPDATE bdibei:"informix".bei_servicio SET  ns_token=pNSToken
					WHERE num_cliente = pNumCte AND id_usuario=pIdUsuario;
					LET cCod_ret='00000';

				-------------------------------------------------------------------------------------
				IF pStatus='140' THEN ----si el estatus al que se quiere cambiar el token es 140
					select solicitud, id_status
					into vsolicitud, vid_status	
					from bdibei:"informix".bei_tokensolicitud 
					where ns_token=pNSToken and numcte=pNumCte; --consulta la solicitud y es estatus de la misma
												
							IF vid_status='120' THEN --Si el estatus de la solicitud es 120, la actualiza a 130.							
												
							update bdibei:"informix".bei_solicitudtoken set id_status='130', f_atencion=current, usr_atiende='transBEI' where solicitud=vsolicitud and numcte=pNumCte;
							update bdibei:"informix".bei_tokensolicitud set id_status='130' where solicitud=vsolicitud and numcte=pNumCte;
							update bdibei:"informix".bei_envios set id_status='130' where solicitud=vsolicitud and numcte=pNumCte and num_envio=1;
							
							insert into bdibei:"informix".bei_stasolicitud values (vsolicitud,'120','130',current);
							insert into bdibpi:"informix".tkn_status_token values (pNSToken,'130','120',current,'transBEI','15');
							
							END IF;
						
				
				END IF;
				
				-------------------------------------------------------------------------------------	
					
			ELSE
				LET	cCod_ret='00002';
			END IF;

	ELSE
		LET cCod_ret = '00001'; -- El cliente No existe
	END IF;

	RETURN cCod_ret, pStatus;

END;

END PROCEDURE;