CREATE PROCEDURE "informix".saldosretenidos(pActualiza CHAR(1))
RETURNING CHAR(5),CHAR(20),MONEY(14,2),
		  INTEGER,INTEGER,INTEGER,
		  MONEY(14,2),MONEY(14,2),
		  INTEGER,INTEGER,INTEGER,
		  MONEY(14,2),MONEY(14,2),MONEY(14,2),
		  CHAR(16);


	DEFINE cod_red CHAR(5);
	DEFINE v_empresa CHAR(3);

	DEFINE v_cuenta CHAR(20);
	DEFINE v_saldo	MONEY(14,2);

	DEFINE v_count_ret	 INTEGER;
	DEFINE v_count_ret_S INTEGER;
	DEFINE v_count_ret_P INTEGER;

	DEFINE v_sum_monto_ret_P	MONEY(14,2);
	DEFINE v_sum_monto_ret_S	MONEY(14,2);

	DEFINE v_count_0801	INTEGER;
	DEFINE v_count_0830	INTEGER;
	DEFINE v_count_cancel INTEGER;

	DEFINE v_monto_tot_0801 MONEY(14,2);
	DEFINE v_monto_tot_0830 MONEY(14,2);
	DEFINE v_monto_libera MONEY(14,2);
	-----------------------------------------------
	DEFINE v_sucursal CHAR(4);
	DEFINE v_usuario CHAR(8);
	DEFINE v_folio_suc CHAR(16);
	DEFINE v_referencia CHAR(40);
	DEFINE v_num_tarjeta CHAR(16);
	DEFINE v_monto_tot MONEY(14,2);
	-----------------------------------------------
	DEFINE v_2 CHAR(4);
	DEFINE v_3 DATE;
	DEFINE v_4 MONEY(14,2);
	DEFINE v_5 MONEY(14,2);
BEGIN

	LET cod_red = '000';

	FOREACH WITH HOLD SELECT cuenta,sdo_retenido,empresa
		INTO v_cuenta,v_saldo,v_empresa
		FROM bdicheq:sc_maechq

		SELECT COUNT(*),
			SUM(CASE cancelado WHEN 'S' THEN 1 ELSE 0 END ),
			SUM(CASE cancelado WHEN 'P' THEN 1 ELSE 0 END ),
			SUM(CASE cancelado WHEN 'S' THEN monto ELSE 0 END ),
			SUM(CASE cancelado WHEN 'P' THEN monto ELSE 0 END )
		INTO v_count_ret,
			 v_count_ret_S,v_count_ret_P,
			 v_sum_monto_ret_S,v_sum_monto_ret_P
		FROM  bdicheq:sc_docret
	    WHERE empresa = v_empresa
	    AND cuenta = v_cuenta;

		IF NVL(v_saldo,0) <> NVL(v_sum_monto_ret_P,0) THEN
			SELECT
				SUM(CASE transacc WHEN '0801' THEN 1 ELSE 0 END ),
				SUM(CASE transacc WHEN '0830' THEN 1 ELSE 0 END ),
				SUM(CASE transacc WHEN '0801' THEN monto_tot ELSE 0 END ),
				SUM(CASE transacc WHEN '0830' THEN monto_tot ELSE 0 END ),
				SUM(CASE cancelad WHEN 'S' THEN 1 ELSE 0 END )
			INTO v_count_0801,v_count_0830,
				 v_monto_tot_0801,v_monto_tot_0830,
				 v_count_cancel
			FROM  bdicheq:sc_movhis
		    WHERE empresa = v_empresa
		    AND cuenta = v_cuenta
		    AND transacc IN ('0801','0830');

			SELECT SUM(a.monto_tot)
			INTO v_monto_libera
			FROM  bdicheq:sc_movhis a
		    WHERE a.empresa = v_empresa
		    AND a.cuenta = v_cuenta
		    AND a.transacc = '0801'
		    AND a.folio_suc NOT  IN
		    	(SELECT folio_suc FROM bdicheq:sc_movhis b
		    		WHERE b.empresa = a.empresa
		    		AND b.cuenta = a.cuenta
		    		AND b.transacc = '0830'
		    		AND b.folio_suc  = a.folio_suc);

			IF pActualiza = '0' THEN
				RETURN cod_red,v_cuenta,v_saldo,
				       v_count_ret,v_count_ret_S,v_count_ret_P,
				       v_sum_monto_ret_S,v_sum_monto_ret_P,
				       v_count_0801,v_count_0830,v_count_cancel,
				       v_monto_tot_0801,v_monto_tot_0830,
				       v_monto_libera,''
				       WITH RESUME;
			ElIF v_saldo = v_monto_libera
	    		AND (v_count_0801 - v_count_0830) = 1 THEN

		    	SELECT sucursal,usuario,folio_suc,
		    		   referencia,num_tarjeta,monto_tot
				INTO v_sucursal,v_usuario,v_folio_suc,
					   v_referencia,v_num_tarjeta,v_monto_tot
				FROM  bdicheq:sc_movhis a
			    WHERE a.empresa = v_empresa
			    AND a.cuenta = v_cuenta
			    AND a.transacc = '0801'
			    AND a.folio_suc NOT  IN
			    	(SELECT folio_suc FROM bdicheq:sc_movhis b
			    		WHERE b.empresa = a.empresa
			    		AND b.cuenta = a.cuenta
			    		AND b.transacc = '0830'
			    		AND b.folio_suc  = a.folio_suc);

			    IF pActualiza = '2' THEN

			    	UPDATE  bdicheq:sc_docret
				    SET cancelado = 'P'
	    		    WHERE empresa = v_empresa
	    		    AND cuenta = v_cuenta
	    		    AND folio_suc = v_folio_suc;


					EXECUTE PROCEDURE bdicheq:cargo_ref(
								v_empresa,v_sucursal,
								v_usuario,'0830','0830',
								v_folio_suc,v_cuenta,
								'0',v_monto_tot,'01',
								v_referencia,v_num_tarjeta,
								v_usuario)
							INTO cod_red,v_2,v_3,v_4,v_5;


	   			END IF

				RETURN cod_red,				--CODIGO DE RETORNO
					   v_cuenta,			--CUENTA DEL CLIENTE
				       v_saldo,				--SALDO RETENIDO DE MAECHEQ

				       v_count_ret,			--TOTAL DE REGISTROS DOCRET
				       v_count_ret_S,		--TOTAL DE REGISTROS DOCRET LIBERADOS
					   v_count_ret_P,		--TOTAL DE REGISTROS DOCRET PENDIENTES

				       v_sum_monto_ret_S,	--SALDO RETENIDO DE DOCRET LIBERADOS
				       v_sum_monto_ret_P,	--SALDO RETENIDO DE DOCRET PENDIENTES

				       v_count_0801,		--TOTAL DE REGISTROS MOVHIS 0801
				       v_count_0830,		--TOTAL DE REGISTROS MOVHIS 0830
				       v_count_cancel,		--TOTAL DE REGISTROS MOVHIS CANCELADOS

				       v_monto_tot_0801,	--SALDO RETENIDO DE MOVHIS 0801
				       v_monto_tot_0830,	--SALDO RETENIDO DE MOVHIS 0830
				       v_monto_libera,		--SALDO RETENIDO PENDIENTE DE LIBERAR

				       v_folio_suc			--FOLIO SUCURSAL
				       WITH RESUME;

			 END IF
		END IF

	END FOREACH;

END;

END PROCEDURE;