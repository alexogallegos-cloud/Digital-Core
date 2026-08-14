CREATE PROCEDURE "informix".ajusta_pagos()
RETURNING char(5);


DEFINE v_credito CHAR(20);
DEFINE v_fechas DATE;
DEFINE ax_codret CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE v_mtooto MONEY(14,2);
DEFINE v_det    MONEY(14,2);
DEFINE v_dif    MONEY(14,2);
DEFINE v_cuota  MONEY(14,2);
DEFINE v_st     CHAR(1);

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

	FOREACH select num_credito, diferencia
		  INTO  v_credito,  v_dif
		  from axcred:sdos_dia
		 --WHERE num_credito ="100003877402001"

	   IF v_dif >  0 THEN
		FOREACH SELECT fecha_cuota, monto_real_pag, status_cuota,
			       monto_cuota
		  	  INTO v_fechas, v_det , v_st, v_cuota
		  	  FROM sd_pagocapit
		 	 WHERE num_credito = v_credito
		   	   AND status_cuota IN ('1','2','7','5')
			ORDER BY fecha_cuota DESC
                                --LET v_dif = v_dif * -1;
                               IF v_det = 0 THEN CONTINUE FOREACH; END IF
                               IF v_dif >= v_det THEN
                                        LET v_dif = v_dif - v_det;
                                        LET v_det = 0;
                                        IF v_st ="5" THEN LET v_st="1"; END IF;
                               ELSE
                                        LET v_det = v_det - v_dif;
                                        LET v_dif = 0;
                               END IF
                               UPDATE sd_pagocapit
                                  SET monto_real_pag = v_det,
                                      status_cuota = v_st
                                WHERE num_credito = v_credito
                                  AND fecha_cuota = v_fechas;

			IF v_dif = 0 THEN EXIT FOREACH; END IF
		END FOREACH
	   ELSE
		FOREACH SELECT fecha_cuota, monto_real_pag, status_cuota,
			       monto_cuota
		  	  INTO v_fechas, v_det , v_st, v_cuota
		  	  FROM sd_pagocapit
		 	 WHERE num_credito = v_credito
		   	   AND status_cuota IN ('1','2','7')
			ORDER BY fecha_cuota DESC

				LET v_dif = v_dif * -1;
				IF v_dif >= v_cuota-v_det THEN
					LET v_det = v_cuota;
					LET v_dif = v_dif - v_cuota ;
					LET v_st ="5";
				ELSE
					LET v_det = v_det + v_dif;
					LET v_dif = 0;
				END IF
				UPDATE sd_pagocapit
				   SET monto_real_pag = v_det ,
				       status_cuota = v_st
				 WHERE num_credito = v_credito
				   AND fecha_cuota = v_fechas;

			IF v_dif = 0 THEN EXIT FOREACH; END IF

		END FOREACH
	   END IF

	END FOREACH

END
	RETURN ax_codret;
END PROCEDURE;