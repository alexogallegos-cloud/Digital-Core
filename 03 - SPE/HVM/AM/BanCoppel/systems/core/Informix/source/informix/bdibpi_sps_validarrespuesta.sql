CREATE PROCEDURE "informix".sps_validarrespuesta(pNumCliente VARCHAR(9), pIdPregunta INT, pRespuesta CHAR(80), pIndicador CHAR(1))
RETURNING CHAR (5), CHAR(1);
	
	-- Creador: Moises Soriano	
	-- Objetivo: Se clona sp_validarrespuesta, se agrega parametro de entrada
	-- Solicitó: Alejandro Vazquez
	-- Fecha: 11/04/2016
	
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vIdUsuario VARCHAR(11);
	DEFINE vResCor CHAR(1);
	
	--SET DEBUG FILE TO "/home/informix/bibiana/sp_validarrespuesta.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vResCor;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		LET vIdUsuario = '';
		
        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3 ;
		
		IF pIndicador = '1' THEN  -- pIndicador = id_usuario
			LET vIdusuario = pNumCliente;
		ELIF pIndicador = '2' THEN -- pIndicador = numcliente
			SELECT id_usuario INTO vIdUsuario FROM bdibpi:"informix".bpi_usuario WHERE numcliente = pNumCliente AND st_portal = 'activo';
		END IF;
		
		SELECT id_usuario INTO vIdusuario FROM bdibpi:"informix".bpi_resp_seguridad WHERE id_usuario = vIdUsuario AND id_pregunta = pIdPregunta AND desc_resp = pRespuesta;
		
		IF NVL(vIdusuario, '') = '' THEN 
			LET vResCor = '0'; --Incorrecta
		ELSE
			LET vResCor = '1'; --Correcta
		END IF;
		RETURN vCod_ret, vResCor;
	END;
END PROCEDURE;