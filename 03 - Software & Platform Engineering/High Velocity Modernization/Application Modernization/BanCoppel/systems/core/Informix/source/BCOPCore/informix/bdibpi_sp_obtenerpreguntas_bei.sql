CREATE PROCEDURE "informix".sp_obtenerpreguntas_bei()
RETURNING CHAR (5), INT, CHAR(70), CHAR(100);
	-- Creador: Manuel Ramos Figueroa
	-- Objetivo: Obtiene preguntas
	-- Fecha: 22/07/2011
	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE iId_pregunta INT;
	DEFINE vDesc_pregunta VARCHAR(70);
	DEFINE iIdRegistro INTEGER;
	DEFINE iOrdAle INTEGER;
	DEFINE iOrdAleAux INTEGER;
	DEFINE vLista_resp VARCHAR(100);
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret, iId_pregunta, vDesc_pregunta, vLista_resp;
		  END IF ;
		END EXCEPTION ;
		
		LET cCod_ret = '00000';
		LET iId_pregunta = 0;
		LET vDesc_pregunta = '';
		LET iIdRegistro = 0;
		LET iOrdAle = 0;
		LET iOrdAleAux = 0;
		LET vLista_resp = '';
		
		EXECUTE PROCEDURE sp_random(0, 1000) INTO iIdRegistro;
		FOREACH
			SELECT id_pregunta, desc_pregunta, lista_resp 
			INTO iId_pregunta, vDesc_pregunta, vLista_resp 
			FROM bdibpi:"informix".bpi_cat_preguntaspm 
			WHERE activo = 't' 
			AND id_pregunta < 10
			ORDER BY id_pregunta
			
			LET iOrdAleAux = iOrdAle;
			EXECUTE PROCEDURE bdibpi:"informix".sp_random(iOrdAleAux, 100) INTO iOrdAle;
		
			INSERT INTO bdibpi:"informix".bpi_cat_preguntas_auxpm(id_ordenamiento, id_pregunta, desc_pregunta, id_registro, lista_resp) VALUES (iOrdAle, iId_pregunta, vDesc_pregunta, iIdRegistro, vLista_resp);
		END FOREACH;
		
		FOREACH
			SELECT LIMIT 10 id_pregunta, desc_pregunta, lista_resp 
			INTO iId_pregunta, vDesc_pregunta, vLista_resp 
			FROM bdibpi:"informix".bpi_cat_preguntas_auxpm 
			WHERE id_registro = iIdRegistro
			ORDER BY id_ordenamiento
			
			RETURN cCod_ret, iId_pregunta, vDesc_pregunta, vLista_resp WITH RESUME;
		END FOREACH;
		
		DELETE FROM bdibpi:"informix".bpi_cat_preguntas_auxpm WHERE id_registro = iIdRegistro;
	END;

END PROCEDURE;