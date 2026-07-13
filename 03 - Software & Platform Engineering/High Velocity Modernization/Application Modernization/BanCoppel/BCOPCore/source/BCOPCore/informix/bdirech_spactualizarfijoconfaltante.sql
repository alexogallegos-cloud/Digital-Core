CREATE PROCEDURE "informix".spactualizarfijoconfaltante (p_mSueldoQuincena MONEY(16,2), p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_iIdFaltante SMALLINT,
p_dFechaAsignacion DATE, p_iIdAsignado SMALLINT, p_mDescQuincenaFijo MONEY (10,0), p_sUsuarioAutoriza CHAR(8))
RETURNING CHAR(5) AS CodigoRetorno, MONEY(10,0) AS MaximoDescuento

DEFINE iSqlErr				INTEGER;
DEFINE v_sCodRet			CHAR(5);
DEFINE v_mMaxDescuento		MONEY(10,0);

DEFINE v_iIdConcepto		SMALLINT;
DEFINE v_iIdAsignado		SMALLINT;
DEFINE v_iIdEstatus			SMALLINT;
DEFINE v_sReferencia		CHAR(26);
DEFINE v_iIdRecupera		SMALLINT;
DEFINE v_sAuxiliar			CHAR(12);
DEFINE v_iIdMovimiento		SMALLINT;

DEFINE v_iSueldoMinimo		MONEY(10,0);
DEFINE v_mDescMaximo		MONEY(10,0);
DEFINE v_dFechaQuincena		DATE;
DEFINE v_sAnio				CHAR(4);
DEFINE v_sMes				CHAR(2);
DEFINE v_iDia				SMALLINT;
DEFINE v_dFechaQuincenaProx	DATE;
DEFINE v_sEstatusCalculo	CHAR(1);
DEFINE v_iIdFaltante		SMALLINT;
DEFINE v_mMontoEntero		MONEY(10,0);
DEFINE v_mMontoCentavos		MONEY(10,2);
DEFINE v_mSaldoActual		MONEY(16,2);
DEFINE v_mDescQuinFijo		MONEY(10,0);
DEFINE v_iContador			SMALLINT;
DEFINE v_mDescCalculado		MONEY(10,0);
DEFINE v_mDescCalculadoEmp	MONEY(10,0);
DEFINE v_iContadorPorc		SMALLINT;
DEFINE v_mPorcentaje		MONEY(5,2); 
DEFINE v_sBandera			CHAR(1);
DEFINE v_mDiferencia		MONEY(10,0);
DEFINE v_sEstatusTransArch	CHAR(1);

    --SET DEBUG FILE TO  "/tmp/spactualizarfijoconfaltante.trc";
    --TRACE ON;
    SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			INSERT INTO bdirech:"informix".rec_errores(descripcion) VALUES ('safcf '||iSqlErr);
			LET v_sCodRet = iSqlErr;
			RETURN v_sCodRet, 0;
		END IF;
	END EXCEPTION;
	
	--//Valida parámetros de entrada
	IF NVL(p_mSueldoQuincena, '') = '' OR NVL(p_sNumEmpleado, '') = '' OR NVL(p_sNumSucursal, '') = '' OR NVL(p_iIdFaltante, '') = ''
		OR NVL(p_dFechaAsignacion, '') = '' OR NVL(p_iIdAsignado, '') = '' OR NVL(p_mDescQuincenaFijo, '') = ''  OR NVL(p_sUsuarioAutoriza, '') = '' THEN		
		LET v_sCodRet = '00006';
		RETURN v_sCodRet, 0;
	END IF;
			
	LET v_mMaxDescuento = 0;
	
	IF p_mSueldoQuincena > 0 THEN --Existe el empleado y tiene movimientos para realizar el calcúlo (Empleado Normal).		
		LET v_iContador = 0;
		LET v_iContadorPorc = 0;
		LET v_mDiferencia = 0;
		LET v_sBandera = 0;		
		LET v_mDescCalculado = 0;
		LET v_sAuxiliar = p_sNumSucursal || p_sNumEmpleado;		
		
		SELECT TRIM(valor) INTO v_iSueldoMinimo FROM bdirech:"informix".rec_param WHERE secuencia = 7; --Se obtiene el sueldo minimo
		LET v_mDescMaximo = p_mSueldoQuincena - v_iSueldoMinimo; --Se calcula el maximo del descuento al empleado
		
		SELECT valor INTO v_dFechaQuincena FROM bdirech:"informix".rec_param WHERE secuencia = 1;
		LET v_sAnio = YEAR (p_dFechaAsignacion);
		LET v_sMes = MONTH (p_dFechaAsignacion);
		
		IF DAY(p_dFechaAsignacion) > 15 THEN
			IF MONTH(p_dFechaAsignacion) <> 2 THEN
				LET v_dFechaQuincenaProx = MDY(v_sMes, 30, v_sAnio);
			ELSE
				EXECUTE PROCEDURE bdicont:"informix".diasmes(v_sAnio,v_sMes) INTO v_iDia;
				LET v_dFechaQuincenaProx = MDY(v_sMes, v_iDia, v_sAnio);
			END IF
		ELSE
			LET v_dFechaQuincenaProx = MDY(v_sMes, 15, v_sAnio);
		END IF;
		
		IF v_dFechaQuincenaProx >= v_dFechaQuincena THEN
			SELECT estatus INTO v_sEstatusCalculo FROM bdirech:"informix".rec_procesos WHERE idprocesos = 3 AND fechaproceso = v_dFechaQuincenaProx;
			IF v_sEstatusCalculo = 0 OR v_sEstatusCalculo IS NULL THEN --No se ha generado el calculo del descuento
				FOREACH					 
					SELECT idfaltante, ROUND(saldoactual,0), descquincenafijo INTO v_iIdFaltante, v_mSaldoActual, v_mDescQuinFijo
					FROM bdirech:"informix".rec_confaltante
					WHERE (saldoactual > 0 AND idrecupera IN(2,6) AND idestatus IN(1,2) AND idconcepto IN(1,2) AND numempleado = p_sNumEmpleado)
					OR (idfaltante = p_iIdFaltante AND numempleado = p_sNumEmpleado)
					ORDER BY numempleado ASC, descquincenafijo DESC, fecharegistro ASC
					-- idrecupera = 1 sucursal, idestatus (1,2) Pendiete x aplicar y Aplicado, idconcepto (1,2) Faltantes y Daños a mobiliario y equipo
					
					IF v_iContador < 6 THEN -- valida que el empleado solo se descuenten hasta 5 faltantes.	
						IF v_iIdFaltante <> p_iIdFaltante THEN
							IF v_mDescQuinFijo > 0 THEN
								LET v_iContador = v_iContador + 1;
								LET v_mDescCalculado = v_mDescQuinFijo;
							ELSE
								LET v_iContador = v_iContador + 1;
								LET v_iContadorPorc = v_iContadorPorc + 1;
								SELECT porcentaje INTO v_mPorcentaje FROM bdirech:"informix".rec_porcentajes WHERE numfaltantes = v_iContadorPorc;
								LET v_mDescCalculado = ((p_mSueldoQuincena * v_mPorcentaje)/100) + v_mDiferencia;
							END IF;
						ELSE
							LET v_iContador = v_iContador + 1;
							LET v_mDescCalculado = p_mDescQuincenaFijo;
							LET v_sBandera = 1;
						END IF;
						
						IF v_mDescCalculado > v_mSaldoActual THEN
							LET v_mDiferencia = v_mDescCalculado - v_mSaldoActual; --Acumulo la diferencia
							LET v_mDescCalculado = v_mSaldoActual;
						END IF;
						
						IF v_mDescMaximo >= v_mDescCalculado THEN
							LET v_mDescMaximo = v_mDescMaximo - v_mDescCalculado;
						ELSE							
							LET v_mMaxDescuento = v_mDescMaximo;
							LET v_mDescMaximo = 0;
						END IF
					ELSE
						LET v_mMaxDescuento = 0;
					END IF
				END FOREACH	
				IF v_sBandera = 1 THEN
					LET v_sCodRet = '00000';					
				ELSE
					LET v_sCodRet = '00003';					
				END IF
			ELSE --Ya se genero el calcúlo del descuento
				
				SELECT desccalculado INTO v_mDescCalculadoEmp FROM bdirech:"informix".rec_descquincena WHERE numempleado = p_sNumEmpleado;
				IF v_mDescCalculadoEmp IS NULL THEN
					LET v_mDescCalculadoEmp = 0;
				END IF;
				IF v_mDescMaximo >= v_mDescCalculadoEmp THEN
					IF (v_mDescMaximo - v_mDescCalculadoEmp) >= p_mDescQuincenaFijo THEN
						LET v_sCodRet = '00000';
						LET v_mDescCalculado = p_mDescQuincenaFijo;
					ELSE
						LET v_mMaxDescuento = v_mDescMaximo - v_mDescCalculadoEmp;
						LET v_sCodRet = '00003';
					END IF
				ELSE
					LET v_mMaxDescuento = 0;
					LET v_sCodRet = '00003';
				END IF
				
				SELECT estatus INTO v_sEstatusTransArch FROM bdirech:"informix".rec_procesos WHERE idprocesos = 4 AND fechaproceso = v_dFechaQuincenaProx;
				IF v_sCodRet = '00000' THEN
					IF v_sEstatusTransArch = 1 THEN --ya se realizó la transferencia del archivo.									
						LET v_sCodRet = '00004';					
					ELIF v_sEstatusTransArch = 0 THEN
						IF EXISTS (SELECT * FROM bdirech:"informix".rec_descquincena WHERE numempleado = p_sNumEmpleado) THEN
							UPDATE bdirech:"informix".rec_descquincena SET desccalculado = (desccalculado + p_mDescQuincenaFijo)WHERE numempleado = p_sNumEmpleado;
						ELSE
							INSERT INTO bdirech:"informix".rec_descquincena (numempleado, numsucursal, auxiliar, fechadesc, sueldoquincena, desccalculado,
							descaplicado)
							VALUES (p_sNumEmpleado, p_sNumSucursal, v_sAuxiliar, v_dFechaQuincenaProx, p_mSueldoQuincena, p_mDescQuincenaFijo, 0);
						END IF;
						
						UPDATE bdirech:"informix".rec_cifrascontrol SET cifracalculada = (cifracalculada + p_mDescQuincenaFijo) 
						WHERE fechaquincena = v_dFechaQuincenaProx;
					END IF				
				END IF
			END IF
		ELSE
			LET v_sCodRet = '00005'; --ERROR EXISTE DESCUADRE EN LOS DATOS
		END IF
		
	ELIF p_mSueldoQuincena = 0 THEN --Existe el empleado pero no tiene movimientos (Empleado Nuevo).
		LET v_sCodRet = '00001';
	ELSE --No existe el empleado o con movimientos de baja (Empleado Baja).
		LET v_sCodRet = '00002';		
		UPDATE bdirech:"informix".rec_confaltante SET idestatus = 3 WHERE numempleado = p_sNumEmpleado;
	END IF				
	
	IF v_sCodRet = '00000' OR v_sCodRet = '00004' THEN
		SELECT idconcepto, idasignado, idestatus, referencia, (saldoactual)::INTEGER, saldoactual-(saldoactual::INTEGER)
		INTO v_iIdConcepto, v_iIdAsignado, v_iIdEstatus, v_sReferencia, v_mMontoEntero, v_mMontoCentavos
		FROM bdirech:"informix".rec_confaltante
		WHERE numempleado = p_sNumEmpleado AND numsucursal = p_sNumSucursal AND idfaltante = p_iIdFaltante;
		
		IF p_iIdAsignado = v_iIdAsignado OR p_iIdAsignado IN(3,5) OR v_iIdEstatus <> 1 OR v_iIdAsignado IS NULL OR v_iIdConcepto <> 1 OR p_mDescQuincenaFijo <= 0 THEN
			LET v_sCodRet = '00007'; --No se puede actualizar el faltante		           
		ELSE
			
			LET v_iIdRecupera = 6; --Recuperación por Nómina Fijo									
			
			SELECT NVL(MAX(idmovimiento), 0) + 1 INTO v_iIdMovimiento FROM bdirech:"informix".rec_movfaltante
			WHERE numempleado = p_sNumEmpleado AND idfaltante = p_iIdFaltante AND tipomovimiento IN ('A','R','F','D');
			
			IF v_mMontoCentavos > 0 THEN --Valida que existan centavos para generar dos movimientos.				
				--Graba el movimiento fraccionario generado por la reasignación
				INSERT INTO bdirech:"informix".rec_movfaltante(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento, auxiliar,
				idrecupera, montomovimiento, fecharegistro, contable, usuarioautoriza, referencia, sucursalpago)
				VALUES (p_sNumEmpleado, p_sNumSucursal, p_iIdFaltante, '0050', v_iIdMovimiento, 'R', v_sAuxiliar,
				v_iIdRecupera, v_mMontoCentavos, p_dFechaAsignacion, '0', p_sUsuarioAutoriza, v_sReferencia,p_sNumSucursal);			
				
				LET v_iIdMovimiento = v_iIdMovimiento + 1;
			END IF			
			
			--Graba el movimiento entero generado por la reasignación
			INSERT INTO bdirech:"informix".rec_movfaltante(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento, auxiliar,
			idrecupera, montomovimiento, fecharegistro, contable, usuarioautoriza, referencia, sucursalpago)
			VALUES (p_sNumEmpleado, p_sNumSucursal, p_iIdFaltante, '0050', v_iIdMovimiento, 'R', v_sAuxiliar,
			v_iIdRecupera, v_mMontoEntero, p_dFechaAsignacion, '0', p_sUsuarioAutoriza, v_sReferencia, p_sNumSucursal);			
			
			--Actualiza el faltante en el concentrado y el saldo actual e inicial sin centavos
			UPDATE bdirech:"informix".rec_confaltante 
			SET fechaasigna = p_dFechaAsignacion, idrecupera = v_iIdRecupera , idasignado = p_iIdAsignado, idasignadoant = idasignado,
			descquincenafijo = p_mDescQuincenaFijo, saldoinicial = ROUND(saldoinicial,0), saldoactual = ROUND(saldoactual,0), desccalculado = p_mDescQuincenaFijo
			WHERE idfaltante = p_iIdFaltante AND numempleado = p_sNumEmpleado AND numsucursal = p_sNumSucursal;
			
		END IF;	
	END IF
	RETURN v_sCodRet, v_mMaxDescuento;
END
END PROCEDURE
