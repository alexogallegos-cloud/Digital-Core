CREATE PROCEDURE "informix".sp_obtener_num_serie_token(pNumCte char(9))
		RETURNING char(5), char(10);

	--Define variables
	define sql_err integer;
	define cod_ret char (5);
	define vNumSerie char(9);

	--Inicializa Variables
	LET sql_err = 0;
	LET cod_ret = '000';
	LET vNumSerie = '';

	--Realizó: Javier Calderon
	--Fecha: 30/12/08
	--Solicitó: Mauricio León
	--Actividad: Obtiene el numero de serie del token asignado a un cliente


	BEGIN
	 ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cod_ret = sql_err;
			RETURN cod_ret, vNumSerie;
		END IF;
	 END EXCEPTION;

	 IF EXISTS(SELECT numcte FROM si_bpiusuarios WHERE numcte = pNumCte) THEN
				SELECT ns_token INTO vNumSerie FROM si_bpitoken WHERE empresa = '001' AND  num_cliente = pNumCte;


	 ELSE
			LET cod_ret = '001'; --El Cliente no existe
	 END IF;

	 RETURN cod_ret, vNumSerie;

	END;

END PROCEDURE;