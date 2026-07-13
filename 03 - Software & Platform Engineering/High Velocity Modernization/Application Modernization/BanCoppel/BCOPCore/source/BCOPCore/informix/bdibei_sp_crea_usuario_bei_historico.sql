CREATE PROCEDURE "informix".sp_crea_usuario_bei_historico(pNumCliente CHAR(9), pIdStatus SMALLINT,
        pUsuario CHAR(50), pPass CHAR(50), pTipoUsuario SMALLINT, pNombrePerfil CHAR(50),
        pNombre CHAR(150), pTelCel CHAR(15), pCiaCel SMALLINT, pMail CHAR(50), pIdUsuarioLogeado INTEGER, pidBitacoraAdmin INTEGER, pIdPerfil INTEGER, pIdUsuario INTEGER)

RETURNING CHAR(5);


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;

    LET cod_ret = "00000";

	--****************************************************************************************************
	-- DESCRIPCION:  Crea usuario Bei
	-- NOTA: Se clona sp sp_crea_usuario_bei para el requerimiento de bitacora de administradores
	-- AUTOR: Solser
	-- FECHA: 04/06/2018

	-- FECHA LIBERACIÃN PRODUCCIÃN: 07-AGOSTO-2018
	-- BASE DE DATOS: BDIBEI
	--***************************************************************************************************


    BEGIN

        ON EXCEPTION SET sql_err
          IF sql_err <> 0 THEN
                let cod_ret = sql_err;
              RETURN cod_ret;
          END IF;
        END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ;

        
        INSERT INTO bdibei:"informix".bei_perfil_historico
        (id_historico,id_bitacora_admin,id_perfil,nombre,activo,createdby,createdon,updatedby,updatedon,f_mov_historico) VALUES
        (0,pidBitacoraAdmin,pIdPerfil,pNombre,'t',pIdUsuarioLogeado,CURRENT YEAR TO DAY,pIdUsuarioLogeado,CURRENT YEAR TO DAY,CURRENT YEAR TO SECOND);

        INSERT INTO bdibei:"informix".bei_usuario_historico
        (id_historico,id_bitacora_admin,id_usuario,num_cliente,id_status,usuario_bei,pass,f_pass,f_status,f_registro,id_tipo_usuario,f_mov_historico) VALUES
        (0,pidBitacoraAdmin,pIdUsuario,pNumCliente,pIdStatus,pUsuario,pPass,CURRENT YEAR TO DAY,CURRENT YEAR TO DAY,CURRENT YEAR TO DAY,pTipoUsuario,CURRENT YEAR TO SECOND);

        INSERT INTO bdibei:"informix".bei_datos_usuario_historico
        (id_historico,id_bitacora_admin,id_usuario,nombre,tel_celular,cia_cel,e_mail,activo,f_mov_historico) VALUES
        (0,pidBitacoraAdmin,pIdUsuario,pNombre,pTelCel,pCiaCel,pMail,'t',CURRENT YEAR TO SECOND);

        INSERT INTO bdibei:"informix".bei_usuario_perfil_historico
        (id_historico,id_bitacora_admin,id_perfil,id_usuario,f_mov_historico) VALUES
        (0,pidBitacoraAdmin,pIdPerfil,pIdUsuario,CURRENT YEAR TO SECOND);

         RETURN cod_ret;

    END
END PROCEDURE;