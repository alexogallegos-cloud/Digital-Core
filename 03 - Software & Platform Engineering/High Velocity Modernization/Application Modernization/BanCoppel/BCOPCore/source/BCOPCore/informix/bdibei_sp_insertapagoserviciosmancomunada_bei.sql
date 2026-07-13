CREATE PROCEDURE "informix".sp_insertapagoserviciosmancomunada_bei(
    pempresa CHAR(3),
    psucursal_virtual CHAR(4),
    pusuario_virtual CHAR(4),
    pnumtransferenciacargo CHAR(4),
    pnumtransferenciaabono CHAR(4),
    ptransaccion_sucursal CHAR(4),
    pfoliosuc CHAR(16),
    pcuenta_origen CHAR(20),
    pcuenta_destino CHAR(20),
    pimporte MONEY,
    pmoneda CHAR(2),
    preferencia CHAR(40),
    pmontototal MONEY,
    pcategoria CHAR(2),
    pconvenio CHAR(3),
    preftelefono CHAR(20),
    prefverificador CHAR(20),
    pf_operacion CHAR(10),
    pnombre_beneficiario VARCHAR(100),
    pf_aplicacion CHAR(10),
    pid_usuario INTEGER,
    pid_cat_operacion INTEGER,
    pstatusoperacion CHAR(1)
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
            let cod_ret = sql_err;
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

    IF(LENGTH(TRIM(NVL(preferencia,''))) = 0) THEN
        LET cod_ret="00005";
    END IF;

    IF(LENGTH(TRIM(NVL(pnombre_beneficiario,''))) = 0) THEN
        LET cod_ret="00007";
    END IF;

    IF(LENGTH(TRIM(NVL(pempresa,''))) = 0) THEN
        LET cod_ret="00008";
    END IF;

    IF(LENGTH(TRIM(NVL(psucursal_virtual,''))) = 0) THEN
        LET cod_ret="00009";
    END IF;

    IF(LENGTH(TRIM(NVL(pusuario_virtual,''))) = 0) THEN
        LET cod_ret="00010";
    END IF;

    IF(LENGTH(TRIM(NVL(pnumtransferenciacargo,''))) = 0) THEN
        LET cod_ret="00011";
    END IF;

    IF(LENGTH(TRIM(NVL(pnumtransferenciaabono,''))) = 0) THEN
        LET cod_ret="00012";
    END IF;

    IF(LENGTH(TRIM(NVL(ptransaccion_sucursal,''))) = 0) THEN
        LET cod_ret="00013";
    END IF;

	IF(LENGTH(TRIM(NVL(pstatusoperacion,''))) = 0) THEN
        LET cod_ret="00028";
    END IF;

    IF(LENGTH(TRIM(NVL(pcategoria,''))) = 0) THEN
        LET cod_ret="00015";
    END IF;

    IF(LENGTH(TRIM(NVL(pconvenio,''))) = 0) THEN
        LET cod_ret="00016";
    END IF;

    IF(LENGTH(TRIM(NVL(preftelefono,''))) = 0) THEN
        LET cod_ret="00017";
    END IF;

    IF(LENGTH(TRIM(NVL(prefverificador,''))) = 0) THEN
        LET cod_ret="00018";
    END IF;

	IF(pimporte <= 0) THEN
        LET cod_ret="00022";
    END IF;

	IF(pid_usuario <= 0) THEN
        LET cod_ret="00023";
    END IF;

	IF(pid_cat_operacion <= 0) THEN
        LET cod_ret="00024";
    END IF;

	IF( pf_aplicacion IS NULL) THEN
        LET cod_ret="00025";
    END IF;

	IF(pf_operacion IS NULL) THEN
        LET cod_ret="00026";
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
        NULL,
        pnombre_beneficiario,
        TO_DATE(pf_aplicacion, '%Y-%m-%d'),
        TO_DATE(pf_operacion, '%Y-%m-%d'),
        pid_usuario,
        pid_cat_operacion,
        pempresa,
        psucursal_virtual,
        pusuario_virtual,
        0,
        ptransaccion_sucursal,
        0, 0, NULL,
        NULL, NULL,0,
        NULL,  NULL,pnumtransferenciacargo, pnumtransferenciaabono,
        pmontototal,
        pcategoria,
        pconvenio,
        preftelefono,
        prefverificador,
        null,
        pstatusoperacion,
		NULL,  NULL,NULL, NULL) INTO cod_ret,sIdOper;		
		

    RETURN cod_ret,sIdOper;


END

END PROCEDURE;