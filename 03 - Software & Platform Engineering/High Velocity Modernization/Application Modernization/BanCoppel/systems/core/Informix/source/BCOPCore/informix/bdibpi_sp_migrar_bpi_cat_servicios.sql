CREATE PROCEDURE "informix".sp_migrar_bpi_cat_servicios(pId_convenio CHAR(3),
											   pId_categoria CHAR(3),
											   pDesc_servicio CHAR(100),
											   pStatus INT,
											   pF_registro DATE)
RETURNING CHAR (5);
	-- Creador: Javier Calderón
	-- Objetivo: Insertar registros a la tabla bpi_cat_servicios, como proceso de la migrasion de postgres a informix
	-- Solicitó: Diana Castellanos
	-- Fecha: 11/11/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vId_convenio INT;
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		
		SELECT id_convenio INTO vId_convenio FROM bpi_cat_servicios WHERE id_convenio = pId_convenio AND id_categoria = pId_categoria;
		
		IF NVL(vId_convenio, '') = '' THEN
			INSERT INTO bpi_cat_servicios (id_convenio, id_categoria, desc_servicio, status, f_registro) VALUES (pId_convenio, pId_categoria, pDesc_servicio, pStatus, pF_registro);
		ELSE
			LET vCod_ret = '00001'; -- Ya existe el registro
		END IF;
		
		RETURN vCod_ret;
		
	END;

END PROCEDURE;