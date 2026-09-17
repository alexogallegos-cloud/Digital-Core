CREATE PROCEDURE "informix".sp_chi_ope_carga_sdos_diarios (p_fecha_carga DATE)
	RETURNING CHAR(5) as codigo_retorno;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	--Peticion: RQM 10 1404 - Hipotecario Infonavit
	--Creado por: 98769022 Miguel Alejandro Sánchez Mojica
	--Fecha de creación: 13/04/2021
	--Creación: Se realiza la carga de la información del archivo chi_ope_rep_sdos_diarios_aaaammdd.txt
	--BD: bdicred
	-------------------------------------------------------------------------------------
	--Peticion: RQM 10 1404 - Hipotecario Infonavit
	--Modificado por: 98769022 Miguel Alejandro Sánchez Mojica
	--Fecha de modificación: 10/08/2021
	--Modificación: Se modifica las longitudes de la columna status_operativo de varchar(10) a varchar(20)
	--BD: bdicred
	-------------------------------------------------------------------------------------
	--Peticion: RQM 10 1404 - Hipotecario Infonavit
	--Modificado por: 98769022 Miguel Alejandro Sánchez Mojica
	--Fecha de modificación: 07/12/2021
	--Modificación: Se modifica para poder realizar re ejecuciones del proceso de conciliaciones
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
	DEFINE 		v_producto 						VARCHAR(20);
	DEFINE 		v_periodo 						VARCHAR(10);
	DEFINE 		v_credito 						VARCHAR(20);
	DEFINE 		v_status_operativo 				VARCHAR(20);
	DEFINE 		v_fecha_cesion 					DATE;
	DEFINE 		v_fecha_firma 					DATE;
	DEFINE 		v_regimen 						VARCHAR(5);
	DEFINE 		v_status 						VARCHAR(5);
	DEFINE 		v_mora							DECIMAL(18,2);
	DEFINE		v_cap_vig 						DECIMAL(18,2);
	DEFINE 		v_cap_venc_trasp 				DECIMAL(18,2);
	DEFINE 		v_cap_prorroga					DECIMAL(18,2);
	DEFINE 		v_cap_venc_exi					DECIMAL(18,2);
	DEFINE 		v_cap_venc_no_exi				DECIMAL(18,2);
	DEFINE 		v_int_vig 						DECIMAL(18,2);
	DEFINE 		v_int_venc_trasp 				DECIMAL(18,2);
	DEFINE 		v_int_prorroga					DECIMAL(18,2);
	DEFINE 		v_int_venc_exi					DECIMAL(18,2);
	DEFINE 		v_int_venc_no_exi				DECIMAL(18,2);
	DEFINE 		v_int_venc_orden				DECIMAL(18,2);
	DEFINE 		v_sdo_total						DECIMAL(18,2);
	DEFINE 		v_fecha_concilia				DATE;	
	DEFINE 		v_version_concilia				INTEGER;
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
	LET 		v_comienza_commit		= 0;
	LET 		v_suma_registros		= 0;

-- ****************************************************************************
-- *                  INICIALIZACION DE VARIABLES RUTAS                       *
-- ****************************************************************************
	LET 		cRuta		 			= "/resplogifx/hipotecario_infonavit/operaciones/";
	LET 		cSQL					= "";
	LET 		cNomSQL					= "sd_chi_ope_sdos_diarios_temp.sql";
	LET 		cArchivo				= "chi_ope_rep_sdos_diarios_";
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
		--SET DEBUG FILE TO '/resplogifx/hipotecario_infonavit/operaciones/sp_chi_ope_carga_sdos_diarios.out';
		--TRACE ON;                                                      
		
		-- ****************************************************************************
		-- *                        PROGRAMA PRINCIPAL                                *
		-- ****************************************************************************	
		-- ****************************************************************************
		-- *                       IMPORTACION DE ARCHIVO                             *
		-- ****************************************************************************	

		-- Insertar registros de la tabla de carga a la tabla histórica
		INSERT INTO sd_chi_ope_sdos_diarios_hist SELECT * FROM sd_chi_ope_sdos_diarios;
		
		-- Limpiar la tabla de carga 
		TRUNCATE TABLE bdicred:"informix".sd_chi_ope_sdos_diarios;
			
		-- Asignar variables para el nombre del archivo
		LET cDia	= LPAD(DAY(p_fecha_carga), 2, '0');
		LET cMes	= LPAD(MONTH(p_fecha_carga), 2, '0');
		LET cYear	= YEAR(p_fecha_carga);
		
		-- Limpiar tabla temporal
		DROP TABLE IF EXISTS bdicred:"informix".sd_chi_ope_sdos_diarios_temp;

		-- Crear tabla temporal
		CREATE TABLE bdicred:"informix".sd_chi_ope_sdos_diarios_temp(
			producto 					varchar(20),
			periodo 					varchar(10),
			credito 					varchar(20),
			status_operativo 			varchar(20),
			fecha_cesion 				date,
			fecha_firma 				date,
			regimen 					varchar(5),
			status 						varchar(5),
			mora						decimal(18,2),
			cap_vig 					decimal(18,2),
			cap_venc_trasp 				decimal(18,2),
			cap_prorroga				decimal(18,2),
			cap_venc_exi				decimal(18,2),
			cap_venc_no_exi				decimal(18,2),
			int_vig 					decimal(18,2),
			int_venc_trasp 				decimal(18,2),
			int_prorroga				decimal(18,2),
			int_venc_exi				decimal(18,2),
			int_venc_no_exi				decimal(18,2),
			int_venc_orden				decimal(18,2),
			sdo_total					decimal(18,2),
			fecha_concilia				date
		);
		
		-- Definir nombre del archivo y cargar información a tabla temporal
		LET cNombreArchivo = TRIM(cArchivo) || cYear || cMes || cDia || '.txt ';
		LET cSQL =  ' echo "SET ISOLATION TO DIRTY READ; LOAD FROM ' || TRIM(cRuta) || TRIM(cNombreArchivo) || 
					' INSERT INTO bdicred:"informix".sd_chi_ope_sdos_diarios_temp;' || "" || '">'||TRIM(cRuta)|| TRIM(cNomSQL);
		SYSTEM TRIM(cSQL);

		LET cSQL='chmod 777 '|| TRIM(cRuta)|| TRIM(cNomSQL);
		SYSTEM cSQL;

		LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || TRIM(cNomSQL);
		SYSTEM cSQL;
		
		LET cSQL = 'rm ' || TRIM(cRuta) || TRIM(cNomSQL);
		SYSTEM cSQL;

		FOREACH WITH HOLD
			
			-- Seleccionar información de tabla temporal
			SELECT 	producto, periodo, credito, status_operativo, fecha_cesion, 
					fecha_firma, regimen, status, mora, cap_vig, 
					cap_venc_trasp, cap_prorroga, cap_venc_exi, cap_venc_no_exi, int_vig, 
					int_venc_trasp, int_prorroga, int_venc_exi, int_venc_no_exi, int_venc_orden, 
					sdo_total, fecha_concilia
			INTO 	v_producto, v_periodo, v_credito, v_status_operativo, v_fecha_cesion, 
					v_fecha_firma, v_regimen, v_status, v_mora, v_cap_vig, 
					v_cap_venc_trasp, v_cap_prorroga, v_cap_venc_exi, v_cap_venc_no_exi, v_int_vig, 
					v_int_venc_trasp, v_int_prorroga, v_int_venc_exi, v_int_venc_no_exi, v_int_venc_orden, 
					v_sdo_total, v_fecha_concilia
			FROM 	bdicred:"informix".sd_chi_ope_sdos_diarios_temp

				-- ABRE COMMIT'S PARCIALES
			IF (v_comienza_commit = 0) THEN
			
				LET v_comienza_commit = 1;
				
				-- Buscar la última versión de la conciliación
				SELECT	MAX(version_concilia) + 1
				INTO	v_version_concilia
				FROM 	bdicred:"informix".sd_chi_ope_sdos_diarios_hist
				WHERE 	fecha_concilia = v_fecha_concilia;
							
				BEGIN WORK;
				
			END IF;
			
			-- Insertar en la tabla principal
			INSERT INTO bdicred:"informix".sd_chi_ope_sdos_diarios VALUES	(v_empresa, p_fecha_carga, nvl(v_producto,''), nvl(v_periodo,''), nvl(v_credito,''),
																			 nvl(v_status_operativo,''), nvl(v_fecha_cesion,''), nvl(v_fecha_firma,''), nvl(v_regimen,''), nvl(v_status,''),
																			 nvl(v_mora,0), nvl(v_cap_vig,0), nvl(v_cap_venc_trasp,0), nvl(v_cap_prorroga,0), nvl(v_cap_venc_exi,0),
																			 nvl(v_cap_venc_no_exi,0), nvl(v_int_vig,0), nvl(v_int_venc_trasp,0), nvl(v_int_prorroga,0), nvl(v_int_venc_exi,0),
																			 nvl(v_int_venc_no_exi,0), nvl(v_int_venc_orden,0), nvl(v_sdo_total,0), v_fecha_concilia, nvl(v_version_concilia,1));
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
		
		-- Ejecuta Stored Procedure para la conciliación de movimientos
		CALL bdicred:sp_chi_ope_concilia_mvtos(p_fecha_carga, v_fecha_concilia) RETURNING cod_ret;
		
		-- Limpiar tabla temporal
		DROP TABLE IF EXISTS bdicred:"informix".sd_chi_ope_sdos_diarios_temp;
		
		RETURN cod_ret;	
    END	
END PROCEDURE;