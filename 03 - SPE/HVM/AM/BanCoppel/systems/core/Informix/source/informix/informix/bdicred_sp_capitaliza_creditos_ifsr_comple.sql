CREATE PROCEDURE "informix".sp_capitaliza_creditos_ifsr_comple()
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
   DEFINE wbandera_apoyo 		CHAR(01);
   DEFINE StatusCred_apoyo   	CHAR(2);
   DEFINE numcte_apoyo			CHAR(9);
   DEFINE diferir_apoyo			INT;
   DEFINE SdoRetenido_apoyo		DECIMAL(14,2);
   DEFINE fecha_cont_apoyo		DATE;
   DEFINE sdo_trab4_apoyo		DECIMAL(14,2);
   
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
	DEFINE dSdoNvoPFSI, dSdoDiaPFSI, dSdoHistPFSI		DECIMAL(14,2);
	DEFINE dFechaIni  , dFechaFin  , dFechaAux			DATE;
	DEFINE sCont_PFSI	SMALLINT;	 DEFINE cCredPFSI	CHAR(20);
	DEFINE sCont_cancel SMALLINT;
	
	-- IFSR variable iAct para determinar las etapas
	DEFINE iAct   		integer;
	DEFINE iActNvo   	integer;
	DEFINE iDiasAct 	integer;
	DEFINE cCapitalStatus CHAR(1);
	
	--JRVR 11_01_22 BAJA DE PROGRAMA DE APOYO 2021
	DEFINE dValorDeudaApoyo DECIMAL(18,2);
	DEFINE dSdoCapInsolutoHist DECIMAL(18,2);
	DEFINE vMonto DECIMAL(18,2);

   ON EXCEPTION SET sql_err, isam_err, error_info
      --SET DEBUG FILE TO "/RESPALDOS/PruebasIFSR/provisionlineacred.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;

	  LET CodRet = sql_err;
      CALL log_cierre ('001', vNumCred, CodRet, FechaHoy,TRIM(error_info)) RETURNING rLog;

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
  --SET DEBUG FILE TO "provisionlineacred_parte_ifrs.out";
  --TRACE ON;

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
   LET StatusCred_apoyo = '';
   LET numcte_apoyo = '';
   LET diferir_apoyo = 0;
   LET SdoRetenido_apoyo = 0;
   LET fecha_cont_apoyo = date (1);
   LET sdo_trab4_apoyo = 0;
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
	LET dSdoNvoPFSI					= 0;  -- Mensualidad Cred 6900 Sdo Inmd
	LET dFechaIni = date(1);	LET dFechaFin = date(1); LET dFechaAux = date(1);	LET sCont_PFSI = 0;	LET cCredPFSI = '';
	LET dSdoDiaPFSI	= 0 ; LET dSdoHistPFSI = 0;	LET sCont_cancel = 0;
	
	--IFSR variable iAct para determinar las etapas
	LET iAct = 0;
	LET iActNvo = 0;
	LET iDiasAct = 0;
	LET vCodFunInt = '';
	LET cCapitalStatus = '';
	--JRVR 11_01_22 BAJA DE PROGRAMA DE APOYO 2021
	LET dValorDeudaApoyo = 0;
	LET dSdoCapInsolutoHist = 0;
	LET vMonto = 0;
	
FOREACH WITH HOLD

	select a.num_credito, monto
	INTO vNumCred, vMonto
	from bdicred:sd_movhis a,
	 bdicred:sd_maesdoshist b 
	where a.num_credito = b.num_credito
	and a.fecha_mov = mdy('01','20','2022')
	and b.fecha = mdy('01','20','2022')
	and a.codigo_fun = '605' 
	and a.codigo_ref = 125
	and extend(hora_mov, hour to second) = '08:26:31'  
	and b.sdo_capital <> b.sdo_cap_insoluto
	and b.monto_vencido > 0
	
	BEGIN WORK;
		-- interes
		--CALL genmovcierre_movdia('001', vNumCred, NumProducto,125, "605", mdy(01,20,2022),  vMonto, Folio, vSucursal, '01', '',vPlaza) RETURNING CodRet, Mensaje;

			
		-- actualizacion maesdos					
		update bdicred:sd_maesdos set sdo_capital = sdo_capital - vMonto,
							sdo_cap_insoluto = sdo_cap_insoluto - vMonto,
							mto_capitalizado = mto_capitalizado - vMonto
							where num_credito = vNumCred;
							
							
		-- actualizacion maesdoshist					
		update bdicred:sd_maesdoshist set sdo_capital = sdo_capital - vMonto,
							sdo_cap_insoluto = sdo_cap_insoluto - vMonto,
							mto_capitalizado = mto_capitalizado - vMonto					
							where empresa = '001' and fecha = mdy(01,20,2022) and num_credito = vNumCred;
							
		--actualiza saldos diarios
		UPDATE bdicred:sd_sdodiario set capvig20 = capvig20 - vMonto
			where fecha = mdy(01,01,2022) and num_credito = vNumCred;
			
		UPDATE  bdicred:Sd_movhis SET reversado = 'S' where empresa = '001' and fecha_mov = mdy(01,20,2022) and num_credito = vNumCred
		and codigo_fun = '605' and codigo_ref = 125 ;			
		
		LET vMonto = 0;
		LET Folio = '';
		LET vSucursal = '';
		LET vPlaza = '';
		LET NumProducto = '';
		
	COMMIT WORK;
END FOREACH;


FOREACH WITH HOLD

	select a.num_credito, monto
	INTO vNumCred, vMonto
	from bdicred:sd_movhis a,
	 bdicred:sd_maesdoshist b 
	where a.num_credito = b.num_credito
	and a.fecha_mov = mdy('01','20','2022')
	and b.fecha = mdy('01','20','2022')
	and a.codigo_fun = '605' 
	and a.codigo_ref = 126
	and extend(hora_mov, hour to second) = '08:26:31'  
	and b.sdo_capital <> b.sdo_cap_insoluto
	and b.monto_vencido > 0
	
	
	BEGIN WORK;
		-- iva
	--	CALL genmovcierre_movdia('001', vNumCred, NumProducto,126, "605", mdy(01,20,2022), vMonto, Folio, vSucursal, '01', '',vPlaza) RETURNING CodRet, Mensaje;

			
		-- actualizacion maesdos					
		update bdicred:sd_maesdos set sdo_capital = sdo_capital - vMonto,
							sdo_cap_insoluto = sdo_cap_insoluto - vMonto,
							mto_capitalizado = mto_capitalizado - vMonto
							where num_credito = vNumCred;
							
							
		-- actualizacion maesdoshist					
		update bdicred:sd_maesdoshist set sdo_capital = sdo_capital - vMonto,
							sdo_cap_insoluto = sdo_cap_insoluto - vMonto,
							mto_capitalizado = mto_capitalizado - vMonto					
							where empresa = '001' and fecha = mdy(01,20,2022) and num_credito = vNumCred;
							
		--actualiza saldos diarios
		UPDATE bdicred:sd_sdodiario set capvig20 = capvig20 - vMonto
			where fecha = mdy(01,01,2022) and num_credito = vNumCred;
			
		UPDATE  bdicred:Sd_movhis SET reversado = 'S' where empresa = '001' and fecha_mov = mdy(01,20,2022) and num_credito = vNumCred
		and codigo_fun = '605' and codigo_ref = 126 ;			
			
		LET vMonto = 0;
		LET Folio = '';
		LET vSucursal = '';
		LET vPlaza = '';
		LET NumProducto = '';
				
	COMMIT WORK;
END FOREACH;


   RETURN CodRet;
END PROCEDURE;