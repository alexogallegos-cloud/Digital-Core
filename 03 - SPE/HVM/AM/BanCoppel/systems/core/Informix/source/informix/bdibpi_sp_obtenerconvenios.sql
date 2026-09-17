CREATE PROCEDURE "informix".sp_obtenerconvenios()
RETURNING CHAR (5), CHAR(3), CHAR(3);
	-- Creador: Javier Calderón
	-- Objetivo: Obtiene los convenios activos
	-- Solicitó: Diana Castellanos
	-- Fecha: 17/11/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vIdCategoria CHAR(3);
	DEFINE vIdConvenio CHAR(3);
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vIdCategoria, vIdConvenio;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		LET vIdCategoria = '';
		LET vIdConvenio = '';
		
		FOREACH
			SELECT DISTINCT(id_categoria) 
			INTO vIdCategoria
			FROM bpi_cat_servicios 
			WHERE status = '1'
			ORDER BY id_categoria
			
			FOREACH
				SELECT id_convenio 
				INTO vIdConvenio 
				FROM bpi_cat_servicios 
				WHERE id_categoria = vIdCategoria 
				AND status = '1'
				ORDER BY id_convenio
				
				RETURN vCod_ret, vIdCategoria, vIdConvenio WITH RESUME;
			END FOREACH;
		END FOREACH;
	END;

END PROCEDURE;