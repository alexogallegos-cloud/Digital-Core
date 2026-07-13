CREATE PROCEDURE "informix".levanta_sdos()

DEFINE v_cred CHAR(20);
DEFINE v_cap MONEY(14,2);
DEFINE v_int MONEY(14,2);

	FOREACH SELECT num_credito, capital, interes
	          INTO v_cred, v_cap, v_int
	          FROM auxcreacred

		UPDATE sd_maesdos SET sdo_capital = v_cap,
				       sdo_cap_insoluto = v_cap,
				       sdo_no_exig = v_int   
		 WHERE num_credito = v_cred;

	END FOREACH

END PROCEDURE;