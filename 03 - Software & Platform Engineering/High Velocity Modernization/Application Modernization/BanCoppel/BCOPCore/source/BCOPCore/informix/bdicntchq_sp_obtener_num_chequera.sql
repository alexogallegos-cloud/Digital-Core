CREATE PROCEDURE "informix".sp_obtener_num_chequera(pEmpresa char(3), pCuenta char(20))
        RETURNING char(5), integer;

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obtener el numero de chequera recien solicitada
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 22/03/2010

   DEFINE vCodret   char(5);
   DEFINE vNumChequera integer;
   DEFINE sql_err integer;

	ON EXCEPTION SET sql_err
	   IF sql_err <> 0 THEN
		LET vCodret = sql_err;
		RETURN vCodret, vNumChequera;
	   END IF;
	END EXCEPTION;

	LET vCodret = '000';
	LET vNumChequera = 0;
	
	BEGIN
		SELECT max(consec)
		INTO vNumChequera
		FROM sq_maechqra
		WHERE empresa = pEmpresa
		AND cuenta = pCuenta
		AND status = "S";
		
		RETURN vCodret, vNumChequera;
	END;

END PROCEDURE;