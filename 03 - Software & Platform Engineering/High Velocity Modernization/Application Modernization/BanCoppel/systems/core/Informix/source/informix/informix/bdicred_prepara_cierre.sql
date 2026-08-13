CREATE PROCEDURE "informix".prepara_cierre()


define vcred CHAR(20);
define vfecha date;

let vcred = " ";

--  set debug file to 'prepara_cierre.out';
--  trace on; 

	FOREACH SELECT num_credito INTO vcred
		  FROM sd_maesdos
		 WHERE monto_financiado < 0

		UPDATE sd_maesdos SET monto_financiado = 0 
	 	 WHERE num_credito = vcred ;

	END FOREACH

	FOREACH SELECT num_credito INTO vcred
		  FROM sd_maesdos
	         WHERE sdo_capital < 0

		UPDATE sd_maesdos SET sdo_intereses = 0 
 		 WHERE num_credito = vcred;

		SELECT MIN(fecha_cuota)
		  INTO vfecha
                  FROM sd_amortiza_credito
                 WHERE num_credito = vcred ;

		UPDATE  sd_amortiza_credito
		   SET capital_mto_cuota = 0,
		       capital_debe      = 0
		 WHERE num_credito = vcred
		   AND fecha_cuota = vfecha;

	END FOREACH

        UPDATE sd_maecredanexo SET dias_fecha_max_pago = 26
	WHERE 1=1;

END PROCEDURE
;