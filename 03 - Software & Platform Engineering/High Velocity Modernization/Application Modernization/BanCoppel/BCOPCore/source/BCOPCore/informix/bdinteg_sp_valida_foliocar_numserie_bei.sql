CREATE PROCEDURE "informix".sp_valida_foliocar_numserie_bei(pNumCte char(9), pFolio char(25), pNumSerie char(10))
		RETURNING char(5);

	DEFINE sql_err integer;
	DEFINE cCod_ret char (5);

	LET sql_err = 0;
	LET cCod_ret = '000';

	--Realizó: Manuel Ramos Figueroa
	--Fecha: 05/08/2011
	--Actividad: Valida que el folio de la caratula y el numero de serie concuerden con el cliente

	BEGIN
	 ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCod_ret = sql_err;
			RETURN cCod_ret;
		END IF;
	 END EXCEPTION;

	SET LOCK MODE TO WAIT ;
	SET ISOLATION DIRTY READ ;
	 
	 IF NOT EXISTS(SELECT num_cliente FROM bdinteg:"informix".si_bpitokenpm WHERE num_cliente = pNumCte AND folio_token = pFolio) THEN
		RETURN '001';
	 END IF;

	 IF NOT EXISTS(SELECT num_cliente FROM bdinteg:"informix".si_bpitokenpm WHERE num_cliente = pNumCte AND ns_token = pNumSerie) THEN
		RETURN '002';
	 END IF;
	 
	 RETURN cCod_ret;

	END;

END PROCEDURE;