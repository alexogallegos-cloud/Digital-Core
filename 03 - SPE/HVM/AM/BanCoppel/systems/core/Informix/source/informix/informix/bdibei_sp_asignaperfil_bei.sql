CREATE PROCEDURE "informix".sp_asignaperfil_bei(pIdUsuario INTEGER, pIdPerfil INTEGER)
RETURNING CHAR (5);

--****************************************************************************************************
-- DESCRIPCION:  Asgina un Perfil a un Usuario
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************
	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);

	LET cCod_ret = '00000';

	BEGIN
--****************************************************************************************************
-- Excepciones:
--***************************************************************************************************
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret;
		  END IF ;
		END EXCEPTION ;
--****************************************************************************************************
-- Valida Si Los datos fueron proporcionados
--***************************************************************************************************

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;


		IF NVL(pIdUsuario, -1) == -1 THEN
			LET cCod_ret = '00001'; -- Sin id De Usuario
				RETURN cCod_ret;
		END IF;

		IF NVL(pIdPerfil, -1)== -1 THEN
			LET cCod_ret = '00002'; -- Sin Id de Perfil
				RETURN cCod_ret;
		END IF;

--****************************************************************************************************
-- Proceso de Actualizacion o Insert:
--***************************************************************************************************


		INSERT INTO "informix".bei_usuario_perfil
			(id_usuario,id_perfil) VALUES
			(pIdUsuario,pIdPerfil);

		RETURN cCod_ret;

	END;

END PROCEDURE;