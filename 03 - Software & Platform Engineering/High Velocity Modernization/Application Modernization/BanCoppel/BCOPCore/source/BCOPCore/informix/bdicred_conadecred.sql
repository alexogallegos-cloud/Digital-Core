CREATE PROCEDURE "informix".conadecred(o_empresa	CHAR(3),
			    o_numcred	CHAR(20))
RETURNING CHAR(5), SMALLINT, MONEY(14,2),MONEY(14,2),MONEY(14,2),MONEY(14,2),
	  MONEY(14,2),MONEY(14,2),MONEY(14,2),MONEY(14,2),MONEY(14,2),
	  MONEY(14,2),MONEY(14,2),MONEY(14,2),MONEY(14,2),CHAR(2);


-- **************************************************************************
-- *           			DEFINICION DE VARIABLES                     *
-- **************************************************************************

DEFINE v_codret		CHAR(5);
DEFINE sql_err		INTEGER;
DEFINE x_nrocuotas	SMALLINT;
DEFINE x_capvig		MONEY(14,2);
DEFINE x_intvig		MONEY(14,2);
DEFINE x_comvig		MONEY(14,2);
DEFINE x_segvig		MONEY(14,2);
DEFINE x_totvig		MONEY(14,2);
DEFINE x_capven		MONEY(14,2);
DEFINE x_intven		MONEY(14,2);
DEFINE x_segven		MONEY(14,2);
DEFINE x_morven		MONEY(14,2);
DEFINE x_totven		MONEY(14,2);
DEFINE x_adedia		MONEY(14,2);
DEFINE x_mtooto		MONEY(14,2);
DEFINE x_adetot		MONEY(14,2);
DEFINE x_status		CHAR(2);
DEFINE v_montominimo	MONEY(14,2);
DEFINE v_fechavig	DATE;
DEFINE v_intdia		MONEY(14,2);
DEFINE v_partd          CHAR(4);
DEFINE v_tpcred         CHAR(2);
DEFINE v_diasc          SMALLINT;
define v_fecha	date;
-- **************************************************************************
-- *           			ASIGNACION DE VARIABLES                     *
-- **************************************************************************
LET v_codret	="00000";
LET sql_err	=0;
LET x_nrocuotas	=0;
LET x_capvig	=0;
LET x_intvig	=0;
LET x_comvig	=0;
LET x_segvig	=0;
LET x_totvig	=0;
LET x_capven	=0;
LET x_intven	=0;
LET x_segven	=0;
LET x_morven	=0;
LET x_totven	=0;
LET x_adedia	=0;
LET x_mtooto	=0;
LET x_adetot	=0;
LET x_status    ="XX";
-- **************************************************************************
-- *           			CONTROL DE ERRORES                          *
-- **************************************************************************

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET v_codret = sql_err;
	 RETURN v_codret, x_nrocuotas, x_capvig,x_intvig, x_comvig,
	        x_segvig, x_totvig, x_capven, x_intven,x_segven,
	        x_morven, x_totven, x_adedia, x_mtooto, x_adetot, x_status;
      end if;
   END EXCEPTION;



select fecha_hoy
into v_fecha
from sd_fechas
where empresa = o_empresa;
-- **************************************************************************
-- *           			PROGRAMA PRINCIPAL                          *
-- **************************************************************************

	SELECT sdo_cap_insoluto, monto_vencido + mto_venc_trasp, 
	       sdo_exig_int, monto_otorgado, sdo_moratorio, sdo_capital,
               maneja_linea, sdo_exig_int, monto_financiado, status_cred,
	       cod_tipcred, sdo_no_exig
	  INTO x_adetot, x_capven, x_intven, x_mtooto, x_morven, x_capvig,
               v_partd, x_intvig, v_montominimo, x_status, v_tpcred, x_intvig
	  FROM sd_maesdos a, sd_maecred b, sd_definicion c
	 WHERE a.num_credito = o_numcred
	   AND a.empresa = o_empresa
	   AND b.num_credito = a.num_credito
	   AND b.empresa     = a.empresa
	   AND c.num_producto = b.num_producto
	   AND c.empresa = b.empresa;
	IF x_adetot IS NULL THEN
		LET v_codret ="100";
		RETURN v_codret, x_nrocuotas, x_capvig,x_intvig, x_comvig,
		       x_segvig, x_totvig, x_capven, x_intven,x_segven,
	               x_morven, x_totven, x_adedia, x_mtooto, x_adetot, 
		       x_status;
	END IF

	IF v_partd = "N" THEN

		-- DETERMINA CUOTAS ADEUDADAS
		SELECT COUNT(*) INTO x_nrocuotas
		  FROM sd_pagocapit
		 WHERE num_credito = o_numcred
		   AND empresa = o_empresa
		   AND status_cuota IN ("2","7");
	
		-- DETERMINA INTERES AL DIA
        	EXECUTE PROCEDURE calc_intdia(o_numcred)
                   INTO v_codret, v_intdia, v_diasc;

		-- Por si son a favor del cliente
		IF v_intdia < 0 THEN
			LET v_intdia = 0;
		END IF	
	
		-- Determina Fecha Cuota Vigente
		SELECT NVL(MIN(fecha_cuota),"01/01/1800") INTO v_fechavig 
		  FROM sd_paginter
		 WHERE fecha_cuota >= v_fecha
		   AND num_credito = o_numcred
		   AND sd_paginter.empresa = o_empresa;
	
		-- Determina lo Vigente
		IF v_fechavig <> "01/01/1800" THEN
			LET x_nrocuotas = x_nrocuotas + 1;
			SELECT a.monto_cuota - a.monto_real_pag
			  INTO x_capvig
			  FROM sd_pagocapit a
			 WHERE a.num_credito = o_numcred
			   AND a.empresa     = o_empresa
			   AND a.fecha_cuota = v_fechavig;
	
			SELECT b.monto_cuota - b.monto_real_pag
			  INTO x_intvig
			  FROM sd_paginter b
			 WHERE b.num_credito = o_numcred
			   AND b.empresa     = o_empresa
			   AND b.fecha_cuota = v_fechavig;

			SELECT NVL(SUM(monto_com - monto_pag),0)
			  INTO x_segvig
			  FROM sd_detcomi a, sd_tpcomis b
			 WHERE a.num_credito = o_numcred
			   AND a.empresa = o_empresa
			   AND a.fecha_alta = v_fechavig
			   AND b.empresa = a.empresa
			   AND b.cod_comis = a.cod_comis
			   AND comi_o_seg = "2";


                        SELECT NVL(SUM(monto_com - monto_pag),0)
                          INTO x_comvig
                          FROM sd_detcomi a, sd_tpcomis b
                         WHERE a.num_credito = o_numcred
                           AND a.empresa = o_empresa
                           AND a.fecha_alta <= v_fechavig
			   AND b.empresa = a.empresa
                           AND b.cod_comis = a.cod_comis
                           AND comi_o_seg = "1";
	
			-- Total Vigente
			LET x_totvig =x_capvig + x_intvig + x_comvig + x_segvig;

                        SELECT NVL(SUM(monto_com - monto_pag),0)
                          INTO x_segven
                          FROM sd_detcomi a, sd_tpcomis b
                         WHERE a.num_credito = o_numcred
                           AND a.empresa = o_empresa
                           AND a.fecha_alta < v_fechavig
			   AND b.empresa = a.empresa
                           AND b.cod_comis = a.cod_comis
                           AND comi_o_seg = "2";
	
		ELSE

			SELECT NVL(SUM(monto_com - monto_pag),0)
			  INTO x_segven
			  FROM sd_detcomi
			 WHERE num_credito = o_numcred
			   AND empresa = o_empresa
			   AND estado_com ="P";
		END IF

		-- Total Vencido
		LET x_totven = x_capven + x_intven + x_segven + x_morven;
		-- Adeudo al Dia
		LET x_adedia = x_totven + x_totvig;
		-- Adeudo Total para Liquidar
		LET x_adetot = x_adetot + x_intven + x_segven + v_intdia +
			       x_morven + x_comvig + x_segvig;
	ELSE
		IF v_montominimo = 0 THEN
			LET x_totvig = x_capvig + x_intvig;
		ELSE
			LET x_capvig = v_montominimo;
			--LET x_intvig = 0;
			LET x_totvig = v_montominimo;
		END IF

		-- Total Vencido
		LET x_totven = x_capven + x_intven + x_segven + x_morven;
		-- Adeudo al Dia
		LET x_adedia = x_totven + x_totvig;
		-- Adeudo Total para Liquidar
		LET x_adetot = x_adetot + x_intven + x_segven + x_morven + 
			       x_intvig;

	END IF
		

END

	RETURN v_codret, x_nrocuotas, x_capvig,x_intvig, x_comvig,
	       x_segvig, x_totvig, x_capven, x_intven,x_segven,
	       x_morven, x_totven, x_adedia, x_mtooto, x_adetot, x_status;

END PROCEDURE;