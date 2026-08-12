CREATE PROCEDURE "informix".sp_obtienepagosventa_club(pFecha DATE)
--DATOS A REGRESAR--
RETURNING CHAR(6) AS CodigoRetorno;

--DEFINICION DE VARIABLES--
DEFINE cCodret CHAR(6);
DEFINE vMensajeRet VARCHAR(80);
DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE vErrorInfo VARCHAR(80);
DEFINE vProceso VARCHAR(30);
DEFINE cSql CHAR(1024);
DEFINE cRuta CHAR(100);
DEFINE dFechaHoy DATE;
DEFINE cFechaArchivo CHAR(8);

--INICIALIZACION DE VARIABLES--
LET cCodret = '000';
LET vMensajeRet = '';
LET iSqlErr = 0;
LET iIsamErr = 0;
LET vErrorInfo = '';
LET vProceso = 'sp_obtienepagosventa_club';
LET cSql = '';
LET cRuta = '';
LET dFechaHoy = '';
LET cFechaArchivo = '';

--SET DEBUG FILE TO "/informix/IrisA/sp_obtienepagosventa_club.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cCodret = iSqlErr;
			LET vMensajeRet = vErrorInfo;
			INSERT INTO "informix".si_club_bitacoradomiciliacion(proceso, codigoretorno, mensajeretorno, fec_paquete)
				VALUES(vProceso, cCodret, vMensajeRet, dFechaHoy);
			RETURN cCodret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;

	SELECT fecha_hoy INTO dFechaHoy FROM "informix".si_fechas WHERE empresa = '001';

	IF TRIM(NVL(dFechaHoy,'')) <> '' THEN

		SELECT valor INTO cRuta FROM "informix".si_param WHERE empresa = '001' AND cod_param = 319;

		IF TRIM(NVL(cRuta,'')) <> '' THEN

			IF TRIM(NVL(pFecha,'')) = '' THEN

				LET cFechaArchivo = YEAR(dFechaHoy) || LPAD(MONTH(dFechaHoy),2,'0') || LPAD(DAY(dFechaHoy),2,'0');

				LET cSql = '';
				LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || 'club1' || TRIM(cFechaArchivo) || '.txt' || ' DELIMITER ' || '''|''' ||
							' SELECT d.fecha_alta, d.suc_alta, d.ejecutivo, d.numcte, d.tipo_plan ' ||
							' FROM bdisac:"informix".sac_movimientos a ' ||
							' INNER JOIN bdisac:"informix".sac_vta_cambio_seg b ON(b.numcliente = a.referencia1 AND b.recibo = a.referencia2 AND b.tipomovimiento = ''C'') ' ||
							' JOIN bdinteg:"informix".si_club_proteccion d ON(d.num_poliza = b.poliza AND aceptada = 1) ' ||
							' WHERE a.fecha_pago = ''' || dFechaHoy || ''' AND a.transacc_suc = ''8102'' AND a.status_cancelado = ''N'' ' ||
							' ORDER BY d.suc_alta, d.ejecutivo, d.numcte ' || ';' ||
							' " > pagosventaclub.sql';
				SYSTEM cSql; 

			ELSE

				LET cFechaArchivo = YEAR(pFecha) || LPAD(MONTH(pFecha),2,'0') || LPAD(DAY(pFecha),2,'0');

				LET cSql = '';
				LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || 'club1' || TRIM(cFechaArchivo) || '.txt' || ' DELIMITER ' || '''|''' ||
							' SELECT d.fecha_alta, d.suc_alta, d.ejecutivo, d.numcte, d.tipo_plan ' ||
							' FROM bdisac:"informix".sac_movimientoshistorial a ' ||
							' INNER JOIN bdisac:"informix".sac_vta_cambio_seg b ON(b.numcliente = a.referencia1 AND b.recibo = a.referencia2 AND b.tipomovimiento = ''C'') ' ||
							' JOIN bdinteg:"informix".si_club_proteccion d ON(d.num_poliza = b.poliza AND aceptada = 1) ' ||
							' WHERE a.fecha_pago = ''' || pFecha || ''' AND a.transacc_suc = ''8102'' AND a.status_cancelado = ''N'' ' ||
							' ORDER BY d.suc_alta, d.ejecutivo, d.numcte ' || ';' ||
							' " > pagosventaclub.sql';
				SYSTEM cSql; 

			END IF;

			LET cSql = '';
			LET cSql = 'dbaccess bdinteg pagosventaclub.sql';
			SYSTEM cSql; 

			LET cSql = '';
			LET cSql = "sed 's/|$//g' " || TRIM(cRuta) || 'club1' || TRIM(cFechaArchivo) || '.txt' || " > " || TRIM(cRuta) || 'club' || TRIM(cFechaArchivo) || '.txt';
			SYSTEM cSql; 

			LET cSql = '';
			LET cSql = 'rm pagosventaclub.sql';
			SYSTEM cSql; 

			LET cSql = '';
			LET cSql = 'rm ' || TRIM(cRuta) || 'club1' || TRIM(cFechaArchivo) || '.txt';
			SYSTEM cSql; 
		ELSE
			LET cCodret = '002';
			LET vMensajeRet = 'No Existe Ruta';
		END IF;
	ELSE
		LET cCodret = '001';
		LET vMensajeRet = 'No Existe Fecha';
	END IF;

	IF cCodret <> '000' THEN
		INSERT INTO "informix".si_club_bitacoradomiciliacion(proceso, codigoretorno, mensajeretorno, fec_paquete)
			VALUES(vProceso, cCodret, vMensajeRet, dFechaHoy);
	END IF;

	RETURN cCodret;
END;
END PROCEDURE;