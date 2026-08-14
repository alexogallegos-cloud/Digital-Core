CREATE PROCEDURE "informix".sp_insertoperacionesmancoctapropias_bei(
    pTransCargo char(4),
    pTransAbono char(4),
    pTransSuc char(4),
    pfoliosuc char(16),
    pcuenta_origen char(12),
    pcuenta_destino char(12),
    pimporte money(14,2),
    pmoneda char(2),
    preferencia char(40),
    pmontototal money(14,2),
    pid_usuario INTEGER,
    pid_cat_operacion INTEGER,
    pstatusoperacion CHAR(1),
	pf_aplicacion            	CHAR(10),
	pf_operacion             	CHAR(10)
)
returning char(5), INTEGER;
    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;
 	DEFINE sIdOper INTEGER;

 	LET sIdOper=0;
 	LET cod_ret="00000";
BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret,sIdOper;
      END IF ;
    END EXCEPTION ;

    SET LOCK MODE TO WAIT 4;

    IF(LENGTH(TRIM(NVL(pfoliosuc,''))) = 0) THEN
        LET cod_ret="00001";
    END IF;

    IF(LENGTH(TRIM(NVL(pcuenta_origen,''))) = 0) THEN
        LET cod_ret="00002";
    END IF;

    IF(LENGTH(TRIM(NVL(pcuenta_destino,''))) = 0) THEN
        LET cod_ret="00003";
    END IF;

    IF(LENGTH(TRIM(NVL(pmoneda,''))) = 0) THEN
        LET cod_ret="00004";
    END IF;

 --   IF(LENGTH(TRIM(NVL(preferencia,''))) = 0) THEN
 --      LET cod_ret="00005";
 --   END IF;

    IF(LENGTH(TRIM(NVL(pTransCargo,''))) = 0) THEN
        LET cod_ret="00011";
    END IF;

	IF(LENGTH(TRIM(NVL(pTransAbono,''))) = 0) THEN
        LET cod_ret="00012";
    END IF;

    IF(LENGTH(TRIM(NVL(pTransSuc,''))) = 0) THEN
        LET cod_ret="00013";
    END IF;

    IF(LENGTH(TRIM(NVL(pstatusoperacion,''))) = 0) THEN
        LET cod_ret="00028";
    END IF;

    IF(pid_cat_operacion <= 0) THEN
        LET cod_ret="00024";
    END IF;

    IF(pimporte <= 0) THEN
        LET cod_ret="00022";
    END IF;

    IF(pid_usuario <= 0) THEN
        LET cod_ret="00023";
    END IF;

    IF(pmontototal <= 0) THEN
        LET cod_ret="00027";
    END IF;

    IF(cod_ret <> '00000') THEN
        RETURN cod_ret,sIdOper;
    END IF;

    EXECUTE PROCEDURE "informix".sp_insertaoperacionesmancomunadasoperador_bei(
        pfoliosuc,
        pcuenta_origen,
        pcuenta_destino,
        pimporte,
        pmoneda,
        preferencia,
        NULL,NULL,
        TO_DATE(pf_aplicacion, '%Y-%m-%d'),
        TO_DATE(pf_operacion, '%Y-%m-%d'),
        pid_usuario,
        pid_cat_operacion,
        NULL, NULL,	NULL, NULL,
        pTransSuc,
        0, 0,
        NULL,NULL,NULL,
        0, NULL,NULL,
        pTransCargo,
        pTransAbono,
        pmontototal,
        NULL, NULL, NULL, NULL, NULL,
        pstatusoperacion,
		NULL, NULL, NULL, NULL
    ) into cod_ret,sIdOper;

    RETURN cod_ret,sIdOper;

END
END PROCEDURE;