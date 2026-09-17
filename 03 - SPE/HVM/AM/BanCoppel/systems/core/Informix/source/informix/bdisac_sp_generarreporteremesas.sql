CREATE PROCEDURE "informix".sp_generarreporteremesas()

	RETURNING
		CHAR	(100),
		CHAR	(5),
		CHAR	(100);

	-- DECLARACION DE VARIABLES
	DEFINE iSqlErr	INTEGER;
	DEFINE iSamErr	INTEGER;
	DEFINE sCommit	SMALLINT;
	DEFINE cProceso	CHAR(100);
	DEFINE dFechaIni	DATE;
	DEFINE dFechaFin	DATE;
	DEFINE cCodRet	CHAR(5);
	DEFINE cVarError	CHAR(100);
	DEFINE cRuta	CHAR(30);
	DEFINE cNombreArchivo	CHAR(30);
	DEFINE cSql	CHAR(2048);

	-- INICIALIZAN LAS VARIABLES
	LET cProceso = 'Genera Reporte de Remesas';
	LET dFechaIni = '';
	LET dFechaFin = '';
	LET cCodRet = '00000';
	LET cVarError = 'Ejecucion Existosa';
--	LET cRuta = '/RESPALDOS/';
	LET cRuta = '/RESPALDOSNEW/';
	LET cNombreArchivo = 'repremesashis_';
	LET cSql = '';
	LET sCommit = 0;

	--SET DEBUG FILE TO "/RESPALDOS/sp_genrepremesashis.out";
	--TRACE ON;

	BEGIN

	-- CONTROL DE ERRORES
	ON EXCEPTION SET iSqlErr, iSamErr, cVarError
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cVarError = 'Error No Controlado';
			INSERT INTO bdisac:"informix".sac_reg_gen_rep_remesas(reporte, fecha_inicio, fecha_fin, status_ejecucion, observacion)
			VALUES (cProceso, CURRENT, CURRENT, cCodRet, cVarError);

			RETURN cProceso, cCodRet, cVarError;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- BORRAMOS TABLAS PARA GENERAR UN NUEVO REPORTE
	DROP TABLE IF EXISTS bdisac:tmp_folio_suc;
	DROP TABLE IF EXISTS bdisac:tmp_movimiento;
	DROP TABLE IF EXISTS bdisac:tmp_movimientos_his;
	DROP TABLE IF EXISTS bdisac:tmp_reportes_remasas;
	TRUNCATE TABLE bdisac:"informix".sac_reg_gen_rep_remesas_his;

	-- OBTENEMOS LA FECHA Y HORA DE INICIO DEL PROCESO
	SELECT DBINFO('utc_to_datetime',sh_curtime)
	INTO dFechaIni
	FROM sysmaster:"informix".sysshmvals;

	--INICIA PROCESO PARA LA CREACION DEL ARCHIVO UNLIMITED
	LET cNombreArchivo = TRIM(cNombreArchivo) || TRIM(SUBSTRING(dFechaIni FROM 4 FOR 2)) || TRIM(SUBSTRING(dFechaIni FROM 1 FOR 2)) || TRIM(SUBSTRING(dFechaIni FROM 7 FOR 4)) || '.txt';

	IF cNombreArchivo IS NOT NULL THEN

		-- IDENTIFICAMOS LOS NUMEROS DE FOLIO_SUC DE TODAS LAS REMESAS
		SELECT  DISTINCT a.folio_suc
		FROM    TABLE(MULTISET(SELECT   mh.folio_suc
							   FROM     bdisac:"informix".sac_movimientoshistorial mh
							   WHERE    mh.numcategoria = '07'
							   AND      mh.numconvenio IN ('004','006','007','008','009')
							   AND      mh.fecha_pago = Today - 1
							   AND		mh.status_cancelado = 'N')) a
		INTO TEMP tmp_folio_suc WITH NO LOG;

		-- OBTENEMOS LOS DATOS DE LA TABLA SAC_MOVIMIENTOSHISTORIAL
		SELECT  hs.numcategoria,
				hs.numconvenio,
				hs.folio_suc,
				hs.id_sucursal,
				hs.usuario
		FROM    bdisac:"informix".sac_movimientoshistorial hs,
				bdisac:tmp_folio_suc a
		WHERE   a.folio_suc = hs.folio_suc
		AND     hs.fecha_pago = Today - 1
		INTO TEMP tmp_movimientos WITH NO LOG;

		-- OBTENEMOS LOS DATOS DE LA TABLA SC_MOVHIS
		SELECT    b.numcategoria,
				  b.numconvenio,
				  b.folio_suc,
				  b.id_sucursal,
				  b.usuario,
				  mv.fech_val,
				  mv.fech_hor,
				  mv.transacc,
				  mv.cuenta,
				  mv.monto_tot,
				  mv.cancelad,
				  mv.referencia
		FROM      bdicheq:"informix".sc_movhis mv,
				  bdisac:tmp_movimientos b
		WHERE     b.folio_suc = mv.folio_suc
		AND       mv.fech_alt = Today - 1
		INTO TEMP tmp_movimientos_his WITH NO LOG;
		-- SE QUITAN LAS TRANSACCIONES DE BTS PARA OBTENER TODAS 08/02/2018

		-- ASIGNAMOS EL NOMBRE DEL CONVENIO DE CADA REMESA
		SELECT  cv.nomconvenio,
				d.folio_suc,
				d.id_sucursal,
				d.usuario,
				d.fech_val,
				TRIM(SUBSTRING(d.fech_hor FROM 1 FOR 8)) AS fech_hor,
				d.transacc,
				d.cuenta,
				d.monto_tot,
				d.cancelad,
				d.referencia
		FROM    bdisac:"informix".sac_convenios cv,
				bdisac:tmp_movimientos_his d
		WHERE   d.numconvenio = cv.numconvenio
		AND     d.numcategoria = cv.numcategoria
		INTO TEMP tmp_reporte_remesas WITH NO LOG;

		INSERT INTO informix.sac_reg_gen_rep_remesas_his(h_nomconvenio, h_folio_suc, h_id_sucursal, h_usuario, h_fech_val, h_fech_hor, h_transacc, h_cuenta, h_monto_tot, h_cancelad, h_referencia) 
		VALUES('NOMBRE REMESA', 'FOLIO SUC', 'SUCURSAL', 'USUARIO', 'FECHA', 'HORA', 'TRAN', 'CUENTA', 'MONTO TOTAL', 'CANCELADO', 'REFERENCIA');
		
		-- INSERTAMOS EN LA TABLA PARA SU DESCARGA EN UNLOAD
		INSERT INTO bdisac:"informix".sac_reg_gen_rep_remesas_his
		SELECT  nomconvenio,
				folio_suc,
				id_sucursal,
				usuario,
				fech_val,
				fech_hor,
				transacc,
				cuenta,
				monto_tot,
				cancelad,
				referencia
		FROM	tmp_reporte_remesas;
		
		LET cSql= '';
		LET cSql= 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNombreArchivo) || ' ' ||
					'SELECT h_nomconvenio, h_folio_suc, h_id_sucursal, h_usuario, h_fech_val, h_fech_hor, ' ||
					'h_transacc, h_cuenta, h_monto_tot, h_cancelad, h_referencia ' ||
					'FROM bdisac:"informix".sac_reg_gen_rep_remesas_his ORDER BY h_nomconvenio ASC" > ' || TRIM(cRuta) || 'rep_remesas.sql';
		SYSTEM cSql;
		LET cSql= '';

		LET cSql= "chmod 777 " || TRIM(cRuta) || 'rep_remesas.sql';
		SYSTEM cSql;
		LET cSql= '';

		LET cSql= "dbaccess bdisac " || TRIM(cRuta) || 'rep_remesas.sql';
		SYSTEM cSql;
		LET cSql= '';

		LET cSql= "rm " || TRIM(cRuta) || 'rep_remesas.sql';
		SYSTEM cSql;
		LET cSql= '';	
	END IF;

	LET cProceso = TRIM(cNombreArchivo);
	LET cVarError = 'Creacion de Archivo .UNL';
	LET cCodRet = '00000';

	-- ELIMINAMOS LAS TABLAS E INFORMACIÃ?N DEL REPORTE
	DROP TABLE IF EXISTS bdisac:tmp_folio_suc;
	DROP TABLE IF EXISTS bdisac:tmp_movimiento;
	DROP TABLE IF EXISTS bdisac:tmp_movimientos_his;
	DROP TABLE IF EXISTS bdisac:tmp_reportes_remasas;
	TRUNCATE TABLE bdisac:"informix".sac_reg_gen_rep_remesas_his;

	-- OBTENEMOS LA FECHA Y HORA EN QUE TERMINA EL PROCESO
	SELECT DBINFO('utc_to_datetime',sh_curtime)
	INTO dFechaFin
	FROM sysmaster:"informix".sysshmvals;

	-- INSERTAMOS EL REGISTRO DE LA EJECUCION DEL PROCESO
	INSERT INTO bdisac:"informix".sac_reg_gen_rep_remesas(reporte, fecha_inicio, fecha_fin, status_ejecucion, observacion)
	VALUES (cProceso, dFechaIni, dFechaFin, cCodRet, cVarError);

	RETURN cProceso, cCodRet, cVarError;

	END;
END PROCEDURE;