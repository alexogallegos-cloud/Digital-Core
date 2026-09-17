CREATE PROCEDURE "informix".sp_ejecuta_monitor(p_anio INTEGER, p_mes INTEGER, p_num_indicador CHAR(3), p_proceso INTEGER)
       RETURNING char(6), char(150);
      
--DEFINE v_concepto           CHAR(3);
DEFINE vCodRet              CHAR(6);
DEFINE vMensaje             CHAR(150);
DEFINE SQL_ERR              INTEGER;
DEFINE ISAM_ERR             INTEGER;
DEFINE ERROR_INFO           VARCHAR(150);
DEFINE p_origen             INTEGER;
DEFINE vvCodRet             char(6);
DEFINE vvMensaje            char(150);
DEFINE p_anioo              INTEGER;
DEFINE p_mess               INTEGER;
DEFINE p_num_indicadorr     CHAR(3);

    --SET DEBUG FILE TO "/tmp/sp_ejecuta_monitor.out";
    --TRACE ON; 

    LET vCodRet             =   "11111";
    LET vMensaje            =   "PROCESO INICIALIZADO";
    LET p_origen            =   1;
    LET p_anioo             =   p_anio;
    LET p_mess              =   p_mes;
    LET p_num_indicadorr    =   p_num_indicador;

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET vCodRet  = SQL_ERR;
        LET vMensaje  = ERROR_INFO;        
        RETURN vCodRet, vMensaje;
    END EXCEPTION;

    IF (p_proceso = 1) THEN
        CALL bdimonitorcob:sp_masterestad_ini(p_anioo, p_mess, p_origen)
        RETURNING vvCodRet, vvMensaje;
    ELIF (p_proceso = 2) THEN
        CALL bdimonitorcob:sp_actualiza_statusmoncob()
        RETURNING vvCodRet, vvMensaje;
    ELIF (p_proceso = 3) THEN
        CALL bdimonitorcob:sp_insertar_registros_mes(p_anioo, p_mess, p_origen)
        RETURNING vvCodRet, vvMensaje;
    ELIF (p_proceso = 4) THEN
        CALL bdimonitorcob:sp_insertar_registros_anio(p_anioo, p_mess, p_origen)
        RETURNING vvCodRet, vvMensaje;    
    ELIF (p_proceso = 5) THEN
        CALL bdimonitorcob:sp_inserta_mes_complemento(p_anioo)
        RETURNING vvCodRet, vvMensaje;
    ELIF (p_proceso = 6) THEN
        CALL bdimonitorcob:sp_inserta_anio_complemento(p_anioo)
        RETURNING vvCodRet, vvMensaje;
    ELIF (p_proceso = 7) THEN
        CALL bdimonitorcob:sp_indicadores_moncob(p_anioo, p_mess, p_num_indicadorr, p_origen)
        RETURNING vvCodRet, vvMensaje;
    ELIF (p_proceso = 8) THEN
        CALL bdimonitorcob:sp_generacomportamiento(p_anioo, p_mess, p_origen)
        RETURNING vvCodRet, vvMensaje;
    END IF

    LET vCodRet = '00000';
    LET vMensaje = 'PROCESO EXITOSO';

END

RETURN vCodRet, vMensaje;

END PROCEDURE;