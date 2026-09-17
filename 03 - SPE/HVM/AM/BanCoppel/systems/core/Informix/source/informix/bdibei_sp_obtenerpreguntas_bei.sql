CREATE PROCEDURE "informix".sp_obtenerpreguntas_bei()
RETURNING  CHAR (5) as cCod_ret, INT as iId_pregunta, CHAR(70) as vDesc_pregunta, CHAR(100) as vLista_resp;
	--****************************************************************************************************
	-- DESCRIPCION:  CONSULTA DE PREGUNTA EN EL MODULO DE ACTIVACION DE USUARIO
	-- AUTOR : SOLSER
	-- FECHA : 05/06/2013
	-- BD: BDIBEI
	--***************************************************************************************************

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

		--EXECUTE PROCEDURE bdibpi:"informix".sp_random(0, 1000) INTO iIdRegistro;
		FOREACH

			--Consulta las primeras 5 preguntas del catalogo
			SELECT LIMIT 5 id_pregunta, desc_pregunta, lista_resp
			INTO iId_pregunta, vDesc_pregunta, vLista_resp
			FROM bdibei:"informix".bei_cat_preguntaspm
			WHERE activo = 't'
			
			RETURN cCod_ret, iId_pregunta, vDesc_pregunta, vLista_resp WITH RESUME;
			 
		END FOREACH;
		
		
	END;

END PROCEDURE;