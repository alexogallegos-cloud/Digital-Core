CREATE PROCEDURE "informix".sp_insertar_registros_mes(p_anio INTEGER, p_mes INTEGER, p_origen INTEGER)
       RETURNING CHAR(6), CHAR(150);

--ESTE PROCESO SE DEBE EJECUTAR EL PRIMER DIA DE CADA MES EN UN CRON CON EL p_origen = 2
--EXECUTE PROCEDURE "informix".sp_insertar_registros_mes(0, 0, '', 2);

-- EL PARAMETRO p_origen
-- 1 = EL USARIO INDICA LA FECHA A EJECUTAR
-- 2 = LA EJECUCION SE REALIZA CON LA FECHA ACTUAL

DEFINE vcodret              CHAR(6);
DEFINE sql_err              INTEGER;
DEFINE isam_err             INTEGER;
DEFINE error_info           VARCHAR(150);
DEFINE vmensaje             CHAR(150);
DEFINE vvcCod_ret           CHAR(6);
DEFINE ccod_ret             CHAR(6);
DEFINE cmensaje             CHAR(150);
DEFINE vfch_inicio          DATE;
DEFINE vfch_fin             DATE;
DEFINE vmes_ejecut          CHAR(8);
DEFINE vempresa             CHAR(3);
DEFINE cProceso             CHAR(4);
DEFINE v_num_credito        CHAR(20);
DEFINE p_fecha_ejecucion    DATE;
DEFINE p_anio_t             INTEGER;
DEFINE v_fecha_hoy          DATE;
DEFINE panio_act            INTEGER;

--SET DEBUG FILE TO "/tmp/sp_dispo_monto_prom_mes.out";
--TRACE ON;

    --CALL "informix".sp_fecha_moncob(p_anio, p_mes, p_origen)
      --   RETURNING vfch_inicio, vfch_fin, vmes_ejecut;

    LET vMensaje = 'PROCESO EXITOSO';
    LET cmensaje = 'PROCESO EXITOSO';
    LET vCodRet = '00000';
    LET vempresa = '001';
    LET cProceso = '0007';
    LET cCod_ret = '000000';
    

    SELECT fecha_hoy 
    INTO v_fecha_hoy 
    FROM bdinteg:si_fechas;

    LET panio_act = year (v_fecha_hoy);

    IF p_origen = 1 THEN

        LET vfch_inicio =   p_mes || '-' || '01' || '-' || p_anio;

    ELSE
        SELECT {+INDEX(bdinteg:si_fechas idx_si_fechas)} pri_dia_mes INTO vfch_inicio FROM bdinteg:si_fechas WHERE empresa = vempresa ;
        LET vfch_inicio = vfch_inicio - 1 UNITS MONTH;
    END IF;

    CALL bdicred:monthadd(vfch_inicio, 1)
         RETURNING vfch_fin;

      LET vmes_ejecut = TO_CHAR(vfch_fin, '%m%Y');
      LET vfch_fin = vfch_fin - 1 UNITS DAY;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET vcodret  = sql_err;
        LET vmensaje  = error_info;
        CALL bdimonitorcob:"informix".sp_inserta_bitacora_moncob(vempresa, cproceso, ccod_ret, cmensaje, '02', vmes_ejecut)
        RETURNING vvcCod_ret;
        RETURN vcodret, vmensaje;
    END EXCEPTION;

        CALL bdimonitorcob:"informix".sp_inserta_bitacora_moncob(vempresa, cproceso, ccod_ret, cmensaje, '01', vmes_ejecut)
        RETURNING vvcCod_ret;
        
SET ISOLATION TO dirty READ;
FOREACH

    SELECT {+INDEX(bdimonitorcob:mc_masterestad mc_masterestad_uc1)} distinct num_credito
    INTO v_num_credito
    FROM mc_masterestad
    WHERE fecha_apertura between vfch_inicio AND vfch_fin and empresa= vempresa
    AND status_cred IN ('BT', 'BA', 'AA')
    --AND (num_credito = p_num_credito or 0 = p_num_credito)
    --AND num_credito NOT IN (SELECT num_credito FROM mc_detestadmes)

    LET p_anio_t = p_anio;
        WHILE p_anio_t <= panio_act

            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(p_anio_t, '110', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');
            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(p_anio_t, '120', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');
            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(p_anio_t, '140', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');
            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(p_anio_t, '150', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');
            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(p_anio_t, '160', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');
            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(p_anio_t, '170', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');
            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(p_anio_t, '180', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');
            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(p_anio_t, '220', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');
            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(p_anio_t, '230', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');
            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(p_anio_t, '240', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');

        LET p_anio_t = p_anio_t + 1;
        END WHILE;
    
END FOREACH;
END

    CALL bdimonitorcob:"informix".sp_inserta_bitacora_moncob(vempresa, cproceso, ccod_ret, cmensaje, '03', vmes_ejecut)
    RETURNING vvcCod_ret;

RETURN vCodRet, vMensaje;
END PROCEDURE;