CREATE PROCEDURE "informix".libromayaux_old(v_empresa CHAR(4), v_fechainicio DATE, v_fechafin DATE, v_ccmayorini CHAR(10),
							  v_ccsubini CHAR(10), v_ccsubsubini CHAR(10), v_ccssubsubini CHAR(10), v_ccsssubsubini CHAR(10),
							  v_sectorini CHAR(10), v_ccmayorfin CHAR(10), v_ccsubfin CHAR(10), v_ccsubsubfin CHAR(10),
							  v_ccssubsubfin CHAR(10), v_ccsssubsubfin CHAR(10), v_sectorfin CHAR(10), vusuario CHAR(10))

	DEFINE tempresa			CHAR(3);
	DEFINE tfecha_valida	DATE;
	DEFINE tfecha_captura	DATE;
	DEFINE tmes_dia			DATE;
	DEFINE tusuario			CHAR(8);
	DEFINE tnro_auxiliar	CHAR(12);
	DEFINE tauxiliar		CHAR(12);
	DEFINE auxiliar_cta		CHAR(12);
	DEFINE tcontrol_poliza	INTEGER;
	DEFINE tsecuencia		INTEGER;
	DEFINE tsucursal		CHAR(4);
	DEFINE tccosto_orig		CHAR(4);
	DEFINE tmonto			MONEY(18, 2);
	DEFINE tmoneda			CHAR(2);
	DEFINE tnaturaleza		CHAR(1);
	DEFINE tdescripcion		CHAR(50);
	DEFINE tciudad			CHAR(3);
	DEFINE tmoneda_sdo		CHAR(2);
	DEFINE tsucursal_sdo	CHAR(4);
	DEFINE tauxiliar_sdo	CHAR(12);
	DEFINE tciudad_sdo		CHAR(3);
	DEFINE tccmayor			CHAR(10);
	DEFINE tccsub			CHAR(10);
	DEFINE tccsubsub		CHAR(10);
	DEFINE tccssubsub		CHAR(10);
	DEFINE tccsssubsub		CHAR(10);
	DEFINE tsector			CHAR(10);
	DEFINE v_ccmayor		CHAR(10);
	DEFINE v_ccsub			CHAR(10);
	DEFINE v_ccsubsub		CHAR(10);
	DEFINE v_ccssubsub		CHAR(10);
	DEFINE v_ccsssubsub		CHAR(10);
	DEFINE v_sector			CHAR(10);
	DEFINE v_plaza			CHAR(3);
	DEFINE v_regional		CHAR(3);
	DEFINE tmovimientos		INTEGER;
	DEFINE tsdoaux			INTEGER;
	--DEFINE tsaldo_inicio_dia	int;
	--DEFINE tsaldo_fin_de_dia	int;
	DEFINE v_cuenta			CHAR(14);
	DEFINE v_cuenta1		decimal(14, 0);
	DEFINE v_rangoini		decimal(14, 0);
	DEFINE v_rangofin		DECIMAL(14, 0);
	DEFINE v_fechahoy		DATE;
	DEFINE v_mesinicio		INTEGER;
	DEFINE v_anoinicio		INTEGER;
	DEFINE v_mesfin			INTEGER;
	DEFINE v_anofin			INTEGER;
	DEFINE v_meshoy			INTEGER;
	DEFINE v_anohoy			INTEGER;
	DEFINE tsaldo_inicial	MONEY(18, 2);
	DEFINE tsaldo_final		MONEY(18, 2);
	DEFINE v_mensaje		VARCHAR(50);
	DEFINE sql_err			INTEGER;
	DEFINE isam_err			INTEGER;
	DEFINE error_info		VARCHAR(40);
	DEFINE v_sauxiliar1		CHAR(1);
	DEFINE v_sauxiliar		CHAR(1);
	DEFINE v_bExiste_tmp_ctacontable1	BOOLEAN;
	DEFINE v_bExiste_tmp_ctacontable	BOOLEAN;

	LET tempresa		= "";
	LET tfecha_valida	= CURRENT;
	LET tfecha_captura	= CURRENT;
	LET tusuario		= "";
	LET tnro_auxiliar	= "";
	LET tauxiliar		= "";
	LET tcontrol_poliza	= 0;
	LET tsecuencia		= 0;
	LET tsucursal		= "";
	LET tccosto_orig	= "";
	LET tmonto			= 0;
	LET tmoneda			= "";
	LET tnaturaleza		= "";
	LET tdescripcion	= "";
	LET tciudad			= "";
	LET tccmayor		= "";
	LET tccsub			= "";
	LET tccsubsub		= "";
	LET tccssubsub		= "";
	LET tccsssubsub		= "";
	LET tsector			= "";
	LET v_cuenta		= "";
	LET tsaldo_inicial	= 0;
	LET tsaldo_final	= 0;
	LET v_rangoini		= 0;
	LET v_rangofin		= 0;
	LET tmes_dia		= "";
	LET v_plaza			= "";
	LET v_regional		= "";
	LET tsdoaux			= 0;
	LET sql_err			= 0;
	LET isam_err		= 0;
	LET error_info		= "";
	LET v_sauxiliar1		= "";
	LET v_sauxiliar		= "";
	LET v_bExiste_tmp_ctacontable1 = 'F';
	LET v_bExiste_tmp_ctacontable = 'F';

	--**************************************************************************************************************
	--Creado por Fabiola Corrales Tapia 17/DIC/2006      
	--Modificado: FCT 25/JUN/2007                        
	--Modificado: Vladimir Felix  19/02/2009              
	--Modificado: Erick Zamora 03/03/2009, se valida el drop de las tablas temporales para evitar genere errores.	
	--Debug del Procedure                                
	--SET DEBUG FILE TO "/tmp/libromayaux"|| vusuario || ".out";	
	--TRACE ON;
	--***************************************************************************************************************

	DELETE FROM bdicont:co_libmadet WHERE usuario_rep = TRIM(vusuario);

	DELETE FROM bdicont:co_libsdoaux WHERE usuario = TRIM(vusuario);

	SET LOCK MODE TO WAIT;

	BEGIN
		ON EXCEPTION --SET sql_err, isam_err, error_info
			IF v_bExiste_tmp_ctacontable1 = 'T' THEN
				DROP TABLE bdicont:tmp_ctacontable1;
			END IF;
			
			IF v_bExiste_tmp_ctacontable = 'T' THEN
				DROP TABLE bdicont:tmp_ctacontable;
			END IF;

			--SET DEBUG FILE TO "calculafecha.err";
			--TRACE sql_err||" * "||isam_err|| " * "||error_info;
			RETURN;
		END EXCEPTION;
	
		-- NO UTILIZA INDICES
		SELECT fecha_hoy
		INTO v_fechahoy
		FROM bdicont:co_fechas
		WHERE empresa = v_empresa;

		LET v_mesinicio = MONTH(v_fechainicio);
		LET v_mesfin = MONTH(v_fechafin);
		LET v_meshoy = MONTH(v_fechahoy);

		LET v_anoinicio = YEAR(v_fechainicio);
		LET v_anofin = YEAR(v_fechafin);
		LET v_anohoy = YEAR(v_fechahoy);

		LET v_rangoini = TRIM(v_ccmayorini) || TRIM(v_ccsubini) || TRIM(v_ccsubsubini) || TRIM(v_ccssubsubini) || TRIM(v_ccsssubsubini) || TRIM(v_sectorini);
		LET v_rangofin = TRIM(v_ccmayorfin) || TRIM(v_ccsubfin) || TRIM(v_ccsubsubfin) || TRIM(v_ccssubsubfin) || TRIM(v_ccsssubsubfin) || TRIM(v_sectorfin);
		/*
		IF EXISTS(SELECT * FROM sysmaster:systabnames WHERE dbsname = 'bdicont' AND tabname = 'tmp_ctacontable1') THEN
			DROP TABLE bdicont:tmp_ctacontable1;
		END IF;
		*/
		CREATE TEMP TABLE bdicont:tmp_ctacontable1 (cuenta DECIMAL(14, 0), auxiliar CHAR(1));
		LET v_bExiste_tmp_ctacontable1 = 'T';
		
		FOREACH
			-- NO UTILIZA INDICES
			SELECT TRIM(ccmayor) || TRIM(ccsub) || TRIM(ccsubsub) || TRIM(ccssubsub) || TRIM(ccsssubsub) || TRIM(sector) AS cuenta,
			auxiliar
			INTO v_cuenta1, v_sauxiliar1
			FROM bdinteg:si_catalog
			WHERE
				empresa = v_empresa
				AND ccmayor BETWEEN v_ccmayorini AND v_ccmayorfin
				AND tipo_cuenta = 'D'
			ORDER BY cuenta

			INSERT INTO bdicont:tmp_ctacontable1 (cuenta, auxiliar) VALUES (v_cuenta1, v_sauxiliar1);
		END FOREACH;
		/*
		IF EXISTS(SELECT * FROM sysmaster:systabnames WHERE dbsname = 'bdicont' AND tabname = 'tmp_ctacontable') THEN
			DROP TABLE bdicont:tmp_ctacontable;
		END IF;
		*/
		CREATE TEMP TABLE bdicont:tmp_ctacontable (cuenta char(14), auxiliar CHAR(1));
		LET v_bExiste_tmp_ctacontable = 'T';
		
		FOREACH
			-- NO UTILIZA INDICES
			SELECT cuenta::char(14), auxiliar
			INTO v_cuenta, v_sauxiliar
			FROM bdicont:tmp_ctacontable1
			WHERE cuenta BETWEEN v_rangoini AND v_rangofin
			ORDER BY cuenta

			INSERT INTO bdicont:tmp_ctacontable (cuenta, auxiliar) VALUES (v_cuenta, v_sauxiliar);
		END FOREACH;

		FOREACH
			-- NO UTILIZA INDICES
			SELECT
				SUBSTRING(cuenta FROM 1 FOR 4), SUBSTRING(cuenta FROM 5 FOR 2), SUBSTRING(cuenta FROM 7 FOR 2),
				SUBSTRING(cuenta FROM 9 FOR 2), SUBSTRING(cuenta FROM 11 FOR 2), SUBSTRING(cuenta FROM 13 FOR 2),
				auxiliar
			INTO
				v_ccmayor, v_ccsub, v_ccsubsub, v_ccssubsub, v_ccsssubsub, v_sector, auxiliar_cta
			FROM bdicont:tmp_ctacontable
			--WHERE cuenta >= TRIM(v_ccmayorini)||TRIM(v_ccsubini)||TRIM(v_ccsubsubini)||
			--TRIM(v_ccssubsubini)||TRIM(v_ccsssubsubini)||TRIM(v_sectorini)
			--AND cuenta <= TRIM(v_ccmayorfin)||TRIM(v_ccsubfin)||TRIM(v_ccsubsubfin)||
			--TRIM(v_ccssubsubfin)||TRIM(v_ccsssubsubfin)||TRIM(v_sectorfin)

			/* NO UTILIZA INDICES
			SELECT auxiliar
			INTO auxiliar_cta
			FROM bdinteg:si_catalog
			WHERE
				empresa = v_empresa AND
				ccmayor = v_ccmayor AND
				ccsub = v_ccsub AND
				ccsubsub = v_ccsubsub AND
				ccssubsub = v_ccssubsub AND
				ccsssubsub = v_ccsssubsub AND
				sector = v_sector;
			*/
			--LET auxiliar_cta = auxiliar_cta;
			
			IF auxiliar_cta = 'N' THEN
				-- CONSULTA TABLAS ACTUALES
				IF v_mesfin = v_meshoy AND v_anofin = v_anohoy THEN
					SET ISOLATION TO DIRTY READ;
					
					FOREACH
						-- UTILIZA 1 DE 2 INDICES
						SELECT DISTINCT TRIM(sucursal), TRIM(moneda), TRIM(ciudad)
						INTO tsucursal_sdo, tmoneda_sdo, tciudad_sdo
						FROM bdicont:co_sdodias
						WHERE
							empresa = v_empresa AND
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							/*
							saldo_inicio_dia = saldo_inicio_dia AND
							cargos_dia = cargos_dia AND
							abonos_dia = abonos_dia AND
							saldo_fin_de_dia = saldo_fin_de_dia AND
							saldo_acumulado = saldo_acumulado AND
							*/
							mes_dia BETWEEN v_fechainicio AND v_fechafin
						
						-- UTILIZA 1 DE 2 INDICES
						SELECT MAX(mes_dia)
						INTO tmes_dia
						FROM bdicont:co_sdodias
						WHERE
							empresa = v_empresa AND
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							sucursal = tsucursal_sdo AND
							moneda = tmoneda_sdo AND
							ciudad = tciudad_sdo AND
							/*
							saldo_inicio_dia = saldo_inicio_dia AND
							cargos_dia = cargos_dia AND
							abonos_dia = abonos_dia AND
							saldo_fin_de_dia = saldo_fin_de_dia AND
							saldo_acumulado = saldo_acumulado AND
							*/
							mes_dia BETWEEN v_fechainicio AND v_fechafin;
						
						-- UTILIZA 1 DE 2 INDICES
						SELECT NVL(saldo_fin_de_dia, 0)
						INTO tsaldo_final
						FROM bdicont:co_sdodias
						WHERE
							empresa = v_empresa AND
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							sucursal = tsucursal_sdo AND
							moneda = tmoneda_sdo AND
							ciudad = tciudad_sdo AND
							/*
							saldo_inicio_dia = saldo_inicio_dia AND
							cargos_dia = cargos_dia AND
							abonos_dia = abonos_dia AND
							saldo_fin_de_dia = saldo_fin_de_dia AND
							saldo_acumulado = saldo_acumulado AND
							*/
							mes_dia = tmes_dia;
						
						LET v_cuenta= trim(v_ccmayor)||trim(v_ccsub)||trim(v_ccsubsub)|| trim(v_ccssubsub)||trim(v_ccsssubsub)||trim(v_sector);
						--LET v_cuenta = v_ccmayor || v_ccsub || v_ccsubsub || v_ccssubsub || v_ccsssubsub || v_sector;
						
						-- UTILIZA 1 DE 2 INDICES
						SELECT NVL(saldo_inicio_dia, 0)
						INTO tsaldo_inicial
						FROM bdicont:co_sdodias
						WHERE
							empresa = v_empresa AND
							moneda = tmoneda_sdo AND
							sucursal = tsucursal_sdo AND
							ciudad = tciudad_sdo AND
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							/*
							saldo_inicio_dia = saldo_inicio_dia AND
							cargos_dia = cargos_dia AND
							abonos_dia = abonos_dia AND
							saldo_fin_de_dia = saldo_fin_de_dia AND
							saldo_acumulado = saldo_acumulado AND
							*/
							mes_dia = v_fechainicio;
						
						IF tsaldo_inicial IS NULL THEN
							LET tsaldo_inicial = 0;
						END IF
						
						-- TABLA SIN INDICES
						SELECT TRIM(plaza)
						INTO v_plaza
						FROM bdinteg:si_sucursales
						WHERE empresa = v_empresa AND sucursal = tsucursal_sdo;
						
						-- TABLA SIN INDICE
						SELECT TRIM(regional)
						INTO v_regional
						FROM bdinteg:si_plazas
						WHERE empresa = v_empresa AND plaza = v_plaza;
						
						LET tciudad = v_regional;
						
						-- TABLA SIN INDICES
						SELECT COUNT(*)
						INTO tsdoaux
						FROM bdicont:co_libsdoaux
						WHERE
							empresa = v_empresa AND
							cuenta  = v_cuenta AND
							moneda = tmoneda_sdo AND
							sucursal = tsucursal_sdo AND
							ciudad = tciudad AND
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							usuario = vusuario;
						
						IF tsdoaux = 0 THEN
							INSERT INTO bdicont:co_libsdoaux
								(empresa, cuenta, ccmayor, ccsub, ccsubsub,
								ccssubsub, ccsssubsub, sector, ciudad, sucursal,
								moneda, fecha_valida, usuario, control_poliza, secuencia,
								nro_auxiliar, naturaleza, saldo_inicial, monto, saldo_final,
								descripcion_det, fecha_captura, ccosto_orig)
							VALUES
								(v_empresa, v_cuenta, v_ccmayor, v_ccsub, v_ccsubsub,
								v_ccssubsub, v_ccsssubsub, v_sector, tciudad, tsucursal_sdo,
								tmoneda_sdo, v_fechainicio, vusuario, '0', '0',
								'', '', tsaldo_inicial, '0',tsaldo_final,
								'', v_fechafin, '0000');
						ELSE
							UPDATE bdicont:co_libsdoaux SET
								(saldo_inicial, saldo_final) = (saldo_inicial + tsaldo_inicial, saldo_final + tsaldo_final)
							WHERE
								empresa = v_empresa AND
								cuenta = v_cuenta AND
								ccmayor = v_ccmayor AND
								ccsub = v_ccsub AND
								ccsubsub = v_ccsubsub AND
								ccssubsub = v_ccssubsub AND
								ccsssubsub = v_ccsssubsub AND
								sector = v_sector AND
								ciudad = tciudad AND
								sucursal = tsucursal_sdo AND
								moneda = tmoneda_sdo AND
								usuario = vusuario;
						END IF;
						
						FOREACH
							-- UTILIZA 0 DE 2 INDICES
							SELECT
								empresa, fecha_valida, fecha_captura, usuario, nro_auxiliar,
								control_poliza, secuencia, TRIM(sucursal), ccosto_orig, monto,
								moneda, naturaleza, descripcion, ciudad, ccmayor,
								ccsub, ccsubsub, ccssubsub, ccsssubsub, sector
							INTO
								tempresa, tfecha_valida, tfecha_captura, tusuario, tnro_auxiliar,
								tcontrol_poliza, tsecuencia, tsucursal, tccosto_orig, tmonto,
								tmoneda, tnaturaleza, tdescripcion, tciudad, tccmayor,
								tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector
							FROM bdicont:co_mensual
							WHERE
								empresa = v_empresa AND
								ccmayor = v_ccmayor AND
								ccsub = v_ccsub AND
								ccsubsub = v_ccsubsub AND
								ccssubsub = v_ccssubsub AND
								ccsssubsub = v_ccsssubsub AND
								sector = v_sector AND
								/*
								nro_auxiliar = nro_auxiliar AND
								naturaleza = naturaleza AND
								*/
								moneda = tmoneda_sdo AND
								sucursal = tsucursal_sdo AND
								ciudad = tciudad_sdo AND
								fecha_valida BETWEEN v_fechainicio AND v_fechafin
							
							-- TABLA SIN INDICES
							SELECT TRIM(plaza)
							INTO v_plaza
							FROM bdinteg:si_sucursales
							WHERE empresa = v_empresa AND sucursal = tsucursal;
							
							-- TABLA SIN INDICES
							SELECT TRIM(regional)
							INTO v_regional
							FROM bdinteg:si_plazas
							WHERE empresa = v_empresa AND plaza = v_plaza;
							
							LET tciudad = v_regional;
							--LET tsucursal = tsucursal;
							
							INSERT INTO bdicont:co_libmadet
								(empresa, cuenta, ccmayor, ccsub, ccsubsub,
								ccssubsub, ccsssubsub, sector, ciudad, sucursal,
								moneda, fecha_valida, usuario, control_poliza, secuencia,
								nro_auxiliar, naturaleza, saldo_inicial, monto, saldo_final,
								descripcion_det, fecha_captura, ccosto_orig, usuario_rep)
							VALUES
								(tempresa, v_cuenta, tccmayor, tccsub, tccsubsub,
								tccssubsub, tccsssubsub, tsector, tciudad, tsucursal,
								tmoneda, tfecha_valida, tusuario, tcontrol_poliza, tsecuencia,
								tnro_auxiliar, tnaturaleza, '0', tmonto, '0',
								tdescripcion, tfecha_captura, tccosto_orig, vusuario);
						END FOREACH;
						
						LET tmovimientos = 0;
						
						-- TABLA SIN INDICES
                        SELECT {+ INDEX(co_libmadet idxco_libmadet)} COUNT(*)
						INTO tmovimientos
						FROM bdicont:co_libmadet
						WHERE
                            sucursal = tsucursal_sdo AND 
                            ciudad = tciudad AND
                            ccmayor = v_ccmayor AND
                            ccsub = v_ccsub AND
                            ccsubsub = v_ccsubsub AND
                            ccssubsub = v_ccssubsub AND
                            ccsssubsub = v_ccsssubsub AND
                            sector = v_sector AND
                            moneda = tmoneda_sdo AND
                            empresa = v_empresa AND
                            usuario_rep = vusuario;
						
						IF tmovimientos = 0 THEN
							INSERT INTO bdicont:co_libmadet
								(empresa, cuenta, ccmayor, ccsub, ccsubsub,
								ccssubsub, ccsssubsub, sector, ciudad, sucursal,
								moneda, fecha_valida, usuario, control_poliza, secuencia,
								nro_auxiliar, naturaleza, saldo_inicial, monto, saldo_final,
								descripcion_det, fecha_captura, ccosto_orig, usuario_rep)
							VALUES
								(v_empresa, v_cuenta, v_ccmayor, v_ccsub, v_ccsubsub,
								v_ccssubsub, v_ccsssubsub, v_sector, tciudad, tsucursal_sdo,
								tmoneda_sdo, v_fechainicio, '', '0', '0',
								'', '', '0', '0', '0',
								'SIN MOVIMIENTOS', v_fechafin, '', vusuario);
						END IF;
					END FOREACH;
				END IF;
				
				-- CONSULTA TABLAS HISTORICAS
				IF v_mesinicio < v_meshoy OR v_anoinicio < v_anohoy THEN
					SET ISOLATION TO DIRTY READ;
					
					FOREACH
						-- UTILIZA 1 DE 1 INDICE
						SELECT DISTINCT
							TRIM(sucursal), TRIM(moneda), TRIM(ciudad)
						INTO
							tsucursal_sdo, tmoneda_sdo, tciudad_sdo
						FROM bdicont:co_histsdodias
						WHERE
							empresa = v_empresa AND
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							mes_dia BETWEEN v_fechainicio AND v_fechafin
						
						-- UTILIZA 1 DE 1 INDICE
						SELECT MAX(mes_dia)
						INTO tmes_dia
						FROM bdicont:co_histsdodias
						WHERE
							empresa = v_empresa AND
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							sucursal = tsucursal_sdo AND
							moneda = tmoneda_sdo AND
							ciudad = tciudad_sdo AND
							mes_dia BETWEEN v_fechainicio AND v_fechafin;
						
						-- UTILIZA 1 DE 1 INDICE
						SELECT NVL(saldo_fin_de_dia, 0)
						INTO tsaldo_final
						FROM bdicont:co_histsdodias
						WHERE
							empresa = v_empresa AND
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							mes_dia = tmes_dia AND
							sucursal = tsucursal_sdo AND
							moneda = tmoneda_sdo AND
							ciudad = tciudad_sdo;
						
						LET v_cuenta = TRIM(v_ccmayor) || TRIM(v_ccsub) || TRIM(v_ccsubsub)|| TRIM(v_ccssubsub) || TRIM(v_ccsssubsub) || TRIM(v_sector);
						--LET v_cuenta = v_ccmayor || v_ccsub || v_ccsubsub|| v_ccssubsub || v_ccsssubsub || v_sector;
						
						-- UTILIZA 1 DE 1 INDICE
						SELECT NVL(saldo_inicio_dia, 0)
						INTO tsaldo_inicial
						FROM bdicont:co_histsdodias
						WHERE
							empresa = v_empresa AND
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							mes_dia = v_fechainicio AND
							sucursal = tsucursal_sdo AND
							moneda = tmoneda_sdo AND
							ciudad = tciudad_sdo;
						
						IF tsaldo_inicial IS NULL THEN
							LET tsaldo_inicial = 0;
						END IF;
						
						-- NO UTILIZA INDICES
						SELECT TRIM(plaza)
						INTO v_plaza
						FROM bdinteg:si_sucursales
						WHERE empresa = v_empresa AND sucursal = tsucursal_sdo;
						
						-- NO UTILIZA INDICES
						SELECT TRIM(regional)
						INTO v_regional
						FROM bdinteg:si_plazas
						WHERE empresa = v_empresa AND plaza = v_plaza;
						
						LET tciudad = v_regional;
						
						-- NO UTILIZA INDICES
						SELECT COUNT(cuenta)
						INTO tsdoaux
						FROM bdicont:co_libsdoaux
						WHERE
							empresa = v_empresa AND
							cuenta  = v_cuenta AND
							moneda = tmoneda_sdo AND
							sucursal = tsucursal_sdo AND
							ciudad = tciudad AND
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							usuario = vusuario;
						
						IF tsdoaux = 0 THEN
							INSERT INTO bdicont:co_libsdoaux
								(empresa, cuenta, ccmayor, ccsub, ccsubsub,
								ccssubsub, ccsssubsub, sector, ciudad, sucursal,
								moneda, fecha_valida, usuario, control_poliza, secuencia,
								nro_auxiliar, naturaleza, saldo_inicial, monto, saldo_final,
								descripcion_det, fecha_captura, ccosto_orig)
							VALUES
								(v_empresa, v_cuenta, v_ccmayor, v_ccsub, v_ccsubsub,
								v_ccssubsub, v_ccsssubsub, v_sector, tciudad, tsucursal_sdo,
								tmoneda_sdo, v_fechainicio, vusuario, '0', '0',
								'', '', tsaldo_inicial, '0', tsaldo_final,
								'', v_fechafin, '0000');
						ELSE
							UPDATE bdicont:co_libsdoaux
							SET (saldo_inicial, saldo_final) = (saldo_inicial + tsaldo_inicial, saldo_final + tsaldo_final)
							WHERE
								empresa = v_empresa AND
								cuenta = v_cuenta AND
								ccmayor = v_ccmayor AND
								ccsub = v_ccsub AND
								ccsubsub = v_ccsubsub AND
								ccssubsub = v_ccssubsub AND
								ccsssubsub = v_ccsssubsub AND
								sector = v_sector AND
								ciudad = tciudad AND
								sucursal = tsucursal_sdo AND
								moneda = tmoneda_sdo AND
								usuario = vusuario;
						END IF;
						
						FOREACH
							-- UTILIZA 0 DE 1 INDICE
							SELECT
								empresa, fecha_valida, fecha_captura, usuario, nro_auxiliar,
								control_poliza, secuencia, sucursal, ccosto_orig, monto,
								moneda, naturaleza, descripcion, ciudad, ccmayor,
								ccsub, ccsubsub, ccssubsub, ccsssubsub, sector
							INTO
								tempresa, tfecha_valida, tfecha_captura, tusuario, tnro_auxiliar,
								tcontrol_poliza, tsecuencia, tsucursal, tccosto_orig, tmonto,
								tmoneda, tnaturaleza, tdescripcion, tciudad, tccmayor,
								tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector
							FROM bdicont:co_historico
							WHERE
								empresa = v_empresa AND
								ccmayor = v_ccmayor AND
								ccsub = v_ccsub AND
								ccsubsub = v_ccsubsub AND
								ccssubsub = v_ccssubsub AND
								ccsssubsub = v_ccsssubsub AND
								sector = v_sector AND
								/*
								nro_auxiliar = nro_auxiliar AND
								*/
								moneda = tmoneda_sdo AND
								sucursal = tsucursal_sdo AND
								ciudad = tciudad_sdo AND
								fecha_valida BETWEEN v_fechainicio AND v_fechafin
							
							-- NO UTILIZA INDICES
							SELECT TRIM(plaza)
							INTO v_plaza
							FROM bdinteg:si_sucursales
							WHERE empresa = v_empresa AND sucursal = tsucursal_sdo;
							
							-- NO UTILIZA INDICES
							SELECT TRIM(regional)
							INTO v_regional
							FROM bdinteg:si_plazas
							WHERE empresa = v_empresa AND plaza = v_plaza;
							
							LET tciudad = v_regional;
							--LET tciudad = tciudad;
							--LET tsucursal = tsucursal;
							
							INSERT INTO bdicont:co_libmadet
								(empresa, cuenta, ccmayor, ccsub, ccsubsub,
								ccssubsub, ccsssubsub, sector, ciudad, sucursal,
								moneda, fecha_valida, usuario, control_poliza, secuencia,
								nro_auxiliar, naturaleza, saldo_inicial, monto, saldo_final,
								descripcion_det, fecha_captura, ccosto_orig, usuario_rep)
							VALUES
								(tempresa, v_cuenta, tccmayor, tccsub, tccsubsub,
								tccssubsub, tccsssubsub, tsector, tciudad, tsucursal,
								tmoneda, tfecha_valida, tusuario, tcontrol_poliza, tsecuencia,
								tnro_auxiliar, tnaturaleza, '0', tmonto, '0',
								tdescripcion, tfecha_captura, tccosto_orig, vusuario);
						END FOREACH;
						
						LET tmovimientos = 0;
						
						-- NO UTILIZA INDICES
                        SELECT {+ INDEX(co_libmadet idxco_libmadet)} COUNT(*)
						INTO tmovimientos
						FROM bdicont:co_libmadet
						WHERE
                            sucursal = tsucursal_sdo AND 
                            ciudad = tciudad AND
                            ccmayor = v_ccmayor AND
                            ccsub = v_ccsub AND
                            ccsubsub = v_ccsubsub AND
                            ccssubsub = v_ccssubsub AND
                            ccsssubsub = v_ccsssubsub AND
                            sector = v_sector AND
                            moneda = tmoneda_sdo AND
                            empresa = v_empresa AND
                            usuario_rep = vusuario;
						
						-- NO UTILIZA INDICES
						SELECT TRIM(plaza)
						INTO v_plaza
						FROM bdinteg:si_sucursales
						WHERE empresa = v_empresa AND sucursal = tsucursal_sdo;
						
						-- NO UTILIZA INDICES
						SELECT regional
						INTO v_regional
						FROM bdinteg:si_plazas
						WHERE empresa = v_empresa AND plaza = v_plaza;
						
						LET tciudad = v_regional;
						--LET tciudad = tciudad;
						--LET tsucursal = tsucursal;
						
						IF tmovimientos = 0 THEN
							INSERT INTO bdicont:co_libmadet
								(empresa, cuenta, ccmayor, ccsub, ccsubsub,
								 ccssubsub, ccsssubsub, sector, ciudad, sucursal,
								 moneda, fecha_valida, usuario, control_poliza, secuencia,
								 nro_auxiliar, naturaleza, saldo_inicial, monto, saldo_final,
								 descripcion_det, fecha_captura, ccosto_orig, usuario_rep)
							VALUES
								(v_empresa, v_cuenta, v_ccmayor, v_ccsub, v_ccsubsub,
								 v_ccssubsub, v_ccsssubsub, v_sector, tciudad, tsucursal_sdo,
								 tmoneda_sdo, v_fechainicio, '', '0', '0',
								 '', '', '0', '0','0',
								 'SIN MOVIMIENTOS', v_fechafin, '', vusuario);
						END IF;
						
					END FOREACH;
				END IF;
			ELSE
				-- CONSULTA TABLAS ACTUALES DE AUXILIARES
				IF v_mesfin = v_meshoy AND v_anofin = v_anohoy THEN
					SET ISOLATION TO DIRTY READ;
					
					FOREACH
						-- UTILIZA 1 DE 2 INDICES
						SELECT DISTINCT TRIM(auxiliar), moneda, sucursal, ciudad
						INTO tauxiliar_sdo, tmoneda_sdo, tsucursal_sdo, tciudad_sdo
						FROM bdicont:co_diasaux
						WHERE
							empresa = v_empresa AND
							/*
							saldo_inicio_dia = saldo_inicio_dia AND
							cargos_dia = cargos_dia AND
							abonos_dia = abonos_dia AND
							saldo_fin_de_dia = saldo_fin_de_dia AND
							saldo_acumulado = saldo_acumulado AND
							*/
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							mes_dia BETWEEN v_fechainicio AND v_fechafin
						
						-- UTILIZA 1 DE 2 INDICES
						SELECT MAX(mes_dia)
						INTO tmes_dia
						FROM bdicont:co_diasaux
						WHERE
							empresa = v_empresa AND
							/*
							saldo_inicio_dia = saldo_inicio_dia AND
							cargos_dia = cargos_dia AND
							abonos_dia = abonos_dia AND
							saldo_fin_de_dia = saldo_fin_de_dia AND
							saldo_acumulado = saldo_acumulado AND
							*/
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							moneda = tmoneda_sdo AND
							sucursal = tsucursal_sdo AND
							ciudad = tciudad_sdo AND
							auxiliar = tauxiliar_sdo AND
							mes_dia BETWEEN v_fechainicio AND v_fechafin;
						
						-- UTILIZA 1 DE 2 INDICES
						SELECT NVL(saldo_fin_de_dia, 0)
						INTO tsaldo_final
						FROM bdicont:co_diasaux
						WHERE
							empresa = v_empresa AND
							/*
							saldo_inicio_dia = saldo_inicio_dia AND
							cargos_dia = cargos_dia AND
							abonos_dia = abonos_dia AND
							saldo_fin_de_dia = saldo_fin_de_dia AND
							saldo_acumulado = saldo_acumulado AND
							*/
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							moneda = tmoneda_sdo AND
							sucursal = tsucursal_sdo AND
							ciudad   = tciudad_sdo AND
							auxiliar = tauxiliar_sdo AND
							mes_dia = tmes_dia;
						
						LET v_cuenta = trim(v_ccmayor) || trim(v_ccsub) || trim(v_ccsubsub) || trim(v_ccssubsub) || trim(v_ccsssubsub) || trim(v_sector);
						--LET v_cuenta = v_ccmayor || v_ccsub || v_ccsubsub || v_ccssubsub || v_ccsssubsub || v_sector;
						
						-- UTILIZA 1 DE 2 INDICES
						SELECT NVL(saldo_inicio_dia, 0)
						INTO tsaldo_inicial
						FROM bdicont:co_diasaux
						WHERE
							empresa = v_empresa AND
							/*
							saldo_inicio_dia = saldo_inicio_dia AND
							cargos_dia = cargos_dia AND
							abonos_dia = abonos_dia AND
							saldo_fin_de_dia = saldo_fin_de_dia AND
							saldo_acumulado = saldo_acumulado AND
							*/
							moneda = tmoneda_sdo AND
							sucursal = tsucursal_sdo AND
							ciudad = tciudad_sdo AND
							auxiliar = tauxiliar_sdo AND
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							mes_dia = v_fechainicio;
						
						IF tsaldo_inicial IS NULL THEN
							LET tsaldo_inicial = 0;
						END IF
						
						-- NO UTILIZA INDICES
						SELECT TRIM(plaza)
						INTO v_plaza
						FROM bdinteg:si_sucursales
						WHERE empresa = v_empresa AND sucursal = tsucursal_sdo;
						
						-- NO UTILIZA INDICES
						SELECT TRIM(regional)
						INTO v_regional
						FROM bdinteg:si_plazas
						WHERE empresa = v_empresa AND plaza = v_plaza;
						
						LET tciudad = v_regional;
						
						-- NO UTILIZA INDICES
						SELECT COUNT(*)
						INTO tsdoaux
						FROM bdicont:co_libsdoaux
						WHERE
							empresa = v_empresa AND
							cuenta  = v_cuenta AND
							moneda = tmoneda_sdo AND
							sucursal = tsucursal_sdo AND
							ciudad = tciudad AND
							nro_auxiliar = tauxiliar_sdo AND
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							usuario = vusuario;
						
						IF tsdoaux = 0 THEN
							INSERT INTO bdicont:co_libsdoaux
								(empresa, cuenta, ccmayor, ccsub, ccsubsub,
								ccssubsub, ccsssubsub, sector, ciudad, sucursal,
								moneda, fecha_valida, usuario, control_poliza, secuencia,
								nro_auxiliar, naturaleza, saldo_inicial, monto, saldo_final,
								descripcion_det, fecha_captura, ccosto_orig)
							VALUES
								(v_empresa, v_cuenta, v_ccmayor, v_ccsub, v_ccsubsub,
								v_ccssubsub, v_ccsssubsub, v_sector, tciudad, tsucursal_sdo,
								tmoneda_sdo, v_fechainicio, vusuario, '0', '0',
								tauxiliar_sdo, '', tsaldo_inicial, '0', tsaldo_final,
								'',v_fechafin,
								'0000');
						ELSE
							UPDATE bdicont:co_libsdoaux
							SET (saldo_inicial,saldo_final) = (saldo_inicial + tsaldo_inicial, saldo_final + tsaldo_final)
							WHERE
								empresa = v_empresa AND
								cuenta = v_cuenta AND
								ccmayor = v_ccmayor AND
								ccsub = v_ccsub AND
								ccsubsub = v_ccsubsub AND
								ccssubsub = v_ccssubsub AND
								ccsssubsub = v_ccsssubsub AND
								sector = v_sector AND
								ciudad = tciudad AND
								sucursal = tsucursal_sdo AND
								moneda = tmoneda_sdo AND
								nro_auxiliar = tauxiliar_sdo AND
								usuario = vusuario;
						END IF;
						
						FOREACH
							-- UTILIZA 1 DE 2 INDICES
							SELECT
								empresa, fecha_valida, fecha_captura, usuario, nro_auxiliar,
								control_poliza, secuencia, sucursal, ccosto_orig, monto,
								moneda, naturaleza, descripcion, ciudad, ccmayor,
								ccsub, ccsubsub, ccssubsub, ccsssubsub, sector
							INTO
								tempresa, tfecha_valida, tfecha_captura, tusuario, tnro_auxiliar,
								tcontrol_poliza, tsecuencia, tsucursal, tccosto_orig, tmonto,
								tmoneda, tnaturaleza, tdescripcion, tciudad, tccmayor,
								tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector
							FROM bdicont:co_mensual
							WHERE
								empresa = v_empresa AND
								ccmayor = v_ccmayor AND
								ccsub = v_ccsub AND
								ccsubsub = v_ccsubsub AND
								ccssubsub = v_ccssubsub AND
								ccsssubsub = v_ccsssubsub AND
								sector = v_sector AND
								nro_auxiliar = tauxiliar_sdo AND
								moneda = tmoneda_sdo AND
								sucursal = tsucursal_sdo AND
								ciudad = tciudad_sdo AND
								/*
								naturaleza = naturaleza AND
								*/
								fecha_valida BETWEEN v_fechainicio AND v_fechafin
							
							-- NO UTILIZA INDICES
							SELECT TRIM(plaza)
							INTO v_plaza
							FROM bdinteg:si_sucursales
							WHERE empresa = v_empresa AND sucursal = tsucursal_sdo;
							
							-- NO UTILIZA INDICES
							SELECT regional
							INTO v_regional
							FROM bdinteg:si_plazas
							WHERE empresa = v_empresa AND plaza = v_plaza;
							
							LET tciudad = v_regional;
							
							INSERT INTO bdicont:co_libmadet
								(empresa, cuenta, ccmayor, ccsub, ccsubsub,
								ccssubsub, ccsssubsub, sector, ciudad, sucursal,
								moneda, fecha_valida, usuario, control_poliza, secuencia,
								nro_auxiliar, naturaleza, saldo_inicial, monto, saldo_final,
								descripcion_det, fecha_captura, ccosto_orig, usuario_rep)
							VALUES
								(tempresa, v_cuenta, tccmayor, tccsub, tccsubsub,
								tccssubsub, tccsssubsub, tsector, tciudad, tsucursal,
								tmoneda, tfecha_valida, tusuario, tcontrol_poliza, tsecuencia,
								tauxiliar_sdo, tnaturaleza, '0', tmonto, '0',
								tdescripcion, tfecha_captura, tccosto_orig, vusuario);
						END FOREACH;
						
						LET tmovimientos = 0;
						
						-- NO UTILIZA INDICES
						SELECT {+ INDEX(co_libmadet idxco_libmadet)} COUNT(*)
						INTO tmovimientos
						FROM bdicont:co_libmadet
						WHERE
                            sucursal = tsucursal_sdo AND 
                            ciudad = tciudad AND
                            ccmayor = v_ccmayor AND
                            ccsub = v_ccsub AND
                            ccsubsub = v_ccsubsub AND
                            ccssubsub = v_ccssubsub AND
                            ccsssubsub = v_ccsssubsub AND
                            sector = v_sector AND
                            moneda = tmoneda_sdo AND
                            empresa = v_empresa AND
                            usuario_rep = vusuario and
                            nro_auxiliar = tauxiliar_sdo; 

						-- NO UTILIZA INDICES
						SELECT TRIM(plaza)
						INTO v_plaza
						FROM bdinteg:si_sucursales
						WHERE empresa = v_empresa AND sucursal = tsucursal_sdo;
						
						-- NO UTILIZA INDICES
						SELECT regional
						INTO v_regional
						FROM bdinteg:si_plazas
						WHERE empresa = v_empresa AND plaza = v_plaza;
						
						LET tciudad = v_regional;
						
						IF tmovimientos = 0 THEN
							INSERT INTO bdicont:co_libmadet
								(empresa, cuenta, ccmayor, ccsub, ccsubsub,
								ccssubsub, ccsssubsub, sector, ciudad, sucursal,
								moneda, fecha_valida, usuario, control_poliza, secuencia,
								nro_auxiliar, naturaleza, saldo_inicial, monto, saldo_final,
								descripcion_det, fecha_captura, ccosto_orig, usuario_rep)
							VALUES
								(v_empresa, v_cuenta, v_ccmayor, v_ccsub, v_ccsubsub,
								v_ccssubsub, v_ccsssubsub, v_sector, tciudad, tsucursal_sdo,
								tmoneda_sdo, v_fechainicio, '', '0', '0',
								tauxiliar_sdo, '', '0', '0', '0',
								'SIN MOVIMIENTOS', v_fechafin, '', vusuario);
						END IF;
					END FOREACH;
				END IF;
				
				-- CONSULTA TABLAS HISTORICAS DE AUXILIARES
				IF v_mesinicio < v_meshoy OR v_anoinicio < v_anohoy THEN
					SET ISOLATION TO DIRTY READ;
					
					FOREACH
						-- UTILIZA 1 DE 1 INDICE
						SELECT DISTINCT TRIM(auxiliar), moneda, sucursal, ciudad
						INTO tauxiliar_sdo, tmoneda_sdo, tsucursal_sdo, tciudad_sdo
						FROM bdicont:co_histdiasaux
						WHERE
							empresa = v_empresa AND
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							mes_dia BETWEEN v_fechainicio AND v_fechafin
						
						-- UTILIZA 1 DE 1 INDICE
						SELECT MAX(mes_dia)
						INTO tmes_dia
						FROM bdicont:co_histdiasaux
						WHERE
							empresa = v_empresa AND
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							moneda = tmoneda_sdo AND
							sucursal = tsucursal_sdo AND
							ciudad = tciudad_sdo AND
							auxiliar = tauxiliar_sdo AND
							mes_dia BETWEEN v_fechainicio AND v_fechafin;
						
						-- UTILIZA 1 DE 1 INDICE
						SELECT NVL(saldo_fin_de_dia, 0)
						INTO tsaldo_final
						FROM bdicont:co_histdiasaux
						WHERE
							empresa = v_empresa AND
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							moneda = tmoneda_sdo AND
							sucursal = tsucursal_sdo AND
							ciudad = tciudad_sdo AND
							auxiliar = tauxiliar_sdo AND
							mes_dia = tmes_dia;
						
						LET v_cuenta= trim(v_ccmayor)||trim(v_ccsub)||trim(v_ccsubsub)|| trim(v_ccssubsub)||trim(v_ccsssubsub)||trim(v_sector);
						--LET v_cuenta = v_ccmayor || v_ccsub || v_ccsubsub || v_ccssubsub || v_ccsssubsub || v_sector;
						
						-- UTILIZA 1 DE 1 INDICE
						SELECT NVL(saldo_inicio_dia, 0)
						INTO tsaldo_inicial
						FROM bdicont:co_histdiasaux
						WHERE
							empresa = v_empresa AND
							moneda = tmoneda_sdo AND
							sucursal = tsucursal_sdo AND
							ciudad = tciudad_sdo AND
							auxiliar = tauxiliar_sdo AND
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							mes_dia = v_fechainicio;
						
						IF tsaldo_inicial IS NULL THEN
							LET tsaldo_inicial = 0;
						END IF
						
						-- NO UTILIZA INDICES
						SELECT TRIM(plaza)
						INTO v_plaza
						FROM bdinteg:si_sucursales
						WHERE empresa = v_empresa AND sucursal = tsucursal_sdo;
						
						-- NO UTILIZA INDICES
						SELECT TRIM(regional)
						INTO v_regional
						FROM bdinteg:si_plazas
						WHERE empresa = v_empresa AND plaza = v_plaza;
						
						LET tciudad = v_regional;
						
						-- NO UTILIZA INDICES
						SELECT COUNT(*)
						INTO tsdoaux
						FROM bdicont:co_libsdoaux
						WHERE
							empresa = v_empresa AND
							cuenta = v_cuenta AND
							moneda = tmoneda_sdo AND
							sucursal = tsucursal_sdo AND
							nro_auxiliar = tauxiliar_sdo AND
							ciudad = tciudad AND
							ccmayor = v_ccmayor AND
							ccsub = v_ccsub AND
							ccsubsub = v_ccsubsub AND
							ccssubsub = v_ccssubsub AND
							ccsssubsub = v_ccsssubsub AND
							sector = v_sector AND
							usuario = vusuario;
						
						IF tsdoaux = 0 THEN
							INSERT INTO bdicont:co_libsdoaux
								(empresa, cuenta, ccmayor, ccsub, ccsubsub,
								ccssubsub, ccsssubsub, sector, ciudad, sucursal,
								moneda, fecha_valida, usuario, control_poliza, secuencia,
								nro_auxiliar, naturaleza, saldo_inicial, monto, saldo_final,
								descripcion_det, fecha_captura, ccosto_orig)
							VALUES
								(v_empresa, v_cuenta, v_ccmayor, v_ccsub, v_ccsubsub,
								v_ccssubsub, v_ccsssubsub, v_sector, tciudad, tsucursal_sdo,
								tmoneda_sdo, v_fechainicio, vusuario, '0', '0',
								tauxiliar_sdo, '', tsaldo_inicial, '0', tsaldo_final,
								'', v_fechafin, '0000');
						ELSE
							UPDATE bdicont:co_libsdoaux
							SET (saldo_inicial,saldo_final) = (saldo_inicial + tsaldo_inicial, saldo_final + tsaldo_final)
							WHERE
								empresa = v_empresa AND
								cuenta = v_cuenta AND
								ccmayor = v_ccmayor AND
								ccsub = v_ccsub AND
								ccsubsub = v_ccsubsub AND
								ccssubsub = v_ccssubsub AND
								ccsssubsub = v_ccsssubsub AND
								sector = v_sector AND
								ciudad = tciudad AND
								sucursal = tsucursal_sdo AND
								moneda = tmoneda_sdo AND
								nro_auxiliar = tauxiliar_sdo AND
								usuario = vusuario;
						END IF;
						
						FOREACH
							-- UTILIZA 1 DE 1 INDICE
							SELECT
								empresa, fecha_valida, fecha_captura, usuario, nro_auxiliar,
								control_poliza, secuencia, sucursal, ccosto_orig, monto,
								moneda, naturaleza, descripcion, ciudad, ccmayor,
								ccsub, ccsubsub, ccssubsub, ccsssubsub, sector
							INTO
								tempresa, tfecha_valida, tfecha_captura, tusuario, tnro_auxiliar,
								tcontrol_poliza, tsecuencia, tsucursal, tccosto_orig, tmonto,
								tmoneda, tnaturaleza, tdescripcion, tciudad, tccmayor,
								tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector
							FROM bdicont:co_historico
							WHERE
								empresa = v_empresa AND
								moneda = tmoneda_sdo AND
								sucursal = tsucursal_sdo AND
								ciudad = tciudad_sdo AND
								nro_auxiliar = tauxiliar_sdo AND
								ccmayor = v_ccmayor AND
								ccsub = v_ccsub AND
								ccsubsub = v_ccsubsub AND
								ccssubsub = v_ccssubsub AND
								ccsssubsub = v_ccsssubsub AND
								sector = v_sector AND
								fecha_valida BETWEEN v_fechainicio and v_fechafin
							
							-- NO UTILIZA INDICES
							SELECT TRIM(plaza)
							INTO v_plaza
							FROM bdinteg:si_sucursales
							WHERE empresa = v_empresa AND sucursal = tsucursal_sdo;
							
							-- NO UTILIZA INDICES
							SELECT TRIM(regional)
							INTO v_regional
							FROM bdinteg:si_plazas
							WHERE empresa = v_empresa AND plaza = v_plaza;
							
							LET tciudad = v_regional;
							
							INSERT INTO bdicont:co_libmadet
								(empresa, cuenta, ccmayor, ccsub, ccsubsub,
								ccssubsub, ccsssubsub, sector, ciudad, sucursal,
								moneda, fecha_valida, usuario, control_poliza, secuencia,
								nro_auxiliar, naturaleza, saldo_inicial, monto, saldo_final,
								descripcion_det, fecha_captura, ccosto_orig, usuario_rep)
							VALUES
								(tempresa, v_cuenta, tccmayor, tccsub, tccsubsub,
								tccssubsub, tccsssubsub, tsector, tciudad, tsucursal,
								tmoneda, tfecha_valida, tusuario, tcontrol_poliza, tsecuencia,
								tauxiliar_sdo, tnaturaleza, '0', tmonto, '0',
								tdescripcion, tfecha_captura, tccosto_orig, vusuario);
						END FOREACH;
						
						LET tmovimientos = 0;
						
						-- NO UTILIZA INDICES
						SELECT {+ INDEX(co_libmadet idxco_libmadet)} COUNT(*)
						INTO tmovimientos
						FROM bdicont:co_libmadet
						WHERE
                            sucursal = tsucursal_sdo AND 
                            ciudad = tciudad AND
                            ccmayor = v_ccmayor AND
                            ccsub = v_ccsub AND
                            ccsubsub = v_ccsubsub AND
                            ccssubsub = v_ccssubsub AND
                            ccsssubsub = v_ccsssubsub AND
                            sector = v_sector AND
                            moneda = tmoneda_sdo AND
                            empresa = v_empresa AND
                            usuario_rep = vusuario and
                            nro_auxiliar = tauxiliar_sdo;   

						IF tmovimientos = 0 THEN
							INSERT INTO bdicont:co_libmadet
								(empresa, cuenta, ccmayor, ccsub, ccsubsub,
								ccssubsub, ccsssubsub, sector, ciudad, sucursal,
								moneda, fecha_valida, usuario, control_poliza, secuencia,
								nro_auxiliar, naturaleza, saldo_inicial, monto, saldo_final,
								descripcion_det, fecha_captura, ccosto_orig, usuario_rep)
							VALUES
								(v_empresa, v_cuenta, v_ccmayor, v_ccsub, v_ccsubsub,
								v_ccssubsub, v_ccsssubsub, v_sector, tciudad, tsucursal_sdo,
								tmoneda_sdo, v_fechainicio, '', '0', '0',
								tauxiliar_sdo, '', '0', '0', '0',
								'SIN MOVIMIENTOS', v_fechafin, '', vusuario);
						END IF;
					END FOREACH;
				END IF;
			END IF;
		END FOREACH;
		--IF EXISTS(SELECT * FROM sysmaster:systabnames WHERE dbsname = 'bdicont' AND tabname = 'tmp_ctacontable') THEN
			DROP TABLE bdicont:tmp_ctacontable;
		--END IF;
		
		--IF EXISTS(SELECT * FROM sysmaster:systabnames WHERE dbsname = 'bdicont' AND tabname = 'tmp_ctacontable1') THEN
			DROP TABLE bdicont:tmp_ctacontable1;
		--END IF;		
		
	END;
END PROCEDURE;