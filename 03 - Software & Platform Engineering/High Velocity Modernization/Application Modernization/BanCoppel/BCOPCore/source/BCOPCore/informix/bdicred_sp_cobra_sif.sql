CREATE PROCEDURE "informix".sp_cobra_sif(c_empresa CHAR(3),
                                         c_sucursal CHAR(4),
			                             c_usuario CHAR(8),
                                         c_num_credito CHAR(20),
                                         c_monto   DECIMAL(14,2),
                                         c_monto_vencido DECIMAL(14,2))

RETURNING CHAR(5),CHAR(16);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret             CHAR(5);
DEFINE vcod_ret             CHAR(5);
DEFINE smen_ret             CHAR(125);
DEFINE vsqlerr              INTEGER;
DEFINE v_folio              CHAR(16);
DEFINE v_val                DECIMAL(18,2);
DEFINE v_val1               CHAR(20);
DEFINE v_val2               CHAR(17);
DEFINE v_val3               DECIMAL(18,2);
DEFINE vSucCre              CHAR(4);
DEFINE vIvaSuc              CHAR(5);
DEFINE vFecCuota            DATE;
DEFINE vFechaHoy            DATE;
DEFINE dAplicaReverso       INTEGER;
DEFINE dSeAplicoReverso     INTEGER;
DEFINE v_montopago          DECIMAL(14,2);
DEFINE GLOBAL g_dtFechaHoy           DATE           DEFAULT "";


-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret              = "000";
LET vcod_ret              = "000";
LET vsqlerr               = 0;
LET vFechaHoy             = "";
LET vSucCre               = "";
LET v_folio               = "";
LET vFecCuota             = '';
LET smen_ret              = '';
LET dAplicaReverso        = 0;
LET dSeAplicoReverso      = 0;
LET v_val1                = '';
LET v_val2                = '';
LET v_val3                = 0;
LET v_montopago           = 0;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      ROLLBACK WORK;
      LET scod_ret=vsqlerr;
      RETURN scod_ret,v_folio;
   END IF;
END EXCEPTION;

--  SET DEBUG FILE TO "/pisa/cas/sp_cobra_sif.out";
--  TRACE ON;

-- Valida los Nulos en los Parametros de Entrada
IF c_empresa = "" OR c_sucursal = "" OR c_usuario = "" OR
   c_num_credito = "" OR c_monto = "" THEN
   LET scod_ret = "110";
   RETURN scod_ret,v_folio;
END IF;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

  SELECT fecha_hoy 
    INTO vFechaHoy
    FROM sd_fechas
   WHERE empresa=c_empresa;

   LET g_dtFechaHoy=vFechaHoy;

  -- La sucursal la Toma el Parametro de entrada
  -- Pero lo pudiera tomar del credito
  SELECT sucursal INTO vSucCre
  FROM sd_maecredcrd
  WHERE empresa = c_empresa
  AND   num_credito = c_num_credito;

  LET v_folio = "SIF"||SUBSTR(CURRENT HOUR TO FRACTION(2),1,2) ||
      SUBSTR(CURRENT HOUR TO FRACTION(2),4,2) ||
      SUBSTR(CURRENT HOUR TO FRACTION(2),7,2);

  IF c_monto_vencido = 0 THEN
      EXECUTE PROCEDURE "informix".sp_pago_anticipado_rr(c_empresa,c_num_credito,c_usuario,c_sucursal,v_folio,'7431',c_monto,'1')
      INTO scod_ret,smen_ret,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val3,v_val1,v_val,v_val,v_val2;
      IF scod_ret <> "00000" THEN
           select aplica_reverso
             into dAplicaReverso
             from sd_reversa_error
             where num_producto='6011'
               and codigo=scod_ret;

            IF dAplicaReverso>0 THEN
               EXECUTE PROCEDURE bdicheq:reversion (c_empresa,c_sucursal,c_usuario, v_folio,"A")
               INTO vcod_ret;
               IF vcod_ret<>"000" THEN
                  LET dSeAplicoReverso = 0;
               ELSE
                  LET dSeAplicoReverso = 1;
               END IF;
            END IF;
        RETURN scod_ret,v_folio;
      ELSE
          -- Por si tiene que hacer algo
         LET scod_ret='000';
      END IF;
   ELIF c_monto <= c_monto_vencido THEN
      EXECUTE PROCEDURE "informix".sp_principal_rr(c_empresa,c_num_credito,1,c_monto,c_usuario,c_sucursal,v_folio,'7432')
      INTO scod_ret,smen_ret,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val3,v_val1,v_val,v_val,v_val2;
      IF scod_ret <> "00000" THEN
           select aplica_reverso
             into dAplicaReverso
             from sd_reversa_error
             where num_producto='6011'
               and codigo=scod_ret;

            IF dAplicaReverso>0 THEN
               EXECUTE PROCEDURE bdicheq:reversion (c_empresa,c_sucursal,c_usuario, v_folio,"A")
               INTO vcod_ret;
               IF vcod_ret<>"000" THEN
                  LET dSeAplicoReverso = 0;
               ELSE
                  LET dSeAplicoReverso = 1;
               END IF;
            END IF;
          RETURN scod_ret,v_folio;
      ELSE
          -- Por si tiene que hacer algo
         LET scod_ret='000';
      END IF;
   ELIF c_monto > c_monto_vencido THEN

      LET v_montopago = c_monto - c_monto_vencido;

      EXECUTE PROCEDURE "informix".sp_principal_rr(c_empresa,c_num_credito,1,c_monto_vencido,c_usuario,c_sucursal,v_folio,'7432')
      INTO scod_ret,smen_ret,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val3,v_val1,v_val,v_val,v_val2;
      IF scod_ret <> "00000" THEN
           select aplica_reverso
             into dAplicaReverso
             from sd_reversa_error
             where num_producto='6011'
               and codigo=scod_ret;

            IF dAplicaReverso>0 THEN
               EXECUTE PROCEDURE bdicheq:reversion (c_empresa,c_sucursal,c_usuario, v_folio,"A")
               INTO vcod_ret;
               IF vcod_ret<>"000" THEN
                  LET dSeAplicoReverso = 0;
               ELSE
                  LET dSeAplicoReverso = 1;
               END IF;
            END IF;
          RETURN scod_ret,v_folio;
      ELSE
          EXECUTE PROCEDURE "informix".sp_pago_anticipado_rr(c_empresa,c_num_credito,c_usuario,c_sucursal,v_folio,'7431',v_montopago,'0')
          INTO scod_ret,smen_ret,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val3,v_val1,v_val,v_val,v_val2;
          IF scod_ret <> "00000" THEN
            EXECUTE PROCEDURE "informix".reversioncrd(c_empresa,c_sucursal,c_usuario,v_folio,"A")
            INTO vcod_ret;
               IF vcod_ret<>"000" THEN
                  LET dSeAplicoReverso = 0;
               ELSE
                  LET dSeAplicoReverso = 1;
               END IF;
           RETURN scod_ret,v_folio;
          END IF;
          -- Por si tiene que hacer algo
         LET scod_ret='000';
      END IF;
   END IF;

   Insert into "informix".sd_log_cobroaut 
   (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
   values ('06','CobroAnSIF',vFechaHoy,current,c_usuario,c_num_credito,v_val1,dSeAplicoReverso,v_folio,v_val3,scod_ret,vcod_ret,v_val2);

END
   RETURN scod_ret,v_folio;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_actualiza_credito_apoyo_2(pEmpresa CHAR(3))
    RETURNING CHAR(5), char(100);

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
   DEFINE vcapmasvencido      DECIMAL(14,6);
   DEFINE vintordcap, vintcopcap DECIMAL(14,6);
   DEFINE vivacalc            DECIMAL(14,6);
   DEFINE vintmoraordi        DECIMAL(14,6);
   DEFINE vintmoracope        DECIMAL(14,6);
   DEFINE FechaHoy            DATE;
   DEFINE vBandera           CHAR(9);


   DEFINE SdoIntAnticip , SdoIntereses  , SdoDiaAntInt , SdoMesAntInt  , SdoAcumMesInt, SdoExigInt  , SdoNoExig    MONEY(14,2); --SdoIntAntDev   , , ProvisionNormal
   DEFINE SdoMoratorio  , SdoCapital   , SdoCapInsoluto, SdoDiaAntCap ,  SdoAcumMesCap, MontoVencido      MONEY(14,2); --SdoDiaAntMor   , SdoMesAntMor  , SdoMesAntCap,
   DEFINE MtoVencTrasp  ,DiasAcumIntPer , SdoGlobalInt  , SdoAcumIntPer, IntTraNoExig, SdoTrab4     , MontoFinanciado   MONEY(14,2); --MtoVencInt    , MtoVencTraInt,
   DEFINE IntTraNoExigMes  MONEY(14,2);
   DEFINE MtoCapitalizado, MtoMinistraCap, vIvaMora     , vSdoAcumMora  , SdoPromedio  , InteresMam  , InteresPmm   , InteresMad        MONEY(14,2); --MontoReservado,
   DEFINE InteresPmd    ,MontoProvision , MtoCapitaliza , TotalAdeudo  , MontoPago     , MtoMoraOrdi  , MtoMoraCope,  MtoMoraOrdiMa, MtoMoraCopeMa     MONEY(14,2);
   DEFINE MtoMoraOrdiPm ,MtoMoraCopePm,CapTrasNo,vIntOrden,vIvaOrd,vSdoNoExigPas,vIvaOrden,vIvaOrdenAnt,vCapInsEsTot                                   MONEY(14,2);

   DEFINE TasaAm, TasaHm, TasaAd, TasaHd, TasaIn, vTasaMora, TasaCope, TasaIntd, vTasaCte,TasaIntm                                                     DECIMAL(9,6) ;
   DEFINE vPrecioIni, vPrecioFin, TasaDiaria                                                                                                           DECIMAL(14,6);
   DEFINE vMtoVencido, vIvaInt, vIvaIntv, vIvaIntMes,  vReservaInt, vMtoProvision,SdoRetenido,vVencidoHist,MinimoMesAnt,VigenteMesAnt     DECIMAL(14,2); --vBaseReserva,
   DEFINE vProvIva,vProvInt, TopeMinimo, vIntDiario,  vCuotaMes,vIntOrd,vCalcIvaMesAnt                                                                 DECIMAL(14,2);
   DEFINE vPorcReserva                                                                                                                  DECIMAL(5,2) ;

   DEFINE DiasPeriodo, DiasAcCap, DiasMa, DiasPm, DifDias, DiaCuota, DiasAcumCap, DiasAcumInt, DiasAcumMora, Aniversario, vReferencia, vDiaDeCorte     SMALLINT     ;
   DEFINE vDiasGraciaMora, vDiasMaxPago, vDiasBloqueo, DiasProvMa, DiasProvPm, vDiasTrasp, vRMora, rLog, vCodRefInt,vPasoProm                          SMALLINT     ;

   DEFINE CambioMes           CHAR(1); DEFINE vCodigoFun   CHAR(3); DEFINE Folio       CHAR(16); DEFINE vSucursal   CHAR(4); DEFINE vDivisa            CHAR(2)      ;
   DEFINE NumProducto         CHAR(4); DEFINE Transacc     CHAR(4); DEFINE vTpDiasMora CHAR(1) ; DEFINE vTpDiasPago CHAR(1); DEFINE Begin              CHAR(1)      ;
   DEFINE TrasHoy             CHAR(1); DEFINE vCodFunInt  CHAR(3) ; DEFINE BanderaInt  CHAR(1); DEFINE vStProc            CHAR(1)      ;
   DEFINE StatusMora          CHAR(1); DEFINE vForeach     CHAR(1); DEFINE vBandFinan  CHAR(1) ; DEFINE vPlaza      CHAR(3); DEFINE Es_Totalero        CHAR(1)      ;
   DEFINE vSiCap              CHAR(1); DEFINE vDia         CHAR(2); DEFINE vCapVig     CHAR(10); DEFINE vCapTras    CHAR(10); DEFINE vCapVenExig       CHAR(15)     ;
   DEFINE vIntVig             CHAR(10);DEFINE vIntVenc     CHAR(10);DEFINE vFolio      CHAR(16);
   DEFINE StatusCred, StatusCred_ant   CHAR(2);

   DEFINE FechaPagoCap, FechaPagoInt, vFechaVenc, vFecProxPag, vFProceso, vCorteHoy,vFechaReserva ,vFechaCuota,vFechaUDIant,vFecMes                     DATE        ;
   DEFINE vErrores,vMarcaAyuda                                                                                                                          INTEGER     ;
--jom   DEFINE MesAnio                                                                                                                             DATETIME YEAR TO MONTH;
 --  DEFINE vinsert_finmes integer;
   DEFINE MontoPasa decimal(14,2);
   DEFINE Porcenmin decimal(14,6);
   DEFINE vinterescapitalizar, vivacapitalizar decimal(14,6);
-- Actualiza moras
   DEFINE vsdo_mora,vsum_mora,vsdo_contab_mora,vsum_contabmora decimal(14,6);

   define vcontador integer;

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET CodRet = sql_err;
         ROLLBACK WORK;
         RETURN CodRet, "Error en el proceso"||isam_err;
   END EXCEPTION WITH RESUME;


  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   SET ISOLATION TO DIRTY READ;


   LET CodRet            = '000';
   LET SdoIntereses      = 0;     LET SdoDiaAntInt      = 0;   LET SdoMesAntInt   = 0;  LET SdoAcumMesInt     = 0; LET SdoExigInt       = 0;    LET SdoNoExig         = 0;
  -- LET ProvisionNormal   = 0;     LET SdoDiaAntMor      = 0; LET SdoMesAntMor     = 0;  LET SdoMesAntCap      = 0;
   LET DiasAcumInt       = 0;   LET SdoMoratorio   = 0;       LET DiasAcumMora      = 0;
   LET SdoCapital        = 0;     LET SdoCapInsoluto    = 0;   LET SdoDiaAntCap   = 0;  LET SdoAcumMesCap    = 0;    LET DiasAcumCap       = 0;
   LET MontoVencido      = 0;     LET MtoVencTrasp      = 0;   LET DiasAcumIntPer = 0;  LET SdoGlobalInt      = 0; LET SdoAcumIntPer    = 0;   -- LET MtoVencInt        = 0;
   LET InteresMam        = 0;   LET InteresPmm     = 0;  LET DiasProvMa        = 0; LET DiasProvPm       = 0;    LET MtoMoraOrdi       = 0; --LET MtoVencTraInt     = 0;
   LET MtoMoraCope       = 0;     LET MtoMoraOrdiMa     = 0;   LET MtoMoraCopeMa  = 0;  LET MtoMoraOrdiPm     = 0; LET MtoMoraCopePm    = 0;    LET IntTraNoExig      = 0;
   LET SdoTrab4          = 0;      LET DiasMa         = 0;  LET DiasPm            = 0; LET CambioMes        = 'N';  LET MontoProvision    = 0;
   LET vCodigoFun        = '034'; LET vReferencia       = '';  LET Transacc       = ''; LET MtoCapitalizado   = 0; LET TasaAd           = 0;    LET TasaHd            = 0;
   LET DiasPeriodo       = 0;     LET MtoCapitaliza     = 0;   LET MtoMinistraCap = 0;  LET TotalAdeudo       = 0; LET MtoMoraOrdi      = 0;    LET MtoMoraCope       = 0;
   LET vNumCred          = " ";   LET rLog              = 0;   LET vMensaje       = ""; LET vCorteHoy         = "";LET Begin            = "N";  LET TrasHoy           = "N";
   LET vPrecioIni        = 0;     LET vPrecioFin        = 0;   LET vIvaInt        = 0;  LET vIvaIntMes        = 0; LET vIvaIntv          = 0;   LET TasaDIaria        = 0;
   LET vIvaMora          = 0;     LET vSdoAcumMora      = 0;   LET vReservaInt       = 0; LET vPorcReserva      = 100; LET vForeach          = "N"; --LET vBaseReserva   = 0;
   LET vMtoVencido       = 0;     LET vPasoProm         = 0;   LET BanderaInt     ="?"; LET vProvInt          = 0; LET vProvIva          = 0;   LET Es_Totalero       = "?";
   LET vDia              ='';     LET vCapVig           ='';   LET vCapTras       ='';  LET vCapVenExig       =''; LET vIntVig           ='';   LET vIntVenc          ='';
   LET vIntDiario        = 0;     LET vCuotaMes         = 0;   LET vFechaUDIant   ='';  LET vFecMes           = '';LET vIntOrd           =0;
   LET vFolio            ='';     LET vIntOrden      = 0;      LET vIvaOrd        = 0;  LET vSdoNoExigPas = 0;
   LET vIvaOrden         = 0;
   LET StatusCred        = '';
   LET vIvaOrdenAnt      = 0;
 --  LET vinsert_finmes    = 0;
   LET vcontador         = 0;
   LET vcapmasvencido    = 0;
   LET vintordcap        = 0;
   let vintcopcap        = 0;
 --  LET vintcap           = 0;
 --  LET vintcalc          = 0;
   LET vivacalc          = 0;
   LET vintmoraordi      = 0;
   LET vintmoracope      = 0;
   let vinterescapitalizar = 0;
   let vivacapitalizar  = 0;
   let vsdo_mora        = 0;
   let vsum_mora        = 0;
   let vsdo_contab_mora = 0;
   let vsum_contabmora  = 0;



    SELECT * FROM bdinteg:si_sucursales
     WHERE tpo_sucursal = "S"
      INTO TEMP cr_sucursales2;
    CREATE INDEX crsucursal on cr_sucursales2 (empresa, sucursal);
    update statistics high for table cr_sucursales2 (empresa, sucursal);


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
-- SET EXPLAIN ON;

--SET DEBUG FILE TO "/pisa/cas/provisionlinea.out";
--TRACE ON;

      SELECT fecha_hoy
        INTO FechaHoy
        FROM sd_fechas
       WHERE empresa = pEmpresa;
      IF FechaHoy IS NULL THEN
         LET CodRet = "110";
         RETURN CodRet,'Fecha no encontrada';
      END IF

      SELECT valor INTO vBandera
        FROM sd_param
       WHERE empresa = pEmpresa
         AND cod_param = "020";       -- parametro para actualizar bandera


  SELECT
     USER||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(current,3,2)||
     SUBSTR(CURRENT,12,2)||substr(current,15,2)
     ||SUBSTR(current,18,2)
  INTO Folio
  FROM dual;

FOREACH WITH HOLD
    select a.num_credito
     into vNumCred
     from bdicred:sd_maecred a, bdicred:sd_maesdos b
    where a.empresa = pEmpresa
      and a.empresa = b.empresa
      and a.num_credito = b.num_credito
      and monto_financiado = sdo_trab4
      and status_cred in ('BA','BT')
      and a.num_credito in
      (select num_credito from bdicred:sd_prog_apoyo where bandera ='2')

    BEGIN WORK;

        select status_cred, sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, sdo_moratorio, sdo_contab_mora, tasa_interes, tasa_moratorios,
               num_producto, sucursal
          into StatusCred, SdoCapital, MontoVencido, MtovencTrasp, CapTrasNo, SdoMoratorio, vSdoAcumMora, TasaIntm, vTasaMora,
               NumProducto, vSucursal
         FROM sd_maesdos a, sd_maecred b
        WHERE a.num_credito = vNumCred
          AND a.empresa = pEmpresa
          AND a.num_credito = b.num_credito
          AND a.empresa     = b.empresa;

          if ( StatusCred = 'BA' ) then
                Update bdicred:sd_maecred
                   set status_cred='AA'
                 where empresa=pEmpresa
                   and num_credito=vNumCred;

                Update bdicred:sd_amortiza_credito
                   set capital_pagado = capital_debe,
                       mora_provi_ordi = 0,
                       mora_provi_cope = 0,
                       mora_sdo_ordi = mora_sdo_ordi_pag,
                       mora_sdo_cope = mora_sdo_cope_pag,
                       capital_status = '5',
                       capital_fecha_pago = today,
                      campo_trabajo4 = 'PROG.APOYO'
                where empresa=pEmpresa
                  and num_credito=vNumCred
                  and fecha_cuota = mdy('10','20','2010');
--                  and capital_status='7';

               Update bdicred:sd_maecredanexo
                  set fecha_vencto=NULL
                where empresa=pEmpresa
                  and num_credito=vNumCred;

                if ( SdoMoratorio < 0 ) then let SdoMoratorio = 0; end if;
                if ( vSdoAcumMora < 0 ) then let vSdoAcumMora = 0; end if;

                update bdicred:sd_maesdos
                   set sdo_capital = sdo_capital+monto_vencido,
                       monto_financiado = monto_financiado-monto_vencido,
                       sdo_trab4 = sdo_trab4 - monto_vencido,
                       monto_vencido = 0,
                       sdo_intereses = sdo_intereses + ((sdo_moratorio+sdo_contab_mora)*TasaIntm/vTasaMora),
                       sdo_dia_ant_int = sdo_dia_ant_int + ((sdo_moratorio+sdo_contab_mora)*TasaIntm/vTasaMora),
                       sdo_int_anticip = sdo_int_anticip + ((sdo_moratorio+sdo_contab_mora)*TasaIntm/vTasaMora),
                       sdo_acum_mes_int = sdo_acum_mes_int + ((sdo_moratorio+sdo_contab_mora)*TasaIntm/vTasaMora),
                       sdo_global_int = sdo_global_int + ((sdo_moratorio+sdo_contab_mora)*TasaIntm/vTasaMora),
                       sdo_acum_intper = sdo_acum_intper + ((sdo_moratorio+sdo_contab_mora)*TasaIntm/vTasaMora),
                       sdo_moratorio=0,
                       sdo_contab_mora=0,
                       dias_acum_mora=0
                 where empresa=pEmpresa
                   and num_credito=vNumCred;

                update bdicred:sd_maesdoshist
                   set sdo_capital = sdo_capital + monto_vencido,
                       monto_financiado = monto_financiado - monto_vencido,
                       sdo_trab4 = sdo_trab4 - monto_vencido,
                       monto_vencido = 0,
                       sdo_moratorio=0,
                       sdo_contab_mora=0,
                       mto_fin_ven_trasp = 0,
                       dias_acum_mora=0
                 where empresa=pEmpresa
                   and num_credito=vNumCred
                   and fecha = mdy('11','20','2010');

                SELECT  plaza
                  INTO vPlaza
                  FROM bdinteg:cr_sucursales2
                 WHERE empresa = pEmpresa
                   AND sucursal = vSucursal;

                  CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,6,
                                   "601", mdy('11','20','2010'), MontoVencido,
                                   Folio, vSucursal, '01', '', vPlaza)
                  RETURNING CodRet, Mensaje;

                  IF (CodRet <> "00000") THEN
                      ROLLBACK WORK;
                      LET vMensaje = "Problema al generar movimiento de transitorio : "|| vNumCred ;
                      return CodRet, Mensaje;
                  END IF;
          else
            select count(*)
              into vcontador
              from bdicred:sd_amortiza_credito
             where empresa=pEmpresa
               and num_credito=vNumCred
               and capital_status='2';

               if ( vcontador = 1 ) then
                    continue  FOREACH;
               elif ( vcontador = 2 ) then

                    Update bdicred:sd_maecred
                       set status_cred='BA'
                     where empresa=pEmpresa
                       and num_credito=vNumCred;

                   Select sum(capital_debe - capital_pagado), sum(mora_provi_ordi + mora_sdo_ordi - mora_sdo_ordi_pag)
                     Into vcapmasvencido, vintordcap
                     from bdicred:sd_amortiza_credito
                    where empresa=pEmpresa
                      and num_credito=vNumCred
                      and fecha_cuota=mdy('09','20','2010');
    --                  and capital_status='2';

                    Update bdicred:sd_amortiza_credito
                       set capital_pagado = capital_debe,
                           mora_provi_ordi = 0,
                           mora_provi_cope = 0,
                           mora_sdo_ordi = mora_sdo_ordi_pag,
                           mora_sdo_cope = mora_sdo_cope_pag,
                          capital_status = '5',
                          capital_fecha_pago = today,
                          campo_trabajo4 = 'PROG.APOYO'
                    where empresa=pEmpresa
                      and num_credito=vNumCred
                      and fecha_cuota=mdy('09','20','2010');
    --                  and capital_status='2';

                   Update bdicred:sd_maecredanexo
                      set fecha_vencto=mdy('10','20','2010')
                    where empresa=pEmpresa
                      and num_credito=vNumCred;


                    Update bdicred:sd_amortiza_credito
                       set interes_debe =  interes_debe + vintordcap,
                           iva_debe = iva_debe + (case when interes_debe<=0 then 0 else vintordcap*iva_debe/interes_debe end),
                          campo_trabajo4 = 'PROG.APOYO'
                    where empresa=pEmpresa
                      and num_credito=vNumCred
                      and fecha_cuota=mdy('11','20','2010');
    --                  and capital_status='1';


                    Select (sum(mora_provi_ordi + mora_sdo_ordi - mora_sdo_ordi_pag) * vcapmasvencido)/ (sum(capital_debe - capital_pagado) + vcapmasvencido),
                          (sum(mora_provi_cope + mora_sdo_cope - mora_sdo_cope_pag) * vcapmasvencido)/ (sum(capital_debe - capital_pagado) + vcapmasvencido)
                    Into  vintmoraordi, vintmoracope
                    from bdicred:sd_amortiza_credito
                    where empresa=pEmpresa
                      and num_credito=vNumCred
                      and fecha_cuota=mdy('10','20','2010');
    --                  and capital_status='2';

                    Update bdicred:sd_amortiza_credito
                       set mora_provi_ordi = 0,
                           mora_provi_cope = 0,
                           mora_sdo_ordi = mora_sdo_ordi_pag + mora_provi_ordi - vintmoraordi,
                           mora_sdo_cope = mora_sdo_cope_pag + mora_provi_cope - vintmoracope,
                           capital_status = '7',
                           campo_trabajo4 = 'PROG.APOYO'
                    where empresa=pEmpresa
                      and num_credito=vNumCred
                      and fecha_cuota=mdy('10','20','2010');
    --                  and capital_status='2';

                    update bdicred:sd_maesdos
                       set sdo_capital = vcapmasvencido + cap_tras_no_venci,
                           monto_vencido = mto_venc_trasp - vcapmasvencido,
                           mto_venc_trasp = 0,
                           cap_tras_no_venci= 0,
                           monto_financiado = monto_financiado - vcapmasvencido,
                           sdo_trab4 = sdo_trab4 - vcapmasvencido,
                           sdo_intereses = sdo_intereses + vintmoraordi,
                           sdo_dia_ant_int = sdo_dia_ant_int + vintmoraordi,
                           sdo_int_anticip = sdo_int_anticip + vintmoraordi,
                           sdo_acum_mes_int = sdo_acum_mes_int + vintmoraordi,
                           sdo_global_int = sdo_global_int + vintmoraordi,
                           sdo_acum_intper = sdo_acum_intper + vintmoraordi,
                           sdo_no_exig = int_tra_no_exig + vintordcap,
                           int_tra_no_exig = 0,
                           sdo_moratorio= (sdo_moratorio+ sdo_contab_mora) - vintmoraordi - vintmoracope,
                           dias_acum_mora = today - mdy('11','20','2010'),
                           sdo_contab_mora=0
                     where empresa=pEmpresa
                       and num_credito=vNumCred;

                SELECT
                sdo_moratorio, 
                nvl((SELECT sum(mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag) FROM bdicred:sd_amortiza_credito WHERE a.empresa = empresa AND a.num_credito = num_credito AND capital_status IN ('2','7')),0),
                sdo_contab_mora,
                nvl((SELECT sum(mora_provi_ordi + mora_provi_cope) FROM bdicred:sd_amortiza_credito WHERE a.empresa = empresa AND a.num_credito = num_credito AND capital_status IN ('2','7')),0)
                INTO vsdo_mora,vsum_mora,vsdo_contab_mora,vsum_contabmora
                FROM bdicred:sd_maecred a,
                     bdicred:sd_maesdos b
                WHERE a.empresa = b.empresa
                  AND a.num_credito = b.num_credito
                  AND a.num_credito = vNumCred
                  AND status_cred in ('BA','BT')
                  AND (sdo_moratorio <> nvl((SELECT sum(mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag) FROM bdicred:sd_amortiza_credito WHERE a.empresa = empresa AND a.num_credito = num_credito AND capital_status in ('2','7')),0)
                   OR  sdo_contab_mora <> nvl((SELECT sum(mora_provi_ordi + mora_provi_cope) FROM bdicred:sd_amortiza_credito WHERE a.empresa = empresa AND a.num_credito = num_credito AND capital_status IN ('2','7')),0));

                 IF   vsdo_mora <> vsum_mora or vsdo_contab_mora <> vsum_contabmora THEN
                      UPDATE bdicred:"informix".sd_maesdos SET sdo_contab_mora = vsum_mora, sdo_moratorio =  vsum_contabmora
                       WHERE empresa = pEmpresa
                         AND num_credito = vNumCred;
                 END if;


                    update bdicred:sd_maesdoshist
                       set sdo_capital = vcapmasvencido + cap_tras_no_venci,
                           monto_vencido = mto_venc_trasp - vcapmasvencido,
                           mto_venc_trasp = 0,
                           cap_tras_no_venci= 0,
                           monto_financiado = monto_financiado - vcapmasvencido,
                           sdo_trab4 = sdo_trab4 - vcapmasvencido,
                           sdo_intereses = sdo_intereses + vintmoraordi,
                           sdo_no_exig = int_tra_no_exig + vintordcap,
                           dias_acum_mora = 1,
                           sdo_contab_mora = (mto_venc_trasp - vcapmasvencido) * 1.03 / 360,
                           mto_fin_ven_trasp = 1,
                           sdo_moratorio = 0,
                           int_tra_no_exig = 0
                     where empresa=pEmpresa
                       and num_credito=vNumCred
                       and fecha = mdy('11','20','2010');


                        SELECT plaza
                          INTO vPlaza
                          FROM bdinteg:cr_sucursales2
                         WHERE empresa = pEmpresa
                           AND sucursal = vSucursal;

                          CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,10,
                                           "601", mdy('11','20','2010'), vcapmasvencido,
                                           Folio, vSucursal, '01', '', vPlaza)
                          RETURNING CodRet, Mensaje;

                          IF (CodRet <> "00000") THEN
                              ROLLBACK WORK;
                              LET vMensaje = "Problema al generar movimiento de traspaso a vigente (EXIG) : "|| vNumCred ;
                              return CodRet, Mensaje;
                          END IF;

                          CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,902,
                                           "033", mdy('11','20','2010'), CapTrasNo,
                                           Folio, vSucursal, '01', '', vPlaza)
                          RETURNING CodRet, Mensaje;

                          IF (CodRet <> "00000") THEN
                              ROLLBACK WORK;
                              LET vMensaje = "Problema al generar movimiento de traspaso a vigente (NO EXIG) : "|| vNumCred ;
                              return CodRet, Mensaje;
                          END IF;

                          CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,9,
                                           "601", mdy('11','20','2010'), MtovencTrasp-vcapmasvencido,
                                           Folio, vSucursal, '01', '', vPlaza)
                          RETURNING CodRet, Mensaje;

                          IF (CodRet <> "00000") THEN
                              ROLLBACK WORK;
                              LET vMensaje = "Problema al generar movimiento de traspaso a transitorio : "|| vNumCred ;
                              return CodRet, Mensaje;
                          END IF;
               elif ( vcontador = 3 ) then

                   Select sum(capital_debe - capital_pagado),
                          sum(mora_provi_ordi + mora_sdo_ordi - mora_sdo_ordi_pag),
                          sum(mora_provi_cope + mora_sdo_cope - mora_sdo_cope_pag)
                     Into vcapmasvencido, vintordcap, vintcopcap
                     from bdicred:sd_amortiza_credito
                    where empresa=pEmpresa
                      and num_credito=vNumCred
                      and fecha_cuota=mdy('08','20','2010');
    --                  and capital_status='2';

                    Update bdicred:sd_amortiza_credito
                       set capital_pagado = capital_debe,
                           mora_provi_ordi = 0,
                           mora_provi_cope = 0,
                           mora_sdo_ordi = mora_sdo_ordi_pag,
                           mora_sdo_cope = mora_sdo_cope_pag,
                          capital_status = '5',
                          capital_fecha_pago = today,
                          campo_trabajo4 = 'PROG.APOYO'
                    where empresa=pEmpresa
                      and num_credito=vNumCred
                      and fecha_cuota=mdy('08','20','2010');
    --                  and capital_status='2';

                   Update bdicred:sd_maecredanexo
                      set fecha_vencto=mdy('09','20','2010')
                    where empresa=pEmpresa
                      and num_credito=vNumCred;

                    Update bdicred:sd_amortiza_credito
                       set interes_debe =  interes_debe + vintordcap,
                           iva_debe = iva_debe + (case when interes_debe<=0 then 0 else vintordcap*iva_debe/interes_debe end),
                          campo_trabajo4 = 'PROG.APOYO'
                    where empresa=pEmpresa
                      and num_credito=vNumCred
                      and fecha_cuota=mdy('11','20','2010');
    --                  and capital_status='1';


                    Select (sum(mora_provi_ordi + mora_sdo_ordi - mora_sdo_ordi_pag) * vcapmasvencido)/ (sum(capital_debe - capital_pagado) + vcapmasvencido),
                           (sum(mora_provi_cope + mora_sdo_cope - mora_sdo_cope_pag) * vcapmasvencido)/ (sum(capital_debe - capital_pagado) + vcapmasvencido),
                           sum(interes_debe - interes_pagado), sum(iva_debe - iva_pagado)
                    Into  vintmoraordi, vintmoracope, vinterescapitalizar, vivacapitalizar
                    from bdicred:sd_amortiza_credito
                    where empresa=pEmpresa
                      and num_credito=vNumCred
                      and fecha_cuota=mdy('10','20','2010');
    --                  and capital_status='2';

                    Update bdicred:sd_amortiza_credito
                       set mora_provi_ordi = 0,
                           mora_provi_cope = 0,
                           interes_debe = interes_pagado,
                           iva_debe = iva_pagado,
                           interes_status = 1,
                           mora_sdo_ordi = mora_sdo_ordi_pag + mora_provi_ordi - vintmoraordi,
                           mora_sdo_cope = mora_sdo_cope_pag + mora_provi_cope - vintmoracope,
                           campo_trabajo4 = 'PROG.APOYO'
                    where empresa=pEmpresa
                      and num_credito=vNumCred
                      and fecha_cuota=mdy('10','20','2010');
    --                  and capital_status='2';

                    update bdicred:sd_maesdos
                       set sdo_cap_insoluto = sdo_cap_insoluto + vinterescapitalizar + vivacapitalizar,
                           cap_tras_no_venci = cap_tras_no_venci + vcapmasvencido + vinterescapitalizar + vivacapitalizar,
                           mto_venc_trasp = mto_venc_trasp - vcapmasvencido,
                           monto_financiado = monto_financiado - vcapmasvencido,
                           sdo_trab4 = sdo_trab4 - vcapmasvencido,
                           sdo_intereses = sdo_intereses + vintmoraordi,
                           sdo_dia_ant_int = sdo_dia_ant_int + vintmoraordi,
                           sdo_int_anticip = sdo_int_anticip + vintmoraordi,
                           sdo_acum_mes_int = sdo_acum_mes_int + vintmoraordi,
                           sdo_global_int = sdo_global_int + vintmoraordi,
                           sdo_acum_intper = sdo_acum_intper + vintmoraordi,
                           int_tra_no_exig = int_tra_no_exig + vintordcap - vinterescapitalizar,
                           sdo_moratorio= (sdo_moratorio+ sdo_contab_mora) - vintmoraordi - vintmoracope - vintordcap - vintcopcap,
                           sdo_contab_mora=0
                     where empresa=pEmpresa
                       and num_credito=vNumCred;

                SELECT
                sdo_moratorio, 
                nvl((SELECT sum(mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag) FROM bdicred:sd_amortiza_credito WHERE a.empresa = empresa AND a.num_credito = num_credito AND capital_status IN ('2','7')),0),
                sdo_contab_mora,
                nvl((SELECT sum(mora_provi_ordi + mora_provi_cope) FROM bdicred:sd_amortiza_credito WHERE a.empresa = empresa AND a.num_credito = num_credito AND capital_status IN ('2','7')),0)
                INTO vsdo_mora,vsum_mora,vsdo_contab_mora,vsum_contabmora
                FROM bdicred:sd_maecred a,
                     bdicred:sd_maesdos b
                WHERE a.empresa = b.empresa
                  AND a.num_credito = b.num_credito
                  AND a.num_credito = vNumCred
                  AND status_cred in ('BA','BT')
                  AND (sdo_moratorio <> nvl((SELECT sum(mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag) FROM bdicred:sd_amortiza_credito WHERE a.empresa = empresa AND a.num_credito = num_credito AND capital_status in ('2','7')),0)
                   OR  sdo_contab_mora <> nvl((SELECT sum(mora_provi_ordi + mora_provi_cope) FROM bdicred:sd_amortiza_credito WHERE a.empresa = empresa AND a.num_credito = num_credito AND capital_status IN ('2','7')),0));

                 IF   vsdo_mora <> vsum_mora or vsdo_contab_mora <> vsum_contabmora THEN
                      UPDATE bdicred:"informix".sd_maesdos SET sdo_contab_mora = vsum_mora, sdo_moratorio =  vsum_contabmora
                       WHERE empresa = pEmpresa
                         AND num_credito = vNumCred;
                 END if;

                    update bdicred:sd_maesdoshist
                       set sdo_cap_insoluto = sdo_cap_insoluto + vinterescapitalizar + vivacapitalizar,
                           cap_tras_no_venci = cap_tras_no_venci + vcapmasvencido + vinterescapitalizar + vivacapitalizar,
                           mto_venc_trasp = mto_venc_trasp - vcapmasvencido,
                           monto_financiado = monto_financiado - vcapmasvencido,
                           sdo_trab4 = sdo_trab4 - vcapmasvencido,
                           int_tra_no_exig = int_tra_no_exig + vintordcap - vinterescapitalizar,
                           sdo_moratorio= (sdo_moratorio+ sdo_contab_mora) - vintordcap - vintcopcap,
                           sdo_contab_mora=0,
                           mto_fin_ven_trasp = 2
                     where empresa=pEmpresa
                       and num_credito=vNumCred
                       and fecha = mdy('11','20','2010');

                        SELECT plaza
                          INTO vPlaza
                          FROM bdinteg:cr_sucursales2
                         WHERE empresa = pEmpresa
                           AND sucursal = vSucursal;

                          CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,10,
                                           "601", mdy('11','20','2010'), vcapmasvencido,
                                           Folio, vSucursal, '01', '', vPlaza)
                          RETURNING CodRet, Mensaje;

                          IF (CodRet <> "00000") THEN
                              ROLLBACK WORK;
                              LET vMensaje = "Problema al generar movimiento de traspaso a vigente (EXIG) : "|| vNumCred ;
                              return CodRet, Mensaje;
                          END IF;

                          CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,2,
                                           "605", mdy('11','20','2010'), vinterescapitalizar,
                                           Folio, vSucursal, '01', '', vPlaza)
                          RETURNING CodRet, Mensaje;

                          IF (CodRet <> "00000") THEN
                              ROLLBACK WORK;
                              LET vMensaje = "Problema al generar movimiento de capitalizacion de interes : "|| vNumCred ;
                              return CodRet, Mensaje;
                          END IF;

                          CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,3,
                                           "605", mdy('11','20','2010'), vivacapitalizar,
                                           Folio, vSucursal, '01', '', vPlaza)
                          RETURNING CodRet, Mensaje;

                          IF (CodRet <> "00000") THEN
                              ROLLBACK WORK;
                              LET vMensaje = "Problema al generar movimiento de capitalizacion de iva : "|| vNumCred ;
                              return CodRet, Mensaje;
                          END IF;


               end if;

          end if;

          update {+INDEX(sd_prog_apoyo inx_sd_prog_apoyo)} bdicred:sd_prog_apoyo
             set bandera = 3
           where num_credito=vNumCred;

       commit work;
    END FOREACH;

  DROP TABLE cr_sucursales2;

  LET CodRet='000';

  RETURN CodRet, "Proceso Exitoso";

END PROCEDURE;