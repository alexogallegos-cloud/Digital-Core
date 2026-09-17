CREATE PROCEDURE "informix".sp_insertatransferenciaspei_bei(
    pempresa CHAR(3),
    psucursal_virtual CHAR(4),
    pusuario_virtual CHAR(4),
    pclave_banco INTEGER,
    pimporte MONEY(14,2),

    ptransaccion_sucursal CHAR(4),
    pfoliosuc CHAR(16),
    pf_operacion CHAR(10),
    pcomision MONEY(14,2),
    pivacomision MONEY(14,2),
    pnombre_usuario VARCHAR(40),


    pcuenta_origen CHAR(20),
    prfc VARCHAR(18),
    pnombre_beneficiario VARCHAR(100),
    ptipo_cuenta_beneficiario VARCHAR(40),
    pcuenta_destino CHAR(20),

    preferencia CHAR(40),
    pvalor_iva MONEY(14,2),
    preferencia_cobranza CHAR(40),
    pbanco_receptor VARCHAR(100),
    pmontototal MONEY(14,2),
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

--	IF(LENGTH(TRIM(NVL(preferencia,''))) = 0) THEN
--        LET cod_ret="00005";
--    END IF;

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

	IF(LENGTH(TRIM(NVL(ptransaccion_sucursal,''))) = 0) THEN
        LET cod_ret="00013";
    END IF;

	IF(LENGTH(TRIM(NVL(pnombre_usuario,''))) = 0) THEN
        LET cod_ret="00018";
    END IF;

	IF(LENGTH(TRIM(NVL(prfc,''))) = 0) THEN
        LET cod_ret="00019";
    END IF;

	IF(LENGTH(TRIM(NVL(preferencia_cobranza,''))) = 0) THEN
        LET cod_ret="00020";
    END IF;

	IF(LENGTH(TRIM(NVL(ptipo_cuenta_beneficiario,''))) = 0) THEN
        LET cod_ret="00021";
    END IF;

    IF(LENGTH(TRIM(NVL(pbanco_receptor,''))) = 0) THEN
        LET cod_ret="00030";
    END IF;

    IF(LENGTH(TRIM(NVL(pstatusoperacion,''))) = 0) THEN
        LET cod_ret="00028";
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

    IF(LENGTH(TRIM(NVL(pf_aplicacion,''))) = 0) THEN
        LET cod_ret="00025";
    END IF;

    IF(pf_operacion IS NULL) THEN
        LET cod_ret="00026";
    END IF;

	IF(pmontototal <= 0) THEN
        LET cod_ret="00027";
    END IF;

	IF(pclave_banco <= 0) THEN
        LET cod_ret="00029";
    END IF;

	--IF(pcomision <= 0) THEN
     --   LET cod_ret="00031";
 --END IF;
--	IF(pivacomision <= 0) THEN
  --      LET cod_ret="00032";
    --END IF;

	IF(pvalor_iva <= 0) THEN
        LET cod_ret="00032";
    END IF;

    IF(cod_ret <> '00000') THEN
        RETURN cod_ret,sIdOper;
    END IF;

    EXECUTE PROCEDURE "informix".sp_insertaoperacionesmancomunadasoperador_bei(
        pfoliosuc,
        pcuenta_origen,
        pcuenta_destino,
        pimporte,
        NULL,
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
        pclave_banco,
        ptransaccion_sucursal,
        pcomision,
        pivacomision,
        pnombre_usuario,
        prfc,
        ptipo_cuenta_beneficiario,
        pvalor_iva,
        preferencia_cobranza,
        pbanco_receptor,
        NULL,NULL,
        pmontototal,
        NULL,
        NULL,
        NULL,NULL,NULL,
        pstatusoperacion,
		NULL, NULL, NULL, NULL
	) INTO cod_ret,sIdOper;

    RETURN cod_ret,sIdOper;


END

END PROCEDURE;