CREATE PROCEDURE "informix".sp_obtienectasefectabiertas(pEmpresa CHAR(3))
--DATOS A REGRESAR--
RETURNING CHAR(5) AS CodigoRetorno;

--DEFINICION DE VARIABLES--
DEFINE cCodret							CHAR(5);
DEFINE cNombreArchivo					CHAR(50);
DEFINE cSql								CHAR(3000);
DEFINE cRuta							CHAR(50);
DEFINE cEncabezado						CHAR(2000);
DEFINE cMes								CHAR(2);
DEFINE cNomMes 							CHAR(20);
DEFINE cSucursal						CHAR(4);
DEFINE cClaveSuc						CHAR(5);
DEFINE cProducto						CHAR(4);
DEFINE cNombreProd						CHAR(40);
DEFINE cNumTarjeta						CHAR(20);
DEFINE cTipoTarjeta						CHAR(1);
DEFINE cTipoAsignacion					CHAR(1);
DEFINE cCobroComision					CHAR(1);
DEFINE cCuenta							CHAR(20);
DEFINE cIva								CHAR(100);
DEFINE cEstadoCom						CHAR(1);
DEFINE cEtiqueta 						CHAR(40);
DEFINE dFechaAsignacion					DATE;
DEFINE dFechaHoy						DATE;
DEFINE dFechaIni						DATE;
DEFINE dFechaFin						DATE;
DEFINE dFechaArchivo					DATE;
DEFINE dFecIniAcumulado					DATE;
DEFINE dtFechaIni						DATETIME YEAR TO SECOND;
DEFINE dtFechaFin						DATETIME YEAR TO SECOND;
DEFINE iBanRegs							INTEGER;
DEFINE iTarjSolicitadas					INTEGER;
DEFINE iCobrada 						INTEGER;
DEFINE iSqlErr, iIsamErr 				INTEGER;
DEFINE iDias							INTEGER;
DEFINE iDia								INTEGER;
DEFINE iMes								INTEGER;
DEFINE iAnio							INTEGER;
DEFINE iBiciesto						INTEGER;
DEFINE iTarjetasEntregadas 				INTEGER;
DEFINE iTarjSuceptibleCobro				INTEGER;
DEFINE iTarjetasCobradas 				INTEGER;
DEFINE iTarjCondonadasGte 				INTEGER;
DEFINE iTarjetasEntregadasMes			INTEGER;
DEFINE iTarjSuceptibleCobroMes			INTEGER;
DEFINE iTarjetasCobradasMes				INTEGER;
DEFINE iTarjCondonadasGteMes			INTEGER;
DEFINE iTarjetasEntregadasAcum			INTEGER;
DEFINE iTarjSuceptibleCobroAcum			INTEGER;
DEFINE iTarjetasCobradasAcum			INTEGER;
DEFINE iTarjCondonadasGteAcum			INTEGER;
DEFINE mMtoTotalSuceptibleCobroMes 		DECIMAL(14,2);
DEFINE mMtoTotalTarjCobradasMes			DECIMAL(14,2);
DEFINE dcCostoPromedioComisionMes 		DECIMAL(14,2);
DEFINE dcPorcTarjSuceptibleCobroMes 	DECIMAL(14,2);
DEFINE dcPorcTarjCondonadasGteMes 		DECIMAL(14,2);
DEFINE mMtoTotalSuceptibleCobroAcum 	DECIMAL(14,2);
DEFINE mMtoTotalTarjCobradasAcum		DECIMAL(14,2);
DEFINE dcCostoPromedioComisionAcum 		DECIMAL(14,2);
DEFINE dcPorcTarjSuceptibleCobroAcum	DECIMAL(14,2);
DEFINE dcPorcTarjCondonadasGteAcum 		DECIMAL(14,2);
DEFINE mMtoTotalSuceptibleCobro 		DECIMAL(14,2);
DEFINE mMtoTotalTarjCobradas 			DECIMAL(14,2);
DEFINE dcCostoPromedioComision 			DECIMAL(14,2);
DEFINE dcPorcTarjSuceptibleCobro 		DECIMAL(14,2);
DEFINE dcPorcTarjCondonadasGte 			DECIMAL(14,2);
DEFINE mMontoTot						MONEY(14,2);
DEFINE mMtoTot							MONEY(14,2);
DEFINE mMontoCom						MONEY(14,2);
DEFINE cTitulo							CHAR(40);
DEFINE cBanderaBonificacion				CHAR(1);
DEFINE cBin								CHAR(6);
DEFINE cSubBin							CHAR(2);
DEFINE cCliente							CHAR(20);
DEFINE cNumCteCond						CHAR(20);
DEFINE iTipo							INTEGER;
DEFINE iTarjSolicitadasMes				INTEGER;
DEFINE iTarjSolicitadasAcum				INTEGER;
DEFINE iTarjCondonadasCred				INTEGER;
DEFINE iTarjCondonadasCredMes			INTEGER;
DEFINE iTarjCondonadasCredAcum 			INTEGER;
DEFINE dcPorcTarjCobradas				DECIMAL(14,2);
DEFINE dcPorcTarjEntregadas				DECIMAL(14,2);
DEFINE dcPorcTarjCobradasMes			DECIMAL(14,2);
DEFINE dcPorcTarjCobradasAcum			DECIMAL(14,2);
DEFINE dcPorcTarjCondonadasCred 		DECIMAL(14,2);
DEFINE dcPorcTarjCondonadasCredMes		DECIMAL(14,2);
DEFINE dcPorcTarjCondonadasCredAcum 	DECIMAL(14,2);
DEFINE dcPorcTarjEntregadasMes			DECIMAL(14,2);
DEFINE dcPorcTarjEntregadasAcum			DECIMAL(14,2);
DEFINE dFechaInsert						DATE;
DEFINE bBandera							INTEGER;


--INICIALIZACION DE VARIABLES--
LET cCodret							= '00000';
LET iSqlErr 						= 0;
LET iIsamErr 						= 0;
LET iDias							= 0;
LET iDia							= 0;
LET iMes							= 0;
LET iAnio							= 0;
LET iBiciesto						= 0;
LET iTarjetasEntregadas 			= 0;
LET iTarjSuceptibleCobro 			= 0;
LET iTarjetasCobradas 				= 0;
LET iTarjCondonadasGte 				= 0;
LET mMtoTotalSuceptibleCobro 		= 0;
LET mMtoTotalTarjCobradas 			= 0;
LET dcCostoPromedioComision 		= 0;
LET dcPorcTarjSuceptibleCobro 		= 0;
LET dcPorcTarjCondonadasGte 		= 0;
LET iTarjetasEntregadasMes			= 0;
LET iTarjSuceptibleCobroMes			= 0;
LET iTarjetasCobradasMes			= 0;
LET iTarjCondonadasGteMes			= 0;
LET mMtoTotalSuceptibleCobroMes 	= 0;
LET mMtoTotalTarjCobradasMes 		= 0;
LET dcCostoPromedioComisionMes		= 0;
LET dcPorcTarjSuceptibleCobroMes 	= 0;
LET dcPorcTarjCondonadasGteMes 		= 0;
LET iTarjetasEntregadasAcum			= 0;
LET iTarjSuceptibleCobroAcum 		= 0;
LET iTarjetasCobradasAcum 			= 0;
LET iTarjCondonadasGteAcum			= 0;
LET mMtoTotalSuceptibleCobroAcum 	= 0;
LET mMtoTotalTarjCobradasAcum 		= 0;
LET dcCostoPromedioComisionAcum 	= 0;
LET dcPorcTarjSuceptibleCobroAcum 	= 0;
LET dcPorcTarjCondonadasGteAcum 	= 0;
LET cIva							= 0;
LET mMontoTot						= 0;
LET mMtoTot							= 0;
LET mMontoCom						= 0;
LET iCobrada 						= 0;
LET cEtiqueta 						= 0;
LET iBanRegs						= 0;
LET iTarjSolicitadas 				= 0;
LET cMes							= '';
LET cNombreArchivo					= '';
LET cSql							= '';
LET cRuta							= '';
LET cEncabezado						= '';
LET dFechaHoy						= '';
LET cNomMes 						= '';
LET dFechaIni						= '';
LET dFechaFin						= '';
LET dtFechaIni						= '';
LET dtFechaFin						= '';
LET dFechaArchivo					= '';
LET dFecIniAcumulado 				= '';
LET cSucursal						= '';
LET cClaveSuc						= '';
LET cProducto						= '';
LET cNombreProd						= '';
LET cNumTarjeta						= '';
LET dFechaAsignacion				= '';
LET cTipoTarjeta					= '';
LET cTipoAsignacion					= '';
LET cCobroComision					= '';
LET cCuenta							= '';
LET cEstadoCom 						= '';
LET cBanderaBonificacion			= '';
LET dFechaInsert					= '';
LET cCliente						= '';
LET cNumCteCond						= '';
LET cTitulo						 	= '';
LET cBin						 	= '';
LET cSubBin						 	= '';
LET iTipo						 	= 1;
LET iTarjCondonadasCred 		 	= 0;
LET iTarjCondonadasCredMes			= 0;
LET iTarjCondonadasCredAcum		 	= 0;
LET dcPorcTarjCobradas				= 0;
LET dcPorcTarjEntregadas			= 0;
LET dcPorcTarjCobradasMes			= 0;
LET dcPorcTarjCobradasAcum			= 0;
LET dcPorcTarjCondonadasCred 	 	= 0;
LET dcPorcTarjCondonadasCredMes		= 0;
LET dcPorcTarjCondonadasCredAcum 	= 0;
LET dcPorcTarjEntregadasMes			= 0;
LET dcPorcTarjEntregadasAcum		= 0;
LET iTarjSolicitadasMes				= 0;
LET iTarjSolicitadasAcum			= 0;
LET bBandera 						= 1;

--SET DEBUG FILE TO "/respaldosbd/Bruno/331/sp_obtienectasefectabiertas.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cCodret = iSqlErr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;

	SELECT fecha_hoy INTO dFechaHoy FROM "informix".sc_fechas WHERE empresa = pEmpresa;

	IF NVL(dFechaHoy,'') <> '' THEN
		LET iDia = DAY(dFechaHoy);
		LET iMes = MONTH(dFechaHoy);
		LET iAnio = YEAR(dFechaHoy);

		IF iMes = 1 THEN
			LET iMes = 12;
			LET iAnio = iAnio -1;
		ELSE
			LET iMes = iMes -1;
		END IF;

		LET cMes = LPAD(iMes,2,'0');
		LET iBiciesto= MOD(iAnio,4);

		IF iMes = 1 OR iMes = 3 OR iMes = 5 OR iMes = 7 OR iMes = 8 OR iMes = 10 OR iMes = 12 THEN
			LET iDias = 31;
		ELIF iMes = 2 THEN
			LET iDias = 28;
			IF iBiciesto = 0 THEN
				LET iDias = iDias + 1;
			END IF;
		ELIF iMes = 4 OR iMes = 6 OR iMes = 9 OR iMes = 11 THEN
			LET iDias = 30;
		END IF;

		IF iMes = 1  THEN LET cNomMes = 'ENERO';      END IF;
		IF iMes = 2  THEN LET cNomMes = 'FEBRERO';    END IF;
		IF iMes = 3  THEN LET cNomMes = 'MARZO';      END IF;
		IF iMes = 4  THEN LET cNomMes = 'ABRIL';      END IF;
		IF iMes = 5  THEN LET cNomMes = 'MAYO';       END IF;
		IF iMes = 6  THEN LET cNomMes = 'JUNIO';      END IF;
		IF iMes = 7  THEN LET cNomMes = 'JULIO';      END IF;
		IF iMes = 8  THEN LET cNomMes = 'AGOSTO';     END IF;
		IF iMes = 9  THEN LET cNomMes = 'SEPTIEMBRE'; END IF;
		IF iMes = 10 THEN LET cNomMes = 'OCTUBRE';    END IF;
		IF iMes = 11 THEN LET cNomMes = 'NOVIEMBRE';  END IF;
		IF iMes = 12 THEN LET cNomMes = 'DICIEMBRE';  END IF;

		LET cNombreArchivo = "cuentasefectivasabiertas" || LPAD(iDia,2,'0') || cMes || iAnio;

		SELECT valor INTO cRuta FROM bdinteg:"informix".si_param WHERE empresa = pEmpresa AND cod_param = 141;

		LET dFechaIni = cMes || '/01/' || TO_CHAR(iAnio);
		LET dFechaFin = cMes || '/' || TO_CHAR(iDias) || '/' || TO_CHAR(iAnio);
		LET dFechaArchivo = cMes || '/' || '02' || '/' || iAnio;
		LET dFecIniAcumulado = '01/01/' || TO_CHAR(iAnio);

		LET dtFechaIni = dFechaIni::DATETIME YEAR TO SECOND;
		LET dtFechaFin = (dFechaFin + 1 UNITS DAY)::DATETIME YEAR TO SECOND;

		IF NVL(cRuta,'') <> '' THEN

			WHILE (iTipo < 5) LOOP

				IF iTipo = 1 THEN
					LET cTitulo = "TARJETA DE DEBITO BANCOPPEL EFECTIVA";
					LET cBin = '416916';
					LET cSubBin = '06';
				ELIF iTipo = 2 THEN
					LET cTitulo = "TARJETA DE DEBITO STOCK CON IMAGEN";
					LET cBin = '416916';
					LET cSubBin = '06';
				ELIF iTipo = 3 THEN
					LET cTitulo = "TARJETA DE DEBITO PLATINO";
					LET cBin = '559471';
				ELIF iTipo = 4 THEN
					LET cTitulo = "TARJETA DE DEBITO PERSONALIZADA";
					LET cBin = '416916';
					LET cSubBin = '05';
				END IF;

				LET cSql = 'echo "' || TRIM(cTitulo) ||'" >> ' || TRIM(cRuta) || TRIM(cNombreArchivo) || '.txt';
				SYSTEM cSql;

				IF iTipo = 1 OR iTipo = 3 THEN
					LET cEncabezado = "PRODUCTO|ENTREGADAS|COBRADAS|%|$|CONDONADAS POR GERENTE|%|CONDONADAS POR CREDITOS|%";
				ELIF iTipo = 2 THEN
					LET cEncabezado = "PRODUCTO|ENTREGADAS|COBRADAS|$|%";
				ELIF iTipo = 4 THEN
					LET cEncabezado = "PRODUCTO|SOLICITADAS|COBRADAS|%|$|ENTREGADAS|%";
					
				END IF;

				LET cSql = 'echo "' || TRIM(cEncabezado) || '" >> ' || TRIM(cRuta) || TRIM(cNombreArchivo) || '.txt';
				SYSTEM cSql;

				SELECT valor INTO cIva FROM bdinteg:"informix".si_param WHERE empresa = pEmpresa AND cod_param = 47;

				FOREACH

					SELECT producto INTO cProducto
					FROM "informix".sc_producto
					WHERE empresa = pEmpresa AND producto IN('1300','1400','1500','1700','1900','2000','2500')
					ORDER BY producto

					IF iTipo = 1 THEN
						FOREACH
							--SELECT PARA OBTENER LAS TARJETAS DE EFECTIVA DE DEBITO
							SELECT {+INDEX(bdicheq:"informix".sc_tarjeta ix_tarjeta2)} tarj.numtarjeta, DATE(tarj.fechaasignacion), cheq.cuenta, cheq.tipo_tarjeta, cheq.tipo_asignacion, cheq.cobro_comision,
							cheq.numcte, DATE(cheq.fecha_insert), cheq.bandera_bonificacion
							INTO cNumTarjeta, dFechaAsignacion, cCuenta, cTipoTarjeta, cTipoAsignacion, cCobroComision, cCliente, dFechaInsert, cBanderaBonificacion
							FROM intercard:"informix".tarjeta tarj, "informix".sc_tarjeta cheq
							WHERE tarj.fechaasignacion >= dtFechaIni AND tarj.fechaasignacion < dtFechaFin
							AND SUBSTR(tarj.numtarjeta,1,6) IN(SELECT {+INDEX(intercard:"informix".tipotarjeta idx_tipotarjeta)} bin
							FROM intercard:"informix".tipotarjeta WHERE chip = 'V')
							AND cheq.empresa = pEmpresa AND cheq.num_tarjeta = tarj.numtarjeta AND cheq.prodtarjeta = cProducto AND SUBSTR(tarj.numtarjeta,1,6) = cBin
							AND (SUBSTR(tarj.numtarjeta,7,2) <> '05' OR SUBSTR(tarj.numtarjeta,7,2) <> cSubBin)

							IF NVL(cNumTarjeta,'') <> '' THEN
								LET iBanRegs = 1;

								IF (NVL(cTipoAsignacion,'') = 'N' OR NVL(cTipoAsignacion,'') = 'R') AND (NVL(cCobroComision,'') = 'S' OR NVL(cCobroComision,'') = 'N') THEN

									LET iTarjetasEntregadas = iTarjetasEntregadas + 1;

									IF NVL(cCobroComision,'') = 'S' THEN

										IF NVL(cTipoAsignacion,'') = 'N' THEN
											SELECT NVL(SUM(monto_tot),0) INTO mMtoTot
											FROM "informix".sc_movhis
											WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3260','0362','3259')
											AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
										ELIF NVL(cTipoAsignacion,'') = 'R' THEN
											SELECT NVL(SUM(monto_tot),0) INTO mMtoTot
											FROM "informix".sc_movhis
											WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3261','0363','3259')
											AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
										END IF;

										IF NVL(mMtoTot,0) = 0 THEN
											IF NVL(cTipoAsignacion,'') = 'N' THEN
												SELECT NVL(SUM(monto_tot),0) INTO mMtoTot
												FROM "informix".sc_movhis_old
												WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3260','0362', '3259')
												AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
											ELIF NVL(cTipoAsignacion,'') = 'R' THEN
												SELECT NVL(SUM(monto_tot),0) INTO mMtoTot
												FROM "informix".sc_movhis_old
												WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3261','0363','3259')
												AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
											END IF;
										END IF;

										IF NVL(mMtoTot,0) > 0 THEN

											LET iTarjetasCobradas = iTarjetasCobradas + 1;
											LET iCobrada = 1;
										END IF;

										IF iCobrada = 1 THEN

											LET mMtoTotalTarjCobradas = mMtoTotalTarjCobradas + NVL(mMtoTot,0);
										END IF;
										LET mMtoTot = 0;
										LET iCobrada = 0;
									ELIF NVL(cCobroComision,'') = 'N' THEN

										IF EXISTS (SELECT * FROM bdicheq:"informix".sc_condonacomdeb WHERE DATE(fecha) = dFechaInsert AND numcte = cCliente) THEN
											LET iTarjCondonadasGte = iTarjCondonadasGte + 1;
										ELIF cBanderaBonificacion IN ('1','2') THEN 
											LET iTarjCondonadasCred = iTarjCondonadasCred + 1;
										END IF;
									END IF;
								END IF;
							END IF;
						END FOREACH;
					ELIF iTipo = 2 THEN
						FOREACH
							--SELECT PARA OBTENER LAS TARJETAS DE DEBITO CON IMAGEN
							SELECT {+INDEX(bdicheq:"informix".sc_tarjeta ix_tarjeta2)} tarj.numtarjeta, DATE(tarj.fechaasignacion), cheq.cuenta, cheq.tipo_tarjeta, cheq.tipo_asignacion, cheq.cobro_comision
							INTO cNumTarjeta, dFechaAsignacion, cCuenta, cTipoTarjeta, cTipoAsignacion, cCobroComision
							FROM intercard:"informix".tarjeta tarj, "informix".sc_tarjeta cheq
							WHERE tarj.fechaasignacion >= dtFechaIni AND tarj.fechaasignacion < dtFechaFin
							AND SUBSTR(tarj.numtarjeta,1,6) IN(SELECT {+INDEX(intercard:"informix".tipotarjeta idx_tipotarjeta)} bin
							FROM intercard:"informix".tipotarjeta WHERE chip = 'V')
							AND cheq.empresa = pEmpresa AND cheq.prodtarjeta = cProducto AND tarj.numtarjeta = cheq.num_tarjeta AND SUBSTR(tarj.numtarjeta,1,6) = cBin AND SUBSTR(tarj.numtarjeta,7,2) = cSubBin

							IF NVL(cNumTarjeta,'') <> '' THEN
								LET iBanRegs = 1;

								IF (NVL(cTipoAsignacion,'') = 'N' OR NVL(cTipoAsignacion,'') = 'R') AND (NVL(cCobroComision,'') = 'S' OR NVL(cCobroComision,'') = 'N') THEN

									LET iTarjetasEntregadas = iTarjetasEntregadas + 1;

									IF NVL(cTipoAsignacion,'') = 'N' THEN
										SELECT NVL(SUM(monto_tot),0) INTO mMtoTot
										FROM "informix".sc_movhis
										WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3260','0362', '3259')
										AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
									ELIF NVL(cTipoAsignacion,'') = 'R' THEN
										SELECT NVL(SUM(monto_tot),0) INTO mMtoTot
										FROM "informix".sc_movhis
										WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3261','0363', '3259')
										AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
									END IF;

									IF NVL(mMtoTot,0) = 0 THEN
										IF NVL(cTipoAsignacion,'') = 'N' THEN
											SELECT NVL(SUM(monto_tot),0) INTO mMtoTot
											FROM "informix".sc_movhis_old
											WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3260','0362', '3259')
											AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
										ELIF NVL(cTipoAsignacion,'') = 'R' THEN
											SELECT NVL(SUM(monto_tot),0) INTO mMtoTot
											FROM "informix".sc_movhis_old
											WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3261','0363', '3259')
											AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
										END IF;
									END IF;

									IF NVL(mMtoTot,0) > 0 THEN

										LET iTarjetasCobradas = iTarjetasCobradas + 1;
										LET iCobrada = 1;
									END IF;

									IF iCobrada = 1 THEN
										LET mMtoTotalTarjCobradas = mMtoTotalTarjCobradas + NVL(mMtoTot,0);
									END IF;
									LET mMtoTot = 0;
									LET iCobrada = 0;
								END IF;
							END IF;
						END FOREACH;
					ELIF iTipo = 3 AND bBandera = 1 THEN
						FOREACH
							--SELECT PARA OBTENER LAS TARJETAS PLATINO
							SELECT {+INDEX(bdicheq:"informix".sc_tarjeta ix_tarjeta2)} tarj.numtarjeta, DATE(tarj.fechaasignacion), cheq.cuenta, cheq.tipo_tarjeta, cheq.tipo_asignacion, cheq.cobro_comision,
							cheq.numcte, DATE(cheq.fecha_insert), cheq.bandera_bonificacion
							INTO cNumTarjeta, dFechaAsignacion, cCuenta, cTipoTarjeta, cTipoAsignacion, cCobroComision, cCliente, dFechaInsert, cBanderaBonificacion
							FROM intercard:"informix".tarjeta tarj, "informix".sc_tarjeta cheq
							WHERE tarj.fechaasignacion >= dtFechaIni AND tarj.fechaasignacion < dtFechaFin
							AND SUBSTR(tarj.numtarjeta,1,6) IN(SELECT {+INDEX(intercard:"informix".tipotarjeta idx_tipotarjeta)} bin
							FROM intercard:"informix".tipotarjeta WHERE chip = 'V')
							AND cheq.empresa = pEmpresa AND cheq.prodtarjeta = '2400' AND tarj.numtarjeta = cheq.num_tarjeta AND SUBSTR(tarj.numtarjeta,1,6) = cBin
							
							LET cProducto = '2400';
							
							IF NVL(cNumTarjeta,'') <> '' THEN
								LET iBanRegs = 1;

								IF (NVL(cTipoAsignacion,'') = 'N' OR NVL(cTipoAsignacion,'') = 'R') AND (NVL(cCobroComision,'') = 'S' OR NVL(cCobroComision,'') = 'N') THEN

									LET iTarjetasEntregadas = iTarjetasEntregadas + 1;

									IF NVL(cCobroComision,'') = 'S' THEN

										IF NVL(cTipoAsignacion,'') = 'N' THEN
											SELECT NVL(SUM(monto_tot),0) INTO mMtoTot
											FROM "informix".sc_movhis
											WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3260','0362', '3259')
											AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
										ELIF NVL(cTipoAsignacion,'') = 'R' THEN
											SELECT NVL(SUM(monto_tot),0) INTO mMtoTot
											FROM "informix".sc_movhis
											WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3261','0363', '3259')
											AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
										END IF;

										IF NVL(mMtoTot,0) = 0 THEN
											IF NVL(cTipoAsignacion,'') = 'N' THEN
												SELECT NVL(SUM(monto_tot),0) INTO mMtoTot
												FROM "informix".sc_movhis_old
												WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3260','0362', '3259')
												AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
											ELIF NVL(cTipoAsignacion,'') = 'R' THEN
												SELECT NVL(SUM(monto_tot),0) INTO mMtoTot
												FROM "informix".sc_movhis_old
												WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3261','0363', '3259')
												AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
											END IF;
										END IF;

										IF NVL(mMtoTot,0) > 0 THEN

											LET iTarjetasCobradas = iTarjetasCobradas + 1;
											LET iCobrada = 1;
										END IF;

										IF iCobrada = 1 THEN
											LET mMtoTotalTarjCobradas = mMtoTotalTarjCobradas + NVL(mMtoTot,0);
										END IF;
										LET mMtoTot = 0;
										LET iCobrada = 0;
									ELIF NVL(cCobroComision,'') = 'N' THEN
										IF EXISTS (SELECT * FROM bdicheq:"informix".sc_condonacomdeb WHERE DATE(fecha) = dFechaInsert AND numcte = cCliente) THEN
											LET iTarjCondonadasGte = iTarjCondonadasGte + 1;
										ELIF cBanderaBonificacion IN ('1','2') THEN 
											LET iTarjCondonadasCred = iTarjCondonadasCred + 1;
										END IF;
									END IF;
								END IF;
							END IF;
							LET bBandera = 0;
						END FOREACH;
					ELIF iTipo = 4 THEN
						FOREACH
							--SELECT PARA OBTENER LAS TARJETAS DE DEBITO PERSONALIZADA
							SELECT {+INDEX(bdicheq:"informix".sc_tarjeta ix_tarjeta2)} tarj.numtarjeta, DATE(tarj.fechaasignacion), cheq.cuenta, cheq.numcte, cheq.tipo_tarjeta, cheq.tipo_asignacion, cheq.cobro_comision
							INTO cNumTarjeta, dFechaAsignacion, cCuenta, cCliente, cTipoTarjeta, cTipoAsignacion,cCobroComision
							FROM intercard:"informix".tarjeta tarj, "informix".sc_tarjeta cheq
							WHERE tarj.fechaasignacion >= dtFechaIni AND tarj.fechaasignacion < dtFechaFin
							AND SUBSTR(tarj.numtarjeta,1,6) IN(SELECT {+INDEX(intercard:"informix".tipotarjeta idx_tipotarjeta)} bin
							FROM intercard:"informix".tipotarjeta WHERE chip = 'V')
							AND cheq.empresa = pEmpresa AND cheq.prodtarjeta = cProducto AND tarj.numtarjeta = cheq.num_tarjeta AND SUBSTR(tarj.numtarjeta,1,6) = cBin AND SUBSTR(tarj.numtarjeta,7,2) = cSubBin

							IF NVL(cNumTarjeta,'') <> '' THEN
								LET iBanRegs = 1;

								IF (NVL(cTipoAsignacion,'') = 'N' OR NVL(cTipoAsignacion,'') = 'R') AND (NVL(cCobroComision,'') = 'S' OR NVL(cCobroComision,'') = 'N') THEN

									LET iTarjetasEntregadas = iTarjetasEntregadas + 1;
									
									IF EXISTS (SELECT idsolicitud FROM intercard:"informix".solicitudtarjeta WHERE numcuenta = cCuenta AND codprodcta = cProducto AND DATE(fechasolicitud) >= DATE(dtFechaIni) AND DATE(fechasolicitud) < DATE(dtFechaFin) AND numcliente = cCliente AND idsolicitud IS NOT NULL ) THEN
										LET iTarjSolicitadas= iTarjSolicitadas + 1 ;
									END IF;
									
									IF NVL(cTipoAsignacion,'') = 'N' THEN
										SELECT NVL(SUM(monto_tot),0) INTO mMtoTot
										FROM "informix".sc_movhis
										WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3260','0362', '3259')
										AND fech_alt = DATE(dFechaAsignacion) AND cancelad <> 'S';
									ELIF NVL(cTipoAsignacion,'') = 'R' THEN
										SELECT NVL(SUM(monto_tot),0) INTO mMtoTot
										FROM "informix".sc_movhis
										WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3261','0363', '3259')
										AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
									END IF;

									IF NVL(mMtoTot,0) = 0 THEN
										IF NVL(cTipoAsignacion,'') = 'N' THEN
											SELECT NVL(SUM(monto_tot),0) INTO mMtoTot
											FROM "informix".sc_movhis_old
											WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3260','0362', '3259')
											AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
										ELIF NVL(cTipoAsignacion,'') = 'R' THEN
											SELECT NVL(SUM(monto_tot),0) INTO mMtoTot
											FROM "informix".sc_movhis_old
											WHERE empresa = pEmpresa AND cuenta = cCuenta AND transacc IN('3261','0363', '3259')
											AND fech_alt = dFechaAsignacion AND cancelad <> 'S';
										END IF;
									END IF;

									IF NVL(mMtoTot,0) > 0 THEN

										LET iTarjetasCobradas = iTarjetasCobradas + 1;
										LET iCobrada = 1;
									END IF;

									IF iCobrada = 1 THEN
										LET mMtoTotalTarjCobradas = mMtoTotalTarjCobradas + NVL(mMtoTot,0);
									END IF;
									LET mMtoTot = 0;
									LET iCobrada = 0;
								END IF;
							END IF;
						END FOREACH;
					END IF;

					IF NVL(iTarjetasEntregadas,0) > 0 THEN

						LET dcPorcTarjCondonadasGte = (NVL(iTarjCondonadasGte,0) * 100) / iTarjetasEntregadas;
						LET dcPorcTarjCondonadasCred = (NVL(iTarjCondonadasCred,0) * 100) / iTarjetasEntregadas;
						LET dcPorcTarjCobradas = (NVL(iTarjetasCobradas,0) * 100) / iTarjetasEntregadas;

					END IF;

					IF iBanRegs = 1 OR iTarjetasEntregadas <> 0 THEN

						INSERT INTO "informix".sc_acumuladostddentregadas(sucursal,producto,tarjetasentregadas,tarjsuceptiblecobro,mtototalsuceptiblecobro,tarjetascobradas,
							mtototaltarjcobradas,costopromediocomision,porctarjsuceptiblecobro,tarjcondonadasgte,porctarjcondonadasgte,tarjcondonadascred,fechainsert,
							tipotarjeta, tarjetassolicitadas)
						VALUES(TRIM(cSucursal),TRIM(cProducto),iTarjetasEntregadas, iTarjSuceptibleCobro,mMtoTotalSuceptibleCobro,iTarjetasCobradas,mMtoTotalTarjCobradas,
							dcCostoPromedioComision,dcPorcTarjSuceptibleCobro, iTarjCondonadasGte,dcPorcTarjCondonadasGte,iTarjCondonadasCred, dFechaArchivo,iTipo,
							iTarjSolicitadas);

						LET iBanRegs = 0;
					END IF;

					LET iTarjetasEntregadas 	  = 0;
					LET iTarjetasCobradas 		  = 0;
					LET dcPorcTarjCobradas        = 0;
					LET mMtoTotalTarjCobradas 	  = 0;
					LET iTarjCondonadasGte 		  = 0;
					LET dcPorcTarjCondonadasGte   = 0;
					LET iTarjCondonadasCred       = 0;
					LET dcPorcTarjCondonadasCred  = 0;
					LET iTarjSuceptibleCobro 	  = 0;
					LET mMtoTotalSuceptibleCobro  = 0;
					LET dcCostoPromedioComision   = 0;
					LET dcPorcTarjSuceptibleCobro = 0;
					LET iTarjSolicitadas	  	  = 0;
				END FOREACH;

				IF iTipo = 1 THEN
					FOREACH
						--RENGLON DEL DETALLE POR PRODUCTO
						SELECT TRIM(producto), TRIM(nombre) INTO cProducto, cNombreProd
						FROM "informix".sc_producto
						WHERE empresa = pEmpresa AND producto IN('1300','1400','1500','1700','1900','2000','2500')
						ORDER BY producto

						SELECT NVL(SUM(tarjetasentregadas),0),NVL(SUM(tarjetascobradas),0),NVL(SUM(mtototaltarjcobradas),0),
							NVL(SUM(tarjcondonadasgte),0),NVL(SUM(tarjcondonadascred),0)
						INTO iTarjetasEntregadas,iTarjetasCobradas,mMtoTotalTarjCobradas,
							iTarjCondonadasGte,iTarjCondonadasCred
						FROM "informix".sc_acumuladostddentregadas
						WHERE producto = cProducto AND fechainsert = dFechaArchivo AND tipotarjeta = iTipo;

						IF NVL(iTarjetasEntregadas,0) > 0 THEN

							LET dcPorcTarjCondonadasGte = (NVL(iTarjCondonadasGte,0) * 100) / iTarjetasEntregadas;
							LET dcPorcTarjCondonadasCred = (NVL(iTarjCondonadasCred,0) * 100) / iTarjetasEntregadas;
							LET dcPorcTarjCobradas = (NVL(iTarjetasCobradas,0) * 100) / iTarjetasEntregadas;
						END IF;

						LET cSql = 'echo "' || TRIM(cNombreProd) || '(' || TRIM(cProducto) || ')' || '|' || NVL(iTarjetasEntregadas,0) || '|' || NVL(iTarjetasCobradas,0) || '|' ||
						NVL(dcPorcTarjCobradas,0) || '|' || NVL(mMtoTotalTarjCobradas,0) || '|' || NVL(iTarjCondonadasGte,0) || '|' || NVL(dcPorcTarjCondonadasGte,0) || '|' ||
						NVL (iTarjCondonadasCred,0) || '|' || NVL(dcPorcTarjCondonadasCred,0) ||'" >> ' || TRIM(cRuta) || TRIM(cNombreArchivo) || '.txt';
						SYSTEM cSql;

						-- RENGLON DEL DETALLE POR MES
						LET iTarjetasEntregadasMes = iTarjetasEntregadasMes + iTarjetasEntregadas;
						LET iTarjetasCobradasMes = iTarjetasCobradasMes + iTarjetasCobradas;
						LET mMtoTotalTarjCobradasMes = mMtoTotalTarjCobradasMes + mMtoTotalTarjCobradas;
						LET iTarjCondonadasCredMes = iTarjCondonadasCredMes + iTarjCondonadasCred;
						LET iTarjCondonadasGteMes = iTarjCondonadasGteMes + iTarjCondonadasGte;

						LET iTarjetasEntregadas 	  = 0;
						LET iTarjetasCobradas 		  = 0;
						LET dcPorcTarjCobradas        = 0;
						LET mMtoTotalTarjCobradas 	  = 0;
						LET iTarjCondonadasGte 		  = 0;
						LET dcPorcTarjCondonadasGte   = 0;
						LET iTarjCondonadasCred       = 0;
						LET dcPorcTarjCondonadasCred  = 0;

					END FOREACH;
				ELIF iTipo = 2 THEN
					FOREACH
						--RENGLON DEL DETALLE POR PRODUCTO
						SELECT TRIM(producto), TRIM(nombre) INTO cProducto, cNombreProd
						FROM "informix".sc_producto
						WHERE empresa = pEmpresa AND producto IN('1300','1400','1500','1700','1900','2000','2500')
						ORDER BY producto

						SELECT NVL(SUM(tarjetasentregadas),0),NVL(SUM(tarjetascobradas),0),NVL(SUM(mtototaltarjcobradas),0)
						INTO iTarjetasEntregadas,iTarjetasCobradas,mMtoTotalTarjCobradas
						FROM "informix".sc_acumuladostddentregadas
						WHERE producto = cProducto AND fechainsert = dFechaArchivo AND tipotarjeta = iTipo;
						
						IF NVL(iTarjetasEntregadas,0) > 0 THEN
							LET dcPorcTarjCobradas = (NVL(iTarjetasCobradas,0) * 100) / iTarjetasEntregadas;							
						END IF;
						
						LET cSql = 'echo "' || TRIM(cNombreProd) || '(' || TRIM(cProducto) || ')' || '|' || NVL(iTarjetasEntregadas,0) || '|' || NVL(iTarjetasCobradas,0) || '|' || 
						NVL(mMtoTotalTarjCobradas,0) || '|' || NVL(dcPorcTarjCobradas,0) ||'" >> ' || TRIM(cRuta) || TRIM(cNombreArchivo) || '.txt';
						SYSTEM cSql;

						-- RENGLON DEL DETALLE POR MES

						LET iTarjetasEntregadasMes = iTarjetasEntregadasMes + iTarjetasEntregadas;
						LET iTarjetasCobradasMes = iTarjetasCobradasMes + iTarjetasCobradas;
						LET mMtoTotalTarjCobradasMes = mMtoTotalTarjCobradasMes + mMtoTotalTarjCobradas;
						
						LET iTarjetasEntregadas 	  = 0;
						LET iTarjetasCobradas 		  = 0;
						LET mMtoTotalTarjCobradas 	  = 0;
						LET dcPorcTarjCobradas        = 0;

					END FOREACH;
				ELIF iTipo = 3 THEN
					FOREACH
						SELECT TRIM(producto), TRIM(nombre) INTO cProducto, cNombreProd
						FROM "informix".sc_producto
						WHERE empresa = pEmpresa AND producto = '2400'

						SELECT NVL(SUM(tarjetasentregadas),0),NVL(SUM(tarjetascobradas),0),NVL(SUM(mtototaltarjcobradas),0),NVL(SUM(tarjcondonadasgte),0),NVL(SUM(tarjcondonadascred),0)
						INTO iTarjetasEntregadas,iTarjetasCobradas,mMtoTotalTarjCobradas,iTarjCondonadasGte,iTarjCondonadasCred
						FROM "informix".sc_acumuladostddentregadas
						WHERE producto = cProducto AND fechainsert = dFechaArchivo AND tipotarjeta = iTipo;

						IF NVL(iTarjetasEntregadas, 0) > 0 THEN

							LET dcPorcTarjCondonadasGte = (NVL(iTarjCondonadasGte,0) * 100) / iTarjetasEntregadas;
							LET dcPorcTarjCondonadasCred = (NVL(iTarjCondonadasCred,0) * 100) / iTarjetasEntregadas;
							LET dcPorcTarjCobradas = (NVL(iTarjetasCobradas,0) * 100) / iTarjetasEntregadas;
						END IF;

						LET cSql = 'echo "' || TRIM(cNombreProd) || '(' || TRIM(cProducto) || ')' || '|' || NVL(iTarjetasEntregadas,0) || '|' || NVL(iTarjetasCobradas,0) || '|' ||
						NVL(dcPorcTarjCobradas,0) || '|' || NVL(mMtoTotalTarjCobradas,0) || '|' || NVL(iTarjCondonadasGte,0) || '|' || NVL(dcPorcTarjCondonadasGte,0) || '|' ||
						NVL (iTarjCondonadasCred,0) || '|' || NVL(dcPorcTarjCondonadasCred,0) ||'" >> ' || TRIM(cRuta) || TRIM(cNombreArchivo) || '.txt';
						SYSTEM cSql;

						-- RENGLON DEL DETALLE POR MES
						LET iTarjetasEntregadasMes = iTarjetasEntregadasMes + iTarjetasEntregadas;
						LET iTarjetasCobradasMes = iTarjetasCobradasMes + iTarjetasCobradas;
						LET mMtoTotalTarjCobradasMes = mMtoTotalTarjCobradasMes + mMtoTotalTarjCobradas;
						LET iTarjCondonadasCredMes = iTarjCondonadasCredMes + iTarjCondonadasCred;
						LET iTarjCondonadasGteMes = iTarjCondonadasGteMes + iTarjCondonadasGte;

						LET iTarjetasEntregadas 	  = 0;
						LET iTarjetasCobradas 		  = 0;
						LET dcPorcTarjCobradas        = 0;
						LET mMtoTotalTarjCobradas 	  = 0;
						LET iTarjCondonadasGte 		  = 0;
						LET dcPorcTarjCondonadasGte   = 0;
						LET iTarjCondonadasCred       = 0;
						LET dcPorcTarjCondonadasCred  = 0;
					END FOREACH;
				ELIF iTipo = 4 THEN
					FOREACH
						--RENGLON DEL DETALLE POR PRODUCTO
						SELECT TRIM(producto), TRIM(nombre) INTO cProducto, cNombreProd
						FROM "informix".sc_producto
						WHERE empresa = pEmpresa AND producto IN('1300','1400','1500','1700','1900','2000','2500')
						ORDER BY producto

						SELECT NVL(SUM(tarjetasentregadas),0),NVL(SUM(tarjetascobradas),0),NVL(SUM(mtototaltarjcobradas),0),NVL(SUM(tarjetassolicitadas),0)
						INTO iTarjetasEntregadas,iTarjetasCobradas,mMtoTotalTarjCobradas, iTarjSolicitadas
						FROM "informix".sc_acumuladostddentregadas
						WHERE producto = cProducto AND fechainsert = dFechaArchivo AND tipotarjeta = iTipo;

						IF NVL(iTarjSolicitadas,0) > 0 THEN

							LET dcPorcTarjCobradas = (NVL(iTarjetasCobradas,0) * 100) / iTarjSolicitadas;
							LET dcPorcTarjEntregadas = (NVL(iTarjetasEntregadas,0) * 100) / iTarjSolicitadas;
						END IF;

						LET cSql = 'echo "' || TRIM(cNombreProd) || '(' || TRIM(cProducto) || ')' || '|' || NVL(iTarjSolicitadas,0) || '|' || NVL(iTarjetasCobradas,0) || '|' ||
						NVL(dcPorcTarjCobradas,0) || '|' || NVL(mMtoTotalTarjCobradas,0) || '|' || NVL(iTarjetasEntregadas,0) || '|' || NVL(dcPorcTarjEntregadas,0) ||'" >> ' ||
						TRIM(cRuta) || TRIM(cNombreArchivo) || '.txt';
						SYSTEM cSql;

						-- RENGLON DEL DETALLE POR MES
						LET iTarjSolicitadasMes = iTarjSolicitadasMes + iTarjSolicitadas;
						LET iTarjetasCobradasMes = iTarjetasCobradasMes + iTarjetasCobradas;
						LET mMtoTotalTarjCobradasMes = mMtoTotalTarjCobradasMes + mMtoTotalTarjCobradas;
						LET iTarjetasEntregadasMes = iTarjetasEntregadasMes + iTarjetasEntregadas;

						LET iTarjSolicitadas		  = 0;
						LET iTarjetasCobradas 		  = 0;
						LET mMtoTotalTarjCobradas 	  = 0;
						LET iTarjetasEntregadas 	  = 0;
						LET dcPorcTarjCobradas        = 0;
						LET dcPorcTarjEntregadas	  = 0;
					END FOREACH;
				END IF;

				IF NVL(iTarjetasEntregadasMes,0) > 0 THEN

					LET dcPorcTarjCobradasMes = (NVL(iTarjetasCobradasMes,0) * 100) / iTarjetasEntregadasMes;
					LET dcPorcTarjCondonadasGteMes = (NVL(iTarjCondonadasGteMes,0) * 100) / iTarjetasEntregadasMes;
					LET dcPorcTarjCondonadasCredMes = (NVL(iTarjCondonadasCredMes,0) * 100) / iTarjetasEntregadasMes;
				END IF;

				IF iTipo = 1 OR iTipo = 3 THEN

					LET cSql = '';
					LET cEtiqueta = 'TOTAL MES ' || cNomMes;
					LET cSql = 'echo "' || TRIM(cEtiqueta) || '|' || NVL(iTarjetasEntregadasMes,0) || '|' || NVL(iTarjetasCobradasMes,0) || '|' || NVL(dcPorcTarjCobradasMes,0) || '|' ||
					NVL(mMtoTotalTarjCobradasMes,0) || '|' || NVL(iTarjCondonadasGteMes,0) || '|' || NVL(dcPorcTarjCondonadasGteMes,0) || '|' || NVL (iTarjCondonadasCredMes,0) || '|' ||
					NVL(dcPorcTarjCondonadasCredMes,0) ||'" >> ' || TRIM(cRuta) || TRIM(cNombreArchivo) || '.txt';
					SYSTEM cSql;

					LET iTarjetasEntregadasMes 		= 0;
					LET iTarjetasCobradasMes		= 0;
					LET dcPorcTarjCobradasMes		= 0;
					LET mMtoTotalTarjCobradasMes	= 0;
					LET iTarjCondonadasGteMes		= 0;
					LET dcPorcTarjCondonadasGteMes	= 0;
					LET iTarjCondonadasCredMes		= 0;
					LET dcPorcTarjCondonadasCredMes	= 0;

				ELIF iTipo = 2 THEN

					IF NVL(iTarjetasEntregadasMes,0) > 0 THEN
							LET dcPorcTarjCobradasMes = (NVL(iTarjetasCobradasMes,0) * 100) / iTarjetasEntregadasMes;							
						END IF;

					LET cSql = '';
					LET cEtiqueta = 'TOTAL MES ' || cNomMes;
					LET cSql = 'echo "' || TRIM(cEtiqueta) || '|' || NVL(iTarjetasEntregadasMes,0) || '|' || NVL(iTarjetasCobradasMes,0) || '|' || 
					NVL(mMtoTotalTarjCobradasMes,0) || '|' || NVL(dcPorcTarjCobradasMes,0) ||'" >> ' || TRIM(cRuta) || TRIM(cNombreArchivo) || '.txt';
					SYSTEM cSql;
					
					LET iTarjetasEntregadasMes 		= 0;
					LET iTarjetasCobradasMes 		= 0;
					LET mMtoTotalTarjCobradasMes 	= 0;
					LET dcPorcTarjCobradasMes 		= 0;
										
				ELIF iTipo = 4 THEN

					IF NVL(iTarjSolicitadasMes,0) > 0 THEN

						LET dcPorcTarjEntregadasMes = (NVL(iTarjetasEntregadasMes,0) * 100) / iTarjSolicitadasMes;
					END IF;

					LET cSql = '';
					LET cEtiqueta = 'TOTAL MES ' || cNomMes;
					LET cSql = 'echo "' || TRIM(cEtiqueta) || '|' || NVL(iTarjSolicitadasMes,0) || '|' || NVL(iTarjetasCobradasMes,0) || '|' || NVL(dcPorcTarjCobradasMes,0) || '|' ||
					NVL(mMtoTotalTarjCobradasMes,0) || '|' || NVL(iTarjetasEntregadasMes,0) || '|' || NVL(dcPorcTarjEntregadasMes,0) ||'" >> ' || TRIM(cRuta) || TRIM(cNombreArchivo) || '.txt';
					SYSTEM cSql;

					LET iTarjSolicitadasMes 		= 0;
					LET iTarjetasCobradasMes 		= 0;
					LET dcPorcTarjCobradasMes 		= 0;
					LET mMtoTotalTarjCobradasMes 	= 0;
					LET iTarjetasEntregadasMes 		= 0;
					LET dcPorcTarjEntregadasMes 	= 0;

				END IF;

				SELECT NVL(SUM(tarjetasentregadas),0),NVL(SUM(tarjetascobradas),0),NVL(SUM(mtototaltarjcobradas),0),NVL(SUM(tarjcondonadasgte),0),NVL(SUM(tarjcondonadascred),0), NVL(SUM(tarjetassolicitadas),0)
				INTO iTarjetasEntregadasAcum,iTarjetasCobradasAcum,mMtoTotalTarjCobradasAcum,iTarjCondonadasGteAcum,iTarjCondonadasCredAcum, iTarjSolicitadasAcum
				FROM "informix".sc_acumuladostddentregadas
				WHERE fechainsert >= dFecIniAcumulado AND fechainsert <= dFechaArchivo AND tipotarjeta = iTipo;

				IF iTipo = 1 OR iTipo = 3 THEN

					IF NVL(iTarjetasEntregadasAcum,0) > 0 THEN

						LET dcPorcTarjCondonadasGteAcum = (NVL(iTarjCondonadasGteAcum,0) * 100) / iTarjetasEntregadasAcum;
						LET dcPorcTarjCobradasAcum = (NVL(iTarjetasCobradasAcum,0) * 100) / iTarjetasEntregadasAcum;
						LET dcPorcTarjCondonadasCredAcum = (NVL(iTarjCondonadasCredAcum,0) * 100) / iTarjetasEntregadasAcum;
					END IF;

					LET cSql = '';
					LET cEtiqueta = 'ACUMULADO ' || TO_CHAR(iAnio);
					LET cSql = 'echo "' || TRIM(cEtiqueta) || '|' || NVL(iTarjetasEntregadasAcum,0) || '|' || NVL(iTarjetasCobradasAcum,0) || '|' ||
					NVL(dcPorcTarjCobradasAcum,0) || '|' || NVL(mMtoTotalTarjCobradasAcum,0) || '|' || NVL(iTarjCondonadasGteAcum,0) || '|' ||
					NVL(dcPorcTarjCondonadasGteAcum,0) || '|' || NVL (iTarjCondonadasCredAcum,0) || '|' || NVL(dcPorcTarjCondonadasCredAcum,0) ||'" >> ' ||
					TRIM(cRuta) || TRIM(cNombreArchivo) || '.txt';
					SYSTEM cSql;
					
				ELIF iTipo = 2 THEN

					IF NVL(iTarjetasEntregadasAcum,0) > 0 THEN
							LET dcPorcTarjCobradasAcum = (NVL(iTarjetasCobradasAcum,0) * 100) / iTarjetasEntregadasAcum;							
						END IF;

					LET cSql = '';
					LET cEtiqueta = 'ACUMULADO ' || TO_CHAR(iAnio);
					LET cSql = 'echo "' || TRIM(cEtiqueta) || '|' || NVL(iTarjetasEntregadasAcum,0) || '|' || NVL(iTarjetasCobradasAcum,0) || '|' || 
					NVL(mMtoTotalTarjCobradasAcum,0) || '|' || NVL(dcPorcTarjCobradasAcum,0) ||'" >> ' || TRIM(cRuta) || TRIM(cNombreArchivo) || '.txt';
					SYSTEM cSql;
					
					LET iTarjetasEntregadasAcum		= 0;
					LET iTarjetasCobradasAcum 		= 0;
					LET mMtoTotalTarjCobradasAcum 	= 0;
					LET dcPorcTarjCobradasAcum		= 0;
					
				ELIF iTipo = 4 THEN

					IF NVL(iTarjSolicitadasAcum,0) > 0 THEN

						LET dcPorcTarjEntregadasAcum = (NVL(iTarjetasEntregadasAcum,0) * 100) / iTarjSolicitadasAcum;
						LET dcPorcTarjCobradasAcum = (NVL(iTarjetasCobradasAcum,0) * 100) / iTarjSolicitadasAcum;
					END IF;

					LET cSql = '';
					LET cEtiqueta = 'ACUMULADO ' || TO_CHAR(iAnio);
					LET cSql = 'echo "' || TRIM(cEtiqueta) || '|' || NVL(iTarjSolicitadasAcum,0) || '|' || NVL(iTarjetasCobradasAcum,0) || '|' || NVL(dcPorcTarjCobradasAcum,0) || '|' ||
					NVL(mMtoTotalTarjCobradasAcum,0) || '|' || NVL(iTarjetasEntregadasAcum,0) || '|' || NVL(dcPorcTarjEntregadasAcum,0) ||'" >> ' || TRIM(cRuta) || TRIM(cNombreArchivo) || '.txt';
					SYSTEM cSql;
				END IF;

				LET iTarjSolicitadasAcum			= 0;
				LET iTarjetasEntregadasAcum 		= 0;
				LET iTarjetasCobradasAcum			= 0;
				LET dcPorcTarjCobradasAcum			= 0;
				LET mMtoTotalTarjCobradasAcum		= 0;
				LET iTarjCondonadasGteAcum			= 0;
				LET dcPorcTarjCondonadasGteAcum		= 0;
				LET iTarjCondonadasCredAcum			= 0;
				LET dcPorcTarjCondonadasCredAcum	= 0;
				LET dcPorcTarjEntregadasAcum		= 0;

				LET iTipo = iTipo + 1;
			END LOOP;
		ELSE
			LET cCodret = "00002"; --Ruta sin Definir
		END IF;
	ELSE
		LET cCodret = "00001"; --Fecha Vacia
	END IF;

	RETURN cCodret;
END;
END PROCEDURE
DOCUMENT
'MODIFICA: MARCO CARDENAS',
'NUMERO DE EMPLEADO: 97959456',
'SOLICITA: CHRIST ARMENTA',
'DESCRIPCION: Se modifican los campos de la trama que genera el archivo y se divide la informacion de los tipos de tarjetas agregando las condonaciones de tarjetas de debito',
'FOLIO: 331-RQM 10 909 Modificar el layout del reporte que nos proporcionan mensualmente.',
'FECHA: 14/11/2017',
'BD:BDICHEQ';

CREATE PROCEDURE "informix".sp_edoctaencabezado( pempresa CHAR(3),
                                                 pcuenta  CHAR(20),
                                                 paniomes CHAR(6),
                                                 ptipo    CHAR(1) )
                                                 
RETURNING CHAR(5), CHAR(45), CHAR(10), CHAR(16), CHAR(18), DATE, DATE, MONEY(14,2), MONEY(14,2), MONEY(14,2), MONEY(14,2), MONEY(14,2),
          MONEY(14,2), MONEY(14,2), MONEY(14,2), MONEY(14,2), MONEY(14,2), SMALLINT, DECIMAL(9,6), CHAR(20), CHAR(107), CHAR(10),CHAR(10), CHAR(30), 
          CHAR(30), CHAR(30), CHAR(30), CHAR(5), CHAR(13), CHAR(20), DATE, CHAR(40), MONEY(14,2), MONEY(16,2), DECIMAL(9,6), MONEY(16,2), SMALLINT;
    
    DEFINE vcodret              CHAR(5);
    DEFINE vcodret2             CHAR(5);
    DEFINE vcodret3             CHAR(50);
    DEFINE cCodPostal           CHAR(5);
    DEFINE cNumExt              CHAR(10);
    DEFINE cNumInt              CHAR(10);
    DEFINE cNumProducto         CHAR(10);
    DEFINE cRFC                 CHAR(13);
    DEFINE cNumTarjeta          CHAR(16);
    DEFINE cClabe               CHAR(18);
    DEFINE cNumcte              CHAR(20);
    DEFINE cCurp                CHAR(20);
    DEFINE cNomCalle            CHAR(30);
    DEFINE cNomColonia          CHAR(30);
    DEFINE cNomCiudad           CHAR(30);
    DEFINE cNomEstado           CHAR(30);
    DEFINE cNomSucursal         CHAR(40);
    DEFINE cProducto            CHAR(45);
    DEFINE cNomcte              CHAR(107);
    DEFINE dFechaini            DATE;
    DEFINE dFechafin            DATE;
    DEFINE dFechaAlta           DATE;
    DEFINE mSaldoAnterior       MONEY(14,2);
    DEFINE mDepositos           MONEY(14,2);
    DEFINE mRetiros             MONEY(14,2);
    DEFINE mInteresesPagados    MONEY(14,2);
    DEFINE mOtrosCargos         MONEY(14,2);
    DEFINE mIvaOtrosCargos      MONEY(14,2);
    DEFINE mSaldoCorte          MONEY(14,2);
    DEFINE mAux1                MONEY(14,2);
    DEFINE mSaldoPromedio       MONEY(14,2);
    DEFINE mRetencionIsr        MONEY(14,2);
    DEFINE mInteresesNetos      MONEY(14,2);
    DEFINE dTasaBruta           DECIMAL(9,6);
    DEFINE iDias                SMALLINT;
    DEFINE vsec_dir             SMALLINT;
    DEFINE vsqlerr              INTEGER;
    DEFINE visamerr             INTEGER;
    DEFINE vdescerr             CHAR(50);
    DEFINE v_mes                CHAR(2);
    DEFINE v_mes2               CHAR(2);
    DEFINE mSaldoRet            MONEY(14,2);
    DEFINE cTipoPersona         CHAR(2);
    DEFINE cFech_param_old      CHAR(10);
    DEFINE mTotOtrosCargos      MONEY(16,2);
    DEFINE mGat                 DECIMAL(9,6);
    DEFINE mTotRetiros          MONEY(16,2);
    DEFINE iFlagGrafica         SMALLINT;
    DEFINE cAnyomes             CHAR(6);
	DEFINE cRFC_alterno         CHAR(13);
	DEFINE cSufijos             CHAR(60);
    DEFINE iExisteCuenta        SMALLINT;
    DEFINE iExisteMaehis        SMALLINT;
    
    LET vcodret           = "000";
    LET vcodret2          = "";
    LET vcodret3          = "";
    LET cProducto         = "";
    LET cNumProducto      = "";
    LET cNumTarjeta       = "";
    LET cClabe            = "";
    LET cNumcte           = "";
    LET cNomcte           = "";
    LET cNumExt           = "";
    LET cNumInt           = "";
    LET cNomCalle         = "";
    LET cNomColonia       = "";
    LET cNomCiudad        = "";
    LET cNomEstado        = "";
    LET cCodPostal        = "";
    LET cRFC              = "";
    LET cCurp             = "";
    LET cNomSucursal      = "";
    LET dFechaini         = "";
    LET dFechafin         = "";
    LET dFechaAlta        = "";
    LET mSaldoPromedio    = 0;
    LET mInteresesNetos   = 0;
    LET mSaldoAnterior    = 0;
    LET mDepositos        = 0;
    LET mRetiros          = 0;
    LET mInteresesPagados = 0;
    LET mOtrosCargos      = 0;
    LET mIvaOtrosCargos   = 0;
    LET mSaldoCorte       = 0;
    LET mRetencionIsr     = 0;
    LET iDias             = 0;
    LET dTasaBruta        = 0;
    LET mAux1             = 0;
    LET vsec_dir          = 0;
    LET pcuenta           = TRIM(pcuenta);
    LET mSaldoRet         = '';
    LET cTipoPersona      = '';
    LET mtotOtroscargos   = 0;
    LET mGat              = 0;
    LET mTotRetiros       = 0;
    LET iFlagGrafica      = 0;
    LET cAnyomes          = "";
	LET cRFC_alterno      = "";
	LET  cSufijos         = '';
    LET iExisteCuenta     = 0;
    LET iExisteMaehis     = 0;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
     --   SET DEBUG FILE TO "/resplogifx/conciliachq/sp_edoctagenerales_central.err";
     --   TRACE ON;
        IF vsqlerr != 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            RETURN vcodret, cProducto, cNumProducto, cNumTarjeta, cClabe, dFechaini, dFechafin, mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos,
                   mIvaOtrosCargos, mSaldoCorte, mSaldoPromedio, mRetencionIsr, mInteresesNetos, iDias, dTasaBruta, cNumcte, cNomcte, cNumExt, cNumInt, cNomCalle, 
                   cNomColonia, cNomCiudad, cNomEstado, cCodPostal, cRFC, cCurp, dFechaAlta, cNomSucursal, mSaldoRet, mTotOtrosCargos, mGat, mTotRetiros, iFlagGrafica;
        END IF;
    END EXCEPTION;
    
	--- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_edoctagenerales_central.out";
	--- TRACE ON;
        
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT COUNT(*)
      INTO iExisteCuenta
      FROM bdicheq:sc_maechq
     WHERE empresa = pempresa
       AND cuenta = pcuenta;
       
    -- // VALIDA QUE LA CUENTA EXISTE 
    IF iExisteCuenta > 0 THEN
        -- // OBTIENE TIPO DE PERSONA 
        Select tpo_persona
          Into cTipoPersona
          From bdinteg:si_cliente
         Where numcte = ( Select num_cte
                            From bdicheq:sc_maechq
                           Where empresa = pempresa
                             And cuenta = pcuenta );

        -- // EN EN EL CASO DE PERSONA FISICA SE VA POR LA SECUENCIA MAXIMA DE NUMERO DE TARJETA DEL TITULAR
        If Trim(cTipoPersona) = '01' Then 
            Select num_tarjeta
              Into cNumTarjeta
              From bdicheq:sc_tarjeta
             Where empresa = pempresa
               And cuenta = pcuenta
               And tipo_tarjeta = "T"
               And status_tar = "A";
        End If;

        SELECT valor
          INTO cFech_param_old
          FROM bdicheq:sc_param
         WHERE empresa = pEmpresa
           AND codparam = 'FechIniCon_movhis_ol';
        
        -- // CONSULTA DE ESTADO DE CUENTA
        IF ptipo = '0' THEN 
            -- // OBTENER EL ESTADO DE CUENTA. SE MODIFICO PARA QUE MOSTRARA EL NUMERO DE TARJETA DE LA CUENTA MAS ACTUAL DEL CLIENTE
            SELECT {+INDEX(sc_maehis idx_maehis1)}
                   TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto, mc.producto,
                   TRIM(mc.num_cte), mc.cuenta_clabe, NVL(mc.fechaini, MDY(1, 1, 1900)), NVL(mc.fechafin,
                   MDY(1, 1, 1900)),NVL(sdo_mes_ant, 0), NVL(totdepositos, 0), NVL(totintpag, 0),
                   NVL(totretiros, 0),NVL(totcomcobrada, 0), NVL(totivacobrado, 0), NVL(sdo_actual, 0),
                   NVL(totisrcobrado, 0),NVL(dia_sdo_pos, 0), (NVL(tasabruta, 0) * 100), NVL(acum_sdo_pos, 0),
                   NVL(sdo_retenido, 0), NVL(tototroscargos,0), (NVL(gat,0)*100), NVL(totretirosefec,0)
              INTO cProducto, cNumProducto, cNumcte, cClabe, dFechaini, dFechafin,
                   mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros,
                   mOtrosCargos, mIvaOtrosCargos, mSaldoCorte,
                   mRetencionIsr, iDias, dTasaBruta, mAux1,mSaldoRet, mTotOtrosCargos, mGat, mTotRetiros
              FROM sc_maehis AS mc,
                   sc_producto AS ap
             WHERE mc.empresa = pempresa 
               AND mc.cuenta = pcuenta 
               AND mc.aniomes = paniomes 
               AND mc.empresa = ap.empresa 
               AND mc.producto = ap.producto 
               AND mc.fechaini >= cFech_param_old;

              SELECT TRIM(valor) 
                INTO cAnyomes
                FROM sc_param 
               WHERE empresa = pEmpresa
                 AND codparam = 'edoctagrafica' ;

              IF CAST(paniomes as INTEGER) >= CAST(cAnyomes as INTEGER) THEN
                  LET iFlagGrafica = 1;
              END IF;    
        
        -- // CONSULTA DE MOVIMIENTOS
        ELIF ptipo = '1'  THEN 
            LET dFechaini = "";
            LET dFechafin = "";
            LET v_mes     = "";
            LET v_mes2    = "";

            -- // SE MODIFICO PARA QUE MOSTRARA EL NUMERO DE TARJETA DE LA CUENTA MAS ACTUAL DEL CLIENTE 
            SELECT TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto, mc.producto,
                   TRIM(mc.num_cte), mc.cuenta_clabe, MDY(1, 1, 1900), MDY(1, 1, 1900),
                   NVL(mc.sdo_dia_ant, 0), NVL(mc.depositos_cantidad, 0), 0, NVL(mc.retiros_cantidad, 0),
                   0, 0, NVL(mc.sdo_actual, 0), 0, 0, 0, 0,NVL(sdo_retenido, 0)
              INTO cProducto, cNumProducto, cNumcte, cClabe, dFechaini, dFechafin,
                   mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros,
                   mOtrosCargos, mIvaOtrosCargos, mSaldoCorte,
                   mRetencionIsr, iDias, dTasaBruta, mAux1,mSaldoRet
              FROM sc_maechq AS mc,
                   sc_producto AS ap
             WHERE mc.empresa = pempresa 
               AND mc.cuenta = pcuenta 
               AND mc.empresa = ap.empresa 
               AND mc.producto = ap.producto;

            -- // SE OBTIENE LA FECHA DE INICIO PARA PRESENTAR LOS MOVIMIENTOS, FECHA FIN DE SU ULTIMO MESIVERSARIO 
            SELECT COUNT(*) 
              INTO iExisteMaehis
              FROM sc_maehis_factelect 
             WHERE empresa = pempresa 
               AND cuenta = pcuenta
               AND fechaini >= cFech_param_old;
               
            IF iExisteMaehis > 0 THEN
                SELECT MAX(fechafin)
                  INTO dFechaini
                  FROM sc_maehis_factelect
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta
                   AND fechaini >= cFech_param_old;
                
                SELECT sdo_actual
                  INTO mSaldoAnterior
                  FROM sc_maehis_factelect
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta
                   AND fechafin = dFechaini;
                   
                -- // A LA FECHA DE INICIO SE LE SUMA 1 DIA PARA QUE NO CONSIDERE LOS MOVTOS QUE YA APARECEN EN EL EDOCTA 
                LET dFechaini = dFechaini + 1 units day;
            ELSE 
                -- // SI LA CUENTA NO HA TENIDO UN MESIVERSARIO SE TOMA LA FECHA DE ALTA DE LA CUENTA 
                SELECT fecha_alta
                  INTO dFechaini
                  FROM sc_maenoc
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta;
                   
                LET mSaldoAnterior = 0.00;
            END IF;
            
			-- // SE OBTIENE PARAMETRO PARA ACTIVAR EL FLAG QUE AUTORIZA QUE SE MUESTRE GRÁFICA 
			SELECT TRIM(valor) 
              INTO cAnyomes
              FROM sc_param 
             WHERE empresa = pEmpresa
               AND codparam = 'edoctagrafica' ;

            IF CAST(paniomes as INTEGER) >= CAST(cAnyomes as INTEGER) THEN
                LET iFlagGrafica = 1;
            END IF;   
			  
            -- // SE OBTIENE LA FECHA DE HOY QUE ES LA FECHA FIN AL CONSULTAR MOVIMIENTOS 
            SELECT fecha_hoy
              INTO dFechafin
              FROM sc_fechas
             WHERE empresa = pempresa;
        ELSE
            LET vcodret = "005";
        END IF;

        IF vcodret <> '005' THEN
            -- // EXTRAE LA ULTIMA SECUENCIA DE TIPO CASA DE DIRECCIONES MEL 
            SELECT secuencia
              INTO vsec_dir
              FROM bdinteg:si_direcciones_actual
             WHERE numcte = cnumcte 
               AND tipo_dir = 1;
           
            IF vsec_dir IS NULL THEN
                SELECT secuencia
                  INTO vsec_dir
                  FROM bdinteg:si_direcciones_actual
                 WHERE numcte = cnumcte 
                   AND tipo_dir = 2;
                   
                IF vsec_dir IS NULL THEN
                    SELECT secuencia
                      INTO vsec_dir
                      FROM bdinteg:si_direcciones_actual
                     WHERE numcte = cnumcte 
                       AND tipo_dir = 3;
                       
                    IF vsec_dir IS NULL THEN
                        LET vsec_dir = 1;
                    END IF;
                END IF;
            END IF

            IF iDias = 0 THEN
                LET mSaldoPromedio= 0;
            ELSE
                LET mSaldoPromedio= mAux1 / iDias;
            END IF;

            LET mInteresesNetos = mInteresesPagados - mRetencionIsr;

            IF cNumcte IS NULL THEN
                LET vcodret = "003";

                SELECT TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto, mc.producto,
                       TRIM(mc.num_cte), mc.cuenta_clabe
                  INTO cProducto, cNumProducto, cNumcte, cClabe
                  FROM sc_maechq AS mc,
                       sc_producto AS ap
                 WHERE mc.empresa = pempresa
                   AND mc.cuenta = pcuenta
                   AND mc.empresa = ap.empresa
                   AND mc.producto = ap.producto;

                SELECT NVL(TRIM(cte.razon_social), "") || NVL(TRIM(cte.nombre1), "") || ' ' || NVL(TRIM(cte.nombre2), "") || ' ' || NVL(TRIM(cte.apell_paterno), "") || ' ' || NVL(TRIM(cte.apell_materno), "") AS nombrex,
                       suc.nombre, cte.fecha_insert, cte.rfc, cte.rfc_alterno, cpf.curp, dir.numeroextcalle, dir.numerointcalle,
                       TRIM(cal.nombrecalle), TRIM(zon.nombrezona), TRIM(ciu.nombre), TRIM(edo.nombre), dir.cod_postal
                  INTO cNomcte, cNomSucursal, dFechaAlta, cRFC, cRFC_alterno, cCurp, cNumExt, cNumInt, cNomCalle,
                       cNomColonia, cNomCiudad, cNomEstado, cCodPostal
                  FROM bdinteg:si_cliente AS cte
                  LEFT JOIN bdinteg:si_ctepf cpf ON (cpf.numcte = cte.numcte)
                  LEFT JOIN bdinteg:si_direcciones_actual AS dir ON (dir.numcte = cte.numcte)
                  LEFT JOIN bdinteg:si_estados AS edo ON (edo.estado = dir.estado AND edo.pais = "001")
                  LEFT JOIN bdinteg:si_ciudades AS ciu ON (ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
                  LEFT JOIN bdinteg:si_catzonas AS zon ON (zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
                  LEFT JOIN bdinteg:si_catcalles AS cal ON (cal.numerocalle = dir.numerocalle)
                  LEFT JOIN bdinteg:si_sucursales AS suc ON (suc.sucursal = cte.sucursal)
                 WHERE cte.empresa = pempresa
                   AND cte.numcte = cNumcte
                   AND dir.secuencia = vsec_dir;

                LET dFechaini = "";
                LET dFechafin = "";
                LET mSaldoAnterior = 0;
                LET mDepositos = 0;
                LET mInteresesPagados = 0;
                LET mRetiros = 0;
                LET mOtrosCargos = 0;
                LET mIvaOtrosCargos = 0;
                LET mSaldoCorte = 0;
                LET mSaldoPromedio = 0;
                LET mRetencionIsr = 0;
                LET mInteresesNetos = 0;
                LET iDias = 0;
                LET dTasaBruta = 0;
            ELSE
                SELECT NVL(TRIM(cte.razon_social), "") || NVL(TRIM(cte.nombre1), "") || ' ' || NVL(TRIM(cte.nombre2), "") || ' ' || NVL(TRIM(cte.apell_paterno), "") || ' ' || NVL(TRIM(cte.apell_materno), "") AS nombrex,
                       suc.nombre, cte.fecha_insert, cte.rfc, cte.rfc_alterno, cpf.curp, dir.numeroextcalle, dir.numerointcalle,
                       TRIM(cal.nombrecalle), TRIM(zon.nombrezona), TRIM(ciu.nombre), TRIM(edo.nombre), dir.cod_postal
                  INTO cNomcte, cNomSucursal, dFechaAlta, cRFC, cRFC_alterno, cCurp, cNumExt, cNumInt, cNomCalle, cNomColonia,
                       cNomCiudad, cNomEstado, cCodPostal
                  FROM bdinteg:si_cliente AS cte
                  LEFT JOIN bdinteg:si_ctepf AS cpf ON (cpf.numcte = cte.numcte)
                  LEFT JOIN bdinteg:si_direcciones_actual AS dir ON (dir.numcte = cte.numcte)
                  LEFT JOIN bdinteg:si_estados AS edo ON (edo.estado = dir.estado AND edo.pais = "001")
                  LEFT JOIN bdinteg:si_ciudades AS ciu ON (ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
                  LEFT JOIN bdinteg:si_catzonas AS zon ON (zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
                  LEFT JOIN bdinteg:si_catcalles AS cal ON (cal.numerocalle = dir.numerocalle)
                  LEFT JOIN bdinteg:si_sucursales AS suc ON (suc.sucursal = cte.sucursal)
                 WHERE cte.empresa = pempresa
                   AND cte.numcte = cNumcte
                   AND dir.secuencia = vsec_dir;
            END IF;
            
            IF cRFC_alterno is not null and cRFC_alterno <> "" THEN
               LET cRFC = cRFC_alterno;
            END IF;	
        END IF;
        
        -- // SE OBTINE EL SUBFIJO DE LA EMPRESA Y SE AGREGA AL NOMBRE
        IF cTipoPersona NOT IN('01','03') THEN
            SELECT TRIM(suf.descripcion) 
              INTO cSufijos
              FROM bdinteg: "informix".si_sufijos suf, 
                   bdinteg: "informix".si_ctepm pm
             WHERE pm.empresa = pempresa
               AND pm.numcte = cNumcte
               AND suf.codigo = pm.sufijo;
            
            LET cNomcte = TRIM(cNomcte)||" "||TRIM(cSufijos);
        END IF;
    ELSE
        LET vcodret = "100";
    END IF;
    
    RETURN vcodret, cProducto, cNumProducto, cNumTarjeta, cClabe, dFechaini, dFechafin, mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos,
           mIvaOtrosCargos, mSaldoCorte, mSaldoPromedio, mRetencionIsr, mInteresesNetos, iDias, dTasaBruta, cNumcte, cNomcte, cNumExt, cNumInt, cNomCalle, 
           cNomColonia, cNomCiudad, cNomEstado, cCodPostal, cRFC, cCurp, dFechaAlta, cNomSucursal, mSaldoRet, mTotOtrosCargos, mGat, mTotRetiros, iFlagGrafica;
    
    END;
    
END PROCEDURE
    
DOCUMENT
'MODIFICA:ARMIDA PAZOS CHÁVEZ',
'DESCRIPCION:SE MODIFCA PARA LA TASABRUTA SE MULTIPLIQUE POR 100',
'FECHA:2009/10/27',
'VERSION:20091027.1241',
'BD: BDICHEQ',
'MODIFICA:ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION:SE UNIFICAN LOS PROCESOS DE SUCURSAL, CENTRAL Y BPI PARA GENERAR EL ENCABEZADO DEL EDO CTA',
'FECHA:NOVIEMBRE 2009',
'VERSION:20091130.1109',
'MODIFICA:SAUL IVANHOE VALDESPINO HERNANDEZ',
'DESCRIPCION:SE MODIFICA PARA QUE REGRESE TRES CAMPOS NUEVOS DE LA sc_maehis:tototroscargos,porcientogat,totretirosefec ',
'FECHA:09/NOV/2010',
'MODIFICA:SAUL IVANHOE VALDESPINO HERNANDEZ',
'DESCRIPCION:SE MODIFICA YA QUE SE SOLICITO CAMBIAR EL NOMBRE DEL CAMPO porcientogat A gat',
'FECHA:23/NOV/2010',
'*******************************************************',
'Autor: 94912599',
'Fecha: 07/10/2013',
'Modificación: Se modifíca procedimiento para agregar sufijo a razon_social de personas morales',
'Sustento: 1450-EdoCtaPersonasMorales-Contrato.pdf',
'Solicita: Daniel Mayen',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_obtienedetalle_edoctacap(pEmpresa CHAR(3),
													pNumCta CHAR(12),
													pNumTarjeta CHAR(16),
													pultreg SMALLINT)
--RETORNO--
RETURNING	CHAR(6),		-- Codigo de Retorno
			CHAR(10),	-- Periodo
			DECIMAL(16,2),	-- Sdo Inicial
			DECIMAL(16,2),	-- Cargos
			DECIMAL(16,2),	-- Abonos
			DECIMAL(16,2);	-- Sdo Final

--DEFINICION DE VARIABLES
DEFINE	iSqlErr 	INTEGER;
DEFINE	cCodRet 	CHAR(6);
DEFINE	cPeriodo	CHAR(10);
DEFINE	dSdoIni		DECIMAL(16,2);
DEFINE	dCargos		DECIMAL(16,2);
DEFINE	dAbonos		DECIMAL(16,2);
DEFINE	dSdoFin		DECIMAL(16,2);
DEFINE	dFecha6mes	DATE;
DEFINE	cPeriodos 	INTEGER;
DEFINE	iTotalCtas	INTEGER;
DEFINE	dFechaHoy	DATE;

--INICIALIZACION DE VARIABLES
LET iSqlErr		= 0;
LET cCodRet		= '000000';
LET	cPeriodo	= '';
LET dSdoIni		= 0;
LET dCargos		= 0;
LET dAbonos		= 0;
LET dSdoFin		= 0;
LET dFecha6mes	= '';
LET cPeriodos	= 0;
LET iTotalCtas	= 0;
LET dFechaHoy = '';

	--SET DEBUG FILE TO '/respaldosbd/claudio/sp_obtienedetalle_edoctacap.out';
	--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,NVL(cPeriodo,''),dSdoIni,dCargos,dAbonos,dSdoFin;
		END IF
	END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF NVL(pEmpresa,'') <> '' AND (NVL(pNumCta,'') <> '' OR NVL(pNumTarjeta,'') <> '') THEN
	
		SELECT valor INTO cPeriodos FROM bdinteg:"informix".si_param WHERE cod_param = 400 AND empresa = pEmpresa;	
		SELECT fecha_hoy INTO dFechaHoy FROM bdicheq:"informix".sc_fechas;		
		EXECUTE PROCEDURE bdicred:"informix".monthadd(dFechaHoy,-cPeriodos) INTO dFecha6mes;		
		
		IF NVL(pNumTarjeta,'') <> '' THEN
            SELECT cuenta 
              into pNumCta
              from bdicheq:"informix".sc_tarjeta 
              where empresa = pEmpresa 
                and num_tarjeta = pNumTarjeta;
        END IF;

        IF ( pNumCta is null ) THEN 
            LET cCodRet = '000001'; --Parametros Vacios.
        ELSE
            FOREACH
                SELECT fechafin,sdo_mes_ant,totretiros,totdepositos,sdo_actual INTO cPeriodo,dSdoIni,dCargos,dAbonos,dSdoFin
                FROM bdicheq:"informix".sc_maehis_factelect
                WHERE empresa = pEmpresa AND fechafin > dFecha6mes AND fechafin <= dFechaHoy AND cuenta = pNumCta ORDER BY aniomes DESC

                LET iTotalCtas = iTotalCtas + 1;
                IF iTotalCtas <= pultreg THEN
                    CONTINUE FOREACH;
                END IF
                RETURN cCodRet,NVL(cPeriodo,''),dSdoIni,dCargos,dAbonos,dSdoFin WITH RESUME;
            END FOREACH;

            IF iTotalCtas = 0 THEN
                LET cCodRet = '000002'; --Cta o Tarj sin Edos de Cuenta.
            END IF

        END IF;

	ELSE
		LET cCodRet = '000001'; --Parametros Vacios.
	END IF

	IF NVL(cCodRet,'') <> '000000' THEN
		RETURN cCodRet,NVL(cPeriodo,''),dSdoIni,dCargos,dAbonos,dSdoFin;
	END IF
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Cosulta estados de cuenta captacion CFDI',
'REALIZO: Claudio Almodovar',
'FECHA: 08/07/2014',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_cancelaportanom_bpi (pEmpresa CHAR(3),pNumcte CHAR(20),pCtaOrdenante CHAR(20),pFolio CHAR(30),pFolioCancela CHAR(30),pUserCancela CHAR(8),pSucCancela CHAR(4))
RETURNING
	CHAR(5)   AS	vcCodRet;
	
	--DECLARA VARIABLES
	DEFINE cCodRet					CHAR (5);
	DEFINE cSqlErr					SMALLINT;
	DEFINE vcNumCte					CHAR(20);
	DEFINE viNumReg					SMALLINT;
	DEFINE vcCuenta					CHAR(20);
	
	--INICIALIZA VARIABLES
	LET cCodRet					= '00000';
	LET cSqlErr					= 0;
	LET vcNumCte				= '';
	LET	viNumReg				= 0;
	LET vcCuenta				= '';
	
	BEGIN
		ON EXCEPTION SET cSqlErr
			IF cSqlErr <> 0 THEN
				LET cCodRet = cSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		
		  --SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_cancelaportanom_bpi.out";
		  --TRACE ON;
		
		SET LOCK MODE TO WAIT 3;	
		
		SELECT cta_ordenante INTO vcCuenta FROM bdicheq:"informix".sc_portacec_solicitud WHERE empresa = pEmpresa AND num_cte = pNumcte AND folio_solicitud = pFolio;
				
		IF EXISTS (SELECT num_cte FROM bdicheq:"informix".sc_portacec_solicitud WHERE empresa = pEmpresa AND num_cte = pNumcte 	AND cta_ordenante = vcCuenta  AND folio_solicitud = pFolio) then
			
			SELECT {+INDEX (sc_maechq, idx_ctaclabe)} cuenta INTO vcCuenta FROM bdicheq:"informix".sc_maechq WHERE cuenta_clabe=pCtaOrdenante;
			IF EXISTS(SELECT cliente FROM bdicheq:"informix".sc_portabilidadnomina WHERE empresa = pEmpresa AND cliente = pNumcte and cuenta_abono = vcCuenta)THEN
							
				UPDATE bdicheq:"informix".sc_portabilidadnomina 
				SET estatus='02', user_cancel='transBPI', fecha_cancel=TODAY, origen_cancel='WEB', sucursal_cancel='5003' 
				WHERE empresa = pEmpresa AND cliente = pNumcte and cuenta_abono = vcCuenta;
				
				UPDATE bdicheq:"informix".sc_portacec_solicitud
				SET estatus_portabilidad='4', clave_sentido='0', folio_cancelacion=pFolioCancela, fecha_estatus_portabilidad= year(today)||lpad(month(today),2,0)||lpad(day(today),2,0)   ,fecha_solca_portabilidad= year(today)||lpad(month(today),2,0)||lpad(day(today),2,0) , clave_origen= '2', suc_cancela='5003', user_cancela='transBPI'
				WHERE empresa = pEmpresa AND num_cte = pNumcte AND cta_ordenante = pCtaOrdenante 
				AND folio_solicitud = pFolio;
				
			ELSE
				LET cCodRet = '002';			END IF;
		ELSE
			LET cCodRet = '001';		END IF;

		RETURN cCodRet;
	END;
END PROCEDURE;