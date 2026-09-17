CREATE PROCEDURE "informix".sp_cierre_diario_pp_parte_pbainci(pEmpresa CHAR(3), pCodTipCred CHAR(2), pProceso CHAR(3))
RETURNING
   CHAR(6)        AS Cod_Ret,
   CHAR(80)       AS Mens_Ret;

-- Modifico: Francisco Martinez Viveros
-- Fecha: 21/mar/2013
-- Comentario: Se adicionan los movimientos de provision a fin de mes, para los prestamos que facturan el dia 1o. de mes
-- se genera el movimiento provision del periodo al dia 31 y el movimiento del dia 1 mas su facturacion.
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   CHAR(125);

DEFINE cBegin         CHAR(1);
DEFINE cFolio         CHAR(16);
DEFINE cEmpresa       CHAR(3);
DEFINE cNumCredito    CHAR(20);
DEFINE cStatusCred    CHAR(2);
DEFINE cStatusCredAnt CHAR(2);
DEFINE cStatusCredIndica CHAR(2);
DEFINE cDivisa        CHAR(2);
DEFINE cNumProducto   CHAR(4);
DEFINE dtFechaApert   DATE;
DEFINE iDiaCorte      INTEGER;
DEFINE cSucursal      CHAR(4);
DEFINE cPlaza         CHAR(3);
DEFINE dIvaSuc        DECIMAL(5,3);
DEFINE cCodTipCred    CHAR(2);
DEFINE iDiasCalc      INTEGER;
DEFINE dtFechaHoy     DATE;
DEFINE dtFechaHoyAux  DATE;
DEFINE dtFechaProx    DATE;
DEFINE dtFechaFinMes  DATE;
--DEFINE dtFechaFinMesAnt DATE;
DEFINE dtFechaProxCuota  DATE;
DEFINE dtFechaVencto  DATE;
DEFINE iDiasInt       INTEGER;
DEFINE iDiasInt_inh   INTEGER;

DEFINE dIntDiario     DECIMAL(18,2);
DEFINE dIntDiario_inh DECIMAL(18,2);

DEFINE dTasaInter       DECIMAL(9,6);
DEFINE dTasaInterMor    DECIMAL(9,6);
DEFINE dTasaInterMorCop DECIMAL(9,6);
DEFINE dSdoCapital      DECIMAL(18,2);
DEFINE dMntVencido      DECIMAL(18,2);
DEFINE dMntVencTras     DECIMAL(18,2);
DEFINE dCapTrasNoVen    DECIMAL(18,2);
DEFINE dSdoCapInso      DECIMAL(18,2);
DEFINE dSdoNoExig       DECIMAL(18,2);
DEFINE dSdoInt          DECIMAL(18,2);
DEFINE dSdoInt_inh      DECIMAL(18,2);
DEFINE dSdodiaantint    DECIMAL(18,2);
DEFINE dSdomesantint    DECIMAL(18,2);
DEFINE dSdomoratorio    DECIMAL(18,2);
DEFINE dSdocontabmora   DECIMAL(18,2);
DEFINE dMontofinanciado DECIMAL(18,2);
DEFINE dIvaIntVencido   DECIMAL(18,2);
DEFINE dIvaIntVigente   DECIMAL(18,2);
DEFINE dSdotrab4        DECIMAL(18,2);
DEFINE dSdo             DECIMAL(18,2);
DEFINE dtFechaCuota     DATE;
DEFINE dtFechaCuotaAnt  DATE;
DEFINE dProvInt       	DECIMAL(14,2);
DEFINE dProvInt_inh    	DECIMAL(14,2);
DEFINE dIvaPag        	DECIMAL(14,2);
--ini cas
DEFINE dIntGrav      	DECIMAL(14,2);
DEFINE dIntExen       	DECIMAL(14,2);
DEFINE dIntGrav_inh   	DECIMAL(14,2); --FMV
DEFINE dIntExen_inh    	DECIMAL(14,2); --FMV

DEFINE dtIvaFechaPag    DATE;
DEFINE dCapMtoCuota     DECIMAL(14,2);
DEFINE iNumPago         INTEGER;
DEFINE dProvIva       	DECIMAL(14,2);
DEFINE dProvIva_inh    	DECIMAL(14,2); --FMV
DEFINE dIntVdo          DECIMAL(18,2);
DEFINE dTraspCap        DECIMAL(14,2);
DEFINE dTraspInt        DECIMAL(18,2);
DEFINE cCapStatusCuota  CHAR(1);
DEFINE dSdoMora         DECIMAL(18,2);
DEFINE dIntMora         DECIMAL(18,2);
DEFINE dIntCope         DECIMAL(18,2);
DEFINE iContCierre      INTEGER;
DEFINE iContCorte       INTEGER;
DEFINE iContCommit      INTEGER;
DEFINE cIdProc1         CHAR(1);
DEFINE cIdProc2         CHAR(1);
DEFINE cIdProc3         CHAR(1);
DEFINE cIdProc4         CHAR(1);
DEFINE dIntProvFinMes   DECIMAL(18,2);
DEFINE dIvaProvFinMes   DECIMAL(18,2);
DEFINE dIvaIntReal      DECIMAL(18,2);
DEFINE dIvaIntReal_inh  DECIMAL(18,2); --FMV
DEFINE dtFechaMesiversario DATE;
DEFINE cBanTemp         CHAR(1);
DEFINE iNumVdos         INTEGER;
DEFINE iPerTrasp        INTEGER;
DEFINE credcontproc 	char(1);
DEFINE intecontproc 	char(1);
DEFINE CodigoRefProvIva INTEGER;
DEFINE CodigoRefProvInt INTEGER;
DEFINE dIntPeriodo      DECIMAL(18,2);
DEFINE dIvaPeriodo      DECIMAL(18,2);
DEFINE cSQL				CHAR(200);
DEFINE vlCapitalDebe    DECIMAL (14,2);
--FMV 03-SEP-11 --CREDINOMINA
DEFINE iTpDiasFechaPago INTEGER;
--FMV 09-MAY-11
DEFINE dCapTrasVen_Amort DECIMAL(14,2);
--SDFM 11-06-12 -- VENTA PP
DEFINE v_marca_ayuda CHAR(1);
--FMV 24abr13: Indicadores de buro
DEFINE vf_fecha_ult_pago DATE;
DEFINE vdias_atraso      INTEGER;
--FMV 9jul13: Traspaso 90, finalizando plazo
DEFINE vf_fecha_vencim   DATE;
DEFINE vi_dias_trasp_cap INTEGER;
DEFINE vlIntVenBal      DECIMAL (14,2);
DEFINE vlIvaIntVenBal   DECIMAL (14,2);
DEFINE Campotrabajo3 CHAR(10);
-- JOM 11/04/2013 Se cambia traspado a periodos INI
DEFINE dFechacuotamin   DATE;
DEFINE iNumVdosaux      INTEGER;
DEFINE pNumCredIni		CHAR(20);
DEFINE pNumCredFin		CHAR(20);

-- RQM 09 473 TRIAD
DEFINE vSdoTotLiquidar 			decimal(18,2);
DEFINE vPagoMinimo 				decimal(18,2);
DEFINE vSdoTotVencido 			decimal(18,2);

-- JOM 11/04/2013 Se cambia traspado a periodos FIN
--FMJ APoyo 2014
DEFINE wbandera_apoyo CHAR(1);
DEFINE iFechaVencto			DATE;
LET cBegin           = "N";
LET cFolio         	 = "";
LET cEmpresa         = "";
LET cNumCredito      = "";
LET cStatusCred    	 = "";
LET cStatusCredAnt 	 = "";
LET cStatusCredIndica = "";
LET cNumProducto   	 = "";
LET cDivisa          = "";
LET dtFechaApert     = DATE(1);
LET iDiaCorte        = 0;
LET cSucursal      	 = "";
LET cPlaza         	 = "";
LET dIvaSuc          = 0;
LET cCodTipCred      = "";
LET iDiasCalc        = 0;
LET dtFechaHoy       = DATE(1);
LET dtFechaHoyAux    = DATE(1);
LET dtFechaProx      = DATE(1);
LET dtFechaFinMes    = DATE(1);
--LET dtFechaFinMesAnt    = DATE(1);
LET dtFechaProxCuota = DATE(1);
LET dtFechaVencto    = DATE(1);
LET iDiasInt         = 0;
LET iDiasInt_inh     = 0;

LET dIntDiario       = 0;
LET dIntDiario_inh   = 0;
LET dTasaInter       = 0;
LET dTasaInterMor    = 0;
LET dTasaInterMorCop = 0;
LET dSdoCapital      = 0;
LET dMntVencido      = 0;
LET dMntVencTras     = 0;
LET dCapTrasNoVen    = 0;
LET dSdoCapInso      = 0;
LET dSdoNoExig       = 0;
LET dSdoInt          = 0;
LET dSdoInt_inh      = 0;

LET dSdodiaantint       = 0;
LET dSdomesantint       = 0;
LET dSdomoratorio       = 0;
LET dSdocontabmora      = 0;
LET dMontofinanciado    = 0;
LET dIvaIntVencido      = 0;
LET dIvaIntVigente      = 0;
LET dSdotrab4           = 0;
LET dSdo                = 0;
LET dtFechaCuota        = DATE(1);
LET dtFechaCuotaAnt     = DATE(1);
LET dProvInt       	    = 0;
LET dProvInt_inh  	    = 0;
LET dIvaPag        	    = 0;
LET dtIvaFechaPag       = DATE(1);
LET dCapMtoCuota        = 0;
LET iNumPago            = 0;
LET dProvIva       	    = 0;
LET dProvIva_inh  	    = 0;
LET dIntVdo             = 0;
LET dTraspCap           = 0;
LET dTraspInt           = 0;
LET cCapStatusCuota     = "";
LET dSdoMora            = 0;
LET dIntMora            = 0;
LET dIntCope            = 0;
LET iContCierre         = 0;
LET iContCorte          = 0;
LET iContCommit         = 0;
LET cIdProc1            = "";
LET cIdProc2            = "";
LET cIdProc3            = "";
LET cIdProc4            = "";

LET dIntProvFinMes      = 0;
LET dIvaProvFinMes      = 0;
LET dtFechaMesiversario = DATE(1);
LET cBanTemp            = 'N';
LET iNumVdos            = 0;
LET iPerTrasp           = 0;
LET dIntGrav            = 0;
LET dIntExen            = 0;
LET dIntGrav_inh        = 0;
LET dIntExen_inh        = 0;

LET ccodret             ='000';
LET CodigoRefProvIva    = 0;
LET CodigoRefProvInt    = 0;
LET dIntPeriodo         = 0;
LET dIvaPeriodo         = 0;
LET cSQL				= "";
LET vlCapitalDebe       = 0;
-- FMV 09-MAY-11 INICIO DE LA VARIABLE PARA EL CALCULO DE INTERES EN VENCIMIENTO, STATUS 1 DE AMORTIZA
LET dCapTrasVen_Amort = 0;
--FMV 03-SEP-11 --6400
LET iTpDiasFechaPago = 0;
--SDFM 11-06-12 -- VENTA PP
LET v_marca_ayuda = "";
LET vf_fecha_ult_pago = DATE(1);
LET vdias_atraso = 0;
LET vf_fecha_vencim   = DATE(1);
LET vi_dias_trasp_cap = 0;
LET vlIntVenBal      = 0;
LET vlIvaIntVenBal   = 0;
LET Campotrabajo3 = '';
-- JOM 11/04/2013 Se cambia traspado a periodos INI
LET dFechacuotamin = DATE(1);
LET iNumVdosaux    = 0;
-- JOM 11/04/2013 Se cambia traspado a periodos FIN
LET wbandera_apoyo = '';
LET iFechaVencto = DATE(1);
LET pNumCredIni		='';
LET pNumCredFin		='';

-- RQM 09 473 TRIAD
LET vSdoTotLiquidar 		= 0.0;
LET vPagoMinimo				= 0.0;
LET vSdoTotVencido 			= 0.0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 10;
---SET PDQPRIORITY 5; HMD-INCIDENCIA-20220224


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cNumCredito ||cErrorInfo;

      IF cBegin = "S" THEN
          ROLLBACK WORK;
       END IF;
/*
      UPDATE "informix".sd_contproc
         SET status_proc = "C",
             hora_fin    = CURRENT,
             cod_ret     = cCodRet,
             mensaje     = cMensajeRet
       WHERE empresa     = cEmpresa
         AND proceso     = "CierrePrest"
         AND fecha       = dtFechaHoy;

      UPDATE bdinteg:sx_contproc
         SET status_proc = "C",
             hora_fin    = CURRENT,
             codret      = cCodRet
       WHERE empresa     = cEmpresa
         AND proceso     = "CierrePrest"
         AND fecha       = dtFechaHoy;
*/
	  IF cBanTemp ='S' THEN
	     DROP TABLE tmp_sucursales_pp;
	  END IF;

   RETURN cCodRet,cMensajeRet;
   END IF;
END EXCEPTION;
 
-- SET DEBUG FILE TO "/resplogifx/archivoscartera/sp_cierre_diario_pp_parte.out";
-- TRACE ON;

-- *******************************************************
--  VALIDACIONES DE EJECUCION DE PROCESO                 *
-- *******************************************************
SELECT a.empresa
  INTO cEmpresa
  FROM bdinteg:si_empresas a
 WHERE a.empresa = pEmpresa;

IF NVL(cEmpresa,"") = "" THEN
     LET cCodRet     = "000001";
     LET cMensajeRet = "La empresa no existe";
     RETURN cCodRet, cMensajeRet;
END IF;

SELECT a.fecha_hoy, a.prox_fecha, a.ult_dia_mes,
       USER||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(CURRENT,3,2)
           ||SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2)
           ||SUBSTR(CURRENT,18,2)
  INTO dtFechaHoy, dtFechaProx, dtFechaFinMes,
       cFolio
  FROM "informix".sd_fechas a
 WHERE a.empresa = cEmpresa;

 --temporal solo para pruebas
--let  dtFechaHoy = today-1;
--let  dtFechaProx = dtFechaHoy+1;
 --temporal solo para pruebas
 
-- *******************************************************
--  INSERTA PARA EJECUCION DE PROCESO                 *
-- *******************************************************
--INI CAS
/*
    SELECT status_proc
    INTO intecontproc
    FROM bdinteg:sx_contproc
    WHERE fecha= dtFechaHoy
      and proceso ='CierrePrest';

    SELECT status_proc
    INTO credcontproc
    FROM bdicred:sd_contproc
    WHERE fecha= dtFechaHoy
      and proceso ='CierrePrest';

    IF (intecontproc IS NULL) THEN
      INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret)
      VALUES ('001','CierrePrest',dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
    end if;

    if (credcontproc IS NULL) THEN
      INSERT INTO  sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
      VALUES ('001','CierrePrest',dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Iniciamos');
    end if;

    UPDATE bdinteg:sx_contproc
       SET status_proc='I'
     WHERE fecha= dtFechaHoy
       and proceso ='CierrePrest';

     UPDATE bdicred:sd_contproc
        SET status_proc='I' ,mensaje = 'Iniciamos'
      WHERE fecha= dtFechaHoy
        and proceso ='CierrePrest';
*/
--FIN CAS
SELECT a.cod_tipcred
  INTO cCodTipCred
  FROM "informix".sd_tipcred a
 WHERE a.cod_tipcred  = pCodTipCred
   AND a.empresa      = cEmpresa;

IF NVL(cCodTipCred,"") = "" THEN
     LET cCodRet     = "000002";
     LET cMensajeRet = "El tipo de credito indicado no existe";
     RETURN cCodRet, cMensajeRet;
END IF;

SELECT a.valor
  INTO iDiasCalc
  FROM "informix".sd_param a
 WHERE a.cod_param = "24";

IF iDiasCalc IS NULL THEN
    LET cCodRet     = "000003";
    LET cMensajeRet = "Parametro para los dias de calculo de interes no encontrado";
    RETURN cCodRet, cMensajeRet;
END IF;

-- Dias de interes.
LET iDiasInt = dtFechaProx - dtFechaHoy;

IF NVL(iDiasInt,0) <= 0 THEN
    LET cCodRet     = "000004";
    LET cMensajeRet = "Fechas incorrectas";
    RETURN cCodRet, cMensajeRet;
END IF;

IF pProceso IS NULL OR pProceso = '' THEN
    LET cCodRet     = "000005";
    LET cMensajeRet = "Parametro de proceso invalido";
    RETURN cCodRet, cMensajeRet;
END IF;


SELECT substr(valor,1,12),substr(valor,14,12)
INTO pNumCredIni,pNumCredFin
FROM bdicred:sd_param 
WHERE empresa 	= cEmpresa 
  AND cod_param	= pProceso;

IF pNumCredIni IS NULL OR pNumCredFin IS NULL OR pNumCredIni = '' OR pNumCredFin = '' THEN
    LET cCodRet     = "000006";
    LET cMensajeRet = "Sin cuentas a procesar";
    RETURN cCodRet, cMensajeRet;
END IF;
  
SELECT a.empresa, a.sucursal, a.iva, a.plaza
  FROM bdinteg:si_sucursales a
 WHERE a.tpo_sucursal = "S"
  INTO TEMP tmp_sucursales_pp;
CREATE INDEX indx_sucursal_pp ON tmp_sucursales_pp (empresa, sucursal);

LET cBanTemp = 'S';

--CALL "informix".monthadd(dtFechaFinMes,-1) RETURNING dtFechaFinMesAnt;
--LET dtFechaFinMesAnt=DATE(MDY(MONTH(dtFechaFinMes),'01',YEAR(dtFechaFinMes))-1);
CALL "informix".sp_valfechabil(dtFechaHoy+1,'+') RETURNING cCodRet, dtFechaHoyAux;

-- *******************************************************
--  SELECCION DE CREDITOS PARA PROCESAR                  *
-- *******************************************************
FOREACH WITH HOLD
        SELECT a.num_credito         , a.status_cred       , a.num_producto     , a.sucursal         , a.divisa           ,
               a.fecha_apertura      , a.tasa_interes      , a.tasa_moratorios  , b.sdo_capital      , b.monto_vencido    ,
               b.mto_venc_trasp      , b.cap_tras_no_venci , b.sdo_cap_insoluto , b.sdo_no_exig      , b.sdo_intereses    ,
               c.dia_corte           , b.int_tra_no_exig   , c.fecha_vencto     , c.prox_fecha_pago  , b.provision_normal ,
               b.sdo_global_int      , d.period_pago_cap   , b.sdo_dia_ant_int  , b.sdo_mes_ant_int  , b.sdo_moratorio    ,
               b.sdo_contab_mora     , b.monto_financiado  , b.mto_venc_int     , b.mto_finan_vdo    , b.sdo_trab4        ,
	           nvl(c.tp_dias_fecha_pago,0) , a.id_origen   , c.fecha_ult_pago   , a.fecha_vencim     , a.dias_trasp_cap   ,
               a.campo_trab3

          INTO cNumCredito          , cStatusCred         , cNumProducto       , cSucursal           , cDivisa            ,
               dtFechaApert         , dTasaInter          , dTasaInterMor      , dSdoCapital         , dMntVencido        ,
               dMntVencTras         , dCapTrasNoVen       , dSdoCapInso        , dSdoNoExig          , dSdoInt            ,
               iDiaCorte            , dIntVdo             , dtFechaVencto      , dtFechaMesiversario , dIntProvFinMes     ,
               dIvaProvFinMes       , iPerTrasp           , dSdodiaantint      , dSdomesantint       , dSdomoratorio      ,
               dSdocontabmora       , dMontofinanciado    , dIvaIntVencido     , dIvaIntVigente      , dSdotrab4          ,
               iTpDiasFechaPago     , v_marca_ayuda       , vf_fecha_ult_pago  , vf_fecha_vencim     , vi_dias_trasp_cap  ,
               Campotrabajo3
          FROM sd_maecredcrd a, sd_maesdoscrd b, sd_maecredanexocrd c, sd_definicion d
         WHERE a.num_credito   = b.num_credito
           AND a.empresa       = b.empresa
           AND c.num_credito   = a.num_credito
           AND c.empresa       = a.empresa
           AND d.num_producto  = a.num_producto
           AND d.empresa       = c.empresa
           AND a.empresa       = cEmpresa
           AND a.status_cred   NOT IN ("FF","FM","CC","FC","CV","FI")
           AND c.fecha_proceso = dtFechaHoy
           AND d.cod_tipcred   = cCodTipCred
AND a.num_credito ='630180548665'
--           AND a.num_credito =  '630159854789'
--           AND a.num_credito <  pNumCredFin
		  

--let cMensajeRet = pNumCredIni||'-'||pNumCredFin;
		   
--RETURN cCodRet, cMensajeRet;

		   
 --          IF cBegin = "N" AND iContCommit=0 THEN
               BEGIN WORK;
               LET cBegin = "S";
--           END IF;

            LET cStatusCredAnt     = cStatusCred;
            LET cStatusCredIndica  = cStatusCred;
            LET cIdProc1          = "";	 LET cIdProc2          = "";
            LET cIdProc3          = "";	 LET cIdProc4          = "";
            LET dIvaIntReal       = 0;	 LET dIvaIntReal_inh   = 0;
            LET dProvIva          = 0;	 LET dProvInt          = 0;
            LET dProvIva_inh      = 0;	 LET dProvInt_inh      = 0;
            LET dCapMtoCuota      = 0;	 LET dSdoInt_inh       = 0;
            LET dIntGrav_inh      = 0;	 LET dIntExen_inh      = 0;
            LET iDiasInt_inh      = 0;	 LET dIntDiario_inh    = 0;

			------Programa Apoyo
			SELECT bandera INTO wbandera_apoyo
               FROM sd_programa_apoyo2018crd
              WHERE num_credito = cNumCredito;
			  IF ( wbandera_apoyo is null ) THEN LET wbandera_apoyo = ''; END IF;
-- Venta de Cartera de PP
		IF ( v_marca_ayuda = '1' OR cStatusCred = 'CV' OR ( Campotrabajo3 = 'BAJA' AND cStatusCred <> 'CV' ) OR wbandera_apoyo ='A' ) THEN

			  -- Identificar  (Cierre de Mes).
			 IF dtFechaHoy = dtFechaFinMes THEN
			    LET cIdProc1 = "C";
			 END IF;
			 -- Validaciones para dias inhabiles y cambios de mes. (FacturaciÃÂÃÂÃÂÃÂ³n)
			 IF dtFechaHoyAux = dtFechaMesiversario THEN
				LET cIdProc2 = "F";
			 END IF;
			 -- Identificar un (Mesiversario)
			 IF dtFechaHoy = dtFechaMesiversario THEN
				 LET cIdProc3 = "M";
			 END IF;
             --FMV 7mar13: Valida registros de la Provision a fin de mes, para PP Factu dia 1o. de mes
             IF cIdProc1 = "C" AND cIdProc2 = "F" THEN
                 LET cIdProc4 = "P";  --> Registro para validar (P)rovision
                 LET iDiasInt_inh = iDiasInt - 1;
             END IF;

            select sum(interes_debe - interes_pagado) vencido_balanza,
                   sum(iva_debe - iva_pagado) iva_vencido_balanza
              into vlIntVenBal, vlIvaIntVenBal
              from bdicred:sd_amortiza_creditocrd 
             where empresa = cEmpresa 
               and num_credito = cNumCredito 
               and capital_status = '2'
               and campo_trabajo3 <> 'V';
        
            if  vlIntVenBal is null then
               let vlIntVenBal = 0;
               let vlIvaIntVenBal = 0;
            end if;

			 CALL sp_actsdodiariocrd(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
									(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
										  WHEN cIdProc2 = "F" THEN (dSdoNoExig)
										  ELSE (dSdoNoExig + dIntProvFinMes)  END), dIntVdo,
									(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
										  WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
										  ELSE (dIvaIntVigente + dIvaProvFinMes) END),
									dIvaIntVencido,vlIntVenBal,vlIvaIntVenBal,dMontofinanciado,dtFechaHoy)
		  	RETURNING cCodRet;
			
			

			IF (cCodRet <> "000") THEN
				 LET cCodRet     = "000002";
				 LET cMensajeRet = "Error al grabar en tabla saldos diarios";
				 RETURN cCodRet, cMensajeRet;
			END IF;

            IF ( v_marca_ayuda = '1' OR ( Campotrabajo3 = 'BAJA' AND cStatusCred <> 'CV' ) OR wbandera_apoyo ='A') THEN
               SELECT COUNT(*)
                 INTO iNumVdos
                 FROM "informix".sd_amortiza_creditocrd a
                WHERE a.empresa        = cEmpresa
                  AND a.num_credito    = cNumCredito
                  AND a.capital_status IN ("2","7");

                  IF (iNumVdos = 0) THEN
                      UPDATE "informix".sd_maecredanexocrd
                         SET fecha_vencto  = NULL
                       WHERE num_credito    = cNumCredito
                         AND empresa        = cEmpresa;
                  END IF;

               UPDATE sd_maesdoscrd
                  SET mto_fin_ven_trasp = iNumVdos
                WHERE empresa = cEmpresa
                  AND num_credito = cNumCredito;

               UPDATE "informix".sd_maecredanexocrd
                  SET fecha_proceso  = dtFechaProx
                WHERE num_credito    = cNumCredito
                  AND empresa        = cEmpresa;

               IF cIdProc1 = "C" or day(dtFechaHoy)=20 THEN
                  INSERT INTO "informix".sd_maesdoscontcrd
                       SELECT dtFechaHoy, *
                         FROM informix.sd_maesdoscrd
                        WHERE num_credito = cNumCredito
                          AND empresa     = cEmpresa;

                  INSERT INTO "informix".sd_maecredcontcrd
                       SELECT dtFechaHoy, *
                         FROM informix.sd_maecredcrd
                        WHERE num_credito = cNumCredito
                          AND empresa     = cEmpresa;
               END IF;
               IF ( cIdProc3 = "M" ) THEN
                      call "informix".calculamesiversario(iDiaCorte::INTEGER, dtFechaMesiversario, 1, iTpDiasFechaPago)
                          RETURNING cCodRet, dtFechaProxCuota;

                      UPDATE "informix".sd_maecredanexocrd
                         SET prox_fecha_pago = dtFechaProxCuota
                       WHERE num_credito     = cNumCredito
                         AND empresa         = cEmpresa;
                  END IF;

                  IF ( cIdProc3 = "M" OR cIdProc2 = "F" ) THEN
                     INSERT INTO "informix".sd_maesdoshistcrd
                           SELECT dtFechaHoy, *
                             FROM informix.sd_maesdoscrd
                            WHERE num_credito = cNumCredito
                              AND empresa     = cEmpresa;
                  END IF;
			   IF (  cIdProc2 = "F" or cIdProc3 = "M") AND (wbandera_apoyo ='A' or Campotrabajo3 = 'BAJA') THEN
				 INSERT INTO "informix".sd_maesdoscrd_apoyo2018
                 SELECT dtFechaHoy, * FROM informix.sd_maesdoscrd
				 WHERE num_credito = cNumCredito AND empresa = cEmpresa;
			  
				 INSERT INTO bdicred:"informix".sd_amortiza_creditocrd_apoyo2018
				 SELECT dtFechaHoy, * FROM bdicred:"informix".sd_amortiza_creditocrd
				  WHERE num_credito = cNumCredito AND empresa = pEmpresa;					  
				 if  cIdProc3 = "M" then
				   update bdicred:"informix".sd_amortiza_creditocrd
				      set fecha_cuota = monthadd(fecha_cuota,1)
				    where capital_status in (3,7,1)
				      AND num_credito = cNumCredito
                      AND empresa = pEmpresa;
				 end if;
			   END IF;
			   IF cIdProc1 ='C' THEN
			     SELECT min(fecha_cuota) INTO  iFechaVencto
				   FROM "informix".sd_amortiza_creditocrd a
				  WHERE a.empresa        = cEmpresa
					AND a.num_credito    = cNumCredito
					AND a.capital_status IN ("2","7");						  
				 IF iFechaVencto IS NULL THEN  LET vdias_atraso= 0; 
				 ELIF cStatusCred ='AA' THEN LET vdias_atraso= 0;
				 ELSE
			       LET vdias_atraso = (dtFechaFinMes - nvl(iFechaVencto,dtFechaFinMes) + 1);                   
			     END IF;
				 UPDATE "informix".sd_indicador_cred_crd
                      SET dias_atraso   = NVL(vdias_atraso,0)  
                   WHERE empresa = pEmpresa
                     AND num_credito = cNumCredito;
			   END IF;
            END IF;
            COMMIT WORK;
            CONTINUE FOREACH;
		END IF;
-- Venta de cartera de PP
-- *******************************************************
--  CALCULO DE INTERESES DIARIOS                         *
-- *******************************************************
           --Se obtiene el saldo para calcular los int diarios.
  --FMV 09-may-11  Calcula el int sobre el sdo capital sin el monto de traspaso ya calculado en la facturacion
            SELECT sum(capital_debe - capital_pagado)
               INTO dCapTrasVen_Amort
              FROM sd_amortiza_creditocrd
             WHERE empresa = cEmpresa
               AND num_credito = cNumCredito
               AND capital_status = '1';

               IF dCapTrasVen_Amort IS NULL
                 THEN
                    LET dCapTrasVen_Amort = 0;
               END IF;
                  --calculo de los int diarios
                  LET dIntDiario = (((dSdoCapital + dCapTrasNoVen - dCapTrasVen_Amort) * dTasaInter) / (iDiasCalc * 100)) * iDiasInt;
             IF dtFechaHoy = dtFechaFinMes AND dtFechaHoyAux = dtFechaMesiversario THEN
                 LET cIdProc4 = "P";  --> Registro para validar (P)rovision
                 LET iDiasInt_inh = iDiasInt - 1;
             END IF;

            IF cIdProc4 = "P"  THEN
               LET dIntDiario_inh = (((dSdoCapital + dCapTrasNoVen - dCapTrasVen_Amort) * dTasaInter) / (iDiasCalc * 100)) * iDiasInt_inh;
               LET dSdoInt_inh  = dSdoInt_inh + dSdoInt + dIntDiario_inh;
            END IF;

                  --Actualizacion de los int diarios en maestro de saldos (sd_maesdoscrd)
                  LET dSdodiaantint = dSdoInt;
                  LET dSdoInt       = dSdoInt + dIntDiario;
                  --Actualizacion de los int diarios en sd_amortiza_creditocrd
                  UPDATE "informix".sd_amortiza_creditocrd
                     SET interes_debe = interes_debe + dIntDiario
                   WHERE empresa        = cEmpresa
                     AND num_credito    = cNumCredito
                     AND capital_status = "3";

                  --Se actualiza la fecha del proximo proceso
                  UPDATE "informix".sd_maecredanexocrd
                     SET fecha_proceso  = dtFechaProx
                   WHERE num_credito    = cNumCredito
                     AND empresa        = cEmpresa;

-- *******************************************************
--  IDENTIFICACION DE PROCESOS POR REALIZAR              *
-- *******************************************************
          -- Validacion para identificar un (Cierre de Mes).
          IF dtFechaHoy = dtFechaFinMes THEN
            LET cIdProc1 = "C";
          END IF;
          -- Validaciones para dias inhabiles y cambios de mes. (Facturacion)
          IF dtFechaHoyAux = dtFechaMesiversario THEN
                LET cIdProc2 = "F";
                if ( iTpDiasFechaPago = 2 ) then
                    if ( iDiaCorte <= 15) then
                        SELECT  sdodiafac
                          INTO iDiaCorte
                          FROM "informix".sd_diafactura
                         WHERE empresa = cEmpresa
                           AND num_producto = cNumProducto
                           AND perdiafac = iDiaCorte
                           AND tipo_pago = iTpDiasFechaPago
                           AND fac_especial = 'N';
                    else
                        SELECT  perdiafac
                          INTO iDiaCorte
                          FROM "informix".sd_diafactura
                         WHERE empresa = cEmpresa
                           AND num_producto = cNumProducto
                           AND sdodiafac = iDiaCorte
                           AND tipo_pago = iTpDiasFechaPago
                           AND fac_especial = 'S';
                    end if;
                 end if;
                call "informix".calculamesiversario(iDiaCorte::INTEGER, dtFechaMesiversario, 1, iTpDiasFechaPago)
                     RETURNING cCodRet, dtFechaProxCuota;
          END IF;

          -- Validaciones para identificar un (Mesiversario)
          IF dtFechaHoy = dtFechaMesiversario THEN
             LET cIdProc3 = "M";
                if ( iTpDiasFechaPago = 2 ) then
                    if ( iDiaCorte <= 15) then
                        SELECT  sdodiafac
                          INTO iDiaCorte
                          FROM "informix".sd_diafactura
                         WHERE empresa = cEmpresa
                           AND num_producto = cNumProducto
                           AND perdiafac = iDiaCorte
                           AND tipo_pago = iTpDiasFechaPago
                           AND fac_especial = 'N';
                    else
                        SELECT  perdiafac
                          INTO iDiaCorte
                          FROM "informix".sd_diafactura
                         WHERE empresa = cEmpresa
                           AND num_producto = cNumProducto
                           AND sdodiafac = iDiaCorte
                           AND tipo_pago = iTpDiasFechaPago
                           AND fac_especial = 'S';
                    end if;
                 end if;
                call "informix".calculamesiversario(iDiaCorte::INTEGER, dtFechaMesiversario, 1, iTpDiasFechaPago)
                     RETURNING cCodRet, dtFechaProxCuota;
          END IF;

-- *******************************************************
--  Calculo de Iva de Interes                            *
-- *******************************************************
 SELECT a.iva, a.plaza
   INTO dIvaSuc, cPlaza
   FROM tmp_sucursales_pp a
  WHERE empresa  = cEmpresa
    AND sucursal = cSucursal;
--********************************************************************
-- PROVISION ESPECIAL PARA PRESTAMOS CON MESIVERSARIO DIA 1o. DE MES
--********************************************************************
IF cIdProc1 = "C" AND cIdProc4 = "P" and (dSdoCapital + dCapTrasNoVen) > 0 THEN

           SELECT a.fecha_cuota,
                --  a.iva_pagado,
                  a.iva_fecha_pago,
                  NVL(a.capital_mto_cuota,0),
                  NVL(num_pago,1)
             INTO dtFechaCuota,
                 -- dIvaPag,
                  dtIvaFechaPag,
                  dCapMtoCuota,
                  iNumPago
             FROM "informix".sd_amortiza_creditocrd a
            WHERE a.empresa        = cEmpresa
              AND a.num_credito    = cNumCredito
              AND a.capital_status = "3";

               IF dtFechaCuota IS NOT NULL THEN
                   LET dtFechaCuotaAnt = dtFechaCuota;
               END IF;

-- LET dSdoInt = dSdoInt + dIntDiario;
 LET dProvInt_inh = dSdoInt_inh;

  CALL "informix".calc_iva_grav_pp(cEmpresa,cNumCredito,dTasaInter,dIvaSuc,dtFechaHoy+1,
                                  dtIvaFechaPag,dtFechaApert,dtFechaCuota,dSdoInt_inh)
  RETURNING cCodRet,dIvaIntReal_inh,cMensajeRet;

  IF cCodRet <> "000000" THEN
        LET cCodRet      = "000005";
        LET cMensajeRet  = "Ocurrio un error al realizar calculo de iva de interes";
        IF cBegin = "S" THEN
           ROLLBACK WORK;
        END IF;
     RETURN cCodRet,cMensajeRet;
  END IF;

               IF dIntProvFinMes is null THEN LET dIntProvFinMes=0; END IF;
               IF dIvaProvFinMes is null THEN LET dIvaProvFinMes=0; END IF;

       LET dProvIva_inh = dIvaIntReal_inh; -- dIvaProvFinMes;

       IF  cStatusCred='BT' THEN
            LET CodigoRefProvIva    = 9;   
            LET CodigoRefProvInt    = 8;   
       ELSE
            LET CodigoRefProvIva    = 7;
            LET CodigoRefProvInt    = 6;
       END IF;

        IF dProvInt_inh > 0 THEN              
                LET dProvInt = dProvInt - dIntProvFinMes;

				CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto ,CodigoRefProvInt,
				                          "606",  dtFechaHoy , dProvInt_inh, cFolio,
										  cSucursal, cDivisa, "0000",'PROV','')
				RETURNING cCodRet,cMensajeRet;

                IF (cCodRet <> "000000") THEN
                       LET cCodRet      = cCodRet;
                       LET cMensajeRet = "Ocurrio un error al registrar la provisiÃÂÃÂÃÂÃÂ³n de interes";
                       IF cBegin = "S" THEN
                          ROLLBACK WORK;
                       END IF;
                       RETURN cCodRet,cMensajeRet;
                END IF;

            --LET dProvIva_inh = dProvIva_inh - dIvaProvFinMes; FMV 19mar13 NO SE DESCUENTA PROVISION FIN DE MES y PROVISIONA IVA
                IF dProvIva_inh > 0 THEN

						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , CodigoRefProvIva,
				                          "606", dtFechaHoy , dProvIva_inh, cFolio,
										  cSucursal, cDivisa, "0000",'PROV','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar la provisiÃÂÃÂÃÂÃÂ³n de iva de interes";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
                END IF;
---ini cas, Se agrega el movimiento aplicativo de interes gravable y exento
---SE AGREGA VALIDACION PARA NO GENERAR INTERES EXENTO NI GRAVABLE PARA CREDISOLUCIONES
			IF cNumProducto <> '6900' THEN
                IF dProvInt_inh>0 and dProvIva_inh<=0 then
                    LET dIntGrav_inh = dProvInt_inh;
                    LET dIntExen_inh = 0;
                ELSE
                    LET dIntGrav_inh = dProvIva_inh/dIvaSuc;
                    IF dIntGrav_inh>dProvInt_inh THEN LET dIntGrav_inh=dProvInt_inh; END IF;
                    LET dIntExen_inh = dProvInt_inh-dIntGrav_inh;
                END IF;

                IF dIntGrav_inh>0 THEN
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 12,
				                          "606", case when cIdProc1 = "C" and cIdProc2 = "F" and cIdProc4 = "P"
                                           then dtFechaHoy end, dIntGrav_inh, cFolio,
										  cSucursal, cDivisa, "0000",'GRAV','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar el InterÃÂÃÂÃÂÃÂ©s Gravado";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
                END IF;
                IF dIntExen_inh>0 THEN
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 13,
				                          "606", case when cIdProc1 = "C" and cIdProc2 = "F" and cIdProc4 = "P"
                                           then dtFechaHoy end, dIntExen_inh, cFolio,
										  cSucursal, cDivisa, "0000",'EXEN','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar el InterÃÂÃÂÃÂÃÂ©s Exento";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
                END IF;
			END IF;
---fin cas, Se agrega el movimiento aplicativo de interes gravable y exento
        END IF;
END IF;
--*************************************************************************
--   FIN DE PROVISION POR REGISTROS DE MOVTO EN FIN MES
--*************************************************************************
-- *******************************************************
--  PROVISION                                            *
-- *******************************************************
IF cIdProc1 = "C" OR cIdProc2 = "F" and (dSdoCapital + dCapTrasNoVen) > 0 THEN

           SELECT a.fecha_cuota, --  a.iva_pagado,
                  a.iva_fecha_pago,
                  NVL(a.capital_mto_cuota,0),NVL(num_pago,1)
             INTO dtFechaCuota,-- dIvaPag,
                  dtIvaFechaPag,
                  dCapMtoCuota,iNumPago
             FROM "informix".sd_amortiza_creditocrd a
            WHERE a.empresa        = cEmpresa
              AND a.num_credito    = cNumCredito
              AND a.capital_status = "3";

               IF dtFechaCuota IS NOT NULL THEN
                   LET dtFechaCuotaAnt = dtFechaCuota;
               END IF;

-- LET dSdoInt = dSdoInt + dIntDiario;
 LET dProvInt = dSdoInt;

  CALL "informix".calc_iva_grav_pp(cEmpresa,cNumCredito,dTasaInter,dIvaSuc,dtFechaHoy+1,
                                  dtIvaFechaPag,dtFechaApert,dtFechaCuota,dSdoInt)
  RETURNING cCodRet,dIvaIntReal,cMensajeRet;

  IF cCodRet <> "000000" THEN
        LET cCodRet      = "000005";
        LET cMensajeRet  = "Ocurrio un error al realizar calculo de iva de interes";
        IF cBegin = "S" THEN
           ROLLBACK WORK;
        END IF;
     RETURN cCodRet,cMensajeRet;
  END IF;

               IF dIntProvFinMes is null THEN LET dIntProvFinMes=0; END IF;
               IF dIvaProvFinMes is null THEN LET dIvaProvFinMes=0; END IF;

       LET dProvIva = dIvaIntReal; -- dIvaProvFinMes;

       IF  cStatusCred='BT' THEN
            LET CodigoRefProvIva    = 9;   --FMV 6ene11: Se cambian codigos 8 x 9 para Vencido
            LET CodigoRefProvInt    = 8;   --FMV 6ene11: Se cambian codigos 9 x 8 para Vencido
       ELSE
            LET CodigoRefProvIva    = 7;
            LET CodigoRefProvInt    = 6;
       END IF;

        IF dProvInt > 0 THEN  
                IF cIdProc4 = '' THEN
                   LET dProvInt = dProvInt - dIntProvFinMes;
                ELSE
                   --LET dProvInt = dProvInt - dIntProvFinMes - dProvInt_inh;
				   LET dProvInt = dProvInt  - dProvInt_inh;
                END IF;
		END IF;
        IF dProvInt > 0 THEN    

				CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto ,CodigoRefProvInt,
				                          "606", dtFechaHoy ,dProvInt, cFolio,
										  cSucursal, cDivisa, "0000",'PROV','')
				RETURNING cCodRet,cMensajeRet;

                IF (cCodRet <> "000000") THEN
                       LET cCodRet      = cCodRet;
                       LET cMensajeRet = "Ocurrio un error al registrar la provisiÃÂÃÂÃÂÃÂ³n de interes";
                       IF cBegin = "S" THEN
                          ROLLBACK WORK;
                       END IF;
                       RETURN cCodRet,cMensajeRet;
                END IF;
                              
                IF cIdProc4 = '' THEN
                   LET dProvIva = dProvIva - dIvaProvFinMes;
                ELSE
                   --LET dProvIva = dProvIva - dIvaProvFinMes - dProvIva_inh;
                   LET dProvIva = dProvIva - dProvIva_inh;
                END IF;
  
                IF dProvIva > 0 THEN
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , CodigoRefProvIva,
				                          "606", dtFechaHoy , dProvIva, cFolio,
										  cSucursal, cDivisa, "0000",'PROV','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar la provisiÃÂÃÂÃÂÃÂ³n de iva de interes";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
                END IF;
---ini cas, Se agrega el movimiento aplicativo de interes gravable y exento
---SE AGREGA VALIDACION PARA NO GENERAR INTERES EXENTO NI GRAVABLE PARA CREDISOLUCIONES
			IF cNumProducto <> '6900' THEN
                IF dProvInt>0 and dProvIva<=0 then
                    LET dIntGrav = dProvInt;
                    LET dIntExen = 0;
                ELSE
                    LET dIntGrav = dProvIva/dIvaSuc;
                    IF dIntGrav>dProvInt THEN LET dIntGrav=dProvInt; END IF;
                    LET dIntExen = dProvInt-dIntGrav;
                END IF;

                IF dIntGrav>0 THEN
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 12,
				                          "606",  dtFechaHoy  , dIntGrav, cFolio,
										  cSucursal, cDivisa, "0000",'GRAV','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar el InterÃÂÃÂÃÂÃÂ©s Gravado";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
                END IF;
                IF dIntExen>0 THEN
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 13,
				                          "606", dtFechaHoy, dIntExen, cFolio,
										  cSucursal, cDivisa, "0000",'EXEN','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar el InterÃÂÃÂÃÂÃÂ©s Exento";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
                END IF;
			END IF;
---fin cas, Se agrega el movimiento aplicativo de int gravable y exento
        END IF;
END IF;

-- *******************************************************
-- FACTURACION                                           *
-- *******************************************************

--FMV 31-ENE-11
IF cIdProc2 = "F" AND (dSdoCapital + dCapTrasNoVen) > 0 THEN
        LET iNumPago = iNumPago + 1 ;
        
      select nvl((interes_debe - interes_pagado),0),
				nvl((iva_debe - iva_pagado),0) + nvl(dIvaIntReal,0)
		  into  vlIntVenBal, vlIvaIntVenBal
		  from bdicred:sd_amortiza_creditocrd 
		  where empresa = cEmpresa 
			and num_credito = cNumCredito 
			and capital_status = '3';	 
        
		IF (dSdoCapital + dCapTrasNoVen - (dCapMtoCuota - vlIntVenBal - vlIvaIntVenBal)) <= 0  and (dSdoCapital + dCapTrasNoVen) > 0 THEN
		
		LET dCapMtoCuota = dSdoCapital + dCapTrasNoVen + vlIntVenBal + vlIvaIntVenBal;
		--	LET dCapMtoCuota = dSdoCapital + dCapTrasNoVen + dProvInt + dProvIva + dIntProvFinMes + dIvaProvFinMes;
			UPDATE "informix".sd_amortiza_creditocrd
			   SET capital_mto_cuota   = dCapMtoCuota
			 WHERE empresa             = cEmpresa
			   AND num_credito         = cNumCredito
			   AND capital_status      = "3";
		END IF;

        LET dMontofinanciado = dMontofinanciado + dCapMtoCuota - vlIntVenBal - vlIvaIntVenBal;
        --LET dMontofinanciado = dMontofinanciado + dCapMtoCuota - dProvInt - dProvIva - dIntProvFinMes - dIvaProvFinMes - dProvInt_inh - dProvIva_inh;
        LET dSdotrab4 = dSdotrab4  + dCapMtoCuota - vlIntVenBal - vlIvaIntVenBal;
        --LET dSdotrab4 = dSdotrab4  + dCapMtoCuota - dProvInt - dProvIva- dIntProvFinMes - dIvaProvFinMes - dProvInt_inh - dProvIva_inh;
        LET dSdomesantint = vlIntVenBal; --dSdoInt;
        LET dSdoNoExig = dSdoNoExig +  vlIntVenBal; --dSdoInt;
        LET dSdoInt = 0;
        LET dIvaIntVigente = dIvaIntVigente + dIvaIntReal;

        IF cIdProc2 = "F" THEN LET dIntProvFinMes=0; LET dIvaProvFinMes=0; END IF;
        LET vlIntVenBal = vlIntVenBal;
        LET vlIvaIntVenBal = vlIvaIntVenBal;
        LET dIvaIntReal = dIvaIntReal;

		UPDATE "informix".sd_amortiza_creditocrd
		   SET capital_debe        = capital_mto_cuota - vlIntVenBal - vlIvaIntVenBal,
			   iva_debe            = iva_debe + dIvaIntReal,
			   capital_status      = "1",
			   capital_status_ant  = "3"
		 WHERE empresa             = cEmpresa
		   AND num_credito         = cNumCredito
		   AND capital_status      = "3";


		select  capital_debe
		  into vlCapitalDebe
		  from "informix".sd_amortiza_creditocrd
		 WHERE empresa             = cEmpresa
		   AND num_credito         = cNumCredito
		   AND capital_status      = "1";

		if vlCapitalDebe is null then let vlCapitalDebe = 0; end if;

		select interes_debe,
			   iva_debe
		  into dIntPeriodo,
			   dIvaPeriodo
		  from "informix".sd_amortiza_creditocrd
		 where empresa             = cEmpresa
		   AND num_credito         = cNumCredito
		   AND capital_status      = "1";

	    IF dIntPeriodo IS NULL THEN LET dIntPeriodo=0; END IF;
	    IF dIvaPeriodo IS NULL THEN LET dIvaPeriodo=0; END IF;

		IF dIntPeriodo>0 THEN
				CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 43,
								  "222", case when cIdProc1 = "C" and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, dIntPeriodo, cFolio,
								  cSucursal, cDivisa, "0000",'INT','')
				RETURNING cCodRet,cMensajeRet;
				IF (cCodRet <> "000000") THEN
					   LET cCodRet      = "000007";
					   LET cMensajeRet = "Ocurrio un error al registrar el Interes del Periodo";
					   IF cBegin = "S" THEN
						  ROLLBACK WORK;
					   END IF;
					   RETURN cCodRet,cMensajeRet;
				END IF;
		END IF;

		IF dIvaPeriodo>0 THEN
				CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 44,
								  "222", case when cIdProc1 = "C" and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, dIvaPeriodo, cFolio,
								  cSucursal, cDivisa, "0000",'INT','')
				RETURNING cCodRet,cMensajeRet;
				IF (cCodRet <> "000000") THEN
					   LET cCodRet      = "000007";
					   LET cMensajeRet = "Ocurrio un error al registrar el InterÃÂÃÂÃÂÃÂ©s Periodo";
					   IF cBegin = "S" THEN
						  ROLLBACK WORK;
					   END IF;
					   RETURN cCodRet,cMensajeRet;
				END IF;
		END IF;
      -- LET vlCapitalDebe = dCapMtoCuota - (interes_debe - interes_pagado) - (dIvaIntReal);
	  --FNV: 31-ENE-2011
		 --IF (dSdoCapital + dCapTrasNoVen - dCapMtoCuota) > 0 THEN
		IF (dSdoCapital + dCapTrasNoVen - vlCapitalDebe) > 0 THEN
	  -- IF (dSdoCapital - dCapMtoCuota) >  0 THEN
			   INSERT INTO "informix".sd_amortiza_creditocrd
						(
							empresa, 		    num_credito, 		fecha_cuota, 		tipo_cuota,
							capital_mto_cuota, 	capital_debe,		capital_pagado, 	capital_status,
							capital_status_ant, capital_fecha_pago,	interes_debe, 		interes_pagado,
							interes_status, 	interes_status_ant,	interes_fecha_pago, iva_debe,
							iva_pagado, 		iva_status,			iva_status_ant, 	iva_fecha_pago,
							mora_provi_ordi, 	mora_provi_cope,	mora_sdo_ordi, 		mora_sdo_ordi_pag,
							mora_sdo_cope, 		mora_sdo_cope_pag,	mora_bonificado, 	mora_status,
							mora_iva_debe, 		mora_iva_pagado,	mora_iva_status, 	mora_iva_fecha_pago,
							num_pago, 		    campo_trabajo1,		campo_trabajo2, 	campo_trabajo3,
							campo_trabajo4
						)
					VALUES
						(   cEmpresa,		    cNumCredito,	dtFechaProxCuota,	"3",
							dCapMtoCuota,        0,				0,			        "3",
							"3",         		"",				0,			         0,
							"1",                "1",			NULL,			     0,
							0,			        "1",			"1",                 "",
							0,			         0,				0,			         0,
							0,			         0,				0,			         "1",
							0,			          0,			"1",			     "",
							iNumPago,		      0,			0,			         "",
							""
						);
	   END IF;
END IF;

-- *******************************************************
-- TRASPASOS                                             *
-- *******************************************************
    -- Traspaso de Vigente a Vencido Transitorio.
 IF  cIdProc3 = "M"  THEN

               SELECT NVL(a.capital_debe - a.capital_pagado,0),NVL(a.interes_debe - a.interes_pagado,0)
                 INTO dTraspCap,dTraspInt
                 FROM "informix".sd_amortiza_creditocrd a
                WHERE a.empresa        = cEmpresa
                  AND a.num_credito    = cNumCredito
                  AND a.capital_status = "1";

					IF dTraspCap IS NULL THEN LET dTraspCap=0; END IF;
					IF dTraspInt IS NULL THEN LET dTraspInt=0; END IF;
----Realiza traspasos a transitorio
        IF cStatusCred IN ('AA','BA') AND cNumProducto <> '6900' THEN
			IF dTraspCap>0 THEN

               LET dMntVencido = dMntVencido + dTraspCap;
               LET dSdoCapital = dSdoCapital - dTraspCap;

                UPDATE "informix".sd_amortiza_creditocrd
                   SET capital_status = "7",
                       capital_status_ant  = "1",
                       campo_trabajo3 = ''
                 WHERE empresa        = cEmpresa
                   AND num_credito    = cNumCredito
                   AND capital_status = "1";

						IF cStatusCred='AA' THEN
							  --Se actualiza la fecha de vencimiento
							  UPDATE "informix".sd_maecredanexocrd
								 SET fecha_vencto  = dtFechaHoy
							   WHERE num_credito    = cNumCredito
								 AND empresa        = cEmpresa;

							 --FMV 25Abr13: Actualiza indicador del 1er. vencido y dias de atraso
							  UPDATE "informix".sd_indicador_cred_crd
								 SET fecha_vencido =  DECODE (nvl(fecha_vencido,date(1)) ,date(1), dtFechaHoy, fecha_vencido)
							   WHERE num_credito   = cNumCredito
								 AND empresa       = cEmpresa;
						END IF;

                  -- Traspaso capital vigente a transitorio.
					  CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 3,
							  "026", dtFechaHoy, dTraspCap, cFolio,
							  cSucursal, cDivisa, "0000",'TCVAT','')
					  RETURNING cCodRet,cMensajeRet;
						IF (cCodRet <> "000000") THEN
							   LET cCodRet      = cCodRet;
							   LET cMensajeRet = "Ocurrio un error al registrar traspaso capital vigente a transitorio";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						 END IF;
					    IF dTraspInt > 0 THEN
						  -- Traspaso interes vigente a transitorio.
						  CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 6,
								  "026", dtFechaHoy, dTraspInt, cFolio,
								  cSucursal, cDivisa, "0000",'TCVAT','')
						  RETURNING cCodRet,cMensajeRet;
							IF (cCodRet <> "000000") THEN
								   LET cCodRet      = cCodRet;
								   LET cMensajeRet = "Ocurrio un error al registrar traspaso capital vigente a transitorio";
								   IF cBegin = "S" THEN
									  ROLLBACK WORK;
								   END IF;
								   RETURN cCodRet,cMensajeRet;
							 END IF;
					    END IF; -- IF dTraspInt > 0 THEN
            END IF; --IF dTraspCap>0 THEN
		END IF; --IF cStatusCred IN ('AA','BA') AND cNumProducto <> '6900' THEN

        --ELSE
			IF cIdProc3 = "M" AND cStatusCred='BT' THEN
                LET dMntVencTras = dMntVencTras + dTraspCap;
                LET dCapTrasNoVen = dCapTrasNoVen - dTraspCap;
                LET dIntVdo = dIntVdo + dSdoNoExig;
                LET dIvaIntVencido = dIvaIntVencido + dIvaIntVigente;
                LET dIvaIntVigente=0;

                UPDATE "informix".sd_amortiza_creditocrd
                   SET capital_status = "2",
                       capital_status_ant  = "1",
                       campo_trabajo3 ='V'
                 WHERE empresa        = cEmpresa
                   AND num_credito    = cNumCredito
                   AND capital_status = "1";

                   LET dSdoNoExig = 0;

                  -- Traspaso capital vencido no exigible a vencido exigible.
                IF dTraspCap > 0 THEN --FMV 25Mar13: Se omite generar movimiento en 0, cuando ya termino devengamiento
                    CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 2,
                           "026", dtFechaHoy, dTraspCap, cFolio,
                           cSucursal, cDivisa, "0000",'TCVNEAVE','')
                        RETURNING cCodRet,cMensajeRet;

                    IF (cCodRet <> "000000") THEN
                           LET cCodRet      = "000014";
                           LET cMensajeRet = "Ocurrio un error al registrar traspaso capital vencido no exigible a vencido exigible";
							IF cBegin = "S" THEN
                              ROLLBACK WORK;
                            END IF;
                           RETURN cCodRet,cMensajeRet;
                    END IF;
                END IF;  --dTraspCap > 0 THEN  FMV 25Mar13:
			END IF; --IF cIdProc3 = "M" AND cStatusCred='BT' THEN


                UPDATE "informix".sd_maecredanexocrd
                   SET prox_fecha_pago = dtFechaProxCuota,
                       dia_corte       = iDiaCorte
                  WHERE num_credito     = cNumCredito
                    AND empresa         = cEmpresa;

                    IF (cStatusCredIndica = "AA" and dTraspCap>0 and cNumProducto <> '6900') then
                        let cStatusCredIndica = 'BA';
                    END IF;

                UPDATE "informix".sd_maecredcrd
                   SET status_cred = (CASE WHEN cStatusCred = "AA" and dTraspCap>0 and cNumProducto <> '6900' THEN "BA" ELSE status_cred END),
                       fecha_pago_cap = dtFechaProxCuota,
                       fecha_pago_int = dtFechaProxCuota
                 WHERE num_credito = cNumCredito
                   AND empresa     = cEmpresa;
---Ini cas ValidaciÃÂÃÂÃÂÃÂ³n solicitada por operaciones para que no cobre el int devengado
---de un dia cuando la reestructura llega a su ultima mensualidad
                    IF dCapTrasNoVen = 0 AND dSdoCapital = 0 AND dSdoInt > 0 THEN
                       LET dSdoInt = 0;
                    END IF;
---Fin cas Validacion solicitada por operaciones
END IF;

------Realiza traspasos a vencido
-- FMV 9jul2013: Traspaso a Vencido aquellos prestamos que llegan a la ultima cuota y pasan los 90 dias vencidos
-- JOM 11/04/2013 Se cambia traspado a periodos INI
-- Se realiza el traspado en la mensualidad 4 para considerar 90 o mas dias en transitorio            
           SELECT COUNT(a.num_credito), nvl(min(fecha_cuota), date(1))
             INTO iNumVdos, dFechacuotamin
             FROM "informix".sd_amortiza_creditocrd a
            WHERE a.empresa        = cEmpresa
              AND a.num_credito    = cNumCredito
              AND a.capital_status IN ("2","7");
            
            IF day(dtFechaHoy) >= iDiaCorte  then 
                LET iNumVdosaux = months_between(dtFechaHoy ,dFechacuotamin ) + 1;  
            ELSE 
                LET iNumVdosaux = months_between(dtFechaHoy ,dFechacuotamin );
            END IF;

            IF (cStatusCred='BA' AND iNumVdos >= 4) or (cStatusCred='BA' and iNumVdos < iNumVdosaux and iNumVdosaux >= 4 and dFechacuotamin <> date(1)) 
--            IF cStatusCred='BA' AND (dtFechaVencto + vi_dias_trasp_cap <= dtFechaHoy) --OR vf_fecha_vencim < dtFechaHoy
-- JOM 11/04/2013 Se cambia traspado a periodos FIN
				  THEN
						LET dCapTrasNoVen = dCapTrasNoVen + dSdoCapital;
						LET dMntVencTras = dMntVencTras + dMntVencido;
						LET dIntVdo = dIntVdo + dSdoNoExig;
						LET dIvaIntVencido = dIvaIntVencido + dIvaIntVigente;

						UPDATE "informix".sd_maecredcrd
						   SET status_cred = "BT"
						 WHERE num_credito = cNumCredito
						   AND empresa     = cEmpresa;

						UPDATE "informix".sd_amortiza_creditocrd
						   SET capital_status = "2",
							   capital_status_ant  = "7"
						 WHERE empresa        = cEmpresa
						   AND num_credito    = cNumCredito
						   AND capital_status = "7";

                  -- Traspaso capital vigente a vdo no exigible.
					IF dCapTrasNoVen > 0 THEN
					  CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 4,
							  "026", dtFechaHoy, dSdoCapital, cFolio,
							  cSucursal, cDivisa, "0000",'TCVAVNE','')
					  RETURNING cCodRet,cMensajeRet;

						IF (cCodRet <> "000000") THEN
							   LET cCodRet      = "000010";
							   LET cMensajeRet = "Ocurrio un error al registrar traspaso capital vigente a vdo no exigible";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						END IF;
					END IF; -- IF dCapTrasNoVen > 0 THEN

					  -- Traspaso capital transitorio a exigible.
					IF dMntVencTras  > 0 THEN
					  CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 1,
							  "026", dtFechaHoy, dMntVencido, cFolio,
							  cSucursal, cDivisa, "0000",'TCTAE','')
					  RETURNING cCodRet,cMensajeRet;

						IF (cCodRet <> "000000") THEN
							   LET cCodRet      = "000011";
							   LET cMensajeRet = "Ocurrio un error al registrar traspaso capital transitorio a exigible";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						END IF;
					END IF; -- IF dMntVencTras  > 0

					  -- Traspaso interes vigente a vdo.
					IF dIntVdo > 0 THEN
					  CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 5,
							  "026", dtFechaHoy, dSdoNoExig, cFolio,
							  cSucursal, cDivisa, "0000",'TIVAV','')
					  RETURNING cCodRet,cMensajeRet;

						IF (cCodRet <> "000000") THEN
							   LET cCodRet      = "000012";
							   LET cMensajeRet = "Ocurrio un error al registrar traspaso interes vigente a vdo";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						END IF;
					END IF; --IF dIntVdo > 0

						LET dSdoCapital = 0;
						LET dMntVencido = 0;
						LET dIvaIntVigente = 0;
						LET dSdoNoExig = 0;
            END IF; --  cStatusCred='BA' AND (dtFechaVencto + vi_dias_trasp_cap <= dtFechaHoy) OR vf_fecha_vencim < dtFechaHoy


-- *******************************************************
-- CALCULO DE INTERES MORATORIO                          *
-- *******************************************************
    LET dTasaInterMorCop = dTasaInterMor - dTasaInter;
--IPCB	
	IF dTasaInterMorCop < 0 THEN
		LET dTasaInterMorCop = 0;
	END IF;
	
FOREACH
     SELECT a.fecha_cuota,
            SUM(NVL(a.capital_debe,0) - NVL(a.capital_pagado,0))
       INTO dtFechaCuota,
            dSdoMora
       FROM "informix".sd_amortiza_creditocrd a
      WHERE a.empresa        = cEmpresa
        AND a.num_credito    = cNumCredito
        AND a.capital_status IN ("2","7")
   GROUP BY 1

     IF NVL(dSdoMora,0) > 0 THEN
          --Se calcula el interes moratorio
          LET dIntMora = (dSdoMora * dTasaInter / (iDiasCalc * 100)) * iDiasInt;

          --Se calculan el interes moratorio copete
          LET dIntCope = (dSdoMora * dTasaInterMorCop / (iDiasCalc * 100)) * iDiasInt;

          -- se actualizan los intereses moratorios en la amortizacrd
          UPDATE "informix".sd_amortiza_creditocrd
             SET mora_sdo_ordi = mora_sdo_ordi + dIntMora,
                 mora_sdo_cope = mora_sdo_cope + dIntCope
           WHERE empresa     = cEmpresa
             AND num_credito = cNumCredito
             AND fecha_cuota = dtFechaCuota;

             LET dSdomoratorio = dSdomoratorio + dIntCope;
             LET dSdocontabmora = dSdocontabmora + dIntMora;
     END IF;
END FOREACH;

   SELECT COUNT(*), min(fecha_cuota) 
     INTO iNumVdos,iFechaVencto
     FROM "informix".sd_amortiza_creditocrd a
    WHERE a.empresa        = cEmpresa
      AND a.num_credito    = cNumCredito
      AND a.capital_status IN ("2","7");

   IF iNumVdos IS NULL THEN
      LET iNumVdos = 0;
   END IF;

    UPDATE sd_maesdoscrd
    SET fecha_ult_mov = dtFechaHoy,
        sdo_int_anticip = 0,
        sdo_int_ant_dev = 0,
        sdo_intereses = dSdoInt,
        sdo_dia_ant_int = dSdodiaantint,
        sdo_mes_ant_int = dSdomesantint,
        sdo_acum_mes_int = (CASE WHEN cIdProc2 = "F" THEN 0 ELSE dSdoInt END),
        sdo_retenido = 0,
        sdo_acum_cap_int = 0,
        sdo_exig_int = 0,
        sdo_no_exig = dSdoNoExig,
        provision_normal = (CASE WHEN cIdProc1 = "C" THEN (provision_normal + dSdoInt) ELSE dIntProvFinMes END),
        dias_acum_int = (CASE WHEN cIdProc2 = "F" THEN 0 ELSE (dias_acum_int + iDiasInt) END),
        sdo_dia_ant_mor = (sdo_moratorio + sdo_contab_mora),
        sdo_mes_ant_mor= (CASE WHEN cIdProc3 = "F" THEN sdo_dia_ant_mor ELSE sdo_mes_ant_mor END),
        sdo_moratorio = dSdomoratorio,
        sdo_contab_mora = dSdocontabmora,
        dias_acum_mora = (CASE WHEN (dSdomoratorio + dSdocontabmora) > 0 THEN (dias_acum_mora + iDiasInt) ELSE dias_acum_mora END),
        sdo_dia_ant_cap = sdo_cap_insoluto,
        sdo_mes_ant_cap = 0,
        sdo_acum_mes_cap = 0,
        sdo_capital = dSdoCapital,
        sdo_cap_insoluto = dSdoCapInso,
        --mto_capitalizado = 0,
        mto_ministra_cap = 0,
        dias_acum_cap = (dias_acum_cap + iDiasInt),
        monto_vencido = dMntVencido,
        mto_venc_trasp = dMntVencTras,
        monto_financiado = dMontofinanciado,
        sdo_global_int = (CASE WHEN cIdProc1 = "C" THEN (sdo_global_int + dProvIva) ELSE dIvaProvFinMes END),
        cap_tras_no_venci = dCapTrasNoVen,
        mto_venc_int = dIvaIntVencido,
        mto_finan_vdo = dIvaIntVigente,
        int_tra_no_exig = dIntVdo,
        sdo_trab4 = dSdotrab4,
        mto_fin_ven_trasp = iNumVdos
    WHERE  empresa = cEmpresa
      AND  num_credito = cNumCredito;

-- *******************************************************
-- RESPALDO DE INFORMACION CONTABILIDAD A FIN DE MES     *
-- *******************************************************

     IF cIdProc1 = "C" THEN

           INSERT INTO "informix".sd_maesdoscontcrd
                SELECT dtFechaHoy, *
                  FROM informix.sd_maesdoscrd
                 WHERE num_credito = cNumCredito
                   AND empresa     = cEmpresa;

           INSERT INTO "informix".sd_maecredcontcrd
                SELECT dtFechaHoy, *
                  FROM informix.sd_maecredcrd
                 WHERE num_credito = cNumCredito
                   AND empresa     = cEmpresa;

             LET iContCierre = iContCierre + 1;

             IF (iContCierre = 80000) THEN
                LET iContCierre = 0;
                UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_maesdoscontcrd;
                UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_maecredcontcrd;
             END IF;
     END IF;
-- *******************************************************
-- GENERAR HISTORICO DE SALDOS                           *
-- *******************************************************
    IF cIdProc3 = "M" OR cIdProc2 = "F" THEN
        INSERT INTO "informix".sd_maesdoshistcrd
             SELECT dtFechaHoy, *
               FROM informix.sd_maesdoscrd
              WHERE num_credito = cNumCredito
                AND empresa     = cEmpresa;

            LET iContCorte = iContCorte + 1;

            IF iContCorte = 30000 THEN
                LET iContCorte = 0;
                UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_movdiacrd;
            END IF;
    END IF;

-- ***********************************
-- GUARDA SALDOS FIN DE DIA          *
-- ***********************************

      select sum(interes_debe - interes_pagado) vencido_balanza,
             sum(iva_debe - iva_pagado) iva_vencido_balanza
        into vlIntVenBal, vlIvaIntVenBal
        from bdicred:sd_amortiza_creditocrd 
        where empresa = cEmpresa
          and num_credito = cNumCredito 
		      and campo_trabajo3 <> 'V'
          and capital_status = '2';
        
      if  vlIntVenBal is null then
         let vlIntVenBal = 0;
         let vlIvaIntVenBal = 0;
      end if;

    CALL sp_actsdodiariocrd(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
                        (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
                              WHEN cIdProc2 = "F" THEN (dSdoNoExig)
                              ELSE (dSdoNoExig + dIntProvFinMes)  END), dIntVdo,
                        (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
                              WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
                              ELSE (dIvaIntVigente + dIvaProvFinMes) END),
                        dIvaIntVencido,vlIntVenBal,vlIvaIntVenBal,dMontofinanciado,dtFechaHoy)
     RETURNING cCodRet;

        IF (cCodRet <> "000") THEN
             LET cCodRet     = "000002";
             LET cMensajeRet = "Error al grabar en tabla saldos diarios";
             RETURN cCodRet, cMensajeRet;
        END IF;

-- ****************************************
-- FIN DEL PROCESO                        *
-- ****************************************
--          LET iContCommit = iContCommit + 1;

--           IF cBegin = "S" AND iContCommit > 2 THEN
               COMMIT WORK;
               LET cBegin = "N";
--               LET iContCommit = 0;
--           END IF;
            --FMV 25abr13: Calcula indicadores para los prestamos por sus dias de atraso en vencidos
            --FMV 17jun13: Ajuste para prestamos q vencen a fin de mes y cambio de estatus vigente
                    IF (dtFechaHoy = dtFechaFinMes)  THEN
                        IF (cStatusCredIndica = 'AA') THEN
                            LET vdias_atraso = 0;
                        ELSE
                            LET vdias_atraso = (dtFechaFinMes - nvl(dtFechaVencto,dtFechaFinMes) + 1);
                        END IF;

                         UPDATE "informix".sd_indicador_cred_crd
                            SET dias_atraso   = vdias_atraso,
                                fecha_ultimo_pago = vf_fecha_ult_pago,
                                fecha_ultimo_pago_h = vf_fecha_ult_pago
                          WHERE empresa = cEmpresa
                            AND num_credito = cNumCredito;
                    END IF; --IF cIdProc1 = "C"
				
-- *******************************************************
-- 	RQM 09 473: TRIAD	                                 *
-- *******************************************************
	LET vSdoTotLiquidar 	= dSdoCapInso + 
	                          (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
                              WHEN cIdProc2 = "F" THEN (dSdoNoExig)
                              ELSE (dSdoNoExig + dIntProvFinMes)  END) + 
							  dIntVdo +
							  (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
                              WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
                              ELSE (dIvaIntVigente + dIvaProvFinMes) END) +
							  dIvaIntVencido +
							  ((dSdomoratorio+dSdocontabmora) *  ( 1 + dIvaSuc));
							  
	LET vPagoMinimo 	    = dMontofinanciado + 
	                          (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
                              WHEN cIdProc2 = "F" THEN (dSdoNoExig)
                              ELSE (dSdoNoExig + dIntProvFinMes)  END) + 
							  dIntVdo +
							  (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
                              WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
                              ELSE (dIvaIntVigente + dIvaProvFinMes) END) +
							  dIvaIntVencido +
							  ((dSdomoratorio+dSdocontabmora) *  ( 1 + dIvaSuc));
							  
							  
	LET vSdoTotVencido 		=  dMntVencido + dMntVencTras +
	                          (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
                              WHEN cIdProc2 = "F" THEN (dSdoNoExig)
                              ELSE (dSdoNoExig + dIntProvFinMes)  END) + 
							  dIntVdo +
							  (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
                              WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
                              ELSE (dIvaIntVigente + dIvaProvFinMes) END) +
							  dIvaIntVencido +
							  ((dSdomoratorio+dSdocontabmora) *  ( 1 + dIvaSuc));
	 
	-- Actualizacion DIARIA.
	UPDATE "informix".sd_indicador_cred_crd
		SET sdo_tot_liquidar 	= vSdoTotLiquidar,
			pago_minimo 		= vPagoMinimo,
			sdo_tot_vencido 	= vSdoTotVencido,
			saldo_maximo_hist   = CASE WHEN(vSdoTotLiquidar > nvl(saldo_maximo_hist,0)) THEN vSdoTotLiquidar ELSE nvl(saldo_maximo_hist,0) END
	WHERE 	empresa				= cEmpresa
	AND 	num_credito 		= cNumCredito;

	--Actualizacion al CORTE.
	IF cIdProc3 = "M" THEN 
		UPDATE "informix".sd_indicador_cred_crd
		SET num_vencidos_ch 	= CASE WHEN num_vencidos_ch IS NULL OR num_vencidos_ch = '' THEN iNumVdos ELSE num_vencidos_ch END,
			sdo_tot_liquidar_ch = vSdoTotLiquidar,
			pago_minimo_ch  	= vPagoMinimo,
			intereses_periodo_ch = (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
									WHEN cIdProc2 = "F" THEN (dSdoNoExig)
									ELSE (dSdoNoExig + dIntProvFinMes) END),
			sdo_tot_vencido_ch 	= vSdoTotVencido,
			fecha_primera_mora  = CASE WHEN fecha_primera_mora IS NULL OR fecha_primera_mora = '' THEN iFechaVencto ELSE fecha_primera_mora END,
			fecha_ultima_mora	= CASE WHEN iFechaVencto IS NOT NULL THEN iFechaVencto ELSE fecha_ultima_mora END,
			max_mora_hist       = CASE WHEN iNumVdos > nvl(max_mora_hist,0) THEN iNumVdos ELSE nvl(max_mora_hist,0) END
		WHERE empresa			= cEmpresa
		AND num_credito 		= cNumCredito;
	END IF;	

	--Actualizacion a FIN DE MES.
	IF cIdProc1 = "C" THEN
		UPDATE "informix".sd_indicador_cred_crd 
		SET sdo_tot_liquidar_h = vSdoTotLiquidar,
			pago_minimo_h 	   = vPagoMinimo,
			sdo_tot_vencido_h  = vSdoTotVencido
		WHERE empresa = cEmpresa
		AND num_credito = cNumCredito;
    END IF;
	-- RQM 09 473: TRIAD - FIN	
	
END FOREACH;
--    IF iContCommit > 0 THEN --  COMMIT WORK;--    END IF;

    IF iContCierre > 0 THEN
       UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_maesdoscontcrd;
       UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_maecredcontcrd;
    END IF;

    IF iContCorte > 0 THEN
       UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_movdiacrd;
    END IF;

   LET cCodRet = "000";   LET cMensajeRet = "PROCESO CONCLUIDO";
/*
    UPDATE "informix".sd_contproc
       SET status_proc = "F", 		hora_fin    = CURRENT,
           cod_ret     = cCodRet, 	mensaje     = cMensajeRet
     WHERE empresa     = cEmpresa
       AND proceso     = "CierrePrest"
       AND fecha       = dtFechaHoy;

    UPDATE bdinteg:sx_contproc
       SET status_proc = "F",		hora_fin    = CURRENT,
           codret      = cCodRet
     WHERE empresa     = cEmpresa
       AND proceso     = "CierrePrest"
       AND fecha       = dtFechaHoy;

	   IF cBanTemp = 'S' THEN
	       DROP TABLE tmp_sucursales_pp;
	       LET cBanTemp ='N';
	   END IF;
*/  
 RETURN cCodRet,cMensajeRet;

END;
END PROCEDURE;