CREATE PROCEDURE "informix".sp_actualiza_statusmoncob()
RETURNING CHAR(6), CHAR(150);

DEFINE vcodret             CHAR(6);
DEFINE vmensaje            CHAR(150);
DEFINE sql_err             INTEGER;
DEFINE isam_err            INTEGER;
DEFINE error_info          VARCHAR(150);
DEFINE v_num_credito       CHAR(20);
DEFINE vstatus_cred        CHAR(2);
DEFINE vvcCod_ret          CHAR(6);
DEFINE ccod_ret            CHAR(6);
DEFINE cmensaje            CHAR(150);
DEFINE vempresa            CHAR(3);
DEFINE cproceso            CHAR(4);
DEFINE vmes_ejecut         CHAR(8);

    --set debug file to "/tmp/sp_insertar_registros_mes.out";
    --trace on;

   LET vcodret = '00000';
   LET vmensaje = 'PROCESO EXITOSO';
   LET vempresa = '001';
   LET cproceso = '0085';
   LET vmes_ejecut = '';
   LET ccod_ret = '00000';
   LET cmensaje = 'PROCESO EXITOSO';   
   
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
    
    SET ISOLATION TO DIRTY READ;
    FOREACH

        SELECT {+INDEX(bdimonitorcob:mc_masterestad mc_masterestad_uc1)} distinct a.num_credito, b.status_cred
        INTO v_num_credito, vstatus_cred
        FROM mc_masterestad a, bdicred:sd_maecred b
        WHERE a.empresa = b.empresa
        AND a.num_credito = b.num_credito
        
        UPDATE informix.mc_masterestad SET status_cred = vstatus_cred
        WHERE num_credito = v_num_credito;
        
    END FOREACH;
    
END

    CALL bdimonitorcob:"informix".sp_inserta_bitacora_moncob(vempresa, cproceso, ccod_ret, cmensaje, '03', vmes_ejecut)
    RETURNING vvcCod_ret;

RETURN vCodRet, vMensaje;
END PROCEDURE;