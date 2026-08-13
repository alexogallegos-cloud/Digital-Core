CREATE PROCEDURE "informix".sp_generaarchivocifras_club_1()
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
DEFINE dFechaHoy DATE;
DEFINE cRuta CHAR(100);
DEFINE cFechaArchivo CHAR(8);
DEFINE cSucursal CHAR(4);
DEFINE iCantMovtos INTEGER;
DEFINE iImporte INTEGER;
DEFINE cTipoMovtos CHAR(1);
DEFINE dFecha DATE;
DEFINE dtFechaHora DATETIME YEAR TO SECOND;

--INICIALIZACION DE VARIABLES--
LET cCodret = '000000';
LET vMensajeRet = '';
LET iSqlErr = 0;
LET iIsamErr = 0;
LET vErrorInfo = '';
LET vProceso = 'sp_generaarchivocifras_club';
LET cSql = '';
LET dFechaHoy = '';
LET cRuta = '';
LET cFechaArchivo = '';
LET cSucursal = '';
LET iCantMovtos = 0;
LET iImporte = 0;
LET cTipoMovtos = '';
LET dFecha = '';
LET dtFechaHora = '';

--SET DEBUG FILE TO "/informix/IrisA/sp_generaarchivocifras_club.out";
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

	SELECT fecha_hoy INTO dFechaHoy 
	FROM "informix".si_fechas WHERE empresa = '001';

	IF TRIM(NVL(dFechaHoy,'')) <> '' THEN

		SELECT valor INTO cRuta 
		FROM "informix".si_param 
		WHERE empresa = '001' AND cod_param = 319;

		IF TRIM(NVL(cRuta,'')) <> '' THEN

			LET cFechaArchivo = YEAR(dFechaHoy) || LPAD(MONTH(dFechaHoy),2,'0') || LPAD(DAY(dFechaHoy),2,'0');

			TRUNCATE TABLE "informix".si_club_cifrastotales;

			FOREACH
				-- SUCURSAL
				SELECT sucursal INTO cSucursal 
				FROM "informix".si_sucursales 
				WHERE empresa = '001' AND tpo_sucursal = 'S'
				ORDER BY sucursal

				-- VENTA
				SELECT COUNT(num_poliza), SUM(monto_pagar::INT) INTO iCantMovtos, iImporte
				FROM "informix".si_club_proteccion 
				WHERE fecha_alta = today-1 AND suc_alta = cSucursal AND aceptada = '1';

				IF NVL(iCantMovtos,0) <> 0 THEN
					INSERT INTO "informix".si_club_cifrastotales(tipomovimiento, cantidadmovtos, sucursal, importe, fecha)
						VALUES('A', iCantMovtos, cSucursal, iImporte, today-1 );
				END IF;

				-- ABONO
				SELECT COUNT(a.referencia1), SUM(a.importe_pago::INT) INTO iCantMovtos, iImporte
				FROM bdisac:sac_movimientoshistorial a, bdisac:"informix".sac_abono_seg b
				WHERE a.referencia1 = b.numcliente AND a.referencia2 = b.recibo AND a.fecha_pago = today-1  
				AND a.fecha_pago = DATE(b.fecha_insert) AND a.id_sucursal = cSucursal 
				AND a.transacc_suc = '8102' AND a.status_cancelado = 'N';

				IF NVL(iCantMovtos,0) <> 0 THEN
					INSERT INTO "informix".si_club_cifrastotales(tipomovimiento, cantidadmovtos, sucursal, importe, fecha)
						VALUES('B', iCantMovtos, cSucursal, iImporte, today-1 );
				END IF;

				-- PAGO DE VENTA
				SELECT COUNT(a.referencia1), SUM(a.importe_pago::INT) INTO iCantMovtos, iImporte
				FROM bdisac:sac_movimientoshistorial a, bdisac:"informix".sac_vta_cambio_seg b
				WHERE a.referencia1 = b.numcliente AND a.referencia2 = b.recibo AND a.fecha_pago = today-1  
				AND a.fecha_pago = DATE(b.fecha_insert) AND a.id_sucursal = cSucursal
				AND a.transacc_suc = '8102' AND a.status_cancelado = 'N' AND b.tipomovimiento = 'C';

				IF NVL(iCantMovtos,0) <> 0 THEN
					INSERT INTO "informix".si_club_cifrastotales(tipomovimiento, cantidadmovtos, sucursal, importe, fecha)
						VALUES('C', iCantMovtos, cSucursal, iImporte, today-1 );
				END IF;

				-- PAGO DE CAMBIO DE PLAN
				SELECT COUNT(a.referencia1), SUM(a.importe_pago::INT) INTO iCantMovtos, iImporte
				FROM bdisac:sac_movimientoshistorial a, bdisac:"informix".sac_vta_cambio_seg b
				WHERE a.referencia1 = b.numcliente AND a.referencia2 = b.recibo AND a.fecha_pago = today-1  
				AND a.fecha_pago = DATE(b.fecha_insert) AND a.id_sucursal = cSucursal
				AND a.transacc_suc = '8102' AND a.status_cancelado = 'N' AND b.tipomovimiento = 'K';

				IF NVL(iCantMovtos,0) <> 0 THEN
					INSERT INTO "informix".si_club_cifrastotales(tipomovimiento, cantidadmovtos, sucursal, importe, fecha)
						VALUES('K', iCantMovtos, cSucursal, iImporte, today-1 );
				END IF;

				-- CAMBIO DE BENEFICIARIO
				SELECT COUNT(DISTINCT numcte) INTO iCantMovtos 
				FROM "informix".si_club_beneficiario 
				WHERE tipo_mov = 'C' AND fecha_modificacion = today-1  AND suc_cambio = cSucursal;

				IF NVL(iCantMovtos,0) <> 0 THEN
					INSERT INTO "informix".si_club_cifrastotales(tipomovimiento, cantidadmovtos, sucursal, importe, fecha)
						VALUES('D', iCantMovtos, cSucursal, 0, today-1 );
				END IF;

				-- CAMBIO DE PLAN
				SELECT COUNT(num_poliza), SUM(monto_pagar::INT) INTO iCantMovtos, iImporte
				FROM "informix".si_club_proteccion 
				WHERE tipo_mov = 'C' AND fecha_cambio = today-1  AND suc_cambio = cSucursal;

				IF NVL(iCantMovtos,0) <> 0 THEN
					INSERT INTO "informix".si_club_cifrastotales(tipomovimiento, cantidadmovtos, sucursal, importe, fecha)
						VALUES('H', iCantMovtos, cSucursal, iImporte, today-1 );
				END IF;

			END FOREACH;

			UPDATE statistics medium FOR TABLE "informix".si_club_cifrastotales;

			LET cSql = '';
            LET cSql = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'cifrasclub1' || TRIM(cFechaArchivo) || '.txt' || ' DELIMITER ' || '''|''' ||
                        ' SELECT tipomovimiento, cantidadmovtos, sucursal, importe, fecha' ||
                        ' FROM si_club_cifrastotales ' || ';' ||
                        ' " > cifrasclub.sql';
            SYSTEM cSql; 

            LET cSql = '';
            LET cSql = 'dbaccess bdinteg cifrasclub.sql';
            SYSTEM cSql;

			LET cSql = '';
            LET cSql = "sed 's/|$//g' " || TRIM(cRuta) || 'cifrasclub1' || TRIM(cFechaArchivo) || '.txt' || " > " || TRIM(cRuta) || 'cifrasclub2' || TRIM(cFechaArchivo) || '.txt';
            SYSTEM cSql; 

			LET cSql = '';
            LET cSql = "sed 's/$'/`echo \\\r`/ " || TRIM(cRuta) || 'cifrasclub2' || TRIM(cFechaArchivo) || '.txt' || " > " || TRIM(cRuta) || 'cifrasclub' || TRIM(cFechaArchivo) || '.txt';
            SYSTEM cSql;

            LET cSql = '';
            LET cSql = 'rm cifrasclub.sql';
            SYSTEM cSql; 

			LET cSql = '';
            LET cSql = 'rm ' || TRIM(cRuta) || 'cifrasclub1' || TRIM(cFechaArchivo) || '.txt';
            SYSTEM cSql; 

			LET cSql = '';
            LET cSql = 'rm ' || TRIM(cRuta) || 'cifrasclub2' || TRIM(cFechaArchivo) || '.txt';
            SYSTEM cSql; 

			FOREACH
				SELECT tipomovimiento, cantidadmovtos, sucursal, importe, fecha, fecha_hora
				INTO cTipoMovtos, iCantMovtos, cSucursal, iImporte, dFecha, dtFechaHora
				FROM "informix".si_club_cifrastotales

				INSERT INTO "informix".si_club_cifrastotales_hist(tipomovimiento, cantidadmovtos, sucursal, importe, fecha, fecha_hora)
					VALUES(cTipoMovtos, iCantMovtos, cSucursal, iImporte, dFecha, dtFechaHora);
			END FOREACH;

		ELSE
			LET cCodret = '002';
			LET vMensajeRet = 'No Existe Ruta';
		END IF;
	ELSE
		LET cCodret = '001';
		LET vMensajeRet = 'No Existe Fecha';
	END IF;

	IF cCodret <> '000000' THEN
		INSERT INTO "informix".si_club_bitacoradomiciliacion(proceso, codigoretorno, mensajeretorno, fec_paquete)
			VALUES(vProceso, cCodret, vMensajeRet, dFechaHoy);
	END IF;

	RETURN cCodret;
END;
END PROCEDURE;