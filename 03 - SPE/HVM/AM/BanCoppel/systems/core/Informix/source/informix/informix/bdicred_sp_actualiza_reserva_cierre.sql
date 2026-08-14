CREATE PROCEDURE "informix".sp_actualiza_reserva_cierre(pEmpresa CHAR(3),dFecha DATE)
RETURNING 
          CHAR(6)  AS resultado,
          CHAR(80) AS mensaje,
          CHAR(10) AS registros;

DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE cCodRet               CHAR(6); 
DEFINE cMensajeRet           CHAR(80);

DEFINE cBegin                 CHAR(1);
DEFINE vcontador_insert       INTEGER;
DEFINE dtFechaHoy             DATE;
DEFINE dtFechaUltMes          DATE;
DEFINE dtFechaCorte            DATE;
DEFINE vult_hab_mes 	      DATE;
DEFINE vprox_fecha            DATE;
DEFINE vpri_hab_mes		      DATE;
DEFINE vstatus_proc 		  CHAR(1);
DEFINE vImporteReservaBuroCC  DECIMAL(18,5);
DEFINE vtotal_capitalizado    DECIMAL(18,5);
DEFINE vmonto_capitalizado    DECIMAL(18,5);
DEFINE vcodigo_ref            INTEGER;
DEFINE iCuotasVdas            INTEGER;
DEFINE vNvoPeriodo            INTEGER;
DEFINE cPeriodicidad          CHAR(1);
DEFINE vTotal                 DECIMAL(18,5);
DEFINE vInteres_venc          DECIMAL(18,5);
DEFINE vProducto 		      CHAR(4);
DEFINE vSucursal 		      CHAR(4);
DEFINE vDivisa 			      CHAR(2);
DEFINE vStatusCred            CHAR(02);
DEFINE dConsPI                DECIMAL(18,5);
DEFINE dConsPORPAGO           DECIMAL(18,5);
DEFINE dConsPORUSO            DECIMAL(18,5);
DEFINE dPorPagoMin            DECIMAL(18,5);
DEFINE dPorcUsoMin            DECIMAL(18,5);
DEFINE dpiEI                  DECIMAL(18,5);
DEFINE dMeses                 INTEGER;
DEFINE dPIdefaul              DECIMAL(18,5);
DEFINE dConsSPMenor           DECIMAL(18,5);
DEFINE dConsSPMenordos        DECIMAL(18,5);
DEFINE dConsComPI             DECIMAL(18,5);
DEFINE cNumCredito            CHAR(20);
DEFINE dPagos                 DECIMAL(18,5);
DEFINE dImpagosCons           DECIMAL(18,5);
DEFINE dImpagosHist           DECIMAL(18,5);
DEFINE dMesesAntiguedad       DECIMAL(18,5);
DEFINE dLinCredAut            DECIMAL(18,5);
DEFINE dEndeudamientoTotCierre  DECIMAL(18,5);
DEFINE dEndeudamientoTotCorte DECIMAL(18,5);
DEFINE dEndeudamientoTotCalc  DECIMAL(18,5);
DEFINE dLimiteCredito         DECIMAL(18,5);
DEFINE dPorUso                DECIMAL(18,5);
DEFINE dPorPago               DECIMAL(18,5);
DEFINE dPagosnunca            DECIMAL(18,5);
DEFINE dSaldoTarjeta          DECIMAL(18,5);
DEFINE dMax                   DECIMAL(18,5);
DEFINE dEI                    DECIMAL(18,5);
DEFINE dEICal                 DECIMAL(18,5);
DEFINE dPI                    DECIMAL(18,5);
DEFINE dSP                    DECIMAL(18,5);
DEFINE dPorcentajeReserva     DECIMAL(18,5);
DEFINE dPorcentajeReserva_prev     DECIMAL(18,5);
DEFINE cGradoRiesgo           CHAR(2);
DEFINE cGradoRiesgoGradual    CHAR(2);
DEFINE cGradoRiesgoEdoResultados    CHAR(2);
DEFINE cGradoRiesgoBancoppel    CHAR(2); 
DEFINE dPorUsoMinCtesNunca    DECIMAL(18,5);

DEFINE dResInteresVen         DECIMAL(18,5);
DEFINE dResBuro               DECIMAL(18,5);
DEFINE dResCalificacion       DECIMAL(18,5);
DEFINE dResCalificacionNueva  DECIMAL(18,5);
DEFINE iClienteNunca          INTEGER;
DEFINE dLineaAutorizada       DECIMAL(18,5);
DEFINE dEvaBuro               CHAR(01);
DEFINE iContInteres           INTEGER;
DEFINE vIntCapitalizado       DECIMAL(18,5);
DEFINE dtFechaApertura        DATE;
DEFINE iANT                   DECIMAL(18,5);
DEFINE dtFechaPeriodo         DATE;
DEFINE dPagoRealizado         DECIMAL(18,5);
DEFINE dConsMinPorUso         DECIMAL(18,5);
DEFINE dConsMaxPorUso         DECIMAL(18,5);
DEFINE dPorSaldoMin           DECIMAL(18,5);
DEFINE dConsMaxPorPago        DECIMAL(18,5);
DEFINE dConsMinPorPago        DECIMAL(18,5);
DEFINE dConsACT               DECIMAL(18,5);
DEFINE dConsHIST              DECIMAL(18,5);
DEFINE dConsANT               DECIMAL(18,5);
DEFINE iACT                   INTEGER;
DEFINE iHIST                  INTEGER;
DEFINE iTipoCliente           INTEGER;
DEFINE dDiaCorte              CHAR(02);
DEFINE sExisten               SMALLINT;
DEFINE dImporteReserva        DECIMAL(18,5);
DEFINE vReservaGradual        DECIMAL(18,5);
DEFINE vPorcentajeGradual     DECIMAL(18,5);
DEFINE vPorcentajeEdoResultados  DECIMAL(18,5);
DEFINE dReservaCalifMesAnterior  DECIMAL(18,5);
DEFINE dReservaEdoResultados     DECIMAL(18,5);
DEFINE dGradual                  DECIMAL(18,5);
DEFINE dReservaBuroGradual       DECIMAL(18,5);
DEFINE dReservaIntCredVenGradual DECIMAL(18,5);
DEFINE dReserva_aconstituir   DECIMAL(18,5);
DEFINE dreserva_calif_mes_anterior  DECIMAL(18,5);
DEFINE dreserva_calificacion  DECIMAL(18,5);
DEFINE dReserva_calificacion_gradual  DECIMAL(18,5);
DEFINE ddiferencia          DECIMAL(18,5);
DEFINE dinteres_cred_ven     DECIMAL(18,5);


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      ---COMMIT WORK;
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      LET cMensajeRet= cNumCredito;

      IF cBegin= 'S' THEN
        ROLLBACK WORK;
      END IF;

/*
      SELECT status_proc
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
       
          UPDATE sd_contproc SET status_proc = "C", mensaje = "PROCESO CANCELADO"
           WHERE empresa = pempresa    and
                 proceso = "califcart" and
                 fecha   = dtFechaHoy;

          UPDATE bdinteg:sx_contproc SET status_proc = "C"
           WHERE empresa = pempresa    and
                 proceso = "califcart" and
		         sistema = "06"        and 
                 fecha   = dtFechaHoy;
                 
      end if
   */
      RETURN cCodRet, cMensajeRet, vcontador_insert;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "sp_actualiza_reserva_cierre.out";
--TRACE ON;

LET cCodRet= '000000';
LET cMensajeRet= 'El proceso de ACTUALIZACION DEL CIERRE se realizó correctamente';

LET cBegin= 'F';
LET vcontador_insert= 0;
LET dtFechaHoy= DATE(1);
LET dtFechaCorte= DATE(1);
LET vult_hab_mes= DATE(1);
LET vprox_fecha= DATE(1);
LET vpri_hab_mes= DATE(1);
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
LET dMeses= 0;
LET dPIdefaul= 0;
LET dConsSPMenor= 0;
LET dConsSPMenordos= 0;
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
LET dPorUso= 0;
LET dPorPago= 0;
LET dSaldoTarjeta= 0;
LET dMax= 0;
LET dEI= 0;
LET dEICal= 0;
LET dPI= 0;
LET dSP= 0;
LET dPorcentajeReserva= 0;
LET dPorcentajeReserva_prev= 0;
LET cGradoRiesgo= '';
LET dPorUsoMinCtesNunca= 0;

LET dResInteresVen= 0;
LET dResBuro= 0;
LET dResCalificacion= 0;
LET dResCalificacionNueva= 0;
LET iClienteNunca= 0;
LET dLineaAutorizada= 0;
LET dEvaBuro= '';
LET iContInteres= 0;
LET vIntCapitalizado= 0;
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
LET iTipoCliente= 0;
LET dDiaCorte = '';
LET sExisten = 0;
LET dImporteReserva = 0;
LET vReservaGradual = 0;
LET vPorcentajeGradual = 0;
LET dReservaCalifMesAnterior = 0;
LET dReservaEdoResultados = 0;
LET dGradual = 0;
LET dReservaBuroGradual = 0;
LET dReservaIntCredVenGradual  = 0;
LET cGradoRiesgo               = '';
LET cGradoRiesgoGradual        = '';
LET cGradoRiesgoEdoResultados  = '';
LET cGradoRiesgoBancoppel      = ''; 
LET dReserva_aconstituir       = 0;
LET dreserva_calif_mes_anterior  =0;
LET dreserva_calificacion  =0;
LET dReserva_calificacion_gradual  =0;
LET ddiferencia  =0;
LET dinteres_cred_ven  =0;

--
-- Carga de parametros
--   

 SELECT valor 
   INTO dConsPI
   FROM bdicred:sd_param_reservas 
  where empresa = pEmpresa
  and cod_param= '3';

 IF dConsPI IS NULL THEN
   LET cCodRet= '000003';
   LET cMensajeRet= 'FALTA CONSTANTE PARA PROBABILIDAD DE INCUMPLIMIENTO PI';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
 END IF;

 SELECT valor 
   INTO dConsACT
   FROM bdicred:sd_param_reservas 
  where empresa = pEmpresa
  and cod_param= '4';

 IF dConsACT IS NULL THEN
    LET cCodRet= '000040';
    LET cMensajeRet= 'FALTA CONSTANTE IMPAGO ACTUAL PI';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
 END IF;

 SELECT valor 
   INTO dConsHIST
   FROM bdicred:sd_param_reservas
  where empresa = pEmpresa 
  and cod_param= '5';

 IF dConsHIST IS NULL THEN
    LET cCodRet= '000050';
    LET cMensajeRet= 'FALTA CONSTANTE IMPAGO HISTORICO PI';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
 END IF;

 SELECT valor 
   INTO dConsANT
   FROM bdicred:sd_param_reservas
  where empresa = pEmpresa 
  and cod_param= '6';

 IF dConsANT IS NULL THEN
    LET cCodRet= '000060';
    LET cMensajeRet= 'FALTA CONSTANTE ANTIGÜEDAD PI';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
 END IF;

 SELECT valor 
   INTO dConsPORPAGO
   FROM bdicred:sd_param_reservas
  where empresa = pEmpresa 
  and cod_param= '7';

 IF dConsPORPAGO IS NULL THEN
   LET cCodRet= '000007';
   LET cMensajeRet= 'FALTA CONSTANTE PARA EL CALCULO DE PORCENTAJE PAGO PI';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
 END IF;

 SELECT valor 
   INTO dConsPORUSO
   FROM bdicred:sd_param_reservas 
  where empresa = pEmpresa
  and cod_param= '8';

 IF dConsPORUSO IS NULL THEN
    LET cCodRet= '000008';
    LET cMensajeRet= 'FALTA CONSTANTE PARA EL CALCULO DE PORCENTAJE USO PI';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
 END IF;

 SELECT valor 
   INTO dPorPagoMin
   FROM bdicred:sd_param_reservas
  where empresa = pEmpresa 
  and cod_param= '9';

 IF dPorPagoMin IS NULL THEN
   LET cCodRet= '000009';
   LET cMensajeRet= 'FALTA PORCENTAJE PAGO MÍNIMO';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
 END IF;

 SELECT valor 
   INTO dPorcUsoMin
   FROM bdicred:sd_param_reservas
  where empresa = pEmpresa 
  and cod_param= '10';

 IF dPorcUsoMin IS NULL THEN
   LET cCodRet= '000010';
   LET cMensajeRet= 'FALTA PORCENTAJE USO MÍNIMO';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
 END IF;

 SELECT valor 
   INTO dpiEI
   FROM bdicred:sd_param_reservas
  where empresa = pEmpresa 
  and cod_param= '11';
    
 IF dpiEI IS NULL THEN
   LET cCodRet= '000011';
   LET cMensajeRet= 'FALTA EXPOSICIÓN AL MOMENTO DE INCUMPLIMIENTO';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
 END IF;

 SELECT valor 
   INTO dMeses
   FROM bdicred:sd_param_reservas
  where empresa = pEmpresa 
  and cod_param= '12';

 IF dMeses IS NULL THEN
   LET cCodRet= '000012';
   LET cMensajeRet= 'FALTA NÚMERO DE MESES';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
 END IF;

 SELECT valor 
   INTO dPIdefaul
   FROM bdicred:sd_param_reservas 
  where empresa = pEmpresa
  and cod_param= '13';

 IF dPIdefaul IS NULL THEN
   LET cCodRet= '000013';
   LET cMensajeRet= 'FALTA CONSTANTE PARA PROBABILIDAD DE INCUMPLIMIENTO >=4';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
 END IF;

 SELECT valor 
   INTO dConsSPMenor
   FROM bdicred:sd_param_reservas
  where empresa = pEmpresa 
  and cod_param= '14';
    
 IF dConsSPMenor IS NULL THEN
   LET cCodRet= '000014';
   LET cMensajeRet= 'FALTA CONSTANTE SEVERIDAD DE LA PERDIDA CUANDO ACT<12 ';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
 END IF;
    
 SELECT valor 
   INTO dConsSPMenordos
   FROM bdicred:sd_param_reservas
  where empresa = pEmpresa 
  and cod_param= '15';

 IF dConsSPMenordos IS NULL THEN
   LET cCodRet= '000015';
   LET cMensajeRet= 'FALTA CONSTANTE SEVERIDAD DE LA PERDIDA CUANDO ACT>=12';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
 END IF;

 SELECT valor 
   INTO dConsComPI
   FROM bdicred:sd_param_reservas
  where empresa = pEmpresa 
  and cod_param= '16';

 IF dConsComPI IS NULL THEN
   LET cCodRet= '000016';
   LET cMensajeRet= 'FALTA CONSTANTE COMPARACIÓN PARA PI';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
 END IF;

  SELECT valor 
    INTO dPorSaldoMin
    FROM bdicred:sd_param_reservas
   where empresa = pEmpresa 
   and cod_param= '17';
    
  IF dPorSaldoMin IS NULL THEN
     LET cCodRet= '000170';
     LET cMensajeRet= 'FALTA PARAMETRO PORCENTAJE DE SALDO MINIMO';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
  END IF;

 SELECT valor 
   INTO dPorUsoMinCtesNunca
   FROM bdicred:sd_param_reservas
  where empresa = pEmpresa 
  and cod_param= '19';

 IF dPorUsoMinCtesNunca IS NULL THEN
   LET cCodRet= '000019';
   LET cMensajeRet= 'FALTA PORCENTAJE USO MINIMO CLIENTES NUNCA';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
 END IF;

 SELECT valor 
   INTO dConsMinPorPago
   FROM bdicred:sd_param_reservas
  where empresa = pEmpresa 
  and cod_param= '21';
 
 IF dConsMinPorPago IS NULL THEN
    LET cCodRet= '000210';
    LET cMensajeRet= 'FALTA VALOR MINIMO COMPARATIVO % DE PAGO';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
 END IF;

 SELECT valor 
   INTO dConsMaxPorPago
   FROM bdicred:sd_param_reservas
  where empresa = pEmpresa 
  and cod_param= '22';
    
  IF dConsMaxPorPago IS NULL THEN
     LET cCodRet= '000220';
     LET cMensajeRet= 'FALTA MAXIMO COMPARATIVO % DE PAGO';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
  END IF;

 SELECT valor 
   INTO dConsMinPorUso
   FROM bdicred:sd_param_reservas
  where empresa = pEmpresa 
  and cod_param= '23';
    
 IF dConsMinPorUso IS NULL THEN
    LET cCodRet= '000230';
    LET cMensajeRet= 'FALTA MINIMO COMPARATIVO % DE USO';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
 END IF;

 SELECT valor 
   INTO dConsMaxPorUso
   FROM bdicred:sd_param_reservas
  where empresa = pEmpresa 
  and cod_param= '24';
    
 IF dConsMaxPorUso IS NULL THEN
    LET cCodRet= '000240';
    LET cMensajeRet= 'FALTA MAXIMO COMPARATIVO % DE USO';
   RETURN cCodRet, cMensajeRet, vcontador_insert;
 END IF;


FOREACH WITH HOLD

    -- Se obtienen los créditos calificados con corte al 20.
    SELECT a.num_credito, CASE WHEN b.num_periodos IS NULL THEN 0 ELSE b.num_periodos END, CASE WHEN b.pagos_realizados IS NULL THEN 0 ELSE b.pagos_realizados END, 
           CASE WHEN b.impagos_consecutivos IS NULL THEN 0 ELSE b.impagos_consecutivos END, CASE WHEN b.impagos_historicos IS NULL THEN 0 ELSE b.impagos_historicos END, 
           b.meses_antiguedad,a.fecha_apertura,
           a.periodo_plazo, a.num_producto, a.sucursal, a.divisa, a.status_cred,
           (b.probabilidad_incumplimiento/100), (b.severidad_perdida/100), b.limite_credito, b.antecedente_buro,
           NVL(c.sdo_capital,0) + NVL(c.cap_tras_no_venci,0) + NVL(c.monto_vencido,0) + NVL(c.mto_venc_trasp,0),
           b.saldo_corte,
           nvl(reserva_calif_mes_anterior,0),interes_cred_ven
           ,b.meses_antiguedad,b.impagos_consecutivos,b.impagos_historicos,(porcentaje_pago/100),(porcentaje_uso/100)
           ,b.fecha_corte
      INTO cNumCredito, iCuotasVdas, dPagos, dImpagosCons, dImpagosHist, dMesesAntiguedad,
           dtFechaApertura,cPeriodicidad, vProducto, vSucursal, vDivisa, vStatusCred,
           dPI, dSP,dLimiteCredito,dEvaBuro,
           dEndeudamientoTotCierre,dEndeudamientoTotCorte,
           dReservaCalifMesAnterior,dinteres_cred_ven
           ,iANT,iACT,iHIST,dPorPago,dPorUso
           ,dtFechaCorte
      FROM bdicred:sd_maecredcont a
--           left outer join bdicred:sd_hist_reserva b on a.empresa = b.empresa AND a.num_credito = b.num_credito AND b.fecha_corte = mdy(month(a.fecha),20,year(a.fecha))
           join bdicred:sd_hist_reserva b on a.empresa = b.empresa AND a.num_credito = b.num_credito AND a.fecha = b.fecha_cierre
           join bdicred:sd_maesdoscont c on a.empresa = c.empresa  AND a.num_credito = c.num_credito and c.fecha = a.fecha
--           join bdicred:sd_maecredanexo d on a.empresa = d.empresa AND a.num_credito = d.num_credito
     WHERE a.empresa = pEmpresa
       and a.fecha = dFecha
       AND b.fecha_corte >= mdy(month(dFecha),20,month(dFecha))
       and a.num_credito > ''
--       and a.num_credito='600000110905'

     IF (vcontador_insert = 0) THEN
       LET cBegin= 'S';
       BEGIN WORK;
     END IF;
/*
--Calculo del %Uso
    IF dEndeudamientoTotCierre > 0 AND dLimiteCredito > 0 THEN
       LET dPorUso = dEndeudamientoTotCierre / dLimiteCredito; 
    ELIF (dEndeudamientoTotCierre > 0 AND dLimiteCredito <= 0) OR dEndeudamientoTotCierre <= 0 THEN
       LET dPorUso = 0.40; 
    END IF;
*/
--Se determina límite inferior y superior del %Uso
--rss   IF dPorUso > dConsMaxPorUso THEN LET dPorUso = dConsMaxPorUso; ELIF dPorUso < dConsMinPorUso THEN LET dPorUso = dConsMinPorUso; END IF; 


                   IF iACT < dConsComPI THEN
                      LET dPI = (1/(1 + EXP(-(dConsPI + (dConsACT * iACT) + (dConsHIST * iHIST) + (dConsANT * iANT) + (dConsPORPAGO * dPorPago) + (dConsPORUSO * dPorUso)))));
                   ELSE
                      LET dPI = dPIdefaul;
                   END IF;

/*
LET dConsPI =dConsPI;
let dConsACT =dConsACT;
let iACT=iACT;
let dConsHIST=dConsHIST;
let iHIST=iHIST;
let dConsANT =dConsANT;
let iANT=iANT;
let dConsPORPAGO=dConsPORPAGO;
let dPorPago=dPorPago;
let dConsPORUSO =dConsPORUSO;
let dPorUso=dPorUso;

let dPI = dPI ;

RETURN cCodRet, cMensajeRet, vcontador_insert;
*/
--Calcula del dMax
    if (dEndeudamientoTotCierre > 0) then 
        if ( dLimiteCredito > 0 ) then
            let dPorUso = dEndeudamientoTotCierre / dLimiteCredito;
        else 
            let dPorUso = 0.40;
        end if;
    else
        let dPorUso = 0.40;
    end if;

IF dPorUso > dConsMaxPorUso THEN LET dPorUso = dConsMaxPorUso; ELIF dPorUso < dConsMinPorUso THEN LET dPorUso = dConsMinPorUso; END IF; 


    IF dPorUso = 0 THEN
       LET dMax = 1;
    ELIF dPorUso > 0 THEN
--       LET dMax = MAX(dPorUso^-0.5784,1)
       LET dMax= POW(dPorUso, dpiEI);
        IF dMax < 1 THEN
           LET dMax= 1;
        END IF;
    END IF;

--Calcula del dEI
     IF dEndeudamientoTotCierre > 0 THEN
        LET dEICal = dEndeudamientoTotCierre * dMax;
     ELIF dPagos > 0 THEN
        LET dEICal = (dPorSaldoMin * dLimiteCredito) * dMax;
     else 
        LET dEICal = dEndeudamientoTotCierre + dLimiteCredito;
     END IF;

    IF dImpagosCons > 0 THEN
       LET dEI = dEndeudamientoTotCierre;
    else 
       LET dEI = dEICal;
    END IF;

--Se calcula el % de reserva
    IF dEndeudamientoTotCierre <= 0 then
      if dPagos = 0 THEN
         LET dPorcentajeReserva_prev = 0.0268;
      else
        LET dPorcentajeReserva_prev = dPI * dSP;
      end if;
    else
      LET dPorcentajeReserva_prev = dPI * dSP;
    END IF;

    IF (dEndeudamientoTotCierre <= 0 ) then
        if ( dPagos > 0 ) then
          LET dPorcentajeReserva = 0;
        else
          LET dPorcentajeReserva = dPorcentajeReserva_prev;
        end if;
    else
         LET dPorcentajeReserva = dPorcentajeReserva_prev;
    END IF;

--Determina reserva de la calificación 
   LET dResCalificacion = dPorcentajeReserva * dEICal;
   LET dResCalificacionNueva = dPorcentajeReserva * dEI;
   LET vReservaGradual = dResCalificacionNueva * (24 / 48);
 

--Determina reserva de Buró 
   IF dEvaBuro = '1' THEN   
      LET vImporteReservaBuroCC = vReservaGradual * 0.15;
      LET dReservaBuroGradual = vReservaGradual * 0.15;
   ELSE
      LET vImporteReservaBuroCC = 0;
      let dReservaBuroGradual = 0;
   END IF;

--Determina reserva de interés 
    
    let vtotal_capitalizado = 0;

    if ( vStatusCred IN ('BT','E2','E3')) then
       if dinteres_cred_ven < 0 then let dinteres_cred_ven = 0; end if;

       if ( vReservaGradual <= 0 ) then
           if ( dEndeudamientoTotCierre <= 0 ) then
              let vtotal_capitalizado = 0;
           else
              if ( dEndeudamientoTotCierre >= dinteres_cred_ven ) then
                 let vtotal_capitalizado = dinteres_cred_ven;
              else
                 let vtotal_capitalizado = dEndeudamientoTotCierre;
              end if;
           end if;
--mayor a cero
       else
           if ( dEndeudamientoTotCierre <= 0 ) then
             let vtotal_capitalizado = 0;
           else
             LET vtotal_capitalizado = (1 - (vReservaGradual / dEndeudamientoTotCierre)) * dinteres_cred_ven;
           end if; 
       end if;
   end if;


--Determina PORCENTAJE RESERVA estado de resultados
           if (dEI > 0) then
              LET vPorcentajeEdoResultados=vReservaGradual/dEI;
           else
              LET vPorcentajeEdoResultados=0.0;
           end if;

--sd_grado_riesgo -> tipo = '0' -> grado de riesgo contable
--sd_grado_riesgo -> tipo = '1' -> grado de riesgo Bancoppel
--Determina GRADO RIESGO estado de resultados
            SELECT a.grado_riesgo
              INTO cGradoRiesgoEdoResultados
              FROM bdicred:sd_grado_riesgo a
             WHERE empresa = pEmpresa
               AND tipo = '0'
               AND(round(vPorcentajeEdoResultados * 100,2) >= a.porcentaje_min
               AND round(vPorcentajeEdoResultados * 100,2) <= a.porcentaje_max);

-- Se obtiene el grado de riesgo del crédito (Calificación) en base al % de riesgo a constituir
        SELECT a.grado_riesgo
          INTO cGradoRiesgo
          FROM bdicred:sd_grado_riesgo a
         WHERE empresa = pEmpresa
           AND tipo = '0'
           AND (round(dPorcentajeReserva * 100,2) >= a.porcentaje_min  
           AND round(dPorcentajeReserva * 100,2) <= a.porcentaje_max);

--Determina GRADO RIESGO Bancoppel
            SELECT a.grado_riesgo
              INTO cGradoRiesgoBancoppel
              FROM bdicred:sd_grado_riesgo a
             WHERE empresa = pEmpresa
               AND tipo = '1'
               AND(round(vPorcentajeEdoResultados * 100,2) >= a.porcentaje_min
               AND round(vPorcentajeEdoResultados * 100,2) <= a.porcentaje_max);


            UPDATE informix.sd_hist_reserva
                 SET 
--                         fecha_cierre              = dtFechaHoy, 
                         grado_riesgo              = cGradoRiesgo,
                         saldo_cierre              = dEndeudamientoTotCierre,  --ok ok
--                         reserva_int_cred_ven      = vtotal_capitalizado,    --ok nok
--                         interes_cred_ven          = vIntCapitalizado,
--                         reserva_buro              = vImporteReservaBuroCC,  --ok ok
                         reserva_calificacion      = dResCalificacionNueva,  --ok nok
                         porcentaje_reserva        = dPorcentajeReserva * 100,
                         exposicion_incumplimiento = dEI,
--                         grado_riesgo_gradual      = cGradoRiesgoGradual,
                         exposicion_inc_gradual    = dEI,
                         reserva_calificacion_gradual = vReservaGradual,  --ok
                         porcentaje_reserva_gradual   = vPorcentajeEdoResultados*100, --??
                         reserva_buro_gradual         = vImporteReservaBuroCC,
                         probabilidad_incumplimiento   = dPI*100, --temporal solo para validar el dato de PI
                         reserva_buro_gradual         = dReservaBuroGradual,
                         reserva_int_cred_ven_gradual = vtotal_capitalizado,
                         grado_riesgo_bancoppel       = cGradoRiesgoBancoppel, --??
                         grado_riesgo_edo_resultados  = cGradoRiesgoEdoResultados, --??
                         reserva_edo_resultados       = vReservaGradual,
                         porcentaje_reserva_edo_resultados = vPorcentajeEdoResultados*100  --??
            WHERE empresa = pEmpresa
              AND num_credito = cNumCredito
              AND fecha_corte = dtFechaCorte;
--              AND fecha_cierre = dFecha;

    LET vcontador_insert = vcontador_insert + 1;

    IF (vcontador_insert >= 60000) THEN
        COMMIT WORK;
        LET vcontador_insert = 0;
--        UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_hist_reserva;
    END IF;

--inicializa variables
let cNumCredito='';
let iCuotasVdas=0; 
let dPagos=0;
let dImpagosCons=0;
let dImpagosHist=0;
let dMesesAntiguedad=0;
let dtFechaApertura=date(0);
let cPeriodicidad='';
let vProducto='';
let vSucursal='';
let vDivisa='';
let vStatusCred='';
let dPI=0;
let dSP=0;
let dLimiteCredito=0;
let dEvaBuro='';
let dEndeudamientoTotCierre=0;
let dEndeudamientoTotCorte=0;
let dReservaCalifMesAnterior=0;
let dinteres_cred_ven=0;
let iANT=0;
let iACT=0;
let iHIST=0;
let dPorPago=0;
let dReservaBuroGradual=0;
let vImporteReservaBuroCC=0;

END FOREACH;

/*
LET cNumCredito = '';

select nvl(sum(reserva_calif_mes_anterior),0), nvl(sum(reserva_calificacion),0), nvl(sum(reserva_calificacion_gradual),0)
into dReserva_calif_mes_anterior, dReserva_calificacion, dReserva_calificacion_gradual
from sd_hist_reserva where empresa='001' and fecha_corte > date(0) and num_credito > '' and fecha_cierre=mdy('08','31','2009');

--Se determina la reserva a constitnuir
IF dreserva_calif_mes_anterior > dReserva_calificacion_gradual THEN
--Se suman las reservas del mes anterior, la actual normal y la actual gradual
   LET dDiferencia = dReserva_calif_mes_anterior - dReserva_calificacion_gradual;

   FOREACH 
       select num_credito,fecha_corte,(reserva_calificacion_gradual / dReserva_calificacion_gradual) * dDiferencia
         into cNumCredito,dtFechaCorte,dReserva_aconstituir
       from sd_hist_reserva where empresa='001' and fecha_corte > date(0) and num_credito > '' and fecha_cierre=mdy('08','31','2009')

       update sd_hist_reserva 
          set reserva_edo_resultados = dReserva_aconstituir
        where empresa='001' and fecha_corte = dtFechaCorte and num_credito = cNumCredito and fecha_cierre=mdy('08','31','2009');

   END FOREACH;
ELIF dreserva_calif_mes_anterior < dReserva_calificacion_gradual THEN
   FOREACH 
       select num_credito,fecha_corte,reserva_calificacion_gradual
         into cNumCredito,dtFechaCorte,dReserva_aconstituir
       from sd_hist_reserva where empresa='001' and fecha_corte > date(0) and num_credito > '' and fecha_cierre=mdy('08','31','2009')

       update sd_hist_reserva 
          set reserva_edo_resultados = dReserva_aconstituir
        where empresa='001' and fecha_corte = dtFechaCorte and num_credito = cNumCredito and fecha_cierre=mdy('08','31','2009');
   END FOREACH;
END IF
*/

IF (vcontador_insert > 0) THEN
  COMMIT WORK;
END IF;

LET cCodRet = "000000";
       -- Actualiza el Control de Procesos
       
RETURN cCodRet, cMensajeRet, vcontador_insert;
    
END
END PROCEDURE
;