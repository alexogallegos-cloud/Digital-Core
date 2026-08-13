CREATE PROCEDURE "informix".sp_obtenerpreguntasusuario_bei(pid_usuario INTEGER, pLimite INT)
RETURNING CHAR (5) as cCod_ret, INT as iId_pregunta, CHAR(70) as vDesc_pregunta, CHAR(100) as vLista_resp;

	--****************************************************************************************************
	-- DESCRIPCION:  OBTIENE LAS PREGUNTAS VIGENTES DEL USUARIO- MODULO OLVIDO CONTRASEÃ?A
	-- Y CAMBIO DE RESPUESTAS DE SEGURIDAD.
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
	DEFINE iIdUsuario CHAR(8);
	DEFINE vLista_resp VARCHAR(100);

	LET cCod_ret = '00000';
	LET iId_pregunta = 0;
	LET vDesc_pregunta = '';
	LET iIdRegistro = 0;
	LET iOrdAle = 0;
	LET iOrdAleAux = 0;
	LET vLista_resp = '';
	
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret, iId_pregunta, vDesc_pregunta, vLista_resp;
		  END IF ;
		END EXCEPTION ;

		SELECT id_usuario INTO iIdUsuario FROM bdibei:"informix".bei_usuario WHERE id_usuario = pid_usuario ;



		FOREACH
			SELECT  LIMIT pLimite rsp.id_pregunta, prg.desc_pregunta, prg.lista_resp
			INTO iId_pregunta, vDesc_pregunta, vLista_resp
			FROM bdibei:"informix".bei_respuestas rsp
            INNER JOIN bdibei:"informix".bei_cat_preguntaspm prg ON prg.id_pregunta = rsp.id_pregunta            
			WHERE rsp.id_usuario = iIdUsuario
			ORDER BY rsp.id_pregunta DESC

 			RETURN cCod_ret, iId_pregunta, vDesc_pregunta, vLista_resp WITH RESUME;
			
		END FOREACH;

	END;

END PROCEDURE;