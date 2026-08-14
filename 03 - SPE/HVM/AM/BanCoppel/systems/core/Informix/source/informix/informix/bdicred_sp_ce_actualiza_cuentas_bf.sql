CREATE PROCEDURE "informix".sp_ce_actualiza_cuentas_bf ()
	RETURNING CHAR(5) as codigo_retorno;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	--Peticion: RQI 28 261 - Banco Famsa - Proceso automatizado actualización de cuentas de captación 
	--Creado por: 98769022 Miguel Alejandro Sánchez Mojica
	--Fecha de creación: 06/05/2021
	--Creación: Se realiza la actualización de las cuentas eje de la cartera de Banco Famsa en la tabla sd_ce_cuentas_bf con base al archivo cuentas_bf_AAAAMMDD.txt; adicional generar el archivo de respuesta Rep_BEM_Cuentas_BF_AAAAMMDD.txt
	--BD: bdicred
	-------------------------------------------------------------------------------------
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES ERROR                        *
-- ****************************************************************************
    DEFINE     	sql_err                 INTEGER;
    DEFINE     	isam_err                INTEGER;
    DEFINE     	cod_ret                 CHAR(6);
	DEFINE	   	mensaje_ret				VARCHAR(255);
	
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

	DEFINE 		v_num_cta_eje 			VARCHAR(20);
	DEFINE 		v_status_disp			VARCHAR(1);
	DEFINE 		v_status_pago 			VARCHAR(1);
	DEFINE 		v_fecha_actual			DATE;
	DEFINE		v_count_info			INTEGER;		-- Variable para validar si hay información cargada en la tabla temporal
	DEFINE		v_count_cuenta			INTEGER;		-- Variable para validar si la cuenta se encuentra en la tabla sd_ce_cuentas_bf
	DEFINE		v_accion				VARCHAR(10);	-- Variable para validar que acción se debe realizar, INSERT o UPDATE
	
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES RUTAS                        *
-- ****************************************************************************
	DEFINE 		cRuta				    CHAR(100);
	DEFINE 		cRutaReporte		    CHAR(100);
	DEFINE 		cSQL                    CHAR(1000);
	DEFINE 		cNomSQL                 CHAR(100);
	DEFINE 		cDia					CHAR(2);
	DEFINE 		cMes					CHAR(2);
	DEFINE 		cYear				    CHAR(4);
	DEFINE 		cArchivo			    CHAR(100);
	DEFINE 		cNombreArchivo		    CHAR(100);
	DEFINE 		cReporte			    CHAR(100);
	DEFINE 		cNombreReporte		    CHAR(100);
	
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
	LET			v_fecha_actual			= TODAY;
	LET			v_accion				= "";
	LET			v_count_info			= 0;

-- ****************************************************************************
-- *                  INICIALIZACION DE VARIABLES RUTAS                       *
-- ****************************************************************************
	LET 		cRuta		 			= "/resplogifx/Credito_BE/022_Cuentas_BF/";
	LET 		cRutaReporte 			= "/RESPALDOSNEW/Credito_BE/022_Cuentas_BF/";
	LET 		cSQL					= "";
	LET 		cNomSQL					= "sd_ce_cuentas_bf_temp.sql";
	LET 		cDia					= LPAD(DAY(v_fecha_actual), 2, '0');
	LET 		cMes					= LPAD(MONTH(v_fecha_actual), 2, '0');
	LET 		cYear					= YEAR(v_fecha_actual);
	LET 		cArchivo				= "cuentas_bf_";
	LET			cNombreArchivo			= TRIM(cArchivo) || cYear || cMes || cDia || '.txt ';
	LET 		cReporte				= "Rep_BEM_Cuentas_BF_";
	LET			cNombreReporte			= TRIM(cReporte) || cYear || cMes || cDia || '.txt ';
	
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

    BEGIN
		
		ON EXCEPTION SET sql_err, isam_err
			IF sql_err != 0 THEN
			
				LET cod_ret = '00000';	
				LET mensaje_ret = 'NO SE PUEDE PROCESAR EL ARCHIVO.';
				LET cSQL =  ' echo "' || TRIM(mensaje_ret) || '">>'|| TRIM(cRutaReporte) || TRIM(cNombreReporte);
				SYSTEM TRIM(cSQL);
				
				-- Imprimir separación de ejecución en archivo de respuesta
				LET cSQL = ' echo " --------------------------------- ">>'||TRIM(cRutaReporte)|| TRIM(cNombreReporte);
				SYSTEM TRIM(cSQL);
				
				RETURN cod_ret;
				
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-668) SET sql_err, isam_err
			IF sql_err != 0 THEN
			
				LET cod_ret = '00000';		
				LET mensaje_ret = 'NO SE PUEDE PROCESAR EL ARCHIVO. VERIFICAR RUTA O ARCHIVO A EJECUTAR';
				LET cSQL =  ' echo "' || TRIM(mensaje_ret) || '">>'|| TRIM(cRutaReporte) || TRIM(cNombreReporte);
				SYSTEM TRIM(cSQL);
				
				-- Imprimir separación de ejecución en archivo de respuesta
				LET cSQL = ' echo " --------------------------------- ">>'||TRIM(cRutaReporte)|| TRIM(cNombreReporte);
				SYSTEM TRIM(cSQL);
				
				RETURN cod_ret;
				
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 10;
		
        --*****************************************************************
        --*						DEBUG DEL PROCEDURE                       *        
        --*****************************************************************
		--SET DEBUG FILE TO '/resplogifx/Credito_BE/022_Cuentas_BF/sp_ce_actualiza_cuentas_bf.out';
		--TRACE ON;                                                     
		
		-- ****************************************************************************
		-- *                        PROGRAMA PRINCIPAL                                *
		-- ****************************************************************************	
		-- ****************************************************************************
		-- *                         CARGA DE ARCHIVO                                 *
		-- ****************************************************************************	
    
		-- Eliminar tabla temporal
		DROP TABLE IF EXISTS bdicred:"informix".sd_ce_cuentas_bf_temp;

		-- Crear tabla temporal
		CREATE TABLE bdicred:"informix".sd_ce_cuentas_bf_temp(                             
			num_cta_eje 				VARCHAR(20),
			status_disposicion			VARCHAR(1),
			status_pago					VARCHAR(1)
		);

		-- Cargar información a tabla temporal
		LET cSQL =  ' echo "SET ISOLATION TO DIRTY READ; LOAD FROM ' || TRIM(cRuta) || TRIM(cNombreArchivo) || 
					' INSERT INTO bdicred:"informix".sd_ce_cuentas_bf_temp;' || "" || '">'||TRIM(cRuta)|| TRIM(cNomSQL);
		SYSTEM TRIM(cSQL);

		LET cSQL='chmod 777 '|| TRIM(cRuta)|| TRIM(cNomSQL);
		SYSTEM cSQL;

		LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || TRIM(cNomSQL);
		SYSTEM cSQL;
		
		LET cSQL = 'rm ' || TRIM(cRuta) || TRIM(cNomSQL);
		SYSTEM cSQL;
		
		-- ****************************************************************************
		-- *                     ACTUALIZACIÓN DE INFORMACIÓN                         *
		-- ****************************************************************************	
		-- ****************************************************************************
		-- *                     GENERACIÓN DE ARCHIVO RESPUESTA                      *
		-- ****************************************************************************
		
		-- Valida si hay información cargada en la tabla temporal
		SELECT 	COUNT(num_cta_eje) 
		INTO	v_count_info
		FROM 	bdicred:"informix".sd_ce_cuentas_bf_temp;
		
		IF (v_count_info > 0) THEN
			
			FOREACH WITH HOLD
				
				-- Seleccionar información de tabla temporal
				SELECT 	num_cta_eje, status_disposicion, status_pago	 
				INTO 	v_num_cta_eje, v_status_disp, v_status_pago
				FROM 	bdicred:"informix".sd_ce_cuentas_bf_temp

				-- Validar si existe la cuenta en la tabla principal
				SELECT 	COUNT(num_cta_eje)
				INTO	v_count_cuenta
				FROM	sd_ce_cuentas_bf
				WHERE 	num_cta_eje = v_num_cta_eje;
				
				-- Si la cuenta no existe en la tabla principal, insertar registro; si existe, actualizar los status de la cuenta 
				IF (v_count_cuenta = 0)	THEN
				
					INSERT INTO bdicred:"informix".sd_ce_cuentas_bf VALUES	(v_num_cta_eje, v_status_disp, v_status_pago);
					LET v_accion = 'INGRESÓ';
				
				ELSE
				
					UPDATE bdicred:"informix".sd_ce_cuentas_bf SET status_disposicion = v_status_disp, status_pago = v_status_pago WHERE num_cta_eje = v_num_cta_eje;
					LET v_accion = 'ACTUALIZÓ';
					
				END IF;
				
				-- Imprimir información en archivo de respuesta
				LET cSQL = ' echo "' || TRIM(v_num_cta_eje) || '|' || TRIM(v_status_disp) || '|' || TRIM(v_status_pago) || '|' || TRIM(v_accion) || '">>'||TRIM(cRutaReporte)|| TRIM(cNombreReporte);
				SYSTEM TRIM(cSQL);

			END FOREACH;
		
		ELSE
		
			-- Imprimir mensaje en archivo de respuesta cuando no haya información a procesar 
			LET mensaje_ret = 'NO HAY INFORMACIÓN A PROCESAR.';
			LET cSQL =  ' echo "' || TRIM(mensaje_ret) || '">>'|| TRIM(cRutaReporte) || TRIM(cNombreReporte);
			SYSTEM TRIM(cSQL);
		
		END IF;
		
		-- Imprimir separación de ejecución en archivo de respuesta
		LET cSQL = ' echo " --------------------------------- ">>'||TRIM(cRutaReporte)|| TRIM(cNombreReporte);
		SYSTEM TRIM(cSQL);
		
		-- Eliminar tabla temporal
		DROP TABLE IF EXISTS bdicred:"informix".sd_ce_cuentas_bf_temp;
		
		RETURN cod_ret;	
    END	
END PROCEDURE;