CREATE PROCEDURE "informix".spgenerarpolizaasignacion (p_dFechaActual DATE, p_sNumEmpleado CHAR(8), p_sUsuario CHAR(8))
    RETURNING CHAR(5) AS CodigoRetorno, INTEGER AS NumeroPoliza
    
    DEFINE iSqlErr          INTEGER;

    DEFINE v_sCodRet                            CHAR(5);
    DEFINE v_iErrores                           INTEGER;
    DEFINE v_sDescripcionParam                  CHAR(60);
    DEFINE v_sCCRecHumanos                      CHAR(20);
    DEFINE v_sCCNumSistema                      CHAR(20);
    DEFINE v_sTranAsigDano                      CHAR(4);
		
	--Variables para el cargo
    DEFINE v_sc_ccMayor                         CHAR(4);
    DEFINE v_sc_ccSub                           CHAR(2);
    DEFINE v_sc_ccSubSub                        CHAR(2);
    DEFINE v_sc_ccssSub                         CHAR(2);
    DEFINE v_sc_ccsssSub                        CHAR(2);
    DEFINE v_sc_Sector                          CHAR(2);
    
	--Variables para el abono
	DEFINE v_sa_ccMayor                         CHAR(4);
    DEFINE v_sa_ccSub                           CHAR(2);
    DEFINE v_sa_ccSubSub                        CHAR(2);
    DEFINE v_sa_ccssSub                         CHAR(2);
    DEFINE v_sa_ccsssSub                        CHAR(2);
    DEFINE v_sa_Sector                          CHAR(2);
    
	DEFINE v_iSecuenciaPoliza                   INTEGER;
    DEFINE v_sMontoTotal                        MONEY(10,0);
    DEFINE v_sAuxiliar                          CHAR(12);
    DEFINE v_sNumSucursal                       CHAR(4);
	DEFINE v_sEmpresa							CHAR(3);
    DEFINE v_iCtrlPoliza                        INTEGER;
	DEFINE v_sFechaSistema                      CHAR(10);
	--Retorno inserta poliza
	DEFINE v_iCtrlPolizaTemp					INTEGER;
    DEFINE v_iSecuenciaTemp                     INTEGER;
    DEFINE v_iNumRegistrosTemp                  INTEGER;
    
   --SET DEBUG FILE TO '/tmp/mfinis/spgenerarpolizaasignacion.out'; 
   --TRACE ON;
   --"/bkpfs/ids10_uc10/alejandra/Prueba.out"; Prueba 1
   
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet, 0;
            END IF;
        END EXCEPTION;
		
	

        --// Valida parÃ¡metros de entrada
        IF NVL(p_dFechaActual, '') = '' OR NVL(p_sNumEmpleado, '') = '' OR NVL(p_sUsuario, '') = '' THEN
            LET v_sCodRet = '00001';
            RETURN v_sCodRet, 0;
        END IF

        LET v_iCtrlPoliza = 0;
		LET v_iSecuenciaPoliza = 0;
		LET v_sEmpresa = '001';		
				
		--CAMBIA EL FORMATO DE LA FECHA A MMDDAAAA PARA QUE SE PUEDA INSERTAR EN LA POLIZA
		LET v_sFechaSistema = LPAD(MONTH(p_dFechaActual), 2, "0")||LPAD(DAY(p_dFechaActual), 2, "0")||YEAR(p_dFechaActual);		

		--SE OBTIENE EL CENTRO DE COSTOS DE RECURSOS HUMANOS				
		EXECUTE PROCEDURE bdirech:spconsultarparam (2) INTO v_sCodRet, v_sDescripcionParam, v_sCCRecHumanos;

		--SE OBTIENE EL NÃMERO DE SISTEMA DE ADMINISTRACION DE FALTANTES		
		EXECUTE PROCEDURE bdirech:spconsultarparam (3) INTO v_sCodRet, v_sDescripcionParam, v_sCCNumSistema;
		
		--SE OBTIENE EL NUMERO DE TRANSACCION PARA REASIGNACION DE DAÃOS			
		SELECT numero INTO	v_sTranAsigDano FROM bdinteg:si_transacc WHERE sistema = v_sCCNumSistema AND abreviatura = 'REASDAÃO';
		
		--SE OBTIENEN LAS CUENTAS CONTABLES DE LA TRANSACCION DE ASIGNACION POR DAÃOS		
		EXECUTE PROCEDURE bdinteg:spobtenercuentascontables(v_sEmpresa, v_sTranAsigDano, v_sCCNumSistema,'1')
		INTO v_sCodRet, v_sc_ccMayor, v_sc_ccSub, v_sc_ccSubSub,v_sc_ccssSub,v_sc_ccsssSub, v_sc_Sector,
		v_sa_ccMayor, v_sa_ccSub,v_sa_ccSubSub, v_sa_ccssSub, v_sa_ccsssSub, v_sa_Sector;		

		IF v_sCodRet = '00000' THEN
			--PARA  CADA AUXILIAR DE LA TRANSACCION, SE GENERA UN MOVIMIENTO DE CARGO Y DE ABONO POR CADA CTA CONTABLE
			FOREACH
			SELECT auxiliar, numsucursal, SUM(montomovimiento) INTO v_sAuxiliar, v_sNumSucursal, v_sMontoTotal
			FROM bdirech:rec_movfaltante
			WHERE transaccion = v_sTranAsigDano AND idmovimiento = 0 AND idrecupera = 2 AND tipomovimiento = 'C' 
			AND fecharegistro = p_dFechaActual AND numempleado = p_sNumEmpleado AND contable = '0' GROUP BY 1, 2

				--Se incrementa la secuencia de la poliza para realizar el abono
				LET v_iSecuenciaPoliza = v_iSecuenciaPoliza + 1;
				--Inserta los datos de la poliza en una tabla temporal llamada tmpco_auditerr
				EXECUTE PROCEDURE bdicont:insertapoliza(v_sEmpresa, p_sUsuario, '01', '1', v_sFechaSistema, v_sFechaSistema,
				'0','0', v_iSecuenciaPoliza::CHAR(4), v_sa_ccMayor, v_sa_ccSub, v_sa_ccSubSub, v_sa_ccssSub, v_sa_ccsssSub, v_sa_Sector,
				'', v_sNumSucursal, v_sCCRecHumanos, 'C', v_sMontoTotal::CHAR(20), 'ABONO POR ASIGNACION DE DAÃOS', '0') 
				INTO v_sCodRet, v_iCtrlPolizaTemp, v_iSecuenciaTemp, v_iNumRegistrosTemp;

				--Se incrementa la secuencia de la poliza para realizar el cargo
				LET v_iSecuenciaPoliza = v_iSecuenciaPoliza + 1;
				--Inserta los datos de la poliza en una tabla temporal llamada tmpco_auditerr
				EXECUTE PROCEDURE bdicont:insertapoliza(v_sEmpresa, p_sUsuario, '01', '1', v_sFechaSistema, v_sFechaSistema,
				'0','0', v_iSecuenciaPoliza::CHAR(4), v_sc_ccMayor, v_sc_ccSub, v_sc_ccSubSub, v_sc_ccssSub, v_sc_ccsssSub, v_sc_Sector,
				v_sAuxiliar, v_sNumSucursal, v_sCCRecHumanos, 'D', v_sMontoTotal::CHAR(20), 'CARGO POR ASIGNACION DE DAÃOS', '0') 
				INTO v_sCodRet, v_iCtrlPolizaTemp, v_iSecuenciaTemp, v_iNumRegistrosTemp;
			END FOREACH		
		
			IF v_iSecuenciaPoliza > 0 THEN	
				IF NOT EXISTS (SELECT 1 FROM bdicont:co_errorpoliza) THEN
				--Se verifica los datos de la poliza, si no hay errores traspasa los datos de la poliza a las tabla co_detpol
					EXECUTE PROCEDURE bdicont:validapolizanomina(v_sEmpresa, p_sUsuario) INTO v_sCodRet, v_iCtrlPoliza;

					IF TRIM(v_sCodRet) = '000' AND v_iCtrlPoliza <> 0 AND NOT EXISTS(SELECT 1 FROM bdicont:tmpco_auditerr WHERE usuario = p_sUsuario) THEN
						
						--ACTUALIZA LOS MOVIMIENTOS DE FALTANTE COMO CONTABLES
						UPDATE bdirech:rec_movfaltante SET contable = '1'
						WHERE numempleado = p_sNumEmpleado AND transaccion = v_sTranAsigDano AND idmovimiento = 0 AND idrecupera = 2
						AND tipomovimiento = 'C' AND fecharegistro = p_dFechaActual;

						LET v_sCodRet = '00000';
					ELSE
						LET v_sCodRet = '00003';
						DELETE FROM bdicont:tmpco_detpol WHERE usuario = p_sUsuario;
					END IF
				ELSE 
					LET v_sCodRet = '00003';
					DELETE FROM bdicont:tmpco_detpol WHERE usuario = p_sUsuario;
				END IF
			ELSE
				LET v_sCodRet = '00004';
			END IF
		ELSE
			LET v_sCodRet = '00002';
		END IF
        RETURN v_sCodRet, v_iCtrlPoliza;
    END
END PROCEDURE
