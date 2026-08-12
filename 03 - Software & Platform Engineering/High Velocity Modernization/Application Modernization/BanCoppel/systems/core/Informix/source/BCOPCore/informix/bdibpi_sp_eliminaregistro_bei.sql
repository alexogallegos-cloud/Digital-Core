CREATE PROCEDURE "informix".sp_eliminaregistro_bei(pNumCliente VARCHAR(9))
RETURNING CHAR (5);

	-- Creador: Manuel Ramos Figueroa
	-- Objetivo: Elimina el registro del usuario
	-- Fecha: 23/07/2011
	
	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	
	LET cCod_ret = '00000';
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		DELETE FROM bdibpi:"informix".bpi_usuariopm WHERE numcliente = pNumCliente AND st_portal = 'activo';
		RETURN cCod_ret;
	END;
END PROCEDURE;