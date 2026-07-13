CREATE PROCEDURE "informix".sp_valida_numserie(pNumCte char(9), pNumSerie char(10))
		RETURNING char(5);

-----------------------------------------------------------------------------------------------
-- Realizó: Pedro Gaspar Jimenez Guzman
-- Actividad: Valida en numero de serie de token renovado
-- Solicitó: Walber Castro
-- Fecha de Solicitud: 23/12/2013
------------------------------------------------------------------------------------------------
		
	--Define variables
	define sql_err integer;
	define cod_ret char (5);

	--Inicializa Variables
	LET sql_err = 0;
	LET cod_ret = '00000';

	BEGIN
	 ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cod_ret = sql_err;
			RETURN cod_ret;
		END IF;
	 END EXCEPTION;

	--SET DEBUG FILE TO "/home/informix/bibiana/sp_valida_numserie.out";
	--TRACE ON;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	 
	 IF NOT EXISTS(SELECT num_cliente FROM bdinteg:"informix".si_bpitoken WHERE num_cliente = pNumCte AND ns_token = pNumSerie) THEN
		RETURN '00001';
	 END IF;
	 
	 RETURN cod_ret;

	END;

END PROCEDURE;