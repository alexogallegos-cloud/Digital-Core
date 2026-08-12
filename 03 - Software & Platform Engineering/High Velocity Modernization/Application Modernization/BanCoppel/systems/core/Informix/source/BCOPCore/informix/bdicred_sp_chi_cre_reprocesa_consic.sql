CREATE PROCEDURE "informix".sp_chi_cre_reprocesa_consic ()
	RETURNING CHAR(5) as codigo_retorno;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	--Creado por: Miguel Alejandro Sanchez Mojica
	--Fecha de creación: 23/03/2021
	--Peticion: 
	--Modificado por: 
	--Fecha de modificación: 
	--Modificación: 
	--BD: 
	-------------------------------------------------------------------------------------
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES ERROR                        *
-- ****************************************************************************
	DEFINE		sql_err					INTEGER;
	DEFINE		isam_err				INTEGER;
	DEFINE		error_info				CHAR(40);
	DEFINE		cod_ret					CHAR(6);
	DEFINE		mensaje_ret				VARCHAR(255);
	DEFINE		cod_ret_aux				CHAR(6);
	DEFINE		mensaje_ret_aux			VARCHAR(255);
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	DEFINE		v_iId                   INTEGER;
	DEFINE		v_cApellido_P           CHAR(26);
	DEFINE		v_cApellido_M           CHAR(26);
	DEFINE		v_cNombre1              CHAR(26);
	DEFINE		v_cNombre2              CHAR(26);
	DEFINE		v_cNumCredito          CHAR(25);
	DEFINE		v_cEmpresa              CHAR(3);
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES RUTAS                        *
-- ****************************************************************************
	DEFINE		cRuta					CHAR(100);
	DEFINE		cSQL					CHAR(1000);
	DEFINE		cNomSQL					CHAR(100);
	DEFINE		cDia					CHAR(2);
	DEFINE		cMes					CHAR(2);
	DEFINE		cYear					CHAR(4);
	DEFINE		cArchivoLay				CHAR(100);
	DEFINE		cNombreArchivo			CHAR(100);
-- ****************************************************************************
-- *                INICIALIZACION DE VARIABLES ERRORES                       *
-- ****************************************************************************
	LET			sql_err					= 0;
	LET			isam_err				= 0;
	LET			cod_ret 				= '00000'; 
	LET			mensaje_ret 			= 'PROCESO EXITOSO';
	LET			cod_ret_aux 			= '00000'; 
	LET			mensaje_ret_aux 		= '';
-- ****************************************************************************
-- *                    INICIALIZACION DE VARIABLES                           *
-- ****************************************************************************
	LET			v_iId                   = 0;
	LET			v_cApellido_P           = '';
	LET			v_cApellido_M           = '';
	LET			v_cNombre1              = '';
	LET			v_cNombre2              = '';
	LET			v_cNumCredito          = '';
	LET			v_cEmpresa              = '001';
-- ****************************************************************************
-- *                  INICIALIZACION DE VARIABLES RUTAS                       *
-- ****************************************************************************
	LET			cRuta		 			= "/resplogifx/hipotecario_infonavit/sics/";
	LET			cSQL					= "";
	LET			cNomSQL					= "sp_temp_chi_cre_reprocesa_consic.sql";
	LET			cDia					= LPAD(DAY(DATE(1)), 2, '0');
	LET			cMes					= LPAD(MONTH(DATE(1)), 2, '0');
	LET			cYear					= LPAD(YEAR(DATE(1)), 4, '0');
	LET			cArchivoLay				= "chi_cre_reprocesa_consulta_sic_";
	LET			cNombreArchivo			= "";
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

	BEGIN
		ON EXCEPTION SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '11111';	
				
				DELETE FROM bdicred:"informix".sd_chi_cre_carga_reproceso_consic WHERE num_credito > 0;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-668) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '22222';		
				LET mensaje_ret = 'VERIFICAR RUTA DEL ARCHIVO A EJECUTAR';
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-1207) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '33333';		
				LET mensaje_ret = 'VERIFICAR TIPOS DE DATOS O LONGITUDES';
				
				DELETE FROM bdicred:"informix".sd_chi_cre_carga_reproceso_consic WHERE num_credito > 0;
							
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-268) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
				
				DELETE FROM bdicred:"informix".sd_chi_cre_carga_reproceso_consic WHERE num_credito > 0;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-691) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
					
				DELETE FROM bdicred:"informix".sd_chi_cre_carga_reproceso_consic WHERE num_credito > 0;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-391) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '55555';		
				LET mensaje_ret = 'VERIFICAR CAMPOS, INSERCIÓN DE NULOS';
						
				DELETE FROM bdicred:"informix".sd_chi_cre_carga_reproceso_consic WHERE num_credito > 0;
						
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-846) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '66666';		
				LET mensaje_ret = 'NÚMERO DE VALORES NO ES IGUAL AL NUMERO DE COLUMNAS';
					
				DELETE FROM bdicred:"informix".sd_chi_cre_carga_reproceso_consic WHERE num_credito > 0;
							
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--*****************************************************************
		--*						Debug del Procedure                     --*        
		--*****************************************************************
		--SET DEBUG FILE TO '/RESPALDOSNEW/hipotecario_infonavit/sics/sp_chi_cre_reprocesa_consic.out';
		--TRACE ON;                                                     --*
		
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	
-- ****************************************************************************
-- *                       IMPORTACIÓN DE ARCHIVO                             *
-- ****************************************************************************	
			
		DELETE FROM bdicred:"informix".sd_chi_cre_carga_reproceso_consic WHERE num_credito > 0;
		
		SELECT LPAD(YEAR(fecha_hoy), 4, '0'), 
			LPAD(MONTH(fecha_hoy), 2, '0'), 
			LPAD(DAY(fecha_hoy), 2, '0')
		INTO cYear, cMes, cDia
		FROM bdicred:sd_fechas 
		WHERE empresa = v_cEmpresa;
		
		LET cNombreArchivo = TRIM(cArchivoLay) || cYear || cMes || cDia || '.txt ';
		LET cSQL = ' echo "SET ISOLATION TO DIRTY READ; LOAD FROM ' || TRIM(cRuta) || TRIM(cNombreArchivo) || 
			' INSERT INTO bdicred:"informix".sd_chi_cre_carga_reproceso_consic;' || "" || '">'||TRIM(cRuta)|| TRIM(cNomSQL);
		SYSTEM TRIM(cSQL);
		
		LET cSQL='chmod 777 '|| TRIM(cRuta)|| TRIM(cNomSQL);
		SYSTEM cSQL;
		
		LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || TRIM(cNomSQL);
		SYSTEM cSQL;
		
		LET cSQL = 'rm ' || TRIM(cRuta) || TRIM(cNomSQL);
		SYSTEM cSQL;
		
-- ****************************************************************************
-- *                      ACTUALIZACIÓN NOMBRES                               *
-- ****************************************************************************
		FOREACH WITH HOLD
			
			SELECT id, num_credito, NVL(apell_paterno, ''), NVL(apell_materno, ''), nombre1, NVL(nombre2, '')
			INTO v_iId, v_cNumCredito, v_capellido_p, v_capellido_m, v_cnombre1, v_cnombre2
			FROM bdicred:"informix".sd_chi_cre_carga_reproceso_consic
			WHERE num_credito > 0
		
			UPDATE bdicred:"informix".sd_chi_cre_carga_consic_hist
			SET apell_paterno = v_capellido_p
				, apell_materno = v_capellido_m
				, nombre1 = v_cnombre1
				, nombre2 = v_cnombre2
				, buro_status = 'NPR'
				, fecha_reproceso = CURRENT
			WHERE id = v_iId 
				AND num_credito = v_cNumCredito;
			
		END FOREACH;
-- ****************************************************************************
-- *                        ENVIO A CONSULTA BURÓ                             *
-- ****************************************************************************	
		EXECUTE PROCEDURE bdicred:"informix".sp_chi_cre_consulta_sic ('R', 0)
		INTO cod_ret;
		
		RETURN cod_ret;	
	END	
END PROCEDURE;