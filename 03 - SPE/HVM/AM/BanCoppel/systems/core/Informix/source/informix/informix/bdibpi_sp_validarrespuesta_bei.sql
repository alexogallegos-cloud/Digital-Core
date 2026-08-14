CREATE PROCEDURE "informix".sp_validarrespuesta_bei(pNumCliente VARCHAR(9),
									 pIdPregunta INT,
									 pRespuesta CHAR(80))
RETURNING CHAR (5), CHAR(1);
	-- Creador: Manuel Ramos Figueroa
	-- Objetivo: Valida respuesta del usuario
	-- Fecha: 25/07/2011
	
	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE vIdUsuario VARCHAR(11);
	DEFINE cResCor CHAR(1);
	
	LET cCod_ret = '00000';
	LET vIdUsuario = '';
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret, cResCor;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
		
		SELECT id_usuario INTO vIdUsuario FROM bdibpi:"informix".bpi_usuariopm WHERE numcliente = pNumCliente AND st_portal = 'activo';
		SELECT id_usuario INTO vIdusuario FROM bdibpi:"informix".bpi_resp_seguridadpm WHERE id_usuario = vIdUsuario AND id_pregunta = pIdPregunta AND desc_resp = pRespuesta;
		IF NVL(vIdusuario, '') = '' THEN 
			LET cResCor = '0'; --Incorrecta
		ELSE
			LET cResCor = '1'; --Correcta
		END IF;
		RETURN cCod_ret, cResCor;
	END;
END PROCEDURE;