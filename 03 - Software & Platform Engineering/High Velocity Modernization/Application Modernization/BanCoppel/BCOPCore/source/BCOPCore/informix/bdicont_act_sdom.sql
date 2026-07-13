CREATE PROCEDURE "informix".act_sdom(v_empresa char(3))
RETURNING char(5)

   DEFINE sql_err INTEGER;

   DEFINE cod_ret char(5);
   DEFINE vccmayor,vccsub, vccsubsub, vccssubsub, vccsssubsub, vsector char(10);
   DEFINE vmoneda, v_mes char(2);
   DEFINE vciudad char(3);
   DEFINE vsucursal char(4);
   DEFINE lv_saldo_acum, lv_inicio_mes       money (18,2);

   DEFINE vcargos_mes, vabonos_mes money(18,2);
   DEFINE vsaldo_acumulado,vsaldo_inicio_mes, lv_saldo_actual money (18,2);
   DEFINE vnro_cargos_mes, vnro_abonos_mes, vdias_acumulado integer;

   DEFINE lv_dias_acum integer;
   DEFINE vw_fecha_hoy, vfecha_alta,vpri_hab_mes,vult_dia_mes date;
      
   DEFINE vanio_mes char(7);
   DEFINE lv_maxdia, lv_mindia date;
   DEFINE lv_dias integer;
   DEFINE vcontador INTEGER;

	ON EXCEPTION SET sql_err 
        LET cod_ret = sql_err;
        RETURN cod_ret;
     END EXCEPTION;

   LET vanio_mes = " ";
   LET lv_dias=0;

   LET vcontador = 1;
   LET cod_ret = "157";

   SELECT fecha_hoy, pri_hab_mes, ult_dia_mes 
	 INTO vw_fecha_hoy, vpri_hab_mes, vult_dia_mes
   FROM co_fechas
   WHERE empresa = v_empresa;

    IF EXISTS (SELECT codigo_retorno FROM co_cierre_cif 
				                    WHERE cierre_fecha = vw_fecha_hoy
                                      AND descripcion_cierre="ACT_SDOM"
									  AND codigo_retorno = '000') THEN
   
		LET cod_ret = "999";
		RETURN cod_ret;
	END IF

   IF vw_fecha_hoy IS NULL THEN
      LET cod_ret = "123";
      RETURN cod_ret;
   ELSE
      LET v_mes = MONTH(vw_fecha_hoy);
      IF v_mes < "10" THEN
         LET v_mes = "0"||v_mes;
      END IF
      LET vanio_mes = year(vw_fecha_hoy)|| "-" || v_mes;
   END IF

   SELECT {+INDEX(co_sdodias sdodias1)} MAX(mes_dia) INTO lv_maxdia
   FROM co_sdodias
   WHERE empresa = v_empresa
     AND mes_dia between vpri_hab_mes and vult_dia_mes;

   LET lv_dias=DAY(lv_maxdia);

	FOREACH WITH HOLD
		SELECT {+INDEX(co_sdodias sdodias1)}
			   ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, ciudad,
               sucursal, moneda, vw_fecha_hoy, sum(cargos_dia), sum(abonos_dia),
               sum(nro_cargos_dia), sum(nro_abonos_dia),
               lv_dias, 0, 0, 0, empresa
         INTO  vccmayor, vccsub, vccsubsub, vccssubsub, vccsssubsub, vsector,
               vciudad, vsucursal, vmoneda, vfecha_alta, vcargos_mes, vabonos_mes,
               vnro_cargos_mes, vnro_abonos_mes, vdias_acumulado, vsaldo_acumulado,
                vsaldo_inicio_mes, lv_saldo_actual, v_empresa
         FROM co_sdodias
        WHERE empresa = v_empresa
          AND mes_dia BETWEEN vpri_hab_mes AND vult_dia_mes
     GROUP BY 1,2,3,4,5,6,7,8,9,10,15,16,17,18,19

	  IF vcontador=1 THEN
			BEGIN WORK;
	  END IF;

	  INSERT INTO co_sdomes
	  VALUES (v_empresa, vccmayor, vccsub, vccsubsub, vccssubsub, vccsssubsub,
	          vsector, vciudad, vsucursal, vmoneda, vanio_mes, vcargos_mes,
	          vabonos_mes, vnro_cargos_mes, vnro_abonos_mes, 0, vdias_acumulado,
	          vsaldo_acumulado, vsaldo_inicio_mes, lv_saldo_actual);

		IF vcontador >=75000 THEN
			COMMIT WORK;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicont:co_sdomes;
			LET vcontador=1;
		ELSE
			LET vcontador = vcontador + 1 ;
		END IF;

		CONTINUE FOREACH;
	END FOREACH;

	IF vcontador > 1 THEN
        COMMIT WORK;
		LET vcontador=1; 
	END IF;

	UPDATE STATISTICS MEDIUM FOR TABLE bdicont:co_sdomes;

BEGIN WORK;
	FOREACH 
	  SELECT {+INDEX(co_sdodias sdodias1)}
		     ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, ciudad,
	         sucursal, moneda, empresa
	  INTO   vccmayor, vccsub, vccsubsub, vccssubsub, vccsssubsub, vsector,
	         vciudad, vsucursal, vmoneda, v_empresa
        FROM co_sdodias
       WHERE empresa = v_empresa
         AND mes_dia BETWEEN vpri_hab_mes AND vult_dia_mes
    GROUP BY 1,2,3,4,5,6,7,8,9,10

	  SELECT MIN(mes_dia)
	    INTO lv_mindia
	    FROM co_sdodias
	   WHERE empresa = v_empresa
	     AND ccmayor = vccmayor
	     AND ccsub   = vccsub
	     AND ccsubsub = vccsubsub
	     AND ccssubsub = vccssubsub
	     AND ccsssubsub = vccsssubsub
	     AND sector     = vsector
	     AND ciudad     = vciudad
		 AND sucursal   = vsucursal
		 AND moneda     = vmoneda;

	  SELECT saldo_inicio_dia
	    INTO lv_inicio_mes
		FROM co_sdodias
	   WHERE empresa = v_empresa
		 AND ccmayor = vccmayor
		 AND ccsub   = vccsub
		 AND ccsubsub = vccsubsub
		 AND ccssubsub = vccssubsub
		 AND ccsssubsub = vccsssubsub
		 AND sector     = vsector
		 AND ciudad     = vciudad
		 AND sucursal   = vsucursal
		 AND moneda     = vmoneda
		 AND mes_dia    = lv_mindia;

	  UPDATE co_sdomes
	     SET saldo_inicio_mes = lv_inicio_mes
	   WHERE empresa = v_empresa
	     AND ccmayor = vccmayor
		 AND ccsub   = vccsub
		 AND ccsubsub = vccsubsub
		 AND ccssubsub = vccssubsub
		 AND ccsssubsub = vccsssubsub
		 AND sector     = vsector
		 AND ciudad     = vciudad
		 AND sucursal   = vsucursal
		 AND moneda     = vmoneda
		 AND ano_mes    = vanio_mes;

		CONTINUE FOREACH;
	END FOREACH;
COMMIT WORK;

	UPDATE STATISTICS MEDIUM FOR TABLE bdicont:co_sdomes;

BEGIN WORK;
	FOREACH 
	  SELECT {+INDEX(co_sdodias sdodias1)}
			 ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, ciudad,
	         sucursal, moneda, empresa,
	         dias_acumulado, saldo_acumulado, saldo_fin_de_dia
	    INTO vccmayor, vccsub, vccsubsub, vccssubsub, vccsssubsub, vsector,
	         vciudad, vsucursal, vmoneda, v_empresa,
	         lv_dias_acum, lv_saldo_acum, lv_saldo_actual
	  FROM co_sdodias
	  WHERE mes_dia    = lv_maxdia
	    AND empresa    = v_empresa

	  UPDATE co_sdomes
	     SET dias_acumulado   = lv_dias_acum,
	         saldo_acumulado  = lv_saldo_acum,
	         saldo_fin_de_mes = lv_saldo_actual
	   WHERE empresa     = v_empresa
		 AND ccmayor    = vccmayor
		 AND ccsub      = vccsub
		 AND ccsubsub   = vccsubsub
		 AND ccssubsub  = vccssubsub
		 AND ccsssubsub = vccsssubsub
		 AND sector     = vsector
		 AND ciudad     = vciudad
		 AND sucursal   = vsucursal
		 AND moneda     = vmoneda
		 AND ano_mes    = vanio_mes;


	   CONTINUE FOREACH;
	END FOREACH;
COMMIT WORK;

   LET cod_ret = "000";

RETURN cod_ret;
END PROCEDURE;