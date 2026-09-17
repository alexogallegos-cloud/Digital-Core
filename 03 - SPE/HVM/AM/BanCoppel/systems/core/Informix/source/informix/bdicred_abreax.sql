CREATE PROCEDURE "informix".abreax()
define pempresa CHAR(3);
DEFINE pnum_solicitud CHAR(20);
DEFINE V_SECUENCIA_MAX INTEGER;
DEFINE V_EQ_DIAS       INTEGER;
DEFINE V_EXISTE_REG    INTEGER;
DEFINE P_ERROR         VARCHAR(8);
DEFINE P_MENSAJE       VARCHAR(80);
DEFINE V_DIF_INT       INTEGER;
DEFINE V_FECHA_FIN_PRORRATEO  DATE;
DEFINE V_INSERT        INTEGER;
DEFINE V_E_CODTRASP    INTEGER;
DEFINE V_TASA_INTERES  DECIMAL(9,6);
DEFINE V_TASA_MORA     DECIMAL(9,6);
DEFINE V_SOBRETASA     DECIMAL(9,6);
DEFINE V_TASA_FAVOR    DECIMAL(9,6);
DEFINE V_SOBRETASA_FAV DECIMAL(9,6);
DEFINE V_FACTOR        CHAR(1);
DEFINE V_FECHA_APERT   DATE;
DEFINE V_FECHA_VENC    DATE;
define v_num_credito   char(20);
define vdigverif      char(1);
DEFINE SQL_ERR     INTEGER;
DEFINE ISAM_ERR    INTEGER;
DEFINE ERROR_INFO  VARCHAR(80);
define vcodret     char(5);
DEFINE vNumCte     CHAR(20);
DEFINE vTpCte      CHAR(1);
DEFINE vIngreso    DECIMAL(14,2);
DEFINE V_FACTOR_FAV CHAR(1);
DEFINE V_PRODUCTO  CHAR(4);
DEFINE VV_DIVISA   CHAR(2);
DEFINE V_MONTO     DECIMAL(14,2);
DEFINE VV_SUCURSAL CHAR(4);
DEFINE VV_FOLIO  	CHAR(16);
DEFINE cStatus_cred CHAR(2);
DEFINE cIFRS		CHAR(1);

LET cStatus_cred = '';
LET cIFRS		 = '';



SELECT valor INTO cIFRS FROM bdicred:sd_param WHERE cod_param = '700';
IF cIFRS = 'A' THEN
	LET cStatus_cred = 'E1';
ELSE
	LET cStatus_cred = 'AA';
END IF;


foreach select empresa, num_solicitud
	into pempresa, pnum_solicitud
	from bdisolic:ss_solicitudes
	where status_solicitud ="AP"

        --INTERES ORDINARIO
        SELECT c.valor, a.factor_sobretasa, a.sobretasa
          INTO V_TASA_INTERES, V_FACTOR, V_SOBRETASA
          FROM sd_definicion a, bdisolic:ss_solicitudes b,
               bdinteg:si_fechavalor c
         WHERE b.empresa = pempresa
           AND num_solicitud = pnum_solicitud
           AND a.empresa = b.empresa
           AND a.num_producto = b.num_producto
           AND c.empresa = a.empresa
           AND c.tasa = a.cod_tasa_base
           AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
                           WHERE r.empresa = pempresa
                             AND r.tasa = a.cod_tasa_base);
        IF v_factor = "+" THEN
                LET V_TASA_INTERES = V_TASA_INTERES + V_SOBRETASA;
        ELIF v_factor = "-" THEN
                LET V_TASA_INTERES = V_TASA_INTERES - V_SOBRETASA;
        ELIF v_factor = "*" THEN
                LET V_TASA_INTERES = V_TASA_INTERES * V_SOBRETASA;
        ELSE
                LET V_TASA_INTERES = V_TASA_INTERES / V_SOBRETASA;
        END IF

        --INTERES MORATORIO
        SELECT c.valor, a.fact_sobret_mora, a.sobretasa_mora
          INTO V_TASA_MORA   , V_FACTOR, V_SOBRETASA
          FROM sd_definicion a, bdisolic:ss_solicitudes b,
               bdinteg:si_fechavalor c
         WHERE b.empresa = pempresa
           AND num_solicitud = pnum_solicitud
           AND a.empresa = b.empresa
           AND a.num_producto = b.num_producto
           AND c.empresa = a.empresa
           AND c.tasa = a.cod_tasa_mora
           AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
                           WHERE r.empresa = pempresa
                             AND r.tasa = a.cod_tasa_mora);

        IF v_factor = "+" THEN
                LET V_TASA_MORA = V_TASA_MORA + V_SOBRETASA;
        ELIF v_factor = "-" THEN
                LET V_TASA_MORA = V_TASA_MORA - V_SOBRETASA;
        ELIF v_factor = "*" THEN
                LET V_TASA_MORA = V_TASA_MORA * V_SOBRETASA;
        ELSE
                LET V_TASA_MORA = V_TASA_MORA / V_SOBRETASA;
        END IF

         INSERT INTO bdicred:sd_maecred
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
	SELECT SOL.EMPRESA          ,SOL.NUM_SOLICITUD
               ,SOL.NUM_PRODUCTO     ,ANX.EJECUTIVO_SOL
               ,SOL.NUMCTE           ,DEF.DIVISA
               ,SOL.SUCURSAL         ,''
               ,''                   ,''
               ,''                   ,100
               --,'AA'                 ,'N'
			   ,cStatus_cred         ,'N'
               ,'N'                  ,DEF.PERIODO_PLAZO
               ,0                    ,"03/14/2007"
               ,"03/14/2008 "         ,DEF.PERIOD_PAGO_CAP
               ,DEF.PERIOD_PAG_INT   ,CTR.DIAS_TRAS_CAP
               ,CTR.DIAS_TRAS_INT    ,DEF.TASA_FIJA_O_VAR
               ,DEF.COD_TASA_BASE    ,DEF.FACTOR_SOBRETASA
               ,DEF.SOBRETASA        ,0
               ,DEF.COD_TASA_MORA    ,DEF.SOBRETASA_MORA
               ,DEF.FACT_SOBRET_MORA ,0
               ,''                   ,''
               ,TIP.ES_FISICA        ,''
               ,DEF.COD_PROD         ,0
               ,''                   ,''
               ,DEF.TIPO_CALCULO     ,''
               ,0                    ,''
               ,''                   ,DEF.REV_TASA_VAR_PER
               ,DEF.DIA_PARA_REVISAR ,''
               ,'M'                  ,''
               ,''                   ,0
               ,0                    ,"03/14/2007"
               ,0                    ,0
               ,''                   ,''
               ,'A'                  ,''
               ,'' ,'','','','','','',''
         FROM   BDISOLIC:SS_SOLICITUDES SOL
              , BDISOLIC:SS_ANEXOSOL    ANX
              , BDINTEG:SI_CLIENTE      CLI
              , BDINTEG:SI_TIPPER       TIP
              , SD_CODTRASP             CTR
              , SD_DEFINICION           DEF
         WHERE  DEF.EMPRESA         = SOL.EMPRESA
         AND    DEF.NUM_PRODUCTO    = SOL.NUM_PRODUCTO
         AND    CTR.PERIOD_PAG_INT  = "2"
         AND    CTR.PERIOD_PAGO_CAP = "3"
         AND    CTR.NUM_PRODUCTO    = DEF.NUM_PRODUCTO
         AND    CTR.EMPRESA         = DEF.EMPRESA
         AND    TIP.TPO_PERSONA     = CLI.TPO_PERSONA
         AND    CLI.NUMCTE          = SOL.NUMCTE
         AND    CLI.EMPRESA         = SOL.EMPRESA
         AND    ANX.NUM_SOLICITUD   = SOL.NUM_SOLICITUD
         AND    ANX.EMPRESA         = SOL.EMPRESA
         AND    SOL.NUM_SOLICITUD   = pnum_solicitud
         AND    SOL.EMPRESA         = pempresa    ;


END FOREACH

END PROCEDURE
;