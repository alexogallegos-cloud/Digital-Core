CREATE PROCEDURE "informix".sp_eliminaregistro(pNumCliente VARCHAR(9))
RETURNING CHAR (5);
	-- Creador: Javier Calderón
	-- Objetivo: Elimina el registro del usuario
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
		DELETE FROM bpi_usuario WHERE numcliente = pNumCliente AND st_portal = 'activo';
		RETURN vCod_ret;
	END;
END PROCEDURE;