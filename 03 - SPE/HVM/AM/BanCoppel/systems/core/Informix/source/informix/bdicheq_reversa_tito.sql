CREATE PROCEDURE "informix".reversa_tito(etran CHAR(4))
RETURNING CHAR(5),CHAR(20);


DEFINE v_folio CHAR(16);
DEFINE v_serie INTEGER;
DEFINE v_cuenta CHAR(20);
DEFINE v_monto  MONEY(14,2);
DEFINE v_con    CHAR(10);
DEFINE v_regresa CHAR(5);
DEFINE v_paso    CHAR(4);
DEFINE v_fpaso   DATE;
DEFINE v_mpaso   MONEY(14,2);
DEFINE v_retorno CHAR(5);
DEFINE v_mensaje CHAR(50);
DEFINE v_nat     CHAR(1);

	SELECT naturaleza INTO v_nat FROM bdinteg:si_transacc
	 WHERE empresa ="001"
	   AND numero = etran;

	IF v_nat IS NULL THEN
		LET v_mensaje ="Transaccion NO Existe";
		LET v_retorno = "0001";
		RETURN v_retorno, v_mensaje;
	END IF

	IF v_nat <> "A" THEN
		LET v_mensaje ="Transaccion debe Ser de Abono";
		LET v_retorno = "0002";
		RETURN v_retorno, v_mensaje;
	END IF

BEGIN WORK;
	FOREACH SELECT LPAD(consecutivo,10,"0"), cuenta, monto  i
		  INTO v_con, v_cuenta, v_monto
	          FROM axcred:nomina
		 WHERE codret <> "000"



		LET v_folio = "nomina" || v_con;

		EXECUTE PROCEDURE abono_ref("001",
                                      "001",
                                      "informix",
                                      etran,
                                      "0000",
                                      v_folio,
                                      v_cuenta,
                                      0,
                                      v_monto,v_monto,0,0,0,
                                      "01",
                                      " " )
		INTO v_regresa;

		IF v_regresa <> "000" THEN
			UPDATE axcred:nomina SET codret = v_regresa
			 WHERE consecutivo = v_con;
		ELSE
			UPDATE axcred:nomina SET codret = "000"
			 WHERE consecutivo = v_con;

		END IF


	END FOREACH

END PROCEDURE;