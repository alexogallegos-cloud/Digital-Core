CREATE PROCEDURE "informix".sp_generaarchivocifras_club()
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
DEFINE cFolioSuc CHAR(16);
DEFINE cTransacc CHAR(4);
DEFINE mMontoTot MONEY(14,2);
DEFINE cNumCliente CHAR(40);
DEFINE cRecibo CHAR(40);
DEFINE cEstatusCancelado CHAR(1);
DEFINE iCantMovtosAbono INTEGER;
DEFINE iImporteAbono INTEGER;
DEFINE iCantMovtosVenta INTEGER;
DEFINE iImporteVenta INTEGER;
DEFINE iCantMovtosCambio INTEGER;
DEFINE iImporteCambio INTEGER;

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
LET cFolioSuc = '';
LET cTransacc = '';
LET mMontoTot = 0;
LET cNumCliente = '';
LET cEstatusCancelado = '';
LET iCantMovtosAbono = 0;
LET iImporteAbono = 0;
LET iCantMovtosVenta = 0;
LET iImporteVenta = 0;
LET iCantMovtosCambio = 0;
LET iImporteCambio = 0;

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
				WHERE fecha_alta = dFechaHoy AND suc_alta = cSucursal AND aceptada = '1';

				IF NVL(iCantMovtos,0) <> 0 THEN
					INSERT INTO "informix".si_club_cifrastotales(tipomovimiento, cantidadmovtos, sucursal, importe, fecha)
						VALUES('A', iCantMovtos, cSucursal, iImporte, dFechaHoy);
				END IF;

				LET iCantMovtosAbono = 0;
				LET iImporteAbono = 0;
				LET iCantMovtosVenta = 0;
				LET iImporteVenta = 0;
				LET iCantMovtosCambio = 0;
				LET iImporteCambio = 0;

				FOREACH
					SELECT folio_suc, transacc, monto_tot INTO cFolioSuc, cTransacc, mMontoTot
					FROM bdicheq:"informix".sc_movdia
					WHERE fech_alt = dFechaHoy AND transacc IN('1303','1363','1393') 
					AND empresa = '001' AND cancelad <> 'S' AND sucursal = cSucursal

					SELECT referencia1, referencia2, status_cancelado INTO cNumCliente, cRecibo, cEstatusCancelado
					FROM bdisac:"informix".sac_movimientos
					WHERE fecha_pago = dFechaHoy AND id_sucursal = cSucursal AND folio_suc = cFolioSuc;

					IF NVL(cNumCliente,'') <> '' THEN
						-- ABONO
						IF EXISTS(SELECT 1 FROM bdisac:"informix".sac_abono_seg WHERE sucursal = cSucursal AND numcliente = cNumCliente 
							AND recibo = cRecibo) THEN
							LET iCantMovtosAbono = iCantMovtosAbono + 1;
							LET iImporteAbono = iImporteAbono + mMontoTot::INT; 

						-- PAGO DE VENTA
						ELIF EXISTS(SELECT 1 FROM bdisac:"informix".sac_vta_cambio_seg WHERE sucursal = cSucursal AND numcliente = cNumCliente 
							AND recibo = cRecibo AND tipomovimiento = 'C') THEN
							LET iCantMovtosVenta = iCantMovtosVenta + 1;
							LET iImporteVenta = iImporteVenta + mMontoTot::INT; 
						
						-- PAGO DE CAMBIO DE PLAN
						ELIF EXISTS(SELECT 1 FROM bdisac:"informix".sac_vta_cambio_seg WHERE sucursal = cSucursal AND numcliente = cNumCliente 
							AND recibo = cRecibo AND tipomovimiento = 'K') THEN
							LET iCantMovtosCambio = iCantMovtosCambio + 1;
							LET iImporteCambio = iImporteCambio + mMontoTot::INT;
							
						ELSE
							INSERT INTO "informix".si_club_movimientosfaltantes(sucursal, folio_suc, transacc, monto_tot, status_cancelado, fecha_insert)
								VALUES(cSucursal, cFolioSuc, cTransacc, mMontoTot, cEstatusCancelado, dFechaHoy);

							LET iCantMovtosVenta = iCantMovtosVenta + 1;
							LET iImporteVenta = iImporteVenta + mMontoTot::INT;
						END IF;
					ELSE
						INSERT INTO "informix".si_club_movimientosfaltantes(sucursal, folio_suc, transacc, monto_tot, status_cancelado, fecha_insert)
							VALUES(cSucursal, cFolioSuc, cTransacc, mMontoTot, cEstatusCancelado, dFechaHoy);

						LET iCantMovtosVenta = iCantMovtosVenta + 1;
						LET iImporteVenta = iImporteVenta + mMontoTot::INT;
					END IF;
				END FOREACH;
					
				IF NVL(iCantMovtosAbono,0) <> 0 THEN
					INSERT INTO "informix".si_club_cifrastotales(tipomovimiento, cantidadmovtos, sucursal, importe, fecha)
						VALUES('B', iCantMovtosAbono, cSucursal, iImporteAbono, dFechaHoy);
				END IF;

				IF NVL(iCantMovtosVenta,0) <> 0 THEN
					INSERT INTO "informix".si_club_cifrastotales(tipomovimiento, cantidadmovtos, sucursal, importe, fecha)
						VALUES('C', iCantMovtosVenta, cSucursal, iImporteVenta, dFechaHoy);
				END IF;

				IF NVL(iCantMovtosCambio,0) <> 0 THEN
					INSERT INTO "informix".si_club_cifrastotales(tipomovimiento, cantidadmovtos, sucursal, importe, fecha)
						VALUES('K', iCantMovtosVenta, cSucursal, iImporteCambio, dFechaHoy);
				END IF;

				-- CAMBIO DE BENEFICIARIO
				SELECT COUNT(DISTINCT numcte) INTO iCantMovtos 
				FROM "informix".si_club_beneficiario 
				WHERE fecha_modificacion = dFechaHoy AND suc_cambio = cSucursal AND tipo_mov = 'C';

				IF NVL(iCantMovtos,0) <> 0 THEN
					INSERT INTO "informix".si_club_cifrastotales(tipomovimiento, cantidadmovtos, sucursal, importe, fecha)
						VALUES('D', iCantMovtos, cSucursal, 0, dFechaHoy);
				END IF;

				-- CAMBIO DE PLAN
				SELECT COUNT(num_poliza), SUM(monto_pagar::INT) INTO iCantMovtos, iImporte
				FROM "informix".si_club_proteccion 
				WHERE fecha_cambio = dFechaHoy AND suc_cambio = cSucursal AND tipo_mov = 'C';

				IF NVL(iCantMovtos,0) <> 0 THEN
					INSERT INTO "informix".si_club_cifrastotales(tipomovimiento, cantidadmovtos, sucursal, importe, fecha)
						VALUES('H', iCantMovtos, cSucursal, iImporte, dFechaHoy);
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