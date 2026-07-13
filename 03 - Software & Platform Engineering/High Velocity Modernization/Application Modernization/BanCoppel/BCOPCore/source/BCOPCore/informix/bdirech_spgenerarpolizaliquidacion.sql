CREATE PROCEDURE "informix".spgenerarpolizaliquidacion (p_dFechaActual DATE, p_sNumEmpleado CHAR(8), p_sUsuario CHAR(8)) 
	RETURNING CHAR(5) AS CodigoRetorno, INTEGER AS numeroPoliza;
	
	DEFINE iSqlErr          					INTEGER;
	DEFINE v_sCodRet        					CHAR(5);
	DEFINE v_sSistema							CHAR(2);
	DEFINE v_sCentroCostosOri					CHAR(4);
	DEFINE v_sCentroCostosRH					CHAR(4);
	DEFINE v_sTransaccionLiquidacionxFaltante	CHAR(4);
	DEFINE v_sTransaccionLiquidacionxDanios		CHAR(4);
	DEFINE v_sTransaccionRecuperacionxFaltante	CHAR(4);
	DEFINE v_sTransaccionRecuperacionxDanios	CHAR(4);
	DEFINE v_sTransaccion						CHAR(4);
	DEFINE v_sTransaccionAnt					CHAR(4);
	DEFINE v_idasignado							SMALLINT;	
	DEFINE v_mTotalCargosLiqFaltantes			MONEY(10,0);
	DEFINE v_mTotalCargosLiqDanios				MONEY(10,0);
	DEFINE v_mTotalCargosRecFaltantes			MONEY(10,0);
	DEFINE v_mTotalCargosRecDanios				MONEY(10,0);
	DEFINE v_mSumaMovimientos					MONEY(10,0);
	DEFINE v_sAuxiliar							CHAR(12);
	DEFINE v_sAuxiliarBanco						CHAR(12);
	DEFINE v_sSucursal							CHAR(4);	
	DEFINE v_sEmpresa							CHAR(3);	
	DEFINE v_iControlPoliza						INTEGER;
	DEFINE v_sDescripcionParametro				CHAR(60);	
	DEFINE v_sFechaActual						CHAR(10);
	DEFINE v_iSecuencia							INTEGER;
	
	
	--CUENTAS CONTABLES
	--Cargo
	DEFINE v_sC_ccmayor							CHAR(4);
	DEFINE v_sC_ccsub							CHAR(2);
	DEFINE v_sC_ccsubsub						CHAR(2);
	DEFINE v_sC_ccsssub							CHAR(2);
	DEFINE v_sC_ccssssub						CHAR(2);
	DEFINE v_sC_sector							CHAR(2);
	--Abono
	DEFINE v_sA_ccmayor							CHAR(4);
	DEFINE v_sA_ccsub							CHAR(2);
	DEFINE v_sA_ccsubsub						CHAR(2);
	DEFINE v_sA_ccsssub							CHAR(2);
	DEFINE v_sA_ccssssub						CHAR(2);
	DEFINE v_sA_sector							CHAR(2);
	
	--RETORNOS INSERTAPOLIZA	
	DEFINE v_iSecuenciaTmp						INTEGER;
	DEFINE v_iNumRegistrosTmp					INTEGER;
	DEFINE v_iControlPolizaTmp					INTEGER;
	
	--SET DEBUG FILE TO  "spgenerarpolizaliquidacion.out"; 
	--TRACE ON;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				INSERT INTO bdirech:rec_errores(descripcion) VALUES ('sgpl'|| iSqlErr);
				RETURN v_sCodRet, 0;
			END IF;
		END EXCEPTION;
		
		--// VALIDA PARÁMETROS DE ENTRADA
		IF NVL(p_dFechaActual, '') = '' OR  NVL(p_sNumEmpleado, '') = '' OR  NVL(p_sUsuario, '') = '' THEN
			LET v_sCodRet = '00001';
			RETURN v_sCodRet, 0;
		END IF;
		
		LET v_iSecuencia = 0;
		LET v_sEmpresa = '001';
		LET v_iControlPoliza = 0;
		LET v_sTransaccionAnt = '';
		
		LET v_mTotalCargosLiqDanios = 0;
		LET v_mTotalCargosLiqFaltantes = 0;
		LET v_mTotalCargosRecDanios = 0;
		LET v_mTotalCargosRecFaltantes = 0;
		LET v_sCentroCostosOri = '';
		LET v_sAuxiliarBanco = '900100000014';
		
		-- CAMBIA EL FORMATO DE LA FECHA A MMDDAAAA PARA QUE SE PUEDA INSERTAR EN LA POLIZA
		LET v_sFechaActual = LPAD(MONTH(p_dFechaActual),2,'0')||LPAD(DAY(p_dFechaActual),2,'0')||YEAR(p_dFechaActual);
		
		--SE OBTIENE EL NÚMERO DE SISTEMA DE ADMINISTRACION DE FALTANTES            		
		EXECUTE PROCEDURE bdirech:spconsultarparam(3) INTO v_sCodRet, v_sDescripcionParametro, v_sSistema;		
				
		--SE OBTIENE EL CENTRO DE COSTOS  DE RECURSOS HUMANOS		
		EXECUTE PROCEDURE bdirech:spconsultarparam(2) INTO v_sCodRet, v_sDescripcionParametro, v_sCentroCostosRH;
				
		--SE OBTIENE EL NUMERO DE TRANSACCION PARA LIQUIDACION DE FALTANTES			
		SELECT numero INTO v_sTransaccionLiquidacionxFaltante FROM bdinteg:si_transacc WHERE sistema = v_sSistema AND abreviatura = 'LIQFAL'; 
		
		--SE OBTIENE EL NUMERO DE TRANSACCION PARA LIQUIDACION POR DAÑOS
		SELECT numero INTO v_sTransaccionLiquidacionxDanios FROM bdinteg:si_transacc WHERE sistema = v_sSistema AND abreviatura = 'LIQDAÑO'; 
		
		--SE OBTIENE EL NUMERO DE TRANSACCION PARA RECUPERACION DE FALTANTES
		SELECT numero INTO v_sTransaccionRecuperacionxFaltante FROM bdinteg:si_transacc WHERE sistema = v_sSistema AND abreviatura = 'RECUFAL'; 
		
		--SE OBTIENE EL NUMERO DE TRANSACCION PARA RECUPERACION DE DAÑOS
		SELECT numero INTO v_sTransaccionRecuperacionxDanios FROM bdinteg:si_transacc WHERE sistema = v_sSistema AND abreviatura = 'RECUDAÑO';				
				
		--PARA CADA AUXILIAR DE LA TRANSACCION, SE GENERA UN ABONO
		FOREACH
		SELECT SUM(b.montomovimiento), b.auxiliar, b.numsucursal, b.transaccion , a.idasignado
		  INTO v_mSumaMovimientos, v_sAuxiliar, v_sSucursal, v_sTransaccion, v_idasignado 
		  FROM bdirech:rec_confaltante a, bdirech:rec_movfaltante b
		WHERE a.referencia=b.referencia
		  AND b.transaccion IN (v_sTransaccionLiquidacionxFaltante, v_sTransaccionLiquidacionxDanios, v_sTransaccionRecuperacionxFaltante,
							    v_sTransaccionRecuperacionxDanios) 
		  AND b.idmovimiento <> 0 
		  AND b.idrecupera = 3 
		  AND b.tipomovimiento = 'A'
		  AND b.fecharegistro = p_dFechaActual 
		  AND b.numempleado = p_sNumEmpleado 
		  AND b.contable = '0'
		GROUP BY 2, 3, 4, 5 ORDER BY 4		

			IF v_sC_ccmayor = '' OR v_sTransaccionAnt <> v_sTransaccion THEN
			
				IF v_sTransaccion NOT IN (v_sTransaccionRecuperacionxFaltante, v_sTransaccionLiquidacionxFaltante) THEN
					LET v_idasignado = '1'; -- VALOR POR DEFAULT
				END IF
				--SE OBTIENEN LAS CUENTAS CONTABLES DE LA TRANSACCION
				EXECUTE PROCEDURE bdinteg:spobtenercuentascontables (v_sEmpresa, v_sTransaccion, v_sSistema, v_idasignado) 		
				INTO v_sCodRet, v_sC_ccmayor, v_sC_ccsub, v_sC_ccsubsub, v_sC_ccsssub, v_sC_ccssssub, v_sC_sector, 
				v_sA_ccmayor, v_sA_ccsub, v_sA_ccsubsub, v_sA_ccsssub, v_sA_ccssssub, v_sA_sector;
				
			END IF
			
			IF  v_idasignado= 3 AND v_sTransaccion IN (v_sTransaccionRecuperacionxFaltante,v_sTransaccionLiquidacionxFaltante) THEN
				LET v_sAuxiliar = '';
				LET v_sCentroCostosRH = '9251';
				LET v_sCentroCostosOri = v_sSucursal;
			ELSE
				LET v_sCentroCostosOri = v_sCentroCostosRH;
			END IF
				
			LET v_iSecuencia = v_iSecuencia + 1;			

			--INSERTAR POLIZA PARA LOS ABONOS DE LIQUIDACION POR DAÑOS
			EXECUTE PROCEDURE bdicont:insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0',
			v_iSecuencia::CHAR(4), v_sA_ccmayor, v_sA_ccsub, v_sA_ccsubsub, v_sA_ccsssub, v_sA_ccssssub, v_sA_sector,
			v_sAuxiliar, v_sCentroCostosOri, v_sCentroCostosRH, 'C', v_mSumaMovimientos::CHAR(20), 'ABONO POR LIQUIDACION DE FALTANTES', '0') INTO v_sCodRet,
			v_iControlPolizaTmp, v_iSecuenciaTmp, v_iNumRegistrosTmp;   ---v_sSucursal, v_sSucursal,
								
			IF v_sTransaccion = v_sTransaccionLiquidacionxDanios THEN
				--SE ACUMULA EL TOTOAL DE CARGOS DE LIDACION POR DAÑOS
				LET v_mTotalCargosLiqDanios = v_mTotalCargosLiqDanios + v_mSumaMovimientos;				
			ELIF v_sTransaccion = v_sTransaccionLiquidacionxFaltante THEN								
				--SE ACUMULA EL TOTAL DE CARGOS DE LIQUIDACION POR FALTANTES
				LET v_mTotalCargosLiqFaltantes = v_mTotalCargosLiqFaltantes + v_mSumaMovimientos;				
			ELIF v_sTransaccion = v_sTransaccionRecuperacionxDanios THEN				
				--SE ACUMULA EL TOTAL DE CARGOS DE RECUPERACION POR DAÑOS
				LET v_mTotalCargosRecDanios = v_mTotalCargosRecDanios + v_mSumaMovimientos;				
			ELIF v_sTransaccion = v_sTransaccionRecuperacionxFaltante THEN 
				--SE ACUMULA EL TOTAL DE CARGOS DE RECUPERACION POR FALTANTES
				LET v_mTotalCargosRecFaltantes = v_mTotalCargosRecFaltantes + v_mSumaMovimientos;				
			END IF;
			LET v_sTransaccionAnt = v_sTransaccion;
		END FOREACH;			
		
		IF v_iSecuencia > 0 THEN		
			
			IF v_mTotalCargosLiqDanios > 0 THEN
				--SE OBTIENEN LAS CUENTAS CONTABLES DE LA TRANSACCION
				EXECUTE PROCEDURE bdinteg:spobtenercuentascontables (v_sEmpresa, v_sTransaccionLiquidacionxDanios, v_sSistema, '1') 		
				INTO v_sCodRet, v_sC_ccmayor, v_sC_ccsub, v_sC_ccsubsub, v_sC_ccsssub, v_sC_ccssssub, v_sC_sector, 
				v_sA_ccmayor, v_sA_ccsub, v_sA_ccsubsub, v_sA_ccsssub, v_sA_ccssssub, v_sA_sector;
				
				LET v_iSecuencia = v_iSecuencia + 1;
				--INSERTAR POLIZA PARA LOS CARGOS  DE LIQUIDACION POR DAÑOS
				EXECUTE PROCEDURE bdicont:insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0', 
				v_iSecuencia::CHAR(4), v_sC_ccmayor, v_sC_ccsub, v_sC_ccsubsub, v_sC_ccsssub, v_sC_ccssssub, v_sC_sector, v_sAuxiliar,
				v_sCentroCostosOri, v_sCentroCostosRH, 'D', v_mTotalCargosLiqDanios::CHAR(20), 'CARGO POR LIQUIDACION POR DAÑOS', '0') 
				INTO v_sCodRet, v_iControlPolizaTmp, v_iSecuenciaTmp, v_iNumRegistrosTmp;
			END IF
			
			IF v_mTotalCargosLiqFaltantes > 0 THEN
				--SE OBTIENEN LAS CUENTAS CONTABLES DE LA TRANSACCION
				EXECUTE PROCEDURE bdinteg:spobtenercuentascontables (v_sEmpresa, v_sTransaccionLiquidacionxFaltante, v_sSistema, v_idasignado) 		
				INTO v_sCodRet, v_sC_ccmayor, v_sC_ccsub, v_sC_ccsubsub, v_sC_ccsssub, v_sC_ccssssub, v_sC_sector, 
				v_sA_ccmayor, v_sA_ccsub, v_sA_ccsubsub, v_sA_ccsssub, v_sA_ccssssub, v_sA_sector;
				
				IF v_idasignado = 2 THEN -- AUXILIAR DE BANCOS POR RECUPERACION RH
					LET v_sAuxiliar = v_sAuxiliarBanco;
				END IF
				
				LET v_iSecuencia = v_iSecuencia + 1;
				--INSERTAR POLIZA PARA LOS CARGOS DE LIQUIDACION POR FALTANTES
				EXECUTE PROCEDURE bdicont:insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0', 
				v_iSecuencia::CHAR(4),  v_sC_ccmayor, v_sC_ccsub, v_sC_ccsubsub, v_sC_ccsssub, v_sC_ccssssub, v_sC_sector, v_sAuxiliar,
				v_sCentroCostosOri, v_sCentroCostosRH, 'D', v_mTotalCargosLiqFaltantes::CHAR(20), 'CARGO POR LIQUIDACION DE FALTANTES', '0') 
				INTO v_sCodRet, v_iControlPolizaTmp, v_iSecuenciaTmp, v_iNumRegistrosTmp;
			END IF
			
			IF v_mTotalCargosRecDanios > 0 THEN
				--SE OBTIENEN LAS CUENTAS CONTABLES DE LA TRANSACCION
				EXECUTE PROCEDURE bdinteg:spobtenercuentascontables (v_sEmpresa, v_sTransaccionRecuperacionxDanios, v_sSistema, '1') 		
				INTO v_sCodRet, v_sC_ccmayor, v_sC_ccsub, v_sC_ccsubsub, v_sC_ccsssub, v_sC_ccssssub, v_sC_sector, 
				v_sA_ccmayor, v_sA_ccsub, v_sA_ccsubsub, v_sA_ccsssub, v_sA_ccssssub, v_sA_sector;
				
				LET v_iSecuencia = v_iSecuencia + 1;
				--INSERTAR POLIZA PARA LOS CARGOS DE RECUPERACION POR DAÑOS
				EXECUTE PROCEDURE bdicont:insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0', 
				v_iSecuencia::CHAR(4), v_sC_ccmayor, v_sC_ccsub, v_sC_ccsubsub, v_sC_ccsssub, v_sC_ccssssub, v_sC_sector, v_sAuxiliar,
				v_sCentroCostosOri, v_sCentroCostosRH, 'D', v_mTotalCargosRecDanios::CHAR(20), 'CARGO POR LIQUIDACION POR DAÑOS', '0') 
				INTO v_sCodRet, v_iControlPolizaTmp, v_iSecuenciaTmp, v_iNumRegistrosTmp;
			END IF
			
			IF v_mTotalCargosRecFaltantes > 0 THEN
				--SE OBTIENEN LAS CUENTAS CONTABLES DE LA TRANSACCION
				EXECUTE PROCEDURE bdinteg:spobtenercuentascontables (v_sEmpresa, v_sTransaccionRecuperacionxFaltante, v_sSistema, v_idasignado) 		
				INTO v_sCodRet, v_sC_ccmayor, v_sC_ccsub, v_sC_ccsubsub, v_sC_ccsssub, v_sC_ccssssub, v_sC_sector, 
				v_sA_ccmayor, v_sA_ccsub, v_sA_ccsubsub, v_sA_ccsssub, v_sA_ccssssub, v_sA_sector;
			
				IF v_idasignado = 2 THEN -- AUXILIAR DE BANCOS POR RECUPERACION RH
					LET v_sAuxiliar = v_sAuxiliarBanco;
				END IF

				LET v_iSecuencia = v_iSecuencia + 1;
				--INSERTAR POLIZA PARA LOS CARGOS DE RECUPERACION POR FALTANTES
				EXECUTE PROCEDURE bdicont:insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0', 
				v_iSecuencia::CHAR(4), v_sC_ccmayor, v_sC_ccsub, v_sC_ccsubsub, v_sC_ccsssub, v_sC_ccssssub, v_sC_sector,v_sAuxiliar,
				v_sCentroCostosOri, v_sCentroCostosRH, 'D', v_mTotalCargosRecFaltantes::CHAR(20), 'CARGO POR LIQUIDACION DE FALTANTES', '0') 
				INTO v_sCodRet, v_iControlPolizaTmp, v_iSecuenciaTmp, v_iNumRegistrosTmp;
			END IF
			
			IF NOT EXISTS (SELECT 1 FROM bdicont:co_errorpoliza) THEN
				EXECUTE PROCEDURE bdicont:validapolizanomina(v_sEmpresa, p_sUsuario) INTO v_sCodRet, v_iControlPoliza;
			
				--VALIDA QUE NO EXISTAN ERRORES EN LA GENERACION DE LA POLIZA
				IF TRIM(v_sCodRet) = '000' AND v_iControlPoliza <> 0
				AND NOT EXISTS(SELECT 1 FROM bdicont:tmpco_auditerr WHERE usuario = p_sUsuario) THEN
			
					--ACTUALIZA LOS MOVIMIENTOS DE FALTANTE COMO CONTABLES
					UPDATE bdirech:rec_movfaltante SET contable = '1'				
					WHERE transaccion IN (v_sTransaccionLiquidacionxFaltante, v_sTransaccionLiquidacionxDanios, 
					v_sTransaccionRecuperacionxFaltante, v_sTransaccionRecuperacionxDanios) AND idmovimiento <> 0 AND idrecupera = 3 
					AND tipomovimiento = 'A' AND fecharegistro = p_dFechaActual AND numempleado = p_sNumEmpleado AND contable = '0';				
				ELSE
					LET v_sCodRet = '00003';
					DELETE FROM bdicont:tmpco_detpol WHERE usuario = p_sUsuario;
				END IF;
			ELSE
				LET v_sCodRet = '00003';
				DELETE FROM bdicont:tmpco_detpol WHERE usuario = p_sUsuario;
			END IF
		ELSE
			LET v_sCodRet = '00004';
		END IF;
	
	RETURN v_sCodRet, v_iControlPoliza;
	END
END PROCEDURE
