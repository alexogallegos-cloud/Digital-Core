CREATE PROCEDURE "informix".activa_procesos (pempresa char(3),pcodigo_plan smallint)
	RETURNING CHAR(3);


	DEFINE cod_ret         CHAR(3);
	DEFINE sql_err         INTEGER;

	DEFINE v_fechahoy      DATE;


	DEFINE v_fecha_ejecut		CHAR(20);
	DEFINE v_activa_proceso		BOOLEAN;

	DEFINE v_empresa			CHAR(3);
	DEFINE v_codigo_plan		SMALLINT;
	DEFINE v_sistema			CHAR(2);
	DEFINE v_codigo_proceso		SMALLINT;

	--SET DEBUG FILE TO "activa_procesos.out";
--	TRACE ON;

	  BEGIN

		ON EXCEPTION SET sql_err
		    IF sql_err <> 0 THEN
		        LET cod_ret = sql_err;
		        RETURN cod_ret;
		    END IF
		END EXCEPTION;

		LET cod_ret = "000";

		FOREACH SELECT fecha_ejecut,empresa,codigo_plan,sistema,codigo_proceso
		    	INTO v_fecha_ejecut,v_empresa,v_codigo_plan,v_sistema,v_codigo_proceso
		      	FROM sx_plejec_det
				WHERE empresa = pempresa
					AND codigo_plan = pcodigo_plan
					AND NOT fecha_ejecut IS NULL


				SELECT fecha_hoy = CASE v_fecha_ejecut
				       		WHEN 'fecha_ant' 	THEN fecha_ant
				       		WHEN 'prox_fecha' 	THEN prox_fecha
				       		WHEN 'pri_dia_mes' 	THEN pri_dia_mes
				       		WHEN 'pri_hab_mes' 	THEN pri_hab_mes
				       		WHEN 'ult_dia_mes' 	THEN ult_dia_mes
					   		WHEN 'ult_hab_mes' 	THEN ult_hab_mes
					   END
				INTO v_activa_proceso
                FROM  si_fechas
                	WHERE empresa = pempresa;


				IF v_activa_proceso = "t" THEN
					UPDATE sx_plejec_det SET activa_proceso = "1"
						WHERE empresa = v_empresa
								AND codigo_plan =v_codigo_plan
								AND sistema =v_sistema
								AND codigo_proceso =v_codigo_proceso;
				ELSE
					UPDATE sx_plejec_det SET activa_proceso = "0"
						WHERE empresa = v_empresa
								AND codigo_plan =v_codigo_plan
								AND sistema =v_sistema
								AND codigo_proceso =v_codigo_proceso;
				END IF

		END FOREACH;

	  END;

	RETURN cod_ret;

END PROCEDURE ;