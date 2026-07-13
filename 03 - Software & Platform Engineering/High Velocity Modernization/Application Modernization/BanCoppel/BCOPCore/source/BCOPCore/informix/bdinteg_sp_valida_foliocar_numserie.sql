CREATE PROCEDURE "informix".sp_valida_foliocar_numserie(pNumCte char(9), pFolio char(25), pNumSerie char(10))
		RETURNING char(5);

	--Define variables
	define sql_err integer;
	define cod_ret char (5);

	--Inicializa Variables
	LET sql_err = 0;
	LET cod_ret = '000';

	--Realizó: Javier Calderon
	--Fecha: 30/12/08
	--Solicitó: Mauricio León
	--Actividad: Valida que el folio de la caratula y el numero de serie concuerden con el cliente


	BEGIN
	 ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cod_ret = sql_err;
			RETURN cod_ret;
		END IF;
	 END EXCEPTION;

	 IF NOT EXISTS(SELECT num_cliente FROM si_bpitoken WHERE num_cliente = pNumCte AND folio_token = pFolio) THEN
		RETURN '001';
	 END IF;

	 IF NOT EXISTS(SELECT num_cliente FROM si_bpitoken WHERE num_cliente = pNumCte AND ns_token = pNumSerie) THEN
		RETURN '002';
	 END IF;
	 
	 RETURN cod_ret;

	END;

END PROCEDURE;