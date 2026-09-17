CREATE PROCEDURE "informix".sp_extrae_info_aud_cheq()
		RETURNING CHAR(40), CHAR(80);

        DEFINE v_codret         	CHAR(40);
        DEFINE v_fec_ant        	DATE;
        DEFINE v_fec_nva        	DATE;
        DEFINE v_day1           	CHAR(2);
        DEFINE v_day2           	CHAR(2);
        DEFINE v_month1         	CHAR(2);
        DEFINE v_month2         	CHAR(2);
        DEFINE v_year1          	CHAR(4);
        DEFINE v_year2          	CHAR(4);
        DEFINE v_ruta_unl       	CHAR(50);
        DEFINE v_filename       	CHAR(75);
        DEFINE v_msj_ret        	CHAR(80);
        DEFINE v_sql            	CHAR(590);
        DEFINE v_fec_hoy        	DATE;
        DEFINE v_qry            	CHAR(58);

        DEFINE v_fecha_upd_com  	DATE;

        DEFINE sql_err          	INTEGER;
        DEFINE isam_err         	INTEGER;
        DEFINE error_info       	CHAR(80);

		--------------- >>>>>>>	Variables Validación de espacio en disco
		DEFINE v_fecha_upd			DATE;

BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info

		LET v_codret = 'sql_err: ' || sql_err || ' isam_err: ' ||isam_err;
		LET v_msj_ret = 'error_info: ' || error_info;

			--------------- >>>>>>>	Validación de espacio en disco
		IF sql_err='-668' THEN
			IF isam_err='-255' THEN
            	LET v_codret    = '668';
                LET v_msj_ret   = 'Problemas con acceso a tabla';
			END IF;
		END IF;
			--------------- >>>>>>>

		--SET DEBUG FILE TO "sp_extrae_info_aud.err";

			--TRACE sql_err||" * "||isam_err|| " * "||error_info;

		RETURN v_codret, v_msj_ret;

	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;

    SELECT fecha_hoy INTO v_fec_hoy FROM bdinteg:"informix".si_fechas;

	--LET v_fec_hoy = "02/20/2008";


-- // -----------------------------------------------------------------> Descarga de información de "sc_movhis" - INICIO - 01 - Validación OK

    -- Asignación de Inicio de proceso, sin Finalizar
    LET v_codret = '001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT ruta_unl {+ INDEX( si_param_extr idx_param_extr )}  id_tabla, fecha_ant INTO v_ruta_unl, v_fec_ant
	FROM bdinteg:"informix".si_param_extr where fecha_ant = (SELECT MAX(fecha_ant) from bdinteg:"informix".si_param_extr where id_tabla = 'sc_movhis') and id_tabla = 'sc_movhis';

    LET v_qry = TRIM(v_ruta_unl) || "sc_movhis_query_aud_cheq.sql";

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
			LET v_fec_ant    = v_fec_ant +1 UNITS DAY;
			LET v_fec_nva    = v_fec_hoy -2 UNITS DAY;
			IF DAY(v_fec_ant) < 10 THEN
				LET v_day1   = "0" || DAY(v_fec_ant);
			ELSE
				LET v_day1   = DAY(v_fec_ant);
			END IF;
			IF MONTH(v_fec_ant) < 10 THEN
				LET v_month1 = "0" || MONTH(v_fec_ant);
			ELSE
				LET v_month1 = MONTH(v_fec_ant);
			END IF;
			LET v_year1      = YEAR(v_fec_ant);
			IF DAY(v_fec_nva) < 10 THEN
				LET v_day2   = "0" || DAY(v_fec_nva);
			ELSE
				LET v_day2   = DAY(v_fec_nva);
			END IF;
			IF MONTH(v_fec_nva) < 10 THEN
				LET v_month2 = "0" || MONTH(v_fec_nva);
			ELSE
				LET v_month2 = MONTH(v_fec_nva);
			END IF;
			LET v_year2      = YEAR(v_fec_nva);

			-- 1. INFO CHEQUES
			-- 1.1 Extrae Movimientos Históricos Cheques -- P 01
			LET v_filename = TRIM(v_ruta_unl) || 'sc_movhis' || v_day1 || v_month1 || v_year1 || '_' || v_day2 || v_month2 || v_year2 || '.txt';
			LET v_sql = 'echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || v_filename || ' SELECT {+ INDEX( sc_movhis idx_movhisnew1) } a.num_cte, b.folio_suc, b.sucursal, b.usuario, b.fech_val, b.fech_hor, b.transacc, b.cuenta, b.monto_tot, b.cancelad, b.sdo_cuenta, b.transacc_suc, b.referencia, b.num_tarjeta FROM  bdicheq:"informix".sc_maechq a, bdicheq:"informix".sc_movhis b' ||
						'  WHERE a.cuenta = b.cuenta AND b.empresa = '||''''||'001'||''''||' AND b.fech_alt BETWEEN ' || '''' || v_fec_ant || '''' || ' AND ' || '''' || v_fec_nva || '''' || '" > ' || v_qry;

			SYSTEM  v_sql;
			LET v_sql = '';
			LET v_sql = 'dbaccess bdicheq ' || trim(v_ruta_unl) || 'sc_movhis_query_aud_cheq.sql';
			SYSTEM  v_sql;

			-->> Compresión de archivos
			LET v_sql = '';
			LET v_sql = 'gzip -9 ' || TRIM(v_ruta_unl) || 'sc_movhis' || v_day1 || v_month1 || v_year1 || '_' || v_day2 || v_month2 || v_year2 || '.txt ';			SYSTEM  v_sql;
/*
			-->> Asignación de permisos
			LET v_sql = '';
			LET v_sql = 'chmod 777 ' || 'sc_movhis' || v_day1 || v_month1 || v_year1 || '_' || v_day2 || v_month2 || v_year2 || '.txt ';
			SYSTEM  v_sql;
*/
			-->> Borrar de archivos sql
			LET v_sql = '';
			LET v_sql = 'rm ' || TRIM(v_ruta_unl) || 'sc_movhis_query_aud_cheq.sql';
			SYSTEM  v_sql;

			INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd) VALUES('001', v_fec_nva, v_ruta_unl, 'sc_movhis', user, today);

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

END PROCEDURE;