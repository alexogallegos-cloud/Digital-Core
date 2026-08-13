CREATE PROCEDURE "informix".sp_reduccion_linea_ina(p_empresa CHAR(3),p_fecha DATE)
RETURNING CHAR(6),CHAR (100);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************


DEFINE v_cod_ret			CHAR(6);
DEFINE vsqlerr				INTEGER;
DEFINE v_Mensaje			CHAR(100);
DEFINE vcod_retred			CHAR(10);
DEFINE v_Mensajered			CHAR(100);
DEFINE vcod_retinc			CHAR(10);
DEFINE v_Mensajeinc			CHAR(100);
DEFINE iMes_Incremento_linea			SMALLINT;
DEFINE iMes_Movimiento_linea			SMALLINT;
DEFINE iMes_Reduccion_linea	   		 	SMALLINT;
DEFINE iMes_Apertura_linea	            SMALLINT;

--- Reduccion

DEFINE p_fecha_consulta_red DATE;
DEFINE v_num_credito		CHAR(20);
DEFINE v_gpo_testigo		INTEGER;
DEFINE v_monto				DECIMAL(14,2);
DEFINE v_alta				DATE;
DEFINE v_fecha_ult_pago		DATE;
DEFINE v_primer_compra		DATE;
DEFINE v_primer_disp		DATE;
DEFINE v_atm_disp_fecha		DATE;
DEFINE v_fecha_ultima_compra	DATE;
DEFINE v_vnt_disp_fecha		DATE;
DEFINE v_fechaultimocambio	DATE;
DEFINE v_fecha_actualiza	DATE;

DEFINE v_meses				INTEGER;
DEFINE v_bcscore			DECIMAL(14,2);
DEFINE VNuevaLinea			DECIMAL(10,2);
DEFINE v_rango				CHAR(20);
DEFINE v_monto_actual		DECIMAL(14,2);
DEFINE v_ajuste_montored	DECIMAL(14,2);
DEFINE v_num_producto		CHAR(4);
DEFINE v_divisared			CHAR(2);
DEFINE v_sucursalred		CHAR(4);
DEFINE v_numcte				CHAR(20);
DEFINE contador_commit 	    INTEGER; 
DEFINE sCommit         		SMALLINT;
DEFINE v_tp_proceso			CHAR(1);

DEFINE pNumTran				CHAR(4);

--- Incremento 50 %

DEFINE p_fecha_rango_inc 	DATE;
DEFINE p_fecha_rango_fin 	DATE;
DEFINE v_num_credito_inc	CHAR(20);
DEFINE v_linea_original		DECIMAL(10,2);
DEFINE vpago_consecutivo	INTEGER;
DEFINE v_param_incremento	DECIMAL (4,2);
DEFINE v_rango_inc			CHAR(20);
DEFINE VNuevaLineaInc		DECIMAL(10,2);
DEFINE v_monto_actual_inc	DECIMAL(10,2);
DEFINE v_ajuste_monto_inc	DECIMAL(10,2);
DEFINE v_productoinc		CHAR(4);
DEFINE v_divisainc			CHAR(2);
DEFINE v_sucursalinc		CHAR(4);

------- Reporte

DEFINE sFechaArch			CHAR(10);
DEFINE sFechaArch2			CHAR(10);
DEFINE v_sepa               CHAR(2);
DEFINE sMes					CHAR(2);
DEFINE sYear				CHAR(4);
DEFINE v_sql				CHAR(250);
DEFINE v_sql2				CHAR(250);
DEFINE cRuta				CHAR(100);

DEFINE periodo1				DATE;
DEFINE periodo2				DATE;
DEFINE r_numcte				CHAR(20);
DEFINE r_num_credito		CHAR(20);
DEFINE r_describe_mov		CHAR(50);
DEFINE r_fecha_insert		DATE;
DEFINE r_total_mov			DECIMAL(10,2);
DEFINE r_linea_original		DECIMAL(10,2);
DEFINE r_linea_nueva		DECIMAL(10,2);
DEFINE r_fecha_marca		DATE;
DEFINE r_meses_ina 			DATE;
DEFINE r_bc_score			DECIMAL(14,2);
DEFINE r_descripcion		CHAR (50);
DEFINE r_fecha_facturacion	DATE;


DEFINE dFechaHoy			DATE;
DEFINE dFechaMes			DATE;
DEFINE dFechaInc			DATE;
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************


LET v_cod_ret				= "000000";
LET vsqlerr					= 0;
LET v_Mensaje				= "";
LET vcod_retred				= "000";
LET v_Mensajered			= "";
LET vcod_retinc				= "000";
LET v_Mensajeinc			= "";
LET iMes_Incremento_linea	=0;
LET iMes_Movimiento_linea	=0;
LET iMes_Reduccion_linea	=0;
LET iMes_Apertura_linea		=0;

LET p_fecha_consulta_red	= DATE(1);
LET v_num_credito			= "";
LET v_gpo_testigo			= 0;
LET v_monto					= 0;
LET v_alta					= DATE(1);
LET v_fecha_ult_pago		= DATE(1);
LET v_primer_compra			= DATE(1);
LET v_primer_disp			= DATE(1);
LET v_atm_disp_fecha		= DATE(1);
LET v_fecha_ultima_compra	= DATE(1);
LET v_vnt_disp_fecha		= DATE(1);
LET v_fechaultimocambio		= DATE(1);
LET v_fecha_actualiza		= DATE(1);
LET v_meses					= 0;
LET v_bcscore				= 0;
LET VNuevaLinea				= 0;
LEt v_rango					= "";
LET v_monto_actual			= 0;
LET v_ajuste_montored		= 0;
LET v_num_producto			= "";
LET v_divisared				= "";
LET v_sucursalred			= "";
LET v_numcte				= "";
LET contador_commit			= 0;
LET sCommit                 = 0;
LET v_tp_proceso			= "";

LET p_fecha_rango_inc		= DATE(1);
LET p_fecha_rango_fin		= DATE(1);
LET v_num_credito_inc		= "";
LET v_linea_original		= 0;
LET vpago_consecutivo		= 0;
LET v_param_incremento		= 0;
LET v_rango_inc				= "";
LET VNuevaLineaInc			= 0;
LET v_monto_actual_inc		= 0;
LET v_ajuste_monto_inc		= 0;
LET v_productoinc			= 0;
LET v_divisainc				= 0;
LET v_sucursalinc			= 0;

LET pNumTran				= '0000';

------- Reporte

LET periodo1				= DATE(1);
LET periodo2				= DATE(1);
LET sFechaArch				= "";
LET v_sepa                 	= '\|';
LET sMes					= "";
LET sYear					= "";
LET v_sql					= "";
LET v_sql2					= "";
LET cRuta		 			= "/RESPALDOSNEW/";
--LET cRuta					= "/informix/Israel/";

LET r_numcte				= "";
LET r_num_credito			= "";
LET r_describe_mov			= "";
LET r_fecha_insert			= DATE(1);
LET r_total_mov				= 0;
LET r_linea_original		= 0;
LET r_linea_nueva			= 0;
LET r_fecha_marca			= DATE(1);
LET r_meses_ina				= DATE(1);
LET r_bc_score				= 0;
LET r_descripcion			= "";
LET r_fecha_facturacion		= DATE(1);


LET dFechaHoy			= date(1);
LET dFechaMes			= date(1);
LET dFechaInc			= date(1);
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************


BEGIN
	ON EXCEPTION SET vsqlerr
	IF vsqlerr != 0 THEN
		LET v_cod_ret=vsqlerr;
		LET v_Mensaje = "";
		IF (sCommit = -1) THEN
                rollback work;
        END IF;
		RETURN v_cod_ret,v_Mensaje;	
	END IF;
	END EXCEPTION;   
	
--SET DEBUG FILE TO "/informix/Israel/sp_reduccion_linea_ina.out";
--TRACE ON;
	
	--SET DEBUG FILE TO "/home/e_vvalen/sp_reduccion_linea_ina.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
		-- Lectura de parametros 
	SELECT valor::SMALLINT INTO iMes_Incremento_linea FROM bdicred:sd_param	WHERE cod_param = '155';		-- NÃºmero de mÃ©ses con Incrementos en los Ãºltimos 9999 meses
	SELECT valor::SMALLINT INTO iMes_Movimiento_linea FROM bdicred:sd_param WHERE cod_param = '156';		-- Movimientos de disposiciones o compras en los Ãºltimos 9999 meses
	SELECT valor::SMALLINT INTO iMes_Reduccion_linea FROM bdicred:sd_param WHERE cod_param = '157';			-- Reducciones de lÃ­nea en los Ãºltimos 9999 meses
	SELECT valor::SMALLINT INTO iMes_Apertura_linea FROM bdicred:sd_param WHERE cod_param = '158';			-- Fecha de apertura del crÃ©dito sea mayor a 9999 meses

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	

	--- Obtiene la fecha de 9999 meses menos
	LET p_fecha_consulta_red =  ADD_MONTHS (p_fecha, -iMes_Apertura_linea);
	
	CREATE temp TABLE fecha_actual ( num_credito char(20), meses integer) with no log;
	CREATE INDEX fecha_inx_actual ON fecha_actual(num_credito,meses);
	UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".fecha_actual;

	CREATE temp TABLE creditos_reduccion ( num_credito char(20),numcte char(20),num_producto CHAR (4),monto DECIMAL(14,2), fecha_ultimo_pago date,f_primer_compra DATE,f_primer_disp DATE,atm_disp_fecha DATE,fecha_ultima_compra DATE,vnt_disp_fecha DATE,fechaultimocambio DATE,fecha_alta DATE) with no log; 
    CREATE UNIQUE INDEX creditos_reduccion_inx ON creditos_reduccion(num_credito,fecha_ultimo_pago,f_primer_compra,f_primer_disp,atm_disp_fecha,fecha_ultima_compra,vnt_disp_fecha,fechaultimocambio,fecha_alta );
	
	Insert into creditos_reduccion
		SELECT 	sdo.num_credito,
				cred.numcte,
				cred.num_producto,
				sdo.monto_otorgado,
				ind.fecha_ultimo_pago,
				ind.f_primer_compra,
				ind.f_primer_disp,
				ind.atm_disp_fecha,
				ind.fecha_ultima_compra,
				ind.vnt_disp_fecha,
				ind.fechaultimocambio,
				ind.fecha_alta
		FROM  bdicred:sd_maecred cred
		JOIN bdicred:sd_indicador_cred ind ON (ind.empresa = cred.empresa AND ind.num_credito = cred.num_credito)
		JOIN bdicred:sd_maesdos sdo ON 	(sdo.empresa = cred.empresa AND sdo.num_credito = cred.num_credito)
		WHERE cred.status_cred IN ('AA','E1')
		AND (sdo.monto_vencido + sdo.mto_venc_trasp) = 0;	

    --------------------------------------------------------------------------------------------------------------------------
	----------Obtiene creditos que tengan algun aumento de linea en los ultimos 3 meses---------------------------------------
	--------------------------------------------------------------------------------------------------------------------------
		-- Lectura de la fecha actual.
	SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas;		-- Fecha del dia
	SELECT add_months(fecha_hoy,-iMes_Incremento_linea) INTO dFechaMes FROM bdicred:sd_fechas;	-- Mes - 9999
	
	
	SELECT num_credito FROM bdicred:sd_incremento_reduccion
	WHERE tp_parametrico IN ('I','3') AND fecha_insert BETWEEN dFechaMes AND dFechaHoy 
	GROUP BY num_credito
	HAVING COUNT(num_credito) > 0 
		UNION ALL
    SELECT num_credito FROM bdicred:sd_status_incremento_reduccion
	WHERE tp_proceso IN ('I','3') AND fecha_actualiza BETWEEN dFechaMes AND dFechaHoy
	GROUP BY num_credito
	HAVING COUNT(num_credito) > 0 
	INTO temp tmp_indic_aum_inac WITH NO LOG;
	create index ix1_indaum_red_inac on tmp_indic_aum_inac ( num_credito ); 
    --ACTUALIZACION DE ESTASISTICOS A LA TEMPORAL
	UPDATE STATISTICS MEDIUM FOR TABLE tmp_indic_aum_inac;
	-- Elimina creditos que recibieron un aumento en los ultimos 3 meses para que no sean procesados en la reduccion de linea.
	DELETE FROM creditos_reduccion WHERE num_credito IN (select {+avoid_full (tmp_indic_aum_inac)} num_credito from tmp_indic_aum_inac);
	
	--------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------

	--- sinonimo sd_adviser_mensual_85		
	CREATE temp TABLE adviser_mensual ( num_credito char(20),adv852 DECIMAL(14,2)) with no log;
    CREATE UNIQUE INDEX adviser_mensual_inx ON adviser_mensual(num_credito,adv852);
	
	Insert into adviser_mensual	
	SELECT num_credito,adv852 FROM sd_adviser_mensual_85; ----- tabla pruebas sd_adviser_mensual cambiar a sd_adviser_mensual_85 para producciÃÂÃÂ³n
	
	LET sMes= MONTH(p_fecha);
	LET sYear= YEAR(p_fecha);

	IF LENGTH(sMes)<2 THEN
		LET sMes="0"||sMes;
	END IF;

	LET sFechaArch=sMes||sYear;
	
	LET v_sql =
		'echo '||'No. de cliente'||v_sepa||'No. de credito'||v_sepa||'Meses de inactividad'||v_sepa||'BC Score'||v_sepa||'Linea anterior'||v_sepa||'Linea actual'||' >>'||TRIM(cRuta)||'Reduccion_'||TRIM(sFechaArch)||'.txt';
	SYSTEM v_sql;	
	
	
	FOREACH WITH HOLD
		
		SELECT 	 a.num_credito,a.numcte,a.num_producto,a.monto,a.fecha_ultimo_pago,a.f_primer_compra,a.f_primer_disp,a.atm_disp_fecha,a.fecha_ultima_compra,a.vnt_disp_fecha,a.fechaultimocambio
			INTO v_num_credito,
			v_numcte,
			v_num_producto,
			v_monto,
			v_fecha_ult_pago,
			v_primer_compra,
			v_primer_disp,
			v_atm_disp_fecha,
			v_fecha_ultima_compra,
			v_vnt_disp_fecha,
			v_fechaultimocambio
		FROM creditos_reduccion a
			WHERE a.fecha_alta <= p_fecha_consulta_red
			
			IF v_num_producto <> '6001' THEN
				CONTINUE FOREACH;
			END IF;

			SELECT fecha_actualiza
				INTO v_fecha_actualiza
			FROM bdicred:sd_status_incremento_reduccion
				WHERE num_credito = v_num_credito AND tp_proceso <> 'E';
			
			LET v_fecha_ult_pago = nvl (v_fecha_ult_pago,date (1));
			LET v_primer_compra	= nvl (v_primer_compra,date (1));
			LET v_primer_disp = nvl (v_primer_disp,date (1));
			LET v_atm_disp_fecha = nvl (v_atm_disp_fecha,date (1));
			LET v_fecha_ultima_compra =	nvl (v_fecha_ultima_compra,date (1));
			LET v_vnt_disp_fecha = nvl (v_vnt_disp_fecha,date (1));
			LET v_fechaultimocambio = nvl (DATE (v_fechaultimocambio),date (1));
			LET v_fecha_actualiza = nvl (v_fecha_actualiza,date(1));

		
			IF (sCommit = 0) THEN
				BEGIN WORK;
				LET sCommit = -1;
			END IF
			
			--- Descarta creditos con movimientos mayores o igual a 9999 meses, que indica que tienen movimientos recientes
			IF (v_fecha_ult_pago >= p_fecha_consulta_red OR v_primer_compra >= p_fecha_consulta_red 
				OR v_primer_disp >= p_fecha_consulta_red OR v_atm_disp_fecha >= p_fecha_consulta_red OR v_fecha_ultima_compra >= p_fecha_consulta_red 
				OR v_vnt_disp_fecha >= p_fecha_consulta_red OR v_fechaultimocambio >= p_fecha_consulta_red OR v_fecha_actualiza >= p_fecha_consulta_red ) THEN
				CONTINUE FOREACH;
			END IF;
			
			--- Proceso que obtiene numero de meses desde el ultimo movimiento
			
			LET v_fecha_ult_pago = (FLOOR (months_between (p_fecha,v_fecha_ult_pago)));
			LET v_primer_compra = (FLOOR (months_between (p_fecha,v_primer_compra)));
			LET v_primer_disp = (FLOOR (months_between (p_fecha,v_primer_disp)));
			LET v_atm_disp_fecha = (FLOOR (months_between (p_fecha,v_atm_disp_fecha)));
			LET v_fecha_ultima_compra = (FLOOR (months_between (p_fecha,v_fecha_ultima_compra)));
			LET v_fechaultimocambio = (FLOOR (months_between (p_fecha,v_fechaultimocambio)));
			LET v_vnt_disp_fecha = (FLOOR (months_between (p_fecha,v_vnt_disp_fecha)));
			LET v_fecha_actualiza = (FLOOR (months_between (p_fecha,v_fecha_actualiza)));
			
		
			-- Se insertan valores en tabla temporal con fechas en meses
				
			INSERT into fecha_actual VALUES(v_num_credito,v_fecha_ult_pago);
			INSERT into fecha_actual VALUES(v_num_credito,v_primer_compra);
			INSERT into fecha_actual VALUES(v_num_credito,v_primer_disp);
			INSERT into fecha_actual VALUES(v_num_credito,v_atm_disp_fecha);
			INSERT into fecha_actual VALUES(v_num_credito,v_fecha_ultima_compra);
			INSERT into fecha_actual VALUES(v_num_credito,v_fechaultimocambio);	
			INSERT into fecha_actual VALUES(v_num_credito,v_vnt_disp_fecha);	
			INSERT into fecha_actual VALUES(v_num_credito,v_fecha_actualiza);
			
			---- Se realiza consulta para obtener fecha mas reciente en meses
			SELECT min (meses)
				INTO v_meses
			FROM fecha_actual 
			WHERE num_credito = v_num_credito;
													
			
			--- sd_adviser_mensual de la tabla temporal
			--SELECT adv852 
				--INTO v_bcscore
			--FROM adviser_mensual 
			--WHERE num_credito = v_num_credito;
			
			--- sd_adviser_mensual de la tabla temporal
			SELECT adv852 
				INTO v_bcscore
			FROM adviser_mensual JOIN sd_tarjeta ON adviser_mensual.num_credito=sd_tarjeta.num_tarjeta
			WHERE sd_tarjeta.num_credito = v_num_credito
			AND secuencia = ( SELECT MAX(secuencia) FROM sd_tarjeta WHERE num_credito = v_num_credito );
				
			LET v_bcscore = NVL (v_bcscore,0);
			
			EXECUTE PROCEDURE bdicred:sp_incremento_reduccion (p_empresa,v_num_credito,v_meses,0,"R",v_bcscore,pNumTran)
			INTO vcod_retred,v_Mensajered, VNuevaLinea;
			
			IF vcod_retred::INTEGER <> 0 THEN
				LET v_cod_ret= '000001'; 
				LET v_Mensaje="Ocurrio un error al realizar la Reduccion de la linea";
				RETURN v_cod_ret, v_Mensaje;			
			END IF;


			LET v_sql = 'echo '||TRIM(v_numcte)||v_sepa||TRIM(v_num_credito)||v_sepa||v_meses||v_sepa||v_bcscore||v_sepa||v_monto||v_sepa||VNuevaLinea||' >>'||TRIM(cRuta)||'Reduccion_'||TRIM(sFechaArch)||'.txt';
			SYSTEM v_sql;
				
			LET contador_commit = contador_commit  + 1;	
	
			IF (contador_commit >= 100) THEN
				COMMIT WORK;
				UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".fecha_actual;
				LET contador_commit = 0;
				BEGIN WORK;
			END IF;
				
			IF sCommit = -1 THEN
				COMMIT WORK;
			END IF;
			
			LET sCommit = 0;
			
	END FOREACH;

	
-- ****************************************************************************
-- *                    Proceso incrementa 100 % de forma mensual              *
-- ****************************************************************************	

	--se consulta la linea de la bitacora y si el count (moviemintos) = 9999 se calcula el 100 % para incrementar la linea
	--- Obtiene la fecha de 3 meses menos
	---LET p_fecha_rango_inc =  ADD_MONTHS (p_fecha, -3);	
	---LET p_fecha_rango_fin =  ADD_MONTHS (p_fecha, -2);
	
	--- Obtiene la fecha de 9999 meses menos
	SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas;		-- Fecha del dia
	SELECT add_months(fecha_hoy,-iMes_Incremento_linea) INTO dFechaInc FROM bdicred:sd_fechas;	-- Mes - 9999


	CREATE temp TABLE cred_incrementos_cincuenta ( numcte CHAR (20),num_credito CHAR(20),meses_ina INTEGER,bc_score INTEGER,describe_mov CHAR (50),fecha_facturacion DATE,total_mov DECIMAL(10,2),linea_original DECIMAL(10,2),linea_nueva DECIMAL(10,2),descripcion CHAR(50)) with no log; 
    CREATE UNIQUE INDEX idx_incrementos_cincuenta ON cred_incrementos_cincuenta(num_credito,linea_original);

	Insert into cred_incrementos_cincuenta	
	SELECT numcte,num_credito,meses_ina,bc_score,describe_mov,fecha_facturacion,monto_facturacion,linea_original,linea_actual,descripcion
	FROM "informix".sd_status_incremento_reduccion 
			WHERE empresa = p_empresa 
				AND tp_proceso = "I" AND marca_cincuenta = 0
				--AND fecha_actualiza BETWEEN p_fecha_rango_inc AND p_fecha_rango_fin;
				AND fecha_actualiza <= dFechaInc;
			
	LET v_sql2 =
		'echo '||'No. de cliente'||v_sepa||'No. de credito'||v_sepa||'Tipo de Facturacion'||v_sepa||'Fecha de movimiento'||v_sepa||'Monto de facturaciÃÂÃÂ³n'||v_sepa||'Linea anterior'||v_sepa||'Linea Actual'||v_sepa||'Fecha reactivaciÃÂÃÂ³n'||v_sepa||'Observaciones'||' >>'||TRIM(cRuta)||'Incrementos_'||TRIM(sFechaArch)||'.txt';
	SYSTEM v_sql2;				
			
	FOREACH WITH HOLD
	
	SELECT numcte,num_credito,meses_ina,bc_score,describe_mov,fecha_facturacion,total_mov,linea_original,linea_nueva,descripcion
			INTO r_numcte,r_num_credito,r_meses_ina,r_bc_score,r_describe_mov,r_fecha_insert,r_total_mov,r_linea_original,r_linea_nueva,r_descripcion
		FROM cred_incrementos_cincuenta 
		
			SELECT COUNT (*)
			INTO vpago_consecutivo
			FROM bdicred:sd_amortiza_credito
			WHERE num_credito = r_num_credito
				AND fecha_cuota > p_fecha_rango_inc
				AND capital_status = 5;
				
			IF vpago_consecutivo < 3 THEN
				CONTINUE FOREACH;
			END IF;
			
			EXECUTE PROCEDURE bdicred:sp_incremento_reduccion (p_empresa,r_num_credito,r_meses_ina,r_linea_original,"3",r_bc_score,pNumTran)
			INTO vcod_retred,v_Mensajered, VNuevaLinea;
			
			IF vcod_retred::INTEGER <> 0 THEN
				LET v_cod_ret= '000001'; 
				LET v_Mensaje="Ocurrio un error al realizar Incremento de la linea";
				RETURN v_cod_ret, v_Mensaje;			
			END IF;				
			
			LET v_sql2 = 'echo '||TRIM(r_numcte)||v_sepa||TRIM(r_num_credito)||v_sepa||TRIM(v_Mensajered)||v_sepa||r_fecha_insert||v_sepa||r_total_mov||v_sepa||r_linea_original||v_sepa||VNuevaLinea||v_sepa||p_fecha||v_sepa||r_descripcion||' >>'||TRIM(cRuta)||'Incrementos_'||TRIM(sFechaArch)||'.txt';
			SYSTEM v_sql2;				
			
	END FOREACH;
	
-- ****************************************************************************
-- *   Reporte incrementos activados por disposiciÃÂÃÂ³n durante el mes anterior  *
-- ****************************************************************************		

	---- Obtiene el periodo para las fechas del reporte

	SELECT ADD_MONTHS (pri_dia_mes,-1) ,LAST_DAY(ADD_MONTHS (fecha_hoy,-1))
		INTO periodo1,periodo2
	FROM bdicred:sd_fechas WHERE empresa = p_empresa;
	

	FOREACH WITH HOLD

		SELECT numcte,num_credito,describe_mov,fecha_insert,fecha_facturacion,monto_facturacion,linea_anterior,linea_actual,descripcion
			INTO r_numcte,r_num_credito,r_describe_mov,r_fecha_insert,r_fecha_facturacion,r_total_mov,r_linea_original,r_linea_nueva,r_descripcion
		FROM "informix".sd_status_incremento_reduccion 
				WHERE empresa = p_empresa 
					AND tp_proceso = "I" AND marca_cincuenta = 0
					AND fecha_actualiza BETWEEN periodo1 AND periodo2					
	
		LET v_sql2 = 'echo '||TRIM(r_numcte)||v_sepa||TRIM(r_num_credito)||v_sepa||TRIM(r_describe_mov)||v_sepa||r_fecha_insert||v_sepa||r_total_mov||v_sepa||r_linea_original||v_sepa||r_linea_nueva||v_sepa||r_fecha_facturacion||v_sepa||r_descripcion||' >>'||TRIM(cRuta)||'Incrementos_'||TRIM(sFechaArch)||'.txt';
		SYSTEM v_sql2;	
		
	END FOREACH;
	

	LET v_Mensaje = "Proceso y Reporte exitoso";	

  RETURN v_cod_ret,v_Mensaje;
END; 

END PROCEDURE
DOCUMENT
'REALIZA LA REDUCCION DE LINEA E INCREMENTO MENSUAL AL 50%, Y GENERA REPORTE - RQM 09 499',
'AUTOR : ISRAEL TRAVIESO DIAZ',
'FECHA : SEP/2018',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_reporte_pagos_rechazados(p_empresa char(3))
    RETURNING CHAR(6)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje;

-- Fecha CreaciÃ³n: Octubre 2024
-- Reporte con los pagos rechazados por rebasar el monto maximo de Saldo a Favor RQI 25 379
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_retIB			CHAR(6);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoEjecSql   CHAR(100);
DEFINE cSQL                 CHAR(1000);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(700);
DEFINE cSQL3                CHAR(100);
DEFINE cruta                CHAR(100);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE cProceso             CHAR(4);
DEFINE dFechaHoy            DATE;
DEFINE dFechaIniMes         DATE;
DEFINE dFechaIni            DATE;
DEFINE dFechaFin            DATE;

--InicializaciÃ³n de variables
LET sql_err             = 0;
LET isam_err            = 0;
LET error_info          = "";
LET cCod_Ret            = '00000';
LET cCod_retIB          = '00000';
LET cMensaje            = 'PROCESO EXITOSO';
LET cruta               = "";
LET cnombre				= "Pagos_rechazados_sdo_favor_";
LET cnomarchivo         = "";
LET cnomarchivo1		= "";
LET cnomarchivoEjecSql  = "";
LET cSQL                = "";
LET cSQL1               = "";
LET cSQL2               = "";
LET cSQL3               = "";
LET cProceso            = '0086';
LET dFechaHoy           = DATE(1);
LET dFechaIniMes        = DATE(1);
LET dFechaIni           = DATE(1);
LET dFechaFin           = DATE(1);

--SET DEBUG FILE TO "/informix/sp_reporte_pagos_rechazados.out";
--TRACE ON;

SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;

 BEGIN
  ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;       
        CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCod_ret, trim(cMensaje)||'-'||isam_err::CHAR, '02') Returning cCod_retIB;
        RETURN cCod_ret, cMensaje;
    END EXCEPTION;

    CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCod_ret, 'INICIA CREACION REPORTE', '02') Returning cCod_RetIB;

	--Obtener ruta del archivo
    SELECT TRIM(valor)  INTO cruta FROM bdicred:sd_param WHERE empresa = p_empresa AND cod_param = '033';
    -- Obtiene la fecha del dia de hoy
    SELECT fecha_hoy, pri_dia_mes INTO dFechaHoy, dFechaIniMes FROM bdinteg:"informix".si_fechas WHERE empresa = p_empresa;

    LET cFechaGenArchivo = to_char(dFechaHoy,'%d%m%Y');
    LET dFechaFin = dFechaIniMes - 1 units day;
    LET dFechaIni = mdy(month(dFechaFin),1,year(dFechaFin));

	--Validar que existe el archivo	
	LET cnomarchivo1 = trim(cnombre)||'Aux_'||cFechaGenArchivo||'.txt ';
    LET cnomarchivo =  trim(cnombre)||cFechaGenArchivo||'.txt ';
    LET cnomarchivoEjecSql = 'Exec_Rep_PagosRechaSdoFavor.sql';

    LET cSQL='';
    LET cSQL = 'echo "Num Credito'||'|'||'Sucursal Pago'||'|'||'Fecha Pago Rechazado'||'|'||'Monto Pago Rechazado'||'|'||'Saldo Total'||'|'||'Monto Otorgado'
               || ' " >' || TRIM(cruta) || TRIM(cnomarchivo)||'';
    SYSTEM cSQL;

    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1);

    LET cSQL2 = " SELECT num_credito, sucursal, fecha_pago_rech, monto_pago_rech, sdo_total_liquidacion, monto_otorgado "        
                || " FROM bdicred:sd_pagos_rech_sdo_favor WHERE fecha_pago_rech >= '" ||dFechaIni|| "' AND fecha_pago_rech <= '" ||dFechaFin||"'";
                
    LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoEjecSql;
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoEjecSql;
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoEjecSql;
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/|$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
    SYSTEM cSql;

    --Borra el archivo de control.
    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || ' ' || TRIM(cruta) || cnomarchivo1;
    SYSTEM cSQL;

    LET cCod_Ret = '00000';
    LET cMensaje = 'PROCESO EXITOSO';

    CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCod_ret, 'TERMINA REPORTE PAGOS RECHAZADOS', '02') Returning cCod_RetIB;

    RETURN cCod_Ret, cMensaje;

 END;   --begin        

END PROCEDURE;