CREATE PROCEDURE "informix".sp_sd_ri_rep_camp()
RETURNING CHAR(5);

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	--Peticion: INC 28 112 - ERROR en Job 206_23_2_GENERA_REP_CAMP_PRO
	--Autor: 98769022 Miguel Alejandro Sanchez Mojica
	--Fecha: 28/02/2019
	--Modificacion: Se modifica para eliminar si existen tablas temporales, las borre. Se controla el error -1202 para el campo v_Num_Ctas_Elegibles. Se controla el error -1205 en el rango de fechas para recuperar el mes anterior, cuando el mes es Enero.
	--BD: bdicred
	-------------------------------------------------------------------------------------
	--Peticion: RQI 28 194 - Proceso de automatizaciÃ³n de RI a demanda
	--Modificado por: 98769022 Miguel Alejandro Sanchez Mojica
	--Fecha de modificaciÃ³n: 07/08/2019
	--ModificaciÃ³n: Se agregan validaciones para realizar los reportes de la recompensa a demanda y modificaciÃ³n de la creaciÃ³n de los archivos (LPAD (DAY(today),2,"0")).
	--BD: bdicred
	-------------------------------------------------------------------------------------
	--Peticion: RQM 10 1287 - AplicaciÃ³n de monto variable de CashBack
	--Modificado por: 98769022 Miguel Alejandro Sanchez Mojica
	--Fecha de modificaciÃ³n: 13/12/2019
	--ModificaciÃ³n: Se agregan modificaciones para poder generar los reportes dependiendo de las recompesas que se hayan aplicado (mensual, a demanda o por monto directo).
	--BD: bdicred
	-------------------------------------------------------------------------------------

--- Declaracion de Variables
	DEFINE 	v_FechaHoy					DATE;    		-- Variable para Fecha actual
	DEFINE 	v_PrimerTransacion 			DATE;			-- Variable para primer transaccion del credito correspondiente
	DEFINE 	v_Fecha20MesAntPeriodos		DATE;			-- Variable para Fecha mes anterior por periodos con inicio en dia 20
	DEFINE 	v_Fecha21MesAntPeriodos		DATE;			-- Variable para Fecha mes anterior por periodos con inicio en dia 21
	DEFINE 	v_Fecha20Mesactual			DATE;			-- Variable para Fecha mes actual con inicio en dia 20
	DEFINE 	v_MesActual					INTEGER; 		-- Variable para Mes actual
	DEFINE 	v_AnioActual				INTEGER; 		-- Variable para AÃÂ±o actual
	DEFINE 	v_TotalCampActiva			INTEGER;		-- Variable para contador de campaÃÂ±as activas
	DEFINE 	v_TotalCampADemanda			INTEGER;		-- Variable para contador de campaÃÂ±as a demanda
	DEFINE	v_monto_total				DECIMAL (18,2);	-- Variable para monto total de transacciones
	DEFINE  v_monto_recompensa			DECIMAL(18,2);	-- RQM 10 1287
	DEFINE	v_a_demanda					INTEGER;		-- RQM 10 1287
	DEFINE  v_id_recompensa 			INTEGER;
	DEFINE  v_tipo_transacc 			CHAR(2);
	DEFINE  v_tipo_recompensa 			INTEGER;
	DEFINE  v_numero_credito 			CHAR(20);
	DEFINE  v_status_credito 			CHAR(2);
	DEFINE  v_periodo					INTEGER;
	DEFINE  v_periodomen  				INTEGER;
    DEFINE cCodRet              		CHAR(5); --> Variables de codigos de retorno  
	DEFINE CodRet              			CHAR(5); --> Variables de codigos de retorno  
    DEFINE sql_err              		INTEGER;
    DEFINE isam_err             		INTEGER;
	DEFINE CMensaje             		CHAR(80);
	DEFINE wBegin						CHAR (1);
    DEFINE vsql                         CHAR(2000);
	DEFINE v_id_alta_recompensa 		INTEGER;
	DEFINE v_id_tipo_recompensa 		INTEGER;
	DEFINE v_Num_Recompensas_otorgadas 	INTEGER;
	DEFINE v_Num_Ctas_Elegibles 		INTEGER;
	DEFINE v_Efectividad				DECIMAL (18,2);
--- Inicializa variables	
	LET cCodRet            	= ''; 			-- Variables de codigos de retorno  
    LET sql_err            	= 0 ; 
    LET isam_err           	= 0 ; 
	LET CMensaje           	= ''; 
	LET  wBegin				= '';
	LET v_TotalCampADemanda = 0 ;
---
	LET v_status_credito = ''; --> sd_maecred
--- desactivar Debug   

	--SET DEBUG FILE TO "/resplogifx/Credito_BE/sp_sd_ri_rep_camp.out";													
    --TRACE ON;

	BEGIN

		ON EXCEPTION SET sql_err,isam_err,CMensaje
		LET cCodRet = sql_err;

		RETURN cCodRet;
	  
	END EXCEPTION;

	LET cCodRet      		= '';
	LET CodRet      		= '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
      
--- se realiza calculo de fechas 
	SELECT 	MONTH(fecha_hoy), 													-- Mes actual
			YEAR(fecha_hoy), 													-- AÃÂ±o actual												
			fecha_hoy 															-- Fecha actual
	INTO	v_MesActual, 															
			v_AnioActual,
			v_FechaHoy 
	FROM	"informix".sd_fechas
	WHERE	empresa = '001';
	
	-- RQM 10 1287 Inicio
	IF ((day(v_FechaHoy) = 26 and month(v_FechaHoy) <> 12) OR (day(v_FechaHoy) = 27 and month(v_FechaHoy) = 12)) THEN
		-- RQI 28 194 Inicio
		--- se valida si hay campaÃ±as de recompensa a demanda que se ejecutaron en el dÃ­a
		SELECT 		COUNT(1)
		INTO 		v_TotalCampADemanda															-- Variable para contador de CampaÃ±as a demanda
		FROM 	    bdicred:sd_ri_altarecompensa AR 
		INNER JOIN  bdicred:sd_ri_rangorecompensa RR ON(AR.pky_id_altarecompensa = RR.fky_id_altarecompensa)
		WHERE	    AR.activo = 0 AND RR.id_periodo = 0 AND RR.numero_op_inicial = 0 AND RR.numero_op_final = 0 
		AND         RR.monto_op_inicial = 0 AND RR.monto_op_final = 0		
		AND 		AR.fecha_ejecucion = v_FechaHoy;
		
		SELECT 	COUNT(1)
		INTO 	v_TotalCampActiva																-- Variable para contador de CampaÃ±as activas
		FROM 	bdicred:sd_ri_altarecompensa
		WHERE	activo = 1	
		AND 	MONTH (fecha_final) = v_MesActual	
		AND		YEAR (fecha_final) = v_AnioActual
		AND 	fecha_ejecucion <= v_FechaHoy;							 

	ELSE
		SELECT 		COUNT(1)
		INTO 		v_TotalCampADemanda															-- Variable para contador de CampaÃ±as a demanda
		FROM 	    bdicred:sd_ri_altarecompensa AR 
		INNER JOIN  bdicred:sd_ri_rangorecompensa RR ON(AR.pky_id_altarecompensa = RR.fky_id_altarecompensa)
		WHERE	    AR.activo = 0 AND RR.id_periodo = 0 AND RR.numero_op_inicial = 0 AND RR.numero_op_final = 0 
		AND         RR.monto_op_inicial = 0 AND RR.monto_op_final = 0		
		AND 		AR.fecha_ejecucion = v_FechaHoy;
	END IF;
	-- RQM 10 1287 Fin

	--- Se valida si hay transacciones activas
	IF	(v_TotalCampActiva <> 0 OR v_TotalCampADemanda <> 0) THEN						-- RQI 28 194
	
		-- Proceso para generar Reporte de CampaÃ±as de Recompensa Inmediata
		---Verificar tabla fisica que se usarÃ¡ de manera temporal
/*	
		if exists( select * from systables where tabname ='sd_ri_adendum_temp1') then
			drop table sd_ri_adendum_temp1;
		end if; 
*/
		-- INC 28 112 Inicio
		-- Si existen las tablas las elimina
		DROP TABLE IF EXISTS sd_ri_adendum_temp1;
		DROP TABLE IF EXISTS adendum_virtual;
		-- INC 28 112 Fin
		
		-- Creacion de tabla
		CREATE TABLE "informix".sd_ri_adendum_temp1(                             
			id_recompensa   		INTEGER,  
			periodo     			INTEGER,
			status     				INTEGER,
			tipo_transacc      		VARCHAR(2),
			campana              	VARCHAR(45),                          
			tipo_recompensa     	INTEGER,
			desc_recompensa         VARCHAR(30),   
			numero_credito         	VARCHAR(20),   
			status_credito         	VARCHAR(2),
			monto_recompensa     	DECIMAL(18,2),
			fecha_periodo	     	VARCHAR(10),
			monto        			DECIMAL(18,2),
			numero_transacciones   	INTEGER,
			a_demanda				INTEGER			-- RQM 10 1287
		);
		
		-- Si se hace proceso, hay campaÃ±as activas    
		SELECT      a.pky_id_altarecompensa AS ID_recompensa,
					d.id_periodo AS periodo,
					a.activo AS status,
					a.id_tipo_transacc AS tipo_transacc,
					a.nombre_campana AS campania,
					a.fky_id_tipo_recompensa AS tipo_recompensa,
					e.nombre AS desc_recompensa,
					b.num_credito AS numero_credito,
					'  ' AS status_credito,
					(CASE WHEN a.id_tipo_transacc = 0 THEN CAST(0 AS CHAR(3)) ELSE d.monto_recompensa END) AS monto_recompensa,	-- RQM 10 1287
					'          ' AS fecha_periodo,
					(CASE WHEN a.id_tipo_transacc = 0 AND b.recompensado = 1 THEN b.monto_variable ELSE c.monto END) AS monto,	-- RQM 10 1287
					(CASE WHEN c.total_op IS NULL THEN 0 ELSE c.total_op END) AS numero_transacciones,
					-- RQM 10 1287 Inicio
					(CASE 
						WHEN d.monto_op_inicial = 0 AND d.monto_op_final = 0 AND d.numero_op_inicial = 0 AND d.numero_op_final = 0 AND d.id_periodo = 0
							THEN 1
						ELSE 0
					END) AS a_demanda
					-- RQM 10 1287 Fin
		FROM        bdicred:sd_ri_altarecompensa 	a 
		LEFT JOIN  	bdicred:sd_ri_archivos 			b
		ON      	a.pky_id_altarecompensa = b.fky_id_altarecompensa 
					AND a.fky_id_archivo = b.pky_id_archivo 
		LEFT JOIN  	bdicred:sd_ri_redencion 		c 
		ON          c. fky_id_altarecompensa = a.pky_id_altarecompensa
					AND	c.fky_id_tipo_recompensa = a.fky_id_tipo_recompensa
					AND	c.num_credito = b.num_credito  
		LEFT JOIN   bdicred:sd_ri_rangorecompensa 	d 
		ON          a.pky_id_altarecompensa = d.fky_id_altarecompensa
					AND	a.fky_id_tipo_recompensa = d.fky_id_tipo_recompensa 
		LEFT JOIN   bdicred:sd_ri_cat_tipo_recompensa 	e 
		ON          a.fky_id_tipo_recompensa = e.pky_id_tipo_recompensa 
		WHERE   	--a.activo = CASE WHEN v_TotalCampActiva <> 0 THEN 1 ELSE 0 END AND				-- RQM 10 1287
					month(fecha_final) = v_MesActual AND year(fecha_final) = v_AnioActual			-- RQI 28 194
		AND			a.fecha_ejecucion = v_FechaHoy													-- RQI 28 194
		INTO 		temp adendum_virtual WITH NO LOG; 
		
				
		-- se realiza proceso para todos los creditos obtenidos
		FOREACH WITH HOLD	
				
			--- se obtienen los registros
			SELECT 	id_recompensa, 
					tipo_transacc, 
					tipo_recompensa, 
					numero_credito, 
					periodo,
					monto_recompensa,		-- RQM 10 1287
					a_demanda				-- RQM 10 1287
			INTO  	v_id_recompensa, 
					v_tipo_transacc, 
					v_tipo_recompensa, 
					v_numero_credito, 
					v_periodo,
					v_monto_recompensa,		-- RQM 10 1287
					v_a_demanda				-- RQM 10 1287
			FROM 	bdicred:adendum_virtual
			
			-- RQM 10 1287 Inicio
			-- Valida que solo realice las acciones para los registros donde la transacciÃ³n no es de CARGO DIRECTO y que el monto de la recompensa sea mayor a 0/
			-- TambiÃ©n valida que solo realice las acciones para los registros donde la transacciÃ³n sea de CARGO DIRECTO
			IF((v_tipo_transacc > 0 AND v_monto_recompensa > 0) OR v_tipo_transacc = 0 )	THEN

				-- Consulta para validar STATUS del producto   
				SELECT	status_cred
				INTO 	v_status_credito
				FROM 	bdicred:sd_maecred 
				WHERE 	empresa = '001'
				AND 	num_credito = v_numero_credito;
						
				--LET v_status_credito = v_status_credito;	

				UPDATE 	bdicred:adendum_virtual 
				SET 	status_credito = v_status_credito
				WHERE	id_recompensa = v_id_recompensa
				AND		tipo_transacc = v_tipo_transacc
				AND		tipo_recompensa = v_tipo_recompensa
				AND		numero_credito = v_numero_credito;					   
			
			/*	
				--- se obtiene rango de fechas para buscar la primer transaccion del periodo requerido, restando total de periodos (meses) a la fecha actual
				SELECT 	mdy((MONTH(fecha_hoy)-v_periodo), 21 , YEAR(fecha_hoy)) , mdy((MONTH(fecha_hoy)), 20 , YEAR(fecha_hoy)) 
				INTO	v_Fecha21MesAntPeriodos,v_Fecha20MesActual
				FROM	"informix".sd_fechas
				WHERE	empresa = '001';
			*/
				-- RQI 28 194 Inicio
				-- Validar si hay recompensas a demandas ejecutados en el dÃ­a, asignar en v_Fecha21MesAntPeriodos la fecha actual
				IF v_a_demanda = 0	THEN	-- RQM 10 1287
					-- INC 28 112 Inicio
					-- Se obtiene rango de fechas para buscar la primer transaccion del periodo requerido, restando total de periodos (meses) a la fecha actual
					SELECT 	mdy(
								CASE
									WHEN MONTH(fecha_hoy) <= v_periodo THEN (12 + MONTH(fecha_hoy)) - v_periodo
									ELSE MONTH(fecha_hoy) - v_periodo
								END,
								21,
								CASE
									WHEN MONTH(fecha_hoy) <= v_periodo THEN YEAR(fecha_hoy) - 1 
									ELSE YEAR(fecha_hoy)
								END),
							mdy((MONTH(fecha_hoy)), 20 , YEAR(fecha_hoy)) 
					INTO	v_Fecha21MesAntPeriodos,v_Fecha20MesActual
					FROM	"informix".sd_fechas
					WHERE	empresa = '001';
					-- INC 28 112 Fin
				ELSE
					LET v_Fecha21MesAntPeriodos = v_FechaHoy;
				END IF;
				-- RQI 28 194 Fin
				
				--- Se actualiza la fecha del registro correspondiente al periodo de entrega de recompensa inmediata		
				UPDATE 	bdicred:adendum_virtual 
				SET 	fecha_periodo = v_Fecha21MesAntPeriodos
				WHERE	id_recompensa = v_id_recompensa
				AND		tipo_transacc = v_tipo_transacc
				AND		tipo_recompensa = v_tipo_recompensa
				AND		numero_credito = v_numero_credito;	
			/*						
				--- consulta para obtener la primera transacion del periodo evaluado de acuerdo a los periodos de la campaÃ±a
				SELECT  FIRST 1 fecha_mov
				INTO  	v_PrimerTransacion
				FROM    bdicred:sd_movhis 
				WHERE   	empresa = '001' 
						AND (fecha_mov BETWEEN v_Fecha21MesAntPeriodos AND v_Fecha20Mesactual)
						AND	num_credito = v_numero_credito
						AND	codigo_fun = '002'
						AND	codigo_ref = 37 
						AND	reversado = 'N';
					
				--- se valida primer transaccion en el periodo seÃ±alado para actualizar la fecha valor del dato 
				IF (v_PrimerTransacion  is not null) THEN		
					UPDATE 	bdicred:adendum_virtual 
					SET 	fecha_transaccion = v_PrimerTransacion
					WHERE		id_recompensa = v_id_recompensa
							AND	tipo_transacc = v_tipo_transacc
							AND	tipo_recompensa = v_tipo_recompensa
							AND	numero_credito = v_numero_credito;
			
					--- se hace calculo de fecha para posicionarse en el periodo indicado
					LET v_periodomen = v_periodo - 1;
					LET v_monto_total = 0;
								
					SELECt	mdy((MONTH(fecha_hoy)-v_periodomen), 20 , YEAR(fecha_hoy))
					INTO	v_Fecha20MesAntPeriodos
					FROM	"informix".sd_fechas 
					WHERE	empresa = '001';
			
					--- dependiendo del tipo de transacciÃ³n, se suman montos de transacciones en el periodo seÃ±alado, se actualiza el monto total de transacciones correspondiente al credito
					-----> PAGO VENTANILLA (SELECT num_pagos, monto_pagos from bdicred:sd_indicador_cred_hist) 
					IF ( v_tipo_transacc = '7' ) THEN
						SELECT  SUM (monto_pagos)
						INTO 	v_monto_total
						FROM 	bdicred:sd_indicador_cred_hist
						WHERE 	empresa = '001' 
								AND (fecha BETWEEN v_Fecha20MesAntPeriodos AND v_Fecha20MesActual)
								AND DAY (fecha) = DAY(v_Fecha20MesActual)
								AND num_credito = v_numero_credito; 
					END IF;
			
					-----> CARGO VENTANILLA (SELECT num_vtn, monto_vtn from bdicred:sd_indicador_cred_hist) 
					IF ( v_tipo_transacc = '8' ) THEN
						SELECT 	SUM (monto_vtn)
						INTO 	v_monto_total
						FROM 	bdicred:sd_indicador_cred_hist
						WHERE 	empresa = '001' 
								AND (fecha BETWEEN v_Fecha20MesAntPeriodos AND v_Fecha20MesActual)
								AND day (fecha) = DAY(v_Fecha20MesActual)
								AND num_credito = v_numero_credito;
					END IF;
			
					-----> CARGO POSIF (SELECT num_pos, monto_pos from bdicred:sd_indicador_cred_hist) 
					IF ( v_tipo_transacc = '9' ) THEN
						SELECT 	SUM (monto_pos)
						INTO 	v_monto_total
						FROM 	bdicred:sd_indicador_cred_hist
						WHERE 	empresa = '001'
								AND (fecha BETWEEN v_Fecha20MesAntPeriodos AND v_Fecha20MesActual)
								AND DAY (fecha) = DAY(v_Fecha20MesActual)
								AND num_credito = v_numero_credito;
					END IF;
			
							-----> CARGO ATM (SELECT num_atm, monto_atm from bdicred:sd_indicador_cred_hist) 
					IF ( v_tipo_transacc = '10' ) THEN
						SELECT 	SUM (monto_atm)
						INTO 	v_monto_total
						FROM 	bdicred:sd_indicador_cred_hist
						WHERE 	empresa = '001' 
								AND (fecha BETWEEN v_Fecha20MesAntPeriodos AND v_Fecha20MesActual)
								AND DAY (fecha) = DAY(v_Fecha20MesActual)
								AND num_credito = v_numero_credito;
					END IF; 
			
					IF	(v_monto_total <> 0) THEN 
						UPDATE 	bdicred:adendum_virtual 
						SET 	monto = v_monto_total
						WHERE	id_recompensa = v_id_recompensa
								AND	tipo_transacc = v_tipo_transacc
								AND	tipo_recompensa = v_tipo_recompensa
								AND	numero_credito = v_numero_credito;
					END IF;
			
				END IF; 
			*/
			END IF;
			-- RQM 10 1287 Fin
		END FOREACH;

		-- no se hace proceso, no hay campaÃ±as activas
		-- genera archivo indicando que no hay compaÃ±as activas a reportar
		UPDATE 	bdicred:adendum_virtual 
		SET 	monto = 0
		WHERE	monto = 9999999999.99;

		INSERT INTO sd_ri_adendum_temp1 (id_recompensa, periodo, status, tipo_transacc, campana, tipo_recompensa, desc_recompensa, numero_credito, status_credito, monto_recompensa, fecha_periodo, monto, numero_transacciones, a_demanda)	-- RQM 10 1287
		SELECT * FROM bdicred:adendum_virtual;		   
	
		-- Se elimina tabla virtual
		DROP TABLE adendum_virtual;				
						
		UPDATE 	bdicred:sd_ri_adendum_temp1 
		SET 	fecha_periodo = ' '
		WHERE	fecha_periodo IS NULL;
						
						
		-- Generacion del Reporte de CampaÃ±as de Recompensa Inmediata con informaciÃ³n a reportar (ReporteRecompensa_DDMMAAAA.txt)
		let vsql = '';
		let vsql = 'echo "Campana|Tipo_Recompensa|Desc_Recompensa|NÃºmero_CrÃ©dito|Status_CrÃ©dito|Monto_Recompensa|Fecha_Periodo|Monto|NÃºmero_Transacciones">/resplogifx/Credito_BE/ReporteRecompensa_'||LPAD (DAY(today),2,"0")||LPAD (MONTH(today),2,"0")||year(today)||'.txt';  -- RQI 28 194
		system vsql;  
		
		let vsql = '';
		let vsql=  'echo "UNLOAD TO /resplogifx/Credito_BE/QA_archivo.unl select campana, tipo_recompensa, desc_recompensa, numero_credito, status_credito, monto_recompensa, fecha_periodo, monto, numero_transacciones from bdicred:sd_ri_adendum_temp1;">/resplogifx/Credito_BE/QA_Script.sql';      
		system vsql;
		
		let vsql='chmod a+rwx /resplogifx/Credito_BE/QA_Script.sql';
		System vsql;
		
		let vsql = '';
		let vsql= 'dbaccess bdicred /resplogifx/Credito_BE/QA_Script.sql';
		system vsql;
		
		let vsql = vsql;
		let vsql ='rm /resplogifx/Credito_BE/QA_Script.sql';
		
		system vsql;
		let vsql ='';
		let vsql = "sed 's/|$//g' /resplogifx/Credito_BE/QA_archivo.unl >>/resplogifx/Credito_BE/ReporteRecompensa_"||LPAD (DAY(today),2,"0")||LPAD (MONTH(today),2,"0")||year(today)||'.txt';	-- RQI 28 194
		system vsql;
		let vsql ='rm /resplogifx/Credito_BE/QA_archivo.unl';
		system vsql; 
		
		-- Se elimina tabla Temporal
		DROP TABLE sd_ri_adendum_temp1; 
			
		-- Proceso para generar Resumen de CampaÃ±as de Recompensa Inmediata	
		---Verificar tabla fisica que se usarÃ¡ de manera temporal
/*	
		if exists( select * from systables where tabname ='sd_ri_adendum_temp2') then
			drop table sd_ri_adendum_temp2;
		end if; 
*/	
		-- INC 28 112 Inicio
		-- Si existen las tablas las elimina
		DROP TABLE IF EXISTS sd_ri_adendum_temp2;
		DROP TABLE IF EXISTS adendum_virtual_2;
		-- INC 28 112 Fin
		
		-- Creacion de tabla
		CREATE TABLE "informix".sd_ri_adendum_temp2( 
			id_alta_recompensa   		INTEGER,
			id_tipo_recompensa   		INTEGER,
			campana              		VARCHAR(45),
			impacto              		VARCHAR(25),
			monto_rec					DECIMAL(18,2),
			fecha_inicio     			VARCHAR(10),
			fecha_cierre     			VARCHAR(10),
			Num_Ctas_Elegibles   		INTEGER,  
			Num_Recompensas_otorgadas   INTEGER, 
			Ctas_Sin_Recompensa   		INTEGER,
			Efectividad					DECIMAL(18,2)                            
		);

		SELECT  pky_id_altarecompensa AS id_alta_recompensa, fky_id_tipo_recompensa AS id_tipo_recompensa, nombre_campana , 
				(CASE WHEN fky_id_tipo_recompensa = 1 THEN 'Monetaria' ELSE 'No Monetaria' END) AS impacto,
				-- RQM 10 1287 Inicio
				(CASE 
					WHEN id_tipo_transacc = 0 
						THEN CAST(0 AS CHAR(3))
					ELSE (select  distinct(monto_recompensa) 
						 from    bdicred:sd_ri_rangorecompensa 
						 where   pky_id_altarecompensa = fky_id_altarecompensa)
				END) as monto_rec ,
				-- RQM 10 1287 Fin
				fecha_inicio, fecha_final as fecha_cierre , 
				(   select  count(num_credito) 
					from    bdicred:sd_ri_archivos 
					where   pky_id_archivo = fky_id_archivo) as Num_Ctas_Elegibles , 
				(   select  count (num_credito) 
					from    bdicred:sd_ri_redencion 
					where   fky_id_altarecompensa = pky_id_altarecompensa and 
							fky_id_tipo_recompensa = fky_id_tipo_recompensa ) as Num_Recompensas_otorgadas ,
				(   select  count (num_credito) 
					from    bdicred:sd_ri_redencionagotada 
					where   fky_id_altarecompensa = pky_id_altarecompensa and 
							fky_id_tipo_recompensa = fky_id_tipo_recompensa ) as Ctas_Sin_Recompensa, 
					(0/ 100) as Efectividad
					--(v_Num_Ctas_Elegibles / v_Num_Recompensas_otorgadas) as Efectividad
		FROM    bdicred:sd_ri_altarecompensa
		WHERE   -- activo = CASE WHEN v_TotalCampActiva <> 0 THEN 1 ELSE 0 END	AND			-- RQM 10 1287
				month(fecha_final) = v_MesActual AND year(fecha_final) = v_AnioActual		-- RQI 28 194
		AND		fecha_ejecucion = v_FechaHoy												-- RQI 28 194
		INTO 	temp adendum_virtual_2 WITH NO LOG; 
		
			-- se realiza proceso para todos los creditos obtenidos
			FOREACH WITH HOLD	
			
				--- se obtienen solo los registros que tengan transacciones redimidas
				SELECT 	id_alta_recompensa,
						id_tipo_recompensa,
						Num_Recompensas_otorgadas, 
						Num_Ctas_Elegibles
				INTO  	v_id_alta_recompensa,
						v_id_tipo_recompensa,
						v_Num_Recompensas_otorgadas, 
						v_Num_Ctas_Elegibles
				FROM 	bdicred:adendum_virtual_2
				
				-- INC 28 112 Inicio
				-- Valida si el valor de v_Num_Ctas_Elegibles es mayor a 0
				IF (v_Num_Ctas_Elegibles > 0)	THEN
					LET v_Efectividad = v_Num_Recompensas_otorgadas * 100 / v_Num_Ctas_Elegibles;
				ELSE 
					LET v_Efectividad = NULL;
				END IF;
				-- INC 28 112 Fin
				
				--- se valida primer transaccion en el periodo seÃ±alado para actualizar la fecha valor del dato 
				IF (v_Efectividad  is not null) THEN		
					UPDATE 	bdicred:adendum_virtual_2 
					SET 	Efectividad = v_Efectividad
					WHERE	id_alta_recompensa = v_id_alta_recompensa
					AND		id_tipo_recompensa = v_id_tipo_recompensa;

				END IF; 

			END FOREACH;
			
			INSERT INTO sd_ri_adendum_temp2 (id_alta_recompensa, id_tipo_recompensa , campana, impacto, monto_rec, fecha_inicio, fecha_cierre, Num_Ctas_Elegibles, Num_Recompensas_otorgadas, Ctas_Sin_Recompensa, Efectividad)
			SELECT * FROM adendum_virtual_2;
			
			-- Se elimina tabla virtual
			DROP TABLE adendum_virtual_2;
										
			-- Generacion del Reporte de CampaÃ±as de Recompensa Inmediata con informaciÃ³n a reportar
			let vsql = '';
			let vsql = 'echo "Campana|Tipo_Recompensa|Monto_Recompensa|Impacto|Fecha_Inicio_Cam|Fecha_Cierre_Cam|Num_Ctas_Elegibles|Num_Recompensas_otorgadas|Ctas_Sin_Recompensa|Efectividad">/resplogifx/Credito_BE/ResumenRecompensa_'||LPAD (DAY(today),2,"0")||LPAD (MONTH(today),2,"0")||year(today)||'.txt';  -- RQI 28 194
			system vsql;  
			
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/Credito_BE/QA_archivo_2.unl select campana, id_tipo_recompensa, monto_rec, impacto, fecha_inicio, fecha_cierre, Num_Ctas_Elegibles, Num_Recompensas_otorgadas, Ctas_Sin_Recompensa, Efectividad from bdicred:sd_ri_adendum_temp2;">/resplogifx/Credito_BE/QA_Script_2.sql';      
			system vsql;
			
			let vsql='chmod a+rwx /resplogifx/Credito_BE/QA_Script_2.sql';
			System vsql;
			
			let vsql = '';
			let vsql= 'dbaccess bdicred /resplogifx/Credito_BE/QA_Script_2.sql';
			system vsql;
			
			let vsql = vsql;
			let vsql ='rm /resplogifx/Credito_BE/QA_Script_2.sql';
			
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/Credito_BE/QA_archivo_2.unl >>/resplogifx/Credito_BE/ResumenRecompensa_"||LPAD (DAY(today),2,"0")||LPAD (MONTH(today),2,"0")||year(today)||'.txt';	-- RQI 28 194
			system vsql;
			let vsql ='rm /resplogifx/Credito_BE/QA_archivo_2.unl';
			system vsql; 
			
			-- Se elimina tabla Temporal
			DROP TABLE sd_ri_adendum_temp2; 
			
		ELSE
			--Generacion de Reporte y Resumen de CampaÃ±as de Recompensa Inmediata sin informaciÃ³n a reportar
			let vsql = '';
			let vsql = 'echo " <<< No hay informaciÃ³n a reportar >>>">/resplogifx/Credito_BE/ReporteRecompensa_'||LPAD (DAY(today),2,"0")||LPAD (MONTH(today),2,"0")||year(today)||'.txt';  -- RQI 28 194
			system vsql;
			
			let vsql = '';
			let vsql = 'echo " <<< No hay informaciÃ³n a reportar >>>">/resplogifx/Credito_BE/ResumenRecompensa_'||LPAD (DAY(today),2,"0")||LPAD (MONTH(today),2,"0")||year(today)||'.txt';  -- RQI 28 194
			system vsql;
	END IF;	
	
	LET CodRet = '00000'; --> Proceso concluyo exitosamente

	END;
	
	LET cCodRet = CodRet;
	
	RETURN cCodRet;

END PROCEDURE;