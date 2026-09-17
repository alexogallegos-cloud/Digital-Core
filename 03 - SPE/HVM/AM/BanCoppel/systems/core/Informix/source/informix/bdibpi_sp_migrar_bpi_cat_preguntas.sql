CREATE PROCEDURE "informix".sp_migrar_bpi_cat_preguntas(pId_pregunta INT,
											   pDesc_pregunta CHAR(50),
											   pActivo BOOLEAN,
											   pF_ultima_mod DATE,
											   pUsuario_ult_mod CHAR(8))
RETURNING CHAR (5);
	-- Creador: Javier Calderón
	-- Objetivo: Insertar registros a la tabla bpi_cat_preguntas, como proceso de la migrasion de postgres a informix
	-- Solicitó: Diana Castellanos
	-- Fecha: 11/11/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR(5);
	DEFINE vId_pregunta INT;
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		
		SELECT id_pregunta INTO vId_pregunta FROM bpi_cat_preguntas WHERE id_pregunta = pId_pregunta;
		
		IF NVL(vId_pregunta, '') = '' THEN
			INSERT INTO bpi_cat_preguntas (id_pregunta, desc_pregunta, activo, f_ultima_mod, usuario_ult_mod) VALUES (pId_pregunta, pDesc_pregunta, pActivo, pF_ultima_mod, pUsuario_ult_mod);
		ELSE
			LET vCod_ret = '00001'; -- Ya existe el registro
		END IF;
		
		RETURN vCod_ret;
		
	END;

END PROCEDURE;