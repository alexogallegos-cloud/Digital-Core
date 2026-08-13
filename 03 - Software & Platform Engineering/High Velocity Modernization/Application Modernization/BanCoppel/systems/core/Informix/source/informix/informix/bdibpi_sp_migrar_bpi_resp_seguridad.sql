CREATE PROCEDURE "informix".sp_migrar_bpi_resp_seguridad(pId_pregunta INT,
											  pId_usuario INT,
											  pDesc_resp CHAR(80),
											  pF_ultima_mod DATE,
											  pEncriptado INT)
RETURNING CHAR (5);
	-- Creador: Javier Calderón
	-- Objetivo: Insertar registros a la tabla bpi_resp_seguridad, como proceso de la migrasion de postgres a informix
	-- Solicitó: Diana Castellanos
	-- Fecha: 11/11/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vId_pregunta INT;
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		
		SELECT id_pregunta INTO vId_pregunta FROM bpi_resp_seguridad WHERE id_pregunta = pId_pregunta AND id_usuario = pId_usuario;
		
		IF NVL(vId_pregunta, '') = '' THEN
			INSERT INTO bpi_resp_seguridad (id_pregunta, id_usuario, desc_resp, f_ultima_mod, encriptado) VALUES (pId_pregunta, pId_usuario, pDesc_resp, pF_ultima_mod, pEncriptado);
		ELSE
			LET vCod_ret = '00001'; -- Ya existe el registro
		END IF;
		
		RETURN vCod_ret;
		
	END;
END PROCEDURE;