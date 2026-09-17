CREATE PROCEDURE "informix".sp_calculo_reserva_corte_pba(pEmpresa CHAR(3))

RETURNING 
          CHAR(6)  AS resultado,
          CHAR(80) AS mensaje;
		  
--  execute procedure "informix".sp_calculo_reserva_corte_pba('001');
          
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
DEFINE dtFechaPriMes         DATE;
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
LET dtFechaPriMes= DATE(1);
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

SET DEBUG FILE TO "/resplogifx/archivoscartera/sp_calculo_reserva_corte_pba.out";
TRACE ON;


-- Se obtiene la fecha hoy del sistema.
    SELECT fecha_hoy,ult_dia_mes,pri_dia_mes
      INTO dtFechaCalculo,dtFechaUltMes,dtFechaPriMes
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
   INTO temp paso_maecred WITH NO LOG;*/

/*solo para prueba     
    SELECT a.num_credito, a.status_cred, a.sucursal, a.num_producto, 
          a.periodo_plazo, a.fecha_apertura, a.divisa, b.dia_corte, a.credito_externo, a.numcte
     FROM bdicred:sd_maecred a
    inner join bdicred:sd_maecredanexo b on b.empresa=a.empresa and b.num_credito=a.num_credito
    WHERE a.empresa          = pEmpresa
      AND a.status_cred      IN ("AA","BA","BT")
      AND a.fecha_apertura   <= mdy(month(dtFechaCalculo),20,year(dtFechaCalculo))	--dtFechaCalculo
      AND a.num_credito NOT IN (SELECT num_credito FROM bdicred:sd_hist_reserva WHERE empresa = a.empresa AND fecha_corte >= dFechaCorte)-- AND num_credito = a.num_credito )
      AND a.num_producto in('6001','8100')   
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
      AND a.num_credito NOT IN (SELECT num_credito FROM bdicred:sd_hist_reserva WHERE empresa = a.empresa AND fecha_corte >= dtFechaPriMes);
*/ --solo para prueba

   SELECT a.num_credito, a.status_cred, a.sucursal, a.num_producto, 
          a.periodo_plazo, a.fecha_apertura, a.divisa, b.dia_corte, a.credito_externo, a.numcte
     FROM bdicred:sd_maecred a
    inner join bdicred:sd_maecredanexo b on b.empresa=a.empresa and b.num_credito=a.num_credito
    WHERE a.empresa          = pEmpresa               
      AND a.status_cred      IN ("AA","BA","BT")
      AND a.fecha_apertura   <= mdy(month(dtFechaCalculo),15,year(dtFechaCalculo))	
      AND a.num_producto = '7800'
      AND a.num_credito NOT IN (SELECT num_credito FROM bdicred:sd_hist_reserva WHERE empresa = a.empresa AND fecha_corte >= dtFechaPriMes)
   INTO temp paso_maecred WITH NO LOG;

    
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
where num_credito='780000108859'

	 IF vProducto = '7800' THEN
		IF dDiaCorte = 31 AND month(dtFechaCalculo) IN (4,6,9,11) THEN
			LET dtFechaCorte = dtFechaUltMes;
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

CREATE PROCEDURE "informix".sp_calcula_fechas_porperiodo(pEmpresa CHAR(3),pPeriodicidad CHAR(1),pNumProducto CHAR(04),pDiaCorte SMALLINT,pFechaHoy DATE)
RETURNING   CHAR(6)        AS resultado,
            VARCHAR(100,1) AS mensaje,
			DATE AS Fecha_Actual_t_0,
			DATE AS Fecha_t_1,
			DATE AS Fecha_t_2,
			DATE AS Fecha_t_3,
			DATE AS Fecha_t_4,
			DATE AS Fecha_t_5,
			DATE AS Fecha_t_6,
			DATE AS Fecha_t_7,
			DATE AS Fecha_t_8,
			DATE AS Fecha_t_9,
			DATE AS Fecha_t_10,
			DATE AS Fecha_t_11,
			DATE AS Fecha_t_12,
			DATE AS Fecha_t_13;
			
DEFINE iSqlErr      	     		INTEGER;
DEFINE iIsamErr              		INTEGER;
DEFINE cErrorInfo            		CHAR(80);
DEFINE cCodRet               		CHAR(6); 
DEFINE cMensajeRet           		VARCHAR(100,1);
DEFINE cMensaje                     CHAR(40);
DEFINE dfecha0,dfecha1,dfecha2,dfecha3,dfecha4,dfecha5,dfecha6,dfecha7 DATE;
DEFINE dfecha8,dfecha9,dfecha10,dfecha11,dfecha12,dfecha13 DATE;
DEFINE dFechaHoyAux date;
DEFINE cLaborable					CHAR(01);
DEFINE sDiaInicial,sDiaFinal	SMALLINT;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		LET cCodRet= iSqlErr;
		LET cMensajeRet = 'Error en CALCULO FECHAS POR PERIODO';
		RETURN cCodRet,cMensajeRet,dfecha0,dfecha1,dfecha2,dfecha3,dfecha4,dfecha5,dfecha6,
			dfecha7,dfecha8,dfecha9,dfecha10,dfecha11,dfecha12,dfecha13;
	  END IF;
END EXCEPTION;

--SET DEBUG FILE TO "sp_calcula_fechas_porperiodo.out";
--TRACE ON;

LET iSqlErr                  	= 0;
LET iIsamErr                 	= 0;
LET cErrorInfo               	= "";
LET cCodRet                  	= '000000';
LET cMensajeRet              	= 'Los cÃÂ¡lculos se realizaron correctamente en CALCULO FECHAS POR PERIODO';
LET cMensaje                    = '';
LET dFechaHoyAux 				= DATE(1);
LET cLaborable					= '';
LET sDiaInicial,sDiaFinal = 0,0;
LET dfecha0,dfecha1,dfecha2,dfecha3,dfecha4,dfecha5,dfecha6,dfecha7 = date(1),date(1),date(1),date(1),date(1),date(1),date(1),date(1);
LET dfecha8,dfecha9,dfecha10,dfecha11,dfecha12,dfecha13 = date(1),date(1),date(1),date(1),date(1),date(1);
LET dFechaHoyAux = date(1);

LET dfecha0,dfecha1,dfecha2,dfecha3,dfecha4,dfecha5,dfecha6,dfecha7 = null,null,null,null,null,null,null,null;
LET dfecha8,dfecha9,dfecha10,dfecha11,dfecha12,dfecha13 = null,null,null,null,null,null;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- Se determinan las fechas de consulta
    IF pPeriodicidad = 'M' THEN
		IF pDiaCorte = 31 THEN
			IF month(pFechaHoy) = 2 THEN
				LET dFechaHoyAux = monthadd(pFechaHoy,+1);
				LET dFechaHoyAux = mdy(month(dFechaHoyAux),pDiaCorte,year(dFechaHoyAux));
				LET dFecha0  = monthadd(dFechaHoyAux,-1);	
				LET dFecha1 = monthadd(dFechaHoyAux,-2);
				LET dFecha2 = monthadd(dFechaHoyAux,-3);
				LET dFecha3 = monthadd(dFechaHoyAux,-4);
				LET dFecha4 = monthadd(dFechaHoyAux,-5);
			ELSE
				IF day(pFechaHoy) = 30 THEN
					LET dFechaHoyAux = monthadd(pFechaHoy,+1);
					LET dFechaHoyAux = mdy(month(dFechaHoyAux),pDiaCorte,year(dFechaHoyAux));
					LET dFecha0 = monthadd(dFechaHoyAux,-1);
					LET dFecha1 = monthadd(dFechaHoyAux,-2);
					LET dFecha2 = monthadd(dFechaHoyAux,-3);
					LET dFecha3 = monthadd(dFechaHoyAux,-4);
					LET dFecha4 = monthadd(dFechaHoyAux,-5);
				ELSE
					LET dFechaHoyAux = pFechaHoy;
--					LET dFechaHoyAux = mdy(month(dFechaHoyAux),pDiaCorte,year(dFechaHoyAux));
					LET dFecha0 = dFechaHoyAux;
					LET dFecha1 = monthadd(dFechaHoyAux,-1);
					LET dFecha2 = monthadd(dFechaHoyAux,-2);
					LET dFecha3 = monthadd(dFechaHoyAux,-3);
					LET dFecha4 = monthadd(dFechaHoyAux,-4);
				END IF;
			END IF;	
		ELIF pDiaCorte = 30 THEN
			IF month(pFechaHoy) = 2 THEN
				LET dFechaHoyAux = monthadd(pFechaHoy,+1);
				LET dFechaHoyAux = mdy(month(dFechaHoyAux),pDiaCorte,year(dFechaHoyAux));
				LET dFecha0  = monthadd(dFechaHoyAux,-1);	
				LET dFecha1 = monthadd(dFechaHoyAux,-2);
				LET dFecha2 = monthadd(dFechaHoyAux,-3);
				LET dFecha3 = monthadd(dFechaHoyAux,-4);
				LET dFecha4 = monthadd(dFechaHoyAux,-5);
			ELSE
				LET dFechaHoyAux = mdy(month(pFechaHoy),pDiaCorte,year(pFechaHoy));
				LET dFecha0  = dFechaHoyAux;	
				LET dFecha1 = monthadd(dFechaHoyAux,-1);
				LET dFecha2 = monthadd(dFechaHoyAux,-2);
				LET dFecha3 = monthadd(dFechaHoyAux,-3);
				LET dFecha4 = monthadd(dFechaHoyAux,-4);
			END IF;	
		ELIF pDiaCorte = 29 THEN
			IF month(pFechaHoy) = 2 THEN
				LET dFechaHoyAux = monthadd(pFechaHoy,+1);
				LET dFechaHoyAux = mdy(month(dFechaHoyAux),pDiaCorte,year(dFechaHoyAux));
				LET dFecha0  = monthadd(dFechaHoyAux,-1);	
				LET dFecha1 = monthadd(dFechaHoyAux,-2);
				LET dFecha2 = monthadd(dFechaHoyAux,-3);
				LET dFecha3 = monthadd(dFechaHoyAux,-4);
				LET dFecha4 = monthadd(dFechaHoyAux,-5);
			ELSE
				LET dFechaHoyAux = mdy(month(pFechaHoy),pDiaCorte,year(pFechaHoy));
				LET dFecha0  = dFechaHoyAux;	
				LET dFecha1 = monthadd(dFechaHoyAux,-1);
				LET dFecha2 = monthadd(dFechaHoyAux,-2);
				LET dFecha3 = monthadd(dFechaHoyAux,-3);
				LET dFecha4 = monthadd(dFechaHoyAux,-4);
			END IF;	
		ELSE
			LET dFechaHoyAux = mdy(month(pFechaHoy),pDiaCorte,year(pFechaHoy));
			LET dFecha0  = dFechaHoyAux;	
			LET dFecha1 = monthadd(dFechaHoyAux,-1);
			LET dFecha2 = monthadd(dFechaHoyAux,-2);
			LET dFecha3 = monthadd(dFechaHoyAux,-3);
			LET dFecha4 = monthadd(dFechaHoyAux,-4);
		END IF;

-- Se validan dÃÂ­as inhÃÂ¡biles
		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dFecha0;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;
		
		IF cLaborable = 'N' THEN LET dFecha0 = dFecha0 - 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dFecha1;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dFecha1 = dFecha1 - 1 units day; END IF;
		
		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dFecha2;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dFecha2 = dFecha2 - 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dFecha3;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dFecha3 = dFecha3 - 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dFecha4;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dFecha4 = dFecha4 - 1 units day; END IF;
	ELIF pPeriodicidad = 'Q' THEN
--calcula 13 periodos de pago
		IF pNumProducto != '6400' THEN 
			LET cCodRet= '000002';
			LET cMensajeRet = 'Producto para periodo quincenal no vÃÂ¡lido en CALCULO FECHAS POR PERIODO.';
			RETURN cCodRet,cMensajeRet,dfecha0,dfecha1,dfecha2,dfecha3,dfecha4,dfecha5,dfecha6,
				dfecha7,dfecha8,dfecha9,dfecha10,dfecha11,dfecha12,dfecha13;
		END IF;

		IF (pDiaCorte <= 15) then
			SELECT perdiafac,sdodiafac
			  INTO sDiaInicial,sDiaFinal
			  FROM "informix".sd_diafactura
			 WHERE empresa = pEmpresa
			   AND num_producto = pNumProducto
			   AND perdiafac = pDiaCorte
			   AND tipo_pago = 2 --iTpDiasFechaPago
			   AND fac_especial = 'N';
		ELSE
			SELECT perdiafac,sdodiafac
			  INTO sDiaInicial,sDiaFinal
			  FROM "informix".sd_diafactura
			 WHERE empresa = pEmpresa
			   AND num_producto = pNumProducto
			   AND sdodiafac = pDiaCorte
			   AND tipo_pago = 2 --iTpDiasFechaPago
			   AND fac_especial = 'S';
		END IF;
		
	   IF sDiaInicial IS NULL OR sDiaInicial = '' THEN LET sDiaInicial = 0; END IF;
	   IF sDiaFinal IS NULL OR sDiaFinal = '' THEN LET sDiaFinal = 0; END IF;
			   
	    IF pDiaCorte = 31 OR pDiaCorte = 15 THEN
			IF month(pFechaHoy) = 2 THEN
/*				LET dFechaHoyAux = monthadd(pFechaHoy,+1);
				LET dFechaHoyAux = mdy(month(dFechaHoyAux),sDiaCorte,year(dFechaHoyAux));
				LET dFecha0  = monthadd(dFechaHoyAux,-1) - 1 units day;	
				LET dFecha1 = monthadd(dFechaHoyAux,-2) - 1 units day;
				LET dFecha2 = monthadd(dFechaHoyAux,-3) - 1 units day;
				LET dFecha3 = monthadd(dFechaHoyAux,-4) - 1 units day;*/

				LET dFechaHoyAux = monthadd(pFechaHoy,+1);
				LET dFechaHoyAux = mdy(month(dFechaHoyAux),sDiaFinal,year(dFechaHoyAux));
				LET dfecha0 = monthadd(dFechaHoyAux,-1);
				LET dfecha1 = mdy(month(date(dfecha0)),sDiaInicial,year(date(dfecha0)));
				LET dfecha2 = monthadd(dFechaHoyAux,-2);
				LET dfecha3 = mdy(month(date(dfecha2)),sDiaInicial,year(date(dfecha2)));
				LET dfecha4 = monthadd(dFechaHoyAux,-3);
				LET dfecha5 = mdy(month(date(dfecha4)),sDiaInicial,year(date(dfecha4)));
				LET dfecha6 = monthadd(dFechaHoyAux,-4);
				LET dfecha7 = mdy(month(date(dfecha6)),sDiaInicial,year(date(dfecha6)));
				LET dfecha8 = monthadd(dFechaHoyAux,-5);
				LET dfecha9 = mdy(month(date(dfecha8)),sDiaInicial,year(date(dfecha8)));
				LET dfecha10 = monthadd(dFechaHoyAux,-6);
				LET dfecha11 = mdy(month(date(dfecha10)),sDiaInicial,year(date(dfecha10)));
				LET dfecha12 = monthadd(dFechaHoyAux,-7);
				LET dfecha13 = mdy(month(date(dfecha12)),sDiaInicial,year(date(dfecha12)));
			ELIF day(pFechaHoy) = 30 THEN
/*				LET dFecha0  = pFechaHoy - 1 units day;	
				LET dFecha1 = monthadd(pFechaHoy,-1) - 1 units day;
				LET dFecha2 = monthadd(pFechaHoy,-2) - 1 units day;
				LET dFecha3 = monthadd(pFechaHoy,-3) - 1 units day;*/

				LET dFechaHoyAux = monthadd(pFechaHoy,+1);
				LET dFechaHoyAux = mdy(month(dFechaHoyAux),sDiaFinal,year(dFechaHoyAux));
				LET dfecha0 = monthadd(dFechaHoyAux,-1);
				LET dfecha1 = mdy(month(date(dfecha0)),sDiaInicial,year(date(dfecha0)));
				LET dfecha2 = monthadd(dFechaHoyAux,-2);
				LET dfecha3 = mdy(month(date(dfecha2)),sDiaInicial,year(date(dfecha2)));
				LET dfecha4 = monthadd(dFechaHoyAux,-3);
				LET dfecha5 = mdy(month(date(dfecha4)),sDiaInicial,year(date(dfecha4)));
				LET dfecha6 = monthadd(dFechaHoyAux,-4);
				LET dfecha7 = mdy(month(date(dfecha6)),sDiaInicial,year(date(dfecha6)));
				LET dfecha8 = monthadd(dFechaHoyAux,-5);
				LET dfecha9 = mdy(month(date(dfecha8)),sDiaInicial,year(date(dfecha8)));
				LET dfecha10 = monthadd(dFechaHoyAux,-6);
				LET dfecha11 = mdy(month(date(dfecha10)),sDiaInicial,year(date(dfecha10)));
				LET dfecha12 = monthadd(dFechaHoyAux,-7);
				LET dfecha13 = mdy(month(date(dfecha12)),sDiaInicial,year(date(dfecha12)));
			ELSE
				LET dFechaHoyAux = pFechaHoy;
				LET dfecha0 = dFechaHoyAux;
				LET dfecha1 = mdy(month(date(dfecha0)),sDiaInicial,year(date(dfecha0)));
				LET dfecha2 = monthadd(dFechaHoyAux,-1);
				LET dfecha3 = mdy(month(date(dfecha2)),sDiaInicial,year(date(dfecha2)));
				LET dfecha4 = monthadd(dFechaHoyAux,-2);
				LET dfecha5 = mdy(month(date(dfecha4)),sDiaInicial,year(date(dfecha4)));
				LET dfecha6 = monthadd(dFechaHoyAux,-3);
				LET dfecha7 = mdy(month(date(dfecha6)),sDiaInicial,year(date(dfecha6)));
				LET dfecha8 = monthadd(dFechaHoyAux,-4);
				LET dfecha9 = mdy(month(date(dfecha8)),sDiaInicial,year(date(dfecha8)));
				LET dfecha10 = monthadd(dFechaHoyAux,-5);
				LET dfecha11 = mdy(month(date(dfecha10)),sDiaInicial,year(date(dfecha10)));
				LET dfecha12 = monthadd(dFechaHoyAux,-6);
				LET dfecha13 = mdy(month(date(dfecha12)),sDiaInicial,year(date(dfecha12)));
			END IF;	
		ELIF pDiaCorte = 30 THEN
			IF month(pFechaHoy) = 2 THEN
/*				LET dFechaHoyAux = monthadd(pFechaHoy,+1);
				LET dFechaHoyAux = mdy(month(dFechaHoyAux),pDiaCorte,year(dFechaHoyAux));
				LET dFecha0  = monthadd(dFechaHoyAux,-1) - 1 units day;	
				LET dFecha1 = monthadd(dFechaHoyAux,-2) - 1 units day;
				LET dFecha2 = monthadd(dFechaHoyAux,-3) - 1 units day;
				LET dFecha3 = monthadd(dFechaHoyAux,-4) - 1 units day;*/
				LET dFechaHoyAux = monthadd(pFechaHoy,+1);
				LET dFechaHoyAux = mdy(month(dFechaHoyAux),sDiaFinal,year(dFechaHoyAux));
				LET dfecha0 = monthadd(dFechaHoyAux,-1);
				LET dfecha1 = mdy(month(date(dfecha0)),sDiaInicial,year(date(dfecha0)));
				LET dfecha2 = monthadd(dFechaHoyAux,-2);
				LET dfecha3 = mdy(month(date(dfecha2)),sDiaInicial,year(date(dfecha2)));
				LET dfecha4 = monthadd(dFechaHoyAux,-3);
				LET dfecha5 = mdy(month(date(dfecha4)),sDiaInicial,year(date(dfecha4)));
				LET dfecha6 = monthadd(dFechaHoyAux,-4);
				LET dfecha7 = mdy(month(date(dfecha6)),sDiaInicial,year(date(dfecha6)));
				LET dfecha8 = monthadd(dFechaHoyAux,-5);
				LET dfecha9 = mdy(month(date(dfecha8)),sDiaInicial,year(date(dfecha8)));
				LET dfecha10 = monthadd(dFechaHoyAux,-6);
				LET dfecha11 = mdy(month(date(dfecha10)),sDiaInicial,year(date(dfecha10)));
				LET dfecha12 = monthadd(dFechaHoyAux,-7);
				LET dfecha13 = mdy(month(date(dfecha12)),sDiaInicial,year(date(dfecha12)));
			ELIF day(pFechaHoy) = 30 THEN
				LET dFechaHoyAux = pFechaHoy;
				LET dfecha0 = dFechaHoyAux;
				LET dfecha1 = mdy(month(date(dfecha0)),sDiaInicial,year(date(dfecha0)));
				LET dfecha2 = monthadd(dFechaHoyAux,-1);
				LET dfecha3 = mdy(month(date(dfecha2)),sDiaInicial,year(date(dfecha2)));
				LET dfecha4 = monthadd(dFechaHoyAux,-2);
				LET dfecha5 = mdy(month(date(dfecha4)),sDiaInicial,year(date(dfecha4)));
				LET dfecha6 = monthadd(dFechaHoyAux,-3);
				LET dfecha7 = mdy(month(date(dfecha6)),sDiaInicial,year(date(dfecha6)));
				LET dfecha8 = monthadd(dFechaHoyAux,-4);
				LET dfecha9 = mdy(month(date(dfecha8)),sDiaInicial,year(date(dfecha8)));
				LET dfecha10 = monthadd(dFechaHoyAux,-5);
				LET dfecha11 = mdy(month(date(dfecha10)),sDiaInicial,year(date(dfecha10)));
				LET dfecha12 = monthadd(dFechaHoyAux,-6);
				LET dfecha13 = mdy(month(date(dfecha12)),sDiaInicial,year(date(dfecha12)));
			ELIF day(pFechaHoy) = 31 THEN
				LET dFechaHoyAux = mdy(month(pFechaHoy),pDiaCorte,year(pFechaHoy));
				LET dfecha0 = dFechaHoyAux;
				LET dfecha1 = mdy(month(date(dfecha0)),sDiaInicial,year(date(dfecha0)));
				LET dfecha2 = monthadd(dFechaHoyAux,-1);
				LET dfecha3 = mdy(month(date(dfecha2)),sDiaInicial,year(date(dfecha2)));
				LET dfecha4 = monthadd(dFechaHoyAux,-2);
				LET dfecha5 = mdy(month(date(dfecha4)),sDiaInicial,year(date(dfecha4)));
				LET dfecha6 = monthadd(dFechaHoyAux,-3);
				LET dfecha7 = mdy(month(date(dfecha6)),sDiaInicial,year(date(dfecha6)));
				LET dfecha8 = monthadd(dFechaHoyAux,-4);
				LET dfecha9 = mdy(month(date(dfecha8)),sDiaInicial,year(date(dfecha8)));
				LET dfecha10 = monthadd(dFechaHoyAux,-5);
				LET dfecha11 = mdy(month(date(dfecha10)),sDiaInicial,year(date(dfecha10)));
				LET dfecha12 = monthadd(dFechaHoyAux,-6);
				LET dfecha13 = mdy(month(date(dfecha12)),sDiaInicial,year(date(dfecha12)));
			END IF;	
		ELSE
/*			LET dFechaHoyAux = mdy(month(pFechaHoy),pDiaCorte,year(pFechaHoy));
			LET dFecha0  = dFechaHoyAux - 1 units day;	
			LET dFecha1 = monthadd(dFechaHoyAux,-1) - 1 units day;
			LET dFecha2 = monthadd(dFechaHoyAux,-2) - 1 units day;
			LET dFecha3 = monthadd(dFechaHoyAux,-3) - 1 units day;*/
--rss
			LET dFechaHoyAux = pFechaHoy;
--			LET dFechaHoyAux = monthadd(dFechaHoyAux,+1);
			IF month(dFechaHoyAux) = 2 AND sDiaFinal = 29 THEN 
				LET dfecha0 = dFechaHoyAux;
			ELSE
				LET dfecha0 = mdy(month(date(dFechaHoyAux)),sDiaFinal,year(date(dFechaHoyAux)));
			END IF;
			LET dfecha1 = mdy(month(date(dfecha0)),sDiaInicial,year(date(dfecha0)));

			LET dFechaHoyAux = mdy(month(date(dfecha1)),1,year(date(dfecha1))) - 1 units day;
			IF month(dFechaHoyAux) = 2 AND sDiaFinal = 29 THEN 
				LET dfecha2 = dFechaHoyAux;
			ELSE
				LET dfecha2 = (mdy(month(date(dFechaHoyAux)),sDiaFinal,year(date(dFechaHoyAux))));
			END IF;
			LET dfecha3 = mdy(month(date(dfecha2)),sDiaInicial,year(date(dfecha2)));
			
			LET dFechaHoyAux = mdy(month(date(dfecha3)),1,year(date(dfecha3))) - 1 units day;
			IF month(dFechaHoyAux) = 2 AND sDiaFinal = 29 THEN 
				LET dfecha4 = dFechaHoyAux;
			ELSE
				LET dfecha4 = (mdy(month(date(dFechaHoyAux)),sDiaFinal,year(date(dFechaHoyAux))));
			END IF;
			LET dfecha5 = mdy(month(date(dfecha4)),sDiaInicial,year(date(dfecha4)));
			
			LET dFechaHoyAux = mdy(month(date(dfecha5)),1,year(date(dfecha5))) - 1 units day;
			IF month(dFechaHoyAux) = 2 AND sDiaFinal = 29 THEN 
				LET dfecha6 = dFechaHoyAux;
			ELSE
				LET dfecha6 = (mdy(month(date(dFechaHoyAux)),sDiaFinal,year(date(dFechaHoyAux))));
			END IF;
			LET dfecha7 = mdy(month(date(dfecha6)),sDiaInicial,year(date(dfecha6)));
			
			LET dFechaHoyAux = mdy(month(date(dfecha7)),1,year(date(dfecha7))) - 1 units day;
			IF month(dFechaHoyAux) = 2 AND sDiaFinal = 29 THEN 
				LET dfecha8 = dFechaHoyAux;
			ELSE
				LET dfecha8 = (mdy(month(date(dFechaHoyAux)),sDiaFinal,year(date(dFechaHoyAux))));
			END IF;
			LET dfecha9 = mdy(month(date(dfecha8)),sDiaInicial,year(date(dfecha8)));

			LET dFechaHoyAux = mdy(month(date(dfecha9)),1,year(date(dfecha9))) - 1 units day;
			IF month(dFechaHoyAux) = 2 AND sDiaFinal = 29 THEN 
				LET dfecha10 = dFechaHoyAux;
			ELSE
				LET dfecha10 = (mdy(month(date(dFechaHoyAux)),sDiaFinal,year(date(dFechaHoyAux))));
			END IF;
			LET dfecha11 = mdy(month(date(dfecha10)),sDiaInicial,year(date(dfecha10)));
			
			LET dFechaHoyAux = mdy(month(date(dfecha11)),1,year(date(dfecha11))) - 1 units day;
			IF month(dFechaHoyAux) = 2 AND sDiaFinal = 29 THEN 
				LET dfecha12 = dFechaHoyAux;
			ELSE
				LET dfecha12 = (mdy(month(date(dFechaHoyAux)),sDiaFinal,year(date(dFechaHoyAux))));
			END IF;
			LET dfecha13 = mdy(month(date(dfecha12)),sDiaInicial,year(date(dfecha12)));
		END IF;

-- Se validan dÃÂ­as inhÃÂ¡biles
		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha0;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;
		
		IF cLaborable = 'N' THEN LET dfecha0 = dfecha0 - 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha1;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha1 = dfecha1 - 1 units day; END IF;
		
		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha2;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha2 = dfecha2 - 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha3;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha3 = dfecha3 - 1 units day; END IF;
------
		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha4;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;
		
		IF cLaborable = 'N' THEN LET dfecha4 = dfecha4 - 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha5;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha5 = dfecha5 - 1 units day; END IF;
		
		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha6;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha6 = dfecha6 - 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha7;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha7 = dfecha7 - 1 units day; END IF;
------
		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha8;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;
		
		IF cLaborable = 'N' THEN LET dfecha8 = dfecha8 - 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha9;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha9 = dfecha9 - 1 units day; END IF;
		
		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha10;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha10 = dfecha10 - 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha11;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha11 = dfecha11 - 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha12;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha12 = dfecha12 - 1 units day; END IF;

		SELECT laborable INTO cLaborable FROM bdinteg:si_feriado WHERE empresa = pEmpresa AND fecha = dfecha13;
		IF cLaborable IS NULL OR cLaborable = '' THEN LET cLaborable = 'S'; END IF;

		IF cLaborable = 'N' THEN LET dfecha13 = dfecha13 - 1 units day; END IF;
		
--	ELIF pPeriodicidad = 'S' THEN
	ELSE
		LET cCodRet= '000003';
		LET cMensajeRet = 'Periodo no vÃÂ¡lido en CALCULO FECHAS POR PERIODO.';
		RETURN cCodRet,cMensajeRet,dfecha0,dfecha1,dfecha2,dfecha3,dfecha4,dfecha5,dfecha6,
				dfecha7,dfecha8,dfecha9,dfecha10,dfecha11,dfecha12,dfecha13;
	END IF;	 

RETURN cCodRet,cMensajeRet,dfecha0,dfecha1,dfecha2,dfecha3,dfecha4,dfecha5,dfecha6,
		dfecha7,dfecha8,dfecha9,dfecha10,dfecha11,dfecha12,dfecha13;
END
END PROCEDURE
DOCUMENT 
'Proceso para el cÃÂ¡lculo de fechas por periodo para la calificaciÃÂ³n de cuentas a plazo',
'AUTOR : Bancoppel',
'FECHA : 20/Septiembre/2016',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_carga_ctes_credisoluciones(pEmpresa CHAR(3))
RETURNING 
          CHAR(06) AS resultado,    CHAR(80) AS mensaje;


DEFINE vproceso         CHAR(4);
DEFINE cCod_RetIB       CHAR(6);
DEFINE dtFechaIni        DATE;
DEFINE dtFechaFin  		 DATE;
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cRutaArch        CHAR(100);
DEFINE cParamNomArch    CHAR(100);
DEFINE cNomArchivo      CHAR(150);
DEFINE cNomArchEjecSql  CHAR(100);
DEFINE cSQL             CHAR(1500);
DEFINE cNumCred         CHAR(20);


--SET DEBUG FILE TO "/informix/jesus/inccat/sp_carga_ctes_credisoluciones.out";
--TRACE ON;

LET vproceso        = '3402';
LET cCod_RetIB      = '000000';
LET dtFechaIni       = DATE(0); 
LET dtFechaFin       = DATE(0); 
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = '000000';
LET cMensajeRet     = 'PROCESO EXITOSO';    
LET cRutaArch       = '';
LET cNomArchivo     = '';
LET cParamNomArch     = 'Credisolucion201703';LET cNomArchEjecSql = '';
LET cSQL            = '';
LET cNumCred        = '';


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet = iSqlErr;
        LET cMensajeRet = cErrorInfo;
        
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 10;



    IF ( NVL(pEmpresa,"") = "" ) THEN
        LET cCodRet= '102005'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        
        RETURN cCodRet, cMensajeRet;
	END IF;

 

    SELECT trim(valor) INTO cRutaArch  FROM bdicred:sd_param WHERE cod_param = 103;
    IF ( NVL(cRutaArch, "") = "" ) THEN
        LET cCodRet = '104005';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        
        RETURN cCodRet, cMensajeRet;
    END IF;
	
	
	---se crea temporal para realizar limpieza de las promociones que se van a insertar.
	SELECT num_credito	
	FROM  "informix".sd_prospectos
	WHERE num_promo = 7
	INTO TEMP limpieza WITH NO LOG;
	
	
	FOREACH WITH HOLD
		SELECT num_credito	
		INTO cNumCred
		FROM  "informix".limpieza
		
		BEGIN WORK;
			INSERT INTO sd_prospectos_hist
			SELECT TODAY,* 	
			FROM  "informix".sd_prospectos
			WHERE num_promo = 7
			AND num_credito = cNumCred;
			
			DELETE FROM  "informix".sd_prospectos
			WHERE num_promo = 7
			and num_credito = cNumCred;
		COMMIT WORK;
		
	END FOREACH
	
	--se carga el archivo con los clientes de las nuevas promociones
	
	SELECT LIMIT 1 fechaini_promo, fechafin_promo
		INTO dtFechaIni, dtFechaFin
	FROM "informix".sd_promocion    
	WHERE empresa = '001'
	AND num_producto = '6001'
	AND num_promo = 7;
   
	
    LET cNomArchivo = trim(cParamNomArch) ||'.txt';
    LET cNomArchEjecSql = 'Carga_credisol.sql';
    TRUNCATE TABLE bdicred:sd_ctes_behavior;
	UPDATE STATISTICS MEDIUM FOR TABLE  bdicred:sd_ctes_behavior;
    -- Realiza carga de archivo.
    LET cSQL = '';
    LET cSQL = ' echo " CREATE TEMP TABLE cred_prospectos (num_credito CHAR(20),numcte CHAR(20)) with no log; '
            || ' LOAD FROM ' || TRIM(cRutaArch) || TRIM(cNomArchivo) 
            || ' INSERT INTO cred_prospectos; '
            || ' INSERT INTO bdicred:sd_prospectos ( empresa, num_producto, num_promo, numcte, num_credito, fecha_ini, fecha_fin) '
            || ' SELECT  ''001'',''6900'',7,numcte , num_credito  ,''' || dtFechaIni || ''',''' || dtFechaFin || ''' FROM cred_prospectos;  ">' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql); 
    SYSTEM cSQL;

	
	

    LET cSQL = 'dbaccess bdicred ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    UPDATE STATISTICS MEDIUM FOR TABLE  bdicred:sd_prospectos;

    RETURN cCodRet,cMensajeRet;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para carga de archivo de creditos candidatos para validarse bajo perfil de segundo producto', 
'AUTOR: JESUS AGUILAR  ',
'FECHA: octubre  2016',
'VERSION: 20151012.1433',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_mc_consexpediente (pEmpresa CHAR(3), pCliente CHAR(20))

RETURNING CHAR(5),    -- Codigo de Retorno
           CHAR (40); --descripcion
		  
--DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(5);
DEFINE iContador		SMALLINT;
DEFINE cDescripcion		CHAR(80);

---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '00000';
LET cDescripcion        = '';
LET iContador           = 0;


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr,cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;          
          RETURN cCodRet,NVL(cErrorInfo,'');	 
       END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/informix/jesus/inccat/sp_mc_consexpediente.out";
	--TRACE ON;
		
	IF  NVL(pCliente,'') = '' THEN
		LET cCodRet	= '00001';
		RETURN cCodRet,'Error de parametros';
	END IF;
	
	
	FOREACH WITH HOLD

		SELECT DISTINCT tipo.descripcion 
		INTO cDescripcion
		FROM bdidigital@coppelimg_tcp:dg_tipodocumento AS tipo 
		LEFT OUTER JOIN bdidigital@coppelimg_tcp:dg_expediente AS EXP ON (tipo.cod_docto = EXP.cod_docto)
		WHERE EXP.cliente = pCliente 
		AND tipo.cod_grupo IN('001','002','003') 
		AND  EXP.fecha_alta IN(SELECT MAX(Exp2.fecha_alta) 
							FROM bdidigital@coppelimg_tcp:dg_tipodocumento  AS tipo2 
							LEFT OUTER JOIN bdidigital@coppelimg_tcp:dg_expediente AS exp2 	ON (tipo2.cod_docto = exp2.cod_docto)
							WHERE Exp2.cliente = EXP.cliente  
							AND tipo2.cod_grupo = tipo.cod_grupo) 
		
		LET iContador = 1;
		
		RETURN cCodRet,NVL(cDescripcion,'') WITH RESUME;
	
	END FOREACH;
	FOREACH WITH HOLD
		SELECT DISTINCT tipo.descripcion 
		INTO cDescripcion
		FROM bdidigital@coppelimg_tcp:dg_tipodocumento AS tipo
		LEFT OUTER JOIN bdidigital@coppelimg_tcp:dg_expediente AS EXP ON (tipo.cod_docto = EXP.cod_docto) 
		WHERE EXP.cliente = pCliente 
		AND tipo.cod_grupo in('006','007') 
		AND exp.fecha_alta > today -90 units DAY 
		LET iContador = 1;
		RETURN cCodRet,NVL(cDescripcion,'')WITH RESUME;
		
	END FOREACH;
	IF iContador = 0 THEN
		LET cCodRet='00002';
		LET cDescripcion='No existe informacion';
		RETURN cCodRet,NVL(cDescripcion,'');
	END IF
   
END;
END PROCEDURE
DOCUMENT    
'DESCRIPCION: Procedimiento para  obtencion de documentos digitalizados en mesa de control para formato de autorizacion de solicitud', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'FECHA:27 Febrero 2017',
'VERSION: 20170227.1028',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_reporte_concentrado_6900(p_empresa char(3), pfechacorte   DATE)
    RETURNING CHAR(6)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje;         

--Proceso para la generación del reporte concentrado de Credisoluciones RQM 10 412 
--Modificado: Febrero 2015

DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_retIB			CHAR(6);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoEjecSql   CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cruta                CHAR(100);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE cProceso             CHAR(4);
DEFINE cFechaCorte          DATE; --CHAR(8);

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = '000000';
LET cCod_retIB              = '000000';
LET cMensaje                = 'PROCESO EXITOSO';
LET cruta                   = "";
LET cnombre					= "Credisol_Con_";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnomarchivoEjecSql      = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cProceso                = '0085';

--SET DEBUG FILE TO "/informix/mahr/sp_reporte_concentrado_6900.out";
--TRACE ON;

SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;

 BEGIN
  ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;       
        CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCod_ret, trim(cMensaje)||'-'||isam_err::CHAR, '02') Returning cCod_retIB;
        RETURN cCod_ret, cMensaje;
    END EXCEPTION;

    CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCod_ret, 'INICIA CREACION REPORTE', '02') Returning cCod_RetIB;

	--Obtener ruta del archivo
    SELECT TRIM(valor)  INTO cruta
      FROM bdicred:sd_param WHERE empresa = p_empresa
       AND cod_param = '033';

    LET cFechaGenArchivo =  to_char(pfechacorte,'%d%m%Y');
    LET cFechaCorte = pfechacorte;

	--Validar que existe el archivo	
	LET cnomarchivo1 = trim(cnombre)||cFechaGenArchivo||'_Aux_'||'.txt ';
    LET cnomarchivo =  trim(cnombre)||cFechaGenArchivo||'.txt ';
    LET cnomarchivoEjecSql = 'Exec_Rep_Con_6900' || '.sql';

    LET cSQL='';
    LET cSQL = 'echo "Num Promocion'||'|'||'Nombre Promocion'||'|'||'Tasa Interes'||'|'||'Contratos'||'|'||'Monto'||'|'||'Plazo'||
               '|'||'Capital insoluto'||'|'||'Intereses por Pagar'||'|'||'IVA por Pagar'||'|'||'Intereses Cargados Acum'||'|'||'IVA Cargados'|| ' " >' || TRIM(cruta) || TRIM(cnomarchivo)||'';
    SYSTEM cSQL;

    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1);
    LET cSQL2 = " SELECT num_promo, nombre_promo, crd.tasa_interes, COUNT(a.nombre_promo) Contratos, SUM(dos.monto_otorgado) monto_otorgado, a.plazo, "
        || " SUM(dos.sdo_capital) cap_insoluto, sum( (select nvl(sum(am11.interes_debe),0) from bdicred:sd_amortiza_creditocrd am11 where a.empresa = am11.empresa "
        || " and a.num_sol_prestamo = am11.num_credito and am11.capital_status!= 5)) int_x_pagar, "
        || " sum( (select nvl(sum(am12.iva_debe),0) from bdicred:sd_amortiza_creditocrd am12 where a.empresa = am12.empresa and a.num_sol_prestamo = am12.num_credito "
        || " and am12.capital_status!= 5)) iva_x_pagar, "
        || " sum( (select nvl(sum(am51.interes_pagado),0) from bdicred:sd_amortiza_creditocrd am51 where a.empresa = am51.empresa and a.num_sol_prestamo = am51.num_credito " 
        || " and am51.capital_status = 5)) int_cargados, sum( (select nvl(sum(am52.iva_pagado),0) from bdicred:sd_amortiza_creditocrd am52 where a.empresa = am52.empresa " 
        || " and a.num_sol_prestamo = am52.num_credito and am52.capital_status = 5)) iva_cargados "
        || " FROM bdicred:sd_promocion_credito a JOIN bdicred:sd_maecredcrd crd "
        || " ON (a.empresa = crd.empresa AND a.num_sol_prestamo = crd.num_credito AND a.num_pro_prestamo = '6900' AND a.empresa = '001') "
        || " JOIN bdicred:sd_maesdoscrd dos ON (a.empresa = dos.empresa AND a.num_sol_prestamo = dos.num_credito) "
        || " WHERE a.status in (0,2,6,7) "
        || " AND a.num_sol_prestamo != '' AND dos.num_credito != '' AND crd.num_credito != '' "
        || " GROUP BY 1,2,3,6 "
        || " ORDER BY num_promo, tasa_interes, plazo ASC; ";

    LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoEjecSql;
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoEjecSql;
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoEjecSql;
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/|$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
    SYSTEM cSql;

    --Borra el archivo de control.
    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || ' ' || TRIM(cruta) || cnomarchivo1;
    SYSTEM cSQL;

    LET cCod_Ret = '000000';
    LET cMensaje = 'PROCESO EXITOSO';

    CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCod_ret, 'TERMINA CREACION REPORTE', '02') Returning cCod_RetIB;


    RETURN cCod_Ret, cMensaje;

 END;   --begin        

END PROCEDURE;