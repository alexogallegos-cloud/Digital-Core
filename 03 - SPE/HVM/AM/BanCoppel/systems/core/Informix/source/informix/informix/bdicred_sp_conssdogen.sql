CREATE PROCEDURE "informix".sp_conssdogen(pEmpresa      CHAR(3),
                                                       pNumCredito   CHAR(20))
RETURNING CHAR(5)       AS codigo_retorno,
          CHAR(80)      AS mensaje_retorno,
          CHAR(20)      AS numero_credito,
          CHAR(2)       AS codigo_tipcred,
          DATE          AS fecha_origen,
          DATE          AS fecha_prox_pago,
          DECIMAL(18,2) AS pago_minimo,
          DATE          AS fecha_ult_pago,
          INTEGER       AS plazo,
          INTEGER       AS pagos_realizados,
          DECIMAL(18,2) AS linea_otorgada,
          DECIMAL(9,6)  AS tasa_interes,
          DECIMAL(9,6)  AS tasa_moratorios,
          DECIMAL(14,2) AS monto_sbc,
          DECIMAL(18,2) AS cap_vig,
          DECIMAL(18,2) AS cap_trans,
          DECIMAL(18,2) AS cap_vdo_exig,
          DECIMAL(18,2) AS cap_vdo_no_exig,
          DECIMAL(18,2) AS sdo_act_total_cap,
          DECIMAL(18,2) AS int_vig,
          DECIMAL(18,2) AS int_vdo,
          DECIMAL(18,2) AS int_moratorios,
          DECIMAL(18,2) AS int_mes,
          DECIMAL(18,2) AS sdo_act_total_int,
          DECIMAL(18,2) AS iva_int_vig,
          DECIMAL(18,2) AS iva_int_vdo,
          DECIMAL(18,2) AS iva_int_moratorios,
          DECIMAL(18,2) AS iva_int_mes,
          DECIMAL(18,2) AS sdo_act_total_iva,
          DECIMAL(18,2) AS com_pend,
          DECIMAL(18,2) AS iva_com,
          DECIMAL(18,2) AS sdo_retenido,
          DECIMAL(18,2) AS total_liquidacion,
          DECIMAL(18,2) AS int_devengado,
          DECIMAL(18,2) AS linea_disponible,
          DECIMAL(18,2) AS pagos_vdos,
          CHAR(60)      AS desc_status_cred,
          INTEGER       AS id_bloqueo_cred,
          CHAR(60)      AS bloqueo_cta,
          CHAR(3)       AS id_causa_bloqueo_cred,
          CHAR(50)      AS causa_bloqueo_cta,
          CHAR(1)       AS id_sit_esp_cte,
          INTEGER       AS id_causa_esp_cte,
          CHAR(75)      AS sit_esp_cte,
          CHAR(1)       AS id_sit_esp_cred,
          INTEGER       AS id_causa_esp_cred,
          CHAR(75)      AS sit_esp_cred;

DEFINE nrows             INTEGER;
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE cCodRet           CHAR(5);
DEFINE cMensajeRet       CHAR(80);

DEFINE cEmpresa          CHAR(3);
DEFINE cNumCte           CHAR(20);
DEFINE cNumCredito       CHAR(20);
DEFINE cCodTipCred       CHAR(2);
DEFINE cNumTarjeta       CHAR(20);
DEFINE cDescStatusCred   CHAR(60);

DEFINE cSucursal         CHAR(4);
DEFINE iIdUnidadProd     INTEGER;
DEFINE cCodCaract2       CHAR(3);
DEFINE dMontoFinanciado  DECIMAL(18,2);
DEFINE dIvaSuc           DECIMAL(5,3);

DEFINE dtFechaOrigen     DATE;
DEFINE dtFechaProxPago   DATE;
DEFINE dPagoMinimo       DECIMAL(18,2);
DEFINE dtFechaUltPago    DATE;
DEFINE iPlazo            INTEGER;
DEFINE iPagosRealizados  INTEGER;
DEFINE dLineaOtorgada    DECIMAL(18,2);

DEFINE dTasaInteres      DECIMAL(9,6);
DEFINE dTasaMoratorios   DECIMAL(9,6);
DEFINE dMontoSBC         DECIMAL(14,2);

DEFINE dCapVig           DECIMAL(18,2);
DEFINE dCapTrans         DECIMAL(18,2);
DEFINE dCapVdoExig       DECIMAL(18,2);
DEFINE dCapVdoNoExig     DECIMAL(18,2);
DEFINE dSdoActCap        DECIMAL(18,2);

DEFINE dIntVig           DECIMAL(18,2);
DEFINE dIntVdo           DECIMAL(18,2);
DEFINE dIntMoratorio     DECIMAL(18,2);
DEFINE dIntMes           DECIMAL(18,2);
DEFINE dSdoActInt        DECIMAL(18,2);

DEFINE dIvaIntVig        DECIMAL(18,2);
DEFINE dIvaIntVdo        DECIMAL(18,2);
DEFINE dIvaIntMoratorio  DECIMAL(18,2);
DEFINE dIvaIntMoratorio_d DECIMAL (18,2); -- Cambio de 15/09/2011
DEFINE dIvaIntMes        DECIMAL(18,2);
DEFINE dSdoActIvaInt     DECIMAL(18,2);

DEFINE dComPend          DECIMAL(18,2);
DEFINE dIvaCom           DECIMAL(18,2);
DEFINE dSdoRetenido      DECIMAL(18,2);
DEFINE dSdoTotalLiq      DECIMAL(18,2);

DEFINE dIntDevengado         DECIMAL(18,2);
DEFINE dLineaDisponible      DECIMAL(18,2);
DEFINE dPagosVdos            DECIMAL(18,2);

DEFINE cDescBloqueoCta       CHAR(60);
DEFINE cDescCausaBloqueoCta  CHAR(50);
DEFINE cSitCte               CHAR(1);
DEFINE cCausaCte             INTEGER;
DEFINE cDescSitEspCte        CHAR(75);
DEFINE cSitCred              CHAR(1);
DEFINE cCausaCred            INTEGER;
DEFINE cDescSitEspCred       CHAR(75);
DEFINE dfh_pre_devol_an      DATE;


LET nrows                = 0;
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = '';
LET cCodRet              = '';
LET cMensajeRet          = '';

LET cEmpresa             = '';
LET cNumCte              = '';
LET cNumCredito          = '';
LET cCodTipCred          = '';
LET cNumTarjeta          = '';
LET cDescStatusCred      = '';

LET cSucursal             = '';
LET iIdUnidadProd         = 0;
LET cCodCaract2           = '';
LET dMontoFinanciado      = 0;
LET dIvaSuc               = 0;

LET dtFechaOrigen         = DATE(1);
LET dtFechaProxPago       = DATE(1);
LET dPagoMinimo           = 0;
LET dtFechaUltPago        = DATE(1);
LET iPlazo                = 0;
LET iPagosRealizados      = 0;
LET dLineaOtorgada        = 0;

LET dTasaInteres          = 0;
LET dTasaMoratorios       = 0;
LET dMontoSBC             = 0;

LET dCapVig               = 0;
LET dCapTrans             = 0;
LET dCapVdoExig           = 0;
LET dCapVdoNoExig         = 0;
LET dSdoActCap            = 0;

LET dIntVig               = 0;
LET dIntVdo               = 0;
LET dIntMoratorio         = 0;
LET dIntMes               = 0;
LET dSdoActInt            = 0;

LET dIvaIntVig            = 0;
LET dIvaIntVdo            = 0;
LET dIvaIntMoratorio      = 0;
LET dIvaIntMoratorio_d    = 0;LET dIvaIntMes            = 0;
LET dSdoActIvaInt         = 0;

LET dComPend              = 0;
LET dIvaCom               = 0;
LET dSdoRetenido          = 0;
LET dSdoTotalLiq          = 0;

LET dIntDevengado         = 0;
LET dLineaDisponible      = 0;
LET dPagosVdos            = 0;

LET cDescBloqueoCta       = '';
LET cDescCausaBloqueoCta  = '';
LET cSitCte               = '';
LET cCausaCte             = 0;
LET cDescSitEspCte        = '';
LET cSitCred              = '';
LET cCausaCred            = 0;
LET cDescSitEspCred       = '';
LET dfh_pre_devol_an	  = date(1);


--SET DEBUG FILE TO '/tmp/sp_conssdogen.out';
--TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = 'OcurriÃ³ error al consultar los saldos'||' - '||cErrorInfo;
   RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
          NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
          NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
          NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
          NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
          NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0), NVL(dLineaDisponible,0),
          NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''),
          NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''),
          NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');
    END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

LET cCodRet      = '00000';
LET cMensajeRet  = 'Se realizÃ³ la consulta correctamente.';

IF NVL(pEmpresa,'') = '' THEN
  LET pEmpresa = NULL;
  LET cEmpresa= '';
ELSE
  LET cEmpresa= TRIM(pEmpresa);
END IF;

IF NVL(pNumCredito,'') = '' THEN
  LET pNumCredito = NULL;
  LET cNumCredito= '';
ELSE
  LET cNumCredito = TRIM(pNumCredito);
END IF;

IF pEmpresa IS NULL AND pNumCredito IS NULL THEN
   LET cCodRet= '00001';
   LET cMensajeRet= 'No hay informaciÃ³n para realizar la consulta';
   RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
          NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
          NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
          NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
          NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
          NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0), NVL(dLineaDisponible,0),
          NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''),
          NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''),
          NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');
END IF;


SELECT a.numcte,
       a.sucursal,
       a.plazo,
       a.fecha_apertura,
       NVL(a.tasa_interes,0),
       (NVL(a.tasa_moratorios,0) - NVL(a.tasa_interes,0)),
       a.id_unidad_prod,
       a.cod_caract_2,
       c.cod_tipcred,
       d.num_tarjeta,
       e.descripcion
  INTO cNumCte,
       cSucursal,
       iPlazo,
       dtFechaOrigen,
       dTasaInteres,
       dTasaMoratorios,
       iIdUnidadProd,
       cCodCaract2,
       cCodTipCred,
       cNumTarjeta,
       cDescStatusCred
  FROM "informix".sd_maecred a,
      "informix".sd_definicion c,
      "informix".sd_tarjeta d,
      "informix".sd_tipocartera e
 WHERE c.num_producto = a.num_producto
   AND c.empresa      = a.empresa
   AND d.num_credito  = a.num_credito
   AND d.status_tar   = d.status_tar
   AND d.tipo_tarjeta = 'T'
--   AND d.status_tar   = 'A'
   and d.secuencia = (select max(secuencia) from bdicred:sd_tarjeta where a.empresa = empresa and a.num_credito = num_credito and

tipo_tarjeta = 'T')
   AND d.empresa      = a.empresa
   AND e.status_cred  = a.status_cred
   AND a.num_credito  = cNumCredito
   AND a.empresa      = cEmpresa;

LET nrows = DBINFO("sqlca.sqlerrd2");
IF nrows  = 0 THEN
    LET cCodRet     = '00002';
    LET cMensajeRet = 'El nÃºmero de crÃ©dito no existe';
   RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
          NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
          NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
          NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
          NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
          NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0), NVL(dLineaDisponible,0),
          NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''),
          NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''),
          NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');
END IF;

SELECT prox_fecha_pago, fecha_ult_pago
  INTO dtFechaProxPago, dtFechaUltPago
  FROM "informix".sd_maecredanexo
 WHERE num_credito = cNumCredito
   AND empresa     = cEmpresa;

SELECT
       NVL(sdo_intereses,0),
       NVL(sdo_retenido,0),
       0, -- sdo_no_exig
       NVL(sdo_capital,0),
       NVL(sdo_cap_insoluto,0),
       NVL(monto_vencido,0),
       NVL(mto_venc_trasp,0),
	   NVL(monto_financiado,0),
       NVL(monto_otorgado,0),
       NVL(cap_tras_no_venci,0),
       (NVL(monto_otorgado,0) - NVL(sdo_cap_insoluto,0) - NVL(sdo_retenido,0)),
       0
  INTO dIntDevengado,
       dSdoRetenido,
       dIntVig,
       dCapVig,
       dSdoActCap,
       dCapTrans,
       dCapVdoExig,
       dMontoFinanciado,
       dLineaOtorgada,
       dCapVdoNoExig,
       dLineaDisponible,
       iPagosRealizados
  FROM "informix".sd_maesdos
 WHERE num_credito = cNumCredito
   AND empresa     = cEmpresa;

SELECT SUM(NVL(monto,0))
  INTO dMontoSBC
  FROM bdicheq:"informix".sc_docret_sbc   --MOHA
 WHERE empresa= cEmpresa
   AND cuenta    = cNumTarjeta
   AND siglas    = 'SD'
   AND cancelado = 'T';

SELECT iva
  INTO dIvaSuc
  FROM bdinteg:"informix".si_sucursales
 WHERE sucursal = cSucursal
   AND empresa  = cEmpresa;
--AAME IFRS Se contempla el nuevo capital_status 6 de vencido en Etapa 3
SELECT SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),
       SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) -

       NVL(mora_sdo_cope_pag,0)),
       SUM(NVL(iva_debe,0) - NVL(iva_pagado,0)),
       COUNT(*)
  INTO dIntVdo,
       dIntMoratorio,
       dIvaIntVdo,
       dPagosVdos
  FROM "informix".sd_amortiza_credito
 WHERE empresa     = cEmpresa
   AND num_credito = cNumCredito
   AND capital_status IN ('2','7','6');

   if dIntMoratorio is null then let dIntMoratorio = 0; end if;
   
    -- Se modifica la manera de consultar el iva de motarios  -- Cambio de 15/09/2011
	--AAME IFRS Se contempla el nuevo capital_status 6 de vencido en Etapa 3
	FOREACH
		SELECT (NVL(mora_iva_debe,0) - NVL(mora_iva_pagado,0) +( NVL(mora_provi_ordi + mora_provi_cope,0)* dIvaSuc ))
		INTO dIvaIntMoratorio_d
		FROM sd_amortiza_credito a
		WHERE a.empresa   = cEmpresa
		AND a.num_credito = cNumCredito
		AND capital_status IN ("2","7","6")		
			
		LET dIvaIntMoratorio = dIvaIntMoratorio + dIvaIntMoratorio_d;

		END FOREACH;
	--->
    --LET dIvaIntMoratorio = NVL(dIntMoratorio,0) * NVL(dIvaSuc,0);   
   LET dPagoMinimo      = NVL(dMontoFinanciado,0) + NVL(dIntVdo,0) + NVL(dIntMoratorio,0) + NVL(dIvaIntVdo,0) + NVL(dIvaIntMoratorio,0);

  SELECT NVL(SUM(NVL(interes_debe,0)),0),
         NVL(SUM(NVL(iva_debe,0)),0),
         0 --NVL(SUM(iva_debe - iva_pagado),0)
    INTO dIntMes,
         dIvaIntMes,
         dIvaIntVig
    FROM "informix".sd_amortiza_credito
   WHERE empresa        = cEmpresa
     AND num_credito    = cNumCredito
     AND capital_status = 1;

     LET dSdoActInt    = NVL(dIntVig,0) + NVL(dIntVdo,0) + NVL(dIntMoratorio,0);
     LET dSdoActIvaInt = NVL(dIvaIntVig,0) + NVL(dIvaIntVdo,0) + NVL(dIvaIntMoratorio,0);

  {SELECT NVL(SUM(decode(tc.comi_o_seg, '1', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0),
         NVL(SUM(decode(tc.comi_o_seg, '4', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0)
    INTO dComPend,
         dIvaCom
    FROM "informix".sd_detcomi dc,
         "informix".sd_tpcomis tc
   WHERE dc.empresa     = cEmpresa
     AND dc.num_credito = cNumCredito
     AND dc.estado_com  = 'A'
     AND dc.empresa     = tc.empresa
     AND dc.cod_comis   = tc.cod_comis
     AND tc.comi_o_seg IN ('1','4');}

     LET dComPend = 0;
     LET dIvaCom  = 0;

     LET dSdoTotalLiq = NVL(dSdoActCap,0) + NVL(dIntVdo,0) + NVL(dIvaIntVdo,0) + NVL(dIntMoratorio,0) + NVL(dIvaIntMoratorio,0) +

NVL(dSdoRetenido,0);

     --if ( dSdoTotalLiq < 0 ) then
        --LET dSdoTotalLiq = 0;
     --end if;

  SELECT descripcion
    INTO cDescBloqueoCta
    FROM "informix".sd_bloqueoscuenta
   WHERE clave = iIdUnidadProd;

  SELECT causa_bloq
    INTO cDescCausaBloqueoCta
    FROM "informix".sd_causa_bloqueo
   WHERE empresa = pEmpresa AND cod_causa = cCodCaract2;

-- TEMPORAL hasta que se libere a producciÃ³n SITUACIONES ESPECIALES
    LET cSitCte         = '';
    LET cCausaCte       = '';
    LET cDescSitEspCte  = '';
/*
  SELECT b.situacion, b.causa, b.descripcion
    INTO cSitCte, cCausaCte, cDescSitEspCte
    FROM bdisitesp:"informix".se_ctessitespcte a,
         bdisitesp:"informix".se_catsitesp b
   WHERE a.idmovto=(SELECT MAX(aux.idmovto)
                      FROM bdisitesp:"informix".se_ctessitespcte aux
                     WHERE aux.idmovto = aux.idmovto
                       AND a.empresa   = aux.empresa
                       AND a.numcte    = aux.numcte)
     AND a.empresa   = cEmpresa
     AND b.situacion = a.situacion
     AND b.causa     = a.causa
     AND a.numcte    = cNumCte;
*/
-- TEMPORAL hasta que se libere a producciÃ³n SITUACIONES ESPECIALES

-- TEMPORAL hasta que se libere a producciÃ³n SITUACIONES ESPECIALES
    LET cSitCred        ='';
    LET cCausaCred      ='';
    LET cDescSitEspCred = '';
/*
  SELECT b.situacion, b.causa, b.descripcion
    INTO cSitCred, cCausaCred, cDescSitEspCred
    FROM bdisitesp:"informix".se_ctessitespcred a,
         bdisitesp:"informix".se_catsitesp b
   WHERE a.idmvto= (SELECT MAX(aux.idmvto)
                      FROM bdisitesp:"informix".se_ctessitespcred aux
                     WHERE aux.idmvto= aux.idmvto
                       AND a.numcte= aux.numcte
                       AND a.empresa= aux.empresa
                       AND a.numcred= aux.numcred)
     AND a.numcte= cNumCte
     AND a.empresa= cEmpresa
     AND a.numcred= cNumCredito
     AND a.situacion= b.situacion
     AND a.causa= b.causa;
*/
-- TEMPORAL hasta que se libere a producciÃ³n SITUACIONES ESPECIALES

   let dCapVdoExig =  NVL(dCapTrans,0) + NVL(dCapVdoExig,0);
   let dCapVdoNoExig =  0;
   
    -- Obtiene marcas de creditos pre-cancelados por devolucion de anualidad INI
    SELECT nvl(date(fecha_pre_devol_anual),date(1)) INTO dfh_pre_devol_an 
	  FROM bdicred:sd_indicador_cred WHERE empresa = cEmpresa AND num_credito = cNumCredito;

	IF iIdUnidadProd = 4 AND nvl(dfh_pre_devol_an,date(1)) > date(1) THEN 
		LET dLineaDisponible = 0;	--	 dLineaOtorgada ,,  dLineaDisponible  , iIdUnidadProd
	END IF;
	-- Obtiene marcas de creditos pre-cancelados por devolucion de anualidad FIN
	

   RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
          NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
          NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
          NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
          NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
          NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0), NVL(dLineaDisponible,0),
          NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''),
          NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''),
          NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');

END
END PROCEDURE;