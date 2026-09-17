CREATE PROCEDURE "informix".sp_cat_ctes_activ_bnca_movil(pEmpresa CHAR(3))

RETURNING 
          CHAR(06) AS resultado,    CHAR(80) AS mensaje;

-- Octubre 2012. MAHR Base de datos de Clientes paa la campaña del CAT: Activacion de Bancoppel Movil.

DEFINE vproceso         CHAR(4);
DEFINE cCod_RetIB       CHAR(6);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE dFechaHoy        DATE;
DEFINE dtFechaIni       DATE;
DEFINE dtFechaFin       DATE;
DEFINE cRutaArch        CHAR(100);
DEFINE cNomArchivo      CHAR(100);
DEFINE cNomArch         CHAR(100);
DEFINE cNomArch1        CHAR(100);
DEFINE cNomArchEjecSql  CHAR(100);
DEFINE cSQL             CHAR(8204);
DEFINE cSQL1            CHAR(500);
DEFINE cSQL2            CHAR(6204);
DEFINE cSQL3            CHAR(100);
DEFINE vNoDiasRango     SMALLINT;
DEFINE vRegistrosLimit	INTEGER;
DEFINE vTot_Registros   INTEGER;
DEFINE viPrioridad      INTEGER;
DEFINE cNum_dia         CHAR(2);
DEFINE cNum_mes         CHAR(2);
DEFINE cNum_anio        CHAR(4);
DEFINE cNum_cred        CHAR(20);
DEFINE cNum_cte         CHAR(20);
DEFINE cNumTel          CHAR(13);


--SET DEBUG FILE TO "/informix/mahr/sp_cat_ctes_activ_bnca_movil.out";
--TRACE ON;

LET vproceso        = '0065';
LET cCod_RetIB      = '000000';
LET cMensajeRet     = 'PROCESO EXITOSO';    
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = '000000';
LET dFechaHoy       = DATE(0); 
LET cRutaArch       = '';
LET cNomArchivo     = '';
LET cNomArch        = '';
LET cNomArch1       = '';
LET cNomArchEjecSql = '';
LET cSQL            = '';
LET cSQL1           = '';
LET cSQL2           = '';
LET cSQL3           = '';
LET vNoDiasRango    = 0;
LET vRegistrosLimit = 0;
LET vTot_Registros  = 0;
LET viPrioridad     = 0;
LET cNum_dia        = '';
LET cNum_mes        = '';
LET cNum_anio       = '';
LET cNum_cred       = '';
LET cNum_cte        = '';
LET cNumTel         = '';


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet = iSqlErr;
        LET cMensajeRet = cErrorInfo;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '01') Returning cCod_RetIB;

    IF ( NVL(pEmpresa,"") = "" ) THEN
        LET cCodRet= '102005'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas WHERE empresa = pempresa;
    IF ( dFechaHoy IS NULL ) THEN
        LET cCodRet= '20013'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    SELECT valor_numerico INTO vNoDiasRango  -- Parametro para obtener el no de dias para rango de fechas
        FROM bdicobranza:cb_param_campania WHERE grupo_parametro = 'CAT_PROMOS' AND num_parametro = 4;
	IF vNoDiasRango = 0 THEN
        LET cCodRet = '104001';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;

    LET dtFechaIni = dFechaHoy - vNoDiasRango units day;
	LET dtFechaFin = dFechaHoy;

    LET cNum_dia = lpad(day(dFechaHoy),2,'0');
    LET cNum_mes =  lpad(month(dFechaHoy),2,'0');
    LET cNum_anio = lpad(year(dFechaHoy),4,'0');
    LET cNum_anio = substr(year(dFechaHoy),3,2);


    SELECT NVL(valor_numerico::INTEGER,0) INTO vRegistrosLimit  -- Parametro de No de registros limite
        FROM bdicobranza:cb_param_campania WHERE grupo_parametro = 'CAT_PROMOS' AND num_parametro = 3;
	IF vRegistrosLimit = 0 THEN
        LET cCodRet = '104001';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT trim(valor_alfabetico) INTO cRutaArch      -- Ruta destino del archivo (misma ruta de PP autorizado sin utilizar)
        FROM bdicred:sd_param_campania WHERE tipo_campania = 50 AND num_parametro = 2;
	IF NVL (cRutaArch,'') = '' THEN
        LET cCodRet = '104005';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT trim(valor_alfabetico) INTO cNomArchivo    -- Nombre de Archivo
        FROM bdicobranza:cb_param_campania WHERE grupo_parametro = 'CAT_PROMOS' and num_parametro = 1;
	IF NVL (cNomArchivo,'') = '' THEN
        LET cCodRet= '104006';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    -- Elimina registros en tablas de consultas previas
    DELETE FROM bdinteg:si_telefonos_nvo_layout_cat WHERE grupo_archivos = 'CTEBCA_MOV';
    DELETE FROM bdinteg:si_clientes_nvo_layout_cat WHERE grupo_archivos = 'CTEBCA_MOV';

    -- Genera informacion en tablas de los clientes con las caracteristicas indicadas.
    INSERT INTO bdinteg:"informix".si_clientes_nvo_layout_cat
      SELECT LIMIT vRegistrosLimit 'CTEBCA_MOV' gpo_arch, 'ABM' prom, 10 tip_log, dFechaHoy fhhoy, bmus.folio_contrato, bmus.suc_registra, bmus.numcte, 
        NVL(tar.num_tarjeta,'0') tarj, 0 statusprom, 0 prioridad, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, 
        ctf.sexo sexo, ctf.estado_civil, '' c_email, est.estado, cat.municipiozona, fech_registro fh_serv, date(1)
        FROM bdinteg:si_bm_usuarios bmus
        JOIN bdinteg:si_cliente cte ON (bmus.empresa = cte.empresa AND bmus.numcte = cte.numcte)
        JOIN bdinteg:si_ctepf ctf ON (bmus.numcte = ctf.numcte)
        JOIN bdinteg:si_direcciones_actual dir1 ON (bmus.numcte = dir1.numcte AND dir1.tipo_dir = '1')
        JOIN bdisolic:ss_circulo_edos est ON (dir1.estado = est.clave)
        JOIN bdinteg:si_catzonas cat ON ( dir1.numerociudad = cat.numerociudad AND dir1.numerocolonia = cat.numerocolonia )
        LEFT OUTER JOIN bdicred:sd_tarjeta tar ON (bmus.empresa = tar.empresa AND bmus.numcte = tar.numcte AND tar.tipo_tarjeta = 'T' 
                            AND tar.secuencia = (select max(secuencia) from bdicred:sd_tarjeta where bmus.empresa = empresa
                            and bmus.numcte = numcte and tipo_tarjeta = 'T'))
        WHERE bmus.empresa = pEmpresa AND bmus.id_status = 20
        AND DATE(bmus.fech_registro) BETWEEN dtFechaIni AND dtFechaFin;

    -- Obtiene los telefonos de los clientes involucrados.
    INSERT INTO bdinteg:"informix".si_telefonos_nvo_layout_cat
        SELECT 'CTEBCA_MOV', bc_mov.num_credito_solic, bc_mov.numcte, tel.tipo_tel::CHAR, decode(tel.tipo_tel,1,'F',2,'M','F') tipo_red, 
                substr(tel.telefono,length(tel.telefono)-9,10) telefono_original, substr(tel.telefono,length(tel.telefono)-9,10) telefono_Reconstruido, 
                NVL(tel.carrier,''), NVL(tel.extension, '')
        FROM bdinteg:si_clientes_nvo_layout_cat bc_mov JOIN bdinteg:si_telefonos_actual tel ON (bc_mov.numcte = tel.numcte)
        WHERE bc_mov.grupo_archivos = 'CTEBCA_MOV' AND tel.status_tel = 'A' AND tel.cofetel = 'V' AND trim(tel.telefono) <> '' 
												   AND tel.tipo_tel IN (1,2,3);

    -- Obtiene los telefonos de referencia casa. (Tipo 4)
    FOREACH
        SELECT cte.num_credito_solic, cte.numcte INTO cNum_cred, cNum_cte
        FROM bdinteg:si_clientes_nvo_layout_cat cte JOIN bdinteg:si_refdirecciones refdir ON (cte.numcte = refdir.numcte)
        WHERE cte.grupo_archivos = 'CTEBCA_MOV' AND refdir.tipo_dir = '1' AND refdir.tipo_telef1 = 'P' AND refdir.ind_cofeteltel1 = 'V'
        AND trim(refdir.telefono1) <> ''
        GROUP BY cte.num_credito_solic, cte.numcte

        SELECT telefono1 INTO cNumTel FROM bdinteg:si_refdirecciones WHERE numcte = cNum_cte
            AND tipo_dir = '1' AND tipo_telef1 = 'P' AND ind_cofeteltel1 = 'V' 
            AND secuencia = (Select max(secuencia) from bdinteg:si_refdirecciones where numcte = cNum_cte and tipo_dir = '1' 
                            and tipo_telef1 = 'P' and ind_cofeteltel1 = 'V');

        INSERT INTO bdinteg:si_telefonos_nvo_layout_cat VALUES('CTEBCA_MOV', cNum_cred, cNum_cte, '4', 'F', cNumTel,cNumTel,0,'');

    END FOREACH;

	-- Elimina registros de clientes de los que no se obtuvieron telefonos.
    DELETE FROM bdinteg:"informix".si_clientes_nvo_layout_cat 
        WHERE grupo_archivos = 'CTEBCA_MOV' 
        AND numcte NOT IN (Select numcte From bdinteg:"informix".si_telefonos_nvo_layout_cat where grupo_archivos = 'CTEBCA_MOV' group by numcte);

    IF ( SELECT COUNT(*) FROM bdinteg:si_clientes_nvo_layout_cat WHERE grupo_archivos = 'CTEBCA_MOV' ) = 0 THEN 
        LET cMensajeRet = 'SIN INFORMACION';
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;    
    END IF

    -- Actualiza el numero de prioridad segun el mas actual
    LET viPrioridad = 1;
    FOREACH
        SELECT numcte, num_credito_solic INTO cNum_cte, cNum_cred 
            FROM bdinteg:"informix".si_clientes_nvo_layout_cat WHERE grupo_archivos = 'CTEBCA_MOV' 
            ORDER BY fecha_autorizacion DESC

        UPDATE bdinteg:"informix".si_clientes_nvo_layout_cat SET prioridad = viPrioridad 
                    WHERE grupo_archivos = 'CTEBCA_MOV'  AND numcte = cNum_cte AND num_credito_solic = cNum_cred;
       
        LET viPrioridad = viPrioridad + 1;
    END FOREACH;

    -- Obtiene el numero total de registros generados
    SELECT count(*) INTO vTot_Registros FROM bdinteg:si_clientes_nvo_layout_cat WHERE grupo_archivos = 'CTEBCA_MOV';
	
    --- GENER ARCHIVO DEL REPORTE CON DATOS DE LOS CLIENTES
    LET cNomArch1 =  TRIM(cNomArchivo) || '_Aux_' || TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
    LET cNomArch  =  TRIM(cNomArchivo) || '_' || vTot_Registros || '_'|| TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
    LET cNomArchEjecSql = 'Rep_ctes_act_bnca_mov.sql';

    LET cSQL ='';
	LET cSQL = ' echo "Tipo Promocion;Tipo Logica;Fecha Insercion;Numero Solicitud;Sucursal;Numero de Cliente;Numero Tarjeta;Status Prom;Prioridad;Apellido Paterno;Apellido Materno;Primer Nombre;Segundo Nombre;Sexo;Estado Civil;Email;Estado;Municipio;Fecha Solicitud Servicio;Fecha Activacion Servicio;Tiene TDC;Tiene Cta Captacion;Servicio por Internet;Activo Servicio de Internet;"> ' || TRIM(cRutaArch) || TRIM(cNomArch);
    SYSTEM cSQL;

	LET cSQL1 = '';
    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRutaArch) || TRIM(cNomArch1) || ' DELIMITER ' || ''';''' ;

    LET cSQL2 = ''; 
    LET cSQL2 = " SELECT trim(ctes.tipo_promocion), ctes.tipo_logica, ctes.fecha, ctes.num_credito_solic, ctes.sucursal, ctes.numcte, "
            || " nvl(substr(trim(ctes.num_tarjeta),13),'0') num_tar, ctes.statusprom, ctes.prioridad, ctes.apell_paterno, "
            || " ctes.apell_materno, ctes.nombre1, ctes.nombre2, ctes.sexo, ctes.estado_civil, "
            || " nvl((Select trim(corr.correo_elec) from bdinteg:si_correos corr Where ctes.numcte = corr.numcte and corr.status_correo = 'A' "
            || " and corr.secuencia = (Select max(secuencia) from bdinteg:si_correos Where ctes.numcte = numcte and status_correo = 'A')),'') correo, "
            || " ctes.estado, ctes.municipio, ctes.fecha_autorizacion fch_sol_serv, '' fh_activ,  "
            || " (CASE WHEN trim(ctes.num_tarjeta) = '0' THEN 'NO' ELSE 'SI' END ) tiene_tarj, "
            || " (CASE WHEN (Select count(mae.num_cte) from bdicheq:sc_maechq mae Where  ctes.numcte = mae.num_cte and "
            || " mae.status_cta in (1,3,4,5,6,7,8)) > 0 THEN 'SI' "
            || " ELSE 'NO' END) cta_capta, (CASE WHEN (Select servicio from bdinteg:si_bpiusuarios inter Where ctes.numcte = inter.numcte) = 1 "
            || " THEN 'BASICO' ELSE 'AVANZADO' END) serv_inter, "
            || " (CASE WHEN (Select count(inter.numcte) from bdinteg:si_bpiusuarios inter where ctes.numcte = inter.numcte "
            || "  and id_status = 30 ) = 1 THEN 'SI' ELSE 'NO' END) serv_int_act " 
            || "  FROM bdinteg:si_clientes_nvo_layout_cat ctes WHERE ctes.grupo_archivos = 'CTEBCA_MOV' "
            || " ORDER BY prioridad ";

    LET cSQL3 = '">' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    SYSTEM cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRutaArch)|| TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = 'dbaccess bdinteg ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = '';
    LET cSQL = "sed 's/;$//g' "|| TRIM(cRutaArch) || TRIM(cNomArch1) || " >> " || TRIM(cRutaArch) || TRIM(cNomArch);
    SYSTEM cSQL;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql) || ' ' || TRIM(cRutaArch) || TRIM(cNomArch1);
    SYSTEM cSQL;


    -- GENERA ARCHIVO DEL REPORTE CON TELEFONOS DE LOS CLIENTES
    LET cNomArch1 = '';     LET cNomArch = '';      LET cNomArchEjecSql = '';

    LET cNomArch1 =  TRIM(cNomArchivo) || '_Aux_Telefonos_' || TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
    LET cNomArch  =  TRIM(cNomArchivo) || '_telefonos_' || TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
    LET cNomArchEjecSql = 'Rep_ctes_act_bnca_mov_telef.sql';

	LET cSQL = '';
	LET cSQL = ' echo "Numero Solicitud;Numero Cliente;Tipo Telefono;Tipo Red;Telefono Original;Telefono Construido;Carrier;Extension; "> ' || TRIM(cRutaArch) || TRIM(cNomArch);
	SYSTEM cSQL;

    LET cSQL1 = '';
    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRutaArch) || TRIM(cNomArch1) || ' DELIMITER ' || ''';''' ;

    LET cSQL2 = ''; 
    LET cSQL2 = " SELECT num_credito, numcte, tipotelefono, tipored, telefono_orig, telefono_reconst, carrier, extension "
                || " FROM bdinteg:si_telefonos_nvo_layout_cat WHERE grupo_archivos = 'CTEBCA_MOV' "
                || " ORDER BY numcte ";

    LET cSQL3 = '">' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    SYSTEM cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRutaArch)|| TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = 'dbaccess bdinteg ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = cSQL;
    LET cSQL = "sed 's/;$//g' "|| TRIM(cRutaArch) || TRIM(cNomArch1) || " >> " || TRIM(cRutaArch) || TRIM(cNomArch);
    SYSTEM cSQL;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql) || ' ' || TRIM(cRutaArch) || TRIM(cNomArch1);
    SYSTEM cSQL;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '03') Returning cCod_RetIB;

    RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;