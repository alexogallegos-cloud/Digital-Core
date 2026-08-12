CREATE PROCEDURE "informix".reproceso()
RETURNING char(5);


DEFINE v_credito CHAR(20);
DEFINE v_fechas DATE;
DEFINE ax_codret CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE v_mtooto MONEY(14,2);
DEFINE v_det    MONEY(14,2);
DEFINE v_dif    MONEY(14,2);

-- ASIGNA VALORES
LET ax_codret ="00000";
LET vsqlerr = 0;

-- CONTROL DE ERRORES
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET ax_codret=vsqlerr;
      RETURN ax_codret;
   END IF;
END EXCEPTION;



-- PROGRAMA PRINCIPAL

	select num_credito, monto_otorgado ,
		(select sum(monto_cuota) from sd_pagocapit b
		  where a.num_credito = b.num_credito) detalle
		   from sd_maesdos a
  	 where substr(num_credito,10,3) <> "410"
	   into temp axel;

	FOREACH select num_credito, monto_otorgado, detalle,
			monto_otorgado-detalle
		  INTO  v_credito, v_mtooto, v_det, v_dif
		  from axel
		 where monto_otorgado-detalle <> 0

		SELECT MAX(fecha_cuota)
		  INTO v_fechas
		  FROM sd_pagocapit
		 WHERE num_credito = v_credito
		   AND status_cuota IN ('1','2','7');

		IF v_dif > 0 THEN
			UPDATE sd_pagocapit
			   SET monto_cuota = monto_cuota + v_dif,
			       saldo_cuota = saldo_cuota + v_dif
			 WHERE num_credito = v_credito
			   AND fecha_cuota = v_fechas;
		ELSE
			LET v_dif = v_dif * -1;
			UPDATE sd_pagocapit
			   SET monto_cuota = monto_cuota - v_dif,
			       saldo_cuota = saldo_cuota - v_dif
			 WHERE num_credito = v_credito
			   AND fecha_cuota = v_fechas;
		END IF

	END FOREACH

END
	RETURN ax_codret;
END PROCEDURE;