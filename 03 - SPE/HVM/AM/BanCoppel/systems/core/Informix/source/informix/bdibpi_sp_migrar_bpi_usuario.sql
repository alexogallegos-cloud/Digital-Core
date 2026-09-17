CREATE PROCEDURE "informix".sp_migrar_bpi_usuario(pId_usuario INTEGER,
									  pUsuario CHAR(50),
									  pNumcliente CHAR(9),
									  pTel_celular CHAR(15),
									  pCia_cel INT,
									  pE_mail CHAR(80),
									  pF_ultimo_acceso DATE,
									  pId_ultima_oper INT,
									  pId_perfil INT,
									  pFecha_bloqueo DATETIME YEAR TO SECOND,
									  pSt_portal CHAR(9),
									  pFecha_bloqueo_camb_pass DATETIME YEAR TO SECOND,
									  pFecha_bloqueo_camb_pregs DATETIME YEAR TO SECOND,
									  pTipo_bloq_temp_pass INT,
									  pTipo_bloq_temp_resp INT)
RETURNING CHAR (5);
	-- Creador: Javier Calderón
	-- Objetivo: Insertar registros a la tabla bpi_usuario, como proceso de la migrasion de postgres a informix
	-- Solicitó: Diana Castellanos
	-- Fecha: 11/11/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vId_usuario INT;
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		
		SELECT id_usuario INTO vId_usuario FROM bpi_usuario WHERE id_usuario = pId_usuario;
		
		IF NVL(vId_usuario, '') = '' THEN
			INSERT INTO bpi_usuario (id_usuario, usuario, numcliente, tel_celular, cia_cel, e_mail, f_ultimo_acceso,  id_ultima_oper, id_perfil,
									 fecha_bloqueo, st_portal, fecha_bloqueo_camb_pass, fecha_bloqueo_camb_pregs, tipo_bloq_temp_pass, tipo_bloq_temp_resp) 
									 VALUES 
									(pId_usuario, pUsuario, pNumcliente, pTel_celular, pCia_cel, pE_mail, pF_ultimo_acceso, pId_ultima_oper, pId_perfil,
									 pFecha_bloqueo, pSt_portal, pFecha_bloqueo_camb_pass, pFecha_bloqueo_camb_pregs, pTipo_bloq_temp_pass, pTipo_bloq_temp_resp);
		ELSE
			LET vCod_ret = '00001'; -- Ya existe el registro
		END IF;
		
		RETURN vCod_ret;
		
	END;

END PROCEDURE;