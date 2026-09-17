CREATE PROCEDURE "informix".sp_ejecuta_cat(p_proceso INTEGER, pEmpresa char(3), cfecha_insert DATE, vtipo_cobranza CHAR(1), pSeparador CHAR(1))
                                                            RETURNING char(6), char(150);

DEFINE v_concepto           CHAR(3);
DEFINE vCodRet              CHAR(6);
DEFINE vMensaje             CHAR(150);
DEFINE sql_err              INTEGER;
DEFINE ISAM_ERR             INTEGER;
DEFINE error_info           CHAR(150);
DEFINE ptipo_cobranza       CHAR(1);
DEFINE vvCodRet             CHAR(6);
DEFINE vvMensaje            CHAR(150);

    --SET DEBUG FILE TO "/tmp/sp_ejecuta_monitor.out";
    --TRACE ON; 

    LET vCodRet             =   "11111";
    LET vMensaje            =   "PROCESO INICIALIZADO";
    LET ptipo_cobranza      =   vtipo_cobranza;

BEGIN

    ON EXCEPTION SET Sql_err, isam_err, error_info
        LET vcodret  = sql_err;
        LET vmensaje  = error_info;        
        RETURN vCodRet, vMensaje;
    END EXCEPTION;
  
    IF (p_proceso = 1) THEN
       
        CALL bdicobranza:"informix".sp_cat_gen_info_admin()
        RETURNING vvCodRet, vvMensaje;

    ELIF (p_proceso = 2) THEN

        CALL bdicobranza:"informix".sp_cat_arch_cartbase(pSeparador)
        RETURNING vvCodRet, vvMensaje;
        
    ELIF (p_proceso = 3) THEN

        CALL bdicobranza:"informix".sp_cat_gen_info_prev()
        RETURNING vvCodRet, vvMensaje;
       
    ELIF (p_proceso = 4) THEN
    
        CALL bdicobranza:"informix".sp_cat_traspasodirectorio_cte(cfecha_insert, vtipo_cobranza)
        RETURNING vvCodRet, vvMensaje;
                
    ELIF (p_proceso = 5) THEN

        CALL bdicobranza:"informix".sp_cat_auronix_target_phone()
        RETURNING vvCodRet, vvMensaje;

    ELIF (p_proceso = 6) THEN

        CALL bdicobranza:"informix".sp_cat_tipologicacte(pEmpresa, ptipo_cobranza)
        RETURNING vvCodRet, vvMensaje;

    /*ELIF (p_proceso = 7) THEN

        CALL bdimonitorcob:sp_pagos_monto_prom_mes(v_anio, v_mes, p_num_credito, p_origen)
        RETURNING vvCodRet, vvMensaje;

    ELIF (p_proceso = 8) THEN

        CALL bdimonitorcob:sp_generaconsumo(pMes, pAnio)
        RETURNING vv_codret, vv_mensaje;

    ELIF (p_proceso = 9) THEN

        CALL bdimonitorcob:sp_generacomportamiento(pMess, pAnios, p_num_credito, p_origen)
        RETURNING vv_codret, vv_mensaje;*/

    END IF

    LET vCodRet = '00000';
    LET vMensaje = 'PROCESO EXITOSO';

END

RETURN vCodRet, vMensaje;

END PROCEDURE;