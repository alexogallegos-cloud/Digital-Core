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