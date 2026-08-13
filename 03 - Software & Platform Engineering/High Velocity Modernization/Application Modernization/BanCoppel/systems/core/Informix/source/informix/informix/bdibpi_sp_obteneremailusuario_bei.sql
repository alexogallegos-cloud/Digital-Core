CREATE PROCEDURE "informix".sp_obteneremailusuario_bei(pNumCliente VARCHAR(9))
RETURNING CHAR (5), CHAR(80);

	-- Creador: Manuel Ramos Figueroa
	-- Objetivo: Obtiene el correo electronico del usuario
	-- Fecha: 26/07/2011
	
	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE vEmail VARCHAR(80);
	
	LET cCod_ret = '00000';
	LET vEmail = '';
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret, vEmail;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
		
		--SELECT e_mail INTO vEmail FROM bdibpi:"informix".bpi_usuariopm WHERE numcliente = pNumCliente AND st_portal = 'activo';
		SELECT correo_elec INTO vEmail FROM bdinteg:"informix".si_correos WHERE numcte = pNumCliente AND status_correo = 'A';
		RETURN cCod_ret, vEmail;
	END;
END PROCEDURE;