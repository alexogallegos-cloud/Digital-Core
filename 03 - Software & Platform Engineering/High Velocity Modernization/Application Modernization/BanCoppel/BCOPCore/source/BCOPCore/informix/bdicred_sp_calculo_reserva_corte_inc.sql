CREATE PROCEDURE "informix".sp_calculo_reserva_corte_inc(pEmpresa CHAR(3))

RETURNING 
          CHAR(6)  AS resultado,
          CHAR(80) AS mensaje;
		  
--  execute procedure "informix".sp_calculo_reserva_corte('001');
          
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE cCodRet               CHAR(6); 
DEFINE cMensajeRet           CHAR(80);

DEFINE cBegin                CHAR(1);
DEFINE vcontador_insert      INTEGER;
DEFINE sNumeroCredito        CHAR(20);
DEFINE auxNumeroCredito      CHAR(20);
DEFINE dtFechaCalculo        DATE;
DEFINE dtFechaUltMes         DATE;
DEFINE dFechaCorte           DATE;
DEFINE dFechaPeriodoAnterior DATE;
DEFINE dfechaini             DATE;
DEFINE dEndeudamientoTot     DECIMAL(18,5);
DEFINE dtFechaApertura       DATE;
DEFINE dtFechaCorte       DATE;
DEFINE dPagoRealizado        DECIMAL(18,5);
DEFINE cPeriodicidad         CHAR(1);
DEFINE iACT                  INTEGER;
DEFINE iHIST                 INTEGER;
DEFINE iANT                  DECIMAL(18,5);
DEFINE dQuincenal            DECIMAL(18,5);
DEFINE dSemanal              DECIMAL(18,5);
DEFINE dIncumplimiento       DECIMAL(18,5);
DEFINE cStatusCred           CHAR(2);  
DEFINE iBanderaConc          INTEGER;  
DEFINE i                     INTEGER;
DEFINE vcuotasvenc           INTEGER;
DEFINE dPorPago              DECIMAL(18,5);
DEFINE dPorUso               DECIMAL(18,5);

DEFINE dPorPagoMin           DECIMAL(18,5);
DEFINE dPorUsoMin            DECIMAL(18,5);
DEFINE dPorSaldoMin          DECIMAL(18,5);
DEFINE dLimiteCredito        DECIMAL(18,5);
DEFINE dImpPerConACT         DECIMAL(18,5);
DEFINE dImpObsHIST           DECIMAL(18,5);
DEFINE dPorResSic            DECIMAL(18,5);

DEFINE dConsComPI            DECIMAL(18,5);
DEFINE dConsPI               DECIMAL(18,5);
DEFINE dConsACT              DECIMAL(18,5);
DEFINE dConsHIST             DECIMAL(18,5);
DEFINE dConsANT              DECIMAL(18,5);
DEFINE dConsPORPAGO          DECIMAL(18,5);
DEFINE dConsPORUSO           DECIMAL(18,5);
DEFINE dPI                   DECIMAL(18,5);
DEFINE dPIdefaul             DECIMAL(18,5);
DEFINE dPorUsoMinCtesNunca   DECIMAL(18,5);

DEFINE dConsSPMenor          DECIMAL(18,5);
DEFINE dConsSPMayor          DECIMAL(18,5);
DEFINE dSP                   DECIMAL(18,5);
DEFINE dEvaBuro              CHAR(01);
DEFINE dLineaAutorizada      DECIMAL(18,5);
DEFINE dConsMinPorPago       DECIMAL(18,5);
DEFINE dConsMaxPorPago       DECIMAL(18,5);
DEFINE dConsMinPorUso        DECIMAL(18,5);
DEFINE dConsMaxPorUso        DECIMAL(18,5);
DEFINE dPagoMinimo           DECIMAL(18,5);
DEFINE dImporteReservaMesAnt DECIMAL(18,5);
DEFINE dFechaMesAnt          DATE;
DEFINE v_iva_suc   			 DECIMAL(18,2);
DEFINE v_sucursal            CHAR(4);
DEFINE dMoratorios           DECIMAL(18,2);
DEFINE dInteVencIva          DECIMAL(18,2);
DEFINE dResCalificacion      DECIMAL(18,5);
DEFINE dPorcResCalificacion  DECIMAL(18,5);
DEFINE cGradoRiesgo          CHAR(2);
DEFINE vReservaGradual       DECIMAL(18,5);
DEFINE dGradual              DECIMAL(18,5);
DEFINE vImporteReservaBuroCC DECIMAL(18,5);
DEFINE dIvaVencido           DECIMAL(18,5);
DEFINE vProducto             CHAR(4);
DEFINE vNvoPeriodo           INTEGER;
DEFINE vDivisa               CHAR(2);
DEFINE cGradoRiesgoBancoppel CHAR(2);
--TEMPORAL para el reproceso de cosechas
DEFINE Tmonto_vencido        DECIMAL(18,5);
DEFINE Tmto_venc_trasp       DECIMAL(18,5);
DEFINE Tsdo_capital          DECIMAL(18,5);
DEFINE Tsdo_cap_insoluto     DECIMAL(18,5);
--TEMPORAL para el reproceso de cosechas
DEFINE dFechaAct             DATE;
DEFINE dDiaCorte             CHAR(02);
DEFINE cCreditoExterno       CHAR(20);
DEFINE dDiasXMes             DECIMAL(18,5);
--A.L.L. Saldos de Credisolucion
DEFINE cNumCreditoCrd		 CHAR(20);

DEFINE dSaldoAlCorteCrd	     DECIMAL(18,5);
DEFINE sNivelRiesgoAlto		 SMALLINT;
DEFINE sNivelRiesgoMedio	 SMALLINT;
DEFINE sNivelRiesgoBajo		 SMALLINT;

DEFINE dPagosRealizados1PeriodosAnt		DECIMAL(18,5);
DEFINE dSaldoCorte2PeriodosAnt			DECIMAL(18,5);
DEFINE dPagosRealizados2PeriodosAnt		DECIMAL(18,5);
DEFINE dSaldoCorte3PeriodosAnt			DECIMAL(18,5);
DEFINE dPagosRealizados3PeriodosAnt	DECIMAL(18,5);
DEFINE dSaldoCorte4PeriodosAnt			DECIMAL(18,5);
DEFINE dPagosRealizados4PeriodosAnt		DECIMAL(18,5);
DEFINE dFecha1PeriodosAnt		DATE;
DEFINE dFecha2PeriodosAnt		DATE;
DEFINE dFecha3PeriodosAnt		DATE;
DEFINE dFecha4PeriodosAnt		DATE;

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

 
LET iSqlErr=0;
LET iIsamErr=0;
LET cErrorInfo="";
LET cCodRet= '000000';
LET cMensajeRet= 'El proceso de CALIFICACION DEL CORTE se realizó correctamente';
LET cBegin= 'F';
LET vcontador_insert= 0;
LET sNumeroCredito="";
LET auxNumeroCredito="";
LET dtFechaCalculo= DATE(1);
LET dtFechaUltMes= DATE(1);
LET dFechaCorte=DATE(1);
LET dFechaPeriodoAnterior=DATE(1);
LET dfechaini=DATE(1);
LET dEndeudamientoTot=0;
LET dtFechaApertura= DATE(1);
LET dPagoRealizado=0;
LET cPeriodicidad='';
LET iACT=0;
LET iHIST=0;
LET iANT=0;
LET dQuincenal=0;
LET dSemanal=0;
LET dIncumplimiento=0;
LET cStatusCred='';
LET iBanderaConc=0;
LET i=0;
LET vcuotasvenc=0;
LET dPorPago=0;
LET dPorUso=0;

LET dPorPagoMin=0;
LET dPorUsoMin=0;
LET dPorSaldoMin=0;
LET dLimiteCredito=0;
LET dImpPerConACT=0;
LET dImpObsHIST=0;
LET dPorResSic=0;

LET dConsComPI=0;
LET dConsPI=0;
LET dConsACT=0;
LET dConsHIST=0;
LET dConsANT=0;
LET dConsPORPAGO=0;
LET dConsPORUSO=0;
LET dPI=0;
LET dPIdefaul=0;
LET dPorUsoMinCtesNunca= 0;

LET dConsSPMenor=0;
LET dConsSPMayor=0;
LET dSP=0;
LET dEvaBuro='';
LET dLineaAutorizada=0;
LET dConsMinPorPago=0;
LET dConsMaxPorPago=0;
LET dConsMinPorUso=0;
LET dConsMaxPorUso=0;
LET dPagoMinimo=0;
LET dImporteReservaMesAnt=0;
LET dFechaMesAnt=DATE(1);
LET v_iva_suc=0;
LET dMoratorios=0;
LET dInteVencIva=0;
LET dResCalificacion=0;
LET dPorcResCalificacion=0;
LET cGradoRiesgo= '';
LET vReservaGradual = 0;
LET dGradual = 0;
LET vImporteReservaBuroCC = 0;
LET dIvaVencido = 0;
LET vProducto = '';
LET vNvoPeriodo = 0;
LET vDivisa = '';
LET cGradoRiesgoBancoppel = '';
--TEMPORAL para el reproceso de cosechas
LET Tmonto_vencido    =0;
LET Tmto_venc_trasp  =0;
LET Tsdo_capital     =0;
LET Tsdo_cap_insoluto =0;
LET dFechaAct = date(1);
--TEMPORAL para el reproceso de cosechas
LET dDiaCorte = '';
LET cCreditoExterno = '';
LET dDiasXMes =0;
--A.L.L. Saldos de Credisolucion
LET cNumCreditoCrd = '';
LET dSaldoAlCorteCrd = 0;
LET sNivelRiesgoAlto = 0;
LET sNivelRiesgoMedio= 0;
LET sNivelRiesgoBajo = 0;

LET dPagosRealizados1PeriodosAnt	= 0;
LET dSaldoCorte2PeriodosAnt			= 0;
LET dPagosRealizados2PeriodosAnt	= 0;
LET dSaldoCorte3PeriodosAnt			= 0;
LET dPagosRealizados3PeriodosAnt	= 0;
LET dSaldoCorte4PeriodosAnt			= 0;
LET dPagosRealizados4PeriodosAnt	= 0;
LET dFecha1PeriodosAnt		= DATE(1);
LET dFecha2PeriodosAnt		= DATE(1);
LET dFecha3PeriodosAnt		= DATE(1);
LET dFecha4PeriodosAnt		= DATE(1);

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
LET dtFechaCorte = DATE(1);


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
--      LET cMensajeRet = cErrorInfo;
      IF cBegin= 'S' THEN
         ROLLBACK WORK;
      END IF;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "sp_calculo_reserva_corte.out";
--TRACE ON;


-- Se obtiene la fecha hoy del sistema.
    SELECT fecha_hoy,ult_dia_mes
      INTO dtFechaCalculo,dtFechaUltMes
      FROM bdicred:sd_fechas
	 WHERE empresa = pEmpresa;

--temporal solo para pruebas
--let dtFechaCalculo = mdy('09','24','2016');
--let dtFechaUltMes = mdy('09','30','2016');
--temporal solo para pruebas	 
--     LET dFechaCorte = MDY(MONTH(dtFechaCalculo),20,YEAR(dtFechaCalculo));
-- Se modifica por la tarjeta Platino
     -- LET dFechaCorte = MDY(MONTH(dtFechaCalculo),18,YEAR(dtFechaCalculo));   --- MODIF. MACF
-- Se modifica por la tarjeta Platino

-- Modificar por Anticipo de nómina
   LET dFechaCorte = MDY(MONTH(dtFechaCalculo),15,YEAR(dtFechaCalculo));   --- MODIF. MACF
-- Modificar por Anticipo de nómina   

--Se obtiene el último día del mes anterior para obtener la reserva de la sd_hisvalcon
     LET dFechaMesAnt = MDY(MONTH(dFechaCorte),1,YEAR(dFechaCorte)) - 1 units day;

    SELECT valor INTO dQuincenal FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '1';
    
    IF dQuincenal IS NULL THEN
       LET cCodRet= '000010';
       LET cMensajeRet= 'FALTA PARAMETRO CALCULO DE IMPAGOS QUINCENALES';
       RETURN cCodRet, cMensajeRet;
    END IF;
    
    SELECT valor INTO dSemanal FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '2';
    
    IF dSemanal IS NULL THEN
       LET cCodRet= '000020';
       LET cMensajeRet= 'FALTA PARAMETRO CALCULO DE IMPAGOS SEMANALES';
       RETURN cCodRet,cMensajeRet;
    END IF;

    SELECT valor INTO dConsPI FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '3';

   IF dConsPI IS NULL THEN
      LET cCodRet= '000030';
      LET cMensajeRet= 'FALTA CONSTANTE PARA PROBABILIDAD DE INCUMPLIMIENTO PI';
      RETURN cCodRet, cMensajeRet;
   END IF;

   SELECT valor INTO dConsACT FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '4';

   IF dConsACT IS NULL THEN
      LET cCodRet= '000040';
      LET cMensajeRet= 'FALTA CONSTANTE IMPAGO ACTUAL PI';
      RETURN cCodRet, cMensajeRet;
   END IF;

   SELECT valor INTO dConsHIST FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '5';

   IF dConsHIST IS NULL THEN
      LET cCodRet= '000050';
      LET cMensajeRet= 'FALTA CONSTANTE IMPAGO HISTORICO PI';
      RETURN cCodRet, cMensajeRet;
   END IF;

   SELECT valor INTO dConsANT FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '6';

   IF dConsANT IS NULL THEN
      LET cCodRet= '000060';
      LET cMensajeRet= 'FALTA CONSTANTE ANTIGÜEDAD PI';
      RETURN cCodRet, cMensajeRet;
   END IF;

   SELECT valor INTO dConsPORPAGO FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '7';

   IF dConsPORPAGO IS NULL THEN
      LET cCodRet= '000070';
      LET cMensajeRet= 'FALTA CONSTANTE PARA EL CALCULO DE PORCENTAJE PAGO PI';
      RETURN cCodRet, cMensajeRet;
   END IF;

   SELECT valor INTO dConsPORUSO FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '8';

   IF dConsPORUSO IS NULL THEN
      LET cCodRet= '000080';
      LET cMensajeRet= 'FALTA CONSTANTE PARA EL CALCULO DE PORCENTAJE USO PI';
      RETURN cCodRet, cMensajeRet;
   END IF;

    SELECT valor INTO dPorPagoMin FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '9';
    
    IF dPorPagoMin IS NULL THEN
       LET cCodRet= '000090';
       LET cMensajeRet= 'FALTA PARAMETRO PORCENTAJE DE PAGO MINIMO';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dPorUsoMin FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '10';
    
    IF dPorUsoMin IS NULL THEN
       LET cCodRet= '000100';
       LET cMensajeRet= 'FALTA PARAMETRO PORCENTAJE DE USO MINIMO';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dPIdefaul FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '13';

    IF dPIdefaul IS NULL THEN
       LET cCodRet= '000130';
       LET cMensajeRet= 'FALTA CONSTANTE PARA PROBABILIDAD DE INCUMPLIMIENTO >=4';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dConsSPMenor FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '14';
    
    IF dConsSPMenor IS NULL THEN
       LET cCodRet= '000140';
       LET cMensajeRet= 'FALTA CONSTANTE SEVERIDAD DE LA PERDIDA CUANDO ACT<12 ';
       RETURN cCodRet, cMensajeRet;
    END IF;
    
   SELECT valor INTO dConsSPMayor FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '15';

   IF dConsSPMayor IS NULL THEN
      LET cCodRet= '000150';
      LET cMensajeRet= 'FALTA CONSTANTE SEVERIDAD DE LA PERDIDA CUANDO ACT>=12';
      RETURN cCodRet, cMensajeRet;
   END IF;

    SELECT valor INTO dConsComPI FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '16';

     IF dConsComPI IS NULL THEN
        LET cCodRet= '000160';
        LET cMensajeRet= 'FALTA CONSTANTE COMPARACIÓN PARA PI';
        RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dPorSaldoMin FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '17';
    
    IF dPorSaldoMin IS NULL THEN
       LET cCodRet= '000170';
       LET cMensajeRet= 'FALTA PARAMETRO PORCENTAJE DE SALDO MINIMO';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dImpPerConACT FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '18';
    
    IF dImpPerConACT IS NULL THEN
       LET cCodRet= '000180';
       LET cMensajeRet= 'FALTA PARAMETRO IMPAGOS EN PERIODOS CONSECUTIVOS ACT';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dPorUsoMinCtesNunca FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '19';

    IF dPorUsoMinCtesNunca IS NULL THEN
       LET cCodRet= '000190';
       LET cMensajeRet= 'FALTA PORCENTAJE USO MINIMO CLIENTES NUNCA';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dImpObsHIST FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '20';
    
    IF dImpObsHIST IS NULL THEN
       LET cCodRet= '000200';
       LET cMensajeRet= 'FALTA PARAMETRO IMPAGOS OBSERVADOS ULTIMOS MESES HIST';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dConsMinPorPago FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '21';
    
    IF dConsMinPorPago IS NULL THEN
       LET cCodRet= '000210';
       LET cMensajeRet= 'FALTA VALOR MINIMO COMPARATIVO % DE PAGO';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dConsMaxPorPago FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '22';
    
    IF dConsMaxPorPago IS NULL THEN
       LET cCodRet= '000220';
       LET cMensajeRet= 'FALTA MAXIMO COMPARATIVO % DE PAGO';
       RETURN cCodRet, cMensajeRet;
    END IF;
    
    SELECT valor INTO dConsMinPorUso FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '23';
    
    IF dConsMinPorUso IS NULL THEN
       LET cCodRet= '000230';
       LET cMensajeRet= 'FALTA MINIMO COMPARATIVO % DE USO';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dConsMaxPorUso FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '24';
    
    IF dConsMaxPorUso IS NULL THEN
       LET cCodRet= '000240';
       LET cMensajeRet= 'FALTA MAXIMO COMPARATIVO % DE USO';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dPorResSic FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '25';
    
    IF dPorResSic IS NULL THEN
       LET cCodRet= '000250';
       LET cMensajeRet= 'FALTA PORCENTAJE DE RESERVA DE SIC';
       RETURN cCodRet, cMensajeRet;
    END IF;
/*
    SELECT valor INTO cGradoRiesgo FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '26';
    
    IF cGradoRiesgo IS NULL THEN
       LET cCodRet= '000260';
       LET cMensajeRet= 'GRADO RIESGO CLIENTES NUNCA';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT gradual
      INTO dGradual
      FROM bdicred:sd_gradualidad
     WHERE empresa=pEmpresa
       AND mes_ano=lpad(month(dtFechaUltMes),2,0)||year(dtFechaUltMes);
*/

    SELECT valor INTO dDiasXMes FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '27';
    
    IF dDiasXMes IS NULL THEN
       LET cCodRet= '000270';
       LET cMensajeRet= 'DIAS POR MES';
       RETURN cCodRet, cMensajeRet;
    END IF;

let dGradual = 1;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- Se calcula la fecha de corte del periodo anterior para obtener SALDO A PAGAR Y PAGO MINIMO
    EXECUTE PROCEDURE bdicred:monthadd(dFechaCorte, -1) INTO dFechaPeriodoAnterior;
-- Se obtienen los datos del crédito.

   /*SELECT a.num_credito, a.status_cred, a.sucursal, a.num_producto, 
          a.periodo_plazo, a.fecha_apertura, a.divisa, b.dia_corte, a.credito_externo, a.numcte
     FROM bdicred:sd_maecred a
    inner join bdicred:sd_maecredanexo b on b.empresa=a.empresa and b.num_credito=a.num_credito
    WHERE a.empresa          = pEmpresa               
      AND a.status_cred      IN ("AA","BA","BT")
      AND a.fecha_apertura   <= mdy(month(dtFechaCalculo),20,year(dtFechaCalculo))	--dtFechaCalculo
      AND a.num_producto <> '6600'   
      AND a.num_credito NOT IN (SELECT num_credito FROM bdicred:sd_hist_reserva WHERE empresa = a.empresa AND fecha_corte >= dFechaCorte)-- AND num_credito = a.num_credito )
--and sucursal in ('0004','1167')
   INTO temp paso_maecred WITH NO LOG;*/

     
    SELECT a.num_credito, a.status_cred, a.sucursal, a.num_producto, 
          a.periodo_plazo, a.fecha_apertura, a.divisa, b.dia_corte, a.credito_externo, a.numcte
     FROM bdicred:sd_maecred a
    inner join bdicred:sd_maecredanexo b on b.empresa=a.empresa and b.num_credito=a.num_credito
    WHERE a.empresa          = pEmpresa
      AND a.status_cred      IN ("AA","BA","BT")
      AND a.fecha_apertura   <= mdy(month(dtFechaCalculo),20,year(dtFechaCalculo))	--dtFechaCalculo
      AND a.num_credito NOT IN (SELECT num_credito FROM bdicred:sd_hist_reserva WHERE empresa = a.empresa AND fecha_corte >= dFechaCorte)-- AND num_credito = a.num_credito )
      AND a.num_producto in('6001','8100')   
--and sucursal in ('0004','1167')
   INTO temp paso_maecred WITH NO LOG;

   insert INTO paso_maecred
   SELECT a.num_credito, a.status_cred, a.sucursal, a.num_producto, 
          a.periodo_plazo, a.fecha_apertura, a.divisa, b.dia_corte, a.credito_externo, a.numcte
     FROM bdicred:sd_maecred a
    inner join bdicred:sd_maecredanexo b on b.empresa=a.empresa and b.num_credito=a.num_credito
    WHERE a.empresa          = pEmpresa               
      AND a.status_cred      IN ("AA","BA","BT")
      AND a.fecha_apertura   <= mdy(month(dtFechaCalculo),18,year(dtFechaCalculo))	
      AND a.num_producto = '7000'
      AND a.num_credito NOT IN (SELECT num_credito FROM bdicred:sd_hist_reserva WHERE empresa = a.empresa AND fecha_corte >= dFechaCorte); 
      
      insert INTO paso_maecred
   SELECT a.num_credito, a.status_cred, a.sucursal, a.num_producto, 
          a.periodo_plazo, a.fecha_apertura, a.divisa, b.dia_corte, a.credito_externo, a.numcte
     FROM bdicred:sd_maecred a
    inner join bdicred:sd_maecredanexo b on b.empresa=a.empresa and b.num_credito=a.num_credito
    WHERE a.empresa          = pEmpresa               
      AND a.status_cred      IN ("AA","BA","BT")
      AND a.fecha_apertura   <= mdy(month(dtFechaCalculo),15,year(dtFechaCalculo))	
      AND a.num_producto = '7800'
      AND a.num_credito NOT IN (SELECT num_credito FROM bdicred:sd_hist_reserva WHERE empresa = a.empresa AND fecha_corte >= mdy('09','01','2016'));

    
   CREATE UNIQUE INDEX inx_paso_maecred ON paso_maecred(num_credito);
   UPDATE STATISTICS HIGH FOR TABLE paso_maecred;

-- RQM 07 097-2 ADDENDUM Calificación Créditos Revolventes
   SELECT MAX(fecha_info) INTO dFechaInfo
   FROM bdiburo:br_variables_cc;
-- RQM 07 097-2 ADDENDUM Calificación Créditos Revolventes
   

FOREACH WITH HOLD
   SELECT num_credito, status_cred, sucursal, num_producto, 
          periodo_plazo, fecha_apertura, divisa, dia_corte, credito_externo, numcte
     INTO sNumeroCredito, cStatusCred, v_sucursal, vProducto,
          cPeriodicidad, dtFechaApertura, vDivisa, dDiaCorte, cCreditoExterno, cNumCte
     FROM paso_maecred

	 IF vProducto = '7800' THEN
		 IF dDiaCorte = 31 AND month(dtFechaCalculo) IN (4,6,9,11) THEN
			LET dtFechaCorte =  dtFechaUltMes;
		 ELIF month(dtFechaCalculo) = 2 AND dDiaCorte IN (29,30,31)THEN
			LET dtFechaCorte =  monthadd(dtFechaUltMes,+1) - 1 UNITS DAY;
		ELSE
			LET dtFechaCorte = mdy(month(dtFechaCalculo),dDiaCorte,year(dtFechaCalculo));
		END IF;
	ELSE
        LET dtFechaCorte = mdy(month(dtFechaCalculo),dDiaCorte,year(dtFechaCalculo));
     END IF;
 
	SELECT 
		NVL(monto_otorgado,0) limite_credito
    INTO
		dLimiteCredito
    FROM bdicred:sd_maesdoshist
--    WHERE fecha       = mdy(month(dtFechaCalculo),dDiaCorte,year(dtFechaCalculo))
    WHERE fecha       = dtFechaCorte
    AND empresa     = pEmpresa               
    AND num_credito = sNumeroCredito;

     LET cMensajeRet = sNumeroCredito;

     IF (vcontador_insert = 0) THEN
       BEGIN WORK;
       LET cBegin= 'S';
     END IF;

-- Se incluye la fecha de corte por la tarjeta Platino
--    LET dFechaCorte = MDY(MONTH(dtFechaCalculo),dDiaCorte,YEAR(dtFechaCalculo));
--    EXECUTE PROCEDURE bdicred:monthadd(dFechaCorte, -1) INTO dFechaPeriodoAnterior;

	IF vProducto = '7800' THEN
		 IF dDiaCorte = 31 AND month(dtFechaCalculo) IN (4,6,9,11) THEN
			LET dFechaPeriodoAnterior =  monthadd(dtFechaCorte,-1) + 1 UNITS DAY;
		 ELIF month(dtFechaCalculo) = 2 AND dDiaCorte IN (29,30,31)THEN
			LET dFechaPeriodoAnterior = MDY(MONTH(dtFechaCorte),1,YEAR(dtFechaCorte)) - 1 UNITS DAY;
			LET dFechaPeriodoAnterior = MDY(MONTH(dFechaPeriodoAnterior),dDiaCorte,YEAR(dFechaPeriodoAnterior));
	--        EXECUTE PROCEDURE bdicred:monthadd(dFechaPeriodoAnterior, -1) INTO dFechaPeriodoAnterior;
		ELSE
			LET dFechaCorte = MDY(MONTH(dtFechaCalculo),dDiaCorte,YEAR(dtFechaCalculo));
			EXECUTE PROCEDURE bdicred:monthadd(dFechaCorte, -1) INTO dFechaPeriodoAnterior;
		END IF;
    ELSE
        LET dFechaCorte = MDY(MONTH(dtFechaCalculo),dDiaCorte,YEAR(dtFechaCalculo));
        EXECUTE PROCEDURE bdicred:monthadd(dFechaCorte, -1) INTO dFechaPeriodoAnterior;
    END IF;

-- Se incluye la fecha de corte por la tarjeta Platino
 
--TEMPORAL para el reproceso de cosechas
/*
if Tmonto_vencido > 0 then
    let cStatusCred ='BA';
elif Tmto_venc_trasp  > 0 then
    let cStatusCred ='BT';
elif Tsdo_capital = Tsdo_cap_insoluto then
    let cStatusCred ='AA';
end if;*/
--TEMPORAL para el reproceso de cosechas

-- RQM 07 097-2 ADDENDUM Calificación Créditos Revolventes
	select fecha_info,meses_desde_primer_cred_banco,bkatr,monto_pagar_propios,monto_pagar_otros,gveces
	  into dFechaInfoTabla,sAntAcreditadoInst,sBkatr,dMontoPagarInst,dMontoPagarRepSic,cGveces
	from bdiburo:br_variables_cc
	where fecha_info = dFechaInfo
	and num_credito  = sNumeroCredito;

	IF sAntAcreditadoInst 	IS NULL OR sAntAcreditadoInst = '' 	THEN LET sAntAcreditadoInst = 0; 	END IF;
	IF dMontoPagarInst 		IS NULL OR dMontoPagarInst = '' 	THEN LET dMontoPagarInst = 0; 		END IF;
	IF dMontoPagarRepSic 	IS NULL OR dMontoPagarRepSic = '' 	THEN LET dMontoPagarRepSic = 0; 	END IF;
	IF cGveces 				IS NULL OR cGveces = '' 			THEN LET cGveces	= ''; 			END IF;
	IF sBkatr 				IS NULL OR sBkatr = '' 				THEN LET sBkatr = -1;				END IF;
	
	--Se obtiene la reserva del mes anterior
	LET dFecha1PeriodosAnt = MDY(MONTH(dtFechaUltMes),1,YEAR(dtFechaUltMes)) - 1 UNITS DAY;
	select saldo_corte, pagos_realizados, reserva_calificacion
	  into dSaldoCorte2PeriodosAnt,dPagosRealizados1PeriodosAnt, dImporteReservaMesAnt
	  from bdicred:sd_hist_reserva
	 where empresa		='001'
	   and num_credito 	= sNumeroCredito
	   and fecha_cierre = dFecha1PeriodosAnt;	--FECHA A 1 PERIODO ANTERIOR

	IF dSaldoCorte2PeriodosAnt IS NULL OR dSaldoCorte2PeriodosAnt = '' THEN LET dSaldoCorte2PeriodosAnt = 0; END IF;
	IF dPagosRealizados1PeriodosAnt IS NULL OR dPagosRealizados1PeriodosAnt = '' THEN LET dPagosRealizados1PeriodosAnt = 0; END IF;
	IF dImporteReservaMesAnt IS NULL THEN LET dImporteReservaMesAnt=0; END IF;
	
	LET dFecha2PeriodosAnt = MDY(MONTH(dFecha1PeriodosAnt),1,YEAR(dFecha1PeriodosAnt)) - 1 UNITS DAY;
	select saldo_corte, pagos_realizados
	  into dSaldoCorte3PeriodosAnt, dPagosRealizados2PeriodosAnt
	  from bdicred:sd_hist_reserva
	 where empresa		='001'
	   and num_credito 	= sNumeroCredito
	   and fecha_cierre = dFecha2PeriodosAnt;	--FECHA A 2 PERIODO ANTERIOR

	IF dSaldoCorte3PeriodosAnt IS NULL OR dSaldoCorte3PeriodosAnt = '' THEN LET dSaldoCorte3PeriodosAnt = 0; END IF;
	IF dPagosRealizados2PeriodosAnt IS NULL OR dPagosRealizados2PeriodosAnt = '' THEN LET dPagosRealizados2PeriodosAnt = 0; END IF;
	
	LET dFecha3PeriodosAnt = MDY(MONTH(dFecha2PeriodosAnt),1,YEAR(dFecha2PeriodosAnt)) - 1 UNITS DAY;
	select saldo_corte, pagos_realizados
	  into dSaldoCorte4PeriodosAnt, dPagosRealizados3PeriodosAnt
	  from bdicred:sd_hist_reserva
	 where empresa		='001'
	   and num_credito 	= sNumeroCredito
	   and fecha_cierre = dFecha3PeriodosAnt;	--FECHA A 3 PERIODO ANTERIOR

	IF dSaldoCorte4PeriodosAnt IS NULL OR dSaldoCorte4PeriodosAnt = '' THEN LET dSaldoCorte4PeriodosAnt = 0; END IF;
	IF dPagosRealizados3PeriodosAnt IS NULL OR dPagosRealizados3PeriodosAnt = '' THEN LET dPagosRealizados3PeriodosAnt = 0; END IF;

	LET dFecha4PeriodosAnt = MDY(MONTH(dFecha3PeriodosAnt),1,YEAR(dFecha3PeriodosAnt)) - 1 UNITS DAY;
	select pagos_realizados
	  into dPagosRealizados4PeriodosAnt
	  from bdicred:sd_hist_reserva
	 where empresa		='001'
	   and num_credito 	= sNumeroCredito
	   and fecha_cierre = dFecha4PeriodosAnt;	--FECHA A 4 PERIODO ANTERIOR

	IF dPagosRealizados4PeriodosAnt IS NULL OR dPagosRealizados4PeriodosAnt = '' THEN LET dPagosRealizados4PeriodosAnt = 0; END IF;

-- RQM 07 097-2 ADDENDUM Calificación Créditos Revolventes

     LET iACT=0;
     LET iHIST=0;
     LET i=0;
	 LET iBanderaConc=0;
     let dFechaAct = date(1);

-- historico de pagos en los ultimos 6 meses
    select count(*), max(fecha)
      into iHIST, dFechaAct
      FROM bdicred:sd_maesdoshist
     WHERE fecha > dFechaCorte - dImpObsHIST units month
       AND empresa= pEmpresa
       AND num_credito = sNumeroCredito
       and (monto_vencido + mto_venc_trasp) > 0;

     IF dFechaAct is null then let dFechaAct = date(1); end if;

     IF (iHIST > 0 and dFechaAct >= dFechaPeriodoAnterior) then
       SELECT 
              --NVL(b.monto_otorgado,0) limite_credito,
                (b.monto_financiado + (b.sdo_contab_mora + b.sdo_moratorio) * (select 1 + nvl(iva,0) from bdinteg:si_sucursales where empresa='001' and sucursal = v_sucursal) 
                        + amo.campo_trabajo1 + case when b.int_tra_no_exig - b.sdo_int_anticip >= 0 then  b.int_tra_no_exig - b.sdo_int_anticip else b.int_tra_no_exig end) pago_minimo,  -- pago_query,
                (b.sdo_cap_insoluto + (b.sdo_contab_mora + b.sdo_moratorio) * (select 1 + nvl(iva,0) from bdinteg:si_sucursales where empresa='001' and sucursal = v_sucursal) 
                        + amo.campo_trabajo1 + case when b.int_tra_no_exig - b.sdo_int_anticip >= 0 then  b.int_tra_no_exig - b.sdo_int_anticip else b.int_tra_no_exig end) saldo_total  -- saldo_query
         INTO
             --dLimiteCredito,
              dPagoMinimo,
              dEndeudamientoTot
         FROM bdicred:sd_maesdoshist b --on (a.empresa = b.empresa AND a.num_credito = b.num_credito AND b.fecha = dFechaPeriodoAnterior)
         LEFT OUTER JOIN bdicred:sd_amortiza_credito amo on amo.empresa = b.empresa and amo.num_credito = b.num_credito and amo.fecha_cuota = dFechaPeriodoAnterior
        WHERE b.fecha       = dFechaPeriodoAnterior
          AND b.empresa     = pEmpresa               
          AND b.num_credito = sNumeroCredito;
     ELSE
       SELECT 
              --NVL(b.monto_otorgado,0) limite_credito,
              NVL(b.monto_financiado,0) pago_minimo,  -- pago_query,
              NVL(b.sdo_cap_insoluto,0) saldo_total  -- saldo_query
         INTO
              --dLimiteCredito,
              dPagoMinimo,
              dEndeudamientoTot
         FROM bdicred:sd_maesdoshist b 
        WHERE b.fecha       = dFechaPeriodoAnterior
          AND b.empresa     = pEmpresa               
          AND b.num_credito = sNumeroCredito;
     END IF;    

     IF dLimiteCredito IS NULL OR dLimiteCredito = '' THEN LET dLimiteCredito = 0; END IF;
     IF dPagoMinimo IS NULL OR dPagoMinimo = '' THEN LET dPagoMinimo = 0; END IF;
     IF dEndeudamientoTot IS NULL OR dEndeudamientoTot = '' THEN LET dEndeudamientoTot = 0; END IF;
	
	--A.L.L.22/09/2015
	--SE VALIDA QUE EL CREDITO TENGA RELACION CON PRODUCTO DE CREDISOLUCION 
      LET cNumCreditoCrd = '';
	  SELECT limit 1 a.num_sol_prestamo
	    INTO cNumCreditoCrd
	    FROM bdicred:sd_promocion_credito a
	   INNER JOIN bdicred:sd_maecredcrd b on b.empresa = a.empresa and b.num_credito = a.num_sol_prestamo and b.status_cred = 'AA'
	   WHERE a.empresa = pEmpresa
         AND a.num_credito = sNumeroCredito;

      IF cNumCreditoCrd IS NULL OR cNumCreditoCrd = '' THEN LET cNumCreditoCrd = ''; END IF;

	  LET dSaldoAlCorteCrd = 0;
	  IF cNumCreditoCrd != '' THEN
	  
		SELECT sum(c.sdo_cap_insoluto)
			INTO dSaldoAlCorteCrd
			FROM bdicred:sd_promocion_credito a
		INNER JOIN bdicred:sd_maecredcrd b on b.empresa = a.empresa and b.num_credito = a.num_sol_prestamo and b.status_cred = 'AA'
		INNER JOIN bdicred:sd_maesdoshistcrd c on c.fecha = dFechaPeriodoAnterior and c.empresa = a.empresa and c.num_credito = a.num_sol_prestamo
			WHERE a.empresa = pEmpresa
			AND a.num_credito = sNumeroCredito;

       IF dSaldoAlCorteCrd IS NULL OR dSaldoAlCorteCrd = '' THEN LET dSaldoAlCorteCrd = 0; END IF;

		LET dEndeudamientoTot = dEndeudamientoTot + dSaldoAlCorteCrd;
	  END IF;
	  
	--END A.L.L

     if (iHIST > 0 and dFechaAct = dFechaCorte) then
         select fecha
          into dFechaAct
          FROM bdicred:sd_maesdoshist
         WHERE fecha = dFechaCorte
           AND empresa= pEmpresa
           AND num_credito = sNumeroCredito
           and (monto_vencido + mto_venc_trasp) > 0;

         if (dFechaAct is not null) then

            select max(fecha)
              into dFechaAct
              FROM bdicred:sd_maesdoshist
            --A.L.L.RQM 07 091 WHERE fecha > dFechaCorte - dImpPerConACT units month 
               WHERE empresa= pEmpresa
               AND num_credito = sNumeroCredito
               and (monto_vencido+mto_venc_trasp) = 0;

             if (dFechaAct is null) then
                LET iACT = dImpPerConACT;
             else
                if (dFechaAct < dFechaCorte) then
                    LET dFechaAct = dFechaAct + 1 units month;
                end if;
                if (year(dFechaCorte) = year(dFechaAct)) then
                    LEt iACT = (month(dFechaCorte) - month(dFechaAct)) + 1;
                else
                    let iACT = (year(dFechaCorte) - year(dFechaAct)) * 12 + (month(dFechaCorte) - month(dFechaAct)) + 1;
                end if;
            end if;
         end if;
      end if;
      
/*
     FOREACH
           SELECT first dImpPerConACT monto_vencido + mto_venc_trasp
             INTO dIncumplimiento
             FROM bdicred:sd_maesdoshist
            WHERE empresa= pEmpresa  
              AND fecha <= dFechaCorte
              AND num_credito = sNumeroCredito
            ORDER BY fecha DESC
                    
		    IF dIncumplimiento> 0   THEN

               IF iBanderaConc=0 THEN
			      LET iACT= iACT + 1;
               END IF;
--Impagos observados en los últimos meses HIST
               IF i < dImpObsHIST THEN  -- 6
                  LET iHIST = iHIST + 1;
               END IF;
                       
			ELSE
			   LET iBanderaConc= 1;
			END IF;
                    
            LET i= i + 1;
--Impagos en períodos consecutivos ACT
            IF (iBanderaConc = 1 AND i >= dImpObsHIST) THEN  -- 10
               EXIT FOREACH;
            END IF;
                    
     END FOREACH;

*/
  
     IF cPeriodicidad = "Q" THEN
        LET iACT= iACT * dQuincenal;
        LET iHIST= iHIST * dQuincenal;
     ELIF cPeriodicidad = "S" THEN
        LET iACT= iACT * dSemanal;
        LET iHIST= iHIST * dSemanal;
     END IF;

     IF  dtFechaApertura <= dFechaCorte THEN
         SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} NVL(SUM(monto),0) 
           INTO dPagoRealizado
           FROM bdicred:sd_movhis
          WHERE empresa = pEmpresa
            AND fecha_mov >= dFechaPeriodoAnterior + 1 
            AND fecha_mov <=dFechaCorte 
            AND num_credito = sNumeroCredito
            AND codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanual)
            AND codigo_ref = 1 
            AND reversado = 'N';
     END IF;
-- Se cambia el calculo de la antigûedad tomando la fecha de fin de mes como base, a solicitud del usuario.

	IF sAntAcreditadoInst = 0 THEN
		LET iANT = round((dtFechaUltMes - dtFechaApertura)/dDiasXMes,2);
	ELSE
		LET iANT = sAntAcreditadoInst;
	END IF;

-- RQM 07 097-2 ADDENDUM Calificación Créditos Revolventes
     IF		iANT <= 42 AND dLimiteCredito <= 15000 THEN 
			LET sNivelRiesgoAlto = 1;
	 ELIF  (iANT <= 42 AND dLimiteCredito > 40000) OR (iANT > 42 AND dLimiteCredito <= 15000) OR (dLimiteCredito > 15000 AND dLimiteCredito <= 40000) THEN
			LET sNivelRiesgoMedio = 1;
	 ELIF	iANT > 42 AND dLimiteCredito > 40000 THEN
			LET sNivelRiesgoBajo = 1;
	 END IF;		

--Se obtiene la reserva del mes anterior
/*    select nvl(reserva_calificacion,0)
      into dImporteReservaMesAnt
      from sd_hist_reserva
     where empresa = pEmpresa 
       and num_credito = sNumeroCredito
       and fecha_cierre = dFechaMesAnt;

       IF dImporteReservaMesAnt IS NULL THEN
          LET dImporteReservaMesAnt=0;
       END IF;*/
-- RQM 07 097-2 ADDENDUM Calificación Créditos Revolventes

    if vProducto = '7000' then
-- Se obtiene el antecedente a Buró
         SELECT evalua_cc
           INTO dEvaBuro
           FROM bdisolic:ss_resum_scor_fin 
          WHERE empresa = pempresa 
            AND num_solicitud = cCreditoExterno;
-- Se obtiene la línea autorizada
         SELECT monto_solicitado
           INTO dLineaAutorizada
           FROM bdisolic:ss_solicitudes 
          WHERE empresa = pempresa 
            AND num_solicitud = cCreditoExterno;
    else
-- Se obtiene el antecedente a Buró
         SELECT monto_solicitado
           INTO dLineaAutorizada
           FROM bdisolic:ss_solicitudes 
          WHERE empresa = pempresa 
            AND num_solicitud = sNumeroCredito;
-- Se obtiene la línea autorizada
         SELECT evalua_cc
           INTO dEvaBuro
           FROM bdisolic:ss_resum_scor_fin 
          WHERE empresa = pempresa 
            AND num_solicitud = sNumeroCredito;
    end if;
/*
---CALCULA LAS RESERVAS PARA LOS CLIENTES NUNCA Y PARA LOS CLIENTES TOTALEROS(INTRA) 
   IF (dEndeudamientoTot <=0 AND dPagoRealizado >= 0) THEN
-- Se obtiene el antecedente a Buró
-- Se obtiene la línea autorizada
     IF (dtFechaApertura > dFechaPeriodoAnterior) then
        if vProducto = '7000' then
             SELECT monto_solicitado
               INTO dLimiteCredito
               FROM bdisolic:ss_solicitudes 
              WHERE empresa = pempresa 
                AND num_solicitud = cCreditoExterno;
         else
             SELECT monto_solicitado
               INTO dLimiteCredito
               FROM bdisolic:ss_solicitudes 
              WHERE empresa = pempresa 
                AND num_solicitud = sNumeroCredito;
         end if;

         IF dLimiteCredito is null THEN
            LET dLimiteCredito = 0;
         END IF;
     END IF;   
        
       IF (dEndeudamientoTot <= 0 AND dPagoRealizado = 0) THEN -- clientes inactivos
          LET dResCalificacion = dPorUsoMinCtesNunca * (dLimiteCredito + dEndeudamientoTot);

          IF dResCalificacion < 0 THEN LET dResCalificacion = 0; END IF;

          LET vReservaGradual= dResCalificacion * dGradual;
          LET dPorcResCalificacion = dPorUsoMinCtesNunca;
          LET cGradoRiesgoBancoppel = 'IN';
          --LET cGradoRiesgo = 'B1';
		  LET cGradoRiesgo = 'A1';
          IF dEvaBuro='1' THEN
             LET vImporteReservaBuroCC = dResCalificacion * dPorResSic * dGradual;
          END IF; 
         --LET vNvoPeriodo= 1;
		 LET vNvoPeriodo= 9;
--Grado A1
       ELIF (dEndeudamientoTot <= 0 AND dPagoRealizado > 0) THEN -- clientes totaleros
--          LET dResCalificacion = dPorUsoMinCtesNunca * (CASE WHEN (dLimiteCredito + dEndeudamientoTot) < 0 THEN 0 ELSE (dLimiteCredito + dEndeudamientoTot) END);
          LET dResCalificacion = 0;
          LET vReservaGradual= dResCalificacion * dGradual;
          LET dPorcResCalificacion = 0;
          LET cGradoRiesgoBancoppel = 'A1';
          LET cGradoRiesgo = 'A1';
          IF dEvaBuro='1' THEN
             LET vImporteReservaBuroCC = dResCalificacion * dPorResSic * dGradual;
          END IF; 
          LET vNvoPeriodo= 0;
       ELSE
--Se inicializan variables del cursor
           LET sNumeroCredito =0;
           LET cStatusCred =0;
           LET cPeriodicidad =0;
           LET dtFechaApertura = date(1);
           LET dEndeudamientoTot =0;
           LET dLimiteCredito =0;
           LET dPagoMinimo =0;
           LET dEvaBuro = '';
           LET dLineaAutorizada = 0;
           LET dPagoRealizado = 0;
           LET iANT = 0;
           LET dPI = 0;
           LET dSP = 0;
           LET iACT = 0;
           LET iHIST = 0;
           LET dPorPago = 0;
           LET dPorUso = 0;
           LET vcuotasvenc = 0;
           LET dImporteReservaMesAnt = 0;
           LET vImporteReservaBuroCC = 0;
		   LET sNivelRiesgoAlto = 0;
		   LET sNivelRiesgoMedio= 0;
		   LET sNivelRiesgoBajo = 0;
		   LET dSaldoCorte4PeriodosAnt = 0;
		   LET dPagoMinimo3PeriodosAnt = 0;
		   LET dPagoMinimo4PeriodosAnt = 0;
		   LET dPagoMinimo2PeriodosAnt = 0;
		   LET dFecha4PeriodosAnt		= DATE(1);
		   LET dFecha3PeriodosAnt		= DATE(1);
		   LET dFecha2PeriodosAnt		= DATE(1);
		   LET sGveces1	= 0;
		   LET sGveces2	= 0;
		   LET sGveces3	= 0;
		   CONTINUE FOREACH;
       END IF;

       INSERT INTO "informix".sd_hist_reserva
        (empresa, fecha_corte, num_credito, fecha_cierre, grado_riesgo, fecha_apertura, antecedente_buro,
         status_cred, linea_autorizada, limite_credito, interes_cred_ven, saldo_corte, saldo_cierre, pago_minimo,
         pagos_realizados, reserva_int_cred_ven, reserva_buro, reserva_calificacion, porcentaje_reserva,
         meses_antiguedad, probabilidad_incumplimiento, severidad_perdida, exposicion_incumplimiento,
         impagos_consecutivos, impagos_historicos, porcentaje_pago, porcentaje_uso, num_periodos,
         exposicion_inc_gradual, grado_riesgo_gradual, reserva_calificacion_gradual, porcentaje_reserva_gradual,
         reserva_buro_gradual, reserva_int_cred_ven_gradual, reserva_calif_mes_anterior, grado_riesgo_bancoppel,
         grado_riesgo_edo_resultados, reserva_edo_resultados, porcentaje_reserva_edo_resultados) 
       VALUES
        (pEmpresa, dFechaCorte, sNumeroCredito, NULL,cGradoRiesgo, dtFechaApertura, dEvaBuro,cStatusCred,
         dLineaAutorizada,dLimiteCredito,0,dEndeudamientoTot,0, dPagoMinimo, dPagoRealizado,0,vImporteReservaBuroCC,
        dResCalificacion,dPorcResCalificacion*100, iANT,0,
        (case when iACT< dImpPerConACT then dConsSPMenor else dConsSPMayor end)*100,null,iACT,iHIST,0,0,vcuotasvenc,0,
        cGradoRiesgo,vReservaGradual,0,vImporteReservaBuroCC,0,dImporteReservaMesAnt,cGradoRiesgoBancoppel,cGradoRiesgo,vReservaGradual,0);

--rss         LET vNvoPeriodo= 1;



------------------------------------------------------------------------------------
        IF vReservaGradual>0 THEN
		
        -- Genera Movimiento para Contabilidad
            EXECUTE PROCEDURE genmov_calif (pEmpresa,
                                            sNumeroCredito,
                                            vProducto,
                                            vNvoPeriodo,
                                            "091",--"070", --665
                                            dtFechaUltMes,
                                            vReservaGradual,
                                            "CalifCartReserva",
                                             v_sucursal,
                                             vDivisa,
                                             "0000")
            INTO cCodRet, cMensajeRet;
            IF TRIM(cCodRet) <> "00000" THEN
               RETURN cCodRet, cMensajeRet;
            END IF;
        END IF;

--        IF vReservaGradual > 0 AND (dLimiteCredito + dEndeudamientoTot) > 0 THEN
--rss se pasa al 2o proceso de la calificación (fin de mes) ya que se debe de reportar el saldo a fin de mes
--rss se pasa al 2o proceso de la calificación (fin de mes) ya que aqui nunca pasará para créditos inactivos con dEndeudamientoTot > 0

        IF vImporteReservaBuroCC > 0 THEN
		
            --Califica malos antecedentes
              EXECUTE PROCEDURE genmov_calif (pEmpresa,
                                              sNumeroCredito,
                                              vProducto,
                                              0,
                                              "093",--"661",
                                              dtFechaUltMes,
                                              vImporteReservaBuroCC,
                                              "CalifCart",
                                              v_sucursal,
                                              vDivisa,
                                              "0000")
             INTO cCodRet, cMensajeRet;
             IF TRIM(cCodRet) <> "00000" THEN
               RETURN cCodRet, cMensajeRet;
             END IF;
        END IF;
------------------------------------------------------------------------------------
       LET auxNumeroCredito="";
       LET vcontador_insert = vcontador_insert + 1;
--Se inicializan variables del cursor
       LET sNumeroCredito =0;
       LET cStatusCred =0;
       LET cPeriodicidad =0;
       LET dtFechaApertura = date(1);
       LET dEndeudamientoTot =0;
       LET dLimiteCredito =0;
       LET dPagoMinimo =0;
       LET dEvaBuro = '';
       LET dLineaAutorizada = 0;
       LET dPagoRealizado = 0;
       LET iANT = 0;
       LET dPI = 0;
       LET dSP = 0;
       LET iACT = 0;
       LET iHIST = 0;
       LET dPorPago = 0;
       LET dPorUso = 0;
       LET vcuotasvenc = 0;
       LET dImporteReservaMesAnt = 0;
       LET vImporteReservaBuroCC = 0;
	   LET sNivelRiesgoAlto = 0;
	   LET sNivelRiesgoMedio= 0;
	   LET sNivelRiesgoBajo = 0;
	   LET dSaldoCorte4PeriodosAnt = 0;
	   LET dPagoMinimo3PeriodosAnt = 0;
	   LET dPagoMinimo4PeriodosAnt = 0;
	   LET dPagoMinimo2PeriodosAnt = 0;
	   LET dFecha4PeriodosAnt		= DATE(1);
	   LET dFecha3PeriodosAnt		= DATE(1);
	   LET dFecha2PeriodosAnt		= DATE(1);
	   LET sGveces1	= 0;
	   LET sGveces2	= 0;
	   LET sGveces3	= 0;

       CONTINUE FOREACH;
   END IF;
*/   
-- Se calcula % de Uso 
--     IF dLimiteCredito = 0 or dEndeudamientoTot = 0 THEN
     IF dLimiteCredito < 1.01 THEN
        LET dPorUso  = 1; 
     ELSE 
        LET dPorUso  = dEndeudamientoTot / dLimiteCredito; 
     END IF;

-- Se calcula % de Pago 
    IF dEndeudamientoTot > 0 THEN
       LET dPorPago = dPagoRealizado / dEndeudamientoTot;
    END IF;
-- Valida valor máximo para %PAGO
     IF dPorPago  > dConsMaxPorPago THEN LET dPorPago  = dConsMaxPorPago; END IF; 

-- RQM 07 097-2 ADDENDUM Calificación Créditos Revolventes
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
	IF sBkatr = -1 AND iACT = 0 THEN 
		LET sBkatr = 13; 
	ELIF sBkatr = -1 AND iACT > 0 THEN 
		LET sBkatr = 0;
	END IF;

--Se calcula PI (Probabilidad de Incumplimiento)
    IF iACT >= dConsComPI THEN -- Valor 4
		LET dPI = dPIdefaul; --Valor 1
	ELIF (dEndeudamientoTot <= 0 AND dSaldoCorte2PeriodosAnt <= 0 AND dSaldoCorte3PeriodosAnt <= 0 AND dSaldoCorte4PeriodosAnt <= 0) AND 
		   (dPagoRealizado = 0 AND dPagosRealizados1PeriodosAnt = 0 AND dPagosRealizados2PeriodosAnt = 0 AND dPagosRealizados3PeriodosAnt = 0) THEN
			LET dPI = 0.0418;
	ELIF (dEndeudamientoTot <= 0 AND dSaldoCorte2PeriodosAnt <= 0 AND dSaldoCorte3PeriodosAnt <= 0 AND dSaldoCorte4PeriodosAnt <= 0) AND 
			 (dPagoRealizado > 0 OR dPagosRealizados1PeriodosAnt > 0 OR dPagosRealizados2PeriodosAnt > 0 OR dPagosRealizados3PeriodosAnt > 0) THEN
			IF sNivelRiesgoAlto = 1 THEN
				LET dPI = 0.0466;
			ELIF sNivelRiesgoMedio = 1 THEN
				LET dPI = 0.0344;
			ELIF sNivelRiesgoBajo = 1 THEN
				LET dPI = 0.0218;
			END IF;	
	ELIF dEndeudamientoTot <= 0 AND (dSaldoCorte2PeriodosAnt > 0 OR dSaldoCorte3PeriodosAnt > 0 OR dSaldoCorte4PeriodosAnt > 0) THEN
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

	-- Se calcula SP (Severidad de la Pérdida)
/*     IF iACT < dImpPerConACT THEN
        LET dSP = dConsSPMenor;
     ELSE
        LET dSP = dConsSPMayor;
     END IF;*/
	IF (dEndeudamientoTot <= 0 AND dSaldoCorte2PeriodosAnt <= 0 AND dSaldoCorte3PeriodosAnt <= 0 AND dSaldoCorte4PeriodosAnt <= 0) AND 
		   (dPagoRealizado = 0 AND dPagosRealizados1PeriodosAnt = 0 AND dPagosRealizados2PeriodosAnt = 0 AND dPagosRealizados3PeriodosAnt = 0) THEN
			LET dSP = 0.67;
	ELIF (dEndeudamientoTot <= 0 AND dSaldoCorte2PeriodosAnt <= 0 AND dSaldoCorte3PeriodosAnt <= 0 AND dSaldoCorte4PeriodosAnt <= 0) AND 
			 (dPagoRealizado > 0 OR dPagosRealizados1PeriodosAnt > 0 OR dPagosRealizados2PeriodosAnt > 0 OR dPagosRealizados3PeriodosAnt > 0) THEN
			LET dSP = 0.70;
	ELIF dEndeudamientoTot <= 0 AND (dSaldoCorte2PeriodosAnt > 0 OR dSaldoCorte3PeriodosAnt > 0 OR dSaldoCorte4PeriodosAnt > 0) THEN
			LET dSP = 0.70;
	ELIF iACT <= 4 THEN
		LET dSP = dConsSPMenor; --Valor 0.75
	ELIF iACT > 4 AND iACT <= 5 THEN LET dSP = 0.77;
	ELIF iACT > 5 AND iACT <= 6 THEN LET dSP = 0.80;
	ELIF iACT > 6 AND iACT <= 7 THEN LET dSP = 0.82;
	ELIF iACT > 7 AND iACT <= 8 THEN LET dSP = 0.86;
	ELIF iACT > 8 AND iACT <= 9 THEN LET dSP = 0.90;
	ELIF iACT > 9 AND iACT <= 10 THEN LET dSP = 0.92;
	ELIF iACT > 10 AND iACT <= 11 THEN LET dSP = 0.96;
	ELIF iACT > 11 THEN LET dSP = 1; END IF;

-- RQM 07 097-2 ADDENDUM Calificación Créditos Revolventes	 

-- Se almacena la información correspondiente al calculo de la reservas preventivas.
     INSERT INTO informix.sd_hist_reserva
/*
(empresa,fecha_corte,num_credito,fecha_cierre,grado_riesgo,fecha_apertura,antecedente_buro,status_cred,linea_autorizada,
limite_credito,interes_cred_ven,saldo_corte,saldo_cierre,pago_minimo,pagos_realizados,reserva_int_cred_ven,reserva_buro, 
reserva_calificacion,porcentaje_reserva,meses_antiguedad,probabilidad_incumplimiento,severidad_perdida,exposicion_incumplimiento,
impagos_consecutivos,impagos_historicos,porcentaje_pago,porcentaje_uso,num_periodos,exposicion_inc_gradual,grado_riesgo_gradual, 
reserva_calificacion_gradual,porcentaje_reserva_gradual,reserva_buro_gradual,reserva_int_cred_ven_gradual,reserva_calif_mes_anterior,
grado_riesgo_bancoppel,grado_riesgo_edo_resultados,reserva_edo_resultados,porcentaje_reserva_edo_resultados,numcte,
cta_credisolucion,status_fin_mes,saldo_corte2,saldo_corte3,saldo_corte4,pagos_realizados1,pagos_realizados2,pagos_realizados3,pagos_realizados4,
saldo_corte_credisolucion,saldo_cierre_credisolucion,monto_pagar_inst,monto_pagar_rep_sic,ant_acreditado_inst,grado_riesgo_alto,grado_riesgo_medio,grado_riesgo_bajo,gveces1,gveces2,gveces3,bkatr)
*/
         VALUES (pEmpresa,dFechaCorte,sNumeroCredito,null,null,dtFechaApertura,dEvaBuro,cStatusCred,dLineaAutorizada,
                  dLimiteCredito,null,dEndeudamientoTot,null,dPagoMinimo,dPagoRealizado,null,null,
                  null,null,ROUND(iANT),dPI * 100,dSP * 100,null,iACT,iHIST,dPorPago * 100,(case when dPorUso < 0 then 0 else dPorUso end) * 100,vcuotasvenc,null,null,
                  null,null,null,null,dImporteReservaMesAnt,
				  null,null,null,null,cNumCte,
				  cNumCreditoCrd,null,dSaldoCorte2PeriodosAnt,dSaldoCorte3PeriodosAnt,dSaldoCorte4PeriodosAnt,dPagosRealizados1PeriodosAnt,dPagosRealizados2PeriodosAnt,dPagosRealizados3PeriodosAnt,dPagosRealizados4PeriodosAnt,
				  dSaldoAlCorteCrd,null,dMontoPagarInst,dMontoPagarRepSic,sAntAcreditadoInst,sNivelRiesgoAlto,sNivelRiesgoMedio,sNivelRiesgoBajo,sGveces1,sGveces2,sGveces3,sBkatr);
				  --Se inicializan variables del cursor
   LET sNumeroCredito ='';
   LET cStatusCred ='';
   LET cPeriodicidad ='';
   LET dtFechaApertura = date(1);
   LET dEndeudamientoTot =0;
   LET dLimiteCredito =0;
   LET dPagoMinimo =0;
   LET dEvaBuro = '';
   LET dLineaAutorizada = 0;
   LET dPagoRealizado = 0;
   LET iANT = 0;
   LET dPI = 0;
   LET dSP = 0;
   LET iACT = 0;
   LET iHIST = 0;
   LET dPorPago = 0;
   LET dPorUso = 0;
   LET vcuotasvenc = 0;
   LET dImporteReservaMesAnt = 0;

   LET auxNumeroCredito="";
   LET cCreditoExterno = '';
   LET sNivelRiesgoAlto = 0;
   LET sNivelRiesgoMedio= 0;
   LET sNivelRiesgoBajo = 0;
   
   LET dPagosRealizados1PeriodosAnt	= 0;
   LET dSaldoCorte2PeriodosAnt			= 0;
   LET dPagosRealizados2PeriodosAnt	= 0;
   LET dSaldoCorte3PeriodosAnt			= 0;
   LET dPagosRealizados3PeriodosAnt	= 0;
   LET dSaldoCorte4PeriodosAnt			= 0;
   LET dPagosRealizados4PeriodosAnt	= 0;
   LET dFecha1PeriodosAnt		= DATE(1);
   LET dFecha2PeriodosAnt		= DATE(1);
   LET dFecha3PeriodosAnt		= DATE(1);
   LET dFecha4PeriodosAnt		= DATE(1);

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
   
   LET vcontador_insert = vcontador_insert + 1;

   IF (vcontador_insert >= 2000) THEN
      COMMIT WORK;
      LET cBegin= 'F';
      LET vcontador_insert = 0;
--      UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_hist_reserva;
   END IF;

END FOREACH;

IF (vcontador_insert > 0) THEN
   COMMIT WORK;
END IF;

UPDATE statistics medium FOR TABLE sd_hist_reserva;
    
--  DROP TABLE cr_sucursales3;
  LET cMensajeRet= 'El proceso de CALIFICACION DEL CORTE se realizó correctamente';

  RETURN cCodRet,cMensajeRet;

END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener',
'el calculo de la reserva',
'AUTOR : Roque Enrique Solis',
'FECHA : 05/MARZO/2009',
'BD    : BDICRED';

create procedure "informix".sp_os_generaos()
returning char(5);


    define sNum_solicitud       char (20);
    define dFecha_solicitud     date;
    DEFINE SQL_ERR          INTEGER;
    DEFINE ISAM_ERR         INTEGER;
    define x                Integer;
    DEFINE ERROR_INFO       VARCHAR(80);

    define P_COD_RET        char(5);
    define vCodRet          char(5);

--  Set debug file to '/pisa/pisabanco/pisa_ftes/credito/coronel/sp_os_GeneraOs.out';
--  trace on;

    Begin

        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
            LET P_COD_RET = SQL_ERR;
            RETURN P_COD_RET;
        END EXCEPTION;

        Let P_COD_RET = '00000';
	Let x = 0;

        ForEach with hold
        Select num_solicitud, fecha_solicitud
        into sNum_solicitud, dFecha_solicitud
        From ss_solicitud_os
        Where status = 'S'
            	execute procedure sp_os_integracion(sNum_solicitud, dFecha_solicitud)  Into vCodRet;
	    	Let x = x + 1;
        End ForEach;

	Return P_COD_RET;

    end;
end procedure
;