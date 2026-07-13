CREATE PROCEDURE "informix".genera_respaldo( p_empresa      VARCHAR
                            , p_credito    VARCHAR
                            , p_solicitud  VARCHAR
                            , p_usuario    VARCHAR)
RETURNING varchar(80);
  --Este procedimiento crea el respaldo de y para las tablas:
  -- SD_PAGINTER.............SS_PAGINTERBAK
  -- SD_PAGOCAPIT............SS_PAGOCAPITBAK
  -- SD_MAECONTRATO..........SS_MAECONTRATOBAK
  -- SD_MAECRED..............SS_MAECRED
  -- SD_MAESDOS..............SS_MAESDOSBAK

  DEFINE P_COD_RET   VARCHAR(100);
  DEFINE P_MENSAJE   VARCHAR(150);
  DEFINE p_error     VARCHAR(80);
  DEFINE sql_err     INTEGER;

  BEGIN

    ON EXCEPTION SET sql_err
       IF sql_err <> 0 then
          LET p_error = 'ocurrio un Error';
          RETURN p_error;
       END IF
    END EXCEPTION;
      --*****************************
      --se genera el respaldo de la tabla SD_PAGINTER
      LET p_error = ' en respaldo de SD_PAGINTER ';
      insert into ss_paginterbak (EMPRESA          ,NUM_CREDITO       ,FECHA_CUOTA
                                 ,CUOTA_REC        ,MONTO_CUOTA       ,MONTO_REAL_PAG
                                 ,FECHA_PAG        ,FACTOR_MORATORIO  ,MONTO_MORATORIO
                                 ,FECHA_MORATORIO  ,DIAS_MORATORIO    ,STATUS_MORATORIO
                                 ,BONIFI_INT_MORA  ,PORC_PAGO         ,STATUS_CUOTA
                                 ,MONTO_FINANCIADO ,NUM_SOLICITUD     ,USER_INSERT
                                 ,FECHA_INSERT
                                 )
                           select EMPRESA          ,NUM_CREDITO       ,FECHA_CUOTA
                                 ,CUOTA_REC        ,MONTO_CUOTA       ,MONTO_REAL_PAG
                                 ,FECHA_PAG        ,FACTOR_MORATORIO  ,MONTO_MORATORIO
                                 ,FECHA_MORATORIO  ,DIAS_MORATORIO    ,STATUS_MORATORIO
                                 ,BONIFI_INT_MORA  ,PORC_PAGO         ,STATUS_CUOTA
                                 ,MONTO_FINANCIADO ,p_solicitud       ,p_usuario
                                 ,EXTEND(CURRENT,HOUR TO FRACTION)
                           from   sd_paginter
                           where  num_credito = p_credito
                           and    empresa     = p_empresa;

      --*****************************
      --se genera el respaldo de la tabla SD_PAGOCAPIT
      LET p_error = ' en respaldo de SD_PAGOCAPIT ';
      insert into ss_pagocapitbak (EMPRESA          ,NUM_SOLICITUD     ,NUM_CREDITO
                                  ,FECHA_CUOTA      ,CUOTA_REC         ,MONTO_CUOTA
                                  ,SALDO_CUOTA      ,IMP_CAPITALIZADO  ,FACTOR_AJUSTE
                                  ,MONTO_REAL_PAG   ,FECHA_PAGO        ,FACTOR_MORATORIO
                                  ,MONTO_MORATORIO  ,FECHA_MORATORIO   ,DIAS_MORATORIOS
                                  ,STATUS_MORATORIO ,NUM_PAGARES       ,PORC_PAGO
                                  ,BANDERA_MINISTRA ,STATUS_CUOTA      ,USER_INSERT
                                  ,FECHA_INSERT
                                  )
                           select EMPRESA            ,p_solicitud      ,NUM_CREDITO
                                 ,FECHA_CUOTA        ,CUOTA_REC        ,MONTO_CUOTA
                                 ,SALDO_CUOTA        ,IMP_CAPITALIZADO ,FACTOR_AJUSTE
                                 ,MONTO_REAL_PAG     ,FECHA_PAGO       ,FACTOR_MORATORIO
                                 ,MONTO_MORATORIO    ,FECHA_MORATORIO  ,DIAS_MORATORIOS
                                 ,STATUS_MORATORIO   ,NUM_PAGARES      ,PORC_PAGO
                                 ,BANDERA_MINISTRA   ,STATUS_CUOTA     , p_usuario
                                 ,EXTEND(CURRENT,HOUR TO FRACTION)
                             from sd_pagocapit
                            where num_credito = p_credito
                            and   empresa = p_empresa;

      --*****************************
      --se genera el respaldo de la tabla SD_MAECONTRATO
      LET p_error = ' en respaldo de SD_MAECONTRATO ';
      insert into ss_maecontratobak (EMPRESA            ,NUM_SOLICITUD     ,NUM_CONTRATO
                                    ,FECHA_SUSCRIPCION  ,DATOS_REGISTRO    ,FECHA_VENC_CONT
                                    ,NUMCTE_CTO         ,MONTO_AUTO_CONT   ,MONTO_EJERCIDO
                                    ,TIPO_CREDITO       ,CON_GARANTIAS     ,DIVISA
                                    ,ES_UNION_CREDITO   ,CONV_TRASP_MN     ,ESTADO_CONTRATO
                                    ,TIPO_CONTRATO      ,OBSERVACIONES     ,NUMERO_CONT_ORIG
                                    ,STATUS_IMPRE
                                    )
                              select EMPRESA            ,p_SOLICITUD       ,NUM_CONTRATO
                                    ,FECHA_SUSCRIPCION  ,DATOS_REGISTRO    ,FECHA_VENC_CONT
                                    ,NUMCTE_CTO         ,MONTO_AUTO_CONT   ,MONTO_EJERCIDO
                                    ,TIPO_CREDITO       ,CON_GARANTIAS     ,DIVISA
                                    ,ES_UNION_CREDITO   ,CONV_TRASP_MN     ,ESTADO_CONTRATO
                                    ,TIPO_CONTRATO      ,OBSERVACIONES     ,NUMERO_CONT_ORIG
                                    ,STATUS_IMPRE
                              from   sd_maecontrato
                              where  num_contrato = substr(p_credito,1,14)
                              and    empresa = p_empresa;

      --*****************************
      --se genera el respaldo de la tabla SD_MAECRED
      LET p_error = ' en respaldo de SD_MAECRED ';
      insert into ss_maecredbak ( EMPRESA             ,NUM_SOLICITUD     ,NUM_CREDITO
                                , NUM_PRODUCTO        ,EJECUTIVO         ,NUMCTE
                                , DIVISA              ,SUCURSAL          ,ID_ORIGEN
                                , ORIGEN              ,COD_TIPO_LINEA    ,COD_LINEA
                                , PORC_REC_PROP       ,STATUS_CRED       ,BANDERA_RENOVAC
                                , BANDERA_PRORROGA    ,PERIODO_PLAZO     ,PLAZO
                                , FECHA_APERTURA      ,FECHA_VENCIM      ,PERIOD_PAGO_CAP
                                , PERIOD_PAG_INT      ,DIAS_TRASP_CAP    ,DIAS_TRASP_INT
                                , TASA_FIJA_O_VAR     ,COD_TASA_BASE     ,FACTOR_SOBRETASA
                                , SOBRETASA           ,TASA_INTERES      ,COD_TASA_MORA
                                , SOBRETASA_MORA      ,FACT_SOBRET_MORA  ,TASA_MORATORIOS
                                , FECHA_PAGO_CAP      ,FECHA_PAGO_INT    ,ES_FISICA
                                , BANDERA_FI_FO       ,CODIGO_PRO        ,SUPERFICIE
                                , ACTIVIDAD           ,CAL_EDOS_FIN      ,TIPO_CALCULO
                                , ADMITE_TLP          ,REL_GARCRED       ,ID_UNIDAD_PROD
                                , NUM_APER_ANT        ,REV_TASA_VAR_PER  ,DIA_PARA_REVISAR
                                , COD_PROD            ,BANDERA_MINISTRA  ,NUM_FIDEICOMISO
                                , CREDITO_EXTERNO     ,GRACIA_CAPITAL    ,DIFERIMIENTO_INT
                                , FECHA_FIN_PRORRATEO ,CAMPO_TRAB1       ,CAMPO_TRAB2
                                , CAMPO_TRAB3         ,CAMPO_TRAB4       ,CALIFICACION_RIESGO
                                , COD_AGRICOLA        ,TASA_BASE_PISO    ,SOBRETASA_PISO
                                , FACTOR_PISO         ,TASA_PISO         ,TASA_BASE_TECHO
                                , SOBRETASA_TECHO     ,FACTOR_TECHO      ,TASA_TECHO
                                , USER_INSERT         ,FECHA_INSERT
                                )
                           select EMPRESA             ,p_solicitud       ,NUM_CREDITO
                                , NUM_PRODUCTO        ,EJECUTIVO         ,NUMCTE
                                , DIVISA              ,SUCURSAL          ,ID_ORIGEN
                                , ORIGEN              ,COD_TIPO_LINEA    ,COD_LINEA
                                , PORC_REC_PROP       ,STATUS_CRED       ,BANDERA_RENOVAC
                                , BANDERA_PRORROGA    ,PERIODO_PLAZO     ,PLAZO
                                , FECHA_APERTURA      ,FECHA_VENCIM      ,PERIOD_PAGO_CAP
                                , PERIOD_PAG_INT      ,DIAS_TRASP_CAP    ,DIAS_TRASP_INT
                                , TASA_FIJA_O_VAR     ,COD_TASA_BASE     ,FACTOR_SOBRETASA
                                , SOBRETASA           ,TASA_INTERES      ,COD_TASA_MORA
                                , SOBRETASA_MORA      ,FACT_SOBRET_MORA  ,TASA_MORATORIOS
                                , FECHA_PAGO_CAP      ,FECHA_PAGO_INT    ,ES_FISICA
                                , BANDERA_FI_FO       ,CODIGO_PRO        ,SUPERFICIE
                                , ACTIVIDAD           ,CAL_EDOS_FIN      ,TIPO_CALCULO
                                , ADMITE_TLP          ,REL_GARCRED       ,ID_UNIDAD_PROD
                                , NUM_APER_ANT        ,REV_TASA_VAR_PER  ,DIA_PARA_REVISAR
                                , COD_PROD            ,BANDERA_MINISTRA  ,NUM_FIDEICOMISO
                                , CREDITO_EXTERNO     ,GRACIA_CAPITAL    ,DIFERIMIENTO_INT
                                , FECHA_FIN_PRORRATEO ,CAMPO_TRAB1       ,CAMPO_TRAB2
                                , CAMPO_TRAB3         ,CAMPO_TRAB4       ,CALIFICACION_RIESGO
                                , COD_AGRICOLA        ,TASA_BASE_PISO    ,SOBRETASA_PISO
                                , FACTOR_PISO         ,TASA_PISO         ,TASA_BASE_TECHO
                                , SOBRETASA_TECHO     ,FACTOR_TECHO      ,TASA_TECHO
                                , p_usuario           ,EXTEND(CURRENT,HOUR TO FRACTION)
                             from sd_maecred
                            where num_credito = p_credito
                              and empresa     = p_empresa;

      --*****************************
      --se genera el respaldo de la tabla SD_MAESDOS
      LET p_error = ' en respaldo de SD_MAESDOS ';
      insert into ss_maesdosbak (EMPRESA           ,NUM_SOLICITUD      ,NUM_CREDITO
                                ,FECHA_ULT_MOV     ,SDO_INT_ANTICIP    ,SDO_INT_ANT_DEV
                                ,SDO_INTERESES     ,SDO_DIA_ANT_INT    ,SDO_MES_ANT_INT
                                ,SDO_ACUM_MES_INT  ,FAVP               ,SDO_ACUM_CAP_INT
                                ,SDO_EXIG_INT      ,SDO_NO_EXIG        ,PROVISION_NORMAL
                                ,DIAS_ACUM_INT     ,SDO_MORATORIO      ,SDO_DIA_ANT_MOR
                                ,SDO_MES_ANT_MOR   ,SDO_CONTAB_MORA    ,DIAS_ACUM_MORA
                                ,SDO_CAPITAL       ,SDO_CAP_INSOLUTO   ,SDO_DIA_ANT_CAP
                                ,SDO_MES_ANT_CAP   ,SDO_ACUM_MES_CAP   ,MTO_CAPITALIZADO
                                ,MTO_MINISTRA_CAP  ,CARGOS_DIA_CAP     ,ABONOS_DIA_CAP
                                ,CARGOS_MES_CAP    ,ABONOS_MES_CAP     ,DIAS_ACUM_CAP
                                ,MONTO_VENCIDO     ,MTO_VENC_TRASP     ,MONTO_FINANCIADO
                                ,MONTO_RESERVADO   ,SDO_ACUM_VENCIDO   ,DIAS_ACUM_INTPER
                                ,SDO_GLOBAL_INT    ,SDO_ACUM_INTPER    ,MONTO_OTORGADO
                                ,PROVI_VENC_NORMAL ,PROVI_VENC_ANTICIP ,CAP_TRAS_NO_VENCI
                                ,MTO_VENC_INT      ,MTO_VENC_TRA_INT   ,MTO_FINAN_VDO
                                ,MTO_RESER_INT     ,MTO_FIN_VEN_TRASP  ,MTO_FIN_VIG_TRASP
                                ,INT_TRA_NO_EXIG   ,SDO_TRAB4          ,USER_INSERT
                                ,FECHA_INSERT
                                )
                         select  EMPRESA           ,p_SOLICITUD        ,NUM_CREDITO
                                ,FECHA_ULT_MOV     ,SDO_INT_ANTICIP    ,SDO_INT_ANT_DEV
                                ,SDO_INTERESES     ,SDO_DIA_ANT_INT    ,SDO_MES_ANT_INT
                                ,SDO_ACUM_MES_INT  ,FAVP               ,SDO_ACUM_CAP_INT
                                ,SDO_EXIG_INT      ,SDO_NO_EXIG        ,PROVISION_NORMAL
                                ,DIAS_ACUM_INT     ,SDO_MORATORIO      ,SDO_DIA_ANT_MOR
                                ,SDO_MES_ANT_MOR   ,SDO_CONTAB_MORA    ,DIAS_ACUM_MORA
                                ,SDO_CAPITAL       ,SDO_CAP_INSOLUTO   ,SDO_DIA_ANT_CAP
                                ,SDO_MES_ANT_CAP   ,SDO_ACUM_MES_CAP   ,MTO_CAPITALIZADO
                                ,MTO_MINISTRA_CAP  ,CARGOS_DIA_CAP     ,ABONOS_DIA_CAP
                                ,CARGOS_MES_CAP    ,ABONOS_MES_CAP     ,DIAS_ACUM_CAP
                                ,MONTO_VENCIDO     ,MTO_VENC_TRASP     ,MONTO_FINANCIADO
                                ,MONTO_RESERVADO   ,SDO_ACUM_VENCIDO   ,DIAS_ACUM_INTPER
                                ,SDO_GLOBAL_INT    ,SDO_ACUM_INTPER    ,MONTO_OTORGADO
                                ,PROVI_VENC_NORMAL ,PROVI_VENC_ANTICIP ,CAP_TRAS_NO_VENCI
                                ,MTO_VENC_INT      ,MTO_VENC_TRA_INT   ,MTO_FINAN_VDO
                                ,MTO_RESER_INT     ,MTO_FIN_VEN_TRASP  ,MTO_FIN_VIG_TRASP
                                ,INT_TRA_NO_EXIG   ,SDO_TRAB4          ,p_usuario
                                ,EXTEND(CURRENT,HOUR TO FRACTION)
                          from   sd_maesdos
                          where  num_credito = p_credito
                          and    empresa = p_empresa;
       LET p_error = ' exitoso ';

  END;
RETURN p_error;
END PROCEDURE;