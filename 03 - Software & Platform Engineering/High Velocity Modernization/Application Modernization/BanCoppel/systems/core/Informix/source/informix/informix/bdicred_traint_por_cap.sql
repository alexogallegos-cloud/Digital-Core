CREATE PROCEDURE "informix".traint_por_cap(p_fecha_proceso DATE)
       RETURNING CHAR(5);


   DEFINE GLOBAL g_num_credito        CHAR(20)       DEFAULT " ";
   DEFINE GLOBAL g_divisa             CHAR(2)        DEFAULT " ";
   DEFINE GLOBAL g_num_producto       CHAR(4)        DEFAULT " ";
   DEFINE GLOBAL g_sucursal           CHAR(4)        DEFAULT " ";
   DEFINE GLOBAL g_campo_trab3        CHAR(10)       DEFAULT " ";
   DEFINE GLOBAL g_sdo_no_exig        MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_mto_venc_int       MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_sdo_exig_int       MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_mto_venc_tra_int   MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_provi_venc_nor     MONEY(14,2)    DEFAULT 0;

   DEFINE GLOBAL  gi_num_credito      CHAR(20)       DEFAULT " ";
   DEFINE GLOBAL  gi_fecha_cuota      DATE           DEFAULT " ";
   DEFINE GLOBAL  gi_cuota_rec        CHAR(1)        DEFAULT " ";
   DEFINE GLOBAL  gi_num_cuota        SMALLINT       DEFAULT 0;
   DEFINE GLOBAL  gi_monto_cuota      MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL  gi_monto_real_pag   MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL  gi_fecha_pag        DATE           DEFAULT " ";
   DEFINE GLOBAL  gi_porc_pago        DECIMAL(14,2)  DEFAULT 0;
   DEFINE GLOBAL  gi_status_cuota     CHAR(1)        DEFAULT " ";
   DEFINE GLOBAL  gi_monto_financia   MONEY(14,2)    DEFAULT 0;

   DEFINE GLOBAL g_codigo_fun         CHAR(3)        DEFAULT "034";
   DEFINE GLOBAL g_fecha_hoy          DATE           DEFAULT " ";

   DEFINE GLOBAL g_empresa         CHAR(3)        DEFAULT " ";
   DEFINE GLOBAL g_mensaje         CHAR(3)       DEFAULT " ";

   DEFINE v_monto            MONEY(14,2);
   DEFINE v_codigo_ref       SMALLINT;
   DEFINE v_transacc_suc     CHAR(4);
   DEFINE v_codret           CHAR(5);
   DEFINE co                 SMALLINT;
   DEFINE wmonto_interes     MONEY(14,2);
   DEFINE v_nocuotas_en_7    SMALLINT;
   DEFINE vt_cont_cuotas     SMALLINT;
   DEFINE v_num_cuota        SMALLINT;
   DEFINE v_folio_suc        CHAR(16);
   DEFINE v_usuario          CHAR(8);
   DEFINE v_hora             DATETIME HOUR TO FRACTION(3);
   DEFINE v_hora_c1          CHAR(12);
   DEFINE v_hora_c2          CHAR(8);

   DEFINE sql_err            SMALLINT;
   DEFINE isam_err           SMALLINT;
   DEFINE error_info         CHAR(40);


   ON EXCEPTION SET sql_err, isam_err, error_info
      LET v_codret = sql_err;
      SET DEBUG FILE TO "TraInt_por_Cap.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      RETURN v_codret;
   END EXCEPTION;



   --#################################################################
   --#####                INICIALIZACION DE VARIABLES            #####
   --#################################################################
   LET v_monto          = 0;
   LET v_codigo_ref     = 0;
   LET v_transacc_suc   = "0000";
   LET v_codret         = "000";
   LET co               = 0 ;
   LET wmonto_interes   = 0;
   LET v_nocuotas_en_7  = 0;
   LET vt_cont_cuotas   = 0;
   LET v_num_cuota      = 0;
   LET v_folio_suc      = "               ";
   LET v_usuario        = USER;
   LET v_hora           = CURRENT HOUR TO FRACTION;
   LET v_hora_c1        = v_hora;
   LET v_hora_c2        = v_hora_c1;
   LET v_folio_suc      = TRIM(v_usuario) || TRIM(v_hora_c2);



   FOREACH

      SELECT num_credito,      fecha_cuota,
             cuota_rec,        num_cuota,
             monto_cuota,      monto_real_pag,
             fecha_pag,        porc_pago,
             status_cuota,     monto_financiado
      INTO   gi_num_credito,   gi_fecha_cuota,
             gi_cuota_rec,     gi_num_cuota,
             gi_monto_cuota,   gi_monto_real_pag,
             gi_fecha_pag,     gi_porc_pago,
             gi_status_cuota,  gi_monto_financia
      FROM   sd_paginter
      WHERE  monto_cuota        > 0

      AND   ((fecha_cuota       <= p_fecha_proceso
            AND    status_cuota       IN ("1","7"))
      OR     (fecha_cuota       >  p_fecha_proceso
            AND    status_cuota       IN ("1")))
      AND    num_credito        = g_num_credito
      AND  empresa = g_empresa
      ORDER BY fecha_cuota ASC

      IF v_nocuotas_en_7 = 1 THEN
         UPDATE sd_maecred
         SET campo_trab3 = "E"
         WHERE num_credito    = gi_num_credito 
         AND empresa = g_empresa;
         LET g_campo_trab3 = "E";
         EXIT FOREACH;
      END IF;

      LET v_monto         = 0;
      LET v_monto         =  gi_monto_cuota - gi_monto_real_pag;

      --================================================================
      --=== TRASPASO DE INTERES A VENCIDO TRASPASADO status de 1 a 2 ===
      --================================================================
      IF gi_status_cuota = "1" THEN
         IF gi_fecha_cuota <= p_fecha_proceso  THEN
            LET v_transacc_suc     = "3i12";

            UPDATE sd_paginter
            SET  status_cuota     = "2"
            WHERE fecha_cuota = gi_fecha_cuota AND
                  num_cuota   = gi_num_cuota AND
                  num_credito = gi_num_credito AND
                  empresa     = g_empresa;
   
            UPDATE sd_maesdos
            SET sdo_no_exig       = sdo_no_exig       - v_monto,
                sdo_exig_int      = sdo_exig_int      + v_monto,
                mto_venc_tra_int  = mto_venc_tra_int  + v_monto
            WHERE num_credito    = gi_num_credito
             AND  empresa     = g_empresa;
  
            LET g_sdo_no_exig       = g_sdo_no_exig      - v_monto;
            LET g_sdo_exig_int      = g_sdo_exig_int     + v_monto;
            LET g_mto_venc_tra_int  = g_mto_venc_tra_int + v_monto;
 
            IF (gi_cuota_rec = "6") OR (gi_cuota_rec = "8") THEN
               LET v_codigo_ref = 85;  -- traspaso int. prop/reno
                                       -- a vdo.exigible
                                       -- 6665
            ELSE
               LET v_codigo_ref = 16;  -- traspaso int. vig. a vdo.exigible
                                       -- 6665
            END IF;
   
            IF v_monto != 0 THEN
               CALL genmov(g_empresa, gi_num_credito,  g_num_producto,
                        v_codigo_ref,       g_codigo_fun,
                        g_fecha_hoy,        v_monto,       v_folio_suc,
                        g_sucursal,         g_divisa,      v_transacc_suc)
               RETURNING v_codret, g_mensaje;
            END IF;
 
         ELSE

            UPDATE sd_maesdos
            SET provi_venc_normal = sdo_no_exig  
            WHERE num_credito     = gi_num_credito
             AND  empresa     = g_empresa;
           
            LET g_provi_venc_nor = g_sdo_no_exig;

            LET v_monto         = 0;
            LET v_monto         =  gi_monto_cuota - gi_monto_real_pag;

            LET v_transacc_suc  = "3i22";
            IF (gi_cuota_rec = "6") OR (gi_cuota_rec = "8") THEN
               LET v_codigo_ref = 97;  -- traspaso int. prop/reno
                                       -- a vdo.exigible
                                       -- 6665 revisar
            ELSE
               LET v_codigo_ref = 98;  -- traspaso int. vig. a vdo.exigible
                                       -- 6665 revisar
            END IF;

            IF v_monto != 0 THEN
               CALL genmov(g_empresa, gi_num_credito,   g_num_producto,
                        v_codigo_ref,       g_codigo_fun,
                        g_fecha_hoy,        v_monto,       v_folio_suc,
                        g_sucursal,         g_divisa,      v_transacc_suc)
               RETURNING v_codret, g_mensaje;
            END IF;


            LET v_nocuotas_en_7    = 1; 

         END IF;
      END IF;


      --===================================================================
      --#### TRASPASO DE INTERES A VENCIDO TRASPASADO  status de 7 a 2 ####
      --===================================================================
      IF gi_status_cuota = "7" THEN

         LET v_monto         = 0;
         LET v_monto         = gi_monto_cuota - gi_monto_real_pag;

         UPDATE sd_paginter
         SET  status_cuota     = "2"
         WHERE fecha_cuota = gi_fecha_cuota AND
               num_cuota   = gi_num_cuota AND
               num_credito = gi_num_credito 
           AND empresa = g_empresa;

         UPDATE sd_maesdos
         SET mto_venc_int      = mto_venc_int     - v_monto,
             mto_venc_tra_int  = mto_venc_tra_int + v_monto
         WHERE num_credito    = gi_num_credito
           AND empresa = g_empresa;

         LET g_mto_venc_int      = g_mto_venc_int     - v_monto;
         LET g_mto_venc_tra_int  = g_mto_venc_tra_int + v_monto;

         LET v_transacc_suc  = "3i72";

         IF (gi_cuota_rec = "6") OR (gi_cuota_rec = "8") THEN
            LET v_codigo_ref = 7; --traspaso int pro/ren vdo.transitorio a
                                  --vencido contabilizado 6662
         ELSE
            LET v_codigo_ref = 6; --traspaso int vdo.transitorio a vencido
                                  -- 6662
         END IF;

         IF v_monto != 0 THEN
            CALL genmov(g_empresa, gi_num_credito,  g_num_producto,
                        v_codigo_ref,    g_codigo_fun,
                        g_fecha_hoy,     v_monto,       v_folio_suc,
                        g_sucursal,      g_divisa,      v_transacc_suc)
            RETURNING v_codret, g_mensaje;
         END IF;

      END IF;


   END FOREACH;


   RETURN v_codret;


END PROCEDURE
DOCUMENT
"Esta funcion realiza el traspaso de interes a interes vencido",
"AUTOR : Jose Cruz narvaez",
"FECHA : 2/Mayo/2001",
"Ver.  : 1.0",
"BD    : bdicred",
"Mod   : ";

CREATE PROCEDURE "informix".tracap_por_int(p_fecha_proceso DATE)
       RETURNING CHAR(5);

   DEFINE GLOBAL g_num_credito        CHAR(20)       DEFAULT " ";
   DEFINE GLOBAL g_divisa             CHAR(2)        DEFAULT " ";
   DEFINE GLOBAL g_num_producto       CHAR(4)        DEFAULT " ";
   DEFINE GLOBAL g_sucursal           CHAR(4)        DEFAULT " ";
   DEFINE GLOBAL g_sdo_capital        MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_mto_capitalizado   MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_monto_vencido      MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_mto_finan_vdo      MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_cap_tras_no_venc   MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_mto_venc_trasp     MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_mto_fin_ven_tras   MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_mto_fin_vig_tras   MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_campo_trab3        CHAR(10)       DEFAULT " ";

   DEFINE GLOBAL g_codigo_fun         CHAR(3)        DEFAULT "034";
   DEFINE GLOBAL g_fecha_hoy          DATE           DEFAULT " ";

   DEFINE GLOBAL g_empresa         CHAR(3)        DEFAULT " ";
   DEFINE GLOBAL g_mensaje         CHAR(3)       DEFAULT " ";


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

   DEFINE v_codret           CHAR(5);
   DEFINE v_monto            MONEY(14,2);
   DEFINE v_monto_tot        MONEY(14,2);
   DEFINE v_codigo_ref       SMALLINT;
   DEFINE v_transacc_suc     CHAR(4);
   DEFINE v_monto_finan      MONEY(14,2);

   DEFINE v_cartera_asoc     SMALLINT;
   DEFINE vt_monto_asocia    MONEY(14,2);
   DEFINE vt_monto_aso_cap   MONEY(14,2);
   DEFINE vt_monto_aso_fin   MONEY(14,2);
   DEFINE v_nocuotas_en_7    SMALLINT;
   DEFINE vt_cont_cuotas     SMALLINT;
   DEFINE wnum_cred_ant      SMALLINT;
   DEFINE wnum_cred_fut      SMALLINT;

   DEFINE v_num_cuota        SMALLINT;
   DEFINE v_folio_suc        CHAR(16);
   DEFINE v_usuario          CHAR(8);
   DEFINE v_hora             DATETIME HOUR TO FRACTION(3);
   DEFINE v_hora_c1          CHAR(12);
   DEFINE v_hora_c2          CHAR(8);

   DEFINE sql_err            SMALLINT;
   DEFINE isam_err           SMALLINT;
   DEFINE error_info         CHAR(40);

   DEFINE v_codigo_fun       CHAR(3);

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET v_codret = sql_err;
      SET DEBUG FILE TO "TraCap_por_Int.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      RETURN v_codret;
   END EXCEPTION;


   --#################################################################
   --#####                INICIALIZACION DE VARIABLES            #####
   --#################################################################
   LET v_monto            = 0;
   LET v_monto_tot        = 0;
   LET v_codigo_ref       = 0;
   LET v_transacc_suc     = "0000";
   LET v_codret           = "000";
   LET v_monto_finan      = 0;
   LET vt_monto_asocia    = 0;
   LET vt_monto_aso_cap   = 0;
   LET vt_monto_aso_fin   = 0;
   LET v_nocuotas_en_7    = 0;
   LET vt_cont_cuotas     = 0;
   LET wnum_cred_ant      = 0;
   LET wnum_cred_fut      = 0;
   LET v_cartera_asoc     = 0;
   LET v_num_cuota        = 0;
   LET v_folio_suc         = "               ";

   LET v_usuario      = USER;
   LET v_hora         = CURRENT HOUR TO FRACTION;
   LET v_hora_c1      = v_hora;
   LET v_hora_c2      = v_hora_c1;
   LET v_folio_suc    = TRIM(v_usuario) || TRIM(v_hora_c2);

   LET v_codigo_fun   = "039";




   FOREACH

      SELECT num_credito,        fecha_cuota,
             cuota_rec,      
             monto_cuota,        saldo_cuota,
             imp_capitalizado,   monto_real_pag,
             fecha_pago,         porc_pago,
             bandera_ministra,   status_cuota
      INTO
           gc_num_credito,      gc_fecha_cuota,
           gc_cuota_rec,    
           gc_monto_cuota,      gc_saldo_cuota,
           gc_imp_capzado,      gc_monto_real_pag,
           gc_fecha_pago,       gc_porc_pago,
           gc_bandera_minis,    gc_status_cuota

      FROM   sd_pagocapit
      WHERE  bandera_ministra   = "A"
      AND   ((fecha_cuota       <= p_fecha_proceso
             AND    status_cuota IN ("1","7"))
      OR     (fecha_cuota        > p_fecha_proceso
             AND    status_cuota IN ("1")))
      AND   num_credito  = g_num_credito
      AND empresa = g_empresa
      ORDER BY fecha_cuota ASC


   IF v_nocuotas_en_7 = 1 THEN
      UPDATE sd_maecred
      SET campo_trab3 = "E"
      WHERE num_credito    = gc_num_credito
      AND empresa = g_empresa;
      LET g_campo_trab3 = "E";
      EXIT FOREACH;
   END IF;

   --===================================================================
   --=== TRASPASO DE CAPITAL A VENCIDO NO TRASPASADO status de 1 a 7 ===
   --===================================================================
   IF gc_status_cuota = "1" THEN

      IF gc_fecha_cuota <= p_fecha_proceso  THEN
         LET v_monto = 0;
         LET v_monto_finan = 0;

         CALL Saldo_cuo_cap()
         RETURNING v_codret, g_num_credito, v_monto, v_monto_finan;

         LET v_transacc_suc     = "3c12";

         UPDATE sd_pagocapit
         SET  status_cuota     = "2" ,
              status_moratorio = "2"
         WHERE fecha_cuota = gc_fecha_cuota AND
               num_credito = gc_num_credito 
            AND empresa = g_empresa;

         UPDATE sd_maesdos
         SET sdo_capital       = sdo_capital       - v_monto,
             mto_venc_trasp    = mto_venc_trasp    + v_monto,
             mto_capitalizado  = mto_capitalizado  - v_monto_finan,
             mto_fin_ven_trasp = mto_fin_ven_trasp + v_monto_finan
         WHERE num_credito    = gc_num_credito
           AND empresa = g_empresa;

         LET g_sdo_capital       = g_sdo_capital       - v_monto;
         LET g_mto_venc_trasp    = g_mto_venc_trasp    + v_monto;
         LET g_mto_capitalizado  = g_mto_capitalizado  - v_monto_finan;
         LET g_mto_fin_ven_tras  = g_mto_fin_ven_tras  + v_monto_finan;

         IF (gc_cuota_rec = "6") OR (gc_cuota_rec = "8") THEN
            LET v_codigo_ref  = 21; -- capital pro/reno vig. a
                                    -- vencido exig 6604
         ELSE
            LET v_codigo_ref  = 20; -- capital vig.  vdo exig
                                    -- 6604
         END IF;

         LET v_monto_tot = 0;
         LET v_monto_tot = v_monto + v_monto_finan;
         LET v_num_cuota = 0;
         IF v_monto_tot != 0 THEN
            CALL genmov(g_empresa, gc_num_credito,  g_num_producto,
                        v_codigo_ref,    g_codigo_fun,
                        g_fecha_hoy,     v_monto_tot,   v_folio_suc,
                        g_sucursal,      g_divisa,      v_transacc_suc)
            RETURNING v_codret, g_mensaje;
         END IF

         LET v_num_cuota = 0;
         -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
         -- Salida de los semestres po efecto de traspaso a c.v de cap.
         CALL semestres(gc_fecha_cuota)
         RETURNING v_num_cuota;

         LET v_codigo_ref  = 2;  -- Salida de semestres x trasp de cap.
         LET v_monto_tot   = 0;
         LET v_monto_tot   = v_monto + v_monto_finan;

         IF v_monto_tot != 0 THEN
            CALL genmov(g_empresa, gc_num_credito,  g_num_producto,
                        v_codigo_ref,    v_codigo_fun,
                        g_fecha_hoy,     v_monto_tot,  v_folio_suc,
                        g_sucursal,      g_divisa,     v_transacc_suc)
            RETURNING v_codret, g_mensaje;

         END IF;
         -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      ELSE

         UPDATE sd_maesdos SET
           cap_tras_no_venci = sdo_capital,
           mto_fin_vig_trasp = mto_capitalizado
         WHERE num_credito = gc_num_credito
          AND empresa = g_empresa;

         LET g_cap_tras_no_venc = g_sdo_capital;
         LET g_mto_fin_vig_tras = g_mto_capitalizado;

         LET v_transacc_suc     = "3c22";
         IF (gc_cuota_rec = "6") OR (gc_cuota_rec = "8") THEN
            LET v_codigo_ref  = 46;  -- capital pro/reno vig. a
                                     -- venc no exig 6771
         ELSE
            LET v_codigo_ref  = 49;  -- capital vig. venc no exig
                                     -- 6771
         END IF

         LET v_monto_tot  = 0;
         LET v_monto_tot  = (g_sdo_capital + g_mto_capitalizado);
         LET v_num_cuota = 0;

         IF v_monto_tot != 0 THEN
            CALL genmov(g_empresa, gc_num_credito, g_num_producto,
                        v_codigo_ref,     g_codigo_fun,
                        g_fecha_hoy,      v_monto_tot,  v_folio_suc,
                        g_sucursal,       g_divisa,     v_transacc_suc)
            RETURNING v_codret, g_mensaje;
         END IF;

         LET v_nocuotas_en_7    = 1 ;

      END IF;

   END IF;


   -- ================================================================
   -- === traspaso de cuotas status 7 a vencido exigible
   -- ================================================================
   IF gc_status_cuota = "7"  THEN
      LET vt_monto_aso_cap = 0;
      LET vt_monto_aso_fin = 0;
      LET vt_monto_asocia  = 0;

      LET v_monto = 0;
      LET v_monto_finan = 0;

      CALL Saldo_cuo_cap()
      RETURNING v_codret, g_num_credito, v_monto, v_monto_finan;


      UPDATE sd_pagocapit
      SET  status_cuota     = "2",
           status_moratorio = "2"
      WHERE fecha_cuota = gc_fecha_cuota AND
            num_credito = gc_num_credito
        AND empresa = g_empresa;

      UPDATE sd_maesdos
      SET monto_vencido     = monto_vencido     - v_monto,
          mto_venc_trasp    = mto_venc_trasp    + v_monto,
          mto_finan_vdo     = mto_finan_vdo     - v_monto_finan,
          mto_fin_ven_trasp = mto_fin_ven_trasp + v_monto_finan
      WHERE num_credito    = gc_num_credito
        AND empresa = g_empresa;

      LET g_monto_vencido     = g_monto_vencido     - v_monto;
      LET g_mto_venc_trasp    = g_mto_venc_trasp    + v_monto;
      LET g_mto_finan_vdo     = g_mto_finan_vdo     - v_monto_finan;
      LET g_mto_fin_ven_tras  = g_mto_fin_ven_tras  + v_monto_finan;

      LET v_transacc_suc     = "3c72";

      IF (gc_cuota_rec = "6") OR (gc_cuota_rec = "8") THEN
         LET v_codigo_ref  = 19;  -- capital pro/reno venc.transi. a
                                  -- vencido exig 6603
      ELSE
         LET v_codigo_ref  = 10;  -- capital venc.transi.  vencido exig
                                  -- 6603
      END IF ;

      LET v_monto_tot = 0;
      LET v_monto_tot = v_monto + v_monto_finan;
      LET v_num_cuota = 0;

      IF v_monto_tot != 0 THEN
         CALL genmov(g_empresa, gc_num_credito,   g_num_producto,
                     v_codigo_ref,     g_codigo_fun,
                     g_fecha_hoy,      v_monto_tot,   v_folio_suc,
                     g_sucursal,       g_divisa,      v_transacc_suc)
         RETURNING v_codret, g_mensaje;
      END IF;

   END IF;


   END FOREACH;

   RETURN v_codret;

END PROCEDURE
DOCUMENT
"Esta funcion realiza el traspaso de capital a capital vencido",
"AUTOR : Jose Cruz Narvaez",
"FECHA : 2/Mayo/2001",
"Ver.  : 1.0",
"BD    : bdicred",
"Mod.  : ";

CREATE PROCEDURE "informix".traspaso_cap(p_fecha_proceso DATE)
       RETURNING CHAR(5), CHAR(20);

   DEFINE GLOBAL g_num_credito        CHAR(20)       DEFAULT " ";
   DEFINE GLOBAL g_divisa             CHAR(2)        DEFAULT " ";
   DEFINE GLOBAL g_num_producto       CHAR(4)        DEFAULT " ";
   DEFINE GLOBAL g_numcte             CHAR(20)       DEFAULT " ";
   DEFINE GLOBAL g_sucursal           CHAR(4)        DEFAULT " ";
   DEFINE GLOBAL g_status_cred        CHAR(2)        DEFAULT " ";
   DEFINE GLOBAL g_campo_trab3        CHAR(10)       DEFAULT " ";
   DEFINE GLOBAL g_period_pago_cap    CHAR(1)        DEFAULT " ";
   DEFINE GLOBAL g_sdo_capital        MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_mto_capitalizado   MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_monto_vencido      MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_mto_finan_vdo      MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_cap_tras_no_venc   MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_mto_venc_trasp     MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_mto_fin_ven_tras   MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_mto_fin_vig_tras   MONEY(14,2)    DEFAULT 0;

   DEFINE GLOBAL g_fecha_hoy          DATE           DEFAULT " ";
   DEFINE GLOBAL g_fecha_ant          DATE           DEFAULT " ";
   DEFINE GLOBAL g_empresa            CHAR(3)        DEFAULT " ";
   DEFINE GLOBAL g_mensaje            CHAR(3)       DEFAULT " ";

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

   DEFINE GLOBAL g_valor38            CHAR(50)       DEFAULT " ";
   --DIAS TRASPASO MENSUAL
   DEFINE GLOBAL g_valor39            CHAR(50)       DEFAULT " ";
   --DIAS TRASPASO NO MENSUAL

   DEFINE v_monto            MONEY(14,2);
   DEFINE v_monto_tot        MONEY(14,2);
   DEFINE v_codigo_ref       SMALLINT;
   DEFINE v_transacc_suc     CHAR(4);
   DEFINE v_codret           CHAR(5);
   DEFINE vt_sum_sdocuota    MONEY(14,2);
   DEFINE vt_sumcapitaliz    MONEY(14,2);
   DEFINE v_monto_finan      MONEY(14,2);
   DEFINE v_status_cred2     CHAR(1);
   DEFINE v_status_cred3     CHAR(1);
   DEFINE v_status_cred4     CHAR(2);
   DEFINE v_status_cred      CHAR(2);
   DEFINE vt_sum_realpa      MONEY(14,2);
   DEFINE vt_pago_capzado    MONEY(14,2);
   DEFINE vt_pago_capital    MONEY(14,2);
   DEFINE v_cartera_asoc     SMALLINT;
   DEFINE v_nocuotas_en_7    SMALLINT;
   DEFINE vt_cont_cuotas     SMALLINT;
   DEFINE vt_reg_x_cred      SMALLINT;
   DEFINE v_num_cuota        SMALLINT;
   DEFINE v_folio_suc        CHAR(16);
   DEFINE v_usuario          CHAR(8);
   DEFINE v_hora             DATETIME HOUR TO FRACTION(3);
   DEFINE v_hora_c1          CHAR(12);
   DEFINE v_hora_c2          CHAR(8);
   DEFINE v_codigo_fun       CHAR(3);

   DEFINE sql_err            SMALLINT;
   DEFINE isam_err           SMALLINT;
   DEFINE error_info         CHAR(40);

   DEFINE v_dias_trasp_cap   SMALLINT;

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET v_codret = sql_err;
      SET DEBUG FILE TO "Traspaso_Cap.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      RETURN v_codret, g_num_credito;
   END EXCEPTION;


   --#################################################################
   --#####                INICIALIZACION DE VARIABLES            #####
   --#################################################################
   LET v_status_cred2     = "";
   LET v_status_cred3     = "";
   LET v_status_cred4     = "";
   LET v_status_cred      = "";

   LET v_monto            = 0;
   LET v_monto_tot        = 0;
   LET v_codigo_ref       = 0;
   LET v_transacc_suc     = "0000";
   LET v_codret           = "000";
   LET vt_sum_sdocuota    = 0;
   LET vt_sumcapitaliz    = 0;

   LET v_monto_finan      = 0;
   LET vt_sum_realpa      = 0;
   LET vt_cont_cuotas     = 0;
   LET vt_reg_x_cred      = 0;
   LET v_cartera_asoc     = 0;
   LET v_nocuotas_en_7    = 0;
   LET v_num_cuota        = 0;
   LET v_folio_suc        = "               ";
   LET v_usuario          = USER;
   LET v_hora             = CURRENT HOUR TO FRACTION;
   LET v_hora_c1          = v_hora;
   LET v_hora_c2          = v_hora_c1;
   LET v_folio_suc        = TRIM(v_usuario) || TRIM(v_hora_c2);
   LET v_codigo_fun       = "039";
   LET v_dias_trasp_cap   = 0;




   --cap = 2 mensual
   IF g_period_pago_cap = "2" THEN
      LET v_dias_trasp_cap   = g_valor38;
   ELSE
      IF g_period_pago_cap = "9" THEN
         LET v_dias_trasp_cap   = g_valor38;
      ELSE
         LET v_dias_trasp_cap   = g_valor39;
      END IF
   END IF;


   --######################################################
   --###    Select de cuotas de capital para traspaso
   --######################################################
   FOREACH
      SELECT num_credito,        fecha_cuota,
             cuota_rec,         
             monto_cuota,        saldo_cuota,
             imp_capitalizado,   monto_real_pag,
             fecha_pago,         porc_pago,
             bandera_ministra,   status_cuota
      INTO
         gc_num_credito,    gc_fecha_cuota,
         gc_cuota_rec,     
         gc_monto_cuota,    gc_saldo_cuota,
         gc_imp_capzado,    gc_monto_real_pag,
         gc_fecha_pago,     gc_porc_pago,
         gc_bandera_minis,  gc_status_cuota
      FROM   sd_pagocapit
      WHERE status_cuota       IN ("1","7")
      AND   ((fecha_cuota        >  g_fecha_ant   AND
              fecha_cuota        <= p_fecha_proceso)  OR
             (p_fecha_proceso   -    fecha_cuota >= v_dias_trasp_cap))
      AND     bandera_ministra   = "A"
      AND     num_credito        = g_num_credito
      AND     empresa            = g_empresa
      ORDER BY fecha_cuota ASC


      --===================================================================
      --=== TRASPASO DE CAPITAL A VENCIDO NO TRASPASADO status de 1 a 7 ===
      --===================================================================
      IF gc_status_cuota = "1" THEN

         -- ##########################################################
         -- #### TRASPASO A CARTERA VENCIDA POR EFECTO DE TENER
         -- #### CUOTA(S) COPN STATUS 2 en sd_pagocapit PASA DE 1 A 2
         -- ##########################################################
         IF g_campo_trab3  = "E" then
            LET v_cartera_asoc = 1;
         END IF;

         LET v_monto          = 0;
         LET v_monto_finan    = 0;
         CALL Saldo_cuo_cap()
         RETURNING v_codret, g_num_credito, v_monto, v_monto_finan;

         IF v_cartera_asoc  = 0 THEN
            LET v_transacc_suc     = "3c17";
            --###########################################################
            --###### ACTUALIZA EL STATUS DE LA CUOTA sd_pagocapit  ######
            --###########################################################
            UPDATE sd_pagocapit
            SET  status_cuota     = "7" ,
                 status_moratorio = "1"
            WHERE fecha_cuota = gc_fecha_cuota AND
                  empresa   = g_empresa AND
                  num_credito = gc_num_credito ;

            --###########################################################
            --###### ACTUALIZA SALDOS EN EL MAESTRO
            --###########################################################
            UPDATE sd_maesdos
            SET sdo_capital      = sdo_capital      - v_monto,
                monto_vencido    = monto_vencido    + v_monto,
                mto_capitalizado = mto_capitalizado - v_monto_finan,
                mto_finan_vdo    = mto_finan_vdo    + v_monto_finan
            WHERE num_credito    = g_num_credito
            AND empresa = g_empresa;

            LET g_sdo_capital      = g_sdo_capital      - v_monto;
            LET g_monto_vencido    = g_monto_vencido    + v_monto;
            LET g_mto_capitalizado = g_mto_capitalizado - v_monto_finan;
            LET g_mto_finan_vdo    = g_mto_finan_vdo    + v_monto_finan;


            -- #################################################################
            -- ### GENERACION DE MOVIMIENTO CONTABLE TRASPASO CAPITAL NORMAL ###
            -- #################################################################
            IF (gc_cuota_rec = "6") OR (gc_cuota_rec = "8") THEN
               LET v_codigo_ref = 18;  -- traspaso cap. prop/reno a vdo.transito
                                       -- 6602
            ELSE
               LET v_codigo_ref = 9;   -- traspaso cap. vig. a vdo.transitorio
                                       -- 6602
            END IF ;

            LET v_monto_tot = 0;
            LET v_monto_tot = v_monto + v_monto_finan;
            IF v_monto_tot != 0 THEN
               CALL genmov(g_empresa, gc_num_credito, g_num_producto,
                           v_codigo_ref,     g_codigo_fun,
                           g_fecha_hoy,      v_monto_tot,  v_folio_suc,
                           g_sucursal,       g_divisa,     v_transacc_suc)
               RETURNING v_codret,g_mensaje;
            END IF;

{RMD La salida de semestres es cuando una cuota pasa de 7 a 2
            LET v_num_cuota     = 0;
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            -- Salida de los semestres po efecto de traspaso a c.v de cap.
            CALL semestres(gc_fecha_cuota)
            RETURNING v_num_cuota;

            LET v_codigo_ref  = 2;  -- Salida de semestres x trasp de cap.

            IF v_monto_tot != 0 THEN
               CALL genmov(gc_num_credito,  v_num_cuota,  g_num_producto,
                           v_codigo_ref,    v_codigo_fun,
                           g_fecha_hoy,     v_monto_tot,  v_folio_suc,
                           g_sucursal,      g_divisa,     v_transacc_suc)
               RETURNING v_codret;

            END IF;
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

RMD}
         ELSE      -- pasa de 1 a 2 por efectos de cartera asociada

            --###########################################################
            --### TRASPASO A CARTERA VENCIDA CONTABILIZADO POR EFECTO ###
            --### DE LA CARTERA ASOCIADA DE status 1 a 2 directo      ###
            --###########################################################
            LET v_transacc_suc     = "3c12";

            --###########################################################
            --###### ACTUALIZA EL STATUS DE LA CUOTA sd_pagocapit  ######
            --###########################################################
            UPDATE sd_pagocapit
            SET  status_cuota     = "2" ,
                 status_moratorio = "2"
            WHERE fecha_cuota = gc_fecha_cuota AND
                  empresa   = g_empresa AND
                  num_credito = gc_num_credito ;

            --###########################################################
            --###### ACTUALIZA SALDOS EN EL MAESTRO
            --###########################################################
            UPDATE sd_maesdos
            SET sdo_capital       = sdo_capital       - v_monto,
                mto_venc_trasp    = mto_venc_trasp    + v_monto,
                mto_capitalizado  = mto_capitalizado  - v_monto_finan,
                mto_fin_ven_trasp = mto_fin_ven_trasp + v_monto_finan
            WHERE num_credito    = g_num_credito
            AND empresa = g_empresa;

            LET g_sdo_capital       = g_sdo_capital       - v_monto;
            LET g_mto_venc_trasp    = g_mto_venc_trasp    + v_monto;
            LET g_mto_capitalizado  = g_mto_capitalizado  - v_monto_finan;
            LET g_mto_fin_ven_tras  = g_mto_fin_ven_tras  + v_monto_finan;

            IF v_cartera_asoc = 1 AND g_campo_trab3 = "E"  THEN
               UPDATE sd_maesdos
               SET cap_tras_no_venci = cap_tras_no_venci - v_monto
               WHERE num_credito    = g_num_credito
               AND empresa  =  g_empresa;

               LET g_cap_tras_no_venc = g_cap_tras_no_venc - v_monto;

               -- ############################################################
               -- traspaso de cartera venc. asociada a vencida exigible
               -- ############################################################
               IF (gc_cuota_rec = "6") OR (gc_cuota_rec = "8") THEN
                  LET v_codigo_ref  = 45 ;   -- 6770 cap pro/ren venc no exig
                                            -- a exig
               ELSE
                  LET v_codigo_ref  = 48 ;   -- 6770  cap venc normal no exig
                                            -- a exig
               END IF;

               LET v_monto_tot = 0;
               LET v_monto_tot = v_monto + v_monto_finan;
               LET v_num_cuota = 0;

               IF v_monto_tot != 0 THEN
                  CALL genmov(g_empresa,gc_num_credito, g_num_producto,
                              v_codigo_ref,    g_codigo_fun,
                              g_fecha_hoy,     v_monto_tot,  v_folio_suc,
                              g_sucursal,      g_divisa,     v_transacc_suc)
                  RETURNING v_codret,g_mensaje;
               END IF;


{RMD La salida de semestres es cuando una cuota pasa de 7 a 2

               LET v_num_cuota = 0;
               -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
               -- Salida de los semestres po efecto de traspaso a c.v de cap.
               CALL semestres(gc_fecha_cuota)
               RETURNING v_num_cuota;

               LET v_codigo_ref = 2;  -- Salida de semestres x trasp de cap.
               LET v_monto_tot  = 0;
               LET v_monto_tot  = v_monto + v_monto_finan;

               IF v_monto_tot != 0 THEN
                  CALL genmov(gc_num_credito,  v_num_cuota,  g_num_producto,
                              v_codigo_ref,    v_codigo_fun,
                              g_fecha_hoy,     v_monto_tot,  v_folio_suc,
                              g_sucursal,      g_divisa,     v_transacc_suc)
                  RETURNING v_codret;

               END IF;
               -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
RMD}
            END IF;


            IF v_cartera_asoc = 1 AND g_campo_trab3  != "E"  THEN
               -- ############################################################
               -- ### GENERACION DE MOVIMIENTO CONTABLE TRASPASO CAPITAL   ###
               -- ############################################################
               IF (gc_cuota_rec = "6") OR (gc_cuota_rec = "8") THEN
                  LET v_codigo_ref  = 21;  -- capital pro/reno vig. a
                                          -- vencido exig 6604
               ELSE
                  LET v_codigo_ref  = 20;  -- capital vig.  vencido exig
                                          -- 6604
               END IF;


               LET v_monto_tot = 0;
               LET v_monto_tot = v_monto + v_monto_finan;
               LET v_num_cuota = 0;
               IF v_monto_tot != 0 THEN
                  CALL genmov(g_empresa,gc_num_credito, g_num_producto,
                              v_codigo_ref,    g_codigo_fun,
                              g_fecha_hoy,     v_monto_tot,  v_folio_suc,
                              g_sucursal,      g_divisa,     v_transacc_suc)
                  RETURNING v_codret,g_mensaje;
               END IF;

{RMD La salida de semestres es cuando una cuota pasa de 7 a 2

               LET v_num_cuota = 0;
               -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
               -- Salida de los semestres po efecto de traspaso a c.v de cap.
               --CALL semestres(gc_fecha_cuota)
               --RETURNING v_num_cuota;

               LET v_codigo_ref = 2;  -- Salida de semestres x trasp de cap.
               LET v_monto_tot  = 0;
               LET v_monto_tot  = v_monto + v_monto_finan;

               IF v_monto_tot != 0 THEN
                  CALL genmov(gc_num_credito,  v_num_cuota,  g_num_producto,
                              v_codigo_ref,    v_codigo_fun,
                              g_fecha_hoy,     v_monto_tot,  v_folio_suc,
                              g_sucursal,      g_divisa,     v_transacc_suc)
                  RETURNING v_codret;

               END IF;
               -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
RMD}
               -- ######################################################
               -- ### Marca el credito que se encuantra en cartera   ###
               -- ### asociada por traspaso de CAPITAL               ###
               -- ######################################################
               UPDATE sd_maecred
               SET campo_trab3 = "E"
               WHERE num_credito    = g_num_credito
               AND empresa = g_empresa;


               UPDATE sd_maesdos
               SET cap_tras_no_venci = sdo_capital,
                   mto_fin_vig_trasp = mto_capitalizado
               WHERE num_credito = g_num_credito
               AND empresa = g_empresa;

               LET g_cap_tras_no_venc = g_sdo_capital;
               LET g_mto_fin_vig_tras = g_mto_capitalizado;

               -- ############################################################
               -- ### CONTABILIZACION DE LA CARTERA ASOCIADA FUTURA
               -- ############################################################
               LET v_transacc_suc     = "3c22";
               IF (gc_cuota_rec = "6") OR (gc_cuota_rec = "8") THEN
                  LET v_codigo_ref  = 46; -- capital pro/reno vig. a
                                          -- venc no exig 6771
               ELSE
                  LET v_codigo_ref  = 49; -- capital vig. venc no exig
                                          -- 6771
               END IF;

               LET v_monto_tot = 0;
               LET v_monto_tot = (g_sdo_capital + g_mto_capitalizado);
               LET v_num_cuota = 0;

               IF v_monto_tot != 0 THEN
                  CALL genmov(g_empresa, gc_num_credito, g_num_producto,
                              v_codigo_ref,    g_codigo_fun,
                              g_fecha_hoy,     v_monto_tot,  v_folio_suc,
                              g_sucursal,      g_divisa,     v_transacc_suc)
                  RETURNING v_codret,g_mensaje;
               END IF;

               LET v_nocuotas_en_7  = 0;
               LET g_campo_trab3    = "E";

               -- ########################################################
               -- ## Rutina Para traspaso de interes por efecto de cartera A.
               -- ########################################################
               CALL TraInt_por_Cap(p_fecha_proceso)
               RETURNING v_codret;

               INSERT INTO sd_pagosost
               VALUES (g_empresa,g_num_credito,0,"V");

               LET v_nocuotas_en_7  = 0;

            END IF;

         END IF;

         LET vt_reg_x_cred     = vt_reg_x_cred   + 1;

      END IF;


      --===================================================================
      --#### TRASPASO DE CAPITAL A VENCIDO TRASPASADO  status de 7 a 2 ####
      --===================================================================
      IF gc_status_cuota = "7" THEN
         IF v_cartera_asoc = 0 THEN
            IF (p_fecha_proceso - gc_fecha_cuota) >= v_dias_trasp_cap THEN

               LET v_monto          = 0;
               LET v_monto_finan    = 0;

               CALL Saldo_cuo_cap()
               RETURNING v_codret, g_num_credito, v_monto, v_monto_finan;

               --###########################################################
               --###### ACTUALIZA EL STATUS DE LA CUOTA sd_pagocapit  ######
               --###########################################################
               UPDATE sd_pagocapit
               SET  status_cuota     = "2",
                    status_moratorio = "2"
               WHERE fecha_cuota = gc_fecha_cuota AND
                     empresa   = g_empresa AND
                     num_credito = gc_num_credito ;


               --###########################################################
               --###### ACTUALIZA SALDOS EN EL MAESTRO
               --###########################################################
               UPDATE sd_maesdos
               SET monto_vencido     = monto_vencido     - v_monto,
                   mto_venc_trasp    = mto_venc_trasp    + v_monto,
                   mto_finan_vdo     = mto_finan_vdo     - v_monto_finan,
                   mto_fin_ven_trasp = mto_fin_ven_trasp + v_monto_finan
               WHERE num_credito     = g_num_credito
               AND empresa = g_empresa;

               LET g_monto_vencido     = g_monto_vencido     - v_monto;
               LET g_mto_venc_trasp    = g_mto_venc_trasp    + v_monto;
               LET g_mto_finan_vdo     = g_mto_finan_vdo     - v_monto_finan;
               LET g_mto_fin_ven_tras  = g_mto_fin_ven_tras  + v_monto_finan;

               --###########################################################
               --##### ARMA EL NUEVO STATUS DEL CREDITO
               --###########################################################
               LET v_status_cred2     = g_status_cred[2,2];
               LET v_status_cred3     = "B";
               LET v_status_cred4     = TRIM(v_status_cred3) ||
                                        TRIM(v_status_cred2);
               LET v_status_cred      = v_status_cred4 ;

               --###########################################################
               --###### ACTUALIZA CAMPOS EN EL MAESTRO DE CREDITOS
               --###########################################################
               UPDATE sd_maecred SET  status_cred = v_status_cred
               WHERE num_credito = g_num_credito
               AND empresa = g_empresa;

               LET g_status_cred = v_status_cred;

               --###########################################################
               --###### ACTUALIZA LA CALIFICACION DEL CLIENTE
               --###########################################################
               UPDATE sd_calcte
               SET cod_califica  =  "M0"
               WHERE numcte = g_numcte
               AND empresa = g_empresa;

               LET v_transacc_suc  = "3c72";
               LET v_monto_tot     = 0;
               LET v_monto_tot     = v_monto + v_monto_finan;
               LET v_num_cuota     = 0;

               -- ############################################################
               -- ### GENERACION DE MOVIMIENTO CONTABLE TRASPASO CAPITAL   ###
               -- ############################################################
               IF (gc_cuota_rec = "6") OR (gc_cuota_rec = "8") THEN
                  LET v_codigo_ref  = 19 ; -- capital pro/reno venc.transi. a
                                           -- vencido exig 6603
               ELSE
                  LET v_codigo_ref  = 10 ; -- capital venc.transi.  vencido exig
                                           -- 6603
               END IF ;


               IF v_monto_tot != 0 THEN
                  CALL genmov(g_empresa,gc_num_credito, g_num_producto,
                              v_codigo_ref,    g_codigo_fun,
                              g_fecha_hoy,     v_monto_tot,  v_folio_suc,
                              g_sucursal,      g_divisa,     v_transacc_suc)
                  RETURNING v_codret,g_mensaje;
               END IF;


            LET v_num_cuota     = 0;
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            -- Salida de los semestres po efecto de traspaso a c.v de cap.
            {CALL semestres(gc_fecha_cuota)
            RETURNING v_num_cuota;

            LET v_codigo_ref  = 2;  -- Salida de semestres x trasp de cap.

            IF v_monto_tot != 0 THEN
               CALL genmov(gc_num_credito,  v_num_cuota,  g_num_producto,
                           v_codigo_ref,    v_codigo_fun,
                           g_fecha_hoy,     v_monto_tot,  v_folio_suc,
                           g_sucursal,      g_divisa,     v_transacc_suc)
               RETURNING v_codret;

            END IF;}
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

               --############################################################
               --#####              CARTERA ASOCIADA                   ######
               --############################################################
               LET vt_cont_cuotas = 0;
               SELECT COUNT(*)
               INTO vt_cont_cuotas
               FROM sd_pagocapit
               WHERE num_credito = gc_num_credito  AND
                     empresa = g_empresa   AND
                     status_cuota = "7" ;

               IF vt_cont_cuotas = 0 OR vt_cont_cuotas IS NULL THEN
                  LET v_cartera_asoc    = 1;
                  LET v_nocuotas_en_7   = 1;
                  LET vt_reg_x_cred     = vt_reg_x_cred   + 1;
               ELSE
                  --###########################################################
                  --###### ACTUALIZA EL STATUS DE LA CUOTA sd_pagocapit  ######
                  --###########################################################
                  UPDATE sd_pagocapit
                  SET  status_cuota     = "2",
                       status_moratorio = "2"
                  WHERE num_credito = gc_num_credito  AND
                        empresa  = g_empresa   AND
                        status_cuota = "7";

                  --###########################################################
                  --###### ACTUALIZA SALDOS EN EL MAESTRO
                  --###########################################################
                  UPDATE sd_maesdos
                  SET mto_venc_trasp    = mto_venc_trasp    + monto_vencido,
                      mto_fin_ven_trasp = mto_fin_ven_trasp + mto_finan_vdo
                  WHERE num_credito     = g_num_credito
                  AND empresa = g_empresa;

                  LET v_monto_tot = 0;
                  LET v_monto_tot = g_monto_vencido + g_mto_finan_vdo;

                  LET g_mto_venc_trasp  =g_mto_venc_trasp   + g_monto_vencido;
                  LET g_mto_fin_ven_tras=g_mto_fin_ven_tras + g_mto_finan_vdo;

                  UPDATE sd_maesdos
                  SET monto_vencido     = 0,
                      mto_finan_vdo     = 0
                  WHERE num_credito    = g_num_credito
                  AND empresa = g_empresa;

                  LET g_monto_vencido  = 0;
                  LET g_mto_finan_vdo  = 0;


                  LET v_num_cuota = 0;

                  -- ########################################################
                  -- ### GENERACION DE MOVIMIENTO CONTABLE TRASPASO CAPITAL #
                  -- ### POR EFECTO DE CARTERA ASOCIADA DE 7s a 2s          #
                  -- ########################################################
                  LET v_transacc_suc     = "3c22";
                  IF (gc_cuota_rec = "6") OR (gc_cuota_rec = "8") THEN
                     LET v_codigo_ref  = 19;
                                           -- capital pro/reno venc.transi. a
                                           -- vencido exig 6603
                  ELSE
                     LET v_codigo_ref  = 10 ;
                                          -- capital venc.transi.  vencido exig
                                          -- 6603
                  END IF;

                  IF v_monto_tot != 0 THEN
                     CALL genmov(g_empresa,gc_num_credito, g_num_producto,
                                 v_codigo_ref,   g_codigo_fun,
                                 g_fecha_hoy,    v_monto_tot,    v_folio_suc,
                                 g_sucursal,     g_divisa,       v_transacc_suc)
                     RETURNING v_codret,g_mensaje;
                  END IF;


               LET v_num_cuota = 0;
               -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
               -- Salida de los semestres po efecto de traspaso a c.v de cap.
               {CALL semestres(gc_fecha_cuota)
               RETURNING v_num_cuota;

               LET v_codigo_ref = 2;  -- Salida de semestres x trasp de cap.
               LET v_monto_tot  = 0;
               LET v_monto_tot  = v_monto + v_monto_finan;

               IF v_monto_tot != 0 THEN
                  CALL genmov(gc_num_credito,  v_num_cuota,  g_num_producto,
                              v_codigo_ref,    v_codigo_fun,
                              g_fecha_hoy,     v_monto_tot,  v_folio_suc,
                              g_sucursal,      g_divisa,     v_transacc_suc)
                  RETURNING v_codret;

               END IF;}
               -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

                  LET v_nocuotas_en_7   = 1;
                  LET v_cartera_asoc    = 1;

                  LET vt_reg_x_cred     = vt_reg_x_cred   + 1;

               END IF;

            END IF;
         END IF;
      END IF;

   END FOREACH

      IF v_nocuotas_en_7 = 1 AND vt_reg_x_cred >= 1 THEN
         --######################################################
         --### Marca el credito que se encuantra en cartera   ###
         --### asociada por traspaso de CAPITAL               ###
         --######################################################
         UPDATE sd_maecred
         SET  campo_trab3 = "E"
         WHERE num_credito    = g_num_credito
         AND empresa  =  g_empresa;

         LET g_campo_trab3   = "E";

         UPDATE sd_maesdos SET
           cap_tras_no_venci = sdo_capital,
           mto_fin_vig_trasp = mto_capitalizado
         WHERE num_credito   = g_num_credito
         AND empresa = g_empresa;

         LET g_cap_tras_no_venc = g_sdo_capital;
         LET g_mto_fin_vig_tras = g_mto_capitalizado;

         LET v_transacc_suc     = "3c22";
         -- ############################################################
         -- ### CONTABILIZACION DE LA CARTERA ASOCIADA FUTURA
         -- ############################################################
         IF (gc_cuota_rec = "6") OR (gc_cuota_rec = "8") THEN
            LET v_codigo_ref  = 46;  -- capital pro/reno vig. a
                                     -- venc no exig 6934
         ELSE
            LET v_codigo_ref  = 49 ; -- capital vig. venc no exig
                                     -- 6771
         END IF;

         LET v_monto_tot = 0;
         LET v_monto_tot   = (g_sdo_capital + g_mto_capitalizado);

         IF v_monto_tot != 0 THEN
            CALL genmov(g_empresa, gc_num_credito, g_num_producto,
                        v_codigo_ref,    g_codigo_fun,
                        g_fecha_hoy,     v_monto_tot,  v_folio_suc,
                        g_sucursal,      g_divisa,     v_transacc_suc)
            RETURNING v_codret,g_empresa;
         END IF;


               LET v_num_cuota = 0;
               -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
               -- Salida de los semestres po efecto de traspaso a c.v de cap.
               {CALL semestres(gc_fecha_cuota)
               RETURNING v_num_cuota;

               LET v_codigo_ref = 2;  -- Salida de semestres x trasp de cap.
               LET v_monto_tot  = 0;
               LET v_monto_tot  = v_monto + v_monto_finan;

               IF v_monto_tot != 0 THEN
                  CALL genmov(gc_num_credito,  v_num_cuota,  g_num_producto,
                              v_codigo_ref,    v_codigo_fun,
                              g_fecha_hoy,     v_monto_tot,  v_folio_suc,
                              g_sucursal,      g_divisa,     v_transacc_suc)
                  RETURNING v_codret;

               END IF;}
               -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

         LET v_nocuotas_en_7 = 0;

            -- ########################################################
            -- ## Rutina Para traspaso de interes por efecto de cartera A.
            -- ########################################################
            CALL TraInt_por_Cap(p_fecha_proceso)
            RETURNING v_codret;

            INSERT INTO sd_pagosost
            VALUES (g_empresa,g_num_credito,0,"V");

      END IF;


   RETURN v_codret, g_num_credito;

END PROCEDURE

DOCUMENT
"Spl para el traspaso a cartera vencida del Capital a efecto de ",
"cartera asociada ",
"base de datos : bdicred",
"AUTOR : Jose Cruz Narvaez Guzman",
"FECHA : 23/abril/2001",
"Ver.  : 1.0",
"Mod   : RAUL MENDOZA 25/Octubre/2001   ",
"      : La salida de semestres es cuando una cuota pasa de estatus 7 a dos",
"      : en GE capital, solicitado por Arturo Marques ";

CREATE PROCEDURE "informix".cobraintanticip()
   RETURNING CHAR(5), MONEY(14,2), MONEY(14,2);

   DEFINE CodRet                 CHAR(5);
   DEFINE Mensaje                CHAR(80);
   DEFINE sql_err                SMALLINT;
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR(40);
   DEFINE nRows                  SMALLINT;

   DEFINE GLOBAL g_Empresa       CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito    CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_NumProducto   CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Remanente     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha         DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa        CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_CodigoFun     CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio         CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_ManejaLinea   CHAR(1)     DEFAULT ' ';

   DEFINE GLOBAL g_SdoIntAnticip MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoIntAntDev  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoIntereses  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoAcumInt    MONEY(14,2) DEFAULT 0;

   
   DEFINE GLOBAL g_IntVig        MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoAcumMesInt MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_ProvisionNorm MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_IntVigCob     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_PagoAdic      CHAR(1)     DEFAULT ' ';

   DEFINE GLOBAL gStatusCap      CHAR(1)     DEFAULT " ";

   DEFINE vInteresAnticip        MONEY(14,2);


   DEFINE vFechaCuota            LIKE sd_paginter.fecha_cuota;
   DEFINE vIntVig                LIKE sd_paginter.monto_cuota;
   DEFINE vCuotaRec              LIKE sd_paginter.cuota_rec;
   DEFINE vMontoCuota            LIKE sd_paginter.monto_cuota;
   DEFINE vMontoRealPag          LIKE sd_paginter.monto_real_pag;
   DEFINE vMontoFinanciado       LIKE sd_paginter.monto_financiado;
   DEFINE vStatusCuota           LIKE sd_paginter.status_cuota;
   DEFINE vReferencia            SMALLINT;
   DEFINE vCodigoFun             CHAR(3);
   DEFINE vSdoACumMesInt         MONEY(14,2);
   DEFINE vProvisionNorm         MONEY(14,2);
   DEFINE vProvision             MONEY(14,2);
 

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraIntVigente.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      LET vIntVig = 0;
      RETURN CodRet, vIntVig, vProvision;
   END EXCEPTION;

   LET CodRet = "000";
   LET vCodigoFun = "034";   --Utilizada para realizar la provision
   LET vSdoAcumMesInt = 0;
   LET vProvisionNorm = 0;
   LET vInteresAnticip = 0;
   LET vProvision = 0;
   LET vIntVig = 0;

   IF (g_ManejaLinea <> 'S') THEN

      IF (g_PagoAdic = '1') THEN   -- Siguientes Cuotas
         SELECT 
            fecha_cuota,
            cuota_rec,
            monto_cuota,
            monto_real_pag,
            (monto_cuota - monto_real_pag),
            NVL(monto_financiado,0),
            status_cuota 
         INTO
            vFechaCuota,
            vCuotaRec,
            vMontoCuota,
            vMontorealPag,
            vIntVig,
            vMontoFinanciado,
            vStatusCuota 
         FROM
            sd_paginter
         WHERE
            empresa = g_Empresa
         AND
            num_credito = g_NumCredito
         AND
            fecha_cuota = (SELECT
                              MIN(fecha_cuota)
                           FROM
                              sd_paginter
                           WHERE
                              empresa = g_Empresa
                           AND
                              num_credito = g_NumCredito
                           AND
                              fecha_cuota >= g_Fecha
                           AND
                              status_cuota = '1')
         AND
         status_cuota = '1';
      ELSE
         SELECT 
            fecha_cuota,
            cuota_rec,
            monto_cuota,
            monto_real_pag,
            (monto_cuota - monto_real_pag),
            NVL(monto_financiado,0),
            status_cuota 
         INTO
            vFechaCuota,
            vCuotaRec,
            vMontoCuota,
            vMontorealPag,
            vIntVig,
            vMontoFinanciado,
            vStatusCuota 
         FROM
            sd_paginter
         WHERE
            empresa = g_Empresa
         AND
            num_credito = g_NumCredito
         AND
            fecha_cuota = (SELECT
                              MAX(fecha_cuota)
                           FROM
                              sd_paginter
                           WHERE
                              empresa = g_Empresa
                           AND
                              num_credito = g_NumCredito
                           AND
                              fecha_cuota >= g_Fecha
                           AND
                              status_cuota = '1')
         AND
         status_cuota = '1';

      END IF;
      LET nrows = dbinfo("sqlca.sqlerrd2");
      IF (nRows = 0) THEN
         RETURN CodRet, 0, 0;
      END IF;

      IF (gStatusCap != "5") THEN
         IF (g_Remanente >= vIntVig) THEN
            LET g_Remanente = g_Remanente - vIntVig;
            LET vCuotaRec = vStatusCuota;
            LET vStatusCuota = '5';
         ELSE
            LET vIntVig = g_Remanente;
            LET g_Remanente = 0;
         END IF;

          -- Valida Provision Pendiente
         IF (vMontoFinanciado <= (vMontoRealPag + vIntVig)) THEN
            LET vProvision = vIntVig - vMontoFinanciado;
         ELSE
            LET vProvision = 0;
         END IF;

         UPDATE    
            sd_paginter
         SET
            monto_real_pag = monto_real_pag + vIntVig,
            fecha_pag     = g_fecha,
            monto_financiado = vMontoFinanciado + vProvision,
            cuota_rec      = vCuotaRec,
            status_cuota   = vStatusCuota
         WHERE
            empresa = g_Empresa
         AND
            num_credito = g_NumCredito
         AND
            fecha_cuota = vFechaCuota;    

   ELSE
      UPDATE 
         sd_paginter
      SET
         status_cuota = "5",
         monto_cuota  = 0,
         cuota_rec = vCuotaRec      
      WHERE
         empresa = g_Empresa
      AND
         num_credito = g_NumCredito
      AND
         fecha_cuota = vFechaCuota;    
  
      LET gStatusCap = " ";
      LET vIntVig = 0;
      LET vProvision = 0;
   END IF;
 
      ---------------------------------------
      --   PAGO ANTICIPADO INSTACASH       --
      ---------------------------------------

   ELSE
      IF (g_Remanente > 0 AND g_SdoIntereses > 0) THEN
         LET vIntVig = g_SdoIntereses;
         IF (g_Remanente >= g_SdoIntereses) THEN
            LET g_Remanente = g_Remanente - g_SdoIntereses;
            LET vInteresAnticip = g_SdoIntereses;
            LET g_SdoIntereses = 0;
         ELSE
            LET g_SdoIntereses = g_SdoIntereses - g_Remanente;
            LET vInteresAnticip = g_Remanente;
            LET g_Remanente = 0;
         END IF;
         
         IF(vInteresAnticip >= g_SdoIntAnticip) THEN
            LET vInteresAnticip = vInteresAnticip - g_SdoIntAnticip;
            LET vProvision = vProvision + g_SdoIntAnticip;
            LET g_SdoIntAnticip  = 0;
         ELSE
            LET g_SdoIntAnticip = g_SdoIntAnticip - vInteresAnticip;
            LET vProvision = vProvision + vInteresAnticip;
            LET vInteresAnticip   = 0;
         END IF;


         IF(vInteresAnticip >= g_SdoIntAntDev) THEN
            LET vInteresAnticip = vInteresAnticip - g_SdoIntAntDev;
            LET vProvision      = vProvision + g_SdoIntAntDev;
            LET g_SdoIntAntDev  = 0;
         ELSE
            LET g_SdoIntAntDev = g_SdoIntAntDev - vInteresAnticip;
            LET vProvision     = vProvision + vInteresAnticip;
            LET vInteresAnticip = 0;
         END IF;  
         LET vIntVig = vProvision;
      END IF;
      
 
   END IF;


   RETURN CodRet, vIntVig, vProvision; 
   
END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de Interes Anticipado',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'CTE   : CACSI',
'BD    : BDICRED';

CREATE PROCEDURE "informix".cobracapanticip()
   RETURNING CHAR(5), MONEY(14,2);

   DEFINE CodRet                 CHAR(5);
   DEFINE Mensaje                CHAR(80);
   DEFINE sql_err                SMALLINT;
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR(40);
   DEFINE nRows                  SMALLINT;

   DEFINE GLOBAL g_Empresa       CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito    CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_NumProducto   CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Remanente     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha         DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa        CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_CodigoFun     CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio         CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_ManejaLinea   CHAR(1)     DEFAULT ' ';
   DEFINE GLOBAL g_PagoAdic      CHAR(1)     DEFAULT ' ';

   DEFINE GLOBAL g_SdoCapInsoluto  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_MtoCapitalizado MONEY(14,2) DEFAULT 0;
 
   DEFINE GLOBAL g_CapVig        MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_CapVigCob     MONEY(14,2) DEFAULT 0;

   DEFINE vFechaCuota            LIKE sd_pagocapit.fecha_cuota;
   DEFINE vCuotaRec              LIKE sd_pagocapit.cuota_rec;
   DEFINE vSaldoCuota            LIKE sd_pagocapit.saldo_cuota;
   DEFINE vMontoRealPag          LIKE sd_pagocapit.monto_real_pag;
   DEFINE vAdeudoCuota           LIKE sd_pagocapit.monto_cuota;
   DEFINE vStatusCuota           LIKE sd_pagocapit.status_cuota;
   DEFINE vCobro1                LIKE sd_pagocapit.monto_cuota;
   DEFINE CapCobrado             LIKE sd_pagocapit.monto_cuota;
   DEFINE vStatus                LIKE sd_pagocapit.status_cuota;

   DEFINE GLOBAL gStatusCap      CHAR(1)   DEFAULT " ";

   DEFINE vCapVig                MONEY(14,2);

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraCapAnticip.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      LET vCobro1 = 0;
      RETURN CodRet, vCobro1;
   END EXCEPTION;

   LET CodRet = '000';
   LET vCObro1 = 0;
   LET vCapVig = 0;
   LET gStatusCap = " ";
   
   IF (g_ManejaLinea <> 'S') THEN
      IF (g_PagoAdic = '1') THEN
         SELECT
            fecha_cuota, cuota_rec, saldo_cuota, monto_real_pag,
            (saldo_cuota - monto_real_pag), status_cuota
         INTO
            vFechaCuota, vCuotaRec, vSaldoCuota, vMontoRealPag, 
            vAdeudoCuota, vStatusCuota 
	 FROM sd_pagocapit 
	WHERE empresa = g_Empresa 
         AND num_credito = g_NumCredito
         AND fecha_cuota = (SELECT MIN(fecha_cuota)
                              FROM sd_pagocapit
                             WHERE empresa = g_Empresa
                               AND num_credito = g_NumCredito
                               AND fecha_cuota >= g_Fecha
                               AND status_cuota = '1'
	 		       AND saldo_cuota - monto_real_pag > 0)
         AND status_cuota = '1';
            
      ELSE
         SELECT fecha_cuota, cuota_rec, saldo_cuota, monto_real_pag,
            (saldo_cuota - monto_real_pag), status_cuota
	 INTO vFechaCuota, vCuotaRec, vSaldoCuota, vMontoRealPag, 
            vAdeudoCuota, vStatusCuota
         FROM sd_pagocapit
         WHERE empresa = g_Empresa 
         AND num_credito = g_NumCredito
         AND fecha_cuota = (SELECT MAX(fecha_cuota)
                              FROM sd_pagocapit
                             WHERE empresa = g_Empresa
                               AND num_credito = g_NumCredito
                               AND fecha_cuota >= g_Fecha
                               AND status_cuota = '1'
	 		       AND saldo_cuota - monto_real_pag > 0)
         AND status_cuota = '1';
      END IF;
      LET nrows = dbinfo("sqlca.sqlerrd2");
      IF (nRows = 0) THEN
            RETURN CodRet, 0;
      END IF;
      IF (g_Remanente >= vAdeudoCuota) THEN
         LET g_Remanente = g_Remanente - vAdeudoCuota;
         LET vCuotaRec = vStatusCuota;
         LET vStatusCuota = '1';
      ELSE
         LET vAdeudoCuota = g_Remanente;
         LET g_Remanente = 0;
      END IF;
      LET vCobro1 = vCobro1 + vAdeudoCuota;
      UPDATE
         sd_pagocapit
      SET
         monto_real_pag = monto_real_pag + vAdeudoCuota,
         fecha_pago     = g_fecha,
         status_cuota   = vStatusCuota
      WHERE
         empresa     = g_empresa
      AND
         num_credito = g_NumCredito 
      AND
         fecha_cuota = vFechaCuota;
      
      LET gStatusCap = vStatusCuota;

    ---------------------------------------------
    --   COBRO ANTICIPADO INSTACASH            --
    ---------------------------------------------

   ELSE
     IF(g_Remanente > 0 AND g_SdoCapInsoluto > 0) THEN
        LET vCapVig = g_SdoCapInsoluto;
        IF (g_Remanente >= g_SdoCapInsoluto) THEN
           LET g_Remanente      = g_Remanente - g_SdoCapInsoluto;
           LET CapCobrado       = g_SdoCapInsoluto;
           LET g_SdoCapInsoluto = 0; 
        ELSE
           LET g_SdoCapInsoluto = g_SdoCapInsoluto - g_Remanente;
           LET CapCobrado       = g_Remanente;
           LET g_Remanente      = 0;
        END IF;       
   
        LET vCobro1 = CapCobrado;
 
        IF (CapCobrado >= g_SdoCapInsoluto) THEN 
           LET CapCobrado       = CapCobrado - g_SdoCapInsoluto;
           LET g_SdoCapInsoluto = 0; 
        ELSE
           LET g_SdoCapInsoluto = g_SdoCapInsoluto - CapCobrado;
           LET CapCobrado       = 0;
        END IF;

        IF (CapCobrado >= g_MtoCapitalizado) THEN
           LET CapCobrado = CapCobrado - g_MtoCapitalizado;
           LET g_MtoCapitalizado = 0;
        ELSE
           LET g_MtoCapitalizado = g_MtoCapitalizado - CapCobrado;
           LET CapCobrado = 0;
        END IF;
     END IF;

   END IF;

   RETURN CodRet, vCobro1;

END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de Capital Anticipado, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'CTE   : CACSI',
'BD    : BDICRED';

CREATE PROCEDURE "informix".clasifica_cartvend(eempresa      CHAR(3),
				  enum_credito  CHAR(20),
			 	  etp_venta     CHAR(1),
				  enum_producto CHAR(4),
				  eusuario      CHAR(8))
RETURNING CHAR(5), CHAR(80);

-- ****************************************************************************
-- *                         DEFINICION DE VARIABLES                          *
-- ****************************************************************************
DEFINE vcod_ret       CHAR(5);
DEFINE vsqlerr        INTEGER;
DEFINE vmensaje       CHAR(80);
DEFINE vfuncion       CHAR(3);
DEFINE v_vigente      MONEY(14,2);
DEFINE v_vencido      MONEY(14,2);
DEFINE v_venctrasp    MONEY(14,2);
DEFINE v_intnoexig    MONEY(14,2);
DEFINE v_int_venc     MONEY(14,2);
DEFINE v_intvenctrasp MONEY(14,2);
DEFINE vnum_producto  CHAR(4);
DEFINE vhoy           DATE;
DEFINE vfolio         CHAR(16);
DEFINE vsucursal      CHAR(4);
DEFINE vdivisa        CHAR(2);
-- ****************************************************************************
-- *                         ASIGNACION DE VARIABLES                          *
-- ****************************************************************************
LET vcod_ret = "00000";
LET vsqlerr  = 0;
LET vmensaje = "PROCESO CONCLUIDO EXITOSAMENTE";
SELECT eusuario || SUBSTR(current hour to fraction    ,1,2 ) ||
                   SUBSTR(current hour to fraction    ,4,2 ) ||
                   SUBSTR(current hour to fraction    ,7,2 ) ||
                   SUBSTR(enum_credito,8 ,2),
      fecha_hoy
 INTO vfolio, vhoy
 FROM sd_fechas;
-- ****************************************************************************
-- *                         CONTROL DE ERRORES                               *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcod_ret=vsqlerr;
      ROLLBACK WORK;
      LET vmensaje = " ";
      RETURN vcod_ret, vmensaje; 
   END IF;
END EXCEPTION;


-- ****************************************************************************
-- *                         PROGRAMA PRINCIPAL                               *
-- ****************************************************************************
	IF etp_venta = "2" THEN
		IF enum_producto = " " OR enum_producto IS NULL THEN
			LET vcod_ret = "0020";
			LET vmensaje = "Debe Definir un Producto"; 
			RETURN vcod_ret, vmensaje;
		END IF
		LET vfuncion = "021";
	ELIF etp_venta = "1" THEN
		LET vfuncion = "020";
	ELSE 
		LET vfuncion = "036";
	END IF
	BEGIN WORK;

	SELECT sdo_capital, monto_vencido, mto_venc_trasp, sdo_no_exig,
	       mto_venc_int,mto_venc_tra_int, num_producto, sucursal,
	       divisa
	  INTO v_vigente  , v_vencido,     v_venctrasp,    v_intnoexig,
	       v_int_venc,  v_intvenctrasp,vnum_producto,  vsucursal,
	       vdivisa
	  FROM sd_maesdos a, sd_maecred b
	 WHERE b.num_credito = a.num_credito
	   AND b.empresa     = a.empresa
	   AND a.num_credito = enum_credito
	   AND a.empresa     = eempresa; 

	-- Liquida o Traspasa el Capital Vigente Segun Corresponda
	EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto, 1, 
				 vfuncion, vhoy, v_vigente, vfolio, vsucursal,
				 vdivisa, "0000")
		INTO vcod_ret, vmensaje;
	IF vcod_ret <> "00000" THEN
      		ROLLBACK WORK;
		RETURN vcod_ret, vmensaje;
	END IF

	-- Liquida o Traspasa el Capital Vencido Segun Corresponda
	EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto, 2, 
				 vfuncion, vhoy, v_vencido, vfolio, vsucursal,
				 vdivisa, "0000")
		INTO vcod_ret, vmensaje;
	IF vcod_ret <> "00000" THEN
      		ROLLBACK WORK;
		RETURN vcod_ret, vmensaje;
	END IF

	-- Liquida o Traspasa el Capital Vencido Traspasado Segun Corresponda
	EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto, 3, 
				 vfuncion, vhoy, v_venctrasp, vfolio, vsucursal,
				 vdivisa, "0000")
		INTO vcod_ret, vmensaje;
	IF vcod_ret <> "00000" THEN
      		ROLLBACK WORK;
		RETURN vcod_ret, vmensaje;
	END IF

	-- Liquida o Traspasa el Interes Vigente Segun Corresponda
	EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto, 4, 
				 vfuncion, vhoy, v_intnoexig, vfolio, vsucursal,
				 vdivisa, "0000")
		INTO vcod_ret, vmensaje;
	IF vcod_ret <> "00000" THEN
      		ROLLBACK WORK;
		RETURN vcod_ret, vmensaje;
	END IF

	-- Liquida o Traspasa el Interes Vencido Segun Corresponda
	EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto, 5, 
				 vfuncion, vhoy, v_int_venc, vfolio, 
				 vsucursal, vdivisa, "0000")
		INTO vcod_ret, vmensaje;
	IF vcod_ret <> "00000" THEN
      		ROLLBACK WORK;
		RETURN vcod_ret, vmensaje;
	END IF

	-- Liquida o Traspasa el Interes Vencido Traspasado Segun Corresponda
	EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto, 6, 
				 vfuncion, vhoy, v_intvenctrasp, vfolio, 
				 vsucursal, vdivisa, "0000")
		INTO vcod_ret, vmensaje;
	IF vcod_ret <> "00000" THEN
      		ROLLBACK WORK;
		RETURN vcod_ret, vmensaje;
	END IF

	IF etp_venta = "1" THEN
		-- Liquida o Traspasa el Interes Moratorios 
		EXECUTE PROCEDURE genmov(eempresa, enum_credito, vnum_producto,
					 7, vfuncion, vhoy, v_intvenctrasp, 
					 vfolio, vsucursal, vdivisa, "0000")
		   INTO vcod_ret, vmensaje;
		IF vcod_ret <> "00000" THEN
      			ROLLBACK WORK;
			RETURN vcod_ret, vmensaje;
		END IF

		UPDATE sd_pagocapit SET monto_real_pag = saldo_cuota,
					status_cuota = "5"
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa 
		   AND status_cuota <> "5";

		UPDATE sd_paginter SET monto_real_pag = monto_cuota,
					status_cuota = "5"
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa 
		   AND status_cuota <> "5";

		UPDATE sd_detmora SET sdo_mora_ordi = 0
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa ;

		-- Se va a verificar pero de entrada el seguro se cancela

		UPDATE sd_detcomi SET estado_com = "C"
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa 
		   AND estado_com = "P";

		UPDATE sd_maesdos SET sdo_no_exig      = 0,
				      sdo_exig_int     = 0,
				      sdo_moratorio    = 0,
				      sdo_capital      = 0,
				      sdo_cap_insoluto = 0,
				      monto_vencido    = 0,
				      mto_venc_trasp   = 0,
				      mto_venc_int     = 0,
				      mto_venc_tra_int = 0
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa ;


		UPDATE sd_maecred SET status_cred = "FE"
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa ;

	ELIF etp_venta = "2" THEN
		UPDATE sd_maecred SET num_producto = enum_producto 
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa ;
	ELSE
		UPDATE sd_maecred SET status_cred = "CC"
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa ;

                UPDATE sd_maesdos SET sdo_no_exig      = 0,
                                      sdo_exig_int     = 0,
                                      sdo_moratorio    = 0,
                                      mto_venc_int     = 0,
                                      mto_venc_tra_int = 0
                 WHERE num_credito = enum_credito
                   AND empresa = eempresa ;

		UPDATE sd_paginter SET monto_cuota = 0, status_cuota ="1"
		 WHERE num_credito = enum_credito
		   AND empresa = eempresa
		   AND monto_cuota > 0
		   AND status_cuota <> "5";

	END IF
	

	COMMIT WORK;
END
	RETURN vcod_ret, vmensaje;
END PROCEDURE;