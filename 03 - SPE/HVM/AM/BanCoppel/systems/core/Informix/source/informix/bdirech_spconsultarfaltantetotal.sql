CREATE PROCEDURE "informix".spconsultarfaltantetotal(p_sNumEmpleado CHAR(8), p_dFecha DATE)
RETURNING MONEY AS SaldoActual
			
	DEFINE mSaldoActual		MONEY;
	
--	SET DEBUG FILE TO "/tmp/Gilberto/spconsultarfaltantetotal.out";
--	TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	BEGIN
		FOREACH
			SELECT NVL(SUM(saldoactual),0) INTO mSaldoActual
			FROM bdirech:"informix".rec_confaltante
			WHERE idfaltante <> 0 AND numempleado = NVL(p_sNumEmpleado, numempleado)
			  AND idasignado = 2
			  AND saldoactual > 0
			  AND fecharegistro <= NVL(p_dFecha, fecharegistro)
			
			RETURN mSaldoActual WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE
