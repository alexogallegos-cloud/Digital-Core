CREATE PROCEDURE "informix".sp_calculaindicadores(vnum_credito CHAR(20))
       RETURNING char(6), char(80);

--declaracion de variables
------------------------------------------------------------
DEFINE sql_err          INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info       CHAR(80);
DEFINE cMensaje         CHAR(80);
DEFINE cCod_ret         CHAR(6);
DEFINE vempresa         CHAR(3);
DEFINE v_num_credito    CHAR(20);
DEFINE v110             DECIMAL(18,2);
DEFINE v120             DECIMAL(18,2);
DEFINE v240             DECIMAL(18,2);
DEFINE v140             DECIMAL(18,2);
DEFINE v150             DECIMAL(18,2);
DEFINE v160             DECIMAL(18,2);
DEFINE v170             DECIMAL(18,2);
DEFINE v180             DECIMAL(18,2);
DEFINE v220             DECIMAL(18,2);
DEFINE vene             MONEY;
DEFINE vfeb             MONEY;
DEFINE vmar             MONEY;
DEFINE vabr             MONEY;
DEFINE vmay             MONEY;
DEFINE vjun             MONEY;
DEFINE vjul             MONEY;
DEFINE vago             MONEY;
DEFINE vsep             MONEY;
DEFINE voct             MONEY;
DEFINE vnov             MONEY;
DEFINE vdic             MONEY;
DEFINE vmontoa          MONEY;
DEFINE vfecha           DATE;
DEFINE vstatus_cred     CHAR(2);
DEFINE v230             DECIMAL(18,2);
DEFINE iMesAux          INTEGER;
DEFINE iAnioAux         INTEGER;
DEFINE iRetraso         INTEGER;
DEFINE iMesesAtraso     INTEGER;
DEFINE dSaldoActual     DECIMAL(18,2);
DEFINE iCreditoUsado    DECIMAL(18,2);
DEFINE vcompras         DECIMAL(18,2);
DEFINE vdisposiciones   DECIMAL(18,2);
DEFINE vfecha_creada    DATE;
DEFINE dPagoMinimo      DECIMAL(18,2);
DEFINE vtotalero        SMALLINT;
DEFINE varfecha         DATE;
DEFINE varnum_credito   CHAR(20);
DEFINE varmeses_venc    SMALLINT;

--SET DEBUG FILE TO 'sp_consulta_indicador_pba.out';
--TRACE ON;

      LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
      LET vempresa      = '001';
      LET v_num_credito = '';
      LET v110          = 0;
      LET v120          = 0;
      LET v240          = 0;
      LET v140          = 0;
      LET v150          = 0;
      LET v160          = 0;
      LET v170          = 0;
      LET v180          = 0;
      LET v220          = 0;
      LET vene          = 0;
      LET vfeb          = 0;
      LET vmar          = 0;
      LET vabr          = 0;
      LET vmay          = 0;
      LET vjun          = 0;
      LET vjul          = 0;
      LET vago          = 0;
      LET vsep          = 0;
      LET voct          = 0;
      LEt vnov          = 0;
      LEt vdic          = 0;
      LET vmontoa       = 0;
      LET v230          = 0;
      LET dSaldoActual  = 0;
      LET vstatus_cred   = '';
      LET iCreditoUsado  = 0;
      LET vcompras       = 0;
      LET vdisposiciones = 0;
      LET vfecha_creada  = DATE(1);
      LET dPagoMinimo    = 0;
      LET vtotalero      = 0;
      LET varfecha       = DATE(1);
      LET varmeses_venc  = 0;
      LET varnum_credito = '';
          
	BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;
            DROP TABLE "informix".tmp_cred;
            DROP TABLE "informix".tmp_sdohist;
    		RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

        SET ISOLATION TO dirty READ;
        SELECT {+INDEX(bdicred:sd_maesdoshist maesdishist2)
            ,(bdicred@pld_tcp:sd_encabezado2_edocta idx_encabezado2_edocta1),(bdicred@pld_tcp:sd_pie_edocta idx_pie_edocta)} b.fecha, a.num_credito, nvl(sdo_debe,0) + nvl(interes_pago_total_tc,0) saldo_al_corte
            ,d.saldo_promedio ,c.menos_abonos pagos ,c.mas_compras compras ,c.mas_disp_efectivo disposiciones,
        (SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} count(*) FROM bdicred:sd_movhis mov
            WHERE mov.empresa = a.empresa AND mov.fecha_mov BETWEEN (b.fecha - 1 UNITS month) + 1 UNITS day AND b.fecha 
            AND mov.num_credito = a.num_credito AND mov.codigo_fun ='002' AND mov.codigo_ref IN (37,57,937,938) AND mov.reversado='N') No_Compras,
        (SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} count(*) FROM bdicred:sd_movhis mov
            WHERE mov.empresa = a.empresa AND mov.fecha_mov BETWEEN (b.fecha - 1 UNITS month) + 1 UNITS day AND b.fecha 
            AND mov.num_credito = a.num_credito AND mov.codigo_fun ='002' AND mov.codigo_ref IN (50,30,40,41,42,34,35,36,60,61,62,63,64) 
            AND mov.reversado='N')No_Disposiciones,
        (SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} count(*) FROM bdicred:sd_movhis mov
            WHERE mov.empresa = a.empresa AND mov.fecha_mov BETWEEN (b.fecha - 1 UNITS month) + 1 UNITS day AND b.fecha
            AND mov.num_credito = a.num_credito AND mov.codigo_fun  IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanual) 
            AND mov.codigo_ref=1 AND mov.reversado='N')No_pagos,
            (d.saldo_promedio /decode(b.monto_otorgado,0,1, b.monto_otorgado)  *100 ) Porcentaje_consumo, a.status_cred
            ,b.monto_vencido + b.mto_venc_trasp pago_min, mto_fin_ven_trasp pagos_vencidos,
        (SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} count(*) FROM bdicred:sd_movhis mov
            WHERE mov.empresa = a.empresa AND mov.fecha_mov = b.fecha 
            AND mov.num_credito = a.num_credito AND mov.codigo_fun IN ('604', '605') AND mov.codigo_ref  IN (2,125,127,7002)
            AND mov.reversado='N') + case when (b.monto_vencido+b.mto_venc_trasp) > 0 then 1 else 0 end  totalero
        FROM bdicred:sd_maecred a,
            bdicred:sd_maesdoshist b,
            bdicred:sd_encabezado2_edocta_hist c,
            bdicred:sd_pie_edocta_hist d
        WHERE a.empresa = b.empresa
        AND a.num_credito = b.num_credito
        AND c.fecha_emision = b.fecha
        AND c.num_credito = a.num_credito 
        AND d.fecha_emision =  b.fecha 
        AND d.num_credito = b.num_credito
        AND a.num_credito = vnum_credito
        AND year(b.fecha) >= year(current) - 2
    UNION
        SELECT {+INDEX(bdicred:sd_maesdoshist maesdishist2)
            ,(bdicred@pld_tcp:sd_encabezado2_edocta idx_encabezado2_edocta1),(bdicred@pld_tcp:sd_pie_edocta idx_pie_edocta)} b.fecha, a.num_credito, nvl(sdo_debe,0) + nvl(interes_pago_total_tc,0) saldo_al_corte
            ,d.saldo_promedio ,c.menos_abonos pagos ,c.mas_compras compras ,c.mas_disp_efectivo disposiciones,
        (SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} count(*) FROM bdicred:sd_movhis mov
            WHERE mov.empresa = a.empresa AND mov.fecha_mov BETWEEN (b.fecha - 1 UNITS month) + 1 UNITS day AND b.fecha 
            AND mov.num_credito = a.num_credito AND mov.codigo_fun ='002' AND mov.codigo_ref IN (37,57,937,938) AND mov.reversado='N') No_Compras,
        (SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} count(*) FROM bdicred:sd_movhis mov
            WHERE mov.empresa = a.empresa AND mov.fecha_mov BETWEEN (b.fecha - 1 UNITS month) + 1 UNITS day AND b.fecha 
            AND mov.num_credito = a.num_credito AND mov.codigo_fun ='002' AND mov.codigo_ref IN (50,30,40,41,42,34,35,36,60,61,62,63,64) 
            AND mov.reversado='N')No_Disposiciones,
        (SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} count(*) FROM bdicred:sd_movhis mov
            WHERE mov.empresa = a.empresa AND mov.fecha_mov BETWEEN (b.fecha - 1 UNITS month) + 1 UNITS day AND b.fecha
            AND mov.num_credito = a.num_credito AND mov.codigo_fun  IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanual) 
            AND mov.codigo_ref=1 AND mov.reversado='N')No_pagos,
            (d.saldo_promedio /decode(b.monto_otorgado,0,1, b.monto_otorgado)  *100 ) Porcentaje_consumo, a.status_cred
            ,b.monto_vencido + b.mto_venc_trasp pago_min, mto_fin_ven_trasp pagos_vencidos,
        (SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} count(*) FROM bdicred:sd_movhis mov
            WHERE mov.empresa = a.empresa AND mov.fecha_mov = b.fecha 
            AND mov.num_credito = a.num_credito AND mov.codigo_fun IN ('604', '605') AND mov.codigo_ref  IN (2,125,127,7002)
            AND mov.reversado='N') + case when (b.monto_vencido+b.mto_venc_trasp) > 0 then 1 else 0 end  totalero
        FROM bdicred:sd_maecred a,
            bdicred:sd_maesdoshist b,
            bdicred@pld_tcp:sd_encabezado2_edocta c,
            bdicred@pld_tcp:sd_pie_edocta d
        WHERE a.empresa = b.empresa
        AND a.num_credito = b.num_credito
        AND c.fecha_emision = b.fecha
        AND c.num_credito = a.num_credito 
        AND d.fecha_emision =  b.fecha 
        AND d.num_credito = b.num_credito
        AND a.num_credito = vnum_credito
        AND year(b.fecha) >= year(current) - 2
    UNION
        SELECT {+INDEX(bdicred:sd_maesdoshist maesdishist2)
            ,(bdicred@pld_tcp:sd_encabezado2_edocta idx_encabezado2_edocta1),(bdicred@pld_tcp:sd_pie_edocta idx_pie_edocta)} b.fecha, a.num_credito, nvl(sdo_debe,0) + nvl(interes_pago_total_tc,0) saldo_al_corte
            ,d.saldo_promedio ,c.menos_abonos pagos ,c.mas_compras compras ,c.mas_disp_efectivo disposiciones,
        (SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} count(*) FROM bdicred:sd_movhis mov
            WHERE mov.empresa = a.empresa AND mov.fecha_mov BETWEEN (b.fecha - 1 UNITS month) + 1 UNITS day AND b.fecha 
            AND mov.num_credito = a.num_credito AND mov.codigo_fun ='002' AND mov.codigo_ref IN (37,57,937,938) AND mov.reversado='N') No_Compras,
--------------------------------------------------------------------------------------------------------------------------------------------
        (SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} count(*) FROM bdicred:sd_movhis mov
            WHERE mov.empresa = a.empresa AND mov.fecha_mov BETWEEN (b.fecha - 1 UNITS month) + 1 UNITS day AND b.fecha 
            AND mov.num_credito = a.num_credito AND mov.codigo_fun ='002' AND mov.codigo_ref IN (50,30,40,41,42,34,35,36,60,61,62,63,64) 
            AND mov.reversado='N')No_Disposiciones,
--------------------------------------------------------------------------------------------------------------------------------------------
        (SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} count(*) FROM bdicred:sd_movhis mov
            WHERE mov.empresa = a.empresa AND mov.fecha_mov BETWEEN (b.fecha - 1 UNITS month) + 1 UNITS day AND b.fecha
            AND mov.num_credito = a.num_credito AND mov.codigo_fun  IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanual) 
            AND mov.codigo_ref=1 AND mov.reversado='N')No_pagos,
            (d.saldo_promedio /decode(b.monto_otorgado,0,1, b.monto_otorgado)  *100 ) Porcentaje_consumo, a.status_cred
            ,b.monto_vencido + b.mto_venc_trasp pago_min, mto_fin_ven_trasp pagos_vencidos,
--------------------------------------------------------------------------------------------------------------------------------------------
        (SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} count(*) FROM bdicred:sd_movhis mov
            WHERE mov.empresa = a.empresa AND mov.fecha_mov = b.fecha 
            AND mov.num_credito = a.num_credito AND mov.codigo_fun IN ('604', '605') AND mov.codigo_ref IN (2,125,127,7002)
            AND mov.reversado='N') + case when (b.monto_vencido+b.mto_venc_trasp) > 0 then 1 else 0 end  totalero
--------------------------------------------------------------------------------------------------------------------------------------------
        FROM bdicred:sd_maecred a,
            bdicred:sd_maesdoshist b,
            bdicred:sd_encabezado2_edocta_hist c,
            bdicred:sd_pie_edocta_hist d
        WHERE a.empresa = b.empresa
        AND a.num_credito = b.num_credito
        AND c.fecha_emision = b.fecha
        AND c.num_credito = a.num_credito 
        AND d.fecha_emision =  b.fecha 
        AND d.num_credito = b.num_credito
        AND a.num_credito = vnum_credito
        AND year(b.fecha) >= year(current) - 2
        INTO TEMP tmp_cred WITH NO LOG;

--/*      
      SELECT * --num_credito,fecha, nvl(monto_vencido,0) monto_vencido ,nvl(mto_venc_trasp,0) mto_venc_trasp,empresa
       FROM bdicred:sd_maesdoshist  
       WHERE empresa=vempresa
         AND num_credito= vnum_credito
         into temp tmp_sdohist WITH NO LOG; 
  --*/             
        FOREACH
            SELECT fecha, num_credito
            INTO varfecha, varnum_credito 
            FROM tmp_cred
            
            --LET varmeses_venc = 0;          
            SELECT CASE WHEN monto_vencido >  0 THEN 1 
                WHEN mto_venc_trasp > 0 THEN (SELECT count(num_credito) FROM "informix".tmp_sdohist b --bdicred:sd_maesdoshist b  
                                                WHERE a.empresa= b.empresa 
                                                AND a.num_credito=b.num_credito 
                                                AND fecha <= a.fecha 
                                                AND fecha >=(SELECT max(fecha) FROM  "informix".tmp_sdohist c --bdicred:sd_maesdoshist c
                                                                WHERE a.empresa=c.empresa 
                                                                AND a.num_credito=c.num_credito 
                                                                AND c.monto_vencido > 0 
                                                                AND fecha <= a.fecha))
            ELSE 0 END
            INTO varmeses_venc
            FROM --bdicred:sd_maesdoshist a
                   "informix".tmp_sdohist a
            WHERE a.empresa = vempresa
            AND a.fecha = varfecha
            AND a.monto_vencido + a.mto_venc_trasp > 0 
            AND a.num_credito = varnum_credito;
--/*
            IF nvl(varmeses_venc, 0) <> 0 THEN
                UPDATE tmp_cred SET pagos_vencidos = varmeses_venc
                WHERE num_credito = varnum_credito AND fecha = varfecha;
            END IF
   --     */    

        END FOREACH;

    IF EXISTS (SELECT num_credito FROM bdimonitorcob:mc_detestadmes WHERE num_credito = vnum_credito) THEN
        DELETE bdimonitorcob:mc_detestadmes WHERE num_credito = vnum_credito;
    END IF;    

        INSERT INTO mc_detestadanual
        SELECT '001', YEAR(FECHA), '130', vnum_credito, MAX(SALDO_AL_CORTE), current, current
        FROM tmp_cred
        GROUP BY 1,2,3,4;

        INSERT INTO mc_detestadanual
        SELECT '001', YEAR(FECHA), '190', vnum_credito, MAX(COMPRAS), current, current
        FROM tmp_cred
        GROUP BY 1,2,3,4;

        INSERT INTO mc_detestadanual
        SELECT '001', YEAR(FECHA), '200', vnum_credito, MAX(DISPOSICIONES), current, current
        FROM tmp_cred
        GROUP BY 1,2,3,4;

        INSERT INTO mc_detestadanual
        SELECT '001', YEAR(FECHA), '210', vnum_credito, MAX(PAGOS), current, current
        FROM tmp_cred
        GROUP BY 1,2,3,4;

        UPDATE statistics medium FOR TABLE bdimonitorcob:mc_detestadanual;

        insert into bdimonitorcob:mc_detestadmes
        SELECT year(fecha), '230',num_credito, '001',
        sum(case when month(fecha) = 1 then 
                 case when saldo_al_corte <= 0 and  pagos + compras + disposiciones = 0 then 00 
                      when pagos > 0 and totalero = 0 then 92
                      when saldo_al_corte > 0 and compras + disposiciones = 0 and pago_min <= 0 then 93
                      when saldo_al_corte > 0 and compras + disposiciones > 0 and pago_min <= 0 then 91
                      else pagos_vencidos
                 end
                 else 0 end),
        sum(case when month(fecha) = 2 then 
                 case when saldo_al_corte <= 0 and  pagos + compras + disposiciones = 0 then 00 
                      when pagos > 0 and totalero = 0 then 92
                      when saldo_al_corte > 0 and compras + disposiciones = 0 and pago_min <= 0 then 93
                      when saldo_al_corte > 0 and compras + disposiciones > 0 and pago_min <= 0 then 91
                      else pagos_vencidos
                 end
                 else 0 end),
        sum(case when month(fecha) = 3 then 
                 case when saldo_al_corte <= 0 and  pagos + compras + disposiciones = 0 then 00 
                      when pagos > 0 and totalero = 0 then 92
                      when saldo_al_corte > 0 and compras + disposiciones = 0 and pago_min <= 0 then 93
                      when saldo_al_corte > 0 and compras + disposiciones > 0 and pago_min <= 0 then 91
                      else pagos_vencidos
                 end
                 else 0 end),
        sum(case when month(fecha) = 4 then 
                 case when saldo_al_corte <= 0 and  pagos + compras + disposiciones = 0 then 00 
                      when pagos > 0 and totalero = 0 then 92
                      when saldo_al_corte > 0 and compras + disposiciones = 0 and pago_min <= 0 then 93
                      when saldo_al_corte > 0 and compras + disposiciones > 0 and pago_min <= 0 then 91
                      else pagos_vencidos
                 end
                 else 0 end),
        sum(case when month(fecha) = 5 then 
                 case when saldo_al_corte <= 0 and  pagos + compras + disposiciones = 0 then 00 
                      when pagos > 0 and totalero = 0 then 92
                      when saldo_al_corte > 0 and compras + disposiciones = 0 and pago_min <= 0 then 93
                      when saldo_al_corte > 0 and compras + disposiciones > 0 and pago_min <= 0 then 91
                      else pagos_vencidos
                 end
                 else 0 end),
        sum(case when month(fecha) = 6 then 
                 case when saldo_al_corte <= 0 and  pagos + compras + disposiciones = 0 then 00 
                      when pagos > 0 and totalero = 0 then 92
                      when saldo_al_corte > 0 and compras + disposiciones = 0 and pago_min <= 0 then 93
                      when saldo_al_corte > 0 and compras + disposiciones > 0 and pago_min <= 0 then 91
                      else pagos_vencidos
                 end
                 else 0 end),
        sum(case when month(fecha) = 7 then 
                 case when saldo_al_corte <= 0 and  pagos + compras + disposiciones = 0 then 00 
                      when pagos > 0 and totalero = 0 then 92
                      when saldo_al_corte > 0 and compras + disposiciones = 0 and pago_min <= 0 then 93
                      when saldo_al_corte > 0 and compras + disposiciones > 0 and pago_min <= 0 then 91
                      else pagos_vencidos
                 end
                 else 0 end),
        sum(case when month(fecha) = 8 then 
                 case when saldo_al_corte <= 0 and  pagos + compras + disposiciones = 0 then 00 
                      when pagos > 0 and totalero = 0 then 92
                      when saldo_al_corte > 0 and compras + disposiciones = 0 and pago_min <= 0 then 93
                      when saldo_al_corte > 0 and compras + disposiciones > 0 and pago_min <= 0 then 91
                      else pagos_vencidos
                 end
                 else 0 end),
        sum(case when month(fecha) = 9 then 
                 case when saldo_al_corte <= 0 and  pagos + compras + disposiciones = 0 then 00 
                      when pagos > 0 and totalero = 0 then 92
                      when saldo_al_corte > 0 and compras + disposiciones = 0 and pago_min <= 0 then 93
                      when saldo_al_corte > 0 and compras + disposiciones > 0 and pago_min <= 0 then 91
                      else pagos_vencidos
                 end
                 else 0 end),
        sum(case when month(fecha) = 10 then 
                 case when saldo_al_corte <= 0 and  pagos + compras + disposiciones = 0 then 00 
                      when pagos > 0 and totalero = 0 then 92
                      when saldo_al_corte > 0 and compras + disposiciones = 0 and pago_min <= 0 then 93
                      when saldo_al_corte > 0 and compras + disposiciones > 0 and pago_min <= 0 then 91
                      else pagos_vencidos
                 end
                 else 0 end),
        sum(case when month(fecha) = 11 then 
                 case when saldo_al_corte <= 0 and  pagos + compras + disposiciones = 0 then 00 
                      when pagos > 0 and totalero = 0 then 92
                      when saldo_al_corte > 0 and compras + disposiciones = 0 and pago_min <= 0 then 93
                      when saldo_al_corte > 0 and compras + disposiciones > 0 and pago_min <= 0 then 91
                      else pagos_vencidos
                 end
                 else 0 end),
        sum(case when month(fecha) = 12 then 
                 case when saldo_al_corte <= 0 and  pagos + compras + disposiciones = 0 then 00 
                      when pagos > 0 and totalero = 0 then 92
                      when saldo_al_corte > 0 and compras + disposiciones = 0 and pago_min <= 0 then 93
                      when saldo_al_corte > 0 and compras + disposiciones > 0 and pago_min <= 0 then 91
                      else pagos_vencidos
                 end
                 else 0 end),
        current,
        current
        FROM tmp_cred
        group by 1,2,3,4;


        insert into bdimonitorcob:mc_detestadmes
        SELECT year(fecha), '110',num_credito, '001',
        sum(case when month(fecha) = 1 then saldo_al_corte else 0 end),
        sum(case when month(fecha) = 2 then saldo_al_corte else 0 end),
        sum(case when month(fecha) = 3 then saldo_al_corte else 0 end),
        sum(case when month(fecha) = 4 then saldo_al_corte else 0 end),
        sum(case when month(fecha) = 5 then saldo_al_corte else 0 end),
        sum(case when month(fecha) = 6 then saldo_al_corte else 0 end),
        sum(case when month(fecha) = 7 then saldo_al_corte else 0 end),
        sum(case when month(fecha) = 8 then saldo_al_corte else 0 end),
        sum(case when month(fecha) = 9 then saldo_al_corte else 0 end),
        sum(case when month(fecha) = 10 then saldo_al_corte else 0 end),
        sum(case when month(fecha) = 11 then saldo_al_corte else 0 end),
        sum(case when month(fecha) = 12 then saldo_al_corte else 0 end),
        current,
        current
        FROM tmp_cred
        group by 1,2,3,4;

        insert into bdimonitorcob:mc_detestadmes
        SELECT year(fecha), '120',num_credito, '001',
        sum(case when month(fecha) = 1 then saldo_promedio::INTEGER else 0 end),
        sum(case when month(fecha) = 2 then saldo_promedio::INTEGER else 0 end),
        sum(case when month(fecha) = 3 then saldo_promedio::INTEGER else 0 end),
        sum(case when month(fecha) = 4 then saldo_promedio::INTEGER else 0 end),
        sum(case when month(fecha) = 5 then saldo_promedio::INTEGER else 0 end),
        sum(case when month(fecha) = 6 then saldo_promedio::INTEGER else 0 end),
        sum(case when month(fecha) = 7 then saldo_promedio::INTEGER else 0 end),
        sum(case when month(fecha) = 8 then saldo_promedio::INTEGER else 0 end),
        sum(case when month(fecha) = 9 then saldo_promedio::INTEGER else 0 end),
        sum(case when month(fecha) = 10 then saldo_promedio::INTEGER else 0 end),
        sum(case when month(fecha) = 11 then saldo_promedio::INTEGER else 0 end),
        sum(case when month(fecha) = 12 then saldo_promedio::INTEGER else 0 end),
        current,
        current
        FROM tmp_cred
        group by 1,2,3,4;

        insert into bdimonitorcob:mc_detestadmes
        SELECT year(fecha), '240',num_credito, '001',
        sum(case when month(fecha) = 1 then pagos else 0 end),
        sum(case when month(fecha) = 2 then pagos else 0 end),
        sum(case when month(fecha) = 3 then pagos else 0 end),
        sum(case when month(fecha) = 4 then pagos else 0 end),
        sum(case when month(fecha) = 5 then pagos else 0 end),
        sum(case when month(fecha) = 6 then pagos else 0 end),
        sum(case when month(fecha) = 7 then pagos else 0 end),
        sum(case when month(fecha) = 8 then pagos else 0 end),
        sum(case when month(fecha) = 9 then pagos else 0 end),
        sum(case when month(fecha) = 10 then pagos else 0 end),
        sum(case when month(fecha) = 11 then pagos else 0 end),
        sum(case when month(fecha) = 12 then pagos else 0 end),
        current,
        current
        FROM tmp_cred
        group by 1,2,3,4;

        insert into bdimonitorcob:mc_detestadmes
        SELECT year(fecha), '140',num_credito, '001',
        sum(case when month(fecha) = 1 then compras else 0 end),
        sum(case when month(fecha) = 2 then compras else 0 end),
        sum(case when month(fecha) = 3 then compras else 0 end),
        sum(case when month(fecha) = 4 then compras else 0 end),
        sum(case when month(fecha) = 5 then compras else 0 end),
        sum(case when month(fecha) = 6 then compras else 0 end),
        sum(case when month(fecha) = 7 then compras else 0 end),
        sum(case when month(fecha) = 8 then compras else 0 end),
        sum(case when month(fecha) = 9 then compras else 0 end),
        sum(case when month(fecha) = 10 then compras else 0 end),
        sum(case when month(fecha) = 11 then compras else 0 end),
        sum(case when month(fecha) = 12 then compras else 0 end),
        current,
        current
        FROM tmp_cred
        group by 1,2,3,4;

        insert into bdimonitorcob:mc_detestadmes
        SELECT year(fecha), '150',num_credito, '001',
        sum(case when month(fecha) = 1 then disposiciones else 0 end),
        sum(case when month(fecha) = 2 then disposiciones else 0 end),
        sum(case when month(fecha) = 3 then disposiciones else 0 end),
        sum(case when month(fecha) = 4 then disposiciones else 0 end),
        sum(case when month(fecha) = 5 then disposiciones else 0 end),
        sum(case when month(fecha) = 6 then disposiciones else 0 end),
        sum(case when month(fecha) = 7 then disposiciones else 0 end),
        sum(case when month(fecha) = 8 then disposiciones else 0 end),
        sum(case when month(fecha) = 9 then disposiciones else 0 end),
        sum(case when month(fecha) = 10 then disposiciones else 0 end),
        sum(case when month(fecha) = 11 then disposiciones else 0 end),
        sum(case when month(fecha) = 12 then disposiciones else 0 end),
        current,
        current
        FROM tmp_cred
        group by 1,2,3,4;

        insert into bdimonitorcob:mc_detestadmes
        SELECT year(fecha), '220',num_credito, '001',
        sum(case when month(fecha) = 1 then porcentaje_consumo else 0 end),
        sum(case when month(fecha) = 2 then porcentaje_consumo else 0 end),
        sum(case when month(fecha) = 3 then porcentaje_consumo else 0 end),
        sum(case when month(fecha) = 4 then porcentaje_consumo else 0 end),
        sum(case when month(fecha) = 5 then porcentaje_consumo else 0 end),
        sum(case when month(fecha) = 6 then porcentaje_consumo else 0 end),
        sum(case when month(fecha) = 7 then porcentaje_consumo else 0 end),
        sum(case when month(fecha) = 8 then porcentaje_consumo else 0 end),
        sum(case when month(fecha) = 9 then porcentaje_consumo else 0 end),
        sum(case when month(fecha) = 10 then porcentaje_consumo else 0 end),
        sum(case when month(fecha) = 11 then porcentaje_consumo else 0 end),
        sum(case when month(fecha) = 12 then porcentaje_consumo else 0 end),
        current,
        current
        FROM tmp_cred
        group by 1,2,3,4;

        insert into bdimonitorcob:mc_detestadmes
        SELECT year(fecha), '160',num_credito, '001',
        sum(case when month(fecha) = 1 then compras / DECODE(no_compras,0,1,no_compras) else 0 end),
        sum(case when month(fecha) = 2 then compras / DECODE(no_compras,0,1,no_compras) else 0 end),
        sum(case when month(fecha) = 3 then compras / DECODE(no_compras,0,1,no_compras) else 0 end),
        sum(case when month(fecha) = 4 then compras / DECODE(no_compras,0,1,no_compras) else 0 end),
        sum(case when month(fecha) = 5 then compras / DECODE(no_compras,0,1,no_compras) else 0 end),
        sum(case when month(fecha) = 6 then compras / DECODE(no_compras,0,1,no_compras) else 0 end),
        sum(case when month(fecha) = 7 then compras / DECODE(no_compras,0,1,no_compras) else 0 end),
        sum(case when month(fecha) = 8 then compras / DECODE(no_compras,0,1,no_compras) else 0 end),
        sum(case when month(fecha) = 9 then compras / DECODE(no_compras,0,1,no_compras) else 0 end),
        sum(case when month(fecha) = 10 then compras / DECODE(no_compras,0,1,no_compras) else 0 end),
        sum(case when month(fecha) = 11 then compras / DECODE(no_compras,0,1,no_compras) else 0 end),
        sum(case when month(fecha) = 12 then compras / DECODE(no_compras,0,1,no_compras) else 0 end),
        current,
        current
        FROM tmp_cred
        group by 1,2,3,4;

        insert into bdimonitorcob:mc_detestadmes
        SELECT year(fecha), '170',num_credito, '001',
        sum(case when month(fecha) = 1 then disposiciones / DECODE(no_disposiciones,0,1,no_disposiciones) else 0 end),
        sum(case when month(fecha) = 2 then disposiciones / DECODE(no_disposiciones,0,1,no_disposiciones) else 0 end),
        sum(case when month(fecha) = 3 then disposiciones / DECODE(no_disposiciones,0,1,no_disposiciones) else 0 end),
        sum(case when month(fecha) = 4 then disposiciones / DECODE(no_disposiciones,0,1,no_disposiciones) else 0 end),
        sum(case when month(fecha) = 5 then disposiciones / DECODE(no_disposiciones,0,1,no_disposiciones) else 0 end),
        sum(case when month(fecha) = 6 then disposiciones / DECODE(no_disposiciones,0,1,no_disposiciones) else 0 end),
        sum(case when month(fecha) = 7 then disposiciones / DECODE(no_disposiciones,0,1,no_disposiciones) else 0 end),
        sum(case when month(fecha) = 8 then disposiciones / DECODE(no_disposiciones,0,1,no_disposiciones) else 0 end),
        sum(case when month(fecha) = 9 then disposiciones / DECODE(no_disposiciones,0,1,no_disposiciones) else 0 end),
        sum(case when month(fecha) = 10 then disposiciones / DECODE(no_disposiciones,0,1,no_disposiciones) else 0 end),
        sum(case when month(fecha) = 11 then disposiciones / DECODE(no_disposiciones,0,1,no_disposiciones) else 0 end),
        sum(case when month(fecha) = 12 then disposiciones / DECODE(no_disposiciones,0,1,no_disposiciones) else 0 end),
        current,
        current
        FROM tmp_cred
        group by 1,2,3,4;

        insert into bdimonitorcob:mc_detestadmes
        SELECT year(fecha), '180',num_credito, '001',
        sum(case when month(fecha) = 1 then pagos / DECODE(no_pagos,0,1,no_pagos) else 0 end),
        sum(case when month(fecha) = 2 then pagos / DECODE(no_pagos,0,1,no_pagos) else 0 end),
        sum(case when month(fecha) = 3 then pagos / DECODE(no_pagos,0,1,no_pagos) else 0 end),
        sum(case when month(fecha) = 4 then pagos / DECODE(no_pagos,0,1,no_pagos) else 0 end),
        sum(case when month(fecha) = 5 then pagos / DECODE(no_pagos,0,1,no_pagos) else 0 end),
        sum(case when month(fecha) = 6 then pagos / DECODE(no_pagos,0,1,no_pagos) else 0 end),
        sum(case when month(fecha) = 7 then pagos / DECODE(no_pagos,0,1,no_pagos) else 0 end),
        sum(case when month(fecha) = 8 then pagos / DECODE(no_pagos,0,1,no_pagos) else 0 end),
        sum(case when month(fecha) = 9 then pagos / DECODE(no_pagos,0,1,no_pagos) else 0 end),
        sum(case when month(fecha) = 10 then pagos / DECODE(no_pagos,0,1,no_pagos) else 0 end),
        sum(case when month(fecha) = 11 then pagos / DECODE(no_pagos,0,1,no_pagos) else 0 end),
        sum(case when month(fecha) = 12 then pagos / DECODE(no_pagos,0,1,no_pagos) else 0 end),
        current,
        current
        FROM tmp_cred
        group by 1,2,3,4;

        DROP TABLE "informix".tmp_cred;
        DROP TABLE "informix".tmp_sdohist;
       
		RETURN cCod_ret, cMensaje;

	END;
END PROCEDURE;