CREATE PROCEDURE "informix".sp_borrarrespuestas_bei(pIdUsuario INTEGER)
RETURNING CHAR (5) AS cCod_ret;

	--****************************************************************************************************
	-- DESCRIPCION:  BORRA LAS RESPUESTAS DE SEGURIDAD DE UN USUARIO
	-- AUTOR : SOLSER
	-- FECHA : 05/06/2013
	-- BD: BDIBEI
	--***************************************************************************************************

	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
		
	LET cCod_ret = '00000';
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;

		--Borra las respuestas del usuario para posteriormente grabar otras
			DELETE FROM "informix".bei_respuestas WHERE id_usuario = pIdUsuario;

		RETURN cCod_ret;

	END;

END PROCEDURE;