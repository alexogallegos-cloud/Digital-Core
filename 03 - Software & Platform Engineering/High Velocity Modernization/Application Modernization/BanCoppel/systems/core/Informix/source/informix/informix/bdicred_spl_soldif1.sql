CREATE PROCEDURE "informix".spl_soldif1(param_fechaproc DATE)
RETURNING CHAR(50),          -- Numero de Credito o mensaje de error
          MONEY(14,2),       -- Otorgado
          MONEY(14,2),       -- SUmatoria de cuotas de capital
          MONEY(14,2),       -- Diferencia entre otorgado y C-Capital
          MONEY(14,2),       -- Cuota fija por plazo
          MONEY(14,2),       -- Cuotas de Capital + Cuotas de Interes
          MONEY(14,2),       -- Diferencia entre CF*P y (CC + CI)
          MONEY(14,2),       -- Saldo migrado
          MONEY(14,2),       -- Saldo Insoluto + Pagos de Capital
          MONEY(14,2),       -- Diferencia entre SM y (SI + PC)
          MONEY(14,2),       -- Intereses registrados
          MONEY(14,2),       -- Intereses calculados
          MONEY(14,2);       -- Diferencia entre IntReg e IntCalc
-------------------------------------------------------------------------
-- DEFINE VARIABLES DE TRABAJO
-------------------------------------------------------------------------
DEFINE x_num_credito        LIKE sd_maecred.num_credito;
DEFINE x_num_producto       LIKE sd_maecred.num_producto;
DEFINE x_plazo              LIKE sd_maecred.plazo;
DEFINE x_tasa_interes       LIKE sd_maecred.tasa_interes;
DEFINE x_campo_trab1        LIKE sd_maecred.campo_trab1;
DEFINE x_fecha_apertura     LIKE sd_maecred.fecha_apertura;
DEFINE x_numcte             LIKE sd_maecred.numcte;
DEFINE x_status_cred        LIKE sd_maecred.status_cred;
DEFINE x_sdo_exig_int       LIKE sd_maesdos.sdo_exig_int;
DEFINE x_sdo_no_exig        LIKE sd_maesdos.sdo_no_exig;
DEFINE x_sdo_moratorio      LIKE sd_maesdos.sdo_moratorio;
DEFINE x_sdo_capital        LIKE sd_maesdos.sdo_capital;
DEFINE x_sdo_cap_insoluto   LIKE sd_maesdos.sdo_cap_insoluto;
DEFINE x_mto_ministra_cap   LIKE sd_maesdos.mto_ministra_cap;
DEFINE x_monto_vencido      LIKE sd_maesdos.monto_vencido;
DEFINE x_mto_venc_trasp     LIKE sd_maesdos.mto_venc_trasp;
DEFINE x_monto_financiado   LIKE sd_maesdos.monto_financiado;
DEFINE x_monto_otorgado     LIKE sd_maesdos.monto_otorgado;
DEFINE x_mto_venc_int       LIKE sd_maesdos.mto_venc_int;
DEFINE x_mto_venc_tra_int   LIKE sd_maesdos.mto_venc_tra_int;
DEFINE x_saldo              LIKE saldos_ini.saldo;
DEFINE x_fecha              LIKE saldos_ini.fecha;
DEFINE x_cliente            LIKE saldos_ini.cliente;
DEFINE x_segmento           LIKE saldos_ini.segmento;
DEFINE x_tipo               LIKE saldos_ini.tipo;
DEFINE x_pagos_cap          MONEY(14,2);
DEFINE x_ccap1257_reg       MONEY(14,2);
DEFINE x_ccap1_reg          MONEY(14,2);
DEFINE x_ccap2_reg          MONEY(14,2);
DEFINE x_ccap7_reg          MONEY(14,2);
DEFINE x_cint1257_calc      MONEY(14,2);
DEFINE x_cint1257_reg       MONEY(14,2);
DEFINE x_cint1_reg          MONEY(14,2);
DEFINE x_cint2_reg          MONEY(14,2);
DEFINE x_cint7_reg          MONEY(14,2);
DEFINE x_detminis_reg       MONEY(14,2);
DEFINE x_detmora_reg        MONEY(14,2);
DEFINE x_dif_oto_ccap       MONEY(14,2);
DEFINE x_dif_cfp_ccei       MONEY(14,2);
DEFINE x_dif_smi_inpa       MONEY(14,2);
DEFINE x_dif_ire_ica        MONEY(14,2);
DEFINE x_codret             CHAR(4);
DEFINE sqlerr               INTEGER;

-------------------------------------------------------------------------
-- INICIALIZA VARIABLES DE TRABAJO
-------------------------------------------------------------------------
LET x_num_credito        = "";
LET x_num_producto       = "";
LET x_plazo              = 0;
LET x_tasa_interes       = 0;
LET x_campo_trab1        = 0;
LET x_fecha_apertura     = "";
LET x_status_cred        = "";
LET x_numcte             = "";
LET x_sdo_exig_int       = 0;
LET x_sdo_no_exig        = 0;
LET x_sdo_moratorio      = 0;
LET x_sdo_capital        = 0;
LET x_sdo_cap_insoluto   = 0;
LET x_mto_ministra_cap   = 0;
LET x_monto_vencido      = 0;
LET x_mto_venc_trasp     = 0;
LET x_monto_financiado   = 0;
LET x_monto_otorgado     = 0;
LET x_mto_venc_int       = 0;
LET x_mto_venc_tra_int   = 0;
LET x_saldo              = 0;
LET x_fecha              = "";
LET x_cliente            = "";
LET x_segmento           = "";
LET x_tipo               = "";
LET x_pagos_cap          = 0;
LET x_ccap1257_reg       = 0;
LET x_ccap1_reg          = 0;
LET x_ccap2_reg          = 0;
LET x_ccap7_reg          = 0;
LET x_cint1257_calc      = 0;
LET x_cint1257_reg       = 0;
LET x_cint1_reg          = 0;
LET x_cint2_reg          = 0;
LET x_cint7_reg          = 0;
LET x_detminis_reg       = 0;
LET x_detmora_reg        = 0;
LET x_dif_oto_ccap       = 0;
LET x_dif_cfp_ccei       = 0;
LET x_dif_smi_inpa       = 0;
LET x_dif_ire_ica        = 0;
LET x_codret             = "FIN";
LET sqlerr               = 0;
--    RETURN x_codret, "MAGA EN LA EJECUCION" with resume;

------------------------------------------------------------------------
-- Inicia Proceso
------------------------------------------------------------------------
BEGIN
   ON EXCEPTION
      SET sqlerr
      LET x_codret = sqlerr;
      RETURN x_codret || "ERROR EN LA EJECUCION",
             x_monto_otorgado,
             x_ccap1257_reg,
             x_dif_oto_ccap,
             (x_campo_trab1 * x_plazo),
             (x_ccap1257_reg + x_cint1257_reg),
             x_dif_cfp_ccei,
             x_saldo,
             (x_sdo_cap_insoluto + x_pagos_cap),
             x_dif_smi_inpa,
             x_cint1257_reg,
             x_cint1257_calc,
             x_dif_ire_ica;
   END EXCEPTION;

   FOREACH
      SELECT  num_credito
        INTO  x_num_credito
        FROM  sd_auditsdo
        WHERE v01_otor_cc1257 = "1"
        AND   v02_sdoc_cc1    <> "1"
        AND   v03_sdoc_tdmm   <> "1"
        AND   v04_inso_cc127  <> "1"
        AND   v05_inso_tdmm   <> "1"
        AND   v06_mvdo_cc7    <> "1"
        AND   v07_mvtr_cc2    <> "1"
        AND   v08_snex_ci1    <> "1"
        AND   v09_sexi_ci27   <> "1"
        AND   v10_mvin_ci7    <> "1"
        AND   v11_mvti_ci2    <> "1"
        AND   v12_sdmo_dmora  <> "1"
        AND   v13_sdmo_0      <> "1"
        AND   v14_sdimig_ip   =  "1"
        AND   v15_ccvenytr    <> "1"
        AND   v16_civenytr    <> "1"
        AND   status_cred[1,1]<> "F"
        AND   fecha_act       =  param_fechaproc

      SELECT  num_credito,
              num_producto,
              plazo,
              tasa_interes,
              campo_trab1,
              fecha_apertura,
              numcte,
              status_cred,
              numcte
        INTO  x_num_credito,
              x_num_producto,
              x_plazo,
              x_tasa_interes,
              x_campo_trab1,
              x_fecha_apertura,
              x_numcte,
              x_status_cred,
              x_numcte
        FROM  sd_maecred
        WHERE num_credito = x_num_credito;

      ------------------------------------------------------------------------
      -- Obtine datos de maecred, maesdos, saldos_ini, paginter, pagocapit
      -- detmora y movdia
      ------------------------------------------------------------------------
      SELECT  num_credito,
              sdo_exig_int,
              sdo_no_exig,
              sdo_moratorio,
              sdo_capital,
              sdo_cap_insoluto,
              mto_ministra_cap,
              monto_vencido,
              mto_venc_trasp,
              monto_financiado,
              monto_otorgado,
              mto_venc_int,
              mto_venc_tra_int
         INTO x_num_credito,
              x_sdo_exig_int,
              x_sdo_no_exig,
              x_sdo_moratorio,
              x_sdo_capital,
              x_sdo_cap_insoluto,
              x_mto_ministra_cap,
              x_monto_vencido,
              x_mto_venc_trasp,
              x_monto_financiado,
              x_monto_otorgado,
              x_mto_venc_int,
              x_mto_venc_tra_int
        FROM  sd_maesdos
        WHERE num_credito = x_num_credito;

      IF x_num_producto = "420" THEN
         SELECT  NVL(saldo, 0)
           INTO  x_saldo
           FROM  saldos_ini
           WHERE x_numcte LIKE "%" || substr(cliente,3) ||  "%"
           AND   "409" = segmento ||  tipo
           AND   x_fecha_apertura = fecha;
      ELSE
         SELECT  NVL(saldo, 0)
           INTO  x_saldo
           FROM  saldos_ini
           WHERE x_numcte LIKE "%" || substr(cliente,3) ||  "%"
           AND   x_num_producto = segmento ||  tipo
           AND   x_fecha_apertura = fecha;
      END IF;

      SELECT  sum(monto_cuota)
        INTO  x_ccap1257_reg
        FROM  sd_pagocapit
        WHERE num_credito = x_num_credito
        AND   status_cuota in ("1","2","5","7");

      SELECT  sum(monto_cuota - monto_real_pag)
        INTO  x_ccap1_reg
        FROM  sd_pagocapit
        WHERE num_credito = x_num_credito
        AND   status_cuota = "1";

      SELECT  sum(monto_cuota - monto_real_pag)
        INTO  x_ccap7_reg
        FROM  sd_pagocapit
        WHERE num_credito = x_num_credito
        AND   status_cuota = "7";

      SELECT  sum(monto_cuota - monto_real_pag)
        INTO  x_ccap2_reg
        FROM  sd_pagocapit
        WHERE num_credito = x_num_credito
        AND   status_cuota = "2";

      SELECT  sum(monto_cuota)
        INTO  x_cint1257_reg
        FROM  sd_paginter
        WHERE num_credito = x_num_credito
        AND   status_cuota in ("1","2","5","7");

      SELECT  sum(monto_cuota - monto_real_pag)
        INTO  x_cint1_reg
        FROM  sd_paginter
        WHERE num_credito = x_num_credito
        AND   status_cuota = "1";

      SELECT  sum(monto_cuota - monto_real_pag)
        INTO  x_cint7_reg
        FROM  sd_paginter
        WHERE num_credito = x_num_credito
        AND   status_cuota = "7";

      SELECT  sum(monto_cuota - monto_real_pag)
        INTO  x_cint2_reg
        FROM  sd_paginter
        WHERE num_credito = x_num_credito
        AND   status_cuota = "2";

      SELECT  sum(monto_otorgado)
        INTO  x_detminis_reg
        FROM  sd_detminis
        WHERE status_ministra = "M";

      SELECT  NVL ((SUM (sdo_mora_ordi)), 0)
        INTO  x_detmora_reg
        FROM  sd_detmora
        WHERE num_credito = x_num_credito;

      SELECT  NVL((SUM (monto)), 0)
        INTO  x_pagos_cap
        FROM  sd_movdia
        WHERE num_credito = x_num_credito
        AND   ((codigo_fun IN ("033", "333") AND codigo_ref IN (7,8,10))
        OR    (codigo_fun = "046" AND codigo_ref IN (1,3)));

      ------------------------------------------------------------------------
      -- Determina diferencias
      ------------------------------------------------------------------------
      LET x_cint1257_calc= (x_campo_trab1 * x_plazo) - x_monto_otorgado;
      LET x_dif_oto_ccap = x_monto_otorgado - x_ccap1257_reg;
      LET x_dif_cfp_ccei = (x_campo_trab1 * x_plazo) -
                           (x_ccap1257_reg + x_cint1257_reg);
      LET x_dif_smi_inpa = x_saldo - (x_sdo_cap_insoluto + x_pagos_cap);
      LET x_dif_ire_ica  = x_cint1257_reg - x_cint1257_calc;

      IF x_dif_cfp_ccei = 0 THEN
--       IF ((x_dif_oto_ccap - x_dif_smi_inpa) <= 1 ) AND
--          ((x_dif_oto_ccap - x_dif_ire_ica)  <= 1 ) THEN
         IF ((x_dif_oto_ccap - x_dif_ire_ica)   = 0 ) THEN
            UPDATE sd_auditsdo set solucion[1,1] = "S"
                   WHERE num_credito = x_num_credito;
         ELSE
            UPDATE sd_auditsdo set solucion[1,1] = "N"
                   WHERE num_credito = x_num_credito;
            RETURN
                   "credito " || x_num_credito || " Rechazo1",
                   x_monto_otorgado,
                   x_ccap1257_reg,
                   x_dif_oto_ccap,
                   (x_campo_trab1 * x_plazo),
                   (x_ccap1257_reg + x_cint1257_reg),
                   x_dif_cfp_ccei,
                   x_saldo,
                   (x_sdo_cap_insoluto + x_pagos_cap),
                   x_dif_smi_inpa,
                   x_cint1257_reg,
                   x_cint1257_calc,
                   x_dif_ire_ica with resume;
         END IF;
      ELSE
         UPDATE sd_auditsdo set solucion[1,1] = "N"
                WHERE num_credito = x_num_credito;
         RETURN
                "credito " || x_num_credito || " Rechazo2" ,
                x_monto_otorgado,
                x_ccap1257_reg,
                x_dif_oto_ccap,
                (x_campo_trab1 * x_plazo),
                (x_ccap1257_reg + x_cint1257_reg),
                x_dif_cfp_ccei,
                x_saldo,
                (x_sdo_cap_insoluto + x_pagos_cap),
                x_dif_smi_inpa,
                x_cint1257_reg,
                x_cint1257_calc,
                x_dif_ire_ica with resume;
      END IF;
      -------------------------------------------------------------------------
      -- INICIALIZA VARIABLES DE TRABAJO
      -------------------------------------------------------------------------
      LET x_num_credito        = "";
      LET x_num_producto       = "";
      LET x_plazo              = 0;
      LET x_tasa_interes       = 0;
      LET x_campo_trab1        = 0;
      LET x_fecha_apertura     = "";
      LET x_status_cred        = "";
      LET x_numcte             = "";
      LET x_sdo_exig_int       = 0;
      LET x_sdo_no_exig        = 0;
      LET x_sdo_moratorio      = 0;
      LET x_sdo_capital        = 0;
      LET x_sdo_cap_insoluto   = 0;
      LET x_mto_ministra_cap   = 0;
      LET x_monto_vencido      = 0;
      LET x_mto_venc_trasp     = 0;
      LET x_monto_financiado   = 0;
      LET x_monto_otorgado     = 0;
      LET x_mto_venc_int       = 0;
      LET x_mto_venc_tra_int   = 0;
      LET x_saldo              = 0;
      LET x_fecha              = "";
      LET x_cliente            = "";
      LET x_segmento           = "";
      LET x_tipo               = "";
      LET x_pagos_cap          = 0;
      LET x_ccap1257_reg       = 0;
      LET x_ccap1_reg          = 0;
      LET x_ccap2_reg          = 0;
      LET x_ccap7_reg          = 0;
      LET x_cint1257_calc      = 0;
      LET x_cint1257_reg       = 0;
      LET x_cint1_reg          = 0;
      LET x_cint2_reg          = 0;
      LET x_cint7_reg          = 0;
      LET x_detminis_reg       = 0;
      LET x_detmora_reg        = 0;
      LET x_dif_oto_ccap       = 0;
      LET x_dif_cfp_ccei       = 0;
      LET x_dif_smi_inpa       = 0;
      LET x_dif_ire_ica        = 0;
   END FOREACH;
   RETURN
          x_codret,
          x_monto_otorgado,
          x_ccap1257_reg,
          x_dif_oto_ccap,
          (x_campo_trab1 * x_plazo),
          (x_ccap1257_reg + x_cint1257_reg),
          x_dif_cfp_ccei,
          x_saldo,
          (x_sdo_cap_insoluto + x_pagos_cap),
          x_dif_smi_inpa,
          x_cint1257_reg,
          x_cint1257_calc,
          x_dif_ire_ica with resume;
END;
END PROCEDURE
DOCUMENT
"****************************************************************************",
"*                        -- CACSI --                                       *",
"* Procedimiento que corrige los creditos que tiene diferencia en el monto  *",
"* otorgado v.s. cuotas de capita. Le agrega a las cuotas de capital lo que *",
"* tienen de mas las cuotas de interes                                      *",
"* Realizado por : Magda Marquez el 07/Mar/2005                             *",
"* Se prohibe la distribucion total o parcial de este programa sin la       *",
"* autorizacion de GRUPO PISA                                               *",
"****************************************************************************";

CREATE PROCEDURE "informix".cuadra_capital()
RETURNING CHAR(5);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE v_credito    CHAR(20);
DEFINE v_dif        MONEY(14,2);
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "00000";
LET vsqlerr      = 0;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      ROLLBACK WORK;
      RETURN scod_ret;
   END IF;
END EXCEPTION;


-- **************************************************************************** 
BEGIN WORK;

	UPDATE sd_maesdos SET sdo_capital =0, 
                              monto_vencido=0, 
                              mto_venc_trasp=0
	 WHERE 1=1;
	SELECT a.num_credito, sdo_capital, SUM(saldo_cuota - monto_real_pag) det
	  FROM sd_maesdos a, sd_pagocapit b
	 WHERE a.num_credito = b.num_credito
	   AND status_cuota ="1"
	   AND SUBSTR(a.num_credito,10,3) <> "410"
	 GROUP BY 1,2
	  INTO TEMP cap_vigente;

	FOREACH SELECT num_credito, det
                  INTO v_credito, v_dif
                  FROM cap_vigente
                 WHERE sdo_capital <>  det 


                   UPDATE sd_maesdos SET sdo_capital =  v_dif
                    WHERE num_credito = v_credito;


        END FOREACH



-- ***************************************************************************
-- *                          Cuadra Capital Vencido                         *
-- ***************************************************************************

        SELECT a.num_credito,monto_vencido,SUM(saldo_cuota - monto_real_pag) det
          FROM sd_maesdos a, sd_pagocapit b
         WHERE a.num_credito = b.num_credito
           AND status_cuota ="7"
	   AND SUBSTR(a.num_credito,10,3) <> "410"
         GROUP BY 1,2
          INTO TEMP cap_vencido;


        FOREACH SELECT num_credito, det
                  INTO v_credito, v_dif
                  FROM cap_vencido
                 WHERE monto_vencido <> det 

                   UPDATE sd_maesdos SET monto_vencido = v_dif
                    WHERE num_credito = v_credito;



        END FOREACH
-- ***************************************************************************
-- *                   Cuadra Capital Vencido Traspasado                     *
-- ***************************************************************************

        SELECT a.num_credito,mto_venc_trasp,
	       SUM(saldo_cuota - monto_real_pag) det
          FROM sd_maesdos a, sd_pagocapit b
         WHERE a.num_credito = b.num_credito
           AND status_cuota ="2"
	   AND SUBSTR(a.num_credito,10,3) <> "410"
         GROUP BY 1,2
          INTO TEMP cap_traspasado;

        FOREACH SELECT num_credito, det
                  INTO v_credito, v_dif
                  FROM cap_traspasado
                 WHERE mto_venc_trasp <> det 

                   UPDATE sd_maesdos SET mto_venc_trasp = v_dif
                    WHERE num_credito = v_credito;

        END FOREACH

-- ***************************************************************************
-- *                   Cuadra Capital Insoluto                               *
-- ***************************************************************************

        SELECT num_credito, sdo_cap_insoluto,
	       (sdo_capital + monto_vencido + mto_venc_trasp) det
          FROM sd_maesdos 
	 WHERE SUBSTR(num_credito,10,3) <> "410"
          INTO TEMP capital;


        FOREACH SELECT num_credito, det
                  INTO v_credito, v_dif
                  FROM capital
                 WHERE sdo_cap_insoluto <> det 

		UPDATE sd_maesdos SET sdo_cap_insoluto = v_dif
		 WHERE num_credito = v_credito;


	END FOREACH

END
	RETURN scod_ret;
END PROCEDURE;