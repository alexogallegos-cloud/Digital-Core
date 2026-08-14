CREATE PROCEDURE "informix".sp_rpt_calificacion_riesgo_cliente()

	RETURNING CHAR(5) AS CodRet;

	DEFINE iSqlErr 	    						INTEGER;
	DEFINE cCodRet 	    						CHAR(5);
	DEFINE v_sql								CHAR(3000);
	DEFINE v_fecha_actual						DATE;
	DEFINE v_productos							INTEGER;
	DEFINE v_nombre								CHAR(35);
	DEFINE v_numcte								CHAR(20);
	DEFINE v_cuenta								CHAR(20);
	DEFINE v_cte_producto						CHAR(20);
	DEFINE v_tpo_persona						CHAR(2);
	DEFINE v_fecha_nac							DATE;
	DEFINE v_nacionalidad						CHAR(3);
	DEFINE v_estado								CHAR(2);
	DEFINE v_nombre_estado						CHAR(30);
	DEFINE v_prodtarjeta						CHAR(4);
	DEFINE v_fecha_insert						DATE;
	DEFINE v_sucursal							CHAR(4);
	DEFINE v_fecha_alta							DATE;
	DEFINE v_actividad							INTEGER;
	DEFINE v_subactividad						INTEGER;
	DEFINE v_puntaje_tpo_persona				DECIMAL(5,3);
	DEFINE v_porcentaje_tpo_persona				DECIMAL(5,3);
	DEFINE v_calificacion_tpo_persona			DECIMAL(5,3);
	DEFINE v_rango_edad_inicio_a				INTEGER;
	DEFINE v_rango_edad_fin_a					INTEGER;
	DEFINE v_rango_edad_puntaje_a				DECIMAL(5,3);
	DEFINE v_rango_edad_inicio_b				INTEGER;
	DEFINE v_rango_edad_fin_b					INTEGER;
	DEFINE v_rango_edad_puntaje_b				DECIMAL(5,3);
	DEFINE v_rango_edad_inicio_c				INTEGER;
	DEFINE v_rango_edad_fin_c					INTEGER;
	DEFINE v_rango_edad_puntaje_c				DECIMAL(5,3);
	DEFINE v_rango_edad_inicio_d				INTEGER;
	DEFINE v_rango_edad_fin_d					INTEGER;
	DEFINE v_rango_edad_puntaje_d				DECIMAL(5,3);
	DEFINE v_rango_edad_inicio_e				INTEGER;
	DEFINE v_rango_edad_fin_e					INTEGER;
	DEFINE v_rango_edad_puntaje_e				DECIMAL(5,3);
	DEFINE v_edad								DATE;
	DEFINE v_rango_edad							INTEGER;
	DEFINE v_puntaje_edad						DECIMAL(5,3);
	DEFINE v_porcentaje_edad					DECIMAL(5,3);
	DEFINE v_calificacion_edad					DECIMAL(5,3);
	DEFINE v_puntaje_nacionalidad				DECIMAL(5,3);
	DEFINE v_porcentaje_nacionalidad			DECIMAL(5,3);
	DEFINE v_calificacion_nacionalidad			DECIMAL(5,3);
	DEFINE v_puntaje_actividad					DECIMAL(5,3);
	DEFINE v_porcentaje_actividad				DECIMAL(5,3);
	DEFINE v_calificacion_actividad				DECIMAL(5,3);
	DEFINE v_puntaje_ubicacion					DECIMAL(5,3);
	DEFINE v_porcentaje_ubicacion				DECIMAL(5,3);
	DEFINE v_calificacion_ubicacion				DECIMAL(5,3);
	DEFINE v_puntaje_producto					DECIMAL(5,3);
	DEFINE v_porcentaje_producto				DECIMAL(5,3);
	DEFINE v_calificacion_producto				DECIMAL(5,3);
	DEFINE v_puntaje_inherente					DECIMAL(5,3);
	DEFINE v_porcentaje_inherente				DECIMAL(5,3);
	DEFINE v_calificacion_inherente				DECIMAL(5,3);
	DEFINE v_depositos_monto					CHAR(2);
	DEFINE v_retiros_monto						CHAR(2);
	DEFINE v_depositos_cantidad					CHAR(2);
	DEFINE v_retiros_cantidad					CHAR(2);
	DEFINE v_proced_aperturacta					CHAR(2);
	DEFINE v_proced_mantenercta					CHAR(2);
	DEFINE v_monto_mensual						CHAR(2);
	DEFINE v_puntaje_deposito					DECIMAL(5,3);
	DEFINE v_porcentaje_deposito				DECIMAL(5,3);
	DEFINE v_calificacion_deposito				DECIMAL(5,3);
	DEFINE v_puntaje_retiro						DECIMAL(5,3);
	DEFINE v_porcentaje_retiro					DECIMAL(5,3);
	DEFINE v_calificacion_retiro				DECIMAL(5,3);
	DEFINE v_puntaje_frecuencia_deposito		DECIMAL(5,3);
	DEFINE v_porcentaje_frecuencia_deposito		DECIMAL(5,3);
	DEFINE v_calificacion_frecuencia_deposito	DECIMAL(5,3);
	DEFINE v_puntaje_frecuencia_retiro			DECIMAL(5,3);
	DEFINE v_porcentaje_frecuencia_retiro		DECIMAL(5,3);
	DEFINE v_calificacion_frecuencia_retiro		DECIMAL(5,3);
	DEFINE v_calificacion_frecuencia			DECIMAL(5,3);
	DEFINE v_puntaje_origen_recurso				DECIMAL(5,3);
	DEFINE v_porcentaje_origen_recurso			DECIMAL(5,3);
	DEFINE v_calificacion_origen_recurso		DECIMAL(5,3);
	DEFINE v_puntaje_destino_recurso			DECIMAL(5,3);
	DEFINE v_porcentaje_destino_recurso			DECIMAL(5,3);
	DEFINE v_calificacion_destino_recurso		DECIMAL(5,3);
	DEFINE v_puntaje_importe_manejar_mes		DECIMAL(5,3);
	DEFINE v_porcentaje_importe_manejar_mes		DECIMAL(5,3);
	DEFINE v_calificacion_importe_manejar_mes	DECIMAL(5,3);
	DEFINE v_puntaje_transaccional				DECIMAL(5,3);
	DEFINE v_porcentaje_transaccional			DECIMAL(5,3);
	DEFINE v_calificacion_transaccional			DECIMAL(5,3);
	DEFINE v_persona_expuesta					INTEGER;
	DEFINE v_calificacion_persona_expuesta		DECIMAL(5,3);
	DEFINE v_calificacion_grado_riesgo			DECIMAL(5,3);
	DEFINE v_grado_riesgo						CHAR(20);
	DEFINE v_detalle_grado_riesgo				CHAR(100);
	DEFINE cCmd1								CHAR(2500);
	DEFINE pRutaDescarga						CHAR(100);
	DEFINE cRutaGral							CHAR(150);
	DEFINE bInTransaction						BOOLEAN;
	DEFINE ven_transacc							SMALLINT;
	DEFINE cSql									CHAR(2500);
	DEFINE dFechaHoy							DATE;
	DEFINE dHoraHoy								DATETIME HOUR TO MINUTE;
	DEFINE cFechaHoraArchivo					CHAR(15);
	DEFINE cNombreArchivo						CHAR(50);
	DEFINE v_riesgo_descripcion_bajo			CHAR(10);
	DEFINE v_riesgo_valor_bajo					DECIMAL(5,3);
	DEFINE v_riesgo_descripcion_medio			CHAR(10);
	DEFINE v_riesgo_valor_medio					DECIMAL(5,3);
	DEFINE v_riesgo_descripcion_alto			CHAR(10);
	DEFINE v_riesgo_valor_alto					DECIMAL(5,3);
	DEFINE iExistegr							INTEGER;
	
	DEFINE dFechaProceso 							DATE;
	DEFINE iCounter									INTEGER;
	DEFINE iExisteFecha								INTEGER;
	DEFINE iRecalculado								INTEGER;
	DEFINE iTotales									INTEGER;
	DEFINE v_calificacion_tpo_persona_vacio			DECIMAL(5,3);
	DEFINE v_calificacion_edad_vacio				DECIMAL(5,3);
	DEFINE v_calificacion_nacionalidad_vacio		DECIMAL(5,3);
	DEFINE v_calificacion_actividad_vacio			DECIMAL(5,3);
	DEFINE v_calificacion_ubicacion_vacio			DECIMAL(5,3);
	DEFINE v_calificacion_producto_vacio			DECIMAL(5,3);
	DEFINE v_calificacion_deposito_vacio			DECIMAL(5,3);
	DEFINE v_calificacion_retiro_vacio				DECIMAL(5,3);
	DEFINE v_calificacion_frecuencia_deposito_vacio	DECIMAL(5,3);
	DEFINE v_calificacion_frecuencia_retiro_vacio 	DECIMAL(5,3);
	DEFINE v_calificacion_origen_recurso_vacio		DECIMAL(5,3);
	DEFINE v_calificacion_destino_recurso_vacio		DECIMAL(5,3);
	DEFINE v_calificacion_importe_manejar_mes_vacio	DECIMAL(5,3);
	DEFINE v_calif_persona_exp						DECIMAL(5,3);
	DEFINE v_calif_persona_exp_vacio				DECIMAL(5,3);

	LET cCodRet 							= '00000';
	LET v_sql								= '';
	LET v_fecha_actual						= CURRENT;
	LET v_productos							= 0;
	LET v_nombre							= '';
	LET v_numcte							= '';
	LET v_cuenta							= '';
	LET v_cte_producto						= '';
	LET v_tpo_persona						= '';
	LET v_fecha_nac							= '';
	LET v_nacionalidad						= '';
	LET v_estado							= '';
	LET v_nombre_estado						= '';
	LET v_prodtarjeta						= '';
	LET v_fecha_insert						= '';
	LET v_sucursal							= '';
	LET v_fecha_alta						= '';
	LET v_puntaje_tpo_persona				= 0;
	LET v_porcentaje_tpo_persona			= 0;
	LET v_calificacion_tpo_persona			= 0;
	LET v_rango_edad_inicio_a				= 0;
	LET v_rango_edad_fin_a					= 0;
	LET v_rango_edad_puntaje_a				= 0;
	LET v_rango_edad_inicio_b				= 0;
	LET v_rango_edad_fin_b					= 0;
	LET v_rango_edad_puntaje_b				= 0;
	LET v_rango_edad_inicio_c				= 0;
	LET v_rango_edad_fin_c					= 0;
	LET v_rango_edad_puntaje_c				= 0;
	LET v_rango_edad_inicio_d				= 0;
	LET v_rango_edad_fin_d					= 0;
	LET v_rango_edad_puntaje_d				= 0;
	LET v_rango_edad_inicio_e				= 0;
	LET v_rango_edad_fin_e					= 0;
	LET v_rango_edad_puntaje_e				= 0;
	LET v_edad								= '';
	LET v_rango_edad						= 0;
	LET v_puntaje_edad						= 0;
	LET v_porcentaje_edad					= 0;
	LET v_calificacion_edad					= 0;
	LET v_rango_edad_inicio_a				= 0;
	LET v_rango_edad_fin_a					= 0;
	LET v_puntaje_nacionalidad				= 0;
	LET v_porcentaje_nacionalidad			= 0;
	LET v_calificacion_nacionalidad			= 0;
	LET v_actividad							= 0;
	LET v_subactividad						= 0;
	LET v_puntaje_actividad					= 0;
	LET v_porcentaje_actividad				= 0;
	LET v_calificacion_actividad			= 0;
	LET v_puntaje_ubicacion					= 0;
	LET v_porcentaje_ubicacion				= 0;
	LET v_calificacion_ubicacion			= 0;
	LET v_puntaje_producto					= 0;
	LET v_porcentaje_producto				= 0;
	LET v_calificacion_producto				= 0;
	LET v_puntaje_inherente					= 0;
	LET v_porcentaje_inherente				= 0;
	LET v_calificacion_inherente			= 0;
	LET v_depositos_monto					= '';
	LET v_retiros_monto						= '';
	LET v_depositos_cantidad				= '';
	LET v_retiros_cantidad					= '';
	LET v_proced_aperturacta				= '';
	LET v_proced_mantenercta				= '';
	LET v_monto_mensual						= '';
	LET v_puntaje_deposito					= 0;
	LET v_porcentaje_deposito				= 0;
	LET v_calificacion_deposito				= 0;
	LET v_puntaje_retiro					= 0;
	LET v_porcentaje_retiro					= 0;
	LET v_calificacion_retiro				= 0;
	LET v_puntaje_frecuencia_deposito		= 0;
	LET v_porcentaje_frecuencia_deposito	= 0;
	LET v_calificacion_frecuencia_deposito	= 0;
	LET v_puntaje_frecuencia_retiro			= 0;
	LET v_porcentaje_frecuencia_retiro		= 0;
	LET v_calificacion_frecuencia_retiro	= 0;
	LET v_calificacion_frecuencia			= 0;
	LET v_puntaje_origen_recurso			= 0;
	LET v_porcentaje_origen_recurso			= 0;
	LET v_calificacion_origen_recurso		= 0;
	LET v_puntaje_destino_recurso			= 0;
	LET v_porcentaje_destino_recurso		= 0;
	LET v_calificacion_destino_recurso		= 0;
	LET v_puntaje_importe_manejar_mes		= 0;
	LET v_porcentaje_importe_manejar_mes	= 0;
	LET v_calificacion_importe_manejar_mes	= 0;
	LET v_puntaje_transaccional				= 0;
	LET v_porcentaje_transaccional			= 0;
	LET v_calificacion_transaccional		= 0;
	LET v_persona_expuesta					= 0;
	LET v_calificacion_persona_expuesta		= 0;
	LET v_calificacion_grado_riesgo			= 0;
	LET v_grado_riesgo						= '';
	LET v_detalle_grado_riesgo				= '';
	LET cCmd1								= '';
	LET pRutaDescarga						= '/RESPALDOSNEW';
	LET cRutaGral							= '';
	LET bInTransaction						= 'f';
	LET ven_transacc						= 0;
	LET cSql								= '';
	LET dFechaHoy							= '';
	LET dHoraHoy							= '';
	LET cFechaHoraArchivo					= '';
	LET cNombreArchivo						= '';
	LET v_riesgo_descripcion_bajo			= '';
	LET v_riesgo_valor_bajo					= 0;
	LET v_riesgo_descripcion_medio			= '';
	LET v_riesgo_valor_medio				= 0;
	LET v_riesgo_descripcion_alto			= '';
	LET v_riesgo_valor_alto					= 0;
	LET iExistegr 							= 0;
	
	LET dFechaProceso 								= CURRENT;
	LET iCounter									= 0;
	LET iExisteFecha								= 0;
	LET iRecalculado								= 0;
	LET iTotales									= 0;
	LET v_calificacion_tpo_persona_vacio			= 0;
	LET v_calificacion_edad_vacio					= 0;
	LET v_calificacion_nacionalidad_vacio			= 0;
	LET v_calificacion_actividad_vacio				= 0;
	LET v_calificacion_ubicacion_vacio				= 0;
	LET v_calificacion_producto_vacio				= 0;
	LET v_calificacion_deposito_vacio				= 0;
	LET v_calificacion_retiro_vacio					= 0;
	LET v_calificacion_frecuencia_deposito_vacio	= 0;
	LET v_calificacion_frecuencia_retiro_vacio		= 0;
	LET v_calificacion_origen_recurso_vacio			= 0;
	LET v_calificacion_destino_recurso_vacio		= 0;
	LET v_calificacion_importe_manejar_mes_vacio	= 0;
	LET v_calif_persona_exp							= 0;
	LET v_calif_persona_exp_vacio					= 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;

			IF ven_transacc = 1 THEN
				ROLLBACK WORK;		
			END IF;
			
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/ifxsif01/emm/sp_rpt_calificacion_riesgo_cliente.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--let v_sql = ' echo "Reporte" > /ifxsif01/emm/reporte.txt';
		--system v_sql;
		
		--TRUNCATE bdinteg:si_cte_grado_riesgo;
		/*
		SELECT valor_vacio INTO v_calificacion_tpo_persona			FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '01';
		SELECT valor_vacio INTO v_calificacion_edad					FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '02';
		SELECT valor_vacio INTO v_calificacion_nacionalidad			FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '03';
		SELECT valor_vacio INTO v_calificacion_actividad			FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '04';
		SELECT valor_vacio INTO v_calificacion_ubicacion			FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '05';
		SELECT valor_vacio INTO v_calificacion_producto				FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '06';
		SELECT valor_vacio INTO v_calificacion_deposito				FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '08';
		SELECT valor_vacio INTO v_calificacion_retiro				FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '09';
		SELECT valor_vacio INTO v_calificacion_frecuencia_deposito	FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '10';
		SELECT valor_vacio INTO v_calificacion_frecuencia_retiro	FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '11';
		SELECT valor_vacio INTO v_calificacion_origen_recurso		FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '12';
		SELECT valor_vacio INTO v_calificacion_destino_recurso		FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '13';
		SELECT valor_vacio INTO v_calificacion_importe_manejar_mes	FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '14';
		*/
		
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Se asignan valores a los porcentaje y los valores vacios correspondientes
		SELECT valor, valor_vacio INTO v_porcentaje_tpo_persona, v_calificacion_tpo_persona_vacio	FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '01';
		SELECT valor, valor_vacio INTO v_porcentaje_edad, v_calificacion_edad_vacio					FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '02';
		SELECT valor, valor_vacio INTO v_porcentaje_nacionalidad, v_calificacion_nacionalidad_vacio	FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '03';
		SELECT valor, valor_vacio INTO v_porcentaje_actividad, v_calificacion_actividad_vacio		FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '04';
		SELECT valor, valor_vacio INTO v_porcentaje_ubicacion, v_calificacion_ubicacion_vacio		FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '05';
		SELECT valor, valor_vacio INTO v_porcentaje_producto, v_calificacion_producto_vacio			FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '06';
		
		SELECT valor, valor_vacio INTO v_porcentaje_deposito, v_calificacion_deposito_vacio							FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '08';
		SELECT valor, valor_vacio INTO v_porcentaje_retiro, v_calificacion_retiro_vacio								FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '09';
		SELECT valor, valor_vacio INTO v_porcentaje_frecuencia_deposito, v_calificacion_frecuencia_deposito_vacio	FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '10';
		SELECT valor, valor_vacio INTO v_porcentaje_frecuencia_retiro, v_calificacion_frecuencia_retiro_vacio		FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '11';
		SELECT valor, valor_vacio INTO v_porcentaje_origen_recurso, v_calificacion_origen_recurso_vacio				FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '12';
		SELECT valor, valor_vacio INTO v_porcentaje_destino_recurso, v_calificacion_destino_recurso_vacio			FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '13';
		SELECT valor, valor_vacio INTO v_porcentaje_importe_manejar_mes, v_calificacion_importe_manejar_mes_vacio	FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '14';
		
		SELECT valor INTO v_porcentaje_inherente FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '07';
		SELECT valor INTO v_porcentaje_transaccional FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '15';
		SELECT valor, valor_vacio INTO v_calif_persona_exp, v_calif_persona_exp_vacio FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '16';
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Se asignan los valores de GRADO RIESGO
		SELECT descripcion, valor INTO v_riesgo_descripcion_bajo, v_riesgo_valor_bajo	FROM si_cat_grado_riesgo WHERE id_grado = '01';
		SELECT descripcion, valor INTO v_riesgo_descripcion_medio, v_riesgo_valor_medio	FROM si_cat_grado_riesgo WHERE id_grado = '02';
		SELECT descripcion, valor INTO v_riesgo_descripcion_alto, v_riesgo_valor_alto	FROM si_cat_grado_riesgo WHERE id_grado = '03';
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		LET dFechaProceso = TODAY - 1;
		
				--CONTINUE FOREACH;
				SELECT count(*), recalculado
				INTO iExisteFecha, iRecalculado
				FROM informix.tmp_lista_fechas
				WHERE fecha = dFechaProceso
				GROUP BY recalculado;
		
			BEGIN WORK;
			
		FOREACH WITH HOLD
				
			SELECT 
				DISTINCT a.numcte,(SELECT count(*) FROM bdicheq:sc_maechq aa INNER JOIN bdicheq:sc_maenoc bb ON aa.cuenta = bb.cuenta WHERE aa.num_cte = a.numcte) productos
			INTO 
				v_numcte,v_productos
			FROM 
				bdinteg:si_cliente a
			WHERE 
				a.fecha_insert = TODAY - 1 AND a.tpo_persona = '01'
			
			SELECT count(*)
			INTO iExistegr
			FROM bdinteg:"informix".si_cte_grado_riesgo
			WHERE numcte = v_numcte;
			
			IF v_productos = 0 OR iExistegr > 0 THEN
				
				IF iRecalculado = 0 OR iRecalculado IS NULL THEN
					-- FOREACH por cliente a re-calcular
					--FOREACH WITH HOLD
						SELECT numcta
						INTO v_cuenta
						FROM informix.si_cte_grado_riesgo
						WHERE numcte = v_numcte;
						
						-- Se obtienen datos
							SELECT
								a.tpo_persona, a.fecha_insert, a.sucursal, a.fecha_alta,
								c.fecha_nac, c.nacionalidad,
								NVL(d.estado,'00'),
								b.producto, b.depositos_monto, b.retiros_monto, b.depositos_cantidad, b.retiros_cantidad, b.proced_aperturacta, b.proced_mantenercta, b.monto_mensual
							INTO
								v_tpo_persona, v_fecha_insert, v_sucursal, v_fecha_alta,
								v_fecha_nac, v_nacionalidad,
								v_estado,
								v_prodtarjeta, v_depositos_monto, v_retiros_monto, v_depositos_cantidad, v_retiros_cantidad, v_proced_aperturacta, v_proced_mantenercta, v_monto_mensual
							FROM  bdinteg:si_cliente a
							INNER JOIN bdicheq:sc_maechq b ON a.numcte = b.num_cte
							INNER JOIN bdicheq:sc_maenoc e ON b.cuenta = e.cuenta
							INNER JOIN bdinteg:si_ctepf c ON a.numcte = c.numcte
							LEFT JOIN bdinteg:si_direcciones_actual d ON a.numcte = d.numcte AND tipo_dir = '1'
							WHERE a.numcte = v_numcte 
								and b.cuenta = v_cuenta;
								
						-- Datos de actividad econÃ³mica
							SELECT a.claveopcionpuesto, a.clavesubopcionpuesto
							INTO v_actividad, v_subactividad
							FROM bdinteg:si_ingresos a
							WHERE a.numcte = v_numcte
								AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM si_ingresos WHERE numcte = a.numcte);
													
						-- PERSONA EXPUESTA
							SELECT COUNT(*) INTO v_persona_expuesta FROM bdinteg:si_cteppes WHERE numcte = v_numcte AND fecha_insert = v_fecha_insert;
							
						/************************************************************************************************************************************************************************************************************************/
						-- CALCULA CARACTERISTICAS INHERENTES
						/************************************************************************************************************************************************************************************************************************/
						--Calificar tipo persona
							SELECT puntaje_gdo_riesgo INTO v_puntaje_tpo_persona FROM si_tipper WHERE tpo_persona = v_tpo_persona;
							
							LET v_calificacion_tpo_persona = (v_puntaje_tpo_persona*v_porcentaje_tpo_persona)/100;
							
						--Califica edad
							SELECT edad_inicio,edad_final,puntaje_gdo_riesgo INTO v_rango_edad_inicio_a,v_rango_edad_fin_a,v_rango_edad_puntaje_a FROM si_cat_rango_edad WHERE codigo = '01';
							SELECT edad_inicio,edad_final,puntaje_gdo_riesgo INTO v_rango_edad_inicio_b,v_rango_edad_fin_b,v_rango_edad_puntaje_b FROM si_cat_rango_edad WHERE codigo = '02';
							SELECT edad_inicio,edad_final,puntaje_gdo_riesgo INTO v_rango_edad_inicio_c,v_rango_edad_fin_c,v_rango_edad_puntaje_c FROM si_cat_rango_edad WHERE codigo = '03';
							SELECT edad_inicio,edad_final,puntaje_gdo_riesgo INTO v_rango_edad_inicio_d,v_rango_edad_fin_d,v_rango_edad_puntaje_d FROM si_cat_rango_edad WHERE codigo = '04';
							SELECT edad_inicio,edad_final,puntaje_gdo_riesgo INTO v_rango_edad_inicio_e,v_rango_edad_fin_e,v_rango_edad_puntaje_e FROM si_cat_rango_edad WHERE codigo = '05';
							
							LET v_edad = YEAR(v_fecha_alta) - YEAR(v_fecha_nac);					
							LET v_rango_edad = CAST(v_edad as numeric);
							
							IF v_rango_edad <= v_rango_edad_fin_a THEN
								LET v_puntaje_edad = v_rango_edad_puntaje_a;
							ELIF v_rango_edad >= v_rango_edad_inicio_b AND v_rango_edad <= v_rango_edad_fin_b THEN
								LET v_puntaje_edad = v_rango_edad_puntaje_b;
							ELIF v_rango_edad >= v_rango_edad_inicio_c AND v_rango_edad <= v_rango_edad_fin_c THEN
								LET v_puntaje_edad = v_rango_edad_puntaje_c;
							ELIF v_rango_edad >= v_rango_edad_inicio_d AND v_rango_edad <= v_rango_edad_fin_d THEN
								LET v_puntaje_edad = v_rango_edad_puntaje_d;
							ELIF v_rango_edad >= v_rango_edad_inicio_e AND v_rango_edad <= v_rango_edad_fin_e THEN
								LET v_puntaje_edad = v_rango_edad_puntaje_e;
							END IF;
							
							LET v_calificacion_edad = (v_puntaje_edad*v_porcentaje_edad)/100;
							
						--Califica nacionalidad
							IF v_nacionalidad IS NOT NULL AND v_nacionalidad != '' AND LENGTH(v_nacionalidad) = 3 THEN
								SELECT puntaje_gdo_riesgo INTO v_puntaje_nacionalidad FROM si_nacion WHERE nacion = v_nacionalidad;
								
								IF v_puntaje_nacionalidad IS NOT NULL AND v_puntaje_nacionalidad != 0 THEN
									LET v_calificacion_nacionalidad = (v_puntaje_nacionalidad*v_porcentaje_nacionalidad)/100;
								ELSE
									LET v_calificacion_nacionalidad = v_calificacion_nacionalidad_vacio;
								END IF;
							ELSE
								LET v_calificacion_nacionalidad = v_calificacion_nacionalidad_vacio;
							END IF;
							
						--Califica actividad y subactividad
							IF v_actividad IS NOT NULL AND v_actividad != 0 AND v_subactividad IS NOT NULL AND v_subactividad != 0 THEN
								SELECT puntaje_gdo_riesgo INTO v_puntaje_actividad FROM si_actsubact WHERE id_act = v_actividad AND id_subact = v_subactividad;
								
								IF v_puntaje_actividad IS NOT NULL AND v_puntaje_actividad != 0 THEN
									LET v_calificacion_actividad = (v_puntaje_actividad*v_porcentaje_actividad)/100;
								ELSE
									LET v_calificacion_actividad = v_calificacion_actividad_vacio;
								END IF;
							ELSE
								LET v_calificacion_actividad = v_calificacion_actividad_vacio;
							END IF;
							
						--Califica ubicacion
							IF v_estado IS NOT NULL AND v_estado != '' AND v_estado != '00' AND LENGTH(v_estado) = 2 THEN
								SELECT puntaje_gdo_riesgo,nombre INTO v_puntaje_ubicacion,v_nombre_estado FROM si_estados WHERE estado = v_estado;
								
								IF v_puntaje_ubicacion IS NOT NULL AND v_puntaje_ubicacion != 0 THEN
									LET v_calificacion_ubicacion = (v_puntaje_ubicacion*v_porcentaje_ubicacion)/100;
								ELSE
									LET v_calificacion_ubicacion = v_calificacion_ubicacion_vacio;
								END IF;
							ELSE
								LET v_calificacion_ubicacion = v_calificacion_ubicacion_vacio;
							END IF;
							
						--Califica producto
							IF v_prodtarjeta IS NOT NULL AND v_prodtarjeta != '' AND LENGTH(v_prodtarjeta) = 4 THEN
								SELECT puntaje_gdo_riesgo INTO v_puntaje_producto FROM bdicheq:sc_producto WHERE producto = v_prodtarjeta;
								
								IF v_puntaje_producto IS NOT NULL AND v_puntaje_producto != 0 THEN
									LET v_calificacion_producto = (v_puntaje_producto*v_porcentaje_producto)/100;
								ELSE
									LET v_calificacion_producto = v_calificacion_producto_vacio;
								END IF;
							ELSE
								LET v_calificacion_producto = v_calificacion_producto_vacio;
							END IF;
							
						/************************************************************************************************************************************************************************************************************************/
						/************************************************************************************************************************************************************************************************************************/
						-- CALCULA CARACTERISTICAS TRANSACCIONALES
						/************************************************************************************************************************************************************************************************************************/
						--Califica deposito
							IF v_depositos_monto IS NOT NULL AND v_depositos_monto != '' AND LENGTH(v_depositos_monto) = 2 THEN
								SELECT puntaje_gdo_riesgo_deposito INTO v_puntaje_deposito FROM bdinteg:si_tipo_montomov WHERE codnummonto = v_depositos_monto;
								
								IF v_puntaje_deposito IS NOT NULL AND v_puntaje_deposito != 0 THEN
									LET v_calificacion_deposito = (v_puntaje_deposito*v_porcentaje_deposito)/100;
								ELSE
									LET v_calificacion_deposito = v_calificacion_deposito_vacio;
								END IF;
							ELSE
								LET v_calificacion_deposito = v_calificacion_deposito_vacio;
							END IF;
							
						--Califica retiro
							IF v_retiros_monto IS NOT NULL AND v_retiros_monto != '' AND LENGTH(v_retiros_monto) = 2 THEN
								SELECT puntaje_gdo_riesgo_retiro INTO v_puntaje_retiro FROM bdinteg:si_tipo_montomov WHERE codnummonto = v_retiros_monto;
								
								IF v_puntaje_retiro IS NOT NULL AND v_puntaje_retiro != 0 THEN
									LET v_calificacion_retiro = (v_puntaje_retiro*v_porcentaje_retiro)/100;
								ELSE
									LET v_calificacion_retiro = v_calificacion_retiro_vacio;
								END IF;
							ELSE
								LET v_calificacion_retiro = v_calificacion_retiro_vacio;
							END IF;
							
						--Califica frecuencia deposito
							IF v_depositos_cantidad IS NOT NULL AND v_depositos_cantidad != '' AND LENGTH(v_depositos_cantidad) = 2 THEN
								SELECT puntaje_gdo_riesgo_deposito INTO v_puntaje_frecuencia_deposito FROM si_tipo_nummov WHERE codnummo = v_depositos_cantidad;
								
								IF v_puntaje_frecuencia_deposito IS NOT NULL AND v_puntaje_frecuencia_deposito != 0 THEN
									LET v_calificacion_frecuencia_deposito = (v_puntaje_frecuencia_deposito*v_porcentaje_frecuencia_deposito)/100;
								ELSE
									LET v_calificacion_frecuencia_deposito = v_calificacion_frecuencia_deposito_vacio;
								END IF;
							ELSE
								LET v_calificacion_frecuencia_deposito = v_calificacion_frecuencia_deposito_vacio;
							END IF;
							
						--Califica frecuencia retiro
							IF v_retiros_cantidad IS NOT NULL AND v_retiros_cantidad != '' AND LENGTH(v_retiros_cantidad) = 2 THEN
								SELECT puntaje_gdo_riesgo_deposito INTO v_puntaje_frecuencia_retiro FROM si_tipo_nummov WHERE codnummo = v_retiros_cantidad;
								
								IF v_puntaje_frecuencia_retiro IS NOT NULL AND v_puntaje_frecuencia_retiro != 0 THEN
									LET v_calificacion_frecuencia_retiro = (v_puntaje_frecuencia_retiro*v_porcentaje_frecuencia_retiro)/100;
								ELSE
									LET v_calificacion_frecuencia_retiro = v_calificacion_frecuencia_retiro_vacio;
								END IF;
							ELSE
								LET v_calificacion_frecuencia_retiro = v_calificacion_frecuencia_retiro_vacio;
							END IF;
							
							LET v_calificacion_frecuencia = v_calificacion_frecuencia_deposito + v_calificacion_frecuencia_retiro;
							
						--Califica origen recurso
							IF v_proced_aperturacta IS NOT NULL AND v_proced_aperturacta != '' AND LENGTH(v_proced_aperturacta) = 2 THEN
								SELECT puntaje_gdo_riesgo INTO v_puntaje_origen_recurso FROM si_tipo_procedencia WHERE procedencia = v_proced_aperturacta;
								
								IF v_puntaje_origen_recurso IS NOT NULL AND v_puntaje_origen_recurso != 0 THEN
									LET v_calificacion_origen_recurso = (v_puntaje_origen_recurso*v_porcentaje_origen_recurso)/100;
								ELSE
									LET v_calificacion_origen_recurso = v_calificacion_origen_recurso_vacio;
								END IF;
							ELSE
								LET v_calificacion_origen_recurso = v_calificacion_origen_recurso_vacio;
							END IF;
							
						--Califica destino recurso
							IF v_proced_mantenercta IS NOT NULL AND v_proced_mantenercta != '' AND LENGTH(v_proced_mantenercta) = 2 THEN
								SELECT puntaje_gdo_riesgo INTO v_puntaje_destino_recurso FROM si_cat_tipo_procedencia_uso WHERE procedencia = v_proced_mantenercta;
								
								IF v_puntaje_destino_recurso IS NOT NULL AND v_puntaje_destino_recurso != 0 THEN
									LET v_calificacion_destino_recurso = (v_puntaje_destino_recurso*v_porcentaje_destino_recurso)/100;
								ELSE
									LET v_calificacion_destino_recurso = v_calificacion_destino_recurso_vacio;
								END IF;
							ELSE
								LET v_calificacion_destino_recurso = v_calificacion_destino_recurso_vacio;
							END IF;
							
						--Califica importe manejar mes
							IF v_monto_mensual IS NOT NULL AND v_monto_mensual != '' AND LENGTH(v_monto_mensual) = 2 THEN
								SELECT puntaje_gdo_riesgo INTO v_puntaje_importe_manejar_mes FROM si_tipo_montomes WHERE codigo = v_monto_mensual;
								
								IF v_puntaje_importe_manejar_mes IS NOT NULL AND v_puntaje_importe_manejar_mes != 0 THEN
									LET v_calificacion_importe_manejar_mes = (v_puntaje_importe_manejar_mes*v_porcentaje_importe_manejar_mes)/100;
								ELSE
									LET v_calificacion_importe_manejar_mes = v_calificacion_importe_manejar_mes_vacio;
								END IF;
							ELSE
								LET v_calificacion_importe_manejar_mes = v_calificacion_importe_manejar_mes_vacio;
							END IF;
							
						/************************************************************************************************************************************************************************************************************************/
						/************************************************************************************************************************************************************************************************************************/
						-- CALCULA GRADO DE RIESGO
						/************************************************************************************************************************************************************************************************************************/
							LET v_puntaje_inherente = v_calificacion_tpo_persona + v_calificacion_edad + v_calificacion_nacionalidad + v_calificacion_actividad + v_calificacion_ubicacion + v_calificacion_producto;
							LET v_puntaje_transaccional = v_calificacion_deposito + v_calificacion_retiro + v_calificacion_frecuencia + v_calificacion_origen_recurso + v_calificacion_destino_recurso + v_calificacion_importe_manejar_mes;
							
							LET v_calificacion_inherente = (v_puntaje_inherente*v_porcentaje_inherente)/100;
							LET v_calificacion_transaccional = (v_puntaje_transaccional*v_porcentaje_transaccional)/100;
							
							IF v_persona_expuesta > 0 THEN
								LET v_calificacion_persona_expuesta = v_calif_persona_exp;
							ELSE 
								LET v_calificacion_persona_expuesta = v_calif_persona_exp_vacio;
							END IF;
							
							LET v_calificacion_grado_riesgo = v_calificacion_inherente + v_calificacion_transaccional + v_calificacion_persona_expuesta;
							
							IF v_calificacion_grado_riesgo <= v_riesgo_valor_bajo THEN
								LET v_grado_riesgo = v_riesgo_descripcion_bajo;
							ELIF v_calificacion_grado_riesgo < v_riesgo_valor_alto THEN
								LET v_grado_riesgo = v_riesgo_descripcion_medio;
							ELIF v_calificacion_grado_riesgo >= v_riesgo_valor_alto THEN
								LET v_grado_riesgo = v_riesgo_descripcion_alto;
							END IF;
							
						/************************************************************************************************************************************************************************************************************************/
						/************************************************************************************************************************************************************************************************************************/
						-- ACTUALIZA DATOS DE GRADO DE RIESGO DEL CLIENTE 
						/************************************************************************************************************************************************************************************************************************/
						UPDATE informix.si_cte_grado_riesgo 
						SET  
							calif_tipo_persona=v_calificacion_tpo_persona, calif_fecha_nacimiento=v_calificacion_edad, calif_nacionalidad=v_calificacion_nacionalidad, calif_actividad=v_calificacion_actividad, calif_ubicacion=v_calificacion_ubicacion, calif_producto=v_calificacion_producto, calif_carac_inherente=v_calificacion_inherente, 
							calif_deposito=v_calificacion_deposito, calif_retiro=v_calificacion_retiro, calif_frecuencia=v_calificacion_frecuencia, calif_origen_recurso=v_calificacion_origen_recurso, calif_destino_recurso=v_calificacion_destino_recurso, calif_importe_manejar_mes=v_calificacion_importe_manejar_mes, calif_carac_transaccional=v_calificacion_transaccional, 
							calif_persona_expuesta=v_calificacion_persona_expuesta, calif_gdo_riesgo=v_calificacion_grado_riesgo, gdo_riesgo=v_grado_riesgo, 
							fecha_insert=TODAY
						WHERE numcte = v_numcte;
						
						/************************************************************************************************************************************************************************************************************************/
						
						LET iCounter = iCounter + 1;
						LET iTotales = iTotales + 1;
						
						IF iCounter >= 1000 THEN
							COMMIT WORK;
							LET iCounter = 0;
							BEGIN WORK;
						END IF;
						
					--END FOREACH;
				END IF;
			ELSE
				FOREACH
				
					SELECT FIRST 1
						b.cuenta,
						a.numcte,
						TRIM(a.apell_paterno)||' '||TRIM(a.apell_materno)||' '||TRIM(a.nombre1)||' '||TRIM(a.nombre2) nombre_cliente,
						a.tpo_persona,
						c.fecha_nac,
						c.nacionalidad,
						d.estado,
						b.producto,
						a.fecha_insert,
						a.sucursal,
						a.fecha_alta
					INTO
						v_cuenta,
						v_cte_producto,
						v_nombre,
						v_tpo_persona,
						v_fecha_nac,
						v_nacionalidad,
						v_estado,
						v_prodtarjeta,
						v_fecha_insert,
						v_sucursal,
						v_fecha_alta
					FROM 
						bdinteg:si_cliente a
					INNER JOIN 
						bdicheq:sc_maechq b ON a.numcte = b.num_cte
					INNER JOIN
						bdicheq:sc_maenoc e ON b.cuenta = e.cuenta
					INNER JOIN 
						bdinteg:si_ctepf c ON a.numcte = c.numcte
					INNER JOIN 
						bdinteg:si_direcciones_actual d ON a.numcte = d.numcte AND d.secuencia = (
							SELECT MAX(secuencia) FROM bdinteg:si_direcciones_actual WHERE numcte = a.numcte AND tipo_dir = '1')
					WHERE 
						a.fecha_insert = TODAY - 1 AND a.tpo_persona = '01' AND a.numcte = v_numcte
					
					/* CARACTERISTICAS INHERENTES */
					--Calificar tipo persona
					SELECT puntaje_gdo_riesgo INTO v_puntaje_tpo_persona FROM si_tipper WHERE tpo_persona = v_tpo_persona;
					
					SELECT valor INTO v_porcentaje_tpo_persona FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '01';
					
					LET v_calificacion_tpo_persona = (v_puntaje_tpo_persona*v_porcentaje_tpo_persona)/100;
					
					--Califica edad
					SELECT edad_inicio,edad_final,puntaje_gdo_riesgo INTO v_rango_edad_inicio_a,v_rango_edad_fin_a,v_rango_edad_puntaje_a FROM si_cat_rango_edad WHERE codigo = '01';
					
					SELECT edad_inicio,edad_final,puntaje_gdo_riesgo INTO v_rango_edad_inicio_b,v_rango_edad_fin_b,v_rango_edad_puntaje_b FROM si_cat_rango_edad WHERE codigo = '02';
					
					SELECT edad_inicio,edad_final,puntaje_gdo_riesgo INTO v_rango_edad_inicio_c,v_rango_edad_fin_c,v_rango_edad_puntaje_c FROM si_cat_rango_edad WHERE codigo = '03';
					
					SELECT edad_inicio,edad_final,puntaje_gdo_riesgo INTO v_rango_edad_inicio_d,v_rango_edad_fin_d,v_rango_edad_puntaje_d FROM si_cat_rango_edad WHERE codigo = '04';
					
					SELECT edad_inicio,edad_final,puntaje_gdo_riesgo INTO v_rango_edad_inicio_e,v_rango_edad_fin_e,v_rango_edad_puntaje_e FROM si_cat_rango_edad WHERE codigo = '05';
					
					LET v_edad = YEAR(v_fecha_actual) - YEAR(v_fecha_nac);
					
					LET v_rango_edad = CAST(v_edad as numeric);
					
					IF v_rango_edad <= v_rango_edad_fin_a THEN
						LET v_puntaje_edad = v_rango_edad_puntaje_a;
					ELIF v_rango_edad >= v_rango_edad_inicio_b AND v_rango_edad <= v_rango_edad_fin_b THEN
						LET v_puntaje_edad = v_rango_edad_puntaje_b;
					ELIF v_rango_edad >= v_rango_edad_inicio_c AND v_rango_edad <= v_rango_edad_fin_c THEN
						LET v_puntaje_edad = v_rango_edad_puntaje_c;
					ELIF v_rango_edad >= v_rango_edad_inicio_d AND v_rango_edad <= v_rango_edad_fin_d THEN
						LET v_puntaje_edad = v_rango_edad_puntaje_d;
					ELIF v_rango_edad >= v_rango_edad_inicio_e AND v_rango_edad <= v_rango_edad_fin_e THEN
						LET v_puntaje_edad = v_rango_edad_puntaje_e;
					END IF;
					
					SELECT valor INTO v_porcentaje_edad FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '02';
					
					LET v_calificacion_edad = (v_puntaje_edad*v_porcentaje_edad)/100;
					
					--Califica nacionalidad
					IF v_nacionalidad IS NOT NULL AND v_nacionalidad != '' AND LENGTH(v_nacionalidad) = 3 THEN
						SELECT puntaje_gdo_riesgo INTO v_puntaje_nacionalidad FROM si_nacion WHERE nacion = v_nacionalidad;
						
						IF v_puntaje_nacionalidad IS NOT NULL AND v_puntaje_nacionalidad != 0 THEN
							SELECT valor INTO v_porcentaje_nacionalidad FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '03';
							
							LET v_calificacion_nacionalidad = (v_puntaje_nacionalidad*v_porcentaje_nacionalidad)/100;
						END IF;
					END IF;
					
					--Califica actividad y subactividad
					SELECT
						a.claveopcionpuesto,a.clavesubopcionpuesto
					INTO
						v_actividad,v_subactividad
					FROM 
						bdinteg:si_ingresos a
					WHERE 
						a.numcte = v_cte_producto
						AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM si_ingresos WHERE numcte = a.numcte);
					
					IF v_actividad IS NOT NULL AND v_actividad != 0 AND v_subactividad IS NOT NULL AND v_subactividad != 0 THEN
						SELECT puntaje_gdo_riesgo INTO v_puntaje_actividad FROM si_actsubact WHERE id_act = v_actividad AND id_subact = v_subactividad;
						
						IF v_puntaje_actividad IS NOT NULL AND v_puntaje_actividad != 0 THEN
							SELECT valor INTO v_porcentaje_actividad FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '04';
						
							LET v_calificacion_actividad = (v_puntaje_actividad*v_porcentaje_actividad)/100;
						END IF;
					END IF;
					
					--Califica ubicacion
					IF v_estado IS NOT NULL AND v_estado != '' AND v_estado != '00' AND LENGTH(v_estado) = 2 THEN
						SELECT puntaje_gdo_riesgo,nombre INTO v_puntaje_ubicacion,v_nombre_estado FROM si_estados WHERE estado = v_estado;
						
						IF v_puntaje_ubicacion IS NOT NULL AND v_puntaje_ubicacion != 0 THEN
							SELECT valor INTO v_porcentaje_ubicacion FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '05';
							
							LET v_calificacion_ubicacion = (v_puntaje_ubicacion*v_porcentaje_ubicacion)/100;
						END IF;
					END IF;
					
					--Califica producto
					IF v_prodtarjeta IS NOT NULL AND v_prodtarjeta != '' AND LENGTH(v_prodtarjeta) = 4 THEN
						SELECT puntaje_gdo_riesgo INTO v_puntaje_producto FROM bdicheq:sc_producto WHERE producto = v_prodtarjeta;
						
						IF v_puntaje_producto IS NOT NULL AND v_puntaje_producto != 0 THEN
							SELECT valor INTO v_porcentaje_producto FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '06';
							
							LET v_calificacion_producto = (v_puntaje_producto*v_porcentaje_producto)/100;
						END IF;
					END IF;
					
					--Califica caracteristicas inherentes
					LET v_puntaje_inherente = v_calificacion_tpo_persona + v_calificacion_edad + v_calificacion_nacionalidad + v_calificacion_actividad + v_calificacion_ubicacion + v_calificacion_producto;
					
					SELECT valor INTO v_porcentaje_inherente FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '07';
					
					LET v_calificacion_inherente = (v_puntaje_inherente*v_porcentaje_inherente)/100;
					
					
					/* CARACTERISTICAS TRANSACCIONALES */
					SELECT FIRST 1 
						depositos_monto,retiros_monto,depositos_cantidad,retiros_cantidad,proced_aperturacta,proced_mantenercta,monto_mensual
					INTO
						v_depositos_monto,v_retiros_monto,v_depositos_cantidad,v_retiros_cantidad,v_proced_aperturacta,v_proced_mantenercta,v_monto_mensual
					FROM 
						bdicheq:sc_maechq 
					WHERE 
						num_cte = v_cte_producto and cuenta = v_cuenta;
						
					--Califica deposito
					IF v_depositos_monto IS NOT NULL AND v_depositos_monto != '' AND LENGTH(v_depositos_monto) = 2 THEN
						SELECT puntaje_gdo_riesgo_deposito INTO v_puntaje_deposito FROM bdinteg:si_tipo_montomov WHERE codnummonto = v_depositos_monto;
						
						IF v_puntaje_deposito IS NOT NULL AND v_puntaje_deposito != 0 THEN
							SELECT valor INTO v_porcentaje_deposito FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '08';
							
							LET v_calificacion_deposito = (v_puntaje_deposito*v_porcentaje_deposito)/100;
						END IF;
					END IF;
					
					--Califica retiro
					IF v_retiros_monto IS NOT NULL AND v_retiros_monto != '' AND LENGTH(v_retiros_monto) = 2 THEN
						SELECT puntaje_gdo_riesgo_retiro INTO v_puntaje_retiro FROM bdinteg:si_tipo_montomov WHERE codnummonto = v_retiros_monto;
						
						IF v_puntaje_retiro IS NOT NULL AND v_puntaje_retiro != 0 THEN
							SELECT valor INTO v_porcentaje_retiro FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '09';
							
							LET v_calificacion_retiro = (v_puntaje_retiro*v_porcentaje_retiro)/100;
						END IF;
					END IF;
					
					--Califica frecuencia deposito
					IF v_depositos_cantidad IS NOT NULL AND v_depositos_cantidad != '' AND LENGTH(v_depositos_cantidad) = 2 THEN
						SELECT puntaje_gdo_riesgo_deposito INTO v_puntaje_frecuencia_deposito FROM si_tipo_nummov WHERE codnummo = v_depositos_cantidad;
						
						IF v_puntaje_frecuencia_deposito IS NOT NULL AND v_puntaje_frecuencia_deposito != 0 THEN
							SELECT valor INTO v_porcentaje_frecuencia_deposito FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '10';
							
							LET v_calificacion_frecuencia_deposito = (v_puntaje_frecuencia_deposito*v_porcentaje_frecuencia_deposito)/100;
						END IF;
					END IF;
					
					--Califica frecuencia retiro
					IF v_retiros_cantidad IS NOT NULL AND v_retiros_cantidad != '' AND LENGTH(v_retiros_cantidad) = 2 THEN
						SELECT puntaje_gdo_riesgo_deposito INTO v_puntaje_frecuencia_retiro FROM si_tipo_nummov WHERE codnummo = v_retiros_cantidad;
						
						IF v_puntaje_frecuencia_retiro IS NOT NULL AND v_puntaje_frecuencia_retiro != 0 THEN
							SELECT valor INTO v_porcentaje_frecuencia_retiro FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '11';
							
							LET v_calificacion_frecuencia_retiro = (v_puntaje_frecuencia_retiro*v_porcentaje_frecuencia_retiro)/100;
						END IF;
					END IF;
					
					LET v_calificacion_frecuencia = v_calificacion_frecuencia_deposito + v_calificacion_frecuencia_retiro;
					
					--Califica origen recurso
					IF v_proced_aperturacta IS NOT NULL AND v_proced_aperturacta != '' AND LENGTH(v_proced_aperturacta) = 2 THEN
						SELECT puntaje_gdo_riesgo INTO v_puntaje_origen_recurso FROM si_tipo_procedencia WHERE procedencia = v_proced_aperturacta;
						
						IF v_puntaje_origen_recurso IS NOT NULL AND v_puntaje_origen_recurso != 0 THEN
							SELECT valor INTO v_porcentaje_origen_recurso FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '12';
							
							LET v_calificacion_origen_recurso = (v_puntaje_origen_recurso*v_porcentaje_origen_recurso)/100;
						END IF;
					END IF;
					
					--Califica destino recurso
					IF v_proced_mantenercta IS NOT NULL AND v_proced_mantenercta != '' AND LENGTH(v_proced_mantenercta) = 2 THEN
						SELECT puntaje_gdo_riesgo INTO v_puntaje_destino_recurso FROM si_cat_tipo_procedencia_uso WHERE procedencia = v_proced_mantenercta;
						
						IF v_puntaje_destino_recurso IS NOT NULL AND v_puntaje_destino_recurso != 0 THEN
							SELECT valor INTO v_porcentaje_destino_recurso FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '13';
							
							LET v_calificacion_destino_recurso = (v_puntaje_destino_recurso*v_porcentaje_destino_recurso)/100;
						END IF;
					END IF;
					
					--Califica importe manejar mes
					IF v_monto_mensual IS NOT NULL AND v_monto_mensual != '' AND LENGTH(v_monto_mensual) = 2 THEN
						SELECT puntaje_gdo_riesgo INTO v_puntaje_importe_manejar_mes FROM si_tipo_montomes WHERE codigo = v_monto_mensual;
						
						IF v_puntaje_importe_manejar_mes IS NOT NULL AND v_puntaje_importe_manejar_mes != 0 THEN
							SELECT valor INTO v_porcentaje_importe_manejar_mes FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '14';
							
							LET v_calificacion_importe_manejar_mes = (v_puntaje_importe_manejar_mes*v_porcentaje_importe_manejar_mes)/100;
						END IF;
					END IF;
					
					--Califica caracteristicas transaccionales
					LET v_puntaje_transaccional = v_calificacion_deposito + v_calificacion_retiro + v_calificacion_frecuencia_deposito + v_calificacion_frecuencia_retiro + v_calificacion_origen_recurso + v_calificacion_destino_recurso + v_calificacion_importe_manejar_mes;
					
					SELECT valor INTO v_porcentaje_transaccional FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '15';
					
					LET v_calificacion_transaccional = (v_puntaje_transaccional*v_porcentaje_transaccional)/100;
					
					/* PERSONA EXPUESTA */
					SELECT COUNT(*) INTO v_persona_expuesta FROM bdinteg:si_cteppes WHERE numcte = v_cte_producto AND fecha_insert = v_fecha_insert;
					
					IF v_persona_expuesta > 0 THEN
						SELECT valor INTO v_calificacion_persona_expuesta FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '16';
					END IF;
					
					/* CALIFICA GRADO RIESGO*/
					SELECT descripcion,valor INTO v_riesgo_descripcion_bajo,v_riesgo_valor_bajo FROM si_cat_grado_riesgo WHERE id_grado = '01';
					SELECT descripcion,valor INTO v_riesgo_descripcion_medio,v_riesgo_valor_medio FROM si_cat_grado_riesgo WHERE id_grado = '02';
					SELECT descripcion,valor INTO v_riesgo_descripcion_alto,v_riesgo_valor_alto FROM si_cat_grado_riesgo WHERE id_grado = '03';
					
					LET v_calificacion_grado_riesgo = v_calificacion_inherente + v_calificacion_transaccional + v_calificacion_persona_expuesta;
					
					IF v_calificacion_grado_riesgo <= v_riesgo_valor_bajo THEN
						LET v_grado_riesgo = v_riesgo_descripcion_bajo;
					ELIF v_calificacion_grado_riesgo < v_riesgo_valor_alto THEN
						LET v_grado_riesgo = v_riesgo_descripcion_medio;
					ELIF v_calificacion_grado_riesgo >= v_riesgo_valor_alto THEN
						LET v_grado_riesgo = v_riesgo_descripcion_alto;
					END IF;
					
					
					--let v_sql = 'echo "'||TRIM(v_numcte)||' - '||v_nombre||' - '||v_calificacion_tpo_persona||' - '||v_calificacion_edad||' - '||v_calificacion_nacionalidad||' - '||v_calificacion_actividad||' - '||v_calificacion_ubicacion||' - '||v_calificacion_producto||' - '||v_calificacion_inherente||' - '||v_calificacion_deposito||' - '||v_calificacion_retiro||' - '||v_calificacion_frecuencia||' - '||v_calificacion_origen_recurso||' - '||v_calificacion_destino_recurso||' - '||v_calificacion_importe_manejar_mes||' - '||v_calificacion_transaccional||' - '||v_calificacion_persona_expuesta||' - '||v_calificacion_grado_riesgo||' - '||v_grado_riesgo||'" >> /ifxsif01/emm/reporte.txt';
					--system v_sql;
					
					/* INSERTAR EN TABLA si_cte_grado_riesgo */
					INSERT INTO bdinteg:si_cte_grado_riesgo(
						numcte,
						nombre_cte,
						numcta,
						sucursal_apertura,
						fecha_alta,
						fecha_nacimiento,
						estado,
						calif_tipo_persona,
						calif_fecha_nacimiento,
						calif_nacionalidad,
						calif_actividad,
						calif_ubicacion,
						calif_producto,
						calif_carac_inherente,
						calif_deposito,
						calif_retiro,
						calif_frecuencia,
						calif_origen_recurso,
						calif_destino_recurso,
						calif_importe_manejar_mes,
						calif_carac_transaccional,
						calif_persona_expuesta,
						calif_gdo_riesgo,
						gdo_riesgo,
						detalle_gdo_riesgo,
						user_insert,
						fecha_insert
					) 
					VALUES(
						v_cte_producto,
						v_nombre,
						v_cuenta,
						v_sucursal,
						v_fecha_alta,
						v_fecha_nac,
						v_nombre_estado,
						v_calificacion_tpo_persona,
						v_calificacion_edad,
						v_calificacion_nacionalidad,
						v_calificacion_actividad,
						v_calificacion_ubicacion,
						v_calificacion_producto,
						v_calificacion_inherente,
						v_calificacion_deposito,
						v_calificacion_retiro,
						v_calificacion_frecuencia,
						v_calificacion_origen_recurso,
						v_calificacion_destino_recurso,
						v_calificacion_importe_manejar_mes,
						v_calificacion_transaccional,
						v_calificacion_persona_expuesta,
						v_calificacion_grado_riesgo,
						v_grado_riesgo,
						v_detalle_grado_riesgo,
						'informix',
						TODAY
					);
				
				END FOREACH;
				
			END IF;
		
		END FOREACH;
			
			COMMIT WORK;
			
				-- Se actualiza tabla tmp_lista_fechas
				IF iExisteFecha > 0 THEN
					UPDATE informix.tmp_lista_fechas SET recalculado = 1 WHERE fecha = dFechaProceso;
				ELSE
					INSERT INTO informix.tmp_lista_fechas (fecha, recalculado) VALUES (dFechaProceso, 1);
				END IF;
				
		
		/* GENERAR REPORTE EXCEL */
		LET dFechaHoy = TODAY - 1;
		LET dHoraHoy = TODAY - 1;
		LET cFechaHoraArchivo = YEAR(dFechaHoy)||LPAD(MONTH(dFechaHoy),2,0)||LPAD(DAY(dFechaHoy),2,0)||'_'||LPAD(CAST(SUBSTR(dHoraHoy,1,2) AS CHAR(2)),2,0)||LPAD(CAST(SUBSTR(dHoraHoy,4,2) AS CHAR(2)),2,0);
		LET cNombreArchivo = 'reporte_grado_riesgo_clientes_'||TRIM(cFechaHoraArchivo)||'.xls';
		
		LET cCmd1 = "SELECT 'FECHA','CLIENTE','NOMBRE','CUENTA','SUCURSAL','FECHA ALTA','FECHA NACIMIENTO','ESTADO','C. TIPO PERSONA','C. FECHA NACIMIENTO','C. NACIONALIDAD','C. ACTIVIDAD','C. UBICACION','C. PRODUCTO','C. CARACTERISTICA INHERENTE','C. DEPOSITO','C. RETIRO','C. FRECUENCIA','C. ORIGEN RECURSO','C. DESTINO RECURSO','C. IMPORTE MANEJAR','C. CARACTERISTICA TRANSACCIONAL','C. PERSONA EXPUESTA','C. GRADO RIESGO','GRADO RIESGO','DETALLE' FROM systables WHERE tabid = 1 UNION ALL "
					|| "SELECT TO_CHAR(gdo.fecha_insert,'%d/%m/%Y'),gdo.numcte,gdo.nombre_cte,gdo.numcta,gdo.sucursal_apertura,TO_CHAR(gdo.fecha_alta,'%d/%m/%Y'),TO_CHAR(gdo.fecha_nacimiento,'%d/%m/%Y'),NVL(est.nombre,''),TO_CHAR(gdo.calif_tipo_persona),TO_CHAR(gdo.calif_fecha_nacimiento),TO_CHAR(gdo.calif_nacionalidad),TO_CHAR(gdo.calif_actividad),TO_CHAR(gdo.calif_ubicacion),TO_CHAR(gdo.calif_producto),TO_CHAR(gdo.calif_carac_inherente),TO_CHAR(gdo.calif_deposito),TO_CHAR(gdo.calif_retiro),TO_CHAR(gdo.calif_frecuencia),TO_CHAR(gdo.calif_origen_recurso),TO_CHAR(gdo.calif_destino_recurso),TO_CHAR(gdo.calif_importe_manejar_mes),TO_CHAR(gdo.calif_carac_transaccional),TO_CHAR(gdo.calif_persona_expuesta),TO_CHAR(gdo.calif_gdo_riesgo),gdo.gdo_riesgo,gdo.detalle_gdo_riesgo "
					|| "FROM si_cte_grado_riesgo gdo "
					|| "LEFT JOIN si_estados est ON est.estado = gdo.estado "
					|| "WHERE fecha_alta = TODAY - 1";

		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			LET cSql = '';
			LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query_calificacion_riesgo_clientes.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query_calificacion_riesgo_clientes.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/ifxsif01/bin/dbaccess bdinteg '||TRIM(pRutaDescarga)||'query_calificacion_riesgo_clientes.sql';
			--LET cSql = '/informix/bin/dbaccess bdinteg '||TRIM(pRutaDescarga)||'query_calificacion_riesgo_clientes.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query_calificacion_riesgo_clientes.sql';
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de linea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo original
			LET cSql = '';
			LET cSql = "rm -rf "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el caracter delimitador ';' al final de la linea
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de linea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
								
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
							
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);	
			
		COMMIT WORK;
		
		LET ven_transacc = 0;
		
		RETURN cCodRet;
		
		/*
		execute procedure sp_rpt_calificacion_riesgo_cliente();
		*/

	END;
	
END PROCEDURE
DOCUMENT
'SP para generar reporte de Calificacion Inicial de Riesgo de Cliente',
'AUTOR : EMM',
'Area: Sitemas',
'Gerencia de Mtto y Soporte IV',
'Coordinador: Victor Sanchez',
'Fecha: 31/Diciembre/2022',
'Version: 1.0.0',
'BD: bdinteg',
'FECHA: 19/01/2023',
'REALIZO: Uriel Amador Islas',
'DESCRIPCION: Se corrige calculo de calificaciÃÂ³n de producto',
'FECHA: 28/02/2023',
'REALIZO: Uriel Amador Islas',
'DESCRIPCION: Se agrega validaciÃÂ³n por tipo de direcciÃÂ³n al obtener la direcciÃÂ³n del cliente',
'FECHA: 13/06/2024',
'REALIZO: Uriel Amador Islas',
'DESCRIPCION: Se valida que el cliente no exista en la tabla si_cte_grado_riesgo',
'FECHA: 13/09/2024',
'REALIZO: Uriel Amador Islas',
'DESCRIPCION: Se cambia filtro fecha_insert por fecha_alta, en la consulta usada para la generacion del reporte, ademas se agrega la consulta a la descripcion del estado';

CREATE PROCEDURE "informix".sp_consultarctemoral_03(pNumcte CHAR(20))

	RETURNING
	CHAR(6) 		AS COD_RET,	
	CHAR(13) 		AS RFC,
	CHAR(26) 		AS APELL_PATER_REP_LEG,
	CHAR(26) 		AS APELL_MATER_REP_LEG,
	CHAR(26) 		AS NOMB1_REP_LEG,
	CHAR(26) 		AS NOMB2_REP_LEG,		
	CHAR(40)   		AS CALLE_FISCAL,
	CHAR(10)   		AS NUM_EXT_CALLE_FISCAL,
	CHAR(60)   		AS COL_FISCAL,
	VARCHAR(60,1)  	AS NOM_CIUD_FISCAL,
	CHAR(3)   		AS COD_MUN_FISCAL,
	CHAR(30)    	AS NOM_ESTADO_FISCAL,
	CHAR(20) 		AS NUM_CTE,
	CHAR(60) 		AS NOM_CORTO,
	CHAR(30) 		AS PAG_INTERNET,
	CHAR(25) 		AS SAT_FEA,	
	CHAR(15) 		AS TEL_CONTACTO,
	CHAR(20) 		AS GIRO,
	CHAR(40) 		AS NOM_GIRO,
	CHAR(3)         AS ACTIVIDAD_SOC,
	CHAR(30) 		AS DES_ACT_OBJ,	
	CHAR(2) 		AS RESP_STATUS,								
	CHAR(26) 		AS APELL_PATER_FIRMANTES,					
	CHAR(26) 		AS APELL_MATER_FIRMANTES,
	CHAR(26) 		AS NOMB1_FIRMANTES, 		
	CHAR(26) 		AS NOMB2_FIRMANTES,
	CHAR(20)        AS DES_PODER,
	CHAR(20)        AS DES_ADMIN,
	CHAR(40)        AS DES_ORG,
	DATE            AS FECHA_INS,
	DATE            AS FECHA_CONS,
	CHAR(3)         AS NACIONALIDAD,
	CHAR(15)        AS DESC_NACIONALIDAD,
	CHAR(48)        AS NOMBRE_CONTACTO,
	CHAR(2)         AS SUFIJO,
	CHAR(60)        AS DES_SUFIJO, 
	CHAR(30)        AS ESCRITURA,
	CHAR(30)        AS NOMBRE_NOT,
	CHAR(5)         AS NUM_NOT,
	CHAR(30)        AS CDNOTARIO_OCT,
	CHAR(30)        AS DES_NOTARIOCT,
	CHAR(30)        AS ESCRITURA_POD,
	CHAR(30)        AS NOMNOTARIO_PD,
	CHAR(5)         AS NUMNOTARIO_PD,
	CHAR(30)        AS CDNOTARIO_PD,
	CHAR(30)        AS DESC_CDNOTARIOPD,
	CHAR(50)        AS NOMBRESOC,
	DATE            AS FECHAINS_PD,
	CHAR(60)        AS EMAIL_PM,
	CHAR(30)        AS FOLIO_MERCAN,
	CHAR(30)        AS CD_FOLIOMERCA,
	INTEGER         AS ESTATUS_CTE,  
	CHAR(1)         AS AUXILIAR1, 
	CHAR(1) 		AS AUXILIAR2,
	CHAR(1) 		AS AUXILIAR3,
    CHAR(1)         AS AUXILIAR4,	
	CHAR(1)         AS AUXILIAR5,
    CHAR(1)         AS AUXILIAR6,
    CHAR(1)         AS AUXILIAR7,
	CHAR(1)         AS AUXILIAR8,
	CHAR(1)         AS AUXILIAR9,
	CHAR(1)         AS AUXILIAR10,
	CHAR(02)        AS TIPO_PERSONA,
	CHAR(20)        AS NUMCTE_APODERADO,
	CHAR(60)        AS NOMCTE_APODERADO,
	CHAR(100)       AS DESC_DOCONSTITUCION,
	CHAR(4)         AS SUCURSAL,
	DATE            AS FECHA_ALTA,
	CHAR(1)         AS AUXILIAR11,
	CHAR(3)         AS TIPO_PODER,
	CHAR(3)         AS TIPO_ADMON,
	CHAR(3)         AS TIPO_ORGANIZACION,
	CHAR(40)        AS NOMBRE_SUCURSAL,
	CHAR(1)         AS VALORPARAM_MORALGOB,
	CHAR(254)        AS RAZON_SOCIAL,
    CHAR(20)        AS CURP,
	CHAR(13)		AS RFC_ALT,
	CHAR(50)		AS REG_FISCAL;
	
	
	---DECLARACIONES
	DEFINE iSqlErr						INTEGER;    		
	DEFINE cCodRet         				CHAR(6);				
	DEFINE cRFC         				CHAR(13);	
    DEFINE cSucursal                    CHAR(4);	
	DEFINE cApellPaterContactoRepLeg 	CHAR(26);				
	DEFINE cApellMaterContactoRepLeg	CHAR(26);				
	DEFINE cNomb1ContactoRepLeg         CHAR(26);				
	DEFINE cNomb2ContactoRepLeg     	CHAR(26);				
	DEFINE cCalleFiscal					CHAR(40);				
	DEFINE cNumExtCalleFiscal       	CHAR(10);				
	DEFINE cColFiscal         			CHAR(60);				
	DEFINE vNomCiudFiscal         		VARCHAR(60,1);			
	DEFINE cCodMunFiscal        		CHAR(3);				
	DEFINE cNomEstadoFiscal        		CHAR(30);				
	DEFINE cNumcte         				CHAR(20);				
	DEFINE cNomCorto        			CHAR(60);				
	DEFINE cPagInternet        			CHAR(30);				
	DEFINE cSatFea        				CHAR(25);				
	DEFINE cTelContacto    				CHAR(15);				
	DEFINE cGiro      					CHAR(20);				
	DEFINE cNomGiro    					CHAR(40);	
	DEFINE cActividadSoc                CHAR(3);
	DEFINE cDesActObj  					CHAR(30);				
	DEFINE cUsuarioAut    				CHAR(200);	
	DEFINE cStatusAlta 					CHAR(1);				
	DEFINE cRespStatus 					CHAR(2);				
	DEFINE cApellPaterFirmantes 		CHAR(26);				
	DEFINE cApellMaterFirmantes 		CHAR(26);				
	DEFINE cNomb1Firmantes 				CHAR(26);				
	DEFINE cNomb2Firmantes 				CHAR(26);				
	DEFINE cCuentaNomina 				CHAR(20);
	DEFINE cPoder                       CHAR(3);
	DEFINE cAdmin                       CHAR(3);
	DEFINE cOrg                         CHAR(3);
	DEFINE cDesPoder                    CHAR(20);
	DEFINE cDesAdmin                    CHAR(20);
	DEFINE cDesOrg                      CHAR(40);
	DEFINE cTpoPersona                  CHAR(2);
	DEFINE dFechaIns                    DATE;
	DEFINE dFechaCons                   DATE;
	DEFINE iNac                         INTEGER;
	DEFINE cNomContacto                 CHAR(48);
	DEFINE cSufijo                      CHAR(2);
	DEFINE cDescSufi                    CHAR(60);
	DEFINE cEscritura                   CHAR(30);
	DEFINE cNombreNot                   CHAR(30);
	DEFINE cNumNot                      CHAR(5);
	DEFINE cCdNotarioct                 CHAR(60);
	DEFINE cDesCdNot                    CHAR(30);
	DEFINE cEscrituraPod                CHAR(30);
	DEFINE cNomNotariopd                CHAR (30);
	DEFINE cNumNotariopd                CHAR(5);
	DEFINE cCdNotariopd                 CHAR(30);
	DEFINE cDesCdNotpd                  CHAR(30);
	DEFINE cNombreSoc                   CHAR(50);
	DEFINE dFechaInspd                  DATE;
	DEFINE cEmailpm                     CHAR(60);
	DEFINE cEsFisica                    CHAR(1);
	DEFINE cNumfoliomerct               CHAR(30);
	DEFINE cCdfoliomerct                CHAR(30);
	DEFINE cAuxiliar1                   CHAR(1);
	DEFINE cAuxiliar2                   CHAR(1);
	DEFINE cAuxiliar3                   CHAR(1);
	DEFINE cAuxiliar4   				CHAR(1);
	DEFINE cAuxiliar5   				CHAR(1);
	DEFINE cAuxiliar6                   CHAR(1);
	DEFINE cAuxiliar7                   CHAR(1);
	DEFINE cAuxiliar8                   CHAR(1);
	DEFINE cAuxiliar9                   CHAR(1);
	DEFINE cAuxiliar10                  CHAR(1);
	DEFINE cAuxiliar11                  CHAR(1);
	DEFINE cNumcteapoder                CHAR(20);
	DEFINE cNomapoder                   CHAR(60);
	DEFINE cDocConst                    CHAR(100);
	DEFINE cDesNacion                   CHAR(15);
	DEFINE cNac                         CHAR(3);
	DEFINE dFechaAlta                   DATE;
	DEFINE cNombreSucursal              CHAR(40);
	DEFINE cPrmTpopersonaGob            CHAR(5);
	DEFINE cValorTpopersonaGop          CHAR(1);
	DEFINE iEstatusCteEmpNet            INTEGER;
	DEFINE cRazonSocial					CHAR(254);
    DEFINE cCURP                        CHAR(20);
	DEFINE cRFCAlt						CHAR(13);
	DEFINE cCodRegFiscal				CHAR(3);
	DEFINE cRegimenFiscal				CHAR(50);
	
	
	---INICIALIZACIONES
	LET iSqlErr						= 0;    		
	LET cCodRet         			= '000000';				
	LET cRFC         				= '';
	LET cApellPaterContactoRepLeg   = '';
	LET cApellMaterContactoRepLeg 	= '';
	LET cNomb1ContactoRepLeg        = '';
	LET cNomb2ContactoRepLeg     	= '';
	LET cCalleFiscal				= '';
	LET cNumExtCalleFiscal       	= '';
	LET cColFiscal         			= '';
	LET vNomCiudFiscal         		= '';
	LET cCodMunFiscal        		= '';
	LET cNomEstadoFiscal        	= '';
	LET cNumcte         			= '';
	LET cNomCorto        			= '';
	LET cPagInternet        		= '';
	LET cSatFea        				= '';
	LET cTelContacto    			= '';
	LET cGiro      					= '';
	LET cNomGiro    				= '';
	LET cDesActObj  				= '';
	LET cUsuarioAut    				= '';	
	LET cStatusAlta 				= '';
	LET cRespStatus 				= '';
	LET cApellPaterFirmantes 		= '';
	LET cApellMaterFirmantes 		= '';
	LET cNomb1Firmantes 			= '';
	LET cNomb2Firmantes 			= '';			
	LET cCuentaNomina	 			= '';
	LET cPoder                      = '';
	LET cAdmin                      = '';
	LET cOrg                        = '';  	
	LET cDesPoder                   = '';
	LET cDesAdmin                   = '';
	LET cDesOrg                     = '';  
	LET cTpoPersona                 = '';		
	LET dFechaIns                   = DATE(1);
	LET dFechaCons                  = DATE(1);
	LET iNac                        = 0;
	LET cNomContacto                = '';
	LET cSufijo                     = '';
	LET cDescSufi                   = '';
	LET cActividadSoc               = '';
	LET cEscritura                  = '';
	LET cNombreNot                  = '';
	LET cNumNot                     = '';
	LET cCdNotarioct                = '';
	LET cDesCdNot                   = '';
	LET cEscrituraPod               = '';
	LET cNomNotariopd               = '';
	LET cNumNotariopd               = '';
	LET cCdNotariopd                = '';
	LET cDesCdNotpd                 = '';
	LET cNombreSoc                  = '';
	LET dFechaInspd                 = DATE(1);
	LET cEmailpm                    = '';
	LET cEsFisica                   = '';
	LET cCdfoliomerct               = '';
	LET cNumfoliomerct              = '';
	LET cAuxiliar1                  = '';
	LET cAuxiliar2                  = '';
	LET cAuxiliar3                  = '';
	LET cAuxiliar4                  = '';
	LET cAuxiliar5                  = '';
	LET cAuxiliar6                  = '';
	LET cAuxiliar7                  = '';
	LET cAuxiliar8                  = '';
	LET cAuxiliar9                  = '';
	LET cAuxiliar10                 = '';
	LET cAuxiliar11                 = '';
	LET cNumcteapoder               = '';
	LET cNomapoder                  = '';
	LET cDocConst                   = '';
	LET cDesNacion                  = '';
	LET cNac                        = '';
	LET cSucursal                   = '';
	LET dFechaAlta                  = DATE(1);
	LET cNombreSucursal             = '';
	LET cPrmTpopersonaGob              = '';
	LET cValorTpopersonaGop            = '';
	LET iEstatusCteEmpNet           = 0;
	LET cRazonSocial				= '';
    LET cCURP                       = '';
	LET cRFCAlt						= '';
	LET cRegimenFiscal				= '';
	LET cCodRegFiscal				= '';
	
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
		   IF iSqlErr != 0 THEN
			  LET cCodRet = iSqlErr;
			  RETURN 	cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
					
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarctemoral02.out';
		--TRACE ON;
		
		IF TRIM(NVL(pNumcte,'')) = '' THEN
			LET cCodRet = '000001'; --PARÃMETRO VACIO
			
		 	RETURN cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
		END IF;
		--SE CONSULTA EL TIPO PERSONA, RFC Y SUCURSAL REFERENTE AL CLIENTE
		SELECT tpo_persona, rfc, sucursal,rfc_alterno
		INTO cTpoPersona, cRFC, cSucursal, cRFCAlt
		FROM si_cliente
		WHERE numcte = TRIM(pNumcte)
		AND empresa = '001';
		
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
		   LET cCodRet = '000002'; --CONSULTA SIN RESULTADOS, AL CONSULTAR PARAMETRO INVÃLIDO
		   
		   RETURN 	cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
		END IF;
		
		--CONSULTA es_fisica OBTENIENDO 'S'= PERSONA FÃSICA, 'N'=PERSONA MORAL
		SELECT es_fisica
		INTO cEsFisica
        FROM si_tipper
		WHERE tpo_persona = TRIM(cTpoPersona);
		
		IF cEsFisica = 'S' THEN
		   LET cCodRet = '000003'; --PERSONA FÃSICA
		   LET cRFC = '';
		   
		   RETURN 	cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
		   
		END IF;
		--CAMBIO
		--SE OBTIENEN LOS DATOS DE CLIENTE MORAL DE LA TABLA si_ctepm
		SELECT TRIM(NVL(numcte,'')),NVL(nombre_corto,''),NVL(pagina_internet,''),TRIM(NVL(sat_fea,'')),
			   TRIM(NVL(telefono_contacto,'')), TRIM(NVL(giro, '')),TRIM(NVL(tipo_poder,'')),TRIM(NVL(tipo_admon,'')), 
			   TRIM(NVL(tipo_org,'')),fecha_inscrip,fecha_constitct,fecha_alta,nacionalidad,TRIM(NVL(nombre_contacto,'')),
			   TRIM(NVL(sufijo,'')),TRIM(NVL(actividadsocial,'')),NVL(escritura_constitutiva,''),
			   TRIM(NVL(nombre_notarioct,'')),TRIM(NVL(numero_notarioct,'')),TRIM(NVL(ciudad_notarioct,'')),
			   TRIM(NVL(numero_foliomercantilct,'')),TRIM(NVL(ciudad_foliomercantilct,'')),TRIM(NVL(escritura_poderes,'')),
			   TRIM(NVL(nombre_notariopd,'')),TRIM(NVL(numero_notariopd,'')), TRIM(NVL(ciudad_notariopd,'')),
			   TRIM(NVL(nombre_sociedad,'')),fecha_inscrippd, TRIM(NVL(emailpm,'')), TRIM(NVL(doc_constitucion,''))
		INTO cNumcte, cNomCorto, cPagInternet, cSatFea,
		     cTelContacto, cGiro, cPoder, cAdmin,
			 cOrg, dFechaIns, dFechaCons,dFechaAlta,iNac, cNomContacto,
			 cSufijo, cActividadSoc, cEscritura,
			 cNombreNot, cNumNot, cCdNotarioct,
			 cNumfoliomerct, cCdfoliomerct, cEscrituraPod,
			 cNomNotariopd, cNumNotariopd, cCdNotariopd,
			 cNombreSoc, dFechaInspd, cEmailpm,cDocConst
		FROM si_ctepm 
		WHERE numcte = TRIM(pNumcte)
		AND empresa = '001';

		--CAMBIO 
		--SE OBTIENEN LAS RAZON SOCIAL DEl CLIENTE MORAL DE LA TABLA si_fiscal
		SELECT LIMIT 1 TRIM(NVL(nom_razon_soc, '')),regim_fiscal
		INTO cRazonSocial, cCodRegFiscal
		FROM bdinteg:si_fiscal
		WHERE empresa = '001' 
		AND numcte = TRIM(pNumcte);

		IF cRazonSocial = '' THEN
			/*--SE OBTIENE LA RAZON SOCIAL;*/
			SELECT razon_social
			INTO cRazonSocial
        	FROM si_cliente
        	WHERE numcte = TRIM(pNumcte)
			AND empresa = '001';
		END IF;
		
	    LET cNac = LPAD(iNac, 3,'0');
		
		--SE OBTIENE LA DESCRIPCION DE LA NACIONALIDAD
	    SELECT descripcion
		INTO cDesNacion
		FROM si_nacion
		WHERE nacion = cNac;
		
		--SE OBTIENE LA DESCRIPCION DEL SUFIJO 
		SELECT descripcion 
		INTO cDescSufi 
		FROM si_sufijos 
		WHERE empresa = '001'
		AND codigo = TRIM(cSufijo);
		
		--SE OBTIENE LA DESCRIPCION DEL ESTADO DE cCdNotarioct
		
		SELECT nombre 
		INTO cDesCdNot 
		FROM si_estados 
		WHERE estado = TRIM(cCdNotarioct);
		
		-- SE OBTIENE LA DESCRIPCION DEL ESTADO DE cCdNotariopd
		
		SELECT nombre 
		INTO cDesCdNotpd 
		FROM si_estados 
		WHERE estado = TRIM(cCdNotariopd);
		
		LET cPrmTpopersonaGob = 'tpo'||TRIM(cTpoPersona);		
		SELECT TRIM(valor)
		INTO cValorTpopersonaGop
		FROM bdicheq:sc_param
		WHERE empresa = '001'
		AND codparam = TRIM(cPrmTpopersonaGob);

		IF cEsFisica = 'N' THEN

			-- SE OBTIENE DESCRIPCIÃN DE EL REGIMEN FISCAL PARA PERSONAS MORALES
			SELECT TRIM(descripcion)
			INTO cRegimenFiscal 
			FROM bdinteg:si_regimen_fiscal
			WHERE c_regimenfiscal = cCodRegFiscal
			AND tipo = 'M';

		ELIF cEsFisica = 'S' THEN

			-- SE OBTIENE DESCRIPCIÃN DE EL REGIMEN FISCAL PARA PERSONAS FISICAS
			SELECT TRIM(descripcion)
			INTO cRegimenFiscal 
			FROM bdinteg:si_regimen_fiscal
			WHERE c_regimenfiscal = cCodRegFiscal
			AND tipo = 'F';
		END IF;

		--SE OBTIENE LA DESCRIPCION DE DATOS DE PERSONAS DE GOBIERNO tpo_persona = '05'*
		IF cValorTpopersonaGop = 'S' THEN
			
			SELECT descripcion
			INTO cDesPoder
			FROM si_tipo_poder_pm 
			WHERE empresa = '001'
			AND codigo = TRIM(cPoder);
			
			SELECT descripcion
			INTO cDesAdmin
			FROM si_tipo_admin_pm 
			WHERE empresa = '001'
			AND codigo = TRIM(cAdmin);
			
			SELECT descripcion
			INTO cDesOrg
			FROM si_tipo_org_pm 
			WHERE empresa = '001'
			AND codigo = TRIM(cOrg);
			
		ELSE 
		   
		   LET cDesPoder = "";
		   LET cDesAdmin = "";
		   LET cDesOrg = "";
		 
		END IF;
		
		
		--SE OBTIENE LA CUENTA Y EL ESTATUS DE LA EMPRESA CON EL SERVICIO DE NOMINA
		SELECT TRIM(NVL(cuenta,'')), TRIM(NVL(status_alta,''))
		INTO cCuentaNomina, cStatusAlta
		FROM bdicheq:sc_nominaempresas
		WHERE numcte = TRIM(pNumcte);
		
		IF TRIM(NVL(cStatusAlta,'')) = '3' THEN
		   LET cRespStatus = 'Si';
		ELSE
		   LET cRespStatus = 'No';
		END IF;		
						
		--SE OBTIENE NOMBRE DEL REPRESENTANTE LEGAL Y RFC.
		SELECT TRIM(NVL(apell_paterno,'')),TRIM(NVL(apell_materno,'')),
	    TRIM(NVL(nombre1,'')),TRIM(NVL(nombre2,'')) 
		INTO cApellPaterContactoRepLeg,cApellMaterContactoRepLeg,cNomb1ContactoRepLeg,cNomb2ContactoRepLeg
		FROM si_cliente 
		WHERE numcte = TRIM(cNomContacto)
		AND empresa = '001';
		
							
		--SE OBTIENE DOMICILIO FISCAL.			
		SELECT 	TRIM(NVL(e.nombrecalle,'')),TRIM(NVL(a.numeroextcalle,'')),TRIM(NVL(f.nombrezona,'')),
				TRIM(NVL(g.nombre,'')),TRIM(NVL(c.municipio,'')),TRIM(NVL(b.nombre,''))			
		INTO cCalleFiscal,cNumExtCalleFiscal,cColFiscal,vNomCiudFiscal,cCodMunFiscal,cNomEstadoFiscal
		FROM si_direcciones_actual a 
			 LEFT OUTER JOIN si_estados 	   b ON (a.estado = b.estado)
			 LEFT OUTER JOIN si_municipios  c ON (a.municipio = c.municipio AND a.estado = c.estado AND a.ciudad = c.ciudad AND a.pais = c.pais)
			 LEFT OUTER JOIN si_catcalles   e ON (a.numerocalle = e.numerocalle)
			 LEFT OUTER JOIN si_catzonas    f ON (a.numerociudad = f.numerociudad AND a.numerocolonia = f.numerocolonia)
			 LEFT OUTER JOIN si_ciudades    g ON (a.estado = g.estado AND a.ciudad = g.ciudad)		 
		WHERE a.numcte = TRIM(pNumcte)
		AND a.tipo_dir = 1;
		
		--SE OBTIENE GIRO MERCANTIL.
		SELECT TRIM(NVL(nombre,'')) 
		INTO cNomGiro
		FROM si_actecon
		WHERE actividad = TRIM(cGiro);
										
		--SE OBTIENE ACTIVIDAD U OBJETO SOCIAL.
		SELECT TRIM(NVL(descripcion,'')) 
		INTO cDesActObj
		FROM si_actividadsocial 
		WHERE codigo = TRIM(cActividadSoc);		
	
	    --SE OBTIENE EL ESTATUS DEL SERVICIO DE EMPRESANET DEL CLIENTE
	    SELECT MAX (NVL(status_contrato, 0))
		INTO iEstatusCteEmpNet
		FROM bdibei:bei_contratacion
		WHERE empresa = '001'
		AND num_cliente = pNumcte;
		
		--OBTIENE EL NUMERO DE CTE APODERADO ASI COMO SU NOMBRE
		SELECT numcteapoderado,nombreapoderado 
		INTO cNumcteapoder, cNomapoder
		FROM si_apoderado
		WHERE empresa = '001'
		AND numcte = TRIM(cNumcte)
		AND secuencia = (SELECT MAX(secuencia) FROM si_apoderado WHERE empresa = '001');

        --OBTIENE LA CLAVE CURP DE CTE APODERADO
		SELECT TRIM(curp)
		INTO cCURP
		FROM si_ctepf
		WHERE empresa = '001'
		AND numcte = TRIM(cNumcteapoder);
        
	
		--SE OBTIENE EL AUTORIZADO PARA MANEJAR LAS CUENTAS DE REGISTRO FIRMAS:
		SELECT TRIM(NVL(b.apell_paterno,'')),TRIM(NVL(b.apell_materno,'')),TRIM(NVL(b.nombre1,'')),TRIM(NVL(b.nombre2,''))
		INTO cApellPaterFirmantes,cApellMaterFirmantes,cNomb1Firmantes,cNomb2Firmantes
		FROM bdicheq:sc_firmantes a INNER JOIN si_cliente b ON(a.numcte = b.numcte)
		WHERE a.empresa = '001'
		AND a.cuenta = TRIM(cCuentaNomina)
		AND a.secuencia = 1;
		
		--SE OBTIENE EL NOMBRE DE LA SUCURSAL
		SELECT nombre 
		INTO cNombreSucursal
        FROM si_sucursales
        WHERE sucursal = TRIM(cSucursal);
		
		--SE RETORNA INFORMACION.
	   RETURN 	cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
                    	
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que obtiene la informacion del cliente moral',
'ahora validando de manera general el tipo de persona.',
'AUTOR:  Mireya Reyes',   
'FECHA DE CREACION: 22/08/2013',
'AUTOR:  Daniel Reyes Guillen',   
'FECHA: 24/06/2021',
'DESCRIPCION: Se aÃ±ade CURP',
'AUTOR:  Jose Antonio Ramirez Franco',   
'FECHA: 29/09/2023',
'DESCRIPCION: Se aÃ±ade Regimen fiscal',
'AUTOR:  Jose Antonio Ramirez Franco',   
'FECHA: 10/12/2024',
'DESCRIPCION: Se realiza modificaciÃ³n en la consulta para obtener el regimen fiscal filtrando por el tipo de persona',
'VERSION: 20130823.1430',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_depurar_clientes_pyt()
RETURNING INTEGER AS rSqlErr, INTEGER AS IsamErr, CHAR(255) AS DescErr ;

    DEFINE dfecha_inicio DATETIME YEAR TO FRACTION(5);
    DEFINE dfecha_fin DATETIME YEAR TO FRACTION(5);
    DEFINE id_control INT;
    DEFINE contador INT;
    DEFINE secuencia_borrar INT;
	DEFINE total_a_borrar INT;
    DEFINE itotal_borrados INT;
	DEFINE bEnTransaccion BOOLEAN;
	
	--DEFINE rSqlErr CHAR(5);
    --DEFINE DescErr CHAR(255);
	
	DEFINE rSqlErr  			INTEGER;
	DEFINE iIsamErr 			INTEGER;
	DEFINE DescErr 				CHAR(255);
	
	LET rSqlErr	 = 0;
	LET iIsamErr = 0;
	LET DescErr = '';

    -- Inicializar variables
    LET contador = 0;
	LET total_a_borrar = 0;
    LET itotal_borrados = 0;
	LET bEnTransaccion = 'f';

	
BEGIN
	ON EXCEPTION 
		SET rSqlErr, iIsamErr, DescErr
		--SET DEBUG FILE TO "/tmp/pruebas_coordinacion/ambientacion_clientes/debug_log.txt";
		--TRACE ON;

		SET DEBUG FILE TO "/RESPALDOSNEW/prevfraudes/debug_log.txt";
		TRACE ON;
		
        --LET rSqlErr = SQLCODE;
        --LET DescErr = ERRMSG(rSqlErr);
        --ROLLBACK WORK;

        --UPDATE control_ejecucion_sp_depurar_clientes_pyt
        --   SET fecha_fin_ejecucion = CURRENT,
        --       codigo_error = rSqlErr,
        --       descripcion_error = DescErr,
        --       total_registros_borrados = itotal_borrados
        -- WHERE id_control = id_control;
		 
		UPDATE control_ejecucion_sp_depurar_clientes_pyt
		SET
			fecha_fin_ejecucion = CURRENT,
			status = 0,
			codigo_error = rSqlErr,
			descripcion_error = DescErr,
			total_registros_borrados = itotal_borrados
		WHERE id_control = id_control;
		
		--IF itotal_borrados = 0 THEN
        --    ROLLBACK WORK;
        --END IF;
		
		IF bEnTransaccion = 't' THEN
			ROLLBACK WORK;
			LET bEnTransaccion = 'f';
			--LET dFechaCargaini = 0;
			--LET dFechaCargafin = 0;
			--LET iFechaMax_Cargada = 0;
			--LET vreg_insertados = 0;
			
			--UPDATE control_ejecucion_sp_depurar_clientes_pyt
			--SET (fecha_fin_ejecucion, fecha_cargaini, fecha_cargafin, fechamax_cargada, reg_insertados, status_proc, cod_err, descripcion_err)
			--= (dFechaProcesofin, dFechaCargaini, dFechaCargafin, iFechaMax_Cargada, vreg_insertados, vstatus_proc, cCodRet1, cCodRet3)
			--where id_proceso = iId_proceso AND status_proc = '1';
		ELSE
			ROLLBACK WORK;
			LET bEnTransaccion = 'f';
			--INSERT INTO ctrl_info_insert_tde_sendmsgs_tar_hist (id_proceso,fecha_procesoIni, fecha_fin_ejecucion, nombre_proceso,
			--fecha_cargaini, fecha_cargafin, fechamax_cargada, reg_insertados, status_proc, cod_err, descripcion_err)
			--VALUES (iId_proceso,dFechaProcesoini, dFechaProcesofin, NVL(cProceso1,''), dFechaCargaini, dFechaCargafin, iFechaMax_Cargada,
			--		vreg_insertados, vstatus_proc,cCodRet1,cCodRet3);
		END IF

        --RETURN rSqlErr, DescErr;
		RETURN rSqlErr, iIsamErr, DescErr;
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/pruebas_coordinacion/ambientacion_clientes/debug_log.txt";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    -- Obtener el rango de fechas
    SELECT fecha_inicio, fecha_fin
      INTO dfecha_inicio, dfecha_fin
      FROM fechas_sp_depurar_clientes_pyt
     WHERE id_configuracion = 1;

    -- Validar que las fechas sean vÃ¡lidas
	IF dfecha_inicio IS NULL OR dfecha_fin IS NULL THEN
		LET rSqlErr = -0001;
		LET DescErr = 'Fechas no configuradas en tabla';
		--RETURN rSqlErr, DescErr;
		RETURN rSqlErr, iIsamErr, DescErr;
	END IF;

	IF dfecha_inicio > dfecha_fin THEN
		LET rSqlErr = -0002;
		LET DescErr = 'Rango de fechas invÃ¡lido';
		--RETURN rSqlErr, DescErr;
		RETURN rSqlErr, iIsamErr, DescErr;
	END IF;
	
	LET rSqlErr = 00001;
	LET DescErr = 'DepuraciÃ³n en ejecuciÃ³n';

	-- Insertar registro inicial en tabla de control
    INSERT INTO control_ejecucion_sp_depurar_clientes_pyt(
        fecha_inicio_ejecucion, fecha_inicio_periodo, fecha_fin_periodo, status, codigo_error, descripcion_error)
    VALUES (
        CURRENT YEAR TO FRACTION(5), dfecha_inicio, dfecha_fin, 1, rSqlErr, DescErr
    );
	
    LET id_control = DBINFO('sqlca.sqlerrd1'); -- Recuperar el id de control
	--SELECT DBINFO('sqlca.sqlerrd1') INTO id_control FROM systables WHERE tabid = 1;
	
    -- 1. Identificar los numcte dentro del rango configurado
    SELECT DISTINCT t.numcte
      FROM info_clientes_pyt t
     WHERE t.fecha_ctrl BETWEEN dfecha_inicio AND dfecha_fin
    INTO TEMP temp_numcte_rango WITH NO LOG;

    CREATE INDEX idx_temp_numcte_rango ON temp_numcte_rango(numcte);
	
	UPDATE STATISTICS MEDIUM FOR TABLE temp_numcte_rango;


    -- 2. Identificar la fecha mÃ¡s reciente para CLI y CPF globalmente
    SELECT t.numcte, t.tbl_orig, MAX(t.fecha_ctrl) AS max_fecha_ctrl
      FROM info_clientes_pyt t
           INNER JOIN temp_numcte_rango tmp
               ON t.numcte = tmp.numcte
     WHERE t.tbl_orig IN ('CLI', 'CPF')
     GROUP BY t.numcte, t.tbl_orig
    INTO TEMP temp_fechas_recientes WITH NO LOG;

    CREATE INDEX idx_temp_fechas_recientes ON temp_fechas_recientes(numcte, tbl_orig);

	UPDATE STATISTICS MEDIUM FOR TABLE temp_fechas_recientes;	
	
    -- 3. Identificar registros a mantener (fecha mÃ¡s reciente global)
    SELECT t.secuencia
      FROM info_clientes_pyt t
           INNER JOIN temp_fechas_recientes tmp
               ON t.numcte = tmp.numcte
              AND t.tbl_orig = tmp.tbl_orig
              AND t.fecha_ctrl = tmp.max_fecha_ctrl
    INTO TEMP temp_registros_a_mantener WITH NO LOG;

    CREATE INDEX idx_temp_mantener ON temp_registros_a_mantener(secuencia);

    UPDATE STATISTICS MEDIUM FOR TABLE temp_registros_a_mantener;


    -- 4. Identificar registros a borrar (excluyendo los registros a mantener)
    SELECT t.secuencia
      FROM info_clientes_pyt t
           INNER JOIN temp_numcte_rango tmp
               ON t.numcte = tmp.numcte
     WHERE t.tbl_orig IN ('CLI', 'CPF')
       AND NOT EXISTS (
           SELECT 1
             FROM temp_registros_a_mantener tmp2
            WHERE tmp2.secuencia = t.secuencia
       )
    INTO TEMP temp_registros_a_borrar WITH NO LOG;

    CREATE INDEX idx_temp_borrar ON temp_registros_a_borrar(secuencia);
	
    UPDATE STATISTICS MEDIUM FOR TABLE temp_registros_a_borrar;


	-- Calcular total de registros a borrar
	SELECT COUNT(*) INTO total_a_borrar FROM temp_registros_a_borrar;
	
	-- Actualizar control con total de registros a borrar
	UPDATE control_ejecucion_sp_depurar_clientes_pyt
	SET total_registros_a_borrar = total_a_borrar
	WHERE id_control = id_control;
	
	DROP TABLE temp_numcte_rango;
	DROP TABLE temp_fechas_recientes;
	DROP TABLE temp_registros_a_mantener;
	
    -- Procesar los registros en bloques
    BEGIN WORK;
		LET bEnTransaccion = 't';
		FOREACH WITH HOLD
			SELECT secuencia
			INTO secuencia_borrar
			FROM temp_registros_a_borrar
			
			insert into bdinteg:info_clientes_pyt_resp
            select * from bdinteg:info_clientes_pyt
            where secuencia = secuencia_borrar;
			
			--secuencia,empresa,numcte,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_insert,fecha_alta,sexo,fecha_nac,accion,fecha_ctrl,tbl_orig     
			
			DELETE FROM info_clientes_pyt
			WHERE secuencia = secuencia_borrar;
			
			-- Confirmar cada 5,000 registros
			IF contador >= 5000 THEN
				COMMIT WORK;
				LET contador = 0;
				BEGIN WORK;
			ELSE
				LET contador = contador + 1;
				LET itotal_borrados = itotal_borrados + 1;
			END IF;

		END FOREACH;
	
    COMMIT WORK;

	LET bEnTransaccion = 'f';

	UPDATE STATISTICS MEDIUM FOR TABLE info_clientes_pyt;
	UPDATE STATISTICS MEDIUM FOR TABLE info_clientes_pyt_resp;
	
	LET rSqlErr = 00000;
	LET DescErr = 'DepuraciÃ³n Exitosa';
	 
	-- Finalizar ejecuciÃ³n del SP
	UPDATE control_ejecucion_sp_depurar_clientes_pyt
	SET
        fecha_fin_ejecucion = CURRENT YEAR TO FRACTION(5),
		status = 0,
		codigo_error = rSqlErr,
		descripcion_error = DescErr,
		total_registros_borrados = itotal_borrados
	WHERE id_control = id_control;
	
	DROP table temp_registros_a_borrar;
	
	--RETURN rSqlErr, DescErr;
	RETURN rSqlErr, iIsamErr, DescErr;
END
END PROCEDURE;