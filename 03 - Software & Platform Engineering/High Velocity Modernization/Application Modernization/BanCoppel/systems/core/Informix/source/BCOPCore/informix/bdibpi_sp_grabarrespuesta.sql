CREATE PROCEDURE "informix".sp_grabarrespuesta(pNumCliente VARCHAR(9),
									pIdPregunta INT,
									pDescResp VARCHAR(80), pBorrar INT, pTipo INT)
RETURNING CHAR (5);
	-- Creador: Javier Calderón
	-- Objetivo: Registra respuestas del usuario
	-- Solicitó: Diana Castellanos
	-- Fecha: 16/11/2010

	-- Modifico: Manuel Ramos Figueroa
	-- Objetivo: Se modifica para borrar las preguntas o asociaciones anteriores segun sea el caso.
	-- Fecha: 11/11/2011
	-- Modifico: René Aldana Hernández
	-- Objetivo: Se modifico para la conbinacion del parametro 0 y tipo 2 borre la asociación correcta
	-- Fecha: 13/07/2015
	
	--Modificó: Edgar M. Alarcon
	--Actividad: valida si recibe id de usuario o numero de cliente
	--Solicito: Jose de Jesus
	--Fecha: 05-11-15
	
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

		SET LOCK MODE TO WAIT ;
		SELECT id_usuario INTO iIdUsuario FROM bdibpi:"informix".bpi_usuario WHERE numcliente = pNumCliente AND st_portal = 'activo';
		
		IF iIdUsuario = '' OR iIdUsuario IS NULL THEN
			LET iIdUsuario = pNumCliente;
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
				WHERE id_usuario IN (select  id_usuario from bdibpi:bpi_usuario where numcliente = pNumCliente)
				AND  id_pregunta = '1010'; 													
				DELETE FROM bdibpi:"informix".bpi_resp_seguridad WHERE id_usuario = exId_usuario AND id_pregunta = 1010;					
		END IF

		INSERT INTO bdibpi:"informix".bpi_resp_seguridad (id_pregunta, id_usuario, desc_resp, f_ultima_mod, encriptado) VALUES (pIdPregunta, iIdUsuario, pDescResp, TODAY, 1);

		RETURN cCod_ret;
	END;
END PROCEDURE;