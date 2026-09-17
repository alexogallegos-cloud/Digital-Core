CREATE PROCEDURE "informix".apercred_uno( P_EMPRESA       VARCHAR(3)
                       , P_SOLICITUD       VARCHAR(29)
                       , P_FECHA_ALTA    DATE
                       , P_FECHA_VENC    DATE
                       )
RETURNING VARCHAR(10), VARCHAR(80), CHAR(20);

--*****************************************************
--DECLARACION DE VARIABLES
--*****************************************************
DEFINE V_SECUENCIA_MAX INTEGER;
DEFINE V_EQ_DIAS       INTEGER;
DEFINE V_EXISTE_REG    INTEGER;
DEFINE P_ERROR         VARCHAR(8);
DEFINE P_MENSAJE       VARCHAR(80);
DEFINE V_DIF_INT       INTEGER;
DEFINE V_FECHA_FIN_PRORRATEO  DATE;
DEFINE V_INSERT        INTEGER;
DEFINE V_E_CODTRASP    INTEGER;
define v_num_credito   char(20);
define vdigverif      char(1);
DEFINE SQL_ERR     INTEGER;
DEFINE ISAM_ERR    INTEGER;
DEFINE ERROR_INFO  VARCHAR(80);
define vcodret     char(5);

BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
         LET P_ERROR    = SQL_ERR;
         LET P_MENSAJE  = ERROR_INFO;
         RETURN P_ERROR, P_MENSAJE,v_num_credito;
    END EXCEPTION;

      --***********************
      --INICIALIZA VARIABLE
      --***********************



      LET V_EXISTE_REG = 0;
      LET P_ERROR      = '00000';
      LET P_MENSAJE    = 'PROCESO EXITOSO';
      LET V_EQ_DIAS    = 0;
      LET V_DIF_INT    = 0;
      LET V_FECHA_FIN_PRORRATEO = NULL;
      LET v_num_credito = "";

      SELECT COUNT(*)
      INTO   V_E_CODTRASP
      FROM   BDISOLIC:SS_SOLICITUDES SOL
           , SD_CODTRASP             CTR
      WHERE  CTR.PERIOD_PAG_INT  = SOL.PERIODO_PAG_INT
      AND    CTR.PERIOD_PAGO_CAP = SOL.PERIODO_PAG_CAP
      AND    CTR.NUM_PRODUCTO    = SOL.NUM_PRODUCTO
      AND    CTR.EMPRESA         = SOL.EMPRESA
      AND    SOL.NUM_SOLICITUD   = P_SOLICITUD
      AND    SOL.EMPRESA         = P_EMPRESA;

      IF V_E_CODTRASP = 0 THEN
         LET P_ERROR = '00100';
         LET P_MENSAJE = 'NO EXISTE INFORMACION DEL CODIGO DE TRASPASO';
         RETURN P_ERROR, P_MENSAJE,v_num_credito;
      END IF;

      CALL digvermod10(P_SOLICITUD)
           returning vcodret, vdigverif;
      let v_num_credito = trim(P_SOLICITUD)||vdigverif;

      SELECT SOL.DIFERIMIENTO_INT
      INTO   V_DIF_INT
      FROM   BDISOLIC:SS_SOLICITUDES SOL
      WHERE  SOL.EMPRESA = P_EMPRESA
      AND    SOL.NUM_SOLICITUD = P_SOLICITUD;

      IF V_DIF_INT = 0 THEN
         LET V_FECHA_FIN_PRORRATEO = P_FECHA_ALTA;
      ELSE
         LET V_FECHA_FIN_PRORRATEO = P_FECHA_ALTA + V_DIF_INT UNITS MONTH;
      END IF;

      --***** ACTUALIZA SD_MAECRED
      BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
         --SIPK_MENSAJES.SP_TRAE_MENSAJE (SQLCODE, SQLERRM, P_ERROR, P_MENSAJE);
         LET P_ERROR    = SQL_ERR;
         LET P_MENSAJE  = ERROR_INFO;
         RETURN P_ERROR, P_MENSAJE,v_num_credito;
    END EXCEPTION;

         INSERT INTO SD_MAECRED
               (EMPRESA                ,NUM_CREDITO
               ,NUM_PRODUCTO           ,EJECUTIVO
               ,NUMCTE                 ,DIVISA
               ,SUCURSAL               ,ID_ORIGEN
               ,ORIGEN                 ,COD_TIPO_LINEA
               ,COD_LINEA              ,PORC_REC_PROP
               ,STATUS_CRED            ,BANDERA_RENOVAC
               ,BANDERA_PRORROGA       ,PERIODO_PLAZO
               ,PLAZO                  ,FECHA_APERTURA
               ,FECHA_VENCIM           ,PERIOD_PAGO_CAP
               ,PERIOD_PAG_INT         ,DIAS_TRASP_CAP
               ,DIAS_TRASP_INT         ,TASA_FIJA_O_VAR
               ,COD_TASA_BASE          ,FACTOR_SOBRETASA
               ,SOBRETASA              ,TASA_INTERES
               ,COD_TASA_MORA          ,SOBRETASA_MORA
               ,FACT_SOBRET_MORA       ,TASA_MORATORIOS
               ,FECHA_PAGO_CAP         ,FECHA_PAGO_INT
               ,ES_FISICA              ,BANDERA_FI_FO
               ,CODIGO_PRO             ,SUPERFICIE
               ,ACTIVIDAD              ,CAL_EDOS_FIN
               ,TIPO_CALCULO           ,ADMITE_TLP
               ,REL_GARCRED            ,ID_UNIDAD_PROD
               ,NUM_APER_ANT           ,REV_TASA_VAR_PER
               ,DIA_PARA_REVISAR       ,COD_PROD
               ,BANDERA_MINISTRA       ,NUM_FIDEICOMISO
               ,CREDITO_EXTERNO        ,GRACIA_CAPITAL
               ,DIFERIMIENTO_INT       ,FECHA_FIN_PRORRATEO
               ,CAMPO_TRAB1            ,CAMPO_TRAB2
               ,CAMPO_TRAB3            ,CAMPO_TRAB4
               ,CALIFICACION_RIESGO    ,COD_AGRICOLA
               ,TASA_BASE_PISO         ,SOBRETASA_PISO
               ,FACTOR_PISO            ,TASA_PISO
               ,TASA_BASE_TECHO        ,SOBRETASA_TECHO
               ,FACTOR_TECHO           ,TASA_TECHO
               )
         SELECT SOL.EMPRESA                ,v_num_credito
               ,SOL.NUM_PRODUCTO           ,ANX.EJECUTIVO_SOL
               ,MAE.NUMCTE_CTO             ,SOL.DIVISA
               ,SOL.SUCURSAL               ,''
               ,''                         ,ANX.COD_TIPO_LINEA
               ,ANX.COD_LINEA              ,NVL(SOL.PORC_REC_PROP,0)
               ,'AA'                       ,'N'
               ,'N'                        ,SOL.PERIODO_PLAZO
               ,SOL.PLAZO                  ,P_FECHA_ALTA
               ,P_FECHA_VENC               ,SOL.PERIODO_PAG_CAP
               ,SOL.PERIODO_PAG_INT        ,CTR.DIAS_TRAS_CAP
               ,CTR.DIAS_TRAS_INT          ,SOL.TASA_FIJA_O_VAR
               ,SOL.COD_TASA_BASE          ,SOL.FACTOR_SOBRETASA
               ,SOL.SOBRETASA              ,SOL.TASA_INTERES
               ,SOL.COD_TASA_MORA          ,SOL.SOBRETASA_MORA
               ,SOL.FACT_SOBRET_MORA       ,SOL.TASA_MORATORIOS
               ,''                         ,''
               ,TIP.ES_FISICA              ,''
               ,DEF.COD_PROD               ,0
               ,ANX.ACTIVIDAD              ,''
               ,SOL.TIPO_CALCULO           ,''
               ,0                          ,''
               ,''                         ,SOL.REV_TASA_VAR_PER
               ,SOL.DIA_PARA_REVISAR       ,''
               ,'P'                        ,''
               ,''                         ,SOL.GRACIA_CAP
               ,SOL.DIFERIMIENTO_INT       ,V_FECHA_FIN_PRORRATEO
               ,0                          ,0
               ,''                         ,''
               ,'A'                        ,''
               ,SOL.TASA_BASE_PISO         ,SOL.SOBRETASA_PISO
               ,SOL.FACTOR_PISO            ,SOL.TASA_PISO
               ,SOL.TASA_BASE_TECHO        ,SOL.SOBRETASA_TECHO
               ,SOL.FACTOR_TECHO           ,SOL.TASA_TECHO
         FROM   BDISOLIC:SS_SOLICITUDES SOL
              , BDISOLIC:SS_ANEXOSOL    ANX
              , BDINTEG:SI_CLIENTE      CLI
              , BDINTEG:SI_TIPPER       TIP
              , SD_CODTRASP             CTR
              , BDISOLIC:SS_MAECONTRATO MAE
              , SD_DEFINICION           DEF
         WHERE  DEF.EMPRESA         = SOL.EMPRESA
         AND    DEF.NUM_PRODUCTO    = SOL.NUM_PRODUCTO
         AND    MAE.EMPRESA         = SOL.EMPRESA
         AND    MAE.NUM_CONTRATO    = P_SOLICITUD
         AND    CTR.PERIOD_PAG_INT  = SOL.PERIODO_PAG_INT
         AND    CTR.PERIOD_PAGO_CAP = SOL.PERIODO_PAG_CAP
         AND    CTR.NUM_PRODUCTO    = SOL.NUM_PRODUCTO
         AND    CTR.EMPRESA         = SOL.EMPRESA
         AND    TIP.TPO_PERSONA     = CLI.TPO_PERSONA
         AND    CLI.NUMCTE          = SOL.NUMCTE
         AND    CLI.EMPRESA         = SOL.EMPRESA
         AND    ANX.NUM_SOLICITUD   = SOL.NUM_SOLICITUD
         AND    ANX.EMPRESA         = SOL.EMPRESA
         AND    SOL.NUM_SOLICITUD   = P_SOLICITUD
         AND    SOL.EMPRESA         = P_EMPRESA;
      END;

      --LET V_INSERT = DBINFO("SQLCA.SQLERRD1");
      --IF V_INSERT = 0 THEN
         --LET P_ERROR = '00001';
         --LET P_MENSAJE = 'EXISTE ERROR EN LA INFORMACIÓN DEL CRÉDITO';
         --RETURN P_ERROR, P_MENSAJE,v_num_credito;
      --END IF;
      --***** ACTUALIZA SD_MAESDOS

    BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
         LET P_ERROR    = SQL_ERR;
         LET P_MENSAJE  = ERROR_INFO;
         RETURN P_ERROR, P_MENSAJE,v_num_credito;
    END EXCEPTION;

         INSERT INTO SD_MAESDOS (EMPRESA                ,NUM_CREDITO
                                ,FECHA_ULT_MOV          ,SDO_INT_ANTICIP
                                ,SDO_INT_ANT_DEV        ,SDO_INTERESES
                                ,SDO_DIA_ANT_INT        ,SDO_MES_ANT_INT
                                ,SDO_ACUM_MES_INT       ,FAVP
                                ,SDO_ACUM_CAP_INT       ,SDO_EXIG_INT
                                ,SDO_NO_EXIG            ,PROVISION_NORMAL
                                ,DIAS_ACUM_INT          ,SDO_MORATORIO
                                ,SDO_DIA_ANT_MOR        ,SDO_MES_ANT_MOR
                                ,SDO_CONTAB_MORA        ,DIAS_ACUM_MORA
                                ,SDO_CAPITAL            ,SDO_CAP_INSOLUTO
                                ,SDO_DIA_ANT_CAP        ,SDO_MES_ANT_CAP
                                ,SDO_ACUM_MES_CAP       ,MTO_CAPITALIZADO
                                ,MTO_MINISTRA_CAP       ,CARGOS_DIA_CAP
                                ,ABONOS_DIA_CAP         ,CARGOS_MES_CAP
                                ,ABONOS_MES_CAP         ,DIAS_ACUM_CAP
                                ,MONTO_VENCIDO          ,MTO_VENC_TRASP
                                ,MONTO_FINANCIADO       ,MONTO_RESERVADO
                                ,SDO_ACUM_VENCIDO       ,DIAS_ACUM_INTPER
                                ,SDO_GLOBAL_INT         ,SDO_ACUM_INTPER
                                ,MONTO_OTORGADO         ,PROVI_VENC_NORMAL
                                ,PROVI_VENC_ANTICIP     ,CAP_TRAS_NO_VENCI
                                ,MTO_VENC_INT           ,MTO_VENC_TRA_INT
                                ,MTO_FINAN_VDO          ,MTO_RESER_INT
                                ,MTO_FIN_VEN_TRASP      ,MTO_FIN_VIG_TRASP
                                ,INT_TRA_NO_EXIG        ,SDO_TRAB4
                                )
                          SELECT SOL.EMPRESA            ,v_num_credito
                                ,TODAY                  ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,MAE.MONTO_AUTO_CONT    ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                          FROM   BDISOLIC:SS_SOLICITUDES SOL
                                ,BDISOLIC:SS_MAECONTRATO MAE
                          WHERE  MAE.EMPRESA       = SOL.EMPRESA
                          AND    MAE.NUM_CONTRATO  = P_SOLICITUD
                          AND    SOL.NUM_SOLICITUD = P_SOLICITUD
                          AND    SOL.EMPRESA   = P_EMPRESA;
      END;

    --***** ACTUALIZA SD_MAECONTRATO
    BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
         --SIPK_MENSAJES.SP_TRAE_MENSAJE (SQLCODE, SQLERRM, P_ERROR, P_MENSAJE);
         LET P_ERROR    = SQL_ERR;
         LET P_MENSAJE  = ERROR_INFO;
         RETURN P_ERROR, P_MENSAJE,v_num_credito;
    END EXCEPTION;

         INSERT INTO SD_MAECONTRATO (EMPRESA                ,NUM_CONTRATO
                                    ,FECHA_SUSCRIPCION      ,DATOS_REGISTRO
                                    ,FECHA_VENC_CONT        ,NUMCTE_CTO
                                    ,MONTO_AUTO_CONT        ,MONTO_EJERCIDO
                                    ,TIPO_CREDITO           ,CON_GARANTIAS
                                    ,DIVISA                 ,ES_UNION_CREDITO
                                    ,CONV_TRASP_MN          ,ESTADO_CONTRATO
                                    ,TIPO_CONTRATO          ,OBSERVACIONES
                                    ,NUMERO_CONT_ORIG       ,STATUS_IMPRE
                                    )
                             SELECT EMPRESA                ,v_num_credito
                                   ,FECHA_SUSCRIPCION      ,DATOS_REGISTRO
                                   ,FECHA_VENC_CONT        ,NUMCTE_CTO
                                   ,MONTO_AUTO_CONT        ,MONTO_EJERCIDO
                                   ,TIPO_CREDITO           ,CON_GARANTIAS
                                   ,DIVISA                 ,ES_UNION_CREDITO
                                   ,CONV_TRASP_MN          ,ESTADO_CONTRATO
                                   ,TIPO_CONTRATO          ,OBSERVACIONES
                                   ,NUMERO_CONT_ORIG       ,STATUS_IMPRE
                             FROM   BDISOLIC:SS_MAECONTRATO
                             WHERE  NUM_CONTRATO = P_SOLICITUD
                             AND    EMPRESA      = P_EMPRESA;
    END;

      RETURN P_ERROR, P_MENSAJE,v_num_credito;
END;
END PROCEDURE;