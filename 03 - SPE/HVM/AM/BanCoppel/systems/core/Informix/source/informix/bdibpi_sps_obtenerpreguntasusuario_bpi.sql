CREATE PROCEDURE "informix".sps_obtenerpreguntasusuario_bpi(pIdCliente VARCHAR(9), pLimite INT, pIndicador CHAR(1))
RETURNING CHAR (5), INT, CHAR(50);	
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

	--SET DEBUG FILE TO "/home/informix/bibiana/sp_obtenerpreguntasusuario.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
		  IF iSql_err <> 0 THEN
				LET cCod_ret = iSql_err;
				RETURN cCod_ret, iId_pregunta, vDesc_pregunta;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		IF pIndicador = '1' THEN  -- pIndicador = id_usuario
			LET iIdUsuario = pIdCliente;
		ELIF pIndicador = '2' THEN -- pIndicador = numcliente
			SELECT id_usuario INTO iIdUsuario 
			FROM bdibpi:"informix".bpi_usuario usr INNER JOIN bdinteg:"informix".si_bpiusuarios bpi ON usr.numcliente=bpi.numcte AND usr.st_portal='activo'  
			WHERE usr.numcliente = pIdCliente;
		END IF;
		
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
					WHERE id_usuario = iIdUsuario AND st_portal = 'inactivo'
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
				IF ((SELECT count(numcte) FROM bdinteg:si_bpiusuarios WHERE numcte = pIdCliente AND id_status='40' ) = 1 AND pIndicador = '2') THEN
					EXECUTE PROCEDURE bdibpi:sp_actualiza_status_bpi('001', pIdCliente, '50', '0.0.0.0', '5003', 'transBPI');
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
END PROCEDURE
DOCUMENT
'AUTOR.........: Moises Soriano',
'FECHA.........: 11/04/2016',
'MODIFICACIÓN..: Se clona sps_obtenerpreguntasusuario, se agrega parametro pIndicador',
'SOLICITA......: Alejandro Vazquez',
'BD............: BDIBPI';

CREATE PROCEDURE  "informix".sp_obtenerconceptosctetoken(pNumCliente VARCHAR(9))
RETURNING CHAR (5), INT, CHAR(80), CHAR(1);
	-- Creador: Javier CalderÃ³n
	-- Objetivo: Obtiene conceptos del cliente
	-- SolicitÃ³: Diana Castellanos
	-- Fecha: 18/11/2010

	-- Modifico: Manuel Ramos Figueroa
	-- Objetivo: Se modifico para obtener las asociaciones del cliente con el id_pregunta igual 1010 en la bdibpi:bpi_resp_seguridad
	--	y armar el id_pregunta para la bdibpi:bpi_cat_preguntas con 3 caracteres.
	-- Fecha: 11/11/2011

	-- Modifico: Manuel Ramos Figueroa
	-- Objetivo: Se modifico para armar el id_pregunta para la bdibpi:bpi_cat_preguntas con 3 caracteres para los clientes nuevos y con 2 caracteres para los
	--	clientes viejos
	-- Fecha: 17/11/2011

	-- Modifico: Alejandro VÃ¡zquez FernÃ¡ndez
	-- Objetivo: Se modifico para identificar las asociaciones de seguridad de un id_usuario anterior a causa de un reset de usuario
	-- Fecha: 18/11/2011

	-- Modifico: RenÃ© Aldana HernÃ¡ndez
	-- Objetivo: Se modifico para obtener el numero de id_usuario que contenga el numero de asociaciÃ³n a la pregunta 1010
	-- Fecha: 10/07/2015
	
	-- Modifico: Gabriela Aguilar
	-- Objetivo: Se modifico para aplicar un reset si no se cuenta con pregunta 1010
	-- Fecha: 24/07/2016

	DEFINE iSql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE iId_concepto INT;
	DEFINE iIdUsuario INT;
	DEFINE exId_usuario INT;
	DEFINE vDesc_concepto VARCHAR(50);
	DEFINE vResp_concepto VARCHAR(1);
	DEFINE vCadConcepto VARCHAR(80);
	DEFINE iId_pregunta INT;
	DEFINE iLong_idPregunta INT;
	DEFINE iLong_respuesta INT;
	DEFINE iNum_respuesta INT;
	DEFINE pNumToken char(9);
	DEFINE pStatusViejo char(3);
	


	LET cCod_ret = '00000';
	LET vDesc_concepto = '';
	LET iId_concepto = 0;
	LET vResp_concepto = '';
	LET iIdUsuario = 0;
	LET vCadConcepto = '';
	LET iId_pregunta = 0;
	LET iLong_idPregunta = 0;
	LET iLong_respuesta = 0;
	LET iNum_respuesta = 0;
	LET pNumToken = '0000000000';
	LET pStatusViejo = '000';
	
	

	--SET DEBUG FILE TO "/informix/gaby/pregunta1010/sp_obtenerconceptosctetoken.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
		  IF iSql_err <> 0 THEN
				LET cCod_ret = iSql_err;
				RETURN cCod_ret, iId_concepto, vDesc_concepto, vResp_concepto;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;
		SELECT id_usuario INTO iIdUsuario FROM bdibpi:"informix".bpi_usuario WHERE numcliente = pNumCliente AND st_portal = 'activo';

		SET LOCK MODE TO WAIT 3;
		--SELECT id_pregunta, LENGTH(desc_resp), trim(desc_resp) INTO iId_pregunta, iLong_respuesta, vCadConcepto FROM bdibpi:"informix".bpi_resp_seguridad WHERE id_usuario = iIdUsuario AND id_pregunta = 1010;
		SELECT LIMIT 1 id_pregunta, LENGTH(desc_resp), trim(desc_resp) INTO iId_pregunta, iLong_respuesta, vCadConcepto FROM bdibpi:"informix".bpi_resp_seguridad
		WHERE id_usuario = iIdUsuario AND id_pregunta = 1010 AND f_ultima_mod IN (select max(f_ultima_mod) FROM "informix".bpi_resp_seguridad WHERE id_usuario = iIdUsuario AND id_pregunta = 1010);

		IF NVL(vCadConcepto, '') = '' THEN
			SET LOCK MODE TO WAIT 3;
			 
			SELECT MAX(id_usuario) INTO exId_usuario FROM bdibpi:bpi_resp_seguridad WHERE id_usuario IN (select  id_usuario from bdibpi:"informix".bpi_usuario where numcliente = pNumCliente)
			  AND  id_pregunta = '1010';
			IF EXISTS (SELECT id_pregunta FROM bdibpi:bpi_resp_seguridad WHERE id_pregunta=1010 AND  id_usuario = exId_usuario)  THEN
				SET LOCK MODE TO WAIT 3;
				UPDATE bdibpi:bpi_resp_seguridad SET id_usuario=iIdUsuario, f_ultima_mod=TODAY  WHERE id_pregunta=1010 AND  id_usuario = exId_usuario;
				SELECT id_pregunta, LENGTH(desc_resp), trim(desc_resp) INTO iId_pregunta, iLong_respuesta, vCadConcepto FROM bdibpi:"informix".bpi_resp_seguridad WHERE id_usuario = iIdUsuario AND id_pregunta = 1010;
			else
				 SELECT ns_token, id_status_token INTO pNumToken, pStatusViejo  FROM bdinteg:"informix".si_bpitoken WHERE num_cliente = pNumCliente;						
					 IF pStatusViejo='151' THEN
						 EXECUTE PROCEDURE bdibpi:"informix".sp_resetstatus_token(pNumCliente, pNumToken, '130', 'TrasBPI', '003') INTO cCod_ret;
						 RETURN cCod_ret, iId_concepto, vDesc_concepto, vResp_concepto;
					 else
						  LET cCod_ret='902';						  RETURN cCod_ret, iId_concepto, vDesc_concepto, vResp_concepto;
					 END IF;
			END IF;
		END IF;
	
	
		IF NVL(vCadConcepto, '') <>  '' THEN
			IF LENGTH(vCadConcepto) < 30 THEN
				LET iLong_idPregunta = 3;
			ELSE
				LET iLong_idPregunta = 2;
			END IF
		END IF

		WHILE (LENGTH(vCadConcepto) > 0 AND iNum_respuesta < 5)
			LET iId_concepto = SUBSTR(vCadConcepto, 1, iLong_idPregunta)::INT;
			LET vResp_concepto = SUBSTR(vCadConcepto, iLong_idPregunta + 1, 1);
			LET vCadConcepto = SUBSTR(vCadConcepto, iLong_idPregunta + 2);
			LET iNum_respuesta = iNum_respuesta + 1;
			SET LOCK MODE TO WAIT 3;
			SELECT desc_pregunta INTO vDesc_concepto FROM bdibpi:"informix".bpi_cat_preguntas WHERE id_pregunta = iId_concepto;
				
			RETURN cCod_ret, iId_concepto, vDesc_concepto, vResp_concepto WITH RESUME;
		END WHILE;
	END;
END PROCEDURE;