CREATE PROCEDURE "informix".sp_inserta_bei_admin_manco_temp_hist_historico(pNumCliente VARCHAR(9), 
                                                                        pIdUsuario INTEGER, 
                                                                        pIdAdminMancoTemp INTEGER, 
                                                                        pIdBitacoraAdmin INTEGER
                                                                        )
RETURNING CHAR(5);

	--****************************************************************************************************
	-- DESCRIPCION: Procedimiento que guarda en la tabla bei_admin_manco_temp_hist_historico para poder 
	-- consultar el historico de las operaciones mancomunadas autorizadas
	-- AUTOR : Solser
	-- FECHA : 06/06/2018

	-- FECHA LIBERACIÃN PRODUCCIÃN: 07-AGOSTO-2018
	-- BASE DE DATOS: BDIBEI
	--***************************************************************************************************


	DEFINE sql_err INTEGER;
	DEFINE cod_ret CHAR(5);
	
	LET cod_ret = '00000';

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
		

    IF((SELECT count(*) FROM "informix".bei_admin_manco_temp_hist WHERE id_admin_manco = pIdAdminMancoTemp) > 0) THEN

        INSERT INTO "informix".bei_admin_manco_temp_hist_historico(
            id_historico, id_bitacora_admin, id_admin_manco, num_cliente_admin, id_usuario_admin, 
            id_usuario_aut, status_aut, fecha_aut, tipo_oper, tipo_mov, id_usuario, num_cliente, 
            id_status, usuario_bei, pass, id_tipo_usuario, 
            nombre_user, tel_celular, cia_cel, e_mail, 
            activo, id_perfil, nom_perfil, 
            ns_token, suc_registro, folio_token, id_status_token) 
        SELECT 	0, NVL(pIdBitacoraAdmin, -1), NVL(id_admin_manco, -1), NVL(num_cliente_admin, ''), NVL(id_usuario_admin, -1), 
            NVL(id_usuario_aut, -1), NVL(status_aut, -1), NVL(fecha_aut, ''), NVL(tipo_oper, -1), NVL(tipo_mov, -1), NVL(id_usuario, -1), NVL(num_cliente, ''), 
            NVL(id_status, -1), NVL(usuario_bei, ''), NVL(pass, ''), NVL(id_tipo_usuario, -1),
            NVL(nombre_user, ''), NVL(tel_celular, ''), NVL(cia_cel, -1), NVL(e_mail, ''), 
            NVL(activo, 't'), NVL(id_perfil, -1), NVL(nom_perfil, ''),
            NVL(ns_token, ''), NVL(suc_registro, ''), NVL(folio_token, ''), NVL(id_status_token, -1)
        FROM "informix".bei_admin_manco_temp_hist
            WHERE id_admin_manco = pIdAdminMancoTemp;
    
    END IF;

    RETURN cod_ret;

END;
END PROCEDURE;