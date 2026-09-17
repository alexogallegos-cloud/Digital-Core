create procedure "informix".sp_plan_pausa_evalua_pago_cliente(
	p_num_credito char(20), p_dt_fecha_corte_inicial date, p_dt_fecha_corte_final date
)

returning char(6), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2);
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE vsqlerr					    INTEGER;
DEFINE v_cod_ret				    CHAR(6);
DEFINE ISAM_ERR             INTEGER;
DEFINE c_descqlerr			CHAR(20);
DEFINE icont	smallint;
define d_pagos_realizados			DECIMAL(18,2);
define d_pagos_realizados_aux		DECIMAL(18,2);
define dPorcentajePago				DECIMAL(18,2);
DEFINE d_pago_minimo	   		  	DECIMAL(18,2);
define dt_fecha		date;
define dt_fecha_aux date;
define i_periodo_evaluado	        INTEGER;
DEFINE d_porcentaje_minimo_pago     DECIMAL(4,2);
DEFINE d_porcentaje_maximo_pago     DECIMAL(4,2);
define i_pagos_apenitas				SMALLINT;
define d_suma_ult_6_pagos_minimo DECIMAL(18,2);
define d_suma_ult_6_pagos_realizado DECIMAL(18,2);
define d_interes_pagado DECIMAL(18,2);
define d_suma_interes_pagado DECIMAL(18,2);
define d_pagominimo_masreciente DECIMAL(18,2);
DEFINE i_num_vencidos 			SMALLINT;

let icont = 0;
LET i_periodo_evaluado 			= 0;
let dPorcentajePago				= 0;
let d_porcentaje_minimo_pago    = 1.00;
let d_porcentaje_maximo_pago    = 1.05;
let i_pagos_apenitas			= 0;
let d_suma_ult_6_pagos_minimo = -6;  --darA -1 en return si no se generan datos
let d_suma_ult_6_pagos_realizado = -6;
let d_suma_interes_pagado = -6;
let d_pagominimo_masreciente = -1;

begin
	-- ****************************************************************************
	-- *                        CONTROL DE ERRORES                                *
	-- ****************************************************************************
	ON EXCEPTION SET vsqlerr, ISAM_ERR, c_descqlerr
		LET vsqlerr  = vsqlerr;
		LET c_descqlerr  = c_descqlerr;
    IF vsqlerr != 0 then
    	LET v_cod_ret = vsqlerr || ' - ' ||ISAM_ERR || ' - ' || trim(c_descqlerr);
        RETURN vsqlerr, 0, 0, 0, 0;
    END IF;
    END EXCEPTION;

	Let icont = 0;

	ForEach
	select monto_pagos, pago_minimo, fecha, num_vencidos
	INTO d_pagos_realizados, d_pago_minimo, dt_fecha , i_num_vencidos
	from bdicred:sd_indicador_cred_hist
	where empresa = '001' --and fecha = dt_fecha_corte_evaluado 
	and fecha >= (p_dt_fecha_corte_inicial - 1 units month)::date --el 12avo pago minimo a evaluar es el mes 13 hacia atrAs
	and fecha <= p_dt_fecha_corte_final
	and num_credito = p_num_credito
	
	Order by fecha desc

		if day(dt_fecha) <> day (p_dt_fecha_corte_inicial) then -- la tabla indicadores tambien tiene corte fin de mes
			continue foreach;
		end if;
		
		let icont = icont + 1;

		if i_num_vencidos > 1 then

			LET i_pagos_apenitas = 0;

			exit foreach;
			
		end if;

		If dt_fecha = p_dt_fecha_corte_final THEN		
			let d_pagominimo_masreciente = nvl(d_pago_minimo,0);
			let d_pagos_realizados_aux = nvl(d_pagos_realizados,0);
			let dt_fecha_aux = dt_fecha;
			let d_suma_ult_6_pagos_realizado = d_pagos_realizados_aux;
			continue foreach;
		end if;

		If dt_fecha = (dt_fecha_aux - 1 units month)::date THEN -- validar que los cortes en indicadores estÃ¡n secuenciados
			LET i_periodo_evaluado = i_periodo_evaluado + 1;
			if nvl(d_pago_minimo,0) > 0 then
				let dPorcentajePago = nvl(d_pagos_realizados_aux,0) / d_pago_minimo;
				if dPorcentajePago >= d_porcentaje_minimo_pago and dPorcentajePago <= d_porcentaje_maximo_pago then 
					let i_pagos_apenitas = i_pagos_apenitas + 1;
				end if;
			end if;
			if icont <= 6 then
				let d_suma_ult_6_pagos_realizado = d_suma_ult_6_pagos_realizado + nvl(d_pagos_realizados,0);
			end if;
			if icont <= 7 then  -- sumarA 6, pues el primero del ciclo no se guarda, correspone al pago minimo mas reciente y se compara vs el pago realizado al prOximo corte, se cuenta del 2do pago minimo hacia atras que se compara con el pagorealizado mas reciente
				let d_suma_ult_6_pagos_minimo = d_suma_ult_6_pagos_minimo + nvl(d_pago_minimo,0);
			end if;
			
		end if;
		
	   -- Se requiere almacenar por lo menos 6 pagos para calcular el saldo y pagos promedio
		if i_pagos_apenitas >= 2 AND i_periodo_evaluado >= 6 then
			exit foreach;
		--else 
		--	let dt_fecha_corte_evaluado = dt_fecha_corte_evaluado - 1 units month;
		end if;	

		let d_pagos_realizados_aux = d_pagos_realizados;
		let dt_fecha_aux = dt_fecha;
	
	End foreach;
	
  	if i_pagos_apenitas >= 2 then
   		let v_cod_ret = "000001"; -- TIENE MAS DE 2 PAGOS MINIMOS DURANTE LOS ULTIMOS 12 MESES
		let icont = 1;
		Let dt_fecha_aux = p_dt_fecha_corte_final - 1 units month;
		--se toma el interes pagado de los pagos minimos evaluados, que empiezan el corte anterior al corte mas reciente
		let d_suma_interes_pagado = 0;
		while icont <=6
			
			SELECT interes_pagado
			INTO d_interes_pagado
			FROM sd_amortiza_credito
			WHERE empresa = '001'
			AND num_credito = p_num_credito
			AND fecha_cuota = dt_fecha_aux;
			
			let d_suma_interes_pagado = d_suma_interes_pagado + nvl(d_interes_pagado,0);
			Let dt_fecha_aux = p_dt_fecha_corte_final - 1 units month;
			let icont = icont + 1;
		end while;
		LET d_suma_ult_6_pagos_minimo = d_suma_ult_6_pagos_minimo / 6;
		LET d_suma_ult_6_pagos_realizado = d_suma_ult_6_pagos_realizado / 6;
		LET d_suma_interes_pagado = d_suma_interes_pagado / 6;
    else
		let v_cod_ret = "000000";
	end if;

	return v_cod_ret, d_pagominimo_masreciente, d_suma_ult_6_pagos_minimo, d_suma_ult_6_pagos_realizado, d_suma_interes_pagado;

end;
end procedure;