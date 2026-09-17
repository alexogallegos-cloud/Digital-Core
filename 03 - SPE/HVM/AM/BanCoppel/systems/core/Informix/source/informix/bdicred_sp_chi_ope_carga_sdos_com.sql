CREATE PROCEDURE "informix".sp_chi_ope_carga_sdos_com ()
	RETURNING CHAR(5) as codigo_retorno;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	--Peticion: RQM 10 1404 - Hipotecario Infonavit
	--Creado por: 98769022 Miguel Alejandro Sánchez Mojica
	--Fecha de creación: 14/05/2021
	--Creación: Se realiza la carga de la información del archivo chi_ope_rep_sdos_com_aaaamm.txt
	--BD: bdicred
	-------------------------------------------------------------------------------------
	--Peticion: RQM 10 1404 - Hipotecario Infonavit
	--Modificado por: 98769022 Miguel Alejandro Sánchez Mojica
	--Fecha de modificación: 10/08/2021
	--Modificación: Se modifica las longitudes de la columna status_operativo de varchar(10) a varchar(20)
	--BD: bdicred
	-------------------------------------------------------------------------------------
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES ERROR                        *
-- ****************************************************************************
    DEFINE     	sql_err                 INTEGER;
    DEFINE     	isam_err                INTEGER;
    DEFINE     	cod_ret                 CHAR(5);
	DEFINE	   	mensaje_ret				VARCHAR(255);
	
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

	DEFINE 		v_empresa 						VARCHAR(3);
	DEFINE 		v_fecha_carga 					DATE;
	DEFINE 		v_producto 						VARCHAR(20);
	DEFINE 		v_periodo 						VARCHAR(10);
	DEFINE 		v_credito 						VARCHAR(20);
	DEFINE 		v_status_operativo 				VARCHAR(20);
	DEFINE 		v_fecha_cesion 					DATE;
	DEFINE 		v_fecha_firma 					DATE;
	DEFINE 		v_regimen 						VARCHAR(5);
	DEFINE 		v_status 						VARCHAR(5);
	DEFINE 		v_com_seguro_vida				DECIMAL(18,2);
	DEFINE		v_iva_com_seguro_vida 			DECIMAL(18,2);
	DEFINE		v_com_infonavit					DECIMAL(18,2);
	DEFINE		v_iva_com_infonavit				DECIMAL(18,2);
	DEFINE		v_com_hito 						DECIMAL(18,2);
	DEFINE		v_iva_com_hito					DECIMAL(18,2);
	DEFINE 		v_count_temp					INTEGER;		-- Variable para contar el número de registros en la tabla temporal y validar si existe información a cargar
	DEFINE 		v_cargar_info					INTEGER;		-- Variable para validar si se cargó información, 1 = Si hay información, 0 = No hay información
	DEFINE 		v_count_info					INTEGER;		-- Variable para validar si hay registros en la tabla de carga con la misma fecha (en caso de haber error en la ejecución anterior del día)
	DEFINE 		v_comienza_commit				INTEGER;		-- Variable para los commits parciales
	DEFINE 		v_suma_registros				INTEGER;		-- Variable para los commits parciales
	
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES RUTAS                        *
-- ****************************************************************************
	DEFINE 		cRuta				    CHAR(100);
	DEFINE 		cSQL                    CHAR(1000);
	DEFINE 		cNomSQL                 CHAR(100);
	DEFINE 		cDia					CHAR(2);
	DEFINE 		cMes					CHAR(2);
	DEFINE 		cYear				    CHAR(4);
	DEFINE 		cMesActual				INTEGER;
	DEFINE 		cArchivo			    CHAR(100);
	DEFINE 		cNombreArchivo		    CHAR(100);
	
-- ****************************************************************************
-- *                INICIALIZACION DE VARIABLES ERRORES                       *
-- ****************************************************************************
	LET 		sql_err      			= 0;
	LET 		isam_err     			= 0;
    LET 	   	cod_ret 				= '00000'; 
	LET 	   	mensaje_ret 			= 'PROCESO EXITOSO';

-- ****************************************************************************
-- *                    INICIALIZACION DE VARIABLES                           *
-- ****************************************************************************
	LET 		v_empresa	   	      	= '001';
	LET 		v_count_temp	   	    = 0;
	LET 		v_cargar_info			= 1;
	LET			v_fecha_carga			= TODAY;
	LET 		v_comienza_commit		= 0;
	LET 		v_suma_registros		= 0;

-- ****************************************************************************
-- *                  INICIALIZACION DE VARIABLES RUTAS                       *
-- ****************************************************************************
	LET 		cRuta		 			= "/resplogifx/hipotecario_infonavit/operaciones/";
	LET 		cSQL					= "";
	LET 		cNomSQL					= "sd_chi_ope_sdos_com_temp.sql";
	LET 		cArchivo				= "chi_ope_rep_sdos_com_";
	LET 		cYear 					= YEAR(v_fecha_carga);
	LET 		cMesActual				= MONTH(v_fecha_carga);
	LET			cNombreArchivo			= "";
	
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

    BEGIN
	
		ON EXCEPTION SET sql_err, isam_err
			IF sql_err != 0 THEN
			
				LET cod_ret = '11111';

				-- Limpiar la tabla de carga 
				TRUNCATE TABLE bdicred:"informix".sd_chi_ope_sdos_diarios;
							
				RETURN cod_ret;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-668) SET sql_err, isam_err
			IF sql_err != 0 THEN
			
				LET cod_ret = '22222';		
				LET mensaje_ret = 'VERIFICAR RUTA DEL ARCHIVO A CARGAR, TIPOS DE DATOS Y LONGITUDES';
				
				-- Limpiar la tabla de carga 
				TRUNCATE TABLE bdicred:"informix".sd_chi_ope_sdos_diarios;
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-1207) SET sql_err, isam_err
			IF sql_err != 0 THEN
			
				LET cod_ret = '33333';		
				LET mensaje_ret = 'VERIFICAR TIPOS DE DATOS Y LONGITUDES';
				
				-- Limpiar la tabla de carga 
				TRUNCATE TABLE bdicred:"informix".sd_chi_ope_sdos_diarios;
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-268) SET sql_err, isam_err
			IF sql_err != 0 THEN
			
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
				
				-- Limpiar la tabla de carga 
				TRUNCATE TABLE bdicred:"informix".sd_chi_ope_sdos_diarios;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-691) SET sql_err, isam_err
			IF sql_err != 0 THEN
			
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
				
				-- Limpiar la tabla de carga 
				TRUNCATE TABLE bdicred:"informix".sd_chi_ope_sdos_diarios;
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        --*****************************************************************
        --*						Debug del Procedure                     --*        
        --*****************************************************************
		--SET DEBUG FILE TO '/resplogifx/hipotecario_infonavit/operaciones/sp_chi_ope_carga_sdos_com.out';
		--TRACE ON;                                                     
		
		-- ****************************************************************************
		-- *                        PROGRAMA PRINCIPAL                                *
		-- ****************************************************************************	
		-- ****************************************************************************
		-- *                       IMPORTACION DE ARCHIVO                             *
		-- ****************************************************************************	
    
		-- Limpiar tabla temporal
		DROP TABLE IF EXISTS bdicred:"informix".sd_chi_ope_sdos_com_temp;

		-- Crear tabla temporal
		CREATE TABLE bdicred:"informix".sd_chi_ope_sdos_com_temp(                             
			producto 					VARCHAR(20),
			periodo 					VARCHAR(10),
			credito 					VARCHAR(20),
			status_operativo 			VARCHAR(20),
			fecha_cesion 				DATE,
			fecha_firma 				DATE,
			regimen 					VARCHAR(5),
			status 						VARCHAR(5),
			com_seguro_vida				DECIMAL(18,2),
			iva_com_seguro_vida 		DECIMAL(18,2),
			com_infonavit				DECIMAL(18,2),
			iva_com_infonavit			DECIMAL(18,2),
			com_hito 					DECIMAL(18,2),
			iva_com_hito				DECIMAL(18,2)
		);
		
		-- Calcular mes y año anterior para la búsqueda del archivo con la información
		-- SI el mes actual es 01 (ENERO) asignar en automático el mes 12 y restar un año al año actual, si NO, restar un mes al mes actual
		IF (cMesActual = 1) THEN
			
			LET cMes = '12';
			LET cYear = YEAR(v_fecha_carga) - 1;
			
		ELSE
		
			LET cMes = LPAD(MONTH(v_fecha_carga)-1, 2, '0');
			
		END IF;
		
		
		LET cNombreArchivo = TRIM(cArchivo) || cYear || cMes || '.txt ';
		LET cSQL =  ' echo "SET ISOLATION TO DIRTY READ; LOAD FROM ' || TRIM(cRuta) || TRIM(cNombreArchivo) || 
					' INSERT INTO bdicred:"informix".sd_chi_ope_sdos_com_temp;' || "" || '">'||TRIM(cRuta)|| TRIM(cNomSQL);
		SYSTEM TRIM(cSQL);

		LET cSQL='chmod 777 '|| TRIM(cRuta)|| TRIM(cNomSQL);
		SYSTEM cSQL;

		LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || TRIM(cNomSQL);
		SYSTEM cSQL;
		
		LET cSQL = 'rm ' || TRIM(cRuta) || TRIM(cNomSQL);
		SYSTEM cSQL;
		
		-- Validar si existen registros a cargar
		SELECT 	COUNT(producto)
		INTO	v_count_temp
		FROM 	bdicred:"informix".sd_chi_ope_sdos_com_temp;
		
		-- Si existen registros en la tabla temporal, realizar el proceso de carga
		IF(v_count_temp > 0)	THEN
		
			-- Contar los regtistros de la tabla de carga
			SELECT 	COUNT(producto)
			INTO	v_count_info
			FROM 	bdicred:"informix".sd_chi_ope_sdos_com
			WHERE	empresa = v_empresa AND fecha_carga = v_fecha_carga;
			
			-- Si no existen registros en la tabla de carga con la fecha actual, insertar en tabla histórica; si existen registros, limpiar tabla de carga ya que la ejecución se identifica como re-proceso
			IF(v_count_info = 0) THEN
			
				-- Insertar registros de la tabla de carga a la tabla histórica
				INSERT INTO sd_chi_ope_sdos_com_hist SELECT * FROM sd_chi_ope_sdos_com;
				
			END IF;
			
			-- Limpiar la tabla de carga 
			TRUNCATE TABLE bdicred:"informix".sd_chi_ope_sdos_com;
			
			FOREACH WITH HOLD
				
				-- Seleccionar información de tabla temporal
				SELECT 	producto, periodo, credito, status_operativo, fecha_cesion,
						fecha_firma, regimen, status, com_seguro_vida, iva_com_seguro_vida,
						com_infonavit, iva_com_infonavit, com_hito, iva_com_hito
				INTO 	v_producto, v_periodo, v_credito, v_status_operativo, v_fecha_cesion,
						v_fecha_firma, v_regimen, v_status, v_com_seguro_vida, v_iva_com_seguro_vida,
						v_com_infonavit, v_iva_com_infonavit, v_com_hito, v_iva_com_hito
				FROM 	bdicred:"informix".sd_chi_ope_sdos_com_temp

					-- ABRE COMMIT'S PARCIALES
				IF (v_comienza_commit = 0) THEN
					LET v_comienza_commit = 1;
					BEGIN WORK;
				END IF;
				
				-- Insertar en la tabla principal
				INSERT INTO bdicred:"informix".sd_chi_ope_sdos_com VALUES	(v_empresa, v_fecha_carga, v_producto, v_periodo, v_credito,
																			 v_status_operativo, v_fecha_cesion, v_fecha_firma, v_regimen, v_status,
																			 nvl(v_com_seguro_vida,0), nvl(v_iva_com_seguro_vida,0), nvl(v_com_infonavit,0), 
																			 nvl(v_iva_com_infonavit,0), nvl(v_com_hito,0), nvl(v_iva_com_hito,0));
																			 
				LET v_suma_registros = v_suma_registros + 1;
			
				--REALIZA COMMIT CADA 1,000 REGISTROS
				IF (v_suma_registros >= 1000) THEN
					LET v_suma_registros = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			
			IF (v_suma_registros > 0) THEN
				COMMIT WORK;
			END IF;
			
		ELSE

			LET v_cargar_info = 0;

		END IF;
		
		-- Ejecuta Stored Procedure para la conciliación de movimientos
		CALL bdicred:sp_chi_ope_concilia_com(v_cargar_info, v_fecha_carga) RETURNING cod_ret;
		
		-- Limpiar tabla temporal
		DROP TABLE IF EXISTS bdicred:"informix".sd_chi_ope_sdos_com_temp;
		
		RETURN cod_ret;	
    END	
END PROCEDURE;