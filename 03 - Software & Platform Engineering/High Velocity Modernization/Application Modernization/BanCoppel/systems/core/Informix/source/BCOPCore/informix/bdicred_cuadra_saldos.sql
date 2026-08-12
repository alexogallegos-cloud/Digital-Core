CREATE PROCEDURE "informix".cuadra_saldos()

RETURNING CHAR(5);

DEFINE v_numcred    CHAR(20);
DEFINE v_diferencia MONEY(14,2);
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
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

	FOREACH SELECT a.num_credito, 
		       MIN(sdo_capital) - sum(saldo_cuota - monto_real_pag)
		  INTO v_numcred, v_diferencia
		  FROM sd_maesdos a, sd_pagocapit b
	  	 WHERE a.num_credito = b.num_credito
		   AND b.status_cuota ='1'
		   AND SUBSTR(a.num_credito,10,3) <> '410'
		 GROUP BY 1
		HAVING MIN(sdo_capital) - sum(saldo_cuota - monto_real_pag)<>0

		IF v_diferencia < 0 then
			LET v_diferencia = v_diferencia * -1;
			UPDATE sd_maesdos 
			   SET sdo_capital = sdo_capital + v_diferencia
			 WHERE num_credito = v_numcred
			   AND empresa ='001';
		ELSE
			UPDATE sd_maesdos 
			   SET sdo_capital = sdo_capital - v_diferencia
			 WHERE num_credito = v_numcred
			   AND empresa ='001';
		END IF
	END FOREACH

	FOREACH SELECT a.num_credito, 
		       MIN(monto_vencido) - sum(saldo_cuota - monto_real_pag)
		  INTO v_numcred, v_diferencia
		  FROM sd_maesdos a, sd_pagocapit b
	  	 WHERE a.num_credito = b.num_credito
		   AND b.status_cuota ='7'
		   AND SUBSTR(a.num_credito,10,3) <> '410'
		 GROUP BY 1
		HAVING MIN(monto_vencido) - sum(saldo_cuota-monto_real_pag)<>0

		IF v_diferencia < 0 then
			LET v_diferencia = v_diferencia * -1;
			UPDATE sd_maesdos 
			   SET monto_vencido = monto_vencido + v_diferencia
			 WHERE num_credito = v_numcred
			   AND empresa ='001';
		ELSE
			UPDATE sd_maesdos 
			   SET monto_vencido = monto_vencido - v_diferencia
			 WHERE num_credito = v_numcred
			   AND empresa ='001';
		END IF
	END FOREACH

	FOREACH SELECT a.num_credito, 
		       MIN(mto_venc_trasp) - sum(saldo_cuota - monto_real_pag)
		  INTO v_numcred, v_diferencia
		  FROM sd_maesdos a, sd_pagocapit b
	  	 WHERE a.num_credito = b.num_credito
		   AND b.status_cuota ='2'
		   AND SUBSTR(a.num_credito,10,3) <> '410'
		 GROUP BY 1
		HAVING MIN(mto_venc_trasp) - sum(saldo_cuota-monto_real_pag)<>0

		IF v_diferencia < 0 then
			LET v_diferencia = v_diferencia * -1;
			UPDATE sd_maesdos 
			   SET mto_venc_trasp = mto_venc_trasp + v_diferencia
			 WHERE num_credito = v_numcred
			   AND empresa ='001';
		ELSE
			UPDATE sd_maesdos 
			   SET mto_venc_trasp = mto_venc_trasp - v_diferencia
			 WHERE num_credito = v_numcred
			   AND empresa ='001';
		END IF
	END FOREACH

	FOREACH SELECT num_credito, 
		       sdo_capital + monto_vencido + mto_venc_trasp
		  INTO v_numcred, v_diferencia
		  FROM sd_maesdos
		 WHERE SUBSTR(num_credito,10,3) <> '410'

		UPDATE sd_maesdos set sdo_cap_insoluto = v_diferencia
		 WHERE num_credito = v_numcred
		   AND empresa = '001';

	END FOREACH
END

END PROCEDURE;