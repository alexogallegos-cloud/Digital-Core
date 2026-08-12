CREATE PROCEDURE "informix".sp_chi_ope_concilia_com ( p_carga_info INTEGER, p_fecha_concilia DATE )
	RETURNING CHAR(5) as codigo_retorno;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	--Peticion: RQM 10 1404 - Hipotecario Infonavit
	--Creado por: 98769022 Miguel Alejandro Sánchez Mojica
	--Fecha de creación: 21/04/2021
	--Creación: Se realiza la conciliación de comisiones (Saldos Hito vs Saldos Bancoppel (Pólizas))
	--BD: bdicred
	-------------------------------------------------------------------------------------
	--Peticion: RQM 10 1404 - Hipotecario Infonavit
	--Creado por: 98769022 Miguel Alejandro Sánchez Mojica
	--Fecha de creación: 07/12/2021
	--Creación: Se realiza cambio en la asignación de valores en las variables v_importe_a y v_importe_c
	--BD: bdicred
	-------------------------------------------------------------------------------------

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	DEFINE     	cod_ret                 		CHAR(5);
	DEFINE 		v_empresa 						VARCHAR(3);
	DEFINE		v_sum_com_seguro_vida			DECIMAL(18,2);
	DEFINE		v_sum_com_infonavit             DECIMAL(18,2);
	DEFINE		v_sum_com_hito                  DECIMAL(18,2);
	DEFINE		v_count_creditos				INTEGER;
	DEFINE 		v_fecha_concilia				DATE;
	DEFINE 		v_fecha_inicial					DATE;
	DEFINE 		v_fecha_final					DATE;
	DEFINE		v_nombre_sdo					VARCHAR(50);
	DEFINE		v_id_rel						INTEGER;
	DEFINE		v_id_cta_cont					INTEGER;
	DEFINE		v_cta							VARCHAR(4);
	DEFINE		v_subcta                        VARCHAR(2);
	DEFINE		v_subsubcta                     VARCHAR(2);
	DEFINE		v_ssubsubcta                    VARCHAR(2);
	DEFINE		v_sssubsubcta                   VARCHAR(2);
	DEFINE		v_sector                        VARCHAR(2);
	DEFINE 		v_mes_actual					INTEGER;
	DEFINE 		v_anio_actual					INTEGER;
	DEFINE 		v_count_concilia				INTEGER;		-- Variable para validar si hay registros en la tabla de conciliaciones con la misma fecha (en caso de haber error en la ejecución anterior del día)
	DEFINE 		v_concilia_info					INTEGER;		-- Variable para validar si hay información para la concialiación, 1 = Si hay información, 0 = No hay información
	DEFINE 		v_importe_c						DECIMAL(18,2);
	DEFINE 		v_importe_a						DECIMAL(18,2);
	DEFINE		v_total_balanza					DECIMAL(18,2);
	DEFINE		v_total_reporte					DECIMAL(18,2);
	DEFINE		v_total_diferencia				DECIMAL(18,2);

-- ****************************************************************************
-- *                    INICIALIZACION DE VARIABLES                           *
-- ****************************************************************************
	LET 	   	cod_ret 					= '00000'; 
	LET 		v_empresa	   	      		= '001';
	LET			v_fecha_concilia			= p_fecha_concilia;
	LET			v_mes_actual				= LPAD(MONTH(v_fecha_concilia), 2, '0');
	LET			v_anio_actual				= YEAR(v_fecha_concilia);
	LET 		v_count_concilia	   	    = 0;
	LET 		v_count_creditos	   	    = 0;
	LET 		v_concilia_info	   	      	= 1;
	LET 		v_total_reporte				= 0;
	LET			v_total_diferencia			= 0;
	
	BEGIN
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		--*****************************************************************
		--*						Debug del Procedure                     --*        
		--*****************************************************************
		--SET DEBUG FILE TO '/RESPALDOSNEW/hipotecario_infonavit/operaciones/sp_chi_ope_concilia_com.out';
		--TRACE ON; 
		
		-- ****************************************************************************
		-- *                        PROGRAMA PRINCIPAL                                *
		-- ****************************************************************************	
		-- ****************************************************************************
		-- *                    CONCILICIACIÓN DE COMISIONES                          *
		-- ****************************************************************************	
		
		-- Si hay información cargada realizar la conciliación, si NO, limpiar la tabla de conciliaciones y asignar el valor 0 a la variable v_concilia_info
		IF(p_carga_info = 1) THEN
			
			-- Contar los regtistros de la tabla de conciliación
			SELECT 	COUNT(fecha_proceso)
			INTO	v_count_concilia
			FROM 	bdicred:"informix".sd_chi_ope_concilia_com
			WHERE	empresa = v_empresa AND fecha_proceso = v_fecha_concilia;
			
			-- Si no existen registros en la tabla de conciliación con la fecha actual, insertar en tabla histórica; si existen registros, limpiar tabla de conciliación ya que la ejecución se identifica como re-proceso
			IF(v_count_concilia = 0) THEN
			
				-- Insertar registros de la tabla principal a la tabla histórica
				INSERT INTO sd_chi_ope_concilia_com_hist SELECT * FROM sd_chi_ope_concilia_com;
				
			ELSE
				-- Limpiar la tabla de conciliaciones 
				TRUNCATE TABLE bdicred:"informix".sd_chi_ope_concilia_com;
				
			END IF;
			
			-- Calcular rango de fechas para la búsqueda de información de pólizas
			-- SI el mes actual es 01 (ENERO) asignar en automático el mes 12 y restar un año al año actual, si NO, restar un mes al mes actual
			IF (v_mes_actual = 1) THEN
				
				LET v_fecha_inicial = mdy(12,01,v_anio_actual - 1);
				
			ELSE
			
				LET v_fecha_inicial = mdy(v_mes_actual - 1,01,v_anio_actual);
				
			END IF;
			
			-- Obtener la última fecha del mes anterior
			LET v_fecha_final = LAST_DAY(v_fecha_inicial);

			-- Seleccionar información de la fecha actual de la tabla de carga
			SELECT 	SUM(com_seguro_vida), SUM(com_infonavit), SUM(com_hito), COUNT(DISTINCT credito)
			INTO 	v_sum_com_seguro_vida, v_sum_com_infonavit, v_sum_com_hito, v_count_creditos
			FROM 	bdicred:"informix".sd_chi_ope_sdos_com
			WHERE	empresa = v_empresa AND fecha_carga = v_fecha_concilia;
			
			FOREACH WITH HOLD
							
				-- Obtener las cuentas contables para obtener los importes totales
				SELECT  	TRIM(a.nombre_sdo), b.id_rel, c.id_cta_cont, c.cta, c.subcta, c.subsubcta, c.ssubsubcta, c.sssubsubcta, c.sector
				INTO 		v_nombre_sdo, v_id_rel, v_id_cta_cont, v_cta, v_subcta, v_subsubcta, v_ssubsubcta, v_sssubsubcta, v_sector
				FROM    	bdicred:"informix".sd_chi_ope_tiposdos a 
				INNER JOIN 	bdicred:"informix".sd_chi_ope_rel_prod_tiposdos_ctascontables b ON a.empresa = b.empresa AND a.id_sdo = b.id_sdo AND b.status = 1
				INNER JOIN  bdicred:"informix".sd_chi_ope_ctascontables c ON c.empresa = b.empresa AND c.id_cta_cont = b.id_cta_cont AND c.status = 1
				WHERE   	a.empresa = v_empresa AND a.nombre_sdo LIKE '%COMISIONES%' AND a.status = 1
				
				-- Obtener el importe de los cargos de la póliza de acuerdo a la cuenta contable
				SELECT	SUM(importe)
				INTO	v_importe_a
				FROM 	bdicred:"informix".sd_chi_carga_reg_cont_hist
				WHERE 	cta =  v_cta AND subcta = v_subcta AND subsubcta = v_subsubcta AND ssubsubcta = v_ssubsubcta AND sssubsubcta = v_sssubsubcta AND sector = v_sector
				AND		fechaintegracion BETWEEN v_fecha_inicial AND v_fecha_final AND naturaleza = 'C' AND poliza > 0;
				
				-- Obtener el importe de los abonos de la póliza de acuerdo a la cuenta contable
				SELECT	SUM(importe)
				INTO	v_importe_c
				FROM 	bdicred:"informix".sd_chi_carga_reg_cont_hist
				WHERE 	cta =  v_cta AND subcta = v_subcta AND subsubcta = v_subsubcta AND ssubsubcta = v_ssubsubcta AND sssubsubcta = v_sssubsubcta AND sector = v_sector
				AND		fechaintegracion BETWEEN v_fecha_inicial AND v_fecha_final AND naturaleza = 'D' AND poliza > 0;
				
				-- Asignar 0 a variable si no existe información
				LET v_total_balanza = nvl(v_importe_c, 0) - nvl(v_importe_a, 0);
				
				-- Asignar importes totales
				IF (v_nombre_sdo LIKE '%COMISIONES POR SEGURO%') THEN
				
					LET v_total_reporte = nvl(v_sum_com_seguro_vida, 0);
				
				ELIF (v_nombre_sdo LIKE '%COMISIONES INFONAVIT%') THEN
				
					LET v_total_reporte = nvl(v_sum_com_infonavit, 0);
				
				ELIF (v_nombre_sdo LIKE '%COMISIONES HITO%') THEN
				
					LET v_total_reporte = nvl(v_sum_com_hito, 0);
					
				END IF;
				
				-- Calcular importe total diferencia
				LET v_total_diferencia = v_total_reporte - v_total_balanza;
				
				-- Insertar en la tabla principal
				INSERT INTO bdicred:"informix".sd_chi_ope_concilia_com VALUES ( v_empresa, v_fecha_concilia, v_id_rel, v_total_reporte, v_total_balanza, v_total_diferencia );
				
			END FOREACH;
		
		ELSE
		
			-- Limpiar la tabla de conciliaciones 
			TRUNCATE TABLE bdicred:"informix".sd_chi_ope_concilia_com;
			
			LET v_concilia_info = 0;
		
		END IF;

		-- Ejecuta Stored Procedure para la generación del reporte
		CALL bdicred:sp_chi_ope_rep_concilia_com(v_concilia_info, v_fecha_concilia, v_count_creditos) RETURNING cod_ret;

		RETURN cod_ret;	
    END	
END PROCEDURE;