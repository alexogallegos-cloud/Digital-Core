CREATE PROCEDURE "informix".sp_chi_cre_result_consulta_sic (
	p_cCodProc CHAR(1), p_iIdInicial INTEGER
) RETURNING CHAR(5) as codigo_retorno;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	--Creado por: Isaac Flores Ruiz
	--Fecha de creación: 23/03/2021
	--Peticion: 
	-------------------------------------------------------------------------------------
	-- Peticion: Hipotecario Infonavit - Actualización a reporte de consulta sics y montos límites de créditos
	-- Modificado por: Miguel Alejandro Sánchez Mojica
	-- Fecha de modificación: 11/01/2022
	-- Modificación: Se modifica las consultas encargadas de extraer la información para los reportes y se agregan dos columnas a los reportes de resultotal
	-- BD: bdiburo
	-- ID Rational:
	-------------------------------------------------------------------------------------
	-- Peticion: Hipotecario Infonavit - 
	-- Modificado por: Isaac Flores Ruiz
	-- Fecha de modificación: 11/01/2022
	-- Modificación: 
	-- BD: bdicred
	-- ID Rational:
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
	DEFINE		v_iid                   INTEGER;
	DEFINE		v_sind_validado         SMALLINT;
	DEFINE		v_sind_listas_negras    SMALLINT;
	DEFINE		v_cnombre_aux           CHAR(104);
	DEFINE		v_cnombre_completo      CHAR(104);
	DEFINE		v_capellido_p           CHAR(26);
	DEFINE		v_capellido_m           CHAR(26);
	DEFINE		v_cnombre1              CHAR(26);
	DEFINE		v_cnombre2              CHAR(26);
	DEFINE		v_cfecha_nac            CHAR(10);
	DEFINE		v_crfc                  CHAR(13);
	DEFINE		v_ccurp                 CHAR(18);
	DEFINE		v_ctipo_resi            CHAR(1);
	DEFINE		v_cedo_civil            CHAR(1);
	DEFINE		v_cgenero               CHAR(1);
	DEFINE		v_cnum_dep              CHAR(2);
	DEFINE		v_cdir1                 CHAR(40);
	DEFINE		v_cdir2                 CHAR(40);
	DEFINE		v_ccolonia              CHAR(40);
	DEFINE		v_cdelegacion           CHAR(40);
	DEFINE		v_cciudad               CHAR(40);
	DEFINE		v_cestado               CHAR(30);
	DEFINE		v_ccp                   CHAR(5);
	DEFINE		v_ctipo_dom             CHAR(1);
	DEFINE		v_cnum_credito          CHAR(25);
	DEFINE		v_cprod                 CHAR(4);
	DEFINE		v_cmonto_cred           MONEY(18, 2);
	DEFINE		v_cfecha_carga          DATE;
	DEFINE		v_cempresa              CHAR(3);
	DEFINE		v_sind_segnom_valido    CHAR(1);
	DEFINE		v_sind_fondeo_mont_prod CHAR(1);
	DEFINE		v_cclave_proc           CHAR(1);
	DEFINE		v_cclave_status         CHAR(1);
	DEFINE		v_sfondeo               SMALLINT;
	DEFINE		v_sclastat              SMALLINT;
	DEFINE		v_cmotivo               CHAR(30);
	DEFINE		v_cdescsta              CHAR(30);
	DEFINE		v_mop              		CHAR(2);
	DEFINE		v_rechazo_monto         INTEGER;
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES RUTAS                        *
-- ****************************************************************************
	DEFINE		cRuta					CHAR(100);
	DEFINE		cSQL					CHAR(1000);
	DEFINE		cDia					CHAR(2);
	DEFINE		cMes					CHAR(2);
	DEFINE		cYear					CHAR(4);
	DEFINE		cArchivoHito			CHAR(100);
	DEFINE		cArchivoUsr				CHAR(100);
	DEFINE		cArchivoRepHito			CHAR(100);
	DEFINE		cArchivoRepUsr			CHAR(100);
	DEFINE		cNombreArchivo			CHAR(100);
	DEFINE		cNombreArchivo2			CHAR(100);
	
	DEFINE 		vCodUdi       			CHAR(2);
	DEFINE 		vCodUs        			CHAR(2);
	DEFINE 		vclase        			CHAR(1);
	DEFINE 		vTpCambioUdi  			DECIMAL(14,6);
	DEFINE 		vTpCambioUs   			DECIMAL(14,6);
	DEFINE 		vMaxMtoUdi    			DECIMAL(14,2);
	DEFINE 		vFechaHoy     			DATE;
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
	LET			v_iid                   = 0;
	LET			v_sind_validado         = 0;
	LET			v_sind_listas_negras    = 0;
	LET			v_cnombre_aux           = '';
	LET			v_cnombre_completo      = '';
	LET			v_capellido_p           = '';
	LET			v_capellido_m           = '';
	LET			v_cnombre1              = '';
	LET			v_cnombre2              = '';
	LET			v_cfecha_nac            = '';
	LET			v_crfc                  = '';
	LET			v_ccurp                 = '';
	LET			v_ctipo_resi            = '';
	LET			v_cedo_civil            = '';
	LET			v_cgenero               = '';
	LET			v_cnum_dep              = '';
	LET			v_cdir1                 = '';
	LET			v_cdir2                 = '';
	LET			v_ccolonia              = '';
	LET			v_cdelegacion           = '';
	LET			v_cciudad               = '';
	LET			v_cestado               = '';
	LET			v_ccp                   = '';
	LET			v_ctipo_dom             = '';
	LET			v_cnum_credito          = '';
	LET			v_cprod                 = '';
	LET			v_cmonto_cred           = 0.0;
	LET			v_cempresa              = '001';
	LET			v_sind_segnom_valido    = '0';
	LET			v_sind_fondeo_mont_prod = '0';
	LET			v_cclave_proc           = '0';
	LET			v_cclave_status         = '0';
	LET			v_sfondeo               = 0;
	LET			v_sclastat              = 0;
	LET			v_cmotivo               = '';
	LET			v_cdescsta              = '';
	
	LET 		vCodUdi       			= '0';
	LET 		vCodUs        			= '0';
	LET 		vTpCambioUdi  			= 0.0;
	LET 		vTpCambioUs   			= 0.0;
	LET 		vMaxMtoUdi    			= 0.0;
	LET 		vFechaHoy     			= DATE(1);
-- ****************************************************************************
-- *                  INICIALIZACION DE VARIABLES RUTAS                       *
-- ****************************************************************************
	LET			cRuta		 			= "/RESPALDOSNEW/hipotecario_infonavit/sics/";
	LET			cSQL					= "";
	LET			cDia					= LPAD(DAY(DATE(1)), 2, '0');
	LET			cMes					= LPAD(MONTH(DATE(1)), 2, '0');
	LET			cYear					= LPAD(YEAR(DATE(1)), 4, '0');
	LET			cArchivoHito			= "chi_cre_resultotal_consulta_sic_";
	LET			cArchivoUsr			    = "chi_cre_valiresult_consulta_sic_";
	LET			cArchivoRepHito			= "chi_cre_resultotal_reprocesa_consic_";
	LET			cArchivoRepUsr			= "chi_cre_valiresult_reprocesa_consic_";
	LET			cNombreArchivo			= "";
	LET			cNombreArchivo2			= "";
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

	BEGIN
		ON EXCEPTION SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '11111';	
				RETURN cod_ret;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-668) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '22222';		
				LET mensaje_ret = 'VERIFICAR RUTA DEL ARCHIVO';
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-1207) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '33333';		
				LET mensaje_ret = 'VERIFICAR TIPOS DE DATOS O LONGITUDES';
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-268) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-691) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-391) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '55555';		
				LET mensaje_ret = 'VERIFICAR CAMPOS, INSERCIÓN DE NULOS';
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-846) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '66666';		
				LET mensaje_ret = 'NÚMERO DE VALORES NO ES IGUAL AL NUMERO DE COLUMNAS';
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--*****************************************************************
		--*						Debug del Procedure                     --*        
		--*****************************************************************
		--SET DEBUG FILE TO '/RESPALDOSNEW/hipotecario_infonavit/sics/sp_chi_cre_result_consulta_sic.out';
		--TRACE ON;                                                     --*
		
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	
		SELECT LPAD(YEAR(fecha_hoy), 4, '0'), 
			LPAD(MONTH(fecha_hoy), 2, '0'), 
			LPAD(DAY(fecha_hoy), 2, '0')
			, fecha_hoy
		INTO cYear, cMes, cDia, vFechaHoy
		FROM bdicred:sd_fechas 
		WHERE empresa = v_cempresa;

			
-- ****************************************************************************
-- *                                TIPO DE DIVISA                            *
-- ****************************************************************************	
			SELECT TRIM(valor) 
				INTO vCodUdi
				FROM bdinteg:si_param
			WHERE empresa = v_cempresa
				AND cod_param = 16;

			SELECT TRIM(valor) 
				INTO vCodUs
				FROM bdinteg:si_param
			WHERE empresa = v_cempresa
				AND cod_param = 17;
			   
			SELECT TRIM(valor) 
			INTO vClase
			FROM bdicred:sd_param
			WHERE empresa = v_cempresa
				AND cod_param = '336';
		 
			EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(v_cempresa, vFechaHoy,vCodUdi,vClase,'0')
			INTO cod_ret,vTpCambioUdi;

			IF cod_ret<>'00000' THEN
			  RETURN cod_ret;
			END IF;

			EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(v_cempresa, vFechaHoy,vCodUs,vClase,'1')
			INTO cod_ret,vTpCambioUs;

			IF cod_ret<>'00000' THEN
			  RETURN cod_ret;
			END IF;

			SELECT valor 
				INTO vMaxMtoUdi
				FROM bdisolic:ss_param
			WHERE empresa = v_cempresa
				AND secuencia = "309";
-- ****************************************************************************
-- *                       ARCHIVOS PROCESAMIENTO                             *
-- ****************************************************************************	
		IF p_ccodproc = 'P' THEN
			LET cNombreArchivo = TRIM(cArchivoHito) || cYear || cMes || cDia || '.xls ';
			LET cSQL = ' echo "NOMBRE	FECHA DE NACIMIENTO	RFC	CURP	TIPO DE RESIDENCIA	ESTADO CIVIL	GENERO	NUMERO DE DEPENDIENTES	DIRECCION1	DIRECCION2	COLONIA	DELEGACION	CIUDAD	ESTADO	CODIGO POSTAL	TIPO DOMICILIO	num_credito	PRODUCTO	MONTO CREDITO	FONDEO	MOTIVO	APELLIDO PATERNO	APELLIDO MATERNO 	NOMBRE1	NOMBRE2	MOP	RECHAZO POR MONTO' ||
				"" || '">'||TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM TRIM(cSQL);
			
			LET cSQL = 'chmod 777 '|| TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM cSQL;
			
			LET cNombreArchivo2 = TRIM(cArchivoUsr) || cYear || cMes || cDia || '.xls ';
			LET cSQL = ' echo "ID REGISTRO	NOMBRE	FECHA DE NACIMIENTO	RFC	CURP	TIPO DE RESIDENCIA	ESTADO CIVIL	GENERO	NUMERO DE DEPENDIENTES	DIRECCION1	DIRECCION2	COLONIA	DELEGACION	CIUDAD	ESTADO	CODIGO POSTAL	TIPO DOMICILIO	num_credito	PRODUCTO	MONTO CREDITO	FONDEO	MOTIVO	APELLIDO PATERNO	APELLIDO MATERNO 	NOMBRE1	NOMBRE2' ||
				"" || '">'||TRIM(cRuta)|| TRIM(cNombreArchivo2);
			SYSTEM TRIM(cSQL);
			
			LET cSQL = 'chmod 777 '|| TRIM(cRuta)|| TRIM(cNombreArchivo2);
			SYSTEM cSQL;
-- ****************************************************************************
-- *                     GENERACIÓN DE REPORTE TOTAL                          *
-- ****************************************************************************	
			FOREACH WITH HOLD
				SELECT 		id, nombre, fecha_nacimiento, rfc, curp, tipo_residencia, 
							estado_civil, genero, numero_dependientes, direccion1, NVL(direccion2, ''), 
							colonia, NVL(delegacion, ''), ciudad, NVL(descripcion, ''), codigo_postal, 
							tipo_domicilio, num_credito, producto, monto_credito, NVL(apell_paterno, ''), 
							NVL(apell_materno, ''), nombre1, NVL(nombre2, '')
							,clave 
							,msn,
							NVL(MOP, ''), id_prod
				INTO 		v_iid, v_cnombre_completo, v_cfecha_nac, v_crfc, v_ccurp, v_ctipo_resi, 
							v_cedo_civil, v_cgenero, v_cnum_dep, v_cdir1, v_cdir2, 
							v_ccolonia, v_cdelegacion, v_cciudad, v_cestado, v_ccp, 
							v_ctipo_dom, v_cnum_credito, v_cprod, v_cmonto_cred, v_capellido_p, 
							v_capellido_m, v_cnombre1, v_cnombre2, v_sclastat, v_cmotivo,
							v_mop, v_rechazo_monto
				FROM 		(SELECT 		A.id, A.nombre, A.fecha_nacimiento, A.rfc, A.curp, A.tipo_residencia, 
								A.estado_civil, A.genero, A.numero_dependientes, A.direccion1, A.direccion2, 
								A.colonia, A.delegacion, A.ciudad, C.descripcion, A.codigo_postal, 
								A.tipo_domicilio, A.num_credito, A.producto, A.monto_credito, A.apell_paterno, 
								A.apell_materno, A.nombre1, A.nombre2
								,(CASE 
											WHEN ((A.clave_proceso = '2' OR A.clave_proceso = '3') AND A.clave_status = '3') 
												THEN '3'
											WHEN (((A.clave_proceso = '2' OR A.clave_proceso = '3') AND (A.clave_status = '1' 
													OR (A.clave_status = 0 AND NVL(D.MOP_HISTORICO,'') <> '99' AND NVL(D.MOP,'') <> '99'))))
												THEN '1' 
											WHEN ((A.clave_proceso = '1' OR A.clave_proceso = '2') AND A.clave_status = '0') 
												THEN '0'
											ELSE '0'
										END) AS clave
								,TRIM(CASE 
											WHEN ((A.clave_proceso = '1' OR A.clave_proceso = '2' OR A.clave_proceso = '3') AND A.clave_status = '3') 
												THEN TRIM(B.descripcion_status)
											WHEN (((A.clave_proceso = '2' OR A.clave_proceso = '3') AND (A.clave_status = '1' 
													OR (A.clave_status = 0 AND NVL(D.MOP_HISTORICO,'') <> '99' AND NVL(D.MOP,'') <> '99'))))
												THEN '' 
											WHEN ((A.clave_proceso = '1' OR A.clave_proceso = '2') AND A.clave_status = '0') 
												THEN TRIM(B.descripcion_proceso)
											ELSE ''
											END) AS msn,
								D.MOP, (CASE WHEN A.monto_credito >= E.monto_minimo AND A.monto_credito <= E.monto_maximo THEN 0 ELSE 1 END) AS id_prod
							FROM bdicred:"informix".sd_chi_cre_carga_consic_dia A
							INNER JOIN 	bdicred:"informix".sd_chi_cre_status_procesos_segsic B ON A.empresa = B.empresa AND A.clave_proceso = B.clave_proceso AND A.clave_status = B.clave_status			
							LEFT JOIN 	bdicred:"informix".sd_chi_cre_edos C ON A.empresa = C.empresa AND A.estado = C.abrev_larga
							LEFT JOIN	(SELECT  	DA.num_cliente AS num_credito
										,MAX (DA.tl26) AS MOP 
										,MAX(DA.tl38) AS MOP_HISTORICO
										 FROM 		bdiburo:br_tl DA
										 INNER JOIN bdicred:sd_chi_cre_carga_consic_dia DB 
										 ON DB.num_credito = DA.num_cliente
										 AND DB.fecha_carga_sist = DA.fecha 
										 INNER JOIN bdisolic:ss_circulo_frecpag DC ON DA.tl11 = DC.tipo
										 WHERE 		(DA.tl26 in (SELECT codigo FROM bdiburo:br_tlmop WHERE status_cons = 1) 
													OR ((SELECT valor FROM bdisolic:ss_param WHERE empresa = DC.empresa AND secuencia = '309') < ROUND(CASE 
																WHEN DA.tl08 = 'N$' OR tl08 = 'MX' THEN (NVL(DA.tl24, 0)) / vTpCambioUdi
																WHEN DA.tl08 = 'US'                THEN ((NVL(DA.tl24, 0) * vTpCambioUs)) / vTpCambioUdi
																WHEN DA.tl08 = 'UD'                THEN NVL(DA.tl24, 0) 
																ELSE NVL(DA.tl24, 0)
															END, 2) 
														AND DA.tl26 in (SELECT codigo FROM bdiburo:br_tlmop WHERE status_cons = 3)))
													AND NVL(DA.tl26,'') <> ''
													AND DA.tl04 NOT IN (SELECT tl04 
																		FROM bdiburo:br_tl 
																		WHERE institucion = DA.institucion 
																			AND num_cliente = DA.num_cliente 
																			AND tl02='BANCOPPEL' 
																			AND tl30 = 'RV')
													AND DA.tl02 NOT IN (SELECT tipo_negocio
																		FROM bdisolic:ss_cat_tiponegocio_sic 
																		WHERE institucion = DA.institucion)
													AND DB.buro_status IN ('PRP', 'NPP')
										 GROUP BY	DA.num_cliente) AS D ON A.num_credito = D.num_credito
							INNER JOIN	bdicred:"informix".sd_chi_cre_rango_monto_producto E ON A.empresa = E.empresa AND A.producto = E.producto
							WHERE 		A.empresa = v_cempresa 
								AND (A.buro_status = 'PRP' 
									OR (A.buro_status = 'NPP' AND (A.clave_proceso = '2' OR A.clave_proceso = '3') AND A.clave_status = '3'))
							UNION
							SELECT 		A.id, A.nombre, A.fecha_nacimiento, A.rfc, A.curp, A.tipo_residencia, 
										A.estado_civil, A.genero, A.numero_dependientes, A.direccion1, A.direccion2, 
										A.colonia, A.delegacion, A.ciudad, C.descripcion, A.codigo_postal, 
										A.tipo_domicilio, A.num_credito, A.producto, A.monto_credito, A.apell_paterno, 
										A.apell_materno, A.nombre1, A.nombre2
										,(CASE 
											WHEN ((A.clave_proceso = '2' OR A.clave_proceso = '3') AND A.clave_status = '3') 
												THEN '3'
											WHEN (((A.clave_proceso = '2' OR A.clave_proceso = '3') AND (A.clave_status = '1' 
													OR (A.clave_status = 0 AND NVL(D.MOP_HISTORICO,'') <> '99' AND NVL(D.MOP,'') <> '99'))))
												THEN '1' 
											WHEN ((A.clave_proceso = '1' OR A.clave_proceso = '2') AND A.clave_status = '0') 
												THEN '0'
											ELSE '0'
										END) AS clave
										,TRIM(CASE 
												WHEN ((A.clave_proceso = '1' OR A.clave_proceso = '2' OR A.clave_proceso = '3') AND A.clave_status = '3') 
													THEN TRIM(B.descripcion_status)
												WHEN (((A.clave_proceso = '2' OR A.clave_proceso = '3') AND (A.clave_status = '1' 
													OR (A.clave_status = 0 AND NVL(D.MOP_HISTORICO,'') <> '99' AND NVL(D.MOP,'') <> '99'))))
													THEN '' 
												WHEN ((A.clave_proceso = '1' OR A.clave_proceso = '2') AND A.clave_status = '0') 
														THEN TRIM(B.descripcion_proceso)
												ELSE ''
											END) AS msn,
										D.MOP, (CASE WHEN A.monto_credito >= E.monto_minimo AND A.monto_credito <= E.monto_maximo THEN 0 ELSE 1 END) AS id_prod
							FROM 		bdicred:"informix".sd_chi_cre_carga_consic_hist A
							INNER JOIN 	bdicred:"informix".sd_chi_cre_status_procesos_segsic B ON A.empresa = B.empresa AND A.clave_proceso = B.clave_proceso AND A.clave_status = B.clave_status			
							LEFT JOIN 	bdicred:"informix".sd_chi_cre_edos C ON A.empresa = C.empresa AND A.estado = C.abrev_larga
							LEFT JOIN	(SELECT  	DA.num_cliente AS num_credito, MAX (DA.tl26) AS MOP
										,MAX(DA.tl38) AS MOP_HISTORICO
										 FROM 		bdiburo:br_tl DA
										 INNER JOIN bdicred:sd_chi_cre_carga_consic_hist DB 
										 ON DB.num_credito = DA.num_cliente
										 AND DB.fecha_carga_sist = DA.fecha 
										 INNER JOIN bdisolic:ss_circulo_frecpag DC ON DA.tl11 = DC.tipo
										 WHERE 		(DA.tl26 in (SELECT codigo FROM bdiburo:br_tlmop WHERE status_cons = 1) 
													OR ((SELECT valor FROM bdisolic:ss_param WHERE empresa = DC.empresa AND secuencia = '309') < ROUND(CASE 
																WHEN DA.tl08 = 'N$' OR tl08 = 'MX' THEN  (NVL(DA.tl24, 0)) / vTpCambioUdi
																WHEN DA.tl08 = 'US'                THEN ((NVL(DA.tl24, 0) * vTpCambioUs)) / vTpCambioUdi
																WHEN DA.tl08 = 'UD'                THEN   NVL(DA.tl24, 0) 
																ELSE NVL(DA.tl24, 0)
															END, 2) 
														AND DA.tl26 in (SELECT codigo FROM bdiburo:br_tlmop WHERE status_cons = 3)))
													AND NVL(DA.tl26,'') <> ''
													AND DA.tl04 NOT IN (SELECT tl04 
																		FROM bdiburo:br_tl 
																		WHERE institucion = DA.institucion 
																			AND num_cliente = DA.num_cliente 
																			AND tl02='BANCOPPEL' 
																			AND tl30 = 'RV')
													AND DA.tl02 NOT IN (SELECT tipo_negocio
																		FROM bdisolic:ss_cat_tiponegocio_sic 
																		WHERE institucion = DA.institucion)
										 GROUP BY	DA.num_cliente) AS D ON A.num_credito = D.num_credito
							INNER JOIN	bdicred:"informix".sd_chi_cre_rango_monto_producto E ON A.empresa = E.empresa AND A.producto = E.producto
							WHERE 		A.empresa = v_cempresa 
								AND A.buro_status = ('PRP')
					)
				ORDER BY 	id
				
				LET cSQL = ' echo "' || 
					TRIM(v_cnombre_completo) || '	' || v_cfecha_nac || '	' || v_crfc || '	' || v_ccurp || '	' || v_ctipo_resi || '	' || 
					v_cedo_civil || '	' || v_cgenero || '	' || v_cnum_dep || '	' || v_cdir1 || '	' || v_cdir2 || '	' || 
					v_ccolonia || '	' || v_cdelegacion || '	' || v_cciudad || '	' || v_cestado || '	' || '''' || v_ccp || '	' || 
					v_ctipo_dom || '	' || '''' || v_cnum_credito || '	' || v_cprod || '	' || TRIM(REPLACE(CAST(v_cmonto_cred AS CHAR(20)), '$', '')) || '	' || v_sclastat || '	' || 
					TRIM(v_cmotivo) || '	' || TRIM(v_capellido_p) || '	' || TRIM(v_capellido_m) || '	' || TRIM(v_cnombre1) || '	' || TRIM(v_cnombre2) || '	' ||
					v_mop || '	' || v_rechazo_monto ||
					"" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo);
				SYSTEM TRIM(cSQL);
				
				UPDATE bdicred:"informix".sd_chi_cre_carga_consic_dia 
				SET buro_status = 'PCP'
				WHERE id = v_iid 
					AND empresa = v_cempresa 
					AND num_credito = v_cnum_credito
					AND buro_status = 'PRP';
				
				UPDATE bdicred:"informix".sd_chi_cre_carga_consic_hist 
				SET buro_status = 'PCP'
				WHERE id = v_iid 
					AND empresa = v_cempresa 
					AND num_credito = v_cnum_credito
					AND buro_status = 'PRP';
			END FOREACH;
			
-- ****************************************************************************
-- *                   GENERACIÓN DE REPORTE NO PROCESADOS                    *
-- ****************************************************************************	
			FOREACH WITH HOLD
				SELECT A.id, A.nombre, A.fecha_nacimiento, A.rfc, A.curp, A.tipo_residencia, 
					A.estado_civil, A.genero, A.numero_dependientes, A.direccion1, NVL(A.direccion2, ''), 
					A.colonia, NVL(A.delegacion, ''), A.ciudad, NVL(C.descripcion, ''), A.codigo_postal, 
					A.tipo_domicilio, A.num_credito, A.producto, A.monto_credito, 
					A.clave_status, B.descripcion_proceso, NVL(A.apell_paterno, ''), NVL(A.apell_materno, ''), A.nombre1, 
					NVL(A.nombre2, ''), B.descripcion_status
				INTO v_iid, v_cnombre_completo, v_cfecha_nac, v_crfc, v_ccurp, v_ctipo_resi, 
					v_cedo_civil, v_cgenero, v_cnum_dep, v_cdir1, v_cdir2, 
					v_ccolonia, v_cdelegacion, v_cciudad, v_cestado, v_ccp, 
					v_ctipo_dom, v_cnum_credito, v_cprod, v_cmonto_cred,  
					v_sclastat, v_cmotivo, v_capellido_p, v_capellido_m, v_cnombre1, 
					v_cnombre2, v_cdescsta
				FROM bdicred:"informix".sd_chi_cre_carga_consic_dia A
				INNER JOIN bdicred:"informix".sd_chi_cre_status_procesos_segsic B ON A.empresa = B.empresa
					AND A.clave_proceso = B.clave_proceso
					AND A.clave_status = B.clave_status			
                LEFT JOIN bdicred:"informix".sd_chi_cre_edos C ON A.empresa = C.empresa
                    AND A.estado = C.abrev_larga
				WHERE A.empresa = v_cempresa
					AND buro_status = 'NPP'
					AND A.clave_status = 3
				ORDER BY A.id
				
				LET cSQL = ' echo "' || 
					v_iid || '	' || TRIM(v_cnombre_completo) || '	' || v_cfecha_nac || '	' || v_crfc || '	' || v_ccurp || '	' || v_ctipo_resi || '	' || 
					v_cedo_civil || '	' || v_cgenero || '	' || v_cnum_dep || '	' || v_cdir1 || '	' || v_cdir2 || '	' || 
					v_ccolonia || '	' || v_cdelegacion || '	' || v_cciudad || '	' || v_cestado || '	' || '''' || v_ccp || '	' || 
					v_ctipo_dom || '	' || '''' || v_cnum_credito || '	' || v_cprod || '	' || TRIM(REPLACE(CAST(v_cmonto_cred AS CHAR(20)), '$', '')) || '	' || v_sclastat || '	' || 
					TRIM(v_cmotivo) || ' ' || TRIM(v_cdescsta) || '	' || TRIM(v_capellido_p) || '	' || TRIM(v_capellido_m) || '	' || TRIM(v_cnombre1) || '	' || TRIM(v_cnombre2) ||
					"" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo2);
				SYSTEM TRIM(cSQL);
			END FOREACH;
		END IF;
		
-- ****************************************************************************
-- *                      ARCHIVOS REPROCESAMIENTO                            *
-- ****************************************************************************	
		IF p_ccodproc = 'R' THEN
			LET cNombreArchivo = TRIM(cArchivoRepHito) || cYear || cMes || cDia || '.xls ';
			LET cSQL = ' echo "NOMBRE	FECHA DE NACIMIENTO	RFC	CURP	TIPO DE RESIDENCIA	ESTADO CIVIL	GENERO	NUMERO DE DEPENDIENTES	DIRECCION1	DIRECCION2	COLONIA	DELEGACION	CIUDAD	ESTADO	CODIGO POSTAL	TIPO DOMICILIO	num_credito	PRODUCTO	MONTO CREDITO	FONDEO	MOTIVO	APELLIDO PATERNO	APELLIDO MATERNO 	NOMBRE1	NOMBRE2	MOP	RECHAZO POR MONTO' ||
				"" || '">'||TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM TRIM(cSQL);
			
			LET cSQL = 'chmod 777 '|| TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM cSQL;
			
			LET cNombreArchivo2 = TRIM(cArchivoRepUsr) || cYear || cMes || cDia || '.xls ';
			LET cSQL = ' echo "ID REGISTRO	NOMBRE	FECHA DE NACIMIENTO	RFC	CURP	TIPO DE RESIDENCIA	ESTADO CIVIL	GENERO	NUMERO DE DEPENDIENTES	DIRECCION1	DIRECCION2	COLONIA	DELEGACION	CIUDAD	ESTADO	CODIGO POSTAL	TIPO DOMICILIO	num_credito	PRODUCTO	MONTO CREDITO	FONDEO	MOTIVO	APELLIDO PATERNO	APELLIDO MATERNO 	NOMBRE1	NOMBRE2' ||
				"" || '">'||TRIM(cRuta)|| TRIM(cNombreArchivo2);
			SYSTEM TRIM(cSQL);
			
			LET cSQL = 'chmod 777 '|| TRIM(cRuta)|| TRIM(cNombreArchivo2);
			SYSTEM cSQL;
			
-- ****************************************************************************
-- *                     GENERACIÓN DE REPORTE TOTAL                          *
-- ****************************************************************************	
			FOREACH WITH HOLD
				SELECT 		A.id, A.nombre, A.fecha_nacimiento, A.rfc, A.curp, A.tipo_residencia, 
							A.estado_civil, A.genero, A.numero_dependientes, A.direccion1, NVL(A.direccion2, ''), 
							A.colonia, NVL(A.delegacion, ''), A.ciudad, NVL(C.descripcion, ''), A.codigo_postal, 
							A.tipo_domicilio, A.num_credito, A.producto, A.monto_credito, NVL(A.apell_paterno, ''), 
							NVL(A.apell_materno, ''), A.nombre1, NVL(A.nombre2, '')
							,(CASE 
								WHEN ((A.clave_proceso = '2' OR A.clave_proceso = '3') AND A.clave_status = '3') 
									THEN '3'
								WHEN (((A.clave_proceso = '2' OR A.clave_proceso = '3') AND (A.clave_status = '1' 
										OR (A.clave_status = 0 AND NVL(D.MOP_HISTORICO,'') <> '99' AND NVL(D.MOP,'') <> '99'))))
									THEN '1' 
								WHEN ((A.clave_proceso = '1' OR A.clave_proceso = '2') AND A.clave_status = '0') 
									THEN '0'
								ELSE '0'
							END)
							,TRIM(CASE 
									WHEN ((A.clave_proceso = '1' OR A.clave_proceso = '2' OR A.clave_proceso = '3') AND A.clave_status = '3') 
										THEN TRIM(B.descripcion_status)
									WHEN (((A.clave_proceso = '2' OR A.clave_proceso = '3') AND (A.clave_status = '1' 
										OR (A.clave_status = 0 AND NVL(D.MOP_HISTORICO,'') <> '99' AND NVL(D.MOP,'') <> '99'))))	
										THEN '' 
									WHEN ((A.clave_proceso = '1' OR A.clave_proceso = '2') AND A.clave_status = '0') 
										THEN TRIM(B.descripcion_proceso)
									ELSE ''
									END)
							,NVL(D.MOP, ''), (CASE WHEN A.monto_credito >= E.monto_minimo AND A.monto_credito <= E.monto_maximo THEN 0 ELSE 1 END)
				INTO 		v_iid, v_cnombre_completo, v_cfecha_nac, v_crfc, v_ccurp, v_ctipo_resi, 
							v_cedo_civil, v_cgenero, v_cnum_dep, v_cdir1, v_cdir2, 
							v_ccolonia, v_cdelegacion, v_cciudad, v_cestado, v_ccp, 
							v_ctipo_dom, v_cnum_credito, v_cprod, v_cmonto_cred, v_capellido_p, 
							v_capellido_m, v_cnombre1, v_cnombre2, v_sclastat, v_cmotivo,
							v_mop, v_rechazo_monto
				FROM 		bdicred:"informix".sd_chi_cre_carga_consic_hist A
				INNER JOIN 	bdicred:"informix".sd_chi_cre_status_procesos_segsic B ON A.empresa = B.empresa AND A.clave_proceso = B.clave_proceso AND A.clave_status = B.clave_status			
                LEFT JOIN 	bdicred:"informix".sd_chi_cre_edos C ON A.empresa = C.empresa AND A.estado = C.abrev_larga
				LEFT JOIN	(SELECT  	DA.num_cliente AS num_credito, MAX (DA.tl26) AS MOP 
							,MAX(DA.tl38) AS MOP_HISTORICO
							 FROM 		bdiburo:br_tl DA
							 INNER JOIN bdicred:sd_chi_cre_carga_consic_hist DB 
							 ON DB.num_credito = DA.num_cliente
							 AND (DB.fecha_carga_sist = DA.fecha OR DB.fecha_reproceso = DA.fecha)
							 INNER JOIN bdisolic:ss_circulo_frecpag DC ON DA.tl11 = DC.tipo
							 WHERE 		(DA.tl26 in (SELECT codigo FROM bdiburo:br_tlmop WHERE status_cons = 1) 
										OR ((SELECT valor FROM bdisolic:ss_param WHERE empresa = DC.empresa AND secuencia = '309') < ROUND(CASE 
													WHEN DA.tl08 = 'N$' OR tl08 = 'MX' THEN  (NVL(DA.tl24, 0)) / vTpCambioUdi
													WHEN DA.tl08 = 'US'                THEN ((NVL(DA.tl24, 0) * vTpCambioUs)) / vTpCambioUdi
													WHEN DA.tl08 = 'UD'                THEN   NVL(DA.tl24, 0) 
													ELSE NVL(DA.tl24, 0)
												END, 2) 
											AND DA.tl26 in (SELECT codigo FROM bdiburo:br_tlmop WHERE status_cons = 3)))
										AND NVL(DA.tl26,'') <> ''
										AND DA.tl04 NOT IN (SELECT tl04 
															FROM bdiburo:br_tl 
															WHERE institucion = DA.institucion 
																AND num_cliente = DA.num_cliente 
																AND tl02='BANCOPPEL' 
																AND tl30 = 'RV')
										AND DA.tl02 NOT IN (SELECT tipo_negocio
															FROM bdisolic:ss_cat_tiponegocio_sic 
															WHERE institucion = DA.institucion)
										AND (DB.buro_status = 'PRR' 
											OR (DB.buro_status = 'NPR' AND (DB.clave_proceso = '2' OR DB.clave_proceso = '3') AND DB.clave_status = '3'))--DB.id IN (SELECT id FROM bdicred:"informix".sd_chi_cre_carga_reproceso_consic)
							 GROUP BY	DA.num_cliente) AS D ON A.num_credito = D.num_credito
				INNER JOIN	bdicred:"informix".sd_chi_cre_rango_monto_producto E ON A.empresa = E.empresa AND A.producto = E.producto
				WHERE 		A.empresa = v_cempresa 
					AND (A.buro_status = 'PRR' 
					OR (A.buro_status = 'NPR' AND (A.clave_proceso = '2' OR A.clave_proceso = '3') AND A.clave_status = '3')) --A.id IN (SELECT id FROM bdicred:"informix".sd_chi_cre_carga_reproceso_consic)
				ORDER BY 	A.id
				
				LET cSQL = ' echo "' || 
					TRIM(v_cnombre_completo) || '	' || v_cfecha_nac || '	' || v_crfc || '	' || v_ccurp || '	' || v_ctipo_resi || '	' || 
					v_cedo_civil || '	' || v_cgenero || '	' || v_cnum_dep || '	' || v_cdir1 || '	' || v_cdir2 || '	' || 
					v_ccolonia || '	' || v_cdelegacion || '	' || v_cciudad || '	' || v_cestado || '	' || '''' || v_ccp || '	' || 
					v_ctipo_dom || '	' || '''' || v_cnum_credito || '	' || v_cprod || '	' || TRIM(REPLACE(CAST(v_cmonto_cred AS CHAR(20)), '$', '')) || '	' || v_sclastat || '	' || 
					v_cmotivo || '	' || TRIM(v_capellido_p) || '	' || TRIM(v_capellido_m) || '	' || TRIM(v_cnombre1) || '	' || TRIM(v_cnombre2) || '	' ||
					v_mop || '	' || v_rechazo_monto ||
					"" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo);
				SYSTEM TRIM(cSQL);
				
				UPDATE bdicred:"informix".sd_chi_cre_carga_consic_hist 
				SET buro_status = 'PCR'
				WHERE id = v_iid 
					AND empresa = v_cempresa 
					AND num_credito = v_cnum_credito
					AND buro_status = 'PRR';
			END FOREACH;
			
-- ****************************************************************************
-- *                   GENERACIÓN DE REPORTE NO PROCESADOS                    *
-- ****************************************************************************	
			FOREACH WITH HOLD
				SELECT A.id, A.nombre, A.fecha_nacimiento, A.rfc, A.curp, A.tipo_residencia, 
					A.estado_civil, A.genero, A.numero_dependientes, A.direccion1, NVL(A.direccion2, ''), 
					A.colonia, NVL(A.delegacion, ''), A.ciudad, NVL(C.descripcion, ''), A.codigo_postal, 
					A.tipo_domicilio, A.num_credito, A.producto, A.monto_credito, 
					A.clave_status, B.descripcion_proceso, NVL(A.apell_paterno, ''), NVL(A.apell_materno, ''), A.nombre1, 
					NVL(A.nombre2, ''), B.descripcion_status
				INTO v_iid, v_cnombre_completo, v_cfecha_nac, v_crfc, v_ccurp, v_ctipo_resi, 
					v_cedo_civil, v_cgenero, v_cnum_dep, v_cdir1, v_cdir2, 
					v_ccolonia, v_cdelegacion, v_cciudad, v_cestado, v_ccp, 
					v_ctipo_dom, v_cnum_credito, v_cprod, v_cmonto_cred, 
					v_sclastat, v_cmotivo, v_capellido_p, v_capellido_m, v_cnombre1, 
					v_cnombre2, v_cdescsta
				FROM bdicred:"informix".sd_chi_cre_carga_consic_hist A
				INNER JOIN bdicred:"informix".sd_chi_cre_status_procesos_segsic B ON A.empresa = B.empresa
					AND A.clave_proceso = B.clave_proceso
					AND A.clave_status = B.clave_status			
                LEFT JOIN bdicred:"informix".sd_chi_cre_edos C ON A.empresa = C.empresa
                    AND A.estado = C.abrev_larga
				WHERE A.empresa = v_cempresa
					--AND A.id IN (SELECT id FROM bdicred:"informix".sd_chi_cre_carga_reproceso_consic)
					AND A.buro_status = 'NPR'
					AND A.clave_status = 3
				ORDER BY A.id
				
				LET cSQL = ' echo "' || 
					v_iid || '	' || TRIM(v_cnombre_completo) || '	' || v_cfecha_nac || '	' || v_crfc || '	' || v_ccurp || '	' || v_ctipo_resi || '	' || 
					v_cedo_civil || '	' || v_cgenero || '	' || v_cnum_dep || '	' || v_cdir1 || '	' || v_cdir2 || '	' || 
					v_ccolonia || '	' || v_cdelegacion || '	' || v_cciudad || '	' || v_cestado || '	' || '''' || v_ccp || '	' || 
					v_ctipo_dom || '	' || '''' || v_cnum_credito || '	' || v_cprod || '	' || TRIM(REPLACE(CAST(v_cmonto_cred AS CHAR(20)), '$', '')) || '	' || v_sclastat || '	' || 
					TRIM(v_cmotivo) || ' ' || TRIM(v_cdescsta) || '	' || TRIM(v_capellido_p) || '	' || TRIM(v_capellido_m) || '	' || TRIM(v_cnombre1) || '	' || TRIM(v_cnombre2) ||
					"" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo2);
				SYSTEM TRIM(cSQL);
			END FOREACH;
		END IF;
		
		RETURN cod_ret;
	END
END PROCEDURE;