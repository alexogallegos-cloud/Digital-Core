CREATE PROCEDURE "informix".sps_grabarrespuesta(pNumCliente VARCHAR(9), pIdPregunta INT, pDescResp VARCHAR(80), pBorrar INT, pTipo INT, pIndicador CHAR(1))
RETURNING CHAR (5);
	
	-- Creador: Moisés Soriano
	-- Objetivo: Registra respuestas del usuario
	-- Se clona sp_grabarrespuesta, se agrega parametro pIndicador = 1 recibe id_usuario, pIndicador = 2 recibe numcte
	-- Solicitó: Alejandro Vazquez
	-- Fecha: 08/04/2016
	-- Bibiana Gaxiola Verdugo
	-- Se agrega validación: si la nueva pregunta-respuesta a insertar ya se encuentra en el histórico de preguntas,
	-- se borra la pregunta del histórico antes de insertar la nueva pregunta-respuesta, para que no cause problemas en el trigger que inserta las preguntas históricas
	-- 23/05/2016
	
	DEFINE iSql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE iIdUsuario INT;
	DEFINE iIdPregunta INT;
	DEFINE exId_usuario INT;
	
	LET cCod_ret = '00000';
	LET iIdUsuario = 0;
	LET iIdPregunta = 0;
	LET exId_usuario = 0;

	--SET DEBUG FILE TO "/home/informix/bibiana/sp_grabarrespuesta.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
		  IF iSql_err <> 0 THEN
				LET cCod_ret = iSql_err;
				RETURN cCod_ret;
		  END IF ;
		END EXCEPTION ;

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pIndicador = '1' THEN  -- pNumCliente = id_usuario
			LET iIdUsuario = pNumCliente;
		ELIF pIndicador = '2' THEN -- pNumCliente = numcliente
			SELECT id_usuario INTO iIdUsuario FROM bdibpi:"informix".bpi_usuario WHERE numcliente = pNumCliente AND st_portal = 'activo';
		END IF;
		
		IF pBorrar = 1 THEN
			SET LOCK MODE TO WAIT ;
			IF pTipo = 1 THEN
				DELETE FROM bdibpi:"informix".bpi_resp_seguridad WHERE id_usuario = iIdUsuario AND id_pregunta <> 1010;
			END IF
            IF pTipo = 2 THEN
				DELETE FROM bdibpi:"informix".bpi_resp_seguridad WHERE id_usuario = iIdUsuario AND id_pregunta = 1010;
			END IF
		END IF
		
		IF pBorrar = 0 AND pTipo = 2 THEN						    
			 SELECT distinct(id_usuario) INTO exId_usuario FROM bdibpi:"informix".bpi_resp_seguridad 
				WHERE id_usuario IN (select  id_usuario from bdibpi:"informix".bpi_usuario where numcliente = pNumCliente)
				AND  id_pregunta = '1010'; 													
				DELETE FROM bdibpi:"informix".bpi_resp_seguridad WHERE id_usuario = exId_usuario AND id_pregunta = 1010;					
		END IF

		-- Se valida si la pregunta ya existe en el historico, de ser asi primero se borra la pregunta del historico y despues se inserta
		IF (SELECT count(id_pregunta) FROM bdibpi:"informix".bpi_preguntas_his WHERE id_usuario = iIdUsuario AND id_pregunta = pIdPregunta) > 0 THEN
			--Se borra la pregunta anterior que ya estaba en el historico
			DELETE FROM bdibpi:"informix".bpi_preguntas_his WHERE id_usuario = iIdUsuario AND id_pregunta = pIdPregunta;
			--Se inserta la Nueva Respuesta y Pregunta con la nueva fecha de insersion
			INSERT INTO bdibpi:"informix".bpi_resp_seguridad (id_pregunta, id_usuario, desc_resp, f_ultima_mod, encriptado) VALUES (pIdPregunta, iIdUsuario, pDescResp, TODAY, 1);
		ELSE
			INSERT INTO bdibpi:"informix".bpi_resp_seguridad (id_pregunta, id_usuario, desc_resp, f_ultima_mod, encriptado) VALUES (pIdPregunta, iIdUsuario, pDescResp, TODAY, 1);
		END IF
		
		RETURN cCod_ret;
	END;
END PROCEDURE;