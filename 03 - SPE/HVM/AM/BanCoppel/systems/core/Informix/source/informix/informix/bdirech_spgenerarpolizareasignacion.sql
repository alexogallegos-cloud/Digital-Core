CREATE PROCEDURE "informix".spgenerarpolizareasignacion(p_dFechaActual DATE, p_sUsuario CHAR(8))
	RETURNING CHAR(5) AS CodigoRetorno, INTEGER AS numeroPoliza;

	DEFINE iSqlErr                                                  INTEGER;
	DEFINE v_sCodRet                                                CHAR(5);
	DEFINE v_sSistema                                               CHAR(2);
	DEFINE v_sCentroCostos											CHAR(4);
	DEFINE v_sCentroCostosRH                                        CHAR(4);
	DEFINE v_sTransacReasigFaltante                         		CHAR(4);
	DEFINE v_sDescripcionParametro                          		CHAR(60);

	DEFINE v_iIdAsignado                                         	SMALLINT;
	DEFINE v_iIdAsignadoAnt                                        	SMALLINT;
	DEFINE v_mCargoEntero                                       	MONEY(32,0);
	DEFINE v_mAbonoEntero                                       	MONEY(32,2);
	DEFINE v_mCargoCentavos                                     	MONEY(32,2);
	DEFINE v_mAbonoCentavos                                       	MONEY(32,2);
	DEFINE v_sAuxiliar                                              CHAR(12);
	DEFINE v_sAuxiliarAnt 										    CHAR(12);
	DEFINE v_sSucursal                                              CHAR(4);
	DEFINE v_sEmpresa                                               CHAR(3);
	DEFINE v_iControlPoliza                                         INTEGER;
	DEFINE v_sFechaActual                                           CHAR(10);
	DEFINE v_iSecuencia                                             INTEGER;
	
	--CUENTAS CONTABLES REASIGNACION POR FALTANTES
	--Cargo
	DEFINE v_sCrf_ccmayor                                           CHAR(4);
	DEFINE v_sCrf_ccsub                                             CHAR(2);
	DEFINE v_sCrf_ccsubsub                                          CHAR(2);
	DEFINE v_sCrf_ccsssub                                           CHAR(2);
	DEFINE v_sCrf_ccssssub                                          CHAR(2);
	DEFINE v_sCrf_sector                                            CHAR(2);
	--Abono
	DEFINE v_sArf_ccmayor                                           CHAR(4);
	DEFINE v_sArf_ccsub                                             CHAR(2);
	DEFINE v_sArf_ccsubsub                                          CHAR(2);
	DEFINE v_sArf_ccsssub                                           CHAR(2);
	DEFINE v_sArf_ccssssub                                          CHAR(2);
	DEFINE v_sArf_sector                                            CHAR(2);
	
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
	DEFINE v_iSecuenciaTemp                                         INTEGER;
	DEFINE v_iNumRegistrosTemp                                      INTEGER;
	DEFINE v_iControlPolizaTemp                                     INTEGER;

	--SET DEBUG FILE TO  "/tmp/mfinis/spgenerarpolizareasignacion.out";
	--TRACE ON;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				INSERT INTO bdirech:"informix".rec_errores(descripcion) VALUES ('sgpr'|| iSqlErr);
				RETURN v_sCodRet, 0;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--VALIDA PARÃMETROS DE ENTRADA
		IF NVL(p_dFechaActual, '') = '' OR NVL(p_sUsuario, '') = '' THEN
			LET v_sCodRet = '00001';
			RETURN v_sCodRet, 0;
		END IF;

		LET v_iSecuencia = 0;
		LET v_sEmpresa = '001';
		LET v_iControlPoliza = 0;
		LET v_sCentroCostos = '';
		LET v_sAuxiliarAnt = '';
		
		--CAMBIA EL FORMATO DE LA FECHA A MMDDAAAA PARA QUE SE PUEDA INSERTAR EN LA POLIZA
		--LET v_sFechaActual = LPAD(MONTH(p_dFechaActual),2,'0')||LPAD(DAY(p_dFechaActual),2,'0')||YEAR(p_dFechaActual);
		SELECT LPAD(MONTH(fecha_hoy),2,'0')||LPAD(DAY(fecha_hoy),2,'0')||YEAR(fecha_hoy) INTO v_sFechaActual FROM bdicont:"informix".co_fechas;
		
		--SE OBTIENE EL NÃMERO DE SISTEMA DE ADMINISTRACION DE FALTANTES
		EXECUTE PROCEDURE bdirech:"informix".spconsultarparam(3) INTO v_sCodRet, v_sDescripcionParametro, v_sSistema;

		--SE OBTIENE EL CENTRO DE COSTOS DE RECURSOS HUMANOS
		EXECUTE PROCEDURE bdirech:"informix".spconsultarparam(2) INTO v_sCodRet, v_sDescripcionParametro, v_sCentroCostosRH;

		--SE OBTIENE EL NUMERO DE TRANSACCION Y LA DESCRIPCION PARA REASIGNACION DE FALTANTES
		SELECT numero INTO v_sTransacReasigFaltante FROM bdinteg:"informix".si_transacc WHERE sistema = v_sSistema AND abreviatura = 'REASFAL';

		IF v_sCodRet = '00000' THEN
			--PARA  CADA AUXILIAR DE LA TRANSACCION, SE GENERA UN MOVIMIENTO DE CARGO Y DE ABONO POR CADA CTA CONTABLE
			FOREACH							
				SELECT a.idasignado, a.idasignadoant, SUM(CASE WHEN b.montomovimiento > .50 THEN (ROUND(b.montomovimiento)) 
                ELSE (TRUNC(b.montomovimiento)) END), 
				SUM(b.montomovimiento), SUM(CASE WHEN b.montomovimiento < .51 THEN b.montomovimiento ELSE 0 END),
				SUM(CASE WHEN b.montomovimiento > .50 AND b.montomovimiento < 1 THEN (1 - b.montomovimiento) ELSE 0 END),
				b.auxiliar, b.numsucursal			  
				INTO v_iIdAsignado, v_iIdAsignadoAnt, v_mCargoEntero, v_mAbonoEntero, v_mCargoCentavos, v_mAbonoCentavos, v_sAuxiliar, v_sSucursal
				FROM bdirech:"informix".rec_confaltante a, bdirech:"informix".rec_movfaltante b
				WHERE a.referencia = b.referencia
				AND b.transaccion = v_sTransacReasigFaltante 
				AND b.idmovimiento <> 0
				AND b.tipomovimiento = 'R' 
				AND b.fecharegistro = p_dFechaActual
				AND b.contable = '0'
				AND idasignado IN (2,3)
				GROUP BY a.idasignado, a.idasignadoant, b.auxiliar, b.numsucursal
				
				IF (v_iIdAsignado = 2 AND v_iIdAsignadoAnt = 1) OR (v_iIdAsignado = 3 AND v_iIdAsignadoAnt = 1) THEN	
					
					LET v_iSecuencia = v_iSecuencia + 1;

					--SE OBTIENEN LAS CUENTAS CONTABLES DE LA TRANSACCION DE REASIGNACION POR FALTANTES
					EXECUTE PROCEDURE bdinteg:"informix".spobtenercuentascontables (v_sEmpresa, v_sTransacReasigFaltante, v_sSistema, v_iIdAsignado)
					INTO v_sCodRet, v_sCrf_ccmayor, v_sCrf_ccsub, v_sCrf_ccsubsub, v_sCrf_ccsssub, v_sCrf_ccssssub, v_sCrf_sector,
					v_sArf_ccmayor, v_sArf_ccsub, v_sArf_ccsubsub, v_sArf_ccsssub, v_sArf_ccssssub, v_sArf_sector;

					--INSERTAR POLIZA PARA LOS ABONOS DE REASIGNACION POR FALTANTES
					EXECUTE PROCEDURE bdicont:"informix".insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0',
					v_iSecuencia::CHAR(4), v_sArf_ccmayor, v_sArf_ccsub, v_sArf_ccsubsub, v_sArf_ccsssub, v_sArf_ccssssub, v_sArf_sector,
					v_sAuxiliar, v_sSucursal, v_sSucursal, 'C', v_mAbonoEntero::CHAR(20), 'MOVIMIENTO DE ABONO REASINACION DE FALTANTE', '0')
					INTO v_sCodRet, v_iControlPolizaTemp, v_iSecuenciaTemp, v_iNumRegistrosTemp;

					LET v_iSecuencia = v_iSecuencia + 1;
					
					IF v_iIdAsignado IN (3) THEN -- CUENTA NO PERMITE AUXILIAR
						LET v_sAuxiliar = '';
						LET v_sCentroCostos = '9251';
					ELSE
						LET v_sCentroCostos = v_sCentroCostosRH ;
					END IF

					--INSERTAR POLIZA PARA LOS CARGOS  DE REASIGNACION POR FALTANTES
					EXECUTE PROCEDURE bdicont:"informix".insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0',
					v_iSecuencia::CHAR(4), v_sCrf_ccmayor, v_sCrf_ccsub, v_sCrf_ccsubsub, v_sCrf_ccsssub, v_sCrf_ccssssub, v_sCrf_sector,
					v_sAuxiliar, v_sSucursal, v_sCentroCostos, 'D', v_mCargoEntero::CHAR(20), 'MOVIMIENTO DE CARGO REASINACION DE FALTANTE', '0')
					INTO v_sCodRet, v_iControlPolizaTemp, v_iSecuenciaTemp, v_iNumRegistrosTemp;
					
				ELIF (v_iIdAsignado = 2 AND v_iIdAsignadoAnt = 3) THEN				
					
					--CANCELACION CONTABLE MOVIMIENTO OPERACIONES					
					LET v_iSecuencia = v_iSecuencia + 1;
					
					EXECUTE PROCEDURE bdinteg:"informix".spobtenercuentascontables (v_sEmpresa, v_sTransacReasigFaltante, v_sSistema, v_iIdAsignadoAnt)
					INTO v_sCodRet, v_sCrf_ccmayor, v_sCrf_ccsub, v_sCrf_ccsubsub, v_sCrf_ccsssub, v_sCrf_ccssssub, v_sCrf_sector,
					v_sArf_ccmayor, v_sArf_ccsub, v_sArf_ccsubsub, v_sArf_ccsssub, v_sArf_ccssssub, v_sArf_sector;

					LET v_sAuxiliarAnt = '';
					LET v_sCentroCostos = '9251';
					
					--INSERTAR POLIZA PARA LOS ABONO  DE REASIGNACION POR FALTANTES
					EXECUTE PROCEDURE bdicont:"informix".insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0',
					v_iSecuencia::CHAR(4), v_sCrf_ccmayor, v_sCrf_ccsub, v_sCrf_ccsubsub, v_sCrf_ccsssub, v_sCrf_ccssssub, v_sCrf_sector,
					v_sAuxiliarAnt, v_sCentroCostos, v_sCentroCostos, 'C', v_mAbonoEntero::CHAR(20), 'MOVIMIENTO DE ABONO REASINACION DE FALTANTE', '0')
					INTO v_sCodRet, v_iControlPolizaTemp, v_iSecuenciaTemp, v_iNumRegistrosTemp;

					--REASIGNACION CONTABLE MOVIMIENTO RECURSOS HUMANOS
					LET v_iSecuencia = v_iSecuencia + 1;
					LET v_sCentroCostos = '9251';

					--SE OBTIENEN LAS CUENTAS CONTABLES DE LA TRANSACCION DE REASIGNACION POR FALTANTES
					EXECUTE PROCEDURE bdinteg:"informix".spobtenercuentascontables (v_sEmpresa, v_sTransacReasigFaltante, v_sSistema, v_iIdAsignado)
					INTO v_sCodRet, v_sCrf_ccmayor, v_sCrf_ccsub, v_sCrf_ccsubsub, v_sCrf_ccsssub, v_sCrf_ccssssub, v_sCrf_sector,
					v_sArf_ccmayor, v_sArf_ccsub, v_sArf_ccsubsub, v_sArf_ccsssub, v_sArf_ccssssub, v_sArf_sector;					
					
					--INSERTAR POLIZA PARA LOS CARGOS  DE REASIGNACION POR FALTANTES
					EXECUTE PROCEDURE bdicont:"informix".insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0',
					v_iSecuencia::CHAR(4), v_sCrf_ccmayor, v_sCrf_ccsub, v_sCrf_ccsubsub, v_sCrf_ccsssub, v_sCrf_ccssssub, v_sCrf_sector,
					v_sAuxiliar, v_sCentroCostos, v_sCentroCostosRH, 'D', v_mCargoEntero::CHAR(20), 'MOVIMIENTO DE CARGO REASINACION DE FALTANTE', '0')
					INTO v_sCodRet, v_iControlPolizaTemp, v_iSecuenciaTemp, v_iNumRegistrosTemp;
				END IF;
				
				IF v_mCargoCentavos > 0 OR v_mAbonoCentavos > 0 THEN
				
					--SE OBTIENEN LAS CUENTAS CONTABLES PARA EL REDONDEO DE LOS CENTAVOS DE REASIGNACION DE FALTANTES
					EXECUTE PROCEDURE bdinteg:"informix".spobtenercuentascontables (v_sEmpresa, v_sTransacReasigFaltante, v_sSistema, 4)
					INTO v_sCodRet, v_sCcr_ccmayor, v_sCcr_ccsub, v_sCcr_ccsubsub, v_sCcr_ccsssub, v_sCcr_ccssssub, v_sCcr_sector,
					v_sAcr_ccmayor, v_sAcr_ccsub, v_sAcr_ccsubsub, v_sAcr_ccsssub, v_sAcr_ccssssub, v_sAcr_sector;					
					
					IF v_mCargoCentavos > 0 THEN
						LET v_iSecuencia = v_iSecuencia + 1;											
						--INSERTAR POLIZA PARA LOS CARGOS POR REDONDEO
						EXECUTE PROCEDURE bdicont:"informix".insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0',
						v_iSecuencia::CHAR(4), v_sCcr_ccmayor, v_sCcr_ccsub, v_sCcr_ccsubsub, v_sCcr_ccsssub, v_sCcr_ccssssub, v_sCcr_sector,
						'', v_sSucursal, v_sCentroCostosRH, 'D', v_mCargoCentavos::CHAR(20), 'MOVIMIENTO DE CARGO POR REDONDEO', '0')
						INTO v_sCodRet, v_iControlPolizaTemp, v_iSecuenciaTemp, v_iNumRegistrosTemp;
					END IF
					
					IF v_mAbonoCentavos > 0 THEN						
						LET v_iSecuencia = v_iSecuencia + 1;					
						--INSERTAR POLIZA PARA LOS ABONOS POR REDONDEO
						EXECUTE PROCEDURE bdicont:"informix".insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0',
						v_iSecuencia::CHAR(4), v_sAcr_ccmayor, v_sAcr_ccsub, v_sAcr_ccsubsub, v_sAcr_ccsssub, v_sAcr_ccssssub, v_sAcr_sector,
						'', v_sSucursal, v_sCentroCostosRH, 'C', v_mAbonoCentavos::CHAR(20), 'MOVIMIENTO DE ABONO POR REDONDEO', '0')
						INTO v_sCodRet, v_iControlPolizaTemp, v_iSecuenciaTemp, v_iNumRegistrosTemp;
					END IF				
				END IF
			END FOREACH;

			IF v_iSecuencia > 0 THEN --VALIDA SI SE GENERARON MOVIMIENTOS PARA GENERAR POLIZA CONTABLE
				--IF NOT EXISTS (SELECT 1 FROM bdicont:"informix".co_errorpoliza) THEN    
					EXECUTE PROCEDURE bdicont:"informix".validapolizanomina(v_sEmpresa, p_sUsuario) INTO v_sCodRet, v_iControlPoliza;

					--VALIDA QUE NO EXISTAN ERRORES EN LA GENERACION DE LA POLIZA
					IF TRIM(v_sCodRet) = '000' AND v_iControlPoliza <> 0 AND NOT EXISTS(SELECT 1 FROM bdicont:tmpco_auditerr WHERE usuario = p_sUsuario) THEN
						--ACTUALIZA LOS MOVIMIENTOS DE FALTANTE COMO CONTABLES
						UPDATE bdirech:"informix".rec_movfaltante SET contable = '1'
						WHERE transaccion = v_sTransacReasigFaltante AND idmovimiento <> 0 AND tipomovimiento = 'R'
						AND fecharegistro = p_dFechaActual AND contable = '0';

						LET v_sCodRet = '00000';
					ELSE
						LET v_sCodRet = '00003';
						DELETE FROM bdicont:"informix".tmpco_detpol WHERE usuario = p_sUsuario;
					END IF;					
				--ELSE
					--LET v_sCodRet = '00003';
					--DELETE FROM bdicont:"informix".tmpco_detpol WHERE usuario = p_sUsuario;
				--END IF
			ELSE
					LET v_sCodRet = '00004';
			END IF
		ELSE
			LET v_sCodRet = '00002';
		END IF;
		RETURN v_sCodRet, v_iControlPoliza;
	END
END PROCEDURE
