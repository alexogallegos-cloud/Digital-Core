CREATE PROCEDURE "informix".sps_crea_usuario_bei_historico(pNumCliente CHAR(9),
                                                            pIdStatus SMALLINT,
                                                            pUsuario CHAR(50),
                                                            pTipoUsuario SMALLINT ,
                                                            pNombrePerfil CHAR(50),
                                                            pNombre CHAR(150),
                                                            pTelCel CHAR(15),
                                                            pCiaCel SMALLINT,
                                                            pMail CHAR(50),
                                                            pIdUsuarioLogeado INTEGER,
                                                            pidBitacoraAdmin INTEGER, 
                                                            pIdPerfil INTEGER, 
                                                            pIdUsuario INTEGER)
RETURNING CHAR(5);


    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER;

    LET cod_ret = "00000";

    --****************************************************************************************************
    -- DESCRIPCION:  Crea usuario Bei
    -- NOTA: Se clona sp sps_crea_usuario_bei para el requerimiento de bitacora de administradores
    -- AUTOR: Solser
    -- FECHA: 05/06/2018
    -- BD: bdibei
    --***************************************************************************************************


  BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
          RETURN cod_ret;
        END IF;
    END EXCEPTION;

    SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;


    INSERT INTO bdibei:"informix".bei_perfil_historico
        (id_historico, id_bitacora_admin, id_perfil, nombre, activo, createdby, createdon, 
        updatedby, updatedon, f_mov_historico)
    SELECT 0, NVL(pidBitacoraAdmin, -1), NVL(id_perfil, -1), NVL(nombre, ''), NVL(activo, 't'), NVL(createdby, -1), NVL(createdon, ''), 
        NVL(updatedby, -1), NVL(updatedon, ''), CURRENT YEAR TO SECOND 
    FROM "informix".bei_perfil
        WHERE id_perfil = pIdPerfil;


    INSERT INTO bdibei:"informix".bei_usuario_historico(id_historico, id_bitacora_admin, id_usuario,
            num_cliente, id_status, usuario_bei, 
            pass, f_pass, pass1, f_pass1, 
            pass2, f_pass2, pass3, f_pass3, 
            f_status, f_ultimo_acceso, f_actualizacion, f_registro, fec_primer_acceso, 
            id_tipo_usuario, f_bloqueo_temp, f_mov_historico) 
	SELECT 0, NVL(pIdBitacoraAdmin, -1), NVL(id_usuario, -1), 
            NVL(num_cliente, ''), NVL(id_status, -1), NVL(usuario_bei, ''), 
            NVL(pass, ''), NVL(f_pass, ''), NVL(pass1, ''), NVL(f_pass1, ''), 
            NVL(pass2, ''), NVL(f_pass2, ''), NVL(pass3, ''), NVL(f_pass3, ''), 
            NVL(f_status, ''), NVL(f_ultimo_acceso, ''), NVL(f_actualizacion, ''), NVL(f_registro, ''), NVL(fec_primer_acceso, ''), 
            NVL(id_tipo_usuario, -1), NVL(f_bloqueo_temp, ''), CURRENT YEAR TO SECOND 
	FROM "informix".bei_usuario
    WHERE id_usuario = pIdUsuario;


    INSERT INTO bdibei:"informix".bei_datos_usuario_historico(id_historico, id_bitacora_admin, id_usuario, 
        nombre, tel_celular, cia_cel, e_mail, activo, id_ultima_oper, 
        fecha_bloqueo, fecha_bloqueo_camb_pass, fecha_bloqueo_camb_pregs, 
        tipo_bloqueo_temp_pass, tipo_bloqueo_temp_resp, f_mov_historico) 
    SELECT 0, NVL(pIdBitacoraAdmin, -1), NVL(id_usuario, -1), 
        NVL(nombre, ''), NVL(tel_celular, ''), NVL(cia_cel, -1), NVL(e_mail, ''), NVL(activo, 't'), NVL(id_ultima_oper, -1), 
        NVL(fecha_bloqueo, ''), NVL(fecha_bloqueo_camb_pass, ''), NVL(fecha_bloqueo_camb_pregs, ''), 
        NVL(tipo_bloqueo_temp_pass, -1), NVL(tipo_bloqueo_temp_resp, -1), CURRENT YEAR TO SECOND 
	FROM "informix".bei_datos_usuario
    WHERE id_usuario = pIdUsuario;


    INSERT INTO bdibei:"informix".bei_usuario_perfil_historico
        (id_historico, id_bitacora_admin, id_usuario, id_perfil, f_mov_historico)
    SELECT 0, NVL(pIdBitacoraAdmin, -1), NVL(id_usuario, -1), NVL(id_perfil, -1), CURRENT YEAR TO SECOND
	FROM "informix".bei_usuario_perfil
        WHERE id_usuario = pIdUsuario
        AND id_perfil = pIdPerfil;


    RETURN cod_ret;

END
END PROCEDURE;