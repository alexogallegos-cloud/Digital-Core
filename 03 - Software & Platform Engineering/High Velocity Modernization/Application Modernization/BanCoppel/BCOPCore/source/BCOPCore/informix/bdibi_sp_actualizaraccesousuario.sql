CREATE PROCEDURE "informix".sp_actualizaraccesousuario(pNumCliente VARCHAR(9))
RETURNING CHAR (5);
	-- Creador: Javier Calderón
	-- Objetivo: Registra la fecha del ultimo acceso
	-- Solicitó: Diana Castellanos
	-- Fecha: 17/11/2010
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


        SET ISOLATION TO DIRTY READ;
		
		LET vCod_ret = '00000';
		
		SELECT numcliente INTO vNumCliente FROM bpi_usuario WHERE numcliente = pNumCliente AND st_portal = 'activo';
		
		IF NVL(vNumCliente, '') <> '' THEN
			UPDATE bpi_usuario SET f_ultimo_acceso = TODAY WHERE numcliente = pNumCliente AND st_portal = 'activo';
		ELSE
			LET vCod_ret = '00001';
		END IF;
		
		RETURN vCod_ret;
		
	END;

END PROCEDURE;