CREATE PROCEDURE "informix".cuadra_interes()
RETURNING CHAR(5);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE v_credito    CHAR(20);
DEFINE v_dif        MONEY(14,2);
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "00000";
LET vsqlerr      = 0;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      ROLLBACK WORK;
      RETURN scod_ret;
   END IF;
END EXCEPTION;


-- **************************************************************************** 
BEGIN WORK;

	UPDATE sd_maesdos SET sdo_no_exig =0,
			   sdo_exig_int =0,
			   mto_venc_int = 0,
			   mto_venc_tra_int =0
	WHERE 1=1    ;

	SELECT a.num_credito, sdo_no_exig, SUM(monto_cuota - monto_real_pag) det
	  FROM sd_maesdos a, sd_paginter b
	 WHERE a.num_credito = b.num_credito
	   AND status_cuota ="1"
	   AND SUBSTR(a.num_credito,10,3) <> "410"
	 GROUP BY 1,2
	  INTO TEMP int_vigente;

	FOREACH SELECT num_credito, det
                  INTO v_credito, v_dif
                  FROM int_vigente
                 WHERE sdo_no_exig - det <> 0


                UPDATE sd_maesdos SET sdo_no_exig = v_dif 
                 WHERE num_credito = v_credito;

        END FOREACH



-- ***************************************************************************
-- *                          Cuadra Interes Vencido                         *
-- ***************************************************************************

        SELECT a.num_credito,mto_venc_int,
	       SUM(monto_cuota - monto_real_pag) det
          FROM sd_maesdos a, sd_paginter b
         WHERE a.num_credito = b.num_credito
           AND status_cuota ="7"
	   AND SUBSTR(a.num_credito,10,3) <> "410"
         GROUP BY 1,2
          INTO TEMP int_vencido;


        FOREACH SELECT num_credito, det
                  INTO v_credito, v_dif
                  FROM int_vencido
                 WHERE mto_venc_int - det <> 0


                UPDATE sd_maesdos SET mto_venc_int = v_dif
                    WHERE num_credito = v_credito;


        END FOREACH
-- ***************************************************************************
-- *                   Cuadra Interes Vencido Traspasado                     *
-- ***************************************************************************

        SELECT a.num_credito,mto_venc_tra_int,
	       SUM(monto_cuota - monto_real_pag) det
          FROM sd_maesdos a, sd_paginter  b
         WHERE a.num_credito = b.num_credito
           AND status_cuota ="2"
	   AND SUBSTR(a.num_credito,10,3) <> "410"
         GROUP BY 1,2
          INTO TEMP int_traspasado;

        FOREACH SELECT num_credito, det
                  INTO v_credito, v_dif
                  FROM int_traspasado
                 WHERE mto_venc_tra_int - det <> 0


                UPDATE sd_maesdos SET mto_venc_tra_int = v_dif
                 WHERE num_credito = v_credito;


        END FOREACH

-- ***************************************************************************
-- *                   Cuadra Interes Exigible                               *
-- ***************************************************************************

        SELECT num_credito, sdo_exig_int,
	       (mto_venc_int + mto_venc_tra_int) det
          FROM sd_maesdos 
	 WHERE SUBSTR(num_credito,10,3) <> "410"
          INTO TEMP interes;


        FOREACH SELECT num_credito, det
                  INTO v_credito, v_dif
                  FROM interes
                 WHERE sdo_exig_int <> det 

		UPDATE sd_maesdos SET sdo_exig_int = v_dif
		 WHERE num_credito = v_credito;


	END FOREACH

END
	RETURN scod_ret;
END PROCEDURE;