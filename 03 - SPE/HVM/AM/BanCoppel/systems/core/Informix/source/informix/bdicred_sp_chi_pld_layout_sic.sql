CREATE PROCEDURE "informix".sp_chi_pld_layout_sic(v_id_proceso CHAR(1))
	RETURNING CHAR(5) as codigo_retorno;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	-- Creado por: 			Gutberto Gomez Guadarrama
	-- Fecha de creacion: 	25/05/2021
	-- Peticion:			RQM 10-1404 (RQI 28 268)
	-- Modificado por: 		N/A
	-- Fecha modificación:	N/A
	-- Modificación:		N/A
	-- BD: 					bdicred
	-- ID Rational:			50746
	-------------------------------------------------------------------------------------
	-- Peticion:			RQM 10 1404 - Hipotecario Infonavit
	-- Modificado por: 		Miguel Alejandro Sánchez Mojica
	-- Fecha modificación:	16/12/2021
	-- Modificación:		Manejo de errores en sección de exceptions
	-- BD: 					bdicred
	-- ID Rational:			54604
	-------------------------------------------------------------------------------------
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES ERROR                        *
-- ****************************************************************************
    DEFINE     	sql_err                 INTEGER;
    DEFINE     	isam_err                INTEGER;
    DEFINE     	error_info              CHAR(40);
    DEFINE     	cod_ret                 CHAR(6);
	DEFINE	   	mensaje_ret				VARCHAR(255);
    DEFINE     	cod_ret_aux             CHAR(6);
	DEFINE	   	mensaje_ret_aux			VARCHAR(255);
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	DEFINE 		v_fechacaptura          DATE;
	DEFINE 		v_fechaintegracion      DATE;
	DEFINE 		v_naturaleza            CHAR(1);
	DEFINE 		v_importe               MONEY(18,2);
	DEFINE 		v_mensaje               CHAR(50);
	DEFINE 		v_status	            CHAR(8);
	DEFINE 		v_integra               INTEGER;
	DEFINE 		v_numtotal              SMALLINT;
	DEFINE	   	vCounter				INTEGER;
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES RUTAS                        *
-- ****************************************************************************
	DEFINE 		cRuta_in			    CHAR(100);
	DEFINE 		cRuta_out			    CHAR(100);
	DEFINE 		cSQL                    CHAR(1000);
	DEFINE 		cNomSQL                 CHAR(100);
	DEFINE 		cDia					CHAR(2);
	DEFINE 		cMes					CHAR(2);
	DEFINE 		cYear				    CHAR(4);
	DEFINE 		cArchivoLay			    CHAR(100);
	DEFINE 		cArchivoRep			    CHAR(100);
	DEFINE 		cNombreArchivo		    CHAR(100);
	DEFINE 		cNombreArchivo2		    CHAR(100);
	
	DEFINE		v_ap_paterno			VARCHAR(50);
	DEFINE		v_ap_materno			VARCHAR(50);
	DEFINE		v_nombres				VARCHAR(80);
	DEFINE		v_fecha_nac				VARCHAR(10);
	DEFINE		v_rfc					VARCHAR(13);
	DEFINE		v_num_credito			VARCHAR(20);
	DEFINE		v_ind_listas_negras		VARCHAR(1);
	DEFINE		v_count_exist			INTEGER;
-- ****************************************************************************
-- *                INICIALIZACION DE VARIABLES ERRORES                       *
-- ****************************************************************************
	LET 		sql_err      			= 0;
	LET 		isam_err     			= 0;
    LET 	   	cod_ret 				= '00000'; 
	LET 	   	mensaje_ret 			= 'PROCESO EXITOSO';
    LET 	   	cod_ret_aux 			= '00000'; 
	LET 	   	mensaje_ret_aux 		= '';
	LET			v_count_exist			= 0;
-- ****************************************************************************
-- *                    INICIALIZACION DE VARIABLES                           *
-- ****************************************************************************
	LET			v_fechacaptura			= today;
-- ****************************************************************************
-- *                  INICIALIZACION DE VARIABLES RUTAS                       *
-- ****************************************************************************
	LET 		cRuta_in	 			= "/resplogifx/hipotecario_infonavit/pld/";
	LET 		cRuta_out	 			= "/RESPALDOSNEW/hipotecario_infonavit/pld/";
	LET 		cSQL					= "";
	LET 		cNomSQL					= "sd_temp_chi_pld_layout_sic.sql";
	LET 		cDia					= LPAD(DAY(DATE(1)), 2, '0');
	LET 		cMes					= LPAD(MONTH(DATE(1)), 2, '0');
	LET 		cYear					= LPAD(YEAR(DATE(1)), 4, '0');
	LET 		cArchivoLay				= "chi_pld_layout_sic_";
	LET 		cArchivoRep				= "chi_pld_layout_sic_listas_negras_";
	LET			cNombreArchivo			= "";
	LET			cNombreArchivo2			= "";
	LET			vCounter				= 0;
	
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

    BEGIN
		ON EXCEPTION SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '11111';	
				
				DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic_paso;
				DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic;
							
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668) SET sql_err, isam_err
			IF sql_err != 0 THEN
			
				LET cod_ret = '22222';		
				LET mensaje_ret = 'VERIFICAR RUTA DEL ARCHIVO A CARGAR, TIPOS DE DATOS Y LONGITUDES';
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-1207) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '33333';		
				LET mensaje_ret = 'VERIFICAR TIPOS DE DATOS Y LONGITUDES';
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-268) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
				
				DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic_paso;
				DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-691) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
				
				DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic_paso;
				DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic;
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
        --*****************************************************************
        --*						Debug del Procedure                     --*        
        --*****************************************************************
		--SET DEBUG FILE TO '/resplogifx/hipotecario_infonavit/pld/sp_chi_pld_layout_sic'||v_id_proceso||'.out';
		--TRACE ON;                                                   
		
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	

-- ****************************************************************************
-- *                      SE OBTIENE FECHA DE PROCESO                         *
-- ****************************************************************************	
	SELECT LPAD(YEAR(fecha_hoy), 4, '0') INTO cYear FROM bdicred:sd_fechas WHERE empresa = '001';
	SELECT LPAD(MONTH(fecha_hoy), 2, '0') INTO cMes FROM bdicred:sd_fechas WHERE empresa = '001';
	SELECT LPAD(DAY(fecha_hoy), 2, '0') INTO cDia FROM bdicred:sd_fechas WHERE empresa = '001';	

-- ****************************************************************************
-- *                          PASE A HISTORICO                                *
-- ****************************************************************************	
IF v_id_proceso = 0 THEN
			INSERT INTO bdicred:"informix".sd_chi_pld_layout_sic_hist 
			SELECT * FROM bdicred:"informix".sd_chi_pld_layout_sic;

-- ****************************************************************************
-- *                     ELIMINAR REGISTROS ACTUALES                          *
-- ****************************************************************************	
			
			DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic;
		
-- ****************************************************************************
-- *                        ELIMINAR TABLA DE PASO                            *
-- ****************************************************************************	
			
			DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic_paso;
		
	
-- ****************************************************************************
-- *               IMPORTACIóN DE ARCHIVO A TABLA DE PASO                     *
-- ****************************************************************************	
			
			--- layout de archivo: APELLIDO PATERNO|APELLIDO MATERNO|NOMBRE(S)|FECHA DE NACIMIENTO(DDMMAAAA)|RFC|NUMERO CREDITO
			LET cNombreArchivo = TRIM(cArchivoLay) || cYear || cMes || cDia || '.txt ';
			LET cSQL = ' echo "SET ISOLATION TO DIRTY READ; LOAD FROM ' || TRIM(cRuta_in) || TRIM(cNombreArchivo) || 
				' INSERT INTO bdicred:"informix".sd_chi_pld_layout_sic_paso;' || "" || '">'||TRIM(cRuta_in)|| TRIM(cNomSQL);
			SYSTEM TRIM(cSQL);

			LET cSQL='chmod 777 '|| TRIM(cRuta_in)|| TRIM(cNomSQL);
			SYSTEM cSQL;

			LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta_in) || TRIM(cNomSQL);
			SYSTEM cSQL;
			
			LET cSQL = 'rm ' || TRIM(cRuta_in) || TRIM(cNomSQL);
			SYSTEM cSQL;
			

-- ****************************************************************************
-- *                    PASE A TABLA DE PROCESO ACTUAL                        *
-- ****************************************************************************	
				
			FOREACH WITH HOLD
				SELECT  
					hito_num_credito,
					hito_nombres,
					hito_fecha_nacimiento,
					hito_rfc
					--
					INTO 
					v_num_credito,
					v_nombres,
					v_fecha_nac,
					v_rfc
				FROM bdicred:"informix".sd_chi_pld_layout_sic_paso
				
				SELECT COUNT (*) INTO v_count_exist
				FROM bdicred:"informix".sd_chi_pld_layout_sic WHERE hito_num_credito = v_num_credito;
				
				IF v_count_exist = 0 THEN
				
					INSERT INTO bdicred:"informix".sd_chi_pld_layout_sic VALUES
					(
						v_num_credito,
						v_nombres,
						v_fecha_nac,
						v_rfc,
						'',--pld_numcte_bcpl
						'',--pld_uid
						'',--pld_categoria
						'',--pld_sub_categoria
						'',--pld_posicion
						'',--pld_lugar_nacimiento
						'',--pld_ciudadania
						'',--pld_companias
						'',--pld_ind_validado
						'',--pld_ind_listas_negras
						CURRENT::datetime year to second,--fecha_carga
						CURRENT::datetime year to second--fecha_modifica
					);
					ELSE
						INSERT INTO bdicred:"informix".sd_chi_pld_layout_sic_err VALUES
						(
							v_num_credito,
							v_nombres,
							v_fecha_nac,
							v_rfc,
							'',--pld_numcte_bcpl
							'',--pld_uid
							'',--pld_categoria
							'',--pld_sub_categoria
							'',--pld_posicion
							'',--pld_lugar_nacimiento
							'',--pld_ciudadania
							'',--pld_companias
							'',--pld_ind_validado
							'',--pld_ind_listas_negras
							CURRENT::datetime year to second,--fecha_carga
							CURRENT::datetime year to second--fecha_modifica
						);
					END IF;
					
			END FOREACH;
			
-- ****************************************************************************
-- *                       GENERACIÓN DE REPORTE                              *
-- ****************************************************************************	
			ELSE

					--- layout de archivo: APELLIDO PATERNO|APELLIDO MATERNO|NOMBRE(S)|FECHA DE NACIMIENTO(DDMMAAAA)|RFC
					LET cNombreArchivo = TRIM(cArchivoRep) || cYear || cMes || cDia || '.unl ';
					let cSQL = '';
					let cSQL=  'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' 
					|| TRIM(cRuta_out) || TRIM(cNombreArchivo) || 
					' SELECT TRIM(hito_num_credito), hito_nombres, hito_fecha_nacimiento, hito_rfc, pld_ind_listas_negras FROM bdicred:"informix".sd_chi_pld_layout_sic /*WHERE ind_listas_negras = "0"*/;">'
					||TRIM(cRuta_out)|| TRIM(cNomSQL);
					system cSQL;
							
					let cSQL='chmod 777 '|| TRIM(cRuta_out)|| TRIM(cNomSQL);
					System cSQL;
							
					let cSQL = '';
					let cSQL= '/ifxsif01/bin/dbaccess bdicred ' || TRIM(cRuta_out) || TRIM(cNomSQL);
					system cSQL;					
					
					let cSQL = cSQL;
					let cSQL ='rm ' || TRIM(cRuta_out) || TRIM(cNomSQL);
					
					LET cNombreArchivo2 = TRIM(cArchivoRep) || cYear || cMes || cDia || '.txt ';
					
					system cSQL;
					let cSQL ='';
					let cSQL = "sed 's/|$//g' "|| TRIM(cRuta_out) || TRIM(cNombreArchivo) ||" >> "|| TRIM(cRuta_out) || TRIM(cNombreArchivo2);
					system cSQL;

					let cSQL = cSQL;
					let cSQL ='rm ' || TRIM(cRuta_out) || TRIM(cNombreArchivo);
					system cSQL;
					
					
			
		END IF
		RETURN cod_ret;	
    END	
END PROCEDURE;