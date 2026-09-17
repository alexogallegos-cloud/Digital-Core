CREATE PROCEDURE "informix".sp_extrae_info_aud()
        
        RETURNING CHAR(40), CHAR(80);

        DEFINE v_codret               CHAR(40);
        DEFINE v_fec_ant              DATE;
        DEFINE v_fec_nva              DATE;
        DEFINE v_fecha1               CHAR(8);
        DEFINE v_fecha2               CHAR(8);
        DEFINE v_ruta_unl             CHAR(50);
        DEFINE v_id_tabla             CHAR(60);
        DEFINE v_filename             CHAR(75);
        DEFINE v_isam_err             INTEGER;
        DEFINE v_msj_ret              CHAR(80);
        DEFINE v_error_infmx          CHAR(160);
        DEFINE v_sql_err              INTEGER;
        DEFINE v_sql                  CHAR(590);
        DEFINE v_sel                  VARCHAR(250);
        DEFINE v_sel2                 VARCHAR(80);
        DEFINE v_frm                  VARCHAR(80);
        DEFINE v_whr                  VARCHAR(90);
        DEFINE v_whr2                 VARCHAR(250);
        DEFINE v_fec_hoy              DATE;
        DEFINE v_qry                  CHAR(58);
        
        DEFINE v_fecha_upd_com        DATE;
        
        DEFINE sql_err                INTEGER;
        DEFINE isam_err               INTEGER;
        DEFINE error_info             CHAR(80);
        
        --------------- >>>>>>>    Variables Validación de espacio en disco
        DEFINE v_total_descargados    CHAR (2);
        DEFINE v_fecha_upd            DATE;    
        DEFINE v_sql_d                CHAR(590);    
        
BEGIN        

    ON EXCEPTION SET sql_err, isam_err, error_info
    
        LET v_codret = 'sql_err: ' || sql_err || ' isam_err: ' ||isam_err;
        LET v_msj_ret = 'error_info: ' || error_info;

        --------------- >>>>>>>    Validación de espacio en disco 
        IF sql_err='-668' THEN
            IF isam_err='-255' THEN
                LET v_codret    = '668';
                LET v_msj_ret   = 'Problemas con acceso a tabla';
            END IF;
        END IF;
        --------------- >>>>>>>    
        
        SET DEBUG FILE TO "sp_extrae_info_aud.err";
        
            TRACE sql_err||" * "||isam_err|| " * "||error_info;
            
        RETURN v_codret, v_msj_ret;
    
    END EXCEPTION;

-- Modificado por VJMP Periféricos GMIV Feb/2020 V9.0  --  Se optimizan tiempos de ejecución
-- Modificado por BB producción 22/11/2012  V8.0       --  
-- Modificado por SD Producción 07/11/2012  V 7.0      -- Error por Ruta de compresión de archivos.
-- Modificado por SD Producción 29/10/2012  V 6.0      -- Error por espacio en disco, validación de registros descargados.
-- Modificado por SD Producción 13/03/2012  V 5.0 
-- Agregar Set, separacion de archivos .sql V 4.0

 --SET DEBUG FILE TO "/ifxsif01/VJMP/RQI_65_347/extrae_inf_aud_op1.out";
 --TRACE ON;

/*
    --------------- >>>>>>>    Validación para borrar registros de proceso inconcluso por espacio en disco 
    
    SELECT COUNT (*) AS total_descargados, fecha_upd  
    INTO v_total_descargados, v_fecha_upd
    FROM bdinteg:"informix".si_param_extr
    WHERE fecha_upd IN (SELECT MAX (fecha_upd) FROM bdinteg:"informix".si_param_extr)
    GROUP BY fecha_upd; 

    IF v_total_descargados < 11 THEN
    
        -->> Borrar registros de proceso inconcluso
        DELETE FROM bdinteg:"informix".si_param_extr WHERE fecha_upd = v_fecha_upd;
        
    END IF;
    --------------- >>>>>>>
*/

    SET ISOLATION TO DIRTY READ; 
    
    SELECT fecha_hoy INTO v_fec_hoy FROM bdinteg:"informix".si_fechas;
    
-- // -----------------------------------------------------------------> Descarga de información de "sc_movhis" - INICIO - 01 - Validación OK
    
    -- Asignación de Inicio de proceso, sin Finalizar
    LET v_codret = '001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

    SELECT ruta_unl {+ INDEX( si_param_extr idx_param_extr )}  id_tabla, fecha_ant 
        INTO v_ruta_unl, v_fec_ant
    FROM bdinteg:"informix".si_param_extr 
    WHERE fecha_ant = (SELECT MAX(fecha_ant) from bdinteg:"informix".si_param_extr where id_tabla = 'sc_movhis') 
        AND id_tabla = 'sc_movhis';

    LET v_qry = TRIM(v_ruta_unl) || "sc_movhis_query_aud.sql";
    
    SELECT MAX (fecha_upd)--, id_tabla 
        INTO v_fecha_upd_com
    FROM bdinteg:"informix".si_param_extr 
    WHERE id_tabla = 'sc_movhis';

    IF v_fecha_upd_com = today THEN
        -- Código de Ejecución Exitosa
        LET v_codret    = '000';
        LET v_msj_ret   = 'Proceso Finalizado Correctamente';
    ELSE
    
        IF (v_fec_ant IS NOT NULL AND v_ruta_unl IS NOT NULL) THEN
            /*
			--Variables de pruebas Eliminar VJMP:
            LET v_fec_hoy = TO_DATE('2020-01-06','%Y-%m-%d');
            LET v_fec_ant = TO_DATE('2019-12-28','%Y-%m-%d');
            --Acaban variables pruebas
			*/
            LET v_fec_ant    = v_fec_ant +1 UNITS DAY;
            LET v_fec_nva    = v_fec_hoy -2 UNITS DAY;
            
            LET v_fecha1 = to_char(v_fec_ant,"%d%m%Y");
            LET v_fecha2 = to_char(v_fec_nva,"%d%m%Y");
            
            -- 1. INFO CHEQUES
            -- 1.1 Extrae Movimientos Históricos Cheques -- P 01
            LET v_filename = TRIM(v_ruta_unl) || 'sc_movhis' || v_fecha1 || '_' || v_fecha2 || '.txt';
            LET v_sql = 'echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || v_filename || ' SELECT a.num_cte, b.folio_suc, b.sucursal, b.usuario, b.fech_val, b.fech_hor, b.transacc, b.cuenta, b.monto_tot, b.cancelad, b.sdo_cuenta, b.transacc_suc, b.referencia, b.num_tarjeta FROM  bdicheq:"informix".sc_maechq a, bdicheq:"informix".sc_movhis b' ||
                        ' WHERE a.cuenta = b.cuenta AND b.fech_alt BETWEEN ' || '''' || v_fec_ant || '''' || ' AND ' || '''' || v_fec_nva || '''' || '" > ' || v_qry;

            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'dbaccess bdicheq ' || trim(v_ruta_unl) || 'sc_movhis_query_aud.sql';
            SYSTEM  v_sql;

            -->> Compresión de archivos 
            LET v_sql = '';
            LET v_sql = 'gzip -9 ' || TRIM(v_ruta_unl) || 'sc_movhis' || v_fecha1 || '_' || v_fecha2 || '.txt ';
            SYSTEM  v_sql;
/*
            -->> Asignación de permisos
            LET v_sql = '';
            LET v_sql = 'chmod 777 ' || 'sc_movhis' || v_fecha1 || '_' || v_fecha2 || '.txt ';
            SYSTEM  v_sql;
*/            
            -->> Borrar de archivos sql
            LET v_sql = '';
            LET v_sql = 'rm ' || TRIM(v_ruta_unl) || 'sc_movhis_query_aud.sql';
            SYSTEM  v_sql;

            INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd) 
                                                   VALUES('001', v_fec_nva, v_ruta_unl, 'sc_movhis', user, today);

            -- Código de Ejecución Exitosa
            LET v_codret    = '000';
            LET v_msj_ret   = 'Proceso Finalizado Correctamente';
        ELSE
            -- Código de Inexistencia de Parámetros de Extracción.
            LET v_codret    = '004';
            LET v_msj_ret   = 'No existen informacion en la tabla de Parametros ';
        END IF;
    END IF ;
	/*
	--Variables de pruebas Eliminar VJMP:
    LET v_fec_hoy = TO_DATE('2019-09-30','%Y-%m-%d');
    --Acaban variables pruebas
    */
	
-- // -----------------------------------------------------------------> Descarga de información de "sc_maechq" - INICIO - 02 - Validación OK
    
    SELECT ruta_unl {+ INDEX( si_param_extr idx_param_extr )}  id_tabla, fecha_ant 
        INTO v_ruta_unl, v_fec_ant
    FROM bdinteg:"informix".si_param_extr 
    WHERE fecha_ant = (SELECT MAX(fecha_ant) from bdinteg:"informix".si_param_extr where id_tabla = 'sc_maechq') 
        AND id_tabla = 'sc_maechq';
    
    LET v_qry = TRIM(v_ruta_unl) || "sc_maechq_query_aud.sql";
    
    SELECT MAX (fecha_upd)--, id_tabla 
        INTO v_fecha_upd_com
    FROM bdinteg:"informix".si_param_extr 
    WHERE id_tabla = 'sc_maechq';

    IF v_fecha_upd_com = today THEN
        -- Código de Ejecución Exitosa
        LET v_codret    = '000';
        LET v_msj_ret   = 'Proceso Finalizado Correctamente';
    ELSE
    
        IF (v_fec_ant IS NOT NULL AND v_ruta_unl IS NOT NULL) THEN
            LET v_fec_ant    = v_fec_ant +1 UNITS DAY;
            LET v_fec_nva    = v_fec_hoy -2 UNITS DAY;
            
            LET v_fecha1 = to_char(v_fec_ant,"%d%m%Y");
            LET v_fecha2 = to_char(v_fec_nva,"%d%m%Y");
            
            -- 1.2 Extrae Info Maestro de Cheques -- P 02
            LET v_filename = TRIM(v_ruta_unl) || 'sc_maechq' || v_fecha1 || '_' || v_fecha2 || '.txt';
            LET v_sql = 'echo " SET ISOLATION TO DIRTY READ;  UNLOAD TO ' || v_filename || 
                        ' SELECT a.cuenta, sucursal, num_cte, status_cta, fec_ult_mov, sdo_actual, sdo_dia_ant, fecultdep FROM bdicheq:"informix".sc_maechq a, bdicheq:"informix".sc_maenoc b' ||
                        ' WHERE a.cuenta = b.cuenta AND b.fecha_alta BETWEEN ' || '''' || v_fec_ant || '''' || ' AND ' || '''' || v_fec_nva || '''' || '" > ' || v_qry;

            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'dbaccess bdicheq ' || trim(v_ruta_unl) || 'sc_maechq_query_aud.sql';
            SYSTEM  v_sql;

            -->> Compresión de archivos 
            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'gzip -9 ' || TRIM(v_ruta_unl) || 'sc_maechq' || v_fecha1 || '_' || v_fecha2 || '.txt ';
            SYSTEM  v_sql;
            
            -->> Borrar de archivos sql
            LET v_sql = '';
            LET v_sql = 'rm ' || TRIM(v_ruta_unl) || 'sc_maechq_query_aud.sql';
            SYSTEM  v_sql;
            
            INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd) 
                                                   VALUES('001', v_fec_nva, v_ruta_unl, 'sc_maechq', user, today);

            -- Código de Ejecución Exitosa
            LET v_codret    = '000';
            LET v_msj_ret   = 'Proceso Finalizado Correctamente';
        ELSE
            -- Código de Inexistencia de Parámetros de Extracción.
            LET v_codret    = '004';
            LET v_msj_ret   = 'No existen informacion en la tabla de Parametros ';
        END IF;
    END IF ;
-- // -----------------------------------------------------------------> Descarga de información de "sc_maenoc" - INICIO - 03 - Validación OK
    
    SELECT ruta_unl {+ INDEX( si_param_extr idx_param_extr )}  id_tabla, fecha_ant 
        INTO v_ruta_unl, v_fec_ant
    FROM bdinteg:"informix".si_param_extr 
    WHERE fecha_ant = (SELECT MAX(fecha_ant) from bdinteg:"informix".si_param_extr where id_tabla = 'sc_maenoc') 
        AND id_tabla = 'sc_maenoc';

    LET v_qry = TRIM(v_ruta_unl) || "sc_maenoc_query_aud.sql";

    SELECT MAX (fecha_upd)--, id_tabla 
        INTO v_fecha_upd_com
    FROM bdinteg:"informix".si_param_extr 
    WHERE id_tabla = 'sc_maenoc';

    IF v_fecha_upd_com = today THEN
        -- Código de Ejecución Exitosa
        LET v_codret    = '000';
        LET v_msj_ret   = 'Proceso Finalizado Correctamente';
    ELSE
    
        IF (v_fec_ant IS NOT NULL AND v_ruta_unl IS NOT NULL) THEN
            LET v_fec_ant    = v_fec_ant +1 UNITS DAY;
            LET v_fec_nva    = v_fec_hoy -2 UNITS DAY;
            
            LET v_fecha1 = to_char(v_fec_ant,"%d%m%Y");
            LET v_fecha2 = to_char(v_fec_nva,"%d%m%Y");
            
            -- 1.3 Extrae Info Maenoc -- P 03
            LET v_filename = TRIM(v_ruta_unl) || 'sc_maenoc' || v_fecha1 || '_' || v_fecha2 || '.txt';
            LET v_sql = 'echo " SET ISOLATION TO DIRTY READ;  UNLOAD TO ' || v_filename || 
                        ' SELECT cuenta, ejecutivo, dia_sdo_pos, acum_sdo_pos, sdo_prom_mesant, sdo_mes_ant, fecha_alta FROM bdicheq:"informix".sc_maenoc' ||
                        ' WHERE fecha_alta BETWEEN ' || '''' || v_fec_ant || '''' || ' AND ' || '''' || v_fec_nva || '''' || '" > ' || v_qry;

            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'dbaccess bdicheq ' || trim(v_ruta_unl) || 'sc_maenoc_query_aud.sql';
            SYSTEM  v_sql;

            -->> Compresión de archivos 
            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'gzip -9 ' || TRIM(v_ruta_unl) || 'sc_maenoc' || v_fecha1 || '_' || v_fecha2 || '.txt ';
            SYSTEM  v_sql;
            
            -->> Borrar de archivos sql
            LET v_sql = '';
            LET v_sql = 'rm ' || TRIM(v_ruta_unl) || 'sc_maenoc_query_aud.sql';
            SYSTEM  v_sql;
            
            INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd) 
                                                   VALUES('001', v_fec_nva, v_ruta_unl, 'sc_maenoc', user, today);

            -- Código de Ejecución Exitosa
            LET v_codret    = '000';
            LET v_msj_ret   = 'Proceso Finalizado Correctamente';
        ELSE
            -- Código de Inexistencia de Parámetros de Extracción.
            LET v_codret    = '004';
            LET v_msj_ret   = 'No existen informacion en la tabla de Parametros ';
        END IF;
    END IF ;
-- // -----------------------------------------------------------------> Descarga de información de "sc_tarjeta" - INICIO - 04 - Validación OK
    
    SELECT ruta_unl {+ INDEX( si_param_extr idx_param_extr )}  id_tabla, fecha_ant 
        INTO v_ruta_unl, v_fec_ant
    FROM bdinteg:"informix".si_param_extr 
    WHERE fecha_ant = (SELECT MAX(fecha_ant) from bdinteg:"informix".si_param_extr where id_tabla = 'sc_tarjeta') 
        AND id_tabla = 'sc_tarjeta';

    LET v_qry = TRIM(v_ruta_unl) || "sc_tarjeta_query_aud.sql";

    SELECT MAX (fecha_upd)--, id_tabla 
        INTO v_fecha_upd_com
    FROM bdinteg:"informix".si_param_extr 
    WHERE id_tabla = 'sc_tarjeta';

    IF v_fecha_upd_com = today THEN
        -- Código de Ejecución Exitosa
        LET v_codret    = '000';
        LET v_msj_ret   = 'Proceso Finalizado Correctamente';
    ELSE
    
        IF (v_fec_ant IS NOT NULL AND v_ruta_unl IS NOT NULL) THEN
            LET v_fec_ant    = v_fec_ant +1 UNITS DAY;
            LET v_fec_nva    = v_fec_hoy -2 UNITS DAY;
            
            LET v_fecha1 = to_char(v_fec_ant,"%d%m%Y");
            LET v_fecha2 = to_char(v_fec_nva,"%d%m%Y");
            
            -- 1.4 Extrae Info Tarjeta Cheques
            LET v_filename = TRIM(v_ruta_unl) || 'sc_tarjeta' || v_fecha1 || '_' || v_fecha2 || '.txt';
            LET v_sql = 'echo " SET ISOLATION TO DIRTY READ;  UNLOAD TO ' || v_filename || 
                        ' SELECT cuenta, secuencia, num_tarjeta, numcte, tipo_tarjeta, status_tar FROM bdicheq:"informix".sc_tarjeta' || '" > ' || TRIM(v_qry);

            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'dbaccess bdicheq ' || trim(v_ruta_unl) || 'sc_tarjeta_query_aud.sql';
            SYSTEM  v_sql;

            -->> Compresión de archivos 
            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'gzip -9 ' || TRIM(v_ruta_unl) || 'sc_tarjeta' || v_fecha1 || '_' || v_fecha2 || '.txt ';
            SYSTEM  v_sql;
            
            -->> Borrar de archivos sql
            LET v_sql = '';
            LET v_sql = 'rm ' || TRIM(v_ruta_unl) || 'sc_tarjeta_query_aud.sql';
            SYSTEM  v_sql;
            
            INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd) 
                                                   VALUES('001', v_fec_nva, v_ruta_unl, 'sc_tarjeta', user, today);

            -- Código de Ejecución Exitosa
            LET v_codret    = '000';
            LET v_msj_ret   = 'Proceso Finalizado Correctamente';
        ELSE
            -- Código de Inexistencia de Parámetros de Extracción.
            LET v_codret    = '004';
            LET v_msj_ret   = 'No existen informacion en la tabla de Parametros ';
        END IF;
    END IF ;
-- // -----------------------------------------------------------------> Descarga de información de "sv_movhis" - INICIO - 05 - Validación OK
    
    SELECT ruta_unl {+ INDEX( si_param_extr idx_param_extr )}  id_tabla, fecha_ant 
        INTO v_ruta_unl, v_fec_ant
    FROM bdinteg:"informix".si_param_extr 
    WHERE fecha_ant = (SELECT MAX(fecha_ant) from bdinteg:"informix".si_param_extr where id_tabla = 'sv_movhis') 
        AND id_tabla = 'sv_movhis';

    LET v_qry = TRIM(v_ruta_unl) || "sv_movhis_query_aud.sql";

    SELECT MAX (fecha_upd)--, id_tabla 
        INTO v_fecha_upd_com
    FROM bdinteg:"informix".si_param_extr 
    WHERE id_tabla = 'sv_movhis';

    IF v_fecha_upd_com = today THEN
        -- Código de Ejecución Exitosa
        LET v_codret    = '000';
        LET v_msj_ret   = 'Proceso Finalizado Correctamente';
    ELSE
    
        IF (v_fec_ant IS NOT NULL AND v_ruta_unl IS NOT NULL) THEN
            LET v_fec_ant    = v_fec_ant +1 UNITS DAY;
            LET v_fec_nva    = v_fec_hoy -2 UNITS DAY;
            
            LET v_fecha1 = to_char(v_fec_ant,"%d%m%Y");
            LET v_fecha2 = to_char(v_fec_nva,"%d%m%Y");
            
            LET v_filename = TRIM(v_ruta_unl) || 'sv_movhis' || v_fecha1 || '_' || v_fecha2 || '.txt';
            LET v_sel = ' SELECT a.num_cte, b.folio_suc, b.sucursal, b.usuario, b.fech_alt, b.fech_hor, b.transacc, b.cuenta, b.monto_tot, b.cancelad FROM bdinvers:"informix".sv_maeinv a, bdinvers:"informix".sv_movhis b';
            LET v_whr = ' WHERE a.cuenta = b.cuenta AND b.fech_alt BETWEEN ' || '''' || v_fec_ant || '''' || ' AND ' || '''' || v_fec_nva || '''';
            LET v_sql = 'echo " SET ISOLATION TO DIRTY READ;  UNLOAD TO ' || v_filename || TRIM(v_sel) || RTRIM(v_whr) || '"' || ' >  ' || TRIM(v_qry);

            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'dbaccess bdinvers ' || trim(v_ruta_unl) || 'sv_movhis_query_aud.sql';
            SYSTEM  v_sql;

            -->> Compresión de archivos 
            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'gzip -9 ' || TRIM(v_ruta_unl) || 'sv_movhis' || v_fecha1 || '_' || v_fecha2 || '.txt ';
            SYSTEM  v_sql;
            
            -->> Borrar de archivos sql
            LET v_sql = '';
            LET v_sql = 'rm ' || TRIM(v_ruta_unl) || 'sv_movhis_query_aud.sql';
            SYSTEM  v_sql;
            
            INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd) 
                                                   VALUES('001', v_fec_nva, v_ruta_unl, 'sv_movhis', user, today);

            -- Código de Ejecución Exitosa
            LET v_codret    = '000';
            LET v_msj_ret   = 'Proceso Finalizado Correctamente';
        ELSE
            -- Código de Inexistencia de Parámetros de Extracción.
            LET v_codret    = '004';
            LET v_msj_ret   = 'No existen informacion en la tabla de Parametros ';
        END IF;
    END IF ;
-- // -----------------------------------------------------------------> Descarga de información de "sv_maeinv" - INICIO - 06 - Validación OK
    
    SELECT ruta_unl {+ INDEX( si_param_extr idx_param_extr )}  id_tabla, fecha_ant 
        INTO v_ruta_unl, v_fec_ant
    FROM bdinteg:"informix".si_param_extr 
    WHERE fecha_ant = (SELECT MAX(fecha_ant) from bdinteg:"informix".si_param_extr where id_tabla = 'sv_maeinv') 
        AND id_tabla = 'sv_maeinv';

    LET v_qry = TRIM(v_ruta_unl) || "sv_maeinv_query_aud.sql";
    
    SELECT MAX (fecha_upd)--, id_tabla 
        INTO v_fecha_upd_com
    FROM bdinteg:"informix".si_param_extr 
    WHERE id_tabla = 'sv_maeinv';

    IF v_fecha_upd_com = today THEN
        -- Código de Ejecución Exitosa
        LET v_codret    = '000';
        LET v_msj_ret   = 'Proceso Finalizado Correctamente';
    ELSE
    
        IF (v_fec_ant IS NOT NULL AND v_ruta_unl IS NOT NULL) THEN
            LET v_fec_ant    = v_fec_ant +1 UNITS DAY;
            LET v_fec_nva    = v_fec_hoy -2 UNITS DAY;
            
            LET v_fecha1 = to_char(v_fec_ant,"%d%m%Y");
            LET v_fecha2 = to_char(v_fec_nva,"%d%m%Y");
            
            -- 2.2 Extrae Maestro Inversiones
            LET v_filename = TRIM(v_ruta_unl) || 'sv_maeinv' || v_fecha1 || '_' || v_fecha2 || '.txt';
            LET v_sel = ' SELECT cuenta, num_cte, status_cta, fec_ult_mov, fec_cancelac, fec_reinversion, capital, fecha_alta, promotor FROM bdinvers:"informix".sv_maeinv';
            LET v_whr = ' WHERE fecha_alta BETWEEN ' || '''' || v_fec_ant || '''' || ' AND ' || '''' || v_fec_nva || '''';
            LET v_sql = 'echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || v_filename || TRIM(v_sel) || RTRIM(v_whr) || '"' || ' >  ' || TRIM(v_qry);

            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'dbaccess bdinvers ' || trim(v_ruta_unl) || 'sv_maeinv_query_aud.sql';
            SYSTEM  v_sql;

            -->> Compresión de archivos 
            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'gzip -9 ' || TRIM(v_ruta_unl) || 'sv_maeinv' || v_fecha1 || '_' || v_fecha2 || '.txt ';
            SYSTEM  v_sql;
            
            -->> Borrar de archivos sql
            LET v_sql = '';
            LET v_sql = 'rm ' || TRIM(v_ruta_unl) || 'sv_maeinv_query_aud.sql';
            SYSTEM  v_sql;
            
            INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd) 
                                                   VALUES('001', v_fec_nva, v_ruta_unl, 'sv_maeinv', user, today);

            -- Código de Ejecución Exitosa
            LET v_codret    = '000';
            LET v_msj_ret   = 'Proceso Finalizado Correctamente';
        ELSE
            -- Código de Inexistencia de Parámetros de Extracción.
            LET v_codret    = '004';
            LET v_msj_ret   = 'No existen informacion en la tabla de Parametros ';
        END IF;
    END IF ;
-- // -----------------------------------------------------------------> Descarga de información de "sd_movhis" - INICIO - 07 - Validación OK
    
    SELECT ruta_unl {+ INDEX( si_param_extr idx_param_extr )}  id_tabla, fecha_ant 
        INTO v_ruta_unl, v_fec_ant
    FROM bdinteg:"informix".si_param_extr 
    WHERE fecha_ant = (SELECT MAX(fecha_ant) from bdinteg:"informix".si_param_extr where id_tabla = 'sd_movhis') 
        AND id_tabla = 'sd_movhis';

    LET v_qry = TRIM(v_ruta_unl) || "sd_movhis_query_aud.sql";
    
    SELECT MAX (fecha_upd)--, id_tabla 
        INTO v_fecha_upd_com
    FROM bdinteg:"informix".si_param_extr 
    WHERE id_tabla = 'sd_movhis';

    IF v_fecha_upd_com = today THEN
        -- Código de Ejecución Exitosa
        LET v_codret    = '000';
        LET v_msj_ret   = 'Proceso Finalizado Correctamente';
    ELSE
    
        IF (v_fec_ant IS NOT NULL AND v_ruta_unl IS NOT NULL) THEN
            LET v_fec_ant    = v_fec_ant +1 UNITS DAY;
            LET v_fec_nva    = v_fec_hoy -2 UNITS DAY;
            
            LET v_fecha1 = to_char(v_fec_ant,"%d%m%Y");
            LET v_fecha2 = to_char(v_fec_nva,"%d%m%Y");
            
            -- 3.1 Extrae Movimientos Históricos Crédito
            LET v_filename = TRIM(v_ruta_unl) || 'sd_movhis' || v_fecha1 || '_' || v_fecha2 || '.txt';
            LET v_sel = ' SELECT a.numcte, b.fecha_mov, b.hora_mov, b.sucursal, b.num_credito, b.transacc_suc, b.usuario, b.monto, b.reversado, b.folio_suc, b.suc_origen FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_movhis b';
            LET v_whr = ' WHERE a.num_credito = b.num_credito AND b.fecha_mov BETWEEN ' || '''' || v_fec_ant || '''' || ' AND ' || '''' || v_fec_nva || '''';
            LET v_sql = 'echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || v_filename || TRIM(v_sel) || RTRIM(v_whr) || '"' || ' >  ' ||TRIM(v_qry);

            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'dbaccess bdicred ' || trim(v_ruta_unl) || 'sd_movhis_query_aud.sql';
            SYSTEM  v_sql;

            -->> Compresión de archivos 
            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'gzip -9 ' || TRIM(v_ruta_unl) || 'sd_movhis' || v_fecha1 || '_' || v_fecha2 || '.txt ';
            SYSTEM  v_sql;
            
            -->> Borrar de archivos sql
            LET v_sql = '';
            LET v_sql = 'rm ' || TRIM(v_ruta_unl) || 'sd_movhis_query_aud.sql';
            SYSTEM  v_sql;
            
            INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd) 
                                                   VALUES('001', v_fec_nva, v_ruta_unl, 'sd_movhis', user, today);

            -- Código de Ejecución Exitosa
            LET v_codret    = '000';
            LET v_msj_ret   = 'Proceso Finalizado Correctamente';
        ELSE
            -- Código de Inexistencia de Parámetros de Extracción.
            LET v_codret    = '004';
            LET v_msj_ret   = 'No existen informacion en la tabla de Parametros ';
        END IF;
    END IF ;
-- // -----------------------------------------------------------------> Descarga de información de "sd_maecred" - INICIO - 08 - Validación OK
        
    SELECT ruta_unl {+ INDEX( si_param_extr idx_param_extr )}  id_tabla, fecha_ant 
        INTO v_ruta_unl, v_fec_ant
    FROM bdinteg:"informix".si_param_extr 
    WHERE fecha_ant = (SELECT MAX(fecha_ant) from bdinteg:"informix".si_param_extr where id_tabla = 'sd_maecred') 
        AND id_tabla = 'sd_maecred';

    LET v_qry = TRIM(v_ruta_unl) || "sd_maecred_query_aud.sql";
    
    SELECT MAX (fecha_upd)--, id_tabla 
        INTO v_fecha_upd_com
    FROM bdinteg:"informix".si_param_extr 
    WHERE id_tabla = 'sd_maecred';

    IF v_fecha_upd_com = today THEN
        -- Código de Ejecución Exitosa
        LET v_codret    = '000';
        LET v_msj_ret   = 'Proceso Finalizado Correctamente';
    ELSE
    
        IF (v_fec_ant IS NOT NULL AND v_ruta_unl IS NOT NULL) THEN
            LET v_fec_ant    = v_fec_ant +1 UNITS DAY;
            LET v_fec_nva    = v_fec_hoy -2 UNITS DAY;
            
            LET v_fecha1 = to_char(v_fec_ant,"%d%m%Y");
            LET v_fecha2 = to_char(v_fec_nva,"%d%m%Y");
            
            --'''"001"'''

            -- 3.2 Extrae Maestro de Crédito
            LET v_filename = TRIM(v_ruta_unl) || 'sd_maecred' || v_fecha1 || '_' || v_fecha2 || '.txt';
            LET v_sel = ' SELECT num_credito, ejecutivo, numcte, sucursal, status_cred, fecha_apertura, calificacion_riesgo FROM bdicred:"informix".sd_maecred';
            LET v_whr = ' WHERE fecha_apertura BETWEEN ' || '''' || v_fec_ant || '''' || ' AND ' || '''' || v_fec_nva || '''';
            LET v_sql = 'echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || v_filename || TRIM(v_sel) || RTRIM(v_whr) || '"' || ' >  ' || TRIM(v_qry);

            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'dbaccess bdicred ' || trim(v_ruta_unl) || 'sd_maecred_query_aud.sql';
            SYSTEM  v_sql;

            -->> Compresión de archivos
            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'gzip -9 ' || TRIM(v_ruta_unl) || 'sd_maecred' || v_fecha1 || '_' || v_fecha2 || '.txt ';
            SYSTEM  v_sql;
            
            -->> Borrar de archivos sql
            LET v_sql = '';
            LET v_sql = 'rm ' || TRIM(v_ruta_unl) || 'sd_maecred_query_aud.sql';
            SYSTEM  v_sql;
            
            INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd) 
                                                   VALUES('001', v_fec_nva, v_ruta_unl, 'sd_maecred', user, today);

            -- Código de Ejecución Exitosa
            LET v_codret    = '000';
            LET v_msj_ret   = 'Proceso Finalizado Correctamente';
        ELSE
            -- Código de Inexistencia de Parámetros de Extracción.
            LET v_codret    = '004';
            LET v_msj_ret   = 'No existen informacion en la tabla de Parametros ';
        END IF;
    END IF ;
-- // -----------------------------------------------------------------> Descarga de información de "sd_tarjeta" - INICIO - 09 - Validación OK
    
    SELECT ruta_unl {+ INDEX( si_param_extr idx_param_extr )}  id_tabla, fecha_ant 
        INTO v_ruta_unl, v_fec_ant
    FROM bdinteg:"informix".si_param_extr 
    WHERE fecha_ant = (SELECT MAX(fecha_ant) from bdinteg:"informix".si_param_extr where id_tabla = 'sd_tarjeta') 
        AND id_tabla = 'sd_tarjeta';

    LET v_qry = TRIM(v_ruta_unl) || "sd_tarjeta_query_aud.sql";
    
    SELECT MAX (fecha_upd)--, id_tabla 
        INTO v_fecha_upd_com
    FROM bdinteg:"informix".si_param_extr 
    WHERE id_tabla = 'sd_tarjeta';

    IF v_fecha_upd_com = today THEN
        -- Código de Ejecución Exitosa
        LET v_codret    = '000';
        LET v_msj_ret   = 'Proceso Finalizado Correctamente';
    ELSE
    
        IF (v_fec_ant IS NOT NULL AND v_ruta_unl IS NOT NULL) THEN
            LET v_fec_ant    = v_fec_ant +1 UNITS DAY;
            LET v_fec_nva    = v_fec_hoy -2 UNITS DAY;
            
            LET v_fecha1 = to_char(v_fec_ant,"%d%m%Y");
            LET v_fecha2 = to_char(v_fec_nva,"%d%m%Y");
            
            -- 3.3 Extrae Tarjeta de Crédito
            LET v_filename = TRIM(v_ruta_unl) || 'sd_tarjeta' || v_fecha1 || '_' || v_fecha2 || '.txt';
            LET v_sel = ' SELECT num_credito, secuencia, num_tarjeta, numcte, tipo_tarjeta, status_tar FROM bdicred:"informix".sd_tarjeta';
            LET v_sql = 'echo " SET ISOLATION TO DIRTY READ;  UNLOAD TO ' || v_filename || TRIM(v_sel) || '"' || ' >  ' || TRIM(v_qry);

            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'dbaccess bdicred ' || trim(v_ruta_unl) || 'sd_tarjeta_query_aud.sql';
            SYSTEM  v_sql;

            -->> Compresión de archivos
            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'gzip -9 ' || TRIM(v_ruta_unl) || 'sd_tarjeta' || v_fecha1 || '_' || v_fecha2 || '.txt ';
            SYSTEM  v_sql;
            
            -->> Borrar de archivos sql
            LET v_sql = '';
            LET v_sql = 'rm ' || TRIM(v_ruta_unl) || 'sd_tarjeta_query_aud.sql';
            SYSTEM  v_sql;
            
            INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd) 
                                                   VALUES('001', v_fec_nva, v_ruta_unl, 'sd_tarjeta', user, today);

            -- Código de Ejecución Exitosa
            LET v_codret    = '000';
            LET v_msj_ret   = 'Proceso Finalizado Correctamente';
        ELSE
            -- Código de Inexistencia de Parámetros de Extracción.
            LET v_codret    = '004';
            LET v_msj_ret   = 'No existen informacion en la tabla de Parametros ';
        END IF;
    END IF ;
-- // -----------------------------------------------------------------> Descarga de información de "tarjeta" - INICIO - 10 - Validación OK
    
    SELECT ruta_unl {+ INDEX( si_param_extr idx_param_extr )}  id_tabla, fecha_ant 
        INTO v_ruta_unl, v_fec_ant
    FROM bdinteg:"informix".si_param_extr 
    WHERE fecha_ant = (SELECT MAX(fecha_ant) from bdinteg:"informix".si_param_extr where id_tabla = 'tarjeta') 
        AND id_tabla = 'tarjeta';

    LET v_qry = TRIM(v_ruta_unl) || "tarjeta_query_aud.sql";
    
    SELECT MAX (fecha_upd)--, id_tabla 
        INTO v_fecha_upd_com
    FROM bdinteg:"informix".si_param_extr 
    WHERE id_tabla = 'tarjeta';

    IF v_fecha_upd_com = today THEN
        -- Código de Ejecución Exitosa
        LET v_codret    = '000';
        LET v_msj_ret   = 'Proceso Finalizado Correctamente';
    ELSE
    
        IF (v_fec_ant IS NOT NULL AND v_ruta_unl IS NOT NULL) THEN
            LET v_fec_ant    = v_fec_ant +1 UNITS DAY;
            LET v_fec_nva    = v_fec_hoy -2 UNITS DAY;
            
            LET v_fecha1 = to_char(v_fec_ant,"%d%m%Y");
            LET v_fecha2 = to_char(v_fec_nva,"%d%m%Y");
            
            -- 4.1 Extrae Movimientos de Tarjetas en Intercard
            LET v_filename = TRIM(v_ruta_unl) || 'tarjeta' || v_fecha1 || '_' || v_fecha2 || '.txt';
            LET v_sel = ' SELECT numtarjeta, codstatustarjeta, numcliente, titular, nombre, usuarioultmodif, fechaultmodif, fechaasignacion FROM intercard:"informix".tarjeta a WHERE DATE(a.fechaasignacion) BETWEEN ' || '''' || v_fec_ant || '''' || ' AND ' || '''' || v_fec_nva || '''';
            LET v_whr = ' UNION ';
            LET v_whr2= ' SELECT numtarjeta, codstatustarjeta, numcliente, titular, nombre, usuarioultmodif, fechaultmodif, fechaasignacion FROM intercard:"informix".tarjeta a WHERE DATE(a.fechaultmodif) BETWEEN ' || '''' || v_fec_ant || '''' || ' AND ' || '''' || v_fec_nva || '''';
            
            LET v_sql = 'echo " SET ISOLATION TO DIRTY READ;  UNLOAD TO ' || trim(v_filename) || ' ' || TRIM(v_sel) || RTRIM(v_whr) || RTRIM(v_whr2) || '"' || ' >  ' || TRIM(v_qry);

            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'dbaccess intercard ' || trim(v_ruta_unl) || 'tarjeta_query_aud.sql';
            SYSTEM  v_sql;

            -->> Compresión de archivos        
            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'gzip -9 ' || TRIM(v_ruta_unl) || 'tarjeta' || v_fecha1 || '_' || v_fecha2 || '.txt ';
            SYSTEM  v_sql;
            
            -->> Borrar de archivos sql
            LET v_sql = '';
            LET v_sql = 'rm ' || TRIM(v_ruta_unl) || 'tarjeta_query_aud.sql';
            SYSTEM  v_sql;
            
            INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd) 
                                                   VALUES('001', v_fec_nva, v_ruta_unl, 'tarjeta', user, today);

            -- Código de Ejecución Exitosa
            LET v_codret    = '000';
            LET v_msj_ret   = 'Proceso Finalizado Correctamente';
        ELSE
            -- Código de Inexistencia de Parámetros de Extracción.
            LET v_codret    = '004';
            LET v_msj_ret   = 'No existen informacion en la tabla de Parametros ';
        END IF;
    END IF ;
-- // -----------------------------------------------------------------> Descarga de información de "ss_solicitudes" - INICIO - 11 - Validación OK
    
    SELECT ruta_unl {+ INDEX( si_param_extr idx_param_extr )}  id_tabla, fecha_ant 
        INTO v_ruta_unl, v_fec_ant
    FROM bdinteg:"informix".si_param_extr 
    WHERE fecha_ant = (SELECT MAX(fecha_ant) from bdinteg:"informix".si_param_extr where id_tabla = 'ss_solicitudes') 
        AND id_tabla = 'ss_solicitudes';

    LET v_qry = TRIM(v_ruta_unl) || "ss_solicitudes_query_aud.sql";
    
    SELECT MAX (fecha_upd)--, id_tabla 
        INTO v_fecha_upd_com
    FROM bdinteg:"informix".si_param_extr 
    WHERE id_tabla = 'ss_solicitudes';

    IF v_fecha_upd_com = today THEN
        -- Código de Ejecución Exitosa
        LET v_codret    = '000';
        LET v_msj_ret   = 'Proceso Finalizado Correctamente';
    ELSE
    
        IF (v_fec_ant IS NOT NULL AND v_ruta_unl IS NOT NULL) THEN
            LET v_fec_ant    = v_fec_ant +1 UNITS DAY;
            LET v_fec_nva    = v_fec_hoy -2 UNITS DAY;
            
            LET v_fecha1 = to_char(v_fec_ant,"%d%m%Y");
            LET v_fecha2 = to_char(v_fec_nva,"%d%m%Y");
            
            -- 5.1 Extrae nuevas Solicitudes
            LET v_filename = TRIM(v_ruta_unl) || 'ss_solicitudes' || v_fecha1 || '_' || v_fecha2 || '.txt';
            LET v_sel = ' SELECT num_solicitud, numcte, sucursal, tipo_solicitud, status_solicitud, monto_solicitado, user_insert, fecha_insert FROM bdisolic:"informix".ss_solicitudes';
            LET v_whr = ' WHERE fecha_insert BETWEEN ' || '''' || v_fec_ant || '''' || ' AND ' || '''' || v_fec_nva || '''';
            
            LET v_sql = 'echo " SET ISOLATION TO DIRTY READ;  UNLOAD TO ' || v_filename || TRIM(v_sel) || RTRIM(v_whr) || '"' || ' >  ' || TRIM(v_qry);

            SYSTEM  v_sql;
           -- LET v_sql = "dbaccess bdinteg query_aud.sql ";
            LET v_sql = 'dbaccess bdinteg ' || trim(v_ruta_unl) || 'ss_solicitudes_query_aud.sql';
            SYSTEM  v_sql;

            -->> Compresión de archivos        
            SYSTEM  v_sql;
            LET v_sql = '';
            LET v_sql = 'gzip -9 ' || TRIM(v_ruta_unl) || 'ss_solicitudes' || v_fecha1 || '_' || v_fecha2 || '.txt ';
            SYSTEM  v_sql;
            
            -->> Borrar de archivos sql
            LET v_sql = '';
            LET v_sql = 'rm ' || TRIM(v_ruta_unl) || 'ss_solicitudes_query_aud.sql';
            SYSTEM  v_sql;
            
            INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd) 
                                                   VALUES('001', v_fec_nva, v_ruta_unl, 'ss_solicitudes', user, today);

            -- Código de Ejecución Exitosa
            LET v_codret    = '000';
            LET v_msj_ret   = 'Proceso Finalizado Correctamente';
        ELSE
            -- Código de Inexistencia de Parámetros de Extracción.
            LET v_codret    = '004';
            LET v_msj_ret   = 'No existen informacion en la tabla de Parametros ';
        END IF;
    END IF ;
    
    RETURN v_codret, v_msj_ret;
END        

END PROCEDURE
DOCUMENT
'Area           :   Sistemas Administrativos y Perifericos',
                    'Gerencia de Mtto y Soporte IV',
'Coordinador    :   Norberto Corona Berruecos',
'FECHA          :   Febrero/2020',
'Requerimiento  :   RQI 65 347',
'VERSION		:   9.0.0',
'BD             :   bdinteg';

CREATE PROCEDURE "informix".sp_consulta_carrier_web ()

	RETURNING  CHAR(5) AS codRetorno, CHAR(4) AS idCarrier, CHAR(40) AS nombreCarrier;
 
--definicion de variables--               
DEFINE resultado_idCarrier           CHAR(4);
DEFINE resultado_nombreCarrier       CHAR(40);
DEFINE resultado_codRetorno          CHAR(5);
DEFINE iSqlErr                       INTEGER;

-- Inicializacion de las variables.
LET resultado_idCarrier = '';
LET resultado_nombreCarrier = '';
LET resultado_codRetorno = '00000';

SET ISOLATION DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET resultado_idCarrier = '';
			LET resultado_nombreCarrier = '';
			LET resultado_codRetorno = '00001';
			RETURN resultado_codRetorno,resultado_idCarrier, resultado_nombreCarrier;
		END IF;
	END EXCEPTION;
	
	FOREACH
		SELECT cve_carrier, nombre_carrier
		INTO resultado_idCarrier, resultado_nombreCarrier
		FROM bdinteg:si_carriers
		ORDER BY cve_carrier, nombre_carrier
		RETURN resultado_codRetorno, resultado_idCarrier, resultado_nombreCarrier WITH resume;
	END FOREACH;
END
END PROCEDURE;