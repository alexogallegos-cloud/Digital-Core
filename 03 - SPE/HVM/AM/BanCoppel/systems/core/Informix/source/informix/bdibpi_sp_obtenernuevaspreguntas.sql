CREATE PROCEDURE "informix".sp_obtenernuevaspreguntas(pNumCte char(10))
RETURNING CHAR (5), INT, CHAR(50);
	-- Creador: Manuel Ramos Figueroa
	-- Objetivo: Obtiene preguntas nuevas para el proceso de renovación de preguntas de seguridad de la BPI
	-- Fecha: 10/11/2011

	DEFINE iSql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE iId_pregunta INT;
	DEFINE vDesc_pregunta VARCHAR(50);
	DEFINE iIdRegistro INTEGER;
	DEFINE iOrdAle INTEGER;
	DEFINE iOrdAleAux INTEGER;
	DEFINE iIdUsuario INTEGER;
	DEFINE iNum_pregunta INTEGER;

	LET cCod_ret = '00000';
	LET iId_pregunta = 0;
	LET vDesc_pregunta = '';
	LET iIdRegistro = 0;
	LET iOrdAle = 0;
	LET iOrdAleAux = 0;
	LET iIdUsuario = 0;
	LET iNum_pregunta = 0;

	--SET DEBUG FILE TO "/informix/tmp/sp_obtenernuevaspreguntas.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
		  IF iSql_err <> 0 THEN
				LET cCod_ret = iSql_err;
				RETURN cCod_ret, iId_pregunta, vDesc_pregunta;
		  END IF ;
		END EXCEPTION ;

		IF NVL(pNumCte, '') <> '' AND TRIM(pNumCte) > 0 THEN
			SET LOCK MODE TO WAIT 3;
			SELECT id_usuario INTO iIdUsuario FROM bdibpi:"informix".bpi_usuario WHERE numcliente = pNumCte AND st_portal = 'activo';

			EXECUTE PROCEDURE sp_random(0, 1000) INTO iIdRegistro;
			
			SELECT count(CA.id_pregunta) INTO iNum_pregunta 
			FROM bdibpi:"informix".bpi_cat_preguntas CA 
				LEFT OUTER JOIN bdibpi:"informix".bpi_preguntas_his HT ON CA.id_pregunta=HT.id_pregunta AND HT.id_usuario = iIdUsuario 
			WHERE CA.tipo = 1 AND HT.id_pregunta IS NULL;
			
			IF NVL(iNum_pregunta, 0) < 6 THEN
				SET LOCK MODE TO WAIT 3;
				DELETE FROM bdibpi:"informix".bpi_preguntas_his WHERE id_usuario = iIdUsuario;
			END IF
			
			SET LOCK MODE TO WAIT 3;
			FOREACH
				
				SELECT CPG.id_pregunta, CPG.desc_pregunta 
				INTO iId_pregunta, vDesc_pregunta 
				FROM bdibpi:"informix".bpi_cat_preguntas as CPG
					LEFT OUTER JOIN bdibpi:"informix".bpi_preguntas_his as HTS ON HTS.id_usuario = iIdUsuario AND HTS.id_pregunta = CPG.id_pregunta 
				WHERE CPG.tipo = 1 
				AND CPG.activo = 't' 				
				AND HTS.id_pregunta IS NULL
				ORDER BY CPG.id_pregunta 

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
		ELSE
			LET cCod_ret = '00001';
			RETURN cCod_ret, iId_pregunta, vDesc_pregunta WITH RESUME;
		END IF
	END;
END PROCEDURE;