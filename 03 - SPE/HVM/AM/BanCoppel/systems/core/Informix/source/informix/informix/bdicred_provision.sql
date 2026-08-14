CREATE PROCEDURE "informix".provision(p_fecha_proceso  DATE,
                           p_dias           SMALLINT,
                           p_dia_extremo    SMALLINT)

       RETURNING CHAR(5), CHAR(20);


   DEFINE GLOBAL g_num_credito        CHAR(20)       DEFAULT " ";
   DEFINE GLOBAL g_divisa             CHAR(2)        DEFAULT " ";
   DEFINE GLOBAL g_num_producto       CHAR(4)        DEFAULT " ";
   DEFINE GLOBAL g_numcte             CHAR(20)       DEFAULT " ";
   DEFINE GLOBAL g_sucursal           CHAR(4)        DEFAULT " ";
   DEFINE GLOBAL g_fecha_apertu       date           DEFAULT " ";
   DEFINE GLOBAL g_fecha_vencim       date           DEFAULT " ";
   DEFINE GLOBAL g_tasa_interes       decimal(9,6)   DEFAULT 0;
   DEFINE GLOBAL g_tasa_morato        decimal(9,6)   DEFAULT 0;
   DEFINE GLOBAL g_tasa_f_o_v         CHAR(1)        DEFAULT " ";
   DEFINE GLOBAL g_cod_tasa_base      CHAR(8)        DEFAULT " ";
   DEFINE GLOBAL g_sobretasa          decimal(9,6)   DEFAULT 0;
   DEFINE GLOBAL g_factor_sobretasa   CHAR(1)        DEFAULT " ";
   DEFINE GLOBAL g_tasa_mora_adic     CHAR(1)        DEFAULT " ";
   DEFINE GLOBAL g_cod_tasa_mora      CHAR(8)        DEFAULT " ";
   DEFINE GLOBAL g_sobretasa_mora     decimal(9,6)   DEFAULT 0;
   DEFINE GLOBAL g_fact_sobret_mora   CHAR(1)        DEFAULT " ";
   DEFINE GLOBAL g_factor_moratorio   decimal(9,6)   DEFAULT 0;
   DEFINE GLOBAL g_es_fisica          CHAR(1)        DEFAULT " ";
   DEFINE GLOBAL g_rev_tasa_var_per   CHAR(1)        DEFAULT " ";
   DEFINE GLOBAL g_dia_para_revisar   SMALLINT       DEFAULT 0;
   DEFINE GLOBAL g_status_cred        CHAR(2)        DEFAULT " ";
   DEFINE GLOBAL g_tipo_calculo       CHAR(2)        DEFAULT " ";
   DEFINE GLOBAL g_porc_rec_p         DECIMAL(9,6)   DEFAULT 0;
   DEFINE GLOBAL g_campo_trab3        CHAR(10)       DEFAULT " ";
   DEFINE GLOBAL g_period_pago_int    CHAR(1)        DEFAULT " ";
   DEFINE GLOBAL g_sdo_capital        MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_mto_capitalizado   MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_sdo_acum_intper    MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_sdo_trab4          MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_sdo_no_exig        MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_monto_otorgado     MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_sdo_acum_mes_int   MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_sdo_cap_insoluto   MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_monto_vencido      MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_mto_venc_trasp     MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_sdo_exig_int       MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_mto_finan_vdo      MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_mto_fin_ven_tras   MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_provi_venc_ant     MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_provi_venc_nor     MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_provision_normal   MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_empresa            CHAR(3)        DEFAULT " ";
   DEFINE GLOBAL g_mensaje            CHAR(3)       DEFAULT " ";

   DEFINE GLOBAL g_cod_tipcred        CHAR(2)        DEFAULT " ";

   DEFINE GLOBAL g_ult_dia_mes        date           DEFAULT " ";
   DEFINE GLOBAL g_ult_hab_mes        date           DEFAULT " ";

   DEFINE GLOBAL g_valor16            CHAR(50)       DEFAULT " ";
   -- period_contab_int
   DEFINE GLOBAL g_valor17            CHAR(50)       DEFAULT " ";
   -- period_contab_mora

   DEFINE GLOBAL g_codigo_fun         CHAR(3)        DEFAULT "034";


   DEFINE   interes_diario            DECIMAL(14,2);
   DEFINE   interes_proreno           DECIMAL(14,2);
   DEFINE   interes_moratorio         DECIMAL(14,2);
   DEFINE   interes_moraord           DECIMAL(14,2);
   DEFINE   interes_moracop           DECIMAL(14,2);

   DEFINE   interes_moraord7          DECIMAL(14,2);
   DEFINE   interes_moracop7          DECIMAL(14,2);
   DEFINE   interes_moraord2          DECIMAL(14,2);
   DEFINE   interes_moracop2          DECIMAL(14,2);

   DEFINE   int_acu_moraord7          DECIMAL(14,2);
   DEFINE   int_acu_moracop7          DECIMAL(14,2);
   DEFINE   int_acu_moraord2          DECIMAL(14,2);
   DEFINE   int_acu_moracop2          DECIMAL(14,2);

   DEFINE   fin_adic_dia              MONEY(14,2);
   DEFINE   provision                 MONEY(14,2);
   DEFINE   provisionmen              MONEY(14,2);
   DEFINE   fin_adicional             MONEY(14,2);
   DEFINE   wfecha_cuota              DATE;
   DEFINE   base_calculo              DECIMAL(14,2);

   DEFINE   max_fec_int               DATE;
   DEFINE   max_fec_cap               DATE;
   DEFINE   v_bandcalcint             SMALLINT;
   DEFINE   v_bandmoras               SMALLINT;
   DEFINE   max_num_int               SMALLINT;
   DEFINE   vbandprovi                SMALLINT;
   DEFINE   vbandprorr                SMALLINT;
   DEFINE   v_sdo_acum_vencido        DECIMAL(14,2);
   DEFINE   v_sdo_acum_mes_cap        DECIMAL(14,2);
   DEFINE   v_sdo_acum_capital        DECIMAL(14,2);
   DEFINE   v_sdointantdevpro         DECIMAL(14,2);
   DEFINE   v_provi_venc_nor          DECIMAL(14,2);
   DEFINE   v_provi_venc_ant          DECIMAL(14,2);
   DEFINE   w_dias                    SMALLINT;
   DEFINE   prorrateo                 DECIMAL(14,2);

   DEFINE v_codret                    CHAR(5);
   DEFINE sql_err                     SMALLINT;
   DEFINE isam_err                    SMALLINT;
   DEFINE error_info                  CHAR(40);
   DEFINE v_int_tranoexig             DECIMAL(14,2);

   DEFINE vi_status_cuota             CHAR(1);
   DEFINE v_evento_int                SMALLINT;
   DEFINE vc_status_cuota             CHAR(1);
   DEFINE v_evento_cap                SMALLINT;

   DEFINE vsdoacummesint              DECIMAL(14,2);

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET v_codret = sql_err;
      SET DEBUG FILE TO "provision.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      RETURN v_codret, g_num_credito;
   END EXCEPTION;



   LET base_calculo       = 0;
   LET v_codret           = "000";

   LET v_bandcalcint      = 0;
   LET v_bandmoras        = 0;

   LET interes_diario     = 0;
   LET interes_moraord    = 0;
   LET interes_moracop    = 0;

   LET interes_moraord7   = 0;
   LET interes_moracop7   = 0;
   LET interes_moraord2   = 0;
   LET interes_moracop2   = 0;

   LET int_acu_moraord7   = 0;
   LET int_acu_moracop7   = 0;
   LET int_acu_moraord2   = 0;
   LET int_acu_moracop2   = 0;

   LET interes_proreno    = 0;
   LET fin_adic_dia       = 0;
   LET vbandprovi         = 0;
   LET vbandprorr         = 0;
   LET v_sdointantdevpro  = 0;
   LET interes_moratorio  = 0;
   LET w_dias             = 0;
   LET prorrateo          = 0;
   LET provision          = 0;
   LET v_int_tranoexig    = 0;

   LET v_provi_venc_nor   = 0;
   LET v_provi_venc_ant   = 0;

   LET vi_status_cuota    = "";
   LET v_evento_int       = 0;
   LET vc_status_cuota    = "";
   LET v_evento_cap       = 0;

   LET vsdoacummesint     = 0;

   -- Valida si el sdo_capital vigente es igual a cero
   IF g_sdo_capital > 0 THEN
      LET v_bandcalcint = 1;
   END IF
   IF g_monto_vencido + g_mto_venc_trasp > 0 THEN
      LET v_bandmoras   = 1;
   END IF


      IF g_tipo_calculo = "01"  OR g_tipo_calculo = "09" THEN
          CALL Cal_Tradicion()
                    RETURNING v_codret,         g_num_credito,
                              interes_diario,   interes_proreno ,
                              interes_moraord7, interes_moracop7,
                              interes_moraord2, interes_moracop2,
                              base_calculo;
      ELIF g_tipo_calculo = "02" THEN
          CALL Cal_Tradicion()
                    RETURNING v_codret,         g_num_credito,
                              interes_diario,   interes_proreno ,
                              interes_moraord7, interes_moracop7,
                              interes_moraord2, interes_moracop2,
                              base_calculo;
      ELIF g_tipo_calculo = "04" THEN
          CALL Cal_Tradicion()
                    RETURNING v_codret,         g_num_credito,
                              interes_diario,   interes_proreno ,
                              interes_moraord7, interes_moracop7,
                              interes_moraord2, interes_moracop2,
                              base_calculo;
      END IF;


      LET interes_moraord   = interes_moraord7 + interes_moraord2;
      LET interes_moracop   = interes_moracop7 + interes_moracop2;

      LET interes_diario   = interes_diario  * p_dias;
      LET interes_proreno  = interes_proreno * p_dias;
      LET fin_adicional    = fin_adic_dia    * p_dias;
      LET interes_moraord  = interes_moraord * p_dias;
      LET interes_moracop  = interes_moracop * p_dias;

      LET interes_moratorio = 0;
      LET interes_moratorio = interes_moraord + interes_moracop;


      LET provision         = interes_diario;
      IF g_tipo_calculo = "02" THEN
         LET prorrateo = provision;
         LET provision = 0;
         LET vsdoacummesint = prorrateo;
      ELSE
         LET vsdoacummesint = provision;
         LET prorrateo = 0;
      END IF


      IF g_valor16 = "1" THEN          -- Provision Diaria
         IF g_tipo_calculo = "02" THEN
            LET vbandprorr = 1;        -- Bandera de prorrateo
            LET v_sdointantdevpro = prorrateo;
         ELSE
            LET vbandprovi = 1;        -- Bandera para la Provision
            LET v_sdointantdevpro = provision;
         END IF
         LET v_provi_venc_nor = 0;
         LET v_provi_venc_ant = 0;
      END IF;

      IF g_valor16 = "2" THEN                    -- Provision Mensual
         IF p_fecha_proceso = g_ult_dia_mes then
            IF g_tipo_calculo = "02" THEN
               LET vbandprorr        = 1;
               LET provision = provision + prorrateo;
            ELSE
               LET vbandprovi        = 1;
            END IF
            IF g_campo_trab3 = "E" THEN
               LET v_provi_venc_nor = 0;
               LET v_provi_venc_ant = 0;
     --RMD          LET v_sdointantdevpro = provision + g_provi_venc_ant;
               LET v_sdointantdevpro = provision + g_provi_venc_ant;
               LET v_provi_venc_nor = g_provi_venc_nor;
               LET v_provi_venc_ant = g_provi_venc_ant;
            ELSE
      --RMD      LET v_sdointantdevpro = provision + g_sdo_acum_mes_int ;
               LET v_sdointantdevpro   = provision + g_sdo_acum_mes_int - g_provision_normal;
               LET v_provi_venc_nor = 0;
               LET v_provi_venc_ant = 0;
            END IF;
         ELSE
            LET v_evento_int = 0;
            SELECT  status_cuota, count(*)
            INTO vi_status_cuota, v_evento_int
            FROM sd_paginter
            WHERE num_credito = g_num_credito
            AND fecha_cuota = p_fecha_proceso
            AND empresa = g_empresa
            AND status_cuota in ( "7","2")
            GROUP BY 1;

            IF v_evento_int <> 0 THEN
               LET vbandprovi = 1;
               IF g_campo_trab3 = "E" THEN
                  LET v_provi_venc_nor  = 0;
                  LET v_provi_venc_ant  = 0;
     --RMD         LET v_sdointantdevpro = provision + g_provi_venc_ant;
                  LET v_sdointantdevpro  = g_provi_venc_ant;
                  LET v_provi_venc_nor  = g_provi_venc_nor;
                  LET v_provi_venc_ant  = g_provi_venc_ant;
               ELSE
    --RMD              LET v_sdointantdevpro = provision + g_sdo_acum_mes_int;
                  LET v_sdointantdevpro = g_sdo_acum_mes_int - g_provision_normal;
                  LET v_provi_venc_nor  = 0;
                  LET v_provi_venc_ant  = 0;
               END IF;
            ELSE
               LET vbandprovi = 0;
               LET vbandprorr = 0;
            END IF;
         END IF
      END IF


      IF v_sdointantdevpro  != 0 THEN
         CALL Cont_Int_Nor(vbandprovi,         vbandprorr,
                           v_sdointantdevpro,  interes_proreno,
                           v_provi_venc_nor,   v_provi_venc_ant,
                           vi_status_cuota,    p_fecha_proceso)
         RETURNING v_codret;
      END IF;


      CALL Mora_detalle(p_fecha_proceso, p_dias)
      RETURNING v_codret,            g_num_credito,
                int_acu_moraord7,    int_acu_moracop7,
                int_acu_moraord2,    int_acu_moracop2;

      LET interes_moratorio = 0;
      LET interes_moraord   = int_acu_moraord7 + int_acu_moraord2;
      LET interes_moracop   = int_acu_moracop7 + int_acu_moracop2;
      LET interes_moratorio = interes_moraord + interes_moracop;


      LET vbandprovi = 0;
      IF g_valor17 = "1" THEN          -- Provision Diaria int moratorio
         IF interes_moraord > 0 OR interes_moracop > 0 THEN
            LET vbandprovi = 1;
         END IF;
      END IF;

      IF g_valor17 = "2" THEN          -- Provision Mensual int moratorio
         IF p_fecha_proceso = g_ult_dia_mes then
            LET vbandprovi = 1;
         ELSE
            LET v_evento_cap = 0;
            SELECT status_cuota,  count(*)
            INTO vc_status_cuota, v_evento_cap
            FROM sd_pagocapit
            WHERE num_credito = g_num_credito
            AND empresa = g_empresa
            AND fecha_cuota = p_fecha_proceso
            AND status_cuota in ( "7","2","5")
            GROUP BY 1;

            IF v_evento_cap <> 0 THEN
               LET vbandprovi = 1;
            ELSE
               LET vbandprovi = 0;
            END IF
         END IF;
      END IF;

      IF interes_moraord > 0 OR interes_moracop > 0 THEN
         LET w_dias             = p_dias;
      END IF;


      IF vbandprovi = 1 THEN

         CALL Cont_Int_Mora(int_acu_moraord7, int_acu_moracop7,
                            int_acu_moraord2, int_acu_moracop2,
                            p_fecha_proceso,  v_evento_cap)
         RETURNING v_codret;

      END IF;


      --###############################################################
      --#####           Saldo Capital Acumulado Vencido           #####
      --###############################################################
      LET v_sdo_acum_vencido = 0;
      LET v_sdo_acum_vencido =
         ((g_monto_vencido  + g_mto_finan_vdo      ) +
          (g_mto_venc_trasp + g_mto_fin_ven_tras  )) * p_dias;

      --###############################################################
      --#####           Saldo Capital Acumulado Vivente           #####
      --###############################################################
      LET v_sdo_acum_mes_cap = 0 ;
      LET v_sdo_acum_mes_cap = (g_sdo_capital +
                                g_mto_capitalizado) * p_dias ;

      LET  v_sdo_acum_capital = 0;
      LET  v_sdo_acum_capital = v_sdo_acum_vencido + v_sdo_acum_mes_cap;


      IF g_campo_trab3 = "E" THEN
         LET v_int_tranoexig = provision;
      ELSE
         LET v_int_tranoexig = 0;
      END IF;


      UPDATE sd_maesdos
      SET fecha_ult_mov      = p_fecha_proceso,
          sdo_int_ant_dev    = sdo_int_ant_dev  + prorrateo,
          sdo_intereses      = sdo_intereses    + provision,
          sdo_acum_mes_int   = sdo_acum_mes_int + vsdoacummesint,
          sdo_no_exig        = sdo_no_exig      + provision,
          provision_normal   = provision_normal + v_sdointantdevpro,
          dias_acum_int      = dias_acum_int    + p_dias,

          dias_acum_cap      = dias_acum_cap    + p_dias,
          sdo_acum_mes_cap   = sdo_acum_mes_cap + v_sdo_acum_mes_cap,
          sdo_acum_vencido   = sdo_acum_vencido + v_sdo_acum_vencido,

          sdo_moratorio      = sdo_moratorio    + interes_moratorio,
          sdo_contab_mora    = interes_moratorio,
          dias_acum_mora     = dias_acum_mora   + w_dias,
          sdo_acum_cap_int   = base_calculo,
          dias_acum_intper   = dias_acum_intper + p_dias,
          sdo_global_int     = sdo_global_int   + provision,
          sdo_acum_intper    = sdo_acum_intper  + provision,
          int_tra_no_exig    = int_tra_no_exig  + v_int_tranoexig,
          provi_venc_anticip = provi_venc_anticip + v_int_tranoexig
      WHERE num_credito = g_num_credito
      AND empresa = g_empresa;


      LET g_sdo_acum_mes_int   = g_sdo_acum_mes_int   + vsdoacummesint;
      LET g_sdo_no_exig        = g_sdo_no_exig        + provision;
      LET g_sdo_acum_intper    = g_sdo_acum_intper    + provision;
      LET g_provi_venc_ant     = g_provi_venc_ant     + v_int_tranoexig;


      LET wfecha_cuota = NULL;

      SELECT MIN(fecha_cuota)
      INTO wfecha_cuota
      FROM sd_paginter
      WHERE num_credito = g_num_credito
      AND empresa = g_empresa
      AND fecha_cuota > p_fecha_proceso
      AND status_cuota = "1";

      IF wfecha_cuota IS NOT NULL THEN

         UPDATE sd_paginter
         SET monto_cuota      = monto_cuota + provision,
             porc_pago        = porc_pago + interes_proreno,
             monto_moratorio  = monto_moratorio + v_sdo_acum_capital,
             dias_moratorio   = dias_moratorio + p_dias
         WHERE num_credito    = g_num_credito
         AND fecha_cuota      = wfecha_cuota
         AND empresa          = g_empresa
         AND status_cuota     = "1";

      ELSE

         LET max_fec_int = NULL;
         SELECT MAX(fecha_cuota)
         INTO   max_fec_int
         FROM   sd_paginter
         WHERE  num_credito = g_num_credito
         AND    empresa     = g_empresa
         AND fecha_cuota > p_fecha_proceso;

         LET max_fec_cap = NULL;
         SELECT MAX(fecha_cuota)
         INTO   max_fec_cap
         FROM   sd_pagocapit
         WHERE  num_credito = g_num_credito
         AND    empresa     = g_empresa;

         IF max_fec_int IS NOT NULL THEN
            IF (max_fec_cap IS NOT NULL) THEN
               UPDATE sd_paginter
               SET monto_cuota      = monto_cuota + provision,
                   porc_pago        = porc_pago  +  interes_proreno,
                   monto_moratorio  = monto_moratorio + v_sdo_acum_capital,
                   dias_moratorio   = dias_moratorio + p_dias,
                   fecha_cuota = max_fec_cap,
                   status_cuota = "1"
               WHERE num_credito = g_num_credito AND
                     empresa     = g_empresa     AND
                     fecha_cuota = max_fec_int;
            END IF;
         ELSE
            IF g_tipo_calculo != "02" THEN
               IF g_tipo_calculo = "04" THEN

                  CALL ValCuotaPI (g_num_credito,
                                   g_fecha_vencim,
                                   g_period_pago_int,
                                   provision,
                                   v_sdo_acum_capital,
                                   p_dias,
                                   interes_proreno)
                  RETURNING v_codret;


               ELSE
                  {SELECT MAX(num_cuota)
                  INTO   max_num_int
                  FROM   sd_paginter
                  WHERE  num_credito = g_num_credito;

                  LET max_num_int = max_num_int + 1;  -- num_cuota
                  INSERT INTO sd_paginter
                  VALUES ( g_num_credito,  -- num_credito
                           max_fec_cap,          -- fecha_cuota
                           "1",                  -- cuota_rec
                           max_num_int,          -- num_cuota
                           provision,            -- monto_cuota
                           0,                    -- monto_real_pag
                           "",                   -- fecha_pag
                           0,                    -- factor_moratorio
                           v_sdo_acum_capital,   -- monto_moratorio
                           "",                   -- fecha_moratorio
                           p_dias,                -- dias_moratorio
                           "1",                  -- status_moratorio
                           "G",                  -- bonifi_int_mora
                           interes_proreno,      -- porc_pago
                           "1",                  -- status_cuota
                           0);                   -- monto_financiado}

               END IF;
            END IF;
         END IF;
     END IF;

   RETURN v_codret, g_num_credito;

END PROCEDURE
DOCUMENT
"Mod.   : En tipo de calculo 02, se creo variable para el saldo acumulado del mes",
"       : de intereses para su prorrateo mensual",
"       : Jose Cruz Narvaez Guzman ",
"       : 08/Agosto/2001";

CREATE PROCEDURE "informix".sp_plan_pagos(P_EMPRESA       VARCHAR(3)
                ,P_NUM_CREDITO   VARCHAR(20)
                ) RETURNING VARCHAR(5), VARCHAR(80);

DEFINE P_COD_RET           VARCHAR(5);
DEFINE P_MENSAJE           VARCHAR(80);

DEFINE V_FECHA_HOY         DATE;
DEFINE V_MONTO             DECIMAL(18,2);
DEFINE V_PERIODO_PAG_CAP   VARCHAR(1);
DEFINE V_PERIODO_PAG_INT   VARCHAR(1);
DEFINE V_TIPO_CALCULO      VARCHAR(2);
DEFINE V_SUCURSAL          VARCHAR(4);
DEFINE V_PERIODO_PLAZO     VARCHAR(1);
DEFINE V_PLAZO             INTEGER;
DEFINE V_TP_GEN_PLANPAGO   VARCHAR(1);
DEFINE V_GRACIA_CAP        INTEGER;
DEFINE V_DIFERIMIENTO_INT  INTEGER;
DEFINE V_EQUIVAL_CAP       INTEGER;
DEFINE V_EQUIVAL_INT       INTEGER;
DEFINE V_AJUSTE_DE_CUOTA   VARCHAR(1);
DEFINE V_AJUSTE_VENC_INT   VARCHAR(1);
DEFINE V_AJUSTE_VENCIM     VARCHAR(1);
DEFINE V_CUOTA_CON_DEC     VARCHAR(1);
define vnum_solicitud      char(20);

DEFINE V_FECHA_INI         DATE;
DEFINE V_FECHA_INICIO      DATE;
DEFINE V_FECHA_FINAL       DATE;
DEFINE V_FECHA_PRORRATEO   DATE;
DEFINE V_FECHA_PRIMIN      DATE;
DEFINE V_DIA_CUOTA         INTEGER;
DEFINE V_DIA_CORTE         VARCHAR(5);
DEFINE V_RANGO_DIAS        INTEGER;

DEFINE V_NUM_PRODUCTO      VARCHAR(4);
DEFINE V_VALOR             VARCHAR(200);
DEFINE V_CADENA            VARCHAR(200);

let V_CADENA = "";
BEGIN


  --SELECCIONA LA FECHA DE HOY
  SELECT FECHA_HOY INTO V_FECHA_HOY FROM SD_FECHAS WHERE EMPRESA = P_EMPRESA;

let P_NUM_CREDITO = P_NUM_CREDITO;
let vnum_solicitud = P_NUM_CREDITO[1,11];
let V_DIA_CORTE = "";

  --SELECCIONA LOS DATOS DEL CREDITO
  SELECT MSDO.MONTO_OTORGADO,  SOL.PERIODO_PAG_CAP, SOL.PERIODO_PAG_INT, SOL.TIPO_CALCULO,
         SOL.SUCURSAL,         SOL.PERIODO_PLAZO,   SOL.PLAZO,           SOL.TP_GEN_PLANPAGO,
         SOL.GRACIA_CAP,       SOL.DIFERIMIENTO_INT, SOL.FECHA_APERT_PROP,SOL.FECHA_VENC_PROP,
         SOL.AJUSTE_DE_CUOTA,  SOL.AJUSTE_VENC_INT,  SOL.AJUSTE_VENCIM,  SOL.CUOTA_CON_DEC,
         PCAP.EQUIVALENCIA_DIAS PCAP,
         PINT.EQUIVALENCIA_DIAS PINT,
         SOL.NUM_PRODUCTO
  INTO   V_MONTO,              V_PERIODO_PAG_CAP,   V_PERIODO_PAG_INT,   V_TIPO_CALCULO,
         V_SUCURSAL,           V_PERIODO_PLAZO,     V_PLAZO,             V_TP_GEN_PLANPAGO,
         V_GRACIA_CAP,         V_DIFERIMIENTO_INT,  V_FECHA_INICIO,      V_FECHA_FINAL,
         V_AJUSTE_DE_CUOTA,    V_AJUSTE_VENC_INT,   V_AJUSTE_VENCIM,     V_CUOTA_CON_DEC,
         V_EQUIVAL_CAP,        V_EQUIVAL_INT,
         V_NUM_PRODUCTO
  FROM   BDISOLIC:SS_SOLICITUDES SOL, SD_CODPCAP PCAP, SD_CODPINT PINT, SD_MAESDOS MSDO
  WHERE  MSDO.NUM_CREDITO = P_NUM_CREDITO
  AND    MSDO.EMPRESA = SOL.EMPRESA
  AND    PINT.PERIOD_PAG_INT = SOL.PERIODO_PAG_INT
  AND    PINT.EMPRESA = SOL.EMPRESA
  AND    PCAP.PERIOD_PAGO_CAP = SOL.PERIODO_PAG_CAP
  AND    PCAP.EMPRESA = SOL.EMPRESA
  AND    SOL.EMPRESA = P_EMPRESA
  AND    SOL.NUM_SOLICITUD = vnum_solicitud;

LET V_TIPO_CALCULO = V_TIPO_CALCULO;

  --SE GENERA EL PLAN DE PAGOS CON LA FECHA DE APERTURA
  IF V_TP_GEN_PLANPAGO = '1' THEN
     IF V_FECHA_INICIO <  V_FECHA_HOY THEN
       LET V_FECHA_INICIO = V_FECHA_HOY;
     END IF;
  --SE GENERA EL PLAN DE PAGOS CON LA FECHA DE LA PRIMERA MINISTRACION
  ELSE

     SELECT MIN(FECHA_PROGRAMADA)
     INTO V_FECHA_INICIO
     FROM SD_DETMINIS
     WHERE NUM_CREDITO = P_NUM_CREDITO
     AND   EMPRESA = P_EMPRESA;

     IF V_FECHA_INICIO < V_FECHA_HOY  THEN
        LET V_FECHA_INICIO = V_FECHA_HOY;
     END IF;
  END IF;

  EXECUTE PROCEDURE SP_CALCULA_FECHA(P_EMPRESA,V_GRACIA_CAP,V_PERIODO_PLAZO,V_FECHA_INICIO
                                    ,'N', V_AJUSTE_VENC_INT)
               INTO P_COD_RET, P_MENSAJE, V_FECHA_PRORRATEO;

  IF V_FECHA_PRORRATEO > V_FECHA_INICIO THEN
     LET V_FECHA_INICIO = V_FECHA_PRORRATEO;
  ELSE
     LET V_FECHA_PRORRATEO = NULL;
  END IF;

  SELECT DIA_CUOTA
  INTO   V_DIA_CUOTA
  FROM   SD_DEFINICION
  WHERE  NUM_PRODUCTO = V_NUM_PRODUCTO
  AND    EMPRESA = P_EMPRESA;

  SELECT V_EQUIVAL_CAP*(VALOR/100)
  INTO   V_RANGO_DIAS
  FROM SD_PARAM
  WHERE COD_PARAM = '52'
  AND EMPRESA = P_EMPRESA;

  IF V_DIA_CUOTA > 0 AND V_DIA_CUOTA <= 28 THEN
    LET V_FECHA_INI = MDY(MONTH(V_FECHA_INICIO),V_DIA_CUOTA,YEAR(V_FECHA_INICIO));
    IF DAY(V_FECHA_INICIO) >= V_DIA_CUOTA THEN
      IF (V_FECHA_INI - V_FECHA_HOY) < V_RANGO_DIAS THEN
        LET V_FECHA_INI = V_FECHA_INI + 1 UNITS MONTH;
      END IF

      EXECUTE PROCEDURE SP_CALCULA_FECHA(P_EMPRESA,1,V_PERIODO_PLAZO,V_FECHA_INI
                                        ,'N', V_AJUSTE_VENC_INT)
                   INTO P_COD_RET, P_MENSAJE, V_FECHA_INICIO;
    ELSE
      IF (V_FECHA_INI - V_FECHA_INICIO) < V_RANGO_DIAS THEN
	LET V_FECHA_INI = V_FECHA_INI + 1 UNITS MONTH;
        EXECUTE PROCEDURE SP_CALCULA_FECHA(P_EMPRESA,1,V_PERIODO_PLAZO,
					   V_FECHA_INI, 'N', V_AJUSTE_VENC_INT)
                     INTO P_COD_RET, P_MENSAJE, V_FECHA_INICIO;
      ELSE
        LET V_FECHA_INICIO = V_FECHA_INI;
      END IF;
    END IF;
    LET V_DIA_CORTE = "50";
  ELIF V_DIA_CUOTA = 50 THEN
    IF (V_FECHA_INICIO - V_FECHA_HOY)  < V_RANGO_DIAS THEN
	--LET V_FECHA_INICIO = V_FECHA_INICIO + 1 UNITS MONTH;
       EXECUTE PROCEDURE SP_CALCULA_FECHA(P_EMPRESA,1,V_PERIODO_PLAZO,V_FECHA_INICIO
                                         ,'N', V_AJUSTE_VENC_INT)
                    INTO P_COD_RET, P_MENSAJE, V_FECHA_INICIO;
    END IF;
   LET V_DIA_CORTE = "50";
  ELIF V_DIA_CUOTA = 99 THEN
    IF MONTH(V_FECHA_INICIO) = 12 THEN
       LET V_FECHA_INI = MDY(12,31,YEAR(V_FECHA_INICIO));
    ELSE
       LET V_FECHA_INI = MDY(MONTH(V_FECHA_INICIO)+1,1,YEAR(V_FECHA_INICIO))-1;
    END IF;
    IF (V_FECHA_INI - V_FECHA_INICIO) < V_RANGO_DIAS THEN
       LET V_FECHA_INICIO = V_FECHA_INI;
       EXECUTE PROCEDURE SP_CALCULA_FECHA(P_EMPRESA,1,V_PERIODO_PLAZO,V_FECHA_INICIO
                                         ,'N', V_AJUSTE_VENC_INT)
                    INTO P_COD_RET, P_MENSAJE, V_FECHA_INICIO;
    ELSE
       LET V_FECHA_INICIO = V_FECHA_INI;
    END IF;
    LET V_DIA_CORTE = "99";
  ELIF V_DIA_CUOTA = 15 AND V_PERIODO_PLAZO = 'Q' THEN
    EXECUTE PROCEDURE SP_CALCULA_FECHA(P_EMPRESA,1,V_PERIODO_PLAZO,V_FECHA_INI
                                      ,'N', V_AJUSTE_VENC_INT)
                 INTO P_COD_RET, P_MENSAJE, V_FECHA_INICIO;
    LET V_DIA_CORTE ="50";
  END IF;


  --IF V_PERIODO_PAG_INT <> "1" THEN
       EXECUTE PROCEDURE SP_CALCULA_FECHA(P_EMPRESA,V_PLAZO-1,V_PERIODO_PLAZO,
					  V_FECHA_INICIO,'N',V_AJUSTE_VENC_INT)
                  INTO P_COD_RET, P_MENSAJE, V_FECHA_FINAL;
  --ELSE
  --     EXECUTE PROCEDURE SP_CALCULA_FECHA(P_EMPRESA,V_PLAZO,V_PERIODO_PLAZO,
--					  V_FECHA_INICIO,'N',V_AJUSTE_VENC_INT)
 --                 INTO P_COD_RET, P_MENSAJE, V_FECHA_FINAL;

  --END IF

  UPDATE sd_maecred SET fecha_vencim = V_FECHA_FINAL
   WHERE num_credito = P_NUM_CREDITO
     AND empresa = P_EMPRESA;

  EXECUTE PROCEDURE CAPITAL(P_EMPRESA
                              ,P_NUM_CREDITO
                              ,V_FECHA_INICIO
                              ,V_FECHA_FINAL
                              ,V_MONTO
                              ,V_PERIODO_PAG_CAP
                              ,V_CUOTA_CON_DEC
                              ,V_AJUSTE_VENCIM
                              ,V_AJUSTE_DE_CUOTA
                              ,V_AJUSTE_VENC_INT
                              ,V_DIA_CORTE
                              ,V_FECHA_PRORRATEO
                              )
                         INTO  P_COD_RET, P_MENSAJE;

     EXECUTE PROCEDURE INTERES(P_EMPRESA
                              ,P_NUM_CREDITO
                              ,V_FECHA_INICIO
                              ,V_FECHA_FINAL
                              ,V_MONTO
                              ,V_PERIODO_PAG_INT
                              ,V_CUOTA_CON_DEC
                              ,V_AJUSTE_VENC_INT
                              ,V_AJUSTE_DE_CUOTA
                              ,V_TIPO_CALCULO
                              ,V_DIA_CORTE
                              ,V_FECHA_PRORRATEO
                              )
                         INTO  P_COD_RET, P_MENSAJE;


  --VERIFICA QUE EL PRODUCTO NO SEA DE CONSTRUCCION
  SELECT ','||TRIM(VALOR)||','
  INTO   V_VALOR
  FROM   SD_PARAM
  WHERE  COD_PARAM = '53'
  AND    EMPRESA = P_EMPRESA;

  IF V_CADENA = V_VALOR THEN  --NO ES DE CONSTRUCCION
     EXECUTE PROCEDURE PAGOS_NIVELADOS (P_EMPRESA, P_NUM_CREDITO, V_FECHA_INICIO)
                                  INTO  P_COD_RET, P_MENSAJE;
  ELSE  --ES DE CONSTRUCCION
     DELETE FROM SD_PAGOCAPIT WHERE EMPRESA = P_EMPRESA AND NUM_CREDITO = P_NUM_CREDITO;
     UPDATE SD_MAECRED SET TIPO_CALCULO = '02' WHERE EMPRESA = P_EMPRESA AND NUM_CREDITO = P_NUM_CREDITO;
  END IF;

  RETURN P_COD_RET, P_MENSAJE;
END;
END PROCEDURE;