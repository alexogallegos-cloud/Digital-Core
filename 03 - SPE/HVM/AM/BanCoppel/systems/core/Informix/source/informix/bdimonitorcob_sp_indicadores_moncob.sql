CREATE PROCEDURE "informix".sp_indicadores_moncob(p_anio INTEGER, p_mes INTEGER, p_num_indicador CHAR(3), p_origen INTEGER)
       RETURNING CHAR(6), CHAR(150);
-- EL PARAMETRO p_origen
-- 1 = EL USARIO INDICA LA FECHA A EJECUTAR
-- 2 = LA EJECUCION SE REALIZA CON LA FECHA ACTUAL
       
DEFINE vcodret         CHAR(6);
DEFINE vvcCod_ret      CHAR(6);
DEFINE ccod_ret        CHAR(6);
DEFINE vmensaje        CHAR(150);
DEFINE cmensaje        CHAR(150);
DEFINE sql_err         INTEGER;
DEFINE isam_err        INTEGER;
DEFINE error_info      VARCHAR(150);
DEFINE vmes_ejecut     CHAR(8);
DEFINE vempresa        CHAR(3);
DEFINE cProceso        CHAR(4);
DEFINE fch_per         DATE;
DEFINE fch_periodo     DATE;
DEFINE fch_anio        INTEGER;
DEFINE fch_mes         INTEGER;
DEFINE vmonto_saldo    DECIMAL(18,2);
DEFINE vsaldo_prom     DECIMAL(18,2);
DEFINE vmonto_pagos    DECIMAL(18,2);
DEFINE vmonto_compras  DECIMAL(18,2);
DEFINE vmonto_dispo    DECIMAL(18,2);
DEFINE vporc_consumo   DECIMAL(18,2);
DEFINE vprom_pagos     DECIMAL(18,2);
DEFINE vprom_compras   DECIMAL(18,2);
DEFINE vprom_dispo     DECIMAL(18,2);
DEFINE vnum_credito    CHAR(20);
DEFINE vnum_compras    INTEGER;
DEFINE vnum_dispo      INTEGER;
DEFINE vnum_pagos      INTEGER;
DEFINE fch_limite      DATE;  
    --SET DEBUG FILE TO "/tmp/sp_genindicadoresmoncob.out";
    --TRACE ON; 

    IF p_origen = 1 THEN
        LET fch_per =   p_mes || '-' || '20' || '-' || p_anio;
        LET fch_periodo = DATE(fch_per);
        LET vmes_ejecut = p_mes || '-' || p_anio; 
    ELSE
        LET fch_periodo = TODAY - 1 UNITS MONTH;
        LET fch_anio    = year  (fch_periodo);
        LET fch_mes     = month (fch_periodo);
        LET fch_periodo = fch_mes || '-' || '20' || '-' || fch_anio;
        LET vmes_ejecut = fch_mes || '-' || fch_anio; 
    END IF;
        
    LET vMensaje        = 'PROCESO EXITOSO';
    LET cmensaje        = 'PROCESO EXITOSO';
    LET vCodRet         = '00000';
    LET vempresa        = '001';
    LET cProceso        = '66666';
    LET cCod_ret        = '000000';
    LET vmonto_saldo    = 0;
    LET vsaldo_prom     = 0;
    LET vmonto_pagos    = 0;
    LET vprom_pagos     = 0;
    LET vmonto_compras  = 0;
    LET vprom_compras   = 0;
    LET vmonto_dispo    = 0;
    LET vprom_dispo     = 0;
    LET vporc_consumo   = 0;
    LET fch_limite      = TODAY - 2 UNITS MONTH;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET vcodret  = sql_err;
        LET vmensaje  = error_info;
        CALL bdimonitorcob:"informix".sp_inserta_bitacora_moncob(vempresa, cproceso, ccod_ret, cmensaje, '02', vmes_ejecut)
        RETURNING vvcCod_ret;
        RETURN vCodRet, vMensaje;

    END EXCEPTION;

        CALL bdimonitorcob:"informix".sp_inserta_bitacora_moncob(vempresa, cproceso, ccod_ret, cmensaje, '01', vmes_ejecut)
        RETURNING vvcCod_ret;


IF fch_periodo >= fch_limite THEN

    SET ISOLATION TO dirty READ;
    FOREACH
    SELECT {+INDEX(bdimonitorcob:mc_masterestad mc_masterestad_uc1), (bdicred:sd_maesdoshist maesdishist2)
        ,(bdicred@pld_tcp:sd_encabezado2_edocta idx_encabezado2_edocta1),(bdicred@pld_tcp:sd_pie_edocta idx_pie_edocta)} a.num_credito
    ,nvl(sdo_debe,0) + nvl(interes_pago_total_tc,0) saldo_al_corte
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
        (d.saldo_promedio /decode(b.monto_otorgado,0,1, b.monto_otorgado)  *100 ) Porcentaje_consumo
    INTO vnum_credito, vmonto_saldo, vsaldo_prom, vmonto_pagos, vmonto_compras, vmonto_dispo, vnum_compras
          ,vnum_dispo, vnum_pagos, vporc_consumo
    FROM bdimonitorcob:mc_masterestad a,
        bdicred:sd_maesdoshist b,
        bdicred@pld_tcp:sd_encabezado2_edocta c,
        bdicred@pld_tcp:sd_pie_edocta d
    WHERE b.empresa = a.empresa   AND a.num_credito = b.num_credito
    AND c.fecha_emision = b.fecha AND c.num_credito = a.num_credito 
    AND d.fecha_emision =  b.fecha  AND d.num_credito = b.num_credito
    AND b.fecha = fch_periodo AND a.status_cred IN ('BT', 'BA', 'AA','E1', 'E2', 'E3')
    
    LET vprom_pagos =0;
    LET vprom_compras =0;
    LET vprom_dispo =0;

    --- OBTIENE PROMEDIOS DE COMPRAS, DISPOSICIONES Y PAGOS
    IF nvl(vmonto_pagos,0) <> 0 THEN
        IF vnum_pagos =0 THEN LET vnum_pagos =1; END IF;
        LET vprom_pagos = (vmonto_pagos / vnum_pagos);
    END IF;

    IF nvl(vmonto_compras,0) <> 0 THEN
        IF vnum_compras =0 THEN LET vnum_compras =1; END IF;
        LET vprom_compras = (vmonto_compras / vnum_compras);
    END IF;

    IF nvl(vmonto_dispo,0) <> 0 THEN
        IF vnum_dispo =0 THEN LET vnum_dispo =1; END IF;
        LET vprom_dispo = (vmonto_dispo / vnum_dispo);
    END IF;
    
    --- VALIDA MES Y SE ACTUALIZA  EL INDICADOR CORRESPONDIENTE
    IF (p_mes = 01) THEN
        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ene = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ene = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ene = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ene = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ene = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ene = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ene = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ene = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ene = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;        
    ELIF (p_mes = 02) THEN
        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET feb = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET feb = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET feb = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET feb = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET feb = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET feb = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET feb = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET feb = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET feb = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;
    ELIF (p_mes = 03) THEN
        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET mar = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET mar = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET mar = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET mar = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET mar = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET mar = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET mar = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET mar = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET mar = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;
    ELIF (p_mes = 04) THEN
        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET abr = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET abr = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET abr = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET abr = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET abr = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET abr = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET abr = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET abr = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET abr = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;
    ELIF (p_mes = 05) THEN
        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET may = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET may = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET may = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET may = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET may = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET may = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET may = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET may = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET may = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;
    ELIF (p_mes = 06) THEN
        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jun = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jun = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jun = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jun = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jun = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jun = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jun = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jun = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jun = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;
    ELIF (p_mes = 07) THEN
        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jul = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jul = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jul = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jul = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jul = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jul = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jul = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jul = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jul = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;
    ELIF (p_mes = 08) THEN
        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ago = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ago = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ago = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ago = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ago = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ago = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ago = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ago = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ago = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;
    ELIF (p_mes = 09) THEN
        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET sep = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET sep = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET sep = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET sep = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET sep = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET sep = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET sep = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET sep = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET sep = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;
    ELIF (p_mes = 10) THEN
        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET oct = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET oct = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET oct = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET oct = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET oct = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET oct = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET oct = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET oct = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET oct = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;
    ELIF (p_mes = 11) THEN
        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET nov = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET nov = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET nov = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET nov = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET nov = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET nov = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET nov = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET nov = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET nov = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;
    ELIF (p_mes = 12) THEN
        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET dic = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET dic = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET dic = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET dic = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET dic = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET dic = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET dic = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET dic = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET dic = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;
   END IF
   END FOREACH;
ELSE
    SET ISOLATION TO dirty READ;
    FOREACH        
            SELECT  a.num_credito, nvl(sdo_debe,0) + nvl(interes_pago_total_tc,0) saldo_al_corte,
                d.saldo_promedio, c.menos_abonos pagos, c.mas_compras compras,
                c.mas_disp_efectivo disposiciones,
                (SELECT  count(*) FROM bdicred:sd_movhis WHERE a.empresa=empresa AND a.num_credito = num_credito 
                    AND codigo_fun ='002' AND codigo_ref IN (37,57,937,938) AND fecha_mov BETWEEN (b.fecha - 1 UNITS month) + 1 UNITS day 
                    AND b.fecha AND reversado='N') No_Compras,
                (SELECT count(*) FROM bdicred:sd_movhis WHERE a.empresa=empresa AND a.num_credito = num_credito AND codigo_fun ='002' 
                    AND codigo_ref IN (50,30,40,41,42,34,35,36,60,61,62,63,64) AND fecha_mov BETWEEN (b.fecha - 1 UNITS month) + 1 UNITS day 
                    AND b.fecha AND reversado='N')No_Disposiciones,
                (SELECT  count(*) FROM bdicred:sd_movhis WHERE a.empresa=empresa AND a.num_credito = num_credito
                    AND codigo_fun  IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanual) AND codigo_ref=1 
                    AND fecha_mov BETWEEN (b.fecha - 1 UNITS month) + 1 UNITS day AND b.fecha AND reversado='N')No_pagos,
                (d.saldo_promedio /decode(b.monto_otorgado,0,1, b.monto_otorgado)  * 100) Porcentaje_consumo
            INTO vnum_credito, vmonto_saldo, vsaldo_prom, vmonto_pagos, vmonto_compras, vmonto_dispo, vnum_compras
                ,vnum_dispo, vnum_pagos, vporc_consumo
            FROM bdimonitorcob:mc_masterestad a,
                bdicred:sd_maesdoshist b,
                bdicred:sd_encabezado2_edocta_hist c ,
                bdicred:sd_pie_edocta_hist d
            WHERE a.empresa = vempresa
            AND a.empresa = b.empresa 
            AND a.num_credito = b.num_credito
            AND a.num_credito = c.num_credito and b.fecha = fch_periodo  
            AND b.fecha = c.fecha_emision 
            AND d.fecha_emision =  b.fecha 
            AND d.num_credito = b.num_credito
            AND a.status_cred IN ('BT', 'BA', 'AA','E1', 'E2', 'E3')

    --LET vnum_compras = 5;
    --LET vnum_pagos = 1;
    LET vprom_pagos =0;
    LET vprom_compras =0;
    LET vprom_dispo =0;

    --- OBTIENE PROMEDIOS DE COMPRAS, DISPOSICIONES Y PAGOS
    IF nvl(vmonto_pagos,0) <> 0 THEN
        IF vnum_pagos =0 THEN LET vnum_pagos =1; END IF;
        LET vprom_pagos = (vmonto_pagos / vnum_pagos);
    END IF;

    IF nvl(vmonto_compras,0) <> 0 THEN
        IF vnum_compras =0 THEN LET vnum_compras =1; END IF;
        LET vprom_compras = (vmonto_compras / vnum_compras);
    END IF;

    IF nvl(vmonto_dispo,0) <> 0 THEN
        IF vnum_dispo =0 THEN LET vnum_dispo =1; END IF;
        LET vprom_dispo = (vmonto_dispo / vnum_dispo);
    END IF;
    
    --- VALIDA MES Y SE ACTUALIZA  EL INDICADOR CORRESPONDIENTE
    IF (p_mes = 01) THEN

        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ene = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ene = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ene = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ene = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ene = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ene = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ene = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ene = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ene = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;
        
    ELIF (p_mes = 02) THEN

        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET feb = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET feb = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET feb = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET feb = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET feb = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET feb = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET feb = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET feb = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET feb = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;

    ELIF (p_mes = 03) THEN

        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET mar = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET mar = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET mar = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET mar = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET mar = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET mar = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET mar = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET mar = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET mar = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;

    ELIF (p_mes = 04) THEN

        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET abr = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET abr = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET abr = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET abr = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET abr = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET abr = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET abr = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET abr = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET abr = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;

    ELIF (p_mes = 05) THEN

        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET may = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET may = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET may = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET may = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET may = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET may = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET may = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET may = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET may = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;

    ELIF (p_mes = 06) THEN

        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jun = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jun = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jun = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jun = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jun = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jun = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jun = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jun = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jun = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;

    ELIF (p_mes = 07) THEN

        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jul = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jul = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jul = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jul = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jul = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jul = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jul = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jul = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET jul = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;

    ELIF (p_mes = 08) THEN

        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ago = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ago = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ago = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ago = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ago = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ago = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ago = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ago = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET ago = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;

    ELIF (p_mes = 09) THEN

        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET sep = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET sep = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET sep = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET sep = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET sep = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET sep = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET sep = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET sep = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET sep = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;

    ELIF (p_mes = 10) THEN

        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET oct = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET oct = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET oct = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET oct = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET oct = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET oct = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET oct = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET oct = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET oct = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;

    ELIF (p_mes = 11) THEN

        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET nov = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET nov = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET nov = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET nov = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET nov = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET nov = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET nov = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET nov = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET nov = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;

    ELIF (p_mes = 12) THEN

        IF (p_num_indicador = '110') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET dic = vmonto_saldo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '110' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '120') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET dic = vsaldo_prom, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '120' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '140') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET dic = vmonto_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '140' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '160') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET dic = vprom_compras, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '160' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '150') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET dic = vmonto_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '150' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '170') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET dic = vprom_dispo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '170' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '240') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET dic = vmonto_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '240' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '180') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET dic = vprom_pagos, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '180' AND num_credito = vnum_credito;
        ELIF (p_num_indicador = '220') THEN
            UPDATE bdimonitorcob:mc_detestadmes SET dic = vporc_consumo, fecha_ejecucion = TODAY
            WHERE empresa = vempresa AND anio = p_anio AND id_conceptom = '220' AND num_credito = vnum_credito;
        END IF;
    END IF
    END FOREACH;   
END IF;
END
    CALL bdimonitorcob:"informix".sp_inserta_bitacora_moncob(vempresa, cproceso, ccod_ret, cmensaje, '03', vmes_ejecut)
    RETURNING vvcCod_ret;
RETURN vCodRet, vMensaje;
END PROCEDURE;