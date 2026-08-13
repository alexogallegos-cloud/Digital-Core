CREATE PROCEDURE "informix".sp_obtenerusuario(pNumCliente VARCHAR(9))
RETURNING CHAR (5), CHAR(50);
	-- Creador: Javier Calderón
	-- Objetivo: Obtiene el usuario de un numero de cliente
	-- Solicitó: Diana Castellanos
	-- Fecha: 17/11/2010
	
	--Modificó: Edgar M. Alarcon
	--Actividad: valida si recibe id de usuario o numero de cliente
	--Solicito: Jose de Jesus
	--Fecha: 05-11-15
	
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vUsuario VARCHAR(50);
	DEFINE vNumCte VARCHAR(9);
	
	--SET DEBUG FILE TO "/home/informix/bibiana/sp_obtenerusuario.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vUsuario;
		  END IF ;
		END EXCEPTION ;
		
		SELECT numcliente INTO vNumCte FROM bdibpi:"informix".bpi_usuario WHERE id_usuario = pNumCliente; -- ID_usuario
		
		IF vNumCte <> '' OR vNumCte IS NOT NULL THEN
			LET vNumCte = "";
			LET vnumCte = pNumCliente;
		ELSE
			LET vNumCte="";
			SELECT id_usuario INTO vNumCte FROM bdibpi:"informix".bpi_usuario WHERE numcliente = pNumCliente AND st_portal = 'activo';
		END IF;
				
		LET vCod_ret = '00000';
		LET vUsuario = '';
		SELECT usuario INTO vUsuario FROM bdibpi:"informix".bpi_usuario WHERE id_usuario = vNumCte AND st_portal = 'activo';
		RETURN vCod_ret, vUsuario;
	END;

END PROCEDURE;