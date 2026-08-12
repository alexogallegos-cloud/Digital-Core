CREATE PROCEDURE "informix".spgenerarpolizanomina (p_dFechaSistema DATE, p_dFechaQuincena DATE, p_sUsuarioSistema CHAR(8))
    RETURNING CHAR(5) AS CodigoRetorno, INTEGER AS NumeroPoliza
    
    DEFINE iSqlErr                              INTEGER;

    DEFINE v_sCodRet                            CHAR(5);
    DEFINE v_sEstatus                           CHAR(2);
    DEFINE v_iErrores                           INTEGER;
    DEFINE v_sDescripcionParam                  CHAR(60);
    DEFINE v_sValorParam                        CHAR(20);
    DEFINE v_sCCRecHumanos                      CHAR(20);
    DEFINE v_sCCNumSistema                      CHAR(20);
    DEFINE v_sTranLiqFaltante                   CHAR(4);
    DEFINE v_sTranLiqDano                       CHAR(4);
    DEFINE v_sTranRecuperaFaltante              CHAR(4);
    DEFINE v_sTranRecuperaDano                  CHAR(4);
    
	DEFINE v_sc_ccMayor                         CHAR(4);
    DEFINE v_sc_ccSub                           CHAR(2);
    DEFINE v_sc_ccSubSub                        CHAR(2);
    DEFINE v_sc_ccssSub                         CHAR(2);
    DEFINE v_sc_ccsssSub                        CHAR(2);
    DEFINE v_sc_Sector                          CHAR(2);
    
	DEFINE v_sa_ccMayor                         CHAR(4);
    DEFINE v_sa_ccSub                           CHAR(2);
    DEFINE v_sa_ccSubSub                        CHAR(2);
    DEFINE v_sa_ccssSub                         CHAR(2);
    DEFINE v_sa_ccsssSub                        CHAR(2);
    DEFINE v_sa_Sector                          CHAR(2);
    
	DEFINE v_iSecuenciaPoliza                   INTEGER;
    DEFINE v_sMontoTotal                        MONEY(10,0);
    DEFINE v_sMontoTotalC                       MONEY(10,0);
    DEFINE v_sTransaccion                       CHAR(4);
    DEFINE v_sTransaccionAnt                    CHAR(4);
    DEFINE v_sAuxiliar                          CHAR(12);
	DEFINE v_sAuxiliarBanco						CHAR(12);
    DEFINE v_sNumSucursal                       CHAR(4);
	DEFINE v_sEmpresa							CHAR(3);
    DEFINE v_sFechaSistema                      CHAR(10);	
	DEFINE v_iCtrlPoliza                        INTEGER;
    
	DEFINE v_iCtrlPolizaTmp                     INTEGER;
	DEFINE v_iSecuenciaTmp                      INTEGER;
    DEFINE v_iNumRegistrosTmp                   INTEGER;    
    
	
    --SET DEBUG FILE TO "spGenerarPolizaNomina.out"; 
    --TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET v_sCodRet = iSqlErr;
			INSERT INTO bdirech:"informix".rec_errores(descripcion) VALUES ('sgpn '|| iSqlErr);
			RETURN v_sCodRet, 0;
		END IF;
	END EXCEPTION;

	--// Valida parámetros de entrada
	IF NVL(p_dFechaSistema, '') = '' OR NVL(p_dFechaQuincena, '') = '' OR NVL(p_sUsuarioSistema, '') = '' THEN
		LET v_sCodRet = '00001';
		RETURN v_sCodRet,'';
	END IF

	LET v_iCtrlPoliza = 0;	
	LET v_sEmpresa = '001';
	
	
	
	--Proceso de Actualización de Saldos.
	EXECUTE PROCEDURE bdirech:"informix".spvalidarprocesos (p_dFechaQuincena,'5') INTO v_sCodRet, v_sEstatus, v_iErrores;

	--Que se haya ejecutado el proceso de actualización de saldos y que no existan errores
	IF v_sEstatus = '1' AND v_iErrores = 0 THEN
		--Proceso de Generacion de la Nomina.
		EXECUTE PROCEDURE bdirech:"informix".spvalidarprocesos (p_dFechaQuincena,'6') INTO v_sCodRet, v_sEstatus, v_iErrores;

		--Que no se haya ejecuta el proceso de generación de la poliza
		IF v_sEstatus = '0' THEN
			--Se obtiene el C.C de Recursos Humanos                
			EXECUTE PROCEDURE bdirech:"informix".spconsultarparam(2) INTO v_sCodRet, v_sDescripcionParam, v_sCCRecHumanos;
			--Se obtiene el Numero de Sistema Asignado                
			EXECUTE PROCEDURE bdirech:"informix".spconsultarparam(3) INTO v_sCodRet, v_sDescripcionParam, v_sCCNumSistema;
									
			--SE OBTIENE EL NUMERO DE TRANSACCION Y LA DESCRIPCION PARA LIQUIDACION DE FALTANTES			
			SELECT numero INTO v_sTranLiqFaltante FROM bdinteg:"informix".si_transacc WHERE sistema = v_sCCNumSistema AND abreviatura = 'LIQFAL'; 
			
			--SE OBTIENE EL NUMERO DE TRANSACCION Y LA DESCRIPCION PARA LIQUIDACION POR DAÑOS
			SELECT numero INTO v_sTranLiqDano FROM bdinteg:"informix".si_transacc WHERE sistema = v_sCCNumSistema AND abreviatura = 'LIQDAÑO'; 
			
			--SE OBTIENE EL NUMERO DE TRANSACCION Y LA DESCRIPCION PARA RECUPERACION DE FALTANTES
			SELECT numero INTO v_sTranRecuperaFaltante FROM bdinteg:"informix".si_transacc WHERE sistema = v_sCCNumSistema AND abreviatura = 'RECUFAL'; 
			
			--SE OBTIENE EL NUMERO DE TRANSACCION Y LA DESCRIPCION PARA RECUPERACION DE DAÑOS
			SELECT numero INTO v_sTranRecuperaDano FROM bdinteg:"informix".si_transacc WHERE sistema = v_sCCNumSistema AND abreviatura = 'RECUDAÑO'; 			
			
			LET v_iSecuenciaPoliza = 0;
			LET v_sMontoTotalC = 0;
			LET v_sTransaccionAnt = '';
			LET v_sFechaSistema = LPAD(MONTH(p_dFechaSistema),2,"0") || LPAD(DAY(p_dFechaSistema),2,"0") || YEAR(p_dFechaSistema);
			LET v_sc_ccMayor = '';
			LET v_sAuxiliarBanco = '900100000065';

			--Recorre los datos para generar las poliza
			FOREACH
			SELECT mov.transaccion, mov.auxiliar, mov.numsucursal, SUM(mov.montomovimiento)
			INTO v_sTransaccion, v_sAuxiliar, v_sNumSucursal, v_sMontoTotal
			FROM bdirech:"informix".rec_movfaltante mov, bdirech:"informix".rec_descquincena des WHERE mov.numempleado = des.numempleado
			AND mov.transaccion IN (v_sTranLiqFaltante, v_sTranLiqDano, v_sTranRecuperaFaltante, v_sTranRecuperaDano)
			AND mov.idmovimiento <> 0 AND mov.idrecupera = 2 AND mov.tipomovimiento = 'A'
			AND mov.fecharegistro = p_dFechaQuincena AND mov.contable = '0'
			GROUP BY 1, 2, 3 ORDER BY 1						
			
				IF v_sc_ccMayor = '' OR v_sTransaccionAnt <> v_sTransaccion THEN
					EXECUTE PROCEDURE bdinteg:"informix".spobtenercuentascontables(v_sEmpresa, v_sTransaccion, v_sCCNumSistema, '2')
					INTO v_sCodRet, v_sc_ccMayor, v_sc_ccSub, v_sc_ccSubSub,v_sc_ccssSub,v_sc_ccsssSub, v_sc_Sector,
					v_sa_ccMayor, v_sa_ccSub,v_sa_ccSubSub, v_sa_ccssSub, v_sa_ccsssSub, v_sa_Sector;
				END IF
				
				LET v_iSecuenciaPoliza = v_iSecuenciaPoliza + 1;					
				--Inserta el abono de la poliza
				EXECUTE PROCEDURE bdicont:"informix".insertapoliza(v_sEmpresa, p_sUsuarioSistema, '01', '1', v_sFechaSistema, v_sFechaSistema,
				'0','0', v_iSecuenciaPoliza::CHAR(4), v_sa_ccMayor, v_sa_ccSub, v_sa_ccSubSub, v_sa_ccssSub, v_sa_ccsssSub, v_sa_Sector,
				v_sAuxiliar, v_sCCRecHumanos, v_sCCRecHumanos, 'C', v_sMontoTotal::CHAR(20), 'MOVIMIENTO DE ABONO DE FALTANTES POR NOMINA', '0') 
				INTO v_sCodRet, v_iCtrlPolizaTmp, v_iSecuenciaTmp, v_iNumRegistrosTmp;				   --v_sNumSucursal, v_sNumSucursal,
									
				IF v_sTransaccionAnt <> v_sTransaccion AND v_sTransaccionAnt <> '' THEN									
					EXECUTE PROCEDURE bdinteg:"informix".spobtenercuentascontables(v_sEmpresa, v_sTransaccionAnt, v_sCCNumSistema, '2')
					INTO v_sCodRet, v_sc_ccMayor, v_sc_ccSub, v_sc_ccSubSub,v_sc_ccssSub,v_sc_ccsssSub, v_sc_Sector,
					v_sa_ccMayor, v_sa_ccSub,v_sa_ccSubSub, v_sa_ccssSub, v_sa_ccsssSub, v_sa_Sector;
					
					LET v_iSecuenciaPoliza = v_iSecuenciaPoliza + 1;
					EXECUTE PROCEDURE bdicont:"informix".insertapoliza(v_sEmpresa, p_sUsuarioSistema, '01', '1', v_sFechaSistema, v_sFechaSistema,
					'0','0', v_iSecuenciaPoliza::CHAR(4), v_sc_ccMayor, v_sc_ccSub, v_sc_ccSubSub, v_sc_ccssSub, v_sc_ccsssSub, v_sc_Sector, --v_sAuxiliar, 
					v_sAuxiliarBanco,
					v_sCCRecHumanos, v_sCCRecHumanos, 'D', v_sMontoTotalC::CHAR(20), 'MOVIMIENTO DE CARGO DE FALTANTES POR NOMINA', '0') 
					INTO v_sCodRet, v_iCtrlPolizaTmp, v_iSecuenciaTmp, v_iNumRegistrosTmp;						
					
					LET v_sMontoTotalC = 0;					
				END IF	
				LET v_sTransaccionAnt = v_sTransaccion;
				LET v_sMontoTotalC = v_sMontoTotalC + v_sMontoTotal;
			END FOREACH;	

			--Se incrementa la secuencia de la poliza para realizar el cargo
			LET v_iSecuenciaPoliza = v_iSecuenciaPoliza + 1;
			--Inserta el cargo de la poliza para la ultima transacción
			EXECUTE PROCEDURE bdicont:"informix".insertapoliza(v_sEmpresa, p_sUsuarioSistema, '01', '1', v_sFechaSistema, v_sFechaSistema,
			'0','0', v_iSecuenciaPoliza::CHAR(4), v_sc_ccMayor, v_sc_ccSub, v_sc_ccSubSub, v_sc_ccssSub, v_sc_ccsssSub, v_sc_Sector,
--v_sAuxiliar,   
v_sAuxiliarBanco,
			v_sCCRecHumanos, v_sCCRecHumanos, 'D', v_sMontoTotalC::CHAR(20), 'MOVIMIENTO DE CARGO DE FALTANTES POR NOMINA', '0') 
			INTO v_sCodRet, v_iCtrlPolizaTmp, v_iSecuenciaTmp, v_iNumRegistrosTmp;
			
					
			IF NOT EXISTS (SELECT 1 FROM bdicont:"informix".co_errorpoliza) THEN
				--Se verifica los datos de la poliza si no hay errores traspasa los datos de la poliza a las tabla co_detpol
				EXECUTE PROCEDURE bdicont:"informix".validapolizanomina(v_sEmpresa, p_sUsuarioSistema) INTO v_sCodRet, v_iCtrlPoliza;

				--Si se genero el numero de poliza se actualiza a 1 el campo contable para que ya no se tome en cuenta 
				--para proximas generación de poliza
				IF TRIM(v_sCodRet) = '000' AND v_iCtrlPoliza <> 0 AND NOT EXISTS(SELECT 1 FROM bdicont:"informix".tmpco_auditerr WHERE usuario = p_sUsuarioSistema) THEN
					UPDATE bdirech:"informix".rec_movfaltante SET contable = '1'
					WHERE numempleado IN (SELECT numempleado FROM bdirech:"informix".rec_descquincena)
					AND transaccion IN (v_sTranLiqFaltante, v_sTranLiqDano, v_sTranRecuperaFaltante, v_sTranRecuperaDano)
					AND idmovimiento <> 0 AND idrecupera = 2 AND tipomovimiento = 'A' AND fecharegistro = p_dFechaQuincena;

					--Actualiza el proceso de generación de la poliza
					UPDATE bdirech:"informix".rec_procesos SET estatus = '1'
					WHERE idprocesos = 6 AND fechaproceso = p_dFechaQuincena;
				ELSE
					LET v_sCodRet = '00004';
					DELETE FROM bdicont:"informix".tmpco_detpol WHERE usuario = p_sUsuarioSistema;
				END IF
			ELSE
				LET v_sCodRet = '00004';
				DELETE FROM bdicont:"informix".tmpco_detpol WHERE usuario = p_sUsuarioSistema;						
			END IF
		ELSE
			LET v_sCodRet = '00003';
		END IF
	ELSE
		LET v_sCodRet = '00002';
	END IF

	RETURN v_sCodRet, v_iCtrlPoliza;
END
END PROCEDURE
