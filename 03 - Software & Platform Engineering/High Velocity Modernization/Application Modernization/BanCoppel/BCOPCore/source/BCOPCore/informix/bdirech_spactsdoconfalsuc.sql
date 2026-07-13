CREATE PROCEDURE "informix".spactsdoconfalsuc(p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_iIdFaltante SMALLINT, p_mDescuento MONEY(10,2), 
p_dFecha DATE, p_sUsuarioAutoriza CHAR(8), p_sTransaccion CHAR(4), p_sFolioSucursal CHAR(16))
	RETURNING CHAR(5) AS CodigoRetorno

	DEFINE iSqlErr          INTEGER;
	DEFINE v_sCodRet        CHAR(5);
	DEFINE v_mSaldoActual	MONEY(10,2);
	DEFINE v_sReferencia	CHAR(26);
	DEFINE v_sAuxiliar		CHAR(12);
	DEFINE v_iIdMovimiento	SMALLINT;
	DEFINE v_iTransaccion	INTEGER;
	DEFINE v_sSucFaltante   CHAR(4);
	
	LET v_iTransaccion = 0;

	--------------------------------------------------------------------	
	--SET DEBUG FILE TO "/datos/francisco/spactsdoconfalsuc.out"; 
	--TRACE ON;
	--------------------------------------------------------------------

	BEGIN
		ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET v_sCodRet = iSqlErr;
			IF v_iTransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			RETURN v_sCodRet;
		END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET v_iTransaccion = 1;
		END EXCEPTION WITH resume;
		
		IF v_iTransaccion = 1 THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			BEGIN WORK;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		
		SELECT numsucursal INTO v_sSucFaltante
		FROM bdirech:"informix".rec_confaltante WHERE numempleado = p_sNumEmpleado AND idfaltante = p_iIdFaltante;
		
				--// Valida parámetros de entrada
		IF NVL(p_sNumEmpleado, '') = '' OR NVL(v_sSucFaltante, '') = '' OR NVL(p_iIdFaltante, '') = '' OR NVL(p_mDescuento, '') = ''
		OR NVL(p_dFecha, '') = '' THEN
			LET v_sCodRet = '00055';
			RETURN v_sCodRet;
		END IF
		
		SELECT saldoactual, referencia, auxiliar INTO v_mSaldoActual, v_sReferencia, v_sAuxiliar FROM bdirech:"informix".rec_confaltante
		WHERE numempleado = p_sNumEmpleado AND idfaltante = p_iIdFaltante;
		
		IF v_mSaldoActual IS NULL THEN
			LET v_sCodRet = '00053';			
		ELIF v_mSaldoActual > p_mDescuento THEN				
			UPDATE bdirech:"informix".rec_confaltante 
			SET desccalculado = p_mDescuento, descacumulado = descacumulado + p_mDescuento, saldoactual = saldoactual - p_mDescuento
			WHERE numempleado = p_sNumEmpleado AND idfaltante = p_iIdFaltante;
			LET v_sCodRet = '00000';
			
		ELIF v_mSaldoActual = p_mDescuento THEN				
			UPDATE bdirech:"informix".rec_confaltante 
			SET desccalculado = p_mDescuento, descacumulado = descacumulado + p_mDescuento, 
			saldoactual = 0, fechaliquida = p_dFecha, idestatus = 5 --Liquidado
			WHERE numempleado = p_sNumEmpleado AND idfaltante = p_iIdFaltante;			
			LET v_sCodRet = '00000';
			
		ELSE
			LET v_sCodRet = '00051';
		END IF
		
		IF v_sCodRet = '00000' THEN
		
			SELECT NVL(MAX(idmovimiento), 0) + 1 INTO v_iIdMovimiento FROM bdirech:"informix".rec_movfaltante
			WHERE numempleado = p_sNumEmpleado AND idfaltante = p_iIdFaltante AND tipomovimiento IN ('A','R','F','D');
			
			INSERT INTO bdirech:"informix".rec_movfaltante 
			(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento, auxiliar, idrecupera, montomovimiento, 
			fecharegistro, contable, usuarioautoriza, referencia, foliosuc, sucursalpago)
			VALUES (p_sNumEmpleado, v_sSucFaltante, p_iIdFaltante, p_sTransaccion, v_iIdMovimiento, 'A', v_sAuxiliar, '1', p_mDescuento,
			p_dFecha, '0', p_sUsuarioAutoriza, v_sReferencia, p_sFolioSucursal,p_sNumSucursal);
			
			IF v_iTransaccion = 1 THEN
				COMMIT WORK;
				BEGIN WORK;
			ELSE
				COMMIT WORK;
			END IF;
		ELSE
			IF v_iTransaccion = 1 THEN
				COMMIT WORK;
				BEGIN WORK;
			ELSE
				COMMIT WORK;
			END IF;
		END IF
			
		RETURN v_sCodRet;
	END
END PROCEDURE
