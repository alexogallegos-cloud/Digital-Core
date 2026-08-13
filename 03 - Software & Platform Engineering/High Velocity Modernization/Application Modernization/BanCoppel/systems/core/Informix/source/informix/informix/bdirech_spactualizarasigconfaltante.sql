CREATE PROCEDURE "informix".spactualizarasigconfaltante (p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_iIdFaltante SMALLINT, p_dFechaAsignacion DATE, 
p_iIdAsignado SMALLINT, p_sUsuarioAutoriza CHAR(8)) RETURNING CHAR(5) AS CodigoRetorno

    DEFINE iSqlErr      	INTEGER;
    DEFINE v_sCodRet        CHAR(5);
    DEFINE v_iIdRecupera    SMALLINT;
	DEFINE v_iIdAsignado	SMALLINT;
    DEFINE v_iIdMovimiento  SMALLINT;    
	DEFINE v_mMontoEntero   MONEY(16,0);
	DEFINE v_mMontoCentavos MONEY(2,2);
    DEFINE v_sAuxiliar      CHAR(12);
    DEFINE v_iIdConcepto      SMALLINT;
	DEFINE v_iIdEstatus 	SMALLINT;
    DEFINE v_cReferencia    CHAR(26);

   SET DEBUG FILE TO  "/tmp/spactualizarasigconfaltante.trc";
   TRACE ON;

   SET LOCK MODE TO WAIT 3;
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                INSERT INTO bdirech:"informix".rec_errores(descripcion) VALUES ('saacf '||iSqlErr);
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;
		
        LET v_sCodRet = '00001';

        --//Valida parámetros de entrada
        IF NVL(p_sNumEmpleado, '') = '' OR NVL(p_sNumSucursal, '') = '' OR NVL(p_iIdFaltante, '') = '' OR NVL(p_dFechaAsignacion, '') = '' 
		OR NVL(p_iIdAsignado, '') = '' THEN
            RETURN v_sCodRet;
        END IF;
		
		IF p_iIdAsignado IN (1,5) THEN
			LET v_sCodRet = '00002';
		    RETURN v_sCodRet;
        END IF;

        SELECT idrecupera, idasignado, (saldoactual)::INTEGER, saldoactual-(saldoactual::INTEGER), idconcepto, idestatus, referencia 
		INTO v_iIdRecupera, v_iIdAsignado, v_mMontoEntero, v_mMontoCentavos, v_iIdConcepto, v_iIdEstatus, v_cReferencia 
		FROM bdirech:"informix".rec_confaltante
		WHERE idfaltante = p_iIdFaltante AND numempleado = p_sNumEmpleado AND numsucursal = p_sNumSucursal AND idasignado <> 2;

		IF p_iIdAsignado = v_iIdAsignado OR v_iIdEstatus <> 1 OR v_iIdAsignado IS NULL THEN
			LET v_sCodRet = '00002';		           
		ELSE
			IF v_iIdConcepto = 1 THEN
				IF p_iIdAsignado = 2 THEN --Recursos Humanos
					LET v_iIdRecupera = 2; --Recuperación por Nómina
				END IF
			END IF;
			
			LET v_sAuxiliar = p_sNumSucursal || p_sNumEmpleado;
			
			SELECT NVL(MAX(idmovimiento), 0) + 1 INTO v_iIdMovimiento FROM bdirech:"informix".rec_movfaltante
			WHERE numempleado = p_sNumEmpleado AND idfaltante = p_iIdFaltante AND tipomovimiento IN ('A','R','F','D');
			
			IF v_mMontoCentavos > 0 THEN
				--Graba el movimiento entero generado por la reasignación
				INSERT INTO bdirech:"informix".rec_movfaltante(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento, auxiliar,
				idrecupera, montomovimiento, fecharegistro, contable, usuarioautoriza,referencia, sucursalpago)
				VALUES (p_sNumEmpleado, p_sNumSucursal, p_iIdFaltante, '0050', v_iIdMovimiento, 'R', v_sAuxiliar,
				v_iIdRecupera, v_mMontoCentavos, p_dFechaAsignacion, '0', p_sUsuarioAutoriza, v_cReferencia, p_sNumSucursal);
				
				LET v_iIdMovimiento = v_iIdMovimiento + 1;
			END IF;
			
			--Graba el movimiento fraccionario generado por la reasignación
			INSERT INTO bdirech:"informix".rec_movfaltante(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento, auxiliar,
			idrecupera, montomovimiento, fecharegistro, contable, usuarioautoriza,referencia,sucursalpago)
			VALUES (p_sNumEmpleado, p_sNumSucursal, p_iIdFaltante, '0050', v_iIdMovimiento, 'R', v_sAuxiliar,
			v_iIdRecupera, v_mMontoEntero, p_dFechaAsignacion, '0', p_sUsuarioAutoriza, v_cReferencia,p_sNumSucursal);
			
			--Actualiza el faltante en el concentrado y el saldo actual e inicial sin centavos
			UPDATE bdirech:"informix".rec_confaltante 
			SET fechaasigna = p_dFechaAsignacion, idrecupera = v_iIdRecupera , idasignado = p_iIdAsignado, idasignadoant = idasignado,
			saldoinicial = ROUND(saldoinicial,0), saldoactual = ROUND(saldoactual,0), descquincenafijo = 0
			WHERE idfaltante = p_iIdFaltante AND numempleado = p_sNumEmpleado AND numsucursal = p_sNumSucursal;
			
			LET v_sCodRet = '00000';				
			
        END IF;
        RETURN v_sCodRet;
    END
END PROCEDURE
