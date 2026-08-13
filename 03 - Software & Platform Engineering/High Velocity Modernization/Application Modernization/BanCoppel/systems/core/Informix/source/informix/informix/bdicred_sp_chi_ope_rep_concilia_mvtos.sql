CREATE PROCEDURE "informix".sp_chi_ope_rep_concilia_mvtos ( p_fecha_rep DATE, p_fecha_concilia DATE,  p_version_concilia INTEGER)
	RETURNING CHAR(5) as codigo_retorno;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	--Peticion: RQM 10 1404 - Hipotecario Infonavit
	--Creado por: 98769022 Miguel Alejandro Sánchez Mojica
	--Fecha de creación: 19/04/2021
	--Creación: Se realiza la generación de los reportes de conciliaciones chi_ope_rep_concilia_mvtos_mvit_aaaammdd.xls y chi_ope_rep_concilia_mvtos_scre_aaaammdd.xls
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
    DEFINE     	cod_ret                 CHAR(6);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

	DEFINE 		v_empresa 						VARCHAR(3);
	DEFINE 		v_nombre_prod 					VARCHAR(20);
	DEFINE 		v_fecha_proceso 				DATE;
	DEFINE 		v_producto 						VARCHAR(20);
	DEFINE 		v_periodo 						VARCHAR(10);
	DEFINE 		v_credito 						VARCHAR(20);
	DEFINE 		v_status_operativo 				VARCHAR(20);
	DEFINE 		v_fecha_cesion 					DATE;
	DEFINE 		v_fecha_firma 					DATE;
	DEFINE 		v_regimen 						VARCHAR(5);
	DEFINE 		v_status 						VARCHAR(5);
	DEFINE 		v_mora							DECIMAL(18,2);
	DEFINE 		v_cap_vig 						DECIMAL(18,2);
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
	DEFINE 		v_cap_vig_tm1 					DECIMAL(18,2);
	DEFINE 		v_cap_venc_trasp_tm1 			DECIMAL(18,2);
	DEFINE 		v_cap_prorroga_tm1				DECIMAL(18,2);
	DEFINE 		v_cap_venc_exi_tm1				DECIMAL(18,2);
	DEFINE 		v_cap_venc_no_exi_tm1			DECIMAL(18,2);
	DEFINE 		v_int_vig_tm1 					DECIMAL(18,2);
	DEFINE 		v_int_venc_trasp_tm1 			DECIMAL(18,2);
	DEFINE 		v_int_prorroga_tm1				DECIMAL(18,2);
	DEFINE 		v_int_venc_exi_tm1				DECIMAL(18,2);
	DEFINE 		v_int_venc_no_exi_tm1			DECIMAL(18,2);
	DEFINE 		v_int_venc_orden_tm1			DECIMAL(18,2);
	DEFINE 		v_sdo_total_tm1					DECIMAL(18,2);
	DEFINE 		v_mov_cap_vig 					DECIMAL(18,2);
	DEFINE		v_mov_cap_venc_trasp			DECIMAL(18,2);
	DEFINE 		v_mov_cap_prorroga				DECIMAL(18,2);
	DEFINE 		v_mov_cap_venc_exi				DECIMAL(18,2);
	DEFINE 		v_mov_cap_venc_no_exi			DECIMAL(18,2);
	DEFINE 		v_mov_int_vig 					DECIMAL(18,2);
	DEFINE		v_mov_int_venc_trasp			DECIMAL(18,2);
	DEFINE 		v_mov_int_prorroga				DECIMAL(18,2);
	DEFINE 		v_mov_int_venc_exi				DECIMAL(18,2);
	DEFINE 		v_mov_int_venc_no_exi			DECIMAL(18,2);
	DEFINE 		v_mov_int_venc_orden			DECIMAL(18,2);
	DEFINE 		v_mov_total						DECIMAL(18,2);
	DEFINE 		v_sum_mov_cap_vig 				DECIMAL(18,2);	-- MOVIMIENTOS CALCULADOS
	DEFINE 		v_sum_mov_cap_venc_trasp		DECIMAL(18,2);	-- MOVIMIENTOS CALCULADOS
	DEFINE 		v_sum_mov_cap_prorroga			DECIMAL(18,2);	-- MOVIMIENTOS CALCULADOS
	DEFINE 		v_sum_mov_cap_venc_exi			DECIMAL(18,2);	-- MOVIMIENTOS CALCULADOS
	DEFINE 		v_sum_mov_cap_venc_no_exi		DECIMAL(18,2);	-- MOVIMIENTOS CALCULADOS
	DEFINE 		v_sum_mov_int_vig 				DECIMAL(18,2);	-- MOVIMIENTOS CALCULADOS
	DEFINE 		v_sum_mov_int_venc_trasp		DECIMAL(18,2);	-- MOVIMIENTOS CALCULADOS
	DEFINE 		v_sum_mov_int_prorroga			DECIMAL(18,2);	-- MOVIMIENTOS CALCULADOS
	DEFINE 		v_sum_mov_int_venc_exi			DECIMAL(18,2);	-- MOVIMIENTOS CALCULADOS
	DEFINE 		v_sum_mov_int_venc_no_exi		DECIMAL(18,2);	-- MOVIMIENTOS CALCULADOS
	DEFINE 		v_sum_mov_int_venc_orden		DECIMAL(18,2);	-- MOVIMIENTOS CALCULADOS
	DEFINE 		v_sum_mov_total					DECIMAL(18,2);	-- MOVIMIENTOS CALCULADOS
	DEFINE		v_nombre_sdo					VARCHAR(50);	-- POLIZA BANCOPPEL
	DEFINE		v_cta							CHAR(4);        -- POLIZA BANCOPPEL
	DEFINE		v_subcta                        CHAR(2);        -- POLIZA BANCOPPEL
	DEFINE		v_subsubcta                     CHAR(2);        -- POLIZA BANCOPPEL
	DEFINE		v_ssubsubcta                    CHAR(2);        -- POLIZA BANCOPPEL
	DEFINE		v_sssubsubcta                   CHAR(2);        -- POLIZA BANCOPPEL
	DEFINE		v_sector                        CHAR(2);        -- POLIZA BANCOPPEL
	DEFINE 		v_importe_c						DECIMAL(18,2);  -- POLIZA BANCOPPEL
	DEFINE 		v_importe_a						DECIMAL(18,2);  -- POLIZA BANCOPPEL
	DEFINE 		v_importe_total					DECIMAL(18,2);  -- POLIZA BANCOPPEL
	DEFINE 		v_pbc_mov_cap_vig 				DECIMAL(18,2);	-- POLIZA BANCOPPEL
	DEFINE 		v_pbc_mov_cap_venc_trasp		DECIMAL(18,2);	-- POLIZA BANCOPPEL
	DEFINE 		v_pbc_mov_cap_prorroga			DECIMAL(18,2);	-- POLIZA BANCOPPEL
	DEFINE 		v_pbc_mov_cap_venc_exi			DECIMAL(18,2);	-- POLIZA BANCOPPEL
	DEFINE 		v_pbc_mov_cap_venc_no_exi		DECIMAL(18,2);	-- POLIZA BANCOPPEL
	DEFINE 		v_pbc_mov_int_vig 				DECIMAL(18,2);	-- POLIZA BANCOPPEL
	DEFINE 		v_pbc_mov_int_venc_trasp		DECIMAL(18,2);	-- POLIZA BANCOPPEL
	DEFINE 		v_pbc_mov_int_prorroga			DECIMAL(18,2);	-- POLIZA BANCOPPEL
	DEFINE 		v_pbc_mov_int_venc_exi			DECIMAL(18,2);	-- POLIZA BANCOPPEL
	DEFINE 		v_pbc_mov_int_venc_no_exi		DECIMAL(18,2);	-- POLIZA BANCOPPEL
	DEFINE 		v_pbc_mov_int_venc_orden		DECIMAL(18,2);	-- POLIZA BANCOPPEL
	DEFINE 		v_pbc_mov_total					DECIMAL(18,2);	-- POLIZA BANCOPPEL
	DEFINE 		v_dif_mov_cap_vig 				DECIMAL(18,2);	-- DIFERENCIA
	DEFINE 		v_dif_mov_cap_venc_trasp		DECIMAL(18,2);  -- DIFERENCIA
	DEFINE 		v_dif_mov_cap_prorroga			DECIMAL(18,2);  -- DIFERENCIA
	DEFINE 		v_dif_mov_cap_venc_exi			DECIMAL(18,2);  -- DIFERENCIA
	DEFINE 		v_dif_mov_cap_venc_no_exi		DECIMAL(18,2);  -- DIFERENCIA
	DEFINE 		v_dif_mov_int_vig 				DECIMAL(18,2);  -- DIFERENCIA
	DEFINE 		v_dif_mov_int_venc_trasp		DECIMAL(18,2);  -- DIFERENCIA
	DEFINE 		v_dif_mov_int_prorroga			DECIMAL(18,2);  -- DIFERENCIA
	DEFINE 		v_dif_mov_int_venc_exi			DECIMAL(18,2);  -- DIFERENCIA
	DEFINE 		v_dif_mov_int_venc_no_exi		DECIMAL(18,2);  -- DIFERENCIA
	DEFINE 		v_dif_mov_int_venc_orden		DECIMAL(18,2);  -- DIFERENCIA
	DEFINE 		v_dif_mov_total					DECIMAL(18,2);  -- DIFERENCIA
	DEFINE		v_cta_contable					VARCHAR(20);	-- CUENTAS CONTABLES
	DEFINE 		v_ctacont_mov_cap_vig 			VARCHAR(20);	-- CUENTAS CONTABLES
	DEFINE 		v_ctacont_mov_cap_venc_trasp	VARCHAR(20);  	-- CUENTAS CONTABLES
	DEFINE 		v_ctacont_mov_cap_prorroga		VARCHAR(20);  	-- CUENTAS CONTABLES
	DEFINE 		v_ctacont_mov_cap_venc_exi		VARCHAR(20);  	-- CUENTAS CONTABLES
	DEFINE 		v_ctacont_mov_cap_venc_no_exi	VARCHAR(20);  	-- CUENTAS CONTABLES
	DEFINE 		v_ctacont_mov_int_vig 			VARCHAR(20);  	-- CUENTAS CONTABLES
	DEFINE 		v_ctacont_mov_int_venc_trasp	VARCHAR(20);  	-- CUENTAS CONTABLES
	DEFINE 		v_ctacont_mov_int_prorroga		VARCHAR(20);  	-- CUENTAS CONTABLES
	DEFINE 		v_ctacont_mov_int_venc_exi		VARCHAR(20);  	-- CUENTAS CONTABLES
	DEFINE 		v_ctacont_mov_int_venc_no_exi	VARCHAR(20);  	-- CUENTAS CONTABLES
	DEFINE 		v_ctacont_mov_int_venc_orden	VARCHAR(20);  	-- CUENTAS CONTABLES
	DEFINE 		v_ind_procesada					INTEGER;
	
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES RUTAS                        *
-- ****************************************************************************
	DEFINE 		cRuta				    CHAR(100);
	DEFINE 		cSQL                    CHAR(2000);
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

-- ****************************************************************************
-- *                    INICIALIZACION DE VARIABLES                           *
-- ****************************************************************************
	LET 		v_empresa	   	      			= '001';
	LET 		v_importe_total					= 0;
	LET 		v_pbc_mov_cap_vig 				= 0;
	LET 		v_pbc_mov_cap_venc_trasp	    = 0;
	LET 		v_pbc_mov_cap_prorroga		    = 0;
	LET 		v_pbc_mov_cap_venc_exi		    = 0;
	LET 		v_pbc_mov_cap_venc_no_exi	    = 0;
	LET 		v_pbc_mov_int_vig 			    = 0;
	LET 		v_pbc_mov_int_venc_trasp	  	= 0;
	LET 		v_pbc_mov_int_prorroga		    = 0;
	LET 		v_pbc_mov_int_venc_exi		    = 0;
	LET 		v_pbc_mov_int_venc_no_exi	    = 0;
	LET 		v_pbc_mov_int_venc_orden	  	= 0;
	LET 		v_pbc_mov_total				    = 0;
	LET 		v_dif_mov_cap_vig 				= 0;
	LET 		v_dif_mov_cap_venc_trasp		= 0;
	LET 		v_dif_mov_cap_prorroga			= 0;
	LET 		v_dif_mov_cap_venc_exi			= 0;
	LET 		v_dif_mov_cap_venc_no_exi		= 0;
	LET 		v_dif_mov_int_vig 				= 0;
	LET 		v_dif_mov_int_venc_trasp		= 0;
	LET 		v_dif_mov_int_prorroga			= 0;
	LET         v_dif_mov_int_venc_exi			= 0;
	LET         v_dif_mov_int_venc_no_exi	    = 0;
	LET         v_dif_mov_int_venc_orden	    = 0;
	LET         v_dif_mov_total				    = 0;
	LET			v_cta_contable					= "";
	LET			v_ctacont_mov_cap_vig 			= "";
	LET			v_ctacont_mov_cap_venc_trasp	= "";
	LET			v_ctacont_mov_cap_prorroga		= "";
	LET			v_ctacont_mov_cap_venc_exi		= "";
	LET			v_ctacont_mov_cap_venc_no_exi	= "";
	LET			v_ctacont_mov_int_vig 			= "";
	LET			v_ctacont_mov_int_venc_trasp	= "";
	LET         v_ctacont_mov_int_prorroga		= "";
	LET         v_ctacont_mov_int_venc_exi		= "";
	LET         v_ctacont_mov_int_venc_no_exi	= "";
	LET         v_ctacont_mov_int_venc_orden	= "";
	
-- ****************************************************************************
-- *                  INICIALIZACION DE VARIABLES RUTAS                       *
-- ****************************************************************************
	LET 		cRuta		 			= "/RESPALDOSNEW/hipotecario_infonavit/operaciones/";
	LET 		cSQL					= "";
	LET 		cDia					= LPAD(DAY(p_fecha_rep), 2, '0');
	LET 		cMes					= LPAD(MONTH(p_fecha_rep), 2, '0');
	LET 		cYear					= YEAR(p_fecha_rep);
	LET			cNombreArchivo			= "";
	
    BEGIN
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        --*****************************************************************
        --*						Debug del Procedure                     --*        
        --*****************************************************************
		--SET DEBUG FILE TO '/RESPALDOSNEW/hipotecario_infonavit/operaciones/sp_chi_ope_rep_concilia_mvtos.out';
		--TRACE ON;                                                        
		
		-- ****************************************************************************
		-- *                        PROGRAMA PRINCIPAL                                *
		-- ****************************************************************************	
		-- ****************************************************************************
		-- *                      GENERACIÓN DE REPORTE                               *
		-- ****************************************************************************	
		
		FOREACH WITH HOLD
			
			-- Seleccionar los nombres de los productos y los nombres de los reportes a generar
			SELECT	nombre_prod, nombre_rep
			INTO	v_nombre_prod, cArchivo
			FROM	bdicred:"informix".sd_chi_ope_productos
			WHERE 	empresa = v_empresa AND nombre_prod <> 'N/A' AND status = 1
			
			-- Definir nombre del archivo
			LET cNombreArchivo = TRIM(cArchivo) || cYear || cMes || cDia || '.xls ';
			
			-- Imprimir encabezados dentro del reporte (45 columnas)
			LET cSQL = ' echo "PRODUCTO	PERIODO	CREDITO	ESTATUS OPERATIVO	FECHA DE CESION	FECHA DE FIRMA	REGIMEN	ESTATUS	MORA	CAPITAL VIGENTE (T-1)	CAPITAL VENCIDO POR TRASPASAR (T-1)	CAPITAL EN PRORROGA (T-1)	CAPITAL VENCIDO EXIGIBLE (T-1)	CAPITAL VENCIDO NO EXIGIBLE (T-1)	INTERES VIGENTE (T-1)	INTERES VENCIDO POR TRASPASAR (T-1)	INTERES EN PRORROGA (T-1)	INTERES VENCIDO EXIGIBLE (T-1)	INTERES VENCIDO NO EXIGIBLE (T-1)	INTERES VENCIDO DE ORDEN (T-1)	SALDO TOTAL (T-1)	CAPITAL VIGENTE	CAPITAL VENCIDO POR TRASPASAR	CAPITAL EN PRORROGA	CAPITAL VENCIDO EXIGIBLE	CAPITAL VENCIDO NO EXIGIBLE	INTERES VIGENTE	INTERES VENCIDO POR TRASPASAR	INTERES EN PRORROGA	INTERES VENCIDO EXIGIBLE	INTERES VENCIDO NO EXIGIBLE	INTERES VENCIDO DE ORDEN	SALDO TOTAL	MOV CAPITAL VIGENTE	MOV CAPITAL VENCIDO POR TRASPASAR	MOV CAPITAL PRORROGA	MOV CAPITAL VENCIDO EXIGIBLE	MOV CAPITAL VENCIDO NO EXIGIBLE	MOV INTERES VIGENTE	MOV INTERES VENCIDO POR TRASPASAR	MOV INTERES PRORROGA	MOV INTERES VENCIDO EXIGIBLE	MOV INTERES VENCIDO NO EXIGIBLE	MOV INTERES VDO DE ORDEN	MOV TOTAL' ||
				"" || '">'||TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM TRIM(cSQL);
		
			LET cSQL='chmod 777 '|| TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM cSQL;
			
			LET v_sum_mov_cap_vig 				= 0;
			LET v_sum_mov_cap_venc_trasp		= 0;
			LET v_sum_mov_cap_prorroga			= 0;
			LET v_sum_mov_cap_venc_exi			= 0;
			LET v_sum_mov_cap_venc_no_exi		= 0;
			LET v_sum_mov_int_vig 				= 0;
			LET v_sum_mov_int_venc_trasp		= 0;
			LET v_sum_mov_int_prorroga			= 0;
			LET v_sum_mov_int_venc_exi			= 0;
			LET v_sum_mov_int_venc_no_exi		= 0;
			LET v_sum_mov_int_venc_orden		= 0;
			LET v_sum_mov_total					= 0;
			LET	v_pbc_mov_total					= 0;
			
			FOREACH WITH HOLD
					
				-- Seleccionar información de tabla de conciliaciones
				SELECT 	producto, periodo, credito, status_operativo, fecha_cesion,
						fecha_firma, regimen, status, mora, cap_vig,
						cap_venc_trasp, cap_prorroga, cap_venc_exi, cap_venc_no_exi, int_vig,
						int_venc_trasp, int_prorroga, int_venc_exi, int_venc_no_exi, int_venc_orden,
						sdo_total, cap_vig_tm1, cap_venc_trasp_tm1, cap_prorroga_tm1, cap_venc_exi_tm1, 
						cap_venc_no_exi_tm1, int_vig_tm1, int_venc_trasp_tm1, int_prorroga_tm1, int_venc_exi_tm1,
						int_venc_no_exi_tm1, int_venc_orden_tm1, sdo_total_tm1, mov_cap_vig, mov_cap_venc_trasp, 
						mov_cap_prorroga, mov_cap_venc_exi, mov_cap_venc_no_exi, mov_int_vig, mov_int_venc_trasp, 
						mov_int_prorroga, mov_int_venc_exi, mov_int_venc_no_exi, mov_int_venc_orden, mov_total
				INTO 	v_producto, v_periodo, v_credito, v_status_operativo, v_fecha_cesion,
						v_fecha_firma, v_regimen, v_status, v_mora, v_cap_vig,
						v_cap_venc_trasp, v_cap_prorroga, v_cap_venc_exi, v_cap_venc_no_exi, v_int_vig,
						v_int_venc_trasp, v_int_prorroga, v_int_venc_exi, v_int_venc_no_exi, v_int_venc_orden,
						v_sdo_total, v_cap_vig_tm1, v_cap_venc_trasp_tm1, v_cap_prorroga_tm1, v_cap_venc_exi_tm1, 
						v_cap_venc_no_exi_tm1, v_int_vig_tm1, v_int_venc_trasp_tm1, v_int_prorroga_tm1, v_int_venc_exi_tm1,
						v_int_venc_no_exi_tm1, v_int_venc_orden_tm1, v_sdo_total_tm1, v_mov_cap_vig, v_mov_cap_venc_trasp, 
						v_mov_cap_prorroga, v_mov_cap_venc_exi, v_mov_cap_venc_no_exi, v_mov_int_vig, v_mov_int_venc_trasp, 
						v_mov_int_prorroga, v_mov_int_venc_exi, v_mov_int_venc_no_exi, v_mov_int_venc_orden, v_mov_total
				FROM 	bdicred:"informix".sd_chi_ope_concilia_mvtos
				WHERE	empresa = v_empresa AND producto = v_nombre_prod AND fecha_concilia = p_fecha_concilia AND version_concilia = p_version_concilia
				
				-- Sumar montos para el renglón de MOVIMIENTOS CALCULADOS del reporte
				LET v_sum_mov_cap_vig 			= v_sum_mov_cap_vig 		+ v_mov_cap_vig; 			
				LET v_sum_mov_cap_venc_trasp	= v_sum_mov_cap_venc_trasp	+ v_mov_cap_venc_trasp;
				LET v_sum_mov_cap_prorroga		= v_sum_mov_cap_prorroga	+ v_mov_cap_prorroga;	
				LET v_sum_mov_cap_venc_exi		= v_sum_mov_cap_venc_exi	+ v_mov_cap_venc_exi;
				LET v_sum_mov_cap_venc_no_exi	= v_sum_mov_cap_venc_no_exi	+ v_mov_cap_venc_no_exi;
				LET v_sum_mov_int_vig 			= v_sum_mov_int_vig 		+ v_mov_int_vig;
				LET v_sum_mov_int_venc_trasp	= v_sum_mov_int_venc_trasp	+ v_mov_int_venc_trasp;
				LET v_sum_mov_int_prorroga		= v_sum_mov_int_prorroga	+ v_mov_int_prorroga;
				LET v_sum_mov_int_venc_exi		= v_sum_mov_int_venc_exi	+ v_mov_int_venc_exi;
				LET v_sum_mov_int_venc_no_exi	= v_sum_mov_int_venc_no_exi	+ v_mov_int_venc_no_exi;
				LET	v_sum_mov_int_venc_orden	= v_sum_mov_int_venc_orden	+ v_mov_int_venc_orden;
				LET v_sum_mov_total				= v_sum_mov_total			+ v_mov_total;

				-- Imprimir información dentro del reporte (45 columnas)
				LET cSQL = ' echo "'  || v_producto || '	' || v_periodo || '	' || v_credito || '	' || v_status_operativo || '	' || TO_CHAR(v_fecha_cesion, "%d/%m/%y" )
							|| '	' || TO_CHAR(v_fecha_firma, "%d/%m/%y" ) || '	' || v_regimen || '	' || v_status || '	' || v_mora || '	' || v_cap_vig_tm1
							|| '	' || v_cap_venc_trasp_tm1 || '	' || v_cap_prorroga_tm1 || '	' || v_cap_venc_exi_tm1 || '	' || v_cap_venc_no_exi_tm1 || '	' || v_int_vig_tm1 
							|| '	' || v_int_venc_trasp_tm1 || '	' || v_int_prorroga_tm1 || '	' || v_int_venc_exi_tm1 || '	' || v_int_venc_no_exi_tm1 || '	' || v_int_venc_orden_tm1 
							|| '	' || v_sdo_total_tm1 || '	' || v_cap_vig || '	' || v_cap_venc_trasp || '	' || v_cap_prorroga || '	' || v_cap_venc_exi 
							|| '	' || v_cap_venc_no_exi || '	' || v_int_vig|| '	' || v_int_venc_trasp || '	' || v_int_prorroga || '	' || v_int_venc_exi 
							|| '	' || v_int_venc_no_exi || '	' || v_int_venc_orden || '	' || v_sdo_total || '	' || v_mov_cap_vig || '	' || v_mov_cap_venc_trasp 
							|| '	' || v_mov_cap_prorroga || '	' || v_mov_cap_venc_exi || '	' || v_mov_cap_venc_no_exi || '	' || v_mov_int_vig || '	' || v_mov_int_venc_trasp 
							|| '	' || v_mov_int_prorroga || '	' || v_mov_int_venc_exi || '	' || v_mov_int_venc_no_exi || '	' || v_mov_int_venc_orden || '	' || v_mov_total
							||	"" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo);
				LET cSQL = cSQL;
				SYSTEM TRIM(cSQL);
				
			END FOREACH;
			
			-- Imprimir renglón de separación dentro del reporte
			LET cSQL = ' echo "' || '	' || "" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM TRIM(cSQL);
			
			-- Imprimir renglón de MOVIMIENTOS CALCULADOS dentro del reporte (Columnas 34 a 45, Texto MOVIMIENTOS CALCULADOS Columna 46)
			LET cSQL = ' echo "'  || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' 
						|| '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' 
						|| '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' 
						|| '	' || '	' || '	' || '	' || v_sum_mov_cap_vig || '	' || v_sum_mov_cap_venc_trasp 
						|| '	' || v_sum_mov_cap_prorroga || '	' || v_sum_mov_cap_venc_exi || '	' || v_sum_mov_cap_venc_no_exi || '	' || v_sum_mov_int_vig || '	' || v_sum_mov_int_venc_trasp 
						|| '	' || v_sum_mov_int_prorroga || '	' || v_sum_mov_int_venc_exi || '	' || v_sum_mov_int_venc_no_exi || '	' || v_sum_mov_int_venc_orden || '	' || v_sum_mov_total 
						|| '	' || 'MOVIMIENTOS CALCULADOS' || "" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM TRIM(cSQL);
			
			-- Imprimir renglón de separación dentro del reporte
			LET cSQL = ' echo "' || '	' || "" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM TRIM(cSQL);
			
			FOREACH WITH HOLD
				
				-- Obtener las cuentas contables para obtener los importes totales del renglón POLIZA BANCOPPEL dentro del reporte
				SELECT  	TRIM(a.nombre_sdo), c.cta, c.subcta, c.subsubcta, c.ssubsubcta, 
							c.sssubsubcta, c.sector
				INTO 		v_nombre_sdo, v_cta, v_subcta, v_subsubcta, v_ssubsubcta, 
							v_sssubsubcta, v_sector
				FROM    	bdicred:"informix".sd_chi_ope_tiposdos a 
				INNER JOIN 	bdicred:"informix".sd_chi_ope_rel_prod_tiposdos_ctascontables b ON a.empresa = b.empresa AND a.id_sdo = b.id_sdo AND b.status = 1
				INNER JOIN  bdicred:"informix".sd_chi_ope_ctascontables c ON c.empresa = b.empresa AND c.id_cta_cont = b.id_cta_cont AND c.status = 1
				INNER JOIN  bdicred:"informix".sd_chi_ope_productos d ON d.empresa = b.empresa AND d.id_prod = b.id_prod AND d.status = 1
				WHERE   	a.empresa = v_empresa AND a.status = 1 AND d.nombre_prod = v_nombre_prod
				
				-- Obtener el importe de los cargos de la póliza de acuerdo a la cuenta contable
				SELECT	SUM(importe)
				INTO	v_importe_a
				FROM 	bdicred:"informix".sd_chi_carga_reg_cont_hist
				WHERE 	cta =  v_cta AND subcta = v_subcta AND subsubcta = v_subsubcta AND ssubsubcta = v_ssubsubcta AND sssubsubcta = v_sssubsubcta AND sector = v_sector
				AND		fechaintegracion = p_fecha_concilia AND naturaleza = 'C' AND poliza = (SELECT MAX(poliza) FROM bdicred:"informix".sd_chi_carga_reg_cont_hist WHERE  fechaintegracion = p_fecha_concilia);
				
				-- Obtener el importe de los abonos de la póliza de acuerdo a la cuenta contable
				SELECT	SUM(importe)
				INTO	v_importe_c
				FROM 	bdicred:"informix".sd_chi_carga_reg_cont_hist
				WHERE 	cta =  v_cta AND subcta = v_subcta AND subsubcta = v_subsubcta AND ssubsubcta = v_ssubsubcta AND sssubsubcta = v_sssubsubcta AND sector = v_sector
				AND		fechaintegracion = p_fecha_concilia AND naturaleza = 'D' AND poliza = (SELECT MAX(poliza) FROM bdicred:"informix".sd_chi_carga_reg_cont_hist WHERE  fechaintegracion = p_fecha_concilia);
				
				-- Restar el importe de abono al importe de cargo
				LET v_importe_total = nvl(v_importe_c, 0) - nvl(v_importe_a, 0);
								
				-- Asignar cuenta contable para el renglón de CUENTAS CONTABLES dentro del reporte
				LET v_cta_contable = v_cta || '-' || v_subcta || '-' || v_subsubcta || '-' || v_ssubsubcta || '-' || v_sssubsubcta || '-' || v_sector;

				-- Asignar cuentas contables para el renglón de CUENTAS CONTABLES dentro del reporte
				-- Asignar importes totales para el renglón de POLIZA BANCOPPEL dentro del reporte
				IF (v_nombre_sdo LIKE '%MOV CAPITAL VIGENTE%') THEN
				
					LET v_ctacont_mov_cap_vig = v_cta_contable;
					LET v_pbc_mov_cap_vig = v_importe_total;
				
				ELIF (v_nombre_sdo LIKE '%MOV CAPITAL VENCIDO POR TRASPASAR%') THEN
				
					LET v_ctacont_mov_cap_venc_trasp = v_cta_contable;
					LET v_pbc_mov_cap_venc_trasp = v_importe_total;
				
				ELIF (v_nombre_sdo LIKE '%MOV CAPITAL PRORROGA%') THEN
				
					LET v_ctacont_mov_cap_prorroga = v_cta_contable;
					LET v_pbc_mov_cap_prorroga = v_importe_total;
				
				ELIF (v_nombre_sdo LIKE '%MOV CAPITAL VENCIDO EXIGIBLE%') THEN
				
					LET v_ctacont_mov_cap_venc_exi = v_cta_contable;
					LET v_pbc_mov_cap_venc_exi = v_importe_total;
				
				ELIF (v_nombre_sdo LIKE '%MOV CAPITAL VENCIDO NO EXIGIBLE%') THEN
				
					LET v_ctacont_mov_cap_venc_no_exi = v_cta_contable;
					LET v_pbc_mov_cap_venc_no_exi = v_importe_total;
				
				ELIF (v_nombre_sdo LIKE '%MOV INTERES VIGENTE%') THEN
				
					LET v_ctacont_mov_int_vig = v_cta_contable;
					LET v_pbc_mov_int_vig = v_importe_total;
				
				ELIF (v_nombre_sdo LIKE '%MOV INTERES VENCIDO POR TRASPASAR%') THEN
				
					LET v_ctacont_mov_int_venc_trasp = v_cta_contable;
					LET v_pbc_mov_int_venc_trasp = v_importe_total;
					
				ELIF (v_nombre_sdo LIKE '%MOV INTERES PRORROGA%') THEN
				
					LET v_ctacont_mov_int_prorroga = v_cta_contable;
					LET v_pbc_mov_int_prorroga = v_importe_total;
					
				ELIF (v_nombre_sdo LIKE '%MOV INTERES VENCIDO EXIGIBLE%') THEN
				
					LET v_ctacont_mov_int_venc_exi = v_cta_contable;
					LET v_pbc_mov_int_venc_exi = v_importe_total;
			
				ELIF (v_nombre_sdo LIKE '%MOV INTERES VENCIDO NO EXIGIBLE%') THEN
				
					LET v_ctacont_mov_int_venc_no_exi = v_cta_contable;
					LET v_pbc_mov_int_venc_no_exi = v_importe_total;
					
				ELIF (v_nombre_sdo LIKE '%MOV INTERES VENCIDO DE ORDEN%') THEN
				
					LET v_ctacont_mov_int_venc_orden = v_cta_contable;
					LET v_pbc_mov_int_venc_orden = v_importe_total;
								
				END IF;
				
				LET v_pbc_mov_total = v_pbc_mov_total + v_importe_total;
				
			END FOREACH;

			-- Imprimir renglón de POLIZA BANCOPPEL dentro del reporte (Columnas 34 a 45, Texto POLIZA BANCOPPEL Columna 46)
			LET cSQL = ' echo "'  || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' 
						|| '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' 
						|| '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' 
						|| '	' || '	' || '	' || '	' ||  v_pbc_mov_cap_vig || '	' || v_pbc_mov_cap_venc_trasp 
						|| '	' || v_pbc_mov_cap_prorroga || '	' || v_pbc_mov_cap_venc_exi || '	' || v_pbc_mov_cap_venc_no_exi || '	' || v_pbc_mov_int_vig || '	' || v_pbc_mov_int_venc_trasp
						|| '	' || v_pbc_mov_int_prorroga || '	' || v_pbc_mov_int_venc_exi || '	' || v_pbc_mov_int_venc_no_exi || '	' || v_pbc_mov_int_venc_orden || '	' || v_pbc_mov_total
						|| '	' || 'POLIZA BANCOPPEL' || "" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM TRIM(cSQL);
			
			-- Imprimir renglón de separación dentro del reporte
			LET cSQL = ' echo "' || '	' || "" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM TRIM(cSQL);
			
			-- Restar montos para el renglón de DIFERENCIA del reporte
			LET v_dif_mov_cap_vig 				= v_sum_mov_cap_vig 		- v_pbc_mov_cap_vig;
			LET v_dif_mov_cap_venc_trasp		= v_sum_mov_cap_venc_trasp	- v_pbc_mov_cap_venc_trasp;
			LET v_dif_mov_cap_prorroga			= v_sum_mov_cap_prorroga	- v_pbc_mov_cap_prorroga;
			LET v_dif_mov_cap_venc_exi			= v_sum_mov_cap_venc_exi	- v_pbc_mov_cap_venc_exi;
			LET v_dif_mov_cap_venc_no_exi		= v_sum_mov_cap_venc_no_exi	- v_pbc_mov_cap_venc_no_exi;
			LET v_dif_mov_int_vig 				= v_sum_mov_int_vig 		- v_pbc_mov_int_vig;
			LET v_dif_mov_int_venc_trasp		= v_sum_mov_int_venc_trasp	- v_pbc_mov_int_venc_trasp;
			LET v_dif_mov_int_prorroga			= v_sum_mov_int_prorroga	- v_pbc_mov_int_prorroga;
			LET v_dif_mov_int_venc_exi			= v_sum_mov_int_venc_exi	- v_pbc_mov_int_venc_exi;
			LET v_dif_mov_int_venc_no_exi	    = v_sum_mov_int_venc_no_exi	- v_pbc_mov_int_venc_no_exi;
			LET v_dif_mov_int_venc_orden	    = v_sum_mov_int_venc_orden	- v_pbc_mov_int_venc_orden;
			LET v_dif_mov_total				    = v_sum_mov_total			- v_pbc_mov_total;
			
			-- Imprimir renglón de DIFERENCIA dentro del reporte (Columnas 34 a 45, Texto DIFERENCIA Columna 46)
			LET cSQL = ' echo "'  || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' 
						|| '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' 
						|| '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' 
						|| '	' || '	' || '	' || '	' || v_dif_mov_cap_vig || '	' || v_dif_mov_cap_venc_trasp 
						|| '	' || v_dif_mov_cap_prorroga || '	' || v_dif_mov_cap_venc_exi || '	' || v_dif_mov_cap_venc_no_exi || '	' || v_dif_mov_int_vig || '	' || v_dif_mov_int_venc_trasp
						|| '	' || v_dif_mov_int_prorroga || '	' || v_dif_mov_int_venc_exi || '	' || v_dif_mov_int_venc_no_exi || '	' || v_dif_mov_int_venc_orden || '	' || v_dif_mov_total
						|| '	' || 'DIFERENCIA' || "" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM TRIM(cSQL);
			
			-- Imprimir renglón de separación dentro del reporte
			LET cSQL = ' echo "' || '	' || "" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM TRIM(cSQL);
			
			-- Imprimir renglón de CUENTAS CONTABLES dentro del reporte (Columnas 34 a 45, Texto CUENTAS CONTABLES Columna 46)
			LET cSQL = ' echo "'  || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' 
						|| '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' 
						|| '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' || '	' 
						|| '	' || '	' || '	' || '	' || v_ctacont_mov_cap_vig || '	' || v_ctacont_mov_cap_venc_trasp 
						|| '	' || v_ctacont_mov_cap_prorroga || '	' || v_ctacont_mov_cap_venc_exi || '	' || v_ctacont_mov_cap_venc_no_exi || '	' || v_ctacont_mov_int_vig || '	' || v_ctacont_mov_int_venc_trasp
						|| '	' || v_ctacont_mov_int_prorroga || '	' || v_ctacont_mov_int_venc_exi || '	' || v_ctacont_mov_int_venc_no_exi || '	' || v_ctacont_mov_int_venc_orden || '	'
						|| '	' || 'CUENTA CONTABLE' || "" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM TRIM(cSQL);
			
			-- Si la diferencia de los montos es igual a 0, asignar a la variable de indicador de que la conciliación fue exitosa; si no, asignar a la variable de indicador de que la conciliación no fue exitosa
			IF (v_dif_mov_total = 0) THEN
			
				LET v_ind_procesada = 1;
			
			ELSE
		
				LET v_ind_procesada = 0;
			
			END IF;
			
			-- Actualizar en la tabla de conciliación el indicador
			UPDATE 	bdicred:"informix".sd_chi_ope_concilia_mvtos
			SET		ind_procesada = v_ind_procesada
			WHERE 	empresa = v_empresa AND fecha_concilia = p_fecha_concilia AND version_concilia = p_version_concilia;
			
		END FOREACH;
		
		RETURN cod_ret;	
    END	
END PROCEDURE;