CREATE PROCEDURE "informix".spgrabarmovfaltante (p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_iIdFaltante SMALLINT, p_sTipoMovimiento CHAR(1), 
p_dFecha DATE, p_iIdRecupera SMALLINT, p_mMontoMovimiento MONEY(10,0), p_sTransaccion CHAR(4), p_sContable CHAR(1),p_sUsuarioAutoriza CHAR(8),
p_sReferencia CHAR(26))
RETURNING CHAR(5) AS CodigoRetorno

	DEFINE iSqlErr          INTEGER;
	DEFINE v_sCodRet        CHAR(5);
	DEFINE v_iIdMovimiento	SMALLINT;
	DEFINE v_sAuxiliar		CHAR(12);

	--------------------------------------------------
	--SET DEBUG FILE TO  "/datos/francisco/spgrabarmovfaltante.out"; 
	--TRACE ON;
	--------------------------------------------------

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				--ROLLBACK WORK;
				RETURN v_sCodRet;
			END IF;
		END EXCEPTION;

		LET v_sCodRet = '00000';
		LET v_iIdMovimiento = 0;
		LET v_sAuxiliar = '';
		
		SET LOCK MODE TO WAIT 3;
		
		--BEGIN WORK;
		--// Valida parámetros de entrada
		IF NVL(p_sNumEmpleado, '') = '' OR NVL(p_sNumSucursal, '') = '' OR NVL(p_iIdFaltante, '') = '' OR NVL(p_sTipoMovimiento, '') = '' 
		OR NVL(p_dFecha, '') = '' OR NVL(p_iIdRecupera, '') = '' OR NVL(p_mMontoMovimiento, '') = '' OR NVL(p_sTransaccion, '') = '' 
		OR NVL(p_sContable, '') = '' OR NVL(p_sReferencia,'') = '' OR NVL(p_sUsuarioAutoriza,'') = '' THEN
			LET v_sCodRet = '00001';
			RETURN v_sCodRet;
		END IF;

		--OBTENER EL IDMOVIMIENTO
		IF p_sTipoMovimiento IN ('A','R','F') THEN
			SELECT NVL(MAX(idmovimiento), 0) + 1 INTO v_iIdMovimiento
			FROM bdirech:"informix".rec_movfaltante
			WHERE numempleado = p_sNumEmpleado AND idfaltante = p_iIdFaltante AND tipomovimiento IN ('A','R','F');

		ELIF p_sTipoMovimiento = 'C' THEN
			LET v_iIdMovimiento = 0;

		ELSE
			LET v_sCodRet = '00001';
			RETURN v_sCodRet;
		END IF;

		IF EXISTS(SELECT numempleado FROM bdirech:"informix".rec_confaltante WHERE numempleado = p_sNumEmpleado AND numsucursal = p_sNumSucursal 
		AND idfaltante = p_iIdFaltante) THEN

			LET v_sAuxiliar = p_sNumSucursal || p_sNumEmpleado;
  
			INSERT INTO bdirech:"informix".rec_movfaltante 
			(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento, auxiliar, idrecupera, 
			montomovimiento, fecharegistro, contable, usuarioautoriza, referencia, sucursalpago)
			VALUES (p_sNumEmpleado, p_sNumSucursal, p_iIdFaltante, p_sTransaccion, v_iIdMovimiento, p_sTipoMovimiento, v_sAuxiliar, p_iIdRecupera,
			p_mMontoMovimiento, p_dFecha, p_sContable, p_sUsuarioAutoriza, p_sReferencia, p_sNumSucursal);
		ELSE
			LET v_sCodRet = '00002';
		END IF;

		--COMMIT WORK;
		RETURN v_sCodRet;
	END
END PROCEDURE
