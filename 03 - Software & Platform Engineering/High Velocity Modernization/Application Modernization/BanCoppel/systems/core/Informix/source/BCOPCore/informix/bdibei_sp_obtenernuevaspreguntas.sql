CREATE PROCEDURE "informix".sp_obtenernuevaspreguntas(pid_usuario INTEGER)
RETURNING  CHAR (5) as cCod_ret, INT as iId_pregunta, CHAR(80) as vDesc_pregunta, CHAR(100) as vLista_resp;

	--****************************************************************************************************
	-- DESCRIPCION:  OBTIENE UN JUEGO DE PREGUNTAS NUEVAS PARA UN USUARIO- MODULO OLVIDO CONTRASEÃÂ¢??A
	-- Y CAMBIO DE RESPUESTAS DE SEGURIDAD.
	-- AUTOR : SOLSER
	-- FECHA : 05/06/2013
	-- BD: BDIBEI
	--***************************************************************************************************


	DEFINE iSql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE iId_pregunta INT;
	DEFINE vDesc_pregunta VARCHAR(80);
	DEFINE iIdRegistro INTEGER;
	DEFINE iOrdAle INTEGER;
	DEFINE iOrdAleAux INTEGER;
	DEFINE iIdUsuario INTEGER;
	DEFINE iNum_pregunta INTEGER;
	DEFINE vLista_resp VARCHAR(100);

	LET cCod_ret = '00000';
	LET iId_pregunta = 0;
	LET vDesc_pregunta = '';
	LET iIdRegistro = 0;
	LET iOrdAle = 0;
	LET iOrdAleAux = 0;
	LET iIdUsuario = 0;
	LET iNum_pregunta = 0;
	LET vLista_resp = '';



	BEGIN
		ON EXCEPTION SET iSql_err
		  IF iSql_err <> 0 THEN
				LET cCod_ret = iSql_err;
				RETURN cCod_ret, iId_pregunta, vDesc_pregunta, vLista_resp;
		  END IF ;
		END EXCEPTION ;

		IF NVL(pid_usuario, '') <> '' AND pid_usuario > 0 THEN
			SET LOCK MODE TO WAIT 3;
			SELECT id_usuario INTO iIdUsuario FROM "informix".bei_usuario WHERE id_usuario = pid_usuario;

			LET iIdRegistro = iIdUsuario;
            DELETE FROM "informix".bei_cat_preguntas_auxpm WHERE id_registro = iIdRegistro;

			SELECT count(CA.id_pregunta) INTO iNum_pregunta
			FROM bdibei:"informix".bei_cat_preguntaspm CA
				LEFT OUTER JOIN "informix".bei_preguntas_his HT ON CA.id_pregunta=HT.id_pregunta AND HT.id_usuario = iIdUsuario
			WHERE HT.id_pregunta IS NULL;

			IF NVL(iNum_pregunta, 0) < 6 THEN
				SET LOCK MODE TO WAIT 3;
				DELETE FROM "informix".bei_preguntas_his WHERE id_usuario = iIdUsuario;
			END IF

			SET LOCK MODE TO WAIT 3;
			FOREACH

				--Verifica las preguntas que ya ha usado el usuario
				SELECT CPG.id_pregunta, CPG.desc_pregunta, CPG.lista_resp
				INTO iId_pregunta, vDesc_pregunta, vLista_resp
				FROM "informix".bei_cat_preguntaspm as CPG
					LEFT OUTER JOIN "informix".bei_preguntas_his as HTS ON HTS.id_usuario = iIdUsuario AND HTS.id_pregunta = CPG.id_pregunta
				WHERE CPG.activo = 't'
				AND HTS.id_pregunta IS NULL
				ORDER BY CPG.id_pregunta

				LET iOrdAleAux = iOrdAle;
				EXECUTE PROCEDURE bdibpi:"informix".sp_random(iOrdAleAux, 100) INTO iOrdAle;

				INSERT INTO "informix".bei_cat_preguntas_auxpm(id_ordenamiento, id_pregunta, desc_pregunta, id_registro, lista_resp) VALUES (iOrdAle, iId_pregunta, vDesc_pregunta, iIdRegistro, vLista_resp);
			END FOREACH;

			SET LOCK MODE TO WAIT 3;
			FOREACH
				SELECT LIMIT 5 id_pregunta, desc_pregunta, lista_resp
				INTO iId_pregunta, vDesc_pregunta, vLista_resp
				FROM "informix".bei_cat_preguntas_auxpm
				WHERE id_registro = iIdRegistro
				ORDER BY id_ordenamiento

				RETURN cCod_ret, iId_pregunta, vDesc_pregunta, vLista_resp WITH RESUME;
			END FOREACH;

			SET LOCK MODE TO WAIT 3;

			--Borra registros de la tabla auxiliar.
			DELETE FROM "informix".bei_cat_preguntas_auxpm WHERE id_registro = iIdRegistro;
		ELSE
			LET cCod_ret = '00001';
			RETURN cCod_ret, iId_pregunta, vDesc_pregunta, vLista_resp WITH RESUME;
		END IF
	END;
END PROCEDURE;