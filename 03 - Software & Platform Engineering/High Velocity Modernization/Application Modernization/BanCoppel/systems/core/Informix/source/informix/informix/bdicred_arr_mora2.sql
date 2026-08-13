CREATE PROCEDURE "informix".arr_mora2(e_dia DATE)
RETURNING CHAR(5);

DEFINE v_credito CHAR(20);
DEFINE v_fecha   DATE;
DEFINE v_monto   MONEY(14,2);
DEFINE vsqlerr   INTEGER;
DEFINE scod_ret  CHAR(5);
DEFINE v_count   SMALLINT;
DEFINE v_fecham  DATE;
DEFINE v_montom  MONEY(14,2);
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
LET vsqlerr = 0;
LET scod_ret = "00000";
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      ROLLBACK WORK;
      RETURN scod_ret;
   END IF;
END EXCEPTION;


BEGIN WORK;

DELETE FROM sd_detmora WHERE fecha_cuota >= '12/01/2003';

FOREACH SELECT a.num_credito, ((campo_trab1) * tasa_moratorios) / 100
	  INTO v_credito, v_monto
          FROM sd_maecred a, sd_maesdos b
         WHERE substr(status_cred ,1,1) ='B'
           AND b.num_credito = a.num_credito
           AND b.empresa = a.empresa
           AND sdo_moratorio > 0

	FOREACH SELECT fecha_cuota, sdo_mora_ordi
		  INTO v_fecham, v_montom
		  FROM sd_detmora
		 WHERE num_credito = v_credito
		   AND empresa = '001'
		   AND sdo_mora_ordi > 0

		IF v_montom <> v_monto THEN
			UPDATE sd_detmora SET sdo_mora_ordi = v_monto
		 	 WHERE num_credito = v_credito
	   		   AND fecha_cuota = v_fecham
	   		   AND empresa = '001';

			UPDATE sd_pagocapit SET monto_moratorio = v_monto,
						status_moratorio = '2'
	 	 	 WHERE num_credito = v_credito
	   	 	   AND fecha_cuota = v_fecham
	   		   AND empresa = '001';
		END IF
	
	END FOREACH

	SELECT NVL(sum(sdo_mora_ordi),0) INTO v_monto
	  FROM sd_detmora
	 WHERE num_credito = v_credito
	   AND empresa = '001';
	 
	UPDATE sd_maesdos SET sdo_moratorio = v_monto
	 WHERE num_credito = v_credito
	   AND empresa = '001';


END FOREACH

END
	RETURN scod_ret;

END PROCEDURE;