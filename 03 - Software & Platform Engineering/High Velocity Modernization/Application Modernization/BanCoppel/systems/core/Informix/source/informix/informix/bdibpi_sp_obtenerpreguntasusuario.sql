CREATE PROCEDURE "informix".sp_obtenerpreguntasusuario(pNumCliente VARCHAR(9), pLimite INT)
RETURNING CHAR (5), INT, CHAR(50);
	-- Creador: Javier Calderón
	-- Objetivo: Obtiene preguntas del usuario
	-- Solicitó: Diana Castellanos
	-- Fecha: 17/11/2010

	-- Modifico: Manuel Ramos Figueroa
	-- Objetivo: Se modifico para que retorne las preguntas del usuario con excepcion de las asociaciones (id_pregunta = 1010)
	-- Fecha: 10/11/2011

	-- Modifico: René Aldana Hernández
	-- Objetivo: Se modifico para grabar el id_registro en la tabla auxiliar
	-- Fecha: 13/07/2015	
	
	DEFINE iSql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE iId_pregunta INT;
	DEFINE vDesc_pregunta VARCHAR(50);
	DEFINE iIdRegistro INTEGER;
	DEFINE iOrdAle INTEGER;
	DEFINE iOrdAleAux INTEGER;
	DEFINE iIdUsuario INTEGER;
	DEFINE xIdUsuario INTEGER;
	DEFINE iLen       INTEGER;

	LET cCod_ret = '00000';
	LET iId_pregunta = 0;
	LET vDesc_pregunta = '';
	LET iIdRegistro = 0;
	LET iOrdAle = 0;
	LET iOrdAleAux = 0;
	LET iLen = 5;

	--SET DEBUG FILE TO "/home/informix/raldana/casos1010/spl/splModAlek/sp_obtenerpreguntasusuario.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
		  IF iSql_err <> 0 THEN
				LET cCod_ret = iSql_err;
				RETURN cCod_ret, iId_pregunta, vDesc_pregunta;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;
		SELECT id_usuario INTO iIdUsuario FROM bdibpi:"informix".bpi_usuario 
			WHERE numcliente = pNumCliente AND st_portal = 'activo';
			
		--EXECUTE PROCEDURE sp_random(0, 1000) INTO iIdRegistro;
		LET iIdRegistro = 0;

		-- VALIDA PREGUNTAS
		SELECT COUNT(*) INTO iIdRegistro
				FROM bdibpi:"informix".bpi_resp_seguridad 
				WHERE id_usuario = iIdUsuario
				AND id_pregunta <> 1010;
		
		IF iIdRegistro < 5 THEN
			LET iOrdAle = -1;
			FOREACH
				SELECT id_usuario INTO xIdUsuario FROM bdibpi:"informix".bpi_usuario 
					WHERE numcliente = pNumCliente AND st_portal = 'inactivo'
					ORDER BY id_usuario DESC
				
				SELECT COUNT(*) INTO iIdRegistro
				FROM bdibpi:"informix".bpi_resp_seguridad 
				WHERE id_usuario = xIdUsuario
				AND id_pregunta <> 1010;	
				IF iIdRegistro >= 5 THEN
					LET iOrdAle = 1;
					EXIT FOREACH;
				END IF;
			END FOREACH;
			IF iOrdAle < 0 THEN
				IF (SELECT count(numcte) FROM bdinteg:si_bpiusuarios WHERE numcte = pNumCliente AND id_status='40' ) = 1 THEN
					EXECUTE PROCEDURE bdibpi:sp_actualiza_status_bpi('001', pNumCliente, '50', '0.0.0.0', '5003', 'transBPI');
				END IF;
				LET cCod_ret = '00003';
				RETURN cCod_ret, iId_pregunta, vDesc_pregunta; 
			END IF;
							
			DELETE 	FROM bdibpi:"informix".bpi_resp_seguridad 
			WHERE id_usuario = iIdUsuario
			AND id_pregunta <> '1010';
				
			UPDATE bdibpi:"informix".bpi_resp_seguridad SET id_usuario = iIdUsuario
			WHERE id_usuario = xIdUsuario
			AND id_pregunta <> 1010;			
		END IF;
		
		LET iOrdAle = 0;
		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT pre.id_pregunta, pre.desc_pregunta INTO iId_pregunta, vDesc_pregunta
				FROM 
					bdibpi:"informix".bpi_cat_preguntas pre
					INNER JOIN bdibpi:"informix".bpi_resp_seguridad res ON res.id_pregunta = pre.id_pregunta
				WHERE res.id_usuario = iIdUsuario
				AND res.id_pregunta < 1010
				ORDER BY pre.id_pregunta
		
			LET iOrdAleAux = iOrdAle;
			EXECUTE PROCEDURE sp_random(iOrdAleAux, 100) INTO iOrdAle;

			INSERT INTO bdibpi:"informix".bpi_cat_preguntas_aux (id_ordenamiento, id_pregunta, desc_pregunta, id_registro) 
				VALUES (iOrdAle, iId_pregunta, vDesc_pregunta, iIdUsuario);
		END FOREACH;

		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT LIMIT pLimite id_pregunta, desc_pregunta 
			INTO iId_pregunta, vDesc_pregunta 
			FROM bdibpi:"informix".bpi_cat_preguntas_aux 
			WHERE id_registro = iIdUsuario
			ORDER BY id_ordenamiento

			RETURN cCod_ret, iId_pregunta, vDesc_pregunta WITH RESUME;
		END FOREACH;

		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdibpi:"informix".bpi_cat_preguntas_aux WHERE id_registro = iIdUsuario;
		
		
	END;
END PROCEDURE;