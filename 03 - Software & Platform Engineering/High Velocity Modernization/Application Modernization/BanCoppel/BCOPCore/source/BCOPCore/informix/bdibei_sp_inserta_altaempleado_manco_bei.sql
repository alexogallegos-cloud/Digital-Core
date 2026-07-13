CREATE PROCEDURE "informix".sp_inserta_altaempleado_manco_bei(
    pnumero_empleado INTEGER,
    pnombre_empleado VARCHAR(100),
    papellidos_pat_empleado VARCHAR(100),
	papellidos_mat_empleado VARCHAR(100),
    pcuenta_destino CHAR(12),
    pclave_banco INTEGER,
    pid_usuario INTEGER
)
RETURNING CHAR(5), INTEGER;

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
    
    
    IF(LENGTH(TRIM(NVL(pnombre_empleado,''))) = 0) THEN
        LET cod_ret="00001";
    END IF;
	
	IF(LENGTH(TRIM(NVL(pnombre_empleado,''))) = 0) THEN
        LET cod_ret="00002";
    END IF;

    IF(LENGTH(TRIM(NVL(papellidos_pat_empleado,''))) = 0) THEN
        LET cod_ret="00003";
    END IF;
    
    IF(LENGTH(TRIM(NVL(papellidos_mat_empleado,''))) = 0) THEN
        LET cod_ret="00005";
    END IF;    

    IF(LENGTH(TRIM(NVL(pcuenta_destino,''))) = 0) THEN
        LET cod_ret="00006";
    END IF;    

    IF(pid_usuario<= 0) THEN
        LET cod_ret="00008";
    END IF;    

    IF(pnumero_empleado <= 0) THEN
        LET cod_ret="00008";
    END IF;

    IF(pclave_banco <= 0) THEN
        LET cod_ret="00009";
    END IF;

    IF(cod_ret <> '00000') THEN
        RETURN cod_ret,sIdOper;
    END IF;

    EXECUTE PROCEDURE "informix".sp_insertaoperacionesmancomunadasoperador_bei(
        NULL,
        NULL,
        pcuenta_destino,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        TODAY,
        TODAY,
        pid_usuario,
        NULL,
        NULL,
        NULL,
        NULL,
        pclave_banco,
        NULL,
        NULL, NULL, NULL,
        NULL, NULL, NULL,
        NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL,
        NULL, null, NULL,
        pnumero_empleado,
        pnombre_empleado ,
        papellidos_pat_empleado,
        papellidos_mat_empleado) INTO cod_ret,sIdOper;

    RETURN cod_ret,sIdOper;

    
    
END
END PROCEDURE;