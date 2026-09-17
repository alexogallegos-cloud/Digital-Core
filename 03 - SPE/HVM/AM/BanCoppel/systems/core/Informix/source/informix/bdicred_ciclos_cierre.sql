CREATE PROCEDURE "informix".ciclos_cierre()
       RETURNING CHAR(5);

   DEFINE GLOBAL g_num_credito        CHAR(20)  DEFAULT " ";
   DEFINE GLOBAL g_fecha_apertu       DATE      DEFAULT " ";
   DEFINE GLOBAL g_fecha_vencim       DATE      DEFAULT " ";

   DEFINE GLOBAL g_valor14            CHAR(50)  DEFAULT " ";
   --Dia inclusive para el calculode los int.

   DEFINE GLOBAL g_fecha_hoy          DATE      DEFAULT " ";
   DEFINE GLOBAL g_fecha_ant          DATE      DEFAULT " ";
   DEFINE GLOBAL g_prox_fecha         DATE      DEFAULT " ";
   DEFINE GLOBAL g_pri_dia_mes        DATE      DEFAULT " ";
   DEFINE GLOBAL g_pri_hab_mes        DATE      DEFAULT " ";
   DEFINE GLOBAL g_ult_dia_mes        DATE      DEFAULT " ";
   DEFINE GLOBAL g_ult_hab_mes        DATE      DEFAULT " ";
   DEFINE GLOBAL g_dias               SMALLINT  DEFAULT 0;
   DEFINE GLOBAL g_empresa            CHAR(3)   DEFAULT " ";

   DEFINE v_codret                    CHAR(5);
   DEFINE v_fecha_prox_rev            DATE;
   DEFINE vi_fecha_cuota              DATE;
   DEFINE vc_fecha_cuota              DATE;
   DEFINE v_mes_hoy                   SMALLINT;
   DEFINE v_prox_mes                  SMALLINT;
   DEFINE v_ciclos                    SMALLINT;
   DEFINE v_pri_dia_mes               DATE;
   DEFINE v_fecha_final               DATE;
   DEFINE v_fecha_ciclos              DATE;
   DEFINE v_contador                  SMALLINT;
   DEFINE v_dias_ciclo                SMALLINT;
   DEFINE v_dia_ext                   SMALLINT;

   DEFINE sql_err                     SMALLINT;
   DEFINE isam_err                    SMALLINT;
   DEFINE error_info                  CHAR(40);

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET v_codret = sql_err;
      SET DEBUG FILE TO "Ciclos_Cierre.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      RETURN v_codret;
   END EXCEPTION;

   LET v_codret         = "000";
   LET v_fecha_prox_rev = NULL;
   LET vi_fecha_cuota   = NULL;
   LET vc_fecha_cuota   = NULL;
   LET v_mes_hoy        = 0;
   LET v_prox_mes       = 0;
   LET v_ciclos         = 0;
   LET v_pri_dia_mes    = NULL;
   LET v_fecha_final    = NULL;
   LET v_fecha_ciclos   = NULL;
   LET v_ciclos         = 0;
   LET v_contador       = 0;
   LET v_dias_ciclo     = 0;
   LET v_dia_ext        = 0;


  

   IF g_dias = 1 THEN
      LET v_ciclos =  v_ciclos + 1;
      INSERT INTO sd_cicloscie
      VALUES (g_empresa,g_num_credito,v_ciclos, g_fecha_hoy, "IN",0,0);

      -- VALIDA SI HAY CORTE DE FIN E INICIO DE MES EN EL RANGO DE FECHAS
      LET v_mes_hoy  = MONTH(g_fecha_hoy);
      LET v_prox_mes = MONTH(g_prox_fecha);

      IF v_mes_hoy <> v_prox_mes THEN
         LET v_ciclos =  v_ciclos + 1;
         INSERT INTO sd_cicloscie
         VALUES (g_empresa,g_num_credito,v_ciclos, g_ult_dia_mes, "FM",0,0);


         CALL validames (g_pri_dia_mes,1)
         RETURNING v_pri_dia_mes;

         LET v_ciclos =  v_ciclos + 1;
         INSERT INTO sd_cicloscie
         VALUES (g_empresa,g_num_credito,v_ciclos, v_pri_dia_mes, "IM",0,0);
      END IF;

   ELSE
      LET v_ciclos =  v_ciclos + 1;
      INSERT INTO sd_cicloscie
      VALUES (g_empresa,g_num_credito,v_ciclos, g_fecha_hoy, "IN",0,0);

      FOREACH
      -- VERIFICA SI HAY REVISION DE TASA EN EL RANGO DE FECHAS
      SELECT fecha_prox_rev INTO v_fecha_prox_rev
      FROM sd_revtasa
      WHERE num_credito = g_num_credito AND
            empresa     = g_empresa     AND
            fecha_prox_rev BETWEEN g_fecha_hoy AND g_prox_fecha - 1 UNITS DAY

      IF v_fecha_prox_rev IS NOT NULL OR v_fecha_prox_rev != "" THEN
         LET v_ciclos =  v_ciclos + 1;
         INSERT INTO sd_cicloscie
         VALUES (g_empresa,g_num_credito,v_ciclos, v_fecha_prox_rev, "RT",0,0);
      END IF;
      END FOREACH;

      FOREACH
      -- VERIFICA SI HAY TRASPASO DE INTERES EN EL RANGO DE FECHAS
      SELECT fecha_cuota INTO vi_fecha_cuota
      FROM sD_paginter
      WHERE num_credito = g_num_credito AND
            empresa     = g_empresa     AND
            fecha_cuota BETWEEN g_fecha_hoy AND g_prox_fecha - 1 UNITS DAY
             AND status_cuota = "1"

      IF vi_fecha_cuota IS NOT NULL OR vi_fecha_cuota != "" THEN
         LET v_ciclos =  v_ciclos + 1;
         INSERT INTO sd_cicloscie
         VALUES (g_empresa,g_num_credito,v_ciclos, vi_fecha_cuota, "TI",0,0);
      END IF;
      END FOREACH;

      FOREACH
      -- VERIFICA SI HAY TRASPASO DE CAPITAL EN EL RANGO DE FECHAS
      SELECT fecha_cuota INTO vc_fecha_cuota
      FROM sd_pagocapit
      WHERE num_credito = g_num_credito AND
            empresa     = g_empresa     AND
            fecha_cuota BETWEEN g_fecha_hoy AND g_prox_fecha - 1 UNITS DAY
            AND status_cuota = "1"

      IF vc_fecha_cuota IS NOT NULL OR vc_fecha_cuota != "" THEN
         LET v_ciclos =  v_ciclos + 1;
         INSERT INTO sd_cicloscie
         VALUES (g_empresa,g_num_credito,v_ciclos, vc_fecha_cuota, "TC",0,0);
      END IF;
      END FOREACH;


      -- VALIDA SI HAY CORTE DE FIN E INICIO DE MES EN EL RANGO DE FECHAS
      LET v_mes_hoy  = MONTH(g_fecha_hoy);
      LET v_prox_mes = MONTH(g_prox_fecha);

      IF v_mes_hoy <> v_prox_mes THEN
         LET v_ciclos =  v_ciclos + 1;
         INSERT INTO sd_cicloscie
         VALUES (g_empresa,g_num_credito,v_ciclos, g_ult_dia_mes, "FM",0,0);


         CALL validames (g_pri_dia_mes,1)
         RETURNING v_pri_dia_mes;

         LET v_ciclos =  v_ciclos + 1;
         INSERT INTO sd_cicloscie
         VALUES (g_empresa,g_num_credito,v_ciclos, v_pri_dia_mes, "IM",0,0);
      END IF;


   END IF;

   LET v_ciclos =  v_ciclos + 1;
   INSERT INTO sd_cicloscie
   VALUES (g_empresa,g_num_credito,v_ciclos, g_prox_fecha, "FI",0,0);


   LET v_fecha_final    = NULL;
   LET v_fecha_ciclos   = NULL;
   LET v_ciclos         = 0;
   LET v_contador       = 0;
   LET v_dias_ciclo     = 0;

   FOREACH
      SELECT fecha_ciclos, ciclos INTO v_fecha_ciclos, v_ciclos
      FROM sd_cicloscie
      WHERE num_credito = g_num_credito
      AND   empresa     = g_empresa
      ORDER BY fecha_ciclos DESC

      LET v_contador = v_contador + 1;

      IF v_contador = 1 THEN
         LET v_fecha_final = v_fecha_ciclos;
      END IF;

      LET v_dias_ciclo = 0;
      LET v_dias_ciclo = v_fecha_final - v_fecha_ciclos;

      LET v_dia_ext        = 0;
      CALL diainclu(v_fecha_ciclos)
      RETURNING v_codret, v_dia_ext;

      UPDATE sd_cicloscie
      SET dias        = v_dias_ciclo,
          dia_extremo = v_dia_ext
      WHERE num_credito = g_num_credito AND
         empresa     = g_empresa     AND
            ciclos = v_ciclos AND
            fecha_ciclos = v_fecha_ciclos;

      LET v_fecha_final = v_fecha_ciclos;


   END FOREACH;

   RETURN v_codret;

END PROCEDURE
DOCUMENT
"Funcion que cuenta los dias entre el dma de hoy y el siguiente dia habil",
"para calculo de intereses, reviusion de tasa, etc. del cierre de rec. propios",
"AUTOR : Jose Cruz Narvaez",
"FECHA : 2/Mayo/2001",
"Ver.  : 1.0",
"BD.   : bdicred",
"Mod.  : ";

CREATE PROCEDURE "informix".diainclu(p_fecha_ciclos  DATE)
   RETURNING CHAR(5), SMALLINT;

   DEFINE GLOBAL g_fecha_apertu       DATE           DEFAULT " ";
   DEFINE GLOBAL g_fecha_vencim       DATE           DEFAULT " ";

   DEFINE GLOBAL g_valor14            CHAR(50)       DEFAULT " ";
   --Dia inclusive para el calculode los int.

   DEFINE v_dias_ext                  SMALLINT;
   DEFINE v_codret                    CHAR(5);
  
 
   LET v_dias_ext       = 0;
   LET v_codret         = "000";

   -- VERIFICA COMO SE CONSIDERAN LOS DIAS EXTREMOS
   IF g_valor14 = "1"  THEN      -- 1 = fecha de apertura si calcula
                                 -- y fecha de vencimiento no calcula
      IF g_fecha_vencim = p_fecha_ciclos then
         LET v_dias_ext = 1;
      END IF
   ELIF g_valor14 = "2"  THEN    -- 2 = fecha de apertura no calcula
                                 -- y fecha de vencimiento si calcula
      IF g_fecha_apertu = p_fecha_ciclos THEN
         LET v_dias_ext = 1;
      END IF
   ELIF g_valor14 =  "3"  THEN   -- 3 = fecha de apertura si calcula y 
                                 -- fecha de vencimiento si calcula
      LET v_dias_ext = 0;
   END IF

   RETURN v_codret, v_dias_ext;

END PROCEDURE
DOCUMENT
"Funcion que verifica los dias que se incluyen en el calculo de intereses",
"AUTOR : Jose Cruz Narvaez",
"FECHA : 2/Mayo/2001",
"Ver.  : 1.0",
"BD    : bdicred",
"Mod.  : ";

CREATE PROCEDURE "informix".linea_nodisp(p_fecha_proceso DATE,
                              p_dias          SMALLINT)
       RETURNING CHAR(5), CHAR(20);


   DEFINE GLOBAL g_num_credito        CHAR(20)       DEFAULT " ";
   DEFINE GLOBAL g_num_producto       CHAR(4)        DEFAULT " ";
   DEFINE GLOBAL g_numcte             CHAR(20)       DEFAULT " ";
   DEFINE GLOBAL g_sdo_cap_insoluto   MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_num_linea          CHAR(20)       DEFAULT " ";
   DEFINE GLOBAL g_empresa            CHAR(3)        DEFAULT " ";
   DEFINE GLOBAL g_mensaje            CHAR(3)       DEFAULT " ";

   DEFINE GLOBAL gl_num_linea         char(20)       DEFAULT " ";
   DEFINE GLOBAL gl_numcte            char(20)       DEFAULT " ";
   DEFINE GLOBAL gl_num_gpo           char(20)       DEFAULT " ";
   DEFINE GLOBAL gl_producto          char(4)        DEFAULT " ";
   DEFINE GLOBAL gl_tp_linea          char(1)        DEFAULT " ";
   DEFINE GLOBAL gl_linea_prod        money(14,2)    DEFAULT 0;
   DEFINE GLOBAL gl_linea_util        money(14,2)    DEFAULT 0;
   DEFINE GLOBAL gl_fec_cancelac      date           DEFAULT " ";
   DEFINE GLOBAL gl_fec_susp          date           DEFAULT " ";
   DEFINE GLOBAL gl_comentarios       char(255)      DEFAULT " ";
   DEFINE GLOBAL gl_con_colateral     char(1)        DEFAULT " ";
   DEFINE GLOBAL gl_linea_colateral   money(14,2)    DEFAULT 0;

   DEFINE GLOBAL g_valor36            CHAR(50)       DEFAULT " ";
   --codigo para la comision por no disponer de linea.

   DEFINE v_monto                     MONEY(14,2);
   DEFINE v_monto_tot                 MONEY(14,2);
   DEFINE v_codret                    CHAR(5);

   DEFINE cxc_num_credito             CHAR(20);
   DEFINE cxc_cod_comis               CHAR(4);
   DEFINE cxc_factor                  DECIMAL(9,6);
   DEFINE cxc_monto                   MONEY(14,2);

   DEFINE v_folio_suc                 CHAR(16);
   DEFINE v_usuario                   CHAR(8);
   DEFINE v_hora                      DATETIME HOUR TO FRACTION(3);
   DEFINE v_hora_c1                   CHAR(12);
   DEFINE v_hora_c2                   CHAR(8);
   DEFINE base_calculo                MONEY(14,2);

   DEFINE sql_err                     SMALLINT;
   DEFINE isam_err                    SMALLINT;
   DEFINE error_info                  CHAR(40);

   DEFINE v_cont_comi                 SMALLINT;

   DEFINE v_participa                 DECIMAL(18,8);
   DEFINE wcredcte                    SMALLINT;

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET v_codret = sql_err;
      SET DEBUG FILE TO "Linea_nodisp.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      RETURN v_codret, g_num_credito;
   END EXCEPTION;

   
   --#################################################################
   --#####                INICIALIZACION DE VARIABLES            #####
   --#################################################################
   LET v_monto            = 0;
   LET v_codret           = "000";
   LET cxc_num_credito    = " ";
   LET cxc_cod_comis      = " ";
   LET cxc_factor         = 0;
   LET cxc_monto          = 0;
   LET v_cont_comi        = 0;

   LET v_folio_suc      = "               ";
   LET v_usuario        = USER;
   LET v_hora           = CURRENT HOUR TO FRACTION;
   LET v_hora_c1        = v_hora;
   LET v_hora_c2        = v_hora_c1;
   LET v_folio_suc      = TRIM(v_usuario) || TRIM(v_hora_c2);

   LET base_calculo     = 0;
   LET v_monto_tot      = 0;
   LET v_participa      = 0;
   LET wcredcte         = 0;


   LET v_monto = 0;
   LET v_monto = gl_linea_prod - gl_linea_util;
   IF (gl_linea_util > 0) THEN
      IF gl_linea_util = 0 THEN
         LET gl_linea_util = 1;
      END IF;
      LET v_participa = (g_sdo_cap_insoluto * 100) / gl_linea_util;
   ELSE
      SELECT
         COUNT(*)
      INTO
         wcredcte     
      FROM
         sd_maecred
      WHERE
         num_producto = g_num_producto
      AND
         empresa      = g_empresa
      AND
         numcte       = g_numcte
      AND
         num_linea    = g_num_linea
      AND
         status_cred NOT IN ("FF"); 

      IF wcredcte <= 0 THEN
         LET wcredcte = 1;
      END IF;
   END IF;
   IF v_monto != 0 THEN

      LET cxc_num_credito    = " ";
      LET cxc_cod_comis      = " ";
      LET cxc_factor         = 0;
      LET cxc_monto          = 0;

      SELECT * 
      INTO  cxc_num_credito, cxc_cod_comis, 
            cxc_factor,      cxc_monto
      FROM sd_comxcre
      WHERE num_credito = g_num_credito AND
            cod_comis   = g_valor36;

      IF cxc_num_credito IS NULL OR cxc_num_credito = " " THEN
         LET v_codret = "317";
         LET v_codret = "000";
         RETURN v_codret, g_num_credito;
      END IF;

      LET base_calculo  = 0;
      LET v_monto_tot   = 0;

      LET base_calculo  = v_monto;
      LET v_monto_tot = (base_calculo * (cxc_factor / 100)) / 360;
      LET v_monto_tot = v_monto_tot * p_dias;

      LET v_cont_comi = 0;
      SELECT COUNT(*) 
      INTO v_cont_comi
      FROM sd_detcomi
      WHERE num_credito = g_num_credito AND
            cod_comis   = g_valor36 AND
            estado_com  = "P";

      IF (v_participa <> 0) THEN
         LET v_monto_tot = (v_monto_tot * v_participa) / 100;
      ELSE
          IF wcredcte <= 0 THEN
             LET wcredcte = 1;
          END IF;
         LET v_monto_tot = v_monto_tot / wcredcte;
      END IF;
      IF v_cont_comi = 0 THEN
         INSERT INTO sd_detcomi
         VALUES (g_num_credito,
                 p_fecha_proceso,
                 g_valor36,
                 v_folio_suc,
                 v_monto_tot,
                 "P",
                 "",
                 "N",
                  0);
      ELSE
         UPDATE sd_detcomi
         SET monto_com = monto_com + v_monto_tot,
             fecha_mov = p_fecha_proceso,
             folio     = v_folio_suc
         WHERE num_credito = g_num_credito AND
               cod_comis   = g_valor36     AND 
               estado_com  = "P";                  
      END IF;          

   END IF;


   RETURN v_codret, g_num_credito;


END PROCEDURE

DOCUMENT
"Spl para calculo de comision por no disponer de la linea",
"base de datos : bdicred",
"AUTOR : Jose Cruz Narvaez Guzman",
"FECHA : 04/Mayo/2001",
"Ver.  : 1.0",
"Mod   : Sergio Ruiz Para Que Permita El Calculo del Credito SIN que",
"      : Tenga Comision por no Uso de Linea",
"Fecha : 28/Noviembre/2001",
"Mod   : Sergio Ruiz Para Que NO Divida El Calculo del Credito Con  Ceros",
"Fecha : 09/Julio/2002";

CREATE PROCEDURE "informix".mora_detalle(p_fecha_proceso DATE,
                              p_dias          SMALLINT)

       RETURNING CHAR(5), CHAR(20), MONEY(14,2), MONEY(14,2),
                                    MONEY(14,2), MONEY(14,2);


   DEFINE GLOBAL g_num_credito        CHAR(20)       DEFAULT " ";
   DEFINE GLOBAL g_tasa_interes       decimal(9,6)   DEFAULT 0;
   DEFINE GLOBAL g_tasa_morato        decimal(9,6)   DEFAULT 0;
   DEFINE GLOBAL g_empresa            CHAR(3)        DEFAULT " ";

   DEFINE GLOBAL g_codigo_fun         CHAR(3)        DEFAULT "034";

   DEFINE GLOBAL gc_num_credito       CHAR(20)       DEFAULT " ";
   DEFINE GLOBAL gc_fecha_cuota       DATE           DEFAULT " ";
   DEFINE GLOBAL gc_cuota_rec         CHAR(1)        DEFAULT " ";
   DEFINE GLOBAL gc_num_cuota         SMALLINT       DEFAULT 0;
   DEFINE GLOBAL gc_monto_cuota       MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL gc_saldo_cuota       MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL gc_imp_capzado       MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL gc_monto_real_pag    MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL gc_fecha_pago        DATE           DEFAULT " ";
   DEFINE GLOBAL gc_porc_pago         DECIMAL(9,6)   DEFAULT 0;
   DEFINE GLOBAL gc_bandera_minis     CHAR(1)        DEFAULT " ";
   DEFINE GLOBAL gc_status_cuota      CHAR(1)        DEFAULT " ";


   DEFINE v_monto            MONEY(14,2);
   DEFINE v_monto_finan      MONEY(14,2);

   DEFINE v_codret           CHAR(5);
   DEFINE vt_sum_sdocuota    MONEY(14,2);
   DEFINE vt_sumcapitaliz    MONEY(14,2);
   DEFINE vt_sum_realpa      MONEY(14,2);
   DEFINE vt_pago_capzado    MONEY(14,2);
   DEFINE vt_pago_capital    MONEY(14,2);

   DEFINE v_num_cuota        SMALLINT;
   DEFINE v_foliosuc         CHAR(16);


   DEFINE interes_moraord7     DECIMAL(14,2);
   DEFINE interes_moracop7     DECIMAL(14,2);
   DEFINE interes_moraord2     DECIMAL(14,2);
   DEFINE interes_moracop2     DECIMAL(14,2);
   DEFINE base_calculo_mo      DECIMAL(14,2);
   DEFINE base_calculo_mc      DECIMAL(14,2);
   DEFINE interes_moratorio    DECIMAL(14,2);
   DEFINE interes_moraord      DECIMAL(14,2);
   DEFINE interes_moracop      DECIMAL(14,2);

   DEFINE int_acu_moraord7        MONEY(14,2);
   DEFINE int_acu_moracop7        MONEY(14,2);
   DEFINE int_acu_moraord2        MONEY(14,2);
   DEFINE int_acu_moracop2        MONEY(14,2);
   DEFINE w_max_cuota_detmo       MONEY(14,2);
   DEFINE wfecha_moratorio        DATE;


   DEFINE sql_err            SMALLINT;
   DEFINE isam_err           SMALLINT;
   DEFINE error_info         CHAR(40);


   ON EXCEPTION SET sql_err, isam_err, error_info
      LET v_codret = sql_err;
      SET DEBUG FILE TO "Mora_detalle.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      RETURN v_codret,         g_num_credito,
             int_acu_moraord7, int_acu_moracop7,
             int_acu_moraord2, int_acu_moracop2;
   END EXCEPTION;


   --#################################################################
   --#####                INICIALIZACION DE VARIABLES            #####
   --#################################################################

   LET v_monto            = 0;
   LET v_monto_finan      = 0;
   LET vt_sumcapitaliz    = 0;
   LET v_codret           = "000";
   LET vt_sum_sdocuota    = 0;

   LET vt_sum_realpa      = 0;
   LET v_num_cuota        = 0;
   LET v_foliosuc         = "               ";

   LET interes_moraord7  = 0;
   LET interes_moracop7  = 0;
   LET interes_moraord2  = 0;
   LET interes_moracop2  = 0;
   LET base_calculo_mo   = 0;
   LET base_calculo_mc   = 0;

   LET interes_moraord    = 0;
   LET interes_moracop    = 0;
   LET interes_moratorio  = 0;

   LET int_acu_moraord7 = 0;
   LET int_acu_moracop7 = 0;
   LET int_acu_moraord2 = 0;
   LET int_acu_moracop2 = 0;

   LET w_max_cuota_detmo  = 0;
   LET wfecha_moratorio  = NULL;


   --######################################################
   --###    Select de cuotas de capital para traspaso
   --######################################################
   FOREACH WITH HOLD
      SELECT num_credito,        fecha_cuota,
             cuota_rec,          --num_cuota,
             monto_cuota,        saldo_cuota,
             imp_capitalizado,   monto_real_pag,
             fecha_pago,         porc_pago,
             bandera_ministra,   status_cuota
      INTO
         gc_num_credito,    gc_fecha_cuota,
         gc_cuota_rec,      --gc_num_cuota,
         gc_monto_cuota,    gc_saldo_cuota,
         gc_imp_capzado,    gc_monto_real_pag,
         gc_fecha_pago,     gc_porc_pago,
         gc_bandera_minis,  gc_status_cuota
      FROM   sd_pagocapit
      WHERE status_cuota       IN ("7","2")
      AND   bandera_ministra   = "A"
      AND   num_credito        = g_num_credito
      AND   empresa            = g_empresa
      ORDER BY fecha_cuota ASC




      CALL Saldo_cuo_cap()
      RETURNING v_codret, g_num_credito, v_monto, v_monto_finan;



      IF gc_status_cuota = "7" THEN
         LET base_calculo_mo  = 0;
         LET base_calculo_mc  = 0;
         LET base_calculo_mo  = v_monto;
         LET interes_moraord7 = (base_calculo_mo * (g_tasa_interes /100))/360;
         LET base_calculo_mc  = v_monto;
         LET interes_moracop7 = (base_calculo_mc * (g_tasa_morato/100))/360;
      END IF;

      IF gc_status_cuota = "2" THEN
         LET base_calculo_mo  = 0 ;
         LET base_calculo_mc  = 0 ;
         LET base_calculo_mo  = v_monto;
         LET interes_moraord2 = (base_calculo_mo * (g_tasa_interes /100))/360;
         LET base_calculo_mc  = v_monto;
         LET interes_moracop2 = (base_calculo_mc * (g_tasa_morato/100))/360;
      END IF;


      LET interes_moraord7 = interes_moraord7 * p_dias;  
      LET interes_moracop7 = interes_moracop7 * p_dias;
      LET interes_moraord2 = interes_moraord2 * p_dias;
      LET interes_moracop2 = interes_moracop2 * p_dias; 

      LET interes_moraord    = 0;
      LET interes_moracop    = 0;
      LET interes_moratorio  = 0;

      LET interes_moraord    = interes_moraord7 + interes_moraord2;
      LET interes_moracop    = interes_moracop7 + interes_moracop2;
      LET interes_moratorio  = interes_moraord  + interes_moracop;


      LET wfecha_moratorio  = NULL;
      SELECT fecha_moratorio INTO wfecha_moratorio  
      FROM sd_pagocapit
      WHERE fecha_cuota = gc_fecha_cuota AND
            empresa   = g_empresa AND
            num_credito = gc_num_credito; 

      IF wfecha_moratorio IS NULL OR wfecha_moratorio = " " THEN
         UPDATE sd_pagocapit
         SET  fecha_moratorio  = p_fecha_proceso
         WHERE fecha_cuota = gc_fecha_cuota AND
               empresa   = g_empresa AND
               num_credito = gc_num_credito;
      END IF;

      --###########################################################
      --###### ACTUALIZA CUOTA DEL PLAN DE PAGOS DE CAPITAL
      --###########################################################
      UPDATE sd_pagocapit
      SET  factor_moratorio = g_tasa_interes + g_tasa_morato,
           monto_moratorio  = monto_moratorio + interes_moratorio,
           dias_moratorios  = dias_moratorios + p_dias
      WHERE fecha_cuota = gc_fecha_cuota AND
            empresa   = g_empresa AND
            num_credito = gc_num_credito;


      --###########################################################
      --###### ACTUALIZA CUOTA DEL DETALLE DE MORATORIOS
      --###########################################################
      IF interes_moraord > 0 OR interes_moracop > 0 THEN

         LET w_max_cuota_detmo  = 0;

         SELECT count(*) INTO w_max_cuota_detmo
         FROM sd_detmora
         WHERE num_credito  = gc_num_credito  AND
               identifi_rec = "P"             AND
               empresa    = g_empresa;

         IF w_max_cuota_detmo = 0 OR w_max_cuota_detmo IS NULL THEN
            INSERT INTO sd_detmora
            VALUES (g_empresa,gc_num_credito,     "P",
                    interes_moratorio,
                    g_tasa_interes,     interes_moraord,
                    g_tasa_morato,      interes_moracop,
                    interes_moraord,    interes_moracop,
                    interes_moraord,    interes_moracop,
                    0,0, gc_status_cuota);
         ELSE
            UPDATE sd_detmora SET (
                      sdo_acum_mes_mora,
                      tasa_ordinaria,
                      provi_mora_ordi,
                      tasa_copete,
                      privi_mora_cope,
                      sdo_mora_ordi,
                      sdo_mora_cope,
                      estado_prov)
                 = (  sdo_acum_mes_mora + interes_moratorio,
                      g_tasa_interes,
                      provi_mora_ordi   + interes_moraord,
                      g_tasa_morato,
                      privi_mora_cope   + interes_moracop,
                      sdo_mora_ordi     + interes_moraord,
                      sdo_mora_cope     + interes_moracop,
                      gc_status_cuota)
            WHERE num_credito   = gc_num_credito AND
                  identifi_rec  = "P" AND
                  empresa     = g_empresa;

         END IF;
      END IF;

      LET int_acu_moraord7 = int_acu_moraord7 + interes_moraord7;
      LET int_acu_moracop7 = int_acu_moracop7 + interes_moracop7;
      LET int_acu_moraord2 = int_acu_moraord2 + interes_moraord2;
      LET int_acu_moracop2 = int_acu_moracop2 + interes_moracop2;


   END FOREACH;



   RETURN v_codret,         g_num_credito,
          int_acu_moraord7, int_acu_moracop7,
          int_acu_moraord2, int_acu_moracop2;



END PROCEDURE


DOCUMENT
"Sp, que calcula los moratorios por cuota de capital vencido ",
"base de datos : bdicred",
"AUTOR : Jose Cruz Narvaez Guzman",
"FECHA : 23/abril/2001",
"Ver.  : 1.0",
"Mod   : por Jose Cruz el 30 de Agosto del 2001 en PISA ",
"Se agraga validacion de la fecha de moratorios para que solo la  ",
"actualice el primer dia que cae en mora  ";

CREATE PROCEDURE "informix".sp_trans_hist_revtasa(P_EMPRESA          VARCHAR(3),
       P_FECHA_HOY        DATE
      ) RETURNING VARCHAR(6), VARCHAR(80);

DEFINE  P_COD_RET  VARCHAR(6);
DEFINE  P_MENSAJE  VARCHAR(80);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);

BEGIN
  ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET  = SQL_ERR;
     LET P_MENSAJE  = ERROR_INFO;
     RETURN P_COD_RET, P_MENSAJE;
  END EXCEPTION;
  
  LET P_COD_RET = '00000';
  LET P_MENSAJE = 'PROCESO EXITOSO';
  
  BEGIN WORK;
    INSERT INTO SD_REVTASA_HIST
            (EMPRESA,              NUM_CREDITO,
             FECHA_FIN_TASA,       TASA_INTERES,
             TASA_MORATORIOS)
      SELECT M.EMPRESA,             M.NUM_CREDITO,
             R.FECHA_PROX_REV - 1,  M.TASA_INTERES,
             M.TASA_MORATORIOS
      FROM   SD_MAECRED M,
             SD_REVTASA R
      WHERE  M.EMPRESA          = R.EMPRESA
      AND    M.NUM_CREDITO      = R.NUM_CREDITO
      AND    M.TASA_FIJA_O_VAR  = '2'
      AND    SUBSTR(M.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
      AND    M.BANDERA_MINISTRA = 'M'
      AND    R.FECHA_PROX_REV   = P_FECHA_HOY
      AND    R.EMPRESA          = P_EMPRESA;
  COMMIT WORK;
  RETURN P_COD_RET, P_MENSAJE;
END;
END PROCEDURE;