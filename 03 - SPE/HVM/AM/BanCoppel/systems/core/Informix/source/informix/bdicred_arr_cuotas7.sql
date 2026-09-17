CREATE PROCEDURE "informix".arr_cuotas7()
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

	select a.num_credito, (SELECT count(*) from sd_paginter b
                        where b.num_credito = a.num_credito
                          and status_cuota ="7") cuantas
	from sd_maecred a
	where status_cred ="BT"
	into temp dra;
	FOREACH select * INTO v_credito, v_dif
		  from dra where cuantas > 0


		UPDATE sd_paginter SET status_cuota ="2"
		 WHERE status_cuota ="7"
		   AND num_credito = v_credito;

	END FOREACH

END
	RETURN ax_codret;
END PROCEDURE;