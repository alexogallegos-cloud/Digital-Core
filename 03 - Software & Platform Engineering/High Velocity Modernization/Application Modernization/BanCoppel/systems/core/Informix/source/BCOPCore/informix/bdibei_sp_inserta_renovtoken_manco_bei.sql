CREATE PROCEDURE "informix".sp_inserta_renovtoken_manco_bei(pNumClienteAdmin CHAR(9), pIdUsuarioAdmin INTEGER, pTipoOper SMALLINT, pTipoMov SMALLINT, pNumCuenta CHAR(20))
RETURNING CHAR(5), INTEGER;

    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER;
  	DEFINE vIdAdminMancoTemp INTEGER;

    LET cod_ret  = "00000";
    LET vIdAdminMancoTemp  = 0;

--****************************************************************************************************
-- DESCRIPCION: Inserta en las tablas de mancomunidad los datos para la renovacion de token mancomunado 
-- para un usuario administrador
-- AUTOR : Solser
-- FECHA : 20/08/2018
-- BD: bdibei
--***************************************************************************************************

--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_inserta_renovtoken_manco_bei.out";
 -- TRACE ON;
 
 
  SET LOCK MODE TO WAIT 3;
	 SET ISOLATION TO DIRTY READ;


BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, vIdAdminMancoTemp;
        END IF;
    END EXCEPTION;

  

	IF NVL(pNumClienteAdmin, '') == '' OR NVL(pIdUsuarioAdmin, -1) == -1 OR NVL(pTipoMov, -1) == -1 OR NVL(pNumCuenta, '') == '' THEN
        LET cod_ret = '00001'; -- Algun parametro requerido es nulo
        RETURN cod_ret, vIdAdminMancoTemp;
	END IF;

    INSERT INTO bdibei:"informix".bei_admin_manco_temp(id_admin_manco, num_cliente_admin, id_usuario_admin, tipo_oper, tipo_mov) 
	VALUES(0, pNumClienteAdmin, pIdUsuarioAdmin, NVL(pTipoOper, 0), pTipoMov);

    LET vIdAdminMancoTemp = DBINFO('sqlca.sqlerrd1');

    INSERT INTO bdibei:"informix".bei_admin_manco_det_temp(id_admin_manco, num_cte, num_cta) 
	VALUES(vIdAdminMancoTemp, pNumClienteAdmin, pNumCuenta);

    -- 5. Actualiza el estatus a 2 (solicitud pendiente de autorizar)
    UPDATE bdibei:"informix".bei_tokenexpira 
    SET id_status_solicitud = '2'
    WHERE num_cte = pNumClienteAdmin
    AND id_token_vencido = 0
    AND id_status_solicitud = 0;

    RETURN cod_ret, vIdAdminMancoTemp;

END
END PROCEDURE;