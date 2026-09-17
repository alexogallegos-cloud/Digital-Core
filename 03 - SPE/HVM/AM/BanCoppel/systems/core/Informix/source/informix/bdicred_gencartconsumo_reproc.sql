CREATE PROCEDURE "informix".gencartconsumo_reproc(pEmpresa CHAR(3))

RETURNING
          CHAR(6)   AS resultado,
          CHAR(100) AS mensaje;
		  
--execute procedure "informix".gencartconsumo_reproc('001');

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

DEFINE vDia                          CHAR(02);
DEFINE vMes                          CHAR(02);
DEFINE vAnio                         CHAR(4);
DEFINE vsql                          CHAR(200);
DEFINE cCreditoExterno               CHAR(20);
DEFINE dDiasXMes                     DECIMAL(18,5);

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
/*
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
*/
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "gencartconsumo_reproc.out";
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
LET cCreditoExterno = '';
LET dDiasXMes =0;

-- Se obtiene la fecha hoy del sistema.
SELECT {+INDEX(sd_fechas idx_sdfechas)} a.fecha_hoy, prox_fecha, pri_dia_mes
   INTO dtFechaHoy, vprox_fecha, dtPriDiaMes 
   FROM bdicred:sd_fechas a
  WHERE a.empresa = pempresa;

--temporal solo para pruebas
	let dtFechaHoy  = mdy('08','31','2015');
	let vprox_fecha = mdy('09','01','2015');
	let dtPriDiaMes = mdy('08','01','2015');
--temporal solo para pruebas

--Se calcula el factor de comparación para los créditos que se dieron de alta entre el 21 y último día del mes
--LET dFactor  = (day(dtFechaHoy) - 20) / day(dtFechaHoy); ---NO SE OCUPA ESTA VARIABLE
/*
   SELECT {+INDEX(bdinteg:sx_contproc idx_xcontproc1)} status_proc
     INTO vstatus_proc
     FROM bdinteg:sx_contproc
    WHERE empresa     = pempresa     and
          proceso     = "CierreCred" and
          status_proc = "F"          and
          sistema     = "06"         and
          fecha       = dtFechaHoy;

   if ( vstatus_proc is null ) then
      let ccodret = "000582";
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
*/
--
-- Carga de parametros
--

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsPI FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '3';

 IF dConsPI IS NULL THEN
   LET cCodRet= '000030';
   LET cMensajeRet= 'FALTA CONSTANTE PARA PROBABILIDAD DE INCUMPLIMIENTO PI';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsACT FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '4';

 IF dConsACT IS NULL THEN
    LET cCodRet= '000040';
    LET cMensajeRet= 'FALTA CONSTANTE IMPAGO ACTUAL PI';
    RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsHIST FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '5';

 IF dConsHIST IS NULL THEN
    LET cCodRet= '000050';
    LET cMensajeRet= 'FALTA CONSTANTE IMPAGO HISTORICO PI';
    RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsANT FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '6';

 IF dConsANT IS NULL THEN
    LET cCodRet= '000060';
    LET cMensajeRet= 'FALTA CONSTANTE ANTIGÜEDAD PI';
    RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsPORPAGO FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '7';

 IF dConsPORPAGO IS NULL THEN
   LET cCodRet= '000070';
   LET cMensajeRet= 'FALTA CONSTANTE PARA EL CALCULO DE PORCENTAJE PAGO PI';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsPORUSO FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '8';

 IF dConsPORUSO IS NULL THEN
    LET cCodRet= '000080';
    LET cMensajeRet= 'FALTA CONSTANTE PARA EL CALCULO DE PORCENTAJE USO PI';
    RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dPorPagoMin FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '9';

 IF dPorPagoMin IS NULL THEN
   LET cCodRet= '000090';
   LET cMensajeRet= 'FALTA PORCENTAJE PAGO MÍNIMO';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dPorcUsoMin FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '10';

 IF dPorcUsoMin IS NULL THEN
   LET cCodRet= '000010';
   LET cMensajeRet= 'FALTA PORCENTAJE USO MÍNIMO';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dpiEI FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '11';

 IF dpiEI IS NULL THEN
   LET cCodRet= '000110';
   LET cMensajeRet= 'FALTA EXPOSICIÓN AL MOMENTO DE INCUMPLIMIENTO';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dMeses FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '12';

 IF dMeses IS NULL THEN
   LET cCodRet= '000120';
   LET cMensajeRet= 'FALTA NÚMERO DE MESES';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dPIdefaul FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '13';

 IF dPIdefaul IS NULL THEN
   LET cCodRet= '000130';
   LET cMensajeRet= 'FALTA CONSTANTE PARA PROBABILIDAD DE INCUMPLIMIENTO >=4';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsSPMenor FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '14';

 IF dConsSPMenor IS NULL THEN
   LET cCodRet= '000140';
   LET cMensajeRet= 'FALTA CONSTANTE SEVERIDAD DE LA PERDIDA CUANDO ACT<12 ';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsSPMayor FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '15';

 IF dConsSPMayor IS NULL THEN
   LET cCodRet= '000150';
   LET cMensajeRet= 'FALTA CONSTANTE SEVERIDAD DE LA PERDIDA CUANDO ACT>=12';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsComPI FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '16';

 IF dConsComPI IS NULL THEN
   LET cCodRet= '000160';
   LET cMensajeRet= 'FALTA CONSTANTE COMPARACIÓN PARA PI';
   RETURN cCodRet, cMensajeRet;
 END IF;

  SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dPorSaldoMin FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '17';

  IF dPorSaldoMin IS NULL THEN
     LET cCodRet= '000170';
     LET cMensajeRet= 'FALTA PARAMETRO PORCENTAJE DE SALDO MINIMO';
     RETURN cCodRet, cMensajeRet;
  END IF;

  SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dImpPerConACT FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa and cod_param= '18';
    
  IF dImpPerConACT IS NULL THEN
     LET cCodRet= '000180';
     LET cMensajeRet= 'FALTA PARAMETRO IMPAGOS EN PERIODOS CONSECUTIVOS ACT';
     RETURN cCodRet, cMensajeRet;
  END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dPorUsoMinCtesNunca FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '19';

 IF dPorUsoMinCtesNunca IS NULL THEN
   LET cCodRet= '000190';
   LET cMensajeRet= 'FALTA PORCENTAJE USO MINIMO CLIENTES NUNCA';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsMinPorPago FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '21';

 IF dConsMinPorPago IS NULL THEN
    LET cCodRet= '000210';
    LET cMensajeRet= 'FALTA VALOR MINIMO COMPARATIVO % DE PAGO';
    RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsMaxPorPago FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '22';

  IF dConsMaxPorPago IS NULL THEN
     LET cCodRet= '000220';
     LET cMensajeRet= 'FALTA MAXIMO COMPARATIVO % DE PAGO';
     RETURN cCodRet, cMensajeRet;
  END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsMinPorUso FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '23';

 IF dConsMinPorUso IS NULL THEN
    LET cCodRet= '000230';
    LET cMensajeRet= 'FALTA MINIMO COMPARATIVO % DE USO';
    RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dConsMaxPorUso FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '24';

 IF dConsMaxPorUso IS NULL THEN
    LET cCodRet= '000240';
    LET cMensajeRet= 'FALTA MAXIMO COMPARATIVO % DE USO';
    RETURN cCodRet, cMensajeRet;
 END IF;

    SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dPorResSic FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '25';
    
    IF dPorResSic IS NULL THEN
       LET cCodRet= '000250';
       LET cMensajeRet= 'FALTA PORCENTAJE DE RESERVA DE SIC';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO cGradoRiesgoAux FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '26';
    
    IF cGradoRiesgoAux IS NULL THEN
       LET cCodRet= '000260';
       LET cMensajeRet= 'GRADO RIESGO CLIENTES NUNCA';
       RETURN cCodRet, cMensajeRet;
    END IF;

/*     EXECUTE PROCEDURE bdicred:monthadd(MDY(month(dtFechaHoy),'20',year(dtFechaHoy)), -1) INTO dtFechaPeriodo;

    SELECT {+INDEX(sd_gradualidad idx_sd_gradualidad)} gradual
      INTO dGradual
      FROM bdicred:sd_gradualidad
     WHERE empresa=pEmpresa
       AND mes_ano=lpad(month(dtFechaHoy),2,0)||year(dtFechaHoy);

    IF dGradual IS NULL OR dGradual = '' THEN LET dGradual = 1; END IF;
*/

    SELECT valor INTO dDiasXMes FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '27';
    
    IF dDiasXMes IS NULL THEN
       LET cCodRet= '000270';
       LET cMensajeRet= 'DIAS POR MES';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT a.num_credito,a.credito_externo
      FROM bdicred:sd_maecredcont a
      LEFT OUTER JOIN bdicred:sd_hist_reserva b on a.empresa = b.empresa AND a.num_credito = b.num_credito AND b.fecha_corte = mdy(month(a.fecha),20,year(a.fecha))
     WHERE a.empresa = pEmpresa
       AND a.fecha = dtFechaHoy
       AND b.fecha_cierre IS NULL
       AND a.num_credito matches '60*'
      into temp paso1 with no log;

    insert into paso1
    SELECT a.num_credito,a.credito_externo
      FROM bdicred:sd_maecredcont a
      LEFT OUTER JOIN bdicred:sd_hist_reserva b on a.empresa = b.empresa AND a.num_credito = b.num_credito AND b.fecha_corte = mdy(month(a.fecha),18,year(a.fecha))
     WHERE a.empresa = pEmpresa
       AND a.fecha = dtFechaHoy
       AND b.fecha_cierre IS NULL
       AND a.num_credito matches '70*';

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
           grado_riesgo_bancoppel,nvl(c.mto_venc_tra_int,0),nvl(c.monto_otorgado,0), b.fecha_corte,aa.credito_externo
      INTO cNumCredito, iCuotasVdas, dPagos, dImpagosCons, dImpagosHist, dMesesAntiguedad,
           dtFechaApertura,cPeriodicidad, vProducto, vSucursal, vDivisa, vStatusCred,
           dPI, dSP,dLimiteCredito,dEvaBuro,
           dEndeudamientoTotCierre,dEndeudamientoTotCorte,
           dDiaCorte,dReservaCalifMesAnterior,
           dPorUso, dPorPago, dtFechacierre,
           dgradoriesgobancoppel,vtotal_capitalizado,dLimiteCreditoNvo,dtFechacorte,cCreditoExterno
      FROM bdicred:sd_maecredcont a
           join paso1 aa on (a.num_credito = aa.num_credito)
           JOIN bdicred:sd_maecredanexo d on a.empresa = d.empresa AND a.num_credito = d.num_credito
--           LEFT OUTER JOIN bdicred:sd_hist_reserva b on a.empresa = b.empresa AND a.num_credito = b.num_credito AND b.fecha_corte = mdy(month(a.fecha),20,year(a.fecha)) 
-- Se modifica para incluir la tarjeta Platino
           LEFT OUTER JOIN bdicred:sd_hist_reserva b on a.empresa = b.empresa AND a.num_credito = b.num_credito AND b.fecha_corte = mdy(month(a.fecha),d.dia_corte,year(a.fecha)) 
-- Se modifica para incluir la tarjeta Platino
           JOIN bdicred:sd_maesdoscont c on a.empresa = c.empresa  AND a.num_credito = c.num_credito and c.fecha = a.fecha
     WHERE a.empresa = pEmpresa
       AND a.fecha = dtFechaHoy
       AND b.fecha_cierre IS NULL
       AND trim(a.campo_trab3) <> 'BAJA' --No se califican los créditos que sufren baja en la cartera 28/02/2014


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

     IF dgradoriesgobancoppel='IN' or dgradoriesgobancoppel = 'A1' THEN
        UPDATE {+INDEX(sd_hist_reserva fecha_corte)} "informix".sd_hist_reserva
           SET fecha_cierre = dtFechaHoy,
               saldo_cierre = dEndeudamientoTotCierre,
               exposicion_incumplimiento = (CASE WHEN dEndeudamientoTotCierre < 0 THEN 0 ELSE dEndeudamientoTotCierre END)
         WHERE empresa = pEmpresa
           AND fecha_corte = mdy(month(dtFechaHoy),dDiaCorte,year(dtFechaHoy))
           AND num_credito = cNumCredito;
--rss
		IF dgradoriesgobancoppel = 'A1' THEN
		
			LET vNvoPeriodo= 0;
			
		ELIF dgradoriesgobancoppel = 'IN' THEN
		
			LET vNvoPeriodo= 9;
			
		END IF;
--rss
-- Actualiza Maestro de Credito Central
         UPDATE {+INDEX(sd_maecred idx_idx_maecredb)} bdicred:sd_maecred
            SET calificacion_riesgo = cGradoRiesgoAux -- B1 cambia por A1
          WHERE empresa = pempresa
            AND num_credito = cNumCredito;
--rss se trae este registro contable del primer proceso de calificación

        IF dEndeudamientoTotCierre > 0 THEN
		
            EXECUTE PROCEDURE genmov_calif (pEmpresa,
                                          cNumCredito,
                                          vProducto,
--rss                                          1,
                                          vNvoPeriodo,
                                          "090",--"071", --666
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
        LET dPorUso =0;               LET dReservaCalifMesAnterior =0; LET dEndeudTotCierreSinIntereses =0; LET cGradoRiesgoAux = 'A1';
		LET cGradoRiesgo = 0;		  

--        LET vcontador_insert = vcontador_insert + 1;
        COMMIT WORK;
        CONTINUE FOREACH;
     END IF;

     IF dMesesAntiguedad IS NULL THEN
        LET dPagosnunca = 0;
--        LET iANT = round((dtFechaHoy - dtFechaApertura)/30,2);
        LET iANT = round((dtFechaHoy - dtFechaApertura)/dDiasXMes,2);
        
        if vProducto = '7000' then
    -- Se obtiene el antecedente de Buró
            SELECT evalua_cc
              INTO dEvaBuro
              FROM bdisolic:ss_resum_scor_fin
             WHERE empresa = pempresa
               AND num_solicitud = cCreditoExterno;
    -- Se obtiene la línea autorizada
            SELECT {+INDEX(bdisolic:ss_solicitudes empsol)} nvl(monto_solicitado,0)
              INTO dLineaAutorizada
              FROM bdisolic:ss_solicitudes
             WHERE empresa = pempresa
               AND num_solicitud = cCreditoExterno;
        else
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
        end if;
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
       LET cGradoRiesgo = cGradoRiesgoAux; --B1 cambia por A1
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
    IF dResCalificacion < 0 THEN LET dResCalificacion = 0; END IF;

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
	IF cGradoRiesgoEdoResultados= 'A1' THEN
		LET vNvoPeriodo= 0;
	ELIF cGradoRiesgoEdoResultados= 'A2' THEN
		LET vNvoPeriodo= 1;
	ELIF cGradoRiesgoEdoResultados= 'B1' THEN
		LET vNvoPeriodo= 2;
	ELIF cGradoRiesgoEdoResultados= 'B2' THEN
		LET vNvoPeriodo= 3;
	ELIF cGradoRiesgoEdoResultados= 'B3' THEN
		LET vNvoPeriodo= 4;
	ELIF cGradoRiesgoEdoResultados= 'C1' THEN
		LET vNvoPeriodo= 5;
	ELIF cGradoRiesgoEdoResultados= 'C2' THEN
		LET vNvoPeriodo= 6;
	ELIF cGradoRiesgoEdoResultados= 'D' THEN
		LET vNvoPeriodo= 7;
	ELIF cGradoRiesgoEdoResultados= 'E' THEN
		LET vNvoPeriodo= 8;
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
                                           "091",--"070", --665
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
                                      "090",--"071", --666
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
                                           0,
                                           "093",--"661",
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
                                                  0,
                                                  "094",--"661",
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
    LET cCreditoExterno = '';

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
/*
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
*/
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

CREATE PROCEDURE "informix".sp_repcrednorev (pEmpresa CHAR(3), pFecha DATE )

RETURNING CHAR(5);  -- Codigo de Retorno
		  
		  
	---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(5);
DEFINE cMensajeRet		CHAR(80);

DEFINE	cNumCte	CHAR(20);  
DEFINE	cNombreCte	CHAR(150);
DEFINE	cNumCred	CHAR(20);  
DEFINE	cSitCont	INTEGER; 
DEFINE	tpCred	CHAR(1);	  
DEFINE	dSaldoTotal	DECIMAL(18,2);
DEFINE	cMoneda	CHAR(1);
DEFINE	dCapVig	DECIMAL(18,2);
DEFINE	dCapVig28	DECIMAL(18,2);
DEFINE	dCapVig29	DECIMAL(18,2);
DEFINE	dCapVig30	DECIMAL(18,2);
DEFINE	dCapVig31	DECIMAL(18,2);
DEFINE	dCapVenc	DECIMAL(18,2);
DEFINE	dCapVenc28	DECIMAL(18,2);
DEFINE	dCapVenc29	DECIMAL(18,2);
DEFINE	dCapVenc30	DECIMAL(18,2);
DEFINE	dCapVenc31	DECIMAL(18,2);
DEFINE	dIntVenc	DECIMAL(18,2);
DEFINE	dIntVenc28	DECIMAL(18,2);
DEFINE	dIntVenc29	DECIMAL(18,2);
DEFINE	dIntVenc30	DECIMAL(18,2);
DEFINE	dIntVenc31	DECIMAL(18,2);
DEFINE	dIntMor	DECIMAL(18,2);
DEFINE	dIntMor28	DECIMAL(18,2);
DEFINE	dIntMor29	DECIMAL(18,2);
DEFINE	dIntMor30	DECIMAL(18,2);
DEFINE	dIntMor31	DECIMAL(18,2);
DEFINE	dComPend	DECIMAL(18,2);
DEFINE	dSeguros	DECIMAL(18,2);
DEFINE	dOtrosAdeudos	DECIMAL(18,2);
DEFINE	iFlagCob	INTEGER;
DEFINE	iDiasAtraso		INTEGER;
DEFINE	iTipoTasa	  INTEGER;
DEFINE	iTipoGar	  INTEGER;
DEFINE	iRestriccion	  INTEGER;
DEFINE	dtFechaApertura	  DATE;
DEFINE	dtFechaVenci	  DATE;
DEFINE	dMontoExigible	  DECIMAL(18,2);
DEFINE	dPagoReal	  DECIMAL(18,2);
DEFINE	cProducto	 CHAR(4);

DEFINE	dtFechaFinMes	DATE;
DEFINE	dTFechaSD	DATE;	
  
DEFINE	iContador	INTEGER;	

DEFINE cSql            	CHAR(2500);
DEFINE cNombreArchivo  	CHAR(100);
DEFINE cNombreArchivo1  CHAR(100);
DEFINE cConsulta		CHAR(2200);
DEFINE cEncabezado		CHAR(500);
DEFINE cRuta 			CHAR(80);
define dtFechaHoy DATE;

---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '00000';
LET cMensajeRet			= 'Proceso Exitoso';

LET	cNumCte	= '';
LET	cNombreCte	= '';
LET	cNumCred	= '';
LET	cSitCont	= 0;
LET	tpCred	= '50';  
LET	cMoneda	= '';  
LET	dSaldoTotal	= 0;

LET	dCapVig	= 0;
LET	dCapVig28	= 0;
LET	dCapVig29	= 0;
LET	dCapVig30	= 0;
LET	dCapVig31	= 0;
LET	dCapVenc	= 0;
LET	dCapVenc28	= 0;
LET	dCapVenc29	= 0;
LET	dCapVenc30	= 0;
LET	dCapVenc31	= 0;
LET	dIntVenc	= 0;
LET	dIntVenc28	= 0;
LET	dIntVenc29	= 0;
LET	dIntVenc30	= 0;
LET	dIntVenc31	= 0;
LET	dIntMor	= 0;
LET	dIntMor28	= 0;
LET	dIntMor29	= 0;
LET	dIntMor30	= 0;
LET	dIntMor31	= 0;
LET	dComPend	= 0;
LET	dSeguros	= 0;
LET	dOtrosAdeudos	= 0;
LET	iFlagCob	= 0;
LET	iDiasAtraso	= 0;
LET	iTipoTasa	= 1;
LET	iTipoGar	= 10;
LET	iRestriccion	= 0;
LET	dtFechaApertura	= DATE(1);
LET	dtFechaVenci	= DATE(1);
LET	dMontoExigible	= 0;
LET	dPagoReal	= 0;
LET	cProducto	= "";

LET	dtFechaFinMes	= DATE(1);
LET	dTFechaSD	 =DATE(1);
LET  iContador  = 0;

LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';
LET cRuta	= "";
LET dtFechaHoy		    = DATE(1);
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr,cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;          
          RETURN cCodRet;
       END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/informix/jesus/correo/sp_repcrednorev.out";
	--TRACE ON;	
	
		
	IF NVL(pEmpresa,'') = ''  OR pFecha  = '' THEN
		LET cCodRet	= '00001';
		LET cMensajeRet	= 'PARAMETROS DE ENTRADA INVALIDOS';
		RETURN cCodRet;
	END IF;
	
	  --RUTA PARA GENERAR EL ARCHIVO
	SELECT valor
	INTO cRuta
	FROM "informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='081';
	
	--SINO EXISTE LA RUTA DEL ARCHIVO	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
		LET cMensajeRet ='NO EXISTE PARAMETRO DE LA RUTA PARA GENERAR EL ARCHIVO';
		RETURN cCodRet;
	END IF;	 
	
	-- OBTIENE LA FECHA DEL DIA
	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM "informix".sd_fechas
	WHERE empresa = '001';
	
	--obtener fecha de fin de mes  del periodo solicitado
	
	LET dTFechaSD = MONTHADD(mdy(month(pFecha),01,YEAR(pFecha)), - 1);
	LET dtFechaFinMes = mdy(month(pFecha),01,YEAR(pFecha)) - 1 units day;
			--GENERA EL NOMBRE DEL ARCHIVO
		LET cNombreArchivo = TRIM('Infpattitcrdnorev')||TO_CHAR(dtFechaHoy,'%d%m%y')|| '.txt';
		LET cNombreArchivo1 = TRIM('Infpattitcrdnorev_aux')||TO_CHAR(dtFechaHoy,'%d%m%y')|| '.txt';
		
	FOREACH WITH HOLD		
		SELECT a.numcte,TRIM(NVL(cte.nombre1,' ')) || ' ' || TRIM(NVL(cte.nombre2,' ')) || ' ' || TRIM(NVL(cte.apell_paterno,' ')) || ' ' || TRIM(NVL(cte.apell_materno,' ')),
			TODAY,a.num_credito, DECODE(a.status_cred,"AA",1,2), "50", a.divisa,
			c.saldo_cierre,b.sdo_cap_insoluto,b.monto_vencido,(b.int_tra_no_exig+b.sdo_no_exig),(b.sdo_moratorio+b.sdo_contab_mora),
			(SELECT NVL(SUM(NVL(dc.monto_com,0) - NVL(dc.monto_pag,0)),0)
			 FROM "informix".sd_detcomi dc , "informix".sd_tpcomis tc
			WHERE dc.empresa     = a.empresa
			AND dc.num_credito = a.num_credito AND dc.estado_com  = 'A'	
			AND dc.empresa     = tc.empresa
			AND dc.cod_comis   = tc.cod_comis
			AND tc.comi_o_seg ='1'	
			AND dc.fecha_alta <= dtFechaFinMes), 0,0,
			 (SELECT  dtFechaFinMes -  NVL(MIN(fecha_cuota),dtFechaFinMes) 		   
				   FROM "informix".sd_amortiza_creditocrd    
				   WHERE  empresa =a.empresa
				   AND num_credito = a.num_credito
				   AND capital_status IN ('2','7')), 
		catprod.tipo_cobra, catprod.tipo_tasa,catprod.tipo_gar,catprod.restriccion,
		a.fecha_apertura,a.fecha_vencim, b.monto_financiado,c.pagos_realizados	
		INTO cNumCte, cNombreCte,pFecha,cNumCred,  cSitCont,  tpCred,cMoneda, dSaldoTotal, dCapVig, dCapVenc, dIntVenc, dIntMor, dComPend, dSeguros, dOtrosAdeudos,	iDiasAtraso, iFlagCob, iTipoTasa, iTipoGar, iRestriccion, dtFechaApertura,dtFechaVenci,dMontoExigible, dPagoReal
		FROM "informix".sd_maecredcontcrd a
		LEFT JOIN "informix".sd_hist_reserva_crd c ON( c.empresa = a.empresa	AND c.num_credito = a.num_credito		AND c.fecha_cierre = mdy(6,30,2015)),
		 sd_maesdoscontcrd b , 	bdinteg:"informix".si_cliente  cte, "informix".sd_catalogo_prod  catprod
			WHERE a.fecha = dtFechaFinMes
			AND a.empresa = b.empresa
			AND b.num_credito = a.num_credito		 	
			AND a.status_cred IN ("AA","BA","BT")
			AND b.fecha = dtFechaFinMes			
			AND cte.empresa = a.empresa
			AND cte.numcte = a.numcte
			AND catprod.empresa =a.empresa 
			AND catprod.num_producto = a.num_producto	
			
		
		
			LET cConsulta = TRIM(NVL(cNumCte,''))||'|'|| TRIM(NVL(cNombreCte,''))||'|'||pFecha||'|'|| TRIM(NVL(cNumCred,''))||'|'||  TRIM(NVL(cSitCont,''))||'|'||  TRIM(NVL(tpCred,''))||'|'||
			NVL(cMoneda,'')||'|'|| NVL(dSaldoTotal,0)||'|'|| NVL(dCapVig,0)||'|'|| NVL(dCapVenc,0)||'|'|| NVL(dIntVenc,0)||'|'|| NVL(dIntMor,0)||'|'|| NVL(dComPend,0)||'|'|| NVL(dSeguros,0)||'|'|| NVL(dOtrosAdeudos,0)||'|'||
			NVL(iDiasAtraso,0)||'|'|| NVL(iFlagCob,0)||'|'|| NVL(iTipoTasa,0)||'|'|| NVL(iTipoGar,0)||'|'|| NVL(iRestriccion,0)||'|'|| NVL(dtFechaApertura,DATE(1))||'|'|| NVL(dtFechaVenci,DATE(1))||'|'|| NVL(dMontoExigible,0)||'|'|| NVL(dPagoReal,0);
		
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;
		
		
	   LET  iContador  = 1;
    END FOREACH;
   
   
   
   --SET DEBUG FILE TO "/informix/jesus/correo/sp_repcrednorev.out";
	--TRACE ON;
   IF iContador > 0 THEN 	

	
	---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo "Identificar del cliente'||'|'||'Nombre del acreditado'||'|'||'Periodo'||'|'||'Identificador de Crédito'||'|'||'Situación Contable'||'|'||'Tipo de Crédito'||'|'||'Moneda'||'|'||'Saldo Total'||'|'||'Capital Vigente'||'|'||'Capital Vencido'||'|'||'Interes Ordinario'||'|'||'Interes Moratorio'||'|'||'Comisiones'||'|'||'Seguros'||'|'||'Otros Adeudos'||'|'||'Dias de Atraso'||'|'||'Cobranza'||'|'||'Tipo de tasa'||'|'||'Tasa  de Garantia'||'|'||'Restricciones'||'|'||'Fecha de Inicio'||'|'||'Fecha de Vencimiento'||'|'||'Monto Exigible'||'|'||'Pago Realizado'||'|'|| '" > '||TRIM(cruta)|| cNombreArchivo;  
		SYSTEM cEncabezado;

		LET cSql = cSql;
		LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNombreArchivo1) || " >> " || TRIM(cRuta) || TRIM(cNombreArchivo);
		SYSTEM cSql;
		
		--BORRADO DE TEMPORALES QUE FUERON USADOS PARA LA CREACION DE ARCHIVO
				
		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
		SYSTEM cSQL;   
   
   
	RETURN cCodRet;
   
   ELSE
    LET cCodRet			= '00003';
	LET cMensajeRet			= 'No se encontro información';
	RETURN cCodRet;
   END IF;
   
END;
END PROCEDURE
DOCUMENT    
'DESCRIPCION: Procedimiento para  la créditos vencidos de los titulares, RQM 06 419', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'FECHA: 01 Junio 2015',
'VERSION: 20150601.1645',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_obtienecred_proyecciones(pProducto CHAR(4))
RETURNING 	CHAR(5)  AS codigo_retorno,
			CHAR(4)  AS NumeroProd,
			CHAR(40) AS DescripcionProd,
			DECIMAL(18,2) AS MontoMin,
			DECIMAL(18,2) AS MontoMax,
			INTEGER AS PlazoMin,
			INTEGER AS PlazoMax,
			DECIMAL(18,2) AS Tasa,
			CHAR(6) AS Comision;

---DECLARACIONES
DEFINE cCodRet        	CHAR(5);
DEFINE iSqlErr      	INTEGER;
DEFINE cNumProducto		CHAR(7);
DEFINE cDescProducto	CHAR(40);
DEFINE dMontoMin	DECIMAL(18,2);
DEFINE dMontoMax	DECIMAL(18,2);
DEFINE dTasa		DECIMAL(18,2);
DEFINE iPlazoMin	INTEGER;
DEFINE iPlazoMax	INTEGER;
DEFINE dComision		DECIMAL(5,2);
DEFINE cCodComDispEfectivo	CHAR(4);
---INICIALIZACIONES
LET iSqlErr             = 0;
LET cCodRet             = "00000";
LET cNumProducto			= '';
LET cDescProducto			= '';
LET dMontoMin	= 0;
LET dTasa	= 0;
LET dMontoMax	= 0;
LET iPlazoMin	= 0;
LET iPlazoMax	= 0;
LET dComision	= 0;
LET cCodComDispEfectivo	='';



BEGIN

ON EXCEPTION SET iSqlErr
    LET cCodRet= iSqlErr;
    RETURN cCodRet, TRIM(cNumProducto), TRIM(cDescProducto),dMontoMin, dMontoMax, iPlazoMin, iPlazoMax,dTasa,dComision;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/tmp/sp_obtienetpoproducto.out';
--TRACE ON;

	FOREACH


	SELECT a.abrevia_prod, a.descrip_prod,b.monto_min_cred,b.monto_max_cred,b.plazo_min_cred,b.plazo_max_cred,c.valor
		INTO cNumProducto, cDescProducto, dMontoMin, dMontoMax, iPlazoMin, iPlazoMax,dTasa
		FROM bdicred:"informix".sd_tipprod a , bdicred:"informix".sd_definicion b,
			 bdinteg:"informix".si_fechavalor c
		WHERE a.cod_prod IN('P','R')
		AND a.abrevia_prod= b.num_producto
		AND b.num_producto = CASE WHEN  NVL(pProducto,'') = '' THEN b.num_producto ELSE pProducto END
		AND c.tasa = b.cod_tasa_base
		AND c.fecha = (SELECT MAX(r.fecha)
					FROM bdinteg:"informix".si_fechavalor r
					WHERE r.tasa = b.cod_tasa_base
					AND r.fecha = r.fecha
					AND r.empresa = b.empresa)
		AND c.empresa = b.empresa
		--RQM 10 550 AAME 20150911 Se modifica para quitar la omisión de los productos de prestamo (7600,7700)
		--AND num_producto NOT IN ('7600','7700')
		--AND num_producto <> '6900'  --RQM 10 452 09-09-2013 AAME Se comenta la validación de diferente del producto "6900" para lo despliegue en el listado.
		ORDER BY abrevia_prod

		IF 	cNumProducto = "6400" THEN
			SELECT valor INTO dComision
			FROM   "informix".sd_param
			WHERE  cod_param = '040';
		END IF;
		--RQM 10 452 09-09-2013 AAME Se agrega validación para que cuando sea el producto "6900" tome el plazo minimo y maximo de la tabla sd_tasa_plazo.
		IF cNumProducto = "6900" THEN
			SELECT Min(plazo),Max(plazo)
			INTO iPlazoMin,iPlazoMax
			FROM bdicred:"informix".sd_tasa_plazo;
			
			LET dMontoMin=1000;
			
			--INC 09-02-2015 SE AGREGA FACTOR PARA OBTENER LA COMISION CORRECTA PARA CREDISOLUCION
			SELECT TRIM(valor)::CHAR(4)
			INTO cCodComDispEfectivo
			FROM bdicred:"informix".sd_param
			WHERE cod_param  = '334';
			-- OBTIENE EL FACTOR PARA LA COMISION DE LA DISPOSICION DE EFECTIVO
				SELECT apli_factor
				INTO dComision
				FROM bdicred:"informix".sd_tpcomis
				WHERE cod_comis = cCodComDispEfectivo;
			
		END IF;

		RETURN cCodRet, TRIM(cNumProducto), TRIM(cDescProducto),dMontoMin, dMontoMax, iPlazoMin, iPlazoMax,dTasa,dComision WITH RESUME;

	END FOREACH;

	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet= '00001';  --No hay informacion
		RETURN cCodRet, TRIM(cNumProducto), TRIM(cDescProducto),dMontoMin, dMontoMax, iPlazoMin, iPlazoMax,dTasa,dComision;
    END IF;

END
END PROCEDURE

DOCUMENT
'DESCRIPCION: Obtiene los productos de crédito que se usan para proyecciones ',
'AUTOR : Jesus Manuel Aguilar Heredia ',
'FECHA : 29/Enero/2013',
'BD    : BDICRED',
'Version: 20130129.1614';

CREATE PROCEDURE "informix".corta_linea(plinea char(1000), pcaracteres integer)
RETURNING 	NVARCHAR(255),INTEGER;


DEFINE v_caracter 	CHAR(1);
DEFINE v_pos_actual INTEGER;
DEFINE v_pos$ INTEGER;
DEFINE v_pos_blanco INTEGER;
DEFINE iBandera$ INTEGER;
DEFINE iBanderaEsp INTEGER;
DEFINE v_renglon	VARCHAR(255);
DEFINE v_palabra	VARCHAR(255);
DEFINE v_palabra2	VARCHAR(255);
LET v_caracter 		= "";
LET v_pos_actual 	= 1;
LET v_pos$ 	= 0;
LET v_pos_blanco 	= 1;
LET v_renglon		= "";
LET v_palabra	= "";
LET v_palabra2	= "";LET iBandera$	= 0;
LET iBanderaEsp	= 0;

--SET DEBUG FILE TO "/informix/jesus/corta_linea.out";
--TRACE ON;

---set pdqpriority 11;
 
BEGIN

	
	LET plinea = TRIM(plinea); 
	
	IF LENGTH(NVL(plinea,'')) = 0 THEN
		RETURN v_renglon,0 ;
	END IF
	IF SUBSTR(plinea,1,26) ='CARGO POR CREDISOLUCIONES' THEN 
		LET iBandera$ = 1;
	END IF;
	
	IF SUBSTR(plinea,len(plinea)-29,19) ='Folio de aclaración' THEN 	--RQI 22 268 JMAH	
		LET v_palabra2 = SUBSTR(plinea,len(plinea)-29,LEN(plinea));	
		LET plinea =SUBSTR(plinea,1,len(plinea)-30);
	END IF
	WHILE  v_pos_actual <= LENGTH(plinea)  
		
		
		----------OBTENGO EL CARACTER ACTUAL
		LET v_caracter = SUBSTR(plinea,v_pos_actual,1);
		
		IF v_caracter ='$' AND iBandera$ = 1 THEN
			LET  v_pos$ = v_pos$+1;
		END IF;
		IF v_caracter ='/ ' AND iBandera$ = 1 THEN
			LET  v_pos$ = v_pos$+1;
		END IF;

		IF (((v_caracter = "I" and  v_pos$ > 0 ) OR (iBanderaEsp =9) ) AND iBandera$ = 1)  THEN
			RETURN v_renglon,LENGTH(v_renglon) WITH RESUME;
			LET v_renglon		= "";
			LET v_palabra	= "";
			LET iBanderaEsp =0;
		END IF;
		
		LET v_palabra = v_palabra || v_caracter;
		
		----------OBTENGO LA POSICION DE LA ULTIMA PALABRA ENCONTRADA
		
		IF v_caracter = " " OR v_pos_actual = LENGTH(plinea) THEN
		
			IF LENGTH(TRIM(v_palabra)) > 0 THEN
				IF LENGTH(v_renglon || v_palabra) <= pcaracteres 
						AND v_pos_actual < LENGTH(plinea) THEN
						LET v_renglon = v_renglon || v_palabra;
				ELIF LENGTH(v_renglon || v_palabra) <= pcaracteres 
						AND v_pos_actual = LENGTH(plinea) THEN
						LET v_renglon = v_renglon || v_palabra;
						RETURN v_renglon,LENGTH(v_renglon) WITH RESUME;
						LET v_renglon = v_palabra;
				ELSE
						RETURN v_renglon,LENGTH(v_renglon) WITH RESUME;
						LET v_renglon = v_palabra;
                        if v_pos_actual >= LENGTH(plinea)  then
                          RETURN v_renglon,LENGTH(v_renglon) WITH RESUME;
                        end if;
				END IF
				LET iBanderaEsp = iBanderaEsp+1;
			END IF
			LET v_palabra = "";
		END IF;
		
		LET v_pos_actual = v_pos_actual + 1;

	END WHILE
	
	IF NVL(v_palabra2,'') <> '' THEN --RQI 22 268 JMAH
		 RETURN v_palabra2,LENGTH(v_palabra2) WITH RESUME; 
	END IF;
	
END
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".calc_iva_grav_pp(p_cEmpresa CHAR(3), p_cNumCredito CHAR(20), p_dTasaInt DECIMAL(9,6),
                                             p_dIvaSuc DECIMAL(5,3), p_dtFechaHoy DATE,p_dtIvaFechaPag DATE,
                                             p_dtFechaApert DATE,p_dtFechaCuota DATE,p_dIntNorm DECIMAL(18,2))

RETURNING
   CHAR(6)        AS Cod_Ret,
   DECIMAL(18,2)  AS IvaIntReal,
   CHAR(80)       AS Mens_Ret;

    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cErrorInfo       CHAR(80);
    DEFINE cCodRet          CHAR(6);
    DEFINE cMensajeRet      CHAR(125);
    DEFINE l_diascalc       INTEGER;
    DEFINE l_dtFechaComp    DATE;
    DEFINE l_iDias          INTEGER;
    DEFINE l_dFactor1       DECIMAL(14,9);
    DEFINE l_dFactor2       DECIMAL(14,9);
    DEFINE l_dTasaReal      DECIMAL(14,9);
    DEFINE l_dFactorIntReal DECIMAL(14,9);
    DEFINE l_dIvaIntReal    DECIMAL(18,2);

    LET iSqlErr               = 0;
    LET iIsamErr              = 0;
    LET cErrorInfo            = "";
    LET cCodRet               = "000000";
    LET cMensajeRet           = "Proceso Exitoso";

    LET l_diascalc            = 0;
    LET l_dtFechaComp         = DATE(1);
    LET l_iDias               = 0;
    LET l_dFactor1            = 0;
    LET l_dFactor2            = 0;
    LET l_dTasaReal           = 0;
    LET l_dFactorIntReal      = 0;
    LET l_dIvaIntReal         = 0;

    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
       RETURN cCodRet,l_dIvaIntReal,cMensajeRet;
       END IF;
    END EXCEPTION;

   -- SET DEBUG FILE TO "/pisa/cas/calc_iva_grav_pp.out";
   -- TRACE ON;

--    SET LOCK MODE TO WAIT 3;

    select valor
    into l_diascalc
    from bdicred:sd_param
    where cod_param='24'
    and empresa= p_cEmpresa;

    IF p_dtIvaFechaPag IS NULL THEN
        CALL bdicred:monthadd(p_dtFechaCuota,-1) RETURNING l_dtFechaComp;

          SELECT fecha_cuota
            INTO l_dtFechaComp
            FROM "informix".sd_amortiza_creditocrd
           WHERE empresa     = p_cEmpresa
             AND num_credito = p_cNumCredito
             AND fecha_cuota = l_dtFechaComp;

             IF l_dtFechaComp IS NULL THEN
                 LET l_dtFechaComp = p_dtFechaApert;
             END IF;
    ELSE
          LET l_dtFechaComp = p_dtIvaFechaPag;
    END IF;

    LET l_iDias    = p_dtFechaHoy - l_dtFechaComp;

    IF l_iDias > 0 THEN
        LET l_dFactor1 = NVL(p_dTasaInt,0)/(l_diascalc *100)* l_iDias;
        IF NVL(l_dFactor1,0) < 0 THEN
             LET cCodRet      = "000001";
             LET cMensajeRet  = "No es posible realizar los calculos con el valor obtenido para el factor 1";
          RETURN cCodRet,l_dIvaIntReal,TRIM(cMensajeRet);
        END IF;

        CALL bdicred:determina_udi_rango(p_cEmpresa,date(l_dtFechaComp-1),date(p_dtFechaHoy-1)) RETURNING cCodRet,l_dFactor2;

        IF NVL(l_dFactor2,0) < 0 THEN
             LET cCodRet     = "000002";
             LET cMensajeRet = "No es posible realizar los calculos con el valor obtenido para el factor 2";
          RETURN cCodRet,l_dIvaIntReal,TRIM(cMensajeRet);
        END IF;

        LET l_dTasaReal       = l_dFactor1 - l_dFactor2;
        IF l_dTasaReal< 0 THEN LET l_dTasaReal=0; END IF;
        IF l_dTasaReal = 0 THEN
		 LET l_dFactorIntReal = 0;
		ELSE
			LET l_dFactorIntReal  = (l_dTasaReal * p_dIvaSuc)/l_dFactor1;
		END IF;
--        LET p_dIntNorm        = g_dSdoInt;
        LET l_dIvaIntReal     = round(l_dFactorIntReal * p_dIntNorm,2);
    END IF;

    IF cCodRet <> "000000" THEN
      LET cCodRet = "000000";
    END IF;

        RETURN cCodRet,l_dIvaIntReal,cMensajeRet;

    END
END PROCEDURE;