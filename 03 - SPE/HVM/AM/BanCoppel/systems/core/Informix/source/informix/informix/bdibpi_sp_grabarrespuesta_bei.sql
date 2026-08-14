CREATE PROCEDURE "informix".sp_grabarrespuesta_bei(pNumCliente VARCHAR(9),
									pIdPregunta INT,
									pDescResp VARCHAR(80))
RETURNING CHAR (5);

	-- Creador: Manuel Ramos Figueroa
	-- Objetivo: Registra respuestas del usuario
	-- Fecha: 23/07/2011
	
	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE cIdUsuario char(8);
	DEFINE iIdPregunta INT;
	
	LET cCod_ret = '00000';
	LET cIdUsuario = '';
	LET iIdPregunta = 0;
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
		
		SELECT id_usuario INTO cIdUsuario FROM bdibpi:"informix".bpi_usuariopm WHERE numcliente = pNumCliente AND st_portal = 'activo';
		SELECT id_pregunta INTO iIdPregunta FROM bdibpi:"informix".bpi_resp_seguridadpm WHERE id_usuario = cIdUsuario AND id_pregunta = pIdPregunta;
		
		IF NVL(iIdPregunta, '') <> '' THEN
			SET LOCK MODE TO WAIT ;
			UPDATE bdibpi:"informix".bpi_resp_seguridadpm SET desc_resp = pDescResp, f_ultima_mod = TODAY WHERE id_usuario = cIdUsuario AND id_pregunta = iIdPregunta;
		ELSE
			INSERT INTO bdibpi:"informix".bpi_resp_seguridadpm (id_pregunta, id_usuario, desc_resp, f_ultima_mod) VALUES (pIdPregunta, cIdUsuario, pDescResp, TODAY);
		END IF;
		
		RETURN cCod_ret;
		
	END;

END PROCEDURE;