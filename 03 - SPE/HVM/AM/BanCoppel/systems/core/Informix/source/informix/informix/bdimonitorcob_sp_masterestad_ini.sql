CREATE PROCEDURE "informix".sp_masterestad_ini(p_anio INTEGER, p_mes INTEGER, p_origen INTEGER)
       RETURNING char(6), char(150);

-- EL PARAMETRO p_origen
-- 1 = EL USARIO INDICA LA FECHA A EJECUTAR
-- 2 = LA EJECUCION SE REALIZA CON LA FECHA ACTUAL

DEFINE vcodret             CHAR(6);
DEFINE vvcCod_ret          CHAR(6);
DEFINE ccod_ret            CHAR(6);
DEFINE vmensaje            CHAR(150);
DEFINE cmensaje            CHAR(150);
DEFINE sql_err             INTEGER;
DEFINE isam_err            INTEGER;
DEFINE error_info          VARCHAR(150);
DEFINE vfch_inicio         DATE;
DEFINE vfch_fin            DATE;
DEFINE vempresa            CHAR(3);
DEFINE cProceso            CHAR(4);
DEFINE vmes_ejecut         CHAR(8);
DEFINE v_num_credito       CHAR(20);
DEFINE v_num_tarjeta       CHAR(20);
DEFINE v_nombre            CHAR(50);
DEFINE v_fecha_apertura    DATE;
DEFINE vstatus_cred        CHAR(2);
DEFINE fch_per             DATE;
DEFINE p_anioo             INTEGER;
DEFINE p_mess              INTEGER;

--SET DEBUG FILE TO "/ids10_uc9/jtrujillo/sp_masterestad_ini.out";
--TRACE ON; 

    LET vempresa = '001';
    LET cProceso = '0002';
    LET vMensaje = 'PROCESO EXITOSO';
    LET cmensaje = 'PROCESO EXITOSO';
    LET vCodRet = '00000';
    LET cCod_ret = '000000';


    IF p_origen = 1 THEN
        LET fch_per =   p_mes || '-' || '01' || '-' || p_anio;
        LET vfch_inicio = DATE(fch_per);
    ELSE

        LET fch_per     = TODAY - 1 UNITS MONTH;
        LET p_anioo     = year  (fch_per);
        LET p_mess      = month (fch_per);
        LET fch_per     = p_mess || '-' || '01' || '-' || p_anioo;
        LET vfch_inicio = DATE(fch_per);
    END IF;

    CALL    bdicred:monthadd(vfch_inicio, 1)
            RETURNING vfch_fin;

      LET vmes_ejecut = TO_CHAR(vfch_fin, '%m%Y');
      LET vfch_fin = vfch_fin - 1 UNITS DAY;

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
        
        SET ISOLATION TO DIRTY READ;
        FOREACH	

            --SELECT {+INDEX(bdicred:sd_tarjeta idx_sd_tarjeta1)} 
            SELECT a.num_credito, a.fecha_apertura, b.num_tarjeta, b.nombre, a.status_cred
            INTO v_num_credito, v_fecha_apertura, v_num_tarjeta, v_nombre, vstatus_cred
            FROM bdicred:sd_maecred a
                ,bdicred:sd_tarjeta b
            WHERE a.empresa = b.empresa
            AND a.num_credito = b.num_credito
            AND a.fecha_apertura between vfch_inicio AND vfch_fin
            AND b.tipo_tarjeta = 'T'
            AND b.status_tar = 'A'

            INSERT INTO "informix".mc_masterestad
            VALUES (v_num_credito, v_num_tarjeta, '001', v_nombre, v_fecha_apertura, today, vstatus_cred);

        END FOREACH;

    CALL bdimonitorcob:"informix".sp_actualiza_statusmoncob()
    RETURNING vvcCod_ret, vMensaje;

    CALL bdimonitorcob:"informix".sp_inserta_bitacora_moncob(vempresa, cproceso, ccod_ret, cmensaje, '03', vmes_ejecut)
    RETURNING vvcCod_ret;

END

RETURN vCodRet, vMensaje;
END PROCEDURE;