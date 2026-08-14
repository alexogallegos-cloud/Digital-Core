CREATE PROCEDURE "informix".sp_actualiza_status_manco_acttknadmin(pNumCliente CHAR(9), pIdUsuario INTEGER)

RETURNING CHAR(5);
-- cod_ret

--****************************************************************************************************
-- DESCRIPCION: Procedimiento que activacion de tokens por renovacion
-- AUTOR : Solser
-- FECHA : 30/08/2018
-- BD: bdibei
--***************************************************************************************************

    DEFINE sql_err INTEGER;
    DEFINE cod_ret CHAR(5);
    DEFINE vid_tipo_usuario SMALLINT;
    DEFINE vStatus_manco SMALLINT;

	LET cod_ret = '00000';
    LET vStatus_manco = -1;
    LET vid_tipo_usuario = 0;
	

	
	
	
	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_actualiza_status_manco_acttknadmin.out";
	--TRACE ON;

BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
        END IF;
    END EXCEPTION;

    -- Valida parametros
    IF(NVL(pNumCliente, '') == '' OR NVL(pIdUsuario, -1) == -1) THEN
        LET cod_ret = '00001'; -- Algun parametro requerido es nulo
        RETURN cod_ret;
    END IF;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- Si el usuario es admin y su status_manco = 2 se actualiza el estatus de mancomunidad a 1
    SELECT id_tipo_usuario 
        INTO vid_tipo_usuario
    FROM bei_usuario
        WHERE id_usuario = pIdUsuario;

    IF(vid_tipo_usuario = 1) THEN -- Si el usuario es admin
        SELECT NVL(status_manco, -1) 
            INTO vStatus_manco
        FROM bdibei:"informix".bei_servicio 
            WHERE id_usuario = pIdUsuario;

        IF(vStatus_manco == 2) THEN
            UPDATE bdibei:"informix".bei_servicio 
            SET status_manco = 1, f_mod_manco = TODAY
            WHERE num_cliente = pNumCliente AND id_usuario = pIdUsuario; 
        END IF;
    END IF;

    RETURN cod_ret;
   
END
END PROCEDURE;