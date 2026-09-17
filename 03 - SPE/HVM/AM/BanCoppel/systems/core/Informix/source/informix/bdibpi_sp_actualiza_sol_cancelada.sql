CREATE PROCEDURE "informix".sp_actualiza_sol_cancelada(pNumSol char(10),pNumCte CHAR(9))
	RETURNING CHAR(5)
	
	--Realizo: Francisco Rodríguez Ibarrra
	--Solicito: Mauricio Leon
	--Actividad: Actualiza el tipo de la solicitud a 5
	-- Fecha: 24-08-2011
	
	--DEFINICION DE VARIABLES
	DEFINE vCodRet 		CHAR(5);
	DEFINE sql_err 		INTEGER;
	
	--Asignacion de valores a variables
	LET vCodRet='00000';
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let vCodRet = sql_err;
				RETURN vCodRet;
			END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 10;
	   
	    IF EXISTS(SELECT numcte from bdibpi:"informix".bpi_tokensolicitud where solicitud=pNumSol and numcte=pNumCte) THEN
			update bdibpi:"informix".bpi_tokensolicitud set tipo=5 where solicitud=pNumSol and numcte=pNumCte;
		ELSE
			LET vCodRet='00001';
		END IF
		RETURN vCodRet;
	END
END PROCEDURE
		;