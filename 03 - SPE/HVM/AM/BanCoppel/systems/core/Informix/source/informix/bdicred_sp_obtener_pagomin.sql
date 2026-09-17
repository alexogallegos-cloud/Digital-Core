CREATE PROCEDURE "informix".sp_obtener_pagomin(pEmpresa      CHAR(3),
                                               pNumCredito   CHAR(20))
RETURNING CHAR(6)       AS codigo_retorno,
          CHAR(80)      AS mensaje_retorno,
          DECIMAL(18,2) AS pago_minimo,
          DECIMAL(18,2) AS IntVdo,
          DECIMAL(18,2) AS IntMoratorio,
          DECIMAL(18,2) AS IvaIntVdo,
          DECIMAL(18,2) AS PagosVdos,
          DECIMAL(18,2) AS IvaIntMoratorio,
          DECIMAL(18,2) AS IntMes,
          DECIMAL(18,2) AS IvaIntMes,
          DECIMAL(18,2) AS IntVig,
          DECIMAL(18,2) AS IvaIntVig
            
          

DEFINE codigo_retorno    CHAR(6);
DEFINE mensaje_retorno   CHAR(80);
DEFINE numero_credito    CHAR(20);
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
DEFINE vRetCs_acum     DECIMAL(18,2);
DEFINE cTablaConsulta  CHAR(01);

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
LET codigo_retorno        = '';
LET mensaje_retorno       = '';
LET cTablaConsulta        = '0';


--SET DEBUG FILE TO '/tmp/sp_consulta_saldos_general.out'; --- MODIFICAR RUTA DEL ARCHIVO
--TRACE ON;

 BEGIN

 ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = 'OcurriÃÂ³ error al consultar los saldos'||' - '||cErrorInfo;
      RETURN cCodRet, cMensajeRet, dPagoMinimo, dIntVdo, dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;
    END IF;
 END EXCEPTION;

 LET cCodRet      = '000000';
 LET cMensajeRet  = 'Consulta pago mÃÂ­nimo correcta.';

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
    LET cMensajeRet= 'No hay informaciÃÂ³n para realizar la consulta';
    RETURN cCodRet, cMensajeRet, dPagoMinimo, dIntVdo, dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig; 
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

    IF cTipCred IS NULL OR cTipCred = '' THEN
          SELECT b.cod_prod
            INTO cTipCred
            FROM bdicred:sd_maecred_old a,
                 bdicred:sd_tipprod b
           WHERE a.num_credito = cNumCredito
             AND a.empresa=pEmpresa
             AND a.empresa=b.empresa
             AND a.num_producto=b.abrevia_prod;
             
			IF cTipCred IS NOT NULL THEN
				LET cTablaConsulta = '1'; 
			END IF;
    END IF;  		   

  IF cTipCred IS NULL OR cTipCred = '' THEN
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
            LET cMensajeRet= 'No hay informaciÃÂ³n para realizar la consulta';
            RETURN cCodRet, cMensajeRet, dPagoMinimo, dIntVdo, dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig; 
        END IF;
  END IF; 
 
  IF cTipCred='T' THEN

    IF cTablaConsulta = '0' THEN
      SELECT a.sucursal
        INTO cSucursal
        FROM "informix".sd_maecred a
       WHERE a.num_credito  = cNumCredito
  		   AND a.empresa      = cEmpresa;
  		   
  		SELECT
  			   NVL(monto_financiado,0)
  		  INTO dMontoFinanciado
  		  FROM "informix".sd_maesdos
  		 WHERE num_credito = cNumCredito
  		   AND empresa     = cEmpresa;
    ELSE
      SELECT a.sucursal
        INTO cSucursal
        FROM "informix".sd_maecred_old a
       WHERE a.num_credito  = cNumCredito
  		   AND a.empresa      = cEmpresa;
  		   
  		SELECT
  			   NVL(monto_financiado,0)
  		  INTO dMontoFinanciado
  		  FROM "informix".sd_maesdos_old
  		 WHERE num_credito = cNumCredito
  		   AND empresa     = cEmpresa;
    END IF;  
    
  		SELECT iva
  		  INTO dIvaSuc
  		  FROM bdinteg:"informix".si_sucursales
  		 WHERE sucursal = cSucursal
  		   AND empresa  = cEmpresa;
  
--        IF cTablaConsulta = '0' THEN
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
               AND capital_status IN ('2','7','6');
/*        ELSE
                    SELECT SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),
                   SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),
                   SUM(NVL(iva_debe,0) - NVL(iva_pagado,0)),
                   COUNT(num_credito)
              INTO dIntVdo,
                   dIntMoratorio,
                   dIvaIntVdo,
                   dPagosVdos
              FROM "informix".sd_amortiza_credito_old
             WHERE empresa     = cEmpresa
               AND num_credito = cNumCredito
               AND capital_status IN ('2','7');
        END IF;*/

--    IF cTablaConsulta = '0' THEN
  		FOREACH
  			SELECT (NVL(mora_iva_debe,0) - NVL(mora_iva_pagado,0) +( NVL(mora_provi_ordi + mora_provi_cope,0)* dIvaSuc ))
  			INTO dIntMoratorio_d
  			FROM sd_amortiza_credito a
  			WHERE a.empresa   = cEmpresa
  			AND a.num_credito = cNumCredito
  			AND capital_status IN ("2","7","6")
  
  			LET dIvaIntMoratorio = dIvaIntMoratorio + dIntMoratorio_d;
  
  		END FOREACH;
/*  	ELSE
  		FOREACH
  			SELECT (NVL(mora_iva_debe,0) - NVL(mora_iva_pagado,0) +( NVL(mora_provi_ordi + mora_provi_cope,0)* dIvaSuc ))
  			INTO dIntMoratorio_d
  			FROM sd_amortiza_credito_old a
  			WHERE a.empresa   = cEmpresa
  			AND a.num_credito = cNumCredito
  			AND capital_status IN ("2","7")
  
  			LET dIvaIntMoratorio = dIvaIntMoratorio + dIntMoratorio_d;
  
  		END FOREACH;
  	END IF;*/
      
      
		   LET dPagoMinimo      = NVL(dMontoFinanciado,0) + NVL(dIntVdo,0) + NVL(dIntMoratorio,0) + NVL(dIvaIntVdo,0) + NVL(dIvaIntMoratorio,0);

  ELIF cTipCred  in ('P','R') THEN
       SELECT a.sucursal
  		   INTO cSucursal
  		   FROM "informix".sd_maecredcrd a
  		  WHERE a.num_credito  = cNumCredito
  		    AND a.empresa  = cEmpresa;
  
  		LET nrows = DBINFO("sqlca.sqlerrd2");
  		IF nrows  = 0 THEN
  		    LET cCodRet     = '000004';
  		    LET cMensajeRet = 'El nÃÂºmero de crÃÂ©dito no existe';
   		    RETURN cCodRet, cMensajeRet, dPagoMinimo, dIntVdo, dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;
  
  		END IF;
  
      IF cTipCred='R' THEN
         LET dTasaMoratorios=0;
      END IF;
  
  		SELECT iva
  		  INTO dIvaSuc
  		  FROM bdinteg:"informix".si_sucursales
  		 WHERE sucursal = cSucursal
  		   AND empresa  = cEmpresa;
  
      --          CALL "informix".calc_iva_grav_pp(cEmpresa,cNumCredito,dTasaInteres,dIvaSuc,dtFechaHoy,
      --                                           dtIvaFechaPag,dtFechaOrigen,dtFechaCuota,dIntDevengado) RETURNING cCodRet,dIvaIntDevengado,cMensajeRet;
      --          IF cCodRet <> "000000" THEN
      --                LET cCodRet      = '000005';
      --                LET cMensajeRet  = 'OcurriÃÂ³ un error al realizar calculo';
      --    				    RETURN cCodRet, cMensajeRet, NVL(dPagoMinimo,0), dIntVdo, dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio;
      --          END IF;
  
    SELECT NVL(monto_financiado,0)
      INTO dMontoFinanciado
      FROM "informix".sd_maesdoscrd
		 WHERE num_credito = cNumCredito
		   AND empresa     = cEmpresa;
          
 
  		-- 2011-11-30 Se realiza cambio en calculo de IVA moratorio
  		SELECT SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),
  		       SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),
  			   SUM(NVL(iva_debe,0) - NVL(iva_pagado,0)),
  		       COUNT(num_credito)
  		  INTO dIntVdo,
  		       dIntMoratorio,
   			   dIvaIntVdo,
  		       dPagosVdos
  		  FROM "informix".sd_amortiza_creditocrd
  		 WHERE empresa     = cEmpresa
  		   AND num_credito = cNumCredito
  		   AND capital_status IN ('2','7','6');

        FOREACH
  			SELECT ((NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0))* dIvaSuc )
  			  INTO dIntMoratorio_d
  			  FROM sd_amortiza_creditocrd a
  			 WHERE a.empresa   = cEmpresa
  			   AND a.num_credito = cNumCredito
  			   AND capital_status IN ('2','7','6')
  
  			LET dIvaIntMoratorio = dIvaIntMoratorio + dIntMoratorio_d;
  
  		END FOREACH;
  		
  		   LET dPagoMinimo = NVL(dMontoFinanciado,0) + NVL(dIntVdo,0) + NVL(dIntMoratorio,0) + NVL(dIvaIntVdo,0) + NVL(dIvaIntMoratorio,0);
 
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
  
  		     LET dSdoActInt    = NVL(dIntVig,0) + NVL(dIntVdo,0) + NVL(dIntMoratorio,0);
  		     LET dSdoActIvaInt = NVL(dIvaIntVig,0) + NVL(dIvaIntVdo,0) + NVL(dIvaIntMoratorio,0);
  
  			 LET dPagoMinimo = dPagoMinimo + NVL(dIntVig,0) + NVL(dIvaIntVig,0);
 

END IF;

  /* RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
          NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
          NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
          NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
          NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
          NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0),NVL(dIvaIntDevengado,0), NVL(dLineaDisponible,0),
          NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''),
          NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''),
          NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');
  */

 RETURN cCodRet, cMensajeRet, dPagoMinimo, dIntVdo, dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig; 
   
   
END
END PROCEDURE
DOCUMENT
'AUTOR : Marco A. Campos',
'FECHA : 20/05/2014',
'BD    : BDICRED';

CREATE PROCEDURE "informix".genmov_ifrs(
   p_empresa                VARCHAR(3),
   p_num_credito            VARCHAR(20),
   p_num_producto           VARCHAR(4),
   p_codigo_ref             INTEGER,
   p_codigo_fun             VARCHAR(3),
   p_fecha_hoy              DATE,
   p_monto                  MONEY(14,2),
   p_foliosuc               VARCHAR(16),
   p_sucursal               VARCHAR(4),
   p_divisa                 VARCHAR(2),
   p_transacc_suc           VARCHAR(4))
RETURNING VARCHAR(10), VARCHAR(80);

DEFINE   p_cod_ret       VARCHAR(10);
DEFINE   p_mensaje       VARCHAR(80);

DEFINE   v_plaza         VARCHAR(3);
DEFINE   v_hora          DATETIME HOUR TO FRACTION(3);
DEFINE   vm_secuencia    INTEGER;
DEFINE   v_reversado     VARCHAR(1);
DEFINE   v_usuario       VARCHAR(8);

DEFINE   v_num_producto  VARCHAR(4);
DEFINE   v_codigo_ref    INTEGER;
DEFINE   v_codigo_fun    VARCHAR(3);
DEFINE   v_fecha_hoy     DATE;
DEFINE   v_monto         DECIMAL(18,2);
DEFINE   v_foliosuc      VARCHAR(16);
DEFINE   v_sucursal      VARCHAR(4);
DEFINE   v_divisa        VARCHAR(2);
DEFINE   v_transacc_suc  VARCHAR(4);

DEFINE SQL_ERR     INTEGER;
DEFINE ISAM_ERR    INTEGER;
DEFINE ERROR_INFO  VARCHAR(80);
DEFINE vcadena     INTEGER;
DEFINE vSucOri     CHAR(4);

DEFINE   vCodFunIFRS     CHAR(3);
DEFINE   vCodRefIFRS     SMALLINT;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET  = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

   LET P_COD_RET      = '00000';
   LET P_MENSAJE      = 'PROCESO EXITOSO';
   LET v_num_producto =  p_num_producto ;
   LET v_codigo_ref   =  p_codigo_ref   ;
   LET v_codigo_fun   =  p_codigo_fun   ;
   LET v_fecha_hoy    =  p_fecha_hoy    ;
   LET v_monto        =  p_monto        ;
   LET v_foliosuc     =  p_foliosuc     ;
   LET v_sucursal     =  p_sucursal     ;
   LET v_divisa       =  p_divisa       ;
   LET v_transacc_suc =  p_transacc_suc ;
   LET vCodFunIFRS    =  '';
   LET vCodRefIFRS    =  '';

   IF (p_transacc_suc IS NULL) THEN
      LET v_transacc_suc = '0000';
   END IF;

   IF (v_fecha_hoy IS NULL) THEN
      SELECT fecha_hoy
      INTO   v_fecha_hoy
      FROM   sd_fechas;
   END IF;
   IF (v_monto IS NULL) THEN
      LET v_monto = 0;
   END IF;
   IF (v_divisa IS NULL) THEN
      LET v_divisa = '00';
   END IF;
   IF (v_num_producto IS NULL) THEN
      LET v_num_producto = '    ';
   END IF;

   IF (v_foliosuc IS NULL) THEN
      LET p_cod_ret = '110';
      LET P_MENSAJE = 'ERROR';
      RETURN P_COD_RET, P_MENSAJE;
   END IF;

   LET p_cod_ret    = '00000';
   LET P_MENSAJE    = 'PROCESO EXITOSO';
   LET v_hora       = EXTEND(CURRENT,HOUR TO fraction(3));

   LET v_reversado  = 'N';
--   v_usuario    := USER;


   LET vcadena = 0;

   let vcadena = length(p_foliosuc) - 8;
   LET v_usuario    = substr(p_foliosuc,1,vcadena);

--   LET v_usuario    = substr(v_foliosuc,1,8);

   --############################################################
   --####  GENERACION DE MOVIMIENTOS Y DETALLE CONTABLE     #####
   --############################################################

   SELECT plaza
   INTO   v_plaza
   FROM   bdinteg:si_sucursales
   WHERE  empresa  = p_empresa
   AND    sucursal = v_sucursal;

   IF V_PLAZA IS NULL OR V_PLAZA = '' THEN
      LET P_COD_RET = '00100';
      LET P_MENSAJE = 'LA INFORMACION PLAZA/SUCURSAL DEL CREDITO ES INCORRECTA';
      RETURN P_COD_RET, P_MENSAJE;
   END IF;

   SELECT sucursal INTO vSucOri
     FROM sd_maecred
    WHERE empresa = p_empresa
      AND num_credito = p_num_credito;

   /*SELECT codigo_fun_ifrs, codigo_ref_ifrs
	INTO vCodFunIFRS, vCodRefIFRS
       FROM sd_transfun
      WHERE empresa = p_empresa
	AND codigo_fun = v_codigo_fun
   AND codigo_ref = v_codigo_ref;

   IF ((vCodFunIFRS IS NOT NULL) AND (vCodRefIFRS IS NOT NULL)) THEN 
      LET v_codigo_fun = vCodFunIFRS;
      LET v_codigo_ref = vCodRefIFRS;
   END IF;*/

   INSERT INTO sd_movdia_ifrs (
               EMPRESA        ,
               FECHA_MOV      ,
               HORA_MOV       ,
               SUCURSAL       ,
               NUM_CREDITO    ,
               PLAZA          ,
               TRANSACC_SUC   ,
               USUARIO        ,
               MONTO          ,
               CODIGO_FUN     ,
               CODIGO_REF     ,
               DIVISA         ,
               REVERSADO      ,
               FOLIO_SUC      ,
               NUM_PRODUCTO   ,
	       SUC_ORIGEN     )
      VALUES ( p_empresa,
               v_fecha_hoy,
               current,
               v_sucursal,
               p_num_credito,
               v_plaza,
               v_transacc_suc,
               v_usuario,
               v_monto,
               v_codigo_fun,
               v_codigo_ref,
               v_divisa,
               v_reversado,
               v_foliosuc,
               v_num_producto,
	       vSucOri);

   RETURN P_COD_RET, P_MENSAJE;

END;
END PROCEDURE;