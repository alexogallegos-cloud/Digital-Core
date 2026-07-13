CREATE PROCEDURE "informix".spgenerarpolizaquebranto (p_dFechaActual DATE, p_sNumEmpleado CHAR(8), p_sUsuario CHAR(8)) 
	RETURNING CHAR(5) AS CodigoRetorno, INTEGER AS numeroPoliza;
	
	DEFINE iSqlErr          				INTEGER;
	DEFINE v_sCodRet        				CHAR(5);
	DEFINE v_sSistema						CHAR(2);
	DEFINE v_sTransaccionQuebrantoxFaltante	CHAR(4);
	DEFINE v_sTransaccionQuebrantoxDanios	CHAR(4);
	DEFINE v_sTransaccion					CHAR(4);
	DEFINE v_mSumaMovimientos				MONEY(10,0);
	DEFINE v_sAuxiliar						CHAR(12);
	DEFINE v_sSucursal						CHAR(4);	
	DEFINE v_sEmpresa						CHAR(3);	
	DEFINE v_iControlPoliza					INTEGER;
	DEFINE v_sDescripcionParametro			CHAR(60);	
	DEFINE v_sFechaActual					CHAR(8);
	DEFINE v_iSecuencia						INTEGER;
	--CUENTAS CONTABLES QUEBRANTO POR FALTANTES	
	DEFINE v_sCqf_ccmayor					CHAR(4);
	DEFINE v_sCqf_ccsub						CHAR(2);
	DEFINE v_sCqf_ccsubsub					CHAR(2);
	DEFINE v_sCqf_ccsssub					CHAR(2);
	DEFINE v_sCqf_ccssssub					CHAR(2);
	DEFINE v_sCqf_sector					CHAR(2);
	DEFINE v_sAqf_ccmayor					CHAR(4);
	DEFINE v_sAqf_ccsub						CHAR(2);
	DEFINE v_sAqf_ccsubsub					CHAR(2);
	DEFINE v_sAqf_ccsssub					CHAR(2);
	DEFINE v_sAqf_ccssssub					CHAR(2);
	DEFINE v_sAqf_sector					CHAR(2);
	--CUENTAS CONTABLES QUEBRANTO POR DAÑOS	
	DEFINE v_sCqd_ccmayor					CHAR(4);
	DEFINE v_sCqd_ccsub						CHAR(2);
	DEFINE v_sCqd_ccsubsub					CHAR(2);
	DEFINE v_sCqd_ccsssub					CHAR(2);
	DEFINE v_sCqd_ccssssub					CHAR(2);
	DEFINE v_sCqd_sector					CHAR(2);
	DEFINE v_sAqd_ccmayor					CHAR(4);
	DEFINE v_sAqd_ccsub						CHAR(2);
	DEFINE v_sAqd_ccsubsub					CHAR(2);
	DEFINE v_sAqd_ccsssub					CHAR(2);
	DEFINE v_sAqd_ccssssub					CHAR(2);
	DEFINE v_sAqd_sector					CHAR(2);
	--RETORNOS INSERTAPOLIZA	
	DEFINE v_iSecuenciaP					INTEGER;
	DEFINE v_iNumRegistros					INTEGER;
	DEFINE v_iControlPolizaTemp				INTEGER;
	
	--SET DEBUG FILE TO  "/tmp/vladi/spgenerarpolizaquebranto.out"; 
	--TRACE ON;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				INSERT INTO bdirech:rec_errores(descripcion) VALUES ('sgpq'||iSqlErr);
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
		
		--CAMBIA EL FORMATO DE LA FECHA A MMDDAAAA PARA QUE SE PUEDA INSERTAR EN LA POLIZA		
		LET v_sFechaActual = LPAD(MONTH(p_dFechaActual),2,'0') || LPAD(DAY(p_dFechaActual),2,'0') || YEAR(p_dFechaActual);
		
		--SE OBTIENE NÚMERO DE SISTEMA DE ADMINISTRACION DE FALTANTES            		
		EXECUTE PROCEDURE bdirech:spconsultarparam(3) INTO v_sCodRet, v_sDescripcionParametro, v_sSistema;
		
		--SE OBTIENE EL NUMERO DE TRANSACCION PARA QUEBRANTO POR FALTANTES			
		SELECT numero INTO v_sTransaccionQuebrantoxFaltante FROM bdinteg:si_transacc WHERE sistema = v_sSistema AND abreviatura = 'QTOFAL';	
				
		--SE OBTIENEN LAS CUENTAS CONTABLES DE LA TRANSACCION DE QUEBRANTO POR FALTANTES		
		EXECUTE PROCEDURE bdinteg:spobtenercuentascontables (v_sEmpresa, v_sTransaccionQuebrantoxFaltante, v_sSistema, '1') 				
		INTO v_sCodRet, v_sCqf_ccmayor, v_sCqf_ccsub, v_sCqf_ccsubsub, v_sCqf_ccsssub, v_sCqf_ccssssub, v_sCqf_sector,
		v_sAqf_ccmayor, v_sAqf_ccsub, v_sAqf_ccsubsub, v_sAqf_ccsssub, v_sAqf_ccssssub, v_sAqf_sector;
		
		--SE OBTIENE EL NUMERO DE TRANSACCION PARA QUEBRANTO POR DAÑOS
		SELECT numero INTO v_sTransaccionQuebrantoxDanios FROM bdinteg:si_transacc WHERE sistema = v_sSistema AND abreviatura = 'QTODAÑO';
				
		--SE OBTIENEN LAS CUENTAS CONTABLES DE LA TRANSACCION DE QUEBRANTO POR DAÑOS		
		EXECUTE PROCEDURE bdinteg:spobtenercuentascontables (v_sEmpresa, v_sTransaccionQuebrantoxDanios, v_sSistema, '1') 		
		INTO v_sCodRet, v_sCqd_ccmayor, v_sCqd_ccsub, v_sCqd_ccsubsub, v_sCqd_ccsssub, v_sCqd_ccssssub, v_sCqd_sector, 
		v_sAqd_ccmayor, v_sAqd_ccsub, v_sAqd_ccsubsub, v_sAqd_ccsssub, v_sAqd_ccssssub, v_sAqd_sector;
				
		IF v_sCodRet = '00000' THEN
			--PARA  CADA AUXILIAR DE LA TRANSACCION, SE GENERA UNA POLIZA
			FOREACH
			SELECT NVL(SUM(montomovimiento),0), auxiliar, numsucursal, transaccion 
			INTO v_mSumaMovimientos, v_sAuxiliar, v_sSucursal, v_sTransaccion
			FROM bdirech:rec_movfaltante
			WHERE transaccion IN (v_sTransaccionQuebrantoxFaltante, v_sTransaccionQuebrantoxDanios)  AND idmovimiento <> 0 
			AND tipomovimiento = 'A' AND fecharegistro = p_dFechaActual AND numempleado = p_sNumEmpleado AND contable = '0'
			GROUP BY auxiliar, numsucursal, transaccion
				
				LET v_iSecuencia = v_iSecuencia + 1;
				
				IF v_sTransaccion = v_sTransaccionQuebrantoxDanios THEN
				
					--INSERTAR POLIZA PARA LOS ABONOS DE QUEBRANTO POR DAÑOS
					EXECUTE PROCEDURE bdicont:insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0', 
					v_iSecuencia::CHAR(4), v_sAqd_ccmayor, v_sAqd_ccsub, v_sAqd_ccsubsub, v_sAqd_ccsssub, v_sAqd_ccssssub, v_sAqd_sector,
					v_sAuxiliar, v_sSucursal, v_sSucursal, 'C', v_mSumaMovimientos::CHAR(20), 'POLIZA ABONO QUEBRANTO DAÑOS', '0') 
					INTO v_sCodRet, v_iControlPolizaTemp, v_iSecuenciaP, v_iNumRegistros;
					
					LET v_iSecuencia = v_iSecuencia + 1;
					
					--INSERTAR POLIZA PARA LOS CARGOS  DE QUEBRANTO POR DAÑOS
					EXECUTE PROCEDURE bdicont:insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0',
					v_iSecuencia::CHAR(4), v_sCqd_ccmayor, v_sCqd_ccsub, v_sCqd_ccsubsub, v_sCqd_ccsssub, v_sCqd_ccssssub, v_sCqd_sector,
					v_sAuxiliar, v_sSucursal, v_sSucursal, 'D', v_mSumaMovimientos::CHAR(20), 'POLIZA CARGO QUEBRANTO DAÑOS', '0') 
					INTO v_sCodRet, v_iControlPolizaTemp, v_iSecuenciaP, v_iNumRegistros;
				ELSE
					
					--INSERTAR POLIZA PARA LOS ABONOS DE QUEBRANTO POR FALTANTES
					EXECUTE PROCEDURE bdicont:insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0',
					v_iSecuencia::CHAR(4), v_sAqf_ccmayor, v_sAqf_ccsub, v_sAqf_ccsubsub, v_sAqf_ccsssub, v_sAqf_ccssssub, v_sAqf_sector,
					v_sAuxiliar, v_sSucursal, v_sSucursal, 'C', v_mSumaMovimientos::CHAR(20), 'POLIZA ABONO QUEBRANTO FALTANTE', '0') 
					INTO v_sCodRet, v_iControlPolizaTemp, v_iSecuenciaP, v_iNumRegistros;
						
					LET v_iSecuencia = v_iSecuencia + 1;
					
					--INSERTAR POLIZA PARA LOS CARGOS DE QUEBRANTO POR FALTANTES
					EXECUTE PROCEDURE bdicont:insertapoliza (v_sEmpresa, p_sUsuario, '01', '1', v_sFechaActual, v_sFechaActual, '0', '0',
					v_iSecuencia::CHAR(4), v_sCqf_ccmayor, v_sCqf_ccsub, v_sCqf_ccsubsub, v_sCqf_ccsssub, v_sCqf_ccssssub, v_sCqf_sector,
					v_sAuxiliar, v_sSucursal, v_sSucursal, 'D', v_mSumaMovimientos::CHAR(20), 'POLIZA CARGO QUEBRANTO FALTANTE', '0') 
					INTO v_sCodRet, v_iControlPolizaTemp, v_iSecuenciaP, v_iNumRegistros;
				END IF;
			END FOREACH;
			
			IF v_iSecuencia > 0 THEN
				IF NOT EXISTS (SELECT 1 FROM bdicont:co_errorpoliza) THEN
					EXECUTE PROCEDURE bdicont:validapolizanomina(v_sEmpresa, p_sUsuario) INTO v_sCodRet, v_iControlPoliza;
					
					--VALIDA QUE NO EXISTAN ERRORES EN LA GENERACION DE LA POLIZA
					IF TRIM(v_sCodRet) = '000' AND v_iControlPoliza <> 0 AND NOT EXISTS(SELECT 1 FROM bdicont:tmpco_auditerr WHERE usuario = p_sUsuario) THEN
						--ACTUALIZA LOS MOVIMIENTOS DE FALTANTE COMO CONTABLES
						UPDATE bdirech:rec_movfaltante
						SET    contable = '1'
						WHERE transaccion IN (v_sTransaccionQuebrantoxFaltante, v_sTransaccionQuebrantoxDanios) 
						AND idmovimiento <> 0 AND tipomovimiento = 'A'
						AND fecharegistro = p_dFechaActual AND numempleado = p_sNumEmpleado AND contable = '0';
						
						LET v_sCodRet = '00000';						
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
			END IF
		ELSE
			LET v_sCodRet = '00002';
		END IF;
		RETURN v_sCodRet, v_iControlPoliza;
	END
END PROCEDURE
