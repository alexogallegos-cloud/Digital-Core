CREATE PROCEDURE "informix".sp_guarda_bei_mancomunidad_temporal(pNumCliente CHAR(9), pIdUsuario INTEGER)

RETURNING CHAR(5);

	--****************************************************************************************************
	-- DESCRIPCION: Procedimiento que guarda en la tabla bei_mancomunidad_temporal
	-- AUTOR : Solser
	-- FECHA : 18/07/2018

	-- FECHA LIBERACIÃN PRODUCCIÃN: 07-AGOSTO-2018
	-- BASE DE DATOS: BDIBEI
	--***************************************************************************************************


	DEFINE sql_err INTEGER;
	DEFINE cod_ret CHAR(5);
    DEFINE vnum_cta CHAR(20);
	
	LET cod_ret = '00000';
    LET vnum_cta = '';

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
    IF (NVL(pNumCliente, '') == '' OR NVL(pIdUsuario, -1) == -1) THEN
        LET cod_ret = '00001'; -- Algun parametro requerido es nulo
        RETURN cod_ret;
    END IF;
		
    -- Realiza copia de registros en tabla temporal
    IF((SELECT count(num_cta) FROM bdibei:"informix".bei_mancomunidad WHERE num_cte = pNumCliente AND id_usuario = pIdUsuario) > 0) THEN
        FOREACH 
            SELECT num_cta INTO vnum_cta FROM bdibei:"informix".bei_mancomunidad WHERE num_cte = pNumCliente AND id_usuario = pIdUsuario

            INSERT INTO bdibei:"informix".bei_mancomunidad_temporal(id_temp, id_usuario, num_cte, num_cta, autoriza) 
                SELECT 	0, NVL(id_usuario, -1), NVL(num_cte, ''), NVL(num_cta, ''), NVL(autoriza, 'f')
                FROM bdibei:"informix".bei_mancomunidad
                WHERE num_cte = pNumCliente AND id_usuario = pIdUsuario AND num_cta = vnum_cta;
        END FOREACH;
    END IF;

    RETURN cod_ret;

END;
END PROCEDURE;