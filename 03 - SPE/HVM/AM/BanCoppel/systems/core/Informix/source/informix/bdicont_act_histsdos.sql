CREATE PROCEDURE "informix".act_histsdos(pempresa char(3), pfecha_hoy date)
RETURNING char(5);

   DEFINE sql_err INTEGER;

   DEFINE cod_ret           char(3);
   DEFINE hempresa          char(3);
   DEFINE hccmayor          char(10);
   DEFINE hccsub            char(10);
   DEFINE hccsubsub         char(10);
   DEFINE hccssubsub        char(10);
   DEFINE hccsssubsub       char(10);
   DEFINE hsector           char(10);
   DEFINE hciudad           char(3);
   DEFINE hsucursal         char(4);
   DEFINE hmoneda           char(2);
   DEFINE hmes_dia          date;
   DEFINE hcargos_dia       money(18,2);
   DEFINE habonos_dia       money(18,2);
   DEFINE hnro_cargos_dia   integer;
   DEFINE hnro_abonos_dia   integer;
   DEFINE hdias_proyectado  smallint;
   DEFINE hdias_acumulado   smallint;
   DEFINE hsaldo_acumulado  money(18,2);
   DEFINE hsaldo_inicio_dia money(18,2);
   DEFINE hsaldo_fin_de_dia money(18,2);

   DEFINE haempresa          char(3);
   DEFINE haccmayor          char(10);
   DEFINE haccsub            char(10);
   DEFINE haccsubsub         char(10);
   DEFINE haccssubsub        char(10);
   DEFINE haccsssubsub       char(10);
   DEFINE hasector           char(10);
   DEFINE haciudad           char(3);
   DEFINE hasucursal         char(4);
   DEFINE haauxiliar         char(12);
   DEFINE hamoneda           char(2);
   DEFINE hames_dia          date;
   DEFINE hacargos_dia       money(18,2);
   DEFINE haabonos_dia       money(18,2);
   DEFINE hanro_cargos_dia   integer;
   DEFINE hanro_abonos_dia   integer;
   DEFINE hadias_proyectado  smallint;
   DEFINE hadias_acumulado   smallint;
   DEFINE hasaldo_acumulado  money(18,2);
   DEFINE hasaldo_inicio_dia money(18,2);
   DEFINE hasaldo_fin_de_dia money(18,2);

   DEFINE vpri_dia_mes,vult_dia_mes date;
   DEFINE vcontador INTEGER;

	ON EXCEPTION SET sql_err 
        LET cod_ret = sql_err;
        RETURN cod_ret;
     END EXCEPTION;

   LET vcontador = 1;
   LET cod_ret = "159";

   SELECT pri_dia_mes, ult_dia_mes
     INTO vpri_dia_mes, vult_dia_mes
     FROM co_fechas
    WHERE empresa = pempresa;

    IF EXISTS (SELECT codigo_retorno FROM co_cierre_cif 
				                    WHERE cierre_fecha = pfecha_hoy
                                      AND descripcion_cierre="ACT_HISTSDOS"
									  AND codigo_retorno = '000') THEN
   
		LET cod_ret = "999";
		RETURN cod_ret;
	END IF

	IF EXISTS (select tabname from bdicont:systables where tabname='co_histsdodias_tmp') THEN
		DROP TABLE co_histsdodias_tmp;
	END IF

	CREATE TABLE "informix".co_histsdodias_tmp 
	(empresa char(3),
     ccmayor char(4),
     ccsub char(2),
     ccsubsub char(2),
     ccssubsub char(2),
     ccsssubsub char(2),
     sector char(2),
     ciudad char(3),
     sucursal char(4),
     moneda char(2),
     mes_dia date,
     cargos_dia money(14,2),
     abonos_dia money(14,2),
     nro_cargos_dia integer,
     nro_abonos_dia integer,
     dias_proyectado integer,
     dias_acumulado integer,
     saldo_acumulado money(17,2),
     saldo_inicio_dia money(17,2),
     saldo_fin_de_dia money(17,2),
     primary key (empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,ciudad,sucursal,moneda,mes_dia)
     )extent size 628912 next size 62896 lock mode row;

    FOREACH WITH HOLD
         SELECT *
         INTO  hempresa,
               hccmayor,
               hccsub,
               hccsubsub,
               hccssubsub,
               hccsssubsub,
               hsector,
               hciudad,
               hsucursal,
               hmoneda,
               hmes_dia,
               hcargos_dia,
               habonos_dia,
               hnro_cargos_dia,
               hnro_abonos_dia,
               hdias_proyectado,
               hdias_acumulado,
               hsaldo_acumulado,
               hsaldo_inicio_dia,
               hsaldo_fin_de_dia
         FROM co_sdodias
        WHERE empresa = pempresa
          AND mes_dia BETWEEN vpri_dia_mes AND vult_dia_mes

	    IF vcontador=1 THEN
			BEGIN WORK;
	    END IF;

         INSERT INTO
         co_histsdodias_tmp
         VALUES(hempresa,
                hccmayor,
                hccsub,
                hccsubsub,
                hccssubsub,
                hccsssubsub,
                hsector,
                hciudad,
                hsucursal,
                hmoneda,
                hmes_dia,
                hcargos_dia,
                habonos_dia,
                hnro_cargos_dia,
                hnro_abonos_dia,
                hdias_proyectado,
                hdias_acumulado,
                hsaldo_acumulado,
                hsaldo_inicio_dia,
                hsaldo_fin_de_dia);

		IF vcontador >=75000 THEN
			COMMIT WORK;
			LET vcontador=1;
		ELSE
			LET vcontador = vcontador + 1 ;
		END IF;

		CONTINUE FOREACH;
    END FOREACH

	IF vcontador > 1 THEN
        COMMIT WORK;
		LET vcontador=1; 
	END IF;

	CREATE INDEX "informix".idx1_co_histsdodias_tmp ON "informix".co_histsdodias_tmp(mes_dia) USING btree FILLFACTOR 99 ONLINE;
	UPDATE STATISTICS MEDIUM FOR TABLE co_histsdodias_tmp (mes_dia);

-- ***************************************************************************
-- Extrae los saldos diarios de los auxiliares y los graba en el Historico
-- ***************************************************************************
    FOREACH WITH HOLD
      SELECT *
      INTO  hempresa,
            haccmayor,
            haccsub,
            haccsubsub,
            haccssubsub,
            haccsssubsub,
            hasector,
            haciudad,
            hasucursal,
            haauxiliar,
            hamoneda,
            hames_dia,
            hacargos_dia,
            haabonos_dia,
            hanro_cargos_dia,
            hanro_abonos_dia,
            hadias_proyectado,
            hadias_acumulado,
            hasaldo_acumulado,
            hasaldo_inicio_dia,
            hasaldo_fin_de_dia
      FROM co_diasaux
      WHERE empresa = pempresa
        AND mes_dia BETWEEN vpri_dia_mes AND vult_dia_mes

	    IF vcontador=1 THEN
			BEGIN WORK;
	    END IF;

	    INSERT INTO co_histdiasaux
	      VALUES (hempresa,
	              haccmayor,
	              haccsub,
	              haccsubsub,
	              haccssubsub,
	              haccsssubsub,
	              hasector,
	              haciudad,
	              hasucursal,
	              haauxiliar,
	              hamoneda,
	              hames_dia,
	              hacargos_dia,
	              haabonos_dia,
	              hanro_cargos_dia,
	              hanro_abonos_dia,
	              hadias_proyectado,
	              hadias_acumulado,
	              hasaldo_acumulado,
	              hasaldo_inicio_dia,
	              hasaldo_fin_de_dia);

   		IF vcontador >=75000 THEN
			COMMIT WORK;
			LET vcontador=1;
		ELSE
			LET vcontador = vcontador + 1 ;
		END IF;

		CONTINUE FOREACH;
    END FOREACH

	IF vcontador > 1 THEN
        COMMIT WORK;
		LET vcontador=1; 
	END IF;

   LET cod_ret = "000";

RETURN cod_ret;
END PROCEDURE;