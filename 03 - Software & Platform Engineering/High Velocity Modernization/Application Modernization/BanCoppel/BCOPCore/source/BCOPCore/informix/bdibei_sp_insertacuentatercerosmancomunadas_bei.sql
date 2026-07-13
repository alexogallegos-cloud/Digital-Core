CREATE PROCEDURE "informix".sp_insertacuentatercerosmancomunadas_bei(
    pfoliosuc                	CHAR(16),
    pcuenta_origen           	CHAR(12),
	pcuenta_destino          	CHAR(12),
    pimporte                 	MONEY(14,2),
	pmoneda                  	CHAR(2),
	preferencia              	CHAR(40),
	preferenciabe            	CHAR(40),
	pnombre_beneficiario     	VARCHAR(100),
	pf_aplicacion            	CHAR(10),
	pf_operacion             	CHAR(10),
	pid_usuario              	INTEGER,
	pid_cat_operacion        	INTEGER,
	pstatusoperacion         	CHAR(1)
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

  --  IF(LENGTH(TRIM(NVL(preferencia,''))) = 0) THEN
  --      LET cod_ret="00005";
  --  END IF;

--    IF(LENGTH(TRIM(NVL(preferenciabe,''))) = 0) THEN
--        LET cod_ret="00006";
--    END IF;

    IF(LENGTH(TRIM(NVL(pnombre_beneficiario,''))) = 0) THEN
        LET cod_ret="00007";
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

    IF( pf_aplicacion IS NULL) THEN
        LET cod_ret="00025";
    END IF;

    IF(pf_operacion IS NULL) THEN
        LET cod_ret="00026";
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
        preferenciabe,
        pnombre_beneficiario,
        TO_DATE(pf_aplicacion, '%Y-%m-%d'),
        TO_DATE(pf_operacion, '%Y-%m-%d'),
        pid_usuario,
        pid_cat_operacion,
        NULL, NULL, NULL,
        0, NULL,0,0, NULL,
        NULL, NULL,0, NULL,
        NULL, NULL, NULL,
        pimporte, NULL, NULL,
        NULL, NULL, NULL, pstatusoperacion, NULL, NULL, NULL, NULL) INTO cod_ret,sIdOper;

    RETURN cod_ret,sIdOper;
END

END PROCEDURE;