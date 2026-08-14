CREATE PROCEDURE "informix".sp_obtenernombrecompania(pCatCia VARCHAR(3), pCveCia VARCHAR(3))
RETURNING CHAR (5), CHAR(100);
	-- Creador: Javier Calderón
	-- Objetivo: Obtiene nombre compania
	-- Solicitó: Diana Castellanos
	-- Fecha: 18/11/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vDescripcion CHAR(100);
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vDescripcion;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		LET vDescripcion = '';
		SELECT desc_servicio INTO vDescripcion FROM bpi_cat_servicios WHERE id_categoria = pCatCia AND id_convenio = pCveCia;
		RETURN vCod_ret, vDescripcion;
	END;
END PROCEDURE;