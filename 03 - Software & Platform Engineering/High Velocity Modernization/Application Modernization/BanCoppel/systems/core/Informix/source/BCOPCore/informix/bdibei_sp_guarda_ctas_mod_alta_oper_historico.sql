CREATE PROCEDURE "informix".sp_guarda_ctas_mod_alta_oper_historico(pNumCliente CHAR(20), pIdUsuario INTEGER, pIdPerfil INTEGER, pIdBitacoraAdmin INTEGER)

RETURNING CHAR(5);

    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER;
    DEFINE vnum_cta CHAR(20);
    DEFINE vis_cta_mod BOOLEAN;
    DEFINE vIdPerfil INTEGER;

    LET cod_ret = '00000';
    LET vnum_cta = '';
    LET vis_cta_mod = 'f';
    LET vIdPerfil = 0;

	-- *****************************************************************************************************************
	-- DESCRIPCION:  Se obtienen cuentas de usuario y se llama a sp que valida qué cuentas se modificaron al realizar 
	-- un alta de operador (Operacion: Perfilar Operador) y se guardan las cuentas modificadas 
	-- en la tabla bei_perfil_oper_ctas_mod_historico
	-- AUTOR: Solser
	-- FECHA: 16/07/2018

	-- FECHA LIBERACIÓN PRODUCCIÓN: 07-AGOSTO-2018
    -- FECHA MOFICIACION: 15-FEB-2019, SE AGREGO VALIDACION DE PIDPERFIL Y SU CONSULTA DESDE LA TABLA BEI_USUARIO_PERFIL
	-- BASE DE DATOS: BDIBEI
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
-- ***************************************************************************************************************

    IF NVL(pNumCliente, '') == '' OR NVL(pIdUsuario, -1) == -1 OR NVL(pIdBitacoraAdmin, -1) == -1 THEN
        LET cod_ret = '00001'; -- Algun parametro requerido es nulo
        RETURN cod_ret;
    END IF;

    IF NVL(pIdPerfil, -1) == -1 THEN
        SELECT id_perfil
            INTO vIdPerfil
        FROM bdibei:"informix".bei_usuario_perfil 
            WHERE id_usuario = pIdUsuario;
    END IF;

    FOREACH -- Para cada cuenta del cliente validar...
        SELECT NVL(mc.cuenta, '')
            INTO vnum_cta
        FROM bdicheq:"informix".sc_maechq as mc, bdicheq:"informix".sc_producto as pr
            WHERE mc.num_cte = pNumCliente
            AND mc.status_cta NOT IN (2,5)
            AND pr.empresa = mc.empresa
            AND pr.producto = mc.producto
        ORDER BY mc.cuenta

        IF(SELECT autoriza FROM bdibei:"informix".bei_mancomunidad 
            WHERE num_cte = pNumCliente AND id_usuario = pIdUsuario AND num_cta = vnum_cta) THEN -- 1) Si se marco el check de autoriza considerar como cuenta modificada
            LET vis_cta_mod = 't';
        END IF;

        IF((SELECT COUNT(id_menu_oper) 
            FROM bdibei:"informix".bei_operaciones 
            WHERE id_perfil = vIdPerfil
            AND num_cta = vnum_cta
            AND id_menu_oper IN (
                SELECT mper.id_menu_oper
                FROM bdibei:"informix".bei_menu_oper  mper
                JOIN bdibei:"informix".bei_cat_operaciones cper ON cper.id_cat_oper=mper.id_cat_oper
                WHERE  mper.tipo_menu  = 2
                AND mper.activo = 't'
                AND cper.id_cat_oper <> 600
                AND id_cat_padre in(100, 200, 300, 410, 420, 3005, 430) 
            )) > 0) THEN -- 2) Si tiene operaciones considerar como cuenta modificada
            LET vis_cta_mod = 't';
        END IF;

        IF(vis_cta_mod) THEN -- Si la cuenta fue modificada guardar en bei_perfil_oper_ctas_mod_historico
            INSERT INTO bdibei:"informix".bei_perfil_oper_ctas_mod_historico(
                id_historico, id_bitacora_admin, id_usuario, id_perfil, num_cta, fecha_mov_historico) 
                VALUES(0, pIdBitacoraAdmin, pIdUsuario, pIdPerfil, vnum_cta, CURRENT YEAR TO SECOND);
        END IF;

        LET vis_cta_mod = 'f';

    END FOREACH;

    RETURN cod_ret;

END
END PROCEDURE;