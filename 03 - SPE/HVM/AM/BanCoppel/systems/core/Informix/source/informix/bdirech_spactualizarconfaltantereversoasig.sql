CREATE PROCEDURE "informix".spactualizarconfaltantereversoasig( p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4),
			p_iIdFaltante SMALLINT, p_dFechaAsignacion DATE, p_iIdEstatus SMALLINT, p_sUsuarioAutoriza CHAR(8))

	RETURNING CHAR(5) AS CodigoRetorno

    DEFINE iSqlErr			INTEGER;
    DEFINE v_sCodRet		CHAR(5);
    DEFINE v_iIdRecupera	SMALLINT;
    DEFINE v_iIdAsignado	SMALLINT;
	DEFINE v_iIdAsignadoant	SMALLINT;
    DEFINE v_iIdMovimiento	SMALLINT;
	DEFINE v_mMonto			MONEY(16,2);
    DEFINE v_mMontoEntero	MONEY(16,0);
    DEFINE v_mMontoCentavos	MONEY(2,2);
    DEFINE v_sAuxiliar		CHAR(12);
    DEFINE v_iIdConcepto	SMALLINT;
    DEFINE v_iIdEstatus 	SMALLINT;
    DEFINE v_cReferencia	CHAR(26);
	DEFINE v_iSecuencia		SMALLINT;

   --SET DEBUG FILE TO  "spactualizarconfaltantereversoasig.out";
   --TRACE ON;
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                INSERT INTO bdirech:"informix".rec_errores(descripcion) VALUES ('sacfra '||iSqlErr);
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;

        LET v_sCodRet		= '00001';
        LET v_iIdMovimiento	= 0;
        LET v_iIdAsignado	= 0;
        LET v_cReferencia	= '';
		
	

        --//Valida parÃ¡metros de entrada
        IF NVL(p_sNumEmpleado, '') = '' OR NVL(p_sNumSucursal, '') = '' OR NVL(p_iIdFaltante, '') = '' OR NVL(p_dFechaAsignacion, '') = ''
		OR NVL(p_iIdEstatus, '') = '' THEN
            RETURN v_sCodRet;
        END IF;

		IF p_iIdEstatus = 3 THEN
			--Actualiza el faltante en el concentrado
			UPDATE bdirech:"informix".rec_confaltante
			SET fechaasigna = p_dFechaAsignacion,
			idestatus = 1 --Pendiente de Aplicar
			WHERE idfaltante = p_iIdFaltante AND numempleado = p_sNumEmpleado AND numsucursal = p_sNumSucursal;

			LET v_sCodRet = '00000';
			
		ELIF p_iIdEstatus = 7 THEN
			SELECT idasignado, NVL(RM.saldoactual,0), RC.referencia, idasignadoant, idrecupera	
			INTO v_iIdAsignado, v_mMonto, v_cReferencia, v_iIdAsignadoant, v_iIdRecupera
			FROM bdirech:"informix".rec_confaltante RC
			left join bdirech:"informix".rec_movquebrantos RM
            ON RC.idfaltante = RM.idfaltante AND RC.numempleado = RM.numempleado AND RC.numsucursal = RM.numsucursal AND trim(RM.tipoperacion)= 'FIN'
			WHERE RC.idfaltante = p_iIdFaltante AND RC.numempleado = p_sNumEmpleado AND RC.numsucursal = p_sNumSucursal;
			
			SELECT NVL(MAX(idmovimiento), 0) + 1
			INTO v_iIdMovimiento
			FROM bdirech:"informix".rec_movfaltante
			WHERE idfaltante = p_iIdFaltante AND numempleado = p_sNumEmpleado
			AND tipomovimiento IN ('A','R','F','D');
			
			LET v_iSecuencia = 0; --Reverso de quebranto finalizado
			LET v_sAuxiliar = p_sNumSucursal || p_sNumEmpleado;
			
			--Graba el movimiento entero generado por la reasignaciÃ³n
				INSERT INTO bdirech:"informix".rec_movfaltante(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento, auxiliar,
				idrecupera, montomovimiento, fecharegistro, contable, usuarioautoriza,referencia, foliosuc, sucursalpago, secuencia)
				VALUES (p_sNumEmpleado, p_sNumSucursal, p_iIdFaltante, '0058', v_iIdMovimiento, 'D', v_sAuxiliar,
				v_iIdRecupera, v_mMonto, p_dFechaAsignacion, '0', p_sUsuarioAutoriza, v_cReferencia, '', '', v_iSecuencia);
				
				--Actualiza el faltante en el concentrado y el saldo actual e inicial con centavos
				UPDATE bdirech:"informix".rec_confaltante 
				SET fechaasigna = p_dFechaAsignacion, idasignado = 6 ,idestatus = 4
				WHERE idfaltante = p_iIdFaltante AND numempleado = p_sNumEmpleado AND numsucursal = p_sNumSucursal;
				
			LET v_sCodRet = '00000';
			
		ELIF p_iIdEstatus = 4 THEN
			SELECT idasignado, NVL(RM.saldoactual,0), RC.referencia, idasignadoant, idrecupera	
			INTO v_iIdAsignado, v_mMonto, v_cReferencia, v_iIdAsignadoant, v_iIdRecupera
			FROM bdirech:"informix".rec_confaltante RC
			left join bdirech:"informix".rec_movquebrantos RM
            ON RC.idfaltante = RM.idfaltante AND RC.numempleado = RM.numempleado AND RC.numsucursal = RM.numsucursal AND RC.auxiliar=RM.auxiliar
			WHERE RC.idfaltante = p_iIdFaltante AND RC.numempleado = p_sNumEmpleado AND RC.numsucursal = p_sNumSucursal;
			
			SELECT NVL(MAX(idmovimiento), 0) + 1
			INTO v_iIdMovimiento
			FROM bdirech:"informix".rec_movfaltante
			WHERE idfaltante = p_iIdFaltante AND numempleado = p_sNumEmpleado
			AND tipomovimiento IN ('A','R','F','D');
			
			LET v_iSecuencia = 0; --Reverso de quebranto
			LET v_sAuxiliar = p_sNumSucursal || p_sNumEmpleado;
			
			--Graba el movimiento entero generado por la reasignaciÃ³n
				INSERT INTO bdirech:"informix".rec_movfaltante(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento, auxiliar,
				idrecupera, montomovimiento, fecharegistro, contable, usuarioautoriza,referencia, foliosuc, sucursalpago, secuencia)
				VALUES (p_sNumEmpleado, p_sNumSucursal, p_iIdFaltante, '0058', v_iIdMovimiento, 'D', v_sAuxiliar,
				v_iIdRecupera, v_mMonto, p_dFechaAsignacion, '0', p_sUsuarioAutoriza, v_cReferencia, '', '', v_iSecuencia);

				--Actualiza el faltante en el concentrado
				UPDATE bdirech:"informix".rec_confaltante
				SET fechaasigna = p_dFechaAsignacion,				
				idasignado = v_iIdAsignadoant,
				idasignadoant = v_iIdAsignado,
				saldoinicial = NVL(saldoinicial, 0),
				saldoactual = NVL(v_mMonto, 0),
				idestatus=3
				WHERE idfaltante = p_iIdFaltante AND numempleado = p_sNumEmpleado AND numsucursal = p_sNumSucursal;		
			
			LET v_sCodRet = '00000';
		ELSE
			SELECT idasignado, saldoactual, (saldoactual)::INTEGER, saldoactual-(saldoactual::INTEGER), referencia
			INTO v_iIdAsignado, v_mMonto, v_mMontoEntero, v_mMontoCentavos, v_cReferencia
			FROM bdirech:"informix".rec_confaltante
			WHERE idfaltante = p_iIdFaltante AND numempleado = p_sNumEmpleado AND numsucursal = p_sNumSucursal;

			LET v_iIdRecupera = 1; --Sucursal
			LET v_sAuxiliar = p_sNumSucursal || p_sNumEmpleado;

			IF v_iIdAsignado = 2 THEN
				LET v_iSecuencia = 1;
			ELSE
				LET v_iSecuencia = 2;
			END IF;

			SELECT NVL(MAX(idmovimiento), 0) + 1
			INTO v_iIdMovimiento
			FROM bdirech:"informix".rec_movfaltante
			WHERE idfaltante = p_iIdFaltante AND numempleado = p_sNumEmpleado
			AND tipomovimiento IN ('A','R','F','D');

			IF v_mMontoCentavos > 0 AND v_iIdAsignado = 2 THEN
				--Graba el movimiento fraccionario generado por la reasignaciÃ³n
				INSERT INTO bdirech:"informix".rec_movfaltante(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento, auxiliar,
				idrecupera, montomovimiento, fecharegistro, contable, usuarioautoriza,referencia, foliosuc, sucursalpago, secuencia)
				VALUES (p_sNumEmpleado, p_sNumSucursal, p_iIdFaltante, '0058', v_iIdMovimiento, 'D', v_sAuxiliar,
				v_iIdRecupera, v_mMontoCentavos, p_dFechaAsignacion, '0', p_sUsuarioAutoriza, v_cReferencia, '', '', v_iSecuencia);

				LET v_iIdMovimiento = v_iIdMovimiento + 1;
			END IF;

			IF v_iIdAsignado = 2 THEN
				--Graba el movimiento entero generado por la reasignaciÃ³n
				INSERT INTO bdirech:"informix".rec_movfaltante(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento, auxiliar,
				idrecupera, montomovimiento, fecharegistro, contable, usuarioautoriza,referencia, foliosuc, sucursalpago, secuencia)
				VALUES (p_sNumEmpleado, p_sNumSucursal, p_iIdFaltante, '0058', v_iIdMovimiento, 'D', v_sAuxiliar,
				v_iIdRecupera, v_mMontoEntero, p_dFechaAsignacion, '0', p_sUsuarioAutoriza, v_cReferencia, '', '', v_iSecuencia);

				--Actualiza el faltante en el concentrado
				UPDATE bdirech:"informix".rec_confaltante
				SET fechaasigna = p_dFechaAsignacion,
				idrecupera = v_iIdRecupera,
				idasignado = 1,--Sucursal
				idasignadoant = idasignado,
				saldoinicial = ROUND(saldoinicial, 0),
				saldoactual = ROUND(saldoactual, 0),
				descquincenafijo = 0
				WHERE idfaltante = p_iIdFaltante AND numempleado = p_sNumEmpleado AND numsucursal = p_sNumSucursal;
			ELSE
				--Graba el movimiento entero generado por la reasignaciÃ³n
				INSERT INTO bdirech:"informix".rec_movfaltante(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento, auxiliar,
				idrecupera, montomovimiento, fecharegistro, contable, usuarioautoriza,referencia, foliosuc, sucursalpago, secuencia)
				VALUES (p_sNumEmpleado, p_sNumSucursal, p_iIdFaltante, '0058', v_iIdMovimiento, 'D', v_sAuxiliar,
				v_iIdRecupera, v_mMonto, p_dFechaAsignacion, '0', p_sUsuarioAutoriza, v_cReferencia, '', '', v_iSecuencia);

				--Actualiza el faltante en el concentrado
				UPDATE bdirech:"informix".rec_confaltante
				SET fechaasigna = p_dFechaAsignacion,
				idrecupera = v_iIdRecupera,
				idasignado = 1,--Sucursal
				idasignadoant = idasignado,
				descquincenafijo = 0
				WHERE idfaltante = p_iIdFaltante AND numempleado = p_sNumEmpleado AND numsucursal = p_sNumSucursal;
			END IF;

			LET v_sCodRet = '00000';
		END IF;

        RETURN v_sCodRet;
    END
END PROCEDURE
