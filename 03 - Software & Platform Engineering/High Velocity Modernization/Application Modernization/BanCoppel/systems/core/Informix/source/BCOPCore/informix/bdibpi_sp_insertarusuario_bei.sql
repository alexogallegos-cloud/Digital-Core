CREATE PROCEDURE "informix".sp_insertarusuario_bei(pNumCliente VARCHAR(9),
								  pUsuario VARCHAR(50))
RETURNING CHAR (5);

	-- Creador: Manuel Ramos Figueroa
	-- Objetivo: Registra número de cliente y el usuario
	-- Fecha: 22/07/2011
	
	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE vNumCliente VARCHAR(9);
	
	LET cCod_ret = '00000';
	LET vNumCliente = '';
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret;
		  END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
		
		SELECT numcliente INTO vNumCliente FROM bdibpi:"informix".bpi_usuariopm WHERE numcliente = pNumCliente AND st_portal = 'activo';
		IF NVL(vNumCliente, '') <> '' THEN
			LET cCod_ret = '00001'; -- Numero de cliente ya registrado
			RETURN cCod_ret;
		END IF;
		
		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
		
		SELECT numcliente INTO vNumCliente FROM bdibpi:"informix".bpi_usuariopm WHERE usuario = pUsuario AND st_portal = 'activo';
		IF NVL(vNumCliente, '') <> '' THEN
			LET cCod_ret = '00002'; -- Usuario ya registrado
			RETURN cCod_ret;
		END IF;
		
		INSERT INTO bdibpi:"informix".bpi_usuariopm (usuario, numcliente, st_portal) VALUES (pUsuario, pNumCliente, 'activo');
		
		RETURN cCod_ret;
		
	END;

END PROCEDURE;