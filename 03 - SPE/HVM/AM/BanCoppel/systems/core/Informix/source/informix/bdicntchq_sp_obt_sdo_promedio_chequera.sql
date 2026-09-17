CREATE PROCEDURE "informix".sp_obt_sdo_promedio_chequera(pNumParam integer)
        RETURNING char(5), char(60);

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener parametro saldo promedio minimo para obtener chequera
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 19/03/2010

   DEFINE vCodret   char(5);
   DEFINE vValor  char(60);
   DEFINE sql_err integer;

	ON EXCEPTION SET sql_err
	   IF sql_err <> 0 THEN
		LET vCodret = sql_err;
		RETURN vCodret, vValor;
	   END IF;
	END EXCEPTION;

	LET vCodret = '000';
	LET vValor = '';

	BEGIN
		IF EXISTS(SELECT valor FROM sq_param WHERE cod_param = pNumParam) THEN

			SELECT valor
			INTO vValor
			FROM sq_param
			WHERE cod_param = pNumParam;

			RETURN vCodret, vValor;

		ELSE
			LET vCodret = '001';
			RETURN vCodret, vValor;
		END IF;
	END;
END PROCEDURE;