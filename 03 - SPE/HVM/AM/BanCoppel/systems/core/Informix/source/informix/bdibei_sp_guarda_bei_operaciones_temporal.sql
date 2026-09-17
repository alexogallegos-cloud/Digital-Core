CREATE PROCEDURE "informix".sp_guarda_bei_operaciones_temporal(pIdPerfil INTEGER)

RETURNING CHAR(5);

	--****************************************************************************************************
	-- DESCRIPCION: Procedimiento que guarda en la tabla bei_operaciones_temporal
	-- AUTOR : Solser
	-- FECHA : 18/07/2018

	-- FECHA LIBERACIÃN PRODUCCIÃN: 07-AGOSTO-2018
	-- BASE DE DATOS: BDIBEI
	--***************************************************************************************************

 --select * from bei_operaciones where id_perfil = 466 order by num_cta, id_oper

	DEFINE sql_err INTEGER;
	DEFINE cod_ret CHAR(5);
    DEFINE vid_oper INTEGER;
	
	LET cod_ret = '00000';
    LET vid_oper = 0;

BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
        END IF;
    END EXCEPTION;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION DIRTY READ;

    -- Valida parametros
    IF (NVL(pIdPerfil, -1) == -1) THEN
        LET cod_ret = '00001'; -- Algun parametro requerido es nulo
        RETURN cod_ret;
    END IF;
		
    -- Realiza copia de registros en tabla temporal
    IF((SELECT count(id_oper) FROM bdibei:"informix".bei_operaciones WHERE id_perfil = pIdPerfil) > 0) THEN
        FOREACH 
            SELECT id_oper INTO vid_oper FROM bdibei:"informix".bei_operaciones WHERE id_perfil = pIdPerfil ORDER BY num_cta, id_oper

            INSERT INTO bdibei:"informix".bei_operaciones_temporal(
                    id_temp, id_oper, id_menu_oper, id_perfil, 
                    num_cta, monto_min, monto_max, mancomunado, 
                    createdby, createdon, updatedby, updatedon) 
            SELECT 	0, NVL(id_oper, -1), NVL(id_menu_oper, -1), NVL(id_perfil, -1), 
                    NVL(num_cta, ''), NVL(monto_min, 0), NVL(monto_max, 0), NVL(mancomunado, 'f'), 
                    NVL(createdby, 0), NVL(createdon, TODAY), NVL(updatedby, 0), NVL(updatedon, TODAY)
                FROM bdibei:"informix".bei_operaciones
                WHERE id_perfil = pIdPerfil AND id_oper = vid_oper;
        END FOREACH;
    END IF;

    RETURN cod_ret;

END;
END PROCEDURE;