CREATE PROCEDURE "informix".sp_migrar_bpi_parametros_contenido(pNum_empleado INT,
													pF_registro DATE,
													pSucursal_virtual CHAR(4),
													pUsuario_virtual CHAR(50),
													pEmail_aclaraciones CHAR(80),
													pResp_aclaraciones VARCHAR(10),
													pEmail_info_prods CHAR(80),
													pResp_info_prods VARCHAR(10),
													pTel_cat CHAR(15),
													pIntentos_acceso INT,
													pCad_usuario CHAR(3),
													pCad_contrasena CHAR(3),
													pF_ultima_actual DATETIME YEAR TO SECOND,
													pFolio INT,
													pFlag_batch_cheques BOOLEAN,
													pFlag_batch_credito BOOLEAN,
													pFlag_batch_spei BOOLEAN)
RETURNING CHAR (5);
	-- Creador: Javier Calderón
	-- Objetivo: Insertar registros a la tabla bpi_parametros_contenido, como proceso de la migrasion de postgres a informix
	-- Solicitó: Diana Castellanos
	-- Fecha: 11/11/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vNum_empleado INT;
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		
		SELECT num_empleado INTO vNum_empleado FROM bpi_parametros_contenido WHERE num_empleado = pNum_empleado;
		
		IF NVL(vNum_empleado, '') = '' THEN
			INSERT INTO bpi_parametros_contenido (num_empleado, f_registro, sucursal_virtual, usuario_virtual, email_aclaraciones, resp_aclaraciones,
												   email_info_prods, resp_info_prods, tel_cat, intentos_acceso, cad_usuario, cad_contrasena, f_ultima_actual,
												   folio, flag_batch_cheques, flag_batch_credito, flag_batch_spei) 
												   VALUES 
												   (pNum_empleado, pF_registro, pSucursal_virtual, pUsuario_virtual, pEmail_aclaraciones, pResp_aclaraciones,
												   pEmail_info_prods, pResp_info_prods, pTel_cat, pIntentos_acceso, pCad_usuario, pCad_contrasena, pF_ultima_actual,
												   pFolio, pFlag_batch_cheques, pFlag_batch_credito, pFlag_batch_spei);
		ELSE
			LET vCod_ret = '00001'; -- Ya existe el registro
		END IF;
		
		RETURN vCod_ret;
		
	END;

END PROCEDURE;