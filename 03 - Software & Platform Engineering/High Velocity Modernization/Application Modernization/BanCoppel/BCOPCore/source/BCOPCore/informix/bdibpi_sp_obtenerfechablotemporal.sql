CREATE PROCEDURE "informix".sp_obtenerfechablotemporal(pNumCliente VARCHAR(9),
											pTipoBloq VARCHAR(5))
RETURNING CHAR (5), DATETIME YEAR TO SECOND, INT;
	-- Creador: Javier Calderón
	-- Objetivo: Obtiene bloqueo temporal del usuario
	-- Solicitó: Diana Castellanos
	-- Fecha: 17/11/2010
	DEFINE sql_err INT;
	DEFINE vCod_ret CHAR (5);
	DEFINE vFechaBloq DATETIME YEAR TO SECOND;
	DEFINE vTipoBloq INT;
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vFechaBloq, vTipoBloq;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		LET vFechaBloq = '1900-01-01 00:00:00';
		LET vTipoBloq = 0;
		
		IF (pTipoBloq = 'ATOK') THEN --Activacion de Token
			SELECT fecha_bloqueo INTO vFechaBloq FROM bpi_usuario WHERE numcliente = pNumCliente AND st_portal = 'activo';
		ELIF (pTipoBloq = 'CPASS') THEN --Cambio de Password
			SELECT fecha_bloqueo_camb_pass, tipo_bloq_temp_pass INTO vFechaBloq, vTipoBloq FROM bpi_usuario  WHERE numcliente = pNumCliente AND st_portal = 'activo';
		ELIF (pTipoBloq = 'CRESP') THEN --Cambio de Respuestas
			SELECT fecha_bloqueo_camb_pregs, tipo_bloq_temp_resp INTO vFechaBloq, vTipoBloq FROM bpi_usuario  WHERE numcliente = pNumCliente AND st_portal = 'activo';
		ELSE
			LET vCod_ret = '00001';
		END IF;
		
		RETURN vCod_ret, NVL(vFechaBloq, '1900-01-01 00:00:00'), NVL(vTipoBloq, 0);
		
	END;

END PROCEDURE;