CREATE PROCEDURE "informix".consnumctapornumcte(pEmpresa CHAR(3), pNumCliente CHAR(20))

	RETURNING
	CHAR(5) ,  -- Codigo de retorno
	CHAR(20); -- Numero de cuenta

	DEFINE v_cod_ret CHAR(5);
	DEFINE v_cuenta  CHAR(20);
	DEFINE v_ciclo   INTEGER;

	LET v_cod_ret = "000";
	LET v_cuenta  = "";
	LET v_ciclo   = 0;

        SET ISOLATION TO DIRTY READ;

	FOREACH
		SELECT {+INDEX(sc_firmantes fir2)} cuenta
		INTO v_cuenta
		FROM bdicheq:sc_firmantes
		WHERE empresa = pEmpresa 
                AND numcte = pNumCliente
		ORDER BY cuenta 

		IF NOT v_cuenta is null THEN
			LET v_ciclo = v_ciclo + 1;

			RETURN v_cod_ret, v_cuenta WITH RESUME;
		END IF

	END FOREACH;

	IF  v_ciclo = 0 THEN
		RETURN "101", "No hay cuentas";
	END IF

END PROCEDURE
;