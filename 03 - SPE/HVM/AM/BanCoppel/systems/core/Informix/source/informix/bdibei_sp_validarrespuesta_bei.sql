CREATE PROCEDURE "informix".sp_validarrespuesta_bei(pid_usuario INTEGER,
									 pIdPregunta INT,
									 pRespuesta CHAR(80))
RETURNING CHAR (5) AS cCod_ret, CHAR(1) AS cResCor;

	--****************************************************************************************************
	-- DESCRIPCION:  VALIDA CADA RESPUESTA DEL USURIO- MODULO OLVIDO CONTRASEÃ?A
	-- Y CAMBIO DE RESPUESTAS DE SEGURIDAD.
	-- AUTOR : SOLSER
	-- FECHA : 05/06/2013
	-- BD: BDIBEI
    -- Modificacion 09/10/2013  Por Casillas se agrega '40' en linea 35
    -- Modificacion 18/06/2014  Por Casillas se agrega '37' y se comenta la 36
	--***************************************************************************************************


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

		--SELECT id_usuario INTO vIdUsuario FROM bdibei:"informix".bei_usuario WHERE id_usuario = pid_usuario AND id_status in ('30' , '40', '90');
        SELECT id_usuario INTO vIdUsuario FROM bdibei:"informix".bei_usuario WHERE id_usuario = pid_usuario;
		SELECT id_usuario INTO vIdusuario FROM bdibei:"informix".bei_respuestas WHERE id_usuario = vIdUsuario AND id_pregunta = pIdPregunta AND desc_resp = pRespuesta;
		IF NVL(vIdusuario, '') = '' THEN
			LET cResCor = '0'; --Incorrecta
		ELSE
			LET cResCor = '1'; --Correcta
		END IF;
		RETURN cCod_ret, cResCor;
	END;
END PROCEDURE;