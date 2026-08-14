CREATE PROCEDURE "informix".gencartconsumo(pEmpresa CHAR(3))

RETURNING
          CHAR(6)   AS resultado,
          CHAR(100) AS mensaje;
		  
--execute procedure "informix".gencartconsumo('001');

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
DEFINE cNumCreditoCrd 				 CHAR(20);
DEFINE cNumcredisolu		 		 CHAR(20);
DEFINE dSaldoAlCierreeCrd 			 DECIMAL(18,5);

DEFINE sNivelRiesgoAlto		 SMALLINT;
DEFINE sNivelRiesgoMedio	 SMALLINT;
DEFINE sNivelRiesgoBajo		 SMALLINT;

DEFINE cNumCte				CHAR(20);
DEFINE cStatusFinMes		CHAR(02);
DEFINE dMontoPagarInst		DECIMAL(18,2);
DEFINE dMontoPagarRepSic	DECIMAL(18,2);
DEFINE sAntAcreditadoInst	SMALLINT;
DEFINE sGveces1				SMALLINT;
DEFINE sGveces2				SMALLINT;
DEFINE sGveces3				SMALLINT;
DEFINE sBkatr				SMALLINT;
DEFINE cGveces				CHAR(07);
DEFINE dFechaInfo			DATE;
DEFINE dFechaInfoTabla		DATE;
DEFINE dPagoMinimo 			DECIMAL(18,2);
DEFINE dPagosRealizados1PeriodosAnt		DECIMAL(18,5);
DEFINE dSaldoCorte2PeriodosAnt			DECIMAL(18,5);
DEFINE dPagosRealizados2PeriodosAnt		DECIMAL(18,5);
DEFINE dSaldoCorte3PeriodosAnt			DECIMAL(18,5);
DEFINE dPagosRealizados3PeriodosAnt		DECIMAL(18,5);
DEFINE dSaldoCorte4PeriodosAnt			DECIMAL(18,5);
DEFINE dPagosRealizados4PeriodosAnt		DECIMAL(18,5);


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

          --UPDATE {+INDEX(sd_contproc idx_sd_contproc)} sd_contproc SET status_proc = "C", mensaje = "PROCESO CANCELADO"
          UPDATE sd_contproc SET status_proc = "C", mensaje = "PROCESO CANCELADO"
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

-- SET DEBUG FILE TO "/informix/macf/gencartconsumo.out";
-- TRACE ON;

LET cCodRet= '000';
LET cMensajeRet= 'El proceso de CALIFICACION DEL CIERRE se realizÃ³ correctamente';

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
LET cNumCreditoCrd = '';
LET cNumcredisolu = '';
LET dSaldoAlCierreeCrd = 0; 

LET sNivelRiesgoAlto = 0;
LET sNivelRiesgoMedio= 0;
LET sNivelRiesgoBajo = 0;

LET cNumCte				= '';
LET cStatusFinMes		= '';
LET dMontoPagarInst		= 0;
LET dMontoPagarRepSic	= 0;
LET sAntAcreditadoInst	= 0;
LET sGveces1			= 0;
LET sGveces2			= 0;
LET sGveces3			= 0;
LET sBkatr				= 0;
LET cGveces				= '';
LET dFechaInfo			= DATE(1); 
LET dFechaInfoTabla		= DATE(1); 

LET dPagoMinimo			= 0;
LET dPagosRealizados1PeriodosAnt	= 0;
LET dSaldoCorte2PeriodosAnt			= 0;
LET dPagosRealizados2PeriodosAnt	= 0;
LET dSaldoCorte3PeriodosAnt			= 0;
LET dPagosRealizados3PeriodosAnt	= 0;
LET dSaldoCorte4PeriodosAnt			= 0;
LET dPagosRealizados4PeriodosAnt	= 0;


-- Se obtiene la fecha hoy del sistema.
SELECT {+INDEX(sd_fechas idx_sdfechas)} a.fecha_hoy, prox_fecha, pri_dia_mes
   INTO dtFechaHoy, vprox_fecha, dtPriDiaMes 
   FROM bdicred:sd_fechas a
  WHERE a.empresa = pempresa;

--temporal solo para pruebas
--	let dtFechaHoy  = mdy('10','31','2019');
--	let vprox_fecha = mdy('11','01','2019');
--	let dtPriDiaMes = mdy('10','01','2019');
--temporal solo para pruebas

--Se calcula el factor de comparaciÃ³n para los crÃ©ditos que se dieron de alta entre el 21 y Ãºltimo dÃ­a del mes
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
       --UPDATE {+INDEX(sd_contproc idx_sd_contproc)} sd_contproc SET mensaje = "PROCESO YA EJECUTADO"
       UPDATE sd_contproc SET mensaje = "PROCESO YA EJECUTADO"
        WHERE empresa = pempresa    and
              proceso = "califcart" and
              fecha   = dtFechaHoy;

          LET cMensajeRet= 'El proceso ya fue ejecutado';
          RETURN cCodRet, cMensajeRet;
   else
      if vstatus_proc = "C" then
           --UPDATE {+INDEX(sd_contproc idx_sd_contproc)} sd_contproc SET status_proc = "I", mensaje = "EN PROCESO"
           UPDATE sd_contproc SET status_proc = "I", mensaje = "EN PROCESO"
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
    LET cMensajeRet= 'FALTA CONSTANTE ANTIGÃ¿EDAD PI';
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
   LET cMensajeRet= 'FALTA PORCENTAJE PAGO MÃNIMO';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dPorcUsoMin FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '10';

 IF dPorcUsoMin IS NULL THEN
   LET cCodRet= '000010';
   LET cMensajeRet= 'FALTA PORCENTAJE USO MÃNIMO';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dpiEI FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '11';

 IF dpiEI IS NULL THEN
   LET cCodRet= '000110';
   LET cMensajeRet= 'FALTA EXPOSICIÃ¿N AL MOMENTO DE INCUMPLIMIENTO';
   RETURN cCodRet, cMensajeRet;
 END IF;

 SELECT {+INDEX(sd_param_reservas idx_sd_param_reservas)} valor INTO dMeses FROM bdicred:sd_param_reservas where empresa = pEmpresa and cod_param= '12';

 IF dMeses IS NULL THEN
   LET cCodRet= '000120';
   LET cMensajeRet= 'FALTA NÃ¿MERO DE MESES';
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
   LET cMensajeRet= 'FALTA CONSTANTE COMPARACIÃ¿N PARA PI';
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
	   
  --A.L.L.
	insert into paso1
    SELECT a.num_credito,a.credito_externo
      FROM bdicred:sd_maecredcont a
      LEFT OUTER JOIN bdicred:sd_hist_reserva b on a.empresa = b.empresa AND a.num_credito = b.num_credito AND b.fecha_corte = mdy(month(a.fecha),20,year(a.fecha))
     WHERE a.empresa = pEmpresa
       AND a.fecha = dtFechaHoy
       AND b.fecha_cierre IS NULL
       AND a.num_credito matches '81*';
  --End A.L.L.
 /*RSS 24/02/2017
   insert into paso1  ---NVO MACF 20160621
    SELECT a.num_credito,a.credito_externo
      FROM bdicred:sd_maecredcont a
      LEFT OUTER JOIN bdicred:sd_hist_reserva b on a.empresa = b.empresa AND a.num_credito = b.num_credito AND b.fecha_corte = mdy(month(a.fecha),15,year(a.fecha))
     WHERE a.empresa = pEmpresa
       AND a.fecha = dtFechaHoy
       AND b.fecha_cierre IS NULL
       AND a.num_credito matches '78*';  ---NVO MACF
*/--RSS 24/02/2017

	insert into paso1
    SELECT a.num_credito,a.credito_externo
      FROM bdicred:sd_maecredcont a
      LEFT OUTER JOIN bdicred:sd_hist_reserva b on a.empresa = b.empresa AND a.num_credito = b.num_credito AND b.fecha_corte = mdy(month(a.fecha),18,year(a.fecha))
     WHERE a.empresa = pEmpresa
       AND a.fecha = dtFechaHoy
       AND b.fecha_cierre IS NULL
       AND a.num_credito matches '85*';
	   
    create unique index inx_paso1 on paso1(num_credito);
    update statistics medium for table paso1;

    delete from  paso1 where num_credito in (select num_credito from bdicred:sd_hist_reserva where empresa = pEmpresa and fecha_corte = dtFechaHoy);

FOREACH WITH HOLD

    -- Se obtienen los crÃ©ditos calificados con corte al 20.
    SELECT a.num_credito, CASE WHEN b.num_periodos IS NULL THEN 0 ELSE b.num_periodos END, CASE WHEN b.pagos_realizados IS NULL THEN 0 ELSE b.pagos_realizados END,
           CASE WHEN b.impagos_consecutivos IS NULL THEN 0 ELSE b.impagos_consecutivos END, CASE WHEN b.impagos_historicos IS NULL THEN 0 ELSE b.impagos_historicos END,
           b.meses_antiguedad,a.fecha_apertura,
           a.periodo_plazo, a.num_producto, a.sucursal, a.divisa, a.status_cred,
           (b.probabilidad_incumplimiento/100),(b.severidad_perdida/100), b.limite_credito, b.antecedente_buro,
           NVL(c.sdo_cap_insoluto,0), NVL(b.saldo_corte,0),
           d.dia_corte,nvl(reserva_calif_mes_anterior,0),
           (porcentaje_uso/100), (porcentaje_pago/100), b.fecha_cierre,
           grado_riesgo_bancoppel,nvl(c.mto_venc_tra_int,0),nvl(c.monto_otorgado,0), b.fecha_corte,aa.credito_externo,
		   b.saldo_corte2,b.saldo_corte3,b.saldo_corte4,b.pagos_realizados1,b.pagos_realizados2,b.pagos_realizados3,b.pagos_realizados4,a.numcte
      INTO cNumCredito, iCuotasVdas, dPagos, dImpagosCons, dImpagosHist, dMesesAntiguedad,
           dtFechaApertura,cPeriodicidad, vProducto, vSucursal, vDivisa, vStatusCred,
           dPI, dSP,dLimiteCredito,dEvaBuro,
           dEndeudamientoTotCierre,dEndeudamientoTotCorte,
           dDiaCorte,dReservaCalifMesAnterior,
           dPorUso, dPorPago, dtFechacierre,
           dgradoriesgobancoppel,vtotal_capitalizado,dLimiteCreditoNvo,dtFechacorte,cCreditoExterno,
		   dSaldoCorte2PeriodosAnt,dSaldoCorte3PeriodosAnt,dSaldoCorte4PeriodosAnt,dPagosRealizados1PeriodosAnt,dPagosRealizados2PeriodosAnt,dPagosRealizados3PeriodosAnt,dPagosRealizados4PeriodosAnt,cNumCte
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
       AND trim(a.campo_trab3) <> 'BAJA' --No se califican los crÃ©ditos que sufren baja en la cartera 28/02/2014


       IF dgradoriesgobancoppel = 'PS' or vProducto = '6600' or dtFechacorte = dtFechaHoy THEN 
           CONTINUE FOREACH;
       END IF;

      IF dLimiteCredito IS NULL THEN LET dLimiteCredito = dLimiteCreditoNvo; END IF;
      IF dLimiteCredito <= 0 THEN  LET dLimiteCredito = 0.01; END IF;
	  
--A.L.L.07/08/2015
--SE VALIDA QUE EL CREDITO TENGA RELACION CON PRODUCTO DE CREDISOLUCION 
      LET cNumCreditoCrd = '';
	  SELECT limit 1 a.num_sol_prestamo
	    INTO cNumCreditoCrd
	    FROM bdicred:sd_promocion_credito a
	   INNER JOIN bdicred:sd_maecredcrd b on (b.empresa = a.empresa and b.num_credito = a.num_sol_prestamo and b.status_cred IN ('AA','E1'))
	   WHERE a.empresa = pEmpresa
         AND a.num_credito = cNumCredito;

      IF cNumCreditoCrd IS NULL OR cNumCreditoCrd = '' THEN LET cNumCreditoCrd = ''; END IF;

	  LET dSaldoAlCierreeCrd = 0;
	  IF cNumCreditoCrd != '' THEN
  
		SELECT sum(c.sdo_cap_insoluto)
			INTO dSaldoAlCierreeCrd
			FROM bdicred:sd_promocion_credito a
		INNER JOIN bdicred:sd_maecredcrd b on (b.empresa = a.empresa and b.num_credito = a.num_sol_prestamo and b.status_cred IN ('AA','E1'))
		INNER JOIN bdicred:sd_maesdoscontcrd c on c.fecha = dtFechaHoy and c.empresa = a.empresa and c.num_credito = a.num_sol_prestamo
			WHERE a.empresa = pEmpresa
			AND a.num_credito = cNumCredito;

        IF dSaldoAlCierreeCrd IS NULL OR dSaldoAlCierreeCrd = '' THEN LET dSaldoAlCierreeCrd = 0; END IF;

        LET dEndeudamientoTotCierre = dEndeudamientoTotCierre + dSaldoAlCierreeCrd;

      END IF;
/*
      IF dLimiteCredito IS NULL OR dLimiteCredito <= 0 THEN  ---??????
          LET dLimiteCredito = 0.01;
      END IF;
*/	  
		
--     IF vcontador_insert = 0 THEN
--       LET cBegin= 'S';
       BEGIN WORK;
--     END IF;
/*-- RQM 07 097-2 ADDENDUM CalificaciÃ³n CrÃ©ditos Revolventes	 
     IF dgradoriesgobancoppel='IN' or dgradoriesgobancoppel = 'A1' THEN
        UPDATE {+INDEX(sd_hist_reserva fecha_corte)} "informix".sd_hist_reserva
           SET fecha_cierre = dtFechaHoy,
               saldo_cierre = dEndeudamientoTotCierre,
               exposicion_incumplimiento = (CASE WHEN dEndeudamientoTotCierre < 0 THEN 0 ELSE dEndeudamientoTotCierre END)
         WHERE empresa = pEmpresa
           AND fecha_corte = mdy(month(dtFechaHoy),dDiaCorte,year(dtFechaHoy))
           AND num_credito = cNumCredito;

		IF dgradoriesgobancoppel = 'A1' THEN
			LET vNvoPeriodo= 0;
		ELIF dgradoriesgobancoppel = 'IN' THEN
			LET vNvoPeriodo= 9;
		END IF;

-- Actualiza Maestro de Credito Central
         UPDATE {+INDEX(sd_maecred idx_idx_maecredb)} bdicred:sd_maecred
            SET calificacion_riesgo = cGradoRiesgoAux -- B1 cambia por A1
          WHERE empresa = pempresa
            AND num_credito = cNumCredito;
--rss se trae este registro contable del primer proceso de calificaciÃ³n

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

--rss se trae este registro contable del primer proceso de calificaciÃ³n
        LET sExisten = 0;             LET iContInteres = 0;            LET vtotal_capitalizado = 0;        LET vImporteReservaBuroCC = 0;        
        LET vmonto_capitalizado = 0;  LET cNumCredito ='';             LET iCuotasVdas =0;                 LET dPagos =0;                      
        LET dImpagosCons =0;          LET dImpagosHist =0;             LET dMesesAntiguedad =0;            LET dtFechaApertura =date(0);         
        LET cPeriodicidad ='';        LET vProducto ='';               LET vSucursal ='';                  LET vDivisa ='';        
        LET vStatusCred ='';          LET dPI =0;                      LET dSP =0;                         LET dLimiteCredito =0;
        LET dEvaBuro ='';             LET dEndeudamientoTotCierre =0;  LET dEndeudamientoTotCorte =0;      LET dDiaCorte =0;
        LET dPorUso =0;               LET dReservaCalifMesAnterior =0; LET dEndeudTotCierreSinIntereses =0; LET cGradoRiesgoAux = 'A1';
		LET cGradoRiesgo = 0;		  LET sNivelRiesgoAlto = 0;		   LET sNivelRiesgoMedio= 0;			LET sNivelRiesgoBajo = 0;

--        LET vcontador_insert = vcontador_insert + 1;
        COMMIT WORK;
        CONTINUE FOREACH;
     END IF;
*/-- RQM 07 097-2 ADDENDUM CalificaciÃ³n CrÃ©ditos Revolventes	 

    IF dMesesAntiguedad IS NULL THEN
-- RQM 07 097-2 ADDENDUM CalificaciÃ³n CrÃ©ditos Revolventes
		select fecha_info,meses_desde_primer_cred_banco,bkatr,monto_pagar_propios,monto_pagar_otros,gveces
		  into dFechaInfoTabla,sAntAcreditadoInst,sBkatr,dMontoPagarInst,dMontoPagarRepSic,cGveces
		from bdiburo:br_variables_cc
		where fecha_info = dFechaInfo
		and num_credito  = cNumCredito;

		LET dPagosnunca = 0;
		LET dPagoMinimo = 0;
		
	IF sAntAcreditadoInst 	IS NULL OR sAntAcreditadoInst = '' 	THEN LET sAntAcreditadoInst = 0; 	END IF;
	IF sBkatr 				IS NULL OR sBkatr = '' 				THEN LET sBkatr = 0; 				END IF;
	IF dMontoPagarInst 		IS NULL OR dMontoPagarInst = '' 	THEN LET dMontoPagarInst = 0; 		END IF;
	IF dMontoPagarRepSic 	IS NULL OR dMontoPagarRepSic = '' 	THEN LET dMontoPagarRepSic = 0; 	END IF;
	IF cGveces 				IS NULL OR cGveces = '' 			THEN LET cGveces	= ''; 			END IF;
		
	IF sAntAcreditadoInst = 0 THEN
        LET iANT = round((dtFechaHoy - dtFechaApertura)/dDiasXMes,2);
	ELSE
		LET iANT = sAntAcreditadoInst;
	END IF;
		
--        LET iANT = round((dtFechaHoy - dtFechaApertura)/dDiasXMes,2);

-- RQM 07 097-2 ADDENDUM CalificaciÃ³n CrÃ©ditos Revolventes
		 IF		iANT <= 42 AND dLimiteCredito <= 15000 THEN 
				LET sNivelRiesgoAlto = 1;
		 ELIF  (iANT <= 42 AND dLimiteCredito > 40000) OR (iANT > 42 AND dLimiteCredito <= 15000) OR (dLimiteCredito > 15000 AND dLimiteCredito <= 40000) THEN
				LET sNivelRiesgoMedio = 1;
		 ELIF	iANT > 42 AND dLimiteCredito > 40000 THEN
				LET sNivelRiesgoBajo = 1;
		 END IF;		

-- RQM 07 097-2 ADDENDUM CalificaciÃ³n CrÃ©ditos Revolventes
--Se determinan los GVeces
		IF cGveces = '' THEN
			IF dPagoMinimo <= 640 THEN 
				LET sGveces1 = 1;
				LET sGveces2 = 0;
				LET sGveces3 = 0;
			ELIF dPagoMinimo > 640 THEN 
				LET sGveces1 = 0;
				LET sGveces2 = 1;
				LET sGveces3 = 0;
			END IF;
		ELSE
			IF cGveces = 'GVeces1' THEN
				LET sGveces1 = 1;
				LET sGveces2 = 0;
				LET sGveces3 = 0;
			ELIF cGveces = 'GVeces2' THEN
				LET sGveces1 = 0;
				LET sGveces2 = 1;
				LET sGveces3 = 0;
			ELIF cGveces = 'GVeces3' THEN
				LET sGveces1 = 0;
				LET sGveces2 = 0;
				LET sGveces3 = 1;
			END IF;
		END IF;

--Se determinan los BKATR
		LET dPorUso = dEndeudamientoTotCierre / dLimiteCredito;
		LET dPorPago = 0;
		LET iHIST = 0;
		LET iACT = 0;
		IF sBkatr = 0 AND iACT = 0 THEN 
			LET sBkatr = 13; 
		ELIF iACT < 1 THEN
			LET sBkatr = 10; 
		ELSE	
			LET sBkatr = 0;
		END IF;
	
--Se calcula PI (Probabilidad de Incumplimiento)
		-- Se inicializan 
		LET dSaldoCorte2PeriodosAnt = 0;
		LET dSaldoCorte3PeriodosAnt = 0;
		LET dSaldoCorte4PeriodosAnt = 0;
		LET dPagoRealizado = 0;
		LET dPagosRealizados1PeriodosAnt = 0;
		LET dPagosRealizados2PeriodosAnt = 0;
		LET dPagosRealizados3PeriodosAnt = 0;		
		LET dPagosRealizados4PeriodosAnt = 0;		
		
		IF iACT >= dConsComPI THEN -- Valor 4
			LET dPI = dPIdefaul; --Valor 1
		ELIF (dEndeudamientoTotCorte <= 0 AND dSaldoCorte2PeriodosAnt <= 0 AND dSaldoCorte3PeriodosAnt <= 0 AND dSaldoCorte4PeriodosAnt <= 0) AND 
			   (dPagoRealizado = 0 AND dPagosRealizados1PeriodosAnt = 0 AND dPagosRealizados2PeriodosAnt = 0 AND dPagosRealizados3PeriodosAnt = 0) THEN
				LET dPI = 0.0418;
		ELIF (dEndeudamientoTotCorte <= 0 AND dSaldoCorte2PeriodosAnt <= 0 AND dSaldoCorte3PeriodosAnt <= 0 AND dSaldoCorte4PeriodosAnt <= 0) AND 
				 (dPagoRealizado > 0 OR dPagosRealizados1PeriodosAnt > 0 OR dPagosRealizados2PeriodosAnt > 0 OR dPagosRealizados3PeriodosAnt > 0) THEN
				IF sNivelRiesgoAlto = 1 THEN
					LET dPI = 0.0466;
				ELIF sNivelRiesgoMedio = 1 THEN
					LET dPI = 0.0344;
				ELIF sNivelRiesgoBajo = 1 THEN
					LET dPI = 0.0218;
				END IF;	
		ELIF dEndeudamientoTotCorte <= 0 AND (dSaldoCorte2PeriodosAnt > 0 OR dSaldoCorte3PeriodosAnt > 0 OR dSaldoCorte4PeriodosAnt > 0) THEN
				IF sNivelRiesgoAlto = 1 THEN
					LET dPI = 0.0870;
				ELIF sNivelRiesgoMedio = 1 THEN
					LET dPI = 0.0579;
				ELIF sNivelRiesgoBajo = 1 THEN
					LET dPI = 0.0312;
				END IF;	
	--		LET dPI = (1/(1 + EXP(-(dConsPI + (dConsACT * iACT) + (dConsHIST * iHIST) + (dConsANT * iANT) + (dConsPORPAGO * dPorPago) + (dConsPORUSO * dPorUso)))));
		ELIF iACT < dConsComPI THEN -- Valor 4
				LET dPI = (1/(1 + EXP((2.1859 - (0.7864 * iACT) - (0.3978 * iHIST) - (0.8731 * dPorUso) + (0.4112 * dPorPago) - (0.2912 * sNivelRiesgoAlto) + (0.0294 * sNivelRiesgoMedio) + (0.2618 * sNivelRiesgoBajo) + (0.1567 * sGveces1) - (0.0238 * sGveces2) - (0.1329 * sGveces3) + (0.0855 * sBkatr)))));
		END IF;

	-- Se calcula SP (Severidad de la PÃ©rdida)
/*     IF iACT < dImpPerConACT THEN
        LET dSP = dConsSPMenor;
     ELSE
        LET dSP = dConsSPMayor;
     END IF;*/

		IF iACT <= 4 THEN
			LET dSP = dConsSPMenor; --Valor 0.75
		END IF;
		IF (dEndeudamientoTotCorte <= 0 AND dSaldoCorte2PeriodosAnt <= 0 AND dSaldoCorte3PeriodosAnt <= 0 AND dSaldoCorte4PeriodosAnt <= 0) AND 
			   (dPagoRealizado = 0 AND dPagosRealizados1PeriodosAnt = 0 AND dPagosRealizados2PeriodosAnt = 0 AND dPagosRealizados3PeriodosAnt = 0) THEN
				LET dSP = 0.67;
		END IF;
		IF (dEndeudamientoTotCorte <= 0 AND dSaldoCorte2PeriodosAnt <= 0 AND dSaldoCorte3PeriodosAnt <= 0 AND dSaldoCorte4PeriodosAnt <= 0) AND 
				 (dPagoRealizado > 0 OR dPagosRealizados1PeriodosAnt > 0 OR dPagosRealizados2PeriodosAnt > 0 OR dPagosRealizados3PeriodosAnt > 0) THEN
				LET dSP = 0.70;
		END IF;
		IF dEndeudamientoTotCorte <= 0 AND (dSaldoCorte2PeriodosAnt > 0 OR dSaldoCorte3PeriodosAnt > 0 OR dSaldoCorte4PeriodosAnt > 0) THEN
				LET dSP = 0.70;
		END IF;
		IF   iACT > 4 AND iACT <= 5 THEN LET dSP = 0.77;
		ELIF iACT > 5 AND iACT <= 6 THEN LET dSP = 0.80;
		ELIF iACT > 6 AND iACT <= 7 THEN LET dSP = 0.82;
		ELIF iACT > 7 AND iACT <= 8 THEN LET dSP = 0.86;
		ELIF iACT > 8 AND iACT <= 9 THEN LET dSP = 0.90;
		ELIF iACT > 9 AND iACT <= 10 THEN LET dSP = 0.92;
		ELIF iACT > 10 AND iACT <= 11 THEN LET dSP = 0.96;
		ELIF iACT > 11 THEN LET dSP = 1; END IF;

-- RQM 07 097-2 ADDENDUM CalificaciÃ³n CrÃ©ditos Revolventes	 		
		 
        
        if vProducto = '7000' then
    -- Se obtiene el antecedente de BurÃ³
            SELECT evalua_cc
              INTO dEvaBuro
              FROM bdisolic:ss_resum_scor_fin
             WHERE empresa = pempresa
               AND num_solicitud = cCreditoExterno;
    -- Se obtiene la lÃ­nea autorizada
            --SELECT {+INDEX(bdisolic:ss_solicitudes empsol)} nvl(monto_solicitado,0)
              SELECT nvl(monto_solicitado,0)
              INTO dLineaAutorizada
              FROM bdisolic:ss_solicitudes
             WHERE empresa = pempresa
               AND num_solicitud = cCreditoExterno;
        else
    -- Se obtiene el antecedente de BurÃ³
            SELECT evalua_cc
              INTO dEvaBuro
              FROM bdisolic:ss_resum_scor_fin
             WHERE empresa = pempresa
               AND num_solicitud = cNumCredito;
    -- Se obtiene la lÃ­nea autorizada
            --SELECT {+INDEX(bdisolic:ss_solicitudes empsol)} nvl(monto_solicitado,0)
            SELECT nvl(monto_solicitado,0)
              INTO dLineaAutorizada
              FROM bdisolic:ss_solicitudes
             WHERE empresa = pempresa
               AND num_solicitud = cNumCredito;
        end if;
/*
    -- Se obtiene el lÃ­mite de crÃ©dito
        SELECT nvl(monto_otorgado,0)
          INTO dLimiteCredito
          FROM bdicred:sd_maesdoscont
--          FROM bdicred:sd_maesdos
         WHERE fecha = dtFechaHoy
           AND empresa = pempresa
           AND num_credito = cNumCredito;
*/

/*-- RQM 07 097-2 ADDENDUM CalificaciÃ³n CrÃ©ditos Revolventes
        LET dPorUso  = 0; ---- para clientes nuevos no se calcula la variable
        LET dPorPago = 0; ---- para clientes nuevos no se calcula la variable
        LET dSP = dConsSPMenor; ---- para clientes nuevos no existen impagos consecutivos
        LET dPI = 0; ---- para clientes nuevos no se calcula la variable*/
-- RQM 07 097-2 ADDENDUM CalificaciÃ³n CrÃ©ditos Revolventes
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
									and capital_status in ('5','2','6')
                                    -- IFRS and capital_status in ('5','2')
                                    and interes_debe = 0 and capital_debe > 0)
           AND mov.num_credito = cNumCredito
           AND mov.codigo_fun = '605'
           and mov.codigo_ref = 2
           AND mov.reversado = 'N';

           IF vtotal_capitalizado IS NULL THEN LET vtotal_capitalizado = 0; END IF;
     END IF;
*/
	-- IFRS IF vStatusCred != 'BT' THEN LET vtotal_capitalizado = 0; END IF;
    IF vStatusCred NOT IN ('BT','E3') THEN LET vtotal_capitalizado = 0; END IF;

    IF vtotal_capitalizado IS NULL THEN LET vtotal_capitalizado = 0; END IF;
--Se restan los intereses vencidos del saldo al cierre
    LET dEndeudTotCierreSinIntereses = dEndeudamientoTotCierre - vtotal_capitalizado;

--Se calcula EI
-- Si la resta del saldo y los intereses vencidos es menor o igual a cero, el saldo es igual al endeudamiento del cliente 
    -- IFRS IF dEndeudTotCierreSinIntereses <= 0 and vStatusCred = 'BT' THEN
	IF (dEndeudTotCierreSinIntereses <= 0) THEN
										
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
/*-- RQM 07 097-2 ADDENDUM CalificaciÃ³n CrÃ©ditos Revolventes
    IF dEndeudTotCierreSinIntereses <= 0 THEN
        LET dEI = 0;
    ELSE
        LET dEI = dEndeudTotCierreSinIntereses;
    END IF;*/

	LET dEI = dEndeudTotCierreSinIntereses;
	
	IF (dEndeudamientoTotCorte <= 0 AND dSaldoCorte2PeriodosAnt <= 0 AND dSaldoCorte3PeriodosAnt <= 0 AND dSaldoCorte4PeriodosAnt <= 0) AND 
		(dPagos = 0 AND dPagosRealizados1PeriodosAnt = 0 AND dPagosRealizados2PeriodosAnt = 0 AND dPagosRealizados3PeriodosAnt = 0) THEN
		LET dEI = dEndeudTotCierreSinIntereses + 1 * (dLimiteCredito - dEndeudTotCierreSinIntereses);	-- 100 %
	ELIF (dEndeudamientoTotCorte <= 0 AND dSaldoCorte2PeriodosAnt <= 0 AND dSaldoCorte3PeriodosAnt <= 0 AND dSaldoCorte4PeriodosAnt <= 0) AND 
		(dPagos > 0 OR dPagosRealizados1PeriodosAnt > 0 OR dPagosRealizados2PeriodosAnt > 0 OR dPagosRealizados3PeriodosAnt > 0) THEN
		LET dEI = dEndeudTotCierreSinIntereses + 0.4267 * (dLimiteCredito - dEndeudTotCierreSinIntereses); -- 42.67 %
	ELIF (dEndeudamientoTotCorte <= 0) AND 
		(dSaldoCorte2PeriodosAnt > 0 OR dSaldoCorte3PeriodosAnt > 0 OR dSaldoCorte4PeriodosAnt > 0) THEN
		LET dEI = dEndeudTotCierreSinIntereses + 0.5181 * (dLimiteCredito - dEndeudTotCierreSinIntereses); -- 51.81 %
	END IF;	
	
	IF dEI < 0 THEN LET dEI = 0; END IF;
-- RQM 07 097-2 ADDENDUM CalificaciÃ³n CrÃ©ditos Revolventes

--Se calcula la reserva de riesgos crediticios
-- RQM 07 097-2 ADDENDUM CalificaciÃ³n CrÃ©ditos Revolventes
/*    IF (dEndeudTotCierreSinIntereses <= 0 AND dPagos = 0 and dEndeudamientoTotCorte <= 0) OR (dtFechaApertura > mdy(month(dtFechaHoy),dDiaCorte,year(dtFechaHoy)))THEN 
       LET dPorcentajeReserva = dPorUsoMinCtesNunca; -- 2.68%
       LET dResCalificacion = dPorcentajeReserva * (dLimiteCredito + dEndeudamientoTotCorte); ----Se omite el monto ya que el monto al inicio del periodo es cero???
       LET cGradoRiesgo = cGradoRiesgoAux; --B1 cambia por A1
    ELSE
*/-- RQM 07 097-2 ADDENDUM CalificaciÃ³n CrÃ©ditos Revolventes	
        LET dPorcentajeReserva = dPI * dSP;
        LET dResCalificacion = dPorcentajeReserva * dEI;
            SELECT {+index (sd_grado_riesgo sd_grado_riesgo_inx1)} a.grado_riesgo
              INTO cGradoRiesgo
              FROM bdicred:sd_grado_riesgo a
             WHERE empresa = pEmpresa
               AND tipo = '0'
               AND (round(dPorcentajeReserva * 100,2) >= a.porcentaje_min
               AND round(dPorcentajeReserva * 100,2) <= a.porcentaje_max);
--    END IF; -- RQM 07 097-2 ADDENDUM CalificaciÃ³n CrÃ©ditos Revolventes	

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
-- Se almacena la informaciÃ³n correspondiente al calculo de la reservas preventivas.
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
             porcentaje_reserva_edo_resultados = vPorcentajeEdoResultados*100,
			 status_fin_mes				  = vStatusCred,
			 saldo_cierre_credisolucion	  = dSaldoAlCierreeCrd
       WHERE empresa = pEmpresa
         AND fecha_corte = mdy(month(dtFechaHoy),dDiaCorte,year(dtFechaHoy))
         AND num_credito = cNumCredito;
   ELSE
         -- Se almacena la informaciÃ³n correspondiente al calculo de la reservas preventivas para crÃ©ditos aperturados despuÃ©s del 20.
      INSERT INTO informix.sd_hist_reserva 
		(empresa,fecha_corte,num_credito,fecha_cierre,grado_riesgo,fecha_apertura,antecedente_buro,status_cred,linea_autorizada,limite_credito,
		interes_cred_ven,saldo_corte,saldo_cierre,pago_minimo,pagos_realizados,reserva_int_cred_ven,reserva_buro,reserva_calificacion,porcentaje_reserva,
		meses_antiguedad,probabilidad_incumplimiento,severidad_perdida,exposicion_incumplimiento,impagos_consecutivos,impagos_historicos,porcentaje_pago,
		porcentaje_uso,num_periodos,exposicion_inc_gradual,grado_riesgo_gradual,reserva_calificacion_gradual,porcentaje_reserva_gradual,reserva_buro_gradual,
		reserva_int_cred_ven_gradual,reserva_calif_mes_anterior,grado_riesgo_bancoppel,grado_riesgo_edo_resultados,reserva_edo_resultados,porcentaje_reserva_edo_resultados,
		numcte,cta_credisolucion,status_fin_mes,saldo_corte2,saldo_corte3,saldo_corte4,pagos_realizados1,pagos_realizados2,pagos_realizados3,pagos_realizados4,
		saldo_corte_credisolucion,saldo_cierre_credisolucion,monto_pagar_inst,monto_pagar_rep_sic,ant_acreditado_inst,grado_riesgo_alto,grado_riesgo_medio,grado_riesgo_bajo,gveces1,gveces2,gveces3,bkatr)
		VALUES 
		(pEmpresa,dtFechaHoy,cNumCredito,dtFechaHoy,cGradoRiesgo,dtFechaApertura,dEvaBuro,vStatusCred,dLineaAutorizada,dLimiteCredito,
		vtotal_capitalizado,0,dEndeudamientoTotCierre,0,dPagoRealizado,vtotal_capitalizado,vImporteReservaBuroCC,dResCalificacion,dPorcentajeReserva * 100,
		ROUND(iANT),dPI * 100,dSP * 100,dEI,iACT,iHIST,dPorPago * 100,
		dPorUso * 100,0,dEI,cGradoRiesgoGradual,vReservaGradual,vPorcentajeGradual*100,dReservaBuroGradual,
		dReservaIntCredVenGradual,0,cGradoRiesgoBancoppel,cGradoRiesgoEdoResultados,dReservaEdoResultados,vPorcentajeEdoResultados*100,
		cNumCte,cNumCreditoCrd,vStatusCred,dSaldoCorte2PeriodosAnt,dSaldoCorte3PeriodosAnt,dSaldoCorte4PeriodosAnt,dPagosRealizados1PeriodosAnt,dPagosRealizados2PeriodosAnt,dPagosRealizados3PeriodosAnt,dPagosRealizados4PeriodosAnt,
		0,0,dMontoPagarInst,dMontoPagarRepSic,sAntAcreditadoInst,sNivelRiesgoAlto,sNivelRiesgoMedio,sNivelRiesgoBajo,sGveces1,sGveces2,sGveces3,sBkatr);
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

-- Reservas por Riesgos Operativos (Clientes con mal Antecedentes en BurÃ³ o CÃ­rculo)
    IF dEvaBuro = '1' THEN
        LET vImporteReservaBuroCC = dResCalificacion * dPorResSic;
--        LET vImporteReservaBuroCC = vImporteReservaBuroCC * dGradual;
        LET vImporteReservaBuroCC = vImporteReservaBuroCC;
        LET dReservaBuroGradual   = vImporteReservaBuroCC;

    IF dMesesAntiguedad IS NOT NULL THEN
       -- Se almacena la informaciÃ³n correspondiente a la reserva de BurÃ³
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

-- Reservas por Intereses devengados sobre crÃ©ditos vencidos.
     LET vmonto_capitalizado = 0;
     LET iContInteres = 0;
     LET vImporteReservaBuroCC = 0;
     LET dReservaBuroGradual = 0;

     -- IFRS IF vStatusCred = 'BT' THEN
--	 IF vStatusCred = 'BT' OR (vStatusCred in ('E2','E3') and (NVL(iAtr_Act_ifrs, -1) >= 2)) THEN
							  
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
--     END IF;

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
	
	
	LET sNivelRiesgoAlto = 0;
	LET sNivelRiesgoMedio= 0;
	LET sNivelRiesgoBajo = 0;

	LET cNumCte				= '';
	LET cStatusFinMes		= '';
	LET dMontoPagarInst		= 0;
	LET dMontoPagarRepSic	= 0;
	LET sAntAcreditadoInst	= 0;
	LET sGveces1			= 0;
	LET sGveces2			= 0;
	LET sGveces3			= 0;
	LET sBkatr				= 0;
	LET cGveces				= '';
	LET dFechaInfo			= DATE(1); 
	LET dFechaInfoTabla		= DATE(1); 
	
	LET dPagoMinimo			= 0;
	LET dPagosRealizados1PeriodosAnt	= 0;
	LET dSaldoCorte2PeriodosAnt			= 0;
	LET dPagosRealizados2PeriodosAnt	= 0;
	LET dSaldoCorte3PeriodosAnt			= 0;
	LET dPagosRealizados3PeriodosAnt	= 0;
	LET dSaldoCorte4PeriodosAnt			= 0;
	LET dPagosRealizados4PeriodosAnt	= 0;

	
	
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

--UPDATE {+INDEX(sd_contproc idx_sd_contproc)} sd_contproc
 UPDATE sd_contproc
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


-- Se genera reporte de la calificaciÃ³n para mostrar por SIF
/*Se elimina a solicitud de soporte para la reduciÃ³n de tiempo 
  EXECUTE PROCEDURE bdicred:"informix".sp_genera_reporte_calificacion(pEmpresa, dtFechaHoy) INTO cCodRet,cMensajeRet;

  IF cCodRet <> '000000' THEN
     LET cMensajeRet = 'Se generÃ³ un error en el proceso de generaciÃ³n del reporte de calificaciÃ³n';
     RETURN cCodRet, cMensajeRet;
  END IF;
*/--Se elimina a solicitud de soporte para la reduciÃ³n de tiempo 
-- Se genera un archivo plano con la informaciÃ³n de reservas que inserta en la tabla sd_hist_reserva.
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

  let vsql = "cp /resplogifx/burodecredito/calificacion.unl /resplogifx/burodecredito/sd_hist_reserva"|| vDia || vMes || vAnio ||".txt ";
  system vsql;

  let vsql = "gzip /resplogifx/burodecredito/sd_hist_reserva"|| vDia || vMes || vAnio ||".txt ";
  system vsql;

  let vsql = "rm /resplogifx/burodecredito/calificacion.unl ";
  system vsql;
*/
LET cMensajeRet= 'El proceso de CALIFICACION DEL CIERRE se realizÃ³ correctamente';

RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para el calculo',
'de la reserva a fin de mes',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 06/MARZO/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_actualizacvlcobranzacte(pempresa     CHAR(3), pfechahoy    DATE)	

RETURNING CHAR(6);
								

--     VARIABLES CONTROL DE ERRORES     --
DEFINE cod_ret             		CHAR(6);
DEFINE sql_err             		INTEGER;
DEFINE v_cod_ret_otro			CHAR(6);

DEFINE v_cl_cobranza            CHAR(60);	   --Clave de Cobranza			
DEFINE v_periodo_tc_ini   		DATE;			--Periodo_tc_Ini
DEFINE v_periodo_tc_fin   		DATE;			--Periodo_tc_Fin
DEFINE v_fecha_corte_tc   		DATE;			--Fecha_Corte
DEFINE v_dias_periodo_tc 		INTEGER;		--Dias_Periodo_tc
DEFINE v_periodo_anterior  	    DATE;			--Fecha Periodo Anterior
DEFINE v_periodo_prox  	        DATE;			--Fecha Periodo Anterior

---DECLARACION DE VARIABLES PARA IDENTIFICAR PRESTAMOS MAS VENCIDO Y/O MAS ANTIGUO
DEFINE cNumcte				 CHAR(20);
DEFINE cStatuscred			 CHAR(2);
DEFINE cNumCredVenc          CHAR(20);
DEFINE cNumCredAux			 CHAR(20);
DEFINE cStatuscredAux        CHAR(2);							   
DEFINE dCapital_vencido      DECIMAL(14,2);  --Capital_Ven_tc
DEFINE dInteres_vencido      DECIMAL(14,2);  --Interes_Ven_tc
DEFINE dIva_vencido          DECIMAL(14,2);  --Iva_Interes_Ven_tc
DEFINE dMoratorio            DECIMAL(14,2);  --Moratorios
DEFINE dIva_moratorio        DECIMAL(14,2);  --iva_Moratorios
DEFINE dMontoVencidoMin      DECIMAL(14,2);  --Monto Vencido Min
DEFINE dMontoVencidoMax		 DECIMAL(14,2);  --Monto Vencido Max
DEFINE cMtoVen		 		 DECIMAL(18,2);

--INICIALIZACION DE VARIABLES
--	VARIABLES CONTROL DE ERRORES     --
LET cod_ret                  = "000000";
LET sql_err                  = 0;
LET v_cod_ret_otro           = "000000";
LET v_periodo_tc_ini   		  = " ";
LET v_periodo_tc_fin   		  = " ";
LET v_fecha_corte_tc   		  = " ";
LET v_dias_periodo_tc 		  = 0;
LET v_periodo_anterior   	  = DATE(1);
LET v_periodo_prox            = DATE(1);
LET v_cl_cobranza  ='';
--- INICIO DE VARIABLES PARA IDENTIFICAR PRESTAMOS MAS VENCIDO Y/O MAS ANTIGUO	
LET cNumcte				 = '';
LET cStatuscred			 = '';
LET cNumCredVenc         = '';
LET cNumCredAux          = '';
LET cStatuscredAux		 = '';
LET dCapital_vencido     = 0;  --Capital_Ven_tc
LET dInteres_vencido     = 0;  --Interes_Ven_tc
LET dIva_vencido         = 0;  --Iva_Interes_Ven_tc
LET dMoratorio           = 0;  --Moratorios
LET dIva_moratorio       = 0;  --iva_Moratorios	
LET dMontoVencidoMin     = 0;  --Monto Vencido Min
LET dMontoVencidoMax	 = 0;  --Monto Vencido Max			
LET cMtoVen				 = 0;

SET ISOLATION TO DIRTY READ;
--SET LOCK MODE TO WAIT 3;
--SET DEBUG FILE TO "/informix/Malena/sp_actualizacvlcobranzacte.out";
--TRACE ON;
BEGIN

  ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
         LET cod_ret = sql_err;
         RETURN cod_ret;
     END IF
  END EXCEPTION WITH RESUME;

	EXECUTE PROCEDURE sp_mes_siguiente(pfechahoy ,-1,DAY(pfechahoy))
				 INTO v_cod_ret_otro, v_periodo_anterior, v_dias_periodo_tc;

	IF v_cod_ret_otro <> "000" AND cod_ret = "000000" THEN
	  LET cod_ret = v_cod_ret_otro;
	END IF;
	
	LET cod_ret = '000000';

	LET v_dias_periodo_tc = (v_dias_periodo_tc * -1);

    --     OBTENGO EL PERIODO INICIAL, FINAL, DIAS DEL PERIODO Y FECHA DE CORTE      --

    LET v_periodo_tc_ini = v_periodo_anterior + 1;
	LET v_periodo_tc_fin = pfechahoy;
    LET v_fecha_corte_tc = pfechahoy;

	--SE AGREGA CONSULTAS PARA IDENTIFICAR PRESTAMOS MAS VENCIDO Y/O MAS ANTIGUO SEGUN 
			--SEA EL CASO RQM 09 306  AAME.
					 LET dMontoVencidoMax=0;
					 LET dMontoVencidoMin=0;
					 LET cStatuscred="";

					FOREACH 
						--AAME 20150430 RQM 10550 Se contemplan los dos nuevos productos de prestamo personal('7600','7700')
						SELECT numcte			   
						INTO cNumcte	
						FROM "informix".sd_maecredcrd  
						where status_cred in ('AA','BA','BT','E1','E2','E3')
						and num_producto IN ('6300','7600','7700')
						group by numcte
						having count(num_credito) > 1	
						--AAME INC 27 044 2013-11-22 SE LIMPIA VARIABLE.
						LET cStatuscred = '';
						LET cNumCredVenc= '';
						--AAME 20150430 RQM 10550 Se contemplan los dos nuevos productos de prestamo personal('7600','7700')
						FOREACH 
							SELECT num_credito,status_cred			   
							  INTO cNumCredAux,cStatuscredAux							   
							  FROM "informix".sd_maecredcrd 
							 WHERE empresa       = pempresa			   
							   AND numcte   = cNumcte	
							   AND num_producto IN ('6300','7600','7700')
							   AND status_cred IN ("BA","BT","AA","E1","E2","E3")
							GROUP BY num_credito,status_cred					
							
							--IFRS
							SELECT NVL(monto_vencido + mto_venc_trasp,0) INTO cMtoVen FROM bdicred:sd_maesdoscrd WHERE num_credito = cNumCredAux;
							
							-- IFRS
							--IF cStatuscredAux IN ("BA","BT") THEN
							IF (cStatuscredAux IN ("BA","BT","E1","E2","E3") and cMtoVen > 0) THEN

								LET cStatuscred=cStatuscredAux;
								--SE OBTIENE TOTAL DE MONTO VENCIDO DEL PRESTAMO --AAME.
								 SELECT capital_ven_tc
								 INTO dMontoVencidoMin
								 FROM bdicred:sd_encabezado2_edoctacrd 
								 WHERE num_credito=cNumCredAux
								 AND MONTH(fecha_emision)=MONTH(pfechahoy)
                                 AND YEAR(fecha_emision)=YEAR(pfechahoy);	--AAME INC 27 044 2013-11-22 SE TOMA SOLO MES Y AÑ DE LA FECHA EMISION PARA QUE SE CONTEMPLEN TODOS LOS DEL MES.									 
								 
								IF dMontoVencidoMax <= dMontoVencidoMin THEN
									IF dMontoVencidoMax=dMontoVencidoMin THEN 
									--VERIFICAR SI EL MONTO VENCIDO ES IGUAL TOMAR EL PRESTAMO VENCIDO MAS ANTIGUO --AAME.
										SELECT MIN(c.num_credito)
										INTO cNumCredAux
										FROM "informix".sd_maecredcrd c, "informix".sd_maesdoscrd d
										WHERE c.num_credito = d.num_credito
										  AND status_cred IN ('BA','BT','E1','E2','E3') and (d.monto_vencido + d.mto_venc_trasp) > 0
										  AND c.num_credito IN (cNumCredVenc,cNumCredAux);	
																
										LET cNumCredVenc = cNumCredAux;										
									ELSE 
									--SI EL MONTO VENCIDO ES MAYOR QUE EL ANTERIOR VENCIDO SE REEMPLAZA --AAME.
										LET dMontoVencidoMax=dMontoVencidoMin;
										LET cNumCredVenc = cNumCredAux;	
									END IF;
								ELSE 
									IF dMontoVencidoMax < dMontoVencidoMin THEN
										LET cNumCredVenc = cNumCredAux;	
									END IF;
								END IF;	
							ELIF (cStatuscredAux IN ("AA","E1") AND cMtoVen = 0 AND cStatuscred = '') THEN
							--AAME 20150430 RQM 10550 Se contemplan los dos nuevos productos de prestamo personal('7600','7700')
							--SE OBTIENE EL NUMERO DE PRESTAMO MAS ANTIGUO --AAME.
								SELECT LIMIT 1 c.num_credito	
								INTO cNumCredVenc
								FROM "informix".sd_maecredcrd c, "informix".sd_maesdoscrd d
								WHERE c.num_credito = d.num_credito
								AND c.numcte = cNumcte
								AND c.num_producto IN ('6300','7600','7700')
								AND c.status_cred IN ("AA","E1") and (d.monto_vencido + d.mto_venc_trasp) = 0
								AND c.num_credito IN (SELECT MIN(e.num_credito) 
													   FROM "informix".sd_maecredcrd e, "informix".sd_maesdoscrd f
													   WHERE e.num_credito = f.num_credito
													   AND e.numcte = cNumcte
													   AND e.num_producto IN ('6300','7600','7700')
													   AND e.status_cred IN ("AA","E1") and (f.monto_vencido + f.mto_venc_trasp) = 0);
							END IF;
					END FOREACH;
						
					--AAME INC 27 028 2013-08-23 SE IDENTIFICA SI SE OBTUVO AL MENOS UN VENCIDO SE TOMA EL VENCIDO SI NO SE TOMA EL PRESTAMO MAS ANTIGUO DE LOS ACTIVOS	
					--UNA VEZ OBTENIDO EL NUMERO DE PRESTAMO MAS VENCIDO O MAS ANTIGUO SE ACTUALIZA LA CLAVE DE COBRANZA PARA EL CLIENTE Y PERIODO EN CURSO
						SELECT cl_cobra	
						INTO v_cl_cobranza
						FROM bdicred:"informix".sd_encabezado_edoctacrd 
						WHERE num_credito= cNumCredVenc
						AND fecha_emision BETWEEN v_periodo_tc_ini AND v_periodo_tc_fin;
						IF NVL(v_cl_cobranza,'') <> '' THEN
							UPDATE bdicred:"informix".sd_encabezado_edoctacrd
							   SET cl_cobra = v_cl_cobranza
							 WHERE fecha_emision BETWEEN v_periodo_tc_ini AND v_periodo_tc_fin
							   AND numcte = cNumcte;
						END IF;
						
		END FOREACH;
END;

	RETURN cod_ret;

END PROCEDURE 
DOCUMENT
"Se actualiza procedimiento para anexar consultas para identificar prestamos mas vencido y/o mas", 
"antiguo segun sea el caso.",
"AUTOR:Maria Elena Angulo",
"FECHA: 07-01-2013";

CREATE PROCEDURE "informix".sp_actualizacvlcobranzacte(pempresa     CHAR(3), pfechahoy    DATE, pNumProd CHAR(4))
RETURNING CHAR(6);
								

--     VARIABLES CONTROL DE ERRORES     --
DEFINE cod_ret             		CHAR(6);
DEFINE sql_err             		INTEGER;
DEFINE v_cod_ret_otro			CHAR(6);

DEFINE v_cl_cobranza            CHAR(60);	   --Clave de Cobranza			
DEFINE v_periodo_tc_ini   		DATE;			--Periodo_tc_Ini
DEFINE v_periodo_tc_fin   		DATE;			--Periodo_tc_Fin
DEFINE v_fecha_corte_tc   		DATE;			--Fecha_Corte
DEFINE v_dias_periodo_tc 		INTEGER;		--Dias_Periodo_tc
DEFINE v_periodo_anterior  	    DATE;			--Fecha Periodo Anterior
DEFINE v_periodo_prox  	        DATE;			--Fecha Periodo Anterior

---DECLARACION DE VARIABLES PARA IDENTIFICAR PRESTAMOS MAS VENCIDO Y/O MAS ANTIGUO
DEFINE cNumcte				 CHAR(20);
DEFINE cStatuscred			 CHAR(2);
DEFINE cNumCredVenc          CHAR(20);
DEFINE cNumCredAux			 CHAR(20);
DEFINE cStatuscredAux        CHAR(2);							   
DEFINE dCapital_vencido      DECIMAL(14,2);  --Capital_Ven_tc
DEFINE dInteres_vencido      DECIMAL(14,2);  --Interes_Ven_tc
DEFINE dIva_vencido          DECIMAL(14,2);  --Iva_Interes_Ven_tc
DEFINE dMoratorio            DECIMAL(14,2);  --Moratorios
DEFINE dIva_moratorio        DECIMAL(14,2);  --iva_Moratorios
DEFINE dMontoVencidoMin      DECIMAL(14,2);  --Monto Vencido Min
DEFINE dMontoVencidoMax		 DECIMAL(14,2);  --Monto Vencido Max
DEFINE cMtoVen		 		 DECIMAL(18,2);

--INICIALIZACION DE VARIABLES
--	VARIABLES CONTROL DE ERRORES     --
LET cod_ret                  = "000000";
LET sql_err                  = 0;
LET v_cod_ret_otro           = "000000";
LET v_periodo_tc_ini   		  = " ";
LET v_periodo_tc_fin   		  = " ";
LET v_fecha_corte_tc   		  = " ";
LET v_dias_periodo_tc 		  = 0;
LET v_periodo_anterior   	  = DATE(1);
LET v_periodo_prox            = DATE(1);
LET v_cl_cobranza  ='';
--- INICIO DE VARIABLES PARA IDENTIFICAR PRESTAMOS MAS VENCIDO Y/O MAS ANTIGUO	
LET cNumcte				 = '';
LET cStatuscred			 = '';
LET cNumCredVenc         = '';
LET cNumCredAux          = '';
LET cStatuscredAux		 = '';
LET dCapital_vencido     = 0;  --Capital_Ven_tc
LET dInteres_vencido     = 0;  --Interes_Ven_tc
LET dIva_vencido         = 0;  --Iva_Interes_Ven_tc
LET dMoratorio           = 0;  --Moratorios
LET dIva_moratorio       = 0;  --iva_Moratorios	
LET dMontoVencidoMin     = 0;  --Monto Vencido Min
LET dMontoVencidoMax	 = 0;  --Monto Vencido Max			
LET cMtoVen				 = 0;

SET ISOLATION TO DIRTY READ;
--SET LOCK MODE TO WAIT 3;
--SET DEBUG FILE TO "/informix/Malena/sp_actualizacvlcobranzacte.out";
--TRACE ON;
BEGIN

  ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
         LET cod_ret = sql_err;
         RETURN cod_ret;
     END IF
  END EXCEPTION WITH RESUME;

	EXECUTE PROCEDURE sp_mes_siguiente(pfechahoy ,-1,DAY(pfechahoy))
				 INTO v_cod_ret_otro, v_periodo_anterior, v_dias_periodo_tc;

	IF v_cod_ret_otro <> "000" AND cod_ret = "000000" THEN
	  LET cod_ret = v_cod_ret_otro;
	END IF;
	
	LET cod_ret = '000000';

	LET v_dias_periodo_tc = (v_dias_periodo_tc * -1);

    --     OBTENGO EL PERIODO INICIAL, FINAL, DIAS DEL PERIODO Y FECHA DE CORTE      --

    LET v_periodo_tc_ini = v_periodo_anterior + 1;
	LET v_periodo_tc_fin = pfechahoy;
    LET v_fecha_corte_tc = pfechahoy;

	--SE AGREGA CONSULTAS PARA IDENTIFICAR PRESTAMOS MAS VENCIDO Y/O MAS ANTIGUO SEGUN 
			--SEA EL CASO RQM 09 306  AAME.
					 LET dMontoVencidoMax=0;
					 LET dMontoVencidoMin=0;
					 LET cStatuscred="";

					FOREACH 
						--AAME 20150430 RQM 10550 Se contemplan los dos nuevos productos de prestamo personal('7600','7700')
						SELECT numcte			   
						INTO cNumcte	
						FROM "informix".sd_maecredcrd  
						where status_cred in ('AA','BA','BT','E1','E2','E3')
						and num_producto = pNumProd
						group by numcte
						having count(num_credito) > 1	
						--AAME INC 27 044 2013-11-22 SE LIMPIA VARIABLE.
						LET cStatuscred = '';
						LET cNumCredVenc= '';
						--AAME 20150430 RQM 10550 Se contemplan los dos nuevos productos de prestamo personal('7600','7700')
						FOREACH 
							SELECT num_credito,status_cred			   
							  INTO cNumCredAux,cStatuscredAux							   
							  FROM "informix".sd_maecredcrd 
							 WHERE empresa       = pempresa			   
							   AND numcte   = cNumcte	
							   AND num_producto = pNumProd
							   AND status_cred IN ("BA","BT","AA","E1","E2","E3")
							GROUP BY num_credito,status_cred					
							
							--IFRS
							SELECT NVL(monto_vencido + mto_venc_trasp,0) INTO cMtoVen FROM bdicred:sd_maesdoscrd WHERE num_credito = cNumCredAux;
							
							-- IFRS
							--IF cStatuscredAux IN ("BA","BT") THEN
							IF (cStatuscredAux IN ("BA","BT","E1","E2","E3") and cMtoVen > 0) THEN

								LET cStatuscred=cStatuscredAux;
								--SE OBTIENE TOTAL DE MONTO VENCIDO DEL PRESTAMO --AAME.
								 SELECT capital_ven_tc
								 INTO dMontoVencidoMin
								 FROM bdicred:sd_encabezado2_edoctacrd 
								 WHERE num_credito=cNumCredAux
								 AND MONTH(fecha_emision)=MONTH(pfechahoy)
                                 AND YEAR(fecha_emision)=YEAR(pfechahoy);	--AAME INC 27 044 2013-11-22 SE TOMA SOLO MES Y AÑ DE LA FECHA EMISION PARA QUE SE CONTEMPLEN TODOS LOS DEL MES.									 
								 
								IF dMontoVencidoMax <= dMontoVencidoMin THEN
									IF dMontoVencidoMax=dMontoVencidoMin THEN 
									--VERIFICAR SI EL MONTO VENCIDO ES IGUAL TOMAR EL PRESTAMO VENCIDO MAS ANTIGUO --AAME.
										SELECT MIN(c.num_credito)
										INTO cNumCredAux
										FROM "informix".sd_maecredcrd c, "informix".sd_maesdoscrd d
										WHERE c.num_credito = d.num_credito
										  AND status_cred IN ('BA','BT','E1','E2','E3') and (d.monto_vencido + d.mto_venc_trasp) > 0
																							 
										  AND c.num_credito IN (cNumCredVenc,cNumCredAux);	
																
										LET cNumCredVenc = cNumCredAux;										
									ELSE 
									--SI EL MONTO VENCIDO ES MAYOR QUE EL ANTERIOR VENCIDO SE REEMPLAZA --AAME.
										LET dMontoVencidoMax=dMontoVencidoMin;
										LET cNumCredVenc = cNumCredAux;	
									END IF;
								ELSE 
									IF dMontoVencidoMax < dMontoVencidoMin THEN
										LET cNumCredVenc = cNumCredAux;	
									END IF;
								END IF;	
							ELIF (cStatuscredAux IN ("AA","E1") AND cMtoVen = 0 AND cStatuscred = '') THEN
							--AAME 20150430 RQM 10550 Se contemplan los dos nuevos productos de prestamo personal('7600','7700')
							--SE OBTIENE EL NUMERO DE PRESTAMO MAS ANTIGUO --AAME.
								SELECT LIMIT 1 c.num_credito	
								INTO cNumCredVenc
								FROM "informix".sd_maecredcrd c, "informix".sd_maesdoscrd d
								WHERE c.num_credito = d.num_credito
								AND c.numcte = cNumcte
								AND c.num_producto = pNumProd
								AND c.status_cred IN ("AA","E1") and (d.monto_vencido + d.mto_venc_trasp) = 0
								AND c.num_credito IN (SELECT MIN(e.num_credito) 
													   FROM "informix".sd_maecredcrd e, "informix".sd_maesdoscrd f
													   WHERE e.num_credito = f.num_credito
													   AND e.numcte = cNumcte
													   AND e.num_producto = pNumProd
													   AND e.status_cred IN ("AA","E1") and (f.monto_vencido + f.mto_venc_trasp) = 0);
							END IF;
					END FOREACH;
						
					--AAME INC 27 028 2013-08-23 SE IDENTIFICA SI SE OBTUVO AL MENOS UN VENCIDO SE TOMA EL VENCIDO SI NO SE TOMA EL PRESTAMO MAS ANTIGUO DE LOS ACTIVOS	
					--UNA VEZ OBTENIDO EL NUMERO DE PRESTAMO MAS VENCIDO O MAS ANTIGUO SE ACTUALIZA LA CLAVE DE COBRANZA PARA EL CLIENTE Y PERIODO EN CURSO
						SELECT cl_cobra	
						INTO v_cl_cobranza
						FROM bdicred:"informix".sd_encabezado_edoctacrd 
						WHERE num_credito= cNumCredVenc
						AND fecha_emision BETWEEN v_periodo_tc_ini AND v_periodo_tc_fin;
						IF NVL(v_cl_cobranza,'') <> '' THEN
							UPDATE bdicred:"informix".sd_encabezado_edoctacrd
							   SET cl_cobra = v_cl_cobranza
							 WHERE fecha_emision BETWEEN v_periodo_tc_ini AND v_periodo_tc_fin
							   AND numcte = cNumcte;
						END IF;
						
		END FOREACH;
END;

	RETURN cod_ret;

END PROCEDURE 
DOCUMENT
"Se sobrecarga sp para parametrizar el numero de producto", 
"AUTOR:Angelica Daniella Lopez Munoz",
"FECHA: 01/03/2018";

CREATE PROCEDURE "informix".sp_actualiza_tasas_creditos(pnum_producto CHAR(4), ptasa_interes DECIMAL(9,6), ptasa_moratorios DECIMAL(9,6)) RETURNING CHAR(6);
	
-- Creacion: Abril 2019
-- Actualiza tasas de creditos activos de acuerdo a instruccion del area de Credito.

--------------------------------------------------------
-- DEFINICION VARIABLES 
--------------------------------------------------------
DEFINE cod_ret				CHAR(6);
DEFINE sql_err				INTEGER;
DEFINE v_num_credito		CHAR(20);
DEFINE v_numcte             CHAR(20);


--SET DEBUG FILE TO "/resplogifx/sp_actualiza_tasas_creditos.out";
--TRACE ON;


--------------------------------------------------------
--	VARIABLES 
--------------------------------------------------------

LET cod_ret				= "000000";
LET sql_err				= 0;
LET v_num_credito		= "";
LET v_numcte             = "";


BEGIN

	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cod_ret = sql_err;
			RETURN cod_ret;
		END IF
	END EXCEPTION WITH RESUME ;
  
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	

	--SET DEBUG FILE TO "/informix/sp_actualiza_tasas_creditos.out";
	-- TRACE ON;
	
	FOREACH WITH HOLD 
	  SELECT {AVOID_FULL("informix".sd_maecred)} num_credito, numcte INTO v_num_credito, v_numcte 
	    FROM bdicred:sd_maecred WHERE num_producto = pnum_producto AND status_cred IN ('AA','BA','BT','E1','E2','E3')
	                                
		BEGIN;
			UPDATE bdicred:sd_maecred SET tasa_interes = ptasa_interes, tasa_moratorios = ptasa_moratorios WHERE num_credito = v_num_credito;
		COMMIT;		
	   
	END FOREACH;   
	
			
	RETURN cod_ret;
END;
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_adn_cart_activa (pEmpresa CHAR (3))	
RETURNING CHAR(5),       -- Codigo de Retorno
		  CHAR(80);      -- Mensaje de Retorno

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cCod_ret      CHAR(6);
DEFINE cMensajeRet CHAR(80);

DEFINE dMontoFinanciado  DECIMAL(18,2);
DEFINE dIngresoMens  DECIMAL(18,2);
DEFINE dCapVig           DECIMAL(18,2);
DEFINE dCapTrans         DECIMAL(18,2);
DEFINE dCapVdoExig       DECIMAL(18,2);
DEFINE dCapVdoNoExig     DECIMAL(18,2);

DEFINE cCteCoppel    CHAR(20);
DEFINE cNumCte  	 CHAR(20);
DEFINE cNumCredito  	 CHAR(20);
DEFINE dtFechaSol    DATE;
DEFINE dtFechaApert     DATE;
DEFINE cStatusDesc     CHAR(50);
DEFINE cStatus     CHAR(2);
DEFINE cSucursal     CHAR(4);
DEFINE cFrecuenciaPago     CHAR(20);
DEFINE cSitPago     CHAR(20);
DEFINE iNumVenc     INTEGER;
DEFINE iMesesHist    INTEGER;
DEFINE cGrupo     CHAR(1);
DEFINE cMovil     CHAR(13);
DEFINE dtFechaHoy    DATE;
DEFINE dtFechaConsulta     DATE;

DEFINE cSql            	CHAR(2500);
DEFINE cNombreArchivo  	CHAR(150);
DEFINE cNombreArchivo1  CHAR(150);
DEFINE cConsulta		CHAR(2200);
DEFINE cEncabezado		CHAR(800);
DEFINE cRuta 			CHAR(80);
DEFINE iContador 		INTEGER;
DEFINE iContador2 		INTEGER;
DEFINE dLinea 		 DECIMAL(18,2);
DEFINE dSaldoLC 		 DECIMAL(18,2);
DEFINE cCuentaNom 		CHAR(20);
DEFINE cStatusPago CHAR(10);
DEFINE dMontoFinanciadoPag  DECIMAL(18,2);
DEFINE iFrecuenciaPago  INTEGER;
DEFINE dtFechaMovPag DATE;
DEFINE dtFechaMov DATE;
DEFINE dtFechaMovAux DATE;
DEFINE act_aux      INTEGER;

LET act_aux         = 0;
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cCod_ret         = "00000";
LET cMensajeRet     = "Proceso Exitoso";

LET dMontoFinanciado	  = 0;
LET dIngresoMens               = 0;
LET dCapVig               = 0;
LET dCapTrans             = 0;
LET dCapVdoExig           = 0;
LET dCapVdoNoExig         = 0;

LET cCteCoppel   = "";
LET cNumCte  	 = "";
LET cNumCredito  	 = "";
LET dtFechaSol   =DATE(1) ;
LET dtFechaApert    =  DATE(1);
LET cStatusDesc    = "";
LET cStatus    = "";
LET cSucursal     = "";
LET cFrecuenciaPago     = "";
LET cSitPago     = "";
LET iNumVenc    = 0;
LET iMesesHist  = 0;
LET cGrupo     = "";
LET cMovil    = "";

LET dtFechaHoy   =DATE(1) ;
LET dtFechaConsulta    =  DATE(1);

LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';
LET cRuta	= "";
LET iContador	= 0;
LET iContador2	= 0;
LET dLinea 		 = 0;
LET dSaldoLC 		= 0;
LET cCuentaNom 		= "";

LET cStatusPago = "";
LET dMontoFinanciadoPag = 0;
LET iFrecuenciaPago = 0;
LET dtFechaMovPag = null;
LET dtFechaMov = null;
LET dtFechaMovAux = null;
	
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN iSqlErr,cErrorInfo ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/jesus/RQM10617/sp_adn_cart_activa.out';
	--TRACE ON;

	IF NVL(pEmpresa,'') = ''  THEN
		RETURN  '00001','PARAMETROS DE ENTRADA INVALIDOS' ;
	ELSE
	
	
	
	  --RUTA PARA GENERAR EL ARCHIVO
	SELECT valor
	INTO cRuta
	FROM bdicred:"informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='081';
	
	--SINO EXISTE LA RUTA DEL ARCHIVO	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
		LET cMensajeRet ='NO EXISTE PARAMETRO DE LA RUTA PARA GENERAR EL ARCHIVO';
		RETURN cCodRet,cMensajeRet;
	END IF;	 
	
	SELECT a.fecha_hoy,pri_dia_mes - 1 units day
	INTO dtFechaHoy,dtFechaConsulta	
	FROM "informix".sd_fechas a
	WHERE a.empresa = pEmpresa;
			 
   --LET dtFechaHoy = mdy(05,05,2016);
   --LET dtFechaConsulta = mdy(04,30,2016);
   --LET dtFechaConsulta = mdy(05,31,2016);
	--LET dtFechaHoy = mdy(06,05,2016);
	--LET dtFechaHoy = mdy(07,05,2016);		
	
	--GENERA EL NOMBRE DEL ARCHIVO
	LET cNombreArchivo = TRIM('Cartera_anticiponomina_')||TO_CHAR(dtFechaHoy,'%d%m%y')|| '.txt';
	LET cNombreArchivo1 = TRIM('Cartera_anticiponomina_aux')||TO_CHAR(dtFechaHoy,'%d%m%y')|| '.txt';
	
	FOREACH WITH HOLD 
		SELECT a.num_credito , a.fecha_apertura  ,a.numcte , a.status_cred , b.act ,
		a.sucursal,b.mto_fin_ven_trasp,b.sdo_capital, b.monto_vencido,mto_venc_trasp,cap_tras_no_venci,
		fecha_insert,DECODE(frecuencia_pgo,'1','MENSUAL','2','QUINCENAL','3','SEMANAL','MENSUAL'),movil_cuenta,	linea, saldocuenta_lc,cuenta_nomina,frecuencia_pgo
		INTO cNumCredito ,dtFechaApert ,cNumCte ,cStatus ,act_aux ,cSucursal, iNumVenc, 
		dCapVig,dCapTrans,dCapVdoExig,dCapVdoNoExig,
		dtFechaSol, cFrecuenciaPago,cMovil, dLinea, dSaldoLC, cCuentaNom,iFrecuenciaPago
		FROM sd_maecred a, sd_maesdos b , bdisolic:"informix".ss_adn_solicitudcuenta c
         WHERE a.num_credito   = b.num_credito
           AND a.empresa       = b.empresa    
		   AND a.num_credito   = c.num_solicitud
           AND a.empresa       = pEmpresa   
		   AND a.num_producto  = '7800'
		   AND a.status_cred  in('AA','BA','BT','E1','E2','E3')
           AND a.fecha_apertura <= dtFechaConsulta
	
			SELECT numcte_ref
			INTO cCteCoppel
			FROM bdinteg:"informix".si_cliente  
			WHERE numcte = cNumCte;

			SELECT descripcion
			INTO cStatusDesc
			FROM "informix".sd_tipocartera  
			WHERE status_cred = cStatus;
			
			SELECT situacion_pago , meses_historia, ingreso_mensual,grupo
				INTO cSitPago, iMesesHist, dIngresoMens, cGrupo
			FROM bdisolic:"informix".ss_resum_scor_fin  
			WHERE num_solicitud = cNumCredito;
		 
		 
		 IF NVL (dSaldoLC,0) = 0 THEN
			 SELECT NVL(monto_tot,0) 
				  INTO dSaldoLC
				  FROM bdicheq:"informix".sc_movhis mov
				INNER JOIN bdicred:"informix".sd_transvalprod  tran ON (tran.transacc = mov.transacc AND tran.activo = 2)
				 WHERE cuenta = cCuentaNom 
				   AND cancelad <> 'S'
				   AND fech_alt <= dtFechaApert
				   AND num_serial = (SELECT MAX(num_serial) FROM bdicheq:"informix".sc_movhis mov2
								INNER JOIN bdicred:"informix".sd_transvalprod  tran ON (tran.transacc = mov2.transacc AND tran.activo = 2)
									 WHERE cuenta = cCuentaNom 
									   AND cancelad <> 'S' 
									   AND fech_alt <= dtFechaApert);
									   
			 IF NVL (dSaldoLC,0) = 0 THEN						   
				 SELECT NVL(monto_tot,0) 
					  INTO dSaldoLC
					  FROM bdicheq:"informix".sc_movhis_old mov
					INNER JOIN bdicred:"informix".sd_transvalprod  tran ON (tran.transacc = mov.transacc AND tran.activo = 2)
					 WHERE cuenta = cCuentaNom 
					   AND cancelad <> 'S'
					   AND fech_alt <= dtFechaApert
					   AND num_serial = (SELECT MAX(num_serial) FROM bdicheq:"informix".sc_movhis_old mov2
									INNER JOIN bdicred:"informix".sd_transvalprod  tran ON (tran.transacc = mov2.transacc AND tran.activo = 2)
										 WHERE cuenta = cCuentaNom 
										   AND cancelad <> 'S' 
										   AND fech_alt <= dtFechaApert);						   
									   
				END IF;		
				
				UPDATE  bdisolic:"informix".ss_adn_solicitudcuenta 
					SET saldocuenta_lc = dSaldoLC
				WHERE empresa='001' 
				AND num_solicitud=cNumCredito; 
									   
		 END IF;
		 

		
		FOREACH WITH HOLD
		
			SELECT monto,fecha_mov
			INTO dMontoFinanciado, dtFechaMov
			FROM bdicred:sd_movhis
			where empresa='001'
			and num_credito =cNumCredito
			and transacc_suc='8174'
			AND MONTH(fecha_mov) = MONTH(dtFechaConsulta)
			ORDER BY fecha_mov DESC
			
			IF iFrecuenciaPago = 1 THEN--mensual
				LET dtFechaMovAux = MONTHADD(dtFechaMov,1) ;
			ELIF iFrecuenciaPago = 2 THEN --quinsenal
					LET dtFechaMovAux = dtFechaMov + 15 UNITS DAY ;	
			ELSE--semanal
				LET dtFechaMovAux = dtFechaMov + 7 UNITS DAY ;	
			END IF 
						
			SELECT SUM(monto),MAX(fecha_mov)
			INTO dMontoFinanciadoPag, dtFechaMovPag
			FROM bdicred:sd_movhis
			where empresa='001'
			and num_credito =cNumCredito
			and transacc_suc='8175'
			and codigo_fun ='074'
			and codigo_ref =1
			AND fecha_mov > dtFechaMov
			AND MONTH(fecha_mov) = MONTH(dtFechaConsulta)
			AND fecha_mov 	<= dtFechaMovAux;
			
			IF dMontoFinanciadoPag > 0 THEN 
				LET cStatusPago = "PAGADO";			
			ELSE 
				LET cStatusPago = "PENDIENTE DE PAGO";
			END IF;
			
			IF (cStatus <>  'AA' OR ( NVL(act_aux,-1) <> 0 and cStatus <> 'E1'))  THEN
				LET cStatusPago = "NO PAGADO";	
			END IF;
			
				LET cConsulta = TRIM(NVL(cCteCoppel,''))||'|'|| TRIM(NVL(cNumCte,''))||'|'|| TRIM(NVL(cNumCredito,''))||'|'||dtFechaSol||'|'|| TRIM(NVL(dtFechaApert,''))||'|'|| TRIM(NVL(cStatusDesc,''))||'|'||  NVL(dIngresoMens,0)||'|'|| NVL(dMontoFinanciado,0)||'|'|| TRIM(NVL(cSucursal,''))||'|'|| TRIM(NVL(cFrecuenciaPago,''))||'|'|| NVL(iNumVenc,0)||'|'|| TRIM(NVL(cSitPago,''))||'|'|| TRIM(NVL(iMesesHist,''))||'|'|| TRIM(NVL(cGrupo,''))||'|'|| TRIM(NVL(cMovil,''))||'|'|| NVL(dCapVig,0)||'|'|| NVL(dCapTrans,0)||'|'|| NVL(dCapVdoExig,0)||'|'|| NVL(dCapVdoNoExig,0)||'|'||NVL(dCapVig,0)||'|'||NVL(dLinea,0)||'|'||NVL(dSaldoLC,0)||'|'||NVL(dtFechaMov,'')||'|'||NVL(dtFechaMovPag,'')||'|'||NVL(dMontoFinanciadoPag,0)||'|'||NVL(cStatusPago,'');

		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;	
		LET iContador2	=  1; 	
			EXIT FOREACH;
		
		END FOREACH;

		
		
		
		
		

	IF iContador2 =0 THEN
		LET cConsulta = TRIM(NVL(cCteCoppel,''))||'|'|| TRIM(NVL(cNumCte,''))||'|'|| TRIM(NVL(cNumCredito,''))||'|'||dtFechaSol||'|'|| TRIM(NVL(dtFechaApert,''))||'|'||TRIM(NVL(cStatusDesc,''))||'|'||  NVL(dIngresoMens,0)||'|'|| NVL(dMontoFinanciado,0)||'|'|| TRIM(NVL(cSucursal,''))||'|'|| TRIM(NVL(cFrecuenciaPago,''))||'|'|| NVL(iNumVenc,0)||'|'|| TRIM(NVL(cSitPago,''))||'|'|| TRIM(NVL(iMesesHist,''))||'|'|| TRIM(NVL(cGrupo,''))||'|'|| TRIM(NVL(cMovil,''))||'|'|| NVL(dCapVig,0)||'|'|| NVL(dCapTrans,0)||'|'|| NVL(dCapVdoExig,0)||'|'|| NVL(dCapVdoNoExig,0)||'|'||NVL(dCapVig,0)||'|'||NVL(dLinea,0)||'|'||NVL(dSaldoLC,0)||'|'||NVL(dtFechaMov,'')||'|'||NVL(dtFechaMovPag,'')||'|'||NVL(dMontoFinanciadoPag,0)||'|'||NVL(cStatusPago,'');

		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;		
	END IF 	
	LET iContador	=  1; 
	LET iContador2	=  0; 
	LET cStatusPago = "";
	LET dMontoFinanciadoPag = 0;
	LET dMontoFinanciado = 0;
	LET dSaldoLC = 0;
	LET dtFechaMovPag = null;
	LET dtFechaMov = null;
	
    END FOREACH;

		IF iContador  > 0 THEN 	

			---se ejecuta para ponerle el encabezado 
			LET cEncabezado = 'echo "NÃ¯Â¿Â½mero de Cliente Coppel'||'|'||'NÃ¯Â¿Â½mero de Cliente BanCoppel'||'|'||'NÃ¯Â¿Â½mero de CrÃ¯Â¿Â½dito'||'|'||'Fecha de solicitud del CrÃ¯Â¿Â½dito'||'|'||'Fecha de Apertura del CrÃ¯Â¿Â½dito'||'|'||'Estatus'||'|'||'Ingreso mensual declarado'||'|'||'Monto prÃ¯Â¿Â½stado'||'|'||'Sucursal origen'||'|'||'Periodicidad de pago'||'|'||'Incumplimientos'||'|'||'Eficiencia de Pago Coppel'||'|'||'Meses de Historia Coppel'||'|'||'Grupo de OriginaciÃ¯Â¿Â½n'||'|'||'NÃ¯Â¿Â½mero de Celular'||'|'||'Capital Vigente'||'|'||'Capital transitorio'||'|'||'Capital Vencido Exigible'||'|'||'Capital Vencido No Exigible'||'|'||'Monto a pagar para liquidar el crÃ¯Â¿Â½dito'||'|'||'LÃ¯Â¿Â½nea otorgada'||'|'||'Ingreso utilizado para determinar la lÃ¯Â¿Â½nea de crÃ¯Â¿Â½dito'||'|'||'Fecha de Disposicion'||'|'||'Fecha de Pago'||'|'||'Suma de Pagos'||'|'||'Estatus de Pago'||'|'|| '" > '||TRIM(cruta)|| cNombreArchivo;  
		
	
			SYSTEM cEncabezado;

			LET cSql = cSql;
			LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNombreArchivo1) || " >> " || TRIM(cRuta) || TRIM(cNombreArchivo);
			SYSTEM cSql;


			LET cSQL = '' ;
			LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
			SYSTEM cSQL;   	

			RETURN cCodRet,cMensajeRet;

		ELSE
			LET cCodRet			= '00000';
			LET cMensajeRet			= 'No se encontro informaciÃ¯Â¿Â½n';
			RETURN cCodRet,cMensajeRet;
		END IF;			
	END IF;		
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para validacion de los resultados del Anticipo de NÃ¯Â¿Â½mina de forma general',
'AUTOR :  Jesus Manuel Aguilar',
'FECHA : 24/abril/2016',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_adn_res_general (pEmpresa CHAR (3))	
RETURNING CHAR(5),       -- Codigo de Retorno
		  CHAR(80);      -- Mensaje de Retorno

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cCod_ret      CHAR(6);
DEFINE cMensajeRet CHAR(80);


DEFINE cSql            	CHAR(2500);
DEFINE cNombreArchivo  	CHAR(150);
DEFINE cNombreArchivo1  CHAR(150);
DEFINE cConsulta		CHAR(2200);
DEFINE cEncabezado		CHAR(600);
DEFINE cRuta 			CHAR(80);

DEFINE	dtFechaHoy	DATE;
DEFINE	dtFechaFinMes	DATE;
DEFINE	dTFechaSD	DATE;

DEFINE dMontoTotal 		DECIMAL(18,2);
DEFINE dMontoCap 		DECIMAL(18,2);
DEFINE dTotalActAnticipo 		INTEGER;
DEFINE dTotalSolAnticipo 		INTEGER;
DEFINE dTotalSolAnticiport 		INTEGER;


LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cCod_ret         = "00000";
LET cMensajeRet     = "Proceso Exitoso";

LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';
LET cRuta	= "";

LET	dtFechaHoy	= DATE(1);
LET	dtFechaFinMes	= DATE(1);
LET	dTFechaSD	 =DATE(1);
LET	 dMontoTotal 		= 0;
LET	 dMontoCap 		= 0;
LET	 dTotalActAnticipo 		= 0;
LET	 dTotalSolAnticipo 		= 0;
LET	 dTotalSolAnticiport 	= 0;



BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN iSqlErr,cErrorInfo ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/jesus/RQM10617/sp_adn_res_general.out';
	--TRACE ON;

	IF NVL(pEmpresa,'') = ''  THEN
		RETURN  '00001','PARAMETROS DE ENTRADA INVALIDOS' ;
	ELSE
	
	
	
	  --RUTA PARA GENERAR EL ARCHIVO
	SELECT valor
	INTO cRuta
	FROM bdicred:"informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='081';
	
	--SINO EXISTE LA RUTA DEL ARCHIVO	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
		LET cMensajeRet ='NO EXISTE PARAMETRO DE LA RUTA PARA GENERAR EL ARCHIVO';
		RETURN cCodRet,cMensajeRet;
	END IF;	 
	
	SELECT a.fecha_hoy
	INTO dtFechaHoy
	FROM "informix".sd_fechas a
	WHERE a.empresa = pEmpresa;

	--LET dtFechaHoy = mdy(05,05,2016);
	--LET dtFechaHoy = mdy(06,05,2016);
	--LET dtFechaHoy = mdy(07,05,2016);		 
			 
	--GENERA EL NOMBRE DEL ARCHIVO
	LET cNombreArchivo = TRIM('Resultados_Generales_ADN_Mes_')||TO_CHAR(dtFechaHoy,'%m%y')|| '.txt';
	LET cNombreArchivo1 = TRIM('Resultados_Generales_ADN_Mes_aux_')||TO_CHAR(dtFechaHoy,'%m%y')|| '.txt';
	
	LET dtFechaFinMes = mdy(month(dtFechaHoy),01,YEAR(dtFechaHoy)) - 1 units day;
	LET dTFechaSD = bdicred:MONTHADD(mdy(month(dtFechaHoy),01,YEAR(dtFechaHoy)), - 1);
	
	

		SELECT count(num_solicitud)
		INTO dTotalSolAnticipo
		FROM bdisolic:"informix".ss_solicitudes
		WHERE  empresa='001'
		and num_solicitud >=''
		and num_producto ='7800'
		and status_solicitud in ('RT','AT','AP')
		and fecha_insert BETWEEN dTFechaSD AND dtFechaFinMes;



		LET cConsulta = "No. Solicitudes efectuadas en el periodo"||'|'|| NVL(dTotalSolAnticipo,'')||'|'||NVL(dMontoTotal,0)||'|'||NVL(dMontoCap,0);
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;	
			
			
		SELECT count(num_solicitud)
		INTO dTotalSolAnticipoRt
		FROM bdisolic:"informix".ss_solicitudes
		WHERE  empresa='001'
		and num_solicitud >=''
		and num_producto ='7800'
		and status_solicitud = 'RT'
		and fecha_insert BETWEEN dTFechaSD AND dtFechaFinMes;

		
		SELECT SUM(b.monto_otorgado), SUM(b.sdo_cap_insoluto) ,count(a.num_credito)
		INTO dMontoTotal,dMontoCap, dTotalActAnticipo
		FROM bdicred:"informix".sd_maecred a , bdicred:"informix".sd_maesdos b
		WHERE   a.empresa ='001'
		AND  a.num_producto ='7800'			
		and a.fecha_apertura BETWEEN dTFechaSD AND dtFechaFinMes
		AND  a.empresa=b.empresa
		and a.num_credito = b.num_credito;

		LET cConsulta = "No. Anticipos Activados (Autorizados)"||'|'|| NVL(dTotalActAnticipo,0)||'|'||NVL(dMontoTotal,0)||'|'||NVL(dMontoCap,0);
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;	

		--liquidados
		
		SELECT SUM(b.monto_otorgado), SUM(b.sdo_cap_insoluto) ,count(a.num_credito)
		INTO dMontoTotal,dMontoCap, dTotalActAnticipo
		FROM bdicred:"informix".sd_maecred a , bdicred:"informix".sd_maesdos b
		WHERE   a.empresa ='001'
		AND  a.num_producto ='7800'			
		--and a.fecha_apertura BETWEEN dTFechaSD AND dtFechaFinMes
		AND  a.empresa=b.empresa
		and a.num_credito = b.num_credito				
		and status_cred ='FF';

			LET cConsulta = "Liquidados"||'|'|| NVL(dTotalActAnticipo,0)||'|'||NVL(dMontoTotal,0)||'|'||NVL(dMontoCap,0);
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;	
		--Pagados
		
		SELECT  SUM(a.monto), SUM(b.sdo_cap_insoluto) ,count(a.num_credito)
		INTO dMontoTotal,dMontoCap, dTotalActAnticipo
		FROM  bdicred:sd_maesdos b, bdicred:sd_maecred c, bdicred:sd_movhis  a
		WHERE  a.empresa='001' 
		and a.num_credito = b.num_credito 
		and a.num_credito = c.num_credito 
		AND  c.num_producto ='7800'
		and a.fecha_mov BETWEEN dTFechaSD AND dtFechaFinMes
		and a.transacc_suc = '8175'
		AND codigo_ref =1;

		LET cConsulta = "Pagados"||'|'|| NVL(dTotalActAnticipo,0)||'|'||NVL(dMontoTotal,0)||'|'||NVL(dMontoCap,0);
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;	

		---disposiciones
		SELECT  SUM(a.monto), SUM(b.sdo_cap_insoluto) ,count(a.num_credito)
		INTO dMontoTotal,dMontoCap, dTotalActAnticipo
		FROM  bdicred:sd_maesdos b, bdicred:sd_maecred c, bdicred:sd_movhis  a
		WHERE  a.empresa='001' 
		and a.num_credito = b.num_credito 
		and a.num_credito = c.num_credito 
		AND  c.num_producto ='7800'
		and a.fecha_mov BETWEEN dTFechaSD AND dtFechaFinMes
		and a.transacc_suc = '8174'
		AND a.codigo_fun = '002'
		and a.codigo_ref =111;

		LET cConsulta = "Disposiciones"||'|'|| NVL(dTotalActAnticipo,0)||'|'||NVL(dMontoTotal,0)||'|'||NVL(dMontoCap,0);
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;	
			
		
		--vigentes
		
		SELECT SUM(b.monto_otorgado), SUM(b.sdo_cap_insoluto) ,count(a.num_credito)
		INTO dMontoTotal,dMontoCap, dTotalActAnticipo
		FROM bdicred:"informix".sd_maecred a , bdicred:"informix".sd_maesdos b
		WHERE   a.empresa ='001'
		AND  a.num_producto ='7800'			
		--and a.fecha_apertura BETWEEN dTFechaSD AND dtFechaFinMes
		AND  a.empresa=b.empresa
		and a.num_credito = b.num_credito				
		and a.status_cred IN ('AA','E1') and (b.monto_vencido + b.mto_venc_trasp) = 0;
		
		LET cConsulta = "Vigentes"||'|'|| NVL(dTotalActAnticipo,0)||'|'||NVL(dMontoTotal,0)||'|'||NVL(dMontoCap,0);
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;	

		--vencidos
		
		SELECT SUM(b.monto_otorgado), SUM(b.sdo_cap_insoluto) ,count(a.num_credito)
		INTO dMontoTotal,dMontoCap, dTotalActAnticipo
		FROM bdicred:"informix".sd_maecred a , bdicred:"informix".sd_maesdos b
		WHERE   a.empresa ='001'
		AND  a.num_producto ='7800'			
		--and a.fecha_apertura BETWEEN dTFechaSD AND dtFechaFinMes
		AND  a.empresa=b.empresa
		and a.num_credito = b.num_credito				
		and a.status_cred IN ('BA','BT','E1','E2','E3') AND (b.monto_vencido + b.mto_venc_trasp) > 0;

			LET cConsulta = "Vencidos"||'|'|| NVL(dTotalActAnticipo,0)||'|'||NVL(dMontoTotal,0)||'|'||NVL(dMontoCap,0);
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;			

		LET dMontoTotal=0;
		LET dMontoCap=0;

		LET cConsulta = "Rechazados"||'|'|| NVL(dTotalSolAnticipoRt,0)||'|'||NVL(dMontoTotal,0)||'|'||NVL(dMontoCap,0);
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;	



		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo "Conceptos'||'|'||'No. Anticipos'||'|'||'Monto Anticipo Autorizada'||'|'||'Saldo Insoluto'||'|'|| '" > '||TRIM(cruta)|| cNombreArchivo;  
		SYSTEM cEncabezado;

		LET cSql = cSql;
		LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNombreArchivo1) || " >> " || TRIM(cRuta) || TRIM(cNombreArchivo);
		SYSTEM cSql;


		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
		SYSTEM cSQL;   	

		RETURN cCodRet,cMensajeRet;

		
	END IF;		
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para validacion de los resultados del Anticipo de Nï¿½mina de forma general',
'AUTOR :  Jesus Manuel Aguilar',
'FECHA : 24/abril/2016',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_calculo_grupoa (cEmpresa CHAR(3), p_numproducto CHAR(4))
    RETURNING CHAR(5)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje,              
              CHAR(25) AS StorePro;              

DEFINE vsqlerr          INTEGER; 
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);

DEFINE v_codigo_retorno	CHAR(5);
DEFINE v_mensaje	  	CHAR(80);

DEFINE v_store_pro      CHAR(25);

DEFINE dtFechaHoy       DATE;
DEFINE dtFechaProx      DATE;
DEFINE dtFechaFinMes    DATE;
DEFINE dtFechaCortePrev DATE;
DEFINE dtFechaCorte1mes DATE;
DEFINE dtFechaHoy_aux   DATE;

DEFINE vc_crdcontproc   CHAR(1);
DEFINE vc_intcontproc 	CHAR(1);

DEFINE vc_numproducto   CHAR (4);
DEFINE vc_numcredito    CHAR(20);
DEFINE vc_numcte        CHAR(20); 
DEFINE vc_statuscred    CHAR(2);
DEFINE vd_motorgado     DECIMAL(18,2);
DEFINE vd_cap_insoluto  DECIMAL(18,2);
DEFINE vi_porcentaje_uso    DECIMAL(18,2);
DEFINE vi_porcentaje_usoUM  DECIMAL(18,2);

DEFINE vd_capital_insol     DECIMAL(18,2);
DEFINE vd_mto_fin_ven_trasp DECIMAL(18,2);
DEFINE vf_vig_fecha_fac     DATE;
DEFINE vc_tipoproceso       CHAR(20);
DEFINE vf_fechapertu        DATE;
DEFINE vi_meses_antigdad    INTEGER;
DEFINE  vlNumCredito        CHAR(20);
--DEFINE ren_empresa  CHAR(3);
--DEFINE ren_producto CHAR(4);
--DEFINE ren_credito  CHAR(20);
DEFINE vi_meses_vigts       INTEGER;
DEFINE vd_usolinea_min      DECIMAL(5,2);
DEFINE vd_usolinea_max      DECIMAL(5,2);
DEFINE vcontador            SMALLINT;
DEFINE vs_dia_cort_prod     SMALLINT;
DEFINE vPorcUtil80          SMALLINT;

LET vc_numproducto      ='';
LET vc_numcredito       ='';
LET vc_numcte           =''; 
LET vc_statuscred       ='';
LET vd_motorgado        = 0; 
LET vd_cap_insoluto     = 0;
LET vi_porcentaje_uso   = 0;
LET vi_porcentaje_usoUM =0;
LET vd_capital_insol    = 0;
LET vd_mto_fin_ven_trasp   = 0;
LET vf_vig_fecha_fac    = DATE(1);
LET vc_tipoproceso      = '';
LET vf_fechapertu       = DATE(1);
LET dtFechaHoy_aux      = DATE(1);
LET vi_meses_antigdad   = 0;
--LET ren_empresa = '';
--LET ren_producto ='';
--LET ren_credito ='';
LET vi_meses_vigts      = 0;
LET vd_usolinea_min     = 0;
LET vd_usolinea_max     = 0;
LET vcontador           = 0;
LET vlNumCredito        = '';
LET vs_dia_cort_prod    = 0;
LET vPorcUtil80         = 0;

LET v_codigo_retorno    = "00000";
LET v_mensaje           = "Proceso Inicia Correctamente";
LET v_store_pro         = 'sp_calculo_grupoa';
--LET vc_tipoproceso    = 'FiltroGpo6_' || TRIM (p_numproducto);
LET vc_tipoproceso      = 'CalculoGpoA_' || TRIM (p_numproducto); 

--SET DEBUG FILE TO "/informix/mahr/sp_calculo_grupoa" ||p_numproducto|| ".out";
--TRACE ON;

SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;

BEGIN
    ON EXCEPTION SET vsqlerr ,iIsamErr,cErrorInfo         
        IF vsqlerr <> 0 THEN         
            LET v_codigo_retorno = vsqlerr;
            LET v_mensaje = cErrorInfo;
            LET v_store_pro = 'sp_calculo_grupoa';
            RETURN v_codigo_retorno, v_mensaje, v_store_pro;
    END IF;
   END EXCEPTION;


    --*********************************************************--
	-- Creado por: Francisco Martinez Viveros	
	--Fecha Creacion: 05/JUNIO/2012 || Fecha Modifica: 16/OCTUBRE/2012
	--Objetivo: Valida Clientes que son candidatos al Grupo "A" 6, por tener buen comportamiento de Credito SP exclusivo para Tarjeta de Credito 
    --                
    -- Fecha Modificacion: Dic 2016. Se agregan productos de Tarjeta Platino y Tarjeta Oro. Se corrige proceso para evaluar a nivel cliente.          
	--*********************************************************--

    IF (p_numproducto <> '6001' ) AND (p_numproducto <> '7000' ) AND (p_numproducto <> '8100') THEN
        LET v_codigo_retorno = "00035";
        LET v_mensaje="NO. DE PRODUCTO, INVALIDO PARA EJECUTAR EN EL SP, VERIFIQUE!";
        LET v_store_pro = 'sp_calculo_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
     END IF;

    SELECT a.fecha_hoy, a.prox_fecha, a.ult_dia_mes
      INTO dtFechaHoy, dtFechaProx, dtFechaFinMes
      FROM "informix".sd_fechas a
     WHERE a.empresa = cEmpresa;

         --FMV 6ago12: Validacion de los meses vigentes y los porcentajes de uso de linea en grupo A
    SELECT valor::integer
      INTO vi_meses_vigts
      FROM "informix".sd_param
     WHERE empresa = cEmpresa
       AND cod_param = '55';

    IF vi_meses_vigts IS NULL THEN
        LET v_codigo_retorno = "00040";
        LET v_mensaje="Falta parametro para el calculo de meses vigentes";
        LET v_store_pro = 'sp_calculo_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT valor::decimal(5,2)
      INTO vd_usolinea_min
      FROM "informix".sd_param
     WHERE empresa = cEmpresa
       AND cod_param = '56';

    IF vd_usolinea_min IS NULL THEN
        LET v_codigo_retorno = "00041";
        LET v_mensaje="Falta parametro del porcentaje minimo uso de linea";
        LET v_store_pro = 'sp_calculo_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT valor::decimal(5,2)
      INTO vd_usolinea_max
      FROM "informix".sd_param
     WHERE empresa = cEmpresa
       AND cod_param = '57';

    IF vd_usolinea_min IS NULL THEN
        LET v_codigo_retorno = "00042";
        LET v_mensaje="Falta parametro del porcentaje maximo uso de linea";
        LET v_store_pro = 'sp_calculo_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    -- FMV 4-OCT-12 Omite validacion para 1a. corrida
    --      IF (DAY(dtFechaHoy) <> 20)
    --       THEN
    --              LET v_codigo_retorno = "00032";
    --              LET v_mensaje="DIA DE EJECUCION NO ES MESIVERSARIO EN DIA 20 DE MES ";
    --              LET v_store_pro = 'sp_calculo_grupoa';
    --          RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    --      END IF; 

    SELECT status_proc INTO vc_intcontproc FROM bdinteg:sx_contproc
     WHERE empresa = cEmpresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
    IF (vc_intcontproc='F') THEN
        LET v_codigo_retorno = "00031";
        LET v_mensaje="PROCESO DE GRUPOA, YA EJECUTADO ANTERIORMENTE";
        LET v_store_pro = 'sp_calculo_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT status_proc INTO vc_crdcontproc FROM bdicred:sd_contproc
     WHERE empresa = cEmpresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
    IF (vc_intcontproc IS NULL) THEN
        INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
               VALUES (cEmpresa,vc_tipoproceso,dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
    END IF;  
    IF (vc_crdcontproc IS NULL) THEN
        INSERT INTO bdicred:sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
               VALUES (cEmpresa,vc_tipoproceso,dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Iniciamos grupoA');
    END IF;

    IF vc_intcontproc = 'I' OR vc_crdcontproc = 'I' THEN
        UPDATE bdinteg:sx_contproc SET status_proc = 'I', hora_ini = CURRENT WHERE empresa = cEmpresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
        UPDATE bdicred:sd_contproc SET status_proc = 'I', hora_inicio = CURRENT, mensaje = 'Iniciamos grupoA' WHERE empresa = cEmpresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
    END IF;
    /*LET dtFechaHoy = mdy(month(dtFechaHoy),'20',year(dtFechaHoy));
    SELECT first 1 num_credito into vlNumCredito FROM sd_maesdoshist  WHERE empresa = '001' AND FECHA= dtFechaHoy;
    IF '' = NVL(vlNumCredito,'') THEN     
        LET dtFechaHoy = dtFechaHoy -1 UNITS MONTH;
    END IF;*/

    -- Obtiene el dia de corte para cada producto, y armar asi la fecha de corte previo correspondiente.
    SELECT dia_cuota INTO vs_dia_cort_prod FROM bdicred:sd_definicion WHERE empresa = cEmpresa AND num_producto = p_numproducto;
    LET dtFechaHoy_aux = monthadd(dtFechaHoy,- 1);

    IF DAY(dtFechaHoy) <= vs_dia_cort_prod THEN
        --LET dtFechaCortePrev = mdy(month(dtFechaHoy -1 UNITS MONTH),vs_dia_cort_prod,year(dtFechaHoy));
        LET dtFechaCortePrev = mdy(month(dtFechaHoy_aux),vs_dia_cort_prod,year(dtFechaHoy_aux)); -- Fecha corte de mes anterior
    ELSE
        LET dtFechaCortePrev = mdy(month(dtFechaHoy),vs_dia_cort_prod,year(dtFechaHoy));
    END IF;
    
	LET vf_vig_fecha_fac = monthadd(dtFechaCortePrev,- vi_meses_vigts);

    FOREACH WITH HOLD                                   
        SELECT a.num_producto, a.num_credito, a.numcte, a.fecha_apertura, a.status_cred, NVL(b.monto_otorgado,0), NVL(b.sdo_cap_insoluto,0)
          INTO vc_numproducto, vc_numcredito, vc_numcte, vf_fechapertu, vc_statuscred, vd_motorgado, vd_cap_insoluto                        
          FROM bdicred:"informix".sd_maecred a,				        
               bdicred:"informix".sd_maesdoshist b, ---max
               bdicred:"informix".sd_maesdos d
         WHERE a.empresa = cEmpresa   
           AND a.empresa = b.empresa
           AND a.empresa = d.empresa
           AND a.num_credito = b.num_credito
           AND a.num_credito = d.num_credito
           AND b.fecha = dtFechaCortePrev
           AND a.num_producto = p_numproducto
           AND a.status_cred IN ('AA','E1')
		   AND (d.monto_vencido + d.mto_venc_trasp) = 0
           --AND ((b.sdo_cap_insoluto/ b.monto_otorgado)*100)>=vd_usolinea_min
           --AND ((b.sdo_cap_insoluto/ b.monto_otorgado)*100)<=vd_usolinea_max
           AND b.monto_otorgado > 0
           AND d.monto_otorgado > 0
           AND A.fecha_apertura <= vf_vig_fecha_fac
           AND a.num_credito not in (select num_credito from bdicred:sd_grupo_credito where empresa = '001' and fecha_status = dtFechaHoy)

        LET vPorcUtil80 = 0;
        --LET vd_mto_venc_trasp = 0;  mto_fin_ven_trasp
        LET vd_mto_fin_ven_trasp = 0;

        SELECT count(*) INTO vPorcUtil80 FROM bdicred:sd_maesdoshist    -- Al menos uno de los meses previos tuvo 80% de utilizacion
         WHERE fecha >= vf_vig_fecha_fac AND fecha <= dtFechaCortePrev AND empresa = cEmpresa AND num_credito = vc_numcredito
           AND ((sdo_cap_insoluto * 100) / monto_otorgado ) >= vd_usolinea_min
		   AND monto_otorgado > 0;

        SELECT NVL(SUM(mto_fin_ven_trasp),0) INTO vd_mto_fin_ven_trasp  FROM bdicred:"informix".sd_maesdoshist -- Los meses previos no haya tenido vencidos
         WHERE fecha >= vf_vig_fecha_fac AND fecha <= dtFechaCortePrev AND empresa = cEmpresa AND num_credito = vc_numcredito;

        IF ( vPorcUtil80 = 0 OR vd_mto_fin_ven_trasp >= 1 ) THEN -- Si el cliente tuvo un vencido o no tuvo al menos un mes con 80%, no continua.
            CONTINUE FOREACH;
        END IF;

        LET vcontador = 0;
        IF vd_cap_insoluto <=0 THEN
            LET vi_porcentaje_uso = 0;
        ELSE
            LET vi_porcentaje_uso = ((vd_cap_insoluto * 100) / vd_motorgado);
        END IF;
                      
        --LET vcontador  = 0; 
        -- IF vi_porcentaje_usoUM > vd_usolinea_max THEN
        IF vi_porcentaje_uso > vd_usolinea_max THEN -- Rebasa el 100%, es decir, esta sobregirado en el ultimo corte
            LET vcontador  = 1; 
        END IF;   

        IF NOT EXISTS (SELECT * FROM bdicred:sd_grupo_credito WHERE empresa = cEmpresa
                          AND num_credito = vc_numcredito AND numcte = vc_numcte) AND (vcontador = 0)  THEN
                        
            --IF (vd_mto_fin_ven_trasp <= 0) THEN
            BEGIN WORK;                            
                INSERT INTO bdicred:"informix".sd_grupo_credito (empresa, num_producto, num_credito, numcte, grupo, tipo, status_cliente, fecha_status,
                                            status_cred, monto_autorizado, porcentaje_uso, num_historia_efic, user_insert, fecha_insert)
                     VALUES(cEmpresa, vc_numproducto, vc_numcredito, vc_numcte, 'A', 9, 'A', dtFechaHoy, vc_statuscred, vd_motorgado, vi_porcentaje_uso,  --Calculo exclusivo de tarjeta
                                            vi_meses_vigts, 'Informix', dtFechaHoy);       
            COMMIT WORK;						
            --END IF; --IF vd_mto_fin_ven_trasp <= 0 AND                                                                
        ELSE 
            IF (vcontador = 0)  THEN
                BEGIN WORK;
                    UPDATE bdicred:sd_grupo_credito
                       SET fecha_status = dtFechaHoy,
                           status_cred  = vc_statuscred,
                           porcentaje_uso= vi_porcentaje_uso,
                           monto_autorizado=vd_motorgado,
                           num_historia_efic = num_historia_efic + 1
                     WHERE empresa = cEmpresa
                       AND num_credito = vc_numcredito
                       AND numcte  = vc_numcte;
                COMMIT WORK;
            END IF;
        END IF;  --IF NOT EXISTS (SELECT * FROM bdicred:sd_grupo_credito       
    END FOREACH;


    -- Incluye los nuevos creditos cuyo Cliente ya existe como grupo A. Ya que como son nuevos creditos el proceso anterior no los contempla por no cumplir 
    -- los 6 meses de antiguedad o en estatus vigente.
    LET dtFechaCorte1mes = monthadd(dtFechaHoy, - 1);
    LET dtFechaCorte1mes = dtFechaCorte1mes + 1 units day;
 
    FOREACH WITH HOLD
        SELECT a.num_producto, a.num_credito, a.numcte, a.fecha_apertura, a.status_cred, NVL(b.monto_otorgado,0), NVL(b.sdo_cap_insoluto,0)
          INTO vc_numproducto, vc_numcredito, vc_numcte, vf_fechapertu, vc_statuscred, vd_motorgado, vd_cap_insoluto
          FROM bdicred:"informix".sd_maecred a,
               bdicred:"informix".sd_maesdos b,
               bdisolic:ss_resum_scor_fin scor
         WHERE a.empresa = cEmpresa
           AND a.empresa = b.empresa
           AND a.empresa = scor.empresa
           AND a.num_credito = b.num_credito
           AND a.num_credito = scor.num_solicitud
           AND a.num_producto = p_numproducto
           AND a.status_cred IN ('AA','E1')
		   AND (b.monto_vencido + b.mto_venc_trasp) = 0
           AND b.monto_otorgado > 0
           AND a.fecha_apertura >= dtFechaCorte1mes AND a.fecha_apertura <= dtFechaHoy -- Fecha apertura desde la ultima  corrida a la fecha
           AND scor.grupo = 'A'
           AND a.numcte in (Select numcte From bdicred:sd_grupo_cliente)

        IF NOT EXISTS (SELECT * FROM bdicred:sd_grupo_credito WHERE empresa = cEmpresa AND num_credito = vc_numcredito AND numcte = vc_numcte) THEN
                        
            BEGIN WORK;                            
                INSERT INTO bdicred:"informix".sd_grupo_credito (empresa, num_producto, num_credito, numcte, grupo, tipo, status_cliente, fecha_status,
                                            status_cred, monto_autorizado, porcentaje_uso, num_historia_efic, user_insert, fecha_insert)
                     VALUES(cEmpresa, vc_numproducto, vc_numcredito, vc_numcte, 'A', 9, 'A', dtFechaHoy, vc_statuscred, vd_motorgado, vi_porcentaje_uso,  --Calculo exclusivo de tarjeta
                                            vi_meses_vigts, 'Informix', dtFechaHoy);       
            COMMIT WORK;						
        END IF;
    END FOREACH;


    -- /* FMV 9-AGO-12: Esta seccion de codigo se habilitarÃ¡ para la 2a. corrida
    --LET ren_empresa = cEmpresa;
    --LET ren_producto= p_numproducto;  
    --LET ren_credito = vc_numcredito;

    --FMV 5Jul12: Existe el registro en la sd_grupo_credito, entonces busco q no tenga vencido reciente          
    CALL "informix".sp_renueva_grupoa(cEmpresa, p_numproducto, vs_dia_cort_prod, dtFechaHoy) RETURNING v_codigo_retorno, v_mensaje, v_store_pro;
                  

    IF v_codigo_retorno = "00000" THEN           
        LET v_mensaje        = "Proceso filtro grupoa Tarjeta, Termino Correctamente";
        LET v_store_pro      = 'sp_calculo_grupoa';
        --LET vc_intcontproc   = 'F';
        --LET vc_crdcontproc   = 'F';

        UPDATE bdinteg:sx_contproc
           SET status_proc = 'F',
               hora_fin = CURRENT                      
         WHERE empresa = cEmpresa
           AND fecha   = dtFechaHoy 
           AND proceso = vc_tipoproceso;
 
        UPDATE bdicred:sd_contproc
           SET status_proc = 'F',
               hora_fin = CURRENT,
		       mensaje = 'Filtro Grupo A Tarjeta, Termino Correctamente!'
         WHERE empresa = cEmpresa
           AND fecha = dtFechaHoy
           AND proceso = vc_tipoproceso;
    END IF; -- IF v_codigo_retorno = "00000"

    RETURN v_codigo_retorno, v_mensaje, v_store_pro;

END;   --begin    
END PROCEDURE;