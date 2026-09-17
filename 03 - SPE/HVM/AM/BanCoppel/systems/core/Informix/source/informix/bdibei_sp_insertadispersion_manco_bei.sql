CREATE PROCEDURE "informix".sp_insertadispersion_manco_bei(
        pf_aplicacion       CHAR(10),
        pcuenta_origen      CHAR(12),
        pnombre_archivo     CHAR(17),
        pf_dispersion       CHAR(10),
        pcte_empresa        CHAR(20),
        pid_empresa         CHAR(3),
        pid_catOperacion    INTEGER,
        pid_usuario         INTEGER,
        ptamano_archivo     INTEGER,
        ptipo_archivo       INTEGER,
        ptipo_cuentas       INTEGER,
        ptipo_oper          SMALLINT,
        pstatus_archivo     SMALLINT,
        pmontoTotal         MONEY(14,2),
		piva				MONEY(14,2),
		pivaComsion			MONEY(14,2),
		pComsion			MONEY(14,2),
		pCantidadEmpleados	INTEGER,
		pConcepto			CHAR(10),
		pTipoDispersion		INTEGER	,
		PcargoDispersion	DECIMAL,
		PtotalSinComision	DECIMAL,
        pMotivoPago         CHAR(30)
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

    IF(LENGTH(TRIM(NVL(pnombre_archivo,''))) = 0) THEN
        LET cod_ret="00003"; -- pnombre_archivo Invalida
    END IF;

    IF(LENGTH(TRIM(NVL(pf_dispersion,''))) = 0) THEN
        LET cod_ret="00004"; -- pf_dispersion Invalida
    END IF;

    IF(LENGTH(TRIM(NVL(pcte_empresa,''))) = 0) THEN
        LET cod_ret="00005"; -- pcte_empresa Invalida
    END IF;

    IF(LENGTH(TRIM(NVL(pid_empresa,''))) = 0) THEN
        LET cod_ret="00006"; -- pid_empresa Invalida
    END IF;

    IF(NVL(pid_catOperacion, -1) <= 0) THEN
        LET cod_ret="00008";
    END IF;

    IF(NVL(pid_usuario, -1) <= 0) THEN
        LET cod_ret="00009";
    END IF;

    IF(NVL(ptamano_archivo, -1) <= 0) THEN
        LET cod_ret="00010";
    END IF;

    IF(NVL(ptipo_archivo, -1) <= 0) THEN
        LET cod_ret="00011";
    END IF;

    IF(NVL(ptipo_cuentas, -1) <= 0) THEN
        LET cod_ret="00012";
    END IF;

    IF(NVL(pstatus_archivo, -1) <= 0) THEN
        LET cod_ret="00014";
    END IF;

    IF(NVL(pmontoTotal, -1) <= 0) THEN
        LET cod_ret="00015";
    END IF;

	IF(NVL(piva, -1) <= -1) THEN
        LET cod_ret="00016";
    END IF;

	IF(NVL(pivaComsion, -1) < 0) THEN
        LET cod_ret="00017";
    END IF;

	IF(NVL(pComsion, -1) < 0) THEN
        LET cod_ret="00018";
    END IF;

	IF(NVL(pCantidadEmpleados, -1) <= 0) THEN
        LET cod_ret="00019";
    END IF;

	IF(LENGTH(TRIM(NVL(pConcepto,''))) = 0)THEN
        LET cod_ret="00008";
    END IF;

	IF(NVL(PcargoDispersion, -1) < 0) THEN
        LET cod_ret="00020";
    END IF;

	IF(NVL(pTipoDispersion, -1) < 0) THEN
        LET cod_ret="00021";
    END IF;

	IF(NVL(PtotalSinComision, -1) < 0) THEN
        LET cod_ret="00022";
    END IF;



    IF(cod_ret <> '00000') THEN
        RETURN cod_ret,sIdOper;
    END IF;

    EXECUTE PROCEDURE "informix".sp_insertadispersionarchivo_manco_bei(
        pnombre_archivo,pf_dispersion,pcte_empresa,
        pid_empresa,sIdOper,pid_usuario,ptamano_archivo,
        ptipo_archivo,ptipo_cuentas,ptipo_oper,pstatus_archivo,
		pCantidadEmpleados, pConcepto, pTipoDispersion,
		PcargoDispersion,PtotalSinComision, pMotivoPago
    ) INTO cod_ret;


    IF(cod_ret <> '00000') THEN
        RETURN cod_ret,sIdOper;
    END IF;


     EXECUTE PROCEDURE "informix".sp_insertaoperacionesmancomunadasoperador_bei(
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
        pnombre_archivo,
        'P',
        NULL, NULL, NULL, NULL
    )INTO cod_ret,sIdOper;

    IF(cod_ret <> '00000') THEN
        DELETE "informix".bei_archivos where nombre_archivo=pnombre_archivo;
        RETURN cod_ret,sIdOper;
    END IF;

	UPDATE "informix".bei_archivos SET id_oper=sIdOper WHERE nombre_archivo=pnombre_archivo;

    RETURN cod_ret,sIdOper;

END
END PROCEDURE;