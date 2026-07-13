CREATE PROCEDURE "informix".sp_obtenerpregstoken_bei()
RETURNING CHAR (5), INT, CHAR(70);

	-- Creador: Manuel Ramos Figueroa
	-- Objetivo: Obtiene conceptos
	-- Fecha: 05/08/2011

	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE iId_pregunta INT;
	DEFINE vDesc_pregunta VARCHAR(70);
	DEFINE iIdRegistro INTEGER;
	DEFINE iOrdAle INTEGER;
	DEFINE iOrdAleAux INTEGER;

	LET cCod_ret = '00000';
	LET iId_pregunta = 0;
	LET vDesc_pregunta = '';
	LET iIdRegistro = 0;
	LET iOrdAle = 0;
	LET iOrdAleAux = 0;

	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret, iId_pregunta, vDesc_pregunta;
		  END IF ;
		END EXCEPTION ;

		EXECUTE PROCEDURE bdibpi:"informix".sp_random(0, 1000) INTO iIdRegistro;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;

		FOREACH
			SELECT id_pregunta, desc_pregunta
			INTO iId_pregunta, vDesc_pregunta
			FROM bdibpi:"informix".bpi_cat_preguntaspm
			WHERE activo = 't'
			AND id_pregunta > 9
			ORDER BY id_pregunta

			LET iOrdAleAux = iOrdAle;
			EXECUTE PROCEDURE bdibpi:"informix".sp_random(iOrdAleAux, 100) INTO iOrdAle;

			INSERT INTO bdibpi:"informix".bpi_cat_preguntas_auxpm(id_ordenamiento, id_pregunta, desc_pregunta, id_registro) VALUES (iOrdAle, iId_pregunta, vDesc_pregunta, iIdRegistro);
		END FOREACH;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;

		FOREACH
			SELECT LIMIT 10 id_pregunta, desc_pregunta
			INTO iId_pregunta, vDesc_pregunta
			FROM bdibpi:"informix".bpi_cat_preguntas_auxpm
			WHERE id_registro = iIdRegistro
			ORDER BY id_ordenamiento

			RETURN cCod_ret, iId_pregunta, vDesc_pregunta WITH RESUME;
		END FOREACH;

		SET LOCK MODE TO WAIT ;

		DELETE FROM bdibpi:"informix".bpi_cat_preguntas_auxpm WHERE id_registro = iIdRegistro;
	END;

END PROCEDURE;