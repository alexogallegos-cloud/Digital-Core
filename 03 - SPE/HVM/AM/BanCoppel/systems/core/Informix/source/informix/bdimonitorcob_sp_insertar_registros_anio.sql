CREATE PROCEDURE "informix".sp_insertar_registros_anio(p_anio INTEGER, p_mes INTEGER, p_origen INTEGER)
RETURNING CHAR(6), CHAR(150);

-- EL PARAMETRO p_origen
-- 1 = EL USARIO INDICA LA FECHA A EJECUTAR
-- 2 = LA EJECUCION SE REALIZA CON LA FECHA ACTUAL

DEFINE v_num_credito     CHAR(20);
DEFINE vCodRet           CHAR(6);
DEFINE vMensaje          CHAR(150);
DEFINE SQL_ERR           INTEGER;
DEFINE ISAM_ERR          INTEGER;
DEFINE ERROR_INFO        VARCHAR(150);
DEFINE v_fch_fin         DATE;
DEFINE v_fch_inic        DATE;
DEFINE v_fecha_hoy       CHAR(10);
DEFINE vvcCod_ret        CHAR(6);
DEFINE vempresa          CHAR(3);
DEFINE cProceso          CHAR(4);
DEFINE ccod_ret          CHAR(6);
DEFINE cmensaje          CHAR(150);
DEFINE fch_per           DATE;
DEFINE p_anioo           INTEGER;
DEFINE p_mess            INTEGER;
DEFINE vmes_ejecut       CHAR(8);
DEFINE p_anio_t          INTEGER;

    --SET debug file TO "/tmp/sp_insertar_registros_anio_04112009.out";
    --TRACE ON;

   LET v_num_credito     = " ";
   LET vCodRet           = "00000";
   LET vMensaje          = "INICIO DE PROCESO";
   LET cProceso          = '0004';
   LET cCod_ret          = '000000';
   LET cmensaje          = 'PROCESO EXITOSO';
   LET vempresa          = '001';


   IF p_origen = 1 THEN
        LET fch_per =   p_mes || '-' || '01' || '-' || p_anio;
        LET v_fch_inic = DATE(fch_per);
    ELSE

        LET fch_per     = TODAY - 1 UNITS MONTH;
        LET p_anioo     = year  (fch_per);
        LET p_mess      = month (fch_per);
        LET fch_per     = p_mess || '-' || '01' || '-' || p_anioo;
        LET v_fch_inic = DATE(fch_per);
    END IF;

    CALL    bdicred:monthadd(v_fch_inic, 1)
            RETURNING v_fch_fin;

      LET vmes_ejecut = TO_CHAR(v_fch_fin, '%m%Y');
      LET v_fch_fin = v_fch_fin - 1 UNITS DAY;




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

   SELECT year (fecha_hoy)
   INTO v_fecha_hoy FROM bdinteg:si_fechas;

    SET ISOLATION TO DIRTY READ;
    FOREACH

        SELECT {+INDEX(bdimonitorcob:mc_masterestad mc_masterestad_uc1)} distinct num_credito
        INTO v_num_credito
        FROM mc_masterestad
        WHERE empresa= vempresa
            AND status_cred IN ('BT', 'BA', 'AA')
            AND num_credito is not null
            AND num_tarjeta is not null
            AND fecha_apertura between v_fch_inic AND v_fch_fin


        LET p_anio_t = p_anio;
        WHILE p_anio_t <= v_fecha_hoy

            INSERT INTO mc_detestadanual (anio, id_conceptoa, num_credito, empresa, monto)
            VALUES (p_anio_t, '130', v_num_credito, vempresa, 0);

            INSERT INTO mc_detestadanual (anio, id_conceptoa, num_credito, empresa, monto)
            VALUES (p_anio_t, '190', v_num_credito, vempresa, 0);

            INSERT INTO mc_detestadanual (anio, id_conceptoa, num_credito, empresa, monto)
            VALUES (p_anio_t, '200', v_num_credito, vempresa, 0);

            INSERT INTO mc_detestadanual (anio, id_conceptoa, num_credito, empresa, monto)
            VALUES (p_anio_t, '210', v_num_credito, vempresa, 0);

        LET p_anio_t = p_anio_t +1;
        END WHILE;

    END FOREACH;

    LET vCodRet = '00000';
    LET vMensaje = 'PROCESO EXITOSO';

    CALL bdimonitorcob:"informix".sp_inserta_bitacora_moncob(vempresa, cproceso, ccod_ret, cmensaje, '03', vmes_ejecut)
    RETURNING vvcCod_ret;

END
RETURN vCodRet, vMensaje;
END PROCEDURE;