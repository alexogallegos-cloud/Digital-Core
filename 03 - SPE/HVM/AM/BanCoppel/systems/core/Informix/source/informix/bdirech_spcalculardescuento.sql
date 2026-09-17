CREATE PROCEDURE "informix".spcalculardescuento (p_dFechaQuincena DATE)
RETURNING CHAR(5) AS retorno;

DEFINE sql_err              INTEGER;
DEFINE v_sCodRet            CHAR(5);
DEFINE v_iSueldoMinimo		SMALLINT;
DEFINE v_iContFaltante      SMALLINT;
DEFINE v_iContPorcentaje    SMALLINT;
DEFINE v_mPorcentaje        MONEY(10,0);
DEFINE v_sNumSucursal       CHAR(4);
DEFINE v_iIdFaltante        SMALLINT;
DEFINE v_mDiferencia        MONEY(10,0);
DEFINE v_mDescEmpleado      MONEY(10,0);
DEFINE v_sNumEmpAux         CHAR(8);
DEFINE v_sNumEmpleado       CHAR(8);
DEFINE v_mSaldoActual       MONEY(10,0);
DEFINE v_dFechaRegistro     DATE;
DEFINE v_mSueldoQuincena    MONEY(10,0);
DEFINE v_mDescMaximo		MONEY(10,0);
DEFINE v_mDescCalculado     MONEY(10,0);
DEFINE v_mDescQuincenaFijo	MONEY(10,0);
DEFINE v_sEstatus           CHAR(2);
DEFINE v_iErrores           INTEGER;

 --****************************************************************
 --SET DEBUG FILE TO "/dbexport/Fabiola/out/spcalculardescuento.out";
 --TRACE ON;                                                      
 --****************************************************************

 SET LOCK MODE TO WAIT 3;
BEGIN
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            INSERT INTO bdirech:"informix".rec_errores(descripcion) VALUES ('scd '||sql_err);
            LET v_sCodRet = sql_err;
            RETURN v_sCodRet;
        END IF;
    END EXCEPTION;

    IF NVL(p_dFechaQuincena, '') = '' THEN
        LET v_sCodRet = '00001';
        RETURN v_sCodRet;
    END IF;

    LET v_sCodRet = '00002';
    LET v_iContFaltante = 0;
	LET v_iContPorcentaje = 0;
	LET v_mDiferencia = 0;
    LET v_sNumEmpAux = '99999999';
    LET v_mDescEmpleado = 0;

    --Proceso de Actualización de Empleados.
    EXECUTE PROCEDURE bdirech:"informix".spvalidarprocesos (p_dFechaQuincena,'2') INTO v_sCodRet, v_sEstatus, v_iErrores;

    IF v_sEstatus = '1' AND v_iErrores = 0 THEN
        --Proceso de Cálculo de descuento.
        EXECUTE PROCEDURE bdirech:"informix".spvalidarprocesos (p_dFechaQuincena,'3') INTO v_sCodRet, v_sEstatus, v_iErrores;

        LET v_sCodRet = '00002';
        IF v_sEstatus = '0' AND v_iErrores = 0 THEN
			
			SELECT TRIM(valor) INTO v_iSueldoMinimo FROM bdirech:"informix".rec_param WHERE secuencia = 7; --Se obtiene el sueldo minimo
            FOREACH
                SELECT numempleado, numsucursal, idfaltante, saldoactual, fecharegistro, descquincenafijo 
                INTO v_sNumEmpleado, v_sNumSucursal, v_iIdFaltante, v_mSaldoActual, v_dFechaRegistro, v_mDescQuincenaFijo
				FROM bdirech:"informix".rec_confaltante
                WHERE saldoactual > 0 AND idrecupera IN (2,6) AND idestatus IN(1,2) AND idconcepto IN (1,2) 
				ORDER BY numempleado ASC, descquincenafijo DESC, fecharegistro ASC
                -- idrecupera = 2 Nómina y Nómina Fijo, idestatus (1,2) Pendiete x aplicar y Aplicado, idconcepto (1,2) Faltantes y Daños a mobiliario y equipo			
				
				IF v_sNumEmpAux <> v_sNumEmpleado THEN						
					-- Para no actualizar un empleado que no existe.
                    IF v_mDescEmpleado > 0 THEN
                        --Actualiza el empleado anterior leido con el descuento acumulado de todos sus faltantes.
                        UPDATE bdirech:"informix".rec_descquincena SET desccalculado = v_mDescEmpleado
                        WHERE numempleado = v_sNumEmpAux;
                        LET v_mDescEmpleado = 0;						
                    END IF
					--Obtiene el sueldo por empleado					
                    SELECT sueldoquincena INTO v_mSueldoQuincena FROM bdirech:"informix".rec_descquincena WHERE numempleado = v_sNumEmpleado;                
                    LET v_mSueldoQuincena = NVL(v_mSueldoQuincena,0);
                    LET v_mDiferencia = 0;
                    LET v_sNumEmpAux = v_sNumEmpleado; -- Asigna nuevo número de empleado leido.
                    LET v_iContFaltante = 1;
					LET v_mDescMaximo = v_mSueldoQuincena - v_iSueldoMinimo; --Se calcula el maximo del descuento por empleado
					
					IF v_mDescQuincenaFijo = 0 THEN --Valida el descuento quincenal fijo para incrementar o no el contador de porcentaje
						LET v_iContPorcentaje = 1;
					ELSE
						LET v_iContPorcentaje = 0;
					END IF;					
				ELSE
					LET v_iContFaltante = v_iContFaltante + 1;
					
					IF v_mDescQuincenaFijo = 0 THEN
						LET v_iContPorcentaje = v_iContPorcentaje + 1;
					END IF;					
                END IF

                IF v_iContFaltante < 6 AND (v_mDescMaximo > v_mDescEmpleado) THEN -- valida que el empleado solo se descuenten hasta 5 faltantes.				
					IF v_mDescQuincenaFijo = 0 THEN
						SELECT porcentaje INTO v_mPorcentaje FROM bdirech:"informix".rec_porcentajes WHERE numfaltantes = v_iContPorcentaje;
						-- Se calcula el descuento con el sueldo y el porcentaje segun el número de faltante mas la diferencia sobrante de otros faltantes.
						LET v_mDescCalculado = ((v_mSueldoQuincena * v_mPorcentaje)/100) + v_mDiferencia;
					ELSE
						LET v_mDescCalculado = v_mDescQuincenaFijo;
					END IF

					IF v_mDescCalculado > v_mSaldoActual THEN
						LET v_mDiferencia = v_mDescCalculado - v_mSaldoActual; --Acumulo la diferencia
						LET v_mDescCalculado = v_mSaldoActual;
					END IF
					
					IF (v_mDescMaximo - v_mDescEmpleado) < v_mDescCalculado THEN					
						LET v_mDescCalculado = v_mDescMaximo - v_mDescEmpleado;
					END IF
					
					-- Se acumula el descuento por empleado
					LET v_mDescEmpleado = v_mDescEmpleado + v_mDescCalculado;										
					-- Se actualiza el descuento calculado por faltante.
					UPDATE bdirech:"informix".rec_confaltante SET desccalculado = v_mDescCalculado
					WHERE numempleado = v_sNumEmpleado AND numsucursal = v_sNumSucursal AND idfaltante = v_iIdFaltante;
					
                END IF

                LET v_sCodRet = '00000';
            END FOREACH;

            IF v_sCodRet = '00000' THEN
                -- Actualiza el descuento calculado del ultimo empleado leido.
                UPDATE bdirech:"informix".rec_descquincena SET desccalculado = v_mDescEmpleado
                WHERE numempleado = v_sNumEmpleado;

                UPDATE bdirech:"informix".rec_procesos SET estatus = '1'
                WHERE fechaproceso = p_dFechaQuincena AND idprocesos = 3; --Proceso de cálculo de descuento.
            END IF 
        ELSE
            LET v_sCodRet = '00003';
        END IF
	ELSE
		LET v_sCodRet = '00002';
    END IF 
    RETURN v_sCodRet;
    END;
END PROCEDURE 

