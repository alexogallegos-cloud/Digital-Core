CREATE PROCEDURE "informix".sp_ajuste_2(c_empresa CHAR(3))
RETURNING CHAR(5);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE v_capital    MONEY(14,2);
DEFINE v_interes    MONEY(14,2);
DEFINE v_fecha      DATE;
DEFINE v_num_credito CHAR(20);
-- ****************************************************************************
LET scod_ret     = "00000";
LET vsqlerr      = 0;
LET v_capital    = 0;
LET v_interes    = 0;
LET v_fecha      = "";
LET v_num_credito = "";
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "/tmp/sp_ajuste.out";
-- TRACE ON;




-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

FOREACH
   SELECT num_credito,fecha_cuota,capital,interes
   INTO   v_num_credito,v_fecha,v_capital,v_interes
   FROM   sd_ajuste
   ORDER BY num_credito,fecha_cuota

   IF v_fecha = "10/17/2009" THEN -- Aplica el Interes solo de la Primera
      UPDATE sd_amortiza_creditocrd
      SET    capital_debe = v_capital,
             interes_debe = v_interes
      WHERE  num_credito = v_num_credito
      AND    fecha_cuota = v_fecha;
      UPDATE sd_maesdoscrd
      SET    int_tra_no_exig = v_interes,
             sdo_int_anticip = v_interes,
             sdo_int_anticip = v_interes,
             sdo_acum_mes_int = v_interes,
             sdo_global_int = v_interes ,
             sdo_acum_intper = v_interes,
             sdo_intereses = v_interes
      where empresa = "001"
      and num_credito = v_num_credito;
   ELSE
      UPDATE sd_amortiza_creditocrd
      SET    capital_debe = v_capital,
             interes_debe = 0
      WHERE  num_credito = v_num_credito
      AND    fecha_cuota = v_fecha;
   END IF;

END FOREACH

LET scod_ret ="000";
END
	RETURN scod_ret;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_actualiza_reserva_corte(pEmpresa CHAR(3),dFecha DATE)

RETURNING 
          CHAR(6) AS resultado,
          CHAR(80) AS mensaje,
          CHAR(10) AS registros;
          
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE cCodRet               CHAR(6); 
DEFINE cMensajeRet           CHAR(80);

DEFINE cBegin                 CHAR(1);
DEFINE vcontador_insert       INTEGER;
DEFINE sNumeroCredito        CHAR(20);
--DEFINE dtFechaCalculo        DATE;
DEFINE dtFechaCorte          DATE;
DEFINE dtFechaPeriodo        DATE;
DEFINE dfechaini             DATE;
DEFINE dEndeudamientoTot     DECIMAL(18,5);
DEFINE dEndeudamientoTotCalc  DECIMAL(18,5);
DEFINE dtFechaApertura       DATE;
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
DEFINE vstatus_proc          CHAR(1);
DEFINE vcuotasvenc           INTEGER;
DEFINE vtotal_dias           INTEGER;
DEFINE dPorPago              DECIMAL(18,5);
DEFINE dPorUso               DECIMAL(18,5);

DEFINE dPorPagoMin           DECIMAL(18,5);
DEFINE dPorUsoMin            DECIMAL(18,5);
DEFINE dPorSaldoMin          DECIMAL(18,5);
DEFINE dLimiteCredito        DECIMAL(18,5);
DEFINE dImpPerConACT         DECIMAL(18,5);
DEFINE dImpObsHIST           DECIMAL(18,5);

DEFINE dConsComPI            DECIMAL(18,5);
DEFINE dConsPI               DECIMAL(18,5);
DEFINE dConsACT              DECIMAL(18,5);
DEFINE dConsHIST             DECIMAL(18,5);
DEFINE dConsANT              DECIMAL(18,5);
DEFINE dConsPORPAGO          DECIMAL(18,5);
DEFINE dConsPORUSO           DECIMAL(18,5);
DEFINE dPI                   DECIMAL(18,5);
DEFINE dPIdefaul             DECIMAL(18,5);

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
DEFINE dImporteReservaMesAnt       DECIMAL(18,5);
DEFINE dFechaMesAnt          DATE;
DEFINE iNumcreditos    INTEGER;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      IF cBegin= 'S' THEN
        ROLLBACK WORK;
      END IF;
      RETURN cCodRet, cMensajeRet, iNumcreditos;
   END IF;

END EXCEPTION;

--SET DEBUG FILE TO "sp_actualiza_reserva_corte.out";
--TRACE ON;
 
LET iSqlErr=0;
LET iIsamErr=0;
LET cErrorInfo="";
LET cCodRet= '000000';
LET cMensajeRet= 'El proceso de ACTUALIZACION DEL CORTE se realizó correctamente';
LET cBegin= 'F';
LET vcontador_insert= 0;
LET sNumeroCredito="";
--LET dtFechaCalculo= DATE(1);
LET dtFechaCorte=DATE(1);
LET dtFechaPeriodo=DATE(1);
LET dfechaini=DATE(1);
LET dEndeudamientoTot=0;
LET dEndeudamientoTotCalc=0;
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
LET vtotal_dias=0;
LET dPorPago=0;
LET dPorUso=0;

LET dPorPagoMin=0;
LET dPorUsoMin=0;
LET dPorSaldoMin=0;
LET dLimiteCredito=0;
LET dImpPerConACT=0;
LET dImpObsHIST=0;

LET dConsComPI=0;
LET dConsPI=0;
LET dConsACT=0;
LET dConsHIST=0;
LET dConsANT=0;
LET dConsPORPAGO=0;
LET dConsPORUSO=0;
LET dPI=0;
LET dPIdefaul=0;

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
LET iNumcreditos = 0;


--     LET dtFechaCorte = MDY(MONTH(dtFechaCalculo),20,YEAR(dtFechaCalculo));
--     LET dFechaMesAnt = MDY(MONTH(dtFechaCorte),1,YEAR(dtFechaCorte)) - 1 units day;

    SELECT valor 
      INTO dQuincenal
      FROM bdicred:sd_param_reservas 
      WHERE empresa = pEmpresa
       and cod_param= '1';
    
    IF dQuincenal IS NULL THEN
       LET cCodRet= '000010';
       LET cMensajeRet= 'FALTA PARAMETRO CALCULO DE IMPAGOS QUINCENALES';
       RETURN cCodRet, cMensajeRet,iNumcreditos;
    END IF;
    
    SELECT valor 
      INTO dSemanal
      FROM bdicred:sd_param_reservas 
     WHERE empresa = pEmpresa
       and cod_param= '2';
    
    IF dSemanal IS NULL THEN
       LET cCodRet= '0000020';
       LET cMensajeRet= 'FALTA PARAMETRO CALCULO DE IMPAGOS SEMANALES';
       RETURN cCodRet,cMensajeRet,iNumcreditos;
    END IF;

    SELECT valor 
      INTO dConsPI
      FROM bdicred:sd_param_reservas 
     WHERE empresa = pEmpresa
      and cod_param= '3';

   IF dConsPI IS NULL THEN
      LET cCodRet= '000030';
      LET cMensajeRet= 'FALTA CONSTANTE PARA PROBABILIDAD DE INCUMPLIMIENTO PI';
      RETURN cCodRet, cMensajeRet,iNumcreditos;
   END IF;

   SELECT valor 
     INTO dConsACT
     FROM bdicred:sd_param_reservas 
    WHERE empresa = pEmpresa
      and cod_param= '4';

   IF dConsACT IS NULL THEN
      LET cCodRet= '000040';
      LET cMensajeRet= 'FALTA CONSTANTE IMPAGO ACTUAL PI';
      RETURN cCodRet, cMensajeRet,iNumcreditos;
   END IF;

   SELECT valor 
     INTO dConsHIST
     FROM bdicred:sd_param_reservas 
    WHERE empresa = pEmpresa
      and cod_param= '5';

   IF dConsHIST IS NULL THEN
      LET cCodRet= '000050';
      LET cMensajeRet= 'FALTA CONSTANTE IMPAGO HISTORICO PI';
      RETURN cCodRet, cMensajeRet,iNumcreditos;
   END IF;

   SELECT valor 
     INTO dConsANT
     FROM bdicred:sd_param_reservas 
    WHERE empresa = pEmpresa
      and cod_param= '6';

   IF dConsANT IS NULL THEN
      LET cCodRet= '000060';
      LET cMensajeRet= 'FALTA CONSTANTE ANTIGÜEDAD PI';
      RETURN cCodRet, cMensajeRet,iNumcreditos;
   END IF;

   SELECT valor 
     INTO dConsPORPAGO
     FROM bdicred:sd_param_reservas 
    WHERE empresa = pEmpresa
      and cod_param= '7';

   IF dConsPORPAGO IS NULL THEN
      LET cCodRet= '000070';
      LET cMensajeRet= 'FALTA CONSTANTE PARA EL CALCULO DE PORCENTAJE PAGO PI';
      RETURN cCodRet, cMensajeRet,iNumcreditos;
   END IF;

   SELECT valor 
     INTO dConsPORUSO
     FROM bdicred:sd_param_reservas 
    WHERE empresa = pEmpresa
     and cod_param= '8';

   IF dConsPORUSO IS NULL THEN
      LET cCodRet= '000080';
      LET cMensajeRet= 'FALTA CONSTANTE PARA EL CALCULO DE PORCENTAJE USO PI';
      RETURN cCodRet, cMensajeRet,iNumcreditos;
   END IF;

    SELECT valor 
      INTO dPorPagoMin
      FROM bdicred:sd_param_reservas 
     WHERE empresa = pEmpresa
       and cod_param= '9';
    
    IF dPorPagoMin IS NULL THEN
       LET cCodRet= '000090';
       LET cMensajeRet= 'FALTA PARAMETRO PORCENTAJE DE PAGO MINIMO';
       RETURN cCodRet, cMensajeRet,iNumcreditos;
    END IF;

    SELECT valor 
      INTO dPorUsoMin
      FROM bdicred:sd_param_reservas 
     WHERE empresa = pEmpresa
       and cod_param= '10';
    
    IF dPorUsoMin IS NULL THEN
       LET cCodRet= '000100';
       LET cMensajeRet= 'FALTA PARAMETRO PORCENTAJE DE USO MINIMO';
       RETURN cCodRet, cMensajeRet,iNumcreditos;
    END IF;

    SELECT valor 
      INTO dPIdefaul
      FROM bdicred:sd_param_reservas 
     WHERE empresa = pEmpresa 
      and cod_param= '13';

    IF dPIdefaul IS NULL THEN
       LET cCodRet= '000130';
       LET cMensajeRet= 'FALTA CONSTANTE PARA PROBABILIDAD DE INCUMPLIMIENTO >=4';
       RETURN cCodRet, cMensajeRet,iNumcreditos;
    END IF;

    SELECT valor 
      INTO dConsSPMenor
      FROM bdicred:sd_param_reservas 
     WHERE empresa = pEmpresa
       and cod_param= '14';
    
    IF dConsSPMenor IS NULL THEN
       LET cCodRet= '000140';
       LET cMensajeRet= 'FALTA CONSTANTE SEVERIDAD DE LA PERDIDA CUANDO ACT<12 ';
       RETURN cCodRet, cMensajeRet,iNumcreditos;
    END IF;
    
   SELECT valor 
     INTO dConsSPMayor
     FROM bdicred:sd_param_reservas 
     WHERE empresa = pEmpresa
       and cod_param= '15';

   IF dConsSPMayor IS NULL THEN
      LET cCodRet= '000150';
      LET cMensajeRet= 'FALTA CONSTANTE SEVERIDAD DE LA PERDIDA CUANDO ACT>=12';
      RETURN cCodRet, cMensajeRet,iNumcreditos;
   END IF;

    SELECT valor 
      INTO dConsComPI
      FROM bdicred:sd_param_reservas 
     WHERE empresa = pEmpresa
     and cod_param= '16';

     IF dConsComPI IS NULL THEN
        LET cCodRet= '000160';
        LET cMensajeRet= 'FALTA CONSTANTE COMPARACIÓN PARA PI';
        RETURN cCodRet, cMensajeRet,iNumcreditos;
    END IF;

    SELECT valor 
      INTO dPorSaldoMin
      FROM bdicred:sd_param_reservas 
     WHERE empresa = pEmpresa
       and cod_param= '17';
    
    IF dPorSaldoMin IS NULL THEN
       LET cCodRet= '000170';
       LET cMensajeRet= 'FALTA PARAMETRO PORCENTAJE DE SALDO MINIMO';
       RETURN cCodRet, cMensajeRet,iNumcreditos;
    END IF;

    SELECT valor 
      INTO dImpPerConACT
      FROM bdicred:sd_param_reservas 
     WHERE empresa = pEmpresa
       and cod_param= '18';
    
    IF dImpPerConACT IS NULL THEN
       LET cCodRet= '000180';
       LET cMensajeRet= 'FALTA PARAMETRO IMPAGOS EN PERIODOS CONSECUTIVOS ACT';
       RETURN cCodRet, cMensajeRet,iNumcreditos;
    END IF;

    SELECT valor 
      INTO dImpObsHIST
      FROM bdicred:sd_param_reservas 
     WHERE empresa = pEmpresa
     and cod_param= '20';
    
    IF dImpObsHIST IS NULL THEN
       LET cCodRet= '000200';
       LET cMensajeRet= 'FALTA PARAMETRO IMPAGOS OBSERVADOS ULTIMOS MESES HIST';
       RETURN cCodRet, cMensajeRet,iNumcreditos;
    END IF;

    SELECT valor 
      INTO dConsMinPorPago
      FROM bdicred:sd_param_reservas 
     WHERE empresa = pEmpresa
     and cod_param= '21';
    
    IF dConsMinPorPago IS NULL THEN
       LET cCodRet= '000210';
       LET cMensajeRet= 'FALTA VALOR MINIMO COMPARATIVO % DE PAGO';
       RETURN cCodRet, cMensajeRet,iNumcreditos;
    END IF;

    SELECT valor 
      INTO dConsMaxPorPago
      FROM bdicred:sd_param_reservas 
     WHERE empresa = pEmpresa
     and cod_param= '22';
    
    IF dConsMaxPorPago IS NULL THEN
       LET cCodRet= '000220';
       LET cMensajeRet= 'FALTA MAXIMO COMPARATIVO % DE PAGO';
       RETURN cCodRet, cMensajeRet,iNumcreditos;
    END IF;
    
    SELECT valor 
      INTO dConsMinPorUso
      FROM bdicred:sd_param_reservas 
     WHERE empresa = pEmpresa
     and cod_param= '23';
    
    IF dConsMinPorUso IS NULL THEN
       LET cCodRet= '000230';
       LET cMensajeRet= 'FALTA MINIMO COMPARATIVO % DE USO';
       RETURN cCodRet, cMensajeRet,iNumcreditos;
    END IF;

    SELECT valor 
      INTO dConsMaxPorUso
      FROM bdicred:sd_param_reservas 
     WHERE empresa = pEmpresa
     and cod_param= '24';
    
    IF dConsMaxPorUso IS NULL THEN
       LET cCodRet= '000240';
       LET cMensajeRet= 'FALTA MAXIMO COMPARATIVO % DE USO';
       RETURN cCodRet, cMensajeRet,iNumcreditos;
    END IF;
  
-- Se obtienen los datos del crédito.
FOREACH WITH HOLD
            SELECT a.num_credito, 
                   NVL(b.sdo_capital,0) + NVL(b.cap_tras_no_venci,0) + NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0),
                   a.limite_credito,a.pagos_realizados, fecha_corte
               INTO sNumeroCredito, 
                    dEndeudamientoTot,
                    dLimiteCredito,dPagoRealizado, dFechaMesAnt
               FROM bdicred:sd_hist_reserva a, bdicred:sd_maesdoshist b
              WHERE a.empresa          = pEmpresa           
                AND a.empresa          = b.empresa
                AND a.num_credito      = b.num_credito     
                AND b.fecha            = mdy(month(dFecha),20,year(dFecha))
                AND a.fecha_corte     >= mdy(month(dFecha),20,year(dFecha))  ---fecha al último día del mes de Agosto 2009

     IF (vcontador_insert = 0) THEN
       LET cBegin= 'S';
       BEGIN WORK;
     END IF;

                  -- Se determina el endeudamiento total (saldo)
                  -- Se calcula % de Pago 
                  -- Se calcula % de Uso 
                    IF dEndeudamientoTot > 0 THEN
                       LET dPorPago = dPagoRealizado / dEndeudamientoTot; 
                       LET dPorUso  = dEndeudamientoTot / dLimiteCredito; 
                    ELSE
                       IF dLimiteCredito = 0 OR dLimiteCredito IS NULL  THEN
                           LET dEndeudamientoTot = 0; 
                           LET dPorPago = 0; 
                       ELSE
                           LET dEndeudamientoTotCalc = dLimiteCredito * dPorSaldoMin; 
                           LET dPorPago = (dPorPagoMin * dLimiteCredito) / dEndeudamientoTotCalc; 
                       END IF
                       LET dPorUso  = dPorUsoMin;
                    END IF

                  -- Valida rangos para %PAGO y %USO 
                    IF dPorPago > dConsMaxPorPago THEN LET dPorPago = dConsMaxPorPago; ELIF dPorPago < dConsMinPorPago THEN LET dPorPago = dConsMinPorPago; END IF 
                    IF dPorUso  > dConsMaxPorUso THEN LET dPorUso  = dConsMaxPorUso; ELIF dPorUso  < dConsMinPorUso THEN LET dPorUso  = dConsMinPorUso; END IF 

                 --Se calcula PI (Probabilidad de Incumplimiento)
                   IF iACT < dConsComPI THEN
                      LET dPI = (1/(1 + EXP(-(dConsPI + (dConsACT * iACT) + (dConsHIST * iHIST) + (dConsANT * iANT) + (dConsPORPAGO * dPorPago) + (dConsPORUSO * dPorUso)))));
                   ELSE
                      LET dPI = dPIdefaul;
                   END IF;
            

                   -- Se almacena la información correspondiente al calculo de la reservas preventivas.
                    UPDATE informix.sd_hist_reserva 
                       SET
                           saldo_corte      = dEndeudamientoTot,
                           probabilidad_incumplimiento = dPI * 100,
                           porcentaje_pago  = dPorPago * 100,
                           porcentaje_uso   = dPorUso * 100,
                           porcentaje_reserva_edo_resultados = - 1
--                          reserva_buro_gradual         = 888
                     WHERE empresa = pEmpresa
                       AND num_credito = sNumeroCredito
                       AND fecha_corte = dFechaMesAnt;

LET vcontador_insert = vcontador_insert + 1;
LET iNumcreditos = iNumcreditos + 1;


IF (vcontador_insert >= 60000) THEN
   COMMIT WORK;
   LET vcontador_insert = 0;
 --  UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_hist_reserva;
END IF;

END FOREACH;

IF (vcontador_insert > 0) THEN
  COMMIT WORK;
END IF;

    UPDATE statistics medium FOR TABLE sd_hist_reserva;
    
  RETURN cCodRet,cMensajeRet,iNumcreditos;

END
END PROCEDURE

;