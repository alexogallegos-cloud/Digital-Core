CREATE PROCEDURE "informix".nivel_escrow()
RETURNING CHAR(5);


DEFINE v_fecha DATE;
DEFINE v_credito CHAR(20);


	FOREACH SELECT num_credito, fecha_cuota
		  INTO v_credito, v_fecha
		  FROM sd_pagocapit 
		 WHERE SUBSTR(num_credito,10,3) IN ("420",
						    "414",
					            "409",
  						    "411",
						    "414",
						    "412",
						    "429",
						    "423",
						    "430")
		  AND status_cuota ="5"
		  AND YEAR(fecha_cuota) ="2004"



		UPDATE sd_detcomi SET estado_com ="A", fecha_alta = v_fecha,
				      monto_pag = monto_com
	 	 WHERE num_credito = v_credito
		   AND fecha_alta  = v_fecha;
		

	END FOREACH



END PROCEDURE
;