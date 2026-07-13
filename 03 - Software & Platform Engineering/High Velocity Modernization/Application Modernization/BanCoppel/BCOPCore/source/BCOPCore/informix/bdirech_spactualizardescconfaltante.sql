CREATE PROCEDURE "informix".spactualizardescconfaltante (p_dFechaQuincena DATE, p_cUsuarioAutoriza CHAR (8))
    RETURNING CHAR(5) AS CodigoRetorno
    
DEFINE iSqlErr          INTEGER;

DEFINE v_sCodRet        CHAR(5);
DEFINE v_sNumSucursal   CHAR(4);
DEFINE v_iIdFaltante    SMALLINT;
DEFINE v_mDescCalculado MONEY(10,0);
DEFINE v_mSaldoActual   MONEY(10,0);
DEFINE v_mMontoAplicado MONEY(10,0);
DEFINE v_sNumEmpleado   CHAR(8);
DEFINE v_mDescAplicado  MONEY(10,0);
DEFINE v_mDescAplicadoQ MONEY(10,0);
DEFINE v_mDescApliMov   MONEY(10,0);
DEFINE v_sEstatus        CHAR(2);
DEFINE v_iErrores        INTEGER;
DEFINE v_iIdConcepto    SMALLINT;
DEFINE v_sTransaccion    CHAR(4);
DEFINE v_iIdMovimiento    SMALLINT;
DEFINE v_sAuxiliar        CHAR(12);
DEFINE v_cReferencia	  CHAR(26);

 --SET DEBUG FILE TO  "/home/vladi/javier.out"; 
 --TRACE ON;
 
BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            INSERT INTO bdirech:"informix".rec_errores(descripcion) VALUES ('sadcf '||iSqlErr);
            LET v_sCodRet = iSqlErr;
            RETURN v_sCodRet;
        END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	
    --// Valida parámetros de entrada
    IF NVL(p_dFechaQuincena, '') = '' THEN
        LET v_sCodRet = '00001';
        RETURN v_sCodRet;
    END IF

    --LET v_sCodRet = '00002';
    --Proceso de Transferencia de Archivos.
    EXECUTE PROCEDURE bdirech:"informix".spvalidarprocesos (p_dFechaQuincena,'4') INTO v_sCodRet, v_sEstatus, v_iErrores;

    IF v_sEstatus = '1' AND v_iErrores = 0 THEN
        --Proceso de Actualización de Saldos.
        EXECUTE PROCEDURE bdirech:"informix".spvalidarprocesos (p_dFechaQuincena,'5') INTO v_sCodRet, v_sEstatus, v_iErrores;

        --LET v_sCodRet = '00004';

        IF v_sEstatus = '0' AND v_iErrores = 0 THEN
			LET v_sCodRet = '00002';
            FOREACH
			SELECT numempleado, descaplicado INTO v_sNumEmpleado, v_mDescAplicadoQ 
			FROM bdirech:"informix".rec_descquincena WHERE fechadesc = p_dFechaQuincena    
				
				LET v_sCodRet = '00000';
                LET v_mDescApliMov = 0;
				IF v_mDescAplicadoQ > 0 THEN
					LET v_mDescAplicado = v_mDescAplicadoQ;
					FOREACH
					SELECT desccalculado, numsucursal, idfaltante, saldoactual, idconcepto, referencia
					INTO v_mDescCalculado, v_sNumSucursal, v_iIdFaltante, v_mSaldoActual, v_iIdConcepto, v_cReferencia
					FROM bdirech:"informix".rec_confaltante
					WHERE numempleado = v_sNumEmpleado AND saldoactual > 0 AND idrecupera IN (2,6) AND idestatus NOT IN (4,5) AND idconcepto IN (1,2) 
					ORDER BY fecharegistro
					
						--v_mDescAplicado=580
					--v_mDescCalculado=177

						LET v_sCodRet = '00003';                   
						IF v_mDescCalculado <= v_mDescAplicado THEN
							IF v_mSaldoActual = v_mDescCalculado THEN
								--LIQUIDACION
								UPDATE bdirech:"informix".rec_confaltante SET saldoactual = saldoactual - v_mDescCalculado, 
								descacumulado = descacumulado + v_mDescCalculado, fechaliquida = p_dFechaQuincena, idestatus = 5 
								-- Estatus = Liquidado
								WHERE numempleado = v_sNumEmpleado AND numsucursal = v_sNumSucursal AND idfaltante = v_iIdFaltante;
								IF v_iIdConcepto = 2 THEN --LIQUIDACIÓN DE DAÑOS
									LET v_sTransaccion = '0056';
								ELIF v_iIdConcepto = 1 THEN --LIQUIDACIÓN DE FALTANTE
									LET v_sTransaccion = '0052';
								END IF
								LET v_mMontoAplicado = v_mDescCalculado;
							ELIF (v_mDescCalculado=0 AND v_mDescAplicado>0) and v_mDescAplicado<=v_mSaldoActual  THEN--Si el decuento calculado viene en Ceros, que descuente lo aplicado si es menor al saldo actual
								--RECUPERACION
								UPDATE bdirech:"informix".rec_confaltante SET saldoactual = saldoactual - v_mDescAplicado, 
								descacumulado = descacumulado + v_mDescAplicado
								WHERE numempleado = v_sNumEmpleado AND numsucursal = v_sNumSucursal AND idfaltante = v_iIdFaltante;
								IF v_iIdConcepto = 2 THEN --RECUPERACIÓN DE DAÑOS
									LET v_sTransaccion = '0055';
								ELIF v_iIdConcepto = 1 THEN --RECUPERACION DE FALTANTE
									LET v_sTransaccion = '0051';
								END IF
								LET v_mMontoAplicado = v_mDescAplicado;
								
							ElIF (v_mDescAplicado>v_mDescCalculado) and v_mSaldoActual>=v_mDescAplicado THEN --
							
							--RECUPERACION
								UPDATE bdirech:"informix".rec_confaltante SET saldoactual = saldoactual - v_mDescAplicado, 
								descacumulado = descacumulado + v_mDescAplicado
								WHERE numempleado = v_sNumEmpleado AND numsucursal = v_sNumSucursal AND idfaltante = v_iIdFaltante;
								IF v_iIdConcepto = 2 THEN --RECUPERACIÓN DE DAÑOS
									LET v_sTransaccion = '0055';
								ELIF v_iIdConcepto = 1 THEN --RECUPERACION DE FALTANTE
									LET v_sTransaccion = '0051';
								END IF
								
								LET v_mMontoAplicado = v_mDescAplicado;							
							ElIF (v_mDescAplicado>v_mDescCalculado) and v_mSaldoActual<v_mDescAplicado THEN --							
							--LIQUIDACION
								UPDATE bdirech:"informix".rec_confaltante SET saldoactual = saldoactual - v_mSaldoActual, 
								descacumulado = descacumulado + v_mSaldoActual, fechaliquida = p_dFechaQuincena, idestatus = 5 
								-- Estatus = Liquidado
								WHERE numempleado = v_sNumEmpleado AND numsucursal = v_sNumSucursal AND idfaltante = v_iIdFaltante;
								IF v_iIdConcepto = 2 THEN --LIQUIDACIÓN DE DAÑOS
									LET v_sTransaccion = '0056';
								ELIF v_iIdConcepto = 1 THEN --LIQUIDACIÓN DE FALTANTE
									LET v_sTransaccion = '0052';
								END IF
								LET v_mMontoAplicado = v_mSaldoActual;
							ELSE
								--RECUPERACION
								UPDATE bdirech:"informix".rec_confaltante SET saldoactual = saldoactual - v_mDescCalculado, 
								descacumulado = descacumulado + v_mDescCalculado
								WHERE numempleado = v_sNumEmpleado AND numsucursal = v_sNumSucursal AND idfaltante = v_iIdFaltante;
								IF v_iIdConcepto = 2 THEN --RECUPERACIÓN DE DAÑOS
									LET v_sTransaccion = '0055';
								ELIF v_iIdConcepto = 1 THEN --RECUPERACION DE FALTANTE
									LET v_sTransaccion = '0051';
								END IF
								
								LET v_mMontoAplicado = v_mDescCalculado;
							END IF
							

						ELIF v_mDescCalculado > v_mDescAplicado THEN
						
							IF v_mSaldoActual <= v_mDescAplicado THEN--para que no descuente de mas, si el descuento aplicado es mayor al saldo actual
								--LIQUIDACION
								UPDATE bdirech:"informix".rec_confaltante SET saldoactual = saldoactual - v_mSaldoActual, 
								descacumulado = descacumulado + v_mSaldoActual, fechaliquida = p_dFechaQuincena, idestatus = 5 
								-- Estatus = Liquidado
								WHERE numempleado = v_sNumEmpleado AND numsucursal = v_sNumSucursal AND idfaltante = v_iIdFaltante;
								
								IF v_iIdConcepto = 2 THEN --LIQUIDACIÓN DE DAÑOS
									LET v_sTransaccion = '0056';
								ELIF v_iIdConcepto = 1 THEN --LIQUIDACIÓN DE FALTANTE
									LET v_sTransaccion = '0052';
								END IF
								LET v_mMontoAplicado = v_mSaldoActual;
							ELSE						
								--RECUPERACION
								UPDATE bdirech:"informix".rec_confaltante SET saldoactual = saldoactual - v_mDescAplicado, 
								descacumulado = descacumulado + v_mDescAplicado
								WHERE numempleado = v_sNumEmpleado AND numsucursal = v_sNumSucursal AND idfaltante = v_iIdFaltante;
								IF v_iIdConcepto = 2 THEN --RECUPERACIÓN DE DAÑOS
									LET v_sTransaccion = '0055';
								ELIF v_iIdConcepto = 1 THEN --RECUPERACION DE FALTANTE
									LET v_sTransaccion = '0051';
								END IF
								LET v_mMontoAplicado = v_mDescAplicado;
							END IF
						END IF

						SELECT NVL(MAX(idmovimiento), 0) + 1 INTO v_iIdMovimiento FROM bdirech:"informix".rec_movfaltante 
						WHERE numempleado = v_sNumEmpleado AND idfaltante = v_iIdFaltante AND tipomovimiento IN ('A','R','F');

						LET v_sAuxiliar = v_sNumSucursal || v_sNumEmpleado;

						--Graba el movimiento generado
						INSERT INTO bdirech:"informix".rec_movfaltante(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento, 
						auxiliar, idrecupera, montomovimiento, fecharegistro, contable,usuarioautoriza,referencia,sucursalpago)
						VALUES (v_sNumEmpleado, v_sNumSucursal, v_iIdFaltante, v_sTransaccion, v_iIdMovimiento, 'A', 
						v_sAuxiliar, 2, v_mMontoAplicado, p_dFechaQuincena, '0',p_cUsuarioAutoriza,v_cReferencia,v_sNumSucursal);

						LET v_mDescAplicado = v_mDescAplicado - v_mMontoAplicado;
						LET v_mDescApliMov = v_mDescApliMov + v_mMontoAplicado;
						LET v_sCodRet = '00000';					
					END FOREACH;
				
					IF v_mDescAplicado > 0 THEN
						INSERT INTO bdirech:"informix".rec_errores(descripcion) 
						VALUES ('sadcf '||v_sNumEmpleado||'-Desc Aplicado '||v_mDescAplicado||'-Desc Real '||v_mDescApliMov);
					END IF				
				END IF
            END FOREACH;

            SELECT COUNT(*) INTO v_iErrores FROM bdirech:"informix".rec_errores;
            IF v_sCodRet = '00000' AND v_iErrores = 0 THEN
                UPDATE bdirech:"informix".rec_procesos SET estatus = '1'
                WHERE fechaproceso = p_dFechaQuincena AND idprocesos = 5;            ELSE
                LET v_sCodRet = '00003';
            END IF
		ELSE
			LET v_sCodRet = '00004';
        END IF
    ELSE
        LET v_sCodRet = '00005';
    END IF
    RETURN v_sCodRet;
END
END PROCEDURE
