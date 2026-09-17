CREATE PROCEDURE "informix".consnumctapornumcte_web(pEmpresa CHAR(3), pNumCliente CHAR(20))

	RETURNING
	CHAR(5),  -- Codigo de retorno
	CHAR(20); -- Numero de cuenta

	DEFINE v_cod_ret CHAR(5);
	DEFINE v_cuenta  CHAR(20);
	DEFINE v_ciclo   INTEGER;

	LET v_cod_ret = "00000";
	LET v_cuenta  = "";
	LET v_ciclo   = 0;

	FOREACH
		SELECT
			num_credito
		INTO
			v_cuenta
		FROM
			bdicred:sd_tarjeta
		WHERE
			empresa = pEmpresa AND
			numcte = pNumCliente
		ORDER BY
			num_credito
					
		IF NOT v_cuenta is NULL THEN
			LET v_ciclo = v_ciclo + 1;

			RETURN v_cod_ret, v_cuenta WITH RESUME;
		END IF	

	END FOREACH;

	IF v_ciclo = 0 THEN
		RETURN "00151", "";
	END IF

END PROCEDURE
                                                                                                                                                                                                                ;