CREATE PROCEDURE "informix".sp_validarrespuesta(pNumCliente VARCHAR(9),
									 pIdPregunta INT,
									 pRespuesta CHAR(80))
RETURNING CHAR (5), CHAR(1);
	-- Creador: Javier Calderón
	-- Objetivo: Valida respuesta del usuario
	-- Solicitó: Diana Castellanos
	-- Fecha: 17/11/2010
	
	--Modificó: Edgar M. Alarcon
	--Actividad: valida si recibe id de usuario o numero de cliente
	--Solicito: Jose de Jesus
	--Fecha: 05-11-15
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vIdUsuario VARCHAR(11);
	DEFINE vResCor CHAR(1);
	
	--SET DEBUG FILE TO "/home/informix/bibiana/sp_validarrespuesta.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vResCor;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		LET vIdUsuario = '';
		
		SELECT id_usuario INTO vIdUsuario FROM bdibpi:"informix".bpi_usuario WHERE numcliente = pNumCliente AND st_portal = 'activo';
		
		IF vIdUsuario = '' OR vIdUsuario IS NULL THEN
			--SELECT id_usuario INTO vIdusuario FROM bpi_resp_seguridad WHERE id_usuario = vIdUsuario AND id_pregunta = pIdPregunta AND desc_resp = pRespuesta;
			SELECT id_usuario INTO vIdusuario FROM bdibpi:"informix".bpi_resp_seguridad WHERE id_usuario = pNumCliente AND id_pregunta = pIdPregunta AND desc_resp = pRespuesta;
		ELSE
			SELECT id_usuario INTO vIdusuario FROM bdibpi:"informix".bpi_resp_seguridad WHERE id_usuario = vIdUsuario AND id_pregunta = pIdPregunta AND desc_resp = pRespuesta;
		END IF;
				
		IF NVL(vIdusuario, '') = '' THEN 
			LET vResCor = '0'; --Incorrecta
		ELSE
			LET vResCor = '1'; --Correcta
		END IF;
		RETURN vCod_ret, vResCor;
	END;
END PROCEDURE;