CREATE PROCEDURE "informix".sp_chi_ope_rep_concilia_com ( p_concilia_info INTEGER, p_fecha_rep DATE,  p_count_creditos INTEGER)
	RETURNING CHAR(5) as codigo_retorno;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	--Peticion: RQM 10 1404 - Hipotecario Infonavit
	--Creado por: 98769022 Miguel Alejandro Sánchez Mojica
	--Fecha de creación: 22/04/2021
	--Creación: Se realiza la generación del reporte de conciliaciones chi_ope_rep_concilia_com_aaaammdd.xls
	--BD: bdicred
	-------------------------------------------------------------------------------------
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES ERROR                        *
-- ****************************************************************************
    DEFINE     	sql_err                 INTEGER;
    DEFINE     	isam_err                INTEGER;
    DEFINE     	cod_ret                 CHAR(5);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	DEFINE		v_empresa						CHAR(3);
	DEFINE		v_count_creditos				INTEGER;
	DEFINE 		v_nombre_sdo					VARCHAR(50);
	DEFINE		v_cta							CHAR(4);      
	DEFINE		v_subcta                        CHAR(2);      
	DEFINE		v_subsubcta                     CHAR(2);      
	DEFINE		v_ssubsubcta                    CHAR(2);      
	DEFINE		v_sssubsubcta                   CHAR(2);      
	DEFINE		v_sector                        CHAR(2);      
	DEFINE 		v_total_reporte					DECIMAL(18,2);
	DEFINE 		v_total_balanza					DECIMAL(18,2);
	DEFINE 		v_total_diferencia				DECIMAL(18,2);
	DEFINE 		v_cta_contable					VARCHAR(20);
	DEFINE		v_fecha_reporte					DATE;
	
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES RUTAS                        *
-- ****************************************************************************
	DEFINE 		cRuta				    CHAR(100);
	DEFINE 		cSQL                    CHAR(1000);
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

-- ****************************************************************************
-- *                    INICIALIZACION DE VARIABLES                           *
-- ****************************************************************************
	LET 		v_empresa				= '001';
	LET 		v_count_creditos		= p_count_creditos;
	LET 		v_cta_contable			= "";
	LET 		v_fecha_reporte			= p_fecha_rep;
	
-- ****************************************************************************
-- *                  INICIALIZACION DE VARIABLES RUTAS                       *
-- ****************************************************************************
	LET 		cRuta		 			= "/RESPALDOSNEW/hipotecario_infonavit/operaciones/";
	LET 		cSQL					= "";
	LET 		cYear					= YEAR(v_fecha_reporte);
	LET 		cMesActual				= MONTH(v_fecha_reporte);
	LET			cNombreArchivo			= "";
	
    BEGIN
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        --*****************************************************************
        --*						Debug del Procedure                     --*        
        --*****************************************************************
		--SET DEBUG FILE TO '/RESPALDOSNEW/hipotecario_infonavit/operaciones/sp_chi_ope_rep_concilia_com.out';
		--TRACE ON;                                                     
		
		-- ****************************************************************************
		-- *                        PROGRAMA PRINCIPAL                                *
		-- ****************************************************************************	
		-- ****************************************************************************
		-- *                      GENERACIÓN DE REPORTE                               *
		-- ****************************************************************************	
		
		SELECT	nombre_rep
		INTO	cArchivo
		FROM	bdicred:"informix".sd_chi_ope_productos
		WHERE 	empresa = v_empresa AND nombre_prod = 'N/A' AND status = 1;
		
		-- Calcular mes y año anterior para crear el reporte
		-- SI el mes actual es 01 (ENERO) asignar en automático el mes 12 y restar un año al año actual, si NO, restar un mes al mes actual
		IF (cMesActual = 1) THEN
			
			LET cMes = '12';
			LET cYear = YEAR(v_fecha_reporte) - 1;
			
		ELSE
		
			LET cMes = LPAD(MONTH(v_fecha_reporte)-1, 2, '0');
			
		END IF;
		
		-- Definir nombre del archivo
		LET cNombreArchivo = TRIM(cArchivo) || cYear || cMes || '.xls ';
		
		-- Si hay información conciliada crear el reporte con la información, si NO, crear el reporte con la leyenda NO HAY INFORMACIÓN PARA MOSTRAR
		IF (p_concilia_info = 1) THEN
		
			-- Imprimir primer encabezado dentro del reporte (TOTAL DE CREDITOS BASE)
			LET cSQL = ' echo "TOTAL DE CREDITOS BASE:' || '	' || v_count_creditos ||
				"" || '">'||TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM TRIM(cSQL);
	
			LET cSQL='chmod 777 '|| TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM cSQL;
			
			-- Imprimir encabezados dentro del reporte (5 columnas)
			LET cSQL = ' echo "TIPO DE COMISION	CUENTA CONTABLE	TOTAL REPORTE	TOTAL BALANZA	DIFERENCIA' ||
				"" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM TRIM(cSQL);
			
			FOREACH WITH HOLD
						
				-- Seleccionar información de tabla de conciliaciones
				SELECT      TRIM(c.nombre_sdo), d.cta, d.subcta, d.subsubcta, d.ssubsubcta, 
							d.sssubsubcta, d.sector, a.total_reporte, a.total_balanza, a.diferencia
				INTO 		v_nombre_sdo, v_cta, v_subcta, v_subsubcta, v_ssubsubcta, 
							v_sssubsubcta, v_sector, v_total_reporte,v_total_balanza, v_total_diferencia
				FROM    	bdicred:"informix".sd_chi_ope_concilia_com a
				INNER JOIN  bdicred:"informix".sd_chi_ope_rel_prod_tiposdos_ctascontables b ON a.empresa = b.empresa AND a.id_rel = b.id_rel AND b.status = 1
				INNER JOIN  bdicred:"informix".sd_chi_ope_tiposdos c ON b.empresa = c.empresa AND b.id_sdo = c.id_sdo AND c.status = 1
				INNER JOIN  bdicred:"informix".sd_chi_ope_ctascontables d ON b.empresa = d.empresa AND b.id_cta_cont = d.id_cta_cont AND d.status = 1
				WHERE   	a.empresa = v_empresa AND a.fecha_proceso = v_fecha_reporte
				
				-- Unir la cadena completa de la cuenta contable
				LET v_cta_contable = v_cta || '-' || v_subcta || '-' || v_subsubcta || '-' || v_ssubsubcta || '-' || v_sssubsubcta || '-' || v_sector;
				
				-- Imprimir información dentro del reporte (5 columnas)
				LET cSQL = ' echo "'  || v_nombre_sdo || '	' || v_cta_contable || '	' || v_total_reporte || '	' || v_total_balanza || '	' || v_total_diferencia ||
							"" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo);
				LET cSQL = cSQL;
				SYSTEM TRIM(cSQL);
				
			END FOREACH;
			
		ELSE
		
			-- Imprimir texto
			LET cSQL = ' echo "' || 'NO HAY INFORMACIÓN PARA MOSTRAR' || "" || '">'||TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM TRIM(cSQL);
		
		END IF;
		
		RETURN cod_ret;	
    END	
END PROCEDURE;