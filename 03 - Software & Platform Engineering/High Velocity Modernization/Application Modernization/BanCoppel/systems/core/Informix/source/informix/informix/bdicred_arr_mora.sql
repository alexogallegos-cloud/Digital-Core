CREATE PROCEDURE "informix".arr_mora(e_dia DATE)
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

FOREACH SELECT a.num_credito, a.fecha_cuota,
               ((a.monto_cuota + b.monto_cuota) * tasa_moratorios) / 100
	  INTO v_credito, v_fecha, v_monto  
	  FROM sd_pagocapit a, sd_paginter b, sd_maecred c, sd_definicion d
	 WHERE b.num_credito = a.num_credito
  	   AND b.fecha_cuota = a.fecha_cuota
  	   AND b.empresa     = a.empresa
  	   AND c.num_credito = a.num_credito
  	   AND c.empresa     = a.empresa
  	   AND d.num_producto = c.num_producto
  	   AND d.empresa      = c.empresa
  	   AND a.fecha_cuota + gracia_calc_mora = e_dia
  	   AND a.status_cuota <> '5'
  	   AND a.empresa = '001'

	SELECT NVL(COUNT(*),0) INTO v_count
	  FROM sd_detmora	
	 WHERE num_credito = v_credito
	   AND fecha_cuota = v_fecham
	   AND empresa = '001';
	IF v_count = 0 THEN
		INSERT INTO sd_detmora 
		VALUES('001', v_credito, v_fecha, 'P', 0,0,0,0,0,1,0);
	END IF

	FOREACH SELECT fecha_cuota, sdo_mora_ordi
		  INTO v_fecham, v_montom
		  FROM sd_detmora
		 WHERE num_credito = v_credito
		   AND empresa = '001'
		   AND sdo_mora_ordi > 0
	
		UPDATE sd_detmora SET sdo_mora_ordi = v_monto
	 	 WHERE num_credito = v_credito
	   	   AND fecha_cuota = v_fecham
	   	   AND empresa = '001';


		UPDATE sd_pagocapit SET monto_moratorio = v_monto,
					status_moratorio = '2'
	 	 WHERE num_credito = v_credito
	   	   AND fecha_cuota = v_fecham
	   	   AND empresa = '001';
	
	END FOREACH

	SELECT sum(sdo_mora_ordi) INTO v_monto
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