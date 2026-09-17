CREATE PROCEDURE "informix".provisionlineacred_parte_mx(pEmpresa CHAR(3), pEjecucion smallint)
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
   SET DEBUG FILE TO "/tmp/provisionlineacred_parte.out";
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

   SELECT fecha_hoy, fecha_ant, prox_fecha, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes
     INTO FechaHoy, FechaAnt, ProxFecha, PriDiaMes, PriHabMes, UltDiaMes, UltHabMes
     FROM sd_fechas WHERE empresa = pEmpresa;

    IF FechaHoy IS NULL THEN
       LET CodRet = "110";
       RETURN CodRet;
    END IF;

    SELECT * FROM bdinteg:si_sucursales
     WHERE tpo_sucursal = "S"
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
         FROM bdicred:sd_param  WHERE cod_param = (950 + pEjecucion)::CHAR(3);               
		 
        SELECT {+INDEX(sd_maecredanexo idx_sd_maecredanexo1), (sd_maecred maecred3) } a.num_credito, a.status_cred
          FROM sd_maecred a, sd_maecredanexo b
         WHERE a.empresa = pEmpresa     AND b.num_credito = a.num_credito
           AND b.empresa = a.empresa    AND b.fecha_proceso = FechaHoy
           and status_cred NOT IN ("CC", "FC")
           and a.num_credito >= cred_ini    and a.num_credito  < cred_fin    
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
		IF NumProducto ='7800' THEN		--RQM 10 617 JMAH	
			 COMMIT WORK;
			CONTINUE FOREACH;
		END IF

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
    IF ( vMarcaAyuda = 1 OR StatusCred = "CV" OR ( Campotrabajo3 = 'BAJA' AND StatusCred <> "CV") ) THEN -- Marca para bloqueo de créditos
        UPDATE sd_maesdos
           SET mto_fin_ven_trasp  = vMtofinventrasp
	     WHERE empresa = pEmpresa AND num_credito = vNumCred;
	
        CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
                               SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,FechaHoy) RETURNING CodRet;

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
                  SELECT FechaHoy, *
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
    SELECT bandera INTO wbandera_apoyo FROM sd_programa_apoyo2017 WHERE num_credito = vNumCred;
	
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
       INSERT INTO bdicred:"informix".sd_maesdos_apoyo2017
       SELECT FechaHoy, *
         FROM bdicred:"informix".sd_maesdos 
        WHERE num_credito = vNumCred AND empresa = pEmpresa;              

       INSERT INTO bdicred:"informix".sd_amortiza_credito_apoyo2017
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

      -- Marcar como crédito inactivo si no tuvo movimientos durante el período (by MACF)
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

   -- **********************************************
   -- Actualiza Tabla de Amortizaciones y Maestros
   -- **********************************************

   IF (SdoRetenido > 0) then
       CALL libera_retenido(pEmpresa, vNumCred, SdoRetenido) RETURNING CodRet, SdoRetenido;
       IF (CodRet <> "000") THEN
           LET vMensaje = " Libera Retenido";
           CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, vMensaje) RETURNING rLog;
       END IF;
   END IF;

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
          CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
                               SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,FechaHoy) RETURNING CodRet;
        IF (CodRet <> "000") THEN
          LET vMensaje = " Saldos Diarios";
          CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,vMensaje) RETURNING rLog;
       END IF;
   ELSE
          CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
                               SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,FechaHoy) RETURNING CodRet;
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
            fecha_vencido = CASE WHEN fecha_vencido IS NULL AND vFechaVencim IS NOT NULL THEN vFechaVencim ELSE fecha_vencido END                  
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
      SELECT FechaHoy, *
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
            fecha_cancelacion_h   = fecha_cancelacion,   fecha_ult_respaldo    = FechaHoy
       WHERE num_credito = vNumCred AND empresa = pEmpresa;
   END IF

 COMMIT WORK;

END FOREACH

   RETURN CodRet;
END PROCEDURE
DOCUMENT
'Procedimiento para la provision y traspaso a cartera ',
'vencida para creditos tipo tarjeta',
'AUTOR : Antonio Ruiz',
'FECHA : 30/Diciembre/2006',
'VERSION: 1.00.006',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_rep_gral_status_total(pFechaIni CHAR (10), pFechaFin CHAR(10), pOrigen CHAR(1))
	RETURNING CHAR(6)  		AS codigo_retorno,
			  CHAR(80) 		AS mensaje_retorno,
			  INTEGER  		AS total;

	---DECLARACIONES   
	DEFINE cCodRet              CHAR(6); 
	DEFINE cMensajeRet          CHAR(80);	
	DEFINE iSqlErr      	    INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE cErrorInfo           CHAR(80);

	DEFINE dPorcStatus			DECIMAL(18,2);
	DEFINE dPorcStatusAcum		DECIMAL(18,2);
	DEFINE cStatus 				CHAR(2);
	DEFINE cCausa 				CHAR(3);
	DEFINE vcDescripcion 		VARCHAR(100);
	DEFINE cBandera 			CHAR(1);
	DEFINE iTotalStatus 		INTEGER;
	DEFINE iTotal 				INTEGER;
	DEFINE iTotalRegistros 		INTEGER;
	DEFINE iTieneCausa 			INTEGER;
	DEFINE iCont 				INTEGER;
	DEFINE iTotalReg 			INTEGER;
	DEFINE dPorcStatusTotal     DECIMAL(18,2);

	---INICIALIZACIONES
	LET iSqlErr                  = 0;
	LET iIsamErr                 = 0;
	LET cErrorInfo               = "";
	LET cCodRet                  = "000000";
	LET cMensajeRet              = "SE REALIZÓ LA CONSULTA CORRECTAMENTE";
	LET dPorcStatus			     = 0;
	LET dPorcStatusAcum		     = 0;
	LET iTotalStatus			 = 0;
	LET iTotal			         = 0;
	LET iTotalRegistros			 = 0;
	LET iTieneCausa				 = 0;
	LET iCont					 = 0;
	LET iTotalReg				 = 0;
	LET vcDescripcion			 = "";
	LET cBandera				 = "";
	LET cStatus 				 = "";
	LET cCausa 					 = "";
	LET dPorcStatusTotal         = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet=cErrorInfo;
				IF iSqlErr IN (-1204,-1205,-1206) THEN
					LET cCodRet = "000002";
					LET cMensajeRet = "PARÁMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA";
				END IF;	 
				IF  cBandera = "S" THEN
					DROP TABLE tme_consultaincrementos;
				END IF;
				RETURN cCodRet, cMensajeRet, iTotalReg;
		   END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/informix/jesus/sp_rep_gral_status.out';
		--TRACE ON;

		--se validan los parametros de entrada.
		IF NVL(pFechaIni,"") = ""  OR NVL(pFechaFin,"") = "" THEN
			LET cCodRet = "000001";
			LET cMensajeRet = "FALTA PARÁMETRO DE FECHAS REQUERIDO PARA REALIZAR LA CONSULTA";
			RETURN cCodRet, cMensajeRet, iTotalReg;
		END IF;

		IF NVL(pOrigen,"") = "" THEN
			LET cCodRet = "000003";
			LET cMensajeRet = "FALTA PARÁMETRO REQUERIDO DE ORIGEN PARA REALIZAR  LA CONSULTA";
			RETURN cCodRet, cMensajeRet, iTotalReg;
		END IF;
		-- Crear una tabla temporal para insertar los datos de la consulta	
		IF EXISTS (SELECT tabname FROM systables  WHERE tabname = 'tme_consultaincrementos') THEN	
			DROP TABLE tme_consultaincrementos;
		END IF;

		-- Se crea la tabla de trabajo
		CREATE TEMP TABLE tme_consultaincrementos
		(
			status CHAR(2),
			causa	CHAR(3),
			descripcion  CHAR(100),
			totalRegistros INTEGER,
			porcentaje   decimal(18,2)		
		)WITH NO LOG;	
			
		LET cBandera = "S";

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		----se insertan el total de registros por estatus
		FOREACH WITH HOLD
			SELECT status,TRIM(descripcion)
				INTO cStatus,vcDescripcion
			FROM  "informix".sd_status_aumlincred 
				
			FOREACH WITH HOLD
				SELECT COUNT(status)
				INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred 
				WHERE fecha_insert >= pFechaIni
					AND fecha_insert <= pFechaFin			
					AND origen = pOrigen
					AND status = cStatus					
					AND causa_status =""
				
				IF iTotalStatus > 0 THEN
					INSERT INTO tme_consultaincrementos(status,causa,descripcion,totalRegistros,porcentaje)
					VALUES(cStatus,'',vcDescripcion,NVL(iTotalStatus,0),0);	 
				END IF;
			END FOREACH;  	
			FOREACH WITH HOLD
				SELECT COUNT(status)
				INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred 
				WHERE fecha_insert >= pFechaIni
					AND fecha_insert <= pFechaFin			
					AND origen = pOrigen
					AND status = cStatus					
					AND causa_status IN(SELECT causa_status		  
										 FROM "informix".sd_causas_aumlincred
										 WHERE mostrar_pantalla = "1")
				
				IF iTotalStatus > 0 THEN
					INSERT INTO tme_consultaincrementos(status,causa,descripcion,totalRegistros,porcentaje)
					VALUES(cStatus,'',vcDescripcion,NVL(iTotalStatus,0),0);	 
				END IF;
				
			END FOREACH;  	
			
		END FOREACH;
		--se obtiene el total de los registros para esta consulta	
		SELECT NVL(SUM(totalregistros),0), COUNT(status)
		INTO iTotal,iTotalReg
		FROM  tme_consultaincrementos 
		WHERE status = status
			AND causa = ""
			AND totalRegistros <> 0;
		
		LET iTotalRegistros = iTotal;
					
		IF iTotalReg <> 0 THEN
			--se realiza el calculo del porcentaje por cada status del total de registros de la consulta	
			FOREACH
				SELECT status,descripcion,totalRegistros
				INTO cStatus, vcDescripcion,iTotalStatus
				FROM  tme_consultaincrementos
				WHERE status = status
					AND causa = ""
					AND totalRegistros <> 0	
				
				LET dPorcStatus = ((iTotalStatus * 100)/iTotalRegistros);
				IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
					LET iCont = iCont + 1;
					IF iTotalReg = iCont THEN
						LET dPorcStatus = 100 - dPorcStatusAcum;
					END IF;
					LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
				ELSE
					LET iCont = iCont + 1;
					LET dPorcStatus = 100 - dPorcStatusAcum;
					LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
				END IF;
						
				UPDATE tme_consultaincrementos
				SET porcentaje = dPorcStatus
				WHERE status = cStatus;
			END FOREACH;
		END IF;
		---se insertan el total de registros por causas
		FOREACH WITH HOLD
			SELECT status,causa_status,TRIM(descripcion)
			  INTO cStatus,cCausa,vcDescripcion
			  FROM "informix".sd_causas_aumlincred
             WHERE mostrar_pantalla = "1"
				
			FOREACH WITH HOLD
				SELECT COUNT(status)
				INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred 
				WHERE fecha_insert >= pFechaIni
					AND fecha_insert <= pFechaFin		
					AND origen = pOrigen
					AND status = cStatus
					AND causa_status = cCausa
			
				INSERT INTO tme_consultaincrementos (status,causa,descripcion,totalRegistros,porcentaje)	
				VALUES(cStatus,cCausa,vcDescripcion,NVL(iTotalStatus,0),0);
			 
			END FOREACH;  		
		END FOREACH;	
		--se realiza el calculo del porcentaje por cada status con causa del total de registros de la consulta para cada status		
		LET dPorcStatusAcum = 0;
		LET dPorcStatus = 0;
		LET iCont = 0;

		FOREACH WITH HOLD
			SELECT status,causa_status
			  INTO cStatus,cCausa
			  FROM "informix".sd_causas_aumlincred
             WHERE mostrar_pantalla = "1"
			ORDER BY status,causa_status
					
			SELECT NVL(SUM(totalregistros),0), COUNT(causa)
			INTO iTotal,iTotalReg
			FROM  tme_consultaincrementos 
			WHERE status = cStatus
				AND causa <> ""
				AND totalRegistros <> 0;
								
			SELECT porcentaje
			INTO  dPorcStatusTotal
			FROM  tme_consultaincrementos 
			WHERE status = cStatus
				AND causa = ""
				AND totalRegistros <> 0;
					
			IF iTotalReg <> 0 THEN
				SELECT status,causa,descripcion,totalRegistros
				INTO cStatus,cCausa,vcDescripcion,iTotalStatus
				FROM  tme_consultaincrementos
				WHERE status = cStatus
					AND causa = cCausa
					AND totalRegistros <> 0;
					
				IF NVL(iTotalStatus,0) <> 0 THEN
					LET dPorcStatus = ((iTotalStatus * 100) / iTotalRegistros);

					IF (dPorcStatusAcum + dPorcStatus) < dPorcStatusTotal THEN
						LET iCont = iCont + 1;
						IF iTotalReg = iCont THEN
							LET dPorcStatus = dPorcStatusTotal - dPorcStatusAcum;							
						END IF;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;						
					ELSE
						LET iCont = iCont + 1;
						LET dPorcStatus = dPorcStatusTotal - dPorcStatusAcum;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;	
					END IF;
						
					UPDATE tme_consultaincrementos
						SET porcentaje = dPorcStatus
					WHERE status = cStatus
						AND causa = cCausa;	
				END IF;
			END IF;
			IF iTotalReg = iCont THEN
				LET dPorcStatusAcum = 0;
				LET dPorcStatus = 0;
				LET iCont = 0;
			END IF;				
		END FOREACH;
		
		--se obtiene los datos de la tabla
		FOREACH
			SELECT count(*)
			INTO iTotalReg
			FROM  tme_consultaincrementos
			--ORDER BY status,causa
			
			/*IF NVL(cCausa,"") <> "" THEN
				LET iTieneCausa = 1;
				LET  vcDescripcion = TRIM (cCausa) || '-' || TRIM (vcDescripcion);
			ELSE
				LET iTieneCausa = 0;				
			END IF;*/
			RETURN cCodRet, cMensajeRet, iTotalReg WITH RESUME;			 
		END FOREACH;	
		
		IF  cBandera = "S" THEN
			DROP TABLE tme_consultaincrementos;
		END IF;
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener el total y porcentaje de cada status de acuerdo al mes consultado',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 04/03/2011',
'MODIFICACION: Se modifica para que reciba como parametro de entrada  el rango de fechas del cual se desea la informacion.',
'FECHA: 04/11/2011',
'AUTOR : Héctor Manuel Bojorquez Ruelas',
'MODIFICACION: Se modifica para corregir y cambiar el retorno de la variable "iTotal" por "iTotalRegistros" ya que perdia el valor cuando el ultimo',
'			   registro tomaba el valor de 0 y por consecuencia no mostraba registros. Se contemplan las reglas de informix, se elimina variable "cComentario" y',
'              dPorcStatusAcum2 ya que estas no son usadas en el procedimiento',
'FECHA: 24/07/2012',
'AUTOR : Guadalupe Payan',
'BD    : BDICRED',
'Version: 20120724.1714',
'----------------------------------------------------------------------------------',
'Autor: Josué Remberto Zazueta Acosta',
'Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían,Se implementan reglas', 'de informix',
'Fecha de modificación: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_sd_amortiza_credito()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(150);
DEFINE cCod_ret                     CHAR(6);
DEFINE vrowid                       INTEGER;
DEFINE VlNumCredito                 CHAR(20);

	--SET DEBUG FILE TO "/informix/c91691184/sp_sd_amortiza_credito.out";
    --TRACE ON; 

	LET cCod_ret      = '000000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';
	LET cMensaje      = 'PROCESO EXITOSO';
            
	BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;
            RETURN cCod_ret;
	    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

    FOREACH WITH HOLD

		select num_solicitud
		into VlNumCredito  
		from "informix".temp_solicitudes

		BEGIN WORK;

			DELETE FROM "informix".sd_amortiza_credito WHERE empresa = '001' and  num_credito = VlNumCredito;
			delete from "informix".temp_solicitudes where num_solicitud = VlNumCredito;

		COMMIT WORK;

	END FOREACH;  
	
	drop table "informix".temp_solicitudes;
	
	RETURN cCod_ret;

	END;

END PROCEDURE;