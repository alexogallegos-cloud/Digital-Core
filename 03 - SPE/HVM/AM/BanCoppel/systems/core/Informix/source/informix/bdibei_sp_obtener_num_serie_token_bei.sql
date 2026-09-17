CREATE PROCEDURE "informix".sp_obtener_num_serie_token_bei(pIdUsuario INTEGER,pNumCte char(9))
		RETURNING char(5), char(10);

	--Define variables
	define sql_err INTEGER;
	define cod_ret char (5);
	define vNumSerie char(9);


	--Inicializa Variables
	LET sql_err = 0;
	LET cod_ret = '00000';
	LET vNumSerie = '';

--****************************************************************************************************
-- DESCRIPCION:  Obtiene el numero de serie del token asignado a un cliente
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************

	BEGIN
	 ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cod_ret = sql_err;
			RETURN cod_ret, vNumSerie;
		END IF;
	 END EXCEPTION;

	 IF NVL(pIdUsuario,-1) <> -1 THEN
				SELECT ns_token INTO vNumSerie FROM "informix".bei_token WHERE id_usuario = pIdUsuario AND  num_cliente = pNumCte;
	 ELSE
			LET cod_ret = '00001'; --El Cliente no existe
	 END IF;

	 RETURN cod_ret, vNumSerie;

	END;

END PROCEDURE;