CREATE PROCEDURE "informix".sp_obtenernuevaspregstoken(pNumCte char(10))
RETURNING CHAR (5), INT, CHAR(50);
	-- Creador: Manuel Ramos Figueroa
	-- Objetivo: Obtiene asociaciones nuevas para el proceso de desbloqueo de token de la BPI
	-- Fecha: 10/11/2011

	DEFINE iSql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE iId_pregunta INT;
	DEFINE vDesc_pregunta VARCHAR(50);
	DEFINE iIdRegistro INTEGER;
	DEFINE iOrdAle INTEGER;
	DEFINE iOrdAleAux INTEGER;
	DEFINE iIdUsuario INTEGER;
	DEFINE iLongID INTEGER;

	LET cCod_ret = '00000';
	LET iId_pregunta = 0;
	LET vDesc_pregunta = '';
	LET iIdRegistro = 0;
	LET iOrdAle = 0;
	LET iOrdAleAux = 0;
	LET iIdUsuario = 0;
	LET iLongID = 3;

	--SET DEBUG FILE TO "sp_obtenernuevaspregstoken.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
		  IF iSql_err <> 0 THEN
				LET cCod_ret = iSql_err;
				RETURN cCod_ret, iId_pregunta, vDesc_pregunta;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;		
		SELECT id_usuario INTO iIdUsuario FROM bdibpi:"informix".bpi_usuario WHERE numcliente = pNumCte AND st_portal = 'activo';
		
		EXECUTE PROCEDURE sp_random(0, 1000) INTO iIdRegistro;

		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT id_pregunta, desc_pregunta 
			INTO iId_pregunta, vDesc_pregunta 
			FROM bdibpi:"informix".bpi_cat_preguntas 
			WHERE tipo = 2 
			AND activo = 't' 
			AND id_pregunta <> (select substr(desc_resp, 1, iLongID) from bdibpi:bpi_resp_seguridad where id_usuario = iIdUsuario and id_pregunta = 1010)
			AND id_pregunta <> (select substr(desc_resp, 5, iLongID) from bdibpi:bpi_resp_seguridad where id_usuario = iIdUsuario and id_pregunta = 1010)
			AND id_pregunta <> (select substr(desc_resp, 9, iLongID) from bdibpi:bpi_resp_seguridad where id_usuario = iIdUsuario and id_pregunta = 1010)
			AND id_pregunta <> (select substr(desc_resp, 13, iLongID) from bdibpi:bpi_resp_seguridad where id_usuario = iIdUsuario and id_pregunta = 1010)
			AND id_pregunta <> (select substr(desc_resp, 17, iLongID) from bdibpi:bpi_resp_seguridad where id_usuario = iIdUsuario and id_pregunta = 1010)
			ORDER BY id_pregunta

			LET iOrdAleAux = iOrdAle;
			EXECUTE PROCEDURE sp_random(iOrdAleAux, 100) INTO iOrdAle;

			INSERT INTO bdibpi:"informix".bpi_cat_preguntas_aux(id_ordenamiento, id_pregunta, desc_pregunta, id_registro) VALUES (iOrdAle, iId_pregunta, vDesc_pregunta, iIdRegistro);
		END FOREACH;

		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT LIMIT 5 id_pregunta, desc_pregunta 
			INTO iId_pregunta, vDesc_pregunta 
			FROM bdibpi:"informix".bpi_cat_preguntas_aux 
			WHERE id_registro = iIdRegistro
			ORDER BY id_ordenamiento

			RETURN cCod_ret, iId_pregunta, vDesc_pregunta WITH RESUME;
		END FOREACH;

		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdibpi:"informix".bpi_cat_preguntas_aux WHERE id_registro = iIdRegistro;
	END;
END PROCEDURE;