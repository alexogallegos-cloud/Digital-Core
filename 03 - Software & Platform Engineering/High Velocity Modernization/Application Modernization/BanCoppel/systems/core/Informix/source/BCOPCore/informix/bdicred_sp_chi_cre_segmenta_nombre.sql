CREATE PROCEDURE "informix".sp_chi_cre_segmenta_nombre ()
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
	DEFINE		v_i						INTEGER;
	DEFINE		v_iIdControl            INTEGER;
	DEFINE		v_iIdControlIni         INTEGER;
	DEFINE		v_iId                   INTEGER;
	DEFINE		v_iEspacioAux           INTEGER;
	DEFINE		v_iIdSegmento           INTEGER;
	DEFINE		v_iBan                  INTEGER;
	DEFINE		v_sIndValidado          SMALLINT;
	DEFINE		v_sIndListasNegras      SMALLINT;
	DEFINE		v_cNombreAux            CHAR(104);
	DEFINE		v_cNombreCompleto       CHAR(104);
	DEFINE		v_cSegmento_1           CHAR(26);
	DEFINE		v_cSegmento_2           CHAR(26);
	DEFINE		v_cSegmento_3           CHAR(26);
	DEFINE		v_cSegmento_4           CHAR(26);
	DEFINE		v_cSegmento_5           CHAR(26);
	DEFINE		v_cSegmento_6           CHAR(26);
	DEFINE		v_cSegmento_7           CHAR(26);
	DEFINE		v_cSegmento_8           CHAR(26);
	DEFINE		v_cSegmento_9           CHAR(26);
	DEFINE		v_cCurp_p1              CHAR(1);
	DEFINE		v_cCurp_p2              CHAR(1);
	DEFINE		v_cCurp_p3              CHAR(1);
	DEFINE		v_cCurp_p4              CHAR(1);
	DEFINE		v_cCurp_p56             CHAR(2);
	DEFINE		v_cCurp_p78             CHAR(2);
	DEFINE		v_cCurp_p910            CHAR(2);
	DEFINE		v_cCurp_p11             CHAR(1);
	DEFINE		v_cCurp_p1213           CHAR(2);
	DEFINE		v_cCurp_p14             CHAR(1);
	DEFINE		v_cCurp_p15             CHAR(1);
	DEFINE		v_cCurp_p16             CHAR(1);
	DEFINE		v_cCurp_p17             CHAR(1);
	DEFINE		v_cCurp_p18             CHAR(1);
	DEFINE		v_cCurpArmado           CHAR(18);
	DEFINE		v_cNombre2_aux          CHAR(1);
	DEFINE		v_cRFCArmado            CHAR(13);
	DEFINE		v_cApellido_P           CHAR(26);
	DEFINE		v_cApellido_M           CHAR(26);
	DEFINE		v_cNombre1              CHAR(26);
	DEFINE		v_cNombre2              CHAR(26);
	DEFINE		v_cArtApe_P             CHAR(26);
	DEFINE		v_cArtApe_M             CHAR(26);
	DEFINE		v_cArtNom1              CHAR(26);
	DEFINE		v_cArtNom2              CHAR(26);
	DEFINE		v_cFechaNac             CHAR(10);
	DEFINE		v_cRFC                  CHAR(13);
	DEFINE		v_cCURP                 CHAR(18);
	DEFINE		v_cTipoResi             CHAR(1);
	DEFINE		v_cEdoCivil             CHAR(1);
	DEFINE		v_cGenero               CHAR(1);
	DEFINE		v_cNumDep               CHAR(2);
	DEFINE		v_cDir1                 CHAR(40);
	DEFINE		v_cDir2                 CHAR(40);
	DEFINE		v_cColonia              CHAR(40);
	DEFINE		v_cDelegacion           CHAR(40);
	DEFINE		v_cCiudad               CHAR(40);
	DEFINE		v_cEstado               CHAR(4);
	DEFINE		v_cCP                   CHAR(5);
	DEFINE		v_ctipo_dom             CHAR(1);
	DEFINE		v_cNumCredito           CHAR(25);
	DEFINE		v_cProd                 CHAR(4);
	DEFINE		v_cMontoCred            MONEY(18, 2);
	DEFINE		v_mMontoMin             MONEY(18, 2);
	DEFINE		v_mMontoMax             MONEY(18, 2);
	DEFINE		v_cFechaCarga           DATE;
	DEFINE		v_cEmpresa              CHAR(3);
	DEFINE		v_sind_segnom_valido    CHAR(1);
	DEFINE		v_sind_fondeo_mont_prod CHAR(1);
	DEFINE		v_cclave_proc           CHAR(1);
	DEFINE		v_cclave_status         CHAR(1);
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
	DEFINE		cArchivoRep				CHAR(100);
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
	LET			v_i						= 0;
	LET			v_iIdControl            = 0;
	LET			v_iIdControlIni         = 0;
	LET			v_iId                   = 0;
	LET			v_iIdSegmento           = 0;
	LET			v_iBan                  = 0;
	LET			v_sIndValidado          = 0;
	LET			v_sIndListasNegras      = 0;
	LET			v_cNombreAux            = '';
	LET			v_cNombreCompleto       = '';
	LET			v_cSegmento_1           = '';
	LET			v_cSegmento_2           = '';
	LET			v_cSegmento_3           = '';
	LET			v_cSegmento_4           = '';
	LET			v_cSegmento_5           = '';
	LET			v_cSegmento_6           = '';
	LET			v_cSegmento_7           = '';
	LET			v_cSegmento_8           = '';
	LET			v_cSegmento_9           = '';
	LET			v_cCurp_p1              = '';
	LET			v_cCurp_p2              = '';
	LET			v_cCurp_p3              = '';
	LET			v_cCurp_p4              = '';
	LET			v_cCurp_p56             = '';
	LET			v_cCurp_p78             = '';
	LET			v_cCurp_p910            = '';
	LET			v_cCurp_p11             = '';
	LET			v_cCurp_p1213           = '';
	LET			v_cCurp_p14             = '';
	LET			v_cCurp_p15             = '';
	LET			v_cCurp_p16             = '';
	LET			v_cCurp_p17             = '';
	LET			v_cCurp_p18             = '';
	LET			v_cCurpArmado           = '';
	LET			v_cNombre2_aux          = '';
	LET			v_cRFCArmado            = '';
	LET			v_iIdSegmento           = 1;
	LET			v_cApellido_P           = '';
	LET			v_cApellido_M           = '';
	LET			v_cNombre1              = '';
	LET			v_cNombre2              = '';
	LET			v_cArtApe_P             = '';
	LET			v_cArtApe_M             = '';
	LET			v_cArtNom1              = '';
	LET			v_cArtNom2              = '';
	LET			v_cFechaNac             = '';
	LET			v_cRFC                  = '';
	LET			v_cCURP                 = '';
	LET			v_cTipoResi             = '';
	LET			v_cEdoCivil             = '';
	LET			v_cGenero               = '';
	LET			v_cNumDep               = '';
	LET			v_cDir1                 = '';
	LET			v_cDir2                 = '';
	LET			v_cColonia              = '';
	LET			v_cDelegacion           = '';
	LET			v_cCiudad               = '';
	LET			v_cEstado               = '';
	LET			v_cCP                   = '';
	LET			v_ctipo_dom             = '';
	LET			v_cNumCredito           = '';
	LET			v_cProd                 = '';
	LET			v_cMontoCred            = '0.0';
	LET			v_mMontoMin             = 0.0;
	LET			v_mMontoMax             = 0.0;
	LET			v_cEmpresa              = '001';
	LET			v_sind_segnom_valido    = '0';
	LET			v_sind_fondeo_mont_prod = '0';
	LET			v_cclave_proc           = '0';
	LET			v_cclave_status         = '0';
-- ****************************************************************************
-- *                  INICIALIZACION DE VARIABLES RUTAS                       *
-- ****************************************************************************
	LET			cRuta		 			= "/resplogifx/hipotecario_infonavit/sics/";
	LET			cSQL					= "";
	LET			cNomSQL					= "sp_temp_chi_cre_segmenta_nombre.sql";
	LET			cDia					= LPAD(DAY(DATE(1)), 2, '0');
	LET			cMes					= LPAD(MONTH(DATE(1)), 2, '0');
	LET			cYear					= LPAD(YEAR(DATE(1)), 4, '0');
	LET			cArchivoLay				= "chi_cre_layout_consulta_sic_";
	LET			cNombreArchivo			= "";
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

	BEGIN
		ON EXCEPTION SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '11111';	
				
				DELETE FROM bdicred:"informix".sd_chi_cre_carga_consic_dia WHERE empresa = '001' AND id > 0;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-668) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '22222';		
				LET mensaje_ret = 'VERIFICAR RUTA DEL ARCHIVO A EJECUTAR';
				
				DELETE FROM bdicred:"informix".sd_chi_cre_carga_consic_dia WHERE empresa = '001' AND id > 0;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-1207) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '33333';		
				LET mensaje_ret = 'VERIFICAR TIPOS DE DATOS O LONGITUDES';
				
				DELETE FROM bdicred:"informix".sd_chi_cre_carga_consic_dia WHERE empresa = '001' AND id > 0;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-268) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
				
				DELETE FROM bdicred:"informix".sd_chi_cre_carga_consic_dia WHERE empresa = '001' AND id > 0;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-691) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
				
				DELETE FROM bdicred:"informix".sd_chi_cre_carga_consic_dia WHERE empresa = '001' AND id > 0;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-391) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '55555';		
				LET mensaje_ret = 'VERIFICAR CAMPOS, INSERCIÓN DE NULOS';
				
				DELETE FROM bdicred:"informix".sd_chi_cre_carga_consic_dia WHERE empresa = '001' AND id > 0;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-846) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '66666';		
				LET mensaje_ret = 'NÚMERO DE VALORES NO ES IGUAL AL NUMERO DE COLUMNAS';
				
				DELETE FROM bdicred:"informix".sd_chi_cre_carga_consic_dia WHERE empresa = '001' AND id > 0;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--*****************************************************************
		--*						Debug del Procedure                     --*        
		--*****************************************************************
		--SET DEBUG FILE TO '/RESPALDOSNEW/hipotecario_infonavit/sics/sp_chi_cre_segmenta_nombre.out';
		--TRACE ON;                                                     --*
		
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	
-- ****************************************************************************
-- *                       IMPORTACIÓN DE ARCHIVO                             *
-- ****************************************************************************	
		
		INSERT INTO bdicred:"informix".sd_chi_cre_carga_consic_hist
		SELECT * FROM bdicred:"informix".sd_chi_cre_carga_consic_dia WHERE empresa = v_cEmpresa AND id > 0;
	
		DELETE FROM bdicred:"informix".sd_chi_cre_carga_consic WHERE num_credito > 0;
		DELETE FROM bdicred:"informix".sd_chi_cre_carga_consic_dia WHERE empresa = v_cEmpresa AND id > 0 ;
		
		SELECT MAX(id)
		INTO v_iIdControlIni
		FROM bdicred:"informix".sd_chi_cre_carga_consic_hist
		WHERE empresa = v_cEmpresa;
		
		IF v_iIdControlIni IS NULL THEN 
			LET  v_iIdControlIni = 1;
		END IF;
		
		LET v_iIdControl = v_iIdControlIni;
		
		SELECT LPAD(YEAR(fecha_hoy), 4, '0'), 
			LPAD(MONTH(fecha_hoy), 2, '0'), 
			LPAD(DAY(fecha_hoy), 2, '0')
		INTO cYear, cMes, cDia
		FROM bdicred:sd_fechas 
		WHERE empresa = v_cEmpresa;
		
		LET cNombreArchivo = TRIM(cArchivoLay) || cYear || cMes || cDia || '.txt ';
		LET cSQL = ' echo "SET ISOLATION TO DIRTY READ; LOAD FROM ' || TRIM(cRuta) || TRIM(cNombreArchivo) || 
			' INSERT INTO bdicred:"informix".sd_chi_cre_carga_consic;' || "" || '">'||TRIM(cRuta)|| TRIM(cNomSQL);
		SYSTEM TRIM(cSQL);
		
		LET cSQL='chmod 777 '|| TRIM(cRuta)|| TRIM(cNomSQL);
		SYSTEM cSQL;
		
		LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || TRIM(cNomSQL);
		SYSTEM cSQL;
		
		LET cSQL = 'rm ' || TRIM(cRuta) || TRIM(cNomSQL);
		SYSTEM cSQL;
		
-- ****************************************************************************
-- *                  ELIMINACIÓN DE CARACTERES ESPECIALES                    *
-- ****************************************************************************	
		UPDATE sd_chi_cre_carga_consic SET nombre = TRIM(REPLACE(nombre, 'á', 'a')) WHERE num_credito > 0;
		UPDATE sd_chi_cre_carga_consic SET nombre = TRIM(REPLACE(nombre, 'Á', 'A')) WHERE num_credito > 0;
		UPDATE sd_chi_cre_carga_consic SET nombre = TRIM(REPLACE(nombre, 'é', 'e')) WHERE num_credito > 0;
		UPDATE sd_chi_cre_carga_consic SET nombre = TRIM(REPLACE(nombre, 'É', 'E')) WHERE num_credito > 0;
		UPDATE sd_chi_cre_carga_consic SET nombre = TRIM(REPLACE(nombre, 'í', 'i')) WHERE num_credito > 0;
		UPDATE sd_chi_cre_carga_consic SET nombre = TRIM(REPLACE(nombre, 'Í', 'I')) WHERE num_credito > 0;
		UPDATE sd_chi_cre_carga_consic SET nombre = TRIM(REPLACE(nombre, 'ó', 'o')) WHERE num_credito > 0;
		UPDATE sd_chi_cre_carga_consic SET nombre = TRIM(REPLACE(nombre, 'Ó', 'O')) WHERE num_credito > 0;
		UPDATE sd_chi_cre_carga_consic SET nombre = TRIM(REPLACE(nombre, 'ú', 'u')) WHERE num_credito > 0;
		UPDATE sd_chi_cre_carga_consic SET nombre = TRIM(REPLACE(nombre, 'Ú', 'U')) WHERE num_credito > 0;
		UPDATE sd_chi_cre_carga_consic SET nombre = TRIM(REPLACE(nombre, 'ñ', 'n')) WHERE num_credito > 0;
		UPDATE sd_chi_cre_carga_consic SET nombre = TRIM(REPLACE(nombre, 'Ñ', 'N')) WHERE num_credito > 0;
		UPDATE sd_chi_cre_carga_consic SET nombre = TRIM(REPLACE(nombre, 'ü', 'u')) WHERE num_credito > 0;
		UPDATE sd_chi_cre_carga_consic SET nombre = TRIM(REPLACE(nombre, 'Ü', 'U')) WHERE num_credito > 0;
-- ****************************************************************************
-- *                           VALIDACIÓN PLD                                 *
-- ****************************************************************************
		FOREACH WITH HOLD
			
			SELECT nombre, fecha_nacimiento, rfc, curp, tipo_residencia, 
				estado_civil, genero, numero_dependientes, direccion1, direccion2, 
				colonia, delegacion, ciudad, estado, codigo_postal, 
				tipo_domicilio, num_credito, producto, monto_credito
			INTO v_cNombreCompleto, v_cFechaNac, v_cRFC, v_cCURP, v_cTipoResi, 
				v_cEdoCivil, v_cGenero, v_cNumDep, v_cDir1, v_cDir2, 
				v_cColonia, v_cDelegacion, v_cCiudad, v_cEstado, v_cCP, 
				v_ctipo_dom, v_cNumCredito, v_cProd, v_cMontoCred
			FROM bdicred:"informix".sd_chi_cre_carga_consic 
			WHERE num_credito > 0
		
			LET v_sind_segnom_valido = '';
			LET v_sind_fondeo_mont_prod = '';
			LET v_cclave_proc = '0';
			LET v_cclave_status = '0';
			LET v_cApellido_P = '';
			LET v_cApellido_M = '';
			LET v_cNombre2 = '';
			
			SELECT pld_ind_validado, pld_ind_listas_negras
			INTO v_sIndValidado, v_sIndListasNegras
			FROM bdicred:"informix".sd_chi_pld_layout_sic 
			WHERE hito_num_credito = v_cNumCredito;
			
			
			IF v_sIndValidado IS NULL OR v_sIndListasNegras IS NULL OR v_sIndValidado = '' OR v_sIndListasNegras = '' THEN 
				SELECT pld_ind_validado, pld_ind_listas_negras
				INTO v_sIndValidado, v_sIndListasNegras
				FROM bdicred:"informix".sd_chi_pld_layout_sic_hist 
				WHERE hito_num_credito = v_cNumCredito;
			END IF;
			
			--NO EXISTE REGISTRO EN PLD
			IF v_sIndValidado IS NULL OR v_sIndListasNegras IS NULL OR v_sIndValidado = '' OR v_sIndListasNegras = '' THEN 
				LET v_iIdControl = v_iIdControl + 1;
				LET v_cclave_proc = '3';
				LET v_cclave_status = '3';
				
				INSERT INTO bdicred:"informix".sd_chi_cre_carga_consic_dia (
					id, empresa, nombre, fecha_nacimiento, rfc, 
					curp, tipo_residencia, estado_civil, genero, numero_dependientes, 
					direccion1, direccion2, colonia, delegacion, ciudad, 
					estado, codigo_postal, tipo_domicilio, num_credito, producto, 
					monto_credito, apell_paterno, apell_materno, nombre1, nombre2, 
					ind_segnom_valido, ind_fondeo_mont_prod, clave_proceso, clave_status, fecha_carga_sist, 
					fecha_reproceso, buro_status 
				) VALUES (
					v_iIdControl, v_cEmpresa, v_cNombreCompleto, v_cFechaNac, v_cRFC, 
					v_cCURP, v_cTipoResi, v_cEdoCivil, v_cGenero, v_cNumDep, 
					v_cDir1, v_cDir2, v_cColonia, v_cDelegacion, v_cCiudad, 
					v_cEstado, v_cCP, v_ctipo_dom, v_cNumCredito, v_cProd, 
					v_cMontoCred, v_cApellido_P, v_cApellido_M, v_cNombreCompleto, v_cNombre2,
					v_sind_segnom_valido, v_sind_fondeo_mont_prod, v_cclave_proc, v_cclave_status, CURRENT, 
					'', 'NPP'
				);
			ELSE
				--REGISTROS QUE YA FUERON VALIDADOS PERO NO SON PERMITIDOS POR PLD
				IF v_sIndValidado = 1 AND v_sIndListasNegras = 1 THEN 
			
					LET v_iIdControl = v_iIdControl + 1;
					LET v_cclave_proc = '1';
					
					INSERT INTO bdicred:"informix".sd_chi_cre_carga_consic_dia (
						id, empresa, nombre, fecha_nacimiento, rfc, 
						curp, tipo_residencia, estado_civil, genero, numero_dependientes, 
						direccion1, direccion2, colonia, delegacion, ciudad, 
						estado, codigo_postal, tipo_domicilio, num_credito, producto, 
						monto_credito, apell_paterno, apell_materno, nombre1, nombre2, 
						ind_segnom_valido, ind_fondeo_mont_prod, clave_proceso, clave_status, fecha_carga_sist, 
						fecha_reproceso, buro_status 
					) VALUES (
						v_iIdControl, v_cEmpresa, v_cNombreCompleto, v_cFechaNac, v_cRFC, 
						v_cCURP, v_cTipoResi, v_cEdoCivil, v_cGenero, v_cNumDep, 
						v_cDir1, v_cDir2, v_cColonia, v_cDelegacion, v_cCiudad, 
						v_cEstado, v_cCP, v_ctipo_dom, v_cNumCredito, v_cProd, 
						v_cMontoCred, v_cApellido_P, v_cApellido_M, v_cNombreCompleto, v_cNombre2,
						v_sind_segnom_valido, v_sind_fondeo_mont_prod, v_cclave_proc, v_cclave_status, CURRENT, 
						'', 'NPP'
					);	
				ELSE 
					--REGISTROS QUE NO HAN SIDO VALIDADOS POR PLD
					IF v_sIndValidado = 0 THEN
			
						LET v_iIdControl = v_iIdControl + 1;
						LET v_cclave_proc = '1';
						LET v_cclave_status = '3';
						
						INSERT INTO bdicred:"informix".sd_chi_cre_carga_consic_dia (
							id, empresa, nombre, fecha_nacimiento, rfc, 
							curp, tipo_residencia, estado_civil, genero, numero_dependientes, 
							direccion1, direccion2, colonia, delegacion, ciudad, 
							estado, codigo_postal, tipo_domicilio, num_credito, producto, 
							monto_credito, apell_paterno, apell_materno, nombre1, nombre2, 
							ind_segnom_valido, ind_fondeo_mont_prod, clave_proceso, clave_status, fecha_carga_sist, 
							fecha_reproceso, buro_status 
						) VALUES (
							v_iIdControl, v_cEmpresa, v_cNombreCompleto, v_cFechaNac, v_cRFC, 
							v_cCURP, v_cTipoResi, v_cEdoCivil, v_cGenero, v_cNumDep, 
							v_cDir1, v_cDir2, v_cColonia, v_cDelegacion, v_cCiudad, 
							v_cEstado, v_cCP, v_ctipo_dom, v_cNumCredito, v_cProd, 
							v_cMontoCred, v_cApellido_P, v_cApellido_M, v_cNombreCompleto, v_cNombre2,
							v_sind_segnom_valido, v_sind_fondeo_mont_prod, v_cclave_proc, v_cclave_status, CURRENT, 
							'', 'NPP'
						);	
					ELSE
						--REGISTROS QUE YA FUERON VALIDADOS Y QUE SI SON PERMITIDOS POR PLD
						IF v_sIndValidado = 1 AND v_sIndListasNegras = 0 THEN 
-- ****************************************************************************
-- *                        SEGMENTACIÓN NOMBRE                               *
-- ****************************************************************************	
							LET v_iEspacioAux = 1;	
							LET v_cNombreAux = v_cNombreCompleto;			
							LET v_cSegmento_1 = TRIM(SUBSTR(v_cNombreAux, 1, INSTR(v_cNombreAux, ' ') - 1));
							
							IF v_cSegmento_1 = '' OR v_cSegmento_1 IS NULL THEN
								LET v_cSegmento_1 = v_cNombreAux;
								LET v_cNombreAux = '';
							END IF;
							
							LET v_iEspacioAux = INSTR(v_cNombreAux, ' ');
							LET v_cNombreAux = TRIM(SUBSTR(v_cNombreAux, v_iEspacioAux + 1, LENGTH(v_cNombreAux)));
							LET v_cSegmento_2 = TRIM(SUBSTR(v_cNombreAux, 1, INSTR(v_cNombreAux, ' ') - 1));
							
							IF v_cSegmento_2 = '' OR v_cSegmento_2 IS NULL THEN
								LET v_cSegmento_2 = v_cNombreAux;
								LET v_cNombreAux = '';
							END IF;
							
							LET v_iEspacioAux = INSTR(v_cNombreAux, ' ');
							LET v_cNombreAux = TRIM(SUBSTR(v_cNombreAux, v_iEspacioAux + 1, LENGTH(v_cNombreAux)));
							LET v_cSegmento_3 = TRIM(SUBSTR(v_cNombreAux, 1, INSTR(v_cNombreAux, ' ') - 1));
							
							IF v_cSegmento_3 = '' OR v_cSegmento_3 IS NULL THEN
								LET v_cSegmento_3 = v_cNombreAux;
								LET v_cNombreAux = '';
							END IF;
							
							LET v_iEspacioAux = INSTR(v_cNombreAux, ' ');
							LET v_cNombreAux = TRIM(SUBSTR(v_cNombreAux, v_iEspacioAux + 1, LENGTH(v_cNombreAux)));
							LET v_cSegmento_4 = TRIM(SUBSTR(v_cNombreAux, 1, INSTR(v_cNombreAux, ' ') - 1));
							
							IF v_cSegmento_4 = '' OR v_cSegmento_4 IS NULL THEN
								LET v_cSegmento_4 = v_cNombreAux;
								LET v_cNombreAux = '';
							END IF;
							
							LET v_iEspacioAux = INSTR(v_cNombreAux, ' ');
							LET v_cNombreAux = TRIM(SUBSTR(v_cNombreAux, v_iEspacioAux + 1, LENGTH(v_cNombreAux)));
							LET v_cSegmento_5 = TRIM(SUBSTR(v_cNombreAux, 1, INSTR(v_cNombreAux, ' ') - 1));
							
							IF v_cSegmento_5 = '' OR v_cSegmento_5 IS NULL THEN
								LET v_cSegmento_5 = v_cNombreAux;
								LET v_cNombreAux = '';
							END IF;
							
							LET v_iEspacioAux = INSTR(v_cNombreAux, ' ');
							LET v_cNombreAux = TRIM(SUBSTR(v_cNombreAux, v_iEspacioAux + 1, LENGTH(v_cNombreAux)));
							LET v_cSegmento_6 = TRIM(SUBSTR(v_cNombreAux, 1, INSTR(v_cNombreAux, ' ') - 1));
							
							IF v_cSegmento_6 = '' OR v_cSegmento_6 IS NULL THEN
								LET v_cSegmento_6 = v_cNombreAux;
								LET v_cNombreAux = '';
							END IF;
							
							LET v_iEspacioAux = INSTR(v_cNombreAux, ' ');
							LET v_cNombreAux = TRIM(SUBSTR(v_cNombreAux, v_iEspacioAux + 1, LENGTH(v_cNombreAux)));
							LET v_cSegmento_7 = TRIM(SUBSTR(v_cNombreAux, 1, INSTR(v_cNombreAux, ' ') - 1));
							
							IF v_cSegmento_7 = '' OR v_cSegmento_7 IS NULL THEN
								LET v_cSegmento_7 = v_cNombreAux;
								LET v_cNombreAux = '';
							END IF;
							
							LET v_iEspacioAux = INSTR(v_cNombreAux, ' ');
							LET v_cNombreAux = TRIM(SUBSTR(v_cNombreAux, v_iEspacioAux + 1, LENGTH(v_cNombreAux)));
							LET v_cSegmento_8 = TRIM(SUBSTR(v_cNombreAux, 1, INSTR(v_cNombreAux, ' ') - 1));
							
							IF v_cSegmento_8 = '' OR v_cSegmento_8 IS NULL THEN
								LET v_cSegmento_8 = v_cNombreAux;
								LET v_cNombreAux = '';
							END IF;
							
							LET v_iEspacioAux = INSTR(v_cNombreAux, ' ');
							LET v_cNombreAux = TRIM(SUBSTR(v_cNombreAux, v_iEspacioAux + 1, LENGTH(v_cNombreAux)));
							LET v_cSegmento_9 = TRIM(SUBSTR(v_cNombreAux, 1, INSTR(v_cNombreAux, ' ') - 1));
							
							IF v_cSegmento_9 = '' OR v_cSegmento_9 IS NULL THEN
								LET v_cSegmento_9 = v_cNombreAux;
								LET v_cNombreAux = '';
							END IF;
							
							LET v_cApellido_P = '' ;
							LET v_cApellido_M = '' ;
							LET v_cNombre1 = '' ;
							LET v_cNombre2 = '' ;
							LET v_iIdSegmento = 1 ;
							LET v_iBan = 0 ;
							LET v_cArtApe_P = '' ;
							LET v_cArtApe_M = '' ;
							LET v_cArtNom1 = '' ;
							LET v_cArtNom2 = '' ;
							
--**********************************************************************APELLIDO PATERNO
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_1));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 1 THEN
								IF v_cArtApe_P = '' OR v_cArtApe_P IS NULL THEN
									LET v_cArtApe_P = TRIM(v_cArtApe_P) || TRIM(v_cSegmento_1);
								ELSE
									LET v_cArtApe_P = TRIM(v_cArtApe_P) || ' ' || TRIM(v_cSegmento_1);
								END IF;
								
								LET v_iIdSegmento = 2;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 1 THEN
									LET v_cApellido_P = TRIM(v_cApellido_P) || TRIM(v_cSegmento_1);									
									LET v_iIdSegmento = 2;
									LET v_iBan = 1;			
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_2));
								
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 2 THEN
								IF v_cArtApe_P = '' OR v_cArtApe_P IS NULL THEN
									LET v_cArtApe_P = TRIM(v_cArtApe_P) || TRIM(v_cSegmento_2);
								ELSE
									LET v_cArtApe_P = TRIM(v_cArtApe_P) || ' ' || TRIM(v_cSegmento_2);
								END IF;
								
								LET v_iIdSegmento = 3;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 2 THEN
									LET v_cApellido_P = TRIM(v_cApellido_P) || TRIM(v_cSegmento_2);
									LET v_iIdSegmento = 3;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_3));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 3 THEN
								IF v_cArtApe_P = '' OR v_cArtApe_P IS NULL THEN
									LET v_cArtApe_P = TRIM(v_cArtApe_P) || TRIM(v_cSegmento_3);
								ELSE
									LET v_cArtApe_P = TRIM(v_cArtApe_P) || ' ' || TRIM(v_cSegmento_3);
								END IF;
								
								LET v_iIdSegmento = 4;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 3 THEN
									LET v_cApellido_P = TRIM(v_cApellido_P) || TRIM(v_cSegmento_3);
									LET v_iIdSegmento = 4;
									LET v_iBan = 1;			
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_4));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 4 THEN
								IF v_cArtApe_P = '' OR v_cArtApe_P IS NULL THEN
									LET v_cArtApe_P = TRIM(v_cArtApe_P) || TRIM(v_cSegmento_4);
								ELSE
									LET v_cArtApe_P = TRIM(v_cArtApe_P) || ' ' || TRIM(v_cSegmento_4);
								END IF;
								
								LET v_iIdSegmento = 5;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 4 THEN
									LET v_cApellido_P = TRIM(v_cApellido_P) || TRIM(v_cSegmento_4);
									LET v_iIdSegmento = 5;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_5));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 5 THEN
								IF v_cArtApe_P = '' OR v_cArtApe_P IS NULL THEN
									LET v_cArtApe_P = TRIM(v_cArtApe_P) || TRIM(v_cSegmento_5);
								ELSE
									LET v_cArtApe_P = TRIM(v_cArtApe_P) || ' ' || TRIM(v_cSegmento_5);
								END IF;
								
								LET v_iIdSegmento = 6;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 5 THEN
									LET v_iIdSegmento = 6;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_6));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 6 THEN
								IF v_cArtApe_P = '' OR v_cArtApe_P IS NULL THEN
									LET v_cArtApe_P = TRIM(v_cArtApe_P) || TRIM(v_cSegmento_6);
								ELSE
									LET v_cArtApe_P = TRIM(v_cArtApe_P) || ' ' || TRIM(v_cSegmento_6);
								END IF;
								
								LET v_iIdSegmento = 7;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 6 THEN
									LET v_cApellido_P = TRIM(v_cApellido_P) || TRIM(v_cSegmento_6);
									LET v_iIdSegmento = 7;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_7));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 7 THEN
								IF v_cArtApe_P = '' OR v_cArtApe_P IS NULL THEN
									LET v_cArtApe_P = TRIM(v_cArtApe_P) || TRIM(v_cSegmento_7);
								ELSE
									LET v_cArtApe_P = TRIM(v_cArtApe_P) || ' ' || TRIM(v_cSegmento_7);
								END IF;
								
								LET v_iIdSegmento = 8;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 7 THEN
									LET v_cApellido_P = TRIM(v_cApellido_P) || TRIM(v_cSegmento_7);
									LET v_iIdSegmento = 8;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_8));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 8 THEN
								IF v_cArtApe_P = '' OR v_cArtApe_P IS NULL THEN
									LET v_cArtApe_P = TRIM(v_cArtApe_P) || TRIM(v_cSegmento_8);
								ELSE
									LET v_cArtApe_P = TRIM(v_cArtApe_P) || ' ' || TRIM(v_cSegmento_8);
								END IF;
								
								LET v_iIdSegmento = 9;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 8 THEN
									LET v_cApellido_P = TRIM(v_cApellido_P) || TRIM(v_cSegmento_8);
									LET v_iIdSegmento = 9;
									LET v_iBan = 1;
								END IF;
							END IF;
--**********************************************************************APELLIDO MATERNO
							LET v_iBan = 0;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_1));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 1 THEN
								IF v_cArtApe_M = '' OR v_cArtApe_M IS NULL THEN
									LET v_cArtApe_M = TRIM(v_cArtApe_M) || TRIM(v_cSegmento_1);
								ELSE
									LET v_cArtApe_M = TRIM(v_cArtApe_M) || ' ' || TRIM(v_cSegmento_1);
								END IF;
								
								LET v_iIdSegmento = 2;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 1 THEN
									LET v_cApellido_M = TRIM(v_cApellido_M) || TRIM(v_cSegmento_1);
									LET v_iIdSegmento = 2;
									LET v_iBan = 1;			
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_2));
								
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 2 THEN
								IF v_cArtApe_M = '' OR v_cArtApe_M IS NULL THEN
									LET v_cArtApe_M = TRIM(v_cArtApe_M) || TRIM(v_cSegmento_2);
								ELSE
									LET v_cArtApe_M = TRIM(v_cArtApe_M) || ' ' || TRIM(v_cSegmento_2);
								END IF;
								
								LET v_iIdSegmento = 3;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 2 THEN
									LET v_cApellido_M = TRIM(v_cApellido_M) || TRIM(v_cSegmento_2);
									LET v_iIdSegmento = 3;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_3));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 3 THEN
								IF v_cArtApe_M = '' OR v_cArtApe_M IS NULL THEN
									LET v_cArtApe_M = TRIM(v_cArtApe_M) || TRIM(v_cSegmento_3);
								ELSE
									LET v_cArtApe_M = TRIM(v_cArtApe_M) || ' ' || TRIM(v_cSegmento_3);
								END IF;
								
								LET v_iIdSegmento = 4;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 3 THEN
									LET v_cApellido_M = TRIM(v_cApellido_M) || TRIM(v_cSegmento_3);
									LET v_iIdSegmento = 4;
									LET v_iBan = 1;			
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_4));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 4 THEN
								IF v_cArtApe_M = '' OR v_cArtApe_M IS NULL THEN
									LET v_cArtApe_M = TRIM(v_cArtApe_M) || TRIM(v_cSegmento_4);
								ELSE
									LET v_cArtApe_M = TRIM(v_cArtApe_M) || ' ' || TRIM(v_cSegmento_4);
								END IF;
								
								LET v_iIdSegmento = 5;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 4 THEN
									LET v_cApellido_M = TRIM(v_cApellido_M) || TRIM(v_cSegmento_4);
									LET v_iIdSegmento = 5;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_5));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 5 THEN
								IF v_cArtApe_M = '' OR v_cArtApe_M IS NULL THEN
									LET v_cArtApe_M = TRIM(v_cArtApe_M) || TRIM(v_cSegmento_5);
								ELSE
									LET v_cArtApe_M = TRIM(v_cArtApe_M) || ' ' || TRIM(v_cSegmento_5);
								END IF;
								
								LET v_iIdSegmento = 6;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 5 THEN
									LET v_cApellido_M = TRIM(v_cApellido_M) || TRIM(v_cSegmento_5);
									LET v_iIdSegmento = 6;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_6));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 6 THEN
								IF v_cArtApe_M = '' OR v_cArtApe_M IS NULL THEN
									LET v_cArtApe_M = TRIM(v_cArtApe_M) || TRIM(v_cSegmento_6);
								ELSE
									LET v_cArtApe_M = TRIM(v_cArtApe_M) || ' ' || TRIM(v_cSegmento_6);
								END IF;
								
								LET v_iIdSegmento = 7;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 6 THEN
									LET v_cApellido_M = TRIM(v_cApellido_M) || TRIM(v_cSegmento_6);
									LET v_iIdSegmento = 7;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_7));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 7 THEN
								IF v_cArtApe_M = '' OR v_cArtApe_M IS NULL THEN
									LET v_cArtApe_M = TRIM(v_cArtApe_M) || TRIM(v_cSegmento_7);
								ELSE
									LET v_cArtApe_M = TRIM(v_cArtApe_M) || ' ' || TRIM(v_cSegmento_7);
								END IF;
								
								LET v_iIdSegmento = 8;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 7 THEN
									LET v_cApellido_M = TRIM(v_cApellido_M) || TRIM(v_cSegmento_7);
									LET v_iIdSegmento = 8;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_8));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 8 THEN
								IF v_cArtApe_M = '' OR v_cArtApe_M IS NULL THEN
									LET v_cArtApe_M = TRIM(v_cArtApe_M) || TRIM(v_cSegmento_8);
								ELSE
									LET v_cArtApe_M = TRIM(v_cArtApe_M) || ' ' || TRIM(v_cSegmento_8);
								END IF;
								
								LET v_iIdSegmento = 9;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 8 THEN
									LET v_cApellido_M = TRIM(v_cApellido_M) || TRIM(v_cSegmento_8);
									LET v_iIdSegmento = 9;
									LET v_iBan = 1;
								END IF;
							END IF;
--**********************************************************************PRIMER NOMBRE
							LET v_iBan = 0;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_1));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 1 THEN
								IF v_cArtNom1 = '' OR v_cArtNom1 IS NULL THEN
									LET v_cArtNom1 = TRIM(v_cArtNom1) || TRIM(v_cSegmento_1);
								ELSE
									LET v_cArtNom1 = TRIM(v_cArtNom1) || ' ' || TRIM(v_cSegmento_1);
								END IF;
								
								LET v_iIdSegmento = 2;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 1 THEN
									LET v_cNombre1 = TRIM(v_cNombre1) || TRIM(v_cSegmento_1);
									LET v_iIdSegmento = 2;
									LET v_iBan = 1;			
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_2));
								
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 2 THEN
								IF v_cArtNom1 = '' OR v_cArtNom1 IS NULL THEN
									LET v_cArtNom1 = TRIM(v_cArtNom1) || TRIM(v_cSegmento_2);
								ELSE
									LET v_cArtNom1 = TRIM(v_cArtNom1) || ' ' || TRIM(v_cSegmento_2);
								END IF;
								
								LET v_iIdSegmento = 3;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 2 THEN
									LET v_cNombre1 = TRIM(v_cNombre1) || TRIM(v_cSegmento_2);
									LET v_iIdSegmento = 3;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_3));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 3 THEN
								IF v_cArtNom1 = '' OR v_cArtNom1 IS NULL THEN
									LET v_cArtNom1 = TRIM(v_cArtNom1) || TRIM(v_cSegmento_3);
								ELSE
									LET v_cArtNom1 = TRIM(v_cArtNom1) || ' ' || TRIM(v_cSegmento_3);
								END IF;
								
								LET v_iIdSegmento = 4;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 3 THEN
									LET v_cNombre1 = TRIM(v_cNombre1) || TRIM(v_cSegmento_3);
									LET v_iIdSegmento = 4;
									LET v_iBan = 1;			
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_4));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 4 THEN
								IF v_cArtNom1 = '' OR v_cArtNom1 IS NULL THEN
									LET v_cArtNom1 = TRIM(v_cArtNom1) || TRIM(v_cSegmento_4);
								ELSE
									LET v_cArtNom1 = TRIM(v_cArtNom1) || ' ' || TRIM(v_cSegmento_4);
								END IF;
								
								LET v_iIdSegmento = 5;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 4 THEN
									LET v_cNombre1 = TRIM(v_cNombre1) || TRIM(v_cSegmento_4);
									LET v_iIdSegmento = 5;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_5));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 5 THEN
								IF v_cArtNom1 = '' OR v_cArtNom1 IS NULL THEN
									LET v_cArtNom1 = TRIM(v_cArtNom1) || TRIM(v_cSegmento_5);
								ELSE
									LET v_cArtNom1 = TRIM(v_cArtNom1) || ' ' || TRIM(v_cSegmento_5);
								END IF;
								
								LET v_iIdSegmento = 6;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 5 THEN
									LET v_cNombre1 = TRIM(v_cNombre1) || TRIM(v_cSegmento_5);
									LET v_iIdSegmento = 6;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_6));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 6 THEN
								IF v_cArtNom1 = '' OR v_cArtNom1 IS NULL THEN
									LET v_cArtNom1 = TRIM(v_cArtNom1) || TRIM(v_cSegmento_6);
								ELSE
									LET v_cArtNom1 = TRIM(v_cArtNom1) || ' ' || TRIM(v_cSegmento_6);
								END IF;
								
								LET v_iIdSegmento = 7;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 6 THEN
									LET v_cNombre1 = TRIM(v_cNombre1) || TRIM(v_cSegmento_6);
									LET v_iIdSegmento = 7;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_7));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 7 THEN
								IF v_cArtNom1 = '' OR v_cArtNom1 IS NULL THEN
									LET v_cArtNom1 = TRIM(v_cArtNom1) || TRIM(v_cSegmento_7);
								ELSE
									LET v_cArtNom1 = TRIM(v_cArtNom1) || ' ' || TRIM(v_cSegmento_7);
								END IF;
								
								LET v_iIdSegmento = 8;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 7 THEN
									LET v_cNombre1 = TRIM(v_cNombre1) || TRIM(v_cSegmento_7);
									LET v_iIdSegmento = 8;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_8));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 8 THEN
								IF v_cArtNom1 = '' OR v_cArtNom1 IS NULL THEN
									LET v_cArtNom1 = TRIM(v_cArtNom1) || TRIM(v_cSegmento_8);
								ELSE
									LET v_cArtNom1 = TRIM(v_cArtNom1) || ' ' || TRIM(v_cSegmento_8);
								END IF;
								
								LET v_iIdSegmento = 9;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 8 THEN
									LET v_cNombre1 = TRIM(v_cNombre1) || TRIM(v_cSegmento_8);
									LET v_iIdSegmento = 9;
									LET v_iBan = 1;
								END IF;
							END IF;
--**********************************************************************SEGUNDO NOMBRE
							LET v_iBan = 0;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_1));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 1 THEN
								IF v_cArtNom2 = '' OR v_cArtNom2 IS NULL THEN
									LET v_cArtNom2 = TRIM(v_cArtNom2) || TRIM(v_cSegmento_1);
								ELSE
									LET v_cArtNom2 = TRIM(v_cArtNom2) || ' ' || TRIM(v_cSegmento_1);
								END IF;
								
								LET v_iIdSegmento = 2;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 1 THEN
									LET v_cNombre2 = TRIM(v_cNombre2) || TRIM(v_cSegmento_1);
									LET v_iIdSegmento = 2;
									LET v_iBan = 1;			
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_2));
								
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 2 THEN
								IF v_cArtNom2 = '' OR v_cArtNom2 IS NULL THEN
									LET v_cArtNom2 = TRIM(v_cArtNom2) || TRIM(v_cSegmento_2);
								ELSE
									LET v_cArtNom2 = TRIM(v_cArtNom2) || ' ' || TRIM(v_cSegmento_2);
								END IF;
								
								LET v_iIdSegmento = 3;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 2 THEN
									LET v_cNombre2 = TRIM(v_cNombre2) || TRIM(v_cSegmento_2);
									LET v_iIdSegmento = 3;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_3));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 3 THEN
								IF v_cArtNom2 = '' OR v_cArtNom2 IS NULL THEN
									LET v_cArtNom2 = TRIM(v_cArtNom2) || TRIM(v_cSegmento_3);
								ELSE
									LET v_cArtNom2 = TRIM(v_cArtNom2) || ' ' || TRIM(v_cSegmento_3);
								END IF;
								
								LET v_iIdSegmento = 4;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 3 THEN
									LET v_cNombre2 = TRIM(v_cNombre2) || TRIM(v_cSegmento_3);
									LET v_iIdSegmento = 4;
									LET v_iBan = 1;			
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_4));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 4 THEN
								IF v_cArtNom2 = '' OR v_cArtNom2 IS NULL THEN
									LET v_cArtNom2 = TRIM(v_cArtNom2) || TRIM(v_cSegmento_4);
								ELSE
									LET v_cArtNom2 = TRIM(v_cArtNom2) || ' ' || TRIM(v_cSegmento_4);
								END IF;
								
								LET v_iIdSegmento = 5;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 4 THEN
									LET v_cNombre2 = TRIM(v_cNombre2) || TRIM(v_cSegmento_4);
									LET v_iIdSegmento = 5;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_5));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 5 THEN
								IF v_cArtNom2 = '' OR v_cArtNom2 IS NULL THEN
									LET v_cArtNom2 = TRIM(v_cArtNom2) || TRIM(v_cSegmento_5);
								ELSE
									LET v_cArtNom2 = TRIM(v_cArtNom2) || ' ' || TRIM(v_cSegmento_5);
								END IF;
								
								LET v_iIdSegmento = 6;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 5 THEN
									LET v_cNombre2 = TRIM(v_cNombre2) || TRIM(v_cSegmento_5);
									LET v_iIdSegmento = 6;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_6));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 6 THEN
								IF v_cArtNom2 = '' OR v_cArtNom2 IS NULL THEN
									LET v_cArtNom2 = TRIM(v_cArtNom2) || TRIM(v_cSegmento_6);
								ELSE
									LET v_cArtNom2 = TRIM(v_cArtNom2) || ' ' || TRIM(v_cSegmento_6);
								END IF;
								
								LET v_iIdSegmento = 7;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 6 THEN
									LET v_cNombre2 = TRIM(v_cNombre2) || TRIM(v_cSegmento_6);
									LET v_iIdSegmento = 7;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_7));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 7 THEN
								IF v_cArtNom2 = '' OR v_cArtNom2 IS NULL THEN
									LET v_cArtNom2 = TRIM(v_cArtNom2) || TRIM(v_cSegmento_7);
								ELSE
									LET v_cArtNom2 = TRIM(v_cArtNom2) || ' ' || TRIM(v_cSegmento_7);
								END IF;
								
								LET v_iIdSegmento = 8;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 7 THEN
									LET v_cNombre2 = TRIM(v_cNombre2) || TRIM(v_cSegmento_7);
									LET v_iIdSegmento = 8;
									LET v_iBan = 1;
								END IF;
							END IF;
							
							SELECT id 
							INTO v_iId 
							FROM bdicred:"informix".sd_chi_cre_segnom_articulos 
							WHERE empresa = v_cEmpresa AND status = 1 AND articulo = UPPER(TRIM(v_cSegmento_8));
							
							IF v_iId > 0 AND v_iBan = 0 AND v_iIdSegmento <= 8 THEN
								IF v_cArtNom2 = '' OR v_cArtNom2 IS NULL THEN
									LET v_cArtNom2 = TRIM(v_cArtNom2) || TRIM(v_cSegmento_8);
								ELSE
									LET v_cArtNom2 = TRIM(v_cArtNom2) || ' ' || TRIM(v_cSegmento_8);
								END IF;
								
								LET v_iIdSegmento = 9;
							ELSE
								IF v_iBan = 0 AND v_iIdSegmento = 8 THEN
									LET v_cNombre2 = TRIM(v_cNombre2) || TRIM(v_cSegmento_8);
									LET v_iIdSegmento = 9;
									LET v_iBan = 1;
								END IF;
							END IF;
-- ****************************************************************************
-- *                        ARMADO DE RFC / CURP                              *
-- ****************************************************************************	
--**********************************************************************CURP
							LET v_cCurp_p1 = SUBSTR(v_cApellido_P, 1, 1);	--Primera letra del primer apellido.
							
							FOR v_i = 2 TO LENGTH(v_cApellido_P) - 1 --Primera vocal del primer apellido.
								LET v_cCurp_p2 = SUBSTR(v_cApellido_P, v_i, 1);
								IF v_cCurp_p2 IN ('a','e','i','o','u') OR v_cCurp_p2 IN ('A','E','I','O','U') THEN
									EXIT FOR;
								END IF;
							END FOR;
							
							LET v_cCurp_p3 = SUBSTR(v_cApellido_M, 1, 1);	--Primera letra del segundo apellido.
							LET v_cNombre2_aux = SUBSTR(v_cNombre2, 1, 1);
							
							IF v_cNombre2_aux = '' OR v_cNombre2_aux IS NULL THEN
								LET v_cCurp_p4 = SUBSTR(v_cNombre1, 1, 1);
							ELSE	--Primera letra del nombre: se tomará en cuenta el primer nombre (exceptuando los nombres compuestos cuando a estos se antepongan los nombres de MARÍA y JOSÉ). 
								IF UPPER(v_cNombre1) = 'MARIA' OR UPPER(v_cNombre1) = 'JOSE' THEN
									LET v_cCurp_p4 = v_cNombre2_aux;	--Ejemplo: Si se llama José Eduardo, tomará la letra E.
								ELSE
									LET v_cCurp_p4 = SUBSTR(v_cNombre1, 1, 1);	--Ejemplo: Si el nombre es Juan Francisco, se tomará la letra J.
								END IF;
							END IF;
							
							LET v_cCurp_p56 = SUBSTR(LPAD(YEAR(v_cFechaNac), 4, '0'), 3, 2);	--Año
							LET v_cCurp_p78 = LPAD(MONTH(v_cFechaNac), 2, '0');	--Mes
							LET v_cCurp_p910 = LPAD(DAY(v_cFechaNac), 2, '0');	--Dia
							
--							IF v_cGenero = 'H' OR v_cGenero = 'M' THEN --El sexo Hombre y Mujer (H/M)
--								LET v_cCurp_p11 = 'H';
--							ELSE
--								LET v_cCurp_p11 = 'M';
--							END IF;
--							
--							--Dos letras correspondientes a la entidad de nacimiento, en caso de haber nacido fuera del país, se marca como NE, (Nacido en el Extranjero)
--							SELECT abrev_corta
--							INTO v_cCurp_p1213
--							FROM sd_chi_cre_edos
--							WHERE empresa = '001'
--								AND abrev_larga = v_cEstado;
--								
--							IF v_cCurp_p1213 = '' OR v_cCurp_p1213 IS NULL THEN
--								LET v_cCurp_p1213 = '  ';
--							END IF;
--															
--							FOR v_i = 2 TO LENGTH(v_cApellido_P) - 1 --Primera consonante interna del primer apellido.
--								LET v_cCurp_p14 = SUBSTR(v_cApellido_P, v_i, 1);
--								IF v_cCurp_p14 NOT IN ('a','e','i','o','u') AND v_cCurp_p14 NOT IN ('A','E','I','O','U') THEN
--									EXIT FOR;
--								END IF;
--							END FOR;
--								
--							FOR v_i = 2 TO LENGTH(v_cApellido_M) - 1 --Primera consonante interna del segundo apellido.
--								LET v_cCurp_p15 = SUBSTR(v_cApellido_M, v_i, 1);
--								IF v_cCurp_p15 NOT IN ('a','e','i','o','u') AND v_cCurp_p15 NOT IN ('A','E','I','O','U') THEN
--									EXIT FOR;
--								END IF;
--							END FOR;
--								
--							FOR v_i = 2 TO LENGTH(v_cNombre1) - 1 --Primera consonante interna del nombre.
--								LET v_cCurp_p16 = SUBSTR(v_cNombre1, v_i, 1);
--								IF v_cCurp_p16 NOT IN ('a','e','i','o','u') AND v_cCurp_p16 NOT IN ('A','E','I','O','U') THEN
--									EXIT FOR;
--								END IF;
--							END FOR;			
--							
--							IF TO_NUMBER(LPAD(YEAR(v_cFechaNac), 4, '0')) < 2000 THEN --Homoclave Dígito, para evitar duplicaciones
--								LET v_cCurp_p17 = 0;
--							ELSE
--								LET v_cCurp_p17 = 1;
--							END IF;
							
							LET v_cCurpArmado = (TRIM(v_cCurp_p1) || TRIM(v_cCurp_p2) || TRIM(v_cCurp_p3) || TRIM(v_cCurp_p4) || TRIM(v_cCurp_p56) || 
								TRIM(v_cCurp_p78) || TRIM(v_cCurp_p910));
--								 || TRIM(v_cCurp_p11) || TRIM(v_cCurp_p1213) || TRIM(v_cCurp_p14) || 
--								TRIM(v_cCurp_p15) || TRIM(v_cCurp_p16) || TRIM(v_cCurp_p17));
					
--**********************************************************************RFC
--							LET v_cRFCArmado = (TRIM(v_cCurp_p1) || TRIM(v_cCurp_p2) || TRIM(v_cCurp_p3) || TRIM(v_cCurp_p4) || TRIM(v_cCurp_p56) || 
--								TRIM(v_cCurp_p78) || TRIM(v_cCurp_p910));
								
							IF v_cNombre1 IS NULL OR TRIM(v_cNombre1) = '' OR v_cSegmento_9 <> '' OR SUBSTR(v_cCURP, 1, 10) <> v_cCurpArmado THEN
--								SELECT monto_minimo, monto_maximo
--								INTO v_mMontoMin, v_mMontoMax
--								FROM bdicred:"informix".sd_chi_cre_rango_monto_producto
--								WHERE empresa = v_cEmpresa
--									AND producto = v_cProd
--									AND status = 1;
									
								LET v_iIdControl = v_iIdControl + 1;
								LET v_cNombre1 = v_cNombreCompleto;
								LET v_cApellido_P = '';
								LET v_cApellido_M = '';
								LET v_cNombre2 = '';
								LET v_sind_segnom_valido = '0';
									
--								IF v_cMontoCred >= v_mMontoMin AND v_cMontoCred <= v_mMontoMax THEN
--									LET v_cclave_proc = '3';
--									LET v_cclave_status = '1';
--									LET v_sind_fondeo_mont_prod = '1';
--								ELSE
								LET v_cclave_proc = '2';
								LET v_cclave_status = '3';
								LET v_sind_fondeo_mont_prod = '0';
--								END IF;
								
								INSERT INTO bdicred:"informix".sd_chi_cre_carga_consic_dia (
									id, empresa, nombre, fecha_nacimiento, rfc, 
									curp, tipo_residencia, estado_civil, genero, numero_dependientes, 
									direccion1, direccion2, colonia, delegacion, ciudad, 
									estado, codigo_postal, tipo_domicilio, num_credito, producto, 
									monto_credito, apell_paterno, apell_materno, nombre1, nombre2, 
									ind_segnom_valido, ind_fondeo_mont_prod, clave_proceso, clave_status, fecha_carga_sist, 
									fecha_reproceso, buro_status 
								) VALUES (
									v_iIdControl, v_cEmpresa, v_cNombreCompleto, v_cFechaNac, v_cRFC, 
									v_cCURP, v_cTipoResi, v_cEdoCivil, v_cGenero, v_cNumDep, 
									v_cDir1, v_cDir2, v_cColonia, v_cDelegacion, v_cCiudad, 
									v_cEstado, v_cCP, v_ctipo_dom, v_cNumCredito, v_cProd, 
									v_cMontoCred, v_cApellido_P, v_cApellido_M, v_cNombre1, v_cNombre2,
									v_sind_segnom_valido, v_sind_fondeo_mont_prod, v_cclave_proc, v_cclave_status, CURRENT, 
									'', 'NPP'
								);
							ELSE
								LET v_iIdControl = v_iIdControl + 1;
								LET v_cclave_proc = '1';
								LET v_cclave_status = '1';
								LET v_sind_segnom_valido = '1';
						
								INSERT INTO bdicred:"informix".sd_chi_cre_carga_consic_dia (
									id, empresa, nombre, fecha_nacimiento, rfc, 
									curp, tipo_residencia, estado_civil, genero, numero_dependientes, 
									direccion1, direccion2, colonia, delegacion, ciudad, 
									estado, codigo_postal, tipo_domicilio, num_credito, producto, 
									monto_credito, apell_paterno, apell_materno, nombre1, nombre2, 
									ind_segnom_valido, ind_fondeo_mont_prod, clave_proceso, clave_status, fecha_carga_sist, 
									fecha_reproceso, buro_status 
								) VALUES (
									v_iIdControl, v_cEmpresa, v_cNombreCompleto, v_cFechaNac, v_cRFC /*v_cRFCArmado*/, 
									v_cCURP/*v_cCurpArmado*/, v_cTipoResi, v_cEdoCivil, v_cGenero, v_cNumDep, 
									v_cDir1, v_cDir2, v_cColonia, v_cDelegacion, v_cCiudad, 
									v_cEstado, v_cCP, v_ctipo_dom, v_cNumCredito, v_cProd, 
									v_cMontoCred, 
									(CASE WHEN  v_cArtApe_P = '' OR v_cArtApe_P IS NULL THEN TRIM(v_cApellido_P) ELSE TRIM(v_cArtApe_P) || ' ' || TRIM(v_cApellido_P) END), 
									(CASE WHEN  v_cArtApe_M = '' OR v_cArtApe_M IS NULL THEN TRIM(v_cApellido_M) ELSE TRIM(v_cArtApe_M) || ' ' || TRIM(v_cApellido_M) END), 
									(CASE WHEN  v_cArtNom1 = '' OR v_cArtNom1 IS NULL THEN TRIM(v_cNombre1) ELSE TRIM(v_cArtNom1) || ' ' || TRIM(v_cNombre1) END), 
									(CASE WHEN  v_cArtNom2 = '' OR v_cArtNom2 IS NULL THEN TRIM(v_cNombre2) ELSE TRIM(v_cArtNom2) || ' ' || TRIM(v_cNombre2) END), 
									v_sind_segnom_valido, v_sind_fondeo_mont_prod, v_cclave_proc, v_cclave_status, CURRENT, 
									'', 'NPP'
								);
							END IF; --VALIDACIÓN DE NOMBRE VACIO
						END IF;					END IF;				END IF;			END IF;		END FOREACH;
-- ****************************************************************************
-- *                        ENVIO A CONSULTA BURÓ                             *
-- ****************************************************************************	
		EXECUTE PROCEDURE bdicred:"informix".sp_chi_cre_consulta_sic('P', v_iIdControlIni)
		INTO cod_ret;
		
		DELETE FROM bdicred:"informix".sd_chi_cre_carga_consic WHERE num_credito > 0;
		
		IF cod_ret <> '00000' THEN
			DELETE FROM bdicred:"informix".sd_chi_cre_carga_consic_dia WHERE empresa = '001' AND id > 0;
		END IF;
		
		RETURN cod_ret;	
	END	
END PROCEDURE;