CREATE PROCEDURE "informix".spactualizarquebrantofaltante (p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_iIdFaltante SMALLINT, p_dFechaAsignacion DATE, 
p_iIdAsignado SMALLINT, p_sUsuarioAutoriza CHAR(8)) RETURNING CHAR(5) AS CodigoRetorno

    DEFINE iSqlErr      	INTEGER;
    DEFINE v_sCodRet        CHAR(5);
    DEFINE v_iIdRecupera    SMALLINT;
	DEFINE v_iIdAsignado	SMALLINT;
    DEFINE v_iIdMovimiento  SMALLINT;
	DEFINE v_iSaldoIni  	MONEY(16,0);
	DEFINE v_mMontoEntero   MONEY(16,0);
	DEFINE v_mMontoCentavos MONEY(2,2);
	DEFINE v_mMontoMov		MONEY(10,0);
    DEFINE v_sAuxiliar      CHAR(12);
    DEFINE v_iIdConcepto      SMALLINT;
	DEFINE v_iIdEstatus 	SMALLINT;
    DEFINE v_cReferencia    CHAR(26);
	DEFINE v_iTotalMov		SMALLINT;


   --SET DEBUG FILE TO  "/tmp/spactualizarquebrantofaltante.trc";
   --TRACE ON;

   SET LOCK MODE TO WAIT 3;
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                INSERT INTO bdirech:"informix".rec_errores(descripcion) VALUES ('saqf '||iSqlErr);
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
		
		--Solo quebrantos
		IF p_iIdAsignado not IN (6) THEN
			LET v_sCodRet = '00002';
		    RETURN v_sCodRet;
        END IF;

        SELECT idrecupera, idasignado, saldoactual, idconcepto, idestatus, referencia, saldoinicial,descacumulado
		INTO v_iIdRecupera, v_iIdAsignado, v_mMontoEntero, v_iIdConcepto, v_iIdEstatus, v_cReferencia,v_iSaldoIni,v_mMontoMov
		FROM bdirech:"informix".rec_confaltante
		WHERE idfaltante = p_iIdFaltante AND numempleado = p_sNumEmpleado AND numsucursal = p_sNumSucursal;

		--Si esta asignado a quebranto, si es diferente de baja 3 y su asignacion es nula
		IF p_iIdAsignado = v_iIdAsignado OR v_iIdEstatus <> 3 OR v_iIdAsignado IS NULL THEN
			LET v_sCodRet = '00002';		           
		ELSE
			
			--LET v_iIdRecupera = 7; --Quebranto
			
			LET v_sAuxiliar = p_sNumSucursal || p_sNumEmpleado;
			
			SELECT NVL(MAX(idmovimiento), 0) + 1 INTO v_iIdMovimiento FROM bdirech:"informix".rec_movfaltante
			WHERE numempleado = p_sNumEmpleado AND idfaltante = p_iIdFaltante AND tipomovimiento IN ('A','R','F','D');
			
						
			--Graba el movimiento del quebranto con la transaccion 0053
			INSERT INTO bdirech:"informix".rec_movfaltante(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento, auxiliar,
			idrecupera, montomovimiento, fecharegistro, contable, usuarioautoriza,referencia,sucursalpago)
			VALUES (p_sNumEmpleado, p_sNumSucursal, p_iIdFaltante, '0053', v_iIdMovimiento, 'R', v_sAuxiliar,
			v_iIdRecupera, v_mMontoEntero, p_dFechaAsignacion, '0', p_sUsuarioAutoriza, v_cReferencia,p_sNumSucursal);
			
			--Actualiza el faltante en el concentrado y el saldo actual e inicial con centavos
			UPDATE bdirech:"informix".rec_confaltante 
			SET fechaliquida = p_dFechaAsignacion, fechaasigna = p_dFechaAsignacion, idrecupera = v_iIdRecupera , idasignado = p_iIdAsignado, idasignadoant = idasignado,saldoactual = 0
			,idestatus = 4
			WHERE idfaltante = p_iIdFaltante AND numempleado = p_sNumEmpleado AND numsucursal = p_sNumSucursal;
			
			
			--Guardamos el historial de quebrantos
			--Total de movimientos
			select NVL(count(montomovimiento),0)
			into v_iTotalMov
			from bdirech:"informix".rec_movfaltante
			where numempleado = p_sNumEmpleado and idfaltante=p_iIdFaltante
			and transaccion in ('0051','0052','0055','0056');	

			If exists(Select * from bdirech:"informix".rec_movquebrantos where numempleado=p_sNumEmpleado and numsucursal=p_sNumSucursal and idfaltante=p_iIdFaltante and auxiliar=v_sAuxiliar) then
				Delete from bdirech:"informix".rec_movquebrantos where numempleado=p_sNumEmpleado and numsucursal=p_sNumSucursal and idfaltante=p_iIdFaltante and auxiliar=v_sAuxiliar;
			End if

			INSERT INTO bdirech:"informix".rec_movquebrantos(numempleado, numsucursal, idfaltante, saldoinicial, saldoactual, transaccion, auxiliar, usuarioautoriza, montotalbonos, numabonos, fechareg, tipoperacion, descripcion)
			VALUES(p_sNumEmpleado, p_sNumSucursal, p_iIdFaltante, v_iSaldoIni, v_mMontoEntero, '0053', v_sAuxiliar, p_sUsuarioAutoriza, v_mMontoMov, v_iTotalMov, today, 'SIF', 'Quebrantado desde el sistema de faltantes SIF');
			
			LET v_sCodRet = '00000';				
			
        END IF;
        RETURN v_sCodRet;
    END
END PROCEDURE
;