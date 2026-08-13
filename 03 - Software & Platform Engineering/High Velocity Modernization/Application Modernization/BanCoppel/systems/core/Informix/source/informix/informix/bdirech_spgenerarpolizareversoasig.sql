CREATE PROCEDURE "informix".spgenerarpolizareversoasig(p_dFechaActual DATE, p_sUsuario CHAR(8))

	RETURNING CHAR(5) AS CodigoRetorno, INTEGER AS numeroPoliza;

	DEFINE iSqlErr                                                  INTEGER;
	DEFINE v_sCodRet                                                CHAR(5);
	DEFINE v_sSistema                                               CHAR(2);
	DEFINE v_sCentroCostosO											CHAR(4);
	DEFINE v_sCentroCostosD											CHAR(4);
	DEFINE v_sCentroCostosORH                                        CHAR(4);
	DEFINE v_sTransacReversoFaltante                         		CHAR(4);
	DEFINE v_iSecuenciaTransac										SMALLINT;
	DEFINE v_sDescripcionParametro                          		CHAR(60);

	DEFINE v_mMontoOperacion                                       	MONEY(32,2);
	DEFINE v_mMontoRH                                       	MONEY(32,0);
	DEFINE v_mAbonoEntero                                       	MONEY(32,2);
	DEFINE v_mCargoCentavos                                     	MONEY(32,2);
	DEFINE v_mAbonoCentavos                                       	MONEY(32,2);
	DEFINE v_sAuxiliar                                              CHAR(12);
	DEFINE v_sSucursal                                              CHAR(4);
	DEFINE v_sEmpresa                                               CHAR(3);
	DEFINE v_iControlPoliza                                         INTEGER;
	DEFINE v_sFechaActual                                           CHAR(10);
	DEFINE v_iSecuencia                                             INTEGER;
	
	--CUENTAS CONTABLES REVERSO ASIGNACIÃN
	--Cargo
	DEFINE v_sCrf_ccmayorS1                                           CHAR(4);
	DEFINE v_sCrf_ccsubS1                                             CHAR(2);
	DEFINE v_sCrf_ccsubsubS1                                          CHAR(2);
	DEFINE v_sCrf_ccsssubS1                                           CHAR(2);
	DEFINE v_sCrf_ccssssubS1                                          CHAR(2);
	DEFINE v_sCrf_sectorS1                                            CHAR(2);
	--Abono
	DEFINE v_sArf_ccmayorS1                                           CHAR(4);
	DEFINE v_sArf_ccsubS1                                             CHAR(2);
	DEFINE v_sArf_ccsubsubS1                                          CHAR(2);
	DEFINE v_sArf_ccsssubS1                                           CHAR(2);
	DEFINE v_sArf_ccssssubS1                                          CHAR(2);
	DEFINE v_sArf_sectorS1                                            CHAR(2);
	
	--Cargo
	DEFINE v_sCrf_ccmayorS2                                           CHAR(4);
	DEFINE v_sCrf_ccsubS2                                             CHAR(2);
	DEFINE v_sCrf_ccsubsubS2                                          CHAR(2);
	DEFINE v_sCrf_ccsssubS2                                           CHAR(2);
	DEFINE v_sCrf_ccssssubS2                                          CHAR(2);
	DEFINE v_sCrf_sectorS2                                            CHAR(2);
	--Abono
	DEFINE v_sArf_ccmayorS2                                           CHAR(4);
	DEFINE v_sArf_ccsubS2                                             CHAR(2);
	DEFINE v_sArf_ccsubsubS2                                          CHAR(2);
	DEFINE v_sArf_ccsssubS2                                           CHAR(2);
	DEFINE v_sArf_ccssssubS2                                          CHAR(2);
	DEFINE v_sArf_sectorS2                                            CHAR(2);
	
	--CUENTA CONTABLE PARA CENTAVOS REDONDEADOS
	--Cargo
	DEFINE v_sCcr_ccmayor                                           CHAR(4);
	DEFINE v_sCcr_ccsub                                             CHAR(2);
	DEFINE v_sCcr_ccsubsub                                          CHAR(2);
	DEFINE v_sCcr_ccsssub                                           CHAR(2);
	DEFINE v_sCcr_ccssssub                                          CHAR(2);
	DEFINE v_sCcr_sector                                            CHAR(2);
	--Abono
	DEFINE v_sAcr_ccmayor                                           CHAR(4);
	DEFINE v_sAcr_ccsub                                             CHAR(2);
	DEFINE v_sAcr_ccsubsub                                          CHAR(2);
	DEFINE v_sAcr_ccsssub                                           CHAR(2);
	DEFINE v_sAcr_ccssssub                                          CHAR(2);
	DEFINE v_sAcr_sector                                            CHAR(2);

	--RETORNOS INSERTAPOLIZA
	DEFINE v_iControlPolizaTemp                                     INTEGER;
	DEFINE v_iSecuenciaTemp                                         INTEGER;
	DEFINE v_iNumRegistrosTemp                                      INTEGER;

	--SET DEBUG FILE TO  "/dbexport/vladi/spgenerarpolizareversoasig.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				INSERT INTO bdirech:"informix".rec_errores(descripcion) VALUES ('sgpra'|| iSqlErr);
				RETURN v_sCodRet, 0;
			END IF;
		END EXCEPTION;

		--VALIDA PARÃMETROS DE ENTRADA
		IF NVL(p_dFechaActual, '') = '' OR NVL(p_sUsuario, '') = '' THEN
			LET v_sCodRet = '00001';
			RETURN v_sCodRet, 0;
		END IF;

		LET v_iSecuencia = 0;
		LET v_sEmpresa = '001';
		LET v_iControlPoliza = 0;
		LET v_sCentroCostosO = '';
		LET v_sCentroCostosD = '';

		--CAMBIA EL FORMATO DE LA FECHA A MMDDAAAA PARA QUE SE PUEDA INSERTAR EN LA POLIZA
		SELECT LPAD(MONTH(fecha_hoy), 2, '0')||LPAD(DAY(fecha_hoy), 2, '0')||YEAR(fecha_hoy)
		INTO v_sFechaActual
		FROM bdicont:"informix".co_fechas;
		
		--SE OBTIENE EL NÃMERO DE SISTEMA DE ADMINISTRACION DE FALTANTES
		EXECUTE PROCEDURE bdirech:"informix".spconsultarparam(3)
		INTO v_sCodRet, v_sDescripcionParametro, v_sSistema;

		--SE OBTIENE EL CENTRO DE COSTOS DE RECURSOS HUMANOS
		EXECUTE PROCEDURE bdirech:"informix".spconsultarparam(2)
		INTO v_sCodRet, v_sDescripcionParametro, v_sCentroCostosORH;

		--SE OBTIENE EL NUMERO DE TRANSACCION Y LA DESCRIPCION PARA REASIGNACION DE FALTANTES
		SELECT numero INTO v_sTransacReversoFaltante
		FROM bdinteg:"informix".si_transacc
		WHERE sistema = v_sSistema AND abreviatura = 'REVASIGFA';
		
		--SE OBTIENEN LAS CUENTAS CONTABLES DE LA TRANSACCION DE REASIGNACION POR FALTANTES DE RH A SUCURSAL
		EXECUTE PROCEDURE bdinteg:"informix".spobtenercuentascontables (v_sEmpresa, v_sTransacReversoFaltante, v_sSistema, 1)
		INTO v_sCodRet, v_sCrf_ccmayorS1, v_sCrf_ccsubS1, v_sCrf_ccsubsubS1, v_sCrf_ccsssubS1, v_sCrf_ccssssubS1, v_sCrf_sectorS1,
						v_sArf_ccmayorS1, v_sArf_ccsubS1, v_sArf_ccsubsubS1, v_sArf_ccsssubS1, v_sArf_ccssssubS1, v_sArf_sectorS1;
		
		--SE OBTIENEN LAS CUENTAS CONTABLES DE LA TRANSACCION DE REASIGNACION POR FALTANTES DE OPERACIONES A SUCURSAL
		EXECUTE PROCEDURE bdinteg:"informix".spobtenercuentascontables (v_sEmpresa, v_sTransacReversoFaltante, v_sSistema, 2)
		INTO v_sCodRet, v_sCrf_ccmayorS2, v_sCrf_ccsubS2, v_sCrf_ccsubsubS2, v_sCrf_ccsssubS2, v_sCrf_ccssssubS2, v_sCrf_sectorS2,
						v_sArf_ccmayorS2, v_sArf_ccsubS2, v_sArf_ccsubsubS2, v_sArf_ccsssubS2, v_sArf_ccssssubS2, v_sArf_sectorS2;
		
		--SE OBTIENEN LAS CUENTAS CONTABLES PARA EL REDONDEO DE LOS CENTAVOS DE REASIGNACION DE FALTANTES
		EXECUTE PROCEDURE bdinteg:"informix".spobtenercuentascontables (v_sEmpresa, v_sTransacReversoFaltante, v_sSistema, 4)
		INTO v_sCodRet, v_sCcr_ccmayor, v_sCcr_ccsub, v_sCcr_ccsubsub, v_sCcr_ccsssub, v_sCcr_ccssssub, v_sCcr_sector,
		v_sAcr_ccmayor, v_sAcr_ccsub, v_sAcr_ccsubsub, v_sAcr_ccsssub, v_sAcr_ccssssub, v_sAcr_sector;					

		IF v_sCodRet = '00000' THEN
			--PARA CADA AUXILIAR DE LA TRANSACCION, SE GENERA UN MOVIMIENTO DE CARGO Y DE ABONO POR CADA CTA CONTABLE
			FOREACH
				SELECT 
				SUM(CASE WHEN b.secuencia = 1 THEN ROUND( b.montomovimiento,0 ) ELSE 0 END),
				SUM(CASE WHEN b.secuencia = 1 AND b.montomovimiento < .51 THEN b.montomovimiento ELSE 0 END),
				SUM(CASE WHEN b.secuencia = 1 AND b.montomovimiento > .50 AND b.montomovimiento < 1 THEN (1 - b.montomovimiento) ELSE 0 END),
				SUM(CASE WHEN b.secuencia = 2 THEN b.montomovimiento ELSE 0 END),
				b.auxiliar, b.numsucursal, b.secuencia
				INTO v_mMontoRH, v_mCargoCentavos, v_mAbonoCentavos, v_mMontoOperacion, v_sAuxiliar, v_sSucursal, v_iSecuenciaTransac
				FROM bdirech:"informix".rec_confaltante a, bdirech:"informix".rec_movfaltante b
				WHERE a.referencia = b.referencia AND a.idfaltante = b.idfaltante
				AND a.idasignado = 1 AND b.idmovimiento <> 0
				AND b.tipomovimiento = 'D' AND b.contable = '0' AND b.transaccion = v_sTransacReversoFaltante 
				AND b.fecharegistro = p_dFechaActual
				GROUP BY b.auxiliar, b.numsucursal, b.secuencia
				ORDER BY b.secuencia

				--REASIGNACION POR FALTANTES DE RH A SUCURSAL
				IF (v_iSecuenciaTransac = 1) THEN
					LET v_iSecuencia = v_iSecuencia + 1;
					LET v_sCentroCostosO = '9103';

					--INSERTAR POLIZA PARA LOS CARGOS DE REVERSO DE RH A SUCURSAL
					EXECUTE PROCEDURE bdicont:"informix".insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0',
					v_iSecuencia::CHAR(4), v_sCrf_ccmayorS1, v_sCrf_ccsubS1, v_sCrf_ccsubsubS1, v_sCrf_ccsssubS1, v_sCrf_ccssssubS1, v_sCrf_sectorS1,
					v_sAuxiliar, v_sCentroCostosO, v_sSucursal, 'D', v_mMontoRH::CHAR(20), 'TRASPASO POR REUBICACIÃN', '0')
					INTO v_sCodRet, v_iControlPolizaTemp, v_iSecuenciaTemp, v_iNumRegistrosTemp;

					LET v_iSecuencia = v_iSecuencia + 1;
					LET v_sCentroCostosD = v_sCentroCostosO;

					--INSERTAR POLIZA PARA LOS ABONOS DE REVERSO DE RH A SUCURSAL
					EXECUTE PROCEDURE bdicont:"informix".insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0',
					v_iSecuencia::CHAR(4), v_sArf_ccmayorS1, v_sArf_ccsubS1, v_sArf_ccsubsubS1, v_sArf_ccsssubS1, v_sArf_ccssssubS1, v_sArf_sectorS1,
					v_sAuxiliar, v_sCentroCostosO, v_sCentroCostosD, 'C', v_mMontoRH::CHAR(20), 'TRASPASO POR REUBICACIÃN', '0')
					INTO v_sCodRet, v_iControlPolizaTemp, v_iSecuenciaTemp, v_iNumRegistrosTemp;

				--REASIGNACION POR FALTANTES DE OPERACIONES A SUCURSAL
				ELSE
					LET v_iSecuencia = v_iSecuencia + 1;
					LET v_sCentroCostosO = '9251';

					--INSERTAR POLIZA PARA LOS CARGOS DE REVERSO DE OPERACIONES A SUCURSAL
					EXECUTE PROCEDURE bdicont:"informix".insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0',
					v_iSecuencia::CHAR(4), v_sCrf_ccmayorS2, v_sCrf_ccsubS2, v_sCrf_ccsubsubS2, v_sCrf_ccsssubS2, v_sCrf_ccssssubS2, v_sCrf_sectorS2,
					v_sAuxiliar, v_sCentroCostosO, v_sSucursal, 'D', v_mMontoOperacion::CHAR(20), 'TRASPASO POR REUBICACIÃN', '0')
					INTO v_sCodRet, v_iControlPolizaTemp, v_iSecuenciaTemp, v_iNumRegistrosTemp;

					LET v_iSecuencia = v_iSecuencia + 1;
					LET v_sCentroCostosD = v_sCentroCostosO;

					--INSERTAR POLIZA PARA LOS ABONOS DE REVERSO DE RH A SUCURSAL
					EXECUTE PROCEDURE bdicont:"informix".insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0',
					v_iSecuencia::CHAR(4), v_sArf_ccmayorS2, v_sArf_ccsubS2, v_sArf_ccsubsubS2, v_sArf_ccsssubS2, v_sArf_ccssssubS2, v_sArf_sectorS2,
					'', v_sCentroCostosO, v_sCentroCostosD, 'C', v_mMontoOperacion::CHAR(20), 'TRASPASO POR REUBICACIÃN', '0')
					INTO v_sCodRet, v_iControlPolizaTemp, v_iSecuenciaTemp, v_iNumRegistrosTemp;
				END IF;

				IF v_mCargoCentavos > 0 OR v_mAbonoCentavos > 0 THEN
					IF v_mCargoCentavos > 0 THEN
						LET v_iSecuencia = v_iSecuencia + 1;
						--INSERTAR POLIZA PARA LOS CARGOS POR REDONDEO
						EXECUTE PROCEDURE bdicont:"informix".insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0',
						v_iSecuencia::CHAR(4), v_sCcr_ccmayor, v_sCcr_ccsub, v_sCcr_ccsubsub, v_sCcr_ccsssub, v_sCcr_ccssssub, v_sCcr_sector,
						'', v_sSucursal, v_sCentroCostosORH, 'D', v_mCargoCentavos::CHAR(20), 'MOVIMIENTO DE CARGO POR REDONDEO', '0')
						INTO v_sCodRet, v_iControlPolizaTemp, v_iSecuenciaTemp, v_iNumRegistrosTemp;
					END IF

					IF v_mAbonoCentavos > 0 THEN
						LET v_iSecuencia = v_iSecuencia + 1;
						--INSERTAR POLIZA PARA LOS ABONOS POR REDONDEO
						EXECUTE PROCEDURE bdicont:"informix".insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0',
						v_iSecuencia::CHAR(4), v_sAcr_ccmayor, v_sAcr_ccsub, v_sAcr_ccsubsub, v_sAcr_ccsssub, v_sAcr_ccssssub, v_sAcr_sector,
						'', v_sSucursal, v_sCentroCostosORH, 'C', v_mAbonoCentavos::CHAR(20), 'MOVIMIENTO DE ABONO POR REDONDEO', '0')
						INTO v_sCodRet, v_iControlPolizaTemp, v_iSecuenciaTemp, v_iNumRegistrosTemp;
					END IF
				END IF
			END FOREACH;

			IF v_iSecuencia > 0 THEN --VALIDA SI SE GENERARON MOVIMIENTOS PARA GENERAR POLIZA CONTABLE
				IF NOT EXISTS (SELECT 1 FROM bdicont:"informix".co_errorpoliza) THEN
					EXECUTE PROCEDURE bdicont:"informix".validapolizanomina(v_sEmpresa, p_sUsuario) INTO v_sCodRet, v_iControlPoliza;

					--VALIDA QUE NO EXISTAN ERRORES EN LA GENERACION DE LA POLIZA
					IF TRIM(v_sCodRet) = '000' AND v_iControlPoliza <> 0 AND NOT EXISTS(SELECT 1 FROM bdicont:tmpco_auditerr WHERE usuario = p_sUsuario) THEN
						--ACTUALIZA LOS MOVIMIENTOS DE FALTANTE COMO CONTABLES
						UPDATE bdirech:"informix".rec_movfaltante SET contable = '1'
						WHERE transaccion = v_sTransacReversoFaltante AND idmovimiento <> 0 AND tipomovimiento = 'D'
						AND fecharegistro = p_dFechaActual AND contable = '0';

						LET v_sCodRet = '00000';
					ELSE
						LET v_sCodRet = '00003';
						DELETE FROM bdicont:"informix".tmpco_detpol WHERE usuario = p_sUsuario;
					END IF;
				ELSE
					LET v_sCodRet = '00003';
					DELETE FROM bdicont:"informix".tmpco_detpol WHERE usuario = p_sUsuario;
				END IF
			ELSE
					LET v_sCodRet = '00004';
			END IF
		ELSE
			LET v_sCodRet = '00002';
		END IF;
		RETURN v_sCodRet, v_iControlPoliza;
	END
END PROCEDURE
