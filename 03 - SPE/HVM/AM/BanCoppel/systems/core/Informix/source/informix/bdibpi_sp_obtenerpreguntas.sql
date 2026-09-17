CREATE PROCEDURE "informix".sp_obtenerpreguntas()
RETURNING CHAR (5), INT, CHAR(50);
	-- Creador: Javier Calderón
	-- Objetivo: Obtiene preguntas
	-- Solicitó: Diana Castellanos
	-- Fecha: 16/11/2010
	
	-- Modificado: Manuel Ramos Figueroa
	-- Descripción: Se modifica para retornar solo 5 preguntas del total con tipo igual 1
	-- Fecha: 10/11/2011

	DEFINE iSql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE iId_pregunta INT;
	DEFINE vDesc_pregunta VARCHAR(50);
	DEFINE iIdRegistro INTEGER;
	DEFINE iOrdAle INTEGER;
	DEFINE iOrdAleAux INTEGER;

	LET cCod_ret = '00000';
	LET iId_pregunta = 0;
	LET vDesc_pregunta = '';
	LET iIdRegistro = 0;
	LET iOrdAle = 0;
	LET iOrdAleAux = 0;

	--SET DEBUG FILE TO "sp_obtenerpreguntas.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
		  IF iSql_err <> 0 THEN
				LET cCod_ret = iSql_err;
				RETURN cCod_ret, iId_pregunta, vDesc_pregunta;
		  END IF ;
		END EXCEPTION ;

		EXECUTE PROCEDURE sp_random(0, 1000) INTO iIdRegistro;

		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT id_pregunta, desc_pregunta 
			INTO iId_pregunta, vDesc_pregunta 
			FROM bdibpi:"informix".bpi_cat_preguntas 
			WHERE tipo = 1 
			AND activo = 't' 
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