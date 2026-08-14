CREATE PROCEDURE "informix".sp_obteneridusuario(pNumCliente VARCHAR(9))
RETURNING CHAR (5), CHAR(11);
	-- Creador: Javier Calderón
	-- Objetivo: Obtiene el ID del usuario
	-- Solicitó: Diana Castellanos
	-- Fecha: 17/11/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vIdUsuario VARCHAR(11);
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vIdUsuario;
		  END IF ;
		END EXCEPTION ;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
       
		LET vCod_ret = '00000';
		LET vIdUsuario = '';
        --        SET ISOLATION TO COMMITTED READ LAST COMMITTED;
		SELECT id_usuario INTO vIdUsuario FROM bpi_usuario WHERE numcliente = pNumCliente AND st_portal = 'activo';
		RETURN vCod_ret, vIdUsuario;
	END;
END PROCEDURE;