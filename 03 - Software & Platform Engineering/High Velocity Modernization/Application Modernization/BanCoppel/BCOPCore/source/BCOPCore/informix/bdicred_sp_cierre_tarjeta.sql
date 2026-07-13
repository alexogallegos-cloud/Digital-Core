CREATE PROCEDURE "informix".sp_cierre_tarjeta(pEmpresa CHAR(3),
                                              pNumCred CHAR(20))
RETURNING CHAR(5);

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE CodRet              CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nRows               SMALLINT;
   DEFINE vMensaje            VARCHAR(200,1);
   DEFINE Mensaje             VARCHAR(200,1);
   DEFINE vNumCred            CHAR(20);

   DEFINE GLOBAL FechaHoy        DATE          DEFAULT NULL;
   DEFINE GLOBAL FechaAnt        DATE          DEFAULT NULL;
   DEFINE GLOBAL ProxFecha       DATE          DEFAULT NULL;
   DEFINE GLOBAL PriDiaMes       DATE          DEFAULT NULL;
   DEFINE GLOBAL PriHabMes       DATE          DEFAULT NULL;
   DEFINE GLOBAL UltDiaMes       DATE          DEFAULT NULL;
   DEFINE GLOBAL UltHabMes       DATE          DEFAULT NULL;

   DEFINE GLOBAL TopeMinimo      DECIMAL(14,2) DEFAULT 0;
   DEFINE GLOBAL DiasCalc        SMALLINT      DEFAULT 0;
   DEFINE GLOBAL vDiasBloqueo    SMALLINT      DEFAULT 0;
   DEFINE GLOBAL vIvaBase        DECIMAL(5,3)  DEFAULT 0;
   DEFINE GLOBAL vPrecioReal     DECIMAL(14,6) DEFAULT 0;
   DEFINE GLOBAL vPrecioRealAnt  DECIMAL(14,6) DEFAULT 0;
   DEFINE GLOBAL vFechaUDIant    DATE          DEFAULT NULL;
   DEFINE GLOBAL DiasProvMa      SMALLINT      DEFAULT 0;
   DEFINE GLOBAL vIvaSuc         DECIMAL(5,3)  DEFAULT 0;

   DEFINE SdoIntAnticip ,SdoIntAntDev   , SdoIntereses  , SdoDiaAntInt , SdoMesAntInt  , SdoAcumMesInt, SdoExigInt  , SdoNoExig    , ProvisionNormal   MONEY(14,2);
   DEFINE SdoMoratorio  ,SdoDiaAntMor   , SdoMesAntMor  , SdoCapital   , SdoCapInsoluto, SdoDiaAntCap , SdoMesAntCap, SdoAcumMesCap, MontoVencido      MONEY(14,2);
   DEFINE MtoVencTrasp  ,DiasAcumIntPer , SdoGlobalInt  , SdoAcumIntPer, MtoVencInt    , MtoVencTraInt, IntTraNoExig, SdoTrab4     , MontoFinanciado   MONEY(14,2);
   DEFINE IntTraNoExigMes  MONEY(14,2);
   DEFINE MontoReservado,MtoCapitalizado, MtoMinistraCap, vIvaMora     , vSdoAcumMora  , SdoPromedio  , InteresMam  , InteresPmm   , InteresMad        MONEY(14,2);
   DEFINE InteresPmd    ,MontoProvision , MtoCapitaliza , TotalAdeudo  , MontoPago     , MtoMoraOrdi  , MtoMoraCope,  MtoMoraOrdiMa, MtoMoraCopeMa     MONEY(14,2);
   DEFINE MtoMoraOrdiPm ,MtoMoraCopePm,CapTrasNo,vIntOrden,vIvaOrd,vSdoNoExigPas,vIvaOrden,vIvaOrdenAnt,vCapInsEsTot                                   MONEY(14,2);

   DEFINE TasaAm, TasaHm, TasaAd, TasaHd, TasaIn, vTasaMora, TasaCope, TasaIntd, vTasaCte,TasaIntm                                                     DECIMAL(9,6) ;
   DEFINE vPrecioIni, vPrecioFin, TasaDiaria                                                                                                           DECIMAL(14,6);
   DEFINE vMtoVencido, vIvaInt, vIvaIntv, vIvaIntMes, vBaseReserva, vReservaInt, vMtoProvision,SdoRetenido,vVencidoHist,MinimoMesAnt,VigenteMesAnt     DECIMAL(14,2);
   DEFINE vProvIva,vProvInt, vIntDiario,  vCuotaMes,vIntOrd,vCalcIvaMesAnt                                                                 DECIMAL(14,2);
   DEFINE vPorcReserva                                                                                                                  DECIMAL(5,2) ;

   DEFINE DiasPeriodo, DiasAcCap, DiasMa, DiasPm, DifDias, DiaCuota, DiasAcumCap, DiasAcumInt, DiasAcumMora, Aniversario, vReferencia, vDiaDeCorte     SMALLINT     ;
   DEFINE vDiasGraciaMora, vDiasMaxPago, DiasProvPm, vDiasTrasp, vRMora, rLog, vCodRefInt,vPasoProm                          SMALLINT     ;

   DEFINE CambioMes           CHAR(1); DEFINE vCodigoFun   CHAR(3); DEFINE Folio       CHAR(16); DEFINE vSucursal   CHAR(4); DEFINE vDivisa            CHAR(2)      ;
   DEFINE NumProducto         CHAR(4); DEFINE Transacc     CHAR(4); DEFINE vTpDiasMora CHAR(1) ; DEFINE vTpDiasPago CHAR(1); DEFINE Begin              CHAR(1)      ;
   DEFINE TrasHoy             CHAR(1); DEFINE vCodFunInt  CHAR(3) ; DEFINE BanderaInt  CHAR(1); DEFINE vStProc            CHAR(1)      ;
   DEFINE StatusMora          CHAR(1); DEFINE vForeach     CHAR(1); DEFINE vBandFinan  CHAR(1) ; DEFINE vPlaza      CHAR(3); DEFINE Es_Totalero        CHAR(1)      ;
   DEFINE vSiCap              CHAR(1); DEFINE vDia         CHAR(2); DEFINE vCapVig     CHAR(10); DEFINE vCapTras    CHAR(10); DEFINE vCapVenExig       CHAR(15)     ;
   DEFINE vIntVig             CHAR(10);DEFINE vIntVenc     CHAR(10);DEFINE vFolio      CHAR(16);
   DEFINE StatusCred, StatusCred_ant   CHAR(2);

   DEFINE FechaPagoCap, FechaPagoInt, vFechaVenc, vFecProxPag, vFProceso, vCorteHoy,vFechaReserva ,vFechaCuota,vFecMes                     DATE        ;
   DEFINE vErrores,vMarcaAyuda                                                                                                                          INTEGER     ;
   DEFINE MesAnio DATETIME YEAR TO MONTH;
   DEFINE vinsert_finmes integer;

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET CodRet = sql_err;
      CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,
                       TRIM(error_info))
      RETURNING rLog;
      IF Begin = "S" THEN
         ROLLBACK WORK;
      END IF

      IF rLog > 0 THEN
          UPDATE sd_contproc
             SET status_proc = 'C',
                 hora_fin    = CURRENT,
                 cod_ret     = CodRet,
                 mensaje     = vMensaje
           WHERE empresa     = pEmpresa
            AND proceso     = 'CierreCred'
            AND fecha       = FechaHoy;

          UPDATE bdinteg:sx_contproc
             SET status_proc = 'C',
                 hora_fin    = CURRENT,
                 codret      = CodRet
           WHERE empresa = pEmpresa
            AND proceso  = 'CierreCred'
            AND fecha    = FechaHoy;

          RETURN CodRet;
      ELSE
        IF vForeach <> "S" THEN
          RETURN CodRet;
        END IF
      END IF
   END EXCEPTION WITH RESUME;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
   LET CodRet            = '000';
   LET SdoIntereses      = 0;     LET SdoDiaAntInt      = 0;   LET SdoMesAntInt   = 0;  LET SdoAcumMesInt     = 0; LET SdoExigInt       = 0;    LET SdoNoExig         = 0;
   LET ProvisionNormal   = 0;     LET DiasAcumInt       = 0;   LET SdoMoratorio   = 0;  LET SdoDiaAntMor      = 0; LET SdoMesAntMor     = 0;    LET DiasAcumMora      = 0;
   LET SdoCapital        = 0;     LET SdoCapInsoluto    = 0;   LET SdoDiaAntCap   = 0;  LET SdoMesAntCap      = 0; LET SdoAcumMesCap    = 0;    LET DiasAcumCap       = 0;
   LET MontoVencido      = 0;     LET MtoVencTrasp      = 0;   LET DiasAcumIntPer = 0;  LET SdoGlobalInt      = 0; LET SdoAcumIntPer    = 0;    LET MtoVencInt        = 0;
   LET MtoVencTraInt     = 0;     LET InteresMam        = 0;   LET InteresPmm     = 0;  LET DiasProvMa        = 0; LET DiasProvPm       = 0;    LET MtoMoraOrdi       = 0;
   LET MtoMoraCope       = 0;     LET MtoMoraOrdiMa     = 0;   LET MtoMoraCopeMa  = 0;  LET MtoMoraOrdiPm     = 0; LET MtoMoraCopePm    = 0;    LET IntTraNoExig      = 0;
   LET SdoTrab4          = 0;      LET DiasMa         = 0;  LET DiasPm            = 0; LET CambioMes        = 'N';  LET MontoProvision    = 0;
   LET vCodigoFun        = '034'; LET vReferencia       = '';  LET Transacc       = ''; LET MtoCapitalizado   = 0; LET TasaAd           = 0;    LET TasaHd            = 0;
   LET DiasPeriodo       = 0;     LET MtoCapitaliza     = 0;   LET MtoMinistraCap = 0;  LET TotalAdeudo       = 0; LET MtoMoraOrdi      = 0;    LET MtoMoraCope       = 0;
   LET vNumCred          = " ";   LET rLog              = 0;   LET vMensaje       = ""; LET vCorteHoy         = "";LET Begin            = "N";  LET TrasHoy           = "N";
   LET vPrecioIni        = 0;     LET vPrecioFin        = 0;   LET vIvaInt        = 0;  LET vIvaIntMes        = 0; LET vIvaIntv          = 0;   LET TasaDIaria        = 0;
   LET vIvaMora          = 0;     LET vSdoAcumMora      = 0;   LET vBaseReserva   = 0;  LET vReservaInt       = 0; LET vPorcReserva      = 100; LET vForeach          = "N";
   LET vMtoVencido       = 0;     LET vPasoProm         = 0;   LET BanderaInt     ="?"; LET vProvInt          = 0; LET vProvIva          = 0;   LET Es_Totalero       = "?";
   LET vDia              ='';     LET vCapVig           ='';   LET vCapTras       ='';  LET vCapVenExig       =''; LET vIntVig           ='';   LET vIntVenc          ='';
   LET vIntDiario        = 0;     LET vCuotaMes         = 0;   LET vFechaUDIant   ='';  LET vFecMes           = '';LET vIntOrd           =0;
   LET vFolio            ='';     LET vIntOrden      = 0;      LET vIvaOrd        = 0;  LET vSdoNoExigPas = 0;
   LET vIvaOrden         = 0;
   LET StatusCred        = '';
   LET vIvaOrdenAnt      = 0;
   LET vinsert_finmes    = 0;

   -- SELECT * FROM bdinteg:si_sucursales
   --  WHERE tpo_sucursal = "S"
   --   INTO TEMP cr_sucursales;
   -- CREATE INDEX crsucursal on cr_sucursales (empresa, sucursal);


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

--SET DEBUG FILE TO "sp_cierre_tarjeta.out";
--TRACE ON;

      LET vFechaReserva = FechaHoy;

 SET OPTIMIZATION HIGH;

FOREACH WITH HOLD
        SELECT a.num_credito
          INTO vNumCred
          FROM sd_maecred a, sd_maecredanexo b
         WHERE a.empresa = pEmpresa
           AND a.status_cred NOT IN ("FF", "CC")
           AND b.num_credito = a.num_credito
           AND b.empresa = a.empresa
           AND b.fecha_proceso = FechaHoy
           AND a.num_credito = pNumCred

 BEGIN WORK;
 LET Begin        = "S";
 LET vForeach     = "S";
 LET vSiCap       ='';
 LET vCapInsEsTot = 0;
 LET vCalcIvaMesAnt = 0;
 LET IntTraNoExigMes = 0;

   SELECT a.empresa,            a.num_credito,
          a.sdo_int_anticip,    a.sdo_int_ant_dev,        a.sdo_intereses,
          a.sdo_dia_ant_int,    a.sdo_mes_ant_int,        a.sdo_acum_mes_int,
          a.sdo_exig_int,       a.sdo_no_exig,            a.provision_normal,
          a.dias_acum_int,      a.sdo_moratorio,          a.sdo_dia_ant_mor,
          a.sdo_mes_ant_mor,    a.dias_acum_mora,         a.sdo_capital,
          a.sdo_cap_insoluto,   a.sdo_dia_ant_cap,        a.sdo_mes_ant_cap,
          a.sdo_acum_mes_cap,   a.dias_acum_cap,          a.monto_vencido,
          a.mto_venc_trasp,     a.dias_acum_intper,       a.sdo_global_int,
          a.sdo_acum_intper,    a.mto_venc_int,           a.mto_venc_tra_int,
          b.num_producto,       DAY(b.fecha_apertura),
          b.tasa_interes,       b.sucursal,               b.divisa,
          b.fecha_pago_cap,     b.fecha_pago_int,         a.mto_capitalizado,
          a.int_tra_no_exig,    a.sdo_trab4,              a.monto_financiado,
          a.monto_reservado,    b.status_cred,            a.sdo_acum_mes_cap,
          a.dias_acum_cap,      a.mto_ministra_cap,       f.dia_corte,
          f.dias_gracia_mora,   f.tp_dias_calc_mora,      f.dias_fecha_max_pago,
          f.tp_dias_fecha_pago, NVL(f.tasa_interes_cte,0),b.dias_trasp_cap,
          f.fecha_vencto     ,  f.prox_fecha_pago,        b.tasa_moratorios,
          f.fecha_proceso,                                 a.sdo_contab_mora,
          a.sdo_retenido  ,   a.cap_tras_no_venci,  NVL(b.id_unidad_prod,0)
     INTO pEmpresa        ,   vNumCred        ,
          SdoIntAnticip   ,   SdoIntAntDev    ,      SdoIntereses    ,
          SdoDiaAntInt    ,   SdoMesAntInt    ,      SdoAcumMesInt   ,
          SdoExigInt      ,   SdoNoExig       ,      ProvisionNormal ,
          DiasAcumInt     ,   SdoMoratorio    ,      SdoDiaAntMor    ,
          SdoMesAntMor    ,   DiasAcumMora    ,      SdoCapital      ,
          SdoCapInsoluto  ,   SdoDiaAntCap    ,      SdoMesAntCap    ,
          SdoAcumMesCap   ,   DiasAcumCap     ,      MontoVencido    ,
          MtovencTrasp    ,   DiasAcumIntPer  ,      SdoGlobalInt    ,
          SdoAcumIntPer   ,   MtoVencInt      ,      MtoVencTraInt   ,
          NumProducto     ,   Aniversario     ,
          TasaIntm        ,   vSucursal       ,      vDivisa         ,
          FechaPagoCap    ,   FechaPagoInt    ,      MtoCapitalizado ,
          IntTraNoExig    ,   SdoTrab4        ,      MontoFinanciado ,
          MontoReservado  ,   StatusCred      ,      SdoPromedio     ,
          DiasAcCap       ,   MtoMinistraCap  ,      vDiaDeCorte     ,
          vDiasGraciaMora ,   vTpDiasMora     ,      vDiasMaxPago    ,
          vTpDiasPago     ,   vTasaCte        ,      vDiasTrasp      ,
          vFechaVenc      ,   vFecProxPag     ,      vTasaMora       ,
          vFProceso       ,                          vSdoAcumMora    ,
          SdoRetenido     ,   CapTrasNo       ,      vMarcaAyuda
     FROM sd_maesdos a, sd_maecred b,
          sd_maecredanexo f
    WHERE a.num_credito = vNumCred
      AND a.empresa = pEmpresa
      AND b.num_credito = a.num_credito
      AND b.empresa     = a.empresa
      AND f.num_credito  = a.num_credito
      AND f.empresa      = a.empresa;


        LET vMtoVencido = 0;
        LET vBandFinan = "0";
        LET Es_Totalero = "N";
        LET StatusCred_ant = StatusCred;

  SELECT
     USER||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(current,3,2)||
     SUBSTR(CURRENT,12,2)||substr(current,15,2)
     ||SUBSTR(current,18,2)
  INTO Folio
  FROM dual;
 -- Let vFolio = USER[1,5]||'ORD';  --Folio Especial Mov. En Orden.


 -- jom Ini Venta de Cartera
    IF vMarcaAyuda = 1 OR StatusCred = "CV" THEN -- Marca para bloqueo de créditos
           INSERT INTO sd_movhis
           SELECT * FROM sd_movdia
            WHERE num_credito = vNumCred
              AND empresa = pEmpresa;

           DELETE FROM sd_movdia
            WHERE num_credito = vNumCred
              AND empresa = pEmpresa;

           COMMIT WORK;
           CONTINUE FOREACH;
    END IF
 -- jom Ini Venta de Cartera

  -- ***********************************
  -- CALCULO DE PROVISION DE INTERESES *
  -- ***********************************
     LET vMensaje = "Provision Normal";

     LET vMtoProvision = (SdoCapital+CapTrasNo);

     IF (vMtoProvision > 0) THEN
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
        LET vIntDiario   = InteresMam + InteresPmm;
     ELIF (vMtoProvision) < 0 THEN
        {LET SdoIntereses = 0;
        LET InteresMam   = 0;
        LET InteresMad   = 0;
     ELSE
        LET SdoIntereses = 0;
        LET InteresMam   = 0;
        LET InteresMad   = 0;}
     END IF;

     LET SdoAcumMesInt = SdoAcumMesInt + InteresMam + InteresPmm;
     LET DiasAcumInt   = DiasAcumInt + DiasProvMa + DiasProvPm;
     IF (SdoCapital > 0) THEN
        LET SdoAcumMesCap = SdoAcumMesCap +
                           (SdoCapital * (DiasProvMa + DiasProvPm));
        LET DiasAcumCap   = DiasAcumCap + DiasProvMa + DiasProvPm;
     END IF;
     LET SdoGlobalInt  = SdoGlobalInt + InteresMam + InteresPmm;
     LET SdoAcumIntPer = SdoAcumIntPer + InteresMam + InteresPmm;

     LET MesAnio = YEAR(FechaHoy) || "-" || LPAD(MONTH(FechaHoy),2,0);

     SELECT COUNT(*) INTO vPasoProm
       FROM sd_salpro
      WHERE empresa = pEmpresa
        AND num_credito = vNumCred
        AND fecha = MesAnio;

     IF vPasoProm = 1 THEN
          UPDATE sd_salpro
                 SET acum_insoluto = acum_insoluto +
                     (SdoCapInsoluto * ( DiasProvMa + DiasProvPm)),
                     acum_vigente = acum_vigente +
                     (SdoCapital * ( DiasProvMa + DiasProvPm)),
                     acum_transitorio = acum_transitorio +
                     (MontoVencido * ( DiasProvMa + DiasProvPm)),
                     acum_vencido = acum_vencido +
                     (MtovencTrasp * ( DiasProvMa + DiasProvPm)),
                     acum_venc_no_exig = acum_venc_no_exig +
                     (CapTrasNo * ( DiasProvMa + DiasProvPm)),
                     dias_pos = dias_pos + ( DiasProvMa + DiasProvPm)
         WHERE empresa = pEmpresa
           AND num_credito = vNumCred
           AND fecha = MesAnio;
     ELSE
         INSERT INTO sd_salpro VALUES
          (pEmpresa, vNumCred, MesAnio,
          (SdoCapInsoluto * ( DiasProvMa + DiasProvPm)),
          (SdoCapital * ( DiasProvMa + DiasProvPm)),
          (MontoVencido * ( DiasProvMa + DiasProvPm)),
          (MtovencTrasp * ( DiasProvMa + DiasProvPm)),
          (CapTrasNo * ( DiasProvMa + DiasProvPm)),
          ( DiasProvMa + DiasProvPm));
     END IF


   -- **********************************************
   --       C a l c u l a   M o r a t o r i o s    *
   -- **********************************************
   LET vMensaje = "Provision de Moratorios";
   IF (StatusCred = "BA" OR StatusCred = "BT") and DAY(FechaHoy) <> vDiaDeCorte THEN

       LET TasaCope    = vTasaMora - TasaIntm;
       LET MtoMoraOrdiMa = MontoVencido + MtovencTrasp;
       LET MtoMoraCopeMa = MontoVencido + MtovencTrasp;
       LET MtoMoraOrdiMa = (MtoMoraOrdiMa) * TasaIntm/(DiasCalc * 100);
       LET MtoMoraOrdiMa = MtoMoraOrdiMa * DiasProvMa ;
       LET MtoMoraCopeMa = (MtoMoraCopeMa) * TasaCope/(DiasCalc * 100);
       LET MtoMoraCopeMa = MtoMoraCopeMa * DiasProvMa ;
       LET vSdoAcumMora = vSdoAcumMora + MtoMoraOrdiMa + MtoMoraCopeMa;
       LET DiasAcumMora = DiasAcumMora + DiasProvMa;

       SELECT MAX(fecha_cuota) INTO vFechaCuota
         FROM sd_amortiza_credito
        WHERE empresa = pempresa
          AND num_credito = vNumCred
          AND capital_status IN ("2","7");

      UPDATE sd_amortiza_credito
         SET mora_provi_ordi = mora_provi_ordi + MtoMoraOrdiMa,
             mora_provi_cope = mora_provi_cope + MtoMoraCopeMa,
             mora_status = 1
           WHERE empresa = pempresa
             AND num_credito = vNumCred
         AND fecha_cuota = vFechaCuota;

   END IF

   -- ****************************************************************
   -- *     P r o c e s o s   p a r a   D i a   d e   C o r t e      *
   -- ****************************************************************

   IF DAY(FechaHoy) = vDiaDeCorte THEN
-----Verifica que en el credito tenga la fecha cuota, si no la crea INI
         LET vFechaCuota = NULL;

         SELECT fecha_cuota
            INTO vFechaCuota
            FROM sd_amortiza_credito
           WHERE empresa     = pEmpresa
             AND num_credito = vNumCred
             AND fecha_cuota = FechaHoy;

         IF vFechaCuota Is Null  THEN
             CALL sp_creacuota(pEmpresa,vNumCred,0)
             RETURNING CodRet;

             SELECT fecha_cuota
               INTO vFechaCuota
               FROM sd_amortiza_credito
              WHERE empresa     = pEmpresa
              AND num_credito = vNumCred
              AND fecha_cuota = FechaHoy;
         END IF;
-----Verifica que en el credito tenga la fecha cuota, si no la crea FIN

    IF vFechaCuota = FechaHoy THEN
        Let DiasAcumInt = FechaHoy - vFechaUDIant;
        LET vIvaInt = 0;
        SELECT iva, plaza
          INTO vIvaSuc, vPlaza
          FROM cr_sucursales
         WHERE empresa = pEmpresa
           AND sucursal = vSucursal;

        -- ************************************************************
        -- Genera Movimiento de Financiamiento de Intereses           *
        -- ************************************************************
        SELECT NVL(sdo_cap_insoluto,0),
               NVL((mto_venc_trasp),0),
               NVL(sdo_trab4,0)     ,
               monto_financiado - (mto_venc_trasp + monto_vencido)
          INTO vMtoVencido , vVencidoHist, MinimoMesAnt, VigenteMesAnt
          FROM sd_maesdoshist
         WHERE fecha = FechaHoy - 1 UNITS MONTH
           AND empresa = pEmpresa
           AND num_credito = vNumCred;
 --***
        IF VigenteMesAnt Is Null OR VigenteMesAnt < 0  THEN
           LET VigenteMesAnt = 0;
        END IF;

        IF SdoCapInsoluto <= 0 THEN
                LET vMtoVencido = 0;
                LET SdoIntereses = 0;
        END IF

        LET vCapInsEsTot = MontoFinanciado;
        --IF MontoFinanciado < 0  THEN
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
              UPDATE sd_amortiza_credito
                     SET interes_debe = 0,
                         iva_debe = 0,
                         iva_pagado = 0
                   WHERE empresa = pempresa
                     AND num_credito = vNumCred
                     AND fecha_cuota = vFechaCuota -1 UNITS MONTH;

           END IF

           IF (vMtoVencido > 0 AND StatusCred <> "BT" ) or (vCapInsEsTot >0 AND StatusCred <> "BT") THEN
           -- Refinanciamiento de Intereses
              SELECT SUM(iva_debe - iva_pagado)
                INTO vIvaInt
                FROM sd_amortiza_credito
               WHERE empresa = pempresa
                 AND num_credito = vNumCred
                 AND fecha_cuota = vFechaCuota -1 UNITS MONTH;


              IF vIvaInt IS NULL THEN
                LET vIvaInt = 0;
              END IF
              CALL genmovcierre(pEmpresa, vNumCred, NumProducto,3,
                               "605", FechaHoy, vIvaInt,
                               Folio, vSucursal, vDivisa, Transacc,vPlaza)
              RETURNING CodRet, Mensaje;
              IF (CodRet <> "00000") THEN
                  ROLLBACK WORK;
                  LET vMensaje = "Financiamiento de Iva      ";
                  CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,
                                   TRIM(vMensaje) || "(GENMOV)")
                  RETURNING rLog;
                  IF rLog > 0 THEN
                     RETURN CodRet;
                  ELSE
                     CONTINUE FOREACH;
                  END IF
              ELSE
                  LET CodRet = "000";
              END IF;

              CALL genmovcierre(pEmpresa, vNumCred, NumProducto,2,
--                                "605", FechaHoy,  (IntTraNoExig + SdoNoExig),
                                "605", FechaHoy,  SdoNoExig,
                               Folio, vSucursal, vDivisa, Transacc,vPlaza)
              RETURNING CodRet, Mensaje;
              IF (CodRet <> "00000") THEN
                  ROLLBACK WORK;
                  LET vMensaje = "Financiamiento de Intereses";
                  CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,
                                   TRIM(vMensaje) || "(GENMOV)")
                  RETURNING rLog;
                  IF rLog > 0 THEN
                     RETURN CodRet;
                  ELSE
                    CONTINUE FOREACH;
                  END IF
              ELSE
                  LET CodRet = "000";
              END IF;
             {
              LET sdoCapital = SdoCapital + IntTraNoExig + SdoNoExig + vIvaInt;
              LET sdoCapInsoluto = SdoCapInsoluto + IntTraNoExig + SdoNoExig + vIvaInt;
              LET MtoCapitalizado = MtoCapitalizado + IntTraNoExig + SdoNoExig + vIvaInt;
             }
              LET sdoCapital = SdoCapital +  SdoNoExig + vIvaInt;
              LET sdoCapInsoluto = SdoCapInsoluto +  SdoNoExig + vIvaInt;
              LET MtoCapitalizado = MtoCapitalizado +  SdoNoExig + vIvaInt;


              LET vIntDiario = SdoNoExig;
            --  LET SdoNoExig    = 0;
            --  LET IntTraNoExig = 0; -- CAS
              LET vIvaInt      = 0;
           END IF
        END IF
        LET vMtoVencido = 0;

        -- *    R e a l i z a    p r o v i s i o n   a l   c o r t e      *
        -- Pregunta si el credito esta o va a entrar a vencido *
{ --JOM
        IF month(FechaHoy) ='09' Or month(FechaHoy) = '02' THEN
            let vDiasTrasp = '61' ;
        END IF;
        IF month(FechaHoy) ='03'  THEN
            let vDiasTrasp = '59' ;
        END IF;
} -- JOM
--        IF ((FechaHoy - vFechaVenc) >= vDiasTrasp + 2  OR (FechaHoy - vFechaVenc) >= vDiasTrasp + 28) THEN

        IF (StatusCred = "BT") THEN
                LET vCodFunInt = "604";
                LET vCodRefInt = 2;
                LET BanderaInt = "1";
        ELSE
                LET vCodFunInt = "606";
                LET vCodRefInt = 1;
                LET BanderaInt = "0";
        END IF;

        SELECT nvl(SUM(interes_debe - interes_pagado),0),
               nvl(SUM(iva_debe - iva_pagado),0)
          INTO vProvInt, vProvIva
          FROM sd_amortiza_credito
         WHERE empresa = pEmpresa
           AND num_credito = vNumCred
          AND fecha_cuota = vFechaCuota -1 UNITS MONTH;

      IF IntTraNoExig > 0 and StatusCred <>'AA' THEN  --Mov. Int Orden.  --CAS
          let IntTraNoExigMes = vProvInt;
          let vIvaOrdenAnt = vProvIva;
{ -- JOM
          SELECT sum(interes_debe - interes_pagado), SUM(iva_debe - iva_pagado)
          INTO IntTraNoExigMes, vIvaOrdenAnt
          FROM sd_amortiza_credito
          WHERE empresa = pempresa
          AND num_credito = vNumCred
          AND fecha_cuota = vFechaCuota -1 UNITS MONTH;
} -- JOM
          CALL genmovcierre(pEmpresa, vNumCred, NumProducto,2,
                      604, FechaHoy, IntTraNoExigMes, Folio,
                        vSucursal, vDivisa, Transacc,vPlaza)
          RETURNING CodRet, Mensaje;

          IF vIvaOrdenAnt > 0 THEN
            CALL genmovcierre(pEmpresa, vNumCred, NumProducto,22,
                      340, FechaHoy, vIvaOrdenAnt, Folio,
                        vSucursal, vDivisa, Transacc,vPlaza)
             RETURNING CodRet, Mensaje;
          END IF;
          IF (CodRet <> "00000") THEN
               RETURN CodRet;
          ELSE
             LET CodRet = "000";
          END IF;
      END IF;

{ -- jom
        SELECT SUM(interes_debe - interes_pagado),
               SUM(iva_debe - iva_pagado)
          INTO vProvInt, vProvIva
          FROM sd_amortiza_credito
         WHERE empresa = pEmpresa
           AND num_credito = vNumCred
          AND fecha_cuota = vFechaCuota -1 UNITS MONTH;
} -- jom

  IF SdoNoExig > 0 THEN
      LET SdoNoExig    = 0;   --**JL
      IF vProvInt > 0  THEN
          IF (vSiCap = '' Or vSiCap IS Null) and StatusCred <> "BT"  THEN
              let vIvaInt = '';
              let vIvaInt=vProvIva;
              IF vIvaInt IS NULL THEN
                LET vIvaInt = 0;
              END IF

              CALL genmovcierre(pEmpresa, vNumCred, NumProducto,3,
                               "605", FechaHoy, vIvaInt,
                               Folio, vSucursal, vDivisa, Transacc,vPlaza)
              RETURNING CodRet, Mensaje;

              CALL genmovcierre(pEmpresa, vNumCred, NumProducto,2,
                                605, FechaHoy, vProvInt, Folio,
                                vSucursal, vDivisa, Transacc,vPlaza)
              RETURNING CodRet, Mensaje;

             CALL genmovcierre(pEmpresa, vNumCred, NumProducto,vCodRefInt,
                        vCodFunInt, FechaHoy, vProvInt, Folio,
                        vSucursal, vDivisa, Transacc,vPlaza)
             RETURNING CodRet, Mensaje;
          ELSE
                        CALL genmovcierre(pEmpresa, vNumCred, NumProducto,vCodRefInt,
                                   vCodFunInt, FechaHoy, vProvInt , Folio,
                                   vSucursal, vDivisa, Transacc,vPlaza)
                        RETURNING CodRet, Mensaje;
          END IF;

          IF (CodRet <> "00000") THEN
              ROLLBACK WORK;
              LET vMensaje = "Provision de Int. Ordinarios";
              CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,
                                TRIM(vMensaje) || "(GENMOV)")
              RETURNING rLog;
              IF rLog > 0 THEN
                RETURN CodRet;
              ELSE
                CONTINUE FOREACH;
              END IF;
          ELSE
              LET CodRet = "000";
          END IF;
          -- Genera Calculo de Iva por Intereses
          CALL calc_iva_grav(pEmpresa, vSucursal, vNumCred,
                            ((SdoAcumMesCap+CapTrasNo)/DiasAcumInt),
                             Folio, TasaIntm, vDivisa, DiasCalc, DiasAcumInt,
                             vProvInt, NumProducto, BanderaInt, vPlaza,
                             "S", vPrecioRealAnt)
          RETURNING CodRet, vIvaInt;
          IF (CodRet <> "000") THEN
             ROLLBACK WORK;
             CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,
                            TRIM(vMensaje) || "(GENMOV)")
             RETURNING rLog;
             IF rLog > 0 THEN
                RETURN CodRet;
             ELSE
                CONTINUE FOREACH;
             END IF;
          END IF;

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
          CALL calc_iva_grav(pEmpresa, vSucursal, vNumCred,
                --            ((SdoAcumMesCap+CapTrasNo)/DiasAcumInt),
                             SdoIntereses,
                             Folio, TasaIntm, vDivisa, DiasCalc, DiasAcumInt,
                             SdoIntereses, NumProducto, BanderaInt, vPlaza,
                             "N", vPrecioReal)
          RETURNING CodRet, vIvaInt;
          IF (CodRet <> "000") THEN
             ROLLBACK WORK;
             CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,
                            TRIM(vMensaje) || "(GENMOV)")
             RETURNING rLog;
             IF rLog > 0 THEN
                RETURN CodRet;
             ELSE
                CONTINUE FOREACH;
             END IF
          END IF

        If SdoIntereses > 0 then
             UPDATE sd_amortiza_credito
                SET interes_debe = SdoIntereses,
                    iva_debe = vIvaInt,
                    interes_status = DECODE(vCodFunInt,"604","3","1")
             WHERE empresa = pEmpresa
               AND num_credito = vNumCred
               AND fecha_cuota = vFechaCuota;
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


           IF (vMtoVencido > 0 AND StatusCred <> "BT") THEN -- Traspaso de Vigente a Vencido *
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

              CALL genmovcierre(pEmpresa, vNumCred, NumProducto,1,
                       "602", FechaHoy, vMtoVencido,
                       Folio, vSucursal, vDivisa, Transacc,vPlaza)
              RETURNING  CodRet, Mensaje;
              IF (CodRet <> "00000") THEN
                 ROLLBACK WORK;
                 LET vMensaje = TRIM(vMensaje) || " (GENMOV)";
                 CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,
                                  vMensaje)
                 RETURNING rLog;
                 IF rLog > 0 THEN
                       RETURN CodRet;
                 ELSE
                       CONTINUE FOREACH;
                 END IF
              ELSE
                  LET CodRet = "000";
              END IF;

              IF vFechaVenc IS NULL OR vFechaVenc = " " THEN -- Vencido Trans.
                LET vFechaVenc = DATE(MONTH((FechaHoy -1 UNITS MONTH)) || "/" ||
                                 vDiaDeCorte || "/" ||
                                 YEAR((FechaHoy -1 UNITS MONTH)));
             END IF

             IF (StatusCred = "AA") THEN
                 UPDATE sd_amortiza_credito
                    SET capital_status = "7"
                  WHERE empresa = pempresa
                    AND num_credito = vNumCred
                    AND fecha_cuota = FechaHoy  -1 UNITS MONTH;
             END IF;

             LET StatusCred ="BA";
             LET TrasHoy    = "S";


           END IF -- Traspaso de Transitorio a Vencido *

          LET vMensaje = "Traspaso de Transitorio a Vencido";
-- jom         Let vDiasTrasp = vDiasTrasp;

-- bloque para transitorios o vencidos
--          IF (FechaHoy - vFechaVenc) >= vDiasTrasp THEN
         IF (StatusCred_ant <> "AA") THEN
{ -- jom             SELECT SUM(capital_debe - capital_pagado)
               INTO vMtoVencido
               FROM sd_amortiza_credito
              WHERE empresa = pempresa
                AND num_credito = vNumCred
                AND capital_status = "7";

             IF vMtoVencido IS NULL THEN
                LET vMtoVencido = 0;
             END IF
} -- jom
             IF StatusCred <> "BT" THEN
                LET StatusCred ="BT";
                LET MtovencTrasp = (MontoVencido);
               -- LET SdoCapital = SdoCapital - vMtoVencido;
                LET CapTrasNo = SdoCapital;
                LET SdoCapital= 0;
                LET MontoVencido = 0;


                -- Capital de Vigente a Traspasado
                CALL genmovcierre(pEmpresa, vNumCred, NumProducto,1,
                            "601", FechaHoy, (CapTrasNo),
                            Folio, vSucursal, vDivisa, Transacc,vPlaza)
                RETURNING  CodRet, Mensaje;
                IF (CodRet <> "00000") THEN
                    ROLLBACK WORK;
                    LET vMensaje = TRIM(vMensaje)||" Vigente a Vencido(GENMOV)";
                    CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,
                                     vMensaje)
                    RETURNING rLog;
                    IF rLog > 0 THEN
                         RETURN CodRet;
                    ELSE
                         CONTINUE FOREACH;
                    END IF
                ELSE
                    LET CodRet = "000";
                END IF;

                -- Capital de transitorio a vencido
                CALL genmovcierre(pEmpresa, vNumCred, NumProducto,1,
                            "600", FechaHoy, MtovencTrasp,
                            Folio, vSucursal, vDivisa, Transacc,vPlaza)
                RETURNING  CodRet, Mensaje;
                IF (CodRet <> "00000") THEN
                   ROLLBACK WORK;
                   LET vMensaje = TRIM(vMensaje) || " Trans a Vencido (GENMOV)";
                   CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,
                                    vMensaje)
                   RETURNING rLog;
                   IF rLog > 0 THEN
                         RETURN CodRet;
                   ELSE
                         CONTINUE FOREACH;
                  END IF
                ELSE
                  LET CodRet = "000";
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

             ELSE       -- Realiza reubicacion de saldos cuando ya esta vencido
                --LET vMtoVencido = MontoFInanciado - MtovencTrasp;
                LET MtovencTrasp = MtovencTrasp ;
                LET VigenteMesAnt = VigenteMesAnt ;
                LET MtovencTrasp = MtovencTrasp + VigenteMesAnt;
                LET CapTrasNo = CapTrasNo - VigenteMesAnt; --AXL
                CALL genmovcierre(pEmpresa, vNumCred, NumProducto,2,
                            "601", FechaHoy, VigenteMesAnt,
                            Folio, vSucursal, vDivisa, Transacc,vPlaza)
                RETURNING  CodRet, Mensaje;
                IF (CodRet <> "00000") THEN
                  ROLLBACK WORK;
                  LET vMensaje = TRIM(vMensaje) || "Trasp Cap No Exig a Trasp";
                  CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,
                                   vMensaje)
                  RETURNING rLog;
                  IF rLog > 0 THEN
                     RETURN CodRet;
                  ELSE
                     CONTINUE FOREACH;
                  END IF
                ELSE
                  LET CodRet = "000";
                END IF;
                LET SdoNoExig = 0;

                SELECT SUM(interes_debe - interes_pagado)
                  INTO IntTraNoExig
                  FROM sd_amortiza_credito
                 WHERE empresa = pempresa
                   AND num_credito = vNumCred
                   AND fecha_cuota < FechaHoy;

                UPDATE sd_amortiza_credito
                   SET interes_status = "3"
                 WHERE empresa = pempresa
                   AND num_credito = vNumCred
                   AND fecha_cuota < FechaHoy
                   AND (interes_debe - interes_pagado) > 0
                   AND interes_status <> "5";

                UPDATE sd_amortiza_credito
                   SET capital_status = "2"
                 WHERE empresa = pempresa
                   AND num_credito = vNumCred
                   AND fecha_cuota < FechaHoy
                   AND capital_status IN ("1","7");
  -- JOM           AND capital_debe > 0;

             END IF -- Status Diferente a BT
          END IF -- Credito Vencido Traspasado

          --IF (FechaHoy - vFechaVenc) >= vDiasBloqueo THEN
        --      LET vMensaje = "Adicionando a BLoqueado";
        --      INSERT INTO sd_pago_bloqueado
        --       (empresa, num_credito, secuencia, fecha, status)
        --      VALUES
        --       (pEmpresa, vNumCred, 0, FechaHoy, "0");
         --END IF

        -- **********************************************
        --       C a l c u l a   M o r a t o r i o s    *
        -- **********************************************
           LET vMensaje = "Acumulacion de Moratorios";
           IF StatusCred = "BA" OR StatusCred = "BT" THEN
                LET TasaCope    = vTasaMora - TasaIntm;
                LET MtoMoraOrdiMa = MontoVencido + MtovencTrasp;
                LET MtoMoraCopeMa = MontoVencido + MtovencTrasp;
               LET MtoMoraOrdiMa = (MtoMoraOrdiMa) * TasaIntm/(DiasCalc * 100);
               LET MtoMoraOrdiMa = MtoMoraOrdiMa * DiasProvMa ;
               LET MtoMoraCopeMa = (MtoMoraCopeMa) * TasaCope/(DiasCalc * 100);
               LET MtoMoraCopeMa = MtoMoraCopeMa * DiasProvMa ;
               LET vSdoAcumMora = vSdoAcumMora + MtoMoraOrdiMa + MtoMoraCopeMa;
               LET DiasAcumMora = DiasAcumMora + DiasProvMa;

               SELECT MAX(fecha_cuota) INTO vFechaCuota
                 FROM sd_amortiza_credito
                WHERE empresa = pempresa
                  AND num_credito = vNumCred
                  AND capital_status IN ("2","7");

               UPDATE sd_amortiza_credito
                  SET mora_provi_ordi = mora_provi_ordi + MtoMoraOrdiMa,
                      mora_provi_cope = mora_provi_cope + MtoMoraCopeMa,
                      mora_status = 1
                WHERE empresa = pempresa
                  AND num_credito = vNumCred
                  AND fecha_cuota = vFechaCuota;

           END IF


        -- *********************************************
        -- *        Calculo de pago minimo             *
        -- *********************************************
        LET vMensaje = "Calculo de pago Minimo";
        -- Pregunta si hay capital pendiente para cobrar los moratorios
        IF TrasHoy = "N" THEN
            IF SdoCapInsoluto = 0 THEN
                LET vSdoAcumMora = 0;
            END IF
        END IF

{ --JOM
        SELECT SUM(iva_debe - iva_pagado) +
               SUM(mora_sdo_ordi - mora_sdo_ordi_pag) +
               SUM(mora_sdo_cope - mora_sdo_cope_pag) +
               SUM(mora_iva_debe - mora_iva_pagado)
          INTO TotalAdeudo
          FROM sd_amortiza_credito
         WHERE empresa = pempresa
           AND num_credito = vNumCred ;
} --JOM
        -- ************************************************************
        -- Valida si estaba en vencido y ya salio para que regenere el
        -- pago minimo RQM 10 011
        -- ************************************************************

      Let StatusCred = StatusCred;
--  JOM    let TotalAdeudo = TotalAdeudo;
      let SdoCapInsoluto = SdoCapInsoluto;
      let SdoNoExig = SdoNoExig;
      let SdoExigInt = SdoExigInt;

       SELECT monto_financiado - (monto_vencido  + mto_venc_trasp) INTO SdoTrab4
       FROM sd_maesdoshist
       WHERE fecha =  FechaHoy -1 UNITS MONTH
       AND empresa = pempresa
       AND num_credito = vNumCred;

       IF SdoTrab4 Is Null THEN
          LET SdoTrab4 = 0;
       END IF;

--  JOM       LET TotalAdeudo = TotalAdeudo + SdoCapInsoluto + SdoNoExig + SdoExigInt;

--  JOM      IF TotalAdeudo < 0 THEN LET TotalAdeudo = 0; END IF

        IF Es_Totalero = "S" THEN
            LET SdoTrab4 = 0;

            IF SdoCapInsoluto <= 0 THEN
                LET MontoFinanciado = 0;
            ELSE
                 LET TotalAdeudo = ROUND(((SdoCapital+CapTrasNo) / 10), -0) ;
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
{--jom
            IF StatusCred = "BT" THEN
            ELIF StatusCred = "BA" THEN
               LET vMtoVencido = MontoVencido;
            ELSE
               LET vMtoVencido = 0;
            END IF

            IF vMtoVencido IS NULL THEN
                    LET vMtoVencido = 0;
            END IF
}-- jom
            LET TotalAdeudo = ROUND(((SdoCapital+CapTrasNo) / 10), -0) ;

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

            IF (TotalAdeudo > SdoTrab4 ) THEN --OR SdoCapInsoluto <= SdoTrab4) THEN
               LET MontoFinanciado = TotalAdeudo;
            ELSE
               LET MontoFinanciado = SdoTrab4;
            END IF

           IF (SdoCapital+CapTrasNo) <= MontoFinanciado THEN   --SdoCapInsoluto <= MontoFinanciado THEN
              LET MontoFinanciado = (SdoCapital+CapTrasNo);   --SdoCapInsoluto;
                IF MontoFinanciado < 0 THEN
                   LET MontoFinanciado = 0;
                END IF;
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
 		LET vCuotaMes =MontoFinanciado;
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
       { IF (SdoCapital+CapTrasNo) > 0 THEN
              IF StatusCred = "BT" THEN
                   SELECT monto_financiado
                     INTO vMtoVencido
                     FROM sd_maesdoshist
                    WHERE fecha =  vFechaVenc
                      AND empresa = pempresa
                      AND num_credito = vNumCred;
              ELSE
                LET vMtoVencido = ROUND((SdoCapital+CapTrasNo / 10),-0);
                --LET vMtoVencido = ROUND(SdoCapital+CapTrasNo,-0);
              END IF
}

              CALL prorratea_cargos(pEmpresa, vNumCred, vCuotaMes)
              RETURNING CodRet;
            IF (CodRet <> "000") THEN
                  ROLLBACK WORK;
                  LET vMensaje = TRIM(vMensaje) || " Prorratea Cargos";
                  CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,
                                vMensaje)
                  RETURNING rLog;
                  IF rLog > 0 THEN
                     RETURN CodRet;
                  ELSE
                     CONTINUE FOREACH;
                  END IF
            END IF;
               --** Actualiza Amortiza En CampoTrabajo1  --**
            SELECT NVL(Sum(iva_debe - iva_pagado),0) Into vIvaIntMes FROM sd_amortiza_credito
            WHERE empresa = pEmpresa and num_credito = vNumCred and
                  capital_status in ('2','7');
            UPDATE sd_amortiza_credito SET campo_trabajo1 = vIvaIntMes
            WHERE empresa = pEmpresa and num_credito = vNumCred and
                  fecha_cuota = FechaHoy;
        --END IF


      -- ********************************************************************
      -- Actualiza Intereses del periodo en las columnas correspondientes   *
      -- ********************************************************************
      IF StatusCred IN ("AA", "BA") THEN
         LET SdoNoExig = SdoIntereses;
      --ELIF StatusCred = "BA" THEN
        --      LET SdoExigInt = SdoExigInt + SdoIntereses;
      ELSE
         LET IntTraNoExig = IntTraNoExig + SdoIntereses;
{ -- JOM
         UPDATE sd_amortiza_credito
            SET capital_status ="2"
          WHERE empresa = pempresa
            AND num_credito = vNumCred
            AND fecha_cuota < FechaHoy
            AND capital_status <> "5"
            AND capital_debe > 0;
} -- JOM
      END IF;

      LET SdoIntereses = 0;

      -- Actualiza Anexo Maecred
      LET vCorteHoy = DATE(MONTH(FechaHoy) || "/" ||
                      vDiaDeCorte || "/" ||
                      YEAR(FechaHoy));
      LET vFecProxPag = DATE(MONTH(FechaHoy + 1 UNITS MONTH) || "/" ||
                        "16/" ||
                        YEAR(FechaHoy + 1 UNITS MONTH));


      UPDATE sd_maecredanexo
         SET prox_fecha_pago = vFecProxPag,
             fecha_vencto = vFechaVenc
       WHERE empresa = pEmpresa
         AND num_credito = vNumCred;


          IF ( StatusCred = "AA" ) THEN
              UPDATE sd_amortiza_credito
                 SET capital_status = "5",
                     capital_pagado = capital_debe
               WHERE empresa = pEmpresa
                 AND num_credito = vNumCred
                 AND fecha_cuota = FechaHoy - 1 UNITS MONTH
                 AND capital_status NOT IN ("2","7");
          END IF;

        END IF; -- Termina IF de DIa de Corte
   END IF;

   -- **********************************************
   -- Actualiza Tabla de Amortizaciones y Maestros
   -- **********************************************

   CALL libera_retenido(pEmpresa, vNumCred, SdoRetenido)
   RETURNING CodRet, SdoRetenido;
   IF (CodRet <> "000") THEN
       LET vMensaje = " Libera Retenido";
       CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,
                                vMensaje)
       RETURNING rLog;
   END IF;

Let SdoNoExig = SdoNoExig;

  -- ******************************************************


   UPDATE sd_maesdos
   SET
      fecha_ult_mov    = FechaHoy,        sdo_int_anticip  = SdoIntAnticip,
      sdo_int_ant_dev  = SdoIntAntDev ,   sdo_intereses    = SdoIntereses,
      sdo_dia_ant_int  = SdoDiaAntInt,    sdo_retenido     = SdoRetenido,
      sdo_acum_mes_int = SdoAcumMesInt ,  sdo_exig_int     = SdoExigInt,
      sdo_no_exig      = SdoNoExig,       provision_normal = ProvisionNormal,
      dias_acum_int    = DiasAcumInt,     sdo_moratorio    = SdoMoratorio,
      sdo_dia_ant_mor  = SdoDiaAntMor,    sdo_mes_ant_mor  = SdoMesAntMor,
      sdo_contab_mora  = vSdoAcumMora,    dias_acum_mora   = DiasAcumMora,
      sdo_capital      = SdoCapital ,     sdo_cap_insoluto = SdoCapInsoluto,
      sdo_dia_ant_cap  = SdoDiaAntCap,    sdo_mes_ant_cap  = SdoMesAntCap,
      sdo_acum_mes_cap = SdoAcumMesCap,   dias_acum_cap    = DiasAcumCap,
      mto_capitalizado = MtoCapitalizado, monto_vencido    = MontoVencido,
      mto_venc_trasp   = MtoVencTrasp,    dias_acum_intper = DiasAcumIntPer,
      sdo_global_int   = SdoGlobalInt,    sdo_acum_intper  = SdoAcumIntPer,
      mto_venc_int     = MtoVencInt,      mto_venc_tra_int = MtoVencTraInt,
      monto_financiado = MontoFinanciado, monto_reservado  = MontoReservado,
      int_tra_no_exig  = IntTraNoExig,    sdo_trab4        = SdoTrab4,
      cap_tras_no_venci = CapTrasNo

  WHERE num_credito = vNumCred
    AND empresa     = pEmpresa;

  UPDATE sd_maecred
     SET status_cred = StatusCred
   WHERE num_credito = vNumCred
     AND empresa = pEmpresa;

  UPDATE sd_maecredanexo
     SET fecha_proceso = ProxFecha
   WHERE num_credito = vNumCred
     AND empresa = pEmpresa;

  -- ******************************************************
  -- Actualiza tabla de saldos diaria y mensual
  -- ******************************************************

  -- Select sdo_capital, monto_vencido, cap_tras_no_venci, mto_venc_trasp,sdo_no_exig, int_tra_no_exig

    Let vIvaInt = 0;

    Select sum(iva_debe - iva_pagado) into  vIvaInt from sd_amortiza_credito
     where empresa = pEmpresa and num_credito = vNumCred;

--   IF StatusCred = 'BA' then
      IF ( StatusCred <> 'AA' ) then
          Let vIvaIntv  = vIvaInt;
          Let vIvaInt   = 0;
      END IF;
--   Elif StatusCred = 'BT' then
--      Let vIvaIntv  = vIvaInt;
--      Let vIvaInt   = 0;
--  End If;

   LET vDia = DAY (FechaHoy);
   IF FechaHoy = PriDiaMes THEN
   	Let vFecMes = PriDiaMes - 1 UNITS DAY;
        Let vFecMes = MDY(MONTH(vFecMes),20,YEAR(vFecMes));
        CALL sp_actsdomensual(pEmpresa,vNumCred,vFecMes,YEAR(vFecMes),MONTH(vFecMes))
        RETURNING CodRet;
        IF CodRet <> '000' THEN
              CALL log_cierre (pEmpresa, "0000000", CodRet, FechaHoy,
                               "Cierre Mensual      ")
              RETURNING rLog;
              RETURN CodRet;
        ELSE
              delete from sd_sdodiario where  num_credito = vNumCred;
        END IF;
          CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
                              SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vDia)
          RETURNING CodRet;
        IF (CodRet <> "000") THEN
          LET vMensaje = " Saldos Diarios";
          CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,
                                  vMensaje)
          RETURNING rLog;
       END IF;

   ELSE
          CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
                             SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vDia)
                         --    vIntDiario,vIntOrden,vIvaInt,vIvaOrden,vDia)
          RETURNING CodRet;
       IF (CodRet <> "000") THEN
          LET vMensaje = " Saldos Diarios";
          CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,
                                  vMensaje)
          RETURNING rLog;
      END IF;
  END IF;




   -- *********************************************
   -- Realiza Pase de Moviento Diario a Historico *
   -- *********************************************
    INSERT INTO sd_movhis
    SELECT * FROM sd_movdia
     WHERE num_credito = vNumCred
       AND empresa = pEmpresa;

    DELETE FROM sd_movdia
     WHERE num_credito = vNumCred
       AND empresa = pEmpresa;

   -- *********************************************
   -- Genera Estado de Cuenta                     *
   -- *********************************************
   IF DAY(FechaHoy) = vDiaDeCorte THEN

        -- Genera Historico de Saldos
        LET vMensaje = "Paso a MaesdosHist    ";
        INSERT INTO sd_maesdoshist
        SELECT FechaHoy, *
          FROM sd_maesdos
         WHERE empresa = pEmpresa
           AND num_credito = vNumCred;

       UPDATE sd_maesdos
          SET sdo_int_anticip  = 0,
              sdo_int_ant_dev  = 0,
              sdo_mes_ant_int  = sdo_intereses,
              sdo_intereses    = 0,
              sdo_acum_mes_int = 0,
              sdo_acum_intper  = 0,
              sdo_acum_mes_cap = 0,
              dias_acum_cap    = 0,
              dias_acum_int    = 0
        WHERE empresa = pEmpresa
          AND num_credito = vNumCred;

   END IF
   -- **************************************************
   -- Respaldo de datos para contabilidad a fin de mes *
   -- **************************************************
   IF FechaHoy = UltHabMes THEN
       INSERT INTO sd_maesdoscont
       SELECT FechaHoy, *
         FROM sd_maesdos
        WHERE num_credito = vNumCred
          AND empresa = pEmpresa ;

      INSERT INTO sd_maecredcont
      SELECT FechaHoy, *
        FROM sd_maecred
       WHERE num_credito = vNumCred
         AND empresa = pEmpresa ;

         let vinsert_finmes = vinsert_finmes + 1;

         if (vinsert_finmes >= 80000) then
            let vinsert_finmes = 0;
            update statistics medium for table sd_maesdoscont;
            update statistics medium for table sd_maecredcont;
         end if;

   END IF

 COMMIT WORK;

END FOREACH

--//FIN proceso
RETURN CodRet;

END PROCEDURE
DOCUMENT
'Procedimiento para la provision y traspaso a cartera ',
'vencida para creditos tipo tarjeta',
'AUTOR : Antonio Ruiz',
'FECHA : 30/Diciembre/2006',
'VERSION: 1.00.006',
'BD    : BDICRED'
;

CREATE PROCEDURE "informix".sp_crea_amortiza(pEmpresa CHAR(3),
                                             pCredito CHAR(20),
                                             pFecCuota DATE)
RETURNING CHAR(5);


   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE GLOBAL g_Fecha         DATE        DEFAULT ' ';
   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE vMensaje            VARCHAR(50);
   DEFINE vNumPag             INTEGER;
   DEFINE vMtoPagFijo         DECIMAL(14,2);
   DEFINE vPeriodo            INTEGER;
   DEFINE vDiasTrans          INTEGER;
   DEFINE vDiasCuota          INTEGER;
   DEFINE vPlazo              INTEGER;

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;



  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET cod_ret    = "000";
   LET vMensaje   = "";
   LET vNumPag    = 0;
   LET vMtoPagFijo= 0;
   LET vPeriodo   = 0;
   LET vDiasTrans = 0;
   LET vDiasCuota = 0;
   LET vPlazo     = 0;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

     SELECT plazo
     INTO vPlazo
     FROM sd_maecred
     WHERE empresa = pEmpresa
      AND num_credito = pCredito ;

{     SELECT LPAD(dia_corte,2,0)
     INTO vDiasCuota
     FROM sd_maecredanexo
     WHERE empresa = pEmpresa
      AND num_credito = pCredito ;
}

     SELECT  num_pago ,capital_mto_cuota
     INTO vNumPag , vMtoPagFijo
     FROM sd_amortiza_credito
     WHERE empresa = pEmpresa
      AND num_credito = pCredito
      AND fecha_cuota = pFecCuota;
 
  --Incrementa Una Coota

   LET vNumPag = vNumPag + 1;
   LET vDiasCuota = DAY(pFecCuota);

   --Calcula La Sig Fec. De Amortizacion

     CALL sp_cal_fecha(pFecCuota,2,1,6,1) RETURNING cod_ret,pFecCuota,vPeriodo,vDiasTrans;
--     IF DAY(pFecCuota) <> vDiasCuota THEN
       LET pFecCuota = MDY(MONTH(pFecCuota), vDiasCuota,YEAR(pFecCuota));
--     END IF;

   --Insert En Amortiza

  IF vNumPag < vPlazo THEN
    INSERT INTO sd_amortiza_credito
                (empresa            , num_credito         , fecha_cuota       ,
                 tipo_cuota         , capital_mto_cuota   , capital_debe      ,
                 capital_pagado     , capital_status      , capital_status_ant,
                 capital_fecha_pago , interes_debe        , interes_pagado    ,
                 interes_status     , interes_status_ant  , interes_fecha_pago,
                 iva_debe           , iva_pagado          , iva_status        ,
                 iva_status_ant     , iva_fecha_pago      , mora_provi_ordi   ,
                 mora_provi_cope    , mora_sdo_ordi       , mora_sdo_ordi_pag ,
                 mora_sdo_cope      , mora_sdo_cope_pag   , mora_bonificado   ,
                 mora_status        , mora_iva_debe       , mora_iva_pagado   ,
                 mora_iva_status    , mora_iva_fecha_pago , num_pago          ,
                 campo_trabajo1     , campo_trabajo2      , campo_trabajo3    ,
                 campo_trabajo4)
      VALUES   ( pEmpresa          , pCredito             ,pFecCuota          ,
                '3'                , vMtoPagFijo         , 0                 ,
                 0                 , 1                   , 0                 ,
                 ''                , 0                   , 0                 ,
                 1                 , 0                   , 0                 ,
                 0                 , 0                   , 0                 ,
                 0                 , ''                  , 0                 ,
                 0                 , 0                   , 0                 ,
                 0                 , 0                   , 0                 ,
                '1'                , 0                   , 0                 ,
                0                  , NULL                , vNumPag           ,
                vMtoPagFijo        , NULL                , NULL              ,
                NULL);
   END IF;


        IF cod_ret = "00000" THEN
                LET cod_ret = "000";
        END IF


END
        RETURN cod_ret;

END PROCEDURE
;