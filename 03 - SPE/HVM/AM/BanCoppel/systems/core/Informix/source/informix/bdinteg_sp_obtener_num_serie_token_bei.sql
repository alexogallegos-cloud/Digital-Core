CREATE PROCEDURE "informix".sp_obtener_num_serie_token_bei(pNumCte char(9))
		RETURNING char(5), char(10);

	define sql_err integer;
	define cCod_ret char (5);
	define cNumSerie char(9);

	LET sql_err = 0;
	LET cCod_ret = '000';
	LET cNumSerie = '';

	--Realizó: Manuel Ramos Figueroa
	--Fecha: 26/08/2011
	--Actividad: Obtiene el numero de serie del token asignado a un cliente

	BEGIN
	 ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCod_ret = sql_err;
			RETURN cCod_ret, cNumSerie;
		END IF;
	 END EXCEPTION;

	SET LOCK MODE TO WAIT ;
	SET ISOLATION DIRTY READ ;
	 
	 IF EXISTS(SELECT num_cliente FROM bdinteg:"informix".si_bpiusuariospm WHERE num_cliente = pNumCte) THEN
				SELECT ns_token INTO cNumSerie FROM bdinteg:"informix".si_bpitokenpm WHERE empresa = '001' AND  num_cliente = pNumCte;


	 ELSE
			LET cCod_ret = '001'; --El Cliente no existe
	 END IF;

	 RETURN cCod_ret, cNumSerie;

	END;

END PROCEDURE;