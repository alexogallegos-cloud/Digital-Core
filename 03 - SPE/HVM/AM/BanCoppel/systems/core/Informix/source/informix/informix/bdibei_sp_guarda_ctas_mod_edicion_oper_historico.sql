CREATE PROCEDURE "informix".sp_guarda_ctas_mod_edicion_oper_historico(pNumCliente CHAR(20), pIdUsuario INTEGER, pIdPerfil INTEGER, pIdBitacoraAdmin INTEGER)

RETURNING CHAR(5);

    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER;

    DEFINE vnum_cta CHAR(20);
    DEFINE vis_cta_mod BOOLEAN;
    DEFINE vautoriza_ant BOOLEAN; -- Para dato autoriza anterior
    DEFINE vautoriza_act BOOLEAN; -- Para dato autoriza actual
    DEFINE vid_menu_oper INTEGER;
    DEFINE vcont_oper_ant INTEGER;
    DEFINE vcont_oper_act INTEGER;
    DEFINE vmanco_ant BOOLEAN;
    DEFINE vmanco_act BOOLEAN;
    DEFINE vmonto_min_ant DECIMAL(16,2);
    DEFINE vmonto_min_act DECIMAL(16,2);
    DEFINE vmonto_max_ant DECIMAL(16,2);
    DEFINE vmonto_max_act DECIMAL(16,2);

    LET cod_ret = '00000';

    LET vnum_cta = '';
    LET vis_cta_mod = 'f';
    LET vautoriza_ant = 'f';
    LET vautoriza_act = 'f';
    LET vid_menu_oper = 0;
    LET vcont_oper_ant = 0;
    LET vcont_oper_act = 0;
    LET vmanco_ant = 'f';
    LET vmanco_act = 'f';
    LET vmonto_min_ant = 0.0;
    LET vmonto_min_act = 0.0;
    LET vmonto_max_ant = 0.0;
    LET vmonto_max_act = 0.0;

	-- *****************************************************************************************************************
	-- DESCRIPCION: Se obtienen cuentas de usuario y se valida qué cuentas se modificaron al realizar 
	-- una modificacion en el perfil del operador, si hubo algún cambio se guarda la cuenta afectada 
	-- en la tabla bei_perfil_oper_ctas_mod_historico
	-- AUTOR: Solser

	-- FECHA LIBERACIÓN PRODUCCIÓN: 07-AGOSTO-2018
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

    IF (NVL(pNumCliente, '') == '' OR NVL(pIdUsuario, -1) == -1 OR NVL(pIdBitacoraAdmin, -1) == -1) THEN
        LET cod_ret = '00001'; -- Algun parametro requerido es nulo
        RETURN cod_ret;
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


        SELECT autoriza INTO vautoriza_act
        FROM bdibei:"informix".bei_mancomunidad
        WHERE num_cte = pNumCliente AND id_usuario = pIdUsuario AND num_cta = vnum_cta; 
       
        SELECT autoriza INTO vautoriza_ant
        FROM bdibei:"informix".bei_mancomunidad_temporal
        WHERE num_cte = pNumCliente AND id_usuario = pIdUsuario AND num_cta = vnum_cta; 

        IF (vautoriza_ant != vautoriza_act) THEN -- 1) Si el campo autoriza es diferente considerar como cuenta modificada
            LET vis_cta_mod = 't';
        END IF;


        FOREACH
            SELECT mper.id_menu_oper
                INTO vid_menu_oper
            FROM bdibei:"informix".bei_menu_oper mper
            JOIN bdibei:"informix".bei_cat_operaciones cper ON cper.id_cat_oper = mper.id_cat_oper
                WHERE  mper.tipo_menu  = 2
                AND mper.activo = 't'
                AND cper.id_cat_oper <> 600
                AND id_cat_padre in(100, 200, 300, 410, 420, 3005, 430)
                ORDER BY id_menu_oper
                
            SELECT NVL(COUNT(id_oper), 0)
                INTO vcont_oper_act
            FROM bdibei:"informix".bei_operaciones 
                WHERE id_perfil = pIdPerfil
                AND num_cta = vnum_cta
                AND id_menu_oper = vid_menu_oper;

            SELECT NVL(COUNT(id_oper), 0)
                INTO vcont_oper_ant
            FROM bdibei:"informix".bei_operaciones_temporal 
                WHERE id_perfil = pIdPerfil
                AND num_cta = vnum_cta
                AND id_menu_oper = vid_menu_oper;

                IF (vcont_oper_act != vcont_oper_ant) THEN 
                     LET vis_cta_mod = 't';
                END IF;

                IF (vcont_oper_act > 0 AND vcont_oper_ant > 0) THEN 
                    IF (vcont_oper_act != vcont_oper_ant) THEN -- Si el numero de registros de esa operacion es diferente hubo un cambio
                        LET vis_cta_mod = 't';
                    END IF;

                    IF (vcont_oper_act == 1 AND vcont_oper_ant == 1) THEN -- Existe la misma operacion una sola vez
                        SELECT mancomunado, monto_min, monto_max
                            INTO vmanco_act, vmonto_min_act, vmonto_max_act
                        FROM bdibei:"informix".bei_operaciones 
                            WHERE id_perfil = pIdPerfil
                            AND num_cta = vnum_cta
                            AND id_menu_oper = vid_menu_oper;

                        SELECT mancomunado, monto_min, monto_max
                            INTO vmanco_ant, vmonto_min_ant, vmonto_max_ant
                        FROM bdibei:"informix".bei_operaciones_temporal
                            WHERE id_perfil = pIdPerfil
                            AND num_cta = vnum_cta
                            AND id_menu_oper = vid_menu_oper;
                        
                            IF (vmanco_act != vmanco_ant) THEN -- Primera validacion cuando existe la misma operacion una sola vez
                                LET vis_cta_mod = 't';
                            END IF;
                            
                            IF (vmonto_min_act != vmonto_min_ant) THEN -- Segunda validacion cuando existe la misma operacion una sola vez
                                LET vis_cta_mod = 't';
                            END IF;

                            IF (vmonto_max_act != vmonto_max_ant) THEN -- Tercera validacion cuando existe la misma operacion una sola vez
                                LET vis_cta_mod = 't';
                            END IF;
                    END IF;

                    IF (vcont_oper_act == 2 AND vcont_oper_ant == 2) THEN -- Existe la misma operacion marcada en la opcion Mancomunidad e Indistinto
                        -- Validaciones para montos con la opcion de Mancomunidad
                        SELECT monto_min, monto_max
                            INTO vmonto_min_act, vmonto_max_act
                        FROM bdibei:"informix".bei_operaciones 
                            WHERE id_perfil = pIdPerfil
                            AND num_cta = vnum_cta
                            AND id_menu_oper = vid_menu_oper
                            AND mancomunado = 't';

                        SELECT monto_min, monto_max
                            INTO vmonto_min_ant, vmonto_max_ant
                        FROM bdibei:"informix".bei_operaciones_temporal
                            WHERE id_perfil = pIdPerfil
                            AND num_cta = vnum_cta
                            AND id_menu_oper = vid_menu_oper
                            AND mancomunado = 't';

                        IF (vmonto_min_act != vmonto_min_ant) THEN -- Primera validacion cuando existe la misma operacion marcada en la opcion Mancomunidad
                            LET vis_cta_mod = 't';
                        END IF;

                        IF (vmonto_max_act != vmonto_max_ant) THEN -- Segunda validacion cuando existe la misma operacion marcada en la opcion Mancomunidad
                            LET vis_cta_mod = 't';
                        END IF;

                        -- Validaciones para montos con la opcion de Indistinto
                        SELECT monto_min, monto_max
                            INTO vmonto_min_act, vmonto_max_act
                        FROM bdibei:"informix".bei_operaciones 
                            WHERE id_perfil = pIdPerfil
                            AND num_cta = vnum_cta
                            AND id_menu_oper = vid_menu_oper
                            AND mancomunado = 'f';

                        SELECT monto_min, monto_max
                            INTO vmonto_min_ant, vmonto_max_ant
                        FROM bdibei:"informix".bei_operaciones_temporal
                            WHERE id_perfil = pIdPerfil
                            AND num_cta = vnum_cta
                            AND id_menu_oper = vid_menu_oper
                            AND mancomunado = 'f';

                        IF (vmonto_min_act != vmonto_min_ant) THEN -- Primera validacion cuando existe la misma operacion marcada en la opcion Indistinto
                            LET vis_cta_mod = 't';
                        END IF;

                        IF (vmonto_max_act != vmonto_max_ant) THEN -- Segunda validacion cuando existe la misma operacion marcada en la opcion Indistinto
                            LET vis_cta_mod = 't';
                        END IF;
                    END IF;
                END IF;
                
                -- Limpiar variables
                LET vcont_oper_ant = 0;
                LET vcont_oper_act = 0;
                LET vmanco_ant = 'f';
                LET vmanco_act = 'f';
                LET vmonto_min_ant = 0.0;
                LET vmonto_min_act = 0.0;
                LET vmonto_max_ant = 0.0;
                LET vmonto_max_act = 0.0;

        END FOREACH;

        IF(vis_cta_mod) THEN -- Si la cuenta fue modificada guardar en bei_perfil_oper_ctas_mod_historico
            INSERT INTO bdibei:"informix".bei_perfil_oper_ctas_mod_historico(id_historico, id_bitacora_admin, id_usuario, id_perfil, num_cta, fecha_mov_historico) 
                VALUES(0, pIdBitacoraAdmin, pIdUsuario, pIdPerfil, vnum_cta, CURRENT YEAR TO SECOND);
        END IF;
        
        LET vautoriza_ant = 'f';
        LET vautoriza_act = 'f';
        LET vid_menu_oper = 0;
        LET vis_cta_mod = 'f';

    END FOREACH;

    -- Borrar temporales
    DELETE FROM bei_mancomunidad_temporal WHERE num_cte = pNumCliente AND id_usuario = pIdUsuario; 
    DELETE FROM bei_operaciones_temporal WHERE id_perfil = pIdPerfil;

    RETURN cod_ret;

END
END PROCEDURE;