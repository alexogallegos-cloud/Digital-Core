CREATE PROCEDURE "informix".sp_genera_rep_camp()
RETURNING CHAR(5);

--- Declaracion de Variables
	DEFINE 	v_FechaHoy					DATE;    		-- Variable para Fecha actual
	DEFINE 	v_PrimerTransacion 			DATE;			-- Variable para primer transaccion del credito correspondiente
	DEFINE 	v_Fecha20MesAntPeriodos		DATE;			-- Variable para Fecha mes anterior por periodos con inicio en dia 20
	DEFINE 	v_Fecha21MesAntPeriodos		DATE;			-- Variable para Fecha mes anterior por periodos con inicio en dia 21
	DEFINE 	v_Fecha20Mesactual			DATE;			-- Variable para Fecha mes actual con inicio en dia 20
	DEFINE 	v_MesActual					INTEGER; 		-- Variable para Mes actual
	DEFINE 	v_AnioActual				INTEGER; 		-- Variable para Año actual
	DEFINE 	v_TotalCampActiva			INTEGER;		-- Variable para contador de campañas activas
	DEFINE	v_monto_total				DECIMAL (18,2);	 -- Variable para monto total de transacciones
	DEFINE  v_id_recompensa 			INTEGER;
	DEFINE  v_tipo_transacc 			CHAR(2);
	DEFINE  v_tipo_recompensa 			INTEGER;
	DEFINE  v_numero_credito 			CHAR(20);
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
	DEFINE	v_Efectividad				DECIMAL (18,2);
--- Inicializa variables	
	LET cCodRet            	= ''; 			-- Variables de codigos de retorno  
    LET sql_err            	= 0 ; 
    LET isam_err           	= 0 ; 
	LET CMensaje           	= ''; 
	LET  wBegin				= '';
---
/*
--- desactivar Debug   
    SET DEBUG FILE TO "/resplogifx/Credito_BE/QA_log.out";
    TRACE ON;
	*/

	BEGIN

    ON EXCEPTION SET sql_err,isam_err,CMensaje
      LET cCodRet = sql_err;

      RETURN cCodRet;
	  
	END EXCEPTION;


	LET cCodRet      		= '';
	LET CodRet      		= '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
      
    set ISOLATION to dirty read;
--- se realiza calculo de fechas 
	SELECT 	MONTH(fecha_hoy), 													-- Mes actual
			YEAR(fecha_hoy), 													-- Año actual
			fecha_hoy 															-- Fecha actual
	INTO	v_MesActual, 															
			v_AnioActual,
			v_FechaHoy 
	FROM	"informix".sd_fechas 
	WHERE	empresa = '001';

--- se valida si hay campañas activas en el mes actual
	SELECT COUNT(1)
	into v_TotalCampActiva														-- Variable para contador de Campañas activas
	FROM 	bdicred:sd_ri_altarecompensa
	WHERE		activo = 1	
			AND MONTH (fecha_final) 	= 	v_MesActual	
			AND	YEAR (fecha_final) 		= 	v_AnioActual;

	--- Se valida si hay transacciones activas
	IF	(v_TotalCampActiva <> 0) THEN			
	
		-- Proceso para generar Reporte de Campañas de Recompensa Inmediata
		---Verificar tabla fisica que se usará de manera temporal
	
		if exists( select * from systables where tabname ='sd_ri_adendum_temp1') then
			drop table sd_ri_adendum_temp1;
		end if; 

		--creacion de tabla

		CREATE TABLE "informix".sd_ri_adendum_temp1(                             
			id_recompensa   		INTEGER,  
			periodo     			INTEGER,
			status     				INTEGER,
			tipo_transacc      		VARCHAR(2),
			campana              	VARCHAR(45),                          
			tipo_recompensa     	INTEGER,
			numero_credito         	VARCHAR(20),
			monto_recompensa     	DECIMAL(18,2),
			fecha_transaccion     	VARCHAR(10),
			monto        			DECIMAL(18,2),
			numero_transacciones   	INTEGER                             
		);
		
				--- si se hace proceso, hay campañas activas    
			set ISOLATION to dirty read;
			SELECT      a.pky_id_altarecompensa AS ID_recompensa,
						d.id_periodo AS periodo,
						a.activo AS status,
						a.id_tipo_transacc AS tipo_transacc,
						a.nombre_campana AS campania,
						a.fky_id_tipo_recompensa AS tipo_recompensa,
						b.num_credito AS numero_credito,
						(CASE WHEN c.fky_id_tipo_recompensa = 1 THEN c.monto ELSE 0 END) AS monto_recompensa,
						'          ' AS fecha_transaccion,
						9999999999.99 AS monto,
						(CASE WHEN c.total_op IS NULL THEN 0 ELSE c.total_op END) AS numero_transacciones
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
			WHERE   	a.activo = 1 
						AND	month (fecha_final) = v_MesActual	
						AND	year (fecha_final) = v_AnioActual
			INTO 	temp adendum_virtual WITH NO LOG; 
		
				
			-- se realiza proceso para todos los creditos obtenidos
			FOREACH WITH HOLD	
					
				--- se obtienen solo los registros que tengan transacciones redimidas
				SELECT 	id_recompensa, 
							tipo_transacc, 
							tipo_recompensa, 
							numero_credito, 
							periodo
					INTO  	v_id_recompensa, 
							v_tipo_transacc, 
							v_tipo_recompensa, 
							v_numero_credito, 
							v_periodo
					FROM 	bdicred:adendum_virtual
					WHERE 	monto_recompensa <> 0
					
				--- se obtiene rango de fechas para buscar la primer transaccion del periodo requerido, restando total de periodos (meses) a la fecha actual
				SELECT 	mdy((MONTH(fecha_hoy)-v_periodo), 21 , YEAR(fecha_hoy)) , mdy((MONTH(fecha_hoy)), 20 , YEAR(fecha_hoy)) 
				INTO	v_Fecha21MesAntPeriodos,v_Fecha20MesActual
				FROM	"informix".sd_fechas 
				WHERE	empresa = '001';
			
				--- consulta para obtener la primera transacion del periodo evaluado de acuerdo a los periodos de la campaña
				SELECT  FIRST 1 fecha_mov
				INTO  	v_PrimerTransacion
				FROM    bdicred:sd_movhis 
				WHERE   	empresa = '001' 
						AND (fecha_mov BETWEEN v_Fecha21MesAntPeriodos AND v_Fecha20Mesactual)
						AND	num_credito = v_numero_credito
						AND	codigo_fun = '002'
						AND	codigo_ref in (37,937,938) 
						AND	reversado = 'N';
					
				set ISOLATION to dirty read;
				--- se valida primer transaccion en el periodo señalado para actualizar la fecha valor del dato 
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
								
					set ISOLATION to dirty read;
					SELECt	mdy((MONTH(fecha_hoy)-v_periodomen), 20 , YEAR(fecha_hoy))
					INTO	v_Fecha20MesAntPeriodos
					FROM	"informix".sd_fechas 
					WHERE	empresa = '001';
			
					--- dependiendo del tipo de transacción, se suman montos de transacciones en el periodo señalado, se actualiza el monto total de transacciones correspondiente al credito
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
		
			END FOREACH;

			-- no se hace proceso, no hay campañas activas
			-- genera archivo indicando que no hay compañas activas a reportar
				SET isolation to dirty read;
			UPDATE 	bdicred:adendum_virtual 
			SET 	monto = 0
			WHERE	monto = 9999999999.99;
				
			SET isolation to dirty read;
			INSERT INTO sd_ri_adendum_temp1 (id_recompensa, periodo, status, tipo_transacc, campana, tipo_recompensa, numero_credito, monto_recompensa, fecha_transaccion, monto, numero_transacciones)
			SELECT * FROM bdicred:adendum_virtual;		   
	
			-- Se elimina tabla virtual
			DROP TABLE adendum_virtual;				
							
			SET isolation to dirty read;
			UPDATE 	bdicred:sd_ri_adendum_temp1 
			SET 	fecha_transaccion = ' '
			WHERE	fecha_transaccion IS NULL;
							
							
			-- Generacion del Reporte de Campañas de Recompensa Inmediata con información a reportar
			let vsql = '';
			let vsql = 'echo "Campana|Tipo_Recompensa|Número_Crédito|Monto_Recompensa|Fecha_Transacción|Monto|Número_Transacciones">/resplogifx/Credito_BE/ReporteRecompensa_'||day(today)||LPAD (MONTH(today),2,"0")||year(today)||'.txt';  
			system vsql;  
			
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/Credito_BE/QA_archivo.unl select campana, tipo_recompensa, numero_credito, monto_recompensa, fecha_transaccion, monto, numero_transacciones from bdicred:sd_ri_adendum_temp1;">/resplogifx/Credito_BE/QA_Script.sql';      
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
			let vsql = "sed 's/|$//g' /resplogifx/Credito_BE/QA_archivo.unl >>/resplogifx/Credito_BE/ReporteRecompensa_"||day(today)||LPAD (MONTH(today),2,"0")||year(today)||'.txt';
			system vsql;
			let vsql ='rm /resplogifx/Credito_BE/QA_archivo.unl';
			system vsql; 
			
			-- Se elimina tabla Temporal
			DROP TABLE sd_ri_adendum_temp1; 
			
		-- Proceso para generar Resumen de Campañas de Recompensa Inmediata	
		---Verificar tabla fisica que se usará de manera temporal
	
		if exists( select * from systables where tabname ='sd_ri_adendum_temp2') then
			drop table sd_ri_adendum_temp2;
		end if; 
	
		--creacion de tabla

		CREATE TABLE "informix".sd_ri_adendum_temp2( 
			id_alta_recompensa   			INTEGER,
			id_tipo_recompensa   			INTEGER,
			campana              		VARCHAR(45),
			fecha_inicio     			VARCHAR(10),
			fecha_cierre     			VARCHAR(10),
			Num_Ctas_Elegibles   		INTEGER,  
			Num_Recompensas_otorgadas   INTEGER, 
			Ctas_Sin_Recompensa   		INTEGER,
			Efectividad					DECIMAL(18,2)                            
		);

		select  pky_id_altarecompensa AS id_alta_recompensa, fky_id_tipo_recompensa AS id_tipo_recompensa, nombre_campana , fecha_inicio, fecha_final as fecha_cierre , 
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
		from    bdicred:sd_ri_altarecompensa
		where   month (fecha_final) = (month (v_FechaHoy))
				and year (fecha_final) = (year (v_FechaHoy))
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
				
				LET v_Efectividad = v_Num_Recompensas_otorgadas/v_Num_Ctas_Elegibles;
		
				--- se valida primer transaccion en el periodo señalado para actualizar la fecha valor del dato 
				IF (v_Efectividad  is not null) THEN		
					UPDATE 	bdicred:adendum_virtual_2 
					SET 	Efectividad = v_Efectividad
					WHERE		id_alta_recompensa = v_id_alta_recompensa
							AND	id_tipo_recompensa = v_id_tipo_recompensa;

				END IF; 

			END FOREACH;
			
			INSERT INTO sd_ri_adendum_temp2 (id_alta_recompensa, id_tipo_recompensa , campana, fecha_inicio, fecha_cierre, Num_Ctas_Elegibles, Num_Recompensas_otorgadas, Ctas_Sin_Recompensa, Efectividad)
			SELECT * FROM adendum_virtual_2;
			
			-- Se elimina tabla virtual
			DROP TABLE adendum_virtual_2;
										
			-- Generacion del Reporte de Campañas de Recompensa Inmediata con información a reportar
			let vsql = '';
			let vsql = 'echo "Campana|Fecha_Inicio_Cam|Fecha_Cierre_Cam|Num_Ctas_Elegibles|Num_Recompensas_otorgadas|Ctas_Sin_Recompensa|Efectividad">/resplogifx/Credito_BE/ResumenRecompensa_'||day(today)||LPAD (MONTH(today),2,"0")||year(today)||'.txt';  
			system vsql;  
			
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/Credito_BE/QA_archivo_2.unl select campana, fecha_inicio, fecha_cierre, Num_Ctas_Elegibles, Num_Recompensas_otorgadas, Ctas_Sin_Recompensa, Efectividad from bdicred:sd_ri_adendum_temp2;">/resplogifx/Credito_BE/QA_Script_2.sql';      
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
			let vsql = "sed 's/|$//g' /resplogifx/Credito_BE/QA_archivo_2.unl >>/resplogifx/Credito_BE/ResumenRecompensa_"||day(today)||LPAD (MONTH(today),2,"0")||year(today)||'.txt';
			system vsql;
			let vsql ='rm /resplogifx/Credito_BE/QA_archivo_2.unl';
			system vsql; 
			
			-- Se elimina tabla Temporal
			DROP TABLE sd_ri_adendum_temp2; 
			
		ELSE
			--Generacion de Reporte y Resumen de Campañas de Recompensa Inmediata sin información a reportar
			let vsql = '';
			let vsql = 'echo " <<< No hay información a reportar >>>">/resplogifx/Credito_BE/ReporteRecompensa_'||day(today)||LPAD (MONTH(today),2,"0")||year(today)||'.txt';  
			system vsql;
			
			let vsql = '';
			let vsql = 'echo " <<< No hay información a reportar >>>">/resplogifx/Credito_BE/ResumenRecompensa_'||day(today)||LPAD (MONTH(today),2,"0")||year(today)||'.txt';  
			system vsql;
	END IF;	
		
	
	
	LET CodRet = '00000'; --> Proceso concluyo exitosamente

	END;
	
	LET cCodRet = CodRet;
	
	RETURN cCodRet;

END PROCEDURE;