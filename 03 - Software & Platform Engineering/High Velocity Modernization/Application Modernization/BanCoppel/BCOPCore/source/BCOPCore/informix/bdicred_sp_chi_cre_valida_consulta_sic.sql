CREATE PROCEDURE "informix".sp_chi_cre_valida_consulta_sic (
	p_ccodproc CHAR(1), p_iidinicial INTEGER
) RETURNING CHAR(5) as codigo_retorno;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	--Creado por: Isaac Flores Ruiz
	--Fecha de creación: 17/02/2022
	--Peticion: RQI 28 296
	--Modificado por: 
	--Fecha de modificación: 
	--Modificación: 
	--BD: bdicred
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
	DEFINE		v_i                     INTEGER;
	DEFINE		v_idcontrol             INTEGER;
	DEFINE		v_idcontrolini          INTEGER;
	DEFINE		v_iid                   INTEGER;
	DEFINE		v_iespacio_aux			INTEGER;
	DEFINE		v_iid_segmento			INTEGER;
	DEFINE		v_iban					INTEGER;
	DEFINE		v_sind_validado         SMALLINT;
	DEFINE		v_sind_listas_negras    SMALLINT;
	DEFINE		v_cnombre_aux           CHAR(104);
	DEFINE		v_cnombre_completo      CHAR(104);
	DEFINE		v_csegmento_1           CHAR(15);
	DEFINE		v_csegmento_2           CHAR(15);
	DEFINE		v_csegmento_3           CHAR(15);
	DEFINE		v_csegmento_4           CHAR(15);
	DEFINE		v_csegmento_5           CHAR(15);
	DEFINE		v_csegmento_6           CHAR(15);
	DEFINE		v_ccurp_p1              CHAR(1);
	DEFINE		v_ccurp_p2              CHAR(1);
	DEFINE		v_ccurp_p3              CHAR(1);
	DEFINE		v_ccurp_p4              CHAR(1);
	DEFINE		v_ccurp_p56             CHAR(2);
	DEFINE		v_ccurp_p78             CHAR(2);
	DEFINE		v_ccurp_p910            CHAR(2);
	DEFINE		v_ccurp_p11             CHAR(1);
	DEFINE		v_ccurp_p1213           CHAR(2);
	DEFINE		v_ccurp_p14             CHAR(1);
	DEFINE		v_ccurp_p15             CHAR(1);
	DEFINE		v_ccurp_p16             CHAR(1);
	DEFINE		v_ccurp_p17             CHAR(1);
	DEFINE		v_ccurp_p18             CHAR(1);
	DEFINE		v_ccurp_armado          CHAR(18);
	DEFINE		v_cnombre2_aux          CHAR(1);
	DEFINE		v_crfc_armado           CHAR(13);
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
	DEFINE		v_cestado               CHAR(4);
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
	DEFINE		v_mmontomin             MONEY(18, 2);
	DEFINE		v_mmontomax             MONEY(18, 2);
	DEFINE      v_ccalificacion         CHAR(1);
	DEFINE      v_dcompromisos          DECIMAL(14,2);
	DEFINE      v_cmotivo               VARCHAR(255);
	DEFINE		v_icountproc			INTEGER;
	DEFINE		v_icountreg				INTEGER;
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
	LET			v_idcontrol				= 0;
	LET			v_idcontrolini          = 0;
	LET			v_iid                   = 0;
	LET			v_iid_segmento          = 0;
	LET			v_iban			        = 0;
	LET			v_sind_validado         = 0;
	LET			v_sind_listas_negras    = 0;
	LET			v_cnombre_aux           = '';
	LET			v_cnombre_completo      = '';
	LET			v_csegmento_1           = '';
	LET			v_csegmento_2           = '';
	LET			v_csegmento_3           = '';
	LET			v_csegmento_4           = '';
	LET			v_csegmento_5           = '';
	LET			v_csegmento_6           = '';
	LET			v_ccurp_p1              = '';
	LET			v_ccurp_p2              = '';
	LET			v_ccurp_p3              = '';
	LET			v_ccurp_p4              = '';
	LET			v_ccurp_p56             = '';
	LET			v_ccurp_p78             = '';
	LET			v_ccurp_p910            = '';
	LET			v_ccurp_p11             = '';
	LET			v_ccurp_p1213           = '';
	LET			v_ccurp_p14             = '';
	LET			v_ccurp_p15             = '';
	LET			v_ccurp_p16             = '';
	LET			v_ccurp_p17             = '';
	LET			v_ccurp_p18             = '';
	LET			v_ccurp_armado          = '';
	LET			v_cnombre2_aux          = '';
	LET			v_crfc_armado           = '';
	LET			v_iid_segmento			= 1;
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
	LET			v_cmonto_cred           = '0.0';
	LET			v_cempresa              = '001';
	LET			v_sind_segnom_valido    = '0';
	LET			v_sind_fondeo_mont_prod = '0';
	LET			v_cclave_proc           = '0';
	LET			v_cclave_status         = '0';
	LET			v_mmontomin             = 0.0;
	LET			v_mmontomax             = 0.0;
	LET			v_ccalificacion         = '0';
	LET			v_dcompromisos          = 0.0;
	LET			v_cmotivo               = '';
	LET			v_icountproc            = 0;
	LET			v_icountreg             = 0;
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
				LET mensaje_ret = 'VERIFICAR RUTA DEL ARCHIVO A EJECUTAR';
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
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
--*****************************************************************
--*						Debug del Procedure                     --*        
--*****************************************************************
		--SET DEBUG FILE TO '/RESPALDOSNEW/hipotecario_infonavit/sics/sp_chi_cre_valida_consulta_sic.out';
		--TRACE ON;                                                     --*
		
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	
-- ****************************************************************************
-- *                        ENVIO A CONSULTA MOP                              *
-- ****************************************************************************	
		IF p_ccodproc = 'P' THEN		
			FOREACH WITH HOLD				
				SELECT id, empresa, nombre, fecha_nacimiento, rfc, 
					curp, tipo_residencia, estado_civil, genero, numero_dependientes, 
					direccion1, direccion2, colonia, delegacion, ciudad, 
					estado, codigo_postal, tipo_domicilio, num_credito, producto, 
					monto_credito, apell_paterno, apell_materno, nombre1, nombre2, 
					ind_segnom_valido, ind_fondeo_mont_prod, clave_proceso, clave_status
				INTO v_idcontrol, v_cempresa, v_cnombre_completo, v_cfecha_nac, v_crfc, 
					v_ccurp, v_ctipo_resi, v_cedo_civil, v_cgenero, v_cnum_dep, 
					v_cdir1, v_cdir2, v_ccolonia, v_cdelegacion, v_cciudad, 
					v_cestado, v_ccp, v_ctipo_dom, v_cnum_credito, v_cprod, 
					v_cmonto_cred, v_capellido_p, v_capellido_m, v_cnombre1, v_cnombre2,
					v_sind_segnom_valido, v_sind_fondeo_mont_prod, v_cclave_proc, v_cclave_status
				FROM (SELECT a.id, a.empresa, a.nombre, a.fecha_nacimiento, a.rfc, a.
							curp, a.tipo_residencia, a.estado_civil, a.genero, a.numero_dependientes, a.
							direccion1, a.direccion2, a.colonia, a.delegacion, a.ciudad, a.
							estado, a.codigo_postal, a.tipo_domicilio, a.num_credito, a.producto, a.
							monto_credito, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, a.
							ind_segnom_valido, a.ind_fondeo_mont_prod, a.clave_proceso, a.clave_status
						FROM bdicred:"informix".sd_chi_cre_carga_consic_dia AS a
						INNER JOIN bdiburo:"informix".br_respuesta_aprocesar AS b ON b.institucion = 'BC'
							AND b.numcte = a.num_credito
							AND b.status = 'OK'
							AND b.fecha_insert = a.fecha_carga_sist
						WHERE a.empresa = v_cempresa
							AND a.clave_proceso = 1
							AND a.clave_status = 1
							AND a.ind_segnom_valido = 1
							AND a.buro_status = 'NPP'
						UNION
						SELECT a.id, a.empresa, a.nombre, a.fecha_nacimiento, a.rfc, a.
							curp, a.tipo_residencia, a.estado_civil, a.genero, a.numero_dependientes, a.
							direccion1, a.direccion2, a.colonia, a.delegacion, a.ciudad, a.
							estado, a.codigo_postal, a.tipo_domicilio, a.num_credito, a.producto, a.
							monto_credito, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, a.
							ind_segnom_valido, a.ind_fondeo_mont_prod, a.clave_proceso, a.clave_status
						FROM bdicred:"informix".sd_chi_cre_carga_consic_hist AS a
						INNER JOIN bdiburo:"informix".br_respuesta_aprocesar AS b ON b.institucion = 'BC'
							AND b.numcte = a.num_credito
							AND b.status = 'OK'
							AND b.fecha_insert = a.fecha_carga_sist
						WHERE a.empresa = v_cempresa
							AND a.clave_proceso = 1
							AND a.clave_status = 1
							AND a.ind_segnom_valido = 1
							AND a.buro_status = 'NPP'
					)
				ORDER BY id
				
				EXECUTE FUNCTION bdisolic:"informix".cal_circulocredito_cjunk2 (
					v_cempresa, v_cnum_credito, v_cnum_credito
				) INTO cod_ret_aux, v_ccalificacion, v_dcompromisos, v_cmotivo; 
						  
				IF v_ccalificacion = 'X' THEN
					SELECT monto_minimo, monto_maximo
					INTO v_mmontomin, v_mmontomax
					FROM bdicred:"informix".sd_chi_cre_rango_monto_producto
					WHERE empresa = v_cempresa
						AND producto = v_cprod
						AND status = 1;
						
					UPDATE bdicred:"informix".sd_chi_cre_carga_consic_dia 
					SET clave_proceso = 2	--(CASE WHEN v_cmonto_cred >= v_mmontomin AND v_cmonto_cred <= v_mmontomax THEN 3 ELSE 2 END)
						, clave_status = (CASE WHEN v_cmonto_cred >= v_mmontomin AND v_cmonto_cred <= v_mmontomax THEN 1 ELSE 0 END)
						, ind_fondeo_mont_prod = (CASE WHEN v_cmonto_cred >= v_mmontomin AND v_cmonto_cred <= v_mmontomax THEN '1' ELSE '0' END)
						, buro_status = 'PRP'
					WHERE id = v_idcontrol
						AND empresa = v_cempresa
						AND num_credito = v_cnum_credito;
						
					UPDATE bdicred:"informix".sd_chi_cre_carga_consic_hist 
					SET clave_proceso = 2	--(CASE WHEN v_cmonto_cred >= v_mmontomin AND v_cmonto_cred <= v_mmontomax THEN 3 ELSE 2 END)
						, clave_status = (CASE WHEN v_cmonto_cred >= v_mmontomin AND v_cmonto_cred <= v_mmontomax THEN 1 ELSE 0 END)
						, ind_fondeo_mont_prod = (CASE WHEN v_cmonto_cred >= v_mmontomin AND v_cmonto_cred <= v_mmontomax THEN '1' ELSE '0' END)
						, buro_status = 'PRP'
					WHERE id = v_idcontrol
						AND empresa = v_cempresa
						AND num_credito = v_cnum_credito;
				ELSE
					UPDATE bdicred:"informix".sd_chi_cre_carga_consic_dia 
					SET clave_proceso = 2	--(CASE WHEN v_ccalificacion = '0' THEN 3 ELSE 2 END)
						, clave_status = (CASE WHEN v_ccalificacion = '0' THEN 1 ELSE 0 END)
						, buro_status = 'PRP'
					WHERE id = v_idcontrol 
						AND empresa = v_cempresa 
						AND num_credito = v_cnum_credito;
						
					UPDATE bdicred:"informix".sd_chi_cre_carga_consic_hist 
					SET clave_proceso = 2	--(CASE WHEN v_ccalificacion = '0' THEN 3 ELSE 2 END)
						, clave_status = (CASE WHEN v_ccalificacion = '0' THEN 1 ELSE 0 END)
						, buro_status = 'PRP'
					WHERE id = v_idcontrol 
						AND empresa = v_cempresa 
						AND num_credito = v_cnum_credito;
				END IF;
				
			END FOREACH;
		END IF;
		
		IF p_ccodproc = 'R' THEN
			FOREACH WITH HOLD				
				SELECT a.id, a.empresa, a.nombre, a.fecha_nacimiento, a.rfc, a.
					curp, a.tipo_residencia, a.estado_civil, a.genero, a.numero_dependientes, a.
					direccion1, a.direccion2, a.colonia, a.delegacion, a.ciudad, a.
					estado, a.codigo_postal, a.tipo_domicilio, a.num_credito, a.producto, a.
					monto_credito, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, a.
					ind_segnom_valido, a.ind_fondeo_mont_prod, a.clave_proceso, a.clave_status
				INTO v_idcontrol, v_cempresa, v_cnombre_completo, v_cfecha_nac, v_crfc, 
					v_ccurp, v_ctipo_resi, v_cedo_civil, v_cgenero, v_cnum_dep, 
					v_cdir1, v_cdir2, v_ccolonia, v_cdelegacion, v_cciudad, 
					v_cestado, v_ccp, v_ctipo_dom, v_cnum_credito, v_cprod, 
					v_cmonto_cred, v_capellido_p, v_capellido_m, v_cnombre1, v_cnombre2,
					v_sind_segnom_valido, v_sind_fondeo_mont_prod, v_cclave_proc, v_cclave_status
				FROM bdicred:"informix".sd_chi_cre_carga_consic_hist AS a
				INNER JOIN bdiburo:"informix".br_respuesta_aprocesar AS b ON b.institucion = 'BC'
					AND b.numcte = a.num_credito
					AND b.status = 'OK'
					AND (b.fecha_insert = a.fecha_carga_sist OR b.fecha_insert = a.fecha_reproceso)
				WHERE a.empresa = v_cempresa
					AND a.buro_status = 'NPR'
				ORDER BY id
				
				EXECUTE FUNCTION bdisolic:"informix".cal_circulocredito_cjunk2 (
					v_cempresa, v_cnum_credito, v_cnum_credito
				) INTO cod_ret_aux, v_ccalificacion, v_dcompromisos, v_cmotivo; 
						  
				IF v_ccalificacion = 'X' THEN
					SELECT monto_minimo, monto_maximo
					INTO v_mmontomin, v_mmontomax
					FROM bdicred:"informix".sd_chi_cre_rango_monto_producto
					WHERE empresa = v_cempresa
						AND producto = v_cprod
						AND status = 1;
						
					UPDATE bdicred:"informix".sd_chi_cre_carga_consic_hist 
					SET clave_proceso = 2	--(CASE WHEN v_cmonto_cred >= v_mmontomin AND v_cmonto_cred <= v_mmontomax THEN 3 ELSE 2 END)
						, clave_status = (CASE WHEN v_cmonto_cred >= v_mmontomin AND v_cmonto_cred <= v_mmontomax THEN '1' ELSE '0' END)
						, ind_fondeo_mont_prod = (CASE WHEN v_cmonto_cred >= v_mmontomin AND v_cmonto_cred <= v_mmontomax THEN '1' ELSE '0' END)
						, buro_status = 'PRR'
					WHERE id = v_idcontrol
						AND empresa = v_cempresa
						AND num_credito = v_cnum_credito;
				ELSE
					UPDATE bdicred:"informix".sd_chi_cre_carga_consic_hist 
					SET clave_proceso = 2	--(CASE WHEN v_ccalificacion = '0' THEN 3 ELSE 2 END)
						, clave_status = (CASE WHEN v_ccalificacion = '0' THEN '1' ELSE '0' END)
						, buro_status = 'PRR'
					WHERE id = v_idcontrol 
						AND empresa = v_cempresa 
						AND num_credito = v_cnum_credito;
				END IF;
				
			END FOREACH;
		END IF;		
-- ****************************************************************************
-- *                   ENVIO A GENERACIÓN DE REPORTES                         *
-- ****************************************************************************
		EXECUTE PROCEDURE bdicred:"informix".sp_chi_cre_result_consulta_sic(p_ccodproc, p_iidinicial)
		INTO cod_ret;		
		
		RETURN cod_ret;	
	END	
END PROCEDURE;