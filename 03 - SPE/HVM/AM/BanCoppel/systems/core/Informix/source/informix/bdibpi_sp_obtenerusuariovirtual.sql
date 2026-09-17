CREATE PROCEDURE "informix".sp_obtenerusuariovirtual()
RETURNING CHAR (5), CHAR(50);
	-- Creador: Javier Calderón
	-- Objetivo: Obtiene el usuario virtual para la BPI
	-- Solicitó: Diana Castellanos
	-- Fecha: 17/11/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vUsuario VARCHAR(50);
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vUsuario;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		LET vUsuario = '';
		SELECT usuario_virtual INTO vUsuario FROM bpi_parametros_contenido;
		RETURN vCod_ret, vUsuario;
	END;
END PROCEDURE;