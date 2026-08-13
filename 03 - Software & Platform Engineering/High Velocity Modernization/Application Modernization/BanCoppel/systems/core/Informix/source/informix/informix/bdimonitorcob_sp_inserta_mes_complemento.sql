CREATE PROCEDURE "informix".sp_inserta_mes_complemento(vanio INTEGER)
RETURNING CHAR(6), CHAR(150);

DEFINE v_num_credito       CHAR(20);
DEFINE vCodRet             CHAR(6);
DEFINE vMensaje            CHAR(150);
DEFINE SQL_ERR             INTEGER;
DEFINE ISAM_ERR            INTEGER;
DEFINE cProceso             CHAR(4);
DEFINE vempresa             CHAR(3);
DEFINE error_info           VARCHAR(150);
DEFINE vvcCod_ret           CHAR(6);
DEFINE ccod_ret             CHAR(6);
DEFINE cmensaje             CHAR(150);
DEFINE vmes_ejecut          CHAR(8);

--DEFINE ERROR_INFO          VARCHAR(150);
--DEFINE cNombreProceso      CHAR(30);
--DEFINE cMesAnioEjecucion   CHAR(20);
--DEFINE vvcCod_ret           CHAR(6);


    --set debug file to "/tmp/sp_insertar_registros_mes.out";
    --trace on;

   LET vempresa = '001';
   LET cCod_ret = '000000';
   LET cmensaje = 'PROCESO EXITOSO';
   LET vmes_ejecut = vanio;
   LET cProceso = '0007';
   LET vMensaje = 'PROCESO EXITOSO';
   LET vCodRet = '00000';
   
BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET vCodRet  = SQL_ERR;
        LET vMensaje  = ERROR_INFO;
        CALL bdimonitorcob:"informix".sp_inserta_bitacora_moncob(vempresa, cproceso, ccod_ret, cmensaje, '02', vmes_ejecut)
        RETURNING vvcCod_ret;
        RETURN vCodRet, vMensaje;
    END EXCEPTION;
    
        CALL bdimonitorcob:"informix".sp_inserta_bitacora_moncob(vempresa, cproceso, ccod_ret, cmensaje, '01', vmes_ejecut)
        RETURNING vvcCod_ret;

    SET ISOLATION TO DIRTY READ;
    FOREACH

        SELECT distinct num_credito
        INTO v_num_credito
        FROM mc_masterestad
        WHERE empresa = vempresa
        AND status_cred IN ('BT', 'BA', 'AA')


            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(vanio, '110', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');
            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(vanio, '120', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');
            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(vanio, '140', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');
            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(vanio, '150', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');
            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(vanio, '160', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');
            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(vanio, '170', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');
            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(vanio, '180', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');
            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(vanio, '220', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');
            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(vanio, '230', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');
            INSERT INTO informix.mc_detestadmes(anio, id_conceptom, num_credito, empresa, ene, feb, mar, abr, may, jun, jul, ago, sep, oct, nov, dic, fecha_insercion, fecha_ejecucion) 
            VALUES(vanio, '240', v_num_credito, vempresa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, TODAY, '');

    END FOREACH;
    
    CALL bdimonitorcob:"informix".sp_inserta_bitacora_moncob(vempresa, cproceso, ccod_ret, cmensaje, '03', vmes_ejecut)
    RETURNING vvcCod_ret;

END
RETURN vCodRet, vMensaje;
END PROCEDURE;