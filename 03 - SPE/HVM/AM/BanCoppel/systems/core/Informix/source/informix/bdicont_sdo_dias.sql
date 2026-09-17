CREATE PROCEDURE "informix".sdo_dias(pempresa char(3))
RETURNING char(5);

   DEFINE sql_err INTEGER;

   DEFINE cod_ret             char(5);
   DEFINE cant_dias, i, num_dia, v_cero, cont_otro_mes integer;
   DEFINE vmes_dia date;
   DEFINE lv_renglon  integer;
   DEFINE fecha_aux, v_fecha_fin_mes date;
   DEFINE sql_stmt char(500);
   DEFINE v_sdo_fin_mes       money(18,2);
   DEFINE sempresa            char(3);
   DEFINE sccmayor            char(10);
   DEFINE sccsub              char(10);
   DEFINE sccsubsub           char(10);
   DEFINE sccssubsub          char(10);
   DEFINE sccsssubsub         char(10);
   DEFINE ssector             char(10);
   DEFINE sciudad             char(3);
   DEFINE ssucursal           char(4);
   DEFINE smoneda             char(2);
   DEFINE smes_dia            date;
   DEFINE scargos_dia         money(18,2);
   DEFINE sabonos_dia         money(18,2);
   DEFINE snro_cargos_dia     integer;
   DEFINE snro_abonos_dia     integer;
   DEFINE sdias_proyectado    smallint;
   DEFINE sdias_acumulado     smallint;
   DEFINE ssaldo_acumulado    money(18,2);
   DEFINE ssaldo_inicio_dia   money(18,2);
   DEFINE ssaldo_fin_de_dia   money(18,2);
   DEFINE pfecha_ant          date;
   DEFINE pfecha_hoy          date;
   DEFINE pprox_fecha         date;

   ON EXCEPTION SET sql_err 
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;

   LET cod_ret  = "154";

   SELECT fecha_ant ,fecha_hoy ,prox_fecha
   INTO   pfecha_ant,pfecha_hoy,pprox_fecha
   FROM   co_fechas
   WHERE  empresa = pempresa;

   IF EXISTS (SELECT {+INDEX(co_cierre_cif idx_co_cierre_cif)} codigo_retorno FROM co_cierre_cif 
	    		                    WHERE cierre_fecha = pfecha_hoy
                                      AND descripcion_cierre="SDO_DIAS"
									  AND codigo_retorno = '000') THEN
   
		LET cod_ret = "999";
		RETURN cod_ret;
	END IF

   LET cant_dias = pprox_fecha - pfecha_hoy;
   LET cant_dias = cant_dias + 1;
   LET v_cero = 0;
   LET cont_otro_mes = 1;

   FOREACH
     SELECT {+INDEX(co_sdodias sdodias1)} *
     INTO sempresa,
          sccmayor,
          sccsub,
          sccsubsub,
          sccssubsub,
          sccsssubsub,
          ssector,
          sciudad,
          ssucursal,
          smoneda,
          smes_dia,
          scargos_dia,
          sabonos_dia,
          snro_cargos_dia,
          snro_abonos_dia,
          sdias_proyectado,
          sdias_acumulado,
          ssaldo_acumulado,
          ssaldo_inicio_dia,
          ssaldo_fin_de_dia
     FROM co_sdodias
     WHERE empresa = pempresa
     AND mes_dia = pfecha_hoy

     LET fecha_aux = pfecha_hoy;
     LET vmes_dia  = fecha_aux;
     LET cont_otro_mes = 1;
     FOR i = 1 to cant_dias
       LET num_dia = day(vmes_dia);
       IF i > 1 THEN
          LET ssaldo_acumulado = ssaldo_acumulado +
                                           ssaldo_fin_de_dia;
       END IF
       IF month(vmes_dia) != month(pfecha_hoy) THEN
          IF cont_otro_mes = 1 THEN
             LET v_fecha_fin_mes  = pfecha_ant;
             LET v_sdo_fin_mes    = ssaldo_acumulado;
             LET ssaldo_acumulado = ssaldo_fin_de_dia;
             LET cont_otro_mes    = cont_otro_mes + 1;
          END IF
       else
             LET v_fecha_fin_mes  = pfecha_hoy;
       END IF
       IF vmes_dia != pfecha_hoy THEN
          LET ssaldo_inicio_dia = ssaldo_fin_de_dia;
          LET scargos_dia       = 0;
          LET sabonos_dia       = 0;
          LET snro_cargos_dia   = 0;
          LET snro_abonos_dia   = 0;

          INSERT INTO co_sdodias
          VALUES (sempresa,
                  sccmayor,
                  sccsub,
                  sccsubsub,
                  sccssubsub,
                  sccsssubsub,
                  ssector,
                  sciudad,
                  ssucursal,
                  smoneda,
                  vmes_dia,
                  scargos_dia,
                  sabonos_dia,
                  snro_cargos_dia,
                  snro_abonos_dia,
                  v_cero,
                  num_dia,
                  ssaldo_acumulado,
                  ssaldo_inicio_dia,
                  ssaldo_fin_de_dia);
       END IF

       LET fecha_aux = fecha_aux + 1 units day;
       LET vmes_dia  = fecha_aux;
     END FOR
     LET fecha_aux = fecha_aux - 1 units day;
     LET vmes_dia  = fecha_aux;

   END FOREACH

   LET cod_ret  = "000";

RETURN cod_ret;
END PROCEDURE;