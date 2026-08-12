CREATE PROCEDURE "informix".sp_insertarusuario(pNumCliente VARCHAR(9),
								  pUsuario VARCHAR(50))
RETURNING CHAR (5);
	-- Creador: Javier Calderón
	-- Objetivo: Registra número de cliente y el usuario
	-- Solicitó: Diana Castellanos
	-- Fecha: 16/11/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vNumCliente VARCHAR(9);
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		
		SELECT numcliente INTO vNumCliente FROM bpi_usuario WHERE numcliente = pNumCliente AND st_portal = 'activo';
		IF NVL(vNumCliente, '') <> '' THEN
			LET vCod_ret = '00001'; -- Numero de cliente ya registrado
			RETURN vCod_ret;
		END IF;
		
		SELECT numcliente INTO vNumCliente FROM bpi_usuario WHERE usuario = pUsuario AND st_portal = 'activo';
		IF NVL(vNumCliente, '') <> '' THEN
			LET vCod_ret = '00002'; -- Usuario ya registrado
			RETURN vCod_ret;
		END IF;
		
		INSERT INTO bpi_usuario (usuario, numcliente, st_portal) VALUES (pUsuario, pNumCliente, 'activo');
		
		RETURN vCod_ret;
		
	END;

END PROCEDURE;