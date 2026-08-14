CREATE PROCEDURE "informix".sp_insertadispersion_manco_odp_bei(
        pf_aplicacion       CHAR(10),
        pcuenta_origen      CHAR(12),
        pid_empresa         CHAR(3),
        pid_catOperacion    INTEGER,
        pid_usuario         INTEGER,
        pmontoTotal         MONEY(14,2),
		piva				MONEY(14,2),
		pivaComsion			MONEY(14,2),
		pComsion			MONEY(14,2),
		PtotalSinComision	DECIMAL
)
RETURNING char(5), INTEGER;

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

    IF(LENGTH(TRIM(NVL(pf_aplicacion,''))) = 0) THEN
        LET cod_ret="00001"; -- pf_aplicacion Invalida
    END IF;

    IF(LENGTH(TRIM(NVL(pcuenta_origen,''))) = 0) THEN
        LET cod_ret="00002"; -- pcuenta_origen Invalida
    END IF;

    IF(LENGTH(TRIM(NVL(pid_empresa,''))) = 0) THEN
        LET cod_ret="00003"; -- pid_empresa Invalida
    END IF;

    IF(NVL(pid_catOperacion, -1) <= 0) THEN
        LET cod_ret="00004";
    END IF;

    IF(NVL(pid_usuario, -1) <= 0) THEN
        LET cod_ret="00005";
    END IF;

    IF(NVL(pmontoTotal, -1) <= 0) THEN
        LET cod_ret="00006";
    END IF;

	IF(NVL(piva, -1) <= -1) THEN
        LET cod_ret="00007";
    END IF;

	IF(NVL(pivaComsion, -1) < 0) THEN
        LET cod_ret="00008";
    END IF;

	IF(NVL(pComsion, -1) < 0) THEN
        LET cod_ret="00009";
    END IF;

	IF(NVL(PtotalSinComision, -1) < 0) THEN
        LET cod_ret="00010";
    END IF;

    IF(cod_ret <> '00000') THEN
        RETURN cod_ret,sIdOper;
    END IF;


     EXECUTE PROCEDURE sp_insertaoperacionesmancomunadasoperador_bei(
        NULL,
        pcuenta_origen, NULL,
        PtotalSinComision, NULL, NULL, NULL, NULL,
        TO_DATE(pf_aplicacion, '%Y-%m-%d'),
        TODAY,
        pid_usuario,
        pid_catOperacion,
        pid_empresa,
        NULL, NULL, NULL, NULL, pComsion,
        pivaComsion, NULL, NULL,  NULL, piva,
        NULL, NULL, NULL, NULL, pmontoTotal,
        NULL, NULL, NULL, NULL,
        NULL,
        'P',
        NULL, NULL, NULL, NULL
    )INTO cod_ret,sIdOper;

    RETURN cod_ret,sIdOper;

END
END PROCEDURE;