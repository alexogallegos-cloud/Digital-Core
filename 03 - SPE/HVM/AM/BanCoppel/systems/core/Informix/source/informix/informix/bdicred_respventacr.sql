CREATE PROCEDURE "informix".respventacr(eEmpresa    CHAR(3),

                             eNumCredito CHAR(20),
                             eFecha      date)
   RETURNING CHAR(5);   --CodRet


   DEFINE CodRet              CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nrows               SMALLINT;
   DEFINE Mensaje             CHAR(80);

   DEFINE wSecuenciaPago      LIKE sd_secpago.secuencia;
   
   LET CodRet = "000";

--set debug file to "respventacr.out";
--trace on;


  LET eNumCredito = eNumCredito;
  LET eFecha = eFecha;
  LET eEmpresa    = eEmpresa;

      --FMV 20-ENE-2012 : ERROR -268 INFORMIX    
        DELETE FROM "informix".sd_maecred_vendida WHERE empresa = eEmpresa 
                                                     AND num_credito = eNumCredito;
        DELETE FROM "informix".sd_maesdos_vendida WHERE empresa = eEmpresa 
                                                     AND num_credito = eNumCredito;
        DELETE FROM "informix".sd_amortiza_credito_vendida WHERE empresa = eEmpresa 
                                                             AND num_credito = eNumCredito;
	  --Se agrega la nueva tabla sd_maecred_vend_total copia de la maecred_vendida
		DELETE FROM "informix".sd_maecred_vend_total WHERE num_credito = eNumCredito;

                             --**    Respalda Maecred                          --
   INSERT INTO sd_maecred_vendida
        (fecha             , empresa         , num_credito     , num_producto    , ejecutivo          ,
         numcte            , divisa          , sucursal        , id_origen       , origen             ,
         cod_tipo_linea    , cod_linea       , porc_rec_prop   , status_cred     , bandera_renovac    ,
         bandera_prorroga  , periodo_plazo   , plazo           , fecha_apertura  , fecha_vencim       ,
         period_pago_cap   , period_pag_int  , dias_trasp_cap  , dias_trasp_int  , tasa_fija_o_var    ,
         cod_tasa_base     , factor_sobretasa, sobretasa       , tasa_interes    , cod_tasa_mora      ,
         sobretasa_mora    , fact_sobret_mora, tasa_moratorios , fecha_pago_cap  , fecha_pago_int     ,
         es_fisica         , bandera_fi_fo   , codigo_pro      , superficie      , actividad          ,
         cal_edos_fin      , tipo_calculo    , admite_tlp      , rel_garcred     , id_unidad_prod     ,
         num_aper_ant      , rev_tasa_var_per, dia_para_revisar, cod_prod        , bandera_ministra   ,
         num_fideicomiso   , credito_externo , gracia_capital  , diferimiento_int, fecha_fin_prorrateo,
         campo_trab1       , campo_trab2     , campo_trab3     , campo_trab4     , calificacion_riesgo,
         cod_agricola      , tasa_base_piso  , sobretasa_piso  , factor_piso     , tasa_piso          ,
         tasa_base_techo   , sobretasa_techo , factor_techo    , tasa_techo      , cod_caract         ,
         cod_caract_2     
		 ,cuenta_clabe)
   SELECT
         eFecha            , empresa         , num_credito     , num_producto    , ejecutivo         ,
         numcte            , divisa          , sucursal        , id_origen       , origen             ,
         cod_tipo_linea    , cod_linea       , porc_rec_prop   , status_cred     , bandera_renovac    ,
         bandera_prorroga  , periodo_plazo   , plazo           , fecha_apertura  , fecha_vencim       ,
         period_pago_cap   , period_pag_int  , dias_trasp_cap  , dias_trasp_int  , tasa_fija_o_var    ,
         cod_tasa_base     , factor_sobretasa, sobretasa       , tasa_interes    , cod_tasa_mora      ,
         sobretasa_mora    , fact_sobret_mora, tasa_moratorios , fecha_pago_cap  , fecha_pago_int     ,
         es_fisica         , bandera_fi_fo   , codigo_pro      , superficie      , actividad          ,
         cal_edos_fin      , tipo_calculo    , admite_tlp      , rel_garcred     , id_unidad_prod     ,
         num_aper_ant      , rev_tasa_var_per, dia_para_revisar, cod_prod        , bandera_ministra   ,
         num_fideicomiso   , credito_externo , gracia_capital  , diferimiento_int, fecha_fin_prorrateo,
         campo_trab1       , campo_trab2     , campo_trab3     , campo_trab4     , calificacion_riesgo,
         cod_agricola      , tasa_base_piso  , sobretasa_piso  , factor_piso     , tasa_piso          ,
         tasa_base_techo   , sobretasa_techo , factor_techo    , tasa_techo      , cod_caract         ,
         cod_caract_2		,cuenta_clabe
    FROM sd_maecred
   WHERE num_credito = eNumCredito
   AND   empresa = eEmpresa;


	--Se inserta a la nueva tabla historica			
	INSERT INTO sd_maecred_vend_total
        (fecha,num_credito,num_producto,numcte,status_cred,fecha_apertura,credito_externo)
   SELECT
        eFecha,num_credito,num_producto,numcte,status_cred,fecha_apertura,credito_externo
    FROM sd_maecred
   WHERE num_credito = eNumCredito;

                             --**    Respalda Maesdos      --

   INSERT INTO sd_maesdos_vendida
         (fecha              , empresa             , num_credito      , fecha_ult_mov     , sdo_int_anticip  ,
          sdo_int_ant_dev    , sdo_intereses       , sdo_dia_ant_int  , sdo_mes_ant_int   , sdo_acum_mes_int ,
          sdo_retenido       , sdo_acum_cap_int    , sdo_exig_int     , sdo_no_exig       , provision_normal ,
          dias_acum_int      , sdo_moratorio       , sdo_dia_ant_mor  , sdo_mes_ant_mor   , sdo_contab_mora  ,
          dias_acum_mora     , sdo_capital         , sdo_cap_insoluto , sdo_dia_ant_cap   , sdo_mes_ant_cap  ,
          sdo_acum_mes_cap   , mto_capitalizado    , mto_ministra_cap , cargos_dia_cap    , abonos_dia_cap   ,
          cargos_mes_cap     , abonos_mes_cap      , dias_acum_cap    , monto_vencido     , mto_venc_trasp   ,
          monto_financiado   , monto_reservado     , sdo_acum_vencido , dias_acum_intper  , sdo_global_int   ,
          sdo_acum_intper    , monto_otorgado      , provi_venc_normal, provi_venc_anticip, cap_tras_no_venci,
          mto_venc_int       , mto_venc_tra_int    , mto_finan_vdo    , mto_reser_int     , mto_fin_ven_trasp,
          mto_fin_vig_trasp  , int_tra_no_exig     , sdo_trab4        )
   SELECT
          eFecha             , empresa             , num_credito      ,  fecha_ult_mov    , sdo_int_anticip   ,
          sdo_int_ant_dev    , sdo_intereses       , sdo_dia_ant_int  , sdo_mes_ant_int   , sdo_acum_mes_int ,
          sdo_retenido       , sdo_acum_cap_int    , sdo_exig_int     , sdo_no_exig       , provision_normal ,
          dias_acum_int      , sdo_moratorio       , sdo_dia_ant_mor  , sdo_mes_ant_mor   , sdo_contab_mora  ,
          dias_acum_mora     , sdo_capital         , sdo_cap_insoluto , sdo_dia_ant_cap   , sdo_mes_ant_cap  ,
          sdo_acum_mes_cap   , mto_capitalizado    , mto_ministra_cap , cargos_dia_cap    , abonos_dia_cap   ,
          cargos_mes_cap     , abonos_mes_cap      , dias_acum_cap    , monto_vencido     , mto_venc_trasp   ,
          monto_financiado   , monto_reservado     , sdo_acum_vencido , dias_acum_intper  , sdo_global_int   ,
          sdo_acum_intper    , monto_otorgado      , provi_venc_normal, provi_venc_anticip, cap_tras_no_venci,
          mto_venc_int       , mto_venc_tra_int    , mto_finan_vdo    , mto_reser_int     , mto_fin_ven_trasp,
          mto_fin_vig_trasp  , int_tra_no_exig     , sdo_trab4
   FROM sd_maesdos
   WHERE empresa   = eEmpresa
   AND num_credito = eNumCredito;

                             --**    Respalda AmortizaCredito --

  INSERT INTO sd_amortiza_credito_vendida(
       fecha                  , empresa          , num_credito            , fecha_cuota            , tipo_cuota             ,
       capital_mto_cuota      , capital_debe     , capital_pagado         , capital_status         , capital_status_ant     ,
       capital_fecha_pago     , interes_debe     , interes_pagado         , interes_status         , interes_status_ant     ,
       interes_fecha_pago     , iva_debe         , iva_pagado             , iva_status             , iva_status_ant         ,
       iva_fecha_pago         , mora_provi_ordi  , mora_provi_cope        , mora_sdo_ordi          , mora_sdo_ordi_pag      ,
       mora_sdo_cope          , mora_sdo_cope_pag, mora_bonificado        , mora_status            , mora_iva_debe          ,
       mora_iva_pagado        , mora_iva_status  , mora_iva_fecha_pago    , num_pago               , campo_trabajo1         ,
       campo_trabajo2         , campo_trabajo3   , campo_trabajo4         )
  SELECT
       eFecha                 , empresa          , num_credito            , fecha_cuota            , tipo_cuota             ,
       capital_mto_cuota      , capital_debe     , capital_pagado         , capital_status         , capital_status_ant     ,
       capital_fecha_pago     , interes_debe     , interes_pagado         , interes_status         , interes_status_ant     ,
       interes_fecha_pago     , iva_debe         , iva_pagado             , iva_status             , iva_status_ant         ,
       iva_fecha_pago         , mora_provi_ordi  , mora_provi_cope        , mora_sdo_ordi          , mora_sdo_ordi_pag      ,
       mora_sdo_cope          , mora_sdo_cope_pag, mora_bonificado        , mora_status            , mora_iva_debe          ,
       mora_iva_pagado        , mora_iva_status  , mora_iva_fecha_pago    , num_pago               , campo_trabajo1         ,
       campo_trabajo2         , campo_trabajo3   , campo_trabajo4
 FROM sd_amortiza_credito
 WHERE empresa     = eEmpresa
   ANd Num_credito = eNumCredito;

   RETURN CodRet;

END PROCEDURE
;