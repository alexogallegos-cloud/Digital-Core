CREATE PROCEDURE "informix".sp_incremento_reduccion (pEmpresa CHAR(3),pCredito CHAR(20),p_meses INTEGER,pTotalMovimiento DECIMAL(10,2),tipo CHAR(1),pbc_score DECIMAL(14,2),pNumTran CHAR(4))
   RETURNING CHAR(6),CHAR (100),DECIMAL(10,2);
   
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE vcod_ret				CHAR(10);
DEFINE v_cod_ret			CHAR(6);
DEFINE vsqlerr				INTEGER;
DEFINE v_Mensaje			CHAR(100);
DEFINE v_Mensaje2			CHAR(100);

DEFINE dFechaHoy			DATE;
DEFINE p_fecha_consulta_inc	DATE;
DEFINE v_bcscore			DECIMAL (8,2);
DEFINE v_tipo				CHAR(1);
DEFINE v_numcte				CHAR(20);
DEFINE v_monto				DECIMAL(10,2);
DEFINE VNuevaLinea			DECIMAL(10,2);
DEFINE vlin_anterior		DECIMAL(10,2);
DEFINE v_rango				CHAR(50);
DEFINE v_ajuste_monto		DECIMAL(10,2);
DEFINE p_folio				CHAR(16);
DEFINE v_producto			CHAR(4);
DEFINE v_divisa				CHAR(2);
DEFINE v_sucursal			CHAR(4);
DEFINE v_marca_cincuenta	INTEGER;
DEFINE p_referencia			INTEGER;
DEFINE p_transaccion		CHAR(4);
DEFINE v_descripcion		CHAR(50);
DEFINE v_descripcion2		CHAR(100);
DEFINE no_movimiento		INTEGER;
DEFINE vmax_fecha			DATE;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET vcod_ret				= "000";
LET v_cod_ret				= "000000";
LET vsqlerr					= 0;
LET v_Mensaje 				= "Proceso Exitoso";
LET v_Mensaje2				= "";

LET dFechaHoy				= DATE (1);
LET p_fecha_consulta_inc	= DATE (1);
LET v_bcscore				= 0;
LET v_tipo					= "";
LET v_numcte				= "";
LET v_monto					= 0;
LET VNuevaLinea				= 0;
LET vlin_anterior			= 0;
LET v_rango					= "";
LET v_ajuste_monto			= 0;
LET p_folio					= "";
LET v_producto				= "";
LET v_divisa				= "";
LET v_sucursal				= "";
LET v_marca_cincuenta 		= 0;

LET p_referencia			= 0;
LET p_transaccion			= 0;
LET v_descripcion 			= "";
LET v_descripcion2			= "Transaccion exitosa";
LET no_movimiento			= 0;
LET vmax_fecha				= DATE(1);

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

BEGIN
	ON EXCEPTION SET vsqlerr
	IF vsqlerr != 0 THEN
		LET v_cod_ret=vsqlerr;
		LET v_Mensaje = "";
		LET VNuevaLinea = 0;
		RETURN v_cod_ret,v_Mensaje,VNuevaLinea;	
	END IF;
	END EXCEPTION;   
	
--SET DEBUG FILE TO "/ifxsif01/sp_incremento_reduccion.out";
--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************		
	
		-- OBTIENE LA FECHA DEL DIA
		SELECT fecha_hoy
			INTO dFechaHoy
		FROM "informix".sd_fechas
			WHERE empresa = pEmpresa;			

		--- Se obtiene datos para grabar el movimiento y Se obtiene el monto			
		SELECT 	b.numcte,b.num_producto, b.divisa, b.sucursal,a.monto_otorgado 
			INTO v_numcte,v_producto, v_divisa, v_sucursal,v_monto
		FROM 	bdicred:sd_maecred b, bdicred:sd_maesdos a
		WHERE b.empresa = pEmpresa
			AND a.empresa = b.empresa
			AND b.num_credito = a.num_credito 
			AND b.num_credito = pCredito;
		
			
		IF tipo = 'I' THEN
			
			--- Consulta el credito con el registro mas reciente de la tabla estatus de incrementos y decrementos
			SELECT bc_score,tp_proceso,meses_ina,marca_cincuenta
				INTO v_bcscore,v_tipo,p_meses,v_marca_cincuenta
			FROM "informix".sd_status_incremento_reduccion 
					WHERE empresa = pEmpresa AND num_credito = pCredito;
	
			--- Para casos donde exista un incremento ya no se aplica.
			IF v_tipo = tipo  THEN
				LET v_Mensaje = 'Se aplico Incremento anteriormente';
				RETURN v_cod_ret, v_Mensaje,VNuevaLinea;
			END IF;
	
			--- Se obtiene la nueva linea y transacciÃÂÃÂ³n en base a tabla de parametros.
			SELECT linea,descripcion,codigo_ref,transaccion,folio
				INTO VNuevaLinea,v_rango,p_referencia,p_transaccion,p_folio
			FROM "informix".sd_param_reduccion_linea
				WHERE tp_solicitud  = "T"			 
					AND v_bcscore BETWEEN bc_scoremin AND bc_scoremax			 
					AND tp_parametrico = tipo; 	
					
			---Se validan los montos para que el monto actual no tenga incremento negativo 
			
			IF VNuevaLinea <= v_monto THEN
				LET v_Mensaje = 'La nueva linea es menor al monto actual';
				RETURN v_cod_ret, v_Mensaje,VNuevaLinea;		
			END IF;
		
						
			--- Se obtiene la descripciÃÂÃÂ³n de transacciÃÂÃÂ³n que se manda por el sp cargo_ref_cel
			SELECT descripcion
				INTO v_descripcion
			FROM bdinteg:"informix".si_transacc
				WHERE empresa = pEmpresa
					AND sistema = "06"
					AND numero = pNumTran;				
	
			
			--- Obtiene la diferencia del incremento para realizar la transacciÃÂÃÂ³n de incremento
			LET v_ajuste_monto = VNuevaLinea - v_monto;
			
			IF VNuevaLinea < pTotalMovimiento THEN 
				LET v_descripcion2 = "Rechazo, monto insuficiente";
			END IF;
				
			UPDATE "informix".sd_status_incremento_reduccion 
				SET tp_proceso = tipo, linea_anterior = v_monto, linea_actual = VNuevaLinea, monto_facturacion = pTotalMovimiento, describe_mov = v_descripcion, fecha_actualiza = dFechaHoy,fecha_facturacion = dFechaHoy, descripcion = v_descripcion2
			WHERE empresa = pEmpresa AND num_credito = pCredito;			
						
			
		ELIF tipo = "R" THEN
		
			--- Se obtiene la nueva linea y transacciÃÂÃÂ³n en base a tabla de parametros.
			SELECT linea,descripcion,codigo_ref,transaccion,folio
				INTO VNuevaLinea,v_rango,p_referencia,p_transaccion,p_folio
			FROM "informix".sd_param_reduccion_linea
				WHERE tp_solicitud  = "T"			 
					AND pbc_score BETWEEN bc_scoremin AND bc_scoremax			 
					AND tp_parametrico = tipo;

			--- El bc_score original de la reducciÃÂÃÂ³n se obtiene de la sd_adviser, se envia parametro del sp_reduccion_linea_ina
			LET v_bcscore = pbc_score;
			
			IF VNuevaLinea >= v_monto THEN
				LET v_Mensaje = 'La nueva linea es mayor al monto actual';
				RETURN v_cod_ret, v_Mensaje,VNuevaLinea;		
			END IF;
			
			--- Se obtiene la descripciÃÂÃÂ³n de transacciÃÂÃÂ³n para reducciÃÂÃÂ³n			
			SELECT descripcion
				INTO v_descripcion
			FROM bdinteg:"informix".si_transacc
				WHERE empresa = pEmpresa
					AND sistema = "06"
					AND numero = p_transaccion;
			
			--- Se asigna la nueva transacciÃÂÃÂ³n.
			LET pNumTran = p_transaccion;	
			
			--- Obtiene la diferencia de reducciÃÂÃÂ³n para realizar la transacciÃÂÃÂ³n
			LET v_ajuste_monto = v_monto - VNuevaLinea;
			LET pTotalMovimiento = v_ajuste_monto;		

			IF NOT EXISTS (SELECT * FROM "informix".sd_status_incremento_reduccion WHERE empresa = pEmpresa AND num_credito = pCredito) THEN
				INSERT INTO "informix".sd_status_incremento_reduccion (empresa,numcte,num_credito,tp_proceso,meses_ina,bc_score,linea_original,linea_anterior,linea_actual,fecha_insert,monto_facturacion,fecha_facturacion,describe_mov,marca_cincuenta,fecha_actualiza,descripcion)
					VALUES (pEmpresa,v_numcte,pCredito,tipo,p_meses,pbc_score,v_monto,v_monto,VNuevaLinea,dFechaHoy,0,dFechaHoy,v_descripcion,v_marca_cincuenta,dFechaHoy,v_descripcion2);
			ELSE
				UPDATE "informix".sd_status_incremento_reduccion SET tp_proceso = tipo, fecha_actualiza = dFechaHoy,linea_anterior = v_monto,linea_actual = VNuevaLinea
					WHERE empresa = pEmpresa AND num_credito = pCredito;
			END IF;
			
		
		ELIF tipo = "3" THEN

			--- Se obtiene la nueva linea y transacciÃÂÃÂ³n en base a tabla de parametros.
			SELECT linea,descripcion,codigo_ref,transaccion,folio
				INTO VNuevaLinea,v_rango,p_referencia,p_transaccion,p_folio
			FROM "informix".sd_param_reduccion_linea
				WHERE tp_solicitud  = "T"			 			 
					AND tp_parametrico = tipo; 	
					
			--- El bc_score original de la reducciÃÂÃÂ³n se obtiene de la sd_adviser, se envia parametro del sp_reduccion_linea_ina					
			LET v_bcscore = pbc_score;					

			--- pTotalMovimiento es la linea original del credito el cual lo manda el sp_reduccion_linea_ina
			LET VNuevaLinea = pTotalMovimiento;		
			
			IF VNuevaLinea <= v_monto THEN
				LET VNuevaLinea = v_monto;
				LET no_movimiento = 1; --- En caso de que la linea sea menor o igual, no se hace movimiento y solo se marca en la bitacora.		
			END IF;
			
			LET v_marca_cincuenta = 1;
			LET v_descripcion = 'REACTIVACION POR '||TRIM (v_rango);
			LET v_ajuste_monto = VNuevaLinea - v_monto;		
			LET pTotalMovimiento = v_ajuste_monto;
				
			UPDATE "informix".sd_status_incremento_reduccion 
				SET tp_proceso = tipo, linea_anterior =  v_monto,linea_actual = VNuevaLinea, describe_mov = v_descripcion, marca_cincuenta = 1, fecha_actualiza = dFechaHoy
			WHERE empresa = pEmpresa AND num_credito = pCredito;				
											
			LET v_Mensaje = v_descripcion;	
			
		
		END IF;
		
		IF VNuevaLinea > 0 THEN
		
			IF no_movimiento = 0 THEN
				--- Actualiza la linea con incremento o decremento.
				UPDATE bdicred:sd_maesdos 
					SET monto_otorgado = VNuevaLinea
				WHERE empresa = pEmpresa
					AND num_credito = pCredito;	

				---  Graba movimiento sd_movdia
				EXECUTE PROCEDURE GENMOV( pEmpresa, pCredito,v_producto,p_referencia,'008', dFechaHoy,v_ajuste_monto, p_folio,v_sucursal,v_divisa,p_transaccion)
					INTO vcod_ret,
						v_Mensaje2;
								
				IF vcod_ret::INTEGER <> 0 THEN
				
					--- Actualiza la linea anterior.
					UPDATE bdicred:sd_maesdos 
						SET monto_otorgado = v_monto
					WHERE empresa = pEmpresa
						AND num_credito = pCredito;					
				
					LET tipo = 'E'; -- Error en el proceso
					LET v_descripcion2="Ocurrio un error al guardar los movimientos del credito en el SP bdicred:genmov";	
					LET VNuevaLinea = 0;
					
					UPDATE "informix".sd_status_incremento_reduccion SET tp_proceso = tipo
						WHERE empresa = pEmpresa AND num_credito = pCredito;					 
				END IF;	
			END IF;
						
			--- Guarda un registro nuevo con el incremento tipo I o reducciÃÂÃÂ³n tipo R o si existe un error en E (para identificar el credito)
			INSERT INTO bdicred:sd_incremento_reduccion (empresa,tp_parametrico,numcte,num_credito,meses_ina,bc_score,rango,linea_original,linea_nueva,total_mov,fecha_insert,marca_cincuenta,transaccion_mov,describe_mov,descripcion)		
				VALUES (pEmpresa,tipo,v_numcte,pCredito,p_meses,v_bcscore,v_rango,v_monto,VNuevaLinea,pTotalMovimiento,dFechaHoy,v_marca_cincuenta,pNumTran,v_descripcion,v_descripcion2);

		END IF;
			
	RETURN v_cod_ret,v_Mensaje,VNuevaLinea;
END; 			

END PROCEDURE
DOCUMENT
'REALIZA LA REDUCCION E INCREMENTO DE LINEA - RQM 09 499',
'AUTOR : ISRAEL TRAVIESO DIAZ',
'FECHA : OCT/2018',
'BD    : BDICRED',
'MODIFICACION: SE AGREGA VALIDACION PARA QUE LA LINEA NUEVA NO SEA MAYOR A LA LINEA ANTERIOR0',
'AUTOR : CINTHIA AGUILAR',
'FECHA : JUNIO/2024',
'BD    : BDICRED';

create procedure "informix".sp_plan_pausa_consultar_candidatos_mensual()
RETURNING VARCHAR(200);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE v_cod_ret			CHAR(6);
DEFINE vsqlerr				INTEGER;
DEFINE c_descqlerr			CHAR(200);
DEFINE ISAM_ERR             INTEGER;
DEFINE c_num_cte			CHAR(20);
DEFINE c_num_credito		CHAR(20);
DEFINE c_num_producto		CHAR(4);
DEFINE c_nombre_1		    CHAR(26);
DEFINE c_nombre_2		    CHAR(26);
DEFINE c_apell_pat		    CHAR(26);
DEFINE c_apell_mat		    CHAR(26);
DEFINE c_nombre_com		    CHAR(104);
DEFINE c_num_celular 		CHAR(13);
DEFINE c_num_telefono_casa	CHAR(13);
DEFINE c_canal				CHAR(3);
DEFINE c_campania			CHAR(20);
DEFINE c_calle				CHAR(40);
DEFINE c_num_casa			CHAR(39);
DEFINE c_colonia			CHAR(60);
DEFINE c_municipio			CHAR(30);
DEFINE c_estado				CHAR(30);
DEFINE c_cp					CHAR(5);
DEFINE c_email				CHAR(100);
DEFINE d_saldo_revolvente	DECIMAL(18,2);
DEFINE d_linea_credito		DECIMAL(18,2);
DEFINE d_linea_ocupada		DECIMAL(18,2);
DEFINE d_pago_no_intereses	DECIMAL(18,2);
DEFINE dt_fecha_corte_proxima		DATE;
DEFINE dt_fecha_originacion	DATE;
DEFINE ERROR_INFO           VARCHAR(80);

define i_plazo_sugerido     INTEGER;
define i_tasa_interes       INTEGER;

DEFINE codigo_retorno		CHAR(6);
DEFINE mensaje_retorno		CHAR(80);
DEFINE d_pago_minimo		DECIMAL(18,2);
define c_estado_id			CHAR(2);
define c_municipio_id       CHAR(5);
DEFINE c_pais_id            CHAR(3);
DEFINE c_ciudad_id			CHAR(3);
DEFINE v_resp_pagos			CHAR(6);
DEFINE dt_fecha_hoy         DATE;
DEFINE i_secuencia_aux		INTEGER;
DEFINE dt_fecha_corte_mas_reciente DATE;
DEFINE dt_fecha_maxima_antiguedad DATE;
DEFINE dt_fecha_maxima_antiguedad_mes_proximo DATE; 
DEFINE dt_fecha_pago		DATE;
DEFINE d_pagomin_msi		DECIMAL(18,2);
DEFINE i_meses_acum_mora	INTEGER;
DEFINE i_dia_cuota          INTEGER;
DEFINE i_gracia_calc_mora   INTEGER;
DEFINE d_interes_pagado     DECIMAL(18,2);
define i_periodos_evaluar	SMALLINT;
define dt_fecha_corte_inicial	date;
DEFINE wbegin				CHAR(1);
DEFINE i_contador_registros INTEGER;
define c_controlproc		char(1);
DEFINE dt_hora_inicio_ejecucion DATETIME year to second ; 
DEFINE dt_hora_fin_ejecucion DATETIME year to second ; 
DEFINE dt_fecha_auxiliar DATE;
define c_cred_inicio   char(20);
define c_cred_fin      char(20);
define c_cred_fin_aux  char(20);
define i_secuencia     smallint;
DEFINE i_total         INTEGER;
define c_estatus       char(10);
define i_total_candidatos integer;
define i_total_evaluados_pagos integer;
define i_total_evaluados_pagos_aux integer;
define i_primera_ejec smallint;
define d_saldominimo decimal(18,2);
define d_promedio_pagos_minimo decimal(18,2);
define d_promedio_pagos_realizado decimal(18,2);
define d_promedio_interes_pagado decimal(18,2);
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET v_cod_ret				= '00000';
LET vsqlerr					= 0;
LET c_descqlerr				= '';
let ISAM_ERR                ='';
LET c_num_cte				= '';
LET c_num_credito			= '';
LET c_num_producto			= '';
LET c_nombre_com   	        = '';
LET c_num_celular			= '';
LET c_num_telefono_casa		= '';
LET c_canal					= 'CAT';
LET c_campania				= '';
LET c_calle					= '';
LET c_num_casa				= '';
LET c_colonia				= '';
LET c_municipio				= '';
LET c_estado				= '';
LET c_cp					= '';
LET c_email					= '';
LET c_nombre_com       		= '';
LET d_linea_credito			= 0.0;
LET d_linea_ocupada			= 0.0;
LET d_pago_no_intereses		= 0.0;

let i_plazo_sugerido        = '';
LET codigo_retorno			= '';
LET mensaje_retorno			= '';
LET d_pago_minimo			= 0.0;
LET d_promedio_pagos_minimo = 0.0;
LET d_promedio_pagos_realizado = 0.0;
LET d_promedio_interes_pagado = 0.0;
LET i_tasa_interes          = 0;
LET c_pais_id               = '001';
LET c_ciudad_id             = '000';
LET d_interes_pagado        = 0;
let i_periodos_evaluar 		= 12;
LET i_contador_registros    = 0;
let c_controlproc 			= '0';
let i_total                 = 0;
let c_estatus               = '';
let d_saldominimo = 3000;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
	ON EXCEPTION SET vsqlerr, ISAM_ERR, c_descqlerr
		LET vsqlerr  = vsqlerr;
		LET c_descqlerr  = c_descqlerr;
		IF (wbegin = 'S') THEN 
			ROLLBACK WORK;
			BEGIN WORK;
		ELSE
			ROLLBACK WORK;
		END IF;
		

		IF c_controlproc = '1' then
			SELECT dbinfo('utc_to_datetime', sh_curtime)
			INTO dt_hora_fin_ejecucion
			FROM sysmaster:sysshmvals;

			UPDATE sd_plan_pausa_control_proceso
			SET estatus = '3', 
			comentario = 'NumCred '|| trim(c_num_credito) ||' Ejecucion fallida ' || vsqlerr ||'_'||ISAM_ERR  ||'_' || TRIM (c_descqlerr) ,
			fecha_fin = dt_hora_fin_ejecucion,
			cred_fin = c_cred_fin, -- es el ultimo credito con commit, puede ser distinto a c_num_credito que tiene el crEdito en proceso cuando se da la excepciOn
			total_registros_procesados = i_total
			where proceso = 'MES'
			and fecha_corte = dt_fecha_corte_mas_reciente
			and num_producto = c_num_producto
			and estatus = '1' -- la que estA en proceso, cambia a estatus 3
			and secuencia = i_secuencia;
		END IF;

		RETURN vsqlerr || '-' || c_descqlerr;

	END EXCEPTION;
	


	ON EXCEPTION IN (-535)
		LET wbegin = "S";
		COMMIT WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME; 	
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	


	-- ****************************************************************************
	-- *                        OBTIENE INFO	                                  *
	-- ****************************************************************************
	LET wbegin = "N";

    LET c_campania = 'Campana preventiva';        
    SELECT fecha_hoy  
	INTO dt_fecha_hoy 
	FROM bdicred:"informix".sd_fechas WHERE  empresa='001' ; 

	FOREACH WITH HOLD
    SELECT dia_cuota, gracia_calc_mora, num_producto
	INTO i_dia_cuota, i_gracia_calc_mora, c_num_producto
	FROM bdicred:"informix".sd_definicion 
	WHERE num_producto IN ('6001')
	--ORDER BY dia_cuota
	-- aquiÂ­ solo agregar los nuevos productos que deben generar candidatos o se meten a una tabla de parametros de contol

		IF day(dt_fecha_hoy) <= day(i_dia_cuota) THEN
			let dt_fecha_corte_mas_reciente =  MDY( month(dt_fecha_hoy - 1 UNITS month) ,day(i_dia_cuota), year(dt_fecha_hoy - 1 UNITS month) );
		elif day(dt_fecha_hoy) > day(i_dia_cuota) then
			let dt_fecha_corte_mas_reciente =  MDY( month(dt_fecha_hoy ) ,day(i_dia_cuota), year(dt_fecha_hoy) );
		end if;

		LET dt_fecha_corte_proxima = dt_fecha_corte_mas_reciente +1 UNITS month;

		LET dt_fecha_pago = dt_fecha_corte_proxima - NVL(i_gracia_calc_mora,0);

		LET dt_fecha_maxima_antiguedad = dt_fecha_corte_mas_reciente - i_periodos_evaluar UNITS MONTH;
		LET dt_fecha_corte_inicial     = dt_fecha_corte_mas_reciente - (i_periodos_evaluar - 1) units month;

		select estatus, cred_fin, secuencia
		into c_estatus, c_cred_fin, i_secuencia
		from sd_plan_pausa_control_proceso
		where proceso = 'MES'
		and fecha_corte = dt_fecha_corte_mas_reciente
		and num_producto = c_num_producto
		and secuencia = 
			(
			select max(secuencia)
			from sd_plan_pausa_control_proceso
			where proceso = 'MES'
			and fecha_corte = dt_fecha_corte_mas_reciente
			and num_producto = c_num_producto
			and	estatus in ('0', '1', '2', '3')
			);

		--validar si hay registros ya sea con null o con numreg de la ejecucion
		
		if nvl(c_estatus, '0') = '0' then --is null 
			--si no ha corrido antes, pues no hay reg o hay estatus '0'
			let c_cred_inicio = '';
			let c_cred_fin    = '';

		elif c_estatus = '1' then 
			-- estA corriendo el proceso o es una ejecuciOn que tronaron de forma manual como lo hacen en pruebas en maqueta, validar cuAl caso es
			SYSTEM 'sleep 6';

			select cred_fin
			into c_cred_fin_aux
			from sd_plan_pausa_control_proceso
			where proceso = 'MES'
			and fecha_corte = dt_fecha_corte_mas_reciente
			and num_producto = c_num_producto
			and secuencia = i_secuencia;

			if c_cred_fin = c_cred_fin_aux then
				--proceso no estA corriendo
				Update sd_plan_pausa_control_proceso
				set estatus = '3',
				comentario = 'Ejecucion cancelada con detencion manual'
				where proceso = 'MES'
				and fecha_corte = dt_fecha_corte_mas_reciente
				and num_producto = c_num_producto
				and secuencia = i_secuencia;

				-- ** la variable c_cred_fin puede estar con dato de crEdito de su Ultimo commit o sin dato si no alcanzO por lo menos 1 commit por lo que tendrIa valor vacIo 
				let c_cred_inicio = c_cred_fin;
				
			else --proceso corriendo, no es necesario avanzar
				continue FOREACH;
			end if;

		elif c_estatus = '2' then
			-- este corte y producto ya fue procesado con Exito en una ejecuciOn anterior, no es necesario volver a correrlo
			continue FOREACH;

		elif c_estatus = '3' then --ejecucion anterior fue cancelada, tomar el Ultimo crEdito procesado
			let c_cred_inicio = c_cred_fin;
		end if;

		let i_secuencia   = nvl(i_secuencia, 0) + 1;
		
		SELECT dbinfo('utc_to_datetime', sh_curtime)
			INTO dt_hora_inicio_ejecucion
		FROM sysmaster:sysshmvals;
		
		if nvl(c_estatus, '0') = '0' then
		
			select limit 1 num_credito 
			into c_num_credito
			from bdicred:sd_indicador_cred_hist
			where empresa = '001' and fecha = dt_fecha_corte_mas_reciente;
		
			if c_num_credito is null then 
			-- ya ha pasado la fecha de corte, aunque no hay indicadores, esperar a la sigte ejecuciOn para generar este producto
				insert into sd_plan_pausa_control_proceso(
				proceso, 
				fecha_corte, 
				num_producto, 
				estatus, 
				comentario, 
				fecha_inicio, 
				fecha_fin, 
				secuencia)
				values (
				'MES', 
				dt_fecha_corte_mas_reciente, 
				c_num_producto, 
				'0', 
				'No hay indicadores de credito para fecha corte', 
				dt_hora_inicio_ejecucion, 
				dt_hora_inicio_ejecucion, 
				i_secuencia);
				continue FOREACH;
			end if;
		end if;

		insert into sd_plan_pausa_control_proceso(
		proceso, 
		fecha_corte, 
		num_producto, 
		estatus, 
		comentario, 
		fecha_inicio, 
		cred_inicio, 
		cred_fin, 
		secuencia)
		values (
		'MES', 
		dt_fecha_corte_mas_reciente, 
		c_num_producto, 
		'1', 
		'Procesando datos.', -- Inicia Proceso', 
		dt_hora_inicio_ejecucion, 
		c_cred_inicio, 
		c_cred_fin, 
		i_secuencia);
		
		let c_controlproc     = '1';
		let i_primera_ejec    = 0;
		let dt_fecha_auxiliar = dt_fecha_corte_mas_reciente - 1 UNITS month;
		
		select estatus
		into c_estatus
		from sd_plan_pausa_control_proceso
		where proceso = 'MES'
		and fecha_corte        --= dt_fecha_auxiliar
			between dt_fecha_corte_inicial and dt_fecha_corte_mas_reciente
		and num_producto = c_num_producto;
		--and estatus = '2';
		--con cualquier ejecucion aunque no se haya completado ya puede haber datos en bitacora de pagos
		
		if c_estatus is null then
			let i_primera_ejec = 1;
		end if;
--la validacion para truncate no se puede usar para validar 1er ejec porque truncate sucede solo 1 vez, si este proceso corre de nuevo porque haya fallado etc ya no hallara registros del corte pasado aunque eso no indica que sea 1er ejecucion
			
-------------------
		--BORRADO DE MESES DE CORTES ANTERIORES AL QUE SE EMPIEZA A PROCESAR, EN LA TABLA mensual NO HABRa 2 meses al mismo tiempo para evitar crecimiento innecesario
		
		SELECT limit 1 num_credito
		INTO c_num_credito
		FROM sd_plan_pausa_candidatos_mensual
		WHERE fecha_corte = dt_fecha_auxiliar;
		
		--si existe algUn crEdito del corte anterior se limpia la tabla, esto sucederA solo 1 vez, cuando haya nuevo corte en un nuevo mes, considerando que los productos del plan cortan el 18 y 20, el dIa 18 limpiara la tabla, dejando 2 dIas sin datos para el corte del 20 en lo que llega la nueva fecha corte, el area de cobranzas trabajarA con el Ultimo archivo generado
		If c_num_credito is not null then
			truncate table sd_plan_pausa_candidatos_mensual;
		end if;
			
		let dt_fecha_auxiliar = dt_fecha_corte_inicial - 1 UNITS month;
		
		--SELECT limit 1 num_credito
		--INTO c_num_credito
		--FROM sd_plan_pausa_bitacorapagos
		--WHERE fecha_corte = dt_fecha_auxiliar;
		
		--If c_num_credito is not null then
		--	BEGIN WORK;
			
		--	DELETE FROM sd_plan_pausa_bitacorapagos
		--	WHERE fecha_corte = dt_fecha_auxiliar;
			-- ** asegurar que el indice funciona bien solo con el primer campo
		--	COMMIT WORK;
		--end if;

		

		update statistics medium for table sd_plan_pausa_candidatos_mensual;
		--update statistics medium for table sd_plan_pausa_bitacorapagos;

--FIN BORRADO
-------------------

		LET i_contador_registros = 0;


		SELECT count(*)
		INTO i_total_candidatos
		FROM
			bdicred:"informix".sd_maecred sm,
			bdicred:"informix".sd_maesdos smd
		WHERE
			sm.num_producto = c_num_producto
			AND sm.num_credito = smd.num_credito
			AND sm.empresa = '001'
			AND sm.status_cred = 'E1'
			AND sm.fecha_apertura <= dt_fecha_maxima_antiguedad
			AND sm.num_credito > c_cred_inicio
			AND smd.sdo_cap_insoluto >= d_saldominimo
			and smd.sdo_capital > 0
			and smd.empresa = '001';
			
		UPDATE sd_plan_pausa_control_proceso
		SET total_objetivo_procesar = i_total_candidatos
		WHERE proceso = 'MES'
			and fecha_corte = dt_fecha_corte_mas_reciente
			and num_producto = c_num_producto
			and estatus = '1'
			and secuencia = i_secuencia;

		Let i_total_candidatos = 0;
		let i_total_evaluados_pagos = 0;
		let i_total_evaluados_pagos_aux = 0;
    	BEGIN WORK;

		

		FOREACH WITH HOLD
		SELECT 	sm.numcte, sm.num_credito, sm.fecha_apertura, smd.monto_otorgado, smd.sdo_cap_insoluto
		INTO
			c_num_cte, c_num_credito, dt_fecha_originacion, d_linea_credito, d_saldo_revolvente
		FROM
			bdicred:"informix".sd_maecred sm, 
			bdicred:"informix".sd_maesdos smd
		WHERE
			sm.num_producto = c_num_producto
			AND sm.num_credito = smd.num_credito
			AND sm.empresa = '001'
			AND sm.status_cred = 'E1'
			AND sm.fecha_apertura <= dt_fecha_maxima_antiguedad
			AND sm.num_credito > c_cred_inicio
			AND smd.sdo_cap_insoluto >= d_saldominimo

		Order by sm.num_credito --necesario para controlar ejecuciones por partes

			LET v_resp_pagos='000000';
/*
			----mora mayor a 2 en los ultimos 12 meses
			--let dt_fecha_maxima_antiguedad_mes_proximo = dt_fecha_maxima_antiguedad + 1 UNITS month;
			SELECT NVL(max(maehist.mto_fin_ven_trasp),0)
			INTO 
				i_meses_acum_mora
			FROM
				bdicred:"informix".sd_maesdoshist maehist
			WHERE 
				maehist.fecha BETWEEN  dt_fecha_corte_inicial AND dt_fecha_corte_mas_reciente       
				AND maehist.empresa = '001'
				AND maehist.num_credito = c_num_credito;

			IF i_meses_acum_mora <= 1 THEN --2 o mas meses vencidos se descarta					 */

				EXECUTE PROCEDURE bdicred:"informix".sp_plan_pausa_evalua_pago_cliente(c_num_credito, dt_fecha_corte_inicial, dt_fecha_corte_mas_reciente)
				INTO v_resp_pagos, d_pago_minimo, d_promedio_pagos_minimo, d_promedio_pagos_realizado, d_promedio_interes_pagado;

				IF v_resp_pagos = '000001' THEN
				
					SELECT 
						cl.nombre1, cl.nombre2, cl.apell_paterno, cl.apell_materno        
					INTO
						c_nombre_1, c_nombre_2, c_apell_pat, c_apell_mat
					FROM
						bdinteg:"informix".si_cliente cl
					WHERE
						cl.numcte =  c_num_cte;


				
					LET c_nombre_com =  TRIM(TRIM(c_nombre_1)  || ' ' || TRIM(c_nombre_2) ) || ' ' || 
										TRIM(TRIM(c_apell_pat) || ' ' || TRIM(c_apell_mat));


					SELECT
						MAX(case when tipo_tel = 1 then
							tel.telefono
						END) as num_telefono_casa,
						MAX(case when tipo_tel = 2 then
							tel.telefono
						END) as num_celular
					INTO
						c_num_telefono_casa,c_num_celular
					FROM
						bdinteg:si_telefonos_actual tel
					WHERE
						tel.numcte=	c_num_cte AND tel.tipo_tel in(1, 2) ;
	/*
					SELECT 
						MAX(da.secuencia)
					INTO 
						i_secuencia_aux
					FROM
						bdinteg:"informix".si_direcciones_actual da
					WHERE 
						da.numcte =	c_num_cte AND da.tipo_dir = '1';
	*/
	--				IF i_secuencia_aux IS NOT NULL THEN
						SELECT limit 1
							TRIM(da.calle) AS calle,
							TRIM(da.numeroextcalle)||' Int: '|| TRIM(da.numerointcalle)|| ' Dpto: ' || da.departamento AS num_casa,
							TRIM(da.colonia) AS colonia,
							da.municipio,
							da.pais,
							da.estado,
							da.ciudad,
							da.cod_postal
						INTO
							c_calle, c_num_casa, c_colonia, c_municipio_id, c_pais_id, c_estado_id, c_ciudad_id, c_cp
						FROM
							bdinteg:"informix".si_direcciones_actual da
						WHERE
							da.numcte =   c_num_cte --AND da.secuencia=i_secuencia_aux 
							AND da.tipo_dir = '1';
			
						SELECT
							TRIM(smun.nombre) AS municipio
						INTO
							c_municipio
						FROM
							bdinteg:"informix".si_municipios smun
						WHERE
							smun.municipio = c_municipio_id AND smun.estado = c_estado_id AND smun.ciudad = c_ciudad_id AND  smun.pais = c_pais_id;
				  
						SELECT
							TRIM(sest.nombre) AS nombre_estado
						INTO
							c_estado
						FROM
							bdinteg:"informix".si_estados sest
						WHERE
							sest.estado = c_estado_id AND sest.pais = c_pais_id  ;
	--				END IF;

					SELECT
						MAX(rclt.secuencia)
					INTO
						i_secuencia_aux
					FROM
						bdinteg:"informix".si_correos rclt
					WHERE 
						rclt.numcte = c_num_cte AND tipo_correo = 1 AND status_correo = 'A';


					SELECT
						TRIM(rclt.correo_elec ) AS email
					INTO
						c_email
					FROM
						bdinteg:"informix".si_correos rclt
					WHERE
						rclt.numcte = c_num_cte AND rclt.secuencia = i_secuencia_aux;

					--EXECUTE PROCEDURE bdicred:"informix".sp_plan_pausa_calcula_pago_minimo(c_num_credito, dt_fecha_corte_mas_reciente)
					--	INTO v_cod_ret, d_pago_minimo, d_interes_pagado;
					--v_cod_ret ya no se valida pues genera datos porque este periodo es el 1ro que se ejecuta en evaluapagos, de lo contrario hubiera salido del flujo

					EXECUTE PROCEDURE bdicred:"informix".sp_plan_pausa_obtiene_tasa_interes(d_promedio_pagos_realizado, d_promedio_interes_pagado, d_promedio_pagos_minimo)
 					INTO i_tasa_interes;

					INSERT INTO bdicred:"informix".sd_plan_pausa_candidatos_mensual (
					numcte , num_credito, num_producto, nombre_com,
					linea_credito, pago_minimo, fecha_corte, fecha_originacion, fecha_pago,
					tasa_interes, num_celular,num_telefono_casa,
					canal, campania, calle, num_casa, colonia, 
					municipio, estado, cp, email, promedio_pagominimo, promedio_pagosrealizados, promedio_interespagado
					)VALUES (	
					c_num_cte, c_num_credito, c_num_producto, NVL(c_nombre_com,''),
					NVL(d_linea_credito,0), NVL(d_pago_minimo,0), dt_fecha_corte_mas_reciente, dt_fecha_originacion, dt_fecha_pago,
					NVL(i_tasa_interes,0), NVL(c_num_celular,''),NVL(c_num_telefono_casa,''),
					c_canal, c_campania, NVL( c_calle,''), NVL( c_num_casa,''), NVL(c_colonia,''), 
					NVL(c_municipio,''), NVL(c_estado,''), NVL(c_cp,''), c_email, NVL(d_promedio_pagos_minimo,0),
					NVL(d_promedio_pagos_realizado,0), NVL(d_promedio_interes_pagado,0)					
					);

					LET i_total_candidatos = i_total_candidatos + 1;
				END IF; -- cumple con pgos minimos
				
				LET i_total_evaluados_pagos = i_total_evaluados_pagos + 1;
				LET i_total_evaluados_pagos_aux = i_total_evaluados_pagos_aux + 1;
				
			--END IF; -- 2 o mas pagos vencidos en los Ultimos 12 periodos

			let i_total = i_total + 1; --total general

			-- contador para ver los inserts, cada 100 inserts hace commit, y abre una nueva begin work
			LET i_contador_registros = i_contador_registros + 1;

			IF (i_total_evaluados_pagos_aux = 100) THEN
				LET  i_total_evaluados_pagos_aux = 0;

				SELECT dbinfo('utc_to_datetime', sh_curtime)
				INTO dt_hora_fin_ejecucion
				FROM sysmaster:sysshmvals;


				if (((dt_hora_fin_ejecucion - dt_hora_inicio_ejecucion ) ::INTERVAL HOUR TO hour)::char(3))::smallint >= 3 then --interval hora a hora no admite cast a smallint directo
				
					UPDATE sd_plan_pausa_control_proceso
					SET estatus = '3', 
					comentario = 'Detenido por tiempo mas de 3 horas. Candidatos detectados: '|| i_total_candidatos,
					fecha_fin = dt_hora_fin_ejecucion,
					cred_fin = c_num_credito,
					total_registros_procesados = i_total
					where proceso = 'MES'
					and fecha_corte = dt_fecha_corte_mas_reciente
					and num_producto = c_num_producto
					and estatus = '1' -- la que estA en proceso--- exito cambia a estatus
					and secuencia = i_secuencia;
					
					let c_controlproc = '0';
					EXIT FOREACH;
				else
				
					UPDATE sd_plan_pausa_control_proceso
					SET comentario = 'Procesando datos. Universo: ' || total_objetivo_procesar ||
									 '  Procesados: ' || i_total || 
									 '  Candidatos detectados: ' || i_total_candidatos || 
									 '  Ultimo Commit: ' || dt_hora_fin_ejecucion,
						cred_fin = c_num_credito,
						fecha_fin = dt_hora_fin_ejecucion,
						total_registros_procesados = i_total
					WHERE proceso = 'MES'
						and fecha_corte = dt_fecha_corte_mas_reciente
						and num_producto = c_num_producto
						and estatus = '1'
						and secuencia = i_secuencia;

					COMMIT WORK;
					let c_cred_fin    = c_num_credito; --Ultimo credito con commit exitoso, ya estA en tabla

					BEGIN WORK;
				
				end if;
			END IF; --100 creditos procesados con registros en bitacora de pagos

		END FOREACH; --sd_maecred
		COMMIT WORK;
		let c_cred_fin    = c_num_credito; --Ultimo credito con commit exitoso, ya estA en tabla
		LET  i_contador_registros = 0;		

		if c_controlproc = '1' then

			SELECT dbinfo('utc_to_datetime', sh_curtime)
				INTO dt_hora_fin_ejecucion
			FROM sysmaster:sysshmvals;

			UPDATE sd_plan_pausa_control_proceso
			SET estatus = '2', 
			comentario = 'FIN EXITOSO. Candidatos detectados: ' || i_total_candidatos ,
			fecha_fin = dt_hora_fin_ejecucion,
			cred_fin = c_num_credito,
			total_registros_procesados = i_total
			where proceso = 'MES'
			and fecha_corte = dt_fecha_corte_mas_reciente
			and num_producto = c_num_producto
			and estatus = '1'
			and secuencia = i_secuencia;
		else -- si es '0' ver si viene de una salida por tiempo, salir del ciclo para hacer return
			EXIT FOREACH;
		end if;
		let c_controlproc = '0';
	END FOREACH;  --sd_definicion

	--regenerar estadisticas para que los procesos diarios tomen las tablas optimizadas
	update statistics medium for table sd_plan_pausa_candidatos_mensual;
	--update statistics medium for table sd_plan_pausa_bitacorapagos;

    
    IF (wbegin = "S") THEN
        BEGIN WORK;
    END IF;

RETURN v_cod_ret;


END;
END PROCEDURE;