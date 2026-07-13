create procedure "informix".sp_genera_inf_rep_recuperado_mail()
returning VARCHAR(06),
          VARCHAR(80);
-----------------------------------------------------------------------
--  execute procedure "informix".sp_genera_inf_rep_recuperado_mail();

DEFINE pfechahoy          DATE;
DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE cProceso           CHAR(4);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE P_MENSAJE          VARCHAR(80);
DEFINE cCiudad            CHAR(10);
DEFINE cEstado            CHAR(08);
DEFINE cNombre1			  CHAR(26);
DEFINE cNombre2			  CHAR(26);
DEFINE cApellidoP		  CHAR(26);
DEFINE cApellidoM		  CHAR(26);
DEFINE vsaldo_total         DECIMAL(18,2);
DEFINE dPagoMinimoTotal   DECIMAL(18,2);
DEFINE dSdoVencIntMora  DECIMAL(18,2);
DEFINE dPagosVencidos      SMALLINT;
DEFINE	vMensualidad		DECIMAL(18,2);
DEFINE vpago_vencido		DECIMAL(18,2);
DEFINE dFechaCarLinea       DATE;
DEFINE dCosto               DECIMAL(9,2);
DEFINE dFechaConsulta       DATE;
DEFINE dPago                DECIMAL(18,2);
DEFINE sPago                SMALLINT;
DEFINE sNumPago             SMALLINT;
DEFINE sNumCampana          SMALLINT;
DEFINE cNumCredito          CHAR(20);
DEFINE cNumcte              CHAR(20);
DEFINE cNumProducto         CHAR(04);
DEFINE dFechaEnvio          DATE;
DEFINE dPagoDia1            DECIMAL(18,2);
DEFINE dPagoDia2            DECIMAL(18,2);
DEFINE dPagoDia3            DECIMAL(18,2);
DEFINE dPagoDia4            DECIMAL(18,2);
DEFINE dPagoDia5            DECIMAL(18,2);
DEFINE dPagoDiaN           DECIMAL(18,2);
DEFINE cEstatusResultado    CHAR(02);
DEFINE dFechaCambioEstatus  DATE;
DEFINE sResultadoMora       SMALLINT;
DEFINE dFechaApertura       DATE;
DEFINE dFechaPrimerConsumo  DATE;
DEFINE dLineaCredito        DECIMAL(18,2);
DEFINE cTipoTransaccion     CHAR(30);
DEFINE dMontoTransaccion    DECIMAL(18,2);
DEFINE dPorcentajeUso       DECIMAL(18,2);
DEFINE dFechaInicio         DATE;
DEFINE dFechaFin            DATE;
DEFINE sFinMes              SMALLINT;
DEFINE cResultadoEntrega    CHAR(15);
DEFINE cIdMensaje           CHAR(10);
DEFINE sEnviado             SMALLINT;
DEFINE dFPprimerCompra      DATE; 
DEFINE dFPrimerDisp         DATE;
DEFINE dMontoPrimerCompra   DECIMAL(18,2);
DEFINE dMontoPrimerDisp     DECIMAL(18,2);
DEFINE cEmpresa             CHAR(03);
DEFINE cTipoCobranza        CHAR(01);

BEGIN 
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET = SQL_ERR;
     LET P_MENSAJE = ERROR_INFO;
     CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, P_COD_RET, P_MENSAJE, '02')
     RETURNING P_COD_RET;
     LET P_COD_RET = SQL_ERR;

     RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

--SET DEBUG FILE TO "sp_genera_inf_rep_recuperado_mail.out";
--TRACE ON;

LET cEmpresa            = '001';
LET cProceso            = '0118';
LET P_COD_RET           = '000000';
LET P_MENSAJE           = 'El proceso de REPORTE RECUPERADO CAMPAÑAS MAILs se realizó correctamente.';
LET cCiudad            = '';
LET cEstado            = '';
LET cNombre1		   = '';
LET cNombre2           = '';
LET cApellidoP         = '';
LET cApellidoM		   = '';
LET vsaldo_total       = 0;
LET dPagoMinimoTotal   = 0;
LET dSdoVencIntMora    = 0;
LET dPagosVencidos     = 0;
LET vMensualidad		= 0;
LET vpago_vencido		= 0;
LET dFechaCarLinea      = DATE(01);
LET dCosto              = 0;
LET dFechaConsulta      = DATE(1);
LET dPago               = 0;
LET sPago               = 0;
LET sNumPago            = 0;
LET sNumCampana         = 0;
LET cNumCredito         = '';
LET cNumcte             = '';
LET cNumProducto        = '';
LET dFechaEnvio          = DATE(1);
LET dPagoDia1            = 0;
LET dPagoDia2            = 0;
LET dPagoDia3            = 0;
LET dPagoDia4            = 0;
LET dPagoDia5            = 0;
LET dPagoDiaN           = 0;
LET cEstatusResultado    = '';
LET dFechaCambioEstatus  = DATE(1);
LET sResultadoMora       = 0;
LET dFechaApertura       = DATE(1);
LET dFechaPrimerConsumo  = DATE(1);
LET dLineaCredito        = 0;
LET cTipoTransaccion     = '';
LET dMontoTransaccion    = 0;
LET dPorcentajeUso       = 0;
LET dFechaInicio         = DATE(1);
LET dFechaFin            = DATE(1);
LET sFinMes              = 0;
LET cResultadoEntrega    = '';
LET cIdMensaje           = '';
LET sEnviado             = 0;
LET dFPprimerCompra      = DATE(1); 
LET dFPrimerDisp         = DATE(1);
LET dMontoPrimerCompra   = 0;
LET dMontoPrimerDisp     = 0;
LET cTipoCobranza        = '';

CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, P_COD_RET, P_MENSAJE, '01')
    RETURNING P_COD_RET;

IF P_COD_RET != '000000' THEN
   LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
   RETURN P_COD_RET,P_MENSAJE;
END IF;


--dFechaInicio  día 1 de cada mes
IF DAY(TODAY) = 1 THEN
    LET dFechaInicio = TODAY - 1;
    LET dFechaInicio = MDY(MONTH(dFechaInicio),1,YEAR(dFechaInicio)) - 1 UNITS DAY;
    LET dFechaFin    = TODAY - 1;
ELSE
    LET dFechaInicio = MDY(MONTH(TODAY),1,YEAR(TODAY));
    LET dFechaFin = TODAY - 1;
END IF;

--TEMPORAL solo para pruebas
--LET dFechaInicio = MDY(MONTH(mdy('03','08','2016')),1,YEAR(mdy('03','08','2016')));
--LET dFechaFin = (mdy('03','08','2016') - 1) + 5;
--TEMPORAL solo para pruebas

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT num_credito,fecha_mov,monto
  FROM bdicred:sd_movhis
 WHERE empresa= cEmpresa
   AND fecha_mov >= dFechaInicio
   AND fecha_mov <= dFechaFin
   AND codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)	
   AND codigo_ref = 1 	
   AND reversado = 'N'
INTO TEMP movimientos WITH NO LOG;

CREATE INDEX inx_mov_tmp ON movimientos(fecha_mov,num_credito);
UPDATE STATISTICS HIGH FOR TABLE movimientos;

SELECT num_credito,fecha_mov,monto
  FROM bdicred:sd_movhiscrd
 WHERE empresa= cEmpresa
   AND fecha_mov >= dFechaInicio
   AND fecha_mov <= dFechaFin
   AND codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanualcrd)	
   AND codigo_ref = 1 	
   AND reversado = 'N'
INTO TEMP movimientos_plazo WITH NO LOG;

CREATE INDEX inx_mov_pzotmp ON movimientos_plazo(fecha_mov,num_credito);
UPDATE STATISTICS HIGH FOR TABLE movimientos_plazo;

--Se obtienen los pagos de todos los días del mes
FOREACH WITH HOLD
    SELECT num_campana,num_credito,numcte,num_producto,fecha_envio,resultado_entrega,pago_dia1,pago_dia2,pago_dia3,pago_dia4,pago_dia5,pago_ndias,
           estatus_resultado,fecha_cambio_estatus,resultado_mora,fecha_apertura,fecha_primer_consumo,linea_credito,tipo_transaccion,monto_transaccion,porcentaje_uso
      INTO sNumCampana,cNumCredito,cNumcte,cNumProducto,dFechaEnvio,cResultadoEntrega,dPagoDia1,dPagoDia2,dPagoDia3,dPagoDia4,dPagoDia5,dPagoDiaN,
           cEstatusResultado,dFechaCambioEstatus,sResultadoMora,dFechaApertura,dFechaPrimerConsumo,dLineaCredito,cTipoTransaccion,dMontoTransaccion,dPorcentajeUso
      FROM bdicobranza:cb_rep_resultado_mail_hist
     WHERE fecha_envio >= dFechaInicio
       AND fecha_envio <= dFechaFin

     SELECT id_mensaje,tipo_cobranza INTO cIdMensaje,cTipoCobranza
       FROM bdicobranza:cb_cat_campania
      WHERE empresa=cEmpresa
        AND num_campania = sNumCampana;
--Envíos MAILs
     IF sNumCampana IN (1000,1001,1002,1003,1004,1005,1006,1007,1008,1009,1010,1011,1012,1013,1014,1015,1016,1017,1018,1019) THEN
        IF cResultadoEntrega IS NULL OR cResultadoEntrega = '' THEN LET cResultadoEntrega = ''; END IF;
        BEGIN WORK;
        IF cResultadoEntrega = '' THEN
            SELECT SUM(estatus) INTO sEnviado 
            FROM bdimnsj:mnsjr_trx_batch
            WHERE cuenta = cNumCredito
            AND id_mensaje = cIdMensaje
            AND date(fecha_hora_registro) >= dFechaEnvio
            AND date(fecha_hora_registro) <= dFechaFin;

            IF sEnviado IS NULL OR sEnviado = '' THEN LET sEnviado = -1; END IF;

            IF sEnviado = -1 THEN
                SELECT SUM(estatus) INTO sEnviado 
                FROM bdimnsj:mnsjr_trx_batch_his
                WHERE cuenta = cNumCredito
                AND id_mensaje = cIdMensaje
                AND date(fecha_hora_registro) >= dFechaEnvio
                AND date(fecha_hora_registro) <= dFechaFin;

                IF sEnviado IS NULL OR sEnviado = '' THEN LET sEnviado = 0; END IF;
            END IF;

            IF sEnviado > 0 THEN
                UPDATE bdicobranza:cb_rep_resultado_mail_hist
                   SET resultado_entrega = 'COMPLETADO'
                 WHERE empresa = cEmpresa
                   AND num_campana = sNumCampana
                   AND num_credito = cNumCredito
                   AND fecha_envio = dFechaEnvio;
            ELSE
                UPDATE bdicobranza:cb_rep_resultado_mail_hist
                   SET resultado_entrega = 'NO COMPLETADO'
                 WHERE empresa = cEmpresa
                   AND num_campana = sNumCampana
                   AND num_credito = cNumCredito
                   AND fecha_envio = dFechaEnvio;
            END IF;
         END IF;
--Envíos MAILs Primer Consumo
         IF dFechaApertura IS NULL OR dFechaApertura = '' THEN LET dFechaApertura = DATE(1); END IF;
         IF dLineaCredito IS NULL OR dLineaCredito = '' THEN LET dLineaCredito = -1; END IF;

         IF sNumCampana = 1009 AND (dFechaApertura = DATE(1) OR dLineaCredito = -1) THEN
            IF cTipoCobranza IN ('A','P') THEN
                SELECT mae.fecha_apertura, mas.monto_otorgado, ind.f_primer_compra, ind.f_primer_disp, ind.monto_primer_compra, ind.monto_primer_disp
                  INTO dFechaApertura   , dLineaCredito     , dFPprimerCompra, dFPrimerDisp, dMontoPrimerCompra, dMontoPrimerDisp
                  FROM bdicred:sd_maecred mae
                INNER JOIN bdicred:sd_maesdos mas ON mas.empresa = mae.empresa AND mas.num_credito = mae.num_credito
                INNER JOIN bdicred:sd_indicador_cred ind ON ind.empresa = mae.empresa AND ind.num_credito = mae.num_credito
                 WHERE mae.empresa = '001'
                   AND mae.num_credito = cNumCredito;
            ELSE
                SELECT mae.fecha_apertura, mas.monto_otorgado, ind.f_primer_compra, ind.f_primer_disp, ind.monto_primer_compra, ind.monto_primer_disp
                  INTO dFechaApertura   , dLineaCredito     , dFPprimerCompra, dFPrimerDisp, dMontoPrimerCompra, dMontoPrimerDisp
                  FROM bdicred:sd_maecredcrd mae
                INNER JOIN bdicred:sd_maesdoscrd mas ON mas.empresa = mae.empresa AND mas.num_credito = mae.num_credito
                INNER JOIN bdicred:sd_indicador_cred_crd ind ON ind.empresa = mae.empresa AND ind.num_credito = mae.num_credito
                 WHERE mae.empresa = '001'
                   AND mae.num_credito = cNumCredito;
            END IF;

            IF dFPprimerCompra IS NULL THEN LET dFPprimerCompra = DATE(1); END IF;
            IF dFPrimerDisp IS NULL THEN LET dFPrimerDisp = DATE(1); END IF;

            IF dFPprimerCompra != DATE(1) THEN
               LET dFPprimerCompra = dFPprimerCompra;
               LET dMontoPrimerCompra = dMontoPrimerCompra;
               LET cTipoTransaccion   = 'COMPRA';
            ELIF dFPrimerDisp != DATE(1) THEN
               LET dFPprimerCompra = dFPrimerDisp;
               LET dMontoPrimerCompra = dMontoPrimerDisp;
               LET cTipoTransaccion   = 'DISPOSICION';
            END IF;

            UPDATE bdicobranza:cb_rep_resultado_mail_hist
               SET fecha_apertura = dFechaApertura,
                   linea_credito = dLineaCredito,
                   fecha_primer_consumo = dFPprimerCompra,
                   monto_transaccion = dMontoPrimerCompra,
                   tipo_transaccion = cTipoTransaccion,
                   porcentaje_uso = (dMontoPrimerCompra / (CASE WHEN dLineaCredito = 0 THEN 0.01 ELSE dLineaCredito END)) * 100
             WHERE empresa = cEmpresa
               AND num_campana = sNumCampana
               AND num_credito = cNumCredito
               AND fecha_envio = dFechaEnvio;

               LET cTipoTransaccion     = '';
         END IF;
         COMMIT WORK;
     END IF;

     LET dFechaConsulta = dFechaEnvio;

     IF dPagoDia1 IS NULL OR dPagoDia1 = '' THEN
        LET dFechaConsulta = dFechaEnvio;
        LET sPago = 1;
     ELIF dPagoDia2 IS NULL OR dPagoDia2 = '' THEN
        LET dFechaConsulta = dFechaEnvio + 1 UNITS DAY;
        LET sPago = 2;
     ELIF dPagoDia3 IS NULL OR dPagoDia3 = '' THEN
        LET dFechaConsulta = dFechaEnvio + 2 UNITS DAY;
        LET sPago = 3;
     ELIF dPagoDia4 IS NULL OR dPagoDia4 = '' THEN
        LET dFechaConsulta = dFechaEnvio + 3 UNITS DAY;
        LET sPago = 4;
     ELIF dPagoDia5 IS NULL OR dPagoDia5 = '' THEN
        LET dFechaConsulta = dFechaEnvio + 4 UNITS DAY;
        LET sPago = 5;
     ELSE
        LET dFechaConsulta = DATE(1);
        CONTINUE FOREACH;
     END IF;

     LET sNumPago = (dFechaFin - dFechaEnvio) + 1;

     BEGIN WORK;
     WHILE sPago <= sNumPago
        IF cTipoCobranza IN ('A','P') THEN
           SELECT SUM(monto) INTO dPago
             FROM movimientos
            WHERE fecha_mov   = dFechaConsulta
              AND num_credito = cNumCredito;
        ELSE
           SELECT SUM(monto) INTO dPago
             FROM movimientos_plazo
            WHERE fecha_mov   = dFechaConsulta
              AND num_credito = cNumCredito;
        END IF;

         IF dPago IS NULL OR dPago = '' THEN LET dPago = 0; END IF;

         IF sPago = 1 THEN
            UPDATE bdicobranza:cb_rep_resultado_mail_hist
               SET pago_dia1 = dPago
             WHERE empresa = cEmpresa
               AND num_campana = sNumCampana
               AND num_credito = cNumCredito
               AND fecha_envio = dFechaEnvio;
         ELIF sPago = 2 THEN
            UPDATE bdicobranza:cb_rep_resultado_mail_hist
               SET pago_dia2 = dPago
             WHERE empresa = cEmpresa
               AND num_campana = sNumCampana
               AND num_credito = cNumCredito
               AND fecha_envio = dFechaEnvio;
         ELIF sPago = 3 THEN
            UPDATE bdicobranza:cb_rep_resultado_mail_hist
               SET pago_dia3 = dPago
             WHERE empresa = cEmpresa
               AND num_campana = sNumCampana
               AND num_credito = cNumCredito
               AND fecha_envio = dFechaEnvio;
         ELIF sPago = 4 THEN
            UPDATE bdicobranza:cb_rep_resultado_mail_hist
               SET pago_dia4 = dPago
             WHERE empresa = cEmpresa
               AND num_campana = sNumCampana
               AND num_credito = cNumCredito
               AND fecha_envio = dFechaEnvio;
         ELIF sPago = 5 THEN
            UPDATE bdicobranza:cb_rep_resultado_mail_hist
               SET pago_dia5 = dPago
             WHERE empresa = cEmpresa
               AND num_campana = sNumCampana
               AND num_credito = cNumCredito
               AND fecha_envio = dFechaEnvio;
         END IF;
         LET sPago = sPago + 1;
         LET dFechaConsulta = dFechaConsulta + 1 UNITS DAY;
     END WHILE;
     LET sPago = 0;
     COMMIT WORK;
END FOREACH;

DROP TABLE movimientos;
DROP TABLE movimientos_plazo;

--SET DEBUG FILE TO "sp_genera_inf_rep_recuperado_mail.out";
--TRACE ON;

LET dFechaInicio = dFechaInicio;
LET dFechaFin = dFechaFin;

LET sPago = 0;

--Se obtienen los pagos de los últimos días del mes
IF DAY(dFechaFin) = 5 AND MONTH(dFechaFin) in (1,2,4,6,8,9,11) THEN
    LET dFechaInicio = dFechaInicio - 1 UNITS MONTH;
    LET dFechaInicio = MDY(MONTH(dFechaInicio),27,YEAR(dFechaInicio));
    LET sFinMes = 1;
ELIF DAY(dFechaFin) = 5 AND MONTH(dFechaFin) in (5,7,10,12) THEN
    LET dFechaInicio = dFechaInicio - 1 UNITS MONTH;
    LET dFechaInicio = MDY(MONTH(dFechaInicio),26,YEAR(dFechaInicio));
    LET sFinMes = 1;
--Se obtienen los pagos de los últimos días del mes de Febrero únicamente
ELIF DAY(dFechaFin) = 5 AND MONTH(dFechaFin) = 3 AND YEAR(dFechaFin) IN (2016,2020,2024,2028,2032) THEN
    LET dFechaInicio = dFechaInicio - 1 UNITS MONTH;
    LET dFechaInicio = MDY(MONTH(dFechaInicio),25,YEAR(dFechaInicio));
    LET sFinMes = 1;
ELIF DAY(dFechaFin) = 5 AND MONTH(dFechaFin) = 3 AND YEAR(dFechaFin) NOT IN (2016,2020,2024,2028,2032) THEN
    LET dFechaInicio = dFechaInicio - 1 UNITS MONTH;
    LET dFechaInicio = MDY(MONTH(dFechaInicio),24,YEAR(dFechaInicio));
    LET sFinMes = 1;
END IF;

LET dFechaFin = (MDY(MONTH(dFechaInicio),1,YEAR(dFechaInicio)) + 1 UNITS MONTH) - 1  UNITS DAY;

IF sFinMes = 1 THEN
    SELECT num_credito,fecha_mov,monto
      FROM bdicred:sd_movhis
     WHERE empresa= cEmpresa
       AND fecha_mov >= MDY(MONTH(dFechaInicio),1,YEAR(dFechaInicio))
       AND fecha_mov <= today
       AND codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)	
       AND codigo_ref = 1 	
       AND reversado = 'N'
    INTO TEMP movimientos_findemes WITH NO LOG;

    CREATE INDEX inx_mov_findemestmp ON movimientos_findemes(fecha_mov,num_credito);
    UPDATE STATISTICS HIGH FOR TABLE movimientos_findemes;

    SELECT num_credito,fecha_mov,monto
      FROM bdicred:sd_movhiscrd
     WHERE empresa= cEmpresa
       AND fecha_mov >= MDY(MONTH(dFechaInicio),1,YEAR(dFechaInicio))
       AND fecha_mov <= today
       AND codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanualcrd)	
       AND codigo_ref = 1 	
       AND reversado = 'N'
    INTO TEMP movimientos_findemes_plazo WITH NO LOG;

    CREATE INDEX inx_mov_findemespzotmp ON movimientos_findemes_plazo(fecha_mov,num_credito);
    UPDATE STATISTICS HIGH FOR TABLE movimientos_findemes_plazo;

--Sumariza los pagos de los días N para las campañas generadas antes del 25 o 27 de cada mes
    FOREACH WITH HOLD
        SELECT num_campana,num_credito,fecha_envio,pago_ndias
          INTO sNumCampana,cNumCredito,dFechaEnvio,dPagoDiaN
          FROM bdicobranza:cb_rep_resultado_mail_hist
         WHERE fecha_envio >= MDY(MONTH(dFechaInicio),1,YEAR(dFechaInicio))
           AND fecha_envio <= dFechaInicio - 1 UNITS day

         SELECT id_mensaje,tipo_cobranza INTO cIdMensaje,cTipoCobranza
           FROM bdicobranza:cb_cat_campania
          WHERE empresa=cEmpresa
            AND num_campania = sNumCampana;

        IF cTipoCobranza IN ('A','P') THEN
            SELECT SUM(monto) INTO dPagoDiaN
              FROM movimientos_findemes
             WHERE fecha_mov  >= dFechaEnvio + 5 UNITS DAY
               AND fecha_mov  <= dFechaFin
               AND num_credito = cNumCredito;
        ELSE
            SELECT SUM(monto) INTO dPagoDiaN
              FROM movimientos_findemes_plazo
             WHERE fecha_mov  >= dFechaEnvio + 5 UNITS DAY
               AND fecha_mov  <= dFechaFin
               AND num_credito = cNumCredito;
        END IF;

        IF dPagoDiaN IS NULL OR dPagoDiaN = '' THEN LET dPagoDiaN = 0; END IF;

        BEGIN WORK;
        UPDATE bdicobranza:cb_rep_resultado_mail_hist
           SET pago_ndias = dPagoDiaN
         WHERE empresa    = cEmpresa
           AND num_campana = sNumCampana
           AND num_credito = cNumCredito
           AND fecha_envio = dFechaEnvio;
        COMMIT WORK;
    END FOREACH
--Registra los pagos de los días 25 o 27 de cada mes en adelante hasta 5 días después
    FOREACH WITH HOLD
        SELECT num_campana,num_credito,fecha_envio,pago_dia1,pago_dia2,pago_dia3,pago_dia4,pago_dia5,pago_ndias
          INTO sNumCampana,cNumCredito,dFechaEnvio,dPagoDia1,dPagoDia2,dPagoDia3,dPagoDia4,dPagoDia5,dPagoDiaN
          FROM bdicobranza:cb_rep_resultado_mail_hist
         WHERE fecha_envio >= dFechaInicio
           AND fecha_envio <= dFechaFin

         LET dFechaConsulta = dFechaEnvio;
         LET sNumPago = 5;

         IF dPagoDia1 IS NULL OR dPagoDia1 = '' THEN
            LET dFechaConsulta = dFechaEnvio;
            LET sPago = 1;
         ELIF dPagoDia2 IS NULL OR dPagoDia2 = '' THEN
            LET dFechaConsulta = dFechaEnvio + 1 UNITS DAY;
            LET sPago = 2;
         ELIF dPagoDia3 IS NULL OR dPagoDia3 = '' THEN
            LET dFechaConsulta = dFechaEnvio + 2 UNITS DAY;
            LET sPago = 3;
         ELIF dPagoDia4 IS NULL OR dPagoDia4 = '' THEN
            LET dFechaConsulta = dFechaEnvio + 3 UNITS DAY;
            LET sPago = 4;
         ELIF dPagoDia5 IS NULL OR dPagoDia5 = '' THEN
            LET dFechaConsulta = dFechaEnvio + 4 UNITS DAY;
            LET sPago = 5;
         ELSE
            LET dFechaConsulta = DATE(1);
            CONTINUE FOREACH;
         END IF;

         SELECT id_mensaje,tipo_cobranza INTO cIdMensaje,cTipoCobranza
           FROM bdicobranza:cb_cat_campania
          WHERE empresa=cEmpresa
            AND num_campania = sNumCampana;

         BEGIN WORK;
         WHILE sPago <= sNumPago
            IF cTipoCobranza IN ('A','P') THEN
                SELECT SUM(monto) INTO dPago
                  FROM movimientos_findemes
                 WHERE fecha_mov   = dFechaConsulta
                   AND num_credito = cNumCredito;
            ELSE
                SELECT SUM(monto) INTO dPago
                  FROM movimientos_findemes_plazo
                 WHERE fecha_mov   = dFechaConsulta
                   AND num_credito = cNumCredito;
            END IF;

             IF dPago IS NULL OR dPago = '' THEN LET dPago = 0; END IF;

             IF sPago = 1 THEN
                UPDATE bdicobranza:cb_rep_resultado_mail_hist
                   SET pago_dia1 = dPago
                 WHERE empresa = cEmpresa
                   AND num_campana = sNumCampana
                   AND num_credito = cNumCredito
                   AND fecha_envio = dFechaEnvio;
             ELIF sPago = 2 THEN
                UPDATE bdicobranza:cb_rep_resultado_mail_hist
                   SET pago_dia2 = dPago
                 WHERE empresa = cEmpresa
                   AND num_campana = sNumCampana
                   AND num_credito = cNumCredito
                   AND fecha_envio = dFechaEnvio;
             ELIF sPago = 3 THEN
                UPDATE bdicobranza:cb_rep_resultado_mail_hist
                   SET pago_dia3 = dPago
                 WHERE empresa = cEmpresa
                   AND num_campana = sNumCampana
                   AND num_credito = cNumCredito
                   AND fecha_envio = dFechaEnvio;
             ELIF sPago = 4 THEN
                UPDATE bdicobranza:cb_rep_resultado_mail_hist
                   SET pago_dia4 = dPago
                 WHERE empresa = cEmpresa
                   AND num_campana = sNumCampana
                   AND num_credito = cNumCredito
                   AND fecha_envio = dFechaEnvio;
             ELIF sPago = 5 THEN
                UPDATE bdicobranza:cb_rep_resultado_mail_hist
                   SET pago_dia5 = dPago
                 WHERE empresa = cEmpresa
                   AND num_campana = sNumCampana
                   AND num_credito = cNumCredito
                   AND fecha_envio = dFechaEnvio;
             END IF;
             LET sPago = sPago + 1;
             LET dFechaConsulta = dFechaConsulta + 1 UNITS DAY;
         END WHILE;

         IF sPago > 0 THEN
             UPDATE bdicobranza:cb_rep_resultado_mail_hist
               SET pago_ndias = 0
             WHERE empresa    = cEmpresa
               AND num_campana = sNumCampana
               AND num_credito = cNumCredito
               AND fecha_envio = dFechaEnvio;
         END IF;
         LET sPago = 0;
         COMMIT WORK;
    END FOREACH;
    DROP TABLE movimientos_findemes;
    DROP TABLE movimientos_findemes_plazo;
END IF;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, P_COD_RET, P_MENSAJE, '03')
    RETURNING P_COD_RET;

    IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;

END
RETURN P_COD_RET,P_MENSAJE;
END PROCEDURE;