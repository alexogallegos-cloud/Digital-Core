CREATE PROCEDURE "informix".sp_generaarchivodetalle_club()
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
DEFINE cNumCte CHAR(20);
DEFINE cNumCteCoppel CHAR(20);
DEFINE iImporte INTEGER;
DEFINE dFecha DATE;
DEFINE cFecha CHAR(10);
DEFINE cCantSeguros CHAR(1);
DEFINE iMesesPagados INTEGER;
DEFINE dFechaNac DATE;
DEFINE cFechaNac CHAR(10);
DEFINE cPoliza CHAR(20);
DEFINE dFechaVenc DATE;
DEFINE cFechaVenc CHAR(10);
DEFINE cRecibo CHAR(40);
DEFINE cFlagDom CHAR(1);
DEFINE cPrimerNombre1 CHAR(26);
DEFINE cSegundoNombre1 CHAR(26);
DEFINE cNombre1 CHAR(15);
DEFINE cApellidoPat1 CHAR(15);
DEFINE cApellidoMat1 CHAR(15);
DEFINE cParentesco1 CHAR(1);
DEFINE iPorcentaje1	DECIMAL(23);
DEFINE cPrimerNombre2 CHAR(26);
DEFINE cSegundoNombre2 CHAR(26);
DEFINE cNombre2 CHAR(15);
DEFINE cApellidoPat2 CHAR(15);
DEFINE cApellidoMat2 CHAR(15);
DEFINE cParentesco2 CHAR(1);
DEFINE iPorcentaje2 DECIMAL(23);
DEFINE cPrimerNombre3 CHAR(26);
DEFINE cSegundoNombre3 CHAR(26);
DEFINE cNombre3 CHAR(15);
DEFINE cApellidoPat3 CHAR(15);
DEFINE cApellidoMat3 CHAR(15);
DEFINE cParentesco3 CHAR(1);
DEFINE iPorcentaje3 DECIMAL(23);
DEFINE cSucursal CHAR(4);
DEFINE cEmpleado CHAR(8);
DEFINE cCiudadSucursal CHAR(4);
DEFINE cEstadoSucursal CHAR(2);
DEFINE iCiudadTienda INTEGER;
DEFINE cFolioSuc CHAR(16);
DEFINE cTipoMov CHAR(1);
DEFINE cClaveMov CHAR(1);
DEFINE cClaveSeguro CHAR(1);
DEFINE sCantSegurosAnt SMALLINT;
DEFINE sCantSegurosNva SMALLINT;
DEFINE sCaja SMALLINT;
DEFINE cArea CHAR(1);
DEFINE cFechaConcilia CHAR(10);

--INICIALIZACION DE VARIABLES--
LET cCodret = '000';
LET vMensajeRet = '';
LET iSqlErr = 0;
LET iIsamErr = 0;
LET vErrorInfo = '';
LET vProceso = 'sp_generaarchivodetalle_club';
LET cSql = '';
LET dFechaHoy = DATE(1);
LET cRuta = '';
LET cFechaArchivo = '';
LET cNumCte = '';
LET cNumCteCoppel = '';
LET iImporte = 0;
LET dFecha = DATE(1);
LET cFecha = '';
LET cCantSeguros = '';
LET iMesesPagados = 0;
LET dFechaNac = DATE(1);
LET cFechaNac = '';
LET cPoliza = '';
LET dFechaVenc = DATE(1);
LET cFechaVenc = '';
LET cRecibo = '';
LET cFlagDom = 0;
LET cNombre1 = '';
LET cApellidoPat1 = '';
LET cApellidoMat1 = '';
LET cParentesco1 = '';
LET iPorcentaje1 = 0;
LET cNombre2 = '';
LET cApellidoPat2 = '';
LET cApellidoMat2 = '';
LET cParentesco2 = '';
LET iPorcentaje2 = 0;
LET cNombre3 = '';
LET cApellidoPat3 = '';
LET cApellidoMat3 = '';
LET cParentesco3 = '';
LET iPorcentaje3 = 0;
LET cSucursal = 0;
LET cEmpleado = 0;
LET cCiudadSucursal = '';
LET cEstadoSucursal = '';
LET iCiudadTienda = 0;
LET cFolioSuc = '';
LET cTipoMov = '';
LET cClaveMov = '';
LET cClaveSeguro = '';
LET sCantSegurosAnt = 0;
LET sCantSegurosNva = 0;
LET sCaja = 0;
LET cArea = '';
LET cFechaConcilia = '';

--SET DEBUG FILE TO "/informix/IrisA/sp_generaarchivodetalle_club.out";
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

			LET cFechaArchivo = YEAR(dFechaHoy) || LPAD(MONTH(dFechaHoy),2,'0') || LPAD(DAY(dFechaHoy),2,'0');

			TRUNCATE TABLE "informix".si_club_detalle;

			-- VENTA
			FOREACH
				SELECT numcte, numcte_coppel, monto_pagar::INT, fecha_alta, tipo_plan, meses_pagar, num_poliza, fecha_vencimiento, tipo_pago, suc_alta, ejecutivo
				INTO cNumCte, cNumCteCoppel, iImporte, dFecha, cCantSeguros, iMesesPagados, cPoliza, dFechaVenc, cFlagDom, cSucursal, cEmpleado
				FROM "informix".si_club_proteccion 
				WHERE fecha_alta = dFechaHoy AND aceptada = '1'
				ORDER BY suc_alta

				IF NVL(cNumCte,'') <> '' THEN
					SELECT fecha_nac INTO dFechaNac
					FROM "informix".si_ctepf WHERE numcte = cNumCte;

					SELECT a.primer_nombre, a.segundo_nombre, a.apell_paterno, a.apell_materno, a.parentesco, a.porcentaje::INT, 
						b.primer_nombre, b.segundo_nombre, b.apell_paterno, b.apell_materno, b.parentesco, b.porcentaje::INT, 
						d.primer_nombre, d.segundo_nombre, d.apell_paterno, d.apell_materno, d.parentesco, d.porcentaje::INT
					INTO cPrimerNombre1, cSegundoNombre1, cApellidoPat1, cApellidoMat1, cParentesco1, iPorcentaje1,
						cPrimerNombre2, cSegundoNombre2, cApellidoPat2, cApellidoMat2, cParentesco2, iPorcentaje2,
						cPrimerNombre3, cSegundoNombre3, cApellidoPat3, cApellidoMat3, cParentesco3, iPorcentaje3
					FROM "informix".si_club_beneficiario a
					LEFT JOIN "informix".si_club_beneficiario b ON (a.numcte = b.numcte AND b.secuencia = '2')
					LEFT JOIN "informix".si_club_beneficiario d ON (a.numcte = d.numcte AND d.secuencia = '3')
					WHERE a.numcte = cNumCte AND a.secuencia = '1';

					LET cNombre1 = SUBSTR((TRIM(NVL(cPrimerNombre1,'')) || ' ' || TRIM(NVL(cSegundoNombre1,''))),1,15);
					LET cApellidoPat1 = SUBSTR(TRIM(NVL(cApellidoPat1,'')),1,15);
					LET cApellidoMat1 = SUBSTR(TRIM(NVL(cApellidoMat1,'')),1,15);
					LET cNombre2 = SUBSTR((TRIM(NVL(cPrimerNombre2,'')) || ' ' || TRIM(NVL(cSegundoNombre2,''))),1,15);
					LET cApellidoPat2 = SUBSTR(TRIM(NVL(cApellidoPat2,'')),1,15);
					LET cApellidoMat2 = SUBSTR(TRIM(NVL(cApellidoMat2,'')),1,15);
					LET cNombre3 = SUBSTR(TRIM((cPrimerNombre3) || ' ' || TRIM(cSegundoNombre3)),1,15);
					LET cApellidoPat3 = SUBSTR(TRIM(NVL(cApellidoPat3,'')),1,15);
					LET cApellidoMat3 = SUBSTR(TRIM(NVL(cApellidoMat3,'')),1,15);
					IF dFecha IS NULL THEN
						LET dFecha = DATE(1);
					END IF;
					IF dFechaNac IS NULL THEN
						LET dFechaNac = DATE(1);
					END IF;
					IF dFechaVenc IS NULL THEN
						LET dFechaVenc = DATE(1);
					END IF;
					LET cFecha = YEAR(dFecha) || LPAD(MONTH(dFecha),2,'0') || LPAD(DAY(dFecha),2,'0');
					LET cFechaNac = YEAR(dFechaNac) || LPAD(MONTH(dFechaNac),2,'0') || LPAD(DAY(dFechaNac),2,'0');
					LET cFechaVenc = YEAR(dFechaVenc) || LPAD(MONTH(dFechaVenc),2,'0') || LPAD(DAY(dFechaVenc),2,'0');

					/*SELECT ciudad, estado INTO cCiudadSucursal, cEstadoSucursal
					FROM "informix".si_sucursales WHERE sucursal = cSucursal;*/
					
					SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad, cve_estado
                    INTO cCiudadSucursal, cEstadoSucursal
                    FROM bdinteg:"informix".si_ptf 
                    WHERE id_ptf = cSucursal AND tipo='S';	
									

					SELECT FIRST 1 ciudad_coppel INTO iCiudadTienda
					FROM "informix".si_ciudades
					WHERE ciudad = cCiudadSucursal AND estado = cEstadoSucursal and ciudad_coppel <> 0;

					IF NVL(iCiudadTienda,0) = 0 THEN
						SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad_coppel) = 'V' THEN ciudad_coppel::INTEGER ELSE 0 END
						INTO iCiudadTienda FROM bdinteg:"informix".si_ciudades WHERE ciudad = cCiudadSucursal and ciudad_coppel <> 0;
					END IF;

					IF NVL(iCiudadTienda,0) = 0 THEN
						SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad_coppel) = 'V' THEN ciudad_coppel::INTEGER ELSE 0 END
						INTO iCiudadTienda FROM bdinteg:"informix".si_ciudades WHERE ciudad_coppel <> 0;
					END IF;

					INSERT INTO "informix".si_club_detalle(clavemovimiento, tipomovimiento, numcliente, importe, fecha, cantidadseguros, claveseguro, 
						mesespagados, fechanacimiento, poliza, fechavencimiento, recibo, cantidadsegurosant, cantidadsegurosnueva, flagdomiciliacion, 
						nombre1, apellidopaterno1, apellidomaterno1, parentesco1, porcentaje1, nombre2, apellidopaterno2, apellidomaterno2, parentesco2, 
						porcentaje2, nombre3, apellidopaterno3, apellidomaterno3, parentesco3, porcentaje3, sucursal, caja, area, empleadoefectuo, 
						ciudad, fechaconciliacion)
					VALUES('G', 'A', TRIM(NVL(cNumCteCoppel,'0')), NVL(iImporte,0), TRIM(NVL(cFecha,'')), NVL(cCantSeguros,'0'), 'C', 
						NVL(iMesesPagados,0), TRIM(NVL(cFechaNac,'')), TRIM(NVL(cPoliza,'0')), NVL(cFechaVenc,''), 0, 0, '0', NVL(cFlagDom,'0'), 
						TRIM(NVL(cNombre1,'')), TRIM(NVL(cApellidoPat1,'')), TRIM(NVL(cApellidoMat1,'')), NVL(cParentesco1,'0'), NVL(iPorcentaje1,0), 
						TRIM(NVL(cNombre2,'')), TRIM(NVL(cApellidoPat2,'')), TRIM(NVL(cApellidoMat2,'')), NVL(cParentesco2,'0'), NVL(iPorcentaje2,0), 
						TRIM(NVL(cNombre3,'')), TRIM(NVL(cApellidoPat3,'')), TRIM(NVL(cApellidoMat3,'')), NVL(cParentesco3,'0'), NVL(iPorcentaje3,0), 
						NVL(cSucursal,'0'), 100, 'B', NVL(cEmpleado,'0'), NVL(iCiudadTienda,0), NVL(cFechaArchivo,''));
				END IF;
			END FOREACH;

			FOREACH
				SELECT folio_suc, monto_tot::INT, sucursal, fech_alt, usuario 
				INTO cFolioSuc, iImporte, cSucursal, dFecha, cEmpleado
				FROM bdicheq:"informix".sc_movdia
				WHERE fech_alt = dFechaHoy AND transacc IN('1303','1363','1393') AND empresa = '001' AND cancelad <> 'S'
				ORDER BY sucursal

				SELECT referencia1, referencia2 INTO cNumCteCoppel, cRecibo
				FROM bdisac:"informix".sac_movimientos
				WHERE fecha_pago = dFechaHoy AND id_sucursal = cSucursal AND folio_suc = cFolioSuc;

				IF NVL(cNumCteCoppel,'') <> '' THEN
					LET cCantSeguros = '0';
					LET iMesesPagados = 0;
					IF dFecha IS NULL THEN
						LET dFecha = DATE(1);
					END IF;
					LET dFechaNac = DATE(1);
					LET dFechaVenc = DATE(1);
					LET cFecha = YEAR(dFecha) || LPAD(MONTH(dFecha),2,'0') || LPAD(DAY(dFecha),2,'0');
					LET cFechaNac = YEAR(dFechaNac) || LPAD(MONTH(dFechaNac),2,'0') || LPAD(DAY(dFechaNac),2,'0');
					LET cFechaVenc = YEAR(dFechaVenc) || LPAD(MONTH(dFechaVenc),2,'0') || LPAD(DAY(dFechaVenc),2,'0');

					-- ABONO
					IF EXISTS(SELECT 1 FROM bdisac:"informix".sac_abono_seg WHERE sucursal = cSucursal 
						AND numcliente = cNumCteCoppel AND recibo = cRecibo) THEN
						LET cTipoMov = 'B';

						SELECT poliza, cantidadseguros, mesespagados, fechanacimiento, fechavencimiento
						INTO cPoliza, cCantSeguros, iMesesPagados, cFechaNac, cFechaVenc
						FROM bdisac:"informix".sac_abono_seg 
						WHERE sucursal = cSucursal AND numcliente = cNumCteCoppel AND recibo = cRecibo;

					-- PAGO DE VENTA
					ELIF EXISTS(SELECT 1 FROM bdisac:"informix".sac_vta_cambio_seg WHERE sucursal = cSucursal 
						AND numcliente = cNumCteCoppel AND recibo = cRecibo AND tipomovimiento = 'C') THEN
						LET cTipoMov = 'C';

						SELECT poliza INTO cPoliza
						FROM bdisac:"informix".sac_vta_cambio_seg 
						WHERE sucursal = cSucursal AND numcliente = cNumCteCoppel AND recibo = cRecibo AND tipomovimiento = 'C';

					-- PAGO DE CAMBIO DE PLAN
					ELIF EXISTS(SELECT 1 FROM bdisac:"informix".sac_vta_cambio_seg WHERE sucursal = cSucursal 
						AND numcliente = cNumCteCoppel AND recibo = cRecibo AND tipomovimiento = 'K') THEN
						LET cTipoMov = 'K';

						SELECT poliza INTO cPoliza
						FROM bdisac:"informix".sac_vta_cambio_seg 
						WHERE sucursal = cSucursal AND numcliente = cNumCteCoppel AND recibo = cRecibo AND tipomovimiento = 'K';
					END IF;

					/*SELECT ciudad, estado INTO cCiudadSucursal, cEstadoSucursal
					FROM "informix".si_sucursales WHERE sucursal = cSucursal;*/
					
					SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad, cve_estado
                    INTO cCiudadSucursal, cEstadoSucursal
                    FROM bdinteg:"informix".si_ptf 
                    WHERE id_ptf = cSucursal AND tipo='S';	
					

					SELECT FIRST 1 ciudad_coppel INTO iCiudadTienda
					FROM "informix".si_ciudades
					WHERE ciudad = cCiudadSucursal AND estado = cEstadoSucursal and ciudad_coppel <> 0;

					IF NVL(iCiudadTienda,0) = 0 THEN
						SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad_coppel) = 'V' THEN ciudad_coppel::INTEGER ELSE 0 END
						INTO iCiudadTienda FROM bdinteg:"informix".si_ciudades WHERE ciudad = cCiudadSucursal and ciudad_coppel <> 0;
					END IF;

					IF NVL(iCiudadTienda,0) = 0 THEN
						SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad_coppel) = 'V' THEN ciudad_coppel::INTEGER ELSE 0 END
						INTO iCiudadTienda FROM bdinteg:"informix".si_ciudades WHERE ciudad_coppel <> 0;
					END IF;

					INSERT INTO "informix".si_club_detalle(clavemovimiento, tipomovimiento, numcliente, importe, fecha, cantidadseguros, claveseguro, 
						mesespagados, fechanacimiento, poliza, fechavencimiento, recibo, cantidadsegurosant, cantidadsegurosnueva, flagdomiciliacion, 
						nombre1, apellidopaterno1, apellidomaterno1, parentesco1, porcentaje1, nombre2, apellidopaterno2, apellidomaterno2, parentesco2, 
						porcentaje2, nombre3, apellidopaterno3, apellidomaterno3, parentesco3, porcentaje3, sucursal, caja, area, empleadoefectuo, 
						ciudad, fechaconciliacion)
					VALUES('G', NVL(cTipoMov,''), TRIM(NVL(cNumCteCoppel,'0')), NVL(iImporte,0), TRIM(NVL(cFecha,'')), NVL(cCantSeguros,'0'), '', 
						NVL(iMesesPagados,0), TRIM(NVL(cFechaNac,'')), TRIM(NVL(cPoliza,'0')), NVL(cFechaVenc,''), TRIM(NVL(cRecibo,'')), 0, '0', '0',
						'', '', '', '0', 0, '', '', '', '0', 0, '', '', '', '0', 0, 
						NVL(cSucursal,'0'), 100, 'B', NVL(cEmpleado,'0'), NVL(iCiudadTienda,0), NVL(cFechaArchivo,''));
				END IF;
			END FOREACH;

			-- CAMBIO DE PLAN
			FOREACH
				SELECT numcte, numcte_coppel, monto_pagar::INT, fecha_alta, tipo_plan, meses_pagar, num_poliza, fecha_vencimiento, tipo_pago, suc_cambio, ejecutivo, tipoplan_ant
				INTO cNumCte, cNumCteCoppel, iImporte, dFecha, sCantSegurosNva, iMesesPagados, cPoliza, dFechaVenc, cFlagDom, cSucursal, cEmpleado, sCantSegurosAnt
				FROM "informix".si_club_proteccion 
				WHERE fecha_cambio = dFechaHoy AND suc_cambio = cSucursal AND tipo_mov = 'C'
				ORDER BY suc_cambio

				IF NVL(cNumCte,'') <> '' THEN
					SELECT fecha_nac INTO dFechaNac 
					FROM "informix".si_ctepf WHERE numcte = cNumCte;

					IF dFecha IS NULL THEN
						LET dFecha = DATE(1);
					END IF;
					IF dFechaNac IS NULL THEN
						LET dFechaNac = DATE(1);
					END IF;
					IF dFechaVenc IS NULL THEN
						LET dFechaVenc = DATE(1);
					END IF;
					LET cFecha = YEAR(dFecha) || LPAD(MONTH(dFecha),2,'0') || LPAD(DAY(dFecha),2,'0');
					LET cFechaNac = YEAR(dFechaNac) || LPAD(MONTH(dFechaNac),2,'0') || LPAD(DAY(dFechaNac),2,'0');
					LET cFechaVenc = YEAR(dFechaVenc) || LPAD(MONTH(dFechaVenc),2,'0') || LPAD(DAY(dFechaVenc),2,'0');

					/*SELECT ciudad, estado INTO cCiudadSucursal, cEstadoSucursal
					FROM "informix".si_sucursales WHERE sucursal = cSucursal;*/

					SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad, cve_estado
                    INTO cCiudadSucursal, cEstadoSucursal
                    FROM bdinteg:"informix".si_ptf 
                    WHERE id_ptf = cSucursal AND tipo='S';	
													
					SELECT FIRST 1 ciudad_coppel INTO iCiudadTienda
					FROM "informix".si_ciudades
					WHERE ciudad = cCiudadSucursal AND estado = cEstadoSucursal and ciudad_coppel <> 0;

					IF NVL(iCiudadTienda,0) = 0 THEN
						SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad_coppel) = 'V' THEN ciudad_coppel::INTEGER ELSE 0 END
						INTO iCiudadTienda FROM bdinteg:"informix".si_ciudades WHERE ciudad = cCiudadSucursal and ciudad_coppel <> 0;
					END IF;

					IF NVL(iCiudadTienda,0) = 0 THEN
						SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad_coppel) = 'V' THEN ciudad_coppel::INTEGER ELSE 0 END
						INTO iCiudadTienda FROM bdinteg:"informix".si_ciudades WHERE ciudad_coppel <> 0;
					END IF;

					INSERT INTO "informix".si_club_detalle(clavemovimiento, tipomovimiento, numcliente, importe, fecha, cantidadseguros, claveseguro, 
						mesespagados, fechanacimiento, poliza, fechavencimiento, recibo, cantidadsegurosant, cantidadsegurosnueva, flagdomiciliacion, 
						nombre1, apellidopaterno1, apellidomaterno1, parentesco1, porcentaje1, nombre2, apellidopaterno2, apellidomaterno2, parentesco2, 
						porcentaje2, nombre3, apellidopaterno3, apellidomaterno3, parentesco3, porcentaje3, sucursal, caja, area, empleadoefectuo, 
						ciudad, fechaconciliacion)
					VALUES('G', 'H', TRIM(NVL(cNumCteCoppel,'0')), NVL(iImporte,0), TRIM(NVL(cFecha,'')), '0', '', 
						NVL(iMesesPagados,0), TRIM(NVL(cFechaNac,'')), TRIM(NVL(cPoliza,'0')), NVL(cFechaVenc,''), 0, NVL(sCantSegurosAnt,0), NVL(sCantSegurosNva,'0'), '0', 
						'', '', '', '0', 0, '', '', '', '0', 0, '', '', '', '0', 0, 
						NVL(cSucursal,'0'), 100, 'B', NVL(cEmpleado,'0'), NVL(iCiudadTienda,0), NVL(cFechaArchivo,''));
				END IF;
			END FOREACH;

			-- CAMBIO DE BENEFICIARIO
			FOREACH
				SELECT a.numcte_coppel, a.fecha_modificacion, a.suc_cambio, a.ejecutivo_modificacion,
					a.primer_nombre, a.segundo_nombre, a.apell_paterno, a.apell_materno, a.porcentaje::INT, a.parentesco,
					b.primer_nombre, b.segundo_nombre, b.apell_paterno, b.apell_materno, b.porcentaje::INT, b.parentesco,
					d.primer_nombre, d.segundo_nombre, d.apell_paterno, d.apell_materno, d.porcentaje::INT, d.parentesco
				INTO cNumCteCoppel, dFecha, cSucursal, cEmpleado,
					cPrimerNombre1, cSegundoNombre1, cApellidoPat1, cApellidoMat1, iPorcentaje1, cParentesco1, 
					cPrimerNombre2, cSegundoNombre2, cApellidoPat2, cApellidoMat2, iPorcentaje2, cParentesco2, 
					cPrimerNombre3, cSegundoNombre3, cApellidoPat3, cApellidoMat3, iPorcentaje3, cParentesco3
				FROM "informix".si_club_beneficiario a
				LEFT JOIN "informix".si_club_beneficiario b ON (a.numcte = b.numcte AND b.secuencia = '2')
				LEFT JOIN "informix".si_club_beneficiario d ON (a.numcte = d.numcte AND d.secuencia = '3')
				WHERE a.fecha_modificacion = dFechaHoy AND a.tipo_mov = 'C' AND a.secuencia = '1'
				ORDER BY a.suc_cambio

				IF NVL(cNumCteCoppel,'') <> '' THEN
					SELECT num_poliza INTO cPoliza
					FROM "informix".si_club_proteccion 
					WHERE numcte_coppel = cNumCteCoppel AND aceptada = '1';

					IF dFecha IS NULL THEN
						LET dFecha = DATE(1);
					END IF;
					LET dFechaNac = DATE(1);
					LET dFechaVenc = DATE(1);
					LET cFecha = YEAR(dFecha) || LPAD(MONTH(dFecha),2,'0') || LPAD(DAY(dFecha),2,'0');
					LET cFechaNac = YEAR(dFechaNac) || LPAD(MONTH(dFechaNac),2,'0') || LPAD(DAY(dFechaNac),2,'0');
					LET cFechaVenc = YEAR(dFechaVenc) || LPAD(MONTH(dFechaVenc),2,'0') || LPAD(DAY(dFechaVenc),2,'0');
					LET cNombre1 = SUBSTR((TRIM(NVL(cPrimerNombre1,'')) || ' ' || TRIM(NVL(cSegundoNombre1,''))),1,15);
					LET cApellidoPat1 = SUBSTR(TRIM(NVL(cApellidoPat1,'')),1,15);
					LET cApellidoMat1 = SUBSTR(TRIM(NVL(cApellidoMat1,'')),1,15);
					LET cNombre2 = SUBSTR((TRIM(NVL(cPrimerNombre2,'')) || ' ' || TRIM(NVL(cSegundoNombre2,''))),1,15);
					LET cApellidoPat2 = SUBSTR(TRIM(NVL(cApellidoPat2,'')),1,15);
					LET cApellidoMat2 = SUBSTR(TRIM(NVL(cApellidoMat2,'')),1,15);
					LET cNombre3 = SUBSTR((TRIM(NVL(cPrimerNombre3,'')) || ' ' || TRIM(NVL(cSegundoNombre3,''))),1,15);
					LET cApellidoPat3 = SUBSTR(TRIM(NVL(cApellidoPat3,'')),1,15);
					LET cApellidoMat3 = SUBSTR(TRIM(NVL(cApellidoMat3,'')),1,15);

					/*SELECT ciudad, estado INTO cCiudadSucursal, cEstadoSucursal
					FROM "informix".si_sucursales WHERE sucursal = cSucursal;*/
					
				    SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad, cve_estado
                    INTO cCiudadSucursal, cEstadoSucursal
                    FROM bdinteg:"informix".si_ptf 
                    WHERE id_ptf = cSucursal AND tipo='S';	
					
					
					SELECT FIRST 1 ciudad_coppel INTO iCiudadTienda
					FROM "informix".si_ciudades
					WHERE ciudad = cCiudadSucursal AND estado = cEstadoSucursal and ciudad_coppel <> 0;

					IF NVL(iCiudadTienda,0) = 0 THEN
						SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad_coppel) = 'V' THEN ciudad_coppel::INTEGER ELSE 0 END
						INTO iCiudadTienda FROM bdinteg:"informix".si_ciudades WHERE ciudad = cCiudadSucursal and ciudad_coppel <> 0;
					END IF;

					IF NVL(iCiudadTienda,0) = 0 THEN
						SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad_coppel) = 'V' THEN ciudad_coppel::INTEGER ELSE 0 END
						INTO iCiudadTienda FROM bdinteg:"informix".si_ciudades WHERE ciudad_coppel <> 0;
					END IF;

					INSERT INTO "informix".si_club_detalle(clavemovimiento, tipomovimiento, numcliente, importe, fecha, cantidadseguros, claveseguro, 
						mesespagados, fechanacimiento, poliza, fechavencimiento, recibo, cantidadsegurosant, cantidadsegurosnueva, flagdomiciliacion, 
						nombre1, apellidopaterno1, apellidomaterno1, parentesco1, porcentaje1, nombre2, apellidopaterno2, apellidomaterno2, parentesco2, 
						porcentaje2, nombre3, apellidopaterno3, apellidomaterno3, parentesco3, porcentaje3, sucursal, caja, area, empleadoefectuo, 
						ciudad, fechaconciliacion)
					VALUES('G', 'D', TRIM(NVL(cNumCteCoppel,'0')), 0, TRIM(NVL(cFecha,'')), '0', 'C', 
						0, TRIM(NVL(cFechaNac,'')), TRIM(NVL(cPoliza,'0')), NVL(cFechaVenc,''), 0, 0, '0', '0', 
						TRIM(NVL(cNombre1,'')), TRIM(NVL(cApellidoPat1,'')), TRIM(NVL(cApellidoMat1,'')), NVL(cParentesco1,'0'), NVL(iPorcentaje1,0), 
						TRIM(NVL(cNombre2,'')), TRIM(NVL(cApellidoPat2,'')), TRIM(NVL(cApellidoMat2,'')), NVL(cParentesco2,'0'), NVL(iPorcentaje2,0), 
						TRIM(NVL(cNombre3,'')), TRIM(NVL(cApellidoPat3,'')), TRIM(NVL(cApellidoMat3,'')), NVL(cParentesco3,'0'), NVL(iPorcentaje3,0), 
						NVL(cSucursal,'0'), 100, 'B', NVL(cEmpleado,'0'), NVL(iCiudadTienda,0), NVL(cFechaArchivo,''));
				END IF;
			END FOREACH;

			UPDATE statistics medium FOR TABLE "informix".si_club_detalle;

			LET cSql = '';
			LET cSql = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'detalleclub1' || TRIM(cFechaArchivo) || '.txt' || ' DELIMITER ' || '''|''' ||
				' SELECT clavemovimiento, tipomovimiento, numcliente, importe, fecha, cantidadseguros, claveseguro, mesespagados,' ||
				' fechanacimiento, poliza, fechavencimiento, recibo, cantidadsegurosant, cantidadsegurosnueva, flagdomiciliacion,' ||
				' nombre1, apellidopaterno1, apellidomaterno1, parentesco1, porcentaje1, nombre2, apellidopaterno2, apellidomaterno2,' ||
				' parentesco2, porcentaje2, nombre3, apellidopaterno3, apellidomaterno3, parentesco3, porcentaje3, sucursal, caja,' ||
				' area, empleadoefectuo, ciudad, fechaconciliacion' ||
				' FROM si_club_detalle ' || ';' ||
				' " > detalleclub.sql';
			SYSTEM cSql; 

			LET cSql = '';
			LET cSql = 'dbaccess bdinteg detalleclub.sql';
			SYSTEM cSql;

			LET cSql = '';
			LET cSql = "sed 's/|$//g' " || TRIM(cRuta) || 'detalleclub1' || TRIM(cFechaArchivo) || '.txt' || " > " || TRIM(cRuta) || 'detalleclub2' || TRIM(cFechaArchivo) || '.txt';
			SYSTEM cSql; 

			LET cSql = '';
			LET cSql = "sed 's/$'/`echo \\\r`/ " || TRIM(cRuta) || 'detalleclub2' || TRIM(cFechaArchivo) || '.txt' || " > " || TRIM(cRuta) || 'detalleclub' || TRIM(cFechaArchivo) || '.txt';
			SYSTEM cSql;

			LET cSql = '';
			LET cSql = 'rm detalleclub.sql';
			SYSTEM cSql; 

			LET cSql = '';
			LET cSql = 'rm ' || TRIM(cRuta) || 'detalleclub1' || TRIM(cFechaArchivo) || '.txt';
			SYSTEM cSql; 

			LET cSql = '';
			LET cSql = 'rm ' || TRIM(cRuta) || 'detalleclub2' || TRIM(cFechaArchivo) || '.txt';
			SYSTEM cSql; 

			FOREACH
				SELECT clavemovimiento, tipomovimiento, numcliente, importe, fecha, cantidadseguros, claveseguro, mesespagados, fechanacimiento, 
					poliza, fechavencimiento, recibo, cantidadsegurosant, cantidadsegurosnueva, flagdomiciliacion, nombre1, apellidopaterno1, 
					apellidomaterno1, parentesco1, porcentaje1, nombre2, apellidopaterno2, apellidomaterno2, parentesco2, porcentaje2, nombre3, 
					apellidopaterno3, apellidomaterno3, parentesco3, porcentaje3, sucursal, caja, area, empleadoefectuo, ciudad, fechaconciliacion
				INTO cClaveMov, cTipoMov, cNumCteCoppel, iImporte, cFecha, cCantSeguros, cClaveSeguro, iMesesPagados, cFechaNac, 
					cPoliza, cFechaVenc, cRecibo, sCantSegurosAnt, sCantSegurosNva, cFlagDom, cNombre1, cApellidoPat1, cApellidoMat1, 
					cParentesco1, iPorcentaje1, cNombre2, cApellidoPat2, cApellidoMat2, cParentesco2, iPorcentaje2, cNombre3, 
					cApellidoPat3, cApellidoMat3, cParentesco3, iPorcentaje3, cSucursal, sCaja, cArea, cEmpleado, iCiudadTienda, cFechaConcilia
				FROM "informix".si_club_detalle

				INSERT INTO "informix".si_club_detalle_hist(clavemovimiento, tipomovimiento, numcliente, importe, fecha, cantidadseguros, claveseguro, 
					mesespagados, fechanacimiento, poliza, fechavencimiento, recibo, cantidadsegurosant, cantidadsegurosnueva, flagdomiciliacion, 
					nombre1, apellidopaterno1, apellidomaterno1, parentesco1, porcentaje1, nombre2, apellidopaterno2, apellidomaterno2, parentesco2, 
					porcentaje2, nombre3, apellidopaterno3, apellidomaterno3, parentesco3, porcentaje3, sucursal, caja, area, empleadoefectuo, 
					ciudad, fechaconciliacion)
				VALUES(NVL(cClaveMov,''), NVL(cTipoMov,''), TRIM(NVL(cNumCteCoppel,'')), NVL(iImporte,0), TRIM(NVL(cFecha,'')), 
					NVL(cCantSeguros,'0'), NVL(cClaveSeguro,''), NVL(iMesesPagados,0), TRIM(NVL(cFechaNac,'')), TRIM(NVL(cPoliza,'0')), 
					NVL(cFechaVenc,''), TRIM(NVL(cRecibo,'')), NVL(sCantSegurosAnt,0), NVL(sCantSegurosNva,0), NVL(cFlagDom,'0'), 
					TRIM(NVL(cNombre1,'')), TRIM(NVL(cApellidoPat1,'')), TRIM(NVL(cApellidoMat1,'')), NVL(cParentesco1,'0'), NVL(iPorcentaje1,0), 
					TRIM(NVL(cNombre2,'')), TRIM(NVL(cApellidoPat2,'')), TRIM(NVL(cApellidoMat2,'')), NVL(cParentesco2,'0'), NVL(iPorcentaje2,0), 
					TRIM(NVL(cNombre3,'')), TRIM(NVL(cApellidoPat3,'')), TRIM(NVL(cApellidoMat3,'')), NVL(cParentesco3,'0'), NVL(iPorcentaje3,0), 
					NVL(cSucursal,'0'), NVL(sCaja,0), NVL(cArea,''), NVL(cEmpleado,'0'), NVL(iCiudadTienda,0), NVL(cFechaConcilia,''));
			END FOREACH;

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