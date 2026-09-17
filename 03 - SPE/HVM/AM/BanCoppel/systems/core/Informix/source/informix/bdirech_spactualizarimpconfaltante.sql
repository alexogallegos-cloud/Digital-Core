CREATE PROCEDURE "informix".spactualizarimpconfaltante (p_sNumEmpleado CHAR(8), p_sNumSucursal CHAR(4), p_iIdFaltante SMALLINT, p_mDescuento MONEY(10,0))
RETURNING CHAR(5) AS CodigoRetorno

    DEFINE iSqlErr          INTEGER;

    DEFINE v_sCodRet        CHAR(5);
    DEFINE v_mSaldoActual   MONEY(10,0);
    DEFINE v_mDescCalculado MONEY(10,0);
	DEFINE v_iIdRecupera 	SMALLINT;
	DEFINE v_iIdEstatus		SMALLINT;
    DEFINE v_mDifDescuento  MONEY(10,0);
	DEFINE v_sAuxiliar		CHAR(12);
	DEFINE v_dFechaQuincena DATE;

    --SET DEBUG FILE TO  "/tmp/vladi/spactualizarimpconfaltante.out"; 
    --TRACE ON;

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                INSERT INTO bdirech:rec_errores(descripcion) VALUES ('saicf '||iSqlErr);
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;

        --// Valida parámetros de entrada
        IF NVL(p_sNumEmpleado, '') = '' OR NVL(p_sNumSucursal, '') = '' OR NVL(p_iIdFaltante, '') = '' OR NVL(p_mDescuento, '') = '' THEN
            LET v_sCodRet = '00001';
            RETURN v_sCodRet;
        END IF

        SELECT saldoactual, desccalculado, idrecupera, idestatus INTO v_mSaldoActual, v_mDescCalculado, v_iIdRecupera, v_iIdEstatus 
		FROM bdirech:rec_confaltante
        WHERE numempleado = p_sNumEmpleado AND numsucursal = p_sNumSucursal AND idfaltante = p_iIdFaltante;
		
        IF v_mSaldoActual IS NOT NULL THEN
            IF v_mSaldoActual >= p_mDescuento THEN 
                --Calcula la diferencia, tomando en cuenta que el descuento puede ser mayor o menor al calculado.
				LET v_mDifDescuento = p_mDescuento - v_mDescCalculado; 

                UPDATE bdirech:rec_confaltante SET desccalculado = p_mDescuento
                WHERE numempleado = p_sNumEmpleado AND numsucursal = p_sNumSucursal AND idfaltante = p_iIdFaltante;
				
				--Valida para asegurar que es un descuento por nómina.
				IF v_mSaldoActual > 0 AND v_iIdRecupera = 2 AND (v_iIdEstatus = 1 OR v_iIdEstatus = 2) THEN 
					IF EXISTS(SELECT numempleado FROM bdirech:rec_descquincena WHERE numempleado = p_sNumEmpleado) THEN
						--Actualiza el descuento calculado sumando la diferencia (-,+)
						UPDATE bdirech:rec_descquincena SET desccalculado = desccalculado + v_mDifDescuento 
						WHERE numempleado = p_sNumEmpleado;
					ELSE
						--Inserta los empleados nuevos que no tienen sueldo en el caso de generar un descuento.
						LET v_sAuxiliar = p_sNumSucursal || p_sNumEmpleado;
						SELECT valor INTO v_dFechaQuincena FROM bdirech:rec_param WHERE secuencia = 1;
						
						INSERT INTO bdirech:rec_descquincena (numempleado, numsucursal, auxiliar, fechadesc, sueldoquincena, desccalculado, descaplicado) 
						VALUES (p_sNumEmpleado, p_sNumSucursal, v_sAuxiliar, v_dFechaQuincena, 0, p_mDescuento, 0);
					END IF
				END IF
				
                LET v_sCodRet = '00000';
            ELSE
                LET v_sCodRet = '00002';
            END IF
        ELSE
            LET v_sCodRet = '00003';
        END IF;

        RETURN v_sCodRet;
    END
END PROCEDURE
