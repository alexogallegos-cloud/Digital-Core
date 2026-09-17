CREATE PROCEDURE "informix".sp_clona_upgrademasivo(pEmpresa CHAR(3), pfecha DATE )
RETURNING CHAR(6)    AS codigo_retorno,
          CHAR(150)  AS mensaje_retorno,
		  INTEGER AS exitoso,
		  INTEGER AS noexitoso,
		  INTEGER AS cSdoRetenido;

--DEFINICION DE VARIABLES DE LOS CODIGOS DE ERROR Y EL RETORNO PRINCIPAL
DEFINE iSqlErr       		INTEGER;
DEFINE iIsamErr      		INTEGER;
DEFINE cErrorInfo    		CHAR(80);
DEFINE cCodRet       		CHAR(6);
DEFINE cMensajeRet   		CHAR(150);
DEFINE cExitoso 	 		INTEGER;
DEFINE cNoexitoso    		INTEGER;
DEFINE cSdoRetenido			INTEGER;
-- DEFINICIÓN DE VARIABLES DE PARAMETROS DE ENTRADA Y RETORNOS DEL PROCEDIMIENTO. SP_CLONA_TDC_UPGRADE_SC
DEFINE vCodRet 		 		CHAR(6);
DEFINE vMsjRetorno   		CHAR(150);
DEFINE cEmpresa      		CHAR(3);
DEFINE dtfecha 		 		DATE;
DEFINE cNumTDCUpgrade 		CHAR(20);
DEFINE cNumTDClasica  		CHAR(20);
DEFINE cNumCredito    	 	CHAR(20);
DEFINE cNumcte        	 	CHAR(20); 
DEFINE cNumProdUpgrade 		CHAR(4);
DEFINE cCreditosSdoRet		CHAR(600);
--AAME INC 27 135 Cheque SBC
DEFINE iSdoSBC				INTEGER;
DEFINE cCreditosSdoSBC		CHAR(600);

--INCIALIZACIÓN DE VARIABLES DE LOS CODIGOS DE ERROR Y EL RETORNO PRINCIPAL
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '000000';
LET cMensajeRet   = 'Se realizo la consulta correctamente.';
LET cExitoso 			= 0;
LET cNoexitoso 			= 0;
LET cSdoRetenido		= 0;

-- INICIALIZACION DE VARIABLES DE PARAMETROS DE ENTRADA Y RETORNOS DEL PROCEDIMIENTO. SP_CLONA_TDC_UPGRADE_SC
LET vCodRet       		= '';
LET vMsjRetorno	  		= '';
LET cEmpresa      		= '';
LET dtfecha 			= pfecha;
LET cNumTDCUpgrade 	 	= '';
LET cNumTDClasica    	= '';
LET cNumCredito   	 	= '';
LET cNumcte       	 	= '';
LET cNumProdUpgrade  	= '';
LET cCreditosSdoRet		= '';
--AAME INC 27 135 Cheque SBC
LET iSdoSBC				= 0;
LET cCreditosSdoSBC		= '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet, cExitoso, cNoexitoso, cSdoRetenido;
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_clona_upgrademasivo.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
INTO cEmpresa
FROM bdinteg:si_empresas
WHERE empresa= pEmpresa;

IF TRIM(NVL(cEmpresa,'')) = '' OR TRIM(NVL(dtfecha,''))=''    THEN
  LET cCodRet = '000001';
  LET cMensajeRet = 'El parámetro no es valido';
  RETURN cCodRet, cMensajeRet, cExitoso, cNoexitoso, cSdoRetenido;
END IF;

--EJECUCIÓN DE QUERY 
	--AAME 20191119 INC 27 140 Se contemplan la corrección de todos los créditos upgrades incompletos
	FOREACH		
		SELECT a.numtarjeta, b.num_credito, a.numcliente
		INTO cNumTDCUpgrade,cNumCredito, cNumcte
		FROM intercard:"informix".tarjeta a 
		INNER JOIN bdicred:"informix".sd_tarjeta b ON (a.numtarjeta = b.num_tarjeta)
        INNER JOIN bdicred:sd_credito_upgrade c ON (b.num_credito = c.num_credito AND b.numcte = c.numcte)
        INNER JOIN bdicred:sd_maecred d ON (c.num_credito = d.num_credito AND c.numcte = d.numcte)
        INNER JOIN bdicred:Sd_maesdos e ON (d.empresa = e.empresa AND d.num_credito = e.num_credito)
		WHERE DATE(a.fechaasignacion) >= dtfecha AND (a.numtarjeta LIKE '51%' OR a.numtarjeta LIKE '554%')
        AND b.prodtarjeta IN ('6001','001','003')
        AND b.num_credito like '600%'
        AND b.status_tar ='A'
		ORDER BY a.fechaasignacion
		
		SELECT numerotarjeta,num_producto_upgrade  
		INTO cNumTDClasica,cNumProdUpgrade
		FROM bdicred:"informix".sd_credito_upgrade
		WHERE num_credito = cNumCredito
		AND numcte = cNumcte;
		
		IF NVL(cNumTDClasica,'') <> '' THEN 
			EXECUTE PROCEDURE "informix".sp_clona_tdc_upgrade_sc(pEmpresa,'sistemas', cNumProdUpgrade, cNumCredito ,cNumTDClasica,cNumTDCUpgrade)
			INTO vCodRet, vMsjRetorno;


			IF vCodRet::INTEGER = 0 THEN
				LET cExitoso = cExitoso + 1;				
			ELIF vCodRet::INTEGER = 5 THEN
				LET cSdoRetenido = cSdoRetenido + 1;
				LET cCreditosSdoRet = cNumCredito || ", " || cCreditosSdoRet;
			ELIF vCodRet::INTEGER = 8 THEN --AAME INC 27 135 Cheque SBC
				LET iSdoSBC = iSdoSBC + 1;
				LET cCreditosSdoSBC = cNumCredito || ", " || cCreditosSdoSBC;			
			ELSE 
				LET cNoexitoso = cNoexitoso + 1;
			END IF;
		
		END IF;
			
	END FOREACH;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '000002';
		LET cMensajeRet = 'No existe información con incidencia de upgrade con la fecha indicada';
	END IF;

	IF cSdoRetenido > 0 THEN
		SET DEBUG FILE TO '/tmp/CreditosconRetenido.out';
		TRACE ON;
			LET cCreditosSdoRet = cCreditosSdoRet;
		TRACE OFF;	
	END IF;
	--AAME INC 27 135 Cheque SBC
	IF iSdoSBC > 0 THEN
		SET DEBUG FILE TO '/tmp/CreditosconSdoSBC.out';
		TRACE ON;
			LET cCreditosSdoSBC = cCreditosSdoSBC;
		TRACE OFF;	
	END IF;	
	
	LET cSdoRetenido = cSdoRetenido + iSdoSBC;

	RETURN cCodRet, cMensajeRet, cExitoso, cNoexitoso, cSdoRetenido;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para ejecutar de forma masiva la correción de créditos con upgrades generados con error en el clonado del producto,',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 16/03/2018',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_cargo_cred()
RETURNING CHAR(6)  AS codigo_retorno, 
          CHAR(80) AS mensaje_retorno;
		  
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6); 
DEFINE cMensajeRet   CHAR(80);
DEFINE iRegistros    INTEGER;
DEFINE dtHoraIni     DATETIME HOUR TO SECOND;
DEFINE dtHoraFin     DATETIME HOUR TO SECOND;
define intcontador			smallint;
DEFINE cFecha1			DATE;
DEFINE cNumProd       	CHAR(4); 
DEFINE cCod_prod       	CHAR(1);
DEFINE dCapVig    		DECIMAL(14,2);
DEFINE dCaptrans    	DECIMAL(14,2);
DEFINE dCapvencexig    	DECIMAL(14,2);
DEFINE dCapvencnoexig    		DECIMAL(14,2);
DEFINE ctotal_creditos    		DECIMAL(14,2);
DEFINE ccreditos_vigentes    	DECIMAL(14,2);
DEFINE ccreditos_transitorios   DECIMAL(14,2);
DEFINE ccreditos_vencidos    	DECIMAL(14,2);
DEFINE ccreditos_saldados    	DECIMAL(14,2);
DEFINE ccreditos_favor    		DECIMAL(14,2);
DEFINE ccreditos_sdo    		DECIMAL(14,2);
--
define vcapvig	integer;


LET iSqlErr        = 0;
LET iIsamErr       = 0;
LET cErrorInfo     = "";
LET cCodRet        = "000000";
LET cMensajeRet    = "PROCESO EXITOSO";
LET iRegistros     = 0;
let intcontador			=0;
LET cFecha1		   = DATE(1);
LET cNumProd 	   = "";
LET cCod_prod	   = "";
LET  dCapVig       = 0;
LET  dCaptrans     = 0;
LET  dCapvencexig      		= 0;
LET  dCapvencnoexig    		= 0;
LET  ctotal_creditos   	 	= 0;
LET  ccreditos_vigentes    	= 0;
LET  ccreditos_transitorios    = 0;
LET  ccreditos_vencidos    	= 0;
LET  ccreditos_saldados    	= 0;
LET  ccreditos_favor    	= 0;
LET  ccreditos_sdo    		= 0;



BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/resplogifx/archivoscartera/Janeth/sp_sispagos_x_25042013_janethe.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
--ejecucion 1
SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
INTO dtHoraIni
FROM sysmaster:"informix".sysshmvals;

SELECT fecha_ant::DATE
INTO cFecha1
FROM bdicred:"informix".sd_fechas;

truncate table "informix".sd_cartera_sdos;

let intcontador        =0;
foreach

		select a.abrevia_prod,a.cod_prod
		into cNumProd,cCod_prod
		from bdicred:sd_tipprod a
		inner join bdicred:sd_definicion b on (a.empresa = b.empresa and a.abrevia_prod = b.num_producto and b.reporte_cartera = 1)
		
--let vcapvig = day(cFecha1)::integer;
	IF cCod_prod in ('T') THEN
	
	select      --a.num_producto num_producto,
			sum(a.capvig) capvig, 
			sum(a.captrans) captrans,
			sum(a.capvenexig) capvenexig,
			sum(a.capvencnoexig) capvencnoexig
			INTO dCapVig,dCaptrans,dCapvencexig,dCapvencnoexig ---cNumProd,
			from bdicred:temp_sdo_conciltdc a  
		   where a.num_producto = cNumProd;
		
		select count(*) 
			INTO ccreditos_vigentes
			from bdicred:temp_sdo_conciltdc
			where status_cred = 'AA'
                and num_producto = cNumProd;

		select count(*) 
			INTO ccreditos_transitorios
			from bdicred:temp_sdo_conciltdc
			where status_cred = 'BA'
                and num_producto = cNumProd;

		select count(*) 
			INTO ccreditos_vencidos
			from bdicred:temp_sdo_conciltdc
			where status_cred = 'BT'
                and num_producto = cNumProd;

		select count(*) 
			INTO ccreditos_saldados
			from bdicred:temp_sdo_conciltdc
			where status_cred = 'FF'
			  and num_producto = cNumProd;
			  
		select count(*) 
		    into ctotal_creditos
			from bdicred:temp_sdo_conciltdc
			where num_producto = cNumProd;
			
		select 
			count(*) saldo_favor
			into ccreditos_favor
		    from bdicred:temp_sdo_conciltdc a
		   where a.num_producto = cNumProd
			and a.status_cred = 'AA'
			and a.sdoinsoluto < 0; 

		select 
			count(*) sado_0
			into ccreditos_sdo
		  from bdicred:temp_sdo_conciltdc a
		 where a.num_producto = cNumProd
			and a.status_cred = 'AA'
            and a.sdoinsoluto = 0; 

	END IF;
	IF cCod_prod in ('P','R') THEN
		
		select      --a.num_producto num_producto,
			sum(a.capvig) capvig, 
			sum(a.captrans) captrans,
			sum(a.capvenexig) capvenexig,
			sum(a.capvencnoexig) capvencnoexig
			INTO dCapVig,dCaptrans,dCapvencexig,dCapvencnoexig ---cNumProd,
			from bdicred:temp_sdo_concilpp a  
			where a.num_producto = cNumProd;
		
		select count(*) 
			INTO ccreditos_vigentes
			from bdicred:temp_sdo_concilpp
			where status_cred = 'AA'
                and num_producto = cNumProd;

		select count(*) 
			INTO ccreditos_transitorios
			from bdicred:temp_sdo_concilpp
			where status_cred = 'BA'
                and num_producto = cNumProd;

		select count(*) 
			INTO ccreditos_vencidos
			from bdicred:temp_sdo_concilpp
			where status_cred = 'BT'
                and num_producto = cNumProd;
				
		select count(*) 
			INTO ccreditos_saldados
			from bdicred:temp_sdo_concilpp
			where status_cred = 'FF'
                and num_producto = cNumProd;

			
		select count(*) 
		    into ctotal_creditos
			from bdicred:temp_sdo_concilpp
			where num_producto = cNumProd;
			
		select 
			count(*) saldo_favor
				into ccreditos_favor
		        from bdicred:temp_sdo_concilpp a
			   where a.num_producto = cNumProd
			     and a.status_cred = 'AA'
                 and a.sdoinsoluto < 0; 

        select 
			count(*) sado_0--,
			    into ccreditos_sdo
		        from bdicred:temp_sdo_concilpp a
	           where a.num_producto = cNumProd
				 and a.status_cred = 'AA'
                 and a.sdoinsoluto = 0; 
	END IF;

	
--let cFecha1 = pFecha;

SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
INTO dtHoraFin 
FROM sysmaster:"informix".sysshmvals;

INSERT INTO bdicred:"informix".sd_cartera_sdos   VALUES 
(cFecha1, cNumProd, dCapVig ,dCaptrans, dCapvencexig, dCapvencnoexig,
 ctotal_creditos,ccreditos_vigentes,ccreditos_transitorios,ccreditos_vencidos,ccreditos_saldados,
 ccreditos_favor,ccreditos_sdo);
 
 end foreach;
--LET cMensajeRet = dtHoraIni || "  " || dtHoraFin;
RETURN cCodRet, cMensajeRet;
 
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la',
'obtención de la información para el',
'reporte de cartera',
'AUTOR : Maria Janeth Peinado Cuevas',
'FECHA : 04/06/2019',
'BD    : BDICRED';

CREATE PROCEDURE "informix".provisionlineacred_parte_inc(pEmpresa CHAR(3), pEjecucion smallint)
    RETURNING CHAR(5);
	
	
   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE CodRet   CHAR(5);  DEFINE sql_err SMALLINT; DEFINE isam_err SMALLINT;
   DEFINE error_info CHAR(40); DEFINE nRows SMALLINT; DEFINE vMensaje VARCHAR(200,1); 
   DEFINE Mensaje  VARCHAR(200,1);  DEFINE vNumCred CHAR(20); DEFINE vProgBand SMALLINT;

   DEFINE GLOBAL FechaHoy  DATE  DEFAULT NULL;
   DEFINE GLOBAL FechaAnt  DATE  DEFAULT NULL;
   DEFINE GLOBAL ProxFecha DATE  DEFAULT NULL;
   DEFINE GLOBAL PriDiaMes DATE  DEFAULT NULL;
   DEFINE GLOBAL PriHabMes DATE  DEFAULT NULL;
   DEFINE GLOBAL UltDiaMes DATE  DEFAULT NULL;
   DEFINE GLOBAL UltHabMes DATE  DEFAULT NULL;
   DEFINE GLOBAL vPrecioReal     DECIMAL(14,6) DEFAULT 0;
   DEFINE GLOBAL vPrecioRealAnt  DECIMAL(14,6) DEFAULT 0;
   DEFINE GLOBAL vIvaSuc         DECIMAL(5,3)  DEFAULT 0;
   DEFINE GLOBAL vIvaBase        DECIMAL(5,3)  DEFAULT 0;
   DEFINE GLOBAL DiasCalc        SMALLINT      DEFAULT 0;
   DEFINE GLOBAL DiasTraspIC     SMALLINT      DEFAULT 0;

   DEFINE SdoIntAnticip, SdoIntereses, SdoDiaAntInt, SdoMesAntInt, SdoAcumMesInt, SdoExigInt, SdoNoExig MONEY(14,2); --SdoIntAntDev   , , ProvisionNormal
   DEFINE SdoMoratorio,  SdoCapital, SdoCapInsoluto, SdoDiaAntCap,  SdoAcumMesCap, MontoVencido MONEY(14,2); --SdoDiaAntMor   , SdoMesAntMor  , SdoMesAntCap,
   DEFINE MtoVencTrasp,  DiasAcumIntPer, SdoGlobalInt, SdoAcumIntPer, IntTraNoExig, SdoTrab4, MontoFinanciado, MtoVencTraInt, IntTraNoExigMes MONEY(14,2); 
   DEFINE MtoCapitalizado, MtoMinistraCap, vIvaMora, vSdoAcumMora, SdoPromedio, InteresMam, InteresPmm, InteresMad     MONEY(14,2); --MontoReservado,
   DEFINE InteresPmd,   MontoProvision, MtoCapitaliza, TotalAdeudo, MontoPago, MtoMoraOrdi, MtoMoraCope, MtoMoraOrdiMa, MtoMoraCopeMa     MONEY(14,2);
   DEFINE MtoMoraOrdiPm, MtoMoraCopePm,CapTrasNo,vIntOrden,vIvaOrd,vSdoNoExigPas,vIvaOrden,vIvaOrdenAnt,vCapInsEsTot, mSdoOrig_PagMin, mIntCap_PagMin, mIvaIntCap_PagMin MONEY(14,2);

   DEFINE TasaAm, TasaHm, TasaAd, TasaHd, TasaIn, vTasaMora, TasaCope, TasaIntd, vTasaCte,TasaIntm DECIMAL(9,6) ;
   DEFINE vPrecioIni, vPrecioFin, TasaDiaria  DECIMAL(14,6);
   DEFINE vMtoVencido, vMtoVencido_ant, vIvaInt,vIntGrav, vIvaIntv, vIvaIntMes,  vReservaInt, vMtoProvision,SdoRetenido,vVencidoHist,MinimoMesAnt,VigenteMesAnt DECIMAL(14,2); 
   DEFINE vProvIva,vProvInt, TopeMinimo, vIntDiario,  vCuotaMes,vIntOrd,vCalcIvaMesAnt             DECIMAL(14,2);
   DEFINE vPorcReserva                        DECIMAL(5,2);

   DEFINE DiasPeriodo, DiasAcCap, DiasMa, DiasPm, DifDias, DiaCuota, DiasAcumCap, DiasAcumInt, DiasAcumMora, Aniversario, vReferencia, vDiaDeCorte  SMALLINT;
   DEFINE vDiasGraciaMora, vDiasMaxPago, vDiasBloqueo, DiasProvMa, DiasProvPm, vDiasTrasp, vRMora, rLog, vCodRefInt,vPasoProm, vFactorPagoMin, vDiaProxPag  SMALLINT;

   DEFINE CambioMes   CHAR(1); DEFINE vCodigoFun CHAR(3); DEFINE Folio      CHAR(16); DEFINE vSucursal   CHAR(4); DEFINE vDivisa CHAR(2);
   DEFINE NumProducto CHAR(4); DEFINE Transacc   CHAR(4); DEFINE vTpDiasMora CHAR(1); DEFINE vTpDiasPago CHAR(1); DEFINE Begin   CHAR(1);
   DEFINE TrasHoy     CHAR(1); DEFINE vCodFunInt CHAR(3); DEFINE BanderaInt CHAR(1);  DEFINE vStProc   CHAR(1);
   DEFINE StatusMora  CHAR(1); DEFINE vForeach   CHAR(1); DEFINE vBandFinan CHAR(1);  DEFINE vPlaza    CHAR(3);  DEFINE Es_Totalero  CHAR(1);
   DEFINE vSiCap      CHAR(1); DEFINE vDia       CHAR(2); DEFINE vCapVig    CHAR(10); DEFINE vCapTras  CHAR(10); DEFINE vCapVenExig  CHAR(15);
   DEFINE vIntVig     CHAR(10);DEFINE vIntVenc   CHAR(10);DEFINE vFolio     CHAR(16); DEFINE StatusCred, StatusCred_ant   CHAR(2);
   DEFINE vmnto_otorgado DECIMAL (18,2); DEFINE vFactorPagoMinLinC, v_fac_pagm_suma_sdo DECIMAL (4,4);

   DEFINE FechaPagoCap, FechaPagoInt, vFechaVenc, vFecProxPag, vFProceso, vFechaReserva ,vFechaCuota,vFechaUDIant,vFecMes, vFechaUltPago,vFechaVencim, vFechahist    DATE;
   DEFINE vErrores,vMarcaAyuda, vdiasatraso INTEGER;

   DEFINE vMtofinventrasp integer; DEFINE wstatus_cred char(02); DEFINE pprocesos smallint; DEFINE cred_ini CHAR(20);
   DEFINE cred_fin CHAR(20);  DEFINE vComportamiento smallint;   DEFINE Campotrabajo3 CHAR(10);

-- APOYO 2014 INI
   DEFINE wbandera_apoyo CHAR(01);
-- APOYO 2014 FIN
	DEFINE impagos, moras INTEGER;

-- RQM 09 473   
    DEFINE vSaldoTotalLiq           DECIMAL(18,2);      DEFINE vSaldoTotalLiq_ch   DECIMAL(18,2);
	DEFINE vSdoTotLiquidar 			decimal(18,2);		DEFINE vPagoMinimo              decimal(18,2);
	DEFINE vSdoTotVencido           decimal(18,2);		DEFINE vLimiteCredito 			decimal(18,2);
	DEFINE vComisionAnualidad       decimal(18,2);		DEFINE vFechaComisionAnualidad 	date;
	DEFINE vComisionDispEfectivo    decimal(18,2);		DEFINE vComisionApertura 		decimal(18,2);		
	DEFINE vFechaComisionApertura   date;				DEFINE vInteresesCargados       decimal(18,2);
	DEFINE vMontoDevoluciones       decimal(18,2);		DEFINE vMontoOtrasTrnx 			decimal(18,2);
	DEFINE vMaxMoraHist             smallint;			DEFINE vSaldoMaximoHist 		decimal(18,2);
	DEFINE vNumVecesMora1           integer;			DEFINE vNumVecesMora2           integer;
	DEFINE vNumVecesMora3 	        integer;			DEFINE vNumVecesMora4           integer;					
-- RQM 09 473   

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- ********************  ******************************************************
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET CodRet = sql_err;
      CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,TRIM(error_info)) RETURNING rLog;

      IF Begin = "S" THEN ROLLBACK WORK; END IF
      IF rLog > 0 THEN
          RETURN CodRet;
      ELSE
        IF vForeach <> "S" THEN RETURN CodRet; END IF
      END IF
   END EXCEPTION WITH RESUME;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;
  SET DEBUG FILE TO "/informix/provisionlineacred_parte.out";
  TRACE ON;

   LET CodRet         = '000';
   LET SdoIntereses   = 0;    LET SdoDiaAntInt  = 0;  LET SdoMesAntInt   = 0;  LET SdoAcumMesInt   = 0;   LET SdoExigInt     = 0;   LET SdoNoExig      = 0;
   LET DiasAcumInt    = 0;    LET SdoMoratorio  = 0;  LET DiasAcumMora   = 0;  LET SdoCapital      = 0;   LET SdoCapInsoluto = 0;   LET SdoDiaAntCap   = 0;  
   LET SdoAcumMesCap  = 0;    LET DiasAcumCap   = 0;  LET MontoVencido   = 0;  LET MtoVencTrasp    = 0;   LET DiasAcumIntPer = 0;   LET SdoGlobalInt   = 0; 
   LET SdoAcumIntPer  = 0;    LET InteresMam    = 0;  LET InteresPmm     = 0;  LET DiasProvMa      = 0;   LET DiasProvPm     = 0;   LET MtoMoraOrdi    = 0; 
   LET MtoVencTraInt  = 0;    LET MtoMoraCope   = 0;  LET MtoMoraOrdiMa  = 0;  LET MtoMoraCopeMa   = 0;   LET MtoMoraOrdiPm  = 0;   LET MtoMoraCopePm  = 0;    
   LET IntTraNoExig   = 0;    LET SdoTrab4      = 0;  LET DiasMa         = 0;  LET DiasPm          = 0;   LET CambioMes      = 'N'; LET MontoProvision = 0;
   LET vCodigoFun     = '034'; LET vReferencia  = ''; LET Transacc       = ''; LET MtoCapitalizado = 0;   LET TasaAd         = 0;   LET TasaHd         = 0;
   LET DiasPeriodo    = 0;    LET MtoCapitaliza = 0;  LET MtoMinistraCap = 0;  LET TotalAdeudo     = 0;   LET MtoMoraOrdi    = 0;   LET MtoMoraCope    = 0;
   LET vNumCred       = " ";  LET rLog          = 0;  LET vMensaje       = ""; LET Begin           = "N"; LET TrasHoy        = "N";
   LET vPrecioIni     = 0;    LET vPrecioFin    = 0;  LET vIvaInt        = 0;  LET vIvaIntMes      = 0;   LET vIvaIntv       = 0;   LET TasaDIaria     = 0;
   LET vIvaMora       = 0;    LET vSdoAcumMora  = 0;  LET vReservaInt    = 0;  LET vPorcReserva    = 100; LET vForeach       = "N"; --LET vBaseReserva = 0;
   LET vMtoVencido    = 0;    LET vPasoProm     = 0;  LET BanderaInt     ="?"; LET vProvInt        = 0;   LET vProvIva       = 0;   LET Es_Totalero    = "?";
   LET vDia           ='';    LET vCapVig       ='';  LET vCapTras       ='';  LET vCapVenExig     ='';   LET vIntVig        ='';   LET vIntVenc       ='';
   LET vIntDiario     = 0;    LET vCuotaMes     = 0;  LET vFechaUDIant   ='';  LET vFecMes         = '';  LET vIntOrd        =0;
   LET vFolio         ='';    LET vIntOrden     = 0;  LET vIvaOrd        = 0;  LET vSdoNoExigPas   = 0;   LET vIvaOrden      = 0;   LET StatusCred     = '';   
   LET vIvaOrdenAnt   = 0;    LET vProgBand     = 0;  LET vMtofinventrasp = 0; LET vIntGrav        = 0;   LET wstatus_cred = '';    LET pprocesos = 0; 
   LET cred_ini = '';         LET cred_fin = '';      LET vComportamiento = 0; LET vFechaUltPago = date(1); LET vMtoVencido_ant = 0; LET vdiasatraso = 0;   LET Campotrabajo3 = '';        
   LET vFactorPagoMin = 0;    LET vDiaProxPag=0;      LET vFactorPagoMinLinC=0;   LET vmnto_otorgado=0; LET vFechahist = date(1);
-- APOYO 2014 INI
   LET wbandera_apoyo = '';
-- APOYO 2014 FIN
	LET impagos = 0; LET moras	= 0;
	-- RQM 09 473 MACF  
	LET vSdoTotLiquidar 			= 0;		LET vPagoMinimo 			= 0;
	LET vSdoTotVencido 			    = 0;		
	LET vLimiteCredito 				= 0;		LET vComisionAnualidad 		= 0;
	LET vFechaComisionAnualidad 	= date(1);	LET vComisionDispEfectivo 	= 0;		
	LET vComisionApertura 			= 0;		LET vFechaComisionApertura 	= date(1);	
	LET vMontoDevoluciones 		    = 0;		LET vInteresesCargados 		= 0;
	LET vMontoOtrasTrnx 			= 0;		
	LET vMaxMoraHist 			    = 0;		LET vNumVecesMora2 			= 0;
	LET vSaldoMaximoHist 			= 0;		LET vNumVecesMora1 			= 0;		
	LET vNumVecesMora3 				= 0;		LET vNumVecesMora4 			= 0;
   -- RQM 09 473 MACF

   SELECT fecha_hoy, fecha_ant, prox_fecha, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes
     INTO FechaHoy, FechaAnt, ProxFecha, PriDiaMes, PriHabMes, UltDiaMes, UltHabMes
     FROM sd_fechas WHERE empresa = pEmpresa;

	 	
    IF FechaHoy IS NULL THEN
       LET CodRet = "110";
       RETURN CodRet;
    END IF;

    SELECT * FROM bdinteg:si_sucursales
     WHERE empresa = pEmpresa AND tpo_sucursal = "S"
      INTO TEMP cr_sucursales;
    CREATE INDEX crsucursal on cr_sucursales (empresa, sucursal);
    update statistics medium for table cr_sucursales;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
      LET vFechaReserva = FechaHoy;

     SELECT valor::SMALLINT INTO vProgBand
       FROM sd_param
      WHERE empresa = pEmpresa AND cod_param = "020";

      SELECT valor INTO DiasCalc
        FROM sd_param
       WHERE empresa = pEmpresa AND cod_param = "24";       -- Dias Para Calculo de Intereses

      IF DiasCalc IS NULL THEN
         LET CodRet = "110";
         CALL log_cierre (pEmpresa, "0000000", CodRet, FechaHoy,"Dias Base para calculo de intereses") RETURNING rLog;
         RETURN CodRet;
      END IF

      SELECT valor INTO vDiasBloqueo
        FROM sd_param
       WHERE empresa = pEmpresa AND cod_param = "335";  --Dias para bloqueo de pagos creditos venc.

      IF vDiasBloqueo IS NULL THEN
         LET CodRet = "110";
         CALL log_cierre (pEmpresa, "0000000", CodRet, FechaHoy,"Dias para BLoqueo de pagos") RETURNING rLog;
         RETURN CodRet;
      END IF

      -- ******************************
      -- Extrae Parametro de IVA Base *
      -- ******************************
      SELECT valor INTO vIvaBase
        FROM bdinteg:si_param
       WHERE empresa = pEmpresa AND cod_param = 47;

      IF vIvaBase IS NULL THEN
         LET CodRet = "800";
         CALL log_cierre (pEmpresa, "0000000", CodRet, FechaHoy,"Valor de Iva Base         ") RETURNING rLog; RETURN CodRet;
      END IF

      -- Determina Valor de Udi para Calculo de Iva de Int. Gravado
      CALL determina_udi(pEmpresa, FechaHoy) RETURNING CodRet, vPrecioReal;

      IF CodRet <> "000" THEN
          CALL log_cierre (pEmpresa, "0000000", CodRet, FechaHoy,"Valor de Real de Udi      ") RETURNING rLog; RETURN CodRet;
      END IF
      -- Determina Valor de Udi para Calculo de Iva de Int. Gravado  Mes Anterior
      CALL monthadd(FechaHoy,-1) returning vFechaUDIant;
      CALL determina_udi(pEmpresa, vFechaUDIant) RETURNING CodRet, vPrecioRealAnt;

       IF CodRet <> "000" THEN
         CALL log_cierre (pEmpresa, "0000000", CodRet, FechaHoy,"Valor de Real de Udi      ") RETURNING rLog; RETURN CodRet;
      END IF
        -- Determina Dias de Provision
        LET DiasProvMa = (ProxFecha - FechaHoy);
        IF DiasProvMa <= 0 THEN
           LET DiasProvMa = 1;
        END IF

      SELECT USER||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(current,3,2)||SUBSTR(CURRENT,12,2)||substr(current,15,2)||SUBSTR(current,18,2) INTO Folio FROM dual;

--     Se determina el rango de creditos a facturar
        SELECT SUBSTR(valor,1,12),SUBSTR(valor,14,25) INTO cred_ini,cred_fin
         FROM bdicred:sd_param WHERE empresa = pEmpresa AND cod_param = (950 + pEjecucion)::CHAR(3);               
		 
        SELECT a.num_credito, a.status_cred
          FROM sd_maecred a, sd_maecredanexo b
         WHERE a.empresa = pEmpresa     AND b.num_credito = a.num_credito
           AND b.empresa = a.empresa    AND b.fecha_proceso = FechaHoy
           and status_cred NOT IN ("CC", "FC")
           and a.num_credito >= cred_ini    and a.num_credito  < cred_fin   
		   and a.num_producto <> '7800'		   
           into temp paso_cred_fac with no log;

        begin;
            create unique index inx_paso_cred on paso_cred_fac(num_credito) ONLINE;
        commit;
        update statistics medium for table paso_cred_fac;
 
FOREACH WITH HOLD
        SELECT num_credito INTO vNumCred
          FROM paso_cred_fac
      ORDER BY status_cred DESC  --FMV 8jul13: Order by por estatus de credito

   BEGIN WORK;

   LET Begin        = "S";
   LET vForeach     = "S";
   LET vSiCap       ='';
   LET vCapInsEsTot = 0;
   LET vCalcIvaMesAnt = 0;
   LET IntTraNoExigMes = 0;
   LET vIvaInt=0;
   LET vIvaIntv=0;
   LET vIntGrav = 0;
   LET vIvaIntMes = 0;
   LET vFechaVencim = NULL;
   LET mSdoOrig_PagMin=0; LET mIntCap_PagMin=0; LET mIvaIntCap_PagMin=0;
    
  
   SELECT a.empresa,              a.num_credito,              a.sdo_int_anticip,  a.sdo_intereses,        a.sdo_dia_ant_int,        a.sdo_mes_ant_int,  
          a.sdo_acum_mes_int,     a.sdo_exig_int,             a.sdo_no_exig,      a.dias_acum_int,        a.sdo_moratorio,          a.dias_acum_mora,     
          a.sdo_capital,          a.sdo_cap_insoluto,         a.sdo_dia_ant_cap,  a.sdo_acum_mes_cap,     a.dias_acum_cap,          a.monto_vencido,
          a.mto_venc_trasp,       a.dias_acum_intper,         a.sdo_global_int,   a.sdo_acum_intper,      a.mto_venc_tra_int,       b.num_producto, 
          DAY(b.fecha_apertura),  b.tasa_interes,             b.sucursal,         b.divisa,               b.fecha_pago_cap,         b.fecha_pago_int,      
          a.mto_capitalizado,     a.int_tra_no_exig,          a.sdo_trab4,        a.monto_financiado,     b.status_cred,            a.sdo_acum_mes_cap,    
          a.dias_acum_cap,        a.mto_ministra_cap,         f.dia_corte,        f.dias_gracia_mora,     f.tp_dias_calc_mora,      f.dias_fecha_max_pago, 
          f.tp_dias_fecha_pago,   NVL(f.tasa_interes_cte,0),  b.dias_trasp_cap,   f.fecha_vencto,         f.prox_fecha_pago,        b.tasa_moratorios,     
          f.fecha_proceso,        a.sdo_contab_mora,          a.sdo_retenido,     a.cap_tras_no_venci,    NVL(b.id_unidad_prod,0),  f.fecha_ult_pago,      
          b.campo_trab3,mto_fin_ven_trasp, a.monto_otorgado
     INTO pEmpresa ,       vNumCred        ,   SdoIntAnticip ,     SdoIntereses   ,    SdoDiaAntInt,  SdoMesAntInt,
          SdoAcumMesInt,   SdoExigInt      ,   SdoNoExig     ,     DiasAcumInt    ,    SdoMoratorio,  DiasAcumMora,
          SdoCapital,      SdoCapInsoluto  ,   SdoDiaAntCap  ,     SdoAcumMesCap  ,    DiasAcumCap,   MontoVencido,
          MtovencTrasp,    DiasAcumIntPer  ,   SdoGlobalInt  ,     SdoAcumIntPer  ,    MtoVencTraInt, NumProducto,
          Aniversario,     TasaIntm        ,   vSucursal     ,     vDivisa        ,    FechaPagoCap,  FechaPagoInt,
          MtoCapitalizado, IntTraNoExig    ,   SdoTrab4      ,     MontoFinanciado,    StatusCred,    SdoPromedio,
          DiasAcCap,       MtoMinistraCap  ,   vDiaDeCorte   ,     vDiasGraciaMora,    vTpDiasMora,   vDiasMaxPago,
          vTpDiasPago,     vTasaCte        ,   vDiasTrasp    ,     vFechaVenc     ,    vFecProxPag,   vTasaMora,
          vFProceso,       vSdoAcumMora    ,   SdoRetenido   ,     CapTrasNo      ,    vMarcaAyuda,   vFechaUltPago,
          Campotrabajo3,   vMtofinventrasp, vmnto_otorgado
     FROM sd_maesdos a, sd_maecred b, sd_maecredanexo f
    WHERE a.num_credito = vNumCred          AND a.empresa     = pEmpresa
      AND b.num_credito = a.num_credito     AND b.empresa     = a.empresa
      AND f.num_credito = a.num_credito     AND f.empresa     = a.empresa;
     
      LET vMtoVencido = 0;
      LET vMtoVencido_ant = 0;
      LET vBandFinan = "0";
      LET Es_Totalero = "N";
      LET mSdoOrig_PagMin = (SdoCapital+CapTrasNo);
--APOYO 2014 INI
      LET wbandera_apoyo = '';
--APOYO 2014 FIN

	  IF (Campotrabajo3 <> 'BAJA' ) then
          LET vMtofinventrasp = 0;
	  ElSE
		IF (vMtofinventrasp <> 0) THEN
			 SELECT count(*) INTO vMtofinventrasp
			 FROM sd_amortiza_credito
			WHERE empresa = pempresa  AND num_credito = vNumCred  AND capital_status IN ("2","7");
		END IF;
	  END IF;

      LET StatusCred_ant = StatusCred;
      LET vComportamiento = 0;

      IF (StatusCred = "AA") THEN
         LET MtoVencTraInt = 0;
      END IF;

    IF ( Campotrabajo3 is null ) then
        LET Campotrabajo3 = '';
    END IF;

    --IF (StatusCred = "FF") THEN
	IF (StatusCred IN  ("FF","FI")) THEN --RQM  09 343-0 JMAH
-- JOM INI Graba historico para generar estados de cuenta de creditos cancelados
        LET vFechahist = mdy(month(FechaHoy),vDiaDeCorte,year(FechaHoy));

        IF ( day(FechaHoy)::smallint > vDiaDeCorte) THEN
            LET vFechahist = monthadd(vFechahist,1);
        END IF;
 
         IF NOT EXISTS ( SELECT num_credito
                       FROM bdicred:sd_maesdoshist
                       WHERE empresa = pEmpresa
     			         AND num_credito = vNumCred
                       AND fecha = vFechahist) THEN
 
 

        INSERT INTO sd_maesdoshist SELECT {+INDEX(sd_maesdos idx_sd_maesdos)} vFechahist, * , 0.0 FROM sd_maesdos  WHERE empresa = pEmpresa AND num_credito = vNumCred;
		END IF;
		COMMIT WORK;
        CONTINUE FOREACH;
    END IF;
-- JOM INI Graba historico para generar estados de cuenta de creditos cancelados

 -- jom Ini Venta de Cartera
    IF ( vMarcaAyuda = 1 OR StatusCred = "CV" OR ( Campotrabajo3 = 'BAJA' AND StatusCred <> "CV") ) THEN -- Marca para bloqueo de crÃÂ©ditos
        UPDATE sd_maesdos
           SET mto_fin_ven_trasp  = vMtofinventrasp
	     WHERE empresa = pEmpresa AND num_credito = vNumCred;
	
        --CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
        --                       SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,FechaHoy) RETURNING CodRet;

        -- RQM 09 473 MACF
		CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
                               SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,MontoFinanciado,FechaHoy) RETURNING CodRet;
		-- RQM 09 473 MACF
        IF ( CodRet <> "000" ) THEN
            LET vMensaje = " Saldos Diarios";
            CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,vMensaje) RETURNING rLog;
        END IF;

        IF ( ( Campotrabajo3 = 'BAJA' AND StatusCred <> "CV") OR (vMarcaAyuda = 1 AND StatusCred <> "CV") ) THEN
            UPDATE sd_maecredanexo  SET fecha_proceso = ProxFecha
             WHERE num_credito = vNumCred AND empresa = pEmpresa;

            IF ( FechaHoy = UltHabMes ) THEN
                INSERT INTO bdicred:"informix".sd_maesdoscont
                 SELECT FechaHoy, *
                   FROM bdicred:"informix".sd_maesdos
                  WHERE num_credito = vNumCred AND empresa = pEmpresa ;

                INSERT INTO bdicred:"informix".sd_maecredcont
                  SELECT FechaHoy, empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,
							status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,
							cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,
							codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,
							bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,
							tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
                    FROM bdicred:"informix".sd_maecred
                   WHERE num_credito = vNumCred
                     AND empresa = pEmpresa ;

                IF (vFechaVenc IS NOT NULL) THEN
                    LET vdiasatraso = abs(FechaHoy) - abs(date(vFechaVenc + 1 units month));
                ELSE
                    LET vdiasatraso = 0;
                END IF;

               UPDATE bdicred:"informix".sd_indicador_cred
                SET fecha_ultimo_pago_h   = fecha_ultimo_pago,   monto_ultimo_pago_h   = monto_ultimo_pago,   trans_ultimo_pago_h   = trans_ultimo_pago, 
                    saldo_maximo_h        = saldo_maximo,        fecha_sdo_maximo_h    = fecha_sdo_maximo ,   fecha_ultima_compra_h = fecha_ultima_compra,
                    monto_ultima_compra_h = monto_ultima_compra, atm_disp_monto_h      = atm_disp_monto,      atm_disp_fecha_h      = atm_disp_fecha, 
                    atm_disp_transacc_h   = atm_disp_transacc,   pos_disp_monto_h      = pos_disp_monto,      pos_disp_fecha_h      = pos_disp_fecha,
                    pos_disp_transacc_h   = pos_disp_transacc,   vnt_disp_monto_h      = vnt_disp_monto,      vnt_disp_fecha_h      = vnt_disp_fecha, 
                    monto_ult_convenio_h  = monto_ult_convenio,  fecha_ult_convenio_h  = fecha_ult_convenio,  num_vencidos_his      = num_vencidos,        
                    num_vencidos		  = vMtofinventrasp,     saldo_max_facturado_h = saldo_max_facturado, pago_mayor_h          = pago_mayor,  
                    num_atm_h             = num_atm,             monto_atm_h           = monto_atm,           num_pos_h             = num_pos,
                    monto_pos_h           = monto_pos,           num_vtn_h             = num_vtn,             monto_vtn_h           = monto_vtn, 
                    num_pagos_h           = num_pagos,           monto_pagos_h         = monto_pagos,         dias_atraso           = vdiasatraso,
                    num_atm               = 0,                   monto_atm             = 0,			          num_pos               = 0, 
                    monto_pos             = 0,        		     num_vtn               = 0,                   monto_vtn             = 0,
                    num_pagos             = 0,                   monto_pagos           = 0,                   fecha_vencido_h       = fecha_vencido, 
                    fecha_cancelacion_h   = fecha_cancelacion,   fecha_ult_respaldo    = FechaHoy
                   WHERE num_credito = vNumCred     AND empresa     = pEmpresa ;

            ELIF DAY(FechaHoy) = vDiaDeCorte THEN
                    -- Genera Historico de Saldos
                INSERT INTO sd_maesdoshist
                 SELECT {+INDEX(sd_maesdos idx_sd_maesdos)} FechaHoy, *, TasaIntm
                   FROM sd_maesdos  WHERE empresa = pEmpresa    AND num_credito = vNumCred;

                UPDATE sd_maesdos
                    SET sdo_int_anticip  = 0, sdo_mes_ant_int  = sdo_intereses, sdo_intereses    = 0, sdo_acum_mes_int = 0,
                        sdo_acum_intper  = 0, sdo_acum_mes_cap = 0,             dias_acum_cap    = 0, dias_acum_int    = 0
                  WHERE empresa = pEmpresa  AND num_credito = vNumCred;

                UPDATE "informix".sd_indicador_cred SET 
                    fecha_ultimo_pago_ch = fecha_ultimo_pago, monto_ultimo_pago_ch   = monto_ultimo_pago,   saldo_maximo_ch        = saldo_maximo, 
                    fecha_sdo_maximo_ch  = fecha_sdo_maximo,  fecha_ultima_compra_ch = fecha_ultima_compra, monto_ultima_compra_ch = monto_ultima_compra,
                    atm_disp_monto_ch    = atm_disp_monto,    atm_disp_fecha_ch      = atm_disp_fecha,      pos_disp_monto_ch      = pos_disp_monto, 
                    pos_disp_fecha_ch    = pos_disp_fecha,    vnt_disp_monto_ch      = vnt_disp_monto,      vnt_disp_fecha_ch      = vnt_disp_fecha,
                    num_vencidos		 = vMtofinventrasp,   num_vencidos_ch        = num_vencidos,        saldo_max_facturado_ch = saldo_max_facturado, 
                    pago_mayor_ch        = pago_mayor,        monto_capitalizado_ch  = monto_capitalizado,  num_atm_ch   		   = num_atmc,
                    monto_atm_ch 		 = monto_atmc,        num_pos_ch   			 = num_posc,			monto_pos_ch 		   = monto_posc, 
                    num_vtn_ch   		 = num_vtnc,   		  monto_vtn_ch 			 = monto_vtnc,          num_pagos_ch 		   = num_pagosc,
                    monto_pagos_ch   	 = monto_pagosc,      num_atmc   			 = 0,                   monto_atmc 			   = 0, 
                    num_posc   			 = 0,			      monto_posc 			 = 0,                   num_vtnc   			   = 0,
                    monto_vtnc 			 = 0,                 num_pagosc 			 = 0,			        monto_pagosc  		   = 0, 
                    fecha_ult_respaldo   = FechaHoy,          comportamiento = vComportamiento, 
                    fecha_vencido = CASE WHEN fecha_vencido IS NULL AND vFechaVencim IS NOT NULL THEN vFechaVencim ELSE fecha_vencido END                  
                WHERE empresa     = pEmpresa AND num_credito = vNumCred ;
            END IF;
        END IF;

        COMMIT WORK;
        CONTINUE FOREACH;
    END IF
 -- jom Ini Venta de Cartera

--APOYO 2014 INI
    SELECT bandera INTO wbandera_apoyo FROM sd_programa_apoyo2018 WHERE num_credito = vNumCred;
	
    IF ( wbandera_apoyo is null ) THEN LET wbandera_apoyo = ''; END IF;
--APOYO 2014 FIN

  -- ***********************************
  -- CALCULO DE PROVISION DE INTERESES *
  -- ***********************************
     LET vMensaje = "Provision Normal";
     LET vMtoProvision = (SdoCapital+CapTrasNo);

--APOYO 2014 INI
    IF ( vMtoProvision > 0 AND wbandera_apoyo <> 'A' ) THEN
--APOYO 2014 FIN
        -- Provision Mes Actual
        LET TasaDiaria = TasaIntm / (DiasCalc * 100);
        LET InteresMam = (vMtoProvision) * TasaDiaria;
        LET InteresMam = InteresMam * DiasProvMa ;
        --Provision Proximo Mes
        IF DiasProvPm > 0 THEN
           LET InteresPmm = (vMtoProvision) * TasaDiaria;
           LET InteresPmm = InteresPmm * DiasProvPm ;
        END IF
        LET SdoDiaAntInt = SdoIntereses;
        LET SdoDiaAntCap = SdoCapInsoluto;
        LET SdoIntAnticip = SdoIntAnticip + InteresMam + InteresPmm;
        LET SdoIntereses = SdoIntereses + InteresMam + InteresPmm;
--        LET vIntDiario   = InteresMam + InteresPmm;
     END IF;

     LET SdoAcumMesInt = SdoAcumMesInt + InteresMam + InteresPmm; -- no se utiliza
     LET DiasAcumInt   = DiasAcumInt + DiasProvMa + DiasProvPm; -- no se utiliza
     IF (SdoCapital > 0) THEN
        LET SdoAcumMesCap = SdoAcumMesCap + (SdoCapital * (DiasProvMa + DiasProvPm));
        LET DiasAcumCap   = DiasAcumCap + DiasProvMa + DiasProvPm; -- no se utiliza
     END IF;
--     LET SdoGlobalInt  = SdoGlobalInt + InteresMam + InteresPmm; -- no se utiliza
     LET SdoAcumIntPer = SdoAcumIntPer + InteresMam + InteresPmm; -- no se utiliza

   -- **********************************************
   --       C a l c u l a   M o r a t o r i o s    *
   -- **********************************************
    LET vMensaje = "Provision de Moratorios";
    IF (StatusCred = "BA" OR StatusCred = "BT") and DAY(FechaHoy) <> vDiaDeCorte THEN

        SELECT MAX(fecha_cuota), count(*) INTO vFechaCuota, vMtofinventrasp
         FROM sd_amortiza_credito
        WHERE empresa = pempresa AND num_credito = vNumCred AND capital_status IN ("2","7");

--APOYO 2014 INI
        IF ( wbandera_apoyo <> 'A' ) THEN
--APOYO 2014 FIN
            LET TasaCope    = vTasaMora - TasaIntm;
            LET MtoMoraOrdiMa = MontoVencido + MtovencTrasp;
            LET MtoMoraCopeMa = MontoVencido + MtovencTrasp;
            LET MtoMoraOrdiMa = (MtoMoraOrdiMa) * TasaIntm/(DiasCalc * 100);
            LET MtoMoraOrdiMa = MtoMoraOrdiMa * DiasProvMa ;
            LET MtoMoraCopeMa = (MtoMoraCopeMa) * TasaCope/(DiasCalc * 100);
            LET MtoMoraCopeMa = MtoMoraCopeMa * DiasProvMa ;
            LET vSdoAcumMora = vSdoAcumMora + MtoMoraOrdiMa + MtoMoraCopeMa;
            LET DiasAcumMora = DiasAcumMora + DiasProvMa;

           UPDATE sd_amortiza_credito
              SET mora_provi_ordi = mora_provi_ordi + MtoMoraOrdiMa,
                  mora_provi_cope = mora_provi_cope + MtoMoraCopeMa,
                  mora_status = 1
            WHERE empresa = pempresa AND num_credito = vNumCred AND fecha_cuota = vFechaCuota;
--APOYO 2014 INI
       END IF;       
--APOYO 2014 FIN
   END IF

   -- ****************************************************************
   -- *     P r o c e s o s   p a r a   D i a   d e   C o r t e      *
   -- ****************************************************************
--APOYO 2014 INI
    IF ( DAY(FechaHoy) = vDiaDeCorte AND wbandera_apoyo = 'A' ) THEN
-- RESPLADA TABLAS
       INSERT INTO bdicred:"informix".sd_maesdos_apoyo2018
       SELECT FechaHoy, *
         FROM bdicred:"informix".sd_maesdos 
        WHERE num_credito = vNumCred AND empresa = pEmpresa;              

       INSERT INTO bdicred:"informix".sd_amortiza_credito_apoyo2018
       SELECT FechaHoy, *
         FROM bdicred:"informix".sd_amortiza_credito
        WHERE num_credito = vNumCred AND empresa = pEmpresa;              
-- MUEVE CUOTAS ACTIVAS UN MES
       UPDATE sd_amortiza_credito
          SET fecha_cuota = monthadd(fecha_cuota,1)
        WHERE empresa = pempresa AND num_credito = vNumCred AND ( capital_status in ('1','7') OR fecha_cuota >= FechaHoy - 1 UNITS MONTH );

       LET vDiaProxPag = vDiaDeCorte-vDiasGraciaMora;
       LET vFecProxPag = DATE(MONTH(FechaHoy + 1 UNITS MONTH) || "/" || vDiaProxPag || "/" || YEAR(FechaHoy + 1 UNITS MONTH));

       UPDATE sd_maecredanexo
          SET prox_fecha_pago = vFecProxPag
        WHERE empresa = pEmpresa AND num_credito = vNumCred;
   END IF;
--APOYO 2014 FIN

    IF ( DAY(FechaHoy) = vDiaDeCorte  AND wbandera_apoyo <> 'A' ) THEN
-----Verifica que en el credito tenga la fecha cuota, si no la crea INI
        LET vFechaCuota = NULL;
-- SE ELIMINA SALDOS INMATERIALES JOM RQM 07 054 11/14/2011
        SELECT fecha_cuota INTO vFechaCuota
          FROM sd_amortiza_credito
         WHERE empresa = pEmpresa AND num_credito = vNumCred AND fecha_cuota = FechaHoy;

        IF vFechaCuota Is Null  THEN
            CALL sp_creacuota(pEmpresa,vNumCred,0) RETURNING CodRet;
            SELECT fecha_cuota INTO vFechaCuota
               FROM sd_amortiza_credito
              WHERE empresa = pEmpresa AND num_credito = vNumCred AND fecha_cuota = FechaHoy;
        END IF;
-----Verifica que en el credito tenga la fecha cuota, si no la crea FIN

        IF vFechaCuota = FechaHoy THEN
           Let DiasAcumInt = FechaHoy - vFechaUDIant;
           LET vIvaInt = 0;
		   
           SELECT iva, plaza INTO vIvaSuc, vPlaza FROM cr_sucursales WHERE empresa = pEmpresa AND sucursal = vSucursal;

        -- ************************************************************
        -- Genera Movimiento de Financiamiento de Intereses           *
        -- ************************************************************
        SELECT NVL(sdo_cap_insoluto,0), NVL((mto_venc_trasp),0), NVL(sdo_trab4,0), monto_financiado - (mto_venc_trasp + monto_vencido)
          INTO vMtoVencido , vVencidoHist, MinimoMesAnt, VigenteMesAnt
          FROM sd_maesdoshist WHERE fecha = FechaHoy - 1 UNITS MONTH AND empresa = pEmpresa AND num_credito = vNumCred;

        LET vMtoVencido_ant = vMtoVencido;
 --***
        IF VigenteMesAnt Is Null OR VigenteMesAnt < 0  THEN
           LET VigenteMesAnt = 0;
        END IF;
        IF SdoCapInsoluto <= 0 THEN
            LET vMtoVencido = 0;
            LET SdoIntereses = 0;
        END IF

        LET vCapInsEsTot = MontoFinanciado;
        IF MontoFinanciado < 0  Or (MontoFinanciado = 0 and vMtoVencido <= 0) THEN  --**Considerar Totalero Cuando El Mto.Financiado Es Cero
            LET MontoFinanciado = MontoFinanciado * -1;
            LET vBandFinan = "1";
        END IF

        IF vBandFinan = "1" THEN
           LET vMtoVencido = vMtoVencido - (MontoFinanciado + MinimoMesAnt);
        ELSE
           LET vMtoVencido = ABS(vMtoVencido - MinimoMesAnt);
        END IF

        IF SdoNoExig > 0 THEN
           LET vSiCap = 'S';
           IF vMtoVencido <= 0  AND  vCapInsEsTot <= 0 THEN
              LET Es_Totalero ="S";
              LET SdoNoExig = 0;
              UPDATE sd_amortiza_credito SET interes_debe = 0, iva_debe = 0, iva_pagado = 0
                WHERE empresa = pempresa AND num_credito = vNumCred AND fecha_cuota = vFechaCuota -1 UNITS MONTH;
           END IF

           IF (vMtoVencido > 0 AND StatusCred <> "BT" ) or (vCapInsEsTot >0 AND StatusCred <> "BT") THEN
           -- Capitalizacion de iva
              SELECT SUM(iva_debe - iva_pagado) INTO vIvaInt
                FROM sd_amortiza_credito
               WHERE empresa = pempresa AND num_credito = vNumCred AND fecha_cuota = vFechaCuota -1 UNITS MONTH;

              IF vIvaInt IS NOT NULL AND vIvaInt <> 0 THEN

                  CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,3, "605", FechaHoy, vIvaInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
                  IF (CodRet <> "00000") THEN
                      ROLLBACK WORK;
                      LET vMensaje = "Financiamiento de Iva      ";
                      CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, TRIM(vMensaje) || "(GENMOV)") RETURNING rLog;
                      IF rLog > 0 THEN
                         RETURN CodRet;
                      ELSE
                         CONTINUE FOREACH;
                      END IF
                  ELSE
                      LET CodRet = "000";
                  END IF;
              ELSE
                  LET vIvaInt = 0;
              END IF;

-- Capitalizacion de interes
              IF SdoNoExig IS NOT NULL AND SdoNoExig <> 0 THEN

                  LET MtoVencTraInt = MtoVencTraInt + SdoNoExig;

                  CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,2, "605", FechaHoy,  SdoNoExig, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
                  IF (CodRet <> "00000") THEN
                      ROLLBACK WORK;
                      LET vMensaje = "Financiamiento de Intereses";
                      CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, TRIM(vMensaje) || "(GENMOV)") RETURNING rLog;
                      IF rLog > 0 THEN
                         RETURN CodRet;
                      ELSE
                        CONTINUE FOREACH;
                      END IF
                  ELSE
                      LET CodRet = "000";
                      
                  END IF;
              ELSE
                  LET SdoNoExig = 0;
              END IF;

              LET sdoCapital = SdoCapital + SdoNoExig + vIvaInt;
              LET sdoCapInsoluto = SdoCapInsoluto + SdoNoExig + vIvaInt;
              LET mIvaIntCap_PagMin = vIvaInt;  /*RQM 10 673 Pag Min Normativo*/
              LET mIntCap_PagMin = SdoNoExig;   /*RQM 10 673 Pag Min Normativo*/
              LET MtoCapitalizado = MtoCapitalizado + SdoNoExig + vIvaInt;
              LET vIntDiario = SdoNoExig;
              LET vIvaInt      = 0;
           END IF
        END IF
        LET vMtoVencido = 0;

         -- *      REALIZA    P R O V I S I O N    AL    CORTE   *
        IF (StatusCred = "BT") THEN
                LET vCodFunInt = "604";
                LET vCodRefInt = 2;
                LET BanderaInt = "1";
        ELSE
                LET vCodFunInt = "606";
                LET vCodRefInt = 1;
                LET BanderaInt = "0";
        END IF;

        SELECT nvl(SUM(interes_debe - interes_pagado),0), nvl(SUM(iva_debe - iva_pagado),0) INTO vProvInt, vProvIva
          FROM sd_amortiza_credito
         WHERE empresa = pEmpresa
           AND num_credito = vNumCred
          AND fecha_cuota = vFechaCuota -1 UNITS MONTH;

      IF ( IntTraNoExig > 0 and StatusCred <>'AA' ) THEN  --Mov. Int Orden.  --CAS
          let IntTraNoExigMes = vProvInt;
          let vIvaOrdenAnt = vProvIva;

          IF IntTraNoExigMes IS NOT NULL AND IntTraNoExigMes <> 0 THEN
              CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,2, 604, FechaHoy, IntTraNoExigMes, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
          ELSE
              LET IntTraNoExigMes = 0;
          END IF;

          IF vIvaOrdenAnt > 0 THEN

              CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,22, 340, FechaHoy, vIvaOrdenAnt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
              IF (CodRet <> "00000") THEN
                   RETURN CodRet;
              ELSE
                 LET CodRet = "000";
              END IF;
           END IF;
      END IF;

  IF SdoNoExig > 0 THEN
      LET SdoNoExig    = 0;   --**JL
      IF vProvInt > 0  THEN
          IF (vSiCap = '' Or vSiCap IS Null) and StatusCred <> "BT"  THEN
---- ESTE CODIGO ESTA DE MAS              
              let vIvaInt = '';
              let vIvaInt=vProvIva;

             IF vIvaInt IS NOT NULL AND vIvaInt <> 0 THEN
                  CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,3, "605", FechaHoy, vIvaInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
             ELSE
                  LET vIvaInt = 0;
             END IF;

             CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,2, 605, FechaHoy, vProvInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
             CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,vCodRefInt, vCodFunInt, FechaHoy, vProvInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
---- ESTE CODIGO ESTA DE MAS
          ELSE
               CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,vCodRefInt, vCodFunInt, FechaHoy, vProvInt , Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
         END IF;

          IF (CodRet <> "00000") THEN
              ROLLBACK WORK;
              LET vMensaje = "Provision de Int. Ordinarios";
              CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, TRIM(vMensaje) || "(GENMOV)") RETURNING rLog;
              IF rLog > 0 THEN
                RETURN CodRet;
              ELSE
                CONTINUE FOREACH;
              END IF;
          ELSE
              LET CodRet = "000";
          END IF;
          -- Genera Calculo de Iva por Intereses

--- PARA QUE SE REALIZA ESTE CALCULO ????
          CALL calc_iva_grav(pEmpresa, vSucursal, vNumCred, ((SdoAcumMesCap+CapTrasNo)/DiasAcumInt), Folio, TasaIntm, vDivisa, DiasCalc, DiasAcumInt,
                             vProvInt, NumProducto, BanderaInt, vPlaza, "S", vPrecioRealAnt)  RETURNING CodRet, vIvaInt, vIntGrav;
          IF (CodRet <> "000") THEN
             ROLLBACK WORK;
             CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, TRIM(vMensaje) || "(GENMOV)") RETURNING rLog;
             IF rLog > 0 THEN
                RETURN CodRet;
             ELSE
                CONTINUE FOREACH;
             END IF;
          END IF;
--- PARA QUE SE REALIZA ESTE CALCULO ????

          IF vCodFunInt = "606" THEN
            UPDATE sd_amortiza_credito
               SET interes_debe = 0,
                   iva_debe = 0
             WHERE empresa = pempresa
               AND num_credito = vNumCred
               AND fecha_cuota = vFechaCuota - 1 UNITS MONTH;
          END IF;

      END IF
END IF;  -- IF PROVISION

          -- Actualiza Tabla de Amortizacion por Provision de Int Ordinario y por Interes moratorio si existiera
          CALL calc_iva_grav(pEmpresa, vSucursal, vNumCred, SdoIntereses, Folio, TasaIntm, vDivisa, DiasCalc, DiasAcumInt,
                             SdoIntereses, NumProducto, BanderaInt, vPlaza, "N", vPrecioReal) RETURNING CodRet, vIvaInt, vIntGrav;
          IF (CodRet <> "000") THEN
             ROLLBACK WORK;
             CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, TRIM(vMensaje) || "(GENMOV)") RETURNING rLog;
             IF rLog > 0 THEN
                RETURN CodRet;
             ELSE
                CONTINUE FOREACH;
             END IF
          END IF

        If SdoIntereses > 0 then
             UPDATE sd_amortiza_credito
                SET interes_debe = SdoIntereses, iva_debe = vIvaInt, interes_status = DECODE(vCodFunInt,"604","3","1"), campo_trabajo2 = vIntGrav
             WHERE empresa = pEmpresa AND num_credito = vNumCred AND fecha_cuota = vFechaCuota;
        end if;

        -- *******************************************************
        -- T r a s p a s o   a    C a r t e r a   V e n c i d a  *
        -- *******************************************************
        IF vBandFinan = "1" THEN
           LET MontoFinanciado = MontoFinanciado * -1;
        END IF

        LET vFechaCuota = NULL;
        IF MontoFinanciado > 0 THEN
           LET vMtoVencido = MontoFinanciado;
        END IF
        IF SdoCapInsoluto = 0 THEN
             LET vMtoVencido = 0;
        END IF

        IF ( vMtoVencido > 0 AND StatusCred <> "BT" ) THEN -- Traspaso de Vigente a transitorio *
            LET vMensaje = "Traspaso a Transitorio ";
            IF StatusCred = "BA" THEN
               LET vMtoVencido = VigenteMesAnt;
            END IF

            IF (vMtoVencido <= SdoCapital) THEN
                LET MontoVencido = MontoVencido + vMtoVencido;
                LET SdoCapital = SdoCapital - vMtoVencido;
            ELSE
                LET MontoVencido = MontoVencido + SdoCapital;
            END IF;

            CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,1, "602", FechaHoy, vMtoVencido, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
            IF (CodRet <> "00000") THEN
                ROLLBACK WORK;
                LET vMensaje = TRIM(vMensaje) || " (GENMOV)";
                CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, vMensaje) RETURNING rLog;
                IF rLog > 0 THEN
                    RETURN CodRet;
                ELSE
                    CONTINUE FOREACH;
                END IF
            ELSE
                LET CodRet = "000";
            END IF;

            IF vFechaVenc IS NULL OR vFechaVenc = " " THEN -- Vencido Trans.
                LET vFechaVenc = DATE(MONTH((FechaHoy -1 UNITS MONTH)) || "/" || vDiaDeCorte || "/" || YEAR((FechaHoy -1 UNITS MONTH)));
            END IF

            IF (StatusCred = "AA") THEN
                UPDATE sd_amortiza_credito
                   SET capital_status = "7"
                 WHERE empresa = pempresa AND num_credito = vNumCred AND fecha_cuota = FechaHoy  -1 UNITS MONTH;
            END IF;

            LET StatusCred ="BA";
            LET TrasHoy    = "S";
          
            LET vFechaVencim = FechaHoy;
        END IF -- Traspaso de Vigente a transitorio *

        LET vMensaje = "Traspaso de Transitorio a Vencido";

-- bloque para transitorios o vencidos
        IF ( StatusCred_ant <> "AA" ) THEN
            IF ( StatusCred <> "BT" ) THEN
                    LET StatusCred ="BT";
                    LET MtovencTrasp = (MontoVencido);
                    LET CapTrasNo = SdoCapital;
                    LET SdoCapital= 0;
                    LET MontoVencido = 0;

                    IF CapTrasNo IS NOT NULL AND CapTrasNo <> 0 THEN
                     -- Capital de Vigente a Traspasado
                        CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,1, "601", FechaHoy, (CapTrasNo),
                                    Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
                        IF (CodRet <> "00000") THEN
                            ROLLBACK WORK;
                            LET vMensaje = TRIM(vMensaje)||" Vigente a Vencido(GENMOV)";
                            CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, vMensaje) RETURNING rLog;
                            IF rLog > 0 THEN
                                 RETURN CodRet;
                            ELSE
                                 CONTINUE FOREACH;
                            END IF
                        ELSE
                            LET CodRet = "000";
                        END IF;
                    ELSE 
                        LET CapTrasNo = 0;
                    END IF;

                    IF MtovencTrasp IS NOT NULL AND MtovencTrasp <> 0 THEN
                     -- Capital de transitorio a vencido
                        CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,1, "600", FechaHoy, MtovencTrasp,
                                 Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
                        IF (CodRet <> "00000") THEN
                            ROLLBACK WORK;
                            LET vMensaje = TRIM(vMensaje) || " Trans a Vencido (GENMOV)";
                            CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, vMensaje) RETURNING rLog;
                            IF rLog > 0 THEN
                                RETURN CodRet;
                            ELSE
                                CONTINUE FOREACH;
                            END IF
                        ELSE
                            LET CodRet = "000";
                        END IF;
                    ELSE
                        LET MtovencTrasp = 0;
                    END IF;

                    LET MontoVencido = 0;

                    UPDATE sd_amortiza_credito
                       SET capital_status = "2"
                     WHERE empresa = pempresa
                       AND num_credito = vNumCred
                       AND capital_status IN ("1","7")
                       AND fecha_cuota < FechaHoy
                       AND capital_debe > 0
                       AND (capital_debe - capital_pagado) > 0;
            ELSE   -- Realiza reubicacion de saldos cuando ya esta vencido
                LET MtovencTrasp = MtovencTrasp ;
                LET VigenteMesAnt = VigenteMesAnt ;
                LET MtovencTrasp = MtovencTrasp + VigenteMesAnt;
                LET CapTrasNo = CapTrasNo - VigenteMesAnt; --AXL

                IF VigenteMesAnt IS NOT NULL AND VigenteMesAnt <> 0 THEN
                    CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,2, "601", FechaHoy, VigenteMesAnt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
                    IF (CodRet <> "00000") THEN
                        ROLLBACK WORK;
                        LET vMensaje = TRIM(vMensaje) || "Trasp Cap No Exig a Trasp";
                        CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, vMensaje) RETURNING rLog;
                        IF rLog > 0 THEN
                            RETURN CodRet;
                        ELSE
                            CONTINUE FOREACH;
                        END IF
                    ELSE
                        LET CodRet = "000";
                    END IF;
                ELSE
                    LET VigenteMesAnt = 0;
                END IF;

                LET SdoNoExig = 0;

                UPDATE sd_amortiza_credito
                   SET capital_status = "2", interes_status = case when (interes_debe - interes_pagado) > 0 then "3" else interes_status end
                 WHERE empresa = pempresa
                   AND num_credito = vNumCred
                   AND fecha_cuota < FechaHoy
                   AND capital_status IN ("1","7","2");

                SELECT SUM(interes_debe - interes_pagado) INTO IntTraNoExig
                  FROM sd_amortiza_credito
                 WHERE empresa = pempresa
                   AND num_credito = vNumCred
                   AND fecha_cuota < FechaHoy
                   AND capital_status='2';

            END IF -- Status Diferente a BT
        END IF -- Credito Vencido Traspasado

    -- **********************************************
    --       C a l c u l a   M o r a t o r i o s    *
    -- **********************************************
        LET vMensaje = "Acumulacion de Moratorios";

        IF ( StatusCred = "BA" OR StatusCred = "BT" ) THEN

           SELECT MAX(fecha_cuota), count(*) INTO vFechaCuota, vMtofinventrasp
             FROM sd_amortiza_credito
            WHERE empresa = pempresa AND num_credito = vNumCred AND capital_status IN ("2","7");

                LET TasaCope    = vTasaMora - TasaIntm;
                LET MtoMoraOrdiMa = MontoVencido + MtovencTrasp;
                LET MtoMoraCopeMa = MontoVencido + MtovencTrasp;
                LET MtoMoraOrdiMa = (MtoMoraOrdiMa) * TasaIntm/(DiasCalc * 100);
                LET MtoMoraOrdiMa = MtoMoraOrdiMa * DiasProvMa ;
                LET MtoMoraCopeMa = (MtoMoraCopeMa) * TasaCope/(DiasCalc * 100);
                LET MtoMoraCopeMa = MtoMoraCopeMa * DiasProvMa ;
                LET vSdoAcumMora = vSdoAcumMora + MtoMoraOrdiMa + MtoMoraCopeMa;
                LET DiasAcumMora = DiasAcumMora + DiasProvMa;

               UPDATE sd_amortiza_credito
                  SET mora_provi_ordi = mora_provi_ordi + MtoMoraOrdiMa, mora_provi_cope = mora_provi_cope + MtoMoraCopeMa, mora_status = 1
                WHERE empresa = pempresa AND num_credito = vNumCred AND fecha_cuota = vFechaCuota;
        END IF

       -- *********************************************
       -- *        Calculo de pago minimo             *
       -- *********************************************

	   -- Obtiene el monto de pago minimo y factor de monto minimo
        SELECT factor_pago_min::SMALLINT, mto_pago_min::DECIMAL, fact_pag_min_lc, fac_pagm_suma_sdo INTO vFactorPagoMin, TopeMinimo, vFactorPagoMinLinC, v_fac_pagm_suma_sdo
          FROM bdicred:sd_definicion WHERE empresa = pempresa and num_producto = NumProducto;

        LET vMensaje = "Calculo de pago Minimo";
       -- Pregunta si hay capital pendiente para cobrar los moratorios
        IF TrasHoy = "N" THEN
            IF SdoCapInsoluto = 0 THEN
                LET vSdoAcumMora = 0;
            END IF
        END IF

        -- ************************************************************
        -- Valida si estaba en vencido y ya salio para que regenere el
        -- pago minimo RQM 10 011
        -- ************************************************************
        Let StatusCred = StatusCred;
        let SdoCapInsoluto = SdoCapInsoluto;
        let SdoNoExig = SdoNoExig;
        let SdoExigInt = SdoExigInt;


        IF ( Es_Totalero = "S" ) THEN
            LET SdoTrab4 = 0;
		    LET vComportamiento = 1;
			
            IF SdoCapInsoluto <= 0 THEN
                LET MontoFinanciado = 0;
            ELSE
                LET TotalAdeudo = ROUND(((SdoCapital+CapTrasNo) / vFactorPagoMin), -0) ;
				
				IF TotalAdeudo < ROUND((vmnto_otorgado * vFactorPagoMinLinC),-0) THEN 
					LET TotalAdeudo = ROUND((vmnto_otorgado * vFactorPagoMinLinC),-0); 
				END IF;
                -- RQM 10 673 Pag Min Normativo
                IF TotalAdeudo  < ROUND(((mSdoOrig_PagMin * v_fac_pagm_suma_sdo) + mIntCap_PagMin + mIvaIntCap_PagMin), -0) THEN
                    LET TotalAdeudo =  ROUND(((mSdoOrig_PagMin * v_fac_pagm_suma_sdo) + mIntCap_PagMin + mIvaIntCap_PagMin), -0);
                END IF;

				IF ( TotalAdeudo > SdoCapInsoluto ) THEN
					LET TotalAdeudo = SdoCapInsoluto;
				END IF;
				
                IF TotalAdeudo < 0 THEN
                    LET TotalAdeudo = 0;
                ELIF SdoCapInsoluto < TopeMinimo THEN
                    IF SdoCapInsoluto < 0 THEN
                        LET TotalAdeudo = 0;
                    ELSE
                        LET TotalAdeudo = SdoCapInsoluto;
                    END IF;
                ELIF TotalAdeudo < TopeMinimo THEN
                    LET TotalAdeudo = TopeMinimo;
                END IF
                LET MontoFinanciado = TotalAdeudo;
            END IF;
        ELSE
            LET TotalAdeudo = ROUND(((SdoCapital+CapTrasNo) / vFactorPagoMin), -0) ;

            IF TotalAdeudo < ROUND((vmnto_otorgado * vFactorPagoMinLinC),-0) THEN 
                LET TotalAdeudo = ROUND((vmnto_otorgado * vFactorPagoMinLinC),-0); 
            END IF;
            -- RQM 10 673 Pag Min Normativo
            IF TotalAdeudo  < ROUND(((mSdoOrig_PagMin * v_fac_pagm_suma_sdo) + mIntCap_PagMin + mIvaIntCap_PagMin), -0) THEN
                LET TotalAdeudo =  ROUND(((mSdoOrig_PagMin * v_fac_pagm_suma_sdo) + mIntCap_PagMin + mIvaIntCap_PagMin), -0);
            END IF;         
			
            IF TotalAdeudo < 0 THEN
               LET TotalAdeudo = 0;
            ELIF (SdoCapital+CapTrasNo) < TopeMinimo THEN     --SdoCapInsoluto < TopeMinimo THEN  --210508 Solicitado Por Juan Olivares.
               IF (SdoCapital+CapTrasNo) < 0 THEN    --SdoCapInsoluto < 0 THEN
                   LET TotalAdeudo = 0;
               ELSE
                   LET TotalAdeudo = (SdoCapital+CapTrasNo);     --SdoCapInsoluto;
               END IF;
            ELIF TotalAdeudo < TopeMinimo THEN  --210508 Solicitado Por Juan Olivares.
               LET TotalAdeudo = TopeMinimo;
            END IF

            LET MontoFinanciado = TotalAdeudo;

            IF (SdoCapital+CapTrasNo) <= MontoFinanciado THEN   --SdoCapInsoluto <= MontoFinanciado THEN
               LET MontoFinanciado = (SdoCapital+CapTrasNo);   --SdoCapInsoluto;
               IF MontoFinanciado < 0 THEN
                  LET MontoFinanciado = 0;
               END IF;
            END IF;
        END IF;

      -- Marcar como crÃÂ©dito inactivo si no tuvo movimientos durante el perÃÂ­odo (by MACF)
      IF (vMtoVencido_ant <= 0 AND SdoCapInsoluto <= 0) THEN
         IF ( vFechaUltPago < FechaHoy -1 UNITS MONTH ) THEN
            LET vComportamiento = 3;
         ELSE
            LET vComportamiento = 2;
         END IF;
      END IF;
      
      IF Round(MontoFinanciado,-1) - MontoFinanciado < 0 THEN
         Let MontoFinanciado = Round(MontoFinanciado,-1) + 10;
      ELSE
         Let MontoFinanciado = Round(MontoFinanciado,-1);
      END IF;

	IF MontoFinanciado>(SdoCapital+CapTrasNo) THEN
	    IF (SdoCapital+CapTrasNo) > 0 THEN
      	  LET vCuotaMes = (SdoCapital+CapTrasNo);
	    ELSE
		  LET vCuotaMes = 0;
	    END IF;
	ELSE
 		LET vCuotaMes = MontoFinanciado;
	END IF;

    LET SdoTrab4 = MontoFinanciado + MontoVencido + MtoVencTrasp;

    IF SdoTrab4 > SdoCapInsoluto THEN
        IF SdoCapInsoluto < 0 THEN
            LET SdoTrab4 = 0;
        ELSE
            LET SdoTrab4 = SdoCapInsoluto;
        END IF;
    END IF;

    LET MontoFinanciado = SdoTrab4;

      -- ********************************************************************
      -- Genera Prorrateo de la Deuda
      -- ********************************************************************
            CALL prorratea_cargos(pEmpresa, vNumCred, vCuotaMes) RETURNING CodRet;

            IF (CodRet <> "000") THEN
                  ROLLBACK WORK;
                  LET vMensaje = TRIM(vMensaje) || " Prorratea Cargos";
                  CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, vMensaje) RETURNING rLog;
                  IF rLog > 0 THEN
                     RETURN CodRet;
                  ELSE
                     CONTINUE FOREACH;
                  END IF
            END IF;
               --** Actualiza Amortiza En CampoTrabajo1  --**
            SELECT NVL(Sum(iva_debe - iva_pagado),0) Into vIvaIntMes FROM sd_amortiza_credito
            WHERE empresa = pEmpresa and num_credito = vNumCred and capital_status in ('2','7');

            UPDATE sd_amortiza_credito SET campo_trabajo1 = vIvaIntMes
            WHERE empresa = pEmpresa and num_credito = vNumCred and fecha_cuota = FechaHoy;

      -- ********************************************************************
      -- Actualiza Intereses del periodo en las columnas correspondientes   *
      -- ********************************************************************
          IF StatusCred IN ("AA", "BA") THEN
             LET SdoNoExig = SdoIntereses;
          ELSE
             LET IntTraNoExig = IntTraNoExig + SdoIntereses;
          END IF;

          LET SdoIntereses = 0;

          -- Actualiza Anexo Maecred
          LET vDiaProxPag = vDiaDeCorte-vDiasGraciaMora;
          LET vFecProxPag = DATE(MONTH(FechaHoy + 1 UNITS MONTH) || "/" || vDiaProxPag || "/" || YEAR(FechaHoy + 1 UNITS MONTH));

          UPDATE sd_maecredanexo
             SET prox_fecha_pago = vFecProxPag, fecha_vencto = vFechaVenc
           WHERE empresa = pEmpresa AND num_credito = vNumCred;

          IF ( StatusCred = "AA" ) THEN
              UPDATE sd_amortiza_credito
                 SET capital_status = "5", capital_pagado = capital_debe
               WHERE empresa = pEmpresa AND num_credito = vNumCred
                 AND fecha_cuota = FechaHoy - 1 UNITS MONTH
                 AND capital_status NOT IN ("2","7");
          END IF;
        END IF; -- Termina IF de DIa de Corte
   END IF;

 -- RQM 09 473 MACF
   let vSdoTotLiquidar = SdoCapital + MontoVencido + CapTrasNo + MtoVencTrasp + (IntTraNoExig-SdoNoExig) + vIvaInt + vIvaIntv + vSdoAcumMora + SdoMoratorio;
   let vPagoMinimo     = MontoFinanciado + (vIvaIntv - vIvaInt) + vIvaInt + vSdoAcumMora;
   let vSdoTotVencido  = vPagoMinimo - (MontoFinanciado + MontoVencido + CapTrasNo);		
--   let vLimiteCredito  = vmnto_otorgado - SdoCapInsoluto - SdoRetenido;	-- JOM RQI 27 210 20190520	
   let vInteresesCargados = (vProvInt + vProvIva);
   -- RQM 09 473 MACF
   -- **********************************************
   -- Actualiza Tabla de Amortizaciones y Maestros
   -- **********************************************

	-- JOM RQI 27 210 20190520 { 
    SELECT sum(monto)
      INTO SdoRetenido
      FROM sd_maeretenido
     WHERE empresa = pEmpresa
       AND num_credito = vNumCred
       AND estatus in ('P','R');

    IF (SdoRetenido is null) then
        LET SdoRetenido = 0;
    END IF;
	-- } 20190520 JOM RQI 27 210

   IF (SdoRetenido <> 0) then -- JOM RQI 27 210 20190520
       CALL libera_retenido(pEmpresa, vNumCred, SdoRetenido) RETURNING CodRet, SdoRetenido;
       IF (CodRet <> "000") THEN
           LET vMensaje = " Libera Retenido";
           CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, vMensaje) RETURNING rLog;
       END IF;
   END IF;

   let vLimiteCredito  = vmnto_otorgado - SdoCapInsoluto - SdoRetenido; -- JOM RQI 27 210 20190520
   Let SdoNoExig = SdoNoExig;

  -- ******************************************************

   UPDATE sd_maesdos
   SET
      fecha_ult_mov    = FechaHoy,       sdo_int_anticip   = SdoIntAnticip,   sdo_intereses     = SdoIntereses,    sdo_dia_ant_int  = SdoDiaAntInt,    
      sdo_retenido     = SdoRetenido,    sdo_acum_mes_int  = SdoAcumMesInt ,  sdo_exig_int      = SdoExigInt,      sdo_no_exig      = SdoNoExig,       
      dias_acum_int    = DiasAcumInt,    sdo_moratorio     = SdoMoratorio,    sdo_contab_mora   = vSdoAcumMora,    dias_acum_mora   = DiasAcumMora,    
      sdo_capital      = SdoCapital ,    sdo_cap_insoluto  = SdoCapInsoluto,  sdo_dia_ant_cap   = SdoDiaAntCap,    sdo_acum_mes_cap = SdoAcumMesCap,   
      dias_acum_cap    = DiasAcumCap,    mto_capitalizado  = MtoCapitalizado, monto_vencido     = MontoVencido,    mto_venc_trasp   = MtoVencTrasp,    
      dias_acum_intper = DiasAcumIntPer, sdo_global_int    = SdoGlobalInt,    sdo_acum_intper   = SdoAcumIntPer,   mto_venc_int     = vIvaIntMes,      
      mto_venc_tra_int = MtoVencTraInt,  monto_financiado  = MontoFinanciado, mto_fin_ven_trasp = vMtofinventrasp, int_tra_no_exig  = IntTraNoExig,  
      sdo_trab4        = SdoTrab4,       cap_tras_no_venci = CapTrasNo
  WHERE num_credito = vNumCred AND empresa = pEmpresa;

  IF (StatusCred_ant <> StatusCred) then
      UPDATE sd_maecred
         SET status_cred = StatusCred
       WHERE num_credito = vNumCred AND empresa = pEmpresa;
  END IF;

  UPDATE sd_maecredanexo
     SET fecha_proceso = ProxFecha
   WHERE num_credito = vNumCred AND empresa = pEmpresa;

  -- ******************************************************
  -- Actualiza tabla de saldos diaria y mensual
  -- ******************************************************
    Let vIvaInt = 0;
    Let vIvaIntv = 0;

    Select {+INDEX(sd_amortiza_credito amorst)} sum(case when capital_status='1' then (interes_debe - interes_pagado) else 0 end),
           sum(case when capital_status in ('2','7') then (interes_debe - interes_pagado) else 0 end),
           sum(case when capital_status='1' then (iva_debe - iva_pagado) else 0 end),
           sum(case when capital_status in ('2','7') then (iva_debe - iva_pagado) else 0 end)
    into  SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv
    from sd_amortiza_credito
    where empresa = pEmpresa
    and num_credito = vNumCred
    and capital_status in ('1','2','7'); -- validar

   IF FechaHoy = PriHabMes THEN
   	Let vFecMes = PriDiaMes - 1 UNITS DAY;
        Let vFecMes = MDY(MONTH(vFecMes),20,YEAR(vFecMes));
          --CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
          --                     SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,FechaHoy) RETURNING CodRet;

          --- RQM 09 473 MACF
		  CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
                               SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,MontoFinanciado,FechaHoy) RETURNING CodRet;					   
		  --- RQM 09 473 MACF

        IF (CodRet <> "000") THEN
          LET vMensaje = " Saldos Diarios";
          CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,vMensaje) RETURNING rLog;
       END IF;
   ELSE
          --CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
          --                     SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,FechaHoy) RETURNING CodRet;

          -- RQM 09 473 MACF					   
		  CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
                               SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,MontoFinanciado,FechaHoy) RETURNING CodRet;
		  -- RQM 09 473 MACF

       IF (CodRet <> "000") THEN
          LET vMensaje = " Saldos Diarios";
          CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,vMensaje) RETURNING rLog;
      END IF;
  END IF;

   -- *********************************************
   -- Genera Estado de Cuenta                     *
   -- *********************************************
   IF DAY(FechaHoy) = vDiaDeCorte THEN
        -- Genera Historico de Saldos
        LET vMensaje = "Paso a MaesdosHist    ";
        INSERT INTO sd_maesdoshist
        SELECT {+INDEX(sd_maesdos idx_sd_maesdos)} FechaHoy, *, TasaIntm
          FROM sd_maesdos
         WHERE empresa = pEmpresa AND num_credito = vNumCred;

       UPDATE sd_maesdos
          SET sdo_int_anticip  = 0, sdo_mes_ant_int  = sdo_intereses, sdo_intereses    = 0, sdo_acum_mes_int = 0,
              sdo_acum_intper  = 0, sdo_acum_mes_cap = 0,             dias_acum_cap    = 0, dias_acum_int    = 0
        WHERE empresa = pEmpresa AND num_credito = vNumCred;

		
        UPDATE "informix".sd_indicador_cred SET 
			fecha_ultimo_pago_ch = fecha_ultimo_pago, monto_ultimo_pago_ch   = monto_ultimo_pago,   saldo_maximo_ch        = saldo_maximo, 
            fecha_sdo_maximo_ch  = fecha_sdo_maximo , fecha_ultima_compra_ch = fecha_ultima_compra, monto_ultima_compra_ch = monto_ultima_compra,
			atm_disp_monto_ch    = atm_disp_monto,    atm_disp_fecha_ch      = atm_disp_fecha,      pos_disp_monto_ch      = pos_disp_monto, 
            pos_disp_fecha_ch    = pos_disp_fecha,    vnt_disp_monto_ch      = vnt_disp_monto,      vnt_disp_fecha_ch      = vnt_disp_fecha,
			num_vencidos		 = vMtofinventrasp,   num_vencidos_ch        = num_vencidos,        saldo_max_facturado_ch = saldo_max_facturado, 
            pago_mayor_ch        = pago_mayor,        monto_capitalizado_ch  = monto_capitalizado,  num_atm_ch   		   = num_atmc,
			monto_atm_ch 		 = monto_atmc,        num_pos_ch   			 = num_posc,			monto_pos_ch 		   = monto_posc, 
            num_vtn_ch   		 = num_vtnc,   		  monto_vtn_ch 			 = monto_vtnc,          num_pagos_ch 		   = num_pagosc,
			monto_pagos_ch   	 = monto_pagosc,      num_atmc   			 = 0,                   monto_atmc 			   = 0, 
            num_posc   			 = 0,			      monto_posc 			 = 0,                   num_vtnc   			   = 0,
			monto_vtnc 			 = 0,                 num_pagosc 			 = 0,			        monto_pagosc  		   = 0, 
            fecha_ult_respaldo   = FechaHoy,          comportamiento = vComportamiento, 
            fecha_vencido = CASE WHEN fecha_vencido IS NULL AND vFechaVencim IS NOT NULL THEN vFechaVencim ELSE fecha_vencido END,
            --- RQM 09 473 MACF
			sdo_tot_liquidar_ch   = vSdoTotLiquidar, pago_minimo_ch            = vPagoMinimo,             sdo_tot_vencido_ch = vSdoTotVencido,
			limite_credito_ch     = vLimiteCredito,  comision_disp_efectivo_ch = comision_disp_efectivo,  intereses_periodo_ch  = vInteresesCargados, 
			monto_devoluciones_ch = monto_devoluciones, monto_otras_trnx_ch    = monto_otras_trnx,        
			num_veces_mora1       = case when vMtofinventrasp = 1 then nvl(num_veces_mora1,0) + 1 else nvl(num_veces_mora1,0) end,  
			num_veces_mora2       = case when vMtofinventrasp = 2 then nvl(num_veces_mora2,0) + 1 else nvl(num_veces_mora2,0) end,
			num_veces_mora3       = case when vMtofinventrasp = 3 then nvl(num_veces_mora3,0) + 1 else nvl(num_veces_mora3,0) end,
			num_veces_mora4       = case when vMtofinventrasp = 4 then nvl(num_veces_mora4,0) + 1 else nvl(num_veces_mora4,0) end,
		    saldo_maximo_hist     =  case when vSdoTotLiquidar > saldo_maximo_hist then vSdoTotLiquidar end, 
			sdo_tot_liquidar	 = 0,	 pago_minimo 		   = 0,	 sdo_tot_vencido 	  = 0,    limite_credito = 0,
            comision_disp_efectivo = 0, monto_devoluciones   = 0, monto_otras_trnx = 0			
			--- RQM 09 473 MACF
        WHERE empresa     = pEmpresa AND num_credito = vNumCred ;
   END IF;
   -- **************************************************
   -- Respaldo de datos para contabilidad a fin de mes *
   -- **************************************************
  IF FechaHoy = UltHabMes THEN
       INSERT INTO bdicred:"informix".sd_maesdoscont
       SELECT FechaHoy, *
         FROM bdicred:"informix".sd_maesdos
        WHERE num_credito = vNumCred AND empresa = pEmpresa ;

      INSERT INTO bdicred:"informix".sd_maecredcont
      SELECT FechaHoy, empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,
				status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,
				cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,
				codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,
				bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,
				tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
        FROM bdicred:"informix".sd_maecred
       WHERE num_credito = vNumCred AND empresa = pEmpresa ;

    IF (vFechaVenc IS NOT NULL) THEN
--APOYO 2014 INI
        IF ( wbandera_apoyo <> 'A' ) THEN
            LET vdiasatraso = abs(FechaHoy) - abs(date(vFechaVenc + 1 units month));
        END IF;
--APOYO 2014 FIN
    ELSE
        LET vdiasatraso = 0;
    END IF;
--IPCB Ago18- Incluyen los impagos consecutivos a fin de mes (impagos_consec_h)y las moras historicas a fin de mes (moras_hist_h)
    UPDATE bdicred:"informix".sd_indicador_cred
       SET  fecha_ultimo_pago_h   = fecha_ultimo_pago,   monto_ultimo_pago_h   = monto_ultimo_pago,   trans_ultimo_pago_h   = trans_ultimo_pago, 
            saldo_maximo_h        = saldo_maximo,        fecha_sdo_maximo_h    = fecha_sdo_maximo ,   fecha_ultima_compra_h = fecha_ultima_compra,
            monto_ultima_compra_h = monto_ultima_compra, atm_disp_monto_h      = atm_disp_monto,      atm_disp_fecha_h      = atm_disp_fecha, 
            atm_disp_transacc_h   = atm_disp_transacc,   pos_disp_monto_h      = pos_disp_monto,      pos_disp_fecha_h      = pos_disp_fecha,
            pos_disp_transacc_h   = pos_disp_transacc,   vnt_disp_monto_h      = vnt_disp_monto,      vnt_disp_fecha_h      = vnt_disp_fecha, 
            monto_ult_convenio_h  = monto_ult_convenio,  fecha_ult_convenio_h  = fecha_ult_convenio,  num_vencidos_his      = num_vencidos,        
	        num_vencidos		  = vMtofinventrasp,     saldo_max_facturado_h = saldo_max_facturado, pago_mayor_h          = pago_mayor,  
            num_atm_h             = num_atm,             monto_atm_h           = monto_atm,           num_pos_h             = num_pos,
            monto_pos_h           = monto_pos,           num_vtn_h             = num_vtn,             monto_vtn_h           = monto_vtn, 
            num_pagos_h           = num_pagos,           monto_pagos_h         = monto_pagos,         dias_atraso           = vdiasatraso,
			num_atm               = 0,                   monto_atm             = 0,			          num_pos               = 0, 
            monto_pos             = 0,          		 num_vtn               = 0,                   monto_vtn             = 0,
			num_pagos             = 0,                   monto_pagos           = 0,                   fecha_vencido_h       = fecha_vencido, 
            fecha_cancelacion_h   = fecha_cancelacion,   fecha_ult_respaldo    = FechaHoy,            impagos_consec_h      = CASE WHEN statuscred = 'AA' THEN 0 ELSE (NVL(impagos_consec_h,0) + 1) END,
            moras_hist_h		  = CASE WHEN statuscred = 'AA' THEN NVL(moras_hist_h,0)  ELSE (NVL(moras_hist_h,0) + 1) END,
            --- RQM 09 473 MACF
			sdo_tot_liquidar_h    = vSdoTotLiquidar,     pago_minimo_h         = vPagoMinimo,         sdo_tot_vencido_h = vSdoTotVencido,
			limite_credito_h      = vLimiteCredito
		    --- RQM 09 473 MACF
       WHERE num_credito = vNumCred AND empresa = pEmpresa;
   END IF

   IF DAY(FechaHoy) <> vDiaDeCorte THEN
	   --- RQM 09 473 Triad MACF para el registro diario
	   UPDATE bdicred:"informix".sd_indicador_cred
		   SET  sdo_tot_liquidar   = vSdoTotLiquidar, 	pago_minimo 		   = vPagoMinimo, 	    sdo_tot_vencido = vSdoTotVencido,	  
				limite_credito 	   = vLimiteCredito,    
				saldo_maximo_hist     =  case when vSdoTotLiquidar > nvl(saldo_maximo_hist,0) then vSdoTotLiquidar end
		   WHERE num_credito = vNumCred AND empresa = pEmpresa;
	   --- RQM 09 473 Triad MACF para el registro diario
    END IF;

 COMMIT WORK;

END FOREACH

   RETURN CodRet;
END PROCEDURE
DOCUMENT
'****************************************************************************************************************',
'Procedimiento para la provision y traspaso a cartera ',
'vencida para creditos tipo tarjeta',
'AUTOR : Antonio Ruiz',
'FECHA : 30/Diciembre/2006',
'VERSION: 1.00.006',
'BD: BDICRED',
'****************************************************************************************************************',
'MODIFICACIÃÂN',
'Fecha: 20/05/2019',
'ModificÃÂ³: Juan Olivares MartÃÂ­nez',
'InstalÃÂ³: Jorge Humberto Quintana Santiesteban',
'RQ: RQI 27 210 Actualizar el Saldo Retenido de forma diaria cuando no cuadran las cifras en tablas de Saldos.',
'CC: 32746 28/05/2019',
'****************************************************************************************************************';

CREATE PROCEDURE "informix".sp_carga_regcontab() 
RETURNING CHAR(6), CHAR(50);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cCodRetP CHAR(6);
DEFINE cCadena  CHAR (500);
DEFINE cRuta CHAR (50);
DEFINE cDatosCarga CHAR (50);
DEFINE cBitCarga CHAR (50);
DEFINE vnum_cred CHAR (20);
DEFINE vnum_producto CHAR (4);
DEFINE vsucursal CHAR(4);
DEFINE vsaldo_cred DECIMAL(18,2);
DEFINE vreserva_calif DECIMAL(18,2);
DEFINE vreserva_int DECIMAL(18,2);
DEFINE vgrado_riesgo VARCHAR(3);
DEFINE vNvoPeriodo INTEGER;
DEFINE vDivisa CHAR(2);
DEFINE dtCargaAct DATETIME YEAR TO SECOND;
DEFINE dtCargaIni DATETIME YEAR TO SECOND;
DEFINE dtCargaFin DATETIME YEAR TO SECOND;
DEFINE wBegin                CHAR(1);
DEFINE cArchivo_dbld      CHAR(50);
DEFINE cArchivo_log       CHAR(50);
DEFINE dtFechaHoy			DATE;
DEFINE dtFechaPase    DATE;
DEFINE cMensajeRet 		CHAR(50);
DEFINE cMensajeRetP		CHAR(50);
DEFINE iExiste			INTEGER;
DEFINE v_band_regcontab	INTEGER;
DEFINE v_band_tdc	INTEGER;
DEFINE v_band_pp	INTEGER;
DEFINE v_cod_param CHAR(3);
DEFINE v_band_sdo1	INTEGER;
DEFINE v_band_sdo2	INTEGER;
DEFINE v_band_sdo3	INTEGER;
DEFINE contador_commit   INTEGER;
DEFINE val_trans_Commit   SMALLINT;

LET iSqlErr = 0;
LET cCodRet = '000001';
LET cCodRetP = '00000';
LET cCadena = '';
LET cRuta = '';
LET cDatosCarga = '';
LET cBitCarga = '';
LET vnum_cred = '';
LET vnum_producto ='';
LET vsucursal ='';
LET vsaldo_cred =0;
LET vreserva_calif =0;
LET vreserva_int =0;
LET vgrado_riesgo ='';
LET vNvoPeriodo =0;
LET vDivisa ='';
LET wBegin = '';
LET dtCargaAct = CURRENT;
LET cArchivo_dbld    = "f_datoscarga.com";
LET cArchivo_log     = "f_datoscarga.log";
LET vsucursal = '';
LET dtFechaHoy			= DATE(1);
LET dtFechaPase		= DATE(1);
LET cMensajeRet 		= '';
LET cMensajeRetP 		= 'PROCESO EXITOSO';
LET iExiste			=0;
LET v_band_regcontab	=0;
LET v_band_tdc	=0;
LET v_band_pp	=0;
LET v_cod_param ='';
LET  v_band_sdo1 = 0;
LET  v_band_sdo2 = 0;
LET  v_band_sdo3 = 0;
LET contador_commit   =0;
LET val_trans_Commit  =0;


BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
		END IF;
		
		IF (val_trans_Commit = -1) THEN
		        rollback work;
        END IF;
	END EXCEPTION;
   	
   SET LOCK MODE TO WAIT 3;

  --SET DEBUG FILE TO '/resplogifx/archivoscontabilidad/sp_carga_datos_reg.out';
  --TRACE ON;

    LET cBitCarga="bit_";
    LET cRuta="/resplogifx/archivoscontabilidad/";                                              
 
	--SE OBTIENE LA FECHA HOY.
	SELECT fecha_hoy, pri_dia_mes - 1 units day 
	INTO dtFechaHoy, dtFechaPase
	  FROM "informix".sd_fechas WHERE empresa = '001';	
	  
	IF NVL(cRuta,'') <> '' THEN
	
				
		FOREACH WITH HOLD
			SELECT valor, cod_param INTO cDatosCarga, v_cod_param
			FROM sd_param 
			WHERE cod_param IN('RS1','RS2','RS3','RS4','RS5','RS6')		

					
			IF NVL(cDatosCarga,'') <> '' THEN
				LET cDatosCarga = TRIM(cDatosCarga)||YEAR(dtFechaHoy)||LPAD(MONTH(dtFechaHoy),2,0)||'.unl';                
				LET cBitCarga= TRIM(cBitCarga)||TRIM(cDatosCarga);
				TRUNCATE TABLE sd_cargadatosregcontab;
											
				
			   system ' echo "FILE ' ||  TRIM(cRuta) ||  TRIM(cDatosCarga) ||' DELIMITER '|| "'" || '|' || "'" || ' 5;' || '">' || TRIM(cRuta) || TRIM(cArchivo_dbld);  
			   system ' echo "INSERT INTO sd_cargadatosregcontab;' || '">>' || TRIM(cRuta) || TRIM(cArchivo_dbld);
			   system 'chmod 777 ' || TRIM(cRuta) || TRIM(cArchivo_dbld);

			   system ' echo "date ' || '">' || TRIM(cRuta) || 'dbload_datoscarga.sh';
			   system ' echo "dbload -d bdicred -c ' || TRIM(cRuta) || TRIM(cArchivo_dbld)  ||' -l ' || TRIM(cRuta) || TRIM(cArchivo_log) || ' -n 1000 ' || ' " >> ' || TRIM(cRuta)|| 'dbload_datoscarga.sh'; 
			   system ' echo "date ' || '">>' || TRIM(cRuta)|| 'dbload_datoscarga.sh';
			   system ' echo "dbaccess bdicred -<<EOF ' || '">>' || TRIM(cRuta)|| 'dbload_datoscarga.sh';             
			   system ' echo "set pdqpriority 0;' || '">>' || TRIM(cRuta)|| 'dbload_datoscarga.sh';          
			   system ' echo "update statistics medium for table sd_cargadatosregcontab; ' || '">>' || TRIM(cRuta)|| 'dbload_datoscarga.sh';           
			   system ' echo "EOF' || '">>' || TRIM(cRuta)|| 'dbload_datoscarga.sh';           
			   system 'chmod 777 ' || TRIM(cRuta)|| 'dbload_datoscarga.sh';
			   system '/usr/bin/sh ' || TRIM(cRuta)|| 'dbload_datoscarga.sh';     
				
				LET cCodRet = '000000';
			ELSE
				LET cCodRet = '000002';
			END IF;			
					
			IF cCodRet = '000000' THEN 	
				
				SELECT COUNT(*) INTO iExiste
				FROM sd_cargadatosregcontab;
					
				IF iExiste>0 THEN	
					IF v_cod_param='RS1' THEN
						DELETE FROM sd_datosregcontab WHERE num_producto = '7800' and fecha_reg=dtFechaHoy;
						DELETE FROM sd_movhis_calif WHERE num_producto ='7800' AND empresa='001' AND num_credito is not null AND fecha_mov=dtFechaPase;
					ELIF v_cod_param='RS2' THEN	
						DELETE FROM sd_datosregcontab WHERE num_producto= '6400' and fecha_reg=dtFechaHoy;
						DELETE FROM sd_movhis_calif_cnr WHERE num_producto= '6400' AND fecha_mov=dtFechaPase;
					ELIF v_cod_param='RS3' THEN	
						DELETE FROM sd_datosregcontab WHERE num_producto IN('6300','7600','7700') and fecha_reg=dtFechaHoy;
						DELETE FROM sd_movhis_calif_cnr WHERE num_producto IN('6300','7600','7700') AND empresa='001' AND num_credito is not null AND fecha_mov=dtFechaPase;
					ELIF v_cod_param='RS4' THEN	
						DELETE FROM sd_datosregcontab WHERE num_producto ='6800' and fecha_reg=dtFechaHoy;
						DELETE FROM sd_movhis_calif_cnr WHERE num_producto= '6800' AND empresa='001' AND num_credito is not null AND fecha_mov=dtFechaPase;
					ELIF v_cod_param='RS5' THEN
						DELETE FROM sd_datosregcontab WHERE num_producto ='6011' and fecha_reg=dtFechaHoy;
						DELETE FROM sd_movhis_calif_cnr WHERE num_producto = '6011' AND empresa='001' AND num_credito is not null AND fecha_mov=dtFechaPase;
					ELIF v_cod_param='RS6' THEN	
						DELETE FROM sd_datosregcontab WHERE num_producto IN('6001','7000','8100','8500') and fecha_reg=dtFechaHoy;
						DELETE FROM sd_movhis_calif WHERE num_producto IN ('6001','7000','8100','8500') AND empresa='001' AND num_credito is not null AND fecha_mov=dtFechaPase;
					END IF;
						
					FOREACH WITH HOLD
						
						SELECT  num_credito,saldo_cred,reserva_calif,reserva_int,  nvl(replace(replace(grado_riesgo, '"|"'," "), '"\"'," ")," ") 
						INTO vnum_cred,vsaldo_cred,vreserva_calif,vreserva_int,vgrado_riesgo
						FROM sd_cargadatosregcontab 
						
						IF (val_trans_Commit = 0) THEN
							BEGIN WORK;
							LET contador_commit = 0;
							LET val_trans_Commit = -1;
						END IF;         
			
						IF (SELECT COUNT(*) FROM bdicred:sd_maecred WHERE num_credito=vnum_cred) > 0 THEN
							SELECT num_producto,sucursal,divisa
							INTO vnum_producto,vsucursal,vDivisa
							FROM bdicred:sd_maecred 						
							WHERE num_credito=vnum_cred;
						ELSE
							SELECT num_producto,sucursal,divisa
							INTO vnum_producto,vsucursal,vDivisa
							FROM bdicred:sd_maecredcrd						
							WHERE num_credito=vnum_cred;
						END IF;											
						
						LET v_band_regcontab=0;
						LET cCodRet='00000';
						LET cMensajeRet='';
						
						--Determina GRADO RIESGO Bancoppel
						IF trim(vgrado_riesgo)= 'A-1' THEN
							LET vNvoPeriodo= 0;
						ELIF trim(vgrado_riesgo)= 'A-2' THEN
							LET vNvoPeriodo= 1;
						ELIF trim(vgrado_riesgo)= 'B-1' THEN
							LET vNvoPeriodo= 2;
						ELIF trim(vgrado_riesgo)= 'B-2' THEN
							LET vNvoPeriodo= 3;
						ELIF trim(vgrado_riesgo)= 'B-3' THEN
							LET vNvoPeriodo= 4;
						ELIF trim(vgrado_riesgo)= 'C-1' THEN
							LET vNvoPeriodo= 5;
						ELIF trim(vgrado_riesgo)= 'C-2' THEN
							LET vNvoPeriodo= 6;
						ELIF trim(vgrado_riesgo) matches '[D]*' THEN
							LET vNvoPeriodo= 7;
						ELIF trim(vgrado_riesgo) matches '[E]*' THEN
							LET vNvoPeriodo= 8;
						END IF;
						
						IF vnum_producto IN('6001','7000','7800','8100','8500') THEN
							IF vReserva_calif>0 THEN
								LET v_band_sdo1=0;
								
							-- Genera Movimiento para Contabilidad					
								EXECUTE PROCEDURE genmov_calif ('001',
															   vnum_cred,
															   vnum_producto,
															   vNvoPeriodo,
															   "091",
															   dtFechaPase,
															   vReserva_calif,
															   "CalifCartReserva",
															   vSucursal,
															   vDivisa,
															   "0000")  
								INTO cCodRet, cMensajeRet;
								IF TRIM(cCodRet) <> "00000" THEN
									LET v_band_regcontab=0;						
								ELSE
									LET v_band_regcontab=1;
								END IF;
							ELSE
								LET v_band_sdo1=1;
							END IF;
														
							IF vsaldo_cred > 0 THEN
								LET cMensajeRet='';
								LET v_band_sdo2=0;

								EXECUTE PROCEDURE genmov_calif ('001',
															  vnum_cred,
															  vnum_producto,
															  vNvoPeriodo,
															  "090",
															  dtFechaPase,
															  vsaldo_cred,
															  "CalifCart",
															  vSucursal,
															  vDivisa,
															  "0000")
								INTO cCodRet, cMensajeRet;
								IF TRIM(cCodRet) <> "00000" THEN
									LET v_band_regcontab=0;								
								ELSE
									LET v_band_regcontab=2;
								END IF;
							ELSE
								LET v_band_sdo2=1;
							END IF;									
						
							IF vReserva_int > 0 THEN
									LET cMensajeRet='';
									LET v_band_sdo3=0;
									EXECUTE PROCEDURE genmov_calif('001',
															  vnum_cred,
															  vnum_producto,
															  0,
															  "094",
															  dtFechaPase,
															  vReserva_int,
															  "CalifCart",
															  vSucursal,
															  vDivisa,
															  "0000")
									INTO cCodRet, cMensajeRet;
									IF TRIM(cCodRet) <> "00000" THEN
										LET v_band_regcontab=0;
									ELSE
										LET v_band_regcontab=3;
									END IF;
							ELSE
								LET v_band_sdo3=1;
							END IF;
						ELIF vnum_producto IN('6011') THEN
							IF vReserva_calif > 0 THEN	
								
								LET v_band_sdo1=0;
							-- Genera Movimiento para Contabilidad					
								EXECUTE PROCEDURE genmov_calif_cnr ('001',
															   vnum_cred,
															   vnum_producto,
															   vNvoPeriodo,
															   "091",
															   dtFechaPase,
															   vReserva_calif,
															   "CalifCartReserva",
															   vSucursal,
															   vDivisa,
															   "0000")  
								INTO cCodRet, cMensajeRet;
								IF TRIM(cCodRet) <> "00000" THEN
									LET v_band_regcontab=0;						
								ELSE
									LET v_band_regcontab=1;
								END IF;
							ELSE
								LET v_band_sdo1=1;
							END IF;							
							
							IF vsaldo_cred>0 THEN
								LET cMensajeRet='';
								LET v_band_sdo2=0;
								EXECUTE PROCEDURE genmov_calif_cnr ('001',
															  vnum_cred,
															  vnum_producto,
															  vNvoPeriodo,
															  "090",
															  dtFechaPase,
															  vsaldo_cred,
															  "CalifCart",
															  vSucursal,
															  vDivisa,
															  "0000")
								INTO cCodRet, cMensajeRet;
								IF TRIM(cCodRet) <> "00000" THEN
									LET v_band_regcontab=0;								
								ELSE
									LET v_band_regcontab=2;
								END IF;
							ELSE
								LET v_band_sdo2=1;
							END IF;							
							
							IF vReserva_int > 0 THEN
									LET cMensajeRet='';
									LET v_band_sdo3=0;
									EXECUTE PROCEDURE genmov_calif_cnr('001',
															  vnum_cred,
															  vnum_producto,
															  0,
															  "094",
															  dtFechaPase,
															  vReserva_int,
															  "CalifCart",
															  vSucursal,
															  vDivisa,
															  "0000")
									INTO cCodRet, cMensajeRet;
									IF TRIM(cCodRet) <> "00000" THEN
										LET v_band_regcontab=0;
									ELSE
										LET v_band_regcontab=3;										
									END IF;
							ELSE
								LET v_band_sdo3=1;
							END IF;							
						ELSE
							IF vReserva_calif > 0 THEN	
								
								LET v_band_sdo1=0;
							-- Genera Movimiento para Contabilidad					
								EXECUTE PROCEDURE genmov_calif_cnr ('001',
															   vnum_cred,
															   vnum_producto,
															   vNvoPeriodo,
															   "101",
															   dtFechaPase,
															   vReserva_calif,
															   "CalifCartReserva",
															   vSucursal,
															   vDivisa,
															   "0000")  
								INTO cCodRet, cMensajeRet;
								IF TRIM(cCodRet) <> "00000" THEN
									LET v_band_regcontab=0;						
								ELSE
									LET v_band_regcontab=1;
								END IF;
							ELSE	
								LET v_band_sdo1=1;
							END IF;							
							
							IF vsaldo_cred>0 THEN
								LET cMensajeRet='';
								LET v_band_sdo2=0;
								EXECUTE PROCEDURE genmov_calif_cnr ('001',
															  vnum_cred,
															  vnum_producto,
															  vNvoPeriodo,
															  "100",
															  dtFechaPase,
															  vsaldo_cred,
															  "CalifCart",
															  vSucursal,
															  vDivisa,
															  "0000")
								INTO cCodRet, cMensajeRet;
								IF TRIM(cCodRet) <> "00000" THEN
									LET v_band_regcontab=0;								
								ELSE
									LET v_band_regcontab=2;
								END IF;
							ELSE
								LET v_band_sdo2=1;
							END IF;							
							
							IF vReserva_int > 0 THEN
									LET cMensajeRet='';
									LET v_band_sdo3=0;
									EXECUTE PROCEDURE genmov_calif_cnr('001',
															  vnum_cred,
															  vnum_producto,
															  0,
															  "104",
															  dtFechaPase,
															  vReserva_int,
															  "CalifCart",
															  vSucursal,
															  vDivisa,
															  "0000")
									INTO cCodRet, cMensajeRet;
									IF TRIM(cCodRet) <> "00000" THEN
										LET v_band_regcontab=0;
									ELSE
										LET v_band_regcontab=3;										
									END IF;
							ELSE
								LET v_band_sdo3=1;
							END IF;						
						END IF;
						
						IF v_band_sdo1=1 AND v_band_sdo2=1 AND v_band_sdo3=1 THEN
							LET cCodRet='00001';
							LET cMensajeRet='SALDOS EN CEROS';
							LET v_band_sdo1=0;
							LET v_band_sdo2=0;
							LET v_band_sdo3=0;
						END IF;
						
						INSERT INTO sd_datosregcontab(num_credito,saldo_cred,reserva_calif,reserva_int,grado_riesgo,num_producto,sucursal,fecha_reg,band_regcontab,cod_ret,descripcion)
						VALUES(vnum_cred,vsaldo_cred,vReserva_calif,vReserva_int,trim(vgrado_riesgo),vnum_producto,vSucursal,dtFechaHoy,v_band_regcontab,cCodRet,cMensajeRet);
	
						LET contador_commit = contador_commit  + 1;
			
						IF (contador_commit >= 5000) THEN
							COMMIT WORK;
							LET contador_commit = 0; 
							BEGIN WORK;
						END IF;     
					END FOREACH 
					IF val_trans_Commit = -1 THEN
						COMMIT WORK;
						LET contador_commit = 0;
						LET val_trans_Commit = 0;
					END IF;
					LET cCadena = '';
					LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitCarga)  ||'  delimiter ''|'' SELECT * FROM bdicred:"informix".sd_datosregcontab where fecha_reg='''||dtFechaHoy||''' and num_credito in(SELECT num_credito From sd_cargadatosregcontab)" >'||TRIM(cRuta)||'bit_carga.sql';
					SYSTEM cCadena;				
					LET cCadena='chmod 777 '|| TRIM(cRuta)||'bit_carga.sql';
					System cCadena;				
					let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bit_carga.sql';
					System cCadena;				
					LET cCadena = '' ;
					LET cCadena = 'rm ' || TRIM(cRuta) || 'bit_carga.sql';
					SYSTEM cCadena;	
					
				ELSE 
					LET cDatosCarga = '';                
					LET cBitCarga="bit_";
					CONTINUE FOREACH;
				END IF;
			END IF;
			
			LET cDatosCarga = '';                
			LET cBitCarga="bit_";
					
		END FOREACH		
		
	END IF;
	RETURN cCodRetP, cMensajeRetP;
END
END PROCEDURE
DOCUMENT
'',
'AUTOR : CONCEPCION ALVAREZ CARRILLO',
'FECHA : 29/oct/2019',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_pases_regcontab() 
RETURNING CHAR(6), CHAR(50);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE dtFechaHoy			DATE;
DEFINE dtFechaPase    DATE;
DEFINE cMensajeRet 		CHAR(50);


LET iSqlErr = 0;
LET cCodRet = '000001';
LET dtFechaHoy			= DATE(1);
LET dtFechaPase		= DATE(1);
LET cMensajeRet 		= '';



BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
		END IF;
	END EXCEPTION;
   	
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/resplogifx/archivoscredito/sp_pases_regcontab.out';
	--TRACE ON;

    
	--SE OBTIENE LA FECHA HOY.
	SELECT fecha_hoy, pri_dia_mes - 1 units day 
	INTO dtFechaHoy, dtFechaPase
	  FROM "informix".sd_fechas WHERE empresa = '001';	
	  
	
	EXECUTE PROCEDURE bdicred:"informix".pasecont_movcalif('001',dtFechaPase,dtFechaHoy,'informix','califcar','PaseCont') 
	INTO cCodRet, cMensajeRet;

	EXECUTE PROCEDURE bdicred:"informix".paseprest_movcalif('001',dtFechaPase,dtFechaHoy,'informix','califcnr','PaseCont') 
	INTO cCodRet, cMensajeRet;

	IF cCodRet <> '000' THEN
		RETURN cCodRet, cMensajeRet;
	ELSE			
		LET cMensajeRet='SE REALIZARON LOS PASES CORRECTAMENTE';
	END IF;
	RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT
'',
'AUTOR : CONCEPCION ALVAREZ CARRILLO',
'FECHA : 29/oct/2019',
'BD    : BDICRED';

CREATE PROCEDURE "informix".pasecont_movcalif(pempresa     CHAR(3),
                                     fecha_pase   DATE,
									 pfecha_captura DATE,
                                     pusuario     CHAR(8),
                                     pusuariopase CHAR(8),
                                     pproceso     CHAR(10))
   RETURNING CHAR(5), varchar(80);

   DEFINE wcod_ret                      CHAR(5);
   DEFINE P_MENSAJE                     VARCHAR(80);
   DEFINE sql_err                       SMALLINT;
   DEFINE isam_err                      SMALLINT;
   DEFINE error_info                    CHAR(40);
   DEFINE v_error                       smallint;

   DEFINE wbegin                        CHAR(1);
   DEFINE wusuario                      CHAR(8);
   DEFINE wejecutivo                    CHAR(8);
   DEFINE wfecha_hoy                    DATE;
   DEFINE nrows                         SMALLINT;
   DEFINE wproceso                      CHAR(10);
   DEFINE valor_cambio                  DECIMAL(6,4);
   DEFINE wdivisa_cambio                CHAR(2);
   DEFINE wsecuenciamn                  INTEGER;
   DEFINE wsecuenciadl                  INTEGER;
   DEFINE wnro_auxiliar                 CHAR(9);
   DEFINE wdescripcion_det              CHAR(50);
   DEFINE wnumpolmn                     SMALLINT;
   DEFINE wnumpoldl                     SMALLINT;
   DEFINE wfecha                        CHAR(10);
   DEFINE wbanco                        CHAR(3);

{****************************************************************************
 **         INICIA REGISTRO DE PASE CONTABLE                               **
 ****************************************************************************}

   DEFINE wregional                     CHAR(3);
   DEFINE wsucursal                     CHAR(4);
   DEFINE wdivisa                       CHAR(2);
   DEFINE wcodigo_fun                   CHAR(3);
   DEFINE wcodigo_ref                   SMALLINT;
   DEFINE wnum_cuota                    SMALLINT;
   DEFINE wtransacc                     CHAR(4);
   DEFINE wapell_paterno                CHAR(15);
   DEFINE wapell_materno                CHAR(15);
   DEFINE wnombre1                      CHAR(15);
   DEFINE wnombre2                      CHAR(15);
   DEFINE wrazon_social                 CHAR(40);
   DEFINE wabreviatura                  CHAR(50);
   DEFINE wsecuencia                    SMALLINT;
   DEFINE wvaloriza                     CHAR(1);
   DEFINE wcmayor                       CHAR(4);
   DEFINE wcsub1                        CHAR(3);
   DEFINE wcsub2                        CHAR(3);
   DEFINE wcsub3                        CHAR(3);
   DEFINE wcsub4                        CHAR(3);
   DEFINE wcsector                      CHAR(3);

   DEFINE wamayor                       CHAR(4);
   DEFINE wasub1                        CHAR(3);
   DEFINE wasub2                        CHAR(3);
   DEFINE wasub3                        CHAR(3);
   DEFINE wasub4                        CHAR(3);
   DEFINE wasector                      CHAR(3);

   DEFINE wmonto                        MONEY(14,2);
{****************************************************************************
 **      TERMINA REGISTRO DE PASE CONTABLE                                 **
 **      INICIA REGISTRO DETPOL                                            **
 ****************************************************************************}

   DEFINE detusuario                    CHAR(11);
   DEFINE detcontrol_poliza             SMALLINT;
   DEFINE detfecha_captura              DATE;
   DEFINE detsecuencia                  INTEGER;
   DEFINE detempresa                    CHAR(3);
   DEFINE detmayor                      CHAR(4);
   DEFINE detsub1                       CHAR(3);
   DEFINE detsub2                       CHAR(3);
   DEFINE detsub3                       CHAR(3);
   DEFINE detsub4                       CHAR(3);
   DEFINE detsector                     CHAR(3);
   DEFINE detciudad                     CHAR(3);
   DEFINE detsucursal                   CHAR(4);
   DEFINE detnro_auxiliar               CHAR(9);
   DEFINE detnaturaleza                 CHAR(1);
   DEFINE detmonto                      MONEY(14,2);
   DEFINE detdescripcion_det            CHAR(50);
   DEFINE detfecha_valida               DATE;
   DEFINE detmoneda                     CHAR(2);
   DEFINE detvalor_cambio               MONEY(12,7);
   DEFINE detvalor_div_cambio           MONEY(12,7);
   DEFINE detmca_aplica                 CHAR(1);
   DEFINE detpoliza_usuario             CHAR(11);
   DEFINE dettipo_mov                   CHAR(1);
   
{***************************************************************************
 **   TERMINA REGISTRO DE DETPOL                                          **
 **   INICIA REGISTRO DE ENCABEZADO DE POLIZA                             **
 ***************************************************************************}

   DEFINE polcifra_control              MONEY(14,2);
   DEFINE polcargo                      MONEY(14,2);
   DEFINE polabono                      MONEY(14,2);
{***************************************************************************
 **   TERMINA REGISTRO DE ENCABEZADO DE POLIZA                            **
 ***************************************************************************}

   DEFINE wsectoriza                    CHAR(1);
   DEFINE dsecuencia                    INTEGER;
   DEFINE dcontrol_poliza               SMALLINT;
   DEFINE wsucorigen			CHAR(4);
   DEFINE dccosto_orig			CHAR(4);
   DEFINE icontador INTEGER;


   ON EXCEPTION SET sql_err, isam_err, error_info
      LET wcod_ret = sql_err;
      SET DEBUG FILE TO "pasecont.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      IF (wbegin = "S") THEN
         ROLLBACK WORK;
         BEGIN WORK;
      ELSE
         ROLLBACK WORK;
      END IF;
      RETURN wcod_ret, P_MENSAJE;
   END EXCEPTION;


   ON EXCEPTION IN (-535)
      LET wbegin = "S";
      ROLLBACK WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

--  SET DEBUG FILE TO "pasecont.out";
--  TRACE ON;


   LET wbegin = "S";
   LET wnum_cuota = 0;
   LET wproceso = ""; --NULL;
   LET P_MENSAJE = 'PROCESO EXITOSO';
   
   --LET detusuario = 'credito';
   LET detusuario = pusuariopase;
    LET icontador=1;

   BEGIN WORK;
      LET wcod_ret = "000";
      LET wproceso = pproceso;  -- "PaseCont";
 
	let fecha_pase = fecha_pase;	

      IF fecha_pase IS NULL OR fecha_pase = " "THEN
         SELECT fecha_hoy
           INTO wfecha_hoy
           FROM sd_fechas
          WHERE empresa = pempresa;
      ELSE
	LET wfecha_hoy = fecha_pase;
      END IF


      IF pusuariopase IS NULL OR pusuariopase = " " THEN
         LET wcod_ret = "821";
         RETURN wcod_ret, P_MENSAJE;
      END IF

--      SELECT proceso
--        INTO wproceso
--        FROM sd_contproc
--       WHERE empresa = pempresa
--         AND proceso = wproceso
--         AND fecha = fecha_pase;

      SELECT proceso
        INTO wproceso
        FROM bdinteg:sx_contproc
       WHERE empresa = pempresa
         AND proceso = wproceso
         AND sistema = "06"
         AND fecha = fecha_pase;


      --borra lo existente en la base de contabilidad
      delete from bdicont:co_poldet
       where empresa = pempresa
         and fecha_captura = fecha_pase
         and usuario = pusuariopase;   --'credito';

      delete from bdicont:co_detpol
       where empresa = pempresa
         and fecha_captura = fecha_pase
         and usuario = pusuariopase;   --'credito';

      delete from bdicont:co_poliza
       where empresa = pempresa
         and fecha_captura = fecha_pase
         and usuario = pusuariopase;   --'credito';

      SELECT ejecutivo
        INTO wejecutivo
        FROM bdinteg:si_ejecut
       WHERE empresa = pempresa
         AND ejecutivo = pusuario;

      LET nrows = dbinfo("sqlca.sqlerrd2");

      IF (nrows = 0) THEN
         LET wcod_ret = "090";
         LET P_MENSAJE = 'Usuario no Valido para ejecutar el proceso';
         IF (wbegin = "S") THEN
            ROLLBACK WORK;
            BEGIN WORK;
         ELSE
            ROLLBACK WORK;
         END IF;
         RETURN wcod_ret, P_MENSAJE;
      END IF;

      if wproceso is NULL then

        LET wproceso = pproceso;   --"PaseCont";

        INSERT INTO sd_contproc
        VALUES (pempresa, wproceso, fecha_pase, "I", USER,
                CURRENT, CURRENT, "  ", "Proceso Iniciado");
                
        INSERT INTO bdinteg:sx_contproc 
	   (empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,
	    hora_fin,codret)
        VALUES 
	   (pempresa, wproceso, fecha_pase, "06","I", USER,CURRENT, 
	    CURRENT, "  ");
                
      else
        UPDATE sd_contproc
               set ejecutivo = user
                  ,hora_inicio = current
                  ,hora_fin = current
                  ,status_proc = 'I'
                  ,mensaje = 'PROCESO INICIADO'
        WHERE empresa = pempresa
        AND   proceso = wproceso
        AND   fecha = fecha_pase;
        
        UPDATE bdinteg:sx_contproc
               set ejecutivo = user
                  ,hora_ini = current
                  ,hora_fin = current
                  ,status_proc = 'I'
        WHERE empresa = pempresa
        AND   proceso = wproceso
        AND   sistema = "06"
        AND   fecha = fecha_pase;

      end if;

   commit work;
   LET wbegin = "N";

{************************************************************************
 ** INICIA CREACION DE TABLAS TEMPORALES Y CARGA DE PARAMETROS         **
 ** NECESARIOS PARA EL PASE CONTABLE                                   **
 ************************************************************************}

      CREATE TEMP TABLE tdetpol
         ( usuario               CHAR(11)  NOT NULL ,
          control_poliza        SMALLINT NOT NULL ,
          fecha_captura         DATE     NOT NULL ,
          secuencia             INTEGER  NOT NULL ,
          empresa               CHAR(3),
          ccmayor               CHAR(4),
          ccsub                 CHAR(3),
          ccsubsub              CHAR(3),
          ccssubsub             CHAR(3),
          ccsssubsub            CHAR(3),
          sector                CHAR(3),
          ciudad                CHAR(3),
          sucursal              CHAR(4),
          nro_auxiliar          CHAR(9),
          naturaleza            CHAR(1),
          monto                 MONEY(19,2),
          descripcion_det       CHAR(50),
          fecha_valida          DATE,
          moneda                CHAR(2),
          valor_cambio          MONEY(12,7),
          valor_div_cambio      MONEY(12,7),
          mca_aplic             CHAR(1),
          poliza_usuario        CHAR(11),
          tipo_mov              CHAR(1),
          ccosto_orig           CHAR(4)) with no log;

      SET ISOLATION TO DIRTY READ;

      SELECT valor
        INTO wbanco
        FROM bdinteg:si_param
       WHERE empresa = pempresa
         AND cod_param = "5";

      SELECT valor
        INTO wdivisa_cambio
        FROM bdinteg:si_param
       WHERE empresa = pempresa
         AND cod_param  = "17";

      SELECT tipo_cpa_mn_div
        INTO valor_cambio
        FROM bdinteg:si_tpcambio
       WHERE empresa = pempresa
         AND divisa = wdivisa_cambio
         AND fecha_tpcambio = wfecha_hoy
         AND clase_tpcambio = "O";

      LET nrows = dbinfo("sqlca.sqlerrd2");
      IF  (nrows = 0) THEN
      {   SELECT tipo_cpa_mn_div
           INTO valor_cambio
           FROM bdinteg:si_histdiv
          WHERE empresa = pempresa
            AND divisa = wdivisa_cambio
            AND fecha_tc = wfecha_hoy
            AND clase_tpcambio = "O";}

         LET nrows = dbinfo("sqlca.sqlerrd2");
--         IF (nrows = 0) THEN
--            LET wcod_ret ="017";
--            IF (wbegin = "S") THEN
--               ROLLBACK WORK;
--               BEGIN WORK;
--            ELSE
--               ROLLBACK WORK;
--            END IF;
--            RETURN wcod_ret, P_MENSAJE;
--         END IF;
      END IF;

      LET wusuario = pusuariopase;   --"credito";  
      LET wsecuenciamn = 1;
      LET wsecuenciadl = 1;
      LET wnro_auxiliar = " ";
      LET wdescripcion_det = "MOVIMIENTOS DE CREDITO DEL DIA ";
      LET wfecha = wfecha_hoy;
      LET wdescripcion_det = TRIM(wdescripcion_det)||" "||TRIM(wfecha);

      SELECT MAX(control_poliza)
        INTO wnumpolmn
        FROM bdicont:co_detpol
       WHERE usuario = wusuario
         AND fecha_captura = wfecha_hoy
         AND moneda = "00"
         AND empresa = pempresa;

      IF (wnumpolmn IS NULL or wnumpolmn = 0) THEN
         LET wnumpolmn = 1;
      ELSE
         LET wnumpolmn = wnumpolmn + 1;
      END IF;

      LET wnumpoldl = wnumpolmn + 1;
      IF pusuariopase = "califcar" OR pusuariopase  = "canccart" then
        SELECT c.regional, a.suc_origen, a.codigo_fun, a.codigo_ref,
                a.divisa, sum(a.monto) monto, a.sucursal,b.num_producto
           FROM sd_movhis_calif a,sd_maecred b,bdinteg:si_plazas c
          WHERE a.empresa = pempresa
            AND a.empresa = b.empresa
            AND a.num_credito = b.num_credito
            AND a.plaza = c.plaza
			AND c.empresa=a.empresa
            AND a.reversado = 'N'
            AND TRIM(a.folio_suc) IN ("CalifCartReserva","CalifCart")
            AND a.fecha_mov = fecha_pase
            AND a.monto > 0
            group by 1,2,3,4,5,7,8
		UNION
		SELECT c.regional, a.suc_origen, a.codigo_fun, a.codigo_ref,
                a.divisa, sum(a.monto) monto, a.sucursal,b.num_producto
           FROM sd_movhis_calif_cnr a,sd_maecredcrd b,bdinteg:si_plazas c
          WHERE a.empresa = pempresa
            AND a.empresa = b.empresa
            AND a.num_credito = b.num_credito
            AND a.plaza = c.plaza
			AND c.empresa=a.empresa
            AND a.reversado = 'N'
            AND TRIM(a.folio_suc) IN ("CalifCartReserva","CalifCart")
            AND a.fecha_mov = fecha_pase
            AND a.monto > 0
			AND a.num_producto='6011'
            group by 1,2,3,4,5,7,8
           INTO TEMP x WITH NO LOG;
      ELSE
         SELECT c.regional, a.suc_origen, a.codigo_fun, a.codigo_ref,
                a.divisa, sum(monto) monto, a.sucursal,b.num_producto
           FROM sd_movhis a, sd_maecred b, bdinteg:si_plazas c
          WHERE a.empresa = pempresa
            AND a.empresa = b.empresa
            AND a.num_credito = b.num_credito
            AND a.plaza = c.plaza
			AND c.empresa=a.empresa
            AND a.reversado = 'N'
            AND TRIM(a.folio_suc) NOT IN ("CalifCartReserva","CalifCart")
            AND a.fecha_mov =fecha_pase
            AND a.monto > 0
            group by 1,2,3,4,5,7,8
           INTO TEMP x WITH NO LOG;
      END IF


      FOREACH
         SELECT a.regional, a.sucursal, a.divisa, a.codigo_fun, a.codigo_ref,
                a.suc_origen, c.descripcion, d.secuencia, c.valoriza,
                d.c_ccmayor, d.c_ccsub, d.c_ccsubsub, d.c_ccsssub,
                d.c_ccssssub, d.c_sector, d.a_ccmayor, d.a_ccsub,
                d.a_ccsubsub, d.a_ccsssub, d.a_ccssssub, d.a_sector,a.monto
           INTO wregional, wsucursal, wdivisa, wcodigo_fun,
                wcodigo_ref, wsucorigen, wabreviatura, wsecuencia, wvaloriza, 
	            wcmayor, wcsub1, wcsub2, wcsub3, wcsub4, wcsector,
                wamayor, wasub1, wasub2, wasub3, wasub4, wasector,
                wmonto
           FROM x a, sd_transfun b,bdinteg:si_transacc c, bdinteg:si_prodtran d
          WHERE b.empresa= pempresa
            AND b.codigo_fun=a.codigo_fun
            AND b.codigo_ref=a.codigo_ref
            AND c.empresa = b.empresa
            AND c.numero = b.transacc
            AND c.sistema = "06"
            AND d.empresa = b.empresa
            AND d.producto = a.num_producto
            AND d.sistema = c.sistema
            AND d.transaccion = b.transacc
            AND d.secuencia>0
          ORDER BY 1,2,3,4,5,6

            LET wdescripcion_det = wabreviatura;

            IF (wvaloriza = "S" AND wsecuencia = 2
                AND wdivisa <> "00") THEN
               LET wmonto = wmonto * valor_cambio;
               LET wdivisa = "00";
            END IF;

            IF (wdivisa = "00") THEN
               LET dsecuencia = wsecuenciamn;
               LET dcontrol_poliza = wnumpolmn;
               LET wsecuenciamn = wsecuenciamn + 1;
            ELSE
               LET dsecuencia = wsecuenciadl;
               LET dcontrol_poliza = wnumpoldl;
               LET wsecuenciadl = wsecuenciadl + 1;
            END IF;


   LET wcmayor = trim(wcmayor);
   IF wcmayor[1,2] = "95" THEN

           INSERT INTO tdetpol VALUES
               (
                wusuario,
                dcontrol_poliza,
                pfecha_captura,
                dsecuencia,
                "001",
                wcmayor,
                wcsub1,
                wcsub2,
                wcsub3,
                wcsub4,
                wcsector,
                wregional,
                wsucursal,
                wnro_auxiliar,
                "D",
                wmonto,
                wdescripcion_det,
                wfecha_hoy,
                wdivisa,
                0,
                0,
                " ",
                wusuario,
                " ",
                wsucursal 
	--	wsucorigen
               );
   ELSE
     
           INSERT INTO tdetpol VALUES
               (
                wusuario,
                dcontrol_poliza,
                pfecha_captura,
                dsecuencia,
                "001",
                wcmayor,
                wcsub1,
                wcsub2,
                wcsub3,
                wcsub4,
                wcsector,
                wregional,
--                wsucursal,
                wsucorigen,
                wnro_auxiliar,
                "D",
                wmonto,
                wdescripcion_det,
                wfecha_hoy,
                wdivisa,
                0,
                0,
                " ",
                wusuario,
                " ",
--                wsucorigen
                wsucursal
               );
  
   END IF; 

            IF (wdivisa = "00") THEN
               LET dsecuencia = wsecuenciamn;
               LET dcontrol_poliza = wnumpolmn;
               LET wsecuenciamn = wsecuenciamn + 1;
            ELSE
               LET dsecuencia = wsecuenciadl;
               LET dcontrol_poliza = wnumpoldl;
               LET wsecuenciadl = wsecuenciadl + 1;
            END IF;

  LET wamayor = trim(wamayor); 
  IF wamayor[1,2] = "95" THEN

            INSERT INTO tdetpol VALUES
               (
                wusuario,
                dcontrol_poliza,
                pfecha_captura,
                dsecuencia,
                "001",
                wamayor,
                wasub1,
                wasub2,
                wasub3,
                wasub4,
                wasector,
                wregional,
                wsucursal,
                wnro_auxiliar,
                "C",
                wmonto,
                wdescripcion_det,
                wfecha_hoy,
                wdivisa,
                0,
                0,
                " ",
                wusuario,
                " ",
                wsucursal
	--	wsucorigen
               );
   ELSE
            INSERT INTO tdetpol VALUES
               (
                wusuario,
                dcontrol_poliza,
                pfecha_captura,
                dsecuencia,
                "001",
                wamayor,
                wasub1,
                wasub2,
                wasub3,
                wasub4,
                wasector,
                wregional,
--                wsucursal,
                wsucorigen,
                wnro_auxiliar,
                "C",
                wmonto,
                wdescripcion_det,
                wfecha_hoy,
                wdivisa,
                0,
                0,
                " ",
                wusuario,
                " ",
--                wsucorigen
                wsucursal
               );
   END IF;

      END FOREACH;

      LET wsecuenciamn = 1;
      LET wsecuenciadl = 1;
      LET detsecuencia = 1;
      LET detvalor_cambio = 0;
      LET detvalor_div_cambio = 0;
      LET detmca_aplica = " ";
      LET dettipo_mov = " ";


      FOREACH with hold
         SELECT usuario, control_poliza, fecha_captura ,
            empresa, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub,
            sector, ciudad, sucursal, nro_auxiliar, naturaleza, sum(monto),
            descripcion_det, fecha_valida, moneda, ccosto_orig
         INTO detusuario, detcontrol_poliza, detfecha_captura,
            detempresa, detmayor, detsub1, detsub2, detsub3, detsub4,
            detsector, detciudad, detsucursal, detnro_auxiliar,
            detnaturaleza, detmonto, detdescripcion_det, detfecha_valida,
            detmoneda, dccosto_orig
         FROM
            tdetpol
         GROUP BY
            1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19
         ORDER BY
            11, 12, 5, 6, 7, 8, 9, 10

         IF (detmoneda = "00") THEN
            LET detcontrol_poliza = wnumpolmn;
            LET detsecuencia = wsecuenciamn;
            LET wsecuenciamn = wsecuenciamn + 1;
         ELSE
            LET detcontrol_poliza = wnumpoldl;
            LET detsecuencia = wsecuenciadl;
            LET wsecuenciadl = wsecuenciadl + 1;
         END IF;
            
        IF icontador=1 then
          BEGIN WORK;
        END IF;

         LET detpoliza_usuario = detusuario;
         INSERT INTO
            bdicont:co_poldet
         VALUES
           (detusuario,
            detfecha_captura,
            detsecuencia,
            detempresa,
            detmayor,
            detsub1,
            detsub2,
            detsub3,
            detsub4,
            detsector,
            detciudad,
            detsucursal,
			detnro_auxiliar,
            detnaturaleza,
            detmonto,
            detdescripcion_det,
            detfecha_valida,
            detmoneda,
	    	dccosto_orig);

    IF icontador>=70000 then
        COMMIT WORK; 
        LET icontador=1;
    ELSE
        LET icontador=icontador+1;
    END IF;

      END FOREACH;

  IF icontador > 1 THEN
        COMMIT WORK; 
  END IF;

      DROP TABLE tdetpol;
      DROP TABLE x;

--   IF (wbegin = "S") THEN
--      COMMIT WORK;
--      BEGIN WORK;
--   ELSE
--      COMMIT WORK;
--   END IF;

   --EJECUTA EL PROCESO DE AUDITOR
   EXECUTE PROCEDURE BDICONT:AUDITAPASE(pfecha_captura,PEMPRESA,detusuario)
           INTO WCOD_RET;

    IF wcod_ret = "00000" THEN
       LET wcod_ret = "000";
    END IF	

   let v_error = wcod_ret;

   IF v_error = 0 then
      UPDATE sd_contproc
      SET status_proc = "F",
          mensaje = 'PROCESO EXITOSO',
          hora_fin = CURRENT,
          cod_ret   = wcod_ret
      WHERE proceso = wproceso
      AND   empresa = pempresa
      AND   fecha = fecha_pase;
      
      UPDATE bdinteg:sx_contproc
      SET status_proc = "F",
          hora_fin = CURRENT,
          codret   = wcod_ret
      WHERE proceso = wproceso
      AND   empresa = pempresa
      AND   sistema = "06"
      AND   fecha = fecha_pase;

      
   ELSE
      UPDATE sd_contproc
      SET status_proc = "C",
          mensaje = 'ERROR: ' || P_MENSAJE,
          hora_fin = CURRENT,
          cod_ret   = wcod_ret
      WHERE proceso = wproceso
      AND   empresa = pempresa
      AND   fecha = fecha_pase;
      
      UPDATE bdinteg:sx_contproc
      SET status_proc = "C",
          hora_fin = CURRENT,
          codret   = wcod_ret
      WHERE proceso = wproceso
      AND   empresa = pempresa
      AND   sistema = "06"
      AND   fecha = fecha_pase;

      
   END IF;

--   commit work;
   RETURN wcod_ret, P_MENSAJE;

END PROCEDURE;