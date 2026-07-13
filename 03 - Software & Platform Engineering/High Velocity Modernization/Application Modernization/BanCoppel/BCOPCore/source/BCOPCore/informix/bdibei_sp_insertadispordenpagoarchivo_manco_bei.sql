CREATE PROCEDURE "informix".sp_insertadispordenpagoarchivo_manco_bei(
        pnombre_archivo     CHAR(17),
        pf_dispersion       CHAR(10),
        pcte_empresa        CHAR(20),
        pid_empresa         CHAR(3),
        pid_oper            CHAR(4),
        pid_usuario         INTEGER,
        ptamano_archivo     INTEGER,
        ptipo_archivo       INTEGER,
        ptipo_cuentas       INTEGER,
        ptipo_oper          SMALLINT,
        pstatus_archivo     SMALLINT,
		pCantidadEmpleados	INTEGER,
		pConcepto			CHAR(30),
		pTipoDispersion		INTEGER,
		PcargoDispersion	DECIMAL(16,2),
		PtotalSinComision	DECIMAL(16,2)
)
RETURNING char(5);

    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;
 	DEFINE sIdOper INTEGER;

 	LET sIdOper=0;
 	LET cod_ret="00000";

	--SET DEBUG FILE TO "/home/informix/bibiana/sp_insertadispordenpagoarchivo_manco_bei.out";
	--TRACE ON;

BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
    END EXCEPTION ;

    SET LOCK MODE TO WAIT 4;

    INSERT INTO bei_archivos_orden_pago(nombre_archivo,f_dispersion,cte_empresa,id_empresa,
        tamano_archivo,tipo_archivo,tipo_oper,status_archivo,tipo_cuentas,
        id_usuario,id_oper,h_registro, cantidadEmpleados, concepto, tipoDispersion,
		cargoDispersion,totalSinComision)
    VALUES(pnombre_archivo,TO_DATE(pf_dispersion, '%Y-%m-%d'),pcte_empresa,pid_empresa,
        ptamano_archivo, ptipo_archivo, ptipo_oper, pstatus_archivo, ptipo_cuentas,
        pid_usuario, pid_oper, CURRENT, pCantidadEmpleados, pConcepto, pTipoDispersion,
		PcargoDispersion, PtotalSinComision);

    RETURN cod_ret;

END
END PROCEDURE;