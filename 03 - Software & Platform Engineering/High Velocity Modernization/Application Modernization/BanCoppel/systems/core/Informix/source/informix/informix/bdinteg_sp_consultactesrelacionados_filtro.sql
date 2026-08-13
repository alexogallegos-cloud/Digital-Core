CREATE PROCEDURE "informix".sp_consultactesrelacionados_filtro(pEmpresa CHAR(3), pNumCteBanco CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5)  AS CodigoRetorno,
	CHAR(20) AS NumCteCoppel;

	DEFINE iSql_err	  INTEGER;
	DEFINE cCodRet	  CHAR(5);
	DEFINE cNumCteCPL CHAR(20);
	DEFINE cCteProsCoppel	CHAR(1);
	
	LET iSql_err	= 0;
	LET cCodRet		= '00000';
	LET cNumCteCPL	= '';
	LET cCteProsCoppel ='';

	--SET DEBUG FILE TO "/home/e10000315/sp_consultactesrelacionados_filtro.out";
    --TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET iSql_err
		
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet, cNumCteCPL;
			END IF;
			
		END EXCEPTION;
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pNumCteBanco IS NULL OR pNumCteBanco = '' OR pEmpresa IS NULL OR pEmpresa = '' THEN
			LET cCodRet = '00001';
		ELSE
			IF EXISTS (SELECT numcte_banco FROM bdinteg:"informix".si_relacion_ctebcplcpl WHERE numcte_banco = TRIM(pNumCteBanco)) THEN
				SELECT TRIM(cliente),cliente_prosp
				INTO cNumCteCPL, cCteProsCoppel
				FROM bdinteg:"informix".si_relacion_ctebcplcpl 
				WHERE empresa = pEmpresa
				AND numcte_banco = TRIM(pNumCteBanco);
				
				IF cNumCteCPL = "" OR cNumCteCPL IS NULL THEN
					LET cCodRet = '00001';
				END IF;
								
				IF TRIM(NVL(cCteProsCoppel,'')) = '1' AND LENGTH(cNumCteCPL) >= 10 AND SUBSTR(cNumCteCPL,1,1) = 9  THEN  
					LET cCodRet = '00001';
					LET cNumCteCPL = '';
				END IF;
				/*
				IF LENGTH(cNumCteCPL) = 11 AND SUBSTR(cNumCteCPL,1,1) = 9 THEN
					LET cCodRet = '00001';
					LET cNumCteCPL = '';
				END IF;
				*/
			ELSE
				LET cCodRet = '00001';
			END IF;
		END IF;
		
		RETURN  cCodRet, cNumCteCPL;
	END
	
END PROCEDURE

DOCUMENT
'Consulta si existe relacion de un cliente Bancoppel con un numero de cliente Coppel',
'Autor :Daniela RamÃ­rez',
'FECHA : 19/Septiembre/2012',
'BD: bdinteg',
'Valida que el campo cliente de la tabla si_relacion_ctebcplcpl, no este vacio o sea nulo',
'Autor :Rodolfo Tortolero',
'FECHA : 03/Enero/2013',
'BD: bdinteg',
'Clon de sp sp_consultactesrelacionados, que deja en blanco el cliente coppel si empieza con 9 y es de 11 digitos',
'Autor :Marcos Cuevas',
'FECHA : 30/Junio/2016',
'BD: bdinteg',
'Se deja en blanco el cliente coppel si la bandera cliente_prosp estÃ¡ encendida',
'Autor :Obed Vega',
'FECHA : 22/Julio/2016',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_cal_riesgo_cliente(pNumCte VARCHAR(20), pDepositosMonto CHAR(4), pRetirosMonto CHAR(4), pDepositosCantidad CHAR(4), pRetirosCantidad CHAR(4),
													pProcedAperturaCta CHAR(4), pProcedMantenerCta CHAR(4), pMontoMensual CHAR(4))

	RETURNING CHAR(5) AS CodRet, CHAR(20) AS Calificacion, CHAR(5) as Riesgo, VARCHAR(1) AS TipoCalificacion;
	

	DEFINE v_CodRet									CHAR(5);
	DEFINE V_calificacion_tpo_persona 				DECIMAL(5,3);
	
	DEFINE V_calificacion_edad 						DECIMAL(5,3);
	DEFINE V_calificacion_nacionalidad 				DECIMAL(5,3);
	DEFINE V_calificacion_actividad 				DECIMAL(5,3);
	DEFINE V_calificacion_ubicacion 				DECIMAL(5,3);
	DEFINE V_calificacion_producto 					DECIMAL(5,3);
	DEFINE V_calificacion_deposito 					DECIMAL(5,3);
	DEFINE V_calificacion_retiro 					DECIMAL(5,3);
	DEFINE V_calificacion_frecuencia_deposito 		DECIMAL(5,3);
	DEFINE V_calificacion_frecuencia_retiro 		DECIMAL(5,3);
	DEFINE V_calificacion_origen_recurso			DECIMAL(5,3);
	DEFINE V_calificacion_destino_recurso 			DECIMAL(5,3);
	DEFINE V_calificacion_importe_manejar_mes 		DECIMAL(5,3);
	
	
	DEFINE v_numcte									CHAR(20);
	DEFINE v_nombre									CHAR(50);
	DEFINE v_tpo_persona							CHAR(2);
	DEFINE v_nacionalidad							CHAR(3);
	DEFINE v_actividad								INTEGER;
	DEFINE v_subactividad							INTEGER;
	DEFINE v_estado									CHAR(2);
	DEFINE v_nombre_estado							CHAR(30);
	DEFINE v_prodtarjeta							CHAR(4);
	
	DEFINE v_puntaje_tpo_persona					DECIMAL(5,3);
	DEFINE v_puntaje_edad							DECIMAL(5,3);
	DEFINE v_puntaje_nacionalidad					DECIMAL(5,3);
	DEFINE v_puntaje_actividad						DECIMAL(5,3);
	DEFINE v_puntaje_ubicacion						DECIMAL(5,3);
	DEFINE v_puntaje_producto						DECIMAL(5,3);
	DEFINE v_porcentaje_tpo_persona					DECIMAL(5,3);
	DEFINE v_porcentaje_edad						DECIMAL(5,3);
	DEFINE v_porcentaje_nacionalidad				DECIMAL(5,3);
	DEFINE v_porcentaje_actividad					DECIMAL(5,3);
	DEFINE v_porcentaje_ubicacion					DECIMAL(5,3);
	DEFINE v_porcentaje_producto					DECIMAL(5,3);
	DEFINE v_porcentaje_inherente					DECIMAL(5,3);
	DEFINE v_calificacion_inherente					DECIMAL(5,3);
	DEFINE v_puntaje_deposito						DECIMAL(5,3);
	DEFINE v_porcentaje_deposito					DECIMAL(5,3);
	
	DEFINE v_puntaje_retiro							DECIMAL(5,3);
	DEFINE v_porcentaje_retiro						DECIMAL(5,3);
	
	DEFINE v_puntaje_frecuencia_deposito			DECIMAL(5,3);
	DEFINE v_porcentaje_frecuencia_deposito			DECIMAL(5,3);
	
	DEFINE v_puntaje_frecuencia_retiro				DECIMAL(5,3);
	DEFINE v_porcentaje_frecuencia_retiro			DECIMAL(5,3);
	
	DEFINE v_calificacion_frecuencia				DECIMAL(5,3);
	
	DEFINE v_depositos_monto						CHAR(2);
	DEFINE v_retiros_monto							CHAR(2);
	DEFINE v_depositos_cantidad						CHAR(2);
	DEFINE v_retiros_cantidad						CHAR(2);
	DEFINE v_proced_aperturacta						CHAR(2);
	DEFINE v_proced_mantenercta						CHAR(2);
	DEFINE v_monto_mensual							CHAR(2);
	
	DEFINE v_Edad									CHAR(3);
	DEFINE v_fecha_nac								DATE;
	
	DEFINE v_fecha_actual							DATE;
	
	DEFINE v_MenorFechaNac							INTEGER;
	
	DEFINE v_puntaje_inherente						DECIMAL(5,3);
	
	DEFINE v_puntaje_origen_recurso					DECIMAL(5,3);
	DEFINE v_porcentaje_origen_recurso				DECIMAL(5,3);
	
	DEFINE v_puntaje_destino_recurso				DECIMAL(5,3);
	DEFINE v_porcentaje_destino_recurso				DECIMAL(5,3);
	
	DEFINE v_puntaje_importe_manejar_mes			DECIMAL(5,3);
	DEFINE v_porcentaje_importe_manejar_mes			DECIMAL(5,3);
	
	DEFINE v_puntaje_transaccional					DECIMAL(5,3);
	DEFINE v_porcentaje_transaccional				DECIMAL(5,3);
	DEFINE v_calificacion_transaccional				DECIMAL(5,3);
	
	DEFINE v_persona_expuesta						INTEGER;
	
	DEFINE v_calificacion_persona_expuesta			DECIMAL(5,3);
	
	DEFINE v_calificacion_grado_riesgo				DECIMAL(5,3);
	
	DEFINE v_Riesgo									CHAR(5);
	
	DEFINE v_riesgo_descripcion_bajo				CHAR(10);
	DEFINE v_riesgo_valor_bajo						DECIMAL(5,3);
	DEFINE v_riesgo_descripcion_medio				CHAR(10);
	DEFINE v_riesgo_valor_medio						DECIMAL(5,3);
	DEFINE v_riesgo_descripcion_alto				CHAR(10);
	DEFINE v_riesgo_valor_alto						DECIMAL(5,3);
	
	DEFINE v_grado_riesgo							CHAR(20);
	DEFINE v_detalle_grado_riesgo					CHAR(100);
	
	DEFINE v_TipoRiesgo								CHAR(1);
	
	DEFINE v_fecha_insert							DATE;
	DEFINE v_sucursal								CHAR(4);
	DEFINE v_fecha_alta								DATE;
	
	DEFINE v_cuenta									CHAR(20);
	
	DEFINE v_conteo									INTEGER;
	
	DEFINE v_productos								INTEGER;
	
	DEFINE v_ConteoCliente							INTEGER;
	
	
	
	LET v_CodRet									 = '00000';
	
	LET V_calificacion_tpo_persona                   = 0;
	LET V_calificacion_edad 						 = 0;
	LET V_calificacion_nacionalidad 				 = 0;
	LET V_calificacion_actividad 					 = 0;
	LET V_calificacion_ubicacion 					 = 0;
	LET V_calificacion_producto						 = 0;
	LET V_calificacion_deposito						 = 0;
	LET V_calificacion_retiro						 = 0;
	LET V_calificacion_frecuencia_deposito			 = 0;
	LET V_calificacion_frecuencia_retiro			 = 0;
	LET V_calificacion_origen_recurso				 = 0;
	LET V_calificacion_destino_recurso				 = 0;
	LET V_calificacion_importe_manejar_mes			 = 0;
	
	LET v_puntaje_tpo_persona						 = 0;
	LET v_puntaje_edad								 = 0;
	LET v_puntaje_nacionalidad						 = 0;
	LET v_puntaje_actividad							 = 0;
	LET v_porcentaje_tpo_persona					 = 0;
	LET v_porcentaje_edad							 = 0;
	LET v_porcentaje_nacionalidad					 = 0;
	LET v_porcentaje_actividad						 = 0;
	LET v_puntaje_ubicacion							 = 0;
	LET v_puntaje_producto							 = 0;
	LET v_porcentaje_ubicacion						 = 0;
	LET v_porcentaje_producto						 = 0;
	LET v_porcentaje_inherente						 = 0;
	
	LET v_numcte									 = '';
	LET v_nombre								 	 = '';
	LET v_tpo_persona								 = '';
	LET v_nacionalidad								 = '';
	LET v_estado									 = '';
	LET v_nombre_estado								 = '';
	LET v_prodtarjeta								 = '';
	
	LET v_Edad										 = '';
	LET v_fecha_nac									 = '';
	
	LET v_fecha_actual								 = CURRENT;
	
	LET v_MenorFechaNac								 = 0;
	
	LET v_actividad									 = 0;
	LET v_subactividad								 = 0;
	
	LET v_puntaje_inherente							 = 0;
	
	LET v_calificacion_inherente					 = 0;
	
	LET v_depositos_monto							 = pDepositosMonto;
	LET v_retiros_monto								 = pRetirosMonto;
	LET v_depositos_cantidad						 = pDepositosCantidad;
	LET v_retiros_cantidad							 = pRetirosCantidad;
	LET v_proced_aperturacta						 = pProcedAperturaCta;
	LET v_proced_mantenercta						 = pProcedMantenerCta;
	LET v_monto_mensual								 = pMontoMensual;
	
	LET v_puntaje_deposito							 = 0;
	LET v_porcentaje_deposito						 = 0;
	LET v_calificacion_deposito						 = 0;
	LET v_puntaje_retiro							 = 0;
	LET v_porcentaje_retiro							 = 0;
	LET v_calificacion_retiro						 = 0;
	LET v_puntaje_frecuencia_deposito				 = 0;
	LET v_porcentaje_frecuencia_deposito			 = 0;
	LET v_calificacion_frecuencia_deposito			 = 0;
	LET v_puntaje_frecuencia_retiro					 = 0;
	LET v_porcentaje_frecuencia_retiro				 = 0;
	LET v_calificacion_frecuencia_retiro			 = 0;
	LET v_calificacion_frecuencia					 = 0;
	
	LET v_puntaje_origen_recurso					 = 0;
	LET v_porcentaje_origen_recurso					 = 0;
	LET v_calificacion_origen_recurso				 = 0;
	
	LET v_puntaje_destino_recurso					 = 0;
	LET v_porcentaje_destino_recurso				 = 0;
	
	LET v_puntaje_importe_manejar_mes				 = 0;
	LET v_porcentaje_importe_manejar_mes			 = 0;
	
	LET v_puntaje_transaccional						 = 0;
	LET v_porcentaje_transaccional					 = 0;
	LET v_calificacion_transaccional				 = 0;
	
	LET v_persona_expuesta							 = 0;
	
	LET v_calificacion_persona_expuesta				 = 0;
	
	LET v_calificacion_grado_riesgo					 = 0;
	
	LET v_Riesgo									 = '';
	
	LET v_riesgo_descripcion_bajo					 = '';
	LET v_riesgo_valor_bajo							 = 0;
	LET v_riesgo_descripcion_medio					 = '';
	LET v_riesgo_valor_medio						 = 0;
	LET v_riesgo_descripcion_alto					 = '';
	LET v_riesgo_valor_alto							 = 0;
	
	LET v_grado_riesgo								 = '';
	LET v_detalle_grado_riesgo						 = '';
	
	LET v_TipoRiesgo								 = '';
	
	LET v_fecha_insert								 = '';
	LET v_sucursal							 		 = '';
	LET v_fecha_alta								 = '';
	LET v_cuenta									 = '';
	
	LET v_conteo									 = 0;
	
	LET v_productos									 = 0;
	
	LET v_ConteoCliente								 = 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

		--SET DEBUG FILE TO '/informix/LMC/biometria/sp_cal_riesgo_cliente.out';
		--TRACE ON;

		SELECT valor_vacio INTO V_calificacion_tpo_persona			FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '01';
		SELECT valor_vacio INTO V_calificacion_edad					FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '02';
		SELECT valor_vacio INTO V_calificacion_nacionalidad			FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '03';
		SELECT valor_vacio INTO V_calificacion_actividad			FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '04';
		SELECT valor_vacio INTO V_calificacion_ubicacion			FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '05';
		SELECT valor_vacio INTO V_calificacion_producto				FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '06';
		SELECT valor_vacio INTO V_calificacion_deposito				FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '08';
		SELECT valor_vacio INTO V_calificacion_retiro				FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '09';
		SELECT valor_vacio INTO V_calificacion_frecuencia_deposito	FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '10';
		SELECT valor_vacio INTO V_calificacion_frecuencia_retiro	FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '11';
		SELECT valor_vacio INTO V_calificacion_origen_recurso		FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '12';
		SELECT valor_vacio INTO V_calificacion_destino_recurso		FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '13';
		SELECT valor_vacio INTO V_calificacion_importe_manejar_mes	FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '14';
		
			
		--SELECT 
		--		DISTINCT (SELECT count(*) FROM bdicheq:sc_maechq aa INNER JOIN bdicheq:sc_maenoc bb ON aa.cuenta = bb.cuenta WHERE aa.num_cte = a.numcte) productos
		--	INTO 
		--		v_productos
		--	FROM 
		--		bdinteg:si_cliente a
		--	WHERE 
		--		a.fecha_alta = TODAY AND a.tpo_persona = '01' AND a.numcte = pNumCte;
		
	--	IF v_productos>0 THEN
			SELECT FIRST 1
						count(*),
						a.numcte,
						TRIM(a.apell_paterno)||' '||TRIM(a.apell_materno)||' '||TRIM(a.nombre1)||' '||TRIM(a.nombre2) AS nombre,
						a.tpo_persona,
						c.fecha_nac,
						c.nacionalidad,
						d.estado,
						a.fecha_insert,
						a.sucursal,
						a.fecha_alta
					INTO
						v_ConteoCliente,
						v_numcte,
						v_nombre,
						v_tpo_persona,
						v_fecha_nac,
						v_nacionalidad,
						v_estado,
						v_fecha_insert,
						v_sucursal,
						v_fecha_alta
					FROM 
						bdinteg:si_cliente a
					INNER JOIN 
						bdinteg:si_ctepf c ON a.numcte = c.numcte
					INNER JOIN 
						bdinteg:si_direcciones_actual d ON a.numcte = d.numcte AND d.secuencia = (
							SELECT MAX(secuencia) FROM bdinteg:si_direcciones_actual WHERE numcte = a.numcte)
					WHERE 
						a.tpo_persona = '01' AND a.fecha_alta=TODAY AND a.numcte = pNumCte GROUP BY a.numcte,nombre, a.tpo_persona,c.fecha_nac,c.nacionalidad,d.estado,a.fecha_insert,a.sucursal,a.fecha_alta;
		
			/* CARACTERISTICAS INHERENTES */
					--Calificar tipo persona
					SELECT puntaje_gdo_riesgo INTO v_puntaje_tpo_persona FROM si_tipper WHERE tpo_persona = v_tpo_persona;
					
					SELECT valor INTO v_porcentaje_tpo_persona FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '01';
					
					LET v_calificacion_tpo_persona = (v_puntaje_tpo_persona*v_porcentaje_tpo_persona)/100;
					
					--Calificar edad
					
					IF MONTH(v_fecha_actual)<MONTH(v_fecha_nac) THEN
						LET v_MenorFechaNac = 1;
					ELIF MONTH(v_fecha_actual)>MONTH(v_fecha_nac) THEN
						LET v_MenorFechaNac = 0;
					ELIF MONTH(v_fecha_actual)=MONTH(v_fecha_nac) THEN
						IF DAY(v_fecha_actual)<DAY(v_fecha_nac) THEN
							LET v_MenorFechaNac = 1;
						ELSE
							LET v_MenorFechaNac = 0;
						END IF;
					END IF;
					
					IF v_MenorFechaNac = 1 THEN
						LET v_edad = (YEAR(v_fecha_actual) - YEAR(v_fecha_nac))-1;
					ELSE
						LET v_edad = YEAR(v_fecha_actual) - YEAR(v_fecha_nac);
					END IF;
					
					SELECT puntaje_gdo_riesgo INTO v_puntaje_edad  FROM si_cat_rango_edad WHERE v_edad between edad_inicio and edad_final ;
					
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
						a.numcte = v_numcte
						AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM si_ingresos WHERE numcte = v_numcte);
					
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
					SELECT FIRST 1
						producto, cuenta
					INTO
						v_prodtarjeta, v_cuenta
					FROM
						bdicheq:sc_maechq WHERE num_cte = v_numcte;
					
					IF v_cuenta = '' OR v_cuenta IS NULL THEN
						LET v_cuenta = '00000000000';
					END IF;
					
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
					
					--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------						
					--Califica deposito
					IF v_depositos_monto IS NOT NULL AND v_depositos_monto != '' AND LENGTH(v_depositos_monto) = 2 THEN
						SELECT puntaje_gdo_riesgo_deposito INTO v_puntaje_deposito FROM bdinteg:si_tipo_montomov WHERE codnummonto = pDepositosMonto;
						
						IF v_puntaje_deposito IS NOT NULL AND v_puntaje_deposito != 0 THEN
							SELECT valor INTO v_porcentaje_deposito FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '08';
							
							LET v_calificacion_deposito = (v_puntaje_deposito*v_porcentaje_deposito)/100;
						END IF;
					END IF;
					
					--Califica retiro
					IF v_retiros_monto IS NOT NULL AND v_retiros_monto != '' AND LENGTH(v_retiros_monto) = 2 THEN
						SELECT puntaje_gdo_riesgo_retiro INTO v_puntaje_retiro FROM bdinteg:si_tipo_montomov WHERE codnummonto = pRetirosMonto;
						
						IF v_puntaje_retiro IS NOT NULL AND v_puntaje_retiro != 0 THEN
							SELECT valor INTO v_porcentaje_retiro FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '09';
							
							LET v_calificacion_retiro = (v_puntaje_retiro*v_porcentaje_retiro)/100;
						END IF;
					END IF;
					
					--Califica frecuencia deposito
					IF v_depositos_cantidad IS NOT NULL AND v_depositos_cantidad != '' AND LENGTH(v_depositos_cantidad) = 2 THEN
						SELECT puntaje_gdo_riesgo_deposito INTO v_puntaje_frecuencia_deposito FROM si_tipo_nummov WHERE codnummo = pDepositosCantidad;
						
						IF v_puntaje_frecuencia_deposito IS NOT NULL AND v_puntaje_frecuencia_deposito != 0 THEN
							SELECT valor INTO v_porcentaje_frecuencia_deposito FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '10';
							
							LET v_calificacion_frecuencia_deposito = (v_puntaje_frecuencia_deposito*v_porcentaje_frecuencia_deposito)/100;
						END IF;
					END IF;
					
					--Califica frecuencia retiro
					IF v_retiros_cantidad IS NOT NULL AND v_retiros_cantidad != '' AND LENGTH(v_retiros_cantidad) = 2 THEN
						SELECT puntaje_gdo_riesgo_deposito INTO v_puntaje_frecuencia_retiro FROM si_tipo_nummov WHERE codnummo = pRetirosCantidad;
						
						IF v_puntaje_frecuencia_retiro IS NOT NULL AND v_puntaje_frecuencia_retiro != 0 THEN
							SELECT valor INTO v_porcentaje_frecuencia_retiro FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '11';
							
							LET v_calificacion_frecuencia_retiro = (v_puntaje_frecuencia_retiro*v_porcentaje_frecuencia_retiro)/100;
						END IF;
					END IF;
					
					LET v_calificacion_frecuencia = v_calificacion_frecuencia_deposito + v_calificacion_frecuencia_retiro;
					
					--Califica origen recurso
					IF v_proced_aperturacta IS NOT NULL AND v_proced_aperturacta != '' AND LENGTH(v_proced_aperturacta) = 2 THEN
						SELECT puntaje_gdo_riesgo INTO v_puntaje_origen_recurso FROM si_tipo_procedencia WHERE procedencia = pProcedAperturaCta;
						
						IF v_puntaje_origen_recurso IS NOT NULL AND v_puntaje_origen_recurso != 0 THEN
							SELECT valor INTO v_porcentaje_origen_recurso FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '12';
							
							LET v_calificacion_origen_recurso = (v_puntaje_origen_recurso*v_porcentaje_origen_recurso)/100;
						END IF;
					END IF;
					
					--Califica destino recurso
					IF v_proced_mantenercta IS NOT NULL AND v_proced_mantenercta != '' AND LENGTH(v_proced_mantenercta) = 2 THEN
						SELECT puntaje_gdo_riesgo INTO v_puntaje_destino_recurso FROM si_cat_tipo_procedencia_uso WHERE procedencia = pProcedMantenerCta;
						
						IF v_puntaje_destino_recurso IS NOT NULL AND v_puntaje_destino_recurso != 0 THEN
							SELECT valor INTO v_porcentaje_destino_recurso FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '13';
							
							LET v_calificacion_destino_recurso = (v_puntaje_destino_recurso*v_porcentaje_destino_recurso)/100;
						END IF;
					END IF;
					
					--Califica importe manejar mes
					IF v_monto_mensual IS NOT NULL AND v_monto_mensual != '' AND LENGTH(v_monto_mensual) = 2 THEN
						SELECT puntaje_gdo_riesgo INTO v_puntaje_importe_manejar_mes FROM si_tipo_montomes WHERE codigo = pMontoMensual;
						
						IF v_puntaje_importe_manejar_mes IS NOT NULL AND v_puntaje_importe_manejar_mes != 0 THEN
							SELECT valor INTO v_porcentaje_importe_manejar_mes FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '14';
							
							LET v_calificacion_importe_manejar_mes = (v_puntaje_importe_manejar_mes*v_porcentaje_importe_manejar_mes)/100;
						END IF;
					END IF;
					
					--Califica caracteristicas transaccionales
					LET v_puntaje_transaccional = v_calificacion_deposito + v_calificacion_retiro + v_calificacion_frecuencia_deposito + v_calificacion_frecuencia_retiro + v_calificacion_origen_recurso + v_calificacion_destino_recurso + v_calificacion_importe_manejar_mes;
					
					SELECT valor INTO v_porcentaje_transaccional FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '15';
					
					LET v_calificacion_transaccional = (v_puntaje_transaccional*v_porcentaje_transaccional)/100;
					
					SELECT COUNT(*) INTO v_persona_expuesta FROM bdinteg:si_cteppes WHERE numcte = pNumCte AND fecha_insert = TODAY;
					
					IF v_persona_expuesta > 0 THEN
						SELECT valor INTO v_calificacion_persona_expuesta FROM si_cat_ponderador_grado_riesgo WHERE id_caracteristica = '16';
					END IF;
					
					LET v_calificacion_grado_riesgo = v_calificacion_inherente + v_calificacion_transaccional + v_calificacion_persona_expuesta;
					
					/* CALIFICA GRADO RIESGO*/
					SELECT descripcion,valor INTO v_riesgo_descripcion_bajo,v_riesgo_valor_bajo FROM si_cat_grado_riesgo WHERE id_grado = '01';
					SELECT descripcion,valor INTO v_riesgo_descripcion_medio,v_riesgo_valor_medio FROM si_cat_grado_riesgo WHERE id_grado = '02';
					SELECT descripcion,valor INTO v_riesgo_descripcion_alto,v_riesgo_valor_alto FROM si_cat_grado_riesgo WHERE id_grado = '03';
					
					LET v_calificacion_grado_riesgo = v_calificacion_inherente + v_calificacion_transaccional + v_calificacion_persona_expuesta;
					
					IF v_calificacion_grado_riesgo <= v_riesgo_valor_bajo THEN
						LET v_grado_riesgo = v_riesgo_descripcion_bajo;
						LET v_TipoRiesgo = '1';
					ELIF v_calificacion_grado_riesgo < v_riesgo_valor_alto THEN
						LET v_grado_riesgo = v_riesgo_descripcion_medio;
						LET v_TipoRiesgo = '2';
					ELIF v_calificacion_grado_riesgo >= v_riesgo_valor_alto THEN
						LET v_grado_riesgo = v_riesgo_descripcion_alto;
						LET v_TipoRiesgo = '3';
					END IF;
					
					SELECT COUNT(*) INTO v_conteo FROM bdinteg:si_cte_grado_riesgo WHERE numcte = pNumCte;
					
					IF v_ConteoCliente > 0 THEN
						IF v_conteo <=0 THEN
							INSERT INTO bdinteg:si_cte_grado_riesgo(
								numcte,
								nombre_cte,
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
								fecha_insert,
								sucursal_apertura,
								fecha_nacimiento,
								fecha_alta,
								estado,
								numcta
							) 
							VALUES(
								v_numcte,
								v_nombre,
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
								TODAY,
								v_sucursal,
								v_fecha_nac,
								TODAY,
								v_estado,
								v_cuenta
								
							);
						END IF;
					END IF;
					

		--ELSE
			RETURN v_CodRet, v_calificacion_grado_riesgo, v_grado_riesgo, v_TipoRiesgo;
		--END IF;
		END
END PROCEDURE

DOCUMENT
'SP para obtener correr la calificaciÃÂÃÂ³n inicial de riesgo de cliente',
'AUTOR : Eduardo ÃÂÃÂvila PÃÂÃÂ©re Tagle',
'Area: Sistemas',
'Gerencia de Mtto y Soporte IV',
'Coordinador: Miguel Angel Mendoza Maldonado',
'Gerente: Victor Hugo SÃÂÃÂ¡nchez Mendoza',
'Fecha: 20/Abril/2024',
'Version: 1.0.0',
'DESCRIPCION: Se corrige calculo de calificacin de carecteristicas inherentes',
'FECHA: 04/11/2024',
'REALIZO: Uriel Amador Islas',
'BD: bdinteg',
'Requerimiento: RQM 11 178 CalificaciÃÂÃÂ³n inicial de riesgo de cliente';

CREATE PROCEDURE "informix".sp_valida_curpp(			pcTipo 		CHAR(1),
														pcNumCte	CHAR(10),
														pcCurp		CHAR(18),
														pcSexo		CHAR(1),
														pcApePat	CHAR(50),
														pcApeMat	CHAR(50),
														pcNombres 	CHAR(50),
														pcFecNac 	CHAR(10),
														pcEntidad   INTEGER,
														pcLimit 	INTEGER,
														pcMensajeR	CHAR(100),
														pcStatus	CHAR(2),
														pcTrans		CHAR(6))
														
														  	  
RETURNING 	CHAR(5) AS cCodRet,CHAR(20) AS cNumCte,CHAR(1) AS pcSexo,CHAR(50) AS cNombres,
			CHAR(50) AS cApePat,CHAR(50) AS cApeMat,CHAR(50) AS cCurp,
			CHAR (10) AS cFecNac,CHAR(2) AS cEntFed;
			
	          
--Definicion de Variables
DEFINE cNumCteAux		CHAR(15);
DEFINE iSqlErr 		  	INTEGER;
DEFINE cCodRet 		  	CHAR(5);  
DEFINE cnumcte        	CHAR(15);   
DEFINE capell_paterno 	CHAR(50);    
DEFINE capell_materno 	CHAR(50);    
DEFINE cnombre1       	CHAR(50);    
DEFINE cnombre2       	CHAR(50);    
DEFINE cfecha_nac     	CHAR(10);  
DEFINE cEntFed		  	CHAR(2);  
DEFINE cCurp		  	CHAR(18);
--DEFINE cidsession		CHAR(30);
DEFINE csexo			CHAR(1);
DEFINE cFecNac			CHAR(10);
--DEFINE iEntidad			INTEGER;
--DEFINE fecha_inicio     DATE;

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '0';
LET cNumCteAux		= '';
LET cnumcte        	= '';    
LET capell_paterno 	= '';    
LET capell_materno 	= '';    
LET cnombre1       	= '';    
LET cnombre2       	= '';    
LET cfecha_nac     	= '';    
LET cEntFed			= '';
LET cCurp			= '';
--LET cidsession		= '';
LET csexo			= '';
LET cFecNac			= '';
--LET iEntidad		= 0 ;
--LET fecha_inicio    =MDY(12,8,2018);

--SET DEBUG FILE TO '/informix/jfponce/DanielGuerrero/sp_valida_curpp.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, '','','','','','','','';
		END IF;
	END EXCEPTION;
	
	IF 	pcTipo = '0' THEN-- Obtener los clientes o empleados a consultar en coppel
		FOREACH WITH HOLD
		
			SELECT first pcLimit {INDEX ("informix".si_ctepf idx_validacurp)}
			D.numcte,P.sexo,D.apell_paterno,D.apell_materno,D.nombre1,D.nombre2,P.fecha_nac,P.lugar_nac,P.curp 
			INTO cnumcte,csexo,capell_paterno,capell_materno,cnombre1,cnombre2,cfecha_nac,cEntFed,ccurp
			FROM "informix".si_ctepf P
			LEFT JOIN "informix".si_cliente D
			ON D.numcte=P.numcte
			--LEFT JOIN "informix".si_estados E
			--ON P.lugar_nac=E.estado 
			WHERE
			P.lugar_nac IN (SELECT estado FROM "informix".si_estados WHERE pais='001' and estado=estado) AND --D.fecha_insert >= MDY(12,08,2015) AND ESTO SE COMENTA PARA PRUEBAS
			P.curp=P.curp AND  P.validacurp IS NULL  		
			AND D.fecha_insert >= MDY(01,01,2024) --D.fecha_insert = TODAY-1  -- ESTO SE PONE PARA PRUEBAS
			 -- AND ESTO SE COMENTA PARA PRUEBAS
			
			
			--LET cFecNac = YEAR(cfecha_nac)||'/'||LPAD(MONTH(cfecha_nac),2,'0')||'/'||LPAD(DAY(cfecha_nac),2,'0');
			LET cFecNac = LPAD(DAY(cfecha_nac),2,'0')||'/'||LPAD(MONTH(cfecha_nac),2,'0')||'/'||YEAR(cfecha_nac);
			
			RETURN cCodret,trim(cnumcte),csexo,trim(trim(cnombre1)||' '||trim(cnombre2)),capell_paterno,capell_materno,NVL(ccurp,''),cFecNac,cEntFed WITH RESUME;
			
		END FOREACH;
		
	ELIF pcTipo = '1' THEN  -- Actualizar validacurp=1 consulta exitosa renapo y se actualiza curp
		IF (pcNumCte IS NULL OR pcNumCte = '') THEN
			LET cCodRet = '00001'; --El cliente is null cuando validacurp=1
		ELSE
			UPDATE "informix".si_ctepf
			SET validaCurp= '1',curp=pcCurp
			WHERE numcte=pcNumCte;

			SELECT numcte INTO cNumCteAux FROM si_bitacora_renapob WHERE numcte = pcNumCte;

			IF cNumCteAux = '' THEN
				--INSERSION EN BITACORA RENAPO
				INSERT INTO "informix".si_bitacora_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			ELSE
				--INSERSION EN TABLA HISTORICA
				INSERT INTO "informix".si_historica_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			END IF;
			
		END IF;
		RETURN cCodRet,pcNumCte,'','','','','','','';
		
	ELIF pcTipo = '2' THEN  -- Actualizar solo validacurp=2 La curp no existe en la base de datos Renapo.
		IF (pcNumCte IS NULL OR pcNumCte = '') THEN
			LET cCodRet = '00002'; --El cliente is null cuando validacurp=2
		ELSE	
			UPDATE "informix".si_ctepf
			SET validaCurp= '2'
			WHERE numcte=pcNumCte;
			
			SELECT numcte INTO cNumCteAux FROM si_bitacora_renapob WHERE numcte = pcNumCte;

			IF cNumCteAux = '' THEN
				--INSERSION EN BITACORA RENAPO
				INSERT INTO "informix".si_bitacora_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			ELSE
				--INSERSION EN TABLA HISTORICA
				INSERT INTO "informix".si_historica_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			END IF;
			
		END IF;
		RETURN cCodRet, '','','','','','','','';
		
	ELIF pcTipo = '3' THEN  --Actualizar solo validacurp=3 El cliente cuenta con mas de un curp
		IF (pcNumCte IS NULL OR pcNumCte = '') THEN
			LET cCodRet = '00003'; --El cliente is null cuando validacurp=3
		ELSE

			UPDATE "informix".si_ctepf 
			SET validacurp ='3'
			WHERE numcte=pcNumCte;
			
			SELECT numcte INTO cNumCteAux FROM si_bitacora_renapob WHERE numcte = pcNumCte;

			IF cNumCteAux = '' THEN
				--INSERSION EN BITACORA RENAPO
				INSERT INTO "informix".si_bitacora_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			ELSE
				--INSERSION EN TABLA HISTORICA
				INSERT INTO "informix".si_historica_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			END IF;

		END IF;
		RETURN cCodRet,'','','','','','','','';

	ELIF pcTipo = '4' THEN  -- Actualizar registros exitosos
		IF (pcNumCte IS NULL OR pcNumCte = '' )THEN
			LET cCodRet = '00004'; --Valor de parametros nulos o no valido
		ELSE
			UPDATE "informix".si_ctepf 
			SET validacurp ='4', lugar_nac = pcEntidad
			WHERE numcte=pcNumCte;
			
			SELECT numcte INTO cNumCteAux FROM si_bitacora_renapob WHERE numcte = pcNumCte;

			IF cNumCteAux = '' THEN
				--INSERSION EN BITACORA RENAPO
				INSERT INTO "informix".si_bitacora_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			ELSE
				--INSERSION EN TABLA HISTORICA
				INSERT INTO "informix".si_historica_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			END IF;
			
		END IF;
		RETURN cCodRet,pcNumCte,'','','','','','','';	
		
	ELIF pcTipo = '5' THEN  --Actualizar solo validacurp=5 Ocurrio un error no controlado
		IF (pcNumCte IS NULL OR pcNumCte = '') THEN
			LET cCodRet = '00005'; --El cliente is null cuando validacurp=3
		ELSE

			UPDATE "informix".si_ctepf 
			SET validacurp ='5'
			WHERE numcte=pcNumCte;
			
			SELECT numcte INTO cNumCteAux FROM si_bitacora_renapob WHERE numcte = pcNumCte;

			IF cNumCteAux = '' THEN
				--INSERSION EN BITACORA RENAPO
				INSERT INTO "informix".si_bitacora_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			ELSE
				--INSERSION EN TABLA HISTORICA
				INSERT INTO "informix".si_historica_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			END IF;
			
		END IF;
		RETURN cCodRet,'','','','','','','','';
		
		
	ELSE
		LET cCodRet = '00069';	--El valor de pTipo no coincide con ninguno del sps
	RETURN cCodRet, '','','','','','','','';
	
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Angel Daniel Hernandez Gallardo',
'FECHA: 26/09/2024',
'SUSTENTO: RQI 63 1121',
'MODIFICACION: Se modifica procedimiento almacenado para insertar informacion en la tabla historica si_historica_renapob';

CREATE PROCEDURE "informix".sp_tarcop( pNumCte     CHAR(20),  -- NO. CLIENTE
                                              PNumTarcoppel CHAR(20),
											  POption INTEGER )-- TARJETA COPPEL 
RETURNING   CHAR(5) AS cod_error,
            CHAR(20) AS num_tarjeta,
            CHAR (100) AS NOMBRE,
            DECIMAL(12,2) AS monto_solicitado;  -- CODIGO DE RETORNO
    
    DEFINE vcodret1 CHAR(5);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
	DEFINE vTarjCop CHAR(20);
    DEFINE cNombre CHAR(100);
    DEFINE mSolicitado DECIMAL(12,2);
 
    
    LET vcodret1 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
	LET vTarjCop = '';
    LET cNombre = '';
    LET mSolicitado = '';
    
    BEGIN
    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_graba_correos.err";
        --TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            RETURN vcodret1, vTarjCop, cNombre, mSolicitado;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_graba_correos.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pNumCte is null OR pNumCte = '') OR
       (PNumTarcoppel is null OR PNumTarcoppel = '') THEN
        LET vcodret1 = '00001';
        RETURN vcodret1, vTarjCop, cNombre, mSolicitado;
    END IF;

    SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2) ||' '||TRIM( apell_paterno) ||' '|| TRIM(apell_materno) AS Nombre
    INTO cNombre
    FROM bdinteg:"informix".si_cliente 
    WHERE numcte = pNumCte;

    SELECT monto_solicitado
    INTO mSolicitado
    FROM bdisolic:"informix".ss_solicitudes
    WHERE numcte = pNumCte
    AND num_producto ='6500';

    IF ( POption = 1) THEN
        DELETE FROM bdinteg:"informix".si_conscoppel WHERE numcte = pNumCte;
		INSERT INTO bdinteg:"informix".si_conscoppel
		(empresa, numcte, numtarcoppel, fechahora)
		VALUES
		('001', pNumCte, PNumTarcoppel, CURRENT);
		
		SELECT numtarcoppel
		INTO vTarjCop
		FROM bdinteg:"informix".si_conscoppel
		WHERE numcte = pNumCte
        AND numtarcoppel = PNumTarcoppel;
		
		IF vTarjCop <> '' THEN
			LET vcodret1 = '00000';
		ELSE 
			LET vcodret1 = '00002';
		END IF;

	ELSE 

		SELECT numtarcoppel
		INTO vTarjCop
		FROM bdinteg:"informix".si_conscoppel
		WHERE numcte = pNumCte
        AND numtarcoppel = PNumTarcoppel;

        IF vTarjCop <> '' THEN
			LET vcodret1 = '00000';
		ELSE 
			LET vcodret1 = '00002';
		END IF;

	END IF;
    
    END; 

    RETURN vcodret1, vTarjCop, cNombre, mSolicitado;

END PROCEDURE;