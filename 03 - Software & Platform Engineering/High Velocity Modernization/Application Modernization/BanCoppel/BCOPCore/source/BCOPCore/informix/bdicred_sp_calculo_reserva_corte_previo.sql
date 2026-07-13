CREATE PROCEDURE "informix".sp_calculo_reserva_corte_previo(pEmpresa CHAR(3))

RETURNING
          CHAR(6) AS resultado,
          CHAR(80) AS mensaje;

DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE cCodRet               CHAR(6);
DEFINE cMensajeRet           CHAR(80);

DEFINE cBegin                 CHAR(1);
DEFINE vcontador_insert       INTEGER;
DEFINE sNumeroCredito        CHAR(20);
DEFINE auxNumeroCredito      CHAR(20);
DEFINE dtFechaCalculo        DATE;
DEFINE dtFechaUltMes         DATE;
DEFINE dtFechaCorte          DATE;
DEFINE dtFechaPeriodo        DATE;
DEFINE dfechaini             DATE;
DEFINE dEndeudamientoTot     DECIMAL(18,5);
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
DEFINE dPI                   DECIMAL(30,10);
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
DEFINE cGradoRiesgo          CHAR(2);
DEFINE vReservaGradual       DECIMAL(18,5);
DEFINE dGradual              DECIMAL(18,5);
DEFINE vImporteReservaBuroCC DECIMAL(18,5);
DEFINE dIvaVencido           DECIMAL(18,5);
DEFINE vProducto             CHAR(4);
DEFINE vNvoPeriodo           INTEGER;
DEFINE vDivisa               CHAR(2);

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

--SET DEBUG FILE TO "/pisa/cas/sp_calculo_reserva_corte.out";
--TRACE ON;

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
LET dtFechaCorte=DATE(1);
LET dtFechaPeriodo=DATE(1);
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
LET cGradoRiesgo= '';
LET vReservaGradual = 0;
LET dGradual = 0;
LET vImporteReservaBuroCC = 0;
LET dIvaVencido = 0;
LET vProducto = '';
LET vNvoPeriodo = 0;
LET vDivisa = '';

-- Se obtiene la fecha hoy del sistema.
    SELECT fecha_hoy,ult_dia_mes
      INTO dtFechaCalculo,dtFechaUltMes
      FROM bdicred:sd_fechas
	 WHERE empresa = pEmpresa;

     LET dtFechaCorte = MDY(MONTH(dtFechaCalculo),20,YEAR(dtFechaCalculo));
--Se obtiene el último día del mes anterior para obtener la reserva de la sd_hisvalcon
     LET dFechaMesAnt = MDY(MONTH(dtFechaCorte),1,YEAR(dtFechaCorte)) - 1 units day;

    SELECT valor INTO dQuincenal FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '1';

    IF dQuincenal IS NULL THEN
       LET cCodRet= '000010';
       LET cMensajeRet= 'FALTA PARAMETRO CALCULO DE IMPAGOS QUINCENALES';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dSemanal FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '2';

    IF dSemanal IS NULL THEN
       LET cCodRet= '0000020';
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

     SELECT valor INTO dPorUsoMinCtesNunca FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '19';

     IF dPorUsoMinCtesNunca IS NULL THEN
       LET cCodRet= '000019';
       LET cMensajeRet= 'FALTA PORCENTAJE USO MINIMO CLIENTES NUNCA';
       RETURN cCodRet, cMensajeRet;
     END IF;

    SELECT valor INTO dPorResSic FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '25';

    IF dPorResSic IS NULL THEN
       LET cCodRet= '000250';
       LET cMensajeRet= 'FALTA PORCENTAJE DE RESERVA DE SIC';
       RETURN cCodRet, cMensajeRet;
    END IF;

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

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

     EXECUTE PROCEDURE bdicred:monthadd(dtFechaCorte, -1) INTO dtFechaPeriodo;

        SELECT empresa,sucursal,iva
          FROM bdinteg:si_sucursales d
         WHERE empresa = pEmpresa
           AND sucursal<> ''
          INTO temp cr_sucursales3;
        CREATE INDEX crsucursales3 on cr_sucursales3 (empresa, sucursal);
        update statistics medium for table cr_sucursales3;

-- Se obtienen los datos del crédito.
FOREACH WITH HOLD
   SELECT a.num_credito, a.status_cred,a.sucursal,a.num_producto,
          a.periodo_plazo, a.fecha_apertura,a.divisa,
          NVL(b.sdo_cap_insoluto,0),
          NVL(NVL(b.int_tra_no_exig,0) - case when NVL(b.mto_venc_trasp + b.monto_vencido,0) > 0 then NVL(b.sdo_int_anticip,0) else 0 end,0),
		  NVL(b.sdo_moratorio,0) + NVL(b.sdo_contab_mora,0),
          NVL(b.monto_otorgado,0), NVL(b.monto_financiado,0)
     INTO sNumeroCredito, cStatusCred,v_sucursal,vProducto,
          cPeriodicidad, dtFechaApertura, vDivisa,
          dEndeudamientoTot,dInteVencIva,dMoratorios,dLimiteCredito,dPagoMinimo
     FROM bdicred:sd_maecred a
     LEFT OUTER JOIN bdicred:sd_maesdoshist b on (a.empresa = b.empresa AND a.num_credito = b.num_credito AND b.fecha = dtFechaPeriodo)
    WHERE a.empresa          = pEmpresa
      AND a.status_cred      IN ("AA","BA","BT","E1","E2","E3")
      AND a.fecha_apertura   <= dtFechaCalculo
      AND a.num_producto <> '6600'
      AND a.num_credito  not in (SELECT num_credito FROM bdicred:sd_hist_reserva_prueba WHERE a.empresa = empresa AND fecha_corte = dtFechaCorte)


        SELECT iva
          INTO v_iva_suc
          FROM cr_sucursales3
         WHERE empresa = pEmpresa
           AND sucursal= v_sucursal;

         SELECT NVL(campo_trabajo1,0)
           INTO dIvaVencido
           FROM sd_amortiza_credito
          WHERE empresa = pEmpresa
            AND num_credito = sNumeroCredito
            AND fecha_cuota = dtFechaPeriodo;

       IF dIvaVencido IS NULL THEN
          LET dIvaVencido=0;
       END IF;

       LET dMoratorios = Round(dMoratorios * (1 + v_iva_suc),2);
       LET dEndeudamientoTot  = dEndeudamientoTot + dMoratorios + dInteVencIva + dIvaVencido;
       LET dPagoMinimo  = dPagoMinimo + dMoratorios + dInteVencIva + dIvaVencido;

     LET cMensajeRet = sNumeroCredito;

     IF (vcontador_insert = 0) THEN
       LET cBegin= 'S';
       BEGIN WORK;
     END IF;

     LET iACT=0;
     LET iHIST=0;
     LET i=0;
	 LET iBanderaConc=0;

    IF dtFechaApertura > dtFechaCorte THEN
     FOREACH
           SELECT first dImpPerConACT monto_vencido + mto_venc_trasp
             INTO dIncumplimiento
             FROM bdicred:sd_maesdoshist
            WHERE empresa= pEmpresa  
              AND fecha <= dtFechaCorte
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

         IF cPeriodicidad = "Q" THEN
            LET iACT= iACT * dQuincenal;
            LET iHIST= iHIST * dQuincenal;
         ELIF cPeriodicidad = "S" THEN
            LET iACT= iACT * dSemanal;
            LET iHIST= iHIST * dSemanal;
         END IF;

         IF  dtFechaApertura <= dtFechaCorte THEN
             SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} NVL(SUM(monto),0)
               INTO dPagoRealizado
               FROM bdicred:sd_movhis
              WHERE empresa = pEmpresa
                AND fecha_mov > dtFechaPeriodo
                AND fecha_mov <=dtFechaCorte
                AND num_credito = sNumeroCredito
                AND codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanual)
                AND codigo_ref = 1
                AND reversado = 'N';
         END IF;
    -- Se cambia el calculo de la antigûedad tomando la fecha de fin de mes como base, a solicitud del usuario.
         LET iANT = round((dtFechaUltMes - dtFechaApertura)/30,2);

         SELECT fecha_vencto
           INTO dfechaini
           FROM sd_maecredanexo
          WHERE empresa = pempresa
            AND num_credito = sNumeroCredito;

         IF dfechaini IS NOT NULL THEN
            LET vcuotasvenc = ((Year(dtFechaCorte) - Year(dfechaini)) * 12) + Month(dtFechaCorte) - Month(dfechaini);
            IF vcuotasvenc IS NULL THEN
               LET vcuotasvenc = 0;
            END IF;
            IF vcuotasvenc < 0 THEN
               LET vcuotasvenc = 0;
            END IF;
         ELSE
             LET vcuotasvenc = 0;
         END IF;

    --Se obtiene la reserva del mes anterior
        select nvl(reserva_calificacion,0)
          into dImporteReservaMesAnt
          from sd_hist_reserva
         where empresa = pEmpresa
           and num_credito = sNumeroCredito
           and fecha_cierre = dFechaMesAnt;
    ELSE

        SELECT pagos_realizados,meses_antiguedad,severidad_perdida,impagos_consecutivos,
               impagos_historicos,num_periodos,reserva_calif_mes_anterior
          INTO dPagoRealizado,iANT,dSP,iACT,iHIST,vcuotasvenc,dImporteReservaMesAnt
          FROM bdicred:sd_hist_reserva
         WHERE empresa     = pEmpresa
           AND fecha_corte = dtFechaCorte
           AND num_credito = sNumeroCredito;

           IF dPagoRealizado IS NULL THEN LET dPagoRealizado=0; END IF;
           IF iANT IS NULL THEN LET iANT=0; END IF;
           IF dSP IS NULL THEN LET dSP=0; END IF;
           IF iACT IS NULL THEN LET iACT=0; END IF;
           IF iHIST IS NULL THEN LET iHIST=0; END IF;
           IF vcuotasvenc IS NULL THEN LET vcuotasvenc=0; END IF;
    END IF;

           IF dImporteReservaMesAnt IS NULL THEN LET dImporteReservaMesAnt=0; END IF;

---CALCULA LAS RESERVAS PARA LOS CLIENTES NUNCA Y PARA LOS CLIENTES TOTALEROS(INTRA)
   IF (dEndeudamientoTot<=0 AND dPagoRealizado>=0) THEN
-- Se obtiene el antecedente a Buró
     SELECT evalua_cc
       INTO dEvaBuro
       FROM bdisolic:ss_resum_scor_fin
      WHERE empresa = pempresa
        AND num_solicitud = sNumeroCredito;

-- Se obtiene la línea autorizada
     IF (dtFechaApertura > dtFechaPeriodo) then
         SELECT monto_solicitado
           INTO dLimiteCredito
           FROM bdisolic:ss_solicitudes
          WHERE empresa = pempresa
            AND num_solicitud = sNumeroCredito;

            IF dLimiteCredito is null THEN
               LET dLimiteCredito = 0;
            END IF;
     END IF;

       IF (dEndeudamientoTot<=0 AND dPagoRealizado=0) THEN
          LET dResCalificacion = dPorUsoMinCtesNunca * (CASE WHEN (dLimiteCredito + dEndeudamientoTot) < 0 THEN 0 ELSE (dLimiteCredito + dEndeudamientoTot) END);
          LET vReservaGradual= dResCalificacion * dGradual;
          IF dEvaBuro='1' THEN
             LET vImporteReservaBuroCC = dResCalificacion * dPorResSic * dGradual;
          END IF;
       ELSE
          LET vImporteReservaBuroCC = 0;
          LET dResCalificacion      = 0;
          LET vReservaGradual       = 0;
       END IF;


       INSERT INTO "informix".sd_hist_reserva_prueba
        (empresa, fecha_corte, num_credito, fecha_cierre, grado_riesgo, fecha_apertura, antecedente_buro,
         status_cred, linea_autorizada, limite_credito, interes_cred_ven, saldo_corte, saldo_cierre, pago_minimo,
         pagos_realizados, reserva_int_cred_ven, reserva_buro, reserva_calificacion, porcentaje_reserva,
         meses_antiguedad, probabilidad_incumplimiento, severidad_perdida, exposicion_incumplimiento,
         impagos_consecutivos, impagos_historicos, porcentaje_pago, porcentaje_uso, num_periodos,
         exposicion_inc_gradual, grado_riesgo_gradual, reserva_calificacion_gradual, porcentaje_reserva_gradual,
         reserva_buro_gradual, reserva_int_cred_ven_gradual, reserva_calif_mes_anterior, grado_riesgo_bancoppel,
         grado_riesgo_edo_resultados, reserva_edo_resultados, porcentaje_reserva_edo_resultados)
       VALUES
        (pEmpresa, dtFechaCorte, sNumeroCredito, NULL,cGradoRiesgo, dtFechaApertura, dEvaBuro,cStatusCred,
         dLineaAutorizada,dLimiteCredito,0,dEndeudamientoTot,0, dPagoMinimo, dPagoRealizado,0,vImporteReservaBuroCC,
        dResCalificacion,(CASE WHEN dPagoRealizado>0 THEN 0 ELSE dPorUsoMinCtesNunca END)*100, iANT,0,
        (case when iACT< dImpPerConACT then dConsSPMenor else dConsSPMayor end)*100,0,iACT,iHIST,0,0,vcuotasvenc,0,
        cGradoRiesgo,vReservaGradual,0,vImporteReservaBuroCC,0,dImporteReservaMesAnt, 'IN',cGradoRiesgo,vReservaGradual,0);

         LET vNvoPeriodo= 1;

/*------------------------------------------------------------------------------------
        IF vReservaGradual>0 THEN
        -- Genera Movimiento para Contabilidad
            EXECUTE PROCEDURE genmov_calif (pEmpresa,
                                            sNumeroCredito,
                                            vProducto,
                                            vNvoPeriodo,
                                            "070", --665
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
        IF vReservaGradual > 0 AND (dLimiteCredito + dEndeudamientoTot) > 0 THEN
            EXECUTE PROCEDURE genmov_calif (pEmpresa,
                                            sNumeroCredito,
                                            vProducto,
                                            vNvoPeriodo,
                                            "071", --666
                                            dtFechaUltMes,
                                            (dLimiteCredito + dEndeudamientoTot),
                                            "CalifCart",
                                             v_sucursal,
                                             vDivisa,
                                             "0000")
            INTO cCodRet, cMensajeRet;
            IF TRIM(cCodRet) <> "00000" THEN
               RETURN cCodRet, cMensajeRet;
            END IF;
        END IF;

        IF vImporteReservaBuroCC > 0 THEN
            --Califica malos antecedentes
              EXECUTE PROCEDURE genmov_calif (pEmpresa,
                                              sNumeroCredito,
                                              vProducto,
                                              51,
                                              "661",
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
        END IF;*/
------------------------------------------------------------------------------------
       LET auxNumeroCredito="";
       LET vcontador_insert = vcontador_insert + 1;
       CONTINUE FOREACH;
   END IF;
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
     IF dPorPago  > dConsMaxPorPago THEN LET dPorPago  = dConsMaxPorPago; END IF

-- Se calcula SP (Severidad de la Pérdida)
     IF iACT < dImpPerConACT THEN
        LET dSP = dConsSPMenor;
     ELSE
        LET dSP = dConsSPMayor;
     END IF;

--Se calcula PI (Probabilidad de Incumplimiento)
     IF iACT >= dConsComPI THEN -- Valor 4
        LET dPI = dPIdefaul; --Valor 1
     ELSE
         LET dPI = (1/(1 + EXP(-(dConsPI + (dConsACT * iACT) + (dConsHIST * iHIST) + (dConsANT * iANT) + (dConsPORPAGO * dPorPago) + (dConsPORUSO * dPorUso)))));
     END IF;

-- Se obtiene el antecedente a Buró
     SELECT evalua_cc
       INTO dEvaBuro
       FROM bdisolic:ss_resum_scor_fin
      WHERE empresa = pempresa
        AND num_solicitud = sNumeroCredito;

-- Se obtiene la línea autorizada
 /*    SELECT monto_solicitado
       INTO dLineaAutorizada
       FROM bdisolic:ss_solicitudes
      WHERE empresa = pempresa
        AND num_solicitud = sNumeroCredito;
*/
                   -- Se almacena la información correspondiente al calculo de la reservas preventivas.
     INSERT INTO "informix".sd_hist_reserva_prueba
/*
(empresa,fecha_corte,num_credito,fecha_cierre,grado_riesgo,fecha_apertura,antecedente_buro,status_cred,linea_autorizada,
limite_credito,interes_cred_ven,saldo_corte,saldo_cierre,pago_minimo,pagos_realizados,reserva_int_cred_ven,reserva_buro,
reserva_calificacion,porcentaje_reserva,meses_antiguedad,probabilidad_incumplimiento,severidad_perdida,exposicion_incumplimiento,
impagos_consecutivos,impagos_historicos,porcentaje_pago,porcentaje_uso,num_periodos,exposicion_inc_gradual,grado_riesgo_gradual,
reserva_calificacion_gradual,porcentaje_reserva_gradual,reserva_buro_gradual,reserva_int_cred_ven_gradual,reserva_calif_mes_anterior,
grado_riesgo_bancoppel)
*/
          VALUES (pEmpresa,
                  dtFechaCorte,
                  sNumeroCredito,
                  null,
                  null,
                  dtFechaApertura,
                  dEvaBuro,
                  cStatusCred,
                  dLineaAutorizada,
                  dLimiteCredito,
                  null,
                  dEndeudamientoTot,
                  null,
                  dPagoMinimo,
                  dPagoRealizado,
                  null,
                  null,
                  null,
                  null,
                  iANT,
                  dPI * 100,
                  dSP * 100,
                  null,
                  iACT,
                  iHIST,
                  dPorPago * 100,
                  dPorUso * 100,
                  vcuotasvenc,
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,
                  dImporteReservaMesAnt,
                  null,
                  null,
                  null,
                  null
);

--Se inicializan variables del cursor
   LET sNumeroCredito =0;
   LET cStatusCred =0;
   LET cPeriodicidad =0;
   LET dtFechaApertura =0;
   LET dEndeudamientoTot =0;
   LET dLimiteCredito =0;
   LET dPagoMinimo =0;

   LET auxNumeroCredito="";

   LET vcontador_insert = vcontador_insert + 1;

   IF (vcontador_insert >= 7000) THEN
      COMMIT WORK;
      LET vcontador_insert = 0;
--      UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_hist_reserva;
   END IF;

END FOREACH;

IF (vcontador_insert > 0) THEN
   COMMIT WORK;
END IF;

UPDATE statistics medium FOR TABLE sd_hist_reserva_prueba;

  DROP TABLE cr_sucursales3;
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

CREATE PROCEDURE "informix".sp_camp_primer_uso_cierra9a10repcanc(pempresa CHAR(3), pServicio CHAR(2), pMessinact SMALLINT, pdFechaHoy DATE)

RETURNING CHAR(6);

--Creado: MAHR. Diciembre 2012 
-- Servicio 10-> Campaña;10 Cierre de cifras de campaña 9, y creacion de reporte de cuentas canceladas "automaticamente".


--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE vproceso				CHAR(4);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnombreTelef			CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivo_tel1     CHAR(100);
DEFINE cnomarchivo_tel      CHAR(100);
DEFINE cnomarchivoejecsql   CHAR(100);
DEFINE cSQL                 CHAR(8204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(3000);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
DEFINE cCod_Promocion       CHAR(3);
DEFINE dfecha_gen_camp      DATE;
DEFINE dfecha_ejec_camp     DATE;
DEFINE dfecha_ent_desde     DATE;
DEFINE dfecha_ent_hasta     DATE;
DEFINE sParamNombArch       SMALLINT;
DEFINE sParamNombArchTelef  SMALLINT;
DEFINE sParamRutaArch       SMALLINT;
DEFINE sNum_logica          SMALLINT;
DEFINE sNumCampania         SMALLINT;
DEFINE itot_tarj_inact      INTEGER;


--SET DEBUG FILE TO "sp_camp_primer_uso_cierra9a10repcanc.out";
--TRACE ON;

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = '000000';
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0601';
LET cruta                   = "";
LET cnombre					= "";
LET cnombreTelef            = "";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnomarchivo_tel1        = "";
LET cnomarchivo_tel         = "";
LET cnomarchivoejecsql      = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "";
LET cdelimitador            = "";
LET cCod_RetIB              = '000000';
LET sParamNombArch          = 0;
LET sParamNombArchTelef     = 0;
LET sParamRutaArch          = 0;
LET sNumCampania            = 0;
LET cCod_Promocion          = "";
LET sNum_logica             = 0;
LET itot_tarj_inact         = 0;


BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, trim(cMensaje) || 'PROCESO' || pServicio, '02') Returning cCod_RetIB;
        RETURN cCod_ret;
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, 'PROCESO INICIALIZADO ' || pServicio , '02') Returning cCod_RetIB;

	-- Validacion de parámetros de entrada
	IF (NVL(pEmpresa,"") = "" OR NVL(pServicio, "") = "" OR pMessinact = 0 ) THEN
        LET cCod_Ret= '104001'; 
        SELECT descripcion INTO cMensaje
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje || pServicio, '02') Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

	--Validación de la empresa
	SELECT empresa INTO cempresa FROM bdinteg:si_empresas WHERE empresa = pempresa;
	IF NVL (cempresa, '') = '' THEN
        LET cCod_Ret = '104002';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje || pServicio, '02') Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;
  
	--Obtener caracter delimitador
	SELECT trim(valor_alfabetico) INTO cdelimitador FROM bdicobranza:"informix".cb_param_campania WHERE empresa = pempresa
        AND tipo_campania = 1 AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 26;
	IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje || pServicio, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

    -- Asigna parametros con nombres de archivos y ruta, dependiendo del servicio (subcampaña).
    LET sParamRutaArch = 1;
    LET sParamNombArch = 43;
    LET sParamNombArchTelef = 44;
    LET sNumCampania = pServicio::SMALLINT; -- Asigna el numero de campaña en base al servicio


    -- Obtiene las fechas: Fecha de campaña, fecha entregada desde, fecha entregadas hasta de la campaña correspondiente para la campaña 2
        -- se realiza el calculo de manera distinta.
    LET dfecha_ejec_camp = pdFechaHoy - pMessinact units month; -- Se obtiene la fecha de campaña de la campaña anterior ejecutada en el mes calculado
    SELECT first 1 fecha_gen_campania, fecha_entreg_desde, fecha_entreg_hasta INTO dfecha_gen_camp, dfecha_ent_desde, dfecha_ent_hasta
        FROM bdicred:"informix".sd_camp_primer_uso WHERE month(fecha_ejecucion) = month(dfecha_ejec_camp)
        AND year(fecha_ejecucion) = year(dfecha_ejec_camp) AND num_campania = (sNumCampania - 1);
    IF dfecha_gen_camp IS NULL THEN     --  Termina proceso, ya que no existe campaña generada para esta fecha.
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, 'SIN CAMPAÑA ' || pServicio, '02') Returning cCod_RetIB;
        LET cCod_Ret = '000001';
        RETURN cCod_Ret;
    END IF;

    -- Obtiene la ruta del archivo
	SELECT TRIM(valor_alfabetico) INTO cruta FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
        AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = sParamRutaArch; 
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret = '104005';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje || pServicio, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

	-- Obtiene el nombre del archivo a generar con datos del cliente.
	SELECT TRIM(valor_alfabetico) INTO cnombre FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
        AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = sParamNombArch; 
	IF NVL (cnombre,'') = '' THEN
        LET cCod_Ret= '102002';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje || pServicio, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

	-- Obtiene el nombre del archivo de telefonos a generar.
	SELECT TRIM(valor_alfabetico) INTO cnombreTelef FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
       AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = sParamNombArchTelef; 
	IF NVL (cnombreTelef,'') = '' THEN
        LET cCod_Ret= '102002';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje || pServicio, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;


    -- Obtiene el codigo de la promocion y numero de logica de la misma.
    SELECT TRIM(valor_alfabetico) INTO cCod_Promocion FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'TIPO_PROM' AND num_parametro = 8;
    SELECT num_parametro INTO sNum_logica FROM sd_param_campania WHERE grupo_parametro = 'TIPOLOGICA' AND num_parametro = 8;


    -- Finaliza cifras de campaña 9 para medir efectividad.
    SELECT COUNT(a.num_credito) INTO itot_tarj_inact    --  Obtiene el total de tarjetas inactivas al momento 
        FROM bdicred:sd_camp_primer_uso a JOIN bdicred:sd_indicador_cred ind on ( a.empresa = ind.empresa and a.num_credito = ind.num_credito) 
																							   
																																															  
        JOIN bdicred:sd_maecred cred ON ( a.empresa = cred.empresa and a.num_credito = cred.num_credito and cred.status_cred IN ('AA','E1')) 
        WHERE a.empresa = pempresa
        AND a.fecha_gen_campania = dfecha_gen_camp AND a.fecha_entreg_desde = dfecha_ent_desde AND a.fecha_entreg_hasta = dfecha_ent_hasta
        AND a.num_campania = (sNumCampania - 1) 
        AND a.status_tarj = 'INACT'
        AND ( ind.f_primer_compra IS NULL OR ind.f_primer_compra = date(1) )
        AND ( ind.f_primer_disp IS NULL OR ind.f_primer_disp = date(1) );


    -- Se actualizan datos de la campaña anterior. Las inactivas restantes de la campaña anterior = Las entregadas de esta campaña
    UPDATE bdicred:cb_1eruso_rep_seguim SET tot_tarj_inactivas = itot_tarj_inact, tot_tarj_activas = (tot_tarj_entregadas - itot_tarj_inact),
                porcentaje_efec = (((tot_tarj_entregadas - itot_tarj_inact) / tot_tarj_entregadas) * 100)::INTEGER
        WHERE fecha_gen_campania = dfecha_gen_camp AND fecha_entreg_desde = dfecha_ent_desde AND fecha_entreg_hasta = dfecha_ent_hasta 
		  AND sub_campania = (sNumCampania - 1); 


    -- Genera el ARCHIVO con los datos de los clientes a partir de los almacenado. Asigna nombre de archivo, segun parametro y la fecha correspondiente
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||substr(year(pdFechaHoy),3)||to_char(pdFechaHoy,'%m%d')||'.txt';
    LET cnomarchivo  =  trim(cnombre)||substr(year(pdFechaHoy),3)||to_char( pdFechaHoy,'%m%d')||'.txt';
    LET cnomarchivoejecsql = 'Ejecuta_gen_arch_Camp_primer_uso.sql';
    LET cSql='';
    LET cSql = 'echo "tipo_promocion'||';'||'tipo_logica'||';'||'fecha_insercion'||';'||'num_credito'||';'||'sucursal'||';'||'num_cliente'||';'
            ||'no_tarjeta'||';'|| 'status_prom'||';'||'prioridad'||';'||'ap_paterno'||';'||'ap_materno' ||';'|| 'primer_nombre' ||';'
            ||'segundo_nombre'||';'|| 'sexo' ||';'|| 'estado_civil' ||';'|| 'email' ||';'|| 'estado' ||';'|| 'municipio/delegacion' ||';'
            || ' " >' ||TRIM(cruta)|| cnomarchivo;
    SYSTEM csql;


    -- Genera el ARCHIVO con los telefonos de los clientes. Asigna nombre de archivo, segun parametro y la fecha correspondiente
    LET cnomarchivo_tel1 =  trim(cnombreTelef)|| 'Aux'|| substr(year(pdFechaHoy),3) || to_char(pdFechaHoy,'%m%d') || '.txt';
    LET cnomarchivo_tel  =  trim(cnombreTelef)|| substr(year(pdFechaHoy),3) || to_char(pdFechaHoy,'%m%d') || '.txt';
    LET cSql='';
    LET cSql = 'echo "Num_Credito'||';'||'num_cliente'||';'||'tipo_telefono'||';'||'tipo_red'||';'||'telefono_original'||';'
            ||'telefono_reconstruido'||';'  ||'carrier'||';'|| 'extension' ||';' || ' " >' ||TRIM(cruta)|| cnomarchivo_tel;
    SYSTEM csql;

	
    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; ';
                                                            -- Se obtienen los registros de los clientes y sus telefonos 
    LET cSQL2 = " SELECT '" || pempresa || "' as empresa, '" || cCod_Promocion || "' as Cod_prom, '" || sNum_logica::CHAR || "' as logica, " 
            || " a.fecha_gen_campania, a.num_credito, a.sucursal, a.numcte, a.num_tarjeta, a.statusprom, a.prioridad, a.ap_paterno, a.ap_materno, "
            || " a.primer_nombre, a.segundo_nombre, a.sexo, a.estado_civil, a.email, a.estado, a.ciudad, a.fecha_apertura, '0' as stat "
            || " FROM bdicred:sd_camp_primer_uso a JOIN bdicred:sd_indicador_cred ind on ( a.empresa = ind.empresa and a.num_credito = ind.num_credito) "
																										
            || " JOIN bdicred:sd_maecred cred ON ( a.empresa = cred.empresa and a.num_credito = cred.num_credito and cred.status_cred IN ('AA','E1')) " 
            || " WHERE a.empresa = '" || pempresa || "'"
            || " AND a.fecha_gen_campania = '" || dfecha_gen_camp ||"' AND a.fecha_entreg_desde  = '"||dfecha_ent_desde
            || "' AND a.fecha_entreg_hasta = '" || dfecha_ent_hasta ||"'"
            || " AND a.num_campania = " || (sNumCampania - 1) 
            || " AND a.status_tarj = 'INACT' "
            || " AND ( ind.f_primer_compra IS NULL OR ind.f_primer_compra = date(1) ) "
            || " AND ( ind.f_primer_disp IS NULL OR ind.f_primer_disp = date(1) ) "
            || " INTO temp temp_clientes_1eruso with no log; "
            || " CREATE INDEX ix_ctes_1eruso on temp_clientes_1eruso (empresa, numcte); "
            || " UPDATE STATISTICS medium FOR TABLE temp_clientes_1eruso;       "       -- Marca los clientes que no tienen telefono..
            || " SELECT prim.num_credito as num_credito, prim.numcte as numcte, tel.tipo_tel::CHAR as tipo_tel, "
            || " decode(tel.tipo_tel,1,'F',3,'F','M') as tipo_red, substr(tel.telefono,length(tel.telefono)-9,10) as telefono_original, "
            || " substr(tel.telefono,length(tel.telefono)-9,10) as telefono_Reconstruido, NVL(tel.carrier,'') as carrier, NVL(tel.extension, '') as extension "
            || " FROM temp_clientes_1eruso prim JOIN bdinteg:si_telefonos_actual tel ON (prim.empresa = tel.empresa AND prim.numcte = tel.numcte ) "
            || " WHERE tel.status_tel = 'A' AND tel.cofetel = 'V' AND trim(tel.telefono) <> '' "
            || " INTO temp temp_telefonos with no log;      " 
            || " UPDATE temp_clientes_1eruso SET stat = '1' WHERE numcte NOT IN (Select numcte from temp_telefonos group by numcte );       "
            || " UNLOAD TO " || TRIM(cruta) || TRIM(cnomarchivo1) || " DELIMITER '" || cdelimitador || "' "
            || " SELECT Cod_prom, logica, fecha_gen_campania, num_credito, sucursal, numcte, num_tarjeta, "
            || " statusprom, prioridad, ap_paterno, ap_materno, primer_nombre, segundo_nombre, sexo, estado_civil, email, estado, ciudad "
            || " FROM temp_clientes_1eruso "
            || " WHERE stat = '0' "
            || " ORDER BY prioridad, fecha_apertura ASC; "
            || " UNLOAD TO " || TRIM(cruta) || TRIM(cnomarchivo_tel1) || " DELIMITER '" || cdelimitador || "' "
            || " SELECT * from temp_telefonos ORDER BY num_credito; ";


    LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoejecsql;
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    SYSTEM cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoejecsql;
    SYSTEM cSQL;

    LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoejecsql;
    SYSTEM cSQL;

    LET cSql = "";
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;

    LET cSql = "";
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo_tel1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo_tel);
    SYSTEM cSql;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || '  ' || TRIM(cruta) || cnomarchivo1 || '  ' || TRIM(cRuta) || TRIM(cnomarchivo_tel1);
    SYSTEM cSQL;

    --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, 'PROCESO INICIALIZADO ' || pServicio, '02') Returning cCod_RetIB;

	RETURN cCod_ret;

END;
END PROCEDURE;