CREATE PROCEDURE "informix".sp_obteneremailcontactobancoppel(pIdParam VARCHAR(2))
RETURNING CHAR (5), CHAR(25);
	-- Creador: Javier Calderón
	-- Objetivo: Obtiene el ID del usuario
	-- Solicitó: Diana Castellanos
	-- Fecha: 19/11/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vEmail CHAR(25);
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vEmail;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		LET vEmail = '';
		SELECT valor INTO vEmail FROM bpi_param WHERE id_param = pIdParam;
		RETURN vCod_ret, vEmail;
	END;
END PROCEDURE;