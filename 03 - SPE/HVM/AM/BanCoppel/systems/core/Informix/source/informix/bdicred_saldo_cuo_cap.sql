CREATE PROCEDURE "informix".saldo_cuo_cap()
       RETURNING CHAR(5), CHAR(20), MONEY(14,2), MONEY(14,2);


   DEFINE GLOBAL g_num_credito        CHAR(20)       DEFAULT " ";
   DEFINE GLOBAL g_tipo_calculo       CHAR(2)        DEFAULT " ";
   DEFINE GLOBAL g_mto_capitalizado   MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_mto_finan_vdo      MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_mto_fin_ven_tras   MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_empresa            CHAR(3)        DEFAULT " ";

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
   DEFINE v_codret           CHAR(5);
   DEFINE vt_sum_sdocuota    MONEY(14,2);
   DEFINE vt_sumcapitaliz    MONEY(14,2);
   DEFINE v_monto_finan      MONEY(14,2);
   DEFINE vt_sum_realpa      MONEY(14,2);
   DEFINE vt_pago_capzado    MONEY(14,2);
   DEFINE vt_pago_capital    MONEY(14,2);

   DEFINE sql_err            SMALLINT;
   DEFINE isam_err           SMALLINT;
   DEFINE error_info         CHAR(40);


   ON EXCEPTION SET sql_err, isam_err, error_info
      LET v_codret = sql_err;
      SET DEBUG FILE TO "Saldo_cuo_cap.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      RETURN v_codret, g_num_credito, v_monto, v_monto_finan;
   END EXCEPTION;

   --#################################################################
   --#####                INICIALIZACION DE VARIABLES            #####
   --#################################################################

   LET v_monto            = 0;
   LET v_codret           = "000";
   LET vt_sum_sdocuota    = 0;
   LET vt_sumcapitaliz    = 0;
   LET v_monto_finan      = 0;
   LET vt_sum_realpa      = 0;
   LET vt_pago_capital    = 0;

   
      IF gc_status_cuota = "1" THEN

         IF g_tipo_calculo = "04" THEN   -- SIMFAA
            LET v_monto            = 0;
            LET v_monto_finan      = 0;

            IF g_mto_capitalizado = 0 THEN
               LET v_monto    = gc_saldo_cuota + gc_imp_capzado  -
                                gc_monto_real_pag;
               LET v_monto_finan = g_mto_capitalizado;
            ELSE
               LET v_monto = gc_saldo_cuota + gc_imp_capzado -
                             g_mto_capitalizado - gc_monto_real_pag;
               LET v_monto_finan = g_mto_capitalizado;
            END IF;

         ELIF g_tipo_calculo = "05" THEN  --REFINANCIAMIENTO AUTOMATICO (SIREFA)
            LET v_monto            = 0;
            LET v_monto_finan      = 0;

            LET vt_sum_sdocuota    = 0 ;
            LET vt_sumcapitaliz    = 0 ;
            LET vt_sum_realpa      = 0;

            LET vt_pago_capzado    = 0;
            LET vt_pago_capital    = 0;

            SELECT SUM(saldo_cuota), SUM(imp_capitalizado), SUM(monto_real_pag)
            INTO vt_sum_sdocuota,  vt_sumcapitaliz, vt_sum_realpa
            FROM sd_pagocapit
            WHERE num_credito = gc_num_credito AND
                  empresa = g_empresa AND
                  status_cuota = "1";


            IF g_mto_capitalizado = vt_sumcapitaliz THEN
               -- no hay capitalizado pagado
               IF vt_sum_realpa > 0 THEN
                  LET v_monto          = gc_saldo_cuota - gc_monto_real_pag ;
                  LET v_monto_finan    = gc_imp_capzado ;
               ELSE
                  LET v_monto          = gc_saldo_cuota ;
                  LET v_monto_finan    = gc_imp_capzado ;
               END IF;
            ELSE
               -- Si hay capitalizado pagado
               LET vt_pago_capzado    = vt_sumcapitaliz  - g_mto_capitalizado;
               LET vt_pago_capital    = gc_monto_real_pag   - vt_pago_capzado ;

               IF gc_saldo_cuota >= vt_pago_capital THEN
                  LET v_monto          = gc_saldo_cuota      - vt_pago_capital;
               END IF;

               IF gc_imp_capzado >= vt_pago_capzado THEN
                  LET v_monto_finan    = gc_imp_capzado - vt_pago_capzado ;
               END IF ;
            END IF;

         ELIF g_tipo_calculo = "06" THEN  -- TASA EQUIVALENTE
            LET v_monto            = 0;
            LET v_monto_finan      = 0;

            IF g_mto_capitalizado = 0 THEN
               LET v_monto    = gc_saldo_cuota + gc_imp_capzado  -
                                gc_monto_real_pag;
               LET v_monto_finan = g_mto_capitalizado ;
            ELSE
               LET v_monto = gc_saldo_cuota + gc_imp_capzado -
                             g_mto_capitalizado - gc_monto_real_pag;
               LET v_monto_finan = g_mto_capitalizado;
            END IF;

         ELIF g_tipo_calculo = "07" THEN      -- VALOR PRESENTE
            LET v_monto            = 0;
            LET v_monto_finan      = 0;

            LET vt_sum_sdocuota    = 0 ;
            LET vt_sumcapitaliz    = 0 ;
            LET vt_sum_realpa      = 0;

            LET vt_pago_capzado    = 0;
            LET vt_pago_capital    = 0;

            SELECT SUM(saldo_cuota), SUM(imp_capitalizado), SUM(monto_real_pag)
            INTO vt_sum_sdocuota,  vt_sumcapitaliz, vt_sum_realpa
            FROM sd_pagocapit
            WHERE num_credito = gc_num_credito AND
                  empresa     = g_empresa  AND
                  status_cuota = "1";

            IF g_mto_capitalizado = vt_sumcapitaliz THEN
               -- no hay capitalizado pagado
               IF vt_sum_realpa > 0 THEN
                  LET v_monto          = gc_saldo_cuota - gc_monto_real_pag ;
                  LET v_monto_finan    = gc_imp_capzado ;
               ELSE
                  LET v_monto          = gc_saldo_cuota ;
                  LET v_monto_finan    = gc_imp_capzado ;
               END IF;
            ELSE
               -- Si hay capitalizado pagado
               LET vt_pago_capzado    = vt_sumcapitaliz  - g_mto_capitalizado;
               LET vt_pago_capital    = gc_monto_real_pag   - vt_pago_capzado ;

               IF gc_saldo_cuota >= vt_pago_capital THEN
                  LET v_monto          = gc_saldo_cuota      - vt_pago_capital;
               END IF;

               IF gc_imp_capzado >= vt_pago_capzado THEN
                  LET v_monto_finan    = gc_imp_capzado - vt_pago_capzado ;
               END IF ;
            END IF;

         ELSE
            LET v_monto         = 0;
            LET v_monto_finan   = 0;
            LET v_monto         =  gc_saldo_cuota - gc_monto_real_pag;
         END IF

      END IF;


      IF gc_status_cuota = "2" THEN

         IF g_tipo_calculo = "04" THEN   -- SIMFAA
            LET v_monto            = 0;
            LET v_monto_finan      = 0;

            IF g_mto_fin_ven_tras = 0 THEN
               LET v_monto    = gc_saldo_cuota + gc_imp_capzado  -
                                gc_monto_real_pag;
               LET v_monto_finan = g_mto_fin_ven_tras;
            ELSE
               LET v_monto = gc_saldo_cuota + gc_imp_capzado -
                             g_mto_fin_ven_tras - gc_monto_real_pag;
               LET v_monto_finan = g_mto_fin_ven_tras;
            END IF;

         ELIF g_tipo_calculo = "05" THEN  --REFINANCIAMIENTO AUTOMATICO (SIREFA)
            LET v_monto            = 0;
            LET v_monto_finan      = 0;

            LET vt_sum_sdocuota    = 0 ;
            LET vt_sumcapitaliz    = 0 ;
            LET vt_sum_realpa      = 0;

            LET vt_pago_capzado    = 0;
            LET vt_pago_capital    = 0;

            SELECT SUM(saldo_cuota), SUM(imp_capitalizado), SUM(monto_real_pag)
            INTO vt_sum_sdocuota,  vt_sumcapitaliz, vt_sum_realpa
            FROM sd_pagocapit
            WHERE num_credito = gc_num_credito AND
                  empresa = g_empresa AND
                  status_cuota = "2";


            IF g_mto_fin_ven_tras = vt_sumcapitaliz THEN
               -- no hay capitalizado pagado
               IF vt_sum_realpa > 0 THEN
                  LET v_monto          = gc_saldo_cuota - gc_monto_real_pag ;
                  LET v_monto_finan    = gc_imp_capzado ;
               ELSE
                  LET v_monto          = gc_saldo_cuota ;
                  LET v_monto_finan    = gc_imp_capzado ;
               END IF;
            ELSE
               -- Si hay capitalizado pagado
               LET vt_pago_capzado    = vt_sumcapitaliz  - g_mto_fin_ven_tras;
               LET vt_pago_capital    = gc_monto_real_pag   - vt_pago_capzado ;

               IF gc_saldo_cuota >= vt_pago_capital THEN
                  LET v_monto          = gc_saldo_cuota      - vt_pago_capital;
               END IF;

               IF gc_imp_capzado >= vt_pago_capzado THEN
                  LET v_monto_finan    = gc_imp_capzado - vt_pago_capzado ;
               END IF ;
            END IF;

         ELIF g_tipo_calculo = "06" THEN  -- TASA EQUIVALENTE
            LET v_monto            = 0;
            LET v_monto_finan      = 0;

            IF g_mto_fin_ven_tras = 0 THEN
               LET v_monto    = gc_saldo_cuota + gc_imp_capzado  -
                                gc_monto_real_pag;
               LET v_monto_finan = g_mto_fin_ven_tras ;
            ELSE
               LET v_monto = gc_saldo_cuota + gc_imp_capzado -
                             g_mto_fin_ven_tras - gc_monto_real_pag;
               LET v_monto_finan = g_mto_fin_ven_tras;
            END IF;

         ELIF g_tipo_calculo = "07" THEN      -- VALOR PRESENTE
            LET v_monto            = 0;
            LET v_monto_finan      = 0;

            LET vt_sum_sdocuota    = 0 ;
            LET vt_sumcapitaliz    = 0 ;
            LET vt_sum_realpa      = 0;

            LET vt_pago_capzado    = 0;
            LET vt_pago_capital    = 0;

            SELECT SUM(saldo_cuota), SUM(imp_capitalizado), SUM(monto_real_pag)
            INTO vt_sum_sdocuota,  vt_sumcapitaliz, vt_sum_realpa
            FROM sd_pagocapit
            WHERE num_credito = gc_num_credito AND
                  empresa = g_empresa AND
                  status_cuota = "2";

            IF g_mto_fin_ven_tras = vt_sumcapitaliz THEN
               -- no hay capitalizado pagado
               IF vt_sum_realpa > 0 THEN
                  LET v_monto          = gc_saldo_cuota - gc_monto_real_pag ;
                  LET v_monto_finan    = gc_imp_capzado ;
               ELSE
                  LET v_monto          = gc_saldo_cuota ;
                  LET v_monto_finan    = gc_imp_capzado ;
               END IF;
            ELSE
               -- Si hay capitalizado pagado
               LET vt_pago_capzado    = vt_sumcapitaliz  - g_mto_fin_ven_tras;
               LET vt_pago_capital    = gc_monto_real_pag   - vt_pago_capzado ;

               IF gc_saldo_cuota >= vt_pago_capital THEN
                  LET v_monto          = gc_saldo_cuota      - vt_pago_capital;
               END IF;

               IF gc_imp_capzado >= vt_pago_capzado THEN
                  LET v_monto_finan    = gc_imp_capzado - vt_pago_capzado ;
               END IF ;
            END IF;

         ELSE
            LET v_monto            = 0;
            LET v_monto_finan      = 0;

            LET v_monto         =  gc_saldo_cuota - gc_monto_real_pag;
         END IF

      END IF;



      IF gc_status_cuota = "7" THEN


               IF g_tipo_calculo = "04" THEN   -- SIMFAA
                  LET v_monto            = 0;
                  LET v_monto_finan      = 0;

                  IF g_mto_finan_vdo = 0 THEN
                     LET v_monto    = gc_saldo_cuota + gc_imp_capzado  -
                                      gc_monto_real_pag;
                     LET v_monto_finan = g_mto_finan_vdo ;
                  ELSE
                     LET v_monto = gc_saldo_cuota + gc_imp_capzado -
                                   g_mto_finan_vdo - gc_monto_real_pag;
                     LET v_monto_finan = g_mto_finan_vdo;
                  END IF;

               ELIF g_tipo_calculo = "05"  THEN  -- REFINAN AUTOMATICO (SIREFA)
                  LET v_monto            = 0;
                  LET v_monto_finan      = 0;

                  LET vt_sum_sdocuota    = 0 ;
                  LET vt_sumcapitaliz    = 0 ;
                  LET vt_sum_realpa      = 0;

                  LET vt_pago_capzado    = 0;
                  LET vt_pago_capital    = 0;

                  SELECT SUM(saldo_cuota),
                         SUM(imp_capitalizado),
                         SUM(monto_real_pag)
                  INTO vt_sum_sdocuota,  vt_sumcapitaliz, vt_sum_realpa
                  FROM sd_pagocapit
                  WHERE num_credito = gc_num_credito AND
                  empresa = g_empresa AND
                        status_cuota = "7";

                  IF g_mto_finan_vdo = vt_sumcapitaliz THEN
                     -- no hay capitalizado pagado
                     IF vt_sum_realpa > 0 THEN
                        LET v_monto   = gc_saldo_cuota - gc_monto_real_pag ;
                        LET v_monto_finan    = gc_imp_capzado ;
                     ELSE
                        LET v_monto          = gc_saldo_cuota ;
                        LET v_monto_finan    = gc_imp_capzado ;
                     END IF;
                  ELSE
                     -- Si hay capitalizado pagado
                     LET vt_pago_capzado = vt_sumcapitaliz -
                                           g_mto_finan_vdo;
                     LET vt_pago_capital = gc_monto_real_pag -
                                           vt_pago_capzado ;

                     IF gc_saldo_cuota >= vt_pago_capital THEN
                        LET v_monto = gc_saldo_cuota      - vt_pago_capital;
                     END IF;

                     IF gc_imp_capzado >= vt_pago_capzado THEN
                        LET v_monto_finan  = gc_imp_capzado -
                                             vt_pago_capzado ;
                     END IF ;
                  END IF;

               ELIF g_tipo_calculo = "06" THEN -- TASA EQUIVALENTE

                  LET v_monto            = 0;
                  LET v_monto_finan      = 0;

                  IF g_mto_finan_vdo = 0 THEN
                     LET v_monto    = gc_saldo_cuota + gc_imp_capzado  -
                                      gc_monto_real_pag;
                     LET v_monto_finan = g_mto_finan_vdo ;
                  ELSE
                     LET v_monto = gc_saldo_cuota + gc_imp_capzado -
                                   g_mto_finan_vdo - gc_monto_real_pag;
                     LET v_monto_finan = g_mto_finan_vdo;
                  END IF;

               ELIF g_tipo_calculo = "07"  THEN     -- VALOR PRESENTE
                  LET v_monto            = 0;
                  LET v_monto_finan      = 0;

                  LET vt_sum_sdocuota    = 0 ;
                  LET vt_sumcapitaliz    = 0 ;
                  LET vt_sum_realpa      = 0;

                  LET vt_pago_capzado    = 0;
                  LET vt_pago_capital    = 0;

                  SELECT SUM(saldo_cuota),
                         SUM(imp_capitalizado),
                         SUM(monto_real_pag)
                  INTO vt_sum_sdocuota,  vt_sumcapitaliz, vt_sum_realpa
                  FROM sd_pagocapit
                  WHERE num_credito = gc_num_credito AND
                  empresa = g_empresa AND
                        status_cuota = "7";

                  IF g_mto_finan_vdo = vt_sumcapitaliz THEN
                     -- no hay capitalizado pagado
                     IF vt_sum_realpa > 0 THEN
                        LET v_monto   = gc_saldo_cuota - gc_monto_real_pag ;
                        LET v_monto_finan    = gc_imp_capzado ;
                     ELSE
                        LET v_monto          = gc_saldo_cuota ;
                        LET v_monto_finan    = gc_imp_capzado ;
                     END IF;
                  ELSE
                     -- Si hay capitalizado pagado
                     LET vt_pago_capzado    = vt_sumcapitaliz  -
                                              g_mto_finan_vdo;
                     LET vt_pago_capital    = gc_monto_real_pag   -
                                              vt_pago_capzado ;

                     IF gc_saldo_cuota >= vt_pago_capital THEN
                        LET v_monto  = gc_saldo_cuota      - vt_pago_capital;
                     END IF;

                     IF gc_imp_capzado >= vt_pago_capzado THEN
                        LET v_monto_finan   = gc_imp_capzado -
                                              vt_pago_capzado ;
                     END IF ;
                  END IF;

               ELSE
                  LET v_monto         = 0;
                  LET v_monto_finan   = 0;
                  LET v_monto         = gc_saldo_cuota - gc_monto_real_pag;
               END IF;


      END IF;

   RETURN v_codret, g_num_credito, v_monto, v_monto_finan;

END PROCEDURE

DOCUMENT
"base de datos : bdicred",
"AUTOR : Jose Cruz Narvaez Guzman",
"FECHA : 23/abril/2001",
"Ver.  : 1.0",
"Mod   : ";

CREATE PROCEDURE "informix".sp_provision_intereses(P_EMPRESA            VARCHAR(3)
                                       ,P_NUM_CREDITO        VARCHAR(20)
                                       ,P_MONTO              INTEGER
                                       ,P_FECHA_HOY          DATE
                                       ,P_FECHA_BANCO        DATE
                                       )RETURNING VARCHAR(10), VARCHAR(80);

DEFINE P_COD_RET       VARCHAR(10);
DEFINE P_MENSAJE       VARCHAR(80);

DEFINE SQL_ERR         INTEGER;
DEFINE ISAM_ERR        INTEGER;
DEFINE ERROR_INFO      VARCHAR(80);

DEFINE V_NUMREG        INTEGER;
DEFINE V_MONTO         INTEGER;
DEFINE V_PRODUCTO      VARCHAR(4);
DEFINE V_REFERENCIA    INTEGER;
DEFINE V_FUNCION       VARCHAR(3);
DEFINE V_FOLIO         VARCHAR(200);
DEFINE V_TRANSACC_SUC  VARCHAR(4);  -- := '0000';
DEFINE V_DIAS_ANUALES  INTEGER;
DEFINE V_PARTICIP      INTEGER;
DEFINE V_CONTADOR      INTEGER;      --:=0;
DEFINE VC_CONTADOR     VARCHAR(20);

DEFINE V_INTERES            DECIMAL(18,2);
DEFINE V_PRORRATEO          VARCHAR(1);
DEFINE V_FECHA_PRORRATEO    DATE;
DEFINE V_NUM_PRODUCTO       VARCHAR(10);
DEFINE V_DIVISA             VARCHAR(5);
DEFINE V_SUCURSAL           VARCHAR(5);
DEFINE V_VALOR              VARCHAR(5);
DEFINE V_NUM_DIAS           INTEGER;

DEFINE VPORCENT_PART    LIKE SD_FUENTES_X_CRED.PORCENT_PART;
DEFINE VTASA_FONDO      LIKE SD_FUENTES_X_CRED.TASA_FONDO;
DEFINE VCODIGO_REF      LIKE SD_TRANSFUN.CODIGO_REF;
DEFINE VCODIGO_INS      LIKE SD_FUENTES_X_CRED.CODIGO_INS;

DEFINE VV_FECHA_CUOTA  DATE;

BEGIN

   LET P_COD_RET      = '00000';
   LET P_MENSAJE      = 'PROCESO EXITOSO';
   LET V_TRANSACC_SUC = '0000';
   LET V_CONTADOR     = 0;
   LET V_NUM_DIAS     = 0;
   LET VC_CONTADOR    = '';

   FOREACH C1 FOR   SELECT P_MONTO * ((M.TASA_INTERES/100)/P.VALOR) INTERESES  --* (P_FECHA_HOY-P_FECHA_BANCO) 
                      ,NVL(FECHA_FIN_PRORRATEO,'') FECHA_PRORRATEO
                      ,M.NUM_PRODUCTO
                      ,M.DIVISA
                      ,M.SUCURSAL
                      ,P.VALOR
                      ,P_FECHA_HOY-P_FECHA_BANCO NUM_DIAS
                INTO   V_INTERES
                      ,V_FECHA_PRORRATEO
                      ,V_PRODUCTO
                      ,V_DIVISA
                      ,V_SUCURSAL
                      ,V_DIAS_ANUALES
                      ,V_NUM_DIAS
                FROM   SD_MAECRED M
                      ,SD_PARAM   P
                WHERE  P.EMPRESA     = M.EMPRESA
                AND    P.COD_PARAM   = '24'
                AND    M.EMPRESA     = P_EMPRESA
                AND    M.NUM_CREDITO = P_NUM_CREDITO


	LET V_FOLIO    = USER || REPLACE(REPLACE(EXTEND (CURRENT HOUR TO FRACTION(3)),':',''),'.','');
      
      IF (P_FECHA_HOY - P_FECHA_BANCO) > 0 THEN
         LET V_INTERES = V_INTERES * (P_FECHA_HOY - P_FECHA_BANCO) ;
      END IF;

      IF (V_FECHA_PRORRATEO - P_FECHA_HOY) > 0 THEN
         LET V_PRORRATEO = 'S'; 
      ELSE   
         LET V_PRORRATEO = 'N'; 
      END IF;

      IF V_PRORRATEO = 'S' THEN
	    --SE PRORRATEAN LOS INTERESES
         LET V_FUNCION = '608';

         SELECT COUNT(*)
         INTO   V_NUMREG
         FROM   SD_PAGINTER
         WHERE  FECHA_CUOTA <= V_FECHA_PRORRATEO
         AND    EMPRESA      = P_EMPRESA
         AND    NUM_CREDITO  = P_NUM_CREDITO;

         IF V_NUMREG > 0 THEN
            LET V_MONTO = V_INTERES / V_NUMREG;
         ELSE
            LET V_MONTO = 0;
         END IF;

         UPDATE SD_PAGINTER
         SET    MONTO_CUOTA  = MONTO_CUOTA + V_MONTO
         WHERE  FECHA_CUOTA <= V_FECHA_PRORRATEO
         AND    EMPRESA      = P_EMPRESA
         AND    NUM_CREDITO  = P_NUM_CREDITO;

      ELSE
	   --LOS INTERESES SE APLICAN A LA SIGUIENTE CUOTA
         LET V_MONTO = V_INTERES;
         LET V_FUNCION = '609'; 
         
         SELECT MIN(PIN2.FECHA_CUOTA)
         INTO   VV_FECHA_CUOTA
         FROM   SD_PAGINTER PIN2
         WHERE  STATUS_CUOTA     = 1
         AND    PIN2.EMPRESA     = P_EMPRESA
         AND    PIN2.NUM_CREDITO = P_NUM_CREDITO;


         UPDATE SD_PAGINTER 
         SET    MONTO_CUOTA  = MONTO_CUOTA + V_MONTO
         WHERE  FECHA_CUOTA  = VV_FECHA_CUOTA
         AND    EMPRESA      = P_EMPRESA
         AND    NUM_CREDITO  = P_NUM_CREDITO;
      END IF;
   END FOREACH;

   --SE ACTULIZA EL SALDO EN MAESDOS
   UPDATE SD_MAESDOS
   SET    SDO_NO_EXIG = SDO_NO_EXIG + V_MONTO
   WHERE  EMPRESA     = P_EMPRESA
   AND    NUM_CREDITO = P_NUM_CREDITO;

   --SE GENERA EL MOVIMIENTO CONTABLE
   SELECT MAX(CODIGO_REF)
   INTO   V_REFERENCIA
   FROM   SD_TRANSFUN
   WHERE  EMPRESA    = P_EMPRESA
   AND    CODIGO_FUN = V_FUNCION
   AND    CODIGO_INS = (SELECT VALOR
                        FROM   SD_PARAM
                        WHERE  EMPRESA = P_EMPRESA
                        AND    COD_PARAM  = '40');

   LET V_FUNCION = '606';
   IF V_MONTO > 0 THEN
      EXECUTE PROCEDURE GENMOV(P_EMPRESA, P_NUM_CREDITO,V_PRODUCTO, V_REFERENCIA, V_FUNCION, P_FECHA_HOY,
                               P_MONTO, V_FOLIO, V_SUCURSAL, V_DIVISA, V_TRANSACC_SUC
                              ) INTO P_COD_RET, P_MENSAJE;
   END IF;

   IF P_COD_RET = '00000' THEN

      FOREACH V_REG2 FOR  SELECT F.PORCENT_PART, F.TASA_FONDO, T.CODIGO_REF, F.CODIGO_INS
                          INTO   VPORCENT_PART
                                ,VTASA_FONDO
                                ,VCODIGO_REF
                                ,VCODIGO_INS
                          FROM   SD_FUENTES_X_CRED F,
                                 OUTER SD_TRANSFUN T
                          WHERE  F.EMPRESA        = T.EMPRESA
                          AND    F.CODIGO_INS     = T.CODIGO_INS
                          AND    F.EMPRESA        = P_EMPRESA
                          AND    F.NUM_CREDITO    = P_NUM_CREDITO
                          AND    T.CODIGO_FUN     = V_FUNCION
                          AND    F.INDIC_PROPIO  != 1

         IF VCODIGO_REF IS NULL THEN
            LET P_COD_RET = '00001';
            LET P_MENSAJE = 'CODIGO DE REFERENCIA NULO'; 
            RETURN P_COD_RET, P_MENSAJE;
         ELSE
            LET V_MONTO    = P_MONTO * (VPORCENT_PART / 100);
            LET V_PARTICIP = V_MONTO * V_NUM_DIAS * (VTASA_FONDO / 100) / V_DIAS_ANUALES;
            LET V_CONTADOR = V_CONTADOR + 1;
            LET VC_CONTADOR = V_CONTADOR;

            WHILE LENGTH(VC_CONTADOR) < 8 
               LET VC_CONTADOR = '0' || VC_CONTADOR;
            END WHILE;            

            LET V_FOLIO    = USER || VC_CONTADOR;  --LTRIM(TO_CHAR(V_CONTADOR, '00000000'));
            IF V_PARTICIP > 0 THEN
               LET V_FUNCION = '609';
               EXECUTE PROCEDURE GENMOV(P_EMPRESA, P_NUM_CREDITO, V_PRODUCTO, VCODIGO_REF,V_FUNCION,
                                        P_FECHA_HOY, V_PARTICIP, V_FOLIO, V_SUCURSAL, V_DIVISA, V_TRANSACC_SUC
                                       ) INTO P_COD_RET, P_MENSAJE;

            END IF;

            IF P_COD_RET <> '00000' THEN	
               RETURN P_COD_RET, P_MENSAJE;
            END IF;

            UPDATE SD_FUENTES_X_CRED
            SET    INTERESES_CALCULADOS = NVL(INTERESES_CALCULADOS,0) + V_PARTICIP
            WHERE  EMPRESA     = P_EMPRESA
            AND    NUM_CREDITO = P_NUM_CREDITO
            AND    CODIGO_INS  = VCODIGO_INS;

         END IF;
      END FOREACH;
   END IF; 
   RETURN P_COD_RET, P_MENSAJE;
END;
END PROCEDURE;