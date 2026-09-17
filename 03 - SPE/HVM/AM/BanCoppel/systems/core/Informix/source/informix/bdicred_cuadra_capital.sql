CREATE PROCEDURE "informix".cuadra_capital()
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

	UPDATE sd_maesdos SET sdo_capital =0, 
                              monto_vencido=0, 
                              mto_venc_trasp=0
	 WHERE 1=1;
	SELECT a.num_credito, sdo_capital, SUM(saldo_cuota - monto_real_pag) det
	  FROM sd_maesdos a, sd_pagocapit b
	 WHERE a.num_credito = b.num_credito
	   AND status_cuota ="1"
	   AND SUBSTR(a.num_credito,10,3) <> "410"
	 GROUP BY 1,2
	  INTO TEMP cap_vigente;

	FOREACH SELECT num_credito, det
                  INTO v_credito, v_dif
                  FROM cap_vigente
                 WHERE sdo_capital <>  det 


                   UPDATE sd_maesdos SET sdo_capital =  v_dif
                    WHERE num_credito = v_credito;


        END FOREACH



-- ***************************************************************************
-- *                          Cuadra Capital Vencido                         *
-- ***************************************************************************

        SELECT a.num_credito,monto_vencido,SUM(saldo_cuota - monto_real_pag) det
          FROM sd_maesdos a, sd_pagocapit b
         WHERE a.num_credito = b.num_credito
           AND status_cuota ="7"
	   AND SUBSTR(a.num_credito,10,3) <> "410"
         GROUP BY 1,2
          INTO TEMP cap_vencido;


        FOREACH SELECT num_credito, det
                  INTO v_credito, v_dif
                  FROM cap_vencido
                 WHERE monto_vencido <> det 

                   UPDATE sd_maesdos SET monto_vencido = v_dif
                    WHERE num_credito = v_credito;



        END FOREACH
-- ***************************************************************************
-- *                   Cuadra Capital Vencido Traspasado                     *
-- ***************************************************************************

        SELECT a.num_credito,mto_venc_trasp,
	       SUM(saldo_cuota - monto_real_pag) det
          FROM sd_maesdos a, sd_pagocapit b
         WHERE a.num_credito = b.num_credito
           AND status_cuota ="2"
	   AND SUBSTR(a.num_credito,10,3) <> "410"
         GROUP BY 1,2
          INTO TEMP cap_traspasado;

        FOREACH SELECT num_credito, det
                  INTO v_credito, v_dif
                  FROM cap_traspasado
                 WHERE mto_venc_trasp <> det 

                   UPDATE sd_maesdos SET mto_venc_trasp = v_dif
                    WHERE num_credito = v_credito;

        END FOREACH

-- ***************************************************************************
-- *                   Cuadra Capital Insoluto                               *
-- ***************************************************************************

        SELECT num_credito, sdo_cap_insoluto,
	       (sdo_capital + monto_vencido + mto_venc_trasp) det
          FROM sd_maesdos 
	 WHERE SUBSTR(num_credito,10,3) <> "410"
          INTO TEMP capital;


        FOREACH SELECT num_credito, det
                  INTO v_credito, v_dif
                  FROM capital
                 WHERE sdo_cap_insoluto <> det 

		UPDATE sd_maesdos SET sdo_cap_insoluto = v_dif
		 WHERE num_credito = v_credito;


	END FOREACH

END
	RETURN scod_ret;
END PROCEDURE;