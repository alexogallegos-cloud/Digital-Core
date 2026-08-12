CREATE PROCEDURE "informix".sp_obtener_num_serie_token_web(pNumCte char(9))
		RETURNING char(5), char(10);

	--Define variables
	define sql_err integer;
	define cod_ret char (5);
	define vNumSerie char(9);

	--Inicializa Variables
	LET sql_err = 0;
	LET cod_ret = '00000';
	LET vNumSerie = '';

	--Realizo: Javier Calderon
	--Fecha: 30/12/08
	--Solicito: Mauricio Leon
	--Actividad: Obtiene el numero de serie del token asignado a un cliente


	BEGIN
	 ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cod_ret = sql_err;
			RETURN cod_ret, vNumSerie;
		END IF;
	 END EXCEPTION;

	 SET ISOLATION TO DIRTY READ;
	 SET LOCK MODE TO WAIT 3;
	 
	 IF EXISTS(SELECT numcte FROM si_bpiusuarios WHERE numcte = pNumCte) THEN
				SELECT ns_token INTO vNumSerie FROM si_bpitoken WHERE empresa = '001' AND  num_cliente = pNumCte;

	 ELSE
			LET cod_ret = '00001'; --El Cliente no existe
	 END IF;

	 RETURN cod_ret, NVL(vNumSerie,'');

	END;

END PROCEDURE;