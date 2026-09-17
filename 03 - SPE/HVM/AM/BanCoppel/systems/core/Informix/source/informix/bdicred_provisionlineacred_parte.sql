CREATE PROCEDURE "informix".provisionlineacred_parte(pEmpresa CHAR(3), pEjecucion smallint)
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
	
	-- Porcentual para calculo del pago minimo
	DEFINE vFactorPorcentual DECIMAL (18,2); --Modificacion pago minimo
    
	--KSOV PROGRAMA APOYO 2023
	DEFINE c_cve_programa char(14);
	DEFINE c_fecha_solicbajapa DATE;
	DEFINE C_fecha_inactiva DATE;
	DEFINE c_fecha_cuotaPA DATE;
	DEFINE c_fecha_altaPA DATE;
	--KSOV PROGRAMA APOYO 2023
	
  --AAC RQM 09 617 pago mÃ­nimo TDC.
    DEFINE sMes CHAR(2);
    DEFINE sYear CHAR(4); 								 
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- ********************  ******************************************************
/*   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "Cons_Sdo_TC.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET Saldo = 0;
      LET FechaHoy = NULL;
      RETURN cod_ret, Saldo, VStatus, cod_ret2, FechaHoy, SaldoCom;
   END EXCEPTION;*/

   ON EXCEPTION SET sql_err, isam_err, error_info
    SET DEBUG FILE TO "provisionlineacred.err";
      TRACE sql_err||" * "||isam_err||" * "||" num_credito "||vNumCred||" * "||error_info; --Modificacion pago minimo

	  LET CodRet = sql_err;
      IF Begin = "S" THEN ROLLBACK WORK; END IF

      CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,TRIM(error_info)) RETURNING rLog; 
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
  
  -- SET DEBUG FILE TO "/home/c90236570/Trace/provisionlineacred_parte_BAJAOTIS.out";
  -- TRACE ON;

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
	-- Porcentual para calculo del pago minimo
	LET vFactorPorcentual = 0; --Modificacion pago minimo
	LET c_cve_programa = '';
	LET c_fecha_solicbajapa  = ''; --KSOV PROGRAMA APOYO 2023
	LET C_fecha_inactiva  = ''; --KSOV PROGRAMA APOYO 2023
	LET c_fecha_cuotaPA  = ''; --KSOV PROGRAMA APOYO 2023
	LET c_fecha_altaPA = '';
  --AAC RQM 09 617 pago mÃ­nimo TDC.
  LET sMes  = "";
  LET sYear = "";	
  LET TopeMinimo = 0;
  LET v_fac_pagm_suma_sdo = 0;
  LET CapTrasNo = 0;
  LET MontoFinanciado = 0;
	
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

-- Obtiene fechas para informacion de PFSI
	  LET dFechaIni = FechaHoy - 1 units month; --mdy(month(dFechaAux), day(FechaHoy), year(dFechaAux));
	  LET dFechaIni = dFechaIni + 1 units day;
	  LET dFechaFin = FechaHoy;
--     Se determina el rango de creditos a facturar
        SELECT SUBSTR(valor,1,12),SUBSTR(valor,14,25) INTO cred_ini,cred_fin
         FROM bdicred:sd_param WHERE empresa = pEmpresa AND cod_param = (950 + pEjecucion)::CHAR(3);     
		 
        SELECT a.num_credito, a.status_cred, a.numcte, b.dia_corte,a.num_producto,a.sucursal,a.divisa
          FROM sd_maecred a, sd_maecredanexo b
         WHERE a.empresa = pEmpresa     AND b.num_credito = a.num_credito
           AND b.empresa = a.empresa  AND b.fecha_proceso = FechaHoy
           and status_cred NOT IN ("CC", "FC")
		  -- AND a.num_credito in (select num_credito from sd_programa_apoyo2021)
		 and a.num_credito >= cred_ini    and a.num_credito  < cred_fin     --IFSR se comenta para pruebas unitarias
		   and a.num_producto <> '7800'	
		   into temp paso_cred_fac with no log;

        begin;
            create unique index inx_paso_cred on paso_cred_fac(num_credito) ONLINE;
        commit;
        update statistics medium for table paso_cred_fac;
		/*IF FechaHoy = mdy (month(FechaHoy),18,2020) OR FechaHoy = mdy (month(FechaHoy),20,2020)  THEN
			FOREACH WITH HOLD
				SELECT a.num_credito,a.numcte,a.num_producto,a.sucursal,a.divisa
				INTO vNumCred,numcte_apoyo,NumProducto,vSucursal,vDivisa
					FROM paso_cred_fac a
					join sd_programa_apoyo2020_chtb b on (a.num_credito = b.num_credito)
				WHERE b.bandera = 'A'
				AND a.dia_corte = DAY(FechaHoy)
				AND a.status_cred = 'BA'
				AND a.num_producto in ('8100','6001')
				
				SELECT monto_vencido INTO MontoVencido  FROM sd_maesdos WHERE num_credito = vNumCred;
					
				IF MontoVencido > 0 THEN
					UPDATE sd_maesdos
					   SET monto_vencido = monto_vencido - MontoVencido,
					   monto_financiado = monto_financiado - MontoVencido,
					   sdo_capital = sdo_capital + MontoVencido
					 WHERE empresa = pempresa AND num_credito = vNumCred;
					 
					UPDATE sd_maecred
					   SET status_cred = 'AA'
					 WHERE empresa = pempresa AND num_credito = vNumCred;
					 
					 UPDATE bdicred:sd_maecredanexo SET fecha_vencto = NULL WHERE num_credito = vNumCred;

					----- recupera monto vencido a vigente
					EXECUTE PROCEDURE GENMOV(pEmpresa, vNumCred, NumProducto, 4, '602', FechaHoy, MontoVencido, Folio, vSucursal, vDivisa, '7598')
								 INTO CodRet, vMensaje;	
							
					UPDATE sd_amortiza_credito
					   SET capital_status = "5"
					 WHERE empresa = pempresa AND num_credito = vNumCred AND fecha_cuota = FechaHoy  -1 UNITS MONTH;
				END IF;
				
			END FOREACH;
		END IF;*/
 /*
	---- Cancela Programa de apoyo
	IF FechaHoy = mdy (10,18,2020) OR FechaHoy = mdy (10,20,2020)  THEN
		FOREACH WITH HOLD
		
			SELECT a.num_credito,a.numcte
			INTO vNumCred,numcte_apoyo
				FROM paso_cred_fac a
				join sd_programa_apoyo2020 b on (a.num_credito = b.num_credito)
			WHERE b.bandera = 'A'
			AND a.dia_corte = DAY(FechaHoy)
				
			CALL sp_diferir_cancela_credito(numcte_apoyo,vNumCred,1,20) 
					RETURNING CodRet,vMensaje;

		END FOREACH;
	END IF;
 */																					   
 
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
   --IFSR variable iAct para determinar las etapas
   LET iAct = 0;
   LET iActNvo = 0;
   LET iDiasAct = 0;
   LET vCodFunInt = '';
   LET cCapitalStatus = '';
    
  
   SELECT a.empresa,              a.num_credito,              a.sdo_int_anticip,  a.sdo_intereses,        a.sdo_dia_ant_int,        a.sdo_mes_ant_int,  
          a.sdo_acum_mes_int,     a.sdo_exig_int,             a.sdo_no_exig,      a.dias_acum_int,        a.sdo_moratorio,          a.dias_acum_mora,     
          a.sdo_capital,          a.sdo_cap_insoluto,         a.sdo_dia_ant_cap,  a.sdo_acum_mes_cap,     a.dias_acum_cap,          a.monto_vencido,
          a.mto_venc_trasp,       a.dias_acum_intper,         a.sdo_global_int,   a.sdo_acum_intper,      a.mto_venc_tra_int,       b.num_producto, 
          DAY(b.fecha_apertura),  b.tasa_interes,             b.sucursal,         b.divisa,               b.fecha_pago_cap,         b.fecha_pago_int,      
          a.mto_capitalizado,     NVL(a.int_tra_no_exig,0),          a.sdo_trab4,        a.monto_financiado,     b.status_cred,            a.sdo_acum_mes_cap,    
          a.dias_acum_cap,        a.mto_ministra_cap,         f.dia_corte,        f.dias_gracia_mora,     f.tp_dias_calc_mora,      f.dias_fecha_max_pago, 
          f.tp_dias_fecha_pago,   NVL(f.tasa_interes_cte,0),  b.dias_trasp_cap,   f.fecha_vencto,         f.prox_fecha_pago,        b.tasa_moratorios,     
          f.fecha_proceso,        a.sdo_contab_mora,          a.sdo_retenido,     a.cap_tras_no_venci,    NVL(b.id_unidad_prod,0),  f.fecha_ult_pago,      
          b.campo_trab3,mto_fin_ven_trasp, a.monto_otorgado,		numcte,		  NVL(a.act,-1) -- IFSR se obtiene el act de la maesdos
     INTO pEmpresa ,       vNumCred        ,   SdoIntAnticip ,     SdoIntereses   ,    SdoDiaAntInt,  SdoMesAntInt,
          SdoAcumMesInt,   SdoExigInt      ,   SdoNoExig     ,     DiasAcumInt    ,    SdoMoratorio,  DiasAcumMora,
          SdoCapital,      SdoCapInsoluto  ,   SdoDiaAntCap  ,     SdoAcumMesCap  ,    DiasAcumCap,   MontoVencido,
          MtovencTrasp,    DiasAcumIntPer  ,   SdoGlobalInt  ,     SdoAcumIntPer  ,    MtoVencTraInt, NumProducto,
          Aniversario,     TasaIntm        ,   vSucursal     ,     vDivisa        ,    FechaPagoCap,  FechaPagoInt,
          MtoCapitalizado, IntTraNoExig    ,   SdoTrab4      ,     MontoFinanciado,    StatusCred,    SdoPromedio,
          DiasAcCap,       MtoMinistraCap  ,   vDiaDeCorte   ,     vDiasGraciaMora,    vTpDiasMora,   vDiasMaxPago,
          vTpDiasPago,     vTasaCte        ,   vDiasTrasp    ,     vFechaVenc     ,    vFecProxPag,   vTasaMora,
          vFProceso,       vSdoAcumMora    ,   SdoRetenido   ,     CapTrasNo      ,    vMarcaAyuda,   vFechaUltPago,
          Campotrabajo3,   vMtofinventrasp, vmnto_otorgado,			numcte_apoyo  ,  iAct -- IFRS se recupera la variable act 
     FROM sd_maesdos a, sd_maecred b, sd_maecredanexo f  
    WHERE a.num_credito = vNumCred          AND a.empresa     = pEmpresa
      AND b.num_credito = a.num_credito     AND b.empresa     = a.empresa
      AND f.num_credito = a.num_credito     AND f.empresa     = a.empresa;

	  
	  
  
	LET iActNvo = iAct; -- IFSR se asigna el valor de iact
	-- Obtiene saldos en caso de contar con Pagos Fijos Saldo Inmediato. Unicamente en dia de corte
	LET dSdoNvoPFSI = 0;
	LET sCont_cancel = 0;
	
		--- Consulta si existe en plan de apoyo --KSOV obtiene fecha baja programa apoyo 
		SELECT bandera, cve_programa, fecha_inactivacion, fecha_solic_baja, fecha_alta INTO wbandera_apoyo, c_cve_programa , C_fecha_inactiva, c_fecha_solicbajapa , c_fecha_altaPA
		FROM sd_programa_apoyo 
		WHERE num_credito = vNumCred;
		--AND bandera = 'A'; ---KSOV SE QUITA EL FILTRO DE LA BANDERA
		
		IF ( wbandera_apoyo is null ) THEN 
			LET wbandera_apoyo = ''; 
		END IF;
		--Se apaga inscripcion al programa de apoyo 20/01/2022 
		--IF wbandera_apoyo = 'A' AND FechaHoy = mdy(11,21,2023) THEN
		--IF wbandera_apoyo = 'A' AND FechaHoy IN (mdy(11,18,2023), mdy(11,20,2023)) AND c_cve_programa = 'PA_JAL_2023' THEN --SE COMENTA BAJA DE GUADALAJARA KSOV
		-- KSOV SE ACTUALIZA BAJA DE PROGRAMA APOYO OTIS DEL 18 Y 20 DE ABRIL AL 18 Y 20 DE FEBRERO
		 IF wbandera_apoyo = 'A' AND FechaHoy IN (mdy(02,18,2024), mdy(02,20,2024)) AND c_cve_programa = 'PA_GRO_2023' THEN
			IF vDiaDeCorte = DAY(FechaHoy) THEN
				SELECT sdo_cap_insoluto INTO dSdoCapInsolutoHist FROM sd_maesdoshist WHERE empresa = '001' AND num_credito = vNumCred AND fecha = mdy(11,DAY(FechaHoy),2023);
				
				IF MontoFinanciado - SdoTrab4 < 0 THEN
					LET dValorDeudaApoyo = dSdoCapInsolutoHist - (MontoFinanciado - SdoTrab4) * -1;
				ELSE 
					LET dValorDeudaApoyo = dSdoCapInsolutoHist - (MontoFinanciado - SdoTrab4);
				END IF;
					
				IF dValorDeudaApoyo IS NULL OR dValorDeudaApoyo = '' THEN LET dValorDeudaApoyo = 0; END IF;
					
				IF dValorDeudaApoyo <= 0 THEN --deuda pagada
					LET SdoNoExig = 0;
					UPDATE sd_maesdos set sdo_no_exig = SdoNoExig WHERE num_credito = vNumCred AND empresa = '001';

					UPDATE sd_amortiza_credito set interes_debe = 0, interes_pagado = 0, iva_debe = 0, iva_pagado = 0 
						WHERE empresa = '001' AND num_credito = vNumCred AND fecha_cuota = (select max(fecha_cuota) - 1 UNITS MONTH from sd_amortiza_credito where empresa = '001' and num_credito = vNumCred);
							
				END IF;
					
				--se desactiva el progrma de apoyo
				LET wbandera_apoyo = 'B';
				UPDATE sd_programa_apoyo SET bandera = wbandera_apoyo, fecha_inactivacion = FechaHoy WHERE num_credito = vNumCred;
			END IF;
		END IF;
		
		--KSOV INI BAJA PROGRAMA DE APOYO OTIS 2023 (PA_GRO_2023) / ACTUALIZA LA FECHA DE INACTIVACION DE ACUERDO A LA SOLICITUD DEL CLIENTE.
		
		IF  c_cve_programa = 'PA_GRO_2023' AND vDiaDeCorte = DAY(FechaHoy) AND wbandera_apoyo = 'B' 
			AND c_fecha_solicbajapa IS NOT NULL 
			AND C_fecha_inactiva IS NULL THEN
						
				UPDATE sd_programa_apoyo SET fecha_inactivacion = FechaHoy WHERE num_credito = vNumCred; --Se desactiva programa de apoyo PA_GRO_2023
																										 --La fecha de inactivacion real es igual a la fecha de solicitud de baja

				SELECT sdo_cap_insoluto INTO dSdoCapInsolutoHist 
				  FROM sd_maesdoshist WHERE empresa = '001' 
				   AND num_credito = vNumCred 
				   AND fecha = mdy(11,DAY(FechaHoy),2023);
			
				IF MontoFinanciado - SdoTrab4 < 0 THEN						
					LET dValorDeudaApoyo = dSdoCapInsolutoHist - (MontoFinanciado - SdoTrab4) * -1;
				ELSE 
					LET dValorDeudaApoyo = dSdoCapInsolutoHist - (MontoFinanciado - SdoTrab4);
				END IF;
			
				IF dValorDeudaApoyo IS NULL OR dValorDeudaApoyo = '' THEN 
					LET dValorDeudaApoyo = 0; 
				END IF;
			
				IF dValorDeudaApoyo <= 0 THEN --DEUDA PAGADA
								
					LET SdoNoExig = 0;
					UPDATE sd_maesdos SET sdo_no_exig = SdoNoExig WHERE num_credito = vNumCred AND empresa = '001';

					UPDATE sd_amortiza_credito SET interes_debe = 0, interes_pagado = 0, iva_debe = 0, iva_pagado = 0 
					 WHERE empresa = '001' AND num_credito = vNumCred AND fecha_cuota = (SELECT MAX(fecha_cuota) - 1 UNITS MONTH from sd_amortiza_credito where empresa = '001' and num_credito = vNumCred);
				END IF;
		END IF;	--KSOV FIN BAJA PROGRAMA DE APOYO OTIS 2023 (PA_GRO_2023) / ACTUALIZA LA FECHA DE INACTIVACION DE ACUERDO A LA SOLICITUD DEL CLIENTE.
		
		
	
	IF vDiaDeCorte = day(FechaHoy) THEN
	
		SELECT count(num_sol_prestamo) INTO sCont_PFSI FROM bdicred:sd_promocion_credito WHERE num_credito = vNumCred AND tipo_contrato = '3';
		LET cCredPFSI = '';
		IF sCont_PFSI = 1 THEN
			SELECT num_sol_prestamo INTO cCredPFSI FROM bdicred:sd_promocion_credito WHERE num_credito = vNumCred AND tipo_contrato = '3';
		ELIF sCont_PFSI > 1 THEN
			SELECT max(fecha) INTO dFechaAux FROM bdicred:sd_promocion_credito WHERE num_credito = vNumCred AND tipo_contrato = '3';
			SELECT num_sol_prestamo INTO cCredPFSI FROM bdicred:sd_promocion_credito WHERE num_credito = vNumCred AND tipo_contrato = '3' AND fecha = dFechaAux;
		END IF;

		IF cCredPFSI IS NULL THEN LET cCredPFSI = ''; END IF;
		IF cCredPFSI != '' THEN  
			SELECT count(*) INTO sCont_PFSI FROM bdicred:sd_maecredcrd 	-- Identifica que el credito este vivo o liquidado en el ultimo periodo
			 WHERE num_credito = cCredPFSI AND (status_cred = 'AA' OR (status_cred = 'E1' AND iAct = 0) OR (status_cred = 'FF' AND fecha_vencim >= dFechaIni AND fecha_vencim <= dFechaFin)); -- IFSR se hace validacion para que contemple la etapa 1 
		
			SELECT count(*) INTO sCont_cancel FROM bdicred:sd_cancela_credisol WHERE num_credito = cCredPFSI;
			
			-- Si tiene un credito PFSI y no se encuentra liquidado por cancelacion a solicitud del cliente.
			IF sCont_PFSI = 1 AND sCont_cancel = 0 THEN
				SELECT sum(monto) INTO dSdoHistPFSI
				  FROM bdicred:sd_movhis 
				 WHERE num_credito = vNumCred 
				   AND codigo_fun = '061' AND codigo_ref in (5, 8, 16)
				   AND fecha_mov >= dFechaIni and fecha_mov <= dFechaFin
				   AND trim(SUBSTR(referencia,18, 20)) = cCredPFSI;
				   
				SELECT sum(monto) INTO dSdoDiaPFSI
				  FROM bdicred:sd_movdia
				 WHERE num_credito = vNumCred 
				   AND codigo_fun = '061' AND codigo_ref in (5, 8, 16)
				   AND fecha_mov >= dFechaIni and fecha_mov <= dFechaFin
				   AND trim(SUBSTR(referencia,18, 20)) = cCredPFSI;	
			
				IF dSdoDiaPFSI IS NULL THEN LET dSdoDiaPFSI = 0; END IF;
				IF dSdoHistPFSI IS NULL THEN LET dSdoHistPFSI = 0; END IF;
				LET dSdoNvoPFSI = dSdoHistPFSI + dSdoDiaPFSI;
			END IF;	
		END IF;
	END IF;		
	----------------------------	  
     
      LET vMtoVencido = 0;
      LET vMtoVencido_ant = 0;
      LET vBandFinan = "0";
      LET Es_Totalero = "N";
      LET mSdoOrig_PagMin = (SdoCapital+CapTrasNo - dSdoNvoPFSI);
--APOYO 2014 INI
      --LET wbandera_apoyo = '';
--APOYO 2014 FIN

	  IF (Campotrabajo3 <> 'BAJA' ) then
          LET vMtofinventrasp = 0;
	  ElSE
		IF (vMtofinventrasp <> 0) THEN
			 SELECT count(*) INTO vMtofinventrasp
			 FROM sd_amortiza_credito
			WHERE empresa = pempresa  AND num_credito = vNumCred  AND capital_status IN ("2","7","6");
		END IF;
	  END IF;

      LET StatusCred_ant = StatusCred;
      LET vComportamiento = 0;

      IF (StatusCred = "AA" OR (StatusCred = "E1" AND iAct = 0)) THEN -- IFRS se valida para la etapa 1 
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
    IF ( vMarcaAyuda = 1 OR StatusCred = "CV" OR ( Campotrabajo3 = 'BAJA' AND StatusCred <> "CV") ) THEN -- Marca para bloqueo de creditos
        UPDATE sd_maesdos
           SET mto_fin_ven_trasp  = vMtofinventrasp
	     WHERE empresa = pEmpresa AND num_credito = vNumCred;
	
        --CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
        --                       SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,FechaHoy) RETURNING CodRet;

        -- RQM 09 473 MACF
		--CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
        --                       SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,MontoFinanciado,FechaHoy) RETURNING CodRet;
		
		--IFSR actualizacion para que se mande a actualizar la sdodiario, con la etapa en que se encuentra en ese momento
		--Se extraen los datos de la amortizacion para heredar datos de intereses
		Let vIvaInt = 0;
		Let vIvaIntv = 0;

		Select {+INDEX(sd_amortiza_credito amorst)} sum(case when capital_status='1' then (interes_debe - interes_pagado) else 0 end),
			   sum(case when capital_status in ('2','7','6') then (interes_debe - interes_pagado) else 0 end),
			   sum(case when capital_status='1' then (iva_debe - iva_pagado) else 0 end),
			   sum(case when capital_status in ('2','7','6') then (iva_debe - iva_pagado) else 0 end)
		into  SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv
		from sd_amortiza_credito
		where empresa = pEmpresa
		and num_credito = vNumCred
		and capital_status in ('1','2','7','6');
		
		CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
                               SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,MontoFinanciado,FechaHoy, StatusCred, vFechaVenc, CASE WHEN StatusCred IN ('E1','E2','E3') THEN iAct ELSE NULL END) RETURNING CodRet;
		
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
--	IF NumProducto in ('6001','8100') AND DAY(FechaHoy) = vDiaDeCorte AND StatusCred = 'AA' THEN
--	IF NumProducto in ('6001','8100') AND StatusCred = 'AA' THEN
		
		/*		--- se apaga inscripcion al programa de apoyo 01/08/2020 ITD
		IF wbandera_apoyo = '' AND DAY(FechaHoy) = vDiaDeCorte THEN
			--- Consulta si el credito tenia estatus vigente AA 
			SELECT status_cred INTO StatusCred_apoyo
			FROM bdicred:sd_maecredcont WHERE num_credito = vNumCred
				AND fecha = mdy('03','31','2020')
				AND status_cred = 'AA';

			IF ( StatusCred_apoyo is not null ) THEN 
				---- Consulta si existe en la tabla de diferimiento, cargado por otro canal.			
				SELECT count (*) INTO diferir_apoyo
				FROM bdicred:sd_diferir 
				WHERE numcte = numcte_apoyo
				AND canal_baja IS NULL;
				
				---- Si existe en tabla de diferimiento o No ha pagado pero estubo al corriente
				IF (diferir_apoyo > 0 ) OR (MontoFinanciado > 0 ) THEN
				
					INSERT INTO bdicred:sd_programa_apoyo2020 
						VALUES(vNumCred,FechaHoy,'A',date (1));
						
					LET wbandera_apoyo = 'A';
					
				END IF;
				
			END IF;
		END IF; */
--	END IF;
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
    IF (StatusCred = "BA" OR StatusCred = "BT" OR (StatusCred IN("E1","E2","E3") AND iAct > 0) ) and DAY(FechaHoy) <> vDiaDeCorte THEN -- IFRS Se agrega validacion para contemplar los creditos con Act > 0

        SELECT MAX(fecha_cuota), count(*) INTO vFechaCuota, vMtofinventrasp
         FROM sd_amortiza_credito
        WHERE empresa = pempresa AND num_credito = vNumCred AND capital_status IN ("2","7","6");

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
--- Se agrega tablas actuales para el apoyo 2020

       INSERT INTO bdicred:"informix".sd_maecred_prog_apoyo
       SELECT FechaHoy, *
         FROM bdicred:"informix".sd_maecred 
        WHERE num_credito = vNumCred AND empresa = pEmpresa;  

       INSERT INTO bdicred:"informix".sd_maesdos_prog_apoyo
       SELECT FechaHoy, *
         FROM bdicred:"informix".sd_maesdos 
        WHERE num_credito = vNumCred AND empresa = pEmpresa;              

       INSERT INTO bdicred:"informix".sd_amortiza_credito_prog_apoyo
       SELECT FechaHoy, *
         FROM bdicred:"informix".sd_amortiza_credito
        WHERE num_credito = vNumCred AND empresa = pEmpresa; 

       INSERT INTO bdicred:"informix".sd_maecredanexo_prog_apoyo
       SELECT FechaHoy, *
         FROM bdicred:"informix".sd_maecredanexo
        WHERE num_credito = vNumCred AND empresa = pEmpresa; 
		
-- MUEVE CUOTAS ACTIVAS UN MES ,-- SI SE CONSIDERAN PARA APOYO E2 SE DEBE OBTENER CAPITAL ESTATUS 2 Y SI SE CONSIDERA ETAPA 3 DEBE INCLUIRSE CAPITAL ESTATUS 6, EN CASO DE SER SOLO ETAPA 1 SE DEBE CONSIDERAR CAPITAL ESTATUS 7, SIEMPRE DEBEN INCLUIRSE 1.
       UPDATE sd_amortiza_credito
          SET fecha_cuota = monthadd(fecha_cuota,1)
        WHERE empresa = pempresa AND num_credito = vNumCred AND ( capital_status in ('1','7','2','6') OR fecha_cuota >= FechaHoy - 1 UNITS MONTH );
    
       LET vDiaProxPag = vDiaDeCorte-vDiasGraciaMora;
       LET vFecProxPag = DATE(MONTH(FechaHoy + 1 UNITS MONTH) || "/" || vDiaProxPag || "/" || YEAR(FechaHoy + 1 UNITS MONTH));
    
       UPDATE sd_maecredanexo
          SET prox_fecha_pago = vFecProxPag
        WHERE empresa = pEmpresa AND num_credito = vNumCred;
   END IF;
--APOYO 2014 FIN

    IF ( DAY(FechaHoy) = vDiaDeCorte AND wbandera_apoyo <> 'A' ) THEN
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
		/*
			IF wbandera_apoyo = 'A' AND MontoFinanciado > 0 THEN
			---- Poner al corriente amortiza y maesdoshis
			
				UPDATE sd_amortiza_credito SET capital_debe = capital_pagado
				WHERE empresa = pempresa AND num_credito = vNumCred AND fecha_cuota = vFechaCuota -1 UNITS MONTH;
				--- pago minimo 
				
				SELECT capital_pagado INTO sdo_trab4_apoyo
				FROM sd_amortiza_credito
				WHERE empresa = pempresa AND num_credito = vNumCred AND fecha_cuota = vFechaCuota -1 UNITS MONTH;
				
				UPDATE sd_maesdoshist SET sdo_trab4 = sdo_trab4_apoyo, monto_financiado = monto_vencido + mto_venc_trasp
				WHERE fecha = FechaHoy - 1 UNITS MONTH AND empresa = pEmpresa AND num_credito = vNumCred;
				
				---- GENERA MOVIMIENTO PARA RESPALDAR MONTO FINANCIADO Y TOMARLO EN EL EDC
				CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,11, "605", FechaHoy, MontoFinanciado, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
					IF (CodRet <> "00000") THEN
						ROLLBACK WORK;
						LET vMensaje = "MONTO FINANCIADO APOYO ";
						CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, TRIM(vMensaje) || "(GENMOV)") RETURNING rLog;
						IF rLog > 0 THEN
							RETURN CodRet;
						ELSE
							CONTINUE FOREACH;
						END IF
					ELSE
						LET CodRet = "000";
					END IF;
				
				LET MontoFinanciado = 0;
			END IF;
		*/
		
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
        IF MontoFinanciado < 0  Or (MontoFinanciado = 0 and vMtoVencido <= 0) THEN 
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
           IF vMtoVencido <= 0  AND  vCapInsEsTot <= 0 THEN -- valida si se pago de mas o tiene saldo a favor
              LET Es_Totalero ="S"; 
              LET SdoNoExig = 0;
              UPDATE sd_amortiza_credito SET interes_debe = 0, iva_debe = 0, iva_pagado = 0
                WHERE empresa = pempresa AND num_credito = vNumCred AND fecha_cuota = vFechaCuota -1 UNITS MONTH;
           END IF

           --IF (vMtoVencido > 0 AND StatusCred <> "BT" ) or (vCapInsEsTot >0 AND StatusCred <> "BT") THEN 
           IF (vMtoVencido > 0 AND StatusCred NOT IN ("BT","E1","E2","E3")) OR 
		      (vCapInsEsTot >0 AND StatusCred NOT IN ("BT","E1","E2","E3")) OR
			  (vMtoVencido > 0 AND iAct >= 0 AND iAct <= 2 AND StatusCred IN ("E1","E2")) OR
			  (vCapInsEsTot > 0 AND iAct >= 0 AND iAct <= 2 AND StatusCred IN ("E1","E2")) THEN
		   -- Capitalizacion de iva
              SELECT SUM(iva_debe - iva_pagado) INTO vIvaInt
                FROM sd_amortiza_credito
               WHERE empresa = pempresa AND num_credito = vNumCred AND fecha_cuota = vFechaCuota -1 UNITS MONTH;

				------ Transaccion que no contabiliza con el monto de IVA de Interes, para el plan de Apoyo
				/*IF wbandera_apoyo = 'A' THEN		  
				  IF vIvaInt IS NOT NULL AND vIvaInt <> 0 THEN

					  CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,8, "605", FechaHoy, vIvaInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
					  IF (CodRet <> "00000") THEN
						  ROLLBACK WORK;
						  LET vMensaje = "IVA INTERES DIFERIDO ";
						  CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, TRIM(vMensaje) || "(GENMOV)") RETURNING rLog;
						  IF rLog > 0 THEN
							 RETURN CodRet;
						  ELSE
							 CONTINUE FOREACH;
						  END IF
					  ELSE
						  LET CodRet = "000";
					  END IF;
					  
					  CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,10, "605", FechaHoy, vIvaInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
					  IF (CodRet <> "00000") THEN
						  ROLLBACK WORK;
						  LET vMensaje = "IVA INTERES DIFERIDO ";
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
				ELSE	*/		   
			   
				  IF vIvaInt IS NOT NULL AND vIvaInt <> 0 THEN 
						-- IFSR validacion para registro de transacciones dependiendo el status o la etapa vMtoVencido
						IF(StatusCred IN ("AA","BA")) THEN
							CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,3, "605", FechaHoy, vIvaInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
						ELIF (StatusCred IN ("E1")) THEN 
							CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,126, "605", FechaHoy, vIvaInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
						ELSE
							CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,128, "605", FechaHoy, vIvaInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
						END IF;
					  
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
				  END IF
			--	END IF;
			  
				------ Transaccion que no contabiliza con el monto de Interes, para el plan de Apoyo
			/*	IF wbandera_apoyo = 'A' THEN
					IF SdoNoExig IS NOT NULL AND SdoNoExig <> 0 THEN
				
					  CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,7, "605", FechaHoy,  SdoNoExig, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
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
					  
					  CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,9, "605", FechaHoy,  SdoNoExig, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
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
					END IF;
				ELSE */
				  
					-- Capitalizacion de interes
					  IF SdoNoExig IS NOT NULL AND SdoNoExig <> 0 THEN 

						  LET MtoVencTraInt = MtoVencTraInt + SdoNoExig;
						  
							-- IFSR validacion para registro de transacciones dependiendo el status o la etapa
							IF (StatusCred IN ("AA","BA")) THEN
								CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,2, "605", FechaHoy,  SdoNoExig, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
							ELIF (StatusCred IN ("E1")) THEN 
								CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,125, "605", FechaHoy,  SdoNoExig, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
							ELSE 
								CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,127, "605", FechaHoy,  SdoNoExig, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
							END IF;
							
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
				--END IF;
			  
			  --- si es plan de apoyo se retiene el interes e IVA
			/*  IF wbandera_apoyo = 'A' THEN
			  
					IF SdoNoExig <> 0 THEN
						INSERT INTO bdicred:"informix".sd_maeretenido(empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
						VALUES('001',vNumCred,Folio,FechaHoy,CURRENT HOUR TO FRACTION(3),'8369',0,SdoNoExig,user,'R','INTERES DIFERIDOS',vSucursal,0);

						INSERT INTO bdicred:"informix".sd_maeretenido(empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
						VALUES('001',vNumCred,Folio,FechaHoy,CURRENT HOUR TO FRACTION(3),'8370',0,vIvaInt,user,'R','IVA INTERES DIFERIDOS',vSucursal,0);

					END IF;
			  
			  END IF;*/

			--	IF wbandera_apoyo <> 'A' THEN 
				
					LET sdoCapital = SdoCapital + SdoNoExig + vIvaInt;
					LET sdoCapInsoluto = SdoCapInsoluto + SdoNoExig + vIvaInt;
					LET MtoCapitalizado = MtoCapitalizado + SdoNoExig + vIvaInt;

			--	END IF;
				
				LET mIvaIntCap_PagMin = vIvaInt;  /*RQM 10 673 Pag Min Normativo*/
				LET mIntCap_PagMin = SdoNoExig;   /*RQM 10 673 Pag Min Normativo*/
				LET vIntDiario = SdoNoExig;
				LET vIvaInt      = 0;	
				
           END IF
        END IF
        LET vMtoVencido = 0;

         -- *      REALIZA    P R O V I S I O N    AL    CORTE   *
        --IF (StatusCred = "BT") THEN -- 
		IF (StatusCred = "BT" OR (StatusCred IN("E2","E3") AND iAct >= 2)) THEN --IFSR considerar a los creditos que e encuentran en E1 y E2 y que su act sea >= 2
                IF(StatusCred IN ("BT")) THEN
					LET vCodFunInt = "604";
					LET vCodRefInt = 2; 
					LET BanderaInt = "1";
				ELIF((StatusCred IN("E3") AND iAct >3)) THEN
					LET vCodFunInt = "604";
					LET vCodRefInt = 7002;					
					LET BanderaInt = "1";
				ELIF(StatusCred IN ("E2") AND iAct < 3) THEN
					--IFSR actualizacion de codigo ref para cuando es etapa 2
					LET vCodFunInt = "606";
					--LET vCodRefInt = 7018;
					LET vCodRefInt = 7079;
					LET BanderaInt = "0";
				ELIF(StatusCred IN ("E2") AND iAct = 3) THEN
					--IFSR actualizacion de codigo ref para cuando es etapa 2
					LET vCodFunInt = "604";
					LET vCodRefInt = 7002;
					LET BanderaInt = "1";
				END IF;
        ELSE
			IF (StatusCred IN ("E1") AND iAct < 2) THEN
				 --IFSR actualizacion de codigo ref para cuando es etapa 1
                LET vCodFunInt = "606";
                LET vCodRefInt = 7018;                
				LET BanderaInt = "0";
			ELSE 
				LET vCodFunInt = "606";
                LET vCodRefInt = 1; 
                LET BanderaInt = "0";
			END IF;
        END IF;

        SELECT nvl(SUM(interes_debe - interes_pagado),0), nvl(SUM(iva_debe - iva_pagado),0) INTO vProvInt, vProvIva
          FROM sd_amortiza_credito
         WHERE empresa = pEmpresa
           AND num_credito = vNumCred
          AND fecha_cuota = vFechaCuota -1 UNITS MONTH;

      --IF ( IntTraNoExig > 0 and (StatusCred <>'AA' OR (StatusCred IN("E1","E2","E3") AND  iAct >= 1))) THEN  --Mov. Int Orden.  --CAS     -- IFSR validar que el credito se encuentre en E1, E2, E3 y que su act sea >= 1
	  IF ( IntTraNoExig > 0 and (StatusCred IN ('BA','BT') OR (StatusCred IN("E2","E3") AND  iAct >= 3))) THEN  --Mov. Int Orden.  --CAS     -- IFSR validar que el credito se encuentre en E2, E3 y que su act sea >= 1
          let IntTraNoExigMes = vProvInt;
          let vIvaOrdenAnt = vProvIva;

          IF IntTraNoExigMes IS NOT NULL AND IntTraNoExigMes <> 0 THEN 
				IF (StatusCred IN ('E2','E3')) THEN
					CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,7002, 604, FechaHoy, IntTraNoExigMes, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
				ELIF (StatusCred NOT IN ('E1','E2','E3')) THEN 
					CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,2, 604, FechaHoy, IntTraNoExigMes, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
				END IF;
			  
          ELSE
              LET IntTraNoExigMes = 0;
          END IF;

          IF vIvaOrdenAnt > 0 THEN 
				IF (StatusCred IN ('E2','E3')) THEN
					CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,7005, 340, FechaHoy, vIvaOrdenAnt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
				ELIF (StatusCred NOT IN ('E1','E2','E3')) THEN 
					CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,22, 340, FechaHoy, vIvaOrdenAnt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
				END IF;
			  
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
          --IF (vSiCap = '' Or vSiCap IS Null) and StatusCred <> "BT"  THEN 
		  --IF ((vSiCap = '' Or vSiCap IS Null) and (StatusCred <> "BT")) or ((vSiCap = '' Or vSiCap IS Null) iAct <= 2 AND StatusCred IN("E1","E2"))  THEN -- IFSR se valida que la etapa sea E1 y E2 y que su act sea <= 2
		 IF  ((vSiCap = '' Or vSiCap IS Null) and StatusCred IN("AA","BA")) OR ((vSiCap = '' Or vSiCap IS Null) and iAct <= 2 AND StatusCred IN("E1","E2"))  THEN -- IFSR se valida que la etapa sea E1 y E2 y que su act sea <= 2
---- ESTE CODIGO ESTA DE MAS              
              let vIvaInt = '';
              let vIvaInt=vProvIva;

             IF vIvaInt IS NOT NULL AND vIvaInt <> 0 THEN 
				    -- IFSR validacion para registro de transacciones dependiendo el status o la etapa
						IF(StatusCred IN ("AA","BA")) THEN
							CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,3, "605", FechaHoy, vIvaInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
						ELIF (StatusCred IN ("E1")) THEN 
							CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,126, "605", FechaHoy, vIvaInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
						END IF;
			 ELSE
                  LET vIvaInt = 0;
             END IF;
			 -- IFSR validacion para registro de transacciones dependiendo el status o la etapa
							IF (StatusCred IN ("AA","BA")) THEN
								CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,2, "605", FechaHoy,  SdoNoExig, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
							ELIF (StatusCred IN ("E1")) THEN 
								CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,125, "605", FechaHoy,  SdoNoExig, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
							END IF;
			 CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,vCodRefInt, vCodFunInt, FechaHoy, vProvInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
			
---- ESTE CODIGO ESTA DE MAS
          ELSE
		  
		   IF vIvaInt IS NOT NULL AND vIvaInt <> 0 THEN 
				    -- IFSR validacion para registro de transacciones dependiendo el status o la etapa
						IF(StatusCred IN ("AA","BA")) THEN
							CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,3, "605", FechaHoy, vIvaInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
						ELIF (StatusCred IN ("E1")) THEN 
							CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,126, "605", FechaHoy, vIvaInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
						ELIF (StatusCred IN ("E2")) THEN
							CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,128, "605", FechaHoy, vIvaInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
						END IF;
			 ELSE
                  LET vIvaInt = 0;
             END IF;
			
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

          IF vCodFunInt = "606" OR (StatusCred IN ("E1","E2") AND vCodFunInt = "604" AND iAct < 3) THEN
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

		  --LET SdoIntereses = SdoIntereses;
		  --LET vIvaInt = vIvaInt;
		  --IF vIvaInt IS NULL THEN LET vIvaInt = 0; END IF;
		  --LET vCodFunInt = vCodFunInt;
		  --LET vIntGrav = vIntGrav;
		  --LET vFechaCuota = vFechaCuota;
        If SdoIntereses > 0 then -- IFSR cual es el status que se debe de considerar (a que interes corresponde) |604 CIERRE.TRASPASO INTERES VIGENTE A VENCIDO TRASPASADO
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

        --IF ( vMtoVencido > 0 AND StatusCred <> "BT" ) THEN -- Traspaso de Vigente a transitorio *    
		IF (( vMtoVencido > 0 and StatusCred IN ("E1","AA","BA") AND iAct < 2 )) OR vMtoVencido > 0 and StatusCred IN("AA","BA") THEN
		   LET vMensaje = "Traspaso a Transitorio ";
		   --IF StatusCred = "BA" THEN
            IF StatusCred = "BA" OR ( StatusCred = "E1" AND iAct = 1 ) THEN -- IFSR se agrega validacion para contemplar los creditos que se encuentren en E1 y con ACT 1
               LET vMtoVencido = VigenteMesAnt;
            END IF

            IF (vMtoVencido <= SdoCapital) THEN
                LET MontoVencido = MontoVencido + vMtoVencido;
                LET SdoCapital = SdoCapital - vMtoVencido;
            ELSE
                LET MontoVencido = MontoVencido + SdoCapital;
            END IF;

			-- IFSR validacion para registro de transacciones dependiendo el status o la etapa
			IF(StatusCred IN ("AA","BA")) THEN 
				CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,1, "602", FechaHoy, vMtoVencido, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
			ELIF (StatusCred IN ("E1")) THEN
				CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,135, "602", FechaHoy, vMtoVencido, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
			END IF;
			
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

            --IF (StatusCred = "AA") THEN 
			IF (StatusCred = "AA" OR ( StatusCred = "E1" AND iAct = 0)) THEN -- IFSR se agrega validacion para contemplar los creditos que esten en E1 y su AT = 0
                UPDATE sd_amortiza_credito
                   SET capital_status = "7"
                 WHERE empresa = pempresa AND num_credito = vNumCred AND fecha_cuota = FechaHoy  -1 UNITS MONTH;
            END IF;

			IF (StatusCred = 'AA') THEN
				LET StatusCred ="BA";
			ELSE
				LET StatusCred ="E1";
			END IF;
			
			IF( (iAct = 0 AND StatusCred IN("E1")) OR StatusCred = "AA") THEN -- IFSR si su act = 0 se aumenta el act
				IF StatusCred IN("E1","E2","E3") THEN LET iActNvo = iAct + 1;END IF;
			END IF;
			LET TrasHoy    = "S";
          
            LET vFechaVencim = FechaHoy;
        END IF -- Traspaso de Vigente a transitorio *

        LET vMensaje = "Traspaso de Transitorio a Vencido";

-- bloque para transitorios o vencidos
        --IF ( StatusCred_ant <> "AA" ) THEN 
		IF (StatusCred_ant IN("E1","E2","E3","BA","BT") AND iAct > 0) or StatusCred_ant IN("BA","BT") THEN
			--IF ( StatusCred <> "BT" ) THEN 
			IF (StatusCred IN("E1") AND iActNvo = 1) or StatusCred IN("BA") THEN
					IF (StatusCred = 'BA') THEN
						LET StatusCred ="BT";
					ELSE
						LET StatusCred ="E2"; -- IFSR se cambia el valor del status
					END IF;
					IF StatusCred IN("E1","E2","E3") THEN LET iActNvo = iAct + 1;	END IF; -- IFSR se aumenta el valor del act
                    
					IF StatusCred NOT IN("E1","E2","E3") THEN
						LET MtovencTrasp = (MontoVencido);
						LET CapTrasNo = SdoCapital;
						LET SdoCapital= 0;
						LET MontoVencido = 0;
					END IF;
					
					
					--IFSR nueva actualizacion de saldos para etapas
					IF(StatusCred IN("E1") AND iActNvo = 1) THEN
						--LET MontoVencido = MontoVencido + VigenteMesAnt;
						--LET SdoCapital= SdoCapital - VigenteMesAnt;
						
									
					ELIF (StatusCred IN("E2") AND iActNvo = 2) THEN
						--LET MontoVencido = MontoVencido + VigenteMesAnt;
						--LET SdoCapital= SdoCapital - VigenteMesAnt;
						
						--IFRS Capital a capital
						CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,7008, "601", FechaHoy, (SdoCapital),
                                    Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
									
						--IFRS vencido a vencido
						CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,7009, "601", FechaHoy, (MontoVencido),
                                    Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
						
					ELIF (StatusCred IN("E2") AND iActNvo = 3) THEN
						LET MontoVencido = MontoVencido + VigenteMesAnt;
						LET SdoCapital= SdoCapital - VigenteMesAnt;
						
						--IFRS Capital a vencido
						CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,136, "602", FechaHoy, (VigenteMesAnt),
                                    Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
					ELIF (StatusCred IN("E3") AND iActNvo = 4) THEN
						LET MontoVencido = MontoVencido + VigenteMesAnt;
						LET SdoCapital= SdoCapital - VigenteMesAnt;
						
						--IFRS Capital a vencido
						CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,136, "602", FechaHoy, (VigenteMesAnt),
                                    Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
									
						--IFRS Capital a capital
						CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,7012, "601", FechaHoy, (SdoCapital),
                                    Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
									
						--IFRS vencido a vencido
						CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,7013, "601", FechaHoy, (MontoVencido),
                                    Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
									
					ELIF (StatusCred IN("E3") AND iActNvo > 4) THEN
						LET MontoVencido = MontoVencido + VigenteMesAnt;
						LET SdoCapital= SdoCapital - VigenteMesAnt;
						--IFRS Capital a vencido
						CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,7020, "601", FechaHoy, (VigenteMesAnt),
                                    Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
					END IF;
					--IFSR FIN

                    IF CapTrasNo IS NOT NULL AND CapTrasNo <> 0  THEN 
						IF StatusCred NOT IN("E1","E2","E3") THEN
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
						END IF;
                    ELSE 
                        LET CapTrasNo = 0;
                    END IF;

                    IF MtovencTrasp IS NOT NULL AND MtovencTrasp <> 0 THEN 
						IF (StatusCred NOT IN("E1","E2","E3")) THEN
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
						END IF;
                    ELSE
                        LET MtovencTrasp = 0;
                    END IF;

					IF StatusCred NOT IN("E1","E2","E3") THEN
						LET MontoVencido = 0;
					END IF;

                    UPDATE sd_amortiza_credito
                       SET capital_status = "2"
                     WHERE empresa = pempresa
                       AND num_credito = vNumCred
					   AND capital_status IN ("1","7") 
                       AND fecha_cuota < FechaHoy
                       AND capital_debe > 0
                       AND (capital_debe - capital_pagado) > 0;
            ELSE   -- Realiza reubicacion de saldos cuando ya esta vencido
			-- IFSR aquiÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ­ se pondriÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ­a la validacion para que haga el traspaso en 2 y 4 IF(StatusCred IN("E2","E3") AND (iAct = 2 or iAct)) THEN  LET iActNvo = iAct + 1;
				
				-- IFSR se actualiza de E2 a E3
				IF(StatusCred = 'E2' AND iAct = 3) THEN
					LET StatusCred ="E3"; -- IFSR se cambia el valor del status
				END IF;
					
				IF StatusCred IN("E1","E2","E3") THEN LET iActNvo = iAct + 1;	END IF; -- IFSR se aumenta el valor del act
				
				LET VigenteMesAnt = VigenteMesAnt ;
				IF StatusCred NOT IN("E1","E2","E3") THEN
                LET MtovencTrasp = MtovencTrasp ;
                LET MtovencTrasp = MtovencTrasp + VigenteMesAnt;
                LET CapTrasNo = CapTrasNo - VigenteMesAnt; --AXL
				END IF;
				
					--IFSR nueva actualizacion de saldos para etapas
					IF(StatusCred IN("E1") AND iActNvo = 1) THEN
						--LET MontoVencido = MontoVencido + VigenteMesAnt;
						--LET SdoCapital= SdoCapital - VigenteMesAnt;
						
					ELIF (StatusCred IN("E2") AND iActNvo = 2) THEN
						--LET MontoVencido = MontoVencido + VigenteMesAnt;
						--LET SdoCapital= SdoCapital - VigenteMesAnt;
						
						--IFRS Capital a capital
						CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,7008, "601", FechaHoy, (SdoCapital),
                                    Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
									
						--IFRS vencido a vencido
						CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,7009, "601", FechaHoy, (MontoVencido),
                                    Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
						
					ELIF (StatusCred IN("E2") AND iActNvo = 3) THEN
						LET MontoVencido = MontoVencido + VigenteMesAnt;
						LET SdoCapital= SdoCapital - VigenteMesAnt;
						
						--IFRS Capital a vencido
						CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,136, "602", FechaHoy, (VigenteMesAnt),
                                    Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
					ELIF (StatusCred IN("E3") AND iActNvo = 4) THEN
						LET MontoVencido = MontoVencido + VigenteMesAnt;
						LET SdoCapital= SdoCapital - VigenteMesAnt;
						
						--IFRS Capital a vencido
						CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,136, "602", FechaHoy, (VigenteMesAnt),
                                    Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
									
						--IFRS Capital a capital
						CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,7012, "601", FechaHoy, (SdoCapital),
                                    Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
									
						--IFRS vencido a vencido
						CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,7013, "601", FechaHoy, (MontoVencido),
                                    Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
									
					ELIF (StatusCred IN("E3") AND iActNvo > 4) THEN
						LET MontoVencido = MontoVencido + VigenteMesAnt;
						LET SdoCapital= SdoCapital - VigenteMesAnt;
						--IFRS Capital a vencido
						CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,7020, "601", FechaHoy, (VigenteMesAnt),
                                    Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
					END IF;
					--IFSR FIN

                IF VigenteMesAnt IS NOT NULL AND VigenteMesAnt <> 0 THEN 
					IF (StatusCred NOT IN("E1","E2","E3")) THEN
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
					END IF;
                ELSE
                    LET VigenteMesAnt = 0;
                END IF;

				IF StatusCred NOT IN("E1","E2","E3") THEN
                LET SdoNoExig = 0;
				END IF;
				
				IF SdoCapital IS NOT NULL AND SdoCapital <> 0 THEN 
					IF (StatusCred NOT IN("E1","E2","E3")) THEN
                     -- Capital de Vigente a Traspasado
							CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,1, "601", FechaHoy, (SdoCapital),
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
					END IF;
                    ELSE 
                        LET SdoCapital = 0;
                    END IF;
					

				IF(StatusCred IN("E2") and iActNvo < 4) THEN
					LET cCapitalStatus = '2';
				ELIF(StatusCred IN("E3") and iActNvo >= 4) THEN
					LET cCapitalStatus = '6';
				END IF;
				
				IF StatusCred NOT IN('E1','E2','E3') THEN 
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
				ELSE
				
                UPDATE sd_amortiza_credito
                   --SET capital_status = "2", interes_status = case when (interes_debe - interes_pagado) > 0 then "3" else interes_status end
				   SET capital_status = cCapitalStatus, interes_status = case when (interes_debe - interes_pagado) > 0 then "3" else interes_status end -- IFSR se agrega para status a 6
                 WHERE empresa = pempresa
                   AND num_credito = vNumCred
                   AND fecha_cuota < FechaHoy
                   AND capital_status IN ("1","7","2");

                SELECT SUM(interes_debe - interes_pagado) INTO IntTraNoExig
                  FROM sd_amortiza_credito
                 WHERE empresa = pempresa
                   AND num_credito = vNumCred
                   AND fecha_cuota < FechaHoy
                   --AND capital_status='2';
				   AND capital_status='6';
				   
				   IF IntTraNoExig IS NULL THEN
					LET IntTraNoExig = 0;
				   END IF;
				END IF;
            END IF -- Status Diferente a BT
        END IF -- Credito Vencido Traspasado

    -- **********************************************
    --       C a l c u l a   M o r a t o r i o s    *
    -- **********************************************
        LET vMensaje = "Acumulacion de Moratorios";

        --IF ( StatusCred = "BA" OR StatusCred = "BT" ) THEN 
		IF ( ( StatusCred = "BA" OR StatusCred = "BT" ) OR (StatusCred IN("E1","E2","E3") and iActNvo >= 1) ) THEN -- IFSR validacion para contemplar los de etapa 2 y 3, y que su atr sea mayor a 0

           SELECT MAX(fecha_cuota), count(*) INTO vFechaCuota, vMtofinventrasp
             FROM sd_amortiza_credito
            WHERE empresa = pempresa AND num_credito = vNumCred AND capital_status IN ("2","7","6");

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
        let vFactorPorcentual = vFactorPagoMin/100; --Modificacion pago minimo

        IF ( Es_Totalero = "S" ) THEN 
            LET SdoTrab4 = 0;
		    LET vComportamiento = 1;
			
            IF (SdoCapInsoluto - dSdoNvoPFSI) <= 0 THEN
                LET MontoFinanciado = 0;
            ELSE
                LET TotalAdeudo = ROUND(((SdoCapital+CapTrasNo - dSdoNvoPFSI) * (vFactorPorcentual)), -0); --Modificacion pago minimo
				
				IF TotalAdeudo < ROUND((vmnto_otorgado * vFactorPagoMinLinC),-0) THEN 
					LET TotalAdeudo = ROUND((vmnto_otorgado * vFactorPagoMinLinC),-0); 
				END IF;
                -- RQM 10 673 Pag Min Normativo
                IF TotalAdeudo  < ROUND(((mSdoOrig_PagMin * v_fac_pagm_suma_sdo) + mIntCap_PagMin + mIvaIntCap_PagMin), -0) THEN
                    LET TotalAdeudo =  ROUND(((mSdoOrig_PagMin * v_fac_pagm_suma_sdo) + mIntCap_PagMin + mIvaIntCap_PagMin), -0);
                END IF;

				IF ( TotalAdeudo > (SdoCapInsoluto - dSdoNvoPFSI) ) THEN
					LET TotalAdeudo = SdoCapInsoluto - dSdoNvoPFSI;
				END IF;
				
                IF TotalAdeudo < 0 THEN
                    LET TotalAdeudo = 0;
                ELIF (SdoCapInsoluto - dSdoNvoPFSI) < TopeMinimo THEN
                    IF SdoCapInsoluto - dSdoNvoPFSI < 0 THEN
                        LET TotalAdeudo = 0;
                    ELSE
                        LET TotalAdeudo = SdoCapInsoluto - dSdoNvoPFSI;
                    END IF;
                ELIF TotalAdeudo < TopeMinimo THEN
                    LET TotalAdeudo = TopeMinimo;
                END IF
                LET MontoFinanciado = TotalAdeudo;
            END IF;
        ELSE
			IF (SdoCapInsoluto - dSdoNvoPFSI) <= 0 THEN
				LET TotalAdeudo = 0;
				LET MontoFinanciado = 0;
			ELSE
				LET TotalAdeudo = ROUND(((SdoCapital+CapTrasNo - dSdoNvoPFSI) * (vFactorPorcentual)), -0);  --Modificacion pago minimo
				IF TotalAdeudo < ROUND((vmnto_otorgado * vFactorPagoMinLinC),-0) THEN 
					LET TotalAdeudo = ROUND((vmnto_otorgado * vFactorPagoMinLinC),-0); 
				END IF;
				-- RQM 10 673 Pag Min Normativo
				IF TotalAdeudo  < ROUND(((mSdoOrig_PagMin * v_fac_pagm_suma_sdo) + mIntCap_PagMin + mIvaIntCap_PagMin), -0) THEN
					LET TotalAdeudo =  ROUND(((mSdoOrig_PagMin * v_fac_pagm_suma_sdo) + mIntCap_PagMin + mIvaIntCap_PagMin), -0);
				END IF;         
			
				IF TotalAdeudo < 0 THEN
				   LET TotalAdeudo = 0;
				ELIF (SdoCapital+CapTrasNo - dSdoNvoPFSI) < TopeMinimo THEN     --SdoCapInsoluto < TopeMinimo THEN  --210508 Solicitado Por Juan Olivares.
				   IF (SdoCapital+CapTrasNo - dSdoNvoPFSI) < 0 THEN    --SdoCapInsoluto < 0 THEN
					   LET TotalAdeudo = 0;
				   ELSE
					   LET TotalAdeudo = (SdoCapital+CapTrasNo - dSdoNvoPFSI);     --SdoCapInsoluto;
				   END IF;
				ELIF TotalAdeudo < TopeMinimo THEN  --210508 Solicitado Por Juan Olivares.
				   LET TotalAdeudo = TopeMinimo;
				END IF

				LET MontoFinanciado = TotalAdeudo;

				IF (SdoCapital+CapTrasNo - dSdoNvoPFSI) <= MontoFinanciado THEN   --SdoCapInsoluto <= MontoFinanciado THEN
				   LET MontoFinanciado = (SdoCapital+CapTrasNo - dSdoNvoPFSI);   --SdoCapInsoluto;
				   IF MontoFinanciado < 0 THEN
					  LET MontoFinanciado = 0;
				   END IF;
				END IF;
			END IF;
        END IF;

      -- Marcar como credito inactivo si no tuvo movimientos durante el periodo (by MACF)
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

	LET MontoFinanciado =  MontoFinanciado + dSdoNvoPFSI;
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
            WHERE empresa = pEmpresa and num_credito = vNumCred and capital_status in ('2','7','6');

            UPDATE sd_amortiza_credito SET campo_trabajo1 = vIvaIntMes
            WHERE empresa = pEmpresa and num_credito = vNumCred and fecha_cuota = FechaHoy;

      -- ********************************************************************
      -- Actualiza Intereses del periodo en las columnas correspondientes   *
      -- ********************************************************************
          --IF StatusCred IN ("AA", "BA") THEN 
		  --IF (StatusCred IN ("AA", "BA") OR (StatusCred IN("E1") AND iActNvo <= 1) ) THEN -- IFSR se valida que la etapa sea 1 y el act 0 o 1
		  IF (StatusCred IN ("AA", "BA") OR (StatusCred IN("E1","E2") AND iActNvo <= 3) ) THEN -- IFSR se valida que la etapa sea 1 o 2 y el act 0 a 3
             LET SdoNoExig = SdoIntereses;
          ELSE
             LET IntTraNoExig = IntTraNoExig + SdoIntereses;
			 LET SdoNoExig = 0;
          END IF;

          LET SdoIntereses = 0;

          -- Actualiza Anexo Maecred
          LET vDiaProxPag = vDiaDeCorte-vDiasGraciaMora;
          LET vFecProxPag = DATE(MONTH(FechaHoy + 1 UNITS MONTH) || "/" || vDiaProxPag || "/" || YEAR(FechaHoy + 1 UNITS MONTH));

          UPDATE sd_maecredanexo
             SET prox_fecha_pago = vFecProxPag, fecha_vencto = vFechaVenc
           WHERE empresa = pEmpresa AND num_credito = vNumCred;

          --IF ( StatusCred = "AA" ) THEN 
		  IF ( StatusCred = "AA" OR ( StatusCred = "E1" AND iActNvo = 0 )) THEN -- IFSR validacion para contemplar los de E1 y atr = 0
              UPDATE sd_amortiza_credito
                 SET capital_status = "5", capital_pagado = capital_debe
               WHERE empresa = pEmpresa AND num_credito = vNumCred
                 AND fecha_cuota = FechaHoy - 1 UNITS MONTH
                 AND capital_status NOT IN ("2","7","6");          END IF;
        END IF; -- Termina IF de DIa de Corte
   END IF;
   
/*
 -- RQM 09 473 MACF
   let vSdoTotLiquidar = SdoCapital + MontoVencido + CapTrasNo + MtoVencTrasp + (IntTraNoExig-SdoNoExig) + vIvaInt + vIvaIntv + vSdoAcumMora + SdoMoratorio;
   let vPagoMinimo     = MontoFinanciado + (vIvaIntv - vIvaInt) + vIvaInt + vSdoAcumMora;
   -- let vSdoTotVencido  = vPagoMinimo - (MontoFinanciado + MontoVencido + CapTrasNo);		-- MACF RQI 21 207 20200703
   LET vSdoTotVencido = MontoFinanciado + MontoVencido + CapTrasNo;
--   let vLimiteCredito  = vmnto_otorgado - SdoCapInsoluto - SdoRetenido;	-- JOM RQI 27 210 20190520	
   let vInteresesCargados = (vProvInt + vProvIva);
   
   IF vSdoTotVencido < 0 THEN LET vSdoTotVencido = 0; END IF;
   */
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
  
  IF (iAct <> iActNvo) then -- IFRS se actualiza el act en caso de que haya cambiado al principal
      LET iAct = iActNvo;
  END IF;
  
   UPDATE sd_maesdos
   SET
      fecha_ult_mov    = FechaHoy,       sdo_int_anticip   = SdoIntAnticip,   sdo_intereses     = SdoIntereses,    sdo_dia_ant_int  = SdoDiaAntInt,    
      sdo_retenido     = SdoRetenido,    sdo_acum_mes_int  = SdoAcumMesInt ,  sdo_exig_int      = SdoExigInt,      sdo_no_exig      = SdoNoExig,       
      dias_acum_int    = DiasAcumInt,    sdo_moratorio     = SdoMoratorio,    sdo_contab_mora   = vSdoAcumMora,    dias_acum_mora   = DiasAcumMora,    
      sdo_capital      = SdoCapital ,    sdo_cap_insoluto  = SdoCapInsoluto,  sdo_dia_ant_cap   = SdoDiaAntCap,    sdo_acum_mes_cap = SdoAcumMesCap,   
      dias_acum_cap    = DiasAcumCap,    mto_capitalizado  = MtoCapitalizado, monto_vencido     = MontoVencido,    mto_venc_trasp   = MtoVencTrasp,    
      dias_acum_intper = DiasAcumIntPer, sdo_global_int    = SdoGlobalInt,    sdo_acum_intper   = SdoAcumIntPer,   mto_venc_int     = vIvaIntMes,      
      mto_venc_tra_int = MtoVencTraInt,  monto_financiado  = MontoFinanciado, mto_fin_ven_trasp = vMtofinventrasp, int_tra_no_exig  = IntTraNoExig,  
      sdo_trab4        = SdoTrab4,       cap_tras_no_venci = CapTrasNo,		  act = iAct
  WHERE num_credito = vNumCred AND empresa = pEmpresa;

  IF (StatusCred_ant <> StatusCred) then -- IFRS se actualiza el status
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
           sum(case when capital_status in ('2','7','6') then (interes_debe - interes_pagado) else 0 end),
           sum(case when capital_status='1' then (iva_debe - iva_pagado) else 0 end),
           sum(case when capital_status in ('2','7','6') then (iva_debe - iva_pagado) else 0 end)
    into  SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv
    from sd_amortiza_credito
    where empresa = pEmpresa
    and num_credito = vNumCred
    and capital_status in ('1','2','7','6');

   IF FechaHoy = PriHabMes THEN 
   	Let vFecMes = PriDiaMes - 1 UNITS DAY;
        Let vFecMes = MDY(MONTH(vFecMes),20,YEAR(vFecMes));
          --CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
          --                     SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,FechaHoy) RETURNING CodRet;

          --- RQM 09 473 MACF
		  --CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
          --                     SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,MontoFinanciado,FechaHoy) RETURNING CodRet;
		  --- RQM 09 473 MACF
		  
		  --IFSR actualizacion para que se mande a actualizar la sdodiario, con la etapa en que se encuentra en ese momento
		  CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
                               SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,MontoFinanciado,FechaHoy, StatusCred, vFechaVenc, CASE WHEN StatusCred IN ('E1','E2','E3') THEN iAct ELSE NULL END) RETURNING CodRet;
		  

        IF (CodRet <> "000") THEN
          LET vMensaje = " Saldos Diarios";
          CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,vMensaje) RETURNING rLog;
       END IF;
   ELSE
          --CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
          --                     SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,FechaHoy) RETURNING CodRet;

          -- RQM 09 473 MACF					   
		  --CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
          --                     SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,MontoFinanciado,FechaHoy) RETURNING CodRet;
		  -- RQM 09 473 MACF
		  
		  --IFSR actualizacion para que se mande a actualizar la sdodiario, con la etapa en que se encuentra en ese momento
		  CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
                               SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,MontoFinanciado,FechaHoy, StatusCred, vFechaVenc, CASE WHEN StatusCred IN ('E1','E2','E3') THEN iAct ELSE NULL END) RETURNING CodRet;
		  

       IF (CodRet <> "000") THEN
          LET vMensaje = " Saldos Diarios";
          CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,vMensaje) RETURNING rLog;
      END IF;
  END IF;

   SELECT iva, plaza INTO vIvaSuc, vPlaza FROM cr_sucursales WHERE empresa = pEmpresa AND sucursal = vSucursal;  -- 20200706 MACF 
   -- RQM 09 473 MACF
   let vSdoTotLiquidar = SdoCapital + MontoVencido + CapTrasNo + MtoVencTrasp + (IntTraNoExig+vIvaIntv) + (vSdoAcumMora + SdoMoratorio+ ((vSdoAcumMora + SdoMoratorio)*vIvaSuc));
   let vPagoMinimo     = MontoFinanciado + (IntTraNoExig+vIvaIntv) + (vSdoAcumMora + SdoMoratorio+ ((vSdoAcumMora + SdoMoratorio)*vIvaSuc));
   LET vSdoTotVencido  = MontoVencido + MtoVencTrasp + (IntTraNoExig+vIvaIntv) + (vSdoAcumMora + SdoMoratorio+ ((vSdoAcumMora + SdoMoratorio)*vIvaSuc));
   let vInteresesCargados = (vProvInt + vProvIva);
   IF vSdoTotVencido < 0 THEN LET vSdoTotVencido = 0; END IF;
  
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
    --AAC RQM 09 617 pago mÃ­nimo TDC.
	  IF NumProducto = '6001' THEN --Inserta a tabla sd_archivopagmin para generar archivo plano
        LET sMes= MONTH(FechaHoy);
        LET sYear= YEAR(FechaHoy);
        
        IF LENGTH(sMes) < 2 THEN
              LET sMes="0"||sMes;
        END IF;
            
        INSERT INTO bdicred:"informix".sd_archivopagmin(fecha_registro,numcte,num_credito,sdo_cap_insoluto,interes,iva,monto_vencido_corte,mto_fin_ven_trasp,monto_otorgado,sdo_trab4,factor_porcentual,tope_minimo,factor_pago_min_linc,fac_pagm_suma_sdo,es_totalero,sdo_nvo_pfsi,sdo_hist_pfsi,sdo_dia_pfsi,sdo_capital,cap_tras_no,total_adeudo,sdo_orig_pagmin,mto_venc_trasp,monto_vencido,monto_financiado,cal_iva,cal_interes,status_cred) 
        VALUES(FechaHoy,numcte_apoyo,vNumCred,SdoCapInsoluto,mIntCap_PagMin, mIvaIntCap_PagMin,vSdoTotVencido,vMtofinventrasp,vmnto_otorgado,SdoTrab4,vFactorPorcentual,TopeMinimo,vFactorPagoMinLinC,v_fac_pagm_suma_sdo,Es_Totalero,dSdoNvoPFSI,dSdoHistPFSI,dSdoDiaPFSI,SdoCapital,CapTrasNo,TotalAdeudo,mSdoOrig_PagMin,MtoVencTrasp,MontoVencido,MontoFinanciado,vIvaInt,SdoNoExig,StatusCred);        
      END IF;	--AAC RQM 09 617 pago mÃ­nimo TDC.
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
	
-- IFSR se calculan los dias_act para su actualizacion
	SELECT NVL(dias_act,0) INTO iDiasAct FROM bdicred:"informix".sd_indicador_cred WHERE num_credito = vNumCred AND empresa = pEmpresa;
	
	IF(iActNvo = 1) THEN
		LET iDiasAct = abs(FechaHoy) - abs(date(vFechaVenc));
	ELIF (iActNvo > 1) THEN
		LET iDiasAct = iDiasAct + DAY(FechaHoy);
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
            fecha_cancelacion_h   = fecha_cancelacion,   fecha_ult_respaldo    = FechaHoy,            impagos_consec_h      = CASE WHEN statuscred = 'AA' OR (statuscred = 'E1' AND iAct = 0) THEN 0 ELSE (NVL(impagos_consec_h,0) + 1) END,
            moras_hist_h		  = CASE WHEN statuscred = 'AA' OR (statuscred = 'E1' AND iAct = 0) THEN NVL(moras_hist_h,0)  ELSE (NVL(moras_hist_h,0) + 1) END, 
            --- RQM 09 473 MACF
			sdo_tot_liquidar_h    = vSdoTotLiquidar,     pago_minimo_h         = vPagoMinimo,         sdo_tot_vencido_h = vSdoTotVencido,
			limite_credito_h      = vLimiteCredito
		    --- RQM 09 473 MACF
			-- IFSR se agrega validacion para el actualizar los dias_act
			, dias_act = iDiasAct
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

 --IPCB junio2023 depuracion y respaldo de Plan de lealtad
	IF DAY(FechaHoy)= (vDiaDeCorte+1)  THEN
	    LET vFechahist = mdy(month(FechaHoy),vDiaDeCorte,year(FechaHoy));
		
		INSERT INTO bdicred:"informix".sd_compra_acumulada_plan_lealtad_hist
       SELECT vFechahist, *
         FROM bdicred:"informix".sd_compra_acumulada_plan_lealtad
        WHERE num_credito = vNumCred
		and origen = "Plan_Lealtad";
		
		DELETE bdicred:"informix".sd_compra_acumulada_plan_lealtad
		 WHERE num_credito = vNumCred;
		 
		 DELETE bdicred:"informix".sd_beneficios_calculados_por_acumular
		 WHERE num_credito = vNumCred;		 

	END IF;
	    
    --IF FechaHoy=mdy(12,31,2021) THEN
    IF FechaHoy=mdy(12,31,2021) THEN

        EXECUTE PROCEDURE "informix".sp_ambientar_indicador_cred(FechaHoy,vNumCred)
            INTO CodRet, vMensaje;

        IF  CodRet <> "000" THEN
            RETURN CodRet;				 
        END IF;

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
'MODIFICACION',
'',
'Modificaciones',
'Instalo: Jorge Humberto Quintana Santiesteban',
'CC: 32746 28/05/2019',
'****************************************************************************************************************';

CREATE PROCEDURE "informix".sp_msi_procesa_msi()
RETURNING
	CHAR(6) 	AS cod_ret,
	CHAR(80) 	AS descripcion


	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE cErrorInfo			CHAR(80);
    DEFINE cCodRet				CHAR(6);
    DEFINE cMensajeRet			CHAR(80);
	DEFINE dMonto				DECIMAL(18,2);
	DEFINE sPlazo				SMALLINT;
	DEFINE vcNumCredito			VARCHAR(20);
	DEFINE vcNumCte				CHAR(20);
	DEFINE cEjecutivo			CHAR(8);
	DEFINE cSucursal			CHAR(4);
	DEFINE sNumPromocion		SMALLINT;
	DEFINE cNomPromocion		CHAR(50);
	DEFINE cFolioApertua		CHAR(16);
	DEFINE cFolioMovto			CHAR(16);

    DEFINE dMonto1				DECIMAL(18,2);
	DEFINE sPlazo1				SMALLINT;
	DEFINE vcNumCredito1		VARCHAR(20);
	DEFINE cEjecutivo1			CHAR(8);
	DEFINE cSucursal1			CHAR(4);
	DEFINE sNumPromocion1		SMALLINT;
	DEFINE cNomPromocion1		CHAR(50);
	DEFINE cFolioApertua1		CHAR(16);
	DEFINE cFolioMovto1			CHAR(16);

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO QUE GENERA EL FOLIO
	DEFINE cCodRetGF			CHAR(6);
	DEFINE cFolioSucGF			CHAR(16);

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE LA PROYECCION
	DEFINE cCodRetPP			CHAR(6);
    DEFINE cMensajeRetPP		CHAR(80);
	DEFINE dTotalPagarPP		DECIMAL(18,2);
	DEFINE sNumPlazoPP			SMALLINT;
	DEFINE dPagoMensualPP		DECIMAL(18,2);
	DEFINE dInteresIvaPP		DECIMAL(18,2);
	DEFINE dSaldoTdcPP			DECIMAL(18,2);
	DEFINE cFolioPromoPP		CHAR(16);

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE principal
	DEFINE cCodRetPrin			CHAR(5);
	DEFINE dRemanentePrin		DECIMAL(18,2);
	DEFINE dIntMoratorioPrin	DECIMAL(18,2);
	DEFINE dIntVencidoPrin		DECIMAL(18,2);
	DEFINE dCapVencidoPrin		DECIMAL(18,2);
	DEFINE dIntVigentePrin		DECIMAL(18,2);
	DEFINE dCapVigentePrin		DECIMAL(18,2);
	DEFINE dImpuestoPrin		DECIMAL(18,2);
	DEFINE dComisionesPrin		DECIMAL(18,2);
	DEFINE dSeguroPrin			DECIMAL(18,2);

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE ASIGNACION DE NUMERO DE SOLICITUD
	DEFINE cCodRetANS			CHAR(5);
	DEFINE cNumSolANS			CHAR(20);

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE APERTURA DE PRESTAMO
	DEFINE cCodRetAP			CHAR(6);
	DEFINE dTasaInteres			DECIMAL(18,2);
	DEFINE dTasaMora			DECIMAL(18,2);
	DEFINE dCatIva		    	DECIMAL(18,2);
	DEFINE cMercadeo			CHAR(1);

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE REVERSION
	DEFINE cCodRetRev			CHAR(5);

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE REVERSION PROMO
	DEFINE cCodRetRP			CHAR(5);
    DEFINE cMensajeRetRP		CHAR(80);

	--VARIABLES PARA CACHAR EL VALOR DEL PROCEDIMIENTO DE LA APERTURA DE LA COMPRA A MESES.
	DEFINE cCodRetGenMov		CHAR(10);
	DEFINE cMsjeGenMov		    CHAR(80);
    DEFINE vDivisa              CHAR(2);
    DEFINE vDivisa1             CHAR(2);
    DEFINE v_dv                 CHAR(2);
    DEFINE v_tipocambio         DECIMAL(14,6);
    DEFINE vsucorig             CHAR(4);
    DEFINE vsucorig1            CHAR(4);
    DEFINE vc_dtFechaHoy        DATE;
	DEFINE cResp_Cte_sms		CHAR(1);
	DEFINE sCountExists			SMALLINT;
	DEFINE sYield				INTEGER;
	DEFINE sTasa				DECIMAL(9,6);
	DEFINE cNumProm_proy		SMALLINT;

	-- JHQS INC 27 127 {
	DEFINE dMontoIntIVA			DECIMAL(18,2);
	DEFINE dFechaPromo			DATE;
	DEFINE dMontoIntIVA1		DECIMAL(18,2);
	DEFINE dFechaPromo1			DATE;
	DEFINE vReferencia			VARCHAR(40);
	DEFINE vReferencia2			VARCHAR(40);
	DEFINE vRef					VARCHAR(40);
	DEFINE vFolio				VARCHAR(16);
	DEFINE vProducto			CHAR(4);
	DEFINE cTipoContrato		CHAR(3);
	DEFINE dPorcReducTp3 		DECIMAL(18,2);
	DEFINE dSdoDisponible       DECIMAL(18,2);
	DEFINE dSdoReduccion        DECIMAL(18,2);
	DEFINE cCodRetCanc 			CHAR(5);
	DEFINE cMensajeRetCanc      CHAR(100);
	DEFINE cBajaApoyo			CHAR(1);
	DEFINE dMonto_LinOrig		DECIMAL(18,2);	
	DEFINE dMonto_LinNva 		DECIMAL(18,2);	
	DEFINE dFecha_Invitacion    DATE;
	DEFINE vStatus_cred			CHAR(2);
	DEFINE vTransaccPrincp		CHAR(4);
	DEFINE dCsg_cap_vig			DECIMAL(18,2);	
	DEFINE dCsg_tot_liquidacion	DECIMAL(18,2);	
	DEFINE dCsg_linea_disp		DECIMAL(18,2);
	DEFINE sCamp_Activa_Msi		SMALLINT;
	DEFINE sContador_sms		SMALLINT;
	DEFINE dMnto_Vencido    	DECIMAL(18,2);
	DEFINE dMnto_Venc_Trasp   	DECIMAL(18,2);
	
	-- Variable para monto minimo
	DEFINE dmontoValido			DECIMAL(18,2);
	
	
	
	LET dMontoIntIVA 			= 0.0;
	LET dFechaPromo				= DATE(1);
	LET dMontoIntIVA1 			= 0.0;
	LET dFechaPromo1			= DATE(1);
	LET vReferencia 			= '';
	LET	vReferencia2 			= '';
	LET vRef 					= '';
	LET	vFolio 					= '';
	---INICIALIZACIONES	
	LET iSqlErr					= 0;
	LET iIsamErr				= 0;
	LET cErrorInfo				= '';
	LET cCodRet					= '000000';
	LET cMensajeRet				= 'PROCESO EXITOSO';
	LET dMonto					= 0.0;
	LET sPlazo					= 0;
	LET vcNumCredito			= '';
	LET vcNumCte				= '';
	LET cEjecutivo				= '';
	LET cSucursal				= '';
	LET sNumPromocion			= 0;
	LET cNomPromocion			= '';
	LET cFolioApertua			= '';
	LET cFolioMovto				= '';
    LET dMonto1					= 0.0;
	LET sPlazo1					= 0;
	LET vcNumCredito1			= '';
	LET cEjecutivo1				= '';
	LET cSucursal1				= '';
	LET sNumPromocion1			= 0;
	LET cNomPromocion1			= '';
	LET cFolioApertua1			= '';
	LET cFolioMovto1			= '';
	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO QUE GENERA EL FOLIO
	LET cCodRetGF				= '000000';
	LET cFolioSucGF				= '';
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE LA PROYECCION
	LET cCodRetPP				= '';
    LET cMensajeRetPP			= '';
	LET dTotalPagarPP			= 0.0;
	LET sNumPlazoPP				= 0;
	LET dPagoMensualPP			= 0.0;
	LET dInteresIvaPP			= 0.0;
	LET dSaldoTdcPP				= 0.0;
	LET cFolioPromoPP			= '';
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE principal
	LET cCodRetPrin				= '';
	LET dRemanentePrin			= 0.0;
	LET dIntMoratorioPrin		= 0.0;
	LET dIntVencidoPrin			= 0.0;
	LET dCapVencidoPrin			= 0.0;
	LET dIntVigentePrin			= 0.0;
	LET dCapVigentePrin			= 0.0;
	LET dImpuestoPrin			= 0.0;
	LET dComisionesPrin			= 0.0;
	LET dSeguroPrin				= 0.0;
	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE ASIGNACION DE NUMERO DE SOLICITUD
	LET cCodRetANS			= '';
	LET cNumSolANS			= '';
	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE APERTURA DE PRESTAMO
	LET cCodRetAP				= '000000';
	LET dTasaInteres			= 0.0;
	LET dTasaMora				= 0.0;
	LET dCatIva		    		= 0.0;
	LET cMercadeo				= '';
	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE REVERSION
	LET cCodRetRev				= '00000';
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE REVERSION PROMO
	LET cCodRetRP				= '00000';
    LET cMensajeRetRP			= '';
	--VARIABLES PARA CACHAR EL VALOR DEL PROCEDIMIENTO DE LA APERTURA DE LA COMPRA A MESES.
	LET cCodRetGenMov			= "";
	LET cMsjeGenMov		    	= "";
    LET vDivisa             	= "00";
    LET vDivisa1            	= "00";
    LET v_dv                	= "00";
    LET v_tipocambio        	= 0;
    LET vsucorig            	= "";
    LET vsucorig1           	= "";
    LET vc_dtFechaHoy       	= DATE(1);
	LET cResp_Cte_sms			= '';
	LET sCountExists			= 0;
	LET sYield 					= 0;
	LET sTasa					= 0;
	LET cNumProm_proy			= 0;
	LET vProducto				='';
	LET cTipoContrato			= '';
	LET dPorcReducTp3 			= 0;
	LET dSdoDisponible      	= 0;
	LET dSdoReduccion       	= 0;
	LET cCodRetCanc 			= '';
	LET cMensajeRetCanc     	= '';
	LET cBajaApoyo				= '';
	LET dMonto_LinOrig			= 0;
	LET dMonto_LinNva 			= 0;
	LET dFecha_Invitacion		= DATE(1);
	LET vTransaccPrincp			= '';
	LET dCsg_cap_vig			= 0;
	LET dCsg_tot_liquidacion	= 0;
	LET dCsg_linea_disp			= 0;
	LET sCamp_Activa_Msi		= 0;
	LET sContador_sms			= 0;
	LET dMnto_Vencido    		= 0;
	LET dMnto_Venc_Trasp   		= 0;
	--VARIABLE PARA CACHAR EL MONTO MINIMO DEL PROCESO
	LET dmontoValido			= 0;

	

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = trim(cFolioMovto) || cErrorInfo;
			RETURN cCodRet, NVL(cMensajeRet,'');
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/mahr/sp_msi_procesa_msi.out';

	--TRACE ON;

	-- Parametros de tipo de cambio
    SELECT valor INTO v_dv FROM bdinteg:si_param WHERE cod_param = 17;
    SELECT precio_venta INTO v_tipocambio FROM bdinteg:si_tpcambio WHERE empresa = "001" AND divisa = v_dv AND clase_tpcambio = "O"
       AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio) FROM bdinteg:si_tpcambio WHERE empresa = "001" AND divisa = v_dv);

	-- Tasa de Interes para MSI
	SELECT valor_numerico INTO sTasa FROM bdicred:sd_param_campania WHERE grupo_parametro = 'MSI' AND num_parametro = 2;
	   
	-- Obtiene fecha del dia de hoy		
    SELECT fecha_hoy INTO vc_dtFechaHoy FROM "informix".sd_fechas WHERE empresa = '001';
	
	-- Obtien el estatus de campaÃ±a activa de Meses Sin Intereses
	SELECT activo INTO sCamp_Activa_Msi FROM bdicred:sd_promocion WHERE num_promo = 10;
	
	-- Obtiene el monto minimo para el proceso
	SELECT valor INTO dmontoValido FROM bdicred:sd_param WHERE cod_param = 337;

	-- Barre los contratos pendientes por generar / Creditos MSI pendientes por generar
    FOREACH WITH HOLD
		SELECT a.monto_actual , a.plazo    , a.num_promo   , a.nombre_promo, a.num_credito, a.ejecutivo, a.sucursal, a.folio_suc  , a.folio_movto, divisa , 
			   b.sucursal, a.monto_int_iva, a.fecha    , b.num_producto, b.numcte      , b.status_cred, c.monto_vencido, c.mto_venc_trasp
		  INTO  dMonto         , sPlazo     , sNumPromocion , cNomPromocion , vcNumCredito , cEjecutivo, cSucursal , cFolioApertua, cFolioMovto  , vDivisa, 
		       vsucorig  , dMontoIntIVA   , dFechaPromo, vProducto     , vcNumCte      , vStatus_cred , dMnto_Vencido  , dMnto_Venc_Trasp 
          FROM bdicred:"informix".sd_promocion_credito a, bdicred:sd_maecred b, bdicred:sd_maesdos c    
         WHERE a.empresa = b.empresa
           AND a.num_credito = b.num_credito
		   AND a.num_credito = c.num_credito
           AND a.status = 0
		   AND a.num_pro_prestamo = '8900'
		   --AND folio_movto in ('i121914061300742') -- BORRA
		
		-- Valida que el producto sea diferente de 6001, de lo contrario se descarta
		IF vProducto != 6001 THEN 
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
			INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi1',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
			CONTINUE FOREACH;
		END IF;
		
		-- Valida que si el plazo es nulo se descarta.
		IF nvl(sPlazo,0) = 0 THEN 
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
			INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi2',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
			CONTINUE FOREACH;
		END IF;
		
		-- Valida que si el plazo es nulo, cero se descarta o si el monto es menor a 50.
		IF nvl(dMonto,0) = 0 or nvl(dMonto,0) < dmontoValido THEN 
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
			INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi3',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
			CONTINUE FOREACH;
		END IF;
		
		-- Valida que si el folio es nulo se descarta.
		IF nvl(cFolioApertua,'') = '' THEN 
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
			INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi4',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
			CONTINUE FOREACH;
		END IF;
		   
		-- Valida que la campaÃ±a MSI este activa, de lo contrario se descarta
		IF nvl(sCamp_Activa_Msi,0) = 0 THEN
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
			INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi5',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
			CONTINUE FOREACH;
		END IF;
		   
		-- No procesa msi de creditos tdc con status diferente de vigente/ Etapa 1, es decir con algun atraso.
		--IF (vStatus_cred != 'AA' and vStatus_cred != 'E1') OR (dMnto_Vencido + dMnto_Venc_Trasp) > 0 THEN  
		IF (dMnto_Vencido + dMnto_Venc_Trasp) > 0 THEN  
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
			INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi6',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
			CONTINUE FOREACH;
		END IF;
		
		-- Valida que el folio de la compra no se encuentre repetido en la tabla. Solo debe de existir el registro insertado por concliador de msi
		LET sCountExists = 0;
		SELECT count(folio_movto) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
		IF sCountExists != 1 THEN
		
			-- Valida estatus de registro previo, si ya esta procesado 0 pendiente o 2 procesado (Credisol Compras), se cancela MSI, de lo contrario se elimina registro previo.
			SELECT count(folio_movto) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto AND num_promo != 10 AND status not in (4,5,8);
			IF sCountExists > 0  THEN
				UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto AND status = 0 AND num_promo = 10;
				INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi7',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);				
				LET sCountExists = 0;
				CONTINUE FOREACH;
			END IF;
			
			-- Valida registros previos marcados pero no procesados, se eliminan para procesar MSI
			SELECT count(folio_movto) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto AND num_promo != 10 AND status in (4,5,8);
			IF sCountExists > 0  THEN
				DELETE FROM bdicred:sd_promocion_credito WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto AND num_promo != 10;
				DELETE FROM bdicred:sd_promocion_credito_sms WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
				LET sCountExists = 0;
			END IF;
		END IF;		

		-- Valida el monto de la deuda de la tdc vs monto de la compra msi
	    SELECT sdo_capital,  (monto_otorgado - (sdo_cap_insoluto + sdo_retenido)), (sdo_cap_insoluto + sdo_retenido) 
		  INTO dCsg_cap_vig, dCsg_linea_disp,									   dCsg_tot_liquidacion
		  FROM bdicred:sd_maesdos WHERE num_credito = vcNumCredito;	

		IF dCsg_cap_vig <= 0 THEN
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
			INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi8',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
			CONTINUE FOREACH;
		ELIF dCsg_linea_disp < dMontoIntIVA THEN 		-- Si la linea disponible no cubre los intereses (0)
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
			INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi9',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);			
			CONTINUE FOREACH;
		ELIF dCsg_cap_vig < dMonto THEN					-- Si la deuda de la tdc es menor al monto del registro de MSI se actualiza el monto
			UPDATE bdicred:"informix".sd_promocion_credito SET monto_actual = dCsg_cap_vig WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
			LET dMonto = dCsg_cap_vig;
			IF nvl(dMonto,0) = 0 or nvl(dMonto,0) < dmontoValido THEN 
				UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
				INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi13',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
				CONTINUE FOREACH;
			END IF;
		END IF;
		
	
		-- Inicializa varaibles que regresan los procesos de la proyeccion y sp principal.
		LET cCodRetPP			= '';
	    LET cMensajeRetPP		= '';
		LET dTotalPagarPP		= 0.0;
		LET sNumPlazoPP			= 0;
		LET dPagoMensualPP		= 0.0;
		LET dInteresIvaPP		= 0.0;
		LET cCodRetPrin			= '';
		LET dRemanentePrin		= 0.0;
		LET dIntMoratorioPrin	= 0.0;
		LET dIntVencidoPrin		= 0.0;
		LET dCapVencidoPrin		= 0.0;
		LET dIntVigentePrin		= 0.0;
		LET dCapVigentePrin		= 0.0;
		LET dImpuestoPrin		= 0.0;
		LET dComisionesPrin		= 0.0;
		LET dSeguroPrin			= 0.0;

		LET cFolioApertua = TRIM(NVL(cFolioApertua,''));
		LET cFolioMovto = TRIM(NVL(cFolioMovto,''));
		
		
		-- Se consulta referencias de retenidos en la tabla sd_maeretenido (en caso de que requiera actualizarse estatus por error [sd_promocion_credito.status = 4])	
		FOREACH
			SELECT referencia, folio_suc INTO vRef, vFolio FROM "informix".sd_maeretenido
		     WHERE empresa = '001' AND num_credito = vcNumCredito AND estatus = 'R' AND monto IN(dMonto,dMontoIntIVA) AND fecha = dFechaPromo
			   
			LET vRef = NVL(vRef,'');
			LET vFolio = NVL(vFolio,'');
			
			IF vFolio = cFolioMovto THEN
				LET vReferencia = vRef;
			ELIF LEFT(vRef,16) = cFolioApertua THEN
				LET vReferencia2 = vRef;
			END IF;
		END FOREACH
		
		
		-- Valida si existe previo registro por compra descartada para pf.
		SELECT count(*) INTO sContador_sms FROM bdicred:sd_promocion_credito_sms WHERE folio_compra_sms = cFolioMovto AND num_credito = vcNumCredito;
		IF sContador_sms > 0 THEN
			DELETE FROM bdicred:sd_promocion_credito_sms WHERE folio_compra_sms = cFolioMovto AND num_credito = vcNumCredito;
		END IF;
		
		-- Inserta registro en tabla sd_promocion_credito_sms para manejo de sms y proyecciones
		INSERT INTO bdicred:sd_promocion_credito_sms(empresa, num_credito , num_cte,  mnto_compra, folio_compra_sms, fecha_invitacion, tipo_sms, num_promo    , fecha_env_sms_inv, plazos_invita, tasas_invita, fecha_insert )
		                                        VALUES('001', vcNumCredito, vcNumCte, dMonto     , cFolioMovto     , vc_dtFechaHoy   , '1'     , sNumPromocion, CURRENT          , sPlazo       , sTasa		  , CURRENT);		
		
		-- Ejecuta proceso de proyeccion para MSI  
		EXECUTE PROCEDURE bdicred:"informix".sp_msi_proyecta_msi(2, cSucursal, cEjecutivo, sNumPromocion, vcNumCredito, '', dMonto, sPlazo, sTasa, cFolioMovto)
		   INTO cCodRetPP, cMensajeRetPP, dTotalPagarPP, sNumPlazoPP, dPagoMensualPP, dInteresIvaPP, dSaldoTdcPP, cFolioPromoPP, cNumProm_proy;		
			   
		IF cCodRetPP::INTEGER = 443 OR cCodRetPP = '000005' THEN        -- 00443 - El plazo no es valido para la promocion

            INSERT INTO bdicred:sd_bitacora_promocion VALUES('001', vcNumCredito, 'sp_msi_proces_msi10', vc_dtFechaHoy, CURRENT, '', sNumPromocion, cCodRetPP);
            LET cCodRet = cCodRetPP;
            LET cMensajeRet = cMensajeRetPP;
			
			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '4', envio_result_sms = '0', status_envio_r_sms = '0' WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND num_promo = sNumPromocion AND folio_movto = cFolioMovto;
			LET cCodRet = '000000';
			CONTINUE FOREACH;

        ELIF cCodRetPP::INTEGER <> 0 AND cCodRetPP NOT IN ('03433','07433','11433') THEN 	-- El cliente no es viable para diferir (cuando se sobregira con la credisol)

			--Registra error en bitacora
            INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi11',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRetPP);
            -- LLAMA AL REVERSO PROMO PARA LIBERAR EL RETENIDO DE LOS INTERESES
			EXECUTE PROCEDURE bdicred:"informix".sp_reverso_promo(vcNumCredito, cFolioMovto, 1) INTO cCodRetRP, cMensajeRetRP;
			
			-- Actualiza el estatus como error de la proyeccion
            IF cCodRetRP::INTEGER <> 0 THEN
			
                UPDATE bdicred:"informix".sd_promocion_credito SET status = 4
                 WHERE num_credito = vcNumCredito
				   AND num_promo = sNumPromocion
                   AND folio_movto = cFolioMovto;
				
				UPDATE "informix".sd_maeretenido SET estatus = 'S'
				 WHERE num_credito = vcNumCredito
				   AND referencia IN(vReferencia, vReferencia2)
				   AND estatus = 'R'
				   AND fecha = dFechaPromo;
			
                LET cCodRet = '000005';
                LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO DE REVERSA PROMO';
            END IF;
			
			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '0' WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
			LET cCodRet = '000000';
			CONTINUE FOREACH;
			
		ELIF cCodRetPP::INTEGER <> 0 THEN
		
			--Registra error en bitacora
            INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi12',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRetPP);
			
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND num_promo = sNumPromocion AND folio_movto = cFolioMovto;
			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '4', envio_result_sms = '0', status_envio_r_sms = '0' WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
			LET cCodRet = '000000';
			CONTINUE FOREACH;
			
		END IF;

		--- Proceso generico para generar un folio
		LET cCodRetGF = '000000';
		SELECT cEjecutivo || substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
			||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
			||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
			||lpad(bdicheq:sp_random(),2,'0')
		INTO cFolioSucGF 
		FROM sysmaster:sysshmvals;
			-------
			-- Valida folio no exista
			LET sCountExists = 0;  
			SELECT COUNT(folio_suc) INTO sCountExists FROM bdicred:"informix".sd_maeretenido 
			 WHERE empresa = '001' AND num_credito = vcNumCredito AND folio_suc = cFolioSucGF;
			IF sCountExists > 0 THEN
				SELECT cEjecutivo || substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
					||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
					||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
					||lpad(bdicheq:sp_random(),2,'0'), sysmaster:yieldn( 1 )
				  INTO cFolioSucGF, sYield FROM sysmaster:sysshmvals;
			END IF;
		-------
		IF cCodRetGF::INTEGER <> 0 THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
            CONTINUE FOREACH;
		ELSE

			-- Manda a llamar al proceso llamado principal para realizar el abono por el monto a diferir
			--EXECUTE PROCEDURE bdicred:"informix".principal('001',vcNumCredito,1,dMonto,cEjecutivo,cSucursal,cFolioSucGF,'6030')
			EXECUTE PROCEDURE bdicred:"informix".principal('001', vcNumCredito, 1, dMonto, cEjecutivo, cSucursal, cFolioSucGF, '4404')
			INTO cCodRetPrin,dRemanentePrin,dIntMoratorioPrin,dIntVencidoPrin,dCapVencidoPrin,dIntVigentePrin,dCapVigentePrin,dImpuestoPrin,dComisionesPrin,dSeguroPrin;

			IF cCodRetPrin::INTEGER <> 0 THEN
				-- Actualiza el status a 4 como error en el proceso
			   UPDATE bdicred:"informix".sd_promocion_credito SET status = 4 
                 WHERE num_credito = vcNumCredito
				   AND num_promo = sNumPromocion
                   AND folio_movto = cFolioMovto;				  
				
				UPDATE "informix".sd_maeretenido SET estatus = 'S'
				 WHERE num_credito = vcNumCredito
				   AND referencia IN(vReferencia, vReferencia2)
				   AND estatus = 'R'
				   AND fecha = dFechaPromo;
				
				-- Marca el registro para el envio de sms no exitoso
				UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '0' WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
				CONTINUE FOREACH;
			ELSE
				LET cCodRetGF = '000000';
				IF cCodRetGF::INTEGER <> 0 THEN
					LET cCodRet = '000003';
					LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
                    CONTINUE FOREACH;
				ELSE
																																						
					INSERT INTO bdicred:"informix".sd_maeretenido(empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
					VALUES('001',vcNumCredito,cFolioSucGF,vc_dtFechaHoy,CURRENT HOUR TO FRACTION(3),'4246',0,dMonto,cEjecutivo,'R',cFolioApertua||' MESES SIN INTERESES',cSucursal,0);

					-- Se genera el movimiento de la apertura de la compra a meses.																		
					EXECUTE PROCEDURE bdicred:"informix".genmov_tc('001',vcNumCredito,vProducto,vc_dtFechaHoy,dMonto,cFolioSucGF,cSucursal,vDivisa,'4246','','MESES SIN INTERESES',v_tipocambio,0,cEjecutivo,vsucorig,'','')
					INTO cCodRetGenMov, cMsjeGenMov;

					IF cCodRetGenMov::INTEGER <> 0 THEN
						LET cCodRet = '000006';
						LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO DE MOVIMIENTO DE APERTURA DE LA COMPRA A MESES';
                        CONTINUE FOREACH;
					END IF

					-- Actualiza el saldo retenido en la tabla de saldos
					UPDATE bdicred:"informix".sd_maesdos
					   SET sdo_retenido = sdo_retenido + dMonto
					 WHERE num_credito = vcNumCredito;

					-- Actualiza el status a 1
					UPDATE bdicred:"informix".sd_promocion_credito SET status = 1
					 WHERE num_credito = vcNumCredito
					   AND num_promo = sNumPromocion
					   AND folio_movto = cFolioMovto;					   

					-- Manda a llamar a el proceso de asignacion de solicitud
					EXECUTE PROCEDURE bdisolic:"informix".asigna_numsol('001','8900') INTO cCodRetANS, cNumSolANS;
					IF cCodRetANS::INTEGER <> 0 THEN
						LET cCodRet = '000004';
						LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO DE LA ASIGNACION DE LA SOLICITUD';
					ELSE
						-- Actualiza el numero de solicitud del prestamo en la tabla de las promociones
						let cNumSolANS = cNumSolANS;
						let vcNumCredito = vcNumCredito;
						let cFolioMovto = cFolioMovto;
						LET sNumPromocion = sNumPromocion;
						
						UPDATE bdicred:"informix".sd_promocion_credito SET num_sol_prestamo = cNumSolANS
						 WHERE num_credito = vcNumCredito
						   AND num_promo = sNumPromocion
						   AND folio_movto = cFolioMovto;

						-- Manda llamar al proceso de apertura de credito de prestamos.
						--EXECUTE PROCEDURE bdicred:"informix".sp_apercred1_credisol('001', cNumSolANS, cEjecutivo, sPlazo, cNomPromocion, dMonto, '', dPagoMensualPP)
						EXECUTE PROCEDURE bdicred:"informix".sp_msi_apercred1_msi('001', cNumSolANS, cEjecutivo, sPlazo, cNomPromocion, dMonto, '', dPagoMensualPP)
						INTO cCodRetAP, dTasaInteres, dTasaMora, dCatIva, cMercadeo;

						IF cCodRetAP::INTEGER <> 0 THEN
							EXECUTE PROCEDURE bdicred:"informix".reversion('001', cSucursal, cEjecutivo, cFolioSucGF, "M") INTO cCodRetRev;

							-- Actualiza el estatus a 4 como credito que se trabajo y obtuvo un error
							UPDATE bdicred:"informix".sd_promocion_credito
							   SET status = 4, num_sol_prestamo = ''
							 WHERE num_credito = vcNumCredito
							   AND num_promo = sNumPromocion
						       AND folio_movto = cFolioMovto;
				
							-- Se agrega cambio de estatus de la tabla sd_maeretenido
							UPDATE "informix".sd_maeretenido SET estatus = 'S'
							 WHERE empresa = '001' 
							   AND num_credito = vcNumCredito
							   AND referencia IN(vReferencia, vReferencia2)
							   AND estatus = 'R'
							   AND fecha = dFechaPromo;
							
							-- Regresa la secuencia anterior
							UPDATE bdisolic:"informix".ss_solic_producto SET secuencia_prod = secuencia_prod - 1
							 WHERE empresa = '001' AND num_producto = '8900';

							UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '0' 
							 WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;

							CONTINUE FOREACH;
						ELSE
							-- Actualiza el status a 2, es decir credisolucion vigente (creada correctamente)
							UPDATE bdicred:"informix".sd_promocion_credito SET status = 2, mensualidad = dPagoMensualPP, fecha = vc_dtFechaHoy
							WHERE num_credito = vcNumCredito AND num_promo = sNumPromocion AND folio_movto = cFolioMovto;

                            -- Actualiza registro de mov_dia con la apertura del credito
                            UPDATE bdicred:sd_movdia SET referencia = cFolioSucGF || ' ' || cNumSolANS
                             WHERE empresa = '001' AND num_credito = vcNumCredito 
                               AND codigo_fun = '060' AND codigo_ref = 10 AND folio_suc = cFolioSucGF;
							   							   
							-- Marca registro de apertura OK si es contratacion por SMS, para su envio posterior de SMS correspondiente.
							 UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '7', envio_result_sms = '1', status_envio_r_sms = '0', num_credisolucion = cNumSolANS
							 WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
							LET cCodRet = '000000';
							
						END IF
					END IF
				END IF
			END IF
		END IF
	END FOREACH
	
	IF cCodRet <> '00000' THEN
        INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_procesa_msi',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
    END IF;

	RETURN cCodRet, cMensajeRet;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que realiza la confirmacion de Meses sin Intereses',
'FECHA DE CREACION: Octubre 2021',
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_consulta_credito_atm(pTipoProducto CHAR(02), pNumCredito CHAR(20), pNumTarjetaDebito CHAR(20), pNumCliente CHAR(20))
RETURNING CHAR(05)       AS Codigo_Retorno,
          CHAR(02)       AS Tipo_Credito,
          VARCHAR(200)   AS Nombre_Cliente,
          CHAR(20)	 	 AS Numero_Credito,
--          MONEY(16,2)	 AS Pago_Corte,
          MONEY(16,2)	 AS Pago_Minimo,
--          MONEY(16,2)	 AS Total_a_Pagar,
          MONEY(16,2)	 AS Pago_No_Generar_Intereses,
          MONEY(16,2)	 AS Saldo_Total,
          DATE			 AS Fecha_Limite_Pago,
		  CHAR(16)	 	 AS Tarjeta_credito;
	
	
	
	
	

--*******************************************************************************************************
-- Realizo   : 
-- Proyecto  : 
-- Actividad : 
-- Fecha     : 

--Autor: 
--Fecha: 05/05/2022
--Modificacion: 
--*******************************************************************************************************

DEFINE cCodRet         CHAR(6);
DEFINE cErrorInfo      CHAR(80);
DEFINE cErrorInfoR     CHAR(80);
DEFINE iSqlerr         INTEGER;
DEFINE sIsamErr        SMALLINT;
DEFINE iRegistros      INTEGER;


DEFINE cNumCte			CHAR(20);
DEFINE cNumCredito     CHAR(20);
DEFINE cCodprod        CHAR(2);
DEFINE cEmpresa        CHAR(3);
DEFINE cTipoCredito	   CHAR(2);
DEFINE cApellPaterno   CHAR(26);
DEFINE cApellMaterno   CHAR(26);
DEFINE cNombre1 	   CHAR(26);
DEFINE cNombre2		   CHAR(26);
DEFINE cNomCliente		CHAR(200);

DEFINE auxNumCte		CHAR(20);
DEFINE auxCont			INTEGER;

DEFINE cMensajeRetornoCSG	CHAR(80);
DEFINE cNumeroCreditoCSG	CHAR(20);
DEFINE cCodigoTipcredCSG	CHAR(2);
DEFINE dFechaOrigenCSG		DATE;
DEFINE dFechaProxPagoCSG	DATE;
DEFINE dPagoMinimoCSG		DECIMAL(18,2);
DEFINE dFechaUltPagoCSG		DATE;
DEFINE iPlazoCSG			INTEGER;
DEFINE iPagosRealizadosCSG	INTEGER;
DEFINE dLineaOtorgadaCSG	DECIMAL(18,2);
DEFINE dTasaInteresCSG		DECIMAL(9,6);
DEFINE dTasaMoratoriosCSG	DECIMAL(9,6);
DEFINE dMontoSbcCSG			DECIMAL(14,2);
DEFINE dCapVigCSG			DECIMAL(18,2);
DEFINE dCapTransCSG			DECIMAL(18,2);
DEFINE dCapVdoExigCSG		DECIMAL(18,2);
DEFINE dCapVdoNoExigCSG		DECIMAL(18,2);
DEFINE dSdoActTotalCapCSG	DECIMAL(18,2);
DEFINE dIntVigCSG			DECIMAL(18,2);
DEFINE dIntVdoCSG			DECIMAL(18,2);
DEFINE dIntMoratoriosCSG	DECIMAL(18,2);
DEFINE dIntMesCSG			DECIMAL(18,2);
DEFINE dSdoActTotalIntCSG	DECIMAL(18,2);
DEFINE dIvaIntVigCSG		DECIMAL(18,2);
DEFINE dIvaIntVdoCSG		DECIMAL(18,2);
DEFINE dIvaIntMoratoriosCSG	DECIMAL(18,2);
DEFINE dIvaIntMesCSG		DECIMAL(18,2);
DEFINE dSdoActTotalIvaCSG	DECIMAL(18,2);
DEFINE dComPendCSG			DECIMAL(18,2);
DEFINE dIvaComCSG			DECIMAL(18,2);
DEFINE dSdoRetenidoCSG		DECIMAL(18,2);
DEFINE dTotalLiquidacionCSG	DECIMAL(18,2);
DEFINE dIntDevengadoCSG		DECIMAL(18,2);
DEFINE dIvaIntDevengadoCSG	DECIMAL(18,2);
DEFINE dLineaDisponibleCSG	DECIMAL(18,2);
DEFINE dPagosVdosCSG		DECIMAL(18,2);
DEFINE cDescStatusCredCSG	CHAR(60);
DEFINE iIdBloqueoCredCSG	INTEGER;
DEFINE cBloqueoCtaCSG		CHAR(60); 
DEFINE cIdCausaBloqueoCSG	CHAR(3);
DEFINE cCausaBloqueoCtaCSG	CHAR(50);
DEFINE cIdSitEspCteCSG		CHAR(1);
DEFINE iIdCausaEspCteCSG	INTEGER;
DEFINE cSitEspCteCSG		CHAR(75);
DEFINE cIdSitEspCredCSG		CHAR(1);
DEFINE iIdCausaEspCredCSG	INTEGER;
DEFINE cSitEspCredCSG		CHAR(75);
DEFINE dPagoCorte			DECIMAL(18,2);
DEFINE dPagoMinimo 			DECIMAL(18,2);
DEFINE dSdoTotalPagar 		DECIMAL(18,2);
DEFINE dPagoNoGenInteres 	DECIMAL(18,2);
DEFINE dSaldoTotal			DECIMAL(18,2);
DEFINE dFechaLimPago 		DATE;
DEFINE cNumProducto			CHAR(4);
DEFINE cNumProductoVal		CHAR(4);
DEFINE cStatusCred			CHAR(60);
DEFINE cStatusCta			CHAR(60);
DEFINE cTipoTarjeta			CHAR(1);
DEFINE cNumTarjetaCredito	CHAR(16);
DEFINE cNumTDC              CHAR(16);


LET cCodRet         = '000000';
LET cErrorInfo      = "";
--LET cErrorInfoR     = "OPERACION EXITOSA";
LET iSqlerr         = 0;
LET iRegistros      = 0;

LET cNumCte			= 0;
LET cNumCredito     = '';
LET cCodprod        = '';
LET cEmpresa		= '001';
LET cTipoCredito	= '';
LET cApellPaterno   = '';
LET cApellMaterno   = '';
LET cNombre1 	    = '';
LET cNombre2		= '';
LET cNomCliente		= '';

LET cMensajeRetornoCSG      = 'PROCESO EXITOSO';
LET cNumeroCreditoCSG		= '';
LET cCodigoTipcredCSG		= '';
LET dFechaOrigenCSG			= '';
LET dFechaProxPagoCSG		= '';
LET dPagoMinimoCSG			= 0	;
LET dFechaUltPagoCSG		= '';
LET iPlazoCSG				= 0;
LET iPagosRealizadosCSG		= 0;
LET dLineaOtorgadaCSG		= 0;
LET dTasaInteresCSG			= 0;
LET dTasaMoratoriosCSG		= 0;
LET dMontoSbcCSG			= 0;
LET dCapVigCSG				= 0;
LET dCapTransCSG			= 0;
LET dCapVdoExigCSG			= 0;
LET dCapVdoNoExigCSG		= 0;
LET dSdoActTotalCapCSG		= 0;
LET dIntVigCSG				= 0;
LET dIntVdoCSG				= 0;
LET dIntMoratoriosCSG		= 0;
LET dIntMesCSG				= 0;
LET dSdoActTotalIntCSG		= 0;
LET dIvaIntVigCSG			= 0;
LET dIvaIntVdoCSG			= 0;
LET dIvaIntMoratoriosCSG	= 0;
LET dIvaIntMesCSG			= 0;
LET dSdoActTotalIvaCSG		= 0;
LET dComPendCSG				= 0;
LET dIvaComCSG				= 0;
LET dSdoRetenidoCSG			= 0;
LET dTotalLiquidacionCSG	= 0;
LET dIntDevengadoCSG		= 0;
LET dIvaIntDevengadoCSG		= 0;
LET dLineaDisponibleCSG		= 0;
LET dPagosVdosCSG			= 0;
LET cDescStatusCredCSG		= '';
LET iIdBloqueoCredCSG		= 0;
LET cBloqueoCtaCSG			= '';
LET cIdCausaBloqueoCSG		= '';
LET cCausaBloqueoCtaCSG		= '';
LET cIdSitEspCteCSG			= '';
LET iIdCausaEspCteCSG		= 0;
LET cSitEspCteCSG			= '';
LET cIdSitEspCredCSG		= '';
LET iIdCausaEspCredCSG		= 0;
LET cSitEspCredCSG			= '';
LET dPagoCorte				= 0;
LET dPagoMinimo 			= 0;
LET dSdoTotalPagar 			= 0;
LET dPagoNoGenInteres 		= 0;
LET dSaldoTotal				= 0;
LET dFechaLimPago 			= DATE(1);
LET cNumProducto			= '';
LET cNumProductoVal			= '';
LET cStatusCred				= '';
LET cStatusCta				= '';
LET cTipoTarjeta			= '';
LET cNumTarjetaCredito		= '';
LET cNumTDC                 = '';
LET auxNumCte				= '';
LET auxCont					= 0;

BEGIN

ON EXCEPTION  SET iSqlerr, sIsamErr, cErrorInfo
	IF iSqlerr <> 0  THEN
		LET  cCodRet  = iSqlerr;
--		LET cErrorInfoR = cErrorInfo;
     RETURN cCodRet,cTipoCredito,cNomCliente,cNumCredito,dPagoMinimo,dPagoNoGenInteres,dSaldoTotal,dFechaLimPago,cNumTDC;

	END IF;
END  EXCEPTION

--SET DEBUG FILE TO '/home/e10000646/AJUSTES_SPS_APP/Base_de_Datos/informix/bdicred/SP/sp_consulta_credito_atm.out';
--TRACE ON;

IF NVL(TRIM(pTipoProducto),'') = '' THEN
	LET cCodRet     = '00001';	-- 'NO SE ESPECIFICA EL TIPO DE PRODUCTO'
	RETURN cCodRet,cTipoCredito,cNomCliente,cNumCredito,dPagoMinimo,dPagoNoGenInteres,dSaldoTotal,dFechaLimPago,cNumTDC;
END IF;

IF NVL(TRIM(pNumTarjetaDebito),'') = '' AND NVL(TRIM(pNumCredito),'') = '' AND NVL(TRIM(pNumCliente),'') = '' THEN
	LET cCodRet     = '00002';	-- 'NO SE ESPECIFICA NINGUN DATO DE CONSULTA DE ENTRADA'
	RETURN cCodRet,cTipoCredito,cNomCliente,cNumCredito,dPagoMinimo,dPagoNoGenInteres,dSaldoTotal,dFechaLimPago,cNumTDC;
END IF;

SET ISOLATION TO dirty READ;

	
IF pTipoProducto = 'TC' THEN
			
	IF NVL(TRIM(pNumTarjetaDebito),'') != '' THEN
	
		/*SELECT mae.num_producto,mae.status_cred,mae.num_credito,tar.numcte, sm.status_cta INTO cNumProducto,cStatusCred,cNumCredito,cNumCte,cStatusCta
		FROM bdicheq:sc_tarjeta tar
		INNER JOIN bdicred:sd_maecred mae ON mae.numcte = tar.numcte
		JOIN bdicheq:sc_maechq sm ON sm.cuenta = tar.cuenta
		WHERE tar.num_tarjeta = pNumTarjetaDebito ;*/
	
		SELECT tar.numcte INTO auxNumCte FROM bdicheq:sc_tarjeta tar --primero obtener el nÃºmero de cliente en bdicheq:sc_tarjeta
		WHERE tar.num_tarjeta = pNumTarjetaDebito;
		
		IF NVL(TRIM(auxNumCte),'') != '' THEN
						
			SELECT COUNT(*) INTO auxCont FROM bdicred:sd_maecred   --num cliente hacer el count a maecred
			WHERE numcte = auxNumCte AND status_cred IN ('E1','E2','E3') and num_producto <> '7800'; 
			
			IF auxCont > 1 THEN --si es mayor a 1 2o mÃ¡sâ  	hacer counts a maecred para todos los 6001
			
				LET auxCont = 0;
				
				SELECT COUNT(*) INTO auxCont FROM bdicred:sd_maecred   
				WHERE numcte = auxNumCte AND num_producto = '6001';
				
								
				IF auxCont = 1 THEN  --si es 1 se consulta el 6001
				
					SELECT mae.num_producto,mae.status_cred,mae.num_credito,tar.numcte, sm.status_cta INTO cNumProducto,cStatusCred,cNumCredito,cNumCte,cStatusCta
					FROM bdicheq:sc_tarjeta tar
					INNER JOIN bdicred:sd_maecred mae ON mae.numcte = tar.numcte
					JOIN bdicheq:sc_maechq sm ON sm.cuenta = tar.cuenta
					WHERE tar.num_tarjeta = pNumTarjetaDebito AND
					mae.num_producto = '6001' AND mae.status_cred IN ('E1','E2','E3');
					
				ELSE --	si son mÃ¡s se realiza el limit 1 quitar lo del 6001
					
					SELECT LIMIT 1 mae.num_producto,mae.status_cred,mae.num_credito,tar.numcte, sm.status_cta INTO cNumProducto,cStatusCred,cNumCredito,cNumCte,cStatusCta
					FROM bdicheq:sc_tarjeta tar
					INNER JOIN bdicred:sd_maecred mae ON mae.numcte = tar.numcte
					JOIN bdicheq:sc_maechq sm ON sm.cuenta = tar.cuenta
					WHERE tar.num_tarjeta = pNumTarjetaDebito AND mae.status_cred IN ('E1','E2','E3') and num_producto <> '7800';
					
				END IF;
			
			ELSE
				--1âhacer la consulta tal como se tiene .
				SELECT mae.num_producto,mae.status_cred,mae.num_credito,tar.numcte, sm.status_cta INTO cNumProducto,cStatusCred,cNumCredito,cNumCte,cStatusCta
				FROM bdicheq:sc_tarjeta tar
				INNER JOIN bdicred:sd_maecred mae ON mae.numcte = tar.numcte
				JOIN bdicheq:sc_maechq sm ON sm.cuenta = tar.cuenta
				WHERE tar.num_tarjeta = pNumTarjetaDebito AND
				mae.num_producto <> '7800' and mae.status_cred IN ('E1','E2','E3');
				
			END IF;
			
		END IF;
		
		
		
			--AGO - ValidaciÃ³n de Status
			IF (NVL(TRIM(cStatusCta),'') != '' and NVL(TRIM(cStatusCta),'') NOT IN ('1','4')) or NVL(TRIM(cNumCredito),'') != ''  THEN
				LET cCodRet     = '00004';	-- 'STATUS INCORRECTO CTA'
				RETURN cCodRet,cStatusCta,'nocta','','',0,0,0,DATE(1);
			END IF;
	
		
			SELECT st.num_tarjeta INTO cNumTDC FROM bdicred:sd_tarjeta st
				where st.secuencia = (SELECT MAX(sdt.secuencia) FROM bdicred:sd_tarjeta sdt WHERE sdt.num_credito=cNumCredito) 
				AND st.status_tar='A' AND st.num_credito=cNumCredito;

				
			EXECUTE PROCEDURE "informix".sp_enmascarado(cNumTDC,2) INTO cCodRet,cNumTDC;
	ELIF NVL(TRIM(pNumCredito),'') != '' THEN
		SELECT num_producto,status_cred,num_credito,numcte INTO cNumProducto,cStatusCred,cNumCredito,cNumCte
		FROM bdicred:sd_maecred
		WHERE num_credito = pNumCredito;
		
			SELECT st.num_tarjeta  INTO cNumTDC FROM bdicred:sd_tarjeta st
				where st.secuencia = (SELECT MAX(sdt.secuencia) FROM bdicred:sd_tarjeta sdt WHERE sdt.num_credito=pNumCredito) 
				AND st.status_tar='A' AND st.num_credito=pNumCredito;
				 
				EXECUTE PROCEDURE "informix".sp_enmascarado(cNumTDC,2) INTO cCodRet,cNumTDC;
	ELSE
		SELECT LIMIT 1 num_producto,status_cred,num_credito,numcte INTO cNumProducto,cStatusCred,cNumCredito,cNumCte
		FROM bdicred:sd_maecred
		WHERE numcte = pNumCliente;
	END IF;
	
	
	--AGO - ValidaciÃ³n de Status
	IF (NVL(TRIM(cStatusCred),'') NOT IN ('E1','E2','E3')) THEN
			LET cCodRet     = '00004';	-- 'STATUS INCORRECTO'
			RETURN cCodRet,'',cStatusCred,'','',0,0,0,DATE(1);
	END IF;

	
	--AGO - ValidaciÃ³n de producto 
	IF NVL(TRIM(cNumProducto),'') != '' AND NVL(TRIM(cNumProducto),'') in ('7800','6900','8900') THEN
			LET cCodRet     = '00004';	-- 'NO SE ACEPTA PRODUCTO 7800, 6900,8900'
			RETURN cCodRet,'','NO PROD 7800',cNumProducto,'',0,0,0,DATE(1);
	END IF;
	
	SELECT TRIM(NVL(apell_paterno,'')),TRIM(NVL(apell_materno,'')),TRIM(NVL(nombre1,'')),TRIM(NVL(nombre2,'')) INTO cApellPaterno,cApellMaterno,cNombre1,cNombre2
	FROM bdinteg:si_cliente 
	WHERE numcte = cNumCte;

	IF cNombre1 IS NOT NULL AND cNombre1 != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cNombre1,1) INTO cCodRet,cNombre1;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cNombre1);
	ELSE
		LET cCodRet     = '00004';	-- 'NO SE OBTUVIERON RESULTADOS'
		RETURN cCodRet,'','sin datos','','',0,0,0,DATE(1);
	END IF;

	IF cNombre2 IS NOT NULL AND cNombre2 != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cNombre2,1) INTO cCodRet,cNombre2;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cNombre2);
	END IF;

	IF cApellPaterno IS NOT NULL AND cApellPaterno != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cApellPaterno,1) INTO cCodRet,cApellPaterno;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cApellPaterno);
	END IF;
	
	IF cApellMaterno IS NOT NULL AND cApellMaterno != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cApellMaterno,1) INTO cCodRet,cApellMaterno;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cApellMaterno);
	END IF;

	FOREACH                
		EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(cEmpresa, cNumCredito) INTO
				cCodRet, cMensajeRetornoCSG, cNumeroCreditoCSG, cCodigoTipcredCSG, dFechaOrigenCSG, dFechaProxPagoCSG,
				dPagoMinimoCSG, dFechaUltPagoCSG, iPlazoCSG, iPagosRealizadosCSG, dLineaOtorgadaCSG, dTasaInteresCSG, dTasaMoratoriosCSG,
				dMontoSbcCSG, dCapVigCSG, dCapTransCSG, dCapVdoExigCSG, dCapVdoNoExigCSG, dSdoActTotalCapCSG, dIntVigCSG, dIntVdoCSG, dIntMoratoriosCSG,
				dIntMesCSG, dSdoActTotalIntCSG, dIvaIntVigCSG, dIvaIntVdoCSG, dIvaIntMoratoriosCSG, dIvaIntMesCSG, dSdoActTotalIvaCSG, dComPendCSG,
				dIvaComCSG, dSdoRetenidoCSG, dTotalLiquidacionCSG, dIntDevengadoCSG, dIvaIntDevengadoCSG, dLineaDisponibleCSG, dPagosVdosCSG,
				cDescStatusCredCSG, iIdBloqueoCredCSG, cBloqueoCtaCSG, cIdCausaBloqueoCSG, cCausaBloqueoCtaCSG, cIdSitEspCteCSG,
				iIdCausaEspCteCSG, cSitEspCteCSG, cIdSitEspCredCSG, iIdCausaEspCredCSG, cSitEspCredCSG

		LET iRegistros = iRegistros + 1;
		LET cTipoCredito = pTipoProducto;

		IF cCodRet::integer != 0 THEN
			IF cCodRet::integer != 2 THEN
				LET cCodRet     = '00006'; -- 'ERROR EN LA CONSULTA DE SALDOS'
			ELSE
				LET cCodRet     = '00007'; -- 'NO HAY INFORMACION DE SALDOS'
			END IF;
			LET iRegistros  = 0; 
			EXIT FOREACH;
		END IF;

		IF dPagoMinimoCSG <= 0 THEN
		LET dPagoMinimo = '0';
		ELSE
		LET dPagoMinimo = dPagoMinimoCSG;
		END IF;
		
		IF dTotalLiquidacionCSG <= 0 THEN
		LET dSaldoTotal = '0';
		ELSE
		LET dSaldoTotal = dTotalLiquidacionCSG;
		END IF;
		
		IF dSdoActTotalCapCSG <= 0 THEN
		LET dPagoNoGenInteres = '0';
		ELSE
		LET dPagoNoGenInteres = dSdoActTotalCapCSG;
		END IF;
		
		IF dFechaProxPagoCSG = '01-01-1900' THEN
		LET dFechaLimPago = '';
		ELSE
		LET dFechaLimPago = dFechaProxPagoCSG;
		END IF;
				
		RETURN cCodRet,cTipoCredito,cNomCliente,cNumCredito,dPagoMinimo,dPagoNoGenInteres,dSaldoTotal,dFechaLimPago,cNumTDC WITH RESUME;
	END FOREACH;			


ELIF pTipoProducto =  'OT' THEN    --Gabo
	
	IF NVL(TRIM(pNumTarjetaDebito),'') != '' THEN
		
		let cNumTarjetaCredito = pNumTarjetaDebito;
		
		SELECT creditodebito INTO cTipoTarjeta FROM intercard:bines -- Para obtener si es Credito o debito de acuerdo al bin de la tarjeta
		WHERE bin = SUBSTR (cNumTarjetaCredito,0,6);
		
		LET cTipoTarjeta = cTipoTarjeta; -- para ver el resultado de la variable
		
		IF cTipoTarjeta = 'D' THEN
			LET cCodRet     = '00009';	-- 'NO PUEDES BUSCAR UNA TDD PARA PAGO DE OTRA TARJETA'
			RETURN cCodRet,'','','','',0,0,0,DATE(1);
		ELIF cTipoTarjeta is null THEN
			LET cCodRet     = '00010';	-- 'TARJETA INVALIDA'
			RETURN cCodRet,'','','','',0,0,0,DATE(1);
		END IF;
				
			
		SELECT num_credito, numcte INTO cNumCredito,cNumCte    -- para obtener el numero de cliente de la tdc digitada
		FROM bdicred:sd_tarjeta 
		WHERE num_tarjeta  = cNumTarjetaCredito;
		
		EXECUTE PROCEDURE "informix".sp_enmascarado(cNumTarjetaCredito,2) INTO cCodRet,cNumTDC;
	ELSE
		LET cCodRet     = '00004';	-- 'NO SE OBTUVIERON RESULTADOS'
		RETURN cCodRet,'','sin RESULTADOS','','',0,0,0,DATE(1);
	END IF;				--Gabo
	
	SELECT TRIM(NVL(apell_paterno,'')),TRIM(NVL(apell_materno,'')),TRIM(NVL(nombre1,'')),TRIM(NVL(nombre2,'')) INTO cApellPaterno,cApellMaterno,cNombre1,cNombre2
	FROM bdinteg:si_cliente 
	WHERE numcte = cNumCte;

	IF cNombre1 IS NOT NULL AND cNombre1 != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cNombre1,1) INTO cCodRet,cNombre1;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cNombre1);
	ELSE
		LET cCodRet     = '00004';	-- 'NO SE OBTUVIERON RESULTADOS'
		RETURN cCodRet,'','SIN RESULTADOS 2','','',0,0,0,DATE(1);
	END IF;

	IF cNombre2 IS NOT NULL AND cNombre2 != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cNombre2,1) INTO cCodRet,cNombre2;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cNombre2);
	END IF;

	IF cApellPaterno IS NOT NULL AND cApellPaterno != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cApellPaterno,1) INTO cCodRet,cApellPaterno;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cApellPaterno);
	END IF;
	
	IF cApellMaterno IS NOT NULL AND cApellMaterno != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cApellMaterno,1) INTO cCodRet,cApellMaterno;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cApellMaterno);
	END IF;

	FOREACH                
		EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(cEmpresa, cNumCredito) INTO
				cCodRet, cMensajeRetornoCSG, cNumeroCreditoCSG, cCodigoTipcredCSG, dFechaOrigenCSG, dFechaProxPagoCSG,
				dPagoMinimoCSG, dFechaUltPagoCSG, iPlazoCSG, iPagosRealizadosCSG, dLineaOtorgadaCSG, dTasaInteresCSG, dTasaMoratoriosCSG,
				dMontoSbcCSG, dCapVigCSG, dCapTransCSG, dCapVdoExigCSG, dCapVdoNoExigCSG, dSdoActTotalCapCSG, dIntVigCSG, dIntVdoCSG, dIntMoratoriosCSG,
				dIntMesCSG, dSdoActTotalIntCSG, dIvaIntVigCSG, dIvaIntVdoCSG, dIvaIntMoratoriosCSG, dIvaIntMesCSG, dSdoActTotalIvaCSG, dComPendCSG,
				dIvaComCSG, dSdoRetenidoCSG, dTotalLiquidacionCSG, dIntDevengadoCSG, dIvaIntDevengadoCSG, dLineaDisponibleCSG, dPagosVdosCSG,
				cDescStatusCredCSG, iIdBloqueoCredCSG, cBloqueoCtaCSG, cIdCausaBloqueoCSG, cCausaBloqueoCtaCSG, cIdSitEspCteCSG,
				iIdCausaEspCteCSG, cSitEspCteCSG, cIdSitEspCredCSG, iIdCausaEspCredCSG, cSitEspCredCSG

		LET iRegistros = iRegistros + 1;
		LET cTipoCredito = pTipoProducto;

		IF cCodRet::integer != 0 THEN
			IF cCodRet::integer != 2 THEN
				LET cCodRet     = '00006'; -- 'ERROR EN LA CONSULTA DE SALDOS'
			ELSE
				LET cCodRet     = '00007'; -- 'NO HAY INFORMACION DE SALDOS'
			END IF;
			LET iRegistros  = 0; 
			EXIT FOREACH;
		END IF;
		
		IF dPagoMinimoCSG <= 0 THEN
		LET dPagoMinimo = '0';
		ELSE
		LET dPagoMinimo = dPagoMinimoCSG;
		END IF;
		
		IF dTotalLiquidacionCSG <= 0 THEN
		LET dSaldoTotal = '0';
		ELSE
		LET dSaldoTotal = dTotalLiquidacionCSG;
		END IF;
		
		IF dSdoActTotalCapCSG <= 0 THEN
		LET dPagoNoGenInteres = '0';
		ELSE
		LET dPagoNoGenInteres = dSdoActTotalCapCSG;
		END IF;
		
		IF dFechaProxPagoCSG = '01-01-1900' THEN
		LET dFechaLimPago = '';
		ELSE
		LET dFechaLimPago = dFechaProxPagoCSG;
		END IF;
				
		RETURN cCodRet,cTipoCredito,cNomCliente,cNumCredito,dPagoMinimo,dPagoNoGenInteres,dSaldoTotal,dFechaLimPago,cNumTDC WITH RESUME;
	END FOREACH;
	
	
ELIF pTipoProducto IN ('P2', 'PN', 'P8', 'P4', 'PT', 'PM', 'PD', 'RD') THEN
/*	IF NVL(TRIM(pNumCredito),'') = '' AND NVL(TRIM(pNumCliente),'') = '' THEN
		LET cCodRet     = '00002';	-- 'NO SE ESPECIFICA NINGUN DATO DE CONSULTA DE ENTRADA'
		RETURN cCodRet,cTipoCredito,cNomCliente,cNumCredito,dPagoMinimo,dPagoNoGenInteres,dSaldoTotal,dFechaLimPago;
	END IF;*/
	
		
	CASE pTipoProducto
		WHEN 'P2' THEN LET cNumProducto = '6300';
		WHEN 'PN' THEN LET cNumProducto = '6400';
		WHEN 'P8' THEN LET cNumProducto = '7600';
		WHEN 'P4' THEN LET cNumProducto = '7700';
		WHEN 'PT' THEN LET cNumProducto = '9100';
		WHEN 'PM' THEN LET cNumProducto = '9300';
		WHEN 'PD' THEN LET cNumProducto = '6800';
		WHEN 'RD' THEN LET cNumProducto = '6011';
	END CASE;

	IF NVL(TRIM(pNumTarjetaDebito),'') != '' THEN
		SELECT mae.num_credito, tar.numcte, mae.num_producto INTO cNumCredito,cNumCte,cNumProductoVal
		FROM bdicheq:sc_tarjeta tar
		INNER JOIN bdicred:sd_maecredcrd mae ON mae.numcte = tar.numcte
		WHERE num_tarjeta = pNumTarjetaDebito and mae.num_producto = cNumProducto;
	ELIF NVL(TRIM(pNumCredito),'') != '' THEN
		SELECT LIMIT 1 num_credito, numcte, num_producto INTO cNumCredito,cNumCte,cNumProductoVal
		FROM bdicred:sd_maecredcrd
		WHERE num_credito = pNumCredito;
	ELSE
		SELECT LIMIT 1 num_credito, numcte, num_producto INTO cNumCredito,cNumCte,cNumProductoVal
		FROM bdicred:sd_maecredcrd
		WHERE numcte = pNumCliente and num_producto = cNumProducto;
	END IF;
	
	--AGO - ValidaciÃ³n de producto 
	IF NVL(TRIM(cNumProductoVal),'') != '' AND NVL(TRIM(cNumProductoVal),'') IN ('6900','8900') THEN
			LET cCodRet     = '00004';	-- 'NO SE ACEPTA PRODUCTO '6900','8900''
			RETURN cCodRet,'','NO PROD 6900 8900',cNumProductoVal,'',0,0,0,DATE(1);
	END IF;

	SELECT TRIM(NVL(apell_paterno,'')),TRIM(NVL(apell_materno,'')),TRIM(NVL(nombre1,'')),TRIM(NVL(nombre2,'')) INTO cApellPaterno,cApellMaterno,cNombre1,cNombre2
	FROM bdinteg:si_cliente 
	WHERE numcte = cNumCte;

	IF cNombre1 IS NOT NULL AND cNombre1 != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cNombre1,1) INTO cCodRet,cNombre1;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cNombre1);
	ELSE
		LET cCodRet     = '00004';	-- 'NO SE OBTUVIERON RESULTADOS'
		RETURN cCodRet,'','SIN RESULTADOS X3','','',0,0,0,DATE(1);
	END IF;

	IF cNombre2 IS NOT NULL AND cNombre2 != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cNombre2,1) INTO cCodRet,cNombre2;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cNombre2);
	END IF;

	IF cApellPaterno IS NOT NULL AND cApellPaterno != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cApellPaterno,1) INTO cCodRet,cApellPaterno;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cApellPaterno);
	END IF;
	
	IF cApellMaterno IS NOT NULL AND cApellMaterno != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cApellMaterno,1) INTO cCodRet,cApellMaterno;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cApellMaterno);
	END IF;

	FOREACH                
		EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(cEmpresa, cNumCredito) INTO
				cCodRet, cMensajeRetornoCSG, cNumeroCreditoCSG, cCodigoTipcredCSG, dFechaOrigenCSG, dFechaProxPagoCSG,
				dPagoMinimoCSG, dFechaUltPagoCSG, iPlazoCSG, iPagosRealizadosCSG, dLineaOtorgadaCSG, dTasaInteresCSG, dTasaMoratoriosCSG,
				dMontoSbcCSG, dCapVigCSG, dCapTransCSG, dCapVdoExigCSG, dCapVdoNoExigCSG, dSdoActTotalCapCSG, dIntVigCSG, dIntVdoCSG, dIntMoratoriosCSG,
				dIntMesCSG, dSdoActTotalIntCSG, dIvaIntVigCSG, dIvaIntVdoCSG, dIvaIntMoratoriosCSG, dIvaIntMesCSG, dSdoActTotalIvaCSG, dComPendCSG,
				dIvaComCSG, dSdoRetenidoCSG, dTotalLiquidacionCSG, dIntDevengadoCSG, dIvaIntDevengadoCSG, dLineaDisponibleCSG, dPagosVdosCSG,
				cDescStatusCredCSG, iIdBloqueoCredCSG, cBloqueoCtaCSG, cIdCausaBloqueoCSG, cCausaBloqueoCtaCSG, cIdSitEspCteCSG,
				iIdCausaEspCteCSG, cSitEspCteCSG, cIdSitEspCredCSG, iIdCausaEspCredCSG, cSitEspCredCSG

		LET iRegistros = iRegistros + 1;
		LET cTipoCredito = pTipoProducto;

		IF cCodRet::integer != 0 THEN
			IF cCodRet::integer != 2 THEN
				LET cCodRet     = '00006'; -- 'ERROR EN LA CONSULTA DE SALDOS'
			ELSE
				LET cCodRet     = '00007'; -- 'NO HAY INFORMACION DE SALDOS'
			END IF;
			LET iRegistros  = 0; 
			EXIT FOREACH; 
		END IF;
        
		IF dPagoMinimoCSG <= 0 and dTotalLiquidacionCSG <= 0 and dSdoActTotalCapCSG <= 0 and dFechaProxPagoCSG = '01-01-1900'  THEN
		  LET cCodRet     = '00007';	-- 'NO HAY INFORMACION DE SALDOS'
		  RETURN cCodRet,'','','','',0,0,0,DATE(1);
		ELSE
		  LET dPagoMinimo = dPagoMinimoCSG;
		  LET dSaldoTotal = dTotalLiquidacionCSG;
		  LET dPagoNoGenInteres = dSdoActTotalCapCSG;
		  LET dFechaLimPago = dFechaProxPagoCSG;
		END IF;
		
        IF dPagoMinimoCSG <= 0 THEN
		LET dPagoMinimo = '0';
		ELSE
		LET dPagoMinimo = dPagoMinimoCSG;
		END IF;
		
		IF dTotalLiquidacionCSG <= 0 THEN
		LET dSaldoTotal = '0';
		ELSE
		LET dSaldoTotal = dTotalLiquidacionCSG;
		END IF;
		
		IF dSdoActTotalCapCSG <= 0 THEN
		LET dPagoNoGenInteres = '0';
		ELSE
		LET dPagoNoGenInteres = dSdoActTotalCapCSG;
		END IF;
		
		IF dFechaProxPagoCSG = '01-01-1900' THEN
		LET dFechaLimPago = '';
		ELSE
		LET dFechaLimPago = dFechaProxPagoCSG;
		END IF;

		RETURN cCodRet,cTipoCredito,cNomCliente,cNumCredito,dPagoMinimo,dPagoNoGenInteres,dSaldoTotal,dFechaLimPago,cNumTDC WITH RESUME;
	END FOREACH;			
ELSE
	LET cCodRet     = '00003';	-- 'TIPO DE CREDITO NO VALIDO'
	RETURN cCodRet,'','','','',0,0,0,DATE(1);
END IF;
   
IF iRegistros  = 0 THEN
	LET cCodRet     = '00004';	-- 'NO SE OBTUVIERON RESULTADOS'
	RETURN cCodRet,cTipoCredito,cNomCliente,cNumCredito,dPagoMinimo,dPagoNoGenInteres,dSaldoTotal,dFechaLimPago,cNumTDC;
END IF;

END;
END PROCEDURE;