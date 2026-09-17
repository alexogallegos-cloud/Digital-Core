CREATE PROCEDURE "informix".sps_obtener_datos_admin_bei(pIdUsuario INTEGER)
RETURNING CHAR(5),CHAR(30),CHAR(9),INTEGER;

    DEFINE sql_err INTEGER;
	DEFINE cod_ret CHAR (5);
	DEFINE id_admin CHAR(30);
    DEFINE num_cliente CHAR(9);
    DEFINE id_usuario INTEGER;

	LET sql_err = 0;
    LET cod_ret = '00000';
	LET id_admin = '';
    LET num_cliente = '';
    LET id_usuario = 0;

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
			RETURN cod_ret, id_admin, num_cliente,id_usuario;
		END IF;
	 END EXCEPTION;

    IF NVL(pIdUsuario,'') <> '' THEN
        SELECT servicio.num_cliente, servicio.identificacion_admin, servicio.id_usuario
        INTO num_cliente,id_admin, id_usuario
        FROM bei_servicio AS servicio 
        INNER JOIN bei_usuario AS usuario
        ON servicio.id_usuario = usuario.id_usuario
        WHERE usuario.id_usuario=pIdUsuario;        

        IF NVL(id_admin,'') == '' THEN
            LET cod_ret = '00002'; --No se encontro registro
        END IF;
	 ELSE
			LET cod_ret = '00001'; --Alguno de los datos esta vacio
	 END IF;
	 RETURN cod_ret, id_admin, num_cliente,id_usuario;
END;
END PROCEDURE;