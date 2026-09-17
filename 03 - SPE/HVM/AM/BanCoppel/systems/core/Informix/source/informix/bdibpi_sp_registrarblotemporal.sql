CREATE PROCEDURE "informix".sp_registrarblotemporal(pFechaBloq DATETIME YEAR TO SECOND,
										 pNumCliente VARCHAR(9),
										 pTipoBloq VARCHAR(5),
										 pTipoBloqTemp  INT)
RETURNING CHAR (5);
	-- Creador: Javier Calderón
	-- Objetivo: Registra bloqueo temporal del usuario
	-- Solicitó: Diana Castellanos
	-- Fecha: 17/11/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		
		IF (pTipoBloq = 'ATOK') THEN --Activacion de Token
			UPDATE bpi_usuario SET fecha_bloqueo = pFechaBloq WHERE numcliente = pNumCliente AND st_portal = 'activo';
		ELIF (pTipoBloq = 'CPASS') THEN --Cambio de Password
			UPDATE bpi_usuario SET fecha_bloqueo_camb_pass = pFechaBloq, tipo_bloq_temp_pass = pTipoBloqTemp WHERE numcliente = pNumCliente AND st_portal = 'activo';
		ELIF (pTipoBloq = 'CRESP') THEN --Cambio de Respuestas
			UPDATE bpi_usuario SET fecha_bloqueo_camb_pregs = pFechaBloq, tipo_bloq_temp_resp = pTipoBloqTemp WHERE numcliente = pNumCliente AND st_portal = 'activo';
		ELSE
			LET vCod_ret = '00001';
		END IF;
		
		RETURN vCod_ret;
		
	END;

END PROCEDURE;