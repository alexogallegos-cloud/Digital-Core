CREATE PROCEDURE "informix".nivelacion_ccostos(p_empresa char(3),
                                    p_fecha_valida DATE)
  RETURNING CHAR(5);

   DEFINE   sql_err                INTEGER;
   DEFINE   isam_err               INTEGER;
   DEFINE   error_info             CHAR(40);
   DEFINE   cod_ret                char(5);
   DEFINE   v_usuario              char(8);
   DEFINE   v_control_poliza       integer;
   DEFINE   v_fecha_captura        date;
   DEFINE   v_secuencia            integer;
   DEFINE   v_empresa              char(3);
   DEFINE   v_ccmayor              char(10);
   DEFINE   v_ccsub                char(10);
   DEFINE   v_ccsubsub             char(10);
   DEFINE   v_ccssubsub            char(10);
   DEFINE   v_ccsssubsub           char(10);
   DEFINE   v_sector               char(10);
   DEFINE   v_ciudad               char(3);
   DEFINE   v_sucursal             char(4);
   DEFINE   v_nro_auxiliar         char(12);
   DEFINE   v_naturaleza           char(1);
   DEFINE   v_monto                money(18,2);
   DEFINE   v_descripcion_det      char(80);
   DEFINE   v_fecha_valida         date;
   DEFINE   v_moneda               char(2);
   DEFINE   v_valor_cambio         money(12,7);
   DEFINE   v_valor_div_cambio     money(12,7);
   DEFINE   v_mca_aplic            char(1);
   DEFINE   v_poliza_usuario       char(8);
   DEFINE   v_tipo_mov             char(1);
   DEFINE   v_ccosto_orig          char(4);

   DEFINE   v_enl_cc_mayor         char(10);
   DEFINE   v_enl_cc_sub           char(10);
   DEFINE   v_enl_cc_ss            char(10);
   DEFINE   v_enl_cc_sss           char(10);
   DEFINE   v_enl_cc_ssss          char(10);
   DEFINE   v_enl_cc_sector        char(10);
   DEFINE   v_sucursal_nivel       char(4);
   DEFINE   v_poliza_nivel         INTEGER;
   DEFINE   v_secuencia_max        INTEGER;
   DEFINE   v_naturaleza_enlace    CHAR(1);
   DEFINE   suma_cargos            money(18,2);
   DEFINE   suma_abonos            money(18,2);
   DEFINE   v_fecha_cap            date;
   DEFINE   v_fecha_val            date;

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      SET DEBUG FILE TO "Importa.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;

      RETURN cod_ret;
   END EXCEPTION;


   LET cod_ret = "000";

    ----- obtener la cuenta de enlace por centro de costos ----
     SELECT enl_cc_mayor,
            enl_cc_sub,
            enl_cc_ss,
            enl_cc_sss,
            enl_cc_ssss,
            enl_cc_sector
     INTO v_enl_cc_mayor,
          v_enl_cc_sub,
          v_enl_cc_ss,
          v_enl_cc_sss,
          v_enl_cc_ssss,
          v_enl_cc_sector
     FROM co_param
     WHERE empresa = p_empresa;

  LET v_descripcion_det = "MOVIMIENTO DE BALANCEO POR C.C.";
  LET suma_cargos = 0;
  LET suma_abonos = 0;


  FOREACH
     SELECT ciudad,usuario,fecha_captura,control_poliza,moneda,sucursal,ccosto_orig,fecha_valida
     INTO v_ciudad,v_usuario,v_fecha_cap,v_poliza_nivel,v_moneda,v_sucursal_nivel,v_ccosto_orig,v_fecha_val
     FROM co_detpol
     WHERE empresa = p_empresa
     AND fecha_captura = p_fecha_valida
     GROUP BY ciudad,usuario,fecha_captura,control_poliza,moneda,sucursal,ccosto_orig,fecha_valida
     ORDER BY ciudad,usuario,fecha_captura,control_poliza,moneda,sucursal,ccosto_orig,fecha_valida

          SELECT nvl(SUM(monto),0) INTO suma_cargos
          FROM co_detpol
          WHERE empresa = p_empresa
           --AND control_poliza = v_poliza_nivel
           AND fecha_captura = p_fecha_valida
           AND control_poliza = v_poliza_nivel
           AND sucursal = v_sucursal_nivel
           AND naturaleza = "C";

          SELECT nvl(SUM(monto),0) INTO suma_abonos
          FROM co_detpol
          WHERE empresa = p_empresa
           --AND control_poliza = v_poliza_nivel
           AND fecha_captura = p_fecha_valida
           AND control_poliza = v_poliza_nivel
           AND sucursal = v_sucursal_nivel
           AND naturaleza = "D";

           {SELECT *
           INTO v_usuario,
                v_control_poliza,
                v_fecha_captura,
                v_secuencia,
                v_empresa,
                v_ccmayor,
                v_ccsub,
                v_ccsubsub,
                v_ccssubsub,
                v_ccsssubsub,
                v_sector,
                v_ciudad,
                v_sucursal,
                v_nro_auxiliar,
                v_naturaleza,
                v_monto,
                v_descripcion_det,
                v_fecha_valida,
                v_moneda,
                v_valor_cambio,
                v_valor_div_cambio,
                v_mca_aplic,
                v_poliza_usuario,
                v_tipo_mov,
                v_ccosto_orig
           FROM co_detpol
           WHERE control_poliza =  v_poliza_nivel AND
                 fecha_valida   = p_fecha_valida  AND
                 sucursal       = v_sucursal_nivel AND
                 fecha_captura  = v_fecha_cap AND
                 empresa        = p_empresa AND
                 usuario        = v_usuario;}

       IF suma_abonos > suma_cargos THEN
           LET v_naturaleza_enlace = "C";
           LET v_monto = suma_abonos - suma_cargos;
           SELECT MAX(secuencia) INTO v_secuencia_max
           FROM co_detpol
           WHERE control_poliza =  v_poliza_nivel AND
                 --fecha_valida = p_fecha_valida  AND
                 --sucursal     = v_sucursal_nivel AND
                 fecha_captura  = v_fecha_cap AND
                 empresa        = p_empresa AND
                 usuario        = v_usuario;
           LET v_secuencia_max = v_secuencia_max + 1;
           INSERT INTO co_detpol
           VALUES (v_usuario,
                   v_poliza_nivel,
                   v_fecha_cap,
                   v_secuencia_max,
                   p_empresa,
                   v_enl_cc_mayor,
                   v_enl_cc_sub,
                   v_enl_cc_ss,
                   v_enl_cc_sss,
                   v_enl_cc_ssss,
                   v_enl_cc_sector,
                   v_ciudad,
                   v_sucursal_nivel,
                   "",
                   v_naturaleza_enlace,
                   v_monto,
                   v_descripcion_det,
                   v_fecha_val,
                   v_moneda,
                   0,
                   0,
                   "",
                   v_usuario,
                   "",
                   v_ccosto_orig);
       ELSE
         IF suma_abonos < suma_cargos THEN
           LET v_naturaleza_enlace = "D";
           LET v_monto = suma_cargos - suma_abonos;
           SELECT MAX(secuencia) INTO v_secuencia_max
           FROM co_detpol
           WHERE control_poliza =  v_poliza_nivel AND
                 --fecha_valida = p_fecha_valida  AND
                 --sucursal     = v_sucursal_nivel AND
                 fecha_captura  = v_fecha_cap AND
                 empresa        = p_empresa AND
                 usuario        = v_usuario;
           LET v_secuencia_max = v_secuencia_max + 1;
           {INSERT INTO co_detpol
           VALUES (v_usuario,
                   v_poliza_nivel,
                   v_fecha_captura,
                   v_secuencia_max,
                   v_empresa,
                   v_enl_cc_mayor,
                   v_enl_cc_sub,
                   v_enl_cc_ss,
                   v_enl_cc_sss,
                   v_enl_cc_ssss,
                   v_enl_cc_sector,
                   v_ciudad,
                   v_sucursal,
                   v_nro_auxiliar,
                   v_naturaleza_enlace,
                   v_monto,
                   v_descripcion_det,
                   v_fecha_valida,
                   v_moneda,
                   v_valor_cambio,
                   v_valor_div_cambio,
                   v_mca_aplic,
                   v_poliza_usuario,
                   v_tipo_mov,
                   v_ccosto_orig);}
           INSERT INTO co_detpol
           VALUES (v_usuario,
                   v_poliza_nivel,
                   v_fecha_cap,
                   v_secuencia_max,
                   p_empresa,
                   v_enl_cc_mayor,
                   v_enl_cc_sub,
                   v_enl_cc_ss,
                   v_enl_cc_sss,
                   v_enl_cc_ssss,
                   v_enl_cc_sector,
                   v_ciudad,
                   v_sucursal_nivel,
                   "",
                   v_naturaleza_enlace,
                   v_monto,
                   v_descripcion_det,
                   v_fecha_val,
                   v_moneda,
                   0,
                   0,
                   "",
                   v_usuario,
                   v_naturaleza_enlace,
                   v_ccosto_orig);
         END IF
       END IF
 END FOREACH;

  RETURN  cod_ret;

END PROCEDURE;