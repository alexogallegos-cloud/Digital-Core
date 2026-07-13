CREATE PROCEDURE "informix".sp_insertadisp_orden_pago_manco_bei(
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
		pConcepto			CHAR(30),
		pTipoDispersion		INTEGER	,
		PcargoDispersion	DECIMAL,
		PtotalSinComision	DECIMAL
)
RETURNING char(5), INTEGER;

--****************************************************************************************************
-- MODIFICACION: INC03527 EmpresaNet - DispersiÃ³n ODP - Cardiff
-- AUTOR : Gabriela Aguilar
-- -- FECHA DE MODIFIACION: 2025/12/11
-- Se agrega validaciÃ³n para que el dato de ID Empresa solo se solicite para las operaciones de NÃ³mina
--****************************************************************************************************

DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;
 	DEFINE sIdOper INTEGER;

 	LET sIdOper=0;
 	LET cod_ret="00000";

	--SET DEBUG FILE TO "/home/c96120053/Empresanet/Ordendepago/OUTS/sp_insertadisp_orden_pago_manco_bei.out";
	--TRACE ON;

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
	
	
	IF pid_catOperacion not in ('3003','3004','3005') then
		IF(LENGTH(TRIM(NVL(pid_empresa,''))) = 0) THEN
			LET cod_ret="00006"; -- pid_empresa Invalida
		END IF;
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

	IF NOT EXISTS(SELECT * FROM "informix".bei_archivos WHERE nombre_archivo = pnombre_archivo AND cte_empresa = pcte_empresa AND id_empresa = pid_empresa AND id_usuario = pid_usuario) THEN
		INSERT INTO "informix".bei_archivos(nombre_archivo, f_dispersion, cte_empresa, id_empresa, tamano_archivo, tipo_archivo, tipo_oper, status_archivo, tipo_cuentas, id_usuario, id_oper, h_registro, cantidadempleados, concepto, tipodispersion, cargodispersion, totalsincomision)
		VALUES(pnombre_archivo,TO_DATE(pf_dispersion, '%Y-%m-%d'), pcte_empresa,pid_empresa,ptamano_archivo,ptipo_archivo,ptipo_oper, pstatus_archivo,ptipo_cuentas,pid_usuario, sIdOper, CURRENT, pCantidadEmpleados,pConcepto,pTipoDispersion,PcargoDispersion,PtotalSinComision);
	
	END IF;
	
  EXECUTE PROCEDURE sp_insertadispordenpagoarchivo_manco_bei(
        pnombre_archivo,pf_dispersion,pcte_empresa,
        pid_empresa,sIdOper,pid_usuario,ptamano_archivo,
        ptipo_archivo,ptipo_cuentas,ptipo_oper,pstatus_archivo,
		pCantidadEmpleados, pConcepto, pTipoDispersion,
		PcargoDispersion,PtotalSinComision
    ) INTO cod_ret;


    IF(cod_ret <> '00000') THEN
        RETURN cod_ret,sIdOper;
    END IF;


     EXECUTE PROCEDURE sp_insertaoperacionesmancomunadasoperador_bei(
        NULL,
        pcuenta_origen, NULL,
        PtotalSinComision, NULL, pConcepto, NULL, NULL,
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
        DELETE bei_archivos_orden_pago where nombre_archivo=pnombre_archivo and cte_empresa=pcte_empresa;
        RETURN cod_ret,sIdOper;
    END IF;

	UPDATE bei_archivos_orden_pago SET id_oper=sIdOper WHERE nombre_archivo=pnombre_archivo and cte_empresa=pcte_empresa;
	UPDATE bei_archivos SET id_oper=sIdOper WHERE nombre_archivo=pnombre_archivo and cte_empresa=pcte_empresa;

    RETURN cod_ret,sIdOper;

END
END PROCEDURE;