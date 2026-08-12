CREATE PROCEDURE "informix".sp_cambiarstatus_bei(pNumCliente VARCHAR(9),
								  pEstado VARCHAR(9))
RETURNING CHAR (5);

	-- Creador: Manuel Ramos Figueroa
	-- Objetivo: Actualiza estado del usuario a inactivo
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
		UPDATE bdibpi:"informix".bpi_usuariopm SET st_portal = pEstado WHERE numcliente = pNumCliente AND st_portal = 'activo';
		RETURN cCod_ret;
		
	END;
END PROCEDURE;