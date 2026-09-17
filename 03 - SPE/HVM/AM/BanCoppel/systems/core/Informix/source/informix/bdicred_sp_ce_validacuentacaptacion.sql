CREATE PROCEDURE "informix".sp_ce_validacuentacaptacion (pNumCta char(20))
        
		RETURNING char(5),char(20),char(20),char(120) ;
		
        DEFINE cCodret 		char(5);        
        DEFINE cDescripcion char(20);        
        DEFINE cNumCte 		char(20);
        DEFINE cNombre 		char(120);        
        DEFINE cSQL_ERR 	integer;

        
        LET cDescripcion 	= "";        
        LET cNombre 		= "";
        LET cNumCte 		= "";
        LET cSQL_ERR 		= 100 ;
        LET cCodret  		= "00000";                


--SET DEBUG FILE TO '/tmp/consxcta.out';
--TRACE ON;

BEGIN

	ON EXCEPTION SET cSQL_ERR
	LET cCodret = cSQL_ERR;
	RETURN cCodret,cDescripcion, cNumCte, cNombre;
	END EXCEPTION;

FOREACH

	SELECT status_cta, mae.num_cte, 
		   NVL(TRIM(si_cliente.nombre1),"") ||' ' || NVL(TRIM(si_cliente.nombre2),"") ||' '|| NVL(TRIM(si_cliente.apell_paterno),"") ||' '|| NVL(TRIM(si_cliente.apell_materno),"")
		   INTO
				cDescripcion,cNumCte, cNombre
		   FROM bdicheq:sc_maechq mae, bdinteg:si_cliente si_cliente    
		  WHERE si_cliente.numcte = mae.num_cte       
			AND mae.cuenta = pNumCta
		 RETURN cCodret,cDescripcion, cNumCte, cNombre with resume ;
		 
END FOREACH;


END;

END PROCEDURE

DOCUMENT
'AUTOR :Faviola Martínez Juárez',
'DESCRIPCION: Se creo el sp para regresar nombre y numero de cliente de una cuenta.',
'Captacion',
'FECHA : Junio 2014',
'VERSION: ',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consulta_saldos_general_evaobj(pEmpresa      CHAR(3),
                                                       pNumCredito   CHAR(20))
RETURNING CHAR(6)       AS codigo_retorno,
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
          DECIMAL(18,2) AS iva_int_devengado,
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
-----------------------------------------------------------------------------------------------------------
-- Fecha: 12/10/2009                                                                                     --
-- Autor: Roque Enrique Solis Campaña                                                                    --
--Modificacion: Se agregaron las consultas para saldos de prestamos personales                           --
-----------------------------------------------------------------------------------------------------------
-- Fecha: 20/10/2009                                                                                     --
-- Autor: Roque Enrique Solis Campaña                                                                    --
--Modificacion: Se agrego el calculo de la comision para prestamo personal                               --
--            se sumo al monto total de liquidacion la comision y el iva de comision                     --
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- Fecha: 22/12/2009                                                                                     --
-- Autor: Paul ivan quintero varela                                                                      --
-- Modificacion: Se modifica para contemplar el calculo del iva de interes real                          --
--               o iva de interes devengado                                                              --
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- Fecha: 30/11/2011                                                                                     --
-- Autor: Diego Guera Atienzo                                                                      --
-- Modificacion: Se modifica método para calcular el IVA moratorio en préstamos personales y             --
--				 reestructuras                                                                           --
-----------------------------------------------------------------------------------------------------------

DEFINE nrows             INTEGER;
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE cCodRet           CHAR(6);
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
DEFINE dIntMoratorio_d	 DECIMAL(18,2);
DEFINE dIntMes           DECIMAL(18,2);
DEFINE dSdoActInt        DECIMAL(18,2);

DEFINE dIvaIntVig        DECIMAL(18,2);
DEFINE dIvaIntVdo        DECIMAL(18,2);
DEFINE dIvaIntMoratorio  DECIMAL(18,2);
DEFINE dIvaIntMes        DECIMAL(18,2);
DEFINE dSdoActIvaInt     DECIMAL(18,2);

DEFINE dComPend          DECIMAL(18,2);
DEFINE dIvaCom           DECIMAL(18,2);
DEFINE dSdoRetenido      DECIMAL(18,2);
DEFINE dSdoTotalLiq      DECIMAL(18,2);

DEFINE dtIvaFechaPag         DATE;
DEFINE dtFechaCuota          DATE;
DEFINE dIntDevengado         DECIMAL(18,2);
DEFINE dIvaIntDevengado      DECIMAL(18,2);
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
DEFINE dFactorComision       DECIMAL(18,2);
DEFINE dtMesiversario        DATE;
DEFINE dtFechaHoy            DATE;
DEFINE cTipCred              CHAR(2);

--FMV 01-Sep-11: Se adicionan el indicador y transaccion de la comision de Credinomina
DEFINE cind_comision   CHAR(1);
DEFINE ctran_comision  CHAR(4);
DEFINE vRetCs_acum          DECIMAL(18,2);

DEFINE vvcodigo_retorno    CHAR(6);
DEFINE vvmensaje_retorno   CHAR(80);
--DEFINE vvpago_minimo       DECIMAL(18,2);

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
LET dIntMoratorio_d       = 0;
LET dIntMes               = 0;
LET dSdoActInt            = 0;

LET dIvaIntVig            = 0;
LET dIvaIntVdo            = 0;
LET dIvaIntMoratorio      = 0;
LET dIvaIntMes            = 0;
LET dSdoActIvaInt         = 0;

LET dComPend              = 0;
LET dIvaCom               = 0;
LET dSdoRetenido          = 0;
LET dSdoTotalLiq          = 0;

LET dtIvaFechaPag         = DATE(1);
LET dtFechaCuota          = DATE(1);
LET dIntDevengado         = 0;
LET dIvaIntDevengado      = 0;
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
LET dFactorComision       = 0;
LET dtMesiversario        = DATE(1);
LET dtFechaHoy            = DATE(1);
LET cTipCred              = '';
LET cind_comision         = '';
LET ctran_comision        = '';
LET vRetCs_acum           = 0;

LET vvcodigo_retorno  = '';
LET vvmensaje_retorno = '';
--LET vvpago_minimo     = 0;

--SET DEBUG FILE TO '/tmp/sp_consulta_saldos_general.out'; --- MODIFICAR RUTA DEL ARCHIVO
--TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = 'Ocurrió error al consultar los saldos'||' - '||cErrorInfo;
   RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
          NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
          NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
          NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
          NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
          NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0),NVL(dIvaIntDevengado,0), NVL(dLineaDisponible,0),
          NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''),
          NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''),
          NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');
    END IF;
END EXCEPTION;

LET cCodRet      = '000000';
LET cMensajeRet  = 'Se realizó la consulta correctamente.';

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
   LET cCodRet= '000001';
   LET cMensajeRet= 'No hay información para realizar la consulta';
   RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
          NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
          NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
          NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
          NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
          NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0),NVL(dIvaIntDevengado,0),NVL(dLineaDisponible,0),
          NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''),
          NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''),
          NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');
END IF;

SET ISOLATION TO dirty READ;

SELECT fecha_hoy
  INTO dtFechaHoy
  FROM "informix".sd_fechas
 WHERE empresa = pEmpresa;


SELECT b.cod_prod
  INTO cTipCred
  FROM bdicred:sd_maecred a,
       bdicred:sd_tipprod b
 WHERE a.num_credito = cNumCredito
   AND a.empresa=pEmpresa
   AND a.empresa=b.empresa
   AND a.num_producto=b.abrevia_prod;

 IF cTipCred IS NULL THEN
    SELECT b.cod_prod
      INTO cTipCred
      FROM bdicred:sd_maecredcrd a,
           bdicred:sd_tipprod b
     WHERE a.num_credito = cNumCredito
       AND a.empresa=pEmpresa
       AND a.empresa=b.empresa
       AND a.num_producto=b.abrevia_prod;

	 IF cTipCred IS NULL THEN
	    LET cCodRet= '000002';
		LET cMensajeRet= 'No hay información para realizar la consulta';
		RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
          NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
          NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
          NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
          NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
          NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0),NVL(dIvaIntDevengado,0), NVL(dLineaDisponible,0),
          NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''),
          NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''),
          NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');
     END IF;
 END IF;

IF cTipCred='T' THEN
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
		   and d.secuencia = (select max(secuencia) from bdicred:sd_tarjeta where a.empresa = empresa and a.num_credito = num_credito and tipo_tarjeta = 'T')
		   AND d.empresa      = a.empresa
		   AND e.status_cred  = a.status_cred
		   AND a.num_credito  = cNumCredito
		   AND a.empresa      = cEmpresa;

		LET nrows = DBINFO("sqlca.sqlerrd2");
		IF nrows  = 0 THEN
		    LET cCodRet     = '000003';
		    LET cMensajeRet = 'El número de crédito no existe';
		   RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
		          NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
		          NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
		          NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
		          NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
		          NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0),NVL(dIvaIntDevengado,0), NVL(dLineaDisponible,0),
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
		  FROM bdicheq:"informix".sc_docret
		 WHERE empresa= cEmpresa
		   AND cuenta    = cNumTarjeta
		   AND siglas    = 'SD'
		   AND cancelado = 'T';

		SELECT iva
		  INTO dIvaSuc
		  FROM bdinteg:"informix".si_sucursales
		 WHERE sucursal = cSucursal
		   AND empresa  = cEmpresa;

/*  SUBSTITUIR QUERIES PAGO MÍNIMO
		SELECT SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),
		       SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),
		       SUM(NVL(iva_debe,0) - NVL(iva_pagado,0)),
		       COUNT(num_credito)
		  INTO dIntVdo,
		       dIntMoratorio,
		       dIvaIntVdo,
		       dPagosVdos
		  FROM "informix".sd_amortiza_credito
		 WHERE empresa     = cEmpresa
		   AND num_credito = cNumCredito
		   AND capital_status IN ('2','7');

		--
		-- Cambio de consulta iva moroso 19/07/201
		--
		FOREACH
			SELECT (NVL(mora_iva_debe,0) - NVL(mora_iva_pagado,0) +( NVL(mora_provi_ordi + mora_provi_cope,0)* dIvaSuc ))
			INTO dIntMoratorio_d
			FROM sd_amortiza_credito a
			WHERE a.empresa   = cEmpresa
			AND a.num_credito = cNumCredito
			AND capital_status IN ("2","7")

			LET dIvaIntMoratorio = dIvaIntMoratorio + dIntMoratorio_d;

		END FOREACH;

		  -- LET dIvaIntMoratorio = NVL(dIntMoratorio,0) * NVL(dIvaSuc,0);
		   LET dPagoMinimo      = NVL(dMontoFinanciado,0) + NVL(dIntVdo,0) + NVL(dIntMoratorio,0) + NVL(dIvaIntVdo,0) + NVL(dIvaIntMoratorio,0);

--  SUBSTITUIR QUERIES PAGO MÍNIMO*/
    
      Call "informix".sp_obtener_pagomin(cEmpresa,cNumCredito) RETURNING vvcodigo_retorno, vvmensaje_retorno, dPagoMinimo, dIntVdo, dIntMoratorio,
                                                                         dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;
       
      IF vvcodigo_retorno <> '000000' THEN
        LET cCodRet= '000007';
		    LET cMensajeRet= 'Error en cálculo de pago mínimo.';
		    RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
          NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
          NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
          NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
          NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
          NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0),NVL(dIvaIntDevengado,0), NVL(dLineaDisponible,0),
          NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''),
          NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''),
          NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');          
      END IF;

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


            IF EXISTS(SELECT num_credito FROM bdicred:sd_promocion_credito 
                      WHERE empresa = cEmpresa and num_credito = cNumCredito AND status = 0
                      GROUP BY num_credito) THEN

                         SELECT sum(NVL(monto_int_iva,0))
                           INTO vRetCs_acum 
                           FROM bdicred:sd_promocion_credito 
                          WHERE empresa = cEmpresa 
                            AND num_credito = cNumCredito 
                            AND status = 0;
           END IF; 
    		     LET dSdoTotalLiq = NVL(dSdoActCap,0) + NVL(dIntVdo,0) + NVL(dIvaIntVdo,0) + NVL(dIntMoratorio,0) + NVL(dIvaIntMoratorio,0) + NVL(dSdoRetenido,0) - NVL(vRetCs_acum,0);
		 
			 
		     if ( dSdoTotalLiq < 0 ) then
		        LET dSdoTotalLiq = 0;
		     end if;

		  SELECT descripcion
		    INTO cDescBloqueoCta
		    FROM "informix".sd_bloqueoscuenta
		   WHERE clave = iIdUnidadProd;

		  SELECT causa_bloq
		    INTO cDescCausaBloqueoCta
		    FROM "informix".sd_causa_bloqueo
		   WHERE empresa = pEmpresa AND cod_causa = cCodCaract2;

		-- TEMPORAL hasta que se libere a producción SITUACIONES ESPECIALES
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
		-- TEMPORAL hasta que se libere a producción SITUACIONES ESPECIALES

		-- TEMPORAL hasta que se libere a producción SITUACIONES ESPECIALES
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
		-- TEMPORAL hasta que se libere a producción SITUACIONES ESPECIALES
ELIF cTipCred  in ('P','R') THEN
     SELECT a.numcte,
		       a.sucursal,
		       a.plazo,
		       a.fecha_apertura,
		       NVL(a.tasa_interes,0),
		       (NVL(a.tasa_moratorios,0) - NVL(a.tasa_interes,0)),
		       --a.id_unidad_prod,
		      -- a.cod_caract_2,
		       c.cod_tipcred,
		       e.descripcion,
               c.ind_comision,
               c.tran_comision
		  INTO cNumCte,
		       cSucursal,
		       iPlazo,
		       dtFechaOrigen,
		       dTasaInteres,
		       dTasaMoratorios,
		       --iIdUnidadProd,
		       --cCodCaract2,
		       cCodTipCred,
		       cDescStatusCred,
               cind_comision,
               ctran_comision

		  FROM "informix".sd_maecredcrd a,
		      "informix".sd_definicion c,
		      "informix".sd_tipocartera e
		 WHERE c.num_producto = a.num_producto
		   AND c.empresa      = a.empresa
		   AND e.status_cred  = a.status_cred
		   AND a.num_credito  = cNumCredito
		   AND a.empresa      = cEmpresa;

		LET nrows = DBINFO("sqlca.sqlerrd2");
		IF nrows  = 0 THEN
		    LET cCodRet     = '000004';
		    LET cMensajeRet = 'El número de crédito no existe';
		   RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
		          NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
		          NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
		          NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
		          NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
		          NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0),NVL(dIvaIntDevengado,0), NVL(dLineaDisponible,0),
		          NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''),
		          NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''),
		          NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');
		END IF;


        IF cTipCred='R' THEN
           LET dTasaMoratorios=0;
        END IF;

		SELECT prox_fecha_pago, fecha_ult_pago
		  INTO dtFechaProxPago, dtFechaUltPago
		  FROM "informix".sd_maecredanexocrd
		 WHERE num_credito = cNumCredito
		   AND empresa     = cEmpresa;

		SELECT
		       NVL(sdo_intereses,0),
		       NVL(sdo_retenido,0),
		       0,
		       NVL(sdo_capital,0),
		       NVL(sdo_cap_insoluto,0),
		       NVL(monto_vencido,0),
		       NVL(mto_venc_trasp,0),
		       NVL(monto_financiado,0),
		       NVL(monto_otorgado,0),
		       NVL(cap_tras_no_venci,0),
		       0 --(NVL(monto_otorgado,0) - NVL(sdo_cap_insoluto,0) - NVL(sdo_retenido,0)),
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
		       dLineaDisponible
		  FROM "informix".sd_maesdoscrd
		 WHERE num_credito = cNumCredito
		   AND empresa     = cEmpresa;

         -- Se calcula el iva de interes devengado
         -- (Se realiza el calculo de iva de interes real).

         IF dIntDevengado IS NULL THEN
             LET dIntDevengado = 0;
         END IF;

        SELECT a.iva_fecha_pago,  -- Iva_fecha_pago
               a.fecha_cuota      -- Fecha Cuota
          INTO dtIvaFechaPag,
               dtFechaCuota
          FROM "informix".sd_amortiza_creditocrd a
         WHERE a.empresa         = cEmpresa
           AND a.num_credito     = cNumCredito
           AND a.capital_status  = "3";

		SELECT iva
		  INTO dIvaSuc
		  FROM bdinteg:"informix".si_sucursales
		 WHERE sucursal = cSucursal
		   AND empresa  = cEmpresa;

              CALL "informix".calc_iva_grav_pp(cEmpresa,cNumCredito,dTasaInteres,dIvaSuc,dtFechaHoy,
                                               dtIvaFechaPag,dtFechaOrigen,dtFechaCuota,dIntDevengado) RETURNING cCodRet,dIvaIntDevengado,cMensajeRet;

              IF cCodRet <> "000000" THEN
                    LET cCodRet      = '000005';
                    LET cMensajeRet  = 'Ocurrió un error al realizar calculo';
				    RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
				          NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
				          NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
				          NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
				          NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
				          NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0),NVL(dIvaIntDevengado,0), NVL(dLineaDisponible,0),
				          NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''),
				          NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''),
				          NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');
              END IF;

		   SELECT COUNT(num_credito)
		     INTO iPagosRealizados
 			 FROM bdicred:sd_amortiza_creditocrd
	    	WHERE empresa = pEmpresa
			  AND num_credito = cNumCredito
			  AND capital_status = '5';

		/*SELECT SUM(NVL(monto,0))
		  INTO dMontoSBC
		  FROM bdicheq:"informix".sc_docret
		 WHERE empresa= cEmpresa
		   AND cuenta    = cNumTarjeta
		   AND siglas    = 'SD'
		   AND cancelado = 'T';*/

 /*SUBSTITUIR QUERIES PAGO MÍNIMO (CREDS. A PLAZO FIJO)
		-- 2011-11-30 Se realiza cambio en calculo de IVA moratorio
		SELECT SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),
		       SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),
			   SUM(round((NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0))* dIvaSuc,2)),
		       SUM(NVL(iva_debe,0) - NVL(iva_pagado,0)),
		       COUNT(num_credito)
		  INTO dIntVdo,
		       dIntMoratorio,
			   dIntMoratorio_d,
		       dIvaIntVdo,
		       dPagosVdos
		  FROM "informix".sd_amortiza_creditocrd
		 WHERE empresa     = cEmpresa
		   AND num_credito = cNumCredito
		   AND capital_status IN ('2','7');

		    --LET dIvaIntMoratorio = NVL(dIntMoratorio,0) * NVL(dIvaSuc,0);
		   LET dIvaIntMoratorio = NVL(dIntMoratorio_d,0);
		   LET dPagoMinimo      = NVL(dMontoFinanciado,0) + NVL(dIntVdo,0) + NVL(dIntMoratorio,0) + NVL(dIvaIntVdo,0) + NVL(dIvaIntMoratorio,0);


		   SELECT 0,
                  0,
                  NVL(SUM(NVL(interes_debe - interes_pagado,0)),0),
                  NVL(SUM(NVL(iva_debe - iva_pagado,0)),0)
		     INTO dIntMes,
		          dIvaIntMes,
		          dIntVig,
		          dIvaIntVig
             FROM "informix".sd_amortiza_creditocrd
            WHERE empresa        = cEmpresa
              AND num_credito    = cNumCredito
              AND capital_status = 1;

			 LET dPagoMinimo = dPagoMinimo + NVL(dIntVig,0) + NVL(dIvaIntVig,0);

  SUBSTITUIR QUERIES PAGO MÍNIMO (CREDS. A PLAZO FIJO) */
  
	
  Call "informix".sp_obtener_pagomin(cEmpresa,cNumCredito) RETURNING vvcodigo_retorno, vvmensaje_retorno, dPagoMinimo, dIntVdo, dIntMoratorio,
                                                                   dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;
      
     LET dSdoActInt    = NVL(dIntVig,0) + NVL(dIntVdo,0) + NVL(dIntMoratorio,0);
     LET dSdoActIvaInt = NVL(dIvaIntVig,0) + NVL(dIvaIntVdo,0) + NVL(dIvaIntMoratorio,0);

      
      IF vvcodigo_retorno <> '000000' THEN
          LET cCodRet= '000008';
		      LET cMensajeRet= 'Error en cálculo de pago mínimo.';
		      RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
          NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
          NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
          NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
          NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
          NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0),NVL(dIvaIntDevengado,0), NVL(dLineaDisponible,0),
          NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''),
          NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''),
          NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');   
          
      END IF;


		  {SELECT NVL(SUM(DECODE(tc.comi_o_seg, '1', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0),
		         NVL(SUM(DECODE(tc.comi_o_seg, '4', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0)
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

			 EXECUTE PROCEDURE "informix".monthadd(dtFechaOrigen, 1) INTO dtMesiversario;

			 IF dtFechaHoy < dtMesiversario and cTipCred='P' and cind_comision = '1' THEN

			     SELECT apli_factor/100
				   INTO dFactorComision
				   FROM "informix".sd_tpcomis
				  WHERE cod_comis=ctran_comision;  --FMV 1-SEP-11 SE ADICIONA EL FACTOR DE COMISION




				 IF dFactorComision IS NULL THEN
				    LET cCodRet = '000006';
				    LET cMensajeRet = 'No se encontró el factor de la comisión';
				    RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
				          NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
				          NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
				          NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
				          NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
				          NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0),NVL(dIvaIntDevengado,0), NVL(dLineaDisponible,0),
				          NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''),
				          NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''),
				          NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');
				 END IF;
			    --COMISIONES
                IF dSdoActCap<=0 THEN
                    LET dComPend = dSdoActCap * dFactorComision;
                ELSE
                    LET dComPend = dLineaOtorgada * dFactorComision;
                END IF;

                --IVA DE COMISIONES
                LET dIvaCom = dComPend * dIvaSuc;
			 END IF;

		     LET dSdoTotalLiq = NVL(dSdoActCap,0) + NVL(dIntVdo,0) + NVL(dIvaIntVdo,0) +

                                NVL(dIntMoratorio,0) + NVL(dIvaIntMoratorio,0) + NVL(dSdoRetenido,0) +
                                NVL(dComPend,0) + NVL(dIvaCom,0) + NVL(dIntDevengado,0) + NVL(dIvaIntDevengado,0) +
                                NVL(dIntVig,0) + NVL(dIvaIntVig,0);

		     IF ( dSdoTotalLiq < 0 ) THEN
		        LET dSdoTotalLiq = 0;
		     END IF;

		-- TEMPORAL hasta que se libere a producción SITUACIONES ESPECIALES
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
		-- TEMPORAL hasta que se libere a producción SITUACIONES ESPECIALES

		-- TEMPORAL hasta que se libere a producción SITUACIONES ESPECIALES
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
		-- TEMPORAL hasta que se libere a producción SITUACIONES ESPECIALES

END IF;

   RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
          NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
          NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
          NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
          NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
          NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0),NVL(dIvaIntDevengado,0), NVL(dLineaDisponible,0),
          NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''),
          NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''),
          NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener los saldos ',
'generales del crédito',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 22/06/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".executaedoctacrd(pempresa  CHAR(3),pfechahoy DATE)
RETURNING CHAR(5);

DEFINE v_cod_ret	    CHAR(5);
DEFINE sql_err          INTEGER;
DEFINE v_cuantos		INTEGER;
DEFINE vStProc         	CHAR(1);
DEFINE v_nameProcess	CHAR(20);

LET v_cuantos = 0;

--SET DEBUG FILE TO "executaedoctacrd.out";
--TRACE ON;

BEGIN

  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_cod_ret = sql_err;

			UPDATE "informix".sd_contproc
			   SET status_proc = "C",
                   hora_fin    = CURRENT,
                   cod_ret     = v_cod_ret,
			       mensaje     = "Estados de Cuenta de Reestructura Sin Generar"
			 WHERE empresa     = pEmpresa			
			   AND proceso     = v_nameProcess
			   AND fecha       = pfechahoy;
                       
			UPDATE bdinteg:sx_contproc
			   SET status_proc = "C",
                   hora_fin    = CURRENT,
			 	   codret      = v_cod_ret
			 WHERE proceso  = v_nameProcess
			   AND fecha    = pfechahoy
			   AND sistema = '06';

            RETURN v_cod_ret;
        END IF
   END EXCEPTION;

	LET v_nameProcess = "GeneraEdoCtaREES";
	LET v_cod_ret = "000";

	--     PREGUNTA POR EL CONTROL  DE PROCESOS     --

	SELECT status_proc INTO vStProc
	  FROM "informix".sd_contproc
	 WHERE empresa = pEmpresa
	   AND proceso  = v_nameProcess
	   AND fecha    = pfechahoy;
	   
	IF vStProc IS NULL OR vStProc = '' THEN
        	INSERT INTO "informix".sd_contproc (empresa, proceso, fecha, 
  	 	 		                     status_proc, ejecutivo,
          	  	                     hora_inicio, hora_fin, 
          	  	                     cod_ret, mensaje)
        	VALUES (pEmpresa, v_nameProcess, pfechahoy, 
	 	 		    'I', USER,
	 	 		    CURRENT, NULL, 
	 	 		    NULL, NULL);

			INSERT INTO bdinteg:sx_contproc (empresa, proceso, fecha, 
		 		                             sistema, status_proc,
	        	                             ejecutivo, hora_ini, 
	        	                             hora_fin, codret)
			     VALUES (pEmpresa, v_nameProcess, pfechahoy, 
		 		         '06', 'I', 
		 		         USER, CURRENT, 
		 		         NULL, '000');
	ELIF vStProc = "F" THEN
         	RETURN v_cod_ret;
	END IF
	
     EXECUTE PROCEDURE executaedoctageneralcrd (pempresa, pfechahoy) 
	 INTO v_cod_ret;

    IF v_cod_ret <> "000" THEN
        UPDATE sd_contproc
           SET status_proc = "C",
               hora_fin    = CURRENT,
               cod_ret     = v_cod_ret,
               mensaje     = v_cuantos || "Estados de Cuenta de Reestructura Sin Generar"
         WHERE empresa     = pEmpresa
           AND proceso     = v_nameProcess
           AND fecha       = pfechahoy;

        UPDATE bdinteg:sx_contproc
           SET status_proc = "C",
               hora_fin    = CURRENT,
               codret      = v_cod_ret
         WHERE proceso  = v_nameProcess
           AND fecha       = pfechahoy
           AND sistema = '06';
    ELSE
	    UPDATE sd_contproc
	       SET status_proc = "F",
	           hora_fin    = CURRENT,
        	   cod_ret     = v_cod_ret,
      	       mensaje     = "Proceso Concluido"
  	     WHERE empresa     = pEmpresa
	       AND proceso     = v_nameProcess
	       AND fecha       = pfechahoy;

          UPDATE bdinteg:sx_contproc
             SET status_proc = "F",
                 hora_fin = CURRENT,
                 codret   = v_cod_ret
           WHERE proceso  = v_nameProcess
             AND fecha    = pfechahoy
             AND sistema = '06';
    END IF
END;

	RETURN v_cod_ret;

END PROCEDURE
DOCUMENT
"Se crea procedimiento para realizar la consulta",
"a la bitacora de control de procesos y comenzar",
"con el proceso de generación de Edo. Cta.",
"reestructura",
"base de datos : bdicred",
"AUTOR : Jose de Jesus Almeida",
"FECHA : 20/Julio/2009";

CREATE PROCEDURE "informix".sp_credisoluciones_revol(pempresa CHAR(3), pFolioMovto CHAR(20) DEFAULT "")
   RETURNING CHAR(6), CHAR(80);

	--DECLARACION DE VARIABLES.
	DEFINE iSqlErr                       INTEGER;
	DEFINE iIsamErr                      INTEGER;
	DEFINE cErrorInfo                    CHAR(100);
	DEFINE CodRet                        CHAR(6);
	DEFINE Mensaje                  	 CHAR(80);
	DEFINE CSnum_credito,cCredito_promo  CHAR(20);
	DEFINE v_total_cap_cs, v_total_mto_cs, v_mto_pag_cs, v_capital_cs, v_interes_cs, v_iva_cs, v_monto_actual, v_monto_int_iva 	DECIMAL(14,2);
	DEFINE cfolio_mov_promo,cfolio_suc_promo CHAR(16);
	DEFINE cCharAux          			 CHAR(80);
	DEFINE dtDateAux         			 DATE;
	DEFINE dDecAux           			 DECIMAL(18,2);
	DEFINE iIntAux           			 INTEGER;
	DEFINE dPagoCom,dPagoIvaCom,dSdoAdeudTotal,dIntDevengado,dIvaIntDevengado,vcap_vig,dSdoAdeudTotalAct   DECIMAL(18,2);
	DEFINE dtFechaApertura,dtFechaProxPago  DATE;
	DEFINE dPagoMinAct        			 DECIMAL(18,2);


	--INICIALIZACION DE VARIABLES.

	LET iSqlErr       = 0;
	LET iIsamErr      = 0;
	LET cErrorInfo    = "";
	LET CodRet       = "000000";
	LET Mensaje   = "Se realiz?? proceso exitosamente";
	LET CSnum_credito,cCredito_promo = '','';
	LET v_total_cap_cs, v_total_mto_cs, v_mto_pag_cs, v_capital_cs, v_interes_cs, v_iva_cs, v_monto_actual, v_monto_int_iva = 0,0,0,0,0,0,0,0;
	LET cfolio_mov_promo,cfolio_suc_promo = '','';
	LET cCharAux       = "";
	LET dtDateAux      = DATE(1);
	LET dDecAux        = 0; LET iIntAux = 0; LET dPagoCom = 0; LET dPagoIvaCom = 0; LET dSdoAdeudTotal = 0; LET dIntDevengado = 0; LET dIvaIntDevengado = 0; LET vcap_vig = 0;
	LET dtFechaApertura  = DATE(1); LET dtFechaProxPago = DATE(1); LET dPagoMinAct = 0; LET dSdoAdeudTotalAct = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		   IF iSqlErr != 0 THEN
				  LET CodRet     = iSqlErr;
				  LET Mensaje = cErrorInfo;
			   RETURN CodRet,Mensaje;
		   END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/sp_credisoluciones_revol.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

			FOREACH
				SELECT b.num_credito,a.num_sol_prestamo, a.monto_actual, a.monto_int_iva,a.folio_movto,a.folio_suc
				  INTO CSnum_credito,cCredito_promo, v_monto_actual, v_monto_int_iva,cfolio_mov_promo,cfolio_suc_promo
				  FROM bdicred:"informix".sd_promocion_credito a,
					   bdicred:"informix".sd_maecred b
				 WHERE a.empresa = pEmpresa
				   AND a.empresa = b.empresa
				   AND a.sistema = '06'
				   AND a.num_credito = b.num_credito
				   AND a.status = 2
				   AND b.status_cred = 'AA'
				   AND a.folio_movto = DECODE(pFolioMovto, "", a.folio_movto, pFolioMovto)

				--SE OBTIENE EL ADEUDO DEL CLIENTE DE CREDISOLUCIONES HASTA ESE MOMENTO

				EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(pEmpresa,cCredito_promo)
					INTO CodRet,Mensaje,cCharAux,cCharAux,dtFechaApertura,dtFechaProxPago,dPagoMinAct,dtDateAux,
					  iIntAux,iIntAux,dDecAux,dDecAux,dDecAux,dDecAux,vcap_vig,dDecAux,dDecAux,dDecAux,
					  dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
					  dDecAux,dDecAux,dDecAux,dDecAux,dSdoAdeudTotalAct,dIntDevengado,dIvaIntDevengado,
					  dDecAux,dDecAux,cCharAux,iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,
					  cCharAux,cCharAux,iIntAux,cCharAux;

				IF  dSdoAdeudTotalAct > 0 THEN
					--SE REALIZA EL PAGO POR EL MONTO CORRESPONDIENTE AL MES CORRIENTE DE CREDISOLUCIONES
					CALL "informix".sp_cargo_abono_palzo(pEmpresa,cCredito_promo,'',dSdoAdeudTotalAct,USER,'9290','4210',3,'')
					RETURNING CodRet, Mensaje;

					IF CodRet::INTEGER <> 0 THEN
						RETURN CodRet,Mensaje;
					ELSE
						LET CodRet = "000";
					END IF;

					IF (SELECT sdo_retenido FROM "informix".sd_maesdos WHERE empresa = '001' and num_credito = CSnum_credito) >= (v_monto_actual + v_monto_int_iva) THEN

						UPDATE "informix".sd_maesdos
						   SET sdo_retenido = sdo_retenido - (v_monto_actual + v_monto_int_iva)
						 WHERE empresa = '001' and num_credito = CSnum_credito;

						UPDATE "informix".sd_promocion_credito
						   SET status = 7
						 WHERE empresa = '001'
						   AND num_sol_prestamo = cCredito_promo
						   AND folio_movto = pFolioMovto;

						UPDATE "informix".sd_maeretenido
						   SET estatus = 'S'
						 WHERE empresa = '001'
						   AND num_credito = CSnum_credito
						   AND folio_suc = cfolio_mov_promo; --Revizar con cliente si se cambia por cfolio_suc_promo.

						UPDATE "informix".sd_maeretenido
						   SET estatus = 'S'
						 WHERE empresa = '001'
						   AND num_credito = CSnum_credito
						   AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo;

					END IF;

					IF dIvaIntDevengado <> 0 THEN
						CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',dIvaIntDevengado,USER,'9290','4202',1,'')
						RETURNING CodRet, Mensaje;

						IF CodRet::INTEGER <> 0 THEN
							RETURN CodRet,Mensaje;
						ELSE
							LET CodRet = "000";
						END IF;
					END IF;

					IF dIntDevengado <> 0 THEN
						CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',dIntDevengado,USER,'9290','4201',1,'')
						  RETURNING CodRet, Mensaje;

						  IF CodRet::INTEGER <> 0 THEN
							   RETURN CodRet,Mensaje;
						  ELSE
							 LET CodRet = "000";
						  END IF;
					END IF;

					IF vcap_vig <> 0 THEN
						CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',vcap_vig,USER,'9290','4200',1,'')
						  RETURNING CodRet, Mensaje;

						IF CodRet::INTEGER <> 0 THEN
						   RETURN CodRet,Mensaje;
						ELSE
						 LET CodRet = "000";
						END IF;
					END IF;
				END IF;

				LET dSdoAdeudTotalAct = 0;
				LET vcap_vig = 0;
				LET dIntDevengado = 0;
				LET dIvaIntDevengado = 0;

			END FOREACH;

		RETURN CodRet,Mensaje;
	END;
END PROCEDURE
DOCUMENT
'NOMBRE: Mario Olivo',
'DESCRIPCION: Se agrega parametro pFolioMovto con (DEFAULT = '') para agregar el filtro',
' 			(AND a.folio_movto = DECODE(pFolioMovto, "", a.folio_movto, pFolioMovto)) en la consulta de',
'			la tabla sd_promocion_credito.',
'			Se implementan reglas de informix.',
'			Se castea el codret por integer para compactar el codigo de retorno y entrar a las validaciones',
'FECHA DE MODIFICACION: 11/junio/2013',
'BASE DE DATOS: bdicred',
'FOLIO DE PROYECTO: 1373';

CREATE PROCEDURE "informix".sp_depura_sd_movhis_3()
RETURNING CHAR(6);

DEFINE cCodRet      CHAR(6); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE vStatusCred  CHAR(02);
DEFINE vcantidad    INTEGER;

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET vNumCred     = '';
LET vNumCredAux  = '';
LET vStatusCred  = '';
LET vcantidad    = 0;


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;		
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

--    SET DEBUG FILE TO '/INFORMIXDUMP/sp_depura_sd_movhis2.out';
--    TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT num_credito
      INTO vNumCredAux
      FROM "informix".sd_param_movhis_dep
     WHERE proceso = 4;

    IF vNumCredAux IS NULL THEN 
       LET vNumCredAux = ""; 
       INSERT INTO "informix".sd_param_movhis_dep VALUES(4,'');
    END IF;

    FOREACH WITH HOLD
       SELECT TRIM(num_credito)
         INTO vNumCred
         FROM bdicred:sd_maecred_vendida
        WHERE empresa = '001'
          AND fecha <  mdy('07','01','2013')
          AND num_credito > vNumCredAux
       ORDER BY num_credito ASC

       SELECT status_cred
         INTO vStatusCred
         FROM bdicred:sd_maecred
        WHERE empresa = '001'
          AND num_credito = vNumCred;

       LET vcantidad = 0;

       IF NVL(vStatusCred,"") = 'CV' THEN
           SELECT count(*)
             INTO vcantidad
             FROM bdicred:sd_movhis
            WHERE empresa = '001'
              AND num_credito = vNumCred;
       END IF;

       IF NVL(vStatusCred,"") = 'CV' and vcantidad > 0 THEN
            BEGIN WORK;
                insert into bdicred:sd_movhis_new
                select * from bdicred:sd_movhis
                where empresa = '001'
                and num_credito = vNumCred;

                DELETE FROM "informix".sd_movhis
                where empresa = '001'
                  and num_credito = vNumCred;

                UPDATE "informix".sd_param_movhis_dep
                   SET num_credito = vNumCred
                 where proceso = 4;

            COMMIT WORK;  
       ELSE
            BEGIN WORK;
                UPDATE "informix".sd_param_movhis_dep
                   SET num_credito = vNumCred
                 where proceso = 4;
            COMMIT WORK;  

       END IF;
            
    END FOREACH;

    RETURN cCodRet;

    END
END PROCEDURE;