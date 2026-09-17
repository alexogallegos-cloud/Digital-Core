CREATE PROCEDURE "informix".spactualizarqueconfaltante (p_sNumEmpleado CHAR(8), p_iIdEstatus SMALLINT, p_cUsuarioAurotiza CHAR(8))
RETURNING CHAR(5) AS CodigoRetorno

    --DECLARACION DE VARIABLES
    DEFINE iSqlErr          INTEGER;
    DEFINE v_sCodRet        CHAR(5);
    DEFINE v_sNumSucursal   CHAR(4);
    DEFINE v_iIdFaltante    SMALLINT;
    DEFINE v_iIdConcepto    SMALLINT;
    DEFINE v_iIdRecupera    SMALLINT;
    DEFINE v_mSaldoActual   MONEY(10,0);
    DEFINE v_dFecha         DATE;
    DEFINE v_sTransaccion   CHAR(4);
    DEFINE v_iIdMovimiento  SMALLINT;
    DEFINE v_sAuxiliar      CHAR(12);
	DEFINE v_cReferencia	CHAR(26);

    --SET DEBUG FILE TO  "/tmp/vladi/spactualizarqueconfaltante.out"; 
    --TRACE ON;

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                INSERT INTO bdirech:"informix".rec_errores(descripcion) VALUES ('saqcf '||iSqlErr);
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;

        LET v_sCodRet = '00001';
        
		SET LOCK MODE TO WAIT 3;
		
        --Valida parámetros de entrada
        IF NVL(p_sNumEmpleado, '') = '' OR NVL(p_iIdEstatus, '') = '' THEN
            RETURN v_sCodRet;
        END IF
        
        --Obtiene la fecha del sistema
        SELECT fecha_hoy
        INTO v_dFecha
        FROM bdinteg:"informix".si_fechas;

        --Obtener los datos para actualizar y para mandar grabar el movimiento por el quebranto.
        FOREACH
            SELECT numsucursal, idfaltante, idconcepto, idrecupera, saldoactual, referencia
            INTO v_sNumSucursal, v_iIdFaltante, v_iIdConcepto, v_iIdRecupera, v_mSaldoActual, v_cReferencia
            FROM bdirech:"informix".rec_confaltante WHERE numempleado = p_sNumEmpleado AND saldoactual > 0 AND idconcepto IN (1,2)

            --Obtener el tipo de transaccion para quebranto de acuerdo al tipo de faltante.
            IF v_iIdConcepto = 1 THEN
                LET v_sTransaccion = '0053';
            ELIF v_iIdConcepto = 2 THEN
                LET v_sTransaccion = '0057';
            END IF

            LET v_sAuxiliar = v_sNumSucursal || p_sNumEmpleado;

            SELECT NVL(MAX(idmovimiento), 0) + 1 INTO v_iIdMovimiento FROM bdirech:"informix".rec_movfaltante 
			WHERE numempleado = p_sNumEmpleado AND idfaltante = v_iIdFaltante AND tipomovimiento IN ('A','R','F');

            --Actualiza el idestatus a quebranto
            UPDATE bdirech:"informix".rec_confaltante SET idestatus = p_iIdEstatus
            WHERE numempleado = p_sNumEmpleado AND numsucursal = v_sNumSucursal AND idfaltante = v_iIdFaltante;

            --Graba el movimiento generado por el quebranto
            INSERT INTO bdirech:"informix".rec_movfaltante(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento,
			auxiliar, idrecupera, montomovimiento, fecharegistro, contable, usuarioautoriza, referencia, sucursalpago)
            VALUES (p_sNumEmpleado, v_sNumSucursal, v_iIdFaltante, v_sTransaccion, v_iIdMovimiento, 'A',
			v_sAuxiliar, v_iIdRecupera, v_mSaldoActual, v_dFecha, '0', p_cUsuarioAurotiza, v_cReferencia,v_sNumSucursal);
        END FOREACH

        LET v_sCodRet = '00000';

        RETURN v_sCodRet;
    END
END PROCEDURE
