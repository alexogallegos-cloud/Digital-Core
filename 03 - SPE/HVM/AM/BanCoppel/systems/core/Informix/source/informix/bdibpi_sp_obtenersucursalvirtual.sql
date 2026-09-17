CREATE PROCEDURE "informix".sp_obtenersucursalvirtual()
RETURNING CHAR (5), CHAR(4);
	-- Creador: Javier Calderón
	-- Objetivo: Obtiene la sucursal virtual para la BPI
	-- Solicitó: Diana Castellanos
	-- Fecha: 17/11/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vSucursal VARCHAR(50);
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vSucursal;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		LET vSucursal = '';
		SELECT sucursal_virtual INTO vSucursal FROM bpi_parametros_contenido;
		RETURN vCod_ret, vSucursal;
	END;
END PROCEDURE;