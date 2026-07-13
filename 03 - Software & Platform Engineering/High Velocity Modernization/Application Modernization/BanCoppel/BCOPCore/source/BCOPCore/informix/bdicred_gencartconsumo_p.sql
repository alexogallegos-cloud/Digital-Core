CREATE PROCEDURE "informix".gencartconsumo_p(pEmpresa CHAR(3))
RETURNING
          CHAR(6)   AS resultado,
          CHAR(100) AS mensaje;

DEFINE iSqlErr                       INTEGER;
DEFINE iIsamErr                      INTEGER;
DEFINE cErrorInfo                    CHAR(80);
DEFINE cCodRet                       CHAR(6);
DEFINE cMensajeRet                   CHAR(80);

DEFINE cBegin                        CHAR(1);
DEFINE vcontador_insert              INTEGER;
DEFINE dtFechaHoy                    DATE;
DEFINE dtPriDiaMes                   DATE;
DEFINE vprox_fecha                   DATE;
DEFINE dtFechacierre                 DATE;
DEFINE vstatus_proc                  CHAR(1);
DEFINE vImporteReservaBuroCC         DECIMAL(18,5);
DEFINE vtotal_capitalizado           DECIMAL(18,5);
DEFINE vmonto_capitalizado           DECIMAL(18,5);
DEFINE vcodigo_ref                   INTEGER;
DEFINE iCuotasVdas                   INTEGER;
DEFINE vNvoPeriodo                   INTEGER;
DEFINE cPeriodicidad                 CHAR(1);
DEFINE vTotal                        DECIMAL(18,5);
DEFINE vInteres_venc                 DECIMAL(18,5);
DEFINE vProducto                     CHAR(4);
DEFINE vSucursal                     CHAR(4);
DEFINE vDivisa                       CHAR(2);
DEFINE vStatusCred                   CHAR(02);
DEFINE dConsPI                       DECIMAL(18,5);
DEFINE dConsPORPAGO                  DECIMAL(18,5);
DEFINE dConsPORUSO                   DECIMAL(18,5);
DEFINE dPorPagoMin                   DECIMAL(18,5);
DEFINE dPorcUsoMin                   DECIMAL(18,5);
DEFINE dpiEI                         DECIMAL(18,5);
DEFINE dpiEICal                      DECIMAL(18,5);
DEFINE dMeses                        INTEGER;
DEFINE dPIdefaul                     DECIMAL(18,5);
DEFINE dConsSPMenor                  DECIMAL(18,5);
DEFINE dConsComPI                    DECIMAL(18,5);
DEFINE cNumCredito                   CHAR(20);
DEFINE dPagos                        DECIMAL(18,5);
DEFINE dImpagosCons                  DECIMAL(18,5);
DEFINE dImpagosHist                  DECIMAL(18,5);
DEFINE dMesesAntiguedad              DECIMAL(18,5);
DEFINE dLinCredAut                   DECIMAL(18,5);
DEFINE dEndeudamientoTotCierre       DECIMAL(18,5);
DEFINE dEndeudamientoTotCorte        DECIMAL(18,5);
DEFINE dEndeudamientoTotCalc         DECIMAL(18,5);
DEFINE dLimiteCredito                DECIMAL(18,5);
DEFINE dLimiteCreditoNvo             DECIMAL(18,5);
DEFINE dPorUso                       DECIMAL(18,5);
DEFINE dPorUsoCal                    DECIMAL(18,5);
DEFINE dPorPago                      DECIMAL(18,5);
DEFINE dPagosnunca                   DECIMAL(18,5);
DEFINE dSaldoTarjeta                 DECIMAL(18,5);
DEFINE dMax                          DECIMAL(18,5);
DEFINE dEI                           DECIMAL(18,5);
DEFINE dEICal                        DECIMAL(18,5);
DEFINE dPI                           DECIMAL(18,5);
DEFINE dSP                           DECIMAL(18,5);
DEFINE dPorcentajeReserva            DECIMAL(18,5);
DEFINE cGradoRiesgo                  CHAR(2);
DEFINE cGradoRiesgoAux               CHAR(2);
DEFINE cGradoRiesgoGradual           CHAR(2);
DEFINE cGradoRiesgoEdoResultados     CHAR(2);
DEFINE cGradoRiesgoBancoppel         CHAR(2);
DEFINE dPorUsoMinCtesNunca           DECIMAL(18,5);
DEFINE dResInteresVen                DECIMAL(18,5);
DEFINE dResBuro                      DECIMAL(18,5);
DEFINE dResCalificacion              DECIMAL(18,5);
DEFINE iClienteNunca                 INTEGER;
DEFINE dLineaAutorizada              DECIMAL(18,5);
DEFINE dEvaBuro                      CHAR(01);
DEFINE iContInteres                  INTEGER;
DEFINE dtFechaApertura               DATE;
DEFINE iANT                          DECIMAL(18,5);
DEFINE dtFechaPeriodo                DATE;
DEFINE dPagoRealizado                DECIMAL(18,5);
DEFINE dConsMinPorUso                DECIMAL(18,5);
DEFINE dConsMaxPorUso                DECIMAL(18,5);
DEFINE dPorSaldoMin                  DECIMAL(18,5);
DEFINE dConsMaxPorPago               DECIMAL(18,5);
DEFINE dConsMinPorPago               DECIMAL(18,5);
DEFINE dConsACT                      DECIMAL(18,5);
DEFINE dConsHIST                     DECIMAL(18,5);
DEFINE dConsANT                      DECIMAL(18,5);
DEFINE iACT                          INTEGER;
DEFINE iHIST                         INTEGER;
DEFINE dDiaCorte                     CHAR(02);
DEFINE sExisten                      SMALLINT;
DEFINE dImporteReserva               DECIMAL(18,5);
DEFINE vReservaGradual               DECIMAL(18,5);
DEFINE vPorcentajeGradual            DECIMAL(18,5);
DEFINE vPorcentajeEdoResultados      DECIMAL(18,5);
DEFINE dReservaCalifMesAnterior      DECIMAL(18,5);
DEFINE dReservaEdoResultados         DECIMAL(18,5);
--DEFINE dGradual                      DECIMAL(18,5);
DEFINE dReservaBuroGradual           DECIMAL(18,5);
DEFINE dReservaIntCredVenGradual     DECIMAL(18,5);
define iPagosVencidos                integer;
DEFINE dImpPerConACT                 DECIMAL(18,5);
DEFINE dConsSPMayor                  DECIMAL(18,5);
DEFINE dEndeudTotCierreSinIntereses  DECIMAL(18,5);
--DEFINE dFactor                       DECIMAL(10,5);
define dgradoriesgobancoppel         char(02);
DEFINE v_iva_suc                     DECIMAL(18,2);
DEFINE dMoratorios                   DECIMAL(18,2);
DEFINE dInteVencIva                  DECIMAL(18,2);
DEFINE dPorcReserv                   DECIMAL(18,5);
DEFINE cTipoCred                     CHAR(1);
DEFINE dPorResSic                    DECIMAL(18,5);

DEFINE dtFechacorte                  date;

DEFINE vDia                      CHAR(02);
DEFINE vMes                      CHAR(02);
DEFINE vAnio                     CHAR(4);
DEFINE vsql                      char(200);


SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      ---COMMIT WORK;
      LET cCodRet= iSqlErr;
--      LET cMensajeRet= cErrorInfo;
      LET cMensajeRet= cNumCredito;

      IF cBegin= 'S' THEN
        ROLLBACK WORK;
      END IF;

      SELECT {+INDEX(bdinteg:sx_contproc idx_xcontproc1)} status_proc
        INTO vstatus_proc
        FROM bdinteg:sx_contproc
       WHERE empresa = pEmpresa    and
             proceso = "califcart" and
             sistema = "06"        and
             fecha   = dtFechaHoy;

      if vstatus_proc is null then

         INSERT INTO sd_contproc (empresa, proceso, fecha, status_proc,
	                          ejecutivo, hora_inicio, hora_fin, cod_ret, mensaje)
                          VALUES (pempresa, "califcart", dtFechaHoy, "C",
		                  USER, CURRENT, CURRENT, "", "PROCESO CANCELADO");

         INSERT INTO bdinteg:sx_contproc (empresa, proceso, fecha, sistema, status_proc,
	                          ejecutivo, hora_ini, hora_fin, codret)
                          VALUES (pempresa, "califcart", dtFechaHoy, "06", "C",
		                  USER, CURRENT, CURRENT, "");

      else

          UPDATE {+INDEX(sd_contproc idx_sd_contproc)} sd_contproc SET status_proc = "C", mensaje = "PROCESO CANCELADO"
           WHERE empresa = pempresa    and
                 proceso = "califcart" and
                 fecha   = dtFechaHoy;

          UPDATE {+INDEX(bdinteg:sx_contproc idx_xcontproc1)} bdinteg:sx_contproc SET status_proc = "C"
           WHERE empresa = pempresa    and
                 proceso = "califcart" and
		         sistema = "06"        and
                 fecha   = dtFechaHoy;

      end if

      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "gencartconsumo.out";
--TRACE ON;

LET cCodRet= '000';
LET cMensajeRet= 'El proceso de CALIFICACION DEL CIERRE se realizó correctamente';

LET cBegin= 'F';
LET vcontador_insert= 0;
LET dtFechaHoy= DATE(1);
LET dtPriDiaMes= DATE(1);
let dtFechacierre = null;
LET vprox_fecha= DATE(1);
LET vstatus_proc= '';
LET vImporteReservaBuroCC= 0;
LET vtotal_capitalizado = 0;
LET vmonto_capitalizado = 0;
LET vcodigo_ref= 0;
LET iCuotasVdas= 0;
LET vNvoPeriodo= 0;
LET cPeriodicidad= '';
LET vTotal= 0;
LET vInteres_venc= 0;
LET vProducto= '';
LET vSucursal= '';
LET vDivisa= '';
LET vStatusCred= '';
LET dConsPI= 0;
LET dConsPORPAGO= 0;
LET dConsPORUSO= 0;
LET dPorPagoMin= 0;
LET dPorcUsoMin= 0;
LET dpiEI= 0;
LET dpiEICal= 0;
LET dMeses= 0;
LET dPIdefaul= 0;
LET dConsSPMenor= 0;
LET dConsComPI= 0;
LET cNumCredito= '';
LET dPagos= 0;
LET dImpagosCons= 0;
LET dImpagosHist= 0;
LET dMesesAntiguedad= 0;
LET dLinCredAut= 0;
LET dEndeudamientoTotCierre= 0;
LET dEndeudamientoTotCorte= 0;
LET dEndeudamientoTotCalc= 0;
LET dLimiteCredito= 0;
LET dLimiteCreditoNvo= 0;
LET dPorUso= 0;
LET dPorUsoCal= 0;
LET dPorPago= 0;
LET dSaldoTarjeta= 0;
LET dMax= 0;
LET dEI= 0;
LET dPI= 0;
LET dSP= 0;
LET dPorcentajeReserva= 0;
LET cGradoRiesgo= '';
LET dPorUsoMinCtesNunca= 0;
LET dResInteresVen= 0;
LET dResBuro= 0;
LET dResCalificacion= 0;
LET iClienteNunca= 0;
LET dLineaAutorizada= 0;
LET dEvaBuro= '';
LET iContInteres= 0;
LET dtFechaApertura=DATE(1);
LET iANT= 0;
LET dtFechaPeriodo=DATE(1);
LET dPagoRealizado= 0;
LET dConsMinPorUso= 0;
LET dConsMaxPorUso= 0;
LET dPorSaldoMin= 0;
LET dConsMaxPorPago= 0;
LET dConsMinPorPago= 0;
LET dConsACT= 0;
LET dConsHIST= 0;
LET dConsANT= 0;
LET iACT= 0;
LET iHIST= 0;
LET dDiaCorte = '';
LET sExisten = 0;
LET dImporteReserva = 0;
LET vReservaGradual = 0;
LET vPorcentajeGradual = 0;
LET dReservaCalifMesAnterior = 0;
LET dReservaEdoResultados = 0;
--LET dGradual = 0;
LET dReservaBuroGradual = 0;
LET dReservaIntCredVenGradual  = 0;
LET cGradoRiesgo               = '';
LET cGradoRiesgoAux            = '';
LET cGradoRiesgoGradual        = '';
LET cGradoRiesgoEdoResultados  = '';
LET cGradoRiesgoBancoppel      = '';
LET dImpPerConACT = 0;
LET dConsSPMayor = 0;
LET dEndeudTotCierreSinIntereses = 0;
--LET dFactor = 0;
let dgradoriesgobancoppel = '';
LET dMoratorios  = 0;
LET dInteVencIva = 0;
LET dPorcReserv  = 0;
LET cTipoCred = ''; 
LET dPagosnunca = 0;
LET dPorResSic = 0;

let dtFechacorte = date(1);

LET vDia = '';
LET vMes = '';
LET vAnio = '';
LET vsql = '';

-- Se obtiene la fecha hoy del sistema.
SELECT {+INDEX(sd_fechas idx_sdfechas)} a.fecha_hoy, prox_fecha, pri_dia_mes
   INTO dtFechaHoy, vprox_fecha, dtPriDiaMes 
   FROM bdicred:sd_fechas a
  WHERE a.empresa = pempresa;

--rss
	let dtFechaHoy  = mdy('02','28','2013');
	let vprox_fecha = mdy('03','01','2013');
	let dtPriDiaMes = mdy('02','01','2013');

--Se calcula el factor de comparación para los créditos que se dieron de alta entre el 21 y último día del mes
--LET dFactor  = (day(dtFechaHoy) - 20) / day(dtFechaHoy); ---NO SE OCUPA ESTA VARIABLE

   SELECT {+INDEX(bdinteg:sx_contproc idx_xcontproc1)} status_proc
     INTO vstatus_proc
     FROM bdinteg:sx_contproc
    WHERE empresa     = pempresa     and
          proceso     = "CierreCred" and
          status_proc = "F"          and
          sistema     = "06"         and
          fecha       = dtFechaHoy;

   if ( vstatus_proc is null ) then
      let ccodret = "582";
      LET cMensajeRet= 'No se ha ejecutado el previo de cierre';
      RETURN cCodRet, cMensajeRet;
   end if;

   SELECT {+INDEX(bdinteg:sx_contproc idx_xcontproc1)} status_proc
     INTO vstatus_proc
     FROM bdinteg:sx_contproc
    WHERE empresa = pempresa    and
          proceso = "califcart" and
	      sistema = "06"        and
          fecha   = dtFechaHoy;

   if ( vstatus_proc is null ) then

      INSERT INTO sd_contproc  (empresa, proceso, fecha, status_proc,
				ejecutivo, hora_inicio, hora_fin, cod_ret, mensaje)
		       VALUES  (pempresa, "califcart", dtFechaHoy, "I",
		                USER, CURRENT, CURRENT, "", "EN PROCESO");

      INSERT INTO bdinteg:sx_contproc  (empresa, proceso, fecha, sistema, status_proc,
				ejecutivo, hora_ini, hora_fin, codret)
		       VALUES  (pempresa, "califcart", dtFechaHoy, "06", "I",
		                USER, CURRENT, CURRENT, "");

   end if;

   if vstatus_proc = "F" then
       UPDATE {+INDEX(sd_contproc idx_sd_contproc)} sd_contproc SET mensaje = "PROCESO YA EJECUTADO"
        WHERE empresa = pempresa    and
              proceso = "califcart" and
              fecha   = dtFechaHoy;

          LET cMensajeRet= 'El proceso ya fue ejecutado';
          RETURN cCodRet, cMensajeRet;
   else
      if vstatus_proc = "C" then
           UPDATE {+INDEX(sd_contproc idx_sd_contproc)} sd_contproc SET status_proc = "I", mensaje = "EN PROCESO"
            WHERE empresa = pempresa    and
                  proceso = "califcart" and
                  fecha   = dtFechaHoy;

           UPDATE {+INDEX(bdinteg:sx_contproc idx_xcontproc1)} bdinteg:sx_contproc SET status_proc = "I"
            WHERE empresa = pempresa    and
                  proceso = "califcart" and
              sistema = "06"        and
                  fecha   = dtFechaHoy;
      end if;
   end if;

--
-- Carga de parametros
--

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsPI FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '3';

 IF dConsPI IS NULL THEN
   LET cCodRet= '003';
   LET cMensajeRet= 'FALTA CONSTANTE PARA PROBABILIDAD DE INCUMPLIMIENTO PI';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsACT FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '4';

 IF dConsACT IS NULL THEN
    LET cCodRet= '040';
    LET cMensajeRet= 'FALTA CONSTANTE IMPAGO ACTUAL PI';
    RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsHIST FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '5';

 IF dConsHIST IS NULL THEN
    LET cCodRet= '050';
    LET cMensajeRet= 'FALTA CONSTANTE IMPAGO HISTORICO PI';
    RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsANT FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '6';

 IF dConsANT IS NULL THEN
    LET cCodRet= '060';
    LET cMensajeRet= 'FALTA CONSTANTE ANTIGÜEDAD PI';
    RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsPORPAGO FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '7';

 IF dConsPORPAGO IS NULL THEN
   LET cCodRet= '007';
   LET cMensajeRet= 'FALTA CONSTANTE PARA EL CALCULO DE PORCENTAJE PAGO PI';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsPORUSO FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '8';

 IF dConsPORUSO IS NULL THEN
    LET cCodRet= '008';
    LET cMensajeRet= 'FALTA CONSTANTE PARA EL CALCULO DE PORCENTAJE USO PI';
    RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dPorPagoMin FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '9';

 IF dPorPagoMin IS NULL THEN
   LET cCodRet= '009';
   LET cMensajeRet= 'FALTA PORCENTAJE PAGO MÍNIMO';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dPorcUsoMin FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '10';

 IF dPorcUsoMin IS NULL THEN
   LET cCodRet= '010';
   LET cMensajeRet= 'FALTA PORCENTAJE USO MÍNIMO';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dpiEI FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '11';

 IF dpiEI IS NULL THEN
   LET cCodRet= '011';
   LET cMensajeRet= 'FALTA EXPOSICIÓN AL MOMENTO DE INCUMPLIMIENTO';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dMeses FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '12';

 IF dMeses IS NULL THEN
   LET cCodRet= '012';
   LET cMensajeRet= 'FALTA NÚMERO DE MESES';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dPIdefaul FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '13';

 IF dPIdefaul IS NULL THEN
   LET cCodRet= '013';
   LET cMensajeRet= 'FALTA CONSTANTE PARA PROBABILIDAD DE INCUMPLIMIENTO >=4';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsSPMenor FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '14';

 IF dConsSPMenor IS NULL THEN
   LET cCodRet= '014';
   LET cMensajeRet= 'FALTA CONSTANTE SEVERIDAD DE LA PERDIDA CUANDO ACT<12 ';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsSPMayor FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '15';

 IF dConsSPMayor IS NULL THEN
   LET cCodRet= '015';
   LET cMensajeRet= 'FALTA CONSTANTE SEVERIDAD DE LA PERDIDA CUANDO ACT>=12';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsComPI FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '16';

 IF dConsComPI IS NULL THEN
   LET cCodRet= '016';
   LET cMensajeRet= 'FALTA CONSTANTE COMPARACIÓN PARA PI';
   RETURN cCodRet, cMensajeRet;
 END IF;

  SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dPorSaldoMin FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '17';

  IF dPorSaldoMin IS NULL THEN
     LET cCodRet= '170';
     LET cMensajeRet= 'FALTA PARAMETRO PORCENTAJE DE SALDO MINIMO';
     RETURN cCodRet, cMensajeRet;
  END IF;

  SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dImpPerConACT FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa and cod_param= '18';
    
  IF dImpPerConACT IS NULL THEN
     LET cCodRet= '180';
     LET cMensajeRet= 'FALTA PARAMETRO IMPAGOS EN PERIODOS CONSECUTIVOS ACT';
     RETURN cCodRet, cMensajeRet;
  END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dPorUsoMinCtesNunca FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '19';

 IF dPorUsoMinCtesNunca IS NULL THEN
   LET cCodRet= '019';
   LET cMensajeRet= 'FALTA PORCENTAJE USO MINIMO CLIENTES NUNCA';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsMinPorPago FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '21';

 IF dConsMinPorPago IS NULL THEN
    LET cCodRet= '210';
    LET cMensajeRet= 'FALTA VALOR MINIMO COMPARATIVO % DE PAGO';
    RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsMaxPorPago FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '22';

  IF dConsMaxPorPago IS NULL THEN
     LET cCodRet= '220';
     LET cMensajeRet= 'FALTA MAXIMO COMPARATIVO % DE PAGO';
     RETURN cCodRet, cMensajeRet;
  END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsMinPorUso FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '23';

 IF dConsMinPorUso IS NULL THEN
    LET cCodRet= '230';
    LET cMensajeRet= 'FALTA MINIMO COMPARATIVO % DE USO';
    RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsMaxPorUso FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '24';

 IF dConsMaxPorUso IS NULL THEN
    LET cCodRet= '240';
    LET cMensajeRet= 'FALTA MAXIMO COMPARATIVO % DE USO';
    RETURN cCodRet, cMensajeRet;
 END IF;

    SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dPorResSic FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '25';
    
    IF dPorResSic IS NULL THEN
       LET cCodRet= '250';
       LET cMensajeRet= 'FALTA PORCENTAJE DE RESERVA DE SIC';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO cGradoRiesgoAux FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '26';
    
    IF cGradoRiesgoAux IS NULL THEN
       LET cCodRet= '260';
       LET cMensajeRet= 'GRADO RIESGO CLIENTES NUNCA';
       RETURN cCodRet, cMensajeRet;
    END IF;

     EXECUTE PROCEDURE bdicred:monthadd(MDY(month(dtFechaHoy),'20',year(dtFechaHoy)), -1) INTO dtFechaPeriodo;
/*
    SELECT {+INDEX(sd_gradualidad idx_sd_gradualidad)} gradual
      INTO dGradual
      FROM bdicred:sd_gradualidad
     WHERE empresa=pEmpresa
       AND mes_ano=lpad(month(dtFechaHoy),2,0)||year(dtFechaHoy);

    IF dGradual IS NULL OR dGradual = '' THEN LET dGradual = 1; END IF;
*/


    SELECT a.num_credito
      FROM bdicred:sd_maecredcont a
      LEFT OUTER JOIN bdicred:sd_hist_reserva b on a.empresa = b.empresa AND a.num_credito = b.num_credito AND b.fecha_corte = mdy(month(a.fecha),20,year(a.fecha)) 
     WHERE a.empresa = pEmpresa
       AND a.fecha = dtFechaHoy
       AND b.fecha_cierre IS NULL
      into temp paso1 with no log;
    create unique index inx_paso1 on paso1(num_credito);
    update statistics medium for table paso1;

    delete from  paso1 where num_credito in (select num_credito from bdicred:sd_hist_reserva where empresa = pEmpresa and fecha_corte = dtFechaHoy);


FOREACH WITH HOLD

    -- Se obtienen los créditos calificados con corte al 20.
    SELECT a.num_credito, CASE WHEN b.num_periodos IS NULL THEN 0 ELSE b.num_periodos END, CASE WHEN b.pagos_realizados IS NULL THEN 0 ELSE b.pagos_realizados END,
           CASE WHEN b.impagos_consecutivos IS NULL THEN 0 ELSE b.impagos_consecutivos END, CASE WHEN b.impagos_historicos IS NULL THEN 0 ELSE b.impagos_historicos END,
           b.meses_antiguedad,a.fecha_apertura,
           a.periodo_plazo, a.num_producto, a.sucursal, a.divisa, a.status_cred,
           (b.probabilidad_incumplimiento/100),(b.severidad_perdida/100), b.limite_credito, b.antecedente_buro,
           NVL(c.sdo_cap_insoluto,0), NVL(b.saldo_corte,0),
           d.dia_corte,nvl(reserva_calif_mes_anterior,0),
           (porcentaje_uso/100), (porcentaje_pago/100), b.fecha_cierre,
           grado_riesgo_bancoppel,nvl(c.mto_venc_tra_int,0),nvl(c.monto_otorgado,0), b.fecha_corte
      INTO cNumCredito, iCuotasVdas, dPagos, dImpagosCons, dImpagosHist, dMesesAntiguedad,
           dtFechaApertura,cPeriodicidad, vProducto, vSucursal, vDivisa, vStatusCred,
           dPI, dSP,dLimiteCredito,dEvaBuro,
           dEndeudamientoTotCierre,dEndeudamientoTotCorte,
           dDiaCorte,dReservaCalifMesAnterior,
           dPorUso, dPorPago, dtFechacierre,
           dgradoriesgobancoppel,vtotal_capitalizado,dLimiteCreditoNvo,dtFechacorte
      FROM bdicred:sd_maecredcont a
           join paso1 aa on (a.num_credito = aa.num_credito)
           LEFT OUTER JOIN bdicred:sd_hist_reserva b on a.empresa = b.empresa AND a.num_credito = b.num_credito AND b.fecha_corte = mdy(month(a.fecha),20,year(a.fecha)) 
           JOIN bdicred:sd_maesdoscont c on a.empresa = c.empresa  AND a.num_credito = c.num_credito and c.fecha = a.fecha
           JOIN bdicred:sd_maecredanexo d on a.empresa = d.empresa AND a.num_credito = d.num_credito
     WHERE a.empresa = pEmpresa
       AND a.fecha = dtFechaHoy
--       AND a.num_credito > ''
       AND b.fecha_cierre IS NULL
--       AND a.num_producto <> '6600'
--       AND a.status_cred      IN ("AA","BA","BT")

       IF dgradoriesgobancoppel = 'PS' or vProducto = '6600' or dtFechacorte = dtFechaHoy THEN 
           CONTINUE FOREACH;
       END IF;

      IF dLimiteCredito IS NULL THEN LET dLimiteCredito = dLimiteCreditoNvo; END IF;
      IF dLimiteCredito <= 0 THEN  LET dLimiteCredito = 0.01; END IF;
/*
      IF dLimiteCredito IS NULL OR dLimiteCredito <= 0 THEN  ---??????
          LET dLimiteCredito = 0.01;
      END IF;
*/

--     IF vcontador_insert = 0 THEN
--       LET cBegin= 'S';
       BEGIN WORK;
--     END IF;

     IF dgradoriesgobancoppel='IN' or dgradoriesgobancoppel='A' THEN
        UPDATE {+INDEX(sd_hist_reserva fecha_corte)} "informix".sd_hist_reserva
           SET fecha_cierre = dtFechaHoy,
               saldo_cierre = dEndeudamientoTotCierre,
               exposicion_incumplimiento = (CASE WHEN dEndeudamientoTotCierre < 0 THEN 0 ELSE dEndeudamientoTotCierre END)
         WHERE empresa = pEmpresa
           AND fecha_corte = mdy(month(dtFechaHoy),dDiaCorte,year(dtFechaHoy))
           AND num_credito = cNumCredito;
--rss
       IF dgradoriesgobancoppel= 'A' THEN
          LET vNvoPeriodo= 0;
          LET cGradoRiesgoAux = 'A';
       ELIF dgradoriesgobancoppel= 'IN' THEN
          LET vNvoPeriodo= 1;
       END IF;
--rss
-- Actualiza Maestro de Credito Central
         UPDATE {+INDEX(sd_maecred idx_idx_maecredb)} bdicred:sd_maecred
            SET calificacion_riesgo = cGradoRiesgoAux -- B1
          WHERE empresa = pempresa
            AND num_credito = cNumCredito;
--rss se trae este registro contable del primer proceso de calificación

        IF dEndeudamientoTotCierre > 0 THEN
            EXECUTE PROCEDURE genmov_calif (pEmpresa,
                                          cNumCredito,
                                          vProducto,
--rss                                          1,
                                          vNvoPeriodo,
                                          "071", --666
                                          dtFechaHoy,
                                          dEndeudamientoTotCierre,
                                          "CalifCart",
                                          vSucursal,
                                          vDivisa,
                                          "0000")
            INTO cCodRet, cMensajeRet;
            IF TRIM(cCodRet) <> "00000" THEN
               RETURN cCodRet, cMensajeRet;
            END IF;
        END IF;

--rss se trae este registro contable del primer proceso de calificación
        LET sExisten = 0;             LET iContInteres = 0;            LET vtotal_capitalizado = 0;        LET vImporteReservaBuroCC = 0;        
        LET vmonto_capitalizado = 0;  LET cNumCredito ='';             LET iCuotasVdas =0;                 LET dPagos =0;                      
        LET dImpagosCons =0;          LET dImpagosHist =0;             LET dMesesAntiguedad =0;            LET dtFechaApertura =date(0);         
        LET cPeriodicidad ='';        LET vProducto ='';               LET vSucursal ='';                  LET vDivisa ='';        
        LET vStatusCred ='';          LET dPI =0;                      LET dSP =0;                         LET dLimiteCredito =0;
        LET dEvaBuro ='';             LET dEndeudamientoTotCierre =0;  LET dEndeudamientoTotCorte =0;      LET dDiaCorte =0;
        LET dPorUso =0;               LET dReservaCalifMesAnterior =0; LET dEndeudTotCierreSinIntereses =0; LET cGradoRiesgoAux = 'B1';

--        LET vcontador_insert = vcontador_insert + 1;
        COMMIT WORK;
        CONTINUE FOREACH;
     END IF;

     IF dMesesAntiguedad IS NULL THEN
        LET dPagosnunca = 0;
        LET iANT = round((dtFechaHoy - dtFechaApertura)/30,2);
    -- Se obtiene el antecedente de Buró
        SELECT evalua_cc
          INTO dEvaBuro
          FROM bdisolic:ss_resum_scor_fin
         WHERE empresa = pempresa
           AND num_solicitud = cNumCredito;
    -- Se obtiene la línea autorizada
        SELECT {+INDEX(bdisolic:ss_solicitudes empsol)} nvl(monto_solicitado,0)
          INTO dLineaAutorizada
          FROM bdisolic:ss_solicitudes
         WHERE empresa = pempresa
           AND num_solicitud = cNumCredito;
/*
    -- Se obtiene el límite de crédito
        SELECT nvl(monto_otorgado,0)
          INTO dLimiteCredito
          FROM bdicred:sd_maesdoscont
--          FROM bdicred:sd_maesdos
         WHERE fecha = dtFechaHoy
           AND empresa = pempresa
           AND num_credito = cNumCredito;
*/

        LET dPorUso  = 0; ---- para clientes nuevos no se calcula la variable
        LET dPorPago = 0; ---- para clientes nuevos no se calcula la variable
        LET dSP = dConsSPMenor; ---- para clientes nuevos no existen impagos consecutivos
        LET dPI = 0; ---- para clientes nuevos no se calcula la variable
     END IF;

     IF dtFechaApertura > mdy(month(dtFechaHoy),dDiaCorte,year(dtFechaHoy)) and dMesesAntiguedad is null then 
        LET dPagosnunca = dPagos; 
     ELSE 
        LET dPagosnunca = -1;
     END IF;

--Se obtienen los intereses vencidos para restarlos del saldo al cierre
/*
     IF vStatusCred = 'BT' THEN
        select {+INDEX(sd_movhis inx_movhis)} sum(monto)
          into vtotal_capitalizado
          FROM bdicred:sd_movhis mov
         WHERE mov.empresa = pEmpresa
           AND mov.fecha_mov >= (select {+INDEX(sd_amortiza_credito amorst)} max(fecha_cuota) 
                                   from bdicred:sd_amortiza_credito
                                  where mov.empresa = empresa
                                    and mov.num_credito = num_credito
                                    and capital_status in ('5','2')
                                    and interes_debe = 0 and capital_debe > 0)
           AND mov.num_credito = cNumCredito
           AND mov.codigo_fun = '605'
           and mov.codigo_ref = 2
           AND mov.reversado = 'N';

           IF vtotal_capitalizado IS NULL THEN LET vtotal_capitalizado = 0; END IF;
     END IF;
*/
    IF vStatusCred != 'BT' THEN LET vtotal_capitalizado = 0; END IF;

    IF vtotal_capitalizado IS NULL THEN LET vtotal_capitalizado = 0; END IF;
--Se restan los intereses vencidos del saldo al cierre
    LET dEndeudTotCierreSinIntereses = dEndeudamientoTotCierre - vtotal_capitalizado;

--Se calcula EI
-- Si la resta del saldo y los intereses vencidos es menor o igual a cero, el saldo es igual al endeudamiento del cliente 
    IF dEndeudTotCierreSinIntereses <= 0 and vStatusCred = 'BT' THEN
       LET dEndeudTotCierreSinIntereses = dEndeudamientoTotCierre;
       LET vtotal_capitalizado = 0;
-- jom    ELIF dEndeudTotCierreSinIntereses <= 0 THEN
-- jom       LET dEndeudTotCierreSinIntereses = 0;
    END IF;

/*
    IF  dEndeudTotCierreSinIntereses > dLimiteCredito THEN
        LET dEI = dEndeudTotCierreSinIntereses;
    ELIF dEndeudTotCierreSinIntereses = 0 THEN
        LET dEI = 0;
    ELSE
        LET dMax = POW(dEndeudTotCierreSinIntereses/dLimiteCredito, dpiEI);
-- Si MAX es menor a 1 se toma el saldo al 100%, de lo contrario, se multiplica el saldo por MAX
        IF dMax <= 1 THEN
           LET dEI = dEndeudTotCierreSinIntereses;
        ELSE
           LET dEI = dEndeudTotCierreSinIntereses * dMax;
        END IF;
    END IF;
*/
    IF dEndeudTotCierreSinIntereses <= 0 THEN
        LET dEI = 0;
    ELSE
        LET dEI = dEndeudTotCierreSinIntereses;
    END IF;

--Se calcula la reserva de riesgos crediticios
    IF (dEndeudTotCierreSinIntereses <= 0 AND dPagos = 0 and dEndeudamientoTotCorte <= 0) OR (dtFechaApertura > mdy(month(dtFechaHoy),dDiaCorte,year(dtFechaHoy)))THEN 
       LET dPorcentajeReserva = dPorUsoMinCtesNunca; -- 2.68%
       LET dResCalificacion = dPorcentajeReserva * (dLimiteCredito + dEndeudamientoTotCorte); ----Se omite el monto ya que el monto al inicio del periodo es cero???
       LET cGradoRiesgo = cGradoRiesgoAux; --B1
    ELSE
        LET dPorcentajeReserva = dPI * dSP;
        LET dResCalificacion = dPorcentajeReserva * dEI;
            SELECT {+index (sd_grado_riesgo sd_grado_riesgo_inx1)} a.grado_riesgo
              INTO cGradoRiesgo
              FROM bdicred:sd_grado_riesgo a
             WHERE empresa = pEmpresa
               AND tipo = '0'
               AND (round(dPorcentajeReserva * 100,2) >= a.porcentaje_min
               AND round(dPorcentajeReserva * 100,2) <= a.porcentaje_max);
    END IF;

--Determina RESERVA CALIFICACION GRADUAL
--    LET vReservaGradual=dResCalificacion*dGradual;
	LET vReservaGradual=dResCalificacion;
    LET cGradoRiesgoGradual = cGradoRiesgo;
    LET dReservaEdoResultados = vReservaGradual;

--Determina PORCENTAJE RESERVA estado de resultados
   IF (dEI > 0) THEN
      LET vPorcentajeEdoResultados=dReservaEdoResultados/dEI;
   ELSE
      LET vPorcentajeEdoResultados=0.0;
   END IF;

    LET cGradoRiesgoEdoResultados = cGradoRiesgo;

--Determina GRADO RIESGO Bancoppel
   IF cGradoRiesgoEdoResultados= 'A' THEN
      LET vNvoPeriodo= 0;
   ELIF cGradoRiesgoEdoResultados= 'B1' THEN
      LET vNvoPeriodo= 1;
   ELIF cGradoRiesgoEdoResultados= 'B2' THEN
      LET vNvoPeriodo= 2;
   ELIF cGradoRiesgoEdoResultados= 'C' THEN
      LET vNvoPeriodo= 3;
   ELIF cGradoRiesgoEdoResultados= 'D' THEN
      LET vNvoPeriodo= 4;
   ELIF cGradoRiesgoEdoResultados= 'E' THEN
      LET vNvoPeriodo= 5;
   END IF;

-- Actualiza Maestro de Credito Central
   UPDATE {+INDEX(sd_maecred idx_idx_maecredb)} bdicred:sd_maecred
      SET calificacion_riesgo = cGradoRiesgo
    WHERE empresa = pempresa
      AND num_credito = cNumCredito;

   IF dMesesAntiguedad IS NOT NULL THEN
-- Se almacena la información correspondiente al calculo de la reservas preventivas.
      UPDATE {+INDEX(sd_hist_reserva fecha_corte)} "informix".sd_hist_reserva
         SET
             fecha_cierre              = dtFechaHoy,
             grado_riesgo              = cGradoRiesgo,
             saldo_cierre              = dEndeudamientoTotCierre,
             reserva_int_cred_ven      = vtotal_capitalizado,
             interes_cred_ven          = vtotal_capitalizado,
             reserva_buro              = vImporteReservaBuroCC,
             reserva_calificacion      = dResCalificacion,
             porcentaje_reserva        = dPorcentajeReserva * 100,
             exposicion_incumplimiento = dEI,
             grado_riesgo_gradual      = cGradoRiesgoGradual,
             exposicion_inc_gradual    = dEI,
             reserva_calificacion_gradual = vReservaGradual,
             porcentaje_reserva_gradual   = vPorcentajeGradual*100,
             reserva_buro_gradual         = dReservaBuroGradual,
             reserva_int_cred_ven_gradual = dReservaIntCredVenGradual,
             grado_riesgo_bancoppel       = cGradoRiesgoBancoppel,
             grado_riesgo_edo_resultados  = cGradoRiesgoEdoResultados,
             reserva_edo_resultados       = dReservaEdoResultados,
             porcentaje_reserva_edo_resultados = vPorcentajeEdoResultados*100
       WHERE empresa = pEmpresa
         AND fecha_corte = mdy(month(dtFechaHoy),dDiaCorte,year(dtFechaHoy))
         AND num_credito = cNumCredito;
   ELSE
         -- Se almacena la información correspondiente al calculo de la reservas preventivas para créditos aperturados después del 20.
      INSERT INTO informix.sd_hist_reserva (empresa,
                                            fecha_corte,
		 							        num_credito,
                                            fecha_cierre,
                                            grado_riesgo,
                                            fecha_apertura,
                                            antecedente_buro,
                                            status_cred,
                                            linea_autorizada,
                                            limite_credito,
                                            interes_cred_ven,
                                            saldo_corte,
                                            saldo_cierre,
                                            pago_minimo,
                                            pagos_realizados,
                                            reserva_int_cred_ven,
                                            reserva_buro,
                                            reserva_calificacion,
                                            porcentaje_reserva,
                                            meses_antiguedad,
                                            probabilidad_incumplimiento,
                                            severidad_perdida,
                                            exposicion_incumplimiento,
                                            impagos_consecutivos,
                                            impagos_historicos,
                                            porcentaje_pago,
                                            porcentaje_uso,
                                            num_periodos,
                                            exposicion_inc_gradual,
                                            grado_riesgo_gradual,
                                            reserva_calificacion_gradual,
                                            porcentaje_reserva_gradual,
                                            reserva_buro_gradual,  --falta registrarlo
                                            reserva_int_cred_ven_gradual,  --falta registrarlo
                                            reserva_calif_mes_anterior,
                                            grado_riesgo_bancoppel,
                                            grado_riesgo_edo_resultados,
                                            reserva_edo_resultados,
                                            porcentaje_reserva_edo_resultados)
           VALUES (pEmpresa,
                   dtFechaHoy,
                   cNumCredito,
                   dtFechaHoy,
                   cGradoRiesgo,
                   dtFechaApertura,
                   dEvaBuro,
                   vStatusCred,
                   dLineaAutorizada,
                   dLimiteCredito,
                   vtotal_capitalizado,
                   0,
                   dEndeudamientoTotCierre,
                   0,
                   dPagoRealizado,
                   vtotal_capitalizado,
                   vImporteReservaBuroCC,
                   dResCalificacion,
                   dPorcentajeReserva * 100,
                   iANT,
                   dPI * 100,
                   dSP * 100,
                   dEI,
                   iACT,
                   iHIST,
                   dPorPago * 100,
                   dPorUso * 100,
                   0,
                   dEI,
                   cGradoRiesgoGradual,
                   vReservaGradual,
                   vPorcentajeGradual*100,
                   dReservaBuroGradual,
                   dReservaIntCredVenGradual,
                   0,
                   cGradoRiesgoBancoppel,
                   cGradoRiesgoEdoResultados,
                   dReservaEdoResultados,
                   vPorcentajeEdoResultados*100);
   END IF;
    IF dReservaEdoResultados>0 THEN
        -- Genera Movimiento para Contabilidad
            EXECUTE PROCEDURE genmov_calif (pEmpresa,
                                           cNumCredito,
                                           vProducto,
                                           vNvoPeriodo,
                                           "070", --665
                                           dtFechaHoy,
                                           dReservaEdoResultados,
                                           "CalifCartReserva",
                                           vSucursal,
                                           vDivisa,
                                           "0000")
            INTO cCodRet, cMensajeRet;
            IF TRIM(cCodRet) <> "00000" THEN
               RETURN cCodRet, cMensajeRet;
            END IF;
    END IF;
    IF dEndeudamientoTotCierre>0 THEN
        EXECUTE PROCEDURE genmov_calif (pEmpresa,
                                      cNumCredito,
                                      vProducto,
                                      vNvoPeriodo,
                                      "071", --666
                                      dtFechaHoy,
                                      dEndeudamientoTotCierre,
                                      "CalifCart",
                                      vSucursal,
                                      vDivisa,
                                      "0000")
        INTO cCodRet, cMensajeRet;
        IF TRIM(cCodRet) <> "00000" THEN
           RETURN cCodRet, cMensajeRet;
        END IF;
    END IF;

-- Reservas por Riesgos Operativos (Clientes con mal Antecedentes en Buró o Círculo)
      IF dEvaBuro = '1' THEN
        LET vImporteReservaBuroCC = dResCalificacion * dPorResSic;
--        LET vImporteReservaBuroCC = vImporteReservaBuroCC * dGradual;
        LET vImporteReservaBuroCC = vImporteReservaBuroCC;
        LET dReservaBuroGradual   = vImporteReservaBuroCC;

    IF dMesesAntiguedad IS NOT NULL THEN
       -- Se almacena la información correspondiente a la reserva de Buró
        UPDATE {+INDEX(sd_hist_reserva fecha_corte)} sd_hist_reserva
           SET reserva_buro              = vImporteReservaBuroCC,
               reserva_buro_gradual      = dReservaBuroGradual
         WHERE empresa = pEmpresa
           AND fecha_corte = mdy(month(dtFechaHoy),dDiaCorte,year(dtFechaHoy))
           AND num_credito = cNumCredito;

        --Califica malos antecedentes
          EXECUTE PROCEDURE genmov_calif (pEmpresa,
                                           cNumCredito,
                                           vProducto,
                                           51,
                                           "661",
                                           dtFechaHoy,
                                           dReservaBuroGradual,
                                           "CalifCart",
                                           vSucursal,
                                           vDivisa,
                                           "0000")
         INTO cCodRet, cMensajeRet;
         IF TRIM(cCodRet) <> "00000" THEN
           RETURN cCodRet, cMensajeRet;
         END IF;
    END IF;

    END IF;

-- Reservas por Intereses devengados sobre créditos vencidos.
     LET vmonto_capitalizado = 0;
     LET iContInteres = 0;
     LET vImporteReservaBuroCC = 0;
     LET dReservaBuroGradual = 0;

     IF vStatusCred = 'BT' THEN
               IF (vtotal_capitalizado > 0 and dEndeudamientoTotCierre > 0)  THEN

                    EXECUTE PROCEDURE genmov_calif(pEmpresa,
                                                  cNumCredito,
                                                  vProducto,
                                                  50,
                                                  "661",
                                                  dtFechaHoy,
                                                  vtotal_capitalizado,
                                                  "CalifCart",
                                                  vSucursal,
                                                  vDivisa,
                                                  "0000")
                   INTO cCodRet, cMensajeRet;
                   IF TRIM(cCodRet) <> "00000" THEN
                     RETURN cCodRet, cMensajeRet;
                   END IF;

                 UPDATE {+INDEX(sd_hist_reserva fecha_corte)} sd_hist_reserva
                    SET interes_cred_ven          = vtotal_capitalizado,
                        reserva_int_cred_ven      = vtotal_capitalizado ,--vmonto_capitalizado,
                        reserva_int_cred_ven_gradual = vtotal_capitalizado
                  WHERE empresa = pEmpresa
                    AND fecha_corte = mdy(month(dtFechaHoy),dDiaCorte,year(dtFechaHoy))
                    AND num_credito = cNumCredito;
              END IF;
     END IF;

    LET sExisten = 0;
    LET iContInteres = 0;
    LET vtotal_capitalizado = 0;
    LET vImporteReservaBuroCC = 0;
    let vmonto_capitalizado = 0;
    LET cNumCredito ='';
    LET iCuotasVdas =0;
    LET dPagos =0;
    LET dImpagosCons =0;
    LET dImpagosHist =0;
    LET dMesesAntiguedad =0;
    LET dtFechaApertura =date(0);
    LET cPeriodicidad ='';
    LET vProducto ='';
    LET vSucursal ='';
    LET vDivisa ='';
    LET vStatusCred ='';
    LET dPI =0;
    LET dSP =0;
    LET dLimiteCredito =0;
    LET dEvaBuro ='';
    LET dEndeudamientoTotCierre =0;
    LET dEndeudamientoTotCorte =0;
    LET dDiaCorte =0;
    LET dReservaCalifMesAnterior =0;
    LET dPorUso =0;
    LET dEndeudTotCierreSinIntereses =0;

--    LET vcontador_insert = vcontador_insert + 1;

--    IF (vcontador_insert >= 2000) THEN
        COMMIT WORK;
--        LET vcontador_insert = 0;
--        UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_hist_reserva;
--		  UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_movhis_calif;
--    END IF;

END FOREACH;

--IF (vcontador_insert > 0) THEN
--  COMMIT WORK;
--END IF;

LET cCodRet = "000";

-- Actualiza el Control de Procesos
UPDATE {+INDEX(sd_contproc idx_sd_contproc)} sd_contproc
   SET status_proc = "F", mensaje = "PROCESO CONCLUIDO", hora_fin = CURRENT, cod_ret = ccodret
WHERE empresa = pempresa    and
      proceso = "califcart" and
      fecha   = dtFechaHoy;

UPDATE {+INDEX(bdinteg:sx_contproc idx_xcontproc1)} bdinteg:sx_contproc
  SET status_proc = "F", hora_fin = CURRENT, codret = ccodret
WHERE empresa = pempresa    and
      proceso = "califcart" and
      sistema = "06"        and
      fecha   = dtFechaHoy;

-- Se genera reporte de la calificación para mostrar por SIF
/*Se elimina a solicitud de soporte para la redución de tiempo 
  EXECUTE PROCEDURE bdicred:"informix".sp_genera_reporte_calificacion(pEmpresa, dtFechaHoy) INTO cCodRet,cMensajeRet;

  IF cCodRet <> '000000' THEN
     LET cMensajeRet = 'Se generó un error en el proceso de generación del reporte de calificación';
     RETURN cCodRet, cMensajeRet;
  END IF;
*/--Se elimina a solicitud de soporte para la redución de tiempo 
-- Se genera un archivo plano con la información de reservas que inserta en la tabla sd_hist_reserva.
/*
  LET vDia = lpad(DAY(dtFechaHoy),2,'00');
  LET vMes = lpad(MONTH(dtFechaHoy),2,'00');
  LET vAnio = YEAR(dtFechaHoy);

  let vsql = 'echo " unload to '''|| '/resplogifx/burodecredito/calificacion.unl'''||" delimiter '|' "||
             '" > /resplogifx/burodecredito/calificacion.sql';
  system vsql;

  let vsql = 'echo "'||
             ' select * FROM bdicred:sd_hist_reserva WHERE empresa = '''||pEmpresa|| ''' and fecha_cierre = '''|| dtFechaHoy || ''' ' ||
             ' AND grado_riesgo IS NOT NULL;  ' ||
             ' " >> /resplogifx/burodecredito/calificacion.sql';
  system vsql;

  let vsql = 'dbaccess bdicred /resplogifx/burodecredito/calificacion.sql';
  system vsql;

  let vsql = "cp /resplogifx/burodecredito/calificacion.unl /resplogifx/burodecredito/sd_hist_reserva_"|| vDia || vMes || vAnio ||".txt ";
  system vsql;

  let vsql = "gzip /resplogifx/burodecredito/sd_hist_reserva_"|| vDia || vMes || vAnio ||".txt ";
  system vsql;

  let vsql = "rm /resplogifx/burodecredito/calificacion.unl ";
  system vsql;
*/
LET cMensajeRet= 'El proceso de CALIFICACION DEL CIERRE se realizó correctamente';

RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para el calculo',
'de la reserva a fin de mes',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 06/MARZO/2009',
'BD    : BDICRED';

create procedure "informix".sp_modmaesdos_central(pEmpresa                  CHAR(3),
                                                  pNumCred                  CHAR(20),
            								      pTipoSaldo                CHAR(2),
												  pQuitaAbono               DECIMAL(18,2),
												  pCastigoAbono             DECIMAL(18,2),
												  pQuebrantoAbono           DECIMAL(18,2),
												  pAjusteCargo              DECIMAL(18,2),
												  pAjusteAbono              DECIMAL(18,2),
												  pCondonacionAbono         DECIMAL(18,2),
												  pIvaInteresVigente	    DECIMAL(18,2),
												  pIvaInteresVencido        DECIMAL(18,2),
												  pMontoActual              DECIMAL(18,2),
												  pDescripcionMovimiento    CHAR(100),
												  pClaveEmpleadoAutorizo    CHAR(20),
                                                  cfolio                    CHAR(16))
RETURNING
   CHAR(6),        -- numero de retorno del proceso
   CHAR (80),      -- Mensaje de retorno del proceso
   DECIMAL(18,2),  -- Monto actual
   DECIMAL(18,2),  -- Cantidad para actualizar
   DECIMAL(18,2),  -- Monto Actual despues de la afectación

   CHAR(16);       -- Folio

-- Autor: David Uriel Prieto Hurtado
-- Fecha de Creación 29/01/2009
-- Observaciones: Se realiza procedimiento para actualizar los saldos de capital en el maestro de
--                saldos (tabla: "bdicred:sd_ maesdos").
-- Autor: Paul Ivan Quintero Varela
-- Fecha de creación 22/05/2009
-- Observaciones: Se modifica para contemplar que no genere movimiento contable en moratorios
--                         y no se intente modificar ivas de intereses y se recalculen de forma automatica.
-- Autor: Roque Solis Campaña
-- Fecha de Creación: 23/06/2009
-- Observaciones: Se modifica para que en la actualización de interes vencido
--                       se actualiza conforme a la misma manera en la cual es obtenida
--                       mediante el status e iva del mes correspondiente.
DEFINE iSqlErr                     INTEGER;
DEFINE iIsamErr                    INTEGER;
DEFINE cErrorInfo                  CHAR(80);
DEFINE cCodRet                     CHAR(6);
DEFINE cMensajeRet                 CHAR(80);
DEFINE dMtoActual                  DECIMAL(18,2);
DEFINE dSdoNuevo                   DECIMAL(18,2);
DEFINE dSdoNuevoAux                DECIMAL(18,2);
DEFINE dMtoActual1                 DECIMAL(18,2);
DEFINE dMtoActual2                 DECIMAL(18,2);
DEFINE dMtoActual3                 DECIMAL(18,2);
DEFINE dMtoActual4                 DECIMAL(18,2);
DEFINE dMtoActual5                 DECIMAL(18,2);
DEFINE dMtoActual6                 DECIMAL(18,2);
DEFINE dMtoActual7                 DECIMAL(18,2);
DEFINE dMtoActual8                 DECIMAL(18,2);
DEFINE dSumMtosActualizar          DECIMAL(18,2);
DEFINE dSumAbonos                  DECIMAL(18,2);
DEFINE dSumCargos                  DECIMAL(18,2);
DEFINE cIdMovto                    CHAR(1);
DEFINE cNumProducto                CHAR(4);
DEFINE cStatusCred                 CHAR(2);
DEFINE dtFecha                     DATE;
DEFINE cSucursal                   CHAR(4);
DEFINE cDivisa                     CHAR(2);
DEFINE cDescTipoMovto              CHAR(16);
DEFINE iCantReg                    INTEGER;
DEFINE dtFechaCuota                DATE;
DEFINE dtFechaComparacion          DATE;
DEFINE dtFechaCuotaAux             DATE;
DEFINE dIntVigDebe                 DECIMAL(18,2);
DEFINE dIntVigPagado               DECIMAL(18,2);
DEFINE dIvaIntVigDebe              DECIMAL(18,2);
DEFINE dIvaIntVdoPagado            DECIMAL(18,2);
DEFINE dIvaIntVig                  DECIMAL(18,2);
DEFINE dIvaIntVdo                  DECIMAL(18,2);
DEFINE dIvaDebe                    DECIMAL(18,2);
DEFINE dIvaPagado                  DECIMAL(18,2);
DEFINE dInteresMes                 DECIMAL(18,2);
DEFINE dIvaMes                     DECIMAL(18,2);
DEFINE dSumIvaIntVig               DECIMAL(18,2);
DEFINE dinteres_debe               DECIMAL(18,2);
DEFINE dinteres_pagado             DECIMAL(18,2);
DEFINE Ddiferencia                 DECIMAL (18,2);
DEFINE dPagointeres                DECIMAL(18,2);
DEFINE dMtoCapVig                  DECIMAL(18,2);
DEFINE dMtoCapTrans                DECIMAL(18,2);
DEFINE dMtoCapVdo                  DECIMAL(18,2);
DEFINE dMtoVdoNoExig               DECIMAL(18,2);
DEFINE dMtoIntVig                  DECIMAL(18,2);
DEFINE dMtoIvaIntVig          	   DECIMAL(18,2);
DEFINE dMtoIntVdo                  DECIMAL(18,2);
DEFINE dMtoIntMoraOrdi             DECIMAL(18,2);
DEFINE dMtoIntMoraCope             DECIMAL(18,2);
DEFINE iBanVigVdo                  INTEGER;
DEFINE cSdoAfectado                CHAR(20);
DEFINE cTpoMovtoQuitaA             CHAR(2);
DEFINE cTpoMovtoCatigoA            CHAR(2);
DEFINE cTpoMovtoQuebrantoA         CHAR(2);
DEFINE cTpoMovtoAjusteC            CHAR(2);
DEFINE cTpoMovtoAjusteA            CHAR(2);
DEFINE cTpoMovtoCondonacionA       CHAR(2);
DEFINE cTpoMovtoIvaInteresVigente  CHAR(2);
DEFINE cTpoMovtoIvaInteresVencido  CHAR(2);
DEFINE dMora_provi_ordi            DECIMAL (18,2);
DEFINE dMora_provi_cope            DECIMAL (18,2);
DEFINE dMora_sdo_ordi              DECIMAL (18,2);
DEFINE dMora_sdo_ordi_pag          DECIMAL (18,2);
DEFINE dMora_sdo_cope              DECIMAL (18,2);
DEFINE dMora_sdo_cope_pag          DECIMAL (18,2);
DEFINE iCodigoRef                  INTEGER;
DEFINE cCodigoFun                  CHAR(3);
DEFINE cBanCapStatus               CHAR(1);
DEFINE dCapDebeAux                 DECIMAL(18,2);
DEFINE dCapPagAux                  DECIMAL(18,2);
DEFINE dMtoCapAux                  DECIMAL(18,2);
DEFINE dIntDebeAux                 DECIMAL(18,2);
DEFINE dIntPagAux                  DECIMAL(18,2);
DEFINE dSumAbonosAux               DECIMAL(18,2);
DEFINE dAbonoCap                   DECIMAL(18,2);
DEFINE dAbonoInt                   DECIMAL(18,2);
DEFINE dAbonoIntMoraOrdiAux        DECIMAL(18,2);
DEFINE dIntMoraOrdiDebeAux         DECIMAL(18,2);
DEFINE dIntMoraOrdiPagAux          DECIMAL(18,2);
DEFINE dIntMoraOrdiProviAux        DECIMAL(18,2);
DEFINE dAbonoIntMoraCopeAux        DECIMAL(18,2);
DEFINE dIntMoraCopeDebeAux         DECIMAL(18,2);
DEFINE dIntMoraCopePagAux          DECIMAL(18,2);
DEFINE dIntMoraCopeProviAux        DECIMAL(18,2);

LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "";
LET cMensajeRet     = "";
LET dMtoActual            = 0;
LET dSdoNuevo             = 0;
LET dSdoNuevoAux          = 0;
LET dMtoActual1           = 0;
LET dMtoActual2           = 0;
LET dMtoActual3           = 0;
LET dMtoActual4           = 0;
LET dMtoActual5           = 0;
LET dMtoActual6           = 0;
LET dMtoActual7           = 0;
LET dMtoActual8           = 0;
LET dSumMtosActualizar    = 0;
LET dSumAbonos            = 0;
LET dSumCargos            = 0;
LET cIdMovto              = "";
LET cNumProducto          = "";
LET cStatusCred           = "";
LET dtFecha               = DATE(1);
LET cSucursal             = "";
LET cDivisa               = "";
LET cDescTipoMovto        = "NV";
LET iCantReg              = 0;
LET dtFechaCuota          = DATE(1);
LET dtFechaComparacion    = DATE(1);
LET dtFechaCuotaAux       = DATE(1);
LET dIntVigDebe           = 0;
LET dIntVigPagado         = 0;
LET dIvaIntVigDebe        = 0;
LET dIvaIntVdoPagado      = 0;
LET dIvaIntVig            = 0;
LET dIvaIntVdo            = 0;
LET dIvaDebe              = 0;
LET dIvaPagado            = 0;
LET dInteresMes           = 0;
LET dIvaMes               = 0;
LET dSumIvaIntVig         = 0;
LET dinteres_debe         = 0;
LET dinteres_pagado       = 0;
LET Ddiferencia           = 0;
LET dPagointeres          = 0;
LET cBanCapStatus         = '';
LET dMtoCapVig            = 0;
LET dMtoCapTrans          = 0;
LET dMtoCapVdo            = 0;
LET dMtoVdoNoExig         = 0;
LET dMtoIntVig            = 0;
LET dMtoIvaIntVig         = 0;
LET dMtoIntVdo            = 0;
LET dMtoIntMoraOrdi       = 0;
LET dMtoIntMoraCope       = 0;
LET iBanVigVdo            = 0;
LET dMora_provi_ordi      = 0;
LET dMora_provi_cope      = 0;
LET dMora_sdo_ordi        = 0;
LET dMora_sdo_ordi_pag    = 0;
LET dMora_sdo_cope        = 0;
LET dMora_sdo_cope_pag    = 0;
LET cSdoAfectado          = "" ;

-- Parametros del catalogo de tipos de movimientos
LET cTpoMovtoQuitaA             = '01'; -- Quita-Abono
LET cTpoMovtoCatigoA            = '02'; -- Castigo-Abono
LET cTpoMovtoQuebrantoA         = '03'; -- Quebranto-Abono
LET cTpoMovtoAjusteC            = '04'; -- Cargo-Ajuste
LET cTpoMovtoAjusteA            = '05'; -- Abono-Ajuste
LET cTpoMovtoCondonacionA       = '06'; -- Condonacion-Abono
LET cTpoMovtoIvaInteresVigente  = '07'; -- Recalculo de Iva de interes Vigente
LET cTpoMovtoIvaInteresVencido  = '08'; -- Recalculo de Iva de interes Vencido

-- Parametros para transacciones de movimientos.
LET iCodigoRef  = 0;
LET cCodigoFun  = "";
--
LET dCapDebeAux   = 0;
LET dCapPagAux    = 0;
LET dMtoCapAux    = 0;
LET dIntDebeAux   = 0;
LET dIntPagAux    = 0;
LET dSumAbonosAux = 0;
LET dAbonoCap     = 0;
LET dAbonoInt     = 0;

LET dAbonoIntMoraOrdiAux  = 0;
LET dIntMoraOrdiDebeAux   = 0;
LET dIntMoraOrdiPagAux    = 0;
LET dIntMoraOrdiProviAux  = 0;

LET dAbonoIntMoraCopeAux  = 0;
LET dIntMoraCopeDebeAux   = 0;
LET dIntMoraCopePagAux    = 0;
LET dIntMoraCopeProviAux  = 0;

BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      ROLLBACK WORK;
      RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/tmp/sp_ModMaesdos_Central-X.out";
--TRACE ON;
SET LOCK MODE TO WAIT 3;

BEGIN WORK;
-- Se obtiene la información correspondiente al crédito
  SELECT
		a.num_producto,       -- Número de producto
		a.status_cred,        -- Status del crédito
		a.sucursal,           -- Sucursal
		a.divisa,             -- Divisa
        b.sdo_capital,        -- Monto Capital Vigente
		b.monto_vencido,      -- Monto Capital Transitorio
		b.mto_venc_trasp,     -- Monto Capital Vencido
		b.cap_tras_no_venci,  -- Monto Capital Vencido No Exigible
        b.sdo_no_exig,        -- Monto Interes Vigente
        b.int_tra_no_exig,    -- Monto Interes Vencido
		c.fecha_hoy           -- Fecha hoy del sistema
    INTO
		cNumProducto,
		cStatusCred,
		cSucursal,
		cDivisa,
		dMtoCapVig,
		dMtoCapTrans,
		dMtoCapVdo,
		dMtoVdoNoExig,
        dMtoIntVig,
        dMtoIntVdo,
		dtFecha
	FROM
		"informix".sd_maecred a,
        "informix".sd_maesdos b,
        "informix".sd_fechas c,
        "informix".sd_definicion d,
         bdinteg:"informix".si_sucursales e
    WHERE a.empresa          = pEmpresa
	  AND a.num_credito      = pNumCred
	  AND a.bANDera_ministra = 'M'
	  AND b.empresa          = a.empresa
	  AND b.num_credito      = a.num_credito
	  AND c.empresa          = a.empresa
	  AND d.empresa          = a.empresa
	  AND d.num_producto     = a.num_producto
	  AND e.empresa			 = a.empresa
	  AND e.sucursal         = a.sucursal;

-- Se obtiene el calculo de la suma para el monto a actualizar.
LET dSumMtosActualizar = pAjusteCargo - pAjusteAbono; /*pCastigoAbono - pQuebrantoAbono - pQuitaAbono -  - pCondonacionAbono;*/
LET dSumAbonos         = pAjusteAbono;
LET dSumCargos         = pAjusteCargo;

IF NVL(cfolio,'')= '' THEN
     LET cDescTipoMovto="NV"|| LPAD(DAY(dtFecha),2,'0')||LPAD(MONTH(dtFecha),2,'0')||YEAR(dtFecha)|| REPLACE(REPLACE(REPLACE(EXTEND(CURRENT,HOUR TO fraction(3)), ':',''),'.',''),'-','');
     LET cfolio = cDescTipoMovto;
ELSE
    LET cDescTipoMovto = cfolio;
END IF;
-- Identifica el tipo de amortizacion a realizar
IF DAY(dtFecha) <= 20 THEN
    LET dtFechaComparacion = MDY(MONTH(dtFecha - 1 UNITS MONTH),20, YEAR(dtFecha));
ELSE
    LET dtFechaComparacion = MDY(MONTH(dtFecha),20, YEAR(dtFecha));
END IF;
-- Se identifica el capital a afectar,
-- y se actualiza el campo correspondiente en el maestro de saldos.
IF pTipoSaldo= "01" THEN -- Capital Vigente
       LET cSdoAfectado= 'sdo_capital';
       LET dMtoActual= dMtoCapVig;
       LET dSdoNuevo= dMtoCapVig + dSumMtosActualizar;

 IF dMtoActual = pMontoActual THEN
				IF dSdoNuevo > dMtoActual THEN
                {IF dMtoCapVig < 0 THEN
                    UPDATE "informix".sd_amortiza_credito
                       SET capital_debe = capital_debe + dSumCargos + dMtoCapVig
                     WHERE empresa    = pEmpresa
                       AND num_Credito = pNumCred
                       AND fecha_cuota = dtFechaComparacion;

                    UPDATE "informix".sd_amortiza_credito
                       SET capital_pagado = capital_pagado - dMtoCapVig
                     WHERE  empresa    = pEmpresa
                       AND num_Credito = pNumCred
                       AND fecha_cuota = dtFechaComparacion;
                 ELSE
                    UPDATE "informix".sd_amortiza_credito
                       SET capital_debe = capital_debe + dSumCargos
                     WHERE  empresa    = pEmpresa
                       AND num_Credito = pNumCred
                       AND fecha_cuota = dtFechaComparacion;
                 END IF;}
		    ELSE
                    LET dSumAbonosAux = dSumAbonos;
                    FOREACH
                        SELECT fecha_cuota, capital_debe, capital_pagado
                          INTO dtFechaCuotaAux, dCapDebeAux, dCapPagAux
                          FROM "informix".sd_amortiza_credito
                         WHERE empresa      = pEmpresa
                           AND num_credito  = pNumCred
                           AND fecha_cuota <= dtFechaComparacion
                           AND capital_status = 1
                         ORDER BY fecha_cuota ASC

							IF dSumAbonosAux > 0 THEN
                                IF dSumAbonosAux > (dCapDebeAux- dCapPagAux) THEN
                                    LET dSumAbonosAux = dSumAbonosAux - (dCapDebeAux - dCapPagAux);
                                    LET dAbonoCap = dCapDebeAux;
                                ELIF dSumAbonosAux = (dCapDebeAux- dCapPagAux) THEN
                                    LET dAbonoCap = dCapDebeAux;
                                    LET dSumAbonosAux = 0;
                                ELIF  dSumAbonosAux < (dCapDebeAux- dCapPagAux) THEN
                                    LET dAbonoCap =  dSumAbonosAux + dCapPagAux;
                                    LET dSumAbonosAux = 0;
                                END IF;

                                UPDATE "informix".sd_amortiza_credito
                                   SET capital_pagado = dAbonoCap,
									   capital_status = CASE WHEN capital_pagado >= capital_debe AND interes_pagado >= interes_debe AND iva_pagado >= iva_debe AND mora_sdo_ordi_pag >= mora_sdo_ordi + mora_provi_ordi AND mora_sdo_cope_pag >= mora_sdo_cope + mora_provi_cope AND capital_status <> '1' THEN '5' ELSE capital_status END
                                 WHERE empresa = pEmpresa
                                   AND num_Credito = pNumCred
                                   AND fecha_cuota = dtFechaCuotaAux;
						    END IF;
                     END FOREACH;
                     IF dSdoNuevo <=0 THEN
                         FOREACH
                            SELECT fecha_cuota, capital_debe, capital_pagado
                              INTO dtFechaCuotaAux, dCapDebeAux, dCapPagAux
                              FROM "informix".sd_amortiza_credito
                             WHERE empresa      = pEmpresa
                               AND num_credito  = pNumCred
                               AND fecha_cuota <= dtFechaComparacion
                               AND capital_status NOT IN ("5","7", "2")
                             ORDER BY fecha_cuota ASC

                             UPDATE "informix".sd_amortiza_credito
                                SET capital_pagado = dCapDebeAux,
								    capital_status = CASE WHEN capital_pagado >= capital_debe AND interes_pagado >= interes_debe AND iva_pagado >= iva_debe AND mora_sdo_ordi_pag >= mora_sdo_ordi + mora_provi_ordi AND mora_sdo_cope_pag >= mora_sdo_cope + mora_provi_cope AND capital_status <> '1' THEN '5' ELSE capital_status END
                              WHERE empresa = pEmpresa
                                AND num_Credito = pNumCred
                                AND fecha_cuota = dtFechaCuotaAux;
                       END FOREACH;
                   END IF;
 END IF;

  SELECT SUM (capital_debe - capital_pagado)
                INTO dMtoCapAux
                FROM "informix".sd_amortiza_credito
               WHERE empresa     = pEmpresa
                 AND num_credito = pNumCred
                 AND capital_status  in ('2','7','1');
           UPDATE "informix".sd_maesdos
                     SET sdo_capital = dSdoNuevo,
					 sdo_cap_insoluto = NVL(dSdoNuevo,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0),
                     monto_financiado =  dMtoCapAux
                   WHERE empresa= pEmpresa
                    AND num_credito= pNumCred;
	ELSE
	    LET cCodRet = '000002';
		LET cMensajeRet = 'El saldo en capital vigente se modificó en línea no es posible actualizar';
        ROLLBACK WORK;
		RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	END IF;
ELIF ptipoSaldo= "02" THEN  -- Capital Transitorio
       LET cSdoAfectado= 'monto_vencido';
       LET dMtoActual= dMtoCapTrans;
       LET dSdoNuevo= dMtoCapTrans + dSumMtosActualizar;

	IF dMtoActual = pMontoActual THEN

                SELECT MAX(fecha_cuota)
                INTO dtFechaCuotaAux
                FROM "informix".sd_amortiza_credito
               WHERE empresa     = pEmpresa
                 AND num_credito = pNumCred
                 AND fecha_cuota <= dtFechaComparacion
				 AND capital_status = '7'; -- IN ("2","7"); roque

                IF dSdoNuevo > dMtoActual THEN
                    IF dtFechaCuotaAux IS NULL THEN
                        SELECT MAX(fecha_cuota)
                          INTO dtFechaCuotaAux
                          FROM "informix".sd_amortiza_credito
                         WHERE empresa     = pEmpresa
                           AND num_credito = pNumCred
                           AND fecha_cuota <= dtFechaComparacion
            			   AND capital_status = 5;
                    END IF;
                    UPDATE "informix".sd_amortiza_credito
                       SET capital_debe = capital_debe + dSumCargos
                     WHERE empresa        = pEmpresa
                       AND num_credito    = pNumCred
                       AND fecha_cuota = dtFechaCuotaAux;

                       UPDATE "informix".sd_amortiza_credito
                       SET capital_status = CASE WHEN capital_pagado <= capital_debe THEN '7' ELSE capital_status END
                     WHERE empresa        = pEmpresa
                       AND num_credito    = pNumCred
                       AND fecha_cuota = dtFechaCuotaAux;
                 ELSE
                    UPDATE "informix".sd_amortiza_credito
                       SET capital_pagado = CASE WHEN (capital_pagado + dSumAbonos) >= capital_debe THEN capital_debe ELSE capital_pagado + dSumAbonos END
                     WHERE empresa = pEmpresa
                       AND num_credito = pNumCred
                       AND fecha_cuota = CASE WHEN NVL(dtFechaCuotaAux,DATE(1)) > DATE(1) THEN dtFechaCuotaAux ELSE dtFechaComparacion END;

					UPDATE "informix".sd_amortiza_credito
                       SET capital_status = CASE WHEN capital_pagado >= capital_debe AND interes_pagado >= interes_debe AND iva_pagado >= iva_debe AND mora_sdo_ordi_pag >= mora_sdo_ordi + mora_provi_ordi AND mora_sdo_cope_pag >= mora_sdo_cope + mora_provi_cope AND capital_status <> '1' THEN '5' ELSE capital_status END
                     WHERE empresa        = pEmpresa
                       AND num_credito    = pNumCred
                       AND fecha_cuota = CASE WHEN NVL(dtFechaCuotaAux,DATE(1)) > DATE(1) THEN dtFechaCuotaAux ELSE dtFechaComparacion END;
                 END IF;
  SELECT SUM (capital_debe - capital_pagado)
                INTO dMtoCapAux
                FROM "informix".sd_amortiza_credito
               WHERE empresa     = pEmpresa
                 AND num_credito = pNumCred
                 AND capital_status  in ('2','7','1');

            UPDATE "informix".sd_maesdos
                 SET monto_vencido = dSdoNuevo,
				     sdo_cap_insoluto = NVL(sdo_capital,0) + NVL(dSdoNuevo,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0),
					 monto_financiado =  dMtoCapAux
               WHERE empresa= pEmpresa
                 AND num_credito= pNumCred;
     ELSE
	    LET cCodRet = '000002';
		LET cMensajeRet = 'El saldo en capital transitorio se modificó en línea no es posible actualizar';
        ROLLBACK WORK;
		RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	END IF;
ELIF  pTipoSaldo= "03" THEN -- Capital Vencido
       LET cSdoAfectado= 'mto_venc_trasp';
       LET dMtoActual= dMtoCapVdo;
       LET dSdoNuevo= dMtoCapVdo + dSumMtosActualizar;

IF dMtoActual = pMontoActual THEN
             UPDATE "informix".sd_maesdos
               SET mto_venc_trasp = dSdoNuevo,
				   sdo_cap_insoluto = NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(dSdoNuevo,0) + NVL(cap_tras_no_venci,0)				   
				 --monto_financiado =  dMtoCapAux
             WHERE empresa= pEmpresa
               AND num_credito= pNumCred;

 	IF dSdoNuevo <= dMtoActual THEN --abono
					LET dSumAbonosAux = dSumAbonos;
                    FOREACH
                        SELECT fecha_cuota, capital_debe, capital_pagado
                          INTO dtFechaCuotaAux, dCapDebeAux, dCapPagAux
                          FROM "informix".sd_amortiza_credito
                         WHERE empresa      = pEmpresa
                           AND num_credito  = pNumCred
                           AND fecha_cuota <= dtFechaComparacion
                           AND capital_status = '2' -- IN ('2','7') roque
                         ORDER BY fecha_cuota ASC

					IF dSumAbonosAux > 0 THEN
                                IF dSumAbonosAux > (dCapDebeAux- dCapPagAux) THEN
                                    LET dSumAbonosAux = dSumAbonosAux - (dCapDebeAux - dCapPagAux);
                                    LET dAbonoCap = dCapDebeAux;
                                ELIF dSumAbonosAux = (dCapDebeAux- dCapPagAux) THEN
                                    LET dAbonoCap = dCapDebeAux;
                                    LET dSumAbonosAux = 0;
                                ELIF  dSumAbonosAux < (dCapDebeAux- dCapPagAux) THEN
                                    LET dAbonoCap =  dSumAbonosAux + dCapPagAux;
                                    LET dSumAbonosAux = 0;
                                END IF;

                                UPDATE "informix".sd_amortiza_credito
                                   SET capital_pagado = dAbonoCap,
									   capital_status = CASE WHEN capital_pagado >= capital_debe AND interes_pagado >= interes_debe AND iva_pagado >= iva_debe AND mora_sdo_ordi_pag >= mora_sdo_ordi + mora_provi_ordi AND mora_sdo_cope_pag >= mora_sdo_cope + mora_provi_cope AND capital_status <> '1' THEN '5' ELSE capital_status END
                                 WHERE empresa = pEmpresa
                                   AND num_Credito = pNumCred
                                   AND fecha_cuota = dtFechaCuotaAux;
						    END IF;
                     END FOREACH;
            ELSE
         SELECT MAX(fecha_cuota)
                INTO dtFechaCuotaAux
                FROM "informix".sd_amortiza_credito
               WHERE empresa     = pEmpresa
                 AND num_credito = pNumCred
                 AND fecha_cuota <= dtFechaComparacion
				 AND capital_status = ("2");

                 IF dtFechaCuotaAux IS NULL THEN
                    SELECT MAX(fecha_cuota)
                      INTO dtFechaCuotaAux
                      FROM "informix".sd_amortiza_credito
                     WHERE empresa     = pEmpresa
                       AND num_credito = pNumCred
                       AND fecha_cuota <= dtFechaComparacion
                       AND capital_status = "7";

                         IF dtFechaCuotaAux IS NULL THEN
                            SELECT MAX(fecha_cuota)
                              INTO dtFechaCuotaAux
                              FROM "informix".sd_amortiza_credito
                             WHERE empresa     = pEmpresa
                               AND num_credito = pNumCred
                               AND fecha_cuota <= dtFechaComparacion
                               AND capital_status = "5";
                         END IF;
                 END IF;

                UPDATE "informix".sd_amortiza_credito
                   SET capital_debe = capital_debe + dSumCargos
                 WHERE empresa        = pEmpresa
                   AND num_credito    = pNumCred
                   AND fecha_cuota = dtFechaCuotaAux;

                   UPDATE "informix".sd_amortiza_credito
                   SET capital_status = CASE WHEN capital_pagado <= capital_debe THEN '2' ELSE capital_status END
                 WHERE empresa        = pEmpresa
                   AND num_credito    = pNumCred
                   AND fecha_cuota = dtFechaCuotaAux;
			END IF;
              SELECT SUM (capital_debe - capital_pagado)
                INTO dMtoCapAux
                FROM "informix".sd_amortiza_credito
               WHERE empresa     = pEmpresa
                 AND num_credito = pNumCred
                 AND capital_status  in ('2','7','1');
            --    AND fecha_cuota = dtFechaComparacion;
               UPDATE "informix".sd_maesdos
               SET  monto_financiado =  dMtoCapAux
             WHERE empresa= pEmpresa
               AND num_credito= pNumCred;

	ELSE
	    LET cCodRet = '000002';
		LET cMensajeRet = 'El saldo en capital vencido se modificó en línea no es posible actualizar';
        ROLLBACK WORK;
		RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	END IF;
ELIF pTipoSaldo= "04" THEN -- Capital Vencido No Exigible
       LET cSdoAfectado= 'cap_tras_no_venci';
       LET dMtoActual= dMtoVdoNoExig;
       LET dSdoNuevo= dMtoVdoNoExig + dSumMtosActualizar;
	    IF dMtoActual = pMontoActual THEN
		    UPDATE "informix".sd_maesdos
		       SET cap_tras_no_venci= dSdoNuevo,
				   sdo_cap_insoluto = NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(dSdoNuevo,0)
		     WHERE empresa= pEmpresa
		       AND num_credito= pNumCred;
			   	   IF dSdoNuevo <= dMtoActual THEN
					LET dSumAbonosAux = dSumAbonos;
                   { FOREACH
                        SELECT fecha_cuota, capital_debe, capital_pagado
                          INTO dtFechaCuotaAux, dCapDebeAux, dCapPagAux
                          FROM "informix".sd_amortiza_credito
                         WHERE empresa      = pEmpresa
                           AND num_credito  = pNumCred
                           AND fecha_cuota <= dtFechaComparacion
                           AND capital_status IN ('2','7')
                         ORDER BY fecha_cuota ASC

							IF dSumAbonosAux > 0 THEN
                                IF dSumAbonosAux > (dCapDebeAux- dCapPagAux) THEN
                                    LET dSumAbonosAux = dSumAbonosAux - (dCapDebeAux - dCapPagAux);
                                    LET dAbonoCap = dCapDebeAux;
                                ELIF dSumAbonosAux = (dCapDebeAux- dCapPagAux) THEN
                                    LET dAbonoCap = dCapDebeAux;
                                    LET dSumAbonosAux = 0;
                                ELIF  dSumAbonosAux < (dCapDebeAux- dCapPagAux) THEN
                                    LET dAbonoCap =  dSumAbonosAux + dCapPagAux;
                                    LET dSumAbonosAux = 0;
                                END IF;

                                UPDATE "informix".sd_amortiza_credito
                                   SET capital_pagado = dAbonoCap
                                 WHERE empresa = pEmpresa
                                   AND num_Credito = pNumCred
                                   AND fecha_cuota = dtFechaCuotaAux;
								   UPDATE "informix".sd_amortiza_credito
                                   SET capital_status = CASE WHEN capital_pagado >= capital_debe AND interes_pagado >= interes_debe AND iva_pagado >= iva_debe AND mora_sdo_ordi_pag >= mora_sdo_ordi + mora_provi_ordi AND mora_sdo_cope_pag >= mora_sdo_cope + mora_provi_cope AND capital_status <> '1' THEN '5' ELSE capital_status END
                                 WHERE empresa = pEmpresa
                                   AND num_Credito = pNumCred
                                   AND fecha_cuota = dtFechaCuotaAux;
						    END IF;
                     END FOREACH;

					IF dSumAbonosAux > 0 THEN
                        UPDATE "informix".sd_amortiza_credito
                           SET capital_pagado = capital_debe,
						       capital_status = CASE WHEN capital_pagado >= capital_debe AND interes_pagado >= interes_debe AND iva_pagado >= iva_debe AND mora_sdo_ordi_pag >= mora_sdo_ordi + mora_provi_ordi AND mora_sdo_cope_pag >= mora_sdo_cope + mora_provi_cope AND capital_status <> '1' THEN '5' ELSE capital_status END
                         WHERE empresa = pEmpresa
                           AND num_Credito = pNumCred
                           AND fecha_cuota = dtFechaComparacion;
                     END IF;}-- roque
			END IF;
--Se agreaga el cargo al monto financiado
              SELECT (capital_debe - capital_pagado + pAjusteCargo)
                INTO dMtoCapAux
                FROM "informix".sd_amortiza_credito
               WHERE empresa     = pEmpresa
                 AND num_credito = pNumCred
                 AND fecha_cuota = dtFechaComparacion;

                {UPDATE "informix".sd_maesdos
                   SET monto_financiado =   monto_financiado + dSumMtosActualizar --dSdoNuevo + dMtoCapAux
                 WHERE num_credito = pNumCred
                   AND empresa     = pEmpresa;}
		ELSE
            LET cCodRet = '000002';
            LET cMensajeRet = 'El saldo en capital no exigible se modificó en línea no es posible actualizar';
            ROLLBACK WORK;
            RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	    END IF;
ELIF pTipoSaldo= "05" THEN -- Interes Vigente
         SELECT SUM(interes_debe), SUM(interes_pagado)
          INTO dIntVigDebe, dIntVigPagado
          FROM "informix".sd_amortiza_credito
         WHERE empresa = pEmpresa
           AND num_credito = pNumCred
           AND capital_status IN('7', '1')
           AND fecha_cuota <=dtFechaComparacion;
           LET dMtoIntVig = dIntVigDebe - dIntVigPagado;
	   LET dSdoNuevo= pMontoActual + dSumMtosActualizar;
    IF dMtoIntVig = pMontoActual THEN
             LET cSdoAfectado = 'sdo_no_exig';
                UPDATE bdicred:sd_Maesdos
                   SET sdo_no_exig = CASE WHEN sdo_no_exig = dMtoIntVig THEN dSdoNuevo ELSE  dMtoIntVig + dSdoNuevo END ----checar
                 WHERE empresa = pEmpresa
                   AND num_credito = pNumCred;
                   IF dSumMtosActualizar = 0 THEN
                       UPDATE bdicred:sd_Maesdos
                          SET sdo_no_exig = int_tra_no_exig,
                              int_tra_no_exig =dSumMtosActualizar
                        WHERE empresa = pEmpresa
                          AND num_credito = pNumCred
                          AND sdo_no_exig = 0;
			       END IF;
                   IF dSdoNuevo > pMontoActual THEN
                        UPDATE "informix".sd_amortiza_credito
                           SET interes_debe = interes_debe  + dSumCargos
                         WHERE empresa        = pEmpresa
                           AND num_credito    = pNumCred
                           AND fecha_cuota    = dtFechaComparacion; -- - 1 units month; -------
                   ELSE
                        UPDATE "informix".sd_amortiza_credito
                           SET interes_pagado = CASE WHEN dSdoNuevo = pMontoActual THEN interes_debe ELSE interes_pagado + dSumAbonos END
                         WHERE empresa = pEmpresa
                           AND num_credito = pNumCred
                           AND fecha_cuota = dtFechaComparacion;
                   END IF;
    	ELSE
            LET cCodRet = '000002';
            LET cMensajeRet = 'El saldo en interes vigente se modificó en línea no es posible actualizar';
            ROLLBACK WORK;
            RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	    END IF;
ELIF pTipoSaldo= "06" THEN -- Iva de Interes Vigente
        SELECT iva_debe, iva_pagado
          INTO dIvaIntVigDebe, dIvaIntVdoPagado
          FROM "informix".sd_amortiza_credito
         WHERE empresa = pEmpresa
           AND num_credito = pNumCred
           AND capital_status= '1'
           AND fecha_cuota = dtFechaComparacion;

		   LET dSumIvaIntVig= (dIvaIntVigDebe - dIvaIntVdoPagado);
		   LET dMtoActual= dSumIvaIntVig;

		IF  dMtoActual = pMontoActual  THEN
		   IF pIvaInteresVigente > dMtoActual THEN
		            LET cSdoAfectado = 'iva_debe';
					LET dSdoNuevo = pIvaInteresVigente - dMtoActual;
				    UPDATE sd_amortiza_credito
				       SET iva_debe = iva_debe + dSdoNuevo
			         WHERE empresa = pEmpresa
				       AND num_credito = pNumCred
				       AND fecha_cuota =  dtFechaComparacion; -- - 1 units month;
			ELSE
		            LET cSdoAfectado = 'iva_pagado';
					LET dSdoNuevo= dMtoActual - pIvaInteresVigente;
					UPDATE sd_amortiza_credito
					   SET iva_pagado = CASE WHEN pIvaInteresVigente=dMtoActual THEN iva_debe ELSE iva_pagado + dSdoNuevo END
					 WHERE empresa = pEmpresa
					   AND num_credito = pNumCred
					   AND fecha_cuota = dtFechaComparacion;
			END IF;
		ELSE
            LET cCodRet = '000002';
            LET cMensajeRet = 'El saldo en iva de interes vigente se modificó en línea no es posible actualizar';
            ROLLBACK WORK;
            RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	    END IF;
ELIF pTipoSaldo= "07" THEN  -- Interes Vencido
       LET cSdoAfectado= 'int_tra_no_exig';
       LET dSdoNuevo= dMtoIntVdo + dSumMtosActualizar;

    SELECT NVL(SUM(b.interes_debe - b.interes_pagado),0)
      INTO dInteresMes
      FROM "informix".sd_amortiza_credito b
     WHERE b.empresa = pEmpresa
       AND b.num_credito = pNumCred
       AND capital_status = '1';

	   IF cStatusCred = "BT" THEN
		  IF dMtoIntVdo - dInteresMes > 0 THEN
             LET dMtoIntVdo = dMtoIntVdo - dInteresMes;
		  ELSE
		     LET dMtoIntVdo = 0;
		  END IF;
	   END IF;
         LET dSdoNuevoAux= dMtoIntVdo + dSumMtosActualizar;
         LET dMtoActual= dMtoIntVdo;
	   IF dMtoIntVdo = pMontoActual OR dMtoIntVdo = dSdoNuevoAux THEN
                   IF dSdoNuevoAux > dMtoActual THEN
                        IF cStatusCred = "BT" THEN
                           LET dSdoNuevoAux = dSdoNuevoAux + dInteresMes;
                        END IF;
                 UPDATE "informix".sd_maesdos
                         SET int_tra_no_exig= dSdoNuevoAux + sdo_no_exig,
                             sdo_no_exig = 0
                       WHERE empresa= pEmpresa
                          AND num_credito= pNumCred;

                          SELECT MAX(fecha_cuota)
                            INTO dtFechaCuotaAux
                            FROM "informix".sd_amortiza_credito
                           WHERE  empresa    = pEmpresa
                             AND  num_credito = pNumCred
                             AND capital_status="2";

                            IF dtFechaCuotaAux IS NULL THEN
                                LET dtFechaCuotaAux = dtFechaComparacion - 1 UNITS MONTH;
                            END IF;

                         UPDATE "informix".sd_amortiza_credito
                            SET interes_debe = interes_debe + dSumCargos,
                                capital_status = CASE WHEN capital_status <>  "2"  THEN "2"  ELSE capital_status END
                          WHERE  empresa    = pEmpresa
                            AND  num_Credito = pNumCred
                            AND fecha_cuota = dtFechaCuotaAux;
                   ELSE
                        UPDATE "informix".sd_maesdos
                           SET int_tra_no_exig = int_tra_no_exig - dSumAbonos
                         WHERE empresa= pEmpresa
                           AND num_credito= pNumCred;

                        IF cStatusCred = "BT" THEN
                            UPDATE "informix".sd_maesdos
                               SET int_tra_no_exig = CASE WHEN int_tra_no_exig <= dInteresMes THEN 0 ELSE int_tra_no_exig END,
                                   sdo_no_exig = CASE WHEN int_tra_no_exig <= dInteresMes THEN  dInteresMes ELSE 0 END
                             WHERE empresa= pEmpresa
                               AND num_credito= pNumCred;
                        END IF;

                        LET dSumAbonosAux = dSumAbonos;
                        FOREACH
                            SELECT fecha_cuota, interes_debe, interes_pagado
                              INTO dtFechaCuotaAux, dIntDebeAux, dIntPagAux
                              FROM "informix".sd_amortiza_credito
                             WHERE empresa      = pEmpresa
                               AND num_credito  = pNumCred
                               AND fecha_cuota <= dtFechaComparacion
                               AND capital_status = '2' --IN ('1','7') roque
                          ORDER BY fecha_cuota ASC

                             IF dSumAbonosAux > 0 then
                                IF dSumAbonosAux > (dIntDebeAux- dIntPagAux) THEN
                                    LET dSumAbonosAux = dSumAbonosAux - (dIntDebeAux - dIntPagAux);
                                    LET dAbonoInt = dIntDebeAux;
                                ELIF dSumAbonosAux = (dIntDebeAux- dIntPagAux) THEN
                                    LET dAbonoInt = dIntDebeAux;
                                    LET dSumAbonosAux = 0;
                                ELIF  dSumAbonosAux < (dIntDebeAux- dIntPagAux) THEN
                                    LET dAbonoInt =  dSumAbonosAux + dIntPagAux;
                                    LET dSumAbonosAux = 0;
                                END IF;
                                UPDATE "informix".sd_amortiza_credito
                                   SET interes_pagado = dAbonoInt
                                 WHERE empresa = pEmpresa
                                   AND num_Credito = pNumCred
                                   AND fecha_cuota = dtFechaCuotaAux;

                             END IF;
                        END FOREACH;
                   END IF;
	   ELSE
           LET cCodRet = '000002';
           LET cMensajeRet = 'El saldo en interes vencido se modificó en línea no es posible actualizar';
           ROLLBACK WORK;
		   RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	   END IF;

ELIF pTipoSaldo= "08" THEN --  Iva de Interes Vencido
   SELECT NVL(SUM(iva_debe - iva_pagado),0)
     INTO dIvaIntVdo
	 FROM "informix".sd_amortiza_credito
	WHERE empresa = pEmpresa
      AND num_credito = pNumCred
	  AND capital_status = "2";  --IN ('2','7');
   SELECT NVL(SUM(b.iva_debe - b.iva_pagado),0)
     INTO dIvaMes
     FROM "informix".sd_amortiza_credito b
    WHERE b.empresa = pEmpresa
      AND b.num_credito = pNumCred
      AND capital_status = '1';

    LET dMtoActual= dIvaIntVdo;
    IF  dIvaIntVdo = pMontoActual THEN
            IF pIvaInteresVencido > dMtoActual THEN  -- Identifica un cargo
                LET cIdMovto = "C";
                LET cSdoAfectado = "iva_debe";
                LET dSdoNuevo = pIvaInteresVencido - dMtoActual;
            ELSE
                LET cIdMovto = "A";
                LET cSdoAfectado = "iva_pagado";
                LET dSdoNuevo = dMtoActual - pIvaInteresVencido ;
            END IF;
            EXECUTE PROCEDURE "informix".sp_actualizaivaintvdo(pEmpresa,pNumCred,pIvaInteresVencido)
                         INTO cCodRet,cMensajeRet;
                           IF cCodRet <> "000000" THEN
                              LET cCodRet = '000001';
                              LET cMensajeRet = 'Ocurrió error al actualizar el IVA DE INTERES VENCIDO';
                              ROLLBACK WORK;
                              RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
                         END IF;
    ELSE
       LET cCodRet = '000002';
       LET cMensajeRet = 'El saldo en iva de interes vencido se modificó en línea no es posible actualizar';
       ROLLBACK WORK;
       RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
    END IF;
ELIF pTipoSaldo = "09" THEN -- Interes Moratorio Base
	   SELECT NVL(SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag),0)
		 INTO dMtoIntMoraOrdi
		 FROM "informix".sd_amortiza_credito
		WHERE empresa = pEmpresa
		  AND num_credito = pNumCred
          AND capital_status IN (2,7);

		  LET dMtoActual= dMtoIntMoraOrdi;
IF 	dMtoActual =  pMontoActual THEN
		FOREACH
			SELECT LIMIT 1 fecha_cuota
			  INTO dtFechaCuotaAux
			  FROM "informix".sd_amortiza_credito
			 WHERE empresa = pEmpresa
			   AND capital_status in  ("2","7")
			   AND num_credito = pNumCred
			   AND fecha_cuota <= dtFecha
		  ORDER BY fecha_cuota ASC
		END FOREACH;

		   IF dSumCargos > 0 THEN
			 UPDATE "informix".sd_amortiza_credito
				SET mora_provi_ordi = mora_provi_ordi + dSumCargos
					--mora_provi_ordi = 0
			  WHERE empresa = pEmpresa
				AND num_credito = pNumCred
				AND fecha_cuota = CASE WHEN NVL(dtFechaCuotaAux,DATE(1)) > DATE(1) THEN dtFechaCuotaAux ELSE dtFechaComparacion END;

			  UPDATE "informix".sd_amortiza_credito
				 SET mora_iva_debe = (mora_provi_ordi + mora_provi_cope) * 0.15, --(mora_sdo_cope + mora_sdo_ordi) * 0.15,
					 mora_iva_pagado = (mora_sdo_cope_pag + mora_sdo_ordi_pag) * 0.15
			   WHERE empresa = pEmpresa
				AND num_credito = pNumCred
				 AND fecha_cuota = CASE WHEN NVL(dtFechaCuotaAux,DATE(1)) > DATE(1) THEN dtFechaCuotaAux ELSE dtFechaComparacion END;

				{UPDATE "informix".sd_maesdos
				   SET sdo_contab_mora = dSumCargos
				 WHERE num_credito = pNumCred;}

				 LET cSdoAfectado= 'mora_sdo_ordi';
				 LET dSdoNuevo= dMtoIntMoraOrdi + dSumCargos;
		   ELSE
				   LET dSumAbonosAux = dSumAbonos;
				   LET cSdoAfectado= 'mora_sdo_ordi_pag';
				   FOREACH
						SELECT fecha_cuota, mora_sdo_ordi, mora_sdo_ordi_pag, mora_provi_ordi --, capital_status
						  INTO dtFechaCuotaAux, dIntMoraOrdiDebeAux, dIntMoraOrdiPagAux, dIntMoraOrdiProviAux --, cBanCapStatus
						  FROM "informix".sd_amortiza_credito
						 WHERE empresa      = pEmpresa
						   AND num_credito  = pNumCred
						   AND fecha_cuota <= dtFechaComparacion
						   AND capital_status IN (2,7)
					  ORDER BY fecha_cuota ASC

						   LET dIntMoraOrdiDebeAux = dIntMoraOrdiDebeAux + dIntMoraOrdiProviAux;
						UPDATE "informix".sd_amortiza_credito
						   SET mora_sdo_ordi= dIntMoraOrdiDebeAux,
							   mora_provi_ordi = 0
						 WHERE empresa = pEmpresa
						  AND num_credito = pNumCred
						  AND fecha_cuota = dtFechaCuotaAux;

						IF dSumAbonosAux > 0 then
							IF dSumAbonosAux > (dIntMoraOrdiDebeAux- dIntMoraOrdiPagAux) THEN
								LET dSumAbonosAux = dSumAbonosAux - (dIntMoraOrdiDebeAux - dIntMoraOrdiPagAux);
								LET dAbonoIntMoraOrdiAux = (dIntMoraOrdiDebeAux - dIntMoraOrdiPagAux); --dIntMoraOrdiDebeAux;
							ELIF dSumAbonosAux = (dIntMoraOrdiDebeAux- dIntMoraOrdiPagAux) THEN
								LET dAbonoIntMoraOrdiAux = (dIntMoraOrdiDebeAux - dIntMoraOrdiPagAux); --dIntMoraOrdiDebeAux;
								LET dSumAbonosAux = 0;
							ELIF  dSumAbonosAux < (dIntMoraOrdiDebeAux- dIntMoraOrdiPagAux) THEN
								LET dAbonoIntMoraOrdiAux =  dSumAbonosAux + dIntMoraOrdiPagAux;
								LET dSumAbonosAux = 0;
							END IF;

							UPDATE "informix".sd_amortiza_credito
							   SET mora_sdo_ordi_pag = mora_sdo_ordi_pag + dAbonoIntMoraOrdiAux --,capital_status = cBanCapStatus
							 WHERE empresa = pEmpresa
							   AND num_Credito = pNumCred
							   AND fecha_cuota = dtFechaCuotaAux;

							UPDATE "informix".sd_amortiza_credito
							   SET mora_iva_debe = (mora_sdo_cope + mora_sdo_ordi) * 0.15,
								   mora_iva_pagado = (mora_sdo_cope_pag + mora_sdo_ordi_pag) * 0.15,
								   capital_status = CASE WHEN capital_pagado >= capital_debe AND interes_pagado >= interes_debe AND iva_pagado >= iva_debe AND mora_sdo_ordi_pag >= mora_sdo_ordi + mora_provi_ordi AND mora_sdo_cope_pag >= mora_sdo_cope + mora_provi_cope  AND capital_status <> '1' THEN '5' ELSE capital_status END
							 WHERE  empresa = pEmpresa
							  AND num_credito = pNumCred
							  AND fecha_cuota = dtFechaCuotaAux;

							   LET dSdoNuevo= (dIntMoraOrdiDebeAux - dIntMoraOrdiPagAux) - dSumAbonosAux;
						 END IF;
				   END FOREACH;
		   END IF;

		   SELECT  NVL(SUM(mora_provi_ordi+ mora_provi_cope),0), NVL(SUM(mora_sdo_ordi + mora_sdo_cope),0)
			 INTO dIntMoraOrdiProviAux , dIntMoraOrdiDebeAux
			 FROM "informix".sd_amortiza_credito
			WHERE empresa      = pEmpresa
			  AND num_credito  = pNumCred
			  AND fecha_cuota <= dtFechaComparacion
			  AND capital_status IN ("2","7");

		  UPDATE "informix".sd_maesdos
			SET sdo_moratorio = dIntMoraOrdiDebeAux,
				sdo_contab_mora =  dIntMoraOrdiProviAux
		  WHERE num_credito = pNumCred;
ELSE
   LET cCodRet = '000002';
   LET cMensajeRet = 'El saldo en interes moratorio base se modificó en línea no es posible actualizar';
   ROLLBACK WORK;
   RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
END IF;
ELIF pTipoSaldo = "10" THEN  -- Interes Moratorio Copete
      SELECT NVL(SUM(mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag),0)
	    INTO dMtoIntMoraCope
	    FROM "informix".sd_amortiza_credito
	   WHERE empresa = pEmpresa
		 AND num_credito = pNumCred;

    	 LET dMtoActual = dMtoIntMoraCope;

       IF dMtoIntMoraCope = pMontoActual THEN
		    FOREACH
			    SELECT LIMIT 1 fecha_cuota
				  INTO dtFechaCuotaAux
		          FROM "informix".sd_amortiza_credito
		         WHERE  empresa = pEmpresa
                 AND num_credito = pNumCred
                 AND capital_status in  ("2","7")
		         AND fecha_cuota <= dtFecha
		      ORDER BY fecha_cuota ASC
			END FOREACH;

			IF dSumCargos > 0 THEN
		         UPDATE "informix".sd_amortiza_credito
		            SET mora_provi_cope = mora_provi_cope + dSumCargos
					    --mora_provi_cope = 0
		          WHERE empresa = pEmpresa
                   AND num_credito = pNumCred
		        	AND fecha_cuota = CASE WHEN NVL(dtFechaCuotaAux,DATE(1)) > DATE(1) THEN dtFechaCuotaAux ELSE dtFechaComparacion END;

                  UPDATE "informix".sd_amortiza_credito
		             SET mora_iva_debe = (mora_provi_ordi + mora_provi_cope) * 0.15, --(mora_sdo_cope + mora_sdo_ordi) * 0.15,
                         mora_iva_pagado = (mora_sdo_cope_pag + mora_sdo_ordi_pag) * 0.15
		           WHERE empresa = pEmpresa
                     AND   num_credito = pNumCred
		            AND fecha_cuota = CASE WHEN NVL(dtFechaCuotaAux,DATE(1)) > DATE(1) THEN dtFechaCuotaAux ELSE dtFechaComparacion END;

					 LET cSdoAfectado= 'mora_sdo_cope';
		             LET dSdoNuevo= dMtoIntMoraCope + dSumCargos;

                     SELECT mora_iva_debe
                       INTO dIvaDebe
                       FROM "informix".sd_amortiza_credito
                      WHERE   empresa = pEmpresa
                       AND num_credito = pNumCred
		               AND fecha_cuota = CASE WHEN NVL(dtFechaCuotaAux,DATE(1)) > DATE(1) THEN dtFechaCuotaAux ELSE dtFechaComparacion END;
			 ELSE
					 LET dSumAbonosAux = dSumAbonos;
				     LET cSdoAfectado= 'mora_sdo_cope_pag';
			  		 FOREACH
                            SELECT fecha_cuota, mora_sdo_cope, mora_sdo_cope_pag, mora_provi_cope
                              INTO dtFechaCuotaAux, dIntMoraCopeDebeAux, dIntMoraCopePagAux, dIntMoraCopeProviAux
                              FROM "informix".sd_amortiza_credito
                             WHERE empresa      = pEmpresa
                               AND num_credito  = pNumCred
                               AND fecha_cuota <= dtFechaComparacion
                               AND capital_status IN (2,7)
                          ORDER BY fecha_cuota ASC

                               LET dIntMoraCopeDebeAux = dIntMoraCopeDebeAux + dIntMoraCopeProviAux;
                            UPDATE "informix".sd_amortiza_credito
		                       SET mora_sdo_cope= dIntMoraCopeDebeAux,
					               mora_provi_cope = 0
                             WHERE  empresa = pEmpresa
                              AND num_credito = pNumCred
		                      AND fecha_cuota = dtFechaCuotaAux;

							IF dSumAbonosAux > 0 then
                                IF dSumAbonosAux > (dIntMoraCopeDebeAux- dIntMoraCopePagAux) THEN
                                    LET dSumAbonosAux = dSumAbonosAux - (dIntMoraCopeDebeAux - dIntMoraCopePagAux);
                                    LET dAbonoIntMoraCopeAux = (dIntMoraCopeDebeAux - dIntMoraCopePagAux);
                                ELIF dSumAbonosAux = (dIntMoraCopeDebeAux- dIntMoraCopePagAux) THEN
                                    LET dAbonoIntMoraCopeAux = (dIntMoraCopeDebeAux - dIntMoraCopePagAux);
                                    LET dSumAbonosAux = 0;
                                ELIF dSumAbonosAux < (dIntMoraCopeDebeAux- dIntMoraCopePagAux) THEN
                                    LET dAbonoIntMoraCopeAux =  dSumAbonosAux+ dIntMoraCopePagAux;
                                    LET dSumAbonosAux = 0;
                                END IF;
                                UPDATE "informix".sd_amortiza_credito
                                   SET mora_sdo_cope_pag = mora_sdo_cope_pag + dAbonoIntMoraCopeAux
                                 WHERE empresa = pEmpresa
                                   AND num_Credito = pNumCred
                                   AND fecha_cuota = dtFechaCuotaAux;

						        UPDATE "informix".sd_amortiza_credito
		                           SET mora_iva_debe = (mora_sdo_cope + mora_sdo_ordi) * 0.15,
                                       mora_iva_pagado = (mora_sdo_cope_pag + mora_sdo_ordi_pag) * 0.15,
									   capital_status = CASE WHEN capital_pagado >= capital_debe AND interes_pagado >= interes_debe AND iva_pagado >= iva_debe AND mora_sdo_ordi_pag >= mora_sdo_ordi + mora_provi_ordi AND mora_sdo_cope_pag >= mora_sdo_cope + mora_provi_cope AND capital_status <> '1' THEN '5' ELSE capital_status END
		                         WHERE empresa = pEmpresa
                                   AND num_credito = pNumCred
		                           AND fecha_cuota = dtFechaCuotaAux;

								   LET dSdoNuevo = (dIntMoraCopeDebeAux - dIntMoraCopeDebeAux) - dSumAbonosAux;
                            END IF;
			  		   END FOREACH;
			 END IF;
            SELECT  NVL(SUM(mora_provi_ordi+ mora_provi_cope),0), NVL(SUM(mora_sdo_ordi + mora_sdo_cope),0)
                 INTO dIntMoraOrdiProviAux , dIntMoraOrdiDebeAux
                 FROM "informix".sd_amortiza_credito
                WHERE empresa      = pEmpresa
                  AND num_credito  = pNumCred
                  AND fecha_cuota <= dtFechaComparacion
                  AND capital_status IN ("2","7");

             UPDATE "informix".sd_maesdos
				SET sdo_moratorio = dIntMoraOrdiDebeAux,
				    sdo_contab_mora =  dIntMoraOrdiProviAux
			  WHERE num_credito = pNumCred;
    ELSE
       LET cCodRet = '000002';
       LET cMensajeRet = 'El saldo en interes moratorio copete se modificó en línea no es posible actualizar';
       ROLLBACK WORK;
       RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	END IF;
END IF;

IF pTipoSaldo = "11" THEN
   LET cSdoAfectado= 'iva_int_mor';
END IF;

LET dMtoActual1 = dMtoActual  - pQuitaAbono;
LET dMtoActual2 = dMtoActual1 - pCastigoAbono;
LET dMtoActual3 = dMtoActual2 - pQuebrantoAbono;
LET dMtoActual4 = dMtoActual3 + pAjusteCargo;
LET dMtoActual5 = dMtoActual4 - pAjusteAbono;
LET dMtoActual6 = dMtoActual5 - pCondonacionAbono;

IF pQuitaAbono > 0 THEN
	SELECT codigo_fun,codigo_ref
	INTO  cCodigoFun,iCodigoRef
	FROM sd_transacc_nvas_func
	WHERE empresa= pEmpresa
	AND tipo_movto = cTpoMovtoQuitaA
	AND tipo_saldo = pTipoSaldo;

  IF cCodigoFun IS NULL OR cCodigoFun = '' THEN
	LET cCodigoFun = '040';
  END IF;

   IF iCodigoRef IS NULL OR iCodigoRef = '' THEN
	 LET iCodigoRef = '99';
   END IF;

   CALL "informix".GENMOV (pEmpresa, pNumCred, cNumProducto,
						   iCodigoRef, cCodigoFun, dtFecha,
						   pQuitaAbono, cDescTipoMovto, cSucursal,
						   cDivisa, "0000")
	  RETURNING cCodRet, cMensajeRet;

   IF cCodRet <> "00000" THEN
	   LET cMensajeRet= "Ocurrió un problema al generar el movimiento(GENMOV) de QUITA-ABONO";
	   ROLLBACK WORK;
	   RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
   ELSE
	   EXECUTE PROCEDURE "informix".sp_GenMovBitacoraMovimientos ( pEmpresa,
																pNumCred,
																cTpoMovtoQuitaA,
																cSdoAfectado,
																dMtoActual,
																pQuitaAbono * -1,
																dMtoActual1,
																pDescripcionMovimiento,
																pClaveEmpleadoAutorizo,
																dtFecha)
					INTO cCodRet,cMensajeRet;
		  IF cCodRet <> "000000" THEN
			 LET cCodRet = '000001';
			 LET cMensajeRet = 'Ocurrió un error al ejecutar el GENERAR bitacora MOVIMIENTO';
			 ROLLBACK WORK;
			 RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
		  END IF;
   END IF;
END IF;
IF pCastigoAbono > 0  THEN
		SELECT codigo_fun,codigo_ref
		INTO  cCodigoFun,iCodigoRef
		FROM sd_transacc_nvas_func
		WHERE empresa= pEmpresa
        AND tipo_movto = cTpoMovtoCatigoA
		AND tipo_saldo = pTipoSaldo;

		  IF cCodigoFun IS NULL OR cCodigoFun = '' THEN
		     LET cCodigoFun = '040';
		   END IF;

           IF iCodigoRef IS NULL OR iCodigoRef = '' THEN
             LET iCodigoRef = '99';
           END IF;

   CALL "informix".GENMOV (pEmpresa,
						   pNumCred,
						   cNumProducto,
						   iCodigoRef,
						   cCodigoFun,
						   dtFecha,
						   pCastigoAbono,
						   cDescTipoMovto,
						   cSucursal,
						   cDivisa,
						   "0000")
	  RETURNING cCodRet, cMensajeRet;

	   IF cCodRet <> "00000" THEN
		   LET cMensajeRet= "Ocurrió un problema al generar el movimiento(GENMOV) de CASTIGO-ABONO";
		   ROLLBACK WORK;
		   RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	   ELSE
			   EXECUTE PROCEDURE "informix".sp_GenMovBitacoraMovimientos ( pEmpresa,
																		pNumCred,
																		cTpoMovtoCatigoA,
																		cSdoAfectado,
																		dMtoActual1,
																		pCastigoAbono * -1,
																		dMtoActual2,
																		pDescripcionMovimiento,
																		pClaveEmpleadoAutorizo,
																		dtFecha)
							INTO cCodRet,cMensajeRet;
			  IF cCodRet <> "000000" THEN
				 LET cCodRet = '000001';
				 LET cMensajeRet = 'Ocurrió un problema al ejecutar el GENERAR bitacora MOVIMIENTO';
				 ROLLBACK WORK;
				 RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
			  END IF;
		END IF;
END IF;
IF pQuebrantoAbono > 0  THEN
	SELECT codigo_fun,codigo_ref
	INTO  cCodigoFun,iCodigoRef
	FROM sd_transacc_nvas_func
	WHERE empresa= pEmpresa
	AND tipo_movto = cTpoMovtoQuebrantoA
	AND tipo_saldo = pTipoSaldo;

	   IF cCodigoFun IS NULL OR cCodigoFun = '' THEN
		   LET cCodigoFun = '040';
		END IF;

	   IF iCodigoRef IS NULL OR iCodigoRef = '' THEN
		 LET iCodigoRef = '99';
	   END IF;

   CALL "informix".GENMOV (pEmpresa, pNumCred, cNumProducto,
						   iCodigoRef, cCodigoFun, dtFecha,
						   pQuebrantoAbono, cDescTipoMovto, cSucursal,
						   cDivisa,"0000")
	  RETURNING cCodRet, cMensajeRet;

	   IF cCodRet <> "00000" THEN
		   LET cMensajeRet= "Ocurrió un problema al generar el movimiento(GENMOV) de QUEBRANTO-ABONO";
		   ROLLBACK WORK;
		   RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
	   ELSE
			   EXECUTE PROCEDURE "informix".sp_GenMovBitacoraMovimientos (pEmpresa,
																		  pNumCred,
																		  cTpoMovtoQuebrantoA,
																		  cSdoAfectado,
																		  dMtoActual2,
																		  pQuebrantoAbono * -1,
																		  dMtoActual3,
																		  pDescripcionMovimiento,
																		  pClaveEmpleadoAutorizo,
																		  dtFecha)
							INTO cCodRet,cMensajeRet;
			  IF cCodRet <> "000000" THEN
				 LET cCodRet = '000001';
				 LET cMensajeRet = 'Ocurrió un error al ejecutar el GENERAR bitacora MOVIMIENTO';
				 ROLLBACK WORK;
				 RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
			  END IF;
		END IF;
END IF;
IF pAjusteCargo  > 0 THEN
	SELECT codigo_fun,codigo_ref
	INTO  cCodigoFun,iCodigoRef
	FROM sd_transacc_nvas_func
	WHERE empresa= pEmpresa
	AND tipo_movto = cTpoMovtoAjusteC
	AND tipo_saldo = pTipoSaldo;

	 IF cCodigoFun IS NULL OR cCodigoFun = '' THEN
	   LET cCodigoFun = '040';
	 END IF;

	 IF iCodigoRef IS NULL OR iCodigoRef = '' THEN
	  LET iCodigoRef = '99';
	 END IF;

	 CALL "informix".GENMOV (pEmpresa, pNumCred, cNumProducto,
							 iCodigoRef,cCodigoFun, dtFecha,
						   pAjusteCargo, cDescTipoMovto, cSucursal,
						   cDivisa, "0000")
	  RETURNING cCodRet, cMensajeRet;

		   IF cCodRet <> "00000" THEN
			   LET cMensajeRet= "Ocurrió un problema al generar el movimiento(GENMOV) de AJUSTE-CARGO";
			   ROLLBACK WORK;
			   RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
		   END IF;
		   EXECUTE PROCEDURE "informix".sp_GenMovBitacoraMovimientos ( pEmpresa,
																	pNumCred,
																	cTpoMovtoAjusteC,
																	cSdoAfectado,
																	dMtoActual3,
																	pAjusteCargo,
																	dMtoActual4,
																	pDescripcionMovimiento,
																	pClaveEmpleadoAutorizo,
																	dtFecha)
						INTO cCodRet,cMensajeRet;
		  IF cCodRet <> "000000" THEN
			 LET cCodRet = '000001';
			 LET cMensajeRet = 'Ocurrió un error al ejecutar el GENERAR bitacora MOVIMIENTO';
			 ROLLBACK WORK;
			 RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
		  END IF;
END IF;
IF pAjusteAbono > 0 THEN
		SELECT codigo_fun,codigo_ref
		INTO  cCodigoFun,iCodigoRef
		FROM sd_transacc_nvas_func
		WHERE empresa= pEmpresa
        AND tipo_movto = cTpoMovtoAjusteA
		AND tipo_saldo = pTipoSaldo;

		 IF cCodigoFun IS NULL OR cCodigoFun = '' THEN
			LET cCodigoFun = '040';
         END IF;

		 IF iCodigoRef IS NULL OR iCodigoRef = '' THEN
		    LET iCodigoRef = '99';
		 END IF;
      CALL "informix".GENMOV (pEmpresa, pNumCred, cNumProducto,
                    iCodigoRef, cCodigoFun, dtFecha,
                    pAjusteAbono, cDescTipoMovto, cSucursal,
                    cDivisa, "0000")
          RETURNING cCodRet, cMensajeRet;

           IF cCodRet <> "00000" THEN
               LET cMensajeRet= "Ocurrió un problema al generar el movimiento(GENMOV) de AJUSTE-ABONO";
               ROLLBACK WORK;
               RETURN cCodRet,cMensajeRet,dMtoActual,dSumMtosActualizar, dSdoNuevo, cfolio;
           END IF;
		   EXECUTE PROCEDURE "informix".sp_GenMovBitacoraMovimientos ( pEmpresa,pNumCred,
																	cTpoMovtoAjusteA,cSdoAfectado,
																	dMtoActual4,pAjusteAbono * -1,
																	dMtoActual5,pDescripcionMovimiento,
																	pClaveEmpleadoAutorizo,dtFecha)
		INTO cCodRet,cMensajeRet;

		  IF cCodRet <> "000000" THEN
			 LET cCodRet = '000001';
			 LET cMensajeRet = 'Ocurrió un error al ejecutar el GENERAR bitacora MOVIMIENTO';
             ROLLBACK WORK;
			 RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
		  END IF;
END IF;
IF pCondonacionAbono > 0 THEN
		SELECT codigo_fun,codigo_ref
		INTO  cCodigoFun,iCodigoRef
		FROM sd_transacc_nvas_func
		WHERE empresa= pEmpresa
		AND tipo_movto = cTpoMovtoCondonacionA
		AND tipo_saldo = pTipoSaldo;

	   IF cCodigoFun IS NULL OR cCodigoFun = '' THEN
		   LET cCodigoFun = '040';
	   END IF;

	   IF iCodigoRef IS NULL OR iCodigoRef = '' THEN
		 LET iCodigoRef = '99';
	   END IF;
       CALL "informix".GENMOV (pEmpresa,
                    pNumCred,
                    cNumProducto,
                    iCodigoRef,
                    cCodigoFun,
                    dtFecha,
                    pCondonacionAbono,
                    cDescTipoMovto,
                    cSucursal,
                    cDivisa,
                    "0000")
          RETURNING cCodRet, cMensajeRet;

           IF cCodRet <> "00000" THEN
               LET cMensajeRet= "Ocurrió un problema al generar el movimiento(GENMOV) de CONDONACION-ABONO";
               ROLLBACK WORK;
               RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
           END IF;
		   EXECUTE PROCEDURE "informix".sp_GenMovBitacoraMovimientos ( pEmpresa,
                                                    pNumCred,
                                                    cTpoMovtoCondonacionA,
                                                    cSdoAfectado,
                                                    dMtoActual5,
                                                    pCondonacionAbono * -1,
                                                    dMtoActual6,
                                                    pDescripcionMovimiento,
                                                    pClaveEmpleadoAutorizo,
                                                   dtFecha)
						INTO cCodRet,cMensajeRet;
		  IF cCodRet <> "000000" THEN
			 LET cCodRet = '000001';
			 LET cMensajeRet = 'Ocurrió un error al ejecutar el GENERAR bitacora MOVIMIENTO';
             ROLLBACK WORK;
			 RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
		  END IF;
END IF;
COMMIT WORK;
IF cCodRet <> "00000" THEN
  LET cCodRet = "000000";
  LET cMensajeRet= "Se realizó actualización correctamente";
END IF;
  RETURN cCodRet,cMensajeRet,NVL(dMtoActual,0),NVL(dSumMtosActualizar,0), NVL(dSdoNuevo,0), cfolio;
END;
END PROCEDURE;