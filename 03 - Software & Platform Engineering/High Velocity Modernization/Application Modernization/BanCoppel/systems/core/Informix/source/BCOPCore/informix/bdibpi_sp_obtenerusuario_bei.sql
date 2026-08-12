CREATE PROCEDURE "informix".sp_obtenerusuario_bei(pNumCliente VARCHAR(9))
RETURNING CHAR (5), CHAR(50);

	-- Creador: Manuel Ramos Figueroa
	-- Objetivo: Obtiene el usuario de un numero de cliente
	-- Fecha: 25/07/2011
	
	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE vUsuario VARCHAR(50);
	
	LET cCod_ret = '00000';
	LET vUsuario = '';
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret, vUsuario;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
		
		SELECT usuario INTO vUsuario FROM bdibpi:"informix".bpi_usuariopm WHERE numcliente = pNumCliente AND st_portal = 'activo';
		RETURN cCod_ret, vUsuario;
	END;

END PROCEDURE;