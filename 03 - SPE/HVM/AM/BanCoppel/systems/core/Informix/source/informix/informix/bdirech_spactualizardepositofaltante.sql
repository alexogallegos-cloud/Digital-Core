CREATE PROCEDURE "informix".spactualizardepositofaltante (p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_iIdFaltante SMALLINT, p_mDescuento MONEY(10,0),
                                             p_dFecha DATE, p_sBancoCheque CHAR(40), p_cUsuarioAurotiza CHAR(8))
RETURNING CHAR(5) AS CodigoRetorno

--------------------------------------------------------------------
--DOCUMENTACIÃN
--actualiza el abono del deposito a los faltantes, para el modulo af0012.exe, para que pueda recibir depositos parciales o totales, sin que suspenda el pago por via nomina
--RealizÃ³: Richar 
--Fecha: 14/07/2015
--Retorno: 00000  ActualizaciÃ³n exitosa',
--		   00001  Parametros insuficientes',
--         00002  Descuento menor al saldo actual',
--         00003  No existe el faltante que se trata de actualizar o el concepto no es faltante ',

--------------------------------------------------------------------				
    
    DEFINE iSqlErr          INTEGER;

    DEFINE v_sCodRet        CHAR(5);
    DEFINE v_iIdConcepto    SMALLINT;
    DEFINE v_mSaldoActual   MONEY(10,0);
    DEFINE v_sTransaccion   CHAR(4);
    DEFINE v_iIdMovimiento  SMALLINT;
    DEFINE v_sAuxiliar      CHAR(12);
	DEFINE v_cReferencia 	CHAR(26);
	DEFINE v_idasignado		SMALLINT;
	DEFINE v_perfil 		CHAR(4);
	
	LET v_sCodRet = '00000';
	LET v_idasignado = 0;
	LET v_perfil = '';
    
    --SET DEBUG FILE TO  "spactualizardepositofaltante.out"; 
    --TRACE ON;

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                INSERT INTO bdirech:"informix".rec_errores(descripcion) VALUES ('safcf '||iSqlErr);
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;

        --// Valida parÃ¡metros de entrada
        IF NVL(p_sNumEmpleado, '') = '' OR NVL(p_sNumSucursal, '') = '' OR NVL(p_iIdFaltante, '') = '' OR NVL(p_mDescuento, '') = ''
            OR NVL(p_dFecha, '') = '' OR NVL(p_cUsuarioAurotiza,'') = '' THEN
            LET v_sCodRet = '00001';
            RETURN v_sCodRet;
        END IF
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        SELECT saldoactual, idconcepto, referencia, idasignado
		  INTO v_mSaldoActual, v_iIdConcepto, v_cReferencia, v_idasignado FROM bdirech:"informix".rec_confaltante
        WHERE numempleado = p_sNumEmpleado AND numsucursal = p_sNumSucursal AND idfaltante = p_iIdFaltante AND idasignado IN (2,3);

        IF v_mSaldoActual IS NULL THEN
            LET v_sCodRet = '00003';
            RETURN v_sCodRet;
        END IF
		
		 SELECT perfil
		   INTO v_perfil		 
		   FROM bdinteg:"informix".si_perfil_ejecut 
		  WHERE perfil IN ('3101','3104') -- SOLO PERFIL DE ADMINISTRACION Y OPERACION DE FALTANTES
		    AND ejecutivo= p_cUsuarioAurotiza 
			AND cod_emp='001' AND sistema = 31;

        IF (v_perfil = '' OR (v_perfil='3101' AND v_idasignado <> '2') OR (v_perfil='3104' AND v_idasignado <> '3') ) THEN 
			LET v_sCodRet = '00003';
            RETURN v_sCodRet;
        END IF
		
        IF v_mSaldoActual IS NOT NULL AND v_iIdConcepto <> 3 THEN
            IF v_mSaldoActual = p_mDescuento THEN
                UPDATE bdirech:"informix".rec_confaltante
                SET fechaliquida = p_dFecha,
                descacumulado = descacumulado + p_mDescuento,
                desccalculado = p_mDescuento,
                saldoactual = 0,
                idestatus = 5, --Liquidado
                bancocheque = p_sBancoCheque
                WHERE numempleado = p_sNumEmpleado AND numsucursal = p_sNumSucursal AND idfaltante = p_iIdFaltante;

                --Obtener el tipo de transaccion para quebranto de acuerdo al tipo de faltante.
                IF v_iIdConcepto = 1 THEN
                    LET v_sTransaccion = '0052';
                ELIF v_iIdConcepto = 2 THEN
                    LET v_sTransaccion = '0056';
                END IF

            ELIF v_mSaldoActual > p_mDescuento THEN
                UPDATE bdirech:"informix".rec_confaltante
                SET descacumulado = descacumulado + p_mDescuento,
                desccalculado = p_mDescuento,
                saldoactual = saldoactual - p_mDescuento,
                bancocheque = p_sBancoCheque
                WHERE numempleado = p_sNumEmpleado AND numsucursal = p_sNumSucursal AND idfaltante = p_iIdFaltante;

                --Obtener el tipo de transaccion para quebranto de acuerdo al tipo de faltante.
                IF v_iIdConcepto = 1 THEN
                    LET v_sTransaccion = '0051';
                ELIF v_iIdConcepto = 2 THEN
                    LET v_sTransaccion = '0055';
                END IF

               
            ELIF v_mSaldoActual < p_mDescuento THEN
                LET v_sCodRet = '00002';
            END IF
			
			IF v_sCodRet <> '00002' THEN				
				
				SELECT NVL(MAX(idmovimiento), 0) + 1 INTO v_iIdMovimiento FROM bdirech:"informix".rec_movfaltante 
				WHERE numempleado = p_sNumEmpleado AND idfaltante = p_iIdFaltante AND tipomovimiento IN ('A','R','F');

                LET v_sAuxiliar = p_sNumSucursal || p_sNumEmpleado;

                --Graba el movimiento generado
                INSERT INTO bdirech:"informix".rec_movfaltante(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento, auxiliar,
				idrecupera, montomovimiento, fecharegistro, contable, usuarioautoriza, referencia, sucursalpago)
                VALUES (p_sNumEmpleado, p_sNumSucursal, p_iIdFaltante, v_sTransaccion, v_iIdMovimiento, 'A', v_sAuxiliar, 
				3, p_mDescuento, p_dFecha, '0', p_cUsuarioAurotiza, v_cReferencia, p_sNumSucursal);
			END IF;	
			
        ELSE
            LET v_sCodRet = '00003';
        END IF;

        RETURN v_sCodRet;
    END
END PROCEDURE


;