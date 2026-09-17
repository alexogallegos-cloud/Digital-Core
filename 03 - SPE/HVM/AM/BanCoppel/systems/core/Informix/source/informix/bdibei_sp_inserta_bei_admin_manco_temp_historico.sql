CREATE PROCEDURE "informix".sp_inserta_bei_admin_manco_temp_historico(pNumCliente VARCHAR(9), pIdUsuario INTEGER, pIdAdminManco INTEGER, pIdBitacoraAdmin INTEGER)
RETURNING CHAR(5);

--****************************************************************************************************
-- DESCRIPCION: Procedimiento que guarda en la tabla bei_admin_manco_temp_historico para poder consultar el historico de las operaciones mancomunadas
-- AUTOR : Solser
-- FECHA : 30/05/2018
-- BD: bdibei
--***************************************************************************************************


	DEFINE sql_err INTEGER;
	DEFINE cod_ret CHAR(5);
	DEFINE vCount SMALLINT;
	
	LET cod_ret = '00000';
	LET vCount = 0;

	BEGIN

--****************************************************************************************************
-- Excepciones:
--***************************************************************************************************
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cod_ret = sql_err;
				RETURN cod_ret;
		  END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ;
		
	

		SELECT COUNT(id_admin_manco)
            INTO vCount
        FROM "informix".bei_admin_manco_temp
            WHERE id_admin_manco = pIdAdminManco
            AND num_cliente_admin = pNumCliente
            AND id_usuario_admin = pIdUsuario;

    	IF(vCount <= 0) THEN
    	  LET cod_ret = '00007'; -- No Hay Datos que transferir
       	 	RETURN cod_ret ;
   		END IF;
			
        
        INSERT INTO "informix".bei_admin_manco_temp_historico
            (id_historico, id_bitacora_admin, id_admin_manco,
            num_cliente_admin, id_usuario_admin, tipo_oper, tipo_mov,
            id_usuario, num_cliente, id_status, usuario_bei, pass, id_tipo_usuario,
            nombre_user, tel_celular, cia_cel, e_mail, activo, id_perfil, nom_perfil,
            ns_token, suc_registro, folio_token, id_status_token)
        SELECT 	0, pIdBitacoraAdmin, pIdAdminManco,
            num_cliente_admin, id_usuario_admin, tipo_oper, tipo_mov,
            NVL(id_usuario,-1), NVL(num_cliente,''), NVL(id_status,-1), NVL(usuario_bei,''), NVL(pass,''), NVL(id_tipo_usuario,-1),
            NVL(nombre_user,''), NVL(tel_celular,''), NVL(cia_cel,-1), NVL(e_mail,''), NVL(activo,'f'),	NVL(id_perfil,-1), NVL(nom_perfil,''),
            NVL(ns_token,''), NVL(suc_registro,''), NVL(folio_token,''), NVL(id_status_token,-1)
        FROM "informix".bei_admin_manco_temp
            WHERE id_admin_manco = pIdAdminManco
            AND num_cliente_admin = pNumCliente
            AND id_usuario_admin = pIdUsuario;
    
		RETURN cod_ret;

	END;
END PROCEDURE;