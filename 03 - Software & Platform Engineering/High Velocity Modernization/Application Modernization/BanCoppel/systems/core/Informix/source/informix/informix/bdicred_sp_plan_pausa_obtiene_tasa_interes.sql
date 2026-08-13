CREATE PROCEDURE "informix".sp_plan_pausa_obtiene_tasa_interes(
	p_monto_abono_6_meses	DECIMAL(18,2), 
	p_interes_debe_6_meses	DECIMAL(18,2), 
	p_pago_minimo_6_meses	DECIMAL(18,2)
)
RETURNING DECIMAL(18,2);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE d_variable_z				DECIMAL(18,2);
DEFINE d_tasa_interes_calculo	DECIMAL(18,2);
DEFINE i_vsqlerr				INTEGER;
DEFINE v_cod_ret				CHAR(5);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET d_variable_z						= 0;
LET d_tasa_interes_calculo			= 0;
LET i_vsqlerr							= 0;
LET v_cod_ret						= "00000";

BEGIN
	-- ****************************************************************************
	-- *                        CONTROL DE ERRORES                                *
	-- ****************************************************************************
	ON EXCEPTION SET i_vsqlerr
    IF i_vsqlerr != 0 THEN
    	LET v_cod_ret = i_vsqlerr;
        RETURN v_cod_ret;
    END IF;
    END EXCEPTION;

	IF (p_pago_minimo_6_meses > 0) AND (p_monto_abono_6_meses >= p_pago_minimo_6_meses) THEN 
   		LET d_variable_z = ( (p_monto_abono_6_meses - p_pago_minimo_6_meses) / p_pago_minimo_6_meses ) * 100;
	ELSE 
		LET d_variable_z = 0;
	END IF;
  
	--Z = ((A-B) / B ) * 100 %  | Porcentaje de pagos extras que ha realizado el cliente
	-- Condiciones de tasa segÃºn los valores de Z y C
	IF d_variable_z = 0 THEN
		IF p_interes_debe_6_meses < 300 THEN
			LET d_tasa_interes_calculo = 5;
		ELIF p_interes_debe_6_meses >= 300 AND p_interes_debe_6_meses < 450 THEN
			LET d_tasa_interes_calculo = 28;
		ELSE
			LET d_tasa_interes_calculo = 35;
		END IF;
	ELIF d_variable_z > 0 AND d_variable_z < 20 THEN
		IF p_interes_debe_6_meses < 300 THEN
			LET d_tasa_interes_calculo = 17;
		ELIF p_interes_debe_6_meses >= 300 AND p_interes_debe_6_meses < 450 THEN
			LET d_tasa_interes_calculo = 33;
		ELSE
			LET d_tasa_interes_calculo = 47;
		END IF;
	ELIF d_variable_z >= 20 AND d_variable_z <= 100 THEN
		IF p_interes_debe_6_meses < 300 THEN
			LET d_tasa_interes_calculo = 21;
		ELIF p_interes_debe_6_meses >= 300 AND p_interes_debe_6_meses < 450 THEN
			LET d_tasa_interes_calculo = 37;
		ELSE
			LET d_tasa_interes_calculo = 49;
		END IF;
	ELIF  d_variable_z > 100 THEN
		IF p_interes_debe_6_meses < 300 THEN
			LET d_tasa_interes_calculo = 19;
		ELIF p_interes_debe_6_meses >= 300 AND p_interes_debe_6_meses < 450 THEN
			LET d_tasa_interes_calculo = 36;
		ELSE
			LET d_tasa_interes_calculo = 31;
		END IF;
	END IF;

   RETURN d_tasa_interes_calculo;
END;
END PROCEDURE;