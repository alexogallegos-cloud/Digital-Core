CREATE PROCEDURE "informix".sp_obtener_id_admin_bei(pIdUsuario INTEGER,pNumCte CHAR(9))
RETURNING CHAR(5),CHAR(30);

    DEFINE sql_err INTEGER;
	DEFINE cod_ret CHAR (5);
	DEFINE id_admin CHAR(30);

	LET sql_err = 0;
	LET cod_ret = '00000';
	LET id_admin = '';

    --****************************************************************************************************
    -- DESCRIPCION:  Obtiene el id de identificacion del administrador por usuario y numero de cliente
    -- FECHA : 10/10/2013
    -- BD: bdibei
    -- SOLICITO :
    --***************************************************************************************************

BEGIN
	 ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cod_ret = sql_err;
			RETURN cod_ret, id_admin;
		END IF;
	 END EXCEPTION;

    IF NVL(pIdUsuario,-1) <> -1 AND NVL(pNumCte,'') <> '' THEN
        SELECT identificacion_admin
        INTO id_admin
        FROM "informix".bei_servicio as servicio
        WHERE servicio.num_cliente=pNumCte
        AND servicio.id_usuario=pIdUsuario;

        IF NVL(id_admin,'') == '' THEN
            LET cod_ret = '00002'; --No se encontro registro
        END IF;
	 ELSE
			LET cod_ret = '00001'; --Alguno de los datos esta vacio
	 END IF;
	 RETURN cod_ret, id_admin;
END;
END PROCEDURE;