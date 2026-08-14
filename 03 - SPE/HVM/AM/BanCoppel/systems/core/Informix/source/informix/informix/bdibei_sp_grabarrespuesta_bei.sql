CREATE PROCEDURE "informix".sp_grabarrespuesta_bei(pIdUsuario INTEGER,
									pIdPregunta INT,
									pDescResp VARCHAR(80), pBorrar INT)
RETURNING CHAR (5) AS cCod_ret;

	--****************************************************************************************************
	-- DESCRIPCION:  GRABA LAS RESPUESTAS DE SEGURIDAD UNA POR UNA
	-- AUTOR : SOLSER
	-- FECHA : 05/06/2013
	-- BD: BDIBEI
	-- Modificado: En caso de que hacer un Reset y se pase por la activación nuevamanete, se valida
	-- si el usuario ya utilizo algunas de las preguntas que se le realisa en pantalla, se elimina de su 
	-- historial de preguntas para permitir guardar la nueva pregunta.
	-- Modifico: Berenice Noriega - BanCoppel
	-- Solito: Alejandro Vazquez - Coordinacion Internet
	-- Fecha: 11 Diciembre 2014
	--***************************************************************************************************

	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE cIdUsuario INTEGER;

	LET cCod_ret = '00000';
	LET cIdUsuario = 0;

	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;

		--Consulta si EL usuario Existe
		SELECT id_usuario INTO cIdUsuario FROM "informix".bei_usuario WHERE id_usuario = pIdUsuario;

		IF cIdUsuario=0 THEN
			LET cCod_ret='00001';
			RETURN cCod_ret;
		END IF;

		IF pBorrar = 1 THEN
			SET LOCK MODE TO WAIT ;

				DELETE FROM "informix".bei_respuestas WHERE id_usuario = pIdUsuario ;
		END IF

		---**********************************************************************************************--

		IF EXISTS (  SELECT id_usuario FROM "informix".bei_preguntas_his
   			     WHERE id_usuario = pIdUsuario AND id_pregunta = pIdPregunta) THEN

			DELETE "informix".bei_preguntas_his WHERE id_usuario = pIdUsuario AND id_pregunta=pIdPregunta ;
		END IF;

		---**********************************************************************************************--



		INSERT INTO "informix".bei_respuestas (id_pregunta, id_usuario, desc_resp, f_ultima_mod) VALUES (pIdPregunta, pIdUsuario, pDescResp, TODAY);


		RETURN cCod_ret;

	END;

END PROCEDURE;